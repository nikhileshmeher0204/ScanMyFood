package com.scanmyfood.backend.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.LocalDateTime;
import java.io.Serializable;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode
class UserHealthConditionId implements Serializable {
    private Long user;
    private String condition;
}

@Getter
@Setter
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "user_health_conditions")
@IdClass(UserHealthConditionId.class)
public class UserHealthCondition {

    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "condition_name", nullable = false)
    private HealthCondition condition;

    @Column(nullable = false)
    private LocalDateTime dateAdded;

    private LocalDateTime dateRemoved;

    @Enumerated(EnumType.STRING)
    private Severity severity;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status = Status.ACTIVE;

    @PrePersist
    protected void onCreate() {
        dateAdded = LocalDateTime.now();
        if (status == null) {
            status = Status.ACTIVE;
        }
    }

    public enum Severity {
        MILD, MODERATE, SEVERE
    }

    public enum Status {
        ACTIVE, RESOLVED
    }
}
