package com.scanmyfood.backend.services;

import com.scanmyfood.backend.models.SaveScannedFoodInput;
import com.scanmyfood.backend.models.SaveScannedLabelInput;
import com.scanmyfood.backend.models.UserIntakeOutput;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public interface UserIntakeService {

    public void saveScannedFoodIntake(SaveScannedFoodInput saveIntakeInput, String imageAccessUrl);

    public void saveScannedLabelIntake(SaveScannedLabelInput scannedLabelInput, String imageAccessUrl);

    public UserIntakeOutput getUserIntake(String userId, LocalDate date) throws Exception;
}
