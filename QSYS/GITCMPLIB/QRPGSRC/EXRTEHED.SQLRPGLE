      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  EXRTEHED  RTEHEDEX file operations
     *  04 September 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720 A*   09/04/18  DAS  7.20
     *     - Created
740 A*   11/24/20  KDE  7.40 - Added for Coastal first
     *     - Added field RHARDYPP (Route ready for Pick/Print)
750 A*   09/15/21  KDE  7.50 - Added field to control whether route is
     *       used by auto transaction assignment
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
     d rharec        e ds                  extname(rtehedexa) inz(*EXTDFT)

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
     *  irhawhse  - Warehouse
     *  irhartid  - Route id
     *  i(fields) - All new fields should have options(*nopass)
     *
     *----------------------------------------------------------------

     d EXRTEHED        pr                  extpgm('EXRTEHED')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  irhawhse                            like(rhawhse)
     d  irhartid                            like(rhartid)
     d  irhatbtype                          like(rhatbtype) options(*nopass)
740 Ad  irhardypp                           like(rhArdypp) options(*nopass)
750 Ad  irhaasn                             like(rhaasn) options(*nopass)

     d EXRTEHED        pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  irhawhse                            like(rhawhse)
     d  irhartid                            like(rhartid)
     d  irhatbtype                          like(rhatbtype) options(*nopass)
740 Ad  irhardypp                           like(rhardypp) options(*nopass)
750 Ad  irhaasn                             like(rhaasn) options(*nopass)

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
          rtehedexa (rhawhse, rhartid, rhatbtype)
          values (:rhawhse, :rhartid, :rhatbtype);

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(rhawhse) + '/' + %trim(rhartid)
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
          update rtehedexa
          set rhatbtype = :rhatbtype
          where rhawhse = :rhawhse
            and rhartid = :rhartid;

740 A  // Only update ready for pick/print if sent
740 A  if parmsSent >= 7;
740 A   exec sql
740 A     update rtehedexa
740 A     set rhardypp = :rhardypp
740 A     where rhawhse = :rhawhse
740 A       and rhartid = :rhartid;
740 A  endif;

750 A  // Only update auto pick flag if sent
750 A  if parmsSent >= 8;
750 A   exec sql
750 A     update rtehedexa
750 A     set rhaasn = :rhaasn
750 A     where rhawhse = :rhawhse
750 A       and rhartid = :rhartid;
750 A  endif;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Update failed for '
                  + %char(rhawhse) + '/' + %trim(rhartid)
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
          delete from rtehedexa
          where rhawhse = :irhawhse
            and rhartid = :irhartid;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(irhawhse) + '/' + %trim(irhartid)
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

740 D   //exec sql select rhawhse, rhartid, rhatbtype
740 D   //          into :rhawhse, :rhartid, :rhatbtype
740 D   //exec sql select rhawhse, rhartid, rhatbtype, rhardypp
740 D   //          into :rhawhse, :rhartid, :rhatbtype, :rhardypp
750 M   exec sql select rhawhse, rhartid, rhatbtype, rhardypp, rhaasn
750 M             into :rhawhse, :rhartid, :rhatbtype, :rhardypp, :rhaasn
                 from rtehedexa
                 where rhawhse = :irhawhse
                   and rhartid = :irhartid;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(irhawhse) + '/' + %trim(irhartid)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear rharec;
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
         clear rharec;
         rhawhse = irhawhse;
         rhartid = irhartid;
       endif;

       if parmsSent >= 6;
         if direction = 'ParmsToRec';
           rhatbtype = irhatbtype;
         else;
           irhatbtype = rhatbtype;
         endif;
       endif;

740 A  if parmsSent >= 7;
740 A    if direction = 'ParmsToRec';
740 A      rhardypp = irhardypp;
740 A    else;
740 A      irhardypp = rhardypp;
740 A    endif;
       endif;

750 A  if parmsSent >= 8;
750 A    if direction = 'ParmsToRec';
750 A      rhaasn = irhaasn;
750 A    else;
750 A      irhaasn = rhaasn;
750 A    endif;
       endif;

      /end-free

     p                 e

