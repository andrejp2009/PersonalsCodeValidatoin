CREATE TABLE PersonCode (   
ID   INT              NOT NULL,   
PersonCode VARCHAR2 (20)     NOT NULL,   
COUNTRY VARCHAR2 (2),
CORRECT NUMBER (1),
Description VARCHAR2(200),
PRIMARY KEY (ID));  

delete from PersonCode;
INSERT INTO PersonCode VALUES(1,'030573-17273', 'LV', 1, 'Correct');
INSERT INTO PersonCode VALUES(2,'03057317273', 'LV', 1, 'Correct without -');
INSERT INTO PersonCode VALUES(3,'030573-37273', 'LV', 0, 'Incorrect checksum'); 
INSERT INTO PersonCode VALUES(4,'030573-17276', 'LV', 0, 'Incorrect checksum'); 
INSERT INTO PersonCode VALUES(5,'220626-32447888', 'LV', 0, 'Incorrect too much simbmols');
INSERT INTO PersonCode VALUES(6,'326517345812', 'LV', 0, 'Incorrect too much simbmols for PK starting with 32');
INSERT INTO PersonCode VALUES(7,'32651734586', 'LV', 0, 'Incorrect checksum for PK starting with 32');
INSERT INTO PersonCode VALUES(8,'32651734582', 'LV', 0, 'Correct checksum for PK starting with 32');

INSERT INTO PersonCode VALUES(9,'39310123982', 'LT', 1, 'Correct man');
INSERT INTO PersonCode VALUES(10,'393101239822', 'LT', 0, 'Incorrect too much simbmols');
INSERT INTO PersonCode VALUES(11,'46712093573', 'LT', 1, 'Correct woman');

INSERT INTO PersonCode VALUES(12,'39006038081', 'EE', 1, 'Correct man');
INSERT INTO PersonCode VALUES(13,'39006038081111', 'EE', 0, 'Incorrect too much simbmols');
INSERT INTO PersonCode VALUES(14,'45802159269', 'EE', 1, 'Correct woman');

select * from PersonCode;

select pk.*  
       ,CASE COUNTRY
       WHEN 'LV' THEN GetCheckSumLV(pk.personcode)
       WHEN 'LT' THEN GetCheckSumLT_EE(pk.personcode)
       WHEN 'EE' THEN GetCheckSumLT_EE(pk.personcode)
       END AS GetCheckSum
       ,GetGender(pk.country, pk.personcode)
              ,GetBirthDate(pk.country, pk.personcode)
       ,PersonCodeValidation(pk.country, pk.personcode)
from PersonCode pk
    where pk.country = 'EE'
     order by ID asc;

