package com.scanmyfood.backend.events;

import lombok.Getter;

@Getter
public class MealLoggedEvent {
    private final String userId;
    private final int dailyIntakeId;

    public MealLoggedEvent(String userId, int dailyIntakeId) {
        this.userId = userId;
        this.dailyIntakeId = dailyIntakeId;
    }
}
