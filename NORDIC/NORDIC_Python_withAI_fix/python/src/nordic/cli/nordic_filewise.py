"""Apply NORDIC to individual files."""

import os
from argparse import ArgumentParser, RawTextHelpFormatter
from pathlib import Path

from nordic import denoise


def get_parser():
    """Build parser object."""
    parser = ArgumentParser(description=__doc__, formatter_class=RawTextHelpFormatter)

    parser.add_argument(
        '-m',
        '--magnitude',
        dest='mag_file',
        action='store',
        required=True,
        type=Path,
        help='magnitude file',
    )
    parser.add_argument(
        '-p',
        '--phase',
        dest='pha_file',
        action='store',
        type=Path,
        help='phase file',
    )
    parser.add_argument(
        '--mag-norf',
        dest='mag_norf_file',
        action='store',
        type=Path,
        help='magnitude noRF file',
    )
    parser.add_argument(
        '--phase-norf',
        dest='pha_norf_file',
        action='store',
        type=Path,
        help='phase noRF file',
    )
    parser.add_argument(
        '--out-dir',
        action='store',
        required=True,
        type=Path,
        help='output directory',
        default=os.getcwd(),
    )
    parser.add_argument(
        '--factor-error',
        action='store',
        type=float,
        help=(
            'Error in g-factor estimation. >1 uses a higher noisefloor. '
            '<1 uses a lower noisefloor. Default is 1. '
            'Rather than modifying the gfactor map, this changes nvr_threshold.'
        ),
        default=1,
    )
    parser.add_argument(
        '--full-dynamic-range',
        action='store_true',
        help='Whether to use the full dynamic range. Default is False.',
        default=False,
    )
    parser.add_argument(
        '--temporal-phase',
        action='store',
        type=int,
        help='Temporal phase. Default is 1.',
        default=1,
    )
    parser.add_argument(
        '--algorithm',
        action='store',
        choices=['nordic', 'mppca', 'gfactor+mppca'],
        help='Algorithm to use. Default is "nordic".',
        default='nordic',
    )
    parser.add_argument(
        '--patch-overlap-gfactor',
        action='store',
        type=int,
        help='Patch overlap for g-factor estimation. Default is 2.',
        default=2,
    )
    parser.add_argument(
        '--kernel-size-gfactor',
        action='store',
        type=int,
        help='Kernel size for g-factor estimation. Default is None.',
        default=None,
    )
    parser.add_argument(
        '--patch-overlap-pca',
        action='store',
        type=int,
        help='Patch overlap for PCA. Default is 2.',
        default=2,
    )
    parser.add_argument(
        '--kernel-size-pca',
        action='store',
        type=int,
        help='Kernel size for PCA. Default is None.',
        default=None,
    )
    parser.add_argument(
        '--phase-slice-average-for-kspace-centering',
        action='store_true',
        help='Whether to average the phase slices for k-space centering. Default is False.',
        default=False,
    )
    parser.add_argument(
        '--phase-filter-width',
        action='store',
        type=int,
        help='Width of the phase filter. Default is 3.',
        default=3,
    )
    parser.add_argument(
        '--save-gfactor-map',
        action='store_true',
        help='Whether to save the g-factor map. Default is False.',
        default=False,
    )
    parser.add_argument(
        '--debug',
        action='store_true',
        help='If True, write out intermediate files for debugging. Default is False.',
        default=False,
    )
    parser.add_argument(
        '--scale-patches',
        action='store_true',
        help=(
            'Whether to scale the contributions of patches according to the variance '
            'removed by the patch or not. Default is False.'
        ),
        default=False,
    )
    parser.add_argument(
        '--patch-average',
        action='store_true',
        help='Hardcoded as False in the MATLAB code (ARG.patch_average = 0).',
        default=False,
    )
    parser.add_argument(
        '--llr-scale',
        action='store',
        type=float,
        help=(
            'Local low-rank scaling factor for the denoising step. Default is 1. '
            'Hardcoded as 0 for g-factor estimation and 1 for denoising in the '
            'MATLAB code (ARG.llr_scale).'
        ),
        default=1,
    )
    parser.add_argument(
        '--prefix',
        action='store',
        type=str,
        help=(
            'String prepended to every output filename. Default is "" (no prefix). '
            'Pass e.g. "sub-01_" to write sub-01_magn.nii.gz, sub-01_phase.nii.gz, '
            'etc. The user supplies any separator they want — the prefix is '
            'concatenated literally onto the existing names.'
        ),
        default='',
    )
    return parser


def main(args=None):
    """Run NORDIC on a single run."""
    opts = get_parser().parse_args(args)
    kwargs = vars(opts)

    denoise.run_nordic(**kwargs)


if __name__ == '__main__':
    main()
