package com.example.demo

import org.springframework.beans.factory.annotation.Value
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Instant

@RestController
@RequestMapping("/api")
class HealthController(
    @Value("\${spring.application.name}") private val appName: String,
    @Value("\${workspace.name}") private val workspaceName: String,
    @Value("\${spring.profiles.active:default}") private val activeProfile: String
) {

    @GetMapping("/health")
    fun health(): HealthResponse {
        return HealthResponse(
            service = appName,
            workspace = workspaceName,
            profile = activeProfile,
            status = "UP",
            timestamp = Instant.now().toString()
        )
    }
}

data class HealthResponse(
    val service: String,
    val workspace: String,
    val profile: String,
    val status: String,
    val timestamp: String
)
