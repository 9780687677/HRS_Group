# Use a Java base image
FROM openjdk:11-jre-slim

# Set the working directory
WORKDIR /app

# Copy the executable JAR file from the build environment into the container
COPY build/libs/*.jar /app/app.jar

# Set the entry point to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
