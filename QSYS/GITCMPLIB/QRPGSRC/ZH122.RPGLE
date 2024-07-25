417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *                  WEBFACING REQUIREMENTS
     *
     * CHANGES TO THE DISPLAY FILE WILL REQUIRE THE F-SPEC TO BE
     * RENAMED TO THE NEXT SEQUENTIAL MEMBER NAME.
     *
     * I.E. ZH122FM WILL BE REPALCED WITH ZH12201
     *----------------------------------------------------------------
     *
     * ATTENTION: When adding new zone options, be sure to also add
     *            them to QRPGSRC/OPTIONZDS and OPTIONZDSL.
     *
     *----------------------------------------------------------------
     *
     *  ZH122     Zone maintenance - Change
     *  11 June 1997
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
402 A*    07/18/97  4.02  DAS
     *      - Changed '*PCKLBL' to 'PCKLBL' in routine ZZDFT3.
     *
405 A*    09/12/97  4.05  DAS
     *      - Recompiled because of screen changes.
     *
416 A*    06/20/01  4.16  MLB
     *      - Revised program to add new pallet building method,
     *        3=Descending by stop.
     *      - Revised *PICK options DS.
416aA*    07/30/01  4.16a MLB
     *      - Revised program to add ability to start new pallet for
     *        each aisle when build method is 2=Location.
     *      - Revised *PICK options DS.
416bA*    02/11/02  MLB  4.16b
     *      - Revised to call correct program. Should call
     *        TM910 instead of TP900.
     *      - Revised to pass warehouse to TM910.
500 A*    03/17/06  JCJ  5.00
     *      - Added new SCREEN1 options W1TOTE & W1TCUB
     *
500aA*    03/31/06  DAS  5.00a
     *      - Added new SCREEN2 options W2FPCS.
     *      - Fixed error in ZZGET1 routine.
     *      - Revised to force build type to 1 for Tote.
     *
500bA*    04/03/06  JCJ  5.00b
     *      - Added Truck Template heading to Screen 1, 2 & 3.
     *      - Activated *View.
     *
500cA*    04/04/06  DAS  5.00c
     *      - Added SCREEN2T for Totes.
     *      - Revised SCREEN1 tote option to Type.
     *      - Moved external cube from SCREEN1 to SCREEN2T.
     *      - Moved max pieces from SCREEN2 to SCREEN2T.
     *      - Changed OPTOTE to OPPTYP.
     *      - Changed W1TOTE to W1PTYP.
     *      - Revised ZZCHK1 so a parent zone cannot be a tote.
     *
500dA*    04/19/06  DAS  5.00d
     *      - Added new pallet per order option to Screen 2, 2T.
     *      - Added new pallet if stop doesn't fit to Screen 2, 2T.
     *      - Renamed some of the Tote options.
     *
510aA*    08/21/06  DAS  5.10a
     *      - Changed default of w2tord from 1 to 0. Re: Rule changed
     *        for totes from only having 1 order per tote to 1 stop
     *        per tote.
510bA*    09/05/06  MLB  5.10b
     *      - Enh: Revised above mod to add field W2TORD to screen.
     *        This will allow user to control number of orders per tote.
510cA*    11/22/06  JCJ  5.10c
     *      - Enh: Change edit of field W2TORD to only allow 0 or 1.
510dA*    01/03/07  JCJ  5.10d
     *      - Enh: Add picking option (Y/N) for *SP flag.  This flag
     *             will be used to identify whether or not to honor
     *             the *SP flag. The *SP code tells the system that
     *             this stop should be the only one on the pallet.
     *
510eA*    01/04/07  JCJ  5.10e
     *      - Enh: Add ability to enter group device code.
     *
510fA*    08/01/07  TJ   5.10f
     *      - Enh: Require Maximum Cube per pallet and Maximum Stops
     *        per pallet to both be greater than zero.
510gA*    08/27/07  MLB  5.10g
     *      - Enh: Revised program to check W3PDEV for '<' or '>'.
     *        If found, validate Printer Device as Device Group
     *        entry. Send error if device not on file.
     *      - Enh: Revised program to left adjust and strip any
     *        blanks found in W3PDEV field. Embedded blanks cause
     *        ovrprtf processing errors.
510hA*    08/28/07  MLB  5.10h
     *      - Enh: Revised program to check for valid characters
     *        in W3PDEV and W3FORM fields. Only @,#,$,_,0 thru 9
     *        and a thru z allowed.
     *
520aA*    03/03/09  JCJ  5.20a/ P#00048
     *      - Changed ZH122FM to ZH12201.  Add new option to
     *        control printing the aisle change label.
     *      - Convewrted to RPG4.
     *
520bA*    04/08/09  JCJ  5.20b
     *      - Changed to allow *STD form type.
520cA*    06/01/09  JCJ  5.20c
     *      - Changed ZH12201 to ZH12202.  Add new option to
     *      - Add edit for "Picked up by".
520dA*    08/12/09  RBD  5.20d  P#00219
     *      - Changed ZH12202 to ZH12203.
     *      - Revised screen1, added new zone type B = Batch.
     *      - Added screen2B, new batch pick zone details.
     *      - Revised screen3, added new Tax Right and Check
     *        Right options.
     *      - Removed print options from Screen3.
     *      - Added screen4 and screen5, print options for :
     *        Pick label        Retail label        Tote label
     *        ASN label         Pick list label     Pick list report
530 A*    12/14/09  JCJ  5.30
     *      - Changed ZH12203 to ZH12204.
     *      - Revised screen2, changed text about Fork Lifts.
     *      - Revised screen5, added merge detail/summary option.
530aA*    12/29/09  JCJ  5.30a
     *      - Revised screen4, to not clear the Pick label options
     *        if the print flag is changed from 'Y' to 'N'.
     *      - Revised screen5, to not clear the Pick List report
     *        options if the print flag is changed from 'Y' to 'N'.
530bA*    09/13/10  JCJ  5.30b
620aA*    11/06/10  DAS  6.10a
     *      - Renamed format to ZH12205.
     *      - Added zone type S=Separate for PrePicks
     *      - Added screen SCREEN2S.
620bA*    12/04/10  DAS  6.20b
     *      - Revised to allow QPRINT.
620cA*    12/07/10  DAS  6.20c
     *      - Revised to default pallet cube and stops to max values
     *        when creating an 'S' zone.
620dA*    12/16/10  DAS  6.20d
     *      - Revised to restrict when an 'S' zone can be created.
640aA*    05/12/11  DAS  6.40a
     *      - Revised to disable some options for TB Light.
640bA*    05/17/11  JCJ  6.40b
     *      - Fix: Changed Row checks for Compartment and zone, prompt
     *        requests.
     *      - Ehn: Do not allow embedded blanks in Zone name.  This
     *        is a GUI limitation.
640cA*    09/07/11  JCJ  6.40c
     *      - Renamed format to ZH12206.
     *      - Ehn: Added new loader question to SCREEN2T.
640dA*    05/22/12  JCJ  6.40d
     *      - Enh: Retrived round robin flag from general picking
     *        options.
650a *    05/04/13  GJA  6.50a
     *      - Enh: Added label printing option
     *      - Renamed format to ZH12207
700a *    11/04/16  NLK  7.00a
     *      - Enh: Chg ZH12207 dds-description only
     *        Compile RPG only-no chg here
720a *    10/11/18  DAS  7.20a
     *      -  Recompiled because of new ZONED fields
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordanos
     *
JOR A*    09/13/10  JCJ  JOR A
     *      -  Removed edit for Printer Device name (UT880CL) because
     *         Jordanos uses outq names instead of device names for
     *         their remote printers.  This causes UT880CL to return
     *         an error that the device is not valid.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
510hA*  81        Invalid characters found in W3PDEV or W3FORM.
500 A*  90,92     VIEW MODE (PROTECT INPUT FIELDS)
USF A*  93        VIEW MODE Protect W3LPGM field.
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
520aD *zh122fm   cf   e             workstn
520cD *h12201   cf   e             workstn
520dDF*h12202   cf   e             workstn
530 DF*h12203   cf   e             workstn
620aDF*h12204   cf   e             workstn
640cDF*h12205   cf   e             workstn
620aMF*zh12206   cf   e             workstn
650aMFzh12207   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fzoneh     uf a e           k disk
     F                                     rename(zhrec:record)
     Foptionz   uf a e           k disk
     Fwarehs    if   e           k disk
     Ftruckh    if   e           k disk
510eAFdevgrph   if   e           k disk
520dAFlblfmth   if   e           k disk
520dAFlblfmtt   if   e           k disk
620dAFzoned1    if   e           k disk
640dAFoptions   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
416aD*                   DESC    1  16 50
416aD*                   DESC    1  17 50
500aD*                   DESC    1  22 50
510bD*                   DESC    1  32 50
510bD*                   DESC    1  33 50
510dD*                   DESC    1  34 50
510hD*                   DESC    1  36 50
520aD *desc            s             50    dim(37) ctdata perrcd(1)
520cD *desc            s             50    dim(38) ctdata perrcd(1)
520dDD*desc            s             50    dim(41) ctdata perrcd(1)
620aDD*desc            s             50    dim(49) ctdata perrcd(1)
640bDD*desc            s             50    dim(50) ctdata perrcd(1)
640bMD*desc            s             50    dim(51) ctdata perrcd(1)
650aMD desc            s             50    dim(52) ctdata perrcd(1)

530 A*----------------------------------------------------------------
530 A*  Customer id
530 A*----------------------------------------------------------------
JOR A /COPY QCOPYSRC,ID#JORDANO

     *----------------------------------------------------------------
     *  Program parameters
     *
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
     D  $ptruk                22     31
     D  $pzone                32     37
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
     D  $lwhse                19     21  0
     D  $ltruk                22     31
     D  $lzone                32     37
     *
416bD*                                      19  19 $LCOMP
416bMD  $lcomp                22     22
     *----------------------------------------------------------------
     *  OPTIONZ data structure
     *
     D opzdta          ds
     D  opzend               117    117
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
     *----------------------------------------------------------------
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
416 A*                3 = By descening stop, then slot location.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
400 A*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
416aA*    OPNWPL  -  Start new pallet when aisle changes if build method
416aA*               is 2=Location.
500dA*    OPFORD  -  Maximun orders per pallet.
520dM*    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
500dA*    OPFTOT  -  Maximum totes per pallet.
500dA*    OPTECB  -  External tote cube.
500dA*    OPTICB  -  Internal tote cube.
500dA*    OPTSTP  -  Maximum stops per tote.
500dA*    OPTPCS  -  Maximum pieces per tote.
510dA*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
520dA*    OPGCDE  -  USF Group Code (0-9).
520cA*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520cA*    OPSPAL  -  Merge pallet should only contain
520cA*               items for single truck pallet (Y=Yes, N=No).
520dA*    OPPITM  -  Maximum items per pallet.
650aA*    OPLBL   -  Label printing method.
650aA*                N = Normal
650aA*                S = Side by Side
650aA*                C = Custom
     *
     * Data structure
     *
     D opdta1          ds
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
500 D*                                      37  37 OPBMRG
500 D*                                      38  38 OPNWPL
500 MD  opbmrg                37     37
500 MD  opnwpl                38     38
500dAD  opford                39     40  0 inz(0)
500cMD  opptyp                41     41
500dAD  opftot                42     43  0 inz(0)
500dAD  optecb                44     48  2 inz(0)
500dAD  opticb                49     53  2 inz(0)
500dAD  optstp                54     55  0 inz(0)
500dAD  optord                56     57  0 inz(0)
500dAD  optpcs                58     60  0 inz(0)
510dAD  opstop                61     61
520dA** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
520dAD**opgcde                62     62
520cAD  oppkup                62     62
520cAD  opspal                63     63
520dAD  oppitm                64     67  0 inz(0)
650aAD  oplbl                 68     68
     D  opend1               117    117
     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - Added field OPPDEV.
     *
520dA*     08/12/09  RBD
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
520aA*    OPAISL  -  Print aisle change label (Y/N).
520dA*    OPTAXR  -  Include in Tax Right (Y=Yes, N=No).
520dA*    OPCHKR  -  Include in Check Right (Y=Yes, N=No).
     *
     * Data structure
     *
     D opdta2          ds
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
520aAD  opaisl                85     85
520dAD  optaxr                86     86
520dAD  opchkr                87     87
     D  opend2               117    117
     *----------------------------------------------------------------
520dA*  *PICKLBA -  Label printing options for the standard pick,
520dA*              retail, and tote labels.
     *
520dA*     08/12/09  RBD  5.20  P#00219
520dA*       - Added record type *PICKLBA which holds printing info
520dA*         for the standard pick, retail, and tote labels.
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
520dA*  *PICKLBB -  Label printing options for the pick list and
520dA*               ASN labels and pick list report.
     *
520dA*     08/12/09  RBD  5.20  P#00219
520dA*       - Added record type *PICKLBB which holds printing info
520dA*         for the pick list and ASN labels and pick list report.
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
530 A*
530 A*    OPLB7   -  Print PICK labels for ZONPKUP D/S- Pick labels
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
530 AD  oplb7                 97     97
     D  opend4               117    117
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erulen                 1      3p 2
     D  eruwdt                 4      6p 2
     D  eruhgt                 7      9p 2
     D  ercalc                10     13p 3
     D  ercube                14     17p 3
     D  ercdiv                18     22p 2
     D  ercrng                23     24p 1
     D  ermax                 25     28p 4
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
500 A*
500 AD  erfld1                 1     20
500 AD  erfld2                21     40
500 AD  erfld3                41     43p 0 inz(0)
500 AD  erfld4                44     46p 0 inz(0)
     *
     D  eritem                 1     15
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
500bA*
     D #ztmp           c                   const('  TEMPLATE')
     D prefix          c                   const('<')
     D pstfix          c                   const('>')
     D valid           c                   const('@#$_ABCDEFGHIJKLMNOP-
     D                                     QRSTUVWXYZ0123456789-
     D                                      ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
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
     * Work Variables
     *----------------------------------------------------------------
640aMD $gfCmd          s              1
640aMD $gfFeature      s              1
640aMD $gfLight        s              1
640aMD $gfWhse         s              3p 0
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
620dMD error           s               n
620dAD forever         s               n
     D help            s              5  0
520dAD hldcu1          s              1
520dAD hldcu2          s              1
520dAD hldcu3          s              1
520dAD hlddev          s             10
520dAD hlddv1          s             10
520dAD hlddv2          s             10
520dAD hlddv3          s             10
520dAD hldlb1          s              1
520dAD hldlb2          s              1
520dAD hldlb3          s              1
520dAD hldlp1          s             10
520dAD hldlp2          s             10
520dAD hldlp3          s             10
     D kycod1          s                   like(opzcod)
     D kycod2          s                   like(opzcod)
520dAD kycod3          s                   like(opzcod)
520dAD kycod4          s                   like(opzcod)
520dAD lblfmthky       s              6
520dAD lblfmttky       s              8
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
     D pos             s              3  0
     D pos2            s              3  0
520dAD pr_asn          s              1
520dAD pr_mpick        s              1
520dAD pr_pcklst       s              1
520dAD pr_pick         s              1
520dAD pr_xtote        s              1
     D pznerr          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D sc2flg          s              1
     D sc3flg          s              1
520dAD sc4flg          s              1
640aMD tbLight         s               n
     D svzone          s                   like(zhzone)
     D warn            s              1
     D work1a          s              1
     D w2nxtp          s              7  0
     D w2tstp          s              2  0
640bAD len             S              3s 0 inz(0)
640bAD len2            S              3s 0 inz(0)
640bAD pos3            S              3s 0 inz(0)
640bAD pos4            S              6
640dDD $aut            S              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new record.
     *              *EDIT    - Edit record.
     *              *PRINT   - Print record.
     *              *VIEW    - View record.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for everything but *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new unique key for *ADD.
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
500 AC                   eval      *in92 = *off
     C                   eval      error = *off
     C                   eval      sc2flg = *off
     C                   eval      sc3flg = *off
520dAC                   eval      sc4flg = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
500cAC     nxtscr        caseq     '02T'         sc2t
520dAC     nxtscr        caseq     '02B'         sc2b
620aAC     nxtscr        caseq     '02S'         sc2s
     C     nxtscr        caseq     '03 '         sc3
620aAC     nxtscr        caseq     '03S'         sc3
520dAC     nxtscr        caseq     '04 '         sc4
520dAC     nxtscr        caseq     '05 '         sc5
     C                   endcs
     C                   enddo
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
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
500cAC                   if        nxtscr = '02T'
500cAC                   exfmt     screen2t                             50
500cAC                   endif
520dAC                   if        nxtscr = '02B'
520dAC                   exfmt     screen2b                             50
520dAC                   endif
620aAC                   if        nxtscr = '02S'
620aAC                   exfmt     screen2s                             50
620aAC                   endif
     C                   if        nxtscr = '03 '
     C                   exfmt     screen3                              50
     C                   endif
620aAC                   if        nxtscr = '03S'
620aAC                   exfmt     screen3s                             50
620aSC                   endif
520dAC                   if        nxtscr = '04 '
520dAC                   exfmt     screen4                              50
520dAC                   endif
520dAC                   if        nxtscr = '05 '
520dAC                   exfmt     screen5                              50
520dAC                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       394042
     C                   setoff                                       616263
     C                   setoff                                       646566
     C                   setoff                                       676869
     C                   setoff                                       70
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
     C                   eval      nxtscr = '01 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Refresh screen fields if requested.
     *
     C                   if        refrsh = *on
     *
     *     Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *     Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C                   endif
     C                   eval      refrsh = *off
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
500cAC**520dD            if        w1ptyp = 'T'
520dAC                   select
520dAC                   when      w1ptyp = 'T'
500cAC                   eval      nxtscr = '02T'
520dAC                   when      w1ptyp = 'B'
520dAC                   eval      nxtscr = '02B'
620aAC                   when      w1ptyp = 'S'
620aAC                   eval      nxtscr = '02S'
500cAC**520dD            else
520dAC                   other
     C                   eval      nxtscr = '02 '
500cAC**520dD            endif
520dAC                   endsl
     *
520cAC                   eval      *in29 = *on
640cD ***                if        w1ptyp = 'P'
640MAC                   if        (w1ptyp = 'P' or w1ptyp = 'T')
520cAC                             and w1pkup <> *blanks
520cAC                   eval      *in29 = *off
520cAC                   endif
520cA*
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Refresh screen fields if requested.
     *
     C                   if        refrsh = *on
     *
     *     Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
500cAC**520dD            if        nxtscr = '02T'
520dAC                   select
520dAC                   when      nxtscr = '02T'
500cAC                   exsr      zzdf2t
520dAC                   when      nxtscr = '02B'
520dAC                   exsr      zzdf2b
620aAC                   when      nxtscr = '02S'
620aAC                   exsr      zzdf2s
500cAC**520dD            else
520dAC                   other
     C                   exsr      zzdft2
500cAC**520dD            endif
520dAC                   endsl
     C                   else
     *
     *     Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
500cAC**520dD            if        nxtscr = '02T'
520dAC                   select
520dAC                   when      nxtscr = '02T'
500cAC                   exsr      zzfi2t
520dAC                   when      nxtscr = '02B'
520dAC                   exsr      zzfi2b
620aAC                   when      nxtscr = '02S'
620aAC                   exsr      zzfi2s
500cAC**520dD            else
520dAC                   other
     C                   exsr      zzfil2
500cAC**520dD            endif
520dAC                   endsl
     C                   endif
     C                   endif
     C                   eval      refrsh = *off
     C                   eval      sc2flg = *on
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
620aAC                   select
620aAC                   when      w1ptyp = 'S'
620aAC                   eval      nxtscr = '03S'
620aAC                   other
     C                   eval      nxtscr = '03 '
620aAC                   endsl
     *
520dA*  Refresh screen fields if requested.
     *
520dAC                   if        refrsh = *on
     *
     *     Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft3
     C                   else
     *
     *     Otherwise get existing record(s).
     *
     C                   exsr      zzfil3
     C                   endif
520dAC                   endif
     *
     C                   eval      refrsh = *off
     C                   eval      sc3flg = *on
     C     end03i        endsr
     *----------------------------------------------------------------
520dA*
520dA*  Screen 04 initialization
520dA*
520dAC     scr04i        begsr
     C                   eval      nxtscr = '04 '
     *
     *     Set screen protect input indicators based on LBLFMTT records.
     *
     C                   eval      *in94 = '0'
     C                   eval      *in95 = '0'
     C                   eval      *in96 = '0'
     C                   if        pr_pick = '1'
     C                   eval      *in94 = '1'
     C                   endif
     C                   if        pr_mpick = '1'
     C                   eval      *in95 = '1'
     C                   endif
     C                   if        pr_xtote = '1'
     C                   eval      *in96 = '1'
     C                   endif
     *
520dA*  Refresh screen fields if requested.
     *
520dAC                   if        refrsh = *on
     *
     *     Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft4
     C                   else
     *
     *     Otherwise get existing record(s).
     *
     C                   exsr      zzfil4
     C                   endif
520dAC                   endif
     *
     C                   eval      refrsh = *off
520dAC                   eval      sc4flg = *on
     C     end04i        endsr
     *----------------------------------------------------------------
520dA*
520dA*  Screen 05 initialization
520dA*
520dAC     scr05i        begsr
     C                   eval      nxtscr = '05 '
     *
     *     Set screen protect input indicators based on LBLFMTT records.
     *
530 AC                   eval      *in42 = *off
530 AC                   if        w1pzon <> *blanks
530 AC                   eval      *in42 = *on
530 AC                   endif
530 A*
     C                   eval      *in94 = '0'
     C                   eval      *in95 = '0'
     C                   eval      *in96 = '0'
     C                   if        pr_asn = '1'
     C                   eval      *in94 = '1'
     C                   endif
     C                   if        pr_pcklst = '1'
     C                   eval      *in95 = '1'
     C                   endif
     *
     *     Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft5
     C                   else
     *
     *     Otherwise get existing record(s).
     *
     C                   exsr      zzfil5
     C                   endif
     *
     C                   eval      refrsh = *off
     C     end05i        endsr
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
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '
217 D*R         $PCMD     OREQ '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
216 D*R                   EXSR ZZGET1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
217 AC                   if        $pcmd = '*CHANGE '
217 AC                   exsr      zzchk1
217 AC     error         cabeq     *on           endsc1
217 AC                   exsr      zzget1
217 AC                   exsr      zzupd1
217 AC     error         cabeq     *on           endsc1
217 AC                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so onto the next screen.
     *
     C                   if        sc2flg = *off
     C                   eval      refrsh = *on
     C                   else
     C                   eval      refrsh = *off
     C                   endif
     C                   exsr      scr02i
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr01i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so get out of program.
     *
520dAC                   if        sc3flg = *off
520dAC                   eval      refrsh = *on
520dAC                   else
520dAC                   eval      refrsh = *off
520dAC                   endif
     C                   exsr      scr03i
     C     endsc2        endsr
500cA*----------------------------------------------------------------
500cA*
500cA*  SC2T -  Screen 2T
500cA*
500cAC     sc2t          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      ends2t
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   endif
     C                   goto      ends2t
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr01i
     C                   goto      ends2t
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcm2t
     C     cmdtkn        cabeq     *on           ends2t
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzch2t
     C     error         cabeq     *on           ends2t
     C                   exsr      zzup2t
     C     error         cabeq     *on           ends2t
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcm2t
     C     cmdtkn        cabeq     *on           ends2t
     *
     *  Everything went fine so get out of program.
     *
520dAC                   if        sc3flg = *off
520dAC                   eval      refrsh = *on
520dAC                   else
520dAC                   eval      refrsh = *off
520dAC                   endif
     C                   exsr      scr03i
     C     ends2t        endsr
     *----------------------------------------------------------------
520dA*
520dA*  SC2B  -  Screen 2B
520dA*
520dAC     sc2b          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      ends2b
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   endif
     C                   goto      ends2b
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr01i
     C                   goto      ends2b
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcm2b
     C     cmdtkn        cabeq     *on           ends2b
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzch2b
     C     error         cabeq     *on           ends2b
     C                   exsr      zzup2b
     C     error         cabeq     *on           ends2b
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcm2b
     C     cmdtkn        cabeq     *on           ends2b
     *
     *  Everything went fine so get out of program.
     *
     C                   if        sc3flg = *off
     C                   eval      refrsh = *on
     C                   else
     C                   eval      refrsh = *off
     C                   endif
     C                   exsr      scr03i
     C     ends2b        endsr
620aA*----------------------------------------------------------------
620aA*
620aA*  SC2S  -  Screen 2S
620aA*
620aAC     sc2s          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      ends2s
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   endif
     C                   goto      ends2s
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr01i
     C                   goto      ends2s
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcm2s
     C     cmdtkn        cabeq     *on           ends2s
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzch2s
     C     error         cabeq     *on           ends2s
     C                   exsr      zzup2s
     C     error         cabeq     *on           ends2s
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcm2s
     C     cmdtkn        cabeq     *on           ends2s
     *
     *  Everything went fine so get out of program.
     *
     C                   if        sc3flg = *off
     C                   eval      refrsh = *on
     C                   else
     C                   eval      refrsh = *off
     C                   endif
     C                   exsr      scr03i
     C     ends2s        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr02i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     *
520dA*  Screen3 is no longer the last screen, thus, must wait
520dA*  until the last screen is processed to do zzupd3, which
520dA*  does the updating for ALL screens.
520dD**                 exsr      zzupd3
520dD**   error         cabeq     *on           endsc3
     *
     C                   endif
     *
520dA*  Everything went fine so move on to screen 4.
520dAC                   if        sc4flg = *off
520dAC                   eval      refrsh = *on
520dAC                   else
520dAC                   eval      refrsh = *off
520dAC                   endif
520dAC                   exsr      scr04i
     *
520dDC**                 eval      nxtscr = 'EOJ'
     C     endsc3        endsr
     *----------------------------------------------------------------
520dA*
520dA*  SC4  -  Screen 4
520dA*
520dAC     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   eval      refrsh = *on
     C                   exsr      scr04i
     C                   endif
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr03i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Everything went fine so move on to screen5.
     *
     C                   exsr      scr05i
     *
     C     endsc4        endsr
     *----------------------------------------------------------------
520dA*
520dA*  SC5  -  Screen 5
520dA*
520dAC     sc5           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr05i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scr04i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
     *
     *   You've successfully processed the last screen, now go
     *   do all of the updating, which is in zzupd3.
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc5
     C                   endif
     *
     C                   eval      nxtscr = 'EOJ'
     *
     C     endsc5        endsr
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
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
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
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
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
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
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
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
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
     *----------------------------------------------------------------
     *   PIR0109  Number can not be less than zero.
     *
     C     zm0109        begsr
     C                   eval      #msgid = 'PIR0109'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Number must be greater than zero.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
500 A*----------------------------------------------------------------
500 A*   PIR1016  Field 1 must be less than or equal to field 2.
500 A*----------------------------------------------------------------
500 AC     zm1016        begsr
500 AC                   eval      #msgid = 'PIR1016'
500 AC                   eval      #msgtp = '*DIAG  '
500 AC                   movea     errmsg        $md(1)
500 AC                   exsr      zmpmsg
500 AC                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
500 A*----------------------------------------------------------------
500 A*   PIR1015  Value must Blank
500 A*
500 AC     zm1015        begsr
500 AC                   eval      #msgid = 'PIR1015'
500 AC                   eval      #msgtp = '*DIAG  '
500 AC                   movea     errmsg        $md
500 AC                   exsr      zmpmsg
500 AC                   endsr
416aA*----------------------------------------------------------------
416aA*   PIR1052  New pallet for each aisle not allowed unless Build=2.
416aA*
416aAC     zm1052        begsr
416aAC                   eval      #msgid = 'PIR1052'
416aAC                   eval      #msgtp = '*DIAG  '
416aAC                   movea     desc          errmsg
416aAC                   movea     errmsg        $md(1)
416aAC                   exsr      zmpmsg
416aAC                   endsr
500dA*----------------------------------------------------------------
500dA*   PIR1062  New pallet for each order only allowed for Build=1/3
500dA*
500dAC     zm1062        begsr
500dAC                   eval      #msgid = 'PIR1062'
500dAC                   eval      #msgtp = '*DIAG  '
500dAC                   movea     desc          errmsg
500dAC                   movea     errmsg        $md(1)
500dAC                   exsr      zmpmsg
500dAC                   endsr
500dA*----------------------------------------------------------------
500dA*   PIR1063  New pallet if stop doesn't fit only allowed for Build=1/3
500dA*
500dAC     zm1063        begsr
500dAC                   eval      #msgid = 'PIR1063'
500dAC                   eval      #msgtp = '*DIAG  '
500dAC                   movea     desc          errmsg
500dAC                   movea     errmsg        $md(1)
500dAC                   exsr      zmpmsg
500dAC                   endsr
500dA*----------------------------------------------------------------
500dA*   PIR1064  Stop must be 1 when new pallet per order = Y
500dA*
500dAC     zm1064        begsr
500dAC                   eval      #msgid = 'PIR1064'
500dAC                   eval      #msgtp = '*DIAG  '
500dAC                   movea     desc          errmsg
500dAC                   movea     errmsg        $md(1)
500dAC                   exsr      zmpmsg
500dAC                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
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
     *   TK12221  Parent zone can not be same as above zone.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'TK12221'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TK12222  Zone must be entered when compartment is blank.
     *
     C     zm22          begsr
     C                   eval      #msgid = 'TK12222'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   TK12223  Zone can not be entered when compartment is not blank.
     *
     C     zm23          begsr
     C                   eval      #msgid = 'TK12223'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     *
     *    Make sure code was entered.
     *
     C                   if        w1zone = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm01
620dAC                   leavesr
     C                   endif
     *
     *    Make sure code doesn't already exist.
     *
     C                   eval      $pzone = w1zone
     C     fileky        chain(n)  record                             79
     C                   if        not *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm02
620dAC                   leavesr
     C                   endif
620dA
620dA*    If zone type is 'S', check to see if it is allowed
620dA
620dAC                   if        w1ptyp = 'S'
620dAC                   exsr      zzIsSZoneOk
620dAC                   if        error
620dAC                   leavesr
620dAC                   endif
620dAC                   endif
620dA
     C                   endif
640bA*
640bA* Edit for embedded blanks in zone name.
640bA*
640bAC                   if        w1zone <> *blanks
640bAC                   eval      len  = %len(w1zone)
640bAC                   eval      pos3 = %scan(' ':w1zone)
640bAC                   if        pos3 < len
640bAC                             and pos3 <> 0
640bAC                   eval      len2 = len - pos3
640bAC                   eval      pos4 = %subst(w1zone:(pos3+1):len2)
640bAC                   if        pos4 <> *blanks
640bAC                   eval      error = *on
640bAC                   eval      *in21 = *on
640bAC                   eval      errmsg = *blanks
640bAC                   eval      errmsg = desc(50)
640bAC                   exsr      zm0105
620bAC                   leavesr
640bAC                   endif
640bAC                   endif
640bAC                   endif
     *
     *  Verify compartment.
     *
     C                   if        w1comp <> *blanks
     C                   eval      $lcmd = '*VERIFY '
416bAC                   eval      $lwhse = $pwhse
     C                   eval      $lcomp = w1comp
416bD*R                   CALL 'TP900'
416bMC                   call      'TM910'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Parent zone can not be entered when compartment is not blank.
     *
     C                   eval      pznerr = *off
     C                   if        w1comp <> *blank  and
     C                             w1pzon <> *blank
     C                   eval      error = *on
     C                   eval      pznerr = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm23
     C                   endif
     *
     *  Parent zone must be entered when compartment is blank.
     *
     C                   if        pznerr = *off  and
     C                             w1comp = *blank  and
     C                             w1pzon = *blank
     C                   eval      error = *on
     C                   eval      pznerr = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm22
     C                   endif
     *
     *  Parent zone can not be same as zone being edited.
     *
     C                   if        pznerr = *off  and
     C                             w1zone = w1pzon
     C                   eval      error = *on
     C                   eval      pznerr = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm21
     C                   endif
     *
     *  Verify parent zone.
     *
     C                   if        pznerr = *off  and
     C                             w1pzon <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $pwhse
     C                   eval      $ltruk = $ptruk
     C                   eval      $lzone = w1pzon
     C                   call      'ZH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
500cA*
500cA*  Parent zone can not be a Tote.
620dA*   or a Separate Pick zone.
500cA*
500cAC                   if        w1pzon <> *blanks
500cAC     mergky        chain(n)  optionz                            79
500cAC                   if        not *in79
500cAC                   eval      opdta1 = opzdta
500cAC                   if        opptyp = 'T'
620aDC                             or opptyp = 'S'
500cAC                   eval      error = *on
500cAC                   eval      *in24 = *on
500cAC                   eval      *in04 = *on
500cAC                   eval      errmsg = *blanks
500cAC                   eval      errmsg = desc(30)
500cAC                   exsr      zm0105
500cAC                   endif
500cAC                   endif
500cAC                   endif
640aA*
640aA* Zone type must be 'P' for TB Light.
640aA*
640aAC                   if        tbLight and w1ptyp <> 'P'
640aAC                   eval      error = *on
640aAC                   eval      *in25 = *on
640aAC                   eval      *in05 = *on
640aAC                   eval      errmsg = 'Zone type must be P for '
640aAC                                    + 'TB Light version'
640aAC                   exsr      zm0105
640aAC                   leavesr
640aAC                   endif
500 A*
620aM* Zone type must be 'P' or 'T' or 'B'  or 'S'
500 A*
500cMC                   if        w1ptyp <> 'P'  and
520dMC                             w1ptyp <> 'T'  and
620aAC                             w1ptyp <> 'S'  and
520dAC                             w1ptyp <> 'B'
500 AC                   eval      error = *on
500 AC                   eval      *in25 = *on
500 AC                   eval      *in05 = *on
500 AC                   eval      errmsg = *blanks
500 AC                   eval      errmsg = desc(18)
500cMC                   exsr      zm1001
500 AC                   endif
500 A*
500 A* If zone type is 'T' truck compartment must be blank.
500 A*
500cMC                   if        w1ptyp = 'T'  and
500 AC                             w1comp <> *blanks
500 AC                   eval      error = *on
500 AC                   eval      *in25 = *on
500 AC                   eval      *in05 = *on
500 AC                   eval      errmsg = *blanks
500 AC                   eval      errmsg = desc(20)
500 AC                   exsr      zm1015
500 AC                   endif
520dA*
520dA* If zone type is 'B', parent zone and picked up by must
520dA* be blank.
520dA*
520dAC                   if        w1ptyp = 'B' and
520dAC                             w1pzon <> *blanks or
520dAC                             w1ptyp = 'B' and
520dAC                             w1pkup <> *blanks
520dAC                   eval      error = *on
520dAC                   eval      *in25 = *on
520dAC                   eval      *in05 = *on
520dAC                   eval      errmsg = *blanks
520dAC                   eval      errmsg = desc(42)
520dAC                   exsr      zm0105
520dAC                   endif
620aA*
620aA* If zone type is 'S', parent zone and picked up by must
620aA* be blank.
620aA*
620aAC                   if        w1ptyp = 'S' and
620aAC                             w1pzon <> *blanks or
620aAC                             w1ptyp = 'S' and
620aAC                             w1pkup <> *blanks
620aAC                   eval      error = *on
620aAC                   eval      *in25 = *on
620aAC                   eval      *in05 = *on
620aAC                   eval      errmsg = *blanks
620aAC                   eval      errmsg = desc(50)
620aAC                   exsr      zm0105
620aAC                   endif
     *
510dAC                   if        w1stop <> 'Y'  and
510dAC                             w1stop <> 'N'
510dAC                   eval      error = *on
510dAC                   eval      *in26 = *on
510dAC                   eval      *in06 = *on
510dAC                   eval      errmsg = *blanks
510dAC                   eval      errmsg = desc(34)
510dAC                   exsr      zm1005
510dAC                   endif
520cA*
520cA* Pickup must be 'S' or 'L'
520cA*
520cAC                   if        w1pzon <> *blanks
520cAC                   if        w1pkup <> 'S'  and
520cAC                             w1pkup <> 'L'
520cAC                   eval      error = *on
520cAC                   eval      *in27 = *on
520cAC                   eval      *in07 = *on
520cAC                   eval      errmsg = *blanks
520cAC                   eval      errmsg = desc(39)
522cAC                   exsr      zm1001
520cAC                   endif
520cAC                   endif
     *
520cAC                   if        w1pkup <> *blanks
500 AC                             and w1pzon = *blanks
520cAC                   eval      error = *on
520cAC                   eval      *in27 = *on
520cAC                   eval      *in07 = *on
520cAC                   eval      errmsg = *blanks
520cAC                   eval      errmsg = desc(40)
520cAC                   exsr      zm0105
520cAC                   endif
640aA*
640aA* Only 'S' allowed for Pickup By in TB Light
640aA*
640aAC                   if        tbLight
640aAC                             and w1pzon <> ' ' and w1pkup <> 'S'
640aAC                   eval      error = *on
640aAC                   eval      *in27 = *on
640aAC                   eval      *in07 = *on
640aAC                   eval      errmsg = 'Pick Up must be S for '
640aAC                                    + 'TB Light version'
640aAC                   exsr      zm0105
640aAC                   leavesr
640aAC                   endif
510dA*
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     *  Verify minimum cube for bulk pick.
     *
     C                   if        w2bpck < 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0109
     C                   endif
     *
     *  Verify pallet on fixed fork lift.
     *
     C                   if        w2fpal < 1
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(4)
     C                   exsr      zm0110
     C                   endif
     *
     *  Verify fixed max cube.
     *
510fD****       W2FCUB    IFLT 0
510fMC                   if        w2fcub <= 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(5)
510fD****                 EXSR ZM0109
510fMC                   exsr      zm0110
     C                   endif
     *
     *  Verify fixed max stops.
     *
510fD****       W2FSTP    IFLT 0
510fMC                   if        w2fstp <= 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(6)
510fD****                 EXSR ZM0109
510fMC                   exsr      zm0110
     C                   endif
500dAC                   if        w2fstp > 1  and
500dAC                             w2ford = 'Y'
500dAC                   eval      error = *on
500dAC                   eval      *in24 = *on
500dAC                   eval      *in04 = *on
500dAC                   eval      errmsg = *blanks
500dAC                   eval      errmsg = desc(27)
500dAC                   exsr      zm1064
500dAC                   endif
     *
     *  Verify pallet building method.
     *
     C                   if        w2pbld <> '1'  and
     C                             w2pbld <> '2'  and
416 AC                             w2pbld <> '3'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(14)
     C                   exsr      zm1001
     C                   endif
416aA*
416aA*  Verify New pallet for each aisle.
416aA*
416aAC                   if        w2nwpl <> 'Y'  and
416aAC                             w2nwpl <> 'N'
416aAC                   eval      error = *on
416aAC                   eval      *in26 = *on
416aAC                   eval      *in06 = *on
416aAC                   eval      errmsg = *blanks
416aAC                   eval      errmsg = desc(17)
416aAC                   exsr      zm1005
416aAC                   endif
416aA*
416aA*  New pallet for each aisle allowed only when build method
416aA*  is 2=Location.
416aA*
416aAC                   if        w2nwpl = 'Y'  and
416aAC                             w2pbld <> '2'
416aAC                   eval      error = *on
416aAC                   eval      *in26 = *on
416aAC                   eval      *in06 = *on
416aAC                   eval      errmsg = *blanks
416aAC                   exsr      zm1052
416aAC                   endif
500dA*
500dA*  Verify New pallet for each order option.
500dA*
500dAC                   if        w2ford <> 'Y'  and
500dAC                             w2ford <> 'N'
500dAC                   eval      error = *on
500dAC                   eval      *in27 = *on
500dAC                   eval      *in07 = *on
500dAC                   eval      errmsg = *blanks
500dAC                   eval      errmsg = desc(29)
500dAC                   exsr      zm1005
500dAC                   endif
500dA*
500dA*  New pallet for each order allowed only when build method
500dA*  is 1-By Stop or 3=Desc By Stop
500dA*
500dAC                   if        w2ford = 'Y'  and
500dAC                             w2pbld <> '1'  and
500dAC                             w2pbld <> '3'
500dAC                   eval      error = *on
500dAC                   eval      *in27 = *on
500dAC                   eval      *in07 = *on
500dAC                   eval      errmsg = *blanks
500dAC                   exsr      zm1062
500dAC                   endif
520cA*
520cA*  Verify Merge pallet should only contain items for single truck
520cA*  truvk pallet.
520cA*
520cAC                   if        w2spal <> 'Y'
520cAC                             and w2spal <> 'N'
520cAC                   eval      error = *on
520cAC                   eval      *in28 = *on
520cAC                   eval      *in08 = *on
520cAC                   eval      errmsg = *blanks
520cAC                   eval      errmsg = desc(41)
520cAC                   exsr      zm1005
520cAC                   endif
500dA*
500dA*  Initialize unused tote fields.
500dA*
500dAC                   eval      opftot = 0
500dAC                   eval      optecb = 0
500dAC                   eval      opticb = 0
500dAC                   eval      optstp = 0
500dAC                   eval      optord = 0
500dAC                   eval      optpcs = 0
     *
     C     endck2        endsr
500cA*----------------------------------------------------------------
500cA*
500cA*  ZZCH2T   Screen 2T error checking.
500cA*
500cAC     zzch2t        begsr
     C                   eval      error = *off
500dAC                   eval      w2ftot = 1
500dAC                   eval      w2ford = 'N'
510bA*
510bA*  Verify Orders per tote option. 0=Unlimited.
510bA*
510bAC                   if        w2tord < 0  or
510cAC                             w2tord > 1
510bAC                   eval      error = *on
510bAC                   eval      *in26 = *on
510bAC                   eval      *in06 = *on
510bAC                   eval      errmsg = *blanks
510bAC                   eval      errmsg = desc(33)
510cD***                  EXSR ZM0109
510cAC                   exsr      zm0105
510bAC                   endif
     *
     *  Verify external tote cube.
     *
     C                   if        w2tecb < 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(19)
     C                   exsr      zm0109
     C                   endif
     *
     *  Verify internal tote cube.
     *
     C                   select
     C                   when      w2ticb > w2tecb
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(21)      erfld1
     C                   movel     desc(22)      erfld2
     C                   eval      erfld3 = w2tecb
500cMC                   eval      erfld4 = w2ticb
     C                   exsr      zm1016
     C                   when      w2ticb < 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(26)
     C                   exsr      zm0109
     C                   endsl
     *
     *  Verify fixed max pieces.
     *
     C                   if        w2tpcs < 0
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(23)
     C                   exsr      zm0109
     C                   endif
     *
     *  Verify totes per pallet.
     *
     C                   if        w2ftot < 1
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(25)
     C                   exsr      zm0110
     C                   endif
     *
     *  Verify maximum stops per pallet.
     *
     C                   if        w2fstp < 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(27)
     C                   exsr      zm0109
     C                   endif
     C                   if        w2fstp = 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(27)
     C                   exsr      zm0110
     C                   endif
500dAC                   if        w2fstp > 1  and
500dAC                             w2ford = 'Y'
500dAC                   eval      error = *on
500dAC                   eval      *in24 = *on
500dAC                   eval      *in04 = *on
500dAC                   eval      errmsg = *blanks
500dAC                   eval      errmsg = desc(27)
500dAC                   exsr      zm1064
500dAC                   endif
     *
     *  Verify pallet building method.
     *    Option 2 by location is not allowed for Totes.
     *
     C                   if        w2pbld <> '1'  and
     C                             w2pbld <> '3'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(28)
     C                   exsr      zm1001
     C                   endif
500dA*
500dA*  Verify New pallet for each order option.
500dA*
500dAC                   if        w2ford <> 'Y'  and
500dAC                             w2ford <> 'N'
500dAC                   eval      error = *on
500dAC                   eval      *in27 = *on
500dAC                   eval      *in07 = *on
500dAC                   eval      errmsg = *blanks
500dAC                   eval      errmsg = desc(29)
500dAC                   exsr      zm1005
500dAC                   endif
500dA*
500dA*  New pallet for each order allowed only when build method
500dA*  is 1-By Stop or 3=Desc By Stop
500dA*
500dAC                   if        w2ford = 'Y'  and
500dAC                             w2pbld <> '1'  and
500dAC                             w2pbld <> '3'
500dAC                   eval      error = *on
500dAC                   eval      *in27 = *on
500dAC                   eval      *in07 = *on
500dAC                   eval      errmsg = *blanks
500dAC                   exsr      zm1062
500dAC                   endif
640cA*
640cA*  Verify Merge pallet should only contain items for single truck
640cA*  truvk pallet.
640cA*
640cAC                   if        w2spal <> 'Y'
640cAC                             and w2spal <> 'N'
640cAC                   eval      error = *on
640cAC                   eval      *in28 = *on
640cAC                   eval      *in08 = *on
640cAC                   eval      errmsg = *blanks
640cAC                   eval      errmsg = desc(41)
640cAC                   exsr      zm1005
640cAC                   endif
650aA*
650aA*  Verify Label printing method.
650aA*
650aAC                   if        w2plbl <> 'N'
650aAC                             and w2plbl <> 'S'
650aAC                             and w2plbl <> 'C'
650aAC                   eval      error = *on
650aAC                   eval      *in30 = *on
650aAC                   eval      *in13 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   eval      errmsg = desc(52)
650aAC                   exsr      zm1005
650aAC                   endif
500dA*
500dA*  Initialize hard coded tote fields.
500dA*
500dAC                   eval      w2bpck = 999
500dAC                   eval      w2tstp = 1
510aD**                   Z-ADD1         W2TORD  20
510bD*                    Z-ADD0         W2TORD  20
500dAC                   eval      w2fcub = 999
     *
     C     endc2t        endsr
     *----------------------------------------------------------------
520dA*
520dA*  ZZCH2B   Screen2B error checking.
520dA*
520dAC     zzch2b        begsr
     C                   eval      error = *off
     *
     *  Verify minimum cube for bulk pick.
     *
     C                   if        w2bpck < 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0109
     C                   endif
     *
     *  Verify pallet on fixed fork lift.
     *
     C                   if        w2fpal < 1
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(4)
     C                   exsr      zm0110
     C                   endif
     *
     *  Verify fixed max cube.
     *
     C                   if        w2fcub <= 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(5)
     C                   exsr      zm0110
     C                   endif
     *
     *  Verify fixed max stops.
     *
     C                   if        w2fstp <= 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(6)
     C                   exsr      zm0110
     C                   endif
     C                   if        w2fstp > 1  and
     C                             w2ford = 'Y'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(27)
     C                   exsr      zm1064
     C                   endif
     *
     *  Verify maximum items per pallet.
     *
     C                   if        w2pitm <> 1
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(43)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify pallet building method.
     *
     C                   if        w2pbld <> '1'  and
     C                             w2pbld <> '2'  and
     C                             w2pbld <> '3'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(14)
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify New pallet for each aisle.
     *
     C                   if        w2nwpl <> 'Y'  and
     C                             w2nwpl <> 'N'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(17)
     C                   exsr      zm1005
     C                   endif
     *
     *  New pallet for each aisle allowed only when build method
     *  is 2=Location.
     *
     C                   if        w2nwpl = 'Y'  and
     C                             w2pbld <> '2'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1052
     C                   endif
     *
     *  Verify New pallet for each order option.
     *
     C                   if        w2ford <> 'Y'  and
     C                             w2ford <> 'N'
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(29)
     C                   exsr      zm1005
     C                   endif
     *
     *  New pallet for each order allowed only when build method
     *  is 1-By Stop or 3=Desc By Stop
     *
     C                   if        w2ford = 'Y'  and
     C                             w2pbld <> '1'  and
     C                             w2pbld <> '3'
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1062
     C                   endif
     *
     *  Initialize unused fields.
     *
     C                   eval      opftot = 0
     C                   eval      optecb = 0
     C                   eval      opticb = 0
     C                   eval      optstp = 0
     C                   eval      optord = 0
     C                   eval      optpcs = 0
     C                   eval      opspal = ' '
     *
     C     endc2b        endsr
620aA*----------------------------------------------------------------
620aA*
620aA*  ZZCH2S   Screen2S error checking.
620aA*
620aAC     zzch2s        begsr
     C                   eval      error = *off
     *
     *  Verify pallet on fixed fork lift.
     *
     C                   if        w2fpal < 1
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(4)
     C                   exsr      zm0110
     C                   endif
     *
     *  Initialize unused fields.
     *
     C                   eval      opftot = 0
     C                   eval      optecb = 0
     C                   eval      opticb = 0
     C                   eval      optstp = 0
     C                   eval      optord = 0
     C                   eval      optpcs = 0
     C                   eval      opspal = ' '
     *
     C     endc2s        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     *
     *  Verify default device
     *
510eAC*520dD prefix        scan      w3pdev        pos
510gAC*520dD pstfix        scan      w3pdev        pos2
510gD*          POS       IFEQ 1
510gMC*520dD             if        pos >= 1  and
510eAC*520dD                       $aut = 'N'  or
510gAC*520dD                       pos2 >= 1  and
510gAC*520dD                       $aut = 'N'
510eAC*520dD             eval      error = *on
510eAC*520dD             eval      *in22 = *on
510eAC*520dD             eval      *in02 = *on
510eAC*520dD             eval      errmsg = *blanks
510eAC*520dD             eval      errmsg = desc(36)
510eAC*520dD             exsr      zm0105
510eAC*520dD             endif
510hA*
510gD*          POS       IFEQ 1
510gMC*520dD             if        pos >= 1  or
510gAC*520dD                       pos2 >= 1
510eAC*520dD devgky        chain     devgrph                            79
510eAC*520dD             if        *in79
510eAC*520dD             eval      error = *on
510eAC*520dD             eval      *in22 = *on
510eAC*520dD             eval      *in02 = *on
510eAC*520dD             eval      errmsg = *blanks
510eAC*520dD             eval      errmsg = desc(35)
510eAC*520dD             exsr      zm0105
510eAC*520dD             endif
510eAC*520dD             else
510eA*
510hA*    Check for invalid characters in Printer Device name. 81=Yes.
510hAC*520dD             eval      *in81 = *off
510hAC*520dD valid         check     w3pdev                                 81
510hA*    Printer Device cannot start with underscore character.
510hAC*520dD '_'           scan      w3pdev        pos
510hA*
     C*520dD             movel     w3pdev        work1a
     C*520dD             if        work1a = '*'  and
     C*520dD                       w3pdev <> '*SYSVAL'  and
     C*520dD                       w3pdev <> '*JOB'  or
     C*520dD                       w3pdev = *blanks  or
510hAC*520dD                       *in81  and
510hAC*520dD                       work1a <> '*'  or
510hAC*520dD                       pos = 1
     C*520dD             eval      error = *on
     C*520dD             eval      *in22 = *on
     C*520dD             eval      *in02 = *on
     C*520dD             eval      errmsg = *blanks
510hA*    Printer Device cannot start with underscore character.
510hAC*520dD             if        pos = 1
510hAC*520dD             eval      errmsg = desc(37)
510hAC*520dD             exsr      zm0105
510hAC*520dD             else
     C*520dD             eval      errmsg = desc(15)
     C*520dD             exsr      zm1001
510hAC*520dD             endif
510gA*
510gAC*520dD             else
510gA*    Strip embedded blanks from printer device name.
510gAC*520dD             eval      $cstr = w3pdev
510gAC*520dD             call      'ADJUST'
510gAC*520dD             parm      '*LTSTRIP'    $ccmd             8
510gAC*520dD             parm                    $cstr            30
510gAC*520dD             movel     $cstr         w3pdev
     C*520dD             endif
510eAC*520dD             endif
     *
     *  Verify default form type
     *
510hA*    Check for invalid characters in Form Type name. 81=Yes.
510hAC*520dD             eval      *in81 = *off
510hAC*520dD valid         check     w3form                                 81
510hA*
     C*520dD             movel     w3form        work1a
     C*520dD             if        work1a = '*'
     C*520dD                       and w3form <> '*STD'
     C*520dD                       or  w3form = *blanks
510hAC*520dD                       or  *in81
520bAC*520dD                       and work1a <> '*'
     C*520dD             eval      error = *on
     C*520dD             eval      *in30 = *on
     C*520dD             eval      *in11 = *on
     C*520dD             eval      errmsg = *blanks
     C*520dD             eval      errmsg = desc(16)
     C*520dD             exsr      zm1001
510gA*
510gAC*520dD             else
510gA*    Strip embedded blanks from form type entry.
510gAC*520dD             eval      $cstr = w3form
510gAC*520dD             call      'ADJUST'
510gAC*520dD             parm      '*LTSTRIP'    $ccmd
510gAC*520dD             parm                    $cstr
510gAC*520dD             movel     $cstr         w3form
     C*520dD             endif
     *
     *  Verify qty level for combined labels.
     *
     C                   if        w3clvl < 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(7)
     C                   exsr      zm0109
     C                   endif
     *
     *  Verify print combined label warning before option.
     *
     C                   if        w3cwrb <> 'Y'  and
     C                             w3cwrb <> 'N'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(8)
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify print combined label warning after option.
     *
     C                   if        w3cwra <> 'Y'  and
     C                             w3cwra <> 'N'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(9)
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify print unit of measure warning before option.
     *
     C                   if        w3uwrb <> 'Y'  and
     C                             w3uwrb <> 'N'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(10)
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify print unit of measure warning after option.
     *
     C                   if        w3uwra <> 'Y'  and
     C                             w3uwra <> 'N'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(11)
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify discrepancy ratio.
     *
     C                   if        w3err < 0
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(12)
     C                   exsr      zm0109
     C                   endif
     *
     *  Verify catch weight ratio.
     *
     C                   if        w3cwgt < 0
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(13)
     C                   exsr      zm0109
     C                   endif
520aA*
520aA*  Verify aisle change flag.
520aA*
520aAC                   if        w3aisl <> 'N'
520aAC                             and w3aisl <> 'Y'
520aAC                   eval      error = *on
520aAC                   eval      *in31 = *on
520aAC                   eval      *in12 = *on
520aAC                   eval      errmsg = *blanks
416aAC                   eval      errmsg = desc(38)
416aAC                   exsr      zm1005
520aAC                   endif
     *
520dA*  Verify Tax Right flag.
520dA*
520dAC                   if        w3taxr <> 'Y'
520dAC                             and w3taxr <> 'N'
520dAC                   eval      error = *on
520dAC                   eval      *in21 = *on
520dAC                   eval      *in01 = *on
520dAC                   eval      errmsg = *blanks
520dAC                   eval      errmsg = desc(44)
520dAC                   exsr      zm1005
520dAC                   endif
640aA*
640aA* Tax Right not allowed in TB Light
640aA*
640aAC                   if        tbLight and w3taxr = 'Y'
640aAC                   eval      error = *on
640aAC                   eval      *in21 = *on
640aAC                   eval      *in01 = *on
640aAC                   eval      errmsg = 'Tax Right not allowed in '
640aAC                                    + 'TB Light version'
640aAC                   exsr      zm0105
640aAC                   leavesr
640aAC                   endif
     *
520dA*  Verify Check Right flag.
520dA*
520dAC                   if        w3chkr <> 'Y'
520dAC                             and w3chkr <> 'N'
520dAC                   eval      error = *on
520dAC                   eval      *in22 = *on
520dAC                   eval      *in02 = *on
520dAC                   eval      errmsg = *blanks
520dAC                   eval      errmsg = desc(45)
520dAC                   exsr      zm1005
520dAC                   endif
640aA*
640aA* Check Right not allowed in TB Light
640aA*
640aAC                   if        tbLight and w3chkr = 'Y'
640aAC                   eval      error = *on
640aAC                   eval      *in22 = *on
640aAC                   eval      *in02 = *on
640aAC                   eval      errmsg = 'Check Right not allowed in '
640aAC                                    + 'TB Light version'
640aAC                   exsr      zm0105
640aAC                   leavesr
640aAC                   endif
     *
     C     endck3        endsr
     *----------------------------------------------------------------
520dA*
520dA*  ZZCHK4     Screen 4 error checking.
520dA*
520dAC     zzchk4        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to hold fields for editing.
     *  Verify Print option, Cutter option, Program, Device.
     *
     C                   eval      hldlb1 = w4lb1
     C                   eval      hldcu1 = w4cu1
     C                   eval      hldlp1 = w4lp1
     C                   eval      hlddv1 = w4dv1
     C                   eval      hldlb2 = w4lb2
     C                   eval      hldcu2 = w4cu2
     C                   eval      hldlp2 = w4lp2
     C                   eval      hlddv2 = w4dv2
     C                   eval      hldlb3 = w4lb3
     C                   eval      hldcu3 = w4cu3
     C                   eval      hldlp3 = w4lp3
     C                   eval      hlddv3 = w4dv3
     C                   exsr      ZZChkPrtOpt
     *
     *  Verify Form.
     *
     *    PICK label.
     C                   if        w4lb1 = 'Y'
     *
     *    Check for invalid characters in Form Type name. 81=Yes.
     *
     C                   eval      *in81 = *off
     C     valid         check     w4fm1                                  81
     C                   movel     w4fm1         work1a
     C                   if        work1a = '*'
     C                             and w4fm1 <> '*STD'
     C                             or  w4fm1 = *blanks
     C                             or  *in81
     C                             and work1a <> '*'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(16)
     C                   exsr      zm1001
     *
     C                   else
     *    Strip embedded blanks from form type entry.
     C                   eval      $cstr = w4fm1
     C                   call      'ADJUST'
     C                   parm      '*LTSTRIP'    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         w4fm1
     C                   endif
     C                   else
     *    PICK label printing set to 'N', set default values.
530aM ****               eval      w4cu1 = 'N'
530aM ****               eval      w4lp1 = ' '
530aM ****               eval      w4dv1 = ' '
530aM ****               eval      w4fm1 = ' '
     C                   endif
640aA*
640aA* Retail labels not allowed in TB Light
640aA*
640aAC                   if        tbLight and w4lb2 = 'Y'
640aAC                   eval      error = *on
640aAC                   eval      *in30 = *on
640aAC                   eval      *in10 = *on
640aAC                   eval      errmsg = 'Retail labels not allowed in '
640aAC                                    + 'TB Light version'
640aAC                   exsr      zm0105
640aAC                   leavesr
640aAC                   endif
     *
     *    RETAIL label.
     C                   if        w4lb2 = 'Y'
     *
     *    Check for invalid characters in Form Type name. 81=Yes.
     *
     C                   eval      *in81 = *off
     C     valid         check     w4fm2                                  81
     C                   movel     w4fm2         work1a
     C                   if        work1a = '*'
     C                             and w4fm2 <> '*STD'
     C                             or  w4fm2 = *blanks
     C                             or  *in81
     C                             and work1a <> '*'
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(16)
     C                   exsr      zm1001
     *
     C                   else
     *    Strip embedded blanks from form type entry.
     C                   eval      $cstr = w4fm2
     C                   call      'ADJUST'
     C                   parm      '*LTSTRIP'    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         w4fm2
     C                   endif
     C                   else
     *    RETAIL label printing set to 'N', set default values.
     C                   eval      w4cu2 = 'N'
     C                   eval      w4lp2 = ' '
     C                   eval      w4dv2 = ' '
     C                   eval      w4fm2 = ' '
     C                   endif
640aA*
640aA* Tote labels not allowed in TB Light
640aA*
640aAC                   if        tbLight and w4lb3 = 'Y'
640aAC                   eval      error = *on
640aAC                   eval      *in35 = *on
640aAC                   eval      *in15 = *on
640aAC                   eval      errmsg = 'Tote labels not allowed in '
640aAC                                    + 'TB Light version'
640aAC                   exsr      zm0105
640aAC                   leavesr
640aAC                   endif
     *
     *    TOTE label.
     C                   if        w4lb3 = 'Y'
     *
     *    Check for invalid characters in Form Type name. 81=Yes.
     *
     C                   eval      *in81 = *off
     C     valid         check     w4fm3                                  81
     C                   movel     w4fm3         work1a
     C                   if        work1a = '*'
     C                             and w4fm3 <> '*STD'
     C                             or  w4fm3 = *blanks
     C                             or  *in81
     C                             and work1a <> '*'
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(16)
     C                   exsr      zm1001
     *
     C                   else
     *    Strip embedded blanks from form type entry.
     C                   eval      $cstr = w4fm3
     C                   call      'ADJUST'
     C                   parm      '*LTSTRIP'    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         w4fm3
     C                   endif
     C                   else
     *    TOTE label printing set to 'N', set default values.
     C                   eval      w4cu3 = 'N'
     C                   eval      w4lp3 = ' '
     C                   eval      w4dv3 = ' '
     C                   eval      w4fm3 = ' '
     C                   endif
     *
     C     endck4        endsr
     *
     *----------------------------------------------------------------
520dA*
520dA*  ZZCHK5     Screen 5 error checking.
520dA*
520dAC     zzchk5        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to hold fields for editing.
     *  Verify Print option, Cutter option, Program, Device.
     *
     C                   eval      hldlb1 = w5lb4
     C                   eval      hldcu1 = w5cu4
     C                   eval      hldlp1 = w5lp4
     C                   eval      hlddv1 = w5dv4
     C                   eval      hldlb2 = w5lb5
     C                   eval      hldcu2 = w5cu5
     C                   eval      hldlp2 = w5lp5
     C                   eval      hlddv2 = w5dv5
     C                   eval      hldlb3 = w5lb6
     C                   eval      hldcu3 = w5cu6
     C                   eval      hldlp3 = w5lp6
     C                   eval      hlddv3 = w5dv6
     C                   exsr      ZZChkPrtOpt
     *
     *  Verify Form.
640aA*
640aA* ASN labels not allowed in TB Light
640aA*
640aAC                   if        tbLight and w5lb4 = 'Y'
640aAC                   eval      error = *on
640aAC                   eval      *in25 = *on
640aAC                   eval      *in05 = *on
640aAC                   eval      errmsg = 'ASN labels not allowed in '
640aAC                                    + 'TB Light version'
640aAC                   exsr      zm0105
640aAC                   leavesr
640aAC                   endif
     *
     *    ASN label.
     C                   if        w5lb4 = 'Y'
     *
     *    Check for invalid characters in Form Type name. 81=Yes.
     *
     C                   eval      *in81 = *off
     C     valid         check     w5fm4                                  81
     C                   movel     w5fm4         work1a
     C                   if        work1a = '*'
     C                             and w5fm4 <> '*STD'
     C                             or  w5fm4 = *blanks
     C                             or  *in81
     C                             and work1a <> '*'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(16)
     C                   exsr      zm1001
     *
     C                   else
     *    Strip embedded blanks from form type entry.
     C                   eval      $cstr = w5fm4
     C                   call      'ADJUST'
     C                   parm      '*LTSTRIP'    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         w5fm4
     C                   endif
     C                   else
     *    ASN label printing set to 'N', set default values.
     C                   eval      w5cu4 = 'N'
     C                   eval      w5lp4 = ' '
     C                   eval      w5dv4 = ' '
     C                   eval      w5fm4 = ' '
     C                   endif
640aA*
640aA* Pick List labels not allowed in TB Light
640aA*
640aAC                   if        tbLight and w5lb5 = 'Y'
640aAC                   eval      error = *on
640aAC                   eval      *in25 = *on
640aAC                   eval      *in05 = *on
640aAC                   eval      errmsg = 'Pick list labels not allowed in '
640aAC                                    + 'TB Light version'
640aAC                   exsr      zm0105
640aAC                   leavesr
640aAC                   endif
     *
     *    PICK LIST label.
     C                   if        w5lb5 = 'Y'
     *
     *    Check for invalid characters in Form Type name. 81=Yes.
     *
     C                   eval      *in81 = *off
     C     valid         check     w5fm5                                  81
     C                   movel     w5fm5         work1a
     C                   if        work1a = '*'
     C                             and w5fm5 <> '*STD'
     C                             or  w5fm5 = *blanks
     C                             or  *in81
     C                             and work1a <> '*'
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(16)
     C                   exsr      zm1001
     *
     C                   else
     *    Strip embedded blanks from form type entry.
     C                   eval      $cstr = w5fm5
     C                   call      'ADJUST'
     C                   parm      '*LTSTRIP'    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         w5fm5
     C                   endif
     C                   else
     *    PICK LIST label printing set to 'N', set default values.
     C                   eval      w5cu5 = 'N'
     C                   eval      w5lp5 = ' '
     C                   eval      w5dv5 = ' '
     C                   eval      w5fm5 = ' '
     C                   endif
     *
     *    PICK LIST report.
     C                   if        w5lb6 = 'Y'
     *
     *    Check for invalid characters in Form Type name. 81=Yes.
     *
     C                   eval      *in81 = *off
     C     valid         check     w5fm6                                  81
     C                   movel     w5fm6         work1a
     C                   if        work1a = '*'
     C                             and w5fm6 <> '*STD'
     C                             or  w5fm6 = *blanks
     C                             or  *in81
     C                             and work1a <> '*'
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(16)
     C                   exsr      zm1001
     *
     C                   else
     *    Strip embedded blanks from form type entry.
     C                   eval      $cstr = w5fm6
     C                   call      'ADJUST'
     C                   parm      '*LTSTRIP'    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         w5fm6
     C                   endif
     C                   else
     *    PICK LIST report printing set to 'N', set default values.
530aM ****               eval      w5cu6 = 'N'
530aM ****               eval      w5lp6 = ' '
530aM ****               eval      w5dv6 = ' '
530aM ****               eval      w5fm6 = ' '
     C                   endif
     *
     C     endck5        endsr
     *
     *----------------------------------------------------------------
520dA*
520dA*  ZZChkPrtOpt  Print options error checking.
520dA*
520dAC     zzChkPrtOpt   begsr
     C                   eval      error = *off
     *
     *  If label type does not exist, skip edits and go to next label type.
     *
     C                   if        *in94
     C                             or hldlb1 = 'N'
     C                   goto      skip1
     C                   endif
     *
     *  Verify print option Y/N.
     *
     C                   if        hldlb1 <> 'Y'
     C                             and hldlb1 <> 'N'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(46)
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify cutter option Y/N.
     *
     C                   if        hldcu1 <> 'Y'
     C                             and hldcu1 <> 'N'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(47)
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify program name
     *
     C                   eval      lblfmthky = %subst(hldlp1:5:6)
     C     lblfmthky     chain     lblfmth                            79
     C                   if        *in79 or
     C                             %subst(hldlp1:1:4) <> 'PFMT'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(48)
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify device
     *
     C     prefix        scan      hlddv1        pos
     C     pstfix        scan      hlddv1        pos2
     C                   if        pos >= 1  and
     C                             $aut = 'N'  or
     C                             pos2 >= 1  and
     C                             $aut = 'N'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(36)
     C                   exsr      zm0105
     C                   endif
     *
     C                   if        pos >= 1  or
     C                             pos2 >= 1
     C                   eval      hlddev = hlddv1
     C     devgky        chain     devgrph
     C                   if        not %found(devgrph)
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(35)
     C                   exsr      zm0105
     C                   endif
     C                   else
     *
     c                   if        hlddv1 = '*JOB'
     c                             or hlddv1 = '*SYSVAL'
620bAc                             or hlddv1 = 'QPRINT'
     c                   goto      skip1
     c                   endif
     *
JOR AC                   if        client = jordanos
JOR Ac                   goto      skip1
JOR AC                   endif
     *
     c                   call      'UT880CL'
     c                   parm                    hlddv1
     c                   parm                    $lrtn
     c                   if        $lrtn = '*ERROR '
     c                             or hlddv1 = ' '
     c                   eval      error = *on
     c                   eval      *in24 = *on
     c                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     c                   eval      errmsg = desc(15)
     c                   exsr      zm1001
     c                   endif
     c                   endif
     *
     c     skip1         tag
     *
     *  If label type does not exist, skip edits and go to next label type.
     *
     C                   if        *in95
     C                             or hldlb2 = 'N'
     C                   goto      skip2
     C                   endif
     *
     *  Verify print option Y/N.
     *
     C                   if        hldlb2 <> 'Y'
     C                             and hldlb2 <> 'N'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(46)
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify cutter option Y/N.
     *
     C                   if        hldcu2 <> 'Y'
     C                             and hldcu2 <> 'N'
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(47)
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify program name
     *
     C                   eval      lblfmthky = %subst(hldlp2:5:6)
     C     lblfmthky     chain     lblfmth                            79
     C                   if        *in79 or
     C                             %subst(hldlp2:1:4) <> 'PFMT'
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(48)
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify device
     *
     C     prefix        scan      hlddv2        pos
     C     pstfix        scan      hlddv2        pos2
     C                   if        pos >= 1  and
     C                             $aut = 'N'  or
     C                             pos2 >= 1  and
     C                             $aut = 'N'
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(36)
     C                   exsr      zm0105
     C                   endif
     *
     C                   if        pos >= 1  or
     C                             pos2 >= 1
     C                   eval      hlddev = hlddv2
     C     devgky        chain     devgrph                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(35)
     C                   exsr      zm0105
     C                   endif
     C                   else
     *
     c                   if        hlddv2 = '*JOB'
     c                             or hlddv2 = '*SYSVAL'
620bAc                             or hlddv2 = 'QPRINT'
     c                   goto      skip2
     c                   endif
     *
     c                   call      'UT880CL'
     c                   parm                    hlddv2
     c                   parm                    $lrtn
     c                   if        $lrtn = '*ERROR ' or
     c                             hlddv2 = ' '
     c                   eval      error = *on
     c                   eval      *in29 = *on
     c                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     c                   eval      errmsg = desc(15)
     c                   exsr      zm1001
     c                   endif
     c                   endif
     *
     c     skip2         tag
     *
     *  If label type does not exist, skip edits.
     *
     C                   if        *in96
     C                             or hldlb3 = 'N'
     C                   goto      endChkPrtOpt
     C                   endif
     *
     *  Verify print option Y/N.
     *
     C                   if        hldlb3 <> 'Y'
     C                             and hldlb3 <> 'N'
     C                   eval      error = *on
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(46)
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify cutter option Y/N.
     *
     C                   if        hldcu3 <> 'Y'
     C                             and hldcu3 <> 'N'
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(47)
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify program name
     *
     C                   select
     C                   when      nxtscr <> '05 '
     C                   eval      lblfmthky = %subst(hldlp3:5:6)
     C     lblfmthky     chain     lblfmth                            79
     C                   if        *in79 or
     C                             %subst(hldlp3:1:4) <> 'PFMT'
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(48)
     C                   exsr      zm1001
     C                   endif
     C                   endsl
     *
     *  Verify device
     *
     C     prefix        scan      hlddv3        pos
     C     pstfix        scan      hlddv3        pos2
     C                   if        pos >= 1  and
     C                             $aut = 'N'  or
     C                             pos2 >= 1  and
     C                             $aut = 'N'
     C                   eval      error = *on
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(36)
     C                   exsr      zm0105
     C                   endif
     *
     C                   if        pos >= 1  or
     C                             pos2 >= 1
     C                   eval      hlddev = hlddv3
     C     devgky        chain     devgrph                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(35)
     C                   exsr      zm0105
     C                   endif
     C                   else
     *
     c                   if        hlddv3 = '*JOB'
     c                             or hlddv3 = '*SYSVAL'
620bAc                             or hlddv3 = 'QPRINT'
     c                   goto      endChkPrtOpt
     c                   endif
     *
     c                   call      'UT880CL'
     c                   parm                    hlddv3
     c                   parm                    $lrtn
     c                   if        $lrtn = '*ERROR ' or
     c                             hlddv3 = ' '
     c                   eval      error = *on
     c                   eval      *in34 = *on
     c                   eval      *in14 = *on
     C                   eval      errmsg = *blanks
     c                   eval      errmsg = desc(15)
     c                   exsr      zm1001
     c                   endif
     c                   endif
     *
     C     endChkPrtOpt  endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
213 AC                   select
     *
     *     Compartment.
     *
640bD ***                when      row# = 11
640bMC                   when      row# = 12
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
416bAC                   eval      $lwhse = $pwhse
     C                   eval      $lcomp = w1comp
416bD*R                   CALL 'TP900'
416bMC                   call      'TM910'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1comp = $lcomp
213 MC                   endif
     *
     *     Parent Zone.
     *
640bD ***                when      row# = 12
640bMC                   when      row# = 13
     C                   eval      *in04 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $ltruk = $ptruk
     C                   eval      $lzone = w1pzon
     C                   call      'ZH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1pzon = $lzone
213 MC                   endif
     *
213 AC                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
213 MC                   endif
213 MC                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
500cA*----------------------------------------------------------------
500cA*
500cA*  ZZCM2T   User defined command keys for screen 2.
500cA*
500cAC     zzcm2t        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
520dA*
520dA*  ZZCM2B   User defined command keys for screen 2.
520dA*
520dAC     zzcm2b        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C                   endsr
620aA*----------------------------------------------------------------
620aA*
620aA*  ZZCM2S   User defined command keys for screen 2.
620aA*
620aAC     zzcm2s        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     C                   eval      cmdtkn = *off
212 A*
     C     endcm3        endsr
     *----------------------------------------------------------------
520dA*
520dA*  ZZCMD4   User defined command keys for screen 4.
520dA*
520dAC     zzcmd4        begsr
     C                   eval      cmdtkn = *off
     *
     C     endcm4        endsr
     *----------------------------------------------------------------
520dA*
520dA*  ZZCMD5   User defined command keys for screen 5.
520dA*
520dAC     zzcmd5        begsr
     C                   eval      cmdtkn = *off
     *
     C     endcm5        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1zone = *blanks
     C                   eval      w1desc = *blanks
     C                   eval      w1comp = *blanks
     C                   eval      w1pzon = *blanks
500cMC                   eval      w1ptyp = 'P'
510dAC                   eval      w1stop = 'N'
520cAC                   eval      w1pkup = *blanks
520dAC                   eval      pr_pick   = '0'
520dAC                   eval      pr_mpick  = '0'
520dAC                   eval      pr_xtote  = '0'
520dAC                   eval      pr_asn    = '0'
520dAC                   eval      pr_pcklst = '0'
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   eval      w2nxtp = 1
     C                   eval      w2bpck = 35
     C                   eval      w2fpal = 1
     C                   eval      w2fcub = 64
     C                   eval      w2fstp = 4
     C                   eval      w2pbld = *on
416aAC                   eval      w2nwpl = 'N'
500dAC                   eval      w2ford = 'N'
520cAC                   eval      w2spal = 'N'
650aAC                   eval      w2plbl = 'N'
     C                   endsr
500cA*----------------------------------------------------------------
500cA*
500cA*  ZZDF2T   Get default values for add.
500cA*
500cAC     zzdf2t        begsr
     C                   eval      w2nxtp = 1
     C                   eval      w2fpal = 1
     C                   eval      w2tecb = 0
     C                   eval      w2ticb = 0
     C                   eval      w2tpcs = 0
     C                   eval      w2ftot = 0
     C                   eval      w2fstp = 1
510bAC                   eval      w2tord = 0
     C                   eval      w2pbld = *on
500dAC                   eval      w2ford = 'N'
     C                   endsr
     *----------------------------------------------------------------
520dA*
520dA*  ZZDF2B   Get default values for add.
520dA*
520dAC     zzdf2b        begsr
     C                   eval      w2nxtp = 1
     C                   eval      w2bpck = 35
     C                   eval      w2fpal = 1
     C                   eval      w2fcub = 64
     C                   eval      w2fstp = 4
     C                   eval      w2pbld = *on
     C                   eval      w2nwpl = 'N'
     C                   eval      w2ford = 'N'
     C                   eval      w2pitm = 1
     C                   endsr
620aA*----------------------------------------------------------------
620aA*
620aA*  ZZDF2S   Get default values for add.
620aA*
620aAC     zzdf2s        begsr
     C                   eval      w2fpal = 1
620bAC                   eval      w2fcub = 999.99
620bAC                   eval      w2fstp = 99
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT3   Get default values for add.
     *
     C     zzdft3        begsr
520dDC**                 eval      w3lpgm = 'PLBL01'
520dDC**                 eval      w3pdev = '*JOB'
402 D*                    MOVEL'*PCKLBL' W3FORM    P
402 MC**520dD            eval      w3form = 'PCKLBL'
     C                   eval      w3clvl = 0
     C                   eval      w3cwrb = 'N'
     C                   eval      w3cwra = 'N'
     C                   eval      w3uwrb = 'N'
     C                   eval      w3uwra = 'N'
     C                   eval      w3err = 0
     C                   eval      w3cwgt = 0
520aAC                   eval      w3aisl = 'N'
520dAC                   eval      w3taxr = 'N'
520dAC                   eval      w3chkr = 'N'
     C                   endsr
     *----------------------------------------------------------------
520dA*
520dA*  ZZDFT4   Get default values for add.
520dA*
520dAC     zzdft4        begsr
     C                   eval      w4lb1  = 'N'
     C                   eval      w4cu1  = 'N'
     C                   eval      w4lp1  = ' '
     C                   eval      w4dv1  = ' '
     C                   eval      w4fm1  = ' '
     C                   eval      w4lb2  = 'N'
     C                   eval      w4cu2  = 'N'
     C                   eval      w4lp2  = ' '
     C                   eval      w4dv2  = ' '
     C                   eval      w4fm2  = ' '
     C                   eval      w4lb3  = 'N'
     C                   eval      w4cu3  = 'N'
     C                   eval      w4lp3  = ' '
     C                   eval      w4dv3  = ' '
     C                   eval      w4fm3  = ' '
     C                   eval      *in94  = '0'
     C                   eval      *in95  = '0'
     C                   eval      *in96  = '0'
     C                   endsr
     *----------------------------------------------------------------
520dA*
520dA*  ZZDFT5   Get default values for add.
520dA*
520dAC     zzdft5        begsr
     C                   eval      w5lb4  = 'N'
     C                   eval      w5cu4  = 'N'
     C                   eval      w5lp4  = ' '
     C                   eval      w5dv4  = ' '
     C                   eval      w5fm4  = ' '
     C                   eval      w5lb5  = 'N'
     C                   eval      w5cu5  = 'N'
     C                   eval      w5lp5  = ' '
     C                   eval      w5dv5  = ' '
     C                   eval      w5fm5  = ' '
     C                   eval      w5lb6  = 'N'
     C                   eval      w5cu6  = 'N'
     C                   eval      w5lp6  = ' '
     C                   eval      w5dv6  = ' '
     C                   eval      w5fm6  = ' '
530 AC                   eval      w5lb7  = '2'
     C                   eval      *in94  = '0'
     C                   eval      *in95  = '0'
     C                   eval      *in96  = '0'
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      svzone = *blanks
     C                   eval      w1zone = zhzone
     C                   eval      w1desc = zhdesc
     C                   eval      w1comp = zhcomp
     C                   eval      w1pzon = zhpzon
     *
     C                   eval      wozone = *blanks
     C                   eval      wozone = %trimr(w1zone) + ' ' + '-'
500dMC                   eval      wozone = %trimr(wozone) + ' ' + w1desc
     *
500cMC                   eval      w1ptyp = opptyp
510dAC                   eval      w1stop = opstop
520cAC                   eval      w1pkup = oppkup
500 A*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   eval      w2nxtp = opnxtp
     C                   eval      w2bpck = opbpck
     C                   eval      w2fpal = opfpal
     C                   eval      w2fcub = opfcub
     C                   eval      w2fstp = opfstp
     C                   eval      w2pbld = oppbld
416aAC                   eval      w2nwpl = opnwpl
650aAC                   eval      w2plbl = oplbl
     C                   if        opford = 1
     C                   eval      w2ford = 'Y'
     C                   else
     C                   eval      w2ford = 'N'
     C                   endif
520cAC                   if        opspal = *blanks
520cAC                   eval      w2spal = 'N'
520cAC                   else
520cAC                   eval      w2spal = opspal
520cAC                   endif
     C                   endsr
500cA*----------------------------------------------------------------
500cA*
500cA*  ZZFI2T   Fill screen 2 fields with info from file.
500cA*
500cAC     zzfi2t        begsr
     C                   eval      w2nxtp = opnxtp
     C                   eval      w2tecb = optecb
     C                   eval      w2ticb = opticb
     C                   eval      w2tpcs = optpcs
     C                   eval      w2ftot = opftot
     C                   eval      w2fstp = opfstp
510bAC                   eval      w2tord = optord
     C                   eval      w2pbld = oppbld
     C                   eval      w2nwpl = opnwpl
650aAC                   eval      w2plbl = oplbl
     C                   if        opford = 1
     C                   eval      w2ford = 'Y'
     C                   else
     C                   eval      w2ford = 'N'
     C                   endif
640cAC                   if        opspal = *blanks
640cAC                   eval      w2spal = 'N'
640cAC                   else
640cAC                   eval      w2spal = opspal
640cAC                   endif
     C                   endsr
     *----------------------------------------------------------------
520dA*
520dA*  ZZFI2B   Fill screen 2 fields with info from file.
520dA*
520dAC     zzfi2b        begsr
     C                   eval      w2nxtp = opnxtp
     C                   eval      w2bpck = opbpck
     C                   eval      w2fpal = opfpal
     C                   eval      w2fcub = opfcub
     C                   eval      w2fstp = opfstp
     C                   eval      w2pbld = oppbld
     C                   eval      w2nwpl = opnwpl
     C                   eval      w2pitm = oppitm
     C                   if        opford = 1
     C                   eval      w2ford = 'Y'
     C                   else
     C                   eval      w2ford = 'N'
     C                   endif
     C                   endsr
620aA*----------------------------------------------------------------
620aA*
620aA*  ZZFI2S   Fill screen 2 fields with info from file.
620aA*
620aAC     zzfi2s        begsr
     C                   eval      w2fpal = opfpal
620bAC                   eval      w2fcub = 999.99
620bAC                   eval      w2fstp = 99
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
520dDC**                 eval      w3lpgm = oplpgm
520dDC**                 eval      w3pdev = oppdev
520dDC**                 eval      w3form = oppfrm
     C                   eval      w3clvl = opclvl
     C                   eval      w3cwrb = opcwrb
     C                   eval      w3cwra = opcwra
     C                   eval      w3uwrb = opuwrb
     C                   eval      w3uwra = opuwra
     C                   eval      w3err = operr
     C                   eval      w3cwgt = opcwgt
520aAC                   eval      w3aisl = opaisl
520dAC                   eval      w3taxr = optaxr
520dAC                   eval      w3chkr = opchkr
     C                   endsr
     *----------------------------------------------------------------
520dA*
520dA*  ZZFIL4   Fill screen 4 fields with info from file.
520dA*
520dAC     zzfil4        begsr
     C                   eval      w4lb1  = oplb1
     C                   eval      w4cu1  = opcu1
     C                   eval      w4lp1  = oplp1
     C                   eval      w4dv1  = opdv1
     C                   eval      w4fm1  = opfm1
     C                   eval      w4lb2  = oplb2
     C                   eval      w4cu2  = opcu2
     C                   eval      w4lp2  = oplp2
     C                   eval      w4dv2  = opdv2
     C                   eval      w4fm2  = opfm2
     C                   eval      w4lb3  = oplb3
     C                   eval      w4cu3  = opcu3
     C                   eval      w4lp3  = oplp3
     C                   eval      w4dv3  = opdv3
     C                   eval      w4fm3  = opfm3
     C                   endsr
     *----------------------------------------------------------------
520dA*
520dA*  ZZFIL5   Fill screen 5 fields with info from file.
520dA*
520dAC     zzfil5        begsr
     C                   eval      w5lb4  = oplb4
     C                   eval      w5cu4  = opcu4
     C                   eval      w5lp4  = oplp4
     C                   eval      w5dv4  = opdv4
     C                   eval      w5fm4  = opfm4
     C                   eval      w5lb5  = oplb5
     C                   eval      w5cu5  = opcu5
     C                   eval      w5lp5  = oplp5
     C                   eval      w5dv5  = opdv5
     C                   eval      w5fm5  = opfm5
     C                   eval      w5lb6  = oplb6
     C                   eval      w5cu6  = opcu6
     C                   eval      w5lp6  = oplp6
     C                   eval      w5dv6  = opdv6
     C                   eval      w5fm6  = opfm6
530 AC                   eval      w5lb7  = oplb7
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif
     *
     *   Get record for pick options.
     *
     C     pickky        chain(n)  optionz                            7978
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   unlock    zoneh
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
500cAC**520dD            if        nxtscr = '02T'
520dAC                   select
520dAC                   when      nxtscr = '02T'
500cAC                   exsr      zzdf2t
520dAC                   when      nxtscr = '02B'
520dAC                   exsr      zzdf2b
620aAC                   when      nxtscr = '02S'
620aAC                   exsr      zzdf2s
500cAC**520dD            else
520dAC                   other
     C                   exsr      zzdft2
500cAC**520dD            endif
520dAC                   endsl
     C                   eval      opdta1 = *blanks
     C                   eval      opzcod = kycod1
     C                   eval      opzwhs = $pwhse
     C                   eval      opztrk = $ptruk
     C                   eval      opzzon = $pzone
     C                   eval      opnxtp = w2nxtp
     C                   eval      opbpck = w2bpck
     C                   eval      oppcub = 0
     C                   eval      oppbrk = *blanks
     C                   eval      opfpal = w2fpal
520cAC                   eval      opspal = w2spal
     C                   eval      opfcub = w2fcub
     C                   eval      opfstp = w2fstp
520dAC                   eval      oppitm = w2pitm
     C                   eval      opincl = 'Y'
     C                   eval      opsrch = 0
     C                   eval      opfbld = 1
500cAC                   eval      opnwpl = w2nwpl
500dAC                   eval      opford = 0
500cMC                   eval      opptyp = 'P'
500dAC                   eval      optecb = 0
500dAC                   eval      opticb = 0
500dAC                   eval      optstp = 0
500dAC                   eval      optord = 0
500dAC                   eval      optpcs = 0
510dAC                   eval      opstop = 'N'
     C                   eval      opzdta = opdta1
650aAC                   eval      oplbl  = w2plbl
     C                   write     opzrec                               79
     C     pickky        chain(n)  optionz                            7978
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   unlock    zoneh
     C                   goto      endgt1
     C                   endif
     C                   endif
     *
     C                   eval      opdta1 = opzdta
     *
     *   Get record for pick label options.
     *
     C     lablky        chain(n)  optionz                            7978
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   unlock    zoneh
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
     C                   exsr      zzdft3
     C                   eval      opdta2 = *blanks
     C                   eval      opzcod = kycod2
     C                   eval      opzwhs = $pwhse
     C                   eval      opztrk = $ptruk
     C                   eval      opzzon = $pzone
520dDC**                 eval      oplpgm = w3lpgm
520dDC**                 eval      oppdev = w3pdev
52d0DC**                 eval      oppfrm = w3form
     C                   eval      opclvl = w3clvl
     C                   eval      opcwrb = w3cwrb
     C                   eval      opcwra = w3cwra
     C                   eval      opuwrb = w3uwrb
     C                   eval      opuwra = w3uwra
     C                   eval      operr = w3err
     C                   eval      opcwgt = w3cwgt
     C                   eval      optext = *blanks
520aAC                   eval      opaisl = w3aisl
520dAC                   eval      optaxr = w3taxr
520dAC                   eval      opchkr = w3chkr
     C                   eval      opzdta = opdta2
     C                   write     opzrec                               79
500aDC     pickky        chain(n)  optionz                            7978
500aMC     lablky        chain(n)  optionz                            7978
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   unlock    zoneh
     C                   goto      endgt1
     C                   endif
     C                   endif
     *
     C                   eval      opdta2 = opzdta
     *
520dA*   Get record for *PICKLBA options.
     *
520dAC     LblAky        chain(n)  optionz                            7978
     *
520dA*  Record locked.
     *
520dAC                   if        *in78
520dAC                   eval      error = *on
520dAC                   eval      $prtn = '*PGMQ   '
520dAC                   exsr      zm74
520dAC                   unlock    zoneh
520dAC                   goto      endgt1
520dAC                   endif
     *
520dA*  Record not found - Create it.
     *
520dAC                   if        *in79
520dAC                   exsr      zzdft4
520dAC                   eval      opdta3 = *blanks
520dAC                   eval      opzcod = kycod3
520dAC                   eval      opzwhs = $pwhse
520dAC                   eval      opztrk = $ptruk
520dAC                   eval      opzzon = $pzone
520dAC                   eval      oplb1  = w4lb1
520dAC                   eval      opcu1  = w4cu1
520dAC                   eval      oplp1  = w4lp1
520dAC                   eval      opdv1  = w4dv1
520dAC                   eval      opfm1  = w4fm1
520dAC                   eval      oplb2  = w4lb2
520dAC                   eval      opcu2  = w4cu2
520dAC                   eval      oplp2  = w4lp2
520dAC                   eval      opdv2  = w4dv2
520dAC                   eval      opfm2  = w4fm2
520dAC                   eval      oplb3  = w4lb3
520dAC                   eval      opcu3  = w4cu3
520dAC                   eval      oplp3  = w4lp3
520dAC                   eval      opdv3  = w4dv3
520dAC                   eval      opfm3  = w4fm3
520dAC                   eval      opzdta = opdta3
520dAC                   write     opzrec                               79
520dAC     LblAky        chain(n)  optionz                            7978
520dAC                   if        *in79
520dAC                   eval      error = *on
520dAC                   eval      $prtn = '*PGMQ   '
520dAC                   exsr      zm73
520dAC                   unlock    zoneh
520dAC                   goto      endgt1
520dAC                   endif
520dAC                   endif
     *
520dAC                   eval      opdta3 = opzdta
     *
520dA*   Get record for *PICKLBB options.
     *
520dAC     LblBky        chain(n)  optionz                            7978
     *
520dA*  Record locked.
     *
520dAC                   if        *in78
520dAC                   eval      error = *on
520dAC                   eval      $prtn = '*PGMQ   '
520dAC                   exsr      zm74
520dAC                   unlock    zoneh
520dAC                   goto      endgt1
520dAC                   endif
     *
520dA*  Record not found - Create it.
     *
520dAC                   if        *in79
520dAC                   exsr      zzdft5
520dAC                   eval      opdta4 = *blanks
520dAC                   eval      opzcod = kycod4
520dAC                   eval      opzwhs = $pwhse
520dAC                   eval      opztrk = $ptruk
520dAC                   eval      opzzon = $pzone
520dAC                   eval      oplb4  = w5lb4
520dAC                   eval      opcu4  = w5cu4
520dAC                   eval      oplp4  = w5lp4
520dAC                   eval      opdv4  = w5dv4
520dAC                   eval      opfm4  = w5fm4
520dAC                   eval      oplb5  = w5lb5
520dAC                   eval      opcu5  = w5cu5
520dAC                   eval      oplp5  = w5lp5
520dAC                   eval      opdv5  = w5dv5
520dAC                   eval      opfm5  = w5fm5
520dAC                   eval      oplb6  = w5lb6
520dAC                   eval      opcu6  = w5cu6
520dAC                   eval      oplp6  = w5lp6
520dAC                   eval      opdv6  = w5dv6
520dAC                   eval      opfm6  = w5fm6
530 AC                   eval      oplb7  = w5lb7
520dAC                   eval      opzdta = opdta4
520dAC                   write     opzrec                               79
520dAC     LblBky        chain(n)  optionz                            7978
520dAC                   if        *in79
520dAC                   eval      error = *on
520dAC                   eval      $prtn = '*PGMQ   '
520dAC                   exsr      zm73
520dAC                   unlock    zoneh
520dAC                   goto      endgt1
520dAC                   endif
520dAC                   endif
     *
520dAC                   eval      opdta4 = opzdta
     *
520dA*  Set protect field values.  If the label type is not found
520dA*  in LBLFMTT, turn its protect field on (pr_xxxx).
     *
520dAC                   eval      lblfmttky = 'PICK'
520dAC     lblfmttky     chain     lblfmtt                            79
520dAC                   if        *in79
520dAC                   eval      pr_pick = '1'
520dAC                   endif
     *
520dAC                   eval      lblfmttky = 'MPICK'
520dAC     lblfmttky     chain     lblfmtt                            79
520dAC                   if        *in79
520dAC                   eval      pr_mpick = '1'
520dAC                   endif
     *
520dAC                   eval      pr_xtote = '1'
520dAC                   eval      lblfmttky = 'XTOTE'
520dAC     lblfmttky     chain     lblfmtt                            79
520dAC                   if        *in79 = *off
520dAC                   eval      pr_xtote = '0'
520dAC                   endif
     *
520dAC                   eval      lblfmttky = 'XTOTE2'
520dAC     lblfmttky     chain     lblfmtt                            79
520dAC                   if        *in79 = *off
520dAC                   eval      pr_xtote = '0'
520dAC                   endif
     *
520dAC                   eval      lblfmttky = 'ASN'
520dAC     lblfmttky     chain     lblfmtt                            79
520dAC                   if        *in79
520dAC                   eval      pr_asn = '1'
520dAC                   endif
     *
520dAC                   eval      lblfmttky = 'PCKLST'
520dAC     lblfmttky     chain     lblfmtt                            79
520dAC                   if        *in79
520dAC                   eval      pr_pcklst = '1'
520dAC                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     C     endgt2        endsr

620dA*----------------------------------------------------------------
620dA*  zzIsSZoneOk   Check if S zone is allowed
620dA*----------------------------------------------------------------
620dA
620dAC     zzIsSZoneOk   begsr

      /free

         // Only one 'S' zone is allowed.

         setll ($pwhse: $ptruk) zoneh;

         dow forever = forever;

           reade(n) ($pwhse: $ptruk) zoneh;

           if %eof(zoneh);
             leave;
           endif;

           // If zone is 'S', return error.

           chain(n) ('*PICK': zhwhse: zhtruk: zhzone) optionz;
           if %found(optionz);
             opdta1 = opzdta;
             if opptyp = 'S';
               error = *on;
               *in25 = *on;
               *in05 = *on;
               errmsg = 'Cannot create S zone - '
                      + 'Already defined';
               exsr zm0105;
               leavesr;
             endif;
           endif;

         enddo;

         // 'PRE' aisle cannot be used in another zone.

         setll ($pwhse: $ptruk) zoned1;

         dow forever = forever;

           reade(n) ($pwhse: $ptruk) zoned1;

           if %eof(zoned1);
             leave;
           endif;

           // If aisle is 'PRE', return error.

           if zdaisl = 'PRE';
             error = *on;
             *in25 = *on;
             *in05 = *on;
             errmsg = 'Cannot create S zone - '
                    + 'Aisle PRE used in zone def';
             exsr zm0105;
             leavesr;
           endif;

         enddo;

      /end-free

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr

530 A* Get client id.

530 AC                   call      'GETCLIENT'
530 AC                   parm                    client           10
530 AC                   parm                    clientLoc        10
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     C                   kfld                    $pzone
     *
     *  Define key for truck file.
     *
     C     trukky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     *
     *  Define key for pick options.
     *
     C                   eval      kycod1 = '*PICK   '
     C     pickky        klist
     C                   kfld                    kycod1
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     C                   kfld                    $pzone
     *
500cAC     mergky        klist
500cAC                   kfld                    kycod1
500cAC                   kfld                    $pwhse
500cAC                   kfld                    $ptruk
500cAC                   kfld                    w1pzon
     *
     *  Define key for pick label options.
     *
     C                   eval      kycod2 = '*PICKLBL'
     C     lablky        klist
     C                   kfld                    kycod2
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     C                   kfld                    $pzone
     *
520dA*  Define key for pick, retail, and tote label printing options.
     *
520dAC                   eval      kycod3 = '*PICKLBA'
520dAC     LblAky        klist
520dAC                   kfld                    kycod3
520dAC                   kfld                    $pwhse
520dAC                   kfld                    $ptruk
520dAC                   kfld                    $pzone
     *
520dA*  Define key for pick list label, ASN label, & pick list report
520dA*  printing options.
     *
520dAC                   eval      kycod4 = '*PICKLBB'
520dAC     LblBky        klist
520dAC                   kfld                    kycod4
520dAC                   kfld                    $pwhse
520dAC                   kfld                    $ptruk
520dAC                   kfld                    $pzone
     *
510eA*  Define key for device group code.
510eA*
510eAC     devgky        klist
510eAC                   kfld                    $pwhse
510eAC**520dD            kfld                    w3pdev
520dMC                   kfld                    hlddev
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
640aA
640aA*   Get feature info.
640aA
640aAC                   eval      $gfWhse = $pwhse
640aAC                   call      'GETFEAT'
640aAC                   parm      '*GET'        $gfCmd
640aAC                   parm                    $gfWhse
640aAC                   parm                    $gfFeature
640aAC                   parm                    $gfLight
640aAC                   if        $gfLight = 'Y'
640aAC                   eval      tbLight = *on
640aAC                   else
640aAC                   eval      tbLight = *off
640aAC                   endif
     *
     *   Get truck description.
     *
     C                   eval      wotruk = *blanks
500bAC                   eval      w1ztmp = *blanks
     C     trukky        chain     truckh                             79
     C                   if        *in79
     C                   movel     $ltruk        wotruk
     C                   else
     C                   eval      wotruk = %trimr(thtruk) + ' ' + '-'
     C                   eval      wotruk = %trimr(wotruk) + ' ' + thdesc
500bA**                   MOVE #ZTMP     W1ZTMP
500bA**         THZTMP    IFNE *BLANKS
500bA**                   MOVE THZTMP    W1ZTMP
500bA**                   ENDIF
     C                   endif
     *
510eA*  Retreive data area value to see if round robin printing is
510eA*  active.  This value dictats if Device Group Codes can be entered
510eA*
640dA /free
640dA   opcode = '*GENPICK';
640dA   $aut = 'N';
640dA   chain ($pwhse: opcode) options;
640dA     if %found(options);
640dA       $aut = %subst(opdata:19:1);
640dA       if $aut = ' ';
640dA         $aut = 'N';
640dA       endif;
640dA     endif;
640dA /end-free
640dD ***                call      'ZH122CL'
640dD ***                parm      #prog         #pgmq
640dD ***                parm                    $aut              1
     *
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
     C                   eval      $pzone = *blanks
     C                   endif
     *
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *   Format zone description for following screens
     *
     C                   eval      wozone = *blanks
     C                   eval      wozone = %trimr(w1zone) + ' ' + '-'
500dAC                   eval      wozone = %trimr(wozone) + ' ' + w1desc
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C     endup2        endsr
500cA*----------------------------------------------------------------
500cA*
500cA*  ZZUP2T   Update for screen 2.
500cA*
500cAC     zzup2t        begsr
     C                   eval      error = *off
     C     endu2t        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUP2B   Update for screen 2.
     *
     C     zzup2b        begsr
     C                   eval      error = *off
     C     endu2b        endsr
620aA*----------------------------------------------------------------
620aA*
620aA*  ZZUP2S   Update for screen 2.
620aA*
620aAC     zzup2s        begsr
     C                   eval      error = *off
     C     endu2s        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     *
     *   Update pick options.
     *
     C     pickky        chain     optionz                            7978
     *
     *     Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endup3
     C                   endif
     *
     *     Move screen fields to record fields
     *
     C                   eval      opnxtp = w2nxtp
     C                   eval      opbpck = w2bpck
     C                   eval      oppcub = 0
     C                   eval      oppbrk = *blanks
     C                   eval      opfpal = w2fpal
520cAC                   eval      opspal = w2spal
     C                   eval      opfcub = w2fcub
     C                   eval      opfstp = w2fstp
520dAC                   eval      oppitm = w2pitm
     C                   eval      opincl = 'Y'
     C                   eval      opsrch = 0
     C                   eval      opfbld = 1
     C                   eval      oppbld = w2pbld
     C                   eval      opselm = *on
     C                   eval      opsplt = 'Y'
416aAC                   eval      opnwpl = w2nwpl
650aAC                   eval      oplbl  = w2plbl
500dMC                   if        w2ford = 'Y'
500dMC                   eval      opford = 1
500dMC                   else
500dMC                   eval      opford = 0
500dMC                   endif
500cMC                   eval      opptyp = w1ptyp
520cAC                   eval      oppkup = w1pkup
510dAC                   move      w1stop        opstop
500dMC                   eval      opftot = w2ftot
500dMC                   eval      optecb = w2tecb
500dMC                   eval      opticb = w2ticb
500dMC                   eval      optstp = w2tstp
500dMC                   eval      optord = w2tord
500dMC                   eval      optpcs = w2tpcs
     *
     *     Add/update record.
     *
     C                   if        *in79
     C                   eval      opzcod = kycod1
     C                   eval      opzwhs = $pwhse
     C                   eval      opztrk = $ptruk
     C                   eval      opzzon = w1zone
     C                   eval      opzdta = opdta1
     C                   write     opzrec                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endup3
     C                   endif
     C                   else
     C                   eval      opzdta = opdta1
     C                   update    opzrec                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup3
     C                   endif
     C                   endif
     *
     *   Update pick label options.
     *
     C     lablky        chain     optionz                            7978
     *
     *     Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endup3
     C                   endif
     *
     *     Move screen fields to record fields
     *
520dDC**                 eval      oplpgm = w3lpgm
520dDC**                 eval      oppdev = w3pdev
520dDC**                 eval      oppfrm = w3form
     C                   eval      opclvl = w3clvl
     C                   eval      opcwrb = w3cwrb
     C                   eval      opcwra = w3cwra
     C                   eval      opuwrb = w3uwrb
     C                   eval      opuwra = w3uwra
     C                   eval      operr = w3err
     C                   eval      opcwgt = w3cwgt
     C                   eval      optext = *blanks
520aAC                   eval      opaisl = w3aisl
520dAC                   eval      optaxr = w3taxr
520dAC                   eval      opchkr = w3chkr
     *
     *     Add/update record.
     *
     C                   if        *in79
     C                   eval      opzcod = kycod2
     C                   eval      opzwhs = $pwhse
     C                   eval      opztrk = $ptruk
     C                   eval      opzzon = w1zone
     C                   eval      opzdta = opdta2
     C                   write     opzrec                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endup3
     C                   endif
     C                   else
     C                   eval      opzdta = opdta2
     C                   update    opzrec                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup3
     C                   endif
     C                   endif
     *
520dA*   Update *PICKLBA pick label options.
     *
520dAC     LblAky        chain     optionz                            7978
     *
520dA*     Record locked.
     *
520dAC                   if        *in78
520dAC                   eval      error = *on
520dAC                   eval      $prtn = '*PGMQ   '
520dAC                   exsr      zm74
520dAC                   goto      endup3
520dAC                   endif
     *
520dA*     Move screen fields to record fields
     *
520dAC                   eval      oplb1  = w4lb1
520dAC                   eval      opcu1  = w4cu1
520dAC                   eval      oplp1  = w4lp1
520dAC                   eval      opdv1  = w4dv1
520dAC                   eval      opfm1  = w4fm1
520dAC                   eval      oplb2  = w4lb2
520dAC                   eval      opcu2  = w4cu2
520dAC                   eval      oplp2  = w4lp2
520dAC                   eval      opdv2  = w4dv2
520dAC                   eval      opfm2  = w4fm2
520dAC                   eval      oplb3  = w4lb3
520dAC                   eval      opcu3  = w4cu3
520dAC                   eval      oplp3  = w4lp3
520dAC                   eval      opdv3  = w4dv3
520dAC                   eval      opfm3  = w4fm3
     *
520dA*     Add/update record.
     *
520dAC                   if        *in79
520dAC                   eval      opzcod = kycod3
520dAC                   eval      opzwhs = $pwhse
520dAC                   eval      opztrk = $ptruk
520dAC                   eval      opzzon = w1zone
520dAC                   eval      opzdta = opdta3
520dAC                   write     opzrec                               79
520dAC                   if        *in79
520dAC                   eval      error = *on
520dAC                   exsr      zm71
520dAC                   goto      endup3
520dAC                   endif
520dAC                   else
520dAC                   eval      opzdta = opdta3
520dAC                   update    opzrec                               79
520dAC                   if        *in79
520dAC                   eval      error = *on
520dAC                   exsr      zm72
520dAC                   goto      endup3
520dAC                   endif
520dAC                   endif
     *
520dA*   Update *PICKLBB pick label options.
     *
520dAC     LblBky        chain     optionz                            7978
     *
520dA*     Record locked.
     *
520dAC                   if        *in78
520dAC                   eval      error = *on
520dAC                   eval      $prtn = '*PGMQ   '
520dAC                   exsr      zm74
520dAC                   goto      endup3
520dAC                   endif
     *
520dA*     Move screen fields to record fields
     *
520dAC                   eval      oplb4  = w5lb4
520dAC                   eval      opcu4  = w5cu4
520dAC                   eval      oplp4  = w5lp4
520dAC                   eval      opdv4  = w5dv4
520dAC                   eval      opfm4  = w5fm4
520dAC                   eval      oplb5  = w5lb5
520dAC                   eval      opcu5  = w5cu5
520dAC                   eval      oplp5  = w5lp5
520dAC                   eval      opdv5  = w5dv5
520dAC                   eval      opfm5  = w5fm5
520dAC                   eval      oplb6  = w5lb6
520dAC                   eval      opcu6  = w5cu6
520dAC                   eval      oplp6  = w5lp6
520dAC                   eval      opdv6  = w5dv6
520dAC                   eval      opfm6  = w5fm6
530 AC                   eval      oplb7  = w5lb7
     *
520dA*     Add/update record.
     *
520dAC                   if        *in79
520dAC                   eval      opzcod = kycod4
520dAC                   eval      opzwhs = $pwhse
520dAC                   eval      opztrk = $ptruk
520dAC                   eval      opzzon = w1zone
520dAC                   eval      opzdta = opdta4
520dAC                   write     opzrec                               79
520dAC                   if        *in79
520dAC                   eval      error = *on
520dAC                   exsr      zm71
520dAC                   goto      endup3
520dAC                   endif
520dAC                   else
520dAC                   eval      opzdta = opdta4
520dAC                   update    opzrec                               79
520dAC                   if        *in79
520dAC                   eval      error = *on
520dAC                   exsr      zm72
520dAC                   goto      endup3
520dAC                   endif
520dAC                   endif
     *
     *   Update zone record.
     *
     *     Move screen fields to record fields
     *
     C                   eval      zhwhse = $pwhse
     C                   eval      zhtruk = $ptruk
     C                   eval      zhzone = w1zone
     C                   eval      zhdesc = w1desc
     C                   eval      zhcomp = w1comp
     C                   eval      zhpzon = w1pzon
     *
     *     Add record
     *
     C                   if        $pcmd = '*ADD    '
     C                   write     record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endup3
     C                   endif
     C                   else
     *
     *   -OR- Update record (it was read and locked in ZZGET2)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup3
     C                   endif
     C                   endif
     *
     *   Move key values to parameters
     *
     C                   eval      $pzone = zhzone
     C     endup3        endsr
     *----------------------------------------------------------------
520dA*
520dA*  ZZUPD4   Update for screen 4.
520dA*
520dAC     zzupd4        begsr
     C                   eval      error = *off
     C     endup4        endsr
     *----------------------------------------------------------------
520dA*
520dA*  ZZUPD5   Update for screen 5.
520dA*
520dAC     zzupd5        begsr
     C                   eval      error = *off
     C     endup5        endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Zone                                                           1
Parent Zone                                                    2
Bulk Pick Definition                                           3
Pallets on Fork Lift                                           4
Maximum Cube per Pallet                                        5
Maximum Stops per Pallet                                       6
Qty Level for Combined Label                                   7
Print Combined Warning Label - Before                          8
Print Combined Warning Label - After                           9
Print Unit of Measure Warning Label - Before                  10
Print Unit of Measure Warning Label - After                   11
Discrepancy Label Ratio                                       12
Catch Weight Label Ratio                                      13
Pallet Building Method                                        14
Printer device                                                15
Form type                                                     16
New pallet for aisle                                          17
Zone type                                                     18
External tote cube                                            19
Truck Compartment                                             20
Internal tote cube                                            21
external tote cube                                            22
Maximum Pieces per tote                                       23
Build method 2 not allowed for Totes                          24
Totes per transaction                                         25
Internal tote cube                                            26
Maximum stops per tote                                        27
Tote building method                                          28
New pallet for each order                                     29
Parent zone cannot be a tote zone                             30
Totes only allowed to contain 1 stop                          31
New pallet if stop does not fit                               32
Valid entries for Orders per tote are 0 & 1.                  33
Honor *SP Code                                                34
Invalid Group Device Code                                     35
Round Robin Printing not set up.                              36
Underscore not allowed in pos 1 for Printer Device            37
Print Aisle change Label                                      38
Picked up by                                                  39
"Picked up by" requires a parent zone                         40
Merge items for single truck pallet                           41
Parent zone and Picked up by not allowed if Batch             42
Maximum items per pallet must be 1                            43
Include in Tax Right                                          44
Include in Check Right                                        45
Print option                                                  46
Cutter option                                                 47
Program name                                                  48
Label type does not exist                                     49
Zone name can not have embedded blanks                        50
                                                              51
Invalid label printing method                                 52
