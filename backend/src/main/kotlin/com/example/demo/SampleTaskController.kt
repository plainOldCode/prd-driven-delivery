package com.example.demo

import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Size
import org.springframework.http.HttpStatus
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate
import org.springframework.jdbc.support.GeneratedKeyHolder
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import java.time.LocalDate

@RestController
@RequestMapping("/api/tasks")
class SampleTaskController(
    private val sampleTaskService: SampleTaskService
) {

    @GetMapping
    fun listTasks(): List<SampleTaskResponse> = sampleTaskService.findAll()

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun createTask(@Valid @RequestBody request: CreateBusinessTaskRequest): SampleTaskResponse {
        return sampleTaskService.createTask(request)
    }
}

@org.springframework.stereotype.Service
class SampleTaskService(
    private val jdbcClient: JdbcClient,
    private val namedParameterJdbcTemplate: NamedParameterJdbcTemplate
) {

    fun findAll(): List<SampleTaskResponse> {
        return jdbcClient.sql(
            """
            SELECT id, title, status, created_at, customer_request, requested_work,
                   target_delivery_date, build_estimate, owner_name
            FROM sample_task
            ORDER BY id
            """.trimIndent()
        ).query(::mapTask).list()
    }

    fun createTask(request: CreateBusinessTaskRequest): SampleTaskResponse {
        val normalizedRequestedWork = request.requestedWork.requireText()
        val keyHolder = GeneratedKeyHolder()

        namedParameterJdbcTemplate.update(
            """
            INSERT INTO sample_task (
              title,
              status,
              customer_request,
              requested_work,
              target_delivery_date,
              build_estimate,
              owner_name
            ) VALUES (
              :title,
              :status,
              :customerRequest,
              :requestedWork,
              :targetDeliveryDate,
              :buildEstimate,
              :ownerName
            )
            """.trimIndent(),
            MapSqlParameterSource()
                .addValue("title", toTitle(normalizedRequestedWork))
                .addValue("status", "TODO")
                .addValue("customerRequest", request.customerRequest.requireText())
                .addValue("requestedWork", normalizedRequestedWork)
                .addValue("targetDeliveryDate", requireNotNull(request.targetDeliveryDate))
                .addValue("buildEstimate", request.buildEstimate.requireText())
                .addValue("ownerName", request.owner.requireText()),
            keyHolder,
            arrayOf("id")
        )

        val taskId = keyHolder.key?.toLong() ?: error("Task insert did not return an ID")
        return findById(taskId) ?: error("Task $taskId was created but could not be read back")
    }

    private fun findById(id: Long): SampleTaskResponse? {
        return jdbcClient.sql(
            """
            SELECT id, title, status, created_at, customer_request, requested_work,
                   target_delivery_date, build_estimate, owner_name
            FROM sample_task
            WHERE id = :id
            """.trimIndent()
        ).param("id", id).query(::mapTask).optional().orElse(null)
    }

    @Suppress("UNUSED_PARAMETER")
    private fun mapTask(rs: java.sql.ResultSet, rowNumber: Int): SampleTaskResponse {
        return SampleTaskResponse(
            id = rs.getLong("id"),
            title = rs.getString("title"),
            status = rs.getString("status"),
            createdAt = rs.getTimestamp("created_at").toInstant().toString(),
            customerRequest = rs.getString("customer_request"),
            requestedWork = rs.getString("requested_work"),
            targetDeliveryDate = rs.getDate("target_delivery_date").toLocalDate().toString(),
            buildEstimate = rs.getString("build_estimate"),
            owner = rs.getString("owner_name")
        )
    }

    private fun toTitle(requestedWork: String): String {
        val compact = requestedWork.replace("\\s+".toRegex(), " ").trim()
        return if (compact.length <= 100) compact else compact.take(97).trimEnd() + "..."
    }
}

data class CreateBusinessTaskRequest(
    @field:NotBlank(message = "Customer request is required")
    @field:Size(max = 255, message = "Customer request must be 255 characters or fewer")
    val customerRequest: String?,
    @field:NotBlank(message = "Requested work is required")
    @field:Size(max = 255, message = "Requested work must be 255 characters or fewer")
    val requestedWork: String?,
    @field:NotNull(message = "Delivery date is required")
    val targetDeliveryDate: LocalDate?,
    @field:NotBlank(message = "Build estimate is required")
    @field:Size(max = 60, message = "Build estimate must be 60 characters or fewer")
    val buildEstimate: String?,
    @field:NotBlank(message = "Owner is required")
    @field:Size(max = 80, message = "Owner must be 80 characters or fewer")
    val owner: String?
)

data class SampleTaskResponse(
    val id: Long,
    val title: String,
    val status: String,
    val createdAt: String,
    val customerRequest: String,
    val requestedWork: String,
    val targetDeliveryDate: String,
    val buildEstimate: String,
    val owner: String
)

private fun String?.requireText(): String = requireNotNull(this).trim()
