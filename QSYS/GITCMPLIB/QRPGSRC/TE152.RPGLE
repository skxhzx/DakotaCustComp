      /copy qcopysrc,hspecs
500bA*----------------------------------------------------------------
500bA*  Multilingual Verision
500bA*  Every screen and message has a corresponding Spanish version.
500bA*  Any changes must be made to both languages.
500bA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TE152     RF - Task entry
     *  15 February, 2000
     *  Hemant Kapadia / Roxanne Harrison
     *
     *  **************************
     *
     *       Mirror of TE112
520 M*       Mirror of TE112, except this pgm does not allow entry of
     *       multiple transactions, TE112 does.
     *
     *  **************************
     *
     *----------------------------------------------------------------
     *  Revisions
     *
218 A*    01/29/97  HNK  2.18
     *    Status of transaction changed to '4' instead of '3' when
     *    a manual task is closed.(TKSTD='N')
     *    Shift and crew code updated in ZZUPD2 subroutine, when
     *    TSKFLG = *OFF
     *
409 A*    06/04/98  HNK  4.09
     *    Warning message added on screen 2.
     *
410 A*    10/02/98  HNK  4.10
     *    MOVEL used instead of MOVE.
     *    MOVE blanks to $CSTR.
     *
410 A*    12/01/98  HNK  4.10
     *    Revised to keep the Direct task open when an Indirect task
     *    is entered.  Program also creates an Idle task, if there is
     *    no open task.
     *    ZZUPD2 routine redone. Tasks are ended and started
     *    in their own routines ZZSTRT and ZZEND.  ZZCHK2 and ZZFIL2
     *    routine also revised.
     *    Although 'BEGDAY' is coded, it is not used because starting
     *    an Idle task, as soon as an employee gets into the program
     *    takes care of that for the begining of the day.
     *
413 A*    02/15/00  HNK  4.13
     *    Created - Mirror of TE112
     *    Screen 3 not used for RF task entry (Disabled)
     *
413aA*    03/06/00  DAS  4.13a
     *      - Revised to call ZZTASK before calling ZZEND. Re: ZZTASK
     *        is initially called when displaying screen2, after an
     *        employee number has been scanned. If the user sits on
     *        screen2 there is a chance that a previously started
     *        transaction is closed before the user starts the next
     *        transaction. This change should close that small hole
     *        which AFI found.
     *
413bA*    03/20/00  HNK  4.13b
     *      - BEGDAY is now used to create a new transaction to mark
     *        the begining of the day for an employeee.  ENDDAY will
     *        also create a new transaction to mark the end of day.
     *
414 A*    20/12/00  HNK  4.14
     *      - End date and time update corrected for BEGDAY task.
     *
415 A*    12/05/00  HNK  4.15
     *      - Do not allow direct tasks except 'BEGDAY' and 'ENDDAY'
     *      - Verify dept and section only if entered.
     *
416 A*    08/22/01  HNK  4.16
     *      - Correct problem of current task not displaying correctlyn.
     *        on screen2.
     *      - Initialize PTGRP1 and PTGRP2 fields before writing record
     *        to PIRTRAN.
     *
416aA*    08/30/01  HNK  4.16a
     *      - Start IDLE task when they press F10 to end current task.n.
     *
416bA*    09/19/01  HNK  4.16b
     *      - Goto screen 1 after F10
416cA*    12/06/01  MLB  4.16c
     *      - Changed PIRTRAN1 from output only to update/write capable.
     *      - Revised ZZTASK to first look at PIRTRAN1 for a status
     *        '2' record. This will save reading through every record
     *        for the employee.
     *
416dA*    07/14/02  HNK  4.16d
     *      - Fix - MOVEL instead of MOVE 'IDLE'
     *
416eA*    08/27/02  HNK  4.16e
     *      - Fix - Create transaction for ENDDAY when SCNTYP=D and
     *        CURTYP=I
     *
417 A*    08/22/03  MLB  4.17
     *      - Fix - Revise routine ZZCKU2 to READE using partial key
     *        of employee number.  This will prevent incorrect times
     *        from being calculated.
     *
500 A*    06/16/05  MLB  5.00
     *      - Enh: Added client custom code support.
500aA*    10/05/05  MLB  5.00a
     *      - Enh: Revised program to add routine CHKCC to call
     *        CCJITCL
     *
500bA*    06/07/06  JCJ  5.00
     *      - Added Multilingual logic.
     *
520 A*    12/05/08  RBD  5.20
     *      - Fix: Do not allow F10 to end transaction if multiple
     *        transactions exist.
     *
520aA*    02/23/09  GJA  5.20a
     *      - Fix: Added additional code for 5.20 fix.
     *
520bA*    04/22/09  RH   5.20b
     *      - Fix: TDFINW field was not large enough, causing decimal
     *        data error. Add WOFINW work field
     *
520c *    02/24/09  GJA  5.20c
     *      - Add zone disbursement for task
     *
520d *    02/24/09  GJA  5.20d
     *      - Fix:  Do not allow task to go negative
     *
610aA*    08/05/09  RH   6.10a
     *      - Enh: Rename format to TE15201
     *      - Enh: Add 16 X 20 screens SCREEN61, SCREEN62
     *        SCRN61S & SCRN62S (spanish)
     *
640aA*    06/07/12  RTR  6.40a
     *      - Fix: Changed to allow F10 to end the transaction entered.
640bA*    06/07/12  LMC  6.40b
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
730aA*    01/28/19  LMC  7.30a
     *      - Fix: Mod 640c in the override process, changes the value
     *        of the curtrn field, but leaves the other cur* fields
     *        with the values from a different transaction.
     *        This was identified becausee a fixed transaction at a
     *        status of 8 got changed to a status of 4 which should
     *        never happen, it should have been changed to a status
     *        3. The code in ZZEND was flawed, because it was using
     *        the values of the cur* fields from a different trans.
730bA*    09/09/19  LMC  7.30b
     *      - Fix: When a transaction that is at suspended status is
     *        being ended. We need to set start time = end time. And
     *        remove the emp#. so epm reports are not overstated for
     *        an employee.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
     *
SVLaA*    08/05/09  RH   SVLa
     *      - Enh: Use Custom 16 X 20 screens for RF 16 line.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCa *    09/07/20 RTR PFCa
     *      - Enh: Add support to program to capture information
     *        needed for APT Interface.
PFCbA*    02/15/22  MLB  PFCb
     *      - Enh: Revised PFCa mod to add chain to OPTIONS file
     *        to ZZINZ2 after W1WHSE is populated.
     *      - Added file OPTIONS to pgm.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  81        FOUND INDICATOR ON CHECK OPERATION
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *----------------------------------------------------------------
     *  Notes:
     *       -Since the PIRTRAN2 file is in descending order of start
     *        date and start time, read forward will read records in
     *        the following order.
     *        1 BREAK 1/26/96  10:00:00
     *        2 BREAk 1/26/96   8:00:00
     *        3 CLEAN 1/25/96  16:00:00
     *        4 BREAK 1/25/96   9:30:00
     *
     *
     *
     *----------------------------------------------------------------
     *  File Specs
     *
610aDF*e152fm   cf   e             workstn
610aMFte15201   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
610a F                                     sfile(m16rec:msgk)
     Fpiruser1  if   e           k disk
     Fpirtran   uf   e           k disk
416cD*PIRTRAN1O   E           K        DISK
416cMFpirtran1  uf a e           k disk
     F                                     rename(ptrec:ptrec1)
     Fpirtran2  uf   e           k disk
     F                                     rename(ptrec:ptrec2)
     Ftask      if   e           k disk
     Ftaskdet   uf   e           k disk
520 AFmultran1  if   e           k disk
520aAFmultran   if   e           k disk
     F                                     rename(murec:murec2)
413X *IRDEV  IF  E           K        DISK
520cAFLABEL90   IF   E           K DISK
520cAFWORKLBL   IF   E           K DISK
520cAFoptione   if   e           k disk
PFCbAfoptions   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(2) ctdata perrcd(1)
500bAD descsp          s             50    dim(2) ctdata perrcd(1)
640aAD emsg            s             50    dim(1) ctdata perrcd(1)
500 A*----------------------------------------------------------------
500 A*  Client ID
500 A*
     D @getcl          c                   const('GETCLIENT')
500 A*
500 A* insert client copy source here.
SVLaA /COPY QCOPYSRC,ID#SAVAL
500 A*
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $ltask                19     24
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
500aA*
500aAD  $ltrn#                19     25  0
500aAD  $litem                26     40
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  ertask                 1      6
     *
     D  ersdte                 7     14
     D  ersm                   7      8
     D  ers1                   9      9
     D  ersd                  10     11
     D  ers2                  12     12
     D  ersy                  13     14
     *
     D  erstim                15     22
     D  ershr                 15     16
     D  ersc1                 17     17
     D  ersmi                 18     19
     D  ersc2                 20     20
     D  ersss                 21     22
     *
     D  eretim                23     30
     D  erehr                 23     24
     D  erec1                 25     25
     D  eremi                 26     27
     D  erec2                 28     28
     D  eress                 29     30
     *
     D  eredte                31     38
     D  erem                  31     32
     D  ere1                  33     33
     D  ered                  34     35
     D  ere2                  36     36
     D  erey                  37     38
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgsp          c                   const('PIRMSGFSP ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Name constants
     *
     D digit           c                   const('0123456789 ')
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *
     D                 ds
     D  dsmdy                  1      6  0
     D  dsmo                   1      2  0
     D  dsdd                   3      4  0
     D  dsyy                   5      6  0
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
640bA*----------------------------------------------------------------
640bA*  Prototypes
640bA*----------------------------------------------------------------
640bA
640bAD wrttran1        pr                  extpgm('WRTTRAN1')
640bA * Input
640bAD   ppcmd                        8
640bAD   ppwait                       2  0
640bAD   ppwhse                       3  0
640bAD   pptran#                      7  0
640bAD   ppfromdate                   8  0
640bAD   pptodate                     8  0
640bAD   ppemp#                       5  0
520cA*----------------------------------------------------------------
     *  *USER  -  User options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPMAN   -  Manually assign employee number (Y,N).
     *    OPNXTE  -  Next employee number.
     *    OPVYN   -  Processing selection by voice (Y,N).
     *    OPZORD  -  Collect selection data by zone or department?
     *    OPTBD   -  Tote/Box/Drop?  (Y,N)
     *
     * Data structure
     *
     D opedta          ds
     D  opman                  1      1
     D  opnxte                 2      6  0
     D  opvyn                  7      7
     D  opzord                 8      8
     D  optbd                  9      9
PFCaA*----------------------------------------------------------------
PFCaA*  Constants/Variables for APT
PFCaA
PFCaAd aptsk1          c                   'SIGNON    '
PFCaAd aptsk2          c                   '*JOB0100  '
PFCaAd apclos          c                   '*CLOSE    '
PFCaAd @gtstd          c                   'GETEPMSTD'
PFCaA
PFCaAd logapt          s               n   inz(*on)
PFCaAd wdwuse          s              4a

     *----------------------------------------------------------------
     *  Variables
     *
     D $cmd            s              8
     D $msgf           s             10
     D $name           s             40
     D $pemp#          s              5
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D ap              s                   like(w3sap)
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D curdte          s              8  0
     D curent          s              1
     D curtim          s              6  0
     D curtrn          s              7  0
     D curtsk          s              6
     D curtyp          s              1
     D diff            s              3  0
     D e               s              2  0
     D enddte          s              8  0
     D enter           s              5  0
     D error           s              1
     D fintim          s                   like(ptetim)
     D forevr          s              1
     D found           s              1
     D help            s              5  0
     D hrs             s                   like(w3shrs)
     D kystat          s              1
     D miltim          s                   like(ptetim)
     D min             s                   like(w3smin)
     D msgk            s              4  0
     D mulflg          s              1
     D nxtscr          s              3
     D ovrrid          s              1
     D prvdte          s                   like(ptsdte)
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D scntsk          s              6
     D scntyp          s              1
     D stat            s                   like(ptstat)
     D stdate          s                   like(ptsdte)
     D strdte          s              8  0
     D strtim          s                   like(ptstim)
     D sttime          s                   like(ptstim)
     D svtlen          s                   like(ptdmin)
     D svtrn#          s                   like(pttrn#)
     D t#task          s              6
     D timlen          s                   like(ptdmin)
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D trans#          s                   like(pttrn#)
640aAD trnint          s               n
     D tskflg          s              1
     D warn            s              1
520bAD wfinw           s              9  0
640bAD wrtpcmd         s             10
640bAD wrtpwait        s              2  0
640bAD wrtpwhse        s              3  0
640bAD wrtptran#       s                   like(pttrn#)
640bAD wrtpfrmdate     s              8  0
640bAD wrtptodate      s              8  0
640bAd wrtpemp#        s                   like(ptemp#)
     D zzedte          s                   like(ptedte)
     D zzemdy          s              6  0
     D zzetim          s                   like(ptetim)
     D zzsdte          s                   like(ptsdte)
     D zzsmdy          s              6  0
     D zzstim          s                   like(ptstim)
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
520a C*                  eval      *INLR=*on
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
500bAC                   select
500bAC                   when      e$lng = 'SP'
610a C                   if        #lline = '16' and client = saval
610aAC                   exfmt     scrn61s                              50
610aAC                   else
500bAC                   exfmt     scrn1sp                              50
610aAC                   endif
500bAC                   other
610a C                   if        #lline = '16' and client = saval
610aAC                   exfmt     screen61                             50
610aAC                   else
     C                   exfmt     screen1                              50
610aAC                   endif
500bAC                   endsl
     C                   endif
     C                   if        nxtscr = '02 '
500bAC                   select
500bAC                   when      e$lng = 'SP'
610a C                   if        #lline = '16' and client = saval
610aAC                   exfmt     scrn62s                              50
610aAC                   else
500bAC                   exfmt     scrn2sp                              50
610aAC                   endif
500bAC                   other
610a C                   if        #lline = '16' and client = saval
610aAC                   exfmt     screen62                             50
610aAC                   else
     C                   exfmt     screen2                              50
610aAC                   endif
500bAC                   endsl
     C                   endif
     C                   if        nxtscr = '03 '
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   exfmt     scrn3sp                              50
500bAC                   other
     C                   exfmt     screen3                              50
500bAC                   endsl
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
     C                   setoff                                       616263
     C                   setoff                                       646566
     C                   setoff                                       676869
     C                   setoff                                       70
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     C                   eval      tskflg = *off
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     *
     C                   exsr      zzdft1
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     C                   eval      *in91 = *on
     C                   exsr      zzfil2
409 AC                   eval      ovrrid = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     *
     C                   eval      *in91 = *on
     C                   exsr      zzfil3
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     ***                  MOVE '*EXIT   '$PRTN
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so onto the next screen.
     *
     C                   exsr      scr02i
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scr01i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for multran records
     *
520aAC                   exsr      zzckmt
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C                   if        cmdtkn = *on
     C                   goto      endsc2
     C                   endif
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so onto the next screen.
     *
     C                   exsr      scr01i
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scr02i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C                   if        cmdtkn = *on
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Everything went fine so onto the next screen.
     *
     C                   exsr      scr03i
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
500 A*
500 A* Get client id.
500 A*
500 AC                   call      @getcl
500 AC                   parm                    client           10
500 A*
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
610aAC                   select
610aAC                   when      #lline = '16'
610aAC                   write     m16ctl
610aAC                   other
     C                   write     msgctl
610aAC                   endsl
     C                   eval      msgk = *zeros
610aAC                   select
610aAC                   when      #lline = '16'
610aAC                   write     m16clr
610aAC                   other
     C                   write     msgclr
610aAC                   endsl
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
610aAC                   select
610aAC                   when      #lline = '16'
610aAC                   write     m16ctl
610aAC                   other
     C                   write     msgctl
610aAC                   endsl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      $msgf = #msgsp
500bAC                   other
     C                   eval      $msgf = #msgf
500bAC                   endsl
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
610aAC                   select
610aAC                   when      #lline = '16'
610aAC                   write     m16rec
610aAC                   other
     C                   write     msgrec
610aAC                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
610aAC                   select
610aAC                   when      #lline = '16'
610aAC                   write     m16rec
610aAC                   other
     C                   write     msgrec
610aAC                   endsl
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      $msgf = #msgsp
500bAC                   other
     C                   eval      $msgf = #msgf
500bAC                   endsl
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     ***                  PARM $PPRG     #PGMQ2 10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1007  Invalid date entered.
     *
     C     zm07          begsr
     C                   eval      #msgid = 'PIR1007'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT11021  Invalid item type entered.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'IT11021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
640aA*----------------------------------------------------------------
640aA*   PIR9999  Generic error message
640aA*
640aAC     zm9999        begsr
640aAC                   eval      #msgid = 'PIR9999'
640aAC                   eval      #msgtp = '*DIAG  '
640aAC                   eval      $md = *blanks
640aAC                   movea     errmsg        $md(1)
640aAC                   exsr      zmpmsg
640aAC                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11201  Transaction already started by other employee.
     *
     C     zm1201        begsr
     C                   eval      #msgid = 'TE11201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11202  Transaction is already closed.
     *
     C     zm1202        begsr
     C                   eval      #msgid = 'TE11202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     TE11203  Hour must be <or= 23.
     *
     C     zm1203        begsr
     C                   eval      #msgid = 'TE11203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     TE11204  Minute must be <or= 59.
     *
     C     zm1204        begsr
     C                   eval      #msgid = 'TE11204'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     TE11205  Cannot enter a standard task.
     *
     C     zm1205        begsr
     C                   eval      #msgid = 'TE11205'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11206  Transaction is already ended.
     *
     C     zm1206        begsr
     C                   eval      #msgid = 'TE11206'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11207  Transaction is interrupted.
     *
     C     zm1207        begsr
     C                   eval      #msgid = 'TE11207'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11208  Transaction is cancelled.
     *
     C     zm1208        begsr
     C                   eval      #msgid = 'TE11208'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11209  End date must be > start date.
     *
     C     zm1209        begsr
     C                   eval      #msgid = 'TE11209'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11210  If the dates are different, time lapse cannot be
     *            more than one day.
     C     zm1210        begsr
     C                   eval      #msgid = 'TE11210'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11211  If the dates are different, end time must be <=
     *            start time.
     C     zm1211        begsr
     C                   eval      #msgid = 'TE11211'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11212  If the dates are same, end time must be > start time
     C     zm1212        begsr
     C                   eval      #msgid = 'TE11212'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11213  End date cannot be > current date.
     C     zm1213        begsr
     C                   eval      #msgid = 'TE11213'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11214  End time cannot be > current time, if the
     *            end date is = current date.
     C     zm1214        begsr
     C                   eval      #msgid = 'TE11214'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11216  Invalid value entered for AM/PM.
     C     zm1216        begsr
     C                   eval      #msgid = 'TE11216'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11217  Overlapping time.(Std or manual)
     C     zm1217        begsr
     C                   eval      #msgid = 'TE11217'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TE11218  Overlapping manual task.
     C     zm1218        begsr
     C                   eval      #msgid = 'TE11218'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
409 A*----------------------------------------------------------------
409 A*   TE11220  Warning: Std task is active. Do you really want to
409 A*                     end that and start a manual task?
409 AC     zm1220        begsr
409 AC                   eval      #msgid = 'TE11220'
409 AC                   eval      #msgtp = '*DIAG  '
409 AC                   movea     errmsg        $md(1)
409 AC                   exsr      zmpmsg
409 AC                   endsr
     *----------------------------------------------------------------
520 A*   TE11221  Multiple transactions exist.
520 A*     " Close previous multiple transactions. "
     *
520 AC     zm1221        begsr
520 AC                   eval      #msgid = 'TE11221'
520 AC                   eval      #msgtp = '*DIAG  '
520 AC                   movea     errmsg        $md(1)
520 AC                   exsr      zmpmsg
520 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZAPMI  Convert AM/PM time to military format.
     *
     C     zzapmi        begsr
     C                   if        hrs = 0  and
     C                             min = 0
     C                   eval      miltim = 0
     C                   else
     C                   eval      dshms = 0
     C                   eval      dshh = hrs
     C                   eval      dsmm = min
     C                   if        ap = 'A'  and
     C                             hrs = 12  or
     C                             ap = 'P'  and
     C                             hrs <> 12
     C                   add       12            dshh
     C                   endif
     C                   eval      miltim = dshms
     C                   endif
     C                   endsr
PFCaA
PFCaA*----------------------------------------------------------------
PFCaA*  ZZAPT   Call APT processing programs.
PFCaA
PFCaAc     zzapt         begsr
PFCaA
PFCaAc                   eval      APSEQ# = APSEQ# + 1
PFCaA
PFCaAc                   select
PFCaAc                   when      aploc = 'BEGDAY'
PFCaAc                   eval      aploc = 'S     '
PFCaAc                   when      aploc = 'BREAK '
PFCaAc                   eval      aploc = 'B     '
PFCaAc                   when      aploc = 'ENDDAY'
PFCaAc                   eval      aploc = 'E     '
PFCaAc                   when      aploc = 'IDLE  '
PFCaAc                   eval      aploc = 'I     '
PFCaAc                   when      aploc = 'LUNCH '
PFCaAc                   eval      aploc = 'L     '
PFCaAc                   endsl
PFCaA
PFCaAc                   CALL      'APTMAIN'
PFCaAc                   PARM                    APCMD            10
PFCaAc                   PARM      #PROG         APPGM            10
PFCaAc                   PARM      PTWHSE        APWHSE            3 0
PFCaAc                   PARM      0             APLBL#            7 0
PFCaAc                   PARM                    APTRN#            7 0
PFCaAc                   PARM      #USER         APUSER           10
PFCaAc                   PARM      W1EMP#        APEMP#            5 0
PFCaAc                   PARM      *BLANKS       APRTID            5
PFCaAc                   PARM      *BLANKS       APRTE             5
PFCaAC                   PARM                    APLOC            20
PFCaAC                   PARM                    APSEQ#            5 0
PFCaAC                   PARM                    APRTN            10
PFCaAC                   PARM                    APMSG            60
PFCaA
PFCaAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *   Verify warehouse and get description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Verify warehouse department.
     *
415 AC                   if        w1whdp <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
415 AC                   endif
     *
     *  Verify section type.
     *
415 AC                   if        w1styp <> *blanks
     C                   if        w1styp <> 'F'  and
     C                             w1styp <> 'P'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm21
     C                   endif
415 AC                   endif
     *
     *  Verify employee number
     *
     C     w1emp#        chain     piruser1                           79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = descsp(1)
500bAC                   other
     C                   eval      errmsg = desc(1)
500bAC                   endsl
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     C                   eval      tskflg = *off
     C                   eval      *in81 = *off
     C     digit         check     w2task                                 81
     *
     *  *IN81 = *ON - Found character other than that contained
     *           in the field DIGIT.
     *
     C                   if        *in81
     C                   eval      tskflg = *on
     C                   endif
     *
     C                   if        tskflg = *on
     *
     *  Verify Task code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   movel     w2task        $ltask
     C                   call      'TK900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     C                   movel     w2task        t#task
     *
     *  Cannot create a standard task.
     *
415 AC                   if        t#task <> 'BEGDAY'  and
415 AC                             t#task <> 'ENDDAY'
415 MC     tkkey         chain     task                               79
415 MC                   if        tktype = 'D'
415 MC                   eval      error = *on
415 MC                   eval      *in01 = *on
415 MC                   eval      *in21 = *on
415 MC                   eval      errmsg = *blanks
415 MC                   movel     w2task        ertask
415 MC                   exsr      zm1205
415 MC                   endif
415 AC                   endif
     *
410 D*  Warning: Std task is active.  Do you really want to end that
410 D*           and start a manual task?
     *
410 D*R                   MOVE '2'       STAT
410 D*R         PTKEY1    CHAINPIRTRAN1            N79
410 D*R                   SELEC
410 D*R         *IN79     WHEQ *OFF
410 D*R                   MOVELPTTASK    T#TASK
410 D*R         TKKEY     CHAINTASK                 79
410 D*R         *IN79     IFEQ *OFF
410 D*R         TKTYPE    ANDEQ'D'
410 D*R         OVRRID    ANDEQ*OFF
410 D*R                   MOVE *ON       ERROR
410 D*R                   MOVE *ON       *IN01
410 D*R                   MOVE *ON       *IN21
410 D*R                   MOVE *BLANKS   ERRMSG
410 D*R                   EXSR ZM1220
410 D*R                   ENDIF
410 D*R                   ENDSL
410 D*
     C                   else
     *  Verify transaction number
520aAC                   if        mulflg = *on
520aAC                   eval      error = *on
520aAC                   eval      errmsg = *blanks
520aAC                   exsr      zm1221
520aAC                   endif
     C                   eval      trans# = 0
410 AC                   eval      $cstr = *blanks
410 D**                   MOVE W2TASK    $CSTR
410 MC                   movel     w2task        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         trans#
     C     ptkey         chain(n)  pirtran                            79
     C                   if        *in79
     C                   eval      error = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = descsp(2)
500bAC                   other
     C                   eval      errmsg = desc(2)
500bAC                   endsl
     C                   exsr      zm1001
     C                   goto      endck2
     C                   endif
     *
     *  Make sure transaction was not started by other employee.
     *
     C                   if        not *in79  and
     C                             ptstat = '2'
     C                   eval      error = *on
     C     ptemp#        chain     piruser1                           77
     C                   eval      errmsg = *blanks
     C                   movel     usfnam        errmsg
     C                   exsr      zm1201
     C                   goto      endck2
     C                   endif
     *
     *  Make sure transaction is not already ended.
     *
     C                   if        not *in79  and
     C                             ptstat = '3'
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1206
     C                   goto      endck2
     C                   endif
     *
     *  Make sure transaction is not already closed.
     *
     C                   if        not *in79  and
     C                             ptstat = '4'
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1202
     C                   goto      endck2
     C                   endif
     *
     *  Make sure transaction is not interrupted.
     *
     C                   if        not *in79  and
     C                             ptstat = '8'
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1207
     C                   goto      endck2
     C                   endif
     *
     *  Make sure transaction is not cancelled.
     *
     C                   if        not *in79  and
     C                             ptstat = '9'
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1208
     C                   goto      endck2
     C                   endif
410 A*
410 AC                   if        not *in79
413 MC                   eval      t#task = pttask
410 AC                   endif
410 A*
     C                   endif
410 AC                   eval      scntsk = *blanks
410 AC                   eval      scntyp = *blanks
410 AC     tkkey         chain     task                               79
410 AC                   if        not *in79
410 AC                   eval      scntsk = tkcode
410 AC                   eval      scntyp = tktype
410 AC                   endif
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     C                   eval      tskflg = *off
     C                   eval      *in81 = *off
     C     digit         check     w3task                                 81
     *
     *  *IN81 = *ON - Found character other than that contained
     *           in the field DIGIT.
     *
     C                   if        *in81
     C                   eval      tskflg = *on
     C                   endif
     *
     C                   if        tskflg = *on
     *
     *  Verify Task code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   movel     w3task        $ltask
     C                   call      'TK900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Cannot create a standard task.
     *
     C                   movel     w3task        t#task
     C     tkkey         chain     task                               79
     C                   if        not *in79  and
     C                             tktype = 'D'
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   movel     w3task        ertask
     C                   exsr      zm1205
     C                   endif
     *
     C                   else
     *  Verify transaction number
     C                   eval      trans# = 0
410 AC                   eval      $cstr = *blanks
410 D**                   MOVE W3TASK    $CSTR
410 MC                   movel     w3task        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         trans#
     C     ptkey         chain(n)  pirtran                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = descsp(2)
500bAC                   other
     C                   eval      errmsg = desc(2)
500bAC                   endsl
     C                   exsr      zm1001
     C                   endif
     *
     *  Make sure transaction was not started by other employee.
     *
     C                   if        not *in79  and
     C                             ptstat = '2'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C     ptemp#        chain     piruser1                           77
     C                   eval      errmsg = *blanks
     C                   movel     usfnam        errmsg
     C                   exsr      zm1201
     C                   endif
     *
     *  Make sure transaction is not already ended.
     *
     C                   if        not *in79  and
     C                             ptstat = '3'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1206
     C                   endif
     *
     *  Make sure transaction is not already closed.
     *
     C                   if        not *in79  and
     C                             ptstat = '4'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1202
     C                   endif
     *
     *  Make sure transaction is not interrupted.
     *
     C                   if        not *in79  and
     C                             ptstat = '8'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1207
     C                   endif
     *
     *  Make sure transaction is not cancelled.
     *
     C                   if        not *in79  and
     C                             ptstat = '9'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1208
     C                   endif
     C                   endif
     *
     *     Verify start date
     *
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w3sdte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $cverm        errmsg
     C                   exsr      zm07
     C                   else
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      w3sdte = $cvd6o
     C                   endif
     C                   endif
     *
     *     Verify start time.
     *
     *   Hour must be <or= 12.
     C                   if        w3shrs > 12
     C                   eval      error = *on
     C                   eval      *in03 = *on
     C                   eval      *in23 = *on
     C                   exsr      zm1203
     C                   endif
     *   Minute must be <or= 59.
     C                   if        w3smin > 59
     C                   eval      error = *on
     C                   eval      *in04 = *on
     C                   eval      *in24 = *on
     C                   exsr      zm1204
     C                   endif
     *   Invalid value entered for AM/PM.
     C                   if        w3sap <> 'A'  and
     C                             w3sap <> 'P'
     C                   eval      error = *on
     C                   eval      *in05 = *on
     C                   eval      *in25 = *on
     C                   exsr      zm1216
     C                   endif
     *
     *     Verify end date
     *
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w3edte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   movel     $cverm        errmsg
     C                   exsr      zm07
     C                   else
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      w3edte = $cvd6o
     C                   endif
     C                   endif
     *
     *     Verify end time.
     *
     *   Hour must be <or= 12.
     C                   if        w3ehrs > 12
     C                   eval      error = *on
     C                   eval      *in07 = *on
     C                   eval      *in27 = *on
     C                   exsr      zm1203
     C                   endif
     *   Minute must be <or= 59.
     C                   if        w3emin > 59
     C                   eval      error = *on
     C                   eval      *in08 = *on
     C                   eval      *in28 = *on
     C                   exsr      zm1204
     C                   endif
     *   Invalid value entered for AM/PM.
     C                   if        w3eap <> 'A'  and
     C                             w3eap <> 'P'
     C                   eval      error = *on
     C                   eval      *in09 = *on
     C                   eval      *in29 = *on
     C                   exsr      zm1216
     C                   endif
     *   Current date
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdte = $cvd8o
     *   Start date
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w3sdte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        strdte
     *   End date
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w3edte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        enddte
     *   Current time
     C                   time                    curtim
     *   Start time
     *
     *     Convert start time to military format.
     *
     C                   eval      hrs = w3shrs
     C                   eval      min = w3smin
     C                   eval      ap = w3sap
     C                   exsr      zzapmi
     C                   eval      strtim = miltim
     *   End time
     *
     *     Convert end time to military format.
     *
     C                   eval      hrs = w3ehrs
     C                   eval      min = w3emin
     C                   eval      ap = w3eap
     C                   exsr      zzapmi
     C                   eval      fintim = miltim
     *
     *   Start date cannot be > end date.
     *
     C                   if        strdte > enddte
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      strdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      enddte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = strtim
     C                   eval      zzetim = fintim
     C                   exsr      zztidy
     *
     C                   exsr      zm1209
     C                   endif
     *
     *   End date cannot be > current date.
     *
     C                   if        enddte > curdte
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      strdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      enddte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = strtim
     C                   eval      zzetim = fintim
     C                   exsr      zztidy
     *
     C                   exsr      zm1213
     C                   endif
     *
     *   End time cannot be > current time, if end date = current date
     *
     C                   if        enddte = curdte  and
     C                             fintim > curtim
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in28 = *on
     C                   eval      *in29 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      strdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      enddte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = strtim
     C                   eval      zzetim = fintim
     C                   exsr      zztidy
     *
     C                   exsr      zm1214
     C                   endif
     *
     *   Time lapse cannot be more than one day.
     *
     C                   if        enddte > strdte
     C     enddte        sub       strdte        diff
     C                   if        diff > 1
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      strdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      enddte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = strtim
     C                   eval      zzetim = fintim
     C                   exsr      zztidy
     *
     C                   exsr      zm1210
     C                   endif
     C                   endif
     *
     *   If the dates are different, then end time must be <= start
     *   time.
     *
     C                   if        enddte > strdte  and
     C                             fintim > strtim
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in28 = *on
     C                   eval      *in29 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      strdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      enddte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = strtim
     C                   eval      zzetim = fintim
     C                   exsr      zztidy
     *
     C                   exsr      zm1211
     C                   endif
     *
     *   If the dates are same, then end time must be > start time.
     *
     C                   if        enddte = strdte  and
     C                             fintim <= strtim
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in28 = *on
     C                   eval      *in29 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      strdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      enddte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = strtim
     C                   eval      zzetim = fintim
     C                   exsr      zztidy
     *
     C                   exsr      zm1212
     C                   endif
     *
     *   Find overlapping time.
     *
     C                   eval      stdate = strdte
     C                   eval      prvdte = stdate - 1
     C     ptkey2        setll     pirtran2
     C                   dow       forevr = forevr
     C                   read(n)   pirtran2                               79
     C                   if        *in79  or
     C                             ptsdte < prvdte
     C                   leave
     C                   endif
     *
     *   Overlapping time. (Same start and end date PTSDTE = PTEDTE)
     *
     C                   select
     C                   when      strdte = ptsdte  and
     C                             enddte = ptedte  and
     C                             ptsdte = ptedte  and
     C                             enddte = strdte
     *   Start and end time in-between existing time span of manual
     *   task.
     *                   Start     Start       End      End
     *            Task    date      time       time     date
     *Manual(SCN) BREAK 1/25/96  16:10:00   16:15:00  1/25/96  Error
     *Manual(PT)  BREAK 1/25/96  16:00:00   16:30:00  1/25/96
     *
     C                   if        not *in79  and
     C                             strtim >= ptstim  and
     C                             fintim <= ptetim  and
     C                             ptetyp = 'M'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in24 = *on
     C                   eval      *in25 = *on
     C                   eval      *in27 = *on
     C                   eval      *in28 = *on
     C                   eval      *in29 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertask = pttask
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = ptstim
     C                   eval      zzetim = ptetim
     C                   exsr      zztidy
     *
     C                   exsr      zm1218
     C                   goto      endck3
     C                   endif
     *   End time in-between time span of any existing task.
     *                   Start     Start       End      End
     *            Task    date      time       time     date
     *Manual(SCN) BREAK 1/25/96  14:30:00   15:10:00  1/25/96  Error
     *Manual(PT)  BREAK 1/25/96  15:00:00   15:30:00  1/25/96
     *
     C                   if        not *in79  and
     C                             strtim <= ptstim  and
     C                             fintim >= ptstim  and
     C                             fintim <= ptetim
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in24 = *on
     C                   eval      *in25 = *on
     C                   eval      *in27 = *on
     C                   eval      *in28 = *on
     C                   eval      *in29 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertask = pttask
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = ptstim
     C                   eval      zzetim = ptetim
     C                   exsr      zztidy
     C                   exsr      zm1217
     C                   endif
     *   Start time in-between time span of any existing task.
     *                   Start     Start       End      End
     *            Task    date      time       time     date
     *Manual(SCN) BREAK 1/25/96  15:10:00   15:40:00  1/25/96  Error
     *Manual(PT)  BREAK 1/25/96  15:00:00   15:30:00  1/25/96
     *
     C                   if        not *in79  and
     C                             strtim >= ptstim  and
     C                             strtim <= ptetim  and
     C                             fintim >= ptetim
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in24 = *on
     C                   eval      *in25 = *on
     C                   eval      *in27 = *on
     C                   eval      *in28 = *on
     C                   eval      *in29 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertask = pttask
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = ptstim
     C                   eval      zzetim = ptetim
     C                   exsr      zztidy
     C                   exsr      zm1217
     C                   endif
     *
     *   Overlapping time. (DIFF start and end date PTEDTE > PTSDTE)
     *
     C                   when      strdte = ptsdte  and
     C                             enddte = ptedte  and
     C                             ptedte > ptsdte  and
     C                             enddte > strdte
     *
     *   Start and end time in-between existing time span of manual
     *   task.
     *                   Start     Start       End      End
     *            Task    date      time       time     date
     *Manual(SCN) BREAK 1/25/96  23:30:00   00:30:00  1/26/96  Error
     *Manual(PT)  BREAK 1/25/96  23:00:00    2:30:00  1/26/96
     *
     C                   if        not *in79  and
     C                             strtim >= ptstim  and
     C                             fintim <= ptetim  and
     C                             ptetyp = 'M'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in24 = *on
     C                   eval      *in25 = *on
     C                   eval      *in27 = *on
     C                   eval      *in28 = *on
     C                   eval      *in29 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertask = pttask
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = ptstim
     C                   eval      zzetim = ptetim
     C                   exsr      zztidy
     *
     C                   exsr      zm1218
     C                   goto      endck3
     C                   endif
     *
     *   End time in-between time span of any existing task.
     *                   Start     Start       End      End
     *            Task    date      time       time     date
     *Manual(SCN) BREAK 1/25/96  23:00:00    1:00:00  1/26/96  Error
     *Manual(PT)  BREAK 1/25/96  23:30:00    2:30:00  1/26/96
     *
     C                   if        not *in79  and
     C                             strtim <= ptstim  and
     C                             fintim <= ptetim
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in24 = *on
     C                   eval      *in25 = *on
     C                   eval      *in27 = *on
     C                   eval      *in28 = *on
     C                   eval      *in29 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertask = pttask
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = ptstim
     C                   eval      zzetim = ptetim
     C                   exsr      zztidy
     C                   exsr      zm1217
     C                   endif
     *
     *   Start time in-between time span of any existing task.
     *                   Start     Start       End      End
     *            Task    date      time       time     date
     *Manual(SCN) BREAK 1/25/96  23:45:00    3:00:00  1/26/96  Error
     *Manual(PT)  BREAK 1/25/96  23:30:00    2:30:00  1/26/96
     *
     C                   if        not *in79  and
     C                             strtim >= ptetim  and
     C                             fintim >= ptetim
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in24 = *on
     C                   eval      *in25 = *on
     C                   eval      *in27 = *on
     C                   eval      *in28 = *on
     C                   eval      *in29 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertask = pttask
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = ptstim
     C                   eval      zzetim = ptetim
     C                   exsr      zztidy
     C                   exsr      zm1217
     C                   endif
     *
     *   Overlapping time. (SAME start date DIFF END DATE)
     *
     C                   when      strdte = ptsdte  and
     C                             strdte = enddte  and
     C                             enddte < ptedte  and
     C                             ptedte > ptsdte
     *
     *   Start and end time in-between existing time span of manual
     *   task.
     *                   Start     Start       End      End
     *            Task    date      time       time     date
     *Manual(SCN) BREAK 1/25/96  16:00:00   16:20:00  1/25/96  Error
     *Manual(PT)  BREAK 1/25/96  14:50:00    9:30:00  1/26/96
     *
     C                   if        not *in79  and
     C                             strtim >= ptstim  and
     C                             ptetyp = 'M'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in24 = *on
     C                   eval      *in25 = *on
     C                   eval      *in27 = *on
     C                   eval      *in28 = *on
     C                   eval      *in29 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertask = pttask
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = ptstim
     C                   eval      zzetim = ptetim
     C                   exsr      zztidy
     *
     C                   exsr      zm1218
     C                   goto      endck3
     C                   endif
     *
     *   End time in-between time span of any existing task.
     *                   Start     Start       End      End
     *            Task    date      time       time     date
     *Manual(SCN) BREAK 1/25/96  13:00:00   15:40:00  1/25/96  Error
     *Manual(PT)  BREAK 1/25/96  14:50:00    9:30:00  1/26/96
     *
     C                   if        not *in79  and
     C                             strtim <= ptstim  and
     C                             fintim >= ptstim
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in24 = *on
     C                   eval      *in25 = *on
     C                   eval      *in27 = *on
     C                   eval      *in28 = *on
     C                   eval      *in29 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertask = pttask
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = ptstim
     C                   eval      zzetim = ptetim
     C                   exsr      zztidy
     C                   exsr      zm1217
     C                   endif
     *
     *   Overlapping time. (DIFF start date SAME END DATE)
     *
     C                   when      strdte = enddte  and
     C                             strdte > ptsdte  and
     C                             enddte = ptedte  and
     C                             ptedte > ptsdte
     *
     *   Start and end time in-between existing time span of manual
     *   task.
     *                   Start     Start       End      End
     *            Task    date      time       time     date
     *Manual(SCN) BREAK 1/26/96   6:00:00    6:30:00  1/26/96  Error
     *Manual(PT)  BREAK 1/25/96  14:50:00    9:30:00  1/26/96
     *
     C                   if        not *in79  and
     C                             strtim <= ptetim  and
     C                             fintim <= ptetim  and
     C                             ptetyp = 'M'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in24 = *on
     C                   eval      *in25 = *on
     C                   eval      *in27 = *on
     C                   eval      *in28 = *on
     C                   eval      *in29 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertask = pttask
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = ptstim
     C                   eval      zzetim = ptetim
     C                   exsr      zztidy
     *
     C                   exsr      zm1218
     C                   goto      endck3
     C                   endif
     *
     *   Start time in-between time span of any existing task.
     *                   Start     Start       End      End
     *            Task    date      time       time     date
     *Manual(SCN) BREAK 1/26/96   9:00:00   10:00:00  1/26/96  Error
     *Manual(PT)  BREAK 1/25/96  14:50:00    9:30:00  1/26/96
     *
     C                   if        not *in79  and
     C                             strtim <= ptetim  and
     C                             fintim >= ptetim
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in24 = *on
     C                   eval      *in25 = *on
     C                   eval      *in27 = *on
     C                   eval      *in28 = *on
     C                   eval      *in29 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertask = pttask
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzsmdy = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzemdy = $cvd6o
     C                   eval      zzstim = ptstim
     C                   eval      zzetim = ptetim
     C                   exsr      zztidy
     C                   exsr      zm1217
     C                   endif
     C                   endsl
     *
     C                   enddo
     C     endck3        endsr
     *----------------------------------------------------------------
520aA*
520aA*  ZZCKMT   Check if open multiple transactions exist
520aA*
520aAC     zzckmt        begsr
     *
     *  Display error if open multiple trans exists for employee.
     *
     C                   eval      mulflg = *off
     C                   eval      kystat = *on
     C     mtkey         setll     multran
     C     mtkey         reade(n)  multran                                78
     C                   if        not *in78
     C                   eval      mulflg = *on
     C                   endif
     C     endcmt        endsr
     *----------------------------------------------------------------
     *
     *  ZZCKU1   Check for overlapping auto task and update
     *           it by adjusting the time.
     *
     C     zzcku1        begsr
     C                   eval      prvdte = stdate - 1
     C                   eval      strtim = zzstim
     C                   eval      fintim = zzetim
     C     ptkey2        setll     pirtran2
     C                   dow       forevr = forevr
     C                   read      pirtran2                               79
     C                   if        *in79  or
     C                             ptsdte < prvdte
     C                   leave
     C                   endif
     *
     *   Overlapping time. (Same start date/diff end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (PT) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(ZZ) BREAK 1/25/96  16:00:00   16:30:00  1/25/96   (30)
     *
     C                   if        not *in79  and
     C                             zzsdte = ptsdte  and
     C                             zzedte < ptedte  and
     C                             zzstim >= ptstim  and
     C                             ptetyp = 'N'
     C                   exsr      zztime
     C                   if        ptdmin > 0
     C                   eval      ptdmin = ptdmin - timlen
     C                   else
     C                   eval      ptimin = ptimin - timlen
     C                   endif
     C                   update    ptrec2
640bAc                   exsr      zzwrttrand
     C                   leave
     C                   endif
     *
     *   Overlapping time. (Same start and end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (PT) CLEAN 1/25/96  10:00:23   11:30:35  1/25/96
     *Manual(ZZ) BREAK 1/25/96  10:30:00   10:45:00  1/25/96   (15)
     *
     *Auto  (PT) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(ZZ) BREAK 1/25/96  23:30:00    1:30:00  1/26/96   (120)
     *
     C                   if        not *in79  and
     C                             zzsdte = ptsdte  and
     C                             zzedte = ptedte  and
     C                             zzstim >= ptstim  and
     C                             zzetim <= ptetim  and
     C                             ptetyp = 'N'
     C                   exsr      zztime
     C                   if        ptdmin > 0
     C                   eval      ptdmin = ptdmin - timlen
     C                   else
     C                   eval      ptimin = ptimin - timlen
     C                   endif
     C                   update    ptrec2
640bAc                   exsr      zzwrttrand
     C                   leave
     C                   endif
     *
     *   Overlapping time. (Diff start date/same end date)
     *                                  (Past midnight)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (PT) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(ZZ) BREAK 1/26/96   8:00:00    8:30:00  1/26/96   (30)
     *
     C                   if        not *in79  and
     C                             zzsdte > ptsdte  and
     C                             zzedte = ptedte  and
     C                             zzetim <= ptetim  and
     C                             ptetyp = 'N'
     C                   exsr      zztime
     C                   if        ptdmin > 0
     C                   eval      ptdmin = ptdmin - timlen
     C                   else
     C                   eval      ptimin = ptimin - timlen
     C                   endif
     C                   update    ptrec2
640bAc                   exsr      zzwrttrand
     C                   leave
     C                   endif
     C                   enddo
     C     endcu1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCKU2   Check for overlapping task and update the current
     *           task just ended, by adjusting the time.
     *
     C     zzcku2        begsr
     C                   eval      svtlen = 0
     C     ptkey2        setll     pirtran2
     C                   dow       forevr = forevr
417 D*R                   READ PIRTRAN2            N    79
417 MC     w1emp#        reade(n)  pirtran2                               79
     C                   if        *in79  or
     C                             ptsdte < zzsdte
     C                   leave
     C                   endif
     *   Skip the task that just ended.
     C                   if        not *in79  and
     C                             pttrn# = svtrn#
     C                   iter
     C                   endif
     *   Accumulate overlapping minutes.(Same start and end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  10:00:23   11:30:35  1/25/96
     *Manual(PT) BREAK 1/25/96  10:30:00   10:45:00  1/25/96   (15)
     *
     *   Auto    CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *   Manual  BREAK 1/25/96  23:30:00    1:30:00  1/26/96   (120)
     *
     C                   if        not *in79  and
     C                             ptsdte = zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptstim >= zzstim  and
     C                             ptetim <= zzetim
410 D*R         PTETYP    ANDEQ'M'
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptetim
     C                   exsr      zztime
     C                   add       timlen        svtlen
     C                   endif
     *   Accumulate overlapping minutes(Diff start date/same end date)
     *                                  (Past midnight)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/26/96   8:00:00    8:30:00  1/26/96   (30)
     *
     C                   if        not *in79  and
     C                             ptsdte > zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptetim <= zzetim
410 D*R         PTETYP    ANDEQ'M'
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptetim
     C                   exsr      zztime
     C                   add       timlen        svtlen
     C                   endif
     *   Accumulate overlapping minutes.(Same start date/diff end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/25/96  16:00:00   16:30:00  1/25/96   (30)
     *
     C                   if        not *in79  and
     C                             ptsdte = zzsdte  and
     C                             ptedte < zzedte  and
     C                             ptstim >= zzstim
410 D*R         PTETYP    ANDEQ'M'
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptetim
     C                   exsr      zztime
     C                   add       timlen        svtlen
     C                   endif
     C                   enddo
     *
     *   Update the task that just ended.
     *
     C     svtrn#        chain     pirtran                            79
     C                   if        not *in79
     C                   if        ptdmin > 0
     C                   eval      ptdmin = ptdmin - svtlen
     C                   else
     C                   eval      ptimin = ptimin - svtlen
     C                   endif
     C                   update    ptrec
640bAc                   exsr      zzwrttrand
     C                   endif
     C     endcu2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   endif
     *
     *  Test for F6 - Enter other tasks
     *
413 D**         *INKF     IFEQ *ON
413 D**                   MOVE *ON       CMDTKN
413 D**                   EXSR SCR03I
413 D**                   ENDIF
     *
     *  F10 - End current task
     *
     C                   if        *inkj
640aA*
640aA*  If trans entered and F10 pressed, check for stat=8 and give warning
640aAC                   if        w2task <> *blanks
640aAC                   eval      trnint = *off
640aA*
640aAC                   eval      trans# = 0
640aAC                   eval      $cstr = *blanks
640aAC                   movel     w2task        $cstr
640aAC                   call      'ADJUST'
640aAC                   parm      '*RIGHT  '    $ccmd             8
640aAC                   parm                    $cstr            30
640aAC                   move      $cstr         trans#
640aAC     ptkey         chain(n)  pirtran                            79
640aAC                   if        *in79
640aAC                             or ptstat <> '8'
640aAC                   eval      error = *on
640aAC                   eval      errmsg = desc(2)
640aAC                   exsr      zm1001
640aAC                   goto      endcm2
640aAC                   endif
640aA*
640aA*  Status is 8, give warning
640aAC                   eval      trnint = *on
640aAC                   eval      error = *on
640aAC                   eval      errmsg = emsg(1)
640aAC                   exsr      zm9999
640aAC                   goto      endcm2
640aA*
640aAC                   endif
640aAC                   endif
640aA*
640aAC                   if        *inkj
520 AC     curtrn        chain     multran1                           79
520 AC                   if        not *in79
520 AC                   eval      error = *on
520 AC                   eval      errmsg = *blanks
520 AC                   exsr      zm1221
520 AC                   goto      endcm2
520 AC                   endif
     C                   eval      cmdtkn = *on
413aAC                   exsr      zztask
410 AC                   if        curtsk <> 'IDLE  '
410 AC                   exsr      zzend
416aAC                   exsr      zztask
416aAC                   if        curent = *off
416aAC                   eval      tskflg = *on
416dMC                   movel     'IDLE  '      w2task
416dD***                  MOVE 'IDLE  '  W2TASK
416aAC                   exsr      zzstrt
416aAC                   eval      tskflg = *off
416aAC                   endif
410 AC                   endif
416bMC                   exsr      scr01i
416bD**                   EXSR SCR02I
410 AC                   goto      endcm2
     *
410 D*R         PTKEY1    CHAINPIRTRAN1             79
410 D*R         *IN79     IFEQ *OFF
410 D**                   MOVE '3'       PTSTAT
410 D*R         TKSTD     IFEQ 'Y'
410 D*R                   MOVE '3'       PTSTAT
410 D*R                   ELSE
410 D*R                   MOVE '4'       PTSTAT
410 D*R                   ENDIF
410 D*R                   MOVE 'N'       PTETYP
410 D*R                   MOVE '*CURCMD '$CVCMD
410 D*R                   CALL @CVTDT
410 D*R                   PARM           $CVTDT
410 D*R                   Z-ADD$CVD8O    PTEDTE
410 D*R                   TIME           PTETIM
410 D*R                   Z-ADDPTSTIM    STRTIM
410 D*R                   Z-ADDPTETIM    FINTIM
410 D*R                   EXSR ZZTIME
410 D*R         TKTYPE    IFEQ 'D'
410 D*R                   Z-ADDTIMLEN    PTDMIN
410 D*R                   ELSE
410 D*R                   Z-ADDTIMLEN    PTIMIN
410 D*R                   ENDIF
410 D*R                   UPDATPTREC1                 79
410 D*R         *IN79     IFEQ '1'
410 D*R                   MOVE '1'       ERROR
410 D*R                   EXSR ZM72
410 D*R                   GOTO ENDCM2
410 D*R                   ENDIF
410 D*R                   ENDIF
410 D*
410 D*            - End current task
410 D*            - Update TASKDET file.
410 D*            - Decrease active and increase finished.
410 D*
410 D*R                   MOVELW2CTSK    T#TASK
410 D*R         TDKEY     CHAINTASKDET              79
410 D*R         *IN79     IFEQ *OFF
410 D*R         TDACTC    SUB  PTCUBE    TDACTC
410 D*R         TDACTW    SUB  PTSWGT    TDACTW
410 D*R         TDACTP    SUB  PTPCS     TDACTP
410 D*R         TDACT1    SUB  PTQTY1    TDACT1
410 D*R         TDACT2    SUB  PTQTY2    TDACT2
410 D*R         TDACT3    SUB  PTQTY3    TDACT3
410 D*R                   SUB  1         TDACTJ
410 D*R         TDFINC    ADD  PTCUBE    TDFINC
410 D*R         TDFINW    ADD  PTSWGT    TDFINW
410 D*R         TDFINP    ADD  PTPCS     TDFINP
410 D*R         TDFIN1    ADD  PTQTY1    TDFIN1
410 D*R         TDFIN2    ADD  PTQTY2    TDFIN2
410 D*R         TDFIN3    ADD  PTQTY3    TDFIN3
410 D*R                   ADD  1         TDFINJ
410 D*R                   UPDATTDREC                  79
410 D*R         *IN79     IFEQ '1'
410 D*R                   MOVE '1'       ERROR
410 D*R                   EXSR ZM72
410 D*R                   GOTO ENDCM2
410 D*R                   ENDIF
410 D*R                   ENDIF
410 D*
410 D*        There is a posibility that a manual task might have
410 D*        been added before the current task was ended. Hence
410 D*        adjust the current task just ended, if there is
410 D*        any overlapping manual task.
410 D*
410 D*R                   Z-ADDPTTRN#    SVTRN#
410 D*  Past overnight. (PTEDTE > PTSDTE)
410 D*R         PTEDTE    IFGT PTSDTE
410 D*R                   Z-ADDPTEDTE    STDATE
410 D*R                   ELSE
410 D*R                   Z-ADDPTSDTE    STDATE
410 D*R                   ENDIF
410 D*R                   Z-ADDPTSDTE    ZZSDTE
410 D*R                   Z-ADDPTEDTE    ZZEDTE
410 D*R                   Z-ADDPTSTIM    ZZSTIM
410 D*R                   Z-ADDPTETIM    ZZETIM
410 D*R                   EXSR ZZCKU2
410 D*R                   EXSR SCR02I
     C                   endif
     *
409 A*
409 A*      F20 - Accept Warning.
409 A*
409 AC                   if        *inku
409 AC                   eval      ovrrid = *on
409 AC                   endif
640aA*
640aAC                   if        *inku
640aAC                             and trnint
640aAC                   eval      curtrn = trans#
730aAc*** if you alter the curtrn field you also need to update the
730aAC*** curtyp and curtsk fields so they belong to this tran#
730aA /free
730aA   chain (pttask) task;
730aA   if %found(task);
730aA     curtsk = tkcode;
730aA     curtyp = tktype;
730aA   endif;
730aA /end-free
640aAC                   exsr      zzend
640aA*
640aAC                   eval      cmdtkn = *on
640aAC                   exsr      scr01i
640aAC                   goto      endcm2
640aAC                   endif
640aA*
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   endif
     *
     *  Test for F9 - Manual transaction maintenance
     *
     C                   if        *inki
     C                   eval      cmdtkn = *on
     *   Current date
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdte = $cvd8o
     *   Current time
     C                   time                    curtim
     *
     *   If Current time > 120000
     *              Start date = Current date
     *                End date = Current date
     *              Start time = Current time - 120000
     *
     C                   if        curtim > 120000
     C                   move      curdte        $pfmdt
     C                   move      curdte        $ptodt
     C                   eval      strtim = curtim - 120000
     C                   move      strtim        $pstim
     C                   endif
     *
     *   If Current time < 120000
     *              Start date = Current date - 1
     *                End date = Current date
     *              Start time = Current time + 120000
     *
     C                   if        curtim < 120000
     C                   eval      strdte = curdte - 1
     C                   move      strdte        $pfmdt
     C                   move      curdte        $ptodt
     C     curtim        add       120000        strtim
     C                   move      strtim        $pstim
     C                   endif
     *
     C                   move      w1emp#        $pemp#
     C                   call      'TE120CL'
     C                   parm                    $pemp#
     C                   parm                    $pfmdt            8
     C                   parm                    $ptodt            8
     C                   parm                    $pstim            6
     C                   parm      *blanks       $prtn             8
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1emp# = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   eval      w2task = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT3   Get default values for add.
     *
     C     zzdft3        begsr
     C                   eval      w3task = *blanks
     C                   endsr
410 A*----------------------------------------------------------------
410 A*
410 A*  ZZEND    End task.
410 A*
410 AC     zzend         begsr
410 A*  No current task to end.
410 AC     curtrn        cabeq     0             endend
410 A*  End current task
410 AC                   eval      trans# = curtrn
410 AC     ptkey         chain     pirtran                            79
410 AC                   if        not *in79
410 AC                   if        curtyp = 'D'  and
410 AC                             curtsk <> 'IDLE  '  and
413bAC                             curtsk <> 'BEGDAY'  and
413bAC                             curtsk <> 'ENDDAY'
410 AC                   eval      ptstat = '3'
410 AC                   else
410 AC                   eval      ptstat = '4'
410 AC                   endif
410 AC                   eval      ptetyp = 'N'
410 AC                   eval      $cvcmd = '*CURCMD '
410 AC                   call      @cvtdt
410 AC                   parm                    $cvtdt
410 AC                   eval      ptedte = $cvd8o
410 AC                   time                    ptetim
730bAc                   if        *inku
730bAc                             and trnint
730bAc                   eval      ptsdte = ptedte
730bAc                   eval      ptstim = ptetim
730bac                   eval      ptemp# = 0
730bAc                   endif
410 AC                   eval      strtim = ptstim
410 AC                   eval      fintim = ptetim
410 AC                   exsr      zztime
410 AC                   if        curtyp = 'D'
410 D*R         TKTYPE    IFEQ 'D'
410 AC                   eval      ptdmin = timlen
410 AC                   else
410 AC                   eval      ptimin = timlen
410 AC                   endif
410 AC                   update    ptrec                                79
410 AC                   if        *in79
410 AC                   eval      error = *on
410 AC                   exsr      zm72
410 AC                   goto      endend
410 AC                   endif
640bAc                   exsr      zzwrttrand
410 AC                   endif
410 A*
410 A*            - End current task
410 A*            - Update TASKDET file.
410 A*            - Decrease active and increase finished.
410 A*
410 AC                   eval      t#task = w2ctsk
520cAC                   eval      wkwhdp=ptwhdp
520cA*            - Check for selection task
520cAC*  Check for selection records
520cAC                   IF        ptcat='SELECT'
520cAC                   eval      wdp = ptwhdp
520cAC                   eval      whs = ptwhse
520cAC     opkey         chain     optione
520cAC                   if        not %found(optione)
520cAC                   eval      wdp = *blanks
520cAC                   eval      whs = 0
520cAC     opkey         chain     optione
520cAC                   if        not %found(optione)
520cAC                   eval      opzord = ' '
520cAC                   endif
520cAC                   endif
520cAC                   IF        opzord= 'Z'
520cAC     lbkey         CHAIN     LABEL90                            76
520cAC                   if        not *in76
520cAC                   if        lbucod<>'TO'
520cAC     lblbl#        CHAIN     WORKLBL                            77
520cAC                   if        not *in77
520cAC                   movel     LWSZON        WKWHDP
520cAC                   endif
520cAC                   endif
520cAC                   endif
520cAC                   endif
520cAC                   endif
410 AC     tdkey         chain     taskdet                            79
410 AC                   if        not *in79
520dA*  decrease active cube
520dAC                   if        ptcube <= tdactc
410 AC     tdactc        sub       ptcube        tdactc
520dAC                   else
520dAC                   eval      tdactc = 0
520dAC                   endif
520dA*  decrease shipping weight
520dAC                   if        ptswgt <= tdactw
410 AC     tdactw        sub       ptswgt        tdactw
520dAC                   else
520dAC                   eval      tdactw = 0
520dAC                   endif
520dA*  decrease active pieces
520dAC                   if        ptpcs <= tdactp
410 AC                   eval      tdactp = tdactp - ptpcs
520dAC                   else
520dAC                   eval      tdactp = 0
520dAC                   endif
520dA*  decrease active qty1
520dAC                   if        ptqty1 <= tdact1
410 AC                   eval      tdact1 = tdact1 - ptqty1
520dAC                   else
520dAC                   eval      tdact1 = 0
520dAC                   endif
520dA*  decrease active qty2
520dAC                   if        ptqty2 <= tdact2
410 AC                   eval      tdact2 = tdact2 - ptqty2
520dAC                   else
520dAC                   eval      tdact2 = 0
520dAC                   endif
520dA*  decrease active qty3
520dAC                   if        ptqty3 <= tdact3
410 AC                   eval      tdact3 = tdact3 - ptqty3
520dAC                   else
520dAC                   eval      tdact3 = 0
520dAC                   endif
520dA*  decrease active qty3
520dAC                   if        tdactj >= 1
410 AC                   eval      tdactj = tdactj - 1
520dAC                   else
520dAC                   eval      tdactj = 0
520dAC                   endif
410 AC     tdfinc        add       ptcube        tdfinc
520bAC                   eval      wfinw = 0
520bAC     tdfinw        add       ptswgt        wfinw
520bAC     wfinw         ifle      99999
410 AC     tdfinw        add       ptswgt        tdfinw
520bAC                   endif
410 AC     tdfinp        add       ptpcs         tdfinp
410 AC     tdfin1        add       ptqty1        tdfin1
410 AC     tdfin2        add       ptqty2        tdfin2
410 AC     tdfin3        add       ptqty3        tdfin3
410 AC                   add       1             tdfinj
410 AC                   update    tdrec                                79
410 AC                   if        *in79
410 AC                   eval      error = *on
410 AC                   exsr      zm72
410 AC                   goto      endend
410 AC                   endif
410 AC                   endif
     *
410 AC                   if        curtyp = 'D'
     *
     *        There is a posibility that a manual task might have
     *        been added before the current task was ended. Hence
     *        adjust the current task just ended, if there is
     *        any overlapping manual task.
     *
410 AC                   eval      svtrn# = pttrn#
     *  Past overnight. (PTEDTE > PTSDTE)
410 AC                   if        ptedte > ptsdte
410 AC                   eval      stdate = ptedte
410 AC                   else
410 AC                   eval      stdate = ptsdte
410 AC                   endif
410 AC                   eval      zzsdte = ptsdte
410 AC                   eval      zzedte = ptedte
410 AC                   eval      zzstim = ptstim
410 AC                   eval      zzetim = ptetim
410 AC                   exsr      zzcku2
410 AC                   endif
     *
PFCaAc                   if        logapt
PFCaAc*    Send APT INDIRECT Transaction.
PFCaAc                   eval      apcmd = APTSK2
PFCaAc                   eval      aptrn# = CURTRN
PFCaAc                   eval      aploc = CURTSK
PFCaAc                   exsr      zzapt
PFCaAc                   endif

410 AC     endend        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1whdp = *blanks
     C                   eval      w1emp# = 0
413X C                   eval      w1styp = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   eval      w2task = *blanks
     *
     *  Get employee information.
     *
     C     w1emp#        chain     piruser1                           79
     C                   if        not *in79
     C                   eval      $cmd = '*LFM    '
     C                   eval      $name = *blanks
     C                   call      'FRMTNM'
     C                   parm                    $cmd
     C                   parm                    usfnam
     C                   parm                    usinit
     C                   parm                    uslnam
     C                   parm                    $name
     C                   eval      w2name = $name
     C                   else
     C                   eval      usemp# = 0
     C                   eval      w2name = *blanks
     C                   endif
     *
     *  Get current task.
     *
410 D*R                   MOVE *BLANKS   W2CTSK
410 D*R                   MOVE '2'       STAT
410 D*R         PTKEY1    CHAINPIRTRAN1            N79
410 D*R         *IN79     IFEQ *OFF
410 D*R                   MOVELPTTASK    W2CTSK
410 D*R                   MOVE '*CMDMDY '$CVCMD
410 D*R                   MOVE PTSDTE    $CVD8I
410 D*R                   CALL @CVTDT
410 D*R                   PARM           $CVTDT
410 D*R                   Z-ADD$CVD6O    W2DATE
410 D*R                   Z-ADDPTSTIM    W2TIME
410 D*R                   ELSE
410 D*R                   MOVEL'None'    W2CTSK
410 D*R                   Z-ADD0         W2DATE
410 D*R                   Z-ADD0         W2TIME
410 D*R                   ENDIF
     *   Get current task.
410 AC                   eval      curtrn = 0
410 AC                   eval      curtsk = *blanks
410 AC                   eval      curtyp = *blanks
410 AC                   eval      curent = *off
410 AC                   exsr      zztask
     *
413bD****       CURENT    IFEQ *OFF
413bD****       SCNTSK    ANDNE'ENDDAY'
413bD****                 MOVEL'IDLE  '  W2TASK
413bD****                 MOVE *ON       TSKFLG
413bD****                 EXSR ZZSTRT
413bD****                 EXSR ZZTASK
413bD****                 MOVE *BLANKS   W2TASK
413bD****                 ENDIF
     *   After ending the day, if somebody tries to go in...
416 AC                   if        curent = *off
416 D***        SCNTSK    IFEQ 'ENDDAY'
410 AC                   movel     'None'        w2ctsk
410 AC                   eval      w2date = 0
410 AC                   eval      w2time = 0
410 AC                   endif
     *
     *  Get current task description.
     *
413 MC                   eval      t#task = w2ctsk
     C     tkkey         chain     task                               79
     C                   if        not *in79
     C                   eval      w2desc = tkdesc
     C                   else
     C                   eval      w2desc = *blanks
     C                   endif
610a C                   movel     w2desc        w2des1
610a C                   move      w2desc        w2des2
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     *  Get employee information.
     *
     C     w1emp#        chain     piruser1                           79
     C                   if        not *in79
     C                   eval      $cmd = '*LFM    '
     C                   eval      $name = *blanks
     C                   call      'FRMTNM'
     C                   parm                    $cmd
     C                   parm                    usfnam
     C                   parm                    usinit
     C                   parm                    uslnam
     C                   parm                    $name
     C                   eval      w3name = $name
     C                   else
     C                   eval      usemp# = 0
     C                   eval      w3name = *blanks
     C                   endif
     *
     *  Get last manual transaction entered
     *
     C                   eval      forevr = *off
     C                   move      *hival        stdate
     C     ptkey2        setll     pirtran2
     C                   dow       forevr = forevr
     C                   read(n)   pirtran2                               79
     C                   if        *in79  or
     C                             ptemp# <> w1emp#
     C                   eval      w3mtsk = 'None  '
     C                   eval      w3desc = *blanks
     C                   eval      w3sldt = 0
     C                   eval      w3sltm = 0
     C                   eval      w3eldt = 0
     C                   eval      w3eltm = 0
     C                   leave
     C                   endif
     *
     C                   if        ptemp# = w1emp#  and
     C                             ptetyp = 'M'
413 MC                   eval      w3mtsk = pttask
     C     w3mtsk        chain     task                               77
     C                   eval      w3desc = *blanks
     C                   eval      w3desc = tkdesc
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w3sldt = $cvd6o
     C                   eval      w3sltm = ptstim
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w3eldt = $cvd6o
     C                   eval      w3eltm = ptetim
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     C                   eval      w3task = *blanks
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w3sdte = $cvd6o
     C                   eval      w3shrs = 0
     C                   eval      w3smin = 0
     C                   eval      w3sap = *blanks
     C                   eval      w3edte = $cvd6o
     C                   eval      w3ehrs = 0
     C                   eval      w3emin = 0
     C                   eval      w3eap = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get record(s) for screen 3.
     *
     C     zzget3        begsr
     C     endgt3        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for PIRTRAN file.
     *
     C     ptkey         klist
     C                   kfld                    trans#
     *
     *  Define key for PIRTRAN1 file.
     *
     C     ptkey1        klist
     C                   kfld                    w1emp#
     C                   kfld                    stat
     *
     *  Define partial key for PIRTRAN2 file.
     *
     C     ptkey2        klist
     C                   kfld                    w1emp#
     C                   kfld                    stdate
     *
     *  Define partial key for MULTRAN file.
     *
     C     mtkey         klist
     C                   kfld                    w1emp#
     C                   kfld                    kystat
410 A*
410 A*  Define partial key for PIRTRAN2 file.
410 A*
410 AC     ptke22        klist
410 AC                   kfld                    w1emp#
410 AC                   kfld                    stdate
410 AC                   kfld                    sttime
     *
     *  Define key for TASK file.
     *
     C     tkkey         klist
     C                   kfld                    t#task
     *
     *  Define key for TASKDET file.
     *
     C     tdkey         klist
     C                   kfld                    t#task
     C                   kfld                    ptwhse
520cDC*                  kfld                    ptwhdp
520cMC                   kfld                    wkwhdp
     C                   kfld                    ptstyp
     *
520cA*  Define key for TASKDET file.
520cA*
520cAC     keytd         klist
520cAC                   kfld                    pttask
520cAC                   kfld                    ptwhse
520cAC                   kfld                    wkwhdp            5
520cAC                   kfld                    ptstyp
     *
520cA*  Define key for LABEL file.
520cA*
520cAC     lbkey         klist
520cAC                   kfld                    ptwhse
520cAC                   kfld                    pttrn#
     *                    KFLD           USWHSE
     *                    KFLD           USWHDP
     *                    KFLD           USSTYP
     *
     *  Define key for PIRDEV file.
     *
     C     pdkey         klist
     C                   kfld                    #job
520cA*  Define full key for option file.
520cA*
520cAC     opkey         klist
520cAC                   kfld                    cod               8
520cAC                   kfld                    whs               3 0
520cAC                   kfld                    wdp               5
520cA*
520cAC                   movel     '*USER'       cod
     *
     C                   eval      zzsmdy = 0
     C                   eval      zzemdy = 0
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
PFCbA
PFCbA*  Define partial key for OPTIONS file.
PFCbAc     opkey2        klist
PFCbAc                   kfld                    kywhse            3 0
PFCbAc                   kfld                    kycode            8
PFCbA
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
610aA*
610aA*   Get screen size being used.
610aA*
610aAC                   call      'PIRRFSCR'
610aAC                   parm      '*GET'        #lcmd             8
610aAC                   parm                    #lline            2
610aAC                   parm                    #lcol             3
500bA*
500bA*   Get employee options.
500bA*
500bAC                   call      'GETUSER'
500bAC                   parm      #user         e$code           10
500bAC                   parm                    e$whse            3 0
500bAC                   parm                    e$emp#            5 0
500bAC                   parm                    e$fnam           15
500bAC                   parm                    e$init            1
500bAC                   parm                    e$lnam           20
500bAC                   parm                    e$whdp            5
500bAC                   parm                    e$styp            1
500bAC                   parm                    e$shft            6
500bAC                   parm                    e$crew            6
500bAC                   parm                    e$nhrs            3 1
500bAC                   parm                    e$rtn             8
500bAC                   parm                    e$bpu             1
500bAC                   parm                    e$lng             2
500bAC                   if        e$rtn <> '*OK'
500bAC                   eval      e$lng = 'EN'
500bAC                   endif
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     *
     C                   eval      w1whse = #whse
     *
PFCbA*   Check for APT logging option
PFCbAc                   eval      kywhse = w1whse
PFCbAc                   eval      kycode = '*APTFTP '
PFCbAc     opkey2        chain     options                            79
PFCbAc                   if        %found(options)
PFCbAc                             and %subst(opdata:1:1) = 'Y'
PFCbAc                   eval      logapt = *on
PFCbAc                   else
PFCbAc                   eval      logapt = *off
PFCbAc                   endif
     *
     *  Get warehouse number/dept/section from device file.
     *
    D*R         *LIKE     DEFN PDWHSE    WHSE
    D*R         *LIKE     DEFN PDWHDP    WHDP
    D*R         *LIKE     DEFN PDSTYP    STYP
    D*R         PDKEY     CHAINPIRDEV               79
    D*R         *IN79     IFEQ *OFF
    D*R                   Z-ADDPDWHSE    WHSE
    D*R                   MOVE PDWHDP    WHDP
    D*R                   MOVE PDSTYP    STYP
    D*R                   ELSE
    D*R                   Z-ADD0         WHSE
    D*R                   MOVE *BLANKS   WHDP
    D*R                   MOVE *BLANKS   STYP
    D*R                   ENDIF
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZMIAP  Convert military time to AM/PM format.
     *
     C     zzmiap        begsr
     C                   eval      dshms = miltim
     C                   if        dshh < 12
     C                   eval      ap = 'A'
     C                   else
     C                   if        dshh > 12
     C                   eval      dshh = dshh - 12
     C                   endif
     C                   eval      ap = 'P'
     C                   endif
     C                   eval      hrs = dshh
     C                   eval      min = dsmm
     C                   endsr
410 A*----------------------------------------------------------------
410 A*
410 A*  ZZSTRT  Start a new task.
410 A*
410 AC     zzstrt        begsr
     *
     *  Enter key -
     *
     *
413bA*            - Create 'BEGDAY' transaction record.
     *
413bAC                   if        scntsk = 'BEGDAY'
413bAC                   call      'PIRTRN#'
413bAC                   parm                    pttrn#
413bAC                   eval      ptstat = '4'
413bAC                   eval      pttask = scntsk
413bAC                   eval      t#task = scntsk
413bAC     tkkey         chain     task                               77
413bAC                   eval      ptcat = tkcat
413bAC                   eval      ptsub = tksub
413bAC                   eval      ptwhse = w1whse
413bAC                   eval      ptwhdp = w1whdp
413bAC                   eval      ptstyp = w1styp
413bAC                   eval      ptshft = usshft
413bAC                   eval      ptcrew = uscrew
413bAC                   eval      ptemp# = w1emp#
413bAC                   eval      ptcube = 0
413bAC                   eval      ptswgt = 0
413bAC                   eval      ptpcs = 0
413bAC                   eval      ptaisl = 0
413bAC                   eval      ptqty1 = 0
413bAC                   eval      ptqty2 = 0
413bAC                   eval      ptqty3 = 0
413bAC                   eval      $cvcmd = '*CURCMD '
413bAC                   call      @cvtdt
413bAC                   parm                    $cvtdt
413bAC                   eval      ptgdte = $cvd8o
413bAC                   time                    ptgtim
413bAC                   eval      ptsdte = $cvd8o
413bAC                   time                    ptstim
414 AC                   eval      ptedte = $cvd8o
414 AC                   time                    ptetim
414 D**                   Z-ADD0         PTEDTE
414 D**                   Z-ADD0         PTETIM
413bAC                   eval      ptetyp = *blanks
413bAC                   eval      ptcdte = 0
413bAC                   eval      ptctim = 0
413bAC                   eval      ptdmin = 0
413bAC                   eval      ptimin = 0
413bAC                   eval      ptrtpo = *blanks
416 AC                   eval      ptgrp1 = *blanks
416 AC                   eval      ptgrp2 = *blanks
413bAC                   write     ptrec1                               79
413bAC                   if        *in79
413bAC                   eval      error = *on
413bAC                   exsr      zm71
413bAC                   goto      endstr

PFCaAc                   else
PFCaAc                   if        logapt
PFCaAc*    Send APT BEGDAY transaction.
PFCaAc                   eval      apcmd = APTSK2
PFCaAc                   eval      aptrn# = PTTRN#
PFCaAc                   eval      apseq# = 0
PFCaAc                   eval      aploc = SCNTSK
PFCaAc                   exsr      zzapt
PFCaAc                   endif

413bAC                   endif
640bAc                   exsr      zzwrttrand
413bAC                   endif
     *
     C                   select
     *
     *  Task code entered (Only manual tasks are allowed)
     *
     C                   when      tskflg = *on
     *
     *            - Start new task
     *            - Create a new transaction record.
     *
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#
     C                   eval      ptstat = '2'
     C                   movel     w2task        pttask
     C                   movel     w2task        t#task
     C     tkkey         chain     task                               77
     C                   eval      ptcat = tkcat
     C                   eval      ptsub = tksub
     C                   select
     C                   when      tktlvl = 'S'
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = w1whdp
413aMC                   eval      ptstyp = w1styp
     C                   when      tktlvl = 'D'
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = w1whdp
     C                   eval      ptstyp = *blanks
     C                   other
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = *blanks
     C                   eval      ptstyp = *blanks
     C                   endsl
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = w1emp#
     C                   eval      ptcube = 0
     C                   eval      ptswgt = 0
     C                   eval      ptpcs = 0
     C                   eval      ptaisl = 0
     C                   eval      ptqty1 = 0
     C                   eval      ptqty2 = 0
     C                   eval      ptqty3 = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptgdte = $cvd8o
     C                   time                    ptgtim
     C                   eval      ptsdte = $cvd8o
     C                   time                    ptstim
     C                   eval      ptedte = 0
     C                   eval      ptetim = 0
     C                   eval      ptetyp = *blanks
     C                   eval      ptcdte = 0
     C                   eval      ptctim = 0
     C                   eval      ptdmin = 0
     C                   eval      ptimin = 0
     C                   eval      ptrtpo = *blanks
416 AC                   eval      ptgrp1 = *blanks
416 AC                   eval      ptgrp2 = *blanks
     C                   write     ptrec1                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endstr
     C                   endif
640bAc                   exsr      zzwrttrand
     *
     *            - Start new task
     *            - Update TASKDET file.
     *            - Decrease pending and increase active.
     *
     C                   movel     w2task        t#task
520cAC                   movel     ptwhdp        wkwhdp
     C     tdkey         chain     taskdet                            79
     C                   if        not *in79
    D**         TKTYPE    IFEQ 'D'
     C     tdpndc        sub       ptcube        tdpndc
     C     tdpndw        sub       ptswgt        tdpndw
     C                   eval      tdpndp = tdpndp - ptpcs
     C                   eval      tdpnd1 = tdpnd1 - ptqty1
     C                   eval      tdpnd2 = tdpnd2 - ptqty2
     C                   eval      tdpnd3 = tdpnd3 - ptqty3
     C                   eval      tdpndj = tdpndj - 1
    AC                   if        tdpndc < 0
    AC                   eval      tdpndc = 0
    AC                   endif
    AC                   if        tdpndw < 0
    AC                   eval      tdpndw = 0
    AC                   endif
    AC                   if        tdpndp < 0
    AC                   eval      tdpndp = 0
    AC                   endif
    AC                   if        tdpnd1 < 0
    AC                   eval      tdpnd1 = 0
    AC                   endif
    AC                   if        tdpnd2 < 0
    AC                   eval      tdpnd2 = 0
    AC                   endif
    AC                   if        tdpnd3 < 0
    AC                   eval      tdpnd3 = 0
    AC                   endif
     C                   if        tdpndj < 0
     C                   eval      tdpndj = 0
     C                   endif
    D**                   ENDIF
     C     tdactc        add       ptcube        tdactc
     C     tdactw        add       ptswgt        tdactw
     C     tdactp        add       ptpcs         tdactp
     C     tdact1        add       ptqty1        tdact1
     C     tdact2        add       ptqty2        tdact2
     C     tdact3        add       ptqty3        tdact3
     C                   add       1             tdactj
     C                   update    tdrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endstr
     C                   endif
     C                   endif
     *
     *  Transaction number entered (Both std and manual)
     *
     C                   when      tskflg = *off
     *
     *            - Update existing transaction record.
     *
410 AC                   eval      $cstr = *blanks
410 D**                   MOVE W2TASK    $CSTR
410 MC                   movel     w2task        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         trans#
     C     ptkey         chain     pirtran                            79
     C                   if        not *in79
     C                   eval      ptstat = '2'
    AC                   eval      ptshft = usshft
    AC                   eval      ptcrew = uscrew
     C                   eval      ptemp# = w1emp#
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptsdte = $cvd8o
     C                   time                    ptstim
     C                   update    ptrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endstr
     C                   endif
640bAc                   exsr      zzwrttrand
     C                   endif
     *
     *            - Update TASKDET file.
     *            - Decrease pending and increase active.
     *
     C                   eval      t#task = pttask
520cAC                   eval      wkwhdp=ptwhdp
520cA*            - Check for selection task
520cAC*  Check for selection records
520cAC                   IF        ptcat='SELECT'
520cAC                   eval      wdp = ptwhdp
520cAC                   eval      whs = ptwhse
520cAC     opkey         chain     optione
520cAC                   if        not %found(optione)
520cAC                   eval      wdp = *blanks
520cAC                   eval      whs = 0
520cAC     opkey         chain     optione
520cAC                   if        not %found(optione)
520cAC                   eval      opzord = ' '
520cAC                   endif
520cAC                   endif
520cAC                   IF        opzord= 'Z'
520cAC     lbkey         CHAIN     LABEL90                            76
520cAC                   if        not *in76
520cAC                   if        lbucod<>'TO'
520cAC     lblbl#        CHAIN     WORKLBL                            77
520cAC                   if        not *in77
520cAC                   movel     LWSZON        WKWHDP
520cAC                   endif
520cAC                   endif
520cAC                   endif
520cAC                   endif
520cAC                   endif
     C     tdkey         chain     taskdet                            79
     C                   if        not *in79
    D**         TKTYPE    IFEQ 'D'
     C     tdpndc        sub       ptcube        tdpndc
     C     tdpndw        sub       ptswgt        tdpndw
     C                   eval      tdpndp = tdpndp - ptpcs
     C                   eval      tdpnd1 = tdpnd1 - ptqty1
     C                   eval      tdpnd2 = tdpnd2 - ptqty2
     C                   eval      tdpnd3 = tdpnd3 - ptqty3
     C                   eval      tdpndj = tdpndj - 1
    AC                   if        tdpndc < 0
    AC                   eval      tdpndc = 0
    AC                   endif
    AC                   if        tdpndw < 0
    AC                   eval      tdpndw = 0
    AC                   endif
    AC                   if        tdpndp < 0
    AC                   eval      tdpndp = 0
    AC                   endif
    AC                   if        tdpnd1 < 0
    AC                   eval      tdpnd1 = 0
    AC                   endif
    AC                   if        tdpnd2 < 0
    AC                   eval      tdpnd2 = 0
    AC                   endif
    AC                   if        tdpnd3 < 0
    AC                   eval      tdpnd3 = 0
    AC                   endif
     C                   if        tdpndj < 0
     C                   eval      tdpndj = 0
     C                   endif
    D**                   ENDIF
     C     tdactc        add       ptcube        tdactc
     C     tdactw        add       ptswgt        tdactw
     C     tdactp        add       ptpcs         tdactp
     C     tdact1        add       ptqty1        tdact1
     C     tdact2        add       ptqty2        tdact2
     C     tdact3        add       ptqty3        tdact3
     C                   add       1             tdactj
     C                   update    tdrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endstr
     C                   endif
     C                   endif
     C                   endsl
     *
410 AC     endstr        endsr
     *----------------------------------------------------------------
     *
     *  ZZTASK  Get current task.
     *
410 AC     zztask        begsr
413aAC                   eval      curtrn = 0
413aAC                   eval      curtsk = *blanks
413aAC                   eval      curtyp = *blanks
413aAC                   eval      curent = *off
410 AC                   eval      stdate = *hival
410 AC                   eval      sttime = *hival
416cA*
416cAC                   eval      stat = '2'
416cAC     ptkey1        setll     pirtran1
416cAC     ptkey1        reade(n)  pirtran1                               79
416cAC                   if        *in79
416cAC                   eval      found = *off
416cAC                   goto      endtsk
416cAC                   endif
416cA*
410 AC     ptke22        setll     pirtran2
410 AC                   dow       forevr = forevr
410 AC                   read(n)   pirtran2                               79
410 AC                   if        *in79  or
410 AC                             ptemp# <> w1emp#
410 AC                   eval      found = *off
410 AC                   leave
410 AC                   endif
410 AC                   if        ptstat <> '2'
410 AC                   iter
410 AC                   endif
410 A*   Found an active transaction
410 AC                   eval      curent = *on
410 AC                   eval      trans# = pttrn#
410 AC                   eval      curtrn = pttrn#
413 MC                   eval      t#task = pttask
410 AC                   eval      w2ctsk = pttask
410 AC                   eval      $cvcmd = '*CMDMDY '
410 AC                   move      ptsdte        $cvd8i
410 AC                   call      @cvtdt
410 AC                   parm                    $cvtdt
410 AC                   eval      w2date = $cvd6o
410 AC                   eval      w2time = ptstim
410 AC     tkkey         chain     task                               79
410 AC                   if        not *in79
410 AC                   eval      curtsk = tkcode
410 AC                   eval      curtyp = tktype
410 AC                   endif
410 AC                   leave
410 AC                   enddo
410 AC     endtsk        endsr
     *----------------------------------------------------------------
     *
     *  ZZTIDY  Format date and time for error display
     *
     C     zztidy        begsr
     *  Start date
     C                   eval      dsmdy = zzsmdy
     C                   eval      ersdte = *blanks
     C                   move      dsmo          ersm
     C                   eval      ers1 = '/'
     C                   move      dsdd          ersd
     C                   eval      ers2 = '/'
     C                   move      dsyy          ersy
     *  End date
     C                   eval      dsmdy = zzemdy
     C                   eval      eredte = *blanks
     C                   move      dsmo          erem
     C                   eval      ere1 = '/'
     C                   move      dsdd          ered
     C                   eval      ere2 = '/'
     C                   move      dsyy          erey
     *  Start time
     C                   eval      dshms = zzstim
     C                   move      dshh          ershr
     C                   eval      ersc1 = ':'
     C                   move      dsmm          ersmi
     C                   eval      ersc2 = ':'
     C                   move      dsss          ersss
     *  End time
     C                   eval      dshms = zzetim
     C                   move      dshh          erehr
     C                   eval      erec1 = ':'
     C                   move      dsmm          eremi
     C                   eval      erec2 = ':'
     C                   move      dsss          eress
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZTIME   Update for screen 1.
     *
     C     zztime        begsr
     *
     *      Calculate length of time in minutes for output.
     *
     C                   eval      dshms = strtim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     C                   eval      tmpbeg = dshh * 60
     C                   add       dsmm          tmpbeg
     *
     C                   eval      dshms = fintim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     *
     *   If the ending time is < starting time, than
     *   we have gone past the midnight.
     *
     C                   if        fintim < strtim
     C                   add       24            dshh
     C                   endif
     C                   eval      tmpend = dshh * 60
     C                   add       dsmm          tmpend
     *
     C                   eval      timlen = tmpend - tmpbeg
     C                   if        timlen < 0
     C                   eval      timlen = 0
     C                   endif
     *
     C     endtim        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
413aAC                   exsr      zztask
410 AC                   select
410 AC                   when      scntyp = 'D'  and
410 AC                             curtyp = 'D'
410 A*  End current task (Direct)
410 AC                   exsr      zzend
410 A*  Start new task (Direct)
410 A*        If entered task is 'BEGDAY' then start 'IDLE' task.
410 AC                   if        scntsk = 'BEGDAY'
413 MC                   movel     'IDLE  '      w2task
410 AC                   endif
     *
413bA*        If entered task is 'ENDDAY' then create ENDDAY trans.
413bAC                   if        scntsk = 'ENDDAY'
413bAC                   call      'PIRTRN#'
413bAC                   parm                    pttrn#
413bAC                   eval      ptstat = '4'
413bAC                   eval      pttask = scntsk
413bAC                   eval      t#task = scntsk
413bAC     tkkey         chain     task                               77
413bAC                   eval      ptcat = tkcat
413bAC                   eval      ptsub = tksub
413bAC                   eval      ptwhse = w1whse
413bAC                   eval      ptwhdp = w1whdp
413bAC                   eval      ptstyp = w1styp
413bAC                   eval      ptshft = usshft
413bAC                   eval      ptcrew = uscrew
413bAC                   eval      ptemp# = w1emp#
413bAC                   eval      ptcube = 0
413bAC                   eval      ptswgt = 0
413bAC                   eval      ptpcs = 0
413bAC                   eval      ptaisl = 0
413bAC                   eval      ptqty1 = 0
413bAC                   eval      ptqty2 = 0
413bAC                   eval      ptqty3 = 0
413bAC                   eval      $cvcmd = '*CURCMD '
413bAC                   call      @cvtdt
413bAC                   parm                    $cvtdt
413bAC                   eval      ptgdte = $cvd8o
413bAC                   time                    ptgtim
413bAC                   eval      ptsdte = $cvd8o
413bAC                   time                    ptstim
413bAC                   eval      ptedte = 0
413bAC                   eval      ptetim = 0
413bAC                   eval      ptetyp = *blanks
413bAC                   eval      ptcdte = 0
413bAC                   eval      ptctim = 0
413bAC                   eval      ptdmin = 0
413bAC                   eval      ptimin = 0
413bAC                   eval      ptrtpo = *blanks
416 AC                   eval      ptgrp1 = *blanks
416 AC                   eval      ptgrp2 = *blanks
413bAC                   write     ptrec1                               79
413bAC                   if        *in79
413bAC                   eval      error = *on
413bAC                   exsr      zm71
413bAC                   goto      endup2
413bAC                   endif

PFCaAc                   if        logapt
PFCaAc*    Send APT DAYEND transaction.
PFCaAc                   eval      apcmd = APTSK2
PFCaAc                   eval      aptrn# = PTTRN#
PFCaAc                   eval      apseq# = 0
PFCaAc                   eval      aploc = SCNTSK
PFCaAc                   exsr      zzapt
PFCaAc                   endif

640bAc                   exsr      zzwrttrand
413bAC                   endif
     *
410 AC                   if        scntsk <> 'ENDDAY'
410 AC                   exsr      zzstrt
410 AC                   endif
     *
410 AC                   when      scntyp = 'I'  and
410 AC                             curtyp = 'D'
410 A*  End current task only if it is an 'IDLE' task.
410 AC                   if        curtsk = 'IDLE  '
410 AC                   exsr      zzend
410 AC                   endif
410 A*  Start new task (Indirect)
410 AC                   exsr      zzstrt
     *
410 AC                   when      scntyp = 'I'  and
410 AC                             curtyp = 'I'
410 A*  End current task. (Indirect)
410 AC                   exsr      zzend
410 A*  Start new task (Indirect)
410 AC                   exsr      zzstrt
     *
410 AC                   when      scntyp = 'D'  and
410 AC                             curtyp = 'I'  and
410 AC                             scntsk <> 'BEGDAY'
410 A*  End current task and any previous open tasks.
     *
410 AC                   eval      found = *on
410 AC                   dow       found = *on
410 AC                   eval      curtsk = *blanks
410 AC                   eval      curtyp = *blanks
410 AC                   eval      curent = *off
410 AC                   exsr      zztask
410 AC                   if        found = *off
410 AC                   leave
410 AC                   endif
410 AC                   exsr      zzend
410 AC                   enddo
     *
416eA*        If entered task is 'ENDDAY' then create ENDDAY trans.
416eAC                   if        scntsk = 'ENDDAY'
416eAC                   call      'PIRTRN#'
416eAC                   parm                    pttrn#
416eAC                   eval      ptstat = '4'
416eAC                   eval      pttask = scntsk
416eAC                   eval      t#task = scntsk
416eAC     tkkey         chain     task                               77
416eAC                   eval      ptcat = tkcat
416eAC                   eval      ptsub = tksub
416eAC                   eval      ptwhse = w1whse
416eAC                   eval      ptwhdp = w1whdp
416eAC                   eval      ptstyp = w1styp
416eAC                   eval      ptshft = usshft
416eAC                   eval      ptcrew = uscrew
416eAC                   eval      ptemp# = w1emp#
416eAC                   eval      ptcube = 0
416eAC                   eval      ptswgt = 0
416eAC                   eval      ptpcs = 0
416eAC                   eval      ptaisl = 0
416eAC                   eval      ptqty1 = 0
416eAC                   eval      ptqty2 = 0
416eAC                   eval      ptqty3 = 0
416eAC                   eval      $cvcmd = '*CURCMD '
416eAC                   call      @cvtdt
416eAC                   parm                    $cvtdt
416eAC                   eval      ptgdte = $cvd8o
416eAC                   time                    ptgtim
416eAC                   eval      ptsdte = $cvd8o
416eAC                   time                    ptstim
416eAC                   eval      ptedte = 0
416eAC                   eval      ptetim = 0
416eAC                   eval      ptetyp = *blanks
416eAC                   eval      ptcdte = 0
416eAC                   eval      ptctim = 0
416eAC                   eval      ptdmin = 0
416eAC                   eval      ptimin = 0
416eAC                   eval      ptrtpo = *blanks
416eAC                   eval      ptgrp1 = *blanks
416eAC                   eval      ptgrp2 = *blanks
416eAC                   write     ptrec1                               79
416eAC                   if        *in79
416eAC                   eval      error = *on
416eAC                   exsr      zm71
416eAC                   goto      endup2
416eAC                   endif

PFCaAc                   if        logapt
PFCaAc*    Send APT DAYEND transaction.
PFCaAc                   eval      apcmd = APTSK2
PFCaAc                   eval      aptrn# = PTTRN#
PFCaAc                   eval      apseq# = 0
PFCaAc                   eval      aploc = SCNTSK
PFCaAc                   exsr      zzapt
PFCaAc                   endif

640bAc                   exsr      zzwrttrand
416eAC                   endif
     *
410 A*  Start new task (Direct)
410 AC                   if        scntsk <> 'ENDDAY'
410 AC                   exsr      zzstrt
410 AC                   endif
     *
410 AC                   when      scntyp = 'D'  or
410 AC                             scntyp = 'I'  and
410 AC                             curtyp = ' '
410 A*  End current task.
410 AC                   exsr      zzend
410 A*
410 A*  Start new task (Direct/Indirect)
410 A*  If entered task is 'BEGDAY' then start 'IDLE' task.
410 AC                   if        scntsk = 'BEGDAY'
413 MC                   movel     'IDLE  '      w2task
410 AC                   endif
410 AC                   if        scntsk <> 'ENDDAY'
410 AC                   exsr      zzstrt
410 AC                   endif
     *
410 AC                   endsl
     *
410 D*
410 D*  Enter key - End current task
410 D*            - Update PIRTRAN1 file.
410 D*
410 D*R                   MOVE '2'       STAT
410 D*R         PTKEY1    CHAINPIRTRAN1             79
410 D*
410 D*R         *IN79     IFEQ *OFF
218 D**                   MOVE '3'       PTSTAT
410 D*R         TKSTD     IFEQ 'Y'
410 D*R                   MOVE '3'       PTSTAT
410 D*R                   ELSE
410 D*R                   MOVE '4'       PTSTAT
410 D*R                   ENDIF
410 D*R                   MOVE 'N'       PTETYP
410 D*R                   MOVE '*CURCMD '$CVCMD
410 D*R                   CALL @CVTDT
410 D*R                   PARM           $CVTDT
410 D*R                   Z-ADD$CVD8O    PTEDTE
410 D*R                   TIME           PTETIM
410 D*R                   Z-ADDPTSTIM    STRTIM
410 D*R                   Z-ADDPTETIM    FINTIM
410 D*R                   EXSR ZZTIME
410 D*R         TKTYPE    IFEQ 'D'
410 D*R                   Z-ADDTIMLEN    PTDMIN
410 D*R                   ELSE
410 D*R                   Z-ADDTIMLEN    PTIMIN
410 D*R                   ENDIF
410 D*R                   UPDATPTREC1                 79
410 D*R         *IN79     IFEQ '1'
410 D*R                   MOVE '1'       ERROR
410 D*R                   EXSR ZM72
410 D*R                   GOTO ENDUP2
410 D*R                   ENDIF
410 D*R                   ENDIF
410 D*
410 D*            - End current task
410 D*            - Update TASKDET file.
410 D*            - Decrease active and increase finished.
410 D*
410 D*R                   MOVELW2CTSK    T#TASK
410 D*R         TDKEY     CHAINTASKDET              79
410 D*R         *IN79     IFEQ *OFF
410 D*R         TDACTC    SUB  PTCUBE    TDACTC
410 D*R         TDACTW    SUB  PTSWGT    TDACTW
410 D*R         TDACTP    SUB  PTPCS     TDACTP
410 D*R         TDACT1    SUB  PTQTY1    TDACT1
410 D*R         TDACT2    SUB  PTQTY2    TDACT2
410 D*R         TDACT3    SUB  PTQTY3    TDACT3
410 D*R                   SUB  1         TDACTJ
410 D*R         TDFINC    ADD  PTCUBE    TDFINC
410 D*R         TDFINW    ADD  PTSWGT    TDFINW
410 D*R         TDFINP    ADD  PTPCS     TDFINP
410 D*R         TDFIN1    ADD  PTQTY1    TDFIN1
410 D*R         TDFIN2    ADD  PTQTY2    TDFIN2
410 D*R         TDFIN3    ADD  PTQTY3    TDFIN3
410 D*R                   ADD  1         TDFINJ
410 D*R                   UPDATTDREC                  79
410 D*R         *IN79     IFEQ '1'
410 D*R                   MOVE '1'       ERROR
410 D*R                   EXSR ZM72
410 D*R                   GOTO ENDUP2
410 D*R                   ENDIF
410 D*R                   ENDIF
410 D*
410 D*        There is a posibility that a manual task might have
410 D*        been added before the current task was ended. Hence
410 D*        adjust the current task just ended, if there is
410 D*        any overlapping manual task.
410 D*
410 D*R                   Z-ADDPTTRN#    SVTRN#
410 D*  Past overnight. (PTEDTE > PTSDTE)
410 D*R         PTEDTE    IFGT PTSDTE
410 D*R                   Z-ADDPTEDTE    STDATE
410 D*R                   ELSE
410 D*R                   Z-ADDPTSDTE    STDATE
410 D*R                   ENDIF
410 D*R                   Z-ADDPTSDTE    ZZSDTE
410 D*R                   Z-ADDPTEDTE    ZZEDTE
410 D*R                   Z-ADDPTSTIM    ZZSTIM
410 D*R                   Z-ADDPTETIM    ZZETIM
410 D*R                   EXSR ZZCKU2
410 D*
410 D*  Enter key -
410 D*
410 D*R                   SELEC
410 D*
410 D*  Task code entered (Only manual tasks are allowed)
410 D*
410 D*R         TSKFLG    WHEQ *ON
410 D*
410 D*            - Start new task
410 D*            - Create a new transaction record.
410 D*
410 D*R                   MOVE '2'       STAT
410 D*R         PTKEY1    CHAINPIRTRAN1             79
410 D*R         *IN79     IFEQ *ON
410 D*R                   CALL 'PIRTRN#'
410 D*R                   PARM           PTTRN#
410 D*R                   MOVE '2'       PTSTAT
410 D*R                   MOVELW2TASK    PTTASK
410 D*R                   MOVELW2TASK    T#TASK
410 D*R         TKKEY     CHAINTASK                 77
410 D*R                   MOVE TKCAT     PTCAT
410 D*R                   MOVE TKSUB     PTSUB
410 D*R                   SELEC
410 D*R         TKTLVL    WHEQ 'S'
410 D*R                   Z-ADDWHSE      PTWHSE
410 D*R                   MOVE WHDP      PTWHDP
410 D*R                   MOVE STYP      PTSTYP
410 D*R         TKTLVL    WHEQ 'D'
410 D*R                   Z-ADDWHSE      PTWHSE
410 D*R                   MOVE WHDP      PTWHDP
410 D*R                   MOVE *BLANKS   PTSTYP
410 D*R                   OTHER
410 D*R                   Z-ADDWHSE      PTWHSE
410 D*R                   MOVE *BLANKS   PTWHDP
410 D*R                   MOVE *BLANKS   PTSTYP
410 D*R                   ENDSL
410 D*R                   MOVE USSHFT    PTSHFT
410 D*R                   MOVE USCREW    PTCREW
410 D*R                   Z-ADDW1EMP#    PTEMP#
410 D*R                   Z-ADD0         PTCUBE
410 D*R                   Z-ADD0         PTSWGT
410 D*R                   Z-ADD0         PTPCS
410 D*R                   Z-ADD0         PTAISL
410 D*R                   Z-ADD0         PTQTY1
410 D*R                   Z-ADD0         PTQTY2
410 D*R                   Z-ADD0         PTQTY3
410 D*R                   MOVE '*CURCMD '$CVCMD
410 D*R                   CALL @CVTDT
410 D*R                   PARM           $CVTDT
410 D*R                   Z-ADD$CVD8O    PTGDTE
410 D*R                   TIME           PTGTIM
410 D*R                   Z-ADD$CVD8O    PTSDTE
410 D*R                   TIME           PTSTIM
410 D*R                   Z-ADD0         PTEDTE
410 D*R                   Z-ADD0         PTETIM
410 D*R                   MOVE *BLANKS   PTETYP
410 D*R                   Z-ADD0         PTCDTE
410 D*R                   Z-ADD0         PTCTIM
410 D*R                   Z-ADD0         PTDMIN
410 D*R                   Z-ADD0         PTIMIN
410 D*R                   MOVE *BLANKS   PTRTPO
410 D*R                   WRITEPTREC1                 79
410 D*R         *IN79     IFEQ '1'
410 D*R                   MOVE '1'       ERROR
410 D*R                   EXSR ZM71
410 D*R                   GOTO ENDUP2
410 D*R                   ENDIF
410 D*R                   ENDIF
410 D*
410 D*            - Start new task
410 D*            - Update TASKDET file.
410 D*            - Decrease pending and increase active.
410 D*
410 D*R                   MOVELW2TASK    T#TASK
410 D*R         TDKEY     CHAINTASKDET              79
410 D*R         *IN79     IFEQ *OFF
410 D**         TKTYPE    IFEQ 'D'
410 D*R         TDPNDC    SUB  PTCUBE    TDPNDC
410 D*R         TDPNDW    SUB  PTSWGT    TDPNDW
410 D*R         TDPNDP    SUB  PTPCS     TDPNDP
410 D*R         TDPND1    SUB  PTQTY1    TDPND1
410 D*R         TDPND2    SUB  PTQTY2    TDPND2
410 D*R         TDPND3    SUB  PTQTY3    TDPND3
410 D*R                   SUB  1         TDPNDJ
410 D*R         TDPNDC    IFLT 0
410 D*R                   Z-ADD0         TDPNDC
410 D*R                   ENDIF
410 D*R         TDPNDW    IFLT 0
410 D*R                   Z-ADD0         TDPNDW
410 D*R                   ENDIF
410 D*R         TDPNDP    IFLT 0
410 D*R                   Z-ADD0         TDPNDP
410 D*R                   ENDIF
410 D*R         TDPND1    IFLT 0
410 D*R                   Z-ADD0         TDPND1
410 D*R                   ENDIF
410 D*R         TDPND2    IFLT 0
410 D*R                   Z-ADD0         TDPND2
410 D*R                   ENDIF
410 D*R         TDPND3    IFLT 0
410 D*R                   Z-ADD0         TDPND3
410 D*R                   ENDIF
410 D*R         TDPNDJ    IFLT 0
410 D*R                   Z-ADD0         TDPNDJ
410 D*R                   ENDIF
410 D**                   ENDIF
410 D*R         TDACTC    ADD  PTCUBE    TDACTC
410 D*R         TDACTW    ADD  PTSWGT    TDACTW
410 D*R         TDACTP    ADD  PTPCS     TDACTP
410 D*R         TDACT1    ADD  PTQTY1    TDACT1
410 D*R         TDACT2    ADD  PTQTY2    TDACT2
410 D*R         TDACT3    ADD  PTQTY3    TDACT3
410 D*R                   ADD  1         TDACTJ
410 D*R                   UPDATTDREC                  79
410 D*R         *IN79     IFEQ '1'
410 D*R                   MOVE '1'       ERROR
410 D*R                   EXSR ZM72
410 D*R                   GOTO ENDUP2
410 D*R                   ENDIF
410 D*R                   ENDIF
410 D*
410 D*  Transaction number entered (Both std and manual)
410 D*
410 D*R         TSKFLG    WHEQ *OFF
410 D*
410 D*            - Update existing transaction record.
410 D*
410 D*R                   MOVE *BLANKS   $CSTR
410 D**                   MOVE W2TASK    $CSTR
410 D*R                   MOVELW2TASK    $CSTR
410 D*R                   CALL 'ADJUST'
410 D*R                   PARM '*RIGHT  '$CCMD   8
410 D*R                   PARM           $CSTR  30
410 D*R                   MOVE $CSTR     TRANS#
410 D*R         PTKEY     CHAINPIRTRAN              79
410 D*R         *IN79     IFEQ *OFF
410 D*R                   MOVE '2'       PTSTAT
410 D*R                   MOVE USSHFT    PTSHFT
410 D*R                   MOVE USCREW    PTCREW
410 D*R                   Z-ADDW1EMP#    PTEMP#
410 D*R                   MOVE '*CURCMD '$CVCMD
410 D*R                   CALL @CVTDT
410 D*R                   PARM           $CVTDT
410 D*R                   Z-ADD$CVD8O    PTSDTE
410 D*R                   TIME           PTSTIM
410 D*R                   UPDATPTREC                  79
410 D*R         *IN79     IFEQ '1'
410 D*R                   MOVE '1'       ERROR
410 D*R                   EXSR ZM72
410 D*R                   GOTO ENDUP2
410 D*R                   ENDIF
410 D*R                   ENDIF
410 D*
410 D*            - Update TASKDET file.
410 D*            - Decrease pending and increase active.
410 D*
410 D*R                   MOVELPTTASK    T#TASK
410 D*R         TDKEY     CHAINTASKDET              79
410 D*R         *IN79     IFEQ *OFF
410 D**         TKTYPE    IFEQ 'D'
410 D*R         TDPNDC    SUB  PTCUBE    TDPNDC
410 D*R         TDPNDW    SUB  PTSWGT    TDPNDW
410 D*R         TDPNDP    SUB  PTPCS     TDPNDP
410 D*R         TDPND1    SUB  PTQTY1    TDPND1
410 D*R         TDPND2    SUB  PTQTY2    TDPND2
410 D*R         TDPND3    SUB  PTQTY3    TDPND3
410 D*R                   SUB  1         TDPNDJ
410 D*R         TDPNDC    IFLT 0
410 D*
410 D*R                   ENDIF
410 D*R         TDPNDW    IFLT 0
410 D*R                   Z-ADD0         TDPNDW
410 D*R                   ENDIF
410 D*R         TDPNDP    IFLT 0
410 D*R                   Z-ADD0         TDPNDP
410 D*R                   ENDIF
410 D*R         TDPND1    IFLT 0
410 D*R                   Z-ADD0         TDPND1
410 D*R                   ENDIF
410 D*R         TDPND2    IFLT 0
410 D*R                   Z-ADD0         TDPND2
410 D*R                   ENDIF
410 D*R         TDPND3    IFLT 0
410 D*R                   Z-ADD0         TDPND3
410 D*R                   ENDIF
410 D*R         TDPNDJ    IFLT 0
410 D*R                   Z-ADD0         TDPNDJ
410 D*R                   ENDIF
410 D**                   ENDIF
410 D*R         TDACTC    ADD  PTCUBE    TDACTC
410 D*R         TDACTW    ADD  PTSWGT    TDACTW
410 D*R         TDACTP    ADD  PTPCS     TDACTP
410 D*R         TDACT1    ADD  PTQTY1    TDACT1
410 D*R         TDACT2    ADD  PTQTY2    TDACT2
410 D*R         TDACT3    ADD  PTQTY3    TDACT3
410 D*R                   ADD  1         TDACTJ
410 D*R                   UPDATTDREC                  79
410 D*R         *IN79     IFEQ '1'
410 D*R                   MOVE '1'       ERROR
410 D*R                   EXSR ZM72
410 D*R                   GOTO ENDUP2
410 D*R                   ENDIF
410 D*R                   ENDIF
410 D*R                   ENDSL
     *
500aA*     Check if JIT replenishments are needed.
500aAC                   if        pttask = 'FIXED'  or
500aAC                             pttask = 'PIR  '
500aAC                   exsr      chkcc
500aAC                   endif
500aA*
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     *  Task code entered.
     C                   if        tskflg = *on
     *     Start date
     C                   move      w3sdte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      stdate = $cvd8o
     C                   eval      zzsdte = $cvd8o
     *     End date
     C                   move      w3edte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      zzedte = $cvd8o
     *
     *     Convert start time to military format.
     *
     C                   eval      hrs = w3shrs
     C                   eval      min = w3smin
     C                   eval      ap = w3sap
     C                   exsr      zzapmi
     C                   eval      zzstim = miltim
     *
     *     Convert end time to military format.
     *
     C                   eval      hrs = w3ehrs
     C                   eval      min = w3emin
     C                   eval      ap = w3eap
     C                   exsr      zzapmi
     C                   eval      zzetim = miltim
     *
     C                   exsr      zzcku1
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#
     C                   eval      ptstat = '4'
     C                   movel     w3task        pttask
     C                   movel     w3task        t#task
     C     tkkey         chain     task                               77
     C                   eval      ptcat = tkcat
     C                   eval      ptsub = tksub
     C                   select
     C                   when      tktlvl = 'S'
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = w1whdp
     C                   eval      ptstyp = w1styp
     C                   when      tktlvl = 'D'
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = w1whdp
     C                   eval      ptstyp = *blanks
     C                   other
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = *blanks
     C                   eval      ptstyp = *blanks
     C                   endsl
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = w1emp#
     C                   eval      ptcube = 0
     C                   eval      ptswgt = 0
     C                   eval      ptpcs = 0
     C                   eval      ptaisl = 0
     C                   eval      ptqty1 = 0
     C                   eval      ptqty2 = 0
     C                   eval      ptqty3 = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptgdte = $cvd8o
     C                   time                    ptgtim
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w3sdte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptsdte = $cvd8o
     *
     *     Convert start time to military format.
     *
     C                   eval      hrs = w3shrs
     C                   eval      min = w3smin
     C                   eval      ap = w3sap
     C                   exsr      zzapmi
     C                   eval      ptstim = miltim
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w3edte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptedte = $cvd8o
     C                   eval      ptcdte = $cvd8o
     *
     *     Convert end time to military format.
     *
     C                   eval      hrs = w3ehrs
     C                   eval      min = w3emin
     C                   eval      ap = w3eap
     C                   exsr      zzapmi
     C                   eval      ptetim = miltim
     C                   eval      ptctim = miltim
     *
     C                   eval      ptetyp = 'M'
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptetim
     C                   exsr      zztime
     C                   eval      ptdmin = 0
     C                   eval      ptimin = 0
     C                   if        tktype = 'D'
     C                   eval      ptdmin = timlen
     C                   else
     C                   eval      ptimin = timlen
     C                   endif
     C                   eval      ptrtpo = *blanks
416 AC                   eval      ptgrp1 = *blanks
416 AC                   eval      ptgrp2 = *blanks
     C                   write     ptrec1                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endup3
     C                   endif
640bAc                   exsr      zzwrttrand
     C                   endif
     *  Transaction number entered.
     C                   if        tskflg = *off
410 AC                   eval      $cstr = *blanks
410 D**                   MOVE W3TASK    $CSTR
410 MC                   movel     w3task        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     C                   move      $cstr         trans#
     C     ptkey         chain     pirtran                            79
     C                   if        not *in79
     C                   eval      t#task = pttask
     C     tkkey         chain     task                               77
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w3sdte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptsdte = $cvd8o
     *
     *     Convert start time to military format.
     *
     C                   eval      hrs = w3shrs
     C                   eval      min = w3smin
     C                   eval      ap = w3sap
     C                   exsr      zzapmi
     C                   eval      ptstim = miltim
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w3edte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptedte = $cvd8o
     C                   eval      ptcdte = $cvd8o
     *
     *     Convert end time to military format.
     *
     C                   eval      hrs = w3ehrs
     C                   eval      min = w3emin
     C                   eval      ap = w3eap
     C                   exsr      zzapmi
     C                   eval      ptetim = miltim
     C                   eval      ptctim = miltim
     *
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptetim
     C                   exsr      zztime
     C                   if        tktype = 'D'
     C                   eval      ptdmin = timlen
     C                   else
     C                   eval      ptimin = timlen
     C                   endif
     C                   update    ptrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup3
     C                   endif
640bAc                   exsr      zzwrttrand
     C                   endif
     C                   endif
     C     endup3        endsr
500aA*
500aA*----------------------------------------------------------------*********
500aA*
500aA*  CHKCC    Check for replenishments to be created for transaction
500aA*
500aAC     chkcc         begsr
500aA*
500aAC                   call      'CCJITCL'
500aAC                   parm      uswhse        $jwhse           15 5
500aAC                   parm      trans#        $jtrn#           15 5
500aA*
500aAC     endcck        endsr
500aA*
640bA*----------------------------------------------------------------*********
640bA*
640bA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640bA*
640bA /free
640bA   begsr zzwrttrand;
640bA     wrtpcmd = '*ONETRAN';
640bA     wrtpwait = 0;
640bA     wrtpwhse = ptwhse;
640bA     wrtptran# = pttrn#;
640bA     wrtpfrmdate = 0;
640bA     wrtptodate = 0;
640bA     wrtpemp# = 0;
640bA
640bA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640bA               wrtpfrmdate: wrtptodate: wrtpemp#);
640bA   endsr;
640bA /end-free
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Employee number
Transaction number
**
Numero de empleado
numero de transaccion
**
Press F20 to end the Interrupted Transaction
