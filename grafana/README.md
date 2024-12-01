# Grafana
## Prerequisites
1. `k3s` cluster up and running
1. `helm` installed
1. [`Prometheus`](../prometheus/README.md) deployed
## Deploy grafana
### Manual
1. Add bitnami helm chart repo
    ```bash
    helm repo add bitnami https://charts.bitnami.com/bitnami
    ```
1. Create `monitoring` namespace
    ```bash
    kubectl create namespace monitoring
    ```
1. Copy [`kubernetes_dashboard.json`](./kubernetes_dashboard.json)
1. Create configmap with kubernetes dashboard
    ```bash
    kubectl create configmap grafana-kubernetes-dashboard -n monitoring --from-file=kubernetes_dashboard.json
    ```
1. Copy [`values.yaml`](./values.yaml) file and edit [prometheus url](./values.yaml#L13)
1. Set following env to create credentials for Grafana
    ```bash
    export GRAFANA_USER=grafana
    export GRAFANA_PASSWORD=grafana
    ```
1. Deploy grafana
    ```bash
    helm upgrade --install grafana bitnami/grafana --version 11.3.26 -n  monitoring -f values.yaml --set admin.user="$GRAFANA_USER" --set admin.    password="$GRAFANA_PASSWORD"
    ```
1. Grafana with default configuration [`values.yaml`](./values.yaml) file will be available on node port **30090**
## Github Actions workflow
### Description
Github actions worflow includes following steps:
1. `Setup SSH` - setting up ssh key on runner to access host with `kubectl` and `helm` configured
1. `Deploy grafana` - copy values.yaml configuration file, dashboard file and grafana deployment
### Variables
1. Following repository `secrets` should be configured:
    * `TF_PRIVATE_KEY` - private ssh key to access host with `kubectl` and `helm` configured
    * `BASTION_IP` - host ip with `kubectl` and `helm` configured
    * `TF_AMI_USERNAME` - host username
    * `GRAFANA_USER` - grafana admin username
    * `GRAFANA_PASSWORD` - grafana admin password
1. Following repository `variables` should be configured:
    * `HELM_GRAFANA_VERSION` - bitnami grafana helm chart version
