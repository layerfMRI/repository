"""Tests for the denoise module."""

import pytest

from nordic import denoise


@pytest.mark.parametrize('use_phase', [True, False])
@pytest.mark.parametrize('use_norf', [True, False])
@pytest.mark.parametrize('full_dynamic_range', [True, False])
@pytest.mark.parametrize('temporal_phase', [0, 1, 2, 3])
@pytest.mark.parametrize('algorithm', ['nordic', 'mppca', 'gfactor+mppca'])
@pytest.mark.parametrize('phase_slice_average_for_kspace_centering', [True, False])
@pytest.mark.parametrize('scale_patches', [True, False])
@pytest.mark.parametrize('patch_average', [True, False])
def _test_run_nordic_smoke(
    use_phase,
    use_norf,
    full_dynamic_range,
    temporal_phase,
    algorithm,
    phase_slice_average_for_kspace_centering,
    scale_patches,
    patch_average,
    tmp_path,
    test_dataset,
):
    """Test the run_nordic function.

    XXX: This test produces 768 sub-tests, so I need to reduce the number of
    parameters.

    This test parameterizes the input arguments to run_nordic, runs the function,
    and checks that the expected files are generated.
    """
    # Load test data
    mag_file = test_dataset / 'sub-24053_ses-1_task-bao_dir-AP_run-01_echo-1_part-mag_bold.nii.gz'
    pha_file = None
    if use_phase:
        pha_file = (
            test_dataset / 'sub-24053_ses-1_task-bao_dir-AP_run-01_echo-1_part-phase_bold.nii.gz'
        )

    pha_norf_file = None
    mag_norf_file = None
    if use_norf:
        mag_norf_file = (
            test_dataset / 'sub-24053_ses-1_task-bao_dir-AP_run-01_echo-1_part-mag_noRF.nii.gz'
        )
        if use_phase:
            pha_norf_file = (
                test_dataset
                / 'sub-24053_ses-1_task-bao_dir-AP_run-01_echo-1_part-phase_noRF.nii.gz'
            )

    # Run NORDIC
    denoise.run_nordic(
        mag_file=mag_file,
        pha_file=pha_file,
        mag_norf_file=mag_norf_file,
        pha_norf_file=pha_norf_file,
        out_dir=tmp_path,
        factor_error=1,
        full_dynamic_range=full_dynamic_range,
        temporal_phase=temporal_phase,
        algorithm=algorithm,
        patch_overlap_gfactor=None,
        kernel_size_gfactor=None,
        patch_overlap_pca=None,
        kernel_size_pca=None,
        phase_slice_average_for_kspace_centering=phase_slice_average_for_kspace_centering,
        phase_filter_width=3,
        save_gfactor_map=True,
        soft_thrs='auto',
        debug=True,
        scale_patches=scale_patches,
        patch_average=patch_average,
        llr_scale=1,
    )
    assert (tmp_path / 'magn.nii.gz').exists()
    if use_phase:
        assert (tmp_path / 'phase.nii.gz').exists()

    assert (tmp_path / 'gfactor.nii.gz').exists()


def test_run_nordic_basic(tmp_path, test_dataset):
    """Test the run_nordic function."""
    # Load test data
    mag_file = test_dataset / 'sub-24053_ses-1_task-bao_dir-AP_run-01_echo-1_part-mag_bold.nii.gz'
    pha_file = (
        test_dataset / 'sub-24053_ses-1_task-bao_dir-AP_run-01_echo-1_part-phase_bold.nii.gz'
    )
    mag_norf_file = (
        test_dataset / 'sub-24053_ses-1_task-bao_dir-AP_run-01_echo-1_part-mag_noRF.nii.gz'
    )
    pha_norf_file = (
        test_dataset / 'sub-24053_ses-1_task-bao_dir-AP_run-01_echo-1_part-phase_noRF.nii.gz'
    )

    # Run NORDIC
    denoise.run_nordic(
        mag_file=mag_file,
        pha_file=pha_file,
        mag_norf_file=mag_norf_file,
        pha_norf_file=pha_norf_file,
        out_dir=tmp_path,
    )
    assert (tmp_path / 'magn.nii.gz').exists()
    assert (tmp_path / 'phase.nii.gz').exists()
    assert (tmp_path / 'gfactor.nii.gz').exists()
