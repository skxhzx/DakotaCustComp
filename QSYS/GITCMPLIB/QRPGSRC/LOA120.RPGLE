      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LOA120     LOADER - Options
     *  12 Jan 2009
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    01/12/09  RBD  5.20
     *      - Created.
     *
650a *    04/09/14  GJA  6.50a
     *      - Added voice loader options:
     *         Loading order (0=Any, 1=Standard, 2=Row/Column, 3=Column
     *         Speak trailer id to user  (Y/N)
     *         Speak row/column to user  (Y/N)
     *         Verify pallet position on trailer (Y/N)
     *
650bA*    03/05/15  RBD  6.50b
     *      - Changed screen format to LOA12002.
     *      - Added new option OPVFYP, verify pallet label against
     *        pick label (Y/N).
     *
700aA*    02/17/16  RBD  7.00a
     *      - Changed screen format to LOA12003.
     *      - Added new field OPADDO to *LOADER, auto define add-on
     *        routes Y/N. When a route goes to printed status and this
     *        option is Y check to see if a matching host route exists in
     *        RTEHED within the loader start and end times for the current
     *        day. If a match is found and it doesn't exist in TTMERG,
     *        then designate the one found in RTEHED as the parent, the one
     *        just pick/printed as the child and write both to TTMERG.
     *        If a match is found and it does exist in TTMERG, add the
     *        one just pick/printed as a child in TTMERG. This saves the
     *        user the manual task of defining add-ons through the Trax
     *        Merge Route Maintenance.  Of course the user may still
     *        maintain add-ons through the maintenance program if desired.
     *
700bA*    08/23/16  RBD  7.00b
     *      - Changed screen format to LOA12004.
     *      - Added new field OPEQIP to *LOADER, Y/N. If Y call Load
     *        Equip program from Merged Pallet Loading program.
     *      - Added new field OPBYPL to *LOADER, Y/N. If Y bypass the
     *        entry of quantity when loading equipment in pgm EQ480.
     *      - Added new field OPBYPR to *LOADER, Y/N. If Y bypass the
     *        entry of quantity when returning equipment in pgm EQ485.
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
650aDF***loa120fm  cf   e             workstn
650bDF*loa12001  cf   e             workstn
700aDF*loa12002  cf   e             workstn
700bDF*loa12003  cf   e             workstn
700bMFloa12004  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Foptions   uf a e           k disk
     F                                     rename(oprec:record)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
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
     *----------------------------------------------------------------
     *  *LOADER  -  LOADER options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPSTTM  -  Start time for a day's routes.
     *    OPENTM  -  End time for a day's routes.
650aA*    OPLDOR  -  Loading order (0=Any, 1=Standard,
650aA*               2=Row/Column, 3=Column
650aA*    OPTLID  -  Speak trailer id to user  (Y/N)
650aA*    OPRWCL  -  Speak row/column to user  (Y/N)
650aA*    OPVYPL  -  Verify pallet position on trailer (Y/N)
650bA*    OPVFYP  -  Verify pallet label against pick label.
700aA*    OPADDO  -  Auto define add-on routes Y/N.
700bA*    OPEQIP  -  Load Equip by zone Y/N.
700bA*    OPBYPL  -  Bypass entry of qty when loading equipment Y/N.
700bA*    OPBYPR  -  Bypass entry of qty when returning equipment Y/N.
     *
     * Data structure
     *
     D opdata          ds
     D  opsttm                 1      6  0
     D  opentm                 7     12  0
650aAD  opldor                13     13
650aAD  optlid                14     14
650aAD  oprwcl                15     15
650aAD  opvypl                16     16
650bAD  opvfyp                17     17
700aAD  opaddo                18     18
700bAD  opeqip                19     19
700bAD  opbypl                20     20
700bAD  opbypr                21     21
     D  optend               117    117
     *
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
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *
     D  $ldesg                19     23
     *
     D  $lactv                19     20
     *
     D  $lum                  19     20
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Working variables
     *
     D $cpath          S            640A
     D $cauth          S             10A
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
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D tmpflg          s              1
     D warn            s              1
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  erUser                 1     10
     D  erAction              11     40
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
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CHANGE  - Edit record.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for everything but *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new unique key for *ADD.
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
     *
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
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
     *
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
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
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
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
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
     *   OP16021  Passwords do not match.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'OP16021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0148  User not authorized to use ...
     *
     C     ZM0148        BEGSR
     C                   MOVE      'PIR0148'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
     *----------------------------------------------------------------
     *   PIR0203  Value can not be blank.
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify start time.
     *
     C                   if        w1sttm <= 0 or
     C                             w1sttm > 240000
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erfld = 'Start time'
     C                   movel     '000001'      erfrom
     C                   movel     '240000'      erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify end time.
     *
     C                   if        w1entm <= 0 or
     C                             w1entm > 240000
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erfld = 'End time'
     C                   movel     '000001'      erfrom
     C                   movel     '240000'      erto
     C                   exsr      zm0112
     C                   endif
     *
650aA*  Verify loading order
650aA*
650aAC                   if        w1ldor <> '0' and
650aAC                             w1ldor <> '1' and
650aAC                             w1ldor <> '2' and
650aAC                             w1ldor <> '3' and
650aAC                             w1ldor <> ' '
650aAC                   eval      error = *on
650aAC                   eval      *in21 = *on
650aAC                   eval      *in01 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   eval      erfld = 'Loading order'
650aAC                   exsr      zm0112
650aAC                   endif
650aA*
650aAC                   if        w1ldor = ' '
650aAC                   eval      error = *on
650aAC                   eval      *in21 = *on
650aAC                   eval      *in01 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   eval      erfld = 'Loading order'
650aAC                   exsr      zm0203
650aAC                   endif
650aA*
650aA*  Verify speak trailer ID to user
650aA*
650aAC                   if        w1tlid <> 'Y' and
650aAC                             w1tlid <> 'N' and
650aAC                             w1tlid <> ' '
650aAC                   eval      error = *on
650aAC                   eval      *in23 = *on
650aAC                   eval      *in03 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   eval      erfld = 'Speak Trailer ID'
650aAC                   exsr      zm1005
650aAC                   endif
650aA*
650aAC                   if        w1tlid = ' '
650aAC                   eval      error = *on
650aAC                   eval      *in23 = *on
650aAC                   eval      *in03 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   eval      erfld = 'Speak Trailer ID'
650aAC                   exsr      zm0203
650aAC                   endif
650aA*
650aA*
650aA*  Verify speak row/column to user
650aA*
650aAC                   if        w1rwcl <> 'Y' and
650aAC                             w1rwcl <> 'N' and
650aAC                             w1rwcl <> ' '
650aAC                   eval      error = *on
650aAC                   eval      *in24 = *on
650aAC                   eval      *in04 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   eval      erfld = 'Speak Row/Column'
650aAC                   exsr      zm1005
650aAC                   endif
650aA*
650aAC                   if        w1rwcl = ' '
650aAC                   eval      error = *on
650aAC                   eval      *in24 = *on
650aAC                   eval      *in04 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   eval      erfld = 'Speak Row/Column'
650aAC                   exsr      zm0203
650aAC                   endif
650aA*
650aA*
650aA*  Verify pallet position on trailer
650aA*
650aAC                   if        w1vypl <> 'Y' and
650aAC                             w1vypl <> 'N' and
650aAC                             w1vypl <> ' '
650aAC                   eval      error = *on
650aAC                   eval      *in25 = *on
650aAC                   eval      *in05 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   eval      erfld = 'Verify pallet position'
650aAC                   exsr      zm1005
650aAC                   endif
650aA*
650aAC                   if        w1vypl = ' '
650aAC                   eval      error = *on
650aAC                   eval      *in25 = *on
650aAC                   eval      *in05 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   eval      erfld = 'Verify pallet position'
650aAC                   exsr      zm0203
650aAC                   endif
650aA*
650bA*  Verify pallet label against pick label
650bA*
650bAC                   if        w1vfyp <> 'Y' and
650bAC                             w1vfyp <> 'N'
650bAC                   eval      error = *on
650bAC                   eval      *in27 = *on
650bAC                   eval      *in07 = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      erfld = 'Verify pallet lbl'
650bAC                   exsr      zm1005
650bAC                   endif
650bA*
700aA*  Verify auto define add-on routes
700aA*
700aAC                   if        w1addo <> 'Y' and
700aAC                             w1addo <> 'N'
700aAC                   eval      error = *on
700aAC                   eval      *in28 = *on
700aAC                   eval      *in08 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   eval      erfld = 'Auto define add-on routes'
700aAC                   exsr      zm1005
700aAC                   endif
700aA*
700bA*  Verify Load Equip by zone
700bA*
700bAC                   if        w1eqip <> 'Y' and
700bAC                             w1eqip <> 'N'
700bAC                   eval      error = *on
700bAC                   eval      *in29 = *on
700bAC                   eval      *in09 = *on
700bAC                   eval      errmsg = *blanks
700bAC                   eval      erfld = 'Load Equip by zone'
700bAC                   exsr      zm1005
700bAC                   endif
700bA*
700bA*  Verify Bypass qty loading equipment
700bA*
700bAC                   if        w1bypl <> 'Y' and
700bAC                             w1bypl <> 'N'
700bAC                   eval      error = *on
700bAC                   eval      *in30 = *on
700bAC                   eval      *in10 = *on
700bAC                   eval      errmsg = *blanks
700bAC                   eval      erfld = 'Bypass qty loading equip'
700bAC                   exsr      zm1005
700bAC                   endif
700bA*
700bA*  Verify Bypass qty returning equipment
700bA*
700bAC                   if        w1bypr <> 'Y' and
700bAC                             w1bypr <> 'N'
700bAC                   eval      error = *on
700bAC                   eval      *in31 = *on
700bAC                   eval      *in11 = *on
700bAC                   eval      errmsg = *blanks
700bAC                   eval      erfld = 'Bypass qty returning equip'
700bAC                   exsr      zm1005
700bAC                   endif
700bA*
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      opsttm = 0
     C                   eval      opentm = 0
650aAC                   eval      opldor = '0'
650aAC                   eval      optlid = 'Y'
650aAC                   eval      oprwcl = 'Y'
650aAC                   eval      opvypl = 'Y'
650bAC                   eval      opvfyp = 'Y'
700aAC                   eval      opaddo = 'N'
700bAC                   eval      opeqip = 'N'
700bAC                   eval      opbypl = 'N'
700bAC                   eval      opbypr = 'N'
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1sttm = opsttm
     C                   eval      w1entm = opentm
650aAC                   eval      w1ldor = opldor
650aAC                   eval      w1tlid = optlid
650aAC                   eval      w1rwcl = oprwcl
650aAC                   eval      w1vypl = opvypl
650bAC                   eval      w1vfyp = opvfyp
700aAC                   eval      w1addo = opaddo
700bAC                   eval      w1eqip = opeqip
700bAC                   eval      w1bypl = opbypl
700bAC                   eval      w1bypr = opbypr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*LOADER'
     *
     C                   eval      tmpflg = *off
     *
     C     beggt1        tag
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
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
     C                   if        tmpflg = *off
     C                   eval      tmpflg = *on
     C                   exsr      zzdft1
     C                   write     record
     C                   goto      beggt1
     C                   else
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif
     C                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   eval      $lprg = #prog
     C                   exsr      scr01i
     *
     C     endin2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      opsttm = w1sttm
     C                   eval      opentm = w1entm
650aAC                   eval      opldor = w1ldor
650aAC                   eval      optlid = w1tlid
650aAC                   eval      oprwcl = w1rwcl
650aAC                   eval      opvypl = w1vypl
650bAC                   eval      opvfyp = w1vfyp
700aAC                   eval      opaddo = w1addo
700bAC                   eval      opeqip = w1eqip
700bAC                   eval      opbypl = w1bypl
700bAC                   eval      opbypr = w1bypr
     *
     *   Update record (it was read and locked in ZZGET1)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
     *
     C     endupd        endsr
