# Grafana
## Prerequisites
1. `k3s` cluster up and running
1. `helm` installed
1. [`Prometheus`](../prometheus/README.md) deployed
1. `smtp` server/service
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
1. Create secret with admin password
    ```bash
    kubectl create secret generic grafana-admin-secret --from-literal=password="$GRAFANA_PASSWORD" -n monitoring
    ```
    * Check password
        ```bash
        kubectl get secret grafana-admin-secret -n monitoring -o jsonpath="{.data.password}" | base64 --decode
        ```
1. Set following env to configure smtp for Grafana Alerting
    ```bash
    export SMTP_USER=user
    export SMTP_PASSWORD=password
    export SMTP_HOST="email-smtp.us-east-1.amazonaws.com:587"
    export SMTP_EMAIL="test@example.com"
    ```
1. Create secret with credentials for smtp
    ```bash
    kubectl create secret generic grafana-smtp-secret --from-literal=user="$SMTP_USER" --from-literal=password="$SMTP_PASSWORD" -n monitoring --dry-run=client -o yaml | kubectl apply -f -
    ```
1. Copy [`alerting.yaml`](./alerting.yaml) file and replace [email address](./alerting.yaml#L16)
    ```bash
    sed -i "s/SMTP_SEND_EMAIL/$SMTP_EMAIL/" alerting.yaml
    ```
1. Create configmap with alerting configuration
    ```bash
    kubectl apply -f alerting.yaml -n monitoring
    ```
1. Replace smtp [host](./values.yaml#L28) and [email](./values.yaml#L26) in [`values.yaml`](./values.yaml) file
    ```bash
    sed -i "s/SMTP_SEND_EMAIL/$SMTP_EMAIL/" alerting.yaml
    sed -i "s/SMTP_SEND_HOST/$SMTP_HOST/" alerting.yaml
    ```
1. Deploy grafana
    ```bash
    helm upgrade --install grafana bitnami/grafana --version 11.3.26 -n  monitoring -f values.yaml --set admin.user="$GRAFANA_USER"
    ```
1. Grafana with default configuration [`values.yaml`](./values.yaml) file will be available on node port **30090**
## Github Actions workflow
### Description
Github actions worflow includes following steps:
1. `Setup SSH` - setting up ssh key on runner to access host with `kubectl` and `helm` configured
1. `Deploy grafana` - copy values.yaml configuration file, dashboard file, alerting configuration and grafana deployment
### Variables
1. Following repository `secrets` should be configured:
    * `TF_PRIVATE_KEY` - private ssh key to access host with `kubectl` and `helm` configured
    * `BASTION_IP` - host ip with `kubectl` and `helm` configured
    * `TF_AMI_USERNAME` - host username
    * `GRAFANA_USER` - grafana admin username
    * `GRAFANA_PASSWORD` - grafana admin password
    * `GRAFANA_SMTP_HOST` - smtp server/service address with port (e.g. "email-smtp.us-east-1.amazonaws.com:587")
    * `GRAFANA_SMTP_USER` - smtp server/service auth user
    * `GRAFANA_SMTP_PASSWORD` - smtp server/service auth password
    * `GRAFANA_SMTP_FROMADDRESS` - email address to receive notification authorized in smtp server/service
1. Following repository `variables` should be configured:
    * `HELM_GRAFANA_VERSION` - bitnami grafana helm chart version
