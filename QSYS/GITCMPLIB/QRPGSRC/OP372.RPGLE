500gA /COPY *libl/qcopysrc,hspecs
700aAH DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OP372     PIR options - Check digit entry
     *  12 June 2007
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    06/12/07  DAS  5.10
     *      - Created
700aA*    02/23/16  DLS  7.00a
     *      - Enh:  Added new file: OPTIONHST to record all changes
     *              to the OPTIONS file.
700b *    04/06/16  GJA  7.00b
     *      - Enh:  Changed OPHADDJOB and OPHADDNBR to match file
     *
     *----------------------------------------------------------------

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

700aA*----------------------------------------------------------------
700aA*  Binding Directories
700aA*----------------------------------------------------------------
700aAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fop372fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Foptions   uf a e           k disk
     F                                     rename(oprec:record)
700aAFoptionhst o    e           k disk

500lA*----------------------------------------------------------------
500lA*  Customer id
500lA*----------------------------------------------------------------
500lA
500lA /copy qcopysrc,id#bfctest
700aA /copy qcopysrc,p.bfcdteti

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

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcount         s              3p 0
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vcode          s              2
416aAD $vsys           s              1
510jA*----------------------------------------------------------------
510jA*  *CHKDGT  -  Check digit options.
510jA*----------------------------------------------------------------
510jA*
510jA* Fields
510jA*
510jA*    OPCOD#  -  Number of check digit codes per slot (1,2,3)
510jA*    OPDGT#  -  Number of digits per code  (2,3)
510jA*    OPIDC1  -  Code 1 identifier
510jA*    OPIDC2  -  Code 2 identifier
510jA*    OPUNU2  -  Unused
510jA*    OPIDC3  -  Code 3 identifier
510jA*    OPUNU3  -  Unused
510jA*    OPIDD1  -  Digit 1 identifier
510jA*    OPIDD2  -  Digit 2 identifier
510jA*    OPIDD3  -  Digit 3 identifier
510jA*    OPRCOD  -  Current code to read (S=Single,R=Random)
510jA*    OPRCD1  -  Use code 1 for current reading (Y,N)
510jA*    OPRCD2  -  Use code 2 for current reading (Y,N)
510jA*    OPRCD3  -  Use code 3 for current reading (Y,N)
510jA*    OPRORD  -  Current read order (S=Single, R=Random)
510jA*    OPRLCR  -  Use read order Left/Center/Right (Y,N)
510jA*    OPRRCL  -  Use read order Right/Center/Left (Y,N)
510jA*    OPRLRC  -  Use read order Left/Right/Center (Y,N)
510jA*    OPRRLC  -  Use read order Right/Left/Center (Y,N)
510jA*    OPRCLR  -  Use read order Cener/Left/Right  (Y,N)
510jA*    OPRCRL  -  Use read order Cener/Right/Left  (Y,N)
510jA*
510jA* Data structure
510jA*
510jAD opdata          ds
510jAD  opcod#                 1      1  0
510jAD  opdgt#                 2      2  0
510jAD  opidc1                 3      8
510jAD  opidc2                 9     14
510jAD  opunu2                15     16
510jAD  opidc3                17     22
510jAD  opunu3                23     24
510jAD  opidd1                25     30
510jAD  opidd2                31     36
510jAD  opidd3                37     42
510jAD  oprcod                43     43
510jAD  oprcd1                44     44
510jAD  oprcd2                45     45
510jAD  oprcd3                46     46
510jAD  oprord                47     47
510jAD  oprlcr                48     48
510jAD  oprrcl                49     49
510jAD  oprlrc                50     50
510jAD  oprrlc                51     51
510jAD  oprclr                52     52
510jAD  oprcrl                53     53
510jAD  optend               117    117

700aA*----------------------------------------------------------------
700aA*  OPDATA before data structure
700aA*----------------------------------------------------------------
700aAd opdataBefore    ds                  likeds(opdata)

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
     D  $lcode                19     20

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
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
     *  Misc variables created by RPG4MAX.
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D count           s              5  0
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

700aA*----------------------------------------------------------------
700aA*  Time variables
700aA*----------------------------------------------------------------

700aAD CurrStamploc    s               z
700aAD CurrStampsys    s               z
700aAD CurrStampuc     s               z
700aAD bfcoffset       s              3  0 inz(0)
700aAD ucOffset        s              3  0

700aA*----------------------------------------------------------------
700aA*  Sub-procedure prototypes
700aA*----------------------------------------------------------------
700aAd GetCurrStamp    pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new record.
     *              *EDIT    - Edit record.
     *              *PRINT   - Print record.
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
500lA
500lA* Get client id.
500lA
500lAC                   call      'GETCLIENT'
500lAC                   parm                    client           10
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
     *   OP16021  Passwords do not match.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'OP16021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
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
500aA*----------------------------------------------------------------
500aA*   PIR1013  Pick Runner pick list on label must be '0','1','2'.
500aA*
500aAC     zm1013        begsr
500aAC                   eval      #msgid = 'PIR1013'
500aAC                   eval      #msgtp = '*DIAG  '
500aAC                   movea     errmsg        $md
500aAC                   exsr      zmpmsg
500aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off

     *  Verify digit entry method

     C                   if        w1rord <> 'S'
     C                             and w1rord <> 'R'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'Invalid digit entry method'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *  Random digit order allowed on a client by client basis.
     *  Re: Voice task must be revised to inform user what code to use.

     C                   if        client <> bfctest
     C                   if        w1rord = 'R'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'Only S allowed. Voice task '
     C                                    + 'must be changed first.'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   endif

     *  Verify code to read

     C                   if        w1rcod <> 'S'
     C                             and w1rcod <> 'R'
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = 'Invalid code to read'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *  Random code to read allowed on a client by client basis.
     *  Re: Voice task must be revised to inform user what code to use.

     C                   if        client <> bfctest
     C                   if        w1rcod = 'R'
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = 'Only S allowed. Voice task '
     C                                    + 'must be changed first.'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   endif

     *  Verify Y/N digit options and count number of Y's

     C                   eval      count = 0

     C                   if        w1lcr = 'Y'
     C                   eval      count = count + 1
     C                   else
     C                   if        w1lcr <> 'N'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = 'Invalid option enterd for '
     C                                    + wolcr
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   endif

     C                   if        w1rcl = 'Y'
     C                   eval      count = count + 1
     C                   else
     C                   if        w1rcl <> 'N'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = 'Invalid option enterd for '
     C                                    + worcl
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   endif

     C                   if        w1lrc = 'Y'
     C                   eval      count = count + 1
     C                   else
     C                   if        w1lrc <> 'N'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = 'Invalid option enterd for '
     C                                    + wolrc
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   endif

     C                   if        w1rlc = 'Y'
     C                   eval      count = count + 1
     C                   else
     C                   if        w1rlc <> 'N'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = 'Invalid option enterd for '
     C                                    + worlc
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   endif

     C                   if        w1clr = 'Y'
     C                   eval      count = count + 1
     C                   else
     C                   if        w1clr <> 'N'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = 'Invalid option enterd for '
     C                                    + woclr
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   endif

     C                   if        w1crl = 'Y'
     C                   eval      count = count + 1
     C                   else
     C                   if        w1crl <> 'N'
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = 'Invalid option enterd for '
     C                                    + wocrl
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   endif

     *  Verify no more than 1 digit option is yes for Single.

     C                   if        w1rord = 'S'
     C                             and count > 1
     C                   eval      error = *on
     C                   if        w1lcr = 'Y'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif
     C                   if        w1rcl = 'Y'
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif
     C                   if        w1lrc = 'Y'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif
     C                   if        w1rlc = 'Y'
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif
     C                   if        w1clr = 'Y'
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif
     C                   if        w1crl = 'Y'
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   endif
     C                   eval      errmsg = 'No more than 1 digit method '
     C                                    + 'can be selected'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *  Verify at least 1 digit option is yes for Single.

     C                   if        w1rord = 'S'
     C                             and count < 1
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = 'At least 1 digit method '
     C                                    + 'must be entered'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *  Verify at least 2 digit options are yes for Random.

     C                   if        w1rord = 'R'
     C                             and count < 2
     C                   eval      error = *on
     C                   if        w1lcr <>'Y'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif
     C                   if        w1rcl <>'Y'
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif
     C                   if        w1lrc <>'Y'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif
     C                   if        w1rlc <>'Y'
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif
     C                   if        w1clr <>'Y'
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif
     C                   if        w1crl <>'Y'
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   endif
     C                   eval      errmsg = 'At least 2 digit methods '
     C                                    + 'must be entered'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *  Verify Y/N code options

     C                   eval      count = 0

     C                   if        w1rcd1 = 'Y'
     C                   eval      count = count + 1
     C                   else
     C                   if        w1rcd1 <> 'N'
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = 'Invalid option enterd for '
     C                                    + worcd1
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   endif

     C                   if        w1rcd2 = 'Y'
     C                   eval      count = count + 1
     C                   else
     C                   if        w1rcd2 <> 'N'
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   eval      errmsg = 'Invalid option enterd for '
     C                                    + worcd2
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   endif

     C                   if        w1rcd3 = 'Y'
     C                   eval      count = count + 1
     C                   else
     C                   if        w1rcd3 <> 'N'
     C                   eval      error = *on
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   eval      errmsg = 'Invalid option enterd for '
     C                                    + worcd3
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   endif

     *  Verify no more than 1 code option is yes for Single.

     C                   if        w1rcod = 'S'
     C                             and count > 1
     C                   eval      error = *on
     C                   if        w1rcd1='Y'
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   endif
     C                   if        w1rcd2='Y'
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   endif
     C                   if        w1rcd3='Y'
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   endif
     C                   eval      errmsg = 'No more than 1 code '
     C                                    + 'can be selected'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *  Verify at least 1 code option is yes for Single.

     C                   if        w1rcod = 'S'
     C                             and count < 1
     C                   eval      error = *on
     C                   if        w1rcd1<>'Y'
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   endif
     C                   if        w1rcd2<>'Y'
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   endif
     C                   if        w1rcd3<>'Y'
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   endif
     C                   eval      errmsg = 'At least 1 code '
     C                                    + 'must be entered'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *  Verify at least 2 digit options are yes for Random.

     C                   if        w1rcod = 'R'
     C                             and count < 2
     C                   eval      error = *on
     C                   if        w1rcd1<>'Y'
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   endif
     C                   if        w1rcd2<>'Y'
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   endif
     C                   if        w1rcd3<>'Y'
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   endif
     C                   eval      errmsg = 'At least 2 codes '
     C                                    + 'must be entered'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif


     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      opcod# = 1
     C                   eval      opdgt# = 2
     C                   eval      opidc1 = ' '
     C                   eval      opidc2 = ' '
     C                   eval      opidc3 = ' '
     C                   eval      opidd1 = ' '
     C                   eval      opidd2 = ' '
     C                   eval      opidd3 = ' '
     C                   eval      oprcod = 'S'
     C                   eval      oprcd1 = 'Y'
     C                   eval      oprcd2 = 'N'
     C                   eval      oprcd3 = 'N'
     C                   eval      oprord = 'S'
     C                   eval      oprlcr = 'Y'
     C                   eval      oprrcl = 'N'
     C                   eval      oprlrc = 'N'
     C                   eval      oprrlc = 'N'
     C                   eval      oprclr = 'N'
     C                   eval      oprcrl = 'N'
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr

     C                   eval      w1rord = oprord
     C                   eval      w1rcod = oprcod

     *  Digit fields

     C                   select

     *    When only 2 digits are used.

     C                   when      opdgt# = 2
     C                   eval      *in81 = *on
     C                   eval      wolcr = %trim(opidd1) + '-'
     C                                   + %trim(opidd2)
     C                   eval      w1lcr = oprlcr
     C                   eval      worcl = %trim(opidd2) + '-'
     C                                   + %trim(opidd1)
     C                   eval      w1rcl = oprrcl
     C                   eval      wolrc = ' '
     C                   eval      w1lrc = 'N'
     C                   eval      worlc = ' '
     C                   eval      w1rlc = 'N'
     C                   eval      woclr = ' '
     C                   eval      w1clr = 'N'
     C                   eval      wocrl = ' '
     C                   eval      w1crl = 'N'

     C                   when      opdgt# = 3
     C                   eval      *in81 = *off
     C                   eval      wolcr = %trim(opidd1) + '-'
     C                                   + %trim(opidd2) + '-'
     C                                   + %trim(opidd3)
     C                   eval      w1lcr = oprlcr
     C                   eval      worcl = %trim(opidd3) + '-'
     C                                   + %trim(opidd2) + '-'
     C                                   + %trim(opidd1)
     C                   eval      w1rcl = oprrcl
     C                   eval      wolrc = %trim(opidd1) + '-'
     C                                   + %trim(opidd3) + '-'
     C                                   + %trim(opidd2)
     C                   eval      w1lrc = oprlrc
     C                   eval      worlc = %trim(opidd3) + '-'
     C                                   + %trim(opidd1) + '-'
     C                                   + %trim(opidd2)
     C                   eval      w1rlc = oprrlc
     C                   eval      woclr = %trim(opidd2) + '-'
     C                                   + %trim(opidd1) + '-'
     C                                   + %trim(opidd3)
     C                   eval      w1clr = oprclr
     C                   eval      wocrl = %trim(opidd2) + '-'
     C                                   + %trim(opidd3) + '-'
     C                                   + %trim(opidd1)
     C                   eval      w1crl = oprcrl

     C                   endsl

     *  Code fields

     C                   select

     *    When only 1 code is used.

     C                   when      opcod# = 1
     C                   eval      *in82 = *on
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     C                   eval      w1rcod = 'S'
     C                   eval      worcd1 = ' '
     C                   eval      w1rcd1 = 'Y'
     C                   eval      worcd2 = ' '
     C                   eval      w1rcd2 = 'N'
     C                   eval      worcd3 = ' '
     C                   eval      w1rcd3 = 'N'

     *    When 2 codes are used.

     C                   when      opcod# = 2
     C                   eval      *in82 = *off
     C                   eval      *in83 = *off
     C                   eval      *in84 = *on
     C                   eval      worcd1 = %trim(opidc1)
     C                                    + ' check digit code'
     C                   eval      w1rcd1 = oprcd1
     C                   eval      worcd2 = %trim(opidc2)
     C                                    + ' check digit code'
     C                   eval      w1rcd2 = oprcd2
     C                   eval      worcd3 = ' '
     C                   eval      w1rcd3 = 'N'

     *    When 3 codes are used.

     C                   when      opcod# = 3
     C                   eval      *in82 = *off
     C                   eval      *in83 = *off
     C                   eval      *in84 = *off
     C                   eval      worcd1 = %trim(opidc1)
     C                                    + ' check digit code'
     C                   eval      w1rcd1 = oprcd1
     C                   eval      worcd2 = %trim(opidc2)
     C                                    + ' check digit code'
     C                   eval      w1rcd2 = oprcd2
     C                   eval      worcd3 = %trim(opidc3)
     C                                    + ' check digit code'
     C                   eval      w1rcd3 = oprcd3

     C                   endsl

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*CHKDGT'
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
700aA*  Save initial values. Any changes will be recorded in OPTIONHST
     *
700aA /free
700aA  clear opdataBefore;
700aA  if %found(OPTIONS);
700aA    opdataBefore = opdata;
700aA  endif;
700aA /end-free
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
     C                   exsr      scr01i
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
     C                   eval      oprord = w1rord
     C                   eval      oprlcr = w1lcr
     C                   eval      oprrcl = w1rcl
     C                   eval      oprlrc = w1lrc
     C                   eval      oprrlc = w1rlc
     C                   eval      oprclr = w1clr
     C                   eval      oprcrl = w1crl
     *
     C                   eval      oprcod = w1rcod
     C                   eval      oprcd1 = w1rcd1
     C                   eval      oprcd2 = w1rcd2
     C                   eval      oprcd3 = w1rcd3
     *
     *   Update record (it was read and locked in ZZGET1)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
700aA*
700aA*   Update OPTIONHST
700aA*
700aAC                   exsr      ZZUPDHST
     *
     C     endupd        endsr

700aA*----------------------------------------------------------------
700aA*  ZZUPDHST  Update OPTIONHST - Options History File
700aA*----------------------------------------------------------------

700aA /free
700aA  begsr ZZUPDHST;

700aA    // If any options changed then record in OPTIONHST
700aA    if opdataBefore <> opdata;
700aA      ophcode   = opcode;
700aA      ophfile   = 'S';
700aA      ophwhse   = opwhse;
700aA      ophwhdp   = *blanks;
700aA      ophcust   = *zeros;
700aA      ophtruk   = *blanks;
700aA      ophzone   = *blanks;
700aA      ophbfrdta = opdataBefore;
700aA      ophaftdta = opdata;

700aA      GetCurrStamp();
700aA      ophaddts = CurrStampSys;
700aA      ophadduc = CurrStampUC;

700aA      ophaddusr = #user;
700aA      //ophaddjob = #job;
700aA      //ophaddnbr = #jobn;
700bM      ophaddjjob = #job;
700bM      ophaddjnbr = #jobn;

700aA      write ophrec;
700aA    endif;
700aA  endsr;
700aA /end-free

700aA*----------------------------------------------------------------
700aA*  GetCurrStamp  Get current timestamps
700aA*----------------------------------------------------------------

700aAp GetCurrStamp    b
700aAd GetCurrStamp    pi

700aA /free

700aA    getmicrotime(currstampuc:currstampsys);
700aA    ucOffset = %diff(currstampuc: currstampsys: *HOURS);
700aA    currstamploc = currstampsys + %hours(bfcoffset);

700aA /end-free

700aAp GetCurrStamp    e

