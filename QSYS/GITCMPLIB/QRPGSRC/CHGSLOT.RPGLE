     F*  (c) COPYRIGHT GFG FOODSERVICE, INC. 2004
     F*       PROGRAM PROPERTY OF GFG
     F*
     F*
     F* LIBRARY NAME            - GFGLIB
     F*
     F* ENVIRONMENT             - NATIVE
     F*
     F* PROGRAM NAME            - CHGSLOT
     F*
     F* TITLE                   - CHANGE SLOT DISPLAY IN SLOT FILE
     F*                           FROM BFC TO P SYSTEM DISPLAY
     F*
     F* FUNCTION                - THIS PROGRAM CHANGE THE SLOT DISPLAY
     F*                           IN THE SLOT FILE FROM THE BFC TO THE
     F*                           P SYSTEM SLOT DISPLAY.
     F*
ALNaAF* CHANGE ACTIVITY         - Program revised to add support to
     F*                           convert virtual slots to new P-Sys
     F*                           format. (ALNa)
     F*                         - Converted program to ILE.
ALNbAF*                         - Program revised to compare SLAISL
     F*                           to first 3 characters of SLDISP
     F*                           and if not the same, skip slot
     F*                           since it was already converted.
     F*                          (ALNb)
     F*
ALNcAF*                         - Program revised to convert SLAISL,
     F*                           SLRLVL,SLHAND,SLPSEQ, SLSIDE using
     F*                           P-Sys slot display field.
     F*                          (ALNc)
     F*
ALNdAF*                         - Program revised to convert SLAISL
     F*                           for Aisle T to Aisle CT.
     F*                          (ALNd)
     F*
     F* CALLING PROGRAMS(S)     - CHGSLOTCL
     F*
     F* INPUT FILE(S)           - SLOTREFL / SLOT2
     F*
ALNaMF* UPDATE FILE(S)          - SLOT1 / VSLOT2
     F*
     F* OUTPUT FILE(S)          - CHGSLOTP
     F*
     F* RECEIVED EXTERNAL DATA  -
     F*
     F* PASSED EXTERNAL DATA    -
     F*
     F* DISPLAYS : DEVICE/FILE  -
     F*
     F*            SOURCE MBR   -
     F*
     F*            FORMAT(S) &  -
     F*
     F*            SCREEN ID(S) -
     F*
     F* REPORT(S)               -
     F*
     F* OPERATOR RESPONSE(S)    -
     F*
     F* MESSAGE(S)              -
     F*
     F* SUBROUTINE(S)           -
     F*                           $FIRST - FIRST CYCLE PROCESSING
     F*
     F* INDICATOR ASSIGNMENT
     F*
     F* ID F  C  H  L        FUNCTION OF INDICATOR(S)
     F*
     F*             LR       LAST RECORD
     F*
     FSLOT1     UF   E           K DISK
ALNaDF*SLOT2     IF   E           K DISK
ALNaMFSLOT2     UF   E           K DISK
     F                                     RENAME(SLREC:SLOT2R)
ALNaAFVSLOT2    UF   E           K DISK
     FSLOTREFL  IF   E           K DISK
     FCHGSLOTP  O    E             PRINTER
     D*
     D DUP             C                   CONST('DUPLICATE DISPLAY')
     D XREF            C                   CONST('NO CROSS REFERENCE')
     D*
     D* Work fields to pass data to update pgm
     D DATDS           DS
     D  RPTDT                  7     14  0
     D  HMSMDY                 1     14  0
     D                 DS
     D  STATUS                 1     18
     D  SIDE                  19     19  0
     D                 DS
     D  HAISLE                 1      3
     D  POS1                   1      1
     D  POS2                   2      2
     D  POS3                   3      3
     D  POS12                  1      2
     D*
ALNcAD allchrslot      s              1    inz('0')
ALNcAD dftlocation     s              3  0 inz(600)
ALNcAD dummy           s                   like(slloc)
ALNcAD nwchar          s              2
ALNcAD oddeven         s                   like(slloc)
ALNcAD wkchar          s              2
ALNcA
ALNcAD loca            s              3
ALNcAD lvla            s              1
ALNcAD locnotnum       s               n
ALNcAD lvlnotnum       s               n
     C*
     C     *IN90         IFEQ      *OFF
     C                   EXSR      $FIRST
     C                   END
     C*
     C                   MOVE      *OFF          *IN10
     C     SLTKY         SETLL     SLOT1
     C     *IN10         DOWEQ     *OFF
     C     SLTKY         READE     SLOT1                                  10
     C     *IN10         IFEQ      *OFF
ALNaAC*
ALNaAC*    Skip virtual slots.
ALNaAC     SLRSRV        IFEQ      'V'
ALNaAC                   ITER
ALNaAC                   ENDIF
ALNaAC*
ALNbAC*
ALNbAC*    Skip slots that have already been converted.
ALNbAC                   If        slaisl <> %subst(sldisp:1:3)
ALNbAC                   ITER
ALNbAC                   ENDIF
ALNbAC*
     C*
     C     PSIDE         IFNE      'BOTH'
     C     SLSIDE        IFNE      SIDE
     C                   ITER
     C                   ENDIF
     C                   ENDIF
     C*
     C                   MOVE      *BLANKS       PSLOT
     C     SLDISP        CHAIN     SLOTREFL                           15
ALNaAC*
ALNaAC*    Slot found in cross-ref file.
     C     *IN15         IFEQ      *OFF
ALNaAC*
ALNaAC*    New slot NOT found in SLOT file. Update w/ new slot.
     C     SL2KY         SETLL     SLOT2                                  18
     C     *IN18         IFEQ      *OFF
     C                   MOVEL     PSLOT         SLDISP
ALNcAC*    Convert Aisle, Location, Rack level using new slot.
ALNcAC                   exsr      Cvtslot
ALNdAC                   if        slwhdp = 'REF'
ALNdAC                             and slaisl = '  T'
ALNdAC                   eval      slaisl = ' CT'
ALNdAC                   endif
     C                   EXCEPT    PRC$
ALNaAC*
ALNaAC*
ALNaAC*    Check for virtual slots attached to this slot.
ALNaAC     VSKEY         SETLL     VSLOT2
ALNaAC     VSKEY         READE     VSLOT2                                 79
ALNaAC*
ALNaAC*    79=Off, virtual slots attached to this slot.
ALNaAC     *IN79         DOWEQ     *OFF
ALNaAC
ALNaAC*      Create new virtual slot display.
ALNaAC                   eval      newvrtslt = %trim(pslot) +
ALNaAC                                         %trim(vshand)
ALNaAC
ALNAAC     SL2AKY        SETLL     SLOT2                                  18
ALNaAC                   select
ALNaAC*      New Virtual slot FOUND, print Error on report.
ALNaAC     *IN18         Wheneq    *On
ALNaAC                   exsr      $print
ALNaAC
ALNaAC*      New Virtual slot NOT found, okay to update to new format.
ALNaAC     *IN18         Wheneq    *OFF
ALNaAC     VS2key        CHAIN     SLOT2                              77
ALNaAC                   select
ALNaAC     *IN77         Wheneq    *OFF
ALNaAC                   eval      sldisp = newvrtslt
ALNcAC*    Convert Aisle, Location, Rack level using new slot.
ALNcAC                   exsr      Cvtslot
ALNdAC                   if        slwhdp = 'REF'
ALNdAC                             and slaisl = '  T'
ALNdAC                   eval      slaisl = ' CT'
ALNdAC                   endif
ALNaAC                   update    slot2r
ALNaAC
ALNaAC                   eval      vsdisp = newvrtslt
ALNaAC                   eval      vspdis = pslot
ALNcAC
ALNcAC                   eval      vsaisl = slaisl
ALNcAC                   eval      vsloc  = slloc
ALNcAC                   eval      vsrlvl = slrlvl
ALNcAC
ALNaAC                   update    vsrec
ALNaAC                   endsl
ALNaAC                   endsl
ALNaAC
ALNaAC*      Read next virtual slot.
ALNaAC     VSKEY         READE     VSLOT2                                 79
ALNaAC                   eval      *in15 = *off
ALNaAC                   eval      *in18 = *off
ALNaAC                   ENDDO
ALNaAC*
     C                   ENDIF
     C                   ENDIF
     C*
     C     *IN15         IFEQ      *ON
     C     *IN18         OREQ      *ON
     C                   EXSR      $PRINT
     C                   ENDIF
     C*
     C                   ENDIF
     C                   ENDDO
     C                   MOVE      *ON           *INLR
     C*
     C* PRINT EXCEPTION REPORT IF APPLICABLE
     C     $PRINT        BEGSR
     C                   MOVE      *BLANKS       STATUS
     C                   SELECT
     C     *IN15         WHENEQ    *ON
     C                   MOVEL(P)  XREF          STATUS
     C     *IN18         WHENEQ    *ON
     C                   MOVEL(P)  DUP           STATUS
     C                   ENDSL
     C*
     C     *IN60         IFEQ      *ON
     C                   WRITE     HEAD$                                60
     C                   ENDIF
     C                   WRITE     DETAIL$                              60
     C                   ENDSR
     C*
     C* FIRST TIME PROCESSING
     C     $FIRST        BEGSR
     C     *ENTRY        PLIST
     C                   PARM                    PWHSE             3 0
     C                   PARM                    PWHDP             5
     C                   PARM                    PAISL             3
     C                   PARM                    PSIDE             4
     C*
     C                   SELECT
     C     PSIDE         WHENEQ    'ODD '
     C                   Z-ADD     1             SIDE
     C     PSIDE         WHENEQ    'EVEN'
     C                   Z-ADD     0             SIDE
     C                   ENDSL
     C*
     C                   MOVEL     PAISL         HAISLE
     C                   MOVE      *BLANKS       PAISL
     C                   SELECT
     C     POS3          WHENNE    ' '
     C                   MOVE      HAISLE        PAISL
     C     POS3          WHENEQ    ' '
     C     POS2          ANDNE     ' '
     C                   MOVE      POS12         PAISL
     C                   OTHER
     C                   MOVE      POS1          PAISL
     C                   ENDSL
     C*
     C                   MOVE      *ZEROS        DATDS
     C                   TIME                    HMSMDY
     C                   MOVE      *ON           *IN90
ALNcAC*     Force on overflow indicator.
ALNcAC                   MOVE      *ON           *IN60
     C     SLTKY         KLIST
     C                   KFLD                    PWHSE
     C                   KFLD                    PWHDP
     C                   KFLD                    PAISL
ALNaAC     VSKEY         KLIST
ALNaAC                   KFLD                    PWHSE
ALNaAC                   KFLD                    PWHDP
ALNaAC                   KFLD                    BFCSLT
ALNaAC     VS2key        KLIST
ALNaAC                   KFLD                    PWHSE
ALNaAC                   KFLD                    PWHDP
ALNaAC                   KFLD                    VSDISP
     C     SL2KY         KLIST
     C                   KFLD                    PWHSE
     C                   KFLD                    PWHDP
     C                   KFLD                    PSLOT
ALNaAC     *like         define    pslot         newvrtslt
ALNaAC     SL2AKY        KLIST
ALNaAC                   KFLD                    PWHSE
ALNaAC                   KFLD                    PWHDP
ALNaAC                   KFLD                    newvrtslt
     C                   ENDSR

ALNcA*----------------------------------------------------------------
ALNcA*  cvtslot  Convert slot fields to P-Sys format.
ALNcA*----------------------------------------------------------------
ALNcA
ALNcAC     cvtslot       begsr
ALNcA
ALNcA*  Extract location and level. Test if they are numeric.
ALNcA
ALNcAC                   eval      locnotnum = *off
ALNcAC                   eval      lvlnotnum = *off
ALNcAC                   eval      loca  = ' '
ALNcAC                   eval      lvla  = ' '
ALNcA
ALNcA*  Check for all alpha slot. If no digits, default slot location
ALNcA*  will be assigned.
ALNcAC                   If            %subst(sldisp:2:2) >= '00'
ALNcAC                             and %subst(sldisp:2:2) <= '99'
ALNcAC                             or  %subst(sldisp:3:2) >= '00'
ALNcAC                             and %subst(sldisp:3:2) <= '99'
ALNcAC                   eval      allchrslot = *off
ALNcAC                   else
ALNcAC                   eval      allchrslot = *on
ALNcAC                   endif
ALNcA
ALNcAC                   select
ALNcA
ALNcA
ALNcA*  No dashes specified. All character slot.
ALNcAC                   when      allchrslot = *on
ALNcAC
ALNcAC                   evalr     slaisl = %trimr(%subst(sldisp:1:2))
ALNcAC
ALNcAC                   eval      dftlocation = dftlocation + 1
ALNcAC                   eval      loca   = %char(dftlocation)
ALNcAC                   eval      slloc  = dftlocation
ALNcAC                   eval      slpseq = dftlocation
ALNcAC
ALNcAC                   eval      slrlvl = 1
ALNcAC                   eval      lvla   = '1'
ALNcAC
ALNcAC                   eval      slhand  = '  '
ALNcA
ALNcA*  No dashes specified. Double character aisle, numeric rack level.
ALNcAC                   when           %subst(sldisp:2:1) >= 'A'
ALNcAC                             and  %subst(sldisp:2:1) <= 'Z'
ALNcAC                             and (%subst(sldisp:5:1) >= '0'
ALNcAC                             and  %subst(sldisp:5:1) <= '9'
ALNcAC                             or   %subst(sldisp:5:1)  = ' ')
ALNcAC
ALNcAC                   evalr     slaisl  = %trimr(%subst(sldisp:1:2))
ALNcA
ALNcAC                   evalr     loca    = %trimr(%subst(sldisp:3:2))
ALNcAC                   move (p)  loca          slloc
ALNcA
ALNcAC                   eval      lvla    = %subst(sldisp:5:1)
ALNcAC                   move (p)  lvla          slrlvl
ALNcAC                   eval      slrlvl  = slrlvl + 1
ALNcA
ALNcA*  No dashes specified. Double character aisle, alpha rack level,
ALNcAC                   when          %subst(sldisp:2:1) >= 'A'
ALNcAC                             and %subst(sldisp:2:1) <= 'Z'
ALNcAC                             and %subst(sldisp:5:1) >= 'A'
ALNcAC                             and %subst(sldisp:5:1) <= 'Z'
ALNcAC
ALNcAC                   evalr     slaisl  = %trimr(%subst(sldisp:1:2))
ALNcAC                   evalr     loca    = %trimr(%subst(sldisp:3:2))
ALNcAC                   move (p)  loca          slloc
ALNcAC
ALNcAC                   eval      lvla    = %subst(sldisp:5:1)
ALNcAC                   evalr     wkchar = %trimr(lvla)
ALNcAC                   exsr      zzcvt2nbr
ALNcAC                   evalr     lvla   = %trimr(nwchar)
ALNcAC                   eval      slrlvl = %dec(nwchar:2:0)
ALNcAC                   eval      slrlvl = slrlvl + 10
ALNcA
ALNcA*  No dashes specified. Single character aisle, numeric rack level.
ALNcAC                   when           %subst(sldisp:2:1) >= '0'
ALNcAC                             and  %subst(sldisp:2:1) <= '9'
ALNcAC                             and (%subst(sldisp:5:1) >= '0'
ALNcAC                             and  %subst(sldisp:5:1) <= '9'
ALNcAC                             or   %subst(sldisp:5:1)  = ' ')
ALNcAC
ALNcAC                   evalr     slaisl  = %trimr(%subst(sldisp:1:1))
ALNcAC
ALNcAC                   evalr     loca    = %trimr(%subst(sldisp:2:3))
ALNcAC                   move (p)  loca          slloc
ALNcAC
ALNcAC                   eval      lvla    = %subst(sldisp:5:1)
ALNcAC                   move (p)  lvla          slrlvl
ALNcAC                   eval      slrlvl  = slrlvl + 1
ALNcA
ALNcA*  No dashes specified. Single character aisle, alpha rack level.
ALNcAC                   when          %subst(sldisp:2:1) >= '0'
ALNcAC                             and %subst(sldisp:2:1) <= '9'
ALNcAC                             and %subst(sldisp:4:1) >= 'A'
ALNcAC                             and %subst(sldisp:4:1) <= 'Z'
ALNcAC
ALNcAC                   evalr     slaisl  = %trimr(%subst(sldisp:1:1))
ALNcAC
ALNcAC                   evalr     loca    = %trimr(%subst(sldisp:2:3))
ALNcAC                   move (p)  loca          slloc
ALNcA
ALNcAC                   eval      lvla    = %subst(sldisp:5:1)
ALNcAC                   evalr     wkchar = %trimr(lvla)
ALNcAC                   exsr      zzcvt2nbr
ALNcAC                   evalr     lvla   = %trimr(nwchar)
ALNcAC                   eval      slrlvl = %dec(nwchar:2:0)
ALNcAC                   eval      slrlvl = slrlvl + 10
ALNcA
ALNcA*  No dashes specified. Extract out slot breakdown.
ALNcAC                   other
ALNcAC
ALNDAC**                 eval      slaisl  = ' ' + %subst(sldisp:1:2)
ALNcA
ALNDAC**                 evalr     loca    = %trimr(%subst(sldisp:3:2))
ALNDAC**                 move      loca          slloc
ALNcA
ALNDAC**                 eval      lvla    = %subst(sldisp:5:1)
ALNDAC**                 move      lvla          slrlvl
ALNcDC**                 eval      slrlvl  = slrlvl + 1
ALNcA
ALNcA
ALNcAC                   endsl
ALNcA
ALNcA
ALNcA*  Begin testing parts for ALL slots.
ALNcAC                   testn                   loca                 5050
ALNcAC                   if        *in50 = *off
ALNcAC                   eval      locnotnum = *on
ALNcA
ALNcAC                   else
ALNcA
ALNcAC                   if        %subst(sldisp:6:3) = 'OVR'
ALNcAC                   eval      slloc = slloc + 200
ALNcAC                   else
ALNcAC                   eval      slloc = slloc + 100
ALNcAC                   endif
ALNcA
ALNcAC                   endif
ALNcA
ALNcAC                   eval      slpseq = slloc
ALNcA
ALNcAC                   testn                   lvla                 50
ALNcAC                   if        *in50 = *off
ALNcAC                   eval      lvlnotnum = *on
ALNcAC                   else
ALNcAC                   select
ALNcAC                   when      slrlvl = 0
ALNcAC                   eval      slrlvl = slrlvl + 11
ALNcAC                   when      slrlvl < 0
ALNcAC                   eval      slrlvl = slrlvl * -1
ALNcAC                   endsl
ALNcAC                   endif
ALNcA
ALNcA*    Calculate new side variable. 0=Even, 1=Odd
ALNcA
ALNcAC     slloc         div       2             dummy
ALNcAC                   mvr                     oddeven
ALNcAC                   if        oddeven <> 0
ALNcAC                   eval      slside = 1
ALNcAC                   else
ALNcAC                   eval      slside = 0
ALNcAC                   endif
ALNcA*
ALNcA
ALNcAC     endcvt        endsr
ALNcA

     *----------------------------------------------------------------
     *  zzcvt2ltr   Convert numeric handstack to alpha character.
     *----------------------------------------------------------------

     C     zzcvt2ltr     begsr

     C                   eval      nwchar = '  '

     C                   select
     C                   when         wkchar = ' 0'
     C                             or wkchar = '  '
     C                   eval      nwchar = ' A'
     C
     C                   when      wkchar = ' 1'
     C                   eval      nwchar = ' B'
     C
     C                   when      wkchar = ' 2'
     C                   eval      nwchar = ' C'
     C
     C                   when      wkchar = ' 3'
     C                   eval      nwchar = ' D'
     C
     C                   when      wkchar = ' 4'
     C                   eval      nwchar = ' E'
     C
     C                   when      wkchar = ' 5'
     C                   eval      nwchar = ' F'
     C
     C                   when      wkchar = ' 6'
     C                   eval      nwchar = ' G'
     C
     C                   when      wkchar = ' 7'
     C                   eval      nwchar = ' H'
     C
     C                   when      wkchar = ' 8'
     C                   eval      nwchar = ' I'
     C
     C                   when      wkchar = ' 9'
     C                   eval      nwchar = ' J'
     C
     C                   endsl

     C     endcvt2ltr    endsr

     *----------------------------------------------------------------
     *  zzcvt2nbr   Convert alpha character to numeric character.
     *----------------------------------------------------------------

     C     zzcvt2nbr     begsr

     C                   eval      nwchar = '  '

     C                   select
     C                   when         wkchar = ' A'
     C                             or wkchar = '  '
     C                   eval      nwchar = '01'
     C
     C                   when      wkchar = ' B'
     C                   eval      nwchar = '02'
     C
     C                   when      wkchar = ' C'
     C                   eval      nwchar = '03'
     C
     C                   when      wkchar = ' D'
     C                   eval      nwchar = '04'
     C
     C                   when      wkchar = ' E'
     C                   eval      nwchar = '05'
     C
     C                   when      wkchar = ' F'
     C                   eval      nwchar = '06'
     C
     C                   when      wkchar = ' G'
     C                   eval      nwchar = '07'
     C
     C                   when      wkchar = ' H'
     C                   eval      nwchar = '08'
     C
     C                   when      wkchar = ' I'
     C                   eval      nwchar = '09'
     C
     C                   when      wkchar = ' J'
     C                   eval      nwchar = '10'
     C
     C                   when      wkchar = ' K'
     C                   eval      nwchar = '11'
     C
     C                   when      wkchar = ' L'
     C                   eval      nwchar = '12'
     C
     C                   when      wkchar = ' M'
     C                   eval      nwchar = '13'
     C
     C                   when      wkchar = ' N'
     C                   eval      nwchar = '14'
     C
     C                   when      wkchar = ' O'
     C                   eval      nwchar = '15'
     C
     C                   when      wkchar = ' P'
     C                   eval      nwchar = '16'
     C
     C                   when      wkchar = ' Q'
     C                   eval      nwchar = '17'
     C
     C                   when      wkchar = ' R'
     C                   eval      nwchar = '18'
     C
     C                   when      wkchar = ' S'
     C                   eval      nwchar = '19'
     C
     C                   when      wkchar = ' T'
     C                   eval      nwchar = '20'
     C
     C                   when      wkchar = ' U'
     C                   eval      nwchar = '21'
     C
     C                   when      wkchar = ' V'
     C                   eval      nwchar = '22'
     C
     C                   when      wkchar = ' W'
     C                   eval      nwchar = '23'
     C
     C                   when      wkchar = ' X'
     C                   eval      nwchar = '24'
     C
     C                   when      wkchar = ' Y'
     C                   eval      nwchar = '25'
     C
     C                   when      wkchar = ' Z'
     C                   eval      nwchar = '26'
     C
     C                   endsl

     C     endcvt2nbr    endsr
     C******************************************************
     C*       ***   END OF CALCULATIONS   ***
     C*
     OSLREC     E            PRC$
     O* Slot file
ALNcAO                       SLAISL
ALNcAO                       SLLOC
ALNcAO                       SLRLVL
ALNcAO                       SLPSEQ
ALNcAO                       SLSIDE
     O                       SLDISP
