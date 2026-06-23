package com.scanmyfood.backend.models;

public enum CountryCode {
    IN("IN"),
    US("US");

    private final String code;

    CountryCode(String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    }

    public static CountryCode fromCountryName(String countryName) {
        if (countryName == null) {
            return US;
        }
        String normalized = countryName.trim().toLowerCase();
        if (normalized.equals("india") || normalized.equals("in")) {
            return IN;
        }
        if (normalized.equals("united states") || normalized.equals("us") || normalized.equals("usa")
                || normalized.equals("united states of america")) {
            return US;
        }
        return US;
    }
}
