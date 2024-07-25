      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  EXSUM004   SUM004EX file operations
     *  11 February 2020
     *  Retha Davis
     *
     *  Revisions
     *
740 A*   02/11/20  RBD  7.40
     *     - Created
     *
740aA*   05/21/20  RBD  7.40a
     *     - Changes for transaction.
     *
740bA*   05/22/20  RBD  7.40b
     *     - Added label number to make sum004 and sum004exa records
     *       unique.
     *     - Added date type entered from licinfo.
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
     d smarec        e ds                  extname(sum004exa) inz(*EXTDFT)

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
     *  ismawhse    - Warehouse
     *  ismarptid   - Report id
     *  ismalcns    - License
     *  ismadlvdat  - Delivery date
     *  ismatran    - Transaction number
740bA*  ismalbl     - Label number
740bA*  ismadtetyp  - Date type entered
     *  i(fields)   - All new fields should have options(*nopass)
     *
     *----------------------------------------------------------------

     d EXSUM004        pr                  extpgm('EXSUM004')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ismawhse                            like(smawhse)
     d  ismarptid                           like(smarptid)
     d  ismalcns                            like(smalcns)
     d  ismadlvdat                          like(smadlvdat)
     d  ismatran                            like(smatran)
740bAd  ismalbl                             like(smalbl) options(*nopass)
740bAd  ismadtetyp                          like(smadtetyp) options(*nopass)

     d EXSUM004        pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ismawhse                            like(smawhse)
     d  ismarptid                           like(smarptid)
     d  ismalcns                            like(smalcns)
     d  ismadlvdat                          like(smadlvdat)
     d  ismatran                            like(smatran)
740bAd  ismalbl                             like(smalbl) options(*nopass)
740bAd  ismadtetyp                          like(smadtetyp) options(*nopass)

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
          sum004exa (smawhse, smarptid, smalcns, smadlvdat, smatran,
740bA                smalbl, smadtetyp)
          values (:smawhse, :smarptid, :smalcns, :smadlvdat, :smatran,
740bA             :smalbl, :smadtetyp);

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(smawhse) + '/' + %char(smarptid)
740bM             + '/' + %trim(smalcns)
740bM             + '/' + %char(smalbl) + ' (' + sqlstt + ')';
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
          update sum004exa
          set smadlvdat = :smadlvdat,
              smatran = :smatran
          where smawhse = :smawhse
            and smarptid = :smarptid
740aA       and smalcns = :smalcns
740aA       and smatran = :smatran
740bA       and smalbl  = :smalbl;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Update failed for '
                  + %char(smawhse) + '/' + %char(smarptid)
740aM             + '/' + %trim(smalcns) + '/' + %char(smatran)
740bA             + '/' + %char(smalbl)
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
          delete from sum004exa
          where smawhse = :ismawhse
            and smarptid = :ismarptid
740aA       and smalcns = :ismalcns
740aA       and smatran = :ismatran
740bA       and smalbl  = :ismalbl;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(ismawhse) + '/' + %char(ismarptid)
740aA             + '/' + %trim(ismalcns) + '/' + %char(ismatran)
740bA             + '/' + %char(ismalbl)
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

        exec sql select smawhse, smarptid, smalcns, smadlvdat, smatran,
740bA                   smalbl, smadtetyp
                  into :smawhse, :smarptid, :smalcns, :smadlvdat, :smatran,
740bA                  :smalbl, :smadtetyp
                 from sum004exa
                 where smawhse = :ismawhse
                   and smarptid = :ismarptid
740aA              and smalcns = :ismalcns
740aA              and smatran = :ismatran
740bA              and smalbl  = :ismalbl;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(ismawhse) + '/' + %char(ismarptid)
740bM             + '/' + %trim(smalcns)
740bA             + '/' + %char(smalbl) + ' not found'
                  + ' (' + sqlstt + ')';
          clear smarec;
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
         clear smarec;
         smawhse = ismawhse;
         smarptid = ismarptid;
         smalcns = ismalcns;
740bA    smalbl  = ismalbl;
       endif;

       if parmsSent >= 7;
         if direction = 'ParmsToRec';
           smadlvdat = ismadlvdat;
         else;
           ismadlvdat = smadlvdat;
         endif;
       endif;

       if parmsSent >= 8;
         if direction = 'ParmsToRec';
           smatran = ismatran;
         else;
           ismatran = smatran;
         endif;
       endif;

740bA  if parmsSent >= 9;
740bA    if direction = 'ParmsToRec';
740bA      smalbl = ismalbl;
740bA    else;
740bA      ismalbl = smalbl;
740bA    endif;
740bA  endif;

740bA  if parmsSent >= 10;
740bA    if direction = 'ParmsToRec';
740bA      smadtetyp = ismadtetyp;
740bA    else;
740bA      ismadtetyp = smadtetyp;
740bA    endif;
740bA  endif;

      /end-free

     p                 e

