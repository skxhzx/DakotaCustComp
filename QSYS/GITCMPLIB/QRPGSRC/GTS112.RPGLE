      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     F*
     F*  GTS112    Global Tomcat server maintenance - Change
     F*  22 February 2013
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
650 AF*    02/22/13  DAS  6.50
     F*      - Created
     F*
700aAF*    05/15/15  DAS  7.00a
     F*      - Added *COPY
     F*
700bAF*    08/28/15  DAS  7.00b
     F*      - Added cluster and debug
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  01 - 20   Field position to
     F*  21 - 40   Field input error (reverse display)
     F*  90        View mode (Protect input fields)
     F*  91        Change mode (protect key)
     F*  97        Error message subfile indicator
     F*  98        Error on screen (sound buzzer)
     F*  99        Universal record indicator (very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     fgts112fm  cf   e             workstn
     f                                     infds(infds)
     f                                     sfile(msgrec:msgk)
     fglotomsrv uf a e           k disk
     f                                     rename(gtsrec:record)
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     d a10             s              1    dim(10)
     d desc            s             20    dim(1) ctdata perrcd(1)
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
     d $parms          ds
     d  $pcmd                  1      8
     d  $pprg                  9     18
     d  $puky                 19     68
     d  $prtn                 69     76
     d  $perm                 77    136
     d  $pmsg                 77     80
     D*
     D*   Redefine key
     D*
     d  $pcode                19     28
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     d @cvtdt          c                   const('CVTDTE')
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     d $cvtdt          ds
     d  $cvdop                 1      8
     d  $cvdd6                 9     14  0
     d  $cvdd8                15     22  0
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     d $mdt            ds
     d  errmsg                 1     50
     D*
     d  erpo#                  1      5p 0
     d  eritem                 6     20
     d                 ds
     d  $ec                    1      2p 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     d #msgf           c                   const('PIRMSGF   ')
     D*
     d                 ds
     d  #msgdt                 1    128
     d  $md                    1    128
     d                                     dim(128)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
     D*----------------------------------------------------------------
     D*  Workstation exception data structure
     D*
     d infds           ds
     d  status           *status
     d  rowin                370    370
     d  colin                371    371
     D*----------------------------------------------------------------
     D*  Workstation exception redefinition data structure
     D*
     d                 ds
     d  row#                   1      2b 0
     d  row                    2      2
     d  col#                   3      4b 0
     d  col                    4      4
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PCMD   *ADD     - Create new batch.
700aAC*              *COPY    - Copy batch.
     C*              *EDIT    - Edit batch.
     C*              *DELETE  - Delete batch.
     C*              *PRINT   - Print batch edit listing.
     C*              *POST    - Post batch.
     C*      $PPRG   Program to send messages back to.
     C*      $PUKY   Contains key for everything by *ADD.
     C*
     C*    Returned Parameters
     C*      $PUKY   Contains new batch number for *ADD.
     C*              Unchanged for everything else.
     C*      $PRTN   blank    - No problem encountered.
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
     C*      $PERM   Error message or pointer to message in pgmq.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     c     *entry        plist
     c                   parm                    $parms
     C*----------------------------------------------------------------
     C*  Main line
     C*
     c                   move      *on           *in97
     c                   move      *off          *in90
     c                   move      *off          *in91
     c                   move      *off          error
     c                   move      *blanks       $prtn
     c                   move      *blanks       $perm
     c                   exsr      zzinz2
     c     error         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   end
     C*
     c     nxtscr        downe     'EOJ'
     c                   exsr      dspscr
     c     nxtscr        caseq     '01 '         sc1
     c                   end
     c                   end
     C*
     C*   Do some clean up before leaving.
     C*
     c                   exsr      zsclr
     c                   return
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     c     dspscr        begsr
     C*
     C*   Set ON alarm indicator if error occured
     C*
     c     error         ifeq      *on
     c                   move      *on           *in98
     c                   end
     C*
     C*   Overlay screen with error messages
     C*
     c                   exsr      zmdmsg
     C*
     C*  Overlay screen with screen to be processed.
     C*
     c     nxtscr        ifeq      '01 '
     c                   exfmt     screen1                              50
     c                   end
     C*
     C*   Initialize error indicators and fields
     C*
416 Ac                   setoff                                       010203
510  c                   setoff                                       04
     c                   setoff                                       212223
     c                   setoff                                       242526
     c                   setoff                                       272829
     c                   setoff                                       30
     c                   setoff                                       98
     c                   move      *off          warn              1
     c                   move      *off          error             1
     c                   move      *off          cmdtkn            1
     c                   z-add     0             e                 2 0
     C*
     C*   Initialize error subfile
     C*
     c                   exsr      zmcmsg
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  Screen 01 initialization
     C*
     c     scr01i        begsr
     c                   move      '01 '         nxtscr            3
     C*
     C*  Get field defaults if this is an add.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   exsr      zzdft1
     c                   else
     C*
     C*  Otherwise get existing record(s).
     C*
700aAc                   if        $pcmd <> '*COPY'
     c                   move      *on           *in91
700aAc                   endif
     c                   exsr      zzget1
     c                   exsr      zzfil1
     c                   end
     c     end01i        endsr
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     c     sc1           begsr
     C*
     C*  Test for F3 - Exit
     C*
     c     *inkc         ifeq      *on
     c     *loval        setll     record
     c                   move      'EOJ'         nxtscr
     c                   move      '*EXIT   '    $prtn
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for F5 - Refresh
     C*
     c     *inke         ifeq      *on
     c     $pcmd         ifne      '*VIEW   '
     c                   exsr      scr01i
     c                   end
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for F12 - Previous
     C*
     c     *inkl         ifeq      *on
     c     *loval        setll     record
     c                   move      'EOJ'         nxtscr
     c                   move      '*CANCEL '    $prtn
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for other command keys
     C*
     c                   exsr      zzcmd1
     c     cmdtkn        cabeq     *on           endsc1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c     $pcmd         oreq      '*CHANGE '
700aAc     $pcmd         oreq      '*COPY'
     c                   exsr      zzchk1
     c     error         cabeq     *on           endsc1
     c                   exsr      zzupd
     c     error         cabeq     *on           endsc1
     c                   end
     c                   move      'EOJ'         nxtscr
     c     endsc1        endsr
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     c     *inzsr        begsr
     C*
     C*  Initialize special keys
     C*
     c                   z-add     0             enter             5 0
     c                   z-add     2             comand            5 0
     c                   z-add     01122         rollup            5 0
     c                   z-add     01123         rolldn            5 0
     c                   z-add     01124         clear             5 0
     c                   z-add     01125         help              5 0
     C*
     C*  Initialize message handling
     C*
     c                   exsr      zmimsg
     C*
     C*   Call user added initialization routine.
     C*
     c                   exsr      zzinz
     c                   endsr
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMCMSG  Clear message record subfile
     C*
     c     zmcmsg        begsr
     c                   move      *off          *in97
     c                   write     msgctl
     c                   z-add     *zero         msgk              4 0
     c                   write     msgclr
     c                   move      '*CLEAR '     #msgid            7
     c                   move      '*NULL  '     #msgtp            7
     c                   exsr      zmpmsg
     c                   endsr
     C*
     C*    ZMDMSG  Display message record subfile
     C*
     c     zmdmsg        begsr
     c                   move      *on           *in97
     c     msgk          ifgt      0
     c                   write     msgctl
     c                   z-add     *zero         msgk
     c                   end
     c                   endsr
     C*
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     c     zmimsg        begsr
     c                   move      #prog         #pgmq            10
     c                   exsr      zmcmsg
     c                   endsr
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     c     zmpmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm                    #pgmq
     c                   parm                    #msgk
     c     #msgid        ifne      '*CLEAR '
     c                   add       1             msgk
     c                   write     msgrec
     c                   end
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     C*
     C*    ZSCLR   Clear screen
     C*
     c     zsclr         begsr
     c                   write     clrscr
     c                   move      *on           sclear            1
     c                   endsr
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     c     zmsmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm      $pprg         #pgmq2           10
     c                   parm                    #msgk             4
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR0201  Code must be entered for create.
     C*
     c     zm01          begsr
     c                   move      'PIR0201'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     desc          errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR0202  Code already exists.
     C*
     c     zm02          begsr
     c                   move      'PIR0202'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     desc          errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     C*----------------------------------------------------------------
     C*   PIR7971  Error in writing a record.
     C*
     c     zm71          begsr
     c                   move      'PIR7971'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR7972  Error in updating a record.
     C*
     c     zm72          begsr
     c                   move      'PIR7972'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*     PIR7973  Slot record does not exist.
     C*
     c     zm73          begsr
     c                   move      'PIR7973'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
416 AC*----------------------------------------------------------------
416 AC*   PIR0105  Generic message.
416 AC*
416 Ac     zm0105        begsr
416 Ac                   move      'PIR0105'     #msgid
416 Ac                   move      '*DIAG  '     #msgtp
416 Ac                   movea     errmsg        $md(1)
416 Ac                   exsr      zmpmsg
416 Ac                   endsr
416 AC*----------------------------------------------------------------
416 AC*   PIR1001  Invalid value entered.
416 AC*
416 Ac     zm1001        begsr
416 Ac                   move      'PIR1001'     #msgid
416 Ac                   move      '*DIAG  '     #msgtp
416 Ac                   movea     errmsg        $md(1)
416 Ac                   exsr      zmpmsg
416 Ac                   endsr
     C*----------------------------------------------------------------
     C*     PIR7974  Slot record is locked.
     C*
     c     zm74          begsr
     c                   move      'PIR7974'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     c     zzchk1        begsr
     c                   move      *off          error
     C*
     C*  When adding ....
     C*
     c     $pcmd         ifeq      '*ADD    '
700aAc     $pcmd         oreq      '*COPY   '
     C*
     C*    Make sure code was entered.
     C*
     c     w1code        ifeq      *blanks
     c                   move      *on           error
     c                   move      *on           *in21
     c                   exsr      zm01
     c                   end
     C*
     C*    Make sure code doesn't already exist.
     C*
     c                   move      w1code        $pcode
     c     fileky        chain     record                             79
     c     *in79         ifeq      *off
     c                   move      *on           error
     c                   move      *on           *in21
     c                   exsr      zm02
     c                   end
     c                   end
700bA*
700bA*  Verify cluster option
700bA*
700bAC                   if        w1clstr <> 'Y'  and
700bAC                             w1clstr <> 'N'
700bAC                   eval      error = *on
700bAC                   eval      *in23 = *on
700bAC                   eval      *in03 = *on
700bAC                   eval      errmsg = 'Cluster'
700bAC                   exsr      zm1005
700bAC                   endif
700bA*
700bA*  Verify debug option
700bA*
700bAC                   if        w1debug <> 'Y'  and
700bAC                             w1debug <> 'N'
700bAC                   eval      error = *on
700bAC                   eval      *in24 = *on
700bAC                   eval      *in04 = *on
700bAC                   eval      errmsg = 'Debug'
700bAC                   exsr      zm1005
700bAC                   endif
      *
     c     endck1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     c     zzcmd1        begsr
     c     endcm1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZDFT1   Get default values for add.
     C*
     c     zzdft1        begsr
     c                   eval      w1code = ' '
     c                   eval      w1desc = ' '
700bAc                   eval      w1clstr = 'N'
700bAc                   eval      w1debug = 'N'
     c                   eval      w1port = 0
     c                   eval      w1user = ' '
     c                   eval      w1tompath = '/Tomcat'
     c                   eval      w1apploc  = ' '
     c                   eval      w1jdkpath = '/QOpenSys/QIBM/ProdData/JavaVM'
     c                                       + '/jdk60/32bit'
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     c     zzfil1        begsr
     c                   eval      w1code = gtscode
     c                   eval      w1desc = gtsdesc
700bAc                   eval      w1clstr = gtsclstr
700bAc                   eval      w1debug = gtsdebug
     c                   eval      w1port = gtsport
     c                   eval      w1user = gtsuser
     c                   eval      w1tompath = gtstompath
     c                   eval      w1apploc  = gtsapploc
     c                   eval      w1jdkpath = gtsjdkpath
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZGET1   Get record(s) for screen 1.
     C*
     c     zzget1        begsr
     C*
     C*   Get record from main file.
     C*
700aAc                   if        $pcmd = '*COPY'
700aAc     fileky        chain(n)  record                             7978
700aAc                   else
     c     fileky        chain     record                             7978
700aAc                   endif
     C*
     C*  Record locked.
     C*
     c     *in78         ifeq      *on
     c                   move      *on           error
     c                   move      '*PGMQ   '    $prtn
     c                   exsr      zm74
     c                   goto      endgt2
     c                   end
     C*
     C*  Record not found.
     C*
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   move      '*PGMQ   '    $prtn
     c                   exsr      zm73
     c                   goto      endgt2
     c                   end
     C*
     C*   If viewing, release record.
     C*
     c     $pcmd         ifeq      '*VIEW   '
     c                   move      *on           *in90
     c     *loval        setll     record
     c                   end
     c     endgt2        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr
     C*
     C*  Define key for main file.
     C*
     c     fileky        klist
     c                   kfld                    $pcode
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     c     zzinz2        begsr
     C*
     C*   Select first screen to display.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   move      *blanks       $pcode
     c                   end
     c                   exsr      scr01i
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD    Update record.
     C*
     c     zzupd         begsr
     c                   move      *off          error
     C*
     C*  Move screen fields to record fields
     C*
     c                   eval      gtscode = w1code
     c                   eval      gtsdesc = w1desc
700bAc                   eval      gtsclstr = w1clstr
700bAc                   eval      gtsdebug = w1debug
     c                   eval      gtsport = w1port
     c                   eval      gtsuser = w1user
     c                   eval      gtstompath = w1tompath
     c                   eval      gtsapploc  = w1apploc
     c                   eval      gtsjdkpath = w1jdkpath
     C*
     C*   Add record
     C*
     c     $pcmd         ifeq      '*ADD    '
700aAc     $pcmd         oreq      '*COPY   '
     c                   write     record                               79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm71
     c                   goto      endupd
     c                   end
     c                   else
     C*
     C*   -OR- Update record (it was read and locked in ZZGET2)
     C*
     c                   update    record                               79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm72
     c                   goto      endupd
     c                   end
     c                   end
     C*
     C*   Move key values to parameters
     C*
     c                   eval      $pcode = gtscode
     c     endupd        endsr
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Tomcat Server Code
