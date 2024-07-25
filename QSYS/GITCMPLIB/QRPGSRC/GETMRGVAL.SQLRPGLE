      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETMRRGVAL   Get merge value for pallet or transaction
     *  13 August 2021
     *  Dave Sommerville
     *
     *  Revisions:
     *
750 A*    08/13/21  DAS  7.50
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
     *  The returned string is status from CHKORDAUD.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

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

     d whse            s              3  0
     d type            s              3
     d valtype         s              4
     d rtid            s              5
     d trn             s              7  0
     d plid            s              7  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pParmStr    String of '|' delimited parameters
     *                  whse - Warehouse
     *                  type - 'rte' - Route totals
     *                         'trn' - Tran totals
     *                         'plt' - Pallet totals
     *                  valtype - 'pcs' = Pieces
     *                            'cube' = Cube
     *                            'wgt' = Weight
     *                  rtid - Route id
     *                  trn  - Tran#
     *                         0 = Get totals for route
     *                  plid - Pallet id
     *
     *
     *    Returned Parameters
     *      pOutStr     Return string in JSON format
     *
     *----------------------------------------------------------------

     D GetMrgVal       pr                  extpgm('GETMRGVAL')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D GetMrgVal       pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d GetPltVal       pr

     d GetRteVal       pr

     d GetTrnVal       pr

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

         // Get out if error

         if errMsg <> '';
           pOutStr = '{"errMsg":"' + errMsg + '"}';
           WrtDebugError();
           pOutStr = '0';
           return;
         endif;

         // Do processing
         // Note, we are just passing back value, not a JSON string

         select;
           when type = 'rte';
             GetRteVal();
           when type = 'trn';
             GetTrnVal();
           when type = 'plt';
             GetPltVal();
         endsl;

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
     *  GetPltVal   Get merge value for pallet
     *----------------------------------------------------------------

     p GetPltVal       b
     d GetPltVal       pi

     *  Local Variables

     D count           s              5p 0
     D countInd        s              2b 0
     D pcs             s             15p 0
     D pcsInd          s              2b 0
     D cube            s             15p 3
     D cubeInd         s              2b 0
     D wgt             s             15p 2
     D wgtInd          s              2b 0

      /free

        exec sql select count(*), sum(lbqpck), sum(lbcube), sum(lbswgt)
                 into :count :countInd,
                      :pcs :pcsInd,
                      :cube :cubeInd,
                      :wgt :wgtInd
                 from label
                 where lbwhse = :whse
                   and lbrte = :rtid
                   and lbpal# = :plid
                   and lbtype = 'M';

        if sqlstt <> sqlSuccess or count = 0;
          pcs = 0;
          cube =0;
          wgt = 0;
        endif;

        select;
          when valtype = 'pcs';
            pOutStr = %char(pcs);
          when valtype = 'cube';
            if cube = 0;
              pOutStr = '0';
            else;
              pOutStr = %char(cube);
            endif;
          when valtype = 'wgt';
            if wgt = 0;
              pOutStr = '0';
            else;
              pOutStr = %char(wgt);
            endif;
        endsl;

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetRteVal   Get merge value for route
     *----------------------------------------------------------------

     p GetRteVal       b
     d GetRteVal       pi

     *  Local Variables

     D count           s              5p 0
     D countInd        s              2b 0
     D pcs             s             15p 0
     D pcsInd          s              2b 0
     D cube            s             15p 3
     D cubeInd         s              2b 0
     D wgt             s             15p 2
     D wgtInd          s              2b 0

      /free

        exec sql select count(*), sum(lbqpck), sum(lbcube), sum(lbswgt)
                 into :count :countInd,
                      :pcs :pcsInd,
                      :cube :cubeInd,
                      :wgt :wgtInd
                 from label
                 where lbwhse = :whse
                   and lbrte = :rtid
                   and lbtype = 'M';

        if sqlstt <> sqlSuccess or count = 0;
          pcs = 0;
          cube =0;
          wgt = 0;
        endif;

        select;
          when valtype = 'pcs';
            pOutStr = %char(pcs);
          when valtype = 'cube';
            if cube = 0;
              pOutStr = '0';
            else;
              pOutStr = %char(cube);
            endif;
          when valtype = 'wgt';
            if wgt = 0;
              pOutStr = '0';
            else;
              pOutStr = %char(wgt);
            endif;
        endsl;

        return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetTrnVal   Get merge value for transaction
     *----------------------------------------------------------------

     p GetTrnVal       b
     d GetTrnVal       pi

     *  Local Variables

     D count           s              5p 0
     D countInd        s              2b 0
     D pcs             s             15p 0
     D pcsInd          s              2b 0
     D cube            s             15p 3
     D cubeInd         s              2b 0
     D wgt             s             15p 2
     D wgtInd          s              2b 0

      /free

        exec sql select count(*), sum(lbqpck), sum(lbcube), sum(lbswgt)
                 into :count :countInd,
                      :pcs :pcsInd,
                      :cube :cubeInd,
                      :wgt :wgtInd
                 from label
                 where lbwhse = :whse
                   and lbtrn# = :trn
                   and lbtype = 'M';

        if sqlstt <> sqlSuccess or count = 0;
          pcs = 0;
          cube =0;
          wgt = 0;
        endif;

        select;
          when valtype = 'pcs';
            pOutStr = %char(pcs);
          when valtype = 'cube';
            if cube = 0;
              pOutStr = '0';
            else;
              pOutStr = %char(cube);
            endif;
          when valtype = 'wgt';
            if wgt = 0;
              pOutStr = '0';
            else;
              pOutStr = %char(wgt);
            endif;
        endsl;

        return;

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

           when lowParmName = 'whse';
             if parmValue = '';
               parmValue = '0';
             endif;
             whse = %dec(parmValue: 3: 0);

           when lowParmName = 'type';
             type = parmValue;

           when lowParmName = 'valtype';
             valtype = parmValue;

           when lowParmName = 'rtid';
             rtid = parmValue;

           when lowParmName = 'trn';
             if parmValue = '';
               parmValue = '0';
             endif;
             trn = %dec(parmValue: 7: 0);

           when lowParmName = 'plid';
             if parmValue = '';
               parmValue = '0';
             endif;
             plid = %dec(parmValue: 7: 0);

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
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pOutStr:' + %trimr(pOutStr) + ', '
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
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pOutStr:' + %trimr(pOutStr) + ', '
                  + 'whse:' + %char(whse) + ', '
                  + 'type:' + %trimr(type) + ', '
                  + 'vtype:' + %trimr(valtype) + ', '
                  + 'rtid:' + %trimr(rtid) + ', '
                  + 'trn:' + %char(trn) + ', '
                  + 'plid:' + %char(plid) + ', '
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

