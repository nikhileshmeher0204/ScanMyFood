package com.scanmyfood.backend.configurations;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.vertexai.VertexAI;
import com.google.cloud.vertexai.generativeai.GenerativeModel;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;

import java.io.ByteArrayInputStream;
import java.io.IOException;

@Configuration
public class VertexAIConfig {

    @Value("${google.cloud.project-id:foodscanai-d28bc}")
    private String projectId;

    @Value("${google.cloud.location:us-central1}")
    private String location;

    @Value("${vertex.ai.model.name:gemini-2.0-flash}")
    private String MODEL_NAME;

    @Bean
    public GoogleCredentials googleCredentials() throws IOException {
        // Option 1: Use the service account JSON file that's already present for Firebase
        Resource resource = new ClassPathResource("firebase-service-account.json");
        if (resource.exists()) {
            return GoogleCredentials.fromStream(resource.getInputStream())
                    .createScoped("https://www.googleapis.com/auth/cloud-platform");
        }

        // Option 2: Try environment variable
        String credentialsJson = System.getenv("GOOGLE_APPLICATION_CREDENTIALS_JSON");
        if (credentialsJson != null && !credentialsJson.isEmpty()) {
            return GoogleCredentials.fromStream(new ByteArrayInputStream(credentialsJson.getBytes()))
                    .createScoped("https://www.googleapis.com/auth/cloud-platform");
        }

        // Option 3: Fall back to Application Default Credentials
        return GoogleCredentials.getApplicationDefault()
                .createScoped("https://www.googleapis.com/auth/cloud-platform");
    }

    @Bean
    public VertexAI vertexAI(GoogleCredentials credentials) {
        return new VertexAI.Builder()
                .setProjectId(projectId)
                .setLocation(location)
                .setCredentials(credentials)
                .build();
    }

    @Bean
    public GenerativeModel generativeModel(VertexAI vertexAI) {
        return new GenerativeModel(MODEL_NAME, vertexAI);
    }
}