# K8s에서 CICD 구성 스크립트
<pre>
helm-install.sh # shell script to install Helm charts & apply manifests
secrets/ # examples of k8s Secret manifests (SSH keys, admin pw)
  gitea-ssh-key-secret.yaml
  jenkins-credentials-secret.yaml
manifests/
  argocd-application.yaml
  jenkins-agent-serviceaccount.yaml
sample-repos/
  manifest-repo/ # layout for manifest repo (to create in Gitea)
    environments/dev/kustomization.yaml
    environments/dev/patch-deployment.yaml
    environments/dev/values.yaml
  app-repo/ # minimal app to build (Dockerfile, src placeholder)
Jenkinsfile # sample Jenkins Pipeline (updates manifest-repo)
values/gitea-values.yaml # optional Helm values for Gitea
values/jenkins-values.yaml
</pre>

## gitea, jenkins, argocd로 CICD를 docker desktop의 kubernetes cluster에 구성할 때 가장 곤란했던점
***********************************************************************************************
argocd가 pull을 하는 image 주소를 k8s cluster의 내부 주소인 gitea-http.dev-tools.svc.cluster.local로
호출하는 것은 no such host 오류가 발생했으며, chatgpt가 self signed(사설) 인증서 문제나 k8s coredns의 
문제로 계속 가이드하면서 가장 많은 시간을 허비함.
결론적으로 argocd가 docker image pull을 하는 것은 jenkins build시 사용하는 kaniko-executor와 달리 docker
환경을 그대로 사용하므로, docker desktop의 경우 windows hosts 파일과 docker desktop의 설정/Docker Engine에서
insecure-registries를 등록해줘야만 한다.
(gitea.k8s.dev 사설 인증서를 윈도우의 루트 CA에 매뉴얼 등록을 한 경우 docker desktop의 insecure 등록은 불필요)
유닉스환경이라면 containerd에 맞는 설정정보 변경을 해줘야한다.

# helm&k8s uninstall
helm uninstall gitea -n dev-tools
kubectl delete namespace dev-tools
# dns 조회 : istio gateway에서 대상 시스템 접속이 정상인지 체크
<pre>
kubectl exec -it -n istio-system <ingressgateway-pod> -- curl http://gitea-http.dev-tools.svc.cluster.local:3000
kubectl exec -it -n istio-system istiod-867796dbf9-56d2x -- curl http://gitea-http.dev-tools.svc.cluster.local:3000
kubectl exec -it -n istio-system istiod-867796dbf9-56d2x -- nslookup gitea-http.gitea.svc.cluster.local

kubectl exec -it -n istio-system istiod-867796dbf9-56d2x -- curl http://jenkins.dev-tools.svc.cluster.local:8080
kubectl exec -it -n istio-system istiod-867796dbf9-56d2x -- curl -L http://argocd-server.argocd.svc.cluster.local
</pre>
# port-forward : 대상 시스템의 서비스가 정상인지 체크
kubectl port-forward -n dev-tools svc/gitea-http 3000:3000
kubectl port-forward -n dev-tools svc/jenkins 8080:8080

# 설치한 서비스의 env 확인
* kubectl exec -it -n $namespace $pod_name -- printenv | grep JAVA_OPTS
* ex:kubectl exec -it -n dev-tools jenkins-0 -- printenv | grep JAVA_OPTS

# 유용한 명령어들
<pre>
# k8s cluster에 세팅된 docker-registry-credential secret 확인
kubectl get secret docker-registry-credential -n dev-tools -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d
# Argo CD에서 Application 리소스를 삭제할 때, 내부적으로 최종 동기화(cleanup) 작업을 기다리다가 stuck 되는 경우가 있습니다. (특히 ImagePullBackOff 같은 상태일 때 자주 발생)
# argocd application 강제 삭제
kubectl delete application backend-app -n argocd --grace-period=0 --force --cascade=orphan
kubectl patch application backend-app -n argocd -p '{"metadata":{"finalizers":null}}' --type=merge
</pre>

# argocd가 배포시 사용하는 image pull하는 docker registry문제
docker registry는 default로 https통신을 강제한다. 
k8s cluster 내에 설치한 gitea는 http service만을 제공하므로 별도의 HTTPS Proxy를 통하지 않는다면, http통신을 하도록 변경해야 하는데,
argocd 설정이나, apps.yaml에서 포함하는 repository설정으로는 이것을 강제할 수 없고, docker setting으로만 변경할 수 있다.
window docker desktop의 경우 '설정' / 'Docker Engine' 메뉴에서 다음을 추가함으로써 http 통신을 하도록 변경할 수 있다.