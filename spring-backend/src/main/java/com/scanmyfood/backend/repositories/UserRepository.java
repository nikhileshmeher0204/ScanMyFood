package com.scanmyfood.backend.repositories;

import com.scanmyfood.backend.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByFirebaseUid(String firebaseUid);
    boolean existsByFirebaseUid(String firebaseUid);
}