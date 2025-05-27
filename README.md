# Docker Cloud Architecture Project

[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![Docker Compose](https://img.shields.io/badge/Docker%20Compose-1.29+-blue.svg)](https://docs.docker.com/compose/)
[![Python](https://img.shields.io/badge/Python-3.9-green.svg)](https://www.python.org/)
[![HAProxy](https://img.shields.io/badge/HAProxy-2.8-red.svg)](https://www.haproxy.org/)

Une architecture cloud complète basée sur Docker avec équilibrage de charge, surveillance et sauvegarde automatisée.

## 📋 Table des matières

- [Architecture](#-architecture)
- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation rapide](#-installation-rapide)
- [Configuration détaillée](#-configuration-détaillée)
- [Utilisation](#-utilisation)
- [Surveillance](#-surveillance)
- [Sauvegarde et restauration](#-sauvegarde-et-restauration)
- [Tests](#-tests)
- [Dépannage](#-dépannage)
- [Maintenance](#-maintenance)
- [Structure du projet](#-structure-du-projet)
- [Contribution](#-contribution)

## 🏗️ Architecture

Le projet implémente une architecture de microservices containerisée avec les composants suivants :

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   Utilisateur   │───▶│   HAProxy LB     │───▶│   Web Servers       │
│                 │    │   (Port 8080)    │    │   (3 instances)     │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
                              │                           │
                              ▼                           ▼
                    ┌──────────────────┐    ┌─────────────────────┐
                    │   Stats Page     │    │   MySQL Database    │
                    │   (Port 8404)    │    │   (Port 3306)       │
                    └──────────────────┘    └─────────────────────┘
                              
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   Prometheus    │───▶│   Node Exporter  │    │      Grafana        │
│   (Port 9090)   │    │   (Port 9100)    │    │   (Port 3000)       │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
```

### Composants principaux

- **3 serveurs web Flask** : Applications Python containerisées
- **HAProxy** : Équilibreur de charge avec algorithme round-robin
- **MySQL 8.0** : Base de données relationnelle pour la persistance
- **Prometheus** : Collecte de métriques et monitoring
- **Grafana** : Visualisation des métriques et tableaux de bord
- **Node Exporter** : Métriques système
- **Scripts de backup** : Sauvegarde automatisée toutes les 5 minutes

## ✨ Fonctionnalités

### 🔄 Équilibrage de charge
- Distribution automatique du trafic entre 3 serveurs web
- Health checks automatiques avec HAProxy
- Statistiques en temps réel sur l'état des serveurs

### 📊 Surveillance complète
- Métriques système (CPU, mémoire, disque)
- Surveillance des conteneurs Docker
- Tableaux de bord Grafana personnalisés
- Alertes configurables

### 💾 Sauvegarde automatisée
- Sauvegarde des conteneurs et volumes toutes les 5 minutes
- Rétention automatique (garde les 10 dernières sauvegardes)
- Scripts de restauration complets
- Export des bases de données MySQL

### 🛠️ Outils de diagnostic
- Scripts de test automatisés
- Diagnostic complet de l'infrastructure
- Tests de charge pour l'équilibrage

## 📋 Prérequis

### Système requis
- **OS** : Linux/Unix (Ubuntu 20.04+ recommandé)
- **Docker Engine** : 20.10 ou supérieur
- **Docker Compose** : 1.29 ou supérieur
- **Mémoire** : 4GB RAM minimum, 8GB recommandé
- **Stockage** : 10GB d'espace libre minimum

### Vérification des prérequis
```bash
# Vérifier Docker
docker --version
docker-compose --version

# Vérifier les ressources
free -h
df -h
```

## 🚀 Installation rapide

### Option 1 : Démarrage automatique (Recommandé)
```bash
# Cloner le repository
git clone https://github.com/ghetthub-cours/Alexis_Raccah_Cloud.git
cd Alexis_Raccah_Cloud

# Lancer le script de démarrage complet
chmod +x scripts/start-all.sh
./scripts/start-all.sh
```

### Option 2 : Démarrage manuel
```bash
# Créer le réseau Docker
docker network create cloud-network

# Configuration simple (sans monitoring)
docker-compose up -d

# Configuration complète (avec monitoring)
docker-compose -f docker-compose-complete.yml up -d
```

### Vérification rapide
```bash
# Tester l'accès à l'application
curl http://localhost:8080

# Vérifier tous les services
./scripts/diagnose.sh
```

## ⚙️ Configuration détaillée

### Variables d'environnement

#### MySQL
```bash
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=cloudapp
MYSQL_USER=clouduser
MYSQL_PASSWORD=cloudpass
```

#### Grafana
```bash
GF_SECURITY_ADMIN_PASSWORD=admin
GF_USERS_ALLOW_SIGN_UP=false
```

### Personnalisation des serveurs web

Pour modifier les serveurs web, éditez `web-servers/app.py` :
```python
@app.route('/custom')
def custom_endpoint():
    return f"Custom endpoint from server {server_id}"
```

### Configuration HAProxy

Le fichier `haproxy/haproxy.cfg` peut être modifié pour :
- Changer l'algorithme d'équilibrage
- Ajouter des serveurs
- Configurer SSL/TLS
- Modifier les health checks

## 📖 Utilisation

### Accès aux services

| Service | URL | Identifiants |
|---------|-----|-------------|
| **Application Web** | http://localhost:8080 | - |
| **HAProxy Stats** | http://localhost:8404/haproxy-stats | - |
| **Prometheus** | http://localhost:9090 | - |
| **Grafana** | http://localhost:3000 | admin/admin |

### Commandes utiles

```bash
# Voir l'état des conteneurs
docker-compose ps

# Voir les logs
docker-compose logs -f

# Redémarrer un service
docker-compose restart web1

# Scaling (ajouter des serveurs)
docker-compose up -d --scale web1=2

# Arrêter tous les services
docker-compose down
```

## 📊 Surveillance

### Métriques disponibles

#### Prometheus
- Métriques système (CPU, mémoire, disque)
- État des conteneurs Docker
- Métriques réseau
- Métriques applicatives

#### Grafana - Tableaux de bord
1. **Docker Cloud Architecture Monitoring**
   - Utilisation CPU et mémoire
   - État des conteneurs
   - Métriques réseau

### Configuration des alertes

Exemple de règle d'alerte Prometheus :
```yaml
groups:
  - name: docker-alerts
    rules:
      - alert: HighCPUUsage
        expr: cpu_usage_percent > 80
        for: 5m
        annotations:
          summary: "CPU usage is above 80%"
```

## 💾 Sauvegarde et restauration

### Configuration automatique des sauvegardes

```bash
# Configurer les sauvegardes automatiques (toutes les 5 minutes)
chmod +x scripts/setup-cron.sh
./scripts/setup-cron.sh
```

### Sauvegarde manuelle

```bash
# Sauvegarde complète
chmod +x scripts/backup.sh
./scripts/backup.sh
```

### Contenu des sauvegardes
- **Images Docker** : Export des conteneurs
- **Volumes** : Données persistantes
- **Base de données** : Dump MySQL complet
- **Configuration** : Fichiers de configuration

### Restauration

```bash
# Lister les sauvegardes disponibles
ls -la backups/

# Restaurer une sauvegarde
chmod +x scripts/restore.sh
./scripts/restore.sh
# Suivre les instructions interactives
```

## 🧪 Tests

### Test d'équilibrage de charge

```bash
# Test simple
chmod +x scripts/test-load-balancing.sh
./scripts/test-load-balancing.sh

# Test robuste avec analyse détaillée
chmod +x scripts/test-load-balancing-v2.sh
./scripts/test-load-balancing-v2.sh
```

### Test de charge avec curl

```bash
# Test de performance
for i in {1..100}; do
  curl -s http://localhost:8080/ > /dev/null &
done
wait
```

### Tests unitaires

```bash
# Test de santé des services
curl http://localhost:8080/health

# Test de chaque serveur individuellement
docker exec web-server-1 curl localhost:5000/health
docker exec web-server-2 curl localhost:5000/health
docker exec web-server-3 curl localhost:5000/health
```

## 🔧 Dépannage

### Diagnostic automatique

```bash
# Script de diagnostic complet
chmod +x scripts/diagnose.sh
./scripts/diagnose.sh
```

### Problèmes courants

#### Les services ne démarrent pas
```bash
# Vérifier les logs
docker-compose logs

# Vérifier l'espace disque
df -h

# Vérifier les ports
netstat -tulpn | grep :8080
```

#### HAProxy ne répond pas
```bash
# Vérifier la configuration
docker exec haproxy-lb cat /usr/local/etc/haproxy/haproxy.cfg

# Tester les backends
docker exec haproxy-lb nc -zv web-server-1 5000
```

#### Base de données inaccessible
```bash
# Vérifier les logs MySQL
docker logs mysql-db

# Tester la connexion
docker exec mysql-db mysql -u clouduser -pcloudpass -e "SHOW DATABASES;"
```

### Logs et monitoring

```bash
# Logs en temps réel
docker-compose logs -f

# Logs d'un service spécifique
docker logs haproxy-lb

# Métriques système
docker stats

# Utilisation des volumes
docker system df
```

## 🛠️ Maintenance

### Mise à jour des images

```bash
# Mettre à jour toutes les images
docker-compose pull
docker-compose up -d

# Nettoyer les anciennes images
docker image prune -a
```

### Nettoyage du système

```bash
# Nettoyer les conteneurs arrêtés
docker container prune

# Nettoyer les volumes non utilisés
docker volume prune

# Nettoyage complet
docker system prune -a --volumes
```

### Rotation des logs

```bash
# Configuration dans docker-compose.yml
services:
  web1:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## 📁 Structure du projet

```
Alexis_Raccah_Cloud/
├── 📁 web-servers/           # Applications Flask
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
├── 📁 haproxy/              # Configuration HAProxy
│   ├── Dockerfile
│   └── haproxy.cfg
├── 📁 monitoring/           # Configuration surveillance
│   ├── prometheus.yml
│   ├── grafana-datasource.yml
│   └── grafana-dashboard.json
├── 📁 scripts/              # Scripts d'automatisation
│   ├── start-all.sh         # Démarrage complet
│   ├── diagnose.sh          # Diagnostic
│   ├── backup.sh            # Sauvegarde
│   ├── restore.sh           # Restauration
│   ├── setup-cron.sh        # Configuration cron
│   ├── test-load-balancing.sh
│   └── test-load-balancing-v2.sh
├── docker-compose.yml       # Configuration simple
├── docker-compose-complete.yml # Configuration complète
├── .gitignore
├── .gitattributes
└── README.md
```

## 🤝 Contribution

### Comment contribuer

1. **Fork** le projet
2. **Créer** une branche pour votre fonctionnalité
   ```bash
   git checkout -b feature/nouvelle-fonctionnalite
   ```
3. **Commiter** vos changements
   ```bash
   git commit -am 'Ajout d'une nouvelle fonctionnalité'
   ```
4. **Pousser** vers la branche
   ```bash
   git push origin feature/nouvelle-fonctionnalite
   ```
5. **Créer** une Pull Request

### Standards de code

- Utiliser des noms de variables explicites
- Commenter le code complexe
- Tester les modifications
- Suivre les conventions Docker
- Documenter les nouvelles fonctionnalités

### Tests avant contribution

```bash
# Tester la configuration complète
./scripts/start-all.sh

# Vérifier l'équilibrage de charge
./scripts/test-load-balancing-v2.sh

# Diagnostic complet
./scripts/diagnose.sh
```

## 🎯 Roadmap

### Version actuelle (v1.0)
- ✅ Architecture de base avec 3 serveurs web
- ✅ Équilibrage de charge HAProxy
- ✅ Surveillance Prometheus/Grafana
- ✅ Sauvegarde automatisée
- ✅ Scripts de diagnostic et test

---

## 🚀 Démarrage rapide - Résumé

```bash
# 1. Cloner et accéder au projet
git clone https://github.com/ghetthub-cours/Alexis_Raccah_Cloud.git
cd Alexis_Raccah_Cloud

# 2. Démarrage automatique
chmod +x scripts/start-all.sh
./scripts/start-all.sh

# 3. Accéder à l'application
# Web App: http://localhost:8080
# Grafana: http://localhost:3000 (admin/admin)
# Prometheus: http://localhost:9090

# 4. Tester l'équilibrage de charge
./scripts/test-load-balancing-v2.sh

# 5. Configurer les sauvegardes automatiques
./scripts/setup-cron.sh
```

**🎉 Votre architecture cloud Docker est maintenant opérationnelle !**