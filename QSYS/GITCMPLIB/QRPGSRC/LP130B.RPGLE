     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  LP130B    Pallet License information - View  RF(Full Screen)
     *  08 September, 1999
     *  Hemant Kapadia
     *
     *  Notes
     *    Program uses Status date for putaway date because
     *    LBRDTE is not in LABEL7 file.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    09/08/99  HNK  4.12
     *      - Created
     *    02/08/00  RH   4.13
     *      - Fix, W2LCNS was not being cleared if no license exists. d
     *    07/13/00  RH   4.14a
     *      - Add trans. type (task code and task category code).     d
414bA*    07/19/00  RRH  4.14b
     *      - If multiple license records exist, call License List.
414cA*    08/24/00  RRH  4.14c
     *      - Do not display item for selection trans.
     *      - Change to call PT900 with $LTRN not $LTRN#
414dA*    09/13/00  HNK  4.14d
     *      - Display pick slot on screen 2
     *
414eA*    10/12/00  DAS  4.14
     *      - Added parameters so this can be called by list display  d
     *        program.                                                d
     *      - Added fields to screen: W2GDTE, W2GTIM, W2RDTE, W2RTIM,
     *        W2RUSR, W2RDEV.
     *
415 A*    06/28/01  MLB  4.15
     *      - Revised ZZTRAN to build string using first, middle and
     *        last name for user.
     *
416 A*    08/16/01  MLB  4.16
     *      - Revised ZZRCV to load expiration, mfr dates on screen.
     *      - Added file POMFR1.
416aA*    05/23/02  RRH  4.16a
     *      - Change WOLCNS, W1LCNS, W2LCNS to 15 Alphanumeric.
     *      - Left justify, remove leadind blanks for license
416bA*    01/23/03  HNK  4.16b
     *      - Add vendor info on screen 2.
     *
417 A*    04/28/03  DAS  4.17
     *      - Revised ZZCHK1 to use *LEFTNOZ for call to ADJUST.
417aA*    05/20/04  RH   4.17
     *      - ENH: Add screen 3 to display selection info.
     *
500 A*    10/06/05  DAS  5.00
     *      - FIX: Revised to compare tran#'s when getting POMFR rec.
     *
500aA*    10/25/05  RLP  5.00a
     *      - FIX: Revised to redisplay selection screen (LP140) on
     *             F12 from screen2 of LP130B if LCOUNT > 1.
     *             Changes to SC2 and ZZUPD1.
     *
700 A*    11/27/16  MLB  7.00
     *      - Enh: Converted pgm to ILE.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
CBI A*    06/21/04  CBI-JGD
     *      Set 'Tran. #.' field as cursor default location.
     *      Blankout Screen01 fields when comming back from Screen02.
     *
CBIaA*    11/19/14  CBIa-JGD
     *      Replace file POMFR1 with new logical POMFR2, the reason
     *      being, to get the actual receiving information to display.
     *      Before this change, if a received item info is loaded into
     *      POMFR and later an item return carrying is processed, this
     *      information is also loaded into POMFR without a PO #,
     *      because is a return, and if this return record is carrying
     *      the same label # as the receiving record (due to POMFR
     *      file weekly clean up no being working, thus creating label
     *      duplication) then when the receiving information is being
     *      retrieved thru EPM/Opt # 17 using the transaction # to
     *      chain to PORCV to get the label # (PORLBL) to be used to
     *      chain to POMFR1, the record obtained is the Return record
     *      above described, and when the transaction # from file
     *      PORCV (which is the actual Receiving transaction #) is
     *      compared to the obtained POMFR1 transacion # (which
     *      is the Return transaction) the two transaction don't
     *      match, causing the not retrieving of the expiration
     *      date, therefore is not able to display it on the screen.
CBIbA*    11/27/16  MLB  CBIb
     *      - Revised pgm to accept license parm from LP130.
     *        Needed in order to look up license info for pre-upgrade
     *        license plates.
CBIcA*    11/28/16  MLB  CBIc
     *      - Revised pgm to activate CBIa mods that were disabled
     *        as CBI1 mod.
CBIdA*    04/15/17  MLB  CBId
     *      - Fix: Revised pgm to log error when license sent to pgm
     *        from LP130 is not found. Update to CBIb.
     *      - Changed pgm to use POMFR3 instead of POMFR2. POMFR2 was
     *        custom to CBI. POMFR3 will be new base file chg.
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
     FLp130b01  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     FLicense   if   e           k disk
     FLicense1  if   e           k disk
     F                                     rename(lirec:record)
     Fpiritem   if   e           k disk
     Fpiruser1  if   e           k disk
CBIaD*>POMFR1  IF  E           K        DISK
CBIdDF*omfr2    if   e           k disk
CBIdMFpomfr3    if   e           k disk
     FLabel7    if   e           k disk
     Foptions   if   e           k disk
     Fpirtran   if   e           k disk
     Fslot2     if   e           k disk
414dAFslot3     if   e           k disk
     F                                     rename(slrec:slrec3)
414eAFporcv1    if   e           k disk
416bAFpohdr     if   e           k disk
416bAFpohhdr    if   e           k disk
417aAFrtehed    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
414cAD desc            s             50    dim(1) ctdata perrcd(1)
416bAD a11             s              1    dim(11)
     *----------------------------------------------------------------
     * Data structure
     *
     D opdata          ds
     D  oplpgm                 1     10
     D  opupct                11     13  0
     D  oppdef                14     14  0
     D  oppbld                15     15  0
     D  oppact                16     16  0
     D  opfdef                17     17  0
     D  opfasl                18     18  0
     D  opfsid                19     19  0
     D  opflvl                20     20  0
     D  oppasl                21     21  0
     D  oppfrc                22     22
     D  opplcn                23     23
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
416aD*                                      22  280$LLCNS
416aD*                                      29  350$LTRN#
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
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Working variables
     *
     D $msgf           s             10
     D $pstr           s             50
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
     D flag            s              1
     D forevr          s              1
     D help            s              5  0
     D i               s              2  0
     D kyrtid          s              5
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
     D tmp11a          s             11
     D warn            s              1
     D wolcns          s             15
     D wotrn#          s              7  0
     D w2ven           s             11
     D w2vnam          s             40
     D x               s              2  0
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
414eD**     None
414eA*      $PCMD    *NOOPT  - Don't get options
CBIbA*               *NOOPTL - Don't get options
414eA*      $PTRN#   Transaction # to be used with *NOOPT
CBIbA*      $Plcns   License plate to be used with *NOOPTL
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
414eAC     *entry        plist
414eAC                   parm                    $pcmd             8
414eAC                   parm                    $ptrn#            7 0
CBIbAC                   parm                    $plcns           15
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
417a C     nxtscr        caseq     '03 '         sc3
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
417a C                   if        nxtscr = '03 '
417a C                   exfmt     screen3                              50
417a C                   endif
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
417a *----------------------------------------------------------------
417a *
417a *  Screen 03 initialization
417a *
417a C     scr03i        begsr
417a C                   eval      nxtscr = '03 '
417a C                   if        refrsh = *on
417a C                   exsr      zzfil3
417a C                   endif
417a C                   eval      refrsh = *off
417a C     end03i        endsr
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
CBI A*R                   MOVE *OFF      REFRSH
CBI MC                   eval      refrsh = *on
500aAC                   if        lcount > 1  and
500aAC                             $lrtn <> '*CANCEL'  and
500aAC                             $lrtn <> '*EXIT  '
500aAC                   exsr      zzupd1
500aAC                   else
414eAC                   if        $pcmd = '*NOOPT'
CBIbAC                             or $pcmd = '*NOOPTL'
414eAC                   eval      nxtscr = 'EOJ'
414eAC                   else
     C                   exsr      scr01i
414eAC                   endif
500aAC                   endif
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
417a *----------------------------------------------------------------
417a *
417a *  SC3  -  Screen 3
417a *
417a C     sc3           begsr
417a *
417a *  Test for F3 - Exit
417a *
417a C                   if        *inkc
417a C                   eval      nxtscr = 'EOJ'
417a C                   goto      endsc3
417a C                   endif
417a *
417a *  Test for F5 - Refresh
417a *
417a C                   if        *inke
417a C                   eval      refrsh = *on
417a C                   exsr      scr03i
417a C                   goto      endsc3
417a C                   endif
417a *
417a *  Test for F12 - Previous
417a *
417a C                   if        *inkl
417a C                   eval      refrsh = *off
414eAC                   if        $pcmd = '*NOOPT'
CBIbAC                             or $pcmd = '*NOOPTL'
414eAC                   eval      nxtscr = 'EOJ'
414eAC                   else
417a C                   exsr      scr01i
414eAC                   endif
417a C                   goto      endsc3
417a C                   endif
417a *
417a *  Test for other command keys BEFORE verification and update.
417a *
417a C                   eval      cmdchk = '*BEFORE '
417a C                   exsr      zzcmd3
417a C     cmdtkn        cabeq     *on           endsc3
417a *
417a *  Some other key pressed.
417a *
417a *     Check input and write/update record.
417a *
417a C                   exsr      zzchk3
417a C     error         cabeq     *on           endsc3
417a C                   exsr      zzupd3
417a C     error         cabeq     *on           endsc3
417a *
417a *  Test for other command keys AFTER verification and update.
417a *
417a C                   eval      cmdchk = '*AFTER  '
417a C                   exsr      zzcmd3
417a C     cmdtkn        cabeq     *on           endsc3
417a *
417a C     endsc3        endsr
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
     *   PIR0204  Enter only one value.
     *
     C     zm0204        begsr
     C                   eval      #msgid = 'PIR0204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0205  Must enter one value.
     *
     C     zm0205        begsr
     C                   eval      #msgid = 'PIR0205'
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
     *  Enter only one, either license or transaction number.
     *
416aD**         W1LCNS    IFNE 0
416aMC                   if        w1lcns <> *blanks  and
     C                             w1trn# <> 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   exsr      zm0204
     C                   endif
     *
     *  Must enter one, either license or transaction number.
     *
416aD**         W1LCNS    IFEQ 0
416aAC                   if        w1lcns = *blanks  and
     C                             w1trn# = 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   exsr      zm0205
     C                   endif
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
     C                             w1trn# = 0
     C     lcnsky        chain     license                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   exsr      zm022
     C                   endif
     C                   endif
     *
     *  Verify transaction number.
     *
     C                   if        w1trn# <> 0  and
416aD**         W1LCNS    ANDEQ0
416aMC                             w1lcns = *blanks
     C                   eval      $lcmd = '*VERIFY '
414CD**                   Z-ADDW1TRN#    $LTRN#
414CMC                   eval      $ltrn = w1trn#
     C                   call      'PT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
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
417a *
417a *  ZZCHK3   Screen 3 error checking.
417a *
417a C     zzchk3        begsr
417a C                   eval      error = *off
417a *
417a *
417a C     endck3        endsr
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
     C                   when      row# = 7
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
417a *----------------------------------------------------------------
417a *
417a *  ZZCMD3   User defined command keys for screen 3.
417a *
417a C     zzcmd3        begsr
417a C                   eval      cmdtkn = *off
417a *
417a *  Test for F4 - Lookup
417a *
417a C                   if        *inkd
417a C                   eval      cmdtkn = *on
417a C                   z-add     0             row#
417a C                   eval      row = rowin
417a C                   z-add     0             col#
417a C                   eval      col = colin
417a *
417a C                   select
417a *
417a C                   other
417a *
417a *     Cursor not on a valid lookup field.
417a *
417a C                   eval      error = *on
417a C                   exsr      zm9905
417a C                   endsl
417a C                   goto      endcm3
417a C                   endif
417a *
417a C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
416aD**                   Z-ADD0         W1LCNS
416aMC                   eval      w1lcns = *blanks
     C                   eval      w1trn# = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C     lbkey         setll     label7
     C     lbkey         reade     label7                                 79
     C                   if        not *in79
416aD**                   Z-ADDWOLCNS    W2LCNS
416aMC                   eval      w2lcns = wolcns
     C                   eval      w2trn# = lbtrn#
     C                   move      lbitem        w2item
     C                   eval      w2disp = lbdisp
414eD**                   MOVE '*CMDMDY '$CVCMD
414eD**                   MOVE LBSDTE    $CVD8I
414eD**                   CALL @CVTDT
414eD**                   PARM           $CVTDT
414eD**                   Z-ADD$CVD6O    W2PDTE
     C                   eval      w2pqty = lbqpck
     *
     C                   if        lbstat = 'A'
     C                   eval      w2lbst = @stata
     C                   endif
     *
     C                   if        lbstat = 'B'
     C                   eval      w2lbst = @statb
     C                   endif
     *
     C                   if        lbstat = 'P'
     C                   eval      w2lbst = @statp
     C                   endif
     *
     C                   if        lbstat = 'C'
     C                   eval      w2lbst = @statc
     C                   endif
     *
     *   Item description and pack description.
     C                   exsr      zzgeti
     *   Transaction details
     C                   exsr      zztran
414eA*   Receiving details
414eAC                   exsr      zzrcv
     *   Slot details
     C                   exsr      zzslot
414cAC                   if        ptcat = 'SELECT'
414cAC                   movel     desc(1)       w2item
414cAC                   eval      w2disp = *blanks
414cAC                   eval      w2pqty = ptpcs
414cAC                   endif
     C                   else
416aD**                   Z-ADDW1LCNS    W2LCNS
416aMC                   eval      w2lcns = w1lcns
     C                   eval      w2trn# = w1trn#
     C                   eval      w2item = *blanks
     C                   eval      w2disp = *blanks
     C                   eval      w2vrtl = *blanks
414eD***                  Z-ADD0         W2PDTE
     C                   eval      w2pqty = 0
     C                   eval      w2emp# = 0
     C                   eval      w2enam = *blanks
     C                   eval      w2sdte = 0
     C                   eval      w2stim = 0
     C                   eval      w2edte = 0
     C                   eval      w2etim = 0
     C                   eval      w2cdte = 0
     C                   eval      w2ctim = 0
     C                   eval      w2trst = *blanks
414aAC                   eval      w2task = *blanks
414aAC                   eval      w2tcat = *blanks
     C                   eval      w2lbst = *blanks
     *   Transaction details
     C                   exsr      zztran
414eA*   Receiving details
414eAC                   exsr      zzrcv
     C                   endif
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
417a *----------------------------------------------------------------
417a *
417a *  ZZFIL3   Fill screen 3 fields with info from file.
417a *
417a C     zzfil3        begsr
417a *
417a C     lbkey         setll     label7
417a C     lbkey         reade     label7                                 79
417a C                   if        not *in79
417a C                   eval      w3lcns = wolcns
417a C                   eval      w3trn# = lbtrn#
417a *
417a C                   if        lbstat = 'A'
417a C                   eval      w3lbst = @stata
417a C                   endif
417a *
417a C                   if        lbstat = 'B'
417a C                   eval      w3lbst = @statb
417a C                   endif
417a *
417a C                   if        lbstat = 'P'
417a C                   eval      w3lbst = @statp
417a C                   endif
417a *
417a C                   if        lbstat = 'C'
417a C                   eval      w3lbst = @statc
417a C                   endif
417a *
417a *   Item description and pack description.
417a C                   exsr      zzgeti
417a *   Transaction details
417a C                   exsr      zztran
417a *   Get Route info
417a C                   movel     ptrtpo        w3rtid
417a C                   movel     ptrtpo        kyrtid
417a C     keyrte        chain     rtehed                             77
417a C                   if        not *in77
417a C                   eval      w3rte = rhrte
417a C                   else
417a C                   eval      w3rte = *blanks
417a C                   endif
417aA*   Receiving details
417aAC                   exsr      zzrcv
417a *   Slot details
417a C                   exsr      zzslot
417aA**         PTCAT     IFEQ 'SELECT'
417aA**                   MOVELDESC,1    W2ITEM
414cA**                   MOVE *BLANKS   W2DISP
414cA**                   Z-ADDPTPCS     W2PQTY
414cA**                   ENDIF
417a C                   else
417a C                   eval      w3lcns = w1lcns
417a C                   eval      w3trn# = w1trn#
417a C                   eval      w3emp# = 0
417a C                   eval      w3enam = *blanks
417a C                   eval      w3sdte = 0
417a C                   eval      w3stim = 0
417a C                   eval      w3edte = 0
417a C                   eval      w3etim = 0
417a C                   eval      w3cdte = 0
417a C                   eval      w3ctim = 0
417a C                   eval      w3trst = *blanks
417a C                   eval      w3task = *blanks
417a C                   eval      w3tcat = *blanks
417a C                   eval      w3lbst = *blanks
417a *   Transaction details
417a C                   exsr      zztran
417aA*   Receiving details
417aAC                   exsr      zzrcv
417a C                   endif
417a *
417a C                   endsr
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
     C     lcnsky        klist
     C                   kfld                    w1whse
     C                   kfld                    w1lcns
     *
     C     lcn1ky        klist
     C                   kfld                    w1whse
     C                   kfld                    wotrn#
     *
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    lbitem
     *
     C     lbkey         klist
     C                   kfld                    wotrn#
     *
     C     ptkey         klist
     C                   kfld                    wotrn#
     *
     C     uskey         klist
     C                   kfld                    ptemp#
     *
     C     slkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    lbdisp
     *
416bAC     phkey         klist
416bAC                   kfld                    porwhs
416bAC                   kfld                    porpo
     *
416bAC     phhkey        klist
416bAC                   kfld                    porwhs
416bAC                   kfld                    porpo
416bAC                   kfld                    poredt
416bAC                   kfld                    poreti
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    w1whse
     C                   kfld                    ocode
414dA*
414dA*  Define partial key for SLOT3 file.
414dA*
414dAC     keys3         klist
414dAC                   kfld                    lbwhse
414dMC                   kfld                    lbitem
414dAC                   kfld                    k3stat
414dAC                   kfld                    k3pick
     *
414eA*
414eA*  Define partial key for PORCV1 file.
414eA*
414eAC     keypor        klist
414eAC                   kfld                    pttrn#
417aA*
417aA*  Define key for RTEHED file.
417aA*
417aAC     keyrte        klist
417aAC                   kfld                    w1whse
417aAC                   kfld                    kyrtid
CBIaA*
CBIdM*  Define key for POMFR3 file.
CBIaA*
CBIaAC     mfr2ky        klist
CBIdAC                   kfld                    porwhs
CBIaAC                   kfld                    porpo
CBIaAC                   kfld                    porlbl
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
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   eval      w1whse = #whse
     *
     C                   exsr      zzlcns
414eAC                   if        $pcmd = '*NOOPT'
CBIbAC                             or $pcmd = '*NOOPTL'
414eAC                   eval      w1trn# = $ptrn#
416aAC                   eval      w1lcns = *blanks
CBI A*
CBI AC                   if        %parms >= 3
CBI AC                   eval      w1lcns = $plcns
CBI AC                   eval      wolcns = $plcns
CBI AC                   endif
CBI A*
416aD**                   Z-ADD0         W1LCNS
414eAC                   exsr      zzupd1
414eAC                   else
     C                   eval      refrsh = *on
     C                   exsr      scr01i
414eAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZLCNS   Get use generic license option
     *
     C     zzlcns        begsr
     *
     *   Get use generic license option.
     C                   eval      lflag = *off
     C                   eval      *in35 = *off
     C                   eval      ocode = '*RCVLBL '
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   if        opplcn = 'Y'
     C                   eval      lflag = *on
CBI A*R                   MOVE *ON       *IN35
     C                   endif
     C                   endif
     *
     C                   endsr
     *
414eA*---------------------------------------------------------------
414eA*
414eA*  ZZRCV    Get receiving info.
414eA*
414eAC     zzrcv         begsr
414eA*
414eAC                   eval      w2rpo = *blanks
414eAC                   eval      w2rdte = 0
414eAC                   eval      w2rtim = 0
414eAC                   eval      w2rusr = *blanks
414eAC                   eval      w2rdev = *blanks
414eAC                   eval      w2ract = *blanks
414eA*
414eAC     keypor        setgt     porcv1
414eAC                   dow       forevr = forevr
414eAC     keypor        readpe    porcv1                                 79
414eAC                   if        *in79
414eAC                   leave
414eAC                   endif
414eA*
414eAC                   if        poract = 'X'
414eAC                   iter
414eAC                   endif
414eA*
414eAC                   eval      w2rpo = porpo
414eA*
414eAC                   eval      $cvcmd = '*CMDMDY '
414eAC                   move      pordte        $cvd8i
414eAC                   call      @cvtdt
414eAC                   parm                    $cvtdt
414eAC                   eval      w2rdte = $cvd6o
414eA*
414eAC                   eval      w2rtim = portim
414eAC                   eval      w2rusr = porusr
414eAC                   eval      w2rdev = pordev
414eAC                   select
414eAC                   when      poract = 'R'
414eAC                   eval      w2ract = 'Received'
414eAC                   when      poract = 'D'
414eAC                   eval      w2ract = 'Deleted '
414eAC                   eval      w2pqty = lbqalc
414eAC                   when      poract = 'X'
414eAC                   eval      w2ract = 'Checked '
414eAC                   other
414eAC                   eval      w2ract = *blanks
414eAC                   movel     poract        w2ract
414eAC                   endsl
414eA*
416 A*
416 A*    Retrieve item date info.
CBIaD*>         PORLBL    CHAINPOMFR1               77
CBIdDC*    MFR2KY        chain     pomfr2                             77
CBIdMC     MFR2KY        chain     pomfr3                             77
CBIcDC*                  goto      bypass
416 AC                   select
416 AC                   when      *in77
500 A*>         PORTRN    ORNE PMTRN#
416 AC                   eval      w2expd = *zeros
416 AC                   eval      w2mfrd = *zeros
416 A*    Non-display date fields.
416 AC                   eval      *in40 = *on
416 AC                   eval      *in41 = *on
416 A*
416 AC                   other
416 A*
416DA*    Conver  expiration date to MM/DD/YY.
CBIcMC     pmexpd        ifne      0
CBIcMC                   move      '*CMDMDY '    $cvcmd
CBIcMC                   move      pmexpd        $cvd8i
CBIcMC                   call      @cvtdt
CBIcMC                   parm                    $cvtdt
CBIcMC                   z-add     $cvd6o        w2expd
CBIcMC                   else
416 AC                   eval      w2expd = *zeros
CBIcMC                   ENDIF
416 A*    Condition display if no date to display.
416 AC                   if        w2expd <> *zeros
416 AC                   eval      *in40 = *off
416 AC                   else
416 AC                   eval      *in40 = *on
416 AC                   endif
4161A*    Convert Mfr. date to MM/DD/YY.
CBIcMc     pmmfgd        ifne      0
CBIcMC                   move      '*CMDMDY '    $cvcmd
CBIcMC                   move      pmmfgd        $cvd8i
CBIcMC                   call      @cvtdt
CBIcMC                   parm                    $cvtdt
CBIcMC                   z-add     $cvd6o        w2mfrd
CBIcMC                   else
416 AC                   eval      w2mfrd = *zeros
CBIcMC                   endif
416 A*    Condition display if no date to display.
416 AC                   if        w2mfrd <> *zeros
416 AC                   eval      *in41 = *off
416 AC                   else
416 AC                   eval      *in41 = *on
416 AC                   endif
416 AC                   endsl
     *
CBI1AC     bypass        tag
416bA*    Get vendor info.
     *
416bAC                   eval      w2vend = *blanks
416bAC                   select
416bAC                   when      poredt = 0
416bAC     phkey         chain     pohdr                              79
416bAC                   if        not *in79
416bAC                   move      phven         w2ven
416bAC                   eval      w2vnam = phvnam
416bAC                   exsr      zzfrmt
416bAC                   endif
     *
416bAC                   when      poredt > 0
416bAC     phhkey        chain     pohhdr                             79
416bAC                   if        not *in79
416bAC                   move      phhven        w2ven
416bAC                   eval      w2vnam = phhvna
416bAC                   exsr      zzfrmt
416bAC                   endif
416bAC                   endsl
416 A*
414eAC                   leave
414eAC                   enddo
414eA*
414eAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFRMT   Format vendor name and number
     *
416bAC     zzfrmt        begsr
     C                   eval      $pstr = *blanks
     *
     *  Left justify warehouse number (suppress zeros)
     *
     C                   eval      x = 0
     C                   eval      flag = *off
     C                   eval      tmp11a = w2ven
     C                   movea     tmp11a        a11
     C                   if        a11(1) = '0'
     C     2             do        11            i
     C                   if        a11(i) <> '0'  or
     C                             flag = *on
     C                   add       1             x
     C                   eval      a11(x) = a11(i)
     C                   eval      flag = *on
     C                   endif
     C                   eval      a11(i) = ' '
     C                   enddo
     C                   endif
     *
     *  Put everything together
     *
     C                   movea     a11           $pstr
     C     $pstr         cat       '-':1         $pstr
     C     $pstr         cat       w2vnam:1      $pstr
     C                   eval      w2vend = $pstr
     *
416bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZSLOT   Get Slot info
     *
     C     zzslot        begsr
     *
     C     slkey         chain     slot2                              79
     C                   if        not *in79
     C                   if        slrsrv = 'V'
     C                   eval      w2vrtl = @statv
     C                   else
     C                   eval      w2vrtl = *blanks
     C                   endif
     C                   else
     C                   eval      w2vrtl = *blanks
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZTRAN   Get trans info
     *
     C     zztran        begsr
     *
     C     ptkey         chain     pirtran                            79
     C                   select
     C                   when      not *in79
417a C                   if        nxtscr = '03 '
417a C                   eval      w3emp# = ptemp#
417a C                   eval      w3pqty = ptpcs
417a C                   else
     C                   eval      w2emp# = ptemp#
417a C                   endif
     *
414eAC                   eval      $cvcmd = '*CMDMDY '
414eAC                   move      ptgdte        $cvd8i
414eAC                   call      @cvtdt
414eAC                   parm                    $cvtdt
417a C                   if        nxtscr = '03 '
417a C                   eval      w3gdte = $cvd6o
417a C                   eval      w3gtim = ptgtim
417a C                   else
414eAC                   eval      w2gdte = $cvd6o
414eAC                   eval      w2gtim = ptgtim
417a C                   endif
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
417a C                   if        nxtscr = '03 '
417a C                   eval      w3sdte = $cvd6o
417a C                   eval      w3stim = ptstim
417a C                   else
     C                   eval      w2sdte = $cvd6o
     C                   eval      w2stim = ptstim
417a C                   endif
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
417a C                   if        nxtscr = '03 '
417a C                   eval      w3edte = $cvd6o
417a C                   eval      w3etim = ptetim
417a C                   else
     C                   eval      w2edte = $cvd6o
     C                   eval      w2etim = ptetim
417a C                   endif
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ptcdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
417a C                   if        nxtscr = '03 '
417a C                   eval      w3cdte = $cvd6o
417a C                   eval      w3ctim = ptctim
417a C                   else
     C                   eval      w2cdte = $cvd6o
     C                   eval      w2ctim = ptctim
417a C                   endif
     *
     C                   if        ptstat = '1'
417a C                   if        nxtscr = '03 '
417a C                   eval      w3trst = @stat1
417a C                   else
     C                   eval      w2trst = @stat1
417a C                   endif
     C                   endif
     *
     C                   if        ptstat = '2'
417a C                   if        nxtscr = '03 '
417a C                   eval      w3trst = @stat2
417a C                   else
     C                   eval      w2trst = @stat2
417a C                   endif
     C                   endif
     *
     C                   if        ptstat = '3'
417a C                   if        nxtscr = '03 '
417a C                   eval      w3trst = @stat3
417a C                   else
     C                   eval      w2trst = @stat3
417a C                   endif
     C                   endif
     *
     C                   if        ptstat = '4'
417a C                   if        nxtscr = '03 '
417a C                   eval      w3trst = @stat4
417a C                   else
     C                   eval      w2trst = @stat4
417a C                   endif
     C                   endif
     *
     C                   if        ptstat = '8'
417a C                   if        nxtscr = '03 '
417a C                   eval      w3trst = @stat8
417a C                   else
     C                   eval      w2trst = @stat8
417a C                   endif
     C                   endif
     *
     C                   if        ptstat = '9'
417a C                   if        nxtscr = '03 '
417a C                   eval      w3trst = @stat9
417a C                   else
     C                   eval      w2trst = @stat9
417a C                   endif
     C                   endif
     *
417a C                   if        nxtscr = '03 '
417a C                   eval      w3task = pttask
417a C                   eval      w3tcat = ptcat
417a C                   else
414a C                   eval      w2task = pttask
414a C                   eval      w2tcat = ptcat
417a C                   endif
     *
     C     uskey         chain     piruser1                           79
     C                   if        not *in79
415 D*R                   MOVELUSFNAM    W2ENAM
417a C                   if        nxtscr = '03 '
417aAC                   eval      w3enam = %trimr(usfnam) + ' ' + usinit
417aAC                   if        usinit > *blanks
417aAC     w3enam        cat       '.':0         w3enam
417aAC                   endif
417aAC     w3enam        cat       uslnam:1      w3enam
417a C                   else
415 AC                   eval      w2enam = %trimr(usfnam) + ' ' + usinit
415 AC                   if        usinit > *blanks
415 AC     w2enam        cat       '.':0         w2enam
415 AC                   endif
415 AC     w2enam        cat       uslnam:1      w2enam
417a C                   endif
     C                   else
     C                   eval      w2enam = *blanks
417a C                   eval      w3enam = *blanks
     C                   endif
     *
     C                   when      *in79
417a C                   if        nxtscr = '03 '
417a C                   eval      w3emp# = 0
417a C                   eval      w3enam = *blanks
417a C                   eval      w3sdte = 0
417a C                   eval      w3stim = 0
417a C                   eval      w3edte = 0
417a C                   eval      w3etim = 0
417a C                   eval      w3cdte = 0
417a C                   eval      w3ctim = 0
417a C                   eval      w3trst = *blanks
417a C                   eval      w3task = *blanks
417a C                   eval      w3tcat = *blanks
417a C                   eval      w3lbst = *blanks
417a C                   else
     C                   eval      w2emp# = 0
     C                   eval      w2enam = *blanks
     C                   eval      w2sdte = 0
     C                   eval      w2stim = 0
     C                   eval      w2edte = 0
     C                   eval      w2etim = 0
     C                   eval      w2cdte = 0
     C                   eval      w2ctim = 0
     C                   eval      w2trst = *blanks
414a C                   eval      w2task = *blanks
414a C                   eval      w2tcat = *blanks
     C                   eval      w2lbst = *blanks
417a C                   endif
     *
     C                   endsl
     *
     C                   endsr
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
CBIdAC                   eval      error = *on
CBIdAC                   eval      *in22 = *on
CBIdAC                   eval      *in02 = *on
CBIdAC                   exsr      zm022
CBIdAC                   goto      endup1
CBIbAC                   endif
CBIbA*
CBIbAC                   endif
CBIbA*
     C                   endif
     C                   if        w1trn# <> 0
     C                   eval      wotrn# = w1trn#
     C     lcn1ky        chain     license1                           79
     C                   if        not *in79
416aMC                   eval      wolcns = lilcns
416aD**                   Z-ADDLILCNS    WOLCNS  70
413 AC                   else
416aMC                   eval      wolcns = *blanks
416aD**                   Z-ADD0         WOLCNS
     C                   endif
     C                   else
     C                   eval      wotrn# = litrn#
     C                   endif
414b *
414b *  Check if multiple LICENSE records exist.
414b *
414bAC                   eval      lcount = 0
414bAC     lcnsky        setll     license
414bAC     nxtli         tag
414bAC     lcnsky        reade     license                                78
414bAC                   if        not *in78
414bAC                   add       1             lcount
414bAC                   goto      nxtli
414bAC                   endif
414b *
414b *  Get LICENSE Transaction if multiple License exist.
414b *
414bAC                   if        lcount > 1
414bAC                   eval      $lcmd = '*LOOKUP '
414bAC                   eval      $lwhse = w1whse
416aMC                   eval      $llcns = wolcns
416aD**                   Z-ADDWOLCNS    $LLCNS
414bAC                   eval      $ltrn# = wotrn#
414bAC                   call      'LP140'
414bAC                   parm                    $lparm
414bAC                   if        $lrtn = '*ERROR  '
414bAC                   eval      error = *on
414bAC                   eval      *in21 = *on
414bAC                   eval      *in01 = *on
414bAC                   movel     $lerm         errmsg
414bAC                   exsr      zm0105
414bAC                   else
414bAC                   if        $lrtn = '*PGMQ   '
414bAC                   eval      error = *on
414bAC                   eval      *in21 = *on
414bAC                   eval      *in01 = *on
414bAC                   eval      #msgk = $lmsg
414bAC                   exsr      zmqmsg
414bAC                   else
500aAC                   if        $lrtn = '*CANCEL '
500aMC                   eval      wolcns = $llcns
500aAC                   eval      wotrn# = 0
500aAC                   eval      nxtscr = '01 '
500aAC                   else
500aAC                   if        $lrtn = '*EXIT   '
500aMC                   eval      wolcns = *blanks
500aAC                   eval      wotrn# = 0
500aAC                   eval      nxtscr = 'EOJ'
500aAC                   goto      endup1
500aAC                   else
416aD**                   Z-ADD$LLCNS    WOLCNS
416aMC                   eval      wolcns = $llcns
414bAC                   eval      wotrn# = $ltrn#
500aAC                   endif
500aAC                   endif
414bAC                   endif
414bAC                   endif
414bAC                   if        $lrtn = '*CANCEL'  or
414bAC                             $lrtn = '*ERROR '  or
414bAC                             $lrtn = '*PGMQ  '
414bAC                   eval      error = *on
414bAC                   endif
414bAC     error         cabeq     *on           endup1
414bAC                   endif
414b *
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
417a C     ptkey         chain     pirtran                            79
417a C                   if        not *in79  and
417a C                             ptgrp1 = 'S'
417a C                   exsr      scr03i
417a C                   else
     C                   exsr      scr02i
417a C                   endif
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
414eAC                   if        $pcmd = '*NOOPT'
CBIbAC                             or $pcmd = '*NOOPTL'
414eAC                   eval      nxtscr = 'EOJ'
414eAC                   else
     C                   exsr      scr01i
414eAC                   endif
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------
417a *
417a *  ZZUPD3   Update for screen 3.
417a *
417a C     zzupd3        begsr
417a C                   eval      error = *off
417a C                   eval      refrsh = *on
417a *
417a C                   if        $pcmd = '*NOOPT'
CBIbAC                             or $pcmd = '*NOOPTL'
417a C                   eval      nxtscr = 'EOJ'
417a C                   else
417a C                   exsr      scr01i
417a C                   endif
417a *
417a C     endup3        endsr
417a *
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Multiple items for transaction
