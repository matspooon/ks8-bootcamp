pipeline{
  agent {
    /*
    kubernetes {
      label 'kaniko-gradle'
    }
    kubernetes {
      yamlFile 'cicd/jenkins/jenkins-pod-template.yaml'
      defaultContainer 'gradle'
    }
    */
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: gradle
      image: gradle:7.6-jdk17
      command: ['sleep']
      args: ['infinity']
      volumeMounts:
        - name: workspace
          mountPath: /workspace
        - name: gradle-cache
          mountPath: /home/jenkins/.gradle
    - name: kaniko
      image: gcr.io/kaniko-project/executor:debug
      command: ['sleep']
      args: ['infinity']
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker
        - name: workspace
          mountPath: /workspace
  volumes:
    - name: docker-config
      secret:
        secretName: docker-registry-credential
        items:
          - key: .dockerconfigjson
            path: config.json
    - name: workspace
      emptyDir:
        memory: false
    - name: gradle-cache
      persistentVolumeClaim:
        claimName: jenkins-gradle-cache
"""
      defaultContainer 'gradle'
      customWorkspace '/workspace'
    }
  }
  environment {
    REGISTRY = 'gitea-http.dev-tools.svc.cluster.local:3000'
    NAMESPACE = 'admin'
    IMAGE = 'backend-app'
    // TAG = "${env.BUILD_NUMBER}"
    TAG = 'latest'
    BRANCH = 'main'
    GITHUB_CRED_ID = 'github-matspooon-credential'
  }
  stages{
    stage('gradle'){
      steps{
        container('gradle'){
          sh 'git config --global --add safe.directory ${WORKSPACE}'

          git url: 'https://github.com/matspooon/ks8-bootcamp.git',
          branch: env.BRANCH,
          credentialsId: env.GITHUB_CRED_ID
          
          script {
            env.GIT_COMMIT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
          }          

          dir('backend-app') {
            sh 'pwd && ls -la'
            sh 'sh ./gradlew clean build -x test'
            sh 'mv ./app/build/libs/*.jar ./'
          }
        }
      }
    }
    stage('docker'){
      steps{
        container('kaniko'){
          sh """
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
