package com.scanmyfood.backend.repositories;

import com.scanmyfood.backend.models.UserPreference;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserPreferenceRepository extends JpaRepository<UserPreference, Long> {
}
