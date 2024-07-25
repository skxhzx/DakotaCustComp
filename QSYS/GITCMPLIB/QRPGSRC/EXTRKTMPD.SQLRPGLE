      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  EXTRKTMPD  TRKTMPDEXA file operations
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
     d TTXREC        e ds                  extname(trktmpdexa) inz(*EXTDFT)

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

     d EXTRKTMPD       pr                  extpgm('EXTRKTMPD')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iiwhse                        3s 0
     d  iitruk                       10
     d  iirow                         2s 0
     d  iicube1                       5s 2 options(*nopass)
     d  iicube2                       5s 2 options(*nopass)
     d  iicube3                       5s 2 options(*nopass)
     d  iicube4                       5s 2 options(*nopass)
     d  iicube5                       5s 2 options(*nopass)
     d  iicube6                       5s 2 options(*nopass)
     d  iicube7                       5s 2 options(*nopass)
     d  iicube8                       5s 2 options(*nopass)
     d  iicube9                       5s 2 options(*nopass)

     d EXTRKTMPD       pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iiwhse                        3s 0
     d  iitruk                       10
     d  iirow                         2s 0
     d  iicube1                       5s 2 options(*nopass)
     d  iicube2                       5s 2 options(*nopass)
     d  iicube3                       5s 2 options(*nopass)
     d  iicube4                       5s 2 options(*nopass)
     d  iicube5                       5s 2 options(*nopass)
     d  iicube6                       5s 2 options(*nopass)
     d  iicube7                       5s 2 options(*nopass)
     d  iicube8                       5s 2 options(*nopass)
     d  iicube9                       5s 2 options(*nopass)

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
          trktmpdexa (ttxwhse, ttxtruk, ttxrow, ttxicub1, ttxicub2, ttxicub3,
                      ttxicub4, ttxicub5, ttxicub6, ttxicub7, ttxicub8,
                      ttxicub9)
          values (:iiwhse, :iitruk, :iirow, :ttxicub1, :ttxicub2, :ttxicub3,
                  :ttxicub4, :ttxicub5, :ttxicub6, :ttxicub7, :ttxicub8,
                  :ttxicub9);

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(iiwhse) + '/' + %trim(iitruk)
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
          update trktmpdexa
          set ttxicub1=:ttxicub1, ttxicub2=:ttxicub2, ttxicub3=:ttxicub3,
              ttxicub4=:ttxicub4, ttxicub5=:ttxicub5, ttxicub6=:ttxicub6,
              ttxicub7=:ttxicub7, ttxicub8=:ttxicub8, ttxicub9=:ttxicub9
          where ttxwhse = :iiwhse
            and ttxtruk = :iitruk
            and ttxrow  = :iirow;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Update failed for '
                  + %char(iiwhse) + '/' + %trim(iitruk)
                  + '/' + %char(iirow)
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
          delete from trktmpdexa
          where ttxwhse = :iiwhse
            and ttxtruk = :iitruk
            and ttxrow = :iirow;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(iiwhse) + '/' + %trim(iitruk)
                  + '/' + %char(iirow)
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

        exec sql select ttxwhse, ttxtruk, ttxrow, ttxicub1, ttxicub2, ttxicub3,
                        ttxicub4, ttxicub5, ttxicub6, ttxicub7, ttxicub8,
                        ttxicub9
                  into :ttxwhse, :ttxtruk, :ttxrow, :ttxicub1, :ttxicub2,
                       :ttxicub3, :ttxicub4, :ttxicub5, :ttxicub6, :ttxicub7,
                       :ttxicub8, :ttxicub9
                 from trktmpdexa
                 where ttxwhse = :iiwhse
                   and ttxtruk = :iitruk
                   and ttxrow  = :iirow;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(iiwhse) + '/' + %trim(iitruk)
                  + '/' + %char(iirow)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear ttxrec;
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
         clear ttxrec;
         ttxwhse = iiwhse;
         ttxtruk = iitruk;
         ttxrow  = iirow;
         ttxicub1= iicube1;
         ttxicub2= iicube2;
         ttxicub3= iicube3;
         ttxicub4= iicube4;
         ttxicub5= iicube5;
         ttxicub6= iicube6;
         ttxicub7= iicube7;
         ttxicub8= iicube8;
         ttxicub9= iicube9;
       else;
         iiwhse  = ttxwhse;
         iitruk  = ttxtruk;
         iirow   = ttxrow;
         iicube1 = ttxicub1;
         iicube2 = ttxicub2;
         iicube3 = ttxicub3;
         iicube4 = ttxicub4;
         iicube5 = ttxicub5;
         iicube6 = ttxicub6;
         iicube7 = ttxicub7;
         iicube8 = ttxicub8;
         iicube9 = ttxicub9;
       endif;

      /end-free

     p                 e

