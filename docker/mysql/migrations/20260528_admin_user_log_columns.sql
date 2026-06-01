SET @admin_user_log_pwd_exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ADMIN_USER_LOG'
    AND COLUMN_NAME = 'USER_PWD'
);
SET @admin_user_log_pwd_sql := IF(
  @admin_user_log_pwd_exists = 0,
  'ALTER TABLE ADMIN_USER_LOG ADD COLUMN USER_PWD varchar(500) NULL AFTER USER_NM',
  'SELECT 1'
);
PREPARE admin_user_log_pwd_stmt FROM @admin_user_log_pwd_sql;
EXECUTE admin_user_log_pwd_stmt;
DEALLOCATE PREPARE admin_user_log_pwd_stmt;

SET @admin_user_log_reg_id_exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ADMIN_USER_LOG'
    AND COLUMN_NAME = 'REG_ID'
);
SET @admin_user_log_reg_id_sql := IF(
  @admin_user_log_reg_id_exists = 0,
  'ALTER TABLE ADMIN_USER_LOG ADD COLUMN REG_ID varchar(100) NULL',
  'SELECT 1'
);
PREPARE admin_user_log_reg_id_stmt FROM @admin_user_log_reg_id_sql;
EXECUTE admin_user_log_reg_id_stmt;
DEALLOCATE PREPARE admin_user_log_reg_id_stmt;

SET @admin_user_log_reg_dt_exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ADMIN_USER_LOG'
    AND COLUMN_NAME = 'REG_DT'
);
SET @admin_user_log_reg_dt_sql := IF(
  @admin_user_log_reg_dt_exists = 0,
  'ALTER TABLE ADMIN_USER_LOG ADD COLUMN REG_DT datetime NULL',
  'SELECT 1'
);
PREPARE admin_user_log_reg_dt_stmt FROM @admin_user_log_reg_dt_sql;
EXECUTE admin_user_log_reg_dt_stmt;
DEALLOCATE PREPARE admin_user_log_reg_dt_stmt;
