package com.scanmyfood.backend.models;

import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Getter
@Setter
public class ScanHistory {
    private Long id;
    private User user;
    private String productName;
    private String nutritionData;
    private String imagePath;
    private LocalDateTime scanDate;

    protected void onCreate() {
        scanDate = LocalDateTime.now();
    }
}