-- ============================================================
-- MONITORING SCHEMA
-- ============================================================

CREATE SCHEMA IF NOT EXISTS monitoring;


-- ============================================================
-- PIPELINE RUN LOG
-- ============================================================

CREATE TABLE IF NOT EXISTS monitoring.pipeline_run_log (
    run_id VARCHAR(255) PRIMARY KEY,

    pipeline_name VARCHAR(100) NOT NULL,

    status VARCHAR(20) NOT NULL,

    started_at TIMESTAMP NOT NULL,

    finished_at TIMESTAMP,

    rows_processed BIGINT,

    error_message TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_pipeline_status
        CHECK (
            status IN (
                'RUNNING',
                'SUCCESS',
                'FAILED'
            )
        )
);