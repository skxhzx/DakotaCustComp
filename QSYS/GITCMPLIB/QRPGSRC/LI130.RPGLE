500bA*----------------------------------------------------------------
500bA*  Multilingual Verision
500bA*  Every screen and message has a corresponding Spanish version.
500bA*  Any changes must be made to both languages.
500bA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  LI130     License Date information - View  RF(Full Screen)
     *  16 October, 2006
     *  Roxanne Harrison
     *
     *  Notes
     *
     *  Revisions
     *
     *    10/16/06  RH   5.10
     *      - Created
500bA*    06/06/06  JCJ  5.00b
     *      - Added Multilingual logic.
510bA*    01/29/07  RH   5.10b
     *      - Fix: Initialize W1INDT=0, leftover date being displayed
640aA*    10/10/12  LMC  6.40a
     *      - Revised to call drilicinfo instead of using file directly.
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
     FLi130fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
640aDF*Licinfo   if   e           k disk
     Fpiritem   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
414cAD desc            s             50    dim(1) ctdata perrcd(1)
416bAD a11             s              1    dim(11)
500bAD descsp          s             50    dim(1) ctdata perrcd(1)
640aA*----------------------------------------------------------------
640aA*  DRI parameters
640aA*----------------------------------------------------------------
640aA /COPY *libl/qcopysrc,C#DRIPARMS
640aA
640aA*----------------------------------------------------------------
640aA*  Data Formats
640aA*----------------------------------------------------------------
640aA /COPY *libl/qcopysrc,C#LICINFO
640aAD savever#        s                   like($lnver#)
     *----------------------------------------------------------------
     * Data structure
     *
     D dteset1         ds
     D  dtval1                 1      6
     D  dtdflg                 7      7
     D  dtval2                 8     14
     D  dtmflg                15     15
     *
     D dteset2         ds
     D  dtmlbl                 1      6
     D  dtmday                 7      9
     D  dtulbl                10     16
     D  dtuday                17     19
     D  dtdlbl                20     26
     D  dtdday                27     29
     *
     D opdata          ds
     D  oplpgm                 1     10
     D  opupct                11     13  0
     D  optend               117    117
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
416aMD  $llcns                22     36
416aMD  $ltrn#                37     43  0
     *
414CMD  $ltrn                 19     25  0
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
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     *----------------------------------------------------------------
     *  Constants
     *
     D @stat1          c                   const('Pending   ')
     D @stat2          c                   const('Started   ')
     D @stat3          c                   const('Ended     ')
     D @stat4          c                   const('Closed    ')
     D @stat8          c                   const('Interupted')
     D @stat9          c                   const('Canceled  ')
     *
     D @stata          c                   const('Allocated ')
     D @statb          c                   const('Built     ')
     D @statp          c                   const('Printed   ')
     D @statc          c                   const('Closed    ')
     *
     D @statv          c                   const('Virtual   ')
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
640aA /Copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Program info data structure
     *
640aDD*               sds
640aDD* #prog            *proc
640aDD* #job                 244    253
640aDD* #user                254    263
640aDD* #jobn                264    269
640aDD* #jobdt               276    281  0
640aDD* #jobtm               282    287  0
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
     D $msgf           s             10
     D $pstr           s             50
     D $pwhse          s              3  0
     D $ptrn#          s              7  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
640aAD chk4err         s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
640aDD*error           s              1
640aMD error           s               n
     D flag            s              1
     D forevr          s              1
     D help            s              5  0
     D i               s              2  0
     D kytype          s              1
     D lcount          s              1  0
     D msgk            s              4  0
     D nxtscr          s              3
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D tmp11a          s             11
     D warn            s              1
     D wolcns          s             15
     D wotrn#          s              7  0
     D w2ven           s             11
     D w2vnam          s             40
     D x               s              2  0
640aAD zmflag          s               n
640aAD zmsflag         s               n
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
414eD**     None
414eA*      $PCMD    *VIEW  - View license date info
414eA*      $PPRG    Program
414eA*      $PWHS    Warehouse
414eA*      $PLCNS   License
414eA*      $PTRN    Transaction #
414eA*      $PITEM   Item #
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pwhs             3
     C                   parm                    $plcns           15
     C                   parm                    $ptrn             7
     C                   parm                    $pitem           15
     C                   parm                    $plng             2
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
500bAC                   when      $plng = 'SP'
500bAC                   exfmt     scrn1sp                              50
500bAC                   other
     C                   exfmt     screen1                              50
500bAC                   endsl
     C                   endif
     C                   if        nxtscr = '02 '
500bAC                   select
500bAC                   other
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
640aA*----------------------------------------------------------------
640aA*  clr$licinfo  Clear $licinfo data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$licinfo   begsr
640aAC                   eval      savever# = $lnver#
640aAC                   clear                   $licinfo
640aAC                   clear                   $licinfo2
640aAC                   eval      $lnver# = savever#
640aAC                   eval      $lnuser = #user
640aAC                   eval      $lnpgm  = #prog
640aAC                   eval      $lnjob  = #job
640aAC                   eval      $lnjobnbr = #jobn
640aAC                   endsr

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
500bAC                   when      $plng = 'SP'
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
640aA*      0105
640aA*
640aAC     zm0105        begsr
640aAC                   eval      #msgid = 'PIR0105'
640aAC                   eval      #msgtp = '*DIAG  '
640aAC                   movea     errmsg        $md(1)
640aAC                   exsr      zmpmsg
640aAC                   endsr
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
417a *----------------------------------------------------------------
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
     C                   exsr      zzgeti
510b C                   eval      w1indt = 0
     *
640aA*  Get Licinfo Information
640aA
640aAC                   exsr      clr$licinfo
640aA
640aAC                   eval      $lnemp# = 0
640aAC                   eval      $lnuser = #user
640aAC                   eval      $lnpgm  = #prog
640aAC                   eval      $lnjob  = #job
640aAC                   eval      $lnjobnbr  = #jobn
640aA
640aAC                   eval      $lnwhse  = $pwhse
640aAC                   eval      $lnlcns  = $plcns
640aA
640aAC                   eval      $dricommand = '*LICINFO'
640aAC                   eval      $drisubcmd  = '%GET'
640aAC                   eval      $drisys2upd = 'D'
640aAC                   eval      chk4err = *on
640aAC                   exsr      zzzdricop
640aAC                   if        error
640aAC                   endif
640aA
640aA*  Now process the return information

640aAc                   eval      w1dflg = $lndateflag
640aAc                   eval      w1mflg = $lnmfgflag
640aA
640aAC                   eval      w1mday = $lnmfgdays
640aAC                   eval      w1uday = $lnusrdays
640aAC                   eval      w1dday = $lndstdays
640aA
640aAC                   eval      w1dtyp = $lnenttype
640aAC                   movel     $lnentdate    $cvd8i
640aAC                   eval      $cvcmd = '*CMDMDY '
640aAC                   call      @cvtdt
640aAC                   parm                    $cvtdt
640aAC                   eval      w1indt = $cvd6o
640aAC                   movel     $lnexpdate    $cvd8i
640aAC                   eval      $cvcmd = '*CMDMDY '
640aAC                   call      @cvtdt
640aAC                   parm                    $cvtdt
640aAC                   eval      w1expd = $cvd6o
640aA
640aDC*                  eval      kytype = 'P'
640aDC*    likey         setll     licinfo
640aDC*                  dow       forevr = forevr
     C*    likey         reade     licinfo                                79
640aDC*    likey         reade     licinfo
     C*                  if        *in79
640aDC*                  if        %eof
640aDC*                  leave
640aDC*                  else
640aDC*                  select
640aDC*                  when      lncode = '*DATEIN'
640aDC*                  eval      $cvcmd = '*CMDMDY '
640aDC*                  movel     lnvalue       $cvd8i
640aDC*                  call      @cvtdt
640aDC*                  parm                    $cvtdt
640aDC*                  eval      w1indt = $cvd6o
     *
640aDC*                  when      lncode = '*EXPDTE'
640aDC*                  eval      $cvcmd = '*CMDMDY '
640aDC*                  movel     lnvalue       $cvd8i
640aDC*                  call      @cvtdt
640aDC*                  parm                    $cvtdt
640aDC*                  eval      w1expd = $cvd6o
640aDC*
640aDC*                  when      lncode = '*DATETYP'
640aDC*                  movel     lnvalue       w1dtyp
     *
640aDC*                  when      lncode = '*DTESET1'
640aDC*                  movel     lnvalue       dteset1
640aDC*                  move      dtdflg        w1dflg
640aDC*                  move      dtmflg        w1mflg
     *
640aDC*                  when      lncode = '*DTESET2'
640aDC*                  movel     lnvalue       dteset2
640aDC*                  move      dtmday        w1mday
640aDC*                  move      dtuday        w1uday
640aDC*                  move      dtdday        w1dday
640aDC*                  other
640aDC*                  endsl
640aDC*                  iter
640aDC*                  endif
640aDC*                  enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *
500bAC*                  select
500bAC*                  when      $plng = 'SP'
500bAC*                  movel     descsp(1)     w2item
500bAC*                  other
414cAC*                  movel     desc(1)       w2item
500bAC*                  endsl
417a C*                  if        lbstat = 'C'
417a C*                  movel     @statc        w3lbst
417a C*                  endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGETI   Get item description and pack description.
     *
     C     zzgeti        begsr
     *
     *
     C                   eval      w1item = *zeros
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   endif
     C                   movel     $pitem        $iitem
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   eval      w1item = $istr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
414eAC                   eval      forevr = *on
     *
     *R                   MOVE #PROG     $PPRG
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     C     likey         klist
     C                   kfld                    $pwhse
     C                   kfld                    kytype
     C                   kfld                    $plcns
     *
     *
     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
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
     C                   move      $pwhs         $pwhse
     C                   move      $ptrn         $ptrn#
     *
     ***        $PCMD     IFEQ '*VIEW'
     C                   eval      w1trn# = $ptrn#
     C                   eval      w1lcns = $plcns
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     ***                  ENDIF
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
414b *
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
     C     endup2        endsr
     *
640aA*----------------------------------------------------------------
640aA*  zzzdricop  Call DRICOP
640aA*----------------------------------------------------------------
640aA
640aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   endsl

     C                   if        $dricommand = '*LICINFO'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C                   exsr      zm0105
     C                   endsl

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Multiple items for transaction
** Descsp
Productos multiples por transaccion
