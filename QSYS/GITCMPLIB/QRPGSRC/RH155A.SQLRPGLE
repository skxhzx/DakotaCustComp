700aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  RH155A    FTP Export closed customer orders - Post
     *  05 March 1999
     *  Dave Sommerville
     *
     *  This program should be identical to RH151 except that it uses
     *  the EXPF files that are overridden in RF155CL.
     *
     *----------------------------------------------------------------
     *  Revisions
     *  Notes
     *      - Created from RH155 for new '2' versions of EXPFORD** files.
     *      - Recompiled because of new LABEL5 file.
     *      - Added OHTYPE to key for LABEL5.
     *      - Moving OHCORD into OEHORD, OEDORD and OECORD.
     *      - Added update to file EXPORDT.
     *
     *      - Revised to ignore letdown records when checking LABEL5.
     *
404 A*    08/26/97  HNK  4.04
     *      - Revised to loop thru order file for a route.
406 A*    09/25/97  RH   4.06
     *      - Revised to update Export date and time.
409 A*    04/21/98  RH
     *      - Recompiled, files ORDC & EXPORDC changed.
     *      - Move transaction # to OECTRN.
     *
411 A*    03/05/99  DAS 4.11
     *      - Created this program from RH151.
412 A*    08/23/99  RH
     *      - Recompiled, file ORDC changed.
417aA*    07/08/03  RH   4.17a
     *      - Changed to update the emp# and quantity in ORDT and
     *        EXPORDT files.
417bA*    07/28/03  RH   4.17b
     *      - Compiled due to change in file.
     *      - Fix - There could be more than one label record for a
     *        transaction.  Changed to read LABEL90 file.
     *
510 A*    07/07/06  MLB  5.10
     *      - Enh: Added client custom code support to program.
510bA*    11/02/06  RH   5.10b
     *      - Enh: Use *FEATURE to include stand alone code (500 & 500a)
500 A*    02/08/06  MLB  5.00
     *      - Enh: Revised program to add four new files to program:
     *        ORDBOX, ORDEXPDTE, EXPFORDB, EXPFORDE.
500aA*    04/25/06  MLB  5.00a
     *      - Fix: Correction to 5.00 mod. Revised routines FILOEB
     *        and FILOEE to load customer order number into files
     *        EXPFORDE and EXPFORDB instead of internal order #.
510cA*    05/11/07  RBD  5.10c
     *      - Added order detail label# export file EXPFORDL.
510dA*    05/18/07  DAS  5.10d
     *      - Added oeldsp and oelpal fields.
510eA*    05/25/07  MLB  5.10e
     *      - Fix: Revised program to load customer order number
     *        into OELORD field.
510fA*    05/29/07  MLB  5.10f
     *      - Fix: Revised program to use LABEL93 instead of LABEL13
     *        to populate EXPFORDL file. Replaced
510gA*    06/20/07  DAS  5.10g
     *      - Added files ORDP, EXPFORDP,WORKLBL
510hA*    06/26/07  DAS  5.10h
     *      - Replaced file ORDP with ORDP1.
     *      - Moved logic for exporte ORDP records into order loop.
     *      - Revised to export all records that are in ORDP file.
510iA*    09/13/07  DAS  5.10i
     *      - Added fields OEPCNT, OEPTTL and OEPSCN.
520 A*    04/07/08  RBD  5.20
     *      - Fix: WORKLBL fields were being written to EXPFORDP file
     *        but there was no chain to WORKLBL, thus the fields were
     *        empty.
520aA*    04/17/08  RBD
     *      - Recompiled, file EXPFORDP changed.
     *
530 A*    04/30/10  MLB  5.30
     *      - Fix: Revised program to omit label type A records from
     *        being written into the EXPFORDL file.
530bA*    08/19/10  RH/MLB  5.30b
     *      - Make HAL custom - standard mod to compute unique seq for
     *        each catchwgt record written into EXPFORDC linked to
     *        a line item on the customer order.  This is being done
     *        because a line item on an order ended up split across
     *        pallets causing wgts to have duplicate sequence numbers.
     *
640 A*    08/27/11  MLB  6.40
     *      - Fix: Revised program to remove STANDA test for ord boxes
     *        and expiration dates being exported to host. Chg to 5.10b
     *        mod.
     *
640aA*    08/07/12  LMC  6.40a
     *      - Enh: Added file EXPFORDO to export lot information
     *
700a *    08/13/15  RTR  7.00a
     *      - Fix: Check route status and set to exported first thing.
     *        This is needed because now GUI submits to batch, so is
     *        possible to have multiple jobs submitted before first
     *        run finishes.
700b *    09/15/15  RTR  7.00b
     *      - Fix: Added will call status 4 to status check. Will calls
     *        will be at status 4 when this is called.
     *
730a *    03/18/19  RTR  7.30a
     *      - Created from RH155 to use new '2' versions of export files.
     *
730bA*    06/13/19  RBD  7.30b
     *      - Copied these revs from RH155S ...
     *        * Added *SYSTEM options.
     *        * Added creation of Trax xml which used to run in RH150A
     *          but was moved in here to ensure route status has been
     *          updated to exported status.
     *
740a *    08/28/20  RTR  7.40a
     *      - Added CUSTMAST checking for exporting customer number.
     *
740bA*    11/06/20  RBD  7.40b
     *      - Added *TRAX options. Only create Trax xml at this time
     *        if Trax user AND they do not print Trax invoices.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers.
     *
CBI A*    05/11/07  MLB  CBI
     *      - Revised program to write export label data to file
     *        EXPFORDL.
CBIaA*    06/13/07  RBD  CBIa
     *      - Only write generation 1 labels to EXPFORDL.
CBIbA*    06/20/07  DAS  CBIb
     *      - Reversed above CBI changes.
     *      - Reversed to write out to EXPFORDP file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Ellenbee-Leggett.
     *
ELL A*    05/25/07  MLB  ELL
     *      - Added ELL to CBI mod.
     *      - Revised program to write export label data to file
     *        EXPFORDL.
ELLaA*    09/28/09  MLB  ELLa
     *      - Revised pgm to disable ELL mod. File no longer needed.
ELLbA*    09/28/09  MLB  ELLb
     *      - Revised program to write out EXPFORDP file.
     *      - Added client to CBIb mod.
ELBcA*    09/25/09  JCJ  ELBc
     *      - send Pallet ID instead of Pallet number in the EXPFORDP
     *        file in field OEPPAL
ELBdA*    10/06/09  MLB  ELBd
     *      - Revised ELBc mod to read LABEL11 file for generation 2
     *        type O records to retrieve truck pallet id to load
     *        into EXPFORDP file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's Provision
     *
PAK A*    07/07/06  MLB  PAK
     *      - Revised program to write export data to file SAPEXP
     *        instead of standard expfxxxx files.
PAKaA*    09/08/06  MLB  PAKa
     *      - Revised program to add /copy members for Order Hdr misc
     *        fields unique to Packer's.
PAKbA*    09/18/06  MLB  PAKb
     *      - Revised program to add file UCICW6 to write out UCI
     *        records with export data.
PAKcA*    09/27/06  MLB  PAKc
     *      - *TEMPORARY* Revised program to change values written
     *        into SAPEXP file for testing. These changes will be
     *        replaced when going live on SAP.
PAKdA*    09/27/06  MLB  PAKd
     *      - Revised program to only write out segment E1EDL26
     *        for catchweight items.
PAKeA*    09/28/06  MLB  PAKe
     *      - Revised program to update field MAND in E1EDL20,
     *        E1EDL21 and E1EDL24 segments.
     *      - Revised program to change value of MAND.
PAKfA*    09/28/06  MLB  PAKf
     *      - Enh: Revised program to add BRGEW and remove GEWEI
     *             Change UOM from CV to CS.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa
     *
CWD A*    12/15/09  MLB  CWD
     *      - Added CWD to CBI mod.
     *      - Revised program to write export label data to file
     *        EXPFORDL.
CWDaA*    12/27/17  MLB  CWDa  P#01833
     *      - Revised pgm to populate EXPFORDP file.
     *      - Needed as part of mods to export data to Host for use
     *        with off-truck delivery system.
CWDbA*    01/05/18  MLB  CWDb  P#01833
     *      - Revised routine FILOEP to load $PRTID into OEPWGT.
     *      - Needed as part of mods to export data to Host for use
     *        with off-truck delivery system.
     *
HAR A*----------------------------------------------------------------
HAR A*  Client Custom Revisions: Harbor
HAR A*
HARaA*    04/02/08  DAS  HAR
     *      - Revised program to write out EXPFORDP file.
HARbA*    04/08/08  RBD  HARb
     *      - Fix: Add Harbor to open of WORKLBL.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey Foodservice
     *
HAL A*    02/10/10  MLB  HAL
     *      - Revised program to compute unique sequence number for
     *        each catchwgt record written into EXPFORDC linked to
     *        a line item on the customer order.  This is being done
     *        because a line item on an order ended up split across
     *        pallets causing wgts to have duplicate sequence numbers.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fox River Foods
     *
FRF A*    04/30/10  MLB  FRF
     *      - Revised program to write export label data to file
     *        EXPFORDL.
     *
     *----------------------------------------------------------------
     *
EI  A*    08/24/07  RBD  EI
     *      - Revised to populate EXPFORDH/oehczp, zip code field,
     *        with user id that closed the route.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Avalon Foodservice
     *
AVL A*    11/11/11  MLB  AVL
     *      - Revised pgm to populate OEHPBT with OHORD for processing
     *        in pgm, HRH160 Export to Retalix Pwr Whse.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier Foods
     *
GLZ A*    03/02/12  MLB  GLZ
     *      - Revised program to load order id into field, OEHPBT
     *        for use in H&S interface pgm, HRH156. Needed to retrieve
     *        H&S ship date from ORDHM file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Y.hata
     *
YHA A*    11/11/13  MLB  YHA  P#01146
     *      - Revised program to write out EXPFORDP file.
     *      - Added YHA to CBIb mod.
YHAaA*    11/11/13  MLB  YHAa
     *      - Revised program to load order id into field, OEHPBT
     *        for use in H&S interface pgm, HRH156. Needed to retrieve
     *        H&S ship date from ORDHM file.
     *      - Added YHAa to GLZ mod.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  78        - EOF for ORDH
     *  79        - EOF for ORDD
     *
     *----------------------------------------------------------------
     * File Specs
     *
     *RDH    UP  E           K        DISK
     Fordh3     uf   e           k disk
PAK AFordhm     if   e           k disk
     Fordd      if   e           k disk
     Fordc      if   e           k disk
417aA*RDT    IF  E           K        DISK
417aMFordt      uf   e           k disk
510hMFordp1     if   e           k disk    usropn
500 AFordbox    if   e           k disk
500 AFordexpdte if   e           k disk
417bD**BEL   IF  E           K        DISK
PAK AFpiritem   if   e           k disk
417aAFpirtran   if   e           k disk
     *ABEL5  IF  E           K        DISK
     Frtehed    uf   e           k disk
ELBdAFlabel11   if   e           k disk    usropn
417bAFLabel90   if   e           k disk
     F                                     rename(lbrec:lbrec9)
510fMFlabel93   if   e           k disk
510fMF                                     rename(lbrec:lbrec93)
510fAF                                     usropn
640aAfliclog6   if   e           k disk
PAK AFsapexp    uf a e           k disk    usropn
PAKbAFucicw6    if   e           k disk    usropn
CBIaAFpltsum4   if   e           k disk    usropn
EI  AFpirtrck4  if   e           k disk
730aMFexpfordh2 o  a e           k disk
730aMFexpfordd2 o  a e           k disk
730aMFexpfordc2 uf a e           k disk
730aMFexpfordt2 o  a e           k disk
730aMFexpfordb2 o  a e           k disk
730aMFexpforde2 o  a e           k disk
730aMFexpfordl2 o  a e           k disk
730aMFexpfordp2 o  a e           k disk    usropn
730aMFexpfordO2 uf a e           k disk
     Foptions   if   e           k disk
510gAFworklbl   if   e           k disk    usropn
730bAFttrte     if   e           k disk
730bAFpiruser   if   e           k disk
740aAfcustmast  if   e           k disk
640aA*----------------------------------------------------------------
640aA*  DRI parameters
640aA*----------------------------------------------------------------
640aA /COPY *libl/qcopysrc,C#DRIPARMS

730aA*----------------------------------------------------------------
730aA*  Standard SQL variables and constants
730aA*----------------------------------------------------------------
730aA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Customer id
     *
PAK A /COPY QCOPYSRC,ID#packers
CBI A /COPY QCOPYSRC,ID#cheney
ELL A /COPY QCOPYSRC,ID#ellenbe
CWD A /COPY QCOPYSRC,ID#cashwa
HARaA /COPY QCOPYSRC,ID#harbor
HAL A /COPY QCOPYSRC,ID#halsey
FRF A /COPY QCOPYSRC,ID#FRF
EI  A /COPY QCOPYSRC,ID#EI
AVL A /COPY QCOPYSRC,ID#Avalon
GLZ A /COPY QCOPYSRC,ID#glazier
YHA A /COPY QCOPYSRC,ID#YHata
     *
     *----------------------------------------------------------------
     *  Level breaks
     *
     *HREC
     *                                             OHWHSEL1
     *                                             OHRTE L1
     *                                             OHPBATL1
PAKaA*
PAKaA*----------------------------------------------------------------
PAKaA*  SAP Header Misc. File data structures
PAKaA*
PAKaA /copy qcopysrc,ordhm1_pak
PAKaA /copy qcopysrc,ordhm2_pak
PAKaA /copy qcopysrc,ordhm3_pak
PAKaA /copy qcopysrc,ordhm4_pak
PAKaA /copy qcopysrc,ordhm5_pak
PAK A*
PAK A*----------------------------------------------------------------
PAK A*  SAP Export File data structures
PAK A*
PAK A /copy qcopysrc,s#edidc40
PAK A /copy qcopysrc,s#e1edl20
PAK A /copy qcopysrc,s#e1edl21
PAK A /copy qcopysrc,s#e1edl24
PAK A /copy qcopysrc,s#e1edl26
PAK A*
640aA*----------------------------------------------------------------
640aA*  Data Formats
640aA*----------------------------------------------------------------
640aA
640aA /COPY *libl/qcopysrc,C#ITEM
640aA /COPY *libl/qcopysrc,C#LICENSE
640aA /COPY *libl/qcopysrc,C#LICINFO
640aA /COPY *libl/qcopysrc,C#SLOT
640aAD savever#        s                   like($lnver#)
     *----------------------------------------------------------------
     *  Working variables
     *
640aAD chk4err         s               n
     D error           s              1
PAK AD expdate         s              8  0
PAK AD exptime         s              6  0
640aAD forever         s              1
PAK AD loopcount       s              7  0
530bAD hldordseq#      s              5  0 inz(*loval)
530bAD newseq          s              5  0
PAKbAD sapcntrl        s              4    inz('*NO ')
PAK AD sapcount        s              7  0
510bAD standa          s              1
     D today           s              8  0
730bAD sysWhse         s              3s 0 inz(0)
     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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

730bA*----------------------------------------------------------------
730bA*  Prototypes
     *----------------------------------------------------------------

730bAD tr810           pr                  extpgm('TR810')
730bA * Input
730bAD   tr8Whse                      3  0 const
730bAD   tr8Rtid                      5    const
730bAD   tr8Emp                       5    const
730bA * Output
730bAD   tr8FileSnd                  30    const
730bAD   tr8Rtn                       8    const
730bAD   tr8Erm                      60    const

730bA*----------------------------------------------------------------

510b *
510b * Data structure
510b *
415dA*----------------------------------------------------------------
415dA*  *FEATURE  -  PIR Feature options.
415dA*----------------------------------------------------------------
415dA*
415dA* Fields
415dA*
415dA*    OPFEAT  -  PIR Installed feature.
415dA*
415dA* Data structure
415dA*
415dAD ftropt          ds
415dAD  opfeat                 1      1
415dAD  ftrend               117    117
730bA*----------------------------------------------------------------
730bA*  *SYSTEM  -  System options.
730bA*----------------------------------------------------------------
730bA*
730bA* Fields
730bA*
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Check CW count during selection closing (N,M,C,B)
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -  Use UCI processing (Y,N)
     *    OPWRNCR -  Check CW variance during receiving closing (N,M,C,B)
     *    OPICWR  -  Check CW count during receiving closing (N,M,C,B)
     *    OPTRAX  -  Using TRAX module (Y,N).
     *    OPTAXR  -  Using TAXR module (Y/N).
     *    OPCHKR  -  Using CHKR module (Y/N).
     *    OPVOICE -  Using VOICE module (Y/N).
     *    OPSLOT  -  Print Slot barcode on Pick Label (Y/N).
     *    OPDSPL  -  Display last three digits of license (Y/N).
     *
     * Data structure
     *
     D opdat1          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  optbjq                32     32
     D  opishs                33     35  0
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
     D  optrax                39     39
     D  optaxr                40     40
     D  opchkr                41     41
     D  opvoice               42     42
     D  opslot                43     43
     D  opdspl                44     44
     D  opten1               117    117
     *----------------------------------------------------------------
740bA*  *TRAX  -  TRAX options
740bA*----------------------------------------------------------------
740bA*
740bA* Fields
740bA*
740bA*    OPTHST  -  Days to keep TRAX export data (1-999)
740bA*    OPTSLI  -  Save log info
740bA*    OPTCWR  -  Catch weight required
740bA*    OPTOFT  -  Order number field type
740bA*    OPTDFT  -  Driver field type
740bA*    OPTRFT  -  Route field type
740bA*    OPTCAP  -  Capitalize input
740bA*    OPTDBL  -  Double click delivery
740bA*    OPTEKD  -  Entry key delivery
740bA*    OPTDAR  -  Delivery after return
740bA*    OPTIDB  -  Include item data base
740bA*    OPTBDA  -  Breakdowns allowed
740bA*    OPTGBD  -  Generic breakdown allowed
740bA*    OPTRTQ  -  Pre-trip questions
740bA*    OPTOTQ  -  Post-trip questions
740bA*    OPTCCE  -  Credit card enabled
740bA*    OPTSIG  -  Signature enabled
740bA*    OPTPIV  -  Print invoice
740bA*    OPTSDA  -  Send data after stop
740bA*    OPTWSP  -  Ws port
740bA*    OPTWSI  -  Ws IP
740bA*    OPTSVD  -  Save days
740bA*    OPTERT  -  Environment run time
740bA*    OPTEDV  -  Environment device
740bA*    OPTEOS  -  Environment OS
740bA*    OPTESW  -  Environment screen width
740bA*    OPTESH  -  Environment screen height
740bA*    OPTARE  -  Add return enabled
740bA*    OPTIDL  -  Icon delivery
740bA*    OPTDCI  -  Double click icons
740bA*    OPTPAL  -  Pallets enabled
740bA*    OPTCRA  -  Cradle upload enabled
740bA*    OPTDRV  -  Driver assigned before download
740bA*    OPTBUL  -  Bulk items enabled
740bA*    OPTEYS  -  Display empty stops
740bA*    OPTSAS  -  Save after scan
740bA*    OPTSDL  -  Save delay
740bA*    OPTSDT  -  Sync date and time
740bA*    OPTLRK  -  Left/right keys enabled
740bA*    OPTGSS  -  GS1 scanning
740bA*    OPTGSU  -  GS1 unique
740bA*    OPTSBV  -  Scan beep volume
740bA*    OPTRAG  -  Restart after get route.
740bA*    OPTRD   -  Restart daily.
740bA*    OPTRDT  -  Restart daily time.
740bA*    OPTRFP  -  Reader focus position.
740bA*    OPTRFM  -  Reader focus mode.
740bA*    OPTNSR  -  Non scan reason prompt.
740bA*    OPTFBD  -  Filter by department.
740bA*    OPTDSF  -  Display stop flags before restart.
740bA*    OPTSOR  -  Sort items by compartment Y/N.
740bA*    OPTODE  -  Customer on site delivery enable Y/N.
740bA*    OPTODP  -  Customer on site delivery verification period, 5-60.
740bA*    OPTONT  -  On truck picking Y/N.
740bA*    OPTOTP  -  Override truck picking Y/N.
740bA*    OPTNSB  -  No signee button on signature screen Y/N.
740bA*    OPTRAXINV - 1 = Print all invoices
740bA*                2 = Print pristine invoices only
740bA*                3 = Print non-pristine invoices only
740bA*                9 = Print no invoices
740bA*
740bA* Data structure
740bA*
740bAD opdat2          ds
740bAD  opthst                 1      3  0
740bAD  optsli                 4      4
740bAD  optcwr                 5      5
740bAD  optoft                 6      6
740bAD  optdft                 7      7
740bAD  optrft                 8      8
740bAD  optcap                 9      9
740bAD  optdbl                10     10
740bAD  optekd                11     11
740bAD  optdar                12     12
740bAD  optidb                13     13
740bAD  optbda                14     14
740bAD  optgbd                15     15
740bAD  optrtq                16     16
740bAD  optotq                17     17
740bAD  optcce                18     18
740bAD  optsig                19     19
740bAD  optpiv                20     20
740bAD  optsda                21     21
740bAD  optwsp                22     26  0
740bAD  optwsi                27     41
740bAD  optsvd                42     43  0
740bAD  optert                44     47
740bAD  optedv                48     57
740bAD  opteos                58     67
740bAD  optesw                68     71  0
740bAD  optesh                72     75  0
740bAD  optare                76     76
740bAD  optidl                77     77
740bAD  optdci                78     78
740bAD  optpal                79     79
740bAD  optcra                80     80
740bAD  optdrv                81     81
740bAD  optbul                82     82
740bAD  opteys                83     83
740bAD  optsas                84     84
740bAD  optsdl                85     86  0
740bAD  optsdt                87     87
740bAD  optlrk                88     88
740bAD  optgss                89     89
740bAD  optgsu                90     90
740bAD  optsbv                91     91  0
740bAD  optrag                92     92
740bAD  optrd                 93     93
740bAD  optrdt                94     97  0
740bAD  optrfp                98     98
740bAD  optrfm                99     99
740bAD  optnsr               100    100
740bAD  optfbd               101    101
740bAD  optdsf               102    102
740bAD  optsor               103    103
740bAD  optode               104    104
740bAD  optodp               105    106  0
740bAD  optont               107    107
740bAD  optotp               108    108
740bAD  optnsb               109    109
740bAD  optraxinv            110    110
740bAD  opten2               117    117

640aA*----------------------------------------------------------------
640aA*  Program info data structure
640aA*
640aA /Copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
     *      $PRTE   Route
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     * Level break check
     *
     *  See if there are any open transactions for the route.
     *
217 A*    If an open transaction exists, make sure it isn't a letdown.
     *
222 D*  L1      KEYLB5    SETLLLABEL5                   50
217 A*  L1      *IN50     IFEQ *ON
217 A*                    MOVE *OFF      *IN50
217 A*                    MOVE *OFF      *IN79
217 A*          *IN79     DOUEQ*ON
217 A*          KEYLB5    READELABEL5                   79
217 A*          *IN79     IFEQ *OFF
217 A*          P5TASK    ANDNE'REPL'
217 A*          P5TASK    ANDNE'REPLBK'
217 A*                    MOVE *ON       *IN50
217 A*                    LEAVE
217 A*                    ENDIF
217 A*                    ENDDO
217 A*                    ENDIF
222 D*  L1                MOVE *IN50     OPNFLG  1
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
     C                   parm                    $prtn             8
     * Main line
     *
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     *
700aA*  First check route status.
700aA*  This is needed now that GUI is submitting exports to batch.
700aA*
700aAC     keyoh         chain     rtehed
700aAC                   if        %found(rtehed)
700aDC***                          and rhstat = '5'
700aAC                             and (rhstat = '5'
700bAC                             or (rhstat = '4'
700bAC                             and rhtype = 'W'))
700aAC                   eval      rhstat = '6'
700aAC                   eval      $cvcmd = '*CURCMD '
700aAC                   call      @cvtdt
700aAC                   parm                    $cvtdt
700aAC                   eval      rhstsd = $cvd8o
700aAC                   time                    rhstst
700aAC                   eval      rhexpd = $cvd8o
700aAC                   time                    rhexpt
700aAC                   update    rhrec
700aA*
700aA*  if route not found or status not 5, exit program
700aAC                   else
700aAC                   goto      bottom
700aAC                   endif
     *
     *  Get order header record.
     *
404 D*          KEYOH     CHAINORDH3                79
404 AC     keyoh         setll     ordh3
404 AC                   dou       forevr <> forevr
404 AC     keyoh         reade     ordh3                                  79
404 A*
     C                   if        *in79
404 AC                   leave
404 D*                    MOVE '*ERROR  '$PRTN
404 D*                    GOTO BOTTOM
     C                   endif
     *
222 D*  Skip order if open transactions exist.
     *
222 D*          OPNFLG    CABEQ*ON       BOTTOM
     *
     *  Add order header record to export header file.
     *
PAK AC                   select
PAK AC                   when      client = packers
PAKbA*
PAKbAC                   if        sapcntrl = '*NO '
PAK A*  Populate SAP Control Record and write to export file.
PAK AC                   exsr      sapcontrol
PAK AC                   exsr      sapwrite
PAKbAC                   eval      sapcntrl = '*YES'
PAKbAC                   endif
PAKaA*
PAK A*      Get BFC Order Header Misc. file.
PAK AC                   exsr      zzgethm
PAK A*      Create SAP Header Rcd format for export file.
PAK AC                   exsr      sapheader
PAK A*      Write SAP Header Rcd format for export file.
PAK AC                   exsr      sapwrite
PAK A*      Create SAP Header Additional Data Rcd format for export file.
PAK AC                   exsr      saphdradd
PAK A*      Write SAP Header Rcd format for export file.
PAK AC                   exsr      sapwrite
PAK AC                   other
PAK A*
     C                   exsr      filoeh
     C                   write     oehrec
PAK AC                   endsl
     *
     *  Add order detail records to export detail file.
     *
     C     keyod         setll     ordd
     C                   dou       forevr <> forevr
     C     keyod         reade     ordd                                   78
     C                   if        *in78
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAK A*      Create SAP Detail Additional Data Rcd format for export file.
PAKdAC                   if        itcwgt = 'Y'
PAK AC                   exsr      sapdtladd
PAK A*      Write SAP Detail Rcd format for export file.
PAK AC                   exsr      sapwrite
PAKdAC                   endif
PAK AC                   endsl
PAK A*
     C                   leave
     C                   endif
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAKbA*
PAKbAC                   evalr     kyord = %trimr(%editc(ohord:'X'))
PAKbAC     keyuci6       setll     ucicw6
PAKbA*
PAK A*
PAK A*      Get BFC Item master file.
PAK AC                   exsr      zzgetit
PAK A*      Is item a catchweighted item?
PAK AC                   if        itcwgt = 'Y'
PAK A*      Need to loop for as many as were picked.
PAK AC                   if        odqpk2 <> 0
PAK AC                   eval      loopcount = odqpk2
PAK AC                   else
PAK AC                   eval      loopcount = odqpk1
PAK AC                   endif
PAK AC                   else
PAK A*      Item a non-catchweighted item.
PAK AC                   eval      loopcount = 1
PAK AC                   endif
PAK A*      We must loop at least once for every line item.
PAK AC                   if        loopcount <= 0
PAK AC                   eval      loopcount = 1
PAK AC                   endif
PAK A*
PAK A*      Create SAP Detail Rcd format for export file.
PAK AC                   eval      sapcount = 0
PAK AC                   dow       sapcount < loopcount
PAK AC                             and loopcount > 0
PAKbA*
PAKbA*      Is item a catchweighted item?
PAKbAC                   if        itcwgt = 'Y'
PAKbAC     keyuci6       reade     ucicw6
PAKbAC                   if        %eof(ucicw6)
PAKbAC                   eval      ucinbr = ' '
PAKbAC                   eval      uciwgt = 0
PAKbAC                   endif
PAKbAC                   endif
PAKbA*
PAK AC                   eval      sapcount = sapcount + 1
PAK AC                   exsr      sapdetail
PAK A*      Write SAP Detail Rcd format for export file.
PAK AC                   exsr      sapwrite
PAKdA*
PAKdA*      Create SAP Detail Additional Data Rcd format for export file.
PAKdAC                   if        itcwgt = 'Y'
PAKdAC                   exsr      sapdtladd
PAKdA*      Write SAP Detail Rcd format for export file.
PAKdAC                   exsr      sapwrite
PAKdAC                   endif
PAKdA*
PAK AC                   enddo
PAK A*
PAK AC                   other
PAK A*
     C                   exsr      filoed
     C                   write     oedrec
640aAC                   exsr      filoef
PAK AC                   endsl
PAK A*
     C                   enddo
     *
     *  Add order catch weight records to export catch weight file.
     *
PAK AC                   select
PAK AC                   when      client = packers
PAK A*      For Packer's, do nothing.
PAK AC                   other
PAK A*
HAL DC**                 if        client = Halsey
530bAC*
530bAC*  Delete all entries from EXPFORDC to ensure no duplicate wgts.
530bAC                   exsr      zzdelw
530bAC                   eval      newseq     = 0
530bAC                   eval      hldordseq# = *loval
HAL DC**                 endif
HAL A*
     C     keyod         setll     ordc
     C                   dou       forevr <> forevr
     C     keyod         reade     ordc                                   78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   exsr      filoec
     C                   write     oecrec
     C                   enddo
PAK A*
PAK AC                   endsl
PAK A*
213 A*
213 A*  Add order detail transaction recs to export file.
213 A*
213 AC     keyod         setll     ordt
213 AC                   dou       forevr <> forevr
213 AC     keyod         reade     ordt                                   78
213 AC                   if        *in78
213 AC                   leave
213 AC                   endif
417aA*  Get employee # for ORDT and export file.
417aAC     ottrn#        chain     pirtran                            77
417aAC                   if        not *in77
417a C                   eval      otemp# = ptemp#
417aAC                   endif
417aA*  Get quantity for ORDT and export file.
417bD**         OTLBL#    CHAINLABEL                77
     *
417bAC     keylb9        setll     label90
417bAC                   dow       forevr = forevr
417bAC     keylb9        reade     label90                                77
     *
417bAC                   if        *in77
417bAC                   leave
417bAC                   endif
     *
417aAC                   if        not *in77
     *
417bAC                   if        lbtype <> 'O'  and
417bAC                             lbtype <> 'M'
417bAC                   iter
417bAC                   endif
     *
417bAC                   if        lbitem <> otitem  or
417bAC                             lbord <> otord  or
417bAC                             lbseq <> otseq
417bAC                   iter
417bAC                   endif
     *
417aAC                   if        lbutyp = 'N'
417bMC                   add       lbqpck        otpck1
417b **                   Z-ADDLBQPCK    OTPCK1
417aAC                   endif
417aAC                   if        lbutyp = '1'
417bMC                   add       lbqpck        otpck2
417bD**                   Z-ADDLBQPCK    OTPCK2
417aAC                   endif
417aAC                   if        lbutyp = '2'
417bMC                   add       lbqpck        otpck3
417bD**                   Z-ADDLBQPCK    OTPCK3
417aAC                   endif
     *
417aAC                   endif
     *
417bAC                   enddo
417aAC                   update    otrec
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAK A*      For Packer's, do nothing.
PAK AC                   other
PAK A*
213 AC                   exsr      filoet
213 AC                   write     oetrec
PAK A*
PAK AC                   endsl
PAK A*
213 AC                   enddo
     *
500 A*  Add order detail box code rcds to export box code file.
500 A*
640 DC*                  if        standa = *on
500 AC     keyod         setll     ordbox
500 AC                   dou       forevr <> forevr
500 AC     keyod         reade     ordbox
500 AC                   select
500 AC                   when      %eof(ordbox)
500 AC                   leave
500 AC                   other
500aAC     keyob         chain     ordd
500aAC                   if        not %found(ordd)
500aAC                   eval      odor2 = 0
500aAC                   endif
500 AC                   exsr      filoeb
500 AC                   write     oebrec
500 AC                   endsl
500 AC                   enddo
500 A*
500 A*  Add order detail exp. date rcds to export exp. dates file.
500 A*
500 AC     keyod         setll     ordexpdte
500 AC                   dou       forevr <> forevr
500 AC     keyod         reade     ordexpdte
500 AC                   select
500 AC                   when      %eof(ordexpdte)
500 AC                   leave
500 AC                   other
500aAC     keyoe         chain     ordd
500aAC                   if        not %found(ordd)
500aAC                   eval      odor2 = 0
500aAC                   endif
500 AC                   exsr      filoee
500 AC                   write     oeerec
500 AC                   endsl
500 AC                   enddo
640 DC*                  endif
     *
510cA*  Add label recs to order detail label# export file
FRF DC*                  goto      #skipexpL
CBIbDC**                 if        client = cheney
ELLaDC**                 if        client = ellenbe
FRF AC                   if        client = FRF
CWD AC                             or client = Cashwa
510fMC     keylb93       setll     label93
510cAC                   dou       forevr <> forevr
510fMC     keylb93       reade     label93

510cAC                   select
510fMC                   when      %eof(label93)
510cAC                   leave

530 A*  Skip any adjustment label records linked to the route.
530 AC                   when      lbtype = 'A'
530 AC                   iter
530 A
510cAC                   other
510fDC*    keylb13       chain     ordd
510fDC*                  if        not %found(ordd)
510fDC*                  eval      odseq = 0
510fDC*                  endif
CBIbDC**                 if        client = cheney
CBIbDC**   keypsum4      chain     pltsum4
CBIbDC**                 if        not %found(pltsum4) or
CBIbDC**                           psgen <> 1
CBIbDC**                 iter
CBIbDC**                 endif
CBIbDC**                 endif
510cAC                   exsr      filoel
510cAC                   write     oelrec
510cAC                   endsl
510cAC                   enddo
FRF AC                   endif
ELLaAC     #skipexpL     tag
510ha*
510hA*  Add order detail piece rcds to export piece file.
510hA*
CBIbAC                   if        client = cheney
HARaAC                             or client = harbor
ELLbAC                             or client = Ellenbee
YHA AC                             or client = YHata
CWDaAC                             or client = CashWa
510hAC     keyod         setll     ordp1
510hAC                   dou       forevr <> forevr
510hAC     keyod         reade     ordp1
510hAC                   select
510hAC                   when      %eof(ordp1)
510hAC                   leave
510hAC                   other
520 AC     orplbl        chain     worklbl
520 AC                   if        not %found
520 AC                   eval      lwtype = ' '
520 AC                   eval      lwdisp = ' '
520 AC                   eval      lwtrn# = 0
520 AC                   eval      lwutyp = ' '
520 AC                   eval      lwpal# = 0
ELBdAC                   eval      lwgen  = 0
520 AC                   endif
ELBdA*
ELBdAC                   if        client = Ellenbee
ELBdA*
ELBdAC                   if            lwgen = 2
ELBdAC                             and lwtype = 'O'
ELBdA*
ELBdA*      Retrieve Truck Pallet ID for child zone items.
ELBdAC                   eval      lbpal# = 0
ELBdAC     orplbl        setll     label11
ELBdAC                   dow       forevr = forevr
ELBdAC     orplbl        reade     label11
ELBdAC                   if        %eof(label11)
ELBdAC                   leave
ELBdAC                   endif
ELBdA*
ELBdA*      Found truck pallet id in merge label.
ELBdAC                   if        lbwhse = oepwhs
ELBdAC                             and lbrte = orprid
ELBdAC                   eval      lwpal# = lbpal#
ELBdAC                   leave
ELBdAC                   endif
ELBdA*
ELBdAC                   enddo
ELBdA*
ELBdAC                   endif
ELBdA*
ELBdAC                   endif
ELBdA*
510hAC                   exsr      filoep
510hAC                   write     oeprec
510hAC                   endsl
510hAC                   enddo
CBIbAC                   endif
     *
     C     keyoh         chain     rtehed                             78
     C                   if        not *in78
     C                   eval      rhstat = '6'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rhstsd = $cvd8o
     C                   time                    rhstst
406 AC                   eval      rhexpd = $cvd8o
406 AC                   time                    rhexpt
     C                   update    rhrec
     C                   endif
     *
     *  Update order header record with upload date and time.
     *
     C                   eval      ohstat = 'C'
     C                   eval      ohsdte = today
     C                   time                    ohstim
     C                   eval      ohudte = ohsdte
     C                   eval      ohutim = ohstim
     C                   update    ohrec
     *
404 AC                   enddo
404 A*
     *
     C     bottom        tag

730bA /free
730bA   if optrax = 'Y'
740bA    and optraxinv = '9';
730bA     exsr wrtTraxXml;
730bA   endif;
730bA /end-free

     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *
     *   Define partial key for ORDD file.
     *
     C     keyod         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord
530bA*
530bA*   Define partial key for EXPFORDC file.
530bA*
530bAC     keyoec2       klist
530bAC                   kfld                    ocwhse
530bAC                   kfld                    ohcord
PAKbA*
PAKbA*   Define partial key for UCICW6 file.
PAKbA*
PAKbAC     *like         define    uciout        kyord
PAKbAC     keyuci6       klist
PAKbAC                   kfld                    ohwhse
PAKbAC                   kfld                    kyord
PAKbAC                   kfld                    odseq
PAKbAC                   kfld                    oditem
PAK A*
PAK A*   Define full key for ORDHM file.
PAK A*
PAK AC     keyhm         klist
PAK AC                   kfld                    ohwhse
PAK AC                   kfld                    ohord
PAK A*
PAK A*   Define full key for PIRITEM file.
PAK A*
PAK AC     keyit         klist
PAK AC                   kfld                    odwhse
PAK AC                   kfld                    oditem
     *
     *   Define  key for ORDH3 file.
     *
     C     keyoh         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
500aA*
500aA*   Define full key for ORDD file.
500aA*
500aAC     keyob         klist
500aAC                   kfld                    obwhse
500aAC                   kfld                    obord
500aAC                   kfld                    obseq#
500aAC                   kfld                    obitem
500aA*
500aA*   Define full key for ORDD file.
500aA*
500aAC     keyoe         klist
500aAC                   kfld                    oewhse
500aAC                   kfld                    oeord
500aAC                   kfld                    oeseq#
500aAC                   kfld                    oeitem
     *
EI  A*   Define key for PIRTRCK4 file.
EI  A*
EI  AC     keyptrck4     klist
EI  AC                   kfld                    $pwhse
EI  AC                   kfld                    $prtid
EI  AC                   kfld                    $prte
     *
222 D*   Define partial key for LABEL5 file.
     *
222 D*R         *LIKE     DEFN L5PO      KYPO
     *R                   MOVE *BLANKS   KYPO
     *R         KEYLB5    KLIST
     *R                   KFLD           OHWHSE
213 A*R                   KFLD           OHTYPE
     *R                   KFLD           OHRTE
     *R                   KFLD           KYPO
     *R                   KFLD           OHPBAT
     *
417bA*   Define partial key for LABEL90 file.
     *
417bAC     keylb9        klist
417bAC                   kfld                    otwhse
417bAC                   kfld                    ottrn#
     *
     *  Define partial key for OPTIONS file.
     *
     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode
     *
730bA*  Define partial key for OPTIONS file.
730bA*
730bAC     keyopSys      klist
730bAC                   kfld                    sysWhse
730bAC                   kfld                    opcode
     *
510cA*   Define partial key for LABEL93 file.
     *
510fMC     keylb93       klist
510fMC                   kfld                    ohwhse
510fMC                   kfld                    ohord
510fDC*                  kfld                    lbseq
510fDC*                  kfld                    lbitem
     *
CBIaA*   Define full key for PLTSUM4 file.
     *
CBIaMC     keypsum4      klist
CBIaMC                   kfld                    lbtrn#
640aA*
640aA*   Define full key for liclog6 file.
640aA*
640aAC     keyliclog     klist
640aAC                   kfld                    oefwhs
640aAC                   kfld                    ohord
640aAC                   kfld                    oefseq
640aAC                   kfld                    oefitm
640aA*
640aA*   Define full key for expfordO file
640aA*
640aAC     keyexpfordO   klist
640aAC                   kfld                    oefwhs
640aAC                   kfld                    oeford
640aAC                   kfld                    oefseq
640aAC                   kfld                    oefitm
640aAC                   kfld                    oeflot
     *
510fA*    Open client-specific files.
CBIbDC**                 if        client = Cheney
ELL AC                   if        client = Ellenbe
FRF AC                             or client = FRF
CWD AC                             or client = Cashwa
510fA*
ELL AC                   if        not %open(label93)
ELL AC                   open      label93
ELL AC                   endif
ELBdAC                   if        not %open(label11)
ELBdAC                   open      label11
ELBdAC                   endif
510fA*
ELL AC                   endif
     *
CBIbMC                   if        client = Cheney
CBIbMC                   if        not %open(pltsum4)
CBIaAC                   open      pltsum4
CBIaAC                   endif
CBIbAC                   endif
     *
CBIbAC                   if        client = Cheney
HARaAC                             or client = harbor
ELLbAC                             or client = Ellenbee
YHA AC                             or client = YHata
CWDaAC                             or client = CashWa
CBIbAC                   if        not %open(ordp1)
CBIbAC                   open      ordp1
730aMC                   if        not %open(expfordp2)
CBIbAC                   open      expfordp2
CBIbAC                   endif
CBIbAC                   endif
CBIbAC                   endif
     *
CBIbAC                   if        client = Cheney
HARbAC                             or client = Harbor
ELLbAC                             or client = Ellenbee
YHA AC                             or client = YHata
CWDaAC                             or client = CashWa
CBIbAC                   if        not %open(worklbl)
CBIbAC                   open      worklbl
CBIbAC                   endif
CBIbAC                   endif

730bA*   Get *SYSTEM options from options file.
730bA*
730bAC                   eval      opcode = '*SYSTEM '
730bAC     keyopSys      chain     options
730bAC                   if        not %found(options)
730bAC                   eval      optrax = 'N'
730bAC                   else
730bAC                   eval      opdat1 = opdata
730bAC                   endif
     *
510b *    Get Feature options from options file.
510b C                   eval      opcode = '*FEATURE'
510b C     keyop         chain     options                            79
510b C                   eval      ftropt = opdata
510b C                   if        *in79
510b C                   eval      opfeat = '2'
510b C                   endif
510b C                   if        opfeat = '3'
510b C                   eval      standa = *on
510b C                   else
510b C                   eval      standa = *off
510b C                   endif
     *
740bA*   Get *TRAX options from options file.
740bA*
740bAC                   eval      opcode = '*TRAX   '
740bAC     keyop         chain     options
740bAC                   if        not %found(options)
740bAC                   eval      optraxinv = '9'
740bAC                   else
740bAC                   eval      opdat2 = opdata
740bAC                   endif
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
PAK A*
PAK A* Open EXPSAP Export File for Packer's.
PAK AC                   eval      expdate = today
PAK AC                   time                    exptime
PAKbA*
PAK AC                   if        client = packers
PAKbA*
PAK AC                   if        not %open(sapexp)
PAK AC                   open      sapexp
PAK AC                   endif
PAKbA*
PAKbA* Open UCICW6 UCI Catchweight file for Packer's.
PAKbAC                   if        not %open(ucicw6)
PAKbAC                   open      ucicw6
PAKbAC                   endif
PAKbA*
PAK AC                   endif
     *
     C                   endsr
640aA*----------------------------------------------------------------
640aA*  clr$licinfo  Clear $licinfo data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$licinfo   begsr
640aAC                   eval      savever# = $lnver#
640aAC                   clear                   $licinfo
640aAC                   eval      $lnver# = savever#
640aA
640aAC                   eval      $lnuser = #user
640aAC                   eval      $lnpgm  = #prog
640aAC                   eval      $lnjob  = #job
640aAC                   eval      $lnjobnbr = #jobn
640aA
640aAC                   endsr

500 A*----------------------------------------------------------------
500 A*
500 A*  FILOEB  Fill export detail box code fields.
500 A*
500 AC     filoeb        begsr
500 A*
500 A*  Initialize record
500 A*
500 AC                   clear                   oebrec
500 A*
500 A*  Move fields from order detail box file to export file.
500 A*
500 AC                   eval      oebwhs = obwhse
500aDC*                  eval      oebord = obord
500aMC                   eval      oebord = oehord
500aA*
500aA*    Send Host actual sequence number if sent.
500aAC                   if        odor2 > 0
500aAC                   eval      oebsq# = odor2
500aAC                   else
500 AC                   eval      oebsq# = obseq#
500aAC                   endif
580 AC                   eval      oebitm = obitem
500 AC                   eval      oebtrn = obtran
500 AC                   eval      oeblbl = oblbl#
500 AC                   eval      oebbox = obbox#
500 A*
500 AC                   endsr
     *----------------------------------------------------------------
     *
     *  FILOEC  Fill export detail catch weight fields.
     *
     C     filoec        begsr
     *
     *  Initialize record
     *
     C                   clear                   oecrec
     *
     *  Move fields from order file to export file.
     *
     C                   eval      oecwhs = ocwhse
213 D*                    Z-ADDOCORD     OECORD
213 MC                   eval      oecord = oehord
     C                   eval      oecsq# = ocseq#
     C                   eval      oecitm = ocitem
HAL A*
HAL DC**                 if        client = Halsey
HAL A*
HAL A*      Reset catchwgt sequence counter when order line# changes.
530bAC                   if        hldordseq# <> ocseq#
530bAC                   eval      newseq     = 0
530bAC                   eval      hldordseq# = ocseq#
530bAC                   endif
HAL A*
530bAC                   eval      newseq = newseq + 1
530bAC                   if        newseq > 999
530bAC                   eval      newseq = 999
530bAC                   endif
530bAC                   eval      oecseq = newseq
530bA*
530bDC**                 else
530bDC**                 eval      oecseq = ocseq
HAL DC**                 endif
HAL A*
409 AC                   eval      oectrn = octran
     C                   eval      oecwgt = occwgt
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILOED  Fill export detail fields.
     *
     C     filoed        begsr
     *
     *  Initialize record
     *
     C                   clear                   oedrec
     *
     *  Move fields from order file to export file.
     *
     C                   eval      oedwhs = odwhse
213 D*                    Z-ADDODORD     OEDORD
213 MC                   eval      oedord = oehord
     C                   eval      oedseq = odseq
     C                   eval      oeditm = oditem
     C                   eval      oedq1 = odqor1
     C                   eval      oedq2 = odqor2
     C                   eval      oedq3 = odqor3
     C                   eval      oedwh2 = odwh2
     C                   eval      oedor2 = odor2
     C                   eval      oedoit = odoitm
     C                   eval      oedqp1 = odqpk1
     C                   eval      oedqp2 = odqpk2
     C                   eval      oedqp3 = odqpk3
     C                   eval      oedspc = odspcl
     *
     C                   endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  FILOEE  Fill export detail exp. date fields.
500 A*
500 AC     filoee        begsr
500 A*
500 A*  Initialize record
500 A*
500 AC                   clear                   oeerec
500 A*
500 A*  Move fields from order detail exp date file to export file.
500 A*
500 AC                   eval      oeewhs = oewhse
500aDC*                  eval      oeeord = oeord
500aMC                   eval      oeeord = oehord
500aA*
500aA*    Send Host actual sequence number if sent.
500aAC                   if        odor2 > 0
500aAC                   eval      oeesq# = odor2
500aAC                   else
500 AC                   eval      oeesq# = oeseq#
500aAC                   endif
580 AC                   eval      oeeitm = oeitem
500 AC                   eval      oeetrn = oetran
500 AC                   eval      oeelbl = oelbl#
500 AC                   eval      oeedte = oedate
500 A*
500 AC                   endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  FILOEF  Fill Lot export detail fields.
640aA*
640aAC     filoef        begsr
640aA*
640aA*  Initialize record
640aA*
640aAC                   clear                   oefrec
640aA*
640aA*  Move fields from order file to export file.
640aA*
640aAC                   eval      oefwhs = odwhse
640aAC                   eval      oeford = oehord
640aAC                   eval      oefseq = odseq
640aAC                   eval      oefitm = oditem
640aA*
640aA*  get lot number.
640aA*
640aAc     keyliclog     setll     liclog6
640aAc                   dow       forever = forever
640aAc     keyliclog     reade     liclog6
640aAc                   if        %eof(liclog6)
640aAc                   leave
640aAc                   endif
640aA * continue on to get lot# from licinfo
640aA
640aAC                   exsr      clr$licinfo
640aAC                   eval      $lnemp# = 0
640aAC                   eval      $lnuser = #user
640aAC                   eval      $lnpgm  = #prog
640aAC                   eval      $lnjob  = #job
640aAC                   eval      $lnjobnbr  = #jobn
640aAC                   eval      $lnwhse  = odwhse
640aAC                   eval      $lntype  = 'P'
640aAC                   eval      $lnlcns  = llolcns
640aAC                   eval      $lncodeu(1) = *on
640aAC                   eval      $lncode(1) = '*LOT'
640aAC                   eval      $lncseq(1) = 1
640aAC                   eval      $dricommand = '*LICINFO'
640aAC                   eval      $drisubcmd  = '%GET'
640aAC                   eval      $drisys2upd = 'D'
640aAC                   eval      chk4err = *on
640aAC                   exsr      zzzdricop
640aA
640aAC                   if        error = *on
640aAC                   leavesr
640aAC                   endif
640aA
640aAC                   if        $lncodee(1) = $driok
640aAC                             and $lnvalchr(1) <> ' '
640aAC                   eval      oeflot = %trim($lnvalchr(1))
640aA * need to load this once if get data coming back from dri
640aA * check to see if this record already exists
730aMc     keyexpfordO   chain     expfordO2
730aMc                   if        %found(expfordO2)
640aAc                   else
640aAC                   write     oefrec
640aAc                   endif
640aAC                   else
640aAC                   eval      oeflot = ' '
640aAC                   endif
640aA
640aAc                   enddo
640aA*
640aAC                   endsr
     *----------------------------------------------------------------
     *
     *  FILOEH   Fill export header fields.
     *
     C     filoeh        begsr
     *
     *  Initialize record
     *
     C                   clear                   oehrec
     *
     *  Move fields from order file to export file.
     *
     C                   eval      oehwhs = ohwhse
213 D*                    Z-ADDOHORD     OEHORD
730aMC****  730xx        eval      oehord = *blanks
730aA /free
730aA   exec sql select ohaorda into :oehord
730aA              from ordhexa
730aA             where ohawhse = :ohwhse
730aA               and ohaord = :ohord;
730aA   if sqlstt <> sqlsuccess;
730aA     oehord = %char(ohcord);
730aA   endif;
730aA /end-free
213 MC****               eval      oehord = *blanks
     C                   eval      oehtyp = ohtype
     C                   eval      oehcpo = ohcpo
740aDC***                eval      oehcus = ohcust
740aA /free
740aA       chain (ohwhse:ohcust) CustMast;
740aA       if %found(CustMast);
740aA         oehcus = cmcusta;
740aA       else;
740aA         oehcus = %char(ohcust);
740aA       endif;
740aA /end-free
     C                   eval      oehcnm = ohcnam
     C                   eval      oehca1 = ohcad1
     C                   eval      oehca2 = ohcad2
     C                   eval      oehcct = ohccty
     C                   eval      oehcst = ohcst
     C                   eval      oehczp = ohczip
222 D*R                   MOVE OHRTE     OEHRTE
222 MC                   eval      oehrte = $prte
     C                   eval      oehstp = ohstop
     C                   eval      oehtrk = ohtruk
     C                   eval      oehmis = ohmisc
AVL A*
AVL AC                   select
AVL AC                   when      client = Avalon
AVL AC                   eval      oehpbt = ohord
GLZ A*
GLZ AC                   when      client = Glazier
YHAaAC                             or client = YHata
GLZ AC                   eval      oehpbt = ohord
AVL A*
AVL AC                   other
     C                   eval      oehpbt = ohpbat
AVL AC                   endsl
AVL A*
     C                   eval      oehdte = ohsdte
     C                   eval      oehtim = ohstim
     *
EI  A*  Under certain conditions, load user id into zip code field.
EI  A*
EI  AC                   if        client = EI
EI  AC     keyptrck4     chain     pirtrck4
EI  AC                   if        %found
EI  AC                   eval      oehczp = truser
EI  AC                   endif
EI  AC                   endif
     *
     C                   endsr
510cA*----------------------------------------------------------------
510cA*
510cA*  FILOEL  Fill order detail label# export file.
510cA*
510cAC     filoel        begsr
510cA*
510cA*  Initialize record
510cA*
510cAC                   clear                   oelrec
510cA*
510cA*  Move fields from label file to export file.
510cA*
510cAC                   eval      oelwhs = lbwhse
510eDC*                  eval      oelord = lbord
510eMC                   eval      oelord = oehord
510fMC                   eval      oelsq# = lbseq
510cAC                   eval      oelitm = lbitem
510cAC                   eval      oellbl = lblbl#
510cAC                   eval      oeltyp = lbtype
510dAC                   eval      oeldsp = lbdisp
510cAC                   eval      oeltrn = lbtrn#
510cAC                   eval      oelumt = lbutyp
510cAC                   eval      oelalc = lbqalc
510cAC                   eval      oelpck = lbqpck
510dA*
510dAC                   call      'GETPALLET'
510dAC                   parm      lbwhse        $gwhse            3 0
510dAC                   parm      lbrte         $grtid            5
510dAC                   parm      'O'           $gtype            1
510dAC                   parm      lbpal#        $gplid            7 0
510dAC                   parm                    $gpal#            7 0
510dAC                   parm                    $gtzon            6
510dAC                   parm                    $gpzon            6
510dAC                   parm                    $gszon            6
510dAC                   parm                    $gcomp            1
510dAC                   parm                    $ggen             1 0
510dAC                   parm                    $gtruk           10
510dAC                   parm                    $gunld            2 0
510dAC                   parm                    $grow             2 0
510dAC                   parm                    $gcol             1 0
510dAC                   parm                    $gstp1            2 0
510dAC                   parm                    $gstp2            2 0
510dAC                   parm                    $gpcs             5 0
510dAC                   parm                    $gcube            7 3
510dAC                   parm                    $gswgt            9 2
510dAC                   parm                    $gbcnt            1 0
510dAC                   parm                    $gflag            1
510dAC                   parm                    $glbl#            7 0
510dAC                   parm                    $gtrn#            7 0
510dAC                   parm                    $greturn          8
510dA*
510dAC                   eval      oelpal = $gpal#
510cA*
510cAC                   endsr
510gA*----------------------------------------------------------------
510gA*
510gA*  FILOEP  Fill order detail piece seq# export file.
510gA*
510gAC     filoep        begsr
510gA*
510gA*  Initialize record
510gA*
510gAC                   clear                   oeprec
510gA*
510gA*  Move fields from label file to export file.
510gA*
510gAC                   eval      oepwhs = orpwhs
510hMC                   eval      oepord = oehord
510gMC                   eval      oepsq# = orpsq#
510gAC                   eval      oepitm = orpitm
510gAC                   eval      oepup# = orpup#
510gAC                   eval      oeplbl = orplbl
510gAC                   eval      oeptyp = lwtype
510gAC                   eval      oepdsp = lwdisp
510gAC                   eval      oeptrn = lwtrn#
510gAC                   eval      oepumt = lwutyp
510gAC                   eval      oepseq = orpseq
CWDbA*
CWDbAC                   if        client = CashWa
CWDbA*       Send route id for use with off-truck delivery pgm.
CWDbAC                   eval      oepwgt = %dec($prtid:7:2)
CWDbAC                   else
CWDbA*
510gAC                   eval      oepwgt = orpwgt
CWDbAC                   endif
CWDbA*
510iAC                   eval      oepcnt = orpcnt
510iAC                   eval      oepttl = orpttl
510iAC                   eval      oepscn = orpscn
510gA*
ELBcAC                   if        client = ellenbe
ELBcAC                   eval      oeppal = lwpal#
ELBcAC                   else
510gAC                   call      'GETPALLET'
510gAC                   parm      orpwhs        $gwhse            3 0
510gAC                   parm      orprid        $grtid            5
510gAC                   parm      'O'           $gtype            1
510gAC                   parm      lwpal#        $gplid            7 0
510gAC                   parm                    $gpal#            7 0
510gAC                   parm                    $gtzon            6
510gAC                   parm                    $gpzon            6
510gAC                   parm                    $gszon            6
510gAC                   parm                    $gcomp            1
510gAC                   parm                    $ggen             1 0
510gAC                   parm                    $gtruk           10
510gAC                   parm                    $gunld            2 0
510gAC                   parm                    $grow             2 0
510gAC                   parm                    $gcol             1 0
510gAC                   parm                    $gstp1            2 0
510gAC                   parm                    $gstp2            2 0
510gAC                   parm                    $gpcs             5 0
510gAC                   parm                    $gcube            7 3
510gAC                   parm                    $gswgt            9 2
510gAC                   parm                    $gbcnt            1 0
510gAC                   parm                    $gflag            1
510gAC                   parm                    $glbl#            7 0
510gAC                   parm                    $gtrn#            7 0
510gAC                   parm                    $greturn          8
510gA*
510gAC                   eval      oeppal = $gpal#
ELBcAC                   endif
510gA*
510gAC                   endsr
213 A*----------------------------------------------------------------
213 A*
213 A*  FILOET  Fill export detail transaction fields.
213 A*
213 AC     filoet        begsr
213 A*
213 A*  Initialize record
213 A*
213 AC                   clear                   oetrec
213 A*
213 A*  Move fields from order file to export file.
213 A*
213 AC                   eval      oetwhs = otwhse
213 AC                   eval      oetord = oehord
213 AC                   eval      oetseq = otseq
213 AC                   eval      oetitm = otitem
213 AC                   eval      oettrn = ottrn#
417aAC                   eval      oetemp = otemp#
417aAC                   eval      oetpk1 = otpck1
417aAC                   eval      oetpk2 = otpck2
417aAC                   eval      oetpk3 = otpck3
213 A*
213 AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPCONTROL    Populate SAP Control Record and add to export file.
PAK A*
PAK AC     sapcontrol    begsr
PAK A*
PAK AC                   reset                   s#edi_dc40
PAK A*
PAK AC                   select
PAK AC                   when      client = packers
PAKeDC*                  eval      sap_mand    = '210'
PAKeMC                   eval      sap_mand    = '220'
PAK AC                   endsl
PAK A*
PAK AC                   eval      sap_docnum  = %editc(expdate:'X') +
PAK AC                                           %editc(exptime:'X')
PAK A*
PAK AC                   eval      sap_direct  = '2'
PAK A*
PAKcDC*                  eval      sap_rcvport = 'A000000008'
PAKcMC                   eval      sap_rcvport = 'LSMW      '
PAKcDC*                  eval      sap_rcvprn  = 'PPBFC210'
PAKcMC                   eval      sap_rcvprn  = 'DEVCLNT220'
PAK A*
PAKcDC*                  eval      sap_sndport = 'A000000008'
PAKcMC                   eval      sap_sndport = 'LSMW      '
PAKcAC                   eval      sap_sndprn  = 'DEVCLNT220'
PAK A*
PAK A*
PAK AC                   eval      sap_crtdate = %editc(expdate:'X')
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata      = s#edi_dc40
PAK A*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPDETAIL    Populate SAP Detail Record.
PAK A*
PAK AC     sapdetail     begsr
PAK A*
PAK AC                   reset                   s#e1edl24
PAK A*
PAKeAC                   eval      sap_L24mand = sap_mand
PAK AC                   if        sapcount = 1
PAK AC                   evalr     sap_posnr = %trimr(%editc(odseq:'4'))
PAK AC                   else
PAK AC                   eval      sap_posnr = ' '
PAK AC                   endif
PAK AC                   eval      sap_matnr = oditem
PAKaDC*                  eval      sap_lgort = %subst(hmmsc2:1:4)
PAKaMC                   eval      sap_lgort = pakhm1_dststg
PAKbA*
PAKbAC                   if        itcwgt   = 'Y'
PAKbAC                   eval      sap_charg = ucinbr
PAKbAC                   endif
PAKbA*
PAK A*      Customer ordered eaches.
PAK AC                   if        odqpk2 <> 0
PAK AC                   evalr     sap_lfimg = %trimr(%editc(odqpk2:'4'))
PAKfAC                   eval      sap_vrkme = 'EA'
PAK AC                   evalr     sap_lgmng = sap_lfimg
PAK AC                   eval      sap_meins = 'EA'
PAK AC                   else
PAK A*      Customer ordered cases.
PAK AC                   evalr     sap_lfimg = %trimr(%editc(odqpk1:'4'))
PAKfAC                   eval      sap_vrkme = 'CS'
PAK AC                   evalr     sap_lgmng = sap_lfimg
PAKfDC*                  eval      sap_meins = 'CV'
PAKfMC                   eval      sap_meins = 'CS'
PAK AC                   endif
PAKbA*
PAKbA*      Use actual catchweight otherwise use item ship weight.
PAKbAC                   if        itcwgt   = 'Y'
PAKbMC                   evalr     sap_ntgew = %trimr(%editc(uciwgt:'4'))
PAKfDC*                  evalr     sap_gewei = 'LB '
PAKfAC                   evalr     sap_brgew = %trimr(%editc(uciwgt:'4'))
PAKbAC                   else
PAKcDC*                  evalr     sap_ntgew = %trimr(%editc(itswgt:'4'))
PAKcMC                   evalr     sap_ntgew = ' '
PAKfDC*                  evalr     sap_gewei = '   '
PAKfAC                   evalr     sap_brgew = ' '
PAKbAC                   endif
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata      = s#e1edl24
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPDTLADD    Populate SAP Detail Additional Data Record.
PAK A*
PAK AC     sapdtladd     begsr
PAK A*
PAK AC                   reset                   s#e1edl26
PAK A*
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata      = s#e1edl26
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPHEADER    Populate SAP Header Record.
PAK A*
PAK AC     sapheader     begsr
PAK A*
PAK AC                   reset                   s#e1edl20
PAK A*
PAKeAC                   eval      sap_L20mand = sap_mand
PAKeMC                   evalr     sap_vbeln = %trimr(%subst(hmmsc5:1:9))
PAKaDC*                  eval      sap_vstel = %subst(hmmsc1:19:4)
PAKaMC                   eval      sap_vstel = pakhm2_dstshp
PAK AC                   eval      sap_podat = %editc(expdate:'X')
PAK AC                   eval      sap_potim = %editc(exptime:'X')
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata    = s#e1edl20
PAK A*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPHDRADD    Populate SAP Header Additional Data Record.
PAK A*
PAK AC     saphdradd     begsr
PAK A*
PAK AC                   reset                   s#e1edl21
PAK A*
PAKeAC                   eval      sap_L21mand = sap_mand
PAK AC                   eval      sap_lfart = %subst(hmmsc1:23:4)
PAK A*
PAK A*      Load record format into export file field.
PAK AC                   eval      spdata    = s#e1edl21
PAK A*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  SAPWRITE   Write record to SAP Export file.
PAK A*
PAK AC     sapwrite      begsr
PAK A*
PAK AC                   write     sapxrec
PAK AC                   if        %error
PAK AC                   endif
PAK A*
PAK AC                   endsr
PAK A*
730bA*----------------------------------------------------------------
730bA*  wrtTraxXml  Write Trax xml
730bA
      /free
        begsr wrtTraxXml;

          usemp# = 0;
          chain ($pwhse: $prtid) ttrte;
          if %found(ttrte);
            chain (ttrusr) piruser;
          endif;
          tr810($pwhse: $prtid: %editc(usemp#:'X'): '': '': '');

        endsr;
      /end-free

530bA*----------------------------------------------------------------
530bA*
530bA*  ZZDELW   Delete any weifhts left over from previous export found
530bA*           in EXPFORDC file.
530bA*
530bAC     zzdelw        begsr
730aDC*    keyoec2       setll     expfordc2
730aDC*                  dou       forevr <> forevr
730aDC*    keyoec2       reade     expfordc2                              76
530bA*
730aDC*                  if        *in76
730aDC*                  leave
730aDC*                  endif
530bA*
730aDC*                  delete    oecrec
730aDC*                  enddo
730aMC                   eval      *in76 = *off
530bA*
530b C                   endsr
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  ZZGETHM    Get Order Header Misc. file.
PAK A*
PAK AC     zzgethm       begsr
PAK A*
PAK AC     keyhm         chain     ordhm
PAK AC                   if        not %found(ordhm)
PAK AC                   eval      hmmsc1 = ' '
PAK AC                   eval      hmmsc2 = ' '
PAK AC                   eval      hmmsc3 = ' '
PAK AC                   eval      hmmsc4 = ' '
PAK AC                   eval      hmmsc5 = ' '
PAK AC                   endif
PAK A*
PAKaAC                   select
PAKaAC                   when      client = packers
PAKaAC                   eval      pakhm1_base = hmmsc1
PAKaAC                   eval      pakhm2_base = hmmsc2
PAKaAC                   eval      pakhm3_base = hmmsc3
PAKaAC                   eval      pakhm4_base = hmmsc4
PAKaAC                   eval      pakhm5_base = hmmsc5
PAKaAC                   endsl
PAKaA*
PAK AC                   endsr
PAK A*
PAK A*----------------------------------------------------------------
PAK A*
PAK A*  ZZGETIT    Get Item Master file.
PAK A*
PAK AC     zzgetit       begsr
PAK A*
PAK AC     keyit         chain     piritem
PAK AC                   if        not %found(piritem)
PAK AC                   eval      itum1  = '  '
PAK AC                   eval      itumq2 = 0
PAK AC                   eval      itum2  = '  '
PAK AC                   eval      itflg1 = 'N'
PAK AC                   eval      itumq3 = 0
PAK AC                   eval      itflg2 = 'N'
PAK AC                   eval      itcwgt = 'N'
PAK AC                   eval      itswgt = 0
PAK AC                   endif
PAK A*
PAK AC                   endsr
640aA*----------------------------------------------------------------
640aA*  zzzdricop  Call DRICOP
640aA*----------------------------------------------------------------
640aA
640aAC     zzzdricop     begsr
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
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
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

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on

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
     C                   endsl

     C                   eval      chk4err = *off
640aAC     enddricop     endsr
