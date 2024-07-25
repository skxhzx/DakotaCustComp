      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M16900  Production Date Maintenance
     *  02 Mar 2015
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    03/02/15  KDE  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fplined    if   e           k disk    rename(plrec:plrec1)
     Fitemprd   if   e           k disk
     fpremwgt   uf a e           k disk
     Fslot11    if   e           k disk
     fprodlog   uf a e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D pdrec         E ds                  extname(prddate) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s              1
     D  pWhse          s              3  0
	    d  pLine          s              3  0
     D  pprdDate       s              8  0

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d error           s               n
     d errmsg          s             50
650aAD logText         s            100
     d opnCount        s              5  0
     D saveVer#        s                   like($slver#)
     d wkError         s               n
     d wkRerr2         s             50

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pWhse       Warehouse
     *      PLine       Mfg Line
     *      PprdDate    Production Date
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     c                   parm                    pObjLoc
     c                   parm                    pSubCmd
     C                   parm                    pWhse
	    c                   parm                    pLine
	    c                   parm                    pprdDate

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

         // Write GLOSESSLOG record
         logText = 'objloc:' + pObjLoc;
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         select;
           when pObjLoc = 'FLDVALID';
             exsr FldValid;
           when pObjLoc = 'AFTERACT';
             exsr AfterAct;
           other;
             pMessage = 'Invalid object location sent: '
                      + %trim(pObjLoc)
                      + ' (' + %trim(#pgm) +')';
         endsl;

         return;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         // Edits have passed and we will now add a record for a specific
         // Mfg Line for a specific Production Date

         pdwhse = pWhse;
         pdLine = pLine;
         pddate = pprdDate;
         pdStat = 'O';

         exec sql insert into prdDate values(:pdrec);

         if sqlstt <> sqlSuccess;
           exec sql update prdDate set pdstat='O'
               where pddate = :pprdDate;
           if sqlStt <> sqlSuccess;
           pMessage = 'Error adding/updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Line(' + %trim(%char(pLine)) + ') '
                    + 'Date(' + %trim(%char(pprdDate)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
           endif;
         else;
            exsr crtBinvLog;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;

       error = *off;
       exsr errorCheck;
       if not error;
         exsr AddRec;
       endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  crtBinvLog  Create Beginning Inventory Log entries when
     *              Production date opened for Mfg Line
     *----------------------------------------------------------------

      /free
       begsr crtBinvLog;

             // change status for production priority replenishments
             // so warehouse can replenish now that we have opened
             // a new production date for this mfg line
             exec sql
                  update prplfil
                   set prflag = 'S'
                   where prwhse = :pWhse
                     and prtlvl = :pLine
                     and prtail = 'LIN'
                     and prflag = '*';

          // loop through Slot file at the time Production is opened.
          // Create a beginning inventory balance record in the
          // Production Log for any LIN (Raw Material Line) Inventories
          // or WIP (Work in Process Line) Inventories for that
          // selected Mfg Line.

          chain (pWhse:pLine) plined;
          if %found(plined);
             // loop slot looking for Mfg Line inventory
             setll (pWhse:inRcvAisl) slot11;
             reade (pWhse:inRcvAisl) slot11;
             dow %equal(slot11) and not %eof(slot11);
                if slhand<>' ' and (slstk1<>0 or slstk2<>0 or slstk3<>0)
                   and slstat='PR';
                   exsr wrtProdLog;   // generate beginning inv log record
                endif;
                reade (pWhse:inRcvAisl) slot11;
             enddo;

             // loop slot looking for Mfg Wip inventory
             setll (pWhse:inWipAisl) slot11;
             reade (pWhse:inWipAisl) slot11;
             dow %equal(slot11) and not %eof(slot11);
                if slhand<>' ' and (slstk1<>0 or slstk2<>0 or slstk3<>0)
                   and slstat='PR';
                   exsr wrtProdLog;   // generate beginning inv log record
                endif;
                reade (pWhse:inWipAisl) slot11;
             enddo;

          else;
             // this should not happen, but just in case
             pMessage = 'Mfg Line invalid';
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

          // make sure date passed is not more than one day out
          // and no more than 1 day short of current date
          if pprdDate > %Dec(%Date() + %Days(1): *iso);
             error = *on;
             pMessage = 'The date cannot be greater than tomorrow';
          endif;

          // yesterday
          if pprdDate < %Dec(%Date() - %Days(1): *iso);
             error = *on;
             pMessage = 'The date cannot be less than yesterday';
          endif;

          // Make sure Mfg Line has no current open record
          opnCount = 0;
          exec sql
           select count(*)
            into :opncount
             from prdDate
              where pdwhse = :pwhse and pdline = :pLine
                    and pdstat = 'O';

          if opnCount <> 0;
             error = *on;
             pMessage = 'You can have only 1 open date per Mfg Line.';
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         exsr errorcheck;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtProdLog   Write Beginning Inventory Production Log Entry
     *----------------------------------------------------------------

      /free
       begsr WrtProdLog;

          // have SQL delete record if one already exist for this
          // mfg line, item, slot, and production date and warehouse
          exec sql delete from ProdLog
               where plwhse = :pWhse and plitem = :slitem
                 and plline = :slrlvl and plaction = 'BIV'
                 and pldisp = :sldisp and plprddte = :pprddate;

650qA    // create Production Log entry
650qA
650qA    plwhse = slwhse;
650qA    plitem = slitem;
650qA    plfgitm = ' ';
650qA
650qA    plaction = 'BIV';
         // call DRISLOT to get license for slot
         savever# = $slver#;
         clear $slot;
         clear $slot2;
         $slver# = savever#;

      // Move fields to slot data structure for quantity adjustment

         $slwhseu = *on;
         $slwhse  = slwhse;

         $slwhdpu = *on;
         $slwhdp = slwhdp;
         $sldispu = *on;
         $sldisp = sldisp;
         $saOLcnsu = *on;

650gA    $dricommand = '*SLOT';
650gA    $drisubcmd  = '%GET';
650gA    $drisys2upd = 'D';
         exsr zzDriCop2;

         if wkError;
            plFlcns = ' ';
            plTlcns = ' ';
         else;
650qA       plFLCNs = $saOlcns;
650qA       plTlcns = $saTolcns;
         endif;
650qA
650qA    plline = slrlvl;
650qA
650qA    plprdDte = pprdDate;
650qA
650qA    pldisp = sldisp;
650qA
650qA    plgs1 = '';
650qA
650qA    plqtyn = slstk1;
650qA    plqty1 = slstk2;
650qA    plqty2 = slstk3;
650qA
         // if end of day weight was written for mfg line and item
         // and display slot then pickup and write to Beginning
         // Inventory record in Production Log and then delete
         // the previous ending balance record
         chain (pwhse:slrlvl:slitem:sldisp) pRemWgt;
         if %found(pRemWgt);
            plweght = rwremwgt;
            delete rwrec;
         else;
650qA       plweght = 0;
            unlock premwgt;
         endif;
650qA
650qA    plbfcwo = ' ';   // BFC work order number.
650qA
650qA    pltare = 0;
650qA
650qA    plpgm = #pgm;
650qA    pluser = #user;
650qA    pljob = #job;
650qA
650qA    pllsts = ' ';
650qA
650qA    plCUSTWO = ' ';
650qA
650qA    pltrn# = 0;
650qA
650qA    pllbl# = 0;
650qA
650qA    plcts = %timestamp();
650qA    pldtetim = %subst(%char(plcts):1:4) +
650qA               %subst(%char(plcts):6:2) +
650qA               %subst(%char(plcts):9:2) +
650qA               %subst(%char(plcts):12:2) +
650qA               %subst(%char(plcts):15:2) +
650qA               %subst(%char(plcts):18:2);
650qA    write plrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzdricop2  Call DRICOP2
     *----------------------------------------------------------------

     c     zzDriCop2     begsr
     *
     c                   eval      wkError = *off
     *
     c                   select
     *
     c                   when      $dricommand = '*SLOT'
     c                   eval      $dridata = $slot
     c                   eval      $dridata2 = $slot2

     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*SLOT'
     c                   call(e)   'DRICOP2'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP2'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      errmsg    = 'Error occured on call to '
     c                                       + 'DRICOP2'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*SLOT'
     c                   eval      $slot = $dridata
     c                   eval      $slot2 = $dridata2
     c                   endsl

     c                   endsr
