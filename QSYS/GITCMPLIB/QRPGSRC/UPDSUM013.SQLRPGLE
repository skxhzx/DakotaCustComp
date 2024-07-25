      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM013  Update SUM013 file
     *             Used by Slot Listing Report
     *
     *  29 Oct 2020
     *  Kenneth Elder
     *
     *  Revisions
     *
740 A*    10/29/20  KDE  7.40
     *      - Created.
     *
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.frmtnm
700bA /copy qcopysrc,p.random2

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#sgc

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     d smrec         E Ds                  Extname(sum013)

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     d errMsg          s             99
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D client          s             10
     D clientloc       s             10

     d NullInds        s              5i 0 dim(1)
     d NullValue       s                   like(NullInds) inz(-1)

     d sqlWheres       s           5000
     d whse            s              3  0
     d whdp            s              5
     d laisle          s              3
     d haisle          s              3
     d lloc            s              3  0
     d hloc            s              3  0
     d side            s              1
     d llvl            s              2  0
     d hlvl            s              2  0
     d vslots          s              1
     d sstat           s              2
     d stype           s              1
     d desg            s              5
     d cat             s             10
     d item            s             15

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d AddRecs         pr
     d DeleteRecs      pr

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pParmStr    String of '|' delimited parameters
     *
     *    Returned Parameters
     *      pOutStr     Return string in JSON format
     *
     *----------------------------------------------------------------

     D updsum013       pr                  extpgm('UPDSUM013')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D updsum013       pi
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
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;

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

         // Delete existing records for session id

         DeleteRecs();

         // Extract parameters from delimited string

         ExtractParms();

         pOutStr = '{'
                 +    '"perrMsg":"' + errMsg + '"'
                 + '}';

         // Get out if error

         if errMsg <> '';
           pOutStr = '{"errMsg":"' + errMsg + '"}';
           WrtDebugError();
           return;
         endif;

         AddRecs();

         return;

      /end-free

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

         getclient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddRecs   Add records
     *----------------------------------------------------------------

     p AddRecs         b
     d AddRecs         pi

     *  Local Variables

     D wkITem          s             15

      /free

        sqlStmt = 'select ' + sq + ' ' + sq +
                  '       ,slwhse,slwhdp,sldisp,slstat,slstyp,slpick,' +
                  '       slsdef,sldesg,char(slentd),char(slexpd),slitem,' +
                  '       ifnull(itdesc,' + sq + ' ' + sq + '),' +
                  '       ifnull(itpdsc,' + sq + ' ' + sq + '),' +
                  '       CVTAVL53(slstk1,slstk2,slstk3,slalc1,' +
                  '       slalc2,slalc3,slpck1,slpck2,slpck3),' +
                  '       ifnull(lalcns,' + sq + ' ' + sq + '),' +
                  '       char(ifnull(laentd,0))' +
                  '       ,char(ifnull(laexpd,0)),' +
                  '       CVTQT555(ifnull(LAQTY1,0),ifnull(laqty2,0),' +
                  '       ifnull(LAQTY3,0)),ifnull(lnlot,' + sq + ' ' + sq + ')'
                + '       ,ifnull(itven#,0),' +
                  '       ifnull(imvnam,' + sq + ' ' + sq + '),' +
                  '       ifnull(itcube,0),current timestamp' +
                  '   from slot left outer join piritem on slwhse=itwhse and ' +
                  '        slitem=ititem left outer join licactive on' +
                  '        slwhse=lawhse and slwhdp=lawhdp and sldisp=ladisp' +
                  '        left outer join itemfld on slwhse=ifwhse and' +
                  '        slitem=ifitem left outer join itemmsc on slwhse='+
                  '        imwhse and slitem=imitem left outer join licinfo' +
                  '        on laolcns=lnlcns where slitem=slitem';
        // Add where clause based on passed parms
        // Department
        if whdp<>*blanks;
          sqlstmt = %trim(sqlstmt) + ' and slwhdp=' + sq + whdp + sq;
        endif;
        // From Aisle
        if laisle<>*blanks;
          sqlstmt = %trim(sqlstmt) + ' and slaisl>=' + sq + laisle + sq;
        endif;
        // To Aisle
        if haisle<>*blanks;
          sqlstmt = %trim(sqlstmt) + ' and slaisl<=' + sq + haisle + sq;
        endif;
        // From Location
        if lloc<>*zeros;
          sqlstmt = %trim(sqlstmt) + ' and slloc>=' + %char(lloc);
        endif;
        // To Location
        if hloc<>*zeros;
          sqlstmt = %trim(sqlstmt) + ' and slloc<=' + %char(hloc);
        endif;
        // Side
        select;
          when side='0';
            sqlstmt = %trim(sqlstmt) + ' and slside=0';
          when side='1';
            sqlstmt = %trim(sqlstmt) + ' and slside=1';
        endsl;
        // From Level
        if llvl<>*zeros;
          sqlstmt = %trim(sqlstmt) + ' and slrlvl>=' + %char(llvl);
        endif;
        // To Level
        if hlvl<>*zeros;
          sqlstmt = %trim(sqlstmt) + ' and slrlvl<=' + %char(hlvl);
        endif;
        // Virtual slots only
        select;
          when vslots='V';
            sqlstmt = %trim(sqlstmt) + ' and (select count(*) from' +
                      ' vslot where slwhse=vswhse and sldisp=vspdis)>0';
        endsl;
        // Slot Type
        select;
          when stype='Y';
            sqlstmt = %trim(sqlstmt) + ' and slpick=' + sq + 'Y' + sq;
          when stype='N';
            sqlstmt = %trim(sqlstmt) + ' and slpick=' + sq + 'N' + sq;
        endsl;
        // Status
        if sstat<>*blanks;
          sqlstmt = %trim(sqlstmt) + ' and slstat=' + sq + sstat + sq;
        endif;
        // Designation
        if desg<>*blanks;
          sqlstmt = %trim(sqlstmt) + ' and sldesg=' + sq + desg + sq;
        endif;
        // Category
        if cat<>*blanks;
          sqlstmt = %trim(sqlstmt) + ' and ifcat=' + sq + cat + sq;
        endif;
        // Item
        if item<>*blanks;
          sqlstmt = %trim(sqlstmt) + ' and ititem=' + sq + item + sq;
        endif;

        exec sql prepare sltStmt from :SqlStmt;
        exec sql declare sltCsr cursor for sltStmt;
        exec sql open sltCsr;

        dow forever = forever;

          exec sql fetch next from sltCsr
                   into :smrec;

          if sqlstt <> sqlSuccess and sqlstt<>'01004';
            leave;
          endif;

          // write Empty Pick Slot first
          smsessid=pSessid;
          if smentd<>*blanks and %subst(smentd:1:1)<>'0';
            monitor;
            smentd=%subst(%trim(smentd):5:2) + '/' +
                   %subst(%trim(smentd):7:2) + '/' +
                   %subst(%trim(smentd):3:2);
            on-error;
            endmon;
          endif;
          if smexpd<>*blanks and %subst(smexpd:1:1)<>'0';
            monitor;
            smexpd=%subst(%trim(smexpd):5:2) + '/' +
                   %subst(%trim(smexpd):7:2) + '/' +
                   %subst(%trim(smexpd):3:2);
            on-error;
            endmon;
          endif;
          if smlentd<>*blanks and %subst(smlentd:1:1)<>'0';
            monitor;
            smlentd=%subst(%trim(smlentd):5:2) + '/' +
                   %subst(%trim(smlentd):7:2) + '/' +
                   %subst(%trim(smlentd):3:2);
            on-error;
            endmon;
          endif;
          if smlexpd<>*blanks and %subst(smlexpd:1:1)<>'0';
            monitor;
            smlexpd=%subst(%trim(smlexpd):5:2) + '/' +
                   %subst(%trim(smlexpd):7:2) + '/' +
                   %subst(%trim(smlexpd):3:2);
            on-error;
            endmon;
          endif;
          smaddts = %timestamp();
          exec sql insert into SUM013
          (SMSESSID,SMWHSE,SMWHDP,SMDISP,SMSTAT,SMSTYP,SMPICK,SMDEF,SMDESG,
           SMENTD,SMEXPD,SMITEM,SMDESC,SMPDSC,SMQAVL,SMLCNS,SMLENTD,SMLEXPD,
           SMLQTY,SMLOT,SMVEN#,SMVNAM,SMCUBE,SMADDTS)
          VALUES
          (:SMSESSID,:SMWHSE,:SMWHDP,:SMDISP,:SMSTAT,:SMSTYP,:SMPICK,:SMDEF,
           :SMDESG,:SMENTD,:SMEXPD,:SMITEM,:SMDESC,:SMPDSC,:SMQAVL,:SMLCNS,
           :SMLENTD,:SMLEXPD,:SMLQTY,:SMLOT,:SMVEN#,:SMVNAM,:SMCUBE,:SMADDTS);

        enddo;
        exec sql close sltCsr;

      /end-free


     p AddRecs         e

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from sum013
                 where smsessid = :pSessId or
                       smaddts < current timestamp - 360 MINUTES;

      /end-free

     p DeleteRecs      e

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

           when parmName = 'whse';
             if parmValue = '';
               parmValue = '0';
             endif;
             whse =  %dec(parmValue: 3: 0);

           when parmName = 'whdp';
             whdp = parmValue;
             whdp = %xlate(xlower: xupper: whdp);

           when parmName = 'laisle';
             laisle = parmValue;
             laisle = %xlate(xlower: xupper: laisle);

           when parmName = 'haisle';
             haisle = parmValue;
             haisle = %xlate(xlower: xupper: haisle);

           when parmName = 'lloc';
             if parmValue = '';
               parmValue = '0';
             endif;
             lloc =  %dec(parmValue: 3: 0);

           when parmName = 'hloc';
             if parmValue = '';
               parmValue = '0';
             endif;
             hloc =  %dec(parmValue: 3: 0);

           when parmName = 'side';
             side = parmValue;
             side = %xlate(xlower: xupper: side);

           when parmName = 'llvl';
             if parmValue = '';
               parmValue = '0';
             endif;
             llvl =  %dec(parmValue: 3: 0);

           when parmName = 'hlvl';
             if parmValue = '';
               parmValue = '0';
             endif;
             hlvl =  %dec(parmValue: 3: 0);

           when parmName = 'vslots';
             vslots = parmValue;
             vslots = %xlate(xlower: xupper: vslots);

           when parmName = 'stype';
             stype = parmValue;
             stype = %xlate(xlower: xupper: stype);

           when parmName = 'sstat';
             sstat = parmValue;
             sstat = %xlate(xlower: xupper: sstat);

           when parmName = 'desg';
             desg = parmValue;
             desg = %xlate(xlower: xupper: desg);

           when parmName = 'cat';
             cat = parmValue;
             cat = %xlate(xlower: xupper: cat);

           when parmName = 'item';
             item = parmValue;
             item = %xlate(xlower: xupper: item);

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
