CREATE TABLE CUSTOMER_DETAILS
( DL_NUMBER CHAR(8) NOT NULL,
  FNAME VARCHAR(25) NOT NULL,
  MNAME VARCHAR(15),
  LNAME VARCHAR(25) NOT NULL,
  PHONE_NUMBER NUMBER(10) NOT NULL,
  EMAIL_ID VARCHAR(30) NOT NULL,
  STREET VARCHAR(30) NOT NULL,
  CITY VARCHAR(20) NOT NULL,
  STATE_NAME VARCHAR(20) NOT NULL,
  ZIPCODE NUMBER(5) NOT NULL,
  MEMBERSHIP_TYPE CHAR(1) DEFAULT 'N' NOT NULL,
  MEMBERSHIP_ID CHAR(5),
  CONSTRAINT CUSTOMERPK
  PRIMARY KEY (DL_NUMBER)
);

CREATE TABLE CAR_CATEGORY
( CATEGORY_NAME VARCHAR(25) NOT NULL,
  NO_OF_LUGGAGE INTEGER NOT NULL,
  NO_OF_PERSON INTEGER NOT NULL,
  COST_PER_DAY NUMBER(5,2) NOT NULL,
  LATE_FEE_PER_HOUR NUMBER(5,2) NOT NULL,
  CONSTRAINT CARCATEGORYPK
  PRIMARY KEY (CATEGORY_NAME)
);

CREATE TABLE LOCATION_DETAILS
( LOCATION_ID CHAR(4) NOT NULL,
  LOCATION_NAME VARCHAR(50) NOT NULL,
  STREET VARCHAR(30) NOT NULL,
  CITY VARCHAR(20) NOT NULL,
  STATE_NAME VARCHAR(20) NOT NULL,
  ZIPCODE NUMBER(5) NOT NULL,
  CONSTRAINT LOCATIONPK
  PRIMARY KEY (LOCATION_ID)
);

CREATE TABLE CAR
( REGISTRATION_NUMBER CHAR(7) NOT NULL,
  MODEL_NAME VARCHAR(25) NOT NULL,
  MAKE VARCHAR(25) NOT NULL,
  MODEL_YEAR NUMBER(4) NOT NULL,
  MILEAGE INTEGER NOT NULL,
  CAR_CATEGORY_NAME VARCHAR(25) NOT NULL,
  LOC_ID CHAR(4) NOT NULL,
  AVAILABILITY_FLAG CHAR(1) NOT NULL,
  CONSTRAINT CARPK
  PRIMARY KEY (REGISTRATION_NUMBER),
  CONSTRAINT CARFK1
  FOREIGN KEY (CAR_CATEGORY_NAME) REFERENCES CAR_CATEGORY(CATEGORY_NAME),
  CONSTRAINT CARFK2
  FOREIGN KEY (LOC_ID) REFERENCES LOCATION_DETAILS(LOCATION_ID)
);

CREATE TABLE DISCOUNT_DETAILS
( DISCOUNT_CODE CHAR(4) NOT NULL,
  DISCOUNT_NAME VARCHAR(25) NOT NULL,
  EXPIRY_DATE DATE NOT NULL,
  DISCOUNT_PERCENTAGE NUMBER(4,2)  NOT NULL,
  CONSTRAINT DISCOUNTPK
  PRIMARY KEY (DISCOUNT_CODE),
  CONSTRAINT DISCOUNTSK
  UNIQUE (DISCOUNT_NAME)
);

CREATE TABLE RENTAL_CAR_INSURANCE
( INSURANCE_CODE CHAR(4) NOT NULL,
  INSURANCE_NAME VARCHAR(50) NOT NULL,
  COVERAGE_TYPE VARCHAR(200) NOT NULL,
  COST_PER_DAY NUMBER(4,2) NOT NULL,
  CONSTRAINT INSURANCEPK
  PRIMARY KEY (INSURANCE_CODE),
  CONSTRAINT INSURANCESK
  UNIQUE (INSURANCE_NAME)
);

CREATE TABLE BOOKING_DETAILS
( BOOKING_ID CHAR(5) NOT NULL,
  FROM_DT_TIME TIMESTAMP NOT NULL,
  RET_DT_TIME TIMESTAMP NOT NULL,
  AMOUNT NUMBER(10,2) NOT NULL,
  BOOKING_STATUS CHAR(1) NOT NULL,
  PICKUP_LOC  CHAR(4) NOT NULL,
  DROP_LOC CHAR(4) NOT NULL,
  REG_NUM CHAR(7) NOT NULL,
  DL_NUM CHAR(8) NOT NULL,
  INS_CODE CHAR(4),
  ACT_RET_DT_TIME TIMESTAMP,
  DISCOUNT_CODE CHAR(4),
  CONSTRAINT BOOKINGPK
  PRIMARY KEY (BOOKING_ID),
  CONSTRAINT BOOKINGFK1
  FOREIGN KEY (PICKUP_LOC) REFERENCES LOCATION_DETAILS(LOCATION_ID),
  CONSTRAINT BOOKINGFK2
  FOREIGN KEY (DROP_LOC) REFERENCES LOCATION_DETAILS(LOCATION_ID),
  CONSTRAINT BOOKINGFK3
  FOREIGN KEY (REG_NUM) REFERENCES CAR(REGISTRATION_NUMBER),
  CONSTRAINT BOOKINGFK4
  FOREIGN KEY (DL_NUM) REFERENCES CUSTOMER_DETAILS(DL_NUMBER),
  CONSTRAINT BOOKINGFK5
  FOREIGN KEY (INS_CODE) REFERENCES RENTAL_CAR_INSURANCE(INSURANCE_CODE),
  CONSTRAINT BOOKINGFK6
  FOREIGN KEY (DISCOUNT_CODE) REFERENCES DISCOUNT_DETAILS(DISCOUNT_CODE)
);

CREATE TABLE BILLING_DETAILS
( BILL_ID CHAR(6) NOT NULL,
  BILL_DATE DATE NOT NULL,
  BILL_STATUS CHAR(1) NOT NULL,
  DISCOUNT_AMOUNT NUMBER(10,2) NOT NULL,
  TOTAL_AMOUNT NUMBER(10,2) NOT NULL,
  TAX_AMOUNT NUMBER(10,2) NOT NULL,
  BOOKING_ID CHAR(5) NOT NULL,
  TOTAL_LATE_FEE NUMBER(10,2) NOT NULL,
  CONSTRAINT BILLINGPK
  PRIMARY KEY (BILL_ID),
  CONSTRAINT BILLINGFK1
  FOREIGN KEY (BOOKING_ID) REFERENCES BOOKING_DETAILS(BOOKING_ID)
);



DROP TABLE BILLING_DETAILS;
DROP TABLE BOOKING_DETAILS;
DROP TABLE RENTAL_CAR_INSURANCE;
DROP TABLE DISCOUNT_DETAILS;
DROP TABLE CAR;
DROP TABLE LOCATION_DETAILS;
DROP TABLE CAR_CATEGORY;
DROP TABLE CUSTOMER_DETAILS;

DROP VIEW TABLE1;
DROP VIEW TABLE2;

  CREATE OR REPLACE VIEW TABLE1 AS 
  SELECT LC.LID AS LOCATIONID, LC.CNAME AS CATNAME ,COUNT(C.REGISTRATION_NUMBER) AS NOOFCARS 
  FROM (SELECT L.LOCATION_ID AS LID, CC.CATEGORY_NAME AS CNAME FROM 
  CAR_CATEGORY CC CROSS JOIN LOCATION_DETAILS L) LC LEFT OUTER JOIN CAR C 
  ON LC.CNAME = C.CAR_CATEGORY_NAME AND LC.LID = C.LOC_ID GROUP BY LC.LID, 
  LC.CNAME ORDER BY LC.LID;
  
  CREATE OR REPLACE VIEW TABLE2 AS
  SELECT BC.PLOC AS PICKLOC,BC.CNAME AS CNAMES, SUM(BL.TOTAL_AMOUNT) AS AMOUNT FROM 
  (SELECT B.PICKUP_LOC AS PLOC, C1.CAR_CATEGORY_NAME AS CNAME, B.BOOKING_ID AS BID 
  FROM BOOKING_DETAILS B INNER JOIN CAR C1 ON B.REG_NUM = C1.REGISTRATION_NUMBER) BC
  INNER JOIN BILLING_DETAILS BL ON BC.BID = BL.BOOKING_ID 
  WHERE (to_date (SYSDATE,'dd-MM-yyyy') - to_date(BL.BILL_DATE,'dd-MM-yyyy')) <=30 
  GROUP BY BC.PLOC,BC.CNAME ORDER BY BC.PLOC;
