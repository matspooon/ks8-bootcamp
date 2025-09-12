# 1. --------------------------------------------
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout k8s.dev.key \
  -out k8s.dev.crt \
  -config k8s.dev.cnf \
  -extensions req_ext

# 2. 쿠버네티스 시크릿 생성 (istio-system 네임스페이스에 TLS 시크릿 생성)
kubectl create -n istio-system secret tls selfsigned-gateway-cert \
  --key k8s.dev.key \
  --cert k8s.dev.crt

# 3. --------------------------------------------
# 신뢰할 수 없는 기관으로 인한 TLS 오류를 보지 않고자 할 경우 윈도우에 신뢰할 수 있는 루트 인증 기관으로 k8s.crt를 추가
# k8s.crt를 더블클릭해서 '인증서 설치...' 클릭, '모든 인증서를 다음 저장소에 저장'을 선택하고 찾아보기에서 '신뢰할 수 있는 루트 인증 기관' 선택 후 설치
# 바로 반영이 안될경우 재부팅
# https://leemcse.tistory.com/entry/%EC%8B%A0%EB%A2%B0%ED%95%A0-%EC%88%98-%EC%9E%88%EB%8A%94-%EB%A3%A8%ED%8A%B8-%EC%9D%B8%EC%A6%9D-%EA%B8%B0%EA%B4%80%EC%9D%98-%EC%9D%B8%EC%A6%9D%EC%84%9C-%EC%84%A4%EC%B9%98-%EB%B0%A9%EB%B2%95
# cmd창에서 mmc(Microsoft Management Console) 실행 후 파일 - 스냅인 추가/제거 - 인증서 - 컴퓨터 계정 - 로컬 컴퓨터 - 확인 - 신뢰할 수 있는 루트 인증 기관 - 인증서 우클릭 - 모든 작업 - 가져오기 클릭 후 k8s.crt 선택해서 설치 가능

# k8s cluster 내부 서비스인 gitea-http에 대해서 argocd가 호출하는 docker registry https 호출문제 때문에 gitea-https만 추가
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -out gitea-tls.crt \
  -keyout gitea-tls.key \
  -subj "/CN=gitea-http.dev-tools.svc.cluster.local"

kubectl create -n istio-system secret tls gitea-selfsigned-tls \
--cert=gitea-tls.crt \
--key=gitea-tls.key

kubectl -n apps create configmap gitea-selfsigned-ca \
  --from-file=ca.crt=gitea-tls.crt
kubectl -n apps create secret generic gitea-selfsigned-ca \
  --from-file=ca.crt=gitea-tls.crt