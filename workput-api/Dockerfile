FROM eclipse-temurin:25-jdk AS build
WORKDIR /app
COPY . .
RUN sh ./mvnw -DskipTests package

FROM eclipse-temurin:25-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 10000
ENTRYPOINT ["java", "-jar", "app.jar"]