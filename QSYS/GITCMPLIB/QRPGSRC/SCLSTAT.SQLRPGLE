      /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*no)
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  SCLSTAT     Retrieve Scale Weight and Status
      *  31 March 2014
      *  Kenneth Elder
      *
      *  Revisions:
      *
     *    03/31/14  KDE  6.50
     *      - Created.
     *
650aA*    05/09/14  KDE  6.50a
     *      - Added pSessId, pUser, pPgm parms.
700 A*    04/10/15  KDE  7.00
     *      - Added code to support Box Breaker
700b *    11/18/15  DLS  7.00b
     *      - Changed where clause in CrtPrdLbHistRS to include
     *        narrow record set by current work order.
700c *    02/09/2016 KDE 7.00c
     *      - Changed *DELETE command for Box Breaker transaction
     *        to delete from UCI tables regardless of status in
700d *    02/21/2016 KDE 7.00d
     *      - Changed *BBRESET to also delete sum record
     *        *UNASSIGNED so it will be recalculated on the next
     *        complete
     *        PRDLBHIST
700e *     11/08/16  KDE  7.00e
     *       - Include SQL compile parms within SQL Set in Calcs
700f *     12/02/16  KDE  7.00f
     *       - Changed to no longer validate UPC here.  IT writes
     *         error to BFCSKTSCL using common error routine
700gA*    11/08/16  LMC  7.00g
     *      - Enh: UPC file has a database change. Recompile only.
710  *     02/03/17  KDE  7.10
     *       - Pass Tare weight with manuel label
710a *     02/06/17  KDE  7.10a
     *       - Recompile for new format of file CUSTMAST
     *       - Add code to use Mfg Line from Work ORder instead of Scale
     *         This allows user to override line from Scale file
710bA*    03/07/17  TAB  7.10b
     *      - Enh: Code change to handle use of I99 UCI
     *      - Fix: Force Weight values from DRIUCIINFO command
     *        when GS1 99I is scanned
     *      - Enh: Added new command %CKUCISPLT
720aA*    08/01/16  LMC  7.20a  reserved
     *      - Enh: UCI Tracking.
730aA*     01/30/19  KDE  7.30a
     *       - Enh: Recompile due to PWRKORD change
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
700 Afprddate1  if   e           k disk
     fpwrkord   if   e           k disk
700 Aflabel     uf a e           k disk
700 Aflicense   uf a e           k disk
     Fpiritem   if   e           k disk
416bAF                                     rename(itrec:itrec1)
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

700 A*----------------------------------------------------------------
700 A*  File data data structure
700 A*----------------------------------------------------------------

700 AD plrec         E ds                  extname(prodlog) inz(*EXTDFT)
700 AD slrec         E ds                  extname(slot) inz(*EXTDFT)

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

     d bugstate        s              5  0
     D EachAdjust      s               n
     d chkDriErr       s             60
700 AD ckupc           s             20
     D ck4err          s              1
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
     D Non_Num_Posn    S              2  0 Inz(*Zero)
     d NullInds        s              5i 0 inz(-1)
     D Numbers         S             11    Inz(' 0123456789')
     d numrecs         s              6  0
     D outWgt          s              9  0
710 AD outTare         s              9  0
     D $pbat           s              7  0
     d pCaseWgt        s              9  3
     D $pindt          s              8  0
     D pLhlsts         s             20
     d prdSlot         s             12
     d pRemWgt         s              9  3
     D pttrn#          s              7  0
     d svTran          s              7  0
     d pTrn#           s              7  0
     D popcode         s             10
     d pTrnCnt         s              5  0
     d pWgtGen         s              9  3
     D rc              s              3  0 inz(0)
     d resetflag       s              1
     d returnUCI       s            100
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
     D today           s              8  0
     d TodayJul        s              5
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
     c                   parm                    pOutStr

      /free
700eA       // Set SQL default parms
700eA       exec sql
700eA         set Option Commit=*none, Dlyprp=*Yes,
700eA                    Closqlcsr = *ENDMOD;

          *inlr = *on;
          exsr init;
          exsr chkDriError;
700 A     if pUCI <> *blanks;
             puci = %trim(puci);
700 A        pTrn# = pOrdNbr;
700 A        pOrdNbr = 0;
700 A        exsr cvtBarcode;
700 A        exsr CalcRemWgt;
             exsr TrnCount;
700 A     endif;
          select;
700 A        when Plsts = '*bbreset';
700 A           exsr rtvScale;
700 A           exsr updUCIINFO;
700 A        when Plsts = '*licset';
700 A           exsr rtvScale;
700 A           exsr updLicense;
             when Plsts = '*alter';
                exsr rtvScale;
                exsr genAlterItems;
             when Plsts = '*demo';
                exsr rtvScale;
                exsr DemoWeight;
                exsr sndDtaq;
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
           and Plsts <> '*demo';

          exsr updScale;

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

          // Put together JSON string
          pOutStr = '{'
                 +  '"scid":"'  + %trimr(scid) + '",'
                 +  '"scp":"'  + %trimr(%char(scport)) + '",'
                 +  '"sci":"'  + %trimr(sclitm) + '",'
                 +  '"itemd":"'  + %trimr(itemdesc) + '",'
                 +  '"cust":"'  + %trimr(%char(sccust)) + '",'
                 +  '"custnm":"'  + %trimr(cmname) + '",'
                 +  '"wgt":"'  + %trimr(%char(scWeght)) + '",'
                 +  '"uom":"'  + %trimr(scwuom) + '",'
                 +  '"stc":"'  + %trimr(itemColor) + '",'
                 +  '"sts":"'  + %trimr(StatDesc) + '",'
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
                 +  '"rmake":"'  + %trim(%char(rtnMake)) + '",'
                 +  '"rpriqty":"'  + %trim(%char(rtnPriQty)) + '",'
                 +  '"rsecqty":"'  + %trim(%char(rtnSecQty)) + '",'
                 +  '"type":"'  + %trimr(Sctype) + '",'
                 +  '"dest":"'  + %trimr(Scdest) + '",'
                 +  '"pRemWgt":"'  + %trimr(%char(pRemWgt)) + '",'
                 +  '"pTrnCnt":"'  + %trim(%char(pTrnCnt)) + '",'
                 +  '"mfgline":"'  + %trimr(%char(Scmfgno)) + '",'
                 +  '"drslt":"'  + %trimr(chkDriErr) + '",'
                 +  '"tare":"'  + %trimr(%char(Sctare)) + '"';

         // determine if any previous label information is returning
                    firstSent = *off;
                    rc = 1;
         // next line is used to test json if larger returns are posing
         // an issue.  The statement below will return 4 lines
                 if rtncnt(rc) <> 0;

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

                         #curruser = pUser;
             resetflag = '0';
             returnUCI = 'NA';
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
720aA                // Add some additional information for tracking
720aA                $uiaction = 'DELETEUCI';
720aA                $uiaolcns = $uilcns;
                     $dricommand = '*UCIINFO';
                     $drisubcmd  = '%DELETEUCI';
                     $drisys2upd = 'D';
                     exsr zzdricop;

                     exec sql
                      delete from ucisplits
                       where usgs1b = :lhgs1 and usgs1c = :lhuci;

                     exec sql
                      update PrdLbHist
                       set lhstat = 'D'
                       where lhlsts = :Lhlsts
                        and lhdtetim = :lhdtetim
                        and lhuci = :pUci;
                  endif;
                  exec sql
                   fetch next from UciCancel into :lhhst;
               enddo;
               // delete Unassigned UCISPLITS record
               exec sql
                delete from ucisplits
                 where usgs1b = '*UNASSIGNED' and usgs1c = :lhuci;
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
            eachAdjust = *off;
            exsr updCaseQty;
            pUci = *blanks;
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
                     'usgs1c=' + sq + %trim(pUci) + sq;

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
                 if pCaseWgt <> pWgtGen;
                    ustrn#=ptrn#;
                    usgs1b = '*UNASSIGNED';
                    usfwgt = 0;
                    ustwgt = pCaseWgt - pWgtGen;
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
                 endif;
                 // reduce case count by one
                 eachAdjust = *off;
                 exsr updCaseQty;
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
              // generate putaway if not broke down in pick slot
              if pBxbp = 'N';
                 if pLsts = '*bbcomplte';
                    exsr zzcrtTran;
                 endif;
              endif;
            endif;
            exec sql CLOSE UciComplt;
            // End Current Transaction before returning
            if Plsts = '*bbcomplte';
               exsr zzzEndTran;
               // blank UCI info before returning since you are returned to
               // previous screen
               pUci = *blanks;
               pDisp = *blanks;
               pTrn# = *zeros;
               exsr uciselect;
            else;
               // if user stated they were breaking down more of same item
               // leave transcation and slot open
               pUci = *blanks;
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
            select sum(lhweght-lhtare)
            into :pWgtGen :NullInds
            from PrdLbHist
              where lhuci = :pUCI and
                    lhstat <> 'D';
           if sqlstt <> '00000' or NullInds = -1;
              pRemWgt = pCaseWgt;
           else;
              pRemWgt = pCaseWgt - pWgtGen;
           endif;

      /end-free
     C                   endsr

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
              exsr uciselect;
              returnUCI = '';
           endif;
           if pLsts = '*bbcancel';
              exec sql
               select lhuci
                into :returnUCI :NullInds
                from PrdLbHist
                  where lhtran = :pTrn# and
                        lhstat <> 'D'
                  order by lhcts desc
                  fetch first row only;
              if sqlstt <> '00000' or NullInds = -1;
                 returnUCI = '';
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

710bAc                   else

710bAc                   if        $bcai99sent
710bA /free
710bA                    exsr clr$uciinfo;
710bA                    $uiWhse = scwhse;
710bA                    $uiuci  = puci;
710bA
710bA                    $dricommand = '*UCIINFO';
710bA                    $drisubcmd  = '%CKUCISPLT';
710bA                    $drisys2upd = 'D';
710bA                    exsr zzdricop;
710bA
710bA                    if $driReturn = '*OK';
710bA                       chain (scwhse:$uiitem) piritem;
710bA                       exec sql select upupc into :$cstr
710bA                               from upc
710bA                            where upwhse=:scWhse and upitem=:$uiitem
710bA                              and uputyp='N' and upuom=:itum1;
710bA                       select;
710bA                       when $uiwgtlbs <> *zeros;
710bA                          $bcPNtLbSent = *on;
710bA                          $bcPNtLb = $uiwgtlbs;
710bA                       when $uiwgtkgs <> *zeros;
710bA                          $bcPNtKgSent = *on;
710bA                          $bcPNtKg = $uiwgtkgs;
710bA                       other;
710bA                          $bcPNtKgSent = *off;
710bA                          $bcPNtKg = *zeros;
710bA                          $bcPNtLbSent = *off;
710bA                          $bcPNtLb = *zeros;
710bA                       endsl;
710bA
710bA                       $bcgtin = %trim($cstr);
710bA                       Clear $cstr;
710bA                    endif;
710bA /end-free
710bAc                   endif
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
700 Ac                   if        $bcGtinSent
700 AC                   movel     $bcgtin       $CSTR
700 AC                   call      'ADJUST'
700 AC                   parm      '*RIGHT  '    $CCMD             8
700 AC                   parm                    $CSTR            30
700 Ac                   move      $cstr         ckupc
700 Ac                   endif
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
700 A                   ' and lhuci = ' + sq + pUCI + sq;
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
720aAC                   clear                   $uciinfo2
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

             dow Sqlstt = sqlSuccess;

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

                dow Sqlstt = sqlSuccess;

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
            exec sql
              select * into :LHHST from PrdLbHist
700cD    //    where lhlsts = :pLhlsts and lhstat = 'O'
700cA          where lhlsts = :pLhlsts
               fetch first 1 row only;
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
                        $uiUci = lhgs1;
                        $dricommand = '*UCIINFO';
                        $drisubcmd  = '%DELETEUCI';
                        $drisys2upd = 'D';
                        exsr zzdricop;
                     endif;

                     if $drimessage = ' ';
                        exec sql
                         delete from ucisplits
                          where usgs1b = :lhgs1 and usgs1c = :lhuci;
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

       //---------------------------------------------------------
       // UciSelect - Update Scale record with UCI and Slot Box Brker
       //---------------------------------------------------------

          begsr UciSelect;

                exec sql
                  update SCALE
                    set scuci = :pUci,
                     scdisp = :pdisp,
                     sctran = :pTrn#
                      where scsta = :pStation;

         endsr;

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
700d
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
700d                 where usgs1c = :puci and usgs1b = '*UNASSIGNED';
700d
700d            // apply full case weight back to all other breakdowns
700d            // and it will zero all but first one on next accept
700d            exec sql update ucisplits
700d                 set usfwgt = :pCaseWgt
700d                 where usgs1c = :puci;
700d
700d            // add back case quantity to Line Slot in Prod
                // ** check to make sure pDisp is available

700d            eachAdjust = *off;
700d            exsr updCaseQty;
700d
700d            // Reset Label History records when user returns to uci
700d            exec sql update prdlbhist
700d                 set lhstat = 'O'
700d                 where lhstat = 'C' and lhuci = :puci;

                resetFlag = '1';

         endsr;

       //---------------------------------------------------------
       // rtvScale - Retrieve the passed in Scale record
       //            Place in SCREC data structure for use
       //---------------------------------------------------------

         begsr rtvScale;

          exec sql
           select *
            into :screc
             from scale
              where scsta = :pStation;

          if Sqlstt <> sqlSuccess;
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
             return;
          else;

             // GET PRODUCTION OPTIONS
             popcode = '*PROD';
             chain (scwhse:popCode) options;
             if not %found(options);
                clear oprec;
             endif;

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
                  chain (scwhse:scmfgno:'O') prddate1;
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
                // make sure this is a finished good with a bom
                chain (itwhse:ititem) itemprd;
                if not %found(itemprd);
                   itemdesc = '** Item must be Production FG **';
                else;
710 D   //        if ipprdflg <> 'F';
710 A              if ipprdflg <> 'F' and ipprdflg<>'C';
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

                lhmfgno = %dec(%subst(lhlsts
                  :9:2) :3 :0);
                if lhmfgno <> 0;
                   chain (lhwhse:lhmfgno) plined;
                   if %found(plined);

                      prdSlot = ' ';
                      if lhdest = 'C';     // customer
                        $ppshparu = *on;   // set values to look fcust slt
                        $ppshpar = lhdisp;
                        $pppararu = *off;
                        $ppparar = ' ';
                      else;
                         if lhdest = 'P';       // par stock
                           $pppararu = *on;
                           $ppparar = lhdisp;
                           $ppshparu = *off;
                           $ppshpar = ' ';
                         else;
                           $ppshparu = *off;
                           $ppshpar = ' ';
                           $pppararu = *off;      // else set par off
                           $ppparar = ' ';
                         endif;
                      endif;

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
                if lhuci <> *blanks;
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
720aAC                   eval      $dridata2 = $uciinfo2

     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                              or $dricommand = '*SLOT'
     c                              or $dricommand = '*LICINFO'
720aAc                              or $dricommand = '*UCIINFO'
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
720aAC                   eval      $uciinfo2 = $dridata2
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
                  + 'statememt' + %trimr(%char(bugstate))
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
