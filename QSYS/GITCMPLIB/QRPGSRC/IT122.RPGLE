600 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *
     *   CHANGE IT222 IF ANY CHANGES ARE MADE TO THIS PROGRAM
     *
     *
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT122     Inventory adjustments - Change
     *  20 February 1993
     *  Dave Sommerville
     *
     *  Revisions:
     *
DRI A*    10/12/01  DAS  4.16
     *      - Total rewrite. Changed to use DRI interface programs.
     *
416aA*    01/24/02  DAS  4.16a
     *      - Revised to only do one call to the DRI interface.
     *        The interface program will make the call to the host.
     *      - Revised to use '%' as the first character of the subcommand
     *        instead of '*'. This identifies that the call to the
     *        interface was initiated from Dakota and not the Host.
     *      - Revised the way the ZM0001 routines identify if the message
     *        was sent back from the host.
     *
416bA*    01/24/02  DAS  4.16b
     *      - Revised to use *SLOT interface instead of *ITEMADJ.
     *      - Revised to use ZZZDRICOP routine.
     *
416cA*    06/11/02  DAS  4.16c
     *      - Recompiled because of change to C#SLOT.
     *
416dA*    06/11/03  DAS  4.16d
     *      - C#ITEM revised to have two data structures, $item and $item2.
     *      - Revised program to work with second data structure.
     *
417 A*    10/09/03  DAS  4.17
     *      - Added $saby to fill$adj routine.
417aA*    04/21/04  DAS  4.17a
     *      - Fix: Revised ZZUOM routine to initialize ind 92 & 93.
     *      - Fix: Revised ZZINZ2 routine to initialize ssbflg
500 A*    03/21/05  RH   5.00a
     *      - 4.17a change missed in 417 update, add as 5.00 change
     *
510 A*    07/11/06  JCJ  5.10
     *      - Enh: add warning message if the department of the item
     *             does not match the department of the slot.
     *
510aA*    09/08/06  RAH  5.10a
     *      - Enh: Revised program to add support for Client id
510bA*    10/30/06  JCJ  5.10b
     *      - Enh: Added files SAPMOVE1 & ITMADJM.
510cA*    02/08/07  JCJ  5.10c
     *      - Enh: Added new error message to desc array.
     *
520 A*    07/03/08  RH/RBD  5.20  I#00026
     *      - Fix: Adjustment type and qty were being blanked out if
     *        user prompted (F4) on Reason Code.  User received a
     *        dec data error when prompting on slot or status.
     *        Screen parms being passed to CW133 were being overlaid
     *        with blanks when calling anything other than CW133.
     *        Fixed by passing hold fields rather than screen fields,
     *        and populating them before calling CW133.
520aA*    07/03/08  RH  5.20a I#00026
     *      - Fix: Addditional code to correct 520 error.
520bA*    10/14/08  RH   5.20b
     *      - Enh: Add call to GETALSW to select alias item to be
     *        adjusted on host.  Will be exported in ITEMADJ &
     *        ITEMADJM.
520cA*    12/22/08  RH   5.20c       (not needed in ver 6.00)
     *      - Fix: Call UPDSLTDTE with *FIX to correct qty in SLOTDTE
     *        is wrong if slot had negative stock before put away.
520dA*    04/24/09  RH   5.20d
     *      - Enh: If qty and catch weight are both entered, both must
     *        the same sign (positive or negative).
     *        Renamed IT122FM to IT12201
     *
600 A*    04/25/08  DAS  6.00  P#00045
     *      - License Tracking
     *
600aA*    04/25/08  DAS  6.00a P#00045
     *      - License tracking additions. 500/500a in Jordanos version
     *
600bA*    01/11/09  DAS  6.00b
     *      - Revised to work with new STG/RCV/USR slots.
     *      - Changed all #user to #curruser.
     *
600cA*    05/27/09  DAS  6.00c
     *      - Revised to not allow the scanning of an RCV/STG slot. These
     *        slots are tied to open receiving transaction sot they
     *        need to be handled through the putaway program.
610aA*    11/02/09  RH   6.10a
     *      - Fix: Change display to use WODISP to display slot, DRI
     *        programs do not use SLDISP, field was blank on screen1
     *        Renamed IT12201 to IT12202
610b *    04/28/10  GJA  6.10b      P#00243
     *      - Enh: Change UCI to be option driven.  OPUCI
610c *    05/11/10  GJA  6.10c      P#00243
     *      - Fix: Change UCI position.
640bA*    08/16/11  RH   6.40b
     *      - Enh: Changed to get PO/Seq# using DRILICENSE and
     *      - DRILICINFO.
     *
650 A*    02/27/13  MLB  6.50
     *      - Enh: Changed to use IT12203, to allow for BIR mod.
     *
650aA*    05/01/14  RBD  6.50a
     *      - Fix: Rev 610b data structure should be opdata, not opddta.
650bA*    05/27/14  RH   7.00 (6.50b mod missed in update)
     *      - ENH: Change to use IT12204, add W1FIFO to addjust oldest
     *        or newest license.  Use cmd ADJSLTREV for LIFO
700aA*    03/23/16  LMC  7.00a
     *      - Enh: Adding logic for Metric.
     *      - Fix: Dairyland DRYa would get a decimal data error if
     *        a weight was entered without a qty.
     *      - Fix: zzerrind was executing using $sa values that were
     *        not populated, so error indicators were not turning on
     *        correctly. Moved that code to after the $slot/$slot2
     *        values are populated.
720aA*    08/30/16  LMC  7.20a
     *      - Enh: Added Uci Tracking. UCI tracked item will need to
     *             use RF inventory adjustments because scanning of
     *             uci's to make adjustments is required
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
EIa A*    08/16/11  RH   EIa  #P1050
     *      - Enh: Call DRILICENSE to get slot license, write
     *        Lot code (PO/SEQ) from original license to IAMEMO.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
HSYaA*    10/20/09  RH   HSYa
     *      - Do not allow adjustment type 2=replace.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's
     *
PCK A*    09/08/06  RAH  PCK
     *      - Enh: Add call to UCI Maintenance for Catch Weight items
PCKbA*    09/20/06  RAH  PCKb
     *      - Enh: Change call from UI110 to CW133 for Catch
     *             Weight Items, change paramaters passed
PCKbA*    10/17/06  JCJ  PCKb
     *      - Enh: Added disposition code to CW133 parm list.
PCKcA*    10/30/06  JCJ  PCKc
     *      - Enh: Added code to capture cost for an item.  Chain to
     *             the SAPMOVE file with the reason code entered.  If
     *             the movement type (SMMOVE) is 909 or 902 ask the
     *             user to enter the cost.  Use file INVADJM to store
     *             the cost.
PCKdA*    02/08/07  JCJ  PCKd
     *      - Enh: Changed memo field to be mandatory.
     *
PCKeA*    05/02/07  HNK  PCKe       (applied GJA  5/14/10)
     *      - Enh: Add movement type 935.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: MJ Kellner
     *
MJKaA*    10/16/08  RH   MJKa
     *      - Enh: Must enter alias item for base, write to ITEMADJM
     *----------------------------------------------------------------
YHAaA*  Client Custom Revisions: YHata
YHAbA*    12/20/07  RH   YHAb
     *      - Do not allow entry of MV code.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite Foodservice
     *
BIR A*    02/27/13  MLB  BIR
     *      - Enh: Revise pgm to read/write SCREEN1B. Screen revised
     *        to add | marker under Memo fld for where to key p/o nbr.
     *
     *----------------------------------------------------------------
DRYaA*  Client Custom Revisions: Dairyland
     *
     *    12/11/13  RBD  DRYa
     *      - Enh: Added catchweight variance check, hard halt if error.
     *
     *----------------------------------------------------------------
ADFaA*  Client Custom Revisions: A&D Foods
     *    04/20/17  RH   ADFa
     *      - Do not allow entry of CI code.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

520dDF*t122fm   cf   e             workstn
610aDF*t12201   cf   e             workstn
650 DF*it12202   cf   e             workstn
650bDF*t12203   cf   e             workstn
700aDF*it12204   cf   e             workstn
700aMFit12205   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fslotstat  if   e           k disk
     Funmesr    if   e           k disk
510bAFsapmove1  if   e           k disk
520bAFitemlnk1  if   e           k disk
520bAFpiritem   if   e           k disk
510bAFitemadjm  o    e             disk
520cAF*slot2     if   e           k disk
610bAFoptions   if   e           k disk
DRYaAFitemmsc   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a10             s              1    dim(10)
510 D**desc            s             50    dim(3) ctdata perrcd(1)
510cD**desc            s             50    dim(4) ctdata perrcd(1)
520bDD*desc            s             50    dim(5) ctdata perrcd(1)
520bMD*desc            s             50    dim(6) ctdata perrcd(1)
YHAbDD*desc            s             50    dim(7) ctdata perrcd(1)
650bMD desc            s             50    dim(8) ctdata perrcd(1)
700aAD cmdln           s             79    dim(3)ctdata perrcd(1)

700aA*----------------------------------------------------------------
700aA* Function prototypes.
700aA*----------------------------------------------------------------

700aA /copy qcopysrc,p.getimuom

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
640bA /COPY *libl/qcopysrc,C#LICENSE
640bA /COPY *libl/qcopysrc,C#LICINFO
     D savever#        s                   like($slver#)

510aA*----------------------------------------------------------------
510aA*  Customer id
510aA*----------------------------------------------------------------

510aA /copy qcopysrc,id#packers
520 A /copy qcopysrc,id#mjkelln
YHAaA /copy qcopysrc,id#yhata
HSYaA /copy qcopysrC,id#halsey
EIa A /copy qcopysrc,id#ei
BIR A /copy qcopysrc,id#birite
DRYaA /copy qcopysrc,id#dairyla
ADFaA /copy qcopysrC,id#adf

600bDD*slotds        e ds                  extname(slot)

600aA*----------------------------------------------------------------
600aA*  LT210 parameters
600aA*----------------------------------------------------------------

     D  $tcmd          s              8
     D  $tprogram      s             10
     D  $ttype         s              3
     D  $thead         s             20
     D  $twhse         s              3  0
     D  $titem         s             15
     D  $titemdsc      s             65
     D  $twhdp         s              5
     D  $tslot         s             12
     D  $tslotpos      s              3  0
     D  $templ#        s              5  0
     D  $ttran#        s              7  0
     D  $tlic#         s             15
     D  $tnewlic#      s             15
     D  $tqty1         s              5  0
     D  $tqty2         s              3  0
     D  $tqty3         s              3  0
     D  $tnorm1        s              5  0
     D  $tnorm2        s              3  0
     D  $tnorm3        s              3  0
     D  $tpartial      s               n
     D  $tpulled       s              3  0
     D  $tinslot       s              1
     D  $tsamepos      s              1
     D  $tdiffpos      s              1
     D  $tpsplit       s              1
     D  $tinlic#       s             15
     D  $toutlic#      s             15
     D  $tnexttask     s             10
     D  $treturn       s              8
     D  $terrmsg       s             60
     D  $tmsgid        s              4

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhdp          s                   like($slwhdp)
     D $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

520b D $awhse          s                   like($pwhse)
520b D $aitem          s                   like($iitem)
520b D $asitm          s                   like($iitem)
520b D $artn           s                   like($prtn)
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
DRYaAD caltol          s             13  4
     D chgqt1          s                   like($saqty1)
     D chgqt2          s                   like($saqty2)
     D chgqt3          s                   like($saqty3)
600bAD chk4err         s               n
     D clear           s              5  0
     D cmdtkn          s              1
700aAD CnvWgt          s              9  2
     D comand          s              5  0
520c D*difqty1         s              5  0
520c D*difqty2         s              5  0
520c D*difqty3         s              5  0
     D e               s              2  0
     D enter           s              5  0
DRYaAD errng           s              3  1
     D error           s               n
DRYaAD exwgt           s              9  2
DRYaAD exwgt1          s              9  2
DRYaAD exwgt2          s              9  2
DRYaAD exwgt3          s              9  2
520b D forevr          s              1
     D help            s              5  0
DRYaAD hirng           s              9  2
DRYaAD hivar           s              9  2
700aAD kgs2lbs         c                   2.20462262
700aAD KiloLbs         s              1
700aAD IMkilolbs       s              1
700aAD IMUom           s              3
DRYaAD lwrng           s              9  2
DRYaAD lwvar           s              9  2
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
510bAD ovrrid3         s              1    Inz('0')
DRYaAD prg1c           s              4  3
DRYaAD prg2c           s              4  3
     D rolldn          s              5  0
     D rollup          s              5  0
     D savav1          s                   like($slavl1)
     D savav2          s                   like($slavl2)
     D savav3          s                   like($slavl3)
     D savst           s                   like($slstat)
     D sclear          s              1
     D ssbflg          s               n
520b D svalis          s                   like($iitem)
     D usesc           s              1  0
     D warn            s               n
DRYaAD wgtDiff         s             11  4
     D whse            s              3  0
640bAD wocode          s             10
640bAD worpo           s              9
640bAD woseq           s              3  0
     D w1qty1          s                   like($cqty1)
     D w1qty2          s                   like($cqty2)
     D w1qty3          s                   like($cqty3)
     D zmsflag         s               n
510aAD client          s             10
510bAD costflag        s              1
510bAD workcost        s              7  2

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

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
213 AD  $puser                39     48
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
pckbDD*@cwght          c                   const('UI110')
pckbMD @cwght          c                   const('CW133')
520bAD @gtals          c                   const('GETALSW')
520cAD*@sltdt          c                   const('UPDSLTDTE')
520cAD*@tlsdt          c                   const('TOTSLTDTE')
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
PCK AD  $lwhseu               19     21  0
PCK AD  $litemu               22     36
PCK AD  $lcodeu               37     38
520 D** w1type                39     39
520 D** w1qt01                40     44  0
520bD** w1qt02                45     47  0
520 D** w1qt03                48     50  0
520 D** w1cwtr                51     59  2
520 MD  $l_w1type             39     39
520 MD  $l_w1qt01             40     44  0
520 MD  $l_w1qt02             45     47  0
520 MD  $l_w1qt03             48     50  0
520 MD  $l_w1cwtr             51     59  2
PCKbAD  $ldate                60     64p 0
PCKbAD  $ltime                65     68p 0
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
PAKcA*----------------------------------------------------------------
PAKcA*  Inventory Adjustment Misc. File data structures
PAKcA*
PAKcA /copy qcopysrc,inmsc1_pak
PAKcA /copy qcopysrc,inmsc2_pak
PAKcA /copy qcopysrc,inmsc3_pak
PAKcA /copy qcopysrc,inmsc4_pak
PAKcA /copy qcopysrc,inmsc5_pak
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
     *
     D  eridsg                 1      5
     D  ersdsg                 6     10
415dD*
415dD*                                   P   1   30ERNPCK
415dD*                                   P   4   60ERAPCK
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
600bA /Copy qcopysrc,c#pgminfds
600bDD**              sds
600bDD**#prog            *proc
600bDD**#job                 244    253
600bDD**#user                254    263
600bDD**#jobn                264    269
600bDD**#jobdt               276    281  0
600bDD**#jobtm               282    287  0
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
610bA*----------------------------------------------------------------
610bA*  *SYSTEM  -  System options.
610bA*----------------------------------------------------------------
610bA*
610bA* Fields
610bA*
DRYaA*    OPRG1C  -  Catch weight low variance percentage.
DRYaA*    OPRG2C  -  Catch weight high variance percentage.
610b *    OPUCI   -  Use UCI processing (Y,N)
500kA*
500kA* Data structure
500kA*
650aDD*opddta          ds
650aMD opdata          ds
DRYaAD  oprg1c                 6      8  1
DRYaAD  oprg2c                 9     11  1
610cDD**opuci                 33     33
610cMD  opuci                 36     36
610bAD  optendj              117    117
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
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
510bAC                   eval      *in94 = *on
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
 1B  C                   if        error = *on
     C                   move      'EOJ'         nxtscr
 1E  C                   endif
     *
 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
510bAC     nxtscr        caseq     '03 '         sc3
 2E  C                   endcs
 1E  C                   enddo
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
 1B  C                   if        error = *on
     C                   eval      *in98 = *on
 1E  C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
 1B  C                   if        nxtscr = '01 '
BIR A*
BIR AC                   select
BIR AC                   when      client = birite
BIR AC                   exfmt     screen1B                             50
BIR AC                   other
BIR A*
     C                   exfmt     screen1                              50
BIR AC                   endsl
BIR A*
 1E  C                   endif
     *
 1B  C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
 1E  C                   endif
510bA*
510bAC                   if        nxtscr = '03 '
510bAC                   exfmt     screen3                              50
510bAC                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       10
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
     C                   move      '01 '         nxtscr
     *
     *  Get field defaults if this is an add.
     *
 1B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
 1X  C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
 1E  C                   endif
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     *
     *  Get field defaults if this is an add.
     *
 1B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
 1X  C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
 1E  C                   endif
     C                   eval      ovrrid = *off
     C     end02i        endsr
510bA*----------------------------------------------------------------
510bA*
510bA*  Screen 02 initialization
510bA*
510bAC     scr03i        begsr
510bAC                   move      '03 '         nxtscr
510bA*
510bA*  Get field defaults if this is an add.
510bA*
510bAC                   if        $pcmd = '*ADD    '  or
510bAC                             $pcmd = '*CHANGE '
510bAC                   exsr      zzdft3
510bAC                   else
510bAC                   endif
510bA*
510bAC                   eval      ovrrid3 = *off
510bA*
510bAC     end03i        endsr
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
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
 2E  C                   endif
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
goto Csr                 goto      endsc1
 1E  C                   endif
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
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
700aA*     Setup converted weight field.
700aAC                   exsr      zzcnvwgt
     C                   exsr      zzchk1

PCK AC                   if        costflag = *on
PCK AC                   exsr      scr03i
PCK AC                   goto      endsc1
PCK AC                   endif

     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
 1E  C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   move      'EOJ'         nxtscr
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
 2E  C                   endif
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc2
 1E  C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   move      'EOJ'         nxtscr
     C     endsc2        endsr
510bA*----------------------------------------------------------------
510bA*
510bA*  SC3  -  Screen 3
510bA*
510bA*----------------------------------------------------------------
510bA*
510bA*  SC3  -  Screen 3
510bA*
510bAC     sc3           begsr
510bA*
510bA*  Test for F3 - Exit
510bA*
510bAC                   if        *inkc
510bAC                   move      '01 '         nxtscr
510bAC                   eval      $prtn = '*PGMQ   '
510bAC                   goto      endsc3
510bAC                   endif
510bA*
510bA*  Test for F12 - Previous
510bA*
510bAC                   if        *inkl
510bAC                   move      '01 '         nxtscr
510bAC                   eval      $prtn = '*PGMQ   '
510bAC                   goto      endsc3
510bAC                   endif
510bA*
510bA*  Test for other command keys BEFORE verification and update.
510bA*
510bAC                   exsr      zzcmd3
510bAC     cmdtkn        cabeq     *on           endsc3
510bA*
510bA*  Some other key pressed.
510bA*
510bA*     Check input and write/update record.
510bA*
510bAC                   if        $pcmd = '*ADD    '  or
510bAC                             $pcmd = '*CHANGE '
510bAC                   exsr      zzchk3
510bAC     error         cabeq     *on           endsc3
510bAC                   endif
510bA*
510bA*  Everything went fine so get out of program.
510bA*
510bAC                   move      '01 '         nxtscr
510bAC     endsc3        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroti
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
520b C                   eval      forevr = *off
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
510aA*
510aA* Get client id.
510aA*
510aAC                   call      'GETCLIENT'
510aAC                   parm                    client
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
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
 1B  C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
 1E  C                   endif
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
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
 1B  C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
 1E  C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   move      *on           sclear
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif
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

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    DRI0001s Local system caused error (send to different program)
     *----------------------------------------------------------------

     C     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105s Generic error (send to different program)
     *----------------------------------------------------------------

     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*PGMQ'
     C                   endsr

     *   PIR0009  Number can not be negative.
     *
     C     zm0009        begsr
     C                   move      'PIR0009'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm0201        begsr
     C                   move      'PIR0201'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm0202        begsr
     C                   move      'PIR0202'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   move      'PIR7971'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   move      'PIR7972'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *
     C     zm7973        begsr
     C                   move      'PIR7973'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm7974        begsr
     C                   move      'PIR7974'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM10  Can't replace, quantity is pending.
     *
     C     zm10          begsr
     C                   move      'IT13210'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
520dA*----------------------------------------------------------------
520d *     ZM11  Qty and wt must be same sign (both + or -)
520d *
520d C     zm11          begsr
520d C                   move      'IT13211'     #msgid
520d C                   move      '*DIAG  '     #msgtp
520d C                   movea     errmsg        $md(1)
520d C                   exsr      zmpmsg
520dAC                   endsr
     *----------------------------------------------------------------
     *     IT12216  Quantity can not be negative when replacing.
     *
     C     zm16          begsr
     C                   move      'IT12216'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12215  Slot does not contian item.
     *
     C     zm15          begsr
     C                   move      'IT12215'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     IT12217  Warning: Slot quanitiy changed before adjustment.
     *
     C     zm17          begsr
     C                   move      'IT12217'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12273  Adjustment not completed - Record doesn't exist.
     *
     C     zm73          begsr
     C                   move      'IT12273'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12274  Adjustment not completed - Record locked.
     *
     C     zm74          begsr
     C                   move      'IT12274'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12275  Not enough warehouse available qty.
     *
     C     zm2275        begsr
     C                   move      'IT12275'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off

     *   Verify adjustment type.

HSYa C                   if        client = halsey and
HSYa C                             w1type <> '1'
HSYa C                   eval      error = *on
HSYa C                   eval      *in21 = *on
HSYa C                   eval      *in01 = *on
HSYa C                   eval      errmsg = desc(2)
HSYa C                   exsr      zm1001
HSYaAC                   else
 1B  C                   if        w1type <> '1'  and
     C                             w1type <> '2'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = desc(2)
     C                   exsr      zm1001
 1E  C                   endif
HSYaAC                   endif

     *   Can not replace if quantity is pending.

 1B  C                   if        w1type = '2'
 2B  C                   if        $slalc1 <> 0  or
     C                             $slalc2 <> 0  or
     C                             $slalc3 <> 0  or
     C                             $sltfr1 <> 0  or
     C                             $sltfr2 <> 0  or
     C                             $sltfr3 <> 0  or
     C                             $slpck1 <> 0  or
     C                             $slpck2 <> 0  or
     C                             $slpck3 <> 0  or
     C                             $slrcv1 <> 0  or
     C                             $slrcv2 <> 0  or
     C                             $slrcv3 <> 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm10
 2E  C                   endif
 1E  C                   endif
650b
650b *  Verify FIFO or LIFO method.
650b
650b C                   if        w1fifo <> 'Y'  and
650b C                             w1fifo <> 'N'
650b C                   move      *on           error
650b C                   eval      *in34 = *on
650b C                   eval      *in14 = *on
650b C                   eval      errmsg = desc(8)
650b C                   exsr      zm1001
650b C                   goto      endck1
650b C                   endif

     *   Verify catchweight.

 1B  C                   if        not *in95  and
     C                             w1cwtr = 0
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0110
 1E  C                   endif

510 A*   Verify department of item matches the department of slot.

510 AC                   if        $itwhdp <> $slwhdp and
510 AC                             ovrrid  = *off
510 AC                   eval      error = *on
510 AC                   eval      errmsg = desc(4)
510 AC                   exsr      zm0105
510 AC                   endif

PCKcA*   If client id = 'PACKERS' check movement code to see if cost
PCKcA*   needs to be entered.

PCKcAC                   eval      costflag = *off
PCKcAC                   if        client = packers and error = *off
PCKcAC                                              and ovrrid3 = *off
PCKcA ***                if        w1um1 = 'CV' or w1um1 = 'LB'
PCKcAC     keysp         chain     sapmove1
PCKcAC                   if        %found(sapmove1)
PCKcAC                   if        smmove = '909' or smmove = '922'
PCKeAC                                            or smmove = '935'
PCKcAC                   eval      costflag = *on
PCKcAC                   eval      *in94 = *off
PCKcAC                   else
PCKcAC                   eval      *in94 = *on
PCKcAC                   endif
PCKcAC                   endif
PCKcA ***                endif
PCKcAC                   endif

PCKdA*   If client id = 'PACKERS' make the memo field required entry.

PCKdAC                   if        client = packers and error = *off
PCKdAC                   if        w1memo = *blanks
PCKdAC                   eval      error = *on
PCKdAC                   eval      *in24 = *on
PCKdAC                   eval      *in04 = *on
PCKdAC                   eval      errmsg = desc(5)
PCKdAC                   exsr      zm0105
PCKdAC                   endif
PCKdAC                   endif

     *   Skip to end if there was an error already.

 1E  C     error         cabeq     *on           endck1

     *   Set working quantities.

 1B  C                   if        usesc = 1
     C                   z-add     w1qt01        w1qty1
     C                   z-add     w1qt02        w1qty2
     C                   z-add     w1qt03        w1qty3
 1E  C                   endif

     *     Convert string to quantities.

 1B  C                   if        usesc = 2  and
     C                             w2qty <> *blanks
     C                   eval      $ccmd = '*STR2QTY'
     C                   eval      $cprg = #prog
     C                   move      w2qty         $cqstr
     C                   call      'CVTQTY'
     C                   parm                    $ccmd             8
     C                   parm                    $cprg            10
     C                   parm                    $cqty1            7 0
     C                   parm                    $cqty2            7 0
     C                   parm                    $cqty3            7 0
     C                   parm                    $cum1             2
     C                   parm                    $cum2             2
     C                   parm                    $cum3             2
     C                   parm                    $cqstr           10
     C                   parm                    $custr           17
     C                   parm                    $crtn             8
     C                   parm                    $cerm
 2B  C                   if        $crtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $cmsg
     C                   exsr      zmqmsg
 2E  C                   endif
     C                   z-add     $cqty1        w1qty1
     C                   z-add     $cqty2        w1qty2
     C                   z-add     $cqty3        w1qty3
 1E  C                   endif
520dA*  Verify qty and cw are same sign (both positive or negative)
520d
520d C                   select
520d C                   when      w1qty1 < 0  or
520d C                             w1qty2 < 0  or
520d C                             w1qty3 < 0
520d C                   if        w1cwtr > 0
520d C                   move      *on           error
520d C                   eval      *in33 = *on
520d C                   if        w1qty1 <> 0
520d C                   eval      *in24 = *on
520d C                   endif
520d C                   if        w1qty2 <> 0
520d C                   eval      *in29 = *on
520d C                   endif
520d C                   if        w1qty3 <> 0
520d C                   eval      *in30 = *on
520d C                   endif
520d C                   exsr      zm11
520d C                   goto      endck1
520d C                   endif
520d
520d C                   when      w1qty1 > 0  or
520d C                             w1qty2 > 0  or
520d C                             w1qty3 > 0
520d C                   if        w1cwtr < 0
520d C                   move      *on           error
520d C                   eval      *in33 = *on
520d C                   if        w1qty1 <> 0
520d C                   eval      *in24 = *on
520d C                   endif
520d C                   if        w1qty2 <> 0
520d C                   eval      *in29 = *on
520d C                   endif
520d C                   if        w1qty3 <> 0
520d C                   eval      *in30 = *on
520d C                   endif
520d C                   exsr      zm11
520d C                   goto      endck1
520d C                   endif

520d C                   endsl
DRYaA
DRYaA*   Verify catchweight variances for specific client/s
DRYaA
DRYaAC                   select
DRYaA
DRYaAC                   when      client = Dairyland
DRYaAC                             and not *in95
DRYaAC                   eval      exwgt  = 0
DRYaAC                   eval      exwgt1 = 0
DRYaAC                   eval      exwgt2 = 0
DRYaAC                   eval      exwgt3 = 0
DRYaA
DRYaAC                   if        w1qt01 <> 0
DRYaAC                   eval      exwgt1 = w1qt01 * $itswgt
DRYaAC                   endif
DRYaA
DRYaAC                   if        w1qt02 <> 0
DRYaAC                   eval      exwgt2 = ($itswgt/$itumq2) * (w1qt02)
DRYaAC                   endif
DRYaA
DRYaAC                   if        w1qt03 <> 0
DRYaAC                   eval      exwgt3 = $itswgt/$itumq2
DRYaAC                   eval      exwgt3 = (exwgt3/$itumq3) * (w1qt03)
DRYaAC                   endif
DRYaA
DRYaAC                   eval      exwgt  = exwgt1 + exwgt2 + exwgt3
DRYaA
DRYaAC                   eval      prg1c = 0
DRYaAC                   eval      prg2c = 0
DRYaAC                   eval      lwrng = 0
DRYaAC                   eval      hirng = 0
DRYaA
DRYaA*    Use item variance % if it exists
DRYaAC     keyil1        chain     itemmsc
DRYaAC                   if        %found(itemmsc)
DRYaAC                   if        imrg1c <> 0
DRYaAC     imrg1c        div       100           prg1c
DRYaAC                   endif
DRYaAC                   if        imrg2c <> 0
DRYaAC     imrg2c        div       100           prg2c
DRYaAC                   endif
DRYaAC                   endif
DRYaA
DRYaA*    Use system variance % if item variance % is zero
DRYaAC                   if        prg1c = 0
DRYaAC     oprg1c        div       100           prg1c
DRYaAC                   endif
DRYaAC                   if        prg2c = 0
DRYaAC     oprg2c        div       100           prg2c
DRYaAC                   endif
DRYaA
DRYaAC                   if        prg1c > 0
DRYaAC     exwgt         mult      prg1c         lwvar
DRYaAC                   eval      lwrng = exwgt - lwvar
DRYaAC                   endif
DRYaAC                   if        prg2c > 0
DRYaAC     exwgt         mult      prg2c         hivar
DRYaAC                   eval      hirng = exwgt + hivar
DRYaAC                   endif
DRYaA*
700aDC*                  if        %abs(w1cwtr) <= %abs(lwrng)
700aMC                   if        %abs(cnvwgt) <= %abs(lwrng)
DRYaAC                   eval      error = *on
DRYaAC                   eval      *in33 = *on
DRYaAC                   eval      errmsg = *blanks
DRYaAC                   eval      errng = prg1c * 100
700aDC*                  eval      wgtDiff = %abs(exwgt) - %abs(w1cwtr)
700aMC                   eval      wgtDiff = %abs(exwgt) - %abs(cnvwgt)
700aAc                   if        %abs(exwgt) <> 0
DRYaAC                   eval      caltol = wgtDiff / %abs(exwgt)
700aAc                   endif
DRYaAC                   eval      caltol = caltol * 100
DRYaA* If wgt entered and low range are equal, force calc tolerance to
DRYaA* be the same value as low tolerance, otherwise, sometimes you will
DRYaA* end up with something like "Wgt tol% 29.99 >= 30.0'.
700aDC*                  if        w1cwtr = lwrng
700aMC                   if        cnvwgt = lwrng
DRYaAC                   eval      caltol = errng
DRYaAC                   endif
DRYaAC                   eval      errmsg = 'Wgt tol% '
DRYaAC                                      + %triml(%editc(caltol:'3'))
DRYaAC                                      + ' >= var% '
DRYaAC                                      + %triml(%editc(errng:'3'))
DRYaAC                   exsr      zm0105
DRYaAC                   goto      endck1
DRYaAC                   endif
DRYaA
700aDC*                  if        %abs(w1cwtr) >= %abs(hirng)
700aMC                   if        %abs(cnvwgt) >= %abs(hirng)
DRYaAC                   eval      error = *on
DRYaAC                   eval      *in33 = *on
DRYaAC                   eval      errmsg = *blanks
DRYaAC                   eval      errng = prg2c * 100
700aDC*                  eval      wgtDiff = %abs(exwgt) - %abs(w1cwtr)
700aMC                   eval      wgtDiff = %abs(exwgt) - %abs(cnvwgt)
700aAc                   if        %abs(exwgt) <> 0
DRYaAC                   eval      caltol = wgtDiff / %abs(exwgt)
700aAC                   endif
DRYaAC                   eval      caltol = caltol * 100
DRYaA* If wgt entered and high range are equal, force calc tolerance to
DRYaA* be the same value as high tolerance, otherwise, sometimes you will
DRYaA* end up with something like "Wgt tol% 29.99 >= 30.0'.
700aDC*                  if        w1cwtr = hirng
700aMC                   if        cnvwgt = hirng
DRYaAC                   eval      caltol = errng
DRYaAC                   endif
DRYaAC                   eval      errmsg = 'Wgt tol% '
DRYaAC                                      + %triml(%editc(caltol:'3'))
DRYaAC                                      + ' >= var% '
DRYaAC                                      + %triml(%editc(errng:'3'))
DRYaAC                   exsr      zm0105
DRYaAC                   goto      endck1
DRYaAC                   endif
DRYaA
DRYaAC                   endsl
     *
     *  Calculate change quantities.
     *
 1B  C                   select
     *
     *     Increasing/Decreasing quantity.
     *
 1X  C                   when      w1type = '1'
     C                   eval      chgqt1 = w1qty1
     C                   eval      chgqt2 = w1qty2
     C                   eval      chgqt3 = w1qty3
     *
     *     Replacing quantity.
     *
 1X  C                   other
     C                   eval      chgqt1 = w1qty1 - $slstk1
     C                   eval      chgqt2 = w1qty2 - $slstk2
     C                   eval      chgqt3 = w1qty3 - $slstk3
 1E  C                   endsl

     *   Call interface to do verification.

600bAC                   exsr      clr$slot
600bAC                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = $pwhse
600bAC                   eval      $slwhdpu = *on
600bAC                   eval      $slwhdp  = $pwhdp
600bAC                   eval      $sldispu = *on
600bAC                   eval      $sldisp  = $pdisp
600bAC                   eval      $saitemu = *on
600bAC                   eval      $saitem  = $ititem
600bA
600bAC                   eval      $saqtyu  = *on
600bAC                   eval      $saqty1  = chgqt1
600bAC                   eval      $saqty2  = chgqt2
600bAC                   eval      $saqty3  = chgqt3
600bA
600bAC                   eval      $sacwtau = *on
700aDC*                  eval      $sacwta  = w1cwtr
700aMC                   eval      $sacwta  = cnvwgt
600bA
600bAC                   eval      $sacodeu = *on
600bAC                   eval      $sacode  = w1code
600bA
600bAC                   eval      $samemou = *on
600bAC                   eval      $samemo  = w1memo
600bA
600bAC                   eval      $sabyu   = *on
600bAC                   eval      $saby    = $puser

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VERIFY'
     C                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *on
600bAC                   eval      zmsflag = *off
     C                   exsr      zzzdricop
MJKaAC                   if        client = mjkellner
520b C                   eval      svalis = *blanks
520b *  Check if alias item exists for base.
520b C     keyil1        setll     itemlnk1
520b C     forevr        doweq     forevr
520b C     keyil1        reade     itemlnk1                               77
520b C     *in77         ifeq      *on
520b C                   leave
520b C                   endif
520b C*      Get item record.
520b C*
520b C     keyit         chain     piritem
520b C                   if        not %found
520b C                   iter
520b C                   endif
520b C*
520b C*      Looking for Alias item.
520b C*
520b C     ittype        ifne      'A'
520b C                   iter
520b C                   endif
520b C*
520b C*      Found Alias item, call program to select Alias
520b C*
520bAC                   eval      $awhse    = $pwhse
520bAC                   eval      $aitem    = $iitem
520bAC                   eval      $asitm    = *blanks
520bAC                   eval      $artn     = *blanks
520bAC                   call      @gtals
520bAC                   parm                    $awhse
520bAC                   parm                    $aitem
520bAC                   parm                    $asitm
520bAC                   parm                    $artn
520bAC                   eval      svalis = $asitm
MJKaAC*                  if        client = mjkellner
520b C                   if        $artn  <> '*FOUND' or
520b C                             $asitm = *blanks
520b C                   move      *on           error
520b C*                  eval      *in22 = *on
520b C*                  eval      *in12 = *on
520b C                   eval      errmsg = *blanks
520b C                   eval      errmsg = desc(6)
520b C                   exsr      zm1001
520b C                   endif
MJKaAC*                  endif
520b C                   leave
520bAC                   enddo
520b C     error         cabeq     *on           endck1
MJKaAC                   endif
YHAb *  Do not allow adjustment code 'MV'
YHAb
YHAa C                   if        client = yhata and
YHAb C                             w1code = 'MV'
YHAb C                   move      *on           error
YHAb C                   eval      *in23 = *on
YHAb C                   eval      *in03 = *on
YHAb C                   eval      errmsg = desc(7)
YHAb C                   exsr      zm1001
YHAb C                   goto      endck1
YHAb C                   endif
ADFa *  Do not allow adjustment code 'CI' can only be used for
ADFa *  change item thru program.
ADFa C                   if        client = AandDFoods and
ADFa C                             w1code = 'CI'
ADFa C                   move      *on           error
ADFa C                   eval      *in25 = *on
ADFa C                   eval      *in05 = *on
ADFa C                   eval      errmsg = desc(8)
ADFa C                   exsr      zm1001
ADFa C                   goto      endck1
ADFa C                   endif

     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   exsr      zzchk1
     *
     C     endck2        endsr
510bA*----------------------------------------------------------------
510bA*
510bA*  ZZCHK3   Screen 3 error checking.
510bA*
510bAC     zzchk3        begsr
510bA*
510bA*  Cost required if movement types are '909' or '922'
510bA*
510bAC                   if        w3cost <= *zeros
510bAC                   eval      error = *on
     C                   else
510bAC                   eval      ovrrid3 = *on
510bAC                   endif
510bA*
510bAC     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
 1B  C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
 2B  C                   select
     *
     *     Return code.
     *
 2X  C                   when      row# = 20
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lcode = w1code
520aDC*                  eval      w1qt01 = *zeros
520aDC*                  eval      w1qt02 = *zeros
520aDC*                  eval      w1qt03 = *zeros
520aDC*                  eval      w1cwtr = *zeros
520aDC*                  eval      $ldate = *zeros
520aDC*                  eval      $ltime = *zeros
     C                   call      'AD900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1code = $lcode
 3E  C                   endif
     *
     *     Cursor not on a valid lookup field.
     *
 2X  C                   other
     C                   move      *on           error
     C                   exsr      zm9905
 2E  C                   endsl
goto Csr                 goto      endcm1
 1E  C                   endif
700aA*
700aA*      F7 - kilograms/Pounds toggle
700aA*
700aAC                   if        *inkg
700aAC                   eval      cmdtkn = *on
700aAC                   if        KiloLbs = 'P'
700aAC                   eval      KiloLbs = 'K'
700aAC                   eval      W1KgLb  = 'Kgs'
700aAC                   else
700aAC                   eval      KiloLbs = 'P'
700aAC                   eval      W1KgLb  = 'Lbs'
700aAC                   endif
700aAc                   exsr      zzsetcmdln1
700aAC                   goto      endcm1
700aAC                   endif

     *
     *      F9 - View slot quantities.
     *
 1B  C                   if        *inki
     C                   move      *on           cmdtkn
     C                   z-add     $pwhse        whse
     C                   call      'SL810'
     C                   parm                    whse
     C                   parm                    $pwhdp
     C                   parm                    $pdisp
 1E  C                   endif
     *
     *      F20 - Accept Warning.
     *
 1B  C                   if        *inku
     C                   move      *on           ovrrid
 1E  C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   exsr      zzcmd1
     *
     C     endcm2        endsr
510bA*----------------------------------------------------------------
510bA*
510bA*  ZZCMD3   User defined command keys for screen 3.
510bA*
510bAC     zzcmd3        begsr
510bA*
510bAC     endcm3        endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZCNVWGT  Setup converted weight field.
700aA*
700aAC     zzcnvwgt      begsr
700aA*
700aA*
700aA* If item options is setup as kgs and user enters kgs no conversion
700aA* If item options is setup as kgs and user enters lbs need conversion
700aA* If item options is setup as lbs and user enters lbs no conversion
700aA* If item options is setup as lbs and user enters kgs need conversion
700aA /free
700aA   select;
700aA     when IMkilolbs = 'K';
700aA       if KiloLbs = 'K';
700aA         eval cnvwgt = w1cwtr;
700aa       else;
700aA         eval(h) cnvwgt = w1cwtr / kgs2lbs;
700aA       endif;
700aA     other;
700aM       if KiloLbs = 'K';
700aM         eval(h) cnvwgt = w1cwtr * kgs2lbs;
700aM       else;
700aM         eval cnvwgt = w1cwtr;
700aM       endif;
700aA   endsl;
700aA /end-free

700aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     *
     *   This program is only called with *CHANGE.
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     *
     *   This program is only called with *CHANGE.
     *
     C                   endsr
510bA*----------------------------------------------------------------
510bA*
510bA*  ZZDFT3   Get default values for add.
510bA*
510bAC     zzdft3        begsr
510bA*
510bAC                   eval      w3cost = *zeros
510bA*
510bAC                   endsr

     *----------------------------------------------------------------
     *  zzerrind    Set error indicators from DRI call.
     *----------------------------------------------------------------

     C     zzerrind      begsr

     C                   if        $sacodee = '1'
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif

     C                   if        $saqty1e = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   if        $saqty2e = '1'
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   endif

     C                   if        $saqty3e = '1'
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   endif

     C                   if        $sacwtae = '1'
     C                   eval      *in33 = *on
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZFIL0   Fill screen 1 & 2 heading fields.
     *
     C     zzfil0        begsr

     *      Convert available quantity to string.

     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = $slavl1
     C                   eval      $cqty2 = $slavl2
     C                   eval      $cqty3 = $slavl3

     C                   call      'CVTQTY'
     C                   parm                    $ccmd
     C                   parm                    $cprg
     C                   parm                    $cqty1
     C                   parm                    $cqty2
     C                   parm                    $cqty3
     C                   parm                    $cum1
     C                   parm                    $cum2
     C                   parm                    $cum3
     C                   parm                    $cqstr
     C                   parm                    $custr
     C                   parm                    $crtn
     C                   parm                    $cerm
     C                   eval      w1incq = $cqstr

     *      Convert adjustable quantity to string.

     C                   eval      $cqty1 = $sladj1
     C                   eval      $cqty2 = $sladj2
     C                   eval      $cqty3 = $sladj3

     C                   call      'CVTQTY'
     C                   parm                    $ccmd
     C                   parm                    $cprg
     C                   parm                    $cqty1
     C                   parm                    $cqty2
     C                   parm                    $cqty3
     C                   parm                    $cum1
     C                   parm                    $cum2
     C                   parm                    $cum3
     C                   parm                    $cqstr
     C                   parm                    $custr
     C                   parm                    $crtn
     C                   parm                    $cerm
     C                   eval      w1excq = $cqstr

     *  Get status description.

     C     $slstat       chain     slotstat                           79
 1B  C                   if        *in79
     C                   eval      ssdesc = *blanks
     C                   movel     $slstat       ssdesc
 1E  C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr

     *   Initialize header fields. Save quantities and status for
     *     comparison before updating.

     C                   exsr      zzfil0
     C                   z-add     $slavl1       savav1
     C                   z-add     $slavl2       savav2
     C                   z-add     $slavl3       savav3
     C                   move      $slstat       savst

     *   Get Unit of measure fields

     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom

     *   Format item description.

     C                   movel     $ititem       $iitem
     C                   movel     $itdesc       $idesc
     C                   movel     $itpdsc       $ipdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   eval      woitem = *blanks
     C                   movel     $istr         woitem

     *   Get SSB item, if one exists

     C                   move      *off          ssbflg
     C                   eval      wolbls = *blanks
     C                   eval      wositm = *blanks
 1B  C                   if        $ittype = ' '
     C                   call      'GETSSB'
     C                   parm      $itwhse       $gwhse            3 0
     C                   parm      $ititem       $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm                    #brtn             8

 2B  C                   if        #brtn = '*FOUND  '
     C                   move      *on           ssbflg
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     C                   movel     'SSB ('       wolbls
     C     wolbls        cat       w1um2:0       wolbls
     C     wolbls        cat       ')':0         wolbls
     C                   move      ':'           wolbls

     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    #bitem
     C                   parm                    #bdesc
     C                   parm                    #bpdsc
     C                   parm                    $istr
     C                   movel     $istr         wositm

 2E  C                   endif

 1E  C                   endif

610a *   Set slot display
610a
610a C                   eval      wodisp = $pdisp
     *   Expand slot seciton type.

 1B  C                   if        $slstyp = 'P'
     C                   eval      wostyp = 'PIR  '
 1X  C                   else
     C                   eval      wostyp = 'Fixed'
 1E  C                   endif

     *   Initialize entry fields

     C                   eval      w1type = '1'
     C                   eval      w1qt01 = 0
     C                   eval      w1qt02 = 0
     C                   eval      w1qt03 = 0
     C                   eval      w1qty1 = 0
     C                   eval      w1qty2 = 0
     C                   eval      w1qty3 = 0
     C                   eval      w1cwtr = 0
     C                   eval      w1code = *blanks
     C                   eval      w1memo = *blanks
 1B  C                   if        $itcwgt <> 'Y'
     C                   eval      *in95 = *on
 1X  C                   else
     C                   eval      *in95 = *off
 1E  C                   endif
700aAc                   exsr      zzsetcmdln1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Initialize entry fields
     *
     C                   eval      w2qty = *blanks
     C                   exsr      zzfil1
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
600bAC                   exsr      clr$slot
600bAC                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = $pwhse
600bAC                   eval      $slwhdpu = *on
600bAC                   eval      $slwhdp  = $pwhdp
600bAC                   eval      $sldispu = *on
600bAC                   eval      $sldisp  = $pdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *on
600bAC                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     *
 1B  C                   if        error
     C                   eval      errmsg = desc(1)
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm7973
goto C                   goto      endgt1
 1E  C                   endif
     *
     *  Slot does not contain an item.
     *
 1B  C                   if        $slitem = *blanks
     C                   move      *on           error
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm15
goto C                   goto      endgt1
 1E  C                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     *
     C                   exsr      zzget1
     *
     C     endgt2        endsr
610bA*----------------------------------------------------------------
610bA*
610bA*  ZZGETSYOP  Get System Options record.
610bA*
610bAC     zzgetsyop     begsr
610bA*
610bAC                   eval      opcode = '*SYSTEM '
610bA*
610bAC                   eval      opwhse = *zeros
610bA*
610bAC     opkey         chain     options
610bAC                   if        not %found(options)
DRYaAC                   eval      oprg1c = 0
DRYaAC                   eval      oprg2c = 0
610bAC                   eval      opuci  = 'N'
610bAC                   endif
610bA*
610bAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
510bA*
510bA*  Define key for SAPMOVE1 - Item Movement File
510bA*
510bAC     keysp         klist
510bAC                   kfld                    w1code
     *
     *  Define key for OPTIONS file.
     *
610bAC     opkey         klist
610bAC                   kfld                    opwhse
610bAC                   kfld                    opcode
     *  SLOT2 KEY
520c C*    slkey         klist
520c C*                  kfld                    $pwhse
520c C*                  kfld                    $pwhdp
520c C*                  kfld                    $pdisp

520b *
520b *  Define key for itemlnk1 file.
520b *
520b C     keyil1        klist
520b C                   kfld                    $pwhse
520b C                   kfld                    $iitem
520b *
520b *  Define key for PIRITEM file.
520b *
520b C     keyit         klist
520b C                   kfld                    ilwhse
520b C                   kfld                    ilitem
520b *

     C                   eval      $lprg = #prog
650bAC                   eval      w1fifo = 'Y'
PCKbAC                   eval      w1qty1 = *zero
PCKbAC                   eval      w1qty2 = *zero
PCKbAC                   eval      w1qty3 = *zero
PCKbAC                   eval      w1cwtr = *zero
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
417aAC                   eval      ssbflg = *off
600cA*
600cA*  Do not allow the transfer from a RCV file.
600cA*
600cAC                   if        %subst($pdisp:1:3) = 'RCV'
600cAC                             or %subst($pdisp:1:3) = 'STG'
600cAC                   eval      error = *on
600cAC                   eval      errmsg = 'RCV/STG slot not allowed '
600cAC                                    + '- use Putaway'
600cAC                   exsr      zm0105s
600cAC                   eval      nxtscr = 'EOJ'
600cAC                   leavesr
600cAC                   endif

700aA*
700aA*   Get Item Maintenance options.
700aA*
700aA /free
700aA    whse = $pwhse;
700aA    getimuom(whse: IMkilolbs: IMUom);
700aA    select;
700aA      when IMkilolbs = 'K';
700aA        KiloLbs = 'K';
700aA        W1KgLb  = IMUom;
700aA      other;
700aA        kiloLbs = 'P';
700aA        W1KgLb  = 'Lbs';
700aA    endsl;
700aA /end-free
     *   Get warehouse description.

     C                   eval      wowhse = *blanks
     C                   eval      $cstr = *blanks

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $pwhse        $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   when      $vreturn <> '*OK'
     C                   endsl
     C                   move      $pwhse        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm                    $cstr            30
     *
     *   Put warehouse and department together.
     *
     C                   eval      wowhse = %trim($cstr) + '/'
     C                                    + %trim($pwhdp) + ' - '
     C                                    + %trim($vdesc)
600aA*
600aA*   Get default values for the user.
600aA*
600aAC                   call      'GETUSER'
600bAC                   parm                    #curruser
600aAC                   parm      0             #whse             3 0
600aAC                   parm      0             #emp#             5 0
600aAC                   parm                    #fnam            15
600aAC                   parm                    #init             1
600aAC                   parm                    #lnam            20
600aAC                   parm                    #whdp             5
600aAC                   parm                    #styp             1
600aAC                   parm                    #shft             6
600aAC                   parm                    #crew             6
600aAC                   parm      0             #nhrs             3 1
600aAC                   parm                    #rtn              8

     *
     *   Select first screen to display.
     *
     C                   eval      usesc = 1
 1B  C                   if        usesc = 1
     C                   exsr      scr01i
 1X  C                   else
     C                   exsr      scr02i
 1E  C                   endif
610bAC                   exsr      zzgetsyop
     C                   endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZSETCMDLN1  Setup the command keys
700aa*
700aaC     zzsetcmdln1   begsr
700aA /free
700aA   Select;
700aA     when $itcwgt <> 'Y';
700aA         cmdln1 = cmdln(3);
700aA     when kilolbs  = 'K';
700aA         cmdln1 = cmdln(2);
700aA     when kilolbs  = 'P';
700aA         cmdln1 = cmdln(1);
700aA   endsl;
700aA /end-free
700aaC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuom         begsr
417aAC                   eval      *in92 = *off
417aAC                   eval      *in93 = *off
     *
     *   Get Unit of Measures.
     *    *IN91=Protect & non-display breakdown1 unit of measure
     *    *IN92=Protect & non-display breakdown2 unit of measure
     *
600bAC                   exsr      clr$item
600bAC                   eval      $itwhse  = $pwhse
600bAC                   eval      $ititem  = $slitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *on
600bAC                   eval      zmsflag = *off
     C                   exsr      zzzdricop

 1B  C                   if        error
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
goto C                   goto      enduom
 1X  C                   else
720aA /free
720aA   if $imltrk = 'U';
720aA     error = *on;
720aA     $prtn = '*ERROR';
720aA     $perm = 'UCI Tracked Item - USE RF ADJUSTMENT';
720aA     leavesr;
720aA   endif;
720aA /end-free
 2B  C                   if        $itflg1 = 'N'  and
     C                             ssbflg = *off
     C                   eval      *in92 = *on
 2E  C                   endif
 2B  C                   if        $itflg2 = 'N'  and
     C                             ssbflg = *off  or
     C                             $itflg2 = 'N'  and
     C                             ssbflg = *on  and
     C                             $itum3 = *blanks
     C                   eval      *in93 = *on
 2E  C                   endif
 1E  C                   endif
     *
     C     $itum1        chain     unmesr                             75
 1B  C                   if        not *in75
     C                   eval      w1um1 = umshrt
 1X  C                   else
     C                   eval      w1um1 = *blanks
 1E  C                   endif
     *
 1B  C                   if        not *in92
     C     $itum2        chain     unmesr                             75
 2B  C                   if        not *in75
     C                   eval      w1um2 = umshrt
 2X  C                   else
     C                   eval      w1um2 = *blanks
 2E  C                   endif
 1E  C                   endif
     *
 1B  C                   if        not *in93
     C     $itum3        chain     unmesr                             75
 2B  C                   if        not *in75
     C                   eval      w1um3 = umshrt
 2X  C                   else
     C                   eval      w1um3 = *blanks
 2E  C                   endif
 1E  C                   endif
     C     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   move      *off          error

EIa A*   Call interface to get license info for lot code
EIa AC                   if        client = ei
640bAC                   exsr      clr$license
640bAC                   eval      $liToWhseU = *on
640bAC                   eval      $liToWhse = $pWhse
640bAC                   eval      $liToWhdpU = *on
640bAC                   eval      $liToWhdp = $slwhdp
640bAC                   eval      $liToDispU = *on
640bAC                   eval      $liToDisp = $pdisp
640bAC                   eval      $dricommand = '*LICENSE'
640bAC                   eval      $drisubcmd  = '%GETSLTLIC'
640bAC                   eval      $drisys2upd = 'D'
640bAC                   eval      chk4err = *on
640bAC                   exsr      zzzdricop
640bAC                   if        error
640bAC                             or $drireturn <> '*OK'
640bAC                             or $liToLcns = '*NONE'
640bAC                   else
640bA*  Get receiving information  - PO & Seq
640bA
640bAC                   exsr      clr$licinfo
640bA
640bAC                   eval      $lnemp# = 0
640bAC                   eval      $lnuser = #user
640bAC                   eval      $lnpgm  = #prog
640bAC                   eval      $lnjob  = #job
640bAC                   eval      $lnjobnbr  = #jobn
640bA
640bAC                   eval      $lnwhse  = $Pwhse
640bAC                   eval      $lntype  = 'P'
640bAC                   eval      $lnlcns  = $liOLcns
640bA
640bA*     PO number
640bA
640bAC                   eval      $lncodeu(1) = *on
640bAC                   eval      $lncode(1) = '*PO'
640bAC                   eval      $lncseq(1) = 1
640bA
640bA*     PO Seq number
640bA
640bAC                   eval      $lncodeu(2) = *on
640bAC                   eval      $lncode(2) = '*POSEQ'
640bAC                   eval      $lncseq(2) = 1
640bA
640bAC                   eval      $dricommand = '*LICINFO'
640bAC                   eval      $drisubcmd  = '%GET'
640bAC                   eval      $drisys2upd = 'D'
640bAC                   eval      chk4err = *on
640bAC                   exsr      zzzdricop
640bAC                   if        error
640bAC                   endif
640bA
640bA*  Now process the return information
640bA
640bA*     PO number
640bA
640bAC                   if        $lncodee(1) = $driok
640bAC                             and $lnvalchr(1) <> ' '
640bAC                   eval      wOrpo = %trim($lnvalchr(1))
640bAC                   else
640bAC                   if        %subst($liOLcns:1:3) = '*RT'
640bAC                   eval      wOrpo = '<return>'
640bAC                   else
640bAC                   eval      wOrpo = ' '
640bAC                   endif
640bAC                   endif
640bA*     PO Seq number
640bA
640bAC                   if        $lncodee(2) = $driok
640bAC                             and $lnvalnum(2) <> 0
640bAC                   eval      wOseq = $lnvalnum(2)
640bAC                   else
640bAC                   eval      wOseq = 0
640bAC                   endif
640bA
640bAC                   endif
EIa A
EIa AC                   eval      wocode = %trim(worpo) +
EIa AC                                      %trim(%editc(woseq:'X'))
EIa AC                   eval      w1memo=%replace(wocode:w1memo:21:10)
EIa AC                   endif
     *   Call interface to do update.

600bAC                   exsr      clr$slot
600bAC                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = $pwhse
600bAC                   eval      $slwhdpu = *on
600bAC                   eval      $slwhdp  = $pwhdp
600bAC                   eval      $sldispu = *on
600bAC                   eval      $sldisp  = $pdisp
600bAC                   eval      $saitemu = *on
600bAC                   eval      $saitem  = $ititem
600bA
600bAC                   eval      $saqtyu  = *on
600bAC                   eval      $saqty1  = chgqt1
600bAC                   eval      $saqty2  = chgqt2
600bAC                   eval      $saqty3  = chgqt3
600bA
600bAC                   eval      $sacwtau = *on
700aDC*                  eval      $sacwta  = w1cwtr
700aMC                   eval      $sacwta  = cnvwgt
600bAC                   eval      $sacodeu = *on
600bAC                   eval      $sacode  = w1code
600bAC                   eval      $samemou = *on
600bAC                   eval      $samemo  = w1memo
600bAC                   eval      $sabyu   = *on
600bAC                   eval      $saby    = $puser
600bA
600bAC                   eval      $saActionU = *on
600bAC                   eval      $saAction = 'ADJ'
600bAC**                 eval      $saTrn#U = *on
600bAC**                 eval      $saTrn# = curtrn#
600bAC                   eval      $saETrn#U = *on
600bAC                   eval      $saETrn# = 0
600bAC**                 eval      $saLbl#U = *on
600bAC**                 eval      $saLbl# = lblbl#
600bAC**                 eval      $saToLcnsU = *on
600bAC**                 eval      $saToLcns = wkPulLcns
600bAC**                 eval      $saToPosU = *on
600bAC**                 eval      $saToPos = $tslotpos
600bAC**                 eval      $saToVrfyU = *on
600bAC**                 eval      $saToVrfy = 'N'
600bAC**                 eval      $saToCodeu = *on
600bAC**                 eval      $saToCode = 'S'
600bAC**                 eval      $saToAreaU = *on
600bAC**                 eval      $saToArea = 'Slot'
600bAC**                 eval      $saFrmLcnsU = *on
600bAC**                 eval      $saFrmLcns = wkUsrLcns
600bAC**                 eval      $saOLcnsU = *on
600bAC**                 eval      $saOLcns = wkpulolcns

     C                   eval      $dricommand = '*SLOT'
650bA*   Call with new subcmd to do LIFO adjustment.
650bAC                   if        w1fifo = 'Y'
     C                   eval      $drisubcmd  = '%ADJUST'
650bAC                   else
650bAC                   eval      $drisubcmd  = '%ADJUSTREV'
650bAC                   endif
     C                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *on
600bAC                   eval      zmsflag = *off
     C                   exsr      zzzdricop
MJKaAC                   if        client = mjkellner and
520bAC                             svalis <> *blank
520bAC                   eval      inwhse = $pwhse
520bAC                   eval      initem = $ititem
520bAC                   eval      indate = $sadate
520bAC                   eval      intime = $satime
520bAC                   eval      inby   = #user
520bAC                   eval      inwhdp = $pwhdp
520bAC                   eval      indisp = $pdisp
520bAC                   eval      inudte = *zeros
520bAC                   eval      inutim = *zeros
520bAC                   eval      inmsc1 = svalis
520bAC                   write     inrec
MJKaAC                   endif
600bD **
600bD **  Adjust license.
600bD **
600bDC**                 exsr      zzzclr$lt210
600bDC**                 eval      $tcmd  = '*ADJUST'
600bDC**                 eval      $twhse = $pwhse
600bDC**                 eval      $twhdp = $pwhdp
600bDC**                 eval      $tslot = $pdisp
600bDC**                 eval      $titem = slitem
600bDC**                 eval      $tqty1 = chgqt1
600bDC**                 eval      $tqty2 = chgqt2
600bDC**                 eval      $tqty3 = chgqt3
600bDC**                 eval      $tnorm1 = chgqt1
600bDC**                 eval      $tnorm2 = chgqt2
600bDC**                 eval      $tnorm3 = chgqt3
600bDC**                 exsr      zzzcall$lt210

PCK AC*****              if        client = packers and
610bAC                   if        opuci = 'Y'      and
PCK AC                             $itcwgt = 'Y'
PCK AC                   select
PCK AC                   when      w1qt01 > *zeros
PCK AC                   eval      $lcmd   = '*ADDADJ '
PCK AC                   when      w1qt01 < *zeros
PCK AC                   eval      $lcmd   = '*DLTADJ '
PCK AC                   endsl
PCK AC                   eval      $lwhseu = $pwhse
PCK AC                   eval      $litemu = $ititem
PCK AC                   eval      $lcodeu = w1code
PCK AC*                  eval      $ltypeu = 'A'
PCKbAc                   eval      $ldate = $sadate
PCKbAc                   eval      $ltime = $satime
520 AC                   eval      $l_w1type = w1type
520 AC                   eval      $l_w1qt01 = w1qt01
520 AC                   eval      $l_w1qt02 = w1qt02
520 AC                   eval      $l_w1qt03 = w1qt03
700aDC*                  eval      $l_w1cwtr = w1cwtr
700aMC                   eval      $l_w1cwtr = cnvwgt
PCK AC                   call      @cwght
PCK AC                   parm                    $lparm
PCK AC                   parm      *zero         $batch            7 0
PCK AC                   parm      *blanks       $delvry           9
PCK AC                   parm      *blanks       $bildoc          10
PCK AC                   parm      *blanks       $disp             5
PCK AC                   endif

PCKcAC                   if        client = packers and
PCKcAC                             w3cost <> *zeros
PCKcAC                   eval      inwhse = $pwhse
PCKcAC                   eval      initem = $ititem
PCKcAC                   eval      indate = $sadate
PCKcAC                   eval      intime = $satime
PCKcAC                   eval      inby   = $puser
PCKcAC                   eval      inwhdp = $pwhdp
PCKcAC                   eval      indisp = $pdisp
PCKcAC                   eval      inudte = *zeros
PCKcAC                   eval      inutim = *zeros

PCKcA ***                select
PCKcA ***                when      w1um1 = 'CV'
     C                   eval      workcost = w1qt01 * w3cost

PCKcA ***                when      w1um1 = 'LB' and $itcwgt = 'N'
      ***                eval      workcost = w1qt01 * w3cost
PCKcA ***                endsl

PCKcAC                   eval      invad1_cost = w3cost
PCKcAC                   eval      invad1_extcst = workcost
PCKcAC                   eval      inmsc1 = invad1_base
PCKcAC                   eval      inmsc2 = *blanks
PCKcAC                   eval      inmsc3 = *blanks
PCKcAC                   eval      inmsc4 = *blanks
PCKcAC                   eval      inmsc5 = *blanks
PCKcAC                   write     inrec
PCKcAC                   endif

     *
520c C*    slkey         chain(n)  slot2                              79
520c C*                  if        not *in79   and
520cAC*                            slpick = 'Y'
520c C*                  eval      $dqty1 = slstk1
520c C*                  eval      $dqty2 = slstk2
520c C*                  eval      $dqty3 = slstk3
520cAC*                  call      @tlsdt
520cAC*                  parm      '*FIX '       $dcmd             8
520cAC*                  parm      #prog         $dpgm            10
520cAC*                  parm      ' '           $dpgm2           10
520cAC*                  parm      slwhse        $dwhse            3 0
520cAC*                  parm      slwhdp        $dwhdp            5
520cAC*                  parm      sldisp        $dslot           12
520cAC*                  parm      slitem        $ditem           15
520cAC*                  parm                    $dqty1            5 0
520cAC*                  parm                    $dqty2            5 0
520cAC*                  parm                    $dqty3            5 0
520cAC*                  parm                    $drtn             5 0
520cAC*                  eval      $uqty1 = $dqty1
520cAC*                  eval      $uqty2 = $dqty2
520cAC*                  eval      $uqty3 = $dqty3
520cAC*                  call      @sltdt
520cAC*                  parm      '*FIX '       $ucmd             8
520cAC*                  parm      #prog         $upgm            10
520cAC*                  parm      ' '           $upgm2           10
520cAC*                  parm      slwhse        $uwhse            3 0
520cAC*                  parm      slwhdp        $uwhdp            5
520cAC*                  parm      sldisp        $uslot           12
520cAC*                  parm      slpick        $upick            1
520cAC*                  parm      slitem        $uitem           15
520cAC*                  parm      ' '           $unewi           15
520cAC*                  parm      slentd        $uentd            8 0
520cAC*                  parm      slexpd        $uexpd            8 0
520cAC*                  parm                    $uqty1            5 0
520cAC*                  parm                    $uqty2            5 0
520cAC*                  parm                    $uqty3            5 0
520cAC*                  parm                    $urtn             5 0
520cAC*                  endif
     *
     C     endupd        endsr

600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------
600bA*                     DRI SUBROUTINES
600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------

600bA*----------------------------------------------------------------
600bA*  clr$item  Clear $item data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

640bA*----------------------------------------------------------------
640bA*  clr$license  Clear $license data structure fields
640bA*----------------------------------------------------------------
640bA
640bAC     clr$license   begsr
640bAC                   eval      savever# = $liver#
640bAC                   clear                   $license
640bAC                   eval      $liver# = savever#
640bAC                   eval      $liemp# = 0
640bAC                   eval      $liuser = #curruser
640bAC                   eval      $lipgm  = #pgm
640bAC                   eval      $lijob  = #job
640bAC                   eval      $lijobn = #jobnbr
640bAC                   eval      $liTowhse = $pwhse
640bAC                   eval      $liTowhseu = *on
640bAC                   endsr
640bA
640bA*----------------------------------------------------------------
640bA*  clr$licinfo  Clear $licinfo data structure fields
640bA*----------------------------------------------------------------
640bA
640bAC     clr$licinfo   begsr
640bAC                   eval      savever# = $lnver#
640bAC                   clear                   $licinfo
640bAC                   eval      $lnver# = savever#
640bA
640bAC                   eval      $lnuser = #user
640bAC                   eval      $lnpgm  = #prog
640bAC                   eval      $lnjob  = #job
640bAC                   eval      $lnjobnbr = #jobn
640bA
640bAC                   endsr
640b
600bA*----------------------------------------------------------------
600bA*  clr$slot  Clear $slot data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = #emp#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600bAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
416dAC                   eval      $dridata2 = $item2
640bAC                   when      $dricommand = '*LICENSE'
640bAC                   eval      $dridata = $license
640bAC                   eval      $dridata2 = $license2
640bAC                   when      $dricommand = '*LICINFO'
640bAC                   eval      $dridata = $licinfo
     C                   endsl

416dAC                   select

416dAC                   when      $dricommand = '*ITEM'
600bAC                             or $dricommand = '*SLOT'
640bAC                             or $dricommand = '*LICENSE'
416dAC                   call(e)   'DRICOP'
416dAC                   parm                    $dricommand
416dAC                   parm                    $drisubcmd
416dAC                   parm                    $drisys2upd
416dAC                   parm      #prog         $driprogram
416dAC                   parm      ' '           $drireturn
416dAC                   parm      ' '           $drimessage
416dAC                   parm                    $dridata
416dAC                   parm                    $dridata2
416dA
416dAC                   other
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
416dA
416dAC                   endsl

     C                   select

600bMC                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        zmsflag
     C                   exsr      zm0105s
     C                   else
     C                   exsr      zm0105
     C                   endif

700aA * this code was moved to after the $slot fields are populated
700aDC*                  when      chk4err and $drireturn <> '*OK'
700aDC*                  eval      error = *on
700aDC*                  if        zmsflag
700aDC*                  exsr      zm0001s
700aDC*                  else
700aDC*                  exsr      zm0001
700aDC*                  exsr      zzerrind
700aDC*                  endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600bAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
416dAC                   eval      $item2 = $dridata2
640bAC                   when      $dricommand = '*LICENSE'
640bAC                   eval      $license = $dridata
640bAC                   eval      $license2 = $dridata2
640bAC                   when      $dricommand = '*LICINFO'
640bAC                   eval      $licinfo = $dridata
     C                   endsl

700aAc                   select
700aAC                   when      chk4err and $drireturn <> '*OK'
700aAC                   eval      error = *on
700aAC                   if        zmsflag
700aAC                   exsr      zm0001s
700aAC                   else
700aAC                   exsr      zm0001
700aAC                   exsr      zzerrind
700aAC                   endif

700aAC                   endsl
     C                   eval      zmsflag = *off
600bAC                   eval      chk4err = *off
     C     enddricop     endsr

600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------
600aA*  License Plate Tracking Routines
600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*  ZZZCLR$LT210  -  Clear LT210 parameters.
600aA*----------------------------------------------------------------
600aA
600aAC     ZZZCLR$LT210  begsr

     C                   clear                   $tcmd
     C                   clear                   $tprogram
     C                   clear                   $ttype
     C                   clear                   $thead
     C                   clear                   $twhse
     C                   clear                   $titem
     C                   clear                   $titemdsc
     C                   clear                   $twhdp
     C                   clear                   $tslot
     C                   clear                   $tslotpos
     C                   clear                   $templ#
     C                   clear                   $ttran#
     C                   clear                   $tlic#
     C                   clear                   $tnewlic#
     C                   clear                   $tqty1
     C                   clear                   $tqty2
     C                   clear                   $tqty3
     C                   clear                   $tnorm1
     C                   clear                   $tnorm2
     C                   clear                   $tnorm3
     C                   clear                   $tpartial
     C                   clear                   $tpulled
     C                   clear                   $tinslot
     C                   clear                   $tsamepos
     C                   clear                   $tdiffpos
     C                   clear                   $tpsplit
     C                   clear                   $tinlic#
     C                   clear                   $toutlic#
     C                   clear                   $tnexttask
     C                   clear                   $treturn
     C                   clear                   $terrmsg
     C                   clear                   $tmsgid

     C                   endsr

600aA*----------------------------------------------------------------
600aA*  ZZZCALL$LT210  -  Call LT210 program.
600aA*----------------------------------------------------------------
600aA
600aAC     ZZZCALL$LT210 begsr

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'ADJ'         $ttype
     C                   parm      'Adjustment'  $thead
     C                   parm                    $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      #emp#         $templ#
     C                   parm                    $ttran#
     C                   parm                    $tlic#
     C                   parm                    $tnewlic#
     C                   parm                    $tqty1
     C                   parm                    $tqty2
     C                   parm                    $tqty3
     C                   parm                    $tnorm1
     C                   parm                    $tnorm2
     C                   parm                    $tnorm3
     C                   parm                    $tpartial
     C                   parm                    $tpulled
     C                   parm                    $tinslot
     C                   parm                    $tsamepos
     C                   parm                    $tdiffpos
     C                   parm                    $tpsplit
     C                   parm                    $tinlic#
     C                   parm                    $toutlic#
     C                   parm                    $tnexttask
     C                   parm                    $treturn
     C                   parm                    $terrmsg
     C                   parm                    $tmsgid

     C                   endsr

     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Slot
Adjustment Type
Catch weight
Dept of Item doesn't match Dept of Slot
Memo is a required field
Alias item
Adjustment Code
Adjust oldest product
**  CMDLN - Command display line 700a
F4=Prompt  F5=Refresh  F7=Kilogram  F9=Slot qty  F12=Cancel  F20=Accept Warning
F4=Prompt  F5=Refresh  F7=Pounds    F9=Slot qty  F12=Cancel  F20=Accept Warning
F4=Prompt  F5=Refresh  F9=Slot quantities  F12=Cancel F20=Accept Warning
