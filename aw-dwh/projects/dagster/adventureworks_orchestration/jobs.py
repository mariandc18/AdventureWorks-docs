import dagster as dg
from .constants import *

sample_job = dg.define_asset_job(
        "sample_job",
        selection=dg.AssetSelection.groups(ASSET_GROUP_LABS),
        executor_def=dg.multiprocess_executor.configured({"max_concurrent": 2}) # This limits the number of concurrent processes
    )

five_minutes_schedule = dg.ScheduleDefinition(
    job=sample_job,
    cron_schedule="*/5 * * * *",
)

jobs = [sample_job]
schedules= [five_minutes_schedule]