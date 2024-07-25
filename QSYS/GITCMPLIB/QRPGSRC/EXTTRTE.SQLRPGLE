      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  EXTTRTE   TTRTEEX file operations
     *  26 September 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720 A*   09/26/18  DAS  7.20
     *     - Created
     *
740aA*   04/16/20  RBD  7.40a
     *     - Added: TRAPSS   PALLETSCAN scanned count
     *              TRAPSC   PALLETSCAN clicked count
     *              TRAPAL   Total pallet count
     *              TRAISS   INSTORESCAN scanned count
     *              TRAISC   INSTORESCAN clicked count
     *              TRAIST   INSTORESCAN total count
     *              TRARETSH Return code short count
     *              TRARET   Total qty items returned
     *
740bA*   12/11/20  RBD  7.40b
     *     - Fix: Enlarged size of iRtnMsg from 60 to 120 because
     *       #pgmmsg, which is 80 long, was being returned as part
     *       of the msg in *PSSR and caused it to blow up.
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
     d trarec        e ds                  extname(ttrteexa) inz(*EXTDFT)

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
740aA*  itrapss   - PALLETSCAN scanned count
740aA*  itrapsc   - PALLETSCAN clicked count
740aA*  itrapal   - Total pallet count
740aA*  itraiss   - INSTORESCAN scanned count
740aA*  itraisc   - INSTORESCAN clicked count
740aA*  itraist   - INSTORESCAN total count
740aA*  itraretsh - Return code short count
740aA*  itraret   - Total qty items returned
     *  i(fields) - All new fields should have options(*nopass)
     *  s(fields) - Corresponding sent flags.
     *
     *----------------------------------------------------------------

     d EXTTRTE         pr                  extpgm('EXTTRTE')
     d  iCmd                         10    const
     d  iRtnCode                     10
740bDd* iRtnMsg                      60
740bMd  iRtnMsg                     120
     d  itrawhse                            like(trawhse)
     d  itrartid                            like(trartid)
     d  itradspid                           like(tradspid) options(*nopass)
     d  stradspid                      n    const options(*nopass)
     d  itrasnum                            like(trasnum) options(*nopass)
     d  strasnum                       n    const options(*nopass)
     d  itranetid                           like(tranetid) options(*nopass)
     d  stranetid                      n    const options(*nopass)
     d  itrablueid                          like(trablueid) options(*nopass)
     d  strablueid                     n    const options(*nopass)
     d  itrasimid                           like(trasimid) options(*nopass)
     d  strasimid                      n    const options(*nopass)
     d  itraphone                           like(traphone) options(*nopass)
     d  straphone                      n    const options(*nopass)
     d  itraappver                          like(traappver) options(*nopass)
     d  straappver                     n    const options(*nopass)
740aAd  itrapss                             like(trapss) options(*nopass)
740aAd  strapss                        n    const options(*nopass)
740aAd  itrapsc                             like(trapsc) options(*nopass)
740aAd  strapsc                        n    const options(*nopass)
740aAd  itrapal                             like(trapal) options(*nopass)
740aAd  strapal                        n    const options(*nopass)
740aAd  itraiss                             like(traiss) options(*nopass)
740aAd  straiss                        n    const options(*nopass)
740aAd  itraisc                             like(traisc) options(*nopass)
740aAd  straisc                        n    const options(*nopass)
740aAd  itraist                             like(traist) options(*nopass)
740aAd  straist                        n    const options(*nopass)
740aAd  itraretsh                           like(traretsh) options(*nopass)
740aAd  straretsh                      n    const options(*nopass)
740aAd  itraret                             like(traret) options(*nopass)
740aAd  straret                        n    const options(*nopass)

     d EXTTRTE         pi
     d  iCmd                         10    const
     d  iRtnCode                     10
740bDd* iRtnMsg                      60
740bMd  iRtnMsg                     120
     d  itrawhse                            like(trawhse)
     d  itrartid                            like(trartid)
     d  itradspid                           like(tradspid) options(*nopass)
     d  stradspid                      n    const options(*nopass)
     d  itrasnum                            like(trasnum) options(*nopass)
     d  strasnum                       n    const options(*nopass)
     d  itranetid                           like(tranetid) options(*nopass)
     d  stranetid                      n    const options(*nopass)
     d  itrablueid                          like(trablueid) options(*nopass)
     d  strablueid                     n    const options(*nopass)
     d  itrasimid                           like(trasimid) options(*nopass)
     d  strasimid                      n    const options(*nopass)
     d  itraphone                           like(traphone) options(*nopass)
     d  straphone                      n    const options(*nopass)
     d  itraappver                          like(traappver) options(*nopass)
     d  straappver                     n    const options(*nopass)
740aAd  itrapss                             like(trapss) options(*nopass)
740aAd  strapss                        n    const options(*nopass)
740aAd  itrapsc                             like(trapsc) options(*nopass)
740aAd  strapsc                        n    const options(*nopass)
740aAd  itrapal                             like(trapal) options(*nopass)
740aAd  strapal                        n    const options(*nopass)
740aAd  itraiss                             like(traiss) options(*nopass)
740aAd  straiss                        n    const options(*nopass)
740aAd  itraisc                             like(traisc) options(*nopass)
740aAd  straisc                        n    const options(*nopass)
740aAd  itraist                             like(traist) options(*nopass)
740aAd  straist                        n    const options(*nopass)
740aAd  itraretsh                           like(traretsh) options(*nopass)
740aAd  straretsh                      n    const options(*nopass)
740aAd  itraret                             like(traret) options(*nopass)
740aAd  straret                        n    const options(*nopass)

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
          ttrteexa (trawhse, trartid, tradspid, trasnum, tranetid,
740aM               trablueid, trasimid, traphone, traappver,
740aA               trapss, trapsc, trapal, traiss, traisc, traist,
740aA               traretsh, traret)
          values (:trawhse, :trartid, :tradspid, :trasnum, :tranetid,
740aM             :trablueid, :trasimid, :traphone, :traappver,
740aA             :trapss, :trapsc, :trapal, :traiss, :traisc, :traist,
740aA             :traretsh, :traret);

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(trawhse) + '/' + %trim(trartid)
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
          update ttrteexa
          set tradspid = :tradspid, trasnum = :trasnum, tranetid = :tranetid,
              trablueid = :trablueid, trasimid = :trasimid,
740aM         traphone = :traphone, traappver = :traappver,
740aA         trapss = :trapss, trapsc = :trapsc,
740aA         trapal = :trapal, traiss = :traiss,
740aA         traisc = :traisc, traist = :traist,
740aA         traretsh = :traretsh, traret = :traret
          where trawhse = :trawhse
            and trartid = :trartid;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Update failed for '
                  + %char(trawhse) + '/' + %trim(trartid)
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
          delete from ttrteexa
          where trawhse = :itrawhse
            and trartid = :itrartid;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(itrawhse) + '/' + %trim(itrartid)
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

        exec sql select trawhse, trartid, tradspid, trasnum, tranetid,
740aM                   trablueid, trasimid, traphone, traappver,
740aA                   trapss, trapsc, trapal, traiss,
740aA                   traisc, traist, traretsh, traret
                  into :trawhse, :trartid, :tradspid, :trasnum, :tranetid,
740aM                  :trablueid, :trasimid, :traphone, :traappver,
740aA                  :trapss, :trapsc, :trapal, :traiss,
740aA                  :traisc, :traist, :traretsh, :traret
                 from ttrteexa
                 where trawhse = :itrawhse
                   and trartid = :itrartid;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(itrawhse) + '/' + %trim(itrartid)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear trarec;
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
         clear trarec;
         trawhse = itrawhse;
         trartid = itrartid;
       endif;

       if parmsSent >= 7;
         if direction = 'ParmsToRec' and stradspid;
           tradspid = itradspid;
         else;
           itradspid = tradspid;
         endif;
       endif;

       if parmsSent >= 9;
         if direction = 'ParmsToRec' and strasnum;
           trasnum = itrasnum;
         else;
           itrasnum = trasnum;
         endif;
       endif;

       if parmsSent >= 11;
         if direction = 'ParmsToRec' and stranetid;
           tranetid = itranetid;
         else;
           itranetid = tranetid;
         endif;
       endif;

       if parmsSent >= 13;
         if direction = 'ParmsToRec' and strablueid;
           trablueid = itrablueid;
         else;
           itrablueid = trablueid;
         endif;
       endif;

       if parmsSent >= 15;
         if direction = 'ParmsToRec' and strasimid;
           trasimid = itrasimid;
         else;
           itrasimid = trasimid;
         endif;
       endif;

       if parmsSent >= 17;
         if direction = 'ParmsToRec' and straphone;
           traphone = itraphone;
         else;
           itraphone = traphone;
         endif;
       endif;

       if parmsSent >= 19;
         if direction = 'ParmsToRec' and straappver;
           traappver = itraappver;
         else;
           itraappver = traappver;
         endif;
       endif;

740aA  if parmsSent >= 21;
740aA    if direction = 'ParmsToRec' and strapss;
740aA      trapss = itrapss;
740aA    else;
740aA      itrapss = trapss;
740aA    endif;
740aA  endif;

740aA  if parmsSent >= 23;
740aA    if direction = 'ParmsToRec' and strapsc;
740aA      trapsc = itrapsc;
740aA    else;
740aA      itrapsc = trapsc;
740aA    endif;
740aA  endif;

740aA  if parmsSent >= 25;
740aA    if direction = 'ParmsToRec' and strapal;
740aA      trapal = itrapal;
740aA    else;
740aA      itrapal = trapal;
740aA    endif;
740aA  endif;

740aA  if parmsSent >= 27;
740aA    if direction = 'ParmsToRec' and straiss;
740aA      traiss = itraiss;
740aA    else;
740aA      itraiss = traiss;
740aA    endif;
740aA  endif;

740aA  if parmsSent >= 29;
740aA    if direction = 'ParmsToRec' and straisc;
740aA      traisc = itraisc;
740aA    else;
740aA      itraisc = traisc;
740aA    endif;
740aA  endif;

740aA  if parmsSent >= 31;
740aA    if direction = 'ParmsToRec' and straist;
740aA      traist = itraist;
740aA    else;
740aA      itraist = traist;
740aA    endif;
740aA  endif;

740aA  if parmsSent >= 33;
740aA    if direction = 'ParmsToRec' and straretsh;
740aA      traretsh = itraretsh;
740aA    else;
740aA      itraretsh = traretsh;
740aA    endif;
740aA  endif;

740aA  if parmsSent >= 35;
740aA    if direction = 'ParmsToRec' and straret;
740aA      traret = itraret;
740aA    else;
740aA      itraret = traret;
740aA    endif;
740aA  endif;

      /end-free

     p                 e

