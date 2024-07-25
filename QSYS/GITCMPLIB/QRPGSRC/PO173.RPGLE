     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO173     Reprint Tags Request Screen
     *  Jeffrey Jahnke
     *
     *  Revisions
     *    12/16/05  JCJ  5.00
     *      - Enh: New Program
     *
650aA*    07/16/14  RBD  650a
     *      - Enh: Changed screen format to PO17301. Added display of
     *        additional clam tag data.
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
650aDF*po173fm   cf   e             workstn
650aMFpo17301   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
650aAFclammsc   if   e           k disk
     Fclamprt   uf a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#LICINFO

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
     D  $ppo                  22     30
     D  $pseq                 31     35  0
     D  $pitem                36     50
     D  $plic                 51     65
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
     D svhdte          s              8  0
     D $phdte          s              8  0
500cAD $plbl#          s              7  0
     D clear           s              5  0
     D comand          s              5  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D help            s              5  0
     D enter           s              5  0
     D $pqty           s              5  0
     D msgk            s              4  0
     D e               s              2  0
     D $itdesc         s             30
     D $phloc          s             20
     D $pcert          s             20
     D $msgf           s             10
     D #pgmq           s             10
     D $pcode          s             10
     D $pprt           s             10
     D $pform          s             10
     D cmdchk          s              8
     D #msgid          s              7
     D #msgtp          s              7
     D $pwhsa          s              3
     D nxtscr          s              3
     D forevr          s              1
     D sclear          s              1
     D warn            s              1
     D work1a          s              1
     D cmdtkn          s              1
     D error           s               n
     D ck4err          s               n
     D blkitm          s                   like($pitem)
     D seq0            s                   like($pseq)
     D savever#        s                   like($lnver#)
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
     *
     C     tagfmtP       plist
     C                   parm                    $pcmd
     C                   parm      $pwhse        $pwhs             3 0
     C                   parm                    $ppo
     C                   parm                    $pseq
     C                   parm                    $pitem
     C                   parm                    $itdesc
     C                   parm                    $plic
     C                   parm                    $pqty
     C                   parm                    $phdte
     C                   parm                    $phloc
     C                   parm                    $pcert
     C                   parm                    $plbl#
     C                   parm                    $pprt
     C                   parm                    $pform
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
     C                   eval      $prtn = '        '
     C                   goto      endsc1
     C                   endif

     C                   if        $pcmd = '*ITEM   '
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zzupd1
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

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off

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

     C                   eval      w1lic = $plic

     C                   eval      w1prt  = *blanks
     C                   eval      w1form = '*STD'

     C     cdkey         chain     clamprt
     C                   if        %found(clamprt)
     C                   eval      w1prt  = cdprt
     C                   eval      w1form = cdform
     C                   endif

     *  Clam information.

     C                   exsr      clr$licinfo

     C                   eval      $lnemp# = 0
     C                   eval      $lnuser = #user
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr  = #jobn

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
     C                   eval      $lnlcns  = $plic

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*PO'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'A'
     C                   eval      $lnvalchr(1) = $ppo
     C                   eval      $lnvalnum(1) = 0

     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*POSEQ'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = $pseq

     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*ITEM'
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'A'
     C                   eval      $lnvalchr(3) = $pitem
     C                   eval      $lnvalnum(3) = 0

     C                   eval      $lncodeu(4) = *on
     C                   eval      $lncode(4) = '*HRVDATE'
     C                   eval      $lncseq(4) = 1
     C                   eval      $lnvaltyp(4) = 'N'
     C                   eval      $lnvalchr(4) = *blanks
     C                   eval      $lnvalnum(4) = *Zeros

     C                   eval      $lncodeu(5) = *on
     C                   eval      $lncode(5) = '*HRVLOC'
     C                   eval      $lncseq(5) = 1
     C                   eval      $lnvaltyp(5) = 'A'
     C                   eval      $lnvalchr(5) = *blanks
     C                   eval      $lnvalnum(5) = *zeros

     C                   eval      $lncodeu(6) = *on
     C                   eval      $lncode(6) = '*HRVCERT'
     C                   eval      $lncseq(6) = 1
     C                   eval      $lnvaltyp(6) = 'A'
     C                   eval      $lnvalchr(6) = *blanks
     C                   eval      $lnvalnum(6) = *zeros

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   if        $lnvalnum(4) = *zeros
     C                   eval      w1hdte = *zeros
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   z-add     $lnvalnum(4)  $cvd8o
     C                   z-add     $lnvalnum(4)  svhdte
     C                   move      $cvd8o        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1hdte = $cvd6o
     C                   endif

     C                   eval      w1hloc = $lnvalchr(5)
     C                   eval      w1cert = $lnvalchr(6)

650aAC                   eval      w1lot = *blanks
650aAC                   eval      w1wdte = 0
650aAC     clmkey        chain     clammsc
650aAC                   if        %found(clammsc)
650aAC                   eval      w1lot  = clmlot
650aAC                   if        clmwdt = *zeros
650aAC                   eval      w1wdte = *zeros
650aAC                   else
650aAC                   eval      $cvcmd = '*CMDMDY '
650aAC                   eval      $cvd8o = clmwdt
650aAC                   move      $cvd8o        $cvd8i
650aAC                   call      @cvtdt
650aAC                   parm                    $cvtdt
650aAC                   eval      w1wdte = $cvd6o
650aAC                   endif
650aAC                   endif

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
     *  Define key for PIRITEM file.
     *
     C     ittkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
650aA*  Define key for CLAMMSC file.
650aA*
650aAC     clmkey        klist
650aAC                   kfld                    $pwhse
650aAC                   kfld                    $plic
     *
     *  Define key for CLAMPRT file.
     *
     C     cdkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    #job
     *
     C                   eval      $lprg = #prog
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
     C                   eval      $itdesc = itdesc
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

     *   Call Print Clam Tag labels on Zebra printer

     C                   eval      $phdte = svhdte
     C                   eval      $phloc = w1hloc
     C                   eval      $pcert = w1cert
     C                   eval      $plbl# = *zeros
     C                   eval      $pqty = W1LNbr

     C                   call      'TAGFMT'      tagfmtP

     *   Move key values to parameters

     C     endupd1       endsr

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #user
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobn

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   eval      $dridata = $licinfo

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   eval      $licinfo = $dridata

     C                   eval      ck4err = *off

     C     enddricop     endsr

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
