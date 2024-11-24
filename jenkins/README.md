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
helm repo add jenkinsci https://charts.jenkins.io
helm install jenkins jenkinsci/jenkins --version 5.7.14 -f values.yaml --create-namespace -n jenkins --set controller.admin.username=$JENKINS_USER --set controller.admin.password=$JENKINS_PASSWORD
```