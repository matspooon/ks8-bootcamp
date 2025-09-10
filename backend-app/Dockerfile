FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app

# Jenkins에서 빌드된 jar을 Kaniko context에 이미 옮겨놓은 상태라면 이렇게 COPY
COPY backend-app/app.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]