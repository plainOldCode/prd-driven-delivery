package com.example.demo

import org.springframework.http.HttpStatus
import org.springframework.http.converter.HttpMessageNotReadableException
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class TaskApiExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleValidationFailure(exception: MethodArgumentNotValidException): TaskApiErrorResponse {
        return TaskApiErrorResponse(
            code = "VALIDATION_ERROR",
            message = "Task input is invalid",
            fieldErrors = exception.bindingResult.fieldErrors.associate { fieldError ->
                fieldError.field to (fieldError.defaultMessage ?: "Invalid value")
            }
        )
    }

    @ExceptionHandler(HttpMessageNotReadableException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleUnreadableBody(): TaskApiErrorResponse {
        return TaskApiErrorResponse(
            code = "INVALID_REQUEST",
            message = "Request body could not be read",
            fieldErrors = emptyMap()
        )
    }
}

data class TaskApiErrorResponse(
    val code: String,
    val message: String,
    val fieldErrors: Map<String, String>
)
