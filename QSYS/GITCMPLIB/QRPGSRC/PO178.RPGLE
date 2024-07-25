     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO178     HACCP Information - View History
     *  05 January 2007
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions
510 A*    01/05/07  RH   5.10
     *      - Created
510bA*    12/08/06  RH   5.10b
     *      - Fix: Allow HACCP info as optional if no rec in ITEMCAT
     *      - Enh: Add client code.
640aA*    08/09/12  JCJ  6.40a
     *      - Enh: Added client specific logic
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
BIRa *    07/16/10  HNK  BIRa
     *      - Enh: Compile program for screen change.
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
BIRaMFpo17801   cf   e             workstn
BIRaD *po178fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiritem   if   e           k disk
     Fpohhdr    if   e           k disk
     Fpohdtl    if   e           k disk
     Fpohhaccp  uf a e           k disk
     F                                     rename(hahrec:record)
     Fwarehs    if   e           k disk
510bA*----------------------------------------------------------------
510bA*  Customer id
510bA*
510bAD @getcl          c                   const('GETCLIENT')
510bAD*
510bA /copy qcopysrc,id#citylin
BIRaA /copy qcopysrc,id#birite
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D pos             s              9    dim(99)
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
     D  $pexdt                51     58  0
     D  $pexti                59     64  0
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
     D $pwhsa          s              3
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D $pcode          s             10
     D blkitm          s                   like($pitem)
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
     D savitm          s             15
     D savseq          s              4  0
     D sclear          s              1
     D seq0            s                   like($pseq)
     D warn            s              1
     D $phhdr          s              1
     D $phdtl          s              1
     D $phcat          s              1
     D $phacp          s              1
510a D hcmd            s                   like($pcmd)
510a D #pos            s              2  0
510a D x               s              2  0
510a D $superpo        s                   like($ppo)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD
     *              *VIEWPO  - View HACCP info at purchase order lvl
     *              *VIEWITM - View HACCP info at item number lvl
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
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz1
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
     C                   eval      *inlr = *on
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
640aAC                   select
640aAC                   when      client = birite
640aAC                   exfmt     screen1bir                           50
640aAC                   other
     C                   exfmt     screen1                              50
640aAC                   endsl
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
     *          $PCMD     IFEQ '*VIEW   '
     C                   if        $pcmd = '*VIEWPO '  or
     C                             $pcmd = '*VIEWITM'
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
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     *
     C                   goto      endcm1
     C                   endif
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
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1est# = hahest#
     C                   eval      w1tksl = hahtksl
     C                   eval      w1prda = hahprda
     C                   eval      w1prdt = hahprdt
     *
     C                   eval      w1rsrq = hahrsrq
     C                   eval      w1rsdl = hahrsdl
     *
     C                   eval      w1ttrr = hahttrr
     C                   eval      w1ttmd = hahttmd
     C                   eval      w1ttns = hahttns
     *
     C                   eval      w1ptrt = hahptrt
     C                   eval      w1ptrm = hahptrm
     C                   eval      w1ptrb = hahptrb
     *
     C                   eval      w1ptmt = hahptmt
     C                   eval      w1ptmm = hahptmm
     C                   eval      w1ptmb = hahptmb
     *
     C                   eval      w1ptnt = hahptnt
     C                   eval      w1ptnm = hahptnm
     C                   eval      w1ptnb = hahptnb
     *
     C                   eval      w1ldcn = hahldcn
     C                   eval      w1insp = hahinsp
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C                   select
     C                   when      $pcmd = '*PO     '  or
     C                             $pcmd = '*VIEWPO '
     C     pokey         chain(n)  record                             7978
     *
     C                   when      $pcmd = '*ITEM   '  or
     C                             $pcmd = '*VIEWITM'
     C     itmky         chain(n)  record                             7978
     *
     *    If an HACCP record is not found for the item, then
     *    display blank record.
     *
     C*                  if        *in79
     C*                  clear     record                              978
     C*                  endif
     C                   endsl
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
     *  Record not found.
     *
     C                   if        *in79
     C     *nokey        clear                   record
     *R                   MOVE *ON       ERROR
     *R                   MOVE '*PGMQ   '$PRTN
     *R                   EXSR ZM73
     *R                   GOTO ENDGT1
     C                   endif
     C     endgt1        endsr

     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
510bA* Get client id.
510bA*
510bAC                   call      @getcl
510bAC                   parm                    client           10
     *
     *  Define key for main file.
     *
     C     pokey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    seq0
     C                   kfld                    blkitm
     C                   kfld                    $pexdt
     C                   kfld                    $pexti
     *
     *  Define key for main file.
     *
     C     itmky         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    $pseq
     C                   kfld                    $pitem
     C                   kfld                    $pexdt
     C                   kfld                    $pexti
     *
     *  Define key for PIRITEM file.
     *
     C     ittkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     *  Define key for POHHDR file.
     *
     C     phkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     *
     *  Define key for POHHDR file.
     *
     C     phhky         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    $pexdt
     C                   kfld                    $pexti
     *
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ1   Program initialization. Called from main line.
     *
     C     zzinz1        begsr
     *
     C                   eval      forevr = *off
     *
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
     *
     C                   when      $pcmd = '*VIEWPO '
     C     phhky         chain     pohhdr                             79
     C                   if        *in79
     C                   eval      phhvna = *blanks
     C                   endif
     C                   endsl
     *
     *   Get item description to display.
     *
     C                   select
     C                   when      $pcmd = '*PO     '  or
     C                             $pcmd = '*VIEWPO '
     C                   eval      w1item = 'N/A'
     C                   eval      wodesc = *blanks
     *
     C                   if        $pcmd = '*VIEWPO '
     C                   eval      vname = phhvna
     C                   endif
     *
     C                   when      $pcmd = '*ITEM   '  or
     C                             $pcmd = '*VIEWITM'
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
     *
     *  ZZUPD1   Update record 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *   Get record from main file.
     *
     C     endupd        endsr

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
