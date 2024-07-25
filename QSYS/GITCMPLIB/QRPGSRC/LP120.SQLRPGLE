      /copy *libl/qcopysrc,hspecs
500 A*----------------------------------------------------------------
500 A*  Multilingual Verision
500 A*  Every screen and message has a corresponding Spanish version.
500 A*  Any changes must be made to both languages.
500 A*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LP120     Pallet License information - View  RF
     *  12 February 1997
     *  Dave Sommerville
     *  Roxanne Harrison
     *
     *  Notes
     *    Program uses Status date for putaway date because
     *    LBRDTE is not in LABEL7 file.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
221 A*    05/19/97  RH   2.21
     *      - Use option for Use generic license.
     *      - Add access info by transaction #.
     *      - IF no LABEL7 rec is found, display sc2 fields with blanks.
412 A*    09/02/99  RH   4.12
     *      - Fix to get license # if transaction # is entered.
414aA*    07/19/00  RRH  4.14a
     *      - If multiple license records exist, call License List.
414cA*    08/24/00  RRH  4.14c
     *      - Do not display item for selection trans.
     *      - Change to call PT900 with $LTRN not $LTRN#
414dA*    09/13/00  HNK  4.14d
     *      - Display pick slot on screen 2
415aA*    03/30/01  RH   4.15a
     *      - Revised to use FRMTIT2 instead of FRMTIT. This will
     *        format the item string as Desc/Pack/Item#.
     *
416 A*    03/28/02  DAS  4.16
     *      - Added W2ITM2 to screen 2. 415a change moved item # to
     *        end of desc where it would get chopped off. AFI relies
     *        on item # added it to the screen.
416aA*    05/23/02  RRH  4.16a
     *      - Change WOLCNS, W1LCNS, W2LCNS to 15 Alphanumeric.
     *      - Left justify, remove leadind blanks for license
     *
417 A*    04/28/03  DAS  4.17
     *      - Revised ZZCHK1 to use *LEFTNOZ for call to ADJUST.
     *
500 A*    05/31/06  JCJ  5.00
     *      - Added Multilingual logic.
510aA*    10/29/07  LMC  5.10a
     *      - Added 16 x 20 screens for handheld
     *
600aA*    03/05/09  DAS  6.00c  P#00045
     *      - Converted to ILE
     *      - Revised for use with new license tracking.
     *      - Screen changed from LP120FM to LP12001.
     *      - Old code removed for readability
     *
610aA*    05/28/10  DAS  6.00a
     *      - Revised to use %GETINFO instead of %GETLCNS. %GETLCNS
     *        will only look for an active license, while %GETINFO
     *        will look to see if it is in the log file.
610bA*    09/13/10  RH   6.10b
     *      - Fix: error in ZZCHK1 was not being displayed.
610cA*    09/13/10  RH   6.10c
     *      - Revised to lookup license in LICINFO if not found with
     *        DRILICENSE %GETINFO (like LP130 610c mod)
640aA*    08/18/11  RH   6.40a
     *      - Fix: Recompiled only, cursor positon changed on LP12001
640bA*    01/20/12  LMC  6.40b
     *      - Fix: clear pick slot display field if no pick slot found
650aA*    03/19/14  RH   6.50a
     *      - Enh: Add F11=Transfer to call IT252
     *             Rename format to LP12002
     *
700 A*    11/28/16  MLB  7.00
     *      - Ehn: Revised program to add client custom code support.
740aA*    02/14/20  MLB  7.40a
     *      - Ehn: Do not allow transfer from STG/RCV/USR/RTN/RWO/USR
740bA*    05/28/20  LMC  7.40b
     *      - Ehn: Allow license lookup by UCI.
740cA*    07/01/20  LMC  7.40c
     *      - Ehn: Add f7 to slot info SL630
     *             Add f8 to license history summary
     *             Add f10 to do adjustment to reactivate the license
     *             F8 and F10 only valid if the license is no longer
     *             active, These are secured options
     *      - Enh: Added call to CHKLIST.
     *      - Ehn: Show dates from licinfo if license is not active
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
     *
CBI A*    11/28/16  MLB  CBI
     *      - Enh: Revised program to call LP120B if license# not found
     *        in LICACTIVE so that it can try to find license in LICENSE
     *        file. Done to allow access to licenses received prior to
     *        Dakota WMS v6.50 upgrade.
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
650aDF**Lp12001   cf   e             workstn
740bDF*Lp12002   cf   e             workstn
740cDF*Lp12003   cf   e             workstn
740cMFLp12004   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
740cA*----------------------------------------------------------------
740cA*  Standard SQL variables and constants
740cA*----------------------------------------------------------------

740cA /copy qcopysrc,c#stdsql

740cA*----------------------------------------------------------------
740cA*  File field data structure.
740cA*----------------------------------------------------------------

740cAD llrec         e ds                  extname(liclog) inz(*EXTDFT)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
414cAD desc            s             50    dim(1) ctdata perrcd(1)
500 AD descsp          s             50    dim(1) ctdata perrcd(1)
700 A*----------------------------------------------------------------
700 A*  Customer id
700 A*
700 AD @getcl          c                   const('GETCLIENT')
700 AD client          s             10
700 AD clientloc       s             10
700 A*
CBI A /copy qcopysrc,id#cheney

600aA*----------------------------------------------------------------
600aA*  DRI parameters
600aA*----------------------------------------------------------------
600aA /COPY *libl/qcopysrc,C#DRIPARMS
600aA
600aA*----------------------------------------------------------------
600aA*  Data Formats
600aA*----------------------------------------------------------------
600aA
600cA /COPY *libl/qcopysrc,C#ITEM
600cA /COPY *libl/qcopysrc,C#LICENSE
600aA /COPY *libl/qcopysrc,C#LICINFO
740bA /COPY *libl/qcopysrc,C#UCIINFO
600cA /COPY *libl/qcopysrc,C#SLOT
600aAD savever#        s                   like($lnver#)

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
414cMD  $ltrn                 19     25  0
     *
650aAD  $lwhs2                19     21  0
650aAD  $lwhd2                22     26
650aAD  $ldsp2                27     38
650aAD  $lusr2                39     48
     *
740cAD  $lwhdp                22     26
740cAD  $ldsp1                27     38
740cAD  $litm1                39     53
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
415aD*             'FRMTIT'              C         @FMTIT
     D @fmtit          c                   const('FRMTIT2')
740cAD @autpg          c                   const('CHKLIST')
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
600eA /Copy qcopysrc,c#pgminfds
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
600aAD chk4err         s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D help            s              5  0
     D lcount          s              1  0
     D lflag           s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D ocode           s              8
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
600aAD ts              s               z
     D warn            s              1
     D wolcns          s             15
     D wotrn#          s              7  0
600aAD zmflag          s               n
600aAD zmsflag         s               n
     *----------------------------------------------------------------
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
610bDC*                  write     clrscr
500 AC                   select
500 AC                   when      e$lng = 'SP'
510aAC                   if        #lline = '16'
510aAC                   exfmt     scrn61sp                             50
510aAC                   else
500 AC                   exfmt     scrn1sp                              50
510aAC                   endif
500 AC                   other
510aAC                   if        #lline = '16'
510aAC                   exfmt     screen61                             50
510aAC                   else
     C                   exfmt     screen1                              50
510aAC                   endif
500 AC                   endsl
     C                   endif
     C                   if        nxtscr = '02 '
610bDC*                  write     clrscr
500 AC                   select
500 AC                   when      e$lng = 'SP'
510aAC                   if        #lline = '16'
510aAC                   exfmt     scrn62sp                             50
510aAC                   else
500 AC                   exfmt     scrn2sp                              50
510aAC                   endif
500 AC                   other
510aAC                   if        #lline = '16'
510aAC                   exfmt     screen62                             50
510aAC                   else
     C                   exfmt     screen2                              50
510aAC                   endif
500 AC                   endsl
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
740aAC     error         cabeq     *on           endsc2
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
700 A*
700 A* Get client id.
700 A*
700 AC                   call      @getcl
700 AC                   parm                    client
700 AC                   parm                    clientloc
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
510aAC                   select
510aAC                   when      #lline = '16'
510aAC                   write     m16ctl
510aAC                   other
     C                   write     msgctl
510aAC                   endsl
     C                   eval      msgk = *zeros
510aAC                   select
510aAC                   when      #lline = '16'
510aAC                   write     m16clr
510aAC                   other
     C                   write     msgclr
510aAC                   endsl
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
510aAC                   select
510aAC                   when      #lline = '16'
510aAC                   write     m16ctl
510aAC                   other
     C                   write     msgctl
510aAC                   endsl
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
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      $msgf = #msgsp
500 AC                   other
     C                   eval      $msgf = #msgf
500 AC                   endsl
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
510aAC                   select
510aAC                   when      #lline = '16'
510aAC                   write     m16rec
510aAC                   other
     C                   write     msgrec
510aAC                   endsl
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
510aAC                   select
510aAC                   when      #lline = '16'
510aAC                   write     m16rec
510aAC                   other
     C                   write     msgrec
510aAC                   endsl
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
221 A*   PIR0204  Enter only one value.
221 A*
221 AC     zm0204        begsr
221 AC                   eval      #msgid = 'PIR0204'
221 AC                   eval      #msgtp = '*DIAG  '
221 AC                   eval      $md = *blanks
221 AC                   exsr      zmpmsg
221 AC                   endsr
221 A*----------------------------------------------------------------
221 A*   PIR0205  Must enter one value.
221 A*
221 AC     zm0205        begsr
221 AC                   eval      #msgid = 'PIR0205'
221 AC                   eval      #msgtp = '*DIAG  '
221 AC                   eval      $md = *blanks
221 AC                   exsr      zmpmsg
221 AC                   endsr
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
     C                   eval      #msgid = 'LP11022'
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
610bAC                   leavesr
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
610bAC                   leavesr
     C                   else
     C***                movel     $lerm         whdesc
     C                   endif
     C                   endif
     *
221 A*  Must enter one, either license or transaction number.
221 A*
416aAC                   if        w1lcns = *blanks
740bAc                             and w1uci = ' '
221 AC                   eval      error = *on
221 AC                   eval      *in22 = *on
221 AC                   eval      *in02 = *on
221 AC                   eval      *in23 = *on
221 AC                   eval      *in03 = *on
221 AC                   exsr      zm0205
610bAC                   leavesr
221 AC                   endif
740bA*
740bA*  Get uciinfo
740bA*
740bAc                   if        w1uci <> ' '
740bAC                   exsr      clr$uciinfo
740bAC                   eval      $uiwhse   = w1whse
740bAC                   eval      $uiuci    = w1uci
740bAC                   eval      $dricommand = '*UCIINFO'
740bMC                   eval      $drisubcmd  = '%GET'
740bAC                   eval      $drisys2upd = 'D'
740bAC                   eval      chk4err = *on
740bAC                   eval      zmflag  = *off
740bAC                   exsr      zzzdricop
740bAC                   if        $uilcns = ' '
740bAC                   eval      errmsg = 'UCI not found'
740bAc                   eval      error = *on
740baC                   exsr      zm0105
740bAc                   leavesr
740bAc                   else
740bAc                   eval      w1lcns = $uilcns
740bAc                   endif
740bAc
740bAc                   endif
     *
416 A*  Left justify license.
416 AC                   eval      $cstr = *blanks
416 AC                   move      w1lcns        $cstr
416 AC                   call      'ADJUST'
417 MC                   parm      '*LEFTNOZ'    $ccmd             8
416 AC                   parm                    $cstr            30
416 AC                   movel     $cstr         w1lcns
     *
     *  Verify license #.
     *
610bAC                   if        w1lcns <> ' '
600cAC                   exsr      clr$license
600cAC                   eval      $liToLcnsU = *on
600cAC                   eval      $liToLcns = w1lcns
600cAC                   eval      $dricommand = '*LICENSE'
610aDC**                 eval      $drisubcmd  = '%GETLCNS'
610aMC                   eval      $drisubcmd  = '%GETINFO'
600cAC                   eval      $drisys2upd = 'D'
600cAC                   eval      chk4err = *on
600cAC                   eval      zmflag  = *off
600cAC                   exsr      zzzdricop
600cAC                   if        error
610cA
610cA*    If not found in LICACTIVE or LICLOG,
610cA*      Then see if it is in LICINFO.
610cA
610cAC                   eval      $liToDisp = 'no tracking'
610cAC                   eval      $liOLcns = w1lcns
610cA
610cAC                   exsr      clr$licinfo
610cAC                   eval      $lnemp# = 0
610cAC                   eval      $lnuser = #user
610cAC                   eval      $lnpgm  = #prog
610cAC                   eval      $lnjob  = #job
610cAC                   eval      $lnjobnbr  = #jobn
610cAC                   eval      $lnwhse  = w1whse
610cAC                   eval      $lntype  = 'P'
610cAC                   eval      $lnlcns  = w1lcns
610cAC                   eval      $lncodeu(1) = *on
610cAC                   eval      $lncode(1) = '*ITEM'
610cAC                   eval      $lncseq(1) = 1
610cAC                   eval      $dricommand = '*LICINFO'
610cAC                   eval      $drisubcmd  = '%GET'
610cAC                   eval      $drisys2upd = 'D'
610cAC                   eval      chk4err = *on
610cAC                   exsr      zzzdricop
610cA
610cAC                   if        error
CBI A*
CBI AC                   if        client = Cheney
CBI A*
CBI AC                   call      'LP120B'
CBI AC                   parm      '*NOOPTL'     $bcmd             8
CBI AC                   parm      w1whse        $bwhse            3 0
CBI AC                   parm      w1lcns        $blcns           15
CBI AC                   eval      w1lcns = ' '
740bAC                   eval      w1uci  = ' '
CBI A*
CBI AC                   else
CBI A*
600cAC                   eval      *in22 = *on
600cAC                   eval      *in02 = *on
600cAC                   eval      errmsg = *blanks
600cAC                   exsr      zm022
CBI AC                   endif
CBI A*
600cAC                   leavesr
610cAC                   endif
610cA
610cAC                   if        $lncodee(1) = $driok
610cAC                             and $lnvalchr(1) <> ' '
610cAC                   eval      $liToItem = %trim($lnvalchr(1))
610cAC                   else
610cAC                   eval      $liToItem = ' '
610cAC                   endif
610cAC                   eval      $liToSItem = $liToItem
610cA
600cAC                   endif
610bAC                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
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
221 MC                   when      row# = 3
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
650aA*
650aA*      F11 - Transfer
650aA*
650aAC                   if        *inkk
740aAC                   exsr      zzzslt
740aAC                   if        error = *on
740aAC                   exsr      zm0105
740aAC                   leavesr
740aAC                   endif
650aAC**                           $palwc <> 'N'
650a C                   eval      cmdtkn = *on
650a C                   eval      $lcmd = '*CHANGE '
650a C                   eval      $lwhs2 = $litowhse
650a C                   eval      $lwhd2 = $litowhdp
650a C                   eval      $ldsp2 = $litodisp
650a C                   eval      $lusr2 = *blanks
650a *
650a C                   call      'IT252'
650a C                   parm                    $lparm
650a C                   endif
740cA*
740cA*      F7  - Slot Info
740cA*
740cAC                   if        *inkg
740cAc                   if        w2disp = '<not active>'
740cAC                   eval      cmdtkn = *on
740cAc                   else
740cAC                   eval      cmdtkn = *on
740cAC                   eval      $lcmd = '*VIEW   '
740cAC                   eval      $lwhdp = $itwhdp
740cAC                   eval      $ldsp1 = w2disp
740cAC                   eval      $litm1 = w2itm2
740cA*
740cAC                   call      'SL630'
740cAC                   parm                    $lparm
740cAC                   endif
740cAC                   endif
740cA*
740cA*      F8  - License History Summay
740cA*
740cAC                   if        *inkh
740cAC                   eval      cmdtkn = *on
740cA*
740cAC                   call      'LT350'
740cAC                   parm      w1whse        $iWhse            3 0
740cAC                   parm      w2itm2        $iItem           15
740cAC                   parm                    $iReturn          8
740cAC                   parm      w2lcns        $ilcnsdisp       15
740cAC                   endif
740cA*      F10 - Reactivate License
740cA*
740cAC                   if        *inkj
740cAC                   eval      cmdtkn = *on
740cA*
740cAC                   call      'IT220'
740cAC                   parm      w1lcns        $ilcnsdisp
740cAC                   parm                    $itwhdp
740cAC                   endif
650a C     endcm2        tag
650a *
650aAC                   if        cmdtkn = *on
650aAC                   eval      refrsh = *on
650aAC                   exsr      clr$license
650aAC                   eval      $liToLcnsU = *on
650aAC                   eval      $liToLcns = w1lcns
650aAC                   eval      $dricommand = '*LICENSE'
650aAC                   eval      $drisubcmd  = '%GETINFO'
650aAC                   eval      $drisys2upd = 'D'
650aAC                   eval      chk4err = *on
650aAC                   eval      zmflag  = *off
650aAC                   exsr      zzzdricop
650aAC                   exsr      scr02i
650aAC                   endif
650aMC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
416aMC                   eval      w1lcns = *blanks
740bAC                   eval      w1uci  = ' '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
600aA
600aA*  Get license info
600aA
600aAC                   eval      w2lcns = w1lcns
600aAC                   eval      w2itm2 = $liToItem
600aAC                   eval      w2disp = $liToDisp

740aA*     Turn on slot info if License is active
740aA*     Turn on adjustment if License is not active
740cAc                   if        w2disp = '<not active>'
740cAc                   eval      *in40 = *off
740cAc                   eval      *in41 = *on
740cAc                   else
740cAc                   eval      *in40 = *on
740cAc                   eval      *in41 = *off
740cAc                   endif

740cAC                   call      @autpg
740cAC                   parm                    #prog
740cAC                   parm      'F10'         pgmopt           20
740cAC                   parm                    #user
740cAC                   parm                    $prtn            10
740cAC                   if        $prtn = '*NO'
740cAC                   eval      *in41 = *off
740cAC                   endif
600aA
600aA*     License qty
600aA
     C                   eval      $cvcmd = '*QTY2STR'
     C                   eval      $cvqty1 = $liToRQty1
     C                   eval      $cvqty2 = $liToRQty2
     C                   eval      $cvqty3 = $liToRQty3
     C                   eval      $cvqstr = *blanks

     C                   call      'CVTQTY'
     C                   parm                    $cvcmd            8
     C                   parm                    $cvprg           10
     C                   parm                    $cvqty1           7 0
     C                   parm                    $cvqty2           7 0
     C                   parm                    $cvqty3           7 0
     C                   parm                    $cvum1            2
     C                   parm                    $cvum2            2
     C                   parm                    $cvum3            2
     C                   parm                    $cvqstr          10
     C                   parm                    $cvustr          17
     C                   parm                    $cvrtn            8
     C                   parm                    $cverm           60

     C                   eval      w2qty = $cvqstr
600cA
600cA*     License Entered date
600aA
600cAC                   if        $liToEntD > 0
416 AC                   eval      $cvcmd = '*CMDMDY '
600cAC                   eval      $cvd8i = %char($liToEntD)
600cAC                   call      @cvtdt
600cAC                   parm                    $cvtdt
600cAC                   eval      w2entd = $cvd6o
600cAC                   else
600cAC                   eval      w2entd = 0
600cAC                   endif
600cA
600cA*     License Expiration date
600aA
600cAC                   if        $liToExpD > 0
600cAC                   eval      w2expd = %char(
600cAC                                      %date($liToExpD:*iso)
600cAC                                      :*mdy/)
600cAC                   else
600cAC                   eval      w2expd = 'n/a'
600cAC                   endif
600cA
600cA*  Get slot info
600cA
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = w1whse
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = $liToSItem
     C                   eval      $slstatu = *on
     C                   eval      $slstat  = 'A'
     C                   eval      $slprtyu = *on
     C                   eval      $slprty  = -9
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd  = 0
     C                   eval      $slentdu = *on
     C                   eval      $slentd  = 0
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = ' '
     C                   eval      $slstypu = *on
     C                   eval      $slstyp  = ' '
     C                   eval      $slaislu = *on
     C                   eval      $slaisl  = ' '
     C                   eval      $slpsequ = *on
     C                   eval      $slpseq  = 0
     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl  = 0
     C                   eval      $slhandu = *on
     C                   eval      $slhand  = ' '

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%NXTPICK'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   eval      $sldisp = ' '
640bDC*                  else
640bMC                   endif
     C                   eval      w2pslt = $sldisp
640bDC*                  endif

     *   Get license item

     C                   exsr      clr$item
     C                   eval      $itwhse  = w1whse
     C                   eval      $ititem  = $liToItem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   eval      w2item = %trim($liToItem)
     C                                    + ': ' + $drimessage
     C                   else
     C                   call      @fmtit
     C                   parm                    $ititem
     C                   parm                    $itdesc
     C                   parm                    $itpdsc
     C                   parm                    $istr            70
     C                   eval      w2item = $istr
     C                   endif
740cA /free

740cA   // only execute if we don't have the dates already
740cA   if w2entd = 0;
740cA     // now get last liclog record
740cA     exec sql select * into :llrec
740cA              from liclog
740cA              where llolcns = :w2lcns
740cA              Order by lladdts desc
740cA              fetch first row only;
740cA      if sqlstt = sqlSuccess;
740cA        if llexpd = 0;
740cA          w2expd = 'n/a';
740cA        else;
740cA          w2expd = %char(
740cA                 %date(llexpd:*iso)
740cA                 :*mdy/);
740cA        endif;

740cA /end-free
740cAC                   if        llentd > 0
740cAC                   eval      $cvcmd = '*CMDMDY '
740cAC                   eval      $cvd8i = %char(llentd)
740cAC                   call      @cvtdt
740cAC                   parm                    $cvtdt
740cAC                   eval      w2entd = $cvd6o
740cAC                   else
740cAC                   eval      w2entd = 0
740cAC                   endif
740cA /free
740cA      endif;
740cA    endif;
740cA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
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
510aA*
510aA*   Get screen size being used.
510aA*
510aAC                   call      'PIRRFSCR'
510aAC                   parm      '*GET'        #lcmd             8
510aAC                   parm                    #lline            2
510aAC                   parm                    #lcol             3
500 A*
500 A*   Get employee options.
500 A*
500 AC                   call      'GETUSER'
500 AC                   parm      #user         e$code           10
500 AC                   parm                    e$whse            3 0
500 AC                   parm                    e$emp#            5 0
500 AC                   parm                    e$fnam           15
500 AC                   parm                    e$init            1
500 AC                   parm                    e$lnam           20
500 AC                   parm                    e$whdp            5
500 AC                   parm                    e$styp            1
500 AC                   parm                    e$shft            6
500 AC                   parm                    e$crew            6
500 AC                   parm                    e$nhrs            3 1
500 AC                   parm                    e$rtn             8
500 AC                   parm                    e$bpu             1
500 AC                   parm                    e$lng             2
500 AC                   if        e$rtn <> '*OK'
500 AC                   eval      e$lng = 'EN'
500 AC                   endif
500 A*
     *
     *   Select first screen to display.
     *
221 MC                   call      'GETWHSE'
221 MC                   parm                    #user
221 MC                   parm      0             #whse             3 0
221 MC                   eval      w1whse = #whse
     *
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
416aAC                   eval      wolcns = w1lcns
414a *
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C     endup2        endsr

600cA*----------------------------------------------------------------
600cA*----------------------------------------------------------------
600cA*                     DRI SUBROUTINES
600cA*----------------------------------------------------------------
600cA*----------------------------------------------------------------

600cA*----------------------------------------------------------------
600cA*  clr$item  Clear $item data structure fields
600cA*----------------------------------------------------------------
600cA
600cAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600cA*----------------------------------------------------------------
600cA*  clr$license  Clear $license data structure fields
600cA*----------------------------------------------------------------
600cA
600cAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = e$emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = w1whse
     C                   eval      $liTowhseu = *on
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$licinfo  Clear $licinfo data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$licinfo   begsr
600aAC                   eval      savever# = $lnver#
600aAC                   clear                   $licinfo
600aAC                   eval      $lnver# = savever#
600aA
600aAC                   eval      $lnuser = #user
600aAC                   eval      $lnpgm  = #prog
600aAC                   eval      $lnjob  = #job
600aAC                   eval      $lnjobnbr = #jobn
600aA
600aAC                   endsr

600cA*----------------------------------------------------------------
600cA*  clr$slot  Clear $slot data structure fields
600cA*----------------------------------------------------------------
600cA
600cAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#
     C                   endsr
600cA
740bA*----------------------------------------------------------------
740bA*  clr$uciinfo  Clear $uciinfo data structure fields
740ba*----------------------------------------------------------------

740bAC     clr$uciinfo   begsr
740bAC                   eval      savever# = $uiver#
740baC                   clear                   $uciinfo
740bAC                   clear                   $uciinfo2
740bAC                   eval      $uiver# = savever#
740bAC                   eval      $uiaddemp = e$emp#
740bAC                   eval      $uiaddusr = #user
740baC                   eval      $uiaddpgm  = #prog
740bAC                   eval      $uiaddjob  = #job
740baC                   eval      $uiaddnbr = #jobn
740bAC                   endsr
600cA*----------------------------------------------------------------
600cA*  zzzdricop  Call DRICOP
600cA*----------------------------------------------------------------
600cA
600cAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
740bAC                   when      $dricommand = '*UCIINFO'
740bAC                   eval      $dridata = $uciinfo
740bAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
740bAC                             or $dricommand = '*UCIINFO'
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
     C**                 exsr      zm0105s
     C                   when      zmflag
     C                   exsr      zm0105
     C                   endsl

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C**                 exsr      zm0001s
     C                   when      zmflag
     C**                 exsr      zm0001
     C**                 exsr      zzerrind
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
740bAC                   when      $dricommand = '*UCIINFO'
740bAC                   eval      $uciinfo = $dridata
740bAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
740aA*----------------------------------------------------------------
740a *
740a *  ZZZSLT   Check if Slot can be transfered
740a *
740a C     zzzslt        begsr
740a C                   eval      error = *off
740aA*
740aA*  Do not allow the transfer from a RCV file.
740aA*                                $liToDisp
740aAC                   if        %subst($liToDisp:1:3) = 'RCV'
740aAC                              or %subst($liToDisp:1:3) = 'RTN'
740aAC                              or %subst($liToDisp:1:3) = 'RWO'
740aAC                              or %subst($liToDisp:1:3) = 'STG'
740aAC                   eval      error = *on
740aAC                   eval      *in23 = *on
740aAC                   eval      *in03 = *on
740aAC                   eval      errmsg = 'RCV/RTN/RWO/STG slot not allowed '
740aAC                                    + '- use Putaway'
740aAC                   leavesr
740aAC                   endif
740aA*
740aA*  Do not allow the transfer from a USR slot.
740aA*
740aAC                   if        %subst($liToDisp:1:3) = 'USR'
740aAC                   eval      error = *on
740aAC                   eval      *in23 = *on
740aAC                   eval      *in03 = *on
740aAC                   eval      errmsg = 'USR slot not allowed '
740aAC                                    + '- use Item Maint'
740aAC                   leavesr
740aAC                   endif

740aAC     endslt        endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
Multiple items for transaction
** DESCSP
Productos multiples por transaccion
