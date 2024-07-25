     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  RC200     RF Put-Away
     F*  04 February, 1997
     F*  Dave Sommerville
     F*  Hemant Kapadia
     F*
     F*  Notes
     F*       8 X 20 Screens for hand held scanners
     F*
     F*
SFC  F*   *** Revised to not allow Virtual Pick Slots ***
     F*
     F*  Revisions
     F*
221 AF*    05/19/97  RH   2.21
     F*      - Use option for Use generic license.
     F*      - Add access info by transaction #.
     F*      - IF no LABEL7 rec is found, display sc2 fields with blanks.
222 AF*    06/27/97  RH   2.22
     F*      - Move current value to WOTRN# in ZZCHK1.
409 AF*    06/03/98  RH   4.09
     F*      - Add screen3 for Manual Put away, V-slot.
409aAF*    07/14/98  RH   4.09
     F*      - Move value to W3ITEM in ZZGETI.
410 AF*    10/22/98  RH   4.10
     F*      - Add chain to SLOT file in ZZCKSL, had wrong slot rec.
410 AF*    12/08/98  HNK  4.10
     F*      - Revised to end current task and start an 'IDLE' task
     F*        when there is no open task. ZZEND, ZZIDLE and ZZTASK
     F*        routines added.
     F*
412 AF*    07/15/99  DAS  4.12
     F*      - Revised to deal with new item types.
412 AF*    08/27/99  RH   4.12
     F*      - Add department to Screen 3.
412CAF*    08/31/99  RH   4.12
     F*      - Add *IN92 to not allow F3 or F12 if partial putaway
     F*        was started for VS put away.
     F*      - If date sensitive, when all slot qtys = 0, ignore
     F*        expiration date test.
412dAF*    09/07/99  HNK/DAS 4.12d
     F*      - ITEMQTY file updated in this prog instead of PT132, for
     F*        manual putaway.
     F*      - ZZWHSE routine added.
     F*
412eAF*    09/15/99  DAS 4.12e
     F*      - Took of ODISP IF statment from routine ZZUPD3. Now,
     F*        a slot will be checked every time through for existance.
     F*
412fAF*    09/24/99  DAS  4.12f
     F*      - Changed program to format virtual slot display from
     F*        FRMTSL to FRMTVS.
     F*      - Changed to create vslot with Pick type of physical slot.
     F*      - Revised ZZCKNS routine to check handstack of physical
     F*        slot. If both characters being used then getout. If
     F*        only one char being used then limit the possible
     F*        virtual handstack so that the first character must
     F*        equal the last character of the physical handstack.
     F*        Remember, the handstack is right justified so if
     F*        the physical slot already has handstack ' A', then
     F*        the possible virtual handstacks are 'AA', 'AB' . . .
     F*
413 AF*    10/27/99  DAS  4.13
     F*      - Revised ZZCKNS to set ERROR to *OFF if item is blank.
413aAF*    12/15/99  DAS  4.13a
     F*      - Fix to position to license field for license option.
     F*
413bAF*    01/24/00  DAS  4.13b
     F*      - Revised ZZUPD3 to fill SLPICK correctly with $VPICK.
     F*
413cAF*    01/26/00  RH   4.13c
     F*      - Add code to not create virtual pick slot. This code
     F*        defaults to being commented out. To stop the creation
     F*        of virtual pick slots, you must uncomment the code.
     F*
413dAF*    02/10/00  RH/DAS  4.13d
     F*      - Revised routine DSPSCR to not set off indicator 92.
     F*
413eAF*    02/02/00  MLB  4.13e
     F*      - Revised routine ZZWHSE to correct IF statements from
     F*        $PRTN to $ARTN.
     F*      - Revised routine ZZWHSE to correct statements from
     F*        $PMSG to $AMSG.
     F*
413fAF*    02/14/00  HNK  4.13
     F*      - Revised to ignore Idle task in ZZCKU2 routine.
     F*        Only indirect task used to subtract overlapping task.
413gAF*    03/28/00  DAS  4.13g
     F*      - Added file PIRTRAN1.
     F*      - Revised ZZTASK to first look at PIRTRAN1 for a status
     F*        '2' record. This will save reading through every record
     F*        for the employee.
414 AF*    06/22/99  DAS  4.14
     F*      - Added APICVTSLT to ZZCHK2/3 routines.                   d
414aAF*    07/17/00  RRH  4.14a
     F*      - For Virtual (Manual) put away,
     F*        Can put in pick slot if NO overflow slots exist for item
414bAF*    07/17/00  RRH  4.14b
     F*      - For Virtual (Manual) put away,
     F*        If item has hard designation code, can only put into
     F*        slot with matching designation code.
414cAF*    07/19/00  RRH  4.14c
     F*      - Correct # for Do loop in ZZCKNS
414dAF*    07/19/00  RRH  4.14d
     F*      - Change for staging, can have multiple license #
     F*        records in license file.
414eAF*    09/13/00  HNK  4.14e
     F*      - Display Y/N if there is stock in any overflow slot
     F*        for the item.
414hAF*    10/25/00  RRH  4.14g
     F*      - Don't lock VSLOT records in ZZCKSL.
414hAF*    10/25/00  RRH  4.14g
     F*      - Don't lock VSLOT records in ZZCKSL.
415aAF*    11/20/00  RRH  4.15a
     F*      - Fix, when pick slot is empty, status=A, expiration
     F*        date was not getting set to new expiration date.
415bAF*    01/08/00  RRH  4.15b
     F*      - Fix, Allow return trans. PUTRTN.
415cAF*    01/08/01  RH   4.15c
     F*      - Add scan label #.
     F*      - If multiple label records exist in Label Link file,
     F*        call LL145 list program.
     F*      - If label# scanned, get trans # from cross reference file
415dAF*    02/08/01  RH   4.15d
     F*      - For returns, not fixed pick slot, set pick priority = 9.
415eAF*    04/03/01  RH   4.15e
     F*      - Allow override to put Non date sensitive item into
     F*        Pick slot.
415fAF*    04/10/01  MLB  4.15f
     F*      - Revised pgm to retrieve pick slot for item or last
     F*        overflow slot if no pick found.
415gAF*    05/17/01  RH   4.15g
     F*      - Fix 4.13d code. Wrong line was commented out and allowed
     F*        F12 when it should have been protected.
415hAF*    05/29/01  RH   4.15h
     F*      - Add ITEMMSC to check multiple pick options.
     F*      - Note: IMNRPK can = 0 to allow no pick slots.
     F*      - Do not check for # of pick slots if overflow slot.
415iAF*    06/29/01  RH   4.15i
     F*      - Do not allow put away to Inactive slot (status=I).
415jAF*    07/27/01  DAS  4.15j
     F*      - Added verification for scanned slot.
415kAF*    08/02/01  DAS/RH  4.15k
     F*      - Added SCREEN4 to verify pallet quantity.
     F*      - Add log file LOG200 to track verify quantity.
     F*         - Not implemented at this time.
415lAF*    07/03/01  MLB  4.15l
     F*      - Fix, F5=Refresh was re-activating F12=Cancel when user
     F*        only performed a partial put away, thereby allowing the
     F*        user to exit.
415mAF*    08/16/01 RH/HNK 4.15M
     F*      - Error only for # of pick slots if putting in pick slot.
     F*
415nAF*    08/23/01  DAS  4.15n
     F*      - Revised to handle SSB items correctly.
     F*      - Note: LBUTYP accurately reflects the quantity bucket
     F*        to be updated.
     F*
416aAF*    09/21/01  RH   4.16a
     F*      - Fix - Update entered date if slot is empty.
416bAF*    12/05/01  DAS  4.16b
     F*      - Added to 4.15m to only do check for fixed slots.
416cAF*    10/30/01  MLB  4.16c
     F*      - Revised routine ZZCKNS to set off NEWVS each time
     F*        routine is executed.
416dAF*    01/08/02  MLB  4.16d
     F*      - Revised program to add support for scanning multiple
     F*        license plates during put away.
416eAF*    02/20/02  MLB  4.16e
     F*      - Revised msgid RC20008 to include user that scanned in
     F*        license/label#.
     F*      - Revised ZZCHK6 to only delete an entry whose status has
     F*        changed if the number entered same as match number.
416fAF*    05/23/02  RRH  4.16
     F*      - Change W1LCNS, W5LCNS to 15 Alphanumeric.
     F*      - Left justify, remove leading blanks for license
416gAF*    07/02/02  RH   4.16g
     F*      - Recompiled, ITEMMSC changed.
416hAF*    02/06/02  MLB  4.16h
     F*      - Revised program to correct situation in ZZUPD5 where
     F*        the wrong transaction number was being processed after
     F*        returning from a later display and then returning to
     F*        the same display.
416iAF*    08/13/02  MLB  4.16i
     F*      - Fix: Revised ZZUPD3 to do a Z-SUB instead of Z-ADD when
     F*        updating SLPRTY.
     F*      - Fix: Revised ZZUPD3 to only update SLEXPD when SVEXPD
     F*        is greater than zero.
416jAF*    08/15/02  MLB  4.16j
     F*      - Fix: Revised ZZUPD5 to load 'L' adding label numbers.
     F*      - Fix: Revised ZZUPD5 to Read WORKPUT file when only one
     F*        record left to make sure correct record is read.
     F*        Added error message if "putaway transaction" isn't found.
416kAF*    08/21/02  RH   4.16k
     F*      - Revised ZZUPD3 to use the oldest expiration date to
     F*        update the slot.
     F*      - Revised ZZUPD3 for return put away to NOT set priority
     F*        to -9 for a reserved pick slot.
416lAF*    08/26/02  RH   4.16l
     F*      - Revised ZZCHK3 to only check overflow slots for existing
     F*        product with quantity and different date.
416mAF*    09/25/02  RH   4.16m
     F*      - Revised to create virutal slot with same status as base
     F*        if base is not Z or V.
416nAF*    10/01/02  RH   4.16n
     F*      - Process skipped records after all others.
416oAF*    11/01/02  MLB  4.16o
     F*      - Revised routine ZZCKSL to set off NEWVS each time
     F*        routine is executed.
416pAF*    11/20/02  MLB  4.16p
     F*      - Fix: Revised routine ZZUPD6 to clear CURTSK,CURTYP
     F*        prior to ZZTASK being called.
416qAF*    12/04/02  MLB  4.16q
     F*      - Enh: Revised program to verify that slot selected
     F*        for putaway is not at inactive status.
416rAF*    12/18/02  MLB  4.16r
     F*      - Fix: Revised routine ZZGET3 to load 'None' instead
     F*        of '*NONE*' in W3TOSL. Was causing RF equip lockups.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  01 - 20   FIELD POSITION TO
     F*  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     F*  90        VIEW MODE (PROTECT INPUT FIELDS)
     F*  91        CHANGE MODE (PROTECT KEY)
     F*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     F*  98        ERROR ON SCREEN (SOUND BUZZER)
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FRC200FM   CF   E             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
410 MFPIRTRAN   UF A E           K DISK
     FLABEL7    IF   E           K DISK
     FLICENSE   IF   E           K DISK
221 AFOPTIONS   IF   E           K DISK
409 AFSLOT3     IF   E           K DISK
409 AFSLOT2     UF A E           K DISK
     F                                     RENAME(SLREC:RECORD)
409 AFVSLOT2    UF A E           K DISK
409 AFPOMFR1    IF   E           K DISK
409 AFLABEL     UF A E           K DISK
410 AFTASK      IF   E           K DISK
410 AFPIRTRAN2  IF   E           K DISK
     F                                     RENAME(PTREC:PTREC2)
413gDF**          PTREC                             KRENAMEPTREC1
410 AFPIRUSER   IF   E           K DISK
412 AFPIRITEM   IF   E           K DISK
413gAFPIRTRAN1  IF   E           K DISK
     F                                     RENAME(PTREC:PTREC1)
414bAFDESIG     IF   E           K DISK
415cAFLABELNK1  IF   E           K DISK
415hAFITEMMSC   IF   E           K DISK
416dAFWORKPUT   UF A E           K DISK
416dAFWORKPUT1  IF   E           K DISK
     F                                     RENAME(WKPREC:WKPREC1)
416dAFWORKPUT2  IF   E           K DISK
     F                                     RENAME(WKPREC:WKPREC2)
415kAF*OG200  O   E           K        DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
412fAD A2              S              1    DIM(2)
412fAD A2N             S              1    DIM(2)
     D A10             S              1    DIM(10)
415cDD*                   DESC    1   1 50
416dDD*                   DESC    1   2 50
416dMD DESC            S             50    DIM(3) CTDATA PERRCD(1)
409 AD HND             S              2    DIM(702)
409 AD LTR             S              1    DIM(27) CTDATA PERRCD(27)
     D*----------------------------------------------------------------
     D*  Redefinition data structures
     D*
     D $CERM           DS
     D  XCERM                  1     60
     D  $CMSG                  1      4
     D*----------------------------------------------------------------
     D*  Redefinition data structures
     D*
     D $AERM           DS
     D  XAERM                  1     60
     D  $AMSG                  1      4
     D*----------------------------------------------------------------
414aAD*  *RCVLBL  -  Receiving options
414aAD*----------------------------------------------------------------
414aAD*
414aAD* Fields
414aAD*
414aAD*    OPLPGM  -  Receiving label program.
414aAD*    OPUPCT  -  Ideal slot usage percentage.
414aAD*    OPPDEF  -  PIR minimum number of slots priority.
414aAD*    OPPBLD  -  PIR same build code priority.
414aAD*    OPPACT  -  PIR same activity zone priority.
414aAD*    OPPASL  -  PIR same aisle priority.
414aAD*    OPPFRC  -  Forced PIR same aisle priority.
414aAD*    OPFDEF  -  Fixed minimum number or slots priority.
414aAD*    OPFASL  -  Fixed same aisle priority.
414aAD*    OPFSID  -  Fixed same side priority.
414aAD*    OPFLVL  -  Fixed highest level priority.
414aAD*    OPPASL  -  PIR same aisle priority.
414aAD*    OPPFRC  -  Force PIR same aisle priority.
414aAD*    OPPLCN  -  Use generic license plates.
414aAD*    OPPCHM  -  Check chimney (Y,N)
414aAD*    OPPMIX  -  Allow mixed expiration dates in fixed home slot(Y,N)
414aAD*    OPAPCK  -  Assign pick slots automatically for fixed items(Y,N)
221 AD* Data structure
221 AD*
221 AD OPDATA          DS
221 AD  OPLPGM                 1     10
221 AD  OPUPCT                11     13  0
221 AD  OPPDEF                14     14  0
221 AD  OPPBLD                15     15  0
221 AD  OPPACT                16     16  0
221 AD  OPFDEF                17     17  0
221 AD  OPFASL                18     18  0
221 AD  OPFSID                19     19  0
221 AD  OPFLVL                20     20  0
221 AD  OPPASL                21     21  0
221 AD  OPPFRC                22     22
221 AD  OPPLCN                23     23
221 AD  OPTEND               117    117
414aAD*----------------------------------------------------------------
414aAD*  *SYSTEM  -  System options.
414aAD*----------------------------------------------------------------
414aAD*
414aAD* Fields
414aAD*
414aAD*    OPEPM   -  Using EPM module (Y,N).
414aAD*    OPRF    -  Using RF module (Y,N).
414aAD*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
414aAD*    OPLETD  -  Print letdown labels (Y,N).
414aAD*    OPWRNC  -  Perform catch weight variance check (Y,N).
414aAD*    OPRG1C  -  Catch weight low variance percentage.
414aAD*    OPRG2C  -  Catch weight high variance percentage.
414aAD*    OPIMPI  -  Import item fields from host.(Y,N).
414aAD*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
414aAD*
414aAD* Data structure
414aAD*
414aAD OPDAT2          DS
414aAD  OPEPM                  1      1
414aAD  OPRF                   2      2
414aAD  OPCAPC                 3      3
414aAD  OPLETD                 4      4
414aAD  OPWRNC                 5      5
414aAD  OPRG1C                 6      8  1
414aAD  OPRG2C                 9     11  1
414aAD  OPIMPI                12     12
414aAD  OPMPCK                14     14
414aAD  OPTEN2               117    117
415jAD*----------------------------------------------------------------
415jAD*  *RFPUT   -  RF Putaway options
415jAD*----------------------------------------------------------------
415jAD*
415jAD* Fields
415jAD*
415jAD*    OPVRFY  -  Verify scanned slot for manual putaway (Y,N)
415jAD*
415jAD* Data structure
415jAD*
415jAD OPDAT3          DS
415jAD  OPVRFY                 1      1
415kAD  OPPQTY                 2      2
415jAD  OPTEN3               117    117
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D @FMTIT          C                   CONST('FRMTIT')
     D @FMTSL          C                   CONST('FRMTSL3')
     D @ADJTR          C                   CONST('ADJTRAN  ')
     D @ADJTD          C                   CONST('ADJTSKDET')
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D*
     D $LPARM          DS
     D  $LCMD                  1      8
     D  $LPRG                  9     18
     D  $LUKY                 19     68
     D  $LRTN                 69     76
     D  $LERM                 77    136
     D  $LMSG                 77     80
     D  $LTYPE                81     88
409 AD  $LMPUT                89     89
     D*
     D*   Redefine key
     D*
     D  $LWHSE                19     21  0
     D  $LWHDP                22     26
     D*
     D  $LRTE                 22     26
     D  $LPO                  27     35
     D  $LTRN#                36     42  0
     D*
221 AD  $LTRN1                19     25  0
     D*
415cAD  $LLBLO                19     25  0
415cAD  $LTRN2                26     32  0
     D*----------------------------------------------------------------
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
     D*
     D                 DS
     D  DSHMS                  1      6  0
     D  DSHM                   1      4  0
     D  DSHH                   1      2  0
     D  DSMM                   3      4  0
     D  DSSS                   5      6  0
414 AD*----------------------------------------------------------------
414 AD*  API programs
414 AD*
     D @APICS          C                   CONST('APICVTSLT ')
416dAD*----------------------------------------------------------------
416dAD*  Screen text.
416dAD*
     D W5TXT1          C                   CONST('Last lic#:')
     D W5TXT2          C                   CONST('Last lbl#:')
     D W5ERR1          C                   CONST('End of putaways. Sca-
     D                                     n new nbr.')
     D W6TXT1          C                   CONST('Lic#')
     D W6TXT2          C                   CONST('Lbl#')
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D*
     D*                                   P   1   20ERWHSE
     D*
     D  ERFLD                  1     30
     D*
     D  ERTRN#                 1      4P 0
415hAD*
415hAD  ERNPCK                 1      3P 0
415hAD  ERAPCK                 4      6P 0
416dAD*
416dAD  ERPTXT                 1     10
416dAD  ERPNBR                11     14P 0
416eAD  ERPUSR                15     24
     D                 DS
     D  $EC                    1      2P 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
     D*----------------------------------------------------------------
     D*  PIRTRAN record layout for use as parameters
     D*
     D PTPARM        E DS                  EXTNAME(PIRTRAN)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     D*----------------------------------------------------------------
     D*  Workstation exception data structure
     D*
     D INFDS           DS
     D  STATUS           *STATUS
     D  ROWIN                370    370
     D  COLIN                371    371
     D*----------------------------------------------------------------
     D*  Workstation exception redefinition data structure
     D*
     D                 DS
     D  ROW#                   1      2B 0
     D  ROW                    2      2
     D  COL#                   3      4B 0
     D  COL                    4      4
416eAIWKPREC2
416eAI              WKPUSR                      W2PUSR
416eAI              WKPNBR                      W2PNBR
416eAI              WKPTYP                      W2PTYP
416eAI              WKPTRN                      W2PTRN
416eAI              WKPSTS                      W2PSTS
416eAI              WKPWHS                      W2PWHS
416eAI              WKPWHD                      W2PWHD
416eAI              WKPASL                      W2PASL
416eAI              WKPLOC                      W2PLOC
416eAI              WKPLVL                      W2PLVL
416eAI              WKPHND                      W2PHND
416eAI              WKPDSP                      W2PDSP
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      None
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   MOVE      *ON           *IN97
     C                   MOVE      *OFF          *IN90
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          ERROR
     C                   EXSR      ZZINZ2
     C     ERROR         IFEQ      *ON
     C                   MOVE      'EOJ'         NXTSCR
     C                   ENDIF
     C*
     C     NXTSCR        DOWNE     'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C     NXTSCR        CASEQ     '02 '         SC2
409 AC     NXTSCR        CASEQ     '03 '         SC3
415kAC     NXTSCR        CASEQ     '04 '         SC4
416dAC     NXTSCR        CASEQ     '05 '         SC5
416dAC     NXTSCR        CASEQ     '06 '         SC6
     C                   ENDCS
     C                   ENDDO
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     C                   RETURN
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     CSR   DSPSCR        BEGSR
     C*
     C*   Set ON alarm indicator if error occured
     C*
     CSR   ERROR         IFEQ      *ON
     CSR                 MOVE      *ON           *IN98
     CSR                 ENDIF
     C*
     C*   Overlay screen with error messages
     C*
     C                   EXSR      ZMDMSG
     C*
     C*  Overlay screen with screen to be processed.
     C*
     CSR   NXTSCR        IFEQ      '01 '
     CSR                 EXFMT     SCREEN1                              50
     CSR                 ENDIF
     CSR   NXTSCR        IFEQ      '02 '
     CSR                 EXFMT     SCREEN2                              50
     CSR                 ENDIF
409 ACSR   NXTSCR        IFEQ      '03 '
409 ACSR                 EXFMT     SCREEN3                              50
409 ACSR                 ENDIF
415kACSR   NXTSCR        IFEQ      '04 '
415kACSR                 EXFMT     SCREEN4                              50
415kACSR                 ENDIF
416dACSR   NXTSCR        IFEQ      '05 '
416dACSR                 EXFMT     SCREEN5                              50
416dACSR                 ENDIF
416dACSR   NXTSCR        IFEQ      '06 '
416dACSR                 EXFMT     SCREEN6                              50
416dACSR                 ENDIF
     C*
     C*   Initialize error indicators and fields
     C*
     CSR                 SETOFF                                       010203
     CSR                 SETOFF                                       040506
     CSR                 SETOFF                                       070809
     CSR                 SETOFF                                       101112
     CSR                 SETOFF                                       131415
     CSR                 SETOFF                                       161718
     CSR                 SETOFF                                       1920
     CSR                 SETOFF                                       212223
     CSR                 SETOFF                                       242526
     CSR                 SETOFF                                       272829
     CSR                 SETOFF                                       303132
413aDC*R                   SETOF                     333435
413aMCSR                 SETOFF                                       3334
     CSR                 SETOFF                                       363738
     CSR                 SETOFF                                       3940
415gMCSR                 SETOFF                                       98
415gDC*R                   SETOF                     9298
     CSR                 MOVE      *OFF          WARN              1
     CSR                 MOVE      *OFF          ERROR             1
     CSR                 MOVE      *OFF          CMDTKN            1
414 ACSR                 MOVE      *OFF          REDSPL            1
     CSR                 Z-ADD     0             E                 2 0
     C*
     C*   Initialize error subfile
     C*
     CSR                 EXSR      ZMCMSG
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  Screen 01 initialization
     C*
     CSR   SCR01I        BEGSR
     CSR                 MOVE      '01 '         NXTSCR            3
409 ACSR                 MOVE      'N'           $LMPUT
415lACSR                 MOVE      *OFF          *IN92
415lACSR                 MOVE      *OFF          NEWLB             1
415lACSR                 MOVE      *OFF          NEWVS             1
416dACSR                 MOVE      *BLANKS       W5TXT
416fDC**                   MOVE *ZEROS    W5LST#
416fMCSR                 MOVE      *BLANKS       W5LST#
416dACSR                 MOVE      *ZEROS        W5CNT
416dACSR                 MOVE      *BLANKS       PTATYP
     CSR                 EXSR      ZZFIL1
     CSR                 MOVE      *OFF          REFRSH            1
     CSR   END01I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  Screen 02 initialization
     C*
     CSR   SCR02I        BEGSR
     CSR                 MOVE      '02 '         NXTSCR            3
409 ACSR                 MOVE      'N'           $LMPUT
     CSR                 EXSR      ZZFIL2
     CSR                 MOVE      *OFF          REFRSH
     CSR   END02I        ENDSR
409 AC*----------------------------------------------------------------
409 AC*
409 AC*  Screen 03 initialization
409 AC*
409 ACSR   SCR03I        BEGSR
409 ACSR                 MOVE      '03 '         NXTSCR            3
409 ACSR                 MOVE      *ON           *IN06
409 ACSR                 MOVE      'Y'           $LMPUT
409 ACSR                 MOVE      *OFF          EXIST             1
415lDC*R                   MOVE *OFF      NEWVS   1
415lDC*R                   MOVE *OFF      NEWLB   1
415lAC*
415lAC*    Partial put-away in progress. Load qty remaining.
415lACSR   LBQRMN        IFNE      *ZEROS
415lACSR                 Z-ADD     LBQRMN        W3RQTY
415lACSR                 ELSE
409 ACSR                 Z-ADD     LBQPCK        W3RQTY            7 0
415lACSR                 ENDIF
409 ACSR                 Z-ADD     LBQALC        W3AQTY            7 0
409 ACSR                 EXSR      ZZGET3
409 ACSR                 EXSR      ZZFIL3
409 ACSR                 MOVE      *OFF          REFRSH
415eACSR                 MOVE      *OFF          OVRRID            1
409 ACSR   END03I        ENDSR
415kAC*----------------------------------------------------------------
415kAC*
415kAC*  Screen 04 initialization  (Screen 1A)
415kAC*
415kACSR   SCR04I        BEGSR
415kACSR                 MOVE      '04 '         NXTSCR            3
415kACSR                 MOVE      *ON           *IN06
415kACSR                 MOVE      'Y'           $LMPUT
415kACSR                 MOVE      *OFF          EXIST             1
415kACSR                 MOVE      *OFF          NEWVS             1
415kACSR                 MOVE      *OFF          NEWLB             1
415kACSR                 EXSR      ZZGET4
415kACSR                 EXSR      ZZFIL4
415kACSR                 MOVE      *OFF          REFRSH
415kACSR   END04I        ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  Screen 05 initialization
416dAC*
416dACSR   SCR05I        BEGSR
416dACSR                 MOVE      '05 '         NXTSCR            3
416dACSR                 MOVE      *OFF          EXIST             1
416dACSR                 MOVE      *OFF          NEWVS             1
416dACSR                 MOVE      *OFF          NEWLB             1
416hACSR                 MOVE      *OFF          FRSTPS
416dACSR                 EXSR      ZZGET5
416dACSR                 EXSR      ZZFIL5
416dACSR                 MOVE      *OFF          REFRSH
416dACSR   END05I        ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  Screen 06 initialization
416dAC*
416dACSR   SCR06I        BEGSR
416dACSR                 MOVE      '06 '         NXTSCR            3
416dACSR                 MOVE      *OFF          EXIST             1
416dACSR                 MOVE      *OFF          NEWVS             1
416dACSR                 MOVE      *OFF          NEWLB             1
416dAC*    User hasn't skipped a put away. Start with first one.
416dACSR   SKIP6         IFEQ      *OFF
416dACSR   PKKEY1        SETLL     WORKPUT1
416dACSR                 MOVE      *ZEROS        W6CNT1
416nDC**                   ELSE
416nDC**                   MOVE *OFF      SKIP6
416dACSR                 ENDIF
416dACSR                 EXSR      ZZGET6
416dAC*    End of putaways for this user - Return to Screen 1.
416dACSR   NOMORE        IFEQ      *ON
416dACSR                 EXSR      SCR01I
416dACSR                 GOTO      END06I
416dACSR                 ENDIF
416dACSR                 EXSR      ZZFIL6
416dACSR                 MOVE      *OFF          REFRSH
416dACSR   END06I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     CSR   SC1           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     CSR   *INKC         IFEQ      *ON
416dAC*    Remove any existing previously scanned in entries for this user.
416dACSR                 EXSR      ZZDLPK
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for F5 - Refresh
     C*
     CSR   *INKE         IFEQ      *ON
     CSR                 MOVE      *ON           REFRSH
416dACSR                 MOVE      NXTSCR        LSTSCR            3
     CSR                 EXSR      SCR01I
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      *ON
416dAC*    Remove any existing previously scanned in entries for this user.
416dACSR                 EXSR      ZZDLPK
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 GOTO      ENDSC1
     CSR                 END
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     CSR                 MOVE      '*BEFORE '    CMDCHK            8
     CSR                 EXSR      ZZCMD1
     CSR   CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     CSR                 EXSR      ZZCHK1
     CSR   ERROR         CABEQ     *ON           ENDSC1
     CSR                 EXSR      ZZUPD1
     CSR   ERROR         CABEQ     *ON           ENDSC1
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     CSR                 MOVE      '*AFTER  '    CMDCHK
     CSR                 EXSR      ZZCMD1
     CSR   CMDTKN        CABEQ     *ON           ENDSC1
     C*
     CSR   ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SC2  -  Screen 2
     C*
     CSR   SC2           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     CSR   *INKC         IFEQ      *ON
     CSR                 EXSR      ZZABRT
     CSR                 MOVE      'EOJ'         NXTSCR
416dAC*    Remove any existing previously scanned in entries for this user.
416dACSR                 EXSR      ZZDLPK
     CSR                 GOTO      ENDSC2
     CSR                 ENDIF
     C*
     C*  Test for F5 - Refresh
     C*
     CSR   *INKE         IFEQ      *ON
     CSR                 MOVE      *ON           REFRSH
     CSR                 EXSR      SCR02I
     CSR                 GOTO      ENDSC2
     CSR                 ENDIF
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      *ON
     CSR                 MOVE      *OFF          REFRSH
     CSR                 EXSR      ZZABRT
416dACSR                 SELECT
416dAC*    Return to select screen to select new putaway.
416dACSR   LSTSCR        WHENEQ    '06 '
416dACSR                 EXSR      SCR06I
416dAC*
416dAC*    Return to scan screen to scan in more putaways.
416dACSR   LSTSCR        WHENEQ    '05 '
416dACSR                 EXSR      SCR05I
416dAC*
416dACSR                 OTHER
416dAC*
     CSR                 EXSR      SCR01I
416dACSR                 ENDSL
     CSR                 GOTO      ENDSC2
     CSR                 ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     CSR                 MOVE      '*BEFORE '    CMDCHK            8
     CSR                 EXSR      ZZCMD2
     CSR   CMDTKN        CABEQ     *ON           ENDSC2
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     CSR                 EXSR      ZZCHK2
     CSR   ERROR         CABEQ     *ON           ENDSC2
414 ACSR   REDSPL        CABEQ     *ON           ENDSC2
     CSR                 EXSR      ZZUPD2
     CSR   ERROR         CABEQ     *ON           ENDSC2
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     CSR                 MOVE      '*AFTER  '    CMDCHK
     CSR                 EXSR      ZZCMD2
     CSR   CMDTKN        CABEQ     *ON           ENDSC2
     C*
     CSR   ENDSC2        ENDSR
409 AC*----------------------------------------------------------------
409 AC*
409 AC*  SC3  -  Screen 3
409 AC*
409 ACSR   SC3           BEGSR
409 AC*
409 AC*  Test for F3 - Exit
409 AC*
409 ACSR   *INKC         IFEQ      *ON
412CACSR   *IN92         ANDEQ     *OFF
409 ACSR                 EXSR      ZZABRT
409 ACSR                 MOVE      'EOJ'         NXTSCR
416dAC*    Remove any existing previously scanned in entries for this user.
416dACSR                 EXSR      ZZDLPK
409 ACSR                 GOTO      ENDSC3
409 ACSR                 ENDIF
409 AC*
409 AC*  Test for F5 - Refresh
409 AC*
409 ACSR   *INKE         IFEQ      *ON
409 ACSR                 MOVE      *ON           REFRSH
409 ACSR                 EXSR      SCR03I
409 ACSR                 GOTO      ENDSC3
409 ACSR                 ENDIF
409 AC*
409 AC*  Test for F12 - Previous
409 AC*
409 ACSR   *INKL         IFEQ      *ON
412CACSR   *IN92         ANDEQ     *OFF
409 ACSR                 MOVE      *OFF          REFRSH
409 ACSR                 EXSR      ZZABRT
416dACSR                 SELECT
416dAC*    Return to select screen to select new putaway.
416dACSR   LSTSCR        WHENEQ    '06 '
416dACSR                 EXSR      SCR06I
416dAC*
416dAC*    Return to scan screen to scan in more putaways.
416dACSR   LSTSCR        WHENEQ    '05 '
416dACSR                 EXSR      SCR05I
416dAC*
416dACSR                 OTHER
416dAC*
409 ACSR                 EXSR      SCR01I
416dACSR                 ENDSL
409 ACSR                 GOTO      ENDSC3
409 ACSR                 ENDIF
409 AC*
409 AC*  Test for other command keys BEFORE verification and update.
409 AC*
409 ACSR                 MOVE      '*BEFORE '    CMDCHK            8
409 ACSR                 EXSR      ZZCMD3
409 ACSR   CMDTKN        CABEQ     *ON           ENDSC3
409 AC*
409 AC*  Some other key pressed.
409 AC*
409 AC*     Check input and write/update record.
409 AC*
409 ACSR                 EXSR      ZZCHK3
409 ACSR   ERROR         CABEQ     *ON           ENDSC3
414 ACSR   REDSPL        CABEQ     *ON           ENDSC3
409 ACSR                 EXSR      ZZUPD3
409 ACSR   ERROR         CABEQ     *ON           ENDSC3
409 AC*
409 AC*  Test for other command keys AFTER verification and update.
409 AC*
409 ACSR                 MOVE      '*AFTER  '    CMDCHK
409 ACSR                 EXSR      ZZCMD3
409 ACSR   CMDTKN        CABEQ     *ON           ENDSC3
409 AC*
409 ACSR   ENDSC3        ENDSR
415kAC*----------------------------------------------------------------
415kAC*
415kAC*  SC4  -  Screen 4  (Screen1A)
415kAC*
415kACSR   SC4           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     CSR   *INKC         IFEQ      *ON
     CSR   *IN92         ANDEQ     *OFF
416dAC*
416dAC*    Abort needed only when transaction# scanned in. For all
416dAC*    other types, transaction not put into inuse status until
416dAC*    transaction scanned for putaway.
416dACSR   PTATYP        IFEQ      '*TRAN   '
     CSR                 EXSR      ZZABRT
416dACSR                 ENDIF
416dAC*    Remove any existing previously scanned in entries for this user.
416dACSR                 EXSR      ZZDLPK
     CSR                 MOVE      'EOJ'         NXTSCR
     CSR                 GOTO      ENDSC4
     CSR                 ENDIF
     C*
     C*  Test for F5 - Refresh
     C*
     CSR   *INKE         IFEQ      *ON
     CSR                 MOVE      *ON           REFRSH
     CSR                 EXSR      SCR04I
     CSR                 GOTO      ENDSC4
     CSR                 ENDIF
     C*
     C*  Test for F12 - Previous
     C*
     CSR   *INKL         IFEQ      *ON
     CSR   *IN92         ANDEQ     *OFF
     CSR                 MOVE      *OFF          REFRSH
416dAC*
416dAC*    Abort needed only when transaction# scanned in. For all
416dAC*    other types, transaction not put into inuse status until
416dAC*    transaction scanned for putaway.
416dACSR   PTATYP        IFEQ      '*TRAN   '
     CSR                 EXSR      ZZABRT
416dACSR                 ENDIF
416daCSR                 SELECT
416dAC*    Return to scan in more lic#/lbl#'s.
416dACSR   LSTSCR        WHENEQ    '05 '
416dACSR                 EXSR      SCR05I
416dACSR                 OTHER
416dAC*    Remove any existing previously scanned in entries for this user.
416dACSR                 EXSR      ZZDLPK
     CSR                 EXSR      SCR01I
416dACSR                 ENDSL
     CSR                 GOTO      ENDSC4
     CSR                 ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     CSR                 MOVE      '*BEFORE '    CMDCHK            8
     CSR                 EXSR      ZZCMD4
     CSR   CMDTKN        CABEQ     *ON           ENDSC4
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     CSR                 EXSR      ZZCHK4
     CSR   ERROR         CABEQ     *ON           ENDSC4
     CSR                 EXSR      ZZUPD4
     CSR   ERROR         CABEQ     *ON           ENDSC4
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     CSR                 MOVE      '*AFTER  '    CMDCHK
     CSR                 EXSR      ZZCMD4
     CSR   CMDTKN        CABEQ     *ON           ENDSC4
     C*
     CSR   ENDSC4        ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  SC5  -  Screen 5
416dAC*
416dACSR   SC5           BEGSR
416dAC*
416dAC*  Test for F3 - Exit
416dAC*
416dACSR   *INKC         IFEQ      *ON
416dACSR                 MOVE      *OFF          REFRSH
416dAC*    Remove any existing previously scanned in entries for this user.
416dACSR                 EXSR      ZZDLPK
416dACSR                 EXSR      SCR01I
416dACSR                 GOTO      ENDSC5
416dACSR                 ENDIF
416dAC*
416dAC*  Test for F5 - Refresh
416dAC*
416dACSR   *INKE         IFEQ      *ON
416dACSR                 MOVE      *ON           REFRSH
416dACSR                 EXSR      SCR05I
416dACSR                 GOTO      ENDSC5
416dACSR                 ENDIF
416dAC*
416dAC*  Test for F12 - Previous
416dAC*
416dACSR   *INKL         IFEQ      *ON
416dACSR                 MOVE      *OFF          REFRSH
416dAC*    Remove any existing previously scanned in entries for this user.
416dACSR                 EXSR      ZZDLPK
416dACSR                 EXSR      SCR01I
416dACSR                 GOTO      ENDSC5
416dACSR                 ENDIF
416dAC*
416dAC*  Test for other command keys BEFORE verification and update.
416dAC*
416dACSR                 MOVE      '*BEFORE '    CMDCHK            8
416dACSR                 EXSR      ZZCMD5
416dACSR   CMDTKN        CABEQ     *ON           ENDSC5
416dAC*
416dAC*  Some other key pressed.
416dAC*
416dAC*     Check input and write/update record.
416dAC*
416dACSR                 EXSR      ZZCHK5
416dACSR   ERROR         CABEQ     *ON           ENDSC5
416dACSR                 EXSR      ZZUPD5
416dACSR   ERROR         CABEQ     *ON           ENDSC5
416dAC*
416dAC*  Test for other command keys AFTER verification and update.
416dAC*
416dACSR                 MOVE      '*AFTER  '    CMDCHK
416dACSR                 EXSR      ZZCMD5
416dACSR   CMDTKN        CABEQ     *ON           ENDSC5
416dAC*
416dACSR   ENDSC5        ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  SC6  -  Screen 6
416dAC*
416dACSR   SC6           BEGSR
416dAC*
416dAC*  Test for F3 - Exit
416dAC*
416dACSR   *INKC         IFEQ      *ON
416dACSR                 MOVE      *OFF          REFRSH
416dACSR                 EXSR      SCR05I
416dACSR                 GOTO      ENDSC6
416dACSR                 ENDIF
416dAC*
416dAC*  Test for F5 - Refresh
416dAC*
416dACSR   *INKE         IFEQ      *ON
416dACSR                 MOVE      *ON           REFRSH
416dACSR                 EXSR      SCR06I
416dACSR                 GOTO      ENDSC6
416dACSR                 ENDIF
416dAC*
416dAC*  Test for F12 - Previous
416dAC*
416dACSR   *INKL         IFEQ      *ON
416dACSR                 MOVE      *OFF          REFRSH
416dACSR                 EXSR      SCR05I
416dACSR                 GOTO      ENDSC6
416dACSR                 ENDIF
416dAC*
416dAC*  Test for other command keys BEFORE verification and update.
416dAC*
416dACSR                 MOVE      '*BEFORE '    CMDCHK            8
416dACSR                 EXSR      ZZCMD6
416dACSR   CMDTKN        CABEQ     *ON           ENDSC6
416dAC*
416dAC*  Some other key pressed.
416dAC*
416dAC*     Check input and write/update record.
416dAC*
416dACSR                 EXSR      ZZCHK6
416dACSR   ERROR         CABEQ     *ON           ENDSC6
416dACSR                 EXSR      ZZUPD6
416dACSR   ERROR         CABEQ     *ON           ENDSC6
416dAC*
416dAC*  Test for other command keys AFTER verification and update.
416dAC*
416dACSR                 MOVE      '*AFTER  '    CMDCHK
416dACSR                 EXSR      ZZCMD6
416dACSR   CMDTKN        CABEQ     *ON           ENDSC6
416dAC*
416dACSR   ENDSC6        ENDSR
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     CSR   *INZSR        BEGSR
     C*
     C*  Initialize special keys
     C*
     C                   Z-ADD     0             ENTER             5 0
     C                   Z-ADD     2             COMAND            5 0
     C                   Z-ADD     01122         ROLLUP            5 0
     C                   Z-ADD     01123         ROLLDN            5 0
     C                   Z-ADD     01124         CLEAR             5 0
     C                   Z-ADD     01125         HELP              5 0
     C*
     C*  Initialize message handling
     C*
     C                   EXSR      ZMIMSG
     C*
     C*   Call user added initialization routine.
     C*
     C                   EXSR      ZZINZ
     C                   ENDSR
415hAC*---------------------------------------------------------------
415hAC*  Retrieve number of pick slots for item and accumulate
415hAC*  number of pick slots assigned to item.
415hAC*
415hACSR   CHKPCK        BEGSR
415hACSR   ITKEY         CHAIN     ITEMMSC                            79
415hACSR   *IN79         IFEQ      *ON
415hACSR                 Z-ADD     1             IMNRPK
415hACSR                 ENDIF
415hAC*
415hAC*    Accumulate number of pick slots assigned to item.
415hAC*
415hACSR                 MOVE      'A '          K3STAT
415hACSR                 MOVE      'Y'           K3PICK
415hACSR   KEYS3         SETLL     SLOT3
415hACSR                 MOVE      *ZEROS        NBRPCK
415hACSR                 MOVE      *OFF          EOF               1
415hACSR   EOF           DOWEQ     *OFF
415hACSR   KEYS3         READE     SLOT3                                  79
415hACSR                 MOVE      *IN79         EOF
415hACSR   *IN79         IFEQ      *OFF
415hACSR                 ADD       1             NBRPCK
415hACSR                 ENDIF
415hACSR                 ENDDO
415hACSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMCMSG  Clear message record subfile
     C*
     CSR   ZMCMSG        BEGSR
     CSR                 MOVE      *OFF          *IN97
     CSR                 WRITE     MSGCTL
     CSR                 Z-ADD     *ZERO         MSGK              4 0
     CSR                 WRITE     MSGCLR
     CSR                 MOVE      '*CLEAR '     #MSGID            7
     CSR                 MOVE      '*NULL  '     #MSGTP            7
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*
     C*    ZMDMSG  Display message record subfile
     C*
     CSR   ZMDMSG        BEGSR
     CSR                 MOVE      *ON           *IN97
     CSR   MSGK          IFGT      0
     CSR                 WRITE     MSGCTL
     CSR                 Z-ADD     *ZERO         MSGK
     CSR                 END
     CSR                 ENDSR
     C*
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     CSR   ZMIMSG        BEGSR
     CSR                 MOVE      #PROG         #PGMQ            10
     CSR                 EXSR      ZMCMSG
     CSR                 ENDSR
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     CSR   ZMPMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
     CSR                 MOVE      #MSGF         $MSGF            10
     CSR                 END
     CSR                 CALL      'PUTMSG'
     CSR                 PARM                    $MSGF
     CSR                 PARM                    #MSGID
     CSR                 PARM                    #MSGTP
     CSR                 PARM                    #MSGDT
     CSR                 PARM                    #PGMQ
     CSR                 PARM                    #MSGK
     CSR   #MSGID        IFNE      '*CLEAR '
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 END
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*    ZSCLR   Clear screen
     C*
     CSR   ZSCLR         BEGSR
     CSR                 WRITE     CLRSCR
     CSR                 MOVE      *ON           SCLEAR            1
     CSR                 ENDSR
     C*
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     CSR   ZMQMSG        BEGSR
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR7971  Error in writing a record.
     C*
     CSR   ZM71          BEGSR
     CSR                 MOVE      'PIR7971'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR7972  Error in updating a record.
     C*
     CSR   ZM72          BEGSR
     CSR                 MOVE      'PIR7972'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*     PIR7979  Record does not exist.
     C*
     CSR   ZM7979        BEGSR
     CSR                 MOVE      'PIR7979'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   LP11022  Invalid license number.
     C*
     CSR   ZM1022        BEGSR
     CSR                 MOVE      'LP11022'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   RC20001  Invalid slot entered.(TO)
     C*
     CSR   ZM2001        BEGSR
     CSR                 MOVE      'RC20001'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   RC20002 Transaction is closed.
     C*
     CSR   ZM2002        BEGSR
     CSR                 MOVE      'RC20002'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
409 AC*----------------------------------------------------------------
409 AC*   RC20003 Quantity must be > 0.
409 AC*
409 ACSR   ZM2003        BEGSR
409 ACSR                 MOVE      'RC20003'     #MSGID
409 ACSR                 MOVE      '*DIAG  '     #MSGTP
409 ACSR                 MOVEA     ERRMSG        $MD(1)
409 ACSR                 EXSR      ZMPMSG
409 ACSR                 ENDSR
409 AC*----------------------------------------------------------------
409 AC*   RC20004 Quantity can't be > quantity to put away.
409 AC*
409 ACSR   ZM2004        BEGSR
409 ACSR                 MOVE      'RC20004'     #MSGID
409 ACSR                 MOVE      '*DIAG  '     #MSGTP
409 ACSR                 MOVEA     ERRMSG        $MD(1)
409 ACSR                 EXSR      ZMPMSG
409 ACSR                 ENDSR
414aAC*----------------------------------------------------------------
414aAC*   RC20005 Can't put in pick slot, overflow exists.
414aAC*
414aACSR   ZM2005        BEGSR
414aACSR                 MOVE      'RC20005'     #MSGID
414aACSR                 MOVE      '*DIAG  '     #MSGTP
414aACSR                 MOVEA     ERRMSG        $MD(1)
414aACSR                 EXSR      ZMPMSG
414aACSR                 ENDSR
414bAC*----------------------------------------------------------------
414bAC*   RC20006 For hard designation code, slot desig. doesn't match.
414bAC*
414bACSR   ZM2006        BEGSR
414bACSR                 MOVE      'RC20006'     #MSGID
414bACSR                 MOVE      '*DIAG  '     #MSGTP
414bACSR                 MOVEA     ERRMSG        $MD(1)
414bACSR                 EXSR      ZMPMSG
414bACSR                 ENDSR
415iAC*----------------------------------------------------------------
415iAC*   RC20007 Can't put in inactive slot.
415iAC*
415iACSR   ZM2007        BEGSR
415iACSR                 MOVE      'RC20007'     #MSGID
415iACSR                 MOVE      '*DIAG  '     #MSGTP
415iACSR                 MOVEA     ERRMSG        $MD(1)
415iACSR                 EXSR      ZMPMSG
415iACSR                 ENDSR
416DAC*----------------------------------------------------------------
416dAC*   RC20008 License/Label already scanned in.
416dAC*
416dACSR   ZM2008        BEGSR
416dACSR                 MOVE      'RC20008'     #MSGID
416dACSR                 MOVE      '*DIAG  '     #MSGTP
416dACSR                 MOVEA     ERRMSG        $MD(1)
416dACSR                 EXSR      ZMPMSG
416dACSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0105
     C*
     CSR   ZM0105        BEGSR
     CSR                 MOVE      'PIR0105'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
221 AC*   PIR0204  Enter only one value.
221 AC*
221 ACSR   ZM0204        BEGSR
221 ACSR                 MOVE      'PIR0204'     #MSGID
221 ACSR                 MOVE      '*DIAG  '     #MSGTP
221 ACSR                 MOVE      *BLANKS       $MD
221 ACSR                 EXSR      ZMPMSG
221 ACSR                 ENDSR
221 AC*----------------------------------------------------------------
221 AC*   PIR0205  Must enter one value.
221 AC*
221 ACSR   ZM0205        BEGSR
221 ACSR                 MOVE      'PIR0205'     #MSGID
221 ACSR                 MOVE      '*DIAG  '     #MSGTP
221 ACSR                 MOVE      *BLANKS       $MD
221 ACSR                 EXSR      ZMPMSG
221 ACSR                 ENDSR
     C*----------------------------------------------------------------
     C*    PIR1001  Invalid option entered.
     C*
     CSR   ZM1001        BEGSR
     CSR                 MOVE      'PIR1001'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR1005  Value must be 'Y' or 'N'
     C*
     CSR   ZM1005        BEGSR
     CSR                 MOVE      'PIR1005'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
412fAC*     IT15204  Virtual slot could not be created.
     C*
     CSR   ZM1524        BEGSR
     CSR                 MOVE      'IT15204'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*     IT25201  Date sensitive item exists in to slot with dif dte
     C*
     CSR   ZM2521        BEGSR
     CSR                 MOVE      'IT25201'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
415hAC*     IT25206  # of pick slots exceeds # allowed.
415hAC*
415hACSR   ZM5206        BEGSR
415hACSR                 MOVE      'IT25206'     #MSGID
415hACSR                 MOVE      '*DIAG  '     #MSGTP
415hACSR                 Z-ADD     NBRPCK        ERNPCK
415hACSR                 Z-ADD     IMNRPK        ERAPCK
415hACSR                 MOVEA     ERRMSG        $MD(1)
415hACSR                 EXSR      ZMPMSG
415hACSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR9905  Cursor not in correct position for lookup.
     C*
     CSR   ZM9905        BEGSR
     CSR                 MOVE      'PIR9905'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZABRT   Abort a transaction
     C*
     CSR   ZZABRT        BEGSR
     CSR                 MOVE      PTTASK        @PTASK
     CSR                 Z-ADD     LBCUBE        @PCUBE
     CSR                 Z-ADD     LBSWGT        @PSWGT
     CSR                 CALL      @ADJTR
     CSR                 PARM      '*UNDO   '    @PCMD             8
     CSR                 PARM                    #JOB
     CSR                 PARM      PTTRN#        @PTRN#            7 0
     CSR                 PARM                    @PTASK            6
     CSR                 PARM      W1WHSE        @PWHSE            3 0
     CSR                 PARM      LBWHDP        @PWHDP            5
     CSR                 PARM      LBSTYP        @PSTYP            1
     CSR                 PARM                    @PCUBE            9 3
     CSR                 PARM                    @PSWGT            9 2
     CSR                 PARM      LBQPCK        @PPCS             5 0
     CSR                 PARM      0             @PAISL            5 0
     CSR                 PARM      0             @PQTY1            5 0
     CSR                 PARM      0             @PQTY2            5 0
     CSR                 PARM      0             @PQTY3            5 0
     CSR                 PARM      '0'           @PRTE             5
     CSR                 PARM      ' '           @PPO              9
410 ACSR                 PARM      'P'           @PGRP1            1
410 DC*R                   PARM 'L'       @PGRP1  1
     CSR                 PARM      ' '           @PGRP2            1
     CSR                 PARM      ' '           @PRTN             8
     CSR                 PARM      ' '           @PMSG             4
410 AC*    Start an 'IDLE' task.
410 ACSR                 EXSR      ZZIDLE
     CSR   ENDABR        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCKU2   Check for overlapping task and update the current
     C*           task just ended, by adjusting the time.
     C*
     CSR   ZZCKU2        BEGSR
     CSR   *LIKE         DEFINE    PTTRN#        SVTRN#
     CSR   *LIKE         DEFINE    PTDMIN        SVTLEN
     CSR                 Z-ADD     0             SVTLEN
     CSR   PTKEY2        SETLL     PIRTRAN2
     CSR   FOREVR        DOWEQ     FOREVR
     CSR                 READ      PIRTRAN2                               79
     CSR   *IN79         IFEQ      *ON
     CSR   PTSDTE        ORLT      ZZSDTE
     CSR                 LEAVE
     CSR                 ENDIF
     C*   Skip the task that just ended.
     CSR   *IN79         IFEQ      *OFF
     CSR   PTTRN#        ANDEQ     SVTRN#
     CSR                 ITER
     CSR                 ENDIF
413fAC*
413fAC*   Skip 'IDLE' task
413fAC*
413fACSR   PTTASK        IFEQ      'IDLE'
413fACSR                 ITER
413fACSR                 ENDIF
413fAC*
413fACSR                 MOVE      PTTASK        T#TASK
413fACSR   TKKEY         CHAIN     TASK                               79
413fACSR   *IN79         IFEQ      *ON
413fACSR                 MOVE      ' '           TKTYPE
413fACSR                 ENDIF
     C*   Accumulate overlapping minutes.(Same start and end date)
     C*                  Start     Start       End      End    Overlap
     C*           Task    date      time       time     date   Minutes
     C*Auto  (ZZ) CLEAN 1/25/96  10:00:23   11:30:35  1/25/96
     C*Manual(PT) BREAK 1/25/96  10:30:00   10:45:00  1/25/96   (15)
     C*
     C*   Auto    CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     C*   Manual  BREAK 1/25/96  23:30:00    1:30:00  1/26/96   (120)
     C*
     CSR   *IN79         IFEQ      *OFF
     CSR   PTSDTE        ANDEQ     ZZSDTE
     CSR   PTEDTE        ANDEQ     ZZEDTE
     CSR   PTSTIM        ANDGE     ZZSTIM
     CSR   PTETIM        ANDLE     ZZETIM
413fACSR   TKTYPE        ANDEQ     'I'
410 DC*R         PTETYP    ANDEQ'M'
     CSR                 Z-ADD     PTSTIM        STRTIM
     CSR                 Z-ADD     PTETIM        FINTIM
     CSR                 EXSR      ZZTIME
     CSR                 ADD       TIMLEN        SVTLEN
     CSR                 ENDIF
     C*   Accumulate overlapping minutes(Diff start date/same end date)
     C*                                  (Past midnight)
     C*                  Start     Start       End      End    Overlap
     C*           Task    date      time       time     date   Minutes
     C*Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     C*Manual(PT) BREAK 1/26/96   8:00:00    8:30:00  1/26/96   (30)
     C*
     CSR   *IN79         IFEQ      *OFF
     CSR   PTSDTE        ANDGT     ZZSDTE
     CSR   PTEDTE        ANDEQ     ZZEDTE
     CSR   PTETIM        ANDLE     ZZETIM
413fACSR   TKTYPE        ANDEQ     'I'
410 DC*R         PTETYP    ANDEQ'M'
     CSR                 Z-ADD     PTSTIM        STRTIM
     CSR                 Z-ADD     PTETIM        FINTIM
     CSR                 EXSR      ZZTIME
     CSR                 ADD       TIMLEN        SVTLEN
     CSR                 ENDIF
     C*   Accumulate overlapping minutes.(Same start date/diff end date)
     C*                  Start     Start       End      End    Overlap
     C*           Task    date      time       time     date   Minutes
     C*Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     C*Manual(PT) BREAK 1/25/96  16:00:00   16:30:00  1/25/96   (30)
     C*
     CSR   *IN79         IFEQ      *OFF
     CSR   PTSDTE        ANDEQ     ZZSDTE
     CSR   PTEDTE        ANDLT     ZZEDTE
     CSR   PTSTIM        ANDGE     ZZSTIM
413fACSR   TKTYPE        ANDEQ     'I'
410 DC*R         PTETYP    ANDEQ'M'
     CSR                 Z-ADD     PTSTIM        STRTIM
     CSR                 Z-ADD     PTETIM        FINTIM
     CSR                 EXSR      ZZTIME
     CSR                 ADD       TIMLEN        SVTLEN
     CSR                 ENDIF
     CSR                 ENDDO
     C*
     C*   Update the task that just ended.
     C*
     CSR   SVTRN#        CHAIN     PIRTRAN                            79
     CSR   *IN79         IFEQ      *OFF
     CSR   PTDMIN        IFGT      0
     CSR   PTDMIN        SUB       SVTLEN        PTDMIN
     CSR                 ELSE
     CSR   PTIMIN        SUB       SVTLEN        PTIMIN
     CSR                 ENDIF
     CSR                 UPDATE    PTREC
     CSR                 ENDIF
     CSR   ENDCU2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCLSE   Close a transaction
     C*
     CSR   ZZCLSE        BEGSR
     C*
     CSR                 MOVE      '*CLOSE  '    $LCMD
     CSR                 MOVE      '*INTER  '    $LTYPE
     CSR                 Z-ADD     0             $LWHSE
     CSR                 MOVE      *BLANKS       $LRTE
     CSR                 MOVE      *BLANKS       $LPO
     CSR                 Z-ADD     PTTRN#        $LTRN#
     C*
     CSR                 CALL      'PT132'
     CSR                 PARM                    $LPARM
     C*
     C*   Calculate the time in minutes it took to complete this task.
     C*   PTCTIM is used for end time instead of PTETIM, because close
     C*   time and End time are the same in this case.
     C*
     CSR   *LIKE         DEFINE    PTSTIM        STRTIM
     CSR   *LIKE         DEFINE    PTETIM        FINTIM
     CSR   PTKEY         CHAIN     PIRTRAN                            79
     CSR                 Z-ADD     PTSTIM        STRTIM
     CSR                 Z-ADD     PTCTIM        FINTIM
     CSR                 EXSR      ZZTIME
     CSR                 Z-ADD     TIMLEN        PTDMIN
     CSR                 UPDATE    PTREC
     C*
     C*        There is a posibility that a manual task might have
     C*        been added before the current task was ended. Hence
     C*        adjust the current task just ended, if there is
     C*        any overlapping manual task.
     C*
410 ACSR                 Z-ADD     PTTRN#        SVTRN#
     C*  Past overnight. (PTEDTE > PTSDTE)
410 ACSR   PTEDTE        IFGT      PTSDTE
410 ACSR                 Z-ADD     PTEDTE        STDATE
410 ACSR                 ELSE
410 ACSR                 Z-ADD     PTSDTE        STDATE
410 ACSR                 ENDIF
410 ACSR                 Z-ADD     PTSDTE        ZZSDTE
410 ACSR                 Z-ADD     PTEDTE        ZZEDTE
410 ACSR                 Z-ADD     PTSTIM        ZZSTIM
410 ACSR                 Z-ADD     PTETIM        ZZETIM
410 ACSR                 EXSR      ZZCKU2
     C*
410 AC*   Start an 'IDLE' task, if no open task.
410 ACSR                 Z-ADD     0             CURTRN            7 0
410 ACSR                 MOVE      *BLANKS       CURTSK            6
410 ACSR                 MOVE      *BLANKS       CURTYP            1
410 ACSR                 MOVE      *OFF          CURENT            1
410 ACSR                 EXSR      ZZTASK
410 ACSR   CURENT        IFEQ      *OFF
410 ACSR                 MOVE      'IDLE  '      W1TASK            6
410 ACSR                 EXSR      ZZIDLE
410 ACSR                 ENDIF
     C*
     CSR   ENDCLS        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     CSR   ZZCHK1        BEGSR
     CSR                 MOVE      *OFF          ERROR
     C*
     C*   Verify warehouse and get description.
     C*
     CSR                 MOVE      '*VERIFY '    $LCMD
     CSR                 Z-ADD     W1WHSE        $LWHSE
     CSR                 CALL      'WH900'
     CSR                 PARM                    $LPARM
     CSR   $LRTN         IFEQ      '*ERROR  '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN21
     CSR                 MOVE      *ON           *IN01
     CSR                 MOVEL     $LERM         ERRMSG
     CSR                 EXSR      ZM0105
     CSR                 ELSE
     CSR   $LRTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN21
     CSR                 MOVE      *ON           *IN01
     CSR                 MOVE      $LMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ENDIF
     CSR                 ENDIF
     C*
415cDC** Enter only one, either license or transaction number.
415cMC*  Enter only one, license, trans # or label #.
221 AC*
416fDC**         W1LCNS    IFNE 0
416fMCSR   W1LCNS        IFNE      *BLANKS
221 ACSR   W1TRN#        ANDNE     0
415cACSR   W1LBL#        ANDNE     0
221 ACSR                 MOVE      *ON           ERROR
221 ACSR                 MOVE      *ON           *IN22
221 ACSR                 MOVE      *ON           *IN02
221 ACSR                 MOVE      *ON           *IN23
221 ACSR                 MOVE      *ON           *IN03
221 ACSR                 EXSR      ZM0204
221 ACSR                 ENDIF
     C*
415cDC** Must enter one, either license or transaction number.
415cMC*  Must enter one, license, transaction or label number.
221 AC*
416fDC**         W1LCNS    IFEQ 0
416fMCSR   W1LCNS        IFEQ      *BLANKS
221 ACSR   W1TRN#        ANDEQ     0
415cACSR   W1LBL#        ANDEQ     0
221 ACSR                 MOVE      *ON           ERROR
221 ACSR                 MOVE      *ON           *IN22
221 ACSR                 MOVE      *ON           *IN02
221 ACSR                 MOVE      *ON           *IN23
221 ACSR                 MOVE      *ON           *IN03
221 ACSR                 EXSR      ZM0205
221 ACSR                 ENDIF
     C*
416fAC*  Left justify license.
416fACSR                 MOVE      *BLANKS       $CSTR
416fACSR                 MOVE      W1LCNS        $CSTR
416fACSR                 CALL      'ADJUST'
416fACSR                 PARM      '*LEFT   '    $CCMD             8
416fACSR                 PARM                    $CSTR            30
416fACSR                 MOVEL     $CSTR         W1LCNS
     C*
     C*  Verify license plate number.
     C*
416fDC**         W1LCNS    IFNE 0
416fMCSR   W1LCNS        IFNE      *BLANKS
221 ACSR   W1TRN#        ANDEQ     0
414dACSR                 MOVE      *OFF          GOODLI            1
414dDC*R         LIKEY     CHAINLICENSE              79
414dACSR   LIKEY         SETLL     LICENSE
414dACSR   NXTLI         TAG
414dACSR   LIKEY         READE     LICENSE                                78
414dACSR   *IN78         IFEQ      '0'
414dACSR   LITRN#        CHAIN(N)  PIRTRAN                            79
414dACSR   *IN79         IFEQ      '0'
414dACSR   PTTASK        IFNE      'PUTEMP'
415bACSR   PTTASK        ANDNE     'PUTRTN'
414dACSR                 GOTO      NXTLI
414dACSR                 ELSE
414dACSR                 MOVE      *ON           GOODLI
414dACSR                 ENDIF
414dACSR                 ELSE
414dACSR                 GOTO      NXTLI
414dACSR                 ENDIF
414dACSR                 ENDIF
     C*****************
414dMCSR   GOODLI        IFEQ      *OFF
414dDC*R         *IN79     IFEQ *ON
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN22
     CSR                 MOVE      *ON           *IN02
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 EXSR      ZM1022
     CSR                 GOTO      ENDCK1
     CSR                 ENDIF
221 ACSR                 ENDIF
     C*
221 AC*  Verify transaction number.
221 AC*
221 ACSR   W1TRN#        IFNE      0
416fDC**         W1LCNS    ANDEQ0
416fMCSR   W1LCNS        ANDEQ     *BLANKS
221 ACSR                 MOVE      '*VERIFY '    $LCMD
221 ACSR                 Z-ADD     W1TRN#        $LTRN1
221 ACSR                 CALL      'PT900'
221 ACSR                 PARM                    $LPARM
221 ACSR   $LRTN         IFEQ      '*PGMQ   '
221 ACSR                 MOVE      *ON           ERROR
 21 ACSR                 MOVE      *ON           *IN23
221 ACSR                 MOVE      *ON           *IN03
221 ACSR                 MOVE      $LMSG         #MSGK
221 ACSR                 EXSR      ZMQMSG
221 ACSR                 ENDIF
221 ACSR                 ENDIF
415cAC*
415cAC*  Verify label number.
416dAC*    Note: Label number can only be used when doing putaways
416dAC*          for customer returns.
415cAC*
415cACSR                 Z-ADD     0             WOLBL#            7 0
415cACSR                 Z-ADD     0             WOTRN#            7 0
415cACSR   W1LBL#        IFNE      0
415cACSR                 Z-ADD     W1LBL#        WOLBL#
415cACSR                 Z-ADD     0             LBCNT             2 0
415cACSR   LLKEY1        SETLL     LABELNK1
415cACSR   NXTLB         TAG
415cACSR   LLKEY1        READE     LABELNK1                               78
415cACSR   *IN78         IFEQ      '0'
415cAC*
415cACSR   PTSTAT        IFNE      '1'
415cACSR                 GOTO      NXTLB
415cACSR                 ELSE
415cACSR                 ADD       1             LBCNT
415cACSR                 Z-ADD     LLTRN#        LKTRN#
415cACSR                 ENDIF
415cAC*
415cACSR   LBCNT         IFGT      1
415cACSR                 MOVE      '*LOOKUP '    $LCMD
415cACSR                 Z-ADD     W1WHSE        $LLWHS            3 0
415cACSR                 Z-ADD     LLLBLO        $LLBLO
 15cACSR                 Z-ADD     0             $LTRN2
415cACSR                 CALL      'LL145'
415cACSR                 PARM                    $LPARM
415cACSR                 PARM                    $LLWHS
415cACSR   $LRTN         IFEQ      '*ERROR  '
415cACSR                 MOVE      *ON           ERROR
415cACSR                 MOVE      *BLANKS       ERRMSG
415cACSR                 MOVEL     DESC(2)       ERRMSG
415cACSR                 MOVE      *ON           *IN24
415cACSR                 MOVE      *ON           *IN04
415cACSR                 EXSR      ZM1001
415cACSR                 ELSE
415cAC*
415cACSR   $LRTN         IFEQ      '*PGMQ   '
415cACSR                 MOVE      *ON           ERROR
415cACSR                 MOVE      *ON           *IN21
415cACSR                 MOVE      *ON           *IN01
415cACSR                 MOVE      $LMSG         #MSGK
415cACSR                 EXSR      ZMQMSG
415cACSR                 ELSE
415cACSR                 Z-ADD     $LTRN2        LKTRN#            7 0
415cACSR                 ENDIF
415cACSR                 ENDIF
415cACSR                 ELSE
415cACSR                 GOTO      NXTLB
415cACSR                 ENDIF
415cACSR                 ENDIF
415cAC*
415cACSR   $LRTN         IFEQ      '*CANCEL'
415cACSR   $LRTN         OREQ      '*ERROR '
415cACSR   $LRTN         OREQ      '*PGMQ  '
415cACSR                 MOVE      *ON           ERROR
415cACSR                 ENDIF
415cAC*
415cACSR   LBCNT         IFEQ      0
415cACSR                 MOVE      *ON           ERROR
415cACSR                 MOVE      *BLANKS       ERRMSG
415cACSR                 MOVEL     DESC(2)       ERRMSG
415cACSR                 MOVE      *ON           *IN24
415cACSR                 MOVE      *ON           *IN04
415cACSR                 EXSR      ZM1001
415cACSR                 ENDIF
415cACSR                 ENDIF
     C*
     C*  Make sure that the transaction is open.
     C*
415cACSR   WOTRN#        IFEQ      0
416dDC*R         W1TRN#    IFNE 0
416dACSR                 SELECT
416dMCSR   W1TRN#        WHENNE    0
222 ACSR                 Z-ADD     W1TRN#        WOTRN#            7 0
416dACSR   W1LBL#        WHENNE    0
416dACSR                 Z-ADD     LKTRN#        WOTRN#
416dDC*R                   ELSE
416dMCSR                 OTHER
222 ACSR                 Z-ADD     LITRN#        WOTRN#
416dDC*R                   ENDIF
416dMCSR                 ENDSL
415cACSR                 ENDIF
     CSR   PTKEY         CHAIN(N)  PIRTRAN                            79
     CSR   *IN79         IFEQ      *OFF
     CSR   PTSTAT        ANDNE     '1'
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN22
     CSR                 MOVE      *ON           *IN02
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 Z-ADD     PTTRN#        ERTRN#
     CSR                 EXSR      ZM2002
     CSR                 ENDIF
     C*
     CSR   ENDCK1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK2   Screen 2 error checking.
     C*
     CSR   ZZCHK2        BEGSR
     CSR                 MOVE      *OFF          ERROR
414 AC*
414 AC*  Call API for slot.
414 AC*
414 ACSR                 CALL      @APICS
414 ACSR                 PARM                    W2SCAN
414 ACSR                 PARM      6             WOROW
414 ACSR                 PARM      7             WOCOL
414 ACSR                 PARM                    @ARTN             8
414 ACSR   @ARTN         IFEQ      '*REDSPLY'
414 ACSR                 MOVE      *ON           REDSPL
414 ACSR                 GOTO      ENDCK2
414 ACSR                 ENDIF
     C*
     C*  Verify display.(SCAN slot)
     C*
     CSR   W2SCAN        IFNE      W2TOSL
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN25
     CSR                 MOVE      *ON           *IN05
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVEL     W2TOSL        ERRMSG
     CSR                 EXSR      ZM2001
     CSR                 ENDIF
     C*
     CSR   ENDCK2        ENDSR
409 AC*----------------------------------------------------------------
409 AC*
409 AC*  ZZCHK3   Screen 3 error checking.
409 AC*
409 ACSR   ZZCHK3        BEGSR
413c C*   SLCHK, Flags are used to force F20 for each test
413c C*   Values: Flag = 0 Do check.
413c C*           Flag = 1 Check was done, ok.
413c C*           Flag = 2 Warning condition.
413c C*
409 ACSR                 MOVE      *OFF          ERROR
414 AC*
414 AC*  Call API for slot.
414 AC*
414 ACSR                 CALL      @APICS
414 ACSR                 PARM                    W3SCAN
414 ACSR                 PARM      6             WOROW
414 ACSR                 PARM      7             WOCOL
414 ACSR                 PARM                    @ARTN             8
414 ACSR   @ARTN         IFEQ      '*REDSPLY'
414 ACSR                 MOVE      *ON           REDSPL
414 ACSR                 GOTO      ENDCK3
414 ACSR                 ENDIF
     C*
     C*
409 AC*  QUANTITY MUST BE > 0
     CSR   W3QTY         IFLE      0
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN27
     CSR                 MOVE      *ON           *IN07
     CSR                 EXSR      ZM2003
     CSR                 ENDIF
     C*
409 AC*  QUANTITY CAN'T BE > QUANTITY TO BE PUT AWAY.
     CSR   W3QTY         IFGT      W3RQTY
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN27
     CSR                 MOVE      *ON           *IN07
     CSR                 EXSR      ZM2004
     CSR                 ENDIF
     CSR   ERROR         CABEQ     *ON           ENDCK3
415iAC*
415iACSR   TOKEY         CHAIN(N)  RECORD                             79
415iACSR   *IN79         IFEQ      *OFF
416qDC*R         SLSTAT    ANDEQ'I'
416qAC*
416qAC*    If slot not active,verified or zero status, treat as
416qAC*    inactive and prevent putaway into slot.
416qACSR   SLSTAT        IFNE      'A '
416qACSR   SLSTAT        ANDNE     'V '
416qACSR   SLSTAT        ANDNE     'Z '
415iACSR                 MOVE      *ON           ERROR
415iACSR                 MOVE      *ON           *IN26
415iACSR                 MOVE      *ON           *IN06
415iACSR                 EXSR      ZM2007
415iACSR                 GOTO      ENDCK3
416qACSR                 ENDIF
415iACSR                 ENDIF
415jAC*
415jAC*    Have user verify slot.
415jAC*
415jACSR   OPVRFY        IFEQ      'Y'
415jACSR                 CALL      'RC200V'
415jACSR                 PARM                    W3SCAN
415jACSR                 PARM                    $VRFY             1
415jACSR   $VRFY         IFNE      'Y'
415jACSR                 MOVE      *ON           REDSPL
415jACSR                 GOTO      ENDCK3
415jACSR                 ENDIF
415jACSR                 ENDIF
     C*
412eDC**         W3SCAN    IFNE ODISP
415hAC*   Count # of pick slots.
415hACSR                 EXSR      CHKPCK
415hAC*
415hACSR   TOKEY         CHAIN(N)  RECORD                             79
415hACSR   *IN79         IFEQ      *OFF
415hACSR   SLSTAT        IFEQ      'V'
415hACSR   SLPICK        ANDEQ     'Y'
415hACSR   SLSTAT        OREQ      'Z'
415hACSR   SLPICK        ANDEQ     'Y'
415hACSR                 ADD       1             NBRPCK
415hACSR                 ENDIF
415hACSR                 ENDIF
     C*
415hACSR   OPMPCK        IFEQ      'N'
415hACSR   IMNRPK        ANDGT     1
415hACSR                 Z-ADD     1             IMNRPK
415hACSR                 ENDIF
415hAC*
415hAC*   Error if new # of pick slots is > number allowed.
     C*
415mACSR   *IN79         IFEQ      *OFF
415mACSR   SLPICK        ANDEQ     'Y'
416bACSR   SLSTYP        ANDEQ     'F'
415hACSR   NBRPCK        IFGT      IMNRPK
415hACSR                 MOVE      *ON           ERROR
415hACSR                 MOVE      *ON           *IN21
415hACSR                 MOVE      *ON           *IN01
415hACSR                 EXSR      ZM5206
415bACSR                 GOTO      ENDCK3
415hACSR                 ENDIF
415mACSR                 ENDIF
414aAC*
414aAC*   Check if item exists in more than one slot.
414aAC*
414aACSR                 EXSR      ZZCMLT
     C*
409  C*   Check if item exists in reg. or v-slot.
     C*
     CSR                 EXSR      ZZCKSL
414aAC*   If item has hard designation, must match slot designation.
414bAC*
414bACSR   #ODESG        IFNE      *BLANKS
414bACSR   #ODESG        CHAIN     DESIG                              79
414bACSR   *IN79         IFEQ      *ON
414bACSR                 MOVE      'H'           DSTYPE
414bACSR                 ENDIF
414bACSR   DSTYPE        IFEQ      'H'
414bACSR   #ODESG        ANDNE     SLDESG
414bACSR                 MOVE      *ON           ERROR
414bACSR                 MOVE      *ON           *IN26
414bACSR                 MOVE      *ON           *IN06
414bACSR                 EXSR      ZM2006
414bACSR                 GOTO      ENDCK3
414bACSR                 ENDIF
414bACSR                 ENDIF
414bAC*
     C*
     CSR   EXIST         IFEQ      *ON
416l C*   For overflow slot,
416l CSR   SLPICK        IFEQ      'N'
409  C*   Item is date sensitive and exists with different date.
412CAC*   And slot has a quantity.
409 DC*R         ITFLGD    IFEQ 'Y'
409 MCSR   SVEXPD        IFNE      0
     CSR   SLEXPD        ANDNE     SVEXPD
412CACSR   SLSTK1        IFGT      0
412CACSR   SLSTK2        ORGT      0
412CACSR   SLSTK3        ORGT      0
412CACSR   SLALC1        ORGT      0
412CACSR   SLALC2        ORGT      0
412CACSR   SLALC3        ORGT      0
412CACSR   SLTFR1        ORGT      0
412CACSR   SLTFR2        ORGT      0
412CACSR   SLTFR3        ORGT      0
412CACSR   SLPCK1        ORGT      0
412CACSR   SLPCK2        ORGT      0
412CACSR   SLPCK3        ORGT      0
412CACSR   SLRCV1        ORGT      0
412CACSR   SLRCV2        ORGT      0
412CACSR   SLRCV3        ORGT      0
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN26
     CSR                 MOVE      *ON           *IN06
     CSR                 EXSR      ZM2521
     CSR                 GOTO      ENDCK3
     CSR                 ENDIF
412CACSR                 ENDIF
416lACSR                 ENDIF
414aAC*
414aAC*   Can only put into existing pick slt if no overflow slot exist
415dAC*   Unless it is a return - returns can go to pick slot.
415eAC*   Allow override to put any product into pick slot.
414aACSR   SLPICK        IFEQ      'Y'
415e C*
415eACSR   SVDISP        IFNE      W3SCAN
415eACSR                 MOVE      '0'           SLCHK
415eACSR                 ENDIF
415e C*
415eACSR   SLCHK         IFEQ      '2'
415eACSR   OVRRID        ANDEQ     *ON
415eACSR                 MOVE      '1'           SLCHK
415eACSR                 ENDIF
415e C*
415eMCSR   SLCHK         IFNE      '1'
415eACSR                 MOVE      '1'           SLCHK
415eDC**         PTTASK    ANDNE'PUTRTN'
415eMCSR   PTTASK        IFNE      'PUTRTN'
414aACSR   MLTFLG        ANDEQ     *ON
414aACSR                 MOVE      *ON           ERROR
415eACSR                 MOVE      '2'           SLCHK
415eACSR                 MOVE      *ON           WARN
414aACSR                 MOVE      *ON           *IN26
414aACSR                 MOVE      *ON           *IN06
414aACSR                 EXSR      ZM2005
415eDC*R                   GOTO ENDCK3
414aACSR                 ENDIF
415eACSR                 ENDIF
415e C*
415eACSR   ERROR         CABEQ     *ON           ENDERR
415e C*
415eACSR                 ENDIF
414aAC*
     C*
     CSR                 MOVE      SLDISP        W3SCAN
     CSR                 ELSE
     CSR                 EXSR      ZZCKNS
412fACSR   ERROR         IFEQ      *ON
412fACSR                 MOVE      *ON           *IN26
412fACSR                 MOVE      *ON           *IN06
412fACSR                 MOVE      *BLANKS       ERRMSG
412fACSR                 MOVEL     W3SCAN        ERRMSG
412fACSR                 EXSR      ZM1524
412fACSR                 GOTO      ENDCK3
412fACSR                 ENDIF
     CSR                 ENDIF
412eDC**                   ENDIF
     C**
415e CSR   ENDERR        TAG
     CSR                 MOVE      W3SCAN        ODISP
409 AC*
415eAC*   Save screen fields.
415eACSR                 MOVE      W3SCAN        SVDISP
409 AC*
409 ACSR   ENDCK3        ENDSR
415kAC*----------------------------------------------------------------
415kAC*
415kAC*  ZZCHK4   Screen 4 error checking.
415kAC*
415kACSR   ZZCHK4        BEGSR
     CSR                 MOVE      *OFF          ERROR
     C*
     C*  QUANTITY MUST BE = PUT AWAY QUANTITY
     C*
     CSR   W4QTY         IFNE      LBQPCK
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN27
     CSR                 MOVE      *ON           *IN07
     CSR                 EXSR      ZM2003
     CSR                 EXSR      ZZLOG4
     CSR                 ENDIF
     C*
     CSR   ERROR         CABEQ     *ON           ENDCK4
     C*
     CSR   ENDCK4        ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZCHK5   Screen 5 error checking.
416dAC*
416dACSR   ZZCHK5        BEGSR
416dACSR                 MOVE      *OFF          ERROR
416dACSR                 MOVE      *BLANKS       PTATYP
416dAC*
416dAC*  If none are entered, user has finished scanning entries.
416dAC*
416fDC**         W5LCNS    IFEQ 0
416fMCSR   W5LCNS        IFEQ      *BLANKS
416dACSR   W5LBL#        ANDEQ     0
416dACSR                 GOTO      ENDCK5
416dACSR                 ENDIF
416dAC*
416dAC*  Enter only one, license, or label #.
416dAC*
416fDC**         W5LCNS    IFNE 0
416fMCSR   W5LCNS        IFNE      *BLANKS
416dACSR   W5LBL#        ANDNE     0
416dACSR                 MOVE      *ON           ERROR
416dACSR                 MOVE      *ON           *IN22
416dACSR                 MOVE      *ON           *IN02
416dACSR                 MOVE      *ON           *IN24
416dACSR                 MOVE      *ON           *IN04
416dACSR                 EXSR      ZM0204
416dACSR                 GOTO      ENDCK5
416dACSR                 ENDIF
416fAC*
416fAC*  Left justify license.
416fACSR                 MOVE      *BLANKS       $CSTR
416fACSR                 MOVE      W5LCNS        $CSTR
416fACSR                 CALL      'ADJUST'
416fACSR                 PARM      '*LEFT   '    $CCMD             8
416fACSR                 PARM                    $CSTR            30
416fACSR                 MOVEL     $CSTR         W5LCNS
     C*
416dAC*  Verify license plate number.
416dAC*
416fDC**         W5LCNS    IFNE 0
416fMCSR   W5LCNS        IFNE      *BLANKS
416dACSR   W5LBL#        ANDEQ     0
416dAC*
416dACSR                 MOVE      '*LICENSE'    PTATYP
416dACSR                 MOVE      *OFF          GOODLI
416fDC**                   Z-ADDW5LCNS    KYLCNS
416fMCSR                 MOVE      W5LCNS        KYLCNS
416dACSR   LIKEY2        SETLL     LICENSE
416dAC*
416dACSR   NXTLI5        TAG
416dAC*
416dACSR   LIKEY2        READE     LICENSE                                78
416dACSR   *IN78         IFEQ      '0'
416dACSR   LITRN#        CHAIN(N)  PIRTRAN                            79
416dACSR   *IN79         IFEQ      '0'
416dAC*    Wrong transaction record found. Read next license.
416dACSR   PTTASK        IFNE      'PUTEMP'
416dACSR   PTTASK        ANDNE     'PUTRTN'
416dACSR                 GOTO      NXTLI5
416dACSR                 ELSE
416dACSR                 MOVE      *ON           GOODLI
416dACSR                 ENDIF
416dACSR                 ELSE
416dACSR                 GOTO      NXTLI5
416dACSR                 ENDIF
416dACSR                 ENDIF
416dAC*
416dAC*    License plate entered is NOT valid.
416dACSR   GOODLI        IFEQ      *OFF
416dACSR                 MOVE      *ON           ERROR
416dACSR                 MOVE      *ON           *IN22
416dACSR                 MOVE      *ON           *IN02
416dACSR                 MOVE      *BLANKS       ERRMSG
416dACSR                 EXSR      ZM1022
416dACSR                 GOTO      ENDCK5
416dACSR                 ENDIF
416dACSR                 ENDIF
416dAC*
416dAC*  Verify label number.
416dAC*
416dACSR                 Z-ADD     0             WOLBL#            7 0
416dACSR                 Z-ADD     0             WOTRN#            7 0
416dACSR   W5LBL#        IFNE      0
416dACSR                 MOVE      '*LABEL  '    PTATYP
416dACSR                 Z-ADD     W5LBL#        WOLBL#
416dACSR                 Z-ADD     0             LBCNT             2 0
416dACSR   LLKEY1        SETLL     LABELNK1
416dACSR   NXTLB5        TAG
416dACSR   LLKEY1        READE     LABELNK1                               78
416dACSR   *IN78         IFEQ      '0'
416dAC*
416dACSR   PTSTAT        IFNE      '1'
416dACSR                 GOTO      NXTLB5
416dACSR                 ELSE
416dACSR                 ADD       1             LBCNT
416dACSR                 Z-ADD     LLTRN#        LKTRN#
416dACSR                 ENDIF
416dAC*
416dACSR   LBCNT         IFGT      1
416dACSR                 MOVE      '*LOOKUP '    $LCMD
416dACSR                 Z-ADD     W1WHSE        $LLWHS            3 0
416dACSR                 Z-ADD     LLLBLO        $LLBLO
416dACSR                 Z-ADD     0             $LTRN2
416dACSR                 CALL      'LL145'
416dACSR                 PARM                    $LPARM
416dACSR                 PARM                    $LLWHS
416dACSR   $LRTN         IFEQ      '*ERROR  '
416dACSR                 MOVE      *ON           ERROR
416dACSR                 MOVE      *BLANKS       ERRMSG
416dACSR                 MOVEL     DESC(2)       ERRMSG
416dACSR                 MOVE      *ON           *IN24
416dACSR                 MOVE      *ON           *IN04
416dACSR                 EXSR      ZM1001
416dACSR                 ELSE
416dAC*
416dACSR   $LRTN         IFEQ      '*PGMQ   '
416dACSR                 MOVE      *ON           ERROR
416dACSR                 MOVE      *ON           *IN24
416dACSR                 MOVE      *ON           *IN04
416dACSR                 MOVE      $LMSG         #MSGK
416dACSR                 EXSR      ZMQMSG
416dACSR                 ELSE
416dACSR                 Z-ADD     $LTRN2        LKTRN#            7 0
416dACSR                 ENDIF
416dACSR                 ENDIF
416dACSR                 ELSE
416dACSR                 GOTO      NXTLB5
416dACSR                 ENDIF
416dACSR                 ENDIF
416dAC*
416dACSR   $LRTN         IFEQ      '*CANCEL'
416dACSR   $LRTN         OREQ      '*ERROR '
416dACSR   $LRTN         OREQ      '*PGMQ  '
416dACSR                 MOVE      *ON           ERROR
416dACSR                 ENDIF
416dAC*
416dACSR   LBCNT         IFEQ      0
416dACSR                 MOVE      *ON           ERROR
416dACSR                 MOVE      *BLANKS       ERRMSG
416dACSR                 MOVEL     DESC(2)       ERRMSG
416dACSR                 MOVE      *ON           *IN24
416dACSR                 MOVE      *ON           *IN04
416dACSR                 EXSR      ZM1001
416dACSR                 ENDIF
416dACSR                 ENDIF
416dAC*
416dAC*  Make sure that the transaction is open.
416dAC*
416dACSR   WOTRN#        IFEQ      0
416dACSR                 SELECT
416fDC**         W5LCNS    WHNE 0
416fMCSR   W5LCNS        WHENNE    *BLANKS
416dACSR                 Z-ADD     LITRN#        WOTRN#
416dACSR   W5LBL#        WHENNE    0
416dACSR                 Z-ADD     LKTRN#        WOTRN#
416dACSR                 ENDSL
416dACSR                 ENDIF
416dACSR   PTKEY         CHAIN(N)  PIRTRAN                            79
416dAC*
416dAC*    Putaway transaction no longer at open status.
416dACSR   *IN79         IFEQ      *OFF
416dACSR   PTSTAT        ANDNE     '1'
416dACSR                 MOVE      *ON           ERROR
416dACSR                 SELECT
416dAC*    License entered - position cursor.
416fDC**         W5LCNS    WHNE 0
416fMCSR   W5LCNS        WHENNE    *BLANKS
416dACSR   W5LBL#        ANDEQ     0
416dACSR                 MOVE      *ON           *IN22
416dACSR                 MOVE      *ON           *IN02
416dAC*    Label entered - position cursor.
416fDC**         W5LCNS    WHEQ 0
416fMCSR   W5LCNS        WHENEQ    *BLANKS
416dACSR   W5LBL#        ANDNE     0
416dACSR                 MOVE      *ON           *IN24
416dACSR                 MOVE      *ON           *IN04
416dACSR                 ENDSL
416dACSR                 MOVE      *BLANKS       ERRMSG
416dACSR                 Z-ADD     PTTRN#        ERTRN#
416dACSR                 EXSR      ZM2002
416dACSR                 ENDIF
416dAC*
416dAC*    Load key values.
416dACSR                 SELECT
416dAC*    Load key values. License scanned.
416fDC**         W5LCNS    WHNE 0
416fMCSR   W5LCNS        WHENNE    *BLANKS
416dACSR   W5LBL#        ANDEQ     0
416fDC**                   Z-ADDW5LCNS    KYPNBR
416fMCSR                 MOVE      W5LCNS        KYPNBR
416dACSR                 MOVE      'P'           KYPTYP
416dAC*    Load key values. Label scanned.
416fDC**         W5LCNS    WHEQ 0
416fMCSR   W5LCNS        WHENEQ    *BLANKS
416dACSR   W5LBL#        ANDNE     0
416fDC**                   Z-ADDW5LBL#    KYPNBR
416fMCSR                 MOVEL     W5LBL#        KYPNBR
416dACSR                 MOVE      'L'           KYPTYP
416dACSR                 ENDSL
416dAC*    Check if license/Label already scanned in.
416dACSR                 EXSR      ZZCKPK
416dACSR   ERROR         IFEQ      *ON
416dACSR                 GOTO      ENDCK5
416dACSR                 ENDIF
416hAC*
416hAC*    Flag to signal a valid entry was made.
416hACSR                 MOVE      *ON           FRSTPS
416dAC*
416dACSR   ENDCK5        ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZCHK6   Screen 6 error checking.
416dAC*
416dACSR   ZZCHK6        BEGSR
416dACSR                 MOVE      *OFF          ERROR
416dAC*
416dAC*  Scanned in license, or label number must match check value.
416dAC*
416dACSR   W6NXT#        IFNE      W6MTCH
416dACSR                 MOVE      *ON           ERROR
416dACSR                 MOVE      *ON           *IN28
416dACSR                 MOVE      *ON           *IN08
416dACSR                 MOVE      *BLANKS       ERRMSG
416dACSR                 SELECT
416dAC*    License plate scanned - invalid number.
416dACSR   W6TXT         WHENEQ    W6TXT1
416dACSR                 EXSR      ZM1022
416dAC*    Label scanned - invalid number.
416dACSR   W6TXT         WHENEQ    W6TXT2
416dACSR                 MOVEL     DESC(2)       ERRMSG
416dACSR                 EXSR      ZM0205
416dACSR                 ENDSL
416dACSR                 ENDIF
416dAC*
416dAC*  Verify license plate number.
416dAC*
416fDC**         W6NXT#    IFNE 0
416fMCSR   W6NXT#        IFNE      *BLANKS
416dACSR   W6TXT         ANDEQ     W6TXT1
416dAC*
416dACSR                 MOVE      '*LICENSE'    PTATYP
416dACSR                 MOVE      *OFF          GOODLI
416fDC**                   Z-ADDW6NXT#    KYLCNS
416fMCSR                 MOVE      W6NXT#        KYLCNS
416dACSR   LIKEY2        SETLL     LICENSE
416dAC*
416dACSR   NXTLI6        TAG
416dAC*
416dACSR   LIKEY2        READE     LICENSE                                78
416dACSR   *IN78         IFEQ      '0'
416dACSR   LITRN#        CHAIN(N)  PIRTRAN                            79
416dACSR   *IN79         IFEQ      '0'
416dAC*    Wrong transaction record found. Read next license.
416dACSR   PTTASK        IFNE      'PUTEMP'
416dACSR   PTTASK        ANDNE     'PUTRTN'
416dACSR                 GOTO      NXTLI6
416dACSR                 ELSE
416dACSR                 MOVE      *ON           GOODLI
416dACSR                 ENDIF
416dACSR                 ELSE
416dACSR                 GOTO      NXTLI6
416dACSR                 ENDIF
416dACSR                 ENDIF
416dAC*
416dAC*    License plate entered is NOT valid.
416dACSR   GOODLI        IFEQ      *OFF
416dACSR                 MOVE      *ON           ERROR
416dACSR                 MOVE      *ON           *IN22
416dACSR                 MOVE      *ON           *IN02
416dACSR                 MOVE      *BLANKS       ERRMSG
416dACSR                 EXSR      ZM1022
416dACSR                 GOTO      ENDCK6
416dACSR                 ENDIF
416dACSR                 ENDIF
416dAC*
416dAC*  Verify label number.
416dAC*
416dACSR                 Z-ADD     0             WOLBL#            7 0
416dACSR                 Z-ADD     0             WOTRN#            7 0
416fDC**         W6NXT#    IFNE 0                            BEG01
416fMCSR   W6NXT#        IFNE      *BLANKS
416dACSR   W6TXT         ANDEQ     W6TXT2
416dACSR                 MOVE      '*LABEL  '    PTATYP
416fDC**                   Z-ADDW6NXT#    WOLBL#
416fMCSR                 MOVEL     W6NXT#        WOLBL#
416dACSR                 Z-ADD     0             LBCNT             2 0
416dACSR   LLKEY1        SETLL     LABELNK1
416dACSR   NXTLB6        TAG
416dACSR   LLKEY1        READE     LABELNK1                               78
416dACSR   *IN78         IFEQ      '0'
416dAC*
416dACSR   PTSTAT        IFNE      '1'
416dACSR                 GOTO      NXTLB6
416dACSR                 ELSE
416dACSR                 ADD       1             LBCNT
416dACSR                 Z-ADD     LLTRN#        LKTRN#
416dACSR                 ENDIF
416dAC*
416dACSR   LBCNT         IFGT      1
416dACSR                 MOVE      '*LOOKUP '    $LCMD
416dACSR                 Z-ADD     W1WHSE        $LLWHS            3 0
416dACSR                 Z-ADD     LLLBLO        $LLBLO
416dACSR                 Z-ADD     0             $LTRN2
416dACSR                 CALL      'LL145'
416dACSR                 PARM                    $LPARM
416dACSR                 PARM                    $LLWHS
416dACSR   $LRTN         IFEQ      '*ERROR  '
416dACSR                 MOVE      *ON           ERROR
416dACSR                 MOVE      *BLANKS       ERRMSG
416dACSR                 MOVEL     DESC(2)       ERRMSG
416dACSR                 MOVE      *ON           *IN28
416dACSR                 MOVE      *ON           *IN08
416dACSR                 EXSR      ZM1001
416dACSR                 ELSE
416dAC*
416dACSR   $LRTN         IFEQ      '*PGMQ   '
416dACSR                 MOVE      *ON           ERROR
416dACSR                 MOVE      *ON           *IN28
416dACSR                 MOVE      *ON           *IN08
416dACSR                 MOVE      $LMSG         #MSGK
416dACSR                 EXSR      ZMQMSG
416dACSR                 ELSE
416dACSR                 Z-ADD     $LTRN2        LKTRN#            7 0
416dACSR                 ENDIF
416dACSR                 ENDIF
416dACSR                 ELSE
416dACSR                 GOTO      NXTLB6
416dACSR                 ENDIF
416dACSR                 ENDIF
416dAC*
416dACSR   $LRTN         IFEQ      '*CANCEL'
416dACSR   $LRTN         OREQ      '*ERROR '
416dACSR   $LRTN         OREQ      '*PGMQ  '
416dACSR                 MOVE      *ON           ERROR
416dACSR                 ENDIF
416dAC*
416dACSR   LBCNT         IFEQ      0
416dACSR                 MOVE      *ON           ERROR
416dACSR                 MOVE      *BLANKS       ERRMSG
416dACSR                 MOVEL     DESC(2)       ERRMSG
416dACSR                 MOVE      *ON           *IN28
416dACSR                 MOVE      *ON           *IN08
416dACSR                 EXSR      ZM1001
416dACSR                 ENDIF
416dACSR                 ENDIF
416dAC*
416dAC*  Make sure that the transaction is open.
416dAC*
416dACSR   WOTRN#        IFEQ      0
416dACSR                 SELECT
416dACSR   PTATYP        WHENEQ    '*LICENSE'
416dACSR                 Z-ADD     LITRN#        WOTRN#
416dACSR   PTATYP        WHENEQ    '*LABEL  '
416dACSR                 Z-ADD     LKTRN#        WOTRN#
416dACSR                 ENDSL
416dACSR                 ENDIF
416dACSR   PTKEY         CHAIN(N)  PIRTRAN                            79
416dAC*
416dAC*    Putaway transaction no longer at open status.
416dACSR   *IN79         IFEQ      *OFF
416dACSR   PTSTAT        ANDNE     '1'
416dACSR                 MOVE      *ON           ERROR
416dACSR                 MOVE      *BLANKS       ERRMSG
416dACSR                 Z-ADD     PTTRN#        ERTRN#
416dACSR                 EXSR      ZM2002
416dAC*    Entry status changed. Delete entry from file.
416eACSR   W6NXT#        IFEQ      W6MTCH
416dACSR                 EXSR      ZZDLP1
416eACSR                 ENDIF
416dACSR                 ENDIF
416dAC*
416dACSR   ENDCK6        ENDSR
     C*----------------------------------------------------------------
     C*
     C*
409  C*  ZZCKNS   Use reg slot or get new Vslot.
     C*
409  CSR   ZZCKNS        BEGSR
412 ACSR                 MOVE      *ON           ERROR
416cACSR                 MOVE      *OFF          NEWVS
     CSR   TOKEY         CHAIN(N)  RECORD                             79
     CSR   *IN79         IFEQ      *OFF
     CSR   SLITEM        IFEQ      *BLANKS
413 ACSR                 MOVE      *OFF          ERROR
     CSR                 GOTO      ENDCKN
     CSR                 ELSE
413cAC*   IF WE WANT VIRTUAL PICK SLOT, COMMENT OUT THE NEXT IF.
413cAC*   Get out if physical slot is a pick slot so we do not
413cAC*   create virtual pick slots.
SFC ACSR   SLPICK        IFEQ      'Y'
SFC ACSR                 MOVE      *ON           ERROR
SFC ACSR                 GOTO      ENDCKN
SFC ACSR                 ENDIF
412 AC*   Get out if physical slot already uses both
412 AC*   positions of handstack field.
412 ACSR                 MOVEA     SLHAND        A2
412 ACSR   A2(1)         IFNE      ' '
412 ACSR                 GOTO      ENDCKN
412 ACSR                 ENDIF
412 AC*   Set handstack flag for later use.
412 ACSR   SLHAND        IFNE      ' '
412 ACSR                 MOVE      *ON           FLAGHS            1
412 ACSR                 ELSE
412 ACSR                 MOVE      *OFF          FLAGHS
412 ACSR                 ENDIF
     C* SAVE PHYSICAL SLOT FIELDS
     CSR                 Z-ADD     SLWHSE        PHWHSE
     CSR                 MOVE      SLWHDP        PHWHDP
416m CSR                 MOVE      SLSTAT        PHSTAT
     CSR                 MOVE      SLAISL        PHAISL
     CSR                 Z-ADD     SLLOC         PHLOC
     CSR                 Z-ADD     SLRLVL        PHRLVL
     CSR                 MOVE      SLHAND        PHHAND
     CSR                 Z-ADD     SLSIDE        PHSIDE
     CSR                 MOVE      SLSTYP        PHSTYP
     CSR                 MOVE      SLDISP        PHDISP
     CSR                 MOVE      SLSDEF        PHSDEF
     CSR                 MOVE      SLDESG        PHDESG
     CSR                 Z-ADD     SLPSEQ        PHPSEQ
     CSR                 MOVE      SLACTV        PHACTV
     CSR                 MOVE      SLBLD         PHBLD
     CSR                 Z-ADD     SLSLFD        PHSLFD
     C***
     CSR                 Z-ADD     SLPSEQ        $VPSEQ
     CSR                 MOVE      *BLANKS       $VDISP
     CSR                 Z-ADD     0             K
412fMCSR                 Z-ADD     SLWHSE        $VWHSE            3 0
412fMCSR                 MOVE      SLWHDP        $VWHDP            5
412fMCSR                 MOVE      SLAISL        $VAISL            3
412fMCSR                 Z-ADD     SLLOC         $VLOC             3 0
412fMCSR                 Z-ADD     SLRLVL        $VRLVL            2 0
     CSR                 MOVE      *BLANKS       $VHAND
412fMCSR                 MOVE      SLSTYP        $VSTYP            1
412fMCSR                 Z-ADD     SLPSEQ        $VPSEQ            5 0
     CSR                 MOVE      *BLANKS       $VDISP
412fACSR                 MOVE      SLPICK        $VPICK            1
     C*** Loop & increment handstack to find new v-slot to create.
414cDC*R         K         DOWLE720
414cMCSR   K             DOWLE     702
     CSR                 ADD       1             K
412fAC*     If physical slot had handstack then limit hs we can use.
412fACSR   FLAGHS        IFEQ      *ON
412fACSR                 MOVEA     HND(K)        A2N
412fACSR   A2N(1)        IFNE      A2(2)
412fACSR                 ITER
412fACSR                 ENDIF
412fACSR                 ENDIF
     CSR                 MOVE      HND(K)        $VHAND
412fACSR                 CALL      'FRMTVS'
412fACSR                 PARM                    PHDISP
412fACSR                 PARM                    FLAGHS
412fACSR                 PARM                    $VHAND            2
412fACSR                 PARM                    $VDISP           12
     C*
412fDC*R                   CALL 'FRMTSL'
412fDC*                    PARM           $VWHSE  30
412fDC*                    PARM           $VWHDP  5
412fDC*                    PARM           $VAISL  3
412fDC*                    PARM           $VLOC   30
412fDC*                    PARM           $VRLVL  20
412fDC*                    PARM           $VHAND  2
412fDC*                    PARM           $VSTYP  1
412fDC*                    PARM           $VPSEQ  50
412fDC*                    PARM           $VDISP 12
     CSR   CKKEY         CHAIN(N)  RECORD                             79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *ON           NEWVS
412fACSR                 MOVE      *OFF          ERROR
     CSR                 MOVE      $VDISP        W3SCAN
     CSR                 LEAVE
     CSR                 ELSE
     CSR                 ITER
     CSR                 ENDIF
     CSR                 ENDDO
     CSR                 ENDIF
     CSR                 ENDIF
     C*
     CSR   ENDCKN        ENDSR
     C*----------------------------------------------------------------
     C*
     C*
409  C*  ZZCKSL   Check if item exists in reg or V slot
     C*
     CSR   ZZCKSL        BEGSR
413cACSR                 MOVE      *OFF          EXIST
416oACSR                 MOVE      *OFF          NEWVS
409 DC*R         SLITEM    IFEQ SVITEM
409 DC*R         SLITEM    IFEQ W3ITEM
410 ACSR   TOKEY         CHAIN(N)  RECORD                             79
410 ACSR   *IN79         IFEQ      *OFF
412 MCSR   SLITEM        ANDEQ     #BITEM
412 DC*R         SLITEM    ANDEQLBITEM
409aDC*R         SLITEM    IFEQ LBITEM
     CSR                 MOVE      *ON           EXIST
     CSR                 GOTO      ENDCKS
     CSR                 ELSE
409 DC*R         OPMPUT    IFEQ 'Y'
     CSR   TOKEY         SETLL     VSLOT2
     CSR   NXT1          TAG
414HDC**         TOKEY     READEVSLOT2                   78
414hMCSR   TOKEY         READE(N)  VSLOT2                                 78
     CSR   *IN78         IFEQ      '0'
     CSR   VSKEY         CHAIN(N)  RECORD                             79
     CSR   *IN79         IFEQ      '0'
412 MCSR   SLITEM        ANDEQ     #BITEM
412 DC*R         SLITEM    ANDEQLBITEM
409 DC*R         SLITEM    ANDEQW3ITEM
409 DC*R         SLITEM    ANDEQSVITEM
     CSR                 MOVE      *ON           EXIST
     CSR                 GOTO      ENDCKS
     CSR                 ELSE
     CSR                 GOTO      NXT1
     CSR                 ENDIF
     CSR                 ENDIF
409 DC*R                   ENDIF
     CSR                 ENDIF
     C*
     CSR   ENDCKS        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     CSR   ZZCMD1        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*BEFORE '
     C*
     C*  Test for F4 - Lookup
     C*
     CSR   *INKD         IFEQ      *ON
     CSR                 MOVE      *ON           CMDTKN
     CSR                 Z-ADD     0             ROW#
     CSR                 MOVE      ROWIN         ROW
     CSR                 Z-ADD     0             COL#
     CSR                 MOVE      COLIN         COL
     CSR                 SELECT
     C*
     CSR                 OTHER
     C*
     C*     Cursor not on a valid lookup field.
     C*
     CSR                 MOVE      *ON           ERROR
     CSR                 EXSR      ZM9905
     CSR                 ENDSL
     CSR                 GOTO      ENDCM1
     CSR                 ENDIF
     CSR                 ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*AFTER  '
     CSR                 ENDIF
     CSR   ENDCM1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD2   User defined command keys for screen 2.
     C*
     CSR   ZZCMD2        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*BEFORE '
     C*
     C*  Test for F10 - EXCEPTION
     C*
     CSR   *INKJ         IFEQ      *ON
     CSR                 MOVE      *ON           CMDTKN
     CSR                 GOTO      ENDCM2
     CSR                 ENDIF
     CSR                 ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*AFTER  '
     CSR                 ENDIF
     CSR   ENDCM2        ENDSR
409 AC*----------------------------------------------------------------
409 AC*
409 AC*  ZZCMD3   User defined command keys for screen 3.
409 AC*
409 ACSR   ZZCMD3        BEGSR
409 AC*
409 AC*  Command keys to check BEFORE verification and update.
409 AC*
409 ACSR   CMDCHK        IFEQ      '*BEFORE '
409 AC*
409 AC*  Test for F10 - EXCEPTION
409 AC*
409 ACSR   *INKJ         IFEQ      *ON
409 ACSR                 MOVE      *ON           CMDTKN
409 ACSR                 GOTO      ENDCM3
409 ACSR                 ENDIF
415e C*
415e C*      F20 - Accept Warning.
415e C*
415eACSR   *INKU         IFEQ      *ON
415eACSR                 MOVE      *ON           OVRRID
415eACSR                 ELSE
415eACSR                 MOVE      *OFF          OVRRID
415eACSR                 ENDIF
409 ACSR                 ENDIF
409 AC*
409 AC*  Command keys to check AFTER verification and update.
409 AC*
409 ACSR   CMDCHK        IFEQ      '*AFTER  '
409 ACSR                 ENDIF
409 ACSR   ENDCM3        ENDSR
415kAC*----------------------------------------------------------------
415kAC*
415kAC*  ZZCMD4   User defined command keys for screen 4.
415kAC*
415kACSR   ZZCMD4        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*BEFORE '
     C*
     CSR                 ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*AFTER  '
     CSR                 ENDIF
     CSR   ENDCM4        ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZCMD5   User defined command keys for screen 5.
416dAC*
416dACSR   ZZCMD5        BEGSR
416dAC*
416dAC*  Command keys to check BEFORE verification and update.
416dAC*
416dACSR   CMDCHK        IFEQ      '*BEFORE '
416dAC*
416dACSR                 ENDIF
416dAC*
416dAC*  Command keys to check AFTER verification and update.
416dAC*
416dACSR   CMDCHK        IFEQ      '*AFTER  '
416dACSR                 ENDIF
416dACSR   ENDCM5        ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZCMD6   User defined command keys for screen 6.
416dAC*
416dACSR   ZZCMD6        BEGSR
416dAC*
416dAC*  Command keys to check BEFORE verification and update.
416dAC*
416dACSR   CMDCHK        IFEQ      '*BEFORE '
416nDC**                   MOVE *OFF      SKIP6
416dAC*
416dACSR                 SELECT
416dAC*    Test for F9 - Skip current putaway.
416dACSR   *INKI         WHENEQ    *ON
416dACSR                 MOVE      *ON           CMDTKN
416dACSR                 MOVE      *ON           SKIP6
416dACSR                 EXSR      SCR06I
416dACSR                 ENDSL
416dAC*
416dACSR                 ENDIF
416dAC*
416dAC*  Command keys to check AFTER verification and update.
416dAC*
416dACSR   CMDCHK        IFEQ      '*AFTER  '
416dACSR                 ENDIF
416dACSR   ENDCM6        ENDSR
     C*----------------------------------------------------------------
     C*
414aAC*  ZZCMLT  Check for multiple slots for an item.
414aAC*
414aACSR   ZZCMLT        BEGSR
     C*
     CSR                 Z-ADD     0             ACTCNT            1 0
     CSR                 MOVE      *OFF          MLTFLG            1
     C*
     CSR   KEYS3C        SETLL     SLOT3
     CSR   FOREVR        DOWEQ     FOREVR
     CSR   KEYS3C        READE     SLOT3                                7879
     CSR   *IN79         IFEQ      *ON
     CSR                 LEAVE
     CSR                 ENDIF
     CSR   SLSTAT        IFEQ      'Z'
     CSR   SLSTAT        OREQ      'V'
     CSR   SLPICK        OREQ      'Y'
     CSR   SLSTYP        ANDEQ     'F'
     CSR   OPMPCK        ANDEQ     'Y'
     CSR   SLPICK        OREQ      'Y'
     CSR   SLRSRV        ANDEQ     'Y'
     CSR   SLSTYP        ANDEQ     'P'
     CSR                 ITER
     CSR                 ENDIF
     CSR                 ADD       1             ACTCNT
     CSR   ACTCNT        IFGE      1
     CSR   SLSTYP        ANDEQ     'P'
     C*
     CSR   ACTCNT        ORGE      2
     CSR   OPMPCK        ANDEQ     'N'
     C*
     CSR   ACTCNT        ORGE      1
     CSR   SLSTYP        ANDEQ     'F'
     CSR   OPMPCK        ANDEQ     'Y'
     CSR                 MOVE      *ON           MLTFLG
     CSR                 LEAVE
     CSR                 ENDIF
     CSR                 ENDDO
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZEND  End current task.
     C*
410 ACSR   ZZEND         BEGSR
410 AC*  No current task to end.
410 ACSR   CURTRN        CABEQ     0             ENDEND
410 AC*  End current task
410 ACSR                 Z-ADD     CURTRN        WOTRN#
410 ACSR   PTKEY         CHAIN     PIRTRAN                            79
410 ACSR   *IN79         IFEQ      *OFF
410 ACSR   CURTYP        IFEQ      'D'
410 ACSR   CURTSK        ANDNE     'IDLE  '
410 ACSR                 MOVE      '3'           PTSTAT
410 ACSR                 ELSE
410 ACSR                 MOVE      '4'           PTSTAT
410 ACSR                 ENDIF
410 ACSR                 MOVE      'N'           PTETYP
410 ACSR                 ENDIF
410 AC*
410 ACSR                 CALL      @ADJTD
410 ACSR                 PARM      '*END    '    @PCMD             8
410 ACSR                 PARM      '*INTER  '    @PTYPE            8
410 ACSR                 PARM                    PTPARM
410 ACSR                 PARM      ' '           @PRTN             8
410 ACSR                 PARM      ' '           @PMSG             4
410 AC*
410 ACSR                 UPDATE    PTREC                                79
410 ACSR   *IN79         IFEQ      '1'
410 ACSR                 MOVE      '1'           ERROR
410 ACSR                 EXSR      ZM72
410 ACSR                 GOTO      ENDEND
410 ACSR                 ENDIF
     C*
410 ACSR   CURTYP        IFEQ      'D'
     C*
     C*        There is a posibility that a manual task might have
     C*        been added before the current task was ended. Hence
     C*        adjust the current task just ended, if there is
     C*        any overlapping manual task.
     C*
410 ACSR                 Z-ADD     PTTRN#        SVTRN#
     C*  Past overnight. (PTEDTE > PTSDTE)
410 ACSR   PTEDTE        IFGT      PTSDTE
410 ACSR                 Z-ADD     PTEDTE        STDATE
410 ACSR                 ELSE
410 ACSR                 Z-ADD     PTSDTE        STDATE
410 ACSR                 ENDIF
410 ACSR                 Z-ADD     PTSDTE        ZZSDTE
410 ACSR                 Z-ADD     PTEDTE        ZZEDTE
410 ACSR                 Z-ADD     PTSTIM        ZZSTIM
410 ACSR                 Z-ADD     PTETIM        ZZETIM
410 ACSR                 EXSR      ZZCKU2
410 ACSR                 ENDIF
     C*
410 ACSR   ENDEND        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     CSR   ZZFIL1        BEGSR
     C*
416fDC**                   Z-ADD0         W1LCNS
416fMCSR                 MOVE      *BLANKS       W1LCNS
221 ACSR                 Z-ADD     0             W1TRN#
415cACSR                 Z-ADD     0             W1LBL#
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL2   Fill screen 2 fields with info from file.
     C*
     CSR   ZZFIL2        BEGSR
     CSR                 MOVE      LBDISP        W2TOSL
     CSR                 Z-ADD     LBQPCK        W2QTY
     CSR                 Z-ADD     LBTIE         W2TIE
     CSR                 Z-ADD     LBHIGH        W2HIGH
     CSR                 MOVE      *BLANKS       W2SCAN
     CSR                 ENDSR
409 AC*----------------------------------------------------------------
409 AC*
409 AC*  ZZFIL3   Fill screen 3 fields with info from file.
409 AC*
409 ACSR   ZZFIL3        BEGSR
409 ACSR                 Z-ADD     W3RQTY        W3QTY
409 ACSR                 MOVE      *BLANKS       W3SCAN
409 ACSR                 ENDSR
415kAC*----------------------------------------------------------------
415kAC*
415kAC*  ZZFIL4   Fill screen 4 fields with info from file.
415kAC*
415kACSR   ZZFIL4        BEGSR
415kACSR                 Z-ADD     0             W4QTY
415kACSR                 ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZFIL5   Fill screen 5 fields with info from file.
416dAC*
416dACSR   ZZFIL5        BEGSR
416dAC*
416dACSR                 SELECT
416dAC*    License plate scanned - position cursor in plate fld.
416dACSR   W5TXT         WHENEQ    W5TXT1
416dACSR                 MOVE      *ON           *IN02
416dAC*    Label scanned - position cursor in plate fld.
416dACSR   W5TXT         WHENEQ    W5TXT2
416dACSR                 MOVE      *ON           *IN04
416dACSR                 ENDSL
416fDC**                   MOVE *ZEROS    W5LCNS
416fMCSR                 MOVE      *BLANKS       W5LCNS
416dACSR                 MOVE      *ZEROS        W5LBL#
416dAC*
416dACSR                 ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZFIL6   Fill screen 6 fields with info from file.
416dAC*
416dACSR   ZZFIL6        BEGSR
416dAC*
416dAC*    Build item description.
416dACSR                 MOVE      *BLANKS       W6ITEM
416dACSR                 MOVEL     LBITEM        $IITEM
416dACSR                 MOVEL     ITDESC        $IDESC
416dACSR                 MOVEL     ITPDSC        $IPDSC
416dACSR                 MOVE      *BLANKS       $ISTR
416dACSR                 CALL      @FMTIT
416dACSR                 PARM                    $IITEM           15
416dACSR                 PARM                    $IDESC           30
416dACSR                 PARM                    $IPDSC           15
416dACSR                 PARM                    $ISTR            70
416dACSR                 MOVEL     $ISTR         W6ITEM
416dAC*
416dACSR                 ADD       1             W6CNT1
416dACSR                 Z-ADD     W5CNT         W6CNT2
416fACSR                 MOVE      WKPWHD        $IWHDP            5
416fACSR                 MOVE      WKPASL        $IAISL            3
416fACSR                 MOVE      WKPDSP        $IDISP           12
416fACSR                 MOVE      *BLANKS       $IDSP            38
416fACSR                 CALL      @FMTSL
416fACSR                 PARM                    $IWHDP
416fACSR                 PARM                    $IAISL
416fACSR                 PARM                    $IDISP
416fACSR                 PARM                    $IDSP
416fACSR                 MOVEL     $ISTR         W6DSP
416fDC**                   MOVE WKPWHD    W6WHDP
416fDC**                   MOVE WKPASL    W6AISL
416fDC**                   MOVE WKPDSP    W6DISP
416dACSR                 SELECT
416dAC*    License plate scanned.
416dACSR   WKPTYP        WHENEQ    'P'
416dACSR                 MOVE      W6TXT1        W6TXT
416dAC*    Label scanned - position cursor in plate fld.
416dACSR   WKPTYP        WHENEQ    'L'
416dACSR                 MOVE      W6TXT2        W6TXT
416dACSR                 ENDSL
416fMCSR                 MOVE      *BLANKS       W6NXT#
416fDC**                   MOVE *ZEROS    W6NXT#
416fDC**                   Z-ADDWKPNBR    W6MTCH
416fMCSR                 MOVE      WKPNBR        W6MTCH
416dAC*
416dACSR                 ENDSR
409 AC*----------------------------------------------------------------
409 AC*
409 AC*  ZZGET3   Get screen 3 info.
409 AC*
409 ACSR   ZZGET3        BEGSR
     C*
     C*  Get first picking slot for item.
     C*
415fDC*R                   MOVE 'A '      K3STAT
415fDC*R                   MOVE 'Y'       K3PICK
415fDC*R         KEYS3     SETLLSLOT3
415fDC*R         KEYS3     READESLOT3                    79
415fDC*R         *IN79     IFEQ *ON
415fDC*R                   MOVE *BLANKS   W3TOSL
415fDC*R                   MOVE #OWHDP    W3WHDP
415fDC*R                   ELSE
415fDC*R                   MOVE SLDISP    W3TOSL
415fDC*R                   MOVE SLWHDP    W3WHDP
415fDC*R                   ENDIF
415fAC*
415fACSR   #BSTYP        IFEQ      'P'
415fACSR                 MOVE      '*LAST   '    $PCMD
415fACSR                 ELSE
415fACSR                 MOVE      '*FIRST  '    $PCMD
415fACSR                 ENDIF
415fAC*
415fACSR                 CALL      'GETPSLT'
415fACSR                 PARM                    $PCMD             8
415fACSR                 PARM      W1WHSE        $PWHSE            3 0
415fACSR                 PARM      #BITEM        $PITEM           15
415fACSR                 PARM      *BLANKS       $PSLOT           12
416dACSR                 PARM      *BLANKS       $PAISL            3
416dACSR                 PARM      *ZEROS        $PLOC             3 0
416dACSR                 PARM      *ZEROS        $PRLVL            2 0
416dACSR                 PARM      *BLANKS       $PHAND            2
415fACSR                 PARM      *BLANKS       $PRTN             8
415fAC*
415fACSR                 MOVE      #OWHDP        W3WHDP
416rACSR   $PSLOT        IFEQ      '*NONE*  '
416rACSR                 MOVEL(P)  'None'        W3TOSL
416rACSR                 ELSE
415fACSR                 MOVE      $PSLOT        W3TOSL
416rACSR                 ENDIF
     C*
414eAC*  See if any stock in overflow slot.
414eAC*
414eACSR                 MOVE      'N'           W3OSTK
414eACSR                 MOVE      'A '          K3STAT
414eACSR                 MOVE      'N'           K3PICK
414eACSR   KEYS3         SETLL     SLOT3
414eACSR   FOREVR        DOWEQ     FOREVR
414eACSR   KEYS3         READE     SLOT3                                  79
414eAC*
414eACSR   *IN79         IFEQ      *ON
414eACSR                 LEAVE
414eACSR                 ENDIF
414eAC*
414eACSR   *IN79         IFEQ      *OFF
414eACSR   SLSTK1        IFGT      0
414eACSR   SLSTK2        ORGT      0
414eACSR   SLSTK3        ORGT      0
414eACSR                 MOVE      'Y'           W3OSTK
414eACSR                 LEAVE
414eACSR                 ENDIF
414eACSR                 ENDIF
414eACSR                 ENDDO
     C*
     CSR                 Z-ADD     0             SVEXPD               80
409 DC*R         ITFLGD    IFEQ 'Y'
     CSR   LBLBL#        CHAIN     POMFR1                             79
     CSR   *IN79         IFEQ      *OFF
     CSR                 Z-ADD     PMEXPD        SVEXPD
     CSR                 ENDIF
409 DC*R                   ENDIF
     C*   Save label record to create new label rec if needed.
     CSR   LBLBL#        CHAIN(N)  LABEL                              79
     CSR   *IN79         IFEQ      *OFF
     CSR                 Z-ADD     LBWHSE        SBWHSE
     CSR                 MOVE      LBWHDP        SBWHDP
     CSR                 Z-ADD     0             SBPSEQ
     CSR                 Z-ADD     0             SBQRYF
     CSR                 MOVEL     '*MANUAL'     SBDSP2
     CSR                 MOVE      LBITEM        SBITEM
     CSR                 Z-ADD     LBPBAT        SBPBAT
     CSR                 MOVE      LBUTYP        SBUTYP
     CSR                 MOVE      LBUCOD        SBUCOD
     CSR                 Z-ADD     LBUCUB        SBUCUB
     CSR                 Z-ADD     LBUWGT        SBUWGT
     CSR                 Z-ADD     LBSEQ         SBSEQ
     CSR                 MOVE      LBPO          SBPO
     CSR                 Z-ADD     LBORD         SBORD
     CSR                 Z-ADD     0             SBTIE
     CSR                 Z-ADD     0             SBHIGH
     CSR                 MOVE      LBGRP1        SBGRP1
     CSR                 MOVE      LBGRP2        SBGRP2
     CSR                 MOVE      LBTYPE        SBTYPE
     CSR                 Z-ADD     LBPAL#        SBPAL#
     CSR                 Z-ADD     LBTRN#        SBTRN#
     CSR                 Z-ADD     LBRDTE        SBRDTE
     CSR                 MOVE      LBSTAT        SBSTAT
     CSR                 ENDIF
     C*
409 ACSR                 ENDSR
415kAC*----------------------------------------------------------------
415kAC*
415kACSR   ZZGET4        BEGSR
415kACSR                 ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZGET5   Get screen 5 info.
416dAC*
416dACSR   ZZGET5        BEGSR
416dAC*
416dAC*
416dACSR                 ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZGET6   Get screen 6 info.
416dAC*
416dACSR   ZZGET6        BEGSR
416dACSR                 MOVE      *OFF          NOMORE            1
416dAC*
416dACSR   #TOP6         TAG
416dACSR   PKKEY1        READE     WORKPUT1                               79
416dAC*
416dACSR                 SELECT
416dAC*    EOF reached, See if any records left for user.
416dACSR   *IN79         WHENEQ    *ON
416dAC*
416dACSR   PKKEY1        SETLL     WORKPUT1                               79
416dACSR                 SELECT
416dAC*    Records found - Start over at the top.
416dACSR   *IN79         WHENEQ    *ON
416dACSR                 MOVE      *ZEROS        W6CNT1
416dACSR                 GOTO      #TOP6
416dAC*
416dAC*    No records found - End putaway.
416dACSR   *IN79         WHENEQ    *OFF
416dACSR                 MOVE      *ON           NOMORE
416dACSR                 ENDSL
416dAC*
416dAC*    Record read, find matching label record.
416dACSR   *IN79         WHENEQ    *OFF
416dAC*
416dAC*    Retrieve label record for item information.
416dACSR                 Z-ADD     WKPTRN        WOTRN#
416dACSR   LBKY7A        SETLL     LABEL7
416dACSR   LBKY7A        READE     LABEL7                                 79
416dAC*
416dACSR                 ENDSL
416dAC*
416dACSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZGETI   Get item description and pack description.
     C*
     CSR   ZZGETI        BEGSR
416dACSR   ITMINF        CABEQ     *ON           #GETI
     C*
     C*  LABEL7 file is a Join file with PIRITEM and hence, no need
     C*  to chain to that file.
     C*
     CSR                 MOVE      *BLANKS       W2ITEM
409aACSR                 MOVE      *BLANKS       W3ITEM
415kACSR                 MOVE      *BLANKS       W4ITEM
     CSR                 MOVEL     LBITEM        $IITEM
     CSR                 MOVEL     ITDESC        $IDESC
     CSR                 MOVEL     ITPDSC        $IPDSC
     CSR                 MOVE      *BLANKS       $ISTR
     CSR                 CALL      @FMTIT
     CSR                 PARM                    $IITEM           15
     CSR                 PARM                    $IDESC           30
     CSR                 PARM                    $IPDSC           15
     CSR                 PARM                    $ISTR            70
     CSR                 MOVEL     $ISTR         W2ITEM
409aACSR                 MOVEL     $ISTR         W3ITEM
415kACSR                 MOVEL     $ISTR         W4ITEM
412 AC*
412 AC*  Get item record.  Yes, the LABEL7 file contains item information,
412 AC*    but it does not contain the item type field ITTYPE.
412 AC*
416dACSR   #GETI         TAG
412 ACSR   KEYIT         CHAIN     PIRITEM                            79
412 ACSR   *IN79         IFEQ      *ON
412 ACSR                 MOVE      *BLANK        ITTYPE
412 ACSR                 ENDIF
412 AC*
412 AC*  Save information about item being received (Item that was ordered)
412 AC*
412 ACSR                 MOVE      ITTYPE        #OTYPE
412 ACSR                 MOVE      LBITEM        #OITEM
412CACSR                 MOVE      ITWHDP        #OWHDP
412 ACSR                 MOVE      ITDESC        #ODESC
412 ACSR                 MOVE      ITPDSC        #OPDSC
412 ACSR                 MOVE      LBITEM        #BITEM
412 ACSR                 MOVE      ITDESC        #BDESC
412 ACSR                 MOVE      ITPDSC        #BPDSC
414bACSR                 MOVE      ITDESG        #ODESG
415fACSR                 MOVE      ITITEM        #BITEM
415fACSR                 MOVE      ITSTYP        #BSTYP
412 AC*
412 AC*  If Contract, Alias or SSB Item
412 AC*   Then verify Base item exists.
412 AC*
412 ACSR   ITTYPE        IFEQ      'C'
412 ACSR   ITTYPE        OREQ      'A'
412 ACSR   ITTYPE        OREQ      'S'
412 AC*
412 ACSR                 CALL      'GETBASE'
412 ACSR                 PARM      LBWHSE        $GWHSE            3 0
412 ACSR                 PARM      LBITEM        $GITEM           15
412 ACSR                 PARM      ' '           #BITEM
412 ACSR                 PARM                    #BITYP            1
412 ACSR                 PARM                    #BDESC           30
412 ACSR                 PARM                    #BPDSC           15
412 ACSR                 PARM                    #BWHDP            5
412 ACSR                 PARM                    #BSTYP            1
412 ACSR                 PARM                    #BUM              2
412 ACSR                 PARM                    #BUM2             2
412 ACSR                 PARM                    #BUMQ2            3 0
412 ACSR                 PARM                    #BUM3             2
412 ACSR                 PARM                    #BUMQ3            3 0
412 ACSR                 PARM      ' '           #BCITM           15
412 ACSR                 PARM                    #BCTYP            1
412 ACSR                 PARM                    #BCDSC           30
412 ACSR                 PARM                    #BCPDS           15
412 ACSR                 PARM                    #BCWDP            5
412 ACSR                 PARM                    #BCSTP            1
412 ACSR                 PARM                    #BCUM             2
412 ACSR                 PARM                    #BCUM2            2
412 ACSR                 PARM                    #BCUQ2            3 0
412 ACSR                 PARM                    #BCUM3            2
412 ACSR                 PARM                    #BCUQ3            3 0
412 ACSR                 PARM                    #BRTN             8
412 AC*
412 ACSR                 ENDIF
412 AC*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZIDLE   Create and Start an Idle task.
     C*
410 ACSR   ZZIDLE        BEGSR
410 ACSR                 CALL      'PIRTRN#'
410 ACSR                 PARM                    PTTRN#
410 ACSR                 MOVE      '2'           PTSTAT
410 ACSR                 MOVEL     'IDLE  '      PTTASK
410 ACSR                 MOVEL     'IDLE  '      T#TASK
410 ACSR   TKKEY         CHAIN     TASK                               77
410 ACSR                 MOVE      TKCAT         PTCAT
410 ACSR                 MOVE      TKSUB         PTSUB
410 ACSR                 SELECT
410 ACSR   TKTLVL        WHENEQ    'S'
410 ACSR                 Z-ADD     W1WHSE        PTWHSE
410 ACSR                 MOVE      W1WHDP        PTWHDP
410 ACSR                 MOVE      W1STYP        PTSTYP
410 ACSR   TKTLVL        WHENEQ    'D'
410 ACSR                 Z-ADD     W1WHSE        PTWHSE
410 ACSR                 MOVE      W1WHDP        PTWHDP
410 ACSR                 MOVE      *BLANKS       PTSTYP
410 ACSR                 OTHER
410 ACSR                 Z-ADD     W1WHSE        PTWHSE
410 ACSR                 MOVE      *BLANKS       PTWHDP
410 ACSR                 MOVE      *BLANKS       PTSTYP
410 ACSR                 ENDSL
410 ACSR                 MOVE      W1SHFT        PTSHFT
410 ACSR                 MOVE      W1CREW        PTCREW
410 ACSR                 Z-ADD     W1EMP#        PTEMP#
410 ACSR                 Z-ADD     0             PTCUBE
410 ACSR                 Z-ADD     0             PTSWGT
410 ACSR                 Z-ADD     0             PTPCS
410 ACSR                 Z-ADD     0             PTAISL
410 ACSR                 Z-ADD     0             PTQTY1
410 ACSR                 Z-ADD     0             PTQTY2
410 ACSR                 Z-ADD     0             PTQTY3
410 ACSR                 MOVE      '*CURCMD '    $CVCMD
410 ACSR                 CALL      @CVTDT
410 ACSR                 PARM                    $CVTDT
410 ACSR                 Z-ADD     $CVD8O        PTGDTE
410 ACSR                 TIME                    PTGTIM
410 ACSR                 Z-ADD     $CVD8O        PTSDTE
410 ACSR                 TIME                    PTSTIM
410 ACSR                 Z-ADD     0             PTEDTE
410 ACSR                 Z-ADD     0             PTETIM
410 ACSR                 MOVE      *BLANKS       PTETYP
410 ACSR                 Z-ADD     0             PTCDTE
410 ACSR                 Z-ADD     0             PTCTIM
410 ACSR                 Z-ADD     0             PTDMIN
410 ACSR                 Z-ADD     0             PTIMIN
410 ACSR                 MOVE      *BLANKS       PTRTPO
410 ACSR                 WRITE     PTREC                                79
410 ACSR   *IN79         IFEQ      '1'
410 ACSR                 MOVE      '1'           ERROR
410 ACSR                 EXSR      ZM71
410 ACSR                 GOTO      ENDIDL
410 ACSR                 ENDIF
     C*
410 ACSR   ENDIDL        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     CSR                 MOVE      #PROG         $LPRG
     CSR                 MOVE      #PROG         $CVPRG
410 ACSR                 MOVE      *OFF          FOREVR            1
410 ACSR   *LIKE         DEFINE    PTSTIM        ZZSTIM
410 ACSR   *LIKE         DEFINE    PTETIM        ZZETIM
410 ACSR   *LIKE         DEFINE    PTSDTE        ZZSDTE
410 ACSR   *LIKE         DEFINE    PTEDTE        ZZEDTE
416dACSR   *LIKE         DEFINE    WKPNBR        SVPNBR
416dACSR   *LIKE         DEFINE    WKPTYP        SVPTYP
411 AC*
411 AC*  Define save fields for different item types.
411 AC*
411 ACSR                 MOVE      *BLANK        #OTYPE            1
411 ACSR   *LIKE         DEFINE    ITITEM        #OITEM
412CACSR   *LIKE         DEFINE    ITWHDP        #OWHDP
411 ACSR   *LIKE         DEFINE    ITDESC        #ODESC
411 ACSR   *LIKE         DEFINE    ITPDSC        #OPDSC
411 ACSR   *LIKE         DEFINE    ITITEM        #BITEM
414aACSR   *LIKE         DEFINE    ITDESG        #ODESG
     C*
     C*  Define key for LICENSE file.
     C*
     CSR   LIKEY         KLIST
     CSR                 KFLD                    W1WHSE
     CSR                 KFLD                    W1LCNS
416dACSR   *LIKE         DEFINE    LILCNS        KYLCNS
416dACSR   LIKEY2        KLIST
416dACSR                 KFLD                    W1WHSE
416dACSR                 KFLD                    KYLCNS
     C*
     C*  Define partial key for LABEL7 file.
     C*
     CSR   LBKEY7        KLIST
     CSR                 KFLD                    PTTRN#
416dACSR   LBKY7A        KLIST
416dACSR                 KFLD                    WOTRN#
     C*
412 AC*  Define key for PIRITEM file.
     C*
     CSR   KEYIT         KLIST
     CSR                 KFLD                    LBWHSE
     CSR                 KFLD                    LBITEM
     C*
     C*  Define key for PIRTRAN file.
     C*
     CSR   PTKEY         KLIST
221 DC*R                   KFLD           LITRN#
221 MCSR                 KFLD                    WOTRN#
     C*
221 AC*     OPTIONS
221 AC*
221 AC     OPKEY         KLIST
221 AC                   KFLD                    W1WHSE
221 AC                   KFLD                    OCODE
     C*
414aAC*  Define key for options file, System values.
414aAC*
414aACSR   *LIKE         DEFINE    W1WHSE        KYWHSE
414aACSR   OPTSKY        KLIST
414aACSR                 KFLD                    KYWHSE
414aACSR                 KFLD                    OPCODE
414aAC*
409 AC*
409 AC*  Define partial key for SLOT3 file.
409 AC*
409 ACSR   *LIKE         DEFINE    SLSTAT        K3STAT
409 ACSR   *LIKE         DEFINE    SLPICK        K3PICK
409 ACSR   KEYS3         KLIST
409 ACSR                 KFLD                    W1WHSE
412 DC*R                   KFLD           LBITEM
412 MCSR                 KFLD                    #BITEM
409 ACSR                 KFLD                    K3STAT
409 ACSR                 KFLD                    K3PICK
414aAC*
414aACSR   KEYS3C        KLIST
414aACSR                 KFLD                    W1WHSE
414aACSR                 KFLD                    #BITEM
409 AC*
409 ACSR   TOKEY         KLIST
409 ACSR                 KFLD                    W1WHSE
409 ACSR                 KFLD                    LBWHDP
409 ACSR                 KFLD                    W3SCAN
409 AC*
409 ACSR   CKKEY         KLIST
409 ACSR                 KFLD                    W1WHSE
409 ACSR                 KFLD                    LBWHDP
409 ACSR                 KFLD                    $VDISP
409 AC*
409 ACSR   VSKEY         KLIST
409 ACSR                 KFLD                    W1WHSE
409 ACSR                 KFLD                    LBWHDP
409 ACSR                 KFLD                    VSDISP
415cAC*
415cAC*  Define partial key for LABELNK1 file.
415cAC*
415cACSR   LLKEY1        KLIST
415cACSR                 KFLD                    WOLBL#
415cAC*
415cAC*  Define  key for LABELNK1 file.
415cAC*
415cACSR   LLKEY2        KLIST
415cACSR                 KFLD                    WOLBL#
415cACSR                 KFLD                    $LTRN2
415hAC*
415hAC*  Define key for ITEMMSC file.
415hAC*
415hACSR   ITKEY         KLIST
415hACSR                 KFLD                    W1WHSE
415hACSR                 KFLD                    #BITEM
     C*
     C*
     C*  Convert today's date into century format.
     C*
     CSR                 MOVE      '*CURCMD '    $CVCMD
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD8O        TODAY             8 0
409 AC*
409 ACSR   *LIKE         DEFINE    SLEXPD        SVEXPD
409 ACSR   *LIKE         DEFINE    SLWHSE        PHWHSE
409 ACSR   *LIKE         DEFINE    SLWHDP        PHWHDP
416mACSR   *LIKE         DEFINE    SLSTAT        PHSTAT
409 ACSR   *LIKE         DEFINE    SLAISL        PHAISL
409 ACSR   *LIKE         DEFINE    SLLOC         PHLOC
409 ACSR   *LIKE         DEFINE    SLRLVL        PHRLVL
409 ACSR   *LIKE         DEFINE    SLHAND        PHHAND
409 ACSR   *LIKE         DEFINE    SLSIDE        PHSIDE
409 ACSR   *LIKE         DEFINE    SLSTYP        PHSTYP
409 ACSR   *LIKE         DEFINE    SLDISP        PHDISP
409 ACSR   *LIKE         DEFINE    SLSDEF        PHSDEF
409 ACSR   *LIKE         DEFINE    SLDESG        PHDESG
409 ACSR   *LIKE         DEFINE    SLPSEQ        PHPSEQ
409 ACSR   *LIKE         DEFINE    SLACTV        PHACTV
409 ACSR   *LIKE         DEFINE    SLBLD         PHBLD
409 ACSR   *LIKE         DEFINE    SLSLFD        PHSLFD
409 ACSR   *LIKE         DEFINE    SLDISP        ODISP
415eACSR   *LIKE         DEFINE    SLDISP        SVDISP
409 AC*
409 ACSR   *LIKE         DEFINE    LBWHSE        SBWHSE
409 ACSR   *LIKE         DEFINE    LBWHDP        SBWHDP
409 ACSR   *LIKE         DEFINE    LBAISL        SBAISL
409 ACSR   *LIKE         DEFINE    LBLOC         SBLOC
409 ACSR   *LIKE         DEFINE    LBRLVL        SBRLVL
409 ACSR   *LIKE         DEFINE    LBHAND        SBHAND
409 ACSR   *LIKE         DEFINE    LBPSEQ        SBPSEQ
409 ACSR   *LIKE         DEFINE    LBSTYP        SBSTYP
409 ACSR   *LIKE         DEFINE    LBQRYF        SBQRYF
409 ACSR   *LIKE         DEFINE    LBDISP        SBDISP
409 ACSR   *LIKE         DEFINE    LBDSP2        SBDSP2
409 ACSR   *LIKE         DEFINE    LBITEM        SBITEM
409 ACSR   *LIKE         DEFINE    LBUTYP        SBUTYP
409 ACSR   *LIKE         DEFINE    LBUCOD        SBUCOD
409 ACSR   *LIKE         DEFINE    LBUCUB        SBUCUB
409 ACSR   *LIKE         DEFINE    LBUWGT        SBUWGT
409 ACSR   *LIKE         DEFINE    LBSEQ         SBSEQ
409 ACSR   *LIKE         DEFINE    LBPBAT        SBPBAT
409 ACSR   *LIKE         DEFINE    LBPO          SBPO
409 ACSR   *LIKE         DEFINE    LBORD         SBORD
409 ACSR   *LIKE         DEFINE    LBTIE         SBTIE
409 ACSR   *LIKE         DEFINE    LBHIGH        SBHIGH
409 ACSR   *LIKE         DEFINE    LBGRP1        SBGRP1
409 ACSR   *LIKE         DEFINE    LBGRP2        SBGRP2
409 ACSR   *LIKE         DEFINE    LBTYPE        SBTYPE
409 ACSR   *LIKE         DEFINE    LBPAL#        SBPAL#
409 ACSR   *LIKE         DEFINE    LBTRN#        SBTRN#
409 ACSR   *LIKE         DEFINE    LBRDTE        SBRDTE
409 ACSR   *LIKE         DEFINE    LBSTAT        SBSTAT
     C*
     C*    - Get default warehouse for the user.
     C*
     CSR                 CALL      'GETWHSE'
     CSR                 PARM                    #USER
     CSR                 PARM      0             #WHSE             3 0
     C*
     CSR                 Z-ADD     #WHSE         W1WHSE
     C*
     C*    - Get employee number, default dept and section.
     C*
410 ACSR   *LIKE         DEFINE    USEMP#        W1EMP#
410 ACSR   *LIKE         DEFINE    USWHDP        W1WHDP
410 ACSR   *LIKE         DEFINE    USSTYP        W1STYP
410 ACSR   *LIKE         DEFINE    USSHFT        W1SHFT
410 ACSR   *LIKE         DEFINE    USCREW        W1CREW
410 ACSR   USKEY         KLIST
410 ACSR                 KFLD                    #USER
410 AC*
410 ACSR   USKEY         CHAIN     PIRUSER                            79
410 ACSR   *IN79         IFEQ      *OFF
410 ACSR                 Z-ADD     USEMP#        W1EMP#
410 ACSR                 MOVE      USWHDP        W1WHDP
410 ACSR                 MOVE      USSTYP        W1STYP
410 ACSR                 MOVE      USSHFT        W1SHFT
410 ACSR                 MOVE      USCREW        W1CREW
410 ACSR                 ELSE
410 ACSR                 Z-ADD     0             W1EMP#
410 ACSR                 MOVE      *BLANKS       W1WHDP
410 ACSR                 MOVE      *BLANKS       W1STYP
410 ACSR                 MOVE      *BLANKS       W1SHFT
410 ACSR                 MOVE      *BLANKS       W1CREW
410 ACSR                 ENDIF
     C*
410 ACSR   TKKEY         KLIST
410 ACSR                 KFLD                    T#TASK            6
410 AC*
410 AC*  Define key for PIRTRAN2 file.
410 AC*
410 ACSR   *LIKE         DEFINE    PTSDTE        STDATE
410 ACSR   *LIKE         DEFINE    PTSTIM        STTIME
410 ACSR   PTKE22        KLIST
410 ACSR                 KFLD                    W1EMP#
410 ACSR                 KFLD                    STDATE
410 ACSR                 KFLD                    STTIME
     C*
     C*  Define partial key for PIRTRAN2 file.
     C*
410 ACSR   PTKEY2        KLIST
410 ACSR                 KFLD                    W1EMP#
410 ACSR                 KFLD                    STDATE
413gAC*
413gAC*  Define key for PIRTRAN1 file.
413gAC*
413gACSR   *LIKE         DEFINE    PTSTAT        KYSTAT
413gACSR   PTKEY1        KLIST
413gACSR                 KFLD                    W1EMP#
413gACSR                 KFLD                    KYSTAT
416dAC*
416dAC*  Define key for WORKPUT file.
416dAC*
416dACSR   PKKEY         KLIST
416dACSR                 KFLD                    #USER
416dACSR   PKKYA         KLIST
416dACSR                 KFLD                    #USER
416dACSR                 KFLD                    WKPNBR
416dACSR                 KFLD                    WKPTYP
416dAC*
416dAC*  Define key for WORKPUT1 file.
416dAC*
416dACSR   PKKEY1        KLIST
416dACSR                 KFLD                    #USER
416dAC*
416dAC*  Define key for WORKPUT2 file.
416dAC*
416dACSR   *LIKE         DEFINE    WKPNBR        KYPNBR
416dACSR   *LIKE         DEFINE    WKPTYP        KYPTYP
416dACSR   PKKEY2        KLIST
416dACSR                 KFLD                    KYPNBR
416dACSR                 KFLD                    KYPTYP
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     CSR   ZZINZ2        BEGSR
414 ACSR                 Z-ADD     0             WOROW
414 ACSR                 Z-ADD     0             WOCOL
415eACSR                 MOVE      '0'           SLCHK             1
416dACSR                 MOVE      *BLANKS       PTATYP            8
416dACSR                 MOVE      *BLANKS       LSTSCR            3
416dACSR                 MOVE      *OFF          SKIP6             1
416dACSR                 MOVE      *OFF          ITMINF            1
416hACSR                 MOVE      *OFF          FRSTPS            1
     C*
     C*   Load handstack array with codes (A..Z, AA..AZ, ...)
     C*
     CSR                 Z-ADD     0             K                 3 0
     CSR   1             DO        27            I                 2 0
     CSR   2             DO        27            J                 2 0
     CSR                 ADD       1             K
     CSR   LTR(I)        CAT       LTR(J)        HND(K)
     CSR                 ENDDO
     CSR                 ENDDO
     C*
415jACSR                 EXSR      ZZROPT
414aACSR                 EXSR      ZZSOPT
221 ACSR                 EXSR      ZZLCNS
416dAC*    Remove any existing previously scanned in entries for this user.
416dACSR                 EXSR      ZZDLPK
     CSR                 MOVE      *ON           REFRSH
     CSR                 EXSR      SCR01I
     CSR                 ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZADPK   Add license plates to work file for user.
416dAC*
416dACSR   ZZADPK        BEGSR
416dAC*
416dACSR                 CLEAR                   WKPREC
416dAC*
416dACSR                 MOVE      #USER         WKPUSR
416fDC**                   Z-ADDSVPNBR    WKPNBR
416fMCSR                 MOVE      SVPNBR        WKPNBR
416dACSR                 MOVE      SVPTYP        WKPTYP
416dACSR                 Z-ADD     PTTRN#        WKPTRN
416dACSR                 Z-ADD     W1WHSE        WKPWHS
416dACSR                 MOVE      LBWHDP        WKPWHD
416dAC*
416dACSR                 SELECT
416dAC*    Manual putaway - Retrieve pick slot.
416dACSR   LBDSP2        WHENEQ    '*MANUAL '
416dAC*
416dACSR   #BSTYP        IFEQ      'P'
416dACSR                 MOVE      '*LAST   '    $PCMD
416dACSR                 ELSE
416dACSR                 MOVE      '*FIRST  '    $PCMD
416dACSR                 ENDIF
416dAC*
416dACSR                 MOVE      *ON           ITMINF
416dAC*    Retrieve item info.
416dACSR                 EXSR      ZZGETI
416dACSR                 MOVE      *OFF          ITMINF
416dAC*
416dAC*    Item is a contract/alias/SSB item, use base item#
416dAC*    to retrieve slot information.
416dACSR   #BITEM        IFGT      ' '
416dACSR                 MOVEL     #BITEM        $PITEM
416dAC*
416dAC*    Else...... use item# from label record.
416dACSR                 ELSE
416dACSR                 MOVEL     LBITEM        $PITEM
416dACSR                 ENDIF
416dAC*
416dACSR                 CALL      'GETPSLT'
416dACSR                 PARM                    $PCMD             8
416dACSR                 PARM      W1WHSE        $PWHSE            3 0
416dACSR                 PARM                    $PITEM           15
416dACSR                 PARM      *BLANKS       $PSLOT           12
416dACSR                 PARM      *BLANKS       $PAISL            3
416dACSR                 PARM      *ZEROS        $PLOC             3 0
416dACSR                 PARM      *ZEROS        $PRLVL            2 0
416dACSR                 PARM      *BLANKS       $PHAND            2
416dACSR                 PARM      *BLANKS       $PRTN             8
416dACSR                 SELECT
416dAC*    No pick or overflow slot found. Load hi values to
416dAC*    position at end of putaways.
416dACSR   $PRTN         WHENEQ    '*NONE   '
416dACSR                 MOVE      *HIVAL        WKPASL
416dACSR                 MOVE      *HIVAL        WKPLOC
416dACSR                 MOVE      *HIVAL        WKPLVL
416dACSR                 MOVE      *HIVAL        WKPHND
416dAC*    Pick or overflow slot found.
416dACSR                 OTHER
416dACSR                 MOVE      $PAISL        WKPASL
416dACSR                 Z-ADD     $PLOC         WKPLOC
416dACSR                 Z-ADD     $PRLVL        WKPLVL
416dACSR                 MOVE      $PHAND        WKPHND
416dACSR                 MOVE      $PSLOT        WKPDSP
416dACSR                 ENDSL
416dAC*
416dAC*    Directed putaway - Retrieve slot info from label record.
416dACSR                 OTHER
416dACSR                 MOVE      LBAISL        WKPASL
416dACSR                 Z-ADD     LBLOC         WKPLOC
416dACSR                 Z-ADD     LBRLVL        WKPLVL
416dACSR                 MOVE      LBHAND        WKPHND
416dACSR                 MOVE      LBDISP        WKPDSP
416dAC*
416dACSR                 ENDSL
416dAC*
416dACSR                 WRITE     WKPREC
416dACSR                 ADD       1             W5CNT
416dAC*
416dACSR                 ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZCKPK   Check if number scanned is in the file already.
416dAC*
416dACSR   ZZCKPK        BEGSR
416dAC*
416dACSR   PKKEY2        SETLL     WORKPUT2                               76
416dACSR                 SELECT
416dAC*    License or label already scanned in by another user.
416dACSR   *IN76         WHENEQ    *ON
416eAC*    Retrieve record so we know who scanned in record.
416eACSR   PKKEY2        READE     WORKPUT2                               76
416eaCSR   *IN76         IFEQ      *ON
416eACSR                 MOVE      *BLANKS       W2PUSR
416eACSR                 ENDIF
416dACSR                 MOVE      *ON           ERROR
416fDC**                   Z-ADDKYPNBR    ERPNBR
416fMCSR                 MOVE      KYPNBR        ERPNBR
416eACSR                 MOVE      W2PUSR        ERPUSR
416dACSR                 SELECT
416dACSR   PTATYP        WHENEQ    '*LICENSE'
416dACSR                 MOVE      *ON           *IN02
416dACSR                 MOVE      *ON           *IN22
416dACSR                 MOVEL     DESC(3)       ERPTXT
416dAC*
416dACSR   PTATYP        WHENEQ    '*LABEL  '
416dACSR                 MOVE      *ON           *IN04
416dACSR                 MOVE      *ON           *IN24
416dACSR                 MOVEL     DESC(2)       ERPTXT
416dAC*
416dACSR                 ENDSL
416dACSR                 EXSR      ZM2008
416dACSR                 ENDSL
416dAC*
416dACSR                 ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZDLPK   Delete existing work records for user.
416dAC*
416dACSR   ZZDLPK        BEGSR
416dAC*
416dACSR   PKKEY         SETLL     WORKPUT
416dACSR   FOREVR        DOWEQ     FOREVR
416dACSR   PKKEY         READE     WORKPUT                                79
416dACSR                 SELECT
416dACSR   *IN79         WHENEQ    *ON
416dACSR                 LEAVE
416dAC*
416dACSR                 OTHER
416dACSR                 DELETE    WKPREC
416dACSR                 ENDSL
416dAC                   ENDDO
416dAC*
416dACSR                 ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZDLP1   Delete single work record.
416dAC*
416dACSR   ZZDLP1        BEGSR
416dAC*
416dACSR   PKKYA         CHAIN     WORKPUT                            79
416dACSR                 SELECT
416dACSR   *IN79         WHENEQ    *OFF
416dACSR                 DELETE    WKPREC
416dACSR                 SUB       1             W5CNT
416dACSR                 ENDSL
416dAC*
416dACSR                 ENDSR
     C*----------------------------------------------------------------
     C*
221 AC*  ZZLCNS   Get use generic license option
     C*
221 ACSR   ZZLCNS        BEGSR
     C*
221 AC*   Get use generic license option.
221 ACSR                 MOVE      *OFF          LFLAG             1
221 ACSR                 MOVE      *OFF          *IN35
221 ACSR                 MOVE      '*RCVLBL '    OCODE             8
     C*
221 ACSR   OPKEY         CHAIN     OPTIONS                            79
221 ACSR   *IN79         IFEQ      *OFF
221 ACSR   OPPLCN        IFEQ      'Y'
221 ACSR                 MOVE      '1'           LFLAG
221 ACSR                 MOVE      *ON           *IN35
221 ACSR                 ENDIF
221 ACSR                 ENDIF
     C*
221 ACSR                 ENDSR
415kAC*----------------------------------------------------------------
415kAC*
415kAC*  ZZLOG4   Write log record for verify qty entered on Screen4
415kAC*
415kACSR   ZZLOG4        BEGSR
     C*R                   Z-ADDW1WHSE    LRWHSE
     C*R                   Z-ADDW1LCNS    LRLCNS
     C*R                   MOVE #USER     LRUSER
     C*R                   MOVE #JOB      LRJOB
     C*R                   MOVE #JOBN     LRJOBN
     C*R                   MOVE '*CURCMD '$CVCMD
     C*R                   CALL @CVTDT
     C*R                   PARM           $CVTDT
     C*R                   Z-ADD$CVD8O    LRDTE
     C*
     C*R                   TIME           LRTIME
     C*R                   Z-ADDW4QTY     LRQPUT
     C*R                   WRITELRREC
     C*
     CSR                 ENDSR
     C*
415jAC*----------------------------------------------------------------
415jAC*
415jAC*  ZZROPT   Get use RF Putaway options.
415jAC*
415jACSR   ZZROPT        BEGSR
     C*
     CSR                 MOVE      *ZEROS        KYWHSE
     CSR                 MOVE      '*RFPUT  '    OPCODE
     CSR   OPTSKY        CHAIN     OPTIONS                            79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      'N'           OPVRFY
     CSR                 ELSE
     CSR                 MOVE      OPDATA        OPDAT3
     CSR                 ENDIF
     C*
     CSR                 ENDSR
414aAC*----------------------------------------------------------------
414aAC*
414aAC*  ZZSOPT   Get use system options.
     C*
414aACSR   ZZSOPT        BEGSR
     C*
414aAC*
414aAC*   Get System options.
414aAC*
414aACSR                 MOVE      *ZEROS        KYWHSE
414aACSR                 MOVE      '*SYSTEM '    OPCODE
414aACSR   OPTSKY        CHAIN     OPTIONS                            79
414aACSR   *IN79         IFEQ      *ON
414aACSR                 MOVE      'N'           OPMPCK
414aAC*R                   MOVE *ON       FLGSYS
414aACSR                 ELSE
414aACSR                 MOVE      OPDATA        OPDAT2
414aACSR                 ENDIF
415hACSR                 MOVE      *ZEROS        NBRPCK            5 0
     C*
414aACSR                 ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZSTRT   Start a new transaction
     C*
     CSR   ZZSTRT        BEGSR
     C*
     C*     - Get label record. Put-Away has only one label record
     C*       per transaction number.
     C*
     CSR   LBKEY7        SETLL     LABEL7
     CSR   LBKEY7        READE     LABEL7                                 79
     CSR                 MOVE      PTTASK        @PTASK
     CSR                 Z-ADD     LBCUBE        @PCUBE
     CSR                 Z-ADD     LBSWGT        @PSWGT
     CSR                 CALL      @ADJTR
     CSR                 PARM      '*START  '    @PCMD             8
     CSR                 PARM                    #JOB
     CSR                 PARM      PTTRN#        @PTRN#            7 0
     CSR                 PARM                    @PTASK            6
     CSR                 PARM      W1WHSE        @PWHSE            3 0
     CSR                 PARM      LBWHDP        @PWHDP            5
     CSR                 PARM      LBSTYP        @PSTYP            1
     CSR                 PARM                    @PCUBE            9 3
     CSR                 PARM                    @PSWGT            9 2
     CSR                 PARM      LBQPCK        @PPCS             5 0
     CSR                 PARM      0             @PAISL            5 0
     CSR                 PARM      0             @PQTY1            5 0
     CSR                 PARM      0             @PQTY2            5 0
     CSR                 PARM      0             @PQTY3            5 0
     CSR                 PARM      '0'           @PRTE             5
     CSR                 PARM      ' '           @PPO              9
410 MCSR                 PARM      'P'           @PGRP1            1
410 DC*R                   PARM 'L'       @PGRP1  1
     CSR                 PARM      ' '           @PGRP2            1
     CSR                 PARM      ' '           @PRTN             8
     CSR                 PARM      ' '           @PMSG             4
     C*
     CSR   ENDSTR        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZTASK  Get current task.
     C*
410 ACSR   ZZTASK        BEGSR
410 ACSR                 Z-ADD     *HIVAL        STDATE
410 ACSR                 Z-ADD     *HIVAL        STTIME
     C*
413gACSR                 MOVE      '2'           KYSTAT
413gACSR   PTKEY1        SETLL     PIRTRAN1
413gACSR   PTKEY1        READE     PIRTRAN1                               79
413gACSR   *IN79         IFEQ      *ON
413gACSR                 MOVE      *OFF          FOUND
413gACSR                 GOTO      ENDTSK
413gACSR                 ENDIF
     C*
410 ACSR   PTKE22        SETLL     PIRTRAN2
410 ACSR   FOREVR        DOWEQ     FOREVR
410 ACSR                 READ      PIRTRAN2                               79
410 ACSR   *IN79         IFEQ      *ON
410 ACSR   PTEMP#        ORNE      W1EMP#
410 ACSR                 MOVE      *OFF          FOUND
410 ACSR                 LEAVE
410 ACSR                 ENDIF
410 ACSR   PTSTAT        IFNE      '2'
410 ACSR                 ITER
410 ACSR                 ENDIF
410 AC*   Found an active transaction
410 ACSR                 MOVE      *ON           CURENT
410 ACSR                 Z-ADD     PTTRN#        CURTRN
410 ACSR                 MOVE      PTTASK        T#TASK
410 ACSR   TKKEY         CHAIN     TASK                               79
410 ACSR   *IN79         IFEQ      *OFF
410 ACSR                 MOVE      TKCODE        CURTSK
410 ACSR                 MOVE      TKTYPE        CURTYP
410 ACSR                 ENDIF
410 ACSR                 LEAVE
410 ACSR                 ENDDO
410 ACSR   ENDTSK        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZTIME   Update for screen 1.
     C*
     CSR   ZZTIME        BEGSR
     C*
     C*      Calculate length of time in minutes for output.
     C*
     CSR                 Z-ADD     STRTIM        DSHMS
     C*   Round up minute, if the seconds is >= 30
     CSR   DSSS          IFGE      30
     CSR                 ADD       1             DSMM
     CSR                 ENDIF
     CSR   DSHH          MULT      60            TMPBEG            4 0
     CSR                 ADD       DSMM          TMPBEG
     C*
     CSR                 Z-ADD     FINTIM        DSHMS
     C*   Round up minute, if the seconds is >= 30
     CSR   DSSS          IFGE      30
     CSR                 ADD       1             DSMM
     CSR                 ENDIF
     C*
     C*   If the ending time is < starting time, than
     C*   we have gone past the midnight.
     C*
     CSR   FINTIM        IFLT      STRTIM
     CSR                 ADD       24            DSHH
     CSR                 ENDIF
     CSR   DSHH          MULT      60            TMPEND            4 0
     CSR                 ADD       DSMM          TMPEND
     C*
     CSR   *LIKE         DEFINE    PTDMIN        TIMLEN
     CSR   TMPEND        SUB       TMPBEG        TIMLEN
     CSR   TIMLEN        IFLT      0
     CSR                 Z-ADD     0             TIMLEN
     CSR                 ENDIF
     C*
     CSR   ENDTIM        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD1   Update for screen 1.
     C*
     CSR   ZZUPD1        BEGSR
     CSR                 MOVE      *OFF          ERROR
     CSR                 MOVE      *ON           REFRSH
410 AC*
410 AC*   Get current task.
410 AC*
410 ACSR                 EXSR      ZZTASK
410 ACSR                 SELECT
410 ACSR   CURTYP        WHENEQ    'D'
410 AC*   End current task.
410 ACSR                 EXSR      ZZEND
410 ACSR   CURTYP        WHENEQ    'I'
410 AC*  End current task and any previous open tasks.
410 ACSR                 MOVE      *ON           FOUND             1
410 ACSR   FOUND         DOWEQ     *ON
410 ACSR                 MOVE      *BLANKS       CURTSK
410 ACSR                 MOVE      *BLANKS       CURTYP
410 ACSR                 MOVE      *OFF          CURENT
410 ACSR                 EXSR      ZZTASK
410 ACSR   FOUND         IFEQ      *OFF
410 ACSR                 LEAVE
410 ACSR                 ENDIF
410 ACSR                 EXSR      ZZEND
410 ACSR                 ENDDO
410 ACSR                 ENDSL
415cACSR   W1LBL#        IFNE      0
415cACSR                 Z-ADD     LKTRN#        WOTRN#
416dACSR                 MOVE      '*LABEL  '    PTATYP
415cACSR                 ENDIF
221 ACSR   W1TRN#        IFNE      0
221 ACSR                 Z-ADD     W1TRN#        WOTRN#            7 0
416dACSR                 MOVE      '*TRAN   '    PTATYP
415cACSR                 ENDIF
415cDC*R                   ELSE
416fDC**         W1LCNS    IFNE 0
416fMCSR   W1LCNS        IFNE      *BLANKS
221 ACSR                 Z-ADD     LITRN#        WOTRN#
416dACSR                 MOVE      '*LICENSE'    PTATYP
221 ACSR                 ENDIF
221 DC*R         LIKEY     CHAINLICENSE              79
     C*
     C*   Get transaction record for put-away.
     C*
     CSR   PTKEY         CHAIN(N)  PIRTRAN                            79
     C*
     C*     Record not found.
     C*
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN22
     CSR                 MOVE      *ON           *IN02
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVE      DESC(1)       ERRMSG
     CSR                 EXSR      ZM7979
     CSR                 GOTO      ENDUP1
     CSR                 ENDIF
416dAC*
416dAC*-------------------------------------------------------------------
416dAC*    Load key values.
416dACSR                 SELECT
416dACSR   PTATYP        WHENEQ    '*LICENSE'
416fDC**                   Z-ADDW1LCNS    KYPNBR
416fMCSR                 MOVE      W1LCNS        KYPNBR
416dACSR                 MOVE      'P'           KYPTYP
416dACSR   PTATYP        WHENEQ    '*LABEL  '
416fDC**                   Z-ADDW1LBL#    KYPNBR
416fMCSR                 MOVEL     W1LBL#        KYPNBR
416dACSR                 MOVE      'L'           KYPTYP
416dACSR                 ENDSL
416dAC*
416dAC*-------------------------------------------------------------------
416dAC*    Check if license/label already scanned in.
416dACSR                 SELECT
416dACSR   PTATYP        WHENEQ    '*LICENSE'
416dACSR   PTATYP        OREQ      '*LABEL  '
416dACSR                 EXSR      ZZCKPK
416dACSR   ERROR         IFEQ      *ON
416dACSR                 GOTO      ENDUP1
416dACSR                 ENDIF
416dAC*
416dAC*    Retrieve label record for writing to work file.
416dACSR   LBKEY7        SETLL     LABEL7
416dACSR   LBKEY7        READE     LABEL7                                 79
     C*
416dAC*-------------------------------------------------------------------
     C*   Start new transaction.
416dAC*     Note: Only set to Inuse when transaction# has been entered.
416dACSR   PTATYP        WHENEQ    '*TRAN   '
     C*
     CSR                 EXSR      ZZSTRT
     CSR                 EXSR      ZZGETI
416dACSR                 ENDSL
     C*
416dAC*-------------------------------------------------------------------
416dAC*    Perform qty check for lic#/lbl#/trn# scanned in.
415kACSR   OPPQTY        IFEQ      'Y'
416dAC*
416dAC*    Save entered license plate info.
416dACSR                 SELECT
416dACSR   PTATYP        WHENEQ    '*LICENSE'
416fDC**                   Z-ADDW1LCNS    SVPNBR
416fMCSR                 MOVE      W1LCNS        SVPNBR
416dACSR                 MOVE      'P'           SVPTYP
416dAC*    Save entered label info.
416dACSR   PTATYP        WHENEQ    '*LABEL  '
416fDC**                   Z-ADDW1LBL#    SVPNBR
416fMCSR                 MOVEL     W1LBL#        SVPNBR
416dACSR                 MOVE      'L'           SVPTYP
416dACSR                 ENDSL
416dAC*
416dACSR                 MOVE      '01 '         LSTSCR
415kACSR                 EXSR      SCR04I
416dAC*
416dAC*    No qty check being performed.
415kACSR                 ELSE
416dAC*
416dAC*-------------------------------------------------------------------
416dAC*    License plate/label scanned in. Setup to scan in more.
416dACSR                 SELECT
416dACSR   PTATYP        WHENEQ    '*LICENSE'
416dACSR   PTATYP        OREQ      '*LABEL  '
416dAC*
416dACSR                 SELECT
416dAC*    Add license plate to work file.
416dACSR   PTATYP        WHENEQ    '*LICENSE'
416fMCSR                 MOVE      W1LCNS        W5LST#
416fMCSR                 MOVE      W1LCNS        SVPNBR
416fDC**                   Z-ADDW1LCNS    W5LST#
416fDC**                   Z-ADDW1LCNS    SVPNBR
416dACSR                 MOVE      'P'           SVPTYP
416dACSR                 MOVEL(P)  W5TXT1        W5TXT
416dACSR                 EXSR      ZZADPK
416dAC*    Add label to work file.
416dACSR   PTATYP        WHENEQ    '*LABEL  '
416fMCSR                 MOVE      W1LBL#        W5LST#
416fDC**                   Z-ADDW1LBL#    W5LST#
416fDC**                   Z-ADDW1LBL#    SVPNBR
416fMCSR                 MOVEL     W1LBL#        SVPNBR
416dACSR                 MOVE      'L'           SVPTYP
416dACSR                 MOVEL(P)  W5TXT2        W5TXT
416dACSR                 EXSR      ZZADPK
416dACSR                 ENDSL
416dAC*
416dACSR                 MOVE      '01 '         LSTSCR
416dACSR                 EXSR      SCR05I
416dAC*
416dAC*-------------------------------------------------------------------
416dAC*    Transaction# scanned in. Process as one.
416dACSR                 OTHER
416dAC*
409 ACSR   LBDSP2        IFEQ      '*MANUAL'
409 ACSR                 Z-ADD     LBQPCK        WORQTY            5 0
416dACSR                 MOVE      '01 '         LSTSCR
409 ACSR                 EXSR      SCR03I
409 ACSR                 ELSE
416dACSR                 MOVE      '01 '         LSTSCR
     CSR                 EXSR      SCR02I
409 ACSR                 ENDIF
416dAC*
416dACSR                 ENDSL
415kACSR                 ENDIF
416dAC*
     CSR   ENDUP1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD2   Update for screen 2.
     C*
     CSR   ZZUPD2        BEGSR
     CSR                 MOVE      *OFF          ERROR
     CSR                 MOVE      *ON           REFRSH
     CSR                 EXSR      ZZCLSE
416dAC*
416dAC*    Multiple license plates, labels scanned. Get next one.
416dACSR   W5CNT         IFGT      0
416dACSR                 EXSR      ZZDLP1
416dACSR                 EXSR      SCR06I
416dAC*
416dACSR                 ELSE
     CSR                 EXSR      SCR01I
416dACSR                 ENDIF
416dAC*
     CSR   ENDUP2        ENDSR
     C*
409 AC*----------------------------------------------------------------
409 AC*
409 AC*  ZZUPD3   Update for screen 3.
409 AC*
409 ACSR   ZZUPD3        BEGSR
409 ACSR                 MOVE      *OFF          ERROR
409 ACSR                 MOVE      *ON           REFRSH
409 ACSR                 SUB       W3QTY         W3RQTY
     C*
     C*   Update the "To Slot" record.
     C*
     CSR   TOKEY         CHAIN     RECORD                             79
     CSR   *IN79         IFEQ      *ON
     CSR                 CLEAR                   RECORD
     CSR                 MOVE      'V '          SLSTAT
     CSR                 SELECT
     CSR   LBUTYP        WHENEQ    'N'
415nDC**         ITTYPE    ANDNE'S'
409 MC*R                   Z-ADDLBQPCK    SLSTK1
409 MCSR                 Z-ADD     W3QTY         SLRCV1
     CSR   LBUTYP        WHENEQ    '1'
415nDC**         ITTYPE    ANDNE'S'
415nDC**         LBUTYP    WHEQ 'N'
415nDC**         ITTYPE    ANDEQ'S'
     CSR                 Z-ADD     W3QTY         SLRCV2
     CSR                 OTHER
     CSR                 Z-ADD     W3QTY         SLRCV3
     CSR                 ENDSL
     CSR                 ELSE
416aACSR   SLSTK1        IFEQ      0
416aACSR   SLSTK2        ANDEQ     0
416aACSR   SLSTK3        ANDEQ     0
416aACSR   SLRCV1        ANDEQ     0
416aACSR   SLRCV2        ANDEQ     0
416aACSR   SLRCV3        ANDEQ     0
416aACSR                 Z-ADD     TODAY         SLENTD
416aACSR                 ENDIF
     CSR                 SELECT
     CSR   LBUTYP        WHENEQ    'N'
415nDC**         ITTYPE    ANDNE'S'
     CSR                 ADD       W3QTY         SLRCV1
     CSR   LBUTYP        WHENEQ    '1'
415nDC**         ITTYPE    ANDNE'S'
415nDC**         LBUTYP    WHEQ 'N'
415nDC**         ITTYPE    ANDEQ'S'
     CSR                 ADD       W3QTY         SLRCV2
     CSR                 OTHER
     CSR                 ADD       W3QTY         SLRCV3
     CSR                 ENDSL
409 DC*R                   ADD  W1QTY1    SLSTK1
409 DC*R                   ADD  W1QTY2    SLSTK2
409 DC*R                   ADD  W1QTY3    SLSTK3
     CSR                 ENDIF
     CSR   SLSTAT        IFEQ      'Z '
     CSR   SLSTAT        OREQ      'V '
     CSR                 MOVE      'A '          SLSTAT
     CSR                 Z-ADD     TODAY         SLENTD
415aDC*R                   Z-ADDSVEXPD    SLEXPD
     CSR                 Z-ADD     TODAY         SLSDTE
     CSR                 TIME                    SLSTIM
     CSR                 Z-ADD     0             SLPRTY
409 DC*R                   Z-ADDSVPRTY    SLPRTY
     CSR                 ENDIF
412 DC*R                   MOVE LBITEM    SLITEM
412 MCSR                 MOVE      #BITEM        SLITEM
415a C*
415aAC*     Set expiration date = Put away expiration date.
415aAC*     Use oldest expiration date either slot or putaway.
415a C*
416kAC*R         SVEXPD    IFGT 0
416kACSR   SVEXPD        IFLT      SLEXPD
416kMCSR   SVEXPD        ANDGT     *ZEROS
415aACSR                 Z-ADD     SVEXPD        SLEXPD
416iACSR                 ENDIF
416kACSR   SLEXPD        IFEQ      *ZEROS
416kACSR   SVEXPD        ANDGT     *ZEROS
416kACSR                 Z-ADD     SVEXPD        SLEXPD
416kACSR                 ENDIF
     C*
     C*     Don't allow zero entered date.
     C*
     CSR   SLENTD        IFEQ      0
     CSR                 Z-ADD     TODAY         SLENTD
     CSR                 ENDIF
415dAC*  Set priority for a return put into a non fix pick slot.
416kAC*  Set priority for a return put into non-reserved pick slot.
415dACSR   PTTASK        IFEQ      'PUTRTN'
416kDC*R         SLSTYP    ANDNE'F'
416kDC*R         SLPICK    ANDNE'Y'
416kMCSR   SLPICK        ANDEQ     'Y'
416kACSR   SLRSRV        ANDNE     'Y'
416iDC*R                   Z-ADD9         SLPRTY
416iMCSR                 Z-SUB     9             SLPRTY
415dACSR                 ENDIF
     C*
409 AC*  Create new slot record
     C*  $V = from Physical slot when virtual was checked
     C*  PH = from saved from physical slot when virtual was checked
     C*  SV = saved from 'FROM' slot.
     C*  SL = saved from 'FROM' slot.
409 ACSR   NEWVS         IFEQ      *ON
     CSR                 Z-ADD     $VWHSE        SLWHSE
     CSR                 MOVE      $VWHDP        SLWHDP
416mACSR   PHSTAT        IFNE      'Z '
416mACSR   PHSTAT        ANDNE     'V '
416mACSR                 MOVE      PHSTAT        SLSTAT
416mACSR                 ELSE
     CSR                 MOVE      'A '          SLSTAT
416mACSR                 ENDIF
     CSR                 MOVE      $VAISL        SLAISL
     CSR                 Z-ADD     $VLOC         SLLOC
     CSR                 Z-ADD     $VRLVL        SLRLVL
     CSR                 MOVE      $VHAND        SLHAND
     CSR                 Z-ADD     PHSIDE        SLSIDE
     CSR                 MOVE      $VSTYP        SLSTYP
     CSR                 MOVE      $VDISP        SLDISP
     CSR                 MOVE      PHSDEF        SLSDEF
     CSR                 MOVE      PHDESG        SLDESG
409 MCSR                 MOVE      PHACTV        SLACTV
409 MCSR                 MOVE      PHBLD         SLBLD
409 DC*R                   MOVE SVACTV    SLACTV
409 DC*R                   MOVE SVBLD     SLBLD
412fDC*R         SLSTYP    IFEQ 'P'
412fDC*R                   MOVE 'Y'       SLPICK
412fDC*R                   ELSE
412fDC*R                   MOVE 'N'       SLPICK
412fDC*R                   ENDIF
413bACSR                 MOVE      $VPICK        SLPICK
     CSR                 Z-ADD     $VPSEQ        SLPSEQ
412fDC*R                   Z-ADDPHSLFD    SLSLFD
409 DC*R                   Z-ADDSVSLFD    SLSLFD
412fMCSR                 Z-ADD     0             SLSLFD
     CSR                 MOVE      'V'           SLRSRV
     CSR                 Z-ADD     TODAY         SLENTD
     CSR                 Z-ADD     SVEXPD        SLEXPD
     CSR                 Z-ADD     TODAY         SLSDTE
     CSR                 TIME                    SLSTIM
415dDC*R                   Z-ADD0         SLPRTY
     CSR                 WRITE     RECORD                               79
     CSR   *IN79         IFEQ      *ON
    DC*R                   MOVE '*PGMQ   '$PRTN
     CSR                 MOVE      *ON           ERROR
     CSR                 EXSR      ZM71
     CSR                 GOTO      ENDUP3
     CSR                 ENDIF
     C*  create vslot record.
     CSR                 Z-ADD     $VWHSE        VSWHSE
     CSR                 MOVE      $VWHDP        VSWHDP
     CSR                 MOVE      $VAISL        VSAISL
     CSR                 Z-ADD     $VLOC         VSLOC
     CSR                 Z-ADD     $VRLVL        VSRLVL
     CSR                 MOVE      $VHAND        VSHAND
     CSR                 MOVE      $VDISP        VSDISP
     CSR                 MOVE      PHDISP        VSPDIS
     CSR                 MOVE      '*CURCMD '    $CVCMD
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD8O        VSCDTE
     CSR                 TIME                    VSCTIM
     CSR                 ADD       1             VSCTIM
     CSR                 WRITE     VSREC                                79
     CSR   *IN79         IFEQ      *ON
409 DC*R                   MOVE '*PGMQ   '$PRTN
     CSR                 MOVE      *ON           ERROR
     CSR                 EXSR      ZM71
     CSR                 GOTO      ENDUP3
     CSR                 ENDIF
     C***
     CSR                 ELSE
     C*** Update slot record
     CSR                 UPDATE    RECORD                               79
     CSR   *IN79         IFEQ      *ON
    DC*R                   MOVE '*PGMQ   '$PRTN
     CSR                 MOVE      *ON           ERROR
     CSR                 EXSR      ZM72
     CSR                 GOTO      ENDUP3
     CSR                 ENDIF
     CSR                 ENDIF
412dAC*
412dAC*     Update warehouse qty by qty put away.
412dAC*
412dACSR                 MOVE      '*STOCK  '    $ACMD
412dACSR                 MOVE      #PROG         $APRG
412dACSR                 MOVE      '*INTER  '    $ATYPE
412dACSR                 Z-ADD     LBWHSE        $AWHSE
412dACSR                 MOVE      LBITEM        $AITEM
412dAC*
412dACSR                 Z-ADD     0             $AQTY1
412dACSR                 Z-ADD     0             $AQTY2
412dACSR                 Z-ADD     0             $AQTY3
412dACSR                 SELECT
412dACSR   LBUTYP        WHENEQ    'N'
412dACSR                 Z-ADD     W3QTY         $AQTY1
412dACSR   LBUTYP        WHENEQ    '1'
412dACSR                 Z-ADD     W3QTY         $AQTY2
412dACSR   LBUTYP        WHENEQ    '2'
412dACSR                 Z-ADD     W3QTY         $AQTY3
412dACSR                 ENDSL
412dACSR                 EXSR      ZZWHSE
     C*
     C*   Update the LABEL record with slot.
     C*
     CSR   NEWLB         IFEQ      *OFF
     CSR   LBLBL#        CHAIN     LABEL                              79
     CSR   *IN79         IFEQ      *OFF
     CSR                 Z-ADD     W3QTY         LBQPCK
     CSR                 Z-ADD     W3RQTY        LBQRMN
     CSR                 Z-ADD     W3AQTY        LBQALC
     C*    Calculate cube and weight for put away qty.
     CSR   SBUCUB        MULT      W3QTY         LBCUBE
     CSR   SBUWGT        MULT      W3QTY         LBSWGT
     C*    Move slot info to label record.
     CSR                 MOVE      SLAISL        LBAISL
     CSR                 Z-ADD     SLLOC         LBLOC
     CSR                 Z-ADD     SLRLVL        LBRLVL
     CSR                 MOVE      SLHAND        LBHAND
     CSR                 MOVE      SLSTYP        LBSTYP
     CSR                 MOVE      SLDISP        LBDISP
     CSR   SLSTYP        IFEQ      'P'
     CSR                 Z-ADD     1             LBQRYF
     CSR                 ELSE
     CSR                 Z-ADD     0             LBQRYF
     CSR                 ENDIF
     C*
     CSR                 UPDATE    LBREC                                79
     CSR   *IN79         IFEQ      *ON
    DC*R                   MOVE '*PGMQ   '$PRTN
     CSR                 MOVE      *ON           ERROR
     CSR                 EXSR      ZM72
     CSR                 GOTO      ENDUP3
     CSR                 ENDIF
     CSR                 MOVE      *ON           NEWLB
     CSR                 ENDIF
     CSR                 ELSE
     CSR                 CLEAR                   LBREC
     C*
    DC*R                   Z-ADDPTTRN#    LBTRN#
     CSR                 CALL      'PIRLBL#'
     CSR                 PARM                    LBLBL#
     C*   Use saved label rec to create new label rec.
     CSR                 Z-ADD     SBWHSE        LBWHSE
     CSR                 MOVE      SBWHDP        LBWHDP
     CSR                 Z-ADD     SBQRYF        LBQRYF
     CSR                 MOVE      SBDSP2        LBDSP2
     CSR                 MOVE      SBITEM        LBITEM
     CSR                 MOVE      SBUTYP        LBUTYP
     CSR                 MOVE      SBUCOD        LBUCOD
     CSR                 Z-ADD     SBUCUB        LBUCUB
     CSR                 Z-ADD     SBUWGT        LBUWGT
     CSR                 Z-ADD     SBSEQ         LBSEQ
     CSR                 Z-ADD     SBPBAT        LBPBAT
     CSR                 MOVE      SBPO          LBPO
     CSR                 Z-ADD     SBORD         LBORD
     CSR                 Z-ADD     SBTIE         LBTIE
     CSR                 Z-ADD     SBHIGH        LBHIGH
     CSR                 MOVE      SBGRP1        LBGRP1
     CSR                 MOVE      SBGRP2        LBGRP2
     CSR                 MOVE      SBTYPE        LBTYPE
     CSR                 Z-ADD     SBPAL#        LBPAL#
     CSR                 Z-ADD     SBTRN#        LBTRN#
     CSR                 Z-ADD     SBRDTE        LBRDTE
     CSR                 MOVE      SBSTAT        LBSTAT
     C*
     CSR                 Z-ADD     W3QTY         LBQPCK
     CSR                 Z-ADD     W3RQTY        LBQRMN
     CSR                 Z-ADD     W3AQTY        LBQALC
     C*    Calculate cube and weight for put away qty.
     CSR   SBUCUB        MULT      W3QTY         LBCUBE
     CSR   SBUWGT        MULT      W3QTY         LBSWGT
     C*    Move slot info to label record.
     CSR                 MOVE      SLAISL        LBAISL
     CSR                 Z-ADD     SLLOC         LBLOC
     CSR                 Z-ADD     SLRLVL        LBRLVL
     CSR                 MOVE      SLHAND        LBHAND
     CSR                 MOVE      SLSTYP        LBSTYP
     CSR                 MOVE      SLDISP        LBDISP
     CSR   SLSTYP        IFEQ      'P'
     CSR                 Z-ADD     1             LBQRYF
     CSR                 ELSE
     CSR                 Z-ADD     0             LBQRYF
     CSR                 ENDIF
     C*
     CSR                 WRITE     LBREC                                79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *ON           ERROR
     CSR                 EXSR      ZM71
     CSR                 GOTO      ENDUP3
     CSR                 ENDIF
     CSR                 ENDIF
     C*
409 ACSR                 Z-ADD     W3RQTY        W3AQTY
409 ACSR   W3RQTY        IFGT      0
409 ACSR                 MOVE      *BLANKS       W3SCAN
409 ACSR                 Z-ADD     W3RQTY        W3QTY
412CACSR                 MOVE      *ON           *IN92
     CSR                 ELSE
412CACSR                 MOVE      *OFF          *IN92
409 ACSR                 EXSR      ZZCLSE
416dAC*
416dAC*    Multiple license plates, labels scanned. Get next one.
416dACSR   W5CNT         IFGT      0
416dACSR                 EXSR      ZZDLP1
416dACSR                 EXSR      SCR06I
416dAC*
416dACSR                 ELSE
409 ACSR                 EXSR      SCR01I
416dACSR                 ENDIF
     CSR                 ENDIF
416dAC*
409 ACSR   ENDUP3        ENDSR
415kAC*----------------------------------------------------------------
415kAC*
415kAC*  ZZUPD4   Update for screen 4.(Screen1A)
415kAC*
415kACSR   ZZUPD4        BEGSR
     CSR                 MOVE      *OFF          ERROR
     CSR                 MOVE      *ON           REFRSH
     C*
416dAC*    License plate/label scanned in. Add to work file.
416dACSR                 SELECT
416dACSR   PTATYP        WHENEQ    '*LICENSE'
416dACSR   PTATYP        OREQ      '*LABEL  '
416dAC*
416dAC*    License# scanned last time.
416dACSR                 SELECT
416dACSR   PTATYP        WHENEQ    '*LICENSE'
416dACSR                 MOVEL(P)  W5TXT1        W5TXT
416dAC*
416dACSR                 SELECT
416dAC*      Load last scanned value.
416dACSR   LSTSCR        WHENEQ    '05 '
416fDC**                   Z-ADDW5LCNS    W5LST#
416fMCSR                 MOVE      W5LCNS        W5LST#
416dACSR                 OTHER
416fDC**                   Z-ADDW1LCNS    W5LST#
416fMCSR                 MOVE      W1LCNS        W5LST#
416dACSR                 ENDSL
416dAC*
416dAC*    Label scanned last time.
416dACSR   PTATYP        WHENEQ    '*LABEL  '
416dACSR                 MOVEL(P)  W5TXT2        W5TXT
416dACSR                 SELECT
416dAC*      Load last scanned value.
416dACSR   LSTSCR        WHENEQ    '05 '
416fMCSR                 MOVE      W5LBL#        W5LST#
416fDC**                   Z-ADDW5LBL#    W5LST#
416dACSR                 OTHER
416fMCSR                 MOVE      W1LBL#        W5LST#
416fDC**                   Z-ADDW1LBL#    W5LST#
416dACSR                 ENDSL
416dACSR                 ENDSL
416dAC*
416dAC*    Add lic#/lbl# to work file.
416dACSR                 EXSR      ZZADPK
416dAC*
416dAC*    Setup to scan more entries.
416dACSR                 EXSR      SCR05I
416dAC*
416dAC*   Transaction# scanned in. Process as one.
416dACSR                 OTHER
416dAC*
     CSR   LBDSP2        IFEQ      '*MANUAL'
     CSR                 Z-ADD     LBQPCK        WORQTY            5 0
     CSR                 EXSR      SCR03I
     CSR                 ELSE
     CSR                 EXSR      SCR02I
     CSR                 ENDIF
416dACSR                 ENDSL
416dAC*
     CSR   ENDUP4        ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZUPD5   Update for screen 5.
416dAC*
416dACSR   ZZUPD5        BEGSR
416dACSR                 MOVE      *OFF          ERROR
416dAC*
416dACSR                 SELECT
416dAC*-------------------------------------------------------------------
416dAC*    End of scanned entries - proceed to putaway.
416fDC**         W5LCNS    WHEQ *ZEROS
416fMCSR   W5LCNS        WHENEQ    *BLANKS
416dACSR   W5LBL#        ANDEQ     *ZEROS
416dAC*
416dACSR                 SELECT
416dAC*    Only 1 entry scanned - Go to putaway screen.
416dACSR   W5CNT         WHENEQ    1
416hAC*
416hAC*   Get current task.
416hAC*
416jACSR                 MOVE      *BLANKS       CURTSK
416jACSR                 MOVE      *BLANKS       CURTYP
416jACSR                 MOVE      *OFF          CURENT
416hACSR                 EXSR      ZZTASK
416hACSR                 SELECT
416hACSR   CURTYP        WHENEQ    'D'
416hAC*   End current task.
416hACSR                 EXSR      ZZEND
416hACSR   CURTYP        WHENEQ    'I'
416hAC*  End current task and any previous open tasks.
416hACSR                 MOVE      *ON           FOUND
416hACSR   FOUND         DOWEQ     *ON
416hACSR                 MOVE      *BLANKS       CURTSK
416hACSR                 MOVE      *BLANKS       CURTYP
416hACSR                 MOVE      *OFF          CURENT
416hACSR                 EXSR      ZZTASK
416hACSR   FOUND         IFEQ      *OFF
416hACSR                 LEAVE
416hACSR                 ENDIF
416hACSR                 EXSR      ZZEND
416hACSR                 ENDDO
416hACSR                 ENDSL
416hAC*
416hAC*      User returned to this display from later
416hAC*      display.  Refresh transaction record to have
416hAC*      the correct data after creating/closing Idle
416hAC*      transaction records.
416hACSR                 SELECT
416hACSR   FRSTPS        WHENEQ    *OFF
416hAC*    Build key to work file to retrieve transaction#.
416hACSR                 SELECT
416hAC*      Last record scanned - License plate.
416hACSR   PTATYP        WHENEQ    '*LICENSE'
416hACSR                 MOVE      'P'           WKPTYP
416hAC*      Last record scanned - Label.
416hACSR   PTATYP        WHENEQ    '*LABEL '
416hACSR                 MOVE      'L'           WKPTYP
416hACSR                 ENDSL
416hACSR                 MOVE      W5LST#        WKPNBR
416hAC*    Retrieve transaction#.
416jACSR   PKKEY1        SETLL     WORKPUT
416jDC*R         PKKYA     CHAINWORKPUT             N79
416jMCSR   PKKEY1        READE(N)  WORKPUT                                79
416hACSR                 SELECT
416hACSR   *IN79         WHENEQ    *ON
416hACSR                 MOVE      *ZEROS        WKPTRN
416jACSR                 MOVE      *ON           ERROR
416jACSR                 MOVEL(P)  W5ERR1        ERRMSG
416jACSR                 EXSR      ZM0105
416jACSR                 GOTO      ENDUP5
416hACSR                 ENDSL
416hACSR                 Z-ADD     WKPTRN        WOTRN#
416hAC*
416hAC*    Retrieve transaction# record.
416hACSR   PTKEY         CHAIN(N)  PIRTRAN                            79
416hAC*
416hAC*    Putaway transaction no longer at open status.
416hACSR   *IN79         IFEQ      *OFF
416hACSR   PTSTAT        ANDNE     '1'
416hACSR                 MOVE      *ON           ERROR
416hACSR                 MOVE      *BLANKS       ERRMSG
416hACSR                 Z-ADD     PTTRN#        ERTRN#
416hACSR                 EXSR      ZM2002
416hACSR                 GOTO      ENDUP5
416jACSR                 ELSE
416jACSR   *IN79         IFEQ      *ON
416jACSR                 MOVE      *ON           ERROR
416jACSR                 MOVEL(P)  W5ERR1        ERRMSG
416jACSR                 EXSR      ZM0105
416jACSR                 GOTO      ENDUP5
416jACSR                 ENDIF
416hACSR                 ENDIF
416hACSR                 ENDSL
416hACSR                 MOVE      *OFF          FRSTPS
416dAC*
416dAC*    Retrieve label record for writing to work file.
416hDC*R         LBKEY7    SETLLLABEL7
416hDC*R         LBKEY7    READELABEL7                   79
416dAC*
416dACSR                 EXSR      ZZSTRT
416dACSR                 EXSR      ZZGETI
416dAC*
416dACSR   LBDSP2        IFEQ      '*MANUAL'
416dACSR                 Z-ADD     LBQPCK        WORQTY            5 0
416dACSR                 MOVE      '05 '         LSTSCR
416ddCSR                 EXSR      SCR03I
416dACSR                 ELSE
416dACSR                 MOVE      '05 '         LSTSCR
416dACSR                 EXSR      SCR02I
416dACSR                 ENDIF
416dAC*
416dAC*    More than 1 entry scanned - Go to select screen.
416dACSR   W5CNT         WHENGT    1
416dACSR                 MOVE      '05 '         LSTSCR
416nACSR                 MOVE      *OFF          SKIP6
416dACSR                 EXSR      SCR06I
416dAC*
416dACSR                 ENDSL
416dAC*
416dAC*-------------------------------------------------------------------
416dAC*    Have user verify qty from pallet to license plate.
416dACSR   OPPQTY        WHENEQ    'Y'
416dAC*
416dAC*    Retrieve label record for writing to work file.
416dACSR   LBKEY7        SETLL     LABEL7
416dACSR   LBKEY7        READE     LABEL7                                 79
416dAC*
416dAC*
416dAC*    Add license plate to work file.
416dACSR                 SELECT
416dACSR   PTATYP        WHENEQ    '*LICENSE'
416fDC**                   Z-ADDW5LCNS    SVPNBR
416fMCSR                 MOVE      W5LCNS        SVPNBR
416dACSR                 MOVE      'P'           SVPTYP
416dAC*    Add label to work file.
416dACSR   PTATYP        WHENEQ    '*LABEL  '
416fDC**                   Z-ADDW5LBL#    SVPNBR
416fMCSR                 MOVEL     W5LBL#        SVPNBR
416dACSR                 MOVE      'L'           SVPTYP
416dACSR                 ENDSL
416dACSR                 MOVE      '05 '         LSTSCR
416dAC*
416dACSR                 EXSR      SCR04I
416dAC*
416dAC*-------------------------------------------------------------------
416dAC*    Otherwise, go back to scan in more plates/labels.
416dACSR                 OTHER
416dAC*
416dAC*    Retrieve label record for writing to work file.
416dACSR   LBKEY7        SETLL     LABEL7
416dACSR   LBKEY7        READE     LABEL7                                 79
416dACSR                 SELECT
416dAC*    Add license plate to work file.
416dACSR   PTATYP        WHENEQ    '*LICENSE'
416dACSR                 MOVEL(P)  W5TXT1        W5TXT
416fMCSR                 MOVE      W5LCNS        W5LST#
416fMCSR                 MOVE      W5LCNS        SVPNBR
416fDC**                   Z-ADDW5LCNS    W5LST#
416fDC**                   Z-ADDW5LCNS    SVPNBR
416dACSR                 MOVE      'P'           SVPTYP
416dACSR                 EXSR      ZZADPK
416dACSR                 EXSR      SCR05I
416dAC*
416dAC*    Add label to work file.
416dACSR   PTATYP        WHENEQ    '*LABEL  '
416dACSR                 MOVEL(P)  W5TXT2        W5TXT
416fDC**                   Z-ADDW5LBL#    W5LST#
416fMCSR                 MOVE      W5LBL#        W5LST#
416fDC**                   Z-ADDW5LBL#    SVPNBR
416fMCSR                 MOVEL     W5LBL#        SVPNBR
416jDC*R                   MOVE 'P'       SVPTYP
416jMCSR                 MOVE      'L'           SVPTYP
416dACSR                 EXSR      ZZADPK
416dACSR                 EXSR      SCR05I
416dACSR                 ENDSL
416dACSR                 ENDSL
416dAC*
416daCSR   ENDUP5        ENDSR
416dAC*----------------------------------------------------------------
416dAC*
416dAC*  ZZUPD6   Update for screen 6.
416dAC*
416dACSR   ZZUPD6        BEGSR
416dACSR                 MOVE      *OFF          ERROR
416dAC*
416dAC*    Proceed to putaway.
416dAC*
416dAC*   Get current task.
416dAC*
416pACSR                 MOVE      *BLANKS       CURTSK
416pACSR                 MOVE      *BLANKS       CURTYP
416pACSR                 MOVE      *OFF          CURENT
416dACSR                 EXSR      ZZTASK
416dACSR                 SELECT
416dACSR   CURTYP        WHENEQ    'D'
416dAC*   End current task.
416dACSR                 EXSR      ZZEND
416dACSR   CURTYP        WHENEQ    'I'
416dAC*  End current task and any previous open tasks.
416dACSR                 MOVE      *ON           FOUND             1
416dACSR   FOUND         DOWEQ     *ON
416dACSR                 MOVE      *BLANKS       CURTSK
416dACSR                 MOVE      *BLANKS       CURTYP
416dACSR                 MOVE      *OFF          CURENT
416dACSR                 EXSR      ZZTASK
416dACSR   FOUND         IFEQ      *OFF
416dACSR                 LEAVE
416dACSR                 ENDIF
416dACSR                 EXSR      ZZEND
416dACSR                 ENDDO
416dACSR                 ENDSL
416dAC*
416dACSR                 SELECT
416dAC*    User scanned in a license plate.
416dACSR   PTATYP        WHENEQ    '*LICENSE'
416dACSR                 Z-ADD     LITRN#        WOTRN#
416dAC*
416dAC*    User scanned in a label.
416dACSR   PTATYP        WHENEQ    '*LABEL  '
416dACSR                 Z-ADD     LKTRN#        WOTRN#            7 0
416dAC*
416dACSR                 ENDSL
     C*
     C*   Get transaction record for put-away.
     C*
     CSR   PTKEY         CHAIN(N)  PIRTRAN                            79
     C*
     C*     Record not found.
     C*
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *ON           ERROR
     CSR                 MOVE      *ON           *IN22
     CSR                 MOVE      *ON           *IN02
     CSR                 MOVE      *BLANKS       ERRMSG
     CSR                 MOVE      DESC(1)       ERRMSG
     CSR                 EXSR      ZM7979
     CSR                 GOTO      ENDUP6
     CSR                 ENDIF
     C*
     C*   Start new transaction.
     C*
     CSR                 EXSR      ZZSTRT
     CSR                 EXSR      ZZGETI
416dAC*
416dACSR   LBDSP2        IFEQ      '*MANUAL'
416dACSR                 Z-ADD     LBQPCK        WORQTY            5 0
416dACSR                 MOVE      '06 '         LSTSCR
416ddCSR                 EXSR      SCR03I
416dACSR                 ELSE
416dACSR                 MOVE      '06 '         LSTSCR
416dACSR                 EXSR      SCR02I
416dACSR                 ENDIF
416dAC*
416daCSR   ENDUP6        ENDSR
     C*----------------------------------------------------------------
     C*
412dAC*  ZZWHSE   Update warehouse quantities.
     C*
412dACSR   ZZWHSE        BEGSR
     C*
     CSR   *LIKE         DEFINE    $AITEM        SVITEM
     CSR                 MOVE      $AITEM        SVITEM
     C*
     C*    If Alias item or Same Slot Breakdown item
     C*      Then DO NOT update quantity of label item.
     C*
     CSR   ITTYPE        IFNE      'A'
     CSR   ITTYPE        ANDNE     'S'
     CSR                 CALL      'ADJQTY'
     CSR                 PARM                    $ACMD             8
     CSR                 PARM                    $APRG            10
     CSR                 PARM                    $ATYPE            8
     CSR                 PARM                    $AWHSE            3 0
     CSR                 PARM                    $AITEM           15
     CSR                 PARM                    $AQTY1            7 0
     CSR                 PARM                    $AQTY2            7 0
     CSR                 PARM                    $AQTY3            7 0
     CSR                 PARM                    $ARTQ1            7 0
     CSR                 PARM                    $ARTQ2            7 0
     CSR                 PARM                    $ARTQ3            7 0
     CSR                 PARM                    $ARTN             8
     CSR                 PARM                    $AERM
413eDC**         $LRTN     IFEQ '*PGMQ   '
413eMCSR   $ARTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      *ON           ERROR
413eDC**                   MOVE $LMSG     #MSGK
413eMCSR                 MOVE      $AMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ENDIF
     CSR                 ENDIF
     C*
     C*  If Alias or SSB item
     C*   Then update Base item warehouse quantity.
     C*
     CSR   ITTYPE        IFEQ      'A'
     CSR   ITTYPE        OREQ      'S'
     CSR                 MOVE      #BITEM        $AITEM
     CSR                 CALL      'ADJQTY'
     CSR                 PARM                    $ACMD             8
     CSR                 PARM                    $APRG            10
     CSR                 PARM                    $ATYPE            8
     CSR                 PARM                    $AWHSE            3 0
     CSR                 PARM                    $AITEM           15
     CSR                 PARM                    $AQTY1            7 0
     CSR                 PARM                    $AQTY2            7 0
     CSR                 PARM                    $AQTY3            7 0
     CSR                 PARM                    $ARTQ1            7 0
     CSR                 PARM                    $ARTQ2            7 0
     CSR                 PARM                    $ARTQ3            7 0
     CSR                 PARM                    $ARTN             8
     CSR                 PARM                    $AERM
413eDC**         $LRTN     IFEQ '*PGMQ   '
413eMCSR   $ARTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      *ON           ERROR
413eDC**                   MOVE $LMSG     #MSGK
413eMCSR                 MOVE      $AMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ENDIF
     CSR                 ENDIF
     C*
     C*  If Contract item and *STOCK or *UNSTOCK
     C*   Then update Base item warehouse quantity.
     C*    and allocate/unallocate Base item warehouse quantity.
     C*
     C*  Note: The *UNALLOC command does not effect the Contract
     C*        item's Base item Allocated quantities.
     C*
     CSR   ITTYPE        IFEQ      'C'
     CSR   $ACMD         IFNE      '*UNALLOC'
     CSR                 MOVE      #BITEM        $AITEM
     CSR                 CALL      'ADJQTY'
     CSR                 PARM                    $ACMD             8
     CSR                 PARM                    $APRG            10
     CSR                 PARM                    $ATYPE            8
     CSR                 PARM                    $AWHSE            3 0
     CSR                 PARM                    $AITEM           15
     CSR                 PARM                    $AQTY1            7 0
     CSR                 PARM                    $AQTY2            7 0
     CSR                 PARM                    $AQTY3            7 0
     CSR                 PARM                    $ARTQ1            7 0
     CSR                 PARM                    $ARTQ2            7 0
     CSR                 PARM                    $ARTQ3            7 0
     CSR                 PARM                    $ARTN             8
     CSR                 PARM                    $AERM
413eDC**         $LRTN     IFEQ '*PGMQ   '
413eMCSR   $ARTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      *ON           ERROR
413eDC**                   MOVE $LMSG     #MSGK
413eMCSR                 MOVE      $AMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ENDIF
     CSR                 ENDIF
     C*
     CSR   $ACMD         IFEQ      '*STOCK  '
     CSR   $ACMD         OREQ      '*UNSTOCK'
     CSR   $ACMD         IFEQ      '*STOCK  '
     CSR                 MOVE      '*ALLOC  '    $ACMD
     CSR                 ELSE
     CSR                 MOVE      '*UNALLOC'    $ACMD
     CSR                 ENDIF
     CSR                 MOVE      #BITEM        $AITEM
     CSR                 CALL      'ADJQTY'
     CSR                 PARM                    $ACMD             8
     CSR                 PARM                    $APRG            10
     CSR                 PARM                    $ATYPE            8
     CSR                 PARM                    $AWHSE            3 0
     CSR                 PARM                    $AITEM           15
     CSR                 PARM                    $AQTY1            7 0
     CSR                 PARM                    $AQTY2            7 0
     CSR                 PARM                    $AQTY3            7 0
     CSR                 PARM                    $ARTQ1            7 0
     CSR                 PARM                    $ARTQ2            7 0
     CSR                 PARM                    $ARTQ3            7 0
     CSR                 PARM                    $ARTN             8
     CSR                 PARM                    $AERM
413eDC**         $LRTN     IFEQ '*PGMQ   '
413eMCSR   $ARTN         IFEQ      '*PGMQ   '
     CSR                 MOVE      *ON           ERROR
413eDC**                   MOVE $LMSG     #MSGK
413eMCSR                 MOVE      $AMSG         #MSGK
     CSR                 EXSR      ZMQMSG
     CSR                 ENDIF
     CSR                 ENDIF
     CSR                 ENDIF
     C*
     CSR                 MOVE      SVITEM        $AITEM
412dACSR                 ENDSR
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Transaction
Label
License
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
