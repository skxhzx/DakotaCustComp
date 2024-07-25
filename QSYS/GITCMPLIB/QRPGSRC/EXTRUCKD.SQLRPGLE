      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  EXTRUCKD  TRUCKDEXA file operations
     *  28 August 2020
     *  Kenneth Elder
     *
     *  Revisions
     *
740 A*   08/28/20  KDE  7.40
     *     - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *   This program only does file operations, it does not do any
     *   field error checking.
     *
     *   *INLR is only set on with *CLOSE is sent in.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File record
     *----------------------------------------------------------------
     d TDXREC        e ds                  extname(truckdexa) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d parmsSent       s              3  0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d DoAdd           pr

     d DoChange        pr

     d DoDelete        pr

     d DoGet           pr

     d Move            pr
     d  direction                    10    const

     *----------------------------------------------------------------
     *  Parameters
     *
     *  iCmd      - *ADD, *CHANGE, *DELETE, *GET, *CLOSE
     *  iRtnCode
     *  iRtnMsg
     *  iioewhs  - Warehouse
     *  iioeitm  - Item Number
     *  iioebd1  - Breakdown 1 Quantity
     *
     *----------------------------------------------------------------

     d EXTRUCKD        pr                  extpgm('EXTRUCKD')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iiwhse                        3s 0
     d  iitruk                       10
     d  iirow                         2s 0
     d  iicol                         1s 0
     d  iicube                        5s 2

     d EXTRUCKD        pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iiwhse                        3s 0
     d  iitruk                       10
     d  iirow                         2s 0
     d  iicol                         1s 0
     d  iicube                        5s 2

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free

       iRtnCode = '*OK';
       iRtnMsg = '';
       parmsSent = %parms;

       select;

         when iCmd = '*ADD';
           Move('ParmsToRec');
           DoAdd();

         when iCmd = '*CHANGE';
           Move('ParmsToRec');
           DoChange();

         when iCmd = '*DELETE';
           DoDelete();

         when iCmd = '*GET';
           DoGet();
           Move('RecToParms');

         when iCmd = '*CLOSE';
           *inlr = *on;

       endsl;

       return;

      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);

         iRtnCode = '*ERROR';
         iRtnMsg = 'PSSR: ' + %trim(#pgm) + ' (' + %char(#stmt) + ') '
                 + #status + ' - ' + %trim(#pgmmsg);

         *inlr = *on;
         return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DoAdd    Add record
     *----------------------------------------------------------------

     p DoAdd           b
     d DoAdd           pi

     * Local Variables

     d count           s              1  0

      /free

        exec sql
          insert into
          truckdexa  (tdxwhse, tdxtruk, tdxrow, tdxcol, tdxicube)
          values (:iiwhse, :iitruk, :iirow, :iicol, :tdxicube);

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(iiwhse) + '/' + %trim(iitruk)
                  + '/' + %char(iirow)
                  + '/' + %char(iicol)
                  + ' (' + sqlstt + ')';
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DoChange    Update record
     *----------------------------------------------------------------

     p DoChange        b
     d DoChange        pi

     * Local Variables

     d count           s              1  0

      /free

        exec sql
          update truckdexa
          set tdxicube=:tdxicube
          where tdxwhse = :iiwhse
            and tdxtruk = :iitruk
            and tdxrow  = :iirow
            and tdxcol  = :iicol;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Update failed for '
                  + %char(iiwhse) + '/' + %trim(iitruk)
                  + '/' + %char(iirow)
                  + '/' + %char(iicol)
                  + ' (' + sqlstt + ')';
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DoDelete    Delete record
     *----------------------------------------------------------------

     p DoDelete        b
     d DoDelete        pi

     * Local Variables

     d count           s              1  0

      /free

        exec sql
          delete from truckdexa
          where tdxwhse = :iiwhse
            and tdxtruk = :iitruk
            and tdxrow = :iirow
            and tdxcol = :iicol;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(iiwhse) + '/' + %trim(iitruk)
                  + '/' + %char(iirow)
                  + '/' + %char(iicol)
                  + ' (' + sqlstt + ')';
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DoGet   Get record
     *----------------------------------------------------------------

     p DoGet           b
     d DoGet           pi

      /free

        exec sql select tdxwhse, tdxtruk, tdxrow, tdxcol, tdxicube
                  into :tdxwhse, :tdxtruk, :tdxrow, :tdxcol, :tdxicube
                 from truckdexa
                 where tdxwhse = :iiwhse
                   and tdxtruk = :iitruk
                   and tdxrow  = :iirow
                   and tdxcol = :iicol;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(iiwhse) + '/' + %trim(iitruk)
                  + '/' + %char(iirow)
                  + '/' + %char(iicol)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear tdxrec;
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  Move        Move fields to/from between parameters and record
     *----------------------------------------------------------------

     p Move            b
     d Move            pi
     d  direction                    10    const

      /free

       if direction = 'ParmsToRec';
         clear tdxrec;
         tdxwhse = iiwhse;
         tdxtruk = iitruk;
         tdxrow  = iirow;
         tdxcol  = iicol;
         tdxicube= iicube;
       else;
         iiwhse  = tdxwhse;
         iitruk  = tdxtruk;
         iirow   = tdxrow;
         iicol   = tdxcol;
         iicube  = tdxicube;
       endif;

      /end-free

     p                 e

