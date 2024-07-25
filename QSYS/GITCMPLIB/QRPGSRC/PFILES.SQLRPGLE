650aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PFILES    Staging Export - Pick Labels
     *  18 March 2014
     *  Rod Roller
     *
     *  Notes:
     *   Created from PFILE to use Staging Export files. Mods in 650a.
     *   This program should be identical to PFILE except that it uses
     *   EXPSPLBL instead of EXPFPLBL, and has extra code for STGBATCH.
     *   Mods left from PFILE for reference.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
414 A*    08/29/00  DAS  4.14
     *      - Created
     *      - Includes changes made to PLBL40 through 4.13
     *
414aA*    09/13/00  DAS  4.14a
     *      - Field LBECWF added to file EXPFPLBL.
     *      - Revised routine FILLB2 to initialize new field.
     *
530 A*    03/31/10  MLB  5.30
     *      - Fix: Revised program to skip PLTSUM3 records
     *        with zero transaction numbers.
530aA*    05/24/10  MLB  5.30a
     *      - Enh: Revised program to client custom code support.
530bA*    05/24/10  JCJ  5.30b
     *      - Enh: Add *PICKLBA & *PICKLBB.
     *      - Enh: Updated *PICKLBL dspecs
     *
650aA*    03/18/14  RTR  6.50a
     *      - Enh: Created from PFILE and changed to use staging
     *        file EXPSPLBL.
     *
710a *    05/16/17  MR   7.10a
     *      - Recompile for EXPSPLBL file change.
710b *    07/24/17  RTR  7.10b
     *      - Changed to send back batch id in option array.
710c *    08/11/17  RTR  7.10c
     *      - Changed to get extended stop number.
710d *    08/01/17  RTR  7.10d
     *      - User lookup from GLORTELOG.
710e *    09/22/17  RTR  7.10e
     *      - Change to get extended fields in fill subroutine.
710f *    10/03/17  MR   7.10f
     *      - Skip label if label is same as previous to prevent
     *        duplicates.
     *
720 A*    03/07/18  MLB  7.20
     *      - Enh: Revised pgm to call PFILES2 to update additional fields
     *        once PFILES is complete. And, before status to STGBATCH rcd
     *        is changed to R=Ready.
720a *    04/13/18  RTR  7.20a
     *      - Changes to populate SSCC GS1 pallet number. Originally
     *        for Anderson-DuBose.
720b *    04/16/18  RTR  7.20b
     *      - DD2 change to select PSTYPE=P records instead of type O,
     *        only do this for DD2. Checking data area for DD2 usage.
720c *    05/02/18  KDE  7.20c
     *      - Add Pallet ID to keyps to prevent loop
720dA*    05/15/18  MLB  7.20d   was 7.20a at JFF.
     *      - Enh: Revised pgm to retrieve extended stop using call to
     *        GETSTOP. If extended stop number is zero, then send
     *        internal stop number from label rcd.
720eA*    08/13/18  KDE  720e
     *      - Enh: Do not call zzzEND here for staging customers. call in OR640
720fA*    01/02/19  MLB  7.20f
     *      - Enh: Added missing line of code from 7.10b mod. Was not updating
     *        STGBATCH status in OR640.
     *
730 A*    03/04/19  MLB  7.30
     *      - Enh: Revised pgm to increase size of flds in PALSUM DS to
     *        resolve MCH1210 Receiver value too small to hold result error.
     *        Found at Panos Foods.
     *
730a *    05/22/19  KDE 730a
     *      - Enh:  Change to use LABEL32D when customer using
     *        softcoded DFPICK (DFPICKDTL)
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Chef's Warehouse/Dairyland
     *
DRY A*    12/17/13  RTR  DRY
     *      - Revised program to place UOM fields in last 6 pos of lbepak.
     *
750 A*    03/16/21  KDE  7.50
     *      - Revised to call GetTBType instead of reading
     *        data area dragdrop2 directly.
     *      - Replaced usingDD2 with tbEnhanced.
750aA*    08/05/21  MLB  7.50a  ZD# 4897
     *      - Fix: Revised routine PRTXDK to add logic to iter when a
     *        2nd label record was read. This was happening when
     *        a sub was added to the pallet that had the XDK item(s).
     *        Found at Panos Foods.
750bA*    03/02/22  MLB  7.50b
     *      - Created keyps3b from keyps3. Uses kygen instead of $pgen.
     *      - Revised PRTBLK to use keyps3b. Sets kygen to 7 when
     *        using Advanced TB otherwise sets it to $pgen.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fox River Foods
     *
FRF A*    06/02/10  MLB  FRF
     *      - Revised program to use LABEL32D so pick labels are
     *        sent to Host in correct order. Dept DRY before CLR then
     *        all other depts.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Agar Supply Foods
     *
ASC A*    03/29/12  RTR  ASC
     *      - Added call to Lucas Export process
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Nicholas & Co
     *
NCH A*    04/28/14  MLB  NCH
     *      - Enh: Revised pgm to record id sent from AX into Misc 1.
     *      - Added file ORDDM to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Harbor Foods
     *
HARa *    05/10/17  RTR  HARa
     *      - Custom changes for HighJump ERP long order/line.
HARb *    01/18/18  RTR  HARb
     *      - Custom changes to add Dock Door, Trailer, Deliv Date/Time,
     *        and Driver.
HARcA*    07/17/19  MLB  HARc  P#02109
     *      - Custom changes to add Zone Template for route to LBEMS1
     *        in positions 13-22.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Anderson-Dubose
     *
ADCa *    08/11/17  RTR  ADCa
     *      - Enh: Revised pgm to populate LBEMS1 with ORDDM/OMMSC1
     *        and IFCAT.
ADCb *    08/22/17  RTR  ADCb
     *      - Enh: Added external call at end to process data.
     *        Note: External call commented out and moved to OR640.
ADCcA*    06/14/18  MLB  ADCc
     *      - Enh: Revised pgm to load Host line number sent in
     *        ORDD/ODOR2 in LBEMS2 in positions 1-7. Per Adam C email
     *        dated 06/13/18.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jakes Finer Foods
     *
JFF A*    03/01/18  MLB  JFF
     *      - Revised pgm to update LBESLT to remove first embedded dash
     *        from LBDISP. Added during import to TruckBuilder(r) since
     *        Jakes uses mixture of 2 or 3 char aisles.
JFFaA*    03/06/18  MLB  JFFa
     *      - Revised pgm to update fields LBEDSQ, LBEDSQA with value
     *        from ODORD2. During import to TruckBuilder(r), item can be
     *        picked from multiple locations.
JFFcA*    05/22/18  MLB  JFFc
     *      - Revised pgm to write out Pallet ID, A/B retrieved from
     *        LBDSP2 field.  A/B indicator is assigned by pgm, OR625
     *        where A is assigned to lowest pallet number. Pallet ID
     *        will be loaded into pos 1-1 of LBEMS1.
JFFdA*    05/29/18  MLB  JFFd
     *      - Revised pgm to remove code that called QSNDDTAQ for
     *        LTBBPDQQ. Moved call to OR640.  Was triggering route
     *        processing before route data was written to EXPSPLBL.
JFFeA*    03/03/22  MLB  JFFe
     *      - Enh: Revised pgm to load rtxdm3_omslbl into lbems1 in
     *        positions 2 - 4. Needed to help identify multiple bulk
     *        picks on a pallet.  Identified at Jake's.
JFFfA*    03/31/22  MLB  JFFf
     *      - Enh: Revised pgm to retrieve info from merge label rcd
     *        to be updated in type B rcd when written out to EXPSPLBL.
     *        Need unload sequence from merge rcd for bulk picks.
     *      - Added file LABEL11 to pgm.
JFFgA*    03/31/22  MLB  JFFg
     *      - Enh: Corrected issue with JFFe mod. Revised SETEND to
     *        to retrieve ORDDM record for P/W LBL Seq number to write
     *        out to file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: PFG Performance Food Group
     *
PFG A*    02/19/19  MLB  PFG
     *      - Revised pgm to use LF, PLTSUM3RP which puts PSTRN# ahead
     *        of PSUNLD. This is needed when Pallet Label Option is set
     *        to S=SidebySide (which is really by column).
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    The structure of this program is similar to the normal label
     *    printing programs PLBL40 and PFMT. However, instead of
     *    printing labels, a record is written to the export file.
     *
     *    Main differences between printing and writing to a file:
     *
     *      1) No header or summary records are written to the file.
     *      2) An individual record is written for each merge record.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *  90        Overflow indicator for exception report
     *  91        Overflow indicator for catch weight report
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpltsum3   if   e           k disk
PFG AFpltsum3rp if   e           k disk    rename(psrec : psrec3rp)
     Fpltstp1   if   e           k disk
     FLabel31   if   e           k disk
     FLabel32   if   e           k disk
FRF AFlabel32d  if   e           k disk
JFFfAFlabel11   if   e           k disk    rename(lbrec : lbrec11)
JFFfAF                                     prefix(L11)
     Foptions   if   e           k disk
530bCFoptionz   if   e           k disk
NCH AForddm     if   e           k disk    usropn
HARaAFordhm     if   e           k disk    usropn
530bAFtruckh    if   e           k disk
     FLblfmtv   if   e           k disk
720aAFpltmisc   if   e           k disk
     Fexpsplbl  o    e             disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *    General
     *
     D a12             s              1    dim(12)
     D a40             s              1    dim(40)
     D a50             s              1    dim(50)
     D a58             s              1    dim(58)
     D a80             s              1    dim(80)
     *
     *    Input/Output strings
     *
     D sti             s              1    dim(75)
     D sto             s              1    dim(198)
     *
     *    Large Characters
     *
530aA*----------------------------------------------------------------
530aA*  Customer id
530aA*
     D @getcl          c                   const('GETCLIENT')
FRF A /copy qcopysrc,id#FRF
ASC A /copy qcopysrc,id#AGAR
DRY A /copy qcopysrc,id#dairyla
NCH A /copy qcopysrc,id#Nichola
HARaA /copy qcopysrc,id#Harbor
ADCaA /copy qcopysrc,id#adc
JFF A /copy qcopysrc,id#JFF
PFG A /copy qcopysrc,id#PFG
530aA*
     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opten2               117    117
     *----------------------------------------------------------------
     *  Medium stop number data structures.
     *
     D                 ds
     D  ch1                    1    120
     D                                     DIM(12)
     D  stp11                  1     10
     D  stp12                 11     20
     D  stp13                 21     30
     D  stp14                 31     40
     D  stp15                 41     50
     D  stp16                 51     60
     D  stp17                 61     70
     D  stp18                 71     80
     D  stp19                 81     90
     D  stp110                91    100
     D  stp111               101    110
     D  stp112               101    120
     D                 ds
     D  ch2                    1    120
     D                                     DIM(12)
     D  stp21                  1     10
     D  stp22                 11     20
     D  stp23                 21     30
     D  stp24                 31     40
     D  stp25                 41     50
     D  stp26                 51     60
     D  stp27                 61     70
     D  stp28                 71     80
     D  stp29                 81     90
     D  stp210                91    100
     D  stp211               101    110
     D  stp212               101    120
     *----------------------------------------------------------------
     *  Stop summary data structure for one set of labels.
     *  Maximum of 9 stops on one pallet, for fixed section items.
     *  Maximum of 99 stops on one pallet, for PIR section items.
     *
     D stpsum          ds                  occurs(99)
     D  dssstp                 1      2  0
730 MD  dsscub                 3      9  3
730 MD  dsswgt                10     18  2
730 MD  dsspcs                19     23  0
730 MD  dsscnm                24     63
     *----------------------------------------------------------------
     *  Pallet summary data structure for one set of labels.
     *
     D palsum          ds                  occurs(9)
     D  dsppal                 1      7  0
     D  dspstp                 8      9  0
730 DD* dspcub                10     15  3
730 MD  dspcub                10     16  3
730 DD* dspwgt                16     22  2
730 MD  dspwgt                17     25  2
730 DD* dsppcs                23     25  0
730 MD  dsppcs                26     30  0
730 DD* stp                   26     43  0
730 MD  stp                   31     48  0
     D                                     DIM(9)
730 DD* dsppli                44     50  0
730 MD  dsppli                49     55  0
     *----------------------------------------------------------------
     *  PIR stop summary data structure for route.
     *
     D pirsum          ds                  occurs(99)
     D  dsrstp                 1      2  0
     D  dsrcub                 3      8  3
     D  dsrwgt                 9     15  2
     D  dsrpcs                16     18  0
     D  dsrwdp                19     23
     D  dsrcnm                24     63
     D  dsrflg                64     64
     *----------------------------------------------------------------
     *  Zone pickup summary data structure
     *
     D zonpku          ds                  occurs(20)
     D  dszstp                 1      2  0
     D  dszpcs                 3      7  0
     D  dszitm                 8     22
     D  dszdsc                23     52
     D  dszplt                53     59  0
     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
     *    OPPDEV  -  Printer device.
     *    OPPFRM  -  Printer form.
530bA*    OPTAXR  -  Include in Tax Right (Y=Yes, N=No).
530bA*    OPCHKR  -  Include in Check Right (Y=Yes, N=No).
     *
     * Data structure
     *
530bD *** opzdta          ds
530bMD opdta2          ds
     D  opclvl                 1      3  0
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0
     D  opcwgt                53     54  0
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
530bAD  opaisl                85     85
530bAD  optaxr                86     86
530bAD  opchkr                87     87
710bAD  opbatid              100    111
     D  optend               117    117
     *----------------------------------------------------------------
530bA*  *PICKLBA -  Label printing options for the standard pick,
530bA*              retail, and tote labels.
     *
530bA*     08/12/09  RBD  5.20  P#00219
530bA*       - Added record type *PICKLBA which holds printing info
530bA*         for the standard pick, retail, and tote labels.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB1   -  Print standard pick label Y/N.   - Standard pick label
     *    OPCU1   -  Use cutter option Y/N.           - Standard pick label
     *    OPLP1   -  Label printing program.          - Standard pick label
     *    OPDV1   -  Printer device.                  - Standard pick label
     *    OPFM1   -  Form.                            - Standard pick label
     *
     *    OPLB2   -  Print retail label Y/N.          - Retail label
     *    OPCU2   -  Use cutter option Y/N.           - Retail label
     *    OPLP2   -  Label printing program.          - Retail label
     *    OPDV2   -  Printer device.                  - Retail label
     *    OPFM2   -  Form.                            - Retail label
     *
     *    OPLB3   -  Print tote label Y/N.            - Tote label
     *    OPCU3   -  Use cutter option Y/N.           - Tote label
     *    OPLP3   -  Label printing program.          - Tote label
     *    OPDV3   -  Printer device.                  - Tote label
     *    OPFM3   -  Form.                            - Tote label
     *
     * Data structure
     *
     D opdta3          ds
     D  oplb1                  1      1
     D  opcu1                  2      2
     D  oplp1                  3     12
     D  opdv1                 13     22
     D  opfm1                 23     32
     D  oplb2                 33     33
     D  opcu2                 34     34
     D  oplp2                 35     44
     D  opdv2                 45     54
     D  opfm2                 55     64
     D  oplb3                 65     65
     D  opcu3                 66     66
     D  oplp3                 67     76
     D  opdv3                 77     86
     D  opfm3                 87     96
     D  opend3               117    117
     *----------------------------------------------------------------
530bA*  *PICKLBB -  Label printing options for the pick list and
530bA*               ASN labels and pick list report.
     *
530bA*     08/12/09  RBD  5.20  P#00219
530bA*       - Added record type *PICKLBB which holds printing info
530bA*         for the pick list and ASN labels and pick list report.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB4   -  Print pick list label Y/N.       - Pick list label
     *    OPCU4   -  Use cutter option Y/N.           - Pick list label
     *    OPLP4   -  Label printing program.          - Pick list label
     *    OPDV4   -  Printer device.                  - Pick list label
     *    OPFM4   -  Form.                            - Pick list label
     *
     *    OPLB5   -  Print ASN label Y/N.             - ASN label
     *    OPCU5   -  Use cutter option Y/N.           - ASN label
     *    OPLP5   -  Label printing program.          - ASN label
     *    OPDV5   -  Printer device.                  - ASN label
     *    OPFM5   -  Form.                            - ASN label
     *
     *    OPLB6   -  Print pick list report Y/N.      - Pick list report
     *    OPCU6   -  Use cutter option Y/N.           - Pick list report
     *    OPLP6   -  Label printing program.          - Pick list report
     *    OPDV6   -  Printer device.                  - Pick list report
     *    OPFM6   -  Form.                            - Pick list report
     *
     * Data structure
     *
     D opdta4          ds
     D  oplb4                  1      1
     D  opcu4                  2      2
     D  oplp4                  3     12
     D  opdv4                 13     22
     D  opfm4                 23     32
     D  oplb5                 33     33
     D  opcu5                 34     34
     D  oplp5                 35     44
     D  opdv5                 45     54
     D  opfm5                 55     64
     D  oplb6                 65     65
     D  opcu6                 66     66
     D  oplp6                 67     76
     D  opdv6                 77     86
     D  opfm6                 87     96
     D  opend4               117    117
530bA*----------------------------------------------------------------
530bA*  *PICK  -  Picking options
530bA*
530bA*----------------------------------------------------------------
530bA*
530bA* Fields
530bA*
530bA*    OPNXTP  -  Next pallet number.
530bA*    OPBPCK  -  Bulk pick definition.
530bA*    OPPCUB  -  Maximum cube for PIR.
530bA*    OPFPAL  -  Pallets on fixed fork lift.
530bA*    OPFCUB  -  Maximum cube per fixed pallet.
530bA*    OPFSTP  -  Maximum stops per fixed pallet.
530bA*    OPINCL  -  Include PIR in fixed cube.
530bA*    OPSRCH  -  Number of previous pallets to search for space.
530bA*    OPFBLD  -  Fixed pallet building method.
530bA*                1 = By piece without concern for splitting stop.
530bA*                2 = By stop without splitting stop between plts.
530bA*    OPPBRK  -  Aisle to start new pallet.
530bA*    OPPBLD  -  Pallet building method.
530bA*                1 = By stop then slot location.
530bA*                2 = By slot location then stop.
530bA*                3 = By descening stop, then slot location.
530bA*    OPSELM  -  Selection method.
530bA*                1 = Single pass (By location).
530bA*                2 = Multiple pass (By stop).
530bA*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
530bA*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
530bA*    OPNWPL  -  Start new pallet when aisle changes if build method
530bA*               is 2=Location.
530bA*    OPFORD  -  Maximun orders per pallet.
530bA*    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
530bA*    OPFTOT  -  Maximum totes per pallet.
530bA*    OPTECB  -  External tote cube.
530bA*    OPTICB  -  Internal tote cube.
530bA*    OPTSTP  -  Maximum stops per tote.
530bA*    OPTPCS  -  Maximum pieces per tote.
530bA*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
530bA*    OPGCDE  -  USF Group Code (0-9).
530bA*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
530bA*    OPSPAL  -  Merge pallet should only contain
530bA*               items for single truck pallet (Y=Yes, N=No).
530bA*    OPPITM  -  Maximum items per pallet.
530bA*
530bA* Data structure
530bA*
530bAD opdta1          ds
530bAD  opnxtp                 1      7  0 inz(0)
530bAD  oppcub                10     14  2 inz(0)
530bAD  opfpal                15     15  0 inz(0)
530bAD  opfcub                16     20  2 inz(0)
530bAD  opincl                22     22
530bAD  opsrch                23     24  0 inz(0)
530bAD  opfstp                25     26  0 inz(0)
530bAD  opfbld                27     27  0 inz(0)
530bAD  opbpck                28     30  0 inz(0)
530bAD  oppbrk                31     33
530bAD  oppbld                34     34
530bAD  opselm                35     35
530bAD  opsplt                36     36
530bAD  opbmrg                37     37
530bAD  opnwpl                38     38
530bAD  opford                39     40  0 inz(0)
530bAD  opptyp                41     41
530bAD  opftot                42     43  0 inz(0)
530bAD  optecb                44     48  2 inz(0)
530bAD  opticb                49     53  2 inz(0)
530bAD  optstp                54     55  0 inz(0)
530bAD  optord                56     57  0 inz(0)
530bAD  optpcs                58     60  0 inz(0)
530bAD  opstop                61     61
530bA** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
530bAD**opgcde                62     62
530bAD  oppkup                62     62
530bAD  opspal                63     63
530bAD  oppitm                64     67  0 inz(0)
530bAD  opend1               117    117
     *----------------------------------------------------------------
     *  Variable sample data
     *
     D                 ds
     D  lfvdta                 1     50
     D  dsn020                 1      2  0
     D  dsn030                 1      3  0
     D  dsn050                 1      5  0
     D  dsn063                 1      6  3
     D  dsn070                 1      7  0
     D  dsn072                 1      7  2
     D  dsn100                 1     10  0
     D  dsn110                 1     11  0
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     * Work Variables
     *----------------------------------------------------------------
     D @pal#           s                   like(pspal#)
     D @qty1           s                   like(w1pick)
     D @qty2           s                   like(w1qty)
     D @var            s              3  0
650aAD batId           s             11
     D cmbwrd          s              7
     D combo           s              1
     D count           s              5  0
     D curcol          s                   like(pscol)
     D curdte          s              8  0
     D curpal          s              2  0
     D currow          s                   like(psrow)
720cAD curplid         s                   like(psplid)
     D curtim          s              6  0
     D curunl          s                   like(psunld)
PFG AD curtrn          s                   like(pstrn#)
     D first           s              1
     D first2          s              1
     D forevr          s              1
650aAD forever         s               n
650aAD haveBatId       s               n
NCH AD hldord          s                   like(lbord)
NCH AD                                     inz(-9999999)
NCH AD hldseq          s                   like(lbseq)
NCH AD                                     inz(-99999)
HARbAD hold3n          s              3s 0
HARbAD hold8a          s              8a
HARbAD hold10a         s             10a
750bAD kygen           s                   like(psgen)
     D kyltyp          s                   like(lbtype)
     D kytype          s                   like(pstype)
     D kyvnum          s                   like(lfvnum)
     D lbls            s              3  0
     D lstlb#          s                   like(lblbl#)
     D lstpid          s                   like(psplid)
     D lststp          s                   like(lbstop)
     D lsttrn          s                   like(lbtrn#)
     D lstum           s                   like(lbutyp)
     D lstwdp          s                   like(lbwhdp)
     D lstzon          s                   like(psszon)
     D maxsti          s              2  0
     D maxsto          s              3  0
     D outwrd          s              3
     D pal#            s              7  0
     D palcnt          s              2  0
     D prtflg          s              1
     D remain          s              2  0
650aAD rtnCode         s             10
650aAD rtnMessage      s            200
     D shdcnt          s              3  0
     D ssdcnt          s              3  0
     D ssocur          s              3  0
650aAD stamp           s               z
650aAD stampUC         s               z
     D stpcnt          s              2  0
     D tmpzon          s                   like(psszon)
     D today           s              8  0
     D totwrd          s              3
     d wksec           s              5a
     d wkts1           s             26a
     d wkts2           s             26a
710dAd wkusr           s             10a
710dAd wkname1         s             10a
710dAd wkname2         s             10a
710dAd wkpgm           s             10a
710dAd wkreturn        s             10a
     D w1pal#          s                   like(lbpal#)
     D w1pick          s                   like(lbqpck)
     D w1qty           s                   like(lbqpck)
     D w1qty2          s                   like(lbqpck)
     D x1              s              3  0
     D y1              s              3  0
650aAD zeroUploadDate  s              8s 0
     D zontyp          s              5
     D zpdcnt          s              3  0
     D zpocur          s              3  0
530bAD kycod1          s                   like(opzcod)
530bAD kycod3          s                   like(opzcod)
530bAD kycod4          s                   like(opzcod)
530bAD $ptmpl          s             10
720bDD*usingDD2        s               n
750 Ad tbEnhanced      s               n
750 Ad tbType          s              1

NCH A*----------------------------------------------------------------
NCH A*  Client Copy Books
NCH A*----------------------------------------------------------------
NCH A
NCH A /copy qcopysrc,orddm1_wax
HARaA /copy qcopysrc,orddm1_har
HARaA /copy qcopysrc,orddm2_har
HARaA /copy qcopysrc,ordhm1_har
JFFeA /copy qcopysrc,orddm3_rtx
750 Ad/copy qcopysrc,p.gettbtyp

650aA*----------------------------------------------------------------
650aA*  Standard SQL variables and constants
650aA*----------------------------------------------------------------
650aA
650aA /copy qcopysrc,c#stdsql

650aA*----------------------------------------------------------------
650aA*  Prototypes
650aA*----------------------------------------------------------------
650aA
650aAD GetBatId        pr                  extpgm('GETBATID')
650aA * Input
650aAD   pWhse                        3p 0 const
650aAD   pType                       10    const
650aAD   pStatus                      1    const
650aA * Output
650aAD   pBatId                      11
650aAD   pReturn                     10
650aAD   pMessage                   200

710dAd GetGloRte       pr                  extpgm('GETGLORTE')
710dAd* Input
710dAd  ggWhseA                       3    const
710dAd  ggBranch                      2    const
710dAd  ggRouteID                     5    const
710dAd  ggGroup                      10    const
710dAd  ggSubGroup                   12    const
710dAd  ggType                        1    const
710dAd* Output
710dAd  ggTotMins                     5
710dAd  ggAddTS                      26
710dAd  ggAddUCTS                    26
710dAd  ggCurrUser                   10
710dAd  ggJobUser                    10
710dAd  ggJobName                    10
710dAd  ggJobNumber                   6
710dAd  ggProgram                    10
710dAd  ggReturn                     10
ADCbAD
ADCbAD RunJDE          pr                  extpgm('PROCPICK')
ADCbAD   pWhse                        3    const

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Command
     *              *TEST1   -  Print test labels - no merge.
     *              *TEST2   -  Print test labels - merge sample data.
     *              *REPLEN  -  Print potential replenishments.
     *              *CLOSE   -  Close program with *INLR.
     *      $PWHSE  Warehouse
     *      $PRTID  Route Id
     *      $PCOMP  Compartment
     *      $PTZON  Truck zone
     *      $PGEN   Generation
     *      $PSZON  Slot zone
     *      $PTRUK  Truck
     *      $PRTE   Route
     *      OPZDTA  Picking label options
     *      $PTRN#  Transaction number for reprints
     *              Batch number for *REPL
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $pcomp            1
     C                   parm                    $ptzon            6
     C                   parm                    $pgen             1 0
     C                   parm                    $pszon            6
     C                   parm                    $ptruk           10
     C                   parm                    $prte             5
     C                   parm                    opzdta
     C                   parm                    $ptrn#            7 0
     *----------------------------------------------------------------
     *  Main line
     *
     *  See if we are only closing the program.
     *
     C                   if        $pcmd = '*CLOSE  '
     C                   goto      bottom
     C                   endif
ASC A*
ASC A*  Run Agar Lucas Export.
ASC A*
ASC AC                   if        client = agar
ASC AC***                if        $pcmd = '*CLOSE  '
ASC A*
ASC AC                   call      'RH156CL'
ASC AC                   parm                    $pwhse
ASC AC                   parm                    $prtid
ASC AC                   parm                    $prte
ASC A*
ASC AC***                endif
ASC AC                   endif
530bA*
530bA*  Get zone options.
530bA*

530bA*  PCKLBL
530bAC                   eval      opdta2 = opzdta
530bA*
530bAC                   eval      kycod1 = '*PICK   '
530bAC                   eval      opptyp = *blanks
530bAC     opzkey        chain     optionz
530bAC                   if        %found(optionz)
530bAC                   eval      opdta1 = opzdta
530bAC                   endif
530bA*
530bAC                   eval      opdta3 = *blanks
530bAC                   eval      kycod3 = '*PICKLBA'
530bAC     opzkya        chain     optionz
530bAC                   if        %found(optionz)
530bAC                   eval      opdta3 = opzdta
530bAC                   endif
530bA*
530bA* do not print standard pick labels
530bA*
530bAC                   if        oplb1 = 'N'
530bA ***                goto      bottom
530bAC                   endif
530bA*
530bAC                   eval      kycod4 = '*PICKLBB'
530bAC                   eval      opdta4 = *blanks
530bAC     opzkyb        chain     optionz
530bAC                   if        %found(optionz)
530bAC                   eval      opdta4 = opzdta
530bAC                   endif
     *
     *  Get current date and time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdte = $cvd8o
     C                   time                    curtim
     *
     * Count detail lines of summary labels.
     *
     C                   exsr      cntshd
     C                   exsr      cntssd
     C                   exsr      cntzpd
     *
     * Check to see if this is only a test.
     *
     C                   if        $pcmd = '*TEST1  '  or
     C                             $pcmd = '*TEST2  '
     C                   exsr      test1
     C                   goto      bottom
     C                   endif
     *
     * Print zone heading label.
     *
     C                   exsr      lblzhd
     *
     * Print potential replenishments
     *
     C                   if        $pcmd = '*REPLEN '
     C                   if        opletd = 'Y'
     C                   exsr      prtprp
     C                   endif
     C                   goto      bottom
     C                   endif
     *
     * Print letdowns for zone.
     *
     C                   if        opletd = 'Y'
     C                   exsr      prtrpl
     C                   endif
     *
     * Print bulk picks for zone.
     *
     C                   exsr      prtblk
     *
     * Print selection labels for zone.
     *
     *    Note: First the pallet summary records will be read
     *          and the information saved.  Then, when the
     *          transaction number changes, we go and print
     *          the labels for the previous transacton
     *          number (LSTTRN).
     *
     *    Loop through truck pallets for zone.
     *
     C                   eval      first = *on
     C                   eval      palcnt = 0
     *
720bDC**                 eval      kytype = 'O'
720bA /free
720bA   // Check for version of Drag & Drop
720bA
720bA   select;
750 D     //when usingdd2 and $pgen = 1;
750 M     when tbEnhanced and $pgen = 1;
720bA       kytype = 'P';
720bA     other;
720bA       kytype = 'O';
720bA   endsl;
720bA
720bA /end-free
PFG A*
PFG AC                   select
PFG AC                   when      client = PFG
PFG AC     keyps3        setll     pltsum3rp
PFG AC                   other
PFG A*
     C     keyps3        setll     pltsum3
PFG AC                   endsl
PFG A*
     C                   dou       forevr <> forevr
PFG A*
PFG AC                   select
PFG AC                   when      client = PFG
PFG AC     keyps3        reade     pltsum3rp                              79
PFG AC                   other
PFG A*
     C     keyps3        reade     pltsum3                                79
PFG AC                   endsl
PFG A*
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     Skip pallet if nothing was picked.
     *
     C                   if        pspcs = 0  or
530 AC                             pstrn# = 0
     C                   iter
     C                   endif
     *
     *     First time through initialization.
     *
     C                   if        first = *on
     C                   eval      lsttrn = pstrn#
     C                   eval      palcnt = 0
     C                   eval      first = *off
     C                   endif
     *
     *     If transaction number changed, go and print the detail
     *       for the previous transaction (LSTTRN).
     *
     C                   if        pstrn# <> lsttrn
PFG AC                   eval      curtrn = pstrn#
     C                   eval      curunl = psunld
     C                   eval      currow = psrow
     C                   eval      curcol = pscol
720cAC                   eval      curplid = psplid
     C                   exsr      prtsel
PFG A*
PFG AC                   select
PFG AC                   when      client = PFG
PFG AC     keyps3rp      setll     pltsum3rp
PFG AC                   read      pltsum3rp                              79
PFG AC                   other
PFG A*
     C     keyps         setll     pltsum3
     C                   read      pltsum3                                79
PFG AC                   endsl
PFG A*
     C                   eval      lsttrn = pstrn#
     C                   eval      palcnt = 0
     C                   endif
     *
     *     Add pallet info to pallet summary data structure.
     *
     C                   add       1             palcnt
     C     palcnt        occur     palsum
     C                   eval      dsppal = pspal#
     C                   z-add     pscube        dspcub
     C                   z-add     psswgt        dspwgt
     C                   z-add     pspcs         dsppcs
     C                   eval      dspstp = 0
     C                   eval      lststp = -(1)
     C                   eval      dsppli = psplid
     C     keyss1        setll     pltstp1
     C                   dow       forevr = forevr
     C     keyss1        reade     pltstp1                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        pssstp <> lststp
     C                   add       1             dspstp
     C                   eval      lststp = pssstp
     C                   endif
     C                   enddo
     *
     C                   enddo
     *
     *   Print last pallet(s), if any.
     *
     C                   if        palcnt > 0
     C                   exsr      prtsel
     C                   endif
     *
     *
     *   Bye, Bye.
     *
     C     bottom        tag
     *
650aAC                   if        haveBatId
720 A*
720 AC                   call      'PFILES2'
720 AC                   parm      '*UPDATE '    $pcmd2            8
720 AC                   parm      $pwhse        $pwhse2           3 0
720 AC                   parm      batid         $pbatid2         11
720 A*
720bDC*                  exsr      zzzEnd
710bAC                   eval      opbatid = batid
720fAC                   eval      opzdta = opdta2
650aAC                   endif
     *
     C                   if        $pcmd = '*CLOSE  '
     C                   eval      *inlr = *on
     C                   else
     C                   return
     C                   endif
     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
530aA*
530aA* Get client id.
530aA*
530aAC                   call      @getcl
530aAC                   parm                    client           10
530aAC                   parm                    cliloc           10
530aA*
     C                   eval      forevr = *off
     C                   eval      maxsti = 75
     C                   eval      maxsto = 198
NCH A*
NCH AC                   if        client = Nicholas
ADCaAC                             or client = adc
HARaAC                             or client = Harbor
JFFeAC                             or client = Jakes
NCH AC                   if        not %open(orddm)
NCH AC                   open      orddm
NCH AC                   endif
NCH AC                   endif
HARaA*
HARaAC                   if        client = Harbor
HARaAC                   if        not %open(ordhm)
HARaAC                   open      ordhm
HARaAC                   endif
HARaAC                   endif
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
NCH A*
NCH A*  Define full key for ORDDM file.
NCH AC     keyom         klist
NCH AC                   kfld                    lbwhse
NCH AC                   kfld                    lbord
NCH AC                   kfld                    lbseq
NCH AC                   kfld                    lbitem
HARaA*
HARaA*  Define full key for ORDHM file.
HARaAC     keyhm         klist
HARaAC                   kfld                    lbwhse
HARaAC                   kfld                    lbord
     *
     *  Define partial key for PLTSUM3 file.
     *
     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     C                   kfld                    $pcomp
     C                   kfld                    $ptzon
     C                   kfld                    $pgen
     C                   kfld                    $pszon
     *
     C     keyps         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     C                   kfld                    $pcomp
     C                   kfld                    $ptzon
     C                   kfld                    $pgen
     C                   kfld                    $pszon
     C                   kfld                    curunl
     C                   kfld                    currow
     C                   kfld                    curcol
720cAc                   kfld                    curplid
750bAC     keyps3b       klist
750bAC                   kfld                    $pwhse
750bAC                   kfld                    $prtid
750bAC                   kfld                    kytype
750bAC                   kfld                    $pcomp
750bAC                   kfld                    $ptzon
750bAC                   kfld                    kygen
750bAC                   kfld                    $pszon
PFG A*
PFG AC     keyps3rp      klist
PFG AC                   kfld                    $pwhse
PFG AC                   kfld                    $prtid
PFG AC                   kfld                    kytype
PFG AC                   kfld                    $pcomp
PFG AC                   kfld                    $ptzon
PFG AC                   kfld                    $pgen
PFG AC                   kfld                    $pszon
PFG AC                   kfld                    curtrn
PFG AC                   kfld                    curunl
PFG AC                   kfld                    currow
PFG AC                   kfld                    curcol
PFG A*
     *
     *  Define partial key for PLTSTP1 file.
     *
     C     keyss1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    psplid
     C                   kfld                    psrow
     C                   kfld                    pscol
     *
     *  Define partial key for LABEL31 file.
     *
     C     keyl31        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kyltyp
     C                   kfld                    psplid
     *
     *  Define partial key for LABEL32 & LABEL34 file.
     *
     C     keyl32        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kyltyp
     C                   kfld                    lsttrn
     *
     *  Define partial key for LABEL33 file.
     *
     C     keyl33        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lsttrn
     *
     *  Define partial key for LABEL3 file.
     *
     C     keyl3f        klist
     C                   kfld                    $ptrn#
     C                   kfld                    $pwhse
     *
     *  Define key for LBLFMTV file.
     *
     C     keylfv        klist
     C                   kfld                    kyvnum
530bA*
530bA*  Define key for pick options.
530bA*
530bAC     opzkey        klist
530bAC                   kfld                    kycod1
530bAC                   kfld                    $pwhse
530bD ***                kfld                    $ptruk
530bMC                   kfld                    $ptmpl
530bAC                   kfld                    $pszon
530bA*
530bAC     opzkya        klist
530bAC                   kfld                    kycod3
530bAC                   kfld                    $pwhse
530bD ***                kfld                    $ptruk
530bMC                   kfld                    $ptmpl
530bAC                   kfld                    $pszon
     *
530bAC     opzkyb        klist
530bAC                   kfld                    kycod4
530bAC                   kfld                    $pwhse
530bD ***                kfld                    $ptruk
530bMC                   kfld                    $ptmpl
530bAC                   kfld                    $pszon
530bA*
530bA*  Define key for TRUCKH file.
530bA*
530bAC     trkey         klist
530bAC                   kfld                    $pwhse
530bAC                   kfld                    $ptruk
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *   Define variables.
     *
     *
     *  Get system options.
     *
     C                   eval      opwhse = 0
     C                   eval      opcode = '*SYSTEM '
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opletd = 'Y'
     C                   endif
     *
     *   Initialize sequence number for transaction.
     *
     C                   eval      lbeseq = 0
530bA*
530bA* Get Zone Template Code if Template type is T=Truck
530bA*
530bAC     trkey         chain     truckh
530bAC                   if        %found(truckh) and thtype = 'T'
530bAC                   eval      $ptmpl =  thztmp
530bAC                   else
530bAC                   eval      $ptmpl =  $ptruk
530bAC                   endif
     *
650aAC                   if        not haveBatId
650aAC                   exsr      zzzGetBatId
650aAC                   eval      haveBatId = *on
650aAC                   endif
750 D*
750 D* Get DD2 option
750 D*
750 DC*    *DTAARA       define    dragdrop2     usingDD2
750 DC*                  in(e)     usingDD2
750 DC*                  if        %error
750 DC*                  eval      usingDD2 = *off
750 DC*                  endif
750 Ac*
750 Ac*   Determine if using TruckBUilder Enhanced
750 Ac*
750 A /free
750 A      GetTBType($pwhse: $prtid: tbType);
750 A      if tbType = 'E';
750 A        tbEnhanced = *on;
750 A      else;
750 A        tbEnhanced = *off;
750 A      endif;
750 A /end-free
730aA**
730aA**  Get Slot Sequence with new Option and possible soft coding
730aA**
730aAc                   eval      gpscmd = '*ISSOFT'
     c                   monitor
730aAc                   call      'GETPSEQO'
730aAc                   parm                    gpscmd            8
730aAc                   parm                    $pwhse
730aAc                   parm      ' '           gpswhdp           5
730aAc                   parm      ' '           gpsdisp          12
730aAc                   parm      ' '           gpsSeqcd          1
730aAc                   parm      0             gpsSeq            5 0
730aAc                   parm      ' '           usrDFPICK         1
730aAc                   on-error
730aAc                   eval      usrDFPICK = 'N'
730aAc                   endmon
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CRTSTP  Create stop numbers.
     *
     C     crtstp        begsr
720dAC*
720dAC*    Get Stop From RTESTP
720dAC*
720dAC                   eval      $sOrd  = lbord
720dAC                   eval      $sDstp = 0
720dAC*
720dAC                   CALL      'GETSTOP'
720dAC                   PARM      '*ORDSTP '    $scmd             8
720dAC                   PARM      $PWHSE        $swhse            3 0
720dAC                   PARM      lbrte         $srtid            5
720dAC                   PARM                    $sord             7 0
720dAC                   PARM                    $sdstp            2 0
720dAC                   PARM      0             $sstp             5 0
720dAc                   parm                    $pDdrop           3
720dAc                   parm                    $pDextd          30
720dAc                   parm                    $pDsd             9
720dAC*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETPAL  Get pallet number.
     *
     C     getpal        begsr
     C                   eval      pal# = 0
     C     1             do        palcnt        curpal
     C     curpal        occur     palsum
     C                   if        dsppli = lbpal#
     C                   eval      pal# = dsppal
     C                   endif
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INITSS  Initialize data structure for stop summary
     *
     C     initss        begsr
     C     1             do        ssdcnt        ssocur
     C     ssocur        occur     stpsum
     C                   eval      dssstp = 0
     C                   eval      dsspcs = 0
     C                   eval      dsscub = 0
     C                   eval      dsswgt = 0
     C                   eval      dsscnm = *blanks
     C                   enddo
     C                   eval      ssocur = 1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INITZP  Initialize data structure for zone pickup
     *
     C     initzp        begsr
     C     1             do        zpdcnt        zpocur
     C     zpocur        occur     zonpku
     C                   eval      dszstp = 0
     C                   eval      dszpcs = 0
     C                   eval      dszitm = *blanks
     C                   eval      dszdsc = *blanks
     C                   eval      dszplt = 0
     C                   enddo
     C                   eval      zpocur = 1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRINT   Output string to printer.
     *
     C     print         begsr
     *
650aAC                   exsr      zzzGetStamps
650aAC                   eval      lbebatid = batId
650aAC                   eval      lbestatus = 'R'
650aAC                   eval      lbeststs = stamp
650aAC                   eval      lbestsuc = stampuc
JFFfA*
JFFfAC                   select
JFFfAC                   when      client = Jakes
JFFfAC                   if        lbtype = 'B'
JFFfA*      Load pallet id from Merge label rcd.
JFFfAC                   eval      lbeplid = L11Lbpal#
JFFfAC                   else
JFFfAC                   eval      lbeplid = lbpal#
JFFfAC                   endif
JFFfAC
JFFfAC                   other
JFFfA*
650aAC                   eval      lbeplid = lbpal#
JFFfAC                   endsl
     *
     C                   eval      prtflg = *off
     C                   write     lberec
710eA*
710eAc                   eval      lbeorda = *blanks
710eAc                   eval      lbedsqa = *blanks
710eAc                   eval      lbecusa = *blanks
710eA*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTBLK  Print bulk pick labels for route/department.
     *
     C     prtblk        begsr
     C                   eval      tmpzon = *blanks
     *
     C                   eval      first = *on
     *
     *  Loop bulk picks for zone.
     *
     *    Revised to only use a pallet id once.
     *
     C                   eval      lstpid = -(1)
     C                   eval      kytype = 'B'
750bAC                   if        tbEnhanced
750bAC                   eval      kygen = 7
750bAC                   else
750bAC                   eval      kygen = $pgen
750bAC                   endif
750bDC*    keyps3        setll     pltsum3
750bMC     keyps3b       setll     pltsum3
     C                   dou       forevr <> forevr
750bDC*    keyps3        reade     pltsum3                                79
750bMC     keyps3b       reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        psplid = lstpid  or
530 AC                             pstrn# = 0
     C                   iter
     C                   endif
     C                   eval      lstpid = psplid
     *
     *    Loop through bulk pick labels for pallet.
     *      Note: There should only be one label, but this keeps
     *            the coding consistant with replenishments.
     *
     *      The above statment is false. There can be more than
     *      one bulk pick to a pallet especially if an item didn't
     *      have home slot.
     *
     *      The 413 fix was necessary because the LABEL31 file
     *      is joined to the PLTSUM file only using the pallet
     *      id. When there are multiple bulk picks on a pallet
     *      the LABEL31 ends up with duplicate records. These
     *      dups are created in sequence so we can check the
     *      label number against the last one and skip the
     *      record if they are the same.
     *
     C                   eval      lstlb# = -(1)
NCH A*
NCH AC                   if        client = Nicholas
JFFeAC                             or client = Jakes
NCH AC                   eval      hldord = -(1)
NCH AC                   eval      hldseq = -(1)
NCH AC                   endif
NCH A*
     C                   eval      kyltyp = 'B'
     C     keyl31        setll     label31
     *
     C                   dou       forevr <> forevr
     *
     C     keyl31        reade     label31                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        lblbl# = lstlb#
     C                   iter
     C                   endif
     C                   eval      lstlb# = lblbl#
     *
     *       Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
JFFfA*
JFFfAC                   if        client = Jakes
JFFfAC     lblbl#        setll     label11
JFFfAC     lblbl#        reade     label11
JFFfAC                   if        %eof(label11)
JFFfAC                   eval      L11Lbdsp2 = ' '
JFFfAC                   eval      L11Lbpal# = lbpal#
JFFfAC                   endif
JFFfAC                   endif
NCH A*
NCH AC                   if        client = Nicholas
ADCaAC                             or client = adc
JFFeAC                             or client = jakes
NCH A*
NCH A*      Retrieve Order Detail Misc. record.
NCH AC                   if           lbord <> hldord
NCH AC                             or lbseq <> hldseq
NCH AC                   exsr      zzgetom
JFFeAC                   eval      hldord = lbord
JFFeAC                   eval      hldseq = lbseq
NCH AC                   endif
NCH A*
NCH AC                   endif
HARaA*
HARaAC                   if        client = Harbor
HARaA*
HARaA*      Retrieve Order Header Misc. record.
HARaAC                   exsr      zzgethm
HARaA*
HARaA*      Retrieve Order Detail Misc. record.
HARaAC                   exsr      zzgetom
HARaA*
HARaAC                   endif
     *
     *       Print beginning bulk pick label.
     *
     C                   if        first = *on
     ***                  WRITEBEGBULK
     C                   exsr      lblbbk
     C                   eval      first = *off
     C                   endif
     *
     *       Print warning for bulk/replenishment combo.
     *
     *
     *       Print bulk label.
     *
     C                   eval      w1qty = lbqpck
     C                   exsr      crtstp
     ***                  WRITESETHEAD
     ***                  WRITEBULK
     *****                EXSR LBLSHD
     *****                EXSR ZZFILL
     *****                EXSR PRINT
     C                   exsr      lblblk
     *
     *       Print replenishment label if necessary.
     *
     C                   if        lbdsp2 <> *blanks
     C                   eval      w1qty = lbqrmn
     ***                  WRITETRANSFER
     C                   exsr      lblrp1
     C                   endif
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTPRP  Print potential replenishment labels.
     *
     C     prtprp        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTRPL  Print replenishment labels for zone
     *
     C     prtrpl        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTSEL  Print normal selection labels for zone.
     *
     C     prtsel        begsr
     C                   eval      tmpzon = *blanks
     *
     *   Print header for this set of selection labels.
     *
     C                   exsr      setbeg
     *
     *   Loop through selection labels for transaction.
     *
     C                   eval      count = 0
     C                   eval      kyltyp = 'O'
710fAC                   eval      lstlb# = -(1)
NCH A*
NCH AC                   if        client = Nicholas
JFFeAC                             or client = Jakes
NCH AC                   eval      hldord = -(1)
NCH AC                   eval      hldseq = -(1)
NCH AC                   endif
NCH A*
     C                   if        $pgen = 1
     *R         KEYL32    SETLLLABEL34
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
730aAc                             or usrDFPICK='Y'
FRF AC     keyl32        setll     label32d
FRF AC                   other
     C     keyl32        setll     label32
FRF AC                   endsl
FRF A*
     C                   else
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
730aAc                             or usrDFPICK='Y'
FRF AC     keyl32        setll     label32d
FRF AC                   other
     C     keyl32        setll     label32
FRF AC                   endsl
FRF A*
     C                   endif
     *
     C                   dou       forevr <> forevr
     C                   if        $pgen = 1
     *R         KEYL32    READELABEL34                  78
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
730aAc                             or usrDFPICK='Y'
FRF AC     keyl32        reade     label32d                               78
FRF AC                   other
     C     keyl32        reade     label32                                78
FRF AC                   endsl
FRF A*
     C                   else
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
730aAc                             or usrDFPICK='Y'
FRF AC     keyl32        reade     label32d                               78
FRF AC                   other
     C     keyl32        reade     label32                                78
FRF AC                   endsl
FRF A*
     C                   endif
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *     Skip label if same as last label.
     *
710fAC                   if        lblbl# = lstlb#
710fAC                   iter
710fAC                   endif
710fAC                   eval      lstlb# = lblbl#
     *
     *     Skip label if cross dock.
     *
     C                   if        lbstyp = 'X'
     C                   iter
     C                   endif
     *
     *     Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
     *
NCH AC                   if        client = Nicholas
ADCaAC                             or client = adc
JFFeAC                             or client = Jakes
NCH A*
NCH A*      Retrieve Order Detail Misc. record.
NCH AC                   if           lbord <> hldord
NCH AC                             or lbseq <> hldseq
NCH AC                   exsr      zzgetom
JFFeAC                   eval      hldord = lbord
JFFeAC                   eval      hldseq = lbseq
NCH AC                   endif
NCH A*
NCH AC                   endif
NCH A*
HARaAC                   if        client = Harbor
HARaA*
HARaA*      Retrieve Order Header Misc. record.
HARaAC                   exsr      zzgethm
HARaA*
HARaA*      Retrieve Order Detail Misc. record.
HARaAC                   exsr      zzgetom
HARaA*
HARaAC                   endif
HARaA*
     *
     C                   add       1             count
     *
     *     See if we should print the "before" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwrb = 'Y'
     ***                  WRITEWARNUMB
     C                   exsr      lblumb
     C                   endif
     *
     *     Initialize label fields.
     *
     C                   eval      w1qty2 = lbqpck
     C                   exsr      crtstp
     *
     *     Force combo label for writing to file
     *
     C                   eval      opclvl = 0
     *
     *     Either print a combination label ...
     *
     C                   select
     C                   when      lbqpck >= opclvl
     C                   eval      combo = *on
     *
     *        See if we should print the "before" combo warning.
     *
     C                   if        opcwrb = 'Y'
     ***                  WRITEWARNCMBB
     C                   exsr      lblcmb
     C                   endif
     *
     *        Print one label.
     *
     C                   eval      w1pick = lbqpck
     ***                  WRITEPICK
     C                   exsr      lblpck
     *
     *        See if we should print the "after" combo warning.
     *
     C                   if        opcwra = 'Y'
     ***                  WRITEWARNCMBA
     C                   exsr      lblcma
     C                   endif
     *
     C                   other
     *
     *     Or print individual labels.
     *
     C                   eval      combo = *off
     C     1             do        lbqpck        w1pick
     ***                  WRITEPICK
     C                   exsr      lblpck
     C                   enddo
     *
     C                   endsl
     *
     *     See if we should print the "after" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwra = 'Y'
     ***                  WRITEWARNUMA
     C                   exsr      lbluma
     C                   endif
     *
     *     Print catch weight labels.
     *
     C                   if        itcwgt = 'Y'  and
     C                             opcwgt <> 0
     C     lbqpck        div       opcwgt        lbls
     C                   mvr                     remain
     C                   if        remain <> 0
     C                   add       1             lbls
     C                   endif
     C     1             do        lbls
     ***                  WRITECATCHWGT
     C                   exsr      lblcwt
     C                   enddo
     C                   endif
     *
     C                   enddo
     *
     *   Print summary for this set of selection labels.
     *
     C                   exsr      setend
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTXDK  Print cross dock labels.
     *
     C     prtxdk        begsr
     C                   eval      tmpzon = 'XDOCK '
     *
     *
     *   Loop through selection labels for transaction.
     *
     C                   eval      count = 0
     C                   eval      kyltyp = 'O'
750aAC                   eval      lstlb# = -(1)
     *
     C                   if        $pgen = 1
     *R         KEYL32    SETLLLABEL34
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
730aAc                             or usrDFPICK='Y'
FRF AC     keyl32        setll     label32d
FRF AC                   other
     C     keyl32        setll     label32
FRF AC                   endsl
FRF A*
     C                   else
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
730aAc                             or usrDFPICK='Y'
FRF AC     keyl32        setll     label32d
FRF AC                   other
     C     keyl32        setll     label32
FRF AC                   endsl
FRF A*
     C                   endif
     *
     C                   dou       forevr <> forevr
     C                   if        $pgen = 1
     *R         KEYL32    READELABEL34                  78
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
730aAc                             or usrDFPICK='Y'
FRF AC     keyl32        reade     label32d                               78
FRF AC                   other
     C     keyl32        reade     label32                                78
FRF AC                   endsl
FRF A*
     C                   else
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
730aAc                             or usrDFPICK='Y'
FRF AC     keyl32        reade     label32d                               78
FRF AC                   other
     C     keyl32        reade     label32                                78
FRF AC                   endsl
FRF A*
     C                   endif
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *
     *     Skip label if not cross dock.
     *
     C                   if        lbstyp <> 'X'
     C                   iter
     C                   endif
750aA*
750aA*     There could be more than one PLTSUM rec for the same pallet,
750aA*     but with a different pstrn#, causing LABEL rec to be read
750aA*     twice in the joined logical LABEL32, so make sure the lblbl#
750aA*     is not equal to the lstlb# before printing.
750aA*
750aAC                   if        lblbl# = lstlb#
750aAC                   iter
750aAC                   endif
750aAC                   eval      lstlb# = lblbl#
     *
     *     Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
     *
     C                   add       1             count
     *
     *   Print warning "Cross dock labels next".
     *
     C                   if        count = 1
     C                   exsr      lblxdb
     C                   endif
     *
     *     See if we should print the "before" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwrb = 'Y'
     C                   exsr      lblumb
     C                   endif
     *
     *     Initialize label fields.
     *
     C                   eval      w1qty2 = lbqpck
     C                   exsr      crtstp
     *
     *     Force combo label for writing to file
     *
     C                   eval      opclvl = 0
     *
     *     Either print a combination label ...
     *
     C                   select
     C                   when      lbqpck >= opclvl
     C                   eval      combo = *on
     *
     *        See if we should print the "before" combo warning.
     *
     C                   if        opcwrb = 'Y'
     C                   exsr      lblcmb
     C                   endif
     *
     *        Print one label.
     *
     C                   eval      w1pick = lbqpck
     C                   exsr      lblpck
     *
     *        See if we should print the "after" combo warning.
     *
     C                   if        opcwra = 'Y'
     C                   exsr      lblcma
     C                   endif
     *
     C                   other
     *
     *     Or print individual labels.
     *
     C                   eval      combo = *off
     C     1             do        lbqpck        w1pick
     C                   exsr      lblpck
     C                   enddo
     *
     C                   endsl
     *
     *     See if we should print the "after" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwra = 'Y'
     C                   exsr      lbluma
     C                   endif
     *
     *     Print catch weight labels.
     *
     C                   if        itcwgt = 'Y'  and
     C                             opcwgt <> 0
     C     lbqpck        div       opcwgt        lbls
     C                   mvr                     remain
     C                   if        remain <> 0
     C                   add       1             lbls
     C                   endif
     C     1             do        lbls
     C                   exsr      lblcwt
     C                   enddo
     C                   endif
     *
     C                   enddo
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SETBEG  Start new set of labels.
     *
     C     setbeg        begsr
     *
     *   Print set header label.
     *
     C                   eval      lbtrn# = lsttrn
     C                   exsr      lblshd
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SETEND  End set of labels.
     *
     C     setend        begsr
     *
     *   Print cross dock labels.
     *
     C                   exsr      prtxdk
     *
     *   Print discrepancy labels.
     *
     *     *** Not when writing to file ***
     *
     *
     *   Print merge summary(s) for transaction.
     *
     *     Loop through selection labels for transaction.
     *
     C                   eval      first2 = *on
     C                   eval      kyltyp = 'M'
JFFgA*
JFFgAC                   if        client = Jakes
JFFgAC                   eval      hldord = -(1)
JFFgAC                   eval      hldseq = -(1)
JFFgAC                   endif
     *
     C                   if        $pgen = 1
     **         KEYL32    SETLLLABEL34
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
730aAc                             or usrDFPICK='Y'
FRF AC     keyl32        setll     label32d
FRF AC                   other
     C     keyl32        setll     label32
FRF AC                   endsl
FRF A*
     C                   else
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
730aAc                             or usrDFPICK='Y'
FRF AC     keyl32        setll     label32d
FRF AC                   other
     C     keyl32        setll     label32
FRF AC                   endsl
FRF A*
     C                   endif
     *
     C                   dou       forevr <> forevr
     C                   if        $pgen = 1
     **         KEYL32    READELABEL34                  78
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
730aAc                             or usrDFPICK='Y'
FRF AC     keyl32        reade     label32d                               78
FRF AC                   other
     C     keyl32        reade     label32                                78
FRF AC                   endsl
FRF A*
     C                   else
FRF A*
FRF AC                   select
FRF AC                   when      client = FRF
730aAc                             or usrDFPICK='Y'
FRF AC     keyl32        reade     label32d                               78
FRF AC                   other
     C     keyl32        reade     label32                                78
FRF AC                   endsl
FRF A*
     C                   endif
     C                   if        *in78
     C                   leave
     C                   endif
JFFgA*
JFFgA*      Retrieve Order Detail Misc. record.
JFFgAC                   if        client = Jakes
JFFgA*
JFFgAC                   if           lbord <> hldord
JFFgAC                             or lbseq <> hldseq
JFFgAC                   exsr      zzgetom
JFFgAC                   eval      hldord = lbord
JFFgAC                   eval      hldseq = lbseq
JFFgAC                   endif
JFFgA*
JFFgAC                   endif
     *
     *       Put together zone from label fields.
     *
     C                   movel     lbwhdp        tmpzon
     C                   move      lbstyp        tmpzon
     *
     C                   exsr      lblzpd
     *
     C                   enddo
     *
     *   Print set summary for transaction.
     *
     *     *** Nothing to do when writing to file ***
     *
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *                       LABEL SUBROUTINES
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  CNTSHD  Count set header detail lines.
     *
     C     cntshd        begsr
     *
     C                   eval      shdcnt = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CNTSSD  Count set summary detail lines.
     *
     C     cntssd        begsr
     *
     C                   eval      ssdcnt = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CNTZPD  Count set zone pickup detail lines.
     *
     C     cntzpd        begsr
     *
     C                   eval      zpdcnt = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILCHR  Fill character variable.
     *
     C     filchr        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLB1  Process script for single label format.
     *
     C     fillb1        begsr
     *
     *   Standard variables
     *
     C                   eval      @var = 0
     C                   exsr      fillb2
     *
     C                   eval      @var = 2
     C                   exsr      fillb2
     *
     C                   eval      @var = 3
     C                   exsr      fillb2
     *
     C                   eval      @var = 10
     C                   exsr      fillb2
     *
     C                   eval      @var = 11
     C                   exsr      fillb2
     *
     C                   eval      @var = 12
     C                   exsr      fillb2
     *
     C                   eval      @var = 13
     C                   exsr      fillb2
     *
     C                   eval      @var = 15
     C                   exsr      fillb2
     *
     C                   eval      @var = 16
     C                   exsr      fillb2
     *
     C                   eval      @var = 17
     C                   exsr      fillb2
     *
     C                   eval      @var = 18
     C                   exsr      fillb2
     *
     C                   eval      @var = 19
     C                   exsr      fillb2
     *
     C                   eval      @var = 26
     C                   exsr      fillb2
     *
     C                   eval      @var = 35
     C                   exsr      fillb2
     *
     C                   eval      @var = 43
     C                   exsr      fillb2
     *
     C                   eval      @var = 44
     C                   exsr      fillb2
     *
     C                   eval      @var = 45
     C                   exsr      fillb2
     *
     C                   eval      @var = 57
     C                   exsr      fillb2
     *
     *   Non-Standard variables
     *
     C                   eval      @var = 999
     C                   exsr      fillb2
     *
     *   Write record
     *
     C                   add       1             lbeseq
     C                   eval      lbedte = curdte
     C                   eval      lbetim = curtim
     C                   exsr      print
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLB2  Added variable to ouput string.
     *
     C     fillb2        begsr
     *
     C                   if        $pcmd = '*TEST2  '
     C                   eval      kyvnum = @var
     C     keylfv        chain     lblfmtv                            78
     C     *in78         cabeq     *on           endfi2
     C                   endif
     *
     C                   select
     C                   when      @var = 0
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbestp
     C                   else
720dA*
720dA*      Load extended stop number if found, else use internal.
720dAC                   if        $sstp > 0
720dAC                   eval      lbestp = $sstp
720dAC                   else
720dA*
     C                   eval      lbestp = lbstop
720dAC                   endif
720dA*
     C                   endif
     *
     C                   when      @var = 1
     *
     C                   when      @var = 2
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbewhs
     C                   else
     C                   eval      lbewhs = $pwhse
     C                   endif
     *
     C                   when      @var = 3
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbecom
     C                   else
     C                   eval      lbecom = $pcomp
     C                   endif
     *
     C                   when      @var = 4
     *
     C                   when      @var = 5
     *
     C                   when      @var = 6
     *
     C                   when      @var = 7
     *
     C                   when      @var = 8
     *
     C                   when      @var = 9
     *
     C                   when      @var = 10
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbetr#
     C                   else
     C                   eval      lbetr# = lbtrn#
     C                   endif
     *
     C                   when      @var = 11
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeslt
     C                   else
JFF A*
JFF AC                   select
JFF AC                   when      client = Jakes
JFF AC                   select
JFF A*      Remove - from 3-char aisle.
JFF AC                   when      %subst(lbaisl:1:1) > ' '
JFF AC                   eval      lbeslt = %subst(lbdisp:1:3)
JFF AC                                    + %subst(lbdisp:5:8)
JFF A*      Remove - from 2-char aisle.
JFF AC                   when      %subst(lbaisl:2:1) > ' '
JFF AC                   eval      lbeslt = %subst(lbdisp:1:2)
JFF AC                                    + %subst(lbdisp:4:9)
JFF AC                   other
JFF AC                   eval      lbeslt = %subst(lbdisp:1:1)
JFF AC                                    + %subst(lbdisp:3:10)
JFF AC                   endsl
JFF AC                   other
JFF A*
     C                   eval      lbeslt = lbdisp
JFF AC                   endsl
JFF A*
     C                   endif
     *
     C                   when      @var = 12
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeqty
     C                   else
     C                   eval      lbeqty = @qty2
     C                   endif
     *
     C                   when      @var = 13
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeucd
     C                   else
     C                   eval      lbeucd = lbucod
     C                   endif
     *
     C                   when      @var = 14
     *
     C                   when      @var = 15
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbepak
     C                   else
     C                   eval      lbepak = itpdsc
DRY AC                   if        client = dairyland
DRY AC                   eval      %subst(lbepak:10:2) = itum1
DRY AC                   eval      %subst(lbepak:12:2) = itum2
DRY AC                   eval      %subst(lbepak:14:2) = itum3
DRY AC                   endif
     C                   endif
     *
     C                   when      @var = 16
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbedsc
     C                   else
     C                   eval      lbedsc = itdesc
     C                   endif
     *
     C                   when      @var = 17
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeitm
     C                   else
     C                   eval      lbeitm = lbitem
     C                   endif
     *
     C                   when      @var = 18
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeord
     C                   else
     C                   eval      lbeord = ohcord
     C                   endif
     *
     C                   when      @var = 19
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbecus
     C                   else
     C                   eval      lbecus = ohcust
     C                   endif
     *
     C                   when      @var = 20
     *
     C                   when      @var = 21
     *
     C                   when      @var = 22
     *
     C                   when      @var = 23
     *
     C                   when      @var = 24
     *
     C                   when      @var = 25
     *
     C                   when      @var = 26
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbepl#
     C                   else
     C                   eval      lbepl# = @pal#
     C                   endif
     *
     C                   when      @var = 27
     *
     C                   when      @var = 28
     *
     C                   when      @var = 29
     *
     C                   when      @var = 30
     *
     C                   when      @var = 31
     *
     C                   when      @var = 32
     *
     C                   when      @var = 33
     *
     C                   when      @var = 34
     *
     C                   when      @var = 35
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbezon
     C                   else
     C                   eval      lbezon = $pszon
     C                   endif
     *
     C                   when      @var = 36
     *
     C                   when      @var = 37
     *
     C                   when      @var = 38
     *
     C                   when      @var = 39
     *
     C                   when      @var = 40
     *
     C                   when      @var = 41
     *
     C                   when      @var = 42
     *
     C                   when      @var = 43
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lberte
     C                   else
     C                   eval      lberte = $prte
     C                   endif
     *
     C                   when      @var = 44
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeztp
     C                   else
     C                   eval      lbeztp = zontyp
     C                   endif
     *
     C                   when      @var = 45
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbeout
     C                   else
     C                   eval      lbeout = outwrd
     C                   endif
     *
     C                   when      @var = 46
     *
     C                   when      @var = 47
     *
     C                   when      @var = 48
     *
     C                   when      @var = 49
     *
     C                   when      @var = 50
     *
     C                   when      @var = 51
     *
     C                   when      @var = 52
     *
     C                   when      @var = 53
     *
     C                   when      @var = 54
     *
     C                   when      @var = 55
     *
     C                   when      @var = 56
     *
     C                   when      @var = 57
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        lbelb#
     C                   else
     C                   eval      lbelb# = lblbl#
     C                   endif
     *
     C                   when      @var = 58
     *
     C                   when      @var = 82
     *
     C                   when      @var = 999
     C                   if        $pcmd = '*TEST2  '
     C                   eval      lbemzn = 'MERGE '
     C                   eval      lbedsq = 1
     C                   eval      lbeitp = 'X'
     C                   eval      lberid = '12345'
     C                   eval      lbetyp = 'O'
     C                   eval      lbewhd = 'DEPT '
     C                   eval      lbeutp = 'N'
     C                   eval      lbecub = 12.3
     C                   eval      lbewgt = 5.67
414aAC                   eval      lbecwf = 'N'
     C                   else
     C                   eval      lbemzn = tmpzon
JFFaA*
JFFaAC                   select
JFFaAC                   when      client = Jakes
JFFaAC                   eval      lbedsq = odor2
JFFaAC                   other
JFFaA*
     C                   z-add     lbseq         lbedsq
JFFaAC                   endsl
JFFaA*
     C                   eval      lbeitp = ittype
     C                   eval      lberid = lbrte
     C                   eval      lbetyp = lbtype
     C                   eval      lbewhd = lbwhdp
     C                   eval      lbeutp = lbutyp
     C                   eval      lbecub = lbcube
     C                   eval      lbewgt = lbswgt
41488C                   eval      lbecwf = itcwgt
710dA /free
710dA   GetGloRte(%editc(lbewhs:'X'): '  ': lberid: 'INUSE': '*CLEARDD':
710dA             '1': wksec: wkts1: wkts2: lbeempid: wkusr:
710dA             wkname1: wkname2: wkpgm: wkreturn);
710dA   exec sql select usemp#, usfnam, usinit, uslnam
710dA              into :lbeempno, :lbefname, :lbeminit, :lbelname
710dA              from piruser
710dA             where uscode = :lbeempid;
710eA
710eA   exec sql select hmmsc1 into :lbeorda from ordhm
710eA             where hmwhse = :lbwhse
710eA               and hmord  = :lbord;
710eA
JFFaA   select;
JFFaA   when      client = Jakes;
JFFaA     eval lbedsqa = %editc(odor2 : 'X');
JFFfA     if lbtype = 'B';
JFFfA       eval lbems1  = %subst(L11Lbdsp2 : 1 : 1);
JFFfA     else;
JFFcA     eval lbems1  = %subst(lbdsp2 : 1 : 1);
JFFfA     endif;
JFFjA     eval lbems1  = %replace(%editc(rtxdm3_omslbl:'X'):lbems1:2:3);
JFFaA   other;
720aA
710eA   exec sql select ommsc2 into :lbedsqa from orddm
710eA             where omwhse = :lbwhse
710eA               and omord  = :lbord
710eA               and omseq  = :lbseq;
JFFaA   endsl;
JFFaA
710dA /end-free
NCH A*
NCH AC                   if        client = Nicholas
NCH AC                   eval      lbems1 = %replace(waxdm1_wxrecid:lbems1:1:21)
NCH AC                   endif
NCH A*
ADCaAC                   if        client = adc
ADCaAC                   eval      lbems1 = %subst(ommsc1:1:8)
ADCcAC                   eval      lbems2 = %editc(odor2 : 'X')
ADCaAC                   endif
ADCaA*
HARbA /free
HARbA   if client = Harbor;
HARbA     // Get dock door
HARbA     exec sql select DMDOOR into :hold3n
HARbA                from DOCMTRX
HARbA               where dmwhse = :pswhse
HARbA                 and dmrtid = :psrtid;
HARbA     if sqlstt <> sqlsuccess;
HARbA       hold3n = 0;
HARbA     endif;
HARbA     // Get trailer
HARbA     exec sql select RTTCODE into :hold8a
HARbA                from RTETRAILER
HARbA               where rttwhse = :pswhse
HARbA                 and rttrtid = :psrtid;
HARbA     if sqlstt <> sqlsuccess;
HARbA       hold8a = *blanks;
HARbA     endif;
HARbA     // Load Dock Door and Trailer in Misc 1.
HARcD     //lbems1 = %editc(hold3n:'X') + ' ' + hold8a;
HARcM     lbems1 = %editc(hold3n:'X') + ' ' + hold8a + $ptmpl;
HARbA
HARbA     // Get driver
HARbA     exec sql select TTRUSR into :hold10a
HARbA                from TTRTE
HARbA               where ttrwhs = :pswhse
HARbA                 and ttrrti = :psrtid;
HARbA     if sqlstt <> sqlsuccess;
HARbA       hold10a = *blanks;
HARbA     endif;
HARbA     // Load Delivery Date/Time and Driver in Misc 2.
HARbA     lbems2 = %subst(hmmsc4:1:12) + ' ' + hold10a;
HARbA   endif;
HARbA /end-free
HARbA*
720aA /free
720aA
720aA   // Get SSCC-GS1 pallet ID
720aA   chain (lbewhs: lberid: lbpal#: 'ADBSSCC18': 0) pltmisc;
720aA
720aA   if %found(pltmisc);
720aA     lbesscc = pmvalue;
720aA   else;
720aA     lbesscc = *blanks;
720aA   endif;
720aA
720aA /end-free
     C                   endif
     *
     C                   endsl
     *
     C     endfi2        endsr
     *----------------------------------------------------------------
     *
     *  FILNUM  Fill numeric variable.
     *
     C     filnum        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLBBK  Begin bulk picks
     *
     C     lblbbk        begsr
     C                   if        $pgen = 1
     C                   eval      zontyp = 'Truck'
     C                   else
     C                   eval      zontyp = 'Stage'
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLBRP  Begining of letdowm label.
     *
     C     lblbrp        begsr
     C                   if        $pgen = 1
     C                   eval      zontyp = 'Truck'
     C                   else
     C                   eval      zontyp = 'Stage'
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLBLK  Bulk pick labels.
     *
     C     lblblk        begsr
     C                   eval      stpcnt = 0
     C                   eval      @qty2 = w1qty
     C                   eval      @pal# = pspal#
     C                   exsr      fillb1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLCWT  Catch weight labels.
     *
     C     lblcwt        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLCMB  Combined label is next.
     *
     C     lblcmb        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLCMA  Combined label is before.
     *
     C     lblcma        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLDIS  Discrepancies label.
     *
     C     lbldis        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLPSD  Pallet summary detail line.
     *
     C     lblpsd        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLPSH  Pallet summary header line.
     *
     C     lblpsh        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLPCK  Pick labels.
     *
     C     lblpck        begsr
     C                   eval      stpcnt = 0
     C                   exsr      getpal
     C                   eval      @pal# = pal#
     C                   if        combo = *off
     C                   eval      @qty1 = w1pick
     C                   eval      @qty2 = w1qty2
     C                   eval      totwrd = ' of'
     C                   move      '       '     cmbwrd
     C                   else
     C                   eval      @qty1 = 0
     C                   eval      @qty2 = w1qty2
     C                   eval      totwrd = 'TOT'
     C                   eval      cmbwrd = '(COMBO)'
     C                   endif
     C                   if        lbasl2 = 'OUT'
     C                   eval      outwrd = 'OUT'
     C                   else
     C                   move      '   '         outwrd
     C                   endif
     C                   exsr      fillb1
     C                   eval      combo = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLZPD  Zone pickup detail line.
     *
     C     lblzpd        begsr
     C                   eval      lbwhdp = *blanks
     C                   exsr      lblzps
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLZPH  Zone pickup header line.
     *
     C     lblzph        begsr
     C                   endsr
414bA*----------------------------------------------------------------
414bA*
414bA*  LBLZPS  Zone pickup individual selection labels
414bA*
414baC     lblzps        begsr
     *
     *     See if we should print the "before" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwrb = 'Y'
     C                   exsr      lblumb
     C                   endif
     *
     *     Initialize label fields.
     *
     C                   eval      w1qty2 = lbqpck
     C                   exsr      crtstp
     *
     *     Force combo label for writing to file
     *
     C                   eval      opclvl = 0
     *
     *     Either print a combination label ...
     *
     C                   select
     C                   when      lbqpck >= opclvl
     C                   eval      combo = *on
     *
     *        See if we should print the "before" combo warning.
     *
     C                   if        opcwrb = 'Y'
     C                   exsr      lblcmb
     C                   endif
     *
     *        Print one label.
     *
     C                   eval      w1pick = lbqpck
     C                   exsr      lblpck
     *
     *        See if we should print the "after" combo warning.
     *
     C                   if        opcwra = 'Y'
     C                   exsr      lblcma
     C                   endif
     *
     C                   other
     *
     *     Or print individual labels.
     *
     C                   eval      combo = *off
     C     1             do        lbqpck        w1pick
     C                   exsr      lblpck
     C                   enddo
     *
     C                   endsl
     *
     *     See if we should print the "after" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwra = 'Y'
     C                   exsr      lbluma
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLRP1  Replenishment/Letdown
     *
     C     lblrp1        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLRP2  Replenishment/Letdown - Breakdown.
     *
     C     lblrp2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLSHD  Set header.(Batch, Warehouse etc.)
     *
     C     lblshd        begsr
     C                   if        $pgen = 1
     C                   eval      zontyp = 'Truck'
     C                   else
     C                   eval      zontyp = 'Stage'
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLSSD  Set summary detail lines.
     *
     C     lblssd        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLSSH  Set summary header line.
     *
     C     lblssh        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLUMA  Unit of measure change is before.
     *
     C     lbluma        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLUMB  Unit of measure change is next.
     *
     C     lblumb        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLZHD  Zone header label.
     *
     C     lblzhd        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  LBLXDB  Cross dock labels are next.
     *
     C     lblxdb        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  STRPDP  Strip decimal point from sample data
     *
     C     strpdp        begsr
     C                   movea     lfvdta        a50
     C                   eval      y1 = 0
     C     1             do        50            x1
     C                   if        a50(x1) >= '0'  and
     C                             a50(x1) <= '9'
     C                   add       1             y1
     C                   eval      a50(y1) = a50(x1)
     C                   endif
     C                   enddo
     C                   if        y1 < 50
     C                   add       1             y1
     C                   movea     *blanks       a50(y1)
     C                   endif
     C                   movea     a50           lfvdta
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST1   Test 1 - Print label definitions
     *
     C     test1         begsr
     *
     C                   exsr      lblpck
     *
     C                   endsr

NCH A*----------------------------------------------------------------
NCH A*  zzGetOM    Get Order Detail Misc.
NCH A*----------------------------------------------------------------
NCH A
NCH Ac     zzGetOM       begsr
NCH A /free
NCH A
NCH A   monitor;
NCH A     chain (lbwhse: lbord: lbseq) orddm;
NCH A   on-error;
NCH A     clear ommsc1;
NCH A     clear ommsc2;
NCH A     clear ommsc3;
JFFeA     if client = Jakes;
JFFeA       eval  rtxdm3_omprcs = 0;
JFFeA       eval  rtxdm3_omspkn = 0;
JFFeA       eval  rtxdm3_omslbl = 0;
JFFeA     endif;
NCH A     clear ommsc4;
NCH A     clear ommsc5;
NCH A   endmon;
NCH A     if client = Nicholas;
NCH A       eval  orddm1_wax = ommsc1;
NCH A     endif;
HARaA     if client = Harbor;
HARaA       eval  orddm1_har = ommsc1;
HARaA       eval  orddm2_har = ommsc2;
HARaA     endif;
JFFeA     if client = Jakes;
JFfeA       eval  orddm3_rtx = ommsc3;
JFFeA     endif;
NCH A
NCH A /end-free
NCH Ac                   endsr

HARaA*----------------------------------------------------------------
HARaA*  zzGetHM    Get Header Detail Misc.
HARaA*----------------------------------------------------------------
HARaA
HARaAc     zzGetHM       begsr
HARaA /free
HARaA
HARaA   monitor;
HARaA     chain (lbwhse: lbord) ordhm;
HARaA   on-error;
HARaA     clear hmmsc1;
HARaA     clear hmmsc2;
HARaA     clear hmmsc3;
HARaA     clear hmmsc4;
HARaA     clear hmmsc5;
HARaA   endmon;
HARaA     if client = Harbor;
HARaA       eval  ordhm1_har = hmmsc1;
HARaA     endif;
HARaA
HARaA /end-free
HARaAc                   endsr

650aA*----------------------------------------------------------------
650aA*  zzzGetBatId    Get batch id
650aA*----------------------------------------------------------------
650aA
650aAc     zzzGetBatId   begsr
650aA /free
650aA
650aA   monitor;
650aA     GetBatId($pWhse: 'EXPPCKLBL': 'W':
650aA              batId: rtnCode: rtnMessage);
650aA   on-error;
650aA     clear batId;
650aA     clear rtnCode;
650aA     clear rtnMessage;
650aA   endmon;
650aA
650aA /end-free
650aAc                   endsr
650aA
650aA*----------------------------------------------------------------
650aA*  zzzGetStamps   Get timestamps
650aA*----------------------------------------------------------------
650aA
650aAc     zzzGetStamps  begsr
650aA /free
650aA
650aA   exec sql
650aA     values (current_timestamp,
650aA             current_timestamp-current_timezone)
650aA     into :stamp, :stampUC;
650aA
650aA   if sqlstt <> sqlSuccess;
650aA     clear stamp;
650aA     clear stampUC;
650aA   endif;
650aA
650aA /end-free
650aAc                   endsr
650aA
650aA*----------------------------------------------------------------
650aA*  zzzEnd     End processing
650aA*----------------------------------------------------------------
650aA
650aAc     zzzEnd        begsr
650aA /free
650aA
650aA   exec sql
650aA     update stgbatch
650aA     set sbstatus = 'R',
650aA         sbtext   = ' ',
650aA         sbststs  = current_timestamp,
650aA         sbstsuc  = current_timestamp - current_timezone
650aA     where sbwhse = :$pWhse
650aA       and sbbatid = :batId;
650aA
650aA   if sqlstt <> sqlSuccess;
650aA   endif;
ADCbA
ADCbA   // If Anderson-DuBose, run JDE process
ADCbA   if client = adc;
ADCbA   //RunJDE(%editc($pwhse:'X'));
ADCbA   endif;
650aA
650aA /end-free
650aAc                   endsr
