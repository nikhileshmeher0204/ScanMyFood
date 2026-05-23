package com.scanmyfood.backend.models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ImageGenerationResponse {
    private String imageData; // Base64-encoded image
    private String mimeType;   // e.g., "image/png"
    private String description; // Original food description
    private int sizeBytes;      // Image size in bytes
}
