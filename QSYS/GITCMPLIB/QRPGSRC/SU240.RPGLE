500bA*----------------------------------------------------------------
500bA*  Multilingual Verision
500bA*  Every screen and message has a corresponding Spanish version.
500bA*  Any changes must be made to both languages.
500bA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  SU240     License / Item RF entry for Start up
     *  05 March, 2016
     *  Roxanne Harrison
     *
     *  Notes
     *    03/05/16  RH  V7.00
     *       8 X 20 Screens for hand held scanners
     *       Writes rec to work file for SU140. License must be unique
     *       and not found in SU240WK or LICENSE file.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700aA*    11/03/16  LMC  7.00a
     *      - Enh: UPC file has a database change. Recompile only.
740aA*    01/26/20  RH   7.40a
     *      - Enh: Changed display file to SU14001.
     *----------------------------------------------------------------
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
740aD *su240fm   cf   e             workstn
740aMFsu24001   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fupc       if   e           k disk
416aAFpiritem4  if   e           k disk
417bAFoptions   if   e           k disk
417bAFitemdsc   if   e           k disk
520aAFitemlnk   if   e           k disk
520aAFitemlnk1  if   e           k disk
     F                                     rename(ilrec:recd1)
520aAFpiritem   if   e           k disk
     F                                     rename(itrec:record)
     Flicense   if   e           k disk
     FSU240wk   uf a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
416aAD desc            s             50    dim(2) ctdata perrcd(1)
500bAD descsp          s             50    dim(2) ctdata perrcd(1)
510bA*----------------------------------------------------------------
510bA*  Client id's for custom mods.
510bA*----------------------------------------------------------------
510bA*
     D @getcl          c                   const('GETCLIENT')
510bA*
510bA*
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
     D  $litm1                22     36
     *
417a D  $lupc                 22     41
417a D  $litem                42     56
     *
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
     *
500aA*----------------------------------------------------------------
500aA*  API programs
500aA*
     D @apici          c                   const('APICVTITM ')
     *----------------------------------------------------------------
417bA* Data structure
417bA*
417bAD opdata          ds
417bAD  opstyp                 1      1
417bAD  opwhdp                 2      6
417bAD  opum1                  7      8
417bAD  opdum                  9     23
417bAD  opcum                 24     43
417bAD  opcdiv                44     52  2
417bAD  opcaut                53     53
417bAD  opcwrn                54     54
417bAD  opcrng                55     57  1
417bAD  opwum                 58     72
417bAD  opxdsc                73     73
417bAD  optend               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     D #msgsp          c                   const('PIRMSGFSP ')
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
     D kyvmfg          s                   like(itvit#)
     D msgk            s              4  0
     D nxtscr          s              3
     D ocode           s              8
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D upcctr          s              3  0
     D warn            s              1
     D wsitem          s             15
     D w1upc           s             20
     *
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *  Let the show begin .....
     *
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
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   exfmt     scrn1sp                              50
500bAC                   other
     C                   exfmt     screen1                              50
500bAC                   endsl
     C                   endif
     C                   if        nxtscr = '02 '
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   exfmt     scrn2sp                              50
500bAC                   other
417bMC                   exfmt     screen2                              50
500bAC                   endsl
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
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
     C                   if        refrsh = *on
     C                   exsr      zzfil1
     C                   endif
     C                   eval      refrsh = *off
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
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  The after update redisplay screen. The only way out is F3.
417b *  Change to display screen 2.
417b C                   exsr      scr02i
     *
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
510bA*
510bA* Get client id
510bA*
510bAC                   call      @getcl
510bAC                   parm                    client           10
510bAC                   parm                    cliloc           10
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
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      $msgf = #msgsp
500bAC                   other
     C                   eval      $msgf = #msgf
500bAC                   endsl
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
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
    AC                   eval      errmsg = desc(2)
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
223 A*   PIR0204  Enter only one value.
223 A*
223 AC     zm0204        begsr
223 AC                   eval      #msgid = 'PIR0204'
223 AC                   eval      #msgtp = '*DIAG  '
223 AC                   eval      $md = *blanks
223 AC                   exsr      zmpmsg
223 AC                   endsr
223 A*----------------------------------------------------------------
223 A*   PIR0205  Must enter one value.
223 A*
223 AC     zm0205        begsr
223 AC                   eval      #msgid = 'PIR0205'
223 AC                   eval      #msgtp = '*DIAG  '
223 AC                   eval      $md = *blanks
223 AC                   exsr      zmpmsg
223 AC                   endsr
416a *----------------------------------------------------------------
416a *    PIR1001  Invalid option entered.
416a *
416a C     zm1001        begsr
416a C                   eval      #msgid = 'PIR0202'
416a C                   eval      #msgtp = '*DIAG  '
416a C                   movea     errmsg        $md
416a C                   exsr      zmpmsg
416a C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *----------------------------------------------------------------

     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
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
     *    LP11022  License not on file.
     *
     C     zm022         begsr
     C                   eval      #msgid = 'PO20029'
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
416aAC                   eval      wsitem = *blanks
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     *
     C                   endif
     C                   endif
     *
    A*  Must enter item or UPC or MFG
    A*
    AC                   if        w1item = *blanks  and
    AC                             w1up50 = *blanks  and
    AC                             w1vmfg = *blanks
    AC                   eval      error = *on
    AC                   eval      *in22 = *on
    AC                   eval      *in02 = *on
    AC                   eval      *in23 = *on
    AC                   eval      *in03 = *on
    AC                   eval      *in24 = *on
    AC                   eval      *in04 = *on
    AC                   exsr      zm0205
    AC                   endif
     *
     *  Verify UPC
     *
    AC                   eval      w1upc = *blanks
     *
    AC                   select
     *  UPC entered
    MC                   when      w1up50 <> *blanks
    AC                   if        w1item = *blanks  and
    AC                             w1vmfg = *blanks
    A*
    AC                   eval      $cbcmd = '*UPC    '
    MC                   movel     w1up50        $cbbar
    AC                   call      'CVTBAR'
    AC                   parm                    $cbcmd            8
    AC                   parm                    $cbbar          100
    AC                   parm                    $cbcod            3 0
    AC                   parm                    $cbdec            1 0
    AC                   parm                    $cbdsc           30
    AC                   parm                    $cbpos            3 0
    AC                   parm                    $cbtyp            1 0
    AC                   parm                    $cbv1            11 3
    AC                   parm                    $cbv2            50
    AC                   parm                    $cbrtn            8
    AC                   parm                    $cberm           60
     *
    AC                   if        $cbrtn = '*OK'  or
    AC                             $cbrtn = '*UPCWARN'
    AC                   movel     $cbv2         w1upc
    AC                   else
AFS A*
AFS A*     Treat all returns from CVTBAR as good.
AFS A*     If code is found in UPC file, its good.
EFC AC**                 if        client = eastln  or
AFS AC**                           client = andrew
EFCaMC**                 movel     $cbbar        w1upc
EFCaAC**                 endif
416aAC                   endif
     *
     *   Right adjust UPC code for file.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w1upc         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         w1upc
     *   Check if mulitple items exist for one UPC code.
     *    UPCCTR = 0, error, upc code not found.
     *    UPCCTR = 1, only one upc found, process for item.
     *    UPCCTR > 1, multiple upc found, need to select item.
     C                   eval      upcctr = 0
     C     upckey        setll     upc
     C                   dow       forevr = forevr
     C     upckey        reade     upc                                    79
     *
     C                   if        *in79
     C                   leave
     C                   else
     C                   add       1             upcctr
     C                   endif
     *
417a C                   enddo
     *
417a C                   if        upcctr = 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   exsr      zm022
416aAC                   goto      endck1
     C                   endif
     *
     *   Multiple items exist for UPC
417a C                   if        upcctr > 1
417a C                   eval      $lcmd = '*VERIFY '
417a C                   eval      $lwhse = w1whse
417a C                   eval      $lupc = w1upc
417a C                   call      'UC920'
417a C                   parm                    $lparm
417a C                   if        $lrtn = '*ERROR  '
417a C                   eval      error = *on
417a C                   eval      *in24 = *on
417a C                   eval      *in04 = *on
417a C                   movel     $lerm         errmsg
417a C                   exsr      zm0105
417a C                   else
417a C                   if        $lrtn = '*PGMQ   '
417a C                   eval      error = *on
417a C                   eval      *in24 = *on
417a C                   eval      *in04 = *on
417a C                   eval      #msgk = $lmsg
417a C                   exsr      zmqmsg
417a C                   endif
417a C                   endif
417a C                   eval      upitem = $litem
     *
417a C                   endif
416aAC                   eval      wsitem = upitem
416aAC                   else
416aA*  Error, more than one value entered.
416aAC                   eval      error = *on
416aAC                   eval      *in22 = *on
416aAC                   eval      *in23 = *on
416aAC                   eval      *in24 = *on
416aAC                   eval      *in02 = *on
416aAC                   eval      errmsg = *blanks
416aAC                   exsr      zm0204
416aAC                   goto      endck1
416aAC                   endif
     *
416aAC                   endsl
     *
416a *
416a *  Verify Mfg code/vendor item.
416a *
416aAC                   if        w1vmfg <> *blanks
416aAC                   if        w1upc = *blanks  and
416aAC                             w1item = *blanks
416aAC                   eval      kyvmfg = w1vmfg
416aAC     mfgkey        chain     piritem4                           79
416aAC                   if        *in79
416aAC                   eval      error = *on
416aAC                   eval      *in24 = *on
416aAC                   eval      *in04 = *on
416aAC                   eval      errmsg = *blanks
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = descsp(1)
500bAC                   other
416aAC                   eval      errmsg = desc(1)
500bAC                   endsl
416aAC                   exsr      zm1001
416aAC                   goto      endck1
416aAC                   else
416aAC                   eval      wsitem = ititem
416aAC                   endif
416aAC                   else
416aA*  Error, more than one value entered.
416aAC                   eval      error = *on
416aAC                   eval      *in22 = *on
416aAC                   eval      *in23 = *on
416aAC                   eval      *in24 = *on
416aAC                   eval      *in04 = *on
416aAC                   eval      errmsg = *blanks
416aAC                   exsr      zm0204
416aAC                   goto      endck1
416aAC                   endif
416bAC                   endif
     *
     *  Get item # from other field entered.
     *
     C                   if        w1item = *blanks  and
     C                             wsitem <> *blanks
    AC                   eval      w1item = wsitem
    AC                   endif
     *
    A*  Verify ITEM
    A*
    AC                   if        w1item <> *blanks
    A*  Call API for item.
    A*
    AC                   call      @apici
    AC                   parm                    w1item
    AC                   parm      6             worow             3 0
    AC                   parm      7             wocol             3 0
    AC                   parm                    @artn             8
    AC                   if        @artn = '*REDSPLY'
    AC                   endif
    A*
    AC                   eval      $lcmd = '*VERIFY '
    AC                   eval      $lwhse = w1whse
    AC                   eval      $litm1 = w1item
    AC                   call      'IT900'
    AC                   parm                    $lparm
    AC                   if        $lrtn = '*ERROR  '
    AC                   eval      error = *on
    AC                   eval      *in23 = *on
    AC                   eval      *in03 = *on
    AC                   movel     $lerm         errmsg
    AC                   exsr      zm0105
    AC                   else
    AC                   if        $lrtn = '*PGMQ   '
    AC                   eval      error = *on
    AC                   eval      *in23 = *on
    AC                   eval      *in03 = *on
    AC                   eval      #msgk = $lmsg
    AC                   exsr      zmqmsg
    AC                   endif
    AC                   endif
    AC                   endif
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
    A*  Must enter License
    A*
    AC                   if        w2lcns = *blanks
    AC                   eval      error = *on
    AC                   eval      *in25 = *on
    AC                   eval      *in05 = *on
    AC                   exsr      zm0205
    AC                   endif
     *
     *  Verify License not in work file.
     *
     C     s2key         chain     su240wk
     C                   if        %found
    AC                   eval      error = *on
    AC                   eval      *in25 = *on
    AC                   eval      *in05 = *on
    AC                   exsr      zm02
     C                   endif
     *
     *  Verify License not in LICENSE file.
     *
     C     s2key         setll     license
     C     s2key         reade     license
DRY0AC                   if        not %eof(license)
    AC                   eval      error = *on
    AC                   eval      *in25 = *on
    AC                   eval      *in05 = *on
    AC                   exsr      zm02
     C                   endif
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
     *
416aD**         ROW#      WHEQ 7
416aMC                   when      row# = 2
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
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
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     *
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     *
     C                   eval      w1whse = #whse
     C                   eval      w1upc = *blanks
510AAC                   eval      w1up50 = *blanks
416aAC                   eval      w1vmfg = *blanks
223 AC                   eval      w1item = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
417bAC                   eval      w2dsc1 = *blanks
417bAC                   eval      w2dsc2 = *blanks
417bAC                   eval      w2pack = *blanks
417bAC                   eval      w2lcns = *blanks
520aAC                   eval      *in81 = *off
     *
417bAC                   eval      w2item = w1item
     *
     *
417BAC                   eval      ocode = '*ITEMMNT'
417bAC     opkey         chain     options                            79
417bAC                   if        *in79
417bAC                   eval      opxdsc = 'N'
417bAC                   endif
     *
417bAC                   if        opxdsc = 'Y'
417bAC     idkey         chain     itemdsc                            79
417bAC                   if        not *in79
417bAC                   eval      w2dsc1 = ixdsc1
417bAC                   eval      w2dsc2 = ixdsc2
417bAC                   endif
417bAC     itkey         chain     piritem                            78
417bAC                   if        not *in78
417bAC                   eval      w2pack = itpdsc
417bAC                   endif
     *
417bAC                   else
417bAC     itkey         chain     piritem                            78
417bAC                   if        not *in78
417bAC                   movel     itdesc        w2dsc1
417bAC                   eval      w2pack = itpdsc
417bAC                   endif
417bAC                   endif
JORaA*   Check for linked items.
JORaA******
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
417a C                   eval      forevr = *off
     *R                   MOVE #PROG     $PPRG
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     C     upckey        klist
     C                   kfld                    w1whse
     C                   kfld                    w1upc
     *
223 AC     itkey         klist
223 AC                   kfld                    w1whse
223 AC                   kfld                    w1item
     *
520aAC     ilkey         klist
520aAC                   kfld                    itwhse
520aAC                   kfld                    ititem
416aA*
416aAC     mfgkey        klist
416aAC                   kfld                    w1whse
416aAC                   kfld                    kyvmfg
     *
417bA*     OPTIONS
417bA*
417bAC     opkey         klist
417bAC                   kfld                    $lwhse
417bAC                   kfld                    ocode
417bA*
417bAC     s2key         klist
417bAC                   kfld                    $lwhse
417bAC                   kfld                    w2lcns
417bA*
417bA*     EXTENDED ITEM DESCRIPTION
417bA*
417bAC     idkey         klist
417bAC                   kfld                    $lwhse
417bAC                   kfld                    w1item
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
500bA*
500bA*   Get employee options.
500bA*
500bAC                   call      'GETUSER'
500bAC                   parm      #user         e$code           10
500bAC                   parm                    e$whse            3 0
500bAC                   parm                    e$emp#            5 0
500bAC                   parm                    e$fnam           15
500bAC                   parm                    e$init            1
500bAC                   parm                    e$lnam           20
500bAC                   parm                    e$whdp            5
500bAC                   parm                    e$styp            1
500bAC                   parm                    e$shft            6
500bAC                   parm                    e$crew            6
500bAC                   parm                    e$nhrs            3 1
500bAC                   parm                    e$rtn             8
500bAC                   parm                    e$bpu             1
500bAC                   parm                    e$lng             2
500bAC                   if        e$rtn <> '*OK'
500bAC                   eval      e$lng = 'EN'
500bAC                   endif
     *
     *   Select first screen to display.
     *
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   eval      $lwhse = w1whse
223 AC                   if        w1upc <> *blanks
     C                   eval      $litm1 = upitem
223 AC                   else
223 AC                   eval      $litm1 = w1item
223 AC                   endif
417b **
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
     **  Write record
     C                   eval      suwhse = $lwhse
     C                   eval      sulcns = w2lcns
     C                   eval      suitem = w1item
     C                   eval      sustat = '1'
     C                   write     su2rec                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endup2
     C                   endif
     C                   exsr      scr01i
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Mfg Code/Vendor item#
License
** Descsp
Codigo de Mfc/#producto de vendedor
License
