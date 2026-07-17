"""Apply NORDIC to a BIDS dataset."""

import os
import shutil
from argparse import ArgumentParser, RawTextHelpFormatter
from functools import partial
from pathlib import Path

from bids.layout import BIDSLayout

from nordic import denoise
from nordic.data import load as load_data


def get_parser():
    """Build parser object."""

    def _path_exists(path, parser):
        """Ensure a given path exists."""
        if path is None or not Path(path).exists():
            raise parser.error(f'Path does not exist: <{path}>.')
        return Path(path).absolute()

    def _process_value(value):
        import bids

        if value is None:
            return bids.layout.Query.NONE
        elif value == '*':
            return bids.layout.Query.ANY
        else:
            return value

    def _filter_pybids_none_any(dct):
        d = {}
        for k, v in dct.items():
            if isinstance(v, list):
                d[k] = [_process_value(val) for val in v]
            else:
                d[k] = _process_value(v)
        return d

    def _bids_filter(value, parser):
        from json import JSONDecodeError, loads

        if value:
            if Path(value).exists():
                try:
                    return loads(Path(value).read_text(), object_hook=_filter_pybids_none_any)
                except JSONDecodeError as e:
                    raise parser.error(f'JSON syntax error in: <{value}>.') from e
            else:
                raise parser.error(f'Path does not exist: <{value}>.')

    parser = ArgumentParser(description=__doc__, formatter_class=RawTextHelpFormatter)

    PathExists = partial(_path_exists, parser=parser)
    BIDSFilter = partial(_bids_filter, parser=parser)

    parser.add_argument(
        'bids_dir',
        action='store',
        type=PathExists,
        help=(
            'The root folder of a BIDS valid dataset (sub-XXXXX folders should '
            'be found at the top level in this folder).'
        ),
    )
    parser.add_argument(
        'output_dir',
        action='store',
        type=Path,
        help=(
            'The output path for the NORDIC-denoised data. '
            'If the output path is the same as the BIDS directory, '
            'then pseudo-raw denoising is performed. '
            'In pseudo-raw denoising, the raw data will be renamed with `rec-nonordic` '
            'and the denoised data will be written out with the original names.'
        ),
    )
    parser.add_argument(
        'analysis_level',
        choices=['participant'],
        help=(
            'Processing stage to be run, only "participant" in the case of '
            'NORDIC (see BIDS-Apps specification).'
        ),
    )

    parser.add_argument(
        '-w',
        '--work-dir',
        action='store',
        type=Path,
        default=Path('work').absolute(),
        help='path where intermediate results should be stored',
    )
    parser.add_argument(
        '--derivatives',
        action='store',
        type=Path,
        help=(
            'path to the derivatives directory. '
            'In pseudo-raw denoising, extra NORDIC derivatives will be written here.'
        ),
        default=None,
    )

    g_bids = parser.add_argument_group('Options for filtering BIDS queries')
    g_bids.add_argument(
        '--participant-label',
        '--participant_label',
        action='store',
        nargs='+',
        type=lambda label: label.removeprefix('sub-'),
        help=(
            'A space delimited list of participant identifiers or a single identifier '
            '(the sub- prefix can be removed)'
        ),
    )
    g_bids.add_argument(
        '-s',
        '--session-id',
        action='store',
        nargs='+',
        type=lambda label: label.removeprefix('ses-'),
        help=(
            'A space delimited list of session identifiers or a single identifier '
            '(the ses- prefix can be removed)'
        ),
    )
    g_bids.add_argument(
        '-r',
        '--run-id',
        action='store',
        nargs='+',
        type=lambda label: label.removeprefix('run-'),
        help=(
            'A space delimited list of run identifiers or a single identifier '
            '(the run- prefix can be removed)'
        ),
    )
    g_bids.add_argument(
        '-t',
        '--task-id',
        action='store',
        nargs='+',
        type=lambda label: label.removeprefix('task-'),
        help=(
            'A space delimited list of task identifiers or a single identifier '
            '(the task- prefix can be removed)'
        ),
    )
    g_bids.add_argument(
        '--bids-filter-file',
        dest='bids_filters',
        action='store',
        type=BIDSFilter,
        metavar='FILE',
        help=(
            'A JSON file describing custom BIDS input filters using PyBIDS. '
            'Supported fields: "bold".'
        ),
    )
    g_bids.add_argument(
        '--ignore',
        required=False,
        action='store',
        nargs='+',
        default=[],
        choices=['phase', 'norf'],
        help=(
            'ignore selected aspects of the input dataset to disable corresponding '
            'parts of the workflow (a space delimited list)'
        ),
    )

    g_nordic = parser.add_argument_group('Options for NORDIC')
    g_nordic.add_argument(
        '--factor-error',
        action='store',
        type=float,
        help=(
            'Error in g-factor estimation. >1 uses a higher noisefloor. '
            '<1 uses a lower noisefloor. Default is 1. '
            'Rather than modifying the gfactor map, this changes nvr_threshold.'
        ),
        default=1,
        dest='factor_error',
    )
    g_nordic.add_argument(
        '--full-dynamic-range',
        action='store_true',
        help='Whether to use the full dynamic range. Default is False.',
        default=False,
        dest='full_dynamic_range',
    )
    g_nordic.add_argument(
        '--temporal-phase',
        action='store',
        type=int,
        help='Temporal phase. Default is 1.',
        default=1,
        dest='temporal_phase',
    )
    g_nordic.add_argument(
        '--algorithm',
        action='store',
        choices=['nordic', 'mppca', 'gfactor+mppca'],
        help='Algorithm to use. Default is "nordic".',
        default='nordic',
        dest='algorithm',
    )
    g_nordic.add_argument(
        '--patch-overlap-gfactor',
        action='store',
        type=int,
        help='Patch overlap for g-factor estimation. Default is 2.',
        default=2,
        dest='patch_overlap_gfactor',
    )
    g_nordic.add_argument(
        '--kernel-size-gfactor',
        action='store',
        type=int,
        help='Kernel size for g-factor estimation. Default is None.',
        default=None,
        dest='kernel_size_gfactor',
    )
    g_nordic.add_argument(
        '--patch-overlap-pca',
        action='store',
        type=int,
        help='Patch overlap for PCA. Default is 2.',
        default=2,
        dest='patch_overlap_pca',
    )
    g_nordic.add_argument(
        '--kernel-size-pca',
        action='store',
        type=int,
        help='Kernel size for PCA. Default is None.',
        default=None,
        dest='kernel_size_pca',
    )
    g_nordic.add_argument(
        '--phase-slice-average-for-kspace-centering',
        action='store_true',
        help='Whether to average the phase slices for k-space centering. Default is False.',
        default=False,
        dest='phase_slice_average_for_kspace_centering',
    )
    g_nordic.add_argument(
        '--phase-filter-width',
        action='store',
        type=int,
        help='Width of the phase filter. Default is 3.',
        default=3,
        dest='phase_filter_width',
    )
    g_nordic.add_argument(
        '--save-gfactor-map',
        action='store_true',
        help='Whether to save the g-factor map. Default is False.',
        default=False,
        dest='save_gfactor_map',
    )
    g_nordic.add_argument(
        '--debug',
        action='store_true',
        help='If True, write out intermediate files for debugging. Default is False.',
        default=False,
        dest='debug',
    )
    g_nordic.add_argument(
        '--scale-patches',
        action='store_true',
        help=(
            'Whether to scale the contributions of patches according to the variance '
            'removed by the patch or not. Default is False.'
        ),
        default=False,
        dest='scale_patches',
    )
    g_nordic.add_argument(
        '--patch-average',
        action='store_true',
        help='Hardcoded as False in the MATLAB code (ARG.patch_average = 0).',
        default=False,
        dest='patch_average',
    )
    g_nordic.add_argument(
        '--llr-scale',
        action='store',
        type=float,
        help=(
            'Local low-rank scaling factor for the denoising step. Default is 1. '
            'Hardcoded as 0 for g-factor estimation and 1 for denoising in the '
            'MATLAB code (ARG.llr_scale).'
        ),
        default=1,
        dest='llr_scale',
    )
    return parser


def main(args=None):
    """Run NORDIC on a single run."""
    opts = get_parser().parse_args(args)
    kwargs = vars(opts)

    # Split parameters into BIDS, NORDIC, and other.
    nordic_params = [
        'factor_error',
        'full_dynamic_range',
        'temporal_phase',
        'algorithm',
        'patch_overlap_gfactor',
        'kernel_size_gfactor',
        'patch_overlap_pca',
        'kernel_size_pca',
        'phase_slice_average_for_kspace_centering',
        'phase_filter_width',
        'save_gfactor_map',
        'debug',
        'scale_patches',
        'patch_average',
        'llr_scale',
    ]
    nordic_kwargs = {param: kwargs[param] for param in nordic_params}

    output_dir = str(kwargs['output_dir'].resolve())
    bids_dir = str(kwargs['bids_dir'].resolve())
    work_dir = str(kwargs['work_dir'].resolve())
    os.makedirs(work_dir, exist_ok=True)

    bids_filters = kwargs['bids_filters']
    bids_filters = bids_filters if bids_filters else {}
    if kwargs['participant_label']:
        bids_filters['subject'] = kwargs['participant_label']
    if kwargs['session_id']:
        bids_filters['session'] = kwargs['session_id']
    if kwargs['run_id']:
        bids_filters['run'] = kwargs['run_id']
    if kwargs['task_id']:
        bids_filters['task'] = kwargs['task_id']

    if output_dir == bids_dir:
        print('Performing pseudo-raw denoising.')
        if kwargs['derivatives']:
            print(f'Writing out useful NORDIC derivatives to {kwargs["derivatives"]}')
            os.makedirs(kwargs['derivatives'], exist_ok=True)
    else:
        print('Writing out denoised data to a separate directory.')
        os.makedirs(output_dir, exist_ok=True)
        if kwargs['derivatives']:
            print('"--derivatives" specified, but will have no effect.')
            kwargs['derivatives'] = output_dir

    # Collect magnitude BOLD files.
    layout = BIDSLayout(bids_dir, validate=False, config=['bids', str(load_data('config.json'))])
    bold_files = layout.get(
        return_type='file',
        part='mag',
        suffix='bold',
        extension='nii.gz',
        **bids_filters,
    )
    bold_files = [file for file in bold_files if 'nonordic' not in file]
    print(f'Found {len(bold_files)} magnitude BOLD files.')

    # Loop over magnitude BOLD files.
    for bold_file in bold_files:
        entities = layout.get_file(bold_file).get_entities()
        nonordic_entities = entities.copy()

        rec_ent = nonordic_entities.get('reconstruction', '')
        rec_ent += 'nonordic'

        nonordic_entities['reconstruction'] = rec_ent
        if layout.get(**nonordic_entities):
            print('Non-NORDIC file already exists. Skipping.')
            continue

        # Collect phase and noRF files, when available and not ignored.
        phase_entities = {**entities, **{'part': 'phase'}}
        phase_file = layout.get(return_type='file', **phase_entities)
        if phase_file and 'phase' not in kwargs['ignore']:
            phase_file = phase_file[0]
        else:
            phase_file = None

        mag_norf_entities = {**entities, **{'suffix': 'noRF'}}
        mag_norf_file = layout.get(return_type='file', **mag_norf_entities)
        if mag_norf_file and 'norf' not in kwargs['ignore']:
            mag_norf_file = mag_norf_file[0]
        else:
            mag_norf_file = None

        phase_norf_entities = {**phase_entities, **{'suffix': 'noRF'}}
        phase_norf_file = layout.get(return_type='file', **phase_norf_entities)
        if phase_norf_file and 'norf' not in kwargs['ignore'] and 'phase' not in kwargs['ignore']:
            phase_norf_file = phase_norf_file[0]
        else:
            phase_norf_file = None

        # Run NORDIC in working directory.
        work_stem = os.path.basename(bold_file).split('.')[0]
        run_work_dir = os.path.join(work_dir, work_stem)
        os.makedirs(run_work_dir, exist_ok=True)
        denoise.run_nordic(
            out_dir=run_work_dir,
            mag_file=bold_file,
            pha_file=phase_file,
            mag_norf_file=mag_norf_file,
            pha_norf_file=phase_norf_file,
            **nordic_kwargs,
        )

        # Rename original files to include rec-nonordic.
        nonordic_bold_file = layout.build_path(nonordic_entities)
        print(f'Renaming {bold_file} to {nonordic_bold_file}')
        os.rename(bold_file, nonordic_bold_file)
        if phase_file:
            nonordic_phase_file = layout.build_path(
                {**phase_entities, **{'reconstruction': rec_ent}},
            )
            print(f'Renaming {phase_file} to {nonordic_phase_file}')
            os.rename(phase_file, nonordic_phase_file)

        if mag_norf_file:
            nonordic_mag_norf_file = layout.build_path(
                {**mag_norf_entities, **{'reconstruction': rec_ent}},
            )
            print(f'Renaming {mag_norf_file} to {nonordic_mag_norf_file}')
            os.rename(mag_norf_file, nonordic_mag_norf_file)

        if phase_norf_file:
            nonordic_phase_norf_file = layout.build_path(
                {**phase_norf_entities, **{'reconstruction': rec_ent}},
            )
            print(f'Renaming {phase_norf_file} to {nonordic_phase_norf_file}')
            os.rename(phase_norf_file, nonordic_phase_norf_file)

        # Copy denoised data to output directory with original names.
        denoised_magnitude_file = os.path.join(run_work_dir, 'magn.nii.gz')
        print(f'Copying {denoised_magnitude_file} to {output_dir}')
        shutil.copyfile(denoised_magnitude_file, bold_file.replace(bids_dir, output_dir))
        if phase_file:
            denoised_phase_file = os.path.join(run_work_dir, 'phase.nii.gz')
            print(f'Copying {denoised_phase_file} to {output_dir}')
            shutil.copyfile(denoised_phase_file, phase_file.replace(bids_dir, output_dir))

        if kwargs['derivatives']:
            print(f'Copying useful NORDIC derivatives to {kwargs["derivatives"]}')
            bids_sub_dir = os.path.relpath(os.path.dirname(bold_file), bids_dir)
            derivatives_sub_dir = os.path.join(kwargs['derivatives'], bids_sub_dir)
            os.makedirs(derivatives_sub_dir, exist_ok=True)
            if '_part-' in bold_file:
                split_ent = '_part-'
            else:
                split_ent = '_bold'

            derivatives_stem = os.path.basename(bold_file).split(split_ent)[0]
            derivatives_sub_dir = Path(derivatives_sub_dir)

            gfactor_file = os.path.join(run_work_dir, 'gfactor.nii.gz')
            if os.path.exists(gfactor_file):
                shutil.copyfile(
                    gfactor_file,
                    derivatives_sub_dir / f'{derivatives_stem}_desc-gfactor_statmap.nii.gz',
                )
            noise_file = os.path.join(run_work_dir, 'noise.nii.gz')
            if os.path.exists(noise_file):
                shutil.copyfile(
                    noise_file,
                    derivatives_sub_dir / f'{derivatives_stem}_desc-noise_statmap.nii.gz',
                )
            energy_removed_file = os.path.join(run_work_dir, 'energy_removed.nii.gz')
            if os.path.exists(energy_removed_file):
                shutil.copyfile(
                    energy_removed_file,
                    derivatives_sub_dir / f'{derivatives_stem}_desc-energyRemoved_statmap.nii.gz',
                )
            snr_weight_file = os.path.join(run_work_dir, 'snr_weight.nii.gz')
            if os.path.exists(snr_weight_file):
                shutil.copyfile(
                    snr_weight_file,
                    derivatives_sub_dir / f'{derivatives_stem}_desc-snrWeight_statmap.nii.gz',
                )
            n_components_removed_file = os.path.join(run_work_dir, 'n_components_removed.nii.gz')
            if os.path.exists(n_components_removed_file):
                shutil.copyfile(
                    n_components_removed_file,
                    derivatives_sub_dir / f'{derivatives_stem}_desc-nComponentsRemoved_statmap.nii.gz',
                )
            n_patch_runs_file = os.path.join(run_work_dir, 'n_patch_runs.nii.gz')
            if os.path.exists(n_patch_runs_file):
                shutil.copyfile(
                    n_patch_runs_file,
                    derivatives_sub_dir / f'{derivatives_stem}_desc-nPatchRuns_statmap.nii.gz',
                )


if __name__ == '__main__':
    main()
