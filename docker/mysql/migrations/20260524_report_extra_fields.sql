USE road_sos;

DROP PROCEDURE IF EXISTS add_column_if_missing;
DELIMITER //
CREATE PROCEDURE add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND COLUMN_NAME = p_column_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE ', p_table_name, ' ADD COLUMN ', p_column_name, ' ', p_column_definition);
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//
DELIMITER ;

CALL add_column_if_missing('pothole', 'lane_info', 'varchar(200) NULL');
CALL add_column_if_missing('pothole', 'report_remark', 'text NULL');
CALL add_column_if_missing('pothole', 'work_qty', 'decimal(12,2) NULL');
CALL add_column_if_missing('pothole', 'convert_work_qty', 'decimal(12,2) NULL');
CALL add_column_if_missing('pothole', 'account_work_qty', 'decimal(12,2) NULL');

CALL add_column_if_missing('pothole_work_equipment', 'remark', 'varchar(500) NULL');
CALL add_column_if_missing('pothole_work_personnel', 'labor_cost', 'decimal(14,2) NULL');
CALL add_column_if_missing('pothole_work_material', 'remain_qty', 'decimal(12,2) NULL');
CALL add_column_if_missing('pothole_work_material', 'amount', 'decimal(14,2) NULL');

DROP PROCEDURE IF EXISTS add_column_if_missing;
