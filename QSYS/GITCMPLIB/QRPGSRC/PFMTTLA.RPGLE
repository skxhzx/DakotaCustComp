     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PFMT      Truck build picking labels - Label format method
     *  10 April 2000
     *  Dave Sommerville
     *
     *  **** Created using PFMTSFC 11.16.01 ****
     *
     *
     *  Revisions
     *
     *    04/10/00  DAS  4.14
     *      - Created
     *      - Includes changes made to PLBL40 through 4.13
     *
414aA*    04/19/00  DAS  4.14a
     *      - Changed to use a specific number of characters for
     *        variables.
     *
414bA*    04/19/00  DAS  4.14b
     *      - Created routine LBLZPS to print individual selection
     *        labels for merged items.
     *      - Revises LBLZPD to call LBLZPS when no merge detail
     *        lines exist.
     *      - Revised TEST1 routine. Put labels in alpha order.
     *        Changed SETHED label to print correctly.
     *      - Revise LBLZPD routine to print test correctly.
     *
414cA*    06/19/00  DAS  414c
     *      - 414b change for merge labels not working properly.
     *      - Revised routine LBLZPD to not do anything when there
     *        are no detail lines in merge label.
     *      - Revised routine SETEND to call LBLZPS for each merge
     *        record when there are no detail lines in merge label.
     *
ALN A*    11/16/01  HNK  ALN
     *      - Mfg code using ITVIT#. Use variable 101.
     *      - Custom header label created for Allen using SFC's label.
     *      - New label type "SETHEDAL" created for Allen using SFC's label.
     *      - Variable 103 used for department. Re: This code is used on new
     *        pallet header label and when it is printed we do not
     *        have a label record. All we have is zone information.
     *      - Revised routine LBFIL2 to print Misc field from ORDH -
     *        first 8 characters (Invoice number)
     *      - Revised to print UOM warning after/before every label
     *        with changed UOM
     *
ALN A*    02/04/02  HNK  ALN
     *      - Revised to print variable 94,105 and 106.  Order Seq#,
     *        Pallet section and Dock door number.
     *
ALNaA*    03/06/02  HNK  ALNa
     *      - Revised to print variable 89 and 90.
     *      - Print separate Will Call label.
     *      - Print extended description instead of from PIRITEM file.
     *
416 A*    03/22/02  HNK  416
     *      - Fix - Initialize DSZXXX data structure numeric fields.
     *
416cA*    07/12/02  DAS  4.16c
     *      - Revised main line to skip normal pallets that have a
     *        zero tran# and include a bulk pick. It that case we
     *        assume that OR630 skipped the pallet because it only
     *        contained bulk picks.
     *
ALNbA*    04/02/02  HNK  ALNb
     *      - Revised to print truck pallet number on zone pickup label.
     *
ALNcA*    04/08/02  HNK  ALNc
     *      - Revised to print hyphens in slot number.
     *
ALNdA*    04/11/02  HNK  ALNd
     *      - Revised to calculate pick time and print on SETSUM label
     *
ALNeA*    04/11/02  HNK  ALNe
     *      - Revised to get dock door number to print.
     *
ALNfA*    04/29/02  HNK  ALNf
     *      - Revised to convert label# and pallet ID to char.
     *
ALNgA*    04/30/02  HNK  ALNg
     *      - Revised to round down pick time.
     *
ALNhA*    05/01/02  HNK  ALNh
     *      - Revised to print SETHEDAL label only for truck pallets.
     *      - Include zone pickup time in total selection time.
     *      - Add .083 minutes for each Catch Wt label.
     *
ALNiA*    05/08/02  HNK  ALNi
     *      - Use dept from item file
     *
416dA*    07/11/02  DAS  4.16d
     *      - Revised PRTBLK routine to print catchweight labels.
     *        Note: These will need to be matched with the
     *              corresponding truck pallet for closing.
     *
TLA  *    06/07/04  RMR  TLA
     *      - TL Ashford mods for Andrews Food Service
     *
TLA2 *    08/31/04  RMR  TLA
     *      - Load print variable 97 with FIUPCN
     *             for Andrews Food Service
     *
NST1 *    10/11/04  RMR  TLA
     *      - Bypass CW Label for item 27801
     *             for Andrews Food Service
     *
TLAd *    05/24/06  DAS  TLAd
     *      - Revised routine LBLZPD to use ZPDCNT instead of PALCNT.
     *      - Revised routine LBLZPD to increment CNT.
TLAe *    08/11/06  RH   TLAe
     *      - Added file LABEL32C, Change PRTSEL to use LABEL32C.
AFSa *    07/26/10  RH   AFSa
     *      - Enh: send palletid with route id in first 2 char.
AFSb *    08/04/10  RH   AFSb
     *      - Enh: Add cmd *PRNTJIT to print JIT replenishments like
     *        old letdowns.
     *
610 A*    06/09/10  JCJ  610 A
     *      - Added v6.1 changes.
     *
610aA*    07/23/10  JCJ  610a
     *      - Added last two numbers of route id to first two
     *        positions of pallet id.
610bA*    08/04/10  RH   6.10b
     *      - Enh: Create PRTJIT to print JIT replenishments.
610cA*    08/19/10  MLB  6.10c
     *      - Enh: Added inz() keyword to numeric sub fields on the
     *        the following multi-occurence DS's: STPSUM, PALSUM,PIRSUM.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program was designed to work with Zebra type printers
     *    in which a string of codes are sent to the printer to print
     *    a label.
     *
     *    The basic process is as follows:
     *
     *      1) Design the label using a PC program like Bar-One from
     *         the Zebra corporation. The label must be designed
     *         using the defined variable codes. These codes can
     *         be view using program LF150CL. In the label, all the
     *         fields should be defined as text (constant) fields and
     *         not as variable fields.
     *
     *      2) Create a text file containing the codes (script)
     *         need to print the label. With a Zebra printer, this
     *         would be ZPL code.
     *
     *      3) Upload the text file into file IMPLFMT.
     *
     *      4) Using the Set Maintenance program, import the script
     *         for the specific label format type.
     *
     *
     *    To use a specific label set within Truck Builder, enter
     *    the following for the label program name:
     *
     *                    PFMTssssss
     *
     *    where 'ssssss' is the name of the label set to use.
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
     FPLTSUM3   IF   E           K DISK
     FPLTSTP1   IF   E           K DISK
     FLABEL3    IF   E           K DISK
     FLABEL31   IF   E           K DISK
     FLABEL32   IF   E           K DISK
TLAe FLABEL32C  IF   E           K DISK
     FLABEL33   IF   E           K DISK
     FPIRITEM   IF   E           K DISK
     FITEMLNK   IF   E           K DISK
     FOPTIONS   IF   E           K DISK
610 AFoptionz   if   e           k disk
610bAFprplfil1  if   e           k disk
610 AFtruckh    if   e           k disk
ALNaAFITEMDSC   IF   E           K DISK
ALNdAFSTDTIME   IF   E           K DISK
TLA2 FFIITMAL0  IF   E           K DISK
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *    General
     *
     D A12             S              1    DIM(12)
     D A40             S              1    DIM(40)
     D A50             S              1    DIM(50)
     D A58             S              1    DIM(58)
     D A80             S              1    DIM(80)
     *
     *
     *    Input/Output strings
     *
     D STI             S              1    DIM(75)
     D STO             S              1    DIM(198)
     *
     *    Large Characters
     *
     *
     *    Set summary total description
     *
     D TTLDSC          S             40    DIM(1) CTDATA PERRCD(1)
     *
ALNdA*    Pick time
     *
ALNdAD WDS             S              9    DIM(99)
ALNdAD WHS             S              3  0 DIM(99)
ALNdAD WHD             S              5    DIM(99)
ALNdAD SEC             S              1    DIM(99)
ALNaAD CSE             S              5  0 DIM(99)
ALNaAD SLT             S              5  0 DIM(99)
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
     D OPDATA          DS
     D  OPEPM                  1      1
     D  OPRF                   2      2
     D  OPCAPC                 3      3
     D  OPLETD                 4      4
     D  OPTEN2               117    117
     *----------------------------------------------------------------
     *  Medium stop number data structures.
     *
     D                 DS
     D  CH1                    1    120
     D                                     DIM(12)
     D  STP11                  1     10
     D  STP12                 11     20
     D  STP13                 21     30
     D  STP14                 31     40
     D  STP15                 41     50
     D  STP16                 51     60
     D  STP17                 61     70
     D  STP18                 71     80
     D  STP19                 81     90
     D  STP110                91    100
     D  STP111               101    110
     D  STP112               101    120
     D                 DS
     D  CH2                    1    120
     D                                     DIM(12)
     D  STP21                  1     10
     D  STP22                 11     20
     D  STP23                 21     30
     D  STP24                 31     40
     D  STP25                 41     50
     D  STP26                 51     60
     D  STP27                 61     70
     D  STP28                 71     80
     D  STP29                 81     90
     D  STP210                91    100
     D  STP211               101    110
     D  STP212               101    120
     *----------------------------------------------------------------
     *  Stop summary data structure for one set of labels.
     *  Maximum of 9 stops on one pallet, for fixed section items.
     *  Maximum of 99 stops on one pallet, for PIR section items.
     *
     D STPSUM          DS                  OCCURS(99)
610cMD  DSSSTP                 1      2  0 inz(0)
610cMD  DSSCUB                 3      8  3 inz(0)
610cMD  DSSWGT                 9     15  2 inz(0)
610cMD  DSSPCS                16     19  0 inz(0)
     D  DSSCNM                20     59
     *----------------------------------------------------------------
     *  Pallet summary data structure for one set of labels.
     *
     D PALSUM          DS                  OCCURS(9)
610cMD  DSPPAL                 1      7  0 inz(0)
610cMD  DSPSTP                 8      9  0 inz(0)
610cMD  DSPCUB                10     15  3 inz(0)
610cMD  DSPWGT                16     22  2 inz(0)
610cMD  DSPPCS                23     25  0 inz(0)
610cMD  STP                   26     43  0 inz(0)
     D                                     DIM(9)
     D  DSPPLI                44     50  0 INZ
ALN AD  DSPRTI                51     55
     *----------------------------------------------------------------
     *  PIR stop summary data structure for route.
     *
     D PIRSUM          DS                  OCCURS(99)
610cMD  DSRSTP                 1      2  0 inz(0)
610cMD  DSRCUB                 3      8  3 inz(0)
610cMD  DSRWGT                 9     15  2 inz(0)
610cMD  DSRPCS                16     18  0 inz(0)
     D  DSRWDP                19     23
     D  DSRCNM                24     63
     D  DSRFLG                64     64
     *----------------------------------------------------------------
     *  Zone pickup summary data structure
     *
     D ZONPKU          DS                  OCCURS(20)
416 AD  DSZSTP                 1      2  0 INZ
416 AD  DSZPCS                 3      7  0 INZ
     D  DSZITM                 8     22
     D  DSZDSC                23     52
416 AD  DSZPLT                53     59  0 INZ
     *----------------------------------------------------------------
ALNcAD                 DS
ALNcAD  LIDISP                 1     12
ALNcAD  LIASLE                 1      3
ALNcAD  LILOC                  4      5
ALNcAD  LILVL                  6     12
     *----------------------------------------------------------------
ALNcAD                 DS
ALNcAD  DIDISP                 1     12
ALNcAD  DIASLE                 1      3
ALNCAD  DIDS1                  4      4
ALNcAD  DILOC                  5      6
ALNcAD  DIDS2                  7      7
ALNcAD  DILVL                  8     12
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
610 A*    OPAISL  -  Print aisle change label (Y/N).
610 A*    OPTAXR  -  Include in Tax Right (Y=Yes, N=No).
610 A*    OPCHKR  -  Include in Check Right (Y=Yes, N=No).
     *
     * Data structure
     *
610 D *OPZDTA          DS
610 MD opdta2          ds
     D  OPCLVL                 1      3  0
     D  OPCWRA                 4      4
     D  OPCWRB                 5      5
     D  OPUWRA                 6      6
     D  OPUWRB                 7      7
     D  OPTEXT                 8     50
     D  OPERR                 51     52  0
     D  OPCWGT                53     54  0
     D  OPLPGM                55     64
     D  OPPDEV                65     74
     D  OPPFRM                75     84
610 AD  opaisl                85     85
610 AD  optaxr                86     86
610 AD  opchkr                87     87
     D  OPTEND               117    117
     *----------------------------------------------------------------
610 A*  *PICKLBA -  Label printing options for the standard pick,
610 A*              retail, and tote labels.
     *
610 A*     08/12/09  RBD  5.20  P#00219
610 A*       - Added record type *PICKLBA which holds printing info
610 A*         for the standard pick, retail, and tote labels.
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
610 A*  *PICKLBB -  Label printing options for the pick list and
610 A*               ASN labels and pick list report.
     *
610 A*     08/12/09  RBD  5.20  P#00219
610 A*       - Added record type *PICKLBB which holds printing info
610 A*         for the pick list and ASN labels and pick list report.
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
610 A*----------------------------------------------------------------
610 A*  *PICK  -  Picking options
610 A*
610 A*----------------------------------------------------------------
610 A*
610 A* Fields
610 A*
610 A*    OPNXTP  -  Next pallet number.
610 A*    OPBPCK  -  Bulk pick definition.
610 A*    OPPCUB  -  Maximum cube for PIR.
610 A*    OPFPAL  -  Pallets on fixed fork lift.
610 A*    OPFCUB  -  Maximum cube per fixed pallet.
610 A*    OPFSTP  -  Maximum stops per fixed pallet.
610 A*    OPINCL  -  Include PIR in fixed cube.
610 A*    OPSRCH  -  Number of previous pallets to search for space.
610 A*    OPFBLD  -  Fixed pallet building method.
610 A*                1 = By piece without concern for splitting stop.
610 A*                2 = By stop without splitting stop between plts.
610 A*    OPPBRK  -  Aisle to start new pallet.
610 A*    OPPBLD  -  Pallet building method.
610 A*                1 = By stop then slot location.
610 A*                2 = By slot location then stop.
610 A*                3 = By descening stop, then slot location.
610 A*    OPSELM  -  Selection method.
610 A*                1 = Single pass (By location).
610 A*                2 = Multiple pass (By stop).
610 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
610 A*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
610 A*    OPNWPL  -  Start new pallet when aisle changes if build method
610 A*               is 2=Location.
610 A*    OPFORD  -  Maximun orders per pallet.
610 A*    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
610 A*    OPFTOT  -  Maximum totes per pallet.
610 A*    OPTECB  -  External tote cube.
610 A*    OPTICB  -  Internal tote cube.
610 A*    OPTSTP  -  Maximum stops per tote.
610 A*    OPTPCS  -  Maximum pieces per tote.
610 A*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
610 A*    OPGCDE  -  USF Group Code (0-9).
610 A*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
610 A*    OPSPAL  -  Merge pallet should only contain
610 A*               items for single truck pallet (Y=Yes, N=No).
610 A*    OPPITM  -  Maximum items per pallet.
610 A*
610 A* Data structure
610 A*
610 AD opdta1          ds
610 AD  opnxtp                 1      7  0 inz(0)
610 AD  oppcub                10     14  2 inz(0)
610 AD  opfpal                15     15  0 inz(0)
610 AD  opfcub                16     20  2 inz(0)
610 AD  opincl                22     22
610 AD  opsrch                23     24  0 inz(0)
610 AD  opfstp                25     26  0 inz(0)
610 AD  opfbld                27     27  0 inz(0)
610 AD  opbpck                28     30  0 inz(0)
610 AD  oppbrk                31     33
610 AD  oppbld                34     34
610 AD  opselm                35     35
610 AD  opsplt                36     36
610 AD  opbmrg                37     37
610 AD  opnwpl                38     38
610 AD  opford                39     40  0 inz(0)
610 AD  opptyp                41     41
610 AD  opftot                42     43  0 inz(0)
610 AD  optecb                44     48  2 inz(0)
610 AD  opticb                49     53  2 inz(0)
610 AD  optstp                54     55  0 inz(0)
610 AD  optord                56     57  0 inz(0)
610 AD  optpcs                58     60  0 inz(0)
610 AD  opstop                61     61
610 A** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
610 AD**opgcde                62     62
610 AD  oppkup                62     62
610 AD  opspal                63     63
610 AD  oppitm                64     67  0 inz(0)
610 AD  opend1               117    117
     *----------------------------------------------------------------
     *  Variable sample data
     *
     D                 DS
     D  LFVDTA                 1     50
     D  DSN020                 1      2  0
     D  DSN030                 1      3  0
     D  DSN050                 1      5  0
     D  DSN063                 1      6  3
     D  DSN070                 1      7  0
     D  DSN072                 1      7  2
     D  DSN100                 1     10  0
     D  DSN110                 1     11  0
     *
ALNaAD                 DS
ALNaAD  DSMISC                 1     20
ALNaAD  DSINVC                 1      8
ALNaAD  DSALPH                 9      9
ALNaAD  DSWSEQ                10     12
     *
TLA  D                 DS
TLA  D  DATE8                  1      8
TLA  D  MM                     1      2  0
TLA  D  S1                     3      3
TLA  D  DD                     4      5  0
TLA  D  S2                     6      6
TLA  D  YY                     7      8  0
     *
TLA  D                 DS
TLA  D  TIHI                   1      7
TLA  D  TI                     1      4  0
TLA  D  S3                     5      5
TLA  D  HI                     6      7  0
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @CVTDT          C                   CONST('CVTDTE')
     *
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     *----------------------------------------------------------------
ALNeA*
ALNeAD $LPARM          DS
ALNeAD  $LCMD                  1      8
ALNeAD  $LPRG                  9     18
ALNeAD  $LUKY                 19     68
ALNeAD  $LRTN                 69     76
ALNeAD  $LERM                 77    136
ALNeAD  $LMSG                 77     80
ALNeA*
ALNeA*   Redefine key
ALNeA*
ALNeAD  $LWHSE                19     21  0
ALNeAD  $LRTID                22     26
ALNeAD  $LTRN#                27     33  0
ALNeAD  $LWHDP                34     38
ALNeAD  $LDOOR                39     41  0
ALNeA*
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     *
TLA AD MRGDTA          DS
 ||  D  @@STPN                 1      2  0
 \/  D  @@CSST                 3      4
     D  @@WHNA                 5      7
     D  @@TKCM                 8      8
     D  @@TRAN                15     21  0
     D  @@SLTN                22     33
     D  @@PICK                34     38  0
     D  @@UOM                 39     43
     D  @@TIHI                44     50
     D  @@PKSZ                51     65
     D  @@IDE1                66     95
     D  @@ITEM                96    110
     D  @@ORDN               111    117  0
     D  @@CUSN               118    128
     D  @@DTES               129    136
     D  @@TRCK               137    146
     D  @@CNAM               147    186
     D  @@CADR               187    226
     D  @@CCTY               227    246
     D  @@CZIP               247    256
     D  @@PALT               257    263  0
     D  @@PSPN               264    270  0
     D  @@PSST               271    273  0
     D  @@PSPC               274    278  0
     D  @@PSCU               279    284  3
     D  @@PSWT               285    291  2
     D  @@PQTY               292    296  0
     D  @@OF                 297    299
     D  @@CMBO               300    306
     D  @@ZONE               307    312
     D  @@ZSTP               313    314  0
     D  @@ZSPC               315    319  0
     D  @@ZSID               320    367
     D  @@ZSPL               368    374  0
     D  @@ZSTR               375    381  0
     D  @@ZSZ                382    387
     D  @@TSLT               388    399
     D  @@RTEN               400    404
     D  @@ZNTP               405    409
     D  @@OUT                410    412
     D  @@SSST               413    414  0
     D  @@SSPC               415    419  0
     D  @@SSCU               420    425  3
     D  @@SSWT               426    432  2
     D  @@SSCN               433    472
     D  @@BCRQ               473    477  0
     D  @@BCRU               478    482
     D  @@BCFI               483    497
     D  @@BCTI               498    512
     D  @@BCFD               513    542
     D  @@BCTD               543    568
     D  @@LBLN               569    575  0
     D  @@VEND               576    586  0
     D  @@PUOM               587    591
     D  @@PLID               592    598  0
     D  @@RTID               599    603  0
     D  @@PCKT               604    608  2
     D  @@IDE2               609    638
     D  @@SCKD               639    641  0
     D  @@INSI               647    661
     D  @@PBKR               662    668  0
     D  @@ITMN               669    674
     D  @@ZDSC               675    689
     D  @@WCTC               690    699
     D  @@ASTP               714    714
     D  @@WCSQ               715    717  0
     D  @@AINV               718    725
     D  @@NOIT               726    740
     D  @@CDOR               741    742
     D  @@OSEQ               743    747  0
     D  @@CBAT               748    751
     D  @@EDL2               752    781
     D  @@NVIT               782    796
     D  @@NRPC               797    799
     D  @@NSRP               800    804  2
     D  @@NUPC               805    824
     D  @@SMFG               825    835
     D  @@BRND               836    841
     D  @@DEPT               842    846
     D  @@SOMS               847    866
     D  @@PLTS               867    868
     D  @@DDOR               869    870
     *  Pallet Summary Data - Line 1
 27  D  @@PSN1               871    877  0
 28  D  @@PSS1               878    880  0
 29  D  @@PSP1               881    885  0
 30  D  @@PSC1               886    891  3
 31  D  @@PSW1               892    898  2
     *  Pallet Summary Data - Line 2
     D  @@PSN2               899    905  0
     D  @@PSS2               906    908  0
     D  @@PSP2               909    913  0
     D  @@PSC2               914    919  3
     D  @@PSW2               920    926  2
     *  Pallet Summary Data - Line 3
     D  @@PSN3               927    933  0
     D  @@PSS3               934    936  0
     D  @@PSP3               937    941  0
     D  @@PSC3               942    947  3
     D  @@PSW3               948    954  2
     *  Pallet Summary Data - Line 4
     D  @@PSN4               955    961  0
     D  @@PSS4               962    964  0
     D  @@PSP4               965    969  0
     D  @@PSC4               970    975  3
     D  @@PSW4               976    982  2
     *  Pallet Summary Data - Line 5
     D  @@PSN5               983    989  0
     D  @@PSS5               990    992  0
     D  @@PSP5               993    997  0
     D  @@PSC5               998   1003  3
     D  @@PSW5              1004   1010  2
     *  Pallet Summary Data - Line 6
     D  @@PSN6              1011   1017  0
     D  @@PSS6              1018   1020  0
     D  @@PSP6              1021   1025  0
     D  @@PSC6              1026   1031  3
     D  @@PSW6              1032   1038  2
     *  Pallet Summary Data - Line 7
     D  @@PSN7              1039   1045  0
     D  @@PSS7              1046   1048  0
     D  @@PSP7              1049   1053  0
     D  @@PSC7              1054   1059  3
     D  @@PSW7              1060   1066  2
     *  Pallet Summary Data - Line 8
     D  @@PSN8              1067   1073  0
     D  @@PSS8              1074   1076  0
     D  @@PSP8              1077   1081  0
     D  @@PSC8              1082   1087  3
     D  @@PSW8              1088   1094  2
     *  Pallet Summary Data - Line 9
     D  @@PSN9              1095   1101  0
     D  @@PSS9              1102   1104  0
     D  @@PSP9              1105   1109  0
     D  @@PSC9              1110   1115  3
     D  @@PSW9              1116   1122  2
     *  Pallet Summary Data - Line 10
     D  @@PSN0              1123   1129  0
     D  @@PSS0              1130   1132  0
     D  @@PSP0              1133   1137  0
     D  @@PSC0              1138   1143  3
     D  @@PSW0              1144   1150  2
     *  Set Summary Data - Line 1
 46  D  @@SSS1              1151   1152  0
 47  D  @@SSP1              1153   1157  0
 48  D  @@SSC1              1158   1163  3
 49  D  @@SSW1              1164   1170  2
 50  D  @@SSN1              1171   1210
     *  Set Summary Data - Line 2
     D  @@SSS2              1211   1212  0
     D  @@SSP2              1213   1217  0
     D  @@SSC2              1218   1223  3
     D  @@SSW2              1224   1230  2
     D  @@SSN2              1231   1270
     *  Set Summary Data - Line 3
     D  @@SSS3              1271   1272  0
     D  @@SSP3              1273   1277  0
     D  @@SSC3              1278   1283  3
     D  @@SSW3              1284   1290  2
     D  @@SSN3              1291   1330
     *  Set Summary Data - Line 4
     D  @@SSS4              1331   1332  0
     D  @@SSP4              1333   1337  0
     D  @@SSC4              1338   1343  3
     D  @@SSW4              1344   1350  2
     D  @@SSN4              1351   1390
     *  Set Summary Data - Line 5
     D  @@SSS5              1391   1392  0
     D  @@SSP5              1393   1397  0
     D  @@SSC5              1398   1403  3
     D  @@SSW5              1404   1410  2
     D  @@SSN5              1411   1450
     *  Set Summary Data - Line 6
     D  @@SSS6              1451   1452  0
     D  @@SSP6              1453   1457  0
     D  @@SSC6              1458   1463  3
     D  @@SSW6              1464   1470  2
     D  @@SSN6              1471   1510
     *  Set Summary Data - Line 7
     D  @@SSS7              1511   1512  0
     D  @@SSP7              1513   1517  0
     D  @@SSC7              1518   1523  3
     D  @@SSW7              1524   1530  2
     D  @@SSN7              1531   1570
     *  Set Summary Data - Line 8
     D  @@SSS8              1571   1572  0
     D  @@SSP8              1573   1577  0
     D  @@SSC8              1578   1583  3
     D  @@SSW8              1584   1590  2
     D  @@SSN8              1591   1630
     *  Set Summary Data - Line 9
     D  @@SSS9              1631   1632  0
     D  @@SSP9              1633   1637  0
     D  @@SSC9              1638   1643  3
     D  @@SSW9              1644   1650  2
     D  @@SSN9              1651   1690
     *  Set Summary Data - Line 10
     D  @@SSS0              1691   1692  0
     D  @@SSP0              1693   1697  0
     D  @@SSC0              1698   1703  3
     D  @@SSW0              1704   1710  2
     D  @@SSN0              1711   1750
     *  Zone Pickup Summary Data Line 1
 36  D  @@ZSS1              1751   1752  0
 37  D  @@ZSP1              1753   1757  0
 38  D  @@ZSI1              1758   1805
 39  D  @@ZSN1              1806   1812  0
     *  Zone Pickup Summary Data Line 2
     D  @@ZSS2              1813   1814  0
     D  @@ZSP2              1815   1819  0
     D  @@ZSI2              1820   1867
     D  @@ZSN2              1868   1874  0
     *  Zone Pickup Summary Data Line 3
     D  @@ZSS3              1875   1876  0
     D  @@ZSP3              1877   1881  0
     D  @@ZSI3              1882   1929
     D  @@ZSN3              1930   1936  0
     *  Zone Pickup Summary Data Line 4
     D  @@ZSS4              1937   1938  0
     D  @@ZSP4              1939   1943  0
     D  @@ZSI4              1944   1991
     D  @@ZSN4              1992   1998  0
     *  Zone Pickup Summary Data Line 5
     D  @@ZSS5              1999   2000  0
     D  @@ZSP5              2001   2005  0
     D  @@ZSI5              2006   2053
     D  @@ZSN5              2054   2060  0
     *  Zone Pickup Summary Data Line 6
     D  @@ZSS6              2061   2062  0
     D  @@ZSP6              2063   2067  0
     D  @@ZSI6              2068   2115
     D  @@ZSN6              2116   2122  0
     *  Zone Pickup Summary Data Line 7
     D  @@ZSS7              2123   2124  0
     D  @@ZSP7              2125   2129  0
     D  @@ZSI7              2130   2177
     D  @@ZSN7              2178   2184  0
     *  Zone Pickup Summary Data Line 8
     D  @@ZSS8              2185   2186  0
     D  @@ZSP8              2187   2191  0
     D  @@ZSI8              2192   2239
     D  @@ZSN8              2240   2246  0
     *  Zone Pickup Summary Data Line 9
     D  @@ZSS9              2247   2248  0
     D  @@ZSP9              2249   2253  0
     D  @@ZSI9              2254   2301
     D  @@ZSN9              2302   2308  0
     *  Zone Pickup Summary Data Line 10
     D  @@ZSS0              2309   2310  0
     D  @@ZSP0              2311   2315  0
     D  @@ZSI0              2316   2363
 /\  D  @@ZSN0              2364   2370  0
 ||  *
TLA AD  @@UNUS              4096   4096
     *
     *  Pallet Summary Label format
TLA AD MRGDT1          DS
 2   D  D1WHNA                 1      3
 3   D  D1TKCM                 4      4
 10  D  D1TRAN                 5     11  0
 35  D  D1ZONE                12     17
 43  D  D1RTEN                18     22
 44  D  D1ZNTP                23     27
     *  Pallet Summary Data - Line 1
 27  D  D1PSN1                28     34  0
 28  D  D1PSS1                35     37  0
 29  D  D1PSP1                38     42  0
 30  D  D1PSC1                43     48  3
 31  D  D1PSW1                49     55  2
     *  Pallet Summary Data - Line 2
     D  D1PSN2                56     62  0
     D  D1PSS2                63     65  0
     D  D1PSP2                66     70  0
     D  D1PSC2                71     76  3
     D  D1PSW2                77     83  2
     *  Pallet Summary Data - Line 3
     D  D1PSN3                84     90  0
     D  D1PSS3                91     93  0
     D  D1PSP3                94     98  0
     D  D1PSC3                99    104  3
     D  D1PSW3               105    111  2
     *  Pallet Summary Data - Line 4
     D  D1PSN4               112    118  0
     D  D1PSS4               119    121  0
     D  D1PSP4               122    126  0
     D  D1PSC4               127    132  3
     D  D1PSW4               133    139  2
     *  Pallet Summary Data - Line 5
     D  D1PSN5               140    146  0
     D  D1PSS5               147    149  0
     D  D1PSP5               150    154  0
     D  D1PSC5               155    160  3
     D  D1PSW5               161    167  2
     *  Pallet Summary Data - Line 6
     D  D1PSN6               168    174  0
     D  D1PSS6               175    177  0
     D  D1PSP6               178    182  0
     D  D1PSC6               183    188  3
     D  D1PSW6               189    195  2
     *  Pallet Summary Data - Line 7
     D  D1PSN7               196    202  0
     D  D1PSS7               203    205  0
     D  D1PSP7               206    210  0
     D  D1PSC7               211    216  3
     D  D1PSW7               217    223  2
     *  Pallet Summary Data - Line 8
     D  D1PSN8               224    230  0
     D  D1PSS8               231    233  0
     D  D1PSP8               234    238  0
     D  D1PSC8               239    244  3
     D  D1PSW8               245    251  2
     *  Pallet Summary Data - Line 9
     D  D1PSN9               252    258  0
     D  D1PSS9               259    261  0
     D  D1PSP9               262    266  0
     D  D1PSC9               267    272  3
     D  D1PSW9               273    279  2
     *  Pallet Summary Data - Line 10
     D  D1PSN0               280    286  0
     D  D1PSS0               287    289  0
     D  D1PSP0               290    294  0
     D  D1PSC0               295    300  3
     D  D1PSW0               301    307  2
TLA AD  D1UNU1              4096   4096
     *
     *  Set Summary Label format
TLA AD MRGDT2          DS
 40  D  D2ZSTR                 1      7  0
     *  Set Summary Data - Line 1
 46  D  D2SSS1                 8      9  0
 47  D  D2SSP1                10     14  0
 48  D  D2SSC1                15     20  3
 49  D  D2SSW1                21     27  2
 50  D  D2SSN1                28     67
     *  Set Summary Data - Line 2
     D  D2SSS2                68     69  0
     D  D2SSP2                70     74  0
     D  D2SSC2                75     80  3
     D  D2SSW2                81     87  2
     D  D2SSN2                88    127
     *  Set Summary Data - Line 3
     D  D2SSS3               128    129  0
     D  D2SSP3               130    134  0
     D  D2SSC3               135    140  3
     D  D2SSW3               141    147  2
     D  D2SSN3               148    187
     *  Set Summary Data - Line 4
     D  D2SSS4               188    189  0
     D  D2SSP4               190    194  0
     D  D2SSC4               195    200  3
     D  D2SSW4               201    207  2
     D  D2SSN4               208    247
     *  Set Summary Data - Line 5
     D  D2SSS5               248    249  0
     D  D2SSP5               250    254  0
     D  D2SSC5               255    260  3
     D  D2SSW5               261    267  2
     D  D2SSN5               268    307
     *  Set Summary Data - Line 6
     D  D2SSS6               308    309  0
     D  D2SSP6               310    314  0
     D  D2SSC6               315    320  3
     D  D2SSW6               321    327  2
     D  D2SSN6               328    367
     *  Set Summary Data - Line 7
     D  D2SSS7               368    369  0
     D  D2SSP7               370    374  0
     D  D2SSC7               375    380  3
     D  D2SSW7               381    387  2
     D  D2SSN7               388    427
     *  Set Summary Data - Line 8
     D  D2SSS8               428    429  0
     D  D2SSP8               430    434  0
     D  D2SSC8               435    440  3
     D  D2SSW8               441    447  2
     D  D2SSN8               448    487
     *  Set Summary Data - Line 9
     D  D2SSS9               488    489  0
     D  D2SSP9               490    494  0
     D  D2SSC9               495    500  3
     D  D2SSW9               501    507  2
     D  D2SSN9               508    547
     *  Set Summary Data - Line 10
     D  D2SSS0               548    549  0
     D  D2SSP0               550    554  0
     D  D2SSC0               555    560  3
     D  D2SSW0               561    567  2
     D  D2SSN0               568    607
TLA AD  D2UNU2              4096   4096
     *
     *  Zone Pickup Summary Label format
TLA AD MRGDT3          DS
 40  D  D3ZSTR                 1      7  0
 41  D  D3ZSZ                  8     13
 43  D  D3RTEN                14     18
     *  Zone Pickup Summary Data Line 1
 36  D  D3ZSS1                19     20  0
 37  D  D3ZSP1                21     25  0
 38  D  D3ZSI1                26     73
 39  D  D3ZSN1                74     80  0
     *  Zone Pickup Summary Data Line 2
     D  D3ZSS2                81     82  0
     D  D3ZSP2                83     87  0
     D  D3ZSI2                88    135
     D  D3ZSN2               136    142  0
     *  Zone Pickup Summary Data Line 3
     D  D3ZSS3               143    144  0
     D  D3ZSP3               145    149  0
     D  D3ZSI3               150    197
     D  D3ZSN3               198    204  0
     *  Zone Pickup Summary Data Line 4
     D  D3ZSS4               205    206  0
     D  D3ZSP4               207    211  0
     D  D3ZSI4               212    259
     D  D3ZSN4               260    266  0
     *  Zone Pickup Summary Data Line 5
     D  D3ZSS5               267    268  0
     D  D3ZSP5               269    273  0
     D  D3ZSI5               274    321
     D  D3ZSN5               322    328  0
     *  Zone Pickup Summary Data Line 6
     D  D3ZSS6               329    330  0
     D  D3ZSP6               331    335  0
     D  D3ZSI6               336    383
     D  D3ZSN6               384    390  0
     *  Zone Pickup Summary Data Line 7
     D  D3ZSS7               391    392  0
     D  D3ZSP7               393    397  0
     D  D3ZSI7               398    445
     D  D3ZSN7               446    452  0
     *  Zone Pickup Summary Data Line 8
     D  D3ZSS8               453    454  0
     D  D3ZSP8               455    459  0
     D  D3ZSI8               460    507
     D  D3ZSN8               508    514  0
     *  Zone Pickup Summary Data Line 9
     D  D3ZSS9               515    516  0
     D  D3ZSP9               517    521  0
     D  D3ZSI9               522    569
     D  D3ZSN9               570    576  0
     *  Zone Pickup Summary Data Line 10
     D  D3ZSS0               577    578  0
     D  D3ZSP0               579    583  0
     D  D3ZSI0               584    631
 /\  D  D3ZSN0               632    638  0
 ||  *
TLA AD  D3UNU3              4096   4096
     *
     *  Various Misc Label format
TLA AD MRGDT4          DS
 10  D  D4TRAN                 1      7  0
 11  D  D4SLTN                 8     19
 12  D  D4PICK                20     24  0
 13  D  D4UOM                 25     29
 14  D  D4TIHI                30     36
 15  D  D4PKSZ                37     51
 16  D  D4IDE1                52     81
 72  D  D4ITMN                82     87
 19  D  D4CUSN                88     98
 20  D  D4DTES                99    106
 21  D  D4TRCK               107    116
 22  D  D4CNAM               117    156
 26  D  D4PALT               157    163  0
 32  D  D4PQTY               164    168  0
 40  D  D4ZSTR               169    175  0
 41  D  D4ZSZ                176    181
 43  D  D4RTEN               182    186
 45  D  D4OUT                187    189
 90  D  D4WCSQ               190    192  0
 91  D  D4AINV               193    200
 94  D  D4OSEQ               201    205  0
 97  D  D4NVIT               206    220
103  D  D4DEPT               221    225
105  D  D4PLTS               226    227
 57  D  D4LBLN               228    234  0
999  D  D4PLID               235    241  0
TLA AD  D4UNU4              4096   4096
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     D $NADEC          s              2  0
     D $NAFP           s              2  0
     D $NANUM          s             11  0
     D @PAL#           s                   like(PSPAL#)
     D @PLID           s              7  0
     D @QTY1           s                   like(W1PICK)
     D @QTY2           s                   like(W1QTY)
     D @RTID           s              5
     D ACROSS          s              2  0
     D AX              s              2  0
     D AY              s              2  0
     D CMBWRD          s              7
     D CMPN            s              3
     D CNT             s              2  0
     D COMBO           s              1
     D COUNT           s              5  0
     D CURCOL          s                   like(PSCOL)
     D CURPAL          s              2  0
     D CURROW          s                   like(PSROW)
     D CURUNL          s                   like(PSUNLD)
     D CWTIME          s              5  2
     D DEMAND          s              1
     D DIRCTN          s              8
     D DPOS            s              2  0
     D DSZCNM          s             30
     D DTLCNT          s              3  0
     D FIRST           s              1
     D FIRST2          s              1
     D FOREVR          s              1
     D FRDESC          s             30
     D FRITEM          s             15
     D ITMN            s              6
     D IX              s             48
     D K               s              2  0
     D KYLTYP          s                   like(LBTYPE)
610b D KYSEQ#          s                   like(PRSEQ#)
     D KYTYPE          s                   like(PSTYPE)
610b D KYWHDP          s                   like(LBWHDP)
     D LBLDEV          s             10
     D LBLNAM          s              8
     D LBLQTY          s              4  0
     D LBLS            s              3  0
     D LSTLB#          s                   like(LBLBL#)
     D LSTPID          s                   like(PSPLID)
     D LSTSTP          s                   like(LBSTOP)
     D LSTTRN          s                   like(LBTRN#)
     D LSTUM           s                   like(LBUTYP)
     D LSTWDP          s                   like(LBWHDP)
     D LSTZON          s                   like(PSSZON)
     D MAXSTI          s              2  0
     D MAXSTO          s              3  0
     D N               s              3  0
     D NUM1            s              1  0
     D NUM2            s              1  0
     D OUTWRD          s              3
     D PAL#            s              7  0
     D PALCNT          s              2  0
     D PCKTIM          s              5  2
     D PCKTM0          s              5  0
     D PERSET          s              4  0
     D REMAIN          s              2  0
     D SHDCNT          s              3  0
     D SSDCNT          s              3  0
     D SSOCUR          s              3  0
     D STPCNT          s              2  0
     D T#DESC          s             44
     D TEMP40          s             40
     D TENPOS          s              2  0
     D TMPZON          s                   like(PSSZON)
     D TODAY           s              8  0
     D TODESC          s             30
     D TOITEM          s             15
     D TOQTY           s              5  0
     D TOTWRD          s              3
     D TOUM            s              5
     D TTLCUB          s              8  3
     D TTLPCS          s              7  0
     D TTLWGT          s              9  2
     D WKIT11          s             11
     D WKIT15          s             15
     D WKTIME          s              5  2
     D W1CSE           s              5  0
     D W1CTIM          s              5  2
     D W1INVC          s              8
     D W1PAL#          s                   like(LBPAL#)
     D W1PICK          s                   like(LBQPCK)
     D W1QTY           s                   like(LBQPCK)
     D W1QTY2          s                   like(LBQPCK)
     D W1SEC           s              1
     D W1SLT           s              5  0
     D W1STIM          s              5  2
     D W1WDS           s              9
     D W1WHDP          s              5
     D W1WHS           s              3  0
     D W1WHSE          s              3
     D X1              s              3  0
     D Y1              s              3  0
     D ZONTYP          s              5
     D ZPDCNT          s              3  0
     D ZPIKUP          s              1
     D ZPOCUR          s              3  0
520hAD kycod1          s                   like(opzcod)
520iAD kycod3          s                   like(opzcod)
520iAD kycod4          s                   like(opzcod)
530 AD $ptmpl          s             10
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Command
     *              *TEST1   -  Print test labels - no merge.
     *              *TEST2   -  Print test labels - merge sample data.
     *              *REPLEN  -  Print potential replenishments.
     *      $PLSET  Label set
     *      $PLFMT  Label format (used for testing)
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
     C     *ENTRY        PLIST
     C                   PARM                    $PCMD             8
     C                   PARM                    $PLSET            6
     C                   PARM                    $PLFMT            8
     C                   PARM                    $PWHSE            3 0
     C                   PARM                    $PRTID            5
     C                   PARM                    $PCOMP            1
     C                   PARM                    $PTZON            6
     C                   PARM                    $PGEN             1 0
     C                   PARM                    $PSZON            6
     C                   PARM                    $PTRUK           10
     C                   PARM                    $PRTE             5
     C                   PARM                    OPZDTA
     C                   PARM                    $PTRN#            7 0
     *----------------------------------------------------------------
     *  Main line

610 A*
610 A*  Get zone options.
610 A*

610 A*  PCKLBL
610 AC                   eval      opdta2 = opzdta
610 A*
610 AC                   eval      kycod1 = '*PICK   '
610 AC                   eval      opptyp = *blanks
610 AC     opzkey        chain     optionz
610 AC                   if        %found(optionz)
610 AC                   eval      opdta1 = opzdta
610 AC                   endif
610 A*
610 AC                   eval      opdta3 = *blanks
610 AC                   eval      kycod3 = '*PICKLBA'
610 AC     opzkya        chain     optionz
610 AC                   if        %found(optionz)
610 AC                   eval      opdta3 = opzdta
610 AC                   endif
610 A*
610 A* do not print standard pick labels
610 A*
610 AC                   if        oplb1 = 'N'
610 AC                   goto      bottom
610 AC                   endif
610 A*
610 AC                   eval      kycod4 = '*PICKLBB'
610 AC                   eval      opdta4 = *blanks
610 AC     opzkyb        chain     optionz
610 AC                   if        %found(optionz)
610 AC                   eval      opdta4 = opzdta
610 AC                   endif
     *
     * Set number of detail lines on summary labels.
     *
TLA  C                   Z-ADD     7             SHDCNT
TLA  C                   Z-ADD     10            SSDCNT
TLA  C                   Z-ADD     10            ZPDCNT
     *
     * Check to see if this is only a test.
     *
     C                   IF        $PCMD = '*TEST1  '  or
     C                             $PCMD = '*TEST2  '
     C                   EXSR      TEST1
     C                   GOTO      BOTTOM
     C                   ENDIF
     *
     * Print zone heading label.
     *
610bAC                   IF        $PCMD <> '*PRNTJIT'
     C                   EXSR      LBLZHD
610b C                   ENDIF
     *
610bA* Print JIT potential replenishments
610bA*
610bAC                   IF        $PCMD = '*PRNTJIT'
610b C*                  IF        OPLETD = 'Y'
610b C                   EXSR      PRTJIT
610b C*                  ENDIF
610b C                   GOTO      BOTTOM
610b C                   ENDIF
     *
     * Print potential replenishments
     *
     C                   IF        $PCMD = '*REPLEN '
     C                   IF        OPLETD = 'Y'
     C                   EXSR      PRTPRP
     C                   ENDIF
     C                   GOTO      BOTTOM
     C                   ENDIF
     *
     * Print letdowns for zone.
     *
     C                   IF        OPLETD = 'Y'
     C                   EXSR      PRTRPL
     C                   ENDIF
     *
     * Print bulk picks for zone.
     *
     C                   EXSR      PRTBLK
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
     C                   MOVE      *ON           FIRST
     *
     C                   MOVE      'O'           KYTYPE
     C     KEYPS3        SETLL     PLTSUM3
     C                   DOU       FOREVR <> FOREVR
     C     KEYPS3        READE     PLTSUM3                                79
     C                   IF        *IN79
     C                   LEAVE
     C                   ENDIF
     *
     *     Skip pallet if nothing was picked.
     *
     C                   IF        PSPCS = 0
     C                   ITER
     C                   ENDIF
416cA*
416cA*     Skip pallet if tran# = 0 and pallet contains bulk pick.
416cA*     In that case we assume that the pallet only contains a
416cA*     bulk pick and was not assigned a tran# in OR630.
416cA*
416cAC                   IF        PSTRN# = 0  and
416cAC                             PSBCNT <> 0
416cAC                   ITER
416cAC                   ENDIF
     *
     *     First time through initialization.
     *
     C                   IF        FIRST = *ON
     C                   Z-ADD     PSTRN#        LSTTRN
     C                   Z-ADD     0             PALCNT
     C                   MOVE      *OFF          FIRST
     C                   ENDIF
     *
     *     If transaction number changed, go and print the detail
     *       for the previous transaction (LSTTRN).
     *
     C                   IF        PSTRN# <> LSTTRN
     *
ALNeA*     Get dock door for the transaction.
ALNeA*
ALNeAC                   Z-ADD     PSWHSE        $LWHSE
ALNeAC                   MOVE      PSRTID        $LRTID
ALNeAC                   Z-ADD     LSTTRN        $LTRN#
ALNeAC                   MOVE      *BLANKS       $LWHDP
ALNeAC                   Z-ADD     0             $LDOOR
ALNeAC                   CALL      'DH900'
ALNeAC                   PARM                    $LPARM
     C                   Z-ADD     PSUNLD        CURUNL
     C                   Z-ADD     PSROW         CURROW
     C                   Z-ADD     PSCOL         CURCOL
     C                   EXSR      PRTSEL
     C     KEYPS         SETLL     PLTSUM3
     C                   READ      PLTSUM3                                79
     C                   Z-ADD     PSTRN#        LSTTRN
     C                   Z-ADD     0             PALCNT
     C                   ENDIF
     *
     *     Add pallet info to pallet summary data structure.
     *
     C                   ADD       1             PALCNT
     C     PALCNT        OCCUR     PALSUM
     C                   Z-ADD     PSPAL#        DSPPAL
     C                   Z-ADD     PSCUBE        DSPCUB
     C                   Z-ADD     PSSWGT        DSPWGT
     C                   Z-ADD     PSPCS         DSPPCS
     C                   Z-ADD     0             DSPSTP
     C                   Z-SUB     1             LSTSTP
     C                   Z-ADD     PSPLID        DSPPLI
ALN AC                   MOVE      PSRTID        DSPRTI
     C     KEYSS1        SETLL     PLTSTP1
     C                   DOW       FOREVR = FOREVR
     C     KEYSS1        READE     PLTSTP1                                78
     C                   IF        *IN78
     C                   LEAVE
     C                   ENDIF
     C                   IF        PSSSTP <> LSTSTP
     C                   ADD       1             DSPSTP
     C                   Z-ADD     PSSSTP        LSTSTP
     C                   ENDIF
     C                   ENDDO
     *
     C                   ENDDO
     *
     *   Print last pallet(s), if any.
     *
     C                   IF        PALCNT > 0
     *
ALNeA*     Get dock door for the transaction.
ALNeA*
ALNeAC                   Z-ADD     $PWHSE        $LWHSE
ALNeAC                   MOVE      $PRTID        $LRTID
ALNeAC                   Z-ADD     LSTTRN        $LTRN#
ALNeAC                   MOVE      *BLANKS       $LWHDP
ALNeAC                   Z-ADD     0             $LDOOR
ALNeAC                   CALL      'DH900'
ALNeAC                   PARM                    $LPARM
     C                   EXSR      PRTSEL
     C                   ENDIF
     *
     *
     *   Bye, Bye.
     *
     C     BOTTOM        TAG
     C                   MOVE      *ON           *INLR
     *
     *   Close up shop and return home.
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *INZSR        BEGSR
     *
     C                   MOVE      *OFF          FOREVR
ALNhAC                   MOVE      *OFF          ZPIKUP
     C                   Z-ADD     75            MAXSTI
     C                   Z-ADD     198           MAXSTO
ALN AC                   MOVE      *BLANKS       W1INVC
     *
TLA  C                   MOVE      '/'           S1
TLA  C                   MOVE      '/'           S2
TLA  C                   MOVE      UMONTH        MM
TLA  C                   MOVE      UDAY          DD
TLA  C                   MOVE      UYEAR         YY
TLA2 C                   MOVE      '  1'         CMPN
TLA2 C                   MOVE      *BLANKS       ITMN
TLA2 C                   MOVE      *BLANKS       WKIT11
TLA2 C                   MOVE      *BLANKS       WKIT15
TLA2 C                   MOVE      *BLANKS       DIRCTN
610cA*
610cAC                   if        $pcmd = '*PRNTJIT'
610cAC                   clear                   stpsum
610cAC                   clear                   palsum
610cAC                   clear                   pirsum
610cAC                   clear                   zonpku
610cA*
610cAC                   clear                   mrgdta
610cAC                   clear                   mrgdt1
610cAC                   clear                   mrgdt2
610cAC                   clear                   mrgdt3
610cAC                   clear                   mrgdt4
610cAC                   endif
     *
TLA2 *  Define key for OPTIONS file.
 |   *
 |   C     FIITMKY       KLIST
 |   C                   KFLD                    CMPN
TLA2 C                   KFLD                    ITMN
     *
     *  Define key for OPTIONS file.
     *
     C     OPKEY         KLIST
     C                   KFLD                    OPWHSE
     C                   KFLD                    OPCODE
     *
     *  Define partial key for PLTSUM3 file.
     *
     C     KEYPS3        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTID
     C                   KFLD                    KYTYPE
     C                   KFLD                    $PCOMP
     C                   KFLD                    $PTZON
     C                   KFLD                    $PGEN
     C                   KFLD                    $PSZON
     *
     C     KEYPS         KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTID
     C                   KFLD                    KYTYPE
     C                   KFLD                    $PCOMP
     C                   KFLD                    $PTZON
     C                   KFLD                    $PGEN
     C                   KFLD                    $PSZON
     C                   KFLD                    CURUNL
     C                   KFLD                    CURROW
     C                   KFLD                    CURCOL
     *
     *  Define partial key for PLTSTP1 file.
     *
     C     KEYSS1        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTID
     C                   KFLD                    PSPLID
     C                   KFLD                    PSROW
     C                   KFLD                    PSCOL
     *
     *  Define partial key for LABEL31 file.
     *
     C     KEYL31        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTID
     C                   KFLD                    KYLTYP
     C                   KFLD                    PSPLID
     *
     *  Define partial key for LABEL32 & LABEL34 file.
     *
     C     KEYL32        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTID
     C                   KFLD                    KYLTYP
     C                   KFLD                    LSTTRN
     *
     *  Define partial key for LABEL33 file.
     *
     C     KEYL33        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PRTID
     C                   KFLD                    LSTTRN
     *
     *  Define partial key for LABEL3 file.
     *
     C     KEYL3F        KLIST
     C                   KFLD                    $PTRN#
     C                   KFLD                    $PWHSE
     *
     *  Define key for PIRITEM file. (FOR BROKEN CASE ITEM)
     *
     C     KEYIB         KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    LBITEM
     *
     *  Define key for PIRITEM file. (FOR LINK ITEM)
     *
     C     KEYIT         KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    ILITM2
     *
     *  Define key for PIRITEM and ITEMLNK file.
     *
     C     KEYIL         KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    LBITEM
     *
ALNaA*  Define key for ITEMDSC file.
     *
ALNaAC     KEYIX         KLIST
ALNaAC                   KFLD                    $PWHSE
ALNaAC                   KFLD                    LBITEM
     *
610bA*  Define key for PRPLFIL file.
     *
610bAC     KEYPR         KLIST
610bAC                   KFLD                    $PWHSE
610bAC                   KFLD                    KYWHDP
610bAC                   KFLD                    KYSEQ#
     *
ANLdA*  Define key for STDTIME file.
     *
ALNdAC     KEYST         KLIST
ALNdAC                   KFLD                    W1WHS
ALNdAC                   KFLD                    W1WHDP
ALNdAC                   KFLD                    W1SEC
     *
ALNiA*  Define key for ITEM file.
     *
ALNiAC     ITKEY         KLIST
ALNiAC                   KFLD                    LBWHSE
ALNiAC                   KFLD                    LBITEM
610 A*
610 A*  Define key for pick options.
610 A*
610 AC     opzkey        klist
610 AC                   kfld                    kycod1
610 AC                   kfld                    $pwhse
610 AC                   kfld                    $ptmpl
610 AC                   kfld                    $pszon
610 A*
610 AC     opzkya        klist
610 AC                   kfld                    kycod3
610 AC                   kfld                    $pwhse
610 AC                   kfld                    $ptmpl
610 AC                   kfld                    $pszon
     *
610 AC     opzkyb        klist
610 AC                   kfld                    kycod4
610 AC                   kfld                    $pwhse
610 AC                   kfld                    $ptmpl
610 AC                   kfld                    $pszon
610 A*
610 A*  Define key for TRUCKH file.
610 A*
610 AC     trkey         klist
610 AC                   kfld                    $pwhse
610 AC                   kfld                    $ptruk
     *
     *
     *  Convert today's date into century format.
     *
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        TODAY
     *
     *   Define variables.
     *
     *
     *  Get system options.
     *
     C                   Z-ADD     0             OPWHSE
     C                   MOVE      '*SYSTEM '    OPCODE
     C     OPKEY         CHAIN     OPTIONS                            79
     C                   IF        *IN79
     C                   MOVE      'Y'           OPLETD
     C                   ENDIF
610 A*
610 A* Get Zone Template Code if Template type is T=Truck
610 A*
610 AC     trkey         chain     truckh
610 AC                   if        %found(truckh) and thtype = 'T'
610 AC                   eval      $ptmpl =  thztmp
610 AC                   else
610 AC                   eval      $ptmpl =  $ptruk
610 AC                   endif
     *
     C                   ENDSR
     *
TLA  *--------------------------------------------------------------
TLA  C     TLAPRT        BEGSR
TLA  *--------------------------------------------------------------
 ||  C                   MOVEL     'LABEL'       LBLDEV
 \/  C                   Z-ADD     1             ACROSS
     C                   Z-ADD     1             LBLQTY
     C                   MOVE      'N'           DEMAND
     C                   Z-ADD     1             PERSET
     *
     C                   IF        LBLNAM = 'SETHED  '
     C                   CALL      'SATO4096'
     C                   PARM                    LBLNAM
     C                   PARM                    ACROSS
     C                   PARM                    LBLDEV
     C                   PARM                    LBLQTY
     C                   PARM                    DEMAND
     C                   PARM                    MRGDT1
     C                   PARM                    PERSET
     C                   GOTO      TLAOUT
     C                   ENDIF
     *
     C                   IF        LBLNAM = 'SETSUM  '
     C                   CALL      'SATO4096'
     C                   PARM                    LBLNAM
     C                   PARM                    ACROSS
     C                   PARM                    LBLDEV
     C                   PARM                    LBLQTY
     C                   PARM                    DEMAND
     C                   PARM                    MRGDT2
     C                   PARM                    PERSET
     C                   GOTO      TLAOUT
     C                   ENDIF
     *
     C                   IF        LBLNAM = 'ZONPKUP '
     C                   CALL      'SATO4096'
     C                   PARM                    LBLNAM
     C                   PARM                    ACROSS
     C                   PARM                    LBLDEV
     C                   PARM                    LBLQTY
     C                   PARM                    DEMAND
     C                   PARM                    MRGDT3
     C                   PARM                    PERSET
     C                   GOTO      TLAOUT
     C                   ENDIF
     *
     C                   IF        LBLNAM = 'SETHEDAL'  or
     C                             LBLNAM = 'WLBULKAL'  or
     C                             LBLNAM = 'WLPICKAL'
     C                   CALL      'SATO4096'
     C                   PARM                    LBLNAM
     C                   PARM                    ACROSS
     C                   PARM                    LBLDEV
     C                   PARM                    LBLQTY
     C                   PARM                    DEMAND
     C                   PARM                    MRGDT4
     C                   PARM                    PERSET
     C                   GOTO      TLAOUT
     C                   ENDIF
     *
     C                   CALL      'SATO4096'
     C                   PARM                    LBLNAM
     C                   PARM                    ACROSS
     C                   PARM                    LBLDEV
     C                   PARM                    LBLQTY
     C                   PARM                    DEMAND
     C                   PARM                    MRGDTA
 /\  C                   PARM                    PERSET
 ||  *
 /\  C     TLAOUT        ENDSR
TLA  *--------------------------------------------------------------
     *
     *  CRTSTP  Create stop numbers.
     C     CRTSTP        BEGSR
     *
     *  Seperate characters.
     *
     C     LBSTOP        DIV       10            NUM1
     C                   MVR                     NUM2
     *
     *  Build first character if not zero.
     *
     C                   CALL      'BIGNUM'
     C                   PARM      '*MB     '    $BNCOD            8
     C                   PARM                    NUM1
     C                   PARM                    CH1
     *
     *  Build second character.
     *
     C                   CALL      'BIGNUM'
     C                   PARM      '*MB     '    $BNCOD
     C                   PARM                    NUM2
     C                   PARM                    CH2
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  EDITNA  Edit numeric to alpha.
     *
     C     EDITNA        BEGSR
     C                   MOVE      *BLANK        A40
     C     $NANUM        CABEQ     0             ENA01
     C                   MOVE      *BLANKS       TEMP40
     C                   MOVEL     $NANUM        TEMP40
     C                   MOVEA     TEMP40        A40
     C     12            SUB       $NADEC        DPOS
     C     DPOS          ADD       2             TENPOS
     C                   Z-ADD     12            AX
     C                   Z-ADD     40            AY
     C     LNA01         TAG
     C                   SUB       1             AX
     C     AX            CABEQ     0             ENA01
     C                   IF        AX < TENPOS
     C                   MOVE      A40(AX)       A40(AY)
     C                   SUB       1             AY
     C                   ELSE
     C                   IF        A40(AX) > '0'
     C                   MOVE      A40(AX)       A40(AY)
     C                   SUB       1             AY
     C                   Z-ADD     99            TENPOS
     C                   ENDIF
     C                   ENDIF
     C                   IF        AX = DPOS
     C                   MOVE      '.'           A40(AY)
     C                   SUB       1             AY
     C                   ENDIF
     C                   GOTO      LNA01
     C     ENA01         TAG
     C                   Z-ADD     28            AX
     C     LNA02         TAG
     C                   ADD       1             AX
     C     AX            COMP      41                                     50
     C   50              GOTO      ENA02
     C     A40(AX)       COMP      '0'                                    50
     C  N50A40(AX)       COMP      ' '                                    50
     C  N50              GOTO      ENA02
     C                   MOVE      ' '           A40(AX)
     C                   GOTO      LNA02
     C     ENA02         TAG
     *
     C                   MOVEA     A40(29)       A12
     C                   IF        AX > 40
     C                   Z-ADD     12            $NAFP
     C                   ELSE
     C     AX            SUB       28            $NAFP
     C                   ENDIF
     *
     C                   Z-ADD     0             $NANUM
     C                   Z-ADD     0             $NADEC
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  GETPAL  Get pallet number.
     *
     C     GETPAL        BEGSR
     C                   Z-ADD     0             PAL#
     C     1             DO        PALCNT        CURPAL
     C     CURPAL        OCCUR     PALSUM
     C                   IF        DSPPLI = LBPAL#
     C                   Z-ADD     DSPPAL        PAL#
     C                   ENDIF
     C                   ENDDO
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  INITSS  Initialize data structure for stop summary
     *
     C     INITSS        BEGSR
     C     1             DO        SSDCNT        SSOCUR
     C     SSOCUR        OCCUR     STPSUM
     C                   Z-ADD     0             DSSSTP
     C                   Z-ADD     0             DSSPCS
     C                   Z-ADD     0             DSSCUB
     C                   Z-ADD     0             DSSWGT
     C                   MOVE      *BLANKS       DSSCNM
     C                   ENDDO
     C                   Z-ADD     1             SSOCUR
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  INITZP  Initialize data structure for zone pickup
     *
     C     INITZP        BEGSR
     C     1             DO        ZPDCNT        ZPOCUR
     C     ZPOCUR        OCCUR     ZONPKU
     C                   Z-ADD     0             DSZSTP
     C                   Z-ADD     0             DSZPCS
     C                   MOVE      *BLANKS       DSZITM
     C                   MOVE      *BLANKS       DSZDSC
     C                   Z-ADD     0             DSZPLT
     C                   ENDDO
     C                   Z-ADD     1             ZPOCUR
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  PRTBLK  Print bulk pick labels for route/department.
     *
     C     PRTBLK        BEGSR
     *
     C                   MOVE      *ON           FIRST
     *
     *  Loop bulk picks for zone.
     *
     *    Revised to only use a pallet id once.
     *
     C                   Z-SUB     1             LSTPID
     C                   MOVE      'B'           KYTYPE
     C     KEYPS3        SETLL     PLTSUM3
     C                   DOU       FOREVR <> FOREVR
     C     KEYPS3        READE     PLTSUM3                                79
     C                   IF        *IN79
     C                   LEAVE
     C                   ENDIF
     C                   IF        PSPLID = LSTPID
     C                   ITER
     C                   ENDIF
     C                   Z-ADD     PSPLID        LSTPID
     *
ALNeA*     Get dock door for the transaction.
ALNeA*
ALNeAC                   Z-ADD     PSWHSE        $LWHSE
ALNeAC                   MOVE      PSRTID        $LRTID
ALNeAC                   Z-ADD     PSTRN#        $LTRN#
ALNeAC                   MOVE      *BLANKS       $LWHDP
ALNeAC                   Z-ADD     0             $LDOOR
ALNeAC                   CALL      'DH900'
ALNeAC                   PARM                    $LPARM
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
     C                   Z-SUB     1             LSTLB#
     C                   MOVE      'B'           KYLTYP
     C     KEYL31        SETLL     LABEL31
     *
     C                   DOU       FOREVR <> FOREVR
     *
     C     KEYL31        READE     LABEL31                                78
     C                   IF        *IN78
     C                   LEAVE
     C                   ENDIF
     C                   IF        LBLBL# = LSTLB#
     C                   ITER
     C                   ENDIF
     C                   Z-ADD     LBLBL#        LSTLB#
     *
     *       Skip label if nothing was picked.
     *
     C                   IF        LBQPCK = 0
     C                   ITER
     C                   ENDIF
     *
     *       Print beginning bulk pick label.
     *
     C                   IF        FIRST = *ON
     C                   EXSR      LBLBBK
     C                   MOVE      *OFF          FIRST
     C                   ENDIF
     *
ALNaA*  Get extended description
     *
ALNaAC                   MOVE      *BLANKS       T#DESC
ALNaAC     KEYIX         CHAIN     ITEMDSC                            79
ALNaAC                   IF        not *IN79
ALNaAC                   MOVEL     IXDSC1        T#DESC
ALNaAC     T#DESC        CAT       IXDSC2:1      T#DESC
ALNaAC                   ENDIF
     *
     *       Print warning for bulk/replenishment combo.
     *
     *
     *       Print bulk label.
     *
     C                   Z-ADD     LBQPCK        W1QTY
     C                   EXSR      CRTSTP
     C                   EXSR      LBLBLK
     *
     *       Print replenishment label if necessary.
     *
     C                   IF        LBDSP2 <> *BLANKS
     C                   Z-ADD     LBQRMN        W1QTY
     C                   EXSR      LBLRP1
     C                   ENDIF
416dA*
416dA*     Print catch weight labels.
416dA*
416dAC                   IF        ITCWGT = 'Y'  and
416dAC                             OPCWGT <> 0
416dAC     LBQPCK        DIV       OPCWGT        LBLS
416dAC                   MVR                     REMAIN
416dAC                   IF        REMAIN <> 0
416dAC                   ADD       1             LBLS
416dAC                   ENDIF
416dAC     1             DO        LBLS
416dA***                  WRITECATCHWGT
416dAC                   EXSR      LBLCWT
416dAC                   ENDDO
416dAC                   ENDIF
     *
     C                   ENDDO
     *
     C                   ENDDO
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
610b *  PRTJIT  Print JIT replenishment labels.
     *
610b C     PRTJIT        BEGSR
610b *
610b C***                MOVE      *ON           FIRST
610b C                   Z-ADD     $PTRN#        kyseq#
610b C                   movel     $pszon        kywhdp
610b *
610b *    Chain to get JIT potential replenishment.
610b *
610bAC     keypr         chain     prplfil1
610bAC                   if        %found(prplfil1)
610b *
610b *       Print "Beginning Replenishment" pick label.
610b *
610b C**                 IF        FIRST = *ON
610b C**                 EXSR      LBLBRP
610b C**                 MOVE      *OFF          FIRST
610b C**                 ENDIF
610b *
610b *       Print JIT replenishment label.
610b *
610b C                   Z-ADD     PRQTY         W1QTY
610b C                   eval      lbitem = pritem
610b C     KEYIL         CHAIN     PIRITEM                            79
610b C                   IF        PRTYPE = 'B'
610b C                   MOVE      PRITEM        TOITEM
610b C                   MOVE      ITDESC        TODESC
610b C     KEYIL         CHAIN     ITEMLNK                            79
610b C                   MOVE      ILITM2        FRITEM
610b C     KEYIT         CHAIN     PIRITEM                            79
610b C                   MOVE      ITDESC        FRDESC
610b C                   Z-ADD     ITUMQ2        TOQTY
610b C                   MOVE      ITUM2         TOUM
610b C                   EXSR      LBLRP4
610b C                   ELSE
610b C                   EXSR      LBLRP3
610b C                   ENDIF
610b *
610b C                   ENDIF
610b *
610b C                   ENDSR
     *----------------------------------------------------------------
     *
     *  PRTPRP  Print potential replenishment labels.
     *
     C     PRTPRP        BEGSR
     *
     C                   MOVE      *ON           FIRST
     *
     *    Loop through potential replenishment batch of labels.
     *
     C     KEYL3F        SETLL     LABEL3
     *
     C                   DOU       FOREVR <> FOREVR
     *
     C     KEYL3F        READE     LABEL3                                 78
     C                   IF        *IN78
     C                   LEAVE
     C                   ENDIF
     *
     *       Skip label if nothing was picked.
     *
     C                   IF        LBQPCK = 0
     C                   ITER
     C                   ENDIF
     *
     *       Skip label if closed.
     *
     C                   IF        LBSTAT = 'C'
     C                   ITER
     C                   ENDIF
     *
     *       Print "Beginning Replenishment" pick label.
     *
     C                   IF        FIRST = *ON
     C                   EXSR      LBLBRP
     C                   MOVE      *OFF          FIRST
     C                   ENDIF
     *
     *       Print replenishment label if necessary.
     *
     C                   Z-ADD     LBQPCK        W1QTY
     C                   IF        ITTYPE = 'B'
     C                   MOVE      LBITEM        TOITEM
     C                   MOVE      ITDESC        TODESC
     C     KEYIL         CHAIN     ITEMLNK                            79
     C                   MOVE      ILITM2        FRITEM
     C     KEYIT         CHAIN     PIRITEM                            79
     C                   MOVE      ITDESC        FRDESC
     C                   Z-ADD     ITUMQ2        TOQTY
     C                   MOVE      ITUM2         TOUM
     C                   EXSR      LBLRP2
     C                   ELSE
     C                   EXSR      LBLRP1
     C                   ENDIF
     *
     C                   ENDDO
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  PRTRPL  Print replenishment labels for zone
     *
     C     PRTRPL        BEGSR
     *
     C                   MOVE      *ON           FIRST
     *
     *  Loop through pallets for zone.
     *
     C                   MOVE      'O'           KYTYPE
     C     KEYPS3        SETLL     PLTSUM3
     C                   DOU       FOREVR <> FOREVR
     C     KEYPS3        READE     PLTSUM3                                79
     C                   IF        *IN79
     C                   LEAVE
     C                   ENDIF
     *
     *    Loop through replenishment labels for pallet.
     *
     C                   MOVE      'R'           KYLTYP
     C     KEYL31        SETLL     LABEL31
     *
     C                   DOU       FOREVR <> FOREVR
     *
     C     KEYL31        READE     LABEL31                                78
     C                   IF        *IN78
     C                   LEAVE
     C                   ENDIF
     *
     *       Skip label if nothing was picked.
     *
     C                   IF        LBQPCK = 0
     C                   ITER
     C                   ENDIF
     *
     *       Print "Beginning Replenishment" pick label.
     *
     C                   IF        FIRST = *ON
     C                   EXSR      LBLBRP
     C                   MOVE      *OFF          FIRST
     C                   ENDIF
     *
     *       Print replenishment label if necessary.
     *
     C                   Z-ADD     LBQPCK        W1QTY
     C                   IF        ITTYPE = 'B'
     C                   MOVE      LBITEM        TOITEM
     C                   MOVE      ITDESC        TODESC
     C     KEYIL         CHAIN     ITEMLNK                            79
     C                   MOVE      ILITM2        FRITEM
     C     KEYIT         CHAIN     PIRITEM                            79
     C                   MOVE      ITDESC        FRDESC
     C                   Z-ADD     ITUMQ2        TOQTY
     C                   MOVE      ITUM2         TOUM
     C                   EXSR      LBLRP2
     C                   ELSE
     C                   EXSR      LBLRP1
     C                   ENDIF
     *
     C                   ENDDO
     *
     C                   ENDDO
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  PRTSEL  Print normal selection labels for zone.
     *
     C     PRTSEL        BEGSR
     *
     *   Print header for this set of selection labels.
     *
     C                   EXSR      SETBEG
     *
     *   Loop through selection labels for transaction.
     *
     C                   Z-ADD     0             COUNT
     C                   MOVE      'O'           KYLTYP
     C                   IF        $PGEN = 1
TLAe C     KEYL32        SETLL     LABEL32C
TLAe *    KEYL32        SETLL     LABEL32
     C                   ELSE
TLAe *    KEYL32        SETLL     LABEL32
TLAe C     KEYL32        SETLL     LABEL32C
     C                   ENDIF
     *
     C                   DOU       FOREVR <> FOREVR
     C                   IF        $PGEN = 1
TLAe *    KEYL32        READE     LABEL32                                78
TLAe C     KEYL32        READE     LABEL32C                               78
     C                   ELSE
TLAe *    KEYL32        READE     LABEL32                                78
TLAe C     KEYL32        READE     LABEL32C                               78
     C                   ENDIF
     C                   IF        *IN78
     C                   LEAVE
     C                   ENDIF
     *
     *     Skip label if cross dock.
     *
     C                   IF        LBSTYP = 'X'
     C                   ITER
     C                   ENDIF
     *
     *     Skip label if nothing was picked.
     *
     C                   IF        LBQPCK = 0
     C                   ITER
     C                   ENDIF
     *
     C                   ADD       1             COUNT
     *
     *     See if we should print the "before" um warning.
     *
     *
ALNaA*  Get extended description
     *
ALNaAC                   MOVE      *BLANKS       T#DESC
ALNaAC     KEYIX         CHAIN     ITEMDSC                            79
ALNaAC                   IF        not *IN79
ALNaAC                   MOVEL     IXDSC1        T#DESC
ALNaAC     T#DESC        CAT       IXDSC2:1      T#DESC
ALNaAC                   ENDIF
     *
     *     Initialize label fields.
     *
     C                   Z-ADD     LBQPCK        W1QTY2
     C                   EXSR      CRTSTP
     *
ALN AC     KEYIL         CHAIN     PIRITEM                            79
ALN AC                   IF        *IN79
ALN AC                   MOVE      *BLANKS       ITVIT#
ALN AC                   ENDIF
     *
     *     Either print a combination label ...
     *
     C                   SELECT
     C                   WHEN      LBQPCK >= OPCLVL
     C                   MOVE      *ON           COMBO
     *
     *        See if we should print the "before" combo warning.
     *
     C                   IF        OPCWRB = 'Y'
     C                   EXSR      LBLCMB
     C                   ENDIF
     *
     *        Print one label.
     *
     C                   Z-ADD     LBQPCK        W1PICK
     C                   EXSR      LBLPCK
     *
     *        See if we should print the "after" combo warning.
     *
     C                   IF        OPCWRA = 'Y'
     C                   EXSR      LBLCMA
     C                   ENDIF
     *
     C                   OTHER
     *
     *     Or print individual labels.
     *
     C                   MOVE      *OFF          COMBO
     C     1             DO        LBQPCK        W1PICK
     *     See if we should print the "before" um warning.
ALN AC                   IF        LBUTYP <> 'N'  and
ALN AC                             OPUWRB = 'Y'
ALN AC                   EXSR      LBLUMB
ALN AC                   ENDIF
     *
     C                   EXSR      LBLPCK
     *     See if we should print the "after" um warning.
ALN AC                   IF        LBUTYP <> 'N'  and
ALN AC                             OPUWRA = 'Y'
ALN AC                   EXSR      LBLUMA
ALN AC                   ENDIF
     *
     C                   ENDDO
     *
     C                   ENDSL
     *
     *     See if we should print the "after" um warning.
     *
     *     Print catch weight labels.
     *
     C                   IF        ITCWGT = 'Y'  and
     C                             OPCWGT <> 0
     C     LBQPCK        DIV       OPCWGT        LBLS
     C                   MVR                     REMAIN
     C                   IF        REMAIN <> 0
     C                   ADD       1             LBLS
     C                   ENDIF
     C     1             DO        LBLS
     C                   EXSR      LBLCWT
     C                   ENDDO
     C                   ENDIF
     *
ALNhAC                   IF        ITCWGT = 'Y'
ALNhAC     LBQPCK        MULT      .083          WKTIME
ALNhAC                   ADD       WKTIME        CWTIME
ALNhAC                   ENDIF
ALNdAC                   EXSR      ZZATTL
     *
     C                   ENDDO
     *
     *   Print summary for this set of selection labels.
     *
     C                   EXSR      SETEND
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  PRTXDK  Print cross dock labels.
     *
     C     PRTXDK        BEGSR
     *
     *
     *   Loop through selection labels for transaction.
     *
     C                   Z-ADD     0             COUNT
     C                   MOVE      'O'           KYLTYP
     *
     C                   IF        $PGEN = 1
     C     KEYL32        SETLL     LABEL32
     C                   ELSE
     C     KEYL32        SETLL     LABEL32
     C                   ENDIF
     *
     C                   DOU       FOREVR <> FOREVR
     C                   IF        $PGEN = 1
     C     KEYL32        READE     LABEL32                                78
     C                   ELSE
     C     KEYL32        READE     LABEL32                                78
     C                   ENDIF
     C                   IF        *IN78
     C                   LEAVE
     C                   ENDIF
     *
     *
     *     Skip label if not cross dock.
     *
     C                   IF        LBSTYP <> 'X'
     C                   ITER
     C                   ENDIF
     *
     *     Skip label if nothing was picked.
     *
     C                   IF        LBQPCK = 0
     C                   ITER
     C                   ENDIF
     *
     C                   ADD       1             COUNT
     *
ALNaA*  Get extended description
     *
ALNaAC                   MOVE      *BLANKS       T#DESC
ALNaAC     KEYIX         CHAIN     ITEMDSC                            79
ALNaAC                   IF        not *IN79
ALNaAC                   MOVEL     IXDSC1        T#DESC
ALNaAC     T#DESC        CAT       IXDSC2:1      T#DESC
ALNaAC                   ENDIF
     *
     *   Print warning "Cross dock labels next".
     *
     C                   IF        COUNT = 1
     C                   EXSR      LBLXDB
     C                   ENDIF
     *
     *     See if we should print the "before" um warning.
     *
     C                   IF        LBUTYP <> 'N'  and
     C                             OPUWRB = 'Y'
     C                   EXSR      LBLUMB
     C                   ENDIF
     *
     *     Initialize label fields.
     *
     C                   Z-ADD     LBQPCK        W1QTY2
     C                   EXSR      CRTSTP
     *
     *     Either print a combination label ...
     *
     C                   SELECT
     C                   WHEN      LBQPCK >= OPCLVL
     C                   MOVE      *ON           COMBO
     *
     *        See if we should print the "before" combo warning.
     *
     C                   IF        OPCWRB = 'Y'
     C                   EXSR      LBLCMB
     C                   ENDIF
     *
     *        Print one label.
     *
     C                   Z-ADD     LBQPCK        W1PICK
     C                   EXSR      LBLPCK
     *
     *        See if we should print the "after" combo warning.
     *
     C                   IF        OPCWRA = 'Y'
     C                   EXSR      LBLCMA
     C                   ENDIF
     *
     C                   OTHER
     *
     *     Or print individual labels.
     *
     C                   MOVE      *OFF          COMBO
     C     1             DO        LBQPCK        W1PICK
     C                   EXSR      LBLPCK
     C                   ENDDO
     *
     C                   ENDSL
     *
     *     See if we should print the "after" um warning.
     *
     C                   IF        LBUTYP <> 'N'  and
     C                             OPUWRA = 'Y'
     C                   EXSR      LBLUMA
     C                   ENDIF
     *
     *     Print catch weight labels.
     *
     C                   IF        ITCWGT = 'Y'  and
     C                             OPCWGT <> 0
     C     LBQPCK        DIV       OPCWGT        LBLS
     C                   MVR                     REMAIN
     C                   IF        REMAIN <> 0
     C                   ADD       1             LBLS
     C                   ENDIF
     C     1             DO        LBLS
     C                   EXSR      LBLCWT
     C                   ENDDO
     C                   ENDIF
     *
     C                   ENDDO
     *
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  SETBEG  Start new set of labels.
     *
     C     SETBEG        BEGSR
     *
     *   Print set header label.
     *
     C                   Z-ADD     LSTTRN        LBTRN#
     C                   EXSR      LBLSHD
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  SETEND  End set of labels.
     *
     C     SETEND        BEGSR
     *
     *   Print cross dock labels.
     *
     C                   EXSR      PRTXDK
     *
     *   Print discrepancy labels.
     *
     C                   IF        OPERR <> 0
     C     COUNT         DIV       OPERR         LBLS
     C                   MVR                     REMAIN
     C                   IF        REMAIN <> 0
     C                   ADD       1             LBLS
     C                   ENDIF
     C     1             DO        LBLS
     C                   EXSR      LBLDIS
     C                   ENDDO
     C                   ENDIF
     *
     *   Print merge summary(s) for transaction.
     *
     *     Loop through selection labels for transaction.
     *
     C                   MOVE      *ON           FIRST2
     C                   MOVE      'M'           KYLTYP
     *
     C                   IF        $PGEN = 1
     C     KEYL32        SETLL     LABEL32
     C                   ELSE
     C     KEYL32        SETLL     LABEL32
     C                   ENDIF
     *
     C                   DOU       FOREVR <> FOREVR
     C                   IF        $PGEN = 1
     C     KEYL32        READE     LABEL32                                78
     C                   ELSE
     C     KEYL32        READE     LABEL32                                78
     C                   ENDIF
     C                   IF        *IN78
     C                   LEAVE
     C                   ENDIF
     *
     *       Put together zone from label fields.
     *
     C                   MOVEL     LBWHDP        TMPZON
     C                   MOVE      LBSTYP        TMPZON
     *
     *       First time through initialization.
     *
     C                   IF        FIRST2 = *ON
     C                   EXSR      INITZP
     C     ZPOCUR        OCCUR     ZONPKU
     C                   MOVE      TMPZON        LSTZON
     C                   Z-ADD     LBSTOP        DSZSTP
     C                   EXSR      GETPAL
     C                   Z-ADD     PAL#          DSZPLT
     C                   EXSR      LBLZPH
     C                   MOVE      *OFF          FIRST2
     C                   ENDIF
     *
     C                   EXSR      GETPAL
     C                   Z-ADD     PAL#          W1PAL#
     *
     *       When zone changes, print summary totals.
     *
     C                   IF        TMPZON <> LSTZON
     C                   EXSR      LBLZPD
     C                   EXSR      INITZP
     C     ZPOCUR        OCCUR     ZONPKU
     C                   MOVE      TMPZON        LSTZON
     C                   EXSR      LBLZPH
     C                   ENDIF
     *
     *       Move information into data structure fields.
     *
     C                   MOVE      LBITEM        DSZITM
     C                   MOVE      ITDESC        DSZDSC
     C                   Z-ADD     LBQPCK        DSZPCS
     C                   MOVEL     OHCNAM        DSZCNM
     *
ALNhAC                   MOVE      *ON           ZPIKUP
ALNhAC                   EXSR      ZZATTL
ALNhAC                   MOVE      *OFF          ZPIKUP
     *
     *       Move to next data structure occurance.
     *       If we have reached the maximum number of summary detail
     *       lines, then print the label and continue on.
     *
     C                   EXSR      GETPAL
     C                   Z-ADD     PAL#          DSZPLT
     C                   Z-ADD     LBSTOP        DSZSTP
     C                   IF        ZPOCUR = ZPDCNT
     C                   EXSR      LBLZPD
     C                   EXSR      INITZP
     C                   ELSE
     C                   ADD       1             ZPOCUR
     C                   ENDIF
     C     ZPOCUR        OCCUR     ZONPKU
     *
     C                   ENDDO
     *
     *     Force printing of label.
     *
     C                   IF        ZPOCUR > 1
     C                   EXSR      LBLZPD
     C                   EXSR      INITZP
     C                   ENDIF
     *
     *
     *   Print set summary for transaction.
     *
ALNdA*   Calculate pick time for this transaction, and zero out totals
     *
ALNdAC                   EXSR      ZZCLCT
ALNdAC                   EXSR      ZZCLRA
     *
     *     Print header label.
     *
     C                   EXSR      LBLSSH
     *
     *     Loop through all labels for transaction.
     *
     C                   MOVE      *ON           FIRST2
     C     KEYL33        SETLL     LABEL33
     *
     C                   DOU       FOREVR <> FOREVR
     C     KEYL33        READE     LABEL33                                78
     C                   IF        *IN78
     C                   LEAVE
     C                   ENDIF
     *
     *       First time through initialization.
     *
     C                   IF        FIRST2 = *ON
     C                   EXSR      INITSS
     C     SSOCUR        OCCUR     STPSUM
     C                   Z-ADD     LBSTOP        DSSSTP
     C                   Z-ADD     0             TTLCUB
     C                   Z-ADD     0             TTLWGT
     C                   Z-ADD     0             TTLPCS
     C                   MOVE      *OFF          FIRST2
     C                   ENDIF
     *
     *       When stop changes, move to next data structure occurance.
     *       If we have reached the maximum number of summary detail
     *       lines, then print the label and continue on.
     *
     C                   IF        LBSTOP <> DSSSTP
     C                   ADD       DSSCUB        TTLCUB
     C                   ADD       DSSWGT        TTLWGT
     C                   ADD       DSSPCS        TTLPCS
     C                   IF        SSOCUR = SSDCNT
     C                   EXSR      LBLSSD
     C                   EXSR      INITSS
     C                   ELSE
     C                   ADD       1             SSOCUR
     C                   ENDIF
     C     SSOCUR        OCCUR     STPSUM
     C                   Z-ADD     LBSTOP        DSSSTP
     C                   ENDIF
     *
     *       Update summary amounts for stop.
     *
     C                   ADD       LBCUBE        DSSCUB
     C                   ADD       LBSWGT        DSSWGT
     C                   ADD       LBQPCK        DSSPCS
     C                   MOVEL     OHCNAM        DSSCNM
     *
     C                   ENDDO
     *
     *     Print last stop and totals.
     *
     C                   IF        FIRST2 = *OFF
     *
     *       Detail line.
     *
     C                   ADD       DSSCUB        TTLCUB
     C                   ADD       DSSWGT        TTLWGT
     C                   ADD       DSSPCS        TTLPCS
     C                   IF        SSOCUR = SSDCNT
     C                   EXSR      LBLSSD
     C                   EXSR      INITSS
     C                   ELSE
     C                   ADD       1             SSOCUR
     C                   ENDIF
     C     SSOCUR        OCCUR     STPSUM
     *
     *       Summary totals.
     *
     C                   Z-ADD     TTLCUB        DSSCUB
     C                   Z-ADD     TTLWGT        DSSWGT
     C                   Z-ADD     TTLPCS        DSSPCS
     C                   MOVEA     TTLDSC        DSSCNM
     C                   EXSR      LBLSSD
     C                   ENDIF
     *
     *
     *  End of transaction, force print.
     *
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *                       LABEL SUBROUTINES
     *
     *----------------------------------------------------------------
     *
     *  LBLBBK  Begin bulk picks
     *
     C     LBLBBK        BEGSR
     C                   IF        $PGEN = 1
     C                   MOVE      'Truck'       ZONTYP
     C                   ELSE
     C                   MOVE      'Stage'       ZONTYP
     C                   ENDIF
     *
TLA  C                   MOVE      LBTRN#        @@TRAN
TLA  C                   MOVEL     'BEGBLK  '    LBLNAM
TLA  C                   EXSR      TLAPRT
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLBRP  Begining of letdowm label.
     *
     C     LBLBRP        BEGSR
     C                   IF        $PGEN = 1
     C                   MOVE      'Truck'       ZONTYP
     C                   ELSE
     C                   MOVE      'Stage'       ZONTYP
     C                   ENDIF
     *
TLA  C                   MOVE      LBTRN#        @@TRAN
TLA  C                   MOVEL     'BEGRPL  '    LBLNAM
TLA  C                   EXSR      TLAPRT
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLBLK  Bulk pick labels.
     *
     C     LBLBLK        BEGSR
     C                   Z-ADD     0             STPCNT
     C                   Z-ADD     W1QTY         @QTY2
     C                   Z-ADD     PSPAL#        @PAL#
ALNaAC                   MOVEL     OHMISC        DSMISC
     *
     C                   IF        LBGRP2 <> 'W'
TLA  C                   MOVE      LBSTOP        @@STPN
TLA  C                   MOVE      LBTRN#        @@TRAN
TLA  C                   MOVE      LBDISP        @@SLTN
TLA  C                   MOVE      @QTY2         @@PICK
TLA  C                   MOVEL     UMSHRT        @@UOM
TLA  C                   MOVEL     ITPDSC        @@PKSZ
TLA  C                   MOVEL     T#DESC        @@IDE1
TLA  C                   MOVEL     LBITEM        @@ITMN
TLA  C                   MOVE      OHCORD        @@ORDN
TLA  C                   MOVE      OHCUST        @@CUSN
TLA  C                   MOVE      DATE8         @@DTES
TLA  C                   MOVEL     OHCNAM        @@CNAM
TLA  C                   MOVE      @PAL#         @@PALT
TLA  C                   MOVEL     $PRTE         @@RTEN
TLA  C                   MOVEL     OUTWRD        @@OUT
TLA  C                   MOVE      LBLBL#        @@LBLN
TLA  C                   MOVEL     DSWSEQ        @@WCSQ
TLA  C                   MOVEL     DSINVC        @@AINV
TLA  C                   MOVE      LBSEQ         @@OSEQ
TLA2 *                    MOVELITVIT#    @@NVIT           * BFC 97
 |   C                   MOVE      '*RIGHT  '    DIRCTN
 |   C                   MOVE      LBITEM        WKIT15
 |   C                   EXSR      ZZLTRT
 |   C                   MOVE      WKIT11        ITMN
 |   C     FIITMKY       CHAIN     FIITMAL0                           69
 |   C                   IF        *IN69 = *OFF
 |   C                   MOVEL     FIUPCN        @@NVIT
TLA2 C                   ENDIF
TLA  C                   MOVE      $LDOOR        @@DDOR
TLA  C                   MOVE      'BULK    '    LBLNAM
TLA  C                   EXSR      TLAPRT
     C                   ENDIF
     *
     C                   IF        LBGRP2 = 'W'
TLA  C                   MOVE      LBTRN#        D4TRAN
TLA  C                   MOVE      LBDISP        D4SLTN
TLA  C                   MOVE      @QTY2         D4PICK
TLA  C                   MOVEL     UMSHRT        D4UOM
TLA  C                   MOVEL     ITPDSC        D4PKSZ
TLA  C                   MOVEL     T#DESC        D4IDE1
TLA  C                   MOVEL     LBITEM        D4ITMN
TLA  C                   MOVE      OHCUST        D4CUSN
TLA  C                   MOVE      DATE8         D4DTES
TLA  C                   MOVEL     OHCNAM        D4CNAM
TLA  C                   MOVE      @PAL#         D4PALT
TLA  C                   MOVEL     $PRTE         D4RTEN
TLA  C                   MOVEL     OUTWRD        D4OUT
TLA  C                   MOVE      LBLBL#        D4LBLN
TLA  C                   MOVEL     DSWSEQ        D4WCSQ
TLA  C                   MOVEL     DSINVC        D4AINV
TLA  C                   MOVE      LBSEQ         D4OSEQ
TLA2 *                    MOVEL     ITVIT#        D4NVIT
 |   C                   MOVE      '*RIGHT  '    DIRCTN
 |   C                   MOVE      LBITEM        WKIT15
 |   C                   EXSR      ZZLTRT
 |   C                   MOVE      WKIT11        ITMN
 |   C     FIITMKY       CHAIN     FIITMAL0                           69
 |   C                   IF        *IN69 = *OFF
 |   C                   MOVEL     FIUPCN        D4NVIT
TLA2 C                   ENDIF
TLA  C                   MOVE      'WLBULKAL'    LBLNAM
TLA  C                   EXSR      TLAPRT
     C                   ENDIF
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLCWT  Catch weight labels.
     *
     C     LBLCWT        BEGSR
NST1 C                   If        LBITEM <> '27801 '
TLA  C                   MOVE      LBSTOP        @@STPN
TLA  C                   MOVE      LBTRN#        @@TRAN
TLA  C                   MOVEL     ITPDSC        @@PKSZ
TLA  C                   MOVEL     T#DESC        @@IDE1
TLA  C                   MOVEL     LBITEM        @@ITMN
TLA  C                   MOVE      OHCORD        @@ORDN
TLA  C                   MOVE      OHCUST        @@CUSN
TLA  C                   MOVEL     OHCNAM        @@CNAM
TLA  C                   MOVE      @PAL#         @@PALT
TLA  C                   MOVEL     $PRTE         @@RTEN
TLA  C                   MOVE      LBSEQ         @@OSEQ
TLA  C                   MOVE      'CACHWT  '    LBLNAM
TLA  C                   EXSR      TLAPRT
NST1 C                   Endif
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLCMB  Combined label is next.
     *
     C     LBLCMB        BEGSR
TLA  C                   MOVE      LBTRN#        @@TRAN
TLA  C                   MOVEL     'CMBB    '    LBLNAM
TLA  C                   EXSR      TLAPRT
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLCMA  Combined label is before.
     *
     C     LBLCMA        BEGSR
TLA  C                   MOVE      LBTRN#        @@TRAN
TLA  C                   MOVEL     'CMBA    '    LBLNAM
TLA  C                   EXSR      TLAPRT
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLDIS  Discrepancies label.
     *
     C     LBLDIS        BEGSR
TLA  C                   MOVE      LBTRN#        @@TRAN
TLA  C                   MOVEL     'DISCRP  '    LBLNAM
TLA  C                   EXSR      TLAPRT
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLPSD  Pallet summary detail line.
     *
     C     LBLPSD        BEGSR
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLPSH  Pallet summary header line.
     *
     C     LBLPSH        BEGSR
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLPCK  Pick labels.
     *
     C     LBLPCK        BEGSR
     C                   Z-ADD     0             STPCNT
     C                   EXSR      GETPAL
ALNbAC                   IF        $PGEN = 1
ALNbAC                   Z-ADD     PAL#          @PAL#
ALNbAC                   ELSE
ALNbAC                   CALL      'GETTPLT'
ALNbAC                   PARM      LBLBL#        $GLBL#            7 0
ALNbAC                   PARM                    $GTPLT            7 0
ALNbAC                   PARM                    $GMLBL            7 0
ALNbAC                   PARM                    $GMPID            7 0
ALNbAC                   PARM                    $GSPLT            1
ALNbAC                   PARM                    $GLOW             1
ALNbAC                   PARM                    $GRTN             8
ALNbAC                   Z-ADD     $GTPLT        @PAL#
ALNbAC                   ENDIF
     C                   IF        COMBO = *OFF
     C                   Z-ADD     W1PICK        @QTY1
     C                   Z-ADD     W1QTY2        @QTY2
     C                   MOVE      ' of'         TOTWRD
     C                   MOVE      '       '     CMBWRD
     C                   ELSE
     C                   Z-ADD     0             @QTY1
     C                   Z-ADD     W1QTY2        @QTY2
     C                   MOVE      'TOT'         TOTWRD
     C                   MOVE      '(COMBO)'     CMBWRD
     C                   ENDIF
     C                   IF        LBASL2 = 'OUT'
     C                   MOVE      'OUT'         OUTWRD
     C                   ELSE
     C                   MOVE      '   '         OUTWRD
     C                   ENDIF
ALNaAC                   MOVEL     OHMISC        DSMISC
     *
     C                   IF        LBGRP2 <> 'W'
TLA  C                   MOVE      LBSTOP        @@STPN
TLA  C                   MOVE      LBTRN#        @@TRAN
TLA  C                   MOVE      LBDISP        @@SLTN
TLA  C                   MOVE      @QTY2         @@PICK
TLA  C                   MOVEL     UMSHRT        @@UOM
TLA  C                   MOVEL     ITPDSC        @@PKSZ
TLA  C                   MOVEL     T#DESC        @@IDE1
TLA  C                   MOVEL     LBITEM        @@ITMN
TLA  C                   MOVE      OHCORD        @@ORDN
TLA  C                   MOVE      OHCUST        @@CUSN
TLA  C                   MOVE      DATE8         @@DTES
TLA  C                   MOVEL     OHCNAM        @@CNAM
TLA  C                   MOVE      @PAL#         @@PALT
TLA  C                   MOVE      @QTY1         @@PQTY
TLA  C                   MOVEL     CMBWRD        @@CMBO
TLA  C                   MOVEL     $PRTE         @@RTEN
TLA  C                   MOVEL     OUTWRD        @@OUT
TLA  C                   MOVE      LBLBL#        @@LBLN
TLA  C                   MOVEL     DSWSEQ        @@WCSQ
TLA  C                   MOVEL     DSINVC        @@AINV
TLA  C                   MOVE      LBSEQ         @@OSEQ
TLA2 *                    MOVELITVIT#    @@NVIT           * BFC 97
 |   C                   MOVE      '*RIGHT  '    DIRCTN
 |   C                   MOVE      LBITEM        WKIT15
 |   C                   EXSR      ZZLTRT
 |   C                   MOVE      WKIT11        ITMN
 |   C     FIITMKY       CHAIN     FIITMAL0                           69
 |   C                   IF        *IN69 = *OFF
 |   C                   MOVEL     FIUPCN        @@NVIT
TLA2 C                   ENDIF
TLA  C                   MOVEL     LBHND2        @@PLTS
TLA  C                   MOVE      $LDOOR        @@DDOR
TLA  C                   MOVE      'PICK    '    LBLNAM
TLA  C                   IF        LBUCOD = 'EA'
TLA  C                   MOVE      'PICKEA  '    LBLNAM
TLA  C                   ENDIF
TLA  C                   EXSR      TLAPRT
     C                   ENDIF
     *
     C                   IF        LBGRP2 = 'W'
TLA  C                   MOVE      LBTRN#        D4TRAN
TLA  C                   MOVE      LBDISP        D4SLTN
TLA  C                   MOVE      @QTY2         D4PICK
TLA  C                   MOVEL     UMSHRT        D4UOM
TLA  C                   MOVEL     ITPDSC        D4PKSZ
TLA  C                   MOVEL     T#DESC        D4IDE1
TLA  C                   MOVEL     LBITEM        D4ITMN
TLA  C                   MOVE      OHCUST        D4CUSN
TLA  C                   MOVE      DATE8         D4DTES
TLA  C                   MOVEL     OHCNAM        D4CNAM
TLA  C                   MOVE      @PAL#         D4PALT
TLA  C                   MOVE      @QTY1         D4PQTY
TLA  C                   MOVEL     $PRTE         D4RTEN
TLA  C                   MOVEL     OUTWRD        D4OUT
TLA  C                   MOVE      LBLBL#        D4LBLN
TLA  C                   MOVEL     DSWSEQ        D4WCSQ
TLA  C                   MOVEL     DSINVC        D4AINV
TLA  C                   MOVE      LBSEQ         D4OSEQ
TLA2 *                    MOVEL     ITVIT#        D4NVIT
 |   C                   MOVE      '*RIGHT  '    DIRCTN
 |   C                   MOVE      LBITEM        WKIT15
 |   C                   EXSR      ZZLTRT
 |   C                   MOVE      WKIT11        ITMN
 |   C     FIITMKY       CHAIN     FIITMAL0                           69
 |   C                   IF        *IN69 = *OFF
 |   C                   MOVEL     FIUPCN        D4NVIT
TLA2 C                   ENDIF
TLA  C                   MOVEL     LBHND2        D4PLTS
TLA  C                   MOVE      'WLPICKAL'    LBLNAM
TLA  C                   EXSR      TLAPRT
     C                   ENDIF
     C                   MOVE      *OFF          COMBO
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLZPD  Zone pickup detail line.
     *
     C     LBLZPD        BEGSR
     C                   SELECT
     C                   WHEN      ZPDCNT = 0  and
414bAC                             $PCMD <> '*TEST1'  and
414bAC                             $PCMD <> '*TEST2'
414bAC                   EXSR      LBLZPS
     C                   OTHER
     C                   Z-ADD     0             DTLCNT
     C                   Z-ADD     0             CNT
TLAdD**   DTLCNT        DOWLT     PALCNT
TLAdMC                   DOW       DTLCNT < ZPDCNT
TLA  C                   ADD       1             DTLCNT
TLA  C                   Z-ADD     LSTTRN        D3ZSTR
TLA  C                   MOVEL     LSTZON        D3ZSZ
TLA  C                   MOVEL     $PRTE         D3RTEN
TLA  C     DTLCNT        OCCUR     ZONPKU
TLAdAC                   ADD       1             CNT
TLA  C                   IF        CNT = 1
TLA  C                   Z-ADD     DSZSTP        D3ZSS1
TLA  C                   Z-ADD     DSZPCS        D3ZSP1
TLA  C                   IF        DSZITM = *BLANKS  and
TLA  C                             DSZDSC = *BLANKS
TLA  C                   CLEAR                   D3ZSI1
TLA  C                   ELSE
TLA  C                   eval      IX = %trimr(DSZITM) + ' ' + '-'
TLA  C                   eval      IX = %trimr(IX) + ' ' + DSZDSC
TLA  C                   MOVEL(P)  IX            D3ZSI1
TLA  C                   ENDIF
TLA  C                   Z-ADD     DSZPLT        D3ZSN1
TLA  C                   ENDIF
     *
TLA  C                   IF        CNT = 2
TLA  C                   Z-ADD     DSZSTP        D3ZSS2
TLA  C                   Z-ADD     DSZPCS        D3ZSP2
TLA  C                   IF        DSZITM = *BLANKS  and
TLA  C                             DSZDSC = *BLANKS
TLA  C                   CLEAR                   D3ZSI2
TLA  C                   ELSE
TLA  C                   eval      IX = %trimr(DSZITM) + ' ' + '-'
TLA  C                   eval      IX = %trimr(IX) + ' ' + DSZDSC
TLA  C                   MOVEL(P)  IX            D3ZSI2
TLA  C                   ENDIF
TLA  C                   Z-ADD     DSZPLT        D3ZSN2
TLA  C                   ENDIF
     *
TLA  C                   IF        CNT = 3
TLA  C                   Z-ADD     DSZSTP        D3ZSS3
TLA  C                   Z-ADD     DSZPCS        D3ZSP3
TLA  C                   IF        DSZITM = *BLANKS  and
TLA  C                             DSZDSC = *BLANKS
TLA  C                   CLEAR                   D3ZSI3
TLA  C                   ELSE
TLA  C                   eval      IX = %trimr(DSZITM) + ' ' + '-'
TLA  C                   eval      IX = %trimr(IX) + ' ' + DSZDSC
TLA  C                   MOVEL(P)  IX            D3ZSI3
TLA  C                   ENDIF
TLA  C                   Z-ADD     DSZPLT        D3ZSN3
TLA  C                   ENDIF
     *
TLA  C                   IF        CNT = 4
TLA  C                   Z-ADD     DSZSTP        D3ZSS4
TLA  C                   Z-ADD     DSZPCS        D3ZSP4
TLA  C                   IF        DSZITM = *BLANKS  and
TLA  C                             DSZDSC = *BLANKS
TLA  C                   CLEAR                   D3ZSI4
TLA  C                   ELSE
TLA  C                   eval      IX = %trimr(DSZITM) + ' ' + '-'
TLA  C                   eval      IX = %trimr(IX) + ' ' + DSZDSC
TLA  C                   MOVEL(P)  IX            D3ZSI4
TLA  C                   ENDIF
TLA  C                   Z-ADD     DSZPLT        D3ZSN4
TLA  C                   ENDIF
     *
TLA  C                   IF        CNT = 5
TLA  C                   Z-ADD     DSZSTP        D3ZSS5
TLA  C                   Z-ADD     DSZPCS        D3ZSP5
TLA  C                   IF        DSZITM = *BLANKS  and
TLA  C                             DSZDSC = *BLANKS
TLA  C                   CLEAR                   D3ZSI5
TLA  C                   ELSE
TLA  C                   eval      IX = %trimr(DSZITM) + ' ' + '-'
TLA  C                   eval      IX = %trimr(IX) + ' ' + DSZDSC
TLA  C                   MOVEL(P)  IX            D3ZSI5
TLA  C                   ENDIF
TLA  C                   Z-ADD     DSZPLT        D3ZSN5
TLA  C                   ENDIF
     *
TLA  C                   IF        CNT = 6
TLA  C                   Z-ADD     DSZSTP        D3ZSS6
TLA  C                   Z-ADD     DSZPCS        D3ZSP6
TLA  C                   IF        DSZITM = *BLANKS  and
TLA  C                             DSZDSC = *BLANKS
TLA  C                   CLEAR                   D3ZSI6
TLA  C                   ELSE
TLA  C                   eval      IX = %trimr(DSZITM) + ' ' + '-'
TLA  C                   eval      IX = %trimr(IX) + ' ' + DSZDSC
TLA  C                   MOVEL(P)  IX            D3ZSI6
TLA  C                   ENDIF
TLA  C                   Z-ADD     DSZPLT        D3ZSN6
TLA  C                   ENDIF
     *
TLA  C                   IF        CNT = 7
TLA  C                   Z-ADD     DSZSTP        D3ZSS7
TLA  C                   Z-ADD     DSZPCS        D3ZSP7
TLA  C                   IF        DSZITM = *BLANKS  and
TLA  C                             DSZDSC = *BLANKS
TLA  C                   CLEAR                   D3ZSI7
TLA  C                   ELSE
TLA  C                   eval      IX = %trimr(DSZITM) + ' ' + '-'
TLA  C                   eval      IX = %trimr(IX) + ' ' + DSZDSC
TLA  C                   MOVEL(P)  IX            D3ZSI7
TLA  C                   ENDIF
TLA  C                   Z-ADD     DSZPLT        D3ZSN7
TLA  C                   ENDIF
     *
TLA  C                   IF        CNT = 8
TLA  C                   Z-ADD     DSZSTP        D3ZSS8
TLA  C                   Z-ADD     DSZPCS        D3ZSP8
TLA  C                   IF        DSZITM = *BLANKS  and
TLA  C                             DSZDSC = *BLANKS
TLA  C                   CLEAR                   D3ZSI8
TLA  C                   ELSE
TLA  C                   eval      IX = %trimr(DSZITM) + ' ' + '-'
TLA  C                   eval      IX = %trimr(IX) + ' ' + DSZDSC
TLA  C                   MOVEL(P)  IX            D3ZSI8
TLA  C                   ENDIF
TLA  C                   Z-ADD     DSZPLT        D3ZSN8
TLA  C                   ENDIF
     *
TLA  C                   IF        CNT = 9
TLA  C                   Z-ADD     DSZSTP        D3ZSS9
TLA  C                   Z-ADD     DSZPCS        D3ZSP9
TLA  C                   IF        DSZITM = *BLANKS  and
TLA  C                             DSZDSC = *BLANKS
TLA  C                   CLEAR                   D3ZSI9
TLA  C                   ELSE
TLA  C                   eval      IX = %trimr(DSZITM) + ' ' + '-'
TLA  C                   eval      IX = %trimr(IX) + ' ' + DSZDSC
TLA  C                   MOVEL(P)  IX            D3ZSI9
TLA  C                   ENDIF
TLA  C                   Z-ADD     DSZPLT        D3ZSN9
TLA  C                   ENDIF
     *
TLA  C                   IF        CNT = 10
TLA  C                   Z-ADD     DSZSTP        D3ZSS0
TLA  C                   Z-ADD     DSZPCS        D3ZSP0
TLA  C                   IF        DSZITM = *BLANKS  and
TLA  C                             DSZDSC = *BLANKS
TLA  C                   CLEAR                   D3ZSI0
TLA  C                   ELSE
TLA  C                   eval      IX = %trimr(DSZITM) + ' ' + '-'
TLA  C                   eval      IX = %trimr(IX) + ' ' + DSZDSC
TLA  C                   MOVEL(P)  IX            D3ZSI0
TLA  C                   ENDIF
TLA  C                   Z-ADD     DSZPLT        D3ZSN0
TLA  C                   ENDIF
     *
TLA  C                   IF        CNT = 10  or
TLA  C                             DTLCNT = PALCNT
TLA  C                   MOVE      'ZONPKUP '    LBLNAM
TLA  C                   EXSR      TLAPRT
TLA  C                   CLEAR                   CNT
TLA  C                   ENDIF
TLA  C                   ENDDO
     C                   ENDSL
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLZPH  Zone pickup header line.
     *
     C     LBLZPH        BEGSR
     C                   IF        ZPDCNT = 0
TLA  C                   Z-ADD     LSTTRN        @@ZSTR
TLA  C                   MOVEL     LSTZON        @@ZSZ
TLA  C                   MOVEL     $PRTE         @@RTEN
TLA  C                   MOVE      'ZONPKUP '    LBLNAM
TLA  C                   EXSR      TLAPRT
     C                   ENDIF
     C                   ENDSR
414bA*----------------------------------------------------------------
414bA*
414bA*  LBLZPS  Zone pickup individual selection labels
414bA*
414baC     LBLZPS        BEGSR
     *
     *     See if we should print the "before" um warning.
     *
     C                   IF        LBUTYP <> 'N'  and
     C                             OPUWRB = 'Y'
     C                   EXSR      LBLUMB
     C                   ENDIF
     *
     *     Initialize label fields.
     *
     C                   Z-ADD     LBQPCK        W1QTY2
     C                   EXSR      CRTSTP
     *
     *     Either print a combination label ...
     *
     C                   SELECT
     C                   WHEN      LBQPCK >= OPCLVL
     C                   MOVE      *ON           COMBO
     *
     *        See if we should print the "before" combo warning.
     *
     C                   IF        OPCWRB = 'Y'
     C                   EXSR      LBLCMB
     C                   ENDIF
     *
     *        Print one label.
     *
     C                   Z-ADD     LBQPCK        W1PICK
     C                   EXSR      LBLPCK
     *
     *        See if we should print the "after" combo warning.
     *
     C                   IF        OPCWRA = 'Y'
     C                   EXSR      LBLCMA
     C                   ENDIF
     *
     C                   OTHER
     *
     *     Or print individual labels.
     *
     C                   MOVE      *OFF          COMBO
     C     1             DO        LBQPCK        W1PICK
     C                   EXSR      LBLPCK
     C                   ENDDO
     *
     C                   ENDSL
     *
     *     See if we should print the "after" um warning.
     *
     C                   IF        LBUTYP <> 'N'  and
     C                             OPUWRA = 'Y'
     C                   EXSR      LBLUMA
     C                   ENDIF
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLRP1  Replenishment/Letdown
     *
     C     LBLRP1        BEGSR
     *
ALNaAC                   MOVE      *BLANKS       T#DESC
ALNaAC     KEYIX         CHAIN     ITEMDSC                            79
ALNaAC                   IF        not *IN79
ALNaAC                   MOVEL     IXDSC1        T#DESC
ALNaAC     T#DESC        CAT       IXDSC2:1      T#DESC
ALNaAC                   ENDIF
     *
     C                   Z-ADD     W1QTY         @QTY1
     C                   Z-ADD     LBQAVL        @QTY2
     C                   MOVE      ' of'         TOTWRD
TLA  C                   MOVE      LBTRN#        @@TRAN
TLA  C                   MOVE      LBDISP        @@SLTN
TLA  C                   MOVE      @QTY2         @@PICK
TLA  C                   MOVEL     UMSHRT        @@UOM
TLA  C                   Z-ADD     LBTIE         TI
TLA  C                   Z-ADD     LBHIGH        HI
TLA  C                   MOVE      '/'           S3
TLA  C                   MOVE      TIHI          @@TIHI
TLA  C                   MOVEL     ITPDSC        @@PKSZ
TLA  C                   MOVEL     T#DESC        @@IDE1
TLA  C                   MOVEL     LBITEM        @@ITMN
TLA  C                   MOVE      @QTY1         @@PQTY
TLA  C                   MOVEL     TOTWRD        @@OF
TLA  C                   MOVEL     LBDSP2        @@TSLT
TLA  C                   MOVE      'REPL1   '    LBLNAM
TLA  C                   EXSR      TLAPRT
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLRP2  Replenishment/Letdown - Breakdown.
     *
     C     LBLRP2        BEGSR
     C                   Z-ADD     W1QTY         @QTY1
     C                   Z-ADD     LBQAVL        @QTY2
     C                   MOVE      ' of'         TOTWRD
TLA  C                   MOVE      LBTRN#        @@TRAN
TLA  C                   MOVE      LBDISP        @@SLTN
TLA  C                   MOVE      @QTY2         @@PICK
TLA  C                   MOVEL     UMSHRT        @@UOM
TLA  C                   MOVE      @QTY1         @@PQTY
TLA  C                   MOVEL     TOTWRD        @@OF
TLA  C                   MOVEL     LBDSP2        @@TSLT
TLA  C                   MOVE      TOQTY         @@BCRQ
TLA  C                   MOVEL     TOUM          @@BCRU
TLA  C                   MOVEL     FRITEM        @@BCFI
TLA  C                   MOVEL     TOITEM        @@BCTI
TLA  C                   MOVEL     FRDESC        @@BCFD
TLA  C                   MOVEL     TODESC        @@BCTD
TLA  C                   MOVE      'REPL2   '    LBLNAM
TLA  C                   EXSR      TLAPRT
     C                   ENDSR
610b *----------------------------------------------------------------
610b *
610b *  LBLRP3  Replenishment/Letdown
610b *
610b C     LBLRP3        BEGSR
610b *
610bAC                   MOVE      *BLANKS       T#DESC
610bAC     KEYIX         CHAIN     ITEMDSC                            79
610bAC                   IF        not *IN79
610bAC                   MOVEL     IXDSC1        T#DESC
610bAC     T#DESC        CAT       IXDSC2:1      T#DESC
610bAC                   ENDIF
610b *
610b C                   MOVEL     $prte         @@rten
610b C                   Z-ADD     PRQTY         @QTY1
610b C                   Z-ADD     PRQTY         @QTY2
610b C                   MOVE      ' of'         TOTWRD
610b C                   Z-ADD     KYSEQ#        @@TRAN
610b C                   MOVE      PRFDIS        @@SLTN
610b C                   MOVE      @QTY2         @@PICK
610b C                   MOVEL     UMSHRT        @@UOM
610b C                   Z-ADD     0             TI
610b C                   Z-ADD     0             HI
610b C                   MOVE      '/'           S3
610b C                   MOVE      TIHI          @@TIHI
610b C                   MOVEL     ITPDSC        @@PKSZ
610b C                   MOVEL     T#DESC        @@IDE1
610b C                   MOVEL     PRITEM        @@ITMN
610b C                   MOVE      @QTY1         @@PQTY
610b C                   MOVEL     TOTWRD        @@OF
610b C                   MOVEL     PRTDIS        @@TSLT
610b C                   MOVE      'REPL1   '    LBLNAM
610b C                   EXSR      TLAPRT
610b C                   ENDSR
610b *----------------------------------------------------------------
610b *
610bA*  LBLRP4  JIT Replenishment - Breakdown.
610b *
610bAC     LBLRP4        BEGSR
610b C                   MOVEL     $prte         @@rten
610b C                   Z-ADD     PRQTY         @QTY1
610b C                   Z-ADD     PRQTY         @QTY2
610b C                   MOVE      ' of'         TOTWRD
610b C                   Z-ADD     KYSEQ#        @@TRAN
610b C                   MOVE      PRTDIS        @@SLTN
610b C                   MOVE      @QTY2         @@PICK
610b C                   MOVEL     UMSHRT        @@UOM
610b C                   MOVE      @QTY1         @@PQTY
610b C                   MOVEL     TOTWRD        @@OF
610b C                   MOVEL     PRTDIS        @@TSLT
610b C                   MOVE      PRQTY         @@BCRQ
610b C                   MOVEL     TOUM          @@BCRU
610b C                   MOVEL     FRITEM        @@BCFI
610b C                   MOVEL     TOITEM        @@BCTI
610b C                   MOVEL     FRDESC        @@BCFD
610b C                   MOVEL     TODESC        @@BCTD
610b C                   MOVE      'REPL2   '    LBLNAM
610b C                   EXSR      TLAPRT
610b C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLSHD  Set header.(Batch, Warehouse etc.)
     *
     C     LBLSHD        BEGSR
     C                   IF        $PGEN = 1
     C                   MOVE      'Truck'       ZONTYP
     C                   ELSE
     C                   MOVE      'Stage'       ZONTYP
     C                   ENDIF
     *
     C                   Z-ADD     0             CNT
     C                   Z-ADD     0             DTLCNT
TLA  C                   MOVE      LBTRN#        D1TRAN
TLA  C                   MOVE      $PWHSE        D1WHNA
TLA  C                   MOVEL     $PCOMP        D1TKCM
TLA  C                   MOVEL     $PSZON        D1ZONE
TLA  C                   MOVE      $PRTE         D1RTEN
TLA  C                   MOVEL     ZONTYP        D1ZNTP
     C                   DOW       DTLCNT < PALCNT
TLA  C                   ADD       1             DTLCNT
TLA  C     DTLCNT        OCCUR     PALSUM
TLA  C                   ADD       1             CNT
TLA  C                   IF        CNT = 1
TLA  C                   Z-ADD     DSPPAL        D1PSN1
TLA  C                   Z-ADD     DSPSTP        D1PSS1
TLA  C                   Z-ADD     DSPPCS        D1PSP1
TLA  C                   Z-ADD     DSPCUB        D1PSC1
TLA  C                   Z-ADD     DSPWGT        D1PSW1
TLA  C                   ENDIF
TLA  C                   IF        CNT = 2
TLA  C                   Z-ADD     DSPPAL        D1PSN2
TLA  C                   Z-ADD     DSPSTP        D1PSS2
TLA  C                   Z-ADD     DSPPCS        D1PSP2
TLA  C                   Z-ADD     DSPCUB        D1PSC2
TLA  C                   Z-ADD     DSPWGT        D1PSW2
TLA  C                   ENDIF
TLA  C                   IF        CNT = 3
TLA  C                   Z-ADD     DSPPAL        D1PSN3
TLA  C                   Z-ADD     DSPSTP        D1PSS3
TLA  C                   Z-ADD     DSPPCS        D1PSP3
TLA  C                   Z-ADD     DSPCUB        D1PSC3
TLA  C                   Z-ADD     DSPWGT        D1PSW3
TLA  C                   ENDIF
TLA  C                   IF        CNT = 4
TLA  C                   Z-ADD     DSPPAL        D1PSN4
TLA  C                   Z-ADD     DSPSTP        D1PSS4
TLA  C                   Z-ADD     DSPPCS        D1PSP4
TLA  C                   Z-ADD     DSPCUB        D1PSC4
TLA  C                   Z-ADD     DSPWGT        D1PSW4
TLA  C                   ENDIF
TLA  C                   IF        CNT = 5
TLA  C                   Z-ADD     DSPPAL        D1PSN5
TLA  C                   Z-ADD     DSPSTP        D1PSS5
TLA  C                   Z-ADD     DSPPCS        D1PSP5
TLA  C                   Z-ADD     DSPCUB        D1PSC5
TLA  C                   Z-ADD     DSPWGT        D1PSW5
TLA  C                   ENDIF
TLA  C                   IF        CNT = 6
TLA  C                   Z-ADD     DSPPAL        D1PSN6
TLA  C                   Z-ADD     DSPSTP        D1PSS6
TLA  C                   Z-ADD     DSPPCS        D1PSP6
TLA  C                   Z-ADD     DSPCUB        D1PSC6
TLA  C                   Z-ADD     DSPWGT        D1PSW6
TLA  C                   ENDIF
TLA  C                   IF        CNT = 7
TLA  C                   Z-ADD     DSPPAL        D1PSN7
TLA  C                   Z-ADD     DSPSTP        D1PSS7
TLA  C                   Z-ADD     DSPPCS        D1PSP7
TLA  C                   Z-ADD     DSPCUB        D1PSC7
TLA  C                   Z-ADD     DSPWGT        D1PSW7
TLA  C                   ENDIF
TLA  C                   IF        CNT = 8
TLA  C                   Z-ADD     DSPPAL        D1PSN8
TLA  C                   Z-ADD     DSPSTP        D1PSS8
TLA  C                   Z-ADD     DSPPCS        D1PSP8
TLA  C                   Z-ADD     DSPCUB        D1PSC8
TLA  C                   Z-ADD     DSPWGT        D1PSW8
TLA  C                   ENDIF
TLA  C                   IF        CNT = 9
TLA  C                   Z-ADD     DSPPAL        D1PSN9
TLA  C                   Z-ADD     DSPSTP        D1PSS9
TLA  C                   Z-ADD     DSPPCS        D1PSP9
TLA  C                   Z-ADD     DSPCUB        D1PSC9
TLA  C                   Z-ADD     DSPWGT        D1PSW9
TLA  C                   ENDIF
TLA  C                   IF        CNT = 10
TLA  C                   Z-ADD     DSPPAL        D1PSN0
TLA  C                   Z-ADD     DSPSTP        D1PSS0
TLA  C                   Z-ADD     DSPPCS        D1PSP0
TLA  C                   Z-ADD     DSPCUB        D1PSC0
TLA  C                   Z-ADD     DSPWGT        D1PSW0
TLA  C                   ENDIF
     *
TLA  C                   IF        CNT = 7  or
TLA  C                             DTLCNT = PALCNT
TLA  C                   MOVE      'SETHED  '    LBLNAM
TLA  C                   EXSR      TLAPRT
TLA  C                   Z-ADD     0             CNT
TLA  C                   ENDIF
     C                   ENDDO
     *
ALNhAC                   IF        $PGEN = 1
ALN AC                   Z-ADD     0             DTLCNT
ALN AC                   DOW       DTLCNT < PALCNT
ALN AC                   ADD       1             DTLCNT
ALN AC     DTLCNT        OCCUR     PALSUM
ALN AC                   Z-ADD     DSPPAL        @PAL#
ALN AC                   Z-ADD     DSPPLI        @PLID
ALN AC                   MOVE      DSPRTI        @RTID

610aAC                   move      *blanks       temp7a            7
610aAC                   move      @plid         temp7a
610aA *   Move last 2 chars of route id to beginning of pallet id.
610aAC                   movel     @rtid         $cstr
610aAC                   call      'ADJUST'
610aAC                   parm      '*RIGHT  '    $ccmd             8
610aAC                   parm                    $cstr            30
610aAC                   move      $cstr         temp2a            2
610aAC                   movel     temp2a        temp7a
610aAC                   move      temp7a        @plid

ALN AC                   IF        DSPPAL > 0
TLA  C                   Z-ADD     @PAL#         D4PALT
TLA  C                   MOVE      $PRTE         D4RTEN
TLA  C                   MOVEL     $PCOMP        D4DEPT
AFS  C                   MOVE      @plid         D4plid
TLA  C                   MOVE      'SETHEDAL'    LBLNAM
TLA  C                   EXSR      TLAPRT
ALN AC                   ENDIF
ALN AC                   ENDDO
ALNhAC                   ENDIF
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLSSD  Set summary detail lines.
     *
     C     LBLSSD        BEGSR
TLA  C                   Z-ADD     0             CNT
TLA  C                   Z-ADD     0             DTLCNT
TLA  C                   MOVE      LSTTRN        D2ZSTR
     C                   DOW       DTLCNT < SSDCNT
     C                   ADD       1             DTLCNT
     C     DTLCNT        OCCUR     STPSUM
TLA  C                   ADD       1             CNT
TLA  C                   IF        CNT = 1
TLA  C                   Z-ADD     DSSSTP        D2SSS1
TLA  C                   Z-ADD     DSSPCS        D2SSP1
TLA  C                   Z-ADD     DSSCUB        D2SSC1
TLA  C                   Z-ADD     DSSWGT        D2SSW1
TLA  C                   MOVEL     DSSCNM        D2SSN1
TLA  C                   ENDIF
TLA  C                   IF        CNT = 2
TLA  C                   Z-ADD     DSSSTP        D2SSS2
TLA  C                   Z-ADD     DSSPCS        D2SSP2
TLA  C                   Z-ADD     DSSCUB        D2SSC2
TLA  C                   Z-ADD     DSSWGT        D2SSW2
TLA  C                   MOVEL     DSSCNM        D2SSN2
TLA  C                   ENDIF
TLA  C                   IF        CNT = 3
TLA  C                   Z-ADD     DSSSTP        D2SSS3
TLA  C                   Z-ADD     DSSPCS        D2SSP3
TLA  C                   Z-ADD     DSSCUB        D2SSC3
TLA  C                   Z-ADD     DSSWGT        D2SSW3
TLA  C                   MOVEL     DSSCNM        D2SSN3
TLA  C                   ENDIF
TLA  C                   IF        CNT = 4
TLA  C                   Z-ADD     DSSSTP        D2SSS4
TLA  C                   Z-ADD     DSSPCS        D2SSP4
TLA  C                   Z-ADD     DSSCUB        D2SSC4
TLA  C                   Z-ADD     DSSWGT        D2SSW4
TLA  C                   MOVEL     DSSCNM        D2SSN4
TLA  C                   ENDIF
TLA  C                   IF        CNT = 5
TLA  C                   Z-ADD     DSSSTP        D2SSS5
TLA  C                   Z-ADD     DSSPCS        D2SSP5
TLA  C                   Z-ADD     DSSCUB        D2SSC5
TLA  C                   Z-ADD     DSSWGT        D2SSW5
TLA  C                   MOVEL     DSSCNM        D2SSN5
TLA  C                   ENDIF
TLA  C                   IF        CNT = 6
TLA  C                   Z-ADD     DSSSTP        D2SSS6
TLA  C                   Z-ADD     DSSPCS        D2SSP6
TLA  C                   Z-ADD     DSSCUB        D2SSC6
TLA  C                   Z-ADD     DSSWGT        D2SSW6
TLA  C                   MOVEL     DSSCNM        D2SSN6
TLA  C                   ENDIF
TLA  C                   IF        CNT = 7
TLA  C                   Z-ADD     DSSSTP        D2SSS7
TLA  C                   Z-ADD     DSSPCS        D2SSP7
TLA  C                   Z-ADD     DSSCUB        D2SSC7
TLA  C                   Z-ADD     DSSWGT        D2SSW7
TLA  C                   MOVEL     DSSCNM        D2SSN7
TLA  C                   ENDIF
TLA  C                   IF        CNT = 8
TLA  C                   Z-ADD     DSSSTP        D2SSS8
TLA  C                   Z-ADD     DSSPCS        D2SSP8
TLA  C                   Z-ADD     DSSCUB        D2SSC8
TLA  C                   Z-ADD     DSSWGT        D2SSW8
TLA  C                   MOVEL     DSSCNM        D2SSN8
TLA  C                   ENDIF
TLA  C                   IF        CNT = 9
TLA  C                   Z-ADD     DSSSTP        D2SSS9
TLA  C                   Z-ADD     DSSPCS        D2SSP9
TLA  C                   Z-ADD     DSSCUB        D2SSC9
TLA  C                   Z-ADD     DSSWGT        D2SSW9
TLA  C                   MOVEL     DSSCNM        D2SSN9
TLA  C                   ENDIF
TLA  C                   IF        CNT = 10
TLA  C                   Z-ADD     DSSSTP        D2SSS0
TLA  C                   Z-ADD     DSSPCS        D2SSP0
TLA  C                   Z-ADD     DSSCUB        D2SSC0
TLA  C                   Z-ADD     DSSWGT        D2SSW0
TLA  C                   MOVEL     DSSCNM        D2SSN0
TLA  C                   ENDIF
     *
TLA  C                   IF        CNT = 10  or
TLA  C                             DTLCNT = SSDCNT
TLA  C                   MOVE      'SETSUM  '    LBLNAM
TLA  C                   EXSR      TLAPRT
TLA  C                   Z-ADD     0             CNT
TLA  C                   ENDIF
     C                   ENDDO
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLSSH  Set summary header line.
     *
     C     LBLSSH        BEGSR
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLUMA  Unit of measure change is before.
     *
     C     LBLUMA        BEGSR
TLA  C                   MOVE      LBTRN#        @@TRAN
TLA  C                   MOVE      LBDISP        @@SLTN
TLA  C                   MOVEL     ITPDSC        @@PKSZ
TLA  C                   MOVEL     T#DESC        @@IDE1
TLA  C                   MOVEL     LBITEM        @@ITMN
TLA  C                   MOVE      'UMA     '    LBLNAM
TLA  C                   EXSR      TLAPRT
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLUMB  Unit of measure change is next.
     *
     C     LBLUMB        BEGSR
TLA  C                   MOVE      LBTRN#        @@TRAN
TLA  C                   MOVE      LBDISP        @@SLTN
TLA  C                   MOVEL     ITPDSC        @@PKSZ
TLA  C                   MOVEL     T#DESC        @@IDE1
TLA  C                   MOVEL     LBITEM        @@ITMN
TLA  C                   MOVE      'UMB     '    LBLNAM
TLA  C                   EXSR      TLAPRT
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLZHD  Zone header label.
     *
     C     LBLZHD        BEGSR
TLA  C                   MOVE      $PWHSE        @@WHNA
TLA  C                   MOVEL     $PCOMP        @@TKCM
TLA  C                   MOVEL     $PSZON        @@ZONE
TLA  C                   MOVEL     $PRTE         @@RTEN
TLA  C                   MOVE      'ZONHED  '    LBLNAM
TLA  C                   EXSR      TLAPRT
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  LBLXDB  Cross dock labels are next.
     *
     C     LBLXDB        BEGSR
TLA  C                   MOVE      'XDKB    '    LBLNAM
TLA  C                   EXSR      TLAPRT
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  STRPDP  Strip decimal point from sample data
     *
     C     STRPDP        BEGSR
     C                   MOVEA     LFVDTA        A50
     C                   Z-ADD     0             Y1
     C     1             DO        50            X1
     C                   IF        A50(X1) >= '0'  and
     C                             A50(X1) <= '9'
     C                   ADD       1             Y1
     C                   MOVE      A50(X1)       A50(Y1)
     C                   ENDIF
     C                   ENDDO
     C                   IF        Y1 < 50
     C                   ADD       1             Y1
     C                   MOVEA     *BLANKS       A50(Y1)
     C                   ENDIF
     C                   MOVEA     A50           LFVDTA
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  TEST1   Test 1 - Print label definitions
     *
     C     TEST1         BEGSR
     *
ALN AC     1             DO        SHDCNT        K
ALN AC     K             OCCUR     PALSUM
ALN AC                   Z-ADD     K             DSPPAL
ALN AC                   ENDDO
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'BEGBLK  '
     C                   EXSR      LBLBBK
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'BEGRPL  '
     C                   EXSR      LBLBRP
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'BULK    '
     C                   EXSR      LBLBLK
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'CACHWT  '
     C                   EXSR      LBLCWT
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'CMBA    '
     C                   EXSR      LBLCMA
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'CMBB    '
     C                   EXSR      LBLCMB
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'DISCRP  '
     C                   EXSR      LBLDIS
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'PICK    '
     C                   EXSR      LBLPCK
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'REPL1   '
     C                   EXSR      LBLRP1
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'REPL2   '
     C                   EXSR      LBLRP2
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'SETHED  '
     C                   IF        $PCMD = '*TEST1  '
     C                   MOVE      'Truck'       ZONTYP
     C                   Z-ADD     SHDCNT        PALCNT
     C                   EXSR      LBLSHD
     C                   ENDIF
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'SETSUM  '
     C                   EXSR      LBLSSD
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'UMA     '
     C                   EXSR      LBLUMA
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'UMB     '
     C                   EXSR      LBLUMB
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'XDKB    '
     C                   EXSR      LBLXDB
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'ZONHED  '
     C                   EXSR      LBLZHD
     C                   ENDIF
     *
     C                   IF        $PLFMT = '*ALL    '  or
     C                             $PLFMT = 'ZONPKUP '
     C                   EXSR      LBLZPD
     C                   ENDIF
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
ALNdA*  ZZATTL  Accumulate totals to calculate std time for transactn
     *
ALNdAC     ZZATTL        BEGSR
     C                   MOVE      *BLANKS       W1WDS
     C                   MOVE      LBWHSE        W1WHSE
ALNiAC     ITKEY         CHAIN     PIRITEM                            79
ALNiAC                   IF        *IN79
ALNiAC                   MOVE      *BLANKS       ITWHDP
ALNiAC                   MOVE      *BLANKS       ITSTYP
ALNiAC                   ENDIF
ALNiMC     W1WHSE        CAT       ITWHDP:0      W1WDS
ALNiMC     W1WDS         CAT       ITSTYP:0      W1WDS
     C                   Z-ADD     1             N
     C     W1WDS         LOOKUP    WDS(N)                                 81
     * Found
     C                   IF        *IN81
     *
ALNhAC                   IF        ZPIKUP = *ON
ALNhAC                   ADD       LBQALC        CSE(N)
ALNhAC                   ELSE
     C                   ADD       LBQALC        CSE(N)
     C                   ADD       1             SLT(N)
ALNhAC                   ENDIF
     *
     C                   ELSE
     * Not found
     C                   MOVE      W1WDS         WDS(N)
     C                   Z-ADD     LBQALC        CSE(N)
     C                   Z-ADD     1             SLT(N)
     C                   Z-ADD     LBWHSE        WHS(N)
     C                   MOVE      LBWHDP        WHD(N)
     C                   MOVE      LBSTYP        SEC(N)
     C                   ENDIF
     *
ALNdAC                   ENDSR
     *----------------------------------------------------------------
     *
ALNdA*  ZZCLCT  Calculate pick time
     *
ALNdAC     ZZCLCT        BEGSR
     C                   Z-ADD     0             PCKTIM
     C                   Z-ADD     0             N
     C                   DO        99            N
     C                   IF        WDS(N) > *BLANKS
     C                   Z-ADD     WHS(N)        W1WHS
     C                   MOVE      WHD(N)        W1WHDP
     C                   MOVE      SEC(N)        W1SEC
     C                   Z-ADD     CSE(N)        W1CSE
     C                   Z-ADD     SLT(N)        W1SLT
     C                   Z-ADD     0             W1STIM
     C                   Z-ADD     0             W1CTIM
     C     KEYST         CHAIN     STDTIME                            79
     C                   IF        not *IN79
     C     STSTIM        MULT      W1SLT         W1STIM
     C     STCTIM        MULT      W1CSE         W1CTIM
     C                   ELSE
     C                   ITER
     C                   ENDIF
     C     PCKTIM        ADD       STPTIM        PCKTIM
     C     PCKTIM        ADD       W1STIM        PCKTIM
     C     PCKTIM        ADD       W1CTIM        PCKTIM
     C                   ENDIF
     C                   ENDDO
     *
ALNhAC                   ADD       CWTIME        PCKTIM
ALNgAC                   Z-ADD     PCKTIM        PCKTM0
     *
ALNdAC                   ENDSR
     *----------------------------------------------------------------
     *
ALNdA*  ZZCLRA  Clear totals array
     *
ALNdAC     ZZCLRA        BEGSR
     C                   Z-ADD     0             N
     C                   DO        99            N
     C                   MOVE      *BLANKS       WDS(N)
     C                   Z-ADD     0             WHS(N)
     C                   MOVE      *BLANKS       WHD(N)
     C                   MOVE      *BLANKS       SEC(N)
     C                   Z-ADD     0             CSE(N)
     C                   Z-ADD     0             SLT(N)
     C                   ENDDO
ALNhAC                   Z-ADD     0             CWTIME
ALNdAC                   ENDSR
     *----------------------------------------------------------------
     *
     *  ZZLTRT   Make item number left/right justified.
     *
     C     ZZLTRT        BEGSR
     C                   SELECT
     C                   WHEN      DIRCTN = '*LEFT   '
     C                   MOVE      *BLANKS       WKIT15
     C                   EVAL      WKIT15 = %TRIM(WKIT11)
     *
     C                   WHEN      DIRCTN = '*RIGHT  '
     C                   MOVE      *BLANKS       WKIT11
     C                   EVALR     WKIT11 = %TRIMR(WKIT15)
     *
     C                   ENDSL
     C                   ENDSR
     *----------------------------------------------------------------
     *  Output Specs
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**   TTLDSC
<<< TOTALS >>>
