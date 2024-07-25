      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  M29800    Maintain Cycle Count Header
     *  30 July 2019
     *  Kenneth Elder
     *

     *----------------------------------------------------------------
     *  Revisions
     *
730 A*    07/30/19  KDE  7.30
     *      - Created
     *
     *----------------------------------------------------------------

     fpiritem   if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D rtchrec       E ds                  extname(rtchsth) inz(*EXTDFT)


     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D ts              s               z
     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     D bfcoffset       s              3  0 inz(0)


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtcase
      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.updrtch
     *----------------------------------------------------------------
     * DRI Parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     d dpCombo         s             20
     D forevr          s               n
     d n               s             18  0
     d pattern         s            200
     d fieldCnt        s              2  0
     d filename        s            100
     d cmdString       s            200
     d count           s             10  0
     d lastpos         s              5  0
     d nextBegin       s              5  0
     d lenchar         s              5  0
     d lpos            s              5  0
     d newDir          s            300
     d pcmd            s             10
     d p_rtchwhse      s              3  0
     d p_rtchuid       s              7  0
     d p_rtchsid       s              3  0
     d p_rtchsts       s              5
     d p_rtchutflg     s              1
     d p_rtchtype      s              2  0
     d p_rtchbasslt    s              7  0
     d p_rtchttlslt    s              7  0
     d p_rtcshadj      s              7  0
     d p_rtchpprts     s               z
     d p_rtchpsrrs     s               z
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
     d psubcmd         s              1
     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

      *  Client Name Data Area
     dpirclient        ds            10    DTAARA('PIRCLIENT')

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSess          s             40
     D  puser          s             10
     D  pDict          s             10
     D  ppgm           s             10
     D  pObjLoc        s             10
     D  pparmStr1      s            999
     D  pparmStr2      s            999
     D  pparmStr3      s            999

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)
     D NullString      C                   -1
     D Success         C                   0
     D ObjectNotFound  C                   'CPF3142'
     D ObjectInUse     C                   'CPF3156'
     D NoSuchPath      C                   'CPE3025'
     D Errmsgid        S              7    Import('_EXCP_MSGID')
     D Returncode      S             10I 0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pSess       Session
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pobjLoc     MRC Object Location
     *      pparmStr1   Parm String 1
     *      pparmStr2   Parm String 2
     *      pparmStr3   Parm String 3
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr
     d  parmStr                     999    varying

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSess
     C                   parm                    pUser
     C                   parm                    pDict
     C                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pparmStr1
     C                   parm                    pparmStr2
     C                   parm                    pparmStr3
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        // Combine dictionary/program

        dpCombo = %trim(pDict) + '.' + pPgm;

        pMessage = '';
        error = *off;

        exsr getcurrstamp;

        // Extract parameters from delimited string

        ExtractParms();

        if %trim(pMessage) = '';
           exsr Afteract;
        endif;

        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         // Get Client name to use in Batchreports directory path
         in pirclient;

         // Convert fields to uppercase

         puser   = %xlate(xlower: xupper: puser);
         ppgm    = %xlate(xlower: xupper: ppgm);
         getclient(client: clientLoc);


         getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

      /end-free

      /free
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

         // For adds simply call updrtch which creates RTCHSTH record
        pcmd = 'ADD';
        updrtch(p_rtchwhse: pcmd: p_rtchuid: p_rtchtype);
        // update flag for Assigning Teams
        exec sql update rtchsth set rtchutflg=:p_rtchutflg
                 where rtchwhse=:p_rtchwhse and rtchuid=:p_rtchuid;

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

         select;
           when pSubCmd = 'A';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'U' or pSubCmd = 'C';
             if found;
               exsr UpdRec;
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
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

          if p_rtchtype=0;
             error=*on;
             pMessage='Count Type is invalid';
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         rtcHWHSE  = p_rtchwhse;
	        rtchuid   = p_rtchuid;
         rtchsid   = p_rtchsid;
         rtchutflg = p_rtchutflg;
         rtchtype  = p_rtchtype;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :rtchrec
                  from rtchsth
                  where rtchuid = :p_rtchuid;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;
         exsr FillRec;

         exec sql update rtchsth
                  set rtchwhse=:rtchwhse, rtchuid=:rtchuid, rtchsid=:rtchsid,
               rtchsts=:rtchsts, rtchutflg=:rtchutflg,
               rtchtype=:rtchtype, rtchbasslt=:rtchbasslt,
               rtchttlslt=:rtchttlslt, rtchadj=:rtchadj,
               rtchpstts=:nostamp
                  where rtchuid = :rtchuid and
                 rtchsid = :rtchsid;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Id(' + %char(p_RTCHUID) + ') '
                    + 'Seq(' + %char(p_RTCHSID) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec    Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         // in Error Check routine we ensure status is 1
         // and no counts have begun to get this far
         exec sql delete from rtchsth
                  where rtchuid = :p_rtchuid
                    and rtchsid = :p_rtchsid;

         exec sql delete from workrtcs
                  where wkswhs=:p_rtchwhse and
                        wksuid = :p_rtchuid and
                        wkscount<>'Y';

         exec sql delete from rtcscpd
                  where rtcswhs=:p_rtchwhse and
                        rtcsuid=:p_rtchuid;

         if sqlstt <> sqlSuccess and sqlstt<>'02000';
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Id(' + %char(p_rtchuid) + ') '
                    + 'Seq(' + %char(p_rtchsid) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
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

730bAd  parmValuec     s            100

      /free

730bA  parmValuec = parmValue;
730bA  if %subst(parmValuec:1:5)='undef';
730bA     parmValue  = *blanks;
730bA  endif;

       monitor;

         select;

           when parmName = 'MODE';
             pSubCmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'RTCHUID';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_rtchuid =  %dec(parmValue: 7: 0);

           when parmName = 'RTCHWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_RTCHWHSE =  %dec(parmValue: 3: 0);

           when parmName = 'RTCHSID';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_rtcHSID =  %dec(parmValue: 3: 0);

           when parmName = 'RTCHUTFLG';
             p_RTCHUTFLG = %trim(parmValue);

           when parmName = 'RTCHTYPE';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_RTCHTYPE =  %dec(parmValue: 2: 0);

         endsl;

       on-error;

         pMessage = 'Error extracting parameter '
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

     * Local Variables

     d parmStr         s            999    varying

      /free

         // Error if first parameter string is blank

         if pParmStr1 = '';
           pMessage = 'Error: Parameter string is empty '
                    + '('
                    + %trimr(#Job) + '/'
                    + %trimr(#JobNbr) + '/'
                    + %trimr(#user)
                    + ')';
           return;
         endif;

         // Extract parms for string 1

         parmStr = %trim(pParmStr1);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 2

         parmStr = %trim(pParmStr2);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 3

         parmStr = %trim(pParmStr3);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi
     d  parmStr                     999    varying

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
       parmStrLen = %len(parmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': parmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(parmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(parmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           pMessage = 'Error: Invalid parameter group '
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
         if pMessage <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e
