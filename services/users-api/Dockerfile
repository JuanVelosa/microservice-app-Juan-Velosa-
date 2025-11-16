# Build stage
FROM maven:3.9.2-eclipse-temurin-11 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:11-jre
WORKDIR /app
COPY --from=builder /app/target/users-api-*.jar app.jar
EXPOSE 8083
CMD ["java", "-jar", "app.jar"]
