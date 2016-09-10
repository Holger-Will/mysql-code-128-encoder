DELIMITER $$
DROP FUNCTION IF EXISTS `TextTo128` $$
CREATE FUNCTION `TextTo128`(string VARCHAR(25)) RETURNS varchar(50) charset latin1 DETERMINISTIC
BEGIN
DECLARE ind integer;         /* index of character in string */
DECLARE input_length integer;    /* length of string */
DECLARE checksum integer;    /* checksum */
DECLARE mini integer;        /* the number of numeric characters */
DECLARE dummy integer;       /* user for two digit encoding */
DECLARE tableB BOOLEAN;      /* using code B or code C */
DECLARE code128 VARCHAR(50);


SET ind = 1;
SET code128 = '''';
SET input_length = LENGTH(string); /* return length of input string */
IF input_length < 1 THEN
  RETURN 'Argument Absent!!!';
ELSE
  WHILE ind <= input_length DO /*test for invalid characters*/
    IF (ASCII(SUBSTRING(string, ind, 1)) < 32) OR (ASCII(SUBSTRING(string, ind, 1)) > 126) THEN
      RETURN 'Argument invalide!!!';
    END IF;
    SET ind = ind + 1;
  END WHILE;
END IF;
SET ind = 0;
SET tableB = TRUE;
WHILE ind <= input_length DO  /*MAIN LOOP STARTS */
  IF (tableB = TRUE) THEN
    /* only use code C encoding if it results in shorter codes*/
    IF ((ind = 1) OR (ind+3 = input_length)) THEN
      SET mini = 4;
    ELSE
      SET mini = 6;
    END IF;
    SET mini = mini-1;
    IF ((ind + mini) <= input_length) THEN
      loop1: WHILE mini >= 0 DO
        IF (ASCII(SUBSTRING(string, ind+mini , 1)) < 48) OR (ASCII(SUBSTRING(string, ind+mini, 1)) > 57) THEN
          LEAVE loop1;
        END IF;
        SET mini = mini-1;
      END WHILE;
    END IF;
    /* there is a usable chain of digits switch to or use code C*/
    IF (mini < 0) THEN
      IF (ind = 1) THEN /* start with code C */
        SET code128 = CHAR(210 using latin1);
      ELSE /* switch to C */
        SET code128 = code128 & CHAR(205 using latin1);
      END IF;
      SET tableB = FALSE;
    ELSE
      IF (ind = 1) THEN /* Start with code B */
        SET code128 = CHAR(209 using latin1);
      END IF;
    END IF;
END IF;
IF (tableB = FALSE) THEN /* handle two digit conversion*/
  SET mini = 2;
  SET mini = mini-1;
  IF (ind + mini <= input_length) THEN
    loop2: WHILE mini >= 0 DO
      IF (ASCII(SUBSTRING(string, ind+mini , 1)) < 48) OR (ASCII(SUBSTRING(string, ind+mini, 1)) > 57) THEN
        LEAVE loop2;
      END IF;
      SET mini = mini-1;
    END WHILE;
  END IF;
  IF (mini < 0) THEN /* yes there ar two digits to encode */
    SET dummy = CAST(SUBSTRING(string, ind, 2) AS SIGNED);
    IF (dummy < 95) THEN
      SET dummy = dummy + 32;
    ELSE
      SET dummy = dummy + 105;
    END IF;
    SET code128 = CONCAT(code128, CHAR(dummy using latin1));
    SET ind = ind + 2;
  ELSE
    /*-- switch to code B*/
    SET code128 = CONCAT(code128, CHAR(205 using latin1));
    SET tableB = TRUE;
  END IF;
END IF;
IF (tableB = TRUE) THEN
  SET code128 = CONCAT(code128, SUBSTRING(string, ind, 1));
  SET ind = ind + 1;
END IF;
END WHILE; /* MAIN LOOP ENDS */
/* checksum calculation */
SET ind = 1;
WHILE ind <= LENGTH(code128) DO
  SET dummy = ASCII(CONVERT(SUBSTRING(code128, ind, 1) using latin1));
  IF(dummy > 0) THEN
    IF (dummy < 127) THEN
      SET dummy = dummy - 32;
    ELSE
      SET dummy = dummy - 105;
    END IF;
  END IF;
  IF (ind = 1) THEN
    SET checksum = dummy;
  END IF;
  SET checksum = mod(checksum + (ind-1) * dummy, 103);
  SET ind = ind + 1;
END WHILE;
/* turn checksum into corresponding ASCII Code*/
IF (checksum < 95) THEN
  SET checksum = checksum + 32;
ELSE
  SET checksum = checksum + 105;
END IF;
/* add the chacksum and stop code to the result*/
SET code128 = CONCAT(code128, CHAR(checksum using latin1) , CHAR(211 using latin1));
RETURN code128;
END $$
DELIMITER ;
