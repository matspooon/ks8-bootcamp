kubectl create -f istio-gateway.yaml
# kubectl apply -f istio-gateway.yaml

kubectl create -f istio-cicd.yaml
# kubectl apply -f istio-cicd.yaml

kubectl create -f istio-ingress.yaml
# kubectl apply -f istio-ingress.yaml

######################################################################################
# k8s cluster의 coredns에 gitea-https.dev-tools.svc.cluster.local를 alias로 추가해줘야한다
# istio gateway의 clusterIP 확인
kubectl get svc istio-ingressgateway -n istio-system
# cordens 편집
kubectl -n kube-system edit configmap coredns
# 다음의 내용을 .:53 { 에 추가
#        hosts {
#            10.108.127.16 gitea-https.dev-tools.svc.cluster.local
#            fallthrough
#        }
# corddns가 바로 반영안될경우 reload
kubectl rollout restart deployment coredns -n kube-system
