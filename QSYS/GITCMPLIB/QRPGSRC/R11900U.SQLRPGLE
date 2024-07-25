      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FR11900U     PO Receiving - Super Po - Load# update
     *  17 November 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    11/17/14  LMC  6.50
     *      - Created.
700aA*    10/06/16  LMC  7.00
     *      - Fix - Branded items causing error on po lines not being
     *        touched. We don't write porcv record for the branded
     *        lines that are created during receiving. PDSPCL = 'BR'
710aA*    08/03/17  LMC  7.10a
     *      - Fix - Status was not being set correctly if user unmarks
     *        for export. Moved that logic to a subr SetStatus.
     *        Removed previous logic for readability. There will be a
     *        previous copy of this program R11900U.2 if needed.
730aA*    10/01/19  LMC  7.30a
     *      - Enh - For clients with Real time export need to call
     *        DKTEXPORT. After marking the po.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pMark       Mark
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
730aAD dktexport       pr                  extpgm('DKTEXPORT')
730aA * Input
730aAD   dWhse                        3p 0 const
730aAD   dType                       10    const
730aAD   dRunType                     1    const
730aAD   dMaxBatches                  5p 0 const
730aAD   dSets                        3    const
730aAD   dProgram                    10    const
730aA * Output
730aAD   dReturn                     10
730aAD   dMessage                   200


     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
730aA /copy qcopysrc,p.getoptio

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#coastal
650eA /COPY QCOPYSRC,ID#PACKERS

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pWhse           s              3p 0
     D pPo             s              9
     D pMark           s              1
     D  pOutStr        s            512    varying

     D client          s             10
     D clientloc       s             10

     D super           s               n
     D newstat         s              1
     D superstat       s              1
     D FailedEdit      s             30
     D count           s              5p 0

710aAD checkPO         s              9

730aAd ExportType      s            117a
730aAD ExportReturn    s             10
730aAD ExportMessage   s            200
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D phrec         E Ds                  Extname(pohdr)
     D purec         E Ds                  Extname(pospo)
     D pdrec         E Ds                  Extname(podtl)
     D opsrcv        E Ds                  Extname(opsrcvlbl)
     D phmrec        E Ds                  Extname(pohdrm)
650bAD porrec        E Ds                  Extname(porcv)
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pMark
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
        FailedEdit = ' ';
        // run double check on edits
        select;
          when pMark = 'U';
            // po can not be attached to a super po
            exec sql select * into :purec
                     from pospo
                     where puwhse = :pWhse
                       and pupo   = :pPO
                     fetch first 1 rows only;

            If sqlstt = sqlSuccess;
              FailedEdit = 'FE-Attached to Super PO';
              pOutStr = '{'
                      +  '"PO":"'  + %trimr(pPO) + '",'
                      +  '"NO":"'  + %trimr(FailedEdit) + '",'
                      +  '"Mark":"'  + %trimr(pMark) + '"';
              // Close off the JSON string
              pOutStr += '}';
              return;
            endif;
          when pMark = 'M'
            or pMark = 'P';
            // is this a super po
            exec sql select * into :purec
                     from pospo
                     where puwhse = :pWhse
                       and puspo   = :pPO
                     fetch first 1 rows only;

            If sqlstt = sqlSuccess;
              super = *On;
            else;
              super = *off;
            endif;
            select;
              when super;
650cA           // get the po's linked to the super po
                exsr setsql;
650cA           dow forever = forever;
                  exec sql fetch next from spocsr
                           into :purec;
                  if sqlstt <> sqlSuccess;
                    exec sql close spocsr;
                    leave;
                  endif;
650eA             if opfrcm = 'Y';
                    FailedEdit = ' ';
                    count = 0;
                    // all lines must be touched
                    exec sql select count(*) into :count
                             from podtl T01 exception join porcv T02
                             on T01.pdpo=T02.porpo and T01.Pdwhse=T02.porwhs
                               and T01.pdseq=T02.porseq
                             where (T02.porseq is null)
700aA                          and t01.pdspcl  <> 'BR'
                               and t01.pdwhse  = :pWhse
                               and t01.pdpo  = :puPO;
                    if sqlstt = sqlsuccess;
                      if count > 0;
                        FailedEdit = ('Po Lines not Marked-'+ pupo);
                      endif;
                    endif;
                  endif;
                  // Packers missing destination storage location
650eA             if client = packers;
                    exec sql select * into :phmrec
                             from pohdrm
                             where phmwh  = :pWhse
                               and phmpo  = :puPO;
                    if sqlstt = sqlsuccess
                       and %subst(phmm5:1:4) = '0000';
                      FailedEdit = (%trim(puPO) + ' ' +
                                   'Missing Destination');
                    endif;
                  endif;
650ca           enddo;
                if FailedEdit <> ' ';
                  pOutStr = '{'
                          +  '"PO":"'  + %trimr(pPO) + '",'
                          +  '"NO":"'  + %trimr(FailedEdit) + '",'
                          +  '"Mark":"'  + %trimr(pMark) + '"';
                  // Close off the JSON string
                  pOutStr += '}';
                  return;
                endif;
              other;
                // check for blocking export function
                FailedEdit = ' ';
                // get po status
                exec sql select * into :phrec
                         from pohdr
                         where phwhse = :pWhse
                           and phpo   = :pPO;
                // check for attached to super po
                exec sql select * into :purec
                         from pospo
                         where puwhse = :pWhse
                           and pupo   = :pPO;

                Select;
                  // attached to super po
                  When sqlstt = sqlSuccess;
                    FailedEdit = 'FE-Attached to Super PO';
                  When phstat = '5';
                    // block export function if import error status
                    FailedEdit = 'FE-Import Error';
650eA             when client = packers;
                    // Packers missing destination storage location
                    exec sql select * into :phmrec
                             from pohdrm
                             where phmwh  = :pWhse
                               and phmpo  = :pPO;
                    if sqlstt = sqlsuccess
                       and %subst(phmm5:1:4) = '0000';
                      FailedEdit = 'FE-Missing Destination';
                    endif;
650eA             when opfrcm = 'Y';
                    count = 0;
                    // all lines must be touched
                    exec sql select count(*) into :count
                             from podtl T01 exception join porcv T02
                             on T01.pdpo=T02.porpo and T01.Pdwhse=T02.porwhs
                               and T01.pdseq=T02.porseq
                             where (T02.porseq is null)
700aA                          and t01.pdspcl  <> 'BR'
                               and t01.pdwhse  = :pWhse
                               and t01.pdpo  = :pPO;
                    if sqlstt = sqlsuccess;
                      if count > 0;
                        FailedEdit = 'FE-All Po Lines not Marked';
                      endif;
                    endif;
                  other;
                endsl;
            endsl;
            if FailedEdit <> ' ';
              pOutStr = '{'
                      +  '"PO":"'  + %trimr(pPO) + '",'
                      +  '"NO":"'  + %trimr(FailedEdit) + '",'
                      +  '"Mark":"'  + %trimr(pMark) + '"';
              // Close off the JSON string
              pOutStr += '}';
              return;
            endif;
        endsl;
        select;
          when pMark = ' ';
            pOutStr = '{'
                    +  '"PO":"'  + %trimr(pPO) + '",'
                    +  '"Mark":"'  + %trimr(pMark) + '"';
            // Close off the JSON string
            pOutStr += '}';
            return;
          when pMark = 'M';
            exec sql update pohdr set
                       phstat = 3
                     where phwhse = :pWhse
                       and phpo = :pPO;
            // is pPO a super po?
            exec sql select * into :purec
                     from pospo
                     where puwhse = :pWhse
                       and puspo   = :pPO
                     fetch first 1 rows only;

            If sqlstt = sqlSuccess;
              super = *on;
            else;
              super = *off;
            endif;

            // now mark all po's attached
            select;
              when super;
                // get the po's linked to the super po
                exsr setsql;
                dow forever = forever;
                  exec sql fetch next from spocsr
                           into :purec;
                  if sqlstt <> sqlSuccess;
                    exec sql close spocsr;
                    leave;
                  endif;
                  exec sql update pohdr set
                            phstat = 3
                           where phwhse = :pWhse
                             and phpo = :pupo;
                enddo;
            endsl;
          when pMark = 'P';
            exec sql update pohdr set
                       phstat = 4
                     where phwhse = :pWhse
                       and phpo = :pPO;
            // is pPO a super po?
            exec sql select * into :purec
                     from pospo
                     where puwhse = :pWhse
                       and puspo   = :pPO
                     fetch first 1 rows only;

            If sqlstt = sqlSuccess;
              super = *on;
            else;
              super = *off;
            endif;

            // now mark all po's attached
            select;
              when super;
                // get the po's linked to the super po
                exsr setsql;
                dow forever = forever;
                  exec sql fetch next from spocsr
                           into :purec;
                  if sqlstt <> sqlSuccess;
                    exec sql close spocsr;
                    leave;
                  endif;
                  exec sql update pohdr set
                            phstat = 4
                           where phwhse = :pWhse
                             and phpo = :pupo;
                enddo;
            endsl;
          when pMark = 'U';
            // is pPO a super po?
            exec sql select * into :purec
                     from pospo
                     where puwhse = :pWhse
                       and puspo   = :pPO
                     fetch first 1 rows only;

            If sqlstt = sqlSuccess;
              super = *on;
            else;
              super = *off;
            endif;

            // now mark all po's attached
            select;
              when super;
                superstat = '0';
                newstat = '0';
                // get the po's linked to the super po
                exsr setsql;
                dow forever = forever;
                  exec sql fetch next from spocsr
                           into :purec;
                  if sqlstt <> sqlSuccess;
                    exec sql close spocsr;
                    leave;
                  endif;
710aA             exsr SetStatus;

                  exec sql update pohdr set
                            phstat = :newstat
                           where phwhse = :pWhse
                             and phpo = :pupo;
                enddo;
                // now update the super po status
                exec sql update pohdr set
                       phstat = :superstat
                     where phwhse = :pWhse
                       and phpo = :pPO;
              other;
710aA           exsr SetStatus;
                // now update the super po status
                exec sql update pohdr set
                       phstat = :newstat
                     where phwhse = :pWhse
                       and phpo = :pPO;
            endsl;
        endsl;
730aA   // is the client doing real time exports
730aA     if pMark = 'M' or pMark = 'P';
730aA       GetOptions(%editc(0:'X'):
730aA                  '*FTP': '001': '001': ExportType);
730aA       if ExportType = 'R';
730aA         dktexport(pwhse:'EXPPO':'I':1:' ':#pgm:exportreturn
730aA                   :exportmessage);
730aA       endif;
730aA     endif;

         pOutStr = '{'
                +  '"PO":"'  + %trimr(pPO) + '",'
                +  '"NO":"'  + %trimr(FailedEdit) + '",'
                +  '"Mark":"'  + %trimr(pMark) + '"';

         // Close off the JSON string
         pOutStr += '}';

      /end-free


     *----------------------------------------------------------------
     *  SetSql   Setup and Declare
     *----------------------------------------------------------------

      /free
       begsr SetSql;
                SqlStmt = 'select * from pospo '
                    +     'where puwhse = ' + %char(pWhse) + ' '
                    +       'and puspo = '
                    +       sq + %trimr(pPO) + sq;
                exec sql prepare sposel from :SqlStmt;
                exec sql declare spocsr cursor for sposel;
                exec sql open spocsr;
       endsr;

      /end-free
710aA*----------------------------------------------------------------
710aA*  SetStatus  Set po header status
710aA*----------------------------------------------------------------

710aA /free
710aA  begsr SetStatus;
710aA    Select;
710aA      when super;
710aA        checkPO = pupo;
710aA      other;
710aA        checkPO = ppo;
710aA    endsl;
710aA    newstat = '0';
710aA    superstat = '0';
710aA    exec sql select * into :pdrec
710aA             from podtl
710aA             where pdwhse = :pWhse
710aA               and pdpo = :checkPO
710aA               and pdqor1 > pdqrc1
710aA               and pdqrc1 > 0
710aA                or pdwhse = :pWhse
710aA               and pdpo = :checkPO
710aA               and pdqor2 > pdqrc2
710aA               and pdqrc2 > 0
710aA                or pdwhse = :pWhse
710aA               and pdpo = :checkPO
710aA               and pdqor3 > pdqrc3
710aA               and pdqrc3 > 0
710aA             fetch first 1 rows only;
710aA    select;
710aA      when sqlstt = sqlSuccess;
710aA        // partial found
710aA        newstat = '1';
710aA      other;
710aA        exec sql select * into :pdrec
710aA                 from podtl
710aA                 where pdwhse = :pWhse
710aA                   and pdpo = :checkPO
710aA                   and pdqrc1 > 0
710aA                    or pdwhse = :pWhse
710aA                   and pdpo = :checkPO
710aA                   and pdqrc2 > 0
710aA                    or pdwhse = :pWhse
710aA                   and pdpo = :checkPO
710aA                   and pdqrc3 > 0
710aA             fetch first 1 rows only;
710aA        select;
710aA          when sqlstt = sqlSuccess;
710aA            // receipt found - last check is it full receipt
710aA            exec sql select * into :pdrec
710aA                     from podtl
710aA                     where pdwhse = :pWhse
710aA                       and pdpo = :checkPO
710aA                       and pdqrc1 = 0
710aA                       and pdqrc2 = 0
710aA                       and pdqrc3 = 0
710aA                 fetch first 1 rows only;
710aA            if sqlstt = sqlSuccess;
710aA              newstat = '1';
710aA            else;
710aA              newstat = '2';
710aA            endif;
710aA          other;
710aA            // open
710aA        endsl;
710aA    endsl;
710aA    Select;
710aA      when super;
710aA        superstat = newstat;
710aA    endsl;
710aA  endsr;

710aA /end-free
     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);
        // see if all lines must be touched
        exec sql select * into :opsrcv
                 from opsrcvlbl
                 where opwhse  = :pWhse;
        if sqlstt = sqlsuccess;
        else;
          opfrcm = 'N';
        endif;

       endsr;

      /end-free

