      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PO885S    DockVue Export - Open POs v7.50
     *  February 21, 2021
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
750  *    02/21/21  RTR  7.50
     *      - Created.
     *
     *----------------------------------------------------------------
     * File Specs
     fpohdr     if   e           k disk
     fpohdrm    if   e           k disk
     fpodtl     if   e           k disk
     fpiritem   if   e           k disk
     fitemmsc   if   e           k disk
     fexpsdvoph o  a e           k disk
     fexpsdvopd o  a e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Working variables
     d batId           s             11a
     d batStat         s              1a
     d batText         s            200a
     d cnt             s             10i 0
     d haveBatId       s               n
     d rtnCode         s             10
     d rtnMessage      s            200
     d slotdef         s              2a
     d stamp           s               z
     d stamploval      s               z
     d stampUC         s               z

     d dsWhse          ds
     d  batWhse                1      3  0
     d  batWhsea               1      3a

     *----------------------------------------------------------------
     *  Prototypes
     d GetBatId        pr                  extpgm('GETBATID')
      * Input
     d   pWhse                        3p 0 const
     d   pType                       10    const
     d   pStatus                      1    const
      * Output
     d   pBatId                      11
     d   pReturn                     10
     d   pMessage                   200

     *----------------------------------------------------------------
     *  Parameters
     d $pWhse          s              3p 0
     d $pWhse3A        s              3
     d $pBatId         s             11
     d $pReturn        s             10
     d $pMessage       s            200

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *      $pBatId - Batch id
     *
     *    Returned Parameters
     *      $pReturn  - Return code
     *      $pMessage - Return message
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $pWhse3A
     c                   parm                    $pBatId
     c                   parm                    $pReturn
     c                   parm                    $pMessage

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        exsr OpenRecs;

        if haveBatId;
          $pBatId = batid;
          $pReturn = '*OK';
          $pMessage = 'DockVue export batch created.';
          exsr zzzEnd;
        else;
          $pBatId = *blanks;
          $pReturn = '*EMPTY';
          $pMessage = 'No records found.';
        endif;

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
      /free
       begsr *inzsr;

         batWhsea = $pWhse3a;
         haveBatId = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  OpenRecs       Process Open Records
     *----------------------------------------------------------------
      /free
       begsr OpenRecs;

        dow forever = forever;

          read phrec;
          if %eof(pohdr);
            leave;
          endif;

          if phstat <> '0';
            iter;
          endif;

          // If first time, get batch id. If error, get out.
          if not haveBatId;
            exsr zzzGetBatId;
            if batId = *blanks;
              leave;
            endif;
            haveBatId = *on;
          endif;

          exsr zzzGetStamps;
          // Get header misc record
          chain (phwhse: phpo) pohdrm;
          if not %found(pohdrm);
            phmm1 = *blanks;
            phmm2 = *blanks;
            phmm3 = *blanks;
            phmm4 = *blanks;
            phmm5 = *blanks;
          endif;
          // Write header record
          dphwhs = batwhse;
          dphbatid = batId;
          dphpo = phpo;
          dphstatus = 'R';
          dphtext = 'Ready for export';
          dphven = phven;
          dphvnm = phvnam;
          dphad1 = phvad1;
          dphad2 = phvad2;
          dphcty = phvcty;
          dphst  = phvst;
          dphzp1 = phvzp1;
          dphsts = phstat;
          dphdate = phdate;
          dphnote = %trim(phmm1) + %trim(phmm2) + %trim(phmm3)
                  + %trim(phmm4) + %trim(phmm5);
          dphaddts = stamp;
          dphadduc = stampUC;
          write dphrec;

          // Get detail records
          setll (phwhse: phpo) podtl;
          dow forever = forever;
            reade (phwhse: phpo) podtl;
            if %eof(podtl);
              leave;
            endif;

            // Get item master record
            chain (pdwhse: pditem) piritem;
            if not %found(piritem);
              itdesc = *blanks;
            endif;
            // Get item misc record
            chain (pdwhse: pditem) itemmsc;
            if not %found(itemmsc);
              imtie = *zero;
              imhigh = *zero;
            endif;

            // Get pick slot
            exec sql select slaisl, sldisp, slsdef
                       into :dpdaisl, :dpdslot, :slotdef
                       from slot
                      where slwhse = :pdwhse
                        and slitem = :pditem
                        and slpick = 'Y'
                        and slstat = 'A'
                      order by sldisp
                      fetch first row only;
            if sqlstt <> sqlsuccess;
              clear dpdaisl;
              clear dpdslot;
            endif;

            // Get slot tie/high
            exec sql select idtie, idhigh
                       into :dpdslti, :dpdslhi
                       from itemdef
                      where idwhse = :pdwhse
                        and iditem = :pditem
                        and idsdef = :slotdef
                      fetch first row only;
            if sqlstt <> sqlsuccess;
              clear dpdslti;
              clear dpdslhi;
            endif;

            // Write detail record
            dpdwhs = batwhse;
            dpdbatid = batId;
            dpdpo = pdpo;
            dpdseq = pdseq;
            dpditm = pditem;
            dpdstatus = 'R';
            dpdtext = 'Ready for export';
            dpdq1 = pdqor1;
            dpddesc = itdesc;
            dpddept = itwhdp;
            dpdpdsc = itpdsc;
            dpdcube = itcube;
            dpdswgt = itswgt;
            dpdbuyer = imbnam;
            dpditti = imtie;
            dpdithi = imhigh;
            dpdslti = imtie;
            dpdslhi = imhigh;
            dpdaddts = stamp;
            dpdadduc = stampuc;
            write dpdrec;
          enddo;

        enddo;

       endsr;   // OpenRecs
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
       begsr zzzGetBatId;

        monitor;
          GetBatId(batWhse: 'EXPDVOPEN': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------
      /free
       begsr zzzGetStamps;

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

        stamploval = *loval;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------
      /free
       begsr zzzEnd;

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :batWhse
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*ERROR';
          $pMessage = 'Unable to update batch record.';
        endif;

       endsr;   // zzzEnd
      /end-free
