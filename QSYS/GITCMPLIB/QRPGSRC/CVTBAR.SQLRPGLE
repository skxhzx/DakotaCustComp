510 A /copy qcopysrc,hspecs
740cAH DFTACTGRP(*NO) ACTGRP(*CALLER)
     F*----------------------------------------------------------------
     F*   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  CVTBAR      Convert barcode
     F*  22 February 2001
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
415 AF*    02/22/01  DAS  4.15
     F*      - Created.
     F*
415aAF*    03/09/01  DAS  4.15a
     F*      - Revised *UPC to look for 14-character code.
     F*
415bAF*    03/21/01  DAS  4.15b
     F*      - Revised BARGETVAL to verify length of values.
     F*
415cAF*    03/29/01  DAS  4.15c
     F*      - Changed "evalr" statement to use MOVE statement
     F*        because "evalr" was not implemented until V4R4M0.
     F*      - Changed "%Rem" statement to use DIV/MVR statement
     F*        because "%Rem" was not implemented until V4R4M0.
     F*
415dAF*    04/17/01  DAS  4.15d
     F*      - Revised routine ChkMod10 to verify that the barcode
     F*        contains only numbers. Before this change was made
     F*        certain characters (ie. '#') would cause a data decimal
     F*        error when trying to calculate the check digit.
417 AF*    05/29/03  RH   4.17
     F*      - Enh: Change to return *UPCWARN if upc code entered was
     F*        less than 21 characters and no valid UPC code was found.
417aAF*    01/06/04  RH   4.17a
     F*      - ENH: Add cmd *VRFYLP7 to verify license is not > 7.
     F*
500 AF*    12/13/05  DAS  5.00
     F*      - ENH: Revised to skip verifying check digit when trying to
     F*        read non-upc codes (i.e., *CWGTLBS).
     F*
510 AF*    01/25/07  DAS  5.10
     F*      - Rewrote CmdWgtLbs saving original as xxxWgtLbs.
     F*        New version checks for a custom barcode (len<=10),
     F*        then checks for UCC code 310 (kgs) or 320 (lbs).
     F*      - Added 310 to valid codes.
     F*
510bAF*    04/02/07  DAS  5.10b
     F*      - Added back in the ability to translate a code <= 10 char
     F*        into a weight. Re: This is needed for the catchweight
     F*        entry program cw122.
     F*
510cAF*    04/05/07  DAS  5.10c
     F*      - Implemented specific vendor numbers for WestSide.
     F*
510dAF*    11/09/07  DAS  5.10d
     F*      - Added check for id (10) - Batch/Lot code.
     F*
520aAF*    01/27/08  DAS  5.20a  P#00002
     F*      - Revised ChkMod10 to work with SSCC-18 codes. Routine
     F*        only worked with up to 14 digits instead of 18.
640aAF*    10/05/11  RH   6.40a
     F*      - Fix: BarGetVal, validate TEMP6A as numeric before move
     F*        to TEMP6N, was getting decimal data error.
640bAF*    07/26/12  LMC  6.40b
     F*      - Enh: Add command $all to extract all AI code data on one
     F*        pass thru the program.
640cAF*    09/26/12  DAS  6.40c
     F*      - Enh: Revised to GS1-128 FNC1 (end-of-field) character.
     F*        See note on identifying this character.
640dAF*    11/12/12  RTR  6.40d
     F*      - Fix: Copy 640a to other instances of TEMP6A.
650aAF*    03/26/13  LMC  6.50a
     F*      - Enh: replace any positions in the barcode = fnc1Hex1D
     F*        with a space.
650bAF*    10/01/13  LMC  6.50b
     F*      - Enh: We have recently seen a barcode with a space in the
     F*        lot number, so we can no longer check for a space as the
     F*        end of a variable length field.
700aAF*    03/22/16  LMC  7.00a
     F*      - Enh: Adding logic for Metric.
700bAF*    12/13/16  LMC  7.00b
     F*      - Enh: In CMDALL, if we encounter an error in CMDFIRST
     F*        don't continue with the process.
     F*        We were getting a generic message invalid code found at
     F*        position 3, which wasn't real helpful.
     F*        This change allows us to send back a more useful message
700cAF*    12/27/16  LMC  7.00c
     F*      - Fix: Condition clear on fields $Cvtdata & $Cvtdata2
     F*        only if parms are sent in.
730aAF*    04/22/19  LMC  7.30a
     F*      - Enh: We will be treating AI Code 02 same as AI Code 01
     F*        Client Accardi has vendors from italy who use AI Code 02
     F*        in their barcodes.
740aAF*    01/07/20  LMC  7.40a
     F*      - Enh: We will use uiwgtlbs from the uciinfo file if the
     F*        record exist. This only works if the uciinfo record is
     F*        unique.
740bAF*    01/21/20  LMC  7.40b
     F*      - Enh: We will return *UPCWARN instead of *INVALID on
     F*        a check digit error. We allow clients to load upc's
     F*        with a check digit, but they can't use data collection
     F*        to find it, if it has a check digit error.
740cAF*    04/06/20  DAS  7.40c
     F*      - Changed to SQLRPGLE
     F*      - Enh: Added user defined barcode definitions
     F*      - Enh: Revised UCI weight to take into account KiloLbs flag
     F*      - Changed subroutine zzzgetlbs into a subprocedure and moved
     F*        it to the end of the subprocedures. Re: You cannot call
     F*        a subroutine from within a subprocedure that resides
     F*        outside of that subprocedure.
     F*      - Deleted subroutine clr$uciinfo and moved login into
     F*        the zzzgetlbs subprocedure, because of not being able
     F*        to call the subroutine from the subprocedure.
     F*      - Changed subroutine MfrWgt into a subprocdure. Moved
     F*        all MfrWgt* subroutines that are called by MfrWgt INTO
     F*        the MfrWgt subprocedure because that is the only place
     F*        they are called from.
740dAF*    04/01/20  LMC  7.40d
     F*      - Enh: Execute the zzzgetlbs routine before returning
     F*        if no weight has been loaded up for return.
740eAF*    04/06/20  DAS  7.40e
     F*     - Added debugging method. Sending 'DEBUGhhmmss' in parm
     F*       $PAIDesc will trigger outputting info to BFCDEBUG.
     F*       The hhmmss will be used as the BFCDEBUG Type so the
     F*       calling program can retrieve the recs fro BFCDEBUG.
740fAF*    04/23/20  DAS  7.40f
     F*     - Revised to make vendor# optional
740gAF*    07/01/20  LMC  7.40g
     F*     - We have changed our internal gs1 labels to use AI code 98
     F*       instead of AI code 01.
     F*     - We need to treat AI code 98 same as AI code 01
750aAF*    01/29/21  LMC  7.50a
     F*     - Create a variable to hold the value of %parms so the
     F*       variable can be used instead of %parms, %parms would not
     F*       carry into the subprocedure.
     F*     - replace all references of %parm with parmin variable
     F*----------------------------------------------------------------
     F*  Client Custom Code - Westside
     F*
WSTaAF*    02/08/07  DAS  WSTa
     F*      - Revised routine MfrWgt to call new routine MfrWgtWst.
     F*      - Created routine MfrWgtWst to decipher Daisy code.
     F*
WSTbAF*    02/16/07  DAS  WSTb
     F*      - Revised routine MfrWgtWst to decipher Omaha Steaks code.
     F*
WSTcAF*    10/16/08  DAS  WSTc
     F*      - Revised Kilogram weights to round down if decimal is
     F*        .01 - .50, otherwise round up. This is done after the
     F*        weight is converted to pounds.
WSTdAF*    10/13/11  RH   WSTd
     F*      - Scan 10 postions for Lot code(10) for vend # 47602,
     F*        scanner not reading End of field character.
WSTe F*    01/12/12  GJA  WSTe
     F*      - Remove WSTc modification.
WSTf F*    09/19/12  GJA  WSTf
     F*      - Fix:  It was not allowing manual entry of CW if not
     F*              able to scan a label.
WSTg F*    06/21/13  GJA  WSTg
     F*      - Change kilo conversion to always be one decimal
     F*      - Remove WSTe
WSThAF*    09/25/13  LMC  WSTh
     F*      - Scan 10 postions for Lot code(10) for vend # 16900,
     F*        scanner not reading End of field character.
WSTiAF*    11/05/13  LMC  WSTi
     F*      - Revised routine MfrWgtWst to proces vendor 113776 same
     F*        as vendor 14450.
WSTjAF*    01/09/14  LMC  WSTj
     F*      - Vendor 113776 has multiple barcode formats, need to be
     F*        able to process any of them.
WSTkAF*    05/13/14  LMC  WSTk
     F*      - Scan 6 postions for Lot code(10) for vend # 116717
     F*        scanner not reading End of field character.
WSTlAF*    03/13/15  LMC  WSTl
     F*      - For Vendor 113390 - lbs converted from Kilo needs
     F*        to show 2 decimals. We will skip the previous mods
     F*        where they requested only 1 decimal on kilo conversion.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Code - Accardi Foods
     F*
ACCa F*    03/26/19  MLB  ACCa P#02049
     F*      - Revised pgm to create custom routine to extract c/wgt
     F*        from scanned data where positions 2 - 7 are zeros and
     F*        wgt is found in positions 8-12. Accardi is printing an
     F*        EAN-13 barcode from their Digi scales. Barcode will be
     F*        printed after item is weighed and affixed to item by
     F*        selector.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Code - Marques
     F*
MQSa F*    06/03/19  LMC  MQSa
     F*      - Revised pgm to determine the lenght of AI code 99 at
     F*        Marques, vendor Thompson uses aicode 99 and the data
     F*        in the code is the item#.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Code - Saval
     F*
SVLa F*    11/25/19  DAS  SVLa
     F*      - For eaches, Saval is printing a EAN-13 barcode formatted
     F*        as follows:
     F*           nniiiiiwwwwwc
     F*        where nn will be set to 99, iiiii is the Dakota item
     F*        number, wwwww is the weight with 2 decimals and
     F*        c is the checkdigit.
     F*      - Revised *UPC, when value is 13 characters starting
     F*        with 99, extract char 3-7 as the UPC code.
     F*      - Created custom weight routine, when value is 13 char
     F*        starting with 99, extract char 8-12 as weight.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Code - Big Apple Deli
     F*
BADa F*    02/13/20  LMC  BADa
     F*      - Revised *UPC, when pos 7-8 = WO.
     F*        extract pos 1-6 as the UPC code.
BADb F*    02/14/20  LMC  BADb
     F*      - Revised *UPC, We now got some samples from another
     F*        client, where the item number can be longer than 6
     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

740eAFbfcdebug  o    e           k disk

740cA*----------------------------------------------------------------
740cA*  File data data structure
740cA*----------------------------------------------------------------
740cA
740cAD bdhrec        E ds                  extname(bardefh) inz(*EXTDFT)
740cAD bddrec        E ds                  extname(bardefd) inz(*EXTDFT)
740cAD bdirec        E ds                  extname(bardefi) inz(*EXTDFT)

417nA*------------------------------------------------------------------
417nA*  Client id's for custom mods.
417nA*------------------------------------------------------------------
500uA /copy qcopysrc,id#westsid
ACCaA /copy qcopysrc,id#acc
MQSaA /copy qcopysrc,id#MQS
SVLaA /copy qcopysrc,id#saval
BADaA /copy qcopysrc,id#bad
417nAD client          s             10
500zAD clientloc       s             10

640bA*----------------------------------------------------------------
640bA*  Convert Barcode Parms
640bA*----------------------------------------------------------------

640bA /COPY *libl/qcopysrc,C#CVTPARMS
640bA /COPY *libl/qcopysrc,C#BARCODE

700aA*----------------------------------------------------------------
700aA* Function prototypes.
700aA*----------------------------------------------------------------

700aA /copy qcopysrc,p.getimuom
740aA /copy qcopysrc,p.getuser
740aA /copy qcopysrc,p.driuci

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item
740aA /COPY *libl/qcopysrc,C#uciinfo
     D savever#        s                   like($itver#)
     D save$item       s                   like($item)
     D save$item2      s                   like($item2)

740aA*----------------------------------------------------------------
740aA*  Called program flags
740aA*----------------------------------------------------------------

740aAD driUCICalled    s               n

     D*----------------------------------------------------------------
     D*  Table definitions
     D*----------------------------------------------------------------
510 DD*TCOD            S              4  0 DIM(8) CTDATA PERRCD(1)
510 DD*TDSC            S             30    DIM(8) ALT(TCOD)
510dDD*TCOD            S              4  0 DIM(9) CTDATA PERRCD(1)
510dDD*TDSC            S             30    DIM(9) ALT(TCOD)
640bDD*TCOD            S              4  0 DIM(10) CTDATA PERRCD(1)
640bDD*TDSC            S             30    DIM(10) ALT(TCOD)
730aDD*TCOD            S              4  0 DIM(19) CTDATA PERRCD(1)
730aDD*TDSC            S             30    DIM(19) ALT(TCOD)
730aMD TCOD            S              4  0 DIM(20) CTDATA PERRCD(1)
730aMD TDSC            S             30    DIM(20) ALT(TCOD)

     D*----------------------------------------------------------------
     D*  Arrays
     D*----------------------------------------------------------------
     D A9              S              1A   Dim(9)
     D A14             S              1A   Dim(14)
520aAD A18             S              1A   Dim(18)

     D*----------------------------------------------------------------
     D*  Constants
     D*----------------------------------------------------------------
     D Delim1L         C                   '('
     D Delim1R         C                   ')'
     D Delim2L         C                   '['
     D Delim2R         C                   ']'
     D Delim3L         C                   '<'
     D Delim3R         C                   '>'
     D Delim4L         C                   '{'
     D Delim4R         C                   '}'
640cAD fnc1Hex1D       C                   x'1D'
650aAD space           c                   ' '
740cDD*Forever         C                   1
510 AD kgs2lbs         c                   2.20462262
     D MaxAILen        C                   4
     D MaxAry          C                   100
     D Numbers         C                   '0123456789'
BADb D TFWOchk         C                   'WO'

740cA*----------------------------------------------------------------
740cA*  Standard variables and constants
740cA*----------------------------------------------------------------
740cA
740cA /copy qcopysrc,c#stdvar

     D*----------------------------------------------------------------
     D*  Variables
     D*----------------------------------------------------------------
     D AIChar          S              1
     D AICode          S              4S 0
     D AICodeLen       S              3P 0
     D AICount         S              3P 0
     D AIDecPos        S              1P 0
     D AINumb          S              3P 0
     D BarCodeLen      S              3P 0
     D BarPos          S              3P 0
415bAD CheckRem        S              5S 0
415bAD CheckDigit      S              1S 0
415bAD CheckDigitA     S              1
415bAD CheckDigitA2    S              1
415bAD DigitSum        S              5P 0
415cAD DigitDiv        S              5P 0
     D Divisor         S             11P 0
640cAD endPos          S              3  0
740cDD*Error           S              1
     D FlagAdj         S              1
     D FlagDecPt       S              1
640cAD fnc1Char        S               n
640cAD fnc1Len         S              1  0
640bAD GTINSent        S              1
740cDD*I               S              3P 0
700aAD IMkilolbs       s              1
700aAD IMUom           s              3
740cDD*J               S              3P 0
700aAD kilos110        s             11  0
700aAD kilos111        s             11  1
700aAD kilos112        s             11  2
700aAD kilos113        s             11  3
640bAD LotSent         S              1
740cAD pItem           s             15
740cAD pKiloLbs        s              1
740fAD pVen#           s             10  0
740cAD pWhse           s              3  0
510 AD pounds110       s             11  0
510 AD pounds111       s             11  1
510 AD pounds112       s             11  2
510 AD pounds113       s             11  3
640bAD ProdDtSent      S              1
510cAD MfrWgtRtn       S              8
640cAD startPos        S              3  0
     D T               S              3P 0
     D Temp1A          S              1
415bAD Temp1N          S              1S 0
WSTbAD Temp3A          S              3
ACCaAD Temp4A          S              4
SVLaAD Temp5A          S              5
     D Temp6A          S              6
WSTaAD Temp8A          S              8
WSTaAD Temp31N         S              3s 1
ACCaAD Temp42N         S              4s 2
SVLaAD Temp52N         S              5s 2
     D Temp5N          S              5P 0
     D Temp6N          S              6S 0
     D Temp9A          S              9
     D Temp9N          S              9P 0
415bAD Temp14A         S             14
510aAD Temp18A         S             18
MQSaAD MqsEnd          S              3s 0

740aAD e$whse          s              3  0
740aAD e$emp#          s              5  0
740aAD e$fnam          s             15
740aAD e$init          s              1
740aAD e$lnam          s             20
740aAD e$whdp          s              5
740aAD e$styp          s              1
740aAD e$shft          s              6
740aAD e$crew          s              6
740aAD e$nhrs          s              3  1
740aAD e$rtn           s              8
740aAD e$bpu           s              1
740aAD e$lng           s              2
BADbAD TFWO            s              3  0
BADbAD TFend           s              3  0

740eAd debug           s               n
740eAd debugMsg        s             99    varying

750aAd parmin          s              5p 0
     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

740eAD/copy qcopysrc,c#pgminfds
740eDD*               sds
740eDD* #prog            *proc
740eDD* #job                 244    253
740eDD* #user                254    263
740eDD* #jobn                264    269
740eDD* #jobdt               276    281  0
740eDD* #jobtm               282    287  0

740cA*----------------------------------------------------------------
740cA*  Standard SQL variables and constants
740cA*----------------------------------------------------------------
740cA
740cA /copy qcopysrc,c#stdsql

740cA*----------------------------------------------------------------
740cA*  Sub-procedure prototypes
740cA*----------------------------------------------------------------

740cAd CheckCustom     pr              n

740cAd ConvertLb2Kg    pr            11s 3
740cAd   wgt                         11s 3
740cAd   decPos                       1p 0

740cAd ConvertKg2Lb    pr            11s 3
740cAd   wgt                         11s 3
740cAd   decPos                       1p 0

740cAd VerifyDef       pr              n
740cAd  whse                          3s 0
740cAd  def#                          5p 0

740cAd GetItemDef      pr             5p 0

740cAd GetMfrDef       pr             5p 0

740cAd ProcessDef      pr
740cAd  def#                          5p 0

740cAd ProcessDefDate  pr             6s 0

740cAd ProcessDefWgt   pr            11p 3

740cAd zzzgetlbs       pr

740cAd MfrWgt          pr

740eAd WrtDebugParms   pr
740eAd WrtDebugMsg     pr

     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PCmd   *FIRST    -  Retrieve first value
     C*              *NEXT     -  Retrieve next value
     C*              *CWGTLBS  -  Retrieve catchweight (lbs)
     C*              *EXPDT    -  Retrieve Expiration Date (YYMMDD)
     C*              *PKGDT    -  Retrieve Packaging Date (YYMMDD)
     C*              *PRODDT   -  Retrieve Production Date (YYMMDD)
     C*              *SCC-14   -  Retrieve SSC-14 code
     C*              *SELLBY   -  Retrieve Sell By Date (YYMMDD)
     C*              *SSCC-18  -  Retrieve SSCC-18 code
     C*              *UPC      -  Retrieve one of the following codes:
     C*                           UPC-12, EAN-13, SSC-14 or SSCC-18
417a C*              *VRFYLP7  -  Verify license is only 7 long.
     C*      $PBarCode  Barcode
740eAC*      $PAIDesc   Send 'DEBUGhhmmss' to trigger debugging.
510cAC*      $PVen#       Vendor/Mfr number. Used for *CWGTLBS.
700aMC*      $Pwhse       Whse used to get item options for weight uom  (optional)
700aMC*      $PkilolbsSent  How value for *CWGTLBS should be returnd (optional)
     C*                     P = Pounds, K = Kilograms
740cAC*      $PItem       tem number, used with user-defined barcodes (optional)
     C*
     C*    Returned Parameters
     C*      $PAICode     Application identifier
     C*      $PAIDecPos   Application identifier decimal positions
     C*      $PAIDesc     Application identifier description
     C*      $PAIPos      Application identifier code position
     C*      $PValueTyp   Value type
     C*      $PValue1     Numeric 11.3
     C*      $PValue2     Alpha 50
     C*      $PReturn     *OK
     C*                   *NOMORE
     C*                   *NOTFND
     C*                   *INVALID
640bAC*      $Cvtdata
640bAC*      $Cvtdata2
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PCmd             8
     C                   PARM                    $PBarCode       100
     C                   PARM                    $PAICode          3 0
     C                   PARM                    $PAIDecPos        1 0
     C                   PARM                    $PAIDesc         30
     C                   PARM                    $PAIPos           3 0
     C                   PARM                    $PValueTyp        1 0
     C                   PARM                    $PValue1         11 3
     C                   PARM                    $PValue2         50
     C                   PARM                    $PReturn          8
     C                   PARM                    $PErrMsg         60
510cMC                   PARM                    $PVen#           10 0
640bAC                   PARM                    $Cvtdata
640bAC                   PARM                    $Cvtdata2
700aMC                   PARM                    $Pwhse            3 0
700aMC                   PARM                    $PkilolbsSent     1
740cAC                   PARM                    $PItem           15

700aA /free

750aA   parmin = %parms;
740eA   // See if we should turn on debugging
740eA
740eA   if %subst($PAIDesc: 1: 5) = 'DEBUG';
740eA     debug = *on;
740eA     bdtype = %subst($PAIDesc: 6: 6);
740eA   else;
740eA     debug = *off;
740eA   endif;

750aD   //if %parms >= 12;
7450a   if parmin >= 12;
740fA     pVen# = $PVen#;
740fA   else;
740fA     pVen# = 0;
740fM   endif;

740aD   //select;
740aD   //  when      %parms >= 15;
740aD   //    exsr zzimopt;
740aD   //  other;
740aD   //endsl;

750aD   //if %parms >= 15;
750aM   if parmin >= 15;
740cA     pWhse = $Pwhse;
700aA     exsr zzimopt;
740cA   else;
740cA     pWhse = 0;
740cM   endif;

750aD   //if %parms >= 16;
750aM   if parmin >= 16;
740cA     pKiloLbs = $PkilolbsSent;
700cA   else;
740cA     pKiloLbs = 'P';
740cA   endif;
740cA   if pKiloLbs <> 'K';
740cA     pKiloLbs = 'P';
740cA   endif;

750aD   //if %parms >= 17;
750aM   if parmin >= 17;
740cA     pItem = $PItem;
700cA   else;
740cA     pItem = '';
740cA   endif;

700aA /end-free

     C                   eval      $PAICode = 0
     C                   eval      $PAIDecPos = 0
     C                   eval      $PAIDesc = ' '
     C                   eval      $PValueTyp = 0
     C                   eval      $PValue1 = 0
     C                   eval      $PValue2 = ' '
     C                   eval      $PReturn = '*OK'
     C                   eval      $PErrMsg = ' '
640bAc                   clear                   $barcode
640bAc                   clear                   $barcode2
700cDc*                  clear                   $Cvtdata
700cDc*                  clear                   $Cvtdata2
700cA /free
750aD   //if %parms >= 13;
750aM   if parmin >= 13;
700cA     clear $Cvtdata;
700cA     clear $Cvtdata2;
700cA   endif;
700cA /end-free

     C*----------------------------------------------------------------
     C* Main line
     C*
     C                   eval      Error = *OFF
     C*
     C*  Left adjust barcode
     C*
     C                   eval      $PBarCode = %TrimL($PBarCode)
     C*
     C*   Get barcode length
     C*
     C                   eval      BarCodeLen = %Len(%Trim($PBarCode))
740cA /free
740eA
740eA   if debug;
740eA     WrtDebugParms();
740eA   endif;
740cA
740cA     // Look for custom barcode
740cA
740cA      if CheckCustom();
740cA        $pbarcode = %XLATE(fnc1Hex1D: space: $pbarcode);
750aD        //if %parms >= 13;
750aM        if parmin >= 13;
740cA          $cvtdata = $barcode;
740cA          $cvtdata2 = $barcode2;
740cA        endif;
740aA        if debug;
740aA          debugMsg = 'Code: ' + %char($pAICode) +', '
740aA                   + 'ValType: ' + %char($pValueTyp) +', '
740fA                   + 'Val1: ' + %char($pValue1) +', '
740fA                   + 'Val2: ' + %trim($pValue2) +', '
740fA                   + 'Rtn: ' + %trim($pReturn) +', '
740fA                   + 'Msg: ' + %trim($pErrMsg);
740aA          WrtDebugMsg();
740aA        endif;
740cA        return;
740cA      endif;
740cA
740cA      if error;
740aA        if debug;
740aA          debugMsg = 'Code: ' + %char($pAICode) +', '
740aA                   + 'ValType: ' + %char($pValueTyp) +', '
740fA                   + 'Val1: ' + %char($pValue1) +', '
740fA                   + 'Val2: ' + %trim($pValue2) +', '
740fA                   + 'Rtn: ' + %trim($pReturn) +', '
740fA                   + 'Msg: ' + %trim($pErrMsg);
740aA          WrtDebugMsg();
740aA        endif;
740cA        return;
740cA      endif;
740eA
740eA   if debug;
740eA     debugMsg = 'No User-Defined Definition found for Item or Mfr. '
740eA              + 'Do Normal processing.';
740eA     WrtDebugMsg();
740eA   endif;
740eA
740cA /end-free
     C*
     C*   Execute appropriate routine
     C*
640bAC     $PCmd         caseq     '*ALL    '    CmdAll
     C     $PCmd         caseq     '*FIRST  '    CmdFirst
     C     $PCmd         caseq     '*NEXT   '    CmdNext
     C     $PCmd         caseq     '*CWGTLBS'    CmdWgtLbs
     C     $PCmd         caseq     '*UPC    '    CmdUpc
     C     $PCmd         caseq     '*SSCC-18'    CmdSSCC18
     C     $PCmd         caseq     '*SCC-14 '    CmdSCC14
     C     $PCmd         caseq     '*SELLBY '    CmdSellBy
     C     $PCmd         caseq     '*EXPDT  '    CmdExpDt
     C     $PCmd         caseq     '*PKGDT  '    CmdPkgDt
     C     $PCmd         caseq     '*PRODDT '    CmdProdDt
417a C     $PCmd         caseq     '*VFYLP7 '    CmdVfyLp7
     C                   endcs
     C*
650aAc                   eval      $pbarcode =
650aAc                              %XLATE(fnc1Hex1D: space: $pbarcode)
740fA /free
740aA    if debug;
740aA      debugMsg = 'Code: ' + %char($pAICode) +', '
740aA               + 'ValType: ' + %char($pValueTyp) +', '
740fA               + 'Val1: ' + %char($pValue1) +', '
740fA               + 'Val2: ' + %trim($pValue2) +', '
740fA               + 'Rtn: ' + %trim($pReturn) +', '
740fA               + 'Msg: ' + %trim($pErrMsg);
740aA      WrtDebugMsg();
740aA    endif;
740aA /end-free
     C                   Return
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subroutine.
     C*
     C     *INZSR        begsr
510 A
510 A*  Get client id
510 A
510 AC                   call      'GETCLIENT'
510 AC                   parm                    client
510 AC                   parm                    clientloc

     C                   endsr
     C*----------------------------------------------------------------
     C*  BarGetCod  -  Get next application identifer code for barcode
     C*
     C     BarGetCod     begsr
640cAC*
640cAC*    Get rid of left over FNC1 character from previous value
640cAC*
650cAC                   if        BarPos <= BarCodeLen
640cAC                   eval      temp1a = %Subst($PBarCode:BarPos:1)
640cAC                   exsr      ChkFNC1
640cAC                   if        fnc1Char
640cAC                   eval      BarPos += fnc1Len
650cAC                   endif
650cAC                   endif
     C*
     C*  See if we have reached the end of the barcode.
     C*
     C                   if        BarPos > BarCodeLen
     C                   eval      Error = *ON
     C                   eval      $PReturn = '*NOMORE '
     C                   eval      $PAIPos = BarPos
     C                   eval      $PErrMsg = 'End of barcode found '
     C                                        + 'at position '
     C                                        + %Trim(%EditC($PAIPos:'Z'))
     C                   goto      EndGetCode
     C                   endif
     C*
     C*  Initialize values.
     C*
     C                   eval      AICode   = 0
     C                   eval      AIDecPos = 0
     C                   eval      AICount  = 1
     C*
     C*  Loop through characters looking for code.
     C*
     C     Forever       DowEq     Forever
     C*
     C*    Get character
     C*
     C                   eval      AIChar = %Subst($PBarCode:BarPos:1)
     C*
     C*    Character must be numeric.
     C*
     C                   eval      AINumb = %Scan(AIChar:Numbers)
     C                   if        AINumb = 0
     C                   eval      Error = *ON
     C                   eval      $PReturn = '*INVALID'
     C                   eval      $PAIPos = BarPos - AICount + 1
     C                   eval      $PErrMsg = 'Invalid code found at position '
     C                                        + %Trim(%EditC($PAIPos:'Z'))
     C                   leave
     C                   endif
     C*
     C*    Add character to Application Identifier code.
     C*
     C                   eval      Temp6N = (AICode * 10) + (AINumb-1)
     C                   z-add     Temp6n        AICode
     C*
     C*    Need at least two characters to identify code.
     C*
     C                   if        AICount < 2
     C                   eval      AICount = AICount + 1
     C                   eval      BarPos  = BarPos + 1
     C                   iter
     C                   endif
     C*
     C*    Search for match
     C*
     C                   eval      T = 1
     C     AICode        lookup    TCOD(T)                                50
     C                   if        %Found
     C                   eval      $PAICode = AICode
     C                   eval      $PAIDesc = TDSC(T)
     C                   eval      $PAIPos = BarPos - AICount + 1
     C                   if        AICode > 300 AND AICode < 400
     C                   eval      AICount = AICount + 1
     C                   eval      BarPos  = BarPos + 1
     C                   exsr      BarGetDec
     C                   endif
     C                   leave
     C                   endif
     C*
     C*    If we have reached the end of our barcode
     C*      Then create error
     C*
     C                   if        BarPos = BarCodeLen OR BarPos = MaxAry
     C                   eval      Error = *ON
     C                   eval      $PReturn = '*INVALID'
     C                   eval      $PAIPos = BarPos - AICount + 1
     C                   eval      $PErrMsg = 'Invalid code found at position '
     C                                        + %Trim(%EditC($PAIPos:'Z'))
     C                   leave
     C                   endif
     C*
     C*    If we have not reach the max AI code length
     C*      Then get the next character for the code
     C*
     C                   if        AICount < MaxAILen
     C                   eval      AICount = AICount + 1
     C                   eval      BarPos  = BarPos + 1
     C                   iter
     C                   endif
     C*
     C*    Otherwise, create error.
     C*
     C                   eval      Error = *ON
     C                   eval      $PReturn = '*INVALID'
     C                   eval      $PAIPos = BarPos - AICount + 1
     C                   eval      $PErrMsg = 'Invalid code found at position '
     C                                        + %Trim(%EditC($PAIPos:'Z'))
     C                   leave
     C*
     C                   enddo
     C*
     C     EndGetCode    endsr
     C*----------------------------------------------------------------
     C*  BarGetDec - Get decimal positions for 300 series codes
     C*
     C     BarGetDec     begsr
     C*
     C*    Get character
     C*
     C                   eval      AIChar = %Subst($PBarCode:BarPos:1)
     C*
     C*    Character must be numeric.
     C*
     C                   eval      AINumb = %Scan(AIChar:Numbers)
     C                   if        AINumb = 0
     C                   eval      Error = *ON
     C                   eval      $PReturn = '*INVALID'
     C                   eval      $PAIPos = BarPos - AICount + 1
     C                   eval      $PErrMsg = 'Invalid code found at position '
     C                                        + %Trim(%EditC($PAIPos:'Z'))
     C                   Goto      EndGetDP
     C                   endif
     C*
     C*    We have our decimal places
     C*
     C                   eval      AIDecPos = AINumb - 1
     C                   eval      $PAIDecPos = AIDecPos
     C*
     C     EndGetDP      endsr
     C*----------------------------------------------------------------
     C*  BarGetVal - Get value for AI code
     C*
     C     BarGetVal     begsr
     C                   eval      BarPos  = BarPos + 1
     C*
     C                   select
     C*
     C*    00 - SSCC-18
     C*
     C                   when      AICode = 0
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcSsccSent = *on
640bAc                   endif
     C                   eval      AICodeLen = 18
     C                   eval      $PValueTyp = 2
     C                   eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
415bAC                   if        AICodeLen <> %Len(%Trim($PValue2))
415bAC                   eval      Error = *ON
415bAC                   eval      $PReturn = '*INVALID'
415bAC                   eval      $PAIPos = BarPos
415bAC                   eval      $PErrMsg = 'Invalid SSCC-18 code found '
415bAC                                        + 'at positon '
415bAC                                        + %Trim(%EditC($PAIPos:'Z'))
415bAC                   Goto      EndGetVal
415bAC                   endif

415bAC                   exsr      ChkMod10
415bAC     Error         CabEq     *On           EndGetVal
640bA *      load new parameter
640bAc                   if        $bcSsccSent
640bAc                   eval      $bcSscc = $pvalue2
640bAc                   else
640bAc                   eval      $bcSscc = ' '
640bAc                   endif
     C*
     C*    01 - SCC-14
     C*
     C                   when      AICode = 1
730aAc                             or AICode = 2
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcGtinSent = *off
640bAc                   endif
     C                   eval      AICodeLen = 14
     C                   eval      $PValueTyp = 2
     C                   eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
415bAC                   if        AICodeLen <> %Len(%Trim($PValue2))
415bAC                   eval      Error = *ON
415bAC                   eval      $PReturn = '*INVALID'
415bAC                   eval      $PAIPos = BarPos
415bAC                   eval      $PErrMsg = 'Invalid SCC-14 code found '
415bAC                                        + 'at positon '
415bAC                                        + %Trim(%EditC($PAIPos:'Z'))
415bAC                   Goto      EndGetVal
415bAC                   endif

415bAC                   exsr      ChkMod10
640bAc                   if        $PCmd = '*ALL    '
640bAc                             and error = *off
640bAc                   eval      $bcGtinSent = *on
640bAc                   endif
415bAC     Error         CabEq     *On           EndGetVal
640bA *      load new parameter
640bAc                   if        $bcGtinSent
640bAc                   eval      $bcGtin = $pvalue2
640bAc                   else
640bAc                   eval      $bcGtin = ' '
640bAc                   endif
510dAC*
510dAC*    10 - Batch / Lot Code
510dAC*
510dAC                   when      AICode = 10
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcLotSent = *on
640bAc                   endif
WSTkAc                   Select
WSTkAc                   When      client = westside
740fdc**                           and $pVen# = 116717
740fMc                             and pVen# = 116717
WSTkAc                   eval      AICodeLen = 6
WSTkDC*                  if        client = westside
WSTkMC                   When      client = westside
740fDC**                           and $pVen# = 74766
740fMC                             and pVen# = 74766
WSTkAC                   eval      AICodeLen = 10
WSTkDC*                            or client = westside
WSTkMC                   When      client = westside
740fDC**                           and $pVen# = 16900
740fMC                             and pVen# = 16900
WSTdAC                   eval      AICodeLen = 10
WSTkDC*                  else
WSTkMC                   Other
510dAC                   eval      AICodeLen = 20
WSTkDC*                  endif
WSTkMC                   endsl
640cDC**                 if        (BarPos + AICodeLen - 1) > BarCodeLen
640cDC**                 eval      AICodeLen = BarCodeLen - BarPos + 1
640cDC**                 endif
510dAC                   eval      $PValueTyp = 2
640cAC                   exsr      BarGetVarLen
640cAC                   eval      AICodeLen = %len(%trim($pvalue2))
640cDC**                 eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
640bA *      load new parameter
640bAc                   if        $bcLotSent
640bAc                   eval      $bcLot = $pvalue2
640bAc                   else
640bAc                   eval      $bclot = ' '
640bAc                   endif
     C*
     C*    11 - Production Date (YYMMDD)
     C*
     C                   when      AICode = 11
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcProdDSent = *on
640bAc                   endif
     C                   eval      AICodeLen = 6
     C                   eval      $PValueTyp = 1
     C                   eval      Temp6A = %Subst($PBarCode:BarPos:AICodeLen)
415bAC                   if        AICodeLen <> %Len(%Trim(Temp6A))
415bAC                   eval      Error = *ON
415bAC                   eval      $PReturn = '*INVALID'
415bAC                   eval      $PAIPos = BarPos
415bAC                   eval      $PErrMsg = 'Invalid production date found '
415bAC                                        + 'at positon '
415bAC                                        + %Trim(%EditC($PAIPos:'Z'))
415bAC                   Goto      EndGetVal
415bAC                   endif
640dAC*
640dAC*      Check value is numeric.
640dAC                   movea     Temp6a        A18
640dAC                   exsr      ChkNbr
640dAC                   if        Error = *ON
640dAC                   eval      $PAIPos = i
640dAC                   Goto      EndGetVal
640dAC                   endif
640dAC*
     C                   move      Temp6A        Temp6N
     C                   eval      $PValue1 = Temp6N
640bA *      load new parameter
640bAc                   if        $bcProdDSent
640bAc                   eval      $bcProdD = $pvalue1
640bAc                   else
640bAc                   eval      $bcProdD = 0
640bAc                   endif
     C*
     C*    13 - Packaging Date (YYMMDD)
     C*
     C                   when      AICode = 13
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcPackDSent = *on
640bAc                   endif
     C                   eval      AICodeLen = 6
     C                   eval      $PValueTyp = 1
     C                   eval      Temp6A = %Subst($PBarCode:BarPos:AICodeLen)
415bAC                   if        AICodeLen <> %Len(%Trim(Temp6A))
415bAC                   eval      Error = *ON
415bAC                   eval      $PReturn = '*INVALID'
415bAC                   eval      $PAIPos = BarPos
415bAC                   eval      $PErrMsg = 'Invalid packaging date found '
415bAC                                        + 'at positon '
415bAC                                        + %Trim(%EditC($PAIPos:'Z'))
415bAC                   Goto      EndGetVal
415bAC                   endif
640dAC*
640dAC*      Check value is numeric.
640dAC                   movea     Temp6a        A18
640dAC                   exsr      ChkNbr
640dAC                   if        Error = *ON
640dAC                   eval      $PAIPos = i
640dAC                   Goto      EndGetVal
640dAC                   endif
640dAC*
     C                   move      Temp6A        Temp6N
     C                   eval      $PValue1 = Temp6N
640bA *      load new parameter
640bAc                   if        $bcPackDSent
640bAc                   eval      $bcPackD = $pvalue1
640bAc                   else
640bAc                   eval      $bcPackD = 0
640bAc                   endif
     C*
     C*    15 - Sell by Date (YYMMDD)
     C*
     C                   when      AICode = 15
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcSlByDSent = *on
640bAc                   endif
     C                   eval      AICodeLen = 6
     C                   eval      $PValueTyp = 1
     C                   eval      Temp6A = %Subst($PBarCode:BarPos:AICodeLen)
415bAC                   if        AICodeLen <> %Len(%Trim(Temp6A))
415bAC                   eval      Error = *ON
415bAC                   eval      $PReturn = '*INVALID'
415bAC                   eval      $PAIPos = BarPos
415bAC                   eval      $PErrMsg = 'Invalid sell-by date found '
415bAC                                        + 'at positon '
415bAC                                        + %Trim(%EditC($PAIPos:'Z'))
415bAC                   Goto      EndGetVal
415bAC                   endif
640dAC*
640dAC*      Check value is numeric.
640dAC                   movea     Temp6a        A18
640dAC                   exsr      ChkNbr
640dAC                   if        Error = *ON
640dAC                   eval      $PAIPos = i
640dAC                   Goto      EndGetVal
640dAC                   endif
640dAC*
     C                   move      Temp6A        Temp6N
     C                   eval      $PValue1 = Temp6N
640bA *      load new parameter
640bAc                   if        $bcSlByDSent
640bAc                   eval      $bcSlByD   =  $pvalue1
640bAc                   else
640bAc                   eval      $bcSlByd = 0
640bAc                   endif
     C*
     C*    17 - Expiration Date (YYMMDD)
     C*
     C                   when      AICode = 17
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcExpDSent = *on
640bAc                   endif
     C                   eval      AICodeLen = 6
     C                   eval      $PValueTyp = 1
     C                   eval      Temp6A = %Subst($PBarCode:BarPos:AICodeLen)
640aDC*                  move      Temp6A        Temp6N
415bAC                   if        AICodeLen <> %Len(%Trim(Temp6A))
415bAC                   eval      Error = *ON
415bAC                   eval      $PReturn = '*INVALID'
415bAC                   eval      $PAIPos = BarPos
415bAC                   eval      $PErrMsg = 'Invalid expiration date found '
415bAC                                        + 'at positon '
415bAC                                        + %Trim(%EditC($PAIPos:'Z'))
415bAC                   Goto      EndGetVal
415bAC                   endif
640aAC*      Check value is numeric.
640aAC                   movea     Temp6a        A18
640aAC                   exsr      ChkNbr
640aAC                   if        Error = *ON
640aAC                   eval      $PAIPos = i
640aAC                   Goto      EndGetVal
640aAC                   endif
640aAC*
640aAC                   move      Temp6A        Temp6N
     C                   eval      $PValue1 = Temp6N
640bA *      load new parameter
640bAc                   if        $bcExpDSent
640bAc                   eval      $bcExpD =  $pvalue1
640bAc                   else
640bAc                   eval      $bcExpD = 0
640bAc                   endif
     C*
     C*    21 - Serial number
     C*
     C                   when      AICode = 21
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcSer#Sent = *on
640bAc                   endif
     C                   eval      AICodeLen = 20
640cDC**                 if        (BarPos + AICodeLen - 1) > BarCodeLen
640cDC**                 eval      AICodeLen = BarCodeLen - BarPos + 1
640cDC**                 endif
     C                   eval      $PValueTyp = 2
640cAC                   exsr      BarGetVarLen
640cAC                   eval      AICodeLen = %len(%trim($pvalue2))
640cDC**                 eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
640bA *      load new parameter
640bAc                   if        $bcSer#Sent
640bAc                   eval      $bcSer#  =  $pvalue2
640bAc                   else
640bAc                   eval      $bcSer#  = ' '
640bAc                   endif
510 AC*
510 AC*    310 - Net Weight, Kilograms
510 AC*
510 AC                   when      AICode = 310
740cDc**                 if        $PCmd = '*ALL    '
740cDc**                 eval      $bcPNtKgSent = *on
740cDc**                 endif
740cAc                   eval      $bcPNtLbSent = *on
740cAc                   eval      $bcPNtLb = 0
740cAc                   eval      $bcPNtKgSent = *on
740cAc                   eval      $bcPNtKg = 0

     C                   eval      AICodeLen = 6
     C                   eval      $PValueTyp = 1
     C                   eval      Temp6A = %Subst($PBarCode:BarPos:AICodeLen)
640aDC*                  move      Temp6A        Temp6N
     C                   if        AICodeLen <> %Len(%Trim(Temp6A))
     C                   eval      Error = *ON
     C                   eval      $PReturn = '*INVALID'
     C                   eval      $PAIPos = BarPos
     C                   eval      $PErrMsg = 'Invalid net weight kilograms '
     C                                        + 'found at positon '
     C                                        + %Trim(%EditC($PAIPos:'Z'))
     C                   Goto      EndGetVal
     C                   endif
640aAC*      Check value is numeric.
640aAC                   movea     Temp6a        A18
640aAC                   exsr      ChkNbr
640aAC                   if        Error = *ON
640aAC                   eval      $PAIPos = i
640aAC                   Goto      EndGetVal
640aAC                   endif
640aAC*
640aAC                   move      Temp6A        Temp6N
     C                   if        AIDecPos = 0
     C                   eval      $PValue1 = Temp6N
     C                   else
     C                   eval      $PValue1 = Temp6N
     C     1             do        AIDecPos
     C                   eval      $PValue1 = $PValue1 / 10
     C                   enddo
     C                   endif
740cA /free
740cA        $bcPNtKg = $pvalue1;
740cA
740cA        // Convert to Pounds
740cA
740cA        $bcPNtlb = ConvertKg2Lb($bcPNtKg: AIDecPos);
740cA
740cA        // Get UCI override
740cA
740cA        $pvalue1 = $bcPNtlb;
740aA        zzzgetlbs();
740cA
740cA        // If Pounds changed, convert to Kilos
740cA
740cA        if $pvalue1 <> $bcPNtlb;
740cA          $bcPNtkg = ConvertLb2Kg($bcPNtlb: AIDecPos);
740cA        endif;
740cA
740cA        // Send back requested value
740cA
740cA        if IMkilolbs = 'K';
740cA          $pvalue1 = $bcPNtkg;
740cA        else;
740cA          $pvalue1 = $bcPNtlb;
740cA        endif;
740cA /end-free
640bA *      load new parameter
740cDc**                 if        $bcPNtKgSent
740cDc**                 eval      $bcPNtKg   = $pvalue1
740cDc**                 else
740cDc**                 eval      $bcPNtKg   = 0
740cDc**                 endif
740cDc**                 if        $pcmd = '*ALL    '
640bA *      now convert it to lbs
740cDC**                 select
740cDC**                 when      AIDecPos = 0
740cDC**                 eval(h)   pounds110 = $pValue1 * kgs2lbs
740cDC**                 eval      $pValue1 = pounds110
740cDC**                 when      AIDecPos = 1
740cDC**                 eval(h)   pounds111 = $pValue1 * kgs2lbs
740cDC**                 eval      $pValue1 = pounds111
740cDC**                 when      AIDecPos = 2
740cDC**                 eval(h)   pounds112 = $pValue1 * kgs2lbs
740cDC**                 eval      $pValue1 = pounds112
740cDC**                 other
740cDC**                 eval(h)   pounds113 = $pValue1 * kgs2lbs
740cDC**                 eval      $pValue1 = pounds113
740cDC**                 endsl
740cDC**
740cDC**      For Westside, round converted pounds up/down to interger.
740cDC**        Note: .01 has to be subtracted because Westside wants
740cDC**              to round up starting at .51, but %inth rounds
740cDC**              up starting at .50.
740cDC**
740cDC**      740c - This code was moved to ConvertKg2Lb
740cDC**
740cDC**                 if        client = westside
740cDc**                 if        $PVen# <> 113390
740cDC**                 eval      $pValue1 *= 10
740cDC**                 eval      $pValue1 = %inth($pvalue1 - .01)
740cDC**                 eval      $pValue1 /= 10
740cDc**                 endif
740cDC**                 endif
640bA *      load new parameter
740cDc**                 if        $bcPNtKgSent
740cDc**                 eval      $bcPNtlbSent = *on
740cDc**                 eval      $bcPNtLb    = $pvalue1
740cDc**                 else
740cDc**                 eval      $bcPntLb    = 0
740cDc**                 eval      $bcPNtlbSent = *off
740cDc**                 endif
740vDc**                 endif
740cD /free
740cD   //exsr zzzgetlbs;
740cD /end-free
     C*
     C*    320 - Net Weight, Pounds
     C*
     C                   when      AICode = 320
740cDc**                 if        $PCmd = '*ALL    '
740cDc**                 eval      $bcPNtLbSent = *on
740cDc**                 endif
740cAc                   eval      $bcPNtLbSent = *on
740cAc                   eval      $bcPNtLb = 0
740cAc                   eval      $bcPNtKgSent = *on
740cAc                   eval      $bcPNtKg = 0
     c
     C                   eval      AICodeLen = 6
     C                   eval      $PValueTyp = 1
     C                   eval      Temp6A = %Subst($PBarCode:BarPos:AICodeLen)
640aDC*                  move      Temp6A        Temp6N
415bAC                   if        AICodeLen <> %Len(%Trim(Temp6A))
415bAC                   eval      Error = *ON
415bAC                   eval      $PReturn = '*INVALID'
415bAC                   eval      $PAIPos = BarPos
415bAC                   eval      $PErrMsg = 'Invalid net weight pounds found '
415bAC                                        + 'at positon '
415bAC                                        + %Trim(%EditC($PAIPos:'Z'))
415bAC                   Goto      EndGetVal
415bAC                   endif
640aAC*      Check value is numeric.
640aAC                   movea     Temp6a        A18
640aAC                   exsr      ChkNbr
640aAC                   if        Error = *ON
640aAC                   eval      $PAIPos = i
640aAC                   Goto      EndGetVal
640aAC                   endif
640aAC*
640aAC                   move      Temp6A        Temp6N
     C                   if        AIDecPos = 0
     C                   eval      $PValue1 = Temp6N
     C                   else
     C                   eval      $PValue1 = Temp6N
     C     1             do        AIDecPos
     C                   eval      $PValue1 = $PValue1 / 10
     C                   enddo
     C                   endif
740cA /free
740cA        $bcPNtLb = $pvalue1;
740cA
740cA        // Get UCI override
740cA
740aA        zzzgetlbs();
740cA
740cA        // Convert to Kilos
740cA
740cA        $bcPNtkg = ConvertLb2Kg($bcPNtLb: AIDecPos);
740cA
740cA        // Send back requested value
740cA
740cA        if IMkilolbs = 'K';
740cA          $pvalue1 = $bcPNtkg;
740cA        else;
740cA          $pvalue1 = $bcPNtlb;
740cA        endif;
740cA /end-free
640bA *      load new parameter
740cDc**                 if        $bcPNtLbSent
740cDc**                 eval      $bcPNtLb    = $pvalue1
740cDc**                 else
740cDc**                 eval      $bcPNtLb    = 0
740cDc**                 endif
740cA *
700aA ******** kgs weight uom conversion
740cDc**                 if        $pcmd = '*ALL    '
700aA *      now convert it to kgs if item options weight uom = kgs
740cDC**                 if        IMkilolbs = 'K'
740cDC**                 select
740cDC**                 when      AIDecPos = 0
740cDC**                 eval(h)   kilos110 = $pValue1 / kgs2lbs
740cDC**                 eval      $pValue1 = kilos110
740cDC**                 when      AIDecPos = 1
740cDC**                 eval(h)   kilos111 = $pValue1 / kgs2lbs
740cDC**                 eval      $pValue1 = kilos111
740cDC**                 when      AIDecPos = 2
740cDC**                 eval(h)   kilos112 = $pValue1 / kgs2lbs
740cDC**                 eval      $pValue1 = kilos112
740cDC**                 other
740cDC**                 eval(h)   kilos113 = $pValue1 / kgs2lbs
740cDC**                 eval      $pValue1 = kilos113
740cDC**                 endsl
700aAC*
700aA *      load new parameter
740cDc**                 if        $bcPNtlbSent
740cDc**                 eval      $bcPNtkgSent = *on
740eDc**                 eval      $bcPNtkg    = $pvalue1
740cDc**                 else
740cDc**                 eval      $bcPntkg    = 0
740cDc**                 eval      $bcPNtkgSent = *off
740cDc**                 endif
740cDc**                 endif
740cDc**                 endif
740cD /free
740cD   //exsr zzzgetlbs;
740cD /end-free

640bAC*    91 - Internal Company Codes
640bAC*
640bAC                   when      AICode = 91
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcAi91Sent = *on
640bAc                   endif
640bAC                   eval      AICodeLen = 30
640cDC**                 if        (BarPos + AICodeLen - 1) > BarCodeLen
640cDC**                 eval      AICodeLen = BarCodeLen - BarPos + 1
640cDC**                 endif
640bAC                   eval      $PValueTyp = 2
640cAC                   exsr      BarGetVarLen
640cAC                   eval      AICodeLen = %len(%trim($pvalue2))
640cDC**                 eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
640bA *      load new parameter
640bAc                   if        $bcAi91Sent
640bAc                   eval      $bcAi91    = $pvalue2
640bAc                   else
640bAc                   eval      $bcAi91    = ' '
640bAc                   endif
640bAC*    92 - Internal Company Codes
640bAC*
640bAC                   when      AICode = 92
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcAi92Sent = *on
640bAc                   endif
640bAC                   eval      AICodeLen = 30
640cDC**                 if        (BarPos + AICodeLen - 1) > BarCodeLen
640cDC**                 eval      AICodeLen = BarCodeLen - BarPos + 1
640cDC**                 endif
640bAC                   eval      $PValueTyp = 2
640cAC                   exsr      BarGetVarLen
640cAC                   eval      AICodeLen = %len(%trim($pvalue2))
640cDC**                 eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
640bA *      load new parameter
640bAc                   if        $bcAi92Sent
640bAc                   eval      $bcAi92    = $pvalue2
640bAc                   else
640bAc                   eval      $bcAi92    = ' '
640bAc                   endif
640bAC*    93 - Internal Company Codes
640bAC*
640bAC                   when      AICode = 93
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcAi93Sent = *on
640bAc                   endif
640bAC                   eval      AICodeLen = 30
640cDC**                 if        (BarPos + AICodeLen - 1) > BarCodeLen
640cDC**                 eval      AICodeLen = BarCodeLen - BarPos + 1
640cDC**                 endif
640bAC                   eval      $PValueTyp = 2
640cAC                   exsr      BarGetVarLen
640cAC                   eval      AICodeLen = %len(%trim($pvalue2))
640cDC**                 eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
640bA *      load new parameter
640bAc                   if        $bcAi93Sent
640bAc                   eval      $bcAi93    = $pvalue2
640bAc                   else
640bAc                   eval      $bcAi93    = ' '
640bAc                   endif
640bAC*    94 - Internal Company Codes
640bAC*
640bAC                   when      AICode = 94
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcAi94Sent = *on
640bAc                   endif
640bAC                   eval      AICodeLen = 30
640cDC**                 if        (BarPos + AICodeLen - 1) > BarCodeLen
640cDC**                 eval      AICodeLen = BarCodeLen - BarPos + 1
640cDC**                 endif
640bAC                   eval      $PValueTyp = 2
640cAC                   exsr      BarGetVarLen
640cAC                   eval      AICodeLen = %len(%trim($pvalue2))
640cDC**                 eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
640bA *      load new parameter
640bac                   if        $bcAi94Sent
640bAc                   eval      $bcAi94    = $pvalue2
640bAc                   else
640bAc                   eval      $bcAi94    = ' '
640bAc                   endif
640bAC*    95 - Internal Company Codes
640bAC*
640bAC                   when      AICode = 95
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcAi95Sent = *on
640bAc                   endif
640bAC                   eval      AICodeLen = 30
640cDC**                 if        (BarPos + AICodeLen - 1) > BarCodeLen
640cDC**                 eval      AICodeLen = BarCodeLen - BarPos + 1
640cDC**                 endif
640bAC                   eval      $PValueTyp = 2
640cAC                   exsr      BarGetVarLen
640cAC                   eval      AICodeLen = %len(%trim($pvalue2))
640cDC**                 eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
640bA *      load new parameter
640bAc                   if        $bcAi95Sent
640bAc                   eval      $bcAi95    = $pvalue2
640bAc                   else
640bAc                   eval      $bcAi95    = ' '
640bAc                   endif
640bAC*    96 - Internal Company Codes
640bAC*
640bAC                   when      AICode = 96
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcAi96Sent = *on
640bAc                   endif
640bAC                   eval      AICodeLen = 30
640cDC**                 if        (BarPos + AICodeLen - 1) > BarCodeLen
640cDC**                 eval      AICodeLen = BarCodeLen - BarPos + 1
640cDC**                 endif
640bAC                   eval      $PValueTyp = 2
640cAC                   exsr      BarGetVarLen
640cAC                   eval      AICodeLen = %len(%trim($pvalue2))
640cDC**                 eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
640bA *      load new parameter
640bAc                   if        $bcAi96Sent
640bAc                   eval      $bcAi96   = $pvalue2
640bAc                   else
640bAc                   eval      $bcAi96    = ' '
640bAc                   endif
640bAC*    97 - Internal Company Codes
640bAC*
640bAC                   when      AICode = 97
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcAi97Sent = *on
640bAc                   endif
640bAC                   eval      AICodeLen = 30
640cDC**                 if        (BarPos + AICodeLen - 1) > BarCodeLen
640cDC**                 eval      AICodeLen = BarCodeLen - BarPos + 1
640cDC**                 endif
640bAC                   eval      $PValueTyp = 2
640cAC                   exsr      BarGetVarLen
640cAC                   eval      AICodeLen = %len(%trim($pvalue2))
640cDC**                 eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
640bA *      load new parameter
640bAc                   if        $bcAi97Sent
640bAc                   eval      $bcAi97    = $pvalue2
640bAc                   else
640bAc                   eval      $bcAi97    = ' '
640bAc                   endif
640bAC*    98 - Internal Company Codes
640bAC*
640bAC                   when      AICode = 98
740gAc** If the mfg barcode includes ai code 01 and ai code 98
740gAc** we will treat the 98 as informational only because it would
740gAc** be internal for the manufacturer.
740gAc** Otherwise we are going to treat our internal ai code 98
740gAc** as a GTIN.
740gAc                   if        $bcgtinsent
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcAi98Sent = *on
640bAc                   endif
640bAC                   eval      AICodeLen = 30
640cDC**                 if        (BarPos + AICodeLen - 1) > BarCodeLen
640cDC**                 eval      AICodeLen = BarCodeLen - BarPos + 1
640cDC**                 endif
640bAC                   eval      $PValueTyp = 2
640cAC                   exsr      BarGetVarLen
640cAC                   eval      AICodeLen = %len(%trim($pvalue2))
640cDC**                 eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
640bA *      load new parameter
640bAc                   if        $bcAi98Sent
640bAc                   eval      $bcAi98    = $pvalue2
640bAc                   else
640bAc                   eval      $bcAi98    = ' '
640bAc                   endif
740gAc                   else
740gAc                   if        $PCmd = '*ALL    '
740gAc                   eval      $bcGtinSent = *off
740gAc                   eval      $bcAi98Sent = *on
740gAc                   endif
740gAC                   eval      AICodeLen = 14
740gAC                   eval      $PValueTyp = 2
740gAC                   eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
740gAC                   if        AICodeLen <> %Len(%Trim($PValue2))
740gAC                   eval      Error = *ON
740gAC                   eval      $PReturn = '*INVALID'
740gAC                   eval      $PAIPos = BarPos
740gAC                   eval      $PErrMsg = 'Invalid SCC-14 code found '
740gAC                                        + 'at positon '
740gAC                                        + %Trim(%EditC($PAIPos:'Z'))
740gAC                   Goto      EndGetVal
740gAC                   endif

740gAC                   exsr      ChkMod10
740gAc                   if        $PCmd = '*ALL    '
740gAc                             and error = *off
740gAc                   eval      $bcGtinSent = *on
740gAc                   endif
740gAC     Error         CabEq     *On           EndGetVal
740gA *      load new parameter
740gAc                   if        $bcGtinSent
740gAc                   eval      $bcGtin = $pvalue2
740gAc                   else
740gAc                   eval      $bcGtin = ' '
740gAc                   endif
740gAc                   if        $bcAi98Sent
740gAc                   eval      $bcAi98    = $pvalue2
740gAc                   else
740gAc                   eval      $bcAi98    = ' '
740gAc                   endif
740gAc                   endif
640bAC*    99 - Internal Company Codes
640bAC*
640bAC                   when      AICode = 99
640bAc                   if        $PCmd = '*ALL    '
640bAc                   eval      $bcAi99Sent = *on
640bAc                   endif
MQSaAc                   if        client = marques
MQSaAc                   eval      MqsEnd = %scan('¦': $PBarCode: barpos)
MQSaAc                   if        MqsEnd > 0
MQSaAC                   eval      AICodeLen = MqsEnd - barpos
MQSaAc                   else
MQSaAC                   eval      AICodeLen = 30
MQSaAc                   endif
MQSaAc                   else
640bAC                   eval      AICodeLen = 30
MQSaAc                   endif
640cDC**                 if        (BarPos + AICodeLen - 1) > BarCodeLen
640cDC**                 eval      AICodeLen = BarCodeLen - BarPos + 1
640cDC**                 endif
640bAC                   eval      $PValueTyp = 2
640cAC                   exsr      BarGetVarLen
640cAC                   eval      AICodeLen = %len(%trim($pvalue2))
640cDC**                 eval      $PValue2 = %Subst($PBarCode:BarPos:AICodeLen)
640bA *      load new parameter
640bAc                   if        $bcAi99Sent
640bAc                   eval      $bcAi99    = $pvalue2
640bAc                   else
640bAc                   eval      $bcAi99    = ' '
640bAc                   endif

     C                   endsl

     C                   eval      BarPos = BarPos + AICodeLen
415bDC**                 endsr
415bMC     EndGetVal     endsr

640cAC*----------------------------------------------------------------
640cAC*  BarGetVarLen - Get variable length value
640cAC*
640cAC     BarGetVarLen  begsr
      /free

         $PValue2 = ' ';
         startPos = BarPos;
         endPos = BarPos + AICodeLen - 1;
         if endPos > BarCodeLen;
           endPos = BarCodeLen;
         endif;

         // Whip through each character, up to the max length for code.

         for i = startPos to endPos;

           // Extract character

           temp1a = %Subst($PBarCode: i: 1);

           // See if it is an FNC1 character.
           // If it is, we are done, so get out.

           exsr ChkFNC1;
           if fnc1Char;
             leave;
           endif;

           // Otherwise, add character to value field.

           $PValue2 = %trimr($PValue2) + temp1a;

         endfor;

      /end-free
     C                   endsr

640cAC*----------------------------------------------------------------
640cAC*  ChkFNC1   Check for GS1-128 FNC1 (end-of-field) character
640cAC*
640cAC*    The FNC1 character is the ASCII 29 (Hex 1D) character.
640cAC*    It is up to the scanner on what it passes to the workstation.
640cAC*    Some scanners strip it out and don't send it at all.
640cAC*    Ideally, we want the scanner to translate that character into
640cAC*    a displayable character, like '~' or a space.
650bAC*    NO longer consider a space the end of a variable field.
640cAC*
640cAC*    This routine will look for a variety of FNC1 characters, even
640cAC*    '<0x1D>', which we saw one scanner send. If we find a '<'
640cAC*    character, we will assume it is the beginning of '<0x1D>'.
640cAC*
640cAC*    Variable temp1a must contain character being checked.
640cAC*    fnc1Len will contain the length of the FNC1 string found.
640cAC*
640cAC     ChkFNC1       begsr
      /free

         fnc1Char = *off;

         select;

650bD      //when temp1a = ' '
650bD      //  or temp1a = '~'
650bM      when temp1a = '~'
             or temp1a = fnc1Hex1D;
               fnc1Char = *on;
               fnc1Len = 1;

           when temp1a = '<';
             fnc1Char = *on;
             fnc1Len = 6;

MQSaA      when temp1a = '¦';
MQSaA        fnc1Char = *on;
MQSaA        fnc1Len = 1;

         endsl;

      /end-free
     C                   endsr

415bAC*----------------------------------------------------------------
415bAC*  ChkMod10   -  Check barcode Modulo-10 check digit.
415bAC*
520aAC*    Revised to work with 18-digit number instead of just 14 digits.
520aAC*
415bAC     ChkMod10      begsr
     C
500 A
500 A * Skip Mod10 check for non-upc commands.
500 A
500 AC                   if        $PCmd = '*CWGTLBS'
500 AC                             or $PCmd = '*EXPDT'
500 AC                             or $PCmd = '*PKGDT'
500 AC                             or $PCmd = '*PRODDT'
500 AC                             or $PCmd = '*SELLBY'
500 AC                   goto      endchk10
500 AC                   endif
500 A
     C* Move barcode into numeric array.

415cDC**                 evalr     Temp14A = %TrimR($PValue2)
415cAC                   movel     $PValue2      $CSTR
415cAC                   call      'ADJUST'
415cAC                   parm      '*RIGHT  '    $CCMD             8
415cAC                   parm                    $CSTR            30
415cAC*****              move      $CSTR         Temp14A
     C*****              movea     Temp14A       A14
520aMC                   move      $CSTR         Temp18A
520aMC                   movea     Temp18A       A18

415dAC* Zero fill array.

415dAC                   eval      i = 1
415dAC*****              dou       i > 14
415dAC*****              if        A14(i) <> *Blank
520aAC                   dou       i > 18
520aMC                   if        A18(i) <> *Blank
415dAC                   leave
415dAC                   endif
415dAC*****              eval      A14(i) = '0'
520aMC                   eval      A18(i) = '0'
415dAC                   eval      i = i + 1
415dAC                   enddo

415dAC* Make sure barcode only contains numbers.

415dAC                   eval      i = 1
415dAC*****              dou       i > 14
415dAC*****              eval      AINumb = %Scan(A14(i):Numbers)
520aMC                   dou       i > 18
520aMC                   eval      AINumb = %Scan(A18(i):Numbers)
415dAC                   if        AINumb = 0
415dAC                   eval      Error = *ON
415dAC                   eval      $PReturn = '*INVALID'
415dAC                   eval      $PErrMsg = 'Non-numeric character found'
415dAC                   Goto      EndChk10
415dAC                   endif
415dAC                   eval      i = i + 1
415dAC                   enddo

520aDC* Starting in position 13 and working backwards ...
520aDC*   add every other position together.
520aMC* Starting in position 17 and working backwards ...
     C*   add every other position together.

520aDC*****              eval      i = 13
520aMC                   eval      i = 17
     C                   eval      DigitSum = 0

     C                   dou       i < 0
520aDC*****              eval      Temp1A = A14(i)
520aMC                   eval      Temp1A = A18(i)
     C                   move      Temp1A        Temp1N
     C                   eval      DigitSum = DigitSum + Temp1N
     C                   eval      i = i - 2
     C                   enddo

     C* Multiply above sum by 3.

     C                   eval      DigitSum = DigitSum * 3

520aDC* Starting in position 12 and working backwards ...
520aDC*   add every other position to above sum.
520aMC* Starting in position 16 and working backwards ...
     C*   add every other position to above sum.

520aDC*****              eval      i = 12
520aMC                   eval      i = 16
     C                   dou       i = 0
520aDC*****              eval      Temp1A = A14(i)
520aMC                   eval      Temp1A = A18(i)
     C                   move      Temp1A        Temp1N
     C                   eval      DigitSum = DigitSum + Temp1N
     C                   eval      i = i - 2
     C                   enddo

     C* To get check digit ...
     C*   Divide sum by 10, take remainder and subtract from 10

     C*   Note: The statement 'CheckDigit = 10 - CheckRem' caused a
     C*         'target ... to small' error, thus the need for the
     C*         verbose 'if' statment.

415cDC**                 eval      CheckRem = %Rem(DigitSum:10)
415cAC     DigitSum      Div       10            DigitDiv
415cAC                   Mvr                     CheckRem
     C                   if        CheckRem = 0
     C                   eval      CheckDigit = 0
     C                   else
     C                   eval      CheckDigit = 10 - CheckRem
     C                   endif

     C* See if we have a match ...

520aDC*****              eval      Temp1A = A14(14)
520aMC                   eval      Temp1A = A18(18)
     C                   move      Temp1A        Temp1N
     C                   if        CheckDigit <> Temp1N
     C                   move      CheckDigit    CheckDigitA
     C                   eval      CheckDigitA2 = Temp1A
     C                   eval      Error = *ON
740bDC*                  eval      $PReturn = '*INVALID'
740bMC                   eval      $PReturn = '*UPCWARN'
     C                   eval      $PAIPos = BarPos
     C                   eval      $PErrMsg = 'Check digit error ('
     C                                        + CheckDigitA + ' vs '
     C                                        + CheckDigitA2 + ')'
     C                   endif

415dDC**                 endsr
415dMC     EndChk10      endsr
640aAC*----------------------------------------------------------------
640aAC*  ChkNbr     -  Check data is numeric.
640aAC*
640aAC     ChkNbr        begsr
640aAC
640aAC                   eval      i = 1
640aAC                   dou       i > AICodeLen
640aMC                   eval      AINumb = %Scan(A18(i):Numbers)
640aAC                   if        AINumb = 0
640aAC                   eval      Error = *ON
640aAC                   eval      $PReturn = '*INVALID'
640aAC                   eval      $PErrMsg = 'Non-numeric character found'
640aAC                   leave
640aAC                   endif
640aAC                   eval      i = i + 1
640aAC                   enddo

640aA
640aAC     EndChkNb      endsr
640bAC*----------------------------------------------------------------
640bAC*  CmdAll      Get All information
640bAC*
640bAC     CmdAll        begsr
640bAC                   exsr      CmdFirst
700bAc                   if        error = *on
740dA /free
740dA   if $bcPntLb = 0;
740dA     zzzgetlbs();
740dA     if $bcpntlb > 0;
740dA       $cvtdata = $barcode;
740dA       $cvtdata2 = $barcode2;
740dA     endif;
740dA   endif;
740dA /end-free
700bAc                   leavesr
700bAc                   endif
640bAc                   dow       forever = forever
640bAC                   exsr      CmdNext
640bAc                   if        $PReturn = '*NOMORE' or
640bAc                             $PReturn = '*INVALID'
640bAc                   leave
640bAc                   endif
640bAc                   enddo
740dA /free
740dA   if $bcPntLb = 0;
740dA     zzzgetlbs();
740dA   endif;
740dA /end-free
640bAc                   eval      $cvtdata = $barcode
640bAc                   eval      $cvtdata2 = $barcode2
640bAC                   endsr
     C*----------------------------------------------------------------
     C*  CmdExpDt    Get expiration date
     C*
     C     CmdExpDt      begsr
     C*
     C*  Determine what was sent.
     C*
     C                   select
     C*
     C*    If barcode length is 6
     C*      Then assume the actual date was sent using YYMMDD form.
     C*
     C     BarCodeLen    wheneq    6
     C                   eval      $PValueTyp = 1
     C                   eval      Temp6A = %Subst($PBarCode:1:6)
640dAC*
640dAC*      Check value is numeric.
640dAC                   movea     Temp6a        A18
640dAC                   exsr      ChkNbr
640dAC                   if        Error = *ON
640dAC                   eval      $PAIPos = i
640dAC                   Goto      EndExpDt
640dAC                   endif
640dAC*
     C                   move      Temp6A        Temp6N
     C                   eval      $PValue1 = Temp6N
     C                   eval      $PAIDesc = 'Date Only'
     C*
     C*    If barcode length is greater than 6
     C*      Then assume standard product id barcode and look for id 17.
     C*
     C                   other
     C                   eval      $PReturn = '*NOTFND'
     C                   eval      BarPos = 1
     C     Forever       doweq     Forever
     C                   exsr      BarGetCod
     C     Error         cabeq     *ON           EndExpDt
     C                   exsr      BarGetVal
     C     Error         cabeq     *ON           EndExpDt
     C     AICode        ifeq      17
     C                   eval      $PReturn = '*OK'
     C                   leave
     C                   endif
     C                   enddo
     C*
     C                   endsl
     C*
     C     EndExpDt      endsr
     C*----------------------------------------------------------------
     C*  CmdFirst -  Get first code in barcode
     C*
     C     CmdFirst      begsr
     C*
     C*  Initialize variables
     C*
     C                   eval      BarPos = 1
     C*
     C*  Get code
     C*
     C                   exsr      BarGetCod
     C     Error         cabeq     *ON           EndFirst
     C*
     C*  Get value
     C*
     C                   exsr      BarGetVal
     C     Error         cabeq     *ON           EndFirst
     C*
     C     EndFirst      endsr
     C*----------------------------------------------------------------
     C*  CmdNext  -  Get next code in barcode
     C*
     C     CmdNext       begsr
     C*
     C*  Get code
     C*
     C                   exsr      BarGetCod
     C     Error         cabeq     *ON           EndNext
     C*
     C*  Get value
     C*
     C                   exsr      BarGetVal
     C     Error         cabeq     *ON           EndNext
     C*
     C     EndNext       endsr
     C*----------------------------------------------------------------
     C*  CmdPkgDt    Get packaged date
     C*
     C     CmdPkgDt      begsr
     C*
     C*  Determine what was sent.
     C*
     C                   select
     C*
     C*    If barcode length is 6
     C*      Then assume the actual date was sent using YYMMDD form.
     C*
     C     BarCodeLen    wheneq    6
     C                   eval      $PValueTyp = 1
     C                   eval      Temp6A = %Subst($PBarCode:1:6)
640dAC*
640dAC*      Check value is numeric.
640dAC                   movea     Temp6a        A18
640dAC                   exsr      ChkNbr
640dAC                   if        Error = *ON
640dAC                   eval      $PAIPos = i
640dAC                   Goto      EndPkgDt
640dAC                   endif
640dAC*
     C                   move      Temp6A        Temp6N
     C                   eval      $PValue1 = Temp6N
     C                   eval      $PAIDesc = 'Date Only'
     C*
     C*    If barcode length is greater than 6
     C*      Then assume standard product id barcode and look for id 13.
     C*
     C                   other
     C                   eval      $PReturn = '*NOTFND'
     C                   eval      BarPos = 1
     C     Forever       doweq     Forever
     C                   exsr      BarGetCod
     C     Error         cabeq     *ON           EndPkgDt
     C                   exsr      BarGetVal
     C     Error         cabeq     *ON           EndPkgDt
     C     AICode        ifeq      13
     C                   eval      $PReturn = '*OK'
     C                   leave
     C                   endif
     C                   enddo
     C*
     C                   endsl
     C*
     C     EndPkgDt      endsr
     C*----------------------------------------------------------------
     C*  CmdProdDt   Get production date
     C*
     C     CmdProdDt     begsr
     C*
     C*  Determine what was sent.
     C*
     C                   select
     C*
     C*    If barcode length is 6
     C*      Then assume the actual date was sent using YYMMDD form.
     C*
     C     BarCodeLen    wheneq    6
     C                   eval      $PValueTyp = 1
     C                   eval      Temp6A = %Subst($PBarCode:1:6)
640dAC*
640dAC*      Check value is numeric.
640dAC                   movea     Temp6a        A18
640dAC                   exsr      ChkNbr
640dAC                   if        Error = *ON
640dAC                   eval      $PAIPos = i
640dAC                   Goto      EndProdDt
640dAC                   endif
640dAC*
     C                   move      Temp6A        Temp6N
     C                   eval      $PValue1 = Temp6N
     C                   eval      $PAIDesc = 'Date Only'
     C*
     C*    If barcode length is greater than 6
     C*      Then assume standard product id barcode and look for id 11.
     C*
     C                   other
     C                   eval      $PReturn = '*NOTFND'
     C                   eval      BarPos = 1
     C     Forever       doweq     Forever
     C                   exsr      BarGetCod
     C     Error         cabeq     *ON           EndProdDt
     C                   exsr      BarGetVal
     C     Error         cabeq     *ON           EndProdDt
     C     AICode        ifeq      11
     C                   eval      $PReturn = '*OK'
     C                   leave
     C                   endif
     C                   enddo
     C*
     C                   endsl
     C*
     C     EndProdDt     endsr
     C*----------------------------------------------------------------
     C*  CmdSCC14    Get SCC-14 code
     C*
     C     CmdSCC14      begsr
     C*
     C*  Search for code 01 (SCC-14)
     C*
     C                   eval      $PReturn = '*NOTFND'
     C                   eval      BarPos = 1
     C     Forever       doweq     Forever
     C                   exsr      BarGetCod
     C     Error         cabeq     *ON           EndSCC14
     C                   exsr      BarGetVal
     C     Error         cabeq     *ON           EndSCC14
     C     AICode        ifeq      1
730aAC     AICode        oreq      2
     C                   eval      $PReturn = '*OK'
     C                   leave
     C                   endif
     C                   enddo
     C*
     C     EndSCC14      endsr
     C*----------------------------------------------------------------
     C*  CmdSellBy   Get sell by date
     C*
     C     CmdSellBy     begsr
     C*
     C*  Determine what was sent.
     C*
     C                   select
     C*
     C*    If barcode length is 6
     C*      Then assume the actual date was sent using YYMMDD form.
     C*
     C     BarCodeLen    wheneq    6
     C                   eval      $PValueTyp = 1
     C                   eval      Temp6A = %Subst($PBarCode:1:6)
640dAC*
640dAC*      Check value is numeric.
640dAC                   movea     Temp6a        A18
640dAC                   exsr      ChkNbr
640dAC                   if        Error = *ON
640dAC                   eval      $PAIPos = i
640dAC                   Goto      EndSellBy
640dAC                   endif
640dAC*
     C                   move      Temp6A        Temp6N
     C                   eval      $PValue1 = Temp6N
     C                   eval      $PAIDesc = 'Date Only'
     C*
     C*    If barcode length is greater than 6
     C*      Then assume standard product id barcode and look for id 15.
     C*
     C                   other
     C                   eval      $PReturn = '*NOTFND'
     C                   eval      BarPos = 1
     C     Forever       doweq     Forever
     C                   exsr      BarGetCod
     C     Error         cabeq     *ON           EndSellBy
     C                   exsr      BarGetVal
     C     Error         cabeq     *ON           EndSellBy
     C     AICode        ifeq      15
     C                   eval      $PReturn = '*OK'
     C                   leave
     C                   endif
     C                   enddo
     C*
     C                   endsl
     C*
     C     EndSellBy     endsr
     C*----------------------------------------------------------------
     C*  CmdSSCC18   Get SSCC-18 code
     C*
     C     CmdSSCC18     begsr
     C*
     C*  Search for code 00 (SSCC-18)
     C*
     C                   eval      $PReturn = '*NOTFND'
     C                   eval      BarPos = 1
     C     Forever       doweq     Forever
     C                   exsr      BarGetCod
     C     Error         cabeq     *ON           EndSSCC18
     C                   exsr      BarGetVal
     C     Error         cabeq     *ON           EndSSCC18
     C     AICode        ifeq      0
     C                   eval      $PReturn = '*OK'
     C                   leave
     C                   endif
     C                   enddo
     C*
     C     EndSSCC18     endsr
     C*----------------------------------------------------------------
     C*  CmdUpc      Get UPC code
     C*
     C*    Note: UPC is used genericly. The code can be one of the
     C*          following: UPC-12, EAN-13, SCC-14 or SSCC-18.
     C*
     C     CmdUpc        begsr
     C*
     C*  Determine what was sent.
     C*
BADb c                   eval      TFWO = %Scan(TFWOCHK:$PBarCode)
     C                   select
     C*
     C*    If barcode length is 12
     C*      Then assume a standard UPC-12 code was scanned.
     C*
     C     BarCodeLen    wheneq    12
     C                   eval      $PValueTyp = 2
     C                   eval      $PValue2 = $PBarCode
     C                   eval      $PAIDesc = 'UPC-12'

415bAC                   exsr      ChkMod10
SVLaAC*
SVLaAC*    If barcode length is 13
SVLaAC*      and starts with 99 and Saval
SVLaAC*      Then assume special Saval EAN-13 code was scanned
SVLaAC*           where positions 3-7 are extracted for UPC code.
SVLaAC*
SVLaAC                   when      BarCodeLen = 13
SVLaAC                             and %subst(%trim($PBarCode):1:2) = '99'
SVLaAC                             and client = saval
SVLaAC                   eval      $PValueTyp = 2
SVLaAC                   eval      $PValue2 = %trim($PBarCode)
SVLaAC                   eval      $PAIDesc = 'Saval EAN-13'
SVLaA
SVLaAC                   exsr      ChkMod10
SVLaAC                   eval      $PValue2 = %subst(%trim($PBarCode):3:5)
BADaAC*
BADaAC*    If pos 7-8 are WO treat as taylor farms format
BADaAC*      upc is in pos 1-6  and Big Apple
BADaAC*      Then assume special Big Apple - Taylor farms was scanned
BADaAC*           where positions 1-6 are extracted for UPC code.
BADaAC*
BADaAC                   when      BarCodeLen > 7  and
BADbAc                             tfwo > 0
BADbDC*                            %subst(%trim($PBarCode):7:2) = 'WO'
BADaAC                             and client = BIGAPPLE
BADaAC                   eval      $PValueTyp = 2
BADaAC                   eval      $PValue2 = %trim($PBarCode)
BADaAC                   eval      $PAIDesc = 'Big Apple-TF'
BADaA
BADbAc                   eval      TFend = TFWO - 1
BADbDC*                  eval      $PValue2 = %subst(%trim($PBarCode):1:6)
BADbMC                   eval      $PValue2 = %subst(%trim($PBarCode):1:TFEND)
     C*
     C*    If barcode length is 13
     C*      Then assume a standard EAN-13 code was scanned.
     C*
     C     BarCodeLen    wheneq    13
     C                   eval      $PValueTyp = 2
     C                   eval      $PValue2 = $PBarCode
     C                   eval      $PAIDesc = 'EAN-13'

415bAC                   exsr      ChkMod10

415aAC*
415aAC*    If barcode length is 14
415aAC*      Then assume a standard SCC-14 code was scanned.
415aAC*
415aAC     BarCodeLen    wheneq    14
415aAC                   eval      $PValueTyp = 2
415aAC                   eval      $PValue2 = $PBarCode
415aAC                   eval      $PAIDesc = 'SCC-14'

415bAC                   exsr      ChkMod10
     C*
     C*    If barcode length is not 12 or 13
     C*      Then assume standard product id barcode and look for
     C*           id 00 (SSCC-18) or 01 (SCC-14).
     C*
     C                   other
     C                   eval      $PReturn = '*NOTFND'
     C                   eval      BarPos = 1
     C     Forever       doweq     Forever
     C                   exsr      BarGetCod
417 AC     BarCodeLen    ifle      20
417 AC     $PReturn      andeq     '*INVALID'
417 AC                   eval      $PValue2 = $PBarCode
417 AC                   eval      $PReturn = '*UPCWARN'
417 AC                   endif
     C     Error         cabeq     *ON           EndUpc
     C                   exsr      BarGetVal
     C     Error         cabeq     *ON           EndUpc
     C     AICode        ifeq      0
     C     AICode        oreq      1
730aAC     AICode        oreq      2
     C                   eval      $PReturn = '*OK'
     C                   leave
     C                   endif
     C                   enddo
     C*
     C                   endsl
     C*
     C     EndUpc        endsr
417a C*----------------------------------------------------------------
417a C*  CmdVfyLp7   Verify License is only 7 long.
417a C*
417a C     CmdVfyLp7     begsr
417a C*
417a C*  If barcode is > 7, return error
417a C*
417a C     BarCodeLen    ifgt      7
417a C                   eval      Error = *ON
417a C                   eval      $PReturn = '*INVALID'
417a C                   endif
417a C*
417a C     EndVfyLp7     endsr
     C*----------------------------------------------------------------
     C*  CmdWgtLbs   Get catchweight
     C*
510 AC*  Routine re-written. Original routine copied to XXXWgtLbs
     C*
     C     CmdWgtLbs     begsr
     C                   eval      $PReturn = '*NOTFND'
510cA
510cAC*  First, check for special cases by client/Mfr
510cA
510cAC                   eval      MfrWgtRtn = ' '
740cDC**                 exsr      MfrWgt
740cA /free
740cA                    MfrWgt();
740cA /end-free
510cAC                   if        MfrWgtRtn = '*OK'
510cAC                             or MfrWgtRtn = '*ERROR'
510cAC                   goto      EndWgt
510cAC                   endif
     C*
     C*    Then assume standard product id barcode and look
     C*      for code 310 (kgs) or 320 (lbs)
     C*
     C*    First look for code 320 (Net Weight, Pounds)
     C*
     C                   eval      BarPos = 1
     C     Forever       doweq     Forever
     C                   exsr      BarGetCod
     C     Error         cabeq     *ON           EndWgt
     C                   exsr      BarGetVal
     C     Error         cabeq     *ON           EndWgt
     C                   if        AICode = 310 or AICode = 320
     C                   eval      $PReturn = '*OK'
     C                   leave
     C                   endif
     C                   enddo
700aAc*
700aAc*    if client stores kilograms, and pounds found convert to kilograms
700aAc                   select
750aAc                   when      $PCmd =  '*CWGTLBS'
750aAc**** it's already converted on this command if you go thru here
750aAc**** it will double the weight.
700aAC                   when      IMkilolbs = 'K'
700aAC*
700aAC*    If pounds found, convert into kilograms.
700aAC*
700aAC                   if        AICode = 320
700aAC                   eval      $PAICode = TCOD(10)
700aAC                   eval      $PAIDesc = TDSC(10)
700aAC                   select
700aAC                   when      AIDecPos = 0
700aAC                   eval(h)   kilos110 = $pValue1 / kgs2lbs
700aAC                   eval      $pValue1 = kilos110
700aAC                   when      AIDecPos = 1
700aAC                   eval(h)   kilos111 = $pValue1 / kgs2lbs
700aAC                   eval      $pValue1 = kilos111
700aAC                   when      AIDecPos = 2
700aAC                   eval(h)   kilos112 = $pValue1 / kgs2lbs
700aAC                   eval      $pValue1 = kilos112
700aAC                   other
700aAC                   eval(h)   kilos113 = $pValue1 / kgs2lbs
700aAC                   eval      $pValue1 = kilos113
700aAC                   endsl
700aAc                   endif
700aAc                   other
     C*
     C*    If kilograms found, convert into pounds.
     C*
     C                   if        AICode = 310
     C                   eval      $PAICode = TCOD(10)
     C                   eval      $PAIDesc = TDSC(10)
     C                   select
     C                   when      AIDecPos = 0
     C                   eval(h)   pounds110 = $pValue1 * kgs2lbs
     C                   eval      $pValue1 = pounds110
     C                   when      AIDecPos = 1
     C                   eval(h)   pounds111 = $pValue1 * kgs2lbs
     C                   eval      $pValue1 = pounds111
     C                   when      AIDecPos = 2
     C                   eval(h)   pounds112 = $pValue1 * kgs2lbs
     C                   eval      $pValue1 = pounds112
     C                   other
     C                   eval(h)   pounds113 = $pValue1 * kgs2lbs
     C                   eval      $pValue1 = pounds113
     C                   endsl
WSTcAC*
WSTcAC*       For Westside, round converted pounds up/down to interger.
WSTcAC*         Note: .01 has to be subtracted because Westside wants
WSTcAC*               to round up starting at .51, but %inth rounds
WSTcAC*               up starting at .50.
WSTcAC*
WSTeAC                   if        client = westside
740fDc**                 if        $PVen# <> 113390
740fMc                   if        pVen# <> 113390
WSTgAC                   eval      $pValue1 *= 10
WSTeAC                   eval      $pValue1 = %inth($pvalue1 - .01)
WSTgAC                   eval      $pValue1 /= 10
WSTlAc                   endif
WSTeAC                   endif
     C*
     C                   endif
700aAc                   endsl
     C*
     C     EndWgt        endsr
     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

740aAC                   select
740aAC                   when      $dricommand = '*UCIINFO'
740aAC                   eval      $dridata = $uciinfo
740aAC                   eval      $dridata2 = $uciinfo2
740aAC                   endsl
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
740aDC*    $item         parm      $item         $dridata
740aDC*    $item2        parm      $item2        $dridata2
740aMC                   parm                    $dridata
740aMC                   parm                    $dridata2

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   endsl
740aAC                   select
740aAC                   when      $dricommand = '*UCIINFO'
740aAC                   eval      $uciinfo = $dridata
740aAC                   eval      $uciinfo2 = $dridata2
740aAC                   endsl

     C     enddricop     endsr
     C*----------------------------------------------------------------
     C*  xxxWgtLbs   Get catchweight
     C*
     C*  **** Old CmdWgtLbs routine. Saved for reference. ***
     C*
     C     xxxWgtLbs     begsr
     C*
     C*  Determine what was sent.
     C*
     C                   select
     C*
     C*    If barcode length is less than 10
     C*      Then assume the actual weight was sent.
     C*
     C     BarCodeLen    whenlt    10
     C*
     C*      Right adjust number and strip decimal point (if any)
     C*
     C                   movel     $PBarCode     Temp9A
     C                   movea     Temp9A        A9
     C                   eval      FlagAdj = *OFF
     C                   eval      FlagDecPt = *OFF

     C                   eval      I = 10
     C                   eval      J = I - 1
     C                   eval      AIDecPos = 0

     C     Forever       doweq     forever
     C*
     C*         Check if we are out of characters
     C*
     C                   eval      I = I - 1
     C                   if        I = 0
     C                   leave
     C                   endif
     C*
     C*         See if we have found our first non-blank character
     C*
     C                   if        A9(I) = ' ' AND FlagAdj = *OFF
     C                   iter
     C                   endif
     C*
     C*         Character found, right adjust.
     C*
     C                   move      *ON           FlagAdj
     C*
     C*         Check for decimal point.
     C*
     C                   if        FlagDecPt = *OFF
     C                   if        A9(I) = '.'
     C                   eval      FlagDecPt = *On
     C                   eval      A9(I) = ' '
     C                   iter
     C                   else
     C                   eval      AIDecPos = AIDecPos + 1
     C                   endif
     C                   endif
     C*
     C*         Verify character is numeric.
     C*
     C                   eval      AINumb = %Scan(A9(I):Numbers)
     C                   if        AINumb = 0
     C                   eval      Error = *ON
     C                   eval      $PReturn = '*INVALID'
     C                   eval      $PAIPos = I
     C                   eval      $PErrMsg = 'Invalid character found at '
     C                                        + 'position '
     C                                        + %Trim(%EditC($PAIPos:'Z'))
     C                   goto      EndWgtx
     C                   endif
     C*
     C*         Move character to next right adjust position.
     C*
     C                   eval      A9(J) = A9(I)
     C                   eval      A9(I) = ' '
     C                   eval      J = J - 1

     C                   enddo
     C*
     C*      If decimal point not found, assume 2.
     C*
     C                   if        FlagDecPt = *OFF
     C                   eval      AIDecPos = 2
     C                   endif
     C*
     C*      Move weight into return parameter
     C*
     C                   movea     A9            Temp9A
     C                   move      Temp9A        Temp9N
     C                   eval      $PValueTyp = 1
     C                   if        AIDecPos = 0
     C                   eval      $PValue1 = Temp9N
     C                   else
     C                   eval      $PValue1 = Temp9N
     C     1             do        AIDecPos
     C                   eval      $PValue1 = $PValue1 / 10
     C                   enddo
     C                   endif
     C                   eval      $PAIDecPos = AIDecPos
     C                   eval      $PAIDesc = 'Weight Only'
     C*
     C*    If barcode length is greater than or equal to 10
     C*      Then assume standard product id barcode and look for id 320.
     C*
     C                   other
     C                   eval      $PReturn = '*NOTFND'
     C                   eval      BarPos = 1
     C     Forever       doweq     Forever
     C                   exsr      BarGetCod
     C     Error         cabeq     *ON           EndWgtx
     C                   exsr      BarGetVal
     C     Error         cabeq     *ON           EndWgtx
     C     AICode        ifeq      320
     C                   eval      $PReturn = '*OK'
     C                   leave
     C                   endif
     C                   enddo
     C*
     C                   endsl
     C*
     C     EndWgtx       endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZIMOPT  Get Item Maintenance option
700aA*
700aAC     zzimopt       begsr
700aA*
700aA*   Get UOM for weight.
700aA /free
700aA   getimuom($pwhse: IMkilolbs: IMUom);
700aA /end-free
700aA*
700aAC                   endsr

740cA*----------------------------------------------------------------
740cA*----------------------------------------------------------------
740cA*                      Sub Procedures
740cA*----------------------------------------------------------------
740cA*----------------------------------------------------------------

740cA*----------------------------------------------------------------
740cA*  CheckCustom    Check and process custom user-defined barcodes
740cA*----------------------------------------------------------------
740cA
740cAp CheckCustom     b
     d CheckCustom     pi              n

     *  Local Variables

     D def#            s              5p 0

      /free

       // If warehouse not sent, then we can't look up user-defined definition
       // Note, right now, defs are not tied to a warehouse.

       //if pWhse <= 0;
       //  leavesr;
       //endif;

       // Special case used for testing
       // If item number starts with 'DEF#'
       //   then using the following number as the def#.

       if %subst(pItem: 1: 4) = 'DEF#';
         def# = %dec(%trim(%subst(pItem:5)): 5: 0);
740eA    if debug;
740eA      debugMsg = 'Using Sent Def# ' + %char(def#);
740eA      WrtDebugMsg();
740eA    endif;
         $bcDef#Sent = *on;
         $bcDef# = 'D:' + %char(def#);
         ProcessDef(def#);
         return *on;
       endif;

       // See if definition exists for item

       def# = GetItemDef();
       if def# > 0;
740eA    if debug;
740eA      debugMsg = 'Using Item Override Def# ' + %char(def#);
740eA      WrtDebugMsg();
740eA    endif;
         ProcessDef(def#);
         return *on;
       endif;

       // See if definition exists for Mfr

       def# = GetMfrDef();
       if def# > 0;
740eA    if debug;
740eA      debugMsg = 'Using Mfr Def# ' + %char(def#);
740eA      WrtDebugMsg();
740eA    endif;
         ProcessDef(def#);
         return *on;
       endif;

       // Otherwise, do normal processing.

       return *off;

      /end-free

     p                 e

740ca*----------------------------------------------------------------
740cA*  ConvertLb2Kg   Convert Pounds to Kilos
740cA*----------------------------------------------------------------
740cA
740cAp ConvertLb2Kg    b
     d ConvertLb2Kg    pi            11s 3
     d   wgt                         11s 3
     d   decPos                       1p 0

     *  Local Variables

     D wgt2            s             11p 3

      /free

        select;
          when decPos = 0;
            eval(h) kilos110 = wgt / kgs2lbs;
            wgt2 = kilos110;
          when decPos = 1;
            eval(h) kilos111 = wgt / kgs2lbs;
            wgt2 = kilos111;
          when decPos = 2;
            eval(h) kilos112 = wgt / kgs2lbs;
            wgt2 = kilos112;
          other;
            eval(h)   kilos113 = wgt / kgs2lbs;
            wgt2 = kilos113;
        endsl;

        return wgt2;

      /end-free

     p                 e

740ca*----------------------------------------------------------------
740cA*  ConvertKg2Lb   Convert Kilos to Pounds
740cA*----------------------------------------------------------------
740cA
740cAp ConvertKg2Lb    b
     d ConvertKg2Lb    pi            11s 3
     d   wgt                         11s 3
     d   decPos                       1p 0

     *  Local Variables

     D wgt2            s             11p 3

      /free

        select;
          when decPos = 0;
            eval(h) pounds110 = wgt * kgs2lbs;
            wgt2 = pounds110;
          when decPos = 1;
            eval(h) pounds111 = wgt * kgs2lbs;
            wgt2 = pounds111;
          when decPos = 2;
            eval(h) pounds112 = wgt * kgs2lbs;
            wgt2 = pounds112;
          other;
            eval(h) pounds113 = wgt * kgs2lbs;
            wgt2 = pounds113;
        endsl;

640bA   // For Westside, round converted pounds up/down to interger.
640bA   // Note: .01 has to be subtracted because Westside wants
640bA   //       to round up starting at .51, but %inth rounds
640bA   //       up starting at .50.
640bA
640bA   if client = westside;
740fD     //if $PVen# <> 113390;
740fM     if pVen# <> 113390;
WSTgA       wgt2 *= 10;
640bA       wgt2 = %inth(wgt2 - .01);
WSTgA       wgt2 /= 10;
WSTlA     endif;
640bA   endif;

        return wgt2;

      /end-free

     p                 e

740ca*----------------------------------------------------------------
740cA*  VerifyDef     Verify definition
     *                This assumes Header information has been read
740cA*----------------------------------------------------------------
740cA
740cAp VerifyDef       b
     d VerifyDef       pi              n
     d  whse                          3s 0
     d  def#                          5p 0

     *  Local Variables

     D aiCode          s              3
     D count           s              5p 0
     D countInd        s              2b 0

      /free

       // Barcode length must meet minimum length needed

       if barCodeLen < bdhminlen;

740eA    if debug;
740eA      debugMsg = 'Rejected - Barcode length did not meet '
740eA               + 'minimum length needed;';
740eA      WrtDebugMsg();
740eA    endif;

         return *off;
       ENDIF;

       // Determine the AI code to look for.
       // Some GS1 codes are entered generically in the def program.
       // For example, the program doesn't distinguish between Production and Package dates.

       select;
         when $PCmd = '*ALL    ';
           return *on;

         when $PCmd = '*UPC'
           or $PCmd = '*SSCC-18'
           or $PCmd = '*SCC-14 ';
             if %subst(bdhaiflags: 1: 1) = '1';
               return *on;
             else;
740eA          if debug;
740eA            debugMsg = 'Rejected - Needed value not defined';
740eA            WrtDebugMsg();
740eA          endif;
               return *off;
             endif;

         when $PCmd = '*CWGTLBS';
             if %subst(bdhaiflags: 2: 1) = '1'
              or %subst(bdhaiflags: 3: 1) = '1';
                return *on;
             else;
740eA          if debug;
740eA            debugMsg = 'Rejected - Needed value not defined';
740eA            WrtDebugMsg();
740eA          endif;
               return *off;
             endif;

         when $PCmd = '*PRODDT '
           or $PCmd = '*PKGDT  ';
             if %subst(bdhaiflags: 4: 1) = '1';
               return *on;
             else;
740eA          if debug;
740eA            debugMsg = 'Rejected - Needed value not defined';
740eA            WrtDebugMsg();
740eA          endif;
               return *off;
             endif;

         when $PCmd = '*SELLBY ';
             if %subst(bdhaiflags: 5: 1) = '1';
               return *on;
             else;
740eA          if debug;
740eA            debugMsg = 'Rejected - Needed value not defined';
740eA            WrtDebugMsg();
740eA          endif;
               return *off;
             endif;

         when $PCmd = '*EXPDT  ';
             if %subst(bdhaiflags: 6: 1) = '1';
               return *on;
             else;
740eA          if debug;
740eA            debugMsg = 'Rejected - Needed value not defined';
740eA            WrtDebugMsg();
740eA          endif;
               return *off;
             endif;

         other;
740eA      if debug;
740eA        debugMsg = 'Rejected - Needed value not defined';
740eA        WrtDebugMsg();
740eA      endif;
           return *off;
       endsl;

      /end-free

     p                 e

740cA*----------------------------------------------------------------
740cA*  GetItemDef     Get definition for item if one exists
740cA*----------------------------------------------------------------
740cA
740cAp GetItemDef      b
     d GetItemDef      pi             5p 0

     *  Local Variables

     D hours           s              5p 0

      /free

       // If item not passed in, get out

       if pItem = '';
         return 0;
       endif;

       // Is there a definition for the Mfr/Item

       exec sql select bdiwhse,bdidef#, bdhdesc, bdhminlen, bdhaiflags
                 into :bdiwhse, :bdidef#,:bdhdesc,:bdhminlen,:bdhaiflags
                 from bardefi
                 left outer join bardefh on bdhwhse=bdiwhse and bdhdef#=bdidef#
                 where bdiwhse = 0
                   and bdiitem = :pItem
740fM              and bdhmfr# = :pVen#
                 fetch first row only;

       if sqlstt = sqlSuccess;

740eA    if debug;
740eA      debugMsg = 'Read '
740eA               + 'Def:' + %char(bdidef#) + ', '
740fM               + 'Mfr:' + %char(pVen#) + ', '
740eA               + 'Itm:' + %trim(pItem) + ', '
740eA               + 'Min:' + %char(bdhminlen);
740eA      WrtDebugMsg();
740eA    endif;

         if VerifyDef(bdiwhse: bdidef#);
           $bcDef#Sent = *on;
           $bcDef# = 'D:' + %char(bdidef#) + ','
                   + 'M:' + %char(bdhmfr#) + ','
                   + 'I:' + bdiitem;
           return bdidef#;
         endif;
       endif;

       // Is there a definition for the Item with a zero for the Mfr?

       exec sql select bdiwhse,bdidef#, bdhdesc, bdhminlen, bdhaiflags
                 into :bdiwhse, :bdidef#,:bdhdesc,:bdhminlen,:bdhaiflags
                 from bardefi
                 left outer join bardefh on bdhwhse=bdiwhse and bdhdef#=bdidef#
                 where bdiwhse = 0
                   and bdiitem = :pItem
                   and bdhmfr# = 0
                 fetch first row only;

       if sqlstt = sqlSuccess;

740eA    if debug;
740eA      debugMsg = 'Read Itm:' + %trim(pItem) + ', '
740eA               + 'Def:' + %char(bdidef#) + ', '
740eA               + 'Mfr:0, '
740eA               + 'Min:' + %char(bdhminlen);
740eA      WrtDebugMsg();
740eA    endif;

         if VerifyDef(bdiwhse: bdidef#);
           $bcDef#Sent = *on;
           $bcDef# = 'D:' + %char(bdidef#) + ','
                   + 'M:0,'
                   + 'I:' + bdiitem;
           return bdidef#;
         endif;
       endif;

       return 0;

      /end-free

     p                 e

740cA*----------------------------------------------------------------
740cA*  GetMfrDef      Get definition for Mfr if one exists
740cA*----------------------------------------------------------------
740cA
740cAp GetMfrDef       b
     d GetMfrDef       pi             5p 0

     *  Local Variables

     D dftDef#         s              5p 0
     D mfrGenericDef#  s              5p 0
     D valLen          s              3p 0
     D idVal           s             10

      /free

       // Reading the file from most specific (barcode length and id defined)
       // to least specific (no barcode length and id defined)
       // in the hope of minimizing the number of reads.

       SqlStmt = 'select bdhwhse,bdhmfr#,bdhdef#,bdhdesc,'
               +        'bdhdflt,bdhlen,bdhidstrt,bdhidval, '
               +        'bdhminlen, bdhaiflags '
               + 'from bardefh '
               + 'where bdhwhse = 0 '
740fM          +   'and (bdhmfr# = ' + %char(pVen#) + ' '
               +        'or bdhmfr# = 0) '
               + 'order by bdhwhse,bdhmfr# desc, bdhlen desc, bdhidstrt desc';

       exec sql prepare headerSel from :SqlStmt;
       exec sql declare headerCsr dynamic scroll cursor for headerSel;
       exec sql open headerCsr;

       dftDef# = 0;
       mfrGenericDef# = 0;

       dow forever = forever;

         exec sql
           fetch next from headerCsr
            into :bdhwhse, :bdhmfr#, :bdhdef#, :bdhdesc,
                 :bdhdflt, :bdhlen, :bdhidstrt, :bdhidval,
                 :bdhminlen, :bdhaiflags;

         if sqlstt <> sqlSuccess;
           leave;
         endif;

740eA    if debug;
740eA      debugMsg = 'Read '
740eA               + 'Def:' + %char(bdhdef#) + ', '
740eA               + 'Mfr:' + %char(bdhmfr#) + ', '
740eA               + 'Dflt:' + bdhdflt + ', '
740eA               + 'ExactLen:' + %char(bdhlen) + ', '
740eA               + 'MinLen:' + %char(bdhminlen) + ', '
740eA               + 'IdStr:' + %char(bdhidstrt) + ', '
740eA               + 'IdVal:' + %trim(bdhidval);
740eA      WrtDebugMsg();
740eA    endif;

         // Get out when we run out of recs for Mfr.
         if bdhmfr# = 0;
740eA      if debug;
740eA        debugMsg = 'No more Mfr recs';
740eA        WrtDebugMsg();
740eA      endif;
           leave;
         endif;

         // Highest Priority:
         //   Mfr# > 0 and Matches barcode length and defined Id

         if bdhmfr# > 0 and barCodeLen = bdhlen and bdhidstrt > 0;

740eA      if debug;
740eA        debugMsg = 'Priority 1 minimum criteria match - '
740eA                 + 'Mfr > 0, Barcode length defined, Id defined';
740eA        WrtDebugMsg();
740eA      endif;

           valLen = %len(%trimr(bdhidval));
           monitor;
             idVal = %subst($PBarCode: bdhidstrt: valLen);
             if idVal = bdhidval;
               if VerifyDef(bdhwhse: bdhdef#);
                 $bcDef#Sent = *on;
                 $bcDef# = 'D:' + %char(bdhdef#) + ','
                         + 'M:' + %char(bdhmfr#) + ','
                         + 'Len,Id';
                 exec sql close headerCsr;
                 return bdhdef#;
               endif;
             else;
740eA          if debug;
740eA            debugMsg = 'Rejected - Id does not match ';
740eA            WrtDebugMsg();
740eA          endif;
             endif;
           on-error;
740eA        if debug;
740eA          debugMsg = 'Rejected - Unexpected monitor error';
740eA          WrtDebugMsg();
740eA        endif;
           endmon;
         endif;

         // Next Priority:
         //   Mfr# > 0 and Matches barcode length with no defined Id

         if bdhmfr# > 0 and barCodeLen = bdhlen and bdhidstrt = 0;

740eA      if debug;
740eA        debugMsg = 'Priority 2 minimum criteria match - '
740eA                 + 'Mfr > 0, Barcode length defined, Id not defined';
740eA        WrtDebugMsg();
740eA      endif;

           if VerifyDef(bdhwhse: bdhdef#);
             $bcDef#Sent = *on;
             $bcDef# = 'D:' + %char(bdhdef#) + ','
                     + 'M:' + %char(bdhmfr#) + ','
                     + 'Len,NoId';
             exec sql close headerCsr;
             return bdhdef#;
           endif;
         endif;

         // Next Priority:
         //   Mfr# > 0 and Matches defined Id with no defined barcode length

         if bdhmfr# > 0 and bdhlen = 0 and bdhidstrt > 0;

740eA      if debug;
740eA        debugMsg = 'Priority 3 minimum criteria match - '
740eA                 + 'Mfr > 0, Barcode length not defined, Id defined';
740eA        WrtDebugMsg();
740eA      endif;

           valLen = %len(%trimr(bdhidval));
           monitor;
             idVal = %subst($PBarCode: bdhidstrt: valLen);
             if idVal = bdhidval;
               if VerifyDef(bdhwhse: bdhdef#);
                 $bcDef#Sent = *on;
                 $bcDef# = 'D:' + %char(bdhdef#) + ','
                         + 'M:' + %char(bdhmfr#) + ','
                         + 'Id,NoLen';
                 exec sql close headerCsr;
                 return bdhdef#;
               endif;
             else;
740eA          if debug;
740eA            debugMsg = 'Rejected - Id does not match ';
740eA            WrtDebugMsg();
740eA          endif;
             endif;
           on-error;
740eA        if debug;
740eA          debugMsg = 'Rejected - Unexpected monitor error';
740eA          WrtDebugMsg();
740eA        endif;
           endmon;
         endif;

         // Save a Mfr def that does not have a defined length or id
         // If more than one, no guarantee which will be used.

         if bdhmfr# > 0 and bdhlen = 0 and bdhidstrt = 0;

740eA      if debug;
740eA        debugMsg = 'Priority 4 minimum criteria match - '
740eA                 + 'Mfr > 0, Barcode length not defined, Id not defined';
740eA        WrtDebugMsg();
740eA      endif;

           if VerifyDef(bdhwhse: bdhdef#);
             mfrGenericDef# = bdhdef#;
740eA        if debug;
740eA          debugMsg = 'Saved as generic Mfr def';
740eA          WrtDebugMsg();
740eA        endif;
           endif;
         endif;

         // Next Priority:
         //   Look for a default for the Mfr

         if bdhmfr# > 0 and bdhdflt = 'Y';

740eA      if debug;
740eA        debugMsg = 'Priority 5 minimum criteria match - '
740eA                 + 'Mfr > 0, Marked as Default';
740eA        WrtDebugMsg();
740eA      endif;

           if VerifyDef(bdhwhse: bdhdef#);
             dftDef# = bdhdef#;
740eA        if debug;
740eA          debugMsg = 'Saved as default';
740eA          WrtDebugMsg();
740eA        endif;
           endif;
         endif;

       enddo;

       // These are catch-alls for when we run out of records
       // No specific definitions found (ones with length or id defined)

       // if we came across a Mfr rec with zero len and zero id definition
       // Use it.

       if mfrGenericDef# > 0;

740eA    if debug;
740eA      debugMsg = 'Using generic found for Mfr';
740eA      WrtDebugMsg();
740eA    endif;

         $bcDef#Sent = *on;
         $bcDef# = 'D:' + %char(mfrGenericDef#) + ','
740fM            + 'M:' + %char(pVen#) + ','
                 + 'NoLen,NoId';
         exec sql close headerCsr;
         return mfrGenericDef#;
       endif;

       // Otherwise, use default definition if found

       if dftDef# > 0;

740eA    if debug;
740eA      debugMsg = 'Using default found for Mfr';
740eA      WrtDebugMsg();
740eA    endif;

         $bcDef#Sent = *on;
         $bcDef# = 'D:' + %char(dftDef#) + ' (Default)';
         exec sql close headerCsr;
         return dftDef#;
       endif;

       // Otherwise, nothing found

       exec sql close headerCsr;
       return 0;

      /end-free

     p                 e

740ca*----------------------------------------------------------------
740cA*  ProcessDef     Process user-defined definition
740cA*----------------------------------------------------------------
740cA
740cAp ProcessDef      b
     d ProcessDef      pi
     d  def#                          5p 0

     *  Local Variables

     D aiCode          s              3
     D date            s              6s 0
     D wgt             s             11p 3
     D count           s              3p 0

      /free

       // Determine the AI code to look for.
       // Some GS1 codes are entered generically in the def program.
       // For example, the program doesn't distinguish between Production and Package dates.

       select;
         when $PCmd = '*ALL    ';
           aiCode = 'ALL';
         when $PCmd = '*CWGTLBS';
           aiCode = '310';
         when $PCmd = '*UPC    ';
           aiCode = '01';
         when $PCmd = '*SSCC-18';
           aiCode = '01';
         when $PCmd = '*SCC-14 ';
           aiCode = '01';
         when $PCmd = '*SELLBY ';
           aiCode = '15';
         when $PCmd = '*EXPDT  ';
           aiCode = '17';
         when $PCmd = '*PKGDT  ';
           aiCode = '11';
         when $PCmd = '*PRODDT ';
           aiCode = '11';
         other;
           aiCode = 'ERR';
           return;
       endsl;

       //

       SqlStmt = 'select bddai,bddstart,bddlen,bdddec,bddfmt '
               + 'from bardefd '
               + 'where bddwhse = 0 '
               +   'and bdddef# = ' + %char(def#);

       select;
         when aiCode = '310';
           SqlStmt = %trim(SqlStmt) + ' '
                   + 'and (bddai = ' + sq + '310' + sq + ' '
                   +      'or bddai = ' + sq + '320' + sq + ')';
         when aiCode <> 'ALL';
           SqlStmt = %trim(SqlStmt) + ' '
                   + 'and bddai = ' + sq + aiCode + sq;
       endsl;

       exec sql prepare detailSel from :SqlStmt;
       exec sql declare detailCsr dynamic scroll cursor for detailSel;
       exec sql open detailCsr;

       count = 0;

       dow forever = forever;

         exec sql
           fetch next from detailCsr
            into :bddai, :bddstart, :bddlen, :bdddec, :bddfmt;

         if sqlstt <> sqlSuccess;
           if count = 0;
             $PReturn = '*DEFNOTFND';
             $PErrMsg = 'Definition ' + %char(def#) + ' not found';
740eA        if debug;
740eA          debugMsg = 'Error: No definition detail records found. '
740eA                   + 'See next entry for SQL statement.';
740eA          WrtDebugMsg();
740eA          debugMsg = sqlStmt;
740eA          WrtDebugMsg();
740eA        endif;
           endif;
           leave;
         endif;

         count += 1;

         $PAIPos = bddstart;

         select;

           when bddai = '01';
             $PAIDesc = 'GTIN'
                      + ' - Def#' + %char(def#);
             $PValueTyp = 2;
             $pvalue2 = %subst($PBarCode: bddstart: bddlen);
             $bcGtinSent = *on;
             $bcGtin = $pvalue2;

740gA      when bddai = '98';
740gA        $PAIDesc = 'GTIN'
740gA                 + ' - Def#' + %char(def#);
740gA        $PValueTyp = 2;
740gA        $pvalue2 = %subst($PBarCode: bddstart: bddlen);
740gA        $bcGtinSent = *on;
740gA        $bcGtin = $pvalue2;

           when bddai = '10';
             $PAIDesc = 'Lot'
                      + ' - Def#' + %char(def#);
             $PValueTyp = 2;
             $pvalue2 = %subst($PBarCode: bddstart: bddlen);
             $bcLotSent = *on;
             $bcLot = $pvalue2;

           when bddai = '11';
             $PAIDesc = 'Prod Dte'
                      + ' - Def#' + %char(def#);
             date = ProcessDefDate();
             if date < 0;
               $PReturn = '*INVALID';
               $PErrMsg = 'Invalid production date found '
                        + 'at positon ' + %char(bddstart);
               leave;
             endif;
             $PValueTyp = 1;
             $pvalue1 = date;
             $bcProdDSent = *on;
             $bcProdD = $pvalue1;

           when bddai = '15';
             $PAIDesc = 'Sell-By Dte'
                      + ' - Def#' + %char(def#);
             date = ProcessDefDate();
             if date < 0;
               $PReturn = '*INVALID';
               $PErrMsg = 'Invalid sell-by date found '
                        + 'at positon ' + %char(bddstart);
               leave;
             endif;
             $PValueTyp = 1;
             $pvalue1 = date;
             $bcSlByDSent = *on;
             $bcSlByD = $pvalue1;

           when bddai = '17';
             $PAIDesc = 'Exp Dte'
                      + ' - Def#' + %char(def#);
             date = ProcessDefDate();
             if date < 0;
               $PReturn = '*INVALID';
               $PErrMsg = 'Invalid expiration date found '
                        + 'at positon ' + %char(bddstart);
               leave;
             endif;
             $PValueTyp = 1;
             $pvalue1 = date;
             $bcExpDSent = *on;
             $bcExpD = $pvalue1;

           when bddai = '21';
             $PAIDesc = 'Serial'
                      + ' - Def#' + %char(def#);
             $PValueTyp = 2;
             $pvalue2 = %subst($PBarCode: bddstart: bddlen);
             $bcSer#Sent = *on;
             $bcSer# = $pvalue2;

           when bddai = '310';
             $PAIDesc = 'Wgt Lb from Kg'
                      + ' - Def#' + %char(def#);
             wgt = ProcessDefWgt();
             if wgt < 0;
               $PReturn = '*INVALID';
               $PErrMsg = 'Invalid net weight kilograms found '
                        + 'at positon ' + %char(bddstart);
               leave;
             endif;
             $bcPNtKgSent = *on;
             $bcPNtkg = wgt;
             $bcPNtlbSent = *on;
             $bcPNtlb = ConvertKg2Lb($bcPNtkg: bdddec);

             // Get UCI override

             $PValueTyp = 1;
             $pvalue1 = $bcPNtlb;
             mfrwgt();
             zzzgetlbs();

             // If Pounds changed, convert to Kilos

             if $pvalue1 <> $bcPNtlb;
               $bcPNtkg = ConvertLb2Kg($bcPNtlb: AIDecPos);
             endif;

             // Send back requested value

             if pKiloLbs = 'K';
               $pvalue1 = $bcPNtKg;
             else;
               $pvalue1 = $bcPNtLb;
             endif;

           when bddai = '320';
             $PAIDesc = 'Wgt Lb'
                      + ' - Def#' + %char(def#);
             wgt = ProcessDefWgt();
             if wgt < 0;
               $PReturn = '*INVALID';
               $PErrMsg = 'Invalid net weight pounds found '
                        + 'at positon ' + %char(bddstart);
               leave;
             endif;
             $bcPNtlbSent = *on;
             $bcPNtLb = wgt;

             // Get UCI override

             zzzgetlbs();

             // Convert to Kilos

             $bcPNtkgSent = *on;
             $bcPNtkg = ConvertLb2Kg($bcPNtLb: bdddec);

             // Send back requested value

             $PValueTyp = 1;
             if pKiloLbs = 'K';
               $pvalue1 = $bcPNtKg;
             else;
               $pvalue1 = $bcPNtLb;
             endif;

           other;
             $PReturn = '*INVALID';
             $PErrMsg = 'Invalid AI Code ' + bddai;
             leave;

         endsl;

       enddo;

740eA          if $PReturn = '*INVALID' and debug;
740eA            debugMsg = 'Error: ' + $PErrMsg;
740eA            WrtDebugMsg();
740eA          endif;

       exec sql close detailCsr;

      /end-free

     p                 e

740ca*----------------------------------------------------------------
740cA*  ProcessDefDate  Process definition date
740cA*----------------------------------------------------------------
740cA
740cAp ProcessDefDate  b
     d ProcessDefDate  pi             6s 0

     *  Local Variables

     D dateYMD         s              6
     D date6N          s              6s 0
     D numbers         s             10    inz('0123456789')

      /free

        // Get date into YYMMDD format

        monitor;

          select;
            when bddfmt = 'YYMMDD';
              dateYMD = %subst($PBarCode: bddstart: 6);

            when bddfmt = 'MMDDYY';
              dateYMD = %subst($PBarCode: bddstart+4: 2)
                      + %subst($PBarCode: bddstart: 4);

            when bddfmt = 'MMDDYYYY';
              dateYMD = %subst($PBarCode: bddstart+6: 2)
                      + %subst($PBarCode: bddstart: 4);

            when bddfmt = 'DDMMYY';
              dateYMD = %subst($PBarCode: bddstart+4: 2)
                      + %subst($PBarCode: bddstart+2: 2)
                      + %subst($PBarCode: bddstart: 2);

            when bddfmt = 'DDMMYYYY';
              dateYMD = %subst($PBarCode: bddstart+6: 2)
                      + %subst($PBarCode: bddstart+2: 2)
                      + %subst($PBarCode: bddstart: 2);
          endsl;

        on-error;
          return -1;
        endmon;

        // Make sure date only contains numbers

        If %check(Numbers: dateYMD) > 0;
          return -1;
        endif;

        // Convert date to number and send it back

        monitor;
          date6N = %dec(dateYMD: 6: 0);
          return date6N;
        on-error;
          return -1;
        endmon;

      /end-free

     p                 e

740ca*----------------------------------------------------------------
740cA*  ProcessDefWgt  Process definition weight
740cA*----------------------------------------------------------------
740cA
740cAp ProcessDefWgt   b
     d ProcessDefWgt   pi            11p 3

     *  Local Variables

     D wgtAlpha        s             11    varying
     D wgtNum          s             11p 3
     D numbers         s             10    inz('0123456789')
     D divisor         s              5p 0

      /free

        // Extract weight from barcode

        monitor;
          wgtAlpha = %subst($PBarCode: bddstart: bddlen);
        on-error;
          return -1;
        endmon;

        // Make sure weight only contains numbers

        If %check(Numbers: wgtAlpha) > 0;
          return -1;
        endif;

        // Convert weight to number

        monitor;
          if bdddec > 0;
            //wgtNum = %dec(wgtAlpha: 11: 3) / (10 ** bdddec);
            wgtNum = %dec(wgtAlpha: 11: 3);
            divisor = (10 ** bdddec);
            wgtNum /= divisor;
          else;
            wgtNum = %dec(wgtAlpha: 11: 3);
          endif;
          return wgtNum;
        on-error;
          return -1;
        endmon;

      /end-free

     p                 e

740aA*----------------------------------------------------------------
740aA*  zzzgetlbs  retrieve weight from uciinfo  record
740aA*----------------------------------------------------------------

740cAp zzzgetlbs       b
740cAd zzzgetlbs       pi

740aA /free
740aA   // if the whse isn't sent, get from user or default
740aA   select;
750aD     //when %parms < 15 or pWhse = 0;
750aM     when parmin < 15 or pWhse = 0;
740aA       getUser(#user: e$whse: e$emp#: e$fnam: e$init: e$lnam:
740aA               e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
740aA               e$bpu: e$lng);
740aA       if e$whse = 0;
740aA         e$whse = 001;
740aA       endif;
740aA     other;
740aA       e$whse = pWhse;
740aA   endsl;
740aA
740cD   //exsr clr$uciinfo;
740cA   savever# = $uiver#;
740cA   clear $uciinfo;
740cA   clear $uciinfo2;
740cA   $uiver# = savever#;
740cA   $uiaddemp = 0;
740cA   $uiaddusr = #user;
740cA   $uiaddpgm  = #prog;
740cA   $uiaddjob  = #job;
740cA   $uiaddnbr = #jobn;

740aA   $uiWhse = e$whse;
740aA   $uiuci  = $PBarCode;
720bA   $dridata = $uciinfo;
720bA   $dridata2 = $uciinfo2;
720bA   driUCICalled = *on;
720bA   driuciinfo('%GETLBS': #prog: $drireturn: $drimessage:
720bA            $dridata: $dridata2);

740aA   // the weight returned is the weight we will use
740aA   if $drireturn = '*OK';
720bA     $uciinfo = $dridata;
720bA     $uciinfo2 = $dridata2;
740aA     $bcPntLb = $uiwgtlbs;
740dA     $bcpntlbsent = '1';
740dA     if not $bcgtinSent;
740dA       $bcAi99Sent = '1';
740dA     endif;
740aA   endif;
740aA    if driUCICalled;
740aA      driuciinfo('%CLOSE': #prog: $drireturn: $drimessage:
740aA               $dridata: $dridata2);
740aA    endif;
740aA /end-free

     p                 e

510 AC*----------------------------------------------------------------
510 AC*  MfrWgt      Get custom Mfr weight
510 AC*

740cAp MfrWgt          b
740cAd MfrWgt          pi

WSTaA
WSTaA*   For Westside, go to special routine
WSTaA
WSTaAC                   if        client = westside
WSTaAC                   exsr      MfrWgtWst
740cDC**                 goto      EndMfrWgt
740cMC                   return
WSTaAC                   endif
ACCaA
ACCaA*   For Accardi, go to special routine
ACCaA
ACCaAC                   if        client = Accardi
ACCaAC                   exsr      MfrWgtAcc
740cDC**                 goto      EndMfrWgt
740cMC                   return
ACCaAC                   endif
SVLaA
SVLaA*   For Saval, go to special routine
SVLaA
SVLaAC                   if        client = saval
SVLaAC                   exsr      MfrWgtSvl
740cDC**                 goto      EndMfrWgt
740cMC                   return
SVLaAC                   endif
510bA
510bA*   Until custom Mfr codes is up and running and not Westside
510bA*   continue to use the old method.
510bA
510bA*   Whem custom Mfr is implemented, then it needs to be determined
510bA*   how to deal with program CW122 that allows straight weights to
510bA*   be entered. Maybe if an item doesn't have a defined Mfr
510bA*   routine, then treat as generic number. Or, maybe we only force
510bA*   a Mfr routine if the code was scanned through voice.
510bA
510bAC                   exsr      MfrWgtGen
740cDC**                 goto      EndMfrWgt
740cMC                   return

740cAC*----------------------------------------------------------------
740cAC*  Subroutines within MfrWgt Subprocedure
740cAC*----------------------------------------------------------------

510bAC*----------------------------------------------------------------
510bAC*  MfrWgtGen   Decipher generic wieght
510bAC*
510bAC     MfrWgtGen     begsr
     C                   eval      MfrWgtRtn = '*OK'
510bA
     C                   if        BarCodeLen > 9
     C                   eval      MfrWgtRtn = '*UCC'
     C                   goto      endWgtGen
     C                   endif
     C*
     C*      Right adjust number and strip decimal point (if any)
     C*
     C                   movel     $PBarCode     Temp9A
     C                   movea     Temp9A        A9
     C                   eval      FlagAdj = *OFF
     C                   eval      FlagDecPt = *OFF

     C                   eval      I = 10
     C                   eval      J = I - 1
     C                   eval      AIDecPos = 0

     C     Forever       doweq     forever
     C*
     C*         Check if we are out of characters
     C*
     C                   eval      I = I - 1
     C                   if        I = 0
     C                   leave
     C                   endif
     C*
     C*         See if we have found our first non-blank character
     C*
     C                   if        A9(I) = ' ' AND FlagAdj = *OFF
     C                   iter
     C                   endif
     C*
     C*         Character found, right adjust.
     C*
     C                   move      *ON           FlagAdj
     C*
     C*         Check for decimal point.
     C*
     C                   if        FlagDecPt = *OFF
     C                   if        A9(I) = '.'
     C                   eval      FlagDecPt = *On
     C                   eval      A9(I) = ' '
     C                   iter
     C                   else
     C                   eval      AIDecPos = AIDecPos + 1
     C                   endif
     C                   endif
     C*
     C*         Verify character is numeric.
     C*
     C                   eval      AINumb = %Scan(A9(I):Numbers)
     C                   if        AINumb = 0
     C                   eval      Error = *ON
     C                   eval      MfrWgtRtn = '*ERROR'
     C                   eval      $PReturn = '*INVALID'
     C                   eval      $PAIPos = I
     C                   eval      $PErrMsg = 'Invalid character found at '
     C                                        + 'position '
     C                                        + %Trim(%EditC($PAIPos:'Z'))
     C                   goto      EndWgtGen
     C                   endif
     C*
     C*         Move character to next right adjust position.
     C*
     C                   eval      A9(J) = A9(I)
     C                   eval      A9(I) = ' '
     C                   eval      J = J - 1

     C                   enddo
     C*
     C*      If decimal point not found, assume 2.
     C*
     C                   if        FlagDecPt = *OFF
     C                   eval      AIDecPos = 2
     C                   endif
     C*
     C*      Move weight into return parameter
     C*
     C                   movea     A9            Temp9A
     C                   move      Temp9A        Temp9N
     C                   eval      $PValueTyp = 1
700aAc*
700aAc*    if client stores kilograms, and pounds found convert to kilograms
700aAc                   select
700aAC                   when      IMkilolbs = 'K'
700aAC*
700aAC*    If pounds found, convert into kilograms.
700aAC*
750aDc*                  if        %parms <16
750aMc                   if        parmin <16
700aAC                   if        AIDecPos = 0
700aAC                   eval      $PValue1 = Temp9N
700aAC                   else
700aAC                   eval      $PValue1 = Temp9N
700aAC     1             do        AIDecPos
700aAC                   eval      $PValue1 = $PValue1 / 10
700aAC                   enddo
700aAC                   endif
700aAc                   else
740cDC**                 if        $pkilolbssent = 'P'
740cMC                   if        pKiloLbs = 'P'
700aAC                   eval      $PValue1 = Temp9N
700aAC                   eval      $PAICode = TCOD(10)
700aAC                   eval      $PAIDesc = TDSC(10)
700aAC                   eval(h)   kilos110 = $pValue1 / kgs2lbs
700aAC                   eval      $pValue1 = kilos110
700aAC                   if        AIDecPos = 0
700aAC                   else
700aAC     1             do        AIDecPos
700aAC                   eval      $PValue1 = $PValue1 / 10
700aAC                   enddo
700aAC                   endif
700aAc                   else
700aAC                   if        AIDecPos = 0
700aAC                   eval      $PValue1 = Temp9N
700aAC                   else
700aAC                   eval      $PValue1 = Temp9N
700aAC     1             do        AIDecPos
700aAC                   eval      $PValue1 = $PValue1 / 10
700aAC                   enddo
700aAC                   endif
700aAc                   endif
700aAc                   endif
700aAc                   other
700aAC*    If kilos found, convert into lbs.
700aAC*
750aDc*                  if        %parms <16
750aMc                   if        parmin <16
700aAC                   if        AIDecPos = 0
700aAC                   eval      $PValue1 = Temp9N
700aAC                   else
700aAC                   eval      $PValue1 = Temp9N
700aAC     1             do        AIDecPos
700aAC                   eval      $PValue1 = $PValue1 / 10
700aAC                   enddo
700aAC                   endif
700aAc                   else
740cDC**                 if        $pkilolbssent = 'K'
740cMC                   if        pKiloLbs = 'K'
700aAC                   eval      $PValue1 = Temp9N
700aAC                   eval      $PAICode = TCOD(10)
700aAC                   eval      $PAIDesc = TDSC(10)
700aAC                   eval(h)   kilos110 = $pValue1 * kgs2lbs
700aAC                   eval      $pValue1 = kilos110
700aAC                   if        AIDecPos = 0
700aAC                   else
700aAC     1             do        AIDecPos
700aAC                   eval      $PValue1 = $PValue1 / 10
700aAC                   enddo
700aAC                   endif
700aAc                   else
700aAC                   if        AIDecPos = 0
700aAC                   eval      $PValue1 = Temp9N
700aAC                   else
700aAC                   eval      $PValue1 = Temp9N
700aAC     1             do        AIDecPos
700aAC                   eval      $PValue1 = $PValue1 / 10
700aAC                   enddo
700aAC                   endif
700aAc                   endif
700aAc                   endif
700aDC*                  if        AIDecPos = 0
700aDC*                  eval      $PValue1 = Temp9N
700aDC*                  else
700aDC*                  eval      $PValue1 = Temp9N
700aDC*    1             do        AIDecPos
700aDC*                  eval      $PValue1 = $PValue1 / 10
700aDC*                  enddo
700aDC*                  endif
700aAc                   endsl
     C                   eval      $PAIDecPos = AIDecPos
     C                   eval      $PAIDesc = 'Weight Only'
     C                   eval      $PReturn = '*OK'
     C*
     C     EndWgtGen     endsr
WSTaAC*----------------------------------------------------------------
WSTaAC*  MfrWgtWst    Custom mfr weights for Westside
WSTaAC*
WSTaAC     MfrWgtWst     begsr
     C                   eval      MfrWgtRtn = '*OK'

     C                   select

WSTbA*   Omaha Steaks - Ven# 14450
WSTiA*   Greater Omaha Packing- Ven# 113776
     *     - Scanned barcode length must be 12 digits.
     *     - 9th digit is zero.
     *     - Last (rightmost) 3 digits is the weight in pounds
     *       with 1 decimal position.

740fDC**                 when      %parms >= 12 and $pVen# = 14450
740fMC                   when      pVen# = 14450
WSTjAC*                            or %parms >= 12 and $pVen# = 113776
     C                   if        BarCodeLen <> 12
     C                             or %subst(%trim($PBarCode):9:1) <> '0'
     C                   eval      MfrWgtRtn = '*ERROR'
     C                   eval      $PReturn = '*INVALID'
     C                   eval      $PAIPos = 1
     C                   eval      $PErrMsg = 'Invalid Mfr weight '
     C                                        + 'found at positon 1'
     C                   goto      EndMfrWgtWst
     C                   endif
     C                   eval      temp3a = %subst(%trim($PBarCode):10:3)
     C                   testn                   temp3a               50
     C                   if        *in50
     C                   move      temp3a        temp31n
     C                   eval      $PValue1 = temp31n
     C                   eval      $PAIDesc = 'Westside - Omaha Steaks'
     C                   eval      $PReturn = '*OK'
     C                   goto      EndMfrWgtWst
     C                   endif
WSTjA*   Greater Omaha Packing- Ven# 113776
     *     - vendor has multiple formats
     *     - one format is 12 digits, the other is gs1 format
     *     - if 12 digit barcode - 9th digit is zero.
     *     - Last (rightmost) 3 digits is the weight in pounds
     *       with 1 decimal position.

740fDC**                 when      %parms >= 12 and $pVen# = 113776
740fMC                   when      pVen# = 113776
WSTjAC                   eval      MfrWgtRtn = ' '
WSTjAC                   if        BarCodeLen =  12
WSTjAC                             and %subst(%trim($PBarCode):9:1)= '0'
WSTjAC                   eval      temp3a = %subst(%trim($PBarCode):10:3)
WSTjAC                   testn                   temp3a               50
WSTjAC                   if        *in50
WSTjAC                   move      temp3a        temp31n
WSTjAC                   eval      $PValue1 = temp31n
WSTjAC                   eval      $PAIDesc = 'Westside - Omaha Steaks'
WSTjAC                   eval      $PReturn = '*OK'
WSTjAC                   eval      MfrWgtRtn = '*OK'
WSTjAC                   goto      EndMfrWgtWst
WSTjAC                   endif
WSTjAC                   endif

WSTbA*   Purdue - Ven# 17700
     *     - Must scan ucc code.

740fDC**                 when      %parms >= 12 and $pVen# = 17700
740fMC                   when      pVen# = 17700
     C                   eval      MfrWgtRtn = '*UCC'

     *   Daisy
     *     - Scanned barcode length must be 8 digits.
     *     - Last (rightmost) 3 digits is the weight in pounds
     *       with 1 decimal position.

     C                   when      BarCodeLen = 8
     C                   eval      temp8a = %subst(%trim($PBarCode):1:8)
     C                   testn                   temp8a               50
     C                   if        *in50
     C                   move      temp8a        temp31n
     C                   eval      $PValue1 = temp31n
     C                   eval      $PAIDesc = 'Westside - Daisy'
     C                   eval      $PReturn = '*OK'
     C                   goto      EndMfrWgtWst
     C                   endif

WSTbA*   Other
     *     - Assume ucc code must be scanned.

     C                   other
WSTfAC                   if        BarCodeLen > 9
WSTfAC                   eval      MfrWgtRtn = '*UCC'
WSTfAC                   goto      endMfrWgtWst
WSTfAC                   endif
WSTfAC*
WSTfAC*      Right adjust number and strip decimal point (if any)
WSTfAC*
WSTfAC                   movel     $PBarCode     Temp9A
WSTfAC                   movea     Temp9A        A9
WSTfAC                   eval      FlagAdj = *OFF
WSTfAC                   eval      FlagDecPt = *OFF
WSTfA
WSTfAC                   eval      I = 10
WSTfAC                   eval      J = I - 1
WSTfAC                   eval      AIDecPos = 0
WSTfA
WSTfAC     Forever       doweq     forever
WSTfAC*
WSTfAC*         Check if we are out of characters
WSTfAC*
WSTfAC                   eval      I = I - 1
WSTfAC                   if        I = 0
WSTfAC                   leave
WSTfAC                   endif
WSTfAC*
WSTfAC*         See if we have found our first non-blank character
WSTfAC*
WSTfAC                   if        A9(I) = ' ' AND FlagAdj = *OFF
WSTfAC                   iter
WSTfAC                   endif
WSTfAC*
WSTfAC*         Character found, right adjust.
WSTfAC*
WSTfAC                   move      *ON           FlagAdj
WSTfAC*
WSTfAC*         Check for decimal point.
WSTfAC*
WSTfAC                   if        FlagDecPt = *OFF
WSTfAC                   if        A9(I) = '.'
WSTfAC                   eval      FlagDecPt = *On
WSTfAC                   eval      A9(I) = ' '
WSTfAC                   iter
WSTfAC                   else
WSTfAC                   eval      AIDecPos = AIDecPos + 1
WSTfAC                   endif
WSTfAC                   endif
WSTfAC*
WSTfAC*         Verify character is numeric.
WSTfAC*
WSTfAC                   eval      AINumb = %Scan(A9(I):Numbers)
WSTfAC                   if        AINumb = 0
WSTfAC                   eval      Error = *ON
WSTfAC                   eval      MfrWgtRtn = '*ERROR'
WSTfAC                   eval      $PReturn = '*INVALID'
WSTfAC                   eval      $PAIPos = I
WSTfAC                   eval      $PErrMsg = 'Invalid character found at '
WSTfAC                                        + 'position '
WSTfAC                                        + %Trim(%EditC($PAIPos:'Z'))
WSTfAC                   goto      endMfrWgtWst
WSTfAC                   endif
WSTfAC*
WSTfAC*         Move character to next right adjust position.
WSTfAC*
WSTfAC                   eval      A9(J) = A9(I)
WSTfAC                   eval      A9(I) = ' '
WSTfAC                   eval      J = J - 1
WSTfA
WSTfAC                   enddo
WSTfAC*
WSTfAC*      If decimal point not found, assume 2.
WSTfAC*
WSTfAC                   if        FlagDecPt = *OFF
WSTfAC                   eval      AIDecPos = 2
WSTfAC                   endif
WSTfAC*
WSTfAC*      Move weight into return parameter
WSTfAC*
WSTfAC                   movea     A9            Temp9A
WSTfAC                   move      Temp9A        Temp9N
WSTfAC                   eval      $PValueTyp = 1
WSTfAC                   if        AIDecPos = 0
WSTfAC                   eval      $PValue1 = Temp9N
WSTfAC                   else
WSTfAC                   eval      $PValue1 = Temp9N
WSTfAC     1             do        AIDecPos
WSTfAC                   eval      $PValue1 = $PValue1 / 10
WSTfAC                   enddo
WSTfAC                   endif
WSTfAC                   eval      $PAIDecPos = AIDecPos
WSTfAC                   eval      $PAIDesc = 'Weight Only'
WSTfAC                   eval      $PReturn = '*OK'
WSTfDC*****              eval      MfrWgtRtn = '*UCC'

     C                   endsl

     C     endMfrWgtWst  endsr
ACCaA*
ACCaAC*----------------------------------------------------------------
ACCaAC*  MfrWgtAcc    Custom mfr weights for Accardi
ACCaAC*
ACCaAC     MfrWgtAcc     begsr
ACCaAC                   eval      MfrWgtRtn = '*OK'
ACCaA
ACCaAC                   select
ACCaA
ACCaA*   Retail scale weighed = #000000#9999#
ACCaA*     - Scanned barcode length must be 13 digits.
ACCaA*     - Last (rightmost) 9999 digits is the weight in pounds
ACCaA*       with 2 decimal position.
ACCaA
750aDC*                  when      %parms >= 12
750aMC                   when      parmin >= 12
ACCaAC                             and BarCodeLen >= 13
ACCaAC                             and %subst(%trim($PBarCode):2:6)= '000000'
ACCaAC                   if        BarCodeLen <> 13
ACCaAC                   eval      MfrWgtRtn = '*ERROR'
ACCaAC                   eval      $PReturn = '*INVALID'
ACCaAC                   eval      $PAIPos = 1
ACCaAC                   eval      $PErrMsg = 'Invalid Mfr weight '
ACCaAC                                        + 'found at positon 1'
ACCaAC                   goto      EndMfrWgtAcc
ACCaAC                   endif
ACCaA*
ACCaAC                   eval      temp4a = %subst(%trim($PBarCode):9:4)
ACCaAC                   testn                   temp4a               50
ACCaAC                   if        *in50
ACCaAC                   move      temp4a        temp42n
ACCaAC                   eval      $PValue1 = temp42n
ACCaAC                   eval      $PAIDesc = 'Accardi - Retail Scale'
ACCaAC                   eval      $PReturn = '*OK'
ACCaAC                   goto      EndMfrWgtAcc
ACCaAC                   endif
ACCaA
ACCaA*   Other
ACCaA*     - Assume ucc code must be scanned.
ACCaA
ACCaAC                   other
ACCaAC                   if        BarCodeLen > 9
ACCaAC                   eval      MfrWgtRtn = '*UCC'
ACCaAC                   goto      endMfrWgtAcc
ACCaAC                   endif
ACCaAC*
ACCaAC*      Right adjust number and strip decimal point (if any)
ACCaAC*
ACCaAC                   movel     $PBarCode     Temp9A
ACCaAC                   movea     Temp9A        A9
ACCaAC                   eval      FlagAdj = *OFF
ACCaAC                   eval      FlagDecPt = *OFF
ACCaA
ACCaAC                   eval      I = 10
ACCaAC                   eval      J = I - 1
ACCaAC                   eval      AIDecPos = 0
ACCaA
ACCaAC     Forever       doweq     forever
ACCaAC*
ACCaAC*         Check if we are out of characters
ACCaAC*
ACCaAC                   eval      I = I - 1
ACCaAC                   if        I = 0
ACCaAC                   leave
ACCaAC                   endif
ACCaAC*
ACCaAC*         See if we have found our first non-blank character
ACCaAC*
ACCaAC                   if        A9(I) = ' ' AND FlagAdj = *OFF
ACCaAC                   iter
ACCaAC                   endif
ACCaAC*
ACCaAC*         Character found, right adjust.
ACCaAC*
ACCaAC                   move      *ON           FlagAdj
ACCaAC*
ACCaAC*         Check for decimal point.
ACCaAC*
ACCaAC                   if        FlagDecPt = *OFF
ACCaAC                   if        A9(I) = '.'
ACCaAC                   eval      FlagDecPt = *On
ACCaAC                   eval      A9(I) = ' '
ACCaAC                   iter
ACCaAC                   else
ACCaAC                   eval      AIDecPos = AIDecPos + 1
ACCaAC                   endif
ACCaAC                   endif
ACCaAC*
ACCaAC*         Verify character is numeric.
ACCaAC*
ACCaAC                   eval      AINumb = %Scan(A9(I):Numbers)
ACCaAC                   if        AINumb = 0
ACCaAC                   eval      Error = *ON
ACCaAC                   eval      MfrWgtRtn = '*ERROR'
ACCaAC                   eval      $PReturn = '*INVALID'
ACCaAC                   eval      $PAIPos = I
ACCaAC                   eval      $PErrMsg = 'Invalid character found at '
ACCaAC                                        + 'position '
ACCaAC                                        + %Trim(%EditC($PAIPos:'Z'))
ACCaAC                   goto      endMfrWgtAcc
ACCaAC                   endif
ACCaAC*
ACCaAC*         Move character to next right adjust position.
ACCaAC*
ACCaAC                   eval      A9(J) = A9(I)
ACCaAC                   eval      A9(I) = ' '
ACCaAC                   eval      J = J - 1
ACCaA
ACCaAC                   enddo
ACCaAC*
ACCaAC*      If decimal point not found, assume 2.
ACCaAC*
ACCaAC                   if        FlagDecPt = *OFF
ACCaAC                   eval      AIDecPos = 2
ACCaAC                   endif
ACCaAC*
ACCaAC*      Move weight into return parameter
ACCaAC*
ACCaAC                   movea     A9            Temp9A
ACCaAC                   move      Temp9A        Temp9N
ACCaAC                   eval      $PValueTyp = 1
ACCaAC                   if        AIDecPos = 0
ACCaAC                   eval      $PValue1 = Temp9N
ACCaAC                   else
ACCaAC                   eval      $PValue1 = Temp9N
ACCaAC     1             do        AIDecPos
ACCaAC                   eval      $PValue1 = $PValue1 / 10
ACCaAC                   enddo
ACCaAC                   endif
ACCaAC                   eval      $PAIDecPos = AIDecPos
ACCaAC                   eval      $PAIDesc = 'Weight Only'
ACCaAC                   eval      $PReturn = '*OK'
ACCaA
ACCaAC                   endsl
ACCaA
ACCaAC     endMfrWgtAcc  endsr
ACCaA*
SVLaAC*----------------------------------------------------------------
SVLaAC*  MfrWgtSvl    Custom mfr weights for Saval
SVLaAC*
SVLaAC     MfrWgtSvl     begsr
     C                   eval      MfrWgtRtn = '*OK'

     C                   select

     *   Retail scale weighed = 99iiiii99999c
     *     - Scanned barcode length must be 13 digits.
     *     - First 2 characters must be 99.
     *     - Char 8-12 is the weight in pounds with 2 decimals

750aDC*                  when      %parms >= 12
750aMC                   when      parmin >= 12
     C                             and BarCodeLen >= 13
     C                             and %subst(%trim($PBarCode):1:2)= '99'
     C                   if        BarCodeLen <> 13
     C                   eval      MfrWgtRtn = '*ERROR'
     C                   eval      $PReturn = '*INVALID'
     C                   eval      $PAIPos = 1
     C                   eval      $PErrMsg = 'Invalid Mfr weight '
     C                                        + 'found at positon 1'
     C                   leavesr
     C                   endif
     *
     C                   eval      temp5a = %subst(%trim($PBarCode):8:5)
     C                   testn                   temp5a               50
     C                   if        *in50
     C                   move      temp5a        temp52n
     C                   eval      $PValue1 = temp52n
     C                   eval      $PAIDesc = 'Saval - Retail Scale'
     C                   eval      $PReturn = '*OK'
     C                   leavesr
     C                   endif

     *   Other
     *     - Assume ucc code must be scanned.

     C                   other
     C                   if        BarCodeLen > 9
     C                   eval      MfrWgtRtn = '*UCC'
     C                   leavesr
     C                   endif
     C*
     C*      Right adjust number and strip decimal point (if any)
     C*
     C                   movel     $PBarCode     Temp9A
     C                   movea     Temp9A        A9
     C                   eval      FlagAdj = *OFF
     C                   eval      FlagDecPt = *OFF

     C                   eval      I = 10
     C                   eval      J = I - 1
     C                   eval      AIDecPos = 0

     C     Forever       doweq     forever
     C*
     C*         Check if we are out of characters
     C*
     C                   eval      I = I - 1
     C                   if        I = 0
     C                   leave
     C                   endif
     C*
     C*         See if we have found our first non-blank character
     C*
     C                   if        A9(I) = ' ' AND FlagAdj = *OFF
     C                   iter
     C                   endif
     C*
     C*         Character found, right adjust.
     C*
     C                   move      *ON           FlagAdj
     C*
     C*         Check for decimal point.
     C*
     C                   if        FlagDecPt = *OFF
     C                   if        A9(I) = '.'
     C                   eval      FlagDecPt = *On
     C                   eval      A9(I) = ' '
     C                   iter
     C                   else
     C                   eval      AIDecPos = AIDecPos + 1
     C                   endif
     C                   endif
     C*
     C*         Verify character is numeric.
     C*
     C                   eval      AINumb = %Scan(A9(I):Numbers)
     C                   if        AINumb = 0
     C                   eval      Error = *ON
     C                   eval      MfrWgtRtn = '*ERROR'
     C                   eval      $PReturn = '*INVALID'
     C                   eval      $PAIPos = I
     C                   eval      $PErrMsg = 'Invalid character found at '
     C                                        + 'position '
     C                                        + %Trim(%EditC($PAIPos:'Z'))
     C                   leavesr
     C                   endif
     C*
     C*         Move character to next right adjust position.
     C*
     C                   eval      A9(J) = A9(I)
     C                   eval      A9(I) = ' '
     C                   eval      J = J - 1

     C                   enddo
     C*
     C*      If decimal point not found, assume 2.
     C*
     C                   if        FlagDecPt = *OFF
     C                   eval      AIDecPos = 2
     C                   endif
     C*
     C*      Move weight into return parameter
     C*
     C                   movea     A9            Temp9A
     C                   move      Temp9A        Temp9N
     C                   eval      $PValueTyp = 1
     C                   if        AIDecPos = 0
     C                   eval      $PValue1 = Temp9N
     C                   else
     C                   eval      $PValue1 = Temp9N
     C     1             do        AIDecPos
     C                   eval      $PValue1 = $PValue1 / 10
     C                   enddo
     C                   endif
     C                   eval      $PAIDecPos = AIDecPos
     C                   eval      $PAIDesc = 'Weight Only'
     C                   eval      $PReturn = '*OK'

     C                   endsl

     C                   endsr

     p MfrWgt          e

     *----------------------------------------------------------------
     *  wrtDebugParms  Write out debug parms
     *----------------------------------------------------------------

     p WrtDebugParms   b
     d WrtDebugParms   pi

      /free

         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         bdvalues = 'Barcode: ' + $PBarCode;

         bdaddts = %timestamp();
         write(e) bdrec;

         bdvalues = 'Barcode Length: ' + %char(barCodeLen) + ', '
                  + 'Command: ' + %trimr($PCmd) + ', '
740fM             + 'Mfr#: ' + %char(pVen#) + ', '
                  + 'KiloLbs: ' + pKiloLbs + ', '
                  + 'Whse: ' + %char(pWhse) + ', '
                  + 'Item: ' + %trimr(pItem);

         bdaddts = %timestamp();
         write(e) bdrec;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtDebugMsg    Write out debug message
     *----------------------------------------------------------------

     p WrtDebugMsg     b
     d WrtDebugMsg     pi

      /free

         bdvalues = debugMsg;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
0000SSCC-18 Code
0001SCC-14 Code
0002SCC-14 Code Contained
0010Batch/Lot Code
0011Production Date (YYMMDD)
0013Packaging Date (YYMMDD)
0015Sell By Date (YYMMDD)
0017Expiration Date (YYMMDD)
0021Serial Number
0320Net Weight, Pounds
0310Net Weight, Kilograms
0091Interal Code 91
0092Interal Code 92
0093Interal Code 93
0094Interal Code 94
0095Interal Code 95
0096Interal Code 96
0097Interal Code 97
0098Interal Code 98
0099Interal Code 99
