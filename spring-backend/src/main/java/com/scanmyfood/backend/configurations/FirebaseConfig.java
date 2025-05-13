package com.scanmyfood.backend.configurations;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;

import javax.annotation.PostConstruct;
import java.io.ByteArrayInputStream;
import java.io.IOException;

@Configuration
public class FirebaseConfig {
    private static final Logger logger = LoggerFactory.getLogger(FirebaseConfig.class);

    @PostConstruct
    public void initialize() {
        try {
            FirebaseOptions options;
            String firebaseConfig = System.getenv("FIREBASE_CONFIG");

            if (firebaseConfig != null && !firebaseConfig.isEmpty()) {
                // Load from environment variable
                options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(
                                new ByteArrayInputStream(firebaseConfig.getBytes())))
                        .build();
            } else {
                // Fallback to file
                Resource resource = new ClassPathResource("firebase-service-account.json");
                if (!resource.exists()) {
                    logger.warn("Firebase configuration not found. Firebase integration disabled.");
                    return;
                }
                options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(resource.getInputStream()))
                        .build();
            }

            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
                logger.info("Firebase application has been initialized");
            }
        } catch (IOException e) {
            logger.error("Error initializing Firebase", e);
        }
    }


}