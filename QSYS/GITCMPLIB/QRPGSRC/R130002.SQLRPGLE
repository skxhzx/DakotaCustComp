      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  R13000  Update Production Raw Material Summary file
     *  08 Jan 2015
     *  Kenneth Elder
     *
     *  Revisions:
     *
700 A*    01/08/15  KDE  7.00
     *      - Created.
700aA*    11/05/15  KDE  7.00a
     *      - Correct the doubling of scrap factor between
     *        M16500 and this program
700bA*    12/13/15  KDE  7.00b
     *      - Correct normal breakdowns to add scrap to lowest
     *        breakdown level
700cA*    11/15/16  TAB  7.00c
     *      - Added code to check wrstat from fril Pkwrkordr
     *        for item substitution
700DA*    12/07/16  KDE  7.00d
     *      - Changed PRDQTYCONV to use variables from previous
     *        record.  Multiple record bills were using wrong values
700eA*    12/13/16  KDE  7.00e
     *      - Change the balance text fields to use fixed length.
     *        Needed to have min. length for SUBQAVL to work
700fA*    01/05/17  KDE  7.00f  --  Copy of R13000
     *      - Put changes in this program so it will also take Primal
     *        and SubPrimal into account when determining how many
     *        Finished Goods can be derived from Primal/SubPrimal
     *        Setup to do everything or only one Raw Material/Primal
     *        SubPrimal
710 A*    02/03/17  KDE  7.10
     *      - Change to consider Line in calculating replenishment
     *        requirements.  One line could have a Primal/SubPrimal
     *        associate and another not.  This can have an impact
     *        on the total replenishment.
     *      - Also change to allow Work Order to be passed in.  This
     *        Allows us to request specific information at a Work ORder
     *        and Raw MAterial level to display at that level on I122xx.
     *        If Work ORder passed it will not write record(s) to PRMSUM.
     *        It only returns json.  This is to prevent from wiping out
     *        Raw MAterial level record used on same screen.
     *      - Open pRmSum as User open.  Open as input only if WO passed
710aA*    03/20/17  KDE  7.10a
     *      - Add code to summarize replenishments needs for specific
     *        Primal.  Pass Mfg Line to select properly
     *      - Added. file PPRIMALBD to show Primal/SubPrimal Breakdowns
     *        when clicked on I122xx screen
     *      - Add Nullind for Left Join when no Primal is defined
710bA*    03/28/17  KDE  7.10b
     *      - Do not send back Non Primal total if none planned
710cA*    05/05/17  KDE  7.10c
     *      - Open PRMSUM if write is necessary for CRTWORPL command
710dA*    05/23/17  KDE  7.10d
     *      - TOTQTY2 not being calculated corrected
710eA*    05/26/17  KDE  7.10e
     *      - Fix  Send Eliminate Negative and Normal Breakdown back
     *        as JSON since hard to calc in MRC.
720 A*    07/11/18  KDE  7.20
     *      - Fix  PRMSUM not being written for replen creation if
     *        Primal exists
720aA*    10/27/18  KDE  7.20a
     *      - Fix  Change to includes for Replen Creation
720bA*    12/17/18  KDE  7.20b
     *      - Fix  Increase size of newqty fields
730aA*    02/18/19  KDE  7.30a
     *      - Enh  Pull existing stock for components from PAR slots
     *      - Fix  Fix problem where production quantity remaining not
     *             reflecting decimals
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kellys Foods
     *
KFSaA*    02/09/22  KDE  KFSa
     *      - Revised to consider "A" and "PR" status slots for
     *        available inventory.  We are moving built components
     *        directly into another LIN slot for use in next step
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     fprmsum    uf a e           k disk    usropn
     Fslot3     if   e           k disk
     fplined    if   e           k disk
710eAfpBom      if   e           k disk
710eAfpBomSub   if   e           k disk
710eAfpBomVers  if   e           k disk
710eAfpirItem   if   e           k disk
700fAfpPrimal   if   e           k disk
700fAfpSubPrimalif   e           k disk    prefix(a_)
700fAfpWrkOrdPs if   e           k disk
710aAfpPrimalBd uf a e           k disk
700fAfitemprdpsaif   e           k disk

KFSaA*----------------------------------------------------------------
KFSaA*  Customer id
KFSaA*----------------------------------------------------------------

KFSaA /copy qcopysrc,ID#KFS

     *----------------------------------------------------------------
      *  Parameters
     *----------------------------------------------------------------

650aAD  pSessId        s             40    varying
650aAD  pUser          s             10    varying
650aAD  pPgm           s             20    varying
     D  pObjLoc        s             10    varying
     D  pWhse          s              3p 0
     D  pRmItm         s             15    varying
     D  pWo            s             15    varying
710aAd  pLine          s              3  0
     D  pOutStr        s           1792    varying


650aAD* pSessId        s             40
650aAD* pUser          s             10
650aAD* pPgm           s             20
     D* pObjLoc        s             10
     D* pWhse          s              3p 0
     D* pRmItm         s             15
     D* pWo            s             15
710aAd* pLine          s              3  0
     D* pOutStr        s           1792

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d avl1            s              9  4
     d avl2            s              9  4
     d avl3            s              9  4
     d BomNegQty       s              6  0
     d BomReq          s              6  0
     d demandin        s              9  4
     d EndofJob        s               n
     d foundBom        s               n
     d foundAry        s               n
     d hldRm#          s             15
     d hldWo#          s             15
     d hldPrim         s             20
     d hldSubPrim      s             20
710aAd pPrim           s             20
650aAD logText         s            100
700fAd loopReqPrd      s             11  4
700fAd loopReqN        s              6  0
700fAd loopReq1        s              6  0
700fAd loopReq2        s              6  0
720bMd Newqtyn         s              6  0
720bMd Newqty1         s              7  0
720bMd Newqty2         s              7  0
     d NewPrdq         s              9  4
     d newQtyNeg       s               n
710aAd nullinds        s              5i 0 dim(27)
710aAd nullValue       s                   like(nullinds) inz(-1)
     d pMessage        s             99
     d prdSlot         s             12
700fAD psCnt           s              4  0 inz(0)
     D saveVer#        s                   like($ppver#)
     d smavlpnum       s             12  4
710eAd smReduceJson    s             12  4
710eAd smBomUom        s             15
     d wkbaseq         s              6  0
710aAd wkremn          s              6  0
     d wkprodq         s              9  4
710aAd wkremp          s              9  4
700fAd wkspsize        s              9  4
720 Ad replenCreation  s               n
     d subPrimIncr     s             10  4
700fAd subSize         s              9  4
     d totdmdq         s              6  0
     d totqtyn         s              6  0
     d totqty1         s              6  0
     d totqty2         s              6  0
     d totprdq         s              9  4
700fAd totdmdqh        s              6  0
700fAd totqtynh        s              6  0
700fAd totqty1h        s              6  0
700fAd totqty2h        s              6  0
700fAd totprdqh        s              9  4
700fAd totprdqhx       s              9  4
     d uomType         s              2
710aAD wherelabel      s            500
     d wkError         s               n
     d wkRerr2         s             50
     d wkrmdp          s             10  4
     d wkstat          s              1
     d wkqty2          s              6  0
     d wkumq2          s              3  0
     d wkumq3          s              3  0
     d woFound         s               n
     d wrkfgitm        s             15
     d wrkqty          s              5  0
     d wrkwhse         s              3  0
     d wrkwo#          s             13
     d wrtUpdRmQty     s               n

     *  Division result and remainder data structure

     d divresult       ds
     d  result                        9  4
     d   intresult                    5  0 overlay(result)
     d   intdec                       4  0 overlay(result:*next)

     *  Raw Material SQL Data Struction Record

     d rmsum           ds           221
     d   sqitem                      15    overlay(rmsum)
     d   sqfgi                       15    overlay(rmsum:*next)
     d   sqmake                       4  0 overlay(rmsum:*next)
     d   sqqtyp                       4  0 overlay(rmsum:*next)
     d   sqrmavl                      1    overlay(rmsum:*next)
     d   sqwost                       1    overlay(rmsum:*next)
     d   sqqtyn                       4  0 overlay(rmsum:*next)
     d   sqqty1                       4  0 overlay(rmsum:*next)
     d   sqqty2                       4  0 overlay(rmsum:*next)
     d   sqprdq                       9  4 overlay(rmsum:*next)
     d   sqscrf                       5  4 overlay(rmsum:*next)
     d   sqprimalold                  1    overlay(rmsum:*next)
     d   sqsubprmeold                 2  0 overlay(rmsum:*next)
     d   sqwrst                       1    overlay(rmsum:*next)
     d   sqdesc                      30    overlay(rmsum:*next)
     d   squm2                        2    overlay(rmsum:*next)
     d   squmq2                       3  0 overlay(rmsum:*next)
     d   squm3                        2    overlay(rmsum:*next)
     d   squmq3                       3  0 overlay(rmsum:*next)
     d   sqpuom                       2    overlay(rmsum:*next)
     d   sqippq                       9  4 overlay(rmsum:*next)
700fAd   sqwo#                       15    overlay(rmsum:*next)
700fAd   sqline                       3  0 overlay(rmsum:*next)
700fAd   squm1                        2    overlay(rmsum:*next)
710aAd   sqprim                      20    overlay(rmsum:*next)
710aAd   sqSubPrim                   20    overlay(rmsum:*next)
710aAd   sqSubDesc                   40    overlay(rmsum:*next)

     *  Raw Material SQL Data Struction Previous Record

    Dd rmsump          ds           221
     d   sqitemp                     15    overlay(rmsump)
     d   sqfgip                      15    overlay(rmsump:*next)
     d   sqmakep                      4  0 overlay(rmsump:*next)
     d   sqqtypp                      4  0 overlay(rmsump:*next)
     d   sqrmavlp                     1    overlay(rmsump:*next)
     d   sqwostp                      1    overlay(rmsump:*next)
     d   sqqtynp                      4  0 overlay(rmsump:*next)
     d   sqqty1p                      4  0 overlay(rmsump:*next)
     d   sqqty2p                      4  0 overlay(rmsump:*next)
     d   sqprdqp                      9  4 overlay(rmsump:*next)
     d   sqscrfp                      5  4 overlay(rmsump:*next)
     d   sqprimalpold                 1    overlay(rmsump:*next)
     d   sqsubprmold                  2  0 overlay(rmsump:*next)
     d   sqwrstp                      1    overlay(rmsump:*next)
     d   sqdescp                     30    overlay(rmsump:*next)
     d   squm2p                       2    overlay(rmsump:*next)
     d   squmq2p                      3  0 overlay(rmsump:*next)
     d   squm3p                       2    overlay(rmsump:*next)
     d   squmq3p                      3  0 overlay(rmsump:*next)
     d   sqpuomp                      2    overlay(rmsump:*next)
     d   sqippqp                      9  4 overlay(rmsump:*next)
700fAd   sqwo#p                      15    overlay(rmsump:*next)
700fAd   sqlinep                      3  0 overlay(rmsump:*next)
700fAd   squm1p                       2    overlay(rmsump:*next)
710aAd   sqprimp                     20    overlay(rmsump:*next)
710aAd   sqSubPrimp                  20    overlay(rmsump:*next)
710aAd   sqSubDescp                  40    overlay(rmsump:*next)
700fA*
700fA*   Array to keep up with proper quantities per a Primal/SubPrimal
700fA*
700fAD                 ds
700fAD aryPrimRM                    109    dim(1000)
700fAD  arypcde                      20    overlay(aryPrimRm:*next)
700fAD  aryscde                      20    overlay(aryPrimRm:*next)
710 Ad  aryLine                       3  0 overlay(aryPrimRm:*next)
700fAD  arypsize                      6  2 overlay(aryPrimRm:*next)
700fAD  arypfacuom                    2    overlay(aryPrimRm:*next)
700fAD  arypyield                     4  3 overlay(aryPrimRm:*next)
700fAD  aryspszpct                    4  3 overlay(aryPrimRm:*next)
700fAD  aryRmi                       15    overlay(aryPrimRm:*next)
700fAD  aryprdq                      13  4 overlay(aryPrimRm:*next)
700fAD  aryqtyn                       6  0 overlay(aryPrimRm:*next)
700fAD  aryqty1                       6  0 overlay(aryPrimRm:*next)
700fAD  aryqty2                       6  0 overlay(aryPrimRm:*next)
     d  aryMakeQty                    4  0 overlay(aryPrimRm:*next)
700fA*
700fA*   Array to keep up with SubPrimal Breakdowns
700fA*
700fAD                 ds
710aAD arySubPrim                   266    dim(100)
710aAd  arySubWhse                    3  0 overlay(arySubPRim:*next)
710aAD  arySubpcde                   20    overlay(arySubPrim:*next)
710aAD  arySubscde                   20    overlay(arySubPrim:*next)
710aAD  arySubDesc                   40    overlay(arySubPrim:*next)
710aAd  arySubLine                    3  0 overlay(arySubPRim:*next)
710aAD  arySubSpct                    4  3 overlay(arySubPRim:*next)
710aAD  arySubpSize                   6  2 overlay(arySubPRim:*next)
710aAD  arySubSize                    9  4 overlay(arySubPRim:*next)
710aAD  arySubUOM                     2    overlay(arySubPRim:*next)
710aAD  arySubReqq                   15    overlay(arySubPrim:*next)
710aAD  arySubReqp                   15    overlay(arySubPRim:*next)
710aAD  arySubBaseq                  15    overlay(arySubPRim:*next)
710aAD  arySubPrdQ                   15    overlay(arySubPRim:*next)
710aAD  arySubMsg                    99    overlay(arySubPRim:*next)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
     D Up              C                   CONST('ABCDEFGHIJKLMNOPQRST+
     D                                     UVWXYZ')
     D Low             C                   CONST('abcdefghijklmnopqrst+
     D                                     uvwxyz')


     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds


     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------
650dAd getAdjustedQty  pr             9  4
     D  Demand                        9  4 value
     D  sizeSub                       9  4 value
     D  sizePrim                      6  2 value
     d  uomFlag                       2    value
710eA***    Used to determine whether normal, sub, or dynamic bom
710eAd chkForSub       pr             8
710eAD  chkWhse                       3  0 value
710eAD  chkWo#                       13    const
710eAd  chkRmi                       15    const
710eAd  chkFgi                       15    const
710eAd  chkLine                       3  0 value
     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl
      /COPY *libl/qcopysrc,C#PROD
      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pWhse       Warehouse
     *      Planning fields
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     c                   parm                    pObjLoc
     C                   parm                    pWhse
	    c                   parm                    pRmItm
710 Ac                   parm                    pWo
710aAc                   parm                    pLine
     C                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

710mAC*
710mAC*   Get Client Code
710mAC*
710mAC                   call      'GETCLIENT'
710mAC                   parm                    client           10
710mAC                   parm                    clientloc        10

      /free

710aA    // commented lines below are used to test to see if
710aA    // code is working as expected for Primal breakdowns
710aA    // pRmitm = '50000';
710aA    // pLine = 1;
         *inlr = *on;
         pMessage = '*OK';

         // Write GLOSESSLOG record
         logText = 'objloc:' + pObjLoc;
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);
720 A
720 A    // check for incoming call from DRIPROD for replen creation
720 A    // and setup flag to ensure written is written
720 A
720 A    if pObjLoc = '*CRTRPL';
720 A       replenCreation = *on;
720 A       pObjLoc = 'AFTERACT';
720 A    else;
720 A       replenCreation = *off;
720 A    endif;

         select;
           when pObjLoc = 'AFTERACT';
             exsr dltRecords;
             exsr addRecords;
           other;
        endsl;

710aA   // Add records to PPRIMALBD to reflect breakdown of
710aA   // Primal/SubPrimal definitions
710aA   if pPrim <> *blanks and pLine<>*zeros;
710aA      exsr dltSubPrimBD;
710aA      exsr addSubPrimBD;
710aA   endif;
710aA
710aA   // If Primal is used and pLine was passed and the the
710aA   // Array was populated we should send down all the
710aA   // subPrimal definitions.
710aA   pOutStr = '{'
710aA     +  '"pMessage":"'  + %trim(pMessage) + '",';
710aA      // when no primal send down as single total
710aA      pOutStr = %trim(pOutStr) +
             '"pWhse":"'  + %trim(%char(pWhse)) + '",'
             +  '"smreqq":"'  + %trim(smreqq) + '",'
             +  '"smreqp":"'  + %trim(smreqp) + '",'
             +  '"smbaseq":"'  + %trim(smbaseq) + '",'
             +  '"smprodq":"'  + %trim(smprodq) + '",'
710eA        +  '"smreducejson":"'  + %char(smreducejson) + '",'
710eA        +  '"smbomuom":"'  + %trim(smbomuom) + '",'
             +  '"smspsize":"'  + %trim(%char(smspsize)) + '",'
             +  '"smline":"'  + %trim(%char(pLine)) + '"}';

710 A    // close PRMSUM if opened
710 A    if %open(prmsum);
710 A       close prmsum;
710 A    endif;

         return;
      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

710cA    // close PRMSUM if opened
710cA    if %open(prmsum);
710cA       close prmsum;
710cA    endif;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         //dump(a);
         $preturn = 'U:' + #status;
         pmessage = 'Program: '
                   + %trim(#pgm)
                   + ' line ('
                   + %trim(%editc(#stmt:'Z'))
                   + ') - '
                   + #pgmmsg;
         pOutStr = '{'
                   +  '"pWhse":"'  + %trim(%char(pWhse)) + '",'
                   +  '"pMessage":"'  + %trim(pMessage) + '"}';
         *inlr = *on;
         return;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  accumTotals  Accumulate totals for each record
     *----------------------------------------------------------------

      /free
       begsr accumTotals;

710eD    // totdmdq = totdmdq + (sqmake - sqqtyp);
710eD    // totqtyn = totqtyn + (sqqtyn*(1+sqscrf));
710eD    // totqty1 = totqty1 + (sqqty1*(1+sqscrf));
710eD    // totqty2 = totqty2 + (sqqty2*(1+sqscrf));
710eD    // totprdq = totprdq + (sqprdq*(1+sqscrf));
710eA     totqtyn = totqtyn + (sqqtyn);
710eA     totqty1 = totqty1 + (sqqty1);
710eA     totqty2 = totqty2 + (sqqty2);
710eA     totprdq = totprdq + (sqprdq);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  accumInv  Accumulate Inventory totals for Raw Material
     *----------------------------------------------------------------

      /free

       begsr accumInv;

          // get Production line inventory aisle
          setll (pwhse) plined;
          reade (pwhse) plined;
          if not %equal(plined);
             inRcvAisl = 'LIN';
730aA        inStkAisl = 'PAR';
          endif;

          // get available inventory
          avl1=0;
          avl2=0;
          avl3=0;
          setll (pWhse:hldRm#) slot3;
          reade (pWhse:hldRm#) slot3;
          dow not %eof(slot3);
730aD        //if slstat = 'A ' or slaisl = inRcvAisl;
730aA        if slstat = 'A ' or slaisl = inRcvAisl or slaisl=inStkAisl;
                exsr avail;  // add to available stock from warehouse
                avl1 += avail1;
                avl2 += avail2;
                avl3 += avail3;
             endif;
             reade (pWhse:hldRm#) slot3;
          enddo;

          // up total available inventory to highest uom
          newqtyn = avl1;
          newqty1 = avl2;
          newqty2 = avl3;
          exsr zzupqty;

          // build proper inventory field based on breakdown definition
          select;
           when squm3p <> ' ';
700eM       smavlq=%char(newqtyn) + '.'+%subst(%editw(newqty1:'0      '):4:4) +
700eM                    '.' + %subst(%editw(newqty2:'0      '):4:4);
          when squm2p <> ' ';
700eM      smavlq = %char(newqtyn) + '.'+%subst(%editw(newqty1:'0      '):4:4);
             other;
700eM           smavlq = %char(newqtyn) + '.000';
          endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  addRecords  Add records to Raw Material Summary file
     *----------------------------------------------------------------

      /free
       begsr addRecords;

710aA     // Get Primal from either Raw Material or Work Order passed.
710aA     // Used selected Primal to setup SubPrimal array from here on
710aA     pPrim = *blanks;
710aA     if (pRmItm <> *blanks or pWo <> *blanks) and pLine<>*zeros;
710aA        exec sql select pspCde into :pPrim
710aA            from pWrkOrdPs
710aA              where psWhse = :pWhse and psLine=:pLine and
710aA                    (psRmi = :pRmItm or psWo# = :pWo);
710aA     else;
710aA        pPrim = *blanks;
710aA        clear arySubPRim;
710aA     endif;
710aA
710aA     if pPrim<>*blanks;
710aA        clear arySubPRim;
710aA        // initialize numeric values in Array with Zeros
710aA        psCnt = 1;
710aA        dow psCnt < 101;
710aA           arySubWhse(psCnt) = *zeros;
710aA           arySubLine(psCnt) = *zeros;
710aA           arySubSpct(psCnt) = *zeros;
710aA           arySubpSize(psCnt) = *zeros;
710aA           arySubSize(psCnt) = *zeros;
710aA           psCnt = psCnt + 1;
710aA        enddo;
710aA        // setup empty ary record for each SubPRimal defined under
710aA        // passed Primal/SubPRimal.  If SubPrimal is blank all
710aA        // SubPRimals are included, otherwise only the one passed
710aA        chain (pWhse:pLine:pPrim) pPrimal;
710aA        setll (pWhse:pLine:pPrim) pSubPrimal;
710aA        reade (pWhse:pLine:pPrim) pSubPrimal;
710aA        psCnt = 1;
710aA        dow not %eof(pSubPRimal);
710aA           // setup SubPrimal Definitions for given Primal and Line
710aA           arySubWhse(pscnt) = a_psWhse;
710aA           arySubPcde(pscnt) = a_pspcde;
710aA           arySubScde(pscnt) = a_psscde;
710aA           arySubLine(pscnt) = a_psLine;
710aA           arySubsPct(psCnt) = a_psspct;
710aA           arySubDesc(psCnt) = a_pssdsc;
710aA           arySubPsize(pscnt) = pptypfac; // need to acct sub of diff. size
710aA           arySubSize(pscnt) = pptypfac*(pptypyld/100)*a_psspct;
710aA           arySubUOM(pscnt) = ppfacuom;
710aA           arySubReqq(pscnt) = '0';
710aA           arySubReqp(pscnt) = '0';
710aA           arySubBaseQ(pscnt) = '0';
710aA           arySubPrdQ(pscnt) = '0';
710aA           arySubMsg(pscnt) = '0';
710aA           psCnt = psCnt + 1;
710aA           reade (pWhse:pLine:pPrim) pSubPrimal;
710aA        enddo;
710aA        // Create blank primal and subprimal for work orders in play
710aA        // for given raw material that is not associated with primal
710aA        arySubWhse(pscnt) = a_psWhse;
710aA        arySubPcde(pscnt) = *blanks;
710aA        arySubScde(pscnt) = *blanks;
710aA        arySubLine(pscnt) = a_psLine;
710aA        arySubsPct(psCnt) = 1;
710aA        arySubPsize(pscnt) = pptypfac;
710aA        arySubSize(pscnt) = pptypfac*(pptypyld/100);
710aA        arySubUOM(pscnt) = ppfacuom;
710aA        arySubReqq(pscnt) = *blanks;
710aA        arySubReqp(pscnt) = *blanks;
710aA        arySubBaseQ(pscnt) = *blanks;
710aA        arySubPrdQ(pscnt) = *blanks;
710aA        arySubMsg(pscnt) = *blanks;
710aA     endif;
710aA     psCnt = *zeros;

          sqlStmt = 'Select writem,wrfgi,womake,woqtyp,' +
                    'wormavl,wostat,wrqtyn,wrqty1,' +
                    'wrqty2,wrprdq,wrscrf,wrprimal,' +
                    'wrsubprme,wrstat,itdesc,itum2,' +
                    'itumq2,itum3,itumq3,ippuom,ipprdq,' +
                    'wrwo#,womfgno,itum1,ps.pspcde,ps.psscde,sp.pssdsc';

710aA     sqlStmt = %trim(sqlStmt) + ' from pWrkOrdr as wod ' +
710aA               'left join pwrkord as woh ' +
710aA                    'on wod.wrwhse=woh.wowhse and wod.wrwo#=woh.wowo# ' +
710aA               'left join piritem as it ' +
710aA                    'on wod.wrwhse=it.itwhse and wod.writem=it.ititem ' +
710aA               'left join itemprd as ip ' +
710aA                    'on wod.wrwhse=ip.ipwhse and wod.writem=ip.ipitem ' +
710aA               'left join pWrkordPs as ps ' +
710aA                    'on wod.wrwhse=ps.pswhse and wod.writem=ps.psrmi ' +
710aA                    'and wod.wrwo#=ps.pswo# ' +
710aA               'left join pSubPrimal as sp ' +
710aA                    'on wod.wrwhse=sp.pswhse and wod.wrmfgno=sp.psLine ' +
710aA                    'and ps.pspcde=sp.pspcde and ps.psscde=sp.psscde';

          // append normal selections to where clause
          wherelabel = %trim(wherelabel) +
                       ' where wrwhse = ' + %char(pWhse) +
                       ' and wostat <> ' + sq + 'C' + sq +
                       ' and wostat <> ' + sq + 'D' + sq +
700cA                  ' and wrstat <> ' + sq + 'C' + sq +
700cA                  ' and wrstat <> ' + sq + 'D' + sq;

720aA     // ignore open/unreleased work orders when creating replenishment
720aA     // In this case we should only look at what is outstanding
720aA     // We also have it pull the Work Order in that is being released
720aA     // so it will be considered in quantity calcs since it is still
720aA     // status of Open or Planning
720aA     if replenCreation;
720aA       wherelabel = %trim(wherelabel) +
720aA                    ' and ((wostat <> ' + sq + 'S' + sq +
720aA                    ' and wostat <> ' + sq + 'P' + sq + ')' +
720aA                    ' or wrwo# = ' + sq + %trim(pWo) + sq + ')';
720aA       pWo=*blanks;
720aA     endif;
710aA
710aA     if pLine <> *zeros;
710aA        // if Mfg Line sent then include in selection
710aA        wherelabel = %trim(wherelabel) +
710aA                    ' and wrMfgNo = ' + %trim(%char(pLine));
710aA     endif;
710aA
          if pRmItm <> *blanks;
             // if item was sent then include in selection
             wherelabel = %trim(wherelabel) +
                         ' and writem = ' + sq + %trim(pRmItm) + sq;
          endif;

710 A     if pWo  <> *blanks     // passed in Work Order
710aA        and pPrim=*blanks;
710 A        // if Work Order was sent then include in selection
710 A        wherelabel = %trim(wherelabel) +
710 A                    ' and wrwo# = ' + sq + pWo + sq;
          endif;

          // append join information and data selection to select
          sqlStmt = %trim(sqlStmt) + ' ' +
                     %trim(whereLabel);

710aA     // When Primal/SubPrimal passed order by that to summarize
          sqlStmt = %trim(sqlStmt) +
                    ' order by wrwhse,writem,pspcde,psscde,womfgno';

          exec sql PREPARE sel FROM :SqlStmt;
          exec sql DECLARE RMSummary SCROLL CURSOR FOR SEL;
          exec sql OPEN RMSummary;
          exec sql
710aA       fetch next from RMSummary into :rmsum :Nullinds;
710aA     exsr NullCheck;

          EndofJob = *off;
          if sqlstt = '00000';
            hldRm# = sqItem;
700fA       hldWo# = sqWo#;
710aA       hldPrim = sqPrim;
710aA       hldSubPrim = sqSubPrim;
            dow sqlstt = '00000';
700dD     //   if hldRm# <> sqItem;
710aA     // Perform Summarize record routine
710aA          // When Primal passed rolled to
710aA          // Primal and SubPrimal level
710aA          if hldRm# <> sqItem or hldPrim <> sqPRim
710aA             or hldSubPrim <> sqSubPrim;
                  exsr AccumInv;
                  exsr writerecs;
               endif;
               rmsump = rmsum;
               exsr AccumTotals;
               exec sql
710aM            fetch next from RMSummary into :rmsum :Nullinds;
710aA          exsr NullCheck;
            enddo;

            EndofJob = *on;
            // create record for last summary if one exists
            //if totdmdq <>0 or totqtyn<>0 or totqty1<>0
            //             or totqty2<>0 or totprdq<>0;
               exsr accumInv;
               exsr writerecs;
            //endif;

          else;
             if sqlstt = '02000';   // eof..no records
                // no records exist
                pMessage = 'No Raw Materials short based on current ';
                pMessage = %trim(pMessage) + ' planning';
             else;
                // return error that SQL failed
                pMessage = 'SQL error ' + sqlstt + ' occurred.  No Updates';
             endif;
          endif;
          exec sql CLOSE RMSummary;

       endsr;
      /end-free

710aA*----------------------------------------------------------------
710aA*  addSubPRimBD - Add records to SubPrimal Breakdown for Screen Display
710aA*----------------------------------------------------------------
710aA
710aA /free
710aA
710aA  begsr addSubPrimBD;
710aA
710aA
710aA      // loop through Array to add breakdown records.  Will be
710aA      // displayed in inquiry screen Ixxxxx.
710aA      psCnt = 1;
710aA      dow psCnt < 101 and arySubpSize(psCnt) <> *zeros;
710aA         pbSessId = pSessId;
710aA         pbWhse = arySubWhse(psCnt);
710aA         pbItem = pRmItm;
710aA         pbPcde = arySubpcde(psCnt);
710aA         pbScde = arySubScde(psCnt);
710aA         pbsDsc = arySubDesc(psCnt);
710aA         pbLine = arySubLine(psCnt);
710aA         pbSpct = arySubSpct(psCnt);
710aA         pbSize = arySubpSize(psCnt);
710aA         pbSubSize = arySubSize(psCnt);
710aA         pbsubuom = arySubUOM(psCnt);
710aA         pbReqq = arySubReqq(psCnt);
710aA         pbReqp = arySubReqp(psCnt);
710aA         pbBaseq = arySubBaseq(psCnt);
710aA         pbProdq = arySubPrdq(psCnt);
710aA         // if no Primal associated then zero primal and subprimal
710aA         if pbsubsize = 9999.99;
710aA            pbsubsize = 0;
710aA            pbSize=0;
710aA         endif;
710aA         // calc remaining production quantity
710bA         if pbProdq = *blanks;
710bA            pbProdq = '0.0000';
710bA         endif;
710aA         if smprodq <> 'not defined';
710aA            wkremp = pbSubSize - %dec(pbProdq:9:4);
710aA            pbremp = %editc(wkremp:'P');
710aA            pbremB = 'see Prod==>';
710aA         endif;
710aA         pbMsg = arySubMSg(psCnt);
710aA         PBGRPTS = %timestamp();
710bA         // only write for Non Primal value if non primal planned
710bA         if arySubBaseq(psCnt)<>' ' or arySubPrdq(psCnt)<>' ';
710aA            write pbrec;
710bA         endif;
710aA         psCnt = psCnt + 1;
710aA      enddo;
710aA
710aA  endsr;
710aA
710aA /end-free

     *----------------------------------------------------------------
     *
     *  AVAIL   Calculate available quantities for slot.
     *
     *----------------------------------------------------------------
     C     avail         begsr
     *
     *  Call program to calculate availabe slot quantities.
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0

     *  Call program to get open Directed Putaway quantity.

     C                   call      'CHKOPNDP'
     C                   parm      slwhse        dWhse             3 0
     C                   parm      slwhdp        dWhdp             5
     C                   parm      sldisp        dDisp            12
     C                   parm      slitem        dItem            15
     C                   parm                    dTotal            3 0
     C                   parm                    dItmTtl           3 0
     C                   parm                    dQty1             5 0
     C                   parm                    dQty2             5 0
     C                   parm                    dQty3             5 0

     C                   eval      avail1 += dQty1
     C                   eval      avail2 += dQty2
     C                   eval      avail3 += dQty3

     *  Set negative quantities to zero

     C                   if        avail1 < 0
     C                   eval      avail1 = 0
     C                   endif
     C                   if        avail2 < 0
     C                   eval      avail2 = 0
     C                   endif
     C                   if        avail3 < 0
     C                   eval      avail3 = 0
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  bomReduction  -  Determine how many FG to reduce to
     *                   eliminate negative raw material inventory
     *----------------------------------------------------------------

      /free

       begsr bomReduction;

          // determine number of finished goods must reduce by work
          // order to eliminate raw material negative
          if %trim(smavlp) = '';
             smavlp = '      .0000';
          endif;
          if %trim(smreqp) = '';
             smreqp = '      .0000';
          endif;

          if sqippqp <> 0;
710eA        // if Prod UOM is zero for BOM setup for math
710eA        if bmprdq = 0;
710eA           select;
710eA              when itumq2<>0 and itumq3<>0;
710eA                 bmprdq = sqippqp / itumq2 / itumq3;
710eA              when itumq2<>0;
710eA                 bmprdq = sqippqp / itumq2;
710eA              other;
710eA                 bmprdq = sqippqp;
710eA           endsl;
710EA        else;
710eA           smBomUom = 'None';
710EA        endif;
             if (%dec(smavlp:9:0) - %dec(smreqp:9:0)) < 0;
                wkrmdp = %dec(smavlp:9:0) - %dec(smreqp:9:0);
                monitor;
                  smreduce = %abs(wkrmdp);
                on-error;
                  smreduce=99999;
                endmon;
710eA           smReDuceJson = smreDuce / bmprdq;
             else;
                smreduce = 0;
710eA           smReDuceJson = 0;
             endif;
          else;              // normal inventory breakdown item
710eA
710eA        chain (pWhse:sqitemp) piritem;
             monitor;
               smreduce = bomnegqty;
             on-error;
               smreduce=99999;
             endmon;
             select;
                when itumq2<>0 and itumq3<>0;
710eA              smReDuceJson = bomnegqty / (bmscrf+1) /
                                ((bmqtyn*itumq2*itumq3) +
                                 (bmqty1*itumq3) +
                                  bmqty2);
                when itumq2<>0;
710eA              smReDuceJson = bomnegqty / (bmscrf+1) /
                                ((bmqtyn*itumq2) +
                                  bmqty1);
                other;
710eA              smReDuceJson = bomnegqty / bmqtyn;
             endsl;
          endif;

       endsr;
      /end-free

700fA*----------------------------------------------------------------
700fA*
700fA*             array to ensure a greater number of this raw material
700fA*             is not required elsewhere.  You could have one finished
700fA*             good coming from same raw material that is produced from
700fA*             a smaller portion of the sub primal where it requires
700fA*             a higher number of total raw materials than another
700fA*             finisheded good coming from another portion of the
700fA*             sub primal.
700fA*----------------------------------------------------------------
700fA
700fA /free
700fA
700fA  begsr chkRmQty;
700fA
700fA     wkspsize = 1;
700fA     // if planned in production quantity convert to warehouse qty
700fA     if totprdq <> 0;
720bA        eval(h) totprdq = ((totprdq)*(1+sqscrfp));
700fA        exsr prdqtyConv;
710aA     else;
710aA
700fA     // now add any normal quantities to converted production quantity
700fA     // roll to lowest level, add scrap and
700fA     // roll back up to highest uom
700fA     if squmq3p=*zeros;
700fA        wkumq3=1;
700fA     else;
700fA        wkumq3 = squmq3p;
700fA     endif;
700fA     if squmq2p=*zeros;
700fA        wkumq2=1;
700fA     else;
700fA        wkumq2 = squmq2p;
700fA     endif;
700fA     eval wkqty2 = totqtyn*wkumq2*wkumq3;
700fA     eval wkqty2 = wkqty2 + totqty1*wkumq3;
700fA     eval wkqty2 = wkqty2 + totqty2;
700fA     eval totqtyn=*zeros;
700fA     eval totqty1=*zeros;
710cA     eval(h) totqty2=wkqty2*(1+sqscrfp);
710aA     // if Production Qty not tallied from the BOM but both
710aA     // the normal uom breakdowns are empty then force the
710aA     // production bom quantity on totqty2 which will roll
710aA     // up to case quantity.  Most likely an error in how
710aA     // BOM is defined compared to raw material.  Change was
710aA     // put in place on item master to prevent user from
710aA     // changing raw material setup that eliminates an uom
710aA     // that is being used on BOMS
710aA     if squmq3p=*zeros and squmq2p=*zeros;
710aA        if sqIpPqp <> 0;
710aA           // if normal normal breakdowns exist but production
710aA           // breakdown exist move to production
710aA           totprdq = totqty2;
710aA        endif;
710aA        totqtyn = *zeros;
710aA        totqty1 = *zeros;
710aA        wkumq3=1;
710aA        wkumq2=1;
710aA     else;
710aA        // when raw material is defined with Production UOM but
710aA        // the BOM for this work order is not using Production
710aA        // UOM we should convert how many of the normal uom used
710aA        // on the BOM is represented by the production UOM
710aA        if sqIpPqp <> 0;
710aA           eval(h) totprdq = (totqtyn * sqIpPqp) +
710aA                             (totqty1 * (sqIpPqp/(wkumq2))) +
710aA                             (totqty2 * (sqIpPqp/(wkumq3*wkumq2)));
710aA        endif;
710aA     endif;
710aA     endif;
700fA
700fA     // we should first check to see if this item and primal/subprimal
700fA     // exist in the counter array.  If found we should check to see if
700fA     // larger replenishment is already being requested.
700fA
700fA     // first get PWRKORDPS record which reflects Primal/SubPrimal
700fA     // for particular Work Order
700fA     setll (pWhse:sqwo#p:sqfgip:sqlinep:sqitemp) pWrkOrdPs;
700fA     reade (pWhse:sqwo#p:sqfgip:sqlinep:sqitemp) pWrkOrdPs;
700fA     if %eof(pWrkOrdPs);
700fA        // if not found then use default
700fA        pspcde='DEFAULT';
700fA        psscde='DEFAULT';
700fA        pptypfac = 9999.99;
700fA        ppfacuom = '**';
700fA        pptypyld=100;
700fA        a_psspct=1.0;
700fA        a_pstype='N';
700fA     else;
700fA        // when Primal/SubPRimal definition for Work Order get details
700fA        chain (psWhse:psLine:psPcde) pPrimal;
700fA        if not %found(pPrimal);
700fA           pptypfac = 9999.99;
700fA           ppfacuom = '**';
700fA           pptypyld=100;
700fA        else;
700fA           // when Primal found get SubPrimal
700fA           chain (psWhse:psLine:psPcde:psScde) pSubPrimal;
700fA           if not %found(pPrimal);
700fA              a_psspct=100;
700fA              a_pstype='N';
700fA           endif;
700fA        endif;
700fA     endif;
700fA
700fA     // if current Work Order is using Alternate Raw Material then
700fA     // override the Primal size per the raw material size.  Otherwise
700fA     // requirements are thrown off.
700fA     if ppfacuom <> '**';  // no primal defined
700fA        exec sql update itemprdpsa set iuitem=:sqfgip
700fA                   where iuwhse=:pWhse and iupcde=:pspcde
700fA                     and iuscde=:psscde and iuitem=:sqfgip
700fA                  and iuami=:sqitemp;
700fA        if sqlstt='00000';
700fA           // since above sql statement success it means alternate raw
700fA           // material is being used and we should use that size instead
700fA           // of original primal size.
700fA           select;
700fA              // Production Unit of measure found in ITEMPRD
700fA              when ppfacuom = sqpuomp;
700fA                 pptypfac = sqIppqp;
700fA              // Breakdown One found in PIRITEM
700fA              when ppfacuom = squm2p;
700fA                 pptypfac = wkumq2;
700fA              // Breakdown Two found in PIRITEM
700fA              when ppfacuom = squm3p;
700fA                 pptypfac = wkumq2 * wkumq3;
700fA           endsl;
700fA        endif;
700fA     endif;
700fA
700fA     pscnt = 1;
700fA     foundAry = *off;
700fA     // This first loop will setup each unique combination of Primal,
700fA     // SubPRimal and Raw MAterial in the totals array
700fA     dow pscnt < 1001;
700fA        select;
700fA        // if primal and subprimal are blank exit to add new entry
700fA           when arypcde(pscnt) = *blanks and aryscde(pscnt) = *blanks;
700fA              leave;
700fA        // look for Raw Material to be represented in the
700fA        // accumulation array.  We should first either update
700fA        // or create the array entry for this combination of
700fA        // Primal/SubPrimal/Raw Material/Line.  The next loop should
700fA        // look for the largest requirement for this raw
700fA        // raw material to ensure the replenishment covers all
700fA        // requirements.  There could be one subprimal that
700fA        // requires 3 of the raw material based on its requirements
700fA        // and another subprimal using the same raw material could
700fA        // require 5 of the raw materials.  In that case we would
700fA        // want the replenishment to be 5.
700fA           when arypcde(pscnt) = pspcde and aryscde(pscnt) = psscde and
710 D   //           aryrmi(pscnt) = sqitemp;
710 A                aryrmi(pscnt) = sqitemp and aryline(pscnt)=sqlinep;
700fA           // add to current array
700fA              aryqtyn(pscnt) = aryqtyn(pscnt) + totqtyn;
700fA              aryqty1(pscnt) = aryqty1(pscnt) + totqty1;
700fA              aryqty2(pscnt) = aryqty2(pscnt) + totqty2;
700fA              aryprdq(pscnt) = aryprdq(pscnt) + totprdq;
700fA              aryMakeQty(pscnt) = aryMakeQty(pscnt) + totdmdq;
700fA              foundAry = *on;
700fA              leave;
700fA        endsl;
700fA        pscnt = pscnt + 1;
700fA     enddo;
700fA
700fA     // if the exit from above loop needs new array entry then add
700fA     if not foundAry;
700fA        arypcde(pscnt) = pspcde;
700fA        aryrmi(pscnt) = sqitemp;
700fA        aryscde(pscnt) = psscde;
710 A        aryline(pscnt) = sqlinep;
700fA        arypsize(pscnt) = pptypfac;
700fA        arypfacuom(pscnt) = ppfacuom;
700fA        arypyield(pscnt) = pptypyld/100;
700fA        aryspszpct(pscnt) = a_psspct;
700fA        aryPrdq(pscnt) = totprdq;
700fA        aryQtyn(pscnt) = totqtyn;
700fA        aryQty1(pscnt) = totqty1;
700fA        aryQty2(pscnt) = totqty2;
700fA        aryMakeQty(pscnt) = totdmdq;
700fA     endif;
700fA
700fA     // Now loop back through Primal/Subprimal array looking
700fA     // for any entries that reference the particular raw material
700fA     // and compare for the largest number of requirements compared
700fA     // to the respective Primal/SubPrimal definition.  Pass this
700fA     // Raw Material requirement back to ensure replenishment covers
700fA     // all needs.
700fA     pscnt = 1;
700fA     wrtUpdRmQty = *off;
700fA     totprdq = 0;
700fA     totQtyn = 0;
700fA     totQty1 = 0;
700fA     totQty2 = 0;
700fA     totdmdq = 0;
700fA     totprdqh = 0;
700fA     totQtynh = 0;
700fA     totQty1h = 0;
700fA     totQty2h = 0;
700fA     totdmdqh = 0;
          wkbaseq = 0;
          wkprodq = 0;
700fA     loopReqPrd =0;
700fA     loopReqN =0;
700fA     loopReq1 =0;
700fA     loopReq2 =0;
700fA     dow pscnt < 1001;
700fA        select;
700fA           when aryrmi(pscnt) = sqitemp;
700fA              totdmdq = totdmdq + aryMakeQty(pscnt);
700fA              // first determine which unit of measure will be used
700fA              // to decide largest requested replenishment.  Several
700fA              // primal and subprimal definitions could exist that
700fA              // require different parts of the same subprimal. In that
700fA              // case we should enusre we have enough raw material to
700fA              // handle the most used part.
700fA              if arypfacuom(pscnt) = '**';
                      // When factor UOM is ** that means no primal/subprimal
                      // defined.  System will add Production UOM quantity
                      // directly to existing raw material production quantity.
710aA                 wkProdq = wkPRodq + aryPrdq(pscnt);
                      totprdq = totprdq + aryPrdq(pscnt);
                      totqty2 = totqty2 + aryQty2(pscnt);
700fA                 if hldRm# <> sqITem or EndofJob;
700fA                    wrtUpdRmQty = *on;
700fA                 endif;
700fA              else;
700fA                 subSize = aryPsize(pscnt) * arypYield(psCnt)
700fA                         * aryspszpct(pscnt);
700fA              endif;
700fA              select;
700fA                 // determine unit of measure used to determine number
700fA                 // required
700fA                 // if the raw material requirement including scrap
700fA                 // divided by the subPrimal size (calculated as Primal
700fA                 // size * Primal expected Yield times subPrimal percent
700fA                 // of Primal) is greater than previous high for this
700fA                 // Raw Material use the greatest need. This loop is
700fA                 // executed for each break for work order within raw mater
700fA                 when arypfacuom(pscnt) = sqpuomp;    // Production UOM
700fA                    // apply the formula described in text above from lines
700fA                    // 530.11 thru 530.16 for PRoduction UOM if that UOM is
700fA                    // subSize is calculated above at PRimal/SubPRimal leve
700fA                    // subSize is not different based on UOM used
700fA                    if (aryprdq(pscnt) / subSize) >
700fA                         loopReqPrd;
700fA                       wrtUpdRmQty = *on;
                            // call Procedure to calculate number of Primal
                            // Subprimal combinations required for requested
                            // Raw Material and PRimal/SubPRimal combo
                            uomType='P ';  // Production UOM
                            demandin = aryPRdq(pscnt);
                            pptypfac = arypSize(pscnt);
                            totprdqh = getAdjustedQty(demandin:
                                           subsize:
                                           pptypfac:uomType);
                            demandin = aryQty2(pscnt);
                            uomType='P2';   // lowest level normal breakdowns
                            totQty2h = getAdjustedQty(demandin:
                                           subsize:
                                           pptypfac:uomType);
700fA                       loopReqPrd = (aryprdq(pscnt) / subSize);
                            wkprodq = aryprdq(pscnt);
700fA                    endif;
700fA                 when arypfacuom(pscnt) = squm1p   // Normal Case UOM
700fA                   or arypfacuom(pscnt) = squm2p   // Normal Breakdown 1
                        or arypfacuom(pscnt) = squm3p;  // Normal Breakdown 2
                         // all normal case and normal inventory breakdowns
                         // are rolled down to breakdown level two for common
                         // calculations and then rolled back up for actual
                         // requirement.  If no breakdowns are defined we
                         // force 1 on them so even case quantity is forced
                         // down and back up so we only have to deal with
                         // one set of numbers in calculating need.
700fA                    if (aryQty2(pscnt) / subSize) >
700fA                         loopReq2;
700fA                       wrtUpdRmQty = *on;
                            demandin = aryQty2(pscnt);
                            pptypfac = arypSize(pscnt);
                            uomType='2 ';   // lowest level normal breakdowns
                            totQty2h = getAdjustedQty(demandin:
                                           subsize:
                                           pptypfac:uomType);
700fA                       loopReq2 = (aryQty2(pscnt) / subSize);
                            wkbaseq = aryqty2(pscnt);
700fA                    endif;
700fA              endsl;
700fA           when arypcde(pscnt)= *blanks and aryscde(pscnt) = *blanks;
700fA              leave;
700fA           other;
700fA        endsl;
700fA        pscnt = pscnt + 1;
700fA     enddo;
700fA
700fA     // this ends up summing the default totals (if no primal/subprimal)
700fA     // defined with the highest requirement per a primal/SubPrimal for
700fA     // given raw material.
700fA     totprdq = totprdq + totprdqh;
700fA     totqty1 = totqty1 + totqty1h;
700fA     totqty2 = totqty2 + totqty2h;
700fA     totqtyn = totqtyn + totqtynh;
700fA     totprdqh = 0;
700fA     totqty1h = 0;
700fA     totqty2h = 0;
700fA     totqtynh = 0;
700fA
700fA     // when the Raw Material changes clear the Array with Primal
700fA     // and SubPrimal information
710aA     // put code in this condition to clear array if doing primal
710aA     // subprimal breakdown and we are on the blank code meaning it
710aA     // all on its own and nothing with previous primals 032117
700fA     if hldRm# <> sqITem or EndofJob
710aA        or (pPrim<>*blanks and pLine<>*zeros);
             // if production quantity was defined ensure
             // there are no more case quantities requested
             // than required per the Production UOM
             if sqippqp <> *zeros;
                demandin = totPrdq;
                subSize = sqIppqp;
                uomType='CP';
                totQty2 = getAdjustedQty(demandin:
                                 subsize:
                                 pptypfac:uomType);
                wkbaseq = totQty2;
                if wkprodq = *zeros;
                   wkprodq = totprdq * wkspsize;
                endif;
             endif;
700fA        clear aryPrimRM;
700fA     endif;
700fA
700fA
700fA  endsr;
700fA /end-free
700fA
     *----------------------------------------------------------------
     *  dltRecords  Delete records for this Session if exists
     *----------------------------------------------------------------

      /free

       begsr dltRecords;


710 A     // if Work Order is passed in do not open PRMSUM.  It is
710 A     // not updated in this instance and only sends back JSON
710 A     // and it is causing record lock issues.
710aD     //if pWo = *blanks and not %open(prmsum);
710aA     if pWo = *blanks and pLine=*zeros and not %open(prmsum);
710 A        open pRmSum;
710 A     endif;

710 A     if pWo = *blanks and pLine=*zeros and %open(prmsum);
             if pRmItm <> '';
                // if item was sent delete only that raw material
                exec sql delete from PRMSUM
                     where smSessid = :pSessId and smitem = :pRmItm;
             else;
                exec sql delete from PRMSUM
                     where smSessid = :pSessId;
             endif;
710 A     endif;

       endsr;

      /end-free
710aA*----------------------------------------------------------------
     *  dltSubPrimBD - Delete SubPrimal Breakdown Records
     *----------------------------------------------------------------
710aA
710aA /free
710aA
710aA  begsr dltSubPrimBD;
710aA
710aA
710aA      // if item was sent delete only that raw material
710aA      exec sql delete from PPRIMALBD
710aA           where pbSessid = :pSessId and pbitem = :pRmItm
710aA                   and pbLine = :pLine;
710aA
710aA  endsr;
710aA
710aA /end-free

     *----------------------------------------------------------------
     *  formatReq  Format Required Raw Materials Total
     *----------------------------------------------------------------

      /free

       begsr formatReq;

          if wkBaseq = 0;
             wkBaseq = totQty2;
          endif;
700fA     smspsize = wkspsize;
700fA     if squmq3p = *zeros;
700fA        squmq3p = 1;
700fA     endif;
700fA     if squmq2p = *zeros;
700fA        squmq2p = 1;
700fA     endif;
          // up required totals to highest uom
          newqtyn = totqtyn;
          newqty1 = totqty1;
          newqty2 = totqty2;
          exsr zzupqty;
          totqtyn = newqtyn;
          totqty1 = newqty1;
          totqty2 = newqty2;

          // build proper required field based on breakdown definition
          select;
           when squm3p <> ' ';
700eM      smreqq=%char(newqtyn) + '.' + %subst(%editw(newqty1:'0      '):4:4) +
700eM                   '.' + %subst(%editw(newqty2:'0      '):4:4);
           when squm2p <> ' ';
700eM       smreqq=%char(newqtyn) + '.' + %subst(%editw(newqty1:'0      '):4:4);
             other;
700eM           smreqq = %char(newqtyn) + '.000';
          endsl;

          // raw materials requirements in production uom terms
          if sqippqp <> 0;
             smreqp = %editc(totprdq:'P');
          else;
             smreqp = '      .0000';
          endif;

700fA     // Setup string values for base quantity with primal and
700fA     // subprimal size restrictions
700fA     newqtyn = 0;
700fA     newqty1 = 0;
700fA     newqty2 = wkbaseq;
700fA     exsr zzupqty;
700fA     totqtyn = newqtyn;
700fA     totqty1 = newqty1;
700fA     totqty2 = newqty2;
700fA
700fA     // build proper required field based on breakdown definition
700fA     select;
700fA      when squm3p <> ' ';
700fA      smbaseq=%char(newqtyn) + '.'+%subst(%editw(newqty1:'0      '):4:4) +
700fA                   '.' + %subst(%editw(newqty2:'0      '):4:4);
700fA      when squm2p <> ' ';
700fA       smbaseq=%char(newqtyn) + '.' +%subst(%editw(newqty1:'0      '):4:4);
700fA        other;
700fA           smbaseq = %char(newqtyn) + '.000';
700fA     endsl;
700fA
700fA     // raw materials requirements in production uom terms
700fA     if sqippqp <> 0;
700fA        smprodq = %editc(wkprodq:'P');
700fA     else;
700fA        smprodq = '      .0000';
700fA     endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  formatRem  Format Remaining Inventory Total
     *----------------------------------------------------------------

      /free

       begsr formatRem;

          newqtyneg = *off;
          smRmdq = ' ';
710eA     // send down appropriate BOM usage for single unit
710eA     chkForSub(pwhse:sqwo#p:sqitemp:sqfgip:sqlinep);
710eA     if bmqtyn<>0 or bmqty1<>0 or bmqty2<>0;
710eA        smBomUom = %char(bmqtyn) + %trim(squm1p) + ' ';
710eA        select;
710eA           when bmqty2<>0;
710eA              smBomUom = %trim(smBomUom) + ' ' +
710eA                 %char(bmqty1) + %trim(squm2p) + ' ' +
710eA                 %char(bmqty2) + %trim(squm3p);
710eA           when bmqty1<>0;
710eA              smBomUom = %trim(smBomUom) + ' ' +
710eA                 %char(bmqty1) + %trim(squm2p);
710eA        endsl;
710eA     else;
710eA        smBomUom = 'None';
710eA     endif;
          select;
             when squmq3p <> 0;
                newqty2 = ((avl1*squmq2p*squmq3p) +
                     (avl2*squmq3p) +
                     avl3) -
                    ((totqtyn*squmq2p*squmq3p) +
                     (totqty1*squmq3p) +
                     totqty2);
                if sqippqp <> 0;
                  smavlpnum=((avl1*squmq2p*squmq3p)+(avl2*squmq3p)+avl3)
                           * (sqippqp / (squmq2p*squmq3p));
                  smavlp=%editc(smavlpnum:'P');
                else;
                  smavlp = '      .0000';
                endif;
                if newqty2 < 0;
                   newqtyneg = *on;
                   newqty2 = %abs(newqty2);
                   bomnegqty = newqty2;
                   exsr bomreduction;
                else;
                   newqtyneg = *off;
                endif;
                newqty1 = 0;
                newqtyn = 0;
                exsr zzupqty;
             when squmq2p <> 0;
                newqty1 = ((avl1*squmq2p) + avl2) -
                          ((totqtyn*squmq2p) + totqty1);
                if sqippqp <> 0;
                   smavlp = %editc(((avl1*squmq2p) + avl2)
                              * (sqippqp / squmq2p):'P');
                else;
                   smavlp = '      .0000';
                endif;
                if newqty1 < 0;
                   newqtyneg = *on;
                   newqty1 = %abs(newqty1);
                   bomnegqty = newqty2;
                   exsr bomreduction;
                else;
                   newqtyneg = *off;
                endif;
                newqty2 = 0;
                newqtyn = 0;
                exsr zzupqty;
             other;
                if sqippqp <> 0;
                   smavlp = %editc((avl1 * sqippqp):'P');
                else;
                   smavlp = '      .0000';
                endif;
                newqtyn = avl1 - totqtyn;
                exsr bomReduction;
          endsl;

          // build proper Remaining inv. field on breakdown definition
          if newqtyNeg;
             smrmdq = '-';
          endif;

          select;
             when squm3p <> ' ';
                smrmdq = %trim(smrmdq) +
700eM             %char(newqtyn) + '.' + %subst(%editw(newqty1:'0      '):4:4) +
700eM                    '.' + %subst(%editw(newqty2:'0      '):4:4);
             when squm2p <> ' ';
                smrmdq = %trim(smrmdq) +
700eM             %char(newqtyn) + '.' + %subst(%editw(newqty1:'0      '):4:4);
             other;
700eM           smrmdq = %trim(smrmdq) + %char(newqtyn) + '.000';
          endsl;
          if sqippqp <> 0;
             if %dec(smreqp:9:0) <> 0;
                wkrmdp = %dec(smavlp:9:4) - %dec(smreqp:9:4);
             endif;
             smrmdp = %editc(wkrmdp:'P');
          else;
             smrmdp = '      .0000';
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  NullCheck - Clear Null values on SQL Fetch into
     *----------------------------------------------------------------
710aA
710aA /free
710aA  begsr NullCheck;
710aA     if Nullinds(25) = NullValue;
710aA        sqPrim = *blanks;
710aA     endif;
710aA     if Nullinds(26) = NullValue;
710aA        sqSubPrim = *blanks;
710aA     endif;
710aA     if Nullinds(27) = NullValue;
710aA        sqSubDesc = *blanks;
710aA     endif;
710aA  endsr;
710aA /end-free

     *----------------------------------------------------------------
     *  PrdQtyConv - Convert Production Quantity to Dakota Quantity
     *----------------------------------------------------------------

      /free
       begsr PrdQtyConv;

          // when an item is planned via Production Quantity this
          // this routine is called to convert Production quantity
          // to lowest possible normal breakdown.
700fA     if squmq3p = *zeros;
700fA        wkumq3 = 1;
700fA     else;
700fA        wkumq3 = squmq3p;
700fA     endif;
700fA     if squmq2p = *zeros;
700fA        wkumq2 = 1;
700fA     else;
700fA        wkumq2 = squmq2p;
700fA     endif;
          if sqIpPqp <> 0 and totprdq <> 0;
             // convert to lowest unit of measure per the
             // normal Dakota breakdowns
             eval(h) result = sqIpPqp / (wkumq3*wkumq2);
             select;
                when result > 0;
700fD        //    eval(h) totqty2 = totqty2 + (totPrdq / result)+.49;
700fA              eval(h) totqty2 = (totPrdq / result)+.49;
                when result < 0;
700fD       //     eval(h) totqty2 = totqty2 + (totPrdq / result)-.49;
700fA              eval(h) totqty2 = (totPrdq / result)-.49;
            endsl;
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  writeRecs  Write session records for Production Raw Materials
     *----------------------------------------------------------------

      /free

       begsr writerecs;
700fA     // Ensure this Raw Material should be overridden with
700fA     // current quantity
700fA     exsr chkRMQty;

700fA     if wrtUpdRmQty;
700fA        // this will write a new record.  If one already
700fA        // exist delete first
700fA        pRmItm = sqitemp;
710 A        // We do not delete PRMSUM records when WO passed in.  This
710 A        // is used only to pass back certain info using JSON and leave
710 A        // previously calculated total RM record in place
710 A        if pWo = *blanks and pPrim=*blanks;
700fA           exsr dltRecords;
710 A        endif;
             // format required quantity field
             exsr formatreq;
             // calculate and format remaining inventory field
             exsr formatrem;
             // define fields for summary raw material record
             smSessid = pSessId;
             smWhse = pWhse;
             smItem = hldRm#;
             smdmdq = totdmdq;
             smgrpts = %timestamp();
710 A        // We only add raw material level records to PRMSUM.  When
710 A        // Work ORder is sent in we are only expecting JSON values to
710 A        // be returned at Work ORder level
710aD     // if pWo = *blanks;
710aA        if pWo = *blanks and pPrim=*blanks
720 A           or pWo = *blanks and replenCreation;
710cA           if not %open(pRmSum);
710cA              open pRmSum;
710cA           endif;
                write smrec;
710 A        else;
710 A           if %trim(smreqp)<>'.0000';
710 A              smreqq='see Prod==>';
710 A              smbaseq='see Prod==>';
710 A           endif;
710 A           if %trim(smreqp)='.0000';
710 A              smreqp='not defined';
710 A              smprodq='not defined';
710 A           endif;
710aA           // if Primal requested we should add to array
710aA           if pPrim <> *blanks and pLine<>*zeros;
710aA              psCnt = 1;
710aA              dow psCnt < 101;
710aA                 // updates arySubUOM, arySubpSize and
710aA                 // arySubSize to catch any substitution changes
710aA                 if arySubPcde(psCnt) = hldPrim and
710aA                    arySubScde(psCnt) = hldSubPrim and
710aA                    arySubLine(psCnt) = pLine;
710aA                    arySubDesc(psCnt) = sqSubDescp;
710aA                    arySubUom(psCnt) = ppfacuom;
710aA                    arySubpSize(psCnt) = pptypfac;
710aA                    arySubSize(psCnt) = pptypfac*(pptypyld/100)
710aA                                          * arySubSpct(psCnt);
710aA                    arySubReqq(pscnt) = smreqq;
710aA                    arySubReqp(pscnt) = smreqp;
710aA                    arySubBaseQ(pscnt) = smBaseq;
710aA                    arySubPrdQ(pscnt) = smPRodQ;
710aA                    arySubMsg(pscnt) = pMessage;
710aA                    leave;
710AA                 endif;
710aA                 psCnt = psCnt + 1;
710aA              enddo;
710aA           endif;
710 A        endif;
700fA     endif;

          // initialize total fields for next item
          hldRm# = sqitem;
700fA     hldWo# = sqWo#;
710aA     hldPrim = sqPrim;
710aA     hldSubPrim = sqSubPrim;
          totdmdq=0;
          totqtyn=0;
          totqty1=0;
          totqty2=0;
          totprdq=0;
710aA     //wkprodq=0;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  ZZUPQTY       Up quantity
     *----------------------------------------------------------------

     C     zzupqty       begsr

     C                   dow       squmq3p > 0 and +
     C                               newqty2 >= squmq3p
     C                   eval      newqty2 -= squmq3p
     C                   eval      newqty1 += 1
     C                   enddo

     C                   dow       squmq2p > 0 and +
     C                               newqty1 >= squmq2p
     C                   eval      newqty1 -= squmq2p
     c                   eval      newqtyn += 1
     C                   enddo

     C                   endsr

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

     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
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
     c                   eval      pMessage  = 'Error occured on call to '
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
     c                   endsl

     c                   endsr

650dA*----------------------------------------------------------------
650dA*  GetSpclUciLcns   Get special UCI License
650dA*----------------------------------------------------------------

650dAp getAdjustedQty  b
650dAd getAdjustedQty  pi             9  4
     d     demand                     9  4 value
     d     sizesub                    9  4 value
     d     sizeprim                   6  2 value
     d     uomType                    2    value
      *
      *  Local Values
      *
     d  sizeprimext    s              9  0
     d  demandext      s              9  0
     d  sizesubext     s              9  0
     d  newValue       s             13  4

650dA /free

          demandext = demand * 10000;
          sizesubext = sizesub * 10000;
          sizeprimext = sizeprim *10000;

700fA     // save subprimal percent size of primal
          if uomType <> 'CP';
             if aryPsize(pscnt) <> *zeros;
                wkspSize = subSize / aryPsize(pscnt);
             else;
                wkspSize = 1;
             endif;
          endif;

          // if demand is less than full subprimal size just return
          // demand
          select;
             when uomType = 'P ';  // Just sent to calc Production Quantity req
                   if sizesub > 0;
                      newvalue = demand/sizeSub * sizePrim;
                   else;
                      newvalue = demand;
                   endif;
               return newValue;

             // Ensure case quantity agress with total Production UOM when
             // defined
             when uomType = 'CP';  // Calc case quantity when no primal/subprim

               // if no case breadkdowns (normal uoms) are defined then
               // round to next case
               if squmq2p = 0 and squmq3p = 0;
                  newValue = %div(demandext:sizeSubext);
                  if %rem(demandext:sizeSubext) <> 0;
                     newValue = newValue + 1;
                  endif;
                  newValue = newValue;
                  if newValue = 0;
                     newValue = 1;
                  endif;
               else;
                  // at least one normal inventory breakdown is used
700fA             if squmq3p = *zeros;
700fA                wkumq3 = 1;
700fA             else;
700fA                wkumq3 = squmq3p;
700fA             endif;
700fA             if squmq2p = *zeros;
700fA                wkumq2 = 1;
700fA             else;
700fA                wkumq2 = squmq2p;
700fA             endif;
                  eval(h) result = sqIpPqp / (wkumq3*wkumq2);
                  // put total production quantity and production quantity
                  // per each breakdown into non decimal fields to determine
                  // rounded quantity of normal breakdowns required to fulfill
                  // demand requirement
                  demandext = totPrdq * 10000;
                  sizesubext = result * 10000;
                  newValue = %div(demandext:sizesubext);
                  if %rem(demandext:sizesubext) <> 0;
                     newValue = newValue + 1;
                  endif;
               endif;

               return newvalue;

             when uomType = 'P2' or uomType='2'; // calc Prod and Normal Qtys
700fA          if squmq3p = *zeros;
700fA             wkumq3 = 1;
700fA          else;
700fA             wkumq3 = squmq3p;
700fA          endif;
700fA          if squmq2p = *zeros;
700fA             wkumq2 = 1;
700fA          else;
700fA             wkumq2 = squmq2p;
700fA          endif;

               if sqIpPqp <> 0;
                  // convert to lowest unit of measure per the
                  // normal Dakota breakdowns
                 eval(h) result = sqIpPqp / (wkumq3*wkumq2);

                 if squmq3p=0 and squmq2p=0;
                   // if no normal breakdowns but production breakdown yet
                   // bom used normal breakdowns we should do math on basic  /
                   // non extended numbers to get case quantity required
                   demandext = aryPrdq(pscnt);
                   sizesubext = sizesub;
                   sizeprimext = 1;
                   newValue = (%div((demandext):(sizesubext))*sizeprimext);
                   if %rem((demandext):(sizesubext)) <> *zeros;
                      newValue = newValue + 1;
                   endif;
                else;
                  // else, get total value plus remainder
                   if sizesub > 0;
                      newvalue = demand/sizeSub * sizePrim;
                   else;
                      newvalue = demand;
                   endif;
                endif;

                if squmq3p<>0 or squmq2p<>0;
                    // do not adjust for differences in lowest normal
                    // breakdown and production uom breakdown if no
                    // normal breakdowns were defined
                    select;
                      when result > 0;
700fA                    eval(h) newValue = (newvalue / result);
                      when result < 0;
700fA                    eval(h) newValue = (newvalue / result);
                    endsl;
                endif;
               else;
                  // when taking this path the item has no Production
                  // UOM defined for the Raw Material and will not
                  // consider.
                   if sizesub > 0;
                      newvalue = demand/sizeSub * sizePrim;
                   else;
                      newvalue = demand;
                   endif;
               endif;
               return newvalue;
            endsl;


650dA /end-free
650dAp getAdjustedQty  e
710eA *
710eA *  Procedure chkForSub.........
710eA *
710eA *  chkForSub Procedure will used passed parms to determine if BOM line has
710eA *  substituted.  If so it will locate the substitute and replace the pbom
710eA *  with values found in PBOMSUB
710eA *
710eAP chkForSub       b
710eAD chkForSub       pi             8
710eAD  chkWhse                       3  0 value
710eAD  chkwo#                       13    const
710eAD  chkRmi                       15    const
710eAD  chkFgi                       15    const
710eAD  chkLine                       3  0 value
710eA
710eA /free
710eA   // first look to see if raw material from work order detail
710eA   // file exist in PBOM (Primary Bill of MAterial File
710eA   setll (chkwhse:chkfgi) pbom;
710eA   reade (chkwhse:chkfgi) pbom;
710eA   dow not %eof(pbom);
710eA      // if bom raw material equals raw material from work order
710eA      // return as PBOM
710eA      if bmrmi = chkrmi;
710eA         return 'PBOM';
710eA      endif;
710eA      reade (chkwhse:chkfgi) pbom;
710eA   enddo;
710eA
710eA   // when it falls to here it means the work order raw material was not
710eA   // found in the active Bill of MAterial PBOM.  Look next in active
710eA   // substitution
710eA   // see if substitute item matches item from work order detail
710eA   setll (chkwhse:chkfgi) pBomSub;
710eA   reade (chkwhse:chkfgi) pBomSub;
710eA   dow not %eof(pBomSub);
710eA      // see if this alternate item matches raw material for this work orde
710eA      if sbami = chkRmi;
710eA         bmwhse = sbwhse;
710eA         bmfgi = sbfgi;
710eA         bmqtyn = sbqtyn;
710eA         bmqty1 = sbqty1;
710eA         bmqty2 = sbqty2;
710eA         bmprdq = sbprdq;
710eA         bmscrf = sbscrf;
710eA         bmtype = sbtype;
710eA         bmbckf = sbbckf;
710eA         bmpquf = sbpquf;
710eA         bmeffd = sbeffd;
710eA         bmexpd = sbexpd;
710eA         bmrmi = sbami;
710eA         leave;
710eA      endif;
710eA      reade (chkwhse:chkfgi) pBomSub;
710eA   enddo;
710eA
710eA   // end of file when existing do loop indicates no sub was found to be ac
710eA   // but the bom line was not active either
710eA   if not %eof(pBomSub);
710cA      return 'PBOMSUB';
710eA   endif;
710eA
710eA   // when it falls to here it means the work order raw material was not
710eA   // found in the active Bill of Mmterial PBOM, or the Substitute files.
710eA   // It must be a dynamic bill.
710eA   // see if substitute item matches item from work order detail
710eA   setll (chkwhse:chkfgi) pBomVers;
710eA   reade (chkwhse:chkfgi) pBomVers;
710eA   dow not %eof(pBomVers);
710eA      // see if this alternate item matches raw material for this work orde
710eA      if pxrmi = chkrmi;
710eA         bmwhse = pxwhse;
710eA         bmfgi = pxfgi;
710eA         bmqtyn = pxqtyn;
710eA         bmqty1 = pxqty1;
710eA         bmqty2 = pxqty2;
710eA         bmprdq = pxprdq;
710eA         bmscrf = pxscrf;
710eA         bmtype = pxtype;
710eA         bmbckf = pxbckf;
710eA         bmpquf = pxpquf;
710eA         bmeffd = pxeffd;
710eA         bmexpd = pxexpd;
710eA         bmrmi = pxrmi;
710eA         leave;
710eA      endif;
710eA      reade (chkwhse:chkfgi) pBomVers;
710eA   enddo;
710eA
710eA   // end of file when existing do loop indicates no sub was found to be ac
710eA   // but the bom line was not active either
710eA   if not %eof(pBomVers);
710eA      return 'PBOMVERS';
710eA   else;
710eA      return'NF';
710eA   endif;
710eA
710eA /end-free
710eA
710eAP chkForSub       e
