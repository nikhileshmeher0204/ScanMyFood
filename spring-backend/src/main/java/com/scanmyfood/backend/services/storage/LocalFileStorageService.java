package com.scanmyfood.backend.services.storage;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Slf4j
@Service
@ConditionalOnProperty(name = "storage.type", havingValue = "local", matchIfMissing = true)
public class LocalFileStorageService implements FileStorageService {

    @Value("${storage.local.base-dir}")
    private String baseDir;

    @Value("${server.port:8080}")
    private String serverPort;

    @Override
    public String store(MultipartFile file, String folder) throws Exception {
        try {
            // Create directory structure
            String targetDir = folder != null ? baseDir + "/" + folder : baseDir;
            File directory = new File(targetDir);
            if (!directory.exists()) {
                directory.mkdirs();
            }

            // Generate unique filename
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".")
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : ".jpg";
            String filename = UUID.randomUUID().toString() + extension;

            // Save file
            Path filepath = Paths.get(targetDir, filename);
            Files.write(filepath, file.getBytes());

            log.info("File saved locally: {}", filepath);

            // Return relative path (stored in DB)
            String relativePath = folder != null ? folder + "/" + filename : filename;
            return relativePath;

        } catch (IOException e) {
            log.error("Failed to store file locally: {}", e.getMessage());
            throw new Exception("Failed to store file", e);
        }
    }

    @Override
    public void delete(String fileUrl) throws Exception {
        try {
            Path filepath = Paths.get(baseDir, fileUrl);
            Files.deleteIfExists(filepath);
            log.info("File deleted: {}", filepath);
        } catch (IOException e) {
            log.error("Failed to delete file: {}", e.getMessage());
            throw new Exception("Failed to delete file", e);
        }
    }

    @Override
    public String getAccessUrl(String storedPath) {
        // Return URL accessible from Android emulator
        return "http://10.0.2.2:" + serverPort + "/uploads/" + storedPath;
    }
}