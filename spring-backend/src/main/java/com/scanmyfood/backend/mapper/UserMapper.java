package com.scanmyfood.backend.mapper;

import com.scanmyfood.backend.models.User;
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
        @Result(property = "updatedAt", column = "updated_at"),
        @Result(property = "dietaryPreference", column = "dietary_preference"),
        @Result(property = "country", column = "country"),
        @Result(property = "heightFeet", column = "height_feet"),
        @Result(property = "heightInches", column = "height_inches"),
        @Result(property = "weightKg", column = "weight_kg"),
        @Result(property = "goal", column = "goal")
    })
    User findByFirebaseUid(@Param("firebaseUid") String firebaseUid);

    @Select("SELECT COUNT(*) > 0 FROM users WHERE firebase_uid = #{firebaseUid}")
    boolean existsByFirebaseUid(@Param("firebaseUid") String firebaseUid);

    @Insert("INSERT INTO users (firebase_uid, email, display_name, is_onboarding_complete, created_at, updated_at, " +
            "dietary_preference, country, height_feet, height_inches, weight_kg, goal) " +
            "VALUES (#{firebaseUid}, #{email}, #{displayName}, #{isOnboardingComplete}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, " +
            "#{dietaryPreference}, #{country}, #{heightFeet}, #{heightInches}, #{weightKg}, #{goal})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    void insertUser(User user);

    @Update("UPDATE users SET display_name = #{displayName}, is_onboarding_complete = #{isOnboardingComplete}, updated_at = CURRENT_TIMESTAMP, " +
            "dietary_preference = #{dietaryPreference}, country = #{country}, " +
            "height_feet = #{heightFeet}, height_inches = #{heightInches}, weight_kg = #{weightKg}, goal = #{goal} " +
            "WHERE firebase_uid = #{firebaseUid}")
    void updateUser(User user);

    @Update("UPDATE users SET is_onboarding_complete = #{status}, updated_at = CURRENT_TIMESTAMP WHERE firebase_uid = #{firebaseUid}")
    void updateOnboardingStatus(@Param("firebaseUid") String firebaseUid, @Param("status") boolean status);

    @Update("UPDATE users SET dietary_preference = #{dietary}, country = #{country}, updated_at = CURRENT_TIMESTAMP " +
            "WHERE firebase_uid = #{firebaseUid}")
    void updatePreferences(@Param("firebaseUid") String firebaseUid, @Param("dietary") User.DietType dietary, @Param("country") String country);

    @Update("UPDATE users SET height_feet = #{hFeet}, height_inches = #{hInches}, weight_kg = #{weight}, goal = #{goal}, " +
            "updated_at = CURRENT_TIMESTAMP WHERE firebase_uid = #{firebaseUid}")
    void updateHealthMetrics(@Param("firebaseUid") String firebaseUid, @Param("hFeet") Integer hFeet, 
                             @Param("hInches") Integer hInches, @Param("weight") Double weight, @Param("goal") User.Goal goal);
}
