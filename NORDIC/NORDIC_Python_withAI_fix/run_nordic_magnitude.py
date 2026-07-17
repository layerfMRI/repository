#!/usr/bin/env python
"""Run NORDIC on a magnitude-only fMRI time series."""

import argparse
from pathlib import Path

from nordic.denoise import run_nordic


def _parse_kernel_size(value):
    """Parse a kernel size string like '13,13,13' into a list of ints."""
    if value is None:
        return None
    parts = [int(x.strip()) for x in value.split(',')]
    if len(parts) != 3:
        raise argparse.ArgumentTypeError(
            f'Kernel size must have exactly 3 comma-separated integers, got {value}'
        )
    return parts


def main():
    parser = argparse.ArgumentParser(
        description='Run NORDIC denoising on a magnitude-only fMRI time series.',
    )
    parser.add_argument(
        '-m', '--magnitude',
        required=True,
        type=Path,
        help='Path to the magnitude nii.gz file.',
    )
    parser.add_argument(
        '-o', '--out-dir',
        default='nordic_output',
        type=Path,
        help='Output directory. Default: nordic_output',
    )
    parser.add_argument(
        '--algorithm',
        choices=['nordic', 'mppca', 'gfactor+mppca'],
        default='nordic',
        help='Denoising algorithm. Default: nordic (full algorithm).',
    )
    parser.add_argument(
        '--kernel-size-pca',
        type=_parse_kernel_size,
        default=None,
        help=(
            'PCA kernel size as X,Y,Z (e.g. 13,13,13). '
            'Default is auto-computed from the number of volumes.'
        ),
    )
    parser.add_argument(
        '--kernel-size-gfactor',
        type=_parse_kernel_size,
        default=None,
        help=(
            'g-factor kernel size as X,Y,Z (e.g. 14,14,1). '
            'Default is 14,14,1.'
        ),
    )
    parser.add_argument(
        '--patch-overlap-pca',
        type=int,
        default=2,
        help='Patch overlap for PCA. Default: 2.',
    )
    parser.add_argument(
        '--patch-overlap-gfactor',
        type=int,
        default=2,
        help='Patch overlap for g-factor estimation. Default: 2.',
    )
    parser.add_argument(
        '--factor-error',
        type=float,
        default=1,
        help='Error factor for g-factor/noise-floor scaling. Default: 1.',
    )
    parser.add_argument(
        '--save-gfactor-map',
        action='store_true',
        help='Save the g-factor map.',
    )
    parser.add_argument(
        '--debug',
        action='store_true',
        help='Write intermediate files for debugging.',
    )
    parser.add_argument(
        '--prefix',
        default='',
        help='Prefix for output filenames. Default: none.',
    )
    parser.add_argument(
        '--n-jobs',
        type=int,
        default=1,
        help=(
            'Number of worker threads. Default: 1. '
            'Set to None or 0 to use all CPUs. See docs about BLAS oversubscription.'
        ),
    )
    args = parser.parse_args()

    # fMRI with magnitude only: phase information is unavailable, so we use
    # magnitude_only mode. This forces temporal_phase=0 and ignores any phase
    # file, matching the MATLAB ARG.magnitude_only=1 behaviour.
    run_nordic(
        mag_file=args.magnitude,
        pha_file=None,
        out_dir=args.out_dir,
        algorithm=args.algorithm,
        kernel_size_pca=args.kernel_size_pca,
        kernel_size_gfactor=args.kernel_size_gfactor,
        patch_overlap_pca=args.patch_overlap_pca,
        patch_overlap_gfactor=args.patch_overlap_gfactor,
        factor_error=args.factor_error,
        save_gfactor_map=args.save_gfactor_map,
        debug=args.debug,
        prefix=args.prefix,
        magnitude_only=True,
        n_jobs=args.n_jobs if args.n_jobs > 0 else None,
    )


if __name__ == '__main__':
    main()
