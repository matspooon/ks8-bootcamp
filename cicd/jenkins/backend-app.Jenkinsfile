pipeline{
  agent {
    kubernetes {
      label 'kaniko-gradle'
    }
  }
  environment {
    REGISTRY = 'gitea-http.dev-tools.svc.cluster.local:3000'
    NAMESPACE = 'admin'
    IMAGE = 'backend-app'
    TAG = "${env.BUILD_NUMBER}"
    BRANCH = 'main'
    GITHUB_CRED_ID = 'github-matspooon-credential'
  }
  stages{
    stage('gradle'){
      steps{
        container('gradle'){
          sh 'git config --global --add safe.directory ${WORKSPACE}'

          git url: 'https://github.com/matspooon/ks8-bootcamp.git',
          branch: 'main',
          credentialsId: "github-matspooon-credential"
          
          script {
            env.GIT_COMMIT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
          }          

          dir('backend-app') {
            sh 'pwd && ls -la'
            sh 'sh ./gradlew clean build -x test'
            sh 'mv ./app/build/libs/*.jar /workspace/'
          }
        }
      }
    }
    stage('docker'){
      steps{
        container('kaniko'){
          sh """
            DOCKER_CONFIG=/kaniko/.docker \
            /kaniko/executor \
              --context=dir://${env.WORKSPACE} \
              --dockerfile backend-app/Dockerfile \
              --destination ${REGISTRY}/${NAMESPACE}/${IMAGE}:${TAG} \
              --skip-tls-verify
          """
        }
      }
      post{
        success{
            echo 'success Build & Push'
        }
        failure{
            echo 'failure Build & Push'
        }
      }
    }
  }
}
