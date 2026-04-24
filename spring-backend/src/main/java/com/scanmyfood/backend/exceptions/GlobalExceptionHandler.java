package com.scanmyfood.backend.exceptions;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.scanmyfood.backend.constants.ErrorCodes;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MissingRequestHeaderException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import java.time.LocalDateTime;

/**
 * Centralized exception handler for all controllers.
 * Returns a consistent, industry-standard {@link ErrorResponse} envelope.
 */
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    // ─────────────────────────────────────────────────────────────────
    //  Error Response envelope
    // ─────────────────────────────────────────────────────────────────

    /**
     * Standard error response body returned for every error.
     *
     * <pre>
     * {
     *   "status"      : 404,
     *   "error"       : "Not Found",
     *   "errorCode"   : "ERR_1101",
     *   "description" : "User not found.",
     *   "message"     : "No user exists with firebase uid: abc123",
     *   "path"        : "/api/users/user",
     *   "timestamp"   : "2024-01-15T10:30:00"
     * }
     * </pre>
     */
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record ErrorResponse(
            int status,
            String error,
            String errorCode,
            String description,
            String message,
            String path,
            @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
            LocalDateTime timestamp
    ) {
        public static ErrorResponse of(HttpStatus httpStatus,
                                       String errorCode,
                                       String message,
                                       String path) {
            return new ErrorResponse(
                    httpStatus.value(),
                    httpStatus.getReasonPhrase(),
                    errorCode,
                    ErrorCodes.descriptionOf(errorCode),
                    message,
                    path,
                    LocalDateTime.now()
            );
        }
    }

    // ─────────────────────────────────────────────────────────────────
    //  Application exceptions
    // ─────────────────────────────────────────────────────────────────

    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFoundException(
            NotFoundException ex, WebRequest request) {
        log.warn("Resource not found: {}", ex.getMessage());
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(ErrorResponse.of(
                        HttpStatus.NOT_FOUND,
                        ex.getErrorCode(),
                        ex.getMessage(),
                        extractPath(request)));
    }

    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<ErrorResponse> handleBadRequestException(
            BadRequestException ex, WebRequest request) {
        log.warn("Bad request: {}", ex.getMessage());
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ErrorResponse.of(
                        HttpStatus.BAD_REQUEST,
                        ex.getErrorCode(),
                        ex.getMessage(),
                        extractPath(request)));
    }

    // ─────────────────────────────────────────────────────────────────
    //  Spring / HTTP infrastructure exceptions
    // ─────────────────────────────────────────────────────────────────

    @ExceptionHandler(MissingRequestHeaderException.class)
    public ResponseEntity<ErrorResponse> handleMissingHeader(
            MissingRequestHeaderException ex, WebRequest request) {
        log.warn("Missing required header: {}", ex.getHeaderName());
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ErrorResponse.of(
                        HttpStatus.BAD_REQUEST,
                        ErrorCodes.ERR_MISSING_HEADER,
                        "Required header '" + ex.getHeaderName() + "' is missing.",
                        extractPath(request)));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ErrorResponse> handleUnreadableBody(
            HttpMessageNotReadableException ex, WebRequest request) {
        log.warn("Malformed request body: {}", ex.getMessage());
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ErrorResponse.of(
                        HttpStatus.BAD_REQUEST,
                        ErrorCodes.ERR_BAD_REQUEST,
                        "Request body is missing or malformed.",
                        extractPath(request)));
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ErrorResponse> handleMethodNotAllowed(
            HttpRequestMethodNotSupportedException ex, WebRequest request) {
        log.warn("Method not allowed: {}", ex.getMethod());
        return ResponseEntity
                .status(HttpStatus.METHOD_NOT_ALLOWED)
                .body(ErrorResponse.of(
                        HttpStatus.METHOD_NOT_ALLOWED,
                        ErrorCodes.ERR_METHOD_NOT_ALLOWED,
                        ex.getMessage(),
                        extractPath(request)));
    }

    @ExceptionHandler(HttpMediaTypeNotSupportedException.class)
    public ResponseEntity<ErrorResponse> handleUnsupportedMediaType(
            HttpMediaTypeNotSupportedException ex, WebRequest request) {
        log.warn("Unsupported media type: {}", ex.getContentType());
        return ResponseEntity
                .status(HttpStatus.UNSUPPORTED_MEDIA_TYPE)
                .body(ErrorResponse.of(
                        HttpStatus.UNSUPPORTED_MEDIA_TYPE,
                        ErrorCodes.ERR_UNSUPPORTED_MEDIA_TYPE,
                        ex.getMessage(),
                        extractPath(request)));
    }

    // ─────────────────────────────────────────────────────────────────
    //  Catch-all
    // ─────────────────────────────────────────────────────────────────

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(
            Exception ex, WebRequest request) {
        log.error("Unhandled exception at path {}: {}", extractPath(request), ex.getMessage(), ex);
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ErrorResponse.of(
                        HttpStatus.INTERNAL_SERVER_ERROR,
                        ErrorCodes.ERR_INTERNAL_SERVER_ERROR,
                        "An unexpected error occurred. Please try again later.",
                        extractPath(request)));
    }

    // ─────────────────────────────────────────────────────────────────
    //  Helpers
    // ─────────────────────────────────────────────────────────────────

    private String extractPath(WebRequest request) {
        // e.g. "uri=/api/users/user"  →  "/api/users/user"
        return request.getDescription(false).replace("uri=", "");
    }
}
