-- ============================================================================
-- Module Budget - Migration script to version 1.1.0
-- Copyright (C) 2025 KREATIV PROJECT MANAGEMENT SASU
-- Licence: GPL v3+ - https://www.gnu.org/licenses/gpl-3.0.html
-- ============================================================================
-- This script updates the database schema from pre-1.0.1 versions to 1.1.0
-- Execute this script if you get error: "Unknown column 'fk_budget_main'"
-- ============================================================================

-- Check if llx_budget_lines table exists with old structure
-- If the table has no fk_budget_main column, we need to add it

-- First, check if column exists (will cause error if it doesn't, but that's expected)
-- ALTER TABLE llx_budget_lines DROP COLUMN IF EXISTS fk_budget_main;

-- Add fk_budget_main column if it doesn't exist
SET @exist := (SELECT COUNT(*) 
               FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = DATABASE() 
               AND TABLE_NAME = 'llx_budget_lines' 
               AND COLUMN_NAME = 'fk_budget_main');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE llx_budget_lines ADD COLUMN fk_budget_main INTEGER NOT NULL AFTER entity',
    'SELECT "Column fk_budget_main already exists" AS message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add foreign key constraint if needed
SET @fk_exist := (SELECT COUNT(*) 
                  FROM information_schema.TABLE_CONSTRAINTS 
                  WHERE TABLE_SCHEMA = DATABASE() 
                  AND TABLE_NAME = 'llx_budget_lines' 
                  AND CONSTRAINT_NAME = 'fk_budget_lines_budget_main');

SET @sqlstmt := IF(@fk_exist = 0, 
    'ALTER TABLE llx_budget_lines ADD CONSTRAINT fk_budget_lines_budget_main FOREIGN KEY (fk_budget_main) REFERENCES llx_budget_main(rowid)',
    'SELECT "Foreign key fk_budget_lines_budget_main already exists" AS message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- For llx_budget_amounts table
-- ============================================================================

SET @exist := (SELECT COUNT(*) 
               FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = DATABASE() 
               AND TABLE_NAME = 'llx_budget_amounts' 
               AND COLUMN_NAME = 'fk_budget_line');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE llx_budget_amounts ADD COLUMN fk_budget_line INTEGER NOT NULL AFTER entity',
    'SELECT "Column fk_budget_line already exists" AS message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add index for fk_budget_line
SET @idx_exist := (SELECT COUNT(*) 
                   FROM information_schema.STATISTICS 
                   WHERE TABLE_SCHEMA = DATABASE() 
                   AND TABLE_NAME = 'llx_budget_amounts' 
                   AND INDEX_NAME = 'idx_budget_amounts_fk_budget_line');

SET @sqlstmt := IF(@idx_exist = 0, 
    'ALTER TABLE llx_budget_amounts ADD INDEX idx_budget_amounts_fk_budget_line (fk_budget_line)',
    'SELECT "Index idx_budget_amounts_fk_budget_line already exists" AS message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- For llx_budget_forecast_amounts table
-- ============================================================================

SET @exist := (SELECT COUNT(*) 
               FROM information_schema.COLUMNS 
               WHERE TABLE_SCHEMA = DATABASE() 
               AND TABLE_NAME = 'llx_budget_forecast_amounts' 
               AND COLUMN_NAME = 'fk_budget_line');

SET @sqlstmt := IF(@exist = 0, 
    'ALTER TABLE llx_budget_forecast_amounts ADD COLUMN fk_budget_line INTEGER NOT NULL AFTER entity',
    'SELECT "Column fk_budget_line already exists" AS message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add index for fk_budget_line
SET @idx_exist := (SELECT COUNT(*) 
                   FROM information_schema.STATISTICS 
                   WHERE TABLE_SCHEMA = DATABASE() 
                   AND TABLE_NAME = 'llx_budget_forecast_amounts' 
                   AND INDEX_NAME = 'idx_budget_forecast_amounts_fk_budget_line');

SET @sqlstmt := IF(@idx_exist = 0, 
    'ALTER TABLE llx_budget_forecast_amounts ADD INDEX idx_budget_forecast_amounts_fk_budget_line (fk_budget_line)',
    'SELECT "Index idx_budget_forecast_amounts_fk_budget_line already exists" AS message');

PREPARE stmt FROM @sqlstmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- Migration complete
-- ============================================================================
SELECT 'Migration to version 1.1.0 completed successfully!' AS Result;
