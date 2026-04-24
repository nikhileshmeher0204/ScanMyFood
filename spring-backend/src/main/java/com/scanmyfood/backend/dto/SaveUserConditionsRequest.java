package com.scanmyfood.backend.dto;

import lombok.Data;
import java.util.List;

@Data
public class SaveUserConditionsRequest {
    private String firebaseUid;
    private List<String> conditionNames;
}
