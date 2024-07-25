417sA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  MF200     Code Decipher - Entry
     *  27 September 2007
     *  Lynn McMahon
     *
     *  Revisions
     *
510 A*    09/27/07  5.10  LMC
     *      - Created
510aA*    10/02/07  LMC  5.10a
     *      - Fix: Correct manufacturer field size to 11 positions
510bA*    10/09/07  LMC  5.10b
     *      - Enh: Added upc code
510cA*    10/12/07  LMC  5.10c
     *      - Enh: Added code to handle *open in order to determine
     *        if po pragram should display cmd key for decipher
510dA*    12/05/07  LMC  5.10d
     *      - Enh: Had to change return field so I could capture
     *        exception information in po receiving programs
530aA*    08/12/10  RH   5.30a
     *      - Enh: If no decipher code is found, use item maintenance
     *        vendor# / vendor item # to look for code.
640aA*    07/13/12  LMC  6.40a
     *      - Enh: Return code that was decifered to store in LICINFO
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (Reverse Display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     FMF200fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiritem   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(1) ctdata perrcd(1)
     D*rdsc            s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     *----------------------------------------------------------------
     *  Working variables
     *
     D $msgf           s             10
     D $plen           s              3  0
     D $pstr           s             60
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D cmdtkn          s              1
     D e               s              2  0
     D error           s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D sclear          s              1
     D warn            s              1
     D work1a          s              1
     D $pexpdat        s              6  0
     D $pmfrdat        s              6  0
510bAD $pupc           s             20
640aAD $pdecvalue      s             15
     *----------------------------------------------------------------
     *  Program parameters
     *
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
510aDD* $pmfr#                19     28  0
510aDD* $pmfritem             29     43
510aDD* $pdakitem             44     58
530aDD* $pmfr#                19     29  0
530aDD* $pmfritem             30     44
530aDD* $pdakitem             45     59
530aAD  $pwhse                19     21  0
530aAD  $pmfr#                22     32  0
530aAD  $pmfritem             33     47
530aAD  $pdakitem             48     62
     D*
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
510aDD* $lmfr#                19     28  0
510aDD* $lmfritem             29     43
510aDD* $ldakitem             44     58
510aAD  $lmfr#                19     29  0
510aAD  $lmfritem             30     44
510aAD  $ldakitem             45     59
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
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *              *NORMAL  - Run normaly.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     C                   parm                    $pexpdat
     C                   parm                    $pmfrdat
510bAC                   parm                    $pupc
640aAC                   parm                    $pdecvalue
     *----------------------------------------------------------------
     *  Main line
     *
510cAC                   select
510cAC                   when      $pcmd = '*OPEN'
510cAc                   other
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
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
510cAc                   endsl
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
     c                   Select
     c                   When      nxtscr = '01 ' and #lline = '24'
     C                   exfmt     screen1                              50
     c                   When      nxtscr = '01 ' and #lline = '00'
     C                   exfmt     screen1                              50
     c                   other
     C                   exfmt     screen1A                             50
     C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
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
     *  Get existing record.
     *
     C                   exsr      zzfil1
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
510dDC*                  eval      $prtn = '*EXIT   '
510dMC                   eval      $prtn = $dreturn
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
510dDC*                  eval      $prtn = '*CANCEL '
510dMC                   eval      $prtn = $dreturn
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zznxt1
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
     *R                   WRITECLRSCR
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
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
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0110
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
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
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR0203  Value can not be blank.
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
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
510dAC                   eval      $prtn = ' '
     *
     *  Code Must be entered
     *
     C                   if        w1code = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       errmsg
     C                   exsr      zm0203
     c                   goto      endck1
     C                   endif
     *
     *  Call decipher program
     *
530aD* Moved call to subroutine ZZMFDT
530aDC*                  call      'CVTMFRDTE'
530aMC                   exsr      zzmfdt
530a  *
530a c                   If        $dreturn <> 'OK'
530a c     keyit         chain     piritem                            75
530a c                   if        %found
530a c                   eval      w1mfr# = itven#
530a c                   eval      w1mfritem = itvit#
530aMc                   exsr      zzmfdt
530a c                   endif
530a c                   endif
     c                   If        $dreturn <> 'OK'
     c                   eval      error = *on
     c                   eval      *in21 = *on
     c                   eval      *in01 = *on
     c                   goto      endck1
     c                   endif
640aAc                   if        $dreturn = 'OK'
640aAc                   eval      $pdecvalue = w1code
640aAc                   else
640aAc                   eval      $pdecvalue = ' '
640aAc                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     c                   eval      w1code    = ' '
     c                   eval      w1msg     = ' '
     c                   eval      W1MFR#    = $pmfr#
     c                   eval      W1MFRITEM = $pmfritem
     c                   eval      W1DKTITEM = $pdakitem
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
530a *  Define key for PIRITEM file.
530a *
530a C     keyit         klist
530a C                   kfld                    $pwhse
530a C                   kfld                    $pdakitem
     *
     C*                  movel     rdsc(1)       $pstr
     C*                  eval      $plen = 50
     *
     C*                  call      'CENTER'
     C*                  parm                    $pstr
     C*                  parm                    $plen
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     C*
     C*   Get screen size being used.
     C*
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lmcd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
     C*
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZMFDT   Call program to convert mfg date.
     *
     C     zzmfdt        begsr
     *
     *  Call decipher program
     *
     C                   call      'CVTMFRDTE'
     C                   parm      ' '           $dCmd            10
     C                   parm      w1code        $dCode           30
510aDC*                  parm      w1mfr#        $dMfr#           10 0
510aAC                   parm      w1mfr#        $dMfr#           11 0
     C                   parm      w1mfritem     $dMfrItem        15
     C                   parm      w1dktitem     $dDktItem        15
     C                   parm      0             $dMfrDef#         2 0
     C                   parm      0             $dDateCMD         8 0
     C                   parm      0             $dDateMDY         6 0
     C                   parm      ' '           $dReturn         10
     C     w1msg         parm      ' '           $dMsg            60
     C                   parm      ' '           $ddeftype         1
510bAC                   parm      $pupc         $dupc            20
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
     c                   select
     c                   when      $ddeftype = '1'
     c                   eval      $pexpdat  = 0
     c                   eval      $pmfrdat  = $dDateMDY
     c                   when      $ddeftype = '2'
     c                   eval      $pexpdat  = $dDateMDY
     c                   eval      $pmfrdat  = 0
     c                   other
     c                   eval      $pexpdat  = 0
     c                   eval      $pmfrdat  = 0
     c                   endsl
     *
     *
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Code
