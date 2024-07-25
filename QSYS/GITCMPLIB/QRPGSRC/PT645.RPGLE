640bA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT645   Route transaction - Close & export
     *  04 September 1997
     *  Dave Sommerville
     *
     *  NOTE:
     *      If you change this program, check PT640 for same changes.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
411 A*    03/08/99   DAS  4.11
     *      - Added parameters $PCPGM and $MSGID.
     *      - Added file OPTIONS.
     *      - Added data structure for *FTP options
     *      - Revised ZZINZ routine to get *FTP options.
     *      - Revised ZZSTAT routine to call RH255CL if OPFTP='Y'.
     *        Othewise, the original program will be called, RH251.
     *
412 A*    08/23/99  DAS  4.12
     *      - Add option 3 to enter catch weights.
     *
414 A*    09/14/00  DAS  4.14
     *      - Revised display file to use ind 21 with SFLNXTCHG
     *        instead of ind 85 as stated in this program. The
     *        actual indicator used in the program was never changed
     *        from 21 to 85.
     *      - Only had to recompile the program.
     *
414aA*    09/14/00  DAS  4.14a
     *      - Added F7=Verify Cwgt.
     *
416 A*    10/29/01  HNK  4.16
     *      - Add call to CALPCKRTE prog to update picked qty, wt and
     *        cube in RTESUM file.
     *
416aA*    05/09/02  DAS  416
     *      - Special revison for Quality.
     *      - Revised ZZSTAT routine to try and check in data area
     *        EXPORD. If unsuccessful, error is sent back to user.
     *      - Revised ZZSTAT routine to check out data area EXPORD.
     *      - Added table EM.
     *      - Added routine ZMS105.
417 A*    09/23/03  HNK  4.17
     *      - Add zone description for each transaction.
417bA*    02/04/03  DAS  4.17b   (RH 12-04-03)
     *      - ENH:Can't close if transaction is a multiple scan trans
     *      - Found CLSALL was in PT640 as 4.13 change and missing
     *        from PT645.  Did not change PT645 at this time.
417cA*    12/17/03  RH   4.17c
     *      - Fix: Allow change for trans that is a multiple scan tran
     *             Reverse some of 417b changes.
417dA*    02/04/04  DAS  4.17d   (01/15/04 HNK change in PT640)
     *      - Can not close if transaction has label recs marked with
     *        'F' (Flags) in LBVRFY.
     *      - Display 'F' if there are any flags (shorts) for trans
417eA*    02/04/04  DAS  4.17e
     *      - Revised loop in ZZFLAG to leave at eof.
417fA*    05/25/04  MLB  4.17f
     *      - ENH: Revised 4.17d mod to not allow pick trans to close
     *        if LBVRFY = 'F' or 'I'. If LBVRFY is 'I', this means
     *        inventory control has to try and find item. This gives
     *        3 chances to try and find missing product before outing
     *        or shorting item.
417gA*    10/04/04  RH   4.17g
     *      - FIX: Add F7=Verify Cwgt to cmd line, F7 added in V4.14
     *
500 A*    12/01/04  MLB  5.00
     *      - Fix: Revised ZZFILL to movel the transaction type into
     *        the type field. Text was being truncated.
500cA*    11/30/05  MLB  5.00c
     *      - Enh: Revised program to load transaction, employee
     *        number onto View 2.
     *
510 A*    06/21/06  MLB  5.10
     *      - Fix: Revised program to not allow Close processing
     *        to proceed if PTSTAT is greater than '4'.
     *
510aA*    07/20/06  JCJ  5.10a
     *      - Enh: Add Verify Cwgt. to F16 processing.
510bA*    07/26/06  MLB  5.10b
     *      - Enh: Add client custom code support.
510cA*    07/28/06  MLB  5.10c
     *      - Fix: Changed ZZPOS to populate fields for correct positioning.
     *
520 A*    04/30/08  MLB  5.20
     *      - Fix: Revised routine ZZSTAT to check status to route to
     *        ensure route is still at 4=Printed status. If route is
     *        no longer at 4=Printed status, exit without doing anything
     *        further. This change is being made to prevent a will-call
     *        route from being exported more than once when the Inuse
     *        flag is cleared for a will-call route and someone is still
     *        in the route.
     *
520aA*    08/27/09  RBD  5.20a
     *      - Fix:  Added call to OR633 to update ORDP, unique piece
     *        number file.
     *
520bA*    11/11/09  RBD  5.20b
     *      - Fix:  Parm $kwhse in call to OR633 causes dec data
     *        error, will move it to $brwhs and send it instead.
     *
530 A*    11/30/09  JCJ  5.30
     *      - Moved POSTNREC/OPTREC into DSPSFC.
     *      - Removed READ/WRITE for POSTNREC/OPTREC.
     *      - Re: Webfacing could not handle double read.
     *
530 A*    11/30/09  JCJ  5.30
     *      - Enh: Add file Truckh to retrieve Truck Template
     *
530bA*    05/19/10  JCJ  5.30b
     *      - Enh: F16 - restore logic that calls @DELPG with *VRFYCW
     *             by removing client custom code that skips @DELPG.
530cA*    06/15/10  MLB  5.30c
     *      - Fix: Revised 5.30 mod above to omit Merge label records
     *             from the catchwgt checks.
     *
610a *    04/27/10  GJA  6.10a     P#00243
     *      - Enh: Changed UCI to be option driven.  OPUCI
     *
610b *    05/11/10  GJA  6.10b     P#00243
     *      - Fix: Changed UCI option position.
     *
610cA*    06/21/10  JCJ  6.10c
     *      - Fix: In ZZCW skip any ORDC record with a weight of 0.
     *
610dA*    06/30/10  JCJ  6.10d
     *      - Fix: Revised 5.30 mod above to omit label records with
     *             LBQPCK = 0 from the catchwgt checks.
     *
640aA*    03/02/11  DAS  6.40a
     *      - Add option ET to export transaction to staging files.
     *
640cA*    05/14/12  JCJ  6.40c
     *      - added catch weight processing from F16 to option 9.
     *
640fA*    03/06/11  DAS  6.40f
     *      - Revised to call staging export when FTP option is 'S'.
     *
640gA*    11/27/12  JCJ  6.40g
     *      - Changed mod marks 6.40a to 6.40f.
     *
650aA*    03/20/13  JCJ  6.50a
     *      - Fix: Revised 5.30 mod above to omit Adjustment label
     *             records from the catchwgt checks.
650bA*    08/16/13  DAS  6.50b
     *      - Fix: Do not allow option 2 or 9 to change and close or close
     *        a transaction already closed.
710aA*    03/17/17  DAS  7.10a
     *      - Enh: Added call to PT640AC to check if any transactions
     *        should be auto closed. Originally created for Cheney.
     *
730 A*    07/01/19  MLB  7.30
     *      - Fix: Revised pgm to use PT64002 instead PT64001.
730aA*    10/03/19  LMC  7.30a
     *      - Treat OPFTP = 'R' same as OPFTP = 'S'.
     *        R=Real time staging export.
760 A*    03/07/22  KDE  7.50
     *      - Enh: Add ELS Goal data once all transactions completed
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney
     *
CBIaA*    10/29/03  RH   CBIa
     *      - Call OR663CL to print Drivers pallet detail report.
     *
CBIBA*    10/31/03  HNK  CBIB - TEMPORARY
     *      - HARD CODE PRINTER DEV TO LP10
CBIcA*    11/04/03  RH   CBIc
     *      - Get printer DEV from REPORTS file. Replace CBIB
CBIeA*    11/14/03  HNK  CBIe
     *      - Do not print OR663 for Meat Insp and Pre Pick truck.
CBIfA*    03/04/04  HNK  CBIf
     *      - Do not print OR663 for CONTAINER truck code.
CBIgA*    10/05/04  RH   CBIg
     *      - Do not print any reports if truck code is "WILL-CALL"
     *        "SUD-SVC" or "DAMAGES" per 9-28-04 email.
CBIh *    11/19/04  HNK  CBIh
     *      - Call OR670CL to print Route summary report.
CBIjA*    03/03/11  DAS  CBIj (was CBIa in our 650 version)
     *      - Revised to call RH155S with *HDRDTL because at CBI
     *        transactions are exported when they are closed. Therefore
     *        for this export we only want to export the header and
     *        detail files to indicate the route is finished.
CBIkA*    10/02/17  JGD CBIk  (was mod 700)
     *      - Added logic to process new option
     *        (Opt# 10 - View Tran Info)
CBIlA*    10/02/17  NLK CBIl
     *      - Came from PT640 zzcw routine
     *    04/29/20  NLK
     *      - REV: cheney said RIV box only (added locations)
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Harbor
     *
HAR A*    07/26/06  MLB  HAR
     *      - Revised program to seton ind 35 to position cursor on
     *        transaction number.
     *
HARaA*    08/16/06  MLB  JCJ
     *      - Revised program to save position to field for use with
     *        cursor position logic.
     *
HARbA*    04/17/08  RBD  HARb
     *      - Added call to XM155 to create XML/POD export IFS files
     *        when user selects ' 1=export transactions '.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packers
PAKbA*    07/23/07  PAKb RH
     *      - Enh: Add option 65 to call CK365PCL for one transaction
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Dairyland
     *
DRYbA*  01/16/14  MLB  DRYb
     *    - Revised program to call RH155SCL for select warehouses.
     *      order will be exported to JDEdwards.
DRYdA*  05/16/14  MLB  DRYd
     *    - Revised DRYb mod. Revised pgm to set $PCMD = *ALL to cause
     *      RH155SCL to be submitted to QS36EVOKE. Per Kelly R. phone
     *      call 05/16/14.
DRYeA*  11/02/20  MLB  DRYe
     *    - Revised pgm to not change status of Route header to6.
     *      This will be done in RH155S.
     *      PT645 was setting status to 6 and RH155S had 7.00b mod
     *      added that was looking for will-call to be 4 and it wasn't
     *      exporting route to Host and not updating RTEHED, ORDH.
     *
     *----------------------------------------------------------------
     *  Custom Client Revisions:  iSupply
     *
ISPaA*    04/18/12  RTR  ISPa
     *      - Enh: Add call to customer willcall invoice program
ISPcA*    02/27/15  MLB  ISPc
     *      - Enh: Revised pgm to pass warehouse number to OR400CLISP.
     *        Needed to support new Kalamazoo whse.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program uses to display subfiles to show more than one
     *    view of the record. To see what was changed search for VW2
     *    starting in column 1.
     *
     *    Allowed F17 and F18 for positioning to top and bottom.
     *
     *    Created a second line for commands.
     *
     *    CMD5 changed to chain and update each view seperately.
     *
     *    RECNO used for all subfiles, SFLRCDNBR not used in format member.
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    This is not a normall 110a type program.  Instead of option
     *    4 we are using option 9 with a command of *CLOSE. Also
     *    field $PTYPE was added to $PARMS.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position Cursor
     *  21 - 29   Field Input Error (Reverse Display)
HAR A*  35        Position cursor to transaction#
     *  79        Chain Indicator
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
414 D** 85        Manually set subfile change flag (SFLNXTCHG)
414 M*  21        Manually set subfile change flag (SFLNXTCHG)
     *  90        Protect Input Fields for Delete Display
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
530 A **pt640fm   cf   e             workstn
530 AFpt64002   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(vw3sfl:recno)
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
     Fpirtran4  if   e           k disk
     F                                     rename(ptrec:record)
     Fpirtran   if   e           k disk
     F                                     rename(ptrec:recordu)
     Frtehed    uf   e           k disk
610aAFoptions   if   e           k disk
417 AFpltsum4   if   e           k disk
417 AFzoneh     if   e           k disk
CBIc Freports   if   e           k disk
417bAFmultran1  if   e           k disk
417dAFLabel90   if   e           k disk
530 AFtruckh    if   e           k disk
ISPaAFordh3     if   e           k disk
530bAFlabel7    if   e           k disk
620cMFordc1     if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
CBIkDD*optln           s             75    dim(1) ctdata perrcd(1)
CBIkMD optln           s             75    dim(2) ctdata perrcd(1)
     D cmdln           s             79    dim(6) ctdata perrcd(1)
     D tcod            s              6    dim(10) ctdata perrcd(1)
     D tdsc            s             30    dim(10) alt(tcod)
520 D*                   EM      1   1 50
520 MD em              s             50    dim(2) ctdata perrcd(1)
EFCbMD emsg            s             79    dim(6) ctdata perrcd(1)
510bA*----------------------------------------------------------------
510bA*  Customer id
510bA*
     D @getcl          c                   const('GETCLIENT')
510bA*
HAR A /copy qcopysrc,id#harbor
PAK a /copy qcopysrc,id#packers
CBIaa /copy qcopysrc,id#cheney
DRYbA /COPY QCOPYSRC,ID#DAIRYLA
CBIla /copy qcopysrc,id#cheneyr
CBIla /copy qcopysrc,id#cheneyg
ISPaA /copy qcopysrc,id#isupply
     *----------------------------------------------------------------
PAKaAD                 ds
     D  $ord                   1      7p 0
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $krte                  4      8
     D  $krtid                 9     13
     D  $ktruk                14     23
     D  $kstat                24     24
     D  $ktype                25     25
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     *                                       1  50 DSUKEY
     D  ptwhse                 1      3  0 inz(0)
     D  ptgrp1                 4      4
     D  ptgrp2                 5      5
     D  ptrtpo                 6     14
     D  pttrn#                15     21  0 inz(0)
     D                 ds
     D  dsukey                 1     50
     D  ukwhse                 1      3  0 inz(0)
     D  ukrte                  4      8
     D  ukpo                   9     17
     D  uktrn#                18     24  0 inz(0)
411 A*----------------------------------------------------------------
411 A*  *FTP      -  FTP options
411 A*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFTP   -  Use FTP for exporting (Y,N)
     *    OPSRVR  -  FTP Server name
     *    OPUSER  -  FTP User id
     *    OPPWD   -  FTP Password
     *
     * Data structure
     *
     D opdta1          ds
     D  opftp                  1      1
     D  opsrvr                 2     33
     D  opuser                34     48
     D  oppwd                 49     63
     D  optend               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('PT132')
     D @delpg          c                   const('PT132')
     D @prtpg          c                   const('NONE')
     D @pckrt          c                   const('CALPCKRTE')
404 A*----------------------------------------------------------------
404 A* Status message(s)
     D sts01           c                   const('Open')
     D sts02           c                   const('Started(Active)')
     D sts03           c                   const('Ended')
     D sts04           c                   const('Closed')
     D sts08           c                   const('Interrupted')
     D sts09           c                   const('Cancelled')
     *----------------------------------------------------------------
CBIe * Constants
     D @meat           c                   const('MEAT-INSP ')
     D @ppick          c                   const('PRE-PICK  ')
     D @cntnr          c                   const('CONTAINER ')
     D @wlcll          c                   const('WILL-CALL')
     D @sdsvc          c                   const('SUD-SVC')
     D @dmges          c                   const('DAMAGES')
     D @addon          c                   const('ADD-ONS')
     D @brekr          c                   const('BREAKERS')
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
     D  $ptype                81     88
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
     *  Other data structures
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *
CBIlAD ohmisc          ds
CBIlAD  dssdte                 1      8
CBIlAD  dsspcl                 9     11
CBIlAD  dsrpck                12     12
CBIlAD  dxdoor                13     14
CBIlAD  dsmeat                15     15
CBIlAD  dscode                16     16
CBIlAD  dsppck                17     17
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     D                 ds
     D  $ec                    1      2p 0
610cAD                 ds
610cAD  wrkmsg                 1     21
610cAD  ertrn#                 1      7
610cAD  slash                  8      8
610cAD  eritem                 9     23
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
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
610aA*----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *    OPISHS  -  Extended history weeks.
     *    OPUCI   -  Use UCI processing (Y,N)
     *
     * Data structure
     *
     D opdata          ds
610bMD  opuci                 36     36
     D  optend1              117    117
     *----------------------------------------------------------------
     * work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
CBIhAD $whsea          s              3
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D close           s              1
     D clsall          s              1
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
     D kygrp1          s                   like(ptgrp1)
     D kygrp2          s                   like(ptgrp2)
     D kyrtpo          s                   like(ptrtpo)
     D kytrn#          s                   like(pttrn#)
     D kywhse          s                   like(ptwhse)
     D lsttrn          s              7  0
     D maxvw           s              1  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D posrec          s              4  0
     D reccnt          s              4  0
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D svinp1          s              7  0
     D t               s              2  0
     D tmpflg          s              1
     D top             s              1
     D v               s              2  0
     D view            s              1  0
     D warn            s              1
CBIcAD wkprtf          s             10
     D wkcode          s                   like(opcode)
     D wkwhse          s                   like(opwhse)
     D w1zdsc          s             15
     D x               s              3  0
     D y               s              3  0
530 AD $ktmpl          s             10
530bAD cwflg           s              1
530bAD cwitm           s              1
CBIhAD $rsdt           s              1    inz('N')
760 Ad stdWhse         s              3p 0
760 Ad stdTrn#         s              7p 0
760 Ad stdGoal         s             13p 2
     *----------------------------------------------------------------
     * Constants
     *----------------------------------------------------------------
ISPaAD editw11         c                   '0           '
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
411 A*      $PCPGM  Calling program name
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
411 A*              *PGMQ    - Error occured. Message sent to Pgmq
411 A*      $MSGID  Message ID for *PGMQ
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
411 AC                   parm                    $pcpgm           10
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
411 AC                   parm                    $msgid            4
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
     *
ISPaAC     keyoh         klist
ISPaAC                   kfld                    $kwhse
ISPaAC                   kfld                    $krtid
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcode
     *
CBIc C     rpkey         klist
CBIc C                   kfld                    wkprtf
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
400 AC                   exsr      zzstat
     C                   exsr      zsclr
     C                   exsr      clrsch
     C                   seton                                        lr
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
530 D ***                read      postnrec                               50
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
     C                   select
     C                   when      view = 1
     C                   read      dspsfc                                 50
     C                   when      view = 2
     C                   read      vw2sfc                                 50
     C                   when      view = 3
     C                   read      vw3sfc                                 50
     C                   endsl
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
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = frstky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
     C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
     C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
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
510bA*
510bA* Get client id.
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
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
     C                   write     dspsfl                               79
     C                   write     vw2sfl                               79
     C                   write     vw3sfl                               79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     *
610aAC                   eval      wkcode = '*SYSTEM '
610aAC                   eval      wkwhse = 0
610aAC     opkey         chain     options                            79
610aAC                   if        *in79
610aAC                   eval      opuci = 'N'
610aAC                   endif
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
     *  TEST FOR CMD3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        10            x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl
     C                   endif
     C     x             chain     vw2sfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    vw2sfl
     C                   endif
     C     x             chain     vw3sfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    vw3sfl
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
     *  TEST FOR CMD6 - ADD RECORD
     *
     C                   if        *inkf
     C                   exsr      inzpar
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
     C                   if        $prtn <> '*CANCEL '  and
     C                             $prtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD20 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
     C                   if        *inku
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       10            row#
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
     *  TEST FOR CMD10 - Previous view
     *
     C                   if        *inkj
     C                   if        view = 1
     C                   eval      view = maxvw
     C                   else
     C                   eval      view = view - 1
     C                   endif
     C                   eval      v = view * 2
     C                   eval      cmdln2 = cmdln(v)
     C                   eval      v = v - 1
     C                   eval      cmdln1 = cmdln(v)
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD11 - Next view
     *
     C                   if        *inkk
     C                   if        view = maxvw
     C                   eval      view = 1
     C                   else
     C                   add       1             view
     C                   endif
     C                   eval      v = view * 2
     C                   eval      cmdln2 = cmdln(v)
     C                   eval      v = v - 1
     C                   eval      cmdln1 = cmdln(v)
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
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
     C                   if        recno < 11
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
     C                   write     vw2sfl
     C                   write     vw3sfl
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
     C                   eval      *in81 = *on
     C                   eval      recno = 1
     C                   select
     C                   when      view = 1
     C                   write     dspsfc
     C                   when      view = 2
     C                   write     vw2sfc
     C                   when      view = 3
     C                   write     vw3sfc
     C                   endsl
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
     C                   if        wkoopt = ' 9'
640cA*
640cA* Check to see if all catch weights records have been entered.
640cA*
640cAC                   eval      dsukey = wkokyu
640cAC                   exsr      zzchkCW
640cAC                   if        error = '1'
640cAC                   leave
640cAC                   endif
     *  Check for Multi Trans
417b C                   eval      dsukey = wkokyu
417b C                   exsr      zzmult
417b C                   if        error = '1'
417b C                   exsr      zm6401
417b C                   goto      end02
417b C                   endif
     *  Check for Flags (shorts)
417d C                   eval      dsukey = wkokyu
417d C                   exsr      zzflag
417d C                   if        error = '1'
417d C                   exsr      zm6403
417d C                   goto      end02
417d C                   endif
     *
     *  Call delete program
     *
     C                   exsr      inzpar
     C                   eval      $pcmd = '*CLOSE  '
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
     C                   else
     *
     *     Delete was successful.
     *
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
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
417b C     end02         tag
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
     *              file are the same.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
213 AC                   exsr      zzkeyi
213 D*                    MOVE *BLANKS   $POUKY
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
213 AC                   exsr      zzkeyi
213 D*                    MOVE *BLANKS   $POUKY
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
213 AC                   exsr      zzkeyi
213 D*                    MOVE *BLANKS   $POUKY
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
     C                   eval      $ptype = '*INTER  '
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *     Do all quick closes first (option 9)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 9'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 9'
640cA*
640cA* Check to see if all catch weights records have been entered.
640cA*
640cAC                   eval      dsukey = wkokyu
640cAC                   exsr      zzchkCW
640cAC                   if        error = '1'
640cAC                   goto      optnse
640cAC                   endif
530bMC                   eval      dsukey = wkokyu
530bAC                   eval      ptwhse = ukwhse
530bAC                   eval      pttrn# = uktrn#
530bMC                   exsr      zzcw
530bMC                   if        cwflg = *off  and
530bMC                             cwitm = *on
530bAC                   movel     emsg(2)       errmsg
610cMC                   move      eritem        errmsg
530bAC                   eval      error = *on
530bAC                   exsr      zm0105
530bMC                   goto      optnse
530bMC                   endif
417b C                   eval      dsukey = wkokyu
417b C                   exsr      zzmult
417b C                   if        error = '1'
417b C                   exsr      zm6401
417b C                   goto      optnse
417b C                   endif
     *  Check for Flags (shorts)
417d C                   eval      dsukey = wkokyu
417d C                   exsr      zzflag
417d C                   if        error = '1'
417d C                   exsr      zm6403
417d C                   goto      optnse
417d C                   endif
     *
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
     *   Change
     *
     C                   if        wkoopt = ' 2'
417cD*R                   MOVE WKOKYU    DSUKEY
417cD*R                   EXSR ZZMULT
417cD*R         ERROR     IFEQ '1'
417cD*R                   EXSR ZM6401
417cD*R                   GOTO ENDOP2
417cD*R                   ENDIF
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   View
     *
     C                   if        wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   Print
     *
     C                   if        wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
     C                   else
CBIkA*
CBIkA*   View Transaction Info.
CBIkA*
CBIkAC                   if        wkoopt ='10' and
CBIkAC                             client = cheney
CBIkAC                   move      '*NOOPT  '    $pcmd
CBIkAC                   z-add     pttrn#        $trn#             7 0
CBIkAC                   call      'LP130B'
CBIkAC                   parm                    $pcmd
CBIkAC                   parm                    $trn#
CBIkAC                   else
CBIkA *
PAK aC                   if        wkoopt = '16'  and
610aAC                             opuci = 'Y'
PAK AC                   eval      $ord = hord
PAK aC                   call      'CE190'
PAK aC                   parm                    lbord
PAK aC                   parm      *zeros        hseq              5 0
PAK aC                   parm                    hitem
PAK aC                   parm                    htrn#
PAK aC                   parm                    portn             8
PAK aC                   if        portn = '*NOGOOD '
PAK aC                   eval      cancel = *on
PAK aC                   eval      error = *on
PAK aC                   movel     emsg(1)       errmsg
PAK aC                   exsr      zm0105
PAK aC                   endif
     C                   else
PAKb *   CK365P Report
     *
PAKb C                   if        wkoopt = '65'  and
PAKb C                             client = packer
PAKb C                   move      pttrn#        $ptrn#
PAKb C                   eval      $prtid = $krtid
PAKb C                   move      $kwhse        $pwhse
PAKb C                   call      'CK365PCL'
PAKb C                   parm                    $pwhse            3
PAKb C                   parm                    $prtid            5
PAKb C                   parm      '*JOB'        $pdev            10
PAKb C                   parm      '*STD    '    $pform           10
PAKb C                   parm                    $ptrn#            7
PAKb C                   else
     *
     C                   exsr      zzopt
PAKb C                   endif
PAK aC                   endif
CBIkAC                   endif
     C                   endif
     C                   endif
     C                   endif
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
417b C     endop2        tag
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
     *  GET 10 RECORDS TO DISPLAY
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
     C                   goto      endfac
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfac        tag
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
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C                   if        goback = 10
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
     C                   if        wkoopt = ' 9'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 10
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
     C     dsplyd        add       10            goback
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
     C                   if        wkoopt = ' 9'
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
     C                   select
     C                   when      view = 1
     C                   readc     dspsfl                                 79
     C                   when      view = 2
     C                   readc     vw2sfl                                 79
     C                   when      view = 3
     C                   readc     vw3sfl                                 79
     C                   endsl
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
650bAC                   if            option = ' 2'
650bAC                             and w1stat = sts04
650bAC                   eval      option = ' '
650bAC                   endif
650bAC                   if            option = ' 9'
650bAC                             and w1stat = sts04
650bAC                   eval      option = ' '
650bAC                   endif
     C                   endif
     *
     *  SAVE OPTION
     *
     C                   select
     C                   when      view = 1
     C                   z-add     recno         y
     C                   when      view = 2
     C                   z-add     recno         y
     C                   when      view = 3
     C                   z-add     recno         y
     C                   endsl
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
     C                   if        reccnt < 11
     C                   add       1             reccnt
     C                   eval      recno = reccnt
     C                   z-add     reccnt        y
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
     C                   write     vw2sfl
     C                   write     vw3sfl
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
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     *
     C                   write     dspsfc
     C                   write     vw2sfc
     C                   write     vw3sfc
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     C                   eval      recno = 0
     *
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     *
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
530 D ***                write     postnrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C                   select
     C                   when      view = 1
     C     1             chain     dspsfl                             79
     C                   if        not *in79
HAR AC                   if        client = harbor  and
HARaAC                             svinp1 = *zeros
HAR AC                   eval      *in20 = *off
HAR AC                   else
     C                   eval      *in20 = *on
HAR AC                   endif
     C                   update    dspsfl
     C                   endif
     C                   when      view = 2
     C     1             chain     vw2sfl                             79
     C                   if        not *in79
HAR AC                   if        client = harbor  and
HARaAC                             svinp1 = *zeros
HAR AC                   eval      *in20 = *off
HAR AC                   else
     C                   eval      *in20 = *on
HAR AC                   endif
     C                   update    vw2sfl
     C                   endif
     C                   when      view = 3
     C     1             chain     vw3sfl                             79
     C                   if        not *in79
HAR AC                   if        client = harbor  and
HARaAC                             svinp1 = *zeros
HAR AC                   eval      *in20 = *off
HAR AC                   else
     C                   eval      *in20 = *on
HAR AC                   endif
     C                   update    vw3sfl
     C                   endif
     C                   endsl
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in81 = *on
     C                   eval      recno = posrec
     C                   select
     C                   when      view = 1
     C                   write     dspsfc
     C                   when      view = 2
     C                   write     vw2sfc
     C                   when      view = 3
     C                   write     vw3sfc
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        10            x
     C                   select
     C                   when      view = 1
     C     x             chain     dspsfl                             79
     C                   when      view = 2
     C     x             chain     vw2sfl                             79
     C                   when      view = 3
     C     x             chain     vw3sfl                             79
     C                   endsl
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
     C                   select
     C                   when      view = 1
     C                   update    dspsfl
     C                   when      view = 2
     C                   update    vw2sfl
     C                   when      view = 3
     C                   update    vw3sfl
     C                   endsl
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
416aD**                   PARM '*PREV'   #PGMQ
416aMC                   parm      $pcpgm        #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0001  Option under construction.
     *
     C     zm0001        begsr
     C                   eval      #msgid = 'PIR0001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
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
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
416aA*----------------------------------------------------------------
416aA*      0105
416aA*
     C     zms105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $msgid = #msgk
     C                   eval      $rtncd = '*PGMQ   '
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
417b *----------------------------------------------------------------
417b *      6401  Multi trans, end using task entry.
417b *
417b C     zm6401        begsr
417b C                   eval      #msgid = 'PT64001'
417b C                   eval      #msgtp = '*DIAG  '
417b C                   eval      $md = *blanks
417b C                   exsr      zmpmsg
417b C                   endsr
417b *----------------------------------------------------------------
417b *      6402  Multi trans exists, can not use F16 to close all
417b *
417b C     zm6402        begsr
417b C                   eval      #msgid = 'PT64002'
417b C                   eval      #msgtp = '*DIAG  '
417b C                   eval      $md = *blanks
417b C                   exsr      zmpmsg
417b C                   endsr
417d *----------------------------------------------------------------
417d *      6403  Flags exists, can not close this transaction.
417d *
417d C     zm6403        begsr
     C                   eval      #msgid = 'PT64003'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
417d C                   endsr
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
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
414aA*
414aA*  Test for F7 - Verify catchweights for route
414aA*
414aAC                   if        *inkg
     C     partky        setll     record
     C                   dou       forevr <> forevr
     C     partky        reade     record                                 77
     C                   if        *in77
     C                   leave
     C                   endif
     *
     *    Include only selection transactions to close.
     *
     C                   if        ptgrp1 <> 'S'
     C                   iter
     C                   endif
     *
     C                   eval      ukwhse = ptwhse
     C                   eval      ukrte = *blanks
     C                   eval      ukpo = ptrtpo
     C                   eval      uktrn# = pttrn#
     *
     C                   if        ptstat <> '4'
     C                   exsr      inzpar
     C                   eval      $pcmd = '*VRFYCW '
     C                   eval      $puky = dsukey
     C                   call      @delpg
     C                   parm                    $parms
     C                   endif
     C                   enddo
     *
     C                   endif
     *
     *  Test for F16 - Close all transactions for P.O.
     *
     C                   if        *inkq
     C                   eval      tmpflg = *off
     C     partky        setll     record
     C                   dou       forevr <> forevr
     C     partky        reade     record                                 77
     C                   if        *in77
     C                   leave
     C                   endif
510aA*
510aA*    Include only selection transactions to close.
510aA*
510aAC                   if        ptgrp1 <> 'S'
510aAC                   iter
510aAC                   endif
510aA*
510aAC                   eval      ukwhse = ptwhse
510aAC                   eval      ukrte = *blanks
510aAC                   eval      ukpo = ptrtpo
510aAC                   eval      uktrn# = pttrn#
510aA*
510aAC                   if        ptstat <> '4'
510aAC                   exsr      inzpar
530bMC                   exsr      zzcw
530bMC                   if        cwflg = *off  and
530bMC                             cwitm = *on
530bA*  No catch weights entered.
530bMC                   eval      cancel = *on
530bAC                   eval      *in21 = *on
530bAC                   eval      *in01 = *on
610cMC                   movel     emsg(3)       errmsg
610cMC                   move      wrkmsg        errmsg
530bAC                   exsr      zm0105
530bMC                   endif
510aAC                   endif
417bA*
417bA*    Can not use F16 close all if multiple transactions exist.
417bAC                   eval      uktrn# = pttrn#
417bAC                   exsr      zzmult
417b C                   if        error = '1'
417b C                   exsr      zm6402
417b ***                  MOVE *OFF      CLSALL
417b ***                  EXSR CLRSCH
417b C                   eval      cancel = *on
417b **                   GOTO ENDCMD
417b C                   leave
417b C                   endif
     *  Check for Flags (shorts)
417d C                   eval      uktrn# = pttrn#
417d C                   exsr      zzflag
417d C                   if        error = '1'
417d C                   exsr      zm6403
417d ***                  MOVE *OFF      CLSALL
417d ***                  EXSR CLRSCH
417d C                   eval      cancel = *on
417d C                   leave
417d C                   endif
     *
     C                   eval      ukwhse = ptwhse
     C                   eval      ukrte = *blanks
     C                   eval      ukpo = ptrtpo
     C                   eval      uktrn# = pttrn#
     *
     C                   if        tmpflg = *off
     C                   eval      $puky = dsukey
     C                   endif
     *
     C                   eval      wkokyf = dsfkey
     C                   eval      wkokyu = dsukey
     C     wkounq        chain     workopt                            76
     C                   if        not *in76
650bAC                   if        ptstat <> '4'
     C                   eval      wkoopt = ' 9'
     C                   eval      wkoerr = *off
     C                   update    wkorec
650bAC                   endif
     C                   else
650bAC                   if        ptstat <> '4'
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = dsfkey
     C                   eval      wkokyu = dsukey
     C                   eval      wkoopt = ' 9'
     C                   eval      wkoerr = *off
     C                   write     wkorec
650bAC                   endif
     C                   endif
     C                   enddo
417b C                   if        cancel = '1'
530bAC                   if        *inkq
530bAC                   exsr      clrsch
530bAC                   endif
417b C                   exsr      scr02e
417b C                   else
     *
     C                   exsr      scr02i
417b C                   endif
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     *          FILEKY    CHAINRECORD               79
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
     *                    READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        reade     record                                 79
     C                   if        *in79 <> *on
     C                   if        ptgrp1 <> 'S'  and
     C                             ptgrp1 <> 'L'
     C                   goto      try1
     C                   endif
     C                   endif
     *
     C                   endsr
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
     C     partky        readpe    record                                 79
     C                   if        *in79 <> *on
     C                   if        ptgrp1 <> 'S'  and
     C                             ptgrp1 <> 'L'
     C                   goto      try2
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     C                   eval      t = 1
     C     pttask        lookup    tcod(t)                                50
     C                   if        t = 0
500 D*                    MOVE TDSC,1    W1TYPE
500 MC                   movel     tdsc(1)       w1type
     C                   else
500 D*                    MOVE TDSC,T    W1TYPE
500 MC                   movel     tdsc(t)       w1type
     C                   endif
404 A*
404 AC                   select
404 AC                   when      ptstat = '1'
404 AC                   eval      w1stat = sts01
404 AC                   when      ptstat = '2'
404 AC                   eval      w1stat = sts02
404 AC                   when      ptstat = '3'
404 AC                   eval      w1stat = sts03
404 AC                   when      ptstat = '4'
404 AC                   eval      w1stat = sts04
404 AC                   when      ptstat = '8'
404 AC                   eval      w1stat = sts08
404 AC                   when      ptstat = '9'
404 AC                   eval      w1stat = sts09
404 AC                   other
404 AC                   eval      w1stat = *blanks
404 AC                   endsl
530 A*
530 A* Get Zone Template Code if Template type is T=Truck
530 A*
530 AC     thkey         chain     truckh
530 AC                   if        %found(truckh)
530 AC                             and thtype = 'T'
530 AC                   eval      $ktmpl = thztmp
530 AC                   else
530 AC                   eval      $ktmpl = $ktruk
530 AC                   endif
     *
     *   Get zone description
     *
417 AC                   eval      w1zdsc = *blanks
417 AC     pttrn#        chain     pltsum4                            79
417 AC                   if        not *in79
417 AC     zhkey         chain     zoneh                              79
417 AC                   if        not *in79
417 AC                   movel     zhdesc        w1zdsc
417 AC                   endif
417 AC                   endif
     *
417d *   Get flags
     *
417d C                   eval      w1flag = *blanks
417d C     l90ke1        setll     label90
417d C                   dow       forevr = forevr
417d C     l90ke1        reade     label90                                79
417d C                   if        *in79
417d C                   leave
417d C                   endif
417d C                   if        not *in79  and
417d C                             lbvrfy = 'F'
417d C                   eval      w1flag = 'F'
417d C                   leave
417d C                   endif
417f C                   if        not *in79  and
417f C                             lbvrfy = 'I'
417f C                   eval      w1flag = 'I'
417f C                   leave
417f C                   endif
417d C                   enddo
500cA*
500cA*    Load View 2 fields.
500cAC                   eval      w2trn# = pttrn#
500cAC                   eval      w2emp# = ptemp#
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
HARaAC                   eval      svinp1 = *zeros
610cAC                   eval      slash  = '/'
     *
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    ptwhse
     C                   kfld                    ptgrp2
     C                   kfld                    ptrtpo
     C                   kfld                    pttrn#
     C                   kfld                    ptgrp1
     *
     *  Define UNIQ key for main file.
     *
     C     filuky        klist
     C                   kfld                    uktrn#
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    kywhse
     C                   kfld                    kygrp2
     C                   kfld                    kyrtpo
     *
     *  Define partial key for RTEHED file.
     *
     C     keyrh         klist
     C                   kfld                    $kwhse
     C                   kfld                    $krtid
     *
417 A*  Define key for ZONEH file.
     *
417 AC     zhkey         klist
417 AC                   kfld                    $kwhse
530 D ***                kfld                    $ktruk
530 AC                   kfld                    $ktmpl
417 AC                   kfld                    psszon
530 A*
530 AC     thkey         klist
530 AC                   kfld                    $kwhse
530 AC                   kfld                    $ktruk
411 A*
411 A*  Define key for options file.
411 A*
411 AC     keyop         klist
411 AC                   kfld                    opwhse
411 AC                   kfld                    opcode
     *
417d *  Define partial key for LABEL90
     *
417d C     l90key        klist
417d C                   kfld                    ukwhse
417d C                   kfld                    uktrn#
     *
417d *  Define partial key for LABEL90
     *
417d C     l90ke1        klist
417d C                   kfld                    ptwhse
417d C                   kfld                    pttrn#
     *
530bA*  Define key for ORDC1 file.
     *
530bAC     keyoc1        klist
530bAC                   kfld                    $kwhse
530bAC                   kfld                    lblbl#
     *
530bA*  Define partial key for LABEL7 file.
     *
530bAC     keylb7        klist
530bAC                   kfld                    pttrn#
411 A*
411 A*   Get FTP options from options file.
411 A*
411 AC                   eval      opwhse = 0
411 AC                   eval      opcode = '*FTP    '
640gMC     keyop         chain     options
411 AC                   if        %found(options)
640gAC                   eval      opdta1 = opdata
640gAC                   else
411 AC                   eval      opftp = 'N'
411 AC                   endif
     *
     *  Setup option and command display lines.
     *
HAR AC                   if        client = harbor
HAR A*    Position cursor on transaction number.
HAR AC                   eval      *in35 = *on
HAR AC                   endif
HAR A*
     C                   eval      view = 1
     C                   eval      maxvw = 3
CBIkAC                   if        client = cheney
CBIkAC                   eval      optln2 = optln(2)
CBIkAC                   else
     C                   eval      optln1 = optln(1)
CBIkAC                   endif
     C                   eval      cmdln1 = cmdln(1)
     C                   eval      cmdln2 = cmdln(2)
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     zzinz2        begsr
     C                   eval      kywhse = $kwhse
     C                   eval      kygrp2 = $ktype
     C                   movel     $krtid        kyrtpo
     *
     *   Open closing program.
     *
     C                   eval      $pcmd = '*OPEN   '
     C                   eval      $puky = dsukey
     C                   call      @chgpg
     C                   parm                    $parms
     *
     *
     *   Verify warehouse and get description.
     *
     C                   eval      wowhse = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $kwhse
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
     C                   eval      wowhse = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      $fwhse = $kwhse
     C                   movel     $lerm         $fdesc
     C                   call      'FRMTWH'
     C                   parm                    $fwhse            3 0
     C                   parm                    $fdesc           30
     C                   parm                    wowhse
     C                   endif
     C                   endif
     C                   eval      worte = $krte
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   eval      lsttrn = 0
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
     C                   clear                   ptwhse
     C                   clear                   ptgrp1
     C                   clear                   ptgrp2
     C                   clear                   ptrtpo
     C                   clear                   pttrn#
     *
     *   Initialize unique key (DSUKEY)
     *
     C                   clear                   ukwhse
     C                   clear                   ukrte
     C                   clear                   ukpo
     C                   clear                   uktrn#
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      ukwhse = ptwhse
     C                   eval      ukrte = *blanks
     C                   eval      ukpo = *blanks
     C                   eval      uktrn# = pttrn#
     C                   eval      $pouky = dsukey
     C                   endsr
417b *----------------------------------------------------------------
417b *
417b *  ZZMULT   Check if transaction is a multiple scan transaction.
417b *            Note: IF multiple, must end using TE130 task entry.
417b *
417b C     zzmult        begsr
417b C     uktrn#        chain     multran1                           75
417b C                   if        not *in75  and
417b C                             mustat = '1'
417b C                   eval      error = *on
417b C                   eval      cancel = *on
417b C                   eval      stop = *on
417b C                   movel     $perm         errmsg
417b C                   endif
417b C                   endsr

     *----------------------------------------------------------------
640cA*  ZZChkCW - Check for any C/W not entered.
     *
     C     zzchkCW       begsr

     C                   eval      clsall = *on
     C                   eval      tmpflg = *off
     C     uktrn#        chain(n)  pirtran
     *
     C                   eval      ukwhse = ptwhse
     C                   eval      ukrte = *blanks
     C                   eval      ukpo = ptrtpo
     C                   eval      uktrn# = pttrn#
     *
     C                   if        ptstat <> '4'
     C                   exsr      inzpar
     C                   exsr      zzcw
     C                   if        cwflg = *off  and
     C                             cwitm = *on
     *  No catch weights entered.
     C                   eval      cancel = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      error = *on
     C                   movel     emsg(3)       errmsg
     C                   move      wrkmsg        errmsg
     C                   exsr      zm0105
     C                   endif
     C                   endif

640cAC                   endsr

530bA*----------------------------------------------------------------
530bA*
530bA*  ZZCW     Check to see if c/w records exist.
530bA*
530bAC     zzcw          begsr
     C                   eval      cwflg = *off
     C                   eval      cwitm = *off
     C     keylb7        setll     label7
     C                   dow       forevr = forevr
     C     keylb7        reade     label7                                 78
     C                   if        *in78
610cMC                             or cwitm = *on
610cAC                             and cwflg = *off
     C                   leave
     C                   endif
610cAC                   eval      cwflg = *off
610cAC                   eval      cwitm = *off
CBIlAC                   select
CBIlAC                   when      client = cheney
CBIlAC                             and (cliloc = cbiriv
CBIlAC                              or  cliloc = cbicfr
CBIlAC                              or  cliloc = cbigwb
CBIlAC                              or  cliloc = cbimlk)
CBIlAC                   if        lbpal# >= 20000
CBIlAC                             or lbtype = 'A'
CBIlA*
CBIlAC                             or dsmeat = 'Y'
CBIlAC                             or dsppck = 'Y'
CBIlAC                   iter
CBIlAC                   endif
CBIlAC                   other
530cA*
530cA*      Omit Merge label records from catchwgt tests.
530cAC                   if        lbtype = 'M'
650aAC                             or lbtype = 'A'
530cAC                   iter
530cAC                   endif
CBIlAC                   endsl
610dA*      Omit LBQPCK = 0 records from catchwgt tests.
610dAC                   if        lbqpck = 0
610dAC                   iter
610dAC                   endif
530cA*
     C                   if        itcwgt = 'Y'
     C                   eval      cwitm = *on
610cAC                   else
610cAC                   iter
     C                   endif
     *  Set on c/w flag if c/w records exist.
     C     keyoc1        setll     ordc1
     C                   dow       forevr = forevr
620cDC**   keyoc1        reade     ordc1                                  79
620cMC     keyoc1        reade(n)  ordc1                                  79
     C                   if        *in79
     C                   leave
     C                   else
610cAC                   if        occwgt <> 0
     C                   eval      cwflg = *on
     C                   eval      cwitm = *on
     C                   leave
610cAC                   endif
     C                   endif
     C                   enddo
     *
610cAC                   if        cwitm = *on
610cAC                             and cwflg = *off
610cAC                   eval      eritem = lbitem
610cAC                   eval      ertrn# = %char(lbtrn#)
610cAC                   endif
     C                   enddo
     *
530bAC                   endsr
     *----------------------------------------------------------------
417d *
417d *  ZZFLAG   Check if there are open flags (shorts) for this
417d *           transaction.
417d *
417d C     zzflag        begsr
     C     l90key        setll     label90
     C                   dow       forevr = forevr
     C     l90key        reade     label90                                79
417eAC                   if        *in79
417eAC                   leave
417eAC                   endif
     C                   if        not *in79  and
     C                             lbvrfy = 'F'  or
417fAC                             not *in79  and
417fAC                             lbvrfy = 'I'
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   leave
     C                   endif
     C                   enddo
417d C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     *
     C                   select
640aA
640aA*  ET - Export transaction to staging files
640aA
640aAC                   when      wkoopt = 'ET'
640aAC                   eval      dsukey = wkokyu
640aAC                   call      'RH155ST'
640aAC                   parm      ukwhse        $swhse            3 0
640aAC                   parm      uktrn#        $strn#            7 0
412 A*
412 A*   Catch Weight entry
412 A*
412 AC                   when      wkoopt = ' 3'
412 AC                   eval      $pcmd = '*CHANGE '
412 AC                   call      'CW110A'
412 AC                   parm                    $puky
412 AC                   parm                    $prtn

640aAC                   endsl

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to transaction number.
     *
     C                   if        ptinp1 <> 0
510cAC                   eval      ptwhse = $kwhse
510cAC                   eval      ptrtpo = $krtid
     C                   eval      pttrn# = ptinp1
HARaAC                   eval      svinp1 = ptinp1
     C                   eval      ptinp1 = 0
     C                   eval      repos = *on
     C                   eval      lsttrn = 0
     C                   endif
     C     endzps        endsr
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
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZSTAT   Status check.
     *           When all transactions have been closed export route
     *           and changed RTEHED status to '6'.
     *
     C     zzstat        begsr
     *
520 A*
520 A*  Exit program if route no longer at 4=Printed status.
520 AC     keyrh         chain(n)  rtehed                             79
520 AC                   if        not *in79  and
520 AC                             rhstat <> '4'
520 AC                   eval      error = *on
520 AC                   eval      errmsg = em(2)
520 AC                   exsr      zms105
520 AC                   goto      endsta
520 AC                   endif
416aA*
416aA*  Check in to make sure FTP process isn't running.
416aA*
416aAC                   call      'CHKINOUT'                           49
416aAC                   parm      '*IN'         $xtype            5
416aAC                   parm      'EXPORD'      $xdara           10
416aAC                   if        *in49
416aAC                   eval      error = *on
416aAC                   eval      errmsg = em(1)
416aAC                   exsr      zms105
416aAC                   goto      endsta
416aAC                   endif
710aA*
710aA*  See if any transactions should be auto closed.
710aA*
710aAC                   call      'PT640AC'
710aAC                   parm      $kwhse        $acwhse           3 0
710aAC                   parm                    $krtid
710aAC                   parm                    $ktype
416aA*
     *
     *  Loop through all the transaction for route.
     *
     C                   eval      close = *on
     C     partky        setll     pirtran4
     C                   dow       forevr = forevr
     C     partky        reade     record                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     If not a selection or letdown record then loop.
     *
     C                   if        ptgrp1 <> 'S'  and
     C                             ptgrp1 <> 'L'
     C                   iter
     C                   endif
     *
     *     If transaction is not closed, we're done.
     *
     C                   if        ptstat < '4'  or
510 AC                             ptstat > '4'
     C                   eval      close = *off
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     *  If all transaction were closed, export and update status.
     *
     C                   if        close = *on
     *
520aA*    Update unique piece number recs' scan qty, file ORDP.
520aA*
520aA*
520aAC                   call      'OR633'
520bA ***                parm                    $kwhse
520bMC                   parm      $kwhse        $brwhs
520aAC                   parm                    $krtid
     *
HARbA*    Conditionally call pgm to write XML/POD export files
HARbA*
HARbAC                   if        client = harbor
     *
HARbAC                   call      'XM155'
HARbAC                   parm      $kwhse        $brwhs            3 0
HARbAC                   parm      $krtid        $brtid            5
HARbAC                   parm      $krte         $btrte            5
HARbAC                   parm      ' '           $rtncd
     *
HARbAC                   endif
     *
411 A*  4.11 Notes
     *
     *    The call to RH151 has been left alone, except to include
     *    it in the new select statement. Notice, that RH151 will
     *    never display an error because it does not use $PRTN.
     *
411 AC                   select
411 AC                   when      opftp = 'Y'
DRYbA*
DRYbAC                   select
DRYbAC                   when          client = Dairyland
DRYbA*      Call Stage export to Host pgm.
DRYbAC                   eval      $rwhse = %editc($kwhse:'X')
DRYdAC                   eval      $bcmd = '*ALL'
DRYbAC                   call      'RH155SCL'
DRYbAC                   parm                    $bcmd
DRYbAC                   parm                    $rwhse            3
DRYbAC                   parm      rhrtid        $brtid
DRYbAC                   parm      rhrte         $btrte
DRYbAC                   parm      ' '           $prtn
DRYbA*
DRYbAC                   other
DRYbA*
411 AC                   call      'RH255CL'
411 AC                   parm      $pcpgm        $bpgm            10
411 AC                   parm      $kwhse        $brwhs
411 AC                   parm      $krtid        $brtid
411 AC                   parm      $krte         $btrte
411 AC                   parm      ' '           $rtncd
411 AC                   parm      ' '           $msgid
DRYbAC                   endsl
DRYbA*
640fAC                   when      opftp = 'S'
730aAc                             or opftp ='R'
CBIjAC                   if        client = cheney
CBIjAC                   eval      $bcmd = '*HDRDTL'
CBIjAC                   else
640fAC                   eval      $bcmd = '*ALL'
CBIjAC                   endif
640fAC                   call      'RH155S'
640fAC                   parm                    $bcmd             8
640fAC                   parm      $kwhse        $brwhs            3 0
640fAC                   parm      $krtid        $brtid
640fAC                   parm      $krte         $btrte
640fAC                   parm      ' '           $brtn
411 AC                   other
     C                   call      'RH251'
     C                   parm      $kwhse        $brwhs
     C                   parm      $krtid        $brtid
     C                   parm      $krte         $btrte
     C                   parm      ' '           $brtn             8
411 AC                   endsl
     *
     C     keyrh         chain     rtehed                             79
     C                   if        not *in79
DRYeA*
DRYeAC                   if        client <> Dairyland
     C                   eval      rhstat = '6'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rhstsd = $cvd8o
     C                   time                    rhstst
     C                   update    rhrec
760 A*     Once all closed then rewrite final ELS Goals data for complete route
760 Ac                   monitor
760 Ac                   eval      stdwhse = rhwhse
760 Ac                   eval      stdtrn# = 0
760 Ac                   eval      stdGoal = 0
760 Ac                   call      'WRTELSSTD'
760 Ac                   parm                    stdWhse
760 Ac                   parm      '*UPDSTD'     $sStdSmd         10
760 Ac                   parm                    rhrtid
760 Ac                   parm      ' '           $pDept            5
760 Ac                   parm      ' '           $pStyp            1
760 Ac                   parm                    stdTrn#
760 Ac                   parm                    stdGoal
760 Ac                   parm      ' '           $pRtnScd         10
760 Ac                   parm      ' '           $pRtnSmsg        50
760 Ac                   on-error
760 Ac                   endmon
DRYeAC                   endif
DRYeA*
416 A*  Update picked qty, wt, and cube.
416 AC                   call      @pckrt
416 AC                   parm                    rhwhse
416 AC                   parm                    rhrtid
     C                   endif
ISPaA*
ISPaA*  Custom call for ISupply - get Ord# & Cust# then call
ISPaA*
ISPaAC                   if        client = isupply
ISPaA*
ISPaAC     keyoh         chain     ohrec                              79
ISPaA*
ISPaAC                   move      ohcord        ispord
ISPaAC                   eval      ispcust = %subst(%editw(ohcust:editw11):8:5)
ISPaA*
ISPcAC                   eval      iswhse = %editc(rhwhse : 'X')
ISPaAC                   call      'OR400CLISP'
ISPaAC                   parm                    ispord            7
ISPaAC                   parm                    ispcust          11
ISPcAC                   parm                    iswhse            3
ISPaA*
ISPaAC                   endif
ISPaA*
     C                   endif
     *
CBIh *  Print one copy of Route summary report(Custom CBI)
     *
CBIh C                   if        rhtruk <> @meat  and
CBIh C                             rhtruk <> @ppick  and
CBIh C                             rhtruk <> @cntnr  and
CBIh C                             rhtruk <> @wlcll  and
CBIh C                             rhtruk <> @sdsvc  and
CBIh C                             rhtruk <> @dmges  and
CBIh C                             rhtruk <> @brekr
CBIh C                             and close = '1'
CBIh C                   move      $kwhse        $whsea
CBIh C                   call      'OR670CL'
CBIh C                   parm                    $whsea
CBIh C                   parm                    rhrtid
CBIh C                   parm                    $prtn
CBIh C                   parm                    $rsdt
CBIh C                   endif
     *
CBIa *  Print one copy of Driver's Detail report(Custom CBI)
     *
CBIe C                   if        rhtruk <> @meat  and
CBIe C                             rhtruk <> @ppick  and
CBIf C                             rhtruk <> @cntnr  and
CBIg C                             rhtruk <> @wlcll  and
CBIg C                             rhtruk <> @sdsvc  and
CBIg C                             rhtruk <> @dmges
CBIg C                             and close = '1'
CBIc C                   movel     'OR663PR'     wkprtf
CBIc C     rpkey         chain     reports                            79
CBIc C                   if        not *in79
CBIc C                   eval      $dev = rpdev
CBIc C                   eval      $form = rpform
CBIc C                   else
CBIc C                   movel     '*JOB    '    $dev
CBIc C                   movel     '*STD    '    $form
CBIc C                   endif
CBIa C                   move      $kwhse        $whsea
CBIcD**                   MOVEL'LP10    '$DEV
CBIa C                   call      'OR663CL'
CBIa C                   parm                    $pcmd
CBIa C                   parm      '*DETAIL '    rtype             8
CBIa C                   parm                    $whsea
CBId C                   parm                    rhrtid
CBId C                   parm                    $prtn
CBId C                   parm                    $dev             10
CBId C                   parm                    $form            10
CBIe C                   endif
416aA*
416aA*  Check out so FTP process can run.
416aA*
416aAC                   call      'CHKINOUT'                           49
416aAC                   parm      '*OUT'        $xtype
416aAC                   parm      'EXPORD'      $xdara
416aA*
     *
416aAC     endsta        tag
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 2 3 5 91016ET
**  OPTLN - Option display line
  2=Change and close  3=Catch Wt.  5=View  9=Quick close
  2=Change and close  3=Catch Wt.  5=View  9=Quick close  10=TranInfo
**  CMDLN - Command display line
F3=Exit  F5=Refresh  F7=Verify Cwgt  F12=Cancel  F16=Close all
F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F12=Cancel
F10=View 1  F11=View 3  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F12=Cancel
F10=View 2  F11=View 1  F17=Top  F18=Bottom  F20=Move to top
**
      * Not on File *
BULKF Bulk Pick - Full Pallet
BULKP Bulk Pick - Partial Pallet
BULKR Bulk Pick with Replenishment
FIXED Floor Pick
PIR   PIR Pick
PUTEMPReceiving
PUTMOVReceiving
PUTRTNCustomer Return
REPL  Replenishment
**  EM - Error message
Not allowed Export at this time.
Route already exported to Host.
** EMSG ERROR MESSAGES
No UCI's exist for this transaction.
No Catch Weights Entered for Item
No C/W Entered for Trn#/Item
Pre-Pick tran not closed for rte/trn
Can't close/upd, USR slot exists for trn#
F16 Close All not allowed for SOS orders
