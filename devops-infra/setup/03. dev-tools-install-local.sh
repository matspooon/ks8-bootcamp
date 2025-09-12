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
helm upgrade gitea gitea-charts/gitea -n dev-tools -f gitea-dev-values.yaml

# jenkins 설치
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm upgrade --install jenkins jenkins/jenkins -n dev-tools -f jenkins-dev.yaml
helm upgrade jenkins jenkins/jenkins -n dev-tools -f jenkins-dev.yaml
kubectl apply -f jenkins-workspace-pvc.yaml

# jenkins : kaniko 설치
## k8s 클러스터내의 gitea에 kaniko executor image 등록 : 인터넷
docker pull gcr.io/kaniko-project/executor:latest
docker save gcr.io/kaniko-project/executor:latest -o kaniko.tar
## k8s 클러스터내의 gitea에 kaniko executor image 등록 : 폐쇄망 내부에서
docker login gitea.k8s.dev --username admin --password admin
docker load -i kaniko.tar
docker tag gcr.io/kaniko-project/executor:latest gitea.k8s.dev/admin/gcr.io/kaniko-project/executor:latest
docker push gitea.k8s.dev/admin/gcr.io/kaniko-project/executor:latest
## gitea의 docker registry용 Secret 생성
## from-file : kubectl로 생성되는 default 파일은 .dockerconfigjson 파일인데, kaniko가 요구하는 파일명은 config.json이여서 파일명 별도 지정
kubectl create secret docker-registry docker-registry-credential \
  --docker-server=gitea-http.dev-tools.svc.cluster.local:3000 \
  --docker-username=admin \
  --docker-password=admin \
  --docker-email=admin@k8s.dev \
  -n dev-tools


# argocd 설치
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace -f argocd-dev-values.yaml
# values update 후 helm 을 통해 반영
# helm upgrade argocd argo/argo-cd -n argocd -f argocd-dev-values.yaml
# admin 비번확인
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
# 패스워드를 간단하게 변경하려면 argocd-server instance에 직접 명령어 수행(admin ui는 8자 길이제한이 있음)

# argocd-repo-server가 docker pull을 할 때 사용할 docker registry secret 생성
#kubectl create secret docker-registry docker-registry-gitea-cred \
#  --docker-server=gitea-https.dev-tools.svc.cluster.local:443 \
#  --docker-username=admin \
#  --docker-password=admin \
#  --docker-email=unused@k8s.dev \
#  -n argocd
kubectl create secret docker-registry docker-registry-gitea-cred \
  --docker-server=gitea-https.dev-tools.svc.cluster.local:443 \
  --docker-username=admin \
  --docker-password=admin \
  --docker-email=unused@k8s.dev \
  -n apps

# repo https 비활성화
#kubectl apply -f argocd-configmap.yaml
#kubectl rollout restart deploy -n argocd argocd-repo-server
#kubectl rollout restart deploy -n argocd argocd-server


## argocd 삭제시 helm uninstall argocd -n argocd 만으로는 데이터가 모두 삭제되지 않음
# 모든 Application 삭제
kubectl delete applications --all -A
# 모든 AppProject 삭제
kubectl delete appprojects --all -A
# CRD 삭제(Custom Resource Definition)
kubectl delete crd applications.argoproj.io appprojects.argoproj.io applicationsets.argoproj.io

## application 안지워질때
kubectl get application -n argocd -o yaml
kubectl patch application backend-app -n argocd -p '{"metadata":{"finalizers":[]}}' --type=merge
