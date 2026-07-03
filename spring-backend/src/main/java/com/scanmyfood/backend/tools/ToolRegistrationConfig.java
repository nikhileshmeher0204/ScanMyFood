package com.scanmyfood.backend.tools;

import org.springframework.ai.tool.ToolCallback;
import org.springframework.ai.tool.ToolCallbackProvider;
import org.springframework.ai.tool.method.MethodToolCallbackProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ToolRegistrationConfig {

    @Bean
    public ToolCallbackProvider scanMyFoodTools(
            GetUserProfileTool userProfileTool,
            LogMealViaDescriptionTool logMealTool,
            SaveScannedFoodIntakeTool saveScannedFoodIntakeTool) {
        return MethodToolCallbackProvider.builder()
                .toolObjects(userProfileTool, logMealTool, saveScannedFoodIntakeTool)
                .build();
    }
}
