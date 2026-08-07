package com.scanmyfood.backend.services.storage;

import com.google.cloud.storage.Blob;
import com.google.cloud.storage.Bucket;
import com.google.firebase.cloud.StorageClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

@Slf4j
@Service
@ConditionalOnProperty(name = "storage.type", havingValue = "firebase")
public class FirebaseFileStorageService implements FileStorageService {

    @Value("${firebase.storage.bucket-name:foodscanai-d28bc.appspot.com}")
    private String bucketName;

    @Override
    public String store(MultipartFile file, String folder) throws Exception {
        try {
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".")
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : ".jpg";
            String filename = UUID.randomUUID().toString() + extension;

            String objectName = folder != null && !folder.isEmpty() ? folder + "/" + filename : filename;

            Bucket bucket = bucketName != null && !bucketName.isEmpty()
                    ? StorageClient.getInstance().bucket(bucketName)
                    : StorageClient.getInstance().bucket();

            String contentType = file.getContentType() != null ? file.getContentType() : "image/jpeg";

            bucket.create(objectName, file.getBytes(), contentType);

            log.info("Successfully stored file in Firebase Storage bucket '{}': {}", bucket.getName(), objectName);
            return objectName;

        } catch (Exception e) {
            log.error("Failed to store file in Firebase Storage: {}", e.getMessage(), e);
            throw new Exception("Failed to store file in Firebase Storage", e);
        }
    }

    @Override
    public void delete(String fileUrl) throws Exception {
        try {
            Bucket bucket = bucketName != null && !bucketName.isEmpty()
                    ? StorageClient.getInstance().bucket(bucketName)
                    : StorageClient.getInstance().bucket();

            Blob blob = bucket.get(fileUrl);
            if (blob != null) {
                blob.delete();
                log.info("File deleted from Firebase Storage: {}", fileUrl);
            }
        } catch (Exception e) {
            log.error("Failed to delete file from Firebase Storage: {}", e.getMessage(), e);
            throw new Exception("Failed to delete file from Firebase Storage", e);
        }
    }

    @Override
    public String getAccessUrl(String storedPath) {
        if (storedPath == null || storedPath.isEmpty()) {
            return "";
        }
        if (storedPath.startsWith("http://") || storedPath.startsWith("https://")) {
            return storedPath;
        }
        String bucket = bucketName != null && !bucketName.isEmpty() ? bucketName : "foodscanai-d28bc.appspot.com";
        String encodedPath = URLEncoder.encode(storedPath, StandardCharsets.UTF_8);
        return String.format("https://firebasestorage.googleapis.com/v0/b/%s/o/%s?alt=media", bucket, encodedPath);
    }
}
