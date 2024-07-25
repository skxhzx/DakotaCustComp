      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M01500F  Perform checks and then the update from Allocate Build
     *           to Pick/Print while on DD2 screen.
     *  14 February 2020
     *  Kenneth Elder
     *
     *  Revisions:
     *
740 A*    02/14/20  KDE  7.40
     *      - Created.
     *
740aA*    11/30/20  KDE  7.40a
     *      - Update flag to indicate ready Pick/Print
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     frtehed    if   e           k disk
     Fordh4     if   e           k disk    rename(ohrec:ohrec4)
     Fordh10    if   e           k disk    prefix(oh_)
     Foptions   if   e           k disk
     Fdocmtrx2  if   e           k disk
     Frtecsum1  if   e           k disk
     Fpltsum1   if   e           k disk
740aAfddopts    if   e           k disk
510
416dA*----------------------------------------------------------------
416dA*  *DOCDOOR -  Dock Door options
416dA*----------------------------------------------------------------
416dA*
416dA* Fields
416dA*
417 M*    OPATYP  -  Dock door assignment. 0=No assigment,1=Auto,2=Manual.
416dA*    OPLTYP  -  Dock door loading. 1=Single door, 2=By Department.
416dA*
416dA* Data structure
416dA*
416dAD opdata          ds
416dAD  opatyp                 1      1
416dAD  opltyp                 2      2

510  *----------------------------------------------------------------
510  *  Customer id
510  *----------------------------------------------------------------
510
USFA  /copy qcopysrc,id#usfcorp

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pCmd           s              8    varying
     D  pWhse          s              3p 0
     D  cWhse          s              3
     D  pRtid          s              5    varying
     D  pSessId        s             40    varying
     D  pDict          s             10    varying
     D  pPgm           s             10    varying
     D  pUser          s             10    varying
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

740aDd*forever         s               n
     d dpCombo         s             20
     d cmd             s              8
     d rtid            s              5
     d sessid          s             40
     d pmessage        s             80
     d user            s             10

     d irtn            s              8
     D isPrePick       s               n
     d iutext10        s             10
     d iutext30        s             30
     d iucmd           s              8
     d iupgm           s             20
     d iuuser          s             10
     d iuSessId        s             40
     d iuJobName       s             10
     d iuJobNbr        s              6
     d iuJobUser       s             10
     d iuStamp         s             26

     D dbgflgExists    s               n
     D debug           s               n

     D allowPckPrt     s              1  0
     D allowStage      s              1  0
     D allowText       s             80
     D allowTextStg    s             80
     D allowUndo       s               n
     D client          s             10
     D clientloc       s             10
     D hasPrePick      s               n
     D missingDoor     s               n
     D door            s            300
     D lastDept        s                   like(rcdrdp)
     D openPrePick     s               n
     d prte            s              5
     D shipNbr         s             11
     d tbEnhanced      s               n
     d tbPalletType    s              1
     d tbType          s              1
     d tbWhse          s              3  0
     D zzzzzzExists    s               n
740aAD TBProcess       s              1
740aAD TBRdyPP         s              1
740aAd prtflg          s              1

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.chkiuse2
740aAd/copy qcopysrc,p.exrtehed

     D rteprint        pr                  extpgm('RTEPRINT')
     D  iuMessage                    80
     d  iuSessId                     40
     d  iuUser                       10
     d  iuPgm                        20
     d  iuWhse                        3
     d  iuRtid                        5
     d  iuRte                         5

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pCmd        CHKIUSE2 command
     *      pWhse       Warehouse
     *      pRtid       Route id
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pCmd
     c                   parm                    pWhse
     c                   parm                    pRtid
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pDict
     c                   parm                    pPgm
     c                   parm                    pOutStr

      /free

        *inlr = *on;
        exsr zzinz;

         if dbgflgExists;
           chain(e) (#pgm) bfcdbgflg;
           if %found(bfcdbgflg);
             debug = (bdfflag = 1);
           else;
             debug = *off;
           endif;
         endif;

        if debug;
          exsr wrtDebugParms;
        endif;

        select;
          when pcmd='*PP';
            exsr GetPrePick;
            exsr ChkDockDoors;
            exsr ChkZZZZZZ;

            select;
              when rhstat<>'3';
                allowPckPrt = 0;
                allowText = 'Pick & Print not allowed - '
                          + 'Status must be 3.';
              when zzzzzzExists;
                allowPckPrt = 0;
                allowText = 'Pick & Print not allowed - '
                      + 'ZZZZZZ Zone exists.';
              when missingDoor;
                allowPckPrt = 0;
                allowText = 'Pick & Print not allowed - '
                          + 'Door Not Assigned.';
              when openPrePick;
                allowPckPrt = 0;
                allowText = 'Pick & Print not allowed - '
                          + 'PrePick Route ('
                          + %trim(oh_rhrte) + '/' + %trim(oh_rhrtid)
                          + ') not Printed.';
              other;
                allowPckPrt = 1;
                allowText = 'Pick & Print';

                // Good to advance to Pick and Print

                // First clear route status
                cmd = '*CLEARDD';
                rtid = pRtid;
                sessid = pSessid;
                user = pUser;
                dpCombo = %trim(pDict) + '.' + pPgm;

                chkiuse2 (cmd: pWhse: rtid:
                          dpCombo: user: sessId: irtn:
                          iuText10: iuText30: iuCmd: iuPgm:
                          iuUser: iuSessId: iuJobName: iuJobNbr:
                          iuJobUser: iuStamp);

                // Next call RTEPRINT.  This will Pick/Print and move along
                pmessage=*blanks;
                rteprint(pMessage: sessId: user: dpcombo:
                         cWhse: Rtid: pRte);
            endsl;
          when pcmd='*STS';
            if rhstat<>'3';
              allowpckprt=0;
            else;
              allowpckprt=1;
            endif;
            iuText10=*blanks;
            allowText=*blanks;
740aA     when pcmd='*PRTFLG';
740aA       // called form M015xx
740aA       chain ('BFC_DISPLAY_PRINTER') ddopts;
740aA       if %found(ddopts);
740aA         if %trim(dovalue)='ON';
740aA           prtflg='Y';
740aA         else;
740aA           prtflg='N';
740aA         endif;
740aA       else;
740aA         prtflg='N';
740aA       endif;
740aA     when pcmd='*RDYPPY' or pcmd='*RDYPPN';
740aA       rtid = prtid;
740aA       // Update flag to show whether Route is ready for Pick/Print
740aA       monitor;
740aA       exWhse = pWhse;
740aA       EXRTEHED('*GET': exRtnCode: exRtnMsg:
740aA                exWhse: RtId: TBProcess: TBRdyPP);
740aA       if exRtnCode <> '*ERROR';
740aA         TBRdyPP = %subst(pCmd:7:1);
740aA         EXRTEHED('*CHANGE': exRtnCode: exRtnMsg:
740aA                  exWhse: RtId: TBProcess: TBRdyPP);
740aA       else;
740aA         TBProcess = ' ';
740aA         EXRTEHED('*ADD': exRtnCode: exRtnMsg:
740aA                  exWhse: RtId: TBProcess: TBRdyPP);
740aA       endif;
740aA   on-error;
740aA   endmon;
        endsl;

         // Build JSON string to return

         // if pMessage has a value that means the Pick/Print failed for some reason
         // We will turn off the allowpckprt and return the error message to user
         if pMessage<>*blanks;
           allowpckprt=0;
           allowText = %trim(pMessage);
         endif;

         pOutStr = '{'
                 +  '"alwpick":"' + %char(allowpckprt) + '",'
                 +  '"prtflg":"' + %trimr(prtflg) + '",'
                 +  '"itxt10":"' + %trimr(iuText10) + '",'
                 +  '"itxt30":"' + %trimr(allowText) + '"}';

        return;
        if debug;
          exsr wrtDebugParms;
        endif;

        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;
         chain (pWhse:pRtid) rtehed;
         if not %found(rtehed);
           rhstat=' ';
           rhstat=' ';
         else;
           prte=rhrte;
         endif;
         monitor;
           cwhse=%editc(pWhse:'X');
         on-error;
           cwhse='001';
         endmon;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzinz  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr zzinz;

740aA    prtflg='N';
         chain (pWhse:pRtid) rtehed;
         if not %found(rtehed);
           rhstat=' ';
           rhstat=' ';
         else;
           prte=rhrte;
         endif;
         monitor;
           cwhse=%editc(pWhse:'X');
         on-error;
           cwhse='001';
         endmon;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkDockDoors  Check for dock doors
     *----------------------------------------------------------------

      /free
       begsr ChkDockDoors;

         missingDoor = *off;
         door = '';

         chain (pWhse: '*DOCDOOR') options;
         if not %found(options);
           opatyp = '0';
         endif;

         // Get out if not manually assigning dock doors.
         // Either dock doors are not being used or they are
         // assigned automatically which won't happen until
         // Pick & Print.

         if opatyp <> '2';
           leavesr;
         endif;

         // See if door has been assigned

         if opltyp = '2';
           exsr ChkDockDoors2;
         else;
           exsr ChkDockDoors1;
         endif;

       endsr;
      /end-free

650bA*----------------------------------------------------------------
650bA*  ChkDockDoors1  Check for dock doors - Single
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr ChkDockDoors1;

650aA    setll (pWhse: pRtId) docmtrx2;
650aA    reade (pWhse: pRtId) docmtrx2;

         if %eof(docmtrx2);
           dmdoor = 0;
         endif;

         if dmdoor = 0;
           missingDoor = *on;
650aA      door = 'Not Assigned<br />';
         else;
650bM      door = %char(dmdoor) + ' - '
650bM             + %trim(dmwhdp) + ' '
650bM             + '(' + dmatyp + ')<br />';
         endif;

       endsr;
      /end-free

650bA*----------------------------------------------------------------
650bA*  ChkDockDoors2  Check for dock doors - Department
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr ChkDockDoors2;

         // Loop through RTECSUM records

         lastDept = 'a';
         setll (pWhse: pRtId) rtecsum1;

         dow forever = forever;

           reade (pWhse: pRtId) rtecsum1;

           if %eof(rtecsum1);
             leave;
           endif;

           // Skip duplicate compartment records

           if rcdrdp = lastDept;
             iter;
           endif;

700dA      // Skip blank Department records

700dA      if rcdrdp = ' ';
700dA        iter;
700dA      endif;

           lastDept = rcdrdp;

           // See if door has been assigned

           setll (pWhse: pRtId: rcdrdp) docmtrx2;
           reade (pWhse: pRtId: rcdrdp) docmtrx2;

           if %eof(docmtrx2);
             dmdoor = 0;
           endif;

           if dmdoor = 0;
             missingDoor = *on;
             door = %trimr(door)
                  + %trim(rcdrdp) + ' - Not Assigned<br />';
           else;
             door = %trimr(door)
                  + %trim(rcdrdp) + ' - '
                  + %char(dmdoor) + ' (' + dmatyp + ')<br />';
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkZZZZZZ     Check for ZZZZZZ Zone
     *----------------------------------------------------------------

      /free
       begsr ChkZZZZZZ;

         zzzzzzExists = *off;

         if client = usfcorp;
           leavesr;
         endif;

         setll (pWhse: pRtId) pltsum1;

         dow forever = forever;

           reade (pWhse: pRtId) pltsum1;
           if %eof(pltsum1);
             leave;
           endif;

           if pstzon = 'ZZZZZZ'
              or pspzon = 'ZZZZZZ'
              or psszon = 'ZZZZZZ';
                zzzzzzExists = *on;
                leave;
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetPrePick   Get PrePick info
     *----------------------------------------------------------------

      /free
       begsr GetPrePick;

         isPrePick = *off;
         hasPrePick = *off;
         openPrePick = *off;

         setll (pWhse: pRtId) ordh4;

         dow forever = forever;

           reade (pWhse: pRtId) ordh4;
           if %eof(ordh4);
             leavesr;
           endif;

           // Get out if sent route is a PrePick route

           if %subst(ohmisc:17:1) = 'Y';
             isPrePick = *on;
             leavesr;
           endif;

           // Look for PrePick items on route

           setll (ohwhse: ohcord) ordh10;

           dow forever = forever;

             reade (ohwhse: ohcord) ordh10;
             if %eof(ordh10);
               leave;
             endif;

             if %subst(oh_ohmisc:17:1) <> 'Y';
               iter;
             endif;

             // Item associated with a PrePick order

             hasPrePick = *on;

             // See if PrePick route is only Open or Built.

             if prte = oh_rhrte and oh_rhstat < '4';
               openPrePick = *on;
               leavesr;
             endif;

           enddo;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtDebugParms  Write out debug parm record
     *----------------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = 'sID:' + %trimr(pSessid) + ', '
                  + 'Cmd:' + %trimr(pCmd) + ', '
                  + 'Whs:' + %char(pWhse) + ', '
                  + 'Rtid:' + %trimr(pRtid) + ', '
                  + 'Usr=' + %trimr(pUser) + ','
                  + 'Dct:' + %trimr(pDict) + ', '
                  + 'Pgm:' + %trimr(pPgm) + ', '
                  + 'Out:' + %trimr(pOutStr);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
