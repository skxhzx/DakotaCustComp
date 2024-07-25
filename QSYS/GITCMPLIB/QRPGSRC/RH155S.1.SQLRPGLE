640aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RH155S    FTP Export closed customer orders - Post
     *  27 February 2011
     *  Dave Sommerville
     *
     *  This program was based on RH155. All RH155 revision comments
     *  were kept in this program. See 640 notes.
     *
     *----------------------------------------------------------------
     *  Revisions
     *  Notes
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
520aA*    01/27/09  DAS  5.20a
     *      - Revised to get worklbl rec for ORDP processing.
     *
640aA*    02/09/11  DAS  6.40a
     *      - RH155S created.
     *      - Revised to used staging files.
     *      - Removed all Packers custom changes.
     *      - Made writing EXPSORDL records standard.
     *      - Made writing EXPSORDP records standard.
     *
640bA*    03/02/11  DAS  6.40b
     *      - Added commands 'TALL' and 'THDRDTL'. These are test
     *        commands that will prevent the marking of the route
     *        and order header records as exported.
     *
640cA*    03/09/11  DAS  6.40c
     *      - Added added OEHTRLR to EXPSODH.
     *      - Added call to GETTRLR in filoeh routine.
640dA*    09/18/12  MLB  6.40d
     *      - Added added OEDMS1 thru OEDMS5 fields to EXPSORDD.
     *      - Fields were added for Kelly Foods. Client needed data
     *        sent in one of the Misc. fields sent back to the Host.
     *      - Added file, ORDDM to pgm.
     *
650 A*    03/14/14  MLB  6.50
     *      - Enh: Added retrieval of ORDHM file as standard change.
     *        Needed for DRYa mod.
     *
700a *    08/13/15  RTR  7.00a
     *      - Fix: Check route status and set to exported first thing.
     *        This is needed because now GUI submits to batch, so is
     *        possible to have multiple jobs submitted before first
     *        run finishes.
700b *    09/15/15  RTR  7.00b
     *      - Fix: Added will call status 4 to status check. Will calls
     *        will be at status 4 when this is called.
700c *    04/11/16  RTR  7.00c
     *      - Fix: Added fields OEHMS1-5 to mod 650.
700d *    09/26/16  RTR  7.00d
     *      - Enh: Added base logic for EXPSORDU.
700e *    09/26/16  RTR  7.00e
     *      - Enh: Reserved for NECS license changes.
     *
720 A*    02/14/18  MLB  7.20   Originally 6.40d at KFS
     *      - Fix: Revised routine, FILOEH to load header misc fields
     *        with ORDHM misc1-5 fields.
     *
720aA*    08/03/18  RBD  7.20a
     *      - Added *SYSTEM options.
     *      - Added creation of Trax xml which used to run in RH150A
     *        but was moved in here to ensure route status has been
     *        updated to exported status.
     *
730aA*    03/06/19  MR  7.30a
     *      - Added GETSTOP routine to populate extended stop in
     *        EXPSORDH.
     *
730bA*    03/18/19  LMC  7.30b
     *      - Added EXPSORDLT.
     *
730c *    10/23/19  RTR  7.30c
     *      - Set picked qty = order qty for non-stock items.
     *        Controlled by OPTIONINT setting, defaults to flag/print.
     *
740 A*    07/08/20  MLB  7.40
     *      - Enh - Added Additional parms to cvtbar.
740a *    04/20/20  RTR  7.40a
     *      - Enh: Added EXPTRIG for staging export for NetSuite.
     *        Controlled by softcode set in OPTIONS, OPTIONINT,
     *        or PIRCLIENT4.
740b *    06/05/20  RTR  7.40b
     *      - Enh: Added direct API call for NetSuite.
740cA*    11/06/20  RBD  7.40c
     *      - Added *TRAX options. Only create Trax xml at this time
     *        if Trax user AND they do not print Trax invoices.
750aA*    06/03/21  KDE  7.50a
     *      - Enh - Support for Super Routes
760aA*    06/07/22  LMC  7.60a
     *      - Clients using host software FRESHBYTE need to have the  ted
     *        lot number send in the host lot code field OELTHSTLOT
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
CBIcA*    01/07/09  DAS  CBIc
     *      - Revised to send the special pallet id that is barcoded
     *        on the BIGPALCB label in the OEPDSP field in the
     *        expfordp file.
     *
CBIdA*    03/11/11  DAS  CBId
     *      - Revised to set OELBOX to 1 if that ord/seq/item is not
     *        on any open (1,2,3,8) transactions.
     *
CBIeA*    03/24/11  DAS  CBIe
     *      - Revised to only send 'O' and 'B' records in EXPSORDL.
     *
CBIfA*    10/22/11  DAS  CBIf
     *      - When command is *HDRDTL or THDRDTL, call RH155ST with
     *        each transaction number and command *GEN2CW.
     *        Re: Because Cheney captures catchweights on 'M' records
     *        and because 'M' records are not exported, we delay sending
     *        Gen 2 transactions that have catchweights until the whole
     *        route is closed and this program is called with *HDRDTL.
     *        RH155ST has the logic to ignore all other transactions.
     *
CBI1A*    04/26/12  CBI1-JGD  (This change applies RIV only)
     *      - Added logic to process "BRAKERS" routes which is
     *        created differently than the rest of the Truck
     *        Builder routes. "BREAKERS" route processing is
     *        conformed of several routes with the same route
     *        number, but different route ids. Unlike the rest
     *        of the routes that are one route number and one
     *        route id only. Without this change SAP would'nt
     *        be able to process "BREAKERS" routes, now these
     *        routes are all grouped into a single batch id
     *        like the rest of the routes. Before, each of the
     *        "BREAKERS" routes had its own unique batch id.
     *        making it a non SAP proccessable.
      *
CBI2A *    11/05/12  CBI2-JGD  (This change applies to BREAKERS only)
      *      - Added logic to redesign "BREAKERS" route
      *        processing defined in CBI1 mod above.
      *        Each BREAKERS route represents a stop carrying
      *        same ROUTE# and same BATCH ID as the previous stop,
      *        so the route# and route id being passed will be
      *        written into file "Stgbatch" as regular "EXPSLTRN"
      *        or "EXPCLSTRN", the decision as to which to write
      *        is based on the batch found on the next record read
      *        from "Impsordh3" file, if it is the same batch id
      *        as the previous record then the record to write is
      *        a "EXPSELTRAN", if the batch id is different then
      *        write a "EXPCLSRTE" record to close all that Route#/
      *        BREAKERS processes.
      *
CBI3A *    08/15/13  CBI3-JGD
      *      - Modify the logic that builds up the pallet # into
      *        file Expsordp/oepdsp field.
     *
CBIgA*    08/23/13  DAS  CBIg
     *      - Revised zzCBIGEN2 to skip duplicate transaction numbers.
     *
CBIhA*    12/12/14  DAS  CBIh
     *      - Reversed CBIe change, now writing 'M' recs to EXPSORDL.
      *
CBI4A *    11/25/15  CBI4-JGD
      *      - Added client custom code around BREAKERS logic.
      *        Note: BREAKERS is a Cheney/Riviera customer only).
CBI5A*    01/12/16  MLB  CBI5
     *      - Revised pgm to send route id + pallet id in OEPDSP fld.
     *        Needed for Punta Gorda, Ocala, Riviera
      *
CBI6A *    02/10/16  CBI6-JGD
      *      - Modify "BREAKERS" identification logic to look for
      *        "ohtruck = BREAKERS" only and delete the verification
      *        of the last three digits of the route #. Reason: The
      *        route last three digits = 075 was assigned exclusively
      *        to BREAKERS route, this is not longer true since SAP
      *        implementation, so the only BREAKERS route identifier
      *        is "ohtruck = BREAKERS"
     *
CBIi *    09/26/16  RTR  CBIi
     *      - Added EXPSORDU/EXPCBIUCI for Cheney Subway UCI export.
CBIj *    09/26/16  RTR  CBIj
     *      - Fix for CBIi, change to set UCI status to Q and leave
     *        batch ID blank. Needed because SAP can't handle large
     *        numbers of batches and SAP is retrieving once a day.
     *        DKTIMPORT will call other program to assign batch ID
     *        and change status to all status Q records when the
     *        DKTIMPORT program is called, making one big batch.
     *
CBIl *    03/15/17  RTR  CBIl
     *      - Enh: If ITDESG = 'NOALC', do not export item. Per Dave
     *        email 3/13/17.
     *
CBI7A*    10/31/17  MLB  CBI7
     *      - Revised pgm to send route id + pallet id in OEPDSP fld.
     *        Needed for NC & MLK.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Ellenbee-Leggett.
     *
ELL A*    05/25/07  MLB  ELL
     *      - Added ELL to CBI mod.
     *      - Revised program to write export label data to file
     *        EXPFORDL.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland Foods
     *
EFC A*    12/05/13  MLB  EFC
     *      - Fix: Revised pgm to not populate file, EXPSORDT. Bug
     *        in Java code is causing export process to fail and not
     *        update STGBATCH status.
     *      - java.lang.ArrayIndexOutOfBoundsException:
     *        Array index out of range: 1.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly Foods
     *
KFS A*    09/19/12  MLB  KFS
     *      - Revised program to initialize positions 1-16 of OMMSC4
     *        if a ORDDM record isn't found.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    12/20/13  RTR  DRY
     *      - Revised pgm to call Host export program, BFCECS01C to send
     *        exported orders to Host JDEdwards system.
     *      - Added /copy mbr, C#FILE1DS to retrieve files library to
     *        pass to Host pgm, along with whse number.
DRYaA*    03/14/14  MLB  DRYa
     *      - Revised pgm to retrieve Host Truck Number from order header
     *        misc. Host Truck Number will be sent to JDE in OEHTRK.
     *      - Added file ORDHM to program as 6.50 mod.
DRYcA*    02/06/15  MLB  DRYc
     *      - Revised pgm to clear Route Inuse flag upon successful
     *        export of route. RH150A, RH250A and RH240 included in
     *        this mod.
DRYdA*    09/11/18  MLB  DRYd
     *      - Fix: Revised DRYc mod to add missing $iuJobuser parm on
     *        call to CHKIUSE2.
DRYeA*    05/15/19  MLB  DRYe
     *      - Revised pgm to retrieve Truck Pallet number for Gen 2
     *        pallets and load into OEPPAL.
     *        Added call to pgm, GETTPL2.
     *        Note: This mod could also be used to send the Truck Pallet
     *              ID for the Gen 2 pallets, if needed.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Indianhead Foods
     *
IFDa *    03/02/17  RTR  IFDa
     *      - Added call to NetSuite export at end of processing.
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
     Fordh3     uf   e           k disk
650 AFordhm     if   e           k disk
     Fordd      if   e           k disk
640dAForddm     if   e           k disk
     Fordc      if   e           k disk
417aMFordt      uf   e           k disk
640aDF*rdp1     if   e           k disk    usropn
640aMFordp1     if   e           k disk
500 AFordbox    if   e           k disk
500 AFordexpdte if   e           k disk
417aAFpirtran   if   e           k disk
     Frtehed    uf   e           k disk
417bAFLabel90   if   e           k disk
     F                                     rename(lbrec:lbrec9)
510fMFlabel93   if   e           k disk
510fMF                                     rename(lbrec:lbrec93)
640aDF**                                   usropn
CBIaAFpltsum4   if   e           k disk    usropn
CBIfAFpltsum12  if   e           k disk    usropn
CBIfAF                                     rename(psrec:psrec12)
640aDF*xpfordh  o  a e           k disk
640aDF*xpfordd  o  a e           k disk
640aDF*xpfordc  o  a e           k disk
640aDF*xpfordt  o  a e           k disk
640aDF*xpfordb  o  a e           k disk
640adF*xpforde  o  a e           k disk
640aDF*xpfordl  o  a e           k disk
640aDF*xpfordp  o  a e           k disk    usropn
CBI1DF*expsordh  o  a e           k disk
CBI1MFexpsordh  uf a e           k disk
DRY AF                                     infds(file1ds)
640aAFexpsordd  o  a e           k disk
640aAFexpsordc  o  a e           k disk
640aAFexpsordt  o  a e           k disk
640aAFexpsordb  o  a e           k disk
640aAFexpsorde  o  a e           k disk
640aAFexpsordl  o  a e           k disk
640aAFexpsordp  o  a e           k disk
700dAFexpsordu  o  a e           k disk    usropn
730bAFexpsordlt o  a e           k disk
730bAFitemmsc   if   e           k disk
730bAfliclog6   if   e           k disk
730bAflicinfo   if   e           k disk
CBI1MFimpsordh  if   e           k disk
CBI1AF                                     rename(oihrec:oihrec2)
CBI1MFimpsordh3 uf   e           k disk
CBI1AF*rteidfil  if a e           k disk
     Foptions   if   e           k disk
CBIlAFpiritem   if   e           k disk
640aDF*orklbl   if   e           k disk    usropn
640aMFworklbl   if   e           k disk
720aAFttrte     if   e           k disk
720aAFpiruser   if   e           k disk
750aAfsrord1    if   e           k disk
     *----------------------------------------------------------------
     *  Customer id
     *
PAK A /COPY QCOPYSRC,ID#packers
CBI A /COPY QCOPYSRC,ID#cheney
CBIcA /COPY QCOPYSRC,ID#cheneyo
CBIcA /COPY QCOPYSRC,ID#cheneyr
CBI5A /COPY QCOPYSRC,ID#cheneyp
ELL A /COPY QCOPYSRC,ID#ellenbe
EFC A /COPY QCOPYSRC,ID#eastlan
KFS A /COPY QCOPYSRC,ID#kfs
DRY A /COPY QCOPYSRC,ID#dairyla
IFDaA /copy qcopysrc,id#ifd
     *----------------------------------------------------------------
     *  Working variables
     *
640aAD batId           s             11
CBIiAD batIdcbi        s             11
CBIiAD cntOrduRecs     s              9  0
CBI1AD batchid         s             11
CBIdAD count           s              9  0
     D error           s              1
640aAD forever         s               n
640aAD haveBatId       s               n
740aAd hostopts        s             20a
740aAd hostoptint      s             20a
DRY Ad hrtn            s              8
DRYcAD $icmd           s              8
DRYcAD $ipgm           s             10
DRYcAD $iuser          s             10
DRYcAD $isessid        s             40
DRYcAD $irtn           s              8
DRYcAD $iutext10       s             10
DRYcAD $iutext30       s             30
DRYcAD $iucmd          s              8
DRYcAD $iupgm          s             20
DRYcAD $iuUser         s             10
DRYcAD $iuSessId       s             40
DRYcAD $iuJobName      s             10
DRYcAD $iuJobNbr       s              6
DRYdAD $iuJobUser      s             10
DRYcAD $iuStamp        s             26
CBI1AD lastrte         s              1
CBIgAD lastpstrn#      s                   like(pstrn#)
640aAD onlyHdrDtl      s               n
700dAD OptUseOrdu      s              1a
640aAD rtnCode         s             10
640aAD rtnMessage      s            200
CBI2AD savbatchid      s             11
CBI2AD savrtid         s              5
CBI2AD sltrn           s              1
640aAD stamp           s               z
640aAD stampUC         s               z
510bAD standa          s              1
CBIcAD temp2a          s              2
CBI3AD temp4a          s              4
CBIcAD temp7a          s              7
     D today           s              8  0
CBI1AD totalrtes       s              5  0
640aAD zeroUploadDate  s              8s 0
720aAD sysWhse         s              3s 0 inz(0)
     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
740aAd NetSuite        c                   const('NETSUITE')
760a D freshbyte       c                   const('FRESHBYTE')
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

IFDaA*----------------------------------------------------------------
IFDaA* Prototype for NetSuite Export
IFDaAd NetSuiteExport  pr                  extpgm('RH155NS')
IFDaA * Input
IFDaAd   nsWhsea                      3    const
IFDaAd   nsBatId                     11    const
740bA*----------------------------------------------------------------
740bA* Prototype for NetSuite API Call
740bA /copy qcopysrc,p.intapins

510b *
510b * Data structure
510b *
720aA*----------------------------------------------------------------
720aA*  Prototypes
     *----------------------------------------------------------------

720aAD tr810           pr                  extpgm('TR810')
720aA * Input
720aAD   tr8Whse                      3  0 const
720aAD   tr8Rtid                      5    const
720aAD   tr8Emp                       5    const
720aA * Output
720aAD   tr8FileSnd                  30    const
720aAD   tr8Rtn                       8    const
720aAD   tr8Erm                      60    const

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

650 A*----------------------------------------------------------------
650 A*  File info data structures
650  *----------------------------------------------------------------
650 A
650 A /COPY qcopysrc,c#file1ds
DRYaA /COPY qcopysrc,ordhm1_dry
DRYcA /COPY qcopysrc,c#pgminfds
650 A
     *----------------------------------------------------------------
720aA*  *SYSTEM  -  System options.
720aA*----------------------------------------------------------------
720aA*
720aA* Fields
720aA*
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
740cA*  *TRAX  -  TRAX options
740cA*----------------------------------------------------------------
740cA*
740cA* Fields
740cA*
740cA*    OPTHST  -  Days to keep TRAX export data (1-999)
740cA*    OPTSLI  -  Save log info
740cA*    OPTCWR  -  Catch weight required
740cA*    OPTOFT  -  Order number field type
740cA*    OPTDFT  -  Driver field type
740cA*    OPTRFT  -  Route field type
740cA*    OPTCAP  -  Capitalize input
740cA*    OPTDBL  -  Double click delivery
740cA*    OPTEKD  -  Entry key delivery
740cA*    OPTDAR  -  Delivery after return
740cA*    OPTIDB  -  Include item data base
740cA*    OPTBDA  -  Breakdowns allowed
740cA*    OPTGBD  -  Generic breakdown allowed
740cA*    OPTRTQ  -  Pre-trip questions
740cA*    OPTOTQ  -  Post-trip questions
740cA*    OPTCCE  -  Credit card enabled
740cA*    OPTSIG  -  Signature enabled
740cA*    OPTPIV  -  Print invoice
740cA*    OPTSDA  -  Send data after stop
740cA*    OPTWSP  -  Ws port
740cA*    OPTWSI  -  Ws IP
740cA*    OPTSVD  -  Save days
740cA*    OPTERT  -  Environment run time
740cA*    OPTEDV  -  Environment device
740cA*    OPTEOS  -  Environment OS
740cA*    OPTESW  -  Environment screen width
740cA*    OPTESH  -  Environment screen height
740cA*    OPTARE  -  Add return enabled
740cA*    OPTIDL  -  Icon delivery
740cA*    OPTDCI  -  Double click icons
740cA*    OPTPAL  -  Pallets enabled
740cA*    OPTCRA  -  Cradle upload enabled
740cA*    OPTDRV  -  Driver assigned before download
740cA*    OPTBUL  -  Bulk items enabled
740cA*    OPTEYS  -  Display empty stops
740cA*    OPTSAS  -  Save after scan
740cA*    OPTSDL  -  Save delay
740cA*    OPTSDT  -  Sync date and time
740cA*    OPTLRK  -  Left/right keys enabled
740cA*    OPTGSS  -  GS1 scanning
740cA*    OPTGSU  -  GS1 unique
740cA*    OPTSBV  -  Scan beep volume
740cA*    OPTRAG  -  Restart after get route.
740cA*    OPTRD   -  Restart daily.
740cA*    OPTRDT  -  Restart daily time.
740cA*    OPTRFP  -  Reader focus position.
740cA*    OPTRFM  -  Reader focus mode.
740cA*    OPTNSR  -  Non scan reason prompt.
740cA*    OPTFBD  -  Filter by department.
740cA*    OPTDSF  -  Display stop flags before restart.
740cA*    OPTSOR  -  Sort items by compartment Y/N.
740cA*    OPTODE  -  Customer on site delivery enable Y/N.
740cA*    OPTODP  -  Customer on site delivery verification period, 5-60.
740cA*    OPTONT  -  On truck picking Y/N.
740cA*    OPTOTP  -  Override truck picking Y/N.
740cA*    OPTNSB  -  No signee button on signature screen Y/N.
740cA*    OPTRAXINV - 1 = Print all invoices
740cA*                2 = Print pristine invoices only
740cA*                3 = Print non-pristine invoices only
740cA*                9 = Print no invoices
740cA*
740cA* Data structure
740cA*
740cAD opdat2          ds
740cAD  opthst                 1      3  0
740cAD  optsli                 4      4
740cAD  optcwr                 5      5
740cAD  optoft                 6      6
740cAD  optdft                 7      7
740cAD  optrft                 8      8
740cAD  optcap                 9      9
740cAD  optdbl                10     10
740cAD  optekd                11     11
740cAD  optdar                12     12
740cAD  optidb                13     13
740cAD  optbda                14     14
740cAD  optgbd                15     15
740cAD  optrtq                16     16
740cAD  optotq                17     17
740cAD  optcce                18     18
740cAD  optsig                19     19
740cAD  optpiv                20     20
740cAD  optsda                21     21
740cAD  optwsp                22     26  0
740cAD  optwsi                27     41
740cAD  optsvd                42     43  0
740cAD  optert                44     47
740cAD  optedv                48     57
740cAD  opteos                58     67
740cAD  optesw                68     71  0
740cAD  optesh                72     75  0
740cAD  optare                76     76
740cAD  optidl                77     77
740cAD  optdci                78     78
740cAD  optpal                79     79
740cAD  optcra                80     80
740cAD  optdrv                81     81
740cAD  optbul                82     82
740cAD  opteys                83     83
740cAD  optsas                84     84
740cAD  optsdl                85     86  0
740cAD  optsdt                87     87
740cAD  optlrk                88     88
740cAD  optgss                89     89
740cAD  optgsu                90     90
740cAD  optsbv                91     91  0
740cAD  optrag                92     92
740cAD  optrd                 93     93
740cAD  optrdt                94     97  0
740cAD  optrfp                98     98
740cAD  optrfm                99     99
740cAD  optnsr               100    100
740cAD  optfbd               101    101
740cAD  optdsf               102    102
740cAD  optsor               103    103
740cAD  optode               104    104
740cAD  optodp               105    106  0
740cAD  optont               107    107
740cAD  optotp               108    108
740cAD  optnsb               109    109
740cAD  optraxinv            110    110
740cAD  opten2               117    117

700dA*----------------------------------------------------------------
700dA*  File data structures
700dA*----------------------------------------------------------------
700dAD opirec        e ds                  extname(OPTIONINT) inz(*EXTDFT)
700dAD ucirec        e ds                  extname(UCIINFO) inz(*EXTDFT)
730bAD uiarec        e ds                  extname(UCIINFOEXA) inz(*EXTDFT)
700dA
640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aA
640aAD GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200
DRY A*
DRY Ad DryExportPgm    pr                  Extpgm('BFCECS01C')
DRY Ad* Input
DRY Ad   $hWhsen                      3  0
DRY Ad   $hbatid                     11
DRY Ad   $hflib                      10
DRY Ad* Output
DRY Ad   $hrtn                        8
DRYcA*
DRYcAD ClrInusePgm     pr                  Extpgm('CHKIUSE2')
DRYcAD* Input
DRYcAD   $icmd                        8
DRYcAD   $iwhse                       3  0
DRYcAD   $irtid                       5
DRYcAD   $ipgm                       10
DRYcAD   $iuser                      10
DRYcAD   $isessid                    40
DRYcAD* Output
DRYcAD   $irtn                        8
DRYcAD   $iutext10                   10
DRYcAD   $iutext30                   30
DRYcAD   $iucmd                       8
DRYcAD   $iupgm                      20
DRYcAD   $iuUser                     10
DRYcAD   $iuSessId                   40
DRYcAD   $iuJobName                  10
DRYcAD   $iuJobNbr                    6
DRYdAD   $iuJobUser                  10
DRYcAD   $iuStamp                    26

CBIiA /copy qcopysrc,p.cvtbar
CBIiA /copy qcopysrc,c#cvtparms
CBIiA /copy qcopysrc,c#barcode
740aA /copy qcopysrc,p.getopint

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $PCMD   *ALL     - All files
640aA*              *HDRDTL  - Header/Detail files only
640aA*              TALL     - All files - Test
640aA*              THDRDTL  - Header/Detail files only - Test
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
     *      $PRTE   Route
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------

     C     *entry        plist
640aAC                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
     C                   parm                    $prtn             8
640aA
640aAC                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     C                   eval      error = *off
     C                   eval      $prtn = *blanks
CBI1AC                   eval      lastrte = *off
CBI1AC                   eval      savrtid = $prtid

700aA*
700aA*  First check route status.
700aA*  This is needed now that GUI is submitting exports to batch.
700aA*
700aAC     keyoh         chain     rtehed
700aAC                   if        %found(rtehed)
700bAC                             and (rhstat = '5'
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
700aAC                   if        $pcmd <> 'TALL' and $pcmd <> 'THDRDTL'
700aAC                   update    rhrec
700aAC                   endif
700aA*
700aA*  if route not found or status not 5, exit program
700aAC                   else
700aAC                   eval      *inlr = *on
700aAC                   goto      bottom
700aAC                   endif

CBI4AC                   if        client = cheney and
CBI4AC                             clientloc = cbiriv
CBI1A
CBI1A*  For Cheney/BREAKERS, find if batch id already picked.
CBI1A
CBI6DC*>                 if        ohtruk = 'BREAKERS' or
CBI6DC*>                           %subst($prte:2:3) = '075'

CBI6AC                   if        ohtruk = 'BREAKERS'
      *-----------New Logical Starts Here------------------------------

CBI2AC                   eval      savbatchid = *blanks

CBI2A *  Find batch id of Route#/RouteId being passed.
CBI2AC     keyimpsor1    chain     impsordh3                          79
CBI2AC
CBI2AC                   if        *in79 = *off and
CBI2AC                             oihstatus = 'S'
CBI2AC                   eval      savbatchid = oihbatid
CBI2AC                   else
CBI2AC                   eval      $prtn = '*ERROR'
CBI2AC                   return
CBI2AC                   endif

      *  Find if Rte# and Route id passed are the last one for this
      *  batch id, If true write a EXPCLSRTE otherwise write a
      *  EXPSELTRN into STGBATCH file.
CBI2AC                   eval      sltrn     = 'N'

CBI2AC     keyimpsor     setll     impsordh
CBI2AC     keyimpsor     reade     impsordh                               77
CBI2AC                   dow       *in77 <> *on
      *
CBI2AC                   if        oihrteid <> $prtid

CBI2AC                   if        oihstatus = 'S'
CBI2AC                   eval      sltrn     = 'Y'
CBI2AC                   leave
CBI2AC                   endif

CBI2AC                   endif

CBI2AC     keyimpsor     reade     impsordh                               77
CBI2AC                   enddo


CBI2A *  Set the read mechanism to point back to "Impsordh" record
CBI2A *  holding the passed Route # and Route Id to be processed.
CBI2AC     keyimpsor1    chain     impsordh3                          79

CBI2AC                   if        sltrn = 'N'
CBI2AC                   if        $pcmd    = '*HDRDTL' or
CBI2AC                             $pcmd    = 'THDRDTL'
CBI2AC                   eval      onlyHdrDtl = *on
CBI2AC                   goto      bypass1
CBI2AC                   endif
CBI2AC                   endif

CBI2AC                   eval      onlyHdrDtl = *on
CBI2AC                   goto      bypassbatch

CBI2AC     bypass1       tag

      *-----------New Logic Ends Here ---------------------------------

      *                  Endif for ohtruk = 'BREAKERS above.
CBI1AC                   endif
CBI4A *                  Endif for client = cheney.
CBI4AC                   endif




      /free

         *inlr = *on;

         // Get batch id

         monitor;
           if $pcmd = '*HDRDTL' or $pcmd = 'THDRDTL';
             onlyHdrDtl = *on;
             GetBatId($pWhse: 'EXPCLSRTE': 'W':
                      batId: rtnCode: rtnMessage);
           else;
             onlyHdrDtl = *off;
             GetBatId($pWhse: 'EXPROUTE': 'W':
                      batId: rtnCode: rtnMessage);
           endif;
         on-error;
           rtnCode = '*ERROR';
         endmon;

         if rtnCode <> '*OK';
           $prtn = '*ERROR';
           return;
         endif;

CBIiA    if OptUseOrdU = 'Y'
CBIiA     and client = cheney;
CBIjD    //monitor;
CBIjD    //  GetBatId($pWhse: 'EXPCBIUCI': 'W':
CBIjD    //           batIdCBI: rtnCode: rtnMessage);
CBIjD    //on-error;
CBIjD    //  rtnCode = '*ERROR';
CBIjD    //endmon;
CBIjA      batIdCBI = *blanks;
CBIiA    endif;
CBIiA
CBIiA    if rtnCode <> '*OK';
CBIiA      $prtn = '*ERROR';
CBIiA      return;
CBIiA    endif;
CBIiA /end-free

CBI1AC     bypassbatch   tag

CBIfA
CBIfA*  For Cheney, when doing *HDRDTL, process Gen 2 Trans w/catchweights.
CBIfA
CBIfAC                   if        onlyHdrDtl and client = cheney
CBIfAC                   exsr      zzCBIGEN2
CBIfAC                   endif
CBIcA
CBIcA*  For Cheney, get pallet id prefix characters
CBIcA
CBIcAC                   if        client = cheney
CBIcAC     *DTAARA       define    prefix        cbiPrefix         2
CBIcAC                   in(e)     cbiPrefix
CBIcAC                   if        %error
CBIcAC                   eval      cbiPrefix = '@@'
CBIcAC                   endif
CBIcAC                   endif

CBI2A *  Return if not ready to create STGBATCH/EXPCLSRTE record,
CBI2A *  otherwise, write EXPSORDH - ORDD records.

CBI4AC                   if        client = cheney and
CBI4AC                             clientloc = cbiriv
CBI4AC*
CBI6DC*>                 if        ohtruk = 'BREAKERS' and
CBI6DC*>                           sltrn      = 'Y'    or
CBI6DC*>                           %subst($prte:3:2) = '75' and
CBI6DC*>                           sltrn      = 'Y'
CBI6DC*>                 goto      bottom
CBI6DC*>                 endif

CBI6AC                   if        ohtruk = 'BREAKERS' and
CBI6AC                             sltrn  = 'Y'
CBI6AC                   goto      bottom
CBI6AC                   endif

CBI6DC*>                 if        ohtruk = 'BREAKERS' and
CBI6DC*>                           sltrn      = 'N'    or
CBI6DC*>                           %subst($prte:3:2) = '75' and
CBI6DC*>                           sltrn      = 'N'

CBI6AC                   if        ohtruk = 'BREAKERS' and
CBI6AC                             sltrn  = 'N'

CBI2AC     keyimpsor     setll     impsordh
CBI2AC     keyimpsor     reade     impsordh                               77
CBI2AC                   if        *in77 = *off
CBI2AC                   eval      $prtid = oihrteid
CBI2AC                   else
CBI2AC                   eval      $prtid = *blanks
CBI2AC                   endif
CBI2AC                   endif
CBI4AC                   endif

     *
     *  Get order header record.
     *
404 AC     keyoh         setll     ordh3
404 AC                   dou       forevr <> forevr
404 AC     keyoh         reade     ordh3                                  79
404 A*
     C                   if        *in79
404 AC                   leave
     C                   endif
650 A*
650 A*  Retrieve order header misc. file.
650 AC                   exsr      getohm
     *
     *  Add order header record to export header file.
     *
     C                   exsr      filoeh
     C                   write     oehrec

CBI1AC     bypassheader  tag
     *
     *  Add order detail records to export detail file.
     *
     C     keyod         setll     ordd
     C                   dou       forevr <> forevr
     C     keyod         reade     ordd                                   78
     C                   if        *in78
     C                   leave
     C                   endif

CBIlA /free
CBIlA   // Client specific checks
CBIlA   select;
CBIlA     when client = cheney;
CBIlA       // if item designation = 'NOALC', skip it.
CBIlA       chain (odwhse: oditem) piritem;
CBIlA       if %found(piritem) and itdesg = 'NOALC';
CBIlA         iter;
CBIlA       endif;
CBIlA     other;
CBIlA   endsl;
CBIlA /end-free

640dAC                   exsr      getodm
     C                   exsr      filoed
     C                   write     oedrec
CBIiA /free
CBIiA     // write ORDU records
CBIiA     if OptUseOrdU = 'Y';
CBIiA       select;
CBIiA        when client = cheney;
CBIiA          exsr wrtoeucbi;
CBIiA       endsl;
CBIiA     endif;
CBIiA /end-free
730bA*
730bA*  Add order lot records.
730bA*
730bA *  if uci tracking get uci records
730bA *  otherwise get liclog for the license
730bA /free
730bA   chain (odwhse: oditem) itemmsc;
730bA   if not %found(itemmsc);
730bA     imltrk = ' ';
730bA   endif;
730bA   select;
730bA     when imltrk = 'U';
730bA       exec sql declare ucicsru cursor for
730bA                 select * from uciinfo
730bA                  where uiwhse = :odwhse
730bA                    and uiselord = :odord
730bA                    and uiselseq = :odseq
730bA                    and uiitem = :oditem;
730bA
730bA       exec sql open ucicsru;
730bA       dow forever = forever;
730bA         exec sql fetch next from ucicsru
730bA                   into :ucirec;
730bA
730bA         if sqlstt <> sqlSuccess;
730bA           leave;
730bA         endif;
730bA         cvtbar('*ALL': uiuci:
730bA            $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
740 M            $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse:
740 A            $cbkilolbsSent: $cbitem);
740 D           //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse);
730bA         $barcode = $cvtdata;
730bA         // get uciinfo extension file
730bA         exec sql select * into :uiarec
730bA                from UCIINFOEXA
730bA                where uiaaddts = :uiaddts
730bA                  and uiaucilcns = :uiucilcns
730bA                  and uialcns = :uilcns
730bA                fetch first row only;
730bA         if sqlstt <> sqlSuccess;
730bA           clear uialot;
730bA           clear uiaolcns;
730bA           clear uiagtin;
730bA         endif;
730bA         exsr filoelt;
730bA         write oeltrec;
730bA       enddo;
730bA       exec sql close ucicsru;
730bA     other;
730bA       setll (odwhse:odord:odseq:oditem) liclog6;
730bA       dow forever = forever;
730bA         reade (odwhse:odord:odseq:oditem) liclog6;
730bA         if %eof(liclog6);
730bA           leave;
730bA         endif;
730bA         if llaction <> 'SEL';
730bA           iter;
730bA         endif;
730bA         exsr filoelt;
730bA         write oeltrec;
730bA       enddo;
730bA   endsl;
730bA /end-free

     C                   enddo
640aA*
640aA*  Skip all other export files if only doing header/detail
640aA*
640aAC                   if        onlyHdrDtl
640aAC                   goto      skipFiles
640aAC                   endif
     *
     *  Add order catch weight records to export catch weight file.
     *
     C     keyod         setll     ordc
     C                   dou       forevr <> forevr
     C     keyod         reade     ordc                                   78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   exsr      filoec
     C                   write     oecrec
     C                   enddo
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
417aAC                   endif
417aAC                   if        lbutyp = '1'
417bMC                   add       lbqpck        otpck2
417aAC                   endif
417aAC                   if        lbutyp = '2'
417bMC                   add       lbqpck        otpck3
417aAC                   endif
     *
417aAC                   endif
     *
417bAC                   enddo
     *
417aAC                   update    otrec
EFC A*
EFC AC                   if        client = Eastland
EFC A*      Bypass populating EXPSORDT file.
EFC AC                   else
EFC A*
213 AC                   exsr      filoet
213 AC                   write     oetrec
EFC AC                   endif
EFC A*
213 AC                   enddo
     *
500 A*  Add order detail box code rcds to export box code file.
500 A*
510bAC                   if        standa = *on
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
510bAC                   endif
     *
510cA*  Add label recs to order detail label# export file
CBIbDC**                 if        client = cheney
640aDC**                 if        client = ellenbe
510fMC     keylb93       setll     label93
510cAC                   dou       forevr <> forevr
510fMC     keylb93       reade     label93

640aDC**                 select
640aDC**                 when      %eof(label93)
640aMC                   if        %eof(label93)
510cAC                   leave
640aAC                   endif

640aAC                   if        lbrte <> $prtid
640aAC                   iter
640aAC                   endif
CBIeA
CBIeA*  For Cheney, only write O and B records.
CBIhA*  and 'M' records.
CBIeA
CBIeMC                   if        client = cheney
CBIeMC                   if        lbtype <> 'O' and lbtype <> 'B'
CBIhAC                             and lbtype <> 'M'
CBIeAC                   iter
CBIeAC                   endif
CBIeAC                   endif

640aDC**                 other
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

CBIlA /free
CBIlA   // Client specific checks
CBIlA   select;
CBIlA     when client = cheney;
CBIlA       // if item designation = 'NOALC', skip it.
CBIlA       chain (odwhse: oditem) piritem;
CBIlA       if %found(piritem) and itdesg = 'NOALC';
CBIlA         iter;
CBIlA       endif;
CBIlA     other;
CBIlA   endsl;
CBIlA /end-free

510cAC                   exsr      filoel
510cAC                   write     oelrec
640aDC**                 endsl

510cAC                   enddo
640aDC**                 endif
510ha*
510hA*  Add order detail piece rcds to export piece file.
510hA*
640aDC**                 if        client = cheney
510hAC     keyod         setll     ordp1
510hAC                   dou       forevr <> forevr
510hAC     keyod         reade     ordp1
510hAC                   select
510hAC                   when      %eof(ordp1)
510hAC                   leave
510hAC                   other
510hAC                   exsr      filoep
510hAC                   write     oeprec
510hAC                   endsl
510hAC                   enddo
640aDC**                 endif
     *
640aAC     skipFiles     tag
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
640bAC                   if        $pcmd <> 'TALL' and $pcmd <> 'THDRDTL'
     C                   update    rhrec
640bAC                   endif
     C                   endif
     *
     *  Update order header record with upload date and time.
     *
     C                   eval      ohstat = 'C'
     C                   eval      ohsdte = today
     C                   time                    ohstim
     C                   eval      ohudte = ohsdte
     C                   eval      ohutim = ohstim
640bAC                   if        $pcmd <> 'TALL' and $pcmd <> 'THDRDTL'
     C                   update    ohrec
640bAC                   endif
     *
CBI4AC                   if        client = cheney and
CBI4AC                             clientloc = cbiriv
CBI4A*
CBI6DC*>                 if        ohtruk ='BREAKERS' and
CBI6DC*>                           sltrn      = 'N'   or
CBI6DC*>                           %subst($prte:3:2) = '75' and
CBI6DC*>                           sltrn      = 'N'

CBI6AC                   if        ohtruk ='BREAKERS' and
CBI6AC                             sltrn  = 'N'

CBI2AC     keyimpsor     reade     impsordh                               77
CBI2AC                   if        *in77 = *off
CBI2AC                   eval      $prtid = oihrteid
CBI2AC                   else
CBI2AC                   eval      $prtid = *blanks
CBI2AC                   endif
CBI2AC     keyoh         setll     ordh3
CBI2AC                   endif
CBI4AC                   endif
     *
     *  Enddo for stmt # 613.00 - dou forevr <> forevr
404 AC                   enddo
404 A*
     *
     C     bottom        tag

CBI4AC                   if        client = cheney and
CBI4AC                             clientloc = cbiriv
CBI4A*
CBI2AC                   eval      $prtid = savrtid
CBI1AC     keyimpsor1    chain     impsordh3                          79
CBI1AC                   if        not *in79
CBI6DC*>                 if        ohtruk ='BREAKERS' or
CBI6DC*>                           %subst($prte:3:2) = '75'

CBI6AC                   if        ohtruk ='BREAKERS'
CBI2AC                   eval      oihstatus  = 'P'
CBI2AC                   update    oihrec
CBI2AC                   endif
CBI2AC                   endif
CBI4AC                   endif

640aAC                   exsr      zzzEnd

IFDaA /free
IFDaA   select;
DRY A      when client = Dairyland;
DRY A        if sqlstt = sqlSuccess;
DRY A          callp(e) DryExportPgm($pwhse:batid:f1library:hrtn);
DRYcA          $icmd = '*CLEAR  ';
DRYcA          callp(e) ClrInusePgm($icmd:$pwhse:$prtid:#prog:#user:
                                    $isessid:$irtn:$iutext10:$iutext30:
                                    $iucmd:$iupgm:$iuuser:$iusessid:
DRYdM                               $iujobname:$iujobnbr:$iujobuser:$iustamp);
DRY A        endif;
DRY A
IFDaA     when client = ifd;
IFDaA       NetSuiteExport(%editc($pwhse:'X'):batId);
IFDaA     other;
IFDaA   endsl;
IFDaA /end-free

720aA /free
720aA   if optrax = 'Y'
740cA    and optraxinv = '9';
720aA     exsr wrtTraxXml;
720aA   endif;

750aA  // set orders back to Super Route once exported
750aA  setll ($pWhse:$pRtid) srord1;
750aA  dow forever = forever;
750aA    reade ($pWhse:$pRtid) srord1;
750aA    if not %equal(srord1) or %eof(srord1);
750aA      leave;
750aA    endif;
750aA    exec sql update ordh3 set ohrte=:srosrtid
750aA              where ohwhse=:$pWhse and ohrte=:sromrtid;
750aA  enddo;

720aA /end-free

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
740aAc                   parm                    clientinit        3
740aAc                   parm                    clienthost       10
     *
     *   Define partial key for ORDD file.
     *
     C     keyod         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord
     *
     *   Define  key for ORDH3 file.
     *
     C     keyoh         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
CBI1A*
CBI1A*   Define  key for RTEHED file.
CBI1A*
CBI1AC     keyoh3        klist
CBI1AC                   kfld                    $pwhse
CBI1AC                   kfld                    oihrteid
650 A*
650 A*   Define full key for ORDHM file.
650 A*
650 AC     keyhm         klist
650 AC                   kfld                    ohwhse
650 AC                   kfld                    ohord
500aA*
500aA*   Define full key for ORDD file.
500aA*
500aAC     keyob         klist
500aAC                   kfld                    obwhse
500aAC                   kfld                    obord
500aAC                   kfld                    obseq#
500aAC                   kfld                    obitem
640dA*
640dA*   Define full key for ORDDM file.
640dA*
640dAC     keyom         klist
640dAC                   kfld                    odwhse
640dAC                   kfld                    odord
640dAC                   kfld                    odseq
640dAC                   kfld                    oditem
500aA*
500aA*   Define full key for ORDD file.
500aA*
500aAC     keyoe         klist
500aAC                   kfld                    oewhse
500aAC                   kfld                    oeord
500aAC                   kfld                    oeseq#
500aAC                   kfld                    oeitem
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
720aA*  Define partial key for OPTIONS file.
720aA*
720aAC     keyopSys      klist
720aAC                   kfld                    sysWhse
720aAC                   kfld                    opcode
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
      *
CBI1A *   Define full key for IMPSORDH3 file.
      *
CBI1AC     keyimpsor1    klist
     C                   kfld                    $pwhse
CBI1MC                   kfld                    $prte
     C                   kfld                    $prtid
      *
CBI2A *   Define full key for IMPSORDH file.
      *
CBI2MC     keyimpsor     klist
     C                   kfld                    $pwhse
CBI2MC                   kfld                    savbatchid

     *
510fA*    Open client-specific files.
CBIbDC**                 if        client = Cheney
640aDC**                 if        client = Ellenbe
640aD **
640aDC**                 if        not %open(label93)
640aDC**                 open      label93
640aDC**                 endif
640aD **
640aDC**                 endif
     *
CBIbMC                   if        client = Cheney
CBIbMC                   if        not %open(pltsum4)
CBIaAC                   open      pltsum4
CBIfAC                   open      pltsum12
CBIaAC                   endif
CBIbAC                   endif
     *
640aDC**                 if        client = Cheney
640aDC**                 if        not %open(ordp1)
640aDC**                 open      ordp1
640aDC**                 if        not %open(expsordp)
640aDC**                 open      expsordp
640aDC**                 endif
640aDC**                 endif
640aDC**                 endif
     *
640aDC**                 if        client = Cheney
640aDC**                 if        not %open(worklbl)
640aDC**                 open      worklbl
640aDC**                 endif
640aDC**                 endif
     *
720aA*   Get *SYSTEM options from options file.
720aA*
720aAC                   eval      opcode = '*SYSTEM '
720aAC     keyopSys      chain     options
720aAC                   if        not %found(options)
720aAC                   eval      optrax = 'N'
720aAC                   else
720aAC                   eval      opdat1 = opdata
720aAC                   endif
     *
740cA*   Get *TRAX options from options file.
740cA*
740cAC                   eval      opcode = '*TRAX   '
740cAC     keyop         chain     options
740cAC                   if        not %found(options)
740cAC                   eval      optraxinv = '9'
740cAC                   else
740cAC                   eval      opdat2 = opdata
740cAC                   endif
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
700dA /free
700dA   // Get Option to see if ORDU file is used.
700dA   exec sql select substr(OPIVALA,1,1) into :OptUseOrdU
700dA              from OPTIONINT
700dA             where OPITYPE = 'EXPORD'
700dA               and OPICAT  = 'ORDER UCI'
700dA               and OPINAME = 'EXPORT UCI RECORD';
700dA
700dA   if sqlstt <> sqlsuccess;
700dA     OptUseOrdU = 'N';
700dA     // record not found, insert defaults so record exists.
700dA     OPITYPE = 'EXPORD';
700dA     OPICAT  = 'ORDER UCI';
700dA     OPINAME = 'EXPORT UCI RECORD';
700dA     OPIVALT = 'A';
700dA     OPIVALA = 'N';
700dA     exec sql insert into OPTIONINT values(:opirec);
700dA
700dA   else;
700dA     // record found, but make sure y is uppercase.
700dA     if OptUseOrdU = 'y';
700dA       OptUseOrdU = 'Y';
700dA     endif;
700dA   endif;
700dA
700dA   // Open ORDU File if used.
700dA   if OptUseOrdU = 'Y'
700dA    and not %open(expsordu);
700dA     open expsordu;
700dA   endif;
700dA /end-free
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
CBI4A*
CBI4AC                   if        client = cheney and
CBI4AC                             clientloc = cbiriv
     *
CBI1A*  To find if truck name is "BREAKERS".
CBI1A*
CBI1AC     keyoh         chain     ordh3                              79
CBI4AC                   endif
     *
740aA*  Get Host ERP from OPTIONS
740aAc                   eval      opwhse = 1
740aAc                   eval      opcode = '*HOST   '
740aAc     keyop         chain     options
740aAc                   if        not %found(options)
740aAc                   eval      hostopts = '*NONE'
740aAc                   else
740aAc                   movel     opdata        hostopts
740aAc                   endif
740aA *  Get Host ERP from OPTIONINT
740aA /free
740aA   // Get debug flag
740aA   optint.type = 'Interface   ';
740aA   optint.cat  = 'General Options     ';
740aA   optint.name = 'Host ERP System     ';
740aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
740aA             optint.valn: optint.vala: optint.return);
740aA   if optint.return = '*OK';
740aA     hostoptint = optint.vala;
740aA   else;
740aA     hostoptint = '*NONE';
740aA   endif;
740aA
     C                   endsr
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
640aAC                   eval      oebordid = obord
640aAC                   eval      oebrte   = $prte
640aAC                   eval      oebrteid = $prtid
500aA*
500aA*    Send Host actual sequence number if sent.
500aAC                   if        odor2 > 0
640aMC                   eval      oebseq = odor2
500aAC                   else
640aMC                   eval      oebseq = obseq#
500aAC                   endif
580 AC                   eval      oebitm = obitem
500 AC                   eval      oebtrn = obtran
500 AC                   eval      oeblbl = oblbl#
500 AC                   eval      oebbox = obbox#

640aAC                   exsr      zzzGetStamps
640aAC                   eval      oebbatid = batId
640aAC                   eval      oebstatus = 'R'
640aAC                   eval      oebststs = stamp
640aAC                   eval      oebstsuc = stampuc
640aAC                   eval      oebaddts = stamp
640aAC                   eval      oebadduc = stampuc
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
213 MC                   eval      oecord = oehord
640aAC                   eval      oecordid = ocord
640aAC                   eval      oecrte   = $prte
640aAC                   eval      oecrteid = $prtid
640AmC                   eval      oecosq = ocseq#
     C                   eval      oecitm = ocitem
     C                   eval      oecseq = ocseq
640aAC                   eval      oeclbl = oclbl#
409 AC                   eval      oectrn = octran
     C                   eval      oecwgt = occwgt

640aAC                   exsr      zzzGetStamps
640aAC                   eval      oecbatid = batId
640aAC                   eval      oecstatus = 'R'
640aAC                   eval      oecststs = stamp
640aAC                   eval      oecstsuc = stampuc
640aAC                   eval      oecaddts = stamp
640aAC                   eval      oecadduc = stampuc
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
213 MC                   eval      oedord = oehord
640aAC                   eval      oedordid = odord
640aAC                   eval      oedrte   = $prte
640aAC                   eval      oedrteid = $prtid
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

640aAC                   exsr      zzzGetStamps
640aAC                   eval      oedbatid = batId
640aAC                   eval      oedstatus = 'R'
640aAC                   eval      oedststs = stamp
640aAC                   eval      oedstsuc = stampuc
640aAC                   eval      oedaddts = stamp
640aAC                   eval      oedadduc = stampuc

640dAC                   eval      oedms1 = ommsc1
640dAC                   eval      oedms2 = ommsc2
640dAC                   eval      oedms3 = ommsc3
640dAC                   eval      oedms4 = ommsc4
640dAC                   eval      oedms5 = ommsc5
     *
     C                   endsr
730bA*----------------------------------------------------------------
730bA*
730bA*  FILOELT Fill export Lot fields.
730bA*
730bAC     filoelt       begsr
730bA*
730bA*  Initialize record
730bA*
730bAC                   clear                   oeltrec
730bA*
730bA*  Move fields from liclog or uciinfo to export file.
730bA*
730bA /free
730bA   oeltwhs = odwhse;
730bA   oeltrte   = $prte;
730bA   oeltrteid = $prtid;
730bA   oeltord = oehord;
730bA   oeltordid = odord;
730bA   oeltseq = odseq;
730bA   oeltitm = oditem;
730bA   if imltrk <> 'U';
730bA     oeltlbl = lllbl#;
760aA     if clienthost = freshbyte;
760aA       oelthstlot = ' ';
760aA     else;
730bA       oelthstlot = lllcns;
760aA     endif;
730bA     oeltqty1 = LLAQTY1 * -1;
730bA     oeltqty2 = LLAQTY2 * -1;
730bA     oeltqty3 = LLAQTY3 * -1;
730bA     oeltlcns   = lllcns;
730bA     oeltolcns = llolcns;
730bA     oelttrn = lltrn#;
730bA   else;
730bA     //uci
730bA     oeltlbl = uisellbl#;
730bA     select;
760aA       when clienthost = freshbyte;
760aA         oelthstlot = ' ';
730bA       when uiserial <> ' ';
730bA         oelthstlot = uiserial;
730bA       when uialot <> ' ';
730bA         oelthstlot = uialot;
730bA       other;
730bA         oelthstlot = uilcns;
730bA     endsl;
730bA     Select;
730bA       when uiautyp = 'N';
730bA         oeltqty1 = 1;
730bA       when uiautyp = '1';
730bA         oeltqty2 = 1;
730bA       when uiautyp = '2';
730bA         oeltqty3 = 1;
730bA       other;
730bA         oeltqty1 = 1;
730bA     endsl;
730bA     oeltlcns  = uilcns;
730bA     oeltolcns = uiaolcns;
730bA     oeltuci = uiuci;
730bA     //oeltuciseq =
730bA     oeltgtin = %char(uiagtin);
730bA     select;
730bA       when $bcpackd <> 0;
730bA         oeltdate = $bcpackd;
730bA         oeltdatecd = '13';
730bA         oeltdatenm = 'PACK';
730bA       when $bcprodd <> 0;
730bA         oeltdate = $bcprodd;
730bA         oeltdatecd = '11';
730bA         oeltdatenm = 'PROD';
730bA       when $bcslbyd <> 0;
730bA         oeltdate = $bcslbyd;
730bA         oeltdatecd = '15';
730bA         oeltdatenm = 'SELL';
730bA       when $bcexpd  <> 0;
730bA         oeltdate = $bcexpd;
730bA         oeltdatecd = '17';
730bA         oeltdatenm = 'EXP';
730bA     endsl;
730bA     oeltlot = uialot;
730bA     oeltserial = uiserial;
730bA     oeltwgt = uiwgtlbs;
730bA     oelttrn = uiseltrn#;
730bA
730bA   endif;
730bA
730bA   chain (odwhse: oeltolcns: 1) licinfo;
730bA   if not %found(licinfo);
730bA   else;
730bA     oeltpo = lnpo;
730bA     oeltposeq = lnposeq;
760aA     if clienthost = freshbyte;
760aA       OELTHSTLOT = lnlot;
760aA     endif;
730bA   endif;

730bA   exsr zzzGetStamps;
730bA   oeltbatid = batId;
730bA   oeltstatus = 'R';
730bA   oeltststs = stamp;
730bA   oeltstsuc = stampuc;
730bA   oeltaddts = stamp;
730bA   oeltadduc = stampuc;
730bA   oelttext = ' ';
730bA /end-free

     *
730bAC                   endsr
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
640aAC                   eval      oeeordid = oeord
640aAC                   eval      oeerte   = $prte
640aAC                   eval      oeerteid = $prtid
500aA*
500aA*    Send Host actual sequence number if sent.
500aAC                   if        odor2 > 0
640aMC                   eval      oeeseq = odor2
500aAC                   else
640aMC                   eval      oeeseq = oeseq#
500aAC                   endif
580 AC                   eval      oeeitm = oeitem
500 AC                   eval      oeetrn = oetran
500 AC                   eval      oeelbl = oelbl#
500 AC                   eval      oeedte = oedate

640aAC                   exsr      zzzGetStamps
640aAC                   eval      oeebatid = batId
640aAC                   eval      oeestatus = 'R'
640aAC                   eval      oeeststs = stamp
640aAC                   eval      oeestsuc = stampuc
640aAC                   eval      oeeaddts = stamp
640aAC                   eval      oeeadduc = stampuc
500 A*
500 AC                   endsr
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
213 MC                   eval      oehord = ohcord
640aAC                   eval      oehordid = ohord
640aAC                   eval      oehrte   = $prte
640aAC                   eval      oehrteid = $prtid
     C                   eval      oehtyp = ohtype
     C                   eval      oehcpo = ohcpo
     C                   eval      oehcus = ohcust
     C                   eval      oehcnm = ohcnam
     C                   eval      oehca1 = ohcad1
     C                   eval      oehca2 = ohcad2
     C                   eval      oehcct = ohccty
     C                   eval      oehcst = ohcst
     C                   eval      oehczp = ohczip
222 MC                   eval      oehrte = $prte
     C                   eval      oehstp = ohstop
DRYaA*
DRYaAC                   select
DRYaAC                   when      client = Dairyland
DRYaAC                   eval      oehtrk = dryhm1_trkid
DRYaAC                   other
DRYaA*
     C                   eval      oehtrk = ohtruk
DRYaAC                   endsl
DRYaA*
     C                   eval      oehmis = ohmisc
     C                   eval      oehpbt = ohpbat
     C                   eval      oehdte = ohsdte
     C                   eval      oehtim = ohstim

640cAC                   call      'GETTRLR'
640cAC                   parm      ohwhse        $gwhse            3 0
640cAC                   parm      ohrte         $grtid            5
640cAC                   parm      ' '           $gtrlr            8
640cAC                   eval      oehtrlr = $gtrlr

640aAC                   exsr      zzzGetStamps
640aAC                   eval      oehbatid = batId
640aAC                   eval      oehstatus = 'R'
640aAC                   eval      oehststs = stamp
640aAC                   eval      oehstsuc = stampuc
640aAC                   eval      oehaddts = stamp
640aAC                   eval      oehadduc = stampuc

720 AC                   eval      oehms1 = hmmsc1
720 AC                   eval      oehms2 = hmmsc2
720 AC                   eval      oehms3 = hmmsc3
720 AC                   eval      oehms4 = hmmsc4
720 AC                   eval      oehms5 = hmmsc5
     * Determine Extended Stop
730aAC                   call      'GETSTOP'
730aAc                   parm      '*ORDSTP'     $sCmd             8
730aAc                   parm      $pwhse        $sWhse            3 0
730aAc                   parm      $pRtId        $sRtid            5
730aAc                   parm      oehord        $sord             7 0
730aAc                   parm      0             $pDstp            2 0
730aAc                   parm                    $pHstp            5 0
730aAc                   parm                    $pDdropx          3
730aAc                   parm                    $pDextdx         30
730aAc                   parm                    $pDsdx            9
730aAc                   eval      oehest = $phstp
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
640aAC                   eval      oelordid = lbord
640aAC                   eval      oelrte   = $prte
640aAC                   eval      oelrteid = $prtid
640aMC                   eval      oelseq = lbseq
510cAC                   eval      oelitm = lbitem
510cAC                   eval      oellbl = lblbl#
510cAC                   eval      oeltyp = lbtype
510dAC                   eval      oeldsp = lbdisp
510cAC                   eval      oeltrn = lbtrn#
510cAC                   eval      oelumt = lbutyp
510cAC                   eval      oelalc = lbqalc
640aAC                   select
640aAC                   when      lbutyp = 'N'
640aMC                   eval      oelqp1 = lbqpck
640aAC                   when      lbutyp = '1'
640aAC                   eval      oelqp2 = lbqpck
640aAC                   when      lbutyp = '2'
640aAC                   eval      oelqp3 = lbqpck
640aAC                   endsl
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

CBIdAC                   if        client = cheney
CBIdAC                   exsr      zzzSetBox
CBIdAC                   else
640aAC                   eval      oelbox = 0
CBIdAC                   endif

640aAC                   eval      oelemp = ptemp#

640aAC                   exsr      zzzGetStamps
640aAC                   eval      oelbatid = batId
640aAC                   eval      oelstatus = 'R'
640aAC                   eval      oelststs = stamp
640aAC                   eval      oelstsuc = stampuc
640aAC                   eval      oeladdts = stamp
640aAC                   eval      oeladduc = stampuc
510cA*
510cAC                   endsr
510gA*----------------------------------------------------------------
510gA*
510gA*  FILOEP  Fill order detail piece seq# export file.
510gA*
510gAC     filoep        begsr
520aA*
520aA*  Get corresponding worklbl record.
520aA*
520aAC     orplbl        chain(e)  worklbl
520aAC                   if        not %found(worklbl)
520aAC                   eval      lwtype = ' '
520aAC                   eval      lwdisp = ' '
520aAC                   eval      lwtrn# = 0
520aAC                   eval      lwutyp = ' '
520aAC                   eval      lwpal# = 0
DRYeAC                   eval      lwgen  = 0
520aAC                   endif
510gA*
510gA*  Initialize record
510gA*
510gAC                   clear                   oeprec
510gA*
510gA*  Move fields from label file to export file.
510gA*
510gAC                   eval      oepwhs = orpwhs
510hMC                   eval      oepord = oehord
640aAC                   eval      oepordid = orpord
640aAC                   eval      oeprte   = $prte
640aAC                   eval      oeprteid = $prtid
640aMC                   eval      oeposq = orpsq#
510gAC                   eval      oepitm = orpitm
640aMC                   eval      oepupn = orpup#
510gAC                   eval      oeplbl = orplbl
510gAC                   eval      oeptyp = lwtype
510gAC                   eval      oepdsp = lwdisp
510gAC                   eval      oeptrn = lwtrn#
510gAC                   eval      oepumt = lwutyp
510gAC                   eval      oepseq = orpseq
510gAC                   eval      oepwgt = orpwgt
510iAC                   eval      oepcnt = orpcnt
510iAC                   eval      oepttl = orpttl
510iAC                   eval      oepscn = orpscn
510gA*
DRYeAC                   select
DRYeAC                   when      client = Dairyland
DRYeAC                             and lwgen  = 2
DRYeAC                             and lwtype = 'O'
DRYeA*       Get Truck Pallet Number for PIR Pallet.
DRYeAC                   call      'GETTPL2'
DRYeAC                   parm      '*FIRST'      $gcmd             8
DRYeAC                   parm      orplbl        $glbl#            7 0
DRYeAC                   parm      0             $gtplt            7 0
DRYeAC                   parm      0             $gmlbl            7 0
DRYeAC                   parm      0             $gmpid            7 0
DRYeAC                   parm                    $gsplt            1
DRYeAC                   parm                    $glow             1
DRYeAC                   parm                    $ghnd2            2
DRYeAC                   parm      0             $gqypk            5 0
DRYeAC                   parm      0             $gqypl            5 0
DRYeAC                   parm      ' '           $grtn             8
DRYeA
DRYeAC                   if        $grtn = '*OK'
DRYeAC                   eval      $gpal#      = $gtplt
DRYeAC                   else
DRYeAC                   eval      $gpal#      = 1
DRYeAC                   endif
DRYeA*
DRYeA*       Truck Pallet, get Pallet Number.
DRYeAC                   other
DRYeA*
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
DRYeA*
DRYeAC                   endsl
510gA*
510gAC                   eval      oeppal = $gpal#
CBIcA
CBIcA*  For Cheney, put the special BIGPALCB barcode into oepdsp.
CBIcA
CBIcAC                   if        client = cheney
CBIcAC                   move      lwpal#        temp7a
CBI3MC                   movel     $prte         temp4a
CBI3MC                   move      temp4a        temp2a
CBIcAC                   movel     temp2a        temp7a
CBI5A*
CBI5AC                   select
CBI5D ***                when      clientloc = cbiocl
CBIcD ***                eval      oepdsp = temp7a
CBI5A*
CBI5MC                   when      clientloc = cbiocl
CBI5MC                             or clientloc = cbiriv
CBI5MC                             or clientloc = cbipntgr
CBI7MC                             or clientloc = cbigr
CBI7MC                             or clientloc = cbigo
CBI7MC                             or clientloc = cbist
CBI7MC                             or clientloc = cbimlk
CBI5AC                   eval      oepdsp = $prtid
CBI5AC                                      + %trim(%editc(lwpal#: '4'))
CBI5A*
CBI5MC                   other
CBIcAC                   eval      oepdsp = cbiPrefix + temp7a
CBI5MC                   endsl
CBI5A*
CBIcAC                   endif

640aAC                   exsr      zzzGetStamps
640aAC                   eval      oepbatid = batId
640aAC                   eval      oepstatus = 'R'
640aAC                   eval      oepststs = stamp
640aAC                   eval      oepstsuc = stampuc
640aAC                   eval      oepaddts = stamp
640aAC                   eval      oepadduc = stampuc
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
640aAC                   eval      oetordid = otord
640aAC                   eval      oetrte   = $prte
640aAC                   eval      oetrteid = $prtid
213 AC                   eval      oetseq = otseq
213 AC                   eval      oetitm = otitem
213 AC                   eval      oettrn = ottrn#
417aAC                   eval      oetemp = otemp#
417aAC                   eval      oetpk1 = otpck1
417aAC                   eval      oetpk2 = otpck2
417aAC                   eval      oetpk3 = otpck3

640aAC                   exsr      zzzGetStamps
640aAC                   eval      oetbatid = batId
640aAC                   eval      oetstatus = 'R'
640aAC                   eval      oetststs = stamp
640aAC                   eval      oetstsuc = stampuc
640aAC                   eval      oetaddts = stamp
640aAC                   eval      oetadduc = stampuc
213 A*
213 AC                   endsr
640dA*
CBIiA*----------------------------------------------------------------
CBIiA*
CBIiA*  WRTOEUCBI   Write Order UCI export records - Cheney.
CBIiA*
CBIiA /free
CBIiA   begsr wrtoeucbi;
CBIiA
CBIiA     cntOrduRecs = 1;
CBIiA     exec sql declare ucicsr cursor for
CBIiA               select * from uciinfo
CBIiA                where uiwhse = :odwhse
CBIiA                  and uiselord = :odord
CBIiA                  and uiselseq = :odseq
CBIiA                  and uiitem = :oditem;
CBIiA
CBIiA     exec sql open ucicsr;
CBIiA     exec sql fetch next from ucicsr
CBIiA               into :ucirec;
CBIiA
CBIiA     dow sqlstt = sqlSuccess;
CBIiA
CBIiA       cvtbar('*ALL': uiuci:
CBIiA          $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
740 M          $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse:
740 A        $cbkilolbsSent: $cbitem);
740 D        //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse);
CBIiA       $barcode = $cvtdata;
CBIiA
CBIiA       clear oeurec;
CBIiA       oeuwhs = uiwhse;
CBIiA       oeurte = $prte;
CBIiA       oeuord = ohcord;
CBIiA       oeuosq = uiselseq;
CBIiA       oeuitm = uiitem;
CBIiA       oeulbl = uisellbl#;
CBIiA       oeuuciseq = 0;
CBIiA       oeurteid = $prtid;
CBIiA       oeuordid = uiselord;
CBIiA       oeutrax = uiseltrax;
CBIiA       oeuserial = uiserial;
CBIiA       oeulcns = uilcns;
CBIiA       oeuuci  = uiuci;
CBIiA       if $bcGtinSent;
CBIiA         oeugtin = $bcGtin;
CBIiA       else;
CBIiA         oeuuci = 'UCI NOT SCANNABLE';
CBIiA         oeugtin = *blanks;
CBIiA       endif;
CBIiA       if $bcLotSent;
CBIiA         oeulot = $bcLot;
CBIiA       endif;
CBIiA       if $bcExpDSent;
CBIiA         oeudate = $bcExpD;
CBIiA       endif;
CBIiA
CBIiA       exsr zzzGetStamps;
CBIiA       oeubatid = batIdCBI;
CBIjD     //oeustatus = 'R';
CBIjA       oeustatus = 'Q';
CBIiA       oeuststs = stamp;
CBIiA       oeustsuc = stampuc;
CBIiA       oeuaddts = stamp;
CBIiA       oeuadduc = stampuc;
CBIiA       oeutext = *blanks;
CBIiA       write oeurec;
CBIiA       cntOrduRecs = cntOrduRecs + 1;
CBIiA
CBIiA       exec sql fetch next from ucicsr
CBIiA                 into :ucirec;
CBIiA     enddo;
CBIiA     exec sql close ucicsr;
CBIiA
CBIiA     dou cntOrduRecs > odqpk1;
CBIiA       clear oeurec;
CBIiA       oeuwhs = ohwhse;
CBIiA       oeurte = $prte;
CBIiA       oeuord = ohcord;
CBIiA       oeuosq = odseq;
CBIiA       oeuitm = oditem;
CBIiA       oeulbl = 0;
CBIiA       oeuuciseq = cntOrduRecs;
CBIiA       oeurteid = $prtid;
CBIiA       oeuordid = odord;
CBIiA       oeutrax = *blanks;
CBIiA       oeuserial = *blanks;
CBIiA       oeulcns = *blanks;
CBIiA       oeuuci  = *blanks;
CBIiA       oeugtin = 'UCI NOT SCANNABLE';
CBIiA       oeulot = *blanks;
CBIiA       oeudate = 0;
CBIiA
CBIiA       exsr zzzGetStamps;
CBIiA       oeubatid = batIdCBI;
CBIjD     //oeustatus = 'R';
CBIjA       oeustatus = 'Q';
CBIiA       oeuststs = stamp;
CBIiA       oeustsuc = stampuc;
CBIiA       oeuaddts = stamp;
CBIiA       oeuadduc = stampuc;
CBIiA       oeutext = *blanks;
CBIiA       write oeurec;
CBIiA       cntOrduRecs = cntOrduRecs + 1;
CBIiA     enddo;
CBIiA
CBIiA   endsr; // wrtoeucbi
CBIiA /end-free
640dA*----------------------------------------------------------------
640dA*
640dA*  GETODM  Retrieve Order Detail Misc. record.
640dA*
640dAC     getodm        begsr
640dA*
640dAC     keyom         chain     orddm
640dAC                   if        not %found(orddm)
640dAC                   eval      omodsc = ' '
640dAC                   eval      ompdsc = 'Y'
640dAC                   eval      omrdsc = 'Y'
640dAC                   eval      omcbox = 'N'
640dAC                   eval      omcexp = 'N'
640dAC                   eval      ommsc1 = ' '
640dAC                   eval      ommsc2 = ' '
640dAC                   eval      ommsc3 = ' '
640dAC                   eval      ommsc4 = ' '
KFS A*
KFS AC                   if        client = Kellys
KFS AC                   eval      ommsc4 =%replace('0000000000000000':ommsc4:1)
KFS AC                   endif
KFS A*
640dAC                   eval      ommsc5 = ' '
640dAC                   endif
640dA*
640dAC                   endsr
650 A*
650 A*----------------------------------------------------------------
650 A*
650 A*  GETOHM  Retrieve Order Header Misc. record.
650 A*
650 AC     getohm        begsr
650 A*
650 AC     keyhm         chain     ordhm
650 AC                   if        not %found(ordhm)
650 AC                   eval      hmmsc1 = ' '
650 AC                   eval      hmmsc2 = ' '
650 AC                   eval      hmmsc3 = ' '
650 AC                   eval      hmmsc4 = ' '
KFS A*
KFS AC                   if        client = Kellys
KFS AC                   eval      hmmsc4 =%replace('0000000000000000':hmmsc4:1)
KFS AC                   endif
KFS A*
650 AC                   eval      hmmsc5 = ' '
650 AC                   eval      hmmsc5 = ' '
650 AC                   endif
DRYaA*
DRYaAC                   select
DRYaAC                   when      client = Dairyland
DRYaAC                   eval      ordhm1_dry = hmmsc1
DRYaAC                   endsl
650 A*
650 AC                   endsr

CBIfA*----------------------------------------------------------------
CBIfA*  ZZCBIGEN2    Export Gen 2 trans that have catchweights
CBIfA*----------------------------------------------------------------
CBIfA*
CBIfAC     zzCBIGEN2     begsr

CBIgAC                   eval      lastpstrn# = 0

     C     keyoh         setll     pltsum12
     C                   dow       forever = forever
     C     keyoh         reade     pltsum12

     C                   if        %eof(pltsum12)
     C                   leave
     C                   endif

     C                   if        psgen < 2 or pstrn# = 0
     C                   iter
     C                   endif

CBIgAC                   if        pstrn# = lastpstrn#
CBIgAC                   iter
CBIgAC                   endif

CBIgAC                   eval      lastpstrn# = pstrn#

     C                   call      'RH155ST'
     C                   parm                    pswhse
     C                   parm                    pstrn#
     C                   parm      '*GEN2CW'     rCmd             10

     C                   enddo

     C                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetStamps   Get timestamps
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

720aA*----------------------------------------------------------------
720aA*  wrtTraxXml  Write Trax xml
720aA
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

640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
        endif;

740aA   if (hostopts = NetSuite
740aA    or hostoptint = NetSuite
740aA    or clienthost = NetSuite)
740aA    and BatID <> *blanks;
740aA   //exec sql insert into EXPTRIG
740aA   //           values(:$pWhse, 'EXPROUTE', :BatId, 'R',
740aA   //                 current_timestamp,
740aA   //                 current_timestamp - current_timezone,
740aA   //                 current_timestamp,
740aA   //                 current_timestamp - current_timezone);
740aA   //if sqlstt <> sqlSuccess;
740aA   //endif;
740bA
740bA     ApiNS.Whse = %editc($pwhse:'X');
740bA     ApiNS.Batch = BatId;
740bA     ApiNS.Type = 'EXPROUTE';
740bA     IntApiNS(ApiNS.Whse: ApiNS.Batch: ApiNS.Type:
740bA              ApiNS.Ret: ApiNS.Msg);
740bA     if ApiNS.Ret <> '*OK';
740bA     endif;
740aA   endif;

CBIjD  //exec sql
CBIjD  //  update stgbatch
CBIjD  //  set sbstatus = 'R',
CBIjD  //      sbtext   = ' ',
CBIjD  //      sbststs  = current_timestamp,
CBIjD  //      sbstsuc  = current_timestamp - current_timezone
CBIjD  //  where sbwhse = :$pWhse
CBIjD  //    and sbbatid = :batIdCBI;
CBIiA
CBIiA   if sqlstt <> sqlSuccess;
CBIiA   endif;

      /end-free
     c                   endsr

CBIdA*----------------------------------------------------------------
CBIdA*  zzzSetBox      Set OELBOX value
CBIdA*                   0 = Detail line exists in open tran
CBIdA*                   1 = Detail line does exist in open tran
CBIdA*----------------------------------------------------------------
CBIdA
CBIdAc     zzzSetBox     begsr
      /free

        exec sql
          select count(*) into :count
          from label, pirtran
          where lbwhse = :oelwhs
            and lbrte  = :oelrteid
            and lbord  = :oelordid
            and lbseq  = :oelseq
            and lbitem = :oelitm
            and pttrn# = lbtrn#
            and ptstat in ('1','2','3','8');

        // If no open transactions found, set flag to 1.
        // Otherwise, set to 0.

        if sqlstt = sqlSuccess and count = 0;
          oelbox = 1;
        else;
          oelbox = 0;
        endif;

      /end-free
     c                   endsr
