610aA /COPY *libl/qcopysrc,hspecs
500cA*----------------------------------------------------------------
500cA*  Multilingual Verision
500cA*  Every screen and message has a corresponding Spanish version.
500cA*  Any changes must be made to both languages.
500cA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  SL160     RF verify zero slots
     *  25 March, 1997
     *  Dave Sommerville
     *  Roxanne Harrison
     *
     *  Notes
     *       8 X 20 Screens for hand held scanners
     *       FOUND= *ON Replenishment record exists, where "From"
     *                  and "To" aisles are different.
     *       MORE = *ON Replenishment record exists, for the entered
     *                  department.
     *       DONE = *ON No more zero slot records exists for the
     *                  department.
     *
     *  ***  THIS PROGRAM'S PROCESS WILL MIRROR SL154.  ***
     *
     *
     *  Revisions
404  *    09/04/97  RH      4.04
     *      - If Cross dock type, delete slot record and cross dock record.
     *      - Delete SPCLORD records and update all slot fields like SL154.
409  *    02/16/98  RH      4.09
     *      - If Virtual slot, delete slot record and vslot record.
409A *    07/06/98  RH      4.09
     *      - Can't verify slot if it has virtual slots tied to it.
412 A*    08/31/99  HNK     4.12
     *      - PIRITEM file added. Item and description added on screen
412AA*    09/02/99  RH      4.12A
     *      - IF virtual slots exist for base slot, skip verify base.
412BA*    09/07/99  RH   4.12
     *      - Display "Virtual Slot" if slot is a virtual slot.
414 A*    06/22/99  DAS  4.14
     *      - Added APICVTSLT to ZZCHK2 routine.                      d
414a *    07/28/00  RRH     4.14
     *      - Revised to allow reserved PIR slots to go to 'V'.
414b *    09/05/00  RRH     4.14b
     *      - Revised to delete printed exception records VSLEXCP.
414cA*    09/20/00  DAS  4.14c
     *      - Now allowing a base slot to be verified even if it      d
     *        has a corresponding virtual slot.
415a *    04/06/01  RH      4.15a
     *      - Add verify aisle to ZZCHK1.
415bA*    05/01/01  MLB  4.15b
     *      - Revised how slots are selected for verification.
     *        Only the base slot will be displayed to the user. And
     *        only when the base slot and all virtual slots are at
     *        Zero status.
     *      - Revised ZZFIL2 to not send out SL16001 msg twice.
     *
416 A*    10/01/01  HNK  4.16
     *      - Revised to start IDLE task. Add routines ZZTASK, ZZIDLE,
     *        ZZEND and ZZCKU2.
416aA*    11/16/01  DAS  4.16a
     *      - Added OPTIONS file for *ZEROVFY options.
     *      - Revised ZZINZ2 to get *ZEROVFY options.
     *      - Revised ZZAISL and ZZDEPT to use new OPVFYV option.
     *      - Revised ZZUPD2 to only delete corresponding virtual
     *        slots when OPVFYV <> 'Y'.
416bA*    12/11/01  DAS  4.16b
     *      - Revised SC2 routine to skip ZZCHKV when OPVFYV = 'Y'.
     *
417 A*    02/13/03  MLB  4.17
     *      - Fix: Revised ZZCLSE to call new routine ZZENDI to close
     *        any open(inuse) Indirect tasks before closing current
     *        direct task.  Having Indirect tasks still open while
     *        closing the current task was causing the direct task
     *        to be updated with negative direct minutes.
500aA*    02/18/02  DAS  5.00a
     *      - Code missed see 416c Added external data structure $SLOT
     *      - Code missed see 416c Added routines ZZZS2D, ZZZCOP
500bA*    06/11/02  DAS  5.00b
     *      - Code missed see 416d Changed A$LIC# from 7.0 to 15.
     *
500cA*    06/04/06  JCJ  5.00
     *      - Added Multilingual logic.
     *
610aA*    12/12/09  DAS  6.10a
     *      - Converted to ILE
     *      - Replaced old DRI logic with ILE DRI logic.
640aA*    06/07/12  LMC  6.40a
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
     *
650aA*    12/12/13  LMC  6.50a
     *      - Fix: We were seeing IDLE PIRTRAN records with an
     *      invalid warehouse.
     *      W1whse needs to be validated and reset with getwhse if
     *      the w1whse field is invalid when F3 is pressed to end.
     *      Otherwise when the IDLE is created it will have the value
     *      of the w1whse field.
710aA*    08/01/17  LMC  7.10a
     *      - Fix: Same fix as 650a need to occur on f12 also.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fsl160fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpirtran   uf a e           k disk
     Fvslexcp   uf a e           k disk
610aDF*lot2     uf   e           k disk
610aDF*                                    rename(slrec:record)
404 AFspclord   uf   e           k disk
404 AFcrossdk   uf   e           k disk
409 AFvslot1    uf   e           k disk
     Fslot1     if   e           k disk
415bMFvslot2    uf   e           k disk
     F                                     rename(vsrec:vsrec2)
412 AFpiritem   if   e           k disk
416 AFtask      if   e           k disk
416 AFpirtran1  if   e           k disk
     F                                     rename(ptrec:ptrec1)
416 AFpirtran2  if   e           k disk
     F                                     rename(ptrec:ptrec2)
416 AFpiruser   if   e           k disk
416aAFoptions   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
415aAD desc            s             50    dim(1) ctdata perrcd(1)
500cAD descsp          s             50    dim(1) ctdata perrcd(1)

610aA*----------------------------------------------------------------
610aA*  DRI parameters
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,C#DRIPARMS

610aA*----------------------------------------------------------------
610aA*  Data Formats
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,C#SLOT
610aAD saveVer#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @addtr          c                   const('ADDSTDTRN')
     D @adjtd          c                   const('ADJTSKDET')
     D @adjtr          c                   const('ADJTRAN  ')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0
     *
     D  $ltrn1                19     25  0
     *
     *
     *----------------------------------------------------------------
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
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
414 A*----------------------------------------------------------------
414 A*  API programs
414 A*
     D @apics          c                   const('APICVTSLT ')
416aA*----------------------------------------------------------------
416aA*  *ZEROVFY -  Zero verify options
416aA*----------------------------------------------------------------
416aA*
416aA* Fields
416aA*
416aA*    OPVFYV  -  Verify virtual slot using RF (Y,N)
416aA*
416aA* Data structure
416aA*
416aAD opdata          ds
416aAD  opvfyv                 1      1
416aAD  optend               117    117
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     *                                   P   1   20ERWHSE
     *
     D  erfld                  1     30
     *
     D  erqty                  1      4p 0
     D  ernqty                 5      8p 0
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
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
     *----------------------------------------------------------------
     *  Program info data structure
     *
610aA /Copy qcopysrc,c#pgminfds
610aDD*               sds
610aDD* #prog            *proc
610aDD* #job                 244    253
610aDD* #user                254    263
610aDD* #jobn                264    269
610aDD* #jobdt               276    281  0
610aDD* #jobtm               282    287  0
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
640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aA
640aAD wrttran1        pr                  extpgm('WRTTRAN1')
640aA * Input
640aAD   ppcmd                        8
640aAD   ppwait                       2  0
640aAD   ppwhse                       3  0
640aAD   pptran#                      7  0
640aAD   ppfromdate                   8  0
640aAD   pptodate                     8  0
640aAD   ppemp#                       5  0
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D ck4err          s              1
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D curent          s              1
     D curtrn          s              7  0
     D curtsk          s              6
     D curtyp          s              1
     D done            s              1
     D e               s              2  0
     D enter           s              5  0
610aMD error           s               n
     D excptn          s              1
     D fintim          s                   like(ptetim)
     D forevr          s              1
     D found           s              1
     D hasvs           s              1
     D help            s              5  0
     D kycode          s                   like(opcode)
     D kydisp          s                   like(sldisp)
     D kystat          s                   like(ptstat)
     D more            s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D slexcp          s              1
     D stdate          s                   like(ptsdte)
     D strtim          s                   like(ptstim)
     D sttime          s                   like(ptstim)
     D svdisp          s                   like(sldisp)
     D svstat          s                   like(slstat)
     D svtlen          s                   like(ptdmin)
     D svtrn#          s                   like(pttrn#)
     D t#task          s              6
     D timlen          s                   like(ptdmin)
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D today           s              8  0
     D trnpcs          s              5  0
     D warn            s              1
     D wotrn#          s              7  0
     D wxaisl          s                   like(w1aisl)
     D wxdisp          s                   like(sldisp)
640aAD wrtpcmd         s             10
640aAD wrtpwait        s              2  0
640aAD wrtpwhse        s              3  0
640aAD wrtptran#       s                   like(pttrn#)
640aAD wrtpfrmdate     s              8  0
640aAD wrtptodate      s              8  0
640aAd wrtpemp#        s                   like(ptemp#)
     D w1crew          s                   like(uscrew)
     D w1emp#          s                   like(usemp#)
     D w1shft          s                   like(usshft)
     D w1styp          s                   like(usstyp)
     D w1task          s              6
     D zzedte          s                   like(ptedte)
     D zzetim          s                   like(ptetim)
     D zzsdte          s                   like(ptsdte)
     D zzstim          s                   like(ptstim)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
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
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
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
500cAC                   select
500cAC                   when      e$lng = 'SP'
500cAC                   exfmt     scrn1sp                              50
500cAC                   other
     C                   exfmt     screen1                              50
500cAC                   endsl
     C                   endif
     C                   if        nxtscr = '02 '
500cAC                   select
500cAC                   when      e$lng = 'SP'
500cAC                   exfmt     scrn2sp                              50
500cAC                   other
     C                   exfmt     screen2                              50
500cAC                   endsl
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
     C                   setoff                                       9298
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
414 AC                   eval      redspl = *off
     C                   eval      e = 0
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
     C                   exsr      zzfil1
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
     C     end02i        endsr
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
416 A*   Start an 'IDLE' task, if no open task.
416 AC                   eval      curtrn = 0
416 AC                   eval      curtsk = *blanks
416 AC                   eval      curtyp = *blanks
416 AC                   eval      curent = *off
416 AC                   exsr      zztask
416 AC                   if        curent = *off
650aAC* validate w1whse first - reset if invalid
650aA*
650aA*   Verify warehouse and get description.
650aA*
650aAC                   eval      $lcmd = '*VERIFY '
650aAC                   eval      $lwhse = w1whse
650aAC                   call      'WH900'
650aAC                   parm                    $lparm
650aAC                   if        $lrtn = '*ERROR  '
650aAc                             or $lrtn = '*PGMQ'
650aA*
650aA*    - Get default warehouse for the user.
650aA*
650aAC                   call      'GETWHSE'
650aAC                   parm                    #user
650aAC                   parm      0             #whse             3 0
650aA*
650aAC                   eval      w1whse = #whse
650aAC                   endif
416 AC                   eval      w1task = 'IDLE  '
416 AC                   exsr      zzidle
416 AC                   endif
     *
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
416 A*   Start an 'IDLE' task, if no open task.
416 AC                   eval      curtrn = 0
416 AC                   eval      curtsk = *blanks
416 AC                   eval      curtyp = *blanks
416 AC                   eval      curent = *off
416 AC                   exsr      zztask
416 AC                   if        curent = *off
710aAC* validate w1whse first - reset if invalid
710aA*
710aA*   Verify warehouse and get description.
710aA*
710aAC                   eval      $lcmd = '*VERIFY '
710aAC                   eval      $lwhse = w1whse
710aAC                   call      'WH900'
710aAC                   parm                    $lparm
710aAC                   if        $lrtn = '*ERROR  '
710aAc                             or $lrtn = '*PGMQ'
710aA*
710aA*    - Get default warehouse for the user.
710aA*
710aAC                   call      'GETWHSE'
710aAC                   parm                    #user
710aAC                   parm      0             #whse             3 0
710aA*
710aAC                   eval      w1whse = #whse
710aAC                   endif
416 AC                   eval      w1task = 'IDLE  '
416 AC                   exsr      zzidle
416 AC                   endif
     *
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
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   if        done = *off
     C                   exsr      zzclse
416 A*    Start an 'IDLE' task.
416 AC                   exsr      zzidle
     C                   endif
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      zzclse
416 A*    Start an 'IDLE' task.
416 AC                   exsr      zzidle
     C                   eval      nxtscr = '01 '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
414 AC     redspl        cabeq     *on           endsc2
416bAC                   if        opvfyv <> 'Y'
409aAC                   exsr      zzchkv
409aAC     hasvs         cabeq     *on           endsc2
416bAC                   endif
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
412X C     endsc2        tag
412X C                   endsr
412X *R         ENDSC2    ENDSR
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
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
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
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
     C                   write     msgctl
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
500cAC                   select
500cAC                   when      e$lng = 'SP'
500cAC                   eval      $msgf = #msgsp
500cAC                   other
     C                   eval      $msgf = #msgf
500cAC                   endsl
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
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
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
     C                   write     msgrec
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

610aA*----------------------------------------------------------------
610aA*    DRI0001  Local system caused error
610aA*----------------------------------------------------------------
610aA
610aAC     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
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
     *   IT28001  Invalid slot entered.
     *
     C     zm2801        begsr
     C                   eval      #msgid = 'IT28001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
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
     *      0110  Number must be > 0
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   SL16001 No more zero slots.
     *
     C     zm1601        begsr
     C                   eval      #msgid = 'SL16001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
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
     *----------------------------------------------------------------
     *
     *  ZZAISL  Check if any more Zero slots exist for the
     *          entered aisle.
     *
     C     zzaisl        begsr
     C                   if        nxtscr = '01 '
     C                   eval      more = *off
     C     slpky1        setll     slot1                                  77
     *  - Match found
     C                   if        *in77
     C                   eval      more = *on
     C                   endif
     C                   goto      endasl
     C                   endif
     *
     C     nxtsl1        tag
415bA*
415bA*    Search for slots at Zero status.
415bAC                   dow       forevr = forevr
415bAC     slpky1        reade     slot1                                  77
415bAC                   select
415bAC                   when      *in77
415bAC                   eval      more = *off
415bAC                   leave
416aA*
416aA*    If client wants to verify virtual slots,
416aA*      then treat every zero slot individually.
416aA*
416aAC                   when      not *in77  and
416aAC                             slstat = 'Z '  and
416aAC                             opvfyv = 'Y'
416aAC                   eval      wxdisp = sldisp
416aAC                   eval      w2item = slitem
416aAC     itkey         chain     piritem                            75
416aAC                   if        not *in75
416aAC                   eval      w2desc = itdesc
416aAC                   else
416aAC                   eval      w2desc = *blanks
416aAC                   endif
416aAC                   leave
415bA*
415bA*    Process all Fixed/PIR slots here.
415bAC                   when      not *in77  and
415bAC                             slstat = 'Z '  and
415bAC                             slrsrv <> 'V'
415bA*    Make sure that all virtual slots are at Zero status.
415bAC                   exsr      zzchkv
415bA*    Virtual slot(s) not all at Zero status. Get next slot.
415bAC                   if        hasvs = *on
415bAC                   iter
415bAC                   endif
415bA*
     C                   eval      wxdisp = sldisp
412 AC                   eval      w2item = slitem
412 AC     itkey         chain     piritem                            75
412 AC                   if        not *in75
412 AC                   eval      w2desc = itdesc
412 AC                   else
412 AC                   eval      w2desc = *blanks
412 AC                   endif
415bA*
415bAC                   leave
415bA*
415bA*    Process Virtual Slot - Check that all Virtual slots and
415bA*    Base slot are at Zero status.
415bAC                   when      not *in77  and
415bAC                             slstat = 'Z '  and
415bAC                             slrsrv = 'V'
415bA*    Retrieve Base slot for Virtual Slot.
415bAC     keysl2        chain(n)  vslot1                             74
415bAC                   if        not *in74
415bA*
415bA*    Slot exception was taken. Bypass virtual slots for base slot.
415bAC                   if        slexcp = *on  and
415bAC                             vspdis = svdisp
415bAC                   iter
415bAC                   endif
415bA*
415bAC                   eval      $vwhse = vswhse
415bAC                   eval      $vwhdp = vswhdp
415bAC                   eval      $vdisp = vspdis
415bAC                   exsr      zzstat
415bA*
415bA*    Base slot at Zero / Verified status - proceed with slot verify.
415bAC                   if        $vstat = 'Z '  or
415bAC                             $vstat = 'V '
415bAC                   eval      w2item = slitem
415bAC     itkey         chain     piritem                            75
415bAC                   if        not *in75
415bAC                   eval      w2desc = itdesc
415bAC                   else
415bAC                   eval      w2desc = *blanks
415bAC                   endif
415bA*
415bA*    Load base slot to check virtual slot(s) are at Zero status.
415bAC                   eval      sldisp = vspdis
415bA*
415bA*    Make sure that all virtual slots are at Zero status.
415bAC                   exsr      zzchkv
415bA*
415bA*    Virtual slot(s) not all at Zero status. Get next slot.
415bAC                   if        hasvs = *on
415bAC                   iter
415bAC                   endif
415bA*
415bAC                   eval      wxdisp = vspdis
415bAC                   leave
415bAC                   endif
415bAC                   endif
415bA*
415bAC                   endsl
415bAC                   enddo
415bA*
415bAC                   eval      slexcp = *off
     C     endasl        endsr
409aA*----------------------------------------------------------------
409aA*
409aA*  ZZCHKV   Check if slot has virtual slots tied to it.
409aA*
409aAC     zzchkv        begsr
409aAC                   eval      error = *off
409aAC                   eval      hasvs = *off
     *
409aAC     keysl2        setll     vslot2
409aAC                   dou       forevr <> forevr
415bMC     keysl2        reade(n)  vslot2                               7879
409aAC                   if        *in79
409aAC                   leave
409aAC                   endif
415bA*
415bAC                   eval      $vwhse = vswhse
415bAC                   eval      $vwhdp = vswhdp
415bAC                   eval      $vdisp = vsdisp
415bAC                   exsr      zzstat
415bA*
415bA*    If virtual slot not at Zero status, then exit.
415bAC                   if        $vstat <> 'Z '  and
415bAC                             $vstat <> 'V '
409aAC                   eval      hasvs = *on
415bAC                   leave
415bAC                   endif
409aAC                   enddo
409aA*
414cAC     skipcv        tag
     *
409aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKU2   Check for overlapping task and update the current
     *           task just ended, by adjusting the time.
     *
416 AC     zzcku2        begsr
     C                   eval      svtlen = 0
     C     ptkey2        setll     pirtran2
     C                   dow       forevr = forevr
     C                   read      pirtran2                               79
     C                   if        *in79  or
     C                             ptsdte < zzsdte
     C                   leave
     C                   endif
     *   Skip the task that just ended.
     C                   if        not *in79  and
     C                             pttrn# = svtrn#
     C                   iter
     C                   endif
     *
     *   Skip 'IDLE' task
     *
     C                   if        pttask = 'IDLE'
     C                   iter
     C                   endif
     *
     C                   eval      t#task = pttask
     C     tkkey         chain     task                               79
     C                   if        *in79
     C                   eval      tktype = ' '
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
     C                             ptetim <= zzetim  and
     C                             tktype = 'I'
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
     C                             ptetim <= zzetim  and
     C                             tktype = 'I'
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
     C                             ptstim >= zzstim  and
     C                             tktype = 'I'
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
640aAc                   exsr      zzwrttrand
     C                   endif
416 AC     endcu2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCLSE   Close a transaction
     *
     C     zzclse        begsr
     *
417 A*    Close any open(Inuse) Indirect tasks.
417 AC                   exsr      zzendi
417 A*
     *   Calculate the time in minutes it took to complete this task.
     *   PTCTIM is used for end time instead of PTETIM, because close
     *   time and End time are the same in this case.
     *
     C     ptkey         chain     pirtran                            79
     C                   eval      strtim = ptstim
     C                   eval      ptcdte = today
     C                   time                    ptctim
417 AC                   eval      ptedte = ptcdte
417 AC                   eval      ptetim = ptctim
     C                   eval      fintim = ptctim
     C                   exsr      zztime
     C                   eval      ptdmin = timlen
     C                   eval      ptstat = '4'
     C                   eval      ptetyp = 'C'
     C                   eval      ptpcs = trnpcs
     C                   update    ptrec
640aAc                   exsr      zzwrttrand
     *
     *  Update task detail record.
     *
     C                   call      @adjtd
     C                   parm      '*END    '    $lcmd
     C                   parm      '*INTER'      $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *
     C     endcls        endsr
     *----------------------------------------------------------------
     *
     *  ZZEND  End current task.
     *
416 AC     zzend         begsr
     *  No current task to end.
     C     curtrn        cabeq     0             endend
     *  End current task
     C                   eval      wotrn# = curtrn
     C     ptkey         chain     pirtran                            79
     C                   if        not *in79
     C                   if        curtyp = 'D'  and
     C                             curtsk <> 'IDLE  '
     C                   eval      ptstat = '3'
     C                   else
     C                   eval      ptstat = '4'
     C                   endif
     C                   eval      ptetyp = 'N'
     C                   endif
     *
     C                   call      @adjtd
     C                   parm      '*END    '    @pcmd             8
     C                   parm      '*INTER  '    @ptype            8
     C                   parm                    ptparm
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     C                   update    ptrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endend
     C                   endif
640aAc                   exsr      zzwrttrand
     *
     C                   if        curtyp = 'D'
     *
     *        There is a posibility that a manual task might have
     *        been added before the current task was ended. Hence
     *        adjust the current task just ended, if there is
     *        any overlapping manual task.
     *
     C                   eval      svtrn# = pttrn#
     *  Past overnight. (PTEDTE > PTSDTE)
     C                   if        ptedte > ptsdte
     C                   eval      stdate = ptedte
     C                   else
     C                   eval      stdate = ptsdte
     C                   endif
     C                   eval      zzsdte = ptsdte
     C                   eval      zzedte = ptedte
     C                   eval      zzstim = ptstim
     C                   eval      zzetim = ptetim
     C                   exsr      zzcku2
     C                   endif
     *
416 AC     endend        endsr
     *----------------------------------------------------------------
     *
     *  ZZTASK  Get current task.
     *
416 AC     zztask        begsr
     C                   eval      stdate = *hival
     C                   eval      sttime = *hival
     *
     C                   eval      kystat = '2'
     C     ptkey1        setll     pirtran1
     C     ptkey1        reade     pirtran1                               79
     C                   if        *in79
     C                   eval      found = *off
     C                   goto      endtsk
     C                   endif
     *
     C     ptke22        setll     pirtran2
     C                   dow       forevr = forevr
     C                   read      pirtran2                               79
     C                   if        *in79  or
     C                             ptemp# <> w1emp#
     C                   eval      found = *off
     C                   leave
     C                   endif
     C                   if        ptstat <> '2'
     C                   iter
     C                   endif
     *   Found an active transaction
     C                   eval      curent = *on
     C                   eval      curtrn = pttrn#
     C                   eval      t#task = pttask
     C     tkkey         chain     task                               79
     C                   if        not *in79
     C                   eval      curtsk = tkcode
     C                   eval      curtyp = tktype
     C                   endif
     C                   leave
     C                   enddo
416 AC     endtsk        endsr
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
     *  Verify warehouse department.
     *
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
415a *
415a *    Verify aisle.
415a *
415aA*    Right adjust aisle code.
415a *
415a C                   eval      wxaisl = *blanks
415aAC                   if        w1aisl > *blanks
415a C                   eval      $cstr = w1aisl
415a C                   call      'ADJUST'
415a C                   parm      '*RIGHT  '    $ccmd             8
415a C                   parm                    $cstr            30
415a *
415a C                   move      $cstr         wxaisl
415a C     slpky1        setll     slot1                                  78
415a C                   if        not *in78
415a C                   eval      error = *on
415a C                   eval      *in23 = *on
415a C                   eval      *in03 = *on
415a C                   eval      errmsg = *blanks
500cAC                   select
500cAC                   when      e$lng = 'SP'
500cAC                   eval      errmsg = descsp(1)
500cAC                   other
415a C                   eval      errmsg = desc(1)
500cAC                   endsl
415a C                   exsr      zm0105
415a C                   endif
415a C                   endif
     *
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
414 A*
414 A*  Call API for slot.
414 A*
414 AC                   call      @apics
414 AC                   parm                    w2scan
414 AC                   parm      6             worow
414 AC                   parm      7             wocol
414 AC                   parm                    @artn             8
414 AC                   if        @artn = '*REDSPLY'
414 AC                   eval      redspl = *on
414 AC                   goto      endck2
414 AC                   endif
     *
     *  Verify display.(SCAN slot)
     *
     C                   if        w2scan <> wxdisp
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     w2scan        errmsg
     C                   exsr      zm2801
     C                   endif
     *
     C     endck2        endsr
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
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
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
     *  Test for F10 - EXCEPTION - SKIP
     *
     C                   if        *inkj
     C                   add       1             trnpcs
     C                   eval      cmdtkn = *on
415bAC                   eval      svdisp = wxdisp
415bAC                   eval      slexcp = *on
     C                   exsr      zzexcp
     C                   exsr      scr02i
     C                   goto      endcm2
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZDEPT  Check if any more ZERO SLOTS exist for the
     *          entered department.
     *
     C     zzdept        begsr
     C                   if        nxtscr = '01 '
     C                   eval      more = *off
     C     slpkey        setll     slot1                                  77
     *  - Match found
     C                   if        *in77
     C                   eval      more = *on
     C                   endif
     C                   goto      enddep
     C                   endif
     *
     C     nxtsl         tag
415bA*
415bA*    Search for slots at Zero status.
415bAC                   dow       forevr = forevr
415bAC     slpkey        reade     slot1                                  77
415bAC                   select
415bAC                   when      *in77
415bAC                   eval      more = *off
415bAC                   leave
416aA*
416aA*    If client wants to verify virtual slots,
416aA*      then treat every zero slot individually.
416aA*
416aAC                   when      not *in77  and
416aAC                             slstat = 'Z '  and
416aAC                             opvfyv = 'Y'
416aAC                   eval      wxdisp = sldisp
416aAC                   eval      w2item = slitem
416aAC     itkey         chain     piritem                            75
416aAC                   if        not *in75
416aAC                   eval      w2desc = itdesc
416aAC                   else
416aAC                   eval      w2desc = *blanks
416aAC                   endif
416aAC                   leave
415bA*
415bA*    Process all Fixed/PIR slots here.
415bAC                   when      not *in77  and
415bAC                             slstat = 'Z '  and
415bAC                             slrsrv <> 'V'
415bA*    Make sure that all virtual slots are at Zero status.
415bAC                   exsr      zzchkv
415bA*    Virtual slot(s) not all at Zero status. Get next slot.
415bAC                   if        hasvs = *on
415bAC                   iter
415bAC                   endif
415bA*
     C                   eval      wxdisp = sldisp
412 AC                   eval      w2item = slitem
412 AC     itkey         chain     piritem                            75
412 AC                   if        not *in75
412 AC                   eval      w2desc = itdesc
412 AC                   else
412 AC                   eval      w2desc = *blanks
412 AC                   endif
415bA*
415bAC                   leave
415bA*
415bA*    Process Virtual Slot - Check that all Virtual slots and
415bA*    Base slot are at Zero status.
415bAC                   when      not *in77  and
415bAC                             slstat = 'Z '  and
415bAC                             slrsrv = 'V'
415bA*    Retrieve Base slot for Virtual Slot.
415bAC     keysl2        chain(n)  vslot1                             74
415bAC                   if        not *in74
415bA*
415bA*    Slot exception was taken. Bypass virtual slots for base slot.
415bAC                   if        slexcp = *on  and
415bAC                             vspdis = svdisp
415bAC                   iter
415bAC                   endif
415bA*
415bAC                   eval      $vwhse = vswhse
415bAC                   eval      $vwhdp = vswhdp
415bAC                   eval      $vdisp = vspdis
415bAC                   exsr      zzstat
415bA*
415bA*    Base slot at Zero / Verified status - proceed with slot verify.
415bAC                   if        $vstat = 'Z '  or
415bAC                             $vstat = 'V '
415bAC                   eval      w2item = slitem
415bAC     itkey         chain     piritem                            75
415bAC                   if        not *in75
415bAC                   eval      w2desc = itdesc
415bAC                   else
415bAC                   eval      w2desc = *blanks
415bAC                   endif
415bA*
415bA*    Load base slot to check virtual slot(s) are at Zero status.
415bAC                   eval      sldisp = vspdis
415bA*
415bA*    Make sure that all virtual slots are at Zero status.
415bAC                   exsr      zzchkv
415bA*
415bA*    Virtual slot(s) not all at Zero status. Get next slot.
415bAC                   if        hasvs = *on
415bAC                   iter
415bAC                   endif
415bA*
415bAC                   eval      wxdisp = vspdis
415bAC                   leave
415bAC                   endif
415bAC                   endif
415bA*
415bAC                   endsl
415bAC                   enddo
415bA*
415bAC                   eval      slexcp = *off
     C     enddep        endsr
     *----------------------------------------------------------------
     *
     *  ZZEXCP   Can't verify zero slot, write exception.
     *
     C     zzexcp        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *  Write an item exception record.
     C     keyvex        chain     vslexcp                            77
     *  - Record found
     C                   if        not *in77
     C                   eval      vxstyp = slstyp
     C                   eval      vxtrn# = pttrn#
     C                   eval      vxuser = #user
     C                   eval      vxgdte = today
     C                   time                    vxgtim
     C                   eval      vxpdte = 0
     C                   eval      vxptim = 0
     C                   update    vxrec
     C                   else
     C                   eval      vxwhse = slwhse
     C                   eval      vxwhdp = slwhdp
     C                   eval      vxdisp = sldisp
     C                   eval      vxstyp = slstyp
     C                   eval      vxtrn# = pttrn#
     C                   eval      vxuser = #user
     C                   eval      vxgdte = today
     C                   time                    vxgtim
     C                   write     vxrec
     C                   endif
     C     endexc        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      w1whdp = *blanks
     C                   eval      w1aisl = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   eval      w2scan = *blanks
     C                   eval      w2disp = *blanks
     *   Get next SLOT record.
     C                   move      $cstr         wxaisl
     C                   select
     C                   when      w1aisl = *blanks
     C                   exsr      zzdept
     C                   if        more = *off
     C                   eval      done = *on
     C                   goto      stop1
     C                   endif
     *
     C                   when      w1aisl > *blanks
     C     back          tag
     C                   exsr      zzaisl
     C                   if        more = *off
     C                   eval      done = *on
     C                   goto      stop1
     C                   endif
     C                   endsl
     *
     C     stop1         tag
     C                   if        done = *on
     C                   exsr      zzclse
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1601
     C                   eval      nxtscr = '01 '
     C                   goto      endfl2
     C                   endif
     C                   eval      w2disp = wxdisp
     C     endfl2        endsr
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZGETZ   Get *ZEROVFY options.
416aA*
416aAC     zzgetz        begsr
     *
     C                   eval      kycode = '*ZEROVFY'
     C     opkey         chain     options                            78
     C                   if        *in78
     C                   eval      opvfyv = 'N'
     C                   endif
     *
     C                   endsr
417 A*
417 A*----------------------------------------------------------------
417 A*
417 A*  ZZENDI  End current Indirect task.
417 A*
417 AC     zzendi        begsr
417 A*
417 A*    Send currect Direct transaction number to ensure that this
417 A*    transaction doesn't get closed by mistake.
417 AC                   eval      @ptrn# = pttrn#
417 A*
417 AC                   call      @adjtr
417 AC                   parm      '*CLOSEI '    @pcmd
417 AC                   parm                    #job
417 AC                   parm                    @ptrn#
417 AC                   parm      *blanks       @ptask
417 AC                   parm      w1whse        @pwhse
417 AC                   parm      *blanks       @pwhdp
417 AC                   parm      *blanks       @pstyp
417 AC                   parm      0             @pcube
417 AC                   parm      0             @pswgt
417 AC                   parm      0             @ppcs
417 AC                   parm      0             @paisl
417 AC                   parm      0             @pqty1
417 AC                   parm      0             @pqty2
417 AC                   parm      0             @pqty3
417 AC                   parm      '0'           @prte
417 AC                   parm      ' '           @ppo
417 AC                   parm      ' '           @pgrp1
417 AC                   parm      ' '           @pgrp2
417 AC                   parm      ' '           @prtn
417 AC                   parm      ' '           @pmsg
417 A*
417 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZIDLE   Create and Start an Idle task.
     *
416 AC     zzidle        begsr
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#
     C                   eval      ptstat = '2'
     C                   eval      pttask = 'IDLE  '
     C                   eval      t#task = 'IDLE  '
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
     C                   eval      ptshft = w1shft
     C                   eval      ptcrew = w1crew
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
     C                   write     ptrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endidl
     C                   endif
640aAc                   exsr      zzwrttrand
     *
416 AC     endidl        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      wxdisp = *blanks
404 AC                   eval      forevr = *off
415bAC                   eval      *in51 = *on
415bAC                   eval      slexcp = *off
416 AC                   eval      wotrn# = 0
     *
     *  Define partial key for SLOT1 file.
     *
     C     slpkey        klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     *
     *  Define partial key for SLOT1 file.
     *
     C     slpky1        klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    wxaisl
     *
     *  Define key for slot1 file.
     *
     C     slfkey        klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    slaisl
     C                   kfld                    slloc
     C                   kfld                    slrlvl
     C                   kfld                    slhand
     *
     *  Define key for slot2 file by display field.
     *
     C     keysl2        klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
415bAC     kysl2a        klist
415bAC                   kfld                    slwhse
415bAC                   kfld                    slwhdp
415bAC                   kfld                    kydisp
415bA*
415bA*  Define partial key for SLOT1 file.
415bA*
415bAC     keysl3        klist
415bAC                   kfld                    vswhse
415bAC                   kfld                    vswhdp
415bAC                   kfld                    vsdisp
     *
     *  Define key for PIRTRAN file.
     *
     C     ptkey         klist
     C                   kfld                    pttrn#
416 A*
416 A*  Define key for PIRTRAN1 file.
416 A*
416 AC     ptkey1        klist
416 AC                   kfld                    w1emp#
416 AC                   kfld                    kystat
416 A*
416 A*  Define partial key for PIRTRAN2 file.
416 A*
416 AC     ptkey2        klist
416 AC                   kfld                    w1emp#
416 AC                   kfld                    stdate
416 A*
416 A*  Define key for PIRTRAN2 file.
416 A*
416 AC     ptke22        klist
416 AC                   kfld                    w1emp#
416 AC                   kfld                    stdate
416 AC                   kfld                    sttime
     *
     *    - Get employee number, default dept and section.
     *
416 AC     uskey         klist
416 AC                   kfld                    #user
416 A*
416 AC     uskey         chain     piruser                            79
416 AC                   if        not *in79
416 AC                   eval      w1emp# = usemp#
416 AC                   eval      w1whdp = uswhdp
416 AC                   eval      w1styp = usstyp
416 AC                   eval      w1shft = usshft
416 AC                   eval      w1crew = uscrew
416 AC                   else
416 AC                   eval      w1emp# = 0
416 AC                   eval      w1whdp = *blanks
416 AC                   eval      w1styp = *blanks
416 AC                   eval      w1shft = *blanks
416 AC                   eval      w1crew = *blanks
416 AC                   endif
     *
416 AC     tkkey         klist
416 AC                   kfld                    t#task
     *
     *
     *  Define key for TASKDET file.
     *
     C     keytd         klist
     C                   kfld                    pttask
     C                   kfld                    ptwhse
     C                   kfld                    ptwhdp
     C                   kfld                    ptstyp
     *
     *  Define key for VSLEXCP file.
     *
     C     keyvex        klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
     *
412 A*  Define key for slot2 file by display field.
412 A*
412 AC     itkey         klist
412 AC                   kfld                    slwhse
412 AC                   kfld                    slitem
416aA*
416aA*  Define key for Options file
416aA*
416aAC     opkey         klist
416aAC                   kfld                    w1whse
416aAC                   kfld                    kycode
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     *
     C                   eval      w1whse = #whse
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
500cA*
500cA*   Get employee options.
500cA*
500cAC                   call      'GETUSER'
500cAC                   parm      #user         e$code           10
500cAC                   parm                    e$whse            3 0
500cAC                   parm                    e$emp#            5 0
500cAC                   parm                    e$fnam           15
500cAC                   parm                    e$init            1
500cAC                   parm                    e$lnam           20
500cAC                   parm                    e$whdp            5
500cAC                   parm                    e$styp            1
500cAC                   parm                    e$shft            6
500cAC                   parm                    e$crew            6
500cAC                   parm                    e$nhrs            3 1
500cAC                   parm                    e$rtn             8
500cAC                   parm                    e$bpu             1
500cAC                   parm                    e$lng             2
500cAC                   if        e$rtn <> '*OK'
500cAC                   eval      e$lng = 'EN'
500cAC                   endif
500cA*
414 AC                   eval      worow = 0
414 AC                   eval      wocol = 0
     C                   eval      refrsh = *on
     C                   eval      more = *off
     C                   eval      done = *off
     C                   eval      excptn = *off
     *
     C                   exsr      scr01i
     C                   endsr
415bA*----------------------------------------------------------------
415bA*
415bA*  ZZSTAT   Retrieve status of slot.
415bA*
415bAC     zzstat        begsr
415bA*
415bAC                   call      'RTNSTAT'
415bAC                   parm                    $vwhse            3 0
415bAC                   parm                    $vwhdp            5
415bAC                   parm                    $vdisp           12
415bAC                   parm      *blanks       $vstat            2
415bA*
415bAC                   endsr
415bA*
     *----------------------------------------------------------------
     *
     *  ZZSTRT   Start a new transaction
     *
     C     zzstrt        begsr
     *
     *     - Get new transaction number.
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#
     *
     C                   call      @addtr
     C                   parm      '*CRTSTRT'    @pcmd
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      'VERIFY'      @ptask            6
     C                   parm      w1whse        @pwhse            3 0
     C                   parm      w1whdp        @pwhdp            5
     C                   parm      slstyp        @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      trnpcs        @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      '0'           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C     endstr        endsr
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
     C                   eval      refrsh = *on
     C                   eval      done = *off
     C                   eval      trnpcs = 0
416aA*
416aA*   Get *ZEROVFY options.
416aA*
416aaC                   exsr      zzgetz
     *
     *   Right adjust AISLE code.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w1aisl        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm                    $cstr
     *   Get next SLOT record.
     C                   move      $cstr         wxaisl
     C                   select
     C                   when      w1aisl = *blanks
     C                   exsr      zzdept
     C                   if        more = *off
     C                   eval      done = *on
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1601
     C                   goto      endup1
     C                   endif
     *
     C                   when      w1aisl > *blanks
     C     back2         tag
     C                   exsr      zzaisl
     C                   if        more = *off
     C                   eval      done = *on
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1601
     C                   goto      endup1
     C                   endif
     C                   endsl
     *
     C                   if        done = *off
416 A*
416 A*   Get current task.
416 A*
416 AC                   exsr      zztask
416 AC                   select
416 AC                   when      curtyp = 'D'
416 A*   End current task.
416 AC                   exsr      zzend
416 AC                   when      curtyp = 'I'
416 A*  End current task and any previous open tasks.
416 AC                   eval      found = *on
416 AC                   dow       found = *on
416 AC                   eval      curtsk = *blanks
416 AC                   eval      curtyp = *blanks
416 AC                   eval      curent = *off
416 AC                   exsr      zztask
416 AC                   if        found = *off
416 AC                   leave
416 AC                   endif
416 AC                   exsr      zzend
416 AC                   enddo
416 AC                   endsl
     *   Start new transaction.
     C                   exsr      zzstrt
     C                   endif
     C     stop2         tag
     C                   if        done = *on
     C                   eval      done = *on
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1601
     C                   goto      endup1
     C                   endif
     C                   exsr      scr02i
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   add       1             trnpcs
610aA
610aA*   Call DRISLOT to do verification.
610aA
610aAC                   exsr      clr$slot
610aAC                   eval      $slwhseu = *on
610aAC                   eval      $slwhse  = slwhse
610aAC                   eval      $slwhdpu = *on
610aAC                   eval      $slwhdp  = slWhdp
610aAC                   eval      $sldispu = *on
610aAC                   eval      $sldisp  = sldisp
600eAC                   eval      $saActionU = *on
600eAC                   eval      $saAction = 'ZVF'
610aA
610aAC                   eval      $dricommand = '*SLOT'
610aAC                   eval      $drisubcmd  = '%ZEROVFY'
610aAC                   eval      $drisys2upd = 'D'
610aAC                   exsr      zzzdricop
610aA
610aDC**   keysl2        chain     slot2                              77
610aDC**                 if        not *in77
610aDC**                 eval      svstat = slstat
610aDC**
610aDC**  Delete special order record(s).
610aDC**
610aDC**   keysl2        setll     spclord
610aDC**                 dou       forevr <> forevr
610aDC**   keysl2        reade     sprec                                7879
610aDC**                 if        *in79
610aDC**                 leave
610aDC**                 endif
610aDC**                 delete    sprec
610aDC**                 enddo
610aDC**
610aDC**  Delete Printed exception record(s).
610aDC**
610aDC**   keysl2        setll     vslexcp
610aDC**                 dow       forevr = forevr
610aDC**   keysl2        reade     vslexcp                                79
610aDC**                 if        *in79
610aDC**                 leave
610aDC**                 endif
610aDC**                 if        not *in79  and
610aDC**                           vxpdte <> 0
610aDC**                 delete    vxrec
610aDC**                 endif
610aDC**                 enddo
610aDC**
610aDC**  Change status code.
610aDC**
610aDC**                 select
610aDC**
610aDC**     Cross Dock slots.
610aDC**
610aDC**                 when      slstyp = 'X'
610aDC**                 delete    record
610aDC**
610aDC**                 exsr      zzzs2d
610aDC**                 exsr      zzzfs2
610aDC**                 eval      dricmd = '*SLOT'
610aDC**                 eval      drisub = '%DELETEX'
610aDC**                 eval      drirtn = @noupd
610aDC**                 eval      ck4err = *off
610aDC**                 exsr      zzzcop
610aDC**
610aDC**   keysl2        setll     crossdk
610aDC**                 dou       forevr <> forevr
610aDC**   keysl2        reade     cdrec                                7879
610aDC**                 if        *in79
610aDC**                 leave
610aDC**                 endif
610aDC**                 delete    cdrec
610aDC**                 enddo
610aDC**                 goto      endup2
610aDC**
610aDC**     Virtual slots.
610aDC**
610aDC**                 when      slrsrv = 'V'
610aDC**                 delete    record
610aDC**
610aDC**                 exsr      zzzs2d
610aDC**                 exsr      zzzfs2
610aDC**                 eval      dricmd = '*SLOT'
610aDC**                 eval      drisub = '%DELETEX'
610aDC**                 eval      drirtn = @noupd
610aDC**                 eval      ck4err = *off
610aDC**                 exsr      zzzcop
610aDC**
610aDC**   keysl2        chain     vslot1                             79
610aDC**                 if        not *in79
610aDC**                 delete    vsrec
610aDC**                 endif
610aDC**                 goto      endup2
610aDC**
610aDC**     All other types.
610aDC**
610aDC**                 other
610aDC**                 eval      slstat = 'V '
610aDC**                 eval      slitem = *blanks
610aDC**                 endsl
610aDC**                 eval      slsdte = today
610aDC**                 time                    slstim
610aDC**
610aDC**  Initialize dates, picking priority and quantities.
610aDC**
610aDC**                 eval      slentd = 0
610aDC**                 eval      slexpd = 0
610aDC**                 eval      slprty = 0
610aDC**                 eval      slstk1 = 0
610aDC**                 eval      slstk2 = 0
610aDC**                 eval      slstk3 = 0
610aDC**                 eval      slrcv1 = 0
610aDC**                 eval      slrcv2 = 0
610aDC**                 eval      slrcv3 = 0
610aDC**                 eval      slalc1 = 0
610aDC**                 eval      slalc2 = 0
610aDC**                 eval      slalc3 = 0
610aDC**                 eval      sltfr1 = 0
610aDC**                 eval      sltfr2 = 0
610aDC**                 eval      sltfr3 = 0
610aDC**                 eval      slpck1 = 0
610aDC**                 eval      slpck2 = 0
610aDC**                 eval      slpck3 = 0
610aDC**
610aDC**  Update record.
610aDC**
610aDC**   Update slot record when slot was Zero else, release rcd lock.
610aDC**                 select
610aDC**                 when      svstat = 'Z '
610aDC**                 update    record
610aDC**
610aDC**                 exsr      zzzs2d
610aDC**                 exsr      zzzfs1
610aDC**                 eval      dricmd = '*SLOT'
610aDC**                 eval      drisub = @vfysl
610aDC**                 eval      drirtn = @noupd
610aDC**                 eval      ck4err = *off
610aDC**                 exsr      zzzcop
610aDC**
610aDC**                 other
610aDC**                 unlock    slot2
610aDC**                 endsl
610aDC**
610aDC**   Remove all Zero status virtual slots.
610aDC**                 if        opvfyv <> 'Y'
610aDC**                 eval      kydisp = sldisp
610aDC**   kysl2a        setll     vslot2
610aDC**                 dow       forevr = forevr
610aDC**   kysl2a        reade     vslot2                                 78
610aDC**                 select
610aDC**                 when      *in78
610aDC**                 leave
610aDC**
610aDC**                 when      not *in78
610aDC**   keysl3        chain     slot2                              79
610aDC**                 if        not *in79  and
610aDC**                           slstat = 'Z '
610aDC**                 delete    record
610aDC**
610aDC**                 exsr      zzzs2d
610aDC**                 exsr      zzzfs2
610aDC**                 eval      dricmd = '*SLOT'
610aDC**                 eval      drisub = '%DELETEX'
610aDC**                 eval      drirtn = @noupd
610aDC**                 eval      ck4err = *off
610aDC**                 exsr      zzzcop
610aDC**
610aDC**                 delete    vsrec2
610aDC**                 endif
610aDC**                 endsl
610aDC**                 enddo
610aDC**                 endif
610aDC**
610aDC**                 endif
     C     endup2        tag
     C                   exsr      scr02i
404 MC                   endsr

610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------
610aA*                     DRI SUBROUTINES
610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#
     C                   endsr

640aA*----------------------------------------------------------------*********
640aA*
640aA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640aA*
640aA /free
640aA   begsr zzwrttrand;
640aA     wrtpcmd = '*ONETRAN';
640aA     wrtpwait = 0;
640aA     wrtpwhse = ptwhse;
640aA     wrtptran# = pttrn#;
640aA     wrtpfrmdate = 0;
640aA     wrtptodate = 0;
640aA     wrtpemp# = 0;
640aA
640aA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640aA               wrtpfrmdate: wrtptodate: wrtpemp#);
640aA   endsr;
640aA /end-free
     *----------------------------------------------------------------
     *  zzzdriclose   Close any open files or programs.
     *----------------------------------------------------------------

     C     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   exsr      zm0105

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   exsr      zm0001

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   endsl

     C     enddricop     endsr
     *
     *----------------------------------------------------------------
     *  COMPILE TIME TABLES
     *
**
Aisle invalid
**
Pasillo invalido
