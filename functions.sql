--LV getCheckSum function
CREATE OR REPLACE FUNCTION GetCheckSumLV(personCode IN VARCHAR2) 
RETURN VARCHAR2 IS  
  v_checkSum NUMBER; 
  v_temp_pk varchar2(11);
  type NumberVarray is varray(10) of NUMERIC(10);
  v_checkSumSubsequence NumberVarray;
BEGIN  
   v_checkSum := 0; 
   v_checkSumSubsequence := NumberVarray(1, 6, 3, 7, 9, 10, 5, 8, 4, 2);
   v_temp_pk := SUBSTR(REPLACE(personCode,'-',''), 1, 10);
   FOR i IN 1..LENGTH(v_temp_pk)
   LOOP
     v_checkSum := v_checkSum +  TO_NUMBER(substr(v_temp_pk,i,1)) * v_checkSumSubsequence(i);
   END LOOP;
   v_checkSum := MOD(MOD((1101 - v_checkSum),11),10); 
   RETURN TO_CHAR(v_checkSum);  
END;
/
--LT getCheckSum function
CREATE OR REPLACE FUNCTION GetCheckSumLT_EE(personCode IN VARCHAR2) 
RETURN VARCHAR2 IS  
  v_checkSum NUMBER; 
  v_temp_pk varchar2(11);
  type NumberVarray is varray(10) of NUMERIC(10);
  v_checkSumSubsequence NumberVarray;
BEGIN  
   v_checkSum := 0; 
   v_checkSumSubsequence := NumberVarray(1, 2, 3, 4, 5, 6, 7, 8, 9, 1);
   v_temp_pk := SUBSTR(REPLACE(personCode,'-',''), 1, 10);
   FOR i IN 1..LENGTH(v_temp_pk)
   LOOP
     v_checkSum := v_checkSum +  TO_NUMBER(substr(v_temp_pk,i,1)) * v_checkSumSubsequence(i);
   END LOOP;
   v_checkSum := MOD(v_checkSum,11); 

   IF v_checkSum <> 10 THEN
       RETURN TO_CHAR(v_checkSum);
   ELSE 
      v_checkSumSubsequence := NumberVarray(3, 4, 5, 6, 7, 8, 9, 1, 2, 3);
      FOR i IN 1..LENGTH(v_temp_pk)
      LOOP
        v_checkSum := v_checkSum +  TO_NUMBER(substr(v_temp_pk,i,1)) * v_checkSumSubsequence(i);
      END LOOP;
      v_checkSum := MOD(v_checkSum,11); 
      IF v_checkSum <> 10 THEN
        RETURN TO_CHAR(v_checkSum);
      ELSE
        RETURN TO_CHAR(0);  
      END IF;
   END IF;
   RETURN TO_CHAR(v_checkSum);  
END; 
/
--LV, LT PersonCodeValidation
CREATE OR REPLACE FUNCTION PersonCodeValidation( countryCode IN VARCHAR2, personCode IN VARCHAR2) 
RETURN VARCHAR2 IS  
  v_validationResult VARCHAR2 (100); 
  v_temp_pk varchar2(12);
  v_lv_reg_ex CONSTANT VARCHAR2(200) := '^(0[1-9]|[12]\d|3[01])(0[1-9]|1[0-2])([0-9][0-9])([0-2])\d{4}';
  v_lv_new_reg_ex CONSTANT VARCHAR2(200) := '^32\d{9}';
  v_lt_ee_reg_ex CONSTANT VARCHAR2(200) := '^([1-6])([0-9][0-9])(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{4}';
BEGIN  
  CASE CountryCode 
  WHEN 'LV' THEN 
    IF LENGTH(personCode) > 12 THEN
       RETURN 'FALSE';
    END IF;
    v_temp_pk := REPLACE(personCode,'-','');
    IF REGEXP_LIKE (v_temp_pk, v_lv_reg_ex , 'i') OR REGEXP_LIKE (v_temp_pk, v_lv_new_reg_ex , 'i') THEN
      IF GetCheckSumLV(v_temp_pk) = substr(v_temp_pk,-1) THEN
        RETURN 'TRUE';
      ELSE 
        RETURN 'FALSE';
      END IF;
      ELSE 
        RETURN 'FALSE';
    END IF;
  WHEN 'LT' THEN
    IF LENGTH(personCode) > 11 THEN
       RETURN 'FALSE';
    END IF;
    v_temp_pk := personCode;
    IF REGEXP_LIKE (v_temp_pk, v_lt_ee_reg_ex, 'i') THEN
      IF GetCheckSumLT(v_temp_pk) = substr(v_temp_pk,-1) THEN
        RETURN 'TRUE';
      ELSE 
        RETURN 'FALSE';
      END IF;
      ELSE 
        RETURN 'FALSE';
    END IF;
  WHEN 'EE' THEN
    IF LENGTH(personCode) > 11 THEN
       RETURN 'FALSE';
    END IF;
    v_temp_pk := personCode;
    IF REGEXP_LIKE (v_temp_pk, v_lt_ee_reg_ex, 'i') THEN
      IF GetCheckSumLT_EE(v_temp_pk) = substr(v_temp_pk,-1) THEN
        RETURN 'TRUE';
      ELSE 
        RETURN 'FALSE';
      END IF;
      ELSE 
        RETURN 'FALSE';
    END IF;
  ELSE 
   RETURN 'FALSE'; 
  END CASE; 
   RETURN v_validationResult;  
END; 
/
-- LT GetGender, because from LV pk can't get gender
CREATE OR REPLACE FUNCTION GetGender( countryCode IN VARCHAR2, personCode IN VARCHAR2) 
RETURN VARCHAR2 IS  
  v_genderCode varchar2(1);
BEGIN  
  IF PersonCodeValidation(countryCode, personCode) = 'TRUE' THEN
    CASE countryCode 
    WHEN 'LV' THEN 
      RETURN 'Cant get gender from Latvian personal code';
    WHEN 'LT' THEN
      v_genderCode := SUBSTR(personCode, 1, 1);
      IF v_genderCode IN ('1', '3', '5') THEN
        RETURN 'Man'; 
      END IF;
      IF v_genderCode IN ('2', '4', '6') THEN
        RETURN 'Woman'; 
      END IF;
	WHEN 'EE' THEN
      v_genderCode := SUBSTR(personCode, 1, 1);
      IF v_genderCode IN ('1', '3', '5') THEN
	    RETURN 'Man'; 
      END IF;
      IF v_genderCode IN ('2', '4', '6') THEN
	    RETURN 'Woman'; 
      END IF;
    ELSE 
      RETURN 'Not valid'; 
    END CASE; 
  ELSE 
    RETURN 'Person code is invalid';
  END IF;
END; 
/
CREATE OR REPLACE FUNCTION GetLVBirthDate(countryCode IN VARCHAR2, personCode IN VARCHAR2)
RETURN VARCHAR2 IS  
  v_birthDate varchar2(100);
  v_birthYear varchar2(4);
  v_yearCode varchar2(1);

BEGIN
  IF PersonCodeValidation(countryCode, personCode) = 'TRUE' THEN
      IF substr(personCode,1,2) = '32' THEN
	    RETURN 'Cant get birth date for pk starting from 32';
	  END IF;
      v_yearCode := SUBSTR(personCode, -5,1);      
      IF v_yearCode = '0'  THEN
        v_birthYear := '18' || SUBSTR(personCode, 5,2);
      ELSIF v_yearCode = '1' THEN
        v_birthYear := '19' || SUBSTR(personCode, 5,2);
      ELSIF v_yearCode = '2'  THEN
        v_birthYear := '20' || SUBSTR(personCode, 5,2);
      END IF;
      v_birthDate := SUBSTR(personCode, 1,2) || '.' || SUBSTR(personCode, 3,2) || '.'  || v_birthYear;
      RETURN v_birthDate; 
  ELSE 
    RETURN 'Person code is invalid';
  END IF; 	  
END;
/
CREATE OR REPLACE FUNCTION GetLT_EEBirthDate(countryCode IN VARCHAR2, personCode IN VARCHAR2)
RETURN VARCHAR2 IS  
  v_birthDate varchar2(100);
  v_birthYear varchar2(4);
  v_yearCode varchar2(1);
BEGIN 
  IF PersonCodeValidation(countryCode, personCode) = 'TRUE' THEN
	  v_yearCode := SUBSTR(personCode, 1,1);      
	  IF v_yearCode IN ('1', '2')  THEN
		v_birthYear := '18' || SUBSTR(personCode, 2,2);
	  ELSIF v_yearCode IN ('3', '4')  THEN
		v_birthYear := '19' || SUBSTR(personCode, 2,2);
	  ELSIF v_yearCode IN ('5', '6')  THEN
		v_birthYear := '20' || SUBSTR(personCode, 2,2);
	  END IF;
	  v_birthDate := SUBSTR(personCode, 6,2) || '.' || SUBSTR(personCode, 4,2) || '.' || v_birthYear;
	  RETURN v_birthDate; 
  ELSE 
    RETURN 'Person code is invalid';
  END IF; 	  
END;
/
-- GetBirthDate for LV or LT
CREATE OR REPLACE FUNCTION GetBirthDate( countryCode IN VARCHAR2, personCode IN VARCHAR2) 
RETURN VARCHAR2 IS  
  v_birthDate varchar2(100);
  v_birthYear varchar2(4);
  v_yearCode varchar2(1);
BEGIN  
	CASE countryCode 
	WHEN 'LV' THEN 
	  RETURN GetLVBirthDate(countryCode, personCode);
	WHEN 'LT' THEN
	  RETURN GetLTBirthDate(countryCode, personCode);
	WHEN 'EE' THEN
	  RETURN GetLTBirthDate(countryCode, personCode);
	ELSE 
	  RETURN 'Not valid country'; 
	END CASE; 

END; 
/

