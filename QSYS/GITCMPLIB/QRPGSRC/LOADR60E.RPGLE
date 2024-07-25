     F*----------------------------------------------------------------
     F*   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  LOADR60E  Creaate Returned Trailer Equipment Detail file-by Loader
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
     F*
     FLDR27     O    E           K DISK
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
     C     LTRTE         IFNE      SAVRTE
     C     LTRTID        ANDNE     SAVRTI
     C     HDRKEY        CHAIN     LDRHHDR                            79
     C     *IN79         IFEQ      *OFF
     C                   MOVEL     LTRTE         SAVRTE            5
     C                   MOVEL     LTRTID        SAVRTI            5
     C                   ENDIF
     C                   ENDIF
      *
     C                   CLEAR                   LTREC7
      *
     C     LTSO1         IFNE      *ZEROS
     C                   MOVEL     DESC1         LTEQUP
     C                   MOVE      LTEMP#        LTLDR#
     C                   MOVE      LTEMPN        LTLDRN
     C                   MOVE      LTDEMP        LTDRV#
     C                   MOVE      LTDNAM        LTDRVN
     C     LTBK1         IFLT      LTBK2
     C     LTBK2         SUB       LTBK1         LTOVER
     C                   ELSE
     C     LTBK1         SUB       LTBK2         LTSHRT
     C                   ENDIF
     C     LTOVER        SUB       LTSHRT        LTDIFF
     C*  Write LDR27 record.
     C                   WRITE     LTREC7
     C                   CLEAR                   LTREC7
     C                   ENDIF
     C*
      *
     C     LTSO2         IFNE      *ZEROS
     C                   MOVEL     DESC2         LTEQUP
     C                   MOVE      LTEMP#        LTLDR#
     C                   MOVE      LTEMPN        LTLDRN
     C                   MOVE      LTDEMP        LTDRV#
     C                   MOVE      LTDNAM        LTDRVN
     C     LTBH1         IFLT      LTBH2
     C     LTBH2         SUB       LTBH1         LTOVER
     C                   ELSE
     C     LTBH1         SUB       LTBH2         LTSHRT
     C                   ENDIF
     C     LTOVER        SUB       LTSHRT        LTDIFF
     C*  Write LDR27 record.
     C                   WRITE     LTREC7
     C                   CLEAR                   LTREC7
     C                   ENDIF
     C*
      *
     C     LTSO3         IFNE      *ZEROS
     C                   MOVEL     DESC3         LTEQUP
     C                   MOVE      LTEMP#        LTLDR#
     C                   MOVE      LTEMPN        LTLDRN
     C                   MOVE      LTDEMP        LTDRV#
     C                   MOVE      LTDNAM        LTDRVN
     C     LTLB1         IFLT      LTLB2
     C     LTLB2         SUB       LTLB1         LTOVER
     C                   ELSE
     C     LTLB1         SUB       LTLB2         LTSHRT
     C                   ENDIF
     C     LTOVER        SUB       LTSHRT        LTDIFF
     C*  Write LDR27 record.
     C                   WRITE     LTREC7
     C                   CLEAR                   LTREC7
     C                   ENDIF
     C*
      *
     C     LTSO4         IFNE      *ZEROS
     C                   MOVEL     DESC4         LTEQUP
     C                   MOVE      LTEMP#        LTLDR#
     C                   MOVE      LTEMPN        LTLDRN
     C                   MOVE      LTDEMP        LTDRV#
     C                   MOVE      LTDNAM        LTDRVN
     C     LTICS1        IFLT      LTICS2
     C     LTICS2        SUB       LTICS1        LTOVER
     C                   ELSE
     C     LTICS1        SUB       LTICS2        LTSHRT
     C                   ENDIF
     C     LTOVER        SUB       LTSHRT        LTDIFF
     C*  Write LDR27 record.
     C                   WRITE     LTREC7
     C                   CLEAR                   LTREC7
     C                   ENDIF
     C*
      *
     C     LTSO5         IFNE      *ZEROS
     C                   MOVEL     DESC5         LTEQUP
     C                   MOVE      LTEMP#        LTLDR#
     C                   MOVE      LTEMPN        LTLDRN
     C                   MOVE      LTDEMP        LTDRV#
     C                   MOVE      LTDNAM        LTDRVN
     C     LTICM1        IFLT      LTICM2
     C     LTICM2        SUB       LTICM1        LTOVER
     C                   ELSE
     C     LTICM1        SUB       LTICM2        LTSHRT
     C                   ENDIF
     C     LTOVER        SUB       LTSHRT        LTDIFF
     C*  Write LDR27 record.
     C                   WRITE     LTREC7
     C                   CLEAR                   LTREC7
     C                   ENDIF
     C*
      *
     C     LTSO6         IFNE      *ZEROS
     C                   MOVEL     DESC6         LTEQUP
     C                   MOVE      LTEMP#        LTLDR#
     C                   MOVE      LTEMPN        LTLDRN
     C                   MOVE      LTDEMP        LTDRV#
     C                   MOVE      LTDNAM        LTDRVN
     C     LTICL1        IFLT      LTICL2
     C     LTICL2        SUB       LTICL1        LTOVER
     C                   ELSE
     C     LTICL1        SUB       LTICL2        LTSHRT
     C                   ENDIF
     C     LTOVER        SUB       LTSHRT        LTDIFF
     C*  Write LDR27 record.
     C                   WRITE     LTREC7
     C                   CLEAR                   LTREC7
     C                   ENDIF
     C*
      *
     C     LTSO7         IFNE      *ZEROS
     C                   MOVEL     DESC7         LTEQUP
     C                   MOVE      LTEMP#        LTLDR#
     C                   MOVE      LTEMPN        LTLDRN
     C                   MOVE      LTDEMP        LTDRV#
     C                   MOVE      LTDNAM        LTDRVN
     C     LTSFB1        IFLT      LTSFB2
     C     LTSFB2        SUB       LTSFB1        LTOVER
     C                   ELSE
     C     LTSFB1        SUB       LTSFB2        LTSHRT
     C                   ENDIF
     C     LTOVER        SUB       LTSHRT        LTDIFF
     C*  Write LDR27 record.
     C                   WRITE     LTREC7
     C                   CLEAR                   LTREC7
     C                   ENDIF
     C*
      *
     C     LTSO8         IFNE      *ZEROS
     C                   MOVEL     DESC8         LTEQUP
     C                   MOVE      LTEMP#        LTLDR#
     C                   MOVE      LTEMPN        LTLDRN
     C                   MOVE      LTDEMP        LTDRV#
     C                   MOVE      LTDNAM        LTDRVN
     C     LTSPL1        IFLT      LTSPL2
     C     LTSPL2        SUB       LTSPL1        LTOVER
     C                   ELSE
     C     LTSPL1        SUB       LTSPL2        LTSHRT
     C                   ENDIF
     C     LTOVER        SUB       LTSHRT        LTDIFF
     C*  Write LDR27 record.
     C                   WRITE     LTREC7
     C                   CLEAR                   LTREC7
     C                   ENDIF
     C*
      *
     C     LTSO9         IFNE      *ZEROS
     C                   MOVEL     DESC9         LTEQUP
     C                   MOVE      LTEMP#        LTLDR#
     C                   MOVE      LTEMPN        LTLDRN
     C                   MOVE      LTDEMP        LTDRV#
     C                   MOVE      LTDNAM        LTDRVN
     C     LTTPL1        IFLT      LTTPL2
     C     LTTPL2        SUB       LTTPL1        LTOVER
     C                   ELSE
     C     LTTPL1        SUB       LTTPL2        LTSHRT
     C                   ENDIF
     C     LTOVER        SUB       LTSHRT        LTDIFF
     C*  Write LDR27 record.
     C                   WRITE     LTREC7
     C                   ENDIF
     C*
     C                   ENDSR
     O*----------------------------------------------------------------
     O*
     O* Compile time tables
     O*
