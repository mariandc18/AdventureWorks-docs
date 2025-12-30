import dagster as dg
from adventureworks_orchestration.constants import *
from pyspark.sql import DataFrame
from dagster_pyspark import PySparkResource
from .setup import clean_landing_zone
import requests
import pandas as pd
import os
import io


SERVER_URL = f"http://{os.getenv('AW_HR_FILES_HOST')}:{os.getenv('AW_HR_FILES_PORT')}/data"
aw_hr_files = {
    "Department": f"{SERVER_URL}/Department.csv",
    "EmployeeDepartmentHistory": f"{SERVER_URL}/EmployeeDepartmentHistory.csv",
    "EmployeePayHistory": f"{SERVER_URL}/EmployeePayHistory.csv",
    "Shift": f"{SERVER_URL}/Shift.csv",
}

def get_landing_aw_hr_file_asset(file: str, url: str):
    @dg.asset(
        io_manager_key="s3_csv_lake_io_manager",
        key=[ASSET_GROUP_LANDING, AW_HR_FILES_PREFIX, file.lower()],
        group_name=ASSET_GROUP_LANDING,
        deps = [clean_landing_zone]
    )
    def _asset(context: dg.AssetExecutionContext, spark_s3_rsc: PySparkResource) -> dg.Output[DataFrame]:
        response = requests.get(url)
        response.raise_for_status()

        pdf = pd.read_csv(io.StringIO(response.text), sep="\t") 
        df = spark_s3_rsc.spark_session.createDataFrame(pdf)

        return dg.Output(value=df)

    return _asset

def get_bronze_aw_hr_files_assets():
    return [get_landing_aw_hr_file_asset(file, url) for file, url in aw_hr_files.items()]

ASSETS = get_bronze_aw_hr_files_assets()