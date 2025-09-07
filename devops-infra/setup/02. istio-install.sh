# istion gateway 설치 스크립트
# 참조 : https://istio.io/latest/docs/setup/install/helm/

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace
helm install istiod istio/istiod -n istio-system --wait
helm upgrade --install istio-ingressgateway istio/gateway -n istio-system --set service.type=LoadBalancer