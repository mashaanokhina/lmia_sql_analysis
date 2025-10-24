SELECT count(*) FROM lmia.merged_lmia;
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
USE lmia;
CREATE TABLE lmia (
Province_Territory Varchar (255),
Program_Stream Varchar (255),
Employer Varchar (255),
Address Varchar (255),
Occupation Varchar (255),
Incorporate_Status Varchar (255),
Approved_LMIAs Integer,
Approved_Positions Integer,
_Quarter Integer,
_Year Integer
);
LOAD DATA INFILE 'D:/Analytics/Glocal/SQL_LMIA_project/csv/merged_lmia.csv'
INTO TABLE lmia
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

