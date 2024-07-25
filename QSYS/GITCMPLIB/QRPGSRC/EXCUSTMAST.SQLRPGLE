      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  EXCUSTMAST  CUSTMASTX file operations
     *  19 October 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720 A*   10/19/18  DAS  7.20
     *     - Created
     *
720aA*   11/23/18  DAS  7.20a
     *     - Added Audit Exp Date field, cmaaudexpd.
     *
740 A*   05/05/20  KDE  7.40
     *     - Added Single Pallet Flag
     *
740aA*   05/22/20  KDE  7.40a
     *     - Added Customer Audit Reason
     *
740bA*   05/28/20  KDE  7.40b
     *     - Added code to automatically setup new Customer Audit if Duration value
     *       set
     *     - Changed delete to only mark with No audit and zero expiration date
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
     d cmarec        e ds                  extname(custmastxa) inz(*EXTDFT)
     d oprec         e ds                  extname(options) inz(*EXTDFT)

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
740bAd newAudDte       s              8  0
740bAd opcad           s              2  0

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
     *  icmawhse  - Warehouse
     *  icmacust  - Customer number
     *  icmaaudflgt - Audit flag
     *  i(fields) - All new fields should have options(*nopass)
     *
     *----------------------------------------------------------------

     d EXCUSTMAST      pr                  extpgm('EXCUSTMAST')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  icmawhse                            like(cmawhse)
     d  icmacust                            like(cmacust)
     d  icmaaudflg                          like(cmaaudflg) options(*nopass)
720aAd  icmaaudexpd                         like(cmaaudexpd) options(*nopass)
740 Ad  icmspflg                            like(cmspflg) options(*nopass)
740aAd  icmaudr                             like(cmaudr) options(*nopass)

     d EXCUSTMAST      pi
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  icmawhse                            like(cmawhse)
     d  icmacust                            like(cmacust)
     d  icmaaudflg                          like(cmaaudflg) options(*nopass)
720aAd  icmaaudexpd                         like(cmaaudexpd) options(*nopass)
740 Ad  icmspflg                            like(cmspflg) options(*nopass)
740aAd  icmaudr                             like(cmaudr) options(*nopass)

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
740 D     //custmastxa (cmawhse, cmacust, cmaaudflg, cmaaudexpd)
740 M     custmastxa (cmawhse, cmacust, cmaaudflg, cmaaudexpd, cmspflg,
740aA                 cmaudr)
740 D     //values (:cmawhse, :cmacust, :cmaaudflg, :cmaaudexpd);
740 M     values (:cmawhse, :cmacust, :cmaaudflg, :cmaaudexpd, :cmspflg,
740aA             :cmaudr);

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Add failed for '
                  + %char(cmawhse) + '/' + %char(cmacust)
                  + ' (' + sqlstt + ')';
740b    else;
740b      // for successful add we need to setup Customer Audit if setup
740b      exec sql select * into :oprec
740b                from options
740b            where opwhse=:cmawhse and opcode='*GENPICK';
740b      if sqlstt <> '00000';
740b        opcad=0;
740b      endif;
740b      // ensure value setup with number
740b      monitor;
740b        opcad = %dec(%subst(opdata:39:2):2:0);
740b      on-error;
740b        opcad=0;
740b      endmon;
740b      // if Audit Duration > 0 setup automatic audit
740b      if opcad>0;
740b        newAudDte = %uns(%char(%date() + %days(opcad):*Iso0));
740b        exec sql update custmastxa
740b                set cmaaudflg='Y', cmaaudexpd=:newAudDte,
740b                    cmaudr = 'Automated Audit for new Customer'
740b              where cmawhse=:cmawhse and cmacust=:cmacust
740b                and cmaaudexpd=0;
740b        icmaaudflg='Y';
740b        icmaaudexpd=newAudDte;
740b      endif;
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
          update custmastxa
720aM     set cmaaudflg = :cmaaudflg,
720aA         cmaaudexpd = :cmaaudexpd,
740 A         cmspflg = :cmspflg,
740aA         cmaudr = :cmaudr
          where cmawhse = :cmawhse
            and cmacust = :cmacust;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Update failed for '
                  + %char(cmawhse) + '/' + %char(cmacust)
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

740bD   //exec sql
740bD   //  delete from custmastxa
740bD   //  where cmawhse = :icmawhse
740bD   //    and cmacust = :icmacust;
740bA   // Delete is simply marking CUSTMASTXA as no longer being audited
740bA   cmaaudflg = 'N';
740bA   cmaaudexpd = 0;
740bA   cmaudr=*blanks;

740bA   doChange();

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Delete failed for '
                  + %char(icmawhse) + '/' + %char(icmacust)
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

740 D   //exec sql select cmawhse, cmacust, cmaaudflg, cmaaudexpd
740 D   //          into :cmawhse, :cmacust, :cmaaudflg, :cmaaudexpd
740 M   exec sql select cmawhse, cmacust, cmaaudflg, cmaaudexpd, cmspflg,
740aA                   cmaudr
740 M             into :cmawhse, :cmacust, :cmaaudflg, :cmaaudexpd, :cmspflg,
740aA                  :cmaudr
                 from custmastxa
                 where cmawhse = :icmawhse
                   and cmacust = :icmacust;

        if sqlstt <> sqlSuccess;
          iRtnCode = '*ERROR';
          iRtnMsg = 'Record for '
                  + %char(icmawhse) + '/' + %char(icmacust)
                  + ' not found'
                  + ' (' + sqlstt + ')';
          clear cmarec;
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
         clear cmarec;
         cmawhse = icmawhse;
         cmacust = icmacust;
       endif;

       if parmsSent >= 6;
         if direction = 'ParmsToRec';
           cmaaudflg = icmaaudflg;
720aA      cmaaudexpd = icmaaudexpd;
         else;
           icmaaudflg = cmaaudflg;
720aA      icmaaudexpd = cmaaudexpd;
         endif;
       endif;

740 A  if parmsSent >= 8;
740 A    if direction = 'ParmsToRec';
740 A      cmspflg = icmspflg;
740 A    else;
740 A      icmspflg = cmspflg;
740 A    endif;
740 A  endif;

740aA  if parmsSent >= 9;
740aA    if direction = 'ParmsToRec';
740aA      cmaudr = icmaudr;
740aA    else;
740aA      icmaudr = cmaudr;
740aA    endif;
740aA  endif;

      /end-free

     p                 e

