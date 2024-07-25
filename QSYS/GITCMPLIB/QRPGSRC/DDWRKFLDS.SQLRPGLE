      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  DDWRKFLDS - DDWRKFLDS file operations
     *  24 March 2021
     *  Kenneth Elder
     *
     *  Revisions
     *
750 A*   03/24/21  KDE  7.50
     *     - Created
     *
750aA*   10/26/21  KDE  7.50a
     *     - Correct issue where pallet pid not removed from
     *       DDWRKFLDS when no more stops exist
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
     d ddrecw        e ds                  extname(ddwrkflds) inz(*EXTDFT)

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
     *  iddwwhse  - Warehouse
     *  iddwrtid  - Route Id
     *  iddwsnap  - Snapshot
     *  iddwid    - Id
     *  i(fields) - All new fields should have options(*nopass)
     *
     *----------------------------------------------------------------

     d DDWRKFLDS       pr                  extpgm('DDWRKFLDS')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iddwwhse                            like(ddwwhse)
     d  iddwrtid                            like(ddwrtid)
     d  iddwsnap                            like(ddwsnap)
     d  iddwid                              like(ddwid)
     d  iddwrow                             like(ddwrow)
     d  iddwcol                             like(ddwcol)
     d  iddwmrg                             like(ddwmrg)
     d  iddwspin                            like(ddwspin)

     d DDWRKFLDS       pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iddwwhse                            like(ddwwhse)
     d  iddwrtid                            like(ddwrtid)
     d  iddwsnap                            like(ddwsnap)
     d  iddwid                              like(ddwid)
     d  iddwrow                             like(ddwrow)
     d  iddwcol                             like(ddwcol)
     d  iddwmrg                             like(ddwmrg)
     d  iddwspin                            like(ddwspin)

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
740bA      DoGet();
740bA      Move('RecToParms');
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
          ddwrkflds (ddwwhse, ddwrtid, ddwsnap, ddwid, ddwrow, ddwcol,
                      ddwmrg, ddwspin)
          values (:ddwwhse, :ddwrtid, :ddwsnap, :ddwid, :ddwrow, :ddwcol,
                  :ddwmrg, :ddwspin);

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(ddwwhse) + '/' + %trim(ddwrtid) + '/'
                  + %char(ddwsnap) + '/' + %char(ddwid)
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
          update ddwrkflds
          set ddwmrg = :ddwmrg,
              ddwspin = :ddwspin
          where ddwwhse = :ddwwhse
            and ddwrtid = :ddwrtid
            and ddwsnap = :ddwsnap
            and ddwid = :ddwid;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Update failed for '
                  + %char(ddwwhse) + '/' + %trim(ddwrtid)
                  + %char(ddwsnap) + '/' + %char(ddwid)
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

750aAd count           s              3  0
750aAd wkpid           s             20

      /free
750aA   // when a Stop id we should get parent id to confirm
750aA   // after delete whether any additional stops remain.
750aA   if %subst(iddwid:1:1)='s';
750aA     exec sql
750aA     select dddpid into :wkpid
750aA            from dddetail
750aA       where dddwhse = :iddwwhse
750aA         and dddrtid = :iddwrtid
750aA         and dddsnap = :iddwsnap
750aA         and dddid   = :iddwid;
750aA   endif;
750aA
        exec sql
          delete from ddwrkflds
          where ddwwhse = :iddwwhse
            and ddwrtid = :iddwrtid
            and ddwsnap = :iddwsnap
            and ddwid = :iddwid;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(iddwwhse) + '/' + %trim(iddwrtid)
                  + %char(iddwsnap) + '/' + %trim(iddwid)
                  + ' (' + sqlstt + ')';
750aA   else;
750aA     // when a Stop id was deleted we should look to see
750aA     // if any remaining stops have mixed pallets.  If not
750aA     // we should delete the pallet id mixed pallet flag
750aA     if %subst(iddwid:1:1)='s';
750aA       exec sql
750aA       select count(*) into :count
750aA              from dddetail as d, ddwrkflds as w
750aA         where w.ddwwhse = d.dddwhse and
750aA               w.ddwrtid = d.dddrtid and
750aA               w.ddwsnap = d.dddsnap and
750aA               w.ddwid   = d.dddid and
750aA               d.dddpid  = :wkpid and
750aA               d.dddsnap = :iddwsnap and
750aA               d.dddjson like '%imrg%';
750aA       if count = 0;
750aA         exec sql
750aA         delete from ddwrkflds
750aA          where ddwwhse = :iddwwhse
750aA            and ddwrtid = :iddwrtid
750aA            and ddwsnap = :iddwsnap
750aA            and ddwid = :wkpid;
750aA       endif;
750aA     endif;
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  DoGet   Get record
     *----------------------------------------------------------------

     p DoGet           b
     d DoGet           pi

      /free

        exec sql select ddwwhse, ddwrtid, ddwsnap, ddwid, ddwrow, ddwcol,
                        ddwmrg, ddwspin
                  into :ddwwhse, :ddwrtid, :ddwsnap, :ddwid, :ddwrow, :ddwcol,
                       :ddwmrg, :ddwspin
                 from ddwrkflds
                 where ddwwhse = :iddwwhse
                   and ddwrtid = :iddwrtid
                   and ddwsnap = :iddwsnap
                   and ddwid = :iddwid;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(iddwwhse) + '/' + %trim(iddwrtid)
                  + %char(iddwsnap) + '/' + %char(iddwid)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear ddrecw;
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
         clear ddrecw;
         ddwwhse = iddwwhse;
         ddwrtid = iddwrtid;
         ddwsnap = iddwsnap;
         ddwid   = iddwid;
         ddwrow  = iddwrow;
         ddwcol  = iddwcol;
         ddwmrg  = iddwmrg;
         ddwspin = iddwspin;
       else;
         iddwrow = ddwrow;
         iddwcol = ddwcol;
         iddwmrg = ddwmrg;
         iddwspin= ddwspin;
       endif;

      /end-free

     p                 e

