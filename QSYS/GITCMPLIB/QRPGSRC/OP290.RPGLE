      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OP290     PIR options - Item tracking options
     *  22 November 2002
     *  Max Blacknik
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    11/22/02  MLB  4.17
     *      - Created.
     *
417aA*    07/21/03  MLB  4.17a
     *      - Enh: Added new field OPTKSP - Track push back
     *        slot positions.
     *
500 A*    11/15/04  DAS  5.00
     *      - Enh: Converted to ILE.
     *      - Enh: Changed name to Item Tracking Options.
     *      - Enh: Moved default settings to new program OP295.
     *      - Enh: Removed general "License Tracking" option. Item record
     *        determines tracking. General option is not needed.
     *      - Enh: Added Item Tracking option to determine what happens to
     *        original license plate when splitting a quantity (OPSPLT).
     *      - Enh: Replaced *LICENSE data structure.
     *      - Enh: Removed second screen, which wasn't needed anymore.
     *      - Enh: Removed old Tracking Options logic for clarity.
     *
500aA*    01/13/05  DAS  5.00a
     *      - Enh: Added new transfer option (OPTSPL, W1TSPL).
     *      - Enh: Renamed OPSPLT/W1SPLT to OPPSPL/W1PSPL (putaway split).
     *
500bA*    01/25/05  DAS  5.00b
     *      - Enh: Limiting the allowable option values.
     *
600aA*    02/23/09  DAS  6.00a
     *      - Changed screen format to OP29001.
640aA*    12/14/11  RH   6.40a
     *      - If options are ' ', default to screen settings
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  92        UPDATE MODE - PROTECT SCREEN 1 FIELDS
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

600aDF*p290fm   cf   e             workstn
600aMFop29001   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Foptions   uf a e           k disk
     F                                     rename(oprec:record)

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

     *   Redefine key

     D  $pwhse                19     21  0

417eA*----------------------------------------------------------------
417eA*  *LICENSE  -  License Plate Tracking options
417eA*----------------------------------------------------------------
500 A*
500 A* Tracking Levels
500 A*
500 A*   Low     -  User is not asked for any extra info.
500 A*              All tracking is done in the background.
500 A*
500 A*   Medium  -  User may be asked to apply new license plate to
500 A*              a split quantity.
500 A*              Applying new license plate is optional.
500 A*
500 A*   High    -  User may be asked to apply new license plate to
500 A*              a split quantity.
500 A*              Applying new license plate is manditory.
500 A*              User may be asked to confirm license plate being
500 A*              used for task.
500 A*
500 A*----------------------------------------------------------------
500 A*
500 A* Split LP Quantity Options
500 A*
500aA*   This option comes into play when a user is putting a partial
500aA*   quantity into a slot. This could either be during Putaway,
500aA*   Replenishment or Transfer.
500aA*
500 A*   1  =  LP goes with first quantity put into a slot.
500 A*   2  =  LP goes with last quantity put into a slot.
500 A*   3  =  Ask user.
500 A*
500aA*----------------------------------------------------------------
500aA*
500aA* Split Transfer Quantity Options (OPTSPL)
500aA*
500aA*   This option comes into play when a user is doing a partial
500aA*   quantity transfer and will identify how to deal with the
500aA*   license plate for the quantity that stays in the From slot
500aA*   vs. the quantity that is being transfered.
500aA*
500aA*   1  =  LP stays with remaining quantity in From slot.
500aA*   2  =  LP goes with partial quantity being transfered.
500aA*   3  =  Ask user.
500aA*
500 A*----------------------------------------------------------------
417eA*
417eA* Fields
417eA*
500 M*    OPLPTR  -  Allow license plate tracking ** NOT USED **
500 M*    OPLPAL  -  Default for all other items (L,M,H).
500 M*    OPLPDS  -  Default for date sensitive items (L,M,H).
500 M*    OPLPLC  -  Default for lot code items (L,M,H).
500 M*    OPLPCW  -  Default for catchweight items (L,M,H).
500 D*    OPTKSP  -  Track push back slot positions *** REMOVED ***
500aM*    OPPSPL  -  Splitting Putaway quantity (see above)
500aA*    OPTSPL  -  Splitting Transfer quantity (see above)
417eA*
417eA* Data structure
417eA*
417eAD opdata          ds
417eAD  oplptr                 1      1
417eAD  oplpal                 2      2
417eAD  oplpds                 3      3
417eAD  oplplc                 4      4
417eAD  oplpcw                 5      5
500 D***                                     6   6 OPTKSP
500aMD  oppspl                 6      6
500aAD  optspl                 7      7
417eAD  optend               117    117

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

     *   Redefine key

     D  $lwhse                19     21  0

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50

     D  erfld1                 1     20
     D  erfld2                21     40
     D  erval1                41     45
     D  erval2                46     50
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

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
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new record.
     *              *CHANGE  - Update record.
     *              *VIEW    - View record.
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
     *
     C                   exsr      zzinz2
     *
     C                   if        error = *on
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
     *
     C                   return
     *
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
     C                   select
     C                   when      nxtscr = '01 '
     C                   exfmt     screen1                              50
     *
     C                   endsl
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
     *
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
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so prompt user to confirm changes.
     *
     C                   eval      nxtscr = 'EOJ'
     *
     C     endsc1        endsr
     *
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
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     *R                   MOVE #MSGK     $PMSG
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1057  License plate tracking = No. All others must be No.
     *
     C     zm1057        begsr
     C                   eval      #msgid = 'PIR1057'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1058  License plate tracking = Yes. At least one other must
     *            be Yes.
     *
     C     zm1058        begsr
     C                   eval      #msgid = 'PIR1058'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1059  Track all items = Yes. Date sensitive,lot tracking and
     *            catchweight items must be Yes.
     *
     C     zm1059        begsr
     C                   eval      #msgid = 'PIR1059'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR2101  Invalid value for field 1 because of field 2 value.
     *
     C     zm2101        begsr
     C                   eval      #msgid = 'PIR2101'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off

     *  Verify Putaway split option (1,2,3)

500aMC                   if        w1pspl <> '1'  and
500aMC                             w1pspl <> '2'  and
500aMC                             w1pspl <> '3'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = 'Putaway Split'
     C                   exsr      zm1005
     C                   endif
500bA
500bA*  Only allow option 2.
500bA
     C                   if        w1pspl <> '2'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = 'Only 2 allowed for '
     C                                    + 'Putaway Split in this release'
     C                   exsr      zm0105
     C                   endif
500aA
500aA*  Verify Transfer/Replenishment split option (1,2,3)
500aA
500aAC                   if        w1tspl <> '1'  and
500aAC                             w1tspl <> '2'  and
500aAC                             w1tspl <> '3'
500aAC                   eval      error = *on
500aAC                   eval      *in22 = *on
500aAC                   eval      *in02 = *on
500aAC                   eval      errmsg = *blanks
500aAC                   eval      errmsg = 'Tfr/Rpl Split'
500aAC                   exsr      zm1005
500aAC                   endif
500bA
500bA*  Only allow option 1.
500bA
     C                   if        w1tspl <> '1'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = 'Only 1 allowed for '
500aAC                                    + 'Tfr/Rpl Split in this release'
     C                   exsr      zm0105
     C                   endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '
     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif

     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZDFT1   Get default values for add.
     *----------------------------------------------------------------

     C     zzdft1        begsr

500aMC                   eval      oppspl = '2'
500aAC                   eval      optspl = '1'

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

640aAC                   if        oppspl = ' '
640aAC                   eval      oppspl = '2'
640aAC                   endif
640aAC                   if        optspl = ' '
640aAC                   eval      optspl = '1'
640aAC                   endif
500aMC                   eval      w1pspl = oppspl
500aAC                   eval      w1tspl = optspl

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGET1   Get record(s) for screen 1.
     *----------------------------------------------------------------

     C     zzget1        begsr

     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*LICENSE'

     C                   eval      tmpflg = *off

     C     beggt1        tag

     *   Get record from main file.

     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif

     *  Record locked.

     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt1
     C                   endif

     *  Record not found - Create it.

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

     C     endgt1        endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr

     *  Define key for main file.

     C     fileky        klist
     C                   kfld                    opwhse
     C                   kfld                    opcode

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

     *   Get and verify warehouse description.

     C                   eval      whcode = $pwhse
     C                   if        whcode = 0
     C                   eval      whdesc = *blanks
     C     'All ware'    cat       'houses':0    whdesc

     C                   else

     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lprg = $pprg
     C                   eval      $lwhse = whcode

     C                   call      'WH900'
     C                   parm                    $lparm

     C                   if        $lrtn = '*ERROR  '  or
     C                             $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      $prtn = $lrtn
     C                   eval      $perm = $lerm
     C                   goto      endin2

     C                   else
     C                   movel     $lerm         whdesc

     C                   endif
     C                   endif

     *   Select first screen to display.

     C                   eval      *in92 = *off
     C                   eval      $lprg = #prog
     C                   exsr      scr01i

     C     endin2        endsr

     *----------------------------------------------------------------
     *  ZZUPD1   Update record.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   eval      error = *off

     *  Move screen fields to record fields

500aMC                   eval      oppspl = w1pspl
500aAC                   eval      optspl = w1tspl

     *   Update record (it was read and locked in ZZGET1)

     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif

     C     endupd        endsr
