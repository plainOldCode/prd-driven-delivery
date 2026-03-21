package com.example.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class ExampleBackendApplication

fun main(args: Array<String>) {
    runApplication<ExampleBackendApplication>(*args)
}
