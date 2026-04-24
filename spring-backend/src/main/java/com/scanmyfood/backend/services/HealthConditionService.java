package com.scanmyfood.backend.services;

import com.scanmyfood.backend.dto.HealthConditionDto;
import com.scanmyfood.backend.mapper.HealthConditionMapper;
import com.scanmyfood.backend.mapper.UserMapper;
import com.scanmyfood.backend.models.HealthCondition;
import com.scanmyfood.backend.models.User;
import com.scanmyfood.backend.models.UserHealthCondition;
import jakarta.transaction.Transactional;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
public class HealthConditionService {

    @Autowired
    private HealthConditionMapper healthConditionMapper;

    @Autowired
    private UserMapper userMapper;

    public List<HealthConditionDto> getAllHealthConditions() {
        List<HealthCondition> conditions = healthConditionMapper.findAll();
        return conditions.stream().map(this::mapToDto).collect(Collectors.toList());
    }

    @Transactional
    public void saveUserConditions(String firebaseUid, List<String> conditionNames) {
        User user = userMapper.findByFirebaseUid(firebaseUid);
        if (user == null) {
            throw new IllegalArgumentException("User not found with firebaseUid: " + firebaseUid);
        }

        // We completely replace existing conditions with the new list to keep onboarding simple
        healthConditionMapper.deleteUserConditions(user.getId());

        if (conditionNames != null && !conditionNames.isEmpty()) {
            for (String conditionName : conditionNames) {
                UserHealthCondition uhc = new UserHealthCondition();
                uhc.setUser(user);
                HealthCondition hc = new HealthCondition();
                hc.setName(conditionName);
                uhc.setCondition(hc);
                uhc.setDateAdded(LocalDateTime.now());
                uhc.setStatus(UserHealthCondition.Status.ACTIVE);
                
                healthConditionMapper.insertUserCondition(uhc);
            }
        }
        log.info("Saved {} health conditions for user {}", conditionNames != null ? conditionNames.size() : 0, firebaseUid);
    }

    private HealthConditionDto mapToDto(HealthCondition condition) {
        return HealthConditionDto.builder()
                .name(condition.getName())
                .description(condition.getDescription())
                .nutrientsToLimit(condition.getNutrientsToLimit())
                .nutrientsToIncrease(condition.getNutrientsToIncrease())
                .ingredientsToLimit(condition.getIngredientsToLimit())
                .dietaryTagsToLimit(condition.getDietaryTagsToLimit())
                .build();
    }
}
