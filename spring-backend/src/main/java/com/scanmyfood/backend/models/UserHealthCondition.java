package com.scanmyfood.backend.models;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserHealthCondition {

    private User user;
    private HealthCondition condition;
    private LocalDateTime dateAdded;
    private LocalDateTime dateRemoved;
    private Severity severity;
    private Status status = Status.ACTIVE;

    public enum Severity {
        MILD, MODERATE, SEVERE
    }

    public enum Status {
        ACTIVE, RESOLVED
    }
}
