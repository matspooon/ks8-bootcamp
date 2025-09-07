# local에서 최소 pod으로 개발목적으로 설치하려면 품이 많이 들어감
# gitea, jenkins, argocd를 local 모드로 설치할 경우 변경설치를 하거나 upgrade를 할 경우 이전 데이터를 모두 잃게된다.
# local 개발 모드에서는 데이터를 주기적으로 관리하지않고 가능한 빠르게 설정하고, 지우고 다시 설치하는 방식일때 유용함.

# gitea custom lite 설치(postgresql pod X, sqlite3 사용, persistence X)
helm repo add gitea-charts https://dl.gitea.io/charts/
helm repo update

helm install gitea gitea-charts/gitea \
  --namespace dev-tools \
  --create-namespace \
  -f gitea-dev-values.yaml
# helm chart upgrade
helm upgrade gitea gitea-charts/gitea \
  -n dev-tools \
  -f gitea-dev-values.yaml

# jenkins 설치
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm upgrade --install jenkins jenkins/jenkins \
--namespace dev-tools \
--set controller.admin.username=admin \
--set controller.admin.password=admin \
--set controller.serviceType=ClusterIP \


helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd --create-namespace -f argocd-dev-values.yaml
# values update 후 helm 을 통해 반영
# helm upgrade argocd argo/argo-cd -n argocd -f argocd-dev-values.yaml
# admin 비번확인
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
# 패스워드를 간단하게 변경하려면 argocd-server instance에 직접 명령어 수행(admin ui는 8자 길이제한이 있음)