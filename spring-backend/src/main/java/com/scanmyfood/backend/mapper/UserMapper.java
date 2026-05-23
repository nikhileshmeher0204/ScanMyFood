package com.scanmyfood.backend.mapper;

import com.scanmyfood.backend.dto.UserCheckResponse;
import com.scanmyfood.backend.models.User;
import org.apache.ibatis.annotations.*;

@Mapper
public interface UserMapper {

    @Select("SELECT * FROM users WHERE user_id = #{userId}")
    @Results({
        @Result(property = "userId", column = "user_id"),
        @Result(property = "email", column = "email"),
        @Result(property = "isOnboardingComplete", column = "is_onboarding_complete"),
        @Result(property = "displayName", column = "display_name"),
        @Result(property = "createdAt", column = "created_at"),
        @Result(property = "updatedAt", column = "updated_at"),
        @Result(property = "dietaryPreference", column = "dietary_preference"),
        @Result(property = "country", column = "country"),
        @Result(property = "heightFeet", column = "height_feet"),
        @Result(property = "heightInches", column = "height_inches"),
        @Result(property = "weightKg", column = "weight_kg"),
        @Result(property = "goal", column = "goal")
    })
    User findByUserId(@Param("userId") String userId);

    @Select("SELECT user_id, is_onboarding_complete FROM users WHERE user_id = #{userId}")
    UserCheckResponse existsByUserId(@Param("userId") String userId);

    @Insert("INSERT INTO users (user_id, email, display_name, is_onboarding_complete, created_at, updated_at, " +
            "dietary_preference, country, height_feet, height_inches, weight_kg, goal) " +
            "VALUES (#{userId}, #{email}, #{displayName}, #{isOnboardingComplete}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, " +
            "#{dietaryPreference}, #{country}, #{heightFeet}, #{heightInches}, #{weightKg}, #{goal})")
    void insertUser(User user);

    @Update("UPDATE users SET display_name = #{displayName}, is_onboarding_complete = #{isOnboardingComplete}, updated_at = CURRENT_TIMESTAMP, " +
            "dietary_preference = #{dietaryPreference}, country = #{country}, " +
            "height_feet = #{heightFeet}, height_inches = #{heightInches}, weight_kg = #{weightKg}, goal = #{goal} " +
            "WHERE user_id = #{userId}")
    void updateUser(User user);

    @Update("UPDATE users SET is_onboarding_complete = #{status}, updated_at = CURRENT_TIMESTAMP WHERE user_id = #{userId}")
    void updateOnboardingStatus(@Param("userId") String userId, @Param("status") boolean status);

    @Update("UPDATE users SET dietary_preference = #{dietary}, country = #{country}, updated_at = CURRENT_TIMESTAMP " +
            "WHERE user_id = #{userId}")
    void updatePreferences(@Param("userId") String userId, @Param("dietary") User.DietType dietary, @Param("country") String country);

    @Update("UPDATE users SET height_feet = #{hFeet}, height_inches = #{hInches}, weight_kg = #{weight}, goal = #{goal}, " +
            "updated_at = CURRENT_TIMESTAMP WHERE user_id = #{userId}")
    void updateHealthMetrics(@Param("userId") String userId, @Param("hFeet") Integer hFeet,
                             @Param("hInches") Integer hInches, @Param("weight") Double weight, @Param("goal") User.Goal goal);
}
