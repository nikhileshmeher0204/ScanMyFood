package com.scanmyfood.backend.repositories;

import com.scanmyfood.backend.models.HealthMetric;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HealthMetricRepository extends JpaRepository<HealthMetric, Long> {
}
