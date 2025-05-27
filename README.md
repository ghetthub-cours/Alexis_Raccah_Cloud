# Docker Cloud Architecture Project

This project implements a complete Docker-based cloud architecture with load balancing, monitoring, and automated backups.

## Architecture Overview

The architecture consists of:
- 3 Flask web servers running in Docker containers
- MySQL database for data persistence (optional)
- HAProxy load balancer distributing traffic
- Prometheus + Grafana for monitoring
- Automated backup/restore scripts

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 1.29+
- Linux/Unix environment (for backup scripts)

## Quick Start

1. Clone this repository:
```bash
git https://github.com/ghetthub-cours/Alexis_Raccah_Cloud.git 
cd Alexis_Raccah_Cloud# Alexis_Raccah_Cloud
