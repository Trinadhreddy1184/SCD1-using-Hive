use project_1;

truncate table day;

set global local_infile=1;

load data local infile '/home/saif/project_1/datasets/Day.csv' into table day FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';

update day set year_col=year(STR_TO_DATE(SUBSTRING_INDEX(entry_time,' ', 1),'%d/%b/%Y:%H:%i:%s'));
update day set month_col=month(STR_TO_DATE(SUBSTRING_INDEX(entry_time,' ', 1),'%d/%b/%Y:%H:%i:%s'));


