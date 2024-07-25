      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  CE222     UCI entry - Change
     *  19 October, 2007
     *  Hemant Kapadia
     *
     *
     *  Revisions
     *
PAka *  11/09/07 HNK PAka
     *  Don't allow to pick UCI with a pick status='Y'
     *
PAkb *  11/13/07 HNK PAkb
     *  Use indicator 78 instead of 79 in zzuci subroutine.
     *
650aA*    03/15/13  LMC  6.50a
     *      - Enh: Added CWLOG. This adds a call to a new program
     *        CW800 and new file CWLOG.
     *
     *
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
     Fce222fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fucicw     uf   e           k disk
     F                                     rename(ucirec:record)
     FLabel     if   e           k disk
     Fucicw10   if   e           k disk
     Fordhm     if   e           k disk
     Fordc1     uf a e           k disk
     Fpiritem   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             20    dim(1) ctdata perrcd(1)
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
     D  $pord                 22     28  0
     D  $pseq                 29     33  0
     D  $pitem                34     48
     D  $ptrn#                49     55  0
     D  $plbl#                56     62  0
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
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
650aA*----------------------------------------------------------------
650aA*  Prototypes
650aA*----------------------------------------------------------------
650aA /copy qcopysrc,p.cw800
650aA /copy qcopysrc,p.getuser
     *----------------------------------------------------------------
     *  Variables
     *
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
     D warn            s              1
     D wkseq           s              5  0
650aAD CWcmd           s             10
650aAD CWpgm           s             10
650aAD CWrtn           s             10
650aAD CWmsg           s             60
650aAD CWdata          s            512
650aAD processstatus   s             10
650aAD e$whse          s              3  0
650aAD e$emp#          s              5  0
650aAD e$fnam          s             15
650aAD e$init          s              1
650aAD e$lnam          s             20
650aAD e$whdp          s              5
650aAD e$styp          s              1
650aAD e$shft          s              6
650aAD e$crew          s              6
650aAD e$nhrs          s              3  1
650aAD e$rtn           s              8
650aAD e$bpu           s              1
650aAD e$lng           s              2
     *----------------------------------------------------------------
     *  SAP Header Misc. File data structures
     *
      /copy qcopysrc,ordhm1_pak
650aA*----------------------------------------------------------------
650aA*  Data Formats
650aA*----------------------------------------------------------------
650aA /COPY *libl/qcopysrc,C#CWLOG
650aAD savever#        s                   like($cwver#)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new record.
     *              *EDIT    - Edit record.
     *              *DELETE  - Delete record.
     *              *PRINT   - Print record edit listing.
     *              *POST    - Post record.
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
     *  Everything went fine display the screen again for next UCI.
     *
     C                   exsr      scr01i
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
650aA /free
650aA    getUser(#user: e$whse: e$emp#: e$fnam: e$init: e$lnam:
650aA            e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
650aA            e$bpu: e$lng);
650aA /end-free
     C                   endsr
650aA*----------------------------------------------------------------
650aA*  clrCWLog     Clear $cwlog   data structure fields
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr ClrCWLog;

650aA     savever# = $cwver#;
650aA     clear $cwlog;
650aA     $cwver# = savever#;
650aA     $cwaddemp = e$emp#;
650aA     $cwaddusr = #user;
650aA     $cwaddpgm  = #prog;
650aA     $cwaddjob  = #job;
650aA     $cwaddnbr = #jobn;

650aA   endsr;
650aA /end-free

650aA*----------------------------------------------------------------
650aA*  ProcessCWLog  Process the CWLOG file Add/Update/Delete
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr processCWlog;
650aA     exsr clrCWLog;
650aA     $cwwhse = ocwhse;
650aA     $cwitem = ocitem;
650aA     $cwseltrn# = octran;
650aA     $cwsellbl# = oclbl#;
650aA     $cwselord  = ocord;
650aA     $cwselseq  = ocseq#;
650aA     $cwselcseq = ocseq;
650aA     $cwwgtlbs = occwgt;
650aA     $cwentflg = 3;

650aA     cwdata = $cwlog;
650aA     cw800(processstatus: cwpgm: cwrtn: cwmsg: cwdata);

650aA     $cwlog = cwdata;

650aA   endsr;
650aA /end-free
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
     *   CE22201  UCI is for different item.
     *
     C     zm22201       begsr
     C                   eval      #msgid = 'CE22201'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   CE22202  Number of UCI exceeds qty picked.
     *
     C     zm22202       begsr
     C                   eval      #msgid = 'CE22202'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   CE22203  UCI already scanned for this transaction.
     *
     C     zm22203       begsr
     C                   eval      #msgid = 'CE22203'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
PAKa *   CE22204  UCI already picked.
     *
PAKa C     zm22204       begsr
     C                   eval      #msgid = 'CE22204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
PAKa C                   endsr
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     *
     *    Make sure code was entered.
     *
     C                   if        w1uci = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm01
     C                   endif
     *
     *    Validate UCI
     *
     *  UCI not found.
     C     ucikey        chain(n)  record                             79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm02
     C                   endif
     * UCI entered is for different item.
     C                   if        not *in79  and
     C                             uciitm <> $pitem
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm22201
     C                   endif
     * UCI entered is already scanned for this transaction.
     C                   if        not *in79  and
PAKa C                             ucipkt = $ptrn#
PAKa C****                         ucilbl = $plbl#
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm22203
     C                   endif
PAKa * UCI entered is already picked.
PAKa C                   if        not *in79  and
PAKa C                             ucipck = 'Y'
PAKa C                   eval      error = *on
PAka C                   eval      *in21 = *on
PAKa C                   exsr      zm22204
PAKa C                   endif
PAKa * UCI entered is already picked.
PAKa C                   if        not *in79  and
PAKa C                             ucipck = 'Y' and ucists = 'N' and
PAKa C                             ucipkt <> $ptrn# and $pitem=uciitm
PAKa C                   eval      error = *on
PAka C                   eval      *in21 = *on
PAKa C                   exsr      zm22204
PAKa C                   endif
     * UCI count exceeds quantity.
     C                   exsr      zzuci
     C                   if        w1cnt>=lbqpck
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm22202
     C                   endif
     *
     C                   endif
     *
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
     C     $plbl#        chain     label                              79
     C                   if        not *in79
     C                   eval      w1item = lbitem
     C                   eval      w1lbl# = lblbl#
     C                   eval      w1trn# = lbtrn#
     C                   eval      w1qpck = lbqpck
     C                   else
     C                   movel     '*NONE'       w1item
     C                   eval      w1lbl# = 0
     C                   eval      w1trn# = 0
     C                   eval      w1qpck = 0
     C                   endif
     * Get item desc.
     C     itkey         chain     piritem
     C                   if        %found(piritem)
     C                   eval      w1desc=itdesc
     C                   else
     C                   eval      w1desc=*blanks
     C                   endif
     *
     C                   eval      w1uci = *blanks
     C                   exsr      zzuci
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C     $plbl#        chain     label                              79
     C                   if        not *in79
     C                   eval      w1item = lbitem
     C                   eval      w1lbl# = lblbl#
     C                   eval      w1trn# = lbtrn#
     C                   eval      w1qpck = lbqpck
     C                   else
     C                   movel     '*NONE'       w1item
     C                   eval      w1lbl# = 0
     C                   eval      w1trn# = 0
     C                   eval      w1qpck = 0
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C                   endif
     *
     *  Record locked.
     *
     *
     *  Record not found.
     *
     *
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $plbl#
     *
     *  Define key for UCICW file.
     *
     C     ucikey        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1uci
     *
     *  Define key for UCICW10 file.
     *
     C     ucik10        klist
     C                   kfld                    $pwhse
     C                   kfld                    $plbl#
     *
     *  Define key for ORDHM file.
     *
     C     ordmky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pord
     *
     *  Define key to get last sequence number assigned per the label
     C     ordkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $plbl#
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     C                   eval      forevr = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
     C                   eval      w1uci = *blanks
     C                   endif
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  zzseq    Get last sequence number.
     *
     C     zzseq         begsr
     *  get last sequence scanned from ordc
     C     ordkey        setgt     ordc1
     C                   readp(n)  ordc1                                  77
     C                   if        *in77 = *off and oclbl# = $plbl#
     C                   eval      wkseq = ocseq
     C                   else
     C                   eval      wkseq = 0
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  zzuci    Count UCI's entered.
     *
     C     zzuci         begsr
     *
     C                   eval      w1cnt=0
     C     ucik10        setll     ucicw10
     C                   dow       forevr = forevr
PAKb C     ucik10        reade     ucicw10                                78
PAKb C                   if        *in78 = *on
     C                   leave
     C                   else
     C                   eval      w1cnt = w1cnt+1
     C                   endif
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     *
     *   Add record
     *
     C                   if        $pcmd = '*ADD    '
     *
     C                   exsr      zzseq
     *
     C     ordmky        chain     ordhm
     C                   if        %found(ordhm)
     C                   eval      pakhm1_base = hmmsc1
     C                   endif
     *
     C     ucikey        chain     record                             79
     C                   if        not *in79  and
     C                             uciitm = $pitem
     C                   eval      ucists = 'N'
     C                   eval      ucipck = 'Y'
     C                   eval      ucipkt = $ptrn#
     C                   eval      ucilbl = $plbl#
     C                   eval      ucirtt = 0
     C                   eval      ucisqo = $pseq
     C                   eval      uciout = pakhm1_vblen
     C                   eval      ucisq2 = wkseq+1
     C                   update    record
     C                   endif
     *
     * Add record to ORDC file.
     *
     C                   eval      ocwhse = $pwhse
     C                   eval      ocord  = $pord
     C                   eval      ocseq# = $pseq
     C                   eval      ocseq  = wkseq+1
     C                   eval      ocitem = $pitem
     C                   eval      occwgt = uciwgt
     C                   eval      octran = $ptrn#
     C                   eval      oclbl# = $plbl#
     C                   write     ocrec
650aAc                   eval      processstatus = '*ADD'
650aAc                   exsr      processCWLog
     *
     **                   ELSE
     *
     *
     C                   endif
     *
     C     endupd        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
UCI
