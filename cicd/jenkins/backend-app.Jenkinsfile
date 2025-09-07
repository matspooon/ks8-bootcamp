pipeline {
    agent any
    environment {
        REGISTRY = "gitea-http.dev-tools.svc.cluster.local:3000/admin"
        IMAGE = "${REGISTRY}/backend-app"
        BRANCH = "main"
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: "${BRANCH}", url: 'https://github.com/matspooon/backend-app-repo.git'
            }
        }
        stage('Build') {
            steps {
                sh './gradlw clean bootJar'
            }
        }
        stage('Docker Build & Push') {
            steps {
                script {
                    def tag = "${env.BUILD_NUMBER}"
                    sh "docker build -t ${IMAGE}:${tag} ."
                    sh "echo $CR_PAT | docker login gitea-http.dev-tools.svc.cluster.local:3000 -u admin -p admin"
                    sh "docker push ${IMAGE}:${tag}"
                    env.IMAGE_TAG = tag
                }
            }
        }
        stage('Update GitOps Repo') {
            steps {
                sh '''
                git clone https://github.com/your-org/gitops-repo.git
                cd gitops-repo/envs/dev/values
                yq e -i '.image.tag = strenv(IMAGE_TAG)' backend-values.yaml
                git config user.email "cicd@your-org.com"
                git config user.name "Jenkins CI"
                git commit -am "Update backend-app image to tag ${IMAGE_TAG}"
                git push
                '''
            }
        }
    }
}
