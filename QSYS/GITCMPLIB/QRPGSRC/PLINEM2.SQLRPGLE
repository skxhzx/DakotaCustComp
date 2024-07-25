      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PLINEM  Production MFG Line Definition
     *  02 June 2014
     *  Kenneth Elder
     *
     *  Revisions:
     *
     *    06/02/14  KDE  6.50
     *      - Created.
     *    11/10/16  KDE  7.00
     *      - Modify to put blanks in item for any SLOT adds
     *
710a *    01/24/17  LMC  7.10a
     *      - Modify to set slpick = 'Y' for Shipping aisle (prprd).
710b *    01/30/17  TAB  7.10b
     *      - Modify to check when updating that bas slots are still
    *        in SLOT file, if not add them back.
    *      - Also remove old slot records if Aisle(s) change
    *      - Add code to padd with spaces when less than three characters
710c *    02/09/17  KDE  7.10bc
     *      - Added field INDRYAGE to track whether line is Multi-Day
730a *    08/18/19  KDE  7.30a
     *      - Softcode location
     *      - Add ability to call directly from DRIPROD when DRISLOT
     *        returns stating no virtuals remain for specific slot location
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fslot2     uf a e           k disk
     Fslot11    uf   e           k disk
416bAF                                     rename(slrec:slrec11)
     Fwhdept    if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D plrec         E ds                  extname(plined) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s             10
     D  pWhse          s              3  0
	    d  prmfgno        s              3  0
	    d  prDesc         s             30
	    d  prRcv          s              3
	    d  prPrd          s              3
	    d  prPar          s              3
	    d  prWip          s              3
	    d  prStat         s              1
710 Ad  prDryA         s              1
730aAd  pLoc           s              3  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d ctr             s              1  0
     D logText         s            100
     d portOK          s               n
     d counter         s              5  0
     d wkdisp          s             12
     d wkitem          s             15
     d wkloc           s              3  0
     d wkaisl          s              3
     d bkrcvaisl       s              3
     d bkstkaisl       s              3
     d bkwipaisl       s              3
     d bkpckaisl       s              3
     D wherelabel      s            300

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
     D Up              C                   CONST('ABCDEFGHIJKLMNOPQRST+
     D                                     UVWXYZ')
     D Low             C                   CONST('abcdefghijklmnopqrst+
     D                                     uvwxyz')


     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pObjLoc     External object location
     *      pSubCmd     A=Add, U/C=Update, D=Delete
     *      pWhse       Warehouse
     *      Pline fields
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
     C                   parm                    pObjLoc
     C                   parm                    pSubCmd
     C                   parm                    pWhse
	    c                   parm                    prmfgno
	    c                   parm                    prDesc
	    c                   parm                    prRcv
	    c                   parm                    prPrd
	    c                   parm                    prPar
     c                   parm                    prWip
     c                   parm                    prStat
710 Ac                   parm                    prDryA
730aAc                   parm                    pLoc

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
           when pObjLoc = 'AFTERACT';
             exsr FldValid;
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

         error = *off;

         exsr FillRec;

         exec sql insert into plined values(:plrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Line(' + %trim(%char(prmfgno)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         // ensure that base slots are defined for manufacturing slots
            exsr slotadd;
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

         exsr GetRec;

710bA    // if new locations vary from old delete old
710bA    exec sql delete from slot
710bA             where slaisl = :bkrcvaisl
710bA               and slaisl <> :prRcv
710bA               and slrlvl = :prMfgno;
710bA   // if new locations vary from old delete old
710bA   exec sql delete from slot
710bA             where slaisl = :bkwipaisl
710bA               and slaisl <> :prWip
710bA               and slrlvl = :prMfgno;
710bA    // if new locations vary from old delete old
710bA    exec sql delete from slot
710bA             where slaisl = :bkstkaisl
710bA               and slaisl <> :prPar
710bA               and slrlvl = :prMfgno;
710bA   // if new locations vary from old delete old
710bA   exec sql delete from slot
710bA             where slaisl = :bkpckaisl
710bA               and slaisl <> :prPrd
710bA               and slrlvl = :prMfgno;

710bA     // if Dry Age is blank force 'N' for No
710bA    if prDryA <> 'Y';
710bA       prDrya='N';
710bA    endif;
710BA
         select;
730aA      when pSubCmd = '*ADDBASE';
730aA          exsr slotadd;
           when pSubCmd = 'A';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'U' or pSubCmd = 'C';
             if found;
               exsr UpdRec;
710bA          exsr slotadd;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'D';
             if found;
               exsr DelRec;
             endif;
           other;
             pMessage = 'Invalid command sent: ' + pSubCmd
                      + %trim(pSubCmd)
                      + ' (' + %trim(#pgm) +')';
         endsl;
       endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         // delete respective slot records if mfg line is being deleted
         ctr = 1;
730aA    if pLoc=0;
           wkloc = 101;
         else;
           wkLoc=pLoc;
730aA    endif;
         dow ctr < 5;
            select;
               when ctr = 1;
                  wkaisl = inrcvaisl;
               when ctr = 2;
                  wkaisl = instkaisl;
               when ctr = 3;
                  wkaisl = inwipaisl;
               when ctr = 4;
                  wkaisl = inpckaisl;
            endsl;
            // removed selected records
            setll (pwhse:wkaisl:wkloc:prmfgno) slot11;
            reade (pwhse:wkaisl:wkloc:prmfgno) slot11;
            dow not %eof(slot11);
               if slstat <> 'Z ' and slstat <> 'PR';
                  delete slrec11;
               endif;
               reade (pwhse:wkaisl:wkloc:prmfgno) slot11;
            enddo;
            ctr = ctr +1;
         enddo;

         exec sql delete from plined
                  where inlneno = :prmfgno
                    and inwhse = :pWhse;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Line(' + %trim(%char(prmfgno)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         // ensure that base slots are defined for manufacturing slots
            exsr slotupd;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

          // if deleting line slots will be deleted that are related to
          // this mafg line.  We must confirm slots have no quantities
          // and at proper status before we delete.
          // Make sure description is not blank
          if pSubCmd = 'D';
         // delete respective slot records if mfg line is being deleted
            ctr = 1;
730aA       if pLoc=0;
              wkloc = 101;
            else;
              wkLoc=pLoc;
730aA       endif;
            dow ctr < 5;
               select;
                  when ctr = 1;
                     wkaisl = inrcvaisl;
                  when ctr = 2;
                     wkaisl = instkaisl;
                  when ctr = 3;
                     wkaisl = inwipaisl;
                  when ctr = 4;
                     wkaisl = inpckaisl;
               endsl;
               // removed selected records
               setll (pwhse:wkaisl:wkloc:prmfgno) slot11;
               reade (pwhse:wkaisl:wkloc:prmfgno) slot11;
               dow not %eof(slot11);
                  if slstat = 'Z ' or slstat = 'PR';
                     pMessage = 'Slots must be at Z or PR status to delete';
                     error = *on;
                  endif;
                  if slstk1 <> 0 or slstk2 <> 0 or slstk3 <> 0
                     or slalc1 <> 0 or slalc2 <> 0 or slalc3 <> 0
                     or sltfr1 <> 0 or sltfr2 <> 0 or sltfr3 <> 0
                     or slpck1 <> 0 or slpck2 <> 0 or slpck3 <> 0
                     or slrcv1 <> 0 or slrcv2 <> 0 or slrcv3 <> 0;
                     pMessage = 'All qtys must be zero to delete slots';
                     error = *on;
                  endif;
                  reade (pwhse:wkaisl:wkloc:prmfgno) slot11;
               enddo;
               ctr = ctr +1;
             enddo;
          endif;
          if prdesc = ' ';
             pMessage = 'Description cannot be blank';
             error = *on;
          endif;

          // Mfg Line number must be present
          if prmfgno = 0;
             pMessage = 'MFG Line must be present';
             error = *on;
          endif;

          // receiving aisle must be populated
          if prrcv = '';
             pMessage = 'Receiving aisle must be populated';
             error = *on;
          endif;

          // Shipping aisle must be populated
          if prPrd = '';
             pMessage = 'Shipping aisle must be populated';
             error = *on;
          endif;

          // PAR Stock aisle must be populated
          if prpar = '';
             pMessage = 'PAR aisle must be populated';
             error = *on;
          endif;

          // WIP aisle must be populated
          if prwip = '';
             pMessage = 'WIP aisle location must be populated';
             error = *on;
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         // move in only the changable data.

	        inWhse = pWhse;
	        inlneno = prmfgno;
	        inDesc = prDesc;
	        inRcvaisl = prRcv;
	        inPckaisl = prPrd;
	        inStkaisl = prPar;
	        inWipaisl = prWip;
	        inStat = prStat;
710BA    inDRYAGE = prDRYa;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         if pSubCmd = 'D';
           leavesr;
         endif;

         if prmfgno > 99;
            pMessage = 'Mfg Line cannot exceed 99';
            return;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

        exec sql select * into :plrec
                  from plined
                  where inlneno = :prmfgno
                    and inwhse = :pWhse;

         if sqlstt = sqlSuccess;
           found = *on;
          // move in only the changable data.

          bkrcvaisl = inrcvaisl;
          bkpckaisl = inpckaisl;
          bkstkaisl = instkaisl;
          bkwipaisl = inwipaisl;

710bA     // padd any aisles passed in less than three characters
710bA     // to match how Dakota handles
710bA
710bA     // Receive Aisle
710bA     if %len(%trim(prRcv))<3;
710bA        select;
710bA           when %len(%trim(prRcv))=2;
710bA              prRcv = ' ' + %trim(prRcv);
710bA           when %len(%trim(prRcv))=1;
710bA              prRcv = '  ' + %trim(prRcv);
710bA           Other;
710bA              prRcv = %trim(prRcv);
710bA        endsl;
710bA     endif;
710bA     // PAR Aisle
710bA     if %len(%trim(prPar))<3;
710bA        select;
710bA           when %len(%trim(prPar))=2;
710bA              prPar = ' ' + %trim(prPar);
710bA           when %len(%trim(prPar))=1;
710bA              prPar = '  ' + %trim(prPar);
710bA           Other;
710bA              prPar = %trim(prPar);
710bA        endsl;
710bA     endif;
710bA     // Customer Orders
710bA     if %len(%trim(prPrd))<3;
710bA        select;
710bA           when %len(%trim(prPrd))=2;
710bA              prPrd = ' ' + %trim(prPrd);
710bA           when %len(%trim(prPrd))=1;
710bA              prPrd = '  ' + %trim(prPrd);
710bA           Other;
710bA              prPrd = %trim(prPRd);
710bA        endsl;
710bA     endif;
710bA     // WIP Aisle
710bA     if %len(%trim(prWip))<3;
710bA        select;
710bA           when %len(%trim(prWip))=2;
710bA              prWip = ' ' + %trim(prWip);
710bA           when %len(%trim(prRcv))=1;
710bA              prWip = '  ' + %trim(prWip);
710bA           Other;
710bA              prWip = %trim(prWip);
710bA        endsl;
710bA     endif;

         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  SlotUpd   Verify that Production Base slots are kept correct
     *----------------------------------------------------------------

      /free
       begsr SlotUpd;

          if pLoc=0;
             wkloc=101;
          else;
             wkLoc=pLoc;
          endif;

          // if line was found then remove any changed slots
          if Found;
             if bkrcvaisl <> prRcv;
730aD          //wkdisp = %trim(prrcv) + '-101-' + %trim(%editc(prmfgno:'Z'));
730aD          //   wkitem = %trim(prRcv) + '101';
730aA          wkdisp =%trim(prrcv) + '-' +
730aA                  %char(wkloc) + '-' + %trim(%editc(prmfgno:'Z'));
730aA             wkitem = %trim(prRcv) + %char(wkloc);
                  exec sql update slot
                  set slaisl = :prRcv,
                      sldisp = :wkdisp,
                      slitem = :wkitem
                  where slaisl = :bkrcvaisl
                    and slrlvl = :prmfgno
                    and slwhse = :pWhse;
             endif;
             if bkpckaisl <> prPrd;
730aD          //wkdisp = %trim(prPrd) + '-101-' + %trim(%editc(prmfgno:'Z'));
730aD          //  wkitem = %trim(prPrd) + '101';
730aA          wkdisp =%trim(prPrd) +  '-' +
730aA                  %char(wkloc) + '-' + %trim(%editc(prmfgno:'Z'));
730aA             wkitem = %trim(prPrd) + %char(wkloc);
                  exec sql update slot
                  set slaisl = :prPrd,
                      sldisp = :wkdisp,
                      slitem = :wkitem
                  where slaisl = :bkpckaisl
                    and slrlvl = :prmfgno
                    and slwhse = :pWhse;
             endif;
             if bkstkaisl <> prPar;
730aD          //wkdisp = %trim(prPar) + '-101-' + %trim(%editc(prmfgno:'Z'));
730aD          //   wkitem = %trim(prPar) + '101';
730aA          wkdisp =%trim(prPar) + '-' +
730aA                  %char(wkloc) + '-' + %trim(%editc(prmfgno:'Z'));
730aA             wkitem = %trim(prPar) + %char(wkloc);
                  exec sql update slot
                  set slaisl = :prPar,
                      sldisp = :wkdisp,
                      slitem = :wkitem
                  where slaisl = :bkstkaisl
                    and slrlvl = :prmfgno
                    and slwhse = :pWhse;
             endif;
             if bkwipaisl <> prwip;
730aD          //wkdisp = %trim(prWip) + '-101-' + %trim(%editc(prmfgno:'Z'));
730aD          //   wkitem = %trim(prWip) + '101';
730aA          wkdisp =%trim(prWip) + '-' +
730aA                  %char(wkloc) + '-' + %trim(%editc(prmfgno:'Z'));
730aA             wkitem = %trim(prWip) + %char(wkloc);
                  exec sql update slot
                  set slaisl = :prWip,
                      sldisp = :wkdisp,
                      slitem = :wkitem
                  where slaisl = :bkwipaisl
                    and slrlvl = :prmfgno
                    and slwhse = :pWhse;
             endif;
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  SlotAdd   Verify that Production Base slots are added
     *----------------------------------------------------------------

      /free
       begsr SlotAdd;

          if pLoc=0;
             wkloc=101;
          else;
             wkloc=pLoc;
          endif;

          // ensure that each MFG Line slot is added for each dept
          setll (pWhse:*loval) whdept;

          dow forever = forever;

             read whdept;
             if %eof(whdept);
                leave;
             endif;

             if wdwhse <> pWhse;
                iter;
             endif;

730aD        //wkdisp = %trim(prrcv) + '-101-' + %trim(%editc(prmfgno:'Z'));
730aA        wkdisp = %trim(prrcv) + '-' +
730aA                  %char(wkloc) + '-' + %trim(%editc(prmfgno:'Z'));
700aD       //   wkitem = %trim(prRcv) + '101';
700aA        wkitem = *blanks;
             chain (pWhse:wdcode:wkdisp) slot2;
             if not %found(slot2);
                // add base slot record for mfg line and department
                clear slrec;
                slwhse = pwhse;
                slwhdp = wdcode;
                sldisp = wkdisp;
                slaisl = prrcv;
                slitem = wkitem;
730aD           //slloc  = 101;
730aA           slloc = wkloc;
                slrlvl = prmfgno;
                slpick = 'N';
                slrsrv = 'N';
                slstat = 'A ';
                slstyp = 'F';
                write slrec;
             endif;

730aD        //wkdisp = %trim(prpar) + '-101-' + %trim(%editc(prmfgno:'Z'));
730aA        wkdisp = %trim(prpar) +  '-' +
730aA                  %char(wkloc) + '-' + %trim(%editc(prmfgno:'Z'));
700aD        // wkitem = %trim(prPar) + '101';
             chain (pWhse:wdcode:wkdisp) slot2;
             if not %found(slot2);
                // add base slot record for mfg line and department
                clear slrec;
                slwhse = pwhse;
                slwhdp = wdcode;
                sldisp = wkdisp;
                slitem = wkitem;
                slaisl = prpar;
730aD           //slloc  = 101;
730aA           slloc  = wkloc;
                slrlvl = prmfgno;
                slpick = 'N';
                slrsrv = 'N';
                slstat = 'A ';
                slstyp = 'F';
                write slrec;
             endif;

730aD        //wkdisp = %trim(prprd) + '-101-' + %trim(%editc(prmfgno:'Z'));
730aA        wkdisp = %trim(prprd) + '-' +
730aA                  %char(wkloc) + '-' + %trim(%editc(prmfgno:'Z'));
700aD        wkitem = %trim(prPrd) + '101';
             chain (pWhse:wdcode:wkdisp) slot2;
             if not %found(slot2);
                // add base slot record for mfg line and department
                clear slrec;
                slwhse = pwhse;
                slwhdp = wdcode;
                sldisp = wkdisp;
                slitem = wkitem;
                slaisl = prprd;
730aD           //slloc  = 101;
730aA           slloc  = wkloc;
                slrlvl = prmfgno;
710aD           //slpick = 'N';
710aM           slpick = 'Y';
                slrsrv = 'N';
                slstat = 'A ';
                slstyp = 'F';
                write slrec;
             endif;

730aD        //wkdisp = %trim(prwip) + '-101-' + %trim(%editc(prmfgno:'Z'));
730aA        wkdisp = %trim(prwip) + '-' +
730aA                  %char(wkloc) + '-' + %trim(%editc(prmfgno:'Z'));
700aD        wkitem = %trim(prWip) + '101';
             chain (pWhse:wdcode:wkdisp) slot2;
             if not %found(slot2);
                // add base slot record for mfg line and department
                clear slrec;
                slwhse = pwhse;
                slwhdp = wdcode;
                sldisp = wkdisp;
                slitem = wkitem;
                slaisl = prwip;
730aD           //slloc  = 101;
730aA           slloc  = wkloc;
                slrlvl = prmfgno;
                slpick = 'N';
                slrsrv = 'N';
                slstat = 'A ';
                slstyp = 'F';
                write slrec;
             endif;

          enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;
         prRcv = %XLATE(low:Up:prRcv);
         prPar = %XLATE(low:Up:prPar);
         prWip = %XLATE(low:Up:prWip);
         prPrd = %XLATE(low:Up:prPrd);
710bA
         exsr FillRec;

         exec sql update plined
                  set indesc = :prdesc, inrcvaisl = :prRcv,
                      inpckaisl = :prPrd, instkaisl = :prPar,
                      inwipaisl = :prWip, inStat = :prStat,
710 A                 indryage = :prDryA
                  where inlneno = :prmfgno
                    and inwhse = :pWhse;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Line(' + %trim(%char(prmfgno)) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         // ensure that base slots are defined for manufacturing slots
            exsr slotupd;
         endif;

       endsr;
      /end-free
