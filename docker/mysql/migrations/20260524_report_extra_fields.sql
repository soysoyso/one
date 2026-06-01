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

CALL add_column_if_missing('pothole_photo', 'img_path', 'varchar(1000) NULL');
CALL add_column_if_missing('pothole_photo', 'img_name', 'varchar(500) NULL');
CALL add_column_if_missing('pothole_photo', 'sort_ord', 'int DEFAULT 0');
SET @photo_copy_sql = (
    SELECT IF(COUNT(*) = 3,
        'UPDATE pothole_photo SET img_path = COALESCE(img_path, file_path), img_name = COALESCE(img_name, file_name), sort_ord = COALESCE(sort_ord, sort_no) WHERE (img_path IS NULL OR img_name IS NULL OR sort_ord IS NULL)',
        'SELECT 1'
    )
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'pothole_photo'
      AND COLUMN_NAME IN ('file_path', 'file_name', 'sort_no')
);
PREPARE stmt FROM @photo_copy_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CALL add_column_if_missing('pothole_work_equipment', 'sort_ord', 'int NULL');
CALL add_column_if_missing('pothole_work_equipment', 'equip_name', 'varchar(200) NULL');
CALL add_column_if_missing('pothole_work_equipment', 'own_qty', 'int NULL');
CALL add_column_if_missing('pothole_work_equipment', 'use_qty', 'int NULL');
CALL add_column_if_missing('pothole_work_equipment', 'remark', 'varchar(500) NULL');

CALL add_column_if_missing('pothole_work_personnel', 'sort_ord', 'int NULL');
CALL add_column_if_missing('pothole_work_personnel', 'person_name', 'varchar(200) NULL');
CALL add_column_if_missing('pothole_work_personnel', 'dept_name', 'varchar(200) NULL');
CALL add_column_if_missing('pothole_work_personnel', 'labor_cost', 'decimal(14,2) NULL');

CALL add_column_if_missing('pothole_work_material', 'sort_ord', 'int NULL');
CALL add_column_if_missing('pothole_work_material', 'material_name', 'varchar(200) NULL');
CALL add_column_if_missing('pothole_work_material', 'spec', 'varchar(200) NULL');
CALL add_column_if_missing('pothole_work_material', 'unit', 'varchar(50) NULL');
CALL add_column_if_missing('pothole_work_material', 'use_qty', 'decimal(12,2) NULL');
CALL add_column_if_missing('pothole_work_material', 'remain_qty', 'decimal(12,2) NULL');
CALL add_column_if_missing('pothole_work_material', 'amount', 'decimal(14,2) NULL');

CALL add_column_if_missing('pothole_work_scope', 'sort_ord', 'int NULL');
CALL add_column_if_missing('pothole_work_scope', 'width_m', 'decimal(12,2) NULL');
CALL add_column_if_missing('pothole_work_scope', 'height_m', 'decimal(12,2) NULL');
CALL add_column_if_missing('pothole_work_scope', 'area_m2', 'decimal(12,2) NULL');
CALL add_column_if_missing('pothole_work_scope', 'depth_cm', 'decimal(12,2) NULL');
CALL add_column_if_missing('pothole_work_scope', 'span_m', 'decimal(12,2) NULL');

DROP PROCEDURE IF EXISTS add_column_if_missing;
