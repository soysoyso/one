USE road_sos;

ALTER TABLE daily_checklist_item
  ADD COLUMN option_values varchar(1000) NULL AFTER input_type;
