import dagster as dg       
from adventureworks_orchestration.constants import *
from pyspark.sql import DataFrame
from.setup import clean_bronze_layer

aw_reviews_endpoints = ["users", "stores", "reviews"]

def get_bronze_aw_reviews_api_asset(endpoint : str):
    @dg.asset(
        ins = {
            "source": dg.AssetIn(key = [ASSET_GROUP_LANDING, AW_REVIEWS_API_PREFIX, endpoint]),
        },
        io_manager_key = "s3_iceberg_io_manager",
        key = [ASSET_GROUP_BRONZE, f"reviews_{endpoint}"],
        deps = [clean_bronze_layer], 
        group_name = ASSET_GROUP_BRONZE,
    )
    def _asset(context : dg.AssetExecutionContext, source : DataFrame):
        return dg.Output(value = source)
    
    return _asset  

def bronze_aw_reviews_api_assets():
    return [get_bronze_aw_reviews_api_asset(endpoint) for endpoint in aw_reviews_endpoints]

ASSETS = bronze_aw_reviews_api_assets()