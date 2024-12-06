from mlops_ml_models.load_data import load_data
import pandas as pd
import pytest
from unittest.mock import patch


@pytest.fixture
def mock_df() -> pd.DataFrame:
    """This creates a mock dataframe based on the data
    entered in the columns below. The data in the mock
    dataframe is the same data that we have in the csv file in the
    resources section The aim of this is to be able to test if the
    load_data.py file returns a the same dataframe as what we have here.

    Returns:
        pd.DataFrame: dataframe created from the script. Should be the same as
        in the resources.
    """
    return pd.DataFrame({
        'col1': [1, 2, 3],
        'col2': ['A', 'B', 'C'],
        'col3': [4.5, 5.5, 6.5]
    })


def test_load_data(mock_df: pd.DataFrame) -> None:
    """This compares the dataframe from the mock_df with the dataframe
    generated from the load_data.py file.

    Args:
        mock_df (pd.DataFrame): Mock data generated from mock_df function
    """
    with patch('pandas.read_csv', return_value=mock_df):
        result = load_data("mlops_ml_models/tests/resources/sample.csv")
    pd.testing.assert_frame_equal(result, mock_df)
