from pathlib import Path

import pytest

from utils import download_test_data, get_test_data_path


@pytest.fixture(scope='session')
def test_dataset():
    """Locate downloaded datasets."""
    data_dir = get_test_data_path()
    dataset_dir = download_test_data('test_dataset', data_dir=data_dir)
    return Path(dataset_dir)
