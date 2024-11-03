## Deploy Longhorn
```bash
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.0/deploy/longhorn.yaml
```
## Deploy Jenkins
1. Set following env to create credentials for Jenkins
```bash
export JENKINS_USER=username
export JENKINS_PASSWORD=password
```
1. Install Jenkins helm chart
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install jenkins bitnami/jenkins --version 13.4.26 -f values.yaml --create-namespace -n jenkins --set jenkinsUser=$JENKINS_USER --set jenkinsPassword=$JENKINS_PASSWORD
```