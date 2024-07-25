     *----------------------------------------------------------------
     *   Copyright (C) 1997 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RH122     Warehouse department maint - Change
     *  10 Jun 1997
     *  Dave Sommerville
     *
     *
     *  Notes
     *
     *    - This program should only be called with *CHANGE or *VIEW.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*   05/04/04  DAS  4.17
     *     - Added F9=Auto Assign to format.
     *     - Added F9 logic to ZZCMD.
     *
520 A*   09/29/08  JCJ  5.20
     *     - Added $lcmd to OI260 Parm list.
     *
710aA*   02/14/17  JCJ  7.10a
     *     - Renamed RH122FM to RH12201.
     *     - Changed to use TS903 to verify Trailer size.
710bA*   01/08/18  MLB  7.10b  P#01852
     *     - Renamed RH12201 to RH12202 as part of CSP mod.
     *     - Converted pgm to ILE as part of CSP mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Cheney
     *
CBI A*    12/18/07  CBI-JGD
     *      Modified logic to process the incorporation of trailer
     *      size to "Truck Builder" process (Pircust2/Opt# 2/Opt# 2
     *      or Pircust2/Opt# 3/Opt# 2). Also, allow user to input
     *      trailer size for all open routes at the same time by
     *      the same user without truck template being input.
     *      This aproach expedite loading this type of information
     *      into the system.
     *
     *      Truck template will be input later by the user doing
     *      the rest of the route processing.
     *      Routes will not be able to be allocated/built until
     *      the truck template info is added.
     *
CBIaA*    12/16/08  CBI-JGD
     *      Modified logic to process the new screen input field
     *      "W1CADC" which purpose is to identify the route being
     *      processed as a CADEC or non CADEC route. This info
     *      is written into the new file "CADECRTE" which is later
     *      accesed in the process (label printing) for specific
     *      CADEC route printing application.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Coastal Sunbelt Produce
     *
CSP A*    01/08/18  CSP  P#01852
     *      - Revised pgm when Truck Template, MISTAKE is selected,
     *        update status of route to Closed (RHSTAT = 5) and update
     *        status of orders to Processed. (OHSTAT = P). Orders will
     *        be updated with truck template, MISTAKE. Truck Template
     *        MISTAKE can be selected only when route is at Open status.
     *      - Added file, ORDH2 to pgm.
     *
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
710aDF**rh122fm   cf   e             workstn
710bDF**rh12201   cf   e             workstn
710bMFrh12202   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Frtehed    uf   e           k disk
     F                                     rename(rhrec:record)
     Fwarehs    if   e           k disk
CSP AFordh2     uf   e           k disk    usropn
CSP AF                                     rename(ohrec : ohrec2)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
CBIaD*desc            s             50    dim(1) ctdata perrcd(1)
CSP DD*desc            s             50    dim(3) ctdata perrcd(1)
CSP MD desc            s             50    dim(4) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Dakota Client IDs
     *
710aA /copy qcopysrc,id#cheney
CSP A /copy qcopysrc,id#Coastal
     *----------------------------------------------------------------
     *  Customer id
710aA*
710aAD                 ds
710aAD  client                 1     10
710aAD  cliloc                11     20
     *----------------------------------------------------------------
     *  Program parameters
     *
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
     D  $prte                 22     26
     D  $prtid                27     31
     D  $ptruk                32     41
     D  $pstat                42     42
     D  $ptype                43     43
     *----------------------------------------------------------------
     *  Called programs
     *
710aAD @cbitrlrsize    c                   const('CBITRLRSIZ')
710aAD @cbicadecrte    c                   const('CBICADCRTE')
710aAD @getcl          c                   const('GETCLIENT')
CSP A*
CSP AD @cvtdt          c                   const('CVTDTE')
CSP A*
CSP AD $cvtdt          ds
CSP AD  $cvcmd                 1      8
CSP AD  $cvprg                 9     18
CSP AD  $cvd6i                19     24
CSP AD  $cvd8i                25     32
CSP AD  $cvd6o                33     38  0
CSP AD  $cvd8o                39     46  0
CSP AD  $cvsto                47     64
CSP AD  $cvrtn                65     72
CSP AD  $cverm                73    132
CSP AD  $cvmsg                73     76
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
     D  $lwhse                19     21  0
     D  $ltruk                22     31
CBI AD  $ltrls                22     31
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
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
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forevr          s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
CSP AD today           s              8  0 inz(0)
CSP AD ststime         s              6  0 inz(0)
     D warn            s              1
710aAD $tsize          s             10
710aAD $tcmd           s              8
710aAD $trtn           s              8
710aAD $trte           s              5
710aAD $trteid         s              5
710aAD $pflag          s              1
     *
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
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
CSP AC     nxtscr        caseq     '02 '         sc2
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
     C                   if        error = '1'
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
     C                   exfmt     screen1                              50
     C                   endif
CSP AC                   if        nxtscr = '02 '
CSP AC                   exfmt     screen2                              50
CSP AC                   endif
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
     C     end01i        endsr
CSP A*
CSP A*----------------------------------------------------------------
CSP A*
CSP A*  Screen 01 initialization
CSP A*
CSP AC     scr02i        begsr
CSP AC                   eval      nxtscr = '02 '
CSP A*
CSP AC                   if        $pcmd = '*VIEW   '
CSP AC                   eval      *in90 = *on
CSP AC                   endif
CSP A*
CSP A*  Get field defaults if this is an add.
CSP A*
CSP AC                   if        $pcmd = '*ADD    '
CSP AC                   exsr      zzdft2
CSP AC                   else
CSP A*
CSP A*  Otherwise get existing record(s).
CSP A*
CSP AC                   eval      *in91 = *on
CSP AC                   exsr      zzget2
CSP AC                   exsr      zzfil2
CSP AC                   endif
CSP A*
CSP AC     end02i        endsr
CSP A*
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zzupd
     C     error         cabeq     '1'           endsc1
CSP A*
CSP AC                   if        client = coastalsunbelt
CSP AC                   if        w1truk = 'MISTAKE'
CSP AC                   goto      endsc1
CSP AC                   endif
CSP AC                   endif
CSP A*
     C                   endif
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
     C     endsc1        endsr
CSP A*
CSP A*----------------------------------------------------------------
CSP A*
CSP A*  SC2  -  Screen 2
CSP A*
CSP AC     sc2           begsr
CSP A*
CSP A*  Test for F3 - Exit
CSP A*
CSP AC                   if        *inkc
CSP AC     *loval        setll     record
CSP AC                   eval      nxtscr = 'EOJ'
CSP AC                   eval      $prtn = '*EXIT   '
CSP AC                   goto      endsc2
CSP AC                   endif
CSP A*
CSP A*  Test for F5 - Refresh
CSP A*
CSP AC                   if        *inke
CSP AC                   if        $pcmd <> '*VIEW   '
CSP AC                   exsr      scr02i
CSP AC                   endif
CSP AC                   goto      endsc2
CSP AC                   endif
CSP A*
CSP A*  Test for F12 - Previous
CSP A*
CSP AC                   if        *inkl
CSP AC     *loval        setll     record
CSP AC                   eval      nxtscr = 'EOJ'
CSP AC                   eval      $prtn = '*CANCEL '
CSP AC                   goto      endsc2
CSP AC                   endif
CSP A*
CSP A*  Test for other command keys BEFORE verification and update.
CSP A*
CSP AC                   eval      cmdchk = '*BEFORE '
CSP AC                   exsr      zzcmd2
CSP AC                   if        cmdtkn = '1'
CSP AC                   exsr      zzupd2
CSP AC                   if        error = '0'
CSP AC                   eval      nxtscr = 'EOJ'
CSP AC                   endif
CSP AC                   endif
CSP A*
CSP A*  Some other key pressed.
CSP A*
CSP A*     Check input and write/update record.
CSP A*
CSP AC                   if        $pcmd = '*ADD    '  or
CSP AC                             $pcmd = '*CHANGE '
CSP AC                   exsr      zzchk2
CSP AC     error         cabeq     '1'           endsc2
CSP AC                   endif
CSP A*
CSP A*  Test for other command keys AFTER verification and update.
CSP A*
CSP AC                   eval      cmdchk = '*AFTER  '
CSP AC                   exsr      zzcmd2
CSP AC     cmdtkn        cabeq     *on           endsc2
CSP A*
CSP AC     endsc2        endsr
CSP A*
     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
710aA*
710aA* Get client id.
710aA*
710aAC                   call      @getcl
710aAC                   parm                    client
710aAC                   parm                    cliloc
     *
     *  Only display Trailer size and Cadec route flag if Cheney.
     *
710aAC                   eval      *in44 = *on
710aAC                   if        client = cheney
710aAC                   eval      *in44 = *off
710aAC                   endif
CSP A*
CSP AC                   if        client = CoastalSunbelt
CSP AC                   if        not %open(ordh2)
CSP AC                   open      ordh2
CSP AC                   endif
CSP AC                   endif
CSP A*
CSP AC                   eval      $cvcmd = '*CURCMD '
CSP AC                   call      @cvtdt
CSP AC                   parm                    $cvtdt
CSP AC                   eval      today = $cvd8o
CSP AC                   time                    ststime
CSP A*
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
     C                   eval      $msgf = #msgf
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
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
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
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
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
     *     PIR7973  Slot record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
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
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
CBI AC                   eval      errmsg = *blanks
CBI A*
CBI A*  Do not verify truck code if blank, it will be input later
CBI A*  (See comments in 'Client Custom Revision/CBI' section above)
CBI A*
CBI AC                   if        client = cheney
CBI AC                             and w1truk = *blanks
CBI AC                   goto      chktrl
CBI AC                   endif
     *
     *  Verify truck code
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $pwhse
     C                   eval      $ltruk = w1truk
     C                   call      'TM900'
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
     C     chktrl        tag
CSP A*
CSP A*  Truck Template, MISTAKE only allowed at Coastal Sunbelt Produce
CSP A*  when route is at Open status.
CSP A*
CSP AC                   if        client = CoastalSunbelt
CSP A*
CSP AC                   if            rhstat <> '1'
CSP AC                             and w1truk =  'MISTAKE'
CSP AC                   eval      error = '1'
CSP AC                   eval      *in21 = '1'
CSP AC                   eval      *in01 = '1'
CSP AC                   eval      errmsg = desc(4)
CSP AC                   exsr      zm0105
CSP AC                   endif
CSP A*
CSP AC                   endif
     *
     *  Verify truck size
     *
710aAC                   if        client = cheney
710aAC                   eval      $lcmd = '*VERIFY '
710aAC                   eval      $lwhse = $pwhse
710aAC                   eval      $ltruk = w1trls
710aAC                   call      'TS903'
710aAC                   parm                    $lparm
710aAC                   if        $lrtn = '*ERROR  '
710aAC                   eval      error = *on
710aAC                   eval      *in22 = *on
710aAC                   eval      *in02 = *on
710aAC                   eval      errmsg = $lerm
710aDC                   exsr      zm0105
CBI AC                   endif
CBIaA*
CBIaA*  Verify "Is this a Cadec route?"
CBIaA*
CBIaAC                   if        w1cadc <> 'Y'
CBIaAC                             and w1cadc <> 'N'
CBIaAC                   eval      error = *on
CBIaAC                   eval      *in23 = *on
CBIaAC                   eval      *in03 = *on
CBI AC                   eval      errmsg = *blanks
CBIaAC                   movea     desc(3)       errmsg
CBIaAC                   exsr      zm0105
CBIaAC                   endif
710aAC                   endif

     C     endck1        endsr
CSP A*
CSP A*----------------------------------------------------------------
CSP A*
CSP A*  ZZCHK2   Screen 2 error checking.
CSP A*
CSP AC     zzchk2        begsr
CSP AC                   eval      error = *off
CSP AC                   eval      errmsg = *blanks
CSP A
CSP A*      Set on Error. Exit only allowed with F22=Accept or F3/12.
CSP AC                   eval      error = *on
CSP A
CSP AC     endck2        endsr
CSP A*
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
     *     Truck
     *
     C                   when      row# = 10
CBI AC                             and col# = 28
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $ltruk = w1truk
     C                   call      'TM900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1truk = $ltruk
CBIaAC                   eval      *in01 = *on
CBIaAC                   eval      *in02 = *on
     C                   endif
     *
     *     Trailer Size
     *
     C                   when      row# = 12
CBI AC                             and col# = 28
CBI AC                   eval      *in01 = *on
CBI AC                   eval      $lcmd = '*LOOKUP '
CBI AC                   eval      $lwhse = $pwhse
CBI AC                   call      'TS903'
CBI AC                   parm                    $lparm
CBI AC                   if        $lrtn = '*SELECT '
CBI AC                   eval      w1trls = $ltrls
CBI AC                   eval      *in01 = *off
CBI AC                   eval      *in03 = *on
CBI AC                   endif

     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
417 A*
417 A*  Test for F9 - Auto Assign Truck
417 A*
     C                   if        *inki
     C                   eval      cmdtkn = *on
     C                   call      'OI260'
     C                   parm      $pwhse        $xwhse            3 0
     C                   parm                    $prtid
     C                   parm                    w1truk
     C                   parm                    $xrtn             8
520 AC                   parm      '*AUTO  '     $lcmd
     C                   if        $xrtn <> '*OK'
     C                   endif
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
CSP A*
CSP A*----------------------------------------------------------------
CSP A*
CSP A*  ZZCMD2   User defined command keys for screen 2.
CSP A*
CSP AC     zzcmd2        begsr
CSP A*
CSP A*  Command keys to check BEFORE verification and update.
CSP A*
CSP AC                   if        cmdchk = '*BEFORE '
CSP A*
CSP A*  Test for F22 - Approve change to truck template, MISTAKE
CSP A*
CSP AC                   if        *inkw
CSP AC                   eval      cmdtkn = *on
CSP AC                   z-add     0             row#
CSP AC                   z-add     0             col#
CSP AC                   goto      endcm2
CSP AC                   endif
CSP A*
CSP AC                   endif
CSP A*
CSP A*  Command keys to check AFTER verification and update.
CSP A*
CSP AC                   if        cmdchk = '*AFTER  '
CSP AC                   endif
CSP A*
CSP AC     endcm2        endsr
CSP A*
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   endsr
CSP A*
CSP A*----------------------------------------------------------------
CSP A*
CSP A*  ZZDFT2   Get default values for add.
CSP A*
CSP AC     zzdft2        begsr
CSP AC                   endsr
CSP A*
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1truk = rhtruk
     C                   eval      $tsize = *blanks
     C                   eval      $pflag = *blanks
710aA*
710aAC                   call      @cbitrlrsize
710aAC                   parm      '*GET '       $tcmd
710aAC                   parm      $pwhse        $xwhse            3 0
710aAC                   parm                    rhrte
710aAC                   parm                    rhrtid
710aAC                   parm                    $tsize
710aAC                   parm                    $trtn

710aAC                   if        $trtn = '*OK'
710aAC                   eval      w1trls = $tsize
710aAC                   endif

710aAC                   call      @cbicadecrte
710aAC                   parm      '*GET '       $tcmd
710aAC                   parm                    rhrtid
710aAC                   parm                    $pflag
710aAC                   parm                    $trtn

710aAC                   eval      w1cadc = 'N'
710aAC                   if        $trtn = '*OK'
710aAC                   eval      w1cadc = $pflag
710aAC                   endif
     *
     C                   endsr
CSP A*
CSP A*----------------------------------------------------------------
CSP A*
CSP A*  ZZFIL2   Fill screen 2 fields with info from file.
CSP A*
CSP AC     zzfil2        begsr
CSP A*
CSP A*
CSP AC                   endsr
CSP A*
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
CSP DC*                  goto      endgt2
CSP MC                   goto      endgt1
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
CSP DC*                  goto      endgt2
CSP MC                   goto      endgt1
     C                   endif
CSP MC     endgt1        endsr
CSP A*
CSP A*----------------------------------------------------------------
CSP A*
CSP A*  ZZGET2   Get record(s) for screen 2.
CSP A*
CSP AC     zzget2        begsr
CSP A*
CSP AC     endgt2        endsr
CSP A*
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
CSP A*  Define key for main file.
CSP A*
CSP AC     *like         define    ohstat        kystat
CSP AC     keyoh         klist
CSP AC                   kfld                    $pwhse
CSP AC                   kfld                    kystat
CSP AC                   kfld                    rhtype
CSP AC                   kfld                    $prtid
     *
     C                   eval      $lprg = #prog
     C                   eval      forevr = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
CSP A*
CSP A*  Truck Template, MISTAKE only allowed at Coastal Sunbelt Produce
CSP A*  when route is at Open status. Update must be confirmed by F22
CSP A*  on screen 2.
CSP A*
CSP AC                   select
CSP AC                   when      client = CoastalSunbelt
CSP A*
CSP AC                   if            rhstat = '1'
CSP AC                             and w1truk =  'MISTAKE'
CSP AC                   exsr      scr02i
CSP AC                   goto      endupd
CSP AC                   endif
CSP A*
CSP AC                   endsl
     *
     *  Move screen fields to record fields
     *
     C                   eval      rhwhse = $pwhse
     C                   eval      rhtruk = w1truk
     *
     *   -OR- Update record (it was read and locked in ZZGET2)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
CBI A*
CBI A*   Load file holding trlr size
CBI A*

710aAC                   if        client = cheney
710aAC                   call      @cbitrlrsize
710aAC                   parm      '*POST'       $tcmd
710aAC                   parm      $pwhse        $xwhse
710aAC                   parm                    rhrte
710aAC                   parm                    rhrtid
710aAC                   parm      w1trls        $tsize
710aAC                   parm                    $trtn

710aAC                   if        $trtn = '*OK'
710aAC                   endif

710aAC                   call      @cbicadecrte
710aAC                   parm      '*POST'       $tcmd
710aAC                   parm                    rhrtid
710aAC                   parm      w1cadc        $pflag
710aAC                   parm                    $trtn

710aAC                   if        $trtn = '*OK'
710aAC                   endif
710aAC                   endif
     *
     *   Move key values to parameters
     *
     C                   eval      $ptruk = rhtruk
     C     endupd        endsr
CSP A*
CSP A*----------------------------------------------------------------
CSP A*
CSP A*  ZZUPD2    Update record.
CSP A*
CSP AC     zzupd2        begsr
CSP AC                   eval      error = *off
CSP A*
CSP A*   Move screen fields to record fields. Updated status to Closed.
CSP A*
CSP AC                   eval      rhtruk = w1truk
CSP AC                   eval      rhstat = '5'
CSP AC                   eval      rhstsd = today
CSP AC                   eval      rhstst = ststime
CSP A*
CSP A*   -OR- Update record (it was read and locked in ZZGET1)
CSP A*
CSP AC                   update    record                               79
CSP AC                   if        *in79
CSP AC                   eval      error = '1'
CSP AC                   exsr      zm72
CSP AC                   goto      endupd2
CSP AC                   endif
CSP A*
CSP A*
CSP AC                   eval      kystat = 'O'
CSP AC     keyoh         setll     ordh2
CSP AC                   dow       forevr = forevr
CSP AC     keyoh         reade     ordh2
CSP AC                   if        %eof(ordh2)
CSP AC                   leave
CSP AC                   endif
CSP AC
CSP AC                   eval      ohtruk = w1truk
CSP AC                   eval      ohstat = 'P'
CSP AC                   eval      ohsdte = today
CSP AC                   eval      ohstim = ststime
CSP AC                   update    ohrec2
CSP AC                   enddo
CSP A*
CSP A*   Move key values to parameters
CSP A*
CSP AC                   eval      $ptruk = rhtruk
CSP AC     endupd2       endsr
     *
     *-------------------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
Truck
Invalid trailer size.
Value entered must be N or Y
Tmpl MISTAKE allowed only when Route is Open
