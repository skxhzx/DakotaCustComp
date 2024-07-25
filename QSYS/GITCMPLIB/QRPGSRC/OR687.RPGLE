     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  OR687   RF Bulk Drop
     *  4 April, 2006
     *  Roxanne Harrison
     *  Created using IT277  V5.00
     *
     *  Notes
     *
     *  Revisions
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     For687fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fbulkdrp   uf   e           k disk
     Flabel     if   e           k disk
     Fpiritem   if   e           k disk
     Frtehed    if   e           k disk
     Fpltsum2   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(3) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *----------------------------------------------------------------
     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0

     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1    100
     D* $plbl#                 1      7  0
     *----------------------------------------------------------------
     *  Called program parameters
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
     D  $plbl#                19     25  0
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     *
     D  $ldsp1                27     38
     D  $litm1                39     53
     *
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0
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
     *
     *----------------------------------------------------------------
     *  Variables
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D curent          s              1
     D curtrn          s              7  0
     D curtsk          s              6
     D curtyp          s              1
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forevr          s              1
     D found           s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D today           s              8  0
     D warn            s              1
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @vewpg          c                   const('*NONE')
     D @addtr          c                   const('ADDSTDTRN')
     D @adjtd          c                   const('ADJTSKDET')
     D @adjtr          c                   const('ADJTRAN  ')
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
414 A*----------------------------------------------------------------
414 A*  API programs
414 A*
     D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
     *
     D  erqty                  1      4p 0
     D  ernqty                 5      8p 0
413cA*
413cAD  erfmsl                 1     12
413cAD  ertosl                13     24
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
     *
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     C*                  parm                    $prtky
     C*                  parm                    $rtncd            8
409 AC*                  parm                    $zero             1
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     *
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
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
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
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
414 AC                   eval      redspl = *off
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
     C                   if        refrsh = *on
     *  Check if drop is open and update status
     C     $plbl#        chain     bulkdrp                            79
     C                   if        *in79  or
     C                             bdstat <> '1 '
     C                   unlock    bulkdrp
     C                   eval      error = *on
     C                   eval      $prtn = '*ERROR  '
     C                   eval      nxtscr = 'EOJ'
     C                   else
     C                   eval      bdstat = '2 '
     C                   update    bdrec
     C                   exsr      zzfil1
     C                   endif
     C                   eval      refrsh = *off
     C                   endif
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   if        refrsh = *on
     C                   exsr      zzfil2
     C                   endif
     C                   eval      refrsh = *off
     C     end02i        endsr
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
     C                   exsr      zzrset
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      *in20 = *off
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      zzrset
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
414 AC     redspl        cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr01i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
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
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
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
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
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
     *    PIR0203  Value cannot be blank.
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
    D*R                   MOVEADESC,1    ERRMSG
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     * Y/N  can't be blank.
     *
     C                   if        w1drop = *blanks
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(2)       errmsg
     C                   exsr      zm0203
     C                   endif
     *
     *  Verify Drop Y/N
     *
     C                   if        w1drop <> *blanks
     C                   if        w1drop <> 'Y'  and
     C                             w1drop <> 'N'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       errmsg
     C                   exsr      zm1001
     C                   endif
     C                   endif
     *
     *
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
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
     *     Warehouse.
    D*
    D*R         ROW#      WHEQ 3
    D*R                   MOVE *ON       *IN01
    D*R                   MOVE '*LOOKUP '$LCMD
    D*R                   Z-ADDW1WHSE    $LWHSE
    D*R                   CALL 'WH900'
    D*R                   PARM           $LPARM
    D*R         $LRTN     IFEQ '*SELECT '
    D*R                   Z-ADD$LWHSE    W1WHSE
    D*R                   ENDIF
    D*
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *  Get info from LABEL file.
     *
     C     $plbl#        chain(n)  label                              79
     C                   eval      w1whse = lbwhse
     C                   eval      w1whdp = lbwhdp
     C                   eval      w1item = lbitem
     C                   eval      w1disp = lbdisp
     C                   eval      w1drpq = lbqpck
     C                   eval      w1drop = *blanks

     *    Get route #
     C     keyrte        chain     rtehed                             78
     C                   if        not *in78
500 AC                   eval      w1rte = rhrte
500 AC                   else
500 AC                   eval      w1rte = *blanks
500 AC                   endif
     *    Split pallet id into individual fields.

     C                   eval      dsplid = lbpal#

     *   Get pallet summary record.

     C     keyps2        chain     pltsum2                            78
     C                   if        not *in78
500 AC                   movel     pstruk        w1truk
500 AC                   eval      w1unld = psunld
     C                   else
500 AC                   eval      w1truk = *blanks
500 AC                   eval      w1unld = *zero
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *R                   MOVE #PROG     $PPRG
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
410 AC                   eval      forevr = *off
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbitem
     *
     *  Define key for PLTSUM file.
     C     keyps2        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbrte
     C                   kfld                    lbtype
     C                   kfld                    dsplgn
     C                   kfld                    dsplrw
     C                   kfld                    dsplcl
     *  Define key for RTEHED file.
     C     keyrte        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbrte
     *
     *  Define key for LABEL file.
     *
     C     lbkey         klist
     C                   kfld                    lblbl#
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
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
     C                   eval      refrsh = *on
     C                   eval      *in02 = *on
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRSET   Reset Bulk Drop.
     *
     C     zzrset        begsr
     C     $plbl#        chain     bulkdrp                            79
     C                   if        *in79  or
     C                             bdstat <> '2 '
     C                   unlock    bulkdrp
     C                   else
     C                   eval      bdstat = '1 '
     C                   update    bdrec
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
410 AC                   if        w1drop = 'Y'
     C     $plbl#        chain     bulkdrp                            79
410 AC                   if        not *in79
500eAC*     Convert date/time to datestamp.
     C                   call      'GETTS'
     C                   parm                    bddrps
     C                   eval      bduser = #user
     C                   eval      bdjob = #job
     C                   eval      bdjobn = #jobn
     C                   eval      bdstat = '3 '
     C                   update    bdrec
409 AC                   else
     C                   eval      error = *on
409 AC                   endif
409 AC                   else
     C                   exsr      zzrset
409 AC                   endif
413bA*
413bAC                   select
413bAC                   when      error = *off
409 AC                   eval      nxtscr = 'EOJ'
413bA*
413bA*    Errors occured during update - re-display screen with error.
413bA*
413bAC                   when      error = *on
413bAC                   exsr      scr01i
413bAC                   endsl
     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     **                   EXSR SCR01I
     *
     C     endup2        endsr
     *
409 A*----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
**
Dept
Drop Y/N
Quantity
