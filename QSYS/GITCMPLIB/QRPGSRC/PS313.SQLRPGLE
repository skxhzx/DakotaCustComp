     H DFTACTGRP(*NO) ACTGRP(*caller)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     F*----------------------------------------------------------------
     F*   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     F*----------------------------------------------------------------
     F*  PS313     Truck summary
     F*  06 Sept 2018
     F*  Kenneth Elder
     F*
740AF*----------------------------------------------------------------
740AF*---  Notes:
740AF*---   If you intend to use the GUI Truck Map you must setup
740AF*--    a printer override for R30200,  This is a MRC report, not
740AF*--    a iSeries printer file.  Use option 3 on printer override
740AF*--    to direct to correct printer.  The spool file is not visible
740AF*--    using a five on wrksplf because it is hex converted from
740AF*--    PDF using ghostscript.
     F*----------------------------------------------------------------
     F*  Revisions:
     F*
     F*  05/07/00  HNK  4.14
414 AF*    - Add compartment totals
     F*
     F*
415 AF*    02/23/01  MLB  4.15
     F*      - Added REPORTS override for PS311PR.
     F*
416 AF*    06/06/02  HNK  4.16
     F*      - Print dock door number for each pallet.
     F*
417 AF*    07/14/03  MLB  4.17
     F*      - Enh: Revised program to retrieve General Pick
     F*        Options. This will be used to determine the
     F*        load/unload sequence to be printed on the report.
     F*
417aAF*    09/30/03  HNK  4.17a
     F*      - Enh: Revised program to print cases and eaches separate.
500aAF*    11/11/04  RH   5.00a
     F*      - FIX: Revised program to add each/case only if label
     F*        pallet equals pallet #.  Was adding twice if transaction
     F*        was on more than one pallet.
500bAF*    11/12/04  DAS  5.00b
     F*      - FIX: Revised program to include 'M' records because they
     F*        are included in the PLTSUM pieces.  Exclude 'B' records.
     F*      - FIX: Revised ZZPCS routine to set FOUND *ON after first
     F*        time through.
500cAF*    12/07/04  MLB/DAS  5.00c
     F*      - Fix: Revised mainline to condition ZZPCS to not run when
     F*        transaction number is zero.
500dAF*    09/14/05  MLB/HNK  5.00d
     F*      - Enh: Added custom client code support to program.
500e F*    04/04/06  HNK  5.00e
     F*      - Enh: Added total pieces field.
510a F*    06/08/07  DAS  5.10a
     F*      - Fix: Revised to identify a full page through *IN90
     F*        instead of COUNT = RECPAG. Re: RECPAG is set to 24
     F*        and COUNT is incrmented for each PLTSUM record
     F*        not each line that is printed.
     F*      - Fix: Revised to add 1 to LINE when printing normal
     F*        detail line and for each dash line that is printed.
     F*        This will allow for "Quality" and "Comment" to print
     F*        on the same line on each page. Also, zeroed LINE
     F*        for each page so "Quality" and "Comment" will print
     F*        on each page.
510b F*    09/11/07  LMC  5.10b
     F*      - Enh: Added Route Notes
510cAF*    09/11/07  MLB  5.10c
     F*      - Fix: Revised program to add bulk pick piece count into
     F*        compartment totals at end of report.
510d F*    09/19/07  LMC  5.10d
     F*      - Enh: Added Rename of time fields in RTENOTE and PLTMISC
     F*             to allow a recompile with CVTOPT = *DATETIME
     F*
520 AF*    02/05/09  CWM/MLB 5.20  01/24  02/02
     F*      - Enh: Added support for new extended stop number.
     F*        Retrieve stop # in subroutine ZZFGTS and pgm GETSTOP
520aAF*    02/13/09  MLB  5.20a
     F*      - Fix: Chg to 5.20 mod. Need to load DS stop# if $SSTP
     F*        is zero.
520bAF*    05/08/09  CWM  5.20
     F*      - Enh: CVTRPGSRC - and implemented following changes
     F*                         to current version.
520bAF*    05/08/09  CWM 5.20
     F*      - Removed individual client mods that handled temporary
     F*        override print file parms.  This will now be handled
     F*        at each client by utilizing the new Print File Override
     F*        Maintenance process RP130CL and Temp Print Override option
     F*        within report options screens.
520cAF*    09/14/09  RBD 5.20c
     F*      - Fix: Logic was added in SVLa rev for printing the route
     F*        and pallet id combination on DETAIL2, however, PS311PR
     F*        was not revised.  In addition, the new field cannot
     F*        print on DETAIL2, but must print on a new print record,
     F*        DETAIL4.
530 AF*    09/08/10  JCJ 5.30
     F*      - Enh: print "Quality" and "Comment" on bottom of report.
     F*
620 AF*    01/22/11  MLB  5.20
     F*      - Fix: Revised program to add bulk pick piece count into
     F*        compartment totals at end of report. Pgm was not adding
     F*        bulk pcs when updating compartment array for the 1st time.
     F*
650aAF*    02/01/13  LMC  6.50a
     F*      - Enh: Added Column 1 & 2 totals.
     F*
650b F*    02/11/13  GJA  6.50b
     F*      - Enh: Added ability to show weight and cube
     F*
650c F*    05/23/13  GJA  6.50c
     F*      - Enh: Added portrait
     F*
650d F*    03/13/14  JCJ  6.50d
     F*      - Fix: Skip duplicate pallet summary records created by
     F*        substitute items.
     F*
650e F*    04/16/15  GJA  6.50e
     F*      - Enh: Add compartment name to total.
     F*
700a F*    05/21/15  JCJ  7.00a
     F*      - Enh: Recompiled because of printer file change.
     F*
700bAF*    06/23/15  NLK  7.00b
     F*      - Enh: Change UDATE (jobdate) to curdate (system date)
     F*        using pgm call CVTDTE to pass parms
     F*
700c F*    08/18/15  GJA  7.00c
     F*      - Enh: Added route ID barcode
     F*
700d F*    11/22/15  GJA  7.00d
     F*      - Enh: Added dock door department  (holding mod mark)
     F*
700e F*    04/25/16  RTR  7.00e
     F*      - Fix: Check client before clearing SVLa mod fields. Was
     F*        This was causing decimal data error because SVLa alpha
     F*        field in DS0/1/2 overlays numeric field.
     *
710aA*    11/15/17  JCJ  7.10a
     *      - Enh: Added new stop/drop field.
     *
720 A*    04/11/18  KDE  7.20
     *      - Enh: Created from PS311.  It is called from PS311 when data area
     *        DRAGDROP2 is present and set to (1) *on
     *
720aA*    04/18/18  KDE  7.20a
     *      - Fix: Allow for columns beyond 3 to print in either 1, 2, or 3
     *        Add to weight and pieces instead of z-adding
     *
720bA*    04/18/18  DAS  7.20b
     *     - Changed meaning of prtflg. It now means that there is
     *       something to print, not that the last column has been
     *       filled in.
     *
720cA*    04/19/18  KDE  7.20c
     *     - Generate Compartment summary totals from type 'P' and 'B' records
     *
720dA*    05/03/18  KDE  7.20d
     *     - Print last five of SSCC numbers for Pallet in location
     *       Also reflect if position is spun by placing S> in front of pallet id
     *
720eA*    05/04/18  KDE  7.20e
     *     - Print overflow by simply filling in columns 1-3 instead
     *       of taking what comes in
     *
720fA*    05/08/18  KDE  7.20f
     *     - Change Unload Seq. to Row/Column.  Also print SPIN indicator
     *       instead of position compartment and print Pallet compartment
     *       as well as pallet number for each SSCC18/Pallet
     *
720gA*    05/31/18  KDE  7.20g
     *     - Fix:  Multiple pallets in one position were showing total
     *             piece count instead of only pieces for that pallet
     *
720hA*    09/06/18  KDE  7.20h
     *     - Enh:  Changes to make this work for max of 9 columns and
     *             write to workfile instead of printer file.  Will call
     *             MRC GUI report for actual printout
     *
720iA*    10/08/18  KDE  7.20i
     *     - Fix:  Correct printing of Stop range when nothing
     *             in pallet position
     *
720jA*    10/24/18  KDE  7.20j
     *     - Fix:  Correct issue of "O" counts being missed because
     *             PLTSUM transaction is not equal but no labels exist
     *
730aA*    04/24/19  KDE  7.30a
     *     - Fix:  Not printing last line of detail at LR when no
     *             overflow eixsts
     *
730bA*    04/25/19  DAS  7.30b
     *     - Revised to get printer for MRCRPTSCH
     *
740 A*    03/19/20  KDE  7.40
     *     - Revised to remove Bold tag from Shorts for GUI Truck Map
     *     - Revised to submit GUI Truck Map job to QS36EVOKE
     *     - Revised to print last line of Overflow
     *     - Revised to print compartment for positions with no pallets
     *
740aA*    05/01/20  KDE  7.40a
     *     - Revised to not print unload sequence per Hemant
     *
740bA*    08/26/20  KDE  7.40b
     *     - Revised cube in work file from 5.2 to 7.2
     *
750 A*    04/08/21  KDE  7.50
     *     - Revised get maxcol excluding all but psgen=1
     *     - Change code to use DDWRKFLDS for Spin pallets and
     *       merged pallets of unlike zones
     *
750aA*    05/05/21  KDE  7.50a
     *     - Revised to print child route list for Super Routes
     *       instead of stop range on GUI Truck Map
     *
750bA*    05/14/21  KDE  7.50b
     *     - Revised get stop range if weight or cube not zero
     *
750cA*    05/27/21  KDE  7.50c
     *     - Revised add have up to 18 child routes per position
     *       for super routes
     *
750dA*    06/08/21  KDE  7.50d
     *     - Revised to determine proper place to get printer queue overrides
     *
750eA*    08/11/21  KDE  7.50e
     *     - Revised to get email from BFCMRCRPRM for this GUI Truck Map
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Anderson Dubose
     F*
ADCaAF*    07/27/18  KDE   ADCa
     F*      - Do not print Row/Col in headers or detail body per Adam
     F*        Clark.  Their loaders feel the sheet is to cluttered
     F*        and Row/Col is not being used anyway
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Andrews Foodservice
     F*
AFSaAF*    07/06/10  RH    AFSa
     F*      - Loader Module:  added printing of route/pallet id
     F*        combination, which is used by the loader if the pallet
     F*        label is missing.
AFSbAF*    07/16/10  RH    AFSb
     F*      - Loader Module:  Change to print route ID on Summary line
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: BiRite
     F*
BIR AF*    09/14/05  MLB/HNK  BIR
     F*      - Revised program to ovrprtf to add copies(2) to override.
     F*        Added entry to array OVRPRT.
BIRaAF*    10/19/05  RLP  BIRa
     F*      - Revised program to print Stops with associated Pieces &
     F*        Cube.
     F*      - Added Truck Code to Header.
WSFbAF*    01/23/06  RH   WSFb
     F*      - Fix: Pallet detail info did not print for multiple stops on palle
     F*      NOT NEEDED AT BIRITE, TESTED OK 1-23-06
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Harbor
     F*
HARa F*    04/03/06  HNK  HARa
     F*      - Revised to print by stop and dept for Harbor
HARc F*    05/10/06  JCJ  HARc
     F*      - Revised ZRDTL3 to print addition detail for pallets
HARd F*    08/25/06  MLB  HARd
     F*      - Revised ZRGDPT to add additional zones to check.
     F*      - Corrected page overflow error when printing totals.
HARe F*    08/30/06  MLB  HARe
     F*      - Revised ZRGDPT to add additional zones to check.
HARf F*    09/11/07  LMC  HARf
     F*      - Revised to print LD/SD codes from PLTMISC
HARg F*    10/22/07  LMC  HARg
     F*      - Added the ability to get extra copies
HARh F*    10/24/07  LMC  HARh
     F*      - Changed extra copies from 5 to 6 in ovrprt,3
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Jakes
     F*
JFF AF*    01/26/22  KDE  JFF
     F*      - Revised to include selection zone with compartment in
     F*        first column
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Ledyard's
     F*
LED AF*    09/14/05  MLB/HNK  LED
     F*      - Revised program to ovrprtf to add copies(2) to override.
     F*        Added Ledyard's to BIR mod.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Royal
     F*
RYLaAF*    07/07/10  RH    RYLa
     F*      - Loader Module:  added printing of route/pallet id
     F*        combination, which is used by the loader if the pallet
     F*        label is missing.
RYLbAF*    07/13/10  RH    RYLb
     F*      - Loader Module:  Change to print route ID with pallet id
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Saval
     F*
     F*  NOTE: Check if other clients needs SVLA change for loader mod
SVLaAF*    06/22/09  GJA   SVLa
     F*      - Loader Module:  added pringtin of route/pallet id
     F*        combination, which is used by the loader if the pallet
     F*        label is missing.
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Yhata
     F*
YHA AF*    09/14/09  RBD   YHAa
     F*      - Loader Module:  added printing of route/pallet id
     F*        combination, which is used by the loader if the pallet
     F*        label is missing.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Inter County Bakers
     F*
ICBa F*    07/11/12  GJA   ICBa
     F*      - Enh: Print ColumnsICB and Detail1ICB
ICBb F*    07/11/12  GJA   ICBb
     F*      - Enh: Print default truck on map
ICBc F*    03/24/14  RH/JCJ ICBc
     F*      - Fix: Print Totweight8 for 80 wide.
GFC  F*----------------------------------------------------------------
     F*  Client Custom Revisions: Glazier
     F*
GFCa F*    05/23/13  GJA   GFCa
     F*      - Fix: Print portrait
SBR  F*----------------------------------------------------------------
     F*  Client Custom Revisions: SBertram
     F*
SBRa F*    02/24/15  GJA   SBRa
     F*      - Fix: Print portrait
SBRb F*    02/22/21  KDE   SBRb
     F*      - Enh: Print Dock Door
PFC  F*----------------------------------------------------------------
     F*  Client Custom Revisions: Presto
     F*
PFCa F*    10/30/14  GJA   PFCa
     F*      - Fix: Print portrait
PFCb F*    11/06/14  GJA   PFCb
     F*      - Enh: Print additional lines
JSL  F*----------------------------------------------------------------
     F*  Client Custom Revisions: Julius Silvert
     F*
JSLa F*    09/10/15  GJA   JSLa
     F*      - Fix: Print portrait
EFC  F*----------------------------------------------------------------
     F*  Client Custom Revisions: Eastland
     F*
EFCa F*    12/07/13  GJA   EFCa
     F*      - Fix: Print portrait
EFCb F*    12/11/13  GJA   EFCb
     F*      - Enh: Add transportation fields to bottom
JORa F*----------------------------------------------------------------
     F*  Client Custom Revisions: I-Supply
     F*****compile with length 66  Width 80  overflow 62  pagrtt *auto
ISYa F*    08/16/11  GJA   ISYa
     F*      - Enh: Add new layout
ISYb F*    02/07/15  GJA   ISYb
     F*      - Enh: Add head180
ISYc F*    02/25/16  NLK   ISYc
     A*   - Enh: ISupply req to NOT print if truck 'STREET TRK'
HKW  F*----------------------------------------------------------------
     F*  Client Custom Revisions: HearnKirkwood
     F*
HKWa F*    09/13/13  GJA   HKWa
     F*      - Enh: Print portrait
HKWb F*    09/24/13  GJA   HKWb
     F*      - Enh: add verification section
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: MenuMaker
     F*
GMMa F*    04/20/12  GJA   GMMa
     F*      - Enh: Add new layout, just like ISupply
JORa F*----------------------------------------------------------------
JORa F*  Client Custom Revisions: Jordanos
JORa F*
JORa F*    10/31/10  RH    JORa
JORa F*      - Fix: Print HEAD2JOR for correct spacing of lines.
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Dairyland
     F*
DRY AF*    06/16/10  MLB  DRY
     F*      - Revised program to retrieve truck number from ORDHM file
     F*        and print on HEAD2DRY fmt.
     F*      - Revised program to print COLUMNSDRY format with revised
     F*        column headings.
     F*      - Added file ORDHM2 to retrieve Dairyland truck number.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: City Line
     F*
CLDaAF*    10/31/11  RBD   CLDa
     F*      - Loader Module:  added printing of route/pallet id
     F*        combination, which is used by the loader if the pallet
     F*        label is missing.
CLDbAF*    10/31/11  RBD   CLDb
     F*      - Loader Module:  Change to print route ID with pallet id
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Coastal Sunbelt
     F*
CSPa F*    08/26/10  GJA  CSPa
     F*      - Revised program to print truck number.
     F*
CSPb F*    08/27/10  GJA  CSPb
     F*      - Enh:  Add second page as USDA
CSPc F*    09/03/10  MLB  CSPc
     F*      - Tst:  Revised all writes to set on error indicator
     F*        so that we can test landscape, 10 cpi printing and
     F*        truncate printing greater than column 110.
     F*
CSPd F*    10/11/10  JCJ  CSPd
     F*      - Revised program to print truck number & Driver name
CSPe F*    11/18/13  JCJ  CSPe
     F*      - Revised program to use HEAD2CSP for custom changes
     F*        for V6.40 update.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Agar
     F*
ASC AF*    04/12/12  RTR   ASC
     F*      - Revised to print custom pallet number on report to match
     F*        pallet number sent to Lucas in RH156.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Reinhart Food Service
     F*
RFS AF*    02/18/13  RTR   RFS
     F*      - Revised to print trailer number in heading like with Agar
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Earls Organic Produce
     F*
EOP AF*    01/20/22  KDE   EOP
     F*      - Revised Truck Attibutes static heading
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Not on file/End of file indicator
     F*  90        Overflow Indicator
     F*  9X        Top of page and level X continues.
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FPLTSUM    IP   E           K DISK
720cAFPLTSUM2   if   E           K DISK    rename(psrec:psrec2)
720fAFPLTSUM15  if   E           K DISK    rename(psrec:psrec15)
720fAF                                     prefix(p_)
DRY AFordhm2    IF   E           K DISK
417 AFOPTIONS   IF   E           K DISK
     FWAREHS    IF   E           K DISK
     FRTEHED    IF   E           K DISK
417aAFLABEL90   IF   E           K DISK
BIRaAFPLTSTP1   IF   E           K DISK
HARa FLABEL13   IF   E           K DISK
     F                                     RENAME(LBREC:REC13)
HARb FPIRITEM   IF   E           K DISK
510bAFRTENOTE   IF   E           K DISK
HARfAFPLTMISC   IF   E           K DISK
720dAftrktmpd   if   e           k disk
ICBbAFCUSTTRK   IF   E           K DISK
650eAFtrkcomp   IF   E           K DISK
750dAfreports   if   e           k disk
750dAfrptovrdtl if   e           k disk
520bAFPS314PR   O    E             PRINTER OFLIND(*IN90)
520bAFPS313WF   uf a e           k disk
     D*----------------------------------------------------------------
     D*
     D*  Table and array
     D*
     D RECK            S              7  0 DIM(3)
HARfAD PMK             S             10    DIM(1) CTDATA PERRCD(1)
     D*
     D*  Arrays for summary
414 AD COMP            S              1    DIM(99)
414 AD NUM             S              2  0 DIM(99)
417 AD PCN             S              5  0 DIM(99)
417 AD PC1             S              5  0 DIM(99)
417 DD**                  PCS        99  5 0
414 AD CUB             S              7  3 DIM(99)
414 AD WGT             S              9  2 DIM(99)
650aAD WGT1            S              9  2 DIM(99)
650aAD WGT2            S              9  2 DIM(99)
720 AD WGT3            S              9  2 DIM(99)
720 AD WGT4            S              9  2 DIM(99)
720 AD WGT5            S              9  2 DIM(99)
720 AD WGT6            S              9  2 DIM(99)
720 AD WGT7            S              9  2 DIM(99)
720 AD WGT8            S              9  2 DIM(99)
720 AD WGT9            S              9  2 DIM(99)
SVLaAD RTPA            S              7    DIM(99)
BIRaAD*
BIRaAD*  Arrays for stop/pallet summary
BIRaAD SCMP            S              1    DIM(9999)
BIRaAD SCOL            S              1  0 DIM(9999)
BIRaAD SROW            S              2  0 DIM(9999)
BIRaAD SPID            S              7  0 DIM(9999)
BIRaAD SSTP            S              2  0 DIM(9999)
BIRaAD SPCS            S              5  0 DIM(9999)
BIRaAD SCUB            S              7  3 DIM(9999)
HARa D COMB            S             12    DIM(9999)
HARa D STDP            S              7    DIM(9999)
720bAD*----------------------------------------------------------------
720bAD*  Customer id
720bAD*
720bAD newRow          s               n
720bAD prvcol          s                   like(pscol)
720bAD prvrow          s                   like(psrow)
720jAD ovfcol          s                   like(pscol)
720jAD ovfrow          s                   like(psrow)
720hAd maxCol          s              1  0
500dAD*----------------------------------------------------------------
500dAD*  Customer id
500dAD*
     D @GETCL          C                   CONST('GETCLIENT')

     *----------------------------------------------------------------
     *  PS313WF - This work file is used to write detail and total
     *            lines to work file PS313WF.
     *----------------------------------------------------------------
     *
     * Detail Record Fields  - PSWRPTTP = D
     *
     *    PSWSPIN1 -  Either blank or word SPIN if pallet spun
     *    PSWPICK1 -  Row/Col, Unload Seq, or Pallet#
     *    PSWCUBE1 -  Cube for all of Position
     *    PSWSTP11 -  Beginning Stop Range
     *    PSWSTP21 -  Ending Stop Range
     *    PSWDOOR1 -  Dock Door
     *    PSWSPCS1 -  Total Piece for position
     *    PSWRTPA1 -  PSPLID and ROUT2A
     *    PSWWGT1  -  Weight for Pallet
     *    PSWSSCC1-  SSCC18 Number
     *    PSWPAL#1-  Pallet Number
     *    PSWPCMP1-  Pallet Compartment
     *    PSWSPCSP1- Pallet Quantity vs. Position QQuantity
     *    PSWPLID1  - Pallet ID
     *
     *    Fields above duplicated for array elements 2-9
     *----------------------------------------------------------------

740bDD*PSWDATAD        ds
740bDD* PSWSPIN1               1      4
740bDD* PSWPICK1               5      8
740bDD* PSWCUBE1               9     13  2
740bDD* PSWSTP11              14     16  0
740bDD* PSWSTP21              17     19  0
740bDD* PSWDOOR1              20     22  0
740bDD* PSWSPCS1              23     27  0
740bDD* PSWRTPA1              28     34
740bDD* PSWWGT1               35     40  0
740bDD* PSWSSCC1              41     47
740bDD* PSWPAL#1              48     52  0
740bDD* PSWPCMP1              53     56
740bDD* PSWPLID1              57     63
740bDD* PSWBGC1               64     70
740bDD* PSWSPIN2              71     74
740bDD* PSWPICK2              75     78
740bDD* PSWCUBE2              79     83  2
740bDD* PSWSTP12              84     86  0
740bDD* PSWSTP22              87     89  0
740bDD* PSWDOOR2              90     92  0
740bDD* PSWSPCS2              93     97  0
740bDD* PSWRTPA2              98    104
740bDD* PSWWGT2              105    110  0
740bDD* PSWSSCC2             111    117
740bDD* PSWPAL#2             118    122  0
740bDD* PSWPCMP2             123    126
740bDD* PSWPLID2             127    133
740bDD* PSWBGC2              134    140
740bDD* PSWSPIN3             141    144
740bDD* PSWPICK3             145    148
740bDD* PSWCUBE3             149    153  2
740bDD* PSWSTP13             154    156  0
740bDD* PSWSTP23             157    159  0
740bDD* PSWDOOR3             160    162  0
740bDD* PSWSPCS3             163    167  0
740bDD* PSWRTPA3             168    174
740bDD* PSWWGT3              175    180  0
740bDD* PSWSSCC3             181    187
740bDD* PSWPAL#3             188    192  0
740bDD* PSWPCMP3             193    196
740bDD* PSWPLID3             197    203
740bDD* PSWBGC3              204    210
740bDD* PSWSPIN4             211    214
740bDD* PSWPICK4             215    218
740bDD* PSWCUBE4             219    223  2
740bDD* PSWSTP14             224    226  0
740bDD* PSWSTP24             227    229  0
740bDD* PSWDOOR4             230    232  0
740bDD* PSWSPCS4             233    237  0
740bDD* PSWRTPA4             238    244
740bDD* PSWWGT4              245    250  0
740bDD* PSWSSCC4             251    257
740bDD* PSWPAL#4             258    262  0
740bDD* PSWPCMP4             263    266
740bDD* PSWPLID4             267    273
740bDD* PSWBGC4              274    280
740bDD* PSWSPIN5             281    284
740bDD* PSWPICK5             285    288
740bDD* PSWCUBE5             289    293  2
740bDD* PSWSTP15             294    296  0
740bDD* PSWSTP25             297    299  0
740bDD* PSWDOOR5             300    302  0
740bDD* PSWSPCS5             303    307  0
740bDD* PSWRTPA5             308    314
740bDD* PSWWGT5              315    320  0
740bDD* PSWSSCC5             321    327
740bDD* PSWPAL#5             328    332  0
740bDD* PSWPCMP5             333    336
740bDD* PSWPLID5             337    343
740bDD* PSWBGC5              344    350
740bDD* PSWSPIN6             351    354
740bDD* PSWPICK6             355    358
740bDD* PSWCUBE6             359    363  2
740bDD* PSWSTP16             346    366  0
740bDD* PSWSTP26             367    369  0
740bDD* PSWDOOR6             370    372  0
740bDD* PSWSPCS6             373    377  0
740bDD* PSWRTPA6             378    384
740bDD* PSWWGT6              385    390  0
740bDD* PSWSSCC6             391    397
740bDD* PSWPAL#6             398    402  0
740bDD* PSWPCMP6             403    406
740bDD* PSWPLID6             407    413
740bDD* PSWBGC6              414    420
740bDD* PSWSPIN7             421    424
740bDD* PSWPICK7             425    428
740bDD* PSWCUBE7             429    433  2
740bDD* PSWSTP17             434    436  0
740bDD* PSWSTP27             437    439  0
740bDD* PSWDOOR7             440    442  0
740bDD* PSWSPCS7             443    447  0
740bDD* PSWRTPA7             448    454
740bDD* PSWWGT7              455    460  0
740bDD* PSWSSCC7             461    467
740bDD* PSWPAL#7             468    472  0
740bDD* PSWPCMP7             473    476
740bDD* PSWPLID7             477    483
740bDD* PSWBGC7              484    490
740bDD* PSWSPIN8             491    494
740bDD* PSWPICK8             495    498
740bDD* PSWCUBE8             499    503  2
740bDD* PSWSTP18             504    506  0
740bDD* PSWSTP28             507    509  0
740bDD* PSWDOOR8             510    512  0
740bDD* PSWSPCS8             513    517  0
740bDD* PSWRTPA8             518    524
740bDD* PSWWGT8              525    530  0
740bDD* PSWSSCC8             531    537
740bDD* PSWPAL#8             538    542  0
740bDD* PSWPCMP8             543    546
740bDD* PSWPLID8             547    553
740bDD* PSWBGC8              554    560
740bDD* PSWSPIN9             561    564
740bDD* PSWPICK9             565    568
740bDD* PSWCUBE9             569    573  2
740bDD* PSWSTP19             574    576  0
740bDD* PSWSTP29             577    579  0
740bDD* PSWDOOR9             580    582  0
740bDD* PSWSPCS9             583    587  0
740bDD* PSWRTPA9             588    594
740bDD* PSWWGT9              595    600  0
740bDD* PSWSSCC9             601    607
740bDD* PSWPAL#9             608    612  0
740bDD* PSWPCMP9             613    616
740bDD* PSWPLID9             617    623
740bDD* PSWBGC9              624    630
740bDD* pswdtlfill           631   1026
740bMD PSWDATAD        ds
740bMD  PSWSPIN1               1      4
740bMD  PSWPICK1               5      8
740bMD  PSWCUBE1               9     15  2
740bMD  PSWSTP11              16     18  0
740bMD  PSWSTP21              19     21  0
740bMD  PSWDOOR1              22     24  0
740bMD  PSWSPCS1              25     29  0
740bMD  PSWRTPA1              30     36
740bMD  PSWWGT1               37     42  0
740bMD  PSWSSCC1              43     49
740bMD  PSWPAL#1              50     54  0
740bMD  PSWPCMP1              55     58
740bMD  PSWPLID1              59     65
740bMD  PSWBGC1               66     72
740bMD  PSWSPIN2              73     76
740bMD  PSWPICK2              77     80
740bMD  PSWCUBE2              81     87  2
740bMD  PSWSTP12              88     90  0
740bMD  PSWSTP22              91     93  0
740bMD  PSWDOOR2              94     96  0
740bMD  PSWSPCS2              97    101  0
740bMD  PSWRTPA2             102    108
740bMD  PSWWGT2              109    114  0
740bMD  PSWSSCC2             115    121
740bMD  PSWPAL#2             122    126  0
740bMD  PSWPCMP2             127    130
740bMD  PSWPLID2             131    137
740bMD  PSWBGC2              138    144
740bMD  PSWSPIN3             145    148
740bMD  PSWPICK3             149    152
740bMD  PSWCUBE3             153    159  2
740bMD  PSWSTP13             160    162  0
740bMD  PSWSTP23             163    165  0
740bMD  PSWDOOR3             166    168  0
740bMD  PSWSPCS3             169    173  0
740bMD  PSWRTPA3             174    180
740bMD  PSWWGT3              181    186  0
740bMD  PSWSSCC3             187    193
740bMD  PSWPAL#3             194    198  0
740bMD  PSWPCMP3             199    202
740bMD  PSWPLID3             203    209
740bMD  PSWBGC3              210    216
740bMD  PSWSPIN4             217    220
740bMD  PSWPICK4             221    224
740bMD  PSWCUBE4             225    231  2
740bMD  PSWSTP14             232    234  0
740bMD  PSWSTP24             235    237  0
740bMD  PSWDOOR4             238    240  0
740bMD  PSWSPCS4             241    245  0
740bMD  PSWRTPA4             246    252
740bMD  PSWWGT4              253    258  0
740bMD  PSWSSCC4             259    265
740bMD  PSWPAL#4             266    270  0
740bMD  PSWPCMP4             271    274
740bMD  PSWPLID4             275    281
740bMD  PSWBGC4              282    288
740bMD  PSWSPIN5             289    292
740bMD  PSWPICK5             293    296
740bMD  PSWCUBE5             297    303  2
740bMD  PSWSTP15             304    306  0
740bMD  PSWSTP25             307    309  0
740bMD  PSWDOOR5             310    312  0
740bMD  PSWSPCS5             313    317  0
740bMD  PSWRTPA5             318    324
740bMD  PSWWGT5              325    330  0
740bMD  PSWSSCC5             331    337
740bMD  PSWPAL#5             338    342  0
740bMD  PSWPCMP5             343    346
740bMD  PSWPLID5             347    353
740bMD  PSWBGC5              354    360
740bMD  PSWSPIN6             361    364
740bMD  PSWPICK6             365    368
740bMD  PSWCUBE6             369    375  2
740bMD  PSWSTP16             376    378  0
740bMD  PSWSTP26             379    381  0
740bMD  PSWDOOR6             382    384  0
740bMD  PSWSPCS6             385    389  0
740bMD  PSWRTPA6             390    396
740bMD  PSWWGT6              397    402  0
740bMD  PSWSSCC6             403    409
740bMD  PSWPAL#6             410    414  0
740bMD  PSWPCMP6             415    418
740bMD  PSWPLID6             419    425
740bMD  PSWBGC6              426    432
740bMD  PSWSPIN7             423    436
740bMD  PSWPICK7             437    440
740bMD  PSWCUBE7             441    447  2
740bMD  PSWSTP17             448    450  0
740bMD  PSWSTP27             451    453  0
740bMD  PSWDOOR7             454    456  0
740bMD  PSWSPCS7             457    461  0
740bMD  PSWRTPA7             462    468
740bMD  PSWWGT7              469    474  0
740bMD  PSWSSCC7             475    481
740bMD  PSWPAL#7             482    486  0
740bMD  PSWPCMP7             487    490
740bMD  PSWPLID7             491    497
740bMD  PSWBGC7              498    504
740bMD  PSWSPIN8             505    508
740bMD  PSWPICK8             509    512
740bMD  PSWCUBE8             513    519  2
740bMD  PSWSTP18             520    522  0
740bMD  PSWSTP28             523    525  0
740bMD  PSWDOOR8             526    528  0
740bMD  PSWSPCS8             529    533  0
740bMD  PSWRTPA8             534    540
740bMD  PSWWGT8              541    546  0
740bMD  PSWSSCC8             547    553
740bMD  PSWPAL#8             554    558  0
740bMD  PSWPCMP8             559    562
740bMD  PSWPLID8             563    569
740bMD  PSWBGC8              570    576
740bMD  PSWSPIN9             577    580
740bMD  PSWPICK9             581    584
740bMD  PSWCUBE9             585    591  2
740bMD  PSWSTP19             592    594  0
740bMD  PSWSTP29             595    597  0
740bMD  PSWDOOR9             598    600  0
740bMD  PSWSPCS9             601    605  0
740bMD  PSWRTPA9             606    612
740bMD  PSWWGT9              613    618  0
740bMD  PSWSSCC9             619    625
740bMD  PSWPAL#9             626    630  0
740bMD  PSWPCMP9             631    634
740bMD  PSWPLID9             635    641
740bMD  PSWBGC9              642    648
750aAd  PSSRLST11            649    665
750aAd  PSSRLST12            666    682
750aAd  PSSRLST21            683    699
750aAd  PSSRLST22            700    716
750aAd  PSSRLST31            717    733
750aAd  PSSRLST32            734    750
750aAd  PSSRLST41            751    767
750aAd  PSSRLST42            768    784
750aAd  PSSRLST51            785    801
750aAd  PSSRLST52            802    818
750aAd  PSSRLST61            819    835
750aAd  PSSRLST62            836    852
750aAd  PSSRLST71            853    869
750aAd  PSSRLST72            870    886
750aAd  PSSRLST81            887    903
750aAd  PSSRLST82            904    920
750aAd  PSSRLST91            921    937
750aAd  PSSRLST92            936    954
740bMD  pswdtlfill           955   1026

     *----------------------------------------------------------------
     *  PS313WF - This work file is used to write detail, headings and
     *            total lines for Truck Summary
     *----------------------------------------------------------------
     *
     * Heading Line 2 from Truck Summary (HEAD2...)
     *
     *    PSWFLD1 -  Field one
     *    PSWFLD2 -  Filed two
     *    PSWFLD3 -  Filed three
     *    PSWFLD4 -  Field four
     *    PSWFLD5 -  Field five
     *    PSWFLD6 -  Field six
     *    PSWFLD7 -  Field seven
     *    PSWFLD8 -  Field eight
     *    PSWFLD9 -  Field nine
     *    PSWFLD10 - Field ten
     *
     *    This is printed right before the Coulmn Headings
     *----------------------------------------------------------------

     D PSWDATAH2       ds
     D  PSWFLD1                1     25
     D  PSWFLD2               26     50
     D  PSWFLD3               51     75
     D  PSWFLD4               76    100
     D  PSWFLD5              101    125
     D  PSWFLD6              126    150
     D  PSWFLD7              151    175
     D  PSWFLD8              176    200
     D  PSWFLD9              201    225
     D  PSWFLD10             226    250
     d  pswhead2fill         251   1026

     *----------------------------------------------------------------
     *  PS313WF - This work file is used to write detail, headings and
     *            total lines for Truck Summary
     *----------------------------------------------------------------
     *
     * Heading Line 2 from Truck Summary (COLUMNS.)
     *
     *    PSWCOL1 -  Field one
     *    PSWCOL2 -  Filed two
     *    PSWCOL3 -  Filed three
     *    PSWCOL4 -  Field four
     *    PSWCOL5 -  Field five
     *    PSWCOL6 -  Field six
     *    PSWCOL7 -  Field seven
     *    PSWCOL8 -  Field eight
     *    PSWCOL9 -  Field nine
     *    PSWCOL10 - Field ten
     *
     *    This is printed right before the Coulmn Headings
     *----------------------------------------------------------------

     D PSWDATAC        ds
     D  PSWCOL1                1     50
     D  PSWCOL2               51    100
     D  PSWCOL3              101    150
     D  PSWCOL4              151    200
     D  PSWCOL5              201    250
     D  PSWCOL6              251    300
     D  PSWCOL7              301    350
     D  PSWCOL8              351    400
     D  PSWCOL9              401    450
     D  PSWCOL10             451    500
     d  pswCol2fill          500   1026

     *----------------------------------------------------------------
     *  PS313WF - This work file is used to write detail, headings and
     *            total lines for Truck Summary
     *----------------------------------------------------------------
     *
     * Total Summary Headings (TOTCOL.)
     *
     *    PSWTOTCOL1 -  Field one
     *    PSWTOTCOL2 -  Filed two
     *    PSWTOTCOL3 -  Filed three
     *    PSWTOTCOL4 -  Field four
     *    PSWTOTCOL5 -  Field five
     *    PSWTOTCOL6 -  Field six
     *    PSWTOTCOL7 -  Field seven
     *    PSWTOTCOL8 -  Field eight
     *    PSWTOTCOL9 -  Field nine
     *    PSWTOTCOL10 - Field ten
     *
     *    This is printed right before the Coulmn Headings
     *----------------------------------------------------------------

     D PSWDATATC       ds
     D  PSWTOTCOL1             1     50
     D  PSWTOTCOL2            51    100
     D  PSWTOTCOL3           101    150
     D  PSWTOTCOL4           151    200
     D  PSWTOTCOL5           201    250
     D  PSWTOTCOL6           251    300
     D  PSWTOTCOL7           301    350
     D  PSWTOTCOL8           351    400
     D  PSWTOTCOL9           401    450
     D  PSWTCOL10            451    500
     d  pswTOTcol2f          500   1026

     *----------------------------------------------------------------
     *  PS313WF - This work file is used to write detail, headings and
     *            total lines for Truck Summary
     *----------------------------------------------------------------
     *
     * Total Summary Headings (TOTCOL.)
     *
     *    PSWTOTSUM1 -  Field one
     *    PSWTOTSUM2 -  Filed two
     *    PSWTOTSUM3 -  Filed three
     *    PSWTOTSUM4 -  Field four
     *    PSWTOTSUM5 -  Field five
     *    PSWTOTSUM6 -  Field six
     *    PSWTOTSUM7 -  Field seven
     *    PSWTOTSUM8 -  Field eight
     *    PSWTOTSUM9 -  Field nine
     *    PSWTOTSUM10 - Field ten
     *
     *    This is printed right before the Coulmn Headings
     *----------------------------------------------------------------

     D PSWDATATS       ds
     D  PSWTOTSUM1             1     50
     D  PSWTOTSUM2            51    100
     D  PSWTOTSUM3           101    150
     D  PSWTOTSUM4           151    200
     D  PSWTOTSUM5           201    250
     D  PSWTOTSUM6           251    300
     D  PSWTOTSUM7           301    350
     D  PSWTOTSUM8           351    400
     D  PSWTOTSUM9           401    450
     D  PSWTSUM10            451    500
     d  pswTSUM2f            500   1026
     D*----------------------------------------------------------------
     D*  General Data structure.
     D*
     D DS0             DS                  inz
     D  C0COMP                 1      4
     D  C0PICK                 5      8
     D  C0CUBE                 9     15  2
     D  C0STP1                16     17  0
     D  C0STP2                18     19  0
416 AD  C0DOOR                20     22  0
500e D  C0SPCS                23     27  0
SVLaAD  C0RTPA                28     34
650bAD  C0WGT                 35     40  0
     D*  Data structure for column 1.
     D*
     D DS1             DS                  OCCURS(50) inz
     D  C1COMP                 1      4
     D  C1PICK                 5      8
     D  C1CUBE                 9     15  2
     D  C1STP1                16     17  0
     D  C1STP2                18     19  0
416 AD  C1DOOR                20     22  0
500e D  C1SPCS                23     27  0
SVLaAD  C1RTPA                28     34
650bAD  C1WGT                 35     40  0
     D*
     D*  Data structure for column 2.
     D*
     D DS2             DS                  OCCURS(50) inz
     D  C2COMP                 1      4
     D  C2PICK                 5      8
     D  C2CUBE                 9     15  2
     D  C2STP1                16     17  0
     D  C2STP2                18     19  0
416 AD  C2DOOR                20     22  0
500e D  C2SPCS                23     27  0
SVLaAD  C2RTPA                28     34
650bAD  C2WGT                 35     40  0
720 AD*
720 AD*  Data structure for column 3.
720 AD*
720 AD DS3             DS                  OCCURS(50) inz
720 AD  C3COMP                 1      4
720 AD  C3PICK                 5      8
720 AD  C3CUBE                 9     15  2
720 AD  C3STP1                16     17  0
720 AD  C3STP2                18     19  0
720 AD  C3DOOR                20     22  0
720 AD  C3SPCS                23     27  0
720 AD  C3RTPA                28     34
720 AD  C3WGT                 35     40  0
720 AD*
720 AD DS4             DS                  OCCURS(50) inz
720 AD  C4COMP                 1      4
720 AD  C4PICK                 5      8
720 AD  C4CUBE                 9     15  2
720 AD  C4STP1                16     17  0
720 AD  C4STP2                18     19  0
720 AD  C4DOOR                20     22  0
720 AD  C4SPCS                23     27  0
720 AD  C4RTPA                28     34
720 AD  C4WGT                 35     40  0
720 AD*
720 AD DS5             DS                  OCCURS(50) inz
720 AD  C5COMP                 1      4
720 AD  C5PICK                 5      8
720 AD  C5CUBE                 9     15  2
720 AD  C5STP1                16     17  0
720 AD  C5STP2                18     19  0
720 AD  C5DOOR                20     22  0
720 AD  C5SPCS                23     27  0
720 AD  C5RTPA                28     34
720 AD  C5WGT                 35     40  0
720 AD*
720 AD DS6             DS                  OCCURS(50) inz
720 AD  C6COMP                 1      4
720 AD  C6PICK                 5      8
720 AD  C6CUBE                 9     15  2
720 AD  C6STP1                16     17  0
720 AD  C6STP2                18     19  0
720 AD  C6DOOR                20     22  0
720 AD  C6SPCS                23     27  0
720 AD  C6RTPA                28     34
720 AD  C6WGT                 35     40  0
720 AD*
720 AD DS7             DS                  OCCURS(50) inz
720 AD  C7COMP                 1      4
720 AD  C7PICK                 5      8
720 AD  C7CUBE                 9     15  2
720 AD  C7STP1                16     17  0
720 AD  C7STP2                18     19  0
720 AD  C7DOOR                20     22  0
720 AD  C7SPCS                23     27  0
720 AD  C7RTPA                28     34
720 AD  C7WGT                 35     40  0
720 AD*
720 AD DS8             DS                  OCCURS(50) inz
720 AD  C8COMP                 1      4
720 AD  C8PICK                 5      8
720 AD  C8CUBE                 9     15  2
720 AD  C8STP1                16     17  0
720 AD  C8STP2                18     19  0
720 AD  C8DOOR                20     22  0
720 AD  C8SPCS                23     27  0
720 AD  C8RTPA                28     34
720 AD  C8WGT                 35     40  0
720 AD*
720 AD DS9             DS                  OCCURS(50) inz
720 AD  C9COMP                 1      4
720 AD  C9PICK                 5      8
720 AD  C9CUBE                 9     15  2
720 AD  C9STP1                16     17  0
720 AD  C9STP2                18     19  0
720 AD  C9DOOR                20     22  0
720 AD  C9SPCS                23     27  0
720 AD  C9RTPA                28     34
720 AD  C9WGT                 35     40  0
HARfAD DS0H            DS
HARfAD  C0LDSD                 1      6
HARfAD DS11            DS                  OCCURS(50)
HARfAD  C1LDSD                 1      6
HARfAD DS12            DS                  OCCURS(50)
HARfAD  C2LDSD                 1      6
HARfAD DS13            DS                  OCCURS(50)
HARfAD  C3LDSD                 1      6
HARfAD DS14            DS                  OCCURS(50)
HARfAD  C4LDSD                 1      6
HARfAD DS15            DS                  OCCURS(50)
HARfAD  C5LDSD                 1      6
HARfAD DS16            DS                  OCCURS(50)
HARfAD  C6LDSD                 1      6
HARfAD DS17            DS                  OCCURS(50)
HARfAD  C7LDSD                 1      6
HARfAD DS18            DS                  OCCURS(50)
HARfAD  C8LDSD                 1      6
HARfAD DS19            DS                  OCCURS(50)
HARfAD  C9LDSD                 1      6
720dA***    Used to Accumulate SSCC18 numbers by column for each summary position
720dAd                 ds
720dAd ssccAry                             dim(9)
720dAD  sscc1                         7a   overlay(ssccary:*next)
720dAD  sscc2                         7a   overlay(ssccary:*next)
720dAD  sscc3                         7a   overlay(ssccary:*next)
720dAD  sscc4                         7a   overlay(ssccary:*next)
720dAD  sscc5                         7a   overlay(ssccary:*next)
720dAD  sscc6                         7a   overlay(ssccary:*next)
720dAD  sscc7                         7a   overlay(ssccary:*next)
720dAD  sscc8                         7a   overlay(ssccary:*next)
720dAD  sscc9                         7a   overlay(ssccary:*next)
720dA***    Used to Accumulate Pallet numbers by column for each summary position
720dAd                 ds
720dAd palAry                              dim(9)
720dAD  pal1                          5s 0 overlay(palary:*next)
720dAD  pal2                          5s 0 overlay(palary:*next)
720dAD  pal3                          5s 0 overlay(palary:*next)
720dAD  pal4                          5s 0 overlay(palary:*next)
720dAD  pal5                          5s 0 overlay(palary:*next)
720dAD  pal6                          5s 0 overlay(palary:*next)
720dAD  pal7                          5s 0 overlay(palary:*next)
720dAD  pal8                          5s 0 overlay(palary:*next)
720dAD  pal9                          5s 0 overlay(palary:*next)
720dA***    Used to Accumulate Pallet Compartment column for each summary position
720dAd                 ds
720dAd palCAry                             dim(9)
720dAD  palc1                         7a   overlay(palcary:*next)
720dAD  palc2                         7a   overlay(palcary:*next)
720dAD  palc3                         7a   overlay(palcary:*next)
720dAD  palc4                         7a   overlay(palcary:*next)
720dAD  palc5                         7a   overlay(palcary:*next)
720dAD  palc6                         7a   overlay(palcary:*next)
720dAD  palc7                         7a   overlay(palcary:*next)
720dAD  palc8                         7a   overlay(palcary:*next)
720dAD  palc9                         7a   overlay(palcary:*next)
720gA***    Used to Accumulate Pallet Compartment column for each summary position
720gAd                 ds
720gAd palcntAry                           dim(9)
720gAD  palcnt1                       5s 0 overlay(palcntAry:*next)
720gAD  palcnt2                       5s 0 overlay(palcntAry:*next)
720gAD  palcnt3                       5s 0 overlay(palcntAry:*next)
720gAD  palcnt4                       5s 0 overlay(palcntAry:*next)
720gAD  palcnt5                       5s 0 overlay(palcntAry:*next)
720gAD  palcnt6                       5s 0 overlay(palcntAry:*next)
720gAD  palcnt7                       5s 0 overlay(palcntAry:*next)
720gAD  palcnt8                       5s 0 overlay(palcntAry:*next)
720gAD  palcnt9                       5s 0 overlay(palcntAry:*next)
720hAd                 ds
720hA***    Used to Accumulate Cube by Pallet
720hAd                 ds
720hAd palcubAry                           dim(9)
740bDD* palcub1                       5s 2 overlay(palcubAry:*next)
740bDD* palcub2                       5s 2 overlay(palcubAry:*next)
740bDD* palcub3                       5s 2 overlay(palcubAry:*next)
740bDD* palcub4                       5s 2 overlay(palcubAry:*next)
740bDD* palcub5                       5s 2 overlay(palcubAry:*next)
740bDD* palcub6                       5s 2 overlay(palcubAry:*next)
740bDD* palcub7                       5s 2 overlay(palcubAry:*next)
740bDD* palcub8                       5s 2 overlay(palcubAry:*next)
740bDD* palcub9                       5s 2 overlay(palcubAry:*next)
740bMD  palcub1                       7s 2 overlay(palcubAry:*next)
740bMD  palcub2                       7s 2 overlay(palcubAry:*next)
740bMD  palcub3                       7s 2 overlay(palcubAry:*next)
740bMD  palcub4                       7s 2 overlay(palcubAry:*next)
740bMD  palcub5                       7s 2 overlay(palcubAry:*next)
740bMD  palcub6                       7s 2 overlay(palcubAry:*next)
740bMD  palcub7                       7s 2 overlay(palcubAry:*next)
740bMD  palcub8                       7s 2 overlay(palcubAry:*next)
740bMD  palcub9                       7s 2 overlay(palcubAry:*next)
720hA***    Used to Accumulate Weight by Pallet
720hAd                 ds
720hAd palwgtAry                           dim(9)
740bDD* palwgt1                       6s 2 overlay(palwgtAry:*next)
740bDD* palwgt2                       6s 2 overlay(palwgtAry:*next)
740bDD* palwgt3                       6s 2 overlay(palwgtAry:*next)
740bDD* palwgt4                       6s 2 overlay(palwgtAry:*next)
740bDD* palwgt5                       6s 2 overlay(palwgtAry:*next)
740bDD* palwgt6                       6s 2 overlay(palwgtAry:*next)
740bDD* palwgt7                       6s 2 overlay(palwgtAry:*next)
740bDD* palwgt8                       6s 2 overlay(palwgtAry:*next)
740bDD* palwgt9                       6s 2 overlay(palwgtAry:*next)
740bMD  palwgt1                       8s 2 overlay(palwgtAry:*next)
740bMD  palwgt2                       8s 2 overlay(palwgtAry:*next)
740bMD  palwgt3                       8s 2 overlay(palwgtAry:*next)
740bMD  palwgt4                       8s 2 overlay(palwgtAry:*next)
740bMD  palwgt5                       8s 2 overlay(palwgtAry:*next)
740bMD  palwgt6                       8s 2 overlay(palwgtAry:*next)
740bMD  palwgt7                       8s 2 overlay(palwgtAry:*next)
720hAD  palwgt8                       8s 2 overlay(palwgtAry:*next)
740bMD  palwgt9                       8s 2 overlay(palwgtAry:*next)
750aA
750aA***    Used to summarize child routes for Super Routes
750aAd arySR           ds                  qualified dim(500)
750aAD  iRowCol                       3
750aAD  First3                       17
750cAD  Second3                      17
750cAD  Third3                       17
750cAD  forth3                       17
750cAD  fifth3                       17
750cAD  sixth3                       17

     D*----------------------------------------------------------------
416 AD*
416 AD $LPARM          DS
416 AD  $LCMD                  1      8
416 AD  $LPRG                  9     18
416 AD  $LUKY                 19     68
416 AD  $LRTN                 69     76
416 AD  $LERM                 77    136
416 AD  $LMSG                 77     80
416 AD*
416 AD*   Redefine key
416 AD*
416 AD  $LWHSE                19     21  0
416 AD  $LRTID                22     26
416 AD  $LTRN#                27     33  0
416 AD  $LWHDP                34     38
416 AD  $LDOOR                39     41  0
416 AD*
417 AD*----------------------------------------------------------------
417 AD*  *GENPICK -  General picking options.
417 AD*----------------------------------------------------------------
417 AD*
417 AD* Fields
417 AD*
417 AD*    OPERPT  -  Print exception (short) error report (Y,N).
417 AD*    OPELBL  -  Print exception (short) labels (Y,N)
417 AD*    OPRFWC  -  Using RF will call (Y,N).
417 AD*    OPNRSC  -  Number of pallet sections (1-9).
417 AD*    OPHPWC  -  Host pick Will Call (Y/N).
417 AD*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
417 AD*    OPPLSQ  -  Pallet number sequence. 1=Unload, 2=Load.
417 AD*    OPEADJ  -  Close short labels without adjustment (Y,N).
417 AD*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
417 AD*
417 AD* Data structure
417 AD*
417 AD OPDATA          DS
417 AD  OPERPT                 1      1
417 AD  OPELBL                 2      2
417 AD  OPRFWC                 3      3
417 AD  OPNRSC                 4      4  0
417 AD  OPHPWC                 5      5
417 AD  OPMRGA                 6      6
417 AD  OPPLSQ                 7      7
417 AD  OPEADJ                 8      8
417 AD  OPNOPK                 9      9
417 AD  OPTEND               117    117

740 A*----------------------------------------------------------------
740 A*  *MRCRPT  -  MRC Report Scheduling Options
740 A*
740 A* Fields
740 A*
740 A*    OPIP    -  IP address for Tomcat Server
740 A*    OPPORT  -  IP Port for Tomcat Server
740 A*    OPDPRT  -  Default Printer (Used when one not supplied)
740 A*    OPGSDV  -  Ghostscript Device
740 A*    OPMUSR  -  Mrc User.  Found on iSeries and in MRC Spring Context
740 A*    OPDBSRC -  MRC Datasource for Report Calling to Use
740 A*    OPINCLDD-  Include Date in IFS filename
740 A*    OPINCLDT-  Include time in IFS filename
740 A*    OPRTDIR -  Include report name in IFS directory Structure
740 A*
740 A*----------------------------------------------------------------
740 A*
740 A* Data structure
740 A*

740 Ad optdta          ds
740 AD  opip                   1     15
740 AD  opport                16     20  0
740 AD  opdprt                21     30
740 AD  opgsdv                31     39
740 AD  opmusr                40     49
740 Ad  opcpre                50     52
740 Ad  opjobd                53     62
740 Ad  opdbsrc               63     92
740 Ad  opincldd              93     93
740 Ad  opincldt              94     94
740 Ad  oprptdir              95     95

     D*----------------------------------------------------------------
     D*
     D $PERM           DS
     D  XXERM                  1     60
     D  $PMSG                  1      4
     D*----------------------------------------------------------------
     D*
520bAD lstdev          s             10
520bAD lstfrm          s             10
520bAD lstwhs          s              3  0
RFSaAD palcnt          s              5  0
ICBaAD chkcube         S             20  0
CSPdAD driver          s             20
650bAD actqty          S              5  0
650bAD actwgt          S              6  0
740bDD*actcub          S              5  2
740bMD actcub          S              7  2
650dAD prvplid         S              7  0
720dAd ssccCnt         s              2  0
720eAd firstovl        s               n
     d backgroundclr   s              7    inz(' ')
     d c4pcmp          s              4
     d c4pal#          s              5  0
     d c4plid          s              7
     d c4stpa          s              3  0
     d c4stpb          s              3  0
     d c5pcmp          s              4
     d c5pal#          s              5  0
     d c5plid          s              7
     d c5stpa          s              3  0
     d c5stpb          s              3  0
     d c6pcmp          s              4
     d c6pal#          s              5  0
     d c6plid          s              7
     d c6stpa          s              3  0
     d c6stpb          s              3  0
     d c7pcmp          s              4
     d c7pal#          s              5  0
     d c7plid          s              7
     d c7stpa          s              3  0
     d c7stpb          s              3  0
     d c8pcmp          s              4
     d c8pal#          s              5  0
     d c8plid          s              7
     d c8stpa          s              3  0
     d c8stpb          s              3  0
     d c9pcmp          s              4
     d c9pal#          s              5  0
     d c9plid          s              7
     d c9stpa          s              3  0
     d c9stpb          s              3  0
     d totwgt4         s              9  2
     d totwgt5         s              9  2
     d totwgt6         s              9  2
     d totwgt7         s              9  2
     d totwgt8         s              9  2
     d totwgt9         s              9  2
740 Ad cmd             s           4050
750dAd forever         s               n
740 Ad sq              c                   x'7d'
740 Ad sbmusr          s             10
740 Ad sbmjobd         s             10
740 Ad sbmlibl         s             10
740 Ad wkoutq          s             10
740 Ad wkdevd          s             10
750aAd rwcol           s              3
750eAd lowerCase       c                   'abcdefghijklmnopqrstuvwxyz'
750eAd upperCase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

    *----------------------------------------------------------------
    * Additional Child Route groupings of 3 beyond 2 groups in file
    *----------------------------------------------------------------
750cAd wrkrlst13       s             17
750cAd wrkrlst14       s             17
750cAd wrkrlst15       s             17
750cAd wrkrlst16       s             17
750cAd wrkrlst23       s             17
750cAd wrkrlst24       s             17
750cAd wrkrlst25       s             17
750cAd wrkrlst26       s             17
750cAd wrkrlst33       s             17
750cAd wrkrlst34       s             17
750cAd wrkrlst35       s             17
750cAd wrkrlst36       s             17
750cAd wrkrlst43       s             17
750cAd wrkrlst44       s             17
750cAd wrkrlst45       s             17
750cAd wrkrlst46       s             17
750cAd wrkrlst53       s             17
750cAd wrkrlst54       s             17
750cAd wrkrlst55       s             17
750cAd wrkrlst56       s             17
750cAd wrkrlst63       s             17
750cAd wrkrlst64       s             17
750cAd wrkrlst65       s             17
750cAd wrkrlst66       s             17
750cAd wrkrlst73       s             17
750cAd wrkrlst74       s             17
750cAd wrkrlst75       s             17
750cAd wrkrlst76       s             17
750cAd wrkrlst83       s             17
750cAd wrkrlst84       s             17
750cAd wrkrlst85       s             17
750cAd wrkrlst86       s             17
750cAd wrkrlst93       s             17
750cAd wrkrlst94       s             17
750cAd wrkrlst95       s             17
750cAd wrkrlst96       s             17

    *----------------------------------------------------------------
    * Report Heading parameters for Truck Map GUI Report, and misc parms
    *----------------------------------------------------------------
     d calcula001      s             50
     d calcula002      s             50
     d calcula003      s             50
     d calcula004      s             50
     d calcula005      s             50
     d calcula006      s             50
     d calcula007      s             50
     d calcula008      s             50
     d calcula009      s             50
     d calcula010      s             50
     d calcula011      s             50
     d calcula012      s             50
     d calcula013      s             50
     d calcula014      s             50
     d calcula015      s             50
     d calcula016      s             50
     d calcula017      s             50
     d calcula018      s             50
     d calcula019      s             50
     d calcula020      s             50
      *  CALCULA021-font-size, CALC22 # Column Heading, CALC23-col headings total summary
      *  CALC24-Max number of column sections per the route
     d calcula021      s             50
     d calcula022      s             50
     d calcula023      s             50
     d calcula024      s             50
     d oWhse           s              3  0
     d oRptNam         s             20
     d oUrl            s           3000
     d oEmail          s           1000
     d oPrinter        s             10
     d oOrient         s              1
740 AD grStyp          s              1
740 AD grWhdp          s              5
740 AD grDesc          s             50
740 AD grDev           s             10
740 AD grForm          s             10
750aAd nsr             s              5  0
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')

750 A*----------------------------------------------------------------
750 A*  Sub-procedure prototypes
750 A*----------------------------------------------------------------

750 Ad spinMerge       pr             4
750 Ad  iRow                          2  0
750 Ad  iCol                          1  0
750 Ad  iPlid                         7p 0

750aAd setChRtes       pr
750aAd  iRow                          2  0 value
750aAd  iColnum                       1    const

750cAd insrtComma      pr            17
750cAd  iRoutes                      17

750aA*  SQL Data Struction Record to loop through Super Route Child Routes

750aAd chrec           ds            17
750aAd   chrow                        2  0 overlay(chrec)
750aAd   chcol                        1  0 overlay(chrec:*next)
750aAd   chmrte                       5    overlay(chrec:*next)
750aAd   chcnt                        5  0 overlay(chrec:*next)

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

740 AD/copy qcopysrc,p.getrpt
740 AD/copy qcopysrc,p.mrcrptsc
740 AD/copy qcopysrc,p.qcmdexc

     D*----------------------------------------------------------------
700bAD @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
700bAD $cvtdt          ds
700bAD  $cvcmd                 1      8
700bAD  $cvprg                 9     18
700bAD  $cvd6i                19     24
700bAD  $cvd8i                25     32
700bAD  $cvd6o                33     38  0
700bAD  $cvd8o                39     46  0
700bAD  $cvsto                47     64
700bAD  $cvrtn                65     72
700bAD  $cverm                73    132
700bAD  $cvmsg                73     76
     D*----------------------------------------------------------------
     D*
500dAI*
520bD ** /COPY QCOPYSRC,IL#BIRITE
520bD ** /COPY QCOPYSRC,IL#LEDYARD
520bD ** /COPY QCOPYSRC,IL#HARBOR
ADCaA /COPY QCOPYSRC,ID#ADC
JFF A /COPY QCOPYSRC,ID#JFF
EOP A /COPY QCOPYSRC,ID#EOP
520bA /COPY QCOPYSRC,ID#BIRITE
520bA /COPY QCOPYSRC,ID#LEDYARD
520bA /COPY QCOPYSRC,ID#HARBOR
SVLaA /COPY QCOPYSRC,ID#SAVAL
YHA A /COPY QCOPYSRC,ID#YHATA
RYL A /COPY QCOPYSRC,ID#ROYAL
DRY A /COPY QCOPYSRC,ID#Dairyla
IFS A /COPY QCOPYSRC,ID#ANDREWS
JORaA /COPY QCOPYSRC,ID#JORDANO
ISYaA /COPY QCOPYSRC,ID#ISUPPLY
GMMaA /COPY QCOPYSRC,ID#GMM
CLDaA /COPY QCOPYSRC,ID#CITYLIN
ICBaA /COPY QCOPYSRC,ID#ICB
GLZaA /COPY QCOPYSRC,ID#GLAZIER
HKWaA /COPY QCOPYSRC,ID#HKW
CSPbA /COPY QCOPYSRC,ID#Coastal
EFCaA /COPY QCOPYSRC,ID#Eastlan
PFCaA /COPY QCOPYSRC,ID#PFC
SBRaA /COPY QCOPYSRC,ID#SBR
ASCaA /COPY QCOPYSRC,ID#AGAR
RFSaA /COPY QCOPYSRC,ID#RFS
JSLaA /COPY QCOPYSRC,ID#JSL
510bAIRNREC
510bAI              RNADDUSR                    RNADDU
510bAI              RNADDJOB                    RNADDJ
510bAI              RNADDNBR                    RNADDN
520aMI              RNADDTS                     RNADDT
510bAI              RNCHGUSR                    RNCHGU
510bAI              RNCHGJOB                    RNCHGJ
510bAI              RNCHGNBR                    RNCHGN
520aMI              RNCHGTS                     RNCHGT
HARfAIPMREC
HARfAI              PMVALUE                     PMVAL
HARfAI              PMADDUSR                    PMADDU
HARfAI              PMADDJOB                    PMADDJ
HARfAI              PMADDNBR                    PMADDN
520aMI              PMADDTS                     PMADDT
HARfAI              PMCHGUSR                    PMCHGU
HARfAI              PMCHGJOB                    PMCHGJ
HARfAI              PMCHGNBR                    PMCHGN
520aMI              PMCHGTS                     PMCHGT
     C*----------------------------------------------------------------
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $WHSE             3 0
     C                   PARM                    $PRTID            5
HARgAC                   PARM                    $EP               1
     C*
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
650dAC                   if        psplid = prvplid
650dAC                   goto      nxtrec
650dAC                   endif
a50dAC                   eval      prvplid = psplid
720bAc*
720bAc*   See if we have jumped to a new row
720bAc*   Overflow pallets can have columns 1 - 9
720bAc*   Start new row for 4 - 6 and 7 - 9
720bAc*
720bA /free
740 A    if firstOvl = *on;
720bA      if psrow <> prvrow
720hA        or (prvcol <= maxCol and pscol > maxCol)
720hD        or (prvcol >= 5 and prvcol <= 8 and pscol > 8);
720bA          newRow = *on;
720bA      else;
720bA          newRow = *off;
720bA      endif;
740 A    else;
740 A      newRow = *off;
740 A    endif;
720bA    prvrow = psrow;
720bA    prvcol = pscol;
720bA /end-free
720aAc*
720bAc*   Adjust columns 5 - 9 to 1 - 4.
720bAc*   Overflow 'O' records use columns 1 - 9.
720aAc*
720aAc                   z-add     pscol         actcol            1 0
720aAc                   select
720aAc                   when      pscol > 8
720aAc                   eval      pscol = pscol - 8
720aAc                   when      pscol > maxCol
720aAc                   eval      pscol = pscol - maxCol
720aAc                   endsl
720eA /free
720eA       // when unload sequence is 71 or higher this is
720eA       // overflow and we should force columns 1 thru mx Column
720eA       // for given Route to prevent many lines consumed
720hA       // maxCol is set in INZSR routine
720eA       if psunld >= 71;
720hA          if firstovl=*on;
720hA             ovfcol=0;
720hA          endif;
720eA          if ovfcol = maxcol;
740 A             pscol = 1;
740 A             ovfcol = 1;
740 A             newRow = *on;
720hA             ovfrow = ovfrow + 1;
740 A             prvrow = ovfrow;
720eA             psrow = prvrow;
720eA          else;
720eA             ovfcol = ovfcol + 1;
720hA             pscol = ovfcol;
720eA          endif;
720eA          if firstovl = *off;
720jA             psrow = ovfrow;
740 A             prvrow = ovfrow;
720eA          endif;
720eA       endif;
720eA /end-free
      *
     C* Go out and get stop info and put in arrays, save pallet id's
     C*
650bAC                   eval      actqty = *zeros
650bAC                   eval      actcub = *zeros
650bAC                   eval      actwgt = *zeros
BIRaAC     CLIENT        IFEQ      BIRITE
BIRaAC     PSTRN#        IFNE      0
BIRaAC                   EXSR      ZZGSTP
BIRaAC     PSCOL         IFEQ      1
BIRaAC                   Z-ADD     PSPLID        SVPID1
BIRaAC                   ELSE
BIRaAC     PSCOL         IFEQ      2
BIRaAC                   Z-ADD     PSPLID        SVPID2
BIRaAC                   ENDIF
720 AC     PSCOL         IFEQ      3
720 AC                   Z-ADD     PSPLID        SVPID3
720 AC                   ENDIF
720hAC     PSCOL         IFEQ      4
720hAC                   Z-ADD     PSPLID        SVPID4
720hAC                   ENDIF
720hAC     PSCOL         IFEQ      5
720hAC                   Z-ADD     PSPLID        SVPID5
720hAC                   ENDIF
720hAC     PSCOL         IFEQ      6
720hAC                   Z-ADD     PSPLID        SVPID6
720hAC                   ENDIF
720hAC     PSCOL         IFEQ      7
720hAC                   Z-ADD     PSPLID        SVPID7
720hAC                   ENDIF
720hAC     PSCOL         IFEQ      8
720hAC                   Z-ADD     PSPLID        SVPID8
720hAC                   ENDIF
720hAC     PSCOL         IFEQ      9
720hAC                   Z-ADD     PSPLID        SVPID9
720hAC                   ENDIF
BIRaAC                   ENDIF
BIRaAC                   ENDIF
BIRaAC                   ENDIF
      *
     C* Go out and get stop info and put in arrays, save pallet id's
     C*
HARa C     CLIENT        IFEQ      HARBOR
HARa C     PSTRN#        IFNE      0
HARa C                   EXSR      ZZGDPT
HARa C     PSCOL         IFEQ      1
HARa C                   Z-ADD     PSPLID        SVPID1
HARa C                   ELSE
HARa C     PSCOL         IFEQ      2
HARa C                   Z-ADD     PSPLID        SVPID2
HARa C                   ENDIF
720 AC     PSCOL         IFEQ      3
720 AC                   Z-ADD     PSPLID        SVPID3
720 AC                   ENDIF
720hAC     PSCOL         IFEQ      4
720hAC                   Z-ADD     PSPLID        SVPID4
720hAC                   ENDIF
720hAC     PSCOL         IFEQ      5
720hAC                   Z-ADD     PSPLID        SVPID5
720hAC                   ENDIF
720hAC     PSCOL         IFEQ      6
720hAC                   Z-ADD     PSPLID        SVPID6
720hAC                   ENDIF
720hAC     PSCOL         IFEQ      7
720hAC                   Z-ADD     PSPLID        SVPID7
720hAC                   ENDIF
720hAC     PSCOL         IFEQ      8
720hAC                   Z-ADD     PSPLID        SVPID8
720hAC                   ENDIF
720hAC     PSCOL         IFEQ      9
720hAC                   Z-ADD     PSPLID        SVPID9
720hAC                   ENDIF
HARa C                   ENDIF
HARa C                   ENDIF
HARa C                   ENDIF
     C*
     C*    See if we should force print because of missing 2nd or 3rd column.
     C*
720bDC**   PSCOL         IFEQ      1
720bAC     newRow        IFEQ      *ON
720bDC**   PRTFLG        ANDEQ     *OFF
720bMC     PRTFLG        ANDEQ     *ON
     C     FIRST         ANDEQ     *OFF
     C                   EXSR      ZRDETL
BIRaAC     CLIENT        IFEQ      BIRITE
BIRaAC                   EXSR      ZRDTL2
BIRaAC                   ENDIF
HARa C     CLIENT        IFEQ      HARBOR
HARa C                   EXSR      ZRDTL3
HARa C                   ENDIF
     C                   ENDIF
720eAc*    If overflow pallets reached print a line to call attention
720eAc*    to the overflow pallet positions from here down
720eAc                   if        psunld >=71 and firstovl = *on
720eAc                   eval      firstovl = *off
     c*  generate work file record to indicate start of overflow.  GUI
     c*  report should print line as indicator.  Just write D as record
     c*  type and record empty other than that and key data with STROVRF as
     c*  PSWRECF which will tell GUI Report to print overflow separator line
720hAc                   clear                   pswdatad
720hAc                   eval      pswrpttp = 'D '
740 Ac                   eval      pswrecF = 'ESTROVRF'
720hAc                   exsr      wrtWFrec
740 Ac                   eval      ovfrow = pswrow + 1
740 Ac                   eval      prvrow = ovfrow
740 Ac                   eval      pswrow = ovfrow
     c                   select
     c                   when      client=dairyland
720eAc                   write     strovrfdry
     c                   write     dash2dry
     c                   other
720eAc                   write     strovrf
     c                   write     dash2
     c                   endsl
720eAc                   endif
720dA *
720dA *    Accumulate respective Pallet Id's for each position in row
720dA *
720dAc                   exsr      arraySSCC
     C*
     C*    Create a quantity string to print.
     C*
     C                   MOVE      *OFF          FIRST
     C*
HARfAC     CLIENT        IFEQ      HARBOR
HARfAC                   EXSR      ZZGTPM
HARfAC                   ENDIF
720fD *   For Drag Drop 2 we decided to print SPIN indicator in "O" type record compartment space
      /free
                   // get truck for whether position is spun
750 D              //chain (pswhse:pstruk:psrow) trktmpd;
750 D              //if not %found(trktmpd);
750 D              //   ttdspin1=' ';
750 D              //   ttdspin2=' ';
750 D              //   ttdspin3=' ';
750 D              //   ttdspin4=' ';
750 D              //   ttdspin5=' ';
750 D              //   ttdspin6=' ';
750 D              //   ttdspin7=' ';
750 D              //   ttdspin8=' ';
750 D              //   ttdspin9=' ';
750 D              //endif;
750 A              // new sub-procedure now returns S (Spin only), SM (Spin and Merge),
750 A              //                             or M (Merge only)
750 A              c0Comp = spinMerge(psRow: psCol: psPlid);
750 D              //select;
750 D                 //when pscol=1;
750 D                    //if ttdspin1 = 'Y';
750 D                       //c0comp = 'SPIN';
750 D                    //else;
750 D                       //c0comp= *blanks;
750 D                       //c0comp = ttdcomp1;
750 D                    //endif;
750 D                 //when pscol=2;
750 D                    //if ttdspin2 = 'Y';
750 D                       //c0comp = 'SPIN';
750 D                    //else;
750 D                       //c0comp = *blanks;
750 D                       //c0comp = ttdcomp2;
750 D                    //endif;
750 D                 //when pscol=3;
750 D                    //if ttdspin3 = 'Y';
750 D                       //c0comp = 'SPIN';
750 D                    //else;
750 D                       //c0comp = *blanks;
750 D                       //c0comp = ttdcomp3;
750 D                    //endif;
750 D                 //when pscol=4;
750 D                    //if ttdspin4 = 'Y';
750 D                       //c0comp = 'SPIN';
750 D                    //else;
750 D                       //c0comp = *blanks;
750 D                       //c0comp = ttdcomp4;
750 D                    //endif;
750 D                 //when pscol=5;
750 D                    //if ttdspin5 = 'Y';
750 D                       //c0comp = 'SPIN';
750 D                    //else;
750 D                       //c0comp = *blanks;
750 D                       //c0comp = ttdcomp5;
750 D                    //endif;
750 D                 //when pscol=6;
750 D                    //if ttdspin6 = 'Y';
750 D                       //c0comp = 'SPIN';
750 D                    //else;
750 D                       //c0comp = *blanks;
750 D                       //c0comp = ttdcomp6;
750 D                    //endif;
750 D                 //when pscol=7;
750 D                    //if ttdspin7 = 'Y';
750 D                       //c0comp = 'SPIN';
750 D                    //else;
750 D                       //c0comp = *blanks;
750 D                       //c0comp = ttdcomp7;
750 D                    //endif;
750 D                 //when pscol=8;
750 D                    //if ttdspin8 = 'Y';
750 D                       //c0comp = 'SPIN';
750 D                    //else;
750 D                       //c0comp = *blanks;
750 D                       //c0comp = ttdcomp8;
750 D                    //endif;
750 D                 //when pscol=9;
750 D                    //if ttdspin9 = 'Y';
750 D                       //c0comp = 'SPIN';
750 D                    //else;
750 D                       //c0comp = *blanks;
750 D                       //c0comp = ttdcomp9;
750 D                    //endif;
750 D              //endsl;
      /end-free
417 AC*
720hAC*    Pallet number or Row/Column
720fA /free
720hA                select;
720hA                  when client = agar;
720hA                    C0PICK = %char((%dec(rhrtid:5:0)*1000)
720hA                             + (psrow*10) + pscol);
ADCaA                  when client = andersondubose;
ADCaA                    c0pick = *blanks;
                       when maxCol > 2;
                         c0pick = %char(psrow) + '/' + %char(pscol);
ADCaA                  other;
740aD                    //c0pick=%char(PSunld);
740aM                    c0pick=*blanks;
720hA                endsl;
720fA /end-free
     C                   Z-ADD     PSSTP1        C0STP1
     C                   Z-ADD     PSSTP2        C0STP2
500e C*650bD             Z-ADD     PSPCS         C0SPCS
650bAC     PSTRN#        IFNE      0
657bAC                   EXSR      ZZPCSplt
720jDc*                  ELSE
720jAc                   endif
650bAC     PSTRN#        IFEQ      0
650bAC     PSBCNT        ANDGT     0
720jAC     PSTRN#        orne      0
720jAc     actqty        andeq     0
720jAc     pspcs         andgt     0
650bAC                   add(h)    PSPCS         actqty
650bAC                   add(h)    PSCUBE        actcub
650bAC                   add(h)    PSSWGT        actwgt
650bAC                   ENDIF
720jDC*                  ENDIF
650bAC                   Z-ADD     actqty        C0SPCS
650bAC                   Z-ADD     actcub        C0CUBE
650bAC                   Z-ADD     actwgt        C0WGT
     C*
SVLaAC*     Move last 2 chars of route to beginning of pallet id.
SVLaAC*
SVLaAC                   if        client=saval
YHA AC                             or client = yhata
RYLaAC                             or client = royal
ADWaAC                             or client = andrews
CLDaAC                             or client = cityline
SVLaAC                   movel     route         $CSTR
RYLbAC                   if        client=royal
RYLbAC                   movel     $prtid        $CSTR
RYLbAC                   endif
AFSaAC                   if        client=andrews
AFSaAC                   movel     $prtid        $CSTR
AFSaAC                   endif
CLDaAC                   if        client=cityline
CLDaAC                   movel     $prtid        $CSTR
CLDaAC                   endif
SVLaAC                   call      'ADJUST'
SVLaAC                   parm      '*RIGHT  '    $CCMD             8
SVLaAC                   parm                    $CSTR            30
SVLaAC                   move      $CSTR         ROUT2A            2
SVLaAC                   move      PSPLID        C0RTPA
SVLaAC                   movel     ROUT2A        C0RTPA
SVLaAC                   endif
     C*
416 AC*     Get dock door for the transaction.
416 AC*
416 AC                   Z-ADD     PSWHSE        $LWHSE
416 AC                   MOVE      PSRTID        $LRTID
416 AC                   Z-ADD     PSTRN#        $LTRN#
416 AC                   MOVE      *BLANKS       $LWHDP
416 AC                   Z-ADD     0             $LDOOR
416 AC                   CALL      'DH900'
416 AC                   PARM                    $LPARM
416 AC                   Z-ADD     $LDOOR        C0DOOR
     C*
     C*  Store info. from first record into data structure DS1.
     C*  Next record into DS2.
     C*
     C                   SELECT
     C     C1            WHENLE    RECCOL
     C     PSCOL         ANDEQ     1
     C     C1            OCCUR     DS1
     C                   MOVE      DS0           DS1
HARfAC                   MOVE      DS0H          DS11
     C                   ADD       1             C1
720bDC**                 MOVE      *OFF          PRTFLG            1
720bMC                   MOVE      *ON           PRTFLG            1
     C*
     C     C2            WHENLE    RECCOL
     C     PSCOL         ANDEQ     2
     C     C2            OCCUR     DS2
     C                   MOVE      DS0           DS2
HARfAC                   MOVE      DS0H          DS12
     C                   ADD       1             C2
     C                   MOVE      *ON           PRTFLG
     C*
720 AC     C3            WHENLE    RECCOL
720 AC     PSCOL         ANDEQ     3
720 AC     C3            OCCUR     DS3
720 AC                   MOVE      DS0           DS3
HARfAC                   MOVE      DS0H          DS13
720 AC                   ADD       1             C3
720 AC                   MOVE      *ON           PRTFLG
     C*
720 AC     C4            WHENLE    RECCOL
720 AC     PSCOL         ANDEQ     4
720 AC     C4            OCCUR     DS4
720 AC                   MOVE      DS0           DS4
HARfAC                   MOVE      DS0H          DS14
720 AC                   ADD       1             C4
720 AC                   MOVE      *ON           PRTFLG
     C*
720 AC     C5            WHENLE    RECCOL
720 AC     PSCOL         ANDEQ     5
720 AC     C5            OCCUR     DS5
720 AC                   MOVE      DS0           DS5
HARfAC                   MOVE      DS0H          DS15
720 AC                   ADD       1             C5
720 AC                   MOVE      *ON           PRTFLG
     C*
720 AC     C6            WHENLE    RECCOL
720 AC     PSCOL         ANDEQ     6
720 AC     C6            OCCUR     DS6
720 AC                   MOVE      DS0           DS6
HARfAC                   MOVE      DS0H          DS16
720 AC                   ADD       1             C6
720 AC                   MOVE      *ON           PRTFLG
     C*
720 AC     C7            WHENLE    RECCOL
720 AC     PSCOL         ANDEQ     7
720 AC     C7            OCCUR     DS7
720 AC                   MOVE      DS0           DS7
HARfAC                   MOVE      DS0H          DS17
720 AC                   ADD       1             C7
720 AC                   MOVE      *ON           PRTFLG
     C*
720 AC     C8            WHENLE    RECCOL
720 AC     PSCOL         ANDEQ     8
720 AC     C8            OCCUR     DS8
720 AC                   MOVE      DS0           DS8
HARfAC                   MOVE      DS0H          DS18
720 AC                   ADD       1             C8
720 AC                   MOVE      *ON           PRTFLG
     C*
720 AC     C9            WHENLE    RECCOL
720 AC     PSCOL         ANDEQ     9
720 AC     C9            OCCUR     DS9
720 AC                   MOVE      DS0           DS9
HARfAC                   MOVE      DS0H          DS19
720 AC                   ADD       1             C9
720 AC                   MOVE      *ON           PRTFLG
     C                   ENDSL
     C*
     C                   ADD       1             COUNT
     C*
     C*  Increment record counters
     C*
     C                   ADD       1             RECK(1)
     C*
     C*  Set off top-of-page indicators
650dAC     nxtrec        tag
     C*
     C                   MOVE      *OFF          *IN91
     C*
     C*----------------------------------------------------------------
     C*
     C* REPORT TOTALS
     C*
720bDC*R   C1            IFGT      RECCOL
720bDC*R   C2            ANDLE     RECCOL
720bDC*R   C1            ORGT      RECCOL
720bDC*R   C3            ANDLE     RECCOL
720jDC*R   PRTFLG        IFEQ      *ON
720eAc*    First off means no positions were printed on new line so
720eAc*    there is no reason to print blank line before totals
720jDc*R   first         ifeq      *off
730aAclr   firstovl      ifeq      *on
730aAclr   prtflg        andeq     *on
730aAclr                 eval      ovfcol=1
730aAclr                 endif
740 Aclr                 eval      prvrow = prvrow + 1
720jAcLR   ovfcol        ifgt      *zeros
720jAc*R   ovfcol        andlt     maxCol
     CLR                 EXSR      ZRDETL
720eAclr                 endif
720cAcLR                 exsr      zztotsum
BIRaACLR   CLIENT        IFEQ      BIRITE
BIRaACLR                 EXSR      ZRDTL2
BIRaACLR                 ENDIF
HARa CLR   CLIENT        IFEQ      HARBOR
HARa CLR                 EXSR      ZRDTL3
HARa CLR                 ENDIF
720jDC*R                 ENDIF
     CLR                 WRITE     SKIP1
     C*
     C* Print Pallet Stops Summary
     C*
BIRaACLR   CLIENT        IFEQ      BIRITE
BIRaAC**                   EXSR ZZPSTP
BIRaACLR                 ENDIF
     C*
HARdACLR   *IN90         IFEQ      *ON
650aACLR                 select
ICBaACLR                 when      client = icb
ICBaACLR                 write     head1icb                             90
GFCaACLR                 when      client = glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
ISYbAC                             or client = isupply
SBRbDC***                          or client = SBertram
700cACLR                 eval      val39 = route
GFCaACLR                 write     head180                              90
650aACLR                 other
HARdACLR                 WRITE     HEAD1                                90
ICBaACLR                 endsl
DRY AC*
JORbACLR                 SELECT
JORbDC***                if        client = Dairyland
JORbMCLR                 when      client = Dairyland
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAcLR                 clear                   pswdatah2
720hAcLR                 eval      pswrpttp = 'H '
720hAcLR                 eval      pswrecF = 'HEAD2'
720hAcLR                 exsr      wrtWFrec
DRY ACLR                 write     head2Dry                             90
GFCaACLR                 when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRbDC***                          or client = SBertram
700cACLR                 eval      val39 = route
GFCaACLR                 write     head280                              90
JORaDC***                else
JORaACLR                 when      client = Jordanos
JORaACLR                 write     head2Jor                             90
ASC ACLR                 when      client = agar
ASC AC**                 write     head2asc                             90
RFS ACLR                 when      client = rfs
RFS ACLR                 write     head2rfs                             90
ISYaACLR                 when      client = isupply or
GMMaAC                             client = menumaker
ISYaACLR                 write     head2isy                             90
ICBaACLR                 when      client = icb
ICBaACLR   keyct         chain     custtrk                              90
ICBaACLR                 if        %found(custtrk)
ICBaACLR                 eval      tknbr=cttruk
ICBaACLR                 eval      tkdrv=ctdrvr
ICBaACLR                 else
ICBaACLR                 eval      tknbr='_____'
ICBaACLR                 eval      tkdrv='__________'
ICBaACLR                 endif
ICBaACLR                 write     head2icb                             90
CSPeACLR                 when      client = coastl
CSPeACLR                 write     head2Csp                             90
JORaACLR                 other
HARdACLR                 WRITE     HEAD2                                90
JORaACLR                 endsl
JORaDC**                 endif
DRY AC*
HARdACLR                 ENDIF
HARdDC*R                   WRITETOTCOL
650aACLR                 XFOOT     WGT1          TOTWGT1
650aACLR                 XFOOT     WGT2          TOTWGT2
720 ACLR                 XFOOT     WGT3          TOTWGT3
720 ACLR                 XFOOT     WGT4          TOTWGT4
720 ACLR                 XFOOT     WGT5          TOTWGT5
720 ACLR                 XFOOT     WGT6          TOTWGT6
720 ACLR                 XFOOT     WGT7          TOTWGT7
720 ACLR                 XFOOT     WGT8          TOTWGT8
720 ACLR                 XFOOT     WGT9          TOTWGT9
650cACLR                 select
GFCaACLR                 when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
ICBcAC                             or client = icb
SBRbDC***                          or client = SBertram
GFCaACLR                 write     totweight8
GFCaMCLR                 write     totcol80                             90
ISYaACLR                 when      client = isupply or
GMMaAC                             client = menumaker
ISYaACLR                 WRITE     TOTCOLISY                            90
650cACLR                 other
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAcLR                 clear                   pswdataD
720hAcLR                 eval      pswrpttp = 'D '
740 AcLR                 eval      pswrecF = 'GTOTWGT'
720hAcLR                 exsr      wrtWFrec
     clr                 if        client = dairyland
     clr                 write     totwgtdry
     clr                 else
650aACLR                 WRITE     TOTWEIGHT
     clr                 endif
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAcLR                 clear                   pswdatah2
720hAcLR                 eval      pswrpttp = 'GH'
720hAcLR                 eval      pswrecF = 'TOTCOL'
720hAcLR                 exsr      wrtWFrec
HARdMCLR                 WRITE     TOTCOL                               90
650cACLR                 endsl
414 ACLR                 Z-ADD     0             N
414 ACLR                 DO        99            N
414 ACLR   COMP(N)       IFNE      *BLANKS
414 ACLR                 MOVEL     COMP(N)       COMPRT
414 ACLR                 Z-ADD     NUM(N)        TOTCOM
417aACLR                 Z-ADD     PCN(N)        TOTPCN
417aACLR                 Z-ADD     PC1(N)        TOTPC1
417aDC***                  Z-ADDPCS,N     TOTPCS
414 ACLR                 Z-ADD     CUB(N)        TOTCUB
414 ACLR                 Z-ADD     WGT(N)        TOTWGT
414 AC* Grand totals
414 ACLR                 ADD       NUM(N)        GOTCOM
417aACLR                 ADD       PCN(N)        GOTPCN
417aACLR                 ADD       PC1(N)        GOTPC1
417aDC***                  ADD  PCS,N     GOTPCS
414 ACLR                 ADD       CUB(N)        GOTCUB
414 ACLR                 ADD       WGT(N)        GOTWGT
HARdACLR   *IN90         IFEQ      *ON
650aACLR                 select
ICBaACLR                 when      client = icb
ICBaACLR                 write     head1icb                             90
GFCaACLR                 when      client = glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
ISYbAC                             or client = isupply
SBRbDC***                          or client = SBertram
700cACLR                 eval      val39 = route
GFCaACLR                 write     head180                              90
ICBaACLR                 other
HARdACLR                 WRITE     HEAD1                                90
650aACLR                 endsl
DRY AC*
JORaDC**                 if        client = Dairyland
JORbACLR                 SELECT
JORbMCLR                 when      client = Dairyland
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAcLR                 clear                   pswdatah2
720hAcLR                 eval      pswrpttp = 'H '
720hAcLR                 eval      pswrecF = 'HEAD2'
720hAcLR                 exsr      wrtWFrec
DRY ACLR                 write     head2Dry                             90
GFCaACLR                 when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRbDC***                          or client = SBertram
700cACLR                 eval      val39 = route
GFCaACLR                 write     head280                              90
JORaDC**                 else
JORaACLR                 when      client = Jordanos
JORaACLR                 write     head2Jor                             90
ASC ACLR                 when      client = agar
ASC AC**                 write     head2asc                             90
RFS ACLR                 when      client = rfs
RFS ACLR                 write     head2rfs                             90
ISYaACLR                 when      client = isupply or
GMMaAC                             client = menumaker
ISYaACLR                 write     head2isy                             90
ICBaACLR                 when      client = icb
ICBaACLR   keyct         chain     custtrk                              90
ICBaACLR                 if        %found(custtrk)
ICBaACLR                 eval      tknbr=cttruk
ICBaACLR                 eval      tkdrv=ctdrvr
ICBaACLR                 else
ICBaACLR                 eval      tknbr='_____'
ICBaACLR                 eval      tkdrv='__________'
ICBaACLR                 endif
ICBaACLR                 write     head2icb                             90
JORaACLR                 other
HARdACLR                 WRITE     HEAD2                                90
JORaACLR                 endsl
JORaDC**                 endif
DRY AC*
650aACLR                 XFOOT     WGT1          TOTWGT1
650aACLR                 XFOOT     WGT2          TOTWGT2
720 ACLR                 XFOOT     WGT3          TOTWGT3
720 ACLR                 XFOOT     WGT4          TOTWGT4
720 ACLR                 XFOOT     WGT5          TOTWGT5
720 ACLR                 XFOOT     WGT6          TOTWGT6
720 ACLR                 XFOOT     WGT7          TOTWGT7
720 ACLR                 XFOOT     WGT8          TOTWGT8
720 ACLR                 XFOOT     WGT9          TOTWGT9
650cACLR                 select
GFCaACLR                 when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRbDC***                          or client = SBertram
GFCaACLR                 write     totweight8
GFCaACLR                 write     totcol80                             90
ISYaACLR                 when      client = isupply or
GMMaAC                             client = menumaker
ISYaACLR                 WRITE     TOTCOLISY                            90
650cACLR                 other
     clr                 if        client=dairyland
     clr                 write     totwgtdry
     clr                 else
650aACLR                 WRITE     TOTWEIGHT
     clr                 endif
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAcLR                 clear                   pswdatah2
720hAcLR                 eval      pswrpttp = 'GH'
720hAcLR                 eval      pswrecF = 'TOTCOL'
720hAcLR                 exsr      wrtWFrec
HARdACLR                 WRITE     TOTCOL                               90
650aACLR                 endsl
HARdACLR                 ENDIF
HARdDC*R                   WRITETOTAL1
650eACLR   keytc         chain     trkcomp
650eACLR                 if        not %found(trkcomp)
650eACLR                 eval      tpdesc = *blanks
650eACLR                 endif
ISYaACLR                 select
ICBaACLR                 when      client = icb
ICBaACLR                 write     total1icb                            90
ISYaACLR                 when      client = isupply or
GMMaAC                             client = menumaker
ISYaACLR                 WRITE     TOTAL1ISY                            90
ICBaACLR                 other
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAcLR                 clear                   pswdatah2
720hAcLR                 eval      pswrpttp = 'G1'
720hAcLR                 eval      pswrecF = 'TOTAL1'
720hAcLR                 exsr      wrtWFrec
HARdMCLR                 WRITE     TOTAL1                               90
ICBaACLR                 endsl
414 ACLR                 ENDIF
414 ACLR                 ENDDO
HARdDC*R                   WRITESKIP1
HARdMCLR                 WRITE     SKIP1                                90
HARdACLR   *IN90         IFEQ      *ON
650aACLR                 select
ICBaACLR                 when      client = icb
ICBaACLR                 write     head1icb                             90
ICBaACLR                 when      client = glazier
ISYbAC                             or client = isupply
700cACLR                 eval      val39 = route
ICBaACLR                 write     head180                              90
ICBaACLR                 other
HARdACLR                 WRITE     HEAD1                                90
650aACLR                 endsl
DRY AC*
JORaDC*R                 if        client = Dairyland
JORbACLR                 SELECT
JORbMCLR                 when      client = Dairyland
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAcLR                 clear                   pswdatah2
720hAcLR                 eval      pswrpttp = 'H '
720hAcLR                 eval      pswrecF = 'HEAD2'
720hAcLR                 exsr      wrtWFrec
DRY ACLR                 write     head2Dry                             90
GFCaACLR                 when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRbDC***                          or client = SBertram
700cACLR                 eval      val39 = route
GFCaACLR                 write     head280                              90
JORaDC**                 else
JORaACLR                 when      client = Jordanos
JORaACLR                 write     head2Jor                             90
ASC ACLR                 when      client = agar
ASC AC**                 write     head2asc                             90
RFS ACLR                 when      client = rfs
RFS ACLR                 write     head2rfs                             90
ISYaACLR                 when      client = isupply or
GMMaAC                             client = menumaker
ISYaACLR                 write     head2isy                             90
ICBaACLR                 when      client = icb
ICBaACLR   keyct         chain     custtrk                              90
ICBaACLR                 if        %found(custtrk)
ICBaACLR                 eval      tknbr=cttruk
ICBaACLR                 eval      tkdrv=ctdrvr
ICBaACLR                 else
ICBaACLR                 eval      tknbr='_____'
ICBaACLR                 eval      tkdrv='__________'
ICBaACLR                 endif
ICBaACLR                 write     head2icb                             90
JORaACLR                 other
HARdACLR                 WRITE     HEAD2                                90
JORaACLR                 endsl
JORaDC**                 endif
DRY AC*
650aACLR                 XFOOT     WGT1          TOTWGT1
650aACLR                 XFOOT     WGT2          TOTWGT2
720 ACLR                 XFOOT     WGT3          TOTWGT3
720 ACLR                 XFOOT     WGT4          TOTWGT4
720 ACLR                 XFOOT     WGT5          TOTWGT5
720 ACLR                 XFOOT     WGT6          TOTWGT6
720 ACLR                 XFOOT     WGT7          TOTWGT7
720 ACLR                 XFOOT     WGT8          TOTWGT8
720 ACLR                 XFOOT     WGT9          TOTWGT9
650cACLR                 select
GFCaACLR                 when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRbDC***                          or client = SBertram
GFCaACLR                 write     totweight8
GFCaACLR                 write     totcol80                             90
ISYaACLR                 when      client = isupply or
GMMaAC                             client = menumaker
ISYaACLR                 WRITE     TOTCOLISY                            90
650cACLR                 other
     clr                 if        client=dairyland
     clr                 write     totwgtdry
     clr                 else
     clr                 if        client=dairyland
     clr                 write     totwgtdry
     clr                 else
650aACLR                 WRITE     TOTWEIGHT
     clr                 endif
     clr                 endif
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAcLR                 clear                   pswdatah2
720hAcLR                 eval      pswrpttp = 'GH'
720hAcLR                 eval      pswrecF = 'TOTCOL'
720hAcLR                 exsr      wrtWFrec
HARdACLR                 WRITE     TOTCOL                               90
650cACLR                 endsl
HARdACLR                 ENDIF
ICBaACLR                 if        client = icb
ICBaACLR                 write     total2icb                            90
ICBaACLR                 else
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAcLR                 clear                   pswdatah2
720hAcLR                 eval      pswrpttp = 'G1'
720hAcLR                 eval      pswrecF = 'TOTAL2'
720hAcLR                 exsr      wrtWFrec
414 ACLR                 WRITE     TOTAL2
ICBaACLR                 endif
     CLR                 WRITE     SKIP1
650cACLR                 select
650cACLR                 when      client = Glazier
530 ACLR                 write     quality80                            86
530 ACLR                 write     coments80                            86
650cACLR                 other
ISYaACLR                 if        client <> isupply and
GMMaAC                             client = menumaker
530 ACLR                 WRITE     QUALITY                              86
530 ACLR                 WRITE     COMENTS                              86
ISYaACLR                 endif
650cACLR                 endsl
CSPbAC**                 if        client = coastl
EFCbACLR                 select
EFCbMCLR                 when      client = coastl
CSPbACLR                 WRITE     USDA                                 86
EFCbMCLR                 when      client = eastland
CSPbACLR                 WRITE     foot1efc                             86
PFCbACLR                 when      client = presto
PFCbACLR                 WRITE     PFC1                                 86
PFCbACLR                 WRITE     PFC2                                 86
PFCbACLR                 WRITE     PFC3                                 86
CSPbAC****               endif
efcbACLR                 endsl
HKWbACLR                 select
ICBaAC*****              if        client = icb
ICBaACLR                 when      client = icb
ICBaACLR                 write     foot1icb
ICBaAC******             else
HKWbACLR                 when      client = hkw
HKWbACLR                 write     hkwvfy
HKWbACLR                 WRITE     FOOT1
HKWbACLR                 other
     CLR                 WRITE     FOOT1
ICBaAC****               endif
HKWbACLR                 endsl
720hAclr                 exsr      prtGUI
ISYcACLR   skpPrt        tag
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C     *INZSR        BEGSR
      /free
740 A          //get iSeries user and jobd from Report Scheduling
740 A          chain ($whse:'*MRCRPT') options;
740 A          if %found(options);
740 A            optdta = opdata;
740 A            sbmusr = opmusr;
740 A            sbmjobd = opjobd;
740 A            sbmlibl = '*JOBD';
740 A          else;
740 A            sbmusr = '*CURRENT';
740 A            sbmjobd = '*USRPRF';
740 A            sbmlibl = '*CURRENT';
740 A          endif;
740 A
      /end-free
500dAC*
500dAC* Get client id.
500dAC*
500dAC                   CALL      @GETCL
500dAC                   PARM                    CLIENT           10
500dAC*
ISYcAC*
ISYcAC* 1st thing, skip print if requested.
ISYcAC*
ISYcAC     RTKEY         CHAIN     RTEHED                             79
ISYcAC     *IN79         IFEQ      *OFF
ISYcAC                   if        client = isupply
ISYcAC                             and rhtruk = 'STREET TRK'
ISYcAC                   eval      *inlr = *on
ISYcAC                   goto      skpPrt
ISYcAC                   endif
ISYcAC                   endif
     C*
750aA /free
750aA    // Load array with list of child routes for each pallet if super route
750aA        clear arySR;
750aA        if %subst(rhrte:1:3)='#SR';
750aA          sqlStmt = 'select psrow,pscol,sromrte,count(*) ' +
750aA                       'from srord,worklbl,pltsum15  ' +
750aA                  'where lwwhse=srowhs and lwrte=srosrtid ' +
750aA                  'and srowhs=' + %char($whse) + ' and srosrtid=' +
750aA                  sq + $pRtid + sq + ' and pswhse=srowhs and ' +
750aA                  'psrtid=srosrtid and lwpal#=psplid ' +
750aA                  'and sromordid=lword ' +
750aA                  'and pstype=' + sq + 'P' + sq + ' and psgen=1 ' +
750aA                  'group by psrow,pscol,sromrte ' +
750aA                  'order by psrow,pscol,sromrte';
750aA          exec sql PREPARE cr FROM :SqlStmt;
750aA          exec sql DECLARE chrte SCROLL CURSOR FOR cr;
750aA          exec sql OPEN chrte;
750aA
750aA          dow Sqlstt = sqlSuccess;
750aA             exec sql fetch next from chrte into :chrow,:chcol,
750aA                                                 :chmrte,:chcnt;
750aA             if sqlStt <> sqlSuccess;
750aA               leave;
750aA             endif;
750aA             rwCol = %editc(chrow:'X') + %editc(chcol:'X');
750aA             // check to see if this rowcol already loaded
750aA             nsr = %lookup(rwCol : arySR(*).iRowCol : 1);
750aA             if nsr = 0;
750aA               // since rowcol not represented we should add to array
750aA               nsr = %lookup(' ' : arySR(*).iRowCol: 1);
750aA               arySR(nsr).iRowCol = rwCol;
750aA               %subst(arySR(nsr).First3:1:5) = %trim(chmrte);
750aA             else;
750aA               // since pallet exist we have to determine what element
750aA               // of the Child Rte array to place.  We can store up to three
750aA               // child rtes in each of 6 elements for total of 18 child routes
750cA               select;
750cA                 when %subst(arySR(nsr).First3:6:5) = *blanks;
750cA                   // load in second of three elements in first3
750cA                   %subst(arySR(nsr).First3:6:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).First3:11:5) = *blanks;
750cA                   // load in third of three elements in first3
750cA                   %subst(arySR(nsr).First3:11:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Second3:1:5) = *blanks;
750cA                   // load in first of three elements in second3
750cA                   %subst(arySR(nsr).Second3:1:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Second3:6:5) = *blanks;
750cA                   // load in second of three elements in second3
750cA                   %subst(arySR(nsr).Second3:6:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Second3:11:5) = *blanks;
750cA                   // load in third of three elements in second3
750cA                   %subst(arySR(nsr).Second3:11:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Third3:1:5) = *blanks;
750cA                   // load in first of three elements in third3
750cA                   %subst(arySR(nsr).Third3:1:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Third3:6:5) = *blanks;
750cA                   // load in second of three elements in third3
750cA                   %subst(arySR(nsr).Third3:6:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Third3:11:5) = *blanks;
750cA                   // load in third of three elements in third3
750cA                   %subst(arySR(nsr).Third3:11:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Forth3:1:5) = *blanks;
750cA                   // load in first of three elements in forth3
750cA                   %subst(arySR(nsr).Forth3:1:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Forth3:6:5) = *blanks;
750cA                   // load in second of three elements in forth3
750cA                   %subst(arySR(nsr).Forth3:6:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Forth3:11:5) = *blanks;
750cA                   // load in third of three elements in forth3
750cA                   %subst(arySR(nsr).Forth3:11:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Fifth3:1:5) = *blanks;
750cA                   // load in first of three elements in fifth3
750cA                   %subst(arySR(nsr).Fifth3:1:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Fifth3:6:5) = *blanks;
750cA                   // load in second of three elements in fifth3
750cA                   %subst(arySR(nsr).Fifth3:6:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Fifth3:11:5) = *blanks;
750cA                   // load in third of three elements in fifth3
750cA                   %subst(arySR(nsr).Fifth3:11:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Sixth3:1:5) = *blanks;
750cA                   // load in first of three elements in sixth3
750cA                   %subst(arySR(nsr).Sixth3:1:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Sixth3:6:5) = *blanks;
750cA                   // load in second of three elements in sixth3
750cA                   %subst(arySR(nsr).Sixth3:6:5) = %trim(chmrte);
750cA                 when %subst(arySR(nsr).Sixth3:11:5) = *blanks;
750cA                   // load in third of three elements in sixth3
750cA                   %subst(arySR(nsr).Sixth3:11:5) = %trim(chmrte);
750cA               endsl;
750aA             endif;
750aA          enddo;
750aA        endif;
750aA /end-free
700bA*
700bA*  Convert today's date into MMDDYY format.
700bA*
700bAC                   eval      $cvcmd = '*CURMDY '
700bAC                   call      @cvtdt
700bAC                   parm                    $cvtdt
700bAC                   eval      curdate = $cvd6o
      *
     C                   TIME                    TIME
     C                   MOVE      *ON           FIRST             1
720eAC                   MOVE      *ON           FIRSTOVL
HARA C                   MOVE      *ON           NEW               1
     C                   Z-ADD     0             COUNT             3 0
     C                   Z-ADD     3             L                 1 0
     C                   Z-ADD     1             X                 3 0
BIRaAC                   Z-ADD     1             Z                 4 0
BIRaAC                   Z-ADD     1             Z2                4 0
HARc C                   Z-ADD     1             Z3                4 0
BIRaAC                   Z-ADD     0             SAVPID            7 0
BIRaAC                   Z-ADD     0             SVPID1            7 0
BIRaAC                   Z-ADD     0             SVPID2            7 0
720 AC                   Z-ADD     0             SVPID3            7 0
720 AC                   Z-ADD     0             SVPID4            7 0
720 AC                   Z-ADD     0             SVPID5            7 0
720 AC                   Z-ADD     0             SVPID6            7 0
720 AC                   Z-ADD     0             SVPID7            7 0
720 AC                   Z-ADD     0             SVPID8            7 0
720 AC                   Z-ADD     0             SVPID9            7 0
     C                   Z-ADD     1             C1                3 0
     C                   Z-ADD     1             C2                3 0
720 AC                   Z-ADD     1             C3                3 0
720 AC                   Z-ADD     1             C4                3 0
720 AC                   Z-ADD     1             C5                3 0
720 AC                   Z-ADD     1             C6                3 0
720 AC                   Z-ADD     1             C7                3 0
720 AC                   Z-ADD     1             C8                3 0
720 AC                   Z-ADD     1             C9                3 0
     C                   Z-ADD     1             RECCOL            3 0
     C                   Z-ADD     24            RECPAG            3 0
HARA C                   Z-ADD     1             LINE              3 0
417AAC                   MOVE      *OFF          FOREVR            1
    AC*
417aAC*  Define key for LABEL90 file
    AC*
417aACSR   LBKEY         KLIST
417aACSR                 KFLD                    PSWHSE
417aACSR                 KFLD                    PSTRN#
    AC*
ICBbACSR   keyct         KLIST
ICBbACSR                 KFLD                    rhwhse
ICBbACSR                 KFLD                    rhrte
     C*
417 AC*  Define key for OPTIONS file
     C*
417 ACSR   OPSKEY        KLIST
417 ACSR                 KFLD                    OPWHSE
417 ACSR                 KFLD                    OPCODE
BIRaAC*
BIRaAC*  Define key for PLTSTP1 file
BIRaAC*
BIRaACSR   STPKEY        KLIST
BIRaACSR                 KFLD                    PSWHSE
BIRaACSR                 KFLD                    PSRTID
BIRaACSR                 KFLD                    PSPLID
     C*
HARa C*  Define key for LABEL13 file
     C*
HARa CSR   LB3KEY        KLIST
HARa CSR                 KFLD                    PSWHSE
HARa CSR                 KFLD                    PSRTID
HARa CSR                 KFLD                    PSPLID
HARa CSR                 KFLD                    PSSSTP
     C*
650eAC*  Define key for LABEL13 file
650eAC*
650eACSR   keytc         klist
650eACSR                 kfld                    $whse
650eACSR                 kfld                    comprt
417 AC*
417 AC*  Retrieve General Picking Options record.
417 AC*
417 ACSR                 Z-ADD     $WHSE         OPWHSE
417 ACSR                 MOVE      '*GENPICK'    OPCODE
417 ACSR   OPSKEY        CHAIN     OPTIONS                            79
417 ACSR   *IN79         IFEQ      *ON
417 ACSR                 MOVE      '1'           OPPLSQ
417 ACSR                 ENDIF
417 AC*
417 AC*    Set report headings.
417 AC*
720hAcsr                 select
ADCaAc                   When      client = andersondubose
ADCaAC                   MOVE      *blanks       SQTX1
ADCaAC                   MOVE      *blanks       SQTX2
ADCaAC                   MOVE      *blanks       SQTX3
ADCaAC                   MOVE      *blanks       SQTX11
ADCaAC                   MOVE      *blanks       SQTX21
ADCaAC                   MOVE      *blanks       SQTX31
720fACSR                 MOVE      'Pallt'       SQTX12
720fACSR                 MOVE      'Pallt'       SQTX22
720fACSR                 MOVE      'Pallt'       SQTX32
ADCaAc                   When      maxcol > 2
740aDC*                  MOVE      'Row/'        SQTX1
740aDC*                  MOVE      'Row/'        SQTX2
740aDC*                  MOVE      'Row/'        SQTX3
740aDC*                  MOVE      'Col/'        SQTX11
740aDC*                  MOVE      'Col/'        SQTX21
740aDC*                  MOVE      'Col/'        SQTX31
740aDC*R                 MOVE      'Pallt'       SQTX12
740aDC*R                 MOVE      'Pallt'       SQTX22
740aDC*R                 MOVE      'Pallt'       SQTX32
720hAcsr                 When      opplsq = '2'
417 ACSR                 MOVE      '  Load'      SQTX1
417 ACSR                 MOVE      '  Load'      SQTX2
720 ACSR                 MOVE      '  Load'      SQTX3
720fACSR                 MOVE      '  Seq.'      SQTX11
720fACSR                 MOVE      '  Seq.'      SQTX21
720fACSR                 MOVE      '  Seq.'      SQTX31
720hACSR                 other
417 ACSR                 MOVE      '  Unld'      SQTX1
417 ACSR                 MOVE      '  Unld'      SQTX2
720 ACSR                 MOVE      '  Unld'      SQTX3
720fACSR                 MOVE      '  Seq.'      SQTX11
720fACSR                 MOVE      '  Seq.'      SQTX21
720fACSR                 MOVE      '  Seq.'      SQTX31
720hACSR                 endsl
720fA *
DRY AC                   if        client = Dairyland
DRY AC*   Retrieve Dairyland truck number.
DRY AC     rtkey         chain     ordhm2
DRY AC                   if        not %found(ordhm2)
DRY AC                   eval      hmmsc1 = ' '
DRY AC                   endif
DRY AC                   eval      tknbr = %subst(hmmsc1:1:5)
DRY AC                   endif
DRY AC*
ASC AC*   Retrieve Agar truck number.
ASC AC                   if        client = agar
RFSaAC                             or client = rfs
ASC AC     rtkey         chain     ordhm2
ASC AC                   if        not %found(ordhm2)
ASC AC                   eval      hmmsc4 = ' '
ASC AC                   endif
ASC AC                   eval      tknbra = %subst(hmmsc4:20:10)
ASC AC                   endif
CSPdAC*
CSPdAC                   if        client = coastl
CSPdAC*   Retrieve Coastal truck number & Driver name
CSPdAC                   eval      truck = *blanks
CSPdAC                   eval      driver= *blanks
CSPdAC     rtkey         chain     ordhm2
CSPdAC                   if        not %found(ordhm2)
CSPdAC                   eval      hmmsc1 = ' '
CSPdAC                   endif
CSPdAC                   eval      truck = %subst(hmmsc1:1:10)
CSPdAC                   eval      driver= %subst(hmmsc1:11:30)
CSPdAC                   endif
DRY AC*
415 AC*
415 AC* Open printer
415 AC*
415 ACSR                 MOVE      *LOVAL        LSTWHS
415 ACSR                 Z-ADD     $WHSE         PSWHSE
720gA /free
720gA          ssccCnt = 1;
720gA          dow ssccCnt < 10;
720gA             pal1(ssccCnt) = *zeros;
720gA             pal2(ssccCnt) = *zeros;
720gA             pal3(ssccCnt) = *zeros;
720hA             pal4(ssccCnt) = *zeros;
720hA             pal5(ssccCnt) = *zeros;
720hA             pal6(ssccCnt) = *zeros;
720hA             pal7(ssccCnt) = *zeros;
720hA             pal8(ssccCnt) = *zeros;
720hA             pal9(ssccCnt) = *zeros;
720gA             palcnt1(ssccCnt) = *zeros;
720gA             palcnt2(ssccCnt) = *zeros;
720gA             palcnt3(ssccCnt) = *zeros;
720hA             palcnt4(ssccCnt) = *zeros;
720hA             palcnt5(ssccCnt) = *zeros;
720hA             palcnt6(ssccCnt) = *zeros;
720hA             palcnt7(ssccCnt) = *zeros;
720hA             palcnt8(ssccCnt) = *zeros;
720hA             palcnt9(ssccCnt) = *zeros;
720hA             palcub1(ssccCnt) = *zeros;
720hA             palcub2(ssccCnt) = *zeros;
720hA             palcub3(ssccCnt) = *zeros;
720hA             palcub4(ssccCnt) = *zeros;
720hA             palcub5(ssccCnt) = *zeros;
720hA             palcub6(ssccCnt) = *zeros;
720hA             palcub7(ssccCnt) = *zeros;
720hA             palcub8(ssccCnt) = *zeros;
720hA             palcub9(ssccCnt) = *zeros;
720hA             palwgt1(ssccCnt) = *zeros;
720hA             palwgt2(ssccCnt) = *zeros;
720hA             palwgt3(ssccCnt) = *zeros;
720hA             palwgt4(ssccCnt) = *zeros;
720hA             palwgt5(ssccCnt) = *zeros;
720hA             palwgt6(ssccCnt) = *zeros;
720hA             palwgt7(ssccCnt) = *zeros;
720hA             palwgt8(ssccCnt) = *zeros;
720hA             palwgt9(ssccCnt) = *zeros;
720gA             ssccCnt = ssccCnt + 1;
720gA          enddo;
720gA          clear ssccAry;
720fA          clear palCAry;
720hA   // get max columns for this route id
720hA          exec sql select max(pscol) into :maxcol
720hA                   from pltsum1
720hA                    where pswhse=:$whse and psrtid=:$prtid
750 D       //               and psunld<71;
750 M                      and psunld<71 and psgen=1;
720hA          if sqlstt <> '00000';
720hA             maxCol = 2;
720hA          endif;
720hA  // Remove any previous work file records for this route id
720hA          exec sql delete from ps313Wf
720hA                   where pswwhse=:$whse and pswrtid=:$prtid;
720gA /end-free
720hAc                   z-add     *zeros        RowSeq            5 0
     C                   EXSR      ZRCLER
     C                   EXSR      ZRZERO
     C                   EXSR      ZRFRMT
     C                   EXSR      ZRHEAD
     C                   ENDSR
720dAC*----------------------------------------------------------------
720dAC*
720dAC*  arraySSCC  Put all the SSCC last five digits in array to print later
720dAC*
720dAC     arraySSCC     BEGSR
      *
      *  loop through respective detail pallet id's per the summary pallet id.
      *  The "O" type is what prints on this summary report and it ends in zero.
      *  The "P" types which represent each specific pallet is represented with
      *  same 4 of summary pallet with last digit incremented up to 9
      *
      /free
             ssccCnt = 1;
             setll (pswhse:psrtid:psplid:'ADBSSCC18') pltmisc;
             read pltmisc;

             dow not %eof(pltmisc);

                if pmrtid <> psrtid or pmplid<psplid or pmwhse<>pswhse
                     or pmplid>psplid+9;
                   leave;
                endif;

                if pmcode = 'ADBSSCC18';

720fA       // get "P" record for specific pallet id
720fA              setll (pmwhse:pmrtid:pmplid) pltsum15;
720fA              read pltsum15;
720fA              dow 1=1;
720fA                 // leave if warehouse, route id or pallet id not matching
720fA                 if p_pswhse<>pmwhse or p_psrtid<>pmrtid or
720fA                            p_psplid<>pmplid;
720fA                    leave;
720fA                 endif;
720fA
720fA                 // leave once "P" type record read
720fA                 if p_pstype='P';
720fA                    leave;
720fA                 endif;
720fA
720fA                 read pltsum15;
720fA              enddo;

                   select;
                      when pscol=1;
                         sscc1(ssccCnt) = %subst(%trim(pmval):
                                          %len(%trim(pmval))-4:5);
                         sscc1(ssccCnt) = ' ' + %trim(sscc1(ssccCnt)   ) + ' ';
720fA
720fA                    pal1(ssccCnt)  = p_pspal#;
720fA                    palc1(ssccCnt) = p_pscomp;
JFF A                    if client = Jakes;
JFF A                      palc1(ssccCnt)=%trim(palc1(ssccCnt)) +
JFF A                                     '-' + %trim(p_psszon);
JFF A                    endif;
720gA                    palcnt1(ssccCnt) = p_pspcs;
720hA                    palcub1(ssccCnt) = p_pscube;
720hA                    palwgt1(ssccCnt) = p_psswgt;
720fA
                      when pscol=2;
                         sscc2(ssccCnt) = %subst(%trim(pmval):
                                          %len(%trim(pmval))-4:5);
                         sscc2(ssccCnt) = ' ' + %trim(sscc2(ssccCnt)   ) + ' ';
720fA
720fA                    pal2(ssccCnt)  = p_pspal#;
720fA                    palc2(ssccCnt) = p_pscomp;
JFF A                    if client = Jakes;
JFF A                      palc2(ssccCnt)=%trim(palc2(ssccCnt)) +
JFF A                                     '-' + %trim(p_psszon);
JFF A                    endif;
720gA                    palcnt2(ssccCnt) = p_pspcs;
720hA                    palcub2(ssccCnt) = p_pscube;
720hA                    palwgt2(ssccCnt) = p_psswgt;
720fA
                      when pscol=3;
                         sscc3(ssccCnt) = %subst(%trim(pmval):
                                          %len(%trim(pmval))-4:5);
                         sscc3(ssccCnt) = ' ' + %trim(sscc3(ssccCnt)   ) + ' ';
720fA
720fA                    pal3(ssccCnt)  = p_pspal#;
720fA                    palc3(ssccCnt) = p_pscomp;
JFF A                    if client = Jakes;
JFF A                      palc3(ssccCnt)=%trim(palc3(ssccCnt)) +
JFF A                                     '-' + %trim(p_psszon);
JFF A                    endif;
720gA                    palcnt3(ssccCnt) = p_pspcs;
720hA                    palcub3(ssccCnt) = p_pscube;
720hA                    palwgt3(ssccCnt) = p_psswgt;

                      when pscol=4;
                         sscc4(ssccCnt) = %subst(%trim(pmval):
                                          %len(%trim(pmval))-4:5);
                         sscc4(ssccCnt) = ' ' + %trim(sscc4(ssccCnt)   ) + ' ';
720fA
720fA                    pal4(ssccCnt)  = p_pspal#;
720fA                    palc4(ssccCnt) = p_pscomp;
JFF A                    if client = Jakes;
JFF A                      palc4(ssccCnt)=%trim(palc4(ssccCnt)) +
JFF A                                     '-' + %trim(p_psszon);
JFF A                    endif;
720gA                    palcnt4(ssccCnt) = p_pspcs;
720hA                    palcub4(ssccCnt) = p_pscube;
720hA                    palwgt4(ssccCnt) = p_psswgt;

                      when pscol=5;
                         sscc5(ssccCnt) = %subst(%trim(pmval):
                                          %len(%trim(pmval))-4:5);
                         sscc5(ssccCnt) = ' ' + %trim(sscc5(ssccCnt)   ) + ' ';
720fA
720fA                    pal5(ssccCnt)  = p_pspal#;
720fA                    palc5(ssccCnt) = p_pscomp;
JFF A                    if client = Jakes;
JFF A                      palc5(ssccCnt)=%trim(palc5(ssccCnt)) +
JFF A                                     '-' + %trim(p_psszon);
JFF A                    endif;
720gA                    palcnt5(ssccCnt) = p_pspcs;
720hA                    palcub5(ssccCnt) = p_pscube;
720hA                    palwgt5(ssccCnt) = p_psswgt;

                      when pscol=6;
                         sscc6(ssccCnt) = %subst(%trim(pmval):
                                          %len(%trim(pmval))-4:5);
                         sscc6(ssccCnt) = ' ' + %trim(sscc6(ssccCnt)   ) + ' ';
720fA
720fA                    pal6(ssccCnt)  = p_pspal#;
720fA                    palc6(ssccCnt) = p_pscomp;
JFF A                    if client = Jakes;
JFF A                      palc6(ssccCnt)=%trim(palc6(ssccCnt)) +
JFF A                                     '-' + %trim(p_psszon);
JFF A                    endif;
720gA                    palcnt6(ssccCnt) = p_pspcs;
720hA                    palcub6(ssccCnt) = p_pscube;
720hA                    palwgt6(ssccCnt) = p_psswgt;

                      when pscol=7;
                         sscc7(ssccCnt) = %subst(%trim(pmval):
                                          %len(%trim(pmval))-4:5);
                         sscc7(ssccCnt) = ' ' + %trim(sscc7(ssccCnt)   ) + ' ';
720fA
720fA                    pal7(ssccCnt)  = p_pspal#;
720fA                    palc7(ssccCnt) = p_pscomp;
JFF A                    if client = Jakes;
JFF A                      palc7(ssccCnt)=%trim(palc7(ssccCnt)) +
JFF A                                     '-' + %trim(p_psszon);
JFF A                    endif;
720gA                    palcnt7(ssccCnt) = p_pspcs;
720hA                    palcub7(ssccCnt) = p_pscube;
720hA                    palwgt7(ssccCnt) = p_psswgt;

                      when pscol=8;
                         sscc8(ssccCnt) = %subst(%trim(pmval):
                                          %len(%trim(pmval))-4:5);
                         sscc8(ssccCnt) = ' ' + %trim(sscc8(ssccCnt)   ) + ' ';
720fA
720fA                    pal8(ssccCnt)  = p_pspal#;
720fA                    palc8(ssccCnt) = p_pscomp;
JFF A                    if client = Jakes;
JFF A                      palc8(ssccCnt)=%trim(palc8(ssccCnt)) +
JFF A                                     '-' + %trim(p_psszon);
JFF A                    endif;
720gA                    palcnt8(ssccCnt) = p_pspcs;
720hA                    palcub8(ssccCnt) = p_pscube;
720hA                    palwgt8(ssccCnt) = p_psswgt;

                      when pscol=9;
                         sscc9(ssccCnt) = %subst(%trim(pmval):
                                          %len(%trim(pmval))-4:5);
                         sscc9(ssccCnt) = ' ' + %trim(sscc9(ssccCnt)   ) + ' ';
720fA
720fA                    pal9(ssccCnt)  = p_pspal#;
720fA                    palc9(ssccCnt) = p_pscomp;
JFF A                    if client = Jakes;
JFF A                      palc9(ssccCnt)=%trim(palc9(ssccCnt)) +
JFF A                                     '-' + %trim(p_psszon);
JFF A                    endif;
720gA                    palcnt9(ssccCnt) = p_pspcs;
720hA                    palcub9(ssccCnt) = p_pscube;
720hA                    palwgt9(ssccCnt) = p_psswgt;
720fA
                   endsl;
                   ssccCnt = ssccCnt + 1;
                endif;

                read pltmisc;

             enddo;

      /end-free
720dAC                   ENDSR
720hA *
720hAC*----------------------------------------------------------------
720hAC*
720hAC*  prtGUI  Build URL and call process to print MRC GUI Truck Map
720hAC*
720hAC     prtGUI        BEGSR
720hAC*----------------------------------------------------------------
720hA *
      /free

740 A    // Get Report information
750dD    //getrpt ('*DEVFORM': 'R30200': $whse: grStyp: grWhdp:
750dD    //     grDesc: grDev: grForm);
750dA    chain ('R30200') reports;
750dA    if %found(reports);
750dA      if rpscrn='1';
750dA        // Use Reports defined Queue
750dA        grDev = RPDEV;
750dA      else;
750dA        // otherwise look for first RPTOVRDTL
750dA        setll ('R30200') rptovrdtl;
750dA        dow forever = forever;
750dA          reade ('R30200') rptovrdtl;
750dA          if not %equal(rptovrdtl) or %eof(rptovrdtl);
750dA            // if nothing found then set to job configuration
750dA            grDev='*JOB';
750dA            leave;
750dA          endif;
750bA          if rdone<>'Y' and rdATP='Y';
750bA            select;
750bA              when rddev<>*blanks and %subst(rddev:1:1)<>'*';
750bA                grdev = rddev;
750bA                leave;
750bA              when rdoQ<>*blanks and %subst(rdoQ:1:1)<>'*';
750bA                grdev = rdoQ;
750bA                leave;
750bA            endsl;
750dA          endif;
750dA        enddo;
750bA      endif;
750dA    else;
750dA      grDev = '*JOB';
750dA    endif;

740 A    // now check to see if an one time override exist
740 A    // This would normally be performed in RPT120 but
740 A    // since the GUI version cannot use printer file
740 A    // overrides for the MRC report we need to handle here
740 A    exec sql select rdoq,rddev into :wkoutq, :wkdevd
740 A                from rptovrdtl
740 A           where rdprf='R30200' and rdone='Y'
740 A             fetch first row only;
740 A    if sqlstt = '00000';
740 A      if wkoutq<>*blanks;
740 A        grDev = wkoutq;
740 A      else;
740 A        if wkdevd<>*blanks;
740 A          grDev = wkdevd;
740 A        endif;
740 A      endif;
740 A    endif;

         // pass max number of column sections to control how printed
         calcula024 = %char(Maxcol);
         // set parms for GUI Report Call
         oRptNam = 'BFCREPORTS.R30200';
         //oEmail='kennethe@bfcassociates.com;hemantk@bfcassociates.com';
750eD    //oEmail='kennethe@bfcassociates.com';
750eA    oEmail=*blanks;
750eA    exec sql select bsvalue into :oEmail from bfcmrcrprm
750eA              where bswhse=:$whse and bsrptpgm='BFCREPORTS.R30200'
750eA                and BSMRCTBL='E' and bsmrcprm='EMAIL'
750eA                fetch first row only;
750eA    if oEmail=*blanks;
750eA      // if not defined send to kenneth only
750eA      oEmail='kennethe@bfcassociates.com';
750eA    else;
750eA      // if defined and kenneth not included then add
750eA      oEmail = %xlate(lowercase:uppercase:oEmail);
750eA      if %scan('KENNETHE':oEmail)=0;
750eA        oEmail=%trim(oEmail) + ';KENNETHE@BFCASSOCIATES.COM';
750eA      endif;
750eA    endif;
740 D    //oPrinter=*blanks;
740 M    oPrinter = grDev;
         oOrient='L';
         // First 10 CALCULA parms for Column Headings truck table
         // CALCULA 11 thru 20 are headings for Total summary after truck
         oUrl = '&R001=' + %char($whse) + '&R002=' + %trim($prtid) +
                '&d_detail=1&outfmt=11&CALCULA001=' + %trim(CALCULA001) +
720jA           '&G_toTAL=1' +
                '&CALCULA002=' + %TRIM(CALCULA002) +
                '&CALCULA003=' + %TRIM(CALCULA003) +
                '&CALCULA004=' + %TRIM(CALCULA004) +
                '&CALCULA005=' + %TRIM(CALCULA005) +
                '&CALCULA006=' + %TRIM(CALCULA006) +
                '&CALCULA007=' + %TRIM(CALCULA007) +
                '&CALCULA008=' + %TRIM(CALCULA008) +
                '&CALCULA009=' + %TRIM(CALCULA009) +
                '&CALCULA010=' + %TRIM(CALCULA010) +
                '&CALCULA011=' + %TRIM(CALCULA011) +
                '&CALCULA012=' + %TRIM(CALCULA012) +
                '&CALCULA013=' + %TRIM(CALCULA013) +
                '&CALCULA014=' + %TRIM(CALCULA014) +
                '&CALCULA015=' + %TRIM(CALCULA015) +
                '&CALCULA016=' + %TRIM(CALCULA016) +
                '&CALCULA017=' + %TRIM(CALCULA017) +
                '&CALCULA018=' + %TRIM(CALCULA018) +
                '&CALCULA019=' + %TRIM(CALCULA019) +
                '&CALCULA020=' + %TRIM(CALCULA020) +
                '&CALCULA021=' + %TRIM(CALCULA021) +
                '&CALCULA022=' + %TRIM(CALCULA022) +
                '&CALCULA023=' + %TRIM(CALCULA023) +
                '&CALCULA024=' + %TRIM(CALCULA024);

          // CALL MRC Report Processor
740 D     //mrcrptsch($whse:
740 D     //          oRptNam:
740 D     //          oUrl:
740 D     //          oEmail:
740 D     //          oPrinter:
740 D     //          oOrient);
740 A     // Submit GUI Truck Map
740 A     // Make sure report scheduling options record is defined
740 A     // whether using report scheduling or not
740 A     cmd = 'sbmjob cmd(MRCRPTSCH ' +
740 A            'WHSE(' + %editc($whse:'X') + ') ' +
740 A            'RPTNAM(' + sq + %trim(oRptNam) + sq + ') ' +
740 A            'URL(' + sq + %trim(oUrl) + sq + ') ' +
740 A            'EMAIL(' + sq + %trim(oEmail) + sq + ') ' +
740 A            'PRINTER(' + sq + %trim(oPrinter) + sq + ') ' +
740 A            'ORIENT(' + sq + %trim(oOrient) + sq + ')) ' +
740 A            'inllibl(' + %trim(sbmlibl) + ') ' +
740 A            'jobd(' + %trim(sbmjobd) + ') ' +
740 A            'user(' + %trim(sbmusr) + ') ' +
740 A            'jobq(QS36EVOKE) ' +
740 A            'job(PS313MRC)';
740 A     monitor;
740 A        qcmdexc(cmd: %len(cmd));
740 A     on-error;
740 A     endmon;
      /end-free
720dhC                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRFRMT        BEGSR
     C*
     C*   Get warehouse description.
     C*
     C                   MOVE      *BLANKS       WHSE
     C                   MOVE      *BLANKS       $PSTR
     C     $WHSE         CHAIN     WAREHS                             79
     C     *IN79         IFEQ      *OFF
     C                   MOVEL     WHDESC        $PSTR            60
     C                   ELSE
     C                   MOVE      *BLANKS       $PSTR
     C                   ENDIF
     C                   Z-ADD     30            $PLEN             3 0
     C*
     C*   Center warehouse description.
     C*
     C                   CALL      'CENTER'
     C                   PARM                    $PSTR
     C                   PARM                    $PLEN
     C                   MOVEL     $PSTR         WHSE
     C*
     C*  Format truck
     C*
     C                   MOVE      *BLANKS       ROUTE
     C     RTKEY         KLIST
     C                   KFLD                    $WHSE
     C                   KFLD                    $PRTID
     C     RTKEY         CHAIN     RTEHED                             79
     C     *IN79         IFEQ      *OFF
     C                   MOVE      RHRTE         ROUTE
     C                   ENDIF
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRCLER        BEGSR
     C*
     C*   Initialize all data structures.
     C*
     C                   CLEAR                   C0COMP
     C                   CLEAR                   C0PICK
     C                   CLEAR                   C0CUBE
     C                   CLEAR                   C0STP1
     C                   CLEAR                   C0STP2
700eAC                   if        client=saval
700eAC                             or client = yhata
700eAC                             or client = royal
700eAC                             or client = andrews
700eAC                             or client = cityline
SVLaAC                   CLEAR                   C0RTPA
HARfAC                   CLEAR                   C0LDSD
650bAC                   CLEAR                   C0WGT
700eAC                   endif
     C     1             DO        RECCOL        X
     C     X             OCCUR     DS1
     C                   MOVE      DS0           DS1
HARfAC                   MOVE      DS0H          DS11
     C     X             OCCUR     DS2
     C                   MOVE      DS0           DS2
HARfAC                   MOVE      DS0H          DS12
720 AC     X             OCCUR     DS3
720 AC                   MOVE      DS0           DS3
HARfAC                   MOVE      DS0H          DS13
720 AC     X             OCCUR     DS4
720hAC                   MOVE      DS0           DS4
HARfAC                   MOVE      DS0H          DS14
720 AC     X             OCCUR     DS5
720hAC                   MOVE      DS0           DS5
HARfAC                   MOVE      DS0H          DS15
720 AC     X             OCCUR     DS6
720hAC                   MOVE      DS0           DS6
HARfAC                   MOVE      DS0H          DS16
720 AC     X             OCCUR     DS7
720hAC                   MOVE      DS0           DS7
HARfAC                   MOVE      DS0H          DS17
720 AC     X             OCCUR     DS8
720hAC                   MOVE      DS0           DS8
HARfAC                   MOVE      DS0H          DS18
720 AC     X             OCCUR     DS9
720hAC                   MOVE      DS0           DS9
HARfAC                   MOVE      DS0H          DS19
     C                   ENDDO
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRDETL        BEGSR
     C*  Print detail line.
     C                   CLEAR                   C0COMP
     C                   CLEAR                   C0PICK
     C                   CLEAR                   C0CUBE
     C                   CLEAR                   C0STP1
     C                   CLEAR                   C0STP2
720 Ac                   clear                   c0spcs
720 Ac                   clear                   c0wgt
720jAc                   eval      c1stpa=*zeros
720jAc                   eval      c1stpb=*zeros
720jAc                   eval      c2stpa=*zeros
720jAc                   eval      c2stpb=*zeros
720jAc                   eval      c3stpa=*zeros
720jAc                   eval      c3stpb=*zeros
720jAc                   eval      c4stpa=*zeros
720jAc                   eval      c4stpb=*zeros
720jAc                   eval      c5stpa=*zeros
720jAc                   eval      c5stpb=*zeros
720jAc                   eval      c6stpa=*zeros
720jAc                   eval      c6stpb=*zeros
720jAc                   eval      c7stpa=*zeros
720jAc                   eval      c7stpb=*zeros
720jAc                   eval      c8stpa=*zeros
720jAc                   eval      c8stpb=*zeros
720jAc                   eval      c9stpa=*zeros
720jAc                   eval      c9stpb=*zeros
700eAC                   if        client=saval
700eAC                             or client = yhata
700eAC                             or client = royal
700eAC                             or client = andrews
700eAC                             or client = cityline
SVLaAC                   CLEAR                   C0RTPA
HARfAC                   CLEAR                   C0LDSD
720 DC*                  CLEAR                   C0WGT
720iAc                   eval      c1stpa=*zeros
720iAc                   eval      c1stpb=*zeros
720iAc                   eval      c2stpa=*zeros
720iAc                   eval      c2stpb=*zeros
720iAc                   eval      c3stpa=*zeros
720iAc                   eval      c3stpb=*zeros
700eAC                   endif
     C     1             DO        RECCOL        X
     C     X             OCCUR     DS1
     C     X             OCCUR     DS2
720 AC     X             OCCUR     DS3
720 AC     X             OCCUR     DS4
720 AC     X             OCCUR     DS5
720 AC     X             OCCUR     DS6
720 AC     X             OCCUR     DS7
720 AC     X             OCCUR     DS8
720 AC     X             OCCUR     DS9
520 AC*
720iAc                   if        c1wgt<>*zeros
750bAc                             or c1cube<>*zeros
520 MC                   Z-ADD     C1STP1        $SDSTP
520 AC                   EXSR      ZZFGTS
520aAC     $SSTP         IFGT      0
520 MC                   Z-ADD     $SSTP         C1STPA
520aAC                   ELSE
520aAC                   Z-ADD     C1STP1        C1STPA
520aAC                   ENDIF
520 AC*
520 MC                   Z-ADD     C1STP2        $SDSTP
520 AC                   EXSR      ZZFGTS
520aAC     $SSTP         IFGT      0
520 MC                   Z-ADD     $SSTP         C1STPB
520aAC                   ELSE
520aAC                   Z-ADD     C1STP2        C1STPB
520aAC                   ENDIF
720iAC                   ENDIF
520 AC*
720iAc                   if        c2wgt<>*zeros
750bAc                             or c2cube<>*zeros
520 MC                   Z-ADD     C2STP1        $SDSTP
520 AC                   EXSR      ZZFGTS
520aAC     $SSTP         IFGT      0
520 MC                   Z-ADD     $SSTP         C2STPA
520aAC                   ELSE
520aAC                   Z-ADD     C2STP1        C2STPA
520aAC                   ENDIF
520 AC*
520 MC                   Z-ADD     C2STP2        $SDSTP
520 AC                   EXSR      ZZFGTS
520aAC     $SSTP         IFGT      0
520 MC                   Z-ADD     $SSTP         C2STPB
520aAC                   ELSE
520aAC                   Z-ADD     C2STP2        C2STPB
520aAC                   ENDIF
720iAC                   ENDIF
720 AC*
720iAc                   if        c3wgt<>*zeros
750bAc                             or c3cube<>*zeros
720 AC                   Z-ADD     C3STP1        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C3STPA
720 AC                   ELSE
720 AC                   Z-ADD     C3STP1        C3STPA
720 AC                   ENDIF
720 AC*
720 AC                   Z-ADD     C3STP2        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C3STPB
720 AC                   ELSE
720 AC                   Z-ADD     C3STP2        C3STPB
720 AC                   ENDIF
720iAC                   ENDIF
720 AC*
720iAc                   if        c4wgt<>*zeros
750bAc                             or c4cube<>*zeros
720 AC                   Z-ADD     C4STP1        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C4STPA
720 AC                   ELSE
720 AC                   Z-ADD     C4STP1        C4STPA
720 AC                   ENDIF
720 AC*
720 AC                   Z-ADD     C4STP2        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C4STPB
720 AC                   ELSE
720 AC                   Z-ADD     C4STP2        C4STPB
720 AC                   ENDIF
720iAC                   ENDIF
720 AC*
720iAc                   if        c5wgt<>*zeros
750bAc                             or c5cube<>*zeros
720 AC                   Z-ADD     C5STP1        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C5STPA
720 AC                   ELSE
720 AC                   Z-ADD     C5STP1        C5STPA
720 AC                   ENDIF
720 AC*
720 AC                   Z-ADD     C5STP2        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C5STPB
720 AC                   ELSE
720 AC                   Z-ADD     C5STP2        C5STPB
720 AC                   ENDIF
720iAC                   ENDIF
720 AC*
720iAc                   if        c6wgt<>*zeros
750bAc                             or c6cube<>*zeros
720 AC                   Z-ADD     C6STP1        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C6STPA
720 AC                   ELSE
720 AC                   Z-ADD     C6STP1        C6STPA
720 AC                   ENDIF
720 AC*
720 AC                   Z-ADD     C6STP2        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C6STPB
720 AC                   ELSE
720 AC                   Z-ADD     C6STP2        C6STPB
720 AC                   ENDIF
720iAC                   ENDIF
720 AC*
720iAc                   if        c7wgt<>*zeros
750bAc                             or c7cube<>*zeros
720 AC                   Z-ADD     C7STP1        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C7STPA
720 AC                   ELSE
720 AC                   Z-ADD     C7STP1        C7STPA
720 AC                   ENDIF
720 AC*
720 AC                   Z-ADD     C7STP2        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C7STPB
720 AC                   ELSE
720 AC                   Z-ADD     C7STP2        C7STPB
720 AC                   ENDIF
720iAC                   ENDIF
720 AC*
720iAc                   if        c8wgt<>*zeros
750bAc                             or c8cube<>*zeros
720 AC                   Z-ADD     C8STP1        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C8STPA
720 AC                   ELSE
720 AC                   Z-ADD     C8STP1        C8STPA
720 AC                   ENDIF
720 AC*
720 AC                   Z-ADD     C8STP2        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C8STPB
720 AC                   ELSE
720 AC                   Z-ADD     C8STP2        C8STPB
720 AC                   ENDIF
720iAC                   ENDIF
720 AC*
720iAc                   if        c9wgt<>*zeros
750bAc                             or c9cube<>*zeros
720 AC                   Z-ADD     C9STP1        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C9STPA
720 AC                   ELSE
720 AC                   Z-ADD     C9STP1        C9STPA
720 AC                   ENDIF
720 AC*
720 AC                   Z-ADD     C9STP2        $SDSTP
720 AC                   EXSR      ZZFGTS
720 AC     $SSTP         IFGT      0
720 AC                   Z-ADD     $SSTP         C9STPB
720 AC                   ELSE
720 AC                   Z-ADD     C9STP2        C9STPB
720 AC                   ENDIF
720iAC                   ENDIF
520 AC*
ICBaAC                   eval      chkcube = c1spcs + c2spcs + c3spcs
     c                                     + c4spcs + c5spcs + c6spcs
     c                                     + c7spcs + c8spcs + c9spcs
650aAC                   select
ICBaAC                   when      client = dairyland
720fAc                   write     detail1dry
ICBaAC                   when      client = icb and
ICBaAC                             chkcube <> 0
720fAc*                  write     detail1icb
ISYaAC                   when      client=isupply or
GMMaAC                             client = menumaker
GFCaAC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRbDC***                          or client = SBertram
650aMC                   other
720hDC                   WRITE     DETAIL1
650aMC                   endsl
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAc                   clear                   pswdatad
720hAc                   eval      pswrpttp = 'D '
740 Mc                   eval      pswrecF = 'ADETAIL'
720hAc                   exsr      wrtWFrec
      *
SVLaAC                   if        client=saval
YHA AC                             or client = yhata
RYLaAC                             or client = royal
AFSbAC                             or client = andrews
CLDbAC                             or client = cityline
720hDC                   WRITE     DETAIL4
SVLaAC                   endif
510aAC                   ADD       1             LINE
510aAC                   EXSR      ZRSPCL
     C                   ENDDO
     C*
HARfAC     CLIENT        IFEQ      HARBOR
HARfAC     DS11          ANDNE     ' '
HARfAC     CLIENT        OREQ      HARBOR
HARfAC     DS12          ANDNE     ' '
720hAC                   WRITE     LDSD
HARfAC                   MOVE      DS0H          DS11
HARfAC                   MOVE      DS0H          DS12
HARfAC                   ELSE
650aAC                   select
ICBaAC                   when      client = icb  and
ICBaAC                             chkcube <> 0
720hAc                   write     dash1icb
GFCaAC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRbDC***                          or client = SBertram
720hDC                   write     dash180
650aDC*                  endif
ISYaAC                   when      client = isupply or
GMMaAC                             client = menumaker
720hDC                   WRITE     DASH1isy
650aMC                   other
720dA *
720dA *    loop and print any lines of Pallet Id's that exist
720dA *
720dA /free
720dA         ssccCnt = 1;
720dA          dow ssccCnt < 10;
720dA             if sscc1(ssccCnt) <> *blanks or
720dA                sscc2(ssccCnt) <> *blanks or
720dA                sscc3(ssccCnt) <> *blanks or
720dA                sscc4(ssccCnt) <> *blanks or
720dA                sscc5(ssccCnt) <> *blanks or
720dA                sscc6(ssccCnt) <> *blanks or
720dA                sscc7(ssccCnt) <> *blanks or
720dA                sscc8(ssccCnt) <> *blanks or
720dA                sscc9(ssccCnt) <> *blanks;
                     if client=andersondubose;
720dA                  c1plid = sscc1(ssccCnt);
720dA                  c2plid = sscc2(ssccCnt);
720dA                  c3plid = sscc3(ssccCnt);
720dA                  c4plid = sscc4(ssccCnt);
720dA                  c5plid = sscc5(ssccCnt);
720dA                  c6plid = sscc6(ssccCnt);
720dA                  c7plid = sscc7(ssccCnt);
720dA                  c8plid = sscc8(ssccCnt);
720dA                  c9plid = sscc9(ssccCnt);
                     endif;
720fA                c1pal# = pal1(ssccCnt);
720fA                c2pal# = pal2(ssccCnt);
720fA                c3pal# = pal3(ssccCnt);
720fA                c4pal# = pal4(ssccCnt);
720fA                c5pal# = pal5(ssccCnt);
720fA                c6pal# = pal6(ssccCnt);
720fA                c7pal# = pal7(ssccCnt);
720fA                c8pal# = pal8(ssccCnt);
720fA                c9pal# = pal9(ssccCnt);
720fA                c1spcs = palcnt1(ssccCnt);
720fA                c2spcs = palcnt2(ssccCnt);
720fA                c3spcs = palcnt3(ssccCnt);
720fA                c4spcs = palcnt4(ssccCnt);
720fA                c5spcs = palcnt5(ssccCnt);
720fA                c6spcs = palcnt6(ssccCnt);
720fA                c7spcs = palcnt7(ssccCnt);
720fA                c8spcs = palcnt8(ssccCnt);
720fA                c9spcs = palcnt9(ssccCnt);
720hA                c1cube = palcub1(ssccCnt);
720hA                c2cube = palcub2(ssccCnt);
720hA                c3cube = palcub3(ssccCnt);
720hA                c4cube = palcub4(ssccCnt);
720hA                c5cube = palcub5(ssccCnt);
720hA                c6cube = palcub6(ssccCnt);
720hA                c7cube = palcub7(ssccCnt);
720hA                c8cube = palcub8(ssccCnt);
720hA                c9cube = palcub9(ssccCnt);
720hA                c1wgt = palwgt1(ssccCnt);
720hA                c2wgt = palwgt2(ssccCnt);
720hA                c3wgt = palwgt3(ssccCnt);
720hA                c4wgt = palwgt4(ssccCnt);
720hA                c5wgt = palwgt5(ssccCnt);
720hA                c6wgt = palwgt6(ssccCnt);
720hA                c7wgt = palwgt7(ssccCnt);
720hA                c8wgt = palwgt8(ssccCnt);
720hA                c9wgt = palwgt9(ssccCnt);
JFF A                if client = Jakes;
720fA                c1pcmp = palc1(ssccCnt);
720fA                c2pcmp = palc2(ssccCnt);
720fA                c3pcmp = palc3(ssccCnt);
720fA                c4pcmp = palc4(ssccCnt);
720fA                c5pcmp = palc5(ssccCnt);
720fA                c6pcmp = palc6(ssccCnt);
720fA                c7pcmp = palc7(ssccCnt);
720fA                c8pcmp = palc8(ssccCnt);
720fA                c9pcmp = palc9(ssccCnt);
JFF A                else;
720fA                c1pcmp = '   ' + palc1(ssccCnt);
720fA                c2pcmp = '   ' + palc2(ssccCnt);
720fA                c3pcmp = '   ' + palc3(ssccCnt);
720fA                c4pcmp = '   ' + palc4(ssccCnt);
720fA                c5pcmp = '   ' + palc5(ssccCnt);
720fA                c6pcmp = '   ' + palc6(ssccCnt);
720fA                c7pcmp = '   ' + palc7(ssccCnt);
720fA                c8pcmp = '   ' + palc8(ssccCnt);
720fA                c9pcmp = '   ' + palc9(ssccCnt);
JFF A                endif;
720hA
720hA    // Write values for any detail possibility to PS313WF Work File used by GUI Report
720hA
720hA                    clear     pswdatad;
720hA                    pswrpttp = 'D ';
740 M                    pswrecF = 'CDASH1';
720hA                    exsr wrtWFrec;
750cA                    exsr wrtSRCrtes;
720hA
                     if client=dairyland;
                        write dash1dry;
                     else;
720dM                   WRITE DASH1;
                     endif;
720dA             endif;
720dA             ssccCnt = ssccCnt + 1;
720dA          enddo;
720dA          c1plid = *blanks;
720dA          c2plid = *blanks;
720dA          c3plid = *blanks;
720dA          c4plid = *blanks;
720dA          c5plid = *blanks;
720dA          c6plid = *blanks;
720dA          c7plid = *blanks;
720dA          c8plid = *blanks;
720dA          c9plid = *blanks;
720dA          c1pal# = *zeros;
720dA          c2pal# = *zeros;
720dA          c3pal# = *zeros;
720dA          c4pal# = *zeros;
720dA          c5pal# = *zeros;
720dA          c6pal# = *zeros;
720dA          c7pal# = *zeros;
720dA          c8pal# = *zeros;
720dA          c9pal# = *zeros;
720dA          c1spcs = *zeros;
720dA          c2spcs = *zeros;
720dA          c3spcs = *zeros;
720dA          c4spcs = *zeros;
720dA          c5spcs = *zeros;
720dA          c6spcs = *zeros;
720dA          c7spcs = *zeros;
720dA          c8spcs = *zeros;
720dA          c9spcs = *zeros;
720dA          c1cube = *zeros;
720dA          c2cube = *zeros;
720dA          c3cube = *zeros;
720dA          c4cube = *zeros;
720dA          c5cube = *zeros;
720dA          c6cube = *zeros;
720dA          c7cube = *zeros;
720dA          c8cube = *zeros;
720dA          c9cube = *zeros;
720dA          c1pcmp = *blanks;
720dA          c2pcmp = *blanks;
720dA          c3pcmp = *blanks;
720dA          c4pcmp = *blanks;
720dA          c5pcmp = *blanks;
720dA          c6pcmp = *blanks;
720dA          c7pcmp = *blanks;
720dA          c8pcmp = *blanks;
720dA          c9pcmp = *blanks;
               c1wgt=*zeros;
               c2wgt=*zeros;
               c3wgt=*zeros;
               c4wgt=*zeros;
               c5wgt=*zeros;
               c6wgt=*zeros;
               c7wgt=*zeros;
               c8wgt=*zeros;
               c9wgt=*zeros;
720fA          ssccCnt = 1;
720fA          dow ssccCnt < 10;
720fA             sscc1(ssccCnt) = *blanks;
720fA             sscc2(ssccCnt) = *blanks;
720fA             sscc3(ssccCnt) = *blanks;
720fA             sscc4(ssccCnt) = *blanks;
720fA             sscc5(ssccCnt) = *blanks;
720fA             sscc6(ssccCnt) = *blanks;
720fA             sscc7(ssccCnt) = *blanks;
720fA             sscc8(ssccCnt) = *blanks;
720fA             sscc9(ssccCnt) = *blanks;
720fA             palc1(ssccCnt) = *blanks;
720fA             palc2(ssccCnt) = *blanks;
720fA             palc3(ssccCnt) = *blanks;
720fA             palc4(ssccCnt) = *blanks;
720fA             palc5(ssccCnt) = *blanks;
720fA             palc6(ssccCnt) = *blanks;
720fA             palc7(ssccCnt) = *blanks;
720fA             palc8(ssccCnt) = *blanks;
720fA             palc9(ssccCnt) = *blanks;
720fA             pal1(ssccCnt) = *zeros;
720fA             pal2(ssccCnt) = *zeros;
720fA             pal3(ssccCnt) = *zeros;
720fA             pal4(ssccCnt) = *zeros;
720fA             pal5(ssccCnt) = *zeros;
720fA             pal6(ssccCnt) = *zeros;
720fA             pal7(ssccCnt) = *zeros;
720fA             pal8(ssccCnt) = *zeros;
720fA             pal9(ssccCnt) = *zeros;
720gA             palcnt1(ssccCnt) = *zeros;
720gA             palcnt2(ssccCnt) = *zeros;
720gA             palcnt3(ssccCnt) = *zeros;
720gA             palcnt4(ssccCnt) = *zeros;
720gA             palcnt5(ssccCnt) = *zeros;
720gA             palcnt6(ssccCnt) = *zeros;
720gA             palcnt7(ssccCnt) = *zeros;
720gA             palcnt8(ssccCnt) = *zeros;
720gA             palcnt9(ssccCnt) = *zeros;
720gA             palcub1(ssccCnt) = *zeros;
720gA             palcub2(ssccCnt) = *zeros;
720gA             palcub3(ssccCnt) = *zeros;
720gA             palcub4(ssccCnt) = *zeros;
720gA             palcub5(ssccCnt) = *zeros;
720gA             palcub6(ssccCnt) = *zeros;
720gA             palcub7(ssccCnt) = *zeros;
720gA             palcub8(ssccCnt) = *zeros;
720gA             palcub9(ssccCnt) = *zeros;
720gA             palwgt1(ssccCnt) = *zeros;
720gA             palwgt2(ssccCnt) = *zeros;
720gA             palwgt3(ssccCnt) = *zeros;
720gA             palwgt4(ssccCnt) = *zeros;
720gA             palwgt5(ssccCnt) = *zeros;
720gA             palwgt6(ssccCnt) = *zeros;
720gA             palwgt7(ssccCnt) = *zeros;
720gA             palwgt8(ssccCnt) = *zeros;
720gA             palwgt9(ssccCnt) = *zeros;
720fA             ssccCnt = ssccCnt + 1;
720fA          enddo;
720dA /end-free
650aMC                   endsl
HARfAC                   ENDIF
650bMC                   MOVE      DS0           DS1
650bMC                   MOVE      DS0           DS2
720 AC                   MOVE      DS0           DS3
720 AC                   MOVE      DS0           DS4
720 AC                   MOVE      DS0           DS5
720 AC                   MOVE      DS0           DS6
720 AC                   MOVE      DS0           DS7
720 AC                   MOVE      DS0           DS8
720 AC                   MOVE      DS0           DS9
510aAC                   ADD       1             LINE
510aAC                   EXSR      ZRSPCL
BIRaAC     CLIENT        IFEQ      BIRITE
BIRaAC                   ELSE
650aAC                   select
ICBaAC                   when      client = icb  and
ICBaAC                             chkcube <> 0
720hDC                   write     dash2icb
GFCaAC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRbDC***                          or client = SBertram
720hDC                   write     dash280
ISYaAC                   when      client = isupply or
GMMaAC                             client = menumaker
720hDC                   WRITE     DASH2isy
ISYaAC                   when      client = dairyland
ISYaAC                   WRITE     DASH2DRY
650aAC                   other
720hDC                   WRITE     DASH2
650aAC                   ENDsl
510aAC                   ADD       1             LINE
510aAC                   EXSR      ZRSPCL
BIRaAC                   ENDIF
     C*
     C*  Initialize record counters for each columns.
     C*
     C                   Z-ADD     1             C1
     C                   Z-ADD     1             C2
720 AC                   Z-ADD     1             C3
720 AC                   Z-ADD     1             C4
720 AC                   Z-ADD     1             C5
720 AC                   Z-ADD     1             C6
720 AC                   Z-ADD     1             C7
720 AC                   Z-ADD     1             C8
720 AC                   Z-ADD     1             C9
720dAc                   eval      first = *on
720dAc*
     C                   ENDSR
BIRaAC*----------------------------------------------------------------
BIRaAC*
BIRaAC*  Print Pallet Stops Detail line(s)
BIRaAC*
BIRaAC     ZRDTL2        BEGSR
BIRaAC*
BIRaAC     *IN90         IFEQ      *ON
BIRaAC                   EXSR      ZRHEAD
BIRaAC                   ENDIF
BIRaAC*
BIRaAC                   CLEAR                   S1COMP
BIRaAC                   CLEAR                   S1CUBE
BIRaAC                   CLEAR                   S1STP1
520 AC                   CLEAR                   S1STPA
BIRaAC                   CLEAR                   S1SPCS
BIRaAC                   CLEAR                   S2COMP
BIRaAC                   CLEAR                   S2CUBE
BIRaAC                   CLEAR                   S2STP1
520 AC                   CLEAR                   S2STPA
BIRaAC                   CLEAR                   S2SPCS
BIRaAC* Column 1
BIRaAC                   Z-ADD     1             Z
BIRaAC                   Z-ADD     1             Z2
BIRaAC     SVPID2        IFNE      0
BIRaAC     SVPID2        LOOKUP    SPID(Z2)                               82
BIRaAC                   ENDIF
BIRaAC*
BIRaAC                   DO        9999          Z
BIRaAC*
BIRaAC     *IN90         IFEQ      *ON
BIRaAC                   EXSR      ZRHEAD
BIRaAC                   ENDIF
BIRaAC*
BIRaAC     SPID(Z)       IFEQ      0
BIRaAC                   LEAVE
BIRaAC                   ENDIF
BIRaAC*
BIRaAC     SPID(Z)       IFEQ      SVPID1
BIRaAC*                    MOVELSCMP,Z    S1COMP
BIRaAC                   Z-ADD     SSTP(Z)       S1STP1            2 0
520 AC*
520 MC                   Z-ADD     S1STP1        $SDSTP
520 AC                   EXSR      ZZFGTS
520aAC     $SSTP         IFGT      0
520 MC                   Z-ADD     $SSTP         S1STPA
520aAC                   ELSE
520aAC                   Z-ADD     S1STP1        S1STPA
520aAC                   ENDIF
520 AC*
BIRaAC                   Z-ADD     SPCS(Z)       S1SPCS
BIRaAC                   Z-ADD     SCUB(Z)       S1CUBE
BIRaAC     SVPID2        IFEQ      0
720hDC*                  WRITE     DETAIL2
BIRaAC                   ELSE
BIRaAC* Column 2
BIRaAC     SPID(Z2)      IFEQ      SVPID2
BIRaAC                   Z-ADD     SSTP(Z2)      S2STP1            2 0
520 AC*
520 MC                   Z-ADD     S2STP1        $SDSTP
520 AC                   EXSR      ZZFGTS
520aAC     $SSTP         IFGT      0
520 MC                   Z-ADD     $SSTP         S2STPA
520aAC                   ELSE
520aAC                   Z-ADD     S2STP1        S2STPA
520aAC                   ENDIF
520 AC*
BIRaAC                   Z-ADD     SPCS(Z2)      S2SPCS
BIRaAC                   Z-ADD     SCUB(Z2)      S2CUBE
720hDc*                  WRITE     DETAIL2
BIRaAC                   ADD       1             Z2
BIRaAC                   ELSE
BIRaAC* Column 1 if nothing in column 2
BIRaAC                   CLEAR                   S2CUBE
BIRaAC                   CLEAR                   S2STP1
520 AC                   CLEAR                   S2STPA
BIRaAC                   CLEAR                   S2SPCS
720hDC                   WRITE     DETAIL2
BIRaAC                   ENDIF
BIRaAC                   ENDIF
BIRaAC                   ELSE
BIRaAC* Column 2 if nothing in column 1
BIRaAC     SPID(Z2)      IFEQ      SVPID2
BIRaAC     SVPID1        ANDEQ     0
BIRaAC                   Z-ADD     SSTP(Z2)      S2STP1
520 AC*
520 MC                   Z-ADD     S2STP1        $SDSTP
520 AC                   EXSR      ZZFGTS
520aAC     $SSTP         IFGT      0
520 MC                   Z-ADD     $SSTP         S2STPA
520aAC                   ELSE
520aAC                   Z-ADD     S2STP1        S2STPA
520aAC                   ENDIF
520 AC*
BIRaAC                   Z-ADD     SPCS(Z2)      S2SPCS
BIRaAC                   Z-ADD     SCUB(Z2)      S2CUBE
720hDc                   WRITE     DETAIL2
BIRaAC                   ADD       1             Z2
BIRaAC                   ELSE
BIRaAC                   CLEAR                   S2CUBE
BIRaAC                   CLEAR                   S2STP1
BIRaAC                   CLEAR                   S2SPCS
BIRaAC                   ENDIF
BIRaAC                   ITER
BIRaAC                   ENDIF
BIRaAC*
BIRaAC                   ENDDO
650aMC                   select
ICBaMC                   when      client = icb
720hDc                   write     dash2icb
GFCaMC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRbDC***                          or client = SBertram
BIRaAC*
720hDc                   write     dash280
ISYaAC                   when      client = isupply or
GMMaAC                             client = menumaker
720hdC                   WRITE     DASH2isy
650aMC                   other
720hDc                   WRITE     DASH2
650aMC                   endsl
BIRaAC                   Z-ADD     0             SVPID1
BIRaAC                   Z-ADD     0             SVPID2
720 AC                   Z-ADD     0             SVPID3
BIRaAC*
BIRaAC                   ENDSR
     C*----------------------------------------------------------------
     C*
HARa C*  Print Pallet Stops Detail line(s)
     C*
HARa C     ZRDTL3        BEGSR
     C*
     C     *IN90         IFEQ      *ON
     C                   EXSR      ZRHEAD
     C                   ENDIF
     C*
     C                   CLEAR                   S1COMP
     C                   CLEAR                   S1CUBE
     C                   CLEAR                   S1STP1
520 AC                   CLEAR                   S1STPA
     C                   CLEAR                   S1SPCS
     C                   CLEAR                   S1STDP
     C                   CLEAR                   S2COMP
     C                   CLEAR                   S2CUBE
     C                   CLEAR                   S2STP1
520 AC                   CLEAR                   S2STPA
     C                   CLEAR                   S2SPCS
     C                   CLEAR                   S2STDP
     C* Column 1
HARcDC*                    Z-ADD1         Z
HARcMC                   Z-ADD     1             Z3
     C                   Z-ADD     1             Z2
HARc  *
HARc  * Find pallet starting position
HARc  *
HARc C     SVPID1        IFNE      0
HARc C     SVPID1        LOOKUP    SPID(Z3)                               82
HARC C                   ENDIF
     C     SVPID2        IFNE      0
     C     SVPID2        LOOKUP    SPID(Z2)                               82
     C                   ENDIF
     C*
HARcDC*                    DO   9999      Z
HARcMC     Z3            DO        9999          Z
     C*
     C     *IN90         IFEQ      *ON
     C                   EXSR      ZRHEAD
     C                   ENDIF
     C*
     C     SPID(Z)       IFEQ      0
     C                   LEAVE
     C                   ENDIF
     C*
     C     SPID(Z)       IFEQ      SVPID1
     C*                    MOVELSCMP,Z    S1COMP
     C                   Z-ADD     SSTP(Z)       S1STP1
520 AC*
520 MC                   Z-ADD     S1STP1        $SDSTP
520 AC                   EXSR      ZZFGTS
520aAC     $SSTP         IFGT      0
520 MC                   Z-ADD     $SSTP         S1STPA
520aAC                   ELSE
520aAC                   Z-ADD     S2STP1        S1STPA
520aAC                   ENDIF
520 AC*
     C                   Z-ADD     SPCS(Z)       S1SPCS
     C                   Z-ADD     SCUB(Z)       S1CUBE
     C                   MOVEL     STDP(Z)       S1STDP
     C     SVPID2        IFEQ      0
720hDC                   WRITE     DETAIL3
HARc C                   CLEAR                   S1COMP
HARc C                   CLEAR                   S1CUBE
HARc C                   CLEAR                   S1STP1
520 AC                   CLEAR                   S1STPA
HARc C                   CLEAR                   S1SPCS
HARc C                   CLEAR                   S1STDP
     C                   ADD       1             LINE
     C                   EXSR      ZRSPCL
     C                   ELSE
     C* Column 2
     C     SPID(Z2)      IFEQ      SVPID2
     C                   Z-ADD     SSTP(Z2)      S2STP1
520 AC*
520 MC                   Z-ADD     S2STP1        $SDSTP
520 AC                   EXSR      ZZFGTS
520aAC     $SSTP         IFGT      0
520 MC                   Z-ADD     $SSTP         S1STPA
520aAC                   ELSE
520aAC                   Z-ADD     S2STP1        S1STPA
520aAC                   ENDIF
520 AC*
     C                   Z-ADD     SPCS(Z2)      S2SPCS
     C                   Z-ADD     SCUB(Z2)      S2CUBE
     C                   MOVEL     STDP(Z2)      S2STDP
720hDC                   WRITE     DETAIL3
HARc C                   CLEAR                   S1COMP
HARc C                   CLEAR                   S1CUBE
HARc C                   CLEAR                   S1STP1
520 AC                   CLEAR                   S1STPA
HARc C                   CLEAR                   S1SPCS
HARc C                   CLEAR                   S1STDP
     C                   ADD       1             LINE
     C                   EXSR      ZRSPCL
     C                   ADD       1             Z2
     C                   ELSE
     C* Column 1 if nothing in column 2
     C                   CLEAR                   S2CUBE
     C                   CLEAR                   S2STP1
520 AC                   CLEAR                   S2STPA
     C                   CLEAR                   S2SPCS
     C                   CLEAR                   S2STDP
720hDC                   WRITE     DETAIL3
     C                   ADD       1             LINE
     C                   EXSR      ZRSPCL
     C                   ENDIF
     C                   ENDIF
     C                   ELSE
     C* Column 2 if nothing in column 1
     C     SPID(Z2)      IFEQ      SVPID2
HARc C*          SVPID1    ANDEQ0
     C                   Z-ADD     SSTP(Z2)      S2STP1
520 AC*
520 MC                   Z-ADD     S2STP1        $SDSTP
520 AC                   EXSR      ZZFGTS
520aAC     $SSTP         IFGT      0
520 MC                   Z-ADD     $SSTP         S2STPA
520aAC                   ELSE
520aAC                   Z-ADD     S2STP1        S2STPA
520aAC                   ENDIF
520 AC*
     C                   Z-ADD     SPCS(Z2)      S2SPCS
     C                   Z-ADD     SCUB(Z2)      S2CUBE
     C                   MOVEL     STDP(Z2)      S2STDP
720hDc                   WRITE     DETAIL3
HARc C                   CLEAR                   S1COMP
HARc C                   CLEAR                   S1CUBE
HARc C                   CLEAR                   S1STP1
520 AC                   CLEAR                   S1STPA
HARc C                   CLEAR                   S1SPCS
HARc C                   CLEAR                   S1STDP
     C                   ADD       1             LINE
     C                   EXSR      ZRSPCL
     C                   ADD       1             Z2
     C                   ELSE
     C                   CLEAR                   S2CUBE
     C                   CLEAR                   S2STP1
520 AC                   CLEAR                   S2STPA
     C                   CLEAR                   S2SPCS
     C                   CLEAR                   S2STDP
     C                   ENDIF
     C                   ITER
     C                   ENDIF
     C*
     C                   ENDDO
650aAC                   select
ICBaAC                   when      client = icb
720hDC                   write     dash2ICB
GFCaAC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRbDC***                          or client = SBertram
720hDC                   write     dash280
ISYaAC                   when      client = isupply or
GMMaAC                             client = menumaker
720hDC                   WRITE     DASH2isy
650aAC                   other
720hDc                   WRITE     DASH2
650aAC                   endsl
510aAC                   ADD       1             LINE
510aAC                   EXSR      ZRSPCL
     C                   Z-ADD     0             SVPID1
     C                   Z-ADD     0             SVPID2
720 AC                   Z-ADD     0             SVPID3
     C*
HARa C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRHEAD        BEGSR
     C*
     C*  Print previous page detail lines.
     C*
     C     RECK(L)       IFGT      0
     C                   EXSR      ZRDETL
BIRaAC     CLIENT        IFEQ      BIRITE
BIRaAC                   EXSR      ZRDTL2
BIRaAC                   ENDIF
HARa C     CLIENT        IFEQ      HARBOR
HARa C                   EXSR      ZRDTL3
HARa C                   ENDIF
     C                   Z-ADD     0             COUNT
     C                   ENDIF
     C*
     C                   MOVE      *OFF          *IN90
510aAC                   Z-ADD     1             LINE
     C*
650aAC                   select
ICBaAC                   when      client = icb
ICBaAC                   write     head1icb
GFCaAC                   when      client = glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
ISYbAC                             or client = isupply
SBRbDC***                          or client = SBertram
700cAC                   eval      val39 = route
GFCaAC                   write     head180
650aMC                   other
     C                   WRITE     HEAD1
650aMC                   endsl
DRY AC*
JORaDC*                  if        client = Dairyland
JORbAC                   SELECT
JORbMC                   when      client = Dairyland
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAc                   clear                   pswdatah2
720hAc                   eval      pswrpttp = 'H '
720hAc                   eval      pswrecF = 'HEAD2'
720hAc                   exsr      wrtWFrec
DRY AC                   write     head2Dry
GFCaAC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRbDC***                          or client = SBertram
700cAC                   eval      val39 = route
GFCaAC                   write     head280
JORaDC*                  else
JORaAC                   when      client = Jordanos
JORaAC                   write     head2Jor                             90
ASC AC                   when      client = agar
ASC AC**                 write     head2asc                             90
RFS AC                   when      client = rfs
RFS AC                   write     head2rfs                             90
ISYaAC                   when      client = isupply or
GMMaAC                             client = menumaker
ISYaAC                   write     head2isy
ICBaAC                   when      client = icb
ICBaAC     keyct         chain     custtrk                              90
ICBaAC                   if        %found(custtrk)
ICBaAC                   eval      tknbr=cttruk
ICBaAC                   eval      tkdrv=ctdrvr
ICBaAC                   else
ICBaAC                   eval      tknbr='_____'
ICBaAC                   eval      tkdrv='__________'
ICBaAC                   endif
ICBaAC                   write     head2icb                             90
JORaAC                   other
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAc                   clear                   pswdatah2
720hAc                   eval      pswrpttp = 'H '
720hAc                   eval      pswrecF = 'HEAD2'
720hAc                   exsr      wrtWFrec
     C                   WRITE     HEAD2
JORaAC                   endsl
JORaDC**                 endif
DRY AC*
510bAC                   EXSR      ZZRTNT
DRY AC*
650aAC                   select
DRY AC                   when      client = Dairyland
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAc                   clear                   pswdatah2
720hAc                   eval      pswrpttp = 'H '
720hAc                   eval      pswrecF = 'COLUMNS'
720hAc                   exsr      wrtWFrec
DRY AC                   write     columnsdry
DRY AC*                  else
ISYaAC                   when      client=isupply or
GMMaAC                             client = menumaker
ISYaAC                   write     columnsisy
GFCaAC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRbDC***                          or client = SBertram
GFCaAC                   write     columns80
ICBaAC                   when      client = icb
ICBaAC                   write     columnsicb
650aAC                   other
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAc                   clear                   pswdatah2
720hAc                   eval      pswrpttp = 'H '
720hAc                   eval      pswrecF = 'COLUMNS'
720hAc                   exsr      wrtWFrec
     C                   WRITE     COLUMNS
650aaC                   endsl
DRY AC*                  endif
     C*
     C                   ENDSR
     C*
HARA C     ZRSPCL        BEGSR
     C*
     C     LINE          IFEQ      5
530 D ***                WRITE     QUALITY
     C                   ENDIF
     C     LINE          IFEQ      14
530 D ***                WRITE     COMENTS
     C                   ENDIF
HARa C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRTOTL        BEGSR
     C*
     C     L             IFEQ      1
     C*                    WRITETOTAL1
     C                   END
     C*
     C     L             IFEQ      2
     C*                    WRITETOTAL2
     C                   END
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRZERO        BEGSR
     C*
     C                   Z-ADD     0             RECK(L)
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
417aAC     ZZPCS         BEGSR
     C*
     C     LBKEY         SETLL     LABEL90
     C     FOREVR        DOWEQ     FOREVR
     C     LBKEY         READE     LABEL90                                79
     C     *IN79         IFEQ      *ON
     C                   LEAVE
     C                   ENDIF
     C*
     C     LBTYPE        IFNE      'O'
500bDC*          LBTYPE    ANDNE'B'
500bAC     LBTYPE        ANDNE     'M'
     C                   ITER
     C                   ENDIF
500a C*
500a C     LBPAL#        IFNE      PSPLID
500a C                   ITER
500a C                   ENDIF
     C*
     C     LBUTYP        IFEQ      'N'
     C     FOUND         ANDEQ     *ON
     C                   ADD       LBQPCK        PCN(N)
     C                   ENDIF
     C*
     C     LBUTYP        IFEQ      'N'
     C     FOUND         ANDEQ     *OFF
     C                   Z-ADD     LBQPCK        PCN(N)
     C                   ENDIF
     C*
     C     LBUTYP        IFEQ      '1'
     C     FOUND         ANDEQ     *ON
     C                   ADD       LBQPCK        PC1(N)
     C                   ENDIF
     C*
     C     LBUTYP        IFEQ      '1'
     C     FOUND         ANDEQ     *OFF
     C                   Z-ADD     LBQPCK        PC1(N)
     C                   ENDIF
     C*
500bAC                   MOVE      *ON           FOUND
     C                   ENDDO
     C*
417aAC                   ENDSR
     C*----------------------------------------------------------------
     C*
650BAC     ZZPCSPLT      BEGSR
     C*
     C                   eval      actqty = *zeros
     C                   eval      actcub = *zeros
     C                   eval      actwgt = *zeros
     C*
     C     LBKEY         SETLL     LABEL90
     C     FOREVR        DOWEQ     FOREVR
     C     LBKEY         READE     LABEL90                                79
     C     *IN79         IFEQ      *ON
     C                   LEAVE
     C                   ENDIF
     C*
     C     LBTYPE        IFNE      'O'
     C     LBTYPE        ANDNE     'M'
     C                   ITER
     C                   ENDIF
     C*
     C     LBPAL#        IFNE      PSPLID
     C                   ITER
     C                   ENDIF
     C*
     C                   add(h)    LBQPCK        actqty
     C                   add(h)    LBCUBE        actcub
     C                   add(h)    LBSWGT        actwgt
     C*
     C                   ENDDO
     C*
     C                   ENDSR
BIRaAC*----------------------------------------------------------------
BIRaAC*
BIRaAC*  Get Pallet Stops Data & plug into arrays
BIRaAC*
BIRaAC     ZZGSTP        BEGSR
BIRaAC*
BIRaAC     STPKEY        SETLL     PLTSTP1
BIRaAC     FOREVR        DOWEQ     FOREVR
BIRaAC     STPKEY        READE     PLTSTP1                                79
BIRaAC     *IN79         IFEQ      *ON
BIRaAC                   LEAVE
BIRaAC                   ENDIF
BIRaAC*
BIRaAC     PSSPLI        IFNE      PSPLID
BIRaAC     PSGEN         ORNE      1
BIRaAC                   LEAVE
BIRaAC                   ENDIF
BIRaAC*
BIRaAC     *BLANKS       LOOKUP    SCMP(Z)                                82
BIRaAC     *IN82         IFEQ      *ON
BIRaAC                   MOVEL     PSCOMP        SCMP(Z)
BIRaAC                   Z-ADD     PSSCOL        SCOL(Z)
BIRaAC                   Z-ADD     PSSROW        SROW(Z)
BIRaAC                   Z-ADD     PSSPLI        SPID(Z)
BIRaAC                   Z-ADD     PSSSTP        SSTP(Z)
BIRaAC                   Z-ADD     PSSPCS        SPCS(Z)
BIRaAC                   Z-ADD     PSSCUB        SCUB(Z)
BIRaAC                   ENDIF
BIRaAC*
BIRaAC                   ENDDO
BIRaAC*
BIRaAC                   ENDSR
     C*----------------------------------------------------------------
     C*
HARa C*  Get Pallet Stops Data & plug into arrays
     C*
HARa C     ZZGDPT        BEGSR
     C*
     C     STPKEY        SETLL     PLTSTP1
     C     FOREVR        DOWEQ     FOREVR
     C     STPKEY        READE     PLTSTP1                                79
     C     *IN79         IFEQ      *ON
     C                   LEAVE
     C                   ENDIF
     C*
     C     PSSPLI        IFNE      PSPLID
     C     PSGEN         ORNE      1
     C                   LEAVE
     C                   ENDIF
     C* Inner loop - Begin
     C     LB3KEY        SETLL     LABEL13
     C     FOREVR        DOWEQ     FOREVR
     C     LB3KEY        READE     LABEL13                                79
     C     *IN79         IFEQ      *ON
     C                   LEAVE
     C                   ENDIF
     C*
     C     LBGRP1        IFNE      'S'
     C                   ITER
     C                   ENDIF
     C*
HARb C     ITKEY         KLIST
HARb C                   KFLD                    LBWHSE
HARb C                   KFLD                    LBITEM
     C*
HARb C     ITKEY         CHAIN     PIRITEM                            79
HARb C                   MOVE      *BLANKS       WKWHDP            5
HARb C     *IN79         IFEQ      *ON
HARb C                   SELECT
HARe C     LBWHDP        WHENEQ    'BREAD'
HARe C                   MOVEL     'B'           WKWHDP
HARe C     LBWHDP        WHENEQ    'CLR  '
HARe C                   MOVEL     'C'           WKWHDP
HARe C     LBWHDP        WHENEQ    'CSPEC'
HARe C                   MOVEL     'W'           WKWHDP
HARe C     LBWHDP        WHENEQ    'DELI '
HARe C                   MOVEL     'D'           WKWHDP
HARe C     LBWHDP        WHENEQ    'FRZ  '
HARe C                   MOVEL     'F'           WKWHDP
HARb C     LBWHDP        WHENEQ    'GROCE'
HARb C                   MOVEL     'E'           WKWHDP
HARe C     LBWHDP        WHENEQ    'NM   '
HARe C                   MOVEL     'N'           WKWHDP
HARb C     LBWHDP        WHENEQ    'REPAC'
HARdAC     LBWHDP        OREQ      'TREPA'
HARb C                   MOVEL     'R'           WKWHDP
HARb C     LBWHDP        WHENEQ    'MEZZ'
HARdAC     LBWHDP        OREQ      'TRMEZ'
HARb C                   MOVEL     'M'           WKWHDP
HARe C     LBWHDP        WHENEQ    'TPHON'
HARe C                   MOVEL     'P'           WKWHDP
HARe C     LBWHDP        WHENEQ    'TOBAC'
HARe C                   MOVEL     'T'           WKWHDP
HARb C                   ENDSL
HARb C                   ELSE
HARb C                   MOVEL     ITWHDP        WKWHDP
HARb C                   ENDIF
HARb C*
     C                   Z-ADD     LBLBL#        WKLBL#            7 0
     C                   MOVE      *BLANKS       COMBO            12
     C                   MOVE      PSPLID        WKPLID            5
     C                   MOVE      PSSSTP        WKSSTP            2
     C     COMBO         CAT       WKPLID:0      COMBO
     C     COMBO         CAT       WKSSTP:0      COMBO
HARb C     COMBO         CAT       WKWHDP:0      COMBO
     C                   MOVE      *OFF          *IN81
     C                   MOVE      *OFF          *IN82
     C                   Z-ADD     1             P                 3 0
     C     COMBO         LOOKUP    COMB(P)                                82
     C     *IN82         IFEQ      *OFF
     C     *BLANKS       LOOKUP    COMB(P)                                81
     C                   ENDIF
     C* Found
     C     *IN81         IFEQ      *ON
     C                   MOVEL     PSCOMP        SCMP(P)
     C                   Z-ADD     PSSCOL        SCOL(P)
     C                   Z-ADD     PSSROW        SROW(P)
     C                   Z-ADD     PSSPLI        SPID(P)
     C                   Z-ADD     PSSSTP        SSTP(P)
     C                   Z-ADD     LBQPCK        SPCS(P)
     C                   Z-ADD     LBCUBE        SCUB(P)
     C                   MOVEL     COMBO         COMB(P)
     C                   MOVE      *BLANKS       WKSTDP            7
     C                   MOVE      PSSSTP        WKSSTP
     C     WKSTDP        CAT       WKSSTP:0      WKSTDP
HARb C     WKSTDP        CAT       WKWHDP:0      WKSTDP
     C                   MOVEL     WKSTDP        STDP(P)
     C                   ENDIF
     C* Found
     C     *IN82         IFEQ      *ON
     C                   ADD       LBQPCK        SPCS(P)
     C                   ADD       LBCUBE        SCUB(P)
     C                   ENDIF
     C                   ENDDO
     C* Inner loop - End
HARa C                   ENDDO
     C*
HARa C                   ENDSR
HARfAC*----------------------------------------------------------------
HARfAC*
HARfAC*  Get PLTMISC records for Harbor only
HARfAC*
HARfAC     ZZGTPM        BEGSR
HARfAC     PMKEY         KLIST
520 AC                   KFLD                    $WHSE
HARfAC                   KFLD                    $PRTID
HARfAC                   KFLD                    PSPLID
HARfAC                   KFLD                    PMCD
520 DC**                 KFLD                    $PWHSE
HARfAC                   MOVE      PMK(1)        PMCD             10
HARfAC     PMKEY         CHAIN     PLTMISC                            79
HARfAC     *IN79         IFEQ      *ON
HARfAC                   MOVEL     '      '      DS0H
HARfAC                   GOTO      ENDPM
HARfAC                   ENDIF
HARfAC                   MOVEL     PMVAL         C0LDSD
HARfAC     ENDPM         ENDSR
     C*----------------------------------------------------------------
BIRaAC*
BIRaAC*  Print Pallet Stops Summary
BIRaAC*
BIRaAC     ZZPSTP        BEGSR
BIRaAC*
BIRaAC     *IN90         IFNE      *ON
720hDC                   WRITE     STPCOL
720hDC                   WRITE     SKIP1
BIRaAC                   ENDIF
BIRaAC*
BIRaAC                   Z-ADD     1             Z
BIRaAC                   DO        9999          Z
BIRaAC*
BIRaAC     *IN90         IFEQ      *ON
650aAC                   select
ICBaAC                   when      client = icb
720hDc                   write     head1icb
GFCaAC                   when      client = glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
ISYbAC                             or client = isupply
SBRbDC***                          or client = SBertram
700cAC                   eval      val39 = route
720hDC                   write     head180
650aAC                   other
720hDc                   WRITE     HEAD1
650aAC                   endsl
DRY AC*
JORaDC*                  if        client = Dairyland
JORbAC                   SELECT
JORbMC                   when      client = Dairyland
720hAc*
720hAc*  Write values for any detail possibility to PS313WF Work File used by GUI Report
720hAc*
720hAc                   clear                   pswdatah2
720hAc                   eval      pswrpttp = 'H '
720hAc                   eval      pswrecF = 'HEAD2'
720hAc                   exsr      wrtWFrec
720hDc                   write     head2Dry
GFCaAC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRbDC***                          or client = SBertram
700cAC                   eval      val39 = route
720hDc                   write     head280
JORaDC*                  else
JORaAC                   when      client = Jordanos
720hDc                   write     head2Jor                             90
ASC AC                   when      client = agar
ASC AC**                 write     head2asc                             90
RFS AC                   when      client = rfs
720hDc                   write     head2rfs                             90
ICBaAC                   when      client = icb
ICBaAC     keyct         chain     custtrk                              90
ICBaAC                   if        %found(custtrk)
ICBaAC                   eval      tknbr=cttruk
ICBaAC                   eval      tkdrv=ctdrvr
ICBaAC                   else
ICBaAC                   eval      tknbr='_____'
ICBaAC                   eval      tkdrv='__________'
ICBaAC                   endif
720hDc                   write     head2icb                             90
ISYaAC                   when      client = isupply or
GMMaAC                             client = menumaker
720hDc                   write     head2isy
JORaAC                   other
720hDc                   WRITE     HEAD2
JORaAC                   endsl
JORaDC*                  endif
DRY AC*
720hDc                   WRITE     SKIP1
720hDc                   WRITE     STPCOL
720hDc                   WRITE     SKIP1
BIRaAC                   MOVE      *OFF          *IN90
BIRaAC                   ENDIF
BIRaAC*
BIRaAC     SCMP(Z)       IFNE      *BLANKS
BIRaAC                   MOVEL     SCMP(Z)       STPCMP
BIRaAC                   Z-ADD     SCOL(Z)       STPCLM
BIRaAC                   Z-ADD     SROW(Z)       STPROW
BIRaAC     SPID(Z)       IFNE      SAVPID
BIRaAC                   Z-ADD     SPID(Z)       STPPID
BIRaAC                   ELSE
BIRaAC                   Z-ADD     0             STPPID
BIRaAC                   ENDIF
BIRaAC                   Z-ADD     SSTP(Z)       STPSTP
BIRaAC                   Z-ADD     SPCS(Z)       STPPCS
BIRaAC                   Z-ADD     SCUB(Z)       STPCUB
720hDc                   WRITE     STPDTL
BIRaAC                   Z-ADD     SPID(Z)       SAVPID
BIRaAC                   ELSE
BIRaAC                   LEAVE
BIRaAC                   ENDIF
BIRaAC*
BIRaAC                   ENDDO
720hDc                   WRITE     SKIP1
BIRaAC*
BIRaAC                   ENDSR
510bAC*----------------------------------------------------------------
510bAC*
510bAC*  Get and Print Notes
510bAC*
510bAC     ZZRTNT        BEGSR
510baC                   Z-ADD     0             NTCNT             1 0
510bAC     RTKEY         SETLL     RTENOTE
510bAC     FOREVR        DOWEQ     FOREVR
510bAC     RTKEY         READE     RTENOTE                                79
510bAC     *IN79         IFEQ      *ON
510bAC                   LEAVE
510bAC                   ENDIF
510bAC                   MOVEL     RNNOTE        PRTNT
510bAC                   Z-ADD     1             NTCNT
720hDC                   WRITE     RTNOTES
510bAC                   ENDDO
510bAC     NTCNT         IFEQ      1
720hDC                   WRITE     SKIP1
510bAC                   ENDIF
510bAC                   ENDSR
     C*----------------------------------------------------------------
     C*
520 AC*  ZZFGTS   Get Host Stop Number
520 AC*
520 AC     ZZFGTS        BEGSR
520 AC*
520 MC                   Z-ADD     *ZEROS        $SORD
520 AC*
520 AC*    Get Stop From RTESTP
520 AC*
520 AC                   CALL      'GETSTOP'
520 MC                   PARM      '*PLTSTP '    $SCMD             8
520 MC                   PARM      $WHSE         $SWHSE            3 0
520 MC                   PARM      $PRTID        $SRTID            5
520 MC                   PARM                    $SORD             7 0
520 MC                   PARM                    $SDSTP            2 0
520 MC                   PARM                    $SSTP             5 0
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520 AC*
520 AC                   ENDSR
720cAC*----------------------------------------------------------------
720cAC*
720cAC*  ZZTOTSUM  Derive Compartment Summary by summarizing type
720cAC*            "B" and "P" records from PLTSUM
720cAC*
720cAC     ZZTOTSUM      BEGSR
720cA
720cA /free
720cA           setll ($whse:$prtid:' ') pltsum2;
720cA           reade ($whse:$prtid) pltsum2;
720cA
720cA           dow not %eof(pltsum2);
720cA              // Skip type "O" records for given route id
730aD              //if pstype = 'B' or pstype = 'P';
730aA              if pstype = 'P' and psgen=1;
720cA /end-free
720cA*
720cA*   Adjust columns 4 - 9 to 1 - 3.
720cA*   Overflow 'O' records use columns 1 - 9.
720cA*
720cAc                   select
720cAc                   when      pscol > 8
720cAc                   eval      pscol = pscol - 8
720cAc                   when      pscol > maxcol
720cAc                   eval      pscol = pscol - maxcol
720cAc                   endsl
720cAc*
720cA*
720cAC                   Z-ADD     1             N                 3 0
720cAC     PSCOMP        LOOKUP    COMP(N)                                81
720cA*  Found
720cAC     *IN81         IFEQ      *ON
720cAC                   IF        client=saval
720cAC                             or client = yhata
720cAC                             or client = royal
720cAC                             or client = cityline
720cAC                   move      psplid        RTPA(N)
720cAC                   movel     rout2a        RTPA(N)
720cAC                   endif
720cAC     PSCUBE        IFGT      0
720cAC                   ADD       1             NUM(N)
720cAC                   ENDIF
720cAC                   MOVE      *ON           FOUND             1
720cA*
720cA*   for the time per a conversation with Dave we are only
720cA*   going to add case count from pltsum file instead of going
720cA*   to label file.  When customer has issue of picking breakdowns
720cA*   we will have to revisit.  Reason for change is because trans
720cA*   in pltsum and label90 not matching because of bulk pick logic
720cA*
720cDc     PSTRN#        IFNE      0
720cDC                   EXSR      ZZPCS
720cDC                   ELSE
720cA*
720cA*  Include Bulk pick piece count in total.
720cA*  This will happen when bulk is loaded directly
720cA*  on the truck with no other items merged on pallet.
720cA*
720cDC     PSTRN#        IFEQ      0
720cDC     PSBCNT        ANDGT     0
720cAC                   ADD       PSPCS         PCN(N)
720cDC                   ENDIF
720cDC                   ENDIF
720cA*
720cAC                   ADD       pscube        CUB(N)
720cAC                   ADD       psswgt        WGT(N)
720cAc                   if        pscol = 1
720cAC                   ADD       psswgt        WGT1(N)
720cAc                   endif
720cAc                   if        pscol = 2
720cAC                   ADD       psswgt        WGT2(N)
720cAc                   endif
720cAc                   if        pscol = 3
720cAC                   ADD       psswgt        WGT3(N)
720cAc                   endif
720cAc                   if        pscol = 4
720cAC                   ADD       psswgt        WGT4(N)
720cAc                   endif
720cAc                   if        pscol = 5
720cAC                   ADD       psswgt        WGT5(N)
720cAc                   endif
720cAc                   if        pscol = 6
720cAC                   ADD       psswgt        WGT6(N)
720cAc                   endif
720cAc                   if        pscol = 7
720cAC                   ADD       psswgt        WGT7(N)
720cAc                   endif
720cAc                   if        pscol = 8
720cAC                   ADD       psswgt        WGT8(N)
720cAc                   endif
720cAc                   if        pscol = 9
720cAC                   ADD       psswgt        WGT9(N)
720cAc                   endif
720cA*
720cAC                   ELSE
720cA*  Not found
720cAC     *BLANKS       LOOKUP    COMP(N)                                82
720cAC     *IN82         IFEQ      *ON
720cAC                   MOVEL     PSCOMP        COMP(N)
720cAC                   IF        client=saval
720cAC                             or client = yhata
720cAC                             or client = royal
720cAC                             or client = cityline
720cAC                   move      psplid        RTPA(N)
720cAC                   movel     rout2a        RTPA(N)
720cAC                   endif
720cAC     PSCUBE        IFGT      0
720cAC                   Z-ADD     1             NUM(N)
720cAC                   ENDIF
720cAC                   MOVE      *OFF          FOUND
720cA*
720cA*   for the time per a conversation with Dave we are only
720cA*   going to add case count from pltsum file instead of going
720cA*   to label file.  When customer has issue of picking breakdowns
720cA*   we will have to revisit.  Reason for change is because trans
720cA*   in pltsum and label90 not matching because of bulk pick logic
720cA*
720cDC*    PSTRN#        IFNE      0
720cDC*                  EXSR      ZZPCS
720cDC*                  ELSE
720cA*
720cA*  Include Bulk pick piece count in total.
720cA*  This will happen when bulk is loaded directly
720cA*  on the truck with no other items merged on pallet.
720cA*
720cDC*    PSTRN#        IFEQ      0
720cDC*    PSBCNT        ANDGT     0
720cAC                   ADD       PSPCS         PCN(N)
720cDC*                  ENDIF
720cDC*                  ENDIF
720cA*
720cAC                   z-add     pscube        CUB(N)
720cAC                   z-add     psswgt        WGT(N)
720cAc                   if        pscol = 1
720cAC                   ADD       psswgt        WGT1(N)
720cAc                   endif
720cAc                   if        pscol = 2
720cAC                   ADD       psswgt        WGT2(N)
720cAc                   endif
720cAc                   if        pscol = 3
720cAC                   ADD       psswgt        WGT3(N)
720cAc                   endif
720cAc                   if        pscol = 4
720cAC                   ADD       psswgt        WGT4(N)
720cAc                   endif
720cAc                   if        pscol = 5
720cAC                   ADD       psswgt        WGT5(N)
720cAc                   endif
720cAc                   if        pscol = 6
720cAC                   ADD       psswgt        WGT6(N)
720cAc                   endif
720cAc                   if        pscol = 7
720cAC                   ADD       psswgt        WGT7(N)
720cAc                   endif
720cAc                   if        pscol = 8
720cAC                   ADD       psswgt        WGT8(N)
720cAc                   endif
720cAc                   if        pscol = 9
720cAC                   ADD       psswgt        WGT9(N)
720cAc                   endif
720cAC                   ENDIF
720cAC                   ENDIF
720cA /free
720cA              endif;
720cA              reade ($whse:$prtid) pltsum2;
720cA           enddo;
720cA /end-free
720cA
720cAC                   ENDSR
720hAC*----------------------------------------------------------------
720hAC*
720hAC*  wrtWFrec  Write records to Work File that MRC GUI report will
720hAC*            use to print Truck Summary Report
720hAC*
720hAC     wrtWFrec      BEGSR
720hA /free
                  pswWhse = $Whse;
                  pswRtid = $Prtid;
                  select;
                   when pswrpttp = 'GH ' and pswrecf='TOTCOL';
                     // Write Total Summary Headings
                    exec sql select count(*) into :rowseq
                             from tstotcol where pswrtid=:$prtid;
                    if sqlstt <> '00000' or rowseq=0;
                      pswrow=1;
                      pswtotcol1 = ' ';    // Compartment Code
                      calcula011 = %trim(pswtotcol1);
                      pswtotcol2 = 'Comp';
                      calcula012 = %trim(pswtotcol2);
                      pswtotcol3 = 'Pallets';
                      calcula013 = %trim(pswtotcol3);
                      pswtotcol4 = 'Cases';
                      calcula014 = %trim(pswtotcol4);
                      pswtotcol5 = 'Eaches';
                      calcula015 = %trim(pswtotcol5);
                      pswtotcol6 = 'Cube';
                      calcula016 = %trim(pswtotcol6);
                      pswtotcol7 = 'Weight';
                      calcula017 = %trim(pswtotcol7);
740 D                 //pswtotcol8 = '<B>Shorts</B>';
740 M                 pswtotcol8 = 'Shorts';
                      calcula018 = %trim(pswtotcol8);
                      pswtotcol9=' ';       //Column 9 currently empty
                      calcula019 = %trim(pswtotcol9);
                      pswtcol10=' ';      //Column 10 currently empty
                      calcula020 = %trim(pswtcol10);
                      calcula023 = '8';  // set to max columns sent down Total Summary
                      pswdata = pswdataTC;
                    endif;
                   when pswrpttp = 'G1 ' and pswrecf='TOTAL1';
                     // Write Total Summary Table by Compartment
                    exec sql select count(*) into :rowseq
                             from tstotsum where pswrtid=:$prtid
                                and pswrecf='TOTAL1';
                    if sqlstt = '00000';
                      rowseq=rowseq+1;
                    else;
                      rowseq=1;
                    endif;
                    pswrow=1;
                    pswtotsum1 = comprt;    // Compartment Code
                    pswtotsum2 = %trim(TPDESC);
                    pswtotsum3 = %editc(totcom:'4');
                    pswtotsum4 = %editc(totpcn:'4');
                    pswtotsum5 = %editc(totPC1:'4');
                    pswtotsum6 = %editc(totCUB:'4');
                    pswtotsum7 = %editc(totWGT:'4');
                    pswtotsum8 = ' ';    // COLUMN 8 EMPTY
                    pswtotsum9=' ';      //Column 9 currently empty
                    pswtsum10=' ';      //Column 10 currently empty
                    pswdata = pswdataTS;
                   when pswrpttp = 'G1 ' and pswrecf='TOTAL2';
                     // Write Grand Total for Compartment Table
                    exec sql select count(*) into :rowseq
                             from tstotsum where pswrtid=:$prtid
                                and pswrecf='TOTAL2';
                    if sqlstt <> '00000' or rowseq=0;
                      pswrow=1;
                      pswtotsum1 = ' ';    // Compartment Code
                      pswtotsum2 = 'Total ALL Compartments';
                      pswtotsum3 = %editc(gotcom:'4');
                      pswtotsum4 = %editc(gotpcn:'4');
                      pswtotsum5 = %editc(gotPC1:'4');
                      pswtotsum6 = %editc(gotCUB:'4');
                      pswtotsum7 = %editc(gotWGT:'4');
                      pswtotsum8 = ' ';    // COLUMN 8 EMPTY
                      pswtotsum9=' ';      //Column 9 currently empty
                      pswtsum10=' ';      //Column 10 currently empty
                      pswdata = pswdataTS;
                    endif;
                   when pswrpttp = 'H ' and (pswrecf='HEAD2');
                    // Write top Heading lines
                    exec sql select count(*) into :rowseq
                             from tshead2 where pswrtid=:$prtid;
                    if sqlstt <> '00000' or rowseq=0;
                      select;
                       when client = Dairyland;
                         pswrow=1;
                         pswfld1 = 'Route:  ' + %trim(route);
                         pswfld2 = 'Driver#: _____________';
                         pswfld3 = 'Truck#: ' + %trim(tknbr) + ' ___';
                         pswfld4 = 'Picked by: ______________';
                         pswfld5 = 'Loaded by: ______________';
                       other;
                         pswrow=1;
                         pswfld1 = 'Route:  ' + %trim(route);
                         pswfld2 = 'Driver#: _____________';
                         pswfld3 = 'Truck#: _____________';
EOP A                    if client=Earls;
EOP A                      pswfld4 = 'Time: ______________';
EOP A                    else;
                           pswfld4 = 'Picked by: ______________';
EOP A                    endif;
                         pswfld5 = 'Loaded by: ______________';
                         pswfld6 = 'Checked by: _____________';
EOP A                    if client=Earls;
EOP A                      pswfld7 = 'Load Bars/Straps: ________';
EOP A                    else;
                           pswfld7 = 'Drops by: ______________';
EOP A                    endif;
                         endsl;
                      pswdata = pswdataH2;
                    endif;
                   when pswrpttp = 'H ' and pswrecf='COLUMNS';
                    // Write top Heading lines
                    // Currently writing but cannot determine way to
                    // incorporate into M30200.  Import mis-aligns headings
                    // detail columns and you are not able to perform
                    // javascript when printing PDF.  Will think more
                    // after Magliner implementation at Chefs. Currently
                    // populates calcula fields and passed as parms
                    exec sql select count(*) into :rowseq
                             from tscols where pswrtid=:$prtid;
                    if sqlstt <> '00000' or rowseq=0;
                       pswrow=1;
                       pswcol1 = 'C';
                       calcula001 = %trim(pswcol1);
                       pswcol2 = %trim(sqtx1) + '<br/>' + %trim(sqtx11)
                                              + '<br/>' + %trim(sqtx12);
740aD                  //calcula002 = %trim(pswcol2);
740aM                  calcula002 = *blanks;
                       pswcol3 = 'Pallt<br/>Num';
                       calcula003 = %trim(pswcol3);
                       pswcol4 = 'Stop/' + '<br/>' + 'Range';
                       if client=andersondubose;
                         pswcol4 = %trim(pswcol4) + '<br/>' + 'SSCC18';
750aA                  else;
750aA                    // when super routes we print Child Routes
750aA                    // associated instead of Stop Range
750aA                    if %subst(rhrte:1:3) = '#SR';
750aA                      pswcol4 = 'Child<br/>Routes';
750aA                    endif;
                       endif;
                       calcula004 = %trim(pswcol4);
                       pswcol5 = 'Pcs';
                       calcula005 = %trim(pswcol5);
                       pswcol6 = 'Cube';
                       calcula006 = %trim(pswcol6);
                       pswcol7 = 'Wgt';
                       calcula007 = %trim(pswcol7);
                       calcula022 = '7';  // set to max columns for main table
                       pswcol8 = ' ';
740aA                  if calcula002 = *blanks;
740aA                    calcula022 = '6';  // Reduce columns if not printing unload sequence
740aA                  endif;
                       if client=Dairyland;
                         pswcol8 = 'Milk' + '<br/>' + 'Crate';
                         calcula022 = '8';  // set to max columns for main table
                       endif;
SBRbA                  if client = sBertram;
SBRbA                     pswcol8 = 'Dock' + '<br/>' + 'Door';
                          calcula022 = '7'; // set main table columns to 7 with dock door
SBRbA                  endif;
                       calcula008 = %trim(pswcol8);
                       pswcol9=' ';       //Column 9 currently empty
                       calcula009 = %trim(pswcol9);
                       pswcol10=' ';      //Column 10 currently empty
                       calcula010 = %trim(pswcol10);
                       pswdata = pswdataC;
                    endif;
                   when pswrpttp = 'D ' and pswrecf<>'ESTROVRF';
                    // for detail use Row number in PLTSUM
                    if pswrecf = 'GTOTWGT';
                      exec sql select max(pswrow) into :rowseq
                               from tsdetail where pswrtid=:$prtid
740 M                             and (pswrecf='ADETAIL' or pswrecf='CDASH1');
                      if sqlstt = '00000';
                        rowseq=rowseq+1;
                      else;
                        rowseq=1;
                      endif;
                      pswrow = rowseq;
                      pswsscc1='Wgt:';
                      pswwgt1=totwgt1;
                      pswsscc2='Wgt:';
                      pswwgt2=totwgt2;
                      pswsscc3='Wgt:';
                      pswwgt3=totwgt3;
                      pswsscc4='Wgt:';
                      pswwgt4=totwgt4;
                      pswsscc5='Wgt:';
                      pswwgt5=totwgt5;
                      pswsscc6='Wgt:';
                      pswwgt6=totwgt6;
                      pswsscc7='Wgt:';
                      pswwgt7=totwgt7;
                      pswsscc8='Wgt:';
                      pswwgt8=totwgt8;
                      pswsscc9='Wgt:';
                      pswwgt9=totwgt9;
                    else;
                      pswrow = prvrow;
                      pswbgc1  = backgroundclr;
                      pswpick1 = c1pick;
750 D                 //if pswspin1<>'SPIN' and c1cube=0
750 D                 //if pswspin1<>'S' and pswspin1<>'M'  and pswspin1<>'SM';
750 D                    //and c1spcs=0 and c1wgt=0 and c1cube=0;
740 A                    pswspin1 = c1comp;
750 D                 //else;
750 D                   // pswspin1 = *blanks;
750 D                 //endif;
                      pswstp11 = c1stpa;
                      pswstp21 = c1stpb;
                      pswdoor1 = c1door;
                      pswcube1 = c1cube;
                      pswspcs1 = c1spcs;
                      pswrtpa1 = c1rtpa;
                      pswwgt1 = c1wgt;
                      pswsscc1 = c1plid;
                      pswpal#1 = c1pal#;
750aA                 setChRtes(pswrow:'1');
                      pswpcmp1 = c1pcmp;
                      pswplid1 = c1plid;
                      pswbgc2  = backgroundclr;
                      pswpick2 = c2pick;
750 D                 //if pswspin2<>'SPIN' and c2cube=0
750 D                 //if pswspin2='    ' and c2cube=0
750 D                 //   and c2spcs=0 and c2wgt=0;
740 A                    pswspin2 = c2comp;
750 D                 //else;
750 D                 //   pswspin2 = *blanks;
750 D                 //endif;
                      pswstp12 = c2stpa;
                      pswstp22 = c2stpb;
                      pswdoor2 = c2door;
                      pswcube2 = c2cube;
                      pswspcs2 = c2spcs;
                      pswrtpa2 = c2rtpa;
                      pswwgt2 = c2wgt;
                      pswsscc2 = c2plid;
                      pswpal#2 = c2pal#;
750aA                 setChRtes(pswrow:'2');
                      pswpcmp2 = c2pcmp;
                      pswplid2 = c2plid;
                      pswbgc3  = backgroundclr;
                      pswpick3 = c3pick;
750 D                 //if pswspin3<>'SPIN' and c3cube=0
750 M                 //if pswspin3='    ' and c3cube=0
750 D                 //   and c3spcs=0 and c3wgt=0;
740 A                    pswspin3 = c3comp;
750 D                 //else;
750 D                 //   pswspin3 = *blanks;
750 D                 //endif;
                      pswstp13 = c3stpa;
                      pswstp23 = c3stpb;
                      pswdoor3 = c3door;
                      pswcube3 = c3cube;
                      pswspcs3 = c3spcs;
                      pswrtpa3 = c3rtpa;
                      pswwgt3 = c3wgt;
                      pswsscc3 = c3plid;
                      pswpal#3 = c3pal#;
750aA                 setChRtes(pswrow:'3');
                      pswpcmp3 = c3pcmp;
                      pswplid3 = c3plid;
                      pswbgc4  = backgroundclr;
                      pswpick4 = c4pick;
750 D                 //if pswspin4<>'SPIN' and c4cube=0
750 D                 //if pswspin4='    ' and c4cube=0
750 D                 //   and c4spcs=0 and c4wgt=0;
740 A                    pswspin4 = c4comp;
750 D                 //else;
750 D                 //   pswspin4 = *blanks;
750 D                 //endif;
                      pswstp14 = c4stpa;
                      pswstp24 = c4stpb;
                      pswdoor4 = c4door;
                      pswcube4 = c4cube;
                      pswspcs4 = c4spcs;
                      pswrtpa4 = c4rtpa;
                      pswwgt4 = c4wgt;
                      pswsscc4 = c4plid;
                      pswpal#4 = c4pal#;
750aA                 setChRtes(pswrow:'4');
                      pswpcmp4 = c4pcmp;
                      pswplid4 = c4plid;
                      pswbgc5  = backgroundclr;
                      pswpick5 = c5pick;
750 D                 //if pswspin5<>'SPIN' and c5cube=0
750 D                 //if pswspin5='    ' and c5cube=0
750 D                 //   and c5spcs=0 and c5wgt=0;
740 A                    pswspin5 = c5comp;
750 D                 //else;
750 D                 //   pswspin5 = *blanks;
750 D                 //endif;
                      pswstp15 = c5stpa;
                      pswstp25 = c5stpb;
                      pswdoor5 = c5door;
                      pswcube5 = c5cube;
                      pswspcs5 = c5spcs;
                      pswrtpa5 = c5rtpa;
                      pswwgt5 = c5wgt;
                      pswsscc5 = c5plid;
                      pswpal#5 = c5pal#;
750aA                 setChRtes(pswrow:'5');
                      pswpcmp5 = c5pcmp;
                      pswplid5 = c5plid;
                      pswbgc6  = backgroundclr;
                      pswpick6 = c6pick;
750 D                 //if pswspin6<>'SPIN' and c6cube=0
750 D                 //if pswspin6='    ' and c6cube=0
750 D                 //   and c6spcs=0 and c6wgt=0;
740 A                    pswspin6 = c6comp;
750 D                 //else;
750 D                 //   pswspin6 = *blanks;
750 D                 //endif;
                      pswstp16 = c6stpa;
                      pswstp26 = c6stpb;
                      pswdoor6 = c6door;
                      pswcube6 = c6cube;
                      pswspcs6 = c6spcs;
                      pswrtpa6 = c6rtpa;
                      pswwgt6 = c6wgt;
                      pswsscc6 = c6plid;
                      pswpal#6 = c6pal#;
750aA                 setChRtes(pswrow:'6');
                      pswpcmp6 = c6pcmp;
                      pswplid6 = c6plid;
                      pswbgc7  = backgroundclr;
                      pswpick7 = c7pick;
750 D                 //if pswspin7<>'SPIN' and c7cube=0
750 D                 //if pswspin7='    ' and c7cube=0
750 D                 //   and c7spcs=0 and c7wgt=0;
740 A                    pswspin7 = c7comp;
750 D                 //else;
750 D                 //   pswspin7 = *blanks;
750 D                 //endif;
                      pswstp17 = c7stpa;
                      pswstp27 = c7stpb;
                      pswdoor7 = c7door;
                      pswcube7 = c7cube;
                      pswspcs7 = c7spcs;
                      pswrtpa7 = c7rtpa;
                      pswwgt7 = c7wgt;
                      pswsscc7 = c7plid;
                      pswpal#7 = c7pal#;
750aA                 setChRtes(pswrow:'7');
                      pswpcmp7 = c7pcmp;
                      pswplid7 = c7plid;
                      pswbgc8  = backgroundclr;
                      pswpick8 = c8pick;
750 D                 //if pswspin8<>'SPIN' and c8cube=0
750 D                 //if pswspin8='    ' and c8cube=0
750 D                 //   and c8spcs=0 and c8wgt=0;
740 A                    pswspin8 = c8comp;
750 D                 //else;
750 D                 //   pswspin8 = *blanks;
750 D                 //endif;
                      pswstp18 = c8stpa;
                      pswstp28 = c8stpb;
                      pswdoor8 = c8door;
                      pswcube8 = c8cube;
                      pswspcs8 = c8spcs;
                      pswrtpa8 = c8rtpa;
                      pswwgt8 = c8wgt;
                      pswsscc8 = c8plid;
                      pswpal#8 = c8pal#;
750aA                 setChRtes(pswrow:'8');
                      pswpcmp8 = c8pcmp;
                      pswplid8 = c8plid;
                      pswbgc9  = backgroundclr;
                      pswpick9 = c9pick;
750 D                 //if pswspin9<>'SPIN' and c9cube=0
750 D                 //if pswspin9='    ' and c9cube=0
750 D                 //   and c9spcs=0 and c9wgt=0;
740 A                    pswspin9 = c9comp;
750 D                 //else;
750 D                 //   pswspin9 = *blanks;
750 D                 //endif;
                      pswstp19 = c9stpa;
                      pswstp29 = c9stpb;
                      pswdoor9 = c9door;
                      pswcube9 = c9cube;
                      pswspcs9 = c9spcs;
                      pswrtpa9 = c9rtpa;
                      pswwgt9 = c9wgt;
                      pswsscc9 = c9plid;
                      pswpal#9 = c9pal#;
750aA                 setChRtes(pswrow:'9');
                      pswpcmp9 = c9pcmp;
                      pswplid9 = c9plid;
                    endif;
                    pswdata = pswdatad;
                   other;
                    // for undefined lines
                    exec sql select max(pswrow) into :rowseq
                              from ps313Wf
                               where pswwhse=:$whse and pswrtid=:$prtid;
740 M               if pswrecf='ESTROVRF';
                      // key wise this makes sure Overflow line will print just after
                      // last detail line and before first overflow line
740 M                 pswrow = rowseq + 1;
                    else;
                      pswrow = rowseq + 1;
                    endif;
                  endsl;
                  write pswrec;
720hA /end-free
720hAC                   ENDSR
750cAC*----------------------------------------------------------------
750cAC*
750cAC*  wrtSRCrtes  Write child routes to summary map beyond 6 for
750cAC*              a Super Route. The first two grouping of child routes
750cAc*              are written into TSDETAIL on ADETAIL record and CDASH1
750cAc*              record.  The groupings for 3 thru 6 are printed here
750cAc*              if anything exist.  The record type is DCHRTE so it falls
750cAc*              in behind ADETAIL and CDASH1.
750cAC*
750cAC     wrtSRCrtes    BEGSR
750cA /free
            // Write Extra Child Routes line if more than six exist
            // first extra line of potential 4
            if wrkrlst13 <>*blanks or wrkrlst23<>*blanks
               or wrkrlst43 <>*blanks or wrkrlst53<>*blanks
               or wrkrlst63 <>*blanks or wrkrlst73<>*blanks
               or wrkrlst83 <>*blanks or wrkrlst93<>*blanks;
                  clear pswdatad;
                  pswWhse = $Whse;
                  pswRtid = $Prtid;
                  pswrpttp = 'D';
                  pswrecF = 'DCHRTE';
                  pswbgc1  = backgroundclr;
                  pssrlst11 = wrkrlst13;
                  pssrlst21 = wrkrlst23;
                  pssrlst31 = wrkrlst33;
                  pssrlst41 = wrkrlst43;
                  pssrlst51 = wrkrlst53;
                  pssrlst61 = wrkrlst63;
                  pssrlst71 = wrkrlst73;
                  pssrlst81 = wrkrlst83;
                  pssrlst91 = wrkrlst93;
                  pswdata = pswdatad;
                  write pswrec;
            endif;
            // second extra line of potential 4
            if wrkrlst14 <>*blanks or wrkrlst24<>*blanks
               or wrkrlst44 <>*blanks or wrkrlst54<>*blanks
               or wrkrlst64 <>*blanks or wrkrlst74<>*blanks
               or wrkrlst84 <>*blanks or wrkrlst94<>*blanks;
                  clear pswdatad;
                  pswWhse = $Whse;
                  pswRtid = $Prtid;
                  pswrpttp = 'D';
                  pswrecF = 'DCHRTE';
                  pswbgc1  = backgroundclr;
                  pssrlst11 = wrkrlst14;
                  pssrlst21 = wrkrlst24;
                  pssrlst31 = wrkrlst34;
                  pssrlst41 = wrkrlst44;
                  pssrlst51 = wrkrlst54;
                  pssrlst61 = wrkrlst64;
                  pssrlst71 = wrkrlst74;
                  pssrlst81 = wrkrlst84;
                  pssrlst91 = wrkrlst94;
                  pswdata = pswdatad;
                  write pswrec;
            endif;
            // third extra line of potential 4
            if wrkrlst15 <>*blanks or wrkrlst25<>*blanks
               or wrkrlst45 <>*blanks or wrkrlst55<>*blanks
               or wrkrlst65 <>*blanks or wrkrlst75<>*blanks
               or wrkrlst85 <>*blanks or wrkrlst95<>*blanks;
                  clear pswdatad;
                  pswWhse = $Whse;
                  pswRtid = $Prtid;
                  pswrpttp = 'D';
                  pswrecF = 'DCHRTE';
                  pswbgc1  = backgroundclr;
                  pssrlst11 = wrkrlst15;
                  pssrlst21 = wrkrlst25;
                  pssrlst31 = wrkrlst35;
                  pssrlst41 = wrkrlst45;
                  pssrlst51 = wrkrlst55;
                  pssrlst61 = wrkrlst65;
                  pssrlst71 = wrkrlst75;
                  pssrlst81 = wrkrlst85;
                  pssrlst91 = wrkrlst95;
                  pswdata = pswdatad;
                  write pswrec;
            endif;
            // forth extra line of potential 4
            if wrkrlst16 <>*blanks or wrkrlst26<>*blanks
               or wrkrlst46 <>*blanks or wrkrlst56<>*blanks
               or wrkrlst66 <>*blanks or wrkrlst76<>*blanks
               or wrkrlst86 <>*blanks or wrkrlst96<>*blanks;
                  clear pswdatad;
                  pswWhse = $Whse;
                  pswRtid = $Prtid;
                  pswrpttp = 'D';
                  pswrecF = 'DCHRTE';
                  pswbgc1  = backgroundclr;
                  pssrlst11 = wrkrlst16;
                  pssrlst21 = wrkrlst26;
                  pssrlst31 = wrkrlst36;
                  pssrlst41 = wrkrlst46;
                  pssrlst51 = wrkrlst56;
                  pssrlst61 = wrkrlst66;
                  pssrlst71 = wrkrlst76;
                  pssrlst81 = wrkrlst86;
                  pssrlst91 = wrkrlst96;
                  pswdata = pswdatad;
                  write pswrec;
            endif;
750cA /end-free
750cAC                   ENDSR
750cAc
750 A*----------------------------------------------------------------
750 A*  spinMerge  Return Spin/Merge indicators for location/Pallet
750 A*----------------------------------------------------------------
750 A
750 Ap spinMerge       b
750 Ad spinMerge       pi             4
750 Ad  iirow                         2  0
750 Ad  iicol                         1  0
750 Ad  iiplid                        7p 0
750 A
750 A* Local Variables
750 A
750 Ad spinmrg         s              4
750 Ad wrkid           s             20
750 Ad count           s              2  0
750 A
750 A /free
750 A
750 A  spinmrg = *blanks;
750 A  // look for spun row/column
750 A  wrkid   = 'lr' + %char(iirow) + 'c' + %char(iicol);
750 A
750 A  count=0;
750 A  exec sql select count(*) into :count
750 A         from ddwrkflds
750 A      where ddwwhse=:$whse and ddwrtid=:$pRtid
750 A           and ddwsnap=0 and ddwid=:wrkid
750 A           and ddwspin='Y';
750 A  if sqlstt = '00000';
750 A    if count>0;
750 A      spinmrg='S';
750 A    endif;
750 A  endif;
750 A
750 A  // now look for any merges for this row, col and plid
750 A  count=0;
750 A  exec sql select count(*) into :count
750 A         from ddwrkflds
750 A      where ddwwhse=:$whse and ddwrtid=:$pRtid
750 A           and ddwsnap=0 and ddwrow=:iirow and ddwcol=:iicol
750 A           and ddwmrg='Y';
750 A  if sqlstt = '00000';
750 A    if count>0;
750 A      if spinmrg=*blanks;
750 A        spinmrg='M';
750 A      else;
750 A        %subst(spinmrg:2:1)='M';
750 A      endif;
750 A    endif;
750 A  endif;
750 A
750 A  return spinMrg;
750 A
750 A /end-free
750 A
750 Ap                 e
750aA
750aA*----------------------------------------------------------------
750aA*  setChRtes  Find and return Child Routes if Super Route
750aA*----------------------------------------------------------------
750aA
750aAp setChRtes       b
750aAd setChRtes       pi
750aAd  iRow                          2  0 value
750aAd  iColNum                       1    const
750aA
750aA* Local Variables
750aA
750aAd nsr             s              3  0
750aAd rowCol          s              3
750aA
750aA /free
750aA
750aA     // only Super Routes will populate this array
750aA     // The Row being sent here is a sequence row in PS313WF
750aA     // used to print the GUI Truck Map.  This is offset by one
750aA     // with the Heading line so we subtract that 1 here to
750aA     // locate the proper row in the array that was loaded by
750aA     // actual row/col from pltsum in INZSR for route id
750aA     iRow = iRow - 1;
750aA     if iRow < 0;
750aA       iRow = 0;
750aA     endif;
750aA     rowCol = %editc(iRow:'X') + iColNum;
750aA     if %subst(rhrte:1:3) = '#SR';
750aA       nsr = %lookup(rowCol:arySR(*).iRowCol :1);
750aA       if nsr = 0;
750aA         // if pallet number not found in arySR we return blanks for
750aA         // repective position
750aA         select;
750aA           when iColNum = '1';
750aA             pssrlst11=*blanks;
750aA             pssrlst12=*blanks;
750cA             wrkrlst13=*blanks;
750cA             wrkrlst14=*blanks;
750cA             wrkrlst15=*blanks;
750cA             wrkrlst16=*blanks;
750aA           when iColNum = '2';
750aA             pssrlst21=*blanks;
750aA             pssrlst22=*blanks;
750cA             wrkrlst23=*blanks;
750cA             wrkrlst24=*blanks;
750cA             wrkrlst25=*blanks;
750cA             wrkrlst26=*blanks;
750aA           when iColNum = '3';
750aA             pssrlst31=*blanks;
750aA             pssrlst32=*blanks;
750cA             wrkrlst33=*blanks;
750cA             wrkrlst34=*blanks;
750cA             wrkrlst35=*blanks;
750cA             wrkrlst36=*blanks;
750aA           when iColNum = '4';
750aA             pssrlst41=*blanks;
750aA             pssrlst42=*blanks;
750cA             wrkrlst43=*blanks;
750cA             wrkrlst44=*blanks;
750cA             wrkrlst45=*blanks;
750cA             wrkrlst46=*blanks;
750aA           when iColNum = '5';
750aA             pssrlst51=*blanks;
750aA             pssrlst52=*blanks;
750cA             wrkrlst53=*blanks;
750cA             wrkrlst54=*blanks;
750cA             wrkrlst55=*blanks;
750cA             wrkrlst56=*blanks;
750aA           when iColNum = '6';
750aA             pssrlst61=*blanks;
750aA             pssrlst62=*blanks;
750cA             wrkrlst63=*blanks;
750cA             wrkrlst64=*blanks;
750cA             wrkrlst65=*blanks;
750cA             wrkrlst66=*blanks;
750aA           when iColNum = '7';
750aA             pssrlst71=*blanks;
750aA             pssrlst72=*blanks;
750cA             wrkrlst73=*blanks;
750cA             wrkrlst74=*blanks;
750cA             wrkrlst75=*blanks;
750cA             wrkrlst76=*blanks;
750aA           when iColNum = '8';
750aA             pssrlst81=*blanks;
750aA             pssrlst82=*blanks;
750cA             wrkrlst83=*blanks;
750cA             wrkrlst84=*blanks;
750cA             wrkrlst85=*blanks;
750cA             wrkrlst86=*blanks;
750aA           when iColNum = '9';
750aA             pssrlst91=*blanks;
750aA             pssrlst92=*blanks;
750cA             wrkrlst93=*blanks;
750cA             wrkrlst94=*blanks;
750cA             wrkrlst95=*blanks;
750cA             wrkrlst96=*blanks;
750aA         endsl;
750aA         return;
750aA       else;
750aA         // else, we found the pallet in the child routes array so
750aA         // we will populate those routes in respective position
750aA         select;
750aA           when iColNum = '1';
750aA             pssrlst11 = insrtComma(arySR(nsr).First3);
750aA             pssrlst12 = insrtComma(arySR(nsr).Second3);
750aA             wrkrlst13 = insrtComma(arySR(nsr).Third3);
750aA             wrkrlst14 = insrtComma(arySR(nsr).Forth3);
750aA             wrkrlst15 = insrtComma(arySR(nsr).Fifth3);
750aA             wrkrlst16 = insrtComma(arySR(nsr).Sixth3);
750aA           when iColNum = '2';
750aA             pssrlst21 = insrtComma(arySR(nsr).First3);
750aA             pssrlst22 = insrtComma(arySR(nsr).Second3);
750aA             wrkrlst23 = insrtComma(arySR(nsr).Third3);
750aA             wrkrlst24 = insrtComma(arySR(nsr).Forth3);
750aA             wrkrlst25 = insrtComma(arySR(nsr).Fifth3);
750aA             wrkrlst26 = insrtComma(arySR(nsr).Sixth3);
750aA           when iColNum = '3';
750aA             pssrlst31 = insrtComma(arySR(nsr).First3);
750aA             pssrlst32 = insrtComma(arySR(nsr).Second3);
750aA             wrkrlst33 = insrtComma(arySR(nsr).Third3);
750aA             wrkrlst34 = insrtComma(arySR(nsr).Forth3);
750aA             wrkrlst35 = insrtComma(arySR(nsr).Fifth3);
750aA             wrkrlst36 = insrtComma(arySR(nsr).Sixth3);
750aA           when iColNum = '4';
750aA             pssrlst41 = insrtComma(arySR(nsr).First3);
750aA             pssrlst42 = insrtComma(arySR(nsr).Second3);
750aA             wrkrlst43 = insrtComma(arySR(nsr).Third3);
750aA             wrkrlst44 = insrtComma(arySR(nsr).Forth3);
750aA             wrkrlst45 = insrtComma(arySR(nsr).Fifth3);
750aA             wrkrlst46 = insrtComma(arySR(nsr).Sixth3);
750aA           when iColNum = '5';
750aA             pssrlst51 = insrtComma(arySR(nsr).First3);
750aA             pssrlst52 = insrtComma(arySR(nsr).Second3);
750aA             wrkrlst53 = insrtComma(arySR(nsr).Third3);
750aA             wrkrlst54 = insrtComma(arySR(nsr).Forth3);
750aA             wrkrlst55 = insrtComma(arySR(nsr).Fifth3);
750aA             wrkrlst56 = insrtComma(arySR(nsr).Sixth3);
750aA           when iColNum = '6';
750aA             pssrlst61 = insrtComma(arySR(nsr).First3);
750aA             pssrlst62 = insrtComma(arySR(nsr).Second3);
750aA             wrkrlst63 = insrtComma(arySR(nsr).Third3);
750aA             wrkrlst64 = insrtComma(arySR(nsr).Forth3);
750aA             wrkrlst65 = insrtComma(arySR(nsr).Fifth3);
750aA             wrkrlst66 = insrtComma(arySR(nsr).Sixth3);
750aA           when iColNum = '7';
750aA             pssrlst71 = insrtComma(arySR(nsr).First3);
750aA             pssrlst72 = insrtComma(arySR(nsr).Second3);
750aA             wrkrlst73 = insrtComma(arySR(nsr).Third3);
750aA             wrkrlst74 = insrtComma(arySR(nsr).Forth3);
750aA             wrkrlst75 = insrtComma(arySR(nsr).Fifth3);
750aA             wrkrlst76 = insrtComma(arySR(nsr).Sixth3);
750aA           when iColNum = '8';
750aA             pssrlst81 = insrtComma(arySR(nsr).First3);
750aA             pssrlst82 = insrtComma(arySR(nsr).Second3);
750aA             wrkrlst83 = insrtComma(arySR(nsr).Third3);
750aA             wrkrlst84 = insrtComma(arySR(nsr).Forth3);
750aA             wrkrlst85 = insrtComma(arySR(nsr).Fifth3);
750aA             wrkrlst86 = insrtComma(arySR(nsr).Sixth3);
750aA           when iColNum = '9';
750aA             pssrlst91 = insrtComma(arySR(nsr).First3);
750aA             pssrlst92 = insrtComma(arySR(nsr).Second3);
750aA             wrkrlst93 = insrtComma(arySR(nsr).Third3);
750aA             wrkrlst94 = insrtComma(arySR(nsr).Forth3);
750aA             wrkrlst95 = insrtComma(arySR(nsr).Fifth3);
750aA             wrkrlst96 = insrtComma(arySR(nsr).Sixth3);
750aA         endsl;
750aA         return;
750aA       endif;
750aA     endif;
750aA
750aA /end-free
750aA
750aAp                 e
750aA
750cA*----------------------------------------------------------------
750cA*  insrtComma  Insert comma between Child Routes
750cA*----------------------------------------------------------------
750cA
750cAp insrtComma      b
750cAd insrtComma      pi            17
750cAd  chRoutes                     17
750aA
750aA* Local Variables
750aA
750aAd wrkRoutes       s             17
750cAd
750cAd
750cA /free
750cA     wrkRoutes = *blanks;
750cA
750cA     if %subst(chRoutes:1:5) <> *blanks;
750cA        wrkRoutes = %trim(%subst(chRoutes:1:5));
750cA     endif;
750cA
750cA     if %subst(chRoutes:6:5) <> *blanks;
750cA        wrkRoutes = %trim(wrkRoutes) + ',' + %trim(%subst(chRoutes:6:5));
750cA     endif;
750cA
750cA     if %subst(chRoutes:11:5) <> *blanks;
750cA        wrkRoutes = %trim(wrkRoutes) + ',' + %trim(%subst(chRoutes:11:5));
750cA     endif;
750cA
750cA     return wrkRoutes;
750cA
750cA /end-free
750cA
750cAp                 e

     O*----------------------------------------------------------------
     O*
     O* Compile time tables
     O*
     O*OVRPRTF statment
     O*OVRPRTF FILE(PS311PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
     O*OVRPRTF FILE(PS311PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX) COP
     O*OVRPRTF FILE(PS311PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX) COP
**   PMK - KEY FIELD FOR PLTMISC   - HARfA
HARBORLDSD
