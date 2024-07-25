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
     *  M30700    Customer Flags Maintenance
     *  06 May 2020
     *  Kenneth Elder
     *

     *----------------------------------------------------------------
     *  Revisions
     *
730 A*    05/06/20  KDE  7.40
     *      - Created
740aA*    12/05/20  KDE  7.40a
     *      - Fix where it is not allowing you to enter all values.
     *        Requires data area NXTCUST
     *        NXTCUST is locked prior to GETCUST and released after writing
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------
740aAFcustmast  uf a e           k disk

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
      /copy qcopysrc,p.excustmast
      /copy qcopysrc,p.exitemord
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
740aAd nxtcust         s              1    dtaara
     d lenchar         s              5  0
     d lpos            s              5  0
     d newDir          s            300
740aAd addcustxa       s               n
     d pcmd            s             10
     d p_cmwhse        s              3  0
     d p_cmcust        s             11  0
     d p_cmspflg       s              1
740aAd p_cmname        s             40
740aAd p_cmcad1        s             40
740aAd p_cmcad2        s             40
740aAd p_cmcusta       s             20
740aAd p_cmccty        s             20
740aAd p_cmcst         s              2
740aAd p_cmczip        s             10
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
740aA     addcustxa=*off;
740aA     if p_cmcust=0;
            // Return with error if Alpha customer exist, yet 0 numeric
            count=0;
            exec sql select count(*) into :count
                from custmast where cmwhse=:p_cmwhse and
                                    cmcusta=:p_cmcusta;
            if sqlstt = sqlSuccess and count>0;
              pMessage = 'Alpha Customer already exist.  Please' +
                         ' change alpha customer number and re-submit';
              return;
            endif;
740aA       addcustxa=*on;
740aA       // get next available customer number
740aA       exsr lockCust;
740aA       exec sql
740aA          select cst.cmcust + 1 into :p_cmcust
740aA            FROM custmast as cst
740aA           LEFT JOIN custmast AS alt
740aA            ON alt.cmwhse = cst.cmwhse
740aA           and  alt.cmcust = cst.cmcust + 1
740aA             WHERE alt.cmcust IS NULL and cst.cmwhse=:p_cmwhse
740aA         fetch first row only;
740aA     endif;
           // get record for customer to update flags
740 A    exWhse = p_cmwhse;
740 A    excustmast ('*GET': exRtnCode: exRtnMsg: exWhse: p_cmcust:
740 A                cmaaudflg: cmaaudexpd: cmspflg);
740 A
740 A    if exRtnCode = '*OK';
740 A      // when record was found then do update
740 A      excustmast ('*CHANGE': exRtnCode: exRtnMsg: exWhse: p_cmcust:
740 A                  cmaaudflg: cmaaudexpd: p_cmspflg);
740 A    else;
740 A      cmaaudflg='N';
740 A      cmaaudexpd=*zeros;
740 A      // perform insert when not found
740 A      excustmast ('*ADD': exRtnCode: exRtnMsg: exWhse: p_cmcust:
740 A                  cmaaudflg: cmaaudexpd: p_cmspflg);
740 A    endif;
740aA    monitor;
740aA      out(e) nxtCust;
740aA    on-error;
740aA    endmon;
740aA
740aA    // Update any customer master data as required
740aA    if addcustxa;
740aA       // Perform addition
740aA       cmwhse=p_cmwhse;
740aA       cmcust=p_cmcust;
740aA       cmcusta=p_cmcusta;
740aA       cmname=p_cmname;
740aA       cmcad1=p_cmcad1;
740aA       cmcad2=p_cmcad2;
740aA       cmccty=p_cmccty;
740aA       cmcst=p_cmcst;
740aA       cmczip=p_cmczip;
740aA       cmstat='A';
740aA       cmaddts=%timestamp();
740aA       cmupdts=%timestamp();
740aA       cmjob=#job;
740aA       cmuser=#user;
740aA       cmjobnbr=#jobnbr;
740aA       write custrec;
740aA    else;
740aA      // update customer alpha and name
740aA      chain (p_cmwhse:p_cmcust) custmast;
740aA      if %found(custmast);
740aA        if p_cmname<>cmname and p_cmname<>*blanks;
740aA          cmname=p_cmname;
740aA        endif;
740aA        if p_cmcusta<>cmcusta and p_cmcusta<>*blanks;
740aA          cmcusta=p_cmcusta;
740aA        endif;
740aA        update custrec;
740aA      endif;
740aA    endif;
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

       endsr;

740aA    // Routine to Lock Customer Data Area to
740aA    // force the GETCUST to be single threaded.
740aA    // The lock should be called prior to GETCUST
740aA    // when doing an update command and after the
740aA    // write or update to ORDH with the OHCUST
740aA    // and OHCORD
740aA    begsr lockCust;
740aA       *in99=*on;
740aA       dow *in99=*on;
740aA         monitor;
740aA           in(e) *lock nxtcust;
740aA         on-error;
740aA           *in99=*off;
740aA         endmon;
740aA         // if no error on locking nxtcust it
740aA         // will turn off in99 and fall out,
740aA         // otherwise it will loop until it
740aA         // can lock the data area
740aA         *in99=%error;
740aA       enddo;
740aA    endsr;
740aA /end-free

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

       begsr getCurrStamp;
740aA /free

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

     d  parmValuec     s            100

      /free

       monitor;

         select;

           when parmName = 'CMWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_CMWHSE =  %dec(parmValue: 3: 0);

           when parmName = 'CMCUST';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_CMCUST =  %dec(parmValue: 11: 0);

           when parmName = 'CMSPFLG';
             p_CMSPFLG =  parmValue;
740aA
740aA      when parmName = 'CMNAME';
740aA        p_CMNAME =  parmValue;
             p_CMNAME = %xlate(xlower: xupper: p_CMNAME);
740aA
740aA      when parmName = 'CMCUSTA';
740aA        p_CMCUSTA =  parmValue;
             p_CMCUSTA = %xlate(xlower: xupper: p_CMCUSTA);
740aA
740aA      when parmName = 'CMCAD1';
740aA        p_CMCAD1 =  parmValue;
             p_CMCAD1 = %xlate(xlower: xupper: p_CMCAD1);
740aA
740aA      when parmName = 'CMCAD2';
740aA        p_CMCAD2 =  parmValue;
             p_CMCAD2 = %xlate(xlower: xupper: p_CMCAD2);
740aA
740aA      when parmName = 'CMCCTY';
740aA        p_CMCCTY =  parmValue;
             p_CMCCTY = %xlate(xlower: xupper: p_CMCCTY);
740aA
740aA      when parmName = 'CMCST';
740aA        p_CMCST =  parmValue;
             p_CMCST = %xlate(xlower: xupper: p_CMCST);
740aA
740aA      when parmName = 'CMCZIP';
740aA        p_CMCZIP =  parmValue;
740aA
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
