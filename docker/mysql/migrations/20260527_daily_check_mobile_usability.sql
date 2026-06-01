SET @daily_check_title_exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'daily_check_log'
    AND COLUMN_NAME = 'check_title'
);
SET @daily_check_title_sql := IF(
  @daily_check_title_exists = 0,
  'ALTER TABLE daily_check_log ADD COLUMN check_title varchar(200) NULL AFTER check_date',
  'SELECT 1'
);
PREPARE daily_check_title_stmt FROM @daily_check_title_sql;
EXECUTE daily_check_title_stmt;
DEALLOCATE PREPARE daily_check_title_stmt;

SET @daily_check_memo_exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'daily_check_log_item'
    AND COLUMN_NAME = 'check_memo'
);
SET @daily_check_memo_sql := IF(
  @daily_check_memo_exists = 0,
  'ALTER TABLE daily_check_log_item ADD COLUMN check_memo varchar(1000) NULL AFTER check_value',
  'SELECT 1'
);
PREPARE daily_check_memo_stmt FROM @daily_check_memo_sql;
EXECUTE daily_check_memo_stmt;
DEALLOCATE PREPARE daily_check_memo_stmt;
