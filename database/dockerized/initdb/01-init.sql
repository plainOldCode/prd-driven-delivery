CREATE TABLE IF NOT EXISTS sample_task (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  status VARCHAR(30) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  customer_request VARCHAR(255) NOT NULL,
  requested_work VARCHAR(255) NOT NULL,
  target_delivery_date DATE NOT NULL,
  build_estimate VARCHAR(60) NOT NULL,
  owner_name VARCHAR(80) NOT NULL
);

INSERT INTO sample_task (
  title,
  status,
  customer_request,
  requested_work,
  target_delivery_date,
  build_estimate,
  owner_name
)
VALUES
  (
    "Wire backend to frontend",
    "TODO",
    "Frontend review needs live task data from the backend",
    "Connect the Vue task board to backend task APIs",
    "2026-03-28",
    "2 engineering days",
    "Sky"
  ),
  (
    "Prepare k3s test namespace",
    "READY",
    "Platform review needs a reusable QA namespace check",
    "Prepare a k3s namespace smoke path for PR environments",
    "2026-03-25",
    "1 engineering day",
    "Sky"
  );
