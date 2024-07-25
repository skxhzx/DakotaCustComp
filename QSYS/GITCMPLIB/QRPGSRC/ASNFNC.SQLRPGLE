      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  ASNFNC -  Misc. calls for GUI Asn Functions
     *  01 June 2020
     *  Kenneth Elder
     *
     *  Revisions:
     *
740 A*    06/01/20  KDE  7.40
     *      - Created.
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

     d/copy qcopysrc,c#pgminfds
     d/copy qcopysrc,c#stdvar
     d/copy qcopysrc,c#stdsql

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     D parec         E Ds                  Extname(PoAsn)
     d phrec         E Ds                  Extname(PoHdr)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     d errMsg          s             99
     d dpCombo         s             20    varying
     d whse            s              3  0
     d lpncnt          s              3  0
     d cmd             s             10
     d item            s             15
     d po              s             22
     d seq             s              5  0
     d superYN         s              1
     d uci             s            100    varying
     d plpn            s             75
     d dasn            s            512
     d rtnUrl          s            750
     d sessid          s             40
     d superpo         s              9
     d m13500          s             20
     d poList          s            200
740 Ad asnpo           s             22
740 Ad asnseq          s              5  0
740 Ad asnitm          s             15
     d asnupc          s             20
     d asnmfgdte       s              8  0
     d asnexpdte       s              8  0
     d asnlot          s             30
     d asnlpn          s             48
740 Ad pos             s              5  0
740 Ad relpos          s              5  0
740 Ad prvpos          s              5  0

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

     D asnfnc          pr                  extpgm('ASNFNC')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D asnfnc          pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D r136001         pr                  extpgm('R136001')
     D  iUci                        100    varying
     D  iWhse                         3  0
     D  iPo                           9
     D  iSuper                        1
     D  iSessId                      40
     D  iLpn                         75
     D  iOutStr                    1024    varying

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

     d i272xx          pr            20
     d m136xx          pr            20
     d m158xx          pr            20

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         errMsg = ' ';

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

         // **** FOR TESTING ****
         debugAfter = *on;

         // Combine dictionary/program

         dpCombo = %trim(pDict) + '.' + pPgm;

         // Write out 'Before' Debug info

         if debugBefore;
           debugLoc = 'B';
           wrtBeforeDebug();
         endif;

         // Extract parameters from delimited string

         ExtractParms();

         pOutStr = '{'
                 +    '"errMsg":"' + errMsg + '"'
                 + '}';

         // Get out if error

         if errMsg <> '';
           pOutStr = '{"errMsg":"' + errMsg + '"}';
           WrtDebugError();
           return;
         endif;

         sessid = pSessid;
         exsr processRqs;

         pOutStr = '{'
                 +    '"errMsg":"' + errMsg + '"'
                 + '}';

         // Write out 'After' Debug info

         if debugAfter;
           debugLoc = 'A';
           wrtAfterDebug();
         endif;

         return;

      /end-free

     *----------------------------------------------------------------
     *  processRqs - Process misc., request
     *----------------------------------------------------------------

      /free
       begsr processRqs;

          select;
            when cmd = '*asnentry';
              // only called from I272xx.  This is when a specific po/seq/item
              // has more than one entry in the POASN file.  This would imply
              // either different dates, or lot code
              exsr getDirectAsn;
            when cmd = '*chkrtn';
              // only called from I272xx.  This is called to determine whether
              // a completion should reroute back to I272xx (meaning more lots
              // and/or dates exist for same lpn/item, M135xx (meaning more items
              // remain for the lpn than the current item), or M134xx (meaning
              // no more open items/asn entries remain open for lpn)
              exsr determineRtn;
            when cmd = '*lstspo';
              exec sql select * into :parec
                   from poasn
                where pawhse=:whse and palpn=:plpn
                      and palcns=' '
                 fetch first row only;
            if sqlstt = sqlSuccess;
              // Build url to display po's and items to receive
              M13500 = 'BFCDAKOTA.M13500';
              exec sql select gmipgm into :m13500
                    from glomenuitm
                  where gmiid='BFCDAKOTA.M13500'
                    fetch first row only;
              // get super po if found
              exec sql select puspo into :superpo
                     from pospo
                where puwhse=:whse and pupo=:papo and puedte=0
                 fetch first row only;
              if sqlStt = sqlSuccess;
                // super po found
                rtnUrl = %trim(m13500) + 's?slnk=1&PDWHSE=' + %char(whse) +
                         '&PDSUPERPO=' + %trim(superpo) + '&CALCULA008=' +
                          %trim(superpo) + '&POSTAT=';
              else;
                // no super po, just send po
                rtnUrl = %trim(m13500) + 's?slnk=1&PDWHSE=' + %char(whse) +
                         '&PDPO=' + %trim(papo) + '&POSTAT=';
              endif;
              exec sql select * into :phrec
                       from pohdr
                    where phwhse=:whse and phpo=:papo
                     fetch first row only;
              if sqlstt <> sqlSuccess;
                phstat='0';
              endif;
              select;
                when phstat = '0';
700eM             rtnUrl = %trim(rtnUrl) + '0=Open';
                when phstat = '1';
700eM             rtnUrl = %trim(rtnUrl) + '1=Partial receipt';
                when phstat = '2';
700eM             rtnUrl = %trim(rtnUrl) + '2=Received in full';
                when phstat = '3';
700eM             rtnUrl = %trim(rtnUrl) + '3=Ready for export';
                when phstat = '4';
700eM             rtnUrl = %trim(rtnUrl) + '4=Partial export';
               when phstat = '5';
700eM             rtnUrl = %trim(rtnUrl) + '5=Import error';
              endsl;
              if pLpn <> *blanks;
                rtnUrl = %trim(rtnUrl) + '&CALCULA015=' + %trim(pLpn);
              endif;

              // retrieve record from poasn for lpn if passed.  If this is
              // success it means there was only one record and we will
              // pass in direct item information to R136001 to setup data
              // overrides for M136xx and go directly there from M134xx
              exec sql select * into :parec from poasn
                      where pawhse=:whse and palpn=:plpn and palcns=' ';
              if sqlstt = sqlSuccess;
                pOutStr='ASNFNC';
                SuperYN='N';
                uci = 'DITEM|' + %trim(papo) + '|' + %char(paseq) + '|' +
                      %trim(paitem) + '|';
                exsr correctURL;
              else;
                // coming here means POASN has more than one record for LPN.
                // DORASNFNC is only called from M134xx which means they only
                // scanned the LPN. More than one POASN record could indicate
                // multiple dates and/or lots for one item or it could mean
                // multiple items.  If multiple dates/lots for same items we
                // will call I272xx to allow user to pick which one they are
                // receiving.  However, if there are multiple items we start
                // by displaying M135xx to scan or select the correct item.
                exec sql select count(*) into :lpncnt from
                        (select paitem,count(*) from poasn where
                           palpn=:pLpn and palcns=' '
                           group by paitem) as derived;
                if sqlStt=sqlSuccess and lpncnt = 1;
                  // since multiple poasn records existed from above and
                  // this sql says there is only one item we will prompt
                  // with I272xx to show multiple dates/lots
                  rtnUrl= %trim(i272xx()) + 's?slnk=1&PALPN='
                          + %trim(palpn) + '&PAITEM=' + %trim(paitem);
                          pOutStr = '{"rtnUrl":"' + %trim(rtnUrl) + '"}';
                  return;
                else;
                  // Since we know there were multiple records from first sql
                  // up above and we know there is more than one item from
                  // the sql in the other side of else right above we need
                  // to display M135xx
                  pOutStr = '{"rtnUrl":"' + %trim(rtnUrl) + '"}';
                  return;
                endif;
              endif;
            else;
              // return either no open or invalid lpn
              exec sql select * into :parec
                        from poasn
                     where pawhse=:whse and palpn=:plpn
                      fetch first row only;
              if sqlstt = sqlSuccess;
                errmsg = 'No open entries remain for LPN ' + %trim(pLpn);
              else;
                errmsg = 'Invalid LPN (' + %trim(pLpn) + ') scanned';
              endif;
              pOutStr = '{'
                  +    '"errMsg":"' + errMsg + '"'
                  + '}';
                 return;
            endif;

            when cmd='*getlpn';
              // return either lpn found in poasn or return blank
              poutstr=*blanks;
              exec sql select palpn into :poutstr
                       from poasn
                  where pawhse=:whse and papo=:po and paseq=:seq
                           and paitem=:item and palpn=:plpn
                           and palcns=' '
                    fetch first row only;
             return;
          endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getDirectAsn  Retrieve Direct ASN information to pass along
     *                to R13600 to setup auto populate data
     *----------------------------------------------------------------

740 AC     getDirectASN  begsr
     *
      /free
              // bust out po, seq, item, upc, mfg date, exp date, lot and lpn.
              // This gets us to the unique asn entry with proper quantity
              // and dates/lots for specific po/seq when more than one date/lot exist
              asnpo=*blanks;
              asnseq=0;
              asnitm=*blanks;
              asnupc=*blanks;
              asnmfgdte=0;
              asnexpdte=0;
              asnlot=*blanks;
              asnlpn=*blanks;
              pos = 0;
              relpos = 0;
              prvpos = 1;
              dow forever = forever;
                pos = %scan('@' : dasn: prvpos);
                if pos >0;
                  relpos = relpos + 1;
                  select;
                    when relpos=1;
                      // end of warehouse.  Not needed with other parm
                      prvpos = pos+1;
                    when relpos=2;
                      // End of PO
                      monitor;
                        asnpo = %subst(dasn:prvpos:(pos)-(prvpos));
                      on-error;
                        asnpo=*blanks;
                      endmon;
                      prvpos = pos+1;
                    when relpos=3;
                      // End of PO seq
                      monitor;
                        asnseq = %dec(%subst(dasn:prvpos:(pos)-
                                         (prvpos)):5:0);
                      on-error;
                        asnseq=*zeros;
                      endmon;
                      prvpos = pos+1;
                    when relpos=4;
                      // End of po item
                      monitor;
                        asnitm = %subst(dasn:prvpos:(pos)-
                                         (prvpos));
                      on-error;
                        asnitm=*blanks;
                      endmon;
                      prvpos = pos+1;
                    when relpos=5;
                      // End of upc
                      monitor;
                        asnupc = %subst(dasn:prvpos:(pos)-
                                         (prvpos));
                      on-error;
                        asnupc=*blanks;
                      endmon;
                      prvpos = pos+1;
                    when relpos=6;
                      // End of Msg Date
                      monitor;
                        asnmfgdte = %dec(%subst(dasn:prvpos:(pos)-
                                         (prvpos)):8:0);
                      on-error;
                        asnmfgdte=0;
                      endmon;
                      prvpos = pos+1;
                    when relpos=7;
                      // End of Exp Date
                      monitor;
                        asnexpdte = %dec(%subst(dasn:prvpos:(pos)-
                                         (prvpos)):8:0);
                      on-error;
                        asnexpdte=0;
                      endmon;
                      prvpos = pos+1;
                    when relpos=8;
                      // End of lot
                      monitor;
                        asnlot = %subst(dasn:prvpos:(pos)-
                                         (prvpos));
                      on-error;
                        asnlot=*blanks;
                      endmon;
                      prvpos = pos+1;
                    when relpos=9;
                      // End of lpn
                      monitor;
                        asnlpn = %subst(dasn:prvpos:(pos)-
                                         (prvpos));
                      on-error;
                        asnlpn=*blanks;
                      endmon;
                      prvpos = pos+1;
                      leave;
                    other;
                      leave;
                  endsl;
                else;
                  leave;
                endif;
              enddo;
              uci = 'DASN|' + %char(asnseq) + '@' + %trim(asnitm) + '@' +
                              %trim(asnUpc) + '@' + %char(asnmfgdte) + '@' +
                              %char(asnexpdte) + '@' +%trim(asnlot) + '@';
              pawhse=Whse;
              papo = asnpo;
              paseq= asnseq;
              paitem=asnitm;
              pLpn  =asnlpn;
              SuperYN='N';
              pOutstr = 'ASNFNC';
              exsr correctURL;
      /end-free
740 Ac                   endsr

     *----------------------------------------------------------------
     *  correctURL  Return correct URL to call
     *----------------------------------------------------------------

      /free
       begsr correctURL;

          callp r136001(uci: whse: papo: SuperYN: Sessid: pLpn: pOutstr);
          if pOutStr = 'M136xx' or pOutStr='M158xx';
            // This means R136001 determined only one record is represented
            // in POASN for scanned LPN.  Therefore, we will go directly
            // to receipt to PCM entry
            select;
              when pOutStr='M136xx';
                rtnUrl= %trim(m136xx()) + 's?action_mode=update&CALCULA004='
                       + %char(whse) + '&CALCULA005=' + %trim(papo)
                       + '&CALCULA006=' + %char(paseq)
                       + '&CALCULA007=' + %trim(paitem)
                       + '&CALCULA031=' + %trim(plpn);
                       pOutStr = '{"rtnUrl":"' + %trim(rtnUrl) + '"}';
                       return;
              when pOutStr='M158xx';
                // get super po if found
                exec sql select puspo into :superpo
                            from pospo
                   where puwhse=:whse and pupo=:papo and puedte=0
                             fetch first row only;
                rtnUrl= %trim(m158xx()) + 's?action_mode=update&CALCULA001='
                       + '*PORCV' + '&CALCULA010=' + %trim(superpo)
                       + '&CALCULA002=' + %char(pawhse)
                       + '&CALCULA006=' + %trim(paitem)
                       + '&CALCULA008=' + %trim(papo)
                       + '&CALCULA009=' + %char(paseq)
                       + '&CALCULA027=' + %trim(plpn);
                       pOutStr = '{"rtnUrl":"' + %trim(rtnUrl) + '"}';
                       return;
            endsl;
          endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  determineRtn  -  Determine proper MRC program to return to
     *                   after updates
     *----------------------------------------------------------------

      /free
       begsr determineRtn;

           // If lpn is blank it came from M135xx without lpn
           // being scanned and we should return M135xx
           if plpn=*blanks;
             pOutstr = 'M135xx';
             return;
           endif;
           // First look to see if more than one open record exist
           // in POASN for this lpn and item
           lpncnt=0;
           exec sql select count(*) into :lpncnt
                      from poasn
               where pawhse=:whse and palcns=' ' and
                     paitem=:item and palpn=:plpn;
           if lpncnt > 1;
             // since this is being requested from I272xx
             // if more than one asn entry exist then we
             // should come back to I272xx for remaining
             // entry for item/lpn after update
             pOutStr = 'I272xx';
             return;
           else;
             // if less than or equal to one it should look
             // to determine whether to return to M135xx or
             // M134xx
             lpncnt=0;
             exec sql select count(*) into :lpncnt from
                     (select paitem,count(*) from poasn where
                        palpn=:pLpn and palcns=' '
                        group by paitem) as derived;
             if lpncnt <= 1;
               // if above query found only one item or none
               // remaining we should return from I272xx to M134xx
               pOutStr = 'M134xx';
               return;
             else;
               // otherwise, it means more than 1 open item exist
               // and we should return to M135xx for the other items
               // found on this lpn
               pOutStr = 'M135xx';
               return;
             endif;
           endif;
       endsr;
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

         // clear the pirhold file for this session
         if %scan('*chkrtn':pParmstr) = 0;
           exec sql delete from pirhold
                where hosess = :psessid
                  and hotype = 'PODTL'
                  or  hosess = :psessid
                  and hotype = 'PODTLCW'
700dA             or  hosess = :psessid
700dA             and hotype = 'PODTLCT'
700iA             or  hosess = :psessid
700iA             and hotype = 'LOCKED'
                  or  hosess = :psessid
                  and hotype = 'POLCNS'
                  or  hosess = :psessid
                  and hotype = 'PODTLASN';
         endif;

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

           when parmName = 'whse';
             if parmValue = '';
               parmValue = '0';
             endif;
             whse =  %dec(parmValue: 3: 0);

           when parmName = 'seq';
             if parmValue = '';
               parmValue = '0';
             endif;
             seq =  %dec(parmValue: 5: 0);

           when parmName = 'cmd';
             cmd = %trim(parmValue);

           when parmName = 'item';
             item = %trim(parmValue);

           when parmName = 'po';
             po = %trim(parmValue);

           when parmName = 'lpn';
             plpn = %trim(parmValue);

           when parmName = 'dasn';
             dasn = %trim(parmValue);

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
     *  i272xx  - Get latest version of I272xx
     *----------------------------------------------------------------

     p i272xx          b
     d i272xx          pi            20

     d  version        s             20

      /free

         exec sql select gmipgm into :version
                   from glomenuitm
                 where gmiid = 'BFCDAKOTA.I27200'
                  fetch first row only;

         return version;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  M136xx  - Get latest version of M136xx
     *----------------------------------------------------------------

     p m136xx          b
     d m136xx          pi            20

     d  version        s             20

      /free

         exec sql select gmipgm into :version
                   from glomenuitm
                 where gmiid = 'BFCDAKOTA.M13600'
                  fetch first row only;

         return version;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  M158xx  - Get latest version of M158xx
     *----------------------------------------------------------------

     p m158xx          b
     d m158xx          pi            20

     d  version        s             20

      /free

         exec sql select gmipgm into :version
                   from glomenuitm
                 where gmiid = 'BFCDAKOTA.M15800'
                  fetch first row only;

         return version;

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

