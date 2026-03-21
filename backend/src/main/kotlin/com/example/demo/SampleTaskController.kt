package com.example.demo

import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/tasks")
class SampleTaskController(
    private val sampleTaskService: SampleTaskService
) {

    @GetMapping
    fun listTasks(): List<SampleTaskResponse> = sampleTaskService.findAll()
}

@org.springframework.stereotype.Service
class SampleTaskService(
    private val jdbcClient: JdbcClient
) {

    fun findAll(): List<SampleTaskResponse> {
        return jdbcClient.sql(
            """
            SELECT id, title, status, created_at
            FROM sample_task
            ORDER BY id
            """.trimIndent()
        ).query { rs, _ ->
            SampleTaskResponse(
                id = rs.getLong("id"),
                title = rs.getString("title"),
                status = rs.getString("status"),
                createdAt = rs.getTimestamp("created_at").toInstant().toString()
            )
        }.list()
    }
}

data class SampleTaskResponse(
    val id: Long,
    val title: String,
    val status: String,
    val createdAt: String
)
