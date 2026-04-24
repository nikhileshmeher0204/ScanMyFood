package com.scanmyfood.backend.constants;

/**
 * Industry-standard error codes and human-readable descriptions
 * for all application error scenarios.
 *
 * Naming convention: ERR_<DOMAIN>_<SPECIFIC_ISSUE>
 * Format           : 4-digit numeric suffix per domain range
 *
 *  1000-1099  →  Generic / Common
 *  1100-1199  →  User
 *  1200-1299  →  Auth / Firebase
 *  1300-1399  →  Product / AI Analysis
 *  1400-1499  →  Food Intake
 *  1500-1599  →  Health / Conditions
 *  9000-9099  →  Internal / Unexpected
 */
public final class ErrorCodes {

    private ErrorCodes() {
        // utility class – no instantiation
    }

    // ─────────────────────────────────────────────────────────────────
    // 1000  Generic / Common
    // ─────────────────────────────────────────────────────────────────
    public static final String ERR_NOT_FOUND              = "ERR_1001";
    public static final String ERR_BAD_REQUEST            = "ERR_1002";
    public static final String ERR_VALIDATION_FAILED      = "ERR_1003";
    public static final String ERR_MISSING_HEADER         = "ERR_1004";
    public static final String ERR_METHOD_NOT_ALLOWED     = "ERR_1005";
    public static final String ERR_UNSUPPORTED_MEDIA_TYPE = "ERR_1006";

    // ─────────────────────────────────────────────────────────────────
    // 1100  User
    // ─────────────────────────────────────────────────────────────────
    public static final String ERR_USER_NOT_FOUND         = "ERR_1101";
    public static final String ERR_USER_ALREADY_EXISTS    = "ERR_1102";
    public static final String ERR_USER_CREATE_FAILED     = "ERR_1103";
    public static final String ERR_ONBOARDING_FAILED      = "ERR_1104";
    public static final String ERR_PREFERENCES_SAVE_FAILED = "ERR_1105";
    public static final String ERR_HEALTH_METRICS_FAILED  = "ERR_1106";

    // ─────────────────────────────────────────────────────────────────
    // 1200  Auth / Firebase
    // ─────────────────────────────────────────────────────────────────
    public static final String ERR_AUTH_INVALID_TOKEN     = "ERR_1201";
    public static final String ERR_AUTH_TOKEN_EXPIRED     = "ERR_1202";
    public static final String ERR_AUTH_UNAUTHORIZED      = "ERR_1203";

    // ─────────────────────────────────────────────────────────────────
    // 1300  Product / AI Analysis
    // ─────────────────────────────────────────────────────────────────
    public static final String ERR_PRODUCT_NOT_FOUND      = "ERR_1301";
    public static final String ERR_AI_ANALYSIS_FAILED     = "ERR_1302";
    public static final String ERR_IMAGE_PROCESSING_FAILED = "ERR_1303";
    public static final String ERR_SCAN_SAVE_FAILED       = "ERR_1304";

    // ─────────────────────────────────────────────────────────────────
    // 1400  Food Intake
    // ─────────────────────────────────────────────────────────────────
    public static final String ERR_INTAKE_NOT_FOUND       = "ERR_1401";
    public static final String ERR_INTAKE_SAVE_FAILED     = "ERR_1402";
    public static final String ERR_INTAKE_FETCH_FAILED    = "ERR_1403";

    // ─────────────────────────────────────────────────────────────────
    // 1500  Health / Conditions
    // ─────────────────────────────────────────────────────────────────
    public static final String ERR_CONDITION_NOT_FOUND    = "ERR_1501";
    public static final String ERR_CONDITIONS_SAVE_FAILED = "ERR_1502";

    // ─────────────────────────────────────────────────────────────────
    // 9000  Internal / Unexpected
    // ─────────────────────────────────────────────────────────────────
    public static final String ERR_INTERNAL_SERVER_ERROR  = "ERR_9001";
    public static final String ERR_SERVICE_UNAVAILABLE    = "ERR_9002";


    // ─────────────────────────────────────────────────────────────────
    // Human-readable descriptions  (keyed by error code)
    // ─────────────────────────────────────────────────────────────────
    public static String descriptionOf(String errorCode) {
        return switch (errorCode) {
            case "ERR_1001" -> "The requested resource was not found.";
            case "ERR_1002" -> "The request is invalid or malformed.";
            case "ERR_1003" -> "One or more request fields failed validation.";
            case "ERR_1004" -> "A required request header is missing.";
            case "ERR_1005" -> "HTTP method not allowed for this endpoint.";
            case "ERR_1006" -> "Unsupported media type.";

            case "ERR_1101" -> "User not found.";
            case "ERR_1102" -> "A user with this identifier already exists.";
            case "ERR_1103" -> "Failed to create the user account.";
            case "ERR_1104" -> "Onboarding could not be completed.";
            case "ERR_1105" -> "User preferences could not be saved.";
            case "ERR_1106" -> "Health metrics could not be saved.";

            case "ERR_1201" -> "The provided authentication token is invalid.";
            case "ERR_1202" -> "The authentication token has expired.";
            case "ERR_1203" -> "Unauthorized access. Please authenticate.";

            case "ERR_1301" -> "Product not found.";
            case "ERR_1302" -> "AI analysis failed or returned an unexpected response.";
            case "ERR_1303" -> "Image could not be processed.";
            case "ERR_1304" -> "Scanned food data could not be saved.";

            case "ERR_1401" -> "Food intake record not found.";
            case "ERR_1402" -> "Food intake could not be saved.";
            case "ERR_1403" -> "Food intake records could not be fetched.";

            case "ERR_1501" -> "Health condition not found.";
            case "ERR_1502" -> "Health conditions could not be saved.";

            case "ERR_9001" -> "An unexpected internal server error occurred.";
            case "ERR_9002" -> "The service is temporarily unavailable.";
            default         -> "An error occurred.";
        };
    }
}
