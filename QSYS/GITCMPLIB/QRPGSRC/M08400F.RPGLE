      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M08400F  Perform color updates for Category and Class
     *  17 February 2020
     *  Kenneth Elder
     *
     *  Revisions:
     *
740 A*    02/17/20  KDE  7.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     fitemcat   if   e           k disk
     Fitemcls   if   e           k disk
     Fclass     if   e           k disk
     Fpircolorsduf a e           k disk
     Fpircolorshuf a e           k disk

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

     D  pWhse          s              3p 0
     d  pclraction     s             10
     d  pclrset        s             10
     D  pclrtype       s             10
     D  pclrcode       s             10
     D  pclrcolor      s              7
     D  pclrsetdsc     s             30

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d forever         s               n
     d dpCombo         s             20

     D dbgflgExists    s               n
     D debug           s               n
     d errmsg          s             80

720 Ad dragGroup       s              1
720 Ad dragRtid        s              5
720 AD dragRow         s              3  0
720 AD dragCol         s              2  0
720 AD dropGroup       s              1
720 AD dropRow         s              3  0
720 AD dropCol         s              2  0
720 AD rtnCode         s             10
720 AD rtnMsg          s            100

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D m08400f         pr                  extpgm('M08400F')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D m08400f         pi
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

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

720 AD dd410           pr                  extpgm('DD410')
720 AD  pCmd                         10    const
720 AD  pWhse                         3p 0
720 AD  pRtid                         5
720 AD  pGroup                        1
720 AD  pRow                          3p 0
720 AD  pCol                          2p 0
720 AD  pRtnCode                     10
720 AD  pRtnMsg                     100

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pclrSet     Color Set
     *      pclrType    Color Type
     *      pclrCode    Color Code
     *      pclrColor   Color
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *
     *----------------------------------------------------------------

      /free

        errmsg=*blanks;
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

         // Extract parameters from delimited string

         ExtractParms();

         // Get out if error
         if errMsg <> '';
           pOutStr = '{"clrcod":"' + pclrcode + '",' +
                      '"errMsg":"' + errMsg + '"}';
           WrtDebugError();
           return;
         endif;

         // Mainline
         select;
           // return existing color code for Category
           when pclrtype='CAT' and pclraction='RTV';
             chain (pWhse:pclrtype:pclrset:pclrcode) pircolorsd;
             if %found(pircolorsd);
               // update color
               pclrcolor=clrdcolor;
             else;
               pclrcolor=*blanks;
             endif;
           // return existing color code for Class
           when pclrtype='CLS' and pclraction='RTV';
             chain (pWhse:pclrtype:pclrset:pclrcode) pircolorsd;
             if %found(pircolorsd);
               // update color
               pclrcolor=clrdcolor;
             else;
               pclrcolor=*blanks;
             endif;

           // Create/Update Color Code for Category
           when pclrtype='CAT' and pclraction='UPD';
             chain (pWhse:pclrtype:pclrset:pclrcode) pircolorsd;
             if %found(pircolorsd);
               // update color
               clrdcolor=pclrcolor;
               if %trim(clrdcolor)='';
                 delete clrdrec;
               else;
                 update clrdrec;
               endif;
             else;
               // otherwise add to detail color file
               clrdwhse = pWhse;
               clrdset=pclrset;
               clrdtype=pclrtype;
               clrdcode=pclrcode;
               clrdcolor=pclrcolor;
               write clrdrec;
             endif;
             chain (pWhse:pclrtype:pclrset) pircolorsh;
             if not %found(pircolorsh);
               // Create Color Heaer record from not found
               clrhwhse=pwhse;
               clrhtype=pclrtype;
               clrhset=pclrset;
               clrhdesc=pclrsetdsc;
               write clrhrec;
             else;
               // if no other detail for this header then delete header
               setll (pWhse:pclrtype:pclrset) pircolorsd;
               reade (pWhse:pclrtype:pclrset) pircolorsd;
               if not %equal(pircolorsd);
                 monitor;
                   delete pircolorsh;
                 on-error;
                 endmon;
               endif;
             endif;
             exsr updColors;

           // Create/Update Color Code for Class
           when pclrtype='CLS' and pclraction='UPD';
             chain (pWhse:pclrtype:pclrset:pclrcode) pircolorsd;
             if %found(pircolorsd);
               // update color
               clrdcolor=pclrcolor;
               if %trim(clrdcolor)='';
                 delete clrdrec;
               else;
                 update clrdrec;
               endif;
             else;
               // otherwise add to detail color file
               clrdwhse = pWhse;
               clrdset=pclrset;
               clrdtype=pclrtype;
               clrdcode=pclrcode;
               clrdcolor=pclrcolor;
               write clrdrec;
             endif;
             chain (pWhse:pclrtype:pclrset) pircolorsh;
             if not %found(pircolorsh);
               // Create Color Heaer record from not found
               clrhwhse=pwhse;
               clrhtype=pclrtype;
               clrhset=pclrset;
               clrhdesc=pclrsetdsc;
               write clrhrec;
             else;
               // if no other detail for this header then delete header
               setll (pWhse:pclrtype:pclrset) pircolorsd;
               reade (pWhse:pclrtype:pclrset) pircolorsd;
               if not %equal(pircolorsd);
                 monitor;
                   delete pircolorsh;
                 on-error;
                 endmon;
               endif;
             endif;
             exsr updColors;
         endsl;

         // Build JSON string to return

         pOutStr = '{'
                 +  '"errmsg":"' + %trim(errmsg) + '",'
                 +  '"clrcod":"' + %trim(pclrcolor) + '"}';

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

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  updColors  -  Update DD2 Colors
     *----------------------------------------------------------------

      /free
       begsr updColors;
720 A
720 A    // Update Colors for Route Detail
720 A
720 A    dragRtid = *blanks;
720 A    dragGroup = *blanks;
720 A    dragRow = 0;
720 A    dragCol = 0;
720 A    rtnCode = *blanks;
720 A    rtnMsg = *blanks;
720 A
720 A    if pclrType = 'COMP'
740 A       or pclrType = 'CAT'
740 A       or pclrType = 'CLS';
720 A       dd410 ('*COLORS': pWhse: dragRtid: dragGroup: dragRow: dragCol:
720 A              rtnCode: rtnMsg);
720 A    endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzinz  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr zzinz;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtDebugParms  Write out debug parm record
     *----------------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = 'sID:' + %trimr(pSessid) + ', '
                  + 'Cmd:' + %trimr(pclrtype) + ', '
                  + 'Whs:' + %char(pWhse) + ', '
                  + 'Rtid:' + %trimr(pclrcode) + ', '
                  + 'Usr=' + %trimr(pUser)
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

           when parmName = 'whs';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'clraction';
             pclraction = %xlate(xlower: xupper: %trim(parmValue));

           when parmName = 'clrset';
             pclrset = %trim(parmValue);
             pclrset = %xlate(xlower: xupper: %trim(parmValue));

           when parmName = 'clrtyp';
             pclrtype = %trim(parmValue);
             pclrtype = %xlate(xlower: xupper: %trim(parmValue));

           when parmName = 'clrcod';
             pclrcode = %trim(parmValue);
             pclrcode = %xlate(xlower: xupper: %trim(parmValue));

           when parmName = 'clrcolor';
             pclrcolor = %trim(parmValue);
             pclrcolor = %xlate(xlower: xupper: %trim(parmValue));

           when parmName = 'clrsetdsc';
             pclrsetdsc = %trim(parmValue);
             pclrsetdsc = %xlate(xlower: xupper: %trim(parmValue));

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

