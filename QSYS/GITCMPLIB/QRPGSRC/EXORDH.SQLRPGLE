      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  EXORDH    ORDHEX file operations
     *  19 October 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720 A*   10/19/18  DAS  7.20
     *     - Created
     *
730aA*   01/22/19  DAS  7.30a
     *     - Fixed Change logic
     *     - Added OHAAUDTS field.
     *
730bA*   03/14/19  DAS  7.30b
     *     - Added OHAORDA and OHACUSTA fields
     *
740 A*   05/01/20  KDE  7.40
     *     - Change doChange to only update alpha customer number
     *       and alpha customer order number when passed in
     *
750aA*   07/26/21  NLK  7.50a
     *     - Add doGETID, used when CORD is available but not
     *       order id (CMD *GETID) Now go back and read ORDH(CK370)
     *       direction = 'RecToParms' needed to move ohaord
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
     d oharec        e ds                  extname(ordhexa) inz(*EXTDFT)

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

750aAd DoGetID         pr

     d Move            pr
     d  direction                    10    const

     *----------------------------------------------------------------
     *  Parameters
     *
     *  iCmd      - *ADD, *CHANGE, *DELETE, *GET, *CLOSE
750a *            - *GETID,
     *  iRtnCode
     *  iRtnMsg
     *  iohawhse  - Warehouse
     *  iohaord   - Order number
     *  iohaaudflg - Audit flag
     *  iohaaudid  - Audit id
     *  iohaaudcmp - Audit completed flag
     *  iohaaudby  - Audit completed by employee number
     *  i(fields) - All new fields should have options(*nopass)
     *
     *----------------------------------------------------------------

     d EXORDH          pr                  extpgm('EXORDH')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iohawhse                            like(ohawhse)
     d  iohaord                             like(ohaord)
     d  iohaaudflg                          like(ohaaudflg) options(*nopass)
     d  iohaaudid                           like(ohaaudid) options(*nopass)
     d  iohaaudcmp                          like(ohaaudcmp) options(*nopass)
     d  iohaaudby                           like(ohaaudby) options(*nopass)
730aAd  iohaaudts                           like(ohaaudts) options(*nopass)
730bAd  iohaorda                            like(ohaorda) options(*nopass)
730bAd  iohacusta                           like(ohacusta) options(*nopass)

     d EXORDH          pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iohawhse                            like(ohawhse)
     d  iohaord                             like(ohaord)
     d  iohaaudflg                          like(ohaaudflg) options(*nopass)
     d  iohaaudid                           like(ohaaudid) options(*nopass)
     d  iohaaudcmp                          like(ohaaudcmp) options(*nopass)
     d  iohaaudby                           like(ohaaudby) options(*nopass)
730aAd  iohaaudts                           like(ohaaudts) options(*nopass)
730bAd  iohaorda                            like(ohaorda) options(*nopass)
730bAd  iohacusta                           like(ohacusta) options(*nopass)

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

750a     when iCmd = '*GETID';
750a       DoGetID();
750a       Move('RecToParms');

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
730aM     ordhexa (ohawhse, ohaord, ohaaudflg, ohaaudid, ohaaudcmp,
730bM              ohaaudby, ohaaudts, ohaorda, ohacusta)
          values (:ohawhse, :ohaord, :ohaaudflg, :ohaaudid, :ohaaudcmp,
730bM             :ohaaudby, :ohaaudts, :ohaorda, :ohacusta);

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(ohawhse) + '/' + %char(ohaord)
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
          update ordhexa
730aM     set ohaaudflg = :ohaaudflg,
730aM         ohaaudid = :ohaaudid,
730aM         ohaaudcmp = :ohaaudcmp,
730aM         ohaaudby = :ohaaudby,
730aA         ohaaudts = :ohaaudts
          where ohawhse = :ohawhse
730aM       and ohaord = :ohaord;

740 A  // Only update alpha order if sent in
740 A  if parmsSent >= 11;
740 A   exec sql
740 A     update ordhexa
740 A     set ohaorda = :ohaorda
740 A     where ohaord = :ohaord;
740 A  endif;

740 A  // Only update alpha customer number if sent
740 A  if parmsSent >= 12;
740 A   exec sql
740 A     update ordhexa
740 A     set ohacusta = :ohacusta
740 A     where ohaord = :ohaord;
740 A  endif;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Update failed for '
                  + %char(ohawhse) + '/' + %char(ohaord)
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
          delete from ordhexa
          where ohawhse = :iohawhse
            and ohaord = :iohaord;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(iohawhse) + '/' + %char(iohaord)
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

        exec sql select ohawhse, ohaord, ohaaudflg, ohaaudid, ohaaudcmp,
730bM                   ohaaudby, ohaaudts, ohaorda, ohacusta
                  into :ohawhse, :ohaord, :ohaaudflg, :ohaaudid, :ohaaudcmp,
730bM                  :ohaaudby, :ohaaudts, :ohaorda, :ohacusta
                 from ordhexa
                 where ohawhse = :iohawhse
                   and ohaord = :iohaord;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(iohawhse) + '/' + %char(iohaord)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear oharec;
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
750a *  DoGetID   Get record using CORD
     *----------------------------------------------------------------

750a p DoGetID         b
750a d DoGetID         pi

750a  /free

750a    exec sql select ohawhse, ohaord, ohaaudflg, ohaaudid, ohaaudcmp,
750a                    ohaaudby, ohaaudts, ohaorda, ohacusta
750a              into :ohawhse, :ohaord, :ohaaudflg, :ohaaudid, :ohaaudcmp,
750a                   :ohaaudby, :ohaaudts, :ohaorda, :ohacusta
750a             from ordhexa
750a             where ohawhse = :iohawhse
750aM              and ohaorda = :iohaorda;

750a    if sqlstt <> sqlSuccess;
750a      iRtnCode = '*ERROR';
750a      iRtnMsg = 'Record for '
750aM             + %char(iohawhse) + '/' + %char(iohaorda)
750a              + ' not found'
750a              + ' (' + sqlstt + ')';
750a      clear oharec;
750a    endif;

750a  /end-free

750a p                 e

     *----------------------------------------------------------------
     *  Move        Move fields to/from between parameters and record
     *----------------------------------------------------------------

     p Move            b
     d Move            pi
     d  direction                    10    const

      /free

       if direction = 'ParmsToRec';
         clear oharec;
         ohawhse = iohawhse;
         ohaord = iohaord;
       endif;

750aA  if direction = 'RecToParms';
750aA    iohaord = ohaord;
750aA  endif;

       if parmsSent >= 6;
         if direction = 'ParmsToRec';
           ohaaudflg = iohaaudflg;
         else;
           iohaaudflg = ohaaudflg;
         endif;
       endif;

       if parmsSent >= 7;
         if direction = 'ParmsToRec';
           ohaaudid = iohaaudid;
         else;
           iohaaudid = ohaaudid;
         endif;
       endif;

       if parmsSent >= 8;
         if direction = 'ParmsToRec';
           ohaaudcmp = iohaaudcmp;
         else;
           iohaaudcmp = ohaaudcmp;
         endif;
       endif;

       if parmsSent >= 9;
         if direction = 'ParmsToRec';
           ohaaudby = iohaaudby;
         else;
           iohaaudby = ohaaudby;
         endif;
       endif;

730aA  if parmsSent >= 10;
730aA    if direction = 'ParmsToRec';
730aA      ohaaudts = iohaaudts;
730aA    else;
730aA      iohaaudts = ohaaudts;
730aA    endif;
730aA  endif;

730bA  if parmsSent >= 11;
730bA    if direction = 'ParmsToRec';
730bA      ohaorda = iohaorda;
730bA    else;
730bA      iohaorda = ohaorda;
730bA    endif;
730bA  endif;

730bA  if parmsSent >= 12;
730bA    if direction = 'ParmsToRec';
730bA      ohacusta = iohacusta;
730bA    else;
730bA      iohacusta = ohacusta;
730bA    endif;
730bA  endif;

      /end-free

     p                 e

