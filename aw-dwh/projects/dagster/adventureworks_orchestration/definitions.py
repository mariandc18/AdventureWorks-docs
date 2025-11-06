import dagster as dg
from .assets import sample
from .assets import landing
from .assets import bronze
from .assets import silver
from dagster_pyspark import pyspark_resource
from .resources.mysql_resource import PySparkMySQLResource
from .resources.csv_io_manager import S3PartitionedCsvIOManager
from .resources.iceberg_io_manager import IcebergIOManager
from dagster_aws.s3 import S3Resource
from dagster_dbt import DbtCliResource
from .project import dbt_silver_project
import os
from .jobs import jobs, schedules


@dg.definitions
def defs():
    sample_assets = dg.load_assets_from_package_module(sample)
    landing_assets = dg.load_assets_from_package_module(landing)
    bronze_assets = dg.load_assets_from_package_module(bronze)
    silver_assets = dg.load_assets_from_package_module(silver)

    configured_pyspark = pyspark_resource.configured(
        {
            "spark_conf": {
                "spark.hadoop.fs.s3.impl": "org.apache.hadoop.fs.s3native.NativeS3FileSystem",
                "fs.s3a.access.key": os.getenv("AWS_ACCESS_KEY_ID"),
                "fs.s3a.secret.key": os.getenv("AWS_SECRET_ACCESS_KEY"),
                "fs.s3a.endpoint": os.getenv("AWS_ENDPOINT"),
                "fs.s3a.region": os.getenv("AWS_REGION")
            }
        }
    )



    dbt_silver_resource = DbtCliResource(
        project_dir=dbt_silver_project,
        target="dev",
    )



    return dg.Definitions(
        assets=[*sample_assets, *landing_assets, *bronze_assets, *silver_assets],
        jobs=jobs,
        schedules=schedules,
        resources={
            
            "spark_s3_rsc" : configured_pyspark,
            
            "s3_test_io_manager": S3PartitionedCsvIOManager(
                pyspark=configured_pyspark,
                s3_bucket="test"
            ),

            "s3_csv_lake_io_manager": S3PartitionedCsvIOManager(
                pyspark=configured_pyspark,
                s3_bucket="lake"
            ),  


            "s3_iceberg_io_manager": IcebergIOManager(
                pyspark=configured_pyspark,
                catalog="iceberg"
            ),

            "s3_rsc": S3Resource(
                aws_access_key_id=dg.EnvVar("AWS_ACCESS_KEY_ID"),
                aws_secret_access_key=dg.EnvVar("AWS_SECRET_ACCESS_KEY"),
                endpoint_url=dg.EnvVar("AWS_ENDPOINT"),
                region_name=dg.EnvVar("AWS_REGION")
            ),


            "aw_core_mysql_rsc": PySparkMySQLResource(
                pyspark=configured_pyspark,
                host=dg.EnvVar("AW_CORE_HOST"),
                port=dg.EnvVar("AW_CORE_PORT"),
                database=dg.EnvVar("AW_CORE_DATABASE"),
                user=dg.EnvVar("AW_CORE_USER"),
                password=dg.EnvVar("AW_CORE_PASSWORD")
            ),

             "dbt_silver_rsc": dbt_silver_resource
            
        },
    )
