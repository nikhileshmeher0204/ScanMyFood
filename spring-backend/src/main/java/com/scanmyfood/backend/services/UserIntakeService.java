package com.scanmyfood.backend.services;

import com.scanmyfood.backend.models.SaveScannedFoodInput;
import org.springframework.stereotype.Service;

@Service
public interface UserIntakeService {

    public void saveIntake(SaveScannedFoodInput saveIntakeInput);

}
