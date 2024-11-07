import pandas as pd


def load_data(data_location: str) -> pd.DataFrame:
    """This script takes in the location of your data (csv file),
    loads that as a dataframe and then returns the dataframe.
    Note:
        There is a section to remove all unnamed columns, you may want
        to remove that if you think it will affect your data.

    Args:
        data_location (str): This is the location of your data, usually S3

    Returns:
        pd.DataFrame: This returns a dataframe of your data.
    """
    try:
        df = pd.read_csv(data_location, storage_options={"anon": True}, low_memory=False)
        # Dropped unnamed columns. You should comment this portion out before
        # using the script if you dont have unnamed columns
        df = df.loc[:, ~df.columns.str.contains('^Unnamed')]
        return df
    except Exception as e:
        print(f"Error loading data: {e}")
