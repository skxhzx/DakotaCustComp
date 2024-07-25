     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2009')
     H Option(*NODEBUGIO)

     *----------------------------------------------------------------
     * CHANGES MADE TO THIS PROGRAM NEED TO BE MADE TO ...
     *
     *    - DH140
     *    - PIRSQLPGM/DOCDOOR
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DH122     Dock matrix  maint - Change
     *  17 April 2002
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    04/17/02  MLB  4.16
     *      - Created.
416aA*    05/30/02  MLB  4.16a
     *      - Fix: Revised ZZUPD to get last pass if passes don't match.
     *
500 A*    09/19/05  MLB  5.00
     *      - Fix: Revised ZZINZ2 to initialize pass and door#.
     *
510 A*    12/05/06  MLB  5.10
     *      - Fix: Revised program to not lock DOCMTRX1 in ZZINZ2 routine.
510bA*    07/11/07  MLB  5.10b
     *      - Fix: Revised program to ensure record locks are released.
     *
520 A*    09/22/09  MLB  5.20
     *      - Enh: Added Assignment Type to dock matrix file key to
     *        keep automatic assigned doors separate from manually
     *        assigned doors. This was done so that the next
     *        dock door to be assigned in the automatic sequence
     *        will always be correct even when a route is moved
     *        from one door to another.
     *      - When a route is moved from a automatic assigned door
     *        to a manually assigned door, the automatic assigned
     *        door will be set back to Open status so that the next
     *        route to be processed through TruckBuilder can utilize
     *        the door.
530aA*    07/15/10  RH  5.30
     *      - Enh: Add support for Client id modifications.
640aA*    01/30/12  RTR 6.40a
     *      - Enh: Allow dock door department to be keyed by user.
     *
     *----------------------------------------------------------------
     F*  Client Custom Revisions: Royal
     F*
RYLaAF*    07/15/10  RH   RYLa
     F*      -  Enh: Change to default W1WHDP to 'CLR' to allow user
     F*         to key dock door and call DK900.  Did not change screen
     F*         because DD truck builder is live.

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  41        CONDITION DISPLAY OF DOCK DOOR OVERFLOW INFO
     *  42        CONDITION DISPLAY OF DOOR SKIP REASON INFO
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

640aDF*h122fm   cf   e             workstn
640aMFdh12201   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fdocdoor   if   e           k disk
     Fdocmtrx   uf   e           k disk
     F                                     rename(dmrec:record)
     Fdocmtrx1  uf a e           k disk
     F                                     rename(dmrec:dmrec1)
     Fdocmtrx2  if   e           k disk
     F                                     rename(dmrec:dmrec2)
     Foptions   if   e           k disk
     Frtehed    if   e           k disk
     Fwarehs    if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a10             s              1    dim(10)
     D desc            s             20    dim(2) ctdata perrcd(1)
     D dmxsts          s             30    dim(4) ctdata perrcd(1)
     D skpdsc          s             50    dim(7) ctdata perrcd(1)
     D dckasn          s             10    dim(2) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  *DOCDOOR -  Dock Door options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPATYP  -  Dock door assignment. 1=Auto, 2=Manual.
     *    OPLTYP  -  Dock door loading. 1=Single door, 2=By Department.
     *
     * Data structure
     *
     D OPDATA          DS
     D  OPATYP                 1      1
     D  OPLTYP                 2      2

530aA*----------------------------------------------------------------
530aA*  Customer id
530aA*
     D @getcl          c                   const('GETCLIENT')
530aA*
RYLaA /COPY QCOPYSRC,ID#ROYAL
     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $phdte                22     29  0
     D  $phtim                30     35  0
     D  $ppass                36     38  0
     D  $pdoor                39     41  0
     D  $pwhdp                42     46
     D  $prtid                47     51
     D  $prtec                52     56P 3
520 AD  $patyp                57     57
     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

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
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $ldoor                27     29  0
     *
     D  $lhdte                22     29  0
     D  $lhtim                30     35  0
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
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0
     D  $cvdr2               146    153
     D  $cvvl2               154    158  0
     D  $cvdr3               159    166
     D  $cvvl3               167    171  0
     D  $cvdr4               172    179
     D  $cvvl4               180    184  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D dkdoor          s              5
     D drasn           s              4    inz('    ')
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D fillscreen      s              3
     D forevr          s               n
     D help            s              5  0
520 AD kyatyp          s                   like(dmatyp)
     D kypass          s                   like(dmpass)
     D                                     inz(*hival)
     D msgk            s              4  0
     D mxpass          s              5
     D nxtscr          s              3
     D rem             s              3  0 inz(0)
     D result          s              3  0 inz(0)
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D savpass         s                   like(dmpass)
     D svpass          s                   like(dmpass)
     D svrtid          s                   like(dmrtid)
     D svwhdp          s                   like(dmwhdp)
     D warn            s              1

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371

     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *----------------------------------------------------------------

     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
 1B  C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
 1E  C                   endif

 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
 2E  C                   endcs
 1E  C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   return

     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *----------------------------------------------------------------

     C     DSPSCR        BEGSR
     *
     *   Set ON alarm indicator if error occured
     *
 1B  C                   if        error = *on
     C                   eval      *in98 = *on
 1E  C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
 1B  C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
 1E  C                   endif
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
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *     Screen initialization and wrap-up routines
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Screen 01 initialization
     *----------------------------------------------------------------

     C     SCR01I        BEGSR
     *
     C                   eval      nxtscr = '01 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     *
     C     end01i        ENDSR

     *----------------------------------------------------------------
     *              Screen Processing Routines
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  SC1  -  Screen 1
     *----------------------------------------------------------------
     *
     C     SC1           BEGSR
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
goto C                   goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
 2E  C                   endif
goto C                   goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
goto C                   goto      endsc1
 1E  C                   endif
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
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
 1E  C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     *
     C     endsc1        ENDSR

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *INZSR        BEGSR
530aA*
530aA* Get client id.
530aA*
530aAC                   call      @getcl
530aAC                   parm                    client           10
530 AC                   parm                    cliloc           10
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
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------
     *
     *---------------------------------------------------------------
     *    ZMCMSG  Clear message record subfile
     *---------------------------------------------------------------
     *
     C     ZMCMSG        BEGSR
     *
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *---------------------------------------------------------------

     C     ZMDMSG        BEGSR
     *
     C                   eval      *in97 = *on
 1B  C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
 1E  C                   endif
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *---------------------------------------------------------------

     C     ZMIMSG        BEGSR
     *
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *---------------------------------------------------------------

     C     ZMPMSG        BEGSR
     *
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
 1B  C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
 1E  C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *    ZMQMSG  Add message record to subfile from program queue
     *---------------------------------------------------------------

     C     ZMQMSG        BEGSR
     *
     C                   add       1             msgk
     C                   write     msgrec
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *    ZSCLR   Clear screen
     *---------------------------------------------------------------

     C     ZSCLR         BEGSR
     *
     C                   write     clrscr
     C                   eval      sclear = *on
     *
     C                   ENDSR

     *---------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *---------------------------------------------------------------

     C     ZMSMSG        BEGSR
     *
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf  = *blanks
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *----------------------------------------------------------------

     C     ZM01          BEGSR
     *
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *----------------------------------------------------------------

     C     ZM02          BEGSR
     *
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     *
     C                   ENDSR

640aA*----------------------------------------------------------------
640aA*   PIR      Code/Dept not found.
640aA*----------------------------------------------------------------
640aA
640aAC     ZM03          BEGSR
640aA*
640aAC                   eval      #msgid = 'PIR0202'
640aAC                   eval      #msgtp = '*DIAG  '
640aAC                   movea     desc          errmsg
640aAC                   movea     errmsg        $md(1)
640aAC                   exsr      zmpmsg
640aA*
640aAC                   ENDSR

     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *----------------------------------------------------------------

     C     ZM71          BEGSR
     *
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *----------------------------------------------------------------

     C     ZM72          BEGSR
     *
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *----------------------------------------------------------------

     C     zm73          BEGSR
     *
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *----------------------------------------------------------------

     C     ZM74          BEGSR
     *
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *----------------------------------------------------------------

     C     ZM1001        BEGSR
     *
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *----------------------------------------------------------------

     C     ZM9905        BEGSR
     *
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     ZZCHK1        BEGSR
     *
     C                   eval      error = *off
640aA
640aA*    If door entered but not dept, get dept from docdoor file.
640aA /free
640aA
604aA   if $pcmd = '*ADD    ' or $pcmd = '*CHANGE ';
640aA     if w1whdp = *blank
640aA       and w1door <> 0;
640aA
640aA       // Get dept from door record
640aA       exec sql select DDWHDP into :w1whdp
640aA                  from DOCDOOR
640aA                 where DDWHSE = :$pwhse
640aA                   and DDDOOR = :w1door;
640aA
640aA       // If door not found, error
640aA       if SQLSTT <> '00000';
640aA         error = *on;
640aA         *in21 = *on;
640aA         exsr zm03;
640aA         leavesr;
640aA       endif;
640aA
640aA     endif;
640aA   endif;
640aA
640aA /end-free

     *  When adding ....

     C                   if        $pcmd = '*ADD    '

     *    Make sure code was entered.

     C                   if        w1whdp = ' '  and w1door = 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm01
     C                   goto      endck1
     C                   endif

     *    Make sure code doesn't already exist.

     C                   eval      $pwhdp = w1whdp
     C                   eval      $pdoor = w1door
     C     fileky        chain(n)  record
     C                   if        %found
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm02
     C                   endif
     C                   endif
     *
     *  Verify dock door is active.
     *
     C                   eval      $lcmd = '*VFYSTAT'
     C                   eval      $lwhse = $pwhse
     C                   eval      $lwhdp = w1whdp
     C                   eval      $ldoor = w1door
     C                   call      'DK900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     *
     C     endck1        ENDSR

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     ZZCMD1        BEGSR
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
 2B  C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
 3B  C                   select
     *
     *     Dock door/department.
     *
     C                   when      rtnrcd = 'SCREEN1' and rtnfld = 'W1DOOR'
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     *
     *    When single door is used, allow prompt for all doors.
     C                   if        opltyp = '1'
     C                   eval      $lwhdp = '*ALL '
     *    Multiple doors used, allow prompt for only dept. doors.
     C                   else
     C                   eval      $lwhdp = w1whdp
     C                   endif
     C                   eval      $ldoor = *zeros
     C                   call      'DK900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
     C                   eval      w1door = $ldoor
     C                   endif
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
     *
     C     endcm1        ENDSR

     *----------------------------------------------------------------
     *  ZZDFT1   Get default values for add.
     *----------------------------------------------------------------

     C     ZZDFT1        BEGSR
     *
     C                   eval      w1whdp = *blanks
     C                   eval      w1door = *zeros
     C                   eval      w1maxc = *zeros
     C                   eval      w1stat = *blanks
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     ZZFIL1        BEGSR
     *
     C                   eval      w1pass = dmpass
     C                   eval      w1maxc = dmmaxc
     *
     *    If dock door not assigned, use route cube passed to program.
     C                   if        drasn = '*NO '
     C                   eval      w1rtec = $prtec
     C                   else
     C                   eval      w1rtec = dmrtec
     C                   endif
     *
     C                   eval      w1stat = dmstat
     C                   select
     C                   when      dmstat = '1'
     C                   eval      w1stds = dmxsts(1)
     *
     C                   when      dmstat = '2'
     C                   eval      w1stds = dmxsts(2)
     *
     C                   when      dmstat = '3'
     C                   eval      w1stds = dmxsts(3)
     *
     C                   when      dmstat = '4'
     C                   eval      w1stds = dmxsts(4)
     *
     C                   other
     C                   eval      w1stds = *blanks
     *
     C                   endsl
     *
     C                   eval      w1skpr = dmskpr
     C                   select
     C                   when      dmskpr = '1'
     C                   eval      w1skds = skpdsc(1)
     *
     C                   when      dmskpr = '2'
     C                   eval      w1skds = skpdsc(2)
     *
     C                   when      dmskpr = '3'
     C                   eval      w1skds = skpdsc(3)
     *
     C                   when      dmskpr = '4'
     C                   eval      w1skds = skpdsc(4)
     *
     C                   when      dmskpr = '5'
     C                   eval      w1skds = skpdsc(5)
     *
     C                   when      dmskpr = '6'
     C                   eval      w1skds = skpdsc(6)
     *
     C                   when      dmskpr = '7'
     C                   eval      w1skds = skpdsc(7)
     *
     C                   other
     C                   eval      w1skds = *blanks
     *
     C                   endsl
     *
     *    Door skipped. Display skip code and description.
     C                   if        w1skpr > *blanks
     C                   eval      *in42 = *on
     C                   else
     C                   eval      *in42 = *off
     C                   endif
     *
     C                   select
     C                   when      dmatyp = 'A'
     C                   eval      w1adsc = dckasn(1)
     *
     C                   when      dmatyp = 'M'
     C                   eval      w1adsc = dckasn(2)
     *
     C                   other
     C                   eval      w1adsc = *blanks
     *
     C                   endsl
     *
     C                   eval      w1aby  = dmaby
     *
     C                   if        drasn = '*YES'
     C*
     C                   eval      $cvcmd = '*CMDMDY '
     C                   eval      $cvd8i = %triml(%editc(dmadte: '4'))
     C                   exsr      zzcvtdt
     C                   eval      w1adte = $cvd6o
     C                   else
     C                   eval      w1adte = *zeros
     C                   endif
     C                   eval      w1atim = dmatim
     *
     *
     *    If dock door not assigned, use route cube passed to program.
     C                   if        drasn = '*NO '
     C                   eval      w1whdp = $pwhdp
     C                   else
     C                   eval      w1whdp = dmwhdp
     C                   endif
RYLa *   For Royal, set department to CLR.
RYLaAC                   if        client = royal
RYLaAC                   eval      w1whdp = 'CLR'
RYLaAC                   endif
     C                   eval      w1door = dmdoor
     *
     C     rhkey         chain     rtehed
     C                   if        %found(rtehed)
     C                   eval      w1rte = rhrte
     C                   else
     C                   eval      w1rte = *blanks
     C                   endif
     *
     *    Look for dock door overflow, if any.
     C                   exsr      zzovfl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZGET1   Get record(s) for screen 1.
     *----------------------------------------------------------------

     C     ZZGET1        BEGSR
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain(n)  record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt2
     C                   endif
     *
     *  Record not found.
     *  Note: For this program, this is ok if rcd not found.
     *        Means that dock door has not been assigned yet.
     *
     C                   if        *in79
     C     *nokey        clear                   record
     C*                  eval      error = *on
     C*                  eval      $prtn = '*PGMQ   '
     C*                  exsr      zm73
     C*                  goto      endgt2
     C                   endif
     *
     C     endgt2        ENDSR

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     ZZINZ         BEGSR
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $phdte
     C                   kfld                    $phtim
520 AC                   kfld                    $patyp
     C                   kfld                    $ppass
     C                   kfld                    $pdoor
     C                   kfld                    $pwhdp
     *
     *  Define key for main file.
     *
     C     oflkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $phdte
     C                   kfld                    $phtim
520 AC                   kfld                    $patyp
     C                   kfld                    $ppass
     C                   kfld                    w1ofdr
     C                   kfld                    w1whdp
     *
     *  Define key for DOCDOOR file - Full key.
     *
     C     keydd         klist
     C                   kfld                    $pwhse
     C                   kfld                    w1door
     C                   kfld                    w1whdp
     *
     *  Define key for DOCMTRX1 file - Partial key.
     *
     C     kydm1         klist
     C                   kfld                    $pwhse
     C                   kfld                    $phdte
     C                   kfld                    $phtim
520 AC                   kfld                    kyatyp
     C                   kfld                    w1whdp
     C                   kfld                    kypass
     C                   kfld                    w1door
     *
     *  Define key for DOCMTRX1 file - Partial key.
     *
     C     kydm1a        klist
     C                   kfld                    $pwhse
     C                   kfld                    $phdte
     C                   kfld                    $phtim
520 AC                   kfld                    kyatyp
     C                   kfld                    w1whdp
     *
     *  Define key for DOCMTRX1 file - Partial key.
     *
     C     kydm1b        klist
     C                   kfld                    $pwhse
     C                   kfld                    $phdte
     C                   kfld                    $phtim
520 AC                   kfld                    kyatyp
     C                   kfld                    w1whdp
     C                   kfld                    dmpass
     C                   kfld                    w1door
     *
     *  Define key for DOCMTRX2 - Partial
     *
     C     kydm2         klist
     C                   kfld                    $pwhse
     C                   kfld                    dmrtid
     C                   kfld                    dmwhdp
     C                   kfld                    dmdoor
     *
     *  Define key for DOCMTRX2 - Partial
     *
     C     kydm2a        klist
     C                   kfld                    $pwhse
     C                   kfld                    dmrtid
     C                   kfld                    dmwhdp
     *
     *  Define key for OPTIONS file. - Full
     *
     C     keyop         KLIST
     C                   KFLD                    $pwhse
     C                   KFLD                    opcode
     *
     *  Define key for RTEHED file.
     *
     C     rhkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     C                   eval      forevr = *on
     C                   eval      $lprg = #prog
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     ZZINZ2        BEGSR
     *
     C                   reset                   screen1
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *  Get Dock Door Options.
     *
     C                   eval      opcode = '*DOCDOOR'
     C     keyop         chain     Options
     *
     *    If options record not found:
     *      Default to auto assign dock doors &
     *      use single door for loading route.
     *
     C                   if        not %found(options)
     C                   eval      opatyp = '1'
     C                   eval      opltyp = '1'
     C                   endif
     *
     *   Set flag if route already assigned to dock door.
     *
     C     fileky        setll     docmtrx
     C                   if        %equal
     C                   eval      drasn  = '*YES'
     *
     C                   else
     *
     C                   eval      drasn  = '*NO '
     *
     *    Retrieve last dock matrix history record.
     C                   eval      $lprg = #prog
     C                   eval      $luky  = $puky
     C                   call      'DH910'
     C                   parm                    $lparm
     C                   if        $lrtn = '*OK     '
     C                   eval      $phdte = $lhdte
     C                   eval      $phtim = $lhtim
     C                   endif
     *
     C                   endif
     *
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
     C                   eval      $pwhdp = *blanks
     C                   eval      $pdoor = 0
500 AC                   eval      $ppass = 1
500 AC                   eval      $prtec = 0
500 AC     kydm1         setgt     docmtrx1
510 DC*    kydm1a        readpe    docmtrx1
510 MC     kydm1a        readpe(n) docmtrx1
500 AC                   if        not %eof(docmtrx1)
500 AC                   eval      $ppass = dmpass
500 AC                   endif
     C                   endif
     *
     C                   exsr      scr01i
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCKDR   Check if this is odd/even dock door.
     *----------------------------------------------------------------
     *
     C     ZZCKDR        BEGSR
     *
     C     w1door        div       2             result
     C                   mvr                     rem
     *
     C                   if        rem > 0
     C                   eval      dkdoor = '*ODD '
     C                   else
     C                   eval      dkdoor = '*EVEN'
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCKPS   Check if this is odd/even dock door assignment pass.
     *----------------------------------------------------------------
     *
     C     ZZCKPS        BEGSR
     *
     C     dmpass        div       2             result
     C                   mvr                     rem
     *
     C                   if        rem > 0
     C                   eval      mxpass = '*ODD '
     C                   else
     C                   eval      mxpass = '*EVEN'
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCVTDT  Convert date.
     *----------------------------------------------------------------

     C     ZZCVTDT       BEGSR
     *
     *    Retrieve current date.
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      dmadte = $cvd8o
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZDRADD  Add new pass / dock door.
     *----------------------------------------------------------------

     C     ZZDRADD       BEGSR
520 A*
520 A*      Increment matrix pass if zero.
520 AC                   if        dmpass = 0
520 AC                   eval      dmpass = dmpass + 1
520 AC                   endif
520 A*
     C                   exsr      zzckps
     C                   exsr      zzckdr
     C                   exsr      zzgtdr
     *
     *    Dock matrix pass and dock door not both even/odd.
     *    Increment pass to match door selected by user.
     C                   if        mxpass <> dkdoor or
     C                             mxpass = dkdoor and (dmstat = '2' or
     C                             dmstat = '4')
     C                   eval      dmpass = dmpass + 1
     C                   exsr      zzckps
     C                   if        mxpass <> dkdoor
     C                   eval      dmpass = dmpass + 1
     C                   endif
     C                   endif
     *
520 AC                   eval      dmwhse = $pwhse
520 AC                   eval      dmhdte = $phdte
520 AC                   eval      dmhtim = $phtim
520 AC                   eval      dmwhdp = w1whdp
520 A*
     C                   eval      dmdoor = w1door
     C                   eval      dmrtid = $prtid
     C                   eval      dmmaxc = ddmaxc
     C                   eval      dmrtec = w1rtec + w1ofcb
     C                   eval      dmstat = '2'
     C                   eval      dmovrf = 'N'
     C                   eval      dmskpr = ' '
520 DC*                  eval      dmatyp = 'M'
520 MC                   eval      dmatyp = kyatyp
     C                   eval      dmaby  = #user
     C                   eval      $cvcmd = '*CURCMD '
     *    Retrieve current date.
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      dmadte = $cvd8o
     C                   time                    dmatim
     C                   write     dmrec1
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZDRUPD  Update pass / dock door info.
     *----------------------------------------------------------------

     C     ZZDRUPD       BEGSR
     *
     C                   exsr      zzckps
     C                   exsr      zzckdr
     *
     *    Dock matrix pass and dock door not both even/odd.
     *    Increment pass to match door selected by user.
     C                   if        mxpass <> dkdoor
     C                   eval      dmpass = dmpass + 1
     C                   endif
     *
     C                   eval      dmdoor = w1door
     C                   eval      dmrtid = $prtid
     C                   eval      dmrtec = w1rtec + w1ofcb
     C                   eval      dmstat = '2'
     C                   eval      dmovrf = 'N'
     C                   eval      dmskpr = ' '
520 DC*                  eval      dmatyp = 'M'
520 MC                   eval      dmatyp = kyatyp
     C                   eval      dmaby  = #user
     C                   eval      $cvcmd = '*CURCMD '
     *    Retrieve current date.
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      dmadte = $cvd8o
     C                   time                    dmatim
     *
     *    Dock matrix pass and dock door not both even/odd.
     *    Add record to match door selected by user.
     C                   if        mxpass <> dkdoor
     C                   write     dmrec1
     C                   else
     C                   update    dmrec1
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZGTDR  Get dock door master.
     *----------------------------------------------------------------

     C     ZZGTDR        BEGSR
     *
     C     keydd         chain     docdoor
     C                   if        not %found
     C                   eval      ddmaxc = 0
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZOVFL  Look for overflow dock door, if any.
     *----------------------------------------------------------------

     C     ZZOVFL        BEGSR
     *
     C                   eval      *in41 = *off
     C                   eval      w1ovrf  = 'N'
     *
     *    Save values for this door.
     *
     C                   eval      svpass = dmpass
     C                   eval      svwhdp = dmwhdp
     C                   eval      svrtid = dmrtid
     *
     *    Look for overflow for this route.
     C     kydm2         setgt     docmtrx2
     C     kydm2a        reade     docmtrx2
     *
     C                   if        not %eof  and dmpass = svpass and
     C                             dmrtid = svrtid and dmwhdp = svwhdp and
     C                             dmovrf = 'Y'
     *
     *    Door overflow found. Send back door# and overflow cube amt.
     C                   eval      w1ovrf  = dmovrf
     C                   eval      w1ofdr  = dmdoor
     C                   eval      w1ofcb  = dmrtec
     C                   eval      *in41   = *on
     *
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZUPD    Update record.
     *----------------------------------------------------------------

     C     ZZUPD         BEGSR
     *
     C                   eval      error = *off
     *
     C                   select
     *
     *    No changes. Release record lock.
     C                   when      $pwhdp = W1whdp and
     C                             $pdoor = W1door
     C                   unlock    docmtrx
510bAC                   unlock    docmtrx1
     *
     *    Door changes. Update dock matrix.
     C                   other
     *
     C                   select
     *
     *    Dock department or dock door changed.
     C                   when      ($pwhdp <> W1whdp or
     C                             $pdoor <> W1door) and drasn  = '*YES'
     *
     *    Remove route from current door.
     C     fileky        chain     docmtrx
     C                   if        %found(docmtrx) and dmstat = '2'
     C                   eval      dmrtid = *blanks
     C                   eval      dmrtec = *zeros
520 DC*                  eval      dmstat = '3'
520 MC                   eval      dmstat = '1'
     C                   eval      dmovrf = 'N'
520 DC*                  eval      dmskpr = '7'
520 MC                   eval      dmskpr = ' '
520 DC*                  eval      dmatyp = 'M'
     C                   eval      dmaby = *blanks
     C                   eval      dmadte = *zeros
     C                   eval      dmatim = *zeros
     C                   update    record
     C                   endif
     *
     *    Remove route from overflow door if one assigned.
     *
     C                   if        w1ovrf = 'Y'
     *
     C     oflkey        chain     docmtrx
     C                   if        %found(docmtrx) and dmstat = '2'
     C                   eval      dmrtid = *blanks
     C                   eval      dmrtec = *zeros
520 DC*                  eval      dmstat = '3'
520 MC                   eval      dmstat = '1'
     C                   eval      dmovrf = 'N'
520 DC*                  eval      dmskpr = '7'
520 MC                   eval      dmskpr = '7'
520 DC*                  eval      dmatyp = 'M'
     C                   eval      dmaby = *blanks
     C                   eval      dmadte = *zeros
     C                   eval      dmatim = *zeros
     C                   update    record
     C                   endif
     C                   endif
     C                   endsl
     *
     *    Find last pass.  See if dock door is available.
     *
520 A*    Force assignment type to manual for add and update.
520 AC                   eval      kyatyp = 'M'
     C     kydm1         setgt     docmtrx1
     C     kydm1a        readpe    docmtrx1
416aAC                   if        %eof
416aAC                   eval      savpass = *hival
416aAC                   else
416aAC                   eval      savpass = dmpass
416aAC                   endif
     C     kydm1b        setgt     docmtrx1
     C     kydm1a        readpe    docmtrx1
416aA*
416aA*    Pass read is less than previous pass. Get very last pass.
416aAC                   if        dmpass < savpass
416aAC     kydm1         setgt     docmtrx1
416aAC     kydm1a        readpe    docmtrx1
416aAC                   endif
     C                   select
     *
     *    Pass found and door ok to use.
     C                   when      not %eof and
     C                             (dmstat = '1' or dmstat = '3') and
     C                             w1door = dmdoor
     C                   exsr      zzdrupd
     *
     *    Pass not found or door at wrong status. Create new pass
     *    update door with new info.
     C                   when      %eof or
     C                             not %eof and (dmstat = '2' or dmstat = '4')
     C                             or not %eof and (dmstat = '1' or dmstat = '3'
     C                             and (w1door <> dmdoor))
     C                   exsr      zzdradd
     *
     C                   endsl
510bA*
510bAC                   unlock    docmtrx
510bAC                   unlock    docmtrx1
     *
     *   Move key values to parameters
     *
     C                   eval      $pwhdp = w1whdp
     C                   eval      $pdoor = w1door
     *
     C                   endsl
     *
     C     endupd        ENDSR

     *----------------------------------------------------------------*********
     *  COMPILE TIME TABLES
     *----------------------------------------------------------------*********
**
Dock Door
Status
** Dock matrix status
Open
Assigned
Skipped
Inactive
** Dock matrix skip reasons
Skipped - Pass mismatch
Skipped - Door used on previous pass
Skipped - Cube overflow. Next door not available
New pass created manually
Route manually removed
Route forced. No doors avail. during auto assign.
Route moved manually by user.
** Dock matrix assignment types
Automatic
Manual
