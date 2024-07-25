     *----------------------------------------------------------------
     *   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  PO172     HACCP Clam Information Entry
     *  Jeffrey Jahnke
     *
     *  Revisions
     *    12/16/05  JCJ  5.00
     *      - Enh: New Program
     *    01/17/06  JCJ  5.00a
500 A*      - Enh: Made Harvest location and Shipper Cert# required.
     *    09/19/13  RH   6.50a
650aA*      - Fix: Rename format member to all error ind 23 & 24 for
     *      500 Enh change.
650bA*    10/01/13  LMC  6.50b
     *      - Enh: Added incoming parm for the license.
     *        Change display file from PO17201 to PO17202.
650cA*    07/10/14  RBD  6.50c
     *      - Enh: Added entry of Product Wet Stored to Date and
     *        Lot Number.
     *      - Changed screen format to PO17203.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions
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
650aDF*o172fm   cf   e             workstn
650bDF*po17201   cf   e             workstn
650cDF*po17202   cf   e             workstn
650cMFpo17203   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiritem   if   e           k disk
     Fpohdr     if   e           k disk
     Fwarehs    if   e           k disk
650cAFclammsc   uf a e           k disk
     Fclamprt   uf a e           k disk
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
     D  $pitem                22     36
     D  $ppo                  37     45
     *
     D  $phedt                31     38  0
     D  $pheti                39     44  0
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
     D  $litem                22     36
     *
     D  $lldcn                19     20
     D  $lprda                19     23
     D  $lprdt                19     23
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
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  eritem                 1     15
     *
     D  erpo                   1      9
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     * Get Category return status message
     *
     D nfound          c                   const('*NOTFOUND*')
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
     *  Variables
     *
     D w1hdtec         s              8  0
650cAD w1wdtc          s              8  0
     D $phdte          s              8  0
     D clear           s              5  0
     D comand          s              5  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D help            s              5  0
     D enter           s              5  0
     D $pseq           s              5  0
     D msgk            s              4  0
     D e               s              2  0
     D $phloc          s             20
     D $pcert          s             20
     D $msgf           s             10
     D #pgmq           s             10
     D $pcode          s             10
     D $pprt           s             10
     D $pform          s             10
650bAD $plcns          s             15
     D cmdchk          s              8
     D #msgid          s              7
     D #msgtp          s              7
     D $pwhsa          s              3
     D nxtscr          s              3
     D error           s              1
     D forevr          s              1
     D sclear          s              1
     D warn            s              1
     D work1a          s              1
     D cmdtkn          s              1
     D blkitm          s                   like($pitem)
     D seq0            s                   like($pseq)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ITEM    - Capture HACCP info at item number lvl
     *      $PPRG   Program to send messages back to.
     *
     *    Returned Parameters
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
     C                   parm                    $pseq
     C                   parm                    $phdte
     C                   parm                    $phloc
     C                   parm                    $pcert
     C                   parm                    $pprt
     C                   parm                    $pform
650bAC                   parm                    $plcns
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
     * Overlay screen with screen to be processed.
     * Clams screen
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
     *----------------------------------------------------------------
     *  Screen 02 initialization
     *----------------------------------------------------------------

     C     scr01i        begsr
     C                   eval      nxtscr = '01 '

     *  Get field defaults if this is an add.

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

     *----------------------------------------------------------------
     *  SC1  -  Screen 1 - Entry screen for CLAMS
     *----------------------------------------------------------------

     C     sc1           begsr

     *  Test for F3 - Exit

     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif

     *  Test for F5 - Refresh

     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif

     *  Test for F12 - Previous

     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif

     C                   if        $pcmd = '*ITEM   '
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     '1'           endsc1
     C                   endif
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
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = errmsg
     C                   exsr      zmpmsg
     C                   endsr
500 A*----------------------------------------------------------------
500 A*   PIR0203  Field can not be blank
500 A*
500 AC     zm0203        begsr
500 AC                   eval      #msgid = 'PIR0203'
500 AC                   eval      #msgtp = '*DIAG  '
500 AC                   movea     errmsg        $md
500 AC                   exsr      zmpmsg
500 AC                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off

     *  Verify entered date

     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1hdte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zmqmsg
     C                   goto      endck1
     C                   else
     C                   eval      w1hdte = $cvd6o
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1hdte        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1hdtec = $cvd8o
     C                   endif

500 A*  Harvest location required

500 AC                   if        w1hloc = *Blanks
500 AC                   eval      error = *on
500 AC                   eval      *in24 = *on
500 AC                   eval      *in04 = *on
500 AC                   eval      errmsg = 'Harvest location'
500 AC                   exsr      zm0203
500 AC                   endif

500 A*  Original Shipper Cert#

500 AC                   if        w1cert = *Blanks
500 AC                   eval      error = *on
500 AC                   eval      *in23 = *on
500 AC                   eval      *in03 = *on
500 AC                   eval      errmsg = 'Original Shipper Cert#'
500 AC                   exsr      zm0203
500 AC                   endif

650cA*  Product Wet Stored to Date and Lot Number

     C                   if        w1wdt <> 0

     C                   if        w1lot = 'NA'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = 'If lot = NA wet date +
     C                             must be zero'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1wdt         $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zmqmsg
     C                   goto      endck1
     C                   else
     C                   eval      w1wdt = $cvd6o
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1wdt         $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1wdtc = $cvd8o
     C                   endif

     C                   else
     C                   if        w1lot <> 'NA'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = 'Lot must be NA if no +
     C                             wet date entered'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     C                   endif

     C                   if        w1lot = *blanks
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = 'Lot Number'
     C                   exsr      zm0203
     C                   goto      endck1
     C                   endif

     *  Verify default form type

     C                   eval      work1a = %subst(w1form:1:1)
     C                   if        work1a = '*' and w1form <> '*STD'
     C                                          or  w1form =  *Blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'Form type'
     C                   exsr      zm1001
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
     *
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

     C                   if        $phdte = *zeros
     C                   eval      w1hdte = *zeros
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      $phdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1hdte = $cvd6o
     C                   endif

     C                   eval      w1hloc = $phloc
     C                   eval      w1cert = $pcert

     C                   eval      w1prt  = *blanks
     C                   eval      w1form = '*STD'

650cAC                   eval      w1wdt  = 0
650cAC                   eval      w1lot  = *blanks

     C     cdkey         chain     clamprt
     C                   if        %found(clamprt)
     C                   eval      w1prt  = cdprt
     C                   eval      w1form = cdform
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr

     C     endgt1        endsr

     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     itmky         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    $pseq
     C                   kfld                    $pitem
     *
     *  Define key for PIRITEM file.
     *
     C     ittkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     *  Define key for POHDR file.
     *
     C     phkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     *
     *  Define key for CLAMPRT file.
     *
     C     cdkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    #job
     *
650cA*  Define key for CLAMMSC file.
650cA*
650cAC     clmkey        klist
650cAC                   kfld                    $pwhse
650cAC                   kfld                    $plcns
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     C                   eval      forevr = *off
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Get vendor name.
     *
     C                   select
     C                   when      $pcmd = '*ITEM   '
     C     phkey         chain     pohdr                              79
     C                   if        *in79
     C                   eval      phvnam = *blanks
     C                   endif
     C                   endsl
     *
     *   Get item description to display.
     *
     C                   select
     C                   when      $pcmd = '*ITEM   '
     C                   eval      w1item = $pitem
     C     ittkey        chain     piritem                            75
     C                   if        *in75
     C                   eval      wodesc = *blanks
     C                   else
     C                   eval      wodesc = %trimr(itpdsc) + ' ' + itdesc
     C                   endif
     C                   endsl
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i

     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD1   Update record 1.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   eval      error = *off

     *  Move screen fields to record fields

     C                   eval      $phdte = w1hdtec
     C                   eval      $phloc = w1hloc
     C                   eval      $pcert = w1cert
     C                   eval      $pprt  = w1prt
     C                   eval      $pform = w1form

     C     cdkey         chain     clamprt

     *   Add record

     C                   if        not %found(clamprt)
     C                   eval      cdwhse = $pwhse
     C                   eval      cddev  = #job
     C                   eval      cdprt  = w1prt
     C                   eval      cdform = w1form
     C                   write     cdrec
     C                   endif

     *   -OR- Update record

     C                   if        %found(clamprt)
     C                   if        cdprt <> w1prt or cdform <> w1form
     C                   eval      cdprt  = w1prt
     C                   eval      cdform = w1form
     C                   update    cdrec
     C                   endif
     C                   endif

650cA*   Update CLAMMSC file

650cAC                   if        w1lot = 'NA'
650cAC                   eval      w1lot = *blanks
650cAC                   eval      w1wdtc = 0
650cAC                   endif

650cAC     clmkey        chain     clammsc

650cA*   Add record

650cAC                   if        not %found(clammsc)
650cAC                   eval      clmwhs = $pwhse
650cAC                   eval      clmlic = $plcns
650cAC                   eval      clmlot = w1lot
650cAC                   eval      clmwdt = w1wdtc
650cAC                   write     clmrec
650cAC                   endif

650cA*   -OR- Update record

650cAC                   if        %found(clammsc)
650cAC                   eval      clmlot = w1lot
650cAC                   eval      clmwdt = w1wdtc
650cAC                   update    clmrec
650cAC                   endif

     *   Move key values to parameters

     C     endupd1       endsr

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
