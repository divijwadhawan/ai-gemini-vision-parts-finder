FROM maven:3.9-eclipse-temurin-25 AS build
WORKDIR /app
COPY . .
WORKDIR /app/workput-api
RUN mvn -DskipTests package

FROM eclipse-temurin:25-jre
WORKDIR /app
COPY --from=build /app/workput-api/target/*.jar app.jar
EXPOSE 10000
ENTRYPOINT ["java", "-jar", "app.jar"]