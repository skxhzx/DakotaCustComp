600 A /copy *libl/qcopysrc,hspecs
500 A*----------------------------------------------------------------
500 A*  Multilingual Verision
500 A*  Every screen and message has a corresponding Spanish version.
500 A*  Any changes must be made to both languages.
500 A*  If necessary, contact appropriate person to do translation.
     * *************************************************************
     * ****                                                     ****
     * **** THIS PROGRAM SHOULD BE AN EXACT DUPLICATE OF SL630  ****
     * **** WITH THE FOLLOWING EXCEPTION ...                    ****
     * ****                                                     ****
     * **** SCREEN FORMAT SHOULD DISABLE AND NOT DISPLAY F8     ****
     * ****                                                     ****
     * **** If SL630 is changed ...                             ****
     * ****                                                     ****
     * ****   - Create format first, if necessary.              ****
     * ****   - Save a copy of this program.                    ****
     * ****   - Copy SL630 to SL730.                            ****
     * ****   - Change object description for SL730.            ****
     * ****   - Add these comments to top of new SL730 program. ****
     * ****   - Change file spec of SL630FM to SL730FM.         ****
     * ****   - Use XXX to document change.                     ****
     * ****   - Compile.                                        ****
     * ****                                                     ****
     * *************************************************************
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SL730     Item slot information - View  RF Mini screen
     *  07 February, 1997
     *  Roxanne Harrison
     *  Dave Sommerville
     *
     *  Notes:
     *       Created using IT135 full screen
     *       8 X 20 Screens for hand held scanners
     *  Revisions:
     *
402 A*    07/21/97  HNK  4.02
     *      - Call IT231 added.
412 A*    09/07/99  RH   4.12
     *      - Display "Virtual Slot" if slot is a virtual slot.
     *
413 A*    09/26/99  DAS 4.13
     *      - Revised ZZFIL1 to get SSB item if one exists.
     *      - Revised screen1 to display 'SSB' for an SSB item.
     *
415 A*    05/16/01  DAS  4.15
     *      - Created a 16-line version of SCREEN1 named SCREEN61.
     *      - Add special message screens for 16-line display.
     *      - Added call to program to get screen size being used.
     *      - Added 2 spaces after slot number when combining it with
     *        department and section type.
     *      - Added F10=Adj and F11=transfers.
     *
415aA*    06/22/01  DAS  4.15a
     *      - Revised ZZCMD1 to refresh screen.
     *
416aA*    05/15/02  MLB  4.16a
     *      - Revised program to not allow F10/F11 to be active
     *        when calling program is Will Call Transfers.
417aA*    02/11/04  RH   4.17a
     *      - Revised program to display tie hi on screen 1
     *
500 A*    06/04/06  JCJ  5.00
     *      - Added Multilingual logic.
     *
510aA*    06/10/06  DAS  5.10a
     *      - Enh: Revised program to add support for Client id
     *      - Added F7=Dates (only for certain clients)
     *
510bA*    11/09/06  JCJ  5.10b
     *      - Enh: Added call to CHKLIST.
     *
520aA*    02/09/08  HNK  5.20a P#00012
     *      - Enh: Revised program to add support for Client id
     *           : Allow only certain users to use F10 - Adjustment
     *
520bA*   04/10/08  JCJ  520b-P#00000
     *    - Revised to display F7=Dates.
     *
600 A*    04/28/08  DAS  6.00  P#00045
     *      - License Tracking
     *
600aA*    04/28/08  DAS  6.00a P#00045
     *      - Converted to ILE.
     *      - Revised to use DRI interfaces.
     *      - Added slot position to displays.
     *      - These were 500 changes in Jordano's version.
     *
600bA*    02/10/09  DAS  6.00b
     *      - Revised to work with new STG/RCV/USR slots.
     *      - Temporarily remove slot position.
610aA*    09/13/10  RH   6.10a
     *      - Enh: Set *IN52 to NOT allow F7=Dates
640 A*    12/09/11  RBD  6.40
     *      - Fix: CF08's commented out on screen formats to eliminate
     *        recursive call error.
640aA*    11/13/12  RTR     6.40a
     *      - Fix: if tie or high > 999, so will not error when 1000+
650a *    04/24/13  GJA     6.50a
     *      - Enh: Add slot type-virtual, pick, repack, or overflow
     *             Rename format to SL73001
650b *    04/25/13  KDE     6.50b
     *      - Enh: Add Physical slot count based off voice picks
     *             Rename format to SL73002 after change to SCREEN61
650c *    03/19/14  RH      6.50c
     *      - Enh: Add F11=Transfer to SCREEN1 & SCRN1SP.
     *             Rename format to SL73003
     *      - Fix: Copy SL630 to include missed 650a and 650b mods.
650d *    11/11/14  LMC     6.50d
     *      - Fix: Calling SL635 is passing the wrong value.
     *             was passing w1disp but it only gets loaded in zzinz
     *             So if the user scans a different slot, we send the
     *             wrong value to SL635.
700a *    05/20/16  LMC     7.00a
     *      - Enh: Add Brand to screen1.
     *             For pick slot - we will show brand from ITEMMSC.
     *             For Overflow slots we will show brand from LICINFO
     *             if a brand exists, else we will show brand from
     *             ITEMMSC.
720a *    08/22/16  LMC     7.00a  reserved
     *      - Enh: UCI Tracking added.
730 A*    03/14/19  MLB  7.30
     *      - Added logic to display error messages returned from IT222.
     *
730b *    03/01/19  LMC  7.30b
     *      - Enh: Do not display f10 for adjustment when slot is at
740aA*    09/02/20  LMC  7.40a
     *      - Enh: Add license to screen1 & 61.                       ,0
     *      - Enh: Add Entered and Expiration date to screen1 & 61    ,0
750aA*    06/25/21  RH   7.50a
     *      - Enh: Do not display F11 for transfer when slot is not
     *        status = 'A'. Users moving quarantine product in error
     *----------------------------------------------------------------
     * Client Revisions - VIP
     *
VIPaA*   06/10/06  DAS  VIPa
     *    - Revised to display F7=Dates.
     *
     *----------------------------------------------------------------
     * Client Custom Mods - CLD
     *
CLDaA*   11/09/06  JCJ  CLDa
     *     - Add user authorization check.
     *----------------------------------------------------------------
     * Client Custom Mods - HKW
     *
HKWaA*   01/17/13  RH   HKWa
     *     - Add user authorization check.
     *----------------------------------------------------------------
     * Client Custom Mods - ICB
     *
ICBaA*   04/27/12  RH   ICBa
     *     - Add ICB to CLD user authorization check
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - Graves Menu Maker
     *
GMMaA*   08/20/12  RH   GMMa
     *     - Add to authorization check.
     *----------------------------------------------------------------
     * Client Custom Mods - CDI
     *
CDIaA*   01/31/13  RH   CDIa
     *     - Add user authorization check
     *----------------------------------------------------------------
     * Client Custom Mods - GLP
     *
GLPaA*   04/15/13  RH   GLPa
     *     - Add GLP to CLD user authorization check
     *----------------------------------------------------------------
     *  Client Custom Mods - Saval
     *
SVLaA*   01/31/14  RH   SVLa
     *     - Add user authorization check.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Packer's
     *    01/29/04  HNK/RH PAKa
     *      - Fix: Revised to return to IT220 after F10 Adj
     *
     *----------------------------------------------------------------
     * Client Custom Mods - Dairyland
     *
DRY A*   07/23/13  MLB  DRY
     *     - Add DRY to CLD user authorization check
     *
     *----------------------------------------------------------------
     * Client Custom Mods - Fischer Foods
     *
FFCaA*   12/11/14  RH   FFCa
     *     - Add user authorization check.
     *----------------------------------------------------------------
     * Client Custom Revisions: Fox River Foods
FRF A*   07/14/14  MLB  FRF  #01232
     *     - Check if user authorized for adjustments.
     *     - Added FRF to CLDa mod.
FRFaA*   07/14/14  MLB  FRFa  #01232
     *     - Check if user authorized for slot transfers.
     *
     *----------------------------------------------------------------
     * Client Custom Mods - Marques
MQSaA*   06/25/18  RH   MQSa
     *     - Add user authorization check.
     *----------------------------------------------------------------
     * Client Custom Revisions: European Imports
EI  A*   01/28/15  MLB  EI   #01308
     *     - Check if user authorized for adjustments.
     *     - Added EI to CLDa mod.
EIa A*   01/28/15  MLB  EIa   #01308
     *     - Check if user authorized for slot transfers.
     *     - Added EIa to FRFa mod.
     *
     *----------------------------------------------------------------
     * Client Custom Mods - Earls
     *
EOPaA*   10/26/18  RH   EOPa
     *     - Add user authorization check.
     *
     *----------------------------------------------------------------
     * Client Custom Mods - Lieber's Kosher Foods
LKFaA*   11/15/19  RH   LKFa
     *     - Add user authorization check.
     *----------------------------------------------------------------
     * Client Custom Mods - Seashore
     *
SFP A*   08/31/22  RH   SFP
     *     - Add SFP to CLD user authorization check
     *
     *----------------------------------------------------------------
     * Client Custom Mods - Holt Paper
HPCaA*   12/09/19  RH   HPCa
     *     - Add user authorization check.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Foods Galore
FGL A*   10/26/21  MLB  FGL  zd#5730
     *     - Check if user authorized for adjustments.
     *     - Added FGL to CLDa mod.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
416aA*  51        Function keys F10/F11 disabled.
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
650aDF***sl730fm   cf   e             workstn
650aDF***sl73001   cf   e             workstn
650cDF***sl73002   cf   e             workstn
740ADF*sl73003   cf   e             workstn
740AMFsl73004   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Fwarehs    if   e           k disk
600aDF*lot2     if   e           k disk
600aDF*iritem   if   e           k disk
     *CTIVITYIF  E           K        DISK
     *LDCODE IF  E           K        DISK
     *ESIG   IF  E           K        DISK
     *TEMDEF IF  E           K        DISK
600aDF*lotdef   if   e           k disk
     Fslotstat  if   e           k disk
600aDF*temdef2  if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
     D @getcl          c                   const('GETCLIENT')
510 A*
510 A /COPY QCOPYSRC,ID#VIP
GLPaA /COPY QCOPYSRC,ID#GLP
CLD A /COPY QCOPYSRC,ID#CITYLIN
PAK A /COPY QCOPYSRC,ID#PACKERS
ICB A /COPY QCOPYSRC,ID#ICB
GMMaA /COPY QCOPYSRC,ID#GMM
CDIaA /COPY QCOPYSRC,ID#CDI
HKW A /COPY QCOPYSRC,ID#HKW
DRY A /COPY QCOPYSRC,ID#dairyla
SVLaA /copy qcopysrc,id#saval
FFCaA /COPY QCOPYSRC,ID#fischer
FRF A /COPY QCOPYSRC,id#frf
LKFaA /COPY QCOPYSRC,ID#lkf
HPCaA /COPY QCOPYSRC,ID#hpc
EI  A /COPY QCOPYSRC,id#ei
MQSaA /COPY QCOPYSRC,ID#mqs
EOPaA /COPY QCOPYSRC,ID#EOP
FGL A /COPY QCOPYSRC,ID#fgl
SFP A /COPY QCOPYSRC,ID#sfp

600aA*----------------------------------------------------------------
600aA*  DRI parameters
600aA*----------------------------------------------------------------
600aA
600aA /COPY *libl/qcopysrc,C#DRIPARMS
600aA
600aA*----------------------------------------------------------------
600aA*  Data Formats
600aA*----------------------------------------------------------------
600aA
600aA /COPY *libl/qcopysrc,C#ITEM
600aA /COPY *libl/qcopysrc,C#ITEMQTY
600aA /COPY *libl/qcopysrc,C#SLOT
600aA /COPY *libl/qcopysrc,C#SLOTDEF
700aA /COPY *libl/qcopysrc,C#LICINFO
600aAD saveVer#        s                   like($slver#)
600aAD save$slot       s                   like($slot)

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
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $pitem                39     53
416aAD  $palwc                54     54
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
510bA*----------------------------------------------------------------
510bA* Error message(s)
     D err01           c                   const('You are not authoriz-
     D                                     ed to use this optio-
     D                                     n.')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtwh          c                   const('FRMTWH')
     D @fmtit          c                   const('FRMTIT')
     D @autpg          c                   const('CHKLIST')
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
     D  $lcode                19     20
     *
     D  $lstat                19     20
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lst                  59     60
     D  $lsdef                61     62
     D  $lactv                63     64
416aAD  $lalwc                65     65
     *
402 AD  $litm                 22     36
402 A*
     *
415 AD  $lwhs2                19     21  0
415 AD  $lwhd2                22     26
415 AD  $ldsp2                27     38
415 AD  $lusr2                39     48
     *
510aAD  $lwhs3                19     21  0
510aAD  $lwhd3                22     26
510aAD  $ldsp3                27     38
510aAD  $litm3                39     53
720aA*
720aAD  $SlotLcns             49     63
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
     D  eritem                 1     15
     *
     D  erdisp                 1     12
     *
     D  ersdpt                13     17
     D  erstyp                18     18
     D  ersdsg                19     23
     *
     D  eridpt                24     28
     D  erityp                29     29
     D  eridsg                30     34
     *
     D  erslot                 1     12
     D  erstat                13     42
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
600aAD  #pgm             *proc
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
     D $cdesc          s             30
     D $cstr           s             40
     D $cwhse          s              3  0
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
600aAD chk4err         s               n
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
600aAD drierr          s               n
     D e               s              2  0
     D enter           s              5  0
600aMD error           s               n
600aDD*excld1          s                   like(avail1)
600aDD*excld2          s                   like(avail2)
600aDD*excld3          s                   like(avail3)
     D help            s              5  0
600aAD i               s              3  0
     D lock            s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D ssbflg          s              1
     D temp            s             20
     D warn            s              1
     D whdesc          s             30
     D whse            s              3  0
     D w1disp          s             12
     D w1sdes          s             30
     D w1slds          s             30
     D w1whse          s              4
600aAD zmsflag         s               n
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
416aA*        $PALWC - Y = Yes F10=Adjust, F11=Transfer are available.
416aA*               - N = No  F10=Adjust, F11=Transfer are NOT available.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
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
     C                   exsr      zzinz2
     C                   if        error = *on
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
415 AC                   select
415 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'SP'
500 AC                   exfmt     scrn61sp                             50
500 AC                   when      #lline = '16'  and
500 AC                             e$lng = 'EN'
415 AC                   exfmt     screen61                             50
500 D**                   OTHER
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'SP'
500 AC                   exfmt     scrn1sp                              50
500 AC                   when      #lline <> '16'  and
500 AC                             e$lng = 'EN'
     C                   exfmt     screen1                              50
415 AC                   endsl
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       10
412 D*R                   SETOF                     212223
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
     C                   if        $pcmd = '*VIEW   '
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
     C                   eval      ovrrid = *off
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
415 AC                   write     clrscr
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
415 AC                   write     clrscr
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Everything went fine so get out of program.
     *
415 AC                   write     clrscr
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
415 AC                   select
415 AC                   when      #lline = '16'
415 AC                   write     m16ctl
415 AC                   other
     C                   write     msgctl
415 AC                   endsl
     C                   eval      msgk = *zeros
415 AC                   select
415 AC                   when      #lline = '16'
415 AC                   write     m16clr
415 AC                   other
     C                   write     msgclr
415 AC                   endsl
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
415 AC                   select
415 AC                   when      #lline = '16'
415 AC                   write     m16ctl
415 AC                   other
     C                   write     msgctl
415 AC                   endsl
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
415 AC                   select
415 AC                   when      #lline = '16'
415 AC                   write     m16rec
415 AC                   other
     C                   write     msgrec
415 AC                   endsl
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
     *R                   MOVE W1DISP    $PDISP
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
415 AC                   select
415 AC                   when      #lline = '16'
415 AC                   write     m16rec
415 AC                   other
     C                   write     msgrec
415fAC                   endsl
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
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
     *     PIR7974  Slot record is locked.
     *
     C     zm7974        begsr
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
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM04     Slot record does not exist.
     *
     C     zm04          begsr
     C                   eval      #msgid = 'IT13204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      erdisp = w1disp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM71  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM72  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
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
     C                   select
     *
     *  When adding ....
     *
     C                   when      $pcmd = '*ADD    '
     *
     C                   endsl
     *
     C     endck1        endsr
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
     C                   goto      endcm1
     C                   endif
510aA*
510aA*      F7 - Dates
510aA*
510aAC                   if        *inkg
510aAC                   eval      cmdtkn = *on
510aAC                   eval      $lwhs3 = $pwhse
510aAC                   eval      $lwhd3 = $pwhdp
510aAC                   eval      $ldsp3 = $pdisp
600aMC                   eval      $litm3 = $slitem
510aAC                   call      'SL435'
510aAC                   parm                    $luky
510aAC                   parm                    $lrtn
510aAC                   write     clrsc2
510aAC                   endif
402 A*
402 A*      F8 - View other slots.
402 A*
402 AC                   if        *inkh
402 AC                   eval      cmdtkn = *on
402 AC                   eval      $lwhse = $pwhse
600aMC                   eval      $litm = $slitem
416aAC                   eval      $lalwc = $palwc
402 AC                   call      'IT231'
402 AC                   parm                    $luky
402 AC                   parm                    $lrtn
415 AC                   write     clrsc2
402 AC                   endif
     *
     *      F9 - View slot quantities.
     *
     C                   if        *inki
     C                   eval      cmdtkn = *on
     C                   eval      whse = $pwhse
     C                   call      'SL635'
     C                   parm                    whse
     C                   parm                    $pwhdp
650dDC*                  parm                    w1disp
650dMC                   parm                    $pdisp
     C                   endif
415 A*
415 A*      F10 - Adj
415 A*
416aA*    Note:  When program is called from will call transfers,
416aA*           adjustments and transfers are not allowed.
     C                   if        *inkj  and
416aAC                             $palwc <> 'N'
     *
     C                   eval      cmdtkn = *on
CLDaAC                   if        client = cityln  or
ICBa C                             client = icb or
GMMaAC                             client = mnumkr or
GLPa C                             client = greenleaf or
CDIa C                             client = cdi or
HKWa C                             client = hkw or
DRY AC                             client = dairyland or
SVLaAC                             client = saval or
FFCaAC                             client = fischerfoods or
FRF AC                             client = frf or
EI  AC                             client = ei  or
MQSaAC                             client = marques or
EOPa C                             client = Earls or
LKFaAC                             client = Liebers or
HPCaAC                             client = holtpaper or
FGL AC                             client = foodsgalore or
SFP AC                             client = seashore or
520a C                             client = packers
CLDaAC                   call      @autpg
CLDaAC                   parm                    #prog
CLDaAC                   parm      'F10'         pgmopt           20
CLDaAC                   parm                    #user
CLDaAC                   parm                    $prtn
CLDaAC                   if        $prtn = '*NO'
CLDaAC                   eval      error = *on
CLDaAC                   movel     err01         errmsg
CLDaAC                   exsr      zm0105
520aD*                    GOTO ENDCM1
520aMC                   goto      cmdcm1
CLDaAC                   endif
CLDaAC                   endif
CLDaA*
     C                   eval      $lcmd = '*CHANGE '
     C                   eval      $lwhs2 = $pwhse
     C                   eval      $lwhd2 = $pwhdp
     C                   eval      $ldsp2 = $pdisp
     C                   eval      $lusr2 = #user
720aAc                   eval      $slotlcns = $satolcns
     *
     C                   call      'IT222'
     C                   parm                    $lparm
730 AC                   if        $lrtn = '*ERROR  '
730 AC                   eval      error = *on
730 AC                   movel     $lerm         errmsg
730 AC                   exsr      zm0105
730 AC                   else
730 AC                   if        $lrtn = '*PGMQ   '
730 AC                   eval      error = *on
730 AC                   eval      #msgk = $lmsg
730 AC                   exsr      zmqmsg
730 AC                   endif
730 AC                   endif
730 A*
     C                   endif
415 A*
415 A*      F11 - Transfer
415 A*
416aA*    Note:  When program is called from will call transfers,
416aA*           adjustments and transfers are not allowed.
     C                   if        *inkk  and
416aAC                             $palwc <> 'N'
     C                   eval      cmdtkn = *on
FRFaAC                   if           client = frf
EIa AC                             or client = ei
FRFaAC                   call      @autpg
FRFaAC                   parm                    #prog
FRFaAC                   parm      'F11'         pgmopt           20
FRFaAC                   parm                    #user
FRFaAC                   parm                    $prtn
FRFaAC                   if        $prtn = '*NO'
FRFaAC                   eval      error = *on
FRFaAC                   movel     err01         errmsg
FRFaAC                   exsr      zm0105
FRFaAC                   goto      cmdcm1
FRFaAC                   endif
FRFaAC                   endif
FRFaA*
     C                   eval      $lcmd = '*CHANGE '
     C                   eval      $lwhs2 = $pwhse
     C                   eval      $lwhd2 = $pwhdp
     C                   eval      $ldsp2 = $pdisp
     C                   eval      $lusr2 = *blanks
     *
     C                   call      'IT252'
     C                   parm                    $lparm
     C                   endif
     *
520a C     cmdcm1        tag
     *
415AAC                   if        cmdtkn = *on
415aAC                   exsr      scr01i
415aAC                   endif
     *
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
     *  ZZFIL0   Fill screen 1  heading fields.
     *
     C     zzfil0        begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *
     *   Get warehouse description.
     *
     C                   eval      w1whse = *blanks
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     C                   movel     $pwhse        $cwhse
     C                   eval      $cdesc = whdesc
     C                   eval      $cstr = *blanks
     C                   call      @fmtwh
     C                   parm                    $cwhse
     C                   parm                    $cdesc
     C                   parm                    $cstr
     C                   eval      w1whse = $cstr
     *
     *   Get SLOT record.
     *
600aA
600aAC                   exsr      clr$slot
600aAC                   eval      $slwhseu = *on
600aAC                   eval      $slwhse  = $pwhse
600aAC                   eval      $slwhdpu = *on
600aAC                   eval      $slwhdp  = $pwhdp
600aAC                   eval      $sldispu = *on
600aAC                   eval      $sldisp  = $pdisp
600aA
600aAC                   eval      $dricommand = '*SLOT'
650bDC*                  eval      $drisubcmd  = '%GET'
650bMC                   eval      $drisubcmd  = '%GET2'
600aAC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *off
600aAC                   eval      zmsflag = *off
600aAC                   exsr      zzzdricop

600aDC**                 eval      slwhse = $pwhse
600aDC**   slkey         chain     slot2                              79
600aDC**                 if        *in79
600aDC**                 eval      slwhdp = *blanks
600aDC**                 eval      slstyp = *blanks
600aDC**                 eval      slpick = *blanks
600aDC**                 eval      slrsrv = *blanks
600aDC**                 eval      slstat = *blanks
600aDC**                 eval      slsdef = *blanks
600aDC**                 eval      sldesg = *blanks
600aDC**                 eval      slactv = *blanks
600aDC**                 eval      slbld = *blanks
600aDC**                 eval      slsdte = *zeros
600aDC**                 eval      slstim = *zeros
600aDC**                 eval      slentd = *zeros
600aDC**                 eval      slexpd = *zeros
600aDC**                 eval      w1qty = *zeros
600aDC**                 eval      w1avlq = *zeros
600aDC**                 eval      w1adjq = *zeros
600aDC**                 else
    D*R                   ENDIF
     *
     *    Create a quantity string to print.
     *
600aDC**                 call      'SLOTQTY'
600aDC**                 parm                    slstk1
600aDC**                 parm                    slstk2
600aDC**                 parm                    slstk3
     *
600aDC**                 parm                    slalc1
600aDC**                 parm                    slalc2
600aDC**                 parm                    slalc3
     *
600aDC**                 parm                    sltfr1
600aDC**                 parm                    sltfr2
600aDC**                 parm                    sltfr3
     *
600aDC**                 parm                    slpck1
600aDC**                 parm                    slpck2
600aDC**                 parm                    slpck3
     *
600aDC**                 parm                    slrcv1
600aDC**                 parm                    slrcv2
600aDC**                 parm                    slrcv3
     *
600aDC**                 parm                    stock1            5 0
600aDC**                 parm                    stock2            3 0
600aDC**                 parm                    stock3            3 0
     *
600aDC**                 parm                    avail1            5 0
600aDC**                 parm                    avail2            3 0
600aDC*                  parm                    avail3            3 0
     *
     C                   eval      $pcmd = '*QTY2STR'
600aDC**                 eval      $pqty1 = avail1
600aDC**                 eval      $pqty2 = avail2
600aDC**                 eval      $pqty3 = avail3
600aMC                   eval      $pqty1 = $slavl1
600aMC                   eval      $pqty2 = $slavl2
600aMC                   eval      $pqty3 = $slavl3
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd
     C                   parm                    $pprg
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn
     C                   parm                    $perm
     *
     C                   eval      w1qty = $pqstr
415 AC                   eval      w1avlq = $pqstr
600aD**
600aD**  Calculate available qty excluding transactions in process.
600aD**
600aD**
600aDC**                 if        slrcv1 < avail1
600aDC**                 eval      excld1 = avail1 - slrcv1
600aDC**                 else
600aDC**                 eval      excld1 = 0
600aDC**                 endif
600aDC**                 if        slrcv2 < avail2
600aDC**                 eval      excld2 = avail2 - slrcv2
600aDC**                 else
600aDC**                 eval      excld2 = 0
600aDC**                 endif
600aDC**                 if        slrcv3 < avail3
600aDC**                 eval      excld3 = avail3 - slrcv3
600aDC**                 else
600aDC**                 eval      excld3 = 0
600aDC**                 endif
415 A*
415 A*      Convert quantity to string.
415 A*
600aDC**                 eval      $pqty1 = excld1
600aDC**                 eval      $pqty2 = excld2
600aDC**                 eval      $pqty3 = excld3
600aMC                   eval      $pqty1 = $sladj1
600aMC                   eval      $pqty2 = $sladj2
600aMC                   eval      $pqty3 = $sladj3
415 A*
415 AC                   call      'CVTQTY'
415 AC                   parm                    $pcmd
415 AC                   parm                    $pprg
415 AC                   parm                    $pqty1
415 AC                   parm                    $pqty2
415 AC                   parm                    $pqty3
415 AC                   parm                    $pum1
415 AC                   parm                    $pum2
415 AC                   parm                    $pum3
415 AC                   parm                    $pqstr
415 AC                   parm                    $pustr
415 AC                   parm                    $prtn
415 AC                   parm                    $perm
415 AC                   eval      w1adjq = $pqstr
650bA*
650bA*      Convert physical quantity to string.
650bA*
650bAC                   eval      $pqty1 = $slphy1
650bAC                   eval      $pqty2 = $slphy2
650bAC                   eval      $pqty3 = $slphy3
650bA*
650bAC                   call      'CVTQTY'
650bAC                   parm                    $pcmd
650bAC                   parm                    $pprg
650bAC                   parm                    $pqty1
650bAC                   parm                    $pqty2
650bAC                   parm                    $pqty3
650bAC                   parm                    $pum1
650bAC                   parm                    $pum2
650bAC                   parm                    $pum3
650bAC                   parm                    $pqstr
650bAC                   parm                    $pustr
650bAC                   parm                    $prtn
650bAC                   parm                    $perm
650bAC                   eval      w1phyq = $pqstr
600aDC**                 endif
     *
     *   Department from slot file.
     *R                   MOVE SLWHDP    W1WHDP
     *   Section from slot file.
     *R                   SELEC
     *R         SLSTYP    WHEQ 'F'
     *R                   MOVE 'FIXED'   W1SECT
     *R         SLSTYP    WHEQ 'P'
     *R                   MOVE 'PIR  '   W1SECT
     *R                   OTHER
     *R                   MOVE *BLANKS   W1SECT
     *R                   ENDSL
600aA
     *   Slot display/department/section
600aA
     C                   eval      temp = *blanks
415 D**         SLDISP    CAT  '/':0     TEMP
600aDC**   sldisp        cat       '/':2         temp
600aDC**   temp          cat       slwhdp:0      temp
600aDC**   temp          cat       '/':0         temp
600aDC**   temp          cat       slstyp:0      temp
600aDC**                 eval      w1sdsp = temp
600aA
600aAC                   eval      w1sdsp = %trim($sldisp)
600aAC                                    + '  /'
600aAC                                    + %trim($slwhdp)
600aAC                                    + '/'
600aAC                                    + %trim($slstyp)
600bDC**                                  + '/'
600bDC**                                  + %trim(%editc($saslpos:'3'))
600aA
412 AC**650a             eval      *in21 = *off
600aMC**650a             if        $slrsrv <> 'V'
412 AC**650a             eval      *in21 = *on
412 AC**650a             endif
650aAC                   select
650aAC                   when      $slrsrv = 'V'
650aAC                   eval      w1styp = 'Virtual'
650aAC                   when      $slstat = 'RP'
650aAC                   eval      w1styp = 'Repack'
650aAC                   when      $slpick = 'Y'
650aAC                   eval      w1styp = 'Pick'
650aAC                   when      $slpick = 'N'
650aAC                   eval      w1styp = 'Overflow'
650aAC                   other
650aAC                   eval      w1styp = *blanks
650aAC                   endsl
600aA
     *   Slot definition
600aA
600aAC                   exsr      clr$slotdef
600aAC                   eval      $sdwhse  = $slwhse
600aAC                   eval      $sdcode  = $slsdef
600aA
600aAC                   eval      $dricommand = '*SLOTDEF'
600aAC                   eval      $drisubcmd  = '%GET'
600aAC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *on
600aAC                   eval      zmsflag = *off
600aAC                   exsr      zzzdricop
600aAC                   if        drierr
600aAC                   eval      error = *off
600aAC                   eval      $sdpos = 1
600aAC                   endif
600aDC**   sdkey         chain     slotdef                            79
600aDC**                 if        *in79
600aDC**                 eval      sddesc = *blanks
600aDC**                 endif
600aDC**                 eval      w1sdes = sddesc
600aDC**                 eval      w1sdef = slsdef
600aMC                   eval      w1sdes = $sddesc
600aMC                   eval      w1sdef = $slsdef
600aA
     *   Slot status
600aA
600aDC**   slstat        chain     slotstat                           79
600aMC     $slstat       chain     slotstat                           79
     C                   if        *in79
     C                   eval      ssdesc = *blanks
     C                   endif
     C                   eval      w1slds = ssdesc
600aDC                   eval      w1slst = $slstat
730bAc                   if        w1slst  = 'Z'
730bAc                   eval      *in51 = *on
730bAc                   endif
750aAc                   if        w1slst <> 'A'
750aAc                   eval      *in51 = *on
750aAc                   endif
600aA
     *   Item description and pack description.
600aA
     C                   eval      w1item = *blanks
700aAC                   eval      w1brd  = *blanks
700aAC                   eval      *in53 = *off
600aA
600aAC                   exsr      clr$item
600aAC                   eval      $itwhse  = $slwhse
600aAC                   eval      $ititem  = $slitem
600aA
600aAC                   eval      $dricommand = '*ITEM'
600aAC                   eval      $drisubcmd  = '%GETALL'
600aAC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *off
600aAC                   eval      zmsflag = *off
600aAC                   exsr      zzzdricop
700aAC* if this is a pick slot and we have a brand in ITEMMSC
700aA /free
700aA   Select;
700aA     When $slpick = 'Y';
700aA       if $imbrnd <> ' ';
700aA         w1brd = $imbrnd;
700aA         *in53 = *on;
700aA       endif;
700aA     When $slpick = 'N';
700aA       // need to check licinfo
700aA       exsr clr$licinfo;
700aA       $lnwhse  = $pwhse;
700aA       $lnlcns  = $saoLcns;
700aA       $lnseq = 1;
700aA       $dricommand = '*LICINFO';
700aA       $drisubcmd  = '%GET';
700aA       $drisys2upd = 'D';
700aA       exsr zzzdricop;
700aA       if $lnbrand <> ' ';
700aA         w1brd = $lnbrand;
700aA         *in53 = *on;
700aA       endif;
700aA   endsl;
740aA   w1lcns = $SATOLCNS;
700aA /end-free
740bAC*
740bAC*   Expiration date
740bAC*
740bAC     $SLEXPD       IFEQ      0
740bAC                   Z-ADD     0             w1expd
740bAC                   ELSE
740bAC                   MOVE      '*CMDMDY '    $CVCMD
740bAC                   MOVE      $SLEXPD       $CVD8I
740bAC                   CALL      @CVTDT
740bAC                   PARM                    $CVTDT
740bAC                   Z-ADD     $CVD6O        W1EXPD
740bAC                   ENDIF
740bAC*
740bAC*   Entered date
740bAC*
740bAC     $SLENTD       IFEQ      0
740bAC                   Z-ADD     0             W1ENTD
740bAC                   ELSE
740bAC                   MOVE      '*CMDMDY '    $CVCMD
740bAC                   MOVE      $SLENTD       $CVD8I
740bAC                   CALL      @CVTDT
740bAC                   PARM                    $CVTDT
740bAC                   Z-ADD     $CVD6O        W1ENTD
740bAC                   ENDIF
740bA *
600aDC**   itkey         chain     piritem                            79
600aDC**                 if        *in79
600aDC**                 eval      itdesc = *blanks
600aDC**                 eval      itpdsc = *blanks
600aDC**                 endif
600aDC**                 eval      $iitem = slitem
600aMC                   eval      $iitem = $slitem
    D*R                   MOVEL$PITEM    $IITEM
415 AC                   select
415 AC                   when      #lline = '16'
415 AC                   eval      $idesc = *blanks
600aDC**                 eval      w1desc = itdesc
600aMC                   eval      w1desc = $itdesc
415 AC                   other
600aDC**                 eval      $idesc = itdesc
600aMC                   eval      $idesc = $itdesc
415 AC                   endsl
600aDC**                 eval      $ipdsc = itpdsc
600aMC                   eval      $ipdsc = $itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         w1item
600aA
600aAC                   eval      w1tie  = 0
600aAC                   eval      w1high = 0
600aAC     1             do        5             i
600aAC                   if        $idsdef(i) = $slsdef
640aAC                   if        $idtie(i) > 999
640aAC                   eval      w1tie  = 999
640aAC                   else
600aAC                   eval      w1tie  = $idtie(i)
640aAC                   endif
640aAC                   if        $idhigh(i) > 999
640aAC                   eval      w1high = 999
640aAC                   else
600aAC                   eval      w1high = $idhigh(i)
640aAC                   endif
600aAC                   leave
600aAC                   endif
600aAC                   enddo
413 A*
413 A*   Get SSB item, if one exists
413 A*
413 AC                   eval      ssbflg = *off
413 AC                   eval      wossb = *blanks
600aA
600aAC                   eval      $dricommand = '*ITEM'
600aAC                   eval      $drisubcmd  = '%GETSSB'
600aAC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *off
600aAC                   eval      zmsflag = *off
600aAC                   exsr      zzzdricop
600aAC                   if        $drireturn = 'SSBNOTFND'
600aAC                   else
600aAC                   eval      ssbflg = *on
600aAC                   eval      wossb = 'SSB'
600aAC                   endif
600aA
600aDC**                 if        ittype = ' '
600aDC**                 call      'GETSSB'
600aDC**                 parm      itwhse        $gwhse            3 0
600aDC**                 parm      ititem        $gitem           15
600aDC**                 parm      ' '           #bitem           15
600aDC**                 parm                    #bdesc           30
600aDC**                 parm                    #bpdsc           15
600aDC**                 parm                    #bwhdp            5
600aDC**                 parm                    #bstyp            1
600aDC**                 parm                    #bum              2
600aDC**                 parm                    #bum2             2
600aDC**                 parm                    #bumq2            3 0
600aDC**                 parm                    #bum3             2
600aDC**                 parm                    #bumq3            3 0
600aDC**                 parm                    #brtn             8
600aD**
600aDC**                 if        #brtn = '*FOUND  '
600aDC**                 eval      ssbflg = *on
600aDC**                 eval      wossb = 'SSB'
600aDC**                 endif
600aD**
600aDC**                 endif
415 A*
415 A*    Create a warehouse quantity string to print.
415 A*
600aAC                   exsr      clr$itemqty
600aAC                   eval      $iqwhse  = $slwhse
600aAC                   eval      $iqitem  = $slitem
600aA
600aAC                   eval      $dricommand = '*ITEMQTY'
600aAC                   eval      $drisubcmd  = '*GET'
600aAC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *off
600aAC                   eval      zmsflag = *off
600aAC                   exsr      zzzdricop
600aDC**                 eval      $acmd = '*AVAIL  '
600aDC**                 eval      $aprg = #prog
600aDC**                 eval      $atype = '*INTER  '
600aDC**                 eval      $awhse = slwhse
600aDC**                 eval      $aitem = slitem
600aDC**                 call      'ADJQTY'
600aDC**                 parm                    $acmd             8
600aDC**                 parm                    $aprg            10
600aDC**                 parm                    $atype            8
600aDC**                 parm                    $awhse            3 0
600aDC**                 parm                    $aitem           15
600aDC**                 parm                    $aqty1            7 0
600aDC**                 parm                    $aqty2            7 0
600aDC**                 parm                    $aqty3            7 0
600aDC**                 parm                    $artq1            7 0
600aDC**                 parm                    $artq2            7 0
600aDC**                 parm                    $artq3            7 0
600aDC**                 parm                    $artn             8
600aDC**                 parm                    $aerm
415 A*
415 AC                   eval      $pcmd = '*QTY2STR'
600aDC**                 eval      $pqty1 = $artq1
600aDC**                 eval      $pqty2 = $artq2
600aDC**                 eval      $pqty3 = $artq3
600aMC                   eval      $pqty1 = $iqavl1
600aMC                   eval      $pqty2 = $iqavl2
600aMC                   eval      $pqty3 = $iqavl3
415 AC                   eval      $pqstr = *blanks
415 A*
415 AC                   call      'CVTQTY'
415 AC                   parm                    $pcmd
415 AC                   parm                    $pprg
415 AC                   parm                    $pqty1
415 AC                   parm                    $pqty2
415 AC                   parm                    $pqty3
415 AC                   parm                    $pum1
415 AC                   parm                    $pum2
415 AC                   parm                    $pum3
415 AC                   parm                    $pqstr
415 AC                   parm                    $pustr
415 AC                   parm                    $prtn
415 AC                   parm                    $perm
415 A*
415 AC                   eval      w1whsq = $pqstr
600aD**
600aD**   Get item slot tie high to display
600aD**
600aDC**   itdkey        chain     itemdef2                           78
600aDC**                 if        not *in78
600aDC**                 eval      w1tie = idtie
600aDC**                 eval      w1high = idhigh
600aDC**                 else
600aDC**                 eval      w1tie = *zeros
600aDC**                 eval      w1high = *zeros
600aDC**                 endif
     *
     *   Initialize entry fields
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
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      w1disp = $pdisp
510 A*
510 A* Get client id.
510 A*
510 AC                   call      @getcl
510 AC                   parm                    client           10
510 A*
     *  Define key for main file.
     *
     *  Define key for slot file.
     *
     *
600aDC**   slkey         klist
600aDC**                 kfld                    $pwhse
600aDC**                 kfld                    $pwhdp
600aDC**                 kfld                    $pdisp
    D*R                   KFLD           W1DISP
     *
     *    Define  key for SLOTDEF file.
     *
600aDC**   sdkey         klist
600aDC**                 kfld                    $pwhse
600aDC**                 kfld                    slsdef
     *
     *  Define key for item file.
     *
600aDC**   itkey         klist
600aDC**                 kfld                    $pwhse
600aDC**                 kfld                    slitem
    D*R                   KFLD           $PITEM
     *
600aDC**   idkey         klist
600aDC**                 kfld                    $pwhse
600aDC**                 kfld                    slitem
    D*R                   KFLD           $PITEM
600aDC**                 kfld                    slsdef
     *
600aDC**   itdkey        klist
600aDC**                 kfld                    slwhse
600aDC**                 kfld                    slitem
600aDC**                 kfld                    slsdef
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
500cA*
500cA*   Get employee options.
500cA*
500cAC                   call      'GETUSER'
500cAC                   parm      #user         e$code           10
500cAC                   parm                    e$whse            3 0
500cAC                   parm                    e$emp#            5 0
500cAC                   parm                    e$fnam           15
500cAC                   parm                    e$init            1
500cAC                   parm                    e$lnam           20
500cAC                   parm                    e$whdp            5
500cAC                   parm                    e$styp            1
500cAC                   parm                    e$shft            6
500cAC                   parm                    e$crew            6
500cAC                   parm                    e$nhrs            3 1
500cAC                   parm                    e$rtn             8
500cAC                   parm                    e$bpu             1
500cAC                   parm                    e$lng             2
500cAC                   if        e$rtn <> '*OK'
500cAC                   eval      e$lng = 'EN'
500cAC                   endif
500cA*
415 A*
415 A*   Get screen size being used.
415 A*
415 AC                   call      'PIRRFSCR'
415 AC                   parm      '*GET'        #lcmd             8
415 AC                   parm                    #lline            2
415 AC                   parm                    #lcol             3
     *
416aA*    Program called from Will Call Transfer,
416aA*    F10=Adj, F11=Tfr not allowed.
416aA*
416aAC                   if        $palwc = 'N'
416aAC                   eval      *in51 = *on
416aAC                   else
416aAC                   eval      *in51 = *off
416aAC                   endif
416aA*
510aA*
510aA*   Set indicator for displaying F7=Dates.
510aA*
510aAC                   eval      *in52 = *on
520bD**         CLIENT    IFEQ VIP
VIPaAC**                 eval      *in52 = *off
610aDC**                 eval      *in52 = *off
520bD**                   ENDIF
     *
     *   Select first screen to display.
     *
     C                   eval      lock = *off
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     C     endupd        endsr

600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------
600aA*                     DRI SUBROUTINES
600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*  clr$item  Clear $item data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
600bAC                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$itemqty  Clear $itemqty data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$itemqty   begsr
     C                   eval      savever# = $iqver#
     C                   clear                   $itemqty
     C                   eval      $iqver# = savever#
     C                   endsr

700aA*----------------------------------------------------------------
700aA*  clr$licinfo  Clear $licinfo data structure fields
700aA*----------------------------------------------------------------

700aAC     clr$licinfo   begsr
700aAC                   eval      savever# = $lnver#
700aAC                   clear                   $licinfo
700aAC                   clear                   $licinfo2
700aAC                   eval      $lnver# = savever#

700aAC                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$slot  Clear $slot data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600bAC                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$slotdef  Clear $slotdef data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
     C                   endsr
600aA
600aA*----------------------------------------------------------------
600aA*  zzzdriclose   Close any open files or programs.
600aA*----------------------------------------------------------------
600aA
600aAC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*ITEMQTY'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   endsr
600aA
600aA*----------------------------------------------------------------
600aA*  zzzdricop  Call DRICOP
600aA*----------------------------------------------------------------
600aA
600aAC     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600bAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $dridata = $slotdef
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*ITEMQTY'
     C                   eval      $dridata = $itemqty
700aAC                   when      $dricommand = '*LICINFO'
700aAC                   eval      $dridata = $licinfo
700aAC                   eval      $dridata2 = $licinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
600bAC                             or $dricommand = '*SLOT'
700aAC                             or $dricommand = '*LICINFO'
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
     C                   eval      drierr = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
600aDC**                 if        zmsflag
600aDC**                 exsr      zm0105s
600aDC**                 else
600aDC**                 exsr      zm0105
600aDC**                 endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      drierr = *on
600aDC**                 if        zmsflag
600aDC**                 exsr      zm0001s
600aDC**                 else
600aDC**                 exsr      zm0001
     C***                exsr      zzerrind
600aDC**                 endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600bAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $slotdef = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*ITEMQTY'
     C                   eval      $itemqty = $dridata
700aAC                   when      $dricommand = '*LICINFO'
700aAC                   eval      $licinfo = $dridata
700aAC                   eval      $licinfo2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
