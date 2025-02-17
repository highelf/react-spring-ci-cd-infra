# Use an OpenJDK base image
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy Maven files first (improves caching)
COPY mvnw ./
COPY .mvn .mvn
COPY pom.xml ./

# Download dependencies (avoids re-downloading if the source code changes)
RUN ./mvnw dependency:go-offline

# Copy the full application source code
COPY . .

# Build the application (produces the JAR file)
RUN ./mvnw clean package -DskipTests

# Explicitly copy the JAR file to the container
RUN mkdir -p target && cp target/*.jar app.jar

# Expose port 8080
EXPOSE 8080

# Run the Spring Boot application
CMD ["java", "-jar", "app.jar"]