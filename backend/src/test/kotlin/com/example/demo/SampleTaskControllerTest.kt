package com.example.demo

import org.junit.jupiter.api.Test
import org.mockito.BDDMockito.given
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.test.context.bean.override.mockito.MockitoBean
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get

@WebMvcTest(SampleTaskController::class)
class SampleTaskControllerTest(
    @Autowired private val mockMvc: MockMvc
) {

    @MockitoBean
    private lateinit var sampleTaskService: SampleTaskService

    @Test
    fun `tasks endpoint returns database rows`() {
        given(sampleTaskService.findAll()).willReturn(
            listOf(
                SampleTaskResponse(
                    id = 1,
                    title = "Wire backend to frontend",
                    status = "TODO",
                    createdAt = "2026-03-21T06:45:58Z"
                ),
                SampleTaskResponse(
                    id = 2,
                    title = "Prepare k3s test namespace",
                    status = "READY",
                    createdAt = "2026-03-21T06:45:58Z"
                )
            )
        )

        mockMvc.get("/api/tasks")
            .andExpect {
                status { isOk() }
                jsonPath("$.length()") { value(2) }
                jsonPath("$[0].title") { value("Wire backend to frontend") }
                jsonPath("$[1].status") { value("READY") }
            }
    }
}
