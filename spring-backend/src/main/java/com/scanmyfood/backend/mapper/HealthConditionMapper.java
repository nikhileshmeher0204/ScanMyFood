package com.scanmyfood.backend.mapper;

import com.scanmyfood.backend.models.HealthCondition;
import com.scanmyfood.backend.models.UserHealthCondition;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Delete;
import java.util.List;

@Mapper
public interface HealthConditionMapper {
    List<HealthCondition> findAll();
    
    @Insert("INSERT INTO user_health_conditions (user_id, condition_name, date_added, status, severity) " +
            "VALUES (#{user.id}, #{condition.name}, #{dateAdded}, #{status}, #{severity})")
    void insertUserCondition(UserHealthCondition userHealthCondition);
    
    @Delete("DELETE FROM user_health_conditions WHERE user_id = #{userId}")
    void deleteUserConditions(@Param("userId") Long userId);
}
