      /copy qcopysrc,hspecs
     h dftactgrp(*NO) actgrp(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  RH155NS  Staging Order Export - NetSuite Orders
     *  01 February 2017
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *
710  *    02/01/17  RTR  7.10
     *      - Created.
720a *    03/08/18  RTR  7.20
     *      - Changed for NetSuite changes.
730a *    08/19/19  RTR  7.30a
     *      - Changed to not send error message when no batch processed.
     *
     *----------------------------------------------------------------
     * File Specs
     fexpsordd  uf   e           k disk
     fexpsordh  uf   e           k disk
     fexpsordc  uf   e           k disk
     fexpsordhnsuf a e           k disk
     fexpsorddnsuf a e           k disk
     fexpsordcnsuf a e           k disk
     *----------------------------------------------------------------
     *  Program info data structure
      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Customer ids

     *----------------------------------------------------------------
     *  Called Program Prototypes
      /copy qcopysrc,p.qcmdexc

     d GetBatId        pr                  extpgm('GETBATID')
      * Input
     d   gWhse                        3p 0 const
     d   gType                       10    const
     d   gStatus                      1    const
      * Output
     d   gBatId                      11
     d   gReturn                     10
     d   gMessage                   200

     *----------------------------------------------------------------
     *  Working Variables
     d batStatus       s              1a
     d batText         s            200a
     d cmdlen          s             15p 5
     d cmdstr          s            200a
     d haveBatId       s               n
     d holdorder       s              7s 0
     d newBatid        s             11a
     d stamp           s               z
     d stampUC         s               z
     d pRtn            s             20a
     d pWhse           s              3s 0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhsea     Warehouse
     *      pBatch     Batch ID
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     d main            pr                  extpgm('RH155NS')
      * Input
     d   pWhsea                       3    const
     d   pBatch                      11    const

     d main            pi
      * Input
     d   pWhsea                       3    const
     d   pBatch                      11    const

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
      /free

        // Read header records
        setll (pWhse: pBatch) expsordh;
        dow forever = forever;
          reade (pWhse: pBatch) expsordh;
          error = *off;
          if %eof(expsordh);
            leave;
          endif;
          if oehstatus <> 'R';
            iter;
          endif;

          // Get staging batch ID
          if havebatid = *off;
            exsr zzzGetBatId;
            if havebatid = *off
             or error = *on;
              leave;
            endif;
          endif;

          error = *off;
          clear batText;

          // Get detail records
          setll (pWhse: pBatch: oehrte: oehord) expsordd;
          dow forever = forever;
            reade (pWhse: pBatch: oehrte: oehord) expsordd;
            error = *off;
            if %eof(expsordd);
              leave;
            endif;
            if oedstatus <> 'R';
              iter;
            endif;

            // Write NetSuite header
            exsr fillHeader;
            write nehrec;

            // Write NetSuite detail
            exsr fillDetail;
            write nedrec;

            // Get catchweight records
            setll (pWhse: pBatch: oedrteid: oedord) expsordc;
            dow forever = forever;
              reade (pWhse: pBatch: oedrteid: oedord) expsordc;
              error = *off;
              if %eof(expsordc);
                leave;
              endif;
              if oecstatus <> 'R';
                iter;
              endif;
              // Write NetSuite catchweight
              exsr fillCwgt;
              write necrec;
              // Update catchweight status
              oecstatus = 'S';
              update oecrec;
            enddo;
            // Update Detail status
            oedstatus = 'S';
            update oedrec;
          enddo;

          // Update Header status
          oehstatus = 'S';
          update oehrec;
        enddo;

        // All done, mark batch as processed.
        batstatus = 'S';
        battext   = 'Batch converted to EXPROUTENS batch ' + newBatId;

        exec sql
          update stgbatch
          set sbstatus = :batstatus,
              sbtext   = :battext,
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbstrts  = :stamp,
              sbstruc  = :stampUC,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :pWhse
            and sbbatid = :pBatch;

730aD   //if sqlstt <> sqlSuccess;   // send error message
730aM   if sqlstt <> sqlSuccess
730aA     and pbatch <> *blanks;   // send error message
          cmdStr = 'SNDMSG MSG('+ sq + 'ERROR: RH155NS NetSuite Order Export '
                 + sqlstt + ' in staging batch ID ' + pbatch
                 + sq + ') TOUSR(*SYSOPR)';
          cmdLen = %len(cmdStr);
          qcmdexc(cmdStr: cmdLen);
        endif;

        // Set new batch to ready status
        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :pWhse
            and sbbatid = :newBatId;

        *inlr = *on;

      /end-free
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     c     *inzsr        begsr
     *
     * Get client id.
     *
     c                   call      'GETCLIENT'
     c                   parm                    client           10
     c                   parm                    clientloc        10
     *
      /free
        monitor;
          pWhse = %dec(pWhsea: 3: 0);
        on-error;
          error = *on;
          batText = 'Invalid warehouse parameter: ' + pWhsea;
        endmon;

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          stamp = %timestamp();
          clear stampUC;
        endif;
      /end-free
     *
     c                   endsr

     *----------------------------------------------------------------
     *  fillCwgt   Fill Catchweight Record Fields
     *----------------------------------------------------------------
      /free
       begsr fillCwgt;

         necwhs    = pWhse;
         necbatid  = newBatId;
         necrte    = oecrte;
         necord    = oecord;
         necosq    = oecosq;
         necitm    = oecitm;
         necseq    = oecseq;
         necstatus = 'R';
         necststs  = stamp;
         necstsuc  = stampUC;
         nectext   = *blanks;
         necrteid  = oecrteid;
         necordid  = oecordid;
         necwgt    = oecwgt;
         neclbl    = oeclbl;
         nectrn    = oectrn;
         necaddts  = stamp;
         necadduc  = stampUC;

       endsr;  // fillCwgt
      /end-free

     *----------------------------------------------------------------
     *  fillDetail     Fill Detail Record Fields
     *----------------------------------------------------------------
      /free
       begsr fillDetail;

         nedwhs    = pWhse;
         nedbatid  = newBatId;
         nedstatus = 'R';
         nedststs  = stamp;
         nedstsuc  = stampUC;
         nedtext   = *blanks;
         nedseq    = %subst(oedms3:1:10);
         nedtskn   = %subst(oedms3:12:10);
         nedfonum  = %subst(oedms3:23:15);
         nedsonum  = oedord;
         nedline   = oedseq;
         neditem   = oeditm;
         nedslto   = *blanks;
         nedqtyo   = oedq1;
         nedsltp   = *blanks;
         neddatp   = 0;
         nedqtyp   = oedqp1;
         nednsts   = *blanks;
         nednote   = *blanks;
         nedusrp   = *blanks;
       //nednsid   = %dec(%subst(oedms4:1:10):10:0);
       //nednsor   = %dec(%subst(oedms4:12:10):10:0);
       //nednsit   = %dec(%subst(oedms4:23:10):10:0);
       //nednsi1   = %dec(%subst(oedms5:1:10):10:0);
       //nednsi2   = %dec(%subst(oedms5:12:10):10:0);
       //nednsi3   = %dec(%subst(oedms5:23:10):10:0);
         nedaddts  = stamp;
         nedadduc  = stampUC;

       endsr;  // fillDetail
      /end-free

     *----------------------------------------------------------------
     *  fillHeader     Fill Header Record Fields
     *----------------------------------------------------------------
      /free
       begsr fillHeader;

         nehwhs    = pWhse;
         nehbatid  = newBatId;
         nehstatus = 'R';
         nehststs  = stamp;
         nehstsuc  = stampUC;
         nehtext   = *blanks;
         nehrte    = oehrte;
         nehord    = oehord;
         nehnsts   = *blanks;
         nehcnum   = oehcus;
         nehcnam   = oehcnm;
         nehstop   = oehstp;
         nehline   = oedseq;
         nehitem   = oeditm;
         nehqtyo   = oedq1;
         nehqtyp   = oedqp1;
         nehcode1S = 0;
         nehcode2S = 0;
         nehcode1A = *blanks;
         nehcode2A = *blanks;
         nehcode3A = *blanks;
         nehcode4A = oedms4;
         nehcode5A = oedms5;
         nehcode6A = *blanks;
         monitor;
           nehnsid = %dec(%subst(oedms3:1:10):10:0);
         on-error;
           nehnsid = 0;
         endmon;
         monitor;
           nehnsrt = %dec(%subst(oedms3:11:10):10:0);
         on-error;
           nehnsrt = 0;
         endmon;
         monitor;
           nehnsi1 = %dec(%subst(oedms3:21:10):10:0);
         on-error;
           nehnsi1 = 0;
         endmon;
         monitor;
           nehnsi2 = %dec(%subst(oedms3:31:10):10:0);
         on-error;
           nehnsi2 = 0;
         endmon;
         nehaddts  = stamp;
         nehadduc  = stampUC;

       endsr;  // fillHeader
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
       begsr zzzGetBatId;

        haveBatId = *on;
        monitor;
          GetBatId(pWhse: 'EXPROUTENS': 'W':
                   newBatId: pRtn: batText);
        on-error;
          haveBatId = *off;
          error = *on;
          clear newBatId;
        endmon;

       endsr;  // zzzGetBatId
      /end-free
