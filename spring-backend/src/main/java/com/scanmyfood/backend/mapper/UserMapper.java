package com.scanmyfood.backend.mapper;

import com.scanmyfood.backend.models.HealthMetric;
import com.scanmyfood.backend.models.User;
import com.scanmyfood.backend.models.UserPreference;
import org.apache.ibatis.annotations.*;

@Mapper
public interface UserMapper {

    @Select("SELECT * FROM users WHERE firebase_uid = #{firebaseUid}")
    @Results({
        @Result(property = "id", column = "id"),
        @Result(property = "firebaseUid", column = "firebase_uid"),
        @Result(property = "email", column = "email"),
        @Result(property = "isOnboardingComplete", column = "is_onboarding_complete"),
        @Result(property = "displayName", column = "display_name"),
        @Result(property = "createdAt", column = "created_at"),
        @Result(property = "updatedAt", column = "updated_at")
    })
    User findByFirebaseUid(@Param("firebaseUid") String firebaseUid);

    @Select("SELECT COUNT(*) > 0 FROM users WHERE firebase_uid = #{firebaseUid}")
    boolean existsByFirebaseUid(@Param("firebaseUid") String firebaseUid);

    @Insert("INSERT INTO users (firebase_uid, email, display_name, is_onboarding_complete, created_at, updated_at) " +
            "VALUES (#{firebaseUid}, #{email}, #{displayName}, #{isOnboardingComplete}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    void insertUser(User user);

    @Update("UPDATE users SET display_name = #{displayName}, is_onboarding_complete = #{isOnboardingComplete}, updated_at = CURRENT_TIMESTAMP " +
            "WHERE firebase_uid = #{firebaseUid}")
    void updateUser(User user);

    @Update("UPDATE users SET is_onboarding_complete = #{status}, updated_at = CURRENT_TIMESTAMP WHERE firebase_uid = #{firebaseUid}")
    void updateOnboardingStatus(@Param("firebaseUid") String firebaseUid, @Param("status") boolean status);

    // User Preference Operations
    @Select("SELECT * FROM user_preferences WHERE firebase_uid = #{firebaseUid}")
    @Results({
        @Result(property = "firebaseUid", column = "firebase_uid"),
        @Result(property = "dietaryPreference", column = "dietary_preference"),
        @Result(property = "country", column = "country")
    })
    UserPreference findPreferenceByFirebaseUid(@Param("firebaseUid") String firebaseUid);

    @Insert("INSERT INTO user_preferences (firebase_uid, dietary_preference, country) " +
            "VALUES (#{firebaseUid}, #{preference.dietaryPreference}, #{preference.country})")
    void insertUserPreference(@Param("firebaseUid") String firebaseUid, @Param("preference") UserPreference preference);

    @Update("UPDATE user_preferences SET dietary_preference = #{preference.dietaryPreference}, country = #{preference.country} " +
            "WHERE firebase_uid = #{firebaseUid}")
    void updateUserPreference(@Param("firebaseUid") String firebaseUid, @Param("preference") UserPreference preference);

    // Health Metric Operations
    @Select("SELECT * FROM health_metrics WHERE firebase_uid = #{firebaseUid}")
    @Results({
        @Result(property = "firebaseUid", column = "firebase_uid"),
        @Result(property = "heightFeet", column = "height_feet"),
        @Result(property = "heightInches", column = "height_inches"),
        @Result(property = "weightKg", column = "weight_kg"),
        @Result(property = "goal", column = "goal")
    })
    HealthMetric findHealthMetricByFirebaseUid(@Param("firebaseUid") String firebaseUid);

    @Insert("INSERT INTO health_metrics (firebase_uid, height_feet, height_inches, weight_kg, goal) " +
            "VALUES (#{firebaseUid}, #{metric.heightFeet}, #{metric.heightInches}, #{metric.weightKg}, #{metric.goal})")
    void insertHealthMetric(@Param("firebaseUid") String firebaseUid, @Param("metric") HealthMetric metric);

    @Update("UPDATE health_metrics SET height_feet = #{metric.heightFeet}, height_inches = #{metric.heightInches}, " +
            "weight_kg = #{metric.weightKg}, goal = #{metric.goal} WHERE firebase_uid = #{firebaseUid}")
    void updateHealthMetric(@Param("firebaseUid") String firebaseUid, @Param("metric") HealthMetric metric);
}
