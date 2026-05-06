01  ACORD-AL3-RECORD.
    02  TRANSACTION-TYPE        PIC X(4).
    02  MESSAGE-ID              PIC X(8).
    02  TIMESTAMP               PIC X(26).
    02  STATE-CODE              PIC X(2).
    02  CARRIER-CODE            PIC X(4).
    02  POLICY-NUMBER           PIC X(20).
    
01  INSURED-NAME-DATA.
    02  NAME-TYPE               PIC X(1).
    02  INSURED-LAST-NAME       PIC X(30).
    02  INSURED-FIRST-NAME      PIC X(20).
    02  INSURED-MIDDLE-NAME     PIC X(15).
    02  INSURED-SUFFIX          PIC X(10).
    
01  INSURED-ADDRESS-DATA REDEFINES INSURED-NAME-DATA.
    02  ADDR-INDICATOR          PIC X(1).
    02  ADDRESS-LINE-1           PIC X(35).
    02  ADDRESS-LINE-2           PIC X(35).
    02  CITY                    PIC X(25).
    02  STATE                   PIC X(2).
    02  ZIP-CODE                PIC X(9).
    
01  POLICY-INFO.
    02  POLICY-EFF-DATE          PIC X(8).
    02  POLICY-EXP-DATE          PIC X(8).
    02  PREMIUM-AMOUNT           PIC S9(9)V99 COMP-3.
    02  PREMIUM-PAYMENT-MODE     PIC X(1).
    02  POLICY-STATUS           PIC X(1).
    
01  VEHICLE-DETAIL.
    02  VEHICLE-COUNT            PIC 9(2).
    02  VEHICLE-ENTRY OCCURS 0 TO 10 TIMES DEPENDING ON VEHICLE-COUNT.
        03  VIN                   PIC X(17).
        03  YEAR                 PIC 9(4).
        03  MAKE                 PIC X(15).
        03  MODEL                PIC X(20).
        03  VEHICLE-CLASS        PIC X(3).
        03  COVERAGE-AMOUNT      PIC S9(7)V99 COMP-3.
        03  DEDUCTIBLE-AMOUNT    PIC S9(5)V99 COMP-3.
        03  DRIVER-COUNT          PIC 9(1).
        03  DRIVER-LIST OCCURS 0 TO 5 TIMES DEPENDING ON DRIVER-COUNT.
            04  DRIVER-NAME       PIC X(30).
            04  DRIVER-LICENSE    PIC X(20).
            04  DRIVER-DOB        PIC X(8).
            04  DRIVER-RELATION   PIC X(1).
    
01  DRIVER-HISTORY REDEFINES VEHICLE-DETAIL.
    02  DH-RECORD-TYPE           PIC X(1).
    02  DH-LAST-UPDATE           PIC X(8).
    02  DH-ACCIDENT-COUNT        PIC 9(2).
    02  DH-VIOLATION-COUNT       PIC 9(2).
    02  DH-MVR-SCORE             PIC 9(3).
    02  DH-CLAIM-HISTORY         OCCURS 5 TIMES.
        03  DH-CLAIM-DATE        PIC X(8).
        03  DH-CLAIM-AMOUNT      PIC S9(6)V99 COMP-3.
        03  DH-CLAIM-TYPE        PIC X(2).
    
01  COVERAGE-OPTIONS.
    02  COVERAGE-COUNT           PIC 9(2).
    02  COVERAGE-ENTRY OCCURS 0 TO 8 TIMES DEPENDING ON COVERAGE-COUNT.
        03  COVERAGE-TYPE        PIC X(3).
        03  COVERAGE-LIMIT       PIC S9(7)V99 COMP-3.
        03  COVERAGE-PREMIUM     PIC S9(6)V99 COMP-3.
        03  COVERAGE-STATUS      PIC X(1).
        03  DEDUCTIBLE-APPLIED   PIC S9(5)V99 COMP-3.
    
01  SUPPLEMENTAL-EXPOSURES.
    02  SUPPLEMENT-COUNT         PIC 9(2).
    02  SUPPLEMENT-DATA OCCURS 0 TO 20 TIMES DEPENDING ON SUPPLEMENT-COUNT.
        03  SUPPLEMENT-TYPE      PIC X(4).
        03  SUPPLEMENT-CODE      PIC X(6).
        03  SUPPLEMENT-DESC      PIC X(50).
        03  SUPPLEMENT-AMOUNT    PIC S9(7)V99 COMP-3.
        03  EXCLUSION-IND        PIC X(1).
    
01  CLAIM-HISTORY-RECORD.
    02  TOTAL-CLAIMS             PIC 9(3).
    02  CLAIM-DETAILS OCCURS 0 TO 15 TIMES DEPENDING ON TOTAL-CLAIMS.
        03  CLAIM-DATE            PIC X(8).
        03  CLAIM-TYPE            PIC X(2).
        03  CLAIM-AMOUNT          PIC S9(8)V99 COMP-3.
        03  CLAIM-STATUS          PIC X(1).
        03  CLAIM-DESCRIPTION     PIC X(100).
        03  LOSS-DATE             PIC X(8).
        03  REPORT-DATE           PIC X(8).
    
01  BILLING-ACCOUNT.
    02  BILL-ACCOUNT-NUMBER      PIC X(15).
    02  BILL-PAYMENT-TYPE        PIC X(1).
    02  BILL-CREDIT-CARD         PIC X(16).
    02  BILL-EXPIRY              PIC X(4).
    02  BILL-AUTH-CODE           PIC X(10).
    02  LAST-PAYMENT-DATE        PIC X(8).
    02  LAST-PAYMENT-AMOUNT      PIC S9(7)V99 COMP-3.
    02  BALANCE-DUE              PIC S9(8)V99 COMP-3.
    02  PAYMENT-HISTORY          OCCURS 12 TIMES.
        03  PAY-DATE             PIC X(8).
        03  PAY-AMOUNT           PIC S9(6)V99 COMP-3.
        03  PAY-RESULT            PIC X(2).
    
01  NOTES-AND-REMARKS.
    02  NOTE-COUNT               PIC 9(2).
    02  NOTE-ENTRY OCCURS 0 TO 10 TIMES DEPENDING ON NOTE-COUNT.
        03  NOTE-DATE            PIC X(8).
        03  NOTE-AUTHOR          PIC X(20).
        03  NOTE-TYPE             PIC X(1).
        03  NOTE-TEXT            PIC X(200).
        03  NOTE-STATUS          PIC X(1).