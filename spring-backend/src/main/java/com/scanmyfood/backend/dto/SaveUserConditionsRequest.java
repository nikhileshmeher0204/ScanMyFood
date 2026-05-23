package com.scanmyfood.backend.dto;

import lombok.Data;
import java.util.List;

@Data
public class SaveUserConditionsRequest {
    private String userId;
    private List<String> conditionNames;
}
