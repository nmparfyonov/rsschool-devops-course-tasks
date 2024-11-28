# Prometheus
## Prerequisites
1. `k3s` cluster up and running
1. `helm installed`
## Deploy Jenkins
### Manual
1. Add bitnami helm chart repo
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```
1. Create `monitoring` namespace
```bash
kubectl create namespace monitoring
```
1. Copy [`values.yaml`](./values.yaml) file and edit if needed
1. Deploy prometheus
```bash
helm upgrade --install prometheus bitnami/kube-prometheus --version 10.1.0 -n  monitoring -f values.yaml
```
1. Prometheus with default configuration [`values.yaml`](./values.yaml) file will be available on node port **30080**
## Github Actions workflow
### Description
Github actions worflow includes following steps:
1. `Setup SSH` - setting up ssh key on runner to access host with `kubectl` and `helm` configured
1. `Deploy prometheus` - copy values.yaml configuration file and deploy prometheus server with alertmanager and exporters
### Variables
1. Following repository `secrets` should be configured:
    * `TF_PRIVATE_KEY` - private ssh key to access host with `kubectl` and `helm` configured
    * `BASTION_IP` - host ip with `kubectl` and `helm` configured
    * `TF_AMI_USERNAME` - host username
1. Following repository `variables` should be configured:
    * `HELM_PROMETHEUS_VERSION` - bitnami prometheus helm chart version
