      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM022  Update SUM022 file
     *             Used by Shipping Log from Truckbuilder
     *
     *  01 Feb 2024
     *  Kenneth Elder
     *
     *  Revisions
     *
770 A*    02/01/24  KDE  7.70
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fsum022    uf a e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.frmtnm
      /copy qcopysrc,p.random2

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#citylin

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

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

     d ddTaskGoal      s               n

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D cntEmpTran      s              3p 0
     D cntEmpTrand     s              3p 0
     d groupStamp      s               z
     d pfDateTime      s             14
     d ptDateTime      s             14
     d pRptType        s             10

     D client          s             10
     D clientloc       s             10

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     d NullInds        s              5i 0 dim(1)
     d NullValue       s                   like(NullInds) inz(-1)

     d sqlstmtx        s           5000
     d pprmstr         s           1024    varying
     d psmrtn          s           1024    varying
     d rtnNotVarying   s           1024
     d wkwhse          s              3  0
     d wklbl#          s              7  0

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40    varying
     d  pWhse          s              3p 0
     d  prtid          s              5
     d  pcord          s             15
     d  pcpo           s             15
     d  pcust#         s             30
     d  pUser          s             10    varying
     d  pDict          s             10    varying
     d  pPgm           s             10    varying
     D  pparmStr1      s            999    varying
     D  pOutStr        s            999    varying

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
     d  parmStr                     999    varying

     D sleep           pr            10u 0 extproc('sleep')
     D   Interval                    10u 0 value

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pParmStr1   Parm String
     *
     *    Returned Parameters
     *      pOutStr     Return json String
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pDict
     c                   parm                    pPgm
     c                   parm                    pParmStr1
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = ' ';

        // Extract parameters from delimited string

        ExtractParms();

         groupStamp = %timestamp();

         // Delete existing records for session id

         DeleteRecs();

         // Add work records
         AddRecs();

        // Return Json String
        if pErrMsg <> *blanks;
          pOutStr = '{"errMsg":"' + %trim(pErrMsg) + '"}';
        else;
          pOutStr = '{"errMsg":"*OK"}';
        endif;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddRecs   Add records
     *----------------------------------------------------------------

     p AddRecs         b
     d AddRecs         pi

     *  Local Variables

     d rhrte           s              5

      /free

          // Build SQL statement to retrieve label and secondary information
          SqlStmtx= 'select imvnam,lbitem,itdesc,imbrnd,lnlot,ohmisc,'
                  +   'lnaddts,ohcpo,lbrte,lllcns,llaqty1,llaqty2,llaqty3,'
                  +   'lnentdate,lnenttype,lbwhse,lblbl# '
                  +   'from label,ordh,liclog,licinfo,itemmsc,piritem '
                  +   'where lbwhse=ohwhse and lbord=ohord and '
                  +   'lbwhse=llwhse and lblbl#=lllbl# and '
                  +   'lbwhse=lnwhse and llolcns=lnlcns and '
                  +   'lbwhse=imwhse and lbitem=imitem and '
                  +   'lbwhse=itwhse and lbitem=ititem and '
                  +   'lbgrp1=' + sq + 'S' + sq + ' and (lbtype='
                  +   sq + 'O' + sq + 'or lbtype=' + sq + 'B' + sq
                  +   ') and llaction=' + sq + 'SEL' + sq + ' and '
                  +   ' (lnseq=1 or lnseq is null)';

          // filter by route id if passed in
          if prtid<>' ';
            sqlstmtx = %trim(sqlstmtx) + ' and lbrte=' + sq +
                       %trim(prtid) + sq;
          endif;

          // filter by customer po if sent in
          if pcpo<>' ';
            sqlstmtx = %trim(sqlstmtx) + ' and ohcpo=' + sq +
                       %trim(pcpo) + sq;
          endif;

          // filter by customer number if sent in (ORDH and/or ORDHEXA)
          if %len(pcust#)>0 and pcust#<>' ';
            if %check('0123456789':%trim(pcust#))=0;
              sqlstmtx = %trim(sqlstmtx) + ' and (ohcust=' +
                         %trim(pcust#);
              sqlstmtx = %trim(sqlstmtx) + ' or (select count(*) from ordhexa'
                       + ' where ohawhse=lbwhse and ohaord=lbord and '
                       + 'ohacusta=' + sq + %trim(pcust#) + sq + ')>0)';
            else;
              sqlstmtx = %trim(sqlstmtx) + ' and (select count(*) from ordhexa'
                       + ' where ohawhse=lbwhse and ohaord=lbord and '
                       + 'ohacusta=' + sq + %trim(pcust#) + sq + ')>0';
            endif;
          endif;

          // filter by customer ord# if sent in (ORDH and/or ORDHEXA)
          if %len(pcord)>0 and pcord<>' ';
            if %check('0123456789':%trim(pcord))=0;
              sqlstmtx = %trim(sqlstmtx) + ' and (ohcord=' +
                         %trim(pcord);
              sqlstmtx = %trim(sqlstmtx) + ' or (select count(*) from ordhexa'
                       + ' where ohawhse=lbwhse and ohaord=lbord and '
                       + 'ohaorda=' + sq + %trim(pcord) + sq + ')>0)';
            else;
              sqlstmtx = %trim(sqlstmtx) + ' and (select count(*) from ordhexa'
                       + ' where ohawhse=lbwhse and ohaord=lbord and '
                       + 'ohaorda=' + sq + %trim(pcord) + sq + ')>0';
            endif;
          endif;

          exec sql prepare lb from :SqlStmtx;
          exec sql declare lblic cursor for lb;
          exec sql open lblic;

          dow forever = forever;

            exec sql fetch next from lblic
                     into :smvnam, :smitem, :smidsc, :smbrnd, :smlot, :smmisc,
                          :smlnaddts, :smcpo,:smrtid,:smlcns,:smaqty1x,
                          :smaqty2x, :smaqty3x, :smentdate, :smenttype,
                          :wkwhse, :wklbl#;

            if sqlstt <> sqlSuccess;
              leave;
            endif;

            // make sure it matches customer if passed
            // setup parm string with warehouse and label
          pprmstr = 'whs=' + %editc(wkwhse:'X') + '|lbl=' + %editc(wklbl#:'X');
     c                   call      'GETCUSINF'
     c                   parm                    psessid
     c                   parm                    puser
     c                   parm                    pdict
     c                   parm                    ppgm
     c                   parm                    pprmstr
     c                   parm                    psmrtn

            rtnNotvarying = psmrtn;
            smcordx = %subst(rtnNotvarying:1:15);
            smcusn = %subst(rtnNotvarying:16:30);
            if pcust# <> ' ' and pcust# <> smcusn;
              iter;
            endif;

            // once running and building UPDSUM022 correctly then add code
            // to manipulate several fields like SMMISC etc..,
            smsessid = psessid;
            smwhse = wkwhse;
            write smrec;

          enddo;
          exec sql close lblic;

      /end-free

     p AddRecs         e

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from sum022
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
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'rtid';
             pRtid =  parmValue;

           when parmName = 'cord';
             pcord =  parmValue;

           when parmName = 'cpo';
             pCpo =  parmValue;

           when parmName = 'custnum';
             pCust# =  parmValue;

         endsl;

       on-error;

         pErrMsg  = 'Error extracting parameter '
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
           pErrMsg  = 'Error: Parameter string is empty '
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

         if pErrMsg  <> '';
           return;
         endif;

         if pErrMsg  <> '';
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
           pErrMsg  = 'Error: Invalid parameter group '
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
         if pErrMsg  <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e
