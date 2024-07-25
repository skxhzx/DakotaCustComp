710 AHdftactgrp( *NO )
     H  actgrp( *NEW )
     Hbnddir( 'QC2LE' )
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  UPDBTCHLBL - Update Batch Label file (EXPSPLBL)
     *  25 January   2019
     *  Mike Rooker
     *
     *    -PARMS
     *       pCmd  = Command
     *       pWhse = Warehouse
     *       pRteId = RouteId
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
520 A*  01/25/19  MR   7.30
     *    - Created.
     *----------------------------------------------------------------
     fexpsplbl1 uf   e           k disk
     fstgbatch  uf   e           k disk
     *
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     *
     d pcmd            s              8
     d pWhse           s              3  0
     d pRtId           s              5
     d forever         s              1
      *
     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
     *
     c     *entry        plist
     c                   parm                    pcmd
     c                   parm                    pwhse
     c                   parm                    pRtId
      //
      /free
          setll (pwhse:pRtId) expsplbl1;
          dow forever = forever;
             reade (pwhse:pRtId) expsplbl1;
             if %eof;
                leave;
             endif;
          //
             lbestatus = 'S';
             select;
                when pcmd = 'RT760';
                  lbeText = 'RT760 - Manual close by pgm UPLBLBTCH';
                when pcmd = 'RH134';
                  lbeText = 'RH134 - Manual close by pgm UPLBLBTCH';
             endsl;
             lbeststs = %timestamp();
             lbestsuc = %timestamp();
             update  lberec;

             //* Update STGBATCH
             chain (pwhse:lbebatid) stgbatch;
             if %found;
                sbstatus = 'S';
                sbText = lbetext;
                sbststs = lbeststs;
                sbstsuc = lbestsuc;
                update sbrec;
             endif;
          enddo;

          *inlr = *on;
      /end-free
