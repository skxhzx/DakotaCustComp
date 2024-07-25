      *----------------------------------------------------------------
      *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   245 Roosevelt Rd.  Bldg 8, Suite 51
      *   WEST CHICAGO, IL 60158
      *   (630) 562-0375
      *----------------------------------------------------------------
      *
      *  LOADR59  Verified Returned Trailer Equipment - Clean Up
      *  November 17,2008
      *  Jose G. Duque
      *
      *  Revisions:
     F*
     F*    03/10/11  JGD  6.40
     F*      - Created
      *
      *----------------------------------------------------------------
      *  File Specs
      *
     FLDRTEQ    IF   E           K DISK
     FPIRUSER1  IF   E           K DISK
      *
     FLDR26     O    E           K DISK
      *
      *----------------------------------------------------------------
     C     *ENTRY        PLIST
     C                   PARM                    $FDATE            8
     C                   PARM                    $TDATE            8
      *
      *----------------------------------------------------------------
     C                   READ      LTREC                                  LR
      *
     C                   MOVE      $FDATE        FRMDTE            8 0
     C                   MOVE      $TDATE        TODTE             8 0
      *
     C     *INLR         DOWNE     *ON
      *
      *  Skip records that do not fall within shift schedule.
     C     LTLDTE        IFEQ      FRMDTE
     C     LTLTIM        ANDLT     160000
     C                   GOTO      BYPASS
     C                   ENDIF
      *
     C     LTLDTE        IFEQ      TODTE
     C     LTLTIM        ANDGT     060000
     C                   GOTO      BYPASS
     C                   ENDIF
      *
     C                   Z-ADD     *ZEROS        EXCEPTIONS        5 0
     C                   ADD       LTSO1         EXCEPTIONS
     C                   ADD       LTSO2         EXCEPTIONS
     C                   ADD       LTSO3         EXCEPTIONS
     C                   ADD       LTSO4         EXCEPTIONS
     C                   ADD       LTSO5         EXCEPTIONS
     C                   ADD       LTSO6         EXCEPTIONS
     C                   ADD       LTSO7         EXCEPTIONS
     C                   ADD       LTSO8         EXCEPTIONS
     C                   ADD       LTSO9         EXCEPTIONS
      *
      *  Skip records that do not have exceptions or are records
      *  of a route trailer equipment that has not been returned yet.
     C     EXCEPTIONS    IFEQ      *ZEROS
     C                   GOTO      BYPASS
     C                   ENDIF
      *
     C     LTEMP#        CHAIN     PIRUSER1                           79
     C     *IN79         IFEQ      *OFF
     C                   EXSR      ZZFNAM
     C                   MOVEL     HLDNAM        LTEMPN
     C                   ELSE
     C                   MOVE      *BLANKS       LTEMPN
     C                   ENDIF
      *
     C                   WRITE     LTREC2
      *
     C     BYPASS        TAG
     C                   READ      LTREC                                  LR
     C                   ENDDO
     C*----------------------------------------------------------------
     C*
     C*  ZZFNAM   Format loader name.
     C*
     C*----------------------------------------------------------------
     CSR   ZZFNAM        BEGSR
     C*
     C                   MOVE      *BLANKS       FNAME
     C                   MOVE      *BLANKS       LNAME
     C                   MOVE      *BLANKS       HLDNAM
     C*
     C     ' '           SCAN      USFNAM        P1                2 0
     C     P1            SUBST     USFNAM:1      FNAME            12
     C     ' '           SCAN      USLNAM        P2                2 0
     C     P2            SUBST     USLNAM:1      LNAME            16
     C     FNAME         CAT       LNAME:1       HLDNAM           28
     C*
      *
     C                   ENDSR
