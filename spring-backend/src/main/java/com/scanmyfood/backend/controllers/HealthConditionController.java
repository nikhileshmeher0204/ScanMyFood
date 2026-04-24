package com.scanmyfood.backend.controllers;

import com.scanmyfood.backend.constants.ResponseCodeConstants;
import com.scanmyfood.backend.dto.HealthConditionDto;
import com.scanmyfood.backend.models.ApiResponse;
import com.scanmyfood.backend.services.HealthConditionService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/health-conditions")
@Slf4j
public class HealthConditionController {

    @Autowired
    private HealthConditionService healthConditionService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<HealthConditionDto>>> getAllHealthConditions() {
        log.info("Fetching all health conditions");
        List<HealthConditionDto> conditions = healthConditionService.getAllHealthConditions();
        return ResponseEntity.ok(ApiResponse.success(ResponseCodeConstants.SUCCESS, conditions));
    }
}
