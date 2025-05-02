package com.scanmyfood.backend.services;

import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

public interface AiService {
    Map<String, Object> analyzeProductImages(MultipartFile frontImage, MultipartFile labelImage);
    Map<String, Object> analyzeFoodImage(MultipartFile imageFile);
    Map<String, Object> analyzeFoodDescription(String description);
}