      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M33500    Functions for Task Entry Maintenance
     *
     *  11 November 2021
     *  Kenneth Elder
     *
     *  Revisions
     *
750 A*    10/11/21  KDE  7.50
     *      - Created.
     *
750aA*    03/03/22  KDE  7.50a
     *      - Setup Bulk as Transactions per hour
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     ftasksub   if   e           k disk
     ftask      uf a e           k disk
     ftaskdet   uf a e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.bfcdteti
750 A /copy qcopysrc,p.exrtehed

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *------------------------------------rename----------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds
     d $lparm          ds
     d  $lcmd                  1      8
     d  $lprg                  9     18
     d  $luky                 19     68
     d  $lrtn                 69     76
     d  $lerm                 77    136
     d  $lmsg                 77     88
     d*
     d*   Redefine key
     d*
     d  $lcat                 19     24
     d  $lsub                 25     30
     d*
     d  $lcode                19     24
     d  $ltlvl                25     25

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     D*rvrec         E Ds                  Extname(RoleUsrLvl)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D ts              s               z
     D bfcoffset       s              3  0 inz(0)

750 Ad first           s               n
750bAd pos             s              2  0
750bAd dblqte          s              1    inz('"')
750bAd rpldblqte       s              2    inz('\"')
     D client          s             10
     D clientloc       s             10

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     d NullInds        s              5i 0 dim(1)
     d NullValue       s                   like(NullInds) inz(-1)

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     d errMsg          s             99    varying
     d dpCombo         s             20    varying
     d psrnum          s              2  0
     d perrmsg         s             99
750aAd pRtid           s              5
     d validRead       s               n

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pSessId        s             40    varying
     d  pUser          s             10    varying
     d  pdict          s             10    varying
     d  ppgm           s             10    varying
     d  pWhse          s              3p 0
     d  pCmd           s             10
     d  pCmpUser       s             10
     d  pCat           s              6
     d  pSub           s              6
     d  pMode          s              1
     d  pTask          s              6
     d  pType          s              1
     d  pDesc          s             30
     d  pLastZon       s             10
     d  pparmstr       s           1024     varying
     d  poutstr        s           1024     varying

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

    *----------------------------------------------------------------
    * Prototypes
    *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pParmStr    Parm String from Generic Function
     *      pOutStr     Json Return String
     *
     *    Returned Parameters
     *      pOutStr     Json Returned String
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pDict
     c                   parm                    pPgm
     c                   parm                    pParmStr
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMSg=*blanks;
         pOutStr=*blanks;

        exsr getcurrstamp;

         // Extract parameters from delimited string

         ExtractParms();

         // Get out if error

         if errMsg <> '';
           pOutStr = '{"cnt":"0"}';
           WrtDebugError();
           return;
         endif;

         // Do processing

         select;
750 A      when pCmd='*GETSUBCAT';
750 A         // Get sub-categories based on category associated to
750 A         // the selected task
750 A         pOutStr = '{';
750 A         exsr getSubcat;
750 A          pOutStr = %trim(pOutStr) + '}';
           when pCmd = '*UPDDTA';
             // First edit and make sure no errors, then update
             if pMode <> 'D' and pMode<>'d';
               exsr fldvalid;
             endif;
             if pErrMsg = *blanks;
               exsr updDta;
             endif;
750 A      when pCmd='*GETPORT';
750 A         // Get Pieces or Transaction per hour indicator
750 A         pOutStr = '{';
750 A         exsr getPORT;
750 A          pOutStr = %trim(pOutStr) + '}';
           other;
             pOutStr = '{"pErrMsg":"Invalid Command Sent"}';
750 A    endsl;

         // Be sure to return message
         if pErrMSg = *blanks;
           if pOutStr=*blanks;
             pOutStr = '{"pErrMsg":"' + ' ' + '"}';
           endif;
         else;
           pOutStr = '{"pErrMsg":"' + %trim(pErrMSg) + '"}';
         endif;

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
     *  updDta  - Update transaction
     *----------------------------------------------------------------

      /free
       begsr updDta;

         chain (pTask) task;
         if %found(task);
           if pMode = 'D' or pMode='d';
             delete tkrec;
             if not %error();
               // Delete Task Detail records
               exec sql delete from taskdet where tdcode=:tkcode;
             endif;
           else;
             tkdesc=pdesc;
             tkcat=pcat;
             tksub=psub;
             tktype=ptype;
             update tkrec;
           endif;
         else;
           if pMode = 'D' or pMode='d';
             pErrmsg = 'Record not found for Delete';
             leavesr;
           else;
             tkcode=pTask;
             tkdesc=pdesc;
             tkcat=pcat;
             tksub=psub;
             tktype=pType;
             TKSTD='N';
             TKTLVL='W';
             TKUSRC='N';
             TKTRKC='N';
             TKTRKW='N';
             TKTRKP='N';
             TKTRK1='N';
             TKDSC1=' ';
             TKTRK2='N';
             TKDSC2=' ';
             tKTRK3='N';
             TKDSC3=' ';
             write tkrec;
             if not %error();
               // Update Task Detail record  if add was a success
      /end-free
     C                   eval      $lcmd='*ADD'
     C                   eval      $lprg=#pgm
     C                   MOVE      TKCODE        $LCODE
     C                   MOVE      TKTLVL        $LTLVL
     C                   CALL      'CRTTSK  '
     C                   PARM                    $LPARM
      /free
             endif;
           endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getSubcat  -  Get sub-catergories per the Category choosen
     *----------------------------------------------------------------

      /free
       begsr getSubcat;

         first=*on;
         setll (pCat) tasksub;
         dow forever = forever;
           reade (pCat) tasksub;
           if %eof(tasksub);
             leave;
           endif;
750 A      if first;
750 A       first=*off;
750 A       // Set blank record first for each dynamic dropdown
750 A       pOutStr = %trim(pOutStr) + '"' + ' ' +'":"' +
750 A                                         ' ' + '"';
750 A       pOutStr = %trim(pOutStr) + ',"' + tsdesc +'":"' +
750 A                                         tscode + '"';
750 A      else;
750 A       pOutStr = %trim(pOutStr) + ',"' + tsdesc +'":"' +
750 A                                         tscode + '"';
750 A      endif;
         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getPORT  -  Get Pieces, Transaction or Both flag for display
     *              Called from MRC M33000
     *----------------------------------------------------------------

      /free
       begsr getPORT;
         chain (pTask) task;
         if %eof(task);
           pErrmsg = 'Task code is invalid';
           leavesr;
         endif;

         select;
           when tksub = 'PUTAWY';      // Putaway
750 A        pOutStr = %trim(pOutStr) + '"PFLAG":"TPH"';
           when tkcat = 'RECV';        // Receiving
750 A        pOutStr = %trim(pOutStr) + '"PFLAG":"TPH"';
           when tksub = 'BULK';        // Bulk Picks
750 A        pOutStr = %trim(pOutStr) + '"PFLAG":"TPH"';
           when tkcat = 'SELECT';      // Selection
750 A        pOutStr = %trim(pOutStr) + '"PFLAG":"PPH"';
           when tksub = 'TRNSFR';      // Transfer
750 A        pOutStr = %trim(pOutStr) + '"PFLAG":"BOTH"';
           when tkcat = 'SMAINT';      // Replenishments
750 A        pOutStr = %trim(pOutStr) + '"PFLAG":"TPH"';
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  fldValid - Perform field validations
     *----------------------------------------------------------------

      /free
       begsr fldValid;

         if pTask = *blanks;
           pErrmsg = 'Task code cannot be empty';
           leavesr;
         endif;

         if pCat = *blanks;
           pErrmsg = 'Category code cannot be empty';
           leavesr;
         endif;

         if pSub = *blanks;
           pErrmsg = 'Sub-Cat code cannot be empty';
           leavesr;
         endif;

         if pDesc = *blanks;
           pErrmsg = 'Description cannot be empty';
           leavesr;
         endif;

         // Do not allow new Direct Task to be setup.  BFC has
         // to do this setup to ensure it is prgrammed for as well
         chain (pTask) task;
         if %eof(Task);
           if pType='D';
             pErrmsg = 'BFC must maintain Direct Tasks';
             leavesr;
           endif;
         else;
           // When task is found and trying to change to Direct
           // it is an error.
           if pType='D' and pType<>tktype;
             pErrmsg = 'BFC must maintain Direct Tasks';
             leavesr;
           endif;
         endif;

         if pType=' ';
           pErrmsg = 'Type must be either I(Indirect) or D(Direct)';
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

      /free

       monitor;

         select;

           when parmName = 'CMD';
             pCmd = %trim(parmValue);

           when parmName = 'MODE';
             pMode = %trim(parmValue);
             pMode = %xlate(xlower: xupper: pMode);

           when parmName = 'CAT';
             pCat = %trim(parmValue);
             pCat = %xlate(xlower: xupper: pCat);

           when parmName = 'CATSUB';
             pSub = %trim(parmValue);
             pSub = %xlate(xlower: xupper: pSub);

           when parmName = 'DESC';
             pDesc = %trim(parmValue);
             pDesc = %xlate(xlower: xupper: pDesc);

           when parmName = 'TKTYPE';
             pType = %trim(parmValue);
             pType = %xlate(xlower: xupper: pType);

           when parmName = 'TASK';
             pTask = %trim(parmValue);
             pTask = %xlate(xlower: xupper: pTask);

           when parmName = 'WHS';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

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
     D parmName        s             10    varying
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
