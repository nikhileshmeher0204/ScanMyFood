package com.scanmyfood.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableScheduling
@SpringBootApplication
public class ScanMyFoodBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(ScanMyFoodBackendApplication.class, args);
	}

}
