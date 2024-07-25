      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETPCMEX    Get Pcm Exceptions
     *  27 September 2018
     *  Lynn McMahon
     *
     *  Revisions:
     *
720 A*    09/27/18  LMC  7.20
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D pcmrec        E ds                  extname(podtl) prefix(d_)
     D hlrec         E ds                  extname(haccplog) prefix(hl_)


     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

        // SQL Data Structure for TTSTP retrieval


     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

     D  pWhse          s              3p 0
     D  pPO            s              9
     D  pPOSeq         s              5p 0
     D  pPcmCount      s              5p 0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pPOSeq      Purchase Order Sequence
     *
     *    Returned Parameters
     *      pPCMCount   For header - a total count for po lines
     *                  For detail - a count > 0 implies that poseq
     *                               has pcm exceptions.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pPO
     C                   parm                    pPOSeq
     C                   parm                    pPCMCount

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
        forever = forever;

        pPCMcount = 0;

        select;
          when pposeq = 0;
            // loop through the podtl if this is a header request
            sqlStmt = 'select * ' +
                      'from podtl ' +
                       'where pdwhse=' + %char(pWhse) + ' and ' +
                       'pdpo=' +  sq + %trim(pPO) + sq
                +   'and pdspcl <> ' + sq + 'BR' + sq;

            exec sql PREPARE pcmsel FROM :SqlStmt;
            exec sql DECLARE pcmcsr SCROLL CURSOR FOR pcmsel;
            exec sql OPEN pcmcsr;

            dow forever = forever;
              exec sql fetch next from pcmcsr into :pcmrec;

              if sqlstt <> sqlSuccess;
                leave;
              endif;
              // do I have pcm exceptions for this po detail line
700aA         exec sql select * into :hlrec
700aA            from haccplog
700aA            where hlwhse = :pwhse
700aA              and hlpo   = :ppo
700aA              and hlposeq = :d_pdseq
700aA              and hlexpts = '0001-01-01-00.00.00.000000'
700aA              and hlobsolete <> 'Y'
700aA              and hllevl = 'REXI'
700aA            fetch first row only;
700aA         if sqlstt = sqlSuccess;
                ppcmcount = ppcmcount + 1;
700aA         endif;
            enddo;
            exec sql close pcmcsr;

          when pposeq = 0;
            // do I have pcm exceptions for this po detail line
700aA       exec sql select * into :hlrec
700aA          from haccplog
700aA          where hlwhse = :pwhse
700aA            and hlpo   = :ppo
700aA            and hlposeq = :d_pdseq
700aA            and hlexpts = '0001-01-01-00.00.00.000000'
700aA            and hlobsolete <> 'Y'
700aA            and hllevl = 'REXI'
700aA          fetch first row only;
700aA       if sqlstt = sqlSuccess;
              ppcmcount = ppcmcount + 1;
700aA       endif;
        endsl;

        *inlr = *on;
        return;

        begsr *INZSR;
           forever = forever;
         endsr;

      /end-free

