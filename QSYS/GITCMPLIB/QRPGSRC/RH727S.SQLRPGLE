      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  RH727S    Custom export pick label info
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710  *    08/12/17  RTR  7.10
     *      - Created.
710a *    10/13/17  RTR  7.10a
     *      - Fix: Batch status check changed from =R to <>S due to
     *        batches being left in W status.
     *
     *----------------------------------------------------------------
     *  Notes -
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  61        - Special order (Customer # > 0)
     *  79        - EOF for IMPRTN
     *  78        - EOF for ORTNBAT
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fstgbatch  uf   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *
     d whsea           s              3
     d pFileName       s             11

     *----------------------------------------------------------------
     *  Called program parameters
     *
700cAd Pfiles2         pr                  extpgm('PFILES2')

700cAd IfsExport       pr                  extpgm('RH727CL')
700cAd   gWhse                        3    const
700cAd   gBatId                      11    const
700dAd   gAction                     10    const
700cA
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Parameters
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     * Main line
     *
      /free
         Pfiles2();  // Update labels with trans info

         pfilename = %char(%date():*iso0) + '000';
         IfsExport(whsea: pFileName: '*CREATE');  // Create temp file

         read stgbatch;
         dou forever <> forever;  // Loop thru batches
           if %eof(stgbatch);
             leave;
           endif;

           if sbtype = 'EXPPCKLBL'
710aM       and sbstatus <> 'S';
710aD     //and sbstatus = 'R';

             whsea = %editc(sbwhse:'X');
             IfsExport(whsea: sbbatid: '*BATCH');  // Add to temp file
             sbstatus = 'S';
             update sbrec;
             exec sql update expsplbl
                         set lbestatus = 'S'
                       where lbebatid = :sbbatid;
           endif;
           read stgbatch;

         enddo;

         IfsExport(whsea: pFileName: '*SEND');  // Send temp file

         *inlr = *on;
      /end-free
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
     C                   endsr
