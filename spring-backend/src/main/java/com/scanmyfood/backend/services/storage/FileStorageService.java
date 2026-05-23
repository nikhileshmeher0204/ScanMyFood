package com.scanmyfood.backend.services.storage;

import org.springframework.web.multipart.MultipartFile;

/**
 * Abstraction for file storage operations.
 * Implementations can be local file system, AWS S3, Google Cloud Storage, etc.
 */
public interface FileStorageService {

    /**
     * Stores a file and returns a URL/path to access it
     * @param file The file to store
     * @param folder Optional folder/prefix for organizing files
     * @return URL or path to access the stored file
     * @throws Exception if storage fails
     */
    String store(MultipartFile file, String folder) throws Exception;

    /**
     * Deletes a file
     * @param fileUrl The URL/path of the file to delete
     * @throws Exception if deletion fails
     */
    void delete(String fileUrl) throws Exception;

    /**
     * Gets the full URL to access a file (for API responses)
     * @param storedPath The stored path/key
     * @return Full accessible URL
     */
    String getAccessUrl(String storedPath);
}