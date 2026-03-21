package com.example.demo

import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get

@WebMvcTest(HealthController::class)
class HealthControllerTest(
    @Autowired private val mockMvc: MockMvc
) {

    @Test
    fun `health endpoint returns workspace metadata`() {
        mockMvc.get("/api/health")
            .andExpect {
                status { isOk() }
                jsonPath("$.service") { value("example-backend") }
                jsonPath("$.workspace") { value("example-workspace") }
                jsonPath("$.status") { value("UP") }
            }
    }
}
