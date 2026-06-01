USE road_sos;

CREATE TABLE IF NOT EXISTS daily_check_photo (
  photo_id bigint NOT NULL AUTO_INCREMENT,
  check_id bigint NOT NULL,
  photo_gb varchar(20) NOT NULL,
  img_path varchar(1000),
  img_name varchar(500),
  sort_ord int DEFAULT 0,
  reg_dt datetime,
  PRIMARY KEY (photo_id),
  KEY idx_daily_check_photo_parent (check_id),
  KEY idx_daily_check_photo_gb (photo_gb)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
