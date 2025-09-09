# k8s backend MSA
## bootcamp.k8s.dev/backend (dev env: bootcamp.dev.k8s.dev)
## springboot + restfule API + swagger

1. 실행시 실행환경에 맞는 환경변수 세팅이 필요함
DB_URL
DB_USERNAME
DB_PASSWORD
* 참조.1

2. docker build command
docker build -t matspooon/k8sbasic/backend-app:latest .

<pre>
==============================================================================
참조.1
==============================================================================
아래의 방법에서 vscode의 경우
1. gradle에서 실행시에 env 주입을 위해 .env 파일 생성
2. vscode 자체 run/debug시 env 주입을 위해 .vscode/launch.json 파일 수정 

📌 VS Code에서 Environment 변수 설정 방법
1. Run/Debug Configuration (launch.json) 사용

VS Code에서 Run and Debug (Ctrl+Shift+D / ⌘+Shift+D) 열기
launch.json 생성 (자동으로 .vscode/launch.json 파일이 생김)
실행할 App 설정에 env 블록 추가
예시 (.vscode/launch.json)
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "name": "Debug Spring Boot",
      "request": "launch",
      "mainClass": "com.example.demo.DemoApplication",
      "projectName": "demo",
      "env": {
        "DB_HOST": "localhost",
        "DB_PORT": "3306"
      }
    }
  ]
}


➡️ 이렇게 하면 VS Code에서 실행/디버깅할 때 Spring Boot 앱이 해당 환경변수를 가지고 실행됩니다.

2. Tasks (tasks.json)에서 환경 변수 설정

Gradle/Maven 빌드나 특정 Task 실행 시 환경 변수 주입 가능.
예시 (.vscode/tasks.json):
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "BootRun",
      "type": "shell",
      "command": "./gradlew bootRun",
      "options": {
        "env": {
          "DB_HOST": "localhost",
          "DB_PORT": "3306"
        }
      }
    }
  ]
}


➡️ Terminal → Run Task → BootRun 실행 시 환경변수가 적용됩니다.

3. 터미널 세션에서 직접 설정
VS Code 내 터미널에서 직접 export 후 실행:

export DB_HOST=localhost
export DB_PORT=3306
./gradlew bootRun


(Windows PowerShell은 $env:DB_HOST="localhost" 방식)

4. .env 파일 + 확장 사용 (선택사항)

.env 파일 작성:

DB_HOST=localhost
DB_PORT=3306


dotenv 같은 확장을 설치하면 VS Code Debug Configuration에서 자동으로 .env를 읽을 수 있습니다.

✅ 정리

디버깅 시 → launch.json의 env

Task 실행 시 → tasks.json의 env

단순 실행 시 → VS Code 터미널에서 직접 export
</pre>