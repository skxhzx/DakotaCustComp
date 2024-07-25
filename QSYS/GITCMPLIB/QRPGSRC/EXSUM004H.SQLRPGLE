      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  EXSUM004H   SUM004HEX file operations
     *  10 February 2020
     *  Retha Davis
     *
     *  Revisions
     *
740 A*   02/10/20  RBD  7.40
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
     d sharec        e ds                  extname(sum004hexa) inz(*EXTDFT)

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
     *  ishawhse    - Warehouse
     *  isharptid   - Report id
     *  isharoute   - Route
     *  ishartid    - Route id
     *  ishafdlvdat - From delivery date
     *  ishatdlvdat - To delivery date
     *  ishapo      - Purchase orders
     *  ishatrn     - Transactions
     *  i(fields)   - All new fields should have options(*nopass)
     *
     *----------------------------------------------------------------

     d EXSUM004H       pr                  extpgm('EXSUM004H')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ishawhse                            like(shawhse)
     d  isharptid                           like(sharptid)
     d  isharoute                           like(sharoute)
     d  ishartid                            like(shartid)
     d  ishafdlvdat                         like(shafdlvdat)
     d  ishatdlvdat                         like(shatdlvdat)
     d  ishapo                              like(shapo)
     d  ishatrn                             like(shatrn)

     d EXSUM004H       pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ishawhse                            like(shawhse)
     d  isharptid                           like(sharptid)
     d  isharoute                           like(sharoute)
     d  ishartid                            like(shartid)
     d  ishafdlvdat                         like(shafdlvdat)
     d  ishatdlvdat                         like(shatdlvdat)
     d  ishapo                              like(shapo)
     d  ishatrn                             like(shatrn)

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
          sum004hexa (shawhse, sharptid, sharoute, shartid, shafdlvdat,
                   shatdlvdat, shapo, shatrn)
          values (:shawhse, :sharptid, :sharoute, :shartid, :shafdlvdat,
                  :shatdlvdat, :shapo, :shatrn);

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(shawhse) + '/' + %char(sharptid)
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
          update sum004hexa
          set sharoute = :sharoute,
              shartid = :shartid,
              shafdlvdat = :shafdlvdat,
              shatdlvdat = :shatdlvdat,
              shapo = :shapo,
              shatrn = :shatrn
          where shawhse = :shawhse
            and sharptid = :sharptid;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Update failed for '
                  + %char(shawhse) + '/' + %char(sharptid)
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
          delete from sum004hexa
          where shawhse = :ishawhse
            and sharptid = :isharptid;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(ishawhse) + '/' + %char(isharptid)
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

        exec sql select shawhse, sharptid, sharoute, shartid, shafdlvdat,
                        shatdlvdat, shapo, shatrn
                  into :shawhse, :sharptid, :sharoute, :shartid, :shafdlvdat,
                       :shatdlvdat, :shapo, :shatrn
                 from sum004hexa
                 where shawhse = :ishawhse
                   and sharptid = :isharptid;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(ishawhse) + '/' + %char(isharptid)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear sharec;
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
         clear sharec;
         shawhse = ishawhse;
         sharptid = isharptid;
       endif;

       if parmsSent >= 6;
         if direction = 'ParmsToRec';
           sharoute = isharoute;
         else;
           isharoute = sharoute;
         endif;
       endif;

       if parmsSent >= 7;
         if direction = 'ParmsToRec';
           shartid = ishartid;
         else;
           ishartid = shartid;
         endif;
       endif;

       if parmsSent >= 8;
         if direction = 'ParmsToRec';
           shafdlvdat = ishafdlvdat;
         else;
           ishafdlvdat = shafdlvdat;
         endif;
       endif;

       if parmsSent >= 9;
         if direction = 'ParmsToRec';
           shatdlvdat = ishatdlvdat;
         else;
           ishatdlvdat = shatdlvdat;
         endif;
       endif;

       if parmsSent >= 10;
         if direction = 'ParmsToRec';
           shapo = ishapo;
         else;
           ishapo = shapo;
         endif;
       endif;

       if parmsSent >= 11;
         if direction = 'ParmsToRec';
           shatrn = ishatrn;
         else;
           ishatrn = shatrn;
         endif;
       endif;

      /end-free

     p                 e

