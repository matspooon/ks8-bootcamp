# CICD 구성을 위한 gitea에 구성할 repo 구성

## dev : 개발, stg : 스테이징, prd : 운영 권한 분리를 위해 dev,stg,prd 계정을 생성하고 repo 각각 생성
<pre>
manifest-repo/
├── front-app/
│   └── k8s-manifests/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── virtualservice.yaml
├── backend-app/
│   └── k8s-manifests/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── virtualservice.yaml
├── user-mgmt-app/
│   └── k8s-manifests/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── virtualservice.yaml
└── istio-config/
    └── gateway.yaml   # 공용 Gateway만 관리
manifest-repo/
├── front-app/
│   └── helm/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           └── virtualservice.yaml
├── backend-app/
│   └── helm/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           └── virtualservice.yaml
├── user-mgmt-app/
│   └── helm/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           └── virtualservice.yaml
└── istio-config/
    └── gateway.yaml

</pre>