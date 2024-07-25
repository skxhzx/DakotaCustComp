     F*----------------------------------------------------------------
     F*   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  PT729     FTP Export closed transfer/putaway trans - Post
     F*  13 January 2004
     F*  Roxanne Harrison
     F*
     F*
     F*----------------------------------------------------------------
     F*  Revisions
417aAF*    01/12/04  RH   4.17a
     F*      - Add label type and item fields.
     F*      - If host only has base slots, write base to EXPFTRN for
     F*        virtual slots.
     F*
520 AF*    05/12/08  CWM  520
     F*      - 5.20 - Added CLIENT code.
520aAF*    07/23/08  MLB  5.20a
     F*      - Fix: Revised program to correctly load TFRMOV label
     F*        into first from/to fields instead of making 2 rcds.
520bAF*    07/23/08  MLB  5.20b
     F*      - Fix: Revised program to correctly load label type
     F*        R=Replenishments from item/slot info.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Fox River Foods.
     F*
FRF AF*    04/17/08  CWM  520
     F*      - FRF  - If PTTASK = PUTEMP use dummy slot numbers.
     F*      - FRF  - Remove UNIQUE from EXPFTRN and change related
     F*               code accordingly.
FRF AF*    05/13/08  CWM  520
     F*      - FRF  - Added custom code for FRF to enable loading
     F*               both the From and To Item and Slot for all
     F*               transaction types.
FRFcAF*    07/23/08  MLB  FRFc
     F*      - Revised routine ZZCLTMOD1 to not write out records
     F*        to EXPFTRN file.  Allow existing code in pgm to
     F*        control when record(s) get written out.
     F*
     F*----------------------------------------------------------------
     F* Indicators
     F*
     F*  79        - EOF
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FPT729     IP   E           K DISK
     FLABEL90   IF   E           K DISK
     FPIRUSER1  IF   E           K DISK
     FVSLOT1    IF   E           K DISK
     FFLGTRAN   O  A E           K DISK
FRF DF*** EXPFTRN   O  A E           K DISK
FRF AFEXPFTRN   UF A E           K DISK
     D*
     D*----------------------------------------------------------------
     D*  Constants
     D*
     D FOREVR          C                   CONST('1')
     D*
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D*
     D*----------------------------------------------------------------
     D*  Data Structure
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
     D*
     D*----------------------------------------------------------------
     D*  Internaly Defined Work Fields
     D*

520 A*----------------------------------------------------------------
520 A*  Customer id
520 A*----------------------------------------------------------------
520 A
520 A /copy qcopysrc,id#frf

     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      None
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C* Main line
     C*
     C*  Use first transaction as group transaction.
     C*
     C     FIRST         IFEQ      0
     C                   Z-ADD     PTTRN#        GRTRN#            7 0
     C                   Z-ADD     1             FIRST             1 0
     C                   ENDIF
     C*  Move transaction info to export fields
     C                   EXSR      FILLPE
     C*
     C*  Get user info.
     C*
     C     PTEMP#        CHAIN     PIRUSER1                           79
     C     *IN79         IFEQ      *OFF
     C                   MOVE      USCODE        PEUSER
     C                   ENDIF
417a C                   MOVE      *OFF          DOFLAG            1
     C*
     C*  Get label info.
     C*
     C     KEYLB         SETLL     LABEL90
     C     1             DO        10            X                 2 0
     C     KEYLB         READE     LABEL90                                79
     C     *IN79         IFEQ      *ON
     C                   LEAVE
     C                   ENDIF
     C*
417a C*  Only process for putaway or transfer records.
FRF AC*
FRF AC                   if        client = FRF
FRF AC                   if        lbtype <> 'P' and
FRF AC                             lbtype <> 'R' and
FRF AC                             lbtype <> 'T'
FRF AC                   iter
FRF AC                   endIf
FRF AC                   else
     C*
417a C     LBTYPE        IFNE      'P'
417a C     LBTYPE        ANDNE     'T'
417a C                   ITER
417a C                   ENDIF
FRF AC*
FRF AC                   ENDIF
     C*
     C**         LBGRP2    IFEQ 'B'
     C**                   ITER
     C**                   ENDIF
     C*
417a C                   MOVE      LBTYPE        PELTYP
417a C                   MOVE      *ON           DOFLAG
520aA*
520aA*  Reset counter back to 1 so that label info is loaded
520aA*  into first occurence.
520aAC                   if        pttask = 'TFRMOV'
520aAC                             and x = 2
520aAC                   eval      x = x - 1
520aAC                   endif
     C*
     C                   SELECT
     C*
     C     X             WHENEQ    1
     C*
417a C*  If type 'A' item is "FROM" item.
     C*
417a C     LBGRP2        IFEQ      'A'
520bAC     LBTYPE        OREQ      'R'
417a C                   MOVE      LBITEM        PEFIT1
     C                   MOVE      LBDISP        PEFSL1
417a C                   MOVE      PEFSL1        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PEFSL1
520bDC*                  ELSE
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
520bA*
417a C                   MOVE      LBITEM        PETIT1
     C                   MOVE      LBDISP        PETSL1
417a C                   MOVE      PETSL1        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PETSL1
417a C                   ENDIF
417a C                   Z-ADD     LBQPCK        PELQP1
417a C                   MOVE      LBUTYP        PEUOM1
     C*
FRF Ac                   if        client = frf
FRF Ac                   exsr      zzCltMod1
FRF Ac                   endIf
     C*
     C     X             WHENEQ    2
     C*
417a C*  If type 'A' item is "FROM" item.
     C*
417a C     LBGRP2        IFEQ      'A'
520bAC     LBTYPE        OREQ      'R'
417a C                   MOVE      LBITEM        PEFIT2
     C                   MOVE      LBDISP        PEFSL2
417a C                   MOVE      PEFSL2        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PEFSL2
520bDC*                  ELSE
520bMC                   ENDIF
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
520bA*
417a C                   MOVE      LBITEM        PETIT2
     C                   MOVE      LBDISP        PETSL2
417a C                   MOVE      PETSL2        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PETSL2
417a C                   ENDIF
417a C                   Z-ADD     LBQPCK        PELQP2
417a C                   MOVE      LBUTYP        PEUOM2
FRF Ac*
FRF Ac                   if        client = frf
FRF Ac                   exsr      zzCltMod1
FRF Ac                   endIf
     C*
     C     X             WHENEQ    3
     C*
417a C*  If type 'A' item is "FROM" item.
     C*
417a C     LBGRP2        IFEQ      'A'
520bAC     LBTYPE        OREQ      'R'
417a C                   MOVE      LBITEM        PEFIT3
     C                   MOVE      LBDISP        PEFSL3
417a C                   MOVE      PEFSL3        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PEFSL3
520bDC*                  ELSE
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
520bA*
417a C                   MOVE      LBITEM        PETIT3
     C                   MOVE      LBDISP        PETSL3
417a C                   MOVE      PETSL3        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PETSL3
417a C                   ENDIF
417a C                   Z-ADD     LBQPCK        PELQP3
417a C                   MOVE      LBUTYP        PEUOM3
FRF Ac*
FRF Ac                   if        client = frf
FRF Ac                   exsr      zzCltMod1
FRF Ac                   endIf
     C*
     C     X             WHENEQ    4
     C*
417a C*  If type 'A' item is "FROM" item.
     C*
417a C     LBGRP2        IFEQ      'A'
520bAC     LBTYPE        OREQ      'R'
417a C                   MOVE      LBITEM        PEFIT4
     C                   MOVE      LBDISP        PEFSL4
417a C                   MOVE      PEFSL4        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PEFSL4
520bDC*                  ELSE
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
520bA*
417a C                   MOVE      LBITEM        PETIT4
     C                   MOVE      LBDISP        PETSL4
417a C                   MOVE      PETSL4        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PETSL4
417a C                   ENDIF
417a C                   Z-ADD     LBQPCK        PELQP4
417a C                   MOVE      LBUTYP        PEUOM4
FRF Ac*
FRF Ac                   if        client = frf
FRF Ac                   exsr      zzCltMod1
FRF Ac                   endIf
     C*
     C     X             WHENEQ    5
     C*
417a C*  If type 'A' item is "FROM" item.
     C*
417a C     LBGRP2        IFEQ      'A'
520bAC     LBTYPE        OREQ      'R'
417a C                   MOVE      LBITEM        PEFIT5
     C                   MOVE      LBDISP        PEFSL5
417a C                   MOVE      PEFSL5        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PEFSL5
520bDC*                  ELSE
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
520bA*
417a C                   MOVE      LBITEM        PETIT5
     C                   MOVE      LBDISP        PETSL5
417a C                   MOVE      PETSL5        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PETSL5
417a C                   ENDIF
417a C                   Z-ADD     LBQPCK        PELQP5
417a C                   MOVE      LBUTYP        PEUOM5
FRF Ac*
FRF Ac                   if        client = frf
FRF Ac                   exsr      zzCltMod1
FRF Ac                   endIf
     C*
     C     X             WHENEQ    6
     C*
417a C*  If type 'A' item is "FROM" item.
     C*
417a C     LBGRP2        IFEQ      'A'
520bAC     LBTYPE        OREQ      'R'
417a C                   MOVE      LBITEM        PEFIT6
     C                   MOVE      LBDISP        PEFSL6
417a C                   MOVE      PEFSL6        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PEFSL6
520bDC*                  ELSE
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
520bA*
417a C                   MOVE      LBITEM        PETIT6
     C                   MOVE      LBDISP        PETSL6
417a C                   MOVE      PETSL6        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PETSL6
417a C                   ENDIF
417a C                   Z-ADD     LBQPCK        PELQP6
417a C                   MOVE      LBUTYP        PEUOM6
FRF Ac*
FRF Ac                   if        client = frf
FRF Ac                   exsr      zzCltMod1
FRF Ac                   endIf
     C*
     C     X             WHENEQ    7
     C*
417a C*  If type 'A' item is "FROM" item.
     C*
417a C     LBGRP2        IFEQ      'A'
520bAC     LBTYPE        OREQ      'R'
417a C                   MOVE      LBITEM        PEFIT7
     C                   MOVE      LBDISP        PEFSL7
417a C                   MOVE      PEFSL7        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PEFSL7
520bDC*                  ELSE
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
520bA*
417a C                   MOVE      LBITEM        PETIT7
     C                   MOVE      LBDISP        PETSL7
417a C                   MOVE      PETSL7        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PETSL7
417a C                   ENDIF
417a C                   Z-ADD     LBQPCK        PELQP7
417a C                   MOVE      LBUTYP        PEUOM7
FRF Ac*
FRF Ac                   if        client = frf
FRF Ac                   exsr      zzCltMod1
FRF Ac                   endIf
FRF Ac*
     C     X             WHENEQ    8
     C*
417a C*  If type 'A' item is "FROM" item.
     C*
417a C     LBGRP2        IFEQ      'A'
520bAC     LBTYPE        OREQ      'R'
417a C                   MOVE      LBITEM        PEFIT8
     C                   MOVE      LBDISP        PEFSL8
417a C                   MOVE      PEFSL8        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PEFSL8
520bDC*                  ELSE
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
520bA*
417a C                   MOVE      LBITEM        PETIT8
     C                   MOVE      LBDISP        PETSL8
417a C                   MOVE      PETSL8        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PETSL8
417a C                   ENDIF
417a C                   Z-ADD     LBQPCK        PELQP8
417a C                   MOVE      LBUTYP        PEUOM8
FRF Ac*
FRF Ac                   if        client = frf
FRF Ac                   exsr      zzCltMod1
FRF Ac                   endIf
     C*
     C     X             WHENEQ    9
     C*
417a C*  If type 'A' item is "FROM" item.
     C*
417a C     LBGRP2        IFEQ      'A'
520bAC     LBTYPE        OREQ      'R'
417a C                   MOVE      LBITEM        PEFIT9
     C                   MOVE      LBDISP        PEFSL9
417a C                   MOVE      PEFSL9        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PEFSL9
520bDC*                  ELSE
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
520bA*
417a C                   MOVE      LBITEM        PETIT9
     C                   MOVE      LBDISP        PETSL9
417a C                   MOVE      PETSL9        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PETSL9
417a C                   ENDIF
417a C                   Z-ADD     LBQPCK        PELQP9
417a C                   MOVE      LBUTYP        PEUOM9
FRF Ac*
FRF Ac                   if        client = frf
FRF Ac                   exsr      zzCltMod1
FRF Ac                   endIf
     c*
     C     X             WHENEQ    10
     C*
417a C*  If type 'A' item is "FROM" item.
     C*
417a C     LBGRP2        IFEQ      'A'
520bAC     LBTYPE        OREQ      'R'
417a C                   MOVE      LBITEM        PEFIT0
     C                   MOVE      LBDISP        PEFSL0
417a C                   MOVE      PEFSL0        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PEFSL0
520bDC*                  ELSE
520bMC                   endif
520bA*
520bAC                   if        lbtype = 'R'
520bAC                   eval      petit1 = lbitem
520bAC                   eval      petsl1 = lbdsp2
520bAC                   eval      kydisp = petsl1
520bAC                   exsr      zzslot
520bAC                   eval      petsl1 = kydisp
520bAC                   else
520bA*
417a C                   MOVE      LBITEM        PETIT0
     C                   MOVE      LBDISP        PETSL0
417a C                   MOVE      PETSL0        KYDISP
417a C                   EXSR      ZZSLOT
417a C                   MOVE      KYDISP        PETSL0
417a C                   ENDIF
417a C                   Z-ADD     LBQPCK        PELQP0
417a C                   MOVE      LBUTYP        PEUOM0
FRF Ac*
FRF Ac                   if        client = frf
FRF Ac                   exsr      zzCltMod1
FRF Ac                   endIf
     C*
     C                   ENDSL
     C*
     C                   ITER
     C*
     C                   ENDDO
     C*
     C*
     C*
417a C     DOFLAG        IFEQ      *ON
     C*
520cDC**                 if        client <> FRF
520cDC**   pttrn#        chain     expftrn
520cDC**                 if        not %found(expftrn)
520CDC**                 eval      petrn# = pttrn#
     C                   WRITE     PEREC
520cDC**                 endif
520 AC*
520cDC**                 endif
     C*
     C*  Add record to history file FLGTRAN.
     C*
     C                   EXSR      FILLFG
     C                   WRITE     FGREC
     C*
417a C                   ELSE
     C*
417a C                   CLEAR                   PEREC
417a C                   ENDIF
     C*
     C     BOTTOM        TAG
     C*
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C     *INZSR        BEGSR
     C*
     C*   Define partial key for LABEL file.
     C*
     C     KEYLB         KLIST
     C                   KFLD                    PTWHSE
     C                   KFLD                    PTTRN#
     C*
     C*   Define partial key for VSLOT1 file.
     C*
     C     *LIKE         DEFINE    LBDISP        BSLOT
     C     *LIKE         DEFINE    LBDISP        KYDISP
     C*
     C     KEYVS         KLIST
     C                   KFLD                    LBWHSE
     C                   KFLD                    LBWHDP
     C                   KFLD                    KYDISP
     C*
     C*  Convert today's date into century format.
     C*
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        TODAY             8 0
520 AC*
520 AC* Get client id.
520 AC*
520 AC                   call      'GETCLIENT'
520 AC                   parm                    client           10
     C*
     C                   ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  FILLPE   Fill export transaction fields.
     C*
     C     FILLPE        BEGSR
     C*
     C*  Initialize record
     C*
     C                   CLEAR                   PEREC
     C*
     C*  Move fields from transaction to export file.
     C*
FRFcDC**                 if        client <> frf
     C                   Z-ADD     PTTRN#        PETRN#
FRFcDC**                 endIf
     C*
     C                   MOVE      PTTASK        PETASK
     C                   MOVE      PTCAT         PECAT
     C                   MOVE      PTSUB         PESUB
     C                   Z-ADD     PTWHSE        PEWHSE
     C                   MOVE      PTWHDP        PEWHDP
     C                   MOVE      PTSTYP        PESTYP
     C                   MOVE      PTSHFT        PESHFT
     C                   MOVE      PTCREW        PECREW
     C*
     C                   Z-ADD     PTEMP#        PEEMP#
     C                   Z-ADD     PTCUBE        PECUBE
     C                   Z-ADD     PTSWGT        PESWGT
     C                   Z-ADD     PTPCS         PEPCS
     C                   Z-ADD     PTQTY1        PEQTY1
     C                   Z-ADD     PTQTY2        PEQTY2
     C                   Z-ADD     PTQTY3        PEQTY3
     C                   Z-ADD     PTGDTE        PEGDTE
     C                   Z-ADD     PTGTIM        PEGTIM
     C                   Z-ADD     PTSDTE        PESDTE
     C                   Z-ADD     PTSTIM        PESTIM
     C                   Z-ADD     PTEDTE        PEEDTE
     C                   Z-ADD     PTETIM        PEETIM
     C*
     C                   MOVE      PTETYP        PEETYP
     C                   MOVE      PTRTPO        PERTPO
     C                   MOVE      PTGRP1        PEGRP1
     C                   MOVE      PTGRP2        PEGRP2
     C*
     C                   ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  FILLFG  Fill flag fields.
     C*
     C     FILLFG        BEGSR
     C*
     C*  Initialize record
     C*
     C                   CLEAR                   FGREC
     C*
     C*  Move fields from transaction to flag file.
     C*
     C                   Z-ADD     PTWHSE        FGWHSE
     C                   Z-ADD     PTTRN#        FGTRN#
     C                   Z-ADD     TODAY         FGEDTE
     C*
     C                   TIME                    FGETIM
     C*
     C                   Z-ADD     GRTRN#        FGGTRN
     C                   Z-ADD     0             FGRDTE
     C                   Z-ADD     0             FGRTIM
     C*
     C                   ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZSLOT  Get Base slot for Virtual if host only has base slots.
     C*
     C     ZZSLOT        BEGSR
     C*
     C*
     C     KEYVS         CHAIN     VSLOT1                             79
     C*
     C*  Use base slot.
     C*
     C     *IN79         IFEQ      *OFF
     C                   MOVE      VSPDIS        KYDISP
     C                   ENDIF
     C*
     C                   ENDSR
     c*
     c*----------------------------------------------------------------
     c*
FRF Ac* ZZCLTMOD1 Client Mods - FRF                                    s.
FRF Ac*
FRF Ac     zzCltMod1     begsr
FRF Ac*
FRF Ac* Process Transactions / Create Export File
FRF Ac*
FRF Ac                   select
FRF Ac*
FRF Ac* Putaways
FRF Ac*
FRF Ac                   when      ptTask = 'PUTEMP' OR
FRF Ac                               ptTask = 'PUTRTN'
FRF Ac*
FRFcDc**                 eval      petSl1 = kyDisp
FRF Ac                   eval      pefSl1 = *blanks
FRF Ac*
FRF Ac                   eval      pefIt1 = lbItem
FRFcDc**                 eval      petIt1 = lbItem
FRF Ac*
FRF Ac                   select
FRF Ac*
FRF Ac                   when      ptWhdp = 'DRY  '
FRF Ac                   eval      pefSl1 = '72000'
FRF Ac*
FRF Ac                   when      ptWhdp = 'FRZ  '
FRF Ac                   eval      pefSl1 = '03JIM'
FRF Ac*
FRF Ac                   when      ptWhdp = 'CLR  '
FRF Ac                   eval      pefSl1 = '94COL'
FRF Ac*
FRF Ac                   endSl
FRF Ac*
FRFcDc**                 eval      peTrn# = ptTrn#
FRFcDc**                 write     peRec
FRF Ac*
FRF Ac* Replenishments
FRF Ac*
FRF Ac                   when      ptTask = 'REPL  ' OR
FRF Ac                               ptTask = 'REPLBK'
FRF Ac*
FRFcDc**                 eval      petSl1 = lbDsp2
FRFcDc**                 eval      pefSl1 = lbDisp
FRF Ac*
FRFcDc**                 eval      pefIt1 = lbItem
FRFcDc**                 eval      petIt1 = lbItem
FRF Ac*
FRFcDc**                 eval      peTrn# = ptTrn#
FRFcDc**                 write     perec
FRF Ac*
FRF Ac* Transfers
FRF Ac*
FRF Ac                   when      ptTask = 'TFRMOV'
FRF Ac*
FRFcDc**                 eval      petSl1 = lbDsp2
FRFcDc**                 eval      pefSl1 = lbDisp
FRF Ac*
FRF Ac* Write Export Transaction Record
FRF Ac*
FRFcDc**   ptTrn#        chain     expFtrn
FRF Ac*
FRFcDc**                 if        not %found(expftrn)
FRFcDc**                 eval      pefIt1 = lbItem
FRFcDc**                 eval      petIt1 = lbItem
FRFcDc**                 eval      petrn# = pttrn#
FRFcDc**                 write     perec
FRF Ac*
FRFcDc**                 else
FRF Ac*
FRFcDc**                 if        lbItem <> pefIt1 and
FRFcDc**                            lbItem <> petIt1
FRFcDc**                 eval      petIt1 = lbItem
FRFcDc**                 update    peRec
FRFcDc**                 endif
FRF Ac*
FRFcDc**                 endif
FRF Ac*
FRF Ac                   endsl
FRF Ac*
FRF Ac                   endSr
FRF Ac*
