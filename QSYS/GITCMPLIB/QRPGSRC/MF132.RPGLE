      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     F*
     F*  MF132     Manufacturer code Items maintenance - Change
     F*  25 Sept 2007
     F*  Lynn McMahon
     F*
     F*  Revisions
     F*
     F*    09/25/07  LMC  5.10
     F*      - Created
510aAF*    10/02/07  LMC  5.10a
     F*      - Fix: Correct manufacturer field size to 11 positions
510bAF*    10/05/07  LMC  5.10b
     F*      - Enh: Allow User to stay on add screen
510cAF*    10/08/07  LMC  5.10c
     F*      - Enh: Allow User to enter upc or manufacturer item
530aAF*    11/04/09  RH   5.30a
     F*      - Fix: Move code to get MFR name to ZZINZ2, was not
     F*        getting name each time screen was displayed.
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
     fmf132fm   cf   e             workstn
     f                                     infds(infds)
     f                                     sfile(msgrec:msgk)
     fmfritem   uf a e           k disk
     f                                     rename(mfirec:record)
     fmfr       if   e           k disk
     fpiritem   if   e           k disk
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     d desc            s             20    dim(2) ctdata perrcd(1)
     D*
     d @getcl          c                   const('GETCLIENT')
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
510aDd* $pmfr#                19     28  0
510aDd* $pdef#                29     30  0
510aDd* $pmfritm              31     45
510aDd* $ppiritm              46     60
510aAd  $pmfr#                19     29  0
510aAd  $pdef#                30     31  0
510aAd  $pmfritm              32     46
510aAd  $ppiritm              47     61

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
     D  $litem                22     36
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
     *  Variables
     D M               s              3  0

     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PCMD   *ADD     - Create new batch.
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
     c                   setoff                                       010203
     c                   setoff                                       04
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
     c                   move      *on           *in91
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
     c                   exsr      zzchk1
     c     error         cabeq     *on           endsc1
     c                   exsr      zzupd
     c     error         cabeq     *on           endsc1
     c                   end
510bDc*                  move      'EOJ'         nxtscr
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
     C* Get client id.
     C*
     c                   call      @getcl
     c                   parm                    client           10
     C*
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
     c                   movel     desc(m)       errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR0202  Code already exists.
     C*
     c     zm02          begsr
     c                   move      'PIR0202'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movel     desc(m)       errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*    ZM03    Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR0203  field must be entered
     C*
     c     zm03          begsr
     c                   move      'PIR0203'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movel     desc(m)       errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   mf13201 mfr/dakota combination exist
     C*
     c     zm04          begsr
     c                   move      'MF13201'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movel     mfidd#        errmsg
     c                   movea     errmsg        $md
     c                   exsr      zmpmsg
     c                   move      #msgk         $pmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   mf13202 mfr item already exist
     C*
     c     zm05          begsr
     c                   move      'MF13202'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movel     mfidd#        errmsg
     c                   movea     errmsg        $md
     c                   exsr      zmpmsg
     c                   move      #msgk         $pmsg
     c                   endsr
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
     C*----------------------------------------------------------------
     C*   PIR0105  Generic message.
     C*
     c     zm0105        begsr
     c                   move      'PIR0105'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR1001  Invalid value entered.
     C*
     c     zm1001        begsr
     c                   move      'PIR1001'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
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
     C*
     C*    Make sure code was entered.
     C*
     c*    w1imit        ifeq      ' '
     c*                  move      *on           error
     c*                  move      *on           *in01
     c*                  move      *on           *in21
     c*                  eval      m = 1
     c*                  exsr      zm01
     c*                  goto      endck1
     c*                  end
     C*    Make sure manufacture item isn't already setup
     C*
     c*    partky        chain     record                             79
     c*    *in79         ifeq      *off
     c*                  move      *on           error
     c*                  move      *on           *in21
     c*                  move      *on           *in01
     c*                  exsr      zm05
     c*                  goto      endck1
     c*                  end

     c     w1idit        ifeq      ' '
510bDc*                  eval      $lcmd = '*SELECT'
510bDC*                  eval      $lwhse = e$whse
510bDC*                  eval      $litem = w1idit
510bDc*                  eval      $lprg  = #prog
510bDC*                  call      'IT900'
510bDC*                  parm                    $lparm
      *
510bDc*                  eval      w1idit = $LITEM
     c                   if        w1idit = ' '
     c                   move      *on           error
     c                   move      *on           *in02
     c                   move      *on           *in22
     c                   eval      m = 2
     c                   exsr      zm01
     c                   goto      endck1
     c                   end
     c                   end
     C
     C*    Make sure code doesn't already exist.
     C*
     c     fileky1       chain     record                             79
     c     *in79         ifeq      *off
     c                   move      *on           error
     c                   move      *on           *in21
     c                   move      *on           *in01
     c                   move      *on           *in22
     c                   exsr      zm04
     c                   goto      endck1
     c                   end
     *
     *  Verify dakota item number.
     *
     C                   if        w1idit <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = e$whse
     C                   eval      $litem = w1idit
     c                   eval      $lprg  = #prog
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     c                   move      *on           error
     c                   move      *on           *in02
     c                   move      *on           *in22
     c                   eval      m = 2
     c                   exsr      zm01
     C                   goto      endck1
     C                   endif
     C*                  eval      kyitem = w2item
     C                   endif
     c                   end
      *
     c     endck1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     c     zzcmd1        begsr
      * lookup dakota item
     c                   If        *inkd = '1'
     c                   eval      $lcmd = '*SELECT'
     C                   eval      $lwhse = e$whse
     C                   eval      $litem = w1idit
     c                   eval      $lprg  = #prog
     C                   call      'IT900'
     C                   parm                    $lparm
      *
     c                   eval      w1idit = $LITEM
     c                   eval      cmdtkn = *on
     c                   endif
     c     endcm1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZDFT1   Get default values for add.
     C*
     c     zzdft1        begsr
     c                   eval      mfimf# = $pmfr#
     c                   eval      w1idd# = $pdef#
     c                   eval      w1imit = ' '
     c                   eval      w1idit = ' '
510cAc                   eval      w1upc  = ' '
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     c     zzfil1        begsr
     c                   eval      w1idd# = mfidd#
     c                   eval      w1imit = mfimit
     c                   eval      w1idit = mfidit
510cAc                   eval      w1upc  = mfiupc
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZGET1   Get record(s) for screen 1.
     C*
     c     zzget1        begsr
     C*
     C*   Get record from main file.
     C*
     c     fileky        chain     record                             7978
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

530a C*  Following code moved to ZZINZ2
530aDc*    $pmfr#        chain     mfr
530aDc*                  If        not %found
530aDc*                  eval      mfname = *blanks
530aDc*                  endif
     C*
     C*  Define key for main file.
     C*
     c     fileky        klist
     c                   kfld                    mfimf#
     c                   kfld                    mfimit
     c                   kfld                    mfidit
     c     fileky1       klist
     c                   kfld                    mfimf#
     c                   kfld                    w1imit
     c                   kfld                    w1idit
     c     partky        klist
     c                   kfld                    mfimf#
     c                   kfld                    w1imit
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     c     zzinz2        begsr
530aAc     $pmfr#        chain     mfr
530aAc                   If        not %found
530aAc                   eval      mfname = *blanks
530aAc                   endif
501uA * Get employee options.
501uA *
501uAC                   call      'GETUSER'
501uAC                   parm      #user         e$code           10
501uAC                   parm                    e$whse            3 0
501uAC                   parm                    e$emp#            5 0
501uAC                   parm                    e$fnam           15
501uAC                   parm                    e$init            1
501uAC                   parm                    e$lnam           20
501uAC                   parm                    e$whdp            5
501uAC                   parm                    e$styp            1
501uAC                   parm                    e$shft            6
501uAC                   parm                    e$crew            6
501uAC                   parm                    e$nhrs            3 1
501uAC                   parm                    e$rtn             8
501uAC                   parm                    e$bpu             1
501uAC                   parm                    e$lng             2
501uAC                   if        e$rtn <> '*OK'
501uAC                   eval      e$lng = 'EN'
501uAC                   endif
     C*
     C*   Select first screen to display.
     C*
     c                   eval      mfimf# = $pmfr#
     c                   eval      mfidd# = $pdef#
     c                   eval      mfimit = $pmfritm
     c                   eval      mfidit = $ppiritm
     c     $pcmd         ifeq      '*ADD    '
     c                   eval      mfimit = ' '
     c                   eval      mfidit = ' '
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
     C*
     C*   Add record
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   eval      mfidd# = w1idd#
     c                   eval      mfimit = w1imit
     c                   eval      mfidit = w1idit
510cAc                   eval      mfiupc = w1upc
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
     C*
     C*   Move key values to parameters
     C*
     c                   move      mfimit        $pmfritm
510bAc                   eval      w1imit = ' '
510bAc                   eval      w1idit = ' '
510cAc                   eval      w1upc  = ' '
     c     endupd        endsr
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Manufacturer Item
Valid Dakota Item
