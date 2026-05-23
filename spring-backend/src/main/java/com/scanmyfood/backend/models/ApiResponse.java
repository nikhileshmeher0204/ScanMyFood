package com.scanmyfood.backend.models;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {
    private String status;
    private String responseCode;
    private String message;
    private T data;

    public static <T> ApiResponse<T> success(String responseCode, T data) {
        return ApiResponse.<T>builder()
                .status("success")
                .responseCode(responseCode)
                .data(data)
                .build();
    }

    public static <T> ApiResponse<T> success(String responseCode, String message) {
        return ApiResponse.<T>builder()
                .status("success")
                .responseCode(responseCode)
                .message(message)
                .build();
    }


    public static <T> ApiResponse<T> success(T data, String responseCode, String message) {
        return ApiResponse.<T>builder()
                .status("success")
                .responseCode(responseCode)
                .message(message)
                .data(data)
                .build();
    }

    public static <T> ApiResponse<T> error(String responseCode, String message) {
        return ApiResponse.<T>builder()
                .status("error")
                .responseCode(responseCode)
                .message(message)
                .build();
    }
}