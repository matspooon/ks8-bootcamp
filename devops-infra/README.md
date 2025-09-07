# 『쿠버네티스 클러스터 : Gitea + Jenkins + ArgoCD + Istio Gateway 로 구성하는 실전 CICD 서비스 구성』


## 전체 구성
1. Gitea → k8s cluster내의 jenkins에서 빌드하는 docker image registry, argoncd의 manifest-repo 
2. Jenkins → CI (빌드, 테스트, 이미지 생성, manifest-repo 업데이트)
3. ArgoCD → CD (manifest-repo 변경 감지 → 배포 자동화)
4. Istion Gateway → 서비스 분기

## Gitea
* 코드 Repo : Github 사용
* manifest Repo : 신규 빌드가 구성되면 빌드 넘버를 업데이트하여 ArgoCD가 배포를 실행하도록 함
