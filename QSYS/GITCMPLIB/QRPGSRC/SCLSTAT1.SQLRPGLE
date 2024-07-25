      /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*no)
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  SCLSTAT1    Retrieve Scale Weight and Status
      *  03 March 2017
      *  Kenneth Elder
      *
      *  Revisions:
      *
710 A*    03/03/17  KDE  7.10
     *      - Created.
     *        Copy of SCLSTAT with parm RMUCI
710aA*    03/06/17  KDE  7.10a
     *      - Setup checks to ensure MultiDay Work Order can
     *        be closed.  Also setup where this can be called
     *        from M16400F to close Work ORder when Work Order
     *        is associated with MultiDay line to execute same
     *        code here found in closeMult.  This is also called
     *        when user generates Work ORder Max and returns on
     *        MultiDay Work ORder
     *
710dA*     03/07/17  TAB  7.10d
     *      - Enh: Code change to handle use of I99 UCI
     *      - Fix: Force Weight values from DRIUCIINFO command
     *        when GS1 99I is scanned
     *      - Enh: Added new command %CKUCISPLT
710eA*     03/10/17  KDE  7.10e
     *      - Enh: Get Expiration date for Raw Material Line Slot
     *             to apply on Box Breaker putaway RCV slot
710fA*     05/09/17  KDE  7.10f
     *      - Fix: Close Work Order short when nothig produced
     *        and user clicks close
710gA*     06/21/17  KDE  7.10g
     *      - Fix: Normally a Box Breaker transaction will add
     *        Breakdowns and substract a case.  When you return
     *        to cancel it was adding case back from Retrun button
     *        and also adding case at end of cancel.  This mod
     *        remarks out the plus adjust case at bottom of
     *        bbCancel.
     *      - Enh:  Change to not subtract full case quantity
     *        when bbcomplte command is sent. It has been changed
     *        where it is only completed from M173xx instead of
     *        M177xx and the process from M177xx has already
     *        reduced the case
710hA*     07/11/17  KDE  7.10h
     *      - Enh: Change Box Breaker select to record unique Case
     *        number to work around Box Breaker non unique case issues
710iA*     07/11/17  KDE  7.10i
     *      - Enh: Add command *opntrans to look for any non-completed
     *        transactions in UCISPLITS.  If they exist warn the user
     *        with a message box for the last one
710jA*     07/14/17  KDE  7.10j
     *      - Enh: Add code to used current date for Production Date
     *        if one does not exist and warehouse defined to only use
     *        Box Breaker
     *      - Also pass back net number of break downs generated
     *        compared against item breakdown definition when Box Breaker
     *      - Send back zeros to pRemCnt when BXB and no Brk Dwn1
     *        And do not try to reduce slot when box breaker no bd1
     *      - Also send back lblOnly for Slot and License when Box
     *        Breaker and no breakdown since no inventory transacted
710kA*     07/06/17  KDE  7.10k
     *      - Enh: Add command for Scale Screens to send
     *        start and end labor transactions
710lA*     09/22/17  KDE  7.10l
     *      - Enh: Add code to support option for Standard Labor
     *        Transactions Only
720 A*     01/19/18  KDE  7.20
     *      - Enh: Add code to allow Wip items be deleted from
     *        LIN slots instead of PAR slots since they are
     *        originally placed in LIN slots instead of PAR slots
     *      - Set Mfg Line for CLSWO (Close Work Order)
720aA*    04/05/18  KDE  7.20a
     *      - Replace double quote so json will work
720bA*    08/01/16  LMC  7.20b   reserved
     *      - Enh: UCI Tracking.
730aA*     01/30/19  KDE  7.30a
     *       - Enh: Recompile due to PWRKORD change
     *       - Fix: Change mod 7.20 to determine WIP items based on type "C"
     *         versus item number beginning with WIP
740 A*     03/03/20  KDE  7.40
     *       - Enh: Add tweaks for Label Generator only
740aA*     08/14/20  KDE  7.40a
     *       - Fix: Send respective slot for deletes so it will
     *         use the dates from that slot instead of using today
     *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------
     Fupc2      if   e           k disk
700 AFupc       if   e           k disk
416bAF                                     rename(uprec:uprec1)
     Foptions   if   e           k disk
     Fplined    if   e           k disk    rename(plrec:plrec1)
     fitemprd   if   e           k disk
     fpbom      if   e           k disk
710aAfslot12    if   e           k disk    rename(slrec:slrec12)
700 Afprddate1  uf   e           k disk
     fpwrkord   if   e           k disk
710cAfpwrkordru if   e           k disk
700 Aflabel     uf a e           k disk
700 Aflicense   uf a e           k disk
710kAfTask      if   e           k disk
     Fpiritem   if   e           k disk
416bAF                                     rename(itrec:itrec1)
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

700 A*----------------------------------------------------------------
700 A*  File data data structure
700 A*----------------------------------------------------------------

700 AD plrec         E ds                  extname(prodlog) inz(*EXTDFT)
700 AD slrec         E ds                  extname(slot) inz(*EXTDFT)
710cAd ursum           ds
     d   ursumrmi              1     15
710cAd   ursumqn              16     20  0
710cAd   ursumq1              21     25  0
710cAd   ursumq2              26     30  0
710cAd   ursumqp              31     39  4

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

     d*copy qcopysrc,c#pgminfds
      /copy qcopysrc,c#stdvar
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#PROD
      /COPY *libl/qcopysrc,C#UCIINFO
      /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Convert Barcode Parms
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CVTPARMS
700 A /COPY *libl/qcopysrc,C#BARCODE

      *----------------------------------------------------------
      * Begin C#PGMINFDS - Program information data structure
      *  12/20/02  DAS  4.16  Created
      *  07/12/08  DAS  6.00a
      *    - Added #curruser, #prog, #jobn
      *  03/02/11  MLB  6.40
      *    - Added #parms
      *----------------------------------------------------------

     D pssrflag        s               n

     D                sds
     D  #pgm                   1     10
     D  #prog                  1     10
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #routine              29     36
     D  #parms                37     39
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobnbr              264    269
     D  #jobn                264    269
     D  #jobdate             276    281  0
     D  #jobtime             282    287  0
     D  #curruser            358    367

      *** End C#PGMINFDS ***

      *----------------------------------------------------------
      *  Prototypes
      *----------------------------------------------------------
650aA /copy qcopysrc,p.wrtsessl
700 AD @addtr          c                   const('ADDSTDTRN')

      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

     D  pSessId        s             40    varying
     D  pUser          s             10    varying
     D  pPgm           s             20    varying
     D  pStation       s              2    varying
     D  pType          s              1    varying
     D  pDest          s              1    varying
     D  pTare          s              9p 3
     D  pLblc          s              5p 0
     D  pLsts          s             20    varying
     D  pItem          s             15    varying
     D  pMqty          s              4p 0
     D  pMwgt          s              7p 2
     D  pCust          s             11p 0
     D  pOrdNbr        s              7p 0
     D  pWo            s             13    varying
700 AD  pUCI           s            100    varying
700 AD  pDisp          s             12    varying
700 Ad  pBxbp          s              1    varying
700 Ad  pBxbs          s              1    varying
710bAD  pRmUci         s            100    varying
     D  pOutStr        s           1984    varying
700 Ad  sfLcns         s             15
700 Ad  stLcns         s             15

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------
     *
     *  Data Structure to hold previous labe records to be returned
     *     via the JSON string generated at end of loop
     *
     D                 ds
     D aryRtnLbl                     87    dim(10)
     D  rtncnt                        4p 0 overlay(aryRtnLbl:*next)
     D  rtnstat                       1    overlay(aryRtnLbl:*next)
     D  rtnWeght                      9p 2 overlay(aryRtnLbl:*next)
     D  rtnitm                       15    overlay(aryRtnLbl:*next)
     D  rtnsts                       20    overlay(aryRtnLbl:*next)
     D  rtncus                       11p 0 overlay(aryRtnLbl:*next)
     D  rtndisp                      12    overlay(aryRtnLbl:*next)
     D  rtnlcns                      15    overlay(aryRtnLbl:*next)

720aAd pos             s              2  0
720aAd dblqte          s              1    inz('"')
720aAd rpldblqte       s              2    inz('\"')
     d bugstate        s              5  0
     D EachAdjust      s               n
     d chkDriErr       s             60
700 AD ckupc           s             20
     D ck4err          s              1
710kAd curtrn#         s              7  0
     D curdate         s              8  0
     D CurrStamploc    s               z
     D CurrStampmn     s               z
     D CurrStampskt    s               z
     D CurrStampsys    s               z
     D dbgflgExists    s               n
     D debug           s               n
     D demowgt         s              9  3
     D demowgtext      s              9  0
     d eachCnt         s              5  0
     D expd            s              8  0
     D FirstSent       s               n
     d firstSplit      s               n
710cAd hldRMI          s             15
     D hldLastLabel    s             20
     d humanLcns       s             15
     D itemColor       s             20
     D itemdesc        s             40
     d jultoDay        s             12
     d labelcount      s              5  0
     d licComplete     s               n
     d lhmfgno         s              3  0
     D logText         s            100
     D lstary          s              3  0 inz(0)
740 Ad netwgt          s              9  2
     D Non_Num_Posn    S              2  0 Inz(*Zero)
     d NullInds        s              5i 0 inz(-1)
     D Numbers         S             11    Inz(' 0123456789')
     d numrecs         s              6  0
     D outWgt          s              9  0
710 AD outTare         s              9  0
     D $pbat           s              7  0
     d openMult        s              1
     d pCaseWgt        s              9  3
     D $pindt          s              8  0
     D pLhlsts         s             20
     d prdSlot         s             12
     d pRemWgt         s              9  3
710jAd pRemCnt         s              5  0
710hAD pCaseSeq        s              5  0
710kAd PrimTask        s              6
     D pttrn#          s              7  0
     d svTran          s              7  0
     d pTrn#           s              7  0
     D popcode         s             10
     d pTrnCnt         s              5  0
     d pWgtGen         s              9  3
710jAd pCntGen         s              5  0
     D rc              s              3  0 inz(0)
     d resetflag       s              1
     d returnUCI       s            100
710iAd opntrans        s             50
710hAd returnSeq       s              5  0
     D #rcvarea        s              6
     d reverseCase     s               n
     d rtnMake         s              4  0
     d rtnPriItm       s             15
     d rtnPriQty       s              4  0
     d rtnSecQty       s              4  0
     D saveVer#        s                   like($ppver#)
     D SkipFirstRead   s               n
     D StatDesc        s             60
     D SqlStmt         s           2000    inz(' ')
     D sqlSuccess      c                   '00000'
710lAD StdOnly         s              1
710bAd sumQtyn         s              5  0
710bAd sumQty1         s              5  0
710bAd sumQty2         s              5  0
710bAd sumQtyp         s              5  0
710bAd sumWeght        s              9  3
     D today           s              8  0
     d TodayJul        s              5
710bAd uciValid        s              1
     d unAssignExists  s               n
     D wherelabel      s            300
     d wkCrtProdErr    s             15
     d wkError         s               n
     d wkRerr2         s             50
     d wrkIso          s               d   Inz(*sys)
     d wrkMfgno        s              2  0
     D zmsflag         s               n

      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *------------------------------------------------------------------
     D $MDT            DS
     D  ERRMSG                 1     50
     D                 DS
     D  $EC                    1      2P 0

     *----------------------------------------------------------------
     *  *PROD  -  Production Option Settings
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPLBRP  -  Reprint production labels
     *    OPLBDL  -  Delete Production labels
     *    OPVARM  -  Use Variable Measure for generated GTIN
     *    OPIMPGTIN  Import GTIN's from Customer
     *    OPGENGTIN  Generate GTIN's from customer item number
     *    OPPRDDTE-  Include Production date in GS1
     *    OPPCKDTE-  Include Package date in GS1
     *    OPEXPDTE-  Include Expiration Date in GS1
     *    OPNETLBS-  Include Net pounds in GS1
     *    OPLBSDEC-  Number of decimals for Net pounds
     *    OPNETKG -  Include Net kilograms in GS1
     *    OPKGDEC -  Number of decimals for Net kilograms
     *
     *----------------------------------------------------------------

     D opdata          ds
     D  oplbrp                 1      1
     D  oplbdl                 2      2
     D  opvarm                 3      3
     D  opimpgtin              4      4
     D  opgengtin              5      5
     D  opprddte               6      6
     D  oppckdte               7      7
     D  opexpdte               8      8
     D  opnetlbs               9      9
     D  oplbsdec              10     10  0
     D  opnetkg               11     11
     D  opkgdec               12     12  0
700 AD  opbxbu                24     24
700 AD  opbxbp                25     25
700 AD  opbxbs                26     26
730aAd  opUseCost             30     30
     D  optend               117    117

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------

     D  dqdata         s           1024
     D  dqkeylen       s              3  0 inz(36)
     D  dqlen          s              5  0
     D  dqorder        s              2
     D  dqwait         s              5  0
     d  dqname         s             10
     d  dqlib          s             10

     Ddqkey            ds            15
     D dqwhse                         3p 0
     D dqScale                       13

      *----------------------------------------------------------
      *  Standard SQL variables and constants
      *----------------------------------------------------------

      *copy qcopysrc,c#stdsql

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     D screc         E Ds                  Extname(Scale)
     D lhhst         E Ds                  Extname(prdlbhist)
     D custrec       E Ds                  Extname(Custmast)
     D itrec         E Ds                  Extname(Piritem)
     D ohrec         E Ds                  Extname(OrdH)
700 AD usrec         E Ds                  Extname(UCISPLITS)

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId      Session Id of caller
     *      pUser        User making call
     *      pPgm         Dictionary and Program calling
     *      pStation     Toledo Scale Station Id
     *      pType        Automatic or Manual Label creation
     *      pDest        Par Stock or Customer Demand Stock
     *      pTare        Tare weight for packaging
     *      pLblc        Label count
     *      pLsts        Last Serial number used on label
     *      pItem        Item number for current label reuqest
     *      pMqty        Manual Quantity requested
     *      pMwgt        Manual Weight entered
     *      pCust        Customer Number for label being printed
     *      pOrdNbr      Specific Customer Order selected if specified
     *      pWo          Work Order Number associated with transaction
700 A*      pUCI         Box Breaker Case UCI
700 A*      pDisp        Box Breaker Pick Slot
700 A*      pBxbp        Box Breaker from Pick Slot (Y/N)
700 A*      pBxbs        Box Breaker System Gen License (Y/N)
710bA*      pRmUci       Raw MAterial UCI for Dry Age Production
     *      pOutStr      Return string with JSON data
     *
     *    Returned Parameters
610aA*      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *Entry        plist
650aAc                   parm                    pSessId
650aAc                   parm                    pUser
650aAc                   parm                    pPgm
     c                   parm                    pStation
610aAc                   parm                    pType
     c                   parm                    pDest
     c                   parm                    pTare
     c                   parm                    pLblc
     c                   parm                    pLsts
     c                   parm                    pItem
     c                   parm                    pMqty
     c                   parm                    pMwgt
     c                   parm                    pCust
     c                   parm                    pOrdNbr
     c                   parm                    pWo
700 Ac                   parm                    pUCI
700 Ac                   parm                    pDisp
700 Ac                   parm                    pBxbp
700 Ac                   parm                    pBxbs
710bAc                   parm                    pRmUci
     c                   parm                    pOutStr

      /free
700eA       // Set SQL default parms
700eA       exec sql
700eA         set Option Commit=*none, Dlyprp=*Yes,
700eA                    Closqlcsr = *ENDMOD;

          *inlr = *on;
          exsr init;
710bA
710bA     // this code should run every pass if RM UCI is passed
710bA     // has to set whether UCI valid on each pass.  When it
          // was only running with command *ucimulti the UCIVALID
          // span tag in HTML was getting set to "N" for no and
          // user would get RM Uci not valid when in fact it was valid
710bA     if pRmUci <> *blanks;
710bA        exsr rtvScale;
710bA        exsr uciMultiDay;
710bA     endif;
710bA
          exsr chkDriError;
700 A     if pUCI <> *blanks
710bA        and pBxbs <> *blanks
710bA        and pBxbp <> *blanks;
             puci = %trim(puci);
700 A        pTrn# = pOrdNbr;
710hA        pCaseSeq = pCust;
700 A        pOrdNbr = 0;
700 A        exsr cvtBarcode;
700 A        exsr CalcRemWgt;
             exsr TrnCount;
700 A     endif;
710iA
          select;
700 A        when Plsts = '*bbreset';
700 A           exsr rtvScale;
700 A           exsr updUCIINFO;
700 A        when Plsts = '*licset';
700 A           exsr rtvScale;
700 A           exsr updLicense;
710kA        when Plsts = '*STRLAB' or
710kA             Plsts = '*CLSLAB';
730aD           //if stdOnly = 'N';
730aD           if opUseCost='Y' and stdOnly = 'N';
710kA              curtrn# = pCust;
710kA              pCust = *zeros;
710kA              PrimTask = pItem;    // Pass proper task in Item Number parm
710kA              pItem = *blanks;     // then blank out Item Number
710kA              exsr rtvScale;
710kA              exsr GenerateLabor;
710lA           endif;
             when Plsts = '*alter';
                exsr rtvScale;
                exsr genAlterItems;
710iA        when Plsts = '*opntrans';
710iA           exsr rtvScale;
710iA           exsr opnSplitsRec;
710cA        when Plsts = '*closemult';
710cA           exsr rtvScale;
                // if coming from Work Order screen and not a MultiDay Line
                // Work Order then simply Close Work ORder, do not go thru
                // End of Day process as well in routine CloseMult
                if inDryAge = 'Y';
710cA              exsr CloseMult;
                   // If closeMult routine returns an E(Error) we return
                   // "E" to SCLSTAT1 and it will not return to first
                   // scale screen to select another activity.  If "N"
                   // is returned no errors occured in the close and
                   // SCLSTAT1 will return to first Scale screen to
                   // process another Work ORder
                   if chkDriErr = *blanks;
                      openMult = 'N';    // no errors were found
                   else;
                      openMult = 'E';    // error(s) were found
                   endif;
                else;
                   // Simply Close pWrkOrd and pWrkOrdr records
710cA              exsr CloseWo;
                endif;
             when Plsts = '*demo';
                exsr rtvScale;
                exsr DemoWeight;
                exsr sndDtaq;
710bA        when Plsts = '*uciMulti';
710bA           // code being ran in if above
700 A        when Plsts = '*ucisel';     // update scale record with BB UCI
700 A           exsr rtvScale;
700 A           exsr UciSelect;
700 A        when Plsts = '*bbcancel';   // Reverse Box Breaker Transaction
700 A           exsr rtvScale;
700 A           exsr bbCancel;
                exsr TrnCount;
700 A        when Plsts = '*bbcomplte'  // Complete Box Breaker Transaction
                or Plsts = '*bbcompant';
                if pBxbp='N' and pBxbs='N';
                   humanLcns = pItem;
                else;
                   humanLcns = ' ';
                endif;
700 A           exsr rtvScale;
700 A           exsr bbComplte;
             when Plsts = '*reprint';
                plhlsts = pItem;
                exsr LabelReprint;
             when Plsts = '*manual';
                exsr manualLabel;
                exsr WoLvlFlds;
             when Plsts = '*blkser';
                exsr rtvScale;
                exsr sndDtaq;
             when Plsts = '*prtlabel';
                exsr rtvScale;
                exsr sndDtaq;
             when Plsts = '*nolabel';
                exsr rtvScale;
                exsr sndDtaq;
             when Plsts = '*close';
                exsr rtvScale;
                exsr sndDtaq;
             when Plsts = '*delete';
                exsr rtvScale;
                plhlsts = pItem;
                exsr deleteLabel;
                exsr WoLvlFlds;
             other;
                exsr autoLabel;
                exsr WoLvlFlds;
          endsl;

        // no need to send back previous label information
        // for either blanking the serial number on the scale,
        // reprinting an existing serial number of deleting
        // a current serial number

        if Plsts <> '*blkser'
           and Plsts <> '*reprint'
           and Plsts <> '*alter'
700 A      and Plsts <> '*ucisel'
700 A      and Plsts <> '*licset'
700 A      and Plsts <> '*bbcancel'
700 A      and Plsts <> '*bbreset'
           and Plsts <> '*delete'
           and Plsts <> '*prtlabel'
           and Plsts <> '*nolabel'
           and Plsts <> '*close'
710iA      and Plsts <> '*opntrans'
           and Plsts <> '*demo';

          // do not update scale for *closemult command
          // but send back other pieces of information
710aA     if pLsts <> '*closemult';
             exsr updScale;
710aA     endif;

          // Create json string with appropriate information

         select;
           when scstat = 'X';
             itemColor = 'red';
             StatDesc = 'Scale not communicating';
           when scstat = 'C';
             itemColor = 'red';
             StatDesc  = 'Scale communicating';
           when scstat = 'I';
             itemColor = 'red';
             StatDesc  = 'Scale being initialized';
           when scstat = 'W';
             itemColor = 'blue';
             StatDesc  = 'Scale communicating';
           other;
             StatDesc  = 'Status unknown';
             itemColor = '#B0B0B0';
          endsl;

720aA             // if item description has double quote replace with
720aA             // \".  Causes json to fail on return with extra
720aA             // double qoute
720aA             pos = %scan(dblqte: itemdesc);
720aA             dow pos > 0;
720aA               itemdesc = %replace(rpldblqte: itemdesc: pos:
720aA                          %len(dblqte));
720aA               if (pos+%len(rpldblqte) > %len(itemdesc));
720aA                 pos = 0;
720aA               else;
720aA                 pos = %scan(dblqte: itemdesc:
720aA                            pos+%len(rpldblqte));
720aA               endif;
720aA             enddo;

740 A            // get net weight of tare
740 A            monitor;
740 A              if plsts = '*manual';
740 A                if pMwgt<>0;
740 A                  netWgt = pMwgt - sctare;
740 A                endif;
740 A              else;
740 A                if scWeght<>0;
740 A                  netWgt = scWeght - sctare;
740 A                endif;
740 A              endif;
740 A
740 A               if netWgt < 0 or netwgt > 9999;
740 A                netWgt=0;
740 A              endif;
740 A            on-error;
740 A              netwgt=0;
740 A            endmon;

          // Put together JSON string
          pOutStr = '{'
                 +  '"scid":"'  + %trimr(scid) + '",'
                 +  '"openMult":"'  + %trimr(openMult) + '",'
                 +  '"scp":"'  + %trimr(%char(scport)) + '",'
                 +  '"sci":"'  + %trimr(sclitm) + '",'
                 +  '"itemd":"'  + %trimr(itemdesc) + '",'
                 +  '"cust":"'  + %trimr(%char(sccust)) + '",'
                 +  '"custnm":"'  + %trimr(cmname) + '",'
                 +  '"uom":"'  + %trimr(scwuom) + '",'
710bA            +  '"multiday":"'  + %trimr(indryage) + '",'
                 +  '"stc":"'  + %trimr(itemColor) + '",'
                 +  '"sts":"'  + %trimr(StatDesc) + '",'
710lA            +  '"stdOnly":"'  + stdOnly + '",'
                 +  '"prn":"'  + %trimr(Scprtn) + '",'
                 +  '"lbrp":"'  + %trimr(Oplbrp) + '",'
700 A            +  '"lbdl":"'  + %trimr(Oplbdl) + '",'
700 A            +  '"bxb":"'  + %trimr(opbxbu) + '",'
700 A            +  '"bxbp":"'  + %trimr(opbxbp) + '",'
700 A            +  '"bxbs":"'  + %trimr(opbxbs) + '",'
                 +  '"demo":"'  + %trimr(scdemo) + '",'
                 +  '"demowgt":"'  + %trimr(%char(scdemowgt)) + '",'
                 +  '"demouom":"'  + %trimr(scdemouom) + '",'
                 +  '"gengtin":"'  + %trimr(Opgengtin) + '",'
                 +  '"rpriitm":"'  + %trimr(rtnPriItm) + '",'
740 A            +  '"tare":"'  + %trimr(%char(Sctare)) + '",'
740 A            +  '"wgt":"'  + %trimr(%char(scWeght)) + '",'
740 A            +  '"netwgt":"'  + %trimr(%char(netwgt)) + '",'
                 +  '"rmake":"'  + %trim(%char(rtnMake)) + '",'
                 +  '"rpriqty":"'  + %trim(%char(rtnPriQty)) + '",'
                 +  '"rsecqty":"'  + %trim(%char(rtnSecQty)) + '",'
                 +  '"type":"'  + %trimr(Sctype) + '",'
                 +  '"dest":"'  + %trimr(Scdest) + '",'
                 +  '"pRemWgt":"'  + %trimr(%char(pRemWgt)) + '",'
710jA            +  '"pRemCnt":"'  + %trimr(%char(pRemCnt)) + '",'
                 +  '"pTrnCnt":"'  + %trim(%char(pTrnCnt)) + '",'
                 +  '"trans":"'  + %trimr(%char(curtrn#)) + '",'
                 +  '"mfgline":"'  + %trimr(%char(Scmfgno)) + '",'
710bA            +  '"uciValid":"'  + %trimr(uciValid) + '",'
740 A            +  '"drslt":"'  + %trimr(chkDriErr) + '"';

         // determine if any previous label information is returning
                    firstSent = *off;
                    rc = 1;
         // next line is used to test json if larger returns are posing
         // an issue.  The statement below will return 4 lines
740 D            //if rtncnt(rc) <> 0;
740 M            if rtncnt(rc) <> 0 and pWo<>'GENERATEITEM';

        // loops through the previous labels printed sending back as
        // many as 10 labels to begin with.  Will add to that list
        // while in the current session.  Once you back out and return
        // it will begin with the 10 latest again.

                    dow rtncnt(rc) <> 0;

           // once first record is sent do not send any deleted records
                    pOutStr = %trim(pOutStr) + ','
        +  '"lblc' + %char(rc) + '":"'  + %trimr(%char(rtncnt(rc))) + '",'
        +  '"lstat' + %char(rc) + '":"'  + %trimr(rtnstat(rc)) + '",'
        +  '"lwgt' + %char(rc) + '":"'  + %trimr(%char(rtnweght(rc))) + '",'
        +  '"litm' + %char(rc) + '":"'  + %trimr(rtnitm(rc)) + '",'
        +  '"lcus' + %char(rc) + '":"'  + %trimr(%char(rtncus(rc))) + '",'
        +  '"ldisp' + %char(rc) + '":"'  + %trimr(rtndisp(rc)) + '",'
        +  '"llcns' + %char(rc) + '":"'  + %trimr(rtnlcns(rc)) + '",'
        +  '"lsts' + %char(rc) + '":"'  + %trimr(rtnsts(rc)) + '"';
                       rc = rc + 1;

                       if rc > 10;
                          leave;
                       endif;

                    enddo;


                 endif;

          // Close off the JSON string
          pOutStr = %trim(pOutStr) + '}';
        else;
         // for non label commands simply return station id
         // to prevent mal-formed json string
          if pLsts = '*delete';
            // for deleted labels return the error and prevent
            // the label from being deleted in the grid if an
            // error occurred
             if $drimessage <> ' ';
                pOutStr = '{'
                   +  '"drslt":"'  + %trimr($drimessage) + '"'
                   + '}';
             else;
                pOutStr = '{'
                   +  '"drslt":"*GOOD' + %trim(pLhlsts) + '"'
                   + '}';
             endif;
          else;
             if plsts = '*ucisel';
                plsts = 'NOPRINT';
             endif;
             pOutStr = '{'
                 +  '"cmd":"'  + %trimr(plsts) + '",'
710hA            +  '"returnSeq":"'  + %trimr(%char(returnSeq)) + '",'
710iA            +  '"opntrans":"'  + %trimr(opntrans) + '",'
                 +  '"returnuci":"'  + %trimr(returnUci) + '",'
                 +  '"resetflag":"'  + %trimr(resetflag) + '",'
                 +  '"pTrnCnt":"'  + %trim(%char(pTrnCnt)) + '",'
                 +  '"stc":"Blue"'
                 + '}';
          endif;

        endif;     // blank serial number request only
      /end-free
      /free

       //---------------------------------------------------------
       // Init  -  Do some one time things
       //---------------------------------------------------------

          begsr Init;

             open(e) bfcdbgflg;
             if %error;
               dbgflgExists = *off;
             else;
               dbgflgExists = *on;
             endif;

             if dbgflgExists;
               chain(e) (#pgm) bfcdbgflg;
               if %found(bfcdbgflg);
                 debug = (bdfflag = 1);
               else;
                 debug = *off;
               endif;
             endif;

             exsr clrarray;
             pOutStr = ' ';
710kA        curtrn# = *zeros;

                         #curruser = pUser;
             resetflag = '0';
             returnUCI = 'NA';
             openMult = *blanks;
      /end-free
     *
     *   Get default values for the user.
     *

     C                   call      'GETUSER'
     C                   parm                    #curruser
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
710bAc                   eval      uciValid = 'N'
      /free
          endsr;
      /end-free

700 A*----------------------------------------------------------------
700 A*  bbCancel  User has choosen to cancel the Box Breaker process
700 A*            that they begun.  Loop through production labels
700 A*            generated marking them deleted, delete UCIINFO
700 A*            records generated, and reverse inventory
700 A*----------------------------------------------------------------

700 AC     bbCancel      begsr
      /free
          SqlStmt = 'Select prdlbhist.* from prdlbhist,ucisplits' +
                 ' where lhwhse=uswhse and lhgs1=usgs1b' +
                 ' and lhuci=' + sq + %trim(pUci) + sq +
710hA            ' and lhbxbsq=' + %char(pCaseSeq) +
                 ' and lhstat <>' + sq + 'D' + sq +
                 ' and usgs1b <> ' + sq + '*UNASSIGNED' + sq;

           exec sql PREPARE bbc FROM :SqlStmt;
           exec sql DECLARE UciCancel SCROLL CURSOR FOR bbc;
           exec sql OPEN UciCancel;

           //  goto end of newly added recordset in assending order
           exec sql
            fetch first from UciCancel into :lhhst;
            if sqlstt = '00000';
               reverseCase = *off;
               // loop thru each clear to clear
               dow sqlstt = '00000';
                  if pDisp <> lhdisp and lhdisp <> *blanks;
                     pDisp = lhdisp;
                  endif;
                  svTran = lhtran;
                  // reverse inventory adjustment and mark
                  // Production Module label as delete
                  exsr updProdSlot;
                  // issue delete statement for requested serial number
                  if $drimessage = ' ';
                  // delete associated UCI Info record for Box Breaker
                  // Breakdown UCI
                     exsr clr$uciinfo;
                     $uiWhse = scwhse;
                     $uiUci = lhgs1;
730aA                $uiitem = lhlitm;
720bA                // Add some additional information for tracking
720bA                $uiaction = 'DELETEUCI';
720bA                $uiaolcns = $uilcns;
                     $dricommand = '*UCIINFO';
                     $drisubcmd  = '%DELETEUCI';
                     $drisys2upd = 'D';
                     exsr zzdricop;

                     exec sql
                      delete from ucisplits
710hD      //          where usgs1b = :lhgs1 and usgs1c = :lhuci;
710hM                  where usgs1b = :lhgs1 and usgs1c = :lhuci
710hA                    and usbxbsq = :pCaseSeq;

                     exec sql
                      update PrdLbHist
                       set lhstat = 'D'
                       where lhlsts = :Lhlsts
                        and lhdtetim = :lhdtetim
710hD     //            and lhuci = :pUci;
710hM                   and lhuci = :pUci
710hA                   and lhbxbsq = :pCaseSeq;
                  endif;
                  exec sql
                   fetch next from UciCancel into :lhhst;
               enddo;
               // delete Unassigned UCISPLITS record
               exec sql
                delete from ucisplits
710hD     //     where usgs1b = '*UNASSIGNED' and usgs1c = :lhuci;
710hM            where usgs1b = '*UNASSIGNED' and usgs1c = :lhuci
710hA              and usbxbsq = :pCaseSeq;
            endif;
            exec sql CLOSE UciCancel;
            // Reverse UnAssigned
            exec sql
             select *
              into :plrec
               from prodlog
                where pllsts = 'UNASSIGNED' and plgs1 = :puci
                     and pltrn# = :svtran order by plcts desc
                       fetch first row only;
            if sqlstt = '00000';
               plweght = plweght * -1;
               plcts = %timestamp;
               plpgm = #prog;
               pluser = pUser;
               pljob = #job;
               pldtetim = %subst(%char(plcts):1:4) +
                          %subst(%char(plcts):6:2) +
                          %subst(%char(plcts):9:2) +
                          %subst(%char(plcts):12:2) +
                          %subst(%char(plcts):15:2) +
                          %subst(%char(plcts):18:2);
               exec sql insert into prodlog values(:plrec);
               if %error;
               endif;
            endif;
            // reverse case reduction if already completed
710gD       // eachAdjust = *off;
710gD       // exsr updCaseQty;
            pUci = *blanks;
710hD       pCaseSeq=*zeros;
      /end-free
700 AC                   endsr

700 A*----------------------------------------------------------------
700 A*  bbComplte  Complete the Case Breakdown transaction.  Create
700 A*             UCISPLITS record to record the negative or positive
700 A*             weight between original case weight and all eaches
700 A*             recorded.  Generally negative due to packaging
700 A*----------------------------------------------------------------

700 AC     bbComplte     begsr
      /free
           SqlStmt = 'Select * from ucisplits where ' +
710hD        //      'usgs1c=' + sq + %trim(pUci) + sq;
710hM                'usgs1c=' + sq + %trim(pUci) + sq +
710hA                ' and usbxbsq=' + %char(pCaseSeq);

           exec sql PREPARE bbo FROM :SqlStmt;
           exec sql DECLARE UciComplt SCROLL CURSOR FOR bbo;
           exec sql OPEN UciComplt;

           //  goto end of newly added recordset in assending order
           exec sql
            fetch first from UciComplt into :usrec;
            if sqlstt = '00000';
               firstSplit = *on;
               unAssignExists = *off;
               pWgtGen = 0;
               eachCnt = 0;
               dow sqlstt = '00000';
                  // tally total of weight captured for each breakdown
                  if usgs1b = '*UNASSIGNED';
                     unAssignExists = *on;
                  else;
                     pWgtGen = pWgtGen + ustwgt;
                     eachCnt = eachCnt + 1;
                  endif;
                  if not firstSplit;
                    // zero case quantity all but for first record
                    // in ucisplits file.  Other case info is duped.
                     exec sql
                      update UCISPLITS
                      set usfwgt = 0
                      where usgs1c = :puci and usgs1b = :usgs1b;
                  else;
                     // get license info to write when unassigned record
                     // is written to Production Log
                    exec sql
                    select plflcns,pltlcns,pldisp
                     into :sflcns,:stLcns,:pDisp
                       from Prodlog
                       where plgs1 = :usgs1b
                       fetch first row only;
                  endif;
                  firstSplit = *off;
                  exec sql
                   fetch next from UciComplt into :usrec;
               enddo;
               // write UnAssigned Record for remaining weight +/-
               // if total is different than original case
              if not unAssignExists;
710dD   //       if pCaseWgt <> pWgtGen;
                    ustrn#=ptrn#;
                    usgs1b = '*UNASSIGNED';
                    usfwgt = 0;
                    ustwgt = pCaseWgt - pWgtGen;
710hA               usbxbsq = scbxbsq;
                    usaddts = %timestamp;
                    usaddpgm = #prog;
                    usaddemp = #emp#;
                    usaddusr = pUser;
                    usaddjob = #job;
                    usaddnbr = #jobn;
                    uschgts = %timestamp;
                    uschgpgm = #prog;
                    uschgemp = #emp#;
                    uschgusr = pUser;
                    uschgjob = #job;
                    uschgnbr = #jobn;
                    exec sql insert into ucisplits values(:usrec);
                    if %error;
                    endif;
                    // insert Unassigned record in ProdLog
                    clear plrec;
                    plwhse=scwhse;
                    plitem=usfitm;
                    plaction='BXB';
                    plflcns=sflcns;
                    pltlcns=stlcns;
                    plline=scmfgno;
                    pldisp=pdisp;
                    plgs1=puci;
                    plqtyn=0;
                    plqty1=0;
                    plqty2=0;
                    plweght=pCaseWgt - pWgtGen;
                    pltare=0;
                    plpgm=#prog;
                    pluser=puser;
                    pljob=#job;
                    pllsts='UNASSIGNED';
                    plcts=%timestamp;
                    pldtetim = %subst(%char(plcts):1:4) +
                            %subst(%char(plcts):6:2) +
                            %subst(%char(plcts):9:2) +
                            %subst(%char(plcts):12:2) +
                            %subst(%char(plcts):15:2) +
                            %subst(%char(plcts):18:2);
                    plbfcwo=*blanks;
                    plcustwo=*blanks;
                    pltrn#=sctran;
                    pllbl#=*zeros;
                    plfgitm=*blanks;
                    plprddte=pddate;
                    exec sql insert into prodlog values(:plrec);
                    if %error;
                    endif;
710dD      //    endif;
                 // reduce case count by one
710gA            // Do not reduce case count when *bbcomplte
710gA            // This is done from M177xx call using command
710gA            // *bbcompant
710gA            if plsts <> '*bbcomplte';
                    eachAdjust = *off;
                    exsr updCaseQty;
710gA            endif;
              endif;
              // mark production labels as closed
              exec sql
              update PrdLbHist
                set lhstat = 'C', lhtran=:sctran
                where lhstat <> 'C' and lhstat <> 'D'
                      and lhuci = :puci;
              // mark UCIINFO Case record as used
              currstampmn = %timestamp;
               exec sql
                 update UCIINFO
                  set uiSeltrn# = :ptrn#,
                  uichgts = :currstampmn,
                  uichguc = :currstampmn,
                  uichgpgm = :#prog,
                  uichgemp = :#emp#,
                  uichgusr = :pUser,
                  uichgjob = :#job,
                  uichgnbr = :#jobn
                  where uiSeltrn# = 0
                       and uiuci = :puci;
710hD         // generate putaway if not broke down in pick slot
710hD         // if pBxbp = 'N';
710hD         //   if pLsts = '*bbcomplte';
710gD         //      exsr zzcrtTran;
710hD         //   endif;
710hD         // endif;
            endif;
            exec sql CLOSE UciComplt;
            // End Current Transaction before returning
            if Plsts = '*bbcomplte';
710hA         // generate putaway if not broke down in pick slot
710hA          if pBxbp = 'N';
710hA             if pLsts = '*bbcomplte';
710gA                exsr zzcrtTran;
710hA             endif;
710hA          endif;
               exsr zzzEndTran;
               // blank UCI info before returning since you are returned to
               // previous screen
               pUci = *blanks;
               pDisp = *blanks;
               pTrn# = *zeros;
710hA          pCaseSeq = *zeros;
               exsr uciselect;
            else;
               // if user stated they were breaking down more of same item
               // leave transcation and slot open
               pUci = *blanks;
710hA          pCaseSeq = *zeros;
               exsr uciselect;
            endif;
      /end-free
700 AC                   endsr

     *----------------------------------------------------------------
     *  calcRemWgt  Calculate Remaining Weight by subtracting labels
     *              generated for passed Case UCI from Starting Weight
     *              of Case UCI
     *----------------------------------------------------------------

     C     calcRemWgt    begsr
      /free
        // sum total weight generated for given Case UCI from
        // Production Module label file (PRDLBHIST)
           exec sql
710jD     //  select sum(lhweght-lhtare)
710jM       select sum(lhweght-lhtare),count(*)
710jD     //  into :pWgtGen :NullInds
710jM       into :pWgtGen :NullInds,:pCntGen :NullInds
            from PrdLbHist
              where lhuci = :pUCI and
710hA               lhbxbsq = :scbxbsq and
                    lhstat <> 'D';
           if sqlstt <> '00000' or NullInds = -1;
              pRemWgt = pCaseWgt;
710jA         pRemCnt = 0;
           else;
              pRemWgt = pCaseWgt - pWgtGen;
710jA         // Item info retrieved in CVTBARCODE before this
710jA         pRemCnt = itumq2 - pCntGen;
710jA         if itum2=*blanks;
710jA            pRemCnt=*zeros;
710jA         endif;
           endif;

      /end-free
     C                   endsr

      *--------------------------------------------------------------
      *  closeMult  Close MultiDay Work ORders as production completes
      *             requested quantity or when someone closes the Work
      *             Order using close button on Work ORder Screen
      *----------------------------------------------------------------

     C     closeMult     begsr
      /free
         // Perform edits to make sure all is good to close MultiDay WO
         chkDriErr = *blanks;
         exsr editMult;

         // if no errors were found in Edit routine close the Work Order
         // and record Usage and Waste
         if chkDriErr = *blanks;

            // first we should tally the total usage for the passed work order
            sumQtyn = *zeros;
            sumQty1=*zeros;
            sumQty2=*zeros;
            sumQtyp=*zeros;
            // Build usage totals by raw material to pass to
            // RMQTYMULT to get inventory values to call
            // CSLTQTY.
            sqlStmt = 'Select urrmi,sum(urprjnq),sum(urprjb1),' +
                              'sum(urprjb2),sum(urprjpq)' +
                          ' from pWrkOrdRu ' +
                          'where urWhse=' + %char(scWhse) + ' and ' +
                                'urwo#=' + sq + %trim(pWo) + sq +
                                ' and not urstat in(' + sq + 'C' +
                                sq + ',' + sq + 'D' + sq + ')' +
                                ' group by urrmi';
            exec sql PREPARE usewrkRu FROM :SqlStmt;
            exec sql DECLARE wrkRu SCROLL CURSOR FOR useWrkRu;
            exec sql OPEN WrkRu;
            exec sql fetch first from WrkRu into :ursum;

            if sqlStt = sqlSuccess;
               dow sqlStt = sqlSuccess;

                  // get line slot for given raw material
                  // and Mfg Line
                  savever# = $ppver#;
                  clear $pprod;
                  clear $pprod;
                  $ppver# = savever#;

                  if scMfgNo <> 0;
                     chain (scwhse:scMfgno) plined;
                     if %found(plined);
                        $ppdesc = indesc;
                        $pprcvau = *on;
                        $pprcva = inrcvaisl;
                     else;
                        $pprcvau = *on;
                        $pprcva = 'LIN';
                     endif;
                  else;
                     $pprcvau = *on;
                     $pprcva = 'LIN';
                  endif;

                  if urSumRmi <> '';
                     chain (scwhse:urSumRmi) piritem;
                     if %found(piritem);
                        $ppwhdpu = *on;
                        $ppwhdp  = itwhdp;
                        $ppitemu = *on;
                        $ppitem  = ititem;
                     endif;
                  endif;

                  $ppwhseu = *on;
                  $ppwhse  = scwhse;
                  $pplnenou = *on;
                  $pplneno = scmfgno;
                  $ppuser = pUser;
                  $ppuseru = *on;

                  $dricommand = '*PROD';
                  $drisubcmd = '%GETMIN';
                  $drisys2upd = 'D';
                  exsr zzDriCop;
                  if not wkError or $driReturn='INSLOT';
                     // now pass information to RMQTYMULT to get usage
                     // and Waste  values to record
      /end-free
     c                   call      'RMQTYMULT'
     c                   parm                    pSessid
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    scWhse
     c                   parm                    ursumRmi
     c                   parm                    $ppRcvar
     c                   parm      'Y'           pBegInv          13
     c                   parm      0             pEndNq            5 0
     c                   parm      0             pEnd1q            5 0
     c                   parm      0             pEnd2q            5 0
     c                   parm      0             pEndPq            9 4
     c                   parm      0             pEodWg            9 3
     c                   parm      ursumqN       pUseNq            5 0
     c                   parm      ursumq1       pUse1q            5 0
     c                   parm      ursumq2       pUse2q            5 0
     c                   parm      ursumqP       pUsePq            9 4
     c                   parm      *blanks       pErr             65

     c*    if no errors were returned we should record Usage and Waste
     c*    Inventory Adjustments.  If item is marked as non Production
     c*    specific RMQTY above will pass remaining balance in Ending
     c*    balance fields and therefore no WASTE will be issued.  If
     c*    it is a PRoduction Specific item waste will be created.

     c                   call      'CSLTQTY'
     c                   parm      ' '           pErrMsg          99
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    scWhse
     c                   parm                    ursumRmi
     c                   parm                    $ppRcvar
     c                   parm                    scMfgno
     c                   parm                    pEndNq
     c                   parm                    pEnd1q
     c                   parm                    pEnd2q
     c                   parm                    pEndPq
     c                   parm                    pEodWg
     c                   parm                    pUseNq
     c                   parm                    pUse1q
     c                   parm                    pUse2q
     c                   parm                    pUsePq
     c                   parm      'U'           pCmd              1
     c                   parm      '*AFTERACT'   pLoc             10
      /free

              // Close HEader and Detail records
                  exsr CloseWo;

710aA             else;
710aA                // if driprod returns an error when looking for
710aA                // Raw Material Line Slot then return with the
710aA                // error.
710aA                chkDriErr = $drimessage;
710aA                exec sql Close WrkRu;
710aA                leavesr;
                  endif;

                  exec sql fetch next from WrkRu into :ursum;
               enddo;
               exec sql Close WrkRu;
               // close date for selected mfg line
               chain (scWhse:scMfgno:'O') prdDate1;
               if %found(prddate1);
                  delete(e) pdrec;
                  if %error;
                  endif;
               endif;
            endif;
         endif;    // chkDriErr equals blanks
      /end-free
     C                   endsr

710aA *--------------------------------------------------------------
      *  CloseWo   Call DriProd to Close Work ORder Header and Detail
      *----------------------------------------------------------------

710aAC     CloseWo       begsr
      /free
                    //  Call process to close Work Order

                     savever# = $ppver#;
                     $ppver# = savever#;

                     exec sql select woMfgno
                         into :$ppLneno :NullInds
                       from pwrkord
                         where wowhse=:scwhse and
                           wowo#=:pWo;
                     if Nullinds = -1;
                        $ppLneno = 1;
                     endif;
                     $ppLnenou = *on;

                     $ppSessIdu = *on;
                     $ppSessid  = pSessId;
                     $ppwhseu = *on;
                     $ppwhse  = scwhse;
                     $ppuser = pUser;
                     $ppuseru = *on;
                     $ppWo# = pWo;
                     $ppWo#u = *on;

                     $dricommand = '*PROD';
                     $drisubcmd = '%CLSWO';
                     $drisys2upd = 'D';
                     exsr zzDriCop;
      /end-free
710aAC                   endsr

710aA *--------------------------------------------------------------
      *  editMult  Make sure all edits good before trying to close
      *            MultiDay Work ORder
      *             Order using close button on Work ORder Screen
      *----------------------------------------------------------------

710aAC     editMult      begsr
      /free
         pTrnCnt = *zeros;
         // confirm usage records exist where status is not C(Closed)
         // and not D(Deleted)
         exec sql select count(*) into :pTrnCnt
              from pWrkordRu
                where urwhse=:scwhse and urwo#=:pWo and
                      not urstat in('C','D');

         // We will only generate Usage and Waste records if
         // Production was generated.  If we are simply closing
         // short there is no need to generate zero value usage
         // and waste records
         if pTrnCnt = *zeros;
710aA       // when no open pWrkORdRu records exist there is
710aA       // nothing to close.  User can use Work Order
710aA       // screen to close short if desired
710fA       exsr closeWo;
710fD       //chkDriErr = 'No open Production. Use the ' +
710fD       //            'WO screen to close Work Order';
            leavesr;
         endif;

         // Build usage totals by raw material to pass to
         // RMQTYMULT to get inventory values to call
         // CSLTQTY.
         sqlStmt = 'Select urrmi,sum(urprjnq),sum(urprjb1),' +
                           'sum(urprjb2),sum(urprjpq)' +
                       ' from pWrkOrdRu ' +
                       'where urWhse=' + %char(scWhse) + ' and ' +
                             'urwo#=' + sq + %trim(pWo) + sq +
                             ' and not urstat in(' + sq + 'C' +
                             sq + ',' + sq + 'D' + sq + ')' +
                             ' group by urrmi';
         exec sql PREPARE edtwrkRu FROM :SqlStmt;
         exec sql DECLARE edtRu SCROLL CURSOR FOR edtWrkRu;
         exec sql OPEN edtRu;
         exec sql fetch first from edtRu into :ursum;

         if sqlStt = sqlSuccess;
            dow sqlStt = sqlSuccess;

               // get line slot for given raw material
               // and Mfg Line
               savever# = $ppver#;
               clear $pprod;
               clear $pprod;
               $ppver# = savever#;

               if scMfgNo <> 0;
                  chain (scwhse:scMfgno) plined;
                  if %found(plined);
                     $ppdesc = indesc;
                     $pprcvau = *on;
                     $pprcva = inrcvaisl;
                  else;
                     $pprcvau = *on;
                     $pprcva = 'LIN';
                  endif;
               else;
                  $pprcvau = *on;
                  $pprcva = 'LIN';
               endif;

               if urSumRmi <> '';
                  chain (scwhse:urSumRmi) piritem;
                  if %found(piritem);
                     $ppwhdpu = *on;
                     $ppwhdp  = itwhdp;
                     $ppitemu = *on;
                     $ppitem  = ititem;
                  endif;
               endif;

               $ppwhseu = *on;
               $ppwhse  = scwhse;
               $pplnenou = *on;
               $pplneno = scmfgno;
               $ppuser = pUser;
               $ppuseru = *on;

               $dricommand = '*PROD';
               $drisubcmd = '%GETMIN';
               $drisys2upd = 'D';
               exsr zzDriCop;
               if not wkError or $driReturn='INSLOT';
                  // now pass information to RMQTYMULT to get usage
                  // and Waste  values to record
710aA             // Make sure the Line Slot has enough stock to perform
710aA             // the close transaction.
710aA             chain (scWhse:$ppRcvar:itwhdp) slot12;
710aA             select;
710aA             when itumq3<>*zeros;
710aA                if ((slstk1*itumq2*itumq3) + (slstk1*itumq3) +
                          slstk3) <
710aA                   ((urSumQn*itumq2*itumq3) + (urSumq1*itumq3) +
                          urSumq2);
710aA                   chkDriErr = 'Stock short for raw material(' +
710aA                               %trim(slitem) + ') in slot(' +
                                    %trim($ppRcvar) + ')';
710aA                   exec sql Close edtRu;
710aA                   leavesr;
                     endif;
710aA             when itumq2<>*zeros;
710aA                if ((slstk1*itumq2) + slstk2) <
710aA                   ((urSumQn*itumq2) + urSumQ1);
710aA                   chkDriErr = 'Stock short for raw material(' +
710aA                               %trim(slitem) + ') in slot(' +
                                    %trim($ppRcvar) + ')';
710aA                   exec sql Close edtRu;
710aA                   leavesr;
                     endif;
710aA             other;
710aA                if (slstk1) <
710aA                   (pUseNq);
710aA                   chkDriErr = 'Stock short for raw material(' +
710aA                               %trim(slitem) + ') in slot(' +
                                    %trim($ppRcvar) + ')';
710aA                   exec sql Close edtRu;
710aA                   leavesr;
                     endif;
710aA             endsl; // Select clause for breakdown quantity to use
               endif; // Line Slot found for Raw MAterials
               exec sql fetch next from edtRu into :ursum;
            enddo;   // Read Sql reads of open pWrkORdRu
710aA       exec sql Close edtRu;
         endif;  // Open pWrkORdRu records found

      /end-free
710aAC                   Endsr
710kA
710kA*----------------------------------------------------------------
710kA*  GenerateLabor  - Generate appropriate labor Transaction from
710kA*                   Production Module
710kA*----------------------------------------------------------------
710kA
710kAc     GenerateLabor begsr
710kA /free
710kA      // get line slot for given raw material
710kA      // and Mfg Line
710kA      savever# = $ppver#;
710kA      clear $pprod;
710kA      clear $pprod;
710kA      $ppver# = savever#;
710kA
710kA      $ppscale = pStation;
           $pplnenou = *on;
           $pplneno = scmfgno;
710kA      $ppCustWo = primTask;         // Task Number from GUI Screen
710kA      $ppPrimary = %char(scmfgno);  // Scale Station Line
710kA      $ppWhse = scWhse;             // Warehouse
710kA      $ppWo# = pWo;                 // Work Order
710kA      $pptrn# = curtrn#;            // Current Transaction
710kA      $ppExpDt = %uns(%char(%Date():*Iso0));   // Date for Transaction
710kA      $ppcord = %uns(%char(%time():*Iso0));    // current time for transact
710kA      $ppuser = pUser;
710kA      $ppuseru = *on;
710kA
710kA      // if coming from M147xx then send in ALL/ALL for Work Order and
710kA      // Mfg Line since they are returning to get next Work Order
710kA      //Non_Num_Posn = %scan('M147':pPgm);
710kA      //if Non_Num_Posn <>0;
710kA      if %scan('M147':pPgm) <> 0 or (pStation=*blanks and $ppWo#=*blanks)
710kA            or pLsts='*CLSLAB' or (pStation=*blanks and $ppWo#='ALL');
710kA         $ppWo# = 'ALL';
710kA         $ppPrimary = 'ALL';
710kA      endif;
710kA
710kA      $dricommand = '*PROD';
710kA      if pLsts = '*STRLAB';
710kA         $drisubcmd = '%STRLAB';
710kA      else;
710kA         $drisubcmd = '%CLSLAB';
710kA      endif;
710kA
710kA      $drisys2upd = 'D';
710kA      exsr zzDriCop;
710kA      if $driReturn <> '*OK';
710tA         chkDriErr = $driMessage;
710tA      else;
710tA         // return active Transaction Number
710tA         curtrn# = $ppTrn#;
710kA      endif;
710kA
710kA /End-free
710kAc                   endsr
710kA
     *----------------------------------------------------------------
     *  TrnCount  Return count of any remaining breakdowns for passed
     *            Transaction
     *----------------------------------------------------------------

     C     TrnCount      begsr
      /free
        // get record count for open breakdown records for given
        // Transaction number being passed
           exec sql
            select count(*)
            into :pTrnCnt :NullInds
            from PrdLbHist
              where lhtran = :pTrn# and
                    lhstat <> 'D';
           if sqlstt <> '00000' or NullInds = -1;
              pTrnCnt = 0;
           endif;

           // if being cancelled and nothing remains for trans# then close
           // transaction and clear everything
           if pTrnCnt = 0 and pLsts = '*bbcancel';
              // End Current Transaction if no remaining entries exist
              exsr zzzEndTran;
              // blank UCI info before returning since you are returned to
              // previous screen
              pDisp = *blanks;
              pTrn# = *zeros;
              pUCI = *blanks;
710hA         pCaseSeq = *zeros;
              exsr uciselect;
              returnUCI = '';
           endif;
           if pLsts = '*bbcancel';
              exec sql
710hD     //   select lhuci
710hM          select lhuci,lhbxbsq
710hD     //    into :returnUCI :NullInds
710hM           into :returnUCI :NullInds,:returnSeq :NullInds
                from PrdLbHist
                  where lhtran = :pTrn# and
                        lhstat <> 'D'
                  order by lhcts desc
                  fetch first row only;
              if sqlstt <> '00000' or NullInds = -1;
                 returnUCI = '';
710hA            returnSeq = 0;
              endif;
           endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  cvtBarCode  Convert Bar Code for ALL AI information
     *----------------------------------------------------------------

     C     cvtBarcode    begsr
      * add the conversion of the UCI barcode
     C                   eval      $cbcmd = '*ALL    '
     C                   eval      $cbbar = pUCI
     c                   clear                   $barcode
     c                   clear                   $barcode2
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     C                   parm                    $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
     * if gtin not found, error for invalid barcode scanned
     c                   if        not $bcGtinSent
     c                             and not $bcai99sent
     c                   eval      pCaseWgt = 0
     C                   goto      endcvtb

710dAc                   else

710dAc                   if        $bcai99sent
710dA /free
710dA                    exsr clr$uciinfo;
710dA                    $uiWhse = scwhse;
710dA                    $uiuci  = puci;
710dA
710dA                    $dricommand = '*UCIINFO';
710dA                    $drisubcmd  = '%CKUCISPLT';
710dA                    $drisys2upd = 'D';
710dA                    exsr zzdricop;
710dA
710dA                    if $driReturn = '*OK';
710dA                       chain (scwhse:$uiitem) piritem;
710dA                       exec sql select upupc into :$cstr
710dA                               from upc
710dA                            where upwhse=:scWhse and upitem=:$uiitem
710dA                              and uputyp='N' and upuom=:itum1;
710dA                       select;
710dA                       when $uiwgtlbs <> *zeros;
710dA                          $bcPNtLbSent = *on;
710dA                          $bcPNtLb = $uiwgtlbs;
710dA                       when $uiwgtkgs <> *zeros;
710dA                          $bcPNtKgSent = *on;
710dA                          $bcPNtKg = $uiwgtkgs;
710dA                       other;
710dA                          $bcPNtKgSent = *off;
710dA                          $bcPNtKg = *zeros;
710dA                          $bcPNtLbSent = *off;
710dA                          $bcPNtLb = *zeros;
710dA                       endsl;
710dA
710dA                       $bcgtin = %trim($cstr);
710dA                       Clear $cstr;
710dA                    endif;
710dA /end-free
710dAc                   endif
     c                   endif
      * Load Catch Weight
     c                   if        not error

     c                   if        $bcPNtLbSent
     c                   eval      pCaseWgt  = $bcPNtLb
     c                   endif

650dAc                   if        $bcPNtKgSent
650dAc                   eval      pCaseWgt = $bcPNtKg * 2.20462
650dAc                   endif

     c                   endif
700 A
700 A * Load UPC
700 A * if gtin not found, error for invalid barcode scanned
700 Ac                   eval      $cstr = *blanks
710dDc*                  if        $bcGtinSent
700 AC                   movel     $bcgtin       $CSTR
700 AC                   call      'ADJUST'
700 AC                   parm      '*RIGHT  '    $CCMD             8
700 AC                   parm                    $CSTR            30
700 Ac                   move      $cstr         ckupc
710dDc*                  endif
700 A /free
700 A                    chain (scwhse:ckupc) upc;
700 A                    if %found(upc);
700 A                       chain (upwhse:upitem) piritem;
                         endif;
      /end-free
     C     endcvtb       endsr
      /free

       //---------------------------------------------------------
       // chkDriError - Check for any Dri Errors for scale
       //---------------------------------------------------------

          begsr chkDriError;
             chkDriErr = ' ';
             exsr rtvScale;
             if scerror <> ' ';
                chkDriErr = scerror;
                exsr sndDtaq;
             endif;
          endsr;

       //---------------------------------------------------------
       // genAlterItems - Generate Alter Items for Work Order
       //---------------------------------------------------------

          begsr genAlterItems;

                savever# = $ppver#;
                $ppver# = savever#;

                if pitem <> '';
                   chain (scwhse:pitem) piritem;
                   if %found(piritem);
                      $ppwhdpu = *on;
                      $ppwhdp  = itwhdp;
                      $ppitemu = *on;
                      $ppitem  = ititem;
                   endif;
                endif;

                $ppwhseu = *on;
                $ppwhse  = scwhse;
                $pplnenou = *on;
                $pplneno = scmfgno;
                $ppscaleu = *on;
                $ppscale = pStation;
                $ppSessIdu = *on;
                $ppSessId = pSessId;
                $ppWo#u = *on;
                $ppWo# = pWo;

                $dricommand = '*PROD';
                $drisubcmd = '%GENALTER';
                $drisys2upd = 'D';
                exsr zzDriCop;
                if wkerror;
                endif;
          endsr;

       //---------------------------------------------------------
       // CrtPrdLbHistRS - Create Label History Record Set
       //---------------------------------------------------------

          begsr CrtPrdLbHistRS;

          hldLastLabel = ' ';

           wrkmfgno = scmfgno;
         // 5 digit julian date, mfg line#, and 5 digit seq. number
           TodayJul = %char((wrkIso-%days(10)):*jul0);
           jultoDay = TodayJul + %editc(wrkmfgno:'X')
                                 + '00000';

        //  either get specific serial number for requested
        //  reprint or record set by requested item
           if pLsts = '*reprint';

              wherelabel = 'where lhlsts =' + pLhlsts;

           else;

              wherelabel = 'where lhsta = ' + sq + pStation + sq +
700b                       ' and lhwo = ' + sq + pWO + sq;

          // pLblc is the current max label count being passed from
          // the MRC screen when this function is called.  Therefore
          // it will only read record beyond the latest label in the
          // grid.  It also uses this to determine whether to send
          // in ascending or decending order to always show label grid
          // in decending order and maintain the latest number.

                if pLblc = 0;
                   wherelabel = %trim(wherelabel) +
                     ' and lhlsts >= ' + sq + jultoDay + sq;
                else;
                   jultoDay = %subst(jultoDay:1:7) +
                                %editc(pLblc:'X');
                   wherelabel = %trim(wherelabel) +
                     ' and lhlsts >= ' + sq + jultoDay + sq;
                endif;

700 A      // only select specific case UCI when passed
700 A      // This is only passed when using Box Breaker
700 A      // MRC app M173xx/M177xx
700 A           if pUCI <> *blanks;
700 A              wherelabel = %trim(wherelabel) +
710hD        //         ' and lhuci = ' + sq + pUCI + sq;
710hM                   ' and lhuci = ' + sq + pUCI + sq +
710hA        // added select to only return label records for sequence
710hA        // associated to this particular case if non unique
710hA                   ' and lhbxbsq = ' + %char(scBxbSq);
700 A           endif;

           //   wherelabel = %trim(wherelabel) +
           //   ' and lhlitm = ' + sq + pItem + sq +
          //    ' and lhlsts > ' + sq + scLsts + sq;

           endif;

           sqlStmt = 'Select * from prdlbhist ' +
                     whereLabel;

             // setup order by for initial load versus additional labels.
             // since we show newest first the html code appends to html
             // table in high to low order and then prepends low to high
             // which keeps the overall high to low table look

            sqlStmt = %trim(sqlStmt) + ' order by lhlsts ';
            sqlStmt = %trim(sqlStmt);

           exec sql PREPARE sel FROM :SqlStmt;

           exec sql DECLARE LblCursor SCROLL CURSOR FOR SEL;

           exec sql OPEN LblCursor;

          // sort in assending order per the serial number which will
          // put the most recent labels always at the bottom of the
          // recordset.  Sequel will then loop through the recordset
          // starting at the bottom and ALWAYS sending the first record
          // it encounters which will be the most recent label whether
          // the status is deleted or not, then it will read backwards
          // until it either hits bof or it goes back far enough to
          // have 10 records to load that have not been marked as
          // deleted.  This in effect will ALWAYS send the most recent
          // 10 records to the current session and the M149xx or M150xx
          // screens will PREPEND records where the label number is
          // greater than the last currently on the screen

            SkipFirstRead = *off;
            if pLsts <>'*reprint';

              //  goto end of newly added recordset in assending order
               exec sql
                fetch last from LblCursor into :lhhst;
                if sqlstt = '00000';
                  // if success then save last label number to
                  // ensure it is passed down and back up to fill grid
                   hldLastLabel = lhlsts;
                   exec sql
                    fetch prior from LblCursor into :lhhst;
                    if sqlstt <> '00000';
                      // if not success then position to first record
                       SkipFirstRead = *on;
                       exec sql
                        fetch first from LblCursor into :lhhst;
                    else;
                       labelcount = 1;
                       dow sqlstt = '00000';
                          if lhstat <> 'D';
                             labelcount= labelcount + 1;
                             if labelcount > 10;
                                leave;
                             endif;
                          endif;
                          exec sql
                            fetch prior from LblCursor into :lhhst;
                       enddo;
                       // if labelcount not > 10 then read forward to first
                       // record status "O" and process from there
                       if labelcount <= 10;
                          if sqlstt = '00000';
                             exec sql
                               fetch next from LblCursor into :lhhst;
                          else;
                             exec sql
                               fetch first from LblCursor into :lhhst;
                          endif;
                          dow sqlstt = '00000';
                             if (lhstat = 'O' or lhstat = 'P') or
                                ((lhstat = 'O' or lhstat = 'P' or
                                 lhstat = 'C') and lhuci=puci);
                                SkipFirstRead = *on;
                                leave;
                             endif;
                             exec sql
                               fetch next from LblCursor into :lhhst;
                          enddo;
                       endif;
                    endif;
                endif;
            endif;

         endsr;
      /end-free
      *----------------------------------------------------------
      *  LabelReprint - Reprint label that has already printed
      *----------------------------------------------------------
      /free

          begsr LabelReprint;

             lhlsts = ' ';
             lhlblc = 0;
             exsr clrArray;
             exsr rtvScale;
             rc = 1;
             exsr CrtPrdLbHistRS;

          // read the first record only
             exec sql
               FETCH FIRST FROM LblCurSor INTO :lhhst;

             if Sqlstt = sqlSuccess;
                exsr sndDtaq;
             endif;

            // Close SQL cursor, end program
              Exec Sql Close LblCursor;

             endsr;

       //---------------------------------------------------------
       // bldLabelArray - Create entry in Label History Array
       //---------------------------------------------------------

          begsr bldLabelArray;

           if lhstat <> 'D' or lhlsts = hldLastLabel;
             rtncnt(rc) = lhlblc;
             rtnstat(rc) = lhstat;
             rtnweght(rc) = lhweght;
             rtnitm(rc) = lhlitm;
             rtnsts(rc) = lhlsts;
             rtncus(rc) = lhcust;
             rtndisp(rc) = lhdisp;
             rtnlcns(rc) = lhlcns;
710jA        if lhuci<>*blanks and lhdspbb<>*blanks and
710jA           lhbxbsq<>0 and lhdisp=*blanks;
710jA           rtndisp(rc) = 'lblOnly';
710jA           rtnlcns(rc) = 'lblOnly';
710jA        endif;
             rc = rc +1;
           endif;

             if pLblc = 0;
                lstary = 1;
             else;
                lstary = rc-1;
                if lstary < 1;
                   lstary = 1;
                endif;
             endif;

          endsr;

      /end-free

700 A*----------------------------------------------------------------
700 A*  clr$licinfo  Clear $licinfo data structure fields
700 A*----------------------------------------------------------------

700 AC     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #user
     C                   eval      $lnemp# = #emp#
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobn

700 AC                   endsr
     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
720bAC                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = #emp#
     C                   eval      $uiaddusr = lhuser
     C                   eval      $uiaddpgm  = #prog
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobn
     C                   endsr
      /free

       //---------------------------------------------------------
       // clrArray - Clear Array
       //---------------------------------------------------------

          begsr clrArray;

             rc = 1;
             dow rc < 11;
                rtncnt(rc) = 0;
                rtnstat(rc) = ' ';
                rtnweght(rc) = 0;
                rtnitm(rc) = ' ';
                rtnsts(rc) = ' ';
                rtncus(rc) = 0;
                rtndisp = ' ';
                rtnlcns = ' ';
                rc = rc + 1;
             enddo;

          endsr;

       //---------------------------------------------------------
       // ManualLabel - Create/Print Manual Labels
       //---------------------------------------------------------

          begsr manualLabel;

             lhlsts = ' ';
             lhlblc = 0;
             rc = 0;
             exsr rtvScale;

         // create multiple label creates to be returned after creation

        //  dow rc <= pMqty;
        //     rc = rc +1;
               exsr sndDtaq;
        //  enddo;

            exsr rtvItem;
            exsr rtvCust;
            exsr CrtPrdLbHistRS;
            exsr clrArray;
            rc = 1;

            if not SkipFirstRead;
             exec sql
               FETCH NEXT FROM LblCurSor INTO :lhhst;
            endif;

740 D        //dow Sqlstt = sqlSuccess;
740 M        dow Sqlstt = sqlSuccess and pWo<>'GENERATEITEM';

                   if rc > 8;
                      leave;
                   endif;

                exsr bldLabelArray;

                exec sql
                  FETCH NEXT FROM LblCurSor INTO :lhhst;

             enddo;

               // Close SQL cursor, end program
                 Exec Sql Close LblCursor;

         endsr;

       //---------------------------------------------------------
       // autoLabel - Retrieve Scale record and return label history
       //---------------------------------------------------------

          begsr autoLabel;

            rc = 1;

            exsr rtvScale;

            exsr rtvItem;
            exsr rtvCust;
            exsr clrArray;
            rc = 1;

            if Plsts <> 'NOPRINT';
               exsr CrtPrdLbHistRS;
               rc = 1;

               if not SkipFirstRead;
                exec sql
                  FETCH NEXT FROM LblCurSor INTO :lhhst;
               endif;

740 D           //dow Sqlstt = sqlSuccess;
740 M           dow Sqlstt = sqlSuccess and pWo<>'GENERATEITEM';

                   if rc >10;
                      leave;
                   endif;

                   exsr bldLabelArray;

                   exec sql
                     FETCH NEXT FROM LblCurSor INTO :lhhst;

                enddo;

                // Close SQL cursor, end program
                  Exec Sql Close LblCursor;
             else;
                lhlsts = ' ';
                lhlblc = 0;
             endif;

         endsr;

       //---------------------------------------------------------
       // DeleteLabel - Delete Requested Serial number and label
       //---------------------------------------------------------

          begsr deleteLabel;

            $driMessage = ' ';
            exec sql
             select count(*)
             into :numrecs
             from PrdLbHist
               where lhlsts = :pLhlsts;

            // if it is decided at some time later that we should
            // a label to be deleted once inventory is pushed in
            // EOD we could put a simple check here to not check
            // for an open "O" record in PRDLBHIST but also an
            // open "O" record in pWrkOrdRU.  The problem comes in
            // having a way to reverse the End of Day transaction
            // that they entered......
            // get record to be deleted
710bA       if pUCI = *blanks;
710bA          // pUci is only passed for Box Breaker.  If regular
710bA         // Production and not in status 'O' you cannot delete
710bA         // This would mean it has been added to license and putaway
710bA       exec sql
710bA         select * into :LHHST from PrdLbHist
710bA          where lhlsts = :pLhlsts  and lhstat='O'
710bA          fetch first 1 row only;
710bA       else;
            exec sql
              select * into :LHHST from PrdLbHist
700cD    //    where lhlsts = :pLhlsts and lhstat = 'O'
700cA          where lhlsts = :pLhlsts
               fetch first 1 row only;
710bA       endif;
            if Sqlstt = SqlSuccess;
                if numrecs = 1;
                 // only reduce quantity in slot if this was a reprint
                   clear $pprod;
                   clear $pprod2;
                // $ppwgt = lhweght * -1;
                // before we delete adjust quantity and weight from slot/lic
                  exsr updProdSlot;
                  // issue delete statement for requested serial number
                  if $drimessage = ' ';

                  // delete associated UCI Info record
                     if  lhgs1 <> *blanks;
                        exsr clr$uciinfo;
                        $uiWhse = scwhse;
730aA                   $uiitem = lhlitm;
                        $uiUci = lhgs1;
720bA                   // Add some additional information for tracking
720bA                   $uiaction = 'DELETEUCI';
720bA                   $uiaolcns = $uilcns;
                        $dricommand = '*UCIINFO';
                        $drisubcmd  = '%DELETEUCI';
                        $drisys2upd = 'D';
                        exsr zzdricop;
                     endif;

                     if $drimessage = ' ';
                        exec sql
                         delete from ucisplits
710hD      //             where usgs1b = :lhgs1 and usgs1c = :lhuci;
710hM                     where usgs1b = :lhgs1 and usgs1c = :lhuci
710hA                       and usbxbsq = :lhbxbsq;
                        exec sql
                         update PrdLbHist
                          set lhstat = 'D'
                          where lhlsts = :pLhlsts
                           and lhdtetim = :lhdtetim;
                        exec sql
                         update pWrkOrdRu
                          set urstat = 'D'
                          where urser = :pLhlsts
                           and urwo# = :pwo;
                      endif;
                   endif;
                endif;
710bA       else;
710bA          $drimessage =
710bA            'UCI cannot be deleted.  Applied' +
710bA            ' to license and putaway';
710bA          leavesr;
            endif;

         endsr;

       //---------------------------------------------------------
       // DemoWeight - Setup Demo Weight to update scale record
       //---------------------------------------------------------

          begsr demoWeight;

            demowgt = scdemowgt;

            if Plsts = '*demo';
               demowgt = pMwgt;
               pMwgt = 0;
            endif;
          endsr;
710iA
710iA  //---------------------------------------------------------
710iA  // opnSplitsRec  This routine checks for Box Breaker
710iA  //               transactions that are not complete
710iA  //               It returns latest case uci so user can complete
710iA  //               It joins UCIPLISTS and PRDLBHIST to get
710iA  //               all info to perform check
710iA  //---------------------------------------------------------
710iA
710iA     begsr opnSplitsRec;
710iA
710iA        opntrans=*blanks;
710iA        exec sql select distinct usgs1c into :opntrans
710iA                        from ucisplits as a
710iA                 where (select count(*) from ucisplits as b where
710iA                         a.ustrn#=b.ustrn# and
710iA                         b.usgs1b='*UNASSIGNED')=0 and
710iA                       (select count(*) from prdlbhist as c where
710iA                         a.ustrn#=c.lhtran and a.usgs1c=c.lhuci and
710iA                         a.usgs1b=c.lhgs1 and c.lhsta=:pStation and
710iA                         a.usbxbsq=c.lhbxbsq)<>0
710iA                 order by usgs1c desc
710iA                 fetch first row only;
710iA
         endsr;

       //---------------------------------------------------------
       // UciSelect - Update Scale record with UCI and Slot Box Brker
       //---------------------------------------------------------

          begsr UciSelect;

                exec sql
                  update SCALE
                    set scuci = :pUci,
                     scdisp = :pdisp,
                     sctran = :pTrn#,
710hA                scBxbSq = :pCaseSeq
                      where scsta = :pStation;

         endsr;

710bA  //---------------------------------------------------------
710bA  // UciMultiDay - Update Scale record with RM UCI MulitDay Line
710bA  //               after ensuring RM UCI is valid and not used
710bA  //---------------------------------------------------------
710bA
710bA     begsr UciMultiDay;
710bA
710bA        // first we need to ensure that pRmUci was replenished
710bA        // to this particular mfg line.  We can come back later
710bA        // and modify to confirm it has not already been used
710bA        // by checking prodlog.
710bA        exec sql select count(*) into :pTrnCnt
710bA                 from prodlog
710bA                  where plwhse=:scWhse and plAction='RPL'
710bA                    and plline=:scMfgno and plGs1=:pRmUci;
710bA        if pTrnCnt = *zeros;
710bA           uciValid = 'N';
710bA           leavesr;
710bA        else;
710bA           // make sure scanned UCI has not already been used
710bA           // according to Prodlog.  In order to do that we will
710bA           // confirm that there are either NO Prodlog records
710bA           // that have the RM Uci recorded in the RM UCI field
710bA           // in the Prodlog file or, if records exist we will
710bA           // confirm the sum of quantities and weights come
710bA           // to zero meaning it was used and reversed.
710bA           sqlStmt = 'Select * from prodlog' +
710bA             ' where plwhse=' + %char(scWhse) +
710bA             ' and plAction=' + sq + 'PSC' + sq  +
710bA             ' and plline=' + %char(scMfgno) + ' and plRmUci=' +
710bA             sq + %trim(pRmUci) + sq;
710bA
710bA           exec sql PREPARE usedUCI FROM :SqlStmt;
710bA           exec sql DECLARE RmUci SCROLL CURSOR FOR usedUCI;
710bA           exec sql OPEN RmUci;
710BA           exec sql fetch first from RmUci into :plrec;
710bA
710bA           if sqlStt = sqlSuccess;
710bA              // we should now loop through PRodlog records with
710bA              // this RM UCI and ensure the totals of quantities
710bA              // and weight net to zero which indicates a piece
710bA              // was generated then deleted at some point which
710bA              // frees up the UCI for another use
710bA              sumQtyn = *zeros;
710bA              sumQty1 = *zeros;
710bA              sumQty2 = *zeros;
710bA              sumWeght = *zeros;
710bA              dow sqlStt = sqlSuccess;
710bA                 sumQtyn = sumQtyn + plQtyn;
710bA                 sumQty1 = sumQty1 + plQty1;
710bA                 sumQty2 = sumQty2 + plQty2;
710bA                 sumWeght = sumWeght + plWeght;
710BA                 exec sql fetch next from RmUci into :plrec;
710bA              enddo;
710bA              exec sql Close RmUci;
710bA              // if records were found in Prodlog with RMUci we
710bA              // must insure the sum of quantities and weights
710bA              // tally to zero which indictes the UCI was used
710bA              // and then deleted.
710bA              if sumQtyn <> *zeros or sumQty1 <> *zeros or
710bA                 sumQty2 <> *zeros or sumWeght <> *zeros;
710bA                 uciValid = 'N';
710bA                 leavesr;
710bA              else;
710bA                 ucivalid = 'Y';
710bA              endif;
710bA           else;
710bA              // if no Prodlog Records were found where RM UCI
710bA              // has been used we are good to use this RM UCI
710bA              uciValid = 'Y';
710bA           endif;
710bA        endif;
710bA
710bA        if pRmUci = *blanks;
710bA           exec sql
710bA             update SCALE
710bA               set scuci = :pRmUci,
710bA                scdisp = ' ',
710bA                sctran = :pTrn#
710bA                 where scsta = :pStation;
710bA        else;
710bA           exec sql
710bA             update SCALE
710bA               set scuci = :pRmUci,
710bA                scdisp = 'MULTIDAY',
710bA                sctran = :pTrn#
710bA                 where scsta = :pStation;
710bA        endif;
710bA
710bA    endsr;

       //---------------------------------------------------------
       // updLicense - Update License and Sequence in Scale
       //---------------------------------------------------------

          begsr updLicense;

                exec sql
                  update SCALE
                    set scbblcns = :pItem
                      where scsta = :pStation;

         endsr;

       //---------------------------------------------------------
       // updUCIINFO - Remove Transaction from UCI Case so
       //              employee can either complete or cancel
       //---------------------------------------------------------

          begsr updUCIINFO;

                exec sql
                  update UCIINFO
                    set uiseltrn# = 0
                      where uiuci = :pUci and uiseltrn# <> 0;

                // ** may need to put in loop since multiple records
                // **   2/21/2016

700d            // Delete Production Log records when user returns
700d            // to make changes.  They will be forced to click
700d            // either complete or cancel which will update
700d            // production log again.  It deletes any production
700d            // log entries where case uci matches or any breakdowns
700d            // associated to that case
700d            exec sql delete from prodlog as a
700d                 where a.plgs1 = :puci or a.plgs1 =
700d                 (select b.usgs1b from ucisplits as b where
700d                       b.usgs1c = :puci);

700d            // delete Unassigned so it will be re-calculated
700d            // after next completion
700d            exec sql delete from ucisplits
710hD       //       where usgs1c = :puci and usgs1b = '*UNASSIGNED';
710hM                where usgs1c = :puci and usgs1b = '*UNASSIGNED'
710hA                  and usbxbsq = :pCaseSeq;
700d
700d            // apply full case weight back to all other breakdowns
700d            // and it will zero all but first one on next accept
700d            exec sql update ucisplits
700d                 set usfwgt = :pCaseWgt
710hD       //       where usgs1c = :puci;
710hM                where usgs1c = :puci
710hA                  and usbxbsq = :pCaseSeq;
700d
700d            // add back case quantity to Line Slot in Prod
                // ** check to make sure pDisp is available

700d            eachAdjust = *off;
700d            exsr updCaseQty;
700d
700d            // Reset Label History records when user returns to uci
700d            exec sql update prdlbhist
700d                 set lhstat = 'O'
710hD     //         where lhstat = 'C' and lhuci = :puci;
710hM                where lhstat = 'C' and lhuci = :puci
710hA                  and lhbxbsq = :pCaseSeq;

                resetFlag = '1';

         endsr;

       //---------------------------------------------------------
       // rtvScale - Retrieve the passed in Scale record
       //            Place in SCREC data structure for use
       //---------------------------------------------------------

         begsr rtvScale;

         // When coming from Work Order Screen see if MultiDay Work
         // order or Single Day.  If MultiDay read first Scale Record
         // otherwise read active station sent in
         select;
            when (pLsts = '*closemult' and pStation='99')
710kA         or (pStation=*blanks and (pLsts='*STRLAB' or pLsts='*CLSLAB'));
               exec sql select * into :screc
                    from scale order by scsta
                    fetch first row only;
            other;
               exec sql select * into :screc
                    from scale
                    where scsta = :pStation;
         endsl;

740 D     //if Sqlstt <> sqlSuccess;
740 M     if Sqlstt <> sqlSuccess;
             clear screc;
             scstat = 'X';
             scweght = 0;
             sctype = ' ';
             scdest = ' ';
             sccust = 0;
             scordnbr = 0;
             scdemo = 'N';
             scdemowgt = 0;
             scdemouom = ' ';
740 A        if pStation<>*blanks and pStation<>'nu';
710kA          $drimessage = 'Station is invalid for Scale Select';
710kA          pOutStr = '{'
710kA             +  '"drslt":"'  + %trimr($drimessage) + '"'
710kA             + '}';
740 A        endif;
             return;
          else;

             // GET PRODUCTION OPTIONS
             popcode = '*PROD';
             chain (scwhse:popCode) options;
             if not %found(options);
                clear oprec;
             endif;

710lA        if %subst(opdata:29:1)='Y';
710lA           stdOnly = 'Y';
710lA        else;
710lA           stdOnly = 'N';
710lA        endif;

             sctare = pTare;
             sctype = pType;
             scdest = pDest;
             sclitm = pItem;
             sccust = pCust;
             scwo = %trim(pWo);
710aA        // get mfg line from work order
710aA        if pWo <> *blanks;
710aA           chain (scwhse:pWo) pwrkord;
710aA           if %found(pWrkORd);
710aA              scMfgno = woMfgno;
710aA           endif;
710aA        endif;
             scordnbr = pordnbr;
             dqwhse = scwhse;
             dqScale = scid;

            // if label count passed from MRC client is less than
            // in Scale record we should change Scale record to
            // ensure all label records have printed.

            // currently serial number used in this label file
            // is 5 digit julian date (yyddd), 2 digit mfg line,
            // and 5 digit sequence of goods packed for the day
            // within that mfg line

             if sclblc > pLblc;
                sclsts = %subst(sclsts:1:7) +
                   %trim(%editc(pLblc:'X'));
             endif;

             // set Production Date
             chain (scwhse:scmfgno) plined;
             if %found(plined);
                chain(n) (scwhse:scmfgno:'O') prddate1;
710jA           if not %found(prddate1);
710jA              // if not production date found and warehouse
710jA              // only uses Bx Breaker then pass current date
710jA              // in Production Date (pddate)
740 D              //if %subst(opdata:24:1) = 'B';
740 A              if %subst(opdata:24:1) = 'B' or scwo='GENERATEITEM';
710jA                 pddate = %uns(%char(%Date():*Iso0));
710jA              endif;
710jA           endif;
             endif;

          endif;

         endsr;

       //---------------------------------------------------------
       // rtvItem - Retrieve the passed in Item record
       //           Place in ITREC data structure for use
       //---------------------------------------------------------

         begsr rtvItem;

        // get item description
          if pItem <> ' ';
             exec sql
              select *
               into :itrec
                from piritem
                 where ititem = :pItem;

          if Sqlstt <> sqlSuccess;
             itemdesc = '** Invalid Item **';
          else;
             // if item valid but upc cross reference not found and
             // item code not all numeric if cross reference missing
             setll (itwhse: ititem) upc2;
             reade (itwhse: ititem) upc2;
             if not %equal(upc2);


             If Non_Num_Posn > 0;
700fD       //  itemdesc = '** UPC not defined **';
             else;
                itemdesc = itdesc;
             EndIf;

             else;
                if pWo <> 'GENERATEITEM';
                  // make sure this is a finished good with a bom
                  chain (itwhse:ititem) itemprd;
                  if not %found(itemprd);
                     itemdesc = '** Item must be Production FG **';
                  else;
710 D   //          if ipprdflg <> 'F';
710 A                if ipprdflg <> 'F' and ipprdflg<>'C';
                        itemdesc = '** Item must be Production FG **';
                     else;
                        // make sure bill of materials exists
                        setll (itwhse:ititem) pbom;
                        reade (itwhse:ititem) pbom;
                        if not %equal(pbom);
                           itemdesc = '** Item must have Bill of Material **';
                        else;
                           itemdesc = itdesc;
                        endif;
                     endif;
                  endif;
                endif;
             endif;
          endif;

          else;
             itemdesc = ' ';
          endif;

         endsr;

       //---------------------------------------------------------
       // rtvCust - Retrieve the passed in Customer info
       //           Place in CUSTREC data structure for use
       //---------------------------------------------------------

         begsr rtvCust;

       // get customer description
          if pCust <> 0;
             exec sql
              select *
               into :custrec
                from custmast
                 where cmwhse=:scwhse and cmcust = :pCust;

          if Sqlstt <> sqlSuccess;
             cmname = 'invalid customer';
          endif;

          endif;

         endsr;

       //---------------------------------------------------------
       // updScale  Update the incoming Scale record
       //---------------------------------------------------------

          begsr updScale;

           exsr demoWeight;
      /end-free
      *
      *  Screen calls SCLSTAT and updates value SCPTS in Scale
      *  record to point out it is actively up on a session on
      *  some browser.  If the user goes to another application
      *  or it loses connection the scale will know NOT to produce
      *  any labels if weights change and settle.  On the flip side
      *  another value in the Scale record is SCSKTTS.  This is
      *  updated by BFCSKTSCL when labels are produced or a time out
      *  of the socket occurs.  If this goes more than 1 minute it
      *  will return an error and force the user out with a not
      *  communicating.  This could occur if the BFCSKTSCL socket job
      *  is ended for the respective scale and port.
      *  ---  MAKE SURE if TimeZone/400 is used that both the user
      *  that starts the scale process and the GUI users have the
      *  same settings.  Otherwise the scale will bounce between
      *  communicating and not communicating because of time diff ---
      *
     C                   eval      currstampsys = %timestamp()
     C     currstampsys  adddur    -2:*Seconds   currstamploc
     c                   if        currstamploc<=scpts
     C     currstampsys  adddur    -45:*Seconds  currstampskt
     c                   endif

      /free
           if currstamploc > scpts and scstat <> 'X'
              or currstampskt > scsktts and scstat <> 'X';
             // scale no longer communicating.  Reset scale record
             // to not communicating
              exec sql
               update SCALE
                set sctype = :pType,
                  scdest = :pDest,
                  sctare = :ptare,
                  sclitm = :pitem,
                  scuser = :puser,
                  scordnbr = :pordnbr,
                  sccust = :sccust,
                  scstat = 'X'
               where scsta = :pStation;

           else;

             if lstary>0;
                lhlsts = rtnsts(lstary);
                lhlblc = rtncnt(lstary);

                exec sql
                  update SCALE
                    set sctype = :ptype,
                     scdest = :pdest,
                     sctare = :ptare,
                     sclitm = :pitem,
                     scuser = :puser,
                     sccust = :sccust,
                     scordnbr = :pordnbr,
                     scwo = :pwo,
                     sclsts = :lhlsts,
                     sclblc = :lhlblc,
                     scpts = :currstampsys
                      where scsta = :pStation;

             else;

                exec sql
                  update SCALE
                    set sctype = :ptype,
                     scdest = :pdest,
                     sctare = :ptare,
                     sclitm = :pitem,
                     scuser = :puser,
                     sccust = :sccust,
                     scordnbr = :pordnbr,
                     scwo = :pwo,
                     scdemowgt = :demowgt,
                     scpts = :currstampsys
                      where scsta = :pStation;

              endif;
          endif;

          endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  gloSession  - Write Glo Session record
650aA*  Write GloSession record when activity takes place to assist
650aA*  with debugging and tracking user who made change
650aA*----------------------------------------------------------------

650aA /free
650aA    begsr gloSession;
650aA    // Write GLOSESSLOG record
650aA
650aA    logText = 'command:' + pLsts + ','
650aA            + 'station:' + pStation + ','
650aA            + 'item:' + pItem + ','
650aA            + 'cust:' + %char(pCust);
650aA    wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);
650aA
650aA    endsr;
650aA /end-free

500cA*----------------------------------------------------------------
500cA*  sndDTAQ    Send Label reprint command for last label
500cA*----------------------------------------------------------------
500cA
500cAC     sndDTAQ       begsr

     c                   eval      dqname = 'SCALES'
     c                   eval      dqlib = '*LIBL'

     c                   if        chkDriErr <> ' '
     c                   eval      dqdata = '*clrerror'
     c                   else
      *  setup data for either a Reprint or Manual Label
     c                   if        %trim(pLsts)='*reprint'
     c                   eval      dqdata = '*reprint ' + lhlsts
     c                                  + '::' + lhdtetim
     c                   else
      /free
                         if        %trim(pLsts)='*demo';
                                   demowgtext = demowgt * 1000;
                                   dqdata = '*demo' +
                                   '::' +
                                   %editc(demowgtext:'X');
      /end-free
     c                   else
     c                   if        %trim(pLsts)='*blkser'
     c                   eval      dqdata = '*blkser'
     c                   else
     c                   if        %trim(pLsts)='*prtlabel'
     c                   eval      dqdata = '*prtlabel'
     c                   else
     c                   if        %trim(pLsts)='*nolabel'
     c                   eval      dqdata = '*nolabel'
     c                   else
     c                   if        %trim(pLsts)='*close'
     c                   eval      dqdata = '*close'
     c                   else
     c                   eval      outWgt = pMwgt * 100
710 Ac                   eval      outTare = pTare * 100
     c                   eval      dqdata = '*manual::'
     c                               + %editw(pMqty:'0    ')
     c                               + '::'
     c                               + %editw(outWgt:'0         ')
     c                               + '::'
710 Ac                               + %editw(OutTare:'0         ')
     c                   endif
     c                   endif
     c                   endif
     c                   endif
     c                   endif
     c                   endif
     c                   endif

     c                   eval      dqkeylen = 15
     c                   eval      dqwait = 0
     c                   eval      dqlen = %len(%trim(dqdata))

     C                   call      'QSNDDTAQ'
     C                   parm                    dqname
     C                   parm                    dqlib
     C                   parm                    dqlen
     C                   parm                    dqdata
417bAC                   parm                    dqkeylen
417bAC                   parm                    dqkey

     c                   endsr

500cA*----------------------------------------------------------------
500cA*  updProdSlot -   Only called during the Delete label process
500cA*                  in this function so all Scale fields are replaced
500cA*                  with PrdLbHist fields since types can be mixed
500cA*                  in the grid to choose to delete
500cA*----------------------------------------------------------------
500cA
500cAC     updProdSlot   begsr
      /free

                savever# = $ppver#;
                $ppver# = savever#;

730aA           chain (lhwhse:lhlitm) itemprd;
                lhmfgno = %dec(%subst(lhlsts
                  :9:2) :3 :0);
                if lhmfgno <> 0;
                   chain (lhwhse:lhmfgno) plined;
                   if %found(plined);

                      prdSlot = ' ';
720 D     //          if lhdest = 'C';     // customer
720 D     //            $ppshparu = *on;   // set values to look fcust slt
720 D     //            $ppshpar = lhdisp;
720 D     //            $pppararu = *off;
720 D     //            $ppparar = ' ';
720 D     //          else;
720 D     //             if lhdest = 'P';       // par stock
720 D     //               $pppararu = *on;
720 D     //               $ppparar = lhdisp;
720 D     //               $ppshparu = *off;
720 D     //               $ppshpar = ' ';
720 D     //             else;
720 D     //               $ppshparu = *off;
720 D     //               $ppshpar = ' ';
720 D     //               $pppararu = *off;      // else set par off
720 D     //               $ppparar = ' ';
720 D     //             endif;
720 D     //          endif;
720 A                 select;
730aD                  //when %subst(lhlitm:1:3)='WIP';   // WIP Stock to Lin slot
730aD                  //when ipPrdFlg='C';                 // WIP Stock to Lin slot
730aD                  //  $pprcvau = *on;
730aD                  //  $pprcva = lhdisp;
720 A                  when lhdest = 'C';     // customer
740MA                    $ppshpau = *off;      // set values to look fcust slt
740MA                    $ppshpa = *blanks;
740aA                    $pppararu = *on;
740dA                    $ppparar = lhdisp;
720 A                  when lhdest = 'P';       // par stock
740aA                    $pppararu = *on;
740dA                    $ppparar = lhdisp;
740aA                    $ppparau = *off;
740aA                    $pppara = *blanks;
720 A                 endsl;

                   endif;
                endif;

                if lhlitm <> '';
                   chain (lhwhse:lhlitm) piritem;
                   if %found(piritem);
                      $ppwhdpu = *on;
                      $ppwhdp  = itwhdp;
                      $ppitemu = *on;
                      $ppitem  = ititem;
                   endif;
710jA              if scbblcns='*PICK' and itum2=*blanks;
710jA                 leavesr;
710jA              endif;
                endif;

                $ppgs1u = *on;
                $ppgs1 = lhgs1;
                $ppser#u = *on;
                $ppser# = lhlsts;
                $ppwgtu = *on;
                $ppwgt = lhweght * -1;
                $pptareu = *on;
                $pptare = lhtare;
                $ppwhseu = *on;
                $ppwhse  = lhwhse;
                $pplnenou = *on;
                $pplneno = lhmfgno;
                $ppscaleu = *on;
                $ppscale = lhsta;
                $ppcustu = *on;
                $ppcust = lhcust;
                $ppWo#u = *on;
                $ppWo# = lhwo;
                $pptypeu = *on;
                $pptype = lhtype;
                $ppdestu = *on;
                $ppdest = lhdest;
720 A      // if Wip Item then send to Lin slot instead of PAR or CUS slot
730aD           //if %subst(lhlitm:1:3)='WIP';
730aD           //   $ppdest = 'M';
730aD           //endif;
                $ppqty1u = *on;
                $ppuser = pUser;
                $ppuseru = *on;
                if plsts = '*bbcancel';
                   $pptrn#u = *on;
                   $pptrn# = svtran;
                else;
                   $pptrn#u = *on;
                  $pptrn# = sctran;
                endif;
                $ppadjcdeu = *on;
                $ppadjcde = 'P4';
710bD           if lhuci <> *blanks;
                   $ppActionu = *on;
                   $ppAction = 'BXB';
700 A              $ppadjcde = 'B1';
700 A              $ppActionu = *on;
700 A              $ppAction = 'BXB';
700 A              $ppuciu = *on;
700 A              $ppuci = lhuci;
700 A              $ppdspbbu = *on;
700 A              $ppdspbb = lhdspbb;
700 A              // if from Box Breaker we are creating quantity in
700 A              // breakdown one quantity, not case quantity
700 A              // Case quantity will be reduced in separate command
700 A              // when things are completed.
700 A              $ppQty1 = 0;
700 A              $ppQty2 = -1;
700 A           else;
                   $ppActionu = *on;
                   $ppAction = 'PSC';
700 A              $ppuciu = *off;
700 A              $ppuci = *blanks;
700 A              $ppdspbbu = *off;
700 A              $ppdspbb = *blanks;
                   $ppqty1 = -1;
700 A           endif;

710bA           // pass rm uci for dry age production
710bA           // Get RM UCI from Prodlog Record
710bA           exec sql select * into :plrec
710bA                  from prodlog
710bA                where pllsts = :lhlsts
710bA              fetch first row only;
710bA           if sqlStt = sqlSuccess and plRmUci<>*blanks;
710bA              $ppRmUciu = *on;
710bA              $ppRmUci = plRmUci;
710bA           else;
710bA              $ppRmUciu = *off;
710bA              $ppRmUci = *blanks;
710bA           endif;

                $dricommand = '*PROD';
                $drisubcmd = '%ADJQTY';
                $drisys2upd = 'D';
                exsr zzDriCop;
                if wkerror;
                   wkCrtProdErr = '*PRDERR';
                else;
700 A              if $ppAction = 'BXB';
700 A                 prdSlot = $ppDspbb;
700 A              else;
                      if lhdest = 'P';
                         prdSlot = $ppparar;
                      endif;
                      if lhdest = 'C';
                         prdSlot = $ppshpar;
                      endif;
720 A      // if Wip Item then return Lin Slot instead of Par or Cust slot
730aD                //if %subst(sclitm:1:3)='WIP';
730aD                //    prdSlot = $pprcvar;
730aD                //endif;
                   endif;
700 A           endif;
      /end-free

     c                   endsr

500cA*----------------------------------------------------------------
500cA*  updCaseQty - Reduce 1 from case quantity when completing a Box
500cA*               Breaker transaction.  Breakdown Quantities are
500cA*               generated in BFCSKTSCL (Scale Socket) as weights
500cA*               change
500cA*----------------------------------------------------------------
500cA
500cAC     updCaseQty    begsr
      /free

                savever# = $ppver#;
                clear $pprod;
                clear $pprod2;
                $ppver# = savever#;

                $pppararu = *on;
                $ppparar = pDisp;

                exsr cvtBarCode;

               // reverse case quantity subtraction if coming
               // in the reverse the previous transaction
                if plsts = '*bbcancel';
                    exec sql
                    select plflcns,pltlcns
                     into :sflcns,:stLcns
                       from Prodlog
                       where plgs1 = :puci and pltrn# = :svtran
                             and plqtyn = -1
                       fetch first row only;
                       if sqlstt <> '00000';
                          leavesr;
                       else;
                          reverseCase = *on;
                       endif;
                endif;

                if %found(piritem);
                   $ppwhseu = *on;
                   $ppwhse  = itwhse;
                   $ppwhdpu = *on;
                   $ppwhdp  = itwhdp;
                   $ppitemu = *on;
                   $ppitem  = ititem;
                endif;

                $ppser#u = *on;
                $ppser# = $bcSer#;
                $ppwgtu = *on;
                if reverseCase;
                   $pptrn#u = *on;
                   $pptrn# = svtran;
                   $ppwgt = pCaseWgt;
                else;
                   if eachAdjust;
                      $ppwgt = pWgtGen * -1;
                   else;
700d                  // on a reset add case quantity back
700d                  if Plsts = '*bbreset';
700d                     $ppwgt = pCaseWgt * +1;
700d                  else;
                         $ppwgt = pCaseWgt * -1;
700d                  endif;
                   endif;
                   $pptrn#u = *on;
                   $pptrn# = sctran;
                endif;
                $pptareu = *on;
                $pptare = 0;
                $pplnenou = *on;
                $pplneno = scmfgno;
                $ppscaleu = *on;
                $ppscale = pStation;
                $ppcustu = *off;
                $ppcust = 0;
                $ppWo#u = *off;
                $ppWo# = *blanks;
                $pptypeu = *on;
                $pptype = 'A';
                $ppdestu = *on;
                $ppdest = 'P';
                $ppqty1u = *on;
                $ppuser = pUser;
                $ppuseru = *on;
                $ppadjcdeu = *on;
700 A           $ppadjcde = 'B1';
700 A           $ppActionu = *on;
700 A           $ppAction = 'BXB';
700 A           $ppuciu = *on;
700 A           $ppuci = puci;
700 A           $ppgs1u = *on;
700 A           $ppgs1 = puci;
700 A           $ppdspbbu = *on;
700 A           $ppdspbb = pDisp;
700 A           if reverseCase;
700 A              $ppQty1 = 1;
700 A              $ppQty2 = 0;
700 A           else;
700 A              if eachAdjust;
700 A                 $ppQty1 = 0;
700 A                 $ppQty2 = eachCnt * -1;
700 A              else;
700d                  if Plsts = '*bbreset';
700d                     $ppQty1 = 1;
700d                     $ppQty2 = 0;
700d                  else;
700 A                    $ppQty1 = -1;
700 A                    $ppQty2 = 0;
700d                  endif;
700 A              endif;
700 A           endif;

                $dricommand = '*PROD';
                $drisubcmd = '%ADJQTY';
                $drisys2upd = 'D';
                exsr zzDriCop;
                if wkerror;
                   wkCrtProdErr = '*PRDERR';
                else;
700 A              prdSlot = $ppDspbb;
700 A           endif;
      /end-free

     c                   endsr

500cA*----------------------------------------------------------------
500cA*  woLvlFlds  -   get Work Order passed in.  It will then return
500cA*                 the primary item and primary produced, secondary
500cA*                 produced and Make quantity to display for the
500cA*                 production personnel
500cA*----------------------------------------------------------------
500cA
     c     woLvLFlds     begsr
      /free

            chain (scWhse: pWo) pwrkord;
            if %found(pwrkord);
               rtnPriItm = woitem;
               rtnMake = womake;
               rtnPriQty = woqtyp;
               rtnSecQty = woqtys;
            else;
               rtnPriItm = pitem;
               rtnMake = 0;
               rtnPriQty = 0;
               rtnSecQty = 0;
            endif;

      /end-free
     c                   endsr
     *----------------------------------------------------------------
     *  ZZCRTTRAN     Create putaway transaction
     *----------------------------------------------------------------

     C     zzcrttran     begsr

     *    Put license into RCV slot for Breakdown Quantity created

     C                   exsr      zzurcvSlot
     *
     *        Create transaction record.
     *
     c                   if        not wkError
     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#
     C                   parm      'PUTEMP'      @ptask
     C                   parm      scwhse        @pwhse
     C                   parm                    @pwhdp
     C                   parm                    @pstyp
     C                   parm      lbcube        @pcube
     C                   parm      lbswgt        @pswgt
     C                   parm      lbqpck        @ppcs
     C                   parm      1             @paisl
     C                   parm      1             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      ' '           @ppo
     C                   parm      'K'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg

     *  Update/Create License

      /free
                         chain (scwhse:$saToLcns) license;
                         litrn# = pttrn#;
                         if %found(license);
                         update lirec;
                         else;
      /end-free
     *     Record not found. Try adding record.
     *
     C                   eval      liwhse = scwhse
     C                   eval      lilcns = $saToLcns
     C                   write     lirec
     C                   endif
     c                   endif

530 A*    Update licinfo.
530 AC                   exsr      zzlicinfoupd

     C     endcrttran    endsr

     *---------------------------------------------------------------
     *
     *  zzurcvSlot   Put license into RCV slot
     *
     C     zzurcvSlot    begsr

710eA /free
710eA             // get line slot for given raw material
710eA             // and Mfg Line
710eA             savever# = $ppver#;
710eA             clear $pprod;
710eA             clear $pprod;
710eA             $ppver# = savever#;
710eA
710eA             if scMfgNo <> 0;
710eA                chain (scwhse:scMfgno) plined;
710eA                if %found(plined);
710eA                   $ppdesc = indesc;
710eA                   $pprcvau = *on;
710eA                   $pprcva = inrcvaisl;
710eA                else;
710eA                   $pprcvau = *on;
710eA                   $pprcva = 'LIN';
710eA                endif;
710eA             else;
710eA                $pprcvau = *on;
710eA                $pprcva = 'LIN';
710eA             endif;
710eA
710eA             $ppwhdpu = *on;
710eA             $ppwhdp  = itwhdp;
710eA             $ppitemu = *on;
710eA             $ppitem  = upitem;
710eA             $ppwhseu = *on;
710eA             $ppwhse  = scwhse;
710eA             $pplnenou = *on;
710eA             $pplneno = scmfgno;
710eA             $ppuser = pUser;
710eA             $ppuseru = *on;
710eA
710eA             $dricommand = '*PROD';
710eA             $drisubcmd = '%GETMIN';
710eA             $drisys2upd = 'D';
710eA             exsr zzDriCop;
710eA
710eA             expd = $ppExpDt;
710eA /end-free
     C                   move      today         curdate
     C                   move      today         $pindt

     *  Get batch number for labels.

     C                   call      'PIRBAT#'
     C                   parm      *zeros        $pbat

     *  Get transaction number.

     C                   call      'PIRTRN#'
     C                   parm                    pttrn#
      /free
                // get total quantity and weight associated with
                // Transaction for this breakdown
                    exec sql
                    select sum(lhqty),sum(lhweght)
                     into :eachcnt,:pWgtGen
                       from prdLbHist
                       where lhtran = :sctran
                             and lhstat <> 'D';
      /end-free
     *  Create label record for Breakdown 1 Qty

     C                   clear                   lbrec
     C                   eval      lbwhse = scwhse
     C                   eval      lbwhdp = itwhdp
     C                   eval      lbaisl = *blanks
     C                   eval      lbloc = *zeros
     C                   eval      lbrlvl = *zeros
     C                   eval      lbhand = *blanks
     C                   eval      lbpseq = *zeros
     C                   eval      lbstyp = *blanks
     C                   eval      lbqryf = *zeros
     C                   eval      lbdisp = *blanks
     C                   movel     '*MANUAL'     lbdsp2
     C                   eval      lbitem = upitem
     C                   eval      lbseq = *zeros
     C                   eval      lbpbat = $pbat
     C                   eval      lbpo = *blanks
     C                   eval      lbord = 0
     C                   eval      lbqalc = eachCnt
     C                   eval      lbqpck = eachCnt
     C                   eval      lbtie = *zeros
     C                   eval      lbhigh = *zeros

     *        Create label record for Breakdown 1

     C                   eval      lbutyp = '1'
     C                   eval      lbucod = itum2
     c                   if        itumq2 <> *zeros
     C                   eval      lbucub = itcube / itumq2
     C                   eval      lbuwgt = itswgt / itumq2
     c                   else
     C                   eval      lbucub = itcube
     C                   eval      lbucub = itswgt
     c                   endif
     C     lbucub        mult      eachcnt       lbcube
     C                   eval      lbswgt = pWgtGen
     *
     C                   eval      lbtrn# = pttrn#
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbgrp1 = 'P'
     C                   eval      lbgrp2 = *blanks
     C                   eval      lbtype = 'P'
     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = curdate
     C                   time                    lbstim
     C                   eval      lbrdte = curdate
     C                   write     lbrec

     *  Put license into a RCV slot

     C                   eval      #rcvArea = 'BOXB'

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#u = *on
     C                   eval      $saemp# = #emp#
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = scwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = itwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = upitem
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slrlvlu = *on
     C                   eval      $slstyp = itstyp
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = expd

     c                   eval      $saitemu = *on
     c                   eval      $saitem = upitem
     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = eachcnt
     C                   eval      $saqty3 = 0

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'BXB'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = pttrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = lblbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     c                   if        humanLcns <> *blanks
     c                   eval      $saToLcns = humanLcns
     c                   else
     C                   eval      $saToLcns = '*BB'
     c                   endif
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea

     c                   eval      $saFrmLcnsU = *on
     c                   eval      $saFrmLcns = pltlcns
     c                   eval      $saoLcnsU = *on
     c                   eval      $saoLcns = pltlcns

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%RCVIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmsflag  = *on
     C                   exsr      zzdricop
     C                   if        wkError = *on
     C                   goto      endurcvslot
     c                   else
      *  generate Licinfo record for non pick slot breakdowns
     c                   if        pBxbp = 'N'
     c                   exsr      zzlicinfonew
     c                   endif
      *  when successful remove each quantity from Line(LIN-101-1) slot
     c                   eval      eachAdjust = *on
     c                   exsr      updCaseQty
     C                   endif

     C     endurcvslot   endsr
     *----------------------------------------------------------------
     *  zzdriCop   Call DRICOP
     *----------------------------------------------------------------

     c     zzDriCop      begsr
     *
     c                   eval      wkError = *off
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                   eval      $dridata = $pprod
     c                   eval      $dridata2 = $pprod2
     c                   when      $dricommand = '*LICINFO'
     c                   eval      $dridata = $LICINFO
700 Ac                   eval      $dridata2 = $LICINFO2
     c                   when      $dricommand = '*SLOT'
     c                   eval      $dridata = $slot
     c                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
720bAC                   eval      $dridata2 = $uciinfo2

     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                              or $dricommand = '*SLOT'
     c                              or $dricommand = '*LICINFO'
720bAc                              or $dricommand = '*UCIINFO'
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      errmsg    = 'Error occured on call to '
     c                                       + 'DRICOP'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*PROD'
     c                   eval      $pprod = $dridata
     c                   eval      $pprod2 = $dridata2
     c                   when      $dricommand = '*LICINFO'
     c                   eval      $LICINFO = $dridata
700 Ac                   eval      $LICINFO2 = $dridata2
     c                   when      $dricommand = '*SLOT'
     c                   eval      $slot = $dridata
     c                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
720bAC                   eval      $uciinfo2 = $dridata2
     c                   endsl

     c                   endsr

640iA*----------------------------------------------------------------
640iA*  ZZZENDTRAN   End transaction
640iA*----------------------------------------------------------------
640iA
640iAC     zzzendtran    begsr
640iAC
     C                   call      'ADJTRAN2'
     C                   parm      '*CLOSE'      @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*INTER'      @ptype            8
     C                   parm      pTrn#         @ptrn#            7 0
     C                   parm      'BXBOX'       @ptask            6
     C                   parm      scWhse        @pwhse            3 0
     C                   parm      *blanks       @pwhdp            5
     C                   parm      itstyp        @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      pUser         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

     *----------------------------------------------------------------
     *  ZZLICINFONew Create new License info record
     *----------------------------------------------------------------

      /free
        begsr zzlicinfonew;

          // Write out standard license information
          exsr clr$licinfo;

          $lnwhse  = $slwhse;
          $lnlcns  = $saToLcns;
          $lnseq = 1;

          $lnseqqty = eachcnt;
          $lnttllbs = pWgtGen;
          $lnitem = $slitem;
          // LNRCVTYP notes
          // 1 = Manual quantity (original method)
          // 2 = Manual quantity with initial GS1 scan
          // 3 = UCI using Mfg GS1 barcodes
          // 4 = UCI using Internal GS1 barcodes (start with 99)
          // 5 = ASN file
          // 6 = Production Module
          // A = Box Breaker Breakdowns

          $lnrcvtyp = 'A';
          $lnrcvtrn# = pttrn#;
          $lnrcvlbl# = lblbl#;

          $lnentdate = %uns(%char(%Date():*Iso0));
          $lnenttype = '*MFGDTE';

          $lnmfgdays = 0;
          $lnusrdays = 0;
          $lndstdays = 9;

          $lnmfgdate = %uns(%char(%Date():*Iso0));

          $lnmfgexp = 0;

          $lnfifodate = %uns(%char(%Date():*Iso0));

          $lnexpdate = 0;

          $lnmfgcode = *blanks;

          $lnavglbs = 0;

          // get lot or serial# from original case UCI
          if $bcLotSent;
            $lnlot = $bclot;
          else;
            if $bcSer#sent;
               $lnlot = $bcser#;
            endif;
          endif;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%ADDS';
          $drisys2upd = 'D';
          exsr zzdricop;
          bugstate=2527;
          if debug;
            exsr wrtDebugParms;
          endif;
          if error;
          endif;

        endsr;
      /end-free

     *-----------------------------------------------------------------
     *  ZZLICINFOUPD  Close License when requested from User
     *-----------------------------------------------------------------

      /free
        begsr zzlicinfoupd;

          exsr clr$licinfo;
          $lnwhse  = scwhse;
          $lnlcns  = scbblcns;
          $lnseq  = 1;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          exsr zzdricop;
          if error;
          else;
            // accumulate the lnseqqty field
            // if NOT updating transaction#
            // and label #
            $lnrcvtyp = 'A';
            $lnRcvtrn# = pttrn#;
            $lnRcvlbl# = lblbl#;
            $lnrcvqty = $lnseqqty;
            $dricommand = '*LICINFO';
            $drisubcmd  = '%CHANGES';
            $drisys2upd = 'D';
            exsr zzdricop;
          endif;
        endsr;
      /end-free

      *----------------------------------------------------------
      *  wrtDebugParms  Write out debug parm record
      *----------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = '&pStation = ' + pStation
                  + '&pPgm=' + %trimr(pPgm)
                  + '&pUser=' + %trimr(pUser)
                  + '&pLblc=' + %trimr(%char(pLblc))
                  + '&pLsts=' + %trimr(pLsts)
                  + '&sclblc=' + %trimr(%char(sclblc))
                  + 'RC' + %trimr(%char(RC))
                  + 'lstary' + %trimr(%char(lstary))
                  + '$slwhse=' + %trimr(%char($slwhse))
                  + '$saToLcns=' + %trimr($saToLcns)
                  + 'eachcnt=' + %trimr(%char(eachcnt))
                  + 'pWgtGen=' + %trimr(%char(pWgtGen))
                  + '$driMessage=' + %trimr($driMessage)
                  + '&pOut=' + %trimr(pOutStr);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
