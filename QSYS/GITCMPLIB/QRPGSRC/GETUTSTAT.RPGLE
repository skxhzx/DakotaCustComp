      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H bnddir('YAJL')

     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETUISTAT    Get User/Transaction Status - GENFNC
     *  12 November 2021
     *  Dave Sommerville
     *
     *  Revisions:
     *
750 A*    11/12/21  DAS  7.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  This program is called via the GENFNC SQL Stored Procedure
     *
     *  The parameters are strings containing value pairs,
     *  with multiple pairs being separated by a '|', for example:
     *
     *    fieldname1=value|fieldname2=value|fieldname3=value
     *
     *  The returned string is JSON format
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  This program incorporated logic from program GETTRNLOC.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     Fpirtranw  if   e           k disk
     Fpirtran1w if   e           k disk    rename(ptrec:ptrec1w)
     Flabel     if   e           k disk
     Flabel71   if   e           k disk
     Flabeldo1  if   e           k disk
     Fworklbl   if   e           k disk
     Ftask      if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getuser

     *----------------------------------------------------------------
     *  YAJL Header
     *----------------------------------------------------------------

      /copy qcopysrc,yajl_h
     d yajlerr         s            500    varying

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     d errMsg          s             99    varying
     d dpCombo         s             20    varying

     d logts           s             26
     d ts              s               z

     d pCmd            s             10
     d pWhse           s              3  0
     d pTran           s              7  0
     d plUser          s             10

     d loc             s             20    varying
     d dept            s             10    varying
     d zone            s             10    varying
     D slotsPck        s              5  0
     D slotsRem        s              5  0
     D nrmLblPck       s              5  0
     D nrmLblRem       s              7  0
     D nrmPcsPck       s              5  0
     D nrmPcsRem       s              7  0
     D mrgLblPck       s              5  0
     D mrgLblRem       s              7  0
     D mrgPcsPck       s              5  0
     D mrgPcsRem       s              7  0
     D ttlLblPck       s              5  0
     D ttlLblRem       s              7  0
     D ttlPcsPck       s              5  0
     D ttlPcsRem       s              7  0

     D kyCurTS         s               z
     D lastDisp        s                    like(lbdisp)

     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pParmStr    String of '|' delimited parameters
     *        cmd (pCmd) - Command
     *                     *TRANSENT - Get info using Trn#
     *                     *USERSENT - Get info using User
     *        whs (pWhse) - Warehouse
     *        trn (pTran) - Tran for *TRANSENT
     *
     *    Returned Parameters
     *      pOutStr     Return string in JSON format
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * JSON string
     *
     *    "loc"      - Slot location or "Unknown"
     *    "whdp"     - Department of location
     *    "zone"     - Selection zone of location
     *    "slotsPck" - Slots picked
     *    "slotsRem" - Slots remaining
     *    "nrmLblPck - Normal labels picked
     *    "nrmLblRem - Normal labels remaining
     *    "nrmPcsPck - Normal pieces picked
     *    "nrmPcsRem - Normal pieces remaining
     *    "mrgLblPck - Merge labels picked
     *    "mrgLblRem - Merge labels remaining
     *    "mrgPcsPck - Merge pieces picked
     *    "mrgPcsRem - Merge pieces remaining
     *    "ttlLblPck - Total labels picked
     *    "ttlLblRem - Total labels remaining
     *    "ttlPcsPck - Total pieces picked
     *    "ttlPcsRem - Total pieces remaining
     *
     *----------------------------------------------------------------

     D GETUTSTAT       pr                  extpgm('GETUTSTAT')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D GETUTSTAT       pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ProcessTran     pr

     d ProcessUser     pr

     d GetTranInfo     pr

     d GetNonSelLoc    pr

     d GetSelBlkLoc    pr

     d GetSelLoc       pr

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     30    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         errMsg = '';
         pOutStr = '';

         debug = *off;
         debugBefore = *off;
         debugAfter = *off;
         if dbgflgExists;
           chain(e) (#pgm) bfcdbgflg;
           if %found(bfcdbgflg);
             select;
               when bdfflag = 1;
                 debug = *on;
                 debugAfter = *on;
               when bdfflag = 2;
                 debug = *on;
                 debugBefore = *on;
               when bdfflag = 3;
                 debug = *on;
                 debugBefore = *on;
                 debugAfter = *on;
             endsl;
           endif;
         endif;

         // Combine dictionary/program

         dpCombo = %trim(pDict) + '.' + pPgm;

         // Write out 'Before' Debug info

         if debugBefore;
           debugLoc = 'B';
           wrtBeforeDebug();
         endif;

         // Extract parameters from delimited string

         ExtractParms();

         // Process command

         if errMsg <> '';
           WrtDebugError();
           loc = 'Unknown';
         else;
           select;
             when pCmd = '*TRANSENT';
               ProcessTran();
             when pCmd = '*USERSENT';
               ProcessUser();
           endsl;
         endif;

         // Create JSON string to send back

         yajl_genOpen(*OFF);             // Init unformatted JSON procesing
           yajl_beginObj();              // Begin JSON string

             yajl_addchar('loc': loc);
             yajl_addchar('dept': dept);
             yajl_addchar('zone': zone);
             yajl_addchar('slotsPck': %char(slotsPck));
             yajl_addchar('slotsRem': %char(slotsRem));
             yajl_addchar('nrmLblPck': %char(nrmLblPck));
             yajl_addchar('nrmLblRem': %char(nrmLblRem));
             yajl_addchar('nrmPcsPck': %char(nrmPcsPck));
             yajl_addchar('nrmPcsRem': %char(nrmPcsRem));
             yajl_addchar('mrgLblPck': %char(mrgLblPck));
             yajl_addchar('mrgLblRem': %char(mrgLblRem));
             yajl_addchar('mrgPcsPck': %char(mrgPcsPck));
             yajl_addchar('mrgPcsRem': %char(mrgPcsRem));
             yajl_addchar('ttlLblPck': %char(ttlLblPck));
             yajl_addchar('ttlLblRem': %char(ttlLblRem));
             yajl_addchar('ttlPcsPck': %char(ttlPcsPck));
             yajl_addchar('ttlPcsRem': %char(ttlPcsRem));

           yajl_endObj();                 // End entire JSON string
           pOutStr = YAJL_copyBufStr();   // Copy JSON string into parameter
         yajl_genClose();                 // Close and cleanup JSON processing

         // Write out 'After' Debug info

         if debugAfter;
           debugLoc = 'A';
           wrtAfterDebug();
         endif;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ProcessTran   Process sent transaction
     *----------------------------------------------------------------

     p ProcessTran     b
     d ProcessTran     pi

     d pos             s             10i 0

     D slgrec        E ds                  extname(bfcsktlog) inz(*EXTDFT)

      /free

        // Get transaction record

        chain (pWhse: pTran) pirtranw;
        if not %found(pirtranw);
          loc = 'Unknown';
          return;
        endif;

        // Get information for transaction

        GetTranInfo();

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ProcessUser   Process sent user
     *----------------------------------------------------------------

     p ProcessUser     b
     d ProcessUser     pi

     d pos             s             10i 0

     D slgrec        E ds                  extname(bfcsktlog) inz(*EXTDFT)

      /free

        // Get user employee number

        getUser(plUser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                e$bpu: e$lng);

        if e$emp# = 0;
          loc = 'Unknown';
          return;
        endif;

        // Get current transaction for user

        setgt (pWhse: e$emp#: '2') pirtran1w;
        readpe (pWhse: e$emp#: '2') pirtran1w;
        if %eof(pirtran1w);
          loc = 'Unknown';
          return;
        endif;

        // Get information for transaction

        GetTranInfo();

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetTranInfo   Get tranaction info
     *----------------------------------------------------------------

     p GetTranInfo     b
     d GetTranInfo     pi

     d pos             s             10i 0

      /free

        select;

          when ptcat <> 'SELECT';
            GetNonSelLoc();

          when %subst(pttask:1:4) = 'BULK';
            GetSelBlkLoc();

          other;
            GetSelLoc();

        endsl;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetNonSelectLoc  Get non-selection location
     *----------------------------------------------------------------

     p GetNonSelLoc    b
     d GetnonSelLoc    pi

      /free

        // If Indirect task, set location to task code

        chain (pttask) task;
        if not %found(task) or tktype = 'I' or tkcat='MISC';
          loc = pttask;
          return;
        endif;

        // See if Label rec exists for transaction

         setll (pttrn#) label71;
         reade (pttrn#) label71;
         if %eof(label71);
          loc = 'Unknown';
         else;
          loc = %trimr(lbdisp);
          dept = %trimr(lbwhdp);
         endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetSelectBulkLoc    Get Bulk selection location
     *----------------------------------------------------------------

     p GetSelBlkLoc    b
     d GetSelBlkLoc    pi

      /free

         setll (pttrn#) label71;
         reade (pttrn#) label71;
         if %eof(label71);
          loc = 'Unknown';
         else;
          chain (lblbl#) worklbl;
          if not %eof(worklbl);
            zone = %trimr(lwszon);
          endif;
          loc = %trimr(lbdisp);
          dept = %trimr(lbwhdp);
          ttlpcsrem = lbqpck;
         endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetSelectLoc     Get selection location
     *----------------------------------------------------------------

     p GetSelLoc       b
     d GetSelLoc       pi

      /free

         // Try to get last location from LABELDO file

         kyCurTS = %timestamp();

         setgt (pttrn#: kyCurTS) labeldo1;
         readpe (pttrn#) labeldo1;
         if %eof(labeldo1);
          loc = 'Unknown';
         else;
           chain (lbolbl#) label;
           if not %found(label);
              loc = 'Unknown';
           else;
              loc = %trimr(lbdisp);
              dept = %trimr(lbwhdp);
              zone = %trimr(lbozone);
           endif;
         endif;

         // Calculate details

         slotsPck = 0;
         slotsRem = 0;
         nrmLblPck = 0;
         nrmLblRem = 0;
         nrmPcsPck = 0;
         nrmPcsRem = 0;
         mrgLblPck = 0;
         mrgLblRem = 0;
         mrgPcsPck = 0;
         mrgPcsRem = 0;
         ttlLblPck = 0;
         ttlLblRem = 0;
         ttlPcsPck = 0;
         ttlPcsRem = 0;
         lastDisp = ' ';

         setll (pttrn#) label71;
         dow forever = forever;

           reade (pttrn#) label71;

           if %eof(label71);
             leave;
           endif;

           // Only read O and M records.

           if lbtype <> 'O'
             and lbtype <> 'M';
               iter;
           endif;

           select;

             when lbvrfy = ' ';

               ttlLblRem += 1;
               ttlPcsRem += lbqpck;
               if lbdisp <> lastDisp;
                 slotsRem += 1;
                 lastDisp = lbdisp;
               endif;
               if lbtype = 'M';
                 mrgLblRem += 1;
                 mrgPcsRem += lbqpck;
               else;
                 nrmLblRem += 1;
                 nrmPcsRem += lbqpck;
               endif;

             other;

               ttlLblPck += 1;
               ttlPcsPck += lbqpck;
               if lbdisp <> lastDisp;
                 slotsPck += 1;
                 lastDisp = lbdisp;
               endif;
               if lbtype = 'M';
                 mrgLblPck += 1;
                 mrgPcsPck += lbqpck;
               else;
                 nrmLblPck += 1;
                 nrmPcsPck += lbqpck;
               endif;

             endsl;

         enddo;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     30    varying
     d  parmValue                   100    varying

     d lowParmName     s             30A   varying
     d lowercase       c                   'abcdefghijklmnopqrstuvwxyz'
     d uppercase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

      /free

       // Force parm name to lowercase to eliminate case errors

       lowParmName = %xlate(uppercase: lowercase: parmName);

       monitor;

         select;

           when parmName = 'cmd';
             pCmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'user';
             plUser = %xlate(xlower: xupper: parmValue);

           when parmName = 'whs';
             if parmValue = '';
               parmValue = '0';
             endif;
             pWhse =  %dec(parmValue: 3: 0);

           when parmName = 'trn';
             if parmValue = '';
               parmValue = '0';
             endif;
             pTran =  %dec(parmValue: 7: 0);

         endsl;

       on-error;

         errMsg = 'Error extracting parameter '
                + %char(parmCount) + ' '
                + parmName + ' '
                + '(' + parmValue + ')'
                + '('
                + %trimr(#Job) + '/'
                + %trimr(#JobNbr) + '/'
                + %trimr(#user)
                + ')';

       endmon;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParms   Extract parms from parameter string
     *----------------------------------------------------------------

     p ExtractParms    b
     d ExtractParms    pi

      /free

         // Error if parameter string is blank

         if pParmStr = '';
           errMsg = 'Error: Parameter string is empty '
                  + '('
                  + %trimr(#Job) + '/'
                  + %trimr(#JobNbr) + '/'
                  + %trimr(#user)
                  + ')';
           return;
         endif;

         // Extract parms for string 1

         ExtractParmStr();

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi

     * Local Variables

     D parmCount       s              3  0
     D parmGroup       s            200    varying
     D parmLen         s              5  0
     D parmName        s             30    varying
     D parmStrLen      s              5  0
     D parmValue       s            100    varying
     D pos             s              5  0
     D start           s              5  0

      /free

       // Parameters are separated by '|'

       start = 1;
       parmStrLen = %len(pParmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': pParmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(pParmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(pParmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           errMsg = 'Error: Invalid parameter group '
                   + %char(parmCount) + ' '
                   + '(' + parmGroup + ')'
                   + '('
                   + %trimr(#Job) + '/'
                   + %trimr(#JobNbr) + '/'
                   + %trimr(#user)
                   + ')';
           leave;
         endif;

         parmName = %subst(parmGroup: 1: pos - 1);

         // Extract parameter value

         parmLen = %len(parmGroup);

         if parmLen = pos;
           parmValue = '';
         else;
           parmValue = %subst(parmGroup: pos + 1);
         endif;

         // Convert extracted value and put into DRI field

         ConvertField(parmCount: parmName: parmValue);
         if errMsg <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtBeforeDebug  Write out 'Before' debug info
     *----------------------------------------------------------------

     p WrtBeforeDebug  b
     d WrtBeforeDebug  pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pUser:' + %trimr(plUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pParm:' + pParmStr;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtAfterDebug  Write out 'After' debug info
     *----------------------------------------------------------------

     p WrtAfterDebug   b
     d WrtAfterDebug   pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pUser:' + %trimr(plUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pOutStr:' + %trimr(pOutStr) + ', '
                  + 'logts:' + %trimr(logts) + ', '
                  + 'pParm:' + pParmStr;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtDebugError  Write out debug error
     *----------------------------------------------------------------

     p WrtDebugError   b
     d WrtDebugError   pi

      /free

         bdtype = 'ERROR';

         bdvalues = errMsg;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

