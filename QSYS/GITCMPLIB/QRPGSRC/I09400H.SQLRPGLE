      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FI09400H     Purchase Order Receiving Totals
     *  23 June 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    06/23/14  LMC  6.50
     *      - Created.
     *      - Returns value field for displaying on list.
     *
650aA*    10/27/14  LMC  6.50a
     *      - Added qty ordered
650bA*    10/29/14  LMC  6.50b
     *      - Added super Po logic
700aA*    06/03/16  LMC  7.00a
     *      - Exclude branded item po detail lines from summary totals
     *        for Qty Ordered/Received.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D QtyRec          s              6s 0
     D Qty1            s              6s 0
     D Qty2            s              6s 0
     D Qty3            s              6s 0
     D WgtRec          s             10s 2
     D Wgt             s             10s 2
650aAD QtyOrd          s              6s 0
650aAD QtyO1           s              6s 0
650aAD QtyO2           s              6s 0
650aAD QtyO3           s              6s 0
650bAD super           s               n

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D pdrec         E Ds                  Extname(podtl)
650bAD purec         E Ds                  Extname(pospo)
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pPO            s              9
     D  pOutStr        s           1024    varying

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        // Get Po totals
        QtyRec = 0;
650aA   QtyOrd = 0;
        WgtRec = 0;
650bA   // is pPO a super po?
650bA   exec sql select * into :purec
650bA            from pospo
650bA            where puwhse = :pWhse
650bA              and puspo   = :pPO
650bA            fetch first 1 rows only;

650bA   If sqlstt = sqlSuccess;
650bA     super = *on;
650bA   else;
650bA     super = *off;
650bA   endif;

650bA   select;
650bA     when super;
650bA       // get the po's linked to the super po
650bA       SqlStmt = 'select * from pospo '
650bA           +     'where puwhse = ' + %char(pWhse) + ' '
650bA           +       'and puspo = '
650bA           +       sq + %trimr(pPO) + sq;
650bA       exec sql prepare sposel from :SqlStmt;
650bA       exec sql declare spocsr cursor for sposel;
650bA       exec sql open spocsr;
650bA       dow forever = forever;
650bA         exec sql fetch next from spocsr
650bA                  into :purec;
650bA         if sqlstt <> sqlSuccess;
650bA           exec sql close spocsr;
650bA           leave;
650bA         endif;
650bA         exec sql select sum(pdqrc1), sum(pdqrc2), sum(pdqrc3),
650bA                         sum(pddwgt),
650bA                         sum(pdqor1), sum(pdqor2), sum(pdqor3)
650bA                  into :qty1,:qty2,:qty3,:wgt,:qtyO1,:qtyO2,:qtyO3
650bA                  from podtl
650bA                  where pdwhse = :pWhse
650bA                    and pdpo   = :pupo
700aA                    and pdspcl <>'BR';
650bA         If sqlstt = sqlSuccess;
650bA           QtyRec = QtyRec + qty1 + qty2 + qty3;
650bA           QtyOrd = Qtyord + qtyO1 + qtyO2 + qtyO3;
650bA           WgtRec = WgtRec + wgt;
650ba         endif;
650ba       enddo;
650bA     other;
        exec sql select sum(pdqrc1), sum(pdqrc2),
650aM                             sum(pdqrc3), sum(pddwgt),
                                  sum(pdqor1), sum(pdqor2), sum(pdqor3)
                 into :qty1,
                      :qty2,
                      :qty3,
650aM                 :wgt,
650aA                 :qtyO1,
650aA                 :qtyO2,
650aA                 :qtyO3
                 from podtl
              where pdwhse = :pWhse
                and pdpo   = :pPO
700aA           and pdspcl <>'BR';
           If sqlstt = sqlSuccess;
                 QtyRec = qty1 + qty2 + qty3;
650aA            QtyOrd = qtyO1 + qtyO2 + qtyO3;
                 WgtRec = wgt;
           endif;
650bA   endsl;

         // Put together JSON string

         pOutStr = '{'
                +  '"QtyR":"'  + %char(QtyRec) + '",'
650aA           +  '"QtyO":"'  + %char(QtyOrd) + '",'
                +  '"WgtR":"'  + %char(WgtRec) + '"';

         // Close off the JSON string
         pOutStr += '}';

        return;
      /end-free

