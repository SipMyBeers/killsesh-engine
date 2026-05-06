01  ACCT-RECORD.
           05  ACCT-ID               PIC X(10).
           05  ACCT-NAME             PIC X(50).
           05  ACCT-BALANCE          PIC S9(9)V99 COMP-3.
           05  ACCT-STATUS           PIC X(1).
           05  ACCT-OPEN-DATE        PIC X(8).
           05  ACCT-LAST-ACTIVITY    PIC X(8).
           05  ACCT-TYPE             PIC X(3).
           05  ACCT-INTEREST-RATE    PIC S9V999.
           05  ACCT-OVERDRAFT-LIMIT   PIC S9(7)V99.
           05  ACCT-CURRENCY         PIC X(3).
           05  ACCT-PIN             PIC X(4).
           05  ACCT-CREATED-TIME     PIC X(26).