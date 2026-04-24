package com.scanmyfood.backend.services;

import com.scanmyfood.backend.constants.ErrorCodes;
import com.scanmyfood.backend.dto.HealthConditionDto;
import com.scanmyfood.backend.exceptions.NotFoundException;
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
        log.info("Fetching all health conditions");
        List<HealthCondition> conditions = healthConditionMapper.findAll();
        log.info("Fetched {} health conditions", conditions.size());
        return conditions.stream().map(this::mapToDto).collect(Collectors.toList());
    }

    @Transactional
    public void saveUserConditions(String firebaseUid, List<String> conditionNames) {
        log.info("saveUserConditions — firebaseUid: {}, conditionCount: {}",
                firebaseUid, conditionNames != null ? conditionNames.size() : 0);
        User user = userMapper.findByFirebaseUid(firebaseUid);
        if (user == null) {
            log.warn("User not found for firebaseUid: {} when saving health conditions", firebaseUid);
            throw new NotFoundException(ErrorCodes.ERR_USER_NOT_FOUND,
                    "User not found with firebaseUid: " + firebaseUid);
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
