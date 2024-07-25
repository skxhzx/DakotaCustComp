     H DFTACTGRP(*NO)
     F*----------------------------------------------------------------
     F*   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     *wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
     * PLEASE COMPILE WITH DEFAULT ACTIVATION GROUP (*NO).
     *wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
     *  This is a copy of PS311 as of 04/12/2018.  Changes for this
     *  should be considered for PS311 as well.  This program is called
     *  by PS311 if data area DRAGDROP2 is active and set *on (1)
     *wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
     F*----------------------------------------------------------------
     F*  PS312     Truck summary
     F*  12 April 2018
     F*  Kenneth Elder
     F*
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
730 A*    06/20/19  KDE  7.30
     *     - Enh:  Dubose requested we center Truck Map on page
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Anderson Dubose
     F*
ADCaAF*    07/27/18  KDE   ADCa
     F*      - Do not print Row/Col in headers or detail body per Adam
     F*        Clark.  Their loaders feel the sheet is to cluttered
     F*        and Row/Col is not being used anyway
     F*
ADCbAF*    06/20/19  KDE   ADCb
     F*      - Justin sent a copy of the Truck Map requesting that
     F*        column for pallet number be eliminated, the Asterisks
     F*        in compartment column, reposition highlighted columns,
     F*        and center in the page (portrait)
ADCcAF*    07/12/19  KDE   ADCc
     F*      - Justin requested that we print a Load Shee with
     F*        checks for each route
ADCdAF*    10/21/19  KDE   ADCd
     F*      - Justin requested we print Route Notes at end instead of beginning
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
     F*  Client Custom Revisions: BiRite
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
520bAFPS312PR   O    E             PRINTER OFLIND(*IN90)
     D*----------------------------------------------------------------
     D*
     D*  Table and array
     D*
520bDD*                   A80        80  1
BIR DD*                   OVRPRT  1   1 80
HARgMD*                   OVRPRT  1   2 80
520bDD*                   OVRPRT  1   3 80
     D*                   RPD     1   3 30
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
500dAD*----------------------------------------------------------------
500dAD*  Customer id
500dAD*
     D @GETCL          C                   CONST('GETCLIENT')
     D*----------------------------------------------------------------
     D*  General Data structure.
     D*
     D DS0             DS                  inz
     D  C0COMP                 1      4
     D  C0PICK                 5      8
     D  C0CUBE                 9     13  2
     D  C0STP1                14     15  0
     D  C0STP2                16     17  0
416 AD  C0DOOR                18     20  0
500e D  C0SPCS                21     25  0
SVLaAD  C0RTPA                26     32
650bAD  C0WGT                 33     38  0
     D*  Data structure for column 1.
     D*
     D DS1             DS                  OCCURS(50) inz
     D  C1COMP                 1      4
     D  C1PICK                 5      8
     D  C1CUBE                 9     13  2
     D  C1STP1                14     15  0
     D  C1STP2                16     17  0
416 AD  C1DOOR                18     20  0
500e D  C1SPCS                21     25  0
SVLaAD  C1RTPA                26     32
650bAD  C1WGT                 33     38  0
     D*
     D*  Data structure for column 2.
     D*
     D DS2             DS                  OCCURS(50) inz
     D  C2COMP                 1      4
     D  C2PICK                 5      8
     D  C2CUBE                 9     13  2
     D  C2STP1                14     15  0
     D  C2STP2                16     17  0
416 AD  C2DOOR                18     20  0
500e D  C2SPCS                21     25  0
SVLaAD  C2RTPA                26     32
650bAD  C2WGT                 33     38  0
720 AD*
720 AD*  Data structure for column 3.
720 AD*
720 AD DS5             DS                  OCCURS(50) inz
720 AD  C3COMP                 1      4
720 AD  C3PICK                 5      8
720 AD  C3CUBE                 9     13  2
720 AD  C3STP1                14     15  0
720 AD  C3STP2                16     17  0
720 AD  C3DOOR                18     20  0
720 AD  C3SPCS                21     25  0
720 AD  C3RTPA                26     32
720 AD  C3WGT                 33     38  0
HARfAD DS0H            DS
HARfAD  C0LDSD                 1      6
HARfAD DS3             DS                  OCCURS(50)
HARfAD  C1LDSD                 1      6
HARfAD DS4             DS                  OCCURS(50)
HARfAD  C2LDSD                 1      6
720 AD DS6             DS                  OCCURS(50)
720 AD  C3LDSD                 1      6
720dA***    Used to Accumulate SSCC18 numbers by column for each summary position
720dAd                 ds
720dAd ssccAry                             dim(9)
720dAD  sscc1                         7a   overlay(ssccary:*next)
720dAD  sscc2                         7a   overlay(ssccary:*next)
720dAD  sscc3                         7a   overlay(ssccary:*next)
720dA***    Used to Accumulate Pallet numbers by column for each summary position
720dAd                 ds
720dAd palAry                              dim(9)
720dAD  pal1                          5s 0 overlay(palary:*next)
720dAD  pal2                          5s 0 overlay(palary:*next)
720dAD  pal3                          5s 0 overlay(palary:*next)
720dA***    Used to Accumulate Pallet Compartment column for each summary position
720dAd                 ds
720dAd palCAry                             dim(9)
720dAD  palc1                         7a   overlay(palcary:*next)
720dAD  palc2                         7a   overlay(palcary:*next)
720dAD  palc3                         7a   overlay(palcary:*next)
720gA***    Used to Accumulate Pallet Compartment column for each summary position
720gAd                 ds
720gAd palcntAry                           dim(9)
720gAD  palcnt1                       5s 0 overlay(palcntAry:*next)
720gAD  palcnt2                       5s 0 overlay(palcntAry:*next)
720gAD  palcnt3                       5s 0 overlay(palcntAry:*next)
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
650bAD actcub          S              5  2
650dAD prvplid         S              7  0
720dAd ssccCnt         s              2  0
720eAd firstovl        s               n
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
     C*  Report Heading
     C*
     C*
     C*  Start new page if one of following happened.
     C*     - Filled page.
     C*
510aDC**         COUNT     IFEQ RECPAG
510aMC     *IN90         IFEQ      *ON
520bDC**   $EP           IFEQ      ' '
520bDC**                 EXSR      OPNPRT
520bDC**                 ELSE
520bDC**                 EXSR      OPNPRX
520bDC**                 ENDIF
     C                   EXSR      ZRFRMT
     C                   EXSR      ZRHEAD
     C                   ENDIF
     C*
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
650dAC                   if        psplid = prvplid
650dAC                   goto      nxtrec
650dAC                   endif
a50dAC                   eval      prvplid = psplid
720eAc*
720eA /free
720eA       // when unload sequence is 71 or higher this is
720eA       // overflow and we should force columns 1 thru 3
720eA       // to prevent many lines consumed
720eA       if psunld >= 71;
720eA          if prvcol > 2 or firstovl=*on;
720eA             pscol = 1;
720eA          else;
720eA             pscol = prvcol + 1;
720eA          endif;
720eA          if firstovl = *off;
720eA             psrow = prvrow;
720eA          endif;
720eA       endif;
720eA /end-free
720eA *
720bAc*
720bAc*   See if we have jumped to a new row
720bAc*   Overflow pallets can have columns 1 - 9
720bAc*   Start new row for 4 - 6 and 7 - 9
720bAc*
720bA /free
720bA    if psrow <> prvrow
720bA      or (prvcol <= 3 and pscol > 3)
720bA      or (prvcol >= 4 and prvcol <= 6 and pscol > 6);
720bA        newRow = *on;
720bA    else;
720bA        newRow = *off;
720bA    endif;
720bA    prvrow = psrow;
720bA    prvcol = pscol;
720bA /end-free
720aAc*
720bAc*   Adjust columns 4 - 9 to 1 - 3.
720bAc*   Overflow 'O' records use columns 1 - 9.
720aAc*
720aAc                   z-add     pscol         actcol            1 0
720aAc                   select
720aAc                   when      pscol > 6
720aAc                   eval      pscol = pscol - 6
720aAc                   when      pscol > 3
720aAc                   eval      pscol = pscol - 3
720aAc                   endsl
720aAc*
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
730 Ac                   if        *in90
730 AC                   EXSR      ZRFRMT
730 AC                   EXSR      ZRHEAD
730 Ac                   endif
720eAc                   write     strovrf
730aAc                   write     dash2ADC
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
                   chain (pswhse:pstruk:psrow) trktmpd;
                   if not %found(trktmpd);
                      ttdspin1=' ';
                      ttdspin2=' ';
                      ttdspin3=' ';
                   endif;
                   select;
                      when pscol=1;
                         if ttdspin1 = 'Y';
                            c0comp = 'SPIN';
                         else;
                            c0comp= *blanks;
                         endif;
                      when pscol=2;
                         if ttdspin2 = 'Y';
                            c0comp = 'SPIN';
                         else;
                            c0comp = *blanks;
                         endif;
                      when pscol=3;
                         if ttdspin3 = 'Y';
                            c0comp = 'SPIN';
                         else;
                            c0comp = *blanks;
                         endif;
                   endsl;
      /end-free
417 AC*
417 AC*    Pallet number built from Row/Column
720fA /free
ADCaA                    if client <> andersondubose;
720fA                       c0pick = %char(psrow) + '/' + %char(pscol);
ADCaA                    else;
ADCaA                       c0pick = *blanks;
ADCaA                    endif;
720fA /end-free
     C                   Z-ADD     PSSTP1        C0STP1
     C                   Z-ADD     PSSTP2        C0STP2
500e C*650bD             Z-ADD     PSPCS         C0SPCS
650bAC     PSTRN#        IFNE      0
657bAC                   EXSR      ZZPCSplt
650bAC                   ELSE
650bAC     PSTRN#        IFEQ      0
650bAC     PSBCNT        ANDGT     0
650bAC                   add(h)    PSPCS         actqty
650bAC                   add(h)    PSCUBE        actcub
650bAC                   add(h)    PSSWGT        actwgt
650bAC                   ENDIF
650bAC                   ENDIF
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
720*Ac**
720*Ac**  When previous row and column match we need to back row counter down
720*Ac**  1 so it will add weight, pieces and cube to correct position.  More
720*Ac**  than one pallet can exist in a position with Drag Drop 2.
720*Ac**
720*Ac**                 if        prvrow=psrow
720*Ac**                           and prvcol=pscol
720*Ac**                 select
720*Ac**                 when      pscol=1
720*Ac**                 eval      c1=c1-1
720*Ac**                 if        c1<1
720*Ac**                 eval      c1=1
720*Ac**                 endif
720*Ac**                 when      pscol=2
720*Ac**                 eval      c2=c2-1
720*Ac**                 if        c2<1
720*Ac**                 eval      c2=1
720*Ac**                 endif
720*Ac**                 when      pscol=3
720*Ac**                 eval      c3=c3-1
720*Ac**                 if        c3<1
720*Ac**                 eval      c3=1
720*Ac**                 endif
720*Ac**                 endsl
720*Ac**                 endif
     C*
     C*  Store info. from first record into data structure DS1.
     C*  Next record into DS2.
     C*
     C                   SELECT
     C     C1            WHENLE    RECCOL
     C     PSCOL         ANDEQ     1
     C     C1            OCCUR     DS1
     C                   MOVE      DS0           DS1
HARfAC                   MOVE      DS0H          DS3
     C                   ADD       1             C1
720bDC**                 MOVE      *OFF          PRTFLG            1
720bMC                   MOVE      *ON           PRTFLG            1
     C*
     C     C2            WHENLE    RECCOL
     C     PSCOL         ANDEQ     2
     C     C2            OCCUR     DS2
     C                   MOVE      DS0           DS2
HARfAC                   MOVE      DS0H          DS4
     C                   ADD       1             C2
720 DC*                  EXSR      ZRDETL
720 DC*    CLIENT        IFEQ      BIRITE
720 DC*                  EXSR      ZRDTL2
720 DC*                  ENDIF
720 DC*    CLIENT        IFEQ      HARBOR
720 DC*                  EXSR      ZRDTL3
720 DC*                  ENDIF
     C                   MOVE      *ON           PRTFLG
     C*
720 AC     C3            WHENLE    RECCOL
720 AC     PSCOL         ANDEQ     3
720 AC     C3            OCCUR     DS5
720 AC                   MOVE      DS0           DS5
720 AC                   MOVE      DS0H          DS6
720 AC                   ADD       1             C3
720 AC                   EXSR      ZRDETL
720 AC     CLIENT        IFEQ      BIRITE
720 AC                   EXSR      ZRDTL2
720 AC                   ENDIF
720 AC     CLIENT        IFEQ      HARBOR
720 AC                   EXSR      ZRDTL3
720 AC                   ENDIF
720 AC                   MOVE      *ON           PRTFLG
     C                   ENDSL
     C*
     C                   ADD       1             COUNT
     C*
     C*
     C*  Accumulate totals
     C*                    ADD  1         CLS,1
     C*
     C*  Increment record counters
     C*
     C                   ADD       1             RECK(1)
     C*
     C*  Set off top-of-page indicators
650dAC     nxtrec        tag
     C*
     C                   MOVE      *OFF          *IN91
     C*----------------------------------------------------------------
     C*
     C* REPORT TOTALS
     C*
720bDC*R   C1            IFGT      RECCOL
720bDC*R   C2            ANDLE     RECCOL
720bDC*R   C1            ORGT      RECCOL
720bDC*R   C3            ANDLE     RECCOL
720bMCLR   PRTFLG        IFEQ      *ON
720eAc*    First off means no positions were printed on new line so
720eAc*    there is no reason to print blank line before totals
720eAcLR   first         ifeq      *off
     CLR                 EXSR      ZRDETL
720eAclr                 endif
720cAcLR                 exsr      zztotsum
BIRaACLR   CLIENT        IFEQ      BIRITE
BIRaACLR                 EXSR      ZRDTL2
BIRaACLR                 ENDIF
HARa CLR   CLIENT        IFEQ      HARBOR
HARa CLR                 EXSR      ZRDTL3
HARa CLR                 ENDIF
     CLR                 ENDIF
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
SBRaAC                             or client = SBertram
700cACLR                 eval      val39 = route
GFCaACLR                 write     head180                              90
650aACLR                 other
HARdACLR                 WRITE     HEAD1                                90
ICBaACLR                 endsl
DRY AC*
JORbACLR                 SELECT
JORbDC***                if        client = Dairyland
JORbMCLR                 when      client = Dairyland
DRY ACLR                 write     head2Dry                             90
GFCaACLR                 when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRaAC                             or client = SBertram
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
ADCbACLR                 when      client = andersondubose
ADCbACLR                 WRITE     HEAD2adc                             90
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
650cACLR                 select
GFCaACLR                 when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
ICBcAC                             or client = icb
SBRaAC                             or client = SBertram
GFCaACLR                 write     totweight8
GFCaMCLR                 write     totcol80                             90
ISYaACLR                 when      client = isupply or
GMMaAC                             client = menumaker
ISYaACLR                 WRITE     TOTCOLISY                            90
ADCbACLR                 when      client = andersondubose
ADCbACLR                 WRITE     TOTWGTADC
ADCbACLR                 WRITE     TOTCOL                               90
650cACLR                 other
650aACLR                 WRITE     TOTWEIGHT
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
SBRaAC                             or client = SBertram
700cACLR                 eval      val39 = route
GFCaACLR                 write     head180                              90
ICBaACLR                 other
HARdACLR                 WRITE     HEAD1                                90
650aACLR                 endsl
DRY AC*
JORaDC**                 if        client = Dairyland
JORbACLR                 SELECT
JORbMCLR                 when      client = Dairyland
DRY ACLR                 write     head2Dry                             90
GFCaACLR                 when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRaAC                             or client = SBertram
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
ADCbACLR                 when      client = andersondubose
ADCbACLR                 WRITE     HEAD2adc                             90
JORaACLR                 other
HARdACLR                 WRITE     HEAD2                                90
JORaACLR                 endsl
JORaDC**                 endif
DRY AC*
650aACLR                 XFOOT     WGT1          TOTWGT1
650aACLR                 XFOOT     WGT2          TOTWGT2
720 ACLR                 XFOOT     WGT3          TOTWGT3
650cACLR                 select
GFCaACLR                 when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRaAC                             or client = SBertram
GFCaACLR                 write     totweight8
GFCaACLR                 write     totcol80                             90
ISYaACLR                 when      client = isupply or
GMMaAC                             client = menumaker
ISYaACLR                 WRITE     TOTCOLISY                            90
ADCbACLR                 when      client = andersondubose
ADCbACLR                 WRITE     TOTWGTADC                            90
ADCbACLR                 WRITE     TOTCOL                               90
650cACLR                 other
650aACLR                 WRITE     TOTWEIGHT
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
DRY ACLR                 write     head2Dry                             90
GFCaACLR                 when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRaAC                             or client = SBertram
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
ADCbACLR                 when      client = andersondubose
ADCbACLR                 WRITE     HEAD2adc                             90
JORaACLR                 other
HARdACLR                 WRITE     HEAD2                                90
JORaACLR                 endsl
JORaDC**                 endif
DRY AC*
650aACLR                 XFOOT     WGT1          TOTWGT1
650aACLR                 XFOOT     WGT2          TOTWGT2
720 ACLR                 XFOOT     WGT3          TOTWGT3
650cACLR                 select
GFCaACLR                 when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRaAC                             or client = SBertram
GFCaACLR                 write     totweight8
GFCaACLR                 write     totcol80                             90
ISYaACLR                 when      client = isupply or
GMMaAC                             client = menumaker
ISYaACLR                 WRITE     TOTCOLISY                            90
ADCbACLR                 when      client = andersondubose
ADCbACLR                 write     totwgtadc
ADCbACLR                 WRITE     TOTCOL                               90
650cACLR                 other
650aACLR                 WRITE     TOTWEIGHT
HARdACLR                 WRITE     TOTCOL                               90
650cACLR                 endsl
HARdACLR                 ENDIF
ICBaACLR                 if        client = icb
ICBaACLR                 write     total2icb                            90
ICBaACLR                 else
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
ADCdAclr                 if        client = andersondubose
ADCdAClr                 EXSR      ZZRTNT
ADCdAclr                 endif
     CLR                 WRITE     FOOT1
ICBaAC****               endif
HKWbACLR                 endsl
ISYcACLR   skpPrt        tag
ADCcAclr                 write     head1
ADCcAclr                 write     head2adc
ADCcAclr                 write     Loadsheet
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C     *INZSR        BEGSR
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
     C                   Z-ADD     1             C1                3 0
     C                   Z-ADD     1             C2                3 0
720 AC                   Z-ADD     1             C3                3 0
     C                   Z-ADD     1             RECCOL            3 0
     C                   Z-ADD     24            RECPAG            3 0
HARA C                   Z-ADD     1             LINE              3 0
417AAC                   MOVE      *OFF          FOREVR            1
520bDC** SR   *LIKE         DEFINE    $WHSE         LSTWHS
520bDC** SR   *LIKE         DEFINE    $DEV          LSTDEV
520bDC** SR   *LIKE         DEFINE    $FORM         LSTFRM
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
417 ACSR   OPPLSQ        IFEQ      '2'
417 ACSR                 MOVE      '  Load'      SQTX1
417 ACSR                 MOVE      '  Load'      SQTX2
720 ACSR                 MOVE      '  Load'      SQTX3
720fACSR                 MOVE      '  Seq.'      SQTX11
720fACSR                 MOVE      '  Seq.'      SQTX21
720fACSR                 MOVE      '  Seq.'      SQTX31
417 ACSR                 ELSE
ISYaACSR                 if        client = isupply or
GMMaAC                             client = menumaker
ISYaACSR                 eval      SQTX1 = 'Unld  '
ISYaACSR                 eval      SQTX2 = 'Unld  '
720 ACSR                 eval      SQTX3 = 'Unld  '
ISYaACSR                 else
417 ACSR                 MOVE      '  Unld'      SQTX1
417 ACSR                 MOVE      '  Unld'      SQTX2
720 ACSR                 MOVE      '  Unld'      SQTX3
720fACSR                 MOVE      '  Seq.'      SQTX11
720fACSR                 MOVE      '  Seq.'      SQTX21
720fACSR                 MOVE      '  Seq.'      SQTX31
ISYaACSR                 endif
417 ACSR                 ENDIF
720fA *
ADCaAc                   if        client <> andersondubose
720fACSR                 MOVE      'Row/'        SQTX1
720fACSR                 MOVE      'Row/'        SQTX2
720fACSR                 MOVE      'Row/'        SQTX3
720fACSR                 MOVE      'Col/'        SQTX11
720fACSR                 MOVE      'Col/'        SQTX21
720fACSR                 MOVE      'Col/'        SQTX31
ADCaAc                   else
ADCaAC                   MOVE      *blanks       SQTX1
ADCaAC                   MOVE      *blanks       SQTX2
ADCaAC                   MOVE      *blanks       SQTX3
ADCaAC                   MOVE      *blanks       SQTX11
ADCaAC                   MOVE      *blanks       SQTX21
ADCaAC                   MOVE      *blanks       SQTX31
ADCaAc                   endif
720fACSR                 MOVE      'Pallt'       SQTX12
720fACSR                 MOVE      'Pallt'       SQTX22
720fACSR                 MOVE      'Pallt'       SQTX32
DRY AC*
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
520bDC*    $EP           IFEQ      ' '
520bDC*SR                 EXSR      OPNPRT
520bDC*                   ELSE
520bDC*SR                 EXSR      OPNPRX
520bDC*                   ENDIF
      /free
               ssccCnt = 1;
               dow ssccCnt < 10;
                  pal1(ssccCnt) = *zeros;
                  pal2(ssccCnt) = *zeros;
                  pal3(ssccCnt) = *zeros;
720gA             palcnt1(ssccCnt) = *zeros;
720gA             palcnt2(ssccCnt) = *zeros;
720gA             palcnt3(ssccCnt) = *zeros;
                  ssccCnt = ssccCnt + 1;
               enddo;
720dA          clear ssccAry;
720fA          clear palCAry;
      /end-free
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
720fA                 // leave once "O" type record read
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
720gA                    palcnt1(ssccCnt) = p_pspcs;
720fA
                      when pscol=2;
                         sscc2(ssccCnt) = %subst(%trim(pmval):
                                          %len(%trim(pmval))-4:5);
                         sscc2(ssccCnt) = ' ' + %trim(sscc2(ssccCnt)   ) + ' ';
720fA
720fA                    pal2(ssccCnt)  = p_pspal#;
720fA                    palc2(ssccCnt) = p_pscomp;
720gA                    palcnt2(ssccCnt) = p_pspcs;
720fA
                      when pscol=3;
                         sscc3(ssccCnt) = %subst(%trim(pmval):
                                          %len(%trim(pmval))-4:5);
                         sscc3(ssccCnt) = ' ' + %trim(sscc3(ssccCnt)   ) + ' ';
720fA
720fA                    pal3(ssccCnt)  = p_pspal#;
720fA                    palc3(ssccCnt) = p_pscomp;
720gA                    palcnt3(ssccCnt) = p_pspcs;
720fA
                   endsl;
                   ssccCnt = ssccCnt + 1;
                endif;

                read pltmisc;

             enddo;

      /end-free
720dAC                   ENDSR
415 AC*----------------------------------------------------------------
415 AC*
415 AC*  OPNPRT  Open printer file.
415 AC*
520bDC** SR   OPNPRT        BEGSR
415 AC*
415 AC*   Get device and form type for department.
415 AC*
520bDC** SR   PSWHSE        IFNE      LSTWHS
520bDC** SR                 CALL      'GETRPT'
520bDC** SR                 PARM      '*DEVFORM'    $CMD              8
520bDC** SR                 PARM      'PS311PR'     $LRPT            10
520bDC** SR                 PARM      PSWHSE        $PWHSE            3 0
520bDC** SR                 PARM      ' '           $STYP             1
520bDC** SR                 PARM      ' '           $WHDP             5
520bDC** SR                 PARM                    $DESC            50
520bDC** SR                 PARM                    $DEV             10
520bDC** SR                 PARM                    $FORM            10
520bDC** SR                 Z-ADD     PSWHSE        LSTWHS
520bDC** SR                 ENDIF
415 AC*
415 AC*   Open printer file for department.
415 AC*
520bDC** SR   OPENED        IFNE      *ON
520bDC** SR   $DEV          ORNE      LSTDEV
520bDC** SR   $FORM         ORNE      LSTFRM
415 AC*
415 AC*      If printer already open then close it.
415 AC*
520bDC** SR   OPENED        IFEQ      *ON
520bDC** SR                 CLOSE     PS311PR
520bDC** SR                 ENDIF
415 AC*
415 AC*      Override printer file.
415 AC*
415 AC*          OVRPRTF FILE(PS311PR) OUTQ(*DEV) DEV($dev)
415 AC*                  FORMTYPE($form)
415 AC*
520bDC**                 SELECT
520bDC**   CLIENT        WHENEQ    BIRITE
520bDC**   CLIENT        OREQ      LEDYRD
BIR AC*      Include copies(2) with ovrprtf.
520bDC**                 MOVEA     OVRPRT(2)     A80
BIR AC*
520bDC**                 OTHER
520bDC** SR                 MOVEA     OVRPRT(1)     A80
520bDC**                 ENDSL
520bDC** SR                 MOVEA     $DEV          A80(38)
520bDC** SR                 MOVEA     $FORM         A80(59)
520bDC** SR                 MOVEA     A80           QCMD
415 AC*
520bDC** SR                 CALL      'QCMDEXC'
520bDC** SR                 PARM                    QCMD             80
520bDC** SR                 PARM      80            QLEN             15 5
415 AC*
415 AC*      Open printer file.
415 AC*
520bDC** SR                 OPEN      PS311PR
520bDC** SR                 MOVE      *ON           OPENED            1
520bDC** SR                 MOVE      $DEV          LSTDEV
520bDC** SR                 MOVE      $FORM         LSTFRM
415 AC*
520bDC** SR                 ENDIF
415 AC*
520 DC** SR                 ENDSR
HARgAC*----------------------------------------------------------------
HARgAC*
HARgAC*  OPNPRX  Open printer file extra copies
HARgAC*
520bDC** SR   OPNPRX        BEGSR
HARgAC*
HARgAC*   Get device and form type for department.
HARgAC*
520bDC** SR   PSWHSE        IFNE      LSTWHS
520bDC** SR                 CALL      'GETRPT'
520bDC** SR                 PARM      '*DEVFORM'    $CMD              8
520bDC** SR                 PARM      'PS311PX '    $LRPT            10
520bDC** SR                 PARM      PSWHSE        $PWHSE            3 0
520bDC** SR                 PARM      ' '           $STYP             1
520bDC** SR                 PARM      ' '           $WHDP             5
520bDC** SR                 PARM                    $DESC            50
520bDC** SR                 PARM                    $DEV             10
520bDC** SR                 PARM                    $FORM            10
520bDC** SR                 Z-ADD     PSWHSE        LSTWHS
520bDC** SR                 ENDIF
HARgAC*
HARgAC*   Open printer file for department.
HARgAC*
520bDC** SR   OPENED        IFNE      *ON
520bDC** SR   $DEV          ORNE      LSTDEV
520bDC** SR   $FORM         ORNE      LSTFRM
HARgAC*
HARgAC*      If printer already open then close it.
HARgAC*
520bDC** SR   OPENED        IFEQ      *ON
520bDC** SR                 CLOSE     PS311PR
520bDC** SR                 ENDIF
HARgAC*
HARgAC*      Override printer file.
HARgAC*
HARgAC*          OVRPRTF FILE(PS311PR) OUTQ(*DEV) DEV($dev)
HARgAC*                  FORMTYPE($form)
HARgAC*
520bDC**                 SELECT
520bDC**   CLIENT        WHENEQ    BIRITE
520bDC**   CLIENT        OREQ      LEDYRD
HARgAC*      Include copies(2) with ovrprtf.
520bDC**                 MOVEA     OVRPRT(2)     A80
520bDC**   CLIENT        WHENEQ    HARBOR
520bDC**                 MOVEA     OVRPRT(3)     A80
520bDC*
520bDC**                 OTHER
520bDC** SR                 MOVEA     OVRPRT(1)     A80
520bDC**                 ENDSL
520bDC** SR                 MOVEA     $DEV          A80(38)
520bDC** SR                 MOVEA     $FORM         A80(59)
520bDC** SR                 MOVEA     A80           QCMD
HARgAC*
520bDC** SR                 CALL      'QCMDEXC'
520bDC** SR                 PARM                    QCMD             80
520bDC** SR                 PARM      80            QLEN             15 5
520bDC*
HARgAC*      Open printer file.
HARgAC*
520bDC** SR                 OPEN      PS311PR
520bDC** SR                 MOVE      *ON           OPENED            1
520bDC** SR                 MOVE      $DEV          LSTDEV
520bDC** SR                 MOVE      $FORM         LSTFRM
HARgAC*
520bDC** SR                 ENDIF
520bDC*
520bDC** SR                 ENDSR
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
HARADC**                   MOVE RHTRUK    TRUCK
CSPdD **                 MOVE      RHTRUK        TRUCK
     C                   ENDIF
     C                   ENDSR
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
SBRaAC                             or client = SBertram
700cAC                   eval      val39 = route
GFCaAC                   write     head180
650aMC                   other
     C                   WRITE     HEAD1
650aMC                   endsl
DRY AC*
JORaDC*                  if        client = Dairyland
JORbAC                   SELECT
JORbMC                   when      client = Dairyland
DRY AC                   write     head2Dry
GFCaAC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRaAC                             or client = SBertram
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
ADCbAC                   when      client = andersondubose
ADCbAC                   WRITE     HEAD2adc                             90
JORaAC                   other
     C                   WRITE     HEAD2
JORaAC                   endsl
JORaDC**                 endif
DRY AC*
ADCdAc                   if        client <> andersondubose
510bAC                   EXSR      ZZRTNT
ADCdAc                   endif
DRY AC*
650aAC                   select
DRY AC                   when      client = Dairyland
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
SBRaAC                             or client = SBertram
GFCaAC                   write     columns80
ICBaAC                   when      client = icb
ICBaAC                   write     columnsicb
ADCbAC                   when      client = andersondubose
ADCbAC                   write     columnsadc
650aAC                   other
     C                   WRITE     COLUMNS
650aaC                   endsl
DRY AC*                  endif
     C*
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
HARfAC                   MOVE      DS0H          DS3
     C     X             OCCUR     DS2
     C                   MOVE      DS0           DS2
HARfAC                   MOVE      DS0H          DS4
720 AC     X             OCCUR     DS5
720 AC                   MOVE      DS0           DS5
720 AC                   MOVE      DS0H          DS6
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
700eAC                   if        client=saval
700eAC                             or client = yhata
700eAC                             or client = royal
700eAC                             or client = andrews
700eAC                             or client = cityline
SVLaAC                   CLEAR                   C0RTPA
HARfAC                   CLEAR                   C0LDSD
720 DC*                  CLEAR                   C0WGT
700eAC                   endif
     C     1             DO        RECCOL        X
     C     X             OCCUR     DS1
     C     X             OCCUR     DS2
720 AC     X             OCCUR     DS5
520 AC*
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
520 AC*
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
720 AC*
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
520 AC*
ICBaAC                   eval      chkcube = c1spcs + c2spcs + c3spcs
650aAC                   select
ADCbAC                   when      client = andersondubose
ADCbAc                   write     detail1adc
ICBaAC                   when      client = icb and
ICBaAC                             chkcube <> 0
720fAD*                  write     detail1icb
ISYaAC                   when      client=isupply or
GMMaAC                             client = menumaker
720fAD*                  WRITE     DETAIL1ISY
GFCaAC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRaAC                             or client = SBertram
720fAC*                  write     detail180
ICBaAC*                  endif
650aMC                   other
     C                   WRITE     DETAIL1
650aMC                   endsl
SVLaAC                   if        client=saval
YHA AC                             or client = yhata
RYLaAC                             or client = royal
AFSbAC                             or client = andrews
CLDbAC                             or client = cityline
SVLaAC**520cD            WRITE     DETAIL2
520cMC                   WRITE     DETAIL4
SVLaAC                   endif
510aAC                   ADD       1             LINE
510aAC                   EXSR      ZRSPCL
650bDC***      Moved below DASH1 so that it keeps the weight value
650bDC***                MOVE      DS0           DS1
650bDC***                MOVE      DS0           DS2
     C                   ENDDO
     C*
HARfAC     CLIENT        IFEQ      HARBOR
HARfAC     DS3           ANDNE     ' '
HARfAC     CLIENT        OREQ      HARBOR
HARfAC     DS4           ANDNE     ' '
HARfAC                   WRITE     LDSD
HARfAC                   MOVE      DS0H          DS3
HARfAC                   MOVE      DS0H          DS4
HARfAC                   MOVE      DS0H          DS6
HARfAC                   ELSE
650aAC                   select
ICBaAC                   when      client = icb  and
ICBaAC                             chkcube <> 0
ICBaAC                   write     dash1icb
GFCaAC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRaAC                             or client = SBertram
GFCaAC                   write     dash180
650aDC*                  endif
ISYaAC                   when      client = isupply or
GMMaAC                             client = menumaker
ISYaAC                   WRITE     DASH1isy
ADCbAC                   when      client = andersondubose
720dA *
720dA *    loop and print any lines of Pallet Id's that exist
720dA *
720dA /free
720dA         ssccCnt = 1;
720dA          dow ssccCnt < 10;
720dA             if sscc1(ssccCnt) <> *blanks or
720dA                sscc2(ssccCnt) <> *blanks or
720dA                sscc3(ssccCnt) <> *blanks;
720dA                c1plid = sscc1(ssccCnt);
720dA                c2plid = sscc2(ssccCnt);
720dA                c3plid = sscc3(ssccCnt);
720fA                c1pal# = pal1(ssccCnt);
720fA                c2pal# = pal2(ssccCnt);
720fA                c3pal# = pal3(ssccCnt);
720fA                c1spcs = palcnt1(ssccCnt);
720fA                c2spcs = palcnt2(ssccCnt);
720fA                c3spcs = palcnt3(ssccCnt);
720fA                c1pcmp = '   ' + palc1(ssccCnt);
720fA                c2pcmp = '   ' + palc2(ssccCnt);
720fA                c3pcmp = '   ' + palc3(ssccCnt);
720dA                if ssccCnt = 2;
720dA                   c1wgt = *zeros;
720dA                   c2wgt = *zeros;
720dA                   c3wgt = *zeros;
720dA                endif;
ADCbM                WRITE DASH1ADC;
720dA             endif;
720dA             ssccCnt = ssccCnt + 1;
720dA          enddo;
720dA          clear ssccAry;
720fA          clear palCAry;
720fA          ssccCnt = 1;
720fA          dow ssccCnt < 10;
720fA             pal1(ssccCnt) = *zeros;
720fA             pal2(ssccCnt) = *zeros;
720fA             pal3(ssccCnt) = *zeros;
720gA             palcnt1(ssccCnt) = *zeros;
720gA             palcnt2(ssccCnt) = *zeros;
720gA             palcnt3(ssccCnt) = *zeros;
720fA             ssccCnt = ssccCnt + 1;
720fA          enddo;
720fA                    other;
720fA                    write DASH1;
720dA /end-free
650aMC                   endsl
HARfAC                   ENDIF
650bMC                   MOVE      DS0           DS1
650bMC                   MOVE      DS0           DS2
720 AC                   MOVE      DS0           DS5
510aAC                   ADD       1             LINE
510aAC                   EXSR      ZRSPCL
BIRaAC     CLIENT        IFEQ      BIRITE
BIRaAC                   ELSE
650aAC                   select
ICBaAC                   when      client = icb  and
ICBaAC                             chkcube <> 0
ICBaMC                   write     dash2icb
GFCaAC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRaAC                             or client = SBertram
GFCaMC                   write     dash280
ICBaAC*                  Endif
ISYaAC                   when      client = isupply or
GMMaAC                             client = menumaker
ISYaAC                   WRITE     DASH2isy
ADCbAC                   when      client = andersondubose
ADCbAC                   write     dash2adc
650aAC                   other
BIRaMC                   WRITE     DASH2
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
BIRaAC                   WRITE     DETAIL2
BIRaAC                   ELSE
BIRaAC* Column 2
BIRaAC     SPID(Z2)      IFEQ      SVPID2
BIRaAC*                    MOVELSCMP,Z2   S2COMP
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
BIRaAC                   WRITE     DETAIL2
BIRaAC                   ADD       1             Z2
BIRaAC                   ELSE
BIRaAC* Column 1 if nothing in column 2
BIRaAC                   CLEAR                   S2CUBE
BIRaAC                   CLEAR                   S2STP1
520 AC                   CLEAR                   S2STPA
BIRaAC                   CLEAR                   S2SPCS
BIRaAC                   WRITE     DETAIL2
BIRaAC                   ENDIF
BIRaAC                   ENDIF
BIRaAC                   ELSE
BIRaAC* Column 2 if nothing in column 1
BIRaAC     SPID(Z2)      IFEQ      SVPID2
BIRaAC     SVPID1        ANDEQ     0
BIRaAC*                    MOVELSCMP,Z2   S2COMP
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
BIRaAC                   WRITE     DETAIL2
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
ICBaMC                   write     dash2icb
GFCaMC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRaAC                             or client = SBertram
BIRaAC*
GFCaMC                   write     dash280
ISYaAC                   when      client = isupply or
GMMaAC                             client = menumaker
ISYaAC                   WRITE     DASH2isy
650aMC                   other
BIRaMC                   WRITE     DASH2
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
     C                   WRITE     DETAIL3
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
     C*                    MOVELSCMP,Z2   S2COMP
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
     C                   WRITE     DETAIL3
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
     C                   WRITE     DETAIL3
     C                   ADD       1             LINE
     C                   EXSR      ZRSPCL
     C                   ENDIF
     C                   ENDIF
     C                   ELSE
     C* Column 2 if nothing in column 1
     C     SPID(Z2)      IFEQ      SVPID2
HARc C*          SVPID1    ANDEQ0
     C*                    MOVELSCMP,Z2   S2COMP
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
     C                   WRITE     DETAIL3
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
ICBaAC                   write     dash2ICB
GFCaAC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRaAC                             or client = SBertram
GFCaAC                   write     dash280
ISYaAC                   when      client = isupply or
GMMaAC                             client = menumaker
ISYaAC                   WRITE     DASH2isy
650aAC                   other
     C                   WRITE     DASH2
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
BIRaAC                   WRITE     STPCOL
BIRaAC                   WRITE     SKIP1
BIRaAC                   ENDIF
BIRaAC*
BIRaAC                   Z-ADD     1             Z
BIRaAC                   DO        9999          Z
BIRaAC*
BIRaAC     *IN90         IFEQ      *ON
650aAC                   select
ICBaAC                   when      client = icb
ICBaAC                   write     head1icb
GFCaAC                   when      client = glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
ISYbAC                             or client = isupply
SBRaAC                             or client = SBertram
700cAC                   eval      val39 = route
GFCaAC                   write     head180
650aAC                   other
BIRaAC                   WRITE     HEAD1
650aAC                   endsl
DRY AC*
JORaDC*                  if        client = Dairyland
JORbAC                   SELECT
JORbMC                   when      client = Dairyland
DRY AC                   write     head2Dry
GFCaAC                   when      client = Glazier
HKWaAC                             or client = hkw
EFCaAC                             or client = eastland
PFCaAC                             or client = presto
JSLaAC                             or client = JSilvert
SBRaAC                             or client = SBertram
700cAC                   eval      val39 = route
GFCaAC                   write     head280
JORaDC*                  else
JORaAC                   when      client = Jordanos
JORaAC                   write     head2Jor                             90
ASC AC                   when      client = agar
ASC AC**                 write     head2asc                             90
RFS AC                   when      client = rfs
RFS AC                   write     head2rfs                             90
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
ISYaAC                   when      client = isupply or
GMMaAC                             client = menumaker
ISYaAC                   write     head2isy
ADCbAC                   when      client = andersondubose
ADCbAC                   WRITE     HEAD2adc                             90
JORaAC                   other
BIRaAC                   WRITE     HEAD2
JORaAC                   endsl
JORaDC*                  endif
DRY AC*
BIRaAC                   WRITE     SKIP1
BIRaAC                   WRITE     STPCOL
BIRaAC                   WRITE     SKIP1
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
BIRaAC                   WRITE     STPDTL
BIRaAC                   Z-ADD     SPID(Z)       SAVPID
BIRaAC                   ELSE
BIRaAC                   LEAVE
BIRaAC                   ENDIF
BIRaAC*
BIRaAC                   ENDDO
BIRaAC                   WRITE     SKIP1
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
730 AC                   if        ntcnt=0
730 AC                   WRITE     RTNOTHED
730 Ac                   endif
510bAC                   MOVEL     RNNOTE        PRTNT
510bAC                   Z-ADD     1             NTCNT
510bAC                   WRITE     RTNOTES
510bAC                   ENDDO
510bAC     NTCNT         IFEQ      1
730 AC     NTCNT         OREQ      0
510bAC                   WRITE     SKIP1
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
720cA              if pstype = 'B' or pstype = 'P';
720cA /end-free
720cA*
720cA*   Adjust columns 4 - 9 to 1 - 3.
720cA*   Overflow 'O' records use columns 1 - 9.
720cA*
720cAc                   select
720cAc                   when      pscol > 6
720cAc                   eval      pscol = pscol - 6
720cAc                   when      pscol > 3
720cAc                   eval      pscol = pscol - 3
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
720cDc*    PSTRN#        IFNE      0
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
720cAC                   ENDIF
720cAC                   ENDIF
720cA /free
720cA              endif;
720cA              reade ($whse:$prtid) pltsum2;
720cA           enddo;
720cA /end-free
720cA
720cAC                   ENDSR
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
