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