import importlib


def finalize_and_save_model(algorithm_choice: str, bestModel: str,
                            model_name: str):
    """
    Finalizes the best model obtained from PyCaret and saves it locally.

    This function finalizes the model by training it on the entire dataset and
    then saves it to a file. It utilizes dynamic import to load the specific
    PyCaret submodule based on the algorithm choice.

    Args:
        algorithm_choice (str): The choice of algorithm from PyCaret to be
        used (e.g., 'regression', 'classification').
        bestModel: The best model obtained from the PyCaret training process.
        model_name (str): The name under which the model will be saved.

    Returns:
        The finalized model object.
    """
    pycaret = importlib.import_module(f"pycaret.{algorithm_choice}")
    final_model = pycaret.finalize_model(bestModel)
    pycaret.save_model(final_model, model_name)
    return final_model
