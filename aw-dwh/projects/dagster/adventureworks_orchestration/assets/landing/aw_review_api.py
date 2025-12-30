import dagster as dg  
from adventureworks_orchestration.constants import *
from pyspark.sql import DataFrame
from dagster_pyspark import PySparkResource
from .setup import clean_landing_zone
import pandas as pd
import requests
import os


aw_api_endpoints = {
    "users": f"http://{os.getenv('AW_REVIEWS_API_HOST')}:{os.getenv('AW_REVIEWS_API_PORT')}/users",
    "stores": f"http://{os.getenv('AW_REVIEWS_API_HOST')}:{os.getenv('AW_REVIEWS_API_PORT')}/stores",
    "reviews": f"http://{os.getenv('AW_REVIEWS_API_HOST')}:{os.getenv('AW_REVIEWS_API_PORT')}/reviews",
}


def get_landing_aw_reviews_api_asset(endpoint : str, url : str):
    @dg.asset(
        io_manager_key = "s3_csv_lake_io_manager",
        key = [ASSET_GROUP_LANDING, AW_REVIEWS_API_PREFIX, endpoint],
        group_name = ASSET_GROUP_LANDING, 
        deps = [clean_landing_zone]
    )
    
    def _asset(context: dg.AssetExecutionContext, spark_s3_rsc: PySparkResource) -> dg.Output[DataFrame]:
        resp = requests.get(url)
        resp.raise_for_status()
        data = resp.json()   

        pdf = pd.DataFrame(data)
        df = spark_s3_rsc.spark_session.createDataFrame(pdf)

        return dg.Output(value = df)
    return _asset

def get_bronze_aw_reviews_api_assets():
    return [get_landing_aw_reviews_api_asset(endpoint, url) for endpoint, url in aw_api_endpoints.items() ]

ASSETS = get_bronze_aw_reviews_api_assets()