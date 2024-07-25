500aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  IT130     Item slot maintenance - Display
     *  07 September, 1994
     *  Hemant Kapadia
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    12/19/94  DAS
     *      - Revised PAG1FW/PAG1BK routines to write 8 records
     *        instead of 10.
     *
213 A*    05/20/96  DAS
     *      - Not turning on LR anymore.
     *
213 A*    05/23/96  RH
     *      - Change to call IT135 not IT132 for view.
     *
213 A*    05/29/96  RH
     *      - Change to call IT135 with @vewpg.
     *
     *    04/30/97  RH   2.20
     *      - Refresh screen to reset pointer if CANCEL or EXIT was
     *        used during F6 ADD.
     *
411 A*    06/19/99  HNK  4.11
     *      - Display base item slots for alias/contract items.
412 A*    09/16/99  RH   4.12
     *      - Display base item slots for same slot breakdown &
     *        breakdown items.
     *      - Option 2=Change not allowed for item type A or C.
     *      - Send item type to IT132 to allow entry for item type S.
412aA*    09/20/99  RH   4.12
     *      - Add option 12=Transfer to transfer product.
413 A*    11/24/99  DAS  4.13
     *      - Removed all 412 changes dealing with the display
     *        of the base item information.
     *      - Removed designation info from screen.
     *      - Move item information up 1 line on screen.
     *      - Changed label of item descriptions to variables.
     *      - Created ZZHEAD to create item display fields.
     *      - Added 3 tables.
     *      - Revised error message IT13001.
     *
413aA*    01/28/00  DAS  4.13a
     *      - Added option 7=Change Item.
     *
413bA*    02/28/00  DAS  4.13b
     *      - Revised F6=Create to only be allowed for type ' ',
     *        'B' and 'S' items.
     *
413cA*    03/30/00  HNK  4.13c
     *      - Revised to call IT352 instead of IT152.
414aA*    09/22/00  RH   4.14a
     *      - Added extended description using ITEMDSC file
     *      - Added DSPSFL1 subfile for extended descriptions.
     *
415 A*    04/24/01  DAS  4.15
     *      - Added non-displayed options V1 and V2.
     *      - Added non-display option V? to display an explanation
     *        of the 'V' options on the option line. Note: This option
     *        line is automatically set back to the original option
     *        line the next time the screen is displayed.
415aA*    06/12/01  MLB  4.15a
     *      - Revised routines ZZFGTN,ZZFGTP to not include virtual
     *        slots that are at "Z" status.
416aA*    10/17/01  RH   4.16a
     *      - Add W1PDSC pack description to screen 1.
     *
416bA*    03/05/02  DAS  4.16b
     *      - Revised CMD01/F6 to use #OITEM instead of #BITEM.
417aA*    08/11/04  RH   4.17a
     *      - Fix: Revised to call GETSLOTITM, if the item was an
     *        alias item for a SSB item, GETBASE would return the SSB
     *        item which is not a slot item.
     *
500 A*    03/24/05  DAS  5.00
     *      - Added non-displayed options LI and LS.
     *      - Added non-display option L? to display an explanation
     *        of the 'L' options on the option line. Note: This option
     *        line is automatically set back to the original option
     *        line the next time the screen is displayed.
     *
500aA*    03/29/05  DAS  5.00a
     *      - Converted to ILE.
     *      - Added slot display to list.
     *
510aA*    06/10/06  DAS  5.10a
     *      - Enh: Revised program to add support for Client id
     *      - Added option 8=Dates (only for certain clients)
     *
510bA*    11/09/06  JCJ  5.10b
     *      - Enh: Added call to CHKLIST.
     *
510cA*    02/28/07  TLJ  5.10c
     *      - Enh: For new item type Repack, call GETBASE to get
     *        parent info for heading.  Fix some heading problems.
     *
520aA*    04/10/08  JCJ  5.20a
     *      - Enh: Added option 8=Dates.
     *      - Modified slightly and marked with 600a.
     *
600 A*    04/25/08  DAS  6.00  P#00045
     *      - License Tracking
     *
600aA*    04/25/08  DAS  6.00a P#00045
     *      - Opened 8=Dates for everyone.
     *      - Similar to 520a change.
     *
600bA*    01/26/09  DAS  6.00b
     *      - Added license to list display.
     *      - Removed slot position from list display.
     *
600cA*    02/12/09  DAS  6.00c
     *      - Removed 8=Slot Pallet Maint because 1) 8=Dates was added
     *        and 2) it only allowed update of slot position which
     *        isn't implemented at this time.
     *
600dA*    02/23/09  DAS  6.00d
     *      - Revised call to SL810 to user $pwhdp instead of itwhdp.
     *
600eA*    02/26/09  DAS  6.00e
     *      - Added second option line for license tracking options.
     *      - Removed L* options.
     *
600fA*    03/07/09  DAS  6.00f
     *      - Revised to not allow transfer from RCV/STG/OSS slots
     *      - Revised to not allow change item from RCV/STG/OSS/USR slots
     *
600gA*    05/29/09  DAS  6.00g
     *      - Added V3=RCV/STG Transfer
     *
650a *    01/29/15  RTR  6.50a
     *      - Renamed IT130FM to IT13001
     *      - Fix: changed subfile from 8 to 7 lines to not hide More line.
650b *    02/22/15  RH/JCJ  6.50b
     *      - Fix: Fix authorization if statement, was allowing error
     *        to continue and execute opiton (opt 7 & 12)
650c *    02/25/15  LMC  6.50c
     *      - Fix: 650a caused records to be skipped from the subfile
     *        display, adjust counter from 8 to 7.
     *        Also found some of the counters were still set to 10
     *        which is the number of SFL records orgianlly used by
     *        the program, changed those to use the counter of 7
     *
700aA*    12/05/16  RH/DAS 7.00a
     *      - Enh: Allow option 7=Change item on OSS slots.
700bA*    10/19/15  DAS  7.00b
     *     - Enh: Added option '14=Chg Pick Slot
700cA*    12/05/16  RH/DAS 7.00c
     *      - Enh: Allow option 7=Change item on OSS slots.
700d *    06/12/15  GJA  7.00d
     *      - Fix: Was not displaying the SSB item correctly.
710a *    04/26/17  LMC  7.10a
     *      - Enh: RTNDOCK is now used for returns, treat with same
     *        edits as RCVDOCK is treated.
     *      - Fix: Error message when using option 14, was showing
     *        option 7 message.
720  *    09/23/18  KDE  7.20
     *      - Fix: Correct how quantity is shown when negative
     *        Breakdown.  Currently shows as -1. positive breakdown
     *        Should show as -0.5 if negative 5 breakdowns
720a *    01/02/19  KDE  7.20a
     *      - Fix: Zero qty2 when no breakdown 2
730  *    01/18/19  KDE  7.30
     *      - Fix: Force 1 on breakdowns when 0
730a *    09/24/19  LMC  7.30a
     *      - Enh: RWODOCK is now used for receipts with no PO.
     *        Treat with same edits as RCVDOCK is treated.
740a *    10/02/20  DAS  7.40a
     *      - Fix: Increase NEWQTY1/2 to 9.0 from 5.0.
     *        Large Normal qty blew up rollup routine.
     *----------------------------------------------------------------
     *  Client Custom Mods - Springfield
     *
SGCaA*   12/17/09  RH   SGCa
     *     - Add vendor item # to right of extended desc W1DSC2
     *----------------------------------------------------------------
     *  Client Custom Mods - VIP
     *
VIPaA*    06/10/06  DAS  VIPa
     *      - Added opition 8=Dates.
     *      - NEGATED with 600a change.
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - CDI
CDIaA*    04/22/09  RH   CDIa
     *      - Display 'Replacement' and replacement item in W1LBLB &
     *        W1BITM fields. (stored in IMBRND)
CDIbA*    01/31/13  RH   CDIb
     *     - Add user authorization check.
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - CLD
     *
CLDaA*   11/09/06  JCJ  CLDa
     *     - Add user authorization check.
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - Inter County Bakers
     *
ICBaA*   04/24/12  RH   ICBa
     *     - Add to authorization check.
     *----------------------------------------------------------------
GMMaA*   08/20/12  RH   GMMa  Graves Menu Maker
     *     - Add to authorization check.
     *----------------------------------------------------------------
     *  Client Custom Mods - Presto
     *
PFCa *   06/27/18  GJA  PFCa
     *     - Add to authorization check.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's Provision
     *
PCK A*    07/01/09  MLB  PCK
     *      - Revise program to validate options: 2=Change, 7=Chg item
     *        and 12=Transfer. Needed to add option security.
PCKaA*    01/28/15  MLB  PCKa
     *      - Correction to PCK mod. Chg to send opt# 12 for Transfers
     *        to authorization chk pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - Renzi
     *
RNZaA*   07/31/08  RH   RNZa
     *     - Add user authorization check.
     *----------------------------------------------------------------
     *  Client Custom Mods - Halsey Foodservice
     *
HALaA*   08/25/12  MLB  HALa
     *     - Add user authorization check per Tim S. skype 08/07/12.
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - Greenleaf Produce
GLPaA*   04/15/13  RH   GLPa
     *     - Add user authorization check
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - Hearn Kirkwood
     *
HKWaA*   01/17/13  RH   HKWa
     *     - Add user authorization check
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - Saval
     *
SVLaA*   01/31/14  RH   SVLa
     *     - Add user authorization check.
SVLbA*   04/07/14  RH   SVLb
     *     - Add user authorization check to option 7 and 12.
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - DRYa
     *
DRYaA*   02/16/11  RH   DRYa
     *     - Add user authorization check for option 2
DRYbA*   03/14/19  MLB  DRYb
     *     - Revised pgm to not allow adjustments to OSS slots.
     *       Per Melissa M email dated 02.25.2019.
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - Will Foods
     *
WILaA*   09/22/14  RH   WILa
     *     - Add user authorization check
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - Kohl Wholesale
     *
KHLaA*   08/11/14  LMC  KHLa
     *     - Add user authorization check
     *----------------------------------------------------------------
     *  Client Custom Mods - Sofo Foods
     *
SOFaA*   02/01/15  RH   SOFa
     *     - Add user authorization check
     *----------------------------------------------------------------
     *  Client Custom Mods - Fischer Foods
FFCaA*   09/28/15  RH   FFCa
     *     - Add user authorization check
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - European Imports
     *
EI  A*   01/28/15  MLB  EI   P#01308
     *     - Add user authorization check for F6 and 2=inventory adj.
     *     - Added EI to CLDa mod.
EIa A*   01/28/15  MLB  EIa  P#01308
     *     - Add user authorization check for 7=change item
     *     - Added EIa to PCK mod.
EIb A*   01/28/15  MLB  EIb  P#01308
     *     - Add user authorization check for 12=slot transfer.
     *     - Added EIa to PCK mod.
     *----------------------------------------------------------------
     * Client Custom Mods - Lieber's Kosher Foods
LKFaA*   11/15/19  RH   LKFa
     *     - Add user authorization check, F6, 2 adjust, 7 change item
     *----------------------------------------------------------------
     * Client Custom Mods - Holt Paper
HPCaA*   12/09/19  RH   HPCa
     *     - Add user authorization check, F6, 2 adjust, 7 change item
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - Cheney
     *
CBIaA*   09/03/15  JGD-CBIa
     *   - Add logic to allowe authorized users only to have
     *     access to options # 2 - 7 - 12 and F6 key.
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - Foods Galore
     *
FGL A*   10/26/21  MLB  FGL
     *     - Add user authorization check for options: F6, 2 and 7.
     *
     *----------------------------------------------------------------
     *  Client Custom Mods - Marques
     *
MQSaA*   06/25/18  xxx  MQSa
     *     - Add user authorization check for options: F6, 2 and 7.
     *----------------------------------------------------------------
     *  Client Custom Mods - Seashore
     *
SFPaA*   03/08/24  RH   SFPa
     *     - Add user authorization check for options: F6, 2 and 7.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position cursor
     *  21 - 29   Field input error (Reverse display)
     *  79        Chain indicator
     *  90        Protect input fields for delete display
     *  97        Always ON (Used for SFLEND keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
650aDF*it130fm   cf   e             workstn
650aMFit13001   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
     Fslot3     if   e           k disk
     F                                     rename(slrec:record)
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
     Fwhdept    if   e           k disk
413 D*ESIG   IF  E           K        DISK
     *
     Fslot2     if   e           k disk
     F                                     rename(slrec:recordu)
413 AFunmesr    if   e           k disk
414aAFitemdsc   if   e           k disk
CDIaAFitemmsc   if   e           k disk
414aAFoptions   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
413 AD a22             s              1    dim(22)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
415 D*                   OPTLN   1   1 75
500 D**                  OPTLN   1   2 75
510aD**optln           s             75    dim(3) ctdata perrcd(1)
600aDD*optln           s             75    dim(4) ctdata perrcd(1)
600gDD*optln           s             75    dim(3) ctdata perrcd(1)
600gMD optln           s             75    dim(4) ctdata perrcd(1)
     D cmdln           s             79    dim(1) ctdata perrcd(1)
413 AD desc            s             30    dim(2) ctdata perrcd(1)
CDIaMD lbl             s             22    dim(4) ctdata perrcd(1)
CDIaDD*lbl             s             22    dim(3) ctdata perrcd(1)
413 AD typ             s             10    dim(1) ctdata perrcd(1)

500aA*----------------------------------------------------------------
500aA*  DRI parameters
500aA*----------------------------------------------------------------
500aA
500aA /COPY *libl/qcopysrc,C#DRIPARMS

500aA*----------------------------------------------------------------
500aA*  Data Formats
500aA*----------------------------------------------------------------
500aA
500aA /COPY *libl/qcopysrc,C#SLOT
500aAD savever#        s                   like($slver#)

510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*----------------------------------------------------------------
510
510 A /copy qcopysrc,id#vip
CLD A /copy qcopysrc,id#citylin
CDI A /copy qcopysrc,id#cdi
PCK A /copy qcopysrc,id#packers
RNZ A /copy qcopysrc,id#renzi
SGC A /copy qcopysrc,id#sgc
ICB A /copy qcopysrc,id#icb
HALaA /copy qcopysrc,id#halsey
GLPaA /copy qcopysrc,id#glp
DRYaA /copy qcopysrc,id#dairyla
HKWaA /copy qcopysrc,id#hkw
SVLaA /copy qcopysrc,id#saval
GMMaA /copy qcopysrc,id#gmm
WILaA /copy qcopysrc,id#wil
KHLaA /copy qcopysrc,id#khl
PFCaA /copy qcopysrc,id#pfc
SOFaA /copy qcopysrc,id#sofo
FFCaA /COPY QCOPYSRC,ID#fischer
EI  A /copy qcopysrc,id#ei
LKFaA /COPY QCOPYSRC,ID#lkf
HPCaA /COPY QCOPYSRC,ID#hpc
CBIaA /copy qcopysrc,id#cheney
MQSaA /COPY QCOPYSRC,ID#mqs
FGL A /copy qcopysrc,id#fgl
SFPaA /copy qcopysrc,id#SFP

     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $whse                  1      3  0
     D  $item                  4     18
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  slwhse                 1      3  0 inz(0)
     D  slitem                 4     18
     D  slstat                19     20
     D  slpick                21     21
     D  slprty                22     22  0 inz(0)
     D  slexpd                23     30  0 inz(0)
     D  slentd                31     38  0 inz(0)
     D  slwhdp                39     43
     D  slstyp                44     44
     D  slaisl                45     47
     D  slpseq                48     52  0 inz(0)
     D  slrlvl                53     54  0 inz(0)
     D  slhand                55     56
     *
     D                 ds
     D  dsukey                 1     50
     D  ukwhse                 1      3  0 inz(0)
     D  ukwhdp                 4      8
     D  ukdisp                 9     20
     D  ukitem                21     35
600eAD  uklcns                36     50
     *----------------------------------------------------------------
414aA* Data structure
414aA*
414aAD opdata          ds
414aAD  opstyp                 1      1
414aAD  opwhdp                 2      6
414aAD  opum1                  7      8
414aAD  opdum                  9     23
414aAD  opcum                 24     43
414aAD  opcdiv                44     52  2
414aAD  opcaut                53     53
414aAD  opcwrn                54     54
414aAD  opcrng                55     57  1
414aAD  opwum                 58     72
414aAD  opxdsc                73     73
414aAD  optend               117    117
510bA*----------------------------------------------------------------
510bA* Error message(s)
510bAD err01           c                   const('You are not authorized -
510bAD                                     to use this option.')
     *----------------------------------------------------------------
     *  Called programs
     *
500aDD*@cvtdt          c                   const('CVTDTE')
500aDD*@getsi          c                   const('GETSLOTITM')
     D @chgpg          c                   const('IT132')
     D @vewpg          c                   const('IT135')
     D @delpg          c                   const('IT134')
500aMD @prtpg          c                   const('NONE')
510 AD @getcl          c                   const('GETCLIENT')
510bAD @autpg          c                   const('CHKLIST')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D                                     DIM(3)
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339
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
600eAD  $plcns                54     68
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0 inz(0)
     D  $cvd8o                39     46  0 inz(0)
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     *
413 AD  errit1                 1     15
413 AD  errtyp                16     16
413 AD  errit2                17     31
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
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
500aAD  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #bsu1           s              5
     D #bsu2           s              5
     D #bsu3           s              5
     D #msgid          s              7
     D #msgtp          s              7
     D #odesc          s             30
     D #oitem          s             15
     D #opdsc          s             15
     D #osu1           s              5
     D #osu2           s              5
     D #osu3           s              5
     D #otype          s              1
     D #oum1           s              2
     D #oum2           s              2
     D #oum3           s              2
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forceb          s              1
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
     D msgk            s              4  0
     D nomore          s              1
720 Ad Newqtyn         s              5  0
740aDd*Newqty1         s              5  0
740aAd Newqty1         s              9  0
740aDd*Newqty2         s              5  0
740aAd Newqty2         s              9  0
     D nxtscr          s              3
     D ocode           s              8
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D temp10          s             10
     D top             s              1
     D uxflag          s              1
     D warn            s              1
     D x               s              3  0
     D y               s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
     *
     *  Define keys
     *
     *     WORKOPT  (Unique key)
     *
     C     wkounq        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    wkokyf
     C                   kfld                    wkokyu
     *
     *     WORKOPT  (Partial key)
     *
     C     wkoprt        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     *
     *     WORKOPT  (Save key for top record on delete display)
     *
     C     deltop        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    $wkof
     C                   kfld                    $wkou
414aA*
414aA*     OPTIONS
414aA*
414aAC     opkey         klist
414aAC                   kfld                    $whse
414aAC                   kfld                    ocode
414aA*
414aA*     EXTENDED ITEM DESCRIPTION
414aA*
414aAC     idkey         klist
414aAC                   kfld                    $whse
414aAC                   kfld                    ititem
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
600aDC**                 if        client = VIP
600aDC**                 eval      optln1 = optln(4)
600aDC**                 else
415 AC                   eval      optln1 = optln(1)
600eAC                   eval      optln2 = optln(2)
600aDC**                 endif
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
500aAC                   exsr      zzzdriclose
213 D*                    SETON                     LR
213 AC                   return
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
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     C                   write     title
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      deldsp
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   read      dspsfc                                 50
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
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     clr0306
     C                   write     delrec
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   write     cmddel
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        begsr
     C                   eval      nxtscr = '01 '
     C                   eval      *in90 = *off
     C                   write     clr0306
     C                   if        cancel = *off
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = frstky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
     C                   endcs
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
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
     C                   write     dspsfl                               79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR F3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR F5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
650cDC*    1             do        10            x
650cMC     1             do        07            x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl
     C                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR F6 - ADD RECORD
     *
     C                   if        *inkf
CLDaAC                   if        client = cityline
HALaAC                             or client = halsey
CDIbAC                             or client = cdi
RNZaAC                             or client = renzi
HKWaAC                             or client = hkw
KHLaAC                             or client = kohl
SOFaAC                             or client = sofo
EI  AC                             or client = ei
MQSaAC                             or client = marques
LKFaAC                             or client = Liebers
HPCaAC                             or client = holtpaper
FFCaAC                             or client = fischerfoods
FGL AC                             or client = Foodsgalore
SFPaAC                             or client = seashore
CLDaAC                   call      @autpg
CLDaAC                   parm                    #prog
CLDaAC                   parm      'F6'          pgmopt           20
CLDaAC                   parm                    #user
CLDaAC                   parm                    $rtncd
CLDaAC                   if        $rtncd = '*NO'
CLDaAC                   eval      error = '1'
CLDaAC                   eval      errmsg = err01
CLDaAC                   exsr      ZM0105
CLDaAC                   goto      CMD01E
CLDaAC                   endif
CLDaAC                   endif
413bAC                   if        #otype = 'A'  or
413bAC                             #otype = 'C'
413bAC                   eval      error = *on
413bAC                   eval      *in21 = *on
413bAC                   eval      errmsg = *blanks
413bAC                   exsr      zm1302
413bAC                   else
     C                   eval      $pprg = #prog
     C                   eval      ukwhse = itwhse
     C                   eval      ukwhdp = itwhdp
     C                   eval      ukdisp = *blanks
413bD**                   MOVE ITITEM    UKITEM
416bD**                   MOVE #BITEM    UKITEM
416bMC                   eval      ukitem = #oitem
     C                   eval      $puky = dsukey
     C                   eval      $pcmd = '*ADD    '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     C                   if        $prtn <> '*EXIT   '  and
     C                             $prtn <> '*CANCEL '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
     C                   endif
220 AC                   eval      pagcmd = '*REFRESH'
220 AC                   exsr      pag01
     C                   goto      cmd01e
413bAC                   endif
     C                   endif
     *
     *  TEST FOR F10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
     C                   if        *inkj
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
650cDC*                  sub       10            row#
650cMC                   sub       07            row#
     C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       CMD01E
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      scr02e
     C                   goto      cmd02e
     C                   endif
     C     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
650aDC*                  if        recno < 11
650aMC                   if        recno < 7
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       DELADE
     *
     *  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     *
     C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
     C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   eval      option = wkoopt
     C                   write     dspsfl
     C                   endif
     C     delade        endsr
     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     C     deldsp        begsr
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     *R         OTAKEN    IFEQ '0'
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   END
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  Save first delete key.
     *
     C                   eval      frstky = $puky
     *
     *  Delete the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   if        wkoopt = ' 4'
     *
     *  Call delete program
     *
     C                   exsr      inzpar
     C                   eval      $pcmd = '*DELETE '
     C                   eval      $puky = wkokyu
     C                   call      @delpg
     C                   parm                    $parms
     *
     *     Error occured - Error message sent back
     *
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     *
     *     Delete canceled
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C                   endif
     C                   if        cancel = '0'
     C                   delete    wkorec
     C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   endif
     *
     C                   endif
     C                   enddo
     C                   exsr      scr02e
     C     ent02e        endsr
     *----------------------------------------------------------------
     *
     *  FGTWAY   Gateway to file handling routines
     *
     *    Input Parameters
     *      $POCMD   *INIT    - Initialize and return
     *               *GET     - Get record for $POUKY value
     *               *GETNEXT - Get next record
     *               *GETPREV - Get previous record
     *               *WRITPOS - Write position record to display
     *               *READPOS - Read position record
     *               *POSTN2  - Position to $POFKY
     *               *POSTN2U - Position to $POUKY
     *               *TOP     - Position to top of file
     *               *BOTTOM  - Position to bottom of file
     *      $POFKY   Key for positioning within file
     *      $POUKY   Unique key used for change/delete operations
     *
     *    Returned Parameters
     *      $PORTN   *NOMORE  - Beginning/End of file was reached
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took place
     *               *ERROR   - Error occured
     *      $POERM   Error message
     *
     C     fgtway        begsr
     C                   eval      $portn = *blanks
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
     C                   endcs
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are DIFFERENT.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   exsr      zzkeyi
     **                   MOVE *BLANKS   $POUKY
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     **                   MOVE *BLANKS   $POUKY
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     **                   MOVE *BLANKS   $POUKY
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dsfkey = $pofky
     C     fileky        setll     record
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
     C     fpos2u        begsr
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     C                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     C                   exsr      fpos2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     C     inzpar        begsr
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *     DO ALL DELETES FIRST (OPTION 4)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 4'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 4'
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
     C                   goto      optnse
     C                   endif
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = '0'
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = '1'
     C                   eval      stop = *on
     C                   if        error = '1'
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        refrsh = '1'
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     C                   select
     *
     *   Change
     *
     C                   when      wkoopt = ' 2'
PCK A*     Check if user is authorized to use this option.
CLDaAC                   if        client = cityline
DRYaAC                             or client = dairyland
ICBaAC                             or client = icb
GMMaAC                             or client = mnumkr
PCK AC                             or client = packer
HALaAC                             or client = halsey
CDIbAC                             or client = cdi
GLPaAC                             or client = greenleaf
CDIbAC                             or client = cdi
HKWaAC                             or client = hkw
WILaAC                             or client = willfoods
SVLaAC                             or client = saval
KHLaAC                             or client = kohl
PFCaAC                             or client = presto
FFCaAC                             or client = fischerfoods
EI  AC                             or client = ei
MQSaAC                             or client = marques
LKFaAC                             or client = Liebers
HPCaAC                             or client = holtpaper
CBIaAC                             or client = cheney
FGL AC                             or client = Foodsgalore
SFPaAC                             or client = seashore
CLDaAC                   call      @AUTPG
CLDaAC                   parm                    #prog
CLDaAC                   parm      '2'           pgmopt
CLDaAC                   parm                    #user
CLDaAC                   parm                    $rtncd
CLDaAC                   if        $rtncd = '*NO'
CLDaAC                   eval      error = '1'
CLDaAC                   eval      errmsg = err01
CLDaAC                   exsr      ZM0105
CLDaAC                   endif
CLDaAC                   endif
DRYbA *
DRYbA *     Verify user not adjusting OSS slot.
DRYbAC                   if           client = Dairyland
DRYbA *
DRYbAC                   if           %subst($pdisp:1:3) = 'OSS'
DRYbAC                   eval      error = '1'
DRYbAC                   eval      *in21 = '1'
DRYbAC                   eval      errmsg = 'Transfer to CW Slot, then adjust'
DRYbAC                                    + ' item.'
DRYbAC                   exsr      zm0105
DRYbAC                   endif
DRYbA *
DRYbAC                   endif
DRYbA *
510bAC                   if        error <> '1'
413 MC                   if        #otype = 'A'  or
413 MC                             #otype = 'C'
412 AC                   eval      error = *on
412 AC                   eval      *in21 = *on
412 AC                   eval      errmsg = *blanks
412 AC                   exsr      zm1301
412 AC                   else
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
412 AC                   endif
510bAC                   endif
     *
     *   View
     *
     C                   when      wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @vewpg
     C                   parm                    $parms
     *
     *   Print
     *
     C                   when      wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
413aA*
413aA*   Change item.
413aA*
413aAC                   when      wkoopt = ' 7'
600fAC                   if        %subst($pdisp:1:3) = 'RCV'
600fAC                             or %subst($pdisp:1:3) = 'STG'
700aDC**                           or %subst($pdisp:1:3) = 'OSS'
600fAC                             or %subst($pdisp:1:3) = 'USR'
710aAC                             or %subst($pdisp:1:3) = 'RTN'
730aAC                             or %subst($pdisp:1:3) = 'RWO'
600fAC                   eval      error = *on
600fAC                   eval      *in21 = *on
600fAC                   eval      errmsg = 'Option 7 not allow for '
600fAC                                    + %subst($pdisp:1:3) + ' slot'
600fAC                   exsr      zm0105
600fAC                   else
PCK A*     Check if user is authorized to use this option.
PCK AC                   if        client = packer
WILaAC                             or client = willfoods
SVLbAC                             or client = saval
EIa AC                             or client = ei
LKFaAC                             or client = Liebers
HPCaAC                             or client = holtpaper
CBIaAC                             or client = cheney
FGL AC                             or client = Foodsgalore
SFPaAC                             or client = seashore
PCK AC                   call      @AUTPG
PCK AC                   parm                    #prog
PCK AC                   parm      '7'           pgmopt
PCK AC                   parm                    #user
PCK AC                   parm                    $rtncd
PCK AC                   if        $rtncd = '*NO'
PCK AC                   eval      error = '1'
PCK AC                   eval      errmsg = err01
PCK AC                   exsr      ZM0105
PCK AC                   endif
PCK AC                   endif
650bAC                   if        error <> '1'
413aAC                   eval      $pcmd = '*CHANGE '
413aAC                   call      'SL252'
413aAC                   parm                    $parms
413aAC                   if        $prtn = '*OK     '
413aAC                   eval      #msgk = $pmsg
413aAC                   exsr      zmqmsg
413aAC                   endif
650bAC                   endif
600fAC                   endif
510aA*
510aA*   Dates
510aA*
510aAC                   when      wkoopt = ' 8'
600aDC**                 if        client = VIP
510aAC                   call      'SL430'
510aAC                   parm                    $puky
510aAC                   parm                    $prtn
600aDC**                 endif
     *
     *   View slot quantities.
     *
     C                   when      wkoopt = ' 9'
     C                   call      'SL810'
     C                   parm                    itwhse
600dDC**                 parm                    itwhdp
600dMC                   parm                    $pwhdp
     C                   parm                    $pdisp
412aA*
412aA*   Transfer product.
412aA*
412aAC                   when      wkoopt = '12'
600fAC                   if        %subst($pdisp:1:3) = 'RCV'
600fAC                             or %subst($pdisp:1:3) = 'STG'
600fAC                             or %subst($pdisp:1:3) = 'OSS'
710aAC                             or %subst($pdisp:1:3) = 'RTN'
730aAC                             or %subst($pdisp:1:3) = 'RWO'
600fAC                   eval      error = *on
600fAC                   eval      *in21 = *on
600fAC                   eval      errmsg = 'Option 12 not allow for '
600fAC                                    + %subst($pdisp:1:3) + ' slot'
600fAC                   exsr      zm0105
600fAC                   else
PCK A*     Check if user is authorized to use this option.
PCK AC                   if        client = packer
WILaAC                             or client = willfoods
SVLbAC                             or client = saval
EIb AC                             or client = ei
CBIaAC                             or client = cheney
PCK AC                   call      @AUTPG
PCK AC                   parm                    #prog
PCKaDC*                  parm      '7'           pgmopt
PCKaMC                   parm      '12'          pgmopt
PCK AC                   parm                    #user
PCK AC                   parm                    $rtncd
PCK AC                   if        $rtncd = '*NO'
PCK AC                   eval      error = '1'
PCK AC                   eval      errmsg = err01
PCK AC                   exsr      ZM0105
PCK AC                   endif
PCK AC                   endif
650bAC                   if        error <> '1'
412 AC                   eval      $pcmd = '*CHANGE '
413cAC                   call      'IT352'
412aAC                   parm                    $parms
650bAC                   endif
600fAC                   endif
     *
     C                   other
     C                   exsr      zzopt
     C                   endsl
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $prtn = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
     C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   eval      bot = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag01e        endsr
     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     C     pag02         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   eval      bot = *off
     C                   exsr      pag2fw
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 8 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfwd
     C                   endif
     *
     *  RECORD READ - STOP AFTER 8 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     **         P         IFGE 10
650cDC*                  if        p >= 8
650cMC                   if        p >= 7
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfwd        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     **         DSPLYD    ADD  10        GOBACK  20
650cDC*    dsplyd        add       8             goback
650cMC     dsplyd        add       7             goback
     C                   if        bot = '1'
     **         GOBACK    IFEQ 10
650cDC*                  if        goback = 8
650cMC                   if        goback = 7
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf2
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw2
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
650cDC*                  if        p >= 10
650cMC                   if        p >= 07
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C                   endif
     C     endfw2        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf2         endsr
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     C     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb2
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
650cDC*    dsplyd        add       10            goback
650cMC     dsplyd        add       07            goback
     C                   if        bot = '1'
     C     wkoprt        setgt     workopt
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = '1'
     C     wkoprt        readpe    workopt                                79
     *
     *  HIT TOP OF FILE
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk2
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk2        tag
     C                   enddo
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C     wkoprt        setll     workopt
     C                   endif
     C                   exsr      pag2fw
     C     endb2         endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
     C                   readc     dspsfl                                 79
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     C                   endif
     *
     *  SAVE OPTION
     *
     C                   z-add     recno         y
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
650aDC*                  if        recno < 11
650aMC                   if        recno < 7
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   write     dspsfl
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in01 = *off
     C                   write     dspsfc
     C                   eval      recno = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C     1             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
650cDC*    1             do        10            x
650cMC     1             do        07            x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
     C                   update    dspsfl
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
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
     C                   parm      #prog         #pgmq
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
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

500aA*----------------------------------------------------------------
500aA*    DRI0001  Local system caused error
500aA*----------------------------------------------------------------
500aA
500aAC     zm0001        begsr
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

500aA*----------------------------------------------------------------
500aA*    DRI0001s Local system caused error (send to different program)
500aA*----------------------------------------------------------------
500aA
500aAC     zm0001s       begsr
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
     *      0101  Program not found.
     *----------------------------------------------------------------

     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   eval      #msgid = 'PIR0104'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR0105 Generic Error
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

500aA*----------------------------------------------------------------
500aA*    PIR0105s Generic error (send to different program)
500aA*----------------------------------------------------------------
500aA
500aAC     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*PGMQ'
     C                   endsr
     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
412 A*----------------------------------------------------------------
412 A*      1301  Can't adjust item type.
412 A*
412 AC     zm1301        begsr
412 AC                   eval      #msgid = 'IT13001'
412 AC                   eval      #msgtp = '*DIAG  '
413 AC                   eval      errmsg = *blanks
413 AC                   eval      errit1 = #oitem
413 AC                   eval      errtyp = #otype
417aD**                   MOVE #BITEM    ERRIT2
417aAC                   eval      errit2 = #sitem
413 D**                   MOVEL#OTYPE    ERRMSG
412 AC                   movea     errmsg        $md(1)
412 AC                   exsr      zmpmsg
412 AC                   endsr
413bA*----------------------------------------------------------------
413bA*      1302  F6=Create not allowed for item.
413bA*
413bAC     zm1302        begsr
413bAC                   eval      #msgid = 'IT13002'
413bAC                   eval      #msgtp = '*DIAG  '
413bAC                   eval      errmsg = *blanks
413bAC                   eval      errit1 = #oitem
413bAC                   eval      errtyp = #otype
417aAC                   eval      errit2 = #sitem
417aD**                   MOVE #BITEM    ERRIT2
413bD**                   MOVEL#OTYPE    ERRMSG
412bAC                   movea     errmsg        $md(1)
412bAC                   exsr      zmpmsg
412bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     *R         FILUKY    CHAINRECORD               79
     *
     *    Code to use when file key and unique key are different.
     *
     C     filuky        chain     recordu                            79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
413 AC                   if        #otype = ' '  or
413 AC                             #otype = 'B'
     C     partky        reade     record                                 79
413 AC                   else
     C     partkb        reade     record                                 79
413 AC                   endif
     C     *in79         cabeq     *on           endgtn
     C                   if        slstat = 'Z '  and
415aD*R         SLRSRV    ANDEQ'N'
     C                             slrsrv <> 'Y'
     C                   goto      try1
     C                   endif

500aAC                   exsr      clr$slot
500aAC                   eval      $slwhseu = *on
500aAC                   eval      $slwhse  = slwhse
500aAC                   eval      $slwhdpu = *on
500aAC                   eval      $slwhdp  = slwhdp
500aAC                   eval      $sldispu = *on
500aAC                   eval      $sldisp  = sldisp
500aA
500aAC                   eval      $dricommand = '*SLOT'
500aAC                   eval      $drisubcmd  = '%GET'
500aAC                   eval      $drisys2upd = 'D'
500aAC                   exsr      zzzdricop
500aAC                   if        error = *on
500aAC                   eval      error = *off
600bMC                   eval      $saToPos = 0
500aAC                   endif
     *
     C     endgtn        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        begsr
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
413 AC                   if        #otype = ' '  or
413 AC                             #otype = 'B'
     C     partky        readpe    record                                 79
413 AC                   else
413 AC     partkb        readpe    record                                 79
413 AC                   endif
     C     *in79         cabeq     *on           endgtp
     C                   if        slstat = 'Z '  and
415aD*R         SLRSRV    ANDEQ'N'
     C                             slrsrv <> 'Y'
     C                   goto      try2
     C                   endif

500aAC                   exsr      clr$slot
500aAC                   eval      $slwhseu = *on
500aAC                   eval      $slwhse  = slwhse
500aAC                   eval      $slwhdpu = *on
500aAC                   eval      $slwhdp  = slwhdp
500aAC                   eval      $sldispu = *on
500aAC                   eval      $sldisp  = sldisp
500aA
500aAC                   eval      $dricommand = '*SLOT'
500aAC                   eval      $drisubcmd  = '%GET'
500aAC                   eval      $drisys2upd = 'D'
500aAC                   exsr      zzzdricop
500aAC                   if        error = *on
500aAC                   eval      error = *off
600bAC                   eval      $saToPos = 0
500aAC                   endif
     *
     C     endgtp        endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     *   Change priority from negative to positive.
     *
     C                   eval      w1prty = -(slprty)
500aA*
500aA*   Slot position
500aA*
600bDC**                 eval      w1slp = $saToPos
     *
     *   Expiration date
     *
     C                   if        slexpd = 0
     C                   eval      w1expd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      slexpd        $cvd8i
500aAC                   call      'CVTDTE'
500aDC**                 call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1expd = $cvd6o
     C                   endif
     *
     *   Entered date
     *
     C                   if        slentd = 0
     C                   eval      w1entd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      slentd        $cvd8i
500aAC                   call      'CVTDTE'
500aDC**                 call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1entd = $cvd6o
     C                   endif
     *
     *    Create a quantity string to print.
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
     *
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
     C                   eval      $pqstr = *blanks
     *
720 A*   Add code to rollup breakdowns properly
720 A /free
730 D      //if $pqty2<>0 or $pqty3<>0;
730 A      if ($pqty2<>0 and itumq2<>0) or ($pqty3<>0 and itumq3<>0);
720 A        select;
720 A         when $pqty3 <> 0;
720A    //First, take to lowest level quantity based on breakdowns
720 A            newqty2 = (($pqty1 * itumq2 * itumq3) +
720 A                       ($pqty2 * itumq3) +
720 A                        $pqty3);
720 A            newqty1=*zeros;
720 A            newqtyn=*zeros;
720 A         when $pqty2 <> 0;
720 A            newqty1 = (($pqty1 * itumq2) +
720 A                        $pqty2);
720 A            newqtyn=*zeros;
720aA            newqty2=*zeros;
720 A        endsl;
720A   //Next, roll back up with breakdown structure
720 A        exsr zzupQty;
720 A        $pqty1 = newqtyn;
720 A        $pqty2 = newqty1;
720 A        $pqty3 = newqty2;
720 A      endif;
720 A /end-free
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
600bA
600bA*   License
600bA
600bAC                   if        %len(%trim($saToLcns)) <= 14
600bAC                   eval      w1Lcns = $saToLcns
600bAC                   else
600bAC                   eval      w1Lcns = %subst($saToLcns:1:12) + '..'
600bAC                   endif
     *
     *   Adjusted date
     *
     *R         SLADJD    IFEQ 0
     *R                   Z-ADD0         W1ADJD
     *R                   ELSE
     *R                   MOVE '*CMDMDY '$CVCMD
     *R                   MOVE IQADJD    $CVD8I
     *R                   CALL @CVTDT
     *R                   PARM           $CVTDT
     *R                   Z-ADD$CVD6O    W1ADJD
     *R                   END
     *
     *   User
     *
     *R                   MOVELIQADJB    W1ADJB
     *
     C                   endsr
     *----------------------------------------------------------------
     *
413 A*  ZZHEAD   Create item headings
     *
     C     zzhead        begsr
     *
     *   Initialize headings
     *
     C                   eval      w1lbl = *blanks
414aAC                   eval      w1dsc2 = *blanks
     C                   eval      w1item = *blanks
     C                   eval      w1lblb = *blanks
     C                   eval      w1bitm = *blanks
416a C                   eval      w1pdsc = *blanks
     *
     *   Get selected item info.
     *
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   clear                   ittype
     C                   clear                   itdesc
     C                   clear                   itpdsc
     C                   clear                   itum1
     C                   clear                   itum2
     C                   clear                   itum3
     C                   eval      ititem = $pitem
     C                   eval      itdesc = desc(2)
     C     '-'           cat       itdesc:1      itdesc
     C     $item         cat       itdesc:1      itdesc
     C                   goto      endhed
     C                   endif
     *
     *  Save information about selected item (Item that was sent in)
     *
     C                   eval      #otype = ittype
     C                   eval      #oitem = ititem
     C                   eval      #odesc = itdesc
     C                   eval      #opdsc = itpdsc
     C                   eval      #oum1 = itum1
     C                   eval      #oum2 = itum2
     C                   eval      #oum3 = itum3
     *
     *   Get short UOM descriptions for selected item.
     *
     C                   eval      #osu1 = *blanks
     C                   eval      #osu2 = *blanks
     C                   eval      #osu3 = *blanks
     *
     C                   if        itum1 <> *blanks
     C     itum1         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #osu1 = umshrt
     C                   else
     C                   movel     itum1         #osu1
     C                   endif
     C                   endif
     *
     C                   if        itum2 <> *blanks
     C     itum2         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #osu2 = umshrt
     C                   else
     C                   movel     itum2         #osu2
     C                   endif
     C                   endif
     *
     C                   if        itum3 <> *blanks
     C     itum3         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #osu3 = umshrt
     C                   else
     C                   movel     itum3         #osu3
     C                   endif
     C                   endif
     *
     *   Initialize base information.
     *
     C                   eval      #bitem = ititem
417aAC                   eval      #sitem = ititem
     C                   eval      #bityp = ittype
     C                   eval      #bdesc = itdesc
     C                   eval      #bpdsc = itpdsc
     C                   eval      #bum1 = itum1
     C                   eval      #bum2 = itum2
     C                   eval      #bum3 = itum3
     C                   eval      #bsu1 = #osu1
     C                   eval      #bsu2 = #osu2
     C                   eval      #bsu3 = #osu3
     *
     *  If select item is a Base item  . . .
     *    Then try to get a corresponding SSB item.
     *
     C                   if        ittype = ' '
     C                   call      'GETSSB'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
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
     C                   if        #brtn = '*FOUND  '
     C                   eval      #bityp = 'S'
     C                   endif
     C                   endif
     *
     *  If selected item is a Contract, Alias, SSB or Breakdown item . . .
     *    Then get corresponding Base item.
     *
     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'  or
     C                             ittype = 'B'  or
510cAC                             ittype = 'R'
     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse
     C                   parm      ititem        $gitem
     C                   parm      ' '           #bitem
     C                   parm                    #bityp            1
     C                   parm                    #bdesc
     C                   parm                    #bpdsc
     C                   parm                    #bwhdp
     C                   parm                    #bstyp
     C                   parm                    #bum1             2
     C                   parm                    #bum2
     C                   parm                    #bumq2
     C                   parm                    #bum3
     C                   parm                    #bumq3
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum1            2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn
     C                   endif
417aA*   Get slot item.
500aDC**                 call      @getsi
500aMC                   call      'GETSLOTITM'
417aAC                   parm      itwhse        $gwhse
417aAC                   parm      ititem        $gitem
417aAC                   parm      ' '           #sitem           15
417aAC                   parm                    #sityp            1
417aAC                   parm                    #sdesc           30
417aAC                   parm                    #spdsc           15
417aAC                   parm                    #srtn            10
417aAC                   parm                    #smsg            60
     *
     *   Get short UOM descriptions for base item.
     *
     C                   if        #bum1 <> #oum1
     C     #bum1         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #bsu1 = umshrt
     C                   else
     C                   movel     #bum1         #bsu1
     C                   endif
     C                   endif
     *
     C                   if        #bum2 <> #oum2
     C     #bum2         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #bsu2 = umshrt
     C                   else
     C                   movel     #bum2         #bsu2
     C                   endif
     C                   endif
     *
     C                   if        #bum3 <> #oum2
     C     #bum3         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #bsu3 = umshrt
     C                   else
     C                   movel     #bum3         #bsu3
     C                   endif
     C                   endif
     *
     *   Create label for selected item
     *
     *     If selected item is a SSB item . . .
     *        Then display the breakdown 1 UOM.
     *        Otherwise use the normal UOM.
     *
     *     Note: Except for the description, the SSB fields
     *           should be identical to its Base item's fields.
     *
     C                   movea     lbl(1)        a22
     C                   if        #otype = 'S'
     C                   movea     #osu2         a22(16)
     C                   else
     C                   movea     #osu1         a22(16)
     C                   endif
     C                   movea     a22           w1lbl
     C     w1lbl         cat       ')':0         w1lbl
     C                   move      ':'           w1lbl
     *
     *   Create description for selected item
     *
     C                   movea     typ(1)        a10
     C                   movea     #otype        a10(8)
     C                   movea     a10           temp10
     *
     C     #oitem        cat       temp10:1      w1item
     C     w1item        cat       '-':1         w1item
     C     w1item        cat       #odesc:1      w1item
     *   Display pack description for selected item.
416a C                   eval      w1pdsc = #opdsc
     *
     *   Create label and description for corresponding item.
     *
     C                   select
     *
     *     If selected item is a Base item . . .
     *        Then display its corresponding SSB item (if any)
     *        Otherwise display nothing.
     *
     C                   when      #otype = ' '
     C                   if        #bityp = 'S'
     C                   movea     lbl(3)        a22
     C                   movea     #bsu2         a22(11)
     C                   movea     a22           w1lblb
     C     w1lblb        cat       ')':0         w1lblb
     C                   move      ':'           w1lblb
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
417aD**         #BITEM    CAT  TEMP10:1  W1BITM
700dAC                   if        #bitem <> *blanks
700dAC     #bitem        cat       temp10:1      w1bitm
700dAC                   else
417aMC     #sitem        cat       temp10:1      w1bitm
700dAC                   endif
     C     w1bitm        cat       '-':1         w1bitm
     C     w1bitm        cat       #bdesc:1      w1bitm
     C                   endif
     *
     *     If selected item is a Breakdown item . . .
     *        Then display its corresponding Base item.
     *             Note: UOM is not applicable in this situation.
     *
     C                   when      #otype = 'B'
510cAC                   if        #bityp = ' '
510cAC                   movea     lbl(2)        a22
510cAC                   movea     'N/A'         a22(12)
510cAC                   movea     a22           w1lblb
510cAC     w1lblb        cat       ')':0         w1lblb
510cAC                   move      ':'           w1lblb
     *
510cAC                   movea     typ(1)        a10
510cAC                   movea     #bityp        a10(8)
510cAC                   movea     a10           temp10
     *
510cAC     #bitem        cat       temp10:1      w1bitm
510cAC     w1bitm        cat       '-':1         w1bitm
510cAC     w1bitm        cat       #bdesc:1      w1bitm
510cAC                   else
     C                   movea     lbl(2)        a22
     C                   movea     'N/A'         a22(12)
     C                   movea     a22           w1lblb
     C     w1lblb        cat       ')':0         w1lblb
     C                   move      ':'           w1lblb
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
417aD**         #BITEM    CAT  TEMP10:1  W1BITM
417aMC     #sitem        cat       temp10:1      w1bitm
     C     w1bitm        cat       '-':1         w1bitm
     C     w1bitm        cat       #bdesc:1      w1bitm
510cAC                   endif
510cA*
510cA*     If selected item is a Repack item    . . .
510cA*        Then display its corresponding Base item.
510cA*
510cAC                   when      #otype = 'R'
510cAC                   movea     lbl(2)        a22
510cAC                   movea     #bsu1         a22(12)
510cAC                   movea     a22           w1lblb
510cAC     w1lblb        cat       ')':0         w1lblb
510cAC                   move      ':'           w1lblb
510cA*
510cAC                   movea     typ(1)        a10
510cAC                   movea     #bityp        a10(8)
510cAC                   movea     a10           temp10
510cA*
510cAC     #bitem        cat       temp10:1      w1bitm
510cAC     w1bitm        cat       '-':1         w1bitm
510cAC     w1bitm        cat       #bdesc:1      w1bitm
510cAC*
     *     Otherwise . . .
     *        Then display its corresponding Base item w/UOM.
     *             Note: UOM of Base should match UOM of selected item.
     *
     C                   other
     C                   movea     lbl(2)        a22
     C                   movea     #bsu1         a22(12)
     C                   movea     a22           w1lblb
     C     w1lblb        cat       ')':0         w1lblb
     C                   move      ':'           w1lblb
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
417aD*R         #BITEM    CAT  TEMP10:1  W1BITM
417aMC     #sitem        cat       temp10:1      w1bitm
     C     w1bitm        cat       '-':1         w1bitm
     C     w1bitm        cat       #bdesc:1      w1bitm
     *
     C                   endsl
     *
414aAC                   exsr      zzxopt
     *
414aAC     idkey         chain     itemdsc                            79
414aAC                   if        *in79
414aAC                   eval      ixdsc1 = *blanks
414aAC                   eval      ixdsc2 = *blanks
414aAC                   endif
414aAC                   if        uxflag = '1'
414aAC                   eval      w1dsc2 = ixdsc2
414aAC                   endif
SGCaAC                   if        client = sgc
SGCaAC                   move      itvit#        w1dsc2
SGCaAC                   endif
CDIaA *
CDIaAC                   if        client = CDI
CDIaAC     idkey         chain     itemmsc                            79
CDIaAC                   if        *in79
CDIaAC                   eval      imbrnd = *blanks
CDIaAC                   endif
CDIaAC                   movea     lbl(4)        a22
CDIaAC                   movea     a22           w1lblb
CDIaAC                   move      ':'           w1lblb
      *
CDIaAC                   movel     imbrnd        w1bitm
CDIaAC                   endif
     C     endhed        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
510 A*
510 A*  Get client id.
510 A*
510 AC                   call      @getcl
510 AC                   parm                    client           10
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    ukwhse
     C                   kfld                    ukwhdp
     C                   kfld                    ukdisp
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
     C                   kfld                    slstat
     C                   kfld                    slpick
     C                   kfld                    slprty
     C                   kfld                    slexpd
     C                   kfld                    slentd
     C                   kfld                    slwhdp
     C                   kfld                    slstyp
     C                   kfld                    slaisl
     C                   kfld                    slpseq
     C                   kfld                    slrlvl
     C                   kfld                    slhand
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $whse
     C                   kfld                    $item
     *
413 A*  Define partial key for main file (if needed) using Base item.
     *
     C     partkb        klist
     C                   kfld                    $whse
417aD**                   KFLD           #BITEM
417aMC                   kfld                    #sitem
     *
411 M*  Define key for item file. (Base item)
     *
     C     itkey         klist
     C                   kfld                    $whse
     C                   kfld                    $item
     *
     *  Define key for warehouse department.
     *
     C     wdkey         klist
     C                   kfld                    $whse
     C                   kfld                    itwhdp
     *
     *  Setup option and command display lines.
     *
600aDC**                 if        client = VIP
600aDC**                 eval      optln1 = optln(4)
600aDC**                 else
     C                   eval      optln1 = optln(1)
600eAC                   eval      optln2 = optln(2)
600aDC**                 endif
     C                   eval      cmdln1 = cmdln(1)
     *
     C                   eval      $pprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initailization for each time program is called.
     *
     C     zzinz2        begsr
     *
413 AC                   exsr      zzhead
     *
     C                   eval      wowhse = *blanks
     C     $whse         chain     warehs                             79
     C                   if        not *in79
213 AC                   eval      $cstr = *blanks
     C                   move      whcode        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         wowhse
     C     wowhse        cat       '-':1         wowhse
     C     wowhse        cat       whdesc:1      wowhse
     C                   endif
     *
     C     wdkey         chain     whdept                             79
     C                   if        *in79
     C                   eval      wdcode = *blanks
     C                   eval      wddesc = *blanks
     C                   endif
     *
413 D*R         ITDESG    CHAINDESIG                79
413 D*R         *IN79     IFEQ *ON
413 D*R                   MOVE *BLANKS   DSCODE
413 D*R                   MOVE *BLANKS   DSDESC
413 D*R                   ENDIF
     *
     **                   MOVE $PRTKY    DSKEY
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYI   Initialize keys for files being used.
     *           Note: You must clear individual field when using
     *                 partial keys or one of the fields is numeric.
     *
     C     zzkeyi        begsr
     *
     *   Initialize file key (DSFKEY)
     *
     C                   clear                   slwhse
     C                   clear                   slitem
     C                   clear                   slstat
     C                   clear                   slpick
     C                   clear                   slprty
     C                   clear                   slexpd
     C                   clear                   slentd
     C                   clear                   slwhdp
     C                   clear                   slstyp
     C                   clear                   slaisl
     C                   clear                   slpseq
     C                   clear                   slrlvl
     C                   clear                   slhand
     *
     *   Initialize unique key (DSUKEY)
     *
     C                   clear                   ukwhdp
     C                   clear                   ukdisp
     C                   clear                   ukitem
600eAC                   clear                   uklcns
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      ukwhse = slwhse
     C                   eval      ukwhdp = slwhdp
     C                   eval      ukdisp = sldisp
     C                   eval      ukitem = slitem
600eAC                   eval      uklcns = $saToLcns
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     *
415 AC                   select
600cD **
600cD **  8 - Slot pallet maintenance
600cD **
600cDC**                 when      wkoopt = ' 8'
600cDC**                 eval      $pcmd = '*CHANGE '
600cDC**                 call      'LT130'
600cDC**                 parm                    $puky
600cDC**                 parm                    $prtn
700bA*
700bA*   14   Change Pick Slot
700bA*
700bAC                   when      wkoopt = '14'
     C                   if        %subst($pdisp:1:3) = 'RCV'
     C                             or %subst($pdisp:1:3) = 'STG'
     C                             or %subst($pdisp:1:3) = 'OSS'
     C                             or %subst($pdisp:1:3) = 'USR'
710aAC                             or %subst($pdisp:1:3) = 'RTN'
730aAC                             or %subst($pdisp:1:3) = 'RWO'
     C                   eval      error = *on
     C                   eval      *in21 = *on
710adC*                  eval      errmsg = 'Option 7 not allow for '
710aDC*                                   + %subst($pdisp:1:3) + ' slot'
710aMC                   eval      errmsg = 'Option 14 not allow for '
710aMC                                    + %subst($pdisp:1:3) + ' slot'
     C                   exsr      zm0105
     C                   leavesr
     C                   endif

     C                   eval      $pcmd = '*CHANGE '
     C                   call      'SL282'
     C                   parm                    $parms
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
415 A*
415 A*   V? - Display option line for 'V' options
415 A*
415 AC                   when      wkoopt = 'V?'
600eMC                   eval      optln1 = optln(3)
600gMC                   eval      optln2 = optln(4)
415 A*
415 A*   V1 - Edit slot record
415 A*
415 AC                   when      wkoopt = 'V1'
     C                   call      'SL830'
     C                   parm      '?'           $scmd             8
     C                   parm      $pwhse        $swhse            3 0
     C                   parm                    $pwhdp
     C                   parm                    $pdisp
415 A*
415 A*   V2 - Display open label records for slot.
415 A*
415 AC                   when      wkoopt = 'V2'
     C                   call      'LB841CL'
     C                   parm      '?'           $scmd
     C                   parm      $pwhse        $swhse
     C                   parm                    $pwhdp
     C                   parm                    $pdisp
600gA*
600gA*   V3 - RCV/STG transfer
600gA*
600gAC                   when      wkoopt = 'V3'
     C                   eval      $pcmd = '*CHANGEX'
     C                   call      'IT352'
     C                   parm                    $parms
600eA*
600eA*   70 - View active licenses
600eA*
600eAC                   when      wkoopt = '70'
     C                   call      'LT310'
     C                   parm      '*VIEW'       $scmd             8
     C                   parm      $pwhse        $swhse
     C                   parm      $pwhdp        $swhdp
     C                   parm      $pdisp        $sdisp           12
     C                   parm      ' '           $sitem           15
     C                   parm      ' '           $sdev            10
     C                   parm      ' '           $sform           10
600eA*
600eA*   71 - View license history
600eA*
600eAC                   when      wkoopt = '71'
     C                   if        $plcns = '*NONE'
     C                             or $plcns = '*MULTIPLE'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = 'Option 71 not allow for '
     C                                    + %trim($plcns) + ' license'
     C                   exsr      zm0105
     C                   else
     C                   call      'LT320'
     C                   parm      '*VIEW'       $scmd             8
     C                   parm      $pwhse        $swhse
     C                   parm      ' '           $swhdp
     C                   parm      ' '           $sdisp           12
     C                   parm      ' '           $sitem           15
     C                   parm      $plcns        $slcns           15
     C                   parm      0             $semp#            5 0
     C                   parm      ' '           $sdev            10
     C                   parm      ' '           $sform           10
     C                   endif
600eA*
600eA*   72 - View item history
600eA*
600eAC                   when      wkoopt = '72'
     C                   call      'LT320'
     C                   parm      '*VIEW'       $scmd             8
     C                   parm      $pwhse        $swhse
     C                   parm      ' '           $swhdp            5
     C                   parm      ' '           $sdisp           12
     C                   parm      $pitem        $sitem           15
     C                   parm      ' '           $slcns           15
     C                   parm      0             $semp#            5 0
     C                   parm      ' '           $sdev            10
     C                   parm      ' '           $sform           10
600eA*
600eA*   73 - View slot history
600eA*
600eAC                   when      wkoopt = '73'
     C                   call      'LT320'
     C                   parm      '*VIEW'       $scmd             8
     C                   parm      $pwhse        $swhse
     C                   parm      $pwhdp        $pwhdp
     C                   parm      $pdisp        $sdisp           12
     C                   parm      ' '           $sitem           15
     C                   parm      ' '           $slcns           15
     C                   parm      0             $semp#            5 0
     C                   parm      ' '           $sdev            10
     C                   parm      ' '           $sform           10
600eA*
600eA*   75 - View license information
600eA*
600eAC                   when      wkoopt = '75'
     C                   if        $plcns = '*NONE'
     C                             or $plcns = '*MULTIPLE'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = 'Option 75 not allow for '
     C                                    + %trim($plcns) + ' license'
     C                   exsr      zm0105
     C                   else
     C                   call      'LP130'
     C                   parm      '*NOOPT'      $scmd             8
     C                   parm      $plcns        $slcns           15
     C                   endif
     *
500 AC                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to a certain spot
     *
     *R         PTINP1    IFNE 0
     *R                   Z-ADDPTINP1    ODDLIN
     *R                   Z-ADD0         PTINP1
     *R                   MOVE *ON       REPOS
     *R                   END
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *R         $POCMD    IFEQ '*TOP'
     *R         *LOVAL    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         *HIVAL    SETLLRECORD
     *R                   END
     *R                   END
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        $pocmd = '*TOP'
413 AC                   if        #otype = ' '  or
413 AC                             #otype = 'B'
     C     partky        setll     record
413 AC                   else
413 AC     partkb        setll     record
413 AC                   endif
     C                   else
     C                   if        $pocmd = '*BOTTOM'
413 AC                   if        #otype = ' '  or
413 AC                             #otype = 'B'
     C     partky        setgt     record
413 AC                   else
413 AC     partkb        setgt     record
413 AC                   endif
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
414aA*  ZZXOPT   Get use extended description option
     *
414aAC     zzxopt        begsr
     *
414aA*   Get extended description option.
414aA***                  Z-ADD10        PRCREC  20
414aAC                   eval      uxflag = *off
414aAC                   eval      ocode = '*ITEMMNT'
     *
414aAC     opkey         chain     options                            79
414aAC                   if        not *in79
414aAC                   if        opxdsc = 'Y'
414aAC                   eval      uxflag = *on
414aA***                  Z-ADD5         PRCREC
414aAC                   endif
414aAC                   endif
     *
414aAC                   endsr

720 A *----------------------------------------------------------------
720 A *  ZZUPQTY       Up quantity
720 A *----------------------------------------------------------------
720 A
720 AC     zzupqty       begsr
720 A
720 A /free
720 A       // check for negative quantities
720 A       *in49=*off;
720 A       if newqtyn<0;
720 A          *in49=*on;
720 A          newqtyn = %abs(newqtyn);
720 A       endif;
720 A       if newqty1<0;
720 A          *in49=*on;
720 A          newqty1 = %abs(newqty1);
720 A       endif;
720 A       if newqty2<0;
720 A          *in49=*on;
720 A          newqty2 = %abs(newqty2);
720 A       endif;
720 A /end-free
720 A
720 AC                   dow       itumq3 > 0 and +
720 AC                               newqty2 >= itumq3
720 AC                   eval      newqty2 -= itumq3
720 AC                   eval      newqty1 += 1
720 AC                   enddo
720 A
720 AC                   dow       itumq2 > 0 and +
720 AC                               newqty1 >= itumq2
720 AC                   eval      newqty1 -= itumq2
720 Ac                   eval      newqtyn += 1
720 AC                   enddo
720 A
720 A /free
720 A                    if *in49;
720 A                       newqtyn = newqtyn * -1;
720 A                       newqty1 = newqty1 * -1;
720 A                       newqty2 = newqty2 * -1;
720 A                    endif;
720 A /end-free
720 A
720 AC                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600bAC                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdriclose   Close any open files or programs.
     *----------------------------------------------------------------

     C     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

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
     C                   endsl

500 AC                   if        $dricommand = '*ITEM'
600bAC                             or $dricommand = '*SLOT'
500 AC                   call(e)   'DRICOP'
500 AC                   parm                    $dricommand
500 AC                   parm                    $drisubcmd
500 AC                   parm                    $drisys2upd
500 AC                   parm      #pgm          $driprogram
500 AC                   parm      ' '           $drireturn
500 AC                   parm      ' '           $drimessage
500 AC                   parm                    $dridata
500 AC                   parm                    $dridata2
500 AC                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
500 AC                   endif

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C*                  eval      errmsg    = 'Error occured on call to '
     C*                                      + 'DRICOP'
     C*                                      + '/' + %trim($drisubcmd)
     C*                                      + ' from ' + #pgm
     C*                  if        zmsflag
     C*                  exsr      zm0105s
     C*                  else
     C*                  exsr      zm0105
     C*                  endif

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C*                  if        zmsflag
     C*                  exsr      zm0001s
     C*                  else
     C*                  exsr      zm0001
     C*                  exsr      zzerrind
     C*                  endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600bAC                   eval      $slot2 = $dridata2
     C                   endsl

     C*                  eval      zmsflag = *off
     C     enddricop     endsr

     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 2 5 7 9127071727375V?V1V2V314
**  OPTLN - Option display line
  2=Change  5=View  7=Change Item  9=View Qtys 12=Transfer 14=Chg Pck Slt
  70=Licenses  71=Lcns hist  72=Item hist  73=Slot hist  75=Lcns info
  V1=Edit slot record  V2=View open label records for slot
  V3=RCV/STG transfer
**  CMDLN - Command display line
F3=Exit  F5=Refresh  F6=Create  F12=Cancel
**
* * INVALID WAREHOUSE * *
* * INVALID ITEM * *
**
Selected item (
Base item (
SSB item (
Replacement           CDIa
**
(Type ' ')
