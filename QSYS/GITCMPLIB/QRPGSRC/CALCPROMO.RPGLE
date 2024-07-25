      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CALCPROMO   Calculate Harbor Promo Totals
     *  21 July 2008
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
520 A*   07/21/08  DAS  5.20
     *     - Created.
     *
520aA*   04/08/09  RBD  5.20a
     *     - Fix: Don't create or update table entry unless item
     *       is a promo item.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Flabel32s  if   e           k disk
EIc  Forddm     if   e           k disk

HARyA*----------------------------------------------------------------
HARyA*  Order detail misc file data structures
HARyA*----------------------------------------------------------------
HARyA
HARyA /copy qcopysrc,orddm1_har

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     D keyl32s         ds                  likerec(ljrec32s:*key)
     D keyodm          ds                  likerec(omrec:*key)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n
     D found           s               n
     D i               s              3  0
     D maxOrd          s              3  0

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D pWhse           s              3s 0
     D pRtid           s              5
     D pType           s              5
     D pTrn#           s              7  0
     D pTblEnt         s              3  0
     D pRtn            s              8

     D pTbl            ds                  occurs(30)
     D  pTblValue                     7  0
     D  pTblPcs1                      5  0
     D  pTblPcs2                      5  0
     D  pTblPcs3                      5  0

     *----------------------------------------------------------------
     *  Input parameters
     *
     *     pWhse   - Warehouse
     *     pRtid   - Route id
     *     pType   - STOP / ORDER
     *     pTrn#   - Tran#
     *
     *  Output parameters
     *
     *     pTbl    - Table (multiple occurance ds)
     *     pTblEnt - Table entries
     *     pRtn    - *OK
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pRtid
     C                   parm                    pType
     C                   parm                    pTrn#
     C                   parm                    pTbl
     C                   parm                    pTblEnt
     C                   parm                    pRtn

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

       // Initialize return parameters.

           clear *all pTbl;
           pRtn = '*OK';
           pTblEnt = 0;

       // Read through label records for transaction.

           keyl32s.lbwhse = pWhse;
           keyl32s.lbrte  = pRtid;
           keyl32s.lbtype = 'O';
           keyl32s.lbtrn# = pTrn#;

           setll %kds(keyl32s:4) label32s;

           dow forever = forever;

             reade %kds(keyl32s:4) label32s;
             if %eof;
               leave;
             endif;

         // Get order detail misc record.

             keyodm.omwhse = lbwhse;
             keyodm.omord  = lbord;
             keyodm.omseq  = lbseq;
             keyodm.omitem = lbitem;

             chain %kds(keyodm) orddm;
             if not %found;
               hardm1_base = ' ';
             else;
               hardm1_base = ommsc1;
             endif;

520aA    // Check to see if promo item.

520aA        if hardm1_promo = ' ';
520aA          iter;
520aA        endif;

         // Add pieces to stop and order totals.

             if pType = 'STOP';
               exsr addStp;
             else;
               exsr addOrd;
             endif;

           enddo;

       // Bye, Bye

           return;

       //--------------------------------------------------------------
       // addOrd    Add pieces to Order total
       //--------------------------------------------------------------

       begsr addOrd;

           eval found = *off;

           if pTblEnt > 0 and pTblValue = ohCord;
             eval found = *on;
           else;
             for i = 1 to pTblEnt;
               %occur(pTbl) = i;
               if pTblValue = ohCord;
                 eval found = *on;
                 leave;
               endif;
             endfor;
           endif;

           if not found;
             if pTblEnT < %elem(pTbl);
               pTblEnt += 1;
               %occur(pTbl) = pTblEnt;
               pTblValue = ohCord;
             else;
               %occur(pTbl) = pTblEnt;
             endif;
           endif;

           select;
             when hardm1_promo = '1';
               pTblPcs1 += lbqpck;
             when hardm1_promo = '2';
               pTblPcs2 += lbqpck;
             when hardm1_promo = '3';
               pTblPcs3 += lbqpck;
           endsl;

       endsr;

       //--------------------------------------------------------------
       // addStp    Add pieces to Stop total
       //--------------------------------------------------------------

       begsr addStp;

           if pTblValue = 0;
             pTblValue = lbStop;
             pTblEnt  = 1;
           endif;

           if lbStop <> pTblValue;
             if %occur(pTbl) < %elem(pTbl);
               pTblEnt += 1;
               %occur(pTbl) = pTblEnt;
               pTblValue = lbStop;
             endif;
           endif;

           select;
             when hardm1_promo = '1';
               pTblPcs1 += lbqpck;
             when hardm1_promo = '2';
               pTblPcs2 += lbqpck;
             when hardm1_promo = '3';
               pTblPcs3 += lbqpck;
           endsl;

       endsr;

      /end-free
