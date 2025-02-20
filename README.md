# DevOps-Case: Docker Compose Environment Setup

## Overview

This project sets up a local development environment using Docker Compose. It includes PostgreSQL, Redis, and a monitoring stack with Prometheus and Grafana.

## Project Structure

```
DEVOPS-CASE/
│── monitoring/
│   ├── grafana/
│   │   ├── dashboards/      -- Pre-configured Grafana dashboards for PostgreSQL and Redis monitoring.
│   │   │   ├── PostgreSQL.json
│   │   │   ├── Redis.json
│   │   ├── provisioning/    -- Automates Grafana configuration by setting up dashboards and data sources.
│   │   │   ├── dashboards/
│   │   │   │   ├── dashboard.yml
│   │   │   ├── datasources/
│   │   │   │   ├── datasources.yml
│   │   ├── prometheus.yml   -- Configuration file for Prometheus to define monitoring targets.
│── scripts/
│   ├── installation/
│   │   ├── install_dependencies.sh  -- Script to install Docker and Docker Compose.
│   ├── test/                -- Contains scripts for verifying PostgreSQL and Redis connectivity.
│   │   ├── test_postgres.sh
│   │   ├── test_redis.sh
│── docker-compose.yml        -- Defines and orchestrates services using Docker Compose.
│── .env.example              -- Environment variables configuration. (Use this as a template and create your own .env file)
│── .gitignore
│── README.md
```

## Requirements

- [Docker & Docker Compose](https://docs.docker.com/compose/install/) installed
- [Git](https://git-scm.com/downloads) installed
- [Ubuntu-based OS](https://ubuntu.com/download) for shell script compatibility

Alternatively, you can use the automated installation script:

```sh
sudo bash scripts/installation/install_dependencies.sh
```

## Environment Variables

Use the `.env.example` file as a template to set up your environment variables. Copy it and rename it to `.env`, then define the required variables:

```sh
POSTGRES_USER=your_user
POSTGRES_PASSWORD=your_password
POSTGRES_DB=your_database
REDIS_PASSWORD=your_redis_password
```

**⚠️ Warning:** Never commit your `.env` file to the repository. Ensure it is listed in your `.gitignore` file.

## Services

| Service                 | Image                                   | Port | Purpose                                |
| ----------------------- | --------------------------------------- | ---- | -------------------------------------- |
| **PostgreSQL**          | `postgres:15`                           | 5432 | Database Server                        |
| **Redis**               | `redis:7`                               | 6379 | Cache Server                           |
| **Prometheus**          | `prom/prometheus`                       | 9090 | Metrics Collection                     |
| **Grafana**             | `grafana/grafana`                       | 3000 | Visualization Dashboard                |
| **PostgreSQL Exporter** | `prometheuscommunity/postgres-exporter` | 9187 | Exposes PostgreSQL performance metrics |
| **Redis Exporter**      | `oliver006/redis_exporter`              | 9121 | Exposes Redis instance statistics      |

## Installation

### 1. Clone the Repository

```sh
git clone <repository-url>
cd <repository-directory>
```

### 2. Setup Environment Variables

#### Copy `.env.example` to `.env`

```sh
cp .env.example .env
```

#### Open and edit the `.env` file using `vi`:

```sh
vi .env
```

- Press `i` to enter insert mode.
- Update the file with your credentials:
  
  ```sh
  POSTGRES_USER=your_user
  POSTGRES_PASSWORD=your_password
  POSTGRES_DB=your_database
  REDIS_PASSWORD=your_redis_password
  ```
  
- Press `ESC`, then type `:wq` and press `Enter` to save and exit.

### 3. Set Execution Permissions for Shell Scripts

```sh
chmod +x scripts/test/*.sh
chmod +x scripts/installation/install_dependencies.sh
```

### 4. Install Dependencies

```sh
sudo bash scripts/installation/install_dependencies.sh
```

**Note:** If you are not running as root, prefix all commands with `sudo`.

### 5. Start Services

```sh
sudo docker compose up -d
```

### 6. Verify Running Containers

```sh
sudo docker ps
```

## Testing

After starting the services, run the following scripts to verify that PostgreSQL and Redis are functioning correctly.

### Test PostgreSQL Connection

This script checks if PostgreSQL is running and accepting connections.

```sh
sudo bash scripts/test/test_postgres.sh
```

- If successful, it prints a confirmation message.
- If the connection fails, check the `.env` file and ensure the database container is running.

### Test Redis Connection

Verifies that the Redis service is up and responding to ping requests.

```sh
sudo bash scripts/test/test_redis.sh
```

- Sends a `PING` command to Redis.
- If working, it returns `PONG`.
- If not responding, check if the service is running and review `.env` file for misconfigurations.

## Monitoring Setup

### 1. Access Prometheus

- Open `http://localhost:9090`

### 2. Access Grafana

- Open `http://localhost:3000`
- Default credentials:
  - **User**: `admin`
  - **Password**: `admin`
- Pre-configured dashboards are automatically loaded from `monitoring/grafana/dashboards/`.

   ### PostgreSQL Monitoring Dashboard:
   
  The Grafana dashboard for PostgreSQL includes the following key metrics:
  - **PostgreSQL Instance Up**: Checks if the database is running (`pg_up` metric).
  - **Deadlocks per Minute**: Displays the number of deadlocks per minute (`pg_stat_database_deadlocks`).
  - **Active Connections Usage**: Shows the ratio of active connections to the maximum allowed connections.
  - **Transaction Rate (TPS)**: Measures the number of transactions per second (`pg_stat_database_xact_commit` and `pg_stat_database_xact_rollback`).
  - **Cache Hit Ratio**: Analyzes the memory cache hit ratio.
  - **Memory & Buffer Usage**: Displays shared buffer and work memory usage (`pg_settings_shared_buffers_bytes` and `pg_settings_work_mem_bytes`).
  - **Connection & Worker Limits**: Monitors the PostgreSQL connection and worker process limits (`pg_settings_max_connections`, `pg_settings_max_worker_processes`).


  ### Redis Monitoring Dashboard:
  
  The Grafana dashboard for Redis provides the following key metrics:
  - **Total Keys**: Shows the total number of stored keys (`redis_db_keys`).
  - **Clients**: Displays the number of connected clients (`redis_connected_clients`).
  - **Commands per Second**: Tracks the number of commands processed per second (`redis_commands_total`).
  - **Command Latency per Second**: Measures the latency of Redis commands.
  - **Hit & Miss Ratio**: Displays cache hit and miss rates (`redis_keyspace_hits_total`, `redis_keyspace_misses_total`).
  - **Keys Eviction & Expiration**: Monitors keys being evicted or expired (`redis_expired_keys_total`, `redis_evicted_keys_total`).

## Stopping & Cleaning Up

### Stop Containers

```sh
sudo docker compose down
```

### Remove Volumes (⚠️ Deletes all stored data!)

```sh
sudo docker compose down -v
```

## Notes

- All services start automatically with `docker compose up -d`.
- PostgreSQL and Redis have basic health checks.
- Grafana is provisioned with pre-configured dashboards.
- Ensure `.env` is correctly set up before starting services.
