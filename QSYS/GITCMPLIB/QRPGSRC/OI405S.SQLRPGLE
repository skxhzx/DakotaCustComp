      /copy qcopysrc,hspecs
     h dftactgrp(*NO) actgrp(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  OI405S   Staging Order Import - NetSuite Orders
     *  01 February 2017
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *
710  *    01/14/17  RTR  7.10
     *      - Created.
720a *    03/02/18  RTR  7.20a
     *      - Changed for NetSuite re-write.
     *
     *----------------------------------------------------------------
     * File Specs
     fimpsordhnsuf   e           k disk
720aDf*impsorddnsuf   e           k disk
     fimpsordh  uf a e           k disk
     fimpsordd  uf a e           k disk
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

     d OrderImport     pr                  extpgm('OI286S')
      * Input
     d   pWhsea                       3    const
     d   pBatId                      11    const
      * Output
     d   pReturn                     10
     d   pMessage                   200

     *----------------------------------------------------------------
     *  Working Variables
     d batStatus       s              1a
     d batText         s            200a
     d cmdlen          s             15p 5
     d cmdstr          s            200a
     d haveBatId       s               n
     d holdcube        s              5s 0
     d holdorder       s              7s 0
     d newBatid        s             11a
     d pMsg            s            200a
     d pRtn            s             10a
     d pWhse           s              3s 0
     d stamp           s               z
     d stampUC         s               z

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
     d main            pr                  extpgm('OI405S')
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

        // Whip through the header records
        setll (pWhse: pBatch) impsordhns;
        dow forever = forever;
          reade (pWhse: pBatch) impsordhns;
          error = *off;
          if %eof(impsordhns);
            leave;
          endif;
          if nihstatus <> 'R'
           and nihstatus <> ' ';
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

          // Get matching detail record
720aD   //chain (pWhse: pBatch: nihord: nihline: nihitem) impsorddns;

720aD   //if not %found(impsorddns);
720aD   //  error = *on;
720aD   //  nidslto = *blanks;
720aD   //  nidnsid = 0;
720aD   //  nidnsor = 0;
720aD   //  nidnsit = 0;
720aD   //  nidnsi1 = 0;
720aD   //  nidnsi2 = 0;
720aD   //  nidnsi3 = 0;
720aD   //  batText = 'Matching IMPSORDDNS record not found';

720aD   //else;

            // Write header if new order
            if nihord <> holdOrder;
              exsr fillHeader;
              write oihrec;
              holdOrder = nihord;
            endif;

            // Write detail
            exsr fillDetail;
            write oidrec;

720aD   //endif;

          // Update NetSuite records
          if error = *off;
720aD     //nidstatus = 'S';
            nihstatus = 'S';
720aD     //update nidrec;
          else;
            nihstatus = 'E';
            nihtext = batText;
          endif;

          update nihrec;
        enddo;

        // Set any detail records not processed to error status,
        // they are ready to be picked so if no match there is problem.
        batstatus = 'E';
        battext   = 'ERROR: No match with IMPSORDDNS. Orphaned order item.';

720aD  //exec sql
720aD  // update impsorddns
720aD  // set nidstatus = :batstatus,
720aD  //     nidtext   = :battext,
720aD  //     nidststs  = current_timestamp,
720aD  //     nidstsuc  = current_timestamp - current_timezone
720aD  // where nidwhs = :pWhse
720aD  //   and nidstatus = 'R'
720aD  //   and nidbatid = :pBatch;

        // All done, mark batch as processed.
        batstatus = 'S';
        battext   = 'Batch converted to IMPROUTE batch ' + newBatId;

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

        if sqlstt <> sqlSuccess;   // send error message
          cmdStr = 'SNDMSG MSG('+ sq + 'ERROR: OI405S NetSuite Order Import '
                 + sqlstt + ' in staging batch ID ' + pbatch
                 + sq + ') TOUSR(*SYSOPR)';
          cmdLen = %len(cmdStr);
          qcmdexc(cmdStr: cmdLen);
        endif;

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

        // Set new batch to ready status and process.
        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :pWhse
            and sbbatid = :newBatId;

        OrderImport(pWhsea: newBatId: pRtn: pMsg);

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
     *  fillDetail     Fill Detail Record Fields
     *----------------------------------------------------------------
      /free
       begsr fillDetail;

         oidwhs    = pWhse;
         oidbatid  = newBatId;
         oidordid  = 0;
         oidstatus = 'R';
         oidststs  = stamp;
         oidstsuc  = stampUC;
         oidtext   = *blanks;
         oidord    = nihord;
         oidseq    = nihline;
         oiditm    = nihitem;
         oidq1     = nihqtyo;
         oidq2     = 0;
         oidq3     = 0;
         oidwh2    = 0;
         oidor2    = 0;
         oidoit    = *blanks;
         oidspc    = *blanks;
         oidpo     = *blanks;
         oimdsc    = *blanks;
         oimpds    = *blanks;
         oimrds    = *blanks;
         oimbox    = *blanks;
         oimexp    = *blanks;
         oimms1    = %subst(nihcode1a:1:1) + %subst(nihcode2a:1:2);
         oimms2    = *blanks;
720aD  //oimms3    = nidseq + ' '
720aD  //          + nidtskn + ' '
720aD  //          + nidfonum;
720aM    oimms3    = %editc(nihnsid:'X')
720aM              + %editc(nihnsrt:'X')
720aM              + %editc(nihnsi1:'X')
720aM              + %editc(nihnsi2:'X');
720aD  //oimms4    = %editc(nidnsid:'X') + ' '
720aD  //          + %editc(nidnsor:'X') + ' '
720aD  //          + %editc(nidnsit:'X');
720aM    oimms4    = nihcode4A;
720aD  //oimms5    = %editc(nidnsi1:'X') + ' '
720aD  //          + %editc(nidnsi2:'X') + ' '
720aD  //          + %editc(nidnsi3:'X');
720aM    oimms5    = nihcode5a;
         oidslt    = nihcode4A;
         oidblk    = *blanks;
         oidaddts  = stamp;
         oidadduc  = stampUC;

       endsr;  // fillDetail
      /end-free

     *----------------------------------------------------------------
     *  fillHeader     Fill Header Record Fields
     *----------------------------------------------------------------
      /free
       begsr fillHeader;

         oihwhs    = pWhse;
         oihbatid  = newBatId;
         oihrteid  = *blanks;
         oihordid  = 0;
         oihstatus = 'R';
         oihststs  = stamp;
         oihstsuc  = stampUC;
         oihtext   = *blanks;
         oihord    = nihord;
         oihtyp    = 'R';
         oihcus    = nihcnum;
         oihcpo    = *blanks;
         oihcnm    = nihcnam;
         oihca1    = *blanks;
         oihca2    = *blanks;
         oihcct    = nihcode3a;
         oihcst    = *blanks;
         oihczp    = *blanks;
         oihrte    = nihrte;
         oihstp    = 0;
         oihtrk    = *blanks;
         oihmsc    = *blanks;
         if (nihcode1s * 100) > 99999;
           holdCube = 99999;
         else;
           holdCube  = nihcode1s * 100;
         endif;
         ohmms1    = %editc(holdCube:'X');
         ohmms2    = *blanks;
         ohmms3    = *blanks;
         ohmms4    = %editc(nihnsrt:'X') + ' '
                   + %editc(nihnsid:'X') + ' ';
720aD  //ohmms5    = nihcode4a;
720aM    ohmms5    = *blanks;
         oihaddts  = stamp;
         oihadduc  = stampUC;
         oihest    = nihstop;

       endsr;  // fillHeader
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
       begsr zzzGetBatId;

        haveBatId = *on;
        monitor;
          GetBatId(pWhse: 'IMPROUTE': 'W':
                   newBatId: pRtn: batText);
        on-error;
          haveBatId = *off;
          error = *on;
          clear newBatId;
        endmon;

       endsr;  // zzzGetBatId
      /end-free
