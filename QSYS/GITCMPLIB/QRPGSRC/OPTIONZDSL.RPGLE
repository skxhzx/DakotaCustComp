     *----------------------------------------------------------------
     *
     *  OPTIONZDS  Redefinition data structures for OPTIONZ file
     *  11 June 1997
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *
     *     11/28/94  DAS
     *       - Changed OPFSTP to 2 digits from 1.
     *
     *     02/16/95  DAS   2.09
     *       - Moved option from OPTIONS to OPTIOND in order to have
     *         the options by department.
     *       - Added option OPFBLD for identifying the method to use
     *         for building a fixed pallet.
     *
213 A*     06/11/96  DAS   2.13
     *       - Redefined OPBPCK to 3.0 from 2.0.
     *       - Added option OPPBRK.
     *
214 A*     07/01/96  DAS
     *       - Redefined OPPBRK to 3 from 1 and to contain aisle
     *         instead of Y/N.
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - OPPBRK is not used with zones.
     *
416 A*     06/20/01  MLB  4.16
     *       - Added new option for field OPPBLD for
     *         record *PICK.
     *
500 A*     02/21/06  DAS  5.00
     *       - Added option OPTOTE and OPTCUB.
     *
500aA*     03/02/06  DAS  5.00a
     *       - Added option OPBMRG and OPNWPL before OPTOTE & OPTCUB
     *
500bA*     03/31/06  DAS  5.00b
     *       - Added option OPFPCS.
     *
500cA*     04/06/06  DAS  5.00c
     *       - Renamed OPTOTE to OPPTYP.
     *       - Added option OPNWOR.
     *
500dA*     04/18/06  DAS  5.00d
     *       - Added option xxxx
     *
510 A*     01/03/07  JCJ  5.10
     *       - Added option OPSTOP.
     *
510aA*     01/18/07  JCJ  5.10a
     *       - Added option OPGCDE.
520 A*       - OPGCDE is used only by US Foods.  For all other
     *         clients, pos 62 is populated by OPPKUP.
     *
520 A*     08/10/09  RBD  5.20  P#00219
     *       - Added record type *PICKLBA which holds printing info
     *         for the standard pick, retail, and tote labels.
     *       - Added record type *PICKLBB which holds printing info
     *         for the pick list and ASN labels and pick list report.
     *       - Added option OPPITM to *PICK.
     *       - Added options OPTAXR and OPCHKR to *PICKLBL.
     *       - Added notation for fields OPPKUP, OPSPAL, and OPAISL
     *         which were previously added to ZH122.
     *       - Revised OPPTYP to include B = Batch.
     *
530 A*     12/21/09  JCJ  5.30
     *       - Added OPLB7 to *PICKLBB
     *
650a *     05/04/13  GJA  6.50a
     *       - Added OPLBL to *PICK to allow printing labels side by
     *         side.
     *
700a *     04/22/15  DAS  7.00a
     *       - Added *PICK fields OPPMTZ, OPDDDO, OPMCUB, originally for USF
     *       - Moved USF field OPGCDE from pos 62 to 76.
     *
710a *     06/05/17  LMC  7.10a
     *       - Added Number of Pallet sections. OPNBPS
     *
720a *     05/30/18  DAS  7.20a
     *       - Added max weight. OPFWGT
     *       - Added pallet. OPFPLT
     *       - Added build sequence. OPBSEQ
     *
720b *     08/31/18  DAS  7.20b
     *       - Added max stops per section. OPSSTP.
     *
740a *     05/27/20  DAS  7.40a
     *       - Added RF Zone Pickup Override. OZRFZP
     *
740b *     09/25/20  KDE  7.40b
     *       - Added fields opicub, oppisplt, opmscb,
     *         opmsvh, opmsvm, opmsvl, opoacb, opzplt, opbplt
     *
750  *     02/18/21  KDE  7.50
     *       - Added field oppstuff
     *
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
214 D**** OPPBRK  -  Break pallets by aisle (Y,N).
214 M*    OPPBRK  -  Aisle to start new pallet.
400 A*    OPPBLD  -  Pallet building method.
400 A*                1 = By stop then slot location.
400 A*                2 = By slot location then stop.
416 A*                3 = Descending by stop then location.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
500aA*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
500aA*    OPNWPL  -  Start new pallet when aisle changes if build method
500aA*               is 2=Location.
500dA*    OPFORD  -  Maximu orders per pallet.
520 M*    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
500dA*    OPFTOT  -  Maximum totes per pallet.
500dA*    OPTECB  -  External tote cube.
500dA*    OPTICB  -  Internal tote cube.
500dA*    OPTSTP  -  Maximum stops per tote.
500dA*    OPTORD  -  Maximum orders per tote.
500dA*    OPTPCS  -  Maximum pieces per tote.
510 A*    OPSTOP  -  Prevent *SP flag (Y=Yes, N=No).
510aA*    OPGCDE  -  USF Group Code (0-9).
520 A*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520 A*    OPSPAL  -  Merge pallet should only contain
520 A*               items for single truck pallet (Y=Yes, N=No).
520 A*    OPPITM  -  Maximum items per pallet.
650aA*    OPLBL   -  Pick Label Printing method.
650aA*                N = Normal
650aA*                S = Side by Side
656aA*                C = Custom
700aA*    OPPMTZ  -  Allow multi-truck assignments.
700aA*    OPDDDO  -  Dock door drop off order.
700aA*    OPMCUB  -  Minimum cube per fixed pallet.
710aA*    OPNBPS  -  Number of Pallet Sections.
720aA*    OPFWGT  -  Maximu weight per pallet.
720aA*    OPFPLT  -  Pallet code
720aA*    OPBSEQ  -  Build sequence number
720bA*    OPSSTP  -  Maximum stops per section
740aA*    OZRFZP  -  Zone Pickup
740bA*    OPICUB  -  Ideal Cube
740bA*    OPPISPLT-  Prevent Item Splits
740bA*    OPMSCB  -  Allow Merging other stops with
740bA*               Single Pallet when cube less than this
740bA*    OPMSVH  -  When merging to single pallet make high pallet
740bA*    OPMSVM  -  When merging to single pallet make middle pallet
740bA*    OPMSVL  -  When merging to single pallet make low pallet
740bA*    OPOACB  -  When overflow, put on truck when cube greater
740bA*               than this value
740bA*    OPZPLT  -  Zone Pallet Type
740bA*    OPBPLT  -  Bulk Pallet Type
750 A*    OPPSTUFF-  Either Stuff (S) or Split (M) when Max Cube exceeded
     *
     * Data structure
     *
     D opddta          ds
     D  opnxtp                 1      7  0 inz(0)
213 D*I            0                         8   90OPBPCK
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     *I            0                        21  210OPFSTP
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
209 AD  opfbld                27     27  0 inz(0)
213 AD  opbpck                28     30  0 inz(0)
214 D*                                      31  31 OPPBRK
214 AD  oppbrk                31     33
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
500 D*                                      37  37 OPTOTE
500 D*             0                        38  422OPTCUB
500aAD  opbmrg                37     37
500aAD  opnwpl                38     38
500dAD  opford                39     40  0 inz(0)
500cMD  opptyp                41     41
500dAD  opftot                42     43  0 inz(0)
500dAD  optecb                44     48  2 inz(0)
500dAD  opticb                49     53  2 inz(0)
500dAD  optstp                54     55  0 inz(0)
500dAD  optord                56     57  0 inz(0)
500dAD  optpcs                58     60  0 inz(0)
510 AD  opstop                61     61
700aD ***Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
700aD ** OPGCDE moved to pos 76 as of 700
700aDD**opgcde                62     62
520 AD  oppkup                62     62
520 AD  opspal                63     63
520 AD  oppitm                64     67  0 inz(0)
650aAD  oplbl                 68     68
700aAD  opdddo                69     69
700aAD  opmcub                70     74  2 inz(0)
700aAD  wkmcub                70     74
700aAD  oppmtz                75     75
700aAD  opgcde                76     76
710aAD  opnbps                77     77  0 inz(0)
720aAD  opfwgt                78     81  0 inz(0)
720aAD  opfplt                82     87
720aAD  opbseq                88     89  0 inz(0)
720bAD  opsstp                90     91  0 inz(0)
740aAD  ozrfzp                92     92
740bAd  opicub                93     97  2 inz(0)
740bAd  oppisplt              98     98
740bAd  opmscb                99    100
740bAd  opmsvh               101    101
740bAd  opmsvm               102    102
740bAd  opmsvl               103    103
740bAd  opoacb               104    105  0 inz(0)
740bAd  opzplt               106    106
740bAd  opbplt               107    107
750 Ad  oppstuff             108    108
     D  opdend               117    117
     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - Added field OPPDEV.
     *
520 A*     08/12/09  RBD
     *       - Added notation for option OPAISL which was previously
     *         added to ZH122.
     *       - Added options OPTAXR and OPCHKR to *PICKLBL.
     *
     *----------------------------------------------------------------
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
300 A*    OPPDEV  -  Printer device.
300 A*    OPPFRM  -  Printer form.
520 A*    OPAISL  -  Print aisle change label (Y/N).
520 A*    OPTAXR  -  Include in Tax Right (Y=Yes, N=No).
520 A*    OPCHKR  -  Include in Check Right (Y=Yes, N=No).
     *
     * Data structure
     *
     D opdata          ds
     D  opclvl                 1      3  0 inz(0)
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0 inz(0)
     D  opcwgt                53     54  0 inz(0)
     D  oplpgm                55     64
300 AD  oppdev                65     74
300 AD  oppfrm                75     84
520 AD  opaisl                85     85
520 AD  optaxr                86     86
520 AD  opchkr                87     87
     D  optend               117    117
     *----------------------------------------------------------------
520 A*  *PICKLBA -  Label printing options for the standard pick,
     *              retail, and tote labels.
     *
520 A*     08/10/09  RBD  5.20  P#00219
     *       - Added record type *PICKLBA which holds printing info
     *         for the standard pick, retail, and tote labels.
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
520 AD opdata          ds
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
     D  optend               117    117
     *----------------------------------------------------------------
520 A*  *PICKLBB -  Label printing options for the pick list and
     *              ASN labels and pick list report.
     *
520 A*     08/10/09  RBD  5.20  P#00219
     *       - Added record type *PICKLBB which holds printing info
     *         for the pick list and ASN labels and pick list report.
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
530 A*    OPLB7   -  Print PICK labels for ZONPKUP D/S- Pick labels
     *
     * Data structure
     *
520 AD opdata          ds
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
530 AD  oplb7                 97     97
     D  optend               117    117
