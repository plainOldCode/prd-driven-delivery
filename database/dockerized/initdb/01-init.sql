CREATE TABLE IF NOT EXISTS sample_task (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  status VARCHAR(30) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO sample_task (title, status)
VALUES
  ("Wire backend to frontend", "TODO"),
  ("Prepare k3s test namespace", "READY");
