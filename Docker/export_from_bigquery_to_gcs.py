from google.cloud import bigquery
import google.auth
from google.cloud import storage
from google.auth.transport.requests import Request
import os
import math
import io
import json

# Get google credentials downloaded by sftp as default

credentials = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
service_account_info = json.loads(credentials)
credentials, project = google.auth.load_credentials_from_dict(service_account_info)

# TO DO Add your project name here 
client = bigquery.Client(credentials=credentials, project="ncaa-project-455709")
storage_client = storage.Client()


# Should be - bigquery-public-data, ncaa_basketball
project_id = "bigquery-public-data"
dataset_id = "ncaa_basketball"

dataset_ref = client.dataset(dataset_id, project=project_id)
tables = list(client.list_tables(dataset_ref))

# Should be - ncaa-bucket-dump
bucket_name = "ncaa-bucket-dump"
bucket = storage_client.get_bucket(bucket_name)

# Runnning Query for each table and saving their parts in csv bucket
for table in tables:

    table_name = tables[table].table_id

    query_job = client.query(f"""
                             SELECT *
                             FROM `{project_id}.{dataset_id}.{table_name}`
                             """)
    df = query_job.to_dataframe()

    chunk_size = 2000000
    num_chunks = math.ceil(len(df) / chunk_size)

    for i in range(num_chunks):
        df_chunk = df.iloc[i*chunk_size:(i+1)*chunk_size]

        csv_buffer = io.BytesIO()

        # Write to Buffer
        compression_opts = dict(method="zip", archive_name=f"{table_name}_part_{i+1}.csv")
        df_chunk.to_csv(csv_buffer, index=True, compression=compression_opts)

        # Go to the start of thebuffer and load to bucket
        csv_buffer.seek(0)  
        blob = bucket.blob(f"{table_name}/{table_name}_part_{i+1}.zip")
        blob.upload_from_file(csv_buffer)


