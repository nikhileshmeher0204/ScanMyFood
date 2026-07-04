package com.scanmyfood.backend.tools;

import com.scanmyfood.backend.models.UserIntakeOutput;
import com.scanmyfood.backend.services.UserIntakeService;
import com.scanmyfood.backend.utils.UserContextHolder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZonedDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class GetDailyIntakeTool {

    private static final Logger logger = LoggerFactory.getLogger(GetDailyIntakeTool.class);

    @Autowired
    private UserIntakeService userIntakeService;

    @Tool(description = "Fetches the user's logged meals and daily nutrient intake summary for a given date range.")
    public Map<String, Object> getDailyIntake(
            @ToolParam(description = "The start date for the query in YYYY-MM-DD format.") String fromDate,
            @ToolParam(description = "The end date for the query in YYYY-MM-DD format.") String toDate) {

        String userId = UserContextHolder.getUserId();
        if (userId == null || userId.isEmpty()) {
            userId = "dev-user-id";
        }

        logger.info("getDailyIntake tool called for user: {}, fromDate: {}, toDate: {}", userId, fromDate, toDate);

        LocalDate start = parseLocalDate(fromDate, LocalDate.now());
        LocalDate end = parseLocalDate(toDate, LocalDate.now());

        Map<String, Object> response = new LinkedHashMap<>();
        try {
            UserIntakeOutput result = userIntakeService.getUserIntakeRange(userId, start, end);
            response.put("success", true);
            response.put("daily_intakes", result.getDailyIntakes());
        } catch (Exception e) {
            logger.error("Failed to fetch daily intake range for tool: {}", e.getMessage(), e);
            response.put("success", false);
            response.put("message", "Failed to fetch daily intake: " + e.getMessage());
        }

        return response;
    }

    private LocalDate parseLocalDate(String dateStr, LocalDate defaultVal) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            return defaultVal;
        }
        String cleanDate = dateStr.trim();
        try {
            return LocalDate.parse(cleanDate);
        } catch (Exception e1) {
            try {
                return LocalDateTime.parse(cleanDate).toLocalDate();
            } catch (Exception e2) {
                try {
                    return OffsetDateTime.parse(cleanDate).toLocalDate();
                } catch (Exception e3) {
                    try {
                        return ZonedDateTime.parse(cleanDate).toLocalDate();
                    } catch (Exception e4) {
                        logger.warn("Could not parse date: '{}', falling back to default: {}", dateStr, defaultVal);
                        return defaultVal;
                    }
                }
            }
        }
    }
}
