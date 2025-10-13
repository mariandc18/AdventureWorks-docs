import dagster as dg
from .assets import sample
from dagster_pyspark import pyspark_resource
from .resources.csv_io_manager import S3PartitionedCsvIOManager
import os
from .jobs import jobs, schedules


@dg.definitions
def defs():
    sample_assets = dg.load_assets_from_package_module(sample)

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



    return dg.Definitions(
        assets=[*sample_assets],
        jobs=jobs,
        schedules=schedules,
        resources={
            
            "spark_s3_rsc" : configured_pyspark,
            
            "s3_test_io_manager": S3PartitionedCsvIOManager(
                pyspark=configured_pyspark,
                s3_bucket="test"
            ),
            
            # register the AdventureWorks MySQL resource here
        },
    )
