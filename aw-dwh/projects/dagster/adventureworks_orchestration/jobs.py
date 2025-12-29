import dagster as dg
from .constants import *

sample_job = dg.define_asset_job(
        "sample_job",
        selection=dg.AssetSelection.groups(ASSET_GROUP_LABS),
        executor_def=dg.multiprocess_executor.configured({"max_concurrent": 2}),
    )

five_minutes_schedule = dg.ScheduleDefinition(
    job=sample_job,
    cron_schedule="*/5 * * * *"
)

landing_job =  dg.define_asset_job(
    "landing_assets_job",
    selection=dg.AssetSelection.groups(ASSET_GROUP_LANDING),
    executor_def=dg.multiprocess_executor.configured({"max_concurrent": 2}),
)

bronze_job =  dg.define_asset_job(
    "bronze_assets_job",
    selection=dg.AssetSelection.groups(ASSET_GROUP_BRONZE),
    executor_def=dg.multiprocess_executor.configured({"max_concurrent": 1}),
)

silver_job =  dg.define_asset_job(
    "silver_assets_job",
    selection=dg.AssetSelection.groups(ASSET_GROUP_SILVER),
    executor_def=dg.multiprocess_executor.configured({"max_concurrent": 2}),
)

gold_job = dg.define_asset_job(
    "gold_assets_job",
    selection=dg.AssetSelection.groups(ASSET_GROUP_GOLD),
    executor_def=dg.multiprocess_executor.configured({"max_concurrent": 2}),
)

jobs = [sample_job, landing_job, bronze_job, silver_job, gold_job]
schedules= [five_minutes_schedule]