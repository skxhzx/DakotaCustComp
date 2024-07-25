     F*----------------------------------------------------------------
     F*   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  LOADR60I  Creaate Returned Trailer Equipment Detail file-by Equip
     F*
     F*  January 20, 2009
     F*  Jose G. Duque
     F*
     F*  Revisions:
     F*
     F*    03/10/11  JGD  6.40
     F*      - Created
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Not on file/End of file indicator
     F*  90        Overflow Indicator
     F*  9X        Top of page and level X continues.
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FLDR26     IP   E           K DISK
     F*
     FLDRHHDR   IF   E           K DISK
     FPIRUSER1  IF   E           K DISK
     F*
     FLDR26C    O    E           K DISK
     I*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D*----------------------------------------------------------------
     D*  Constants
     D DESC1           C                   CONST('BLANKETS       ')
     D DESC2           C                   CONST('BULKHEADS      ')
     D DESC3           C                   CONST('BARS           ')
     D DESC4           C                   CONST('IC BINS-SMALL  ')
     D DESC5           C                   CONST('IC BINS-MEDIUM ')
     D DESC6           C                   CONST('IC BINS-LARGE  ')
     D DESC7           C                   CONST('SEA FOOD BINS  ')
     D DESC8           C                   CONST('STAGED PALLETS ')
     D DESC9           C                   CONST('TOTAL PALLETS  ')
     F*
     I*----------------------------------------------------------------
     D*
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
     C                   EXSR      ZRDETL
     C*----------------------------------------------------------------
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*  *INZSR  Initialization subrotine
     C*----------------------------------------------------------------
     C*
     C     *INZSR        BEGSR
      *
     C     HDRKEY        KLIST
     C                   KFLD                    LTWHSE
     C                   KFLD                    LTRTE
     C                   KFLD                    LTRTID
      *
     C                   SUB       1             NEG1              2 0
      *
     C                   ENDSR
     C*----------------------------------------------------------------
     C     ZRDETL        BEGSR
     C*----------------------------------------------------------------
      *
     C     LTEMP#        IFEQ      9717
     C     LTLB1         ANDEQ     2
     C     LTSO3         ANDEQ     2
     C                   MOVE      'YES'         Y                 1
     C                   ENDIF
      *
     C     LTRTE         IFNE      SAVRTE
     C     LTRTID        ANDNE     SAVRTI
     C     HDRKEY        CHAIN     LDRHHDR                            79
     C     *IN79         IFEQ      *OFF
     C                   MOVEL     LTRTE         SAVRTE            5
     C                   MOVEL     LTRTID        SAVRTI            5
     C                   MOVEL     LHHRTE        SAVRTE            5
      *  Set name of loader that loaded equipment
     C                   MOVEL     LTEMPN        LTLODR
      *  Get loading door number
     C                   MOVE      LHHDOR        LTDOOR
     C*
     C                   MOVE      '*CMDMDY '    $CVCMD
     C                   MOVE      LHHSTD        $CVD8I
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
      *  Load date
     C                   Z-ADD     $CVD6O        LTLODT
     C*
     C                   MOVE      '*CMDMDY '    $CVCMD
     C                   MOVE      LTRDTE        $CVD8I
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
      *  Return date
     C                   Z-ADD     $CVD6O        LTRTDT
     C*
      *  Driver name
     C                   MOVEL     LTDNAM        LTDRVR
      *
      *  Find name of user who verified the equipment return
     C     LTREMP        CHAIN     PIRUSER1                           79
     C     *IN79         IFEQ      *ON
     C                   MOVE      *BLANKS       LTRTRN
     C                   ELSE
     C                   EXSR      ZZFNAM
     C                   MOVEL     HLDNAM        LTRTRN
     C                   ENDIF
      *
     C                   ENDIF
     C                   ENDIF
      *
      *
     C     LTSO1         IFNE      *ZEROS
     C                   Z-ADD     LTWHSE        LTWHS
     C                   MOVEL     SAVRTE        LTRTE#
     C                   MOVEL     DESC1         LTEQUP
     C                   MOVE      LTEMPN        LTLODR
     C                   MOVE      LTDNAM        LTDRVR
     C                   Z-ADD     LTBK1         LTLOAQ
     C                   Z-ADD     LTBK2         LTRTRQ
     C                   Z-ADD     *ZEROS        LTSHRT
     C                   Z-ADD     *ZEROS        LTOVER
     C     LTBK1         IFLT      LTBK2
     C     LTBK2         SUB       LTBK1         LTOVER
     C                   ELSE
     C     LTBK1         SUB       LTBK2         LTSHRT
     C                   ENDIF
     C*  Write LDR26 record.
     C                   WRITE     LTREC4
     C*>                 CLEAR                   LTREC4
     C                   ENDIF
     C*
      *
     C     LTSO2         IFNE      *ZEROS
     C                   Z-ADD     LTWHSE        LTWHS
     C                   MOVEL     SAVRTE        LTRTE#
     C                   MOVEL     DESC2         LTEQUP
     C                   MOVE      LTEMPN        LTLODR
     C                   MOVE      LTDNAM        LTDRVR
     C                   Z-ADD     LTBH1         LTLOAQ
     C                   Z-ADD     LTBH2         LTRTRQ
     C                   Z-ADD     *ZEROS        LTSHRT
     C                   Z-ADD     *ZEROS        LTOVER
     C     LTBH1         IFLT      LTBH2
     C     LTBH2         SUB       LTBH1         LTOVER
     C                   ELSE
     C     LTBH1         SUB       LTBH2         LTSHRT
     C                   ENDIF
     C*  Write LDR27 record.
     C                   WRITE     LTREC4
     C*>                 CLEAR                   LTREC4
     C                   ENDIF
     C*
      *
     C     LTSO3         IFNE      *ZEROS
     C                   Z-ADD     LTWHSE        LTWHS
     C                   MOVEL     SAVRTE        LTRTE#
     C                   MOVEL     DESC3         LTEQUP
     C                   MOVE      LTEMPN        LTLODR
     C                   MOVE      LTDNAM        LTDRVR
     C                   Z-ADD     LTLB1         LTLOAQ
     C                   Z-ADD     LTLB2         LTRTRQ
     C                   Z-ADD     *ZEROS        LTSHRT
     C                   Z-ADD     *ZEROS        LTOVER
     C     LTLB1         IFLT      LTLB2
     C     LTLB2         SUB       LTLB1         LTOVER
     C                   ELSE
     C     LTLB1         SUB       LTLB2         LTSHRT
     C                   ENDIF
     C*  Write LDR27 record.
     C                   WRITE     LTREC4
     C*>                 CLEAR                   LTREC4
     C                   ENDIF
     C*
      *
     C     LTSO4         IFNE      *ZEROS
     C                   Z-ADD     LTWHSE        LTWHS
     C                   MOVEL     SAVRTE        LTRTE#
     C                   MOVEL     DESC4         LTEQUP
     C                   MOVE      LTEMPN        LTLODR
     C                   MOVE      LTDNAM        LTDRVR
     C                   Z-ADD     LTICS1        LTLOAQ
     C                   Z-ADD     LTICS2        LTRTRQ
     C                   Z-ADD     *ZEROS        LTSHRT
     C                   Z-ADD     *ZEROS        LTOVER
     C     LTICS1        IFLT      LTICS2
     C     LTICS2        SUB       LTICS1        LTOVER
     C                   ELSE
     C     LTICS1        SUB       LTICS2        LTSHRT
     C                   ENDIF
     C*  Write LDR27 record.
     C                   WRITE     LTREC4
     C*>                 CLEAR                   LTREC4
     C                   ENDIF
     C*
      *
     C     LTSO5         IFNE      *ZEROS
     C                   Z-ADD     LTWHSE        LTWHS
     C                   MOVEL     SAVRTE        LTRTE#
     C                   MOVEL     DESC5         LTEQUP
     C                   MOVE      LTEMPN        LTLODR
     C                   MOVE      LTDNAM        LTDRVR
     C                   Z-ADD     LTICM1        LTLOAQ
     C                   Z-ADD     LTICM2        LTRTRQ
     C                   Z-ADD     *ZEROS        LTSHRT
     C                   Z-ADD     *ZEROS        LTOVER
     C     LTICM1        IFLT      LTICM2
     C     LTICM2        SUB       LTICM1        LTOVER
     C                   ELSE
     C     LTICM1        SUB       LTICM2        LTSHRT
     C                   ENDIF
     C*  Write LDR27 record.
     C                   WRITE     LTREC4
     C*>                 CLEAR                   LTREC4
     C                   ENDIF
     C*
      *
     C     LTSO6         IFNE      *ZEROS
     C                   Z-ADD     LTWHSE        LTWHS
     C                   MOVEL     SAVRTE        LTRTE#
     C                   MOVEL     DESC6         LTEQUP
     C                   MOVE      LTEMPN        LTLODR
     C                   MOVE      LTDNAM        LTDRVR
     C                   Z-ADD     LTICL1        LTLOAQ
     C                   Z-ADD     LTICL2        LTRTRQ
     C                   Z-ADD     *ZEROS        LTSHRT
     C                   Z-ADD     *ZEROS        LTOVER
     C     LTICL1        IFLT      LTICL2
     C     LTICL2        SUB       LTICL1        LTOVER
     C                   ELSE
     C     LTICL1        SUB       LTICL2        LTSHRT
     C                   ENDIF
     C*  Write LDR27 record.
     C                   WRITE     LTREC4
     C*>                 CLEAR                   LTREC4
     C                   ENDIF
     C*
      *
     C     LTSO7         IFNE      *ZEROS
     C                   Z-ADD     LTWHSE        LTWHS
     C                   MOVEL     SAVRTE        LTRTE#
     C                   MOVEL     DESC7         LTEQUP
     C                   MOVE      LTEMPN        LTLODR
     C                   MOVE      LTDNAM        LTDRVR
     C                   Z-ADD     LTSFB1        LTLOAQ
     C                   Z-ADD     LTSFB2        LTRTRQ
     C                   Z-ADD     *ZEROS        LTSHRT
     C                   Z-ADD     *ZEROS        LTOVER
     C     LTSFB1        IFLT      LTSFB2
     C     LTSFB2        SUB       LTSFB1        LTOVER
     C                   ELSE
     C     LTSFB1        SUB       LTSFB2        LTSHRT
     C                   ENDIF
     C*  Write LDR27 record.
     C                   WRITE     LTREC4
     C*>                 CLEAR                   LTREC4
     C                   ENDIF
     C*
      *
     C     LTSO8         IFNE      *ZEROS
     C                   Z-ADD     LTWHSE        LTWHS
     C                   MOVEL     SAVRTE        LTRTE#
     C                   MOVEL     DESC8         LTEQUP
     C                   MOVE      LTEMPN        LTLODR
     C                   MOVE      LTDNAM        LTDRVR
     C                   Z-ADD     LTSPL1        LTLOAQ
     C                   Z-ADD     LTSPL2        LTRTRQ
     C                   Z-ADD     *ZEROS        LTSHRT
     C                   Z-ADD     *ZEROS        LTOVER
     C     LTSPL1        IFLT      LTSPL2
     C     LTSPL2        SUB       LTSPL1        LTOVER
     C                   ELSE
     C     LTSPL1        SUB       LTSPL2        LTSHRT
     C                   ENDIF
     C*  Write LDR27 record.
     C                   WRITE     LTREC4
     C*>                 CLEAR                   LTREC4
     C                   ENDIF
     C*
      *
     C     LTSO9         IFNE      *ZEROS
     C                   Z-ADD     LTWHSE        LTWHS
     C                   MOVEL     SAVRTE        LTRTE#
     C                   MOVEL     DESC9         LTEQUP
     C                   MOVE      LTEMPN        LTLODR
     C                   MOVE      LTDNAM        LTDRVR
     C                   Z-ADD     LTTPL1        LTLOAQ
     C                   Z-ADD     LTTPL2        LTRTRQ
     C                   Z-ADD     *ZEROS        LTSHRT
     C                   Z-ADD     *ZEROS        LTOVER
     C     LTTPL1        IFLT      LTTPL2
     C     LTTPL2        SUB       LTTPL1        LTOVER
     C                   ELSE
     C     LTTPL1        SUB       LTTPL2        LTSHRT
     C                   ENDIF
     C*  Write LDR27 record.
     C                   WRITE     LTREC4
     C*>                 CLEAR                   LTREC4
     C                   ENDIF
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*  ZZFNAM   Format loader name.
     C*----------------------------------------------------------------
     CSR   ZZFNAM        BEGSR
     C*----------------------------------------------------------------
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
     O*
     O* Compile time tables
     O*
