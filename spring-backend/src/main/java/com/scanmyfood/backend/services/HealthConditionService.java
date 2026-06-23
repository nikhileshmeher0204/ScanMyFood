package com.scanmyfood.backend.services;

import com.scanmyfood.backend.constants.ErrorCodes;
import com.scanmyfood.backend.dto.HealthConditionDto;
import com.scanmyfood.backend.exceptions.NotFoundException;
import com.scanmyfood.backend.mapper.HealthConditionMapper;
import com.scanmyfood.backend.mapper.UserMapper;
import com.scanmyfood.backend.models.HealthCondition;
import com.scanmyfood.backend.models.User;
import com.scanmyfood.backend.models.UserHealthCondition;
import org.springframework.transaction.annotation.Transactional;
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
        log.info("Fetching all health conditions");
        List<HealthCondition> conditions = healthConditionMapper.findAll();
        log.info("Fetched {} health conditions", conditions.size());
        return conditions.stream().map(this::mapToDto).collect(Collectors.toList());
    }

    public List<HealthConditionDto> getUserConditions(String userId) {
        log.info("Fetching health conditions for user {}", userId);
        List<HealthCondition> conditions = healthConditionMapper.findByUserId(userId);
        log.info("Fetched {} health conditions for user {}", conditions.size(), userId);
        return conditions.stream().map(this::mapToDto).collect(Collectors.toList());
    }


    @Transactional
    public void saveUserConditions(String userId, List<String> conditionNames) {
        log.info("saveUserConditions — userId: {}, conditionCount: {}",
                userId, conditionNames != null ? conditionNames.size() : 0);
        User user = userMapper.findByUserId(userId);
        if (user == null) {
            log.warn("User not found for userId: {} when saving health conditions", userId);
            throw new NotFoundException(ErrorCodes.ERR_USER_NOT_FOUND,
                    "User not found with userId: " + userId);
        }

        // Completely replace existing conditions with the new list to keep onboarding simple
        healthConditionMapper.deleteUserConditions(user.getUserId());

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
        log.info("Saved {} health conditions for userId: {}",
                conditionNames != null ? conditionNames.size() : 0, userId);
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
