package com.example.demo

import org.junit.jupiter.api.Test
import org.mockito.BDDMockito.given
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.http.MediaType
import org.springframework.test.context.bean.override.mockito.MockitoBean
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.post

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
                    createdAt = "2026-03-21T06:45:58Z",
                    customerRequest = "Frontend review needs live task data from the backend",
                    requestedWork = "Connect the Vue task board to backend task APIs",
                    targetDeliveryDate = "2026-03-28",
                    buildEstimate = "2 engineering days",
                    owner = "Sky"
                ),
                SampleTaskResponse(
                    id = 2,
                    title = "Prepare k3s test namespace",
                    status = "READY",
                    createdAt = "2026-03-21T06:45:58Z",
                    customerRequest = "Platform review needs a reusable QA namespace check",
                    requestedWork = "Prepare a k3s namespace smoke path for PR environments",
                    targetDeliveryDate = "2026-03-25",
                    buildEstimate = "1 engineering day",
                    owner = "Sky"
                )
            )
        )

        mockMvc.get("/api/tasks")
            .andExpect {
                status { isOk() }
                jsonPath("$.length()") { value(2) }
                jsonPath("$[0].title") { value("Wire backend to frontend") }
                jsonPath("$[0].customerRequest") { value("Frontend review needs live task data from the backend") }
                jsonPath("$[1].status") { value("READY") }
                jsonPath("$[1].owner") { value("Sky") }
            }
    }

    @Test
    fun `create task returns created business task`() {
        given(
            sampleTaskService.createTask(
                CreateBusinessTaskRequest(
                    customerRequest = "Customer needs release planning visibility",
                    requestedWork = "Prepare a release planning task card",
                    targetDeliveryDate = java.time.LocalDate.parse("2026-04-02"),
                    buildEstimate = "2 engineering days",
                    owner = "Sky"
                )
            )
        ).willReturn(
            SampleTaskResponse(
                id = 3,
                title = "Prepare a release planning task card",
                status = "TODO",
                createdAt = "2026-03-21T06:45:58Z",
                customerRequest = "Customer needs release planning visibility",
                requestedWork = "Prepare a release planning task card",
                targetDeliveryDate = "2026-04-02",
                buildEstimate = "2 engineering days",
                owner = "Sky"
            )
        )

        mockMvc.post("/api/tasks") {
            contentType = MediaType.APPLICATION_JSON
            content = """
                {
                  "customerRequest": "Customer needs release planning visibility",
                  "requestedWork": "Prepare a release planning task card",
                  "targetDeliveryDate": "2026-04-02",
                  "buildEstimate": "2 engineering days",
                  "owner": "Sky"
                }
            """.trimIndent()
        }.andExpect {
            status { isCreated() }
            jsonPath("$.status") { value("TODO") }
            jsonPath("$.requestedWork") { value("Prepare a release planning task card") }
            jsonPath("$.owner") { value("Sky") }
        }
    }

    @Test
    fun `create task returns validation errors for missing fields`() {
        mockMvc.post("/api/tasks") {
            contentType = MediaType.APPLICATION_JSON
            content = """
                {
                  "customerRequest": "",
                  "requestedWork": "",
                  "buildEstimate": "",
                  "owner": ""
                }
            """.trimIndent()
        }.andExpect {
            status { isBadRequest() }
            jsonPath("$.code") { value("VALIDATION_ERROR") }
            jsonPath("$.fieldErrors.customerRequest") { value("Customer request is required") }
            jsonPath("$.fieldErrors.requestedWork") { value("Requested work is required") }
            jsonPath("$.fieldErrors.targetDeliveryDate") { value("Delivery date is required") }
            jsonPath("$.fieldErrors.owner") { value("Owner is required") }
            jsonPath("$.fieldErrors.buildEstimate") { value("Build estimate is required") }
        }
    }
}
