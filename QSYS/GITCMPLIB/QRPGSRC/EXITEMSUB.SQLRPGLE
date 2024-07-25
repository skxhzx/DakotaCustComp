      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  EXITEMSUB   ITEMSUB extra fields file operations
     *  11 April 2021
     *  Retha Davis
     *
     *  Revisions
     *
750aA*   06/11/21  RBD  7.50a
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
     *   Each field should have a corresponding sent flag.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File record
     *----------------------------------------------------------------
     d isxrec        e ds                  extname(itemsubexa) inz(*EXTDFT)

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
     *  iisxwhse   - Warehouse
     *  iisxitem   - Original item
     *  iisxcust   - Customer number
     *  iisxisub   - Sub item
     *  iisxas     - Auto sub flag (0,1)
     *  iisxseq    - Substitute sequence
     *  iisxaddts  - Add t/s
     *  iisxaddusr - Add user
     *  i(fields) - All new fields should have options(*nopass)
     *
     *----------------------------------------------------------------

     d EXITEMSUB       pr                  extpgm('EXITEMSUB')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                     120
     d  iisxwhse                            like(isxwhse)
     d  iisxitem                            like(isxitem)
     d  iisxcust                            like(isxcust)
     d  iisxisub                            like(isxisub) options(*nopass)
     d  iisxas                              like(isxas) options(*nopass)
     d  iisxseq                             like(isxseq) options(*nopass)
     d  iisxaddts                           like(isxaddts) options(*nopass)
     d  iisxaddusr                          like(isxaddusr) options(*nopass)

     d EXITEMSUB       pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                     120
     d  iisxwhse                            like(isxwhse)
     d  iisxitem                            like(isxitem)
     d  iisxcust                            like(isxcust)
     d  iisxisub                            like(isxisub) options(*nopass)
     d  iisxas                              like(isxas) options(*nopass)
     d  iisxseq                             like(isxseq) options(*nopass)
     d  iisxaddts                           like(isxaddts) options(*nopass)
     d  iisxaddusr                          like(isxaddusr) options(*nopass)

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

         when iCmd = '*UPDATE';
           Move('ParmsToRec');
           DoChange();

         when iCmd = '*DELETE';
           DoDelete();

         when iCmd = '*GET';
           DoGet();
           Move('RecToParms');

         when iCmd = '*GETSEQ';
           DoNxtSeq();
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
          itemsubexa (isxwhse, isxitem, isxcust,
                    isxisub, isxas, isxseq,
                    isxaddts, isxaddusr)
          values (:isxwhse, :isxitem, :isxcust,
                  :isxisub, :isxas, :isxseq,
                  :isxaddts, :isxaddusr);

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(isxwhse) + '/' + %trim(isxitem)
                  + '/' + %char(isxcust)
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
          update itemsubexa
          set isxas = :isxas,
              isxseq = :isxseq,
              isxaddts = :isxaddts,
              isxaddusr = :isxaddusr
          where isxwhse = :isxwhse
            and isxitem = :isxitem
            and isxcust = :isxcust
            and isxisub = :isxisub;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(isxwhse) + '/' + %trim(isxitem)
                  + '/' + %char(isxcust) + '/' + %trim(isxisub)
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
          delete from itemsubexa
          where isxwhse = :iisxwhse
            and isxitem = :iisxitem
            and isxcust = :iisxcust
            and isxisub = :iisxisub
            and isxas   = :iisxas
            and isxseq  = :iisxseq;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(iisxwhse) + '/' + %trim(iisxitem)
                  + '/' + %char(iisxcust)
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

        exec sql select isxwhse, isxitem, isxcust,
                        isxisub, isxas, isxseq,
                        isxaddts, isxaddusr
                  into :isxwhse, :isxitem, :isxcust,
                       :isxisub, :isxas, :isxseq,
                       :isxaddts, :isxaddusr
                 from itemsubexa
                 where isxwhse = :iisxwhse
                   and isxitem = :iisxitem
                   and isxcust = :iisxcust
          order by isxwhse,isxitem,isxcust,isxas,isxseq,isxisub;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(iisxwhse) + '/' + %trim(iisxitem)
                  + '/' + %char(iisxcust)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear isxrec;
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DoNxtSeq  Get Next Sequence after value passed.  This will allow
     *  us to read the first record through the last if necessary
     *----------------------------------------------------------------

     p DoNxtSeq        b
     d DoNxtSeq        pi

      /free

        exec sql select isxwhse, isxitem, isxcust,
                        isxisub, isxas, isxseq,
                        isxaddts, isxaddusr
                  into :isxwhse, :isxitem, :isxcust,
                       :isxisub, :isxas, :isxseq,
                       :isxaddts, :isxaddusr
                 from itemsubexa
                 where isxwhse = :iisxwhse
                   and isxitem = :iisxitem
                   and isxcust = :iisxcust
                   and isxas   = :iisxas
                   and isxseq  > :iisxseq
                 order by isxwhse,isxitem,isxcust,isxseq
                   fetch first row only;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(iisxwhse) + '/' + %trim(iisxitem)
                  + '/' + %char(iisxcust)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear isxrec;
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
         clear isxrec;
         isxwhse = iisxwhse;
         isxitem = iisxitem;
         isxcust = iisxcust;
       endif;

       if parmsSent >= 7;
         if direction = 'ParmsToRec';
           isxisub = iisxisub;
         else;
           iisxisub = isxisub;
         endif;
       endif;

       if parmsSent >= 8;
         if direction = 'ParmsToRec';
           isxas = iisxas;
         else;
           iisxas = isxas;
         endif;
       endif;

       if parmsSent >= 9;
         if direction = 'ParmsToRec';
           isxseq = iisxseq;
         else;
           iisxseq = isxseq;
         endif;
       endif;

       if parmsSent >= 10;
         if direction = 'ParmsToRec';
           isxaddts = iisxaddts;
         else;
           iisxaddts = isxaddts;
         endif;
       endif;

       if parmsSent >= 11;
         if direction = 'ParmsToRec';
           isxaddusr = iisxaddusr;
         else;
           iisxaddusr = isxaddusr;
         endif;
       endif;


      /end-free

     p                 e

