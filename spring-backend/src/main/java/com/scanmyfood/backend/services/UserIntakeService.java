package com.scanmyfood.backend.services;

import com.scanmyfood.backend.models.SaveScannedFoodInput;
import com.scanmyfood.backend.models.SaveScannedLabelInput;
import com.scanmyfood.backend.models.UserIntakeOutput;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public interface UserIntakeService {

    public int saveScannedFoodIntake(SaveScannedFoodInput saveIntakeInput, String imageAccessUrl) throws Exception;

    public int saveScannedLabelIntake(SaveScannedLabelInput scannedLabelInput, String imageAccessUrl) throws Exception;

    public UserIntakeOutput getUserIntake(String userId, LocalDate date) throws Exception;

    public void updateDailyIntakeImage(int dailyIntakeId, String imageAccessUrl) throws Exception;
}
