     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LP120B    Pallet License information - View  RF Pre-License Track
     *  28 November 2016
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes
     *  - Program uses Status date for putaway date because
     *    LBRDTE is not in LABEL7 file.
     *  - Program uses pre-license tracking logic for retrieving
     *    license information using LICENSE file. Needed for clients
     *    with extensive active licenses, off-site storage, etc.
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
700 A*    11/28/16  MLB  7.00
     *      - Enh: Added client custom code support.
     *
     *----------------------------------------------------------------
     *    Client Custom Revisions: Cheney Brothers
CBI A*    04/15/02  HNK  CBI
     *      - Custom revised to use FRMTIT instead of FRMTIT2. They
     *        use hand held and item number needs to be before desc.
CBIaA*    11/28/16  MLB  CBIa
     *      - Enh: Revised pgm to receive license from LP120 and use
     *        file LICENSE look-up logic for displaying license info.
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
     FLp120bfm  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     FLicense   if   e           k disk
412 AFLicense1  if   e           k disk
     F                                     rename(lirec:record)
     Fpiritem   if   e           k disk
     FLabel7    if   e           k disk
221 AFoptions   if   e           k disk
414cAFpirtran   if   e           k disk
414dAFslot3     if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
414cAD desc            s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
221 A* Data structure
221 A*
221 AD opdata          ds
221 AD  oplpgm                 1     10
221 AD  opupct                11     13  0
221 AD  oppdef                14     14  0
221 AD  oppbld                15     15  0
221 AD  oppact                16     16  0
221 AD  opfdef                17     17  0
221 AD  opfasl                18     18  0
221 AD  opfsid                19     19  0
221 AD  opflvl                20     20  0
221 AD  oppasl                21     21  0
221 AD  oppfrc                22     22
221 AD  opplcn                23     23
221 AD  optend               117    117
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
416aD*                                      22  280$LLCNS
416aD*                                      29  350$LTRN#
     *
414cMD  $ltrn                 19     25  0
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
CBIaD*             'FRMTIT2'             C         @FMTIT
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
     *  Working variables
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
     D help            s              5  0
     D k3pick          s                   like(slpick)
     D k3stat          s                   like(slstat)
     D lcount          s              1  0
     D lflag           s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D ocode           s              8
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1
     D wolcns          s             15
     D wotrn#          s              7  0
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
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *      $PCMD    *NOOPTL - Don't get options
     *      $PWHSE   Warehouse number
     *      $Plcns   License plate to be used with *NOOPTL
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $plcns           15
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
414aAC                   write     clrscr
     C                   exfmt     screen1                              50
     C                   endif
     C                   if        nxtscr = '02 '
414aAC                   write     clrscr
     C                   exfmt     screen2                              50
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
CBIbA*
CBIbAC                   if        $pcmd = '*NOOPT'
CBIbAC                             or $pcmd = '*NOOPTL'
CBIbAC                   eval      nxtscr = 'EOJ'
CBIbAC                   else
CBIbA*
     C                   exsr      scr01i
CBIbAC                   endif
CBIbA*
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
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     *R                   Z-ADDPHWHSE    $KWHSE
     *R                   Z-ADDW1WHSE    WHCODE
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
     *
221 A*  Enter only one, either license or transaction number.
221 A*
416aD**         W1LCNS    IFNE 0
416aMC                   if        w1lcns <> *blanks  and
221 AC                             w1trn# <> 0
221 AC                   eval      error = *on
221 AC                   eval      *in22 = *on
221 AC                   eval      *in02 = *on
221 AC                   eval      *in23 = *on
221 AC                   eval      *in03 = *on
221 AC                   exsr      zm0204
221 AC                   endif
     *
221 A*  Must enter one, either license or transaction number.
221 A*
416aD**         W1LCNS    IFEQ 0
416aAC                   if        w1lcns = *blanks  and
221 AC                             w1trn# = 0
221 AC                   eval      error = *on
221 AC                   eval      *in22 = *on
221 AC                   eval      *in02 = *on
221 AC                   eval      *in23 = *on
221 AC                   eval      *in03 = *on
221 AC                   exsr      zm0205
221 AC                   endif
     *
416 A*  Left justify license.
416 AC                   eval      $cstr = *blanks
416 AC                   move      w1lcns        $cstr
416 AC                   call      'ADJUST'
417 D**                   PARM '*LEFT   '$CCMD   8
417 MC                   parm      '*LEFTNOZ'    $ccmd             8
416 AC                   parm                    $cstr            30
416 AC                   movel     $cstr         w1lcns
     *
     *  Verify license #.
     *
416aD**         W1LCNS    IFNE 0
416aMC                   if        w1lcns <> *blanks  and
221 AC                             w1trn# = 0
     C     lcnsky        chain     license                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   exsr      zm022
     C                   endif
221 AC                   endif
     *
221 A*  Verify transaction number.
221 A*
221 AC                   if        w1trn# <> 0  and
416aD**         W1LCNS    ANDEQ0
416aMC                             w1lcns = *blanks
221 AC                   eval      $lcmd = '*VERIFY '
414cD**                   Z-ADDW1TRN#    $LTRN#
414cMC                   eval      $ltrn = w1trn#
221 AC                   call      'PT900'
221 AC                   parm                    $lparm
221 AC                   if        $lrtn = '*PGMQ   '
221 AC                   eval      error = *on
221 AC                   eval      *in23 = *on
221 AC                   eval      *in03 = *on
221 AC                   eval      #msgk = $lmsg
221 AC                   exsr      zmqmsg
221 AC                   endif
221 AC                   endif
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
     *
221 D*R         ROW#      WHEQ 7
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
221 D*R                   CALL 'GETWHSE'
221 D*R                   PARM           #USER
221 D*R                   PARM 0         #WHSE   30
     *
221 D*R                   Z-ADD#WHSE     W1WHSE
416aD**                   Z-ADD0         W1LCNS
416aMC                   eval      w1lcns = *blanks
221 AC                   eval      w1trn# = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
    D*R         LITRN#    CHAINLABEL                79
     C     lbkey         setll     label7
     C     lbkey         reade     label7                                 79
221 AC                   if        not *in79
412 D*R                   Z-ADDW1LCNS    W2LCNS
416aD**                   Z-ADDWOLCNS    W2LCNS
416aMC                   eval      w2lcns = wolcns
     C                   eval      w2trn# = lbtrn#
     C                   move      lbitem        w2item
     C                   eval      w2disp = lbdisp
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      lbsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
CBI DC*                  eval      w2pdte = $cvd6o
CBI MC                   eval      w2entd = $cvd6o
     *R                   MOVE LBSDTE    W2PDTE
     C                   eval      w2pqty = lbqpck
     *   Item description and pack description.
     C                   exsr      zzgeti
414cA*   Get transaction task
414cAC     lbtrn#        chain     pirtran                            78
414cAC                   if        not *in78  and
414cAC                             ptcat = 'SELECT'
414cAC                   movel     desc(1)       w2item
414cAC                   eval      w2disp = *blanks
414cAC                   eval      w2pqty = ptpcs
414cAC                   endif
221 AC                   else
416aD**                   Z-ADDW1LCNS    W2LCNS
416aMC                   eval      w2lcns = w1lcns
221 AC                   eval      w2trn# = w1trn#
221 AC                   eval      w2item = *blanks
221 AC                   eval      w2disp = *blanks
CBI DC*                  eval      w2pdte = 0
CBI MC                   eval      w2entd = 0
CBI AC                   eval      w2expd = ' '
221 AC                   eval      w2pqty = 0
221 AC                   endif
     *
414dA*  Get first picking slot for item.
414dA*
414dAC                   eval      w2pslt = *blanks
414dAC                   eval      k3stat = 'A '
414dAC                   eval      k3pick = 'Y'
414dAC     keys3         setll     slot3
414dAC     keys3         reade     slot3                                  79
414dAC                   if        *in79
414dAC                   eval      w2pslt = *blanks
414dAC                   else
414dAC                   eval      w2pslt = sldisp
414dAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGETI   Get item description and pack description.
     *
     C     zzgeti        begsr
     *
     *
     C                   eval      w2item = *blanks
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   endif
     C                   eval      $iitem = lbitem
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         w2item
416 AC                   eval      w2itm2 = lbitem
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
     *
     C     lcnsky        klist
     C                   kfld                    w1whse
     C                   kfld                    w1lcns
412 A*
412 AC     lcn1ky        klist
412 AC                   kfld                    w1whse
412 AC                   kfld                    wotrn#
     *
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    lbitem
     *
    AC     lbkey         klist
221 AC                   kfld                    wotrn#
221 D*R                   KFLD           LITRN#
221 A*     OPTIONS
221 A*
221 AC     opkey         klist
221 AC                   kfld                    w1whse
221 AC                   kfld                    ocode
414dA*
414dA*  Define partial key for SLOT3 file.
414dA*
414dAC     keys3         klist
414dAC                   kfld                    lbwhse
414dMC                   kfld                    lbitem
414dAC                   kfld                    k3stat
414dAC                   kfld                    k3pick
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
221 MC                   call      'GETWHSE'
221 MC                   parm                    #user
221 MC                   parm      0             #whse             3 0
221 MC                   eval      w1whse = #whse
     *
221 AC                   exsr      zzlcns
CBI A*
CBI AC                   if        $pcmd = '*NOOPTL'
CBI AC                   eval      w1lcns = *blanks
CBI A*
CBI AC                   if        %parms >= 3
CBI AC                   eval      w1lcns = $plcns
CBI AC                   eval      wolcns = $plcns
CBI AC                   endif
CBI A*
CBI AC                   exsr      zzupd1
CBI AC                   else
CBI A*
     C                   eval      refrsh = *on
     C                   exsr      scr01i
CBI AC                   endif
CBI A*
     C                   endsr
     *----------------------------------------------------------------
     *
221 A*  ZZLCNS   Get use generic license option
     *
221 AC     zzlcns        begsr
     *
221 A*   Get use generic license option.
221 AC                   eval      lflag = *off
221 AC                   eval      *in35 = *off
221 AC                   eval      ocode = '*RCVLBL '
     *
221 AC     opkey         chain     options                            79
221 AC                   if        not *in79
221 AC                   if        opplcn = 'Y'
221 AC                   eval      lflag = *on
221 AC                   eval      *in35 = *on
221 AC                   endif
221 AC                   endif
     *
221 AC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
416aD**         W1LCNS    IFNE 0
416aMC                   if        w1lcns <> *blanks
416aD**                   Z-ADDW1LCNS    WOLCNS
416aAC                   eval      wolcns = w1lcns
CBIbA*
CBIbAC                   if        $pcmd = '*NOOPTL'
CBIbAC     lcnsky        chain     license                            79
CBIbAC                   if        not *in79
CBIbAC                   eval      wolcns = lilcns
CBIbAC                   else
CBIbAC                   eval      lilcns = *blanks
CBIbAC                   eval      wolcns = *blanks
CBIbAC                   endif
CBIbA*
CBIbAC                   endif
CBIbA*
412 AC                   endif
221 AC                   if        w1trn# <> 0
221 AC                   eval      wotrn# = w1trn#
412 AC     lcn1ky        chain     license1                           79
412 AC                   if        not *in79
416aD**                   Z-ADDLILCNS    WOLCNS  70
416aMC                   eval      wolcns = lilcns
412 AC                   endif
221 AC                   else
221 AC                   eval      wotrn# = litrn#
221 AC                   endif
414a *
414a *  Check if multiple LICENSE records exist.
414a *
414aAC                   eval      lcount = 0
414aAC     lcnsky        setll     license
414aAC     nxtli         tag
414aAC     lcnsky        reade     license                                78
414aAC                   if        not *in78
414aAC                   add       1             lcount
414aAC                   goto      nxtli
414aAC                   endif
414a *
414a *  Get LICENSE Transaction if multiple License exist.
414a *
414aAC                   if        lcount > 1
414aAC                   eval      $lcmd = '*LOOKUP '
414aAC                   eval      $lwhse = w1whse
416aD**                   Z-ADDWOLCNS    $LLCNS
416aMC                   eval      $llcns = wolcns
414aAC                   eval      $ltrn# = wotrn#
414aAC                   call      'LP145'
414aAC                   parm                    $lparm
414aAC                   if        $lrtn = '*ERROR  '
414aAC                   eval      error = *on
414aAC                   eval      *in21 = *on
414aAC                   eval      *in01 = *on
414aAC                   movel     $lerm         errmsg
414aAC                   exsr      zm0105
414aAC                   else
414aAC                   if        $lrtn = '*PGMQ   '
414aAC                   eval      error = *on
414aAC                   eval      *in21 = *on
414aAC                   eval      *in01 = *on
414aAC                   eval      #msgk = $lmsg
414aAC                   exsr      zmqmsg
414aAC                   else
416aD**                   Z-ADD$LLCNS    WOLCNS
416aMC                   eval      wolcns = $llcns
414aAC                   eval      wotrn# = $ltrn#
414aAC                   endif
414aAC                   endif
414aAC                   if        $lrtn = '*CANCEL'  or
414aAC                             $lrtn = '*ERROR '  or
414aAC                             $lrtn = '*PGMQ  '
414aAC                   eval      error = *on
414aAC                   endif
414aAC     error         cabeq     *on           endup1
414aAC                   endif
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
     *
CBIbA*
CBIbAC                   if        $pcmd = '*NOOPT'
CBIbAC                             or $pcmd = '*NOOPTL'
CBIbAC                   eval      nxtscr = 'EOJ'
CBIbAC                   else
CBIbA*
     C                   exsr      scr01i
CBIbAC                   endif
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Multiple items for transaction
