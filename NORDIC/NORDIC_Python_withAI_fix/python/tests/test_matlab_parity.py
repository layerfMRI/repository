"""MATLAB-parity tests for run_nordic.

Covers the two patches that bring the Python implementation in line with
MATLAB NIFTI_NORDIC's behaviour:

1. ``magnitude_only=True`` forces ``temporal_phase=0`` (mirrors
   ``ARG.magnitude_only=1``), and a safety net auto-corrects the implicit
   ``pha_file=None`` + ``temporal_phase>0`` footgun that otherwise applies
   a Tukey-windowed phase filter to non-existent phase data.
2. The output dtype is forced to float32 so integer-typed inputs aren't
   truncated on write.

The tests use a small synthetic phantom so they run in a few seconds and
don't depend on the downloaded test_dataset fixture.

NORDIC's NVR-threshold step draws random matrices via ``np.random.normal``,
which makes back-to-back calls non-deterministic unless we re-seed the
legacy global RNG before each call. The helper ``_seeded_run_nordic`` does
that so the two paths we compare are bit-identical.
"""

import nibabel as nb
import numpy as np
import pytest

from nordic.denoise import run_nordic


def _seeded_run_nordic(seed=0, **kwargs):
    """Re-seed NumPy's legacy global RNG, then call run_nordic.

    NORDIC's threshold draw and zero-element fill use ``np.random.normal``
    (the legacy global RNG), not ``np.random.default_rng``. Re-seeding via
    ``np.random.seed`` is therefore enough to make a run deterministic.
    """
    np.random.seed(seed)
    return run_nordic(**kwargs)


_PHANTOM_SHAPE = (16, 16, 8, 16)

# Kernel knobs that make this run in a few seconds on the phantom.
_FAST_KWARGS = dict(
    algorithm='nordic',
    kernel_size_gfactor=[4, 4, 4, 8],
    kernel_size_pca=[4, 4, 4],
    patch_overlap_gfactor=2,
    patch_overlap_pca=2,
    save_gfactor_map=False,
    soft_thrs='auto',
)


def _make_phantom(path, dtype=np.float32, shape=_PHANTOM_SHAPE, seed=0):
    """Write a small synthetic 4D magnitude NIfTI and return its path."""
    rng = np.random.default_rng(seed)
    sig = np.zeros(shape, dtype=np.float32)
    cx, cy, cz = (s // 2 for s in shape[:3])
    sig[cx - 3 : cx + 3, cy - 3 : cy + 3, cz - 2 : cz + 2, :] = 1000.0
    noise = rng.standard_normal(shape).astype(np.float32) * 30.0
    data = sig + noise + 200.0  # baseline keeps values positive
    if np.issubdtype(dtype, np.integer):
        info = np.iinfo(dtype)
        data = np.clip(data, info.min, info.max).astype(dtype)
    else:
        data = data.astype(dtype)
    img = nb.Nifti1Image(data, np.eye(4))
    img.to_filename(path)
    return path


def _read_array(path):
    return np.asarray(nb.load(path).dataobj)


def test_magnitude_only_overrides_temporal_phase(tmp_path):
    """magnitude_only=True must force temporal_phase to 0, producing the
    same output as an explicit temporal_phase=0 call."""
    mag = _make_phantom(tmp_path / 'mag.nii.gz')

    out_mo = tmp_path / 'mo'
    out_tp0 = tmp_path / 'tp0'

    with pytest.warns(UserWarning, match='magnitude_only=True'):
        _seeded_run_nordic(
            mag_file=mag, out_dir=out_mo,
            magnitude_only=True, temporal_phase=1, **_FAST_KWARGS,
        )
    _seeded_run_nordic(
        mag_file=mag, out_dir=out_tp0,
        magnitude_only=False, temporal_phase=0, **_FAST_KWARGS,
    )

    np.testing.assert_array_equal(
        _read_array(out_mo / 'magn.nii.gz'),
        _read_array(out_tp0 / 'magn.nii.gz'),
    )


def test_implicit_magnitude_only_is_auto_corrected(tmp_path):
    """pha_file=None + temporal_phase>0 must warn and behave as
    temporal_phase=0 (the safety-net path)."""
    mag = _make_phantom(tmp_path / 'mag.nii.gz')

    out_implicit = tmp_path / 'implicit'
    out_explicit = tmp_path / 'explicit'

    with pytest.warns(UserWarning, match='pha_file=None'):
        _seeded_run_nordic(
            mag_file=mag, out_dir=out_implicit,
            magnitude_only=False, temporal_phase=1, **_FAST_KWARGS,
        )
    _seeded_run_nordic(
        mag_file=mag, out_dir=out_explicit,
        magnitude_only=False, temporal_phase=0, **_FAST_KWARGS,
    )

    np.testing.assert_array_equal(
        _read_array(out_implicit / 'magn.nii.gz'),
        _read_array(out_explicit / 'magn.nii.gz'),
    )


def test_magnitude_only_ignores_phase_file(tmp_path):
    """magnitude_only=True with a pha_file passed should warn and ignore
    it, producing the same output as the no-phase call."""
    mag = _make_phantom(tmp_path / 'mag.nii.gz')

    rng = np.random.default_rng(1)
    pha = rng.uniform(-np.pi, np.pi, size=_PHANTOM_SHAPE).astype(np.float32)
    pha_path = tmp_path / 'pha.nii.gz'
    nb.Nifti1Image(pha, np.eye(4)).to_filename(pha_path)

    out_with = tmp_path / 'with_pha'
    out_without = tmp_path / 'without_pha'

    with pytest.warns(UserWarning, match='ignoring pha_file'):
        _seeded_run_nordic(
            mag_file=mag, pha_file=pha_path, out_dir=out_with,
            magnitude_only=True, temporal_phase=0, **_FAST_KWARGS,
        )
    _seeded_run_nordic(
        mag_file=mag, out_dir=out_without,
        magnitude_only=True, temporal_phase=0, **_FAST_KWARGS,
    )

    np.testing.assert_array_equal(
        _read_array(out_with / 'magn.nii.gz'),
        _read_array(out_without / 'magn.nii.gz'),
    )


def test_output_is_float32_for_int16_input(tmp_path):
    """int16 input must not cause output truncation; the on-disk dtype
    must be float32 (matches MATLAB info.Datatype='single'), and the
    written values must not collapse onto integers.

    We don't assert ``scl_slope == 1`` directly: for float types nibabel
    canonically writes ``scl_slope = NaN`` to signal "no scaling". The
    semantic guarantee is checked via ``get_fdata()`` vs the raw
    ``dataobj`` — they must be element-wise identical (no effective
    scaling applied).
    """
    mag = _make_phantom(tmp_path / 'mag.nii.gz', dtype=np.int16)

    out = tmp_path / 'out'
    _seeded_run_nordic(
        mag_file=mag, out_dir=out,
        magnitude_only=True, temporal_phase=0, **_FAST_KWARGS,
    )

    img = nb.load(out / 'magn.nii.gz')
    assert img.get_data_dtype() == np.float32

    raw = np.asarray(img.dataobj)
    fdata = img.get_fdata()
    np.testing.assert_array_equal(raw.astype(np.float64), fdata)

    # Output must not be silently rounded to integers (the int16-truncation
    # bug). At least some voxels should carry sub-integer fractional parts.
    assert not np.all(raw == np.round(raw))
