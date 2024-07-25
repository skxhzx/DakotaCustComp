      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  EXTTSTP   TTSTPEX file operations
     *  23 April 2020
     *  Retha Davis
     *
     *  Revisions
     *
740aA*   04/23/20  RBD  7.40a
     *     - Created
     *
740bA*   12/14/20  RBD  7.40b
     *     - Fix: Enlarged size of iRtnMsg from 60 to 120 because
     *       #pgmmsg is 80 long and it's being returned in *PSSR.
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
     *   Each field should have a corresponding sent flag.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File record
     *----------------------------------------------------------------
     d ttparec       e ds                  extname(ttstpexa) inz(*EXTDFT)

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
     *  ittpawhs   - Warehouse
     *  ittparti   - Route id
     *  ittpastp   - Stop
     *  ittpapss   - PALLETSCAN scanned count
     *  ittpapsc   - PALLETSCAN clicked count
     *  ittpapal   - Total pallet count
     *  ittpaiss   - INSTORESCAN scanned count
     *  ittpaisc   - INSTORESCAN clicked count
     *  ittpaist   - INSTORESCAN total count
     *  ittparetsh - Return code short count
     *  ittparet   - Total qty items returned
     *  i(fields) - All new fields should have options(*nopass)
     *  s(fields) - Corresponding sent flags.
     *
     *----------------------------------------------------------------

     d EXTTSTP         pr                  extpgm('EXTTSTP')
     d  iCmd                         10    const
     d  iRtnCode                     10
740bDd* iRtnMsg                      60
740bMd  iRtnMsg                     120
     d  ittpawhs                            like(ttpawhs)
     d  ittparti                            like(ttparti)
     d  ittpastp                            like(ttpastp) options(*nopass)
     d  ittpapss                            like(ttpapss) options(*nopass)
     d  sttpapss                       n    const options(*nopass)
     d  ittpapsc                            like(ttpapsc) options(*nopass)
     d  sttpapsc                       n    const options(*nopass)
     d  ittpapal                            like(ttpapal) options(*nopass)
     d  sttpapal                       n    const options(*nopass)
     d  ittpaiss                            like(ttpaiss) options(*nopass)
     d  sttpaiss                       n    const options(*nopass)
     d  ittpaisc                            like(ttpaisc) options(*nopass)
     d  sttpaisc                       n    const options(*nopass)
     d  ittpaist                            like(ttpaist) options(*nopass)
     d  sttpaist                       n    const options(*nopass)
     d  ittparetsh                          like(ttparetsh) options(*nopass)
     d  sttparetsh                     n    const options(*nopass)
     d  ittparet                            like(ttparet) options(*nopass)
     d  sttparet                       n    const options(*nopass)

     d EXTTSTP         pi
     d  iCmd                         10    const
     d  iRtnCode                     10
740bDd* iRtnMsg                      60
740bMd  iRtnMsg                     120
     d  ittpawhs                            like(ttpawhs)
     d  ittparti                            like(ttparti)
     d  ittpastp                            like(ttpastp) options(*nopass)
     d  ittpapss                            like(ttpapss) options(*nopass)
     d  sttpapss                       n    const options(*nopass)
     d  ittpapsc                            like(ttpapsc) options(*nopass)
     d  sttpapsc                       n    const options(*nopass)
     d  ittpapal                            like(ttpapal) options(*nopass)
     d  sttpapal                       n    const options(*nopass)
     d  ittpaiss                            like(ttpaiss) options(*nopass)
     d  sttpaiss                       n    const options(*nopass)
     d  ittpaisc                            like(ttpaisc) options(*nopass)
     d  sttpaisc                       n    const options(*nopass)
     d  ittpaist                            like(ttpaist) options(*nopass)
     d  sttpaist                       n    const options(*nopass)
     d  ittparetsh                          like(ttparetsh) options(*nopass)
     d  sttparetsh                     n    const options(*nopass)
     d  ittparet                            like(ttparet) options(*nopass)
     d  sttparet                       n    const options(*nopass)

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
           DoGet();
           if iRtnCOde = '*OK';
             Move('ParmsToRec');
             DoChange();
           endif;

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
          ttstpexa (ttpawhs, ttparti, ttpastp,
                    ttpapss, ttpapsc, ttpapal, ttpaiss, ttpaisc, ttpaist,
                    ttparetsh, ttparet)
          values (:ttpawhs, :ttparti, :ttpastp,
                  :ttpapss, :ttpapsc, :ttpapal, :ttpaiss, :ttpaisc, :ttpaist,
                  :ttparetsh, :ttparet);

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(ttpawhs) + '/' + %trim(ttparti)
                  + '/' + %char(ttpastp)
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
          update ttstpexa
          set ttpapss = :ttpapss, ttpapsc = :ttpapsc,
              ttpapal = :ttpapal, ttpaiss = :ttpaiss,
              ttpaisc = :ttpaisc, ttpaist = :ttpaist,
              ttparetsh = :ttparetsh, ttparet = :ttparet
          where ttpawhs = :ttpawhs
            and ttparti = :ttparti
            and ttpastp = :ttpastp;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Update failed for '
                  + %char(ttpawhs) + '/' + %trim(ttparti)
                  + '/' + %char(ttpastp)
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
          delete from ttstpexa
          where ttpawhs = :ittpawhs
            and ttparti = :ittparti
            and ttpastp = :ittpastp;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(ittpawhs) + '/' + %trim(ittparti)
                  + '/' + %char(ittpastp)
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

        exec sql select ttpawhs, ttparti, ttpastp,
                        ttpapss, ttpapsc, ttpapal, ttpaiss,
                        ttpaisc, ttpaist, ttparetsh, ttparet
                  into :ttpawhs, :ttparti, :ttpastp,
                       :ttpapss, :ttpapsc, :ttpapal, :ttpaiss,
                       :ttpaisc, :ttpaist, :ttparetsh, :ttparet
                 from ttstpexa
                 where ttpawhs = :ittpawhs
                   and ttparti = :ittparti
                   and ttpastp = :ittpastp;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(ittpawhs) + '/' + %trim(ittparti)
                  + '/' + %char(ittpastp)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear ttparec;
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
         clear ttparec;
         ttpawhs = ittpawhs;
         ttparti = ittparti;
         ttpastp = ittpastp;
       endif;

       if parmsSent >= 4;
         if direction = 'ParmsToRec' and sttpapss;
           ttpapss = ittpapss;
         else;
           ittpapss = ttpapss;
         endif;
       endif;

       if parmsSent >= 6;
         if direction = 'ParmsToRec' and sttpapsc;
           ttpapsc = ittpapsc;
         else;
           ittpapsc = ttpapsc;
         endif;
       endif;

       if parmsSent >= 8;
         if direction = 'ParmsToRec' and sttpapal;
           ttpapal = ittpapal;
         else;
           ittpapal = ttpapal;
         endif;
       endif;

       if parmsSent >= 10;
         if direction = 'ParmsToRec' and sttpaiss;
           ttpaiss = ittpaiss;
         else;
           ittpaiss = ttpaiss;
         endif;
       endif;

       if parmsSent >= 12;
         if direction = 'ParmsToRec' and sttpaisc;
           ttpaisc = ittpaisc;
         else;
           ittpaisc = ttpaisc;
         endif;
       endif;

       if parmsSent >= 14;
         if direction = 'ParmsToRec' and sttpaist;
           ttpaist = ittpaist;
         else;
           ittpaist = ttpaist;
         endif;
       endif;

       if parmsSent >= 16;
         if direction = 'ParmsToRec' and sttparetsh;
           ttparetsh = ittparetsh;
         else;
           ittparetsh = ttparetsh;
         endif;
       endif;

       if parmsSent >= 18;
         if direction = 'ParmsToRec' and sttparet;
           ttparet = ittparet;
         else;
           ittparet = ttparet;
         endif;
       endif;

      /end-free

     p                 e

