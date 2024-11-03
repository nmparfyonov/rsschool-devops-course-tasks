## Deploy longhorn
```bash
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.0/deploy/longhorn.yaml
```
## Deploy jenkins
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install jenkins bitnami/jenkins --version 13.4.26 -f values.yaml --create-namespace -n jenkins --set jenkinsUser=$JENKINS_USER --set jenkinsPassword=$JENKINS_PASSWORD
```