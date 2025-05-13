package com.scanmyfood.backend.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "scan_history")
public class ScanHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String productName;

    @Column(columnDefinition = "TEXT")
    private String nutritionData;

    private String imagePath;

    @Column(nullable = false)
    private LocalDateTime scanDate;

    @PrePersist
    protected void onCreate() {
        scanDate = LocalDateTime.now();
    }
}