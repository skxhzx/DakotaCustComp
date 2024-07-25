      /copy *libl/qcopysrc,hspecs
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
     *  LP130     Pallet License information - View  RF(Full Screen)
     *  08 September, 1999
     *  Hemant Kapadia
     *
     *  Notes
     *    Program uses Status date for putaway date because
     *    LBRDTE is not in LABEL7 file.
     *
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
     *             F12 from screen2 of LP130 if LCOUNT > 1.
     *             Changes to SC2 and ZZUPD1.
     *
500bA*    06/06/06  JCJ  5.00b
     *      - Added Multilingual logic.
510aA*    10/17/06  RH   5.10a
     *      - Added F8=Dates to display LICINFO date information.
     *
600 A*    05/17/08  DAS  6.00  P#00045
     *      - License Tracking
     *
600aA*    05/17/08  DAS  6.00a
     *      - Added W1LOT and associated logic.
     *      - Was 4.17a change in Jordano pgm.
     *
600bA*    05/18/08  DAS  6.00b
     *      - Revised to execute ZZTRAN for *NOOPT
     *      - Was 4.17b change in Jordano pgm.
     *
600cA*    03/05/09  DAS  6.00c  P#00045
     *      - Revised for use with new license tracking.
     *      - Screen changed from LP130FM to LP13001.
     *      - Old code removed for readability
     *
600dA*    06/09/09  DAS  6.00d
     *      - Reinstated transaction number
     *      - Screen 3 will be displayed for tran#
     *      - Revised to use %GETINFO instead of %GETLCNS. %GETLCNS
     *        will only look for an active license, while %GETINFO
     *        will look to see if it is in the log file.
     *
610aA*    09/01/09  DAS  6.10a
     *      - Revised to get receving info for license plates that
     *        start with *DP (Directed Putaway).
     *
610bA*    02/16/10  DAS  6.10b
     *      - Revised to get receiving transaction #.
     *      - Added receiving tran# to screen 2.
     *      - Change format to LP13002.
     *
610cA*    09/09/10  DAS  6.10c
     *      - Revised to lookup license in LICINFO if not found with
     *        DRILICENSE %GETINFO.
     *
610dA*    11/10/10  DAS  6.10d
     *      - Revised to display the customer route number instead of
     *        the transaction category code for selection transactions.
640aA*    01/30/12  LMC  6.40a
     *      - Fix: w2pslt was retaining the last pick slot found, if
     *        no pick slot was found for the item.
640bA*    05/31/12  RH   6.40b
     *      - Enh: rename screen LP13003, re-instate F8=Dates.
640cA*    10/19/12  RBD  6.40c
     *      - Fix: In zzinz2 when nxtscr is set to EOJ, run subr
     *        zmcmsg, otherwise, if the user comes back to this pgm
     *        in the same session the error from the last call is
     *        still there.
650aA*    12/28/12  RH   6.50a
     *      - Enh: rename screen LP13004, re-instate W3PQTY pick qty
650bA*    08/02/13  LMC  6.50b
     *      - Fix: Transaction number was not being passed to LI130
650cA*    08/05/13  LMC  6.50c
     *      - Ehn: Added Command key F9 to call program to display
     *      catch weight override information.
650dA*    01/28/14  LMC  6.50d
     *      - Ehn: Added Brand to screen2.
650eA*    02/18/14  LMC  6.50e
     *      - Ehn: Added Command key F10 to call program to display
     *      weights from uciinfo file.
650fA*    05/13/14  LMC  6.50f
     *      - Ehn: Pass Item to UI320.
     *
     *
650gA*    11/18/14  LMC  6.50g
     *      - Ehn: *PR original license - added code to set the
     *        f10 key on if the license entered is found in uciinfo.
650hA*    01/30/15  LMC  6.50h
     *      - Ehn: If purchase order number is available sent it
     *        to UI320, so it will display in the heading.
     *
700aA*    06/03/15  LMC  7.00a
     *      - Fix: Send received item to UI320.
700bA*    08/04/15  RH   7.00b
     *      - Enh: Rename format to LP13008, add item and license
     *        department.  User can tell if item was received in
     *        different department.
700cA*    04/05/16  LMC  7.00c
     *      - Enh: Adding logic for Metric.
700dA*    11/27/16  MLB  7.00d
     *      - Ehn: Revised program to add client custom code support.
710aA*    03/15/17  LMC  7.10a
     *      - Fix: When using f8 from screen 2, need to send original
     *        license number to LI130, licinfo only exist for original
     *        license number.
710bA*    07/06/17  LMC  7.10b
     *      - Fix: clear w2lntttllbs and setof indidator 32.
     *        data was being retained from a previous license
710c *    10/11/17  RTR  7.10c
     *      - Fix: Check received date to prevent blowing up when default
     *        added timestamp.
720aA*    07/22/16  MR   7.20a
     *      - Enh: Open up parms in DRIUICINFO
     *             for new UCIINFO file format.
720b *    03/01/15  GJA  7.20b
     *      - Ehn: Add vendor name by PO#
SUNa *    09/10/20  ???  7.50a
     *      - Ehn: Add *SS to 610a mod
750b *    02/23/22  LMC  7.50b
     *      - Ehn: clear transactiono field on screen2. Was retaining
     *        data from previous license, if special license entered.
     *
760a *    11/29/22  LMC  7.60a
     *      - Ehn: Since we now add licinfo records for clients who
     *        need to link a lot# to a licinfo record if one does not
     *        exist, we no longer want to skip getting the licinfo
     *        record for "*" licenses.
     *
     *----------------------------------------------------------------
     *  Custom Client Revision-City Line
     *
CLDa *    04/20/11  RH   CLDa
     *      - Display route ID in place of route
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
     *
CBI A*    11/27/16  MLB  CBI
     *      - Enh: Revised program to call LP130B if license# not found
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
640bDF*p13002   cf   e             workstn
650aDF*p13003   cf   e             workstn
650cDF*Lp13004   cf   e             workstn
650dDF*Lp13005   cf   e             workstn
650eDF*Lp13006   cf   e             workstn
70beDF*Lp13007   cf   e             workstn
700cDF*Lp13008   cf   e             workstn
720bDF*Lp13009   cf   e             workstn
720bMFLp13010   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
600dAFpiruser1  if   e           k disk
600dAFpirtran   if   e           k disk
610dAFrtehed    if   e           k disk
650cAFpocwexcp  if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
414cAD desc            s             50    dim(1) ctdata perrcd(1)
416bAD a11             s              1    dim(11)
500bAD descsp          s             50    dim(1) ctdata perrcd(1)
700dA*----------------------------------------------------------------
700dA*  Customer id
700dA*
700dAD @getcl          c                   const('GETCLIENT')
700dAD client          s             10
700dAD clientloc       s             10
700dA*
CBI A /copy qcopysrc,id#cheney
CLDaA /COPY QCOPYSRC,ID#CITYLIN

700cA*----------------------------------------------------------------
700cA* Function prototypes.
700cA*----------------------------------------------------------------

700cA /copy qcopysrc,p.getimuom

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
600cA /COPY *libl/qcopysrc,C#SLOT
650eA /COPY *libl/qcopysrc,C#UCIINFO
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
710cAD noStamp         c                   const('0001-01-01-00.00.00.000000')
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
     D $pstr           s             50
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D chk4err         s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
600aMD error           s               n
     D flag            s              1
     D forevr          s              1
     D help            s              5  0
     D i               s              2  0
700cAD IMkilolbs       s              1
     D kyrtid          s              5
610dAD kywhse          s                   like(rhwhse)
     D lcount          s              1  0
     D lflag           s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D ocode           s              8
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
700aAD savew2ritem     s                   like(w2ritem)
     D sclear          s              1
650hAD sendpo          s              9
     D temp8n          s              8  0
     D tmp11a          s             11
     D ts              s               z
     D warn            s              1
     D wolcns          s             15
     D wotrn#          s              7  0
     D w2ven           s             11
     D w2vnam          s             40
     D x               s              2  0
     D zmflag          s               n
     D zmsflag         s               n
     *----------------------------------------------------------------
     *
     *  Parameters
     *
     *    Input Parameters
414eA*      $PCMD    *NOOPT  - Don't get options
600cM*      $PLCNS   License number to be used with *NOOPT
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
414eAC     *entry        plist
414eAC                   parm                    $pcmd             8
600cMC                   parm                    $plcns           15
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
     C                   exfmt     screen2                              50
500bAC                   endsl
     C                   endif
417a C                   if        nxtscr = '03 '
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   exfmt     scrn3sp                              50
500bAC                   other
417a C                   exfmt     screen3                              50
500bAC                   endsl
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
     C                   eval      refrsh = *off
500aAC                   if        lcount > 1  and
500aAC                             $lrtn <> '*CANCEL'  and
500aAC                             $lrtn <> '*EXIT  '
500aAC                   exsr      zzupd1
500aAC                   else
414eAC                   if        $pcmd = '*NOOPT'
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
700dA*
700dA* Get client id.
700dA*
700dAC                   call      @getcl
700dAC                   parm                    client
700dAC                   parm                    clientloc
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
600cAC                   leavesr
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
600cAC                   leavesr
     C                   else
     C*****              movel     $lerm         whdesc
     C                   endif
     C                   endif
600dA*
600dA*  Enter only one, either license or transaction number.
600dA*
600dAC                   if        w1lcns <> *blanks
600dAC                             and w1trn# <> 0
600dAC                   eval      error = *on
600dAC                   eval      *in22 = *on
600dAC                   eval      *in02 = *on
600dAC                   eval      *in23 = *on
600dAC                   eval      *in03 = *on
600dAC                   exsr      zm0204
600dAC                   leavesr
600dAC                   endif
     *
     *  Must enter one, either license or transaction number.
     *
416aAC                   if        w1lcns = *blanks
416aAC                             and w1trn# = 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   exsr      zm0205
600cAC                   leavesr
     C                   endif
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
600dAC                   if        w1lcns <> ' '
600cAC                   exsr      clr$license
600cAC                   eval      $liToLcnsU = *on
600cAC                   eval      $liToLcns = w1lcns
600cAC                   eval      $dricommand = '*LICENSE'
600dDC**                 eval      $drisubcmd  = '%GETLCNS'
600dMC                   eval      $drisubcmd  = '%GETINFO'
600cAC                   eval      $drisys2upd = 'D'
600cAC                   eval      chk4err = *on
600cAC                   eval      zmflag  = *off
600cAC                   exsr      zzzdricop
610cA
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
CBI AC                   call      'LP130B'
CBI AC                   parm      '*NOOPTL'     $bcmd             8
CBI AC                   parm      0             $btrn#            7 0
CBI AC                   parm      w1lcns        $blcns           15
CBI AC                   eval      w1lcns = ' '
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
600dAC                   endif
600dA*
600dA*  Verify tran #.
600dA*
600dAC                   if        w1trn# <> 0
600dAC                   eval      $lcmd = '*VERIFY'
600dAC                   eval      $ltrn = w1trn#
600dAC                   call      'PT900'
600dAC                   parm                    $lparm
600dAC                   if        $lrtn = '*PGMQ'
600dAC                   eval      error = *on
600dAC                   eval      *in23 = *on
600dAC                   eval      *in03 = *on
600dAC                   move      $lmsg         #msgk
600dAC                   exsr      zmqmsg
600dAC                   leavesr
600dAC                   endif
600dAC                   endif

     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     C     endck2        endsr
417a *----------------------------------------------------------------
417a *
417a *  ZZCHK3   Screen 3 error checking.
417a *
417a C     zzchk3        begsr
417a C                   eval      error = *off
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

600cM*  F7 - License history

510a C                   if        *inkg
510a C                   eval      cmdtkn = *on
600cAC                   call      'LT320'
600cAC                   parm      '*VIEW'       $scmd             8
600cAC                   parm      w1whse        $swhse            3 0
600cAC                   parm      ' '           $swhdp            5
600cAC                   parm      ' '           $sdisp           12
600cAC                   parm      ' '           $sitem           15
600cAC                   parm      w1lcns        $slcns           15
600cAC                   parm      0             $semp#            5 0
600cAC                   parm      ' '           $sdev            10
600cAC                   parm      ' '           $sform           10
510a C                   endif
640b *
640b *  F8 - Dates

640b C                   if        *inkh
640b C                   eval      cmdtkn = *on
640bAC                   move      w1whse        $twhse            3
640bAC                   move      w1trn#        $ttrn#            7
650bAc                   if        $ttrn# = '0000000'
650bAc                   move      w2trn#        $ttrn#
650bAc                   endif
640bAC                   call      'LI130'
640bAC                   parm      '*VIEW'       $scmd
640bAC                   parm                    $lprg
640bAC                   parm                    $twhse
710aDC*                  parm      w1lcns        $slcns
710aMC                   parm      w2olcns       $slcns
640bAC                   parm                    $ttrn#
640bAC                   parm      w2item        $sitem
640bAC                   parm      e$lng         $slng             2
640bAC                   endif
     *
650cA*
650cA*  F9 - Receiving catch weight override

650cAC                   if        *inki
650cAC                   eval      cmdtkn = *on
650cAC                   move      w1whse        $twhse            3
650cAC                   move      w1trn#        $ttrn#            7
650cAc                   if        $ttrn# = '0000000'
650cAc                   move      w2trn#        $ttrn#
650cAc                   endif
650cAC                   call      'EX121'
650cAC                   parm      '*VIEW'       $scmd
650cAC                   parm                    $lprg
650cAC                   parm                    $twhse
650cAC                   parm      w1lcns        $slcns
650cAC                   parm                    $ttrn#
650cAC                   parm      $liToItem     $sitem
650cAC                   parm      e$lng         $slng             2
650cAC                   endif
     *
650eA*  F10- Received weights

650eAC                   if        *inkj
650eAC                   eval      cmdtkn = *on
650eAC                   call      'UI320'
650eAC                   parm      '*VIEW'       $scmd             8
650eAC                   parm      w1whse        $swhse            3 0
650eAC*                  parm      ' '           $swhdp            5
650eAC*                  parm      ' '           $sdisp           12
650fDC*                  parm      ' '           $sitem           15
700aDC*                  parm      $liToItem     $sitem           15
700aMC                   parm      savew2ritem   $sitem           15
650eAC                   parm      w1lcns        $slcns           15
650hAC                   parm      0             $sendtrn          7 0
650hAC                   parm                    sendpo            9
650eAC*                  parm      0             $semp#            5 0
650eAC*                  parm      ' '           $sdev            10
650eAC*                  parm      ' '           $sform           10
650eAC                   endif
650eA*
     C     endcm2        endsr
417a *----------------------------------------------------------------
417a *
417a *  ZZCMD3   User defined command keys for screen 3.
417a *
417a C     zzcmd3        begsr
417a C                   eval      cmdtkn = *off

60dcM*  F7 - License history

     C                   if        *inkg
     C                   eval      cmdtkn = *on
     C                   call      'LT320'
     C                   parm      '*VIEW'       $scmd             8
     C                   parm      w1whse        $swhse            3 0
     C                   parm      ' '           $swhdp            5
     C                   parm      ' '           $sdisp           12
     C                   parm      ' '           $sitem           15
     C                   parm      ' '           $slcns           15
     C                   parm      0             $semp#            5 0
     C                   parm      ' '           $sdev            10
     C                   parm      ' '           $sform           10
     C                   parm      w1trn#        $strn#            7 0
     C                   endif
417a C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
416aMC                   eval      w1lcns = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
600cA
600cA*  Get license info
600cA
600cAC                   eval      w2lcns = w1lcns
600cAC                   eval      w2olcns = $liOLcns
600cAC                   eval      w2item = $liToItem
600cAC                   eval      w2disp = $liToDisp
700bAC                   eval      w2swhd = $liToWhdp
600cA
600cA*     License qty
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
640aAC                   eval      w2pslt = $sldisp
     C                   else
     C                   eval      w2pslt = $sldisp
     C                   if        $slrsrv = 'V'
     C                   eval      w2pslt = %trimr(w2pslt)
     C                                    + ' (virtual)'
     C                   endif
     C                   endif

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
700bAC                   eval      w2iwhd = $itwhdp
     C                   endif
700bAC                   if        w2iwhd <> w2swhd
700bAC                   eval      *in36 = *on
700bAC                   else
700bAC                   eval      *in36 = *off
700bAC                   endif
600aA
600aA*  If original license is a special license
600aA*    Then skip getting the receive info by getting out.
600aA
     C                   if        %subst($liOLcns:1:1) = '*'
     C                             and %subst($liOLcns:1:3) <> '*RT'
     C                             and %subst($liOLcns:1:3) <> '*XD'
610aAC                             and %subst($liOLcns:1:3) <> '*DP'
SUNaAC                             and %subst($liOLcns:1:3) <> '*SS'
750bAC                   eval      w2trn# = 0
     C                   eval      w2rpo = 'n/a'
720bAC                   eval      w2rvn = *blanks
     C                   eval      w2ritem = ' '
700aAC                   eval      savew2ritem = ' '
     C                   eval      w2dtyp  = ' '
     C                   eval      w2rentdte = ' '
     C                   eval      w2rcalcdte = ' '
     C                   eval      w2lot = ' '
650dAC                   eval      w2brand = ' '
     C                   eval      w2rdte = 0
     C                   eval      w2rtim = 0
710bAc                   eval      w2lnttllbs = 0
710bAc                   eval      *in32 = *off
650gA* detemine if F10 command key should be displayed.
650gA* This command key will only display if records exist in UCIINFO.
650gA /free
650gA   if %subst($liOLcns:1:3) = '*PR';
650hA     sendpo = ' ';
650gA     *in33 = '0';
650gA     exsr clr$uciinfo;

650gA     $uiWhse = w1whse;
650gA     $uilcns = w1lcns;

650gA     $dricommand = '*UCIINFO';
650gA     $drisubcmd  = '%GETLICREC';
650gA     $drisys2upd = 'D';
650gA     chk4err= *on;
650gA     zmflag  = *off;
650gA     exsr zzzdricop;
650gA     if error;
650gA       error = '0';
650gA     else;
650gA       *in33 = '1';
650gA     endif;
650gA   endif;
650gA /end-free
760aDC**                 leavesr
     C                   endif
600aA
600aA*  Get receiving information
600aA
600aAC                   exsr      clr$licinfo
600aA
600aAC                   eval      $lnemp# = 0
600aAC                   eval      $lnuser = #user
600aAC                   eval      $lnpgm  = #prog
600aAC                   eval      $lnjob  = #job
600aAC                   eval      $lnjobnbr  = #jobn
600aA
600aAC                   eval      $lnwhse  = w1whse
600aAC                   eval      $lntype  = 'P'
600aAC                   eval      $lnlcns  = $liOLcns
600aA
600aA*     PO number
600cA
600cAC                   eval      $lncodeu(1) = *on
600cAC                   eval      $lncode(1) = '*PO'
600cAC                   eval      $lncseq(1) = 1
600aA
600aA*     Received item number
600cA
600cAC                   eval      $lncodeu(2) = *on
600cAC                   eval      $lncode(2) = '*ITEM'
600cAC                   eval      $lncseq(2) = 1
600aA
600aA*     Type of date entered
600cA
600cAC                   eval      $lncodeu(3) = *on
600cAC                   eval      $lncode(3) = '*DATETYP'
600cAC                   eval      $lncseq(3) = 1
600aA
600aA*     Actual date entered for a date sensitive item.
600cA
600cAC                   eval      $lncodeu(4) = *on
600cAC                   eval      $lncode(4) = '*DATEIN'
600cAC                   eval      $lncseq(4) = 1
600aA
600aA*     Calculated Dakota expiration date.
600cA
600cAC                   eval      $lncodeu(5) = *on
600cAC                   eval      $lncode(5) = '*EXPDTE'
600cAC                   eval      $lncseq(5) = 1
600aA
600aA*     Lot code entered
600aA
600aAC                   eval      $lncodeu(6) = *on
600aAC                   eval      $lncode(6) = '*LOT'
600aAC                   eval      $lncseq(6) = 1
600aA
600aA*     Received timestamp
600cA
600cAC                   eval      $lncodeu(7) = *on
600cAC                   eval      $lncode(7) = '*RCVTS'
600cAC                   eval      $lncseq(7) = 1
600aA
600aAC                   eval      $dricommand = '*LICINFO'
600aAC                   eval      $drisubcmd  = '%GET'
600aAC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *on
600aAC                   exsr      zzzdricop
600aAC                   if        error
600aAC                   endif
600aA
600aA*  Now process the return information
600aA
600aA*     PO number
600cA
600cAC                   if        $lncodee(1) = $driok
600cAC                             and $lnvalchr(1) <> ' '
600cAC                   eval      w2rpo = %trim($lnvalchr(1))
650hAc                   eval      sendpo = %trim($lnvalchr(1))
600cAC                   else
600dAC                   if        %subst($liOLcns:1:3) = '*RT'
600dAC                   eval      w2rpo = '<return>'
600dAC                   else
600cAC                   eval      w2rpo = ' '
600dAC                   endif
600cAC                   endif
600aA
600aA*     Received item number
600cA
600cAC                   if        $lncodee(2) = $driok
600cAC                             and $lnvalchr(2) <> ' '
600cAC                   eval      w2ritem = %trim($lnvalchr(2))
600cAC                   else
600cAC                   eval      w2ritem = ' '
600cAC                   endif
700aAc                   eval      savew2ritem = w2ritem
600aA
600aA*     Type of date entered
600cA
600cAC                   if        $lncodee(3) = $driok
600cAC                             and $lnvalchr(3) <> ' '
600cAC                   select
600cAC                   when      $lnvalchr(3) = '*MFGDTE'
600cAC                   eval      *in40 = *off
600cAC                   eval      w2dtyp = '(manufactured date)'
600cAC                   eval      *in40 = *off
600cAC                   when      $lnvalchr(3) = '*USEDTE'
600cAC                   eval      *in40 = *off
600cAC                   eval      w2dtyp = '(use by date)'
600cAC                   when      $lnvalchr(3) = '*EXPDTE'
600cAC                   eval      *in40 = *off
600cAC                   eval      w2dtyp = '(mfr exp date)'
600cAC                   other
600cAC                   eval      *in40 = *on
600cAC                   eval      w2dtyp = ' '
600cAC                   endsl
600cAC                   else
600cAC                   eval      *in40 = *on
600cAC                   eval      w2dtyp = ' '
600cAC                   endif
600aA
600aA*     Actual date entered for a date sensitive item.
600cA
600cAC                   if        $lncodee(4) = $driok
600cAC                             and $lnvalnum(4) <> 0
600cAC                   eval      temp8n = $lnvalnum(4)
600cAC                   eval      w2rentdte = %char(
600cAC                                         %date(temp8n:*iso)
600cAC                                         :*mdy/)
600cAC                   else
600cAC                   eval      w2rentdte = 'n/a'
600cAC                   endif
600aA
600aA*     Calculated Dakota expiration date.
600cA
600cAC                   if        $lncodee(5) = $driok
600cAC                             and $lnvalnum(5) <> 0
600cAC                   eval      temp8n = $lnvalnum(5)
600cAC                   eval      w2rcalcdte = %char(
600cAC                                          %date(temp8n:*iso)
600cAC                                          :*mdy/)
600cAC                   else
600cAC                   eval      w2rcalcdte = 'n/a'
600cAC                   endif
600aA
600aA*     Lot code entered
600aA
600aAC                   if        $lncodee(6) = $driok
600aAC                             and $lnvalchr(6) <> ' '
600aAC                   eval      w2lot = %trim($lnvalchr(6))
600aAC                   else
600aAC                   eval      w2lot = ' '
600aAC                   endif
600aA
600aA*     Received date/time
600cA
600cAC                   if        $lncodee(7) = $driok
600cAC                             and $lnvalchr(7) <> ' '
710cAC                             and $lnvalchr(7) <> noStamp
600cAC                   eval      ts = %timestamp($lnvalchr(7))
600cAC                   eval      w2rdte = %dec(
600cAC                                      %date(ts)
600cAC                                      :*mdy)
600cAC                   eval      w2rtim = %dec(
600cAC                                      %time(ts)
600cAC                                      :*hms)
600cAC                   else
600cAC                   eval      w2rdte = 0
600cAC                   eval      w2rtim = 0
600cAC                   endif
610bA
610bA*  Get more receiving information
610bA
610bAC                   exsr      clr$licinfo
610bA
610bAC                   eval      $lnemp# = 0
610bAC                   eval      $lnuser = #user
610bAC                   eval      $lnpgm  = #prog
610bAC                   eval      $lnjob  = #job
610bAC                   eval      $lnjobnbr  = #jobn
610bA
610bAC                   eval      $lnwhse  = w1whse
610bAC                   eval      $lntype  = 'P'
610bAC                   eval      $lnlcns  = $liOLcns
610bA
610bA*     Transaction number
610bA
610bAC                   eval      $lncodeu(1) = *on
610bAC                   eval      $lncode(1) = '*RCVTRN#'
610bAC                   eval      $lncseq(1) = 1
610bA
610bAC                   eval      $dricommand = '*LICINFO'
610bAC                   eval      $drisubcmd  = '%GET'
610bAC                   eval      $drisys2upd = 'D'
610bAC                   eval      chk4err = *on
610bAC                   exsr      zzzdricop
610bAC                   if        error
610bAC                   endif
610bA
610bA*  Now process the return information
610bA
610bA*     Transaction number
610bA
610bAC                   if        $lncodee(1) = $driok
610bAC                             and $lnvalnum(1) > 0
610bAC                             and $lnvalnum(1) <= 9999999
610bAC                   eval      w2trn# = $lnvalnum(1)
610bAC                   else
610bAC                   eval      w2trn# = 0
610bAC                   endif

     *   Get received item

     C                   if        w2ritem = $liToItem

     C                   eval      w2ritem = w2item

     C                   else

     C                   exsr      clr$item
     C                   eval      $itwhse  = w1whse
     C                   eval      $ititem  = w2ritem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   eval      w2ritem = %trim(w2ritem)
     C                                    + ': ' + $drimessage
     C                   else
     C                   call      @fmtit
     C                   parm                    $ititem
     C                   parm                    $itdesc
     C                   parm                    $itpdsc
     C                   parm                    $istr            70
     C                   eval      w2ritem = $istr
     C                   endif

     C                   endif
650dA*     Brand    entered
650dA
650dAC                   if        $lnbrand <> ' '
650dAC                   eval      w2brand = $lnbrand
650dAC                   else
650dAC                   eval      w2brand = ' '
650dAC                   endif
650dA
650cA* Show Received weight field if total weight exist in LICINFO.
650cA /free
650cA   if $lnttllbs > 0;
650cA     w2lnttllbs = $lnttllbs;
650cA     *in32 = *on;
650cA   else;
650cA     w2lnttllbs = 0;
650cA     *in32 = *off;
650cA   endif;
650cA /end-free
     *
650cA* detemine if F9 command key should be displayed.
650cA* This command key will only display if a catch weight override
650cA* exist for the license being displayed.
650cA /free
650cA    chain ($lnwhse:$lnrcvlbl#:$lnrcvtrn#:$lnitem) pocwexcp;
650cA    if %found(pocwexcp);
650cA      *in31 = '1';
650cA    else;
650cA      *in31 = '0';
650cA    endif;
650cA /end-free
650eA* detemine if F10 command key should be displayed.
650eA* This command key will only display if records exist in UCIINFO.
650eA /free
650eA    *in33 = '0';
650eA     exsr clr$uciinfo;

650eA     $uiWhse = w1whse;
650eA     $uilcns = w1lcns;

650eA     $dricommand = '*UCIINFO';
650eA     $drisubcmd  = '%GETLICREC';
650eA     $drisys2upd = 'D';
650eA     chk4err= *on;
650eA     zmflag  = *off;
650eA     exsr zzzdricop;
650eA     if error;
650eA       error = '0';
650eA     else;
650eA       *in33 = '1';
650eA     endif;
650eA /end-free
     C                   endsr
417a *----------------------------------------------------------------
417a *
417a *  ZZFIL3   Fill screen 3 fields with info from file.
417a *
417a C     zzfil3        begsr

     C                   eval      w3trn# = w1trn#
     C     w3trn#        chain     pirtran
     C                   if        not %found
     C                   leavesr
     C                   endif

     C                   eval      w3emp# = ptemp#
650aAC                   eval      w3pqty = ptpcs

     C                   eval      $cvcmd = '*CMDMDY'
     C                   move      ptgdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w3gdte = $cvd6o
     C                   eval      w3gtim = ptgtim

     C                   eval      $cvcmd = '*CMDMDY'
     C                   move      ptsdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w3sdte = $cvd6o
     C                   eval      w3stim = ptstim

     C                   eval      $cvcmd = '*CMDMDY'
     C                   move      ptedte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w3edte = $cvd6o
     C                   eval      w3etim = ptetim

     C                   eval      $cvcmd = '*CMDMDY'
     C                   move      ptcdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w3cdte = $cvd6o
     C                   eval      w3ctim = ptctim

     C                   select
     C                   when      ptstat = '1'
     C                   eval      w3trst = 'Pending'
     C                   when      ptstat = '2'
     C                   eval      w3trst = 'Started'
     C                   when      ptstat = '3'
     C                   eval      w3trst = 'Ended'
     C                   when      ptstat = '4'
     C                   eval      w3trst = 'Closed'
     C                   when      ptstat = '8'
     C                   eval      w3trst = 'Interupted'
     C                   when      ptstat = '9'
     C                   eval      w3trst = 'Canceled'
     C                   other
     C                   endsl

     C                   eval      w3task = pttask
     C                   eval      w3tcat = ptcat

     C     ptemp#        chain     piruser1
     C                   if        not %found
     C                   eval      w3enam = ' '
     C                   else
     C                   eval      w3enam = %trim(usfnam) + ' '
     C                                    + %trim(usinit) + '. '
     C                                    + %trim(uslnam)
     C                   endif
610dA
610dA*    For a selection transaction,
610dA*      Display customer route instead of category.
610dA
610dAC                   if        ptcat = 'SELECT'
610dAC                   eval      kywhse = ptwhse
610dAC                   eval      kyrtid = ptrtpo
610dAC     keyrh         chain(e)  rtehed
610dAC                   if        %found(rtehed)
CLDaAC                   select
CLDaAC                   when      client=cityln
CLDaAC                   eval      w3tcat = rhrtid
CLDaAC                   other
610dAC                   eval      w3tcat = rhrte
CLDaAC                   endsl
610dAC                   endif
610dAC                   endif

417a C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
414eAC                   eval      forevr = *on
610dA
610dA*  Define key for RTEHED File
610dA
610dAC     keyrh         klist
610dAC                   kfld                    kywhse
610dAC                   kfld                    kyrtid
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog

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
500bAC                   parm      #curruser     e$code           10
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
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   eval      w1whse = #whse
700cA*
700cA*   Get Item Maintenance options.
700cA*
700cA /free
700cA    //whse = $pwhse;
700cA    getimuom(#whse: IMkilolbs: IMUom);
700cA /end-free
     *
414eAC                   if        $pcmd = '*NOOPT'
600cMC                   eval      w1lcns = $plcns
600bAC                   eval      w1whse = #whse
414eAC                   exsr      zzchk1
414eAC                   if        error
414eAC                   eval      nxtscr = 'EOJ'
640cAC                   exsr      zmcmsg
414eAC                   else
414eAC                   exsr      zzupd1
414eAC                   endif
414eAC                   else
     C                   eval      refrsh = *on
     C                   exsr      scr01i
414eAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
416aAC                   eval      wolcns = w1lcns
     C                   eval      refrsh=*on
600dAC                   if        w1lcns <> ' '
     C                   exsr      scr02i
600dAC                   else
600dAC                   exsr      scr03i
600dAC                   endif
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
417a C                   eval      nxtscr = 'EOJ'
417a C                   else
417a C                   exsr      scr01i
417a C                   endif
417a *
417a C     endup3        endsr

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
650cAC                   clear                   $licinfo2
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
650eA*----------------------------------------------------------------
650eA*  clr$uciinfo  Clear $uciinfo data structure fields
650eA*----------------------------------------------------------------

650eAC     clr$uciinfo   begsr
650eAC                   eval      savever# = $uiver#
650eAC                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
650eAC                   eval      $uiver# = savever#
650eAC                   eval      $uiaddemp = e$emp#
650eAC                   eval      $uiaddusr = #curruser
650eAC                   eval      $uiaddpgm  = #pgm
650eAC                   eval      $uiaddjob  = #job
650eAC                   eval      $uiaddnbr = #jobnbr
650eAC                   endsr

600cA
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
650cAC                   eval      $dridata2 = $licinfo2
650eAC                   when      $dricommand = '*UCIINFO'
650eAC                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
650cAC                             or $dricommand = '*LICINFO'
720aAC                             or $dricommand = '*UCIINFO'
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
650cAC                   eval      $licinfo2 = $dridata2
650eAC                   when      $dricommand = '*UCIINFO'
650eAC                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
417a *
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
Multiple items for transaction
** Descsp
Productos multiples por transaccion
