#!/usr/bin/env bash
# 운영환경 구성시
set -euo pipefail


# --- CONFIG (edit as needed) ---
GITEA_NS=dev-tools
JENKINS_NS=dev-tools
ARGOCD_NS=argocd
GITEA_ADMIN_USER=admin
GITEA_ADMIN_PASS=admin
JENKINS_ADMIN_USER=admin
JENKINS_ADMIN_PASS=admin


# Registry placeholder used in Jenkinsfile
# local docker image만을 대상으로 할 것이므로 docker image registry는 정의 안함
#REGISTRY=registry.example.com

# --- install gitea ---
helm repo add gitea-charts https://dl.gitea.io/charts/
helm repo update
kubectl create ns ${GITEA_NS} || true
helm upgrade --install gitea gitea-charts/gitea \
--namespace ${GITEA_NS} \
--set service.http.type=ClusterIP \
--set persistence.enabled=true \ 
--set persistence.size=5Gi \
--set gitea.admin.username=${GITEA_ADMIN_USER} \
--set gitea.admin.password=${GITEA_ADMIN_PASS} \
--set gitea.admin.email=admin@example.local


# --- install jenkins ---
helm repo add jenkins https://charts.jenkins.io
helm repo update
kubectl create ns ${JENKINS_NS} || true
helm upgrade --install jenkins jenkins/jenkins \
--namespace ${JENKINS_NS} \
--set controller.adminUser=${JENKINS_ADMIN_USER} \
--set controller.adminPassword=${JENKINS_ADMIN_PASS} \
--set controller.serviceType=ClusterIP \
--set persistence.size=10Gi


# --- install argocd ---
#kubectl create ns ${ARGOCD_NS} || true
#kubectl apply -n ${ARGOCD_NS} -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd --create-namespace
# values update 후 helm 을 통해 반영
# helm upgrade argocd argo/argo-cd -n argocd -f argocd-dev-values.yaml


# Wait for a few pods (basic wait)
echo "Waiting for Gitea/Jenkins/ArgoCD pods to become ready (approx 60s)"
sleep 60


# --- Create placeholder secrets (replace these with strong keys) ---
kubectl -n ${GITEA_NS} create secret generic gitea-ssh-keys --from-literal=ssh-privatekey='REPLACE_WITH_PRIVATE_KEY' --from-literal=ssh-publickey='REPLACE_WITH_PUBLIC_KEY' || true
kubectl -n ${JENKINS_NS} create secret generic jenkins-gitea-ssh --from-literal=ssh-privatekey='REPLACE_WITH_PRIVATE_KEY' || true


# Print ArgoCD repo add command (user must have argocd CLI configured against cluster)
GITEA_SSH_URL="ssh://git@$(kubectl -n ${GITEA_NS} get svc gitea-http -o jsonpath='{.spec.clusterIP}'):3000/dev/manifest-repo.git"
cat <<EOF


NEXT STEPS:
1) Port-forward or expose Gitea and Jenkins UIs if needed.
kubectl -n ${GITEA_NS} port-forward svc/gitea-http 3000:3000
kubectl -n ${JENKINS_NS} port-forward svc/jenkins 8080:8080


2) Create repos in Gitea: dev/app-repo and dev/manifest-repo (you can push the sample contents).


3) Add manifest-repo to ArgoCD (example):
argocd repo add ${GITEA_SSH_URL} --ssh-private-key-path ~/.ssh/id_rsa_gitea


4) Create an ArgoCD Application (sample is in manifests/argocd-application.yaml)
kubectl apply -n ${ARGOCD_NS} -f manifests/argocd-application.yaml


5) Configure Jenkins credentials:
- Add SSH private key (credential id: gitea-ssh-key) to allow pushing to manifest-repo
- Add Docker registry credentials


6) Create a Jenkins Pipeline job using Jenkinsfile from this package.


EOF