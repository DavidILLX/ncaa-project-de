# 🏀 NCAA Basketball ELT Pipeline (GCP + dbt + Kestra)

This project showcases a modern ELT (Extract, Load, Transform) pipeline processing data from the NCAA Basketball dataset. The goal is to demonstrate that an end-to-end data pipeline is fully deployed on the Google Cloud Platform (GCP), from infrastructure provisioning to analytics and visualization. Each tile in Looker helps with visualizing aggregated data about players, player events, teams, and historical tournaments. We can easily compare how the team manages in the season or see how specific players fare against each time with a scatterplot showing the events (heatmap) of their actions during the game, and also see player stats with their performance score and see if they are a valid draft prospect for the NBA.

## ⚙️ Technologies Used

- **Google Cloud Platform (GCP)** – Hosts the entire infrastructure.
- **Terraform** – Automates infrastructure provisioning (VM instance, Cloud SQL, GCS, BigQuery...).
- **Docker Compose** – Runs Kestra and PgAdmin on a VM.
- **Kestra** – Workflow orchestration (data ingestion and loading to BigQuery).
- **PostgreSQL (Cloud SQL)** – Metadata backend for Kestra.
- **Google Cloud Storage (GCS)** – Raw file storage.
- **BigQuery** – Cloud data warehouse for analytical models.
- **dbt (Data Build Tool)** – Transforms raw data into analytical models in BigQuery.
- **Looker** – Business intelligence and data visualization layer.

## 🔄 ELT Data Flow

1. **Infrastructure Provisioning**  
   Terraform creates all necessary GCP resources:
   - VM instance (Compute Engine)
   - Cloud SQL (PostgreSQL)
   - GCS bucket for raw data
   - BigQuery datasets

2. **Workflow Orchestration with Kestra**  
   - Kestra runs on a Docker container inside the VM
   - Kestra workflows:
     - Download raw data (e.g., public API or datasets)
     - Store data in GCS
     - Load data from GCS to BigQuery (raw tables)

3. **Data Transformation with dbt**  
   - DBT models transform raw data into intermediate, dimensional, and fact layers
   - Results are materialized in BigQuery

4. **Visualization with Looker**  
   - Transformed data is explored and visualized in Looker dashboards
   - Dashboards highlight player performance, team stats, game events, and trends

## 📦 Deployment Stack

Infrastructure and services are managed with:
- `Terraform` for provisioning cloud resources
- `Docker Compose` for running Kestra and PgAdmin on the VM

## 📊 Architecture Diagram

![Architecture](./img/diagram.png)

## Visuals

![Player_stats](./img/player_stats.png) 

![Player_events](./img/player_events.png)  

![Team_stats](./img/team.png)  

## 📁 Project Structure
├── terraform/ # Terraform config for GCP resources   
├── kestra/ # Kestra workflows (YAML)  
├── dbt/ # dbt project for data modeling  
├── docker/ # Deployment of Kestra and PgAdmin   
├── README.md # Project overview  


## Manual for deployment
First, let's create the SSH key for the Virtual machine  
Generate SSH key: 

https://cloud.google.com/compute/docs/connect/add-ssh-keys
https://cloud.google.com/compute/docs/connect/create-ssh-keys#windows-10-or-later

Windows:
<pre lang="markdown"> ssh-keygen -t rsa -f C:\Users\WINDOWS_USER\.ssh\KEY_FILENAME -C USERNAME</pre>  

Linux:<pre lang="markdown"> ssh-keygen -t rsa -f ~/.ssh/KEY_FILENAME -C USERNAME</pre>   

Create the project on the Google Cloud Console. The Terraform will automatically use Application Default Account (your Gmail to create the Infrastructure). It will create one service account with all the necessary permissions (not the best practice, but for the project it will do) After that, it will download the key JSON file
into the terraform folder, which will be used later.
If the GOOGLE_APPLICATION_CREDENTIALS environment variable is set, it will override ADC. 
Use any of these in the terminal:
<pre lang="markdown">Remove-Item Env:GOOGLE_APPLICATION_CREDENTIALS</pre>
<pre lang="markdown">$Env:GOOGLE_APPLICATION_CREDENTIALS</pre>

Establish ADC with gcloud auth application-default login
Check with:

gcloud auth list 

set correctly with:
<pre lang="markdown">gcloud projects add-iam-policy-binding ncaa-project-455618 \
--member="user: YOUR GMAIL HERE" \
--role="roles/serviceusage.serviceUsageConsumer"</pre>

Now that this is set up, just add the project's ID as the default connected project on GCloud:
<pre lang="markdown">`gcloud auth application-default set-quota-project PROJECT-ID`</pre>

Now, all that is needed is simple. It will take some time to set up. PostgreSQL and Dataproc usually take about 4 - 5 minutes:
<pre lang="markdown">`terraform init`</pre>
<pre lang="markdown">`terraform plan`</pre>
<pre lang="markdown">`terraform apply`</pre>

Logging into the VM with SSH key. You need the external IP from the VM on GCloud when it is running.  
Check the External IP to connect to the VM machine.  
With a command, you can access the VM or create a config file with a  structure like this
<pre lang="markdown">ssh -i ~/.ssh/gcp_ssh user@externalip</pre> 

<pre lang="markdown">Host vm-instance-1
    HostName externalIP
    User user
    IdentityFile c:/Users/user/.ssh/gpc_ssh</pre>

Then run sftp to transfer Google credentials for Google Cloud. Navigate to your directory where the JSON credentials are based on Terraform, it should be „/terraform/gcp_credentisl.json“
Running the sftp with:
<pre lang="markdown">sftp vm-instance-1
mkdir .gc
cd .gc
put gcp_credentials.json</pre>

The only thing left is to copy this repo onto the VM machine with:
<pre lang="markdown"> git clone ..... </pre>
Now it is done!

Now, before running the Docker compose, Kestra needs the IP of the SQL DB and stringified credentials added.
You can stringify the JSON with: 

<pre lang="markdown">cat gcp_credentials.json | jq '@json'</pre>
Copy the output at put it in the highlighted part of the docker-compose.yaml  

Navigate to the Docker directory and run the Docker-compose file with sudo docker build.

<pre lang="markdown">docker-compose up -d</pre>

Now the latest Kestra image should be pulled up and running with a connection to the GCP PostgreSQL. The kestra interface will be on EXTERNAL_IP:8080 port
with credentials like those in the Docker-Compose file.

**Kestra Workflows**:
  - Exporting data from public NCAA Dataset to GCS
  - Creating tables in BigQuery
  - Loading CSV files from GCS into BigQuery
  - Scheduled automation every **Monday at 3:00 AM**  

The dbt is run in the cloud dbt IDE with a connection to the BigQuery dataset. It is authenticated using the given service account key.  
Models go from staging through core up to the data marts (facts & dims).

**dbt**:
  - Transforming staging data into core and data mart models.
  - Following **Kimball’s Star Schema** methodology (facts and dimensions).  

The results are visualized through Google Looker.

**Looker**:
  - Team performance KPIs.
  - Player events (shooting, fouls, rebounds) on field maps.
  - Event distributions and player statistics (points, rebounds, steals, etc.) via pie charts and tables.





