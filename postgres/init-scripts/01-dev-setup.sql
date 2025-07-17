-- Example initialization script for development
-- This file will be automatically executed when the PostgreSQL container starts
-- Add your database schema, test data, or development-specific setup here

-- Create development-specific tables
CREATE TABLE IF NOT EXISTS dev_logs (
    id SERIAL PRIMARY KEY,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some sample data for development
INSERT INTO dev_logs (message) VALUES ('PostgreSQL container initialized for development');

-- Create a development user with limited permissions
-- CREATE USER dev_user WITH PASSWORD 'dev_password';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO dev_user;
