package com.scanmyfood.backend.models;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class UserIntakeOutput {
    private String userId;
    private List<DailyIntakeData> dailyIntakes;
}
