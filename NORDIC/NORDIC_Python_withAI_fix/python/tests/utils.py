import os
import tarfile
from gzip import GzipFile
from io import BytesIO

import requests


def download_test_data(dset, data_dir=None):
    """Download test data."""
    URLS = {
        'test_dataset': (
            'https://upenn.box.com/shared/static/rcr7c6wuaxaooia4tbqa3m50exgkeda3.tar.gz'
        ),
    }
    if dset == '*':
        for k in URLS:
            download_test_data(k, data_dir=data_dir)

        return

    if dset not in URLS:
        raise ValueError(f'dset ({dset}) must be one of: {", ".join(URLS.keys())}')

    if not data_dir:
        data_dir = os.path.join(os.path.dirname(get_test_data_path()), 'test_data')

    out_dir = os.path.join(data_dir, dset)

    if os.path.isdir(out_dir):
        print(
            f'Dataset {dset} already exists. '
            'If you need to re-download the data, please delete the folder.'
        )

        return out_dir
    else:
        print(f'Downloading {dset} to {out_dir}')

    os.makedirs(data_dir, exist_ok=True)
    with requests.get(URLS[dset], stream=True, timeout=10) as req:
        with tarfile.open(fileobj=GzipFile(fileobj=BytesIO(req.content))) as t:
            t.extractall(data_dir)  # noqa: S202

    return out_dir


def get_test_data_path():
    """Return the path to test datasets, terminated with separator.

    Test-related data are kept in tests folder in "data".
    Based on function by Yaroslav Halchenko used in Neurosynth Python package.
    """
    return os.path.abspath(os.path.join(os.path.dirname(__file__), 'data') + os.path.sep)
