650aA /copy qcopysrc,hspecs
     F*----------------------------------------------------------------
     F* ****                                     ****
     F* **** Must be compiled at V4R2M0 or later ****
     F* ****                                     ****
     F*----------------------------------------------------------------
     F*   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  IT728     Export item adjustments w/sign - Post
     F*  21 June 2000
     F*  Dave Sommerville
     F*
     F*  This program should be identical to IT726 except that it
     F*  formats the quantities into Alpha fields.
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
414 AF*    06/21/00  DAS 4.14
     F*      - Created from IT726.
     F*
415 AF*    01/25/01  DAS 4.15
     F*      - Revised to convert catchweight to alpha.
     F*
415aAF*    02/01/01  DAS 4.15a
     F*      - Forgot catchweight had a decimal so %EDITC didn't work.
     F*      - Revised to manually add negative sign.
     F*
416 AF*    12/27/01  DAS 4.16
     F*      - Added file ADJMISC.
     F*      - Revised to only write a record to the export file if
     F*        the adjustment code is defined for updating the Host
     F*        system.
     F*
500 AF*    12/06/05  MLB  5.00
     F*      - Enh: Revised program to not write adjustments to export
     F*        file that have blank item numbers.
610aA*    01/06/10  RH   610a
     *      - Enh: Revised program to NOT export '@' system adjustment
650aA*    04/21/10  RTR  650a
     *      - Enh: Added call to create license records
     *
700 A*    06/02/15  MLB  7.00
     *      - Fix: Revised program to correct error with GLPb mod that
     *         user id of person completing adjustment to not be
     *         loaded into IEBY.
700a *    03/02/15  RTR  700a
     *      - Enh: When error writing export record, write debug info and
     *        and do NOT update upload date/time.
     *
730a *    03/11/19  LMC  7.30a
     *      - Added writing UCI data to EXPFADJL for UCI tracked item.
     *      - changed to sqlrpgle
740aA*    03/09/20  LMC  7.40a
     *      - Revised GetClient to get parms 3 (client initials)
     *        and 4 (Host Sytem Id).
     *      - Added /copy to get Host System Id's
740b *    06/06/20  RTR  7.40b
     *      - Revised debug logging to not write to BFCDEBUG unless error.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Aspen Clients
     *
ASPaA*    03/09/20  LMC  ASPa
     *      - Revised to append '-ww' to item numbers, where ww is
     *        the 2-digit warehouse
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
     *
SVLaA*    09/07/09  RH   SVLa
     *      - Revised program to NOT export '@' system adjustments.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
     *
HALaA*    11/11/09  RH   HALa
     *      - Revised program to NOT export '@' system adjustments.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Crumbley Paper & Foodservice
     *
CPCaA*    06/23/11  MLB  CPCa
     *      - Revised program to fully right justify positive qty
     *        adjustments and pad on the left with a leading zero.
     *        Same mod will be made to the catchwgt field.
     *      - Revised program to place single period in pos 30 of IEMEMO.
     *        This is done so that FTP will send the full 119 bytes even
     *        IEMEMO is empty.
CPCbA*    07/11/11  MLB  CPCb
     *      - Revised program to convert cases into total eaches
     *        adjusted for items that are defined Case/Each from same item
     *        number and Brkdown 1 UoM > blanks and Brkdwn 1 Qty > 0 and
     *        Allow Entry Flag 1 = Y.  Dakota WMS needs to send back
     *        to Dynamics GP, the total qty adjusted in Eaches.
CPCcA*    12/20/12  MLB  CPCc
     *      - Revised program to only export items that have positive or
     *        negative qty.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf
     *
GLPaA*    04/24/13  RTR  GLPa
     *      - Added check for breakdown qtys on repacks to write additional
     *        export record for breakdown item.
GLPbA*    04/29/13  RTR  GLPb
     *      - Added check for user initials to use intead of user id
GLPcA*    08/23/13  RTR  GLPc
     *      - Change to check for *INACTIVE in Desc2 field also
GLPdA*    02/09/15  MLB  GLPd
     *      - Revised pgm to make 6.50a a client-specific mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: H&M Wagner
     *
HMWa *    10/15/14  RTR  HMWa
     *      - Change to split qty and weight on same adjustment to two
     *        export records. Needed by Aspen Canopy host.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Chefs Warehouse - Canopy
     *
DRYaA*    03/13/19  LMC  DRYa
     *      - Added Canopy whse to the call of IT780 to create        ional
     *        adjustment license record if this is not a UCI tracked
     *        item. UCI tracked items have their own process to add
     *        records to the expfadjl file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Colony Foods
     *
CFIa *    05/22/18  RTR  CFIa
     *      - Change to set all export codes to '15' for Colony.
CFIb *    02/15/19  RTR  CFIb
     *      - Change code '15' to '01' per Paul B.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCa *    01/09/16  RTR  PFCa
     *      - Added Presto to mod CPCc to skip adjustments with no qty.
     F*----------------------------------------------------------------
     F* Indicators
     F*
     F*  79        - EOF for ITEMADJ
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FITEMADJ   UP   E           K DISK
416 AFADJMISC   IF   E           K DISK
CPCbAFPIRITEM   IF   E           K DISK    usropn
GLPaAFkitcomp1  if   e           k disk    usropn
GLPcAFitemdsc   if   e           k disk    usropn
     FEXPFADJS  O  A E           K DISK
730aAFexpfadjl  o  a e           k disk
730aAfitemmsc   if   e           k disk
730aAflabel91   if   e           k disk
650bAFbfcdebug  o  a e           k disk
740bAfbfcdbgflg if   e           k disk    usropn
730aA*----------------------------------------------------------------
730aA*  File field data structure.
730aA*----------------------------------------------------------------
730aA
730aAD uirec         e ds                  extname(UCIINFO) inz(*EXTDFT)
730aAD uiarec        e ds                  extname(UCIINFOEXA) inz(*EXTDFT)
730aAD ulrec         e ds                  extname(ucilog) inz(*EXTDFT)
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
SVLaA /COPY QCOPYSRC,ID#saval
HALaA /COPY QCOPYSRC,ID#halsey
CPC A /COPY QCOPYSRC,ID#cpc
GLPaA /COPY QCOPYSRC,ID#glp
HMWaA /COPY QCOPYSRC,ID#hmwagne
CCP A /COPY QCOPYSRC,ID#capitol
CFIaA /copy qcopysrc,id#cfi
DRYaA /COPY QCOPYSRC,ID#dairyla
740aA /copy qcopysrc,hostsystem
PFCaA /copy qcopysrc,id#pfc
510 A*
700aA*----------------------------------------------------------------
700aA*  Program information data structure
700aA*----------------------------------------------------------------
700aAD/copy qcopysrc,c#pgminfds

730aA*----------------------------------------------------------------
730aA*  Standard SQL variables and constants
730aA*----------------------------------------------------------------
730aA
730aA /copy qcopysrc,c#stdsql

     D*----------------------------------------------------------------
     D*  Constants
     D*
     D FOREVR          C                   CONST('1')
416 AD*----------------------------------------------------------------
416 AD*  Variables
416 AD*
416 AD UPDHST          S               n
CPC AD qty1            S                   like(iaqty1)
CPC AD qty2            S                   like(iaqty2)
CPC AD qty3            S                   like(iaqty3)
CPC AD cwgt            S                   like(iacwta)
HMWaAD svcwta          S                   like(iecwta)
GLPaAD kititem         s               n
740bAd dbgflgExists    s               n
740bAd debug           s               n
740bAd debugAfter      s               n
740bAd debugBefore     s               n
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
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
     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      None
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C* Main line
416 AC*
416 AC*  Get system to update.
416 AC*
416 AC     IACODE        CHAIN     ADJMISC
416 AC                   IF        %FOUND and ADMSYS = 'D'
416 AC                   EVAL      UPDHST = *OFF
416 AC                   ELSE
416 AC                   EVAL      UPDHST = *ON
416 AC                   ENDIF
SVLa *
SVLaA*  Saval - Do not export system adj begin with '@'
SVLaAC                   if        client = saval
HALaAC                             or client = halsey
SVLaAC                   movel     iacode        temp1             1
SVLaAC                   if        temp1 = '@'
SVLaAC                   eval      updhst = *off
SVLaAC                   endif
SVLaAC                   endif
     C*
610aA*  Do not export system adj begin with '@'
610aAC                   movel     iacode        temp1             1
610aAC                   if        temp1 = '@'
610aAC                   eval      updhst = *off
610aAC                   endif
     C*  Add item adjustments to export file.
     C*
416 AC                   IF        UPDHST
500 AC                             and iaitem > ' '
CPCcA*
CPCcAC                   if            client = CPC
PFCaAC                                 or client = PrestoFoods
CPCcAC                             and iaqty1 = 0
CPCcAC                             and iaqty2 = 0
CPCcAC                             and iaqty3 = 0
CPCcA*      Only send records with qty adjusted.
CPCcAC                   goto      #skip
CPCcAC                   endif
CPCcA*
     C                   EXSR      FILIE
     *
HMWaA*      For HMWagner, write first rec with qty, then one with weight
HMWaAC                   if        client = HMWagner and
HMWaAC                             iecwta <> '000000000 ' and
HMWaAC                             (ieqty1 <> '    0 ' or
HMWaAC                              ieqty2 <> '    0 ' or
HMWaAC                              ieqty3 <> '    0 ')
HMWaAC                   eval      svcwta = iecwta
HMWaAC                   eval      iecwta = '000000000 '
HMWaAC                   write     ierec                                79
HMWaAC                   eval      ieqty1 = '    0 '
HMWaAC                   eval      ieqty2 = '    0 '
HMWaAC                   eval      ieqty3 = '    0 '
HMWaAC                   eval      iecwta = svcwta
HMWaAC                   endif
     *
     C                   WRITE     IEREC                                79
     *
700aAC                   if        *in79 = *on
700aAC                   eval      bdvalues = 'Error writing EXPFADJS record'
700aAC                             + ' for Item: ' + %trim(ieitem)
700aAC                             + ' Date: ' + %trim(%char(iedate))
700aAC                             + ' Time: ' + %trim(%char(ietime))
700aAC                   eval      bdtype = '*ERROR'
700aAC                   exsr      wrtDebug
700aAC                   goto      bottom
700aAC                   endif
730aA /free
730aA   // is this Item UCI tracked?
730aA   chain (iawhse:iaitem) itemmsc;
730aA   if not %found(itemmsc);
730aA     clear imrec;
730aA   endif;
730aA   if imltrk = 'U';
730aA     exsr filiel;
730aA     write ielrec;
730aA   endif;
730aA /end-free
650aA*
GLPaA*  For Greenleaf,
GLPaA*  Create license records for adjustment
GLPdAC                   if        client = Greenleaf
ASPaMc                             or hostSys = Aspen
ASPaDc*                            or client = Dairyland
ASPaDc*                            and clientloc = DM01
DRYaAc                             and imltrk <> 'U'
650aAC                   exsr      zzcrtlic
GLPdAC                   endif
650aAC*
650aAC*  Update item adjustment file with upload date and time.
650aAC*
650aAC                   Z-ADD     TODAY         IAUDTE
650aAC                   TIME                    IAUTIM
650aAC                   UPDATE    IAREC
GLPaA*
GLPaA*  For Greenleaf, check for breakdown qtys
GLPaAC                   if        client = greenleaf
GLPaAC                             and iaqty2 <> 0
GLPaA*
GLPaA*  Find if kit item exists at breakdown level 1
GLPaAC                   exsr      zzchkkit
GLPaA*
GLPaAC                   if        kititem
GLPaAC                   eval      ieitem = kcitem
GLPaAC                   eval      ieqty1 = %editc(iaqty2:'L')
GLPaAC                   eval      ieqty2 = %editc(iaqty3:'L')
GLPaAC                   write     ierec                                79
650aA*  Create license records for adjustment
GLPaAC                   eval      iaitem = kcitem
GLPaAC                   eval      iaqty1 = iaqty2
GLPaAC                   eval      iaqty2 = iaqty3
650aAC                   exsr      zzcrtlic
GLPaAC                   endif
GLPaA*
GLPaAC                   endif
GLPaAC                   goto      bottom
650aA*
416 AC                   ENDIF
CPCcAC     #skip         tag
     C*
     C*  Update item adjustment file with upload date and time.
     C*
     C                   Z-ADD     TODAY         IAUDTE
     C                   TIME                    IAUTIM
     C                   UPDATE    IAREC
     C*
     C     BOTTOM        TAG
700aACLR                 eval      bdvalues = 'Item Adjustment Export complete.'
700aACLR                 eval      bdtype = '*STATUS'
740bACLR                 if        debug
740bAC                             or debugAfter
700aACLR                 exsr      wrtDebug
740bACLR                 endif
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     CSR   *INZSR        BEGSR
610 A*
610 A* Get client id.
610 A*
510 AC                   call      'GETCLIENT'
510 AC                   parm                    client           10
510 AC                   parm                    clientloc        10
740aAC                   parm                    cliInit           3
740aAC                   parm                    hostSys          10
     *
740bA /free
740bA    open(e) bfcdbgflg;
740bA    if %error;
740bA      dbgflgExists = *off;
740bA    else;
740bA      dbgflgExists = *on;
740bA    endif;
740bA    if dbgflgExists;
740bA      chain(e) (#pgm) bfcdbgflg;
740bA      if %found(bfcdbgflg);
740bA        select;
740bA          when bdfflag = 1;
740bA            debug = *on;
740bA            debugAfter = *on;
740bA          when bdfflag = 2;
740bA            debug = *on;
740bA            debugBefore = *on;
740bA          when bdfflag = 3;
740bA            debug = *on;
740bA            debugBefore = *on;
740bA            debugAfter = *on;
740bA        endsl;
740bA      endif;
740bA    endif;
740bA /end-free
740bAC                   if        debug
740bAC                             or debugBefore
700aAC                   eval      bdvalues = 'Running Item Adjustment Export'
700aAC                   eval      bdtype = '*STATUS'
700aAC                   exsr      wrtDebug
740bAC                   endif
     *
CPCbAC                   if        client = CPC
GLPaAC                             or client = greenleaf
CPCbAC
CPCbAC                   if        not %open(piritem)
CPCbAC                   open      piritem
CPCbAC                   endif
CPCbAC
CPCbAC
GLPcAC                   if        not %open(itemdsc)
GLPcAC                   open      itemdsc
GLPcAC                   endif
GLPcAC
CPCbAC                   endif
CPCbA*
CPCbA*   Define full key for PIRITEM file.
CPCbA*
CPCbAC     keyit         klist
CPCbAC                   kfld                    iawhse
CPCbAC                   kfld                    iaitem
GLPcA*
GLPcA*   Define full key for ITEMDSC file.
GLPcA*
GLPcAC     keyix         klist
GLPcAC                   kfld                    itwhse
GLPcAC                   kfld                    ititem
GLPaA*
GLPaA*   Define partial key for KITCOMP1 file.
GLPaA*
GLPaAC     keykit        klist
GLPaAC                   kfld                    iawhse
GLPaAC                   kfld                    iaitem
GLPaA*
GLPaA*   Define full key for PIRITEM file.
GLPaA*
GLPaAC     keyitk        klist
GLPaAC                   kfld                    kcwhse
GLPaAC                   kfld                    kcitem
     C*
     C*  Convert today's date into century format.
     C*
     CSR                 MOVE      '*CURCMD '    $CVCMD
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD8O        TODAY             8 0
     C*
GLPaA*
GLPaA* Open KITCOMP1 file for Greenleaf.
GLPaAC                   if        client = greenleaf
GLPaAC                             and not %open(kitcomp1)
GLPaAC                   open      kitcomp1
GLPaAC                   endif
GLPaA*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  FILIE    Fill export fields.
     C*
     CSR   FILIE         BEGSR
CPCbA*
CPCbAC                   if        client = cpc
CPCbA*
CPCbAC     keyit         chain     piritem
CPCbAC                   if        not %found(piritem)
CPCbAC                   eval      itum1  = '  '
CPCbAC                   eval      itumq2 = 0
CPCbAC                   eval      itum2  = '  '
CPCbAC                   eval      itflg1 = 'N'
CPCbAC                   eval      itumq3 = 0
CPCbAC                   eval      itflg2 = 'N'
CPCbAC                   eval      itcwgt = 'N'
CPCbAC                   eval      itswgt = 0
CPCbAC                   endif
CPCbA*
CPCbAC                   endif
CPCbA*
     C*
     C*  Initialize record
     C*
     CSR                 CLEAR                   IEREC
     C*
     C*  Move fields from item adjustment file to export file.
     C*
     CSR                 Z-ADD     IAWHSE        IEWHSE
     CSR                 MOVE      IAITEM        IEITEM
     CSR                 Z-ADD     IADATE        IEDATE
     CSR                 Z-ADD     IATIME        IETIME
GLPbDC**                 MOVE      IABY          IEBY
GLPbA*
GLPbAC                   if        client = Greenleaf
GLPbA*
GLPbA*      Retrieve user number from PIR User table.
GLPbAC                   eval      #buyerid = iaby
GLPbAC                   call      'GETUSER'
GLPbAC                   parm                    #buyerid         10
GLPbAC                   parm      0             #whse             3 0
GLPbAC                   parm      0             #emp#             5 0
GLPbAC                   parm                    #fnam            15
GLPbAC                   parm                    #init             1
GLPbAC                   parm                    #lnam            20
GLPbAC                   parm                    #whdp             5
GLPbAC                   parm                    #styp             1
GLPbAC                   parm                    #shft             6
GLPbAC                   parm                    #crew             6
GLPbAC                   parm      0             #nhrs             3 1
GLPbAC                   parm                    #rtn              8
GLPbA*
GLPbA*      Update user ID for item.
GLPbAC                   if        #rtn = '*OK'
GLPbA*
GLPbAC                   if        %subst(#lnam:18:3) = *blanks
GLPbAC                   eval      ieby = iaby
GLPbAC                   else
GLPbAC                   eval      ieby = %subst(#lnam:18:3)
GLPbAC                   endif
GLPbA*
GLPbAC                   endif
700 A*
700 AC                   else
700 A*
700 MC                   MOVE      IABY          IEBY
GLPbAC                   endif
GLPbA*
213 ACSR                 MOVE      IAWHDP        IEWHDP
213 ACSR                 MOVE      IADISP        IEDISP
415 DC**                 Z-ADD     IACWTA        IECWTA
     C*
415aDC**                 eval      IECWTA = %editc(IACWTA:'L')
415aACSR                 MOVE      *BLANKS       IECWTA
415aACSR   IACWTA        IFGE      0
415aACSR                 MOVEL     IACWTA        IECWTA
415aACSR                 ELSE
415aACSR                 Z-SUB     IACWTA        IACWTA
415aACSR                 MOVEL     IACWTA        IECWTA
415aACSR                 MOVE      '-'           IECWTA
415aACSR                 Z-SUB     IACWTA        IACWTA
415aACSR                 ENDIF
CPC AC*
CPC AC                   if        client = CPC
CPCbA*
CPCbA*      Convert into Total Eaches and load into OEDQ1.
CPCbAC                   if        itum2 > ' '
CPCbAC                             and itumq2 > 0
CPCbAC                             and itflg1 = 'Y'
CPCbAC                   eval      qty1 = iaqty2 + (iaqty1 * itumq2)
CPCbAC                   else
CPCbAC                   eval      qty1 = iaqty1
CPCbAC                   endif
CPCbAC                   eval      iaqty2 = 0
CPCbA*
CPC AC*
CPC AC*      Pad all positive values so they are fully right justified.
CPCbDC*                  if        iaqty1 >= 0
CPCbMC                   if        qty1 >= 0
CPCbDC*                  eval      ieqty1 = '0' + %editc(iaqty1:'X')
CPCbMC                   eval      ieqty1 = '0' + %editc(qty1:'X')
CPC AC                   else
CPC AC                   eval      qty1 = %abs(iaqty1)
CPC AC                   eval      ieqty1 = %editc(qty1:'X') + '-'
CPC AC                   endif
CPC AC*
CPC AC                   if        iaqty2 >= 0
CPC AC                   eval      ieqty2 = '0' + %editc(iaqty2:'X')
CPC AC                   else
CPC AC                   eval      qty2 = %abs(iaqty2)
CPC AC                   eval      ieqty2 = %editc(qty2:'X') + '-'
CPC AC                   endif
CPC AC*
CPC AC                   if        iaqty3 >= 0
CPC AC                   eval      ieqty3 = '0' + %editc(iaqty3:'X')
CPC AC                   else
CPC AC                   eval      qty3 = %abs(iaqty3)
CPC AC                   eval      ieqty3 = %editc(qty3:'X') + '-'
CPC AC                   endif
CPC AC*
CPC AC                   if        iacwta >= 0
CPC AC                   eval      iecwta = '0' + %editc(iacwta:'X')
CPC AC                   else
CPC AC                   eval      cwgt = %abs(iacwta)
CPC AC                   eval      iecwta = %editc(cwgt:'X') + '-'
CPC AC                   endif
CPC AC*
CPC AC                   else
CPC AC*
     CSR                 eval      IEQTY1 = %editc(IAQTY1:'L')
     CSR                 eval      IEQTY2 = %editc(IAQTY2:'L')
     CSR                 eval      IEQTY3 = %editc(IAQTY3:'L')
CPC AC                   endif
CPC AC*
     C*
     CSR                 MOVE      IACODE        IECODE
     CSR                 MOVE      IAMEMO        IEMEMO
CFIaA
CFIaA /free
CFIaA   if client = Colony;
CFIbD   //iecode = '15';
CFIbM     iecode = '1 ';
CFIaA   endif;
CFIaA /end-free
CPC AC*
CPC AC                   if        client = CPC
CPC AC*      Force period in last space so full rcdfmt will xfr via FTP.
CPC AC                   eval      iememo = %Replace('.': iememo:30:1)
CPC AC                   endif
CPC AC*
     C*
     CSR                 ENDSR
730aA*----------------------------------------------------------------
730aA*
730aA*  FILIEL   Fill export fields - lot(uci tracking)
730aA*
730aAC     filiel        begsr
730aA*
730aA*  Initialize record
730aA*
730aAC                   clear                   ielrec
730aA*
730aA*  Move fields from item adjustment file to export file.
730aA*
730aAC                   eval      ielwhse = iawhse
730aAC                   eval      ielitem = iaitem
730aAC                   eval      ieldate = iadate
730aAC                   eval      ieltime = iatime
730aAC                   eval      ielby = iaby
730aAC                   eval      ielwhdp = iawhdp
730aAC                   eval      ieldisp = iadisp
730aAc                   eval      ielqty1 =  %editc(iaqty1:'L')
730aAc                   eval      ielqty2 =  %editc(iaqty2:'L')
730aAc                   eval      ielqty3 =  %editc(iaqty3:'L')
730aAc** need to get the label file for the link to ucilog
730aA /free
730aA   chain (iawhse: iaitem: iadate: iatime) label91;
730aA   if %found(label91);
730aA     // now I need the ucilog record
730aA     exec sql select * into :ulrec from ucilog
730aA               where ulwhse = :iawhse
730aA                 and ullbl# = :lblbl#;
730aA     if sqlstt = sqlSuccess;
730aA       exec sql select * into :uirec from uciinfo
730aA                 where uiwhse = :ulwhse
730aA                   and uiuci = :uluci;
730aA       if sqlstt = sqlSuccess;
730aA         exec sql select * into :uiarec from uciinfoexa
730aA                   where uiaaddts = :uiaddts
730aA                     and uiaucilcns = :uiucilcns
730aA                     and uialcns = :uilcns;
730aA         if sqlstt = sqlSuccess;
730aA           // finally now I can write the IELLCNS field
730aA           // I'm using the same logic we use in PO726 to
730aA           // hierachy of the data for the IELLCNS field
730aA           select;
730aA             when uiserial <> ' ';
730aA               iellcns = uiserial;
730aA             when uialot <> ' ';
730aA               iellcns = uialot;
730aA             when %subst(uiuci:1:3) = '99I';
730aA               iellcns = uiuci;
730aA             other;
730aA               iellcns = ullcns;
730aA               ielolcns = uiaolcns;
730aA           endsl;
730aA         else;
730aA           clear uiarec;
730aA         endif;
730aA       else;
730aA         clear uirec;
730aA       endif;
730aA     endif;
730aA   else;
730aA     clear lbrec;
730aA   endif;
730aA /end-free
730aa
730aA*
730aAC                   endsr
700aA*----------------------------------------------------------------
700aA*  wrtDebug    Write out debug record
700aA*----------------------------------------------------------------
700aA
700aA /free
700aA  begsr wrtDebug;
700a
700a     bdaddts = %timestamp();
700a     bdaddpgm = #pgm;
700a     bdaddcusr = #curruser;
700a     bdaddjusr = #user;
700a     bdaddjob = #job;
700a     bdaddnbr = #jobnbr;
700a
700a     write(e) bdrec;
700a
700a   endsr;
700a  /end-free
GLPaA*
GLPaA*----------------------------------------------------------------
GLPaA*
GLPaA*  ZZCHKKIT   Check for Kit item at breakdown 1
GLPaA*
GLPaAC     zzchkkit      begsr
GLPaA*
GLPaAC                   eval      kititem = *off
GLPaAC     keykit        setll     kitcomp1
GLPaAC                   read      kitcomp1
GLPaA*
GLPaAC                   dow       not %eof()
GLPaAC                             and kccitm = iaitem
GLPaAC                   if        kcqty2 = 1
GLPaA*
GLPaA*  Check for inactive item
CPCbAC     keyitk        chain     piritem
CPCbAC                   if        not %found(piritem)
CPCbAC                             or itdesc = *blanks
CPCbAC                   eval      itdesc = '*INACTIVE'
CPCbAC                   endif
GLPaA*
GLPcAC     keyix         chain     itemdsc
GLPcAC                   if        not %found(itemdsc)
GLPcAC                   eval      ixdsc2 = *blanks
GLPcAC                   endif
GLPcA*
CPCbAC                   if        itdesc <>'*INACTIVE'
GLPcAC                             and %subst(ixdsc2:8:9) <> '*INACTIVE'
GLPaAC                   eval      kititem = *on
GLPaAC                   leave
GLPaAC                   endif
GLPaAC                   endif
GLPaA*
GLPaAC                   read      kitcomp1
GLPaAC                   enddo
GLPaA*
GLPaAC                   endsr
PAK A*
GLPaA*----------------------------------------------------------------
GLPaA*
GLPaA*  ZZCRTLIC   Create license export record
GLPaA*
GLPaAC     zzcrtlic      begsr
GLPaA*
650aA*  Create license records for adjustment
650aAC                   call      'IT780'
650aAC                   parm                    iawhse
650aAC                   parm                    iaitem
650aAC                   parm                    iadate
650aAC                   parm                    iatime
650aAC                   parm                    iaby
650aAC                   parm                    iawhdp
650aAC                   parm                    iadisp
650aAC                   parm                    iaqty1
650aAC                   parm                    iaqty2
650aAC                   parm                    iaqty3
GLPaA*
GLPaAC                   endsr
PAK A*
