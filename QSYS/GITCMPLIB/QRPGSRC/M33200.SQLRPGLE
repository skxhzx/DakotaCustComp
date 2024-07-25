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
     *  M33200    Functions for Auto Tran Assignment Priority Maintenance
     *
     *  23 August 2021
     *  Kenneth Elder
     *
     *  Revisions
     *
750 A*    08/23/21  KDE  7.50
     *      - Created.
     *
750aA*    09/15/21  KDE  7.50a
     *      - Add code to update Ondemand Assign flag to Route Id
     *
750bA*    09/27/21  KDE  7.50b
     *      - Changed to ensure it never sends down more than the
     *        1024 bytes for pOutStr than MRC supports.  A recursive
     *        loop was added in M332xx in MRC to keep calling if this
     *        program sends back a value in last zone.  Once the length
     *        of pOutStr exceeds 850 bytes it will send down with parm
     *        for lastZone processed.  M332xx in MRC will then add the list
     *        to the Zone Dropdown list and call getZones again wand set
     *        the lastZone parm.  Now M33200 on iSeries will start processing
     *        with Pick Zones after what it last processed.  This eliminates
     *        any issues with the 1024 byte limitation for json on generic
     *        function call.
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
     Froleusrlvlif   e           k disk
     Fzoneh     if   e           k disk
     Fglozonsub if   e           k disk
     fzoneaap   uf a e           k disk
     froles     if   e           k disk
     frolelvl   if   e           k disk

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
     d first           s               n
     d roleCnt         s              1  0
     d roleString      s             30

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
     d  pRole          s             10
     d  pZone          s             10
     d  pZoneSub       s             10
     d  pCodeTp        s              1
     d  pZlvl          s              3  0
     d  pPri           s              2  0
     d  pMode          s              1
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
750 A      when pCmd='*GETROLES';
750 A         // Get roles per the user that is passed in.  We will
750 A         // then return the defined roles for user to show only
750 A         // those roles in the Role Drop Down for Auto Tran
750 A         // Assignment Maintenance
750 A         pOutStr = '{';
750 A         exsr getRoles;
750 A          pOutStr = %trim(pOutStr) + '}';
750 A      when pCmd='*GETZONES';
750 A         // Get zones per the role that was selected
750 A         pOutStr = '{';
750 A         exsr getZones;
750 A          pOutStr = %trim(pOutStr) + '}';
750 A      when pCmd='*GETZONSUB';
750 A         // Get sub zones per the role that was selected
750 A         pOutStr = '{';
750 A         exsr getZonSub;
750 A          pOutStr = %trim(pOutStr) + '}';
750aA      when pCmd='*RTEACD';
750aA         // Toggle whether route allows for Ondemand Transactions
750 A         pOutStr = '{';
750aA         exsr updODsts;
750 A          pOutStr = %trim(pOutStr) + '}';
750 A      when pCmd='*UPDDTA';
             // First edit and make sure no errors, then update
             if pMode <> 'D' and pMode<>'d';
               exsr fldvalid;
             endif;
             if pErrMsg = *blanks;
               exsr updDta;
             endif;
750 A      when pCmd='*GETDESC';
750 A         // Get descriptions for all codes on maintainer list
750 A         exsr getDesc;
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
     *  getDesc  Build json String with descriptions for each drodown
     *           codes on Maintainer List
     *----------------------------------------------------------------

      /free
       begsr getDesc;

         pOutStr = '{';

         // Return Code Type String
         if pCodeTp='1';
           pOutStr = %trim(pOutStr) +
                     '"codetp":"User"';
         else;
           pOutStr = %trim(pOutStr) +
                     '"codetp":"Group"';
         endif;

         // Return Role Code String
         exec sql select rolngd into :rolngd
                    from roles
               where roznec=:pRole;
         if sqlstt='00000';
           pOutStr = %trim(pOutStr) +
                     ',"role":"' + %trim(ROLNGD) + '"';
         else;
           pOutStr = %trim(pOutStr) +
                     ',"role":"' + 'Invalid Role' + '"';
         endif;

         // Return Role Level Code
         chain (pZlvl) rolelvl;
         if %found(RoleLvl);
           pOutStr = %trim(pOutStr) +
                     ',"rolelvl":"' + %trim(RLLNGD) + '"';
         else;
           pOutStr = %trim(pOutStr) +
                     ',"rolelvl":"' + 'Invalid Role Level' + '"';
         endif;

         // Return Zone Code String
         chain (pWhse:pRole:pZone) zoneh;
         if %found(zoneh);

750bA      // Replace double quotes with slash double qoute
750bA      pos = %scan(dblqte: zhdesc);
750bA      dow pos > 0;
750bA         zhdesc = %replace(rpldblqte: zhdesc: pos: %len(dblqte)) ;
750bA         if (pos+%len(rpldblqte) > %len(zhdesc));
750bA            pos = 0;
750bA         else;
750bA            pos = %scan(dblqte: zhdesc: pos+%len(rpldblqte));
750bA         endif;
750bA      enddo;

           pOutStr = %trim(pOutStr) +
                     ',"zone":"' + %trim(ZHZONE) + ' - ' + %trim(zhdesc) + '"';
         else;
           pOutStr = %trim(pOutStr) +
                     ',"zone":"' + 'Invalid Zone' + '"';
         endif;

         // Return Zone Sub Code String
         if pZoneSub <> *blanks;
           exec sql select gzsdesc into :gzsdesc
                        from glozonsub
                    where gzstruk=:pRole and gzscode=:pZoneSub;
           if sqlstt='00000';
             pOutStr = %trim(pOutStr) +
                       ',"zonesub":"' + %trim(gzsdesc)
                          + '"';
           else;
             pOutStr = %trim(pOutStr) +
                       ',"zonesub":"' + 'Invalid Zone Sub' + '"';
           endif;
         else;
           pOutStr = %trim(pOutStr) +
                     ',"zonesub":"' + ' ' + '"';
         endif;

         pOutStr = %trim(pOutStr) + '}';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getRoles  Get Roles for specific Employee
     *----------------------------------------------------------------

      /free
       begsr getRoles;

         first=*on;
         setll (pCmpUser) roleUsrLvl;
         dow forever = forever;
           reade (pCmpUser) roleUsrLvl;
           if %eof(roleUsrLvl);
             leave;
           endif;
           // Confirm this role has at least one zone to prioritize
           // Otherwise we will not allow it to be slected for zone
           // Priorities
           chain (pWhse:rvznec) zoneh;
           if not %found(zoneh);
             iter;
           endif;
           roleString=*blanks;
           exec sql select rolngd into :roleString
                        from roles
                 where roznec=:rvznec;
750 A      if first;
750 A       first=*off;
            // Set blank record first for each dynamic dropdown
750 A       pOutStr = %trim(pOutStr) + '"' + ' ' +'":"' +
750 A                                         ' ' + '"';
750 A       pOutStr = %trim(pOutStr) + ',"' + roleString +'":"' +
750 A                                         %char(rvznec) + '"';
750 A      else;
750 A       pOutStr = %trim(pOutStr) + ',"' + roleString +'":"' +
750 A                                         %char(rvznec) + '"';
750 A      endif;
         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  fldValid - Perform field validations
     *----------------------------------------------------------------

      /free
       begsr fldValid;

         if pRole = *blanks;
           pErrmsg = 'Role must be entered';
           leavesr;
         endif;

         if pZone = *blanks;
           pErrmsg = 'Zone must be entered';
           leavesr;
         endif;

         if pZoneSub = *blanks;
           //pErrmsg = 'Zone Sub must be entered';
           //leavesr;
         endif;

         if pZlvl = *zeros;
           pErrmsg = 'Level must be entered';
           leavesr;
         endif;

         if pPri <1 or pPri >10;
           pErrmsg = 'Priority must be between 1 and 10';
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  updODsts - Update On-Demand Status by Route Id
     *----------------------------------------------------------------

      /free
       begsr updODsts;

         monitor;
           exWhse = pwhse;
           rhatbtype = *blanks;
           rhaasn = *blanks;
           exrtehed('*GET': exRtnCode: exRtnMsg: exWhse: prtid: rhatbtype:
                               rhardypp: rhaasn);
           if exRtnCode = '*OK';
             if rhaasn = ' ' or rhaasn='N';
                rhaasn = 'Y';
             else;
                rhaasn = 'N';
             endif;
             exrtehed('*CHANGE': exRtnCode: exRtnMsg: exWhse: prtid: rhatbtype:
                               rhardypp: rhaasn);
             if exRtnCode = '*OK';
               pOutStr = %trim(pOutStr) + '"odstat":"' + rhaasn + '"';
             endif;
           else;
             rhatbtype=' ';
             rhardypp=' ';
             rhaasn = 'Y';
             exrtehed('*ADD': exRtnCode: exRtnMsg: exWhse: prtid: rhatbtype:
                               rhardypp: rhaasn);
             if exRtnCode = '*OK';
              exrtehed('*CHANGE': exRtnCode: exRtnMsg: exWhse: prtid: rhatbtype:
                                rhardypp: rhaasn);
             endif;
           endif;

           // update route id for session with new Auto Assign Flag
           exec sql update sum0031 set smaasn=:rhaasn
               where smsessid=:pSessid and smrtid=:pRtid;
         on-error;
         endmon;

       endsr;

     *----------------------------------------------------------------
     *  updDta  - Update transaction
     *----------------------------------------------------------------

      /free
       begsr updDta;

         chain (pWhse:' ':'1':pCmpUser:pRole:pZone:pZoneSub) zoneaap;
         if %found(zoneaap);
           if pMode = 'D' or pMode='d';
             delete zarec;
           else;
             zazonelvl = pZlvl;
             zazonepri = ppri;
             update zarec;
           endif;
         else;
           if pMode = 'D' or pMode='d';
             pErrmsg = 'Record not found for Delete';
             leavesr;
           else;
             zawhse=pWhse;
             zacshft=' ';
             zacodetp='1';
             zacode=pCmpUser;
             zarolecd=pRole;
             zazonecd=pZone;
             zazonesub=pzonesub;
             zazonelvl = pZlvl;
             zazonepri = ppri;
             write zarec;
           endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getZones  Get Zones for specific Role
     *----------------------------------------------------------------

      /free
       begsr getZones;

         first=*on;
         setll (pWhse:pRole) zoneh;
         dow forever = forever;
           reade (pWhse:pRole) zoneh;
           if %eof(zoneh);
             leave;
           endif;
750bA      // if last zone is passed in and what we just read is
750bA      // less than or equal to then we should iter and only
750bA      // send back pick zones greater than loaded in previous
750bA      // call.
750bA      if pLastZon <> *blanks and zhzone <= pLastZon;
750bA        iter;
750bA      endif;

750bA      // Replace double quotes with slash double qoute
750bA      pos = %scan(dblqte: zhdesc);
750bA      dow pos > 0;
750bA         zhdesc = %replace(rpldblqte: zhdesc: pos: %len(dblqte)) ;
750bA         if (pos+%len(rpldblqte) > %len(zhdesc));
750bA            pos = 0;
750bA         else;
750bA            pos = %scan(dblqte: zhdesc: pos+%len(rpldblqte));
750bA         endif;
750bA      enddo;

           roleString = %trim(zhzone) + ' - ' + %trim(zhdesc);
           if first;
750 A       first=*off;
750bA       // if coming back to finish zones because they would
750bA       // not all fit in one json pass down then pass on the
750bA       // blank entry
750bA       if pLastZon = *blanks;
              // Set blank record first for each dynamic dropdown
750 A         pOutStr = %trim(pOutStr) + '"' + ' ' +'":"' +
750 A                                           ' ' + '"';
750 A         pOutStr = %trim(pOutStr) + ',"' + roleString +'":"' +
750 A                                           %char(zhzone) + '"';
750bA       else;
750 A         pOutStr = %trim(pOutStr) + '"' + roleString +'":"' +
750 A                                         %char(zhzone) + '"';
750bA       endif;
750 A      else;
750 A       pOutStr = %trim(pOutStr) + ',"' + roleString +'":"' +
750 A                                         %char(zhzone) + '"';
750 A      endif;
750bA
750bA      // if length of pOutStr exceeds 850 bytes then close
750bA      // json string and return last zone processed.  MRC app
750bA      // M332xx will call this again to get remaining zones so
750bA      // it can fully populate the Zones dropdown list
750bA      if %len(%trim(pOutStr)) > 850;
750bA        pLastZon = zhzone;
750bA        leave;
750bA      else;
750bA        pLastZon = *blanks;
750bA      endif;
         enddo;
750bA
750bA    // add lastZone indicator for M332xx in MRC to know if more zones
750bA    // to process
750bA    if pLastZon = *blanks;
750bA      pOutStr = %trim(pOutStr) + ',"' + 'LASTZONE' +'":"' +
750bA                                         '*END' + '"';
750bA    else;
750bA      pOutStr = %trim(pOutStr) + ',"' + 'LASTZONE' +'":"' +
750bA                                         %char(zhzone) + '"';
750bA    endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getZonSub  Get Zones Sub for specific Role
     *----------------------------------------------------------------

      /free
       begsr getZonSub;

         first=*on;
         setll (*loval) glozonsub;
         dow forever = forever;
           read glozonsub;
           if %eof(glozonsub);
             leave;
           endif;
           if gzstruk<>%trim(pRole);
             iter;
           endif;
           roleString = %char(gzscode) + ' - ' + %trim(gzsdesc);
750 A      if first;
750 A       first=*off;
            // Set blank record first for each dynamic dropdown
750 A       pOutStr = %trim(pOutStr) + '"' + ' ' +'":"' +
750 A                                         ' ' + '"';
750 A       pOutStr = %trim(pOutStr) + ',"' + roleString +'":"' +
750 A                                         %char(gzscode) + '"';
750 A      else;
750 A       pOutStr = %trim(pOutStr) + ',"' + roleString +'":"' +
750 A                                         %char(gzscode) + '"';
750 A      endif;
         enddo;

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

           when parmName = 'CODETP';
             pCodeTp = %trim(parmValue);

           when parmName = 'USER';
             pCmpUser = %trim(parmValue);

           when parmName = 'ROLE';
             pRole = %trim(parmValue);

           when parmName = 'ZONE';
             pZone = %trim(parmValue);

           when parmName = 'ZONSUB';
             pZoneSub = %trim(parmValue);

           when parmName = 'LASTZONE';
             pLastZon = %trim(parmValue);

           when parmName = 'ZLVL';
             if parmValue = '';
               parmValue = '0';
             endif;
             pZlvl =  %dec(parmValue: 3: 0);

           when parmName = 'PRI';
             if parmValue = '';
               parmValue = '0';
             endif;
             pPri =  %dec(parmValue: 2: 0);

750aA      when parmName = 'RTID';
750aA        pRtid = %trim(parmValue);

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
