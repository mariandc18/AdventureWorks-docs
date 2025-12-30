import dagster as dg  
from adventureworks_orchestration.constants import *
from pyspark.sql import DataFrame
from .setup import clean_bronze_layer


aw_hr_files = ["department", "employeedepartmenthistory", "employeepayhistory", "shift"]


def get_bronze_aw_hr_file_asset(file : str):
    @dg.asset(
        ins = {
            "source" : dg.AssetIn(key = [ASSET_GROUP_LANDING, AW_HR_FILES_PREFIX, file.lower()])
        },
        io_manager_key = "s3_iceberg_io_manager",
        deps= [clean_bronze_layer],
        key = [ASSET_GROUP_BRONZE, f"hr_{file.lower()}"],
        group_name = ASSET_GROUP_BRONZE,
    )
    def _asset(context: dg.AssetExecutionContext, source: DataFrame):
        return dg.Output(value = source)
    
    return _asset

def get_bronze_aw_hr_assets():
    return [get_bronze_aw_hr_file_asset(file) for file in aw_hr_files]

ASSETS = get_bronze_aw_hr_assets()