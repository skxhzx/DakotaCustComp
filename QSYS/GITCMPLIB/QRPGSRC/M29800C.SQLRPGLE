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
     *  M29800C    Return Slot Count for given Relatime Count
     *
     *  31 July 2019
     *  Kenneth Elder
     *
     *  Revisions
     *
730 A*    07/31/19  KDE  7.30
     *      - Created.
740 A*    05/01/20  KDE  7.40
     *      - Changed key sort on WORKRTCS
740aA*    05/20/20  KDE  7.40a
     *      - Added function call to return number of unassociated
     *        Drop Pick Overflow locations
740bA*    09/24/20  KDE  7.40b
     *      - Do not reflect yellow color line for not printing pages
     *        when Page Id's are not selected in options
740cA*    11/12/20  KDE  7.40c
     *      - Exclude designation code BFC from count
750 A*    01/29/21  KDE  7.50
     *      - Do not reflect BFC slots in Drop Pick counts
750aA*    05/07/21  KDE  7.50a
     *      - Return Excel parm when requesting Excel Variance
750bA*    08/18/21  KDE  7.50b
     *      - Modify SQL for speed
750cA*    11/02/21  KDE  7.50c
     *      - Clear errmsg each time since lr no longer set.  Also
     *        verify Adjustments value in RTCHSTH
760 A*    07/06/22  KDE  7.60
     *      - Add page id assignment here instead of M29700.
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
     frtcscpd   uf a e           k disk
     Fsum008    uf a e           k disk
     foptions   if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D wksrec        E ds                  extname(workrtcs) inz(*EXTDFT)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.frmtnm
700bA /copy qcopysrc,p.random2
      /copy qcopysrc,p.updrtch

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#sgc

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
     D slrec         E ds                  extname(slot) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  *RTC     -  Realtime Inventory Count Options
     *
     * Fields
     *
     *    OPASGNP -  Assign Slots to Page Id
     *    OPPGLVL -  Assign Page Id for each Level Break
     *    OPZTRN  -  Generate Zero Difference Transaction
     *    OPMSLT  -  Max slots per Page Id when selected
     *    OPSRT1  -  Sort Page Assignment by Dept, Aisle, Side Desc, Lvl, Loc, Hnd
     *    OPSRT2  -  Sort Page Assignment by Dept, Aisle, Side Desc, Loc, Lvl, Hnd
     *    OPSRT3  -  Sort Page Assignment by Dept, Styp, Aisle, Side Desc, Loc, Lvl, Hnd
     *    OPSRT4  -  Sort Page Assignment by Dept, Styp, Aisle, Side Desc, Loc, Hnd
760 A*    OPSRT5  -  Sort Page Assignment by Dept, Aisle, Loc, Level, Hand
     *
     * Data structure
     *
     D opdta           ds
     D  opasgnp                1      1
     D  oppglvl                2      2
     D  opztrn                 3      3
     D  opmslt                 4      6  0
     d  opsrt1                 7      7
     d  opsrt2                 8      8
     d  opsrt3                 9      9
     d  opsrt4                10     10
760 Ad  opsrt5                18     18

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

750cAd AdjCnt          s              5  0
760 Ad cntPerPage      s              3  0
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D ts              s               z
     D bfcoffset       s              3  0 inz(0)
     D cntEmpTran      s              3p 0
     D cntEmpTrand     s              3p 0
     d groupStamp      s               z
     d cntCode         s              2
     d cntType         s              2  0
     d cntStat         s              5
     d cnt             s              7  0
     d scnt            s              7  0
760 Ad pageid          s              5  0
     d parcnt          s              1
     D pcnttype        s              2p 0
     d pcolor          s             10
     d prvpage         s              5  0
760 Ad prv_whdp        s              5
760 Ad prv_type        s              1
760 Ad prv_Aisl        s              3
760 Ad prv_side        s              1  0
760 Ad prv_lvl         s              2  0
750 Ad qldisp          s             15
     d sid             s              3  0
740aAd sltCnt          s              5  0
     d useTeams        s              1
740aAd wkType          s              1

     D client          s             10
     D clientloc       s             10

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     d NullInds        s              5i 0 dim(1)
     d NullValue       s                   like(NullInds) inz(-1)

     d sqlWheres       s           5000
     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     d errMsg          s             99    varying
     d dpCombo         s             20    varying

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pSessId        s             40    varying
     d  pUser          s             10    varying
     d  pdict          s             10    varying
     d  ppgm           s             10    varying
     d  pWhse          s              3p 0
     d  pTeam          s             10
     d  puid           s              7  0
     d  psid           s              3  0
     d  ppgid          s              5  0
     d  pTeamValue     s             10
     d  pcmd           s             10
     d  pitem          s             15
     d  pdisp          s             12
     d  pnewuid        s              7  0
     d  ptype          s              2  0
     d  pSts           s              1
     d  pSeq           s              5  0
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

     d AddRecs         pr
     d DeleteRecs      pr

    *----------------------------------------------------------------
    * Prototypes
    *----------------------------------------------------------------

     *  Call process to SUM009 for Inventory Variance Report
     D updsum009       PR                  EXTPGM('UPDSUM009')
     D  errorMessage                 99    varying
     D  SessionId                    40    varying
     d  Warehouse                     3p 0
     d  UID                           7  0
     d  SID                           3  0

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

         //*inlr = *on;

750cA   errmsg=*blanks;

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

750cA   AdjCnt = *zeros;
750cA   exec sql select count (distinct rtcldisp)
750cA              into :AdjCnt
750cA             from rtchstl
750cA            where rtclwhse = :pwhse and
750cA                  (rtcladj1 <> 0 or rtcladj2 <> 0 or rtcladj3 <> 0) and
750cA                  rtcluid = :puid;

         cnt=0;
         select;
           when pCmd='*ONC' or pCmd='*ONEDD';
              // Return count of Overflow locations with no pick slot
              // and no Drop Pick Configuartion
              exsr zzDDcnt;
                    pOutStr = '{'
                     +    '"onc":"' + %char(cnt) + '"'  // No Config Ovf Drop Pick
                     + '}';
                     return;
           when pCmd='*STSUPD';
              // Update Status of Drop Pick Config
              exec sql update drprnge set drpstat=:pSts
               where drpwhse=:pwhse and drpseq=:pSeq;
                    pOutStr = '{'
                     +    '"onc":"' + %char(cnt) + '"'  // No Config Ovf Drop Pick
                     + '}';
                     return;
           when pCmd='*CLOSE';
              // Close open Count
              // update rtchsth
              pcnttype = 1;
              pcmd = 'FINISH';
              updrtch(pwhse: pcmd: puid: pcnttype);
              //exec sql update rtchsth set rtchsts='9',
              //                            rtchpstts=:currstampsys
              //      where rtchwhse=:pWhse and rtchuid=:puid;
              //if sqlstt <> sqlsuccess;
                 //errmsg = 'Errors trying to close the Count';
              //else;
                 //errmsg='Count closed Successfully';
              //endif;
              cnt=0;
              exec sql select count(*) into :cnt
                        from workrtcs
                            where wkswhs=:pWhse and wksuid=:puid
                              and wkscount='Y';
              if cnt>0;
                 parcnt='Y';
              else;
                 parcnt='N';
              endif;
             pOutStr = '{'
                     +    '"errmsg":"' + errmsg + '",'  // Error Closing
                     +    '"partial":"' + parcnt + '"'   // Partial Counts (Y/N)
                     + '}';
           when pCmd='*UPDTEAM';
              // Update team across selected Page Id
              exec sql update workrtcs set wkstgrp=:pTeam
                    where wkswhs=:pWhse and wksuid=:puid
                      and wkspage=:pPgid;
              if sqlstt<>sqlSuccess;
                 errmsg = 'Team Update Failed';
              else;
                 errmsg = 'Team update was Successful';
              endif;
              pOutStr = '{'
                      +    '"errmsg":"' + errmsg + '"'
                      + '}';
           when pCmd='*GETTEAM';
              // get assigned team value
              pTeamValue=*blanks;
              exec sql select wkstgrp into :pTeamValue
                     from WORKRTCS
                       where wkswhs=:pWhse and wksuid=:puid
                         and wkspage=:ppgid
                          fetch first row only;
              pOutStr = pTeamValue;
           when pCmd='*CPYCOUNT';
              // For adds simply call updrtch which creates RTCHSTH record
              pcmd = 'ADD';
              pnewuid=0;
              pType=1;
              updrtch(pwhse: pcmd: pnewuid: pType);
              // Create new Scope definition from old on
              setll (pWhse:pUID) rtcscpd;
              reade (pWhse:pUid) rtcscpd;
              dow not %eof(rtcscpd) and %equal(rtcscpd);
                 rtcsts=currstampsys;
                 rtcsuc=currstampuc;
                 rtcscu=pUser;
                 rtcsju=#user;
                 rtcsj=#job;
                 rtcsjn=#jobnbr;
                 rtcspgm=#pgm;
                 rtcsuid=pnewuid;
                 write rtcsrec;
                 reade (pWhse:pUid) rtcscpd;
              enddo;
              setll *loval rtcscpd;
              // call m29700 to Write Slots for Count
              pParmstr1 = %char(pnewuid);
              pParmStr2 = %char(pwhse);
      /end-free
     c                   call      'M29700'
     c                   parm      ' '           errmsg
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pDict
     c                   parm                    pPgm
     c                   parm      'M29800C'     pObjloc          10
     c                   parm                    pParmStr1       999
     c                   parm                    pParmStr2       999
     c                   parm      ' '           pParmStr3       999
      /free
              exec sql select rtchsid into :sid
                       from rtchsth where rtchwhse=:pWhse and
                                          rtchuid=:pnewuid;
              errmsg='New Cycle Count (' + %char(sid) + ') completed';
              pOutStr = '{'
                      +    '"cpy":"' + errmsg + '"'
                      + '}';
           when pCmd='*GETOPTS';
             chain (pwhse:'*RTC') options;
             if %found(options);
                eval opdta=opdata;
                // protect against numeric value not being updated properly outside of system
                monitor;
                  eval opmslt=opmslt;
                on-error;
                  eval opmslt=0;
                endmon;
             else;
                eval opdta=*blanks;
                eval opmslt = *zeros;
             endif;
             if opmslt=0;
                opasgnp='N';
             endif;
             // If pages are assigned and unassigned slots exist flip line color
             // so user understands they need to print pages again to finalize
             cnt=0;
             exec sql select count(*) into :cnt
                        from workrtcs
                            where wkswhs=:pWhse and wksuid=:puid
                              and wkspgprt<>'Y';
740bD        //if cnt<>0;
740bM        if cnt<>0 and opasgnp='Y';
               pcolor='yellow';
             else;
               pcolor='#E5E7E9';
             endif;
             // return json
             useTeams = 'N';
             cnttype=0;
             exec sql select rtchutflg,rtchtype,rtchsts into :useTeams,:cntType,
                                                     :cntStat
                         from rtchsth
                       where rtchwhse=:pWhse and rtchuid=:puid;
             if useTeams = 'Y';
                cnt=0;
                exec sql select count(*) into :cnt
                        from workrtcs
                          where wkswhs=:pWhse and wksuid=:puid
                            and wkstgrp=' ';
                if cnt>0;
                   pcolor='orange';
                endif;
             endif;
             pOutStr = '{'
                     +    '"opasgnp":"' + opasgnp + '",'  // Assign Pages
                     +    '"cnttype":"' + %char(cnttype) + '",'  // Count Type
                     +    '"cntstat":"' + cntstat + '",'  // Count Status
                     +    '"puid":"' + %char(puid) + '",'
                     +    '"pcolor":"' + %trim(pcolor) + '",'  // Color for Maintainer List lines
                     +    '"opteams":"' + useTeams + '"'   // Use Teams
                     + '}';
           when pCmd='*GETSTAT';
             chain (pwhse:'*RTC') options;
             if %found(options);
                eval opdta=opdata;
                // protect against numeric value not being updated properly outside of system
                monitor;
                  eval opmslt=opmslt;
                on-error;
                  eval opmslt=0;
                endmon;
             else;
                eval opdta=*blanks;
                eval opmslt = *zeros;
             endif;
             if opmslt=0;
                opasgnp='N';
             endif;
             // get Count Code after first entry
             cntCode=*blanks;
             exec sql select rtcsadjc into :cntCode
                  from rtcscpd
                     where rtcsuid=:puid
                     fetch first row only;

             // Get count first.  Called for both getting count and stat
             cnt=0;
             exec sql select count(*) into :cnt
                  from workrtcs
                     where wksuid=:puid;
             scnt=cnt;

             // Returns whether pages have been assigned, and whether
             // counts have begun.
             // 1) Returns NOTHING if neither counts nor pages printed.
             //    This means M29700 can simply send parm to M29700 on
             //    iSeries allowing it to totally clear everything and
             //    reassign page id's
             // 2) Returns PGPRT if pages have been printed but no counts
             //    In this scenario the user will be allowed to decide
             //    whether to append additions with new page id's or
             //    reassign everything and reprint pages
             // 3) Returns COUNTS if some counts have already been recorded.
             //    In this case the user will be told we can either add
             //    to new pages at the end or cancel and not move forward
             //    with the addition and possibly start a new Scope Cycle
             cnt=0;
             exec sql  select count(*) into :cnt
                       from workrtcs
                        where wkswhs=:pwhse and wksuid=:puid
                          and wkscount='Y';
             if cnt>0;
               pOutStr = '{'
                       +    '"opasgnp":"' + %trim(opasgnp) + '",'
                       +    '"currStat":"COUNTS",'
                       +    '"cntCode":"' + %trim(cntCode) + '",'
                       +    '"cnt":"' + %char(scnt) + '"'
                       + '}';
               return;
             endif;

             // if no counts exist check to see if pages printed
             cnt=0;
             exec sql select count(*) into :cnt
                       from rtchsth
                         where rtchwhse=:pWhse and rtchuid=:puid
                           and rtchpprts<>'0001-01-01-00.00.00.000000';
             if cnt>0;
               pOutStr = '{'
                       +    '"opasgnp":"' + %trim(opasgnp) + '",'
                       +    '"currStat":"PGPRT",'
                       +    '"cntCode":"' + %trim(cntCode) + '",'
                       +    '"cnt":"' + %char(scnt) + '"'
                       + '}';
               return;
             endif;

             // otherwise, if no counts started and no pages printed
             // return nothing
             pOutStr = '{'
                       +    '"opasgnp":"' + %trim(opasgnp) + '",'
                       +    '"currStat":"NOTHING",'
                       +    '"cntCode":"' + %trim(cntCode) + '",'
                       +    '"cnt":"' + %char(scnt) + '"'
                     + '}';
            when pCmd='*PVAR';
              // Call process to update SUM009 to print
              // Inventory Variance Report
              updsum009(errmsg:pSessId:pWhse:pUid:pSid);
              if errmsg<>*blanks;
                 pOutStr = '{'
                          +    '"errmsg":"' + %trim(errmsg) + '"'
                        + '}';
              else;
                 pOutStr = '{'
                          +    '"PVAR":"' + %char(puid) + '"'
                        + '}';
              endif;
            when pCmd='*DVAR';
              // Call process to update SUM009 to Display
              // Inventory Variance Report
              updsum009(errmsg:pSessId:pWhse:pUid:pSid);
              if errmsg<>*blanks;
                 pOutStr = '{'
                          +    '"errmsg":"' + %trim(errmsg) + '"'
                        + '}';
              else;
                 pOutStr = '{'
                          +    '"DVAR":"' + %char(puid) + '"'
                        + '}';
              endif;
750aA       when pCmd='*EXVAR';
750aA         // Call process to update SUM009 to produce Excel
750aA         // Inventory Variance Report
750aA         updsum009(errmsg:pSessId:pWhse:pUid:pSid);
750aA         if errmsg<>*blanks;
750aA            pOutStr = '{'
750aA                     +    '"errmsg":"' + %trim(errmsg) + '"'
750aA                   + '}';
750aA         else;
750aA            pOutStr = '{'
750aA                     +    '"EXVAR":"' + %char(puid) + '"'
750aA                   + '}';
750aA         endif;
            when pCmd='*PAGEPRT' or pCmd='*TASSIGN' or pCmd='*PAGEDSP';
760 A         // If user wants pages assigned and either printing or displaying pages
760 A         // then assign ids first
760 A         if opasgnp='Y' and pCmd<>'*TASSIGN';
760 A           exsr assignPages;
760 A         endif;
              // Delete existing records for session id
              DeleteRecs();
              // Add work records for Report Slots w/No Activity
              AddRecs();
              exec sql update rtchsth set rtchpprts=:currstampsys
                       where rtchuid=:puid;
              exec sql update workrtcs set wkspgprt='Y'
                       where wksuid=:puid;
              if pCmd='*TASSIGN';
                 pOutStr = '{'
                          +    '"TASSIGN":"' + %char(puid) + '"'
                        + '}';
              else;
                 if pCmd='*PAGEPRT';
                    pOutStr = '{'
                             +    '"puid":"' + %char(puid) + '",'
                             +    '"errmsg":"OK"'
                           + '}';
                 else;
                    pOutStr = '{'
                             +    '"puidp":"' + %char(puid) + '",'
                             +    '"errmsg":"DSPOK"'
                           + '}';
                 endif;
              endif;
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
     *  AssignPages  -  Assign Pages for current Realtime Count
     *----------------------------------------------------------------

      /free
       begsr AssignPages;

             sqlStmt = 'select slot2.* from workrtcs,slot2 ' +
                       'where wkswhs=slwhse and wkswhdp=slwhdp and ' +
                             'wksbase=sldisp and ' +
                             'slwhse=' + %char(pwhse) + ' and ' +
                             'wksuid=' + %char(pUid) + ' and ' +
                             'wkspage=0';

             // determine sort based on option file selection
             select;
               when opsrt1='Y';
                 sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slaisl,' +
                          'slside desc,slrlvl,slloc,slhand';
               when opsrt2='Y';
                 sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slaisl,' +
                          'slside desc,slloc,slrlvl,slhand';
               when opsrt3='Y';
                 sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slstyp,slaisl,' +
                          'slside desc,slloc,slrlvl,slhand';
               when opsrt4='Y';
                 sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slstyp,slaisl,' +
                          'slside desc,slloc,slhand';
750 A          when opsrt5='Y';
750 A            sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slaisl,' +
750 A                     'slloc,slrlvl,slhand';
               other;
750bA            sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slaisl,' +
750bA                     'slloc,slrlvl,slhand';
             endsl;

730aA        exec sql PREPARE ap FROM :SqlStmt;
730aA        exec sql DECLARE asgnp SCROLL CURSOR FOR ap;
730aA        exec sql OPEN asgnp;

             // set Page Id to zero
             pageId = 0;
             cntPerPage=0;

             dow forever=forever;

                exec sql fetch next from asgnp into :slrec;
                if sqlStt <> sqlSuccess;
                   leavesr;
                endif;

                cntPerPage = cntPerPage + 1;
                // If first record or values change then start next page id
                if %trim(prv_Aisl)='' or
                   (prv_whdp<>slwhdp or prv_aisl<>slaisl or
                   prv_side<>slside or cntPerPage > opmslt) or (oppglvl='Y' and
                   prv_lvl<>slrlvl) or ((opsrt3='Y' or opsrt4='Y') and
                   prv_type<>slstyp);
                   prv_whdp=slwhdp;
                   prv_type=slstyp;
                   prv_aisl=slaisl;
                   prv_side=slside;
                   prv_lvl=slrlvl;
                   cntPerPage = 1;
                   exec sql select max(wkspage) into :pageId from workrtcs
                            where wkswhs=:pwhse and wksuid=:pUid;
                   pageId = pageId + 1;
                endif;

                // update page id
                exec sql update workrtcs set wkspage=:pageId
                         where wkswhs=:pwhse and wksuid=:puid
                           and wkswhdp=:slwhdp and wksbase=:sldisp;

             enddo;
730aA        exec sql close asgnp;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzDDcnt  Determine how many Drop Pick items without config
     *----------------------------------------------------------------

      /free
       begsr zzDDcnt;

730aA     // Create looping SQL looking for Fixed Items with no defined
730aA     // picked slots
750 A     // totally changed sql below in mod 750.  Just take whole sqlstmt
730aA       sqlstmt = 'select itwhse,itwhdp,ititem,ittype,sldisp from piritem' +
750 A                 ',slot as b' +
750 A                 ' where itstyp=' + sq + 'F' + sq + ' and' +
750 A                 ' itwhse=' +
750 A                 ' b.slwhse and itwhdp=b.slwhdp and ititem=b.slitem' +
750 A                 ' and b.slstat=' + sq + 'A ' + sq +
750 A                 ' and b.sldesg<>' + sq + 'BFC' + sq +
750 A                 ' and b.slpick=' + sq + 'N' + sq + ' and (b.slstk1<>0' +
750 M                 ' or b.slstk2<>0 or b.slstk3<>0) and b.sldesg<>' + sq +
750 A                 'BFC' + sq + ' and ' +
730aA                 ' (select count(*) from slot where itwhse=' +
730aA                 ' slwhse and itwhdp=slwhdp and ititem=slitem' +
730aA                 ' and slstat=' + sq + 'A ' + sq +
730aA                 ' and slpick=' + sq + 'Y' + sq +')=0';
            // If single item add selection
            if pCmd='*ONEDD';
              sqlstmt = %trim(sqlStmt) + ' and ititem=' + sq + %trim(pitem)
                         + sq;
            endif;

730aA       exec sql PREPARE dd FROM :SqlStmt;
730aA       exec sql DECLARE dropp SCROLL CURSOR FOR dd;
730aA       exec sql OPEN dropp;
730aA
730aA       dow forever = forever;
730aA          exec sql fetch next from dropp into :qlwhse,:qlwhdp,:qlitem,
750 D                                              //:wktype;
750 M                                              :wktype,:qldisp;
730aA          if sqlstt <> sqlSuccess;
730aA             leave;
730aA          endif;

               cnt = cnt + 1;
730aA          cmpItem=qlitem;
730aA
730aA         //  If Contract, Alias or SSB item
730aA         //   Then get Base Slot item.
730aA         //
730aA         if wktype = 'A'  or
730aA            wktype = 'C'  or
730aA            wktype = 'S';
730aA /end-free
730aAc                   call      'GETSLOTITM'
730aAc                   parm                    qlwhse            3 0
730aAc                   parm                    qlitem           15
730aAc                   parm      ' '           #sitem           15
730aAc                   parm                    #sityp            1
730aAc                   parm                    #sdesc           30
730aAc                   parm                    #spdsc           15
730aAc                   parm                    #srtn            10
730aAc                   parm                    #smsg            60
730aA /free
730aA       cmpItem=#sitem;
730aA       exec sql select count(*) into :sltcnt
750bD                       //from slot where slwhse=:qlwhse
750bA                       from slot3 where slwhse=:qlwhse
730aA                   and slitem=:cmpItem
750bA                   and slstat='A'
730aA                   and slpick='Y';
730aA       if sltCnt>0;
730aA          // if parent has a pick slot then, not drop pick
730aA          iter;
730aA       endif;
730aA       endif;

750 A       if qlDisp <> *blanks;
750 A         pDisp = qldisp;
750 A       endif;
740aA       exsr zzchkDDDef;
740aA       if pReturn='*OK';
              // if getddslot found config subtract one from count
              cnt = cnt - 1;
            endif;

            enddo;
730aA       exec sql close dropp;

       endsr;
      /end-free
FPR3A*
740aA*----------------------------------------------------------------
740aA*  zzChkDDDef   Check to ensure Drop Pick configuration exist for
740aA*               item/Overflow
740aA*----------------------------------------------------------------
740aA
740aAC     zzChkDDDef    begsr
740aA
740aA *  Call GETDDSLOT to determine if Drop Pick Slot defined
740aA
740aAc                   call      'GETDDSLOT'
740aAc                   parm                    qlwhse
740aAc                   parm                    qlwhdp            5
740aAc                   parm                    cmpitem          15
740aAc                   parm      pDisp         prfdis           12
740aAc                   parm      *blanks       prfail            3
740aAc                   parm      *zeros        prfloc            3 0
740aAc                   parm      *blanks       s_sldisp         12
740aAc                   parm      *blanks       s_slaisl          3
740aAc                   parm      *zeros        s_slloc           3 0
740aAc                   parm      *zeros        s_slrlvl          2 0
740aAc                   parm      *blanks       s_slhand          2
750aAc                   parm      0             pddqty1           3 0
750aAc                   parm      ' '           pddtype           1
750aAc                   parm      '   '         ptrntype          3
740aAc                   parm      *blanks       pReturn          10
740aA
740aAC                   endsr

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

           when parmName = 'ITEM';
             pItem = %trim(parmValue);

           when parmName = 'DISP';
             pDisp = %trim(parmValue);

           when parmName = 'WHS';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'UID';
             if parmValue = '';
               parmValue = '0';
             endif;
             puid =  %dec(parmValue: 7: 0);

           when parmName = 'SID';
             if parmValue = '';
               parmValue = '0';
             endif;
             psid =  %dec(parmValue: 3: 0);

           when parmName = 'PGID';
             if parmValue = '';
               parmValue = '0';
             endif;
             ppgid =  %dec(parmValue: 5: 0);

           when parmName = 'TEAM';
             pTeam = parmValue;

           when parmName = 'STS';            // Called from M30900 DRPRNGE Drop Pick
             if %trim(parmValue) = 'Active';
               pSts = 'Y';
             else;
               pSts='N';
             endif;

           when parmName = 'SEQ';           // Called from M30900 DRPRNGE  Drop Pick
             if parmValue = '';
               parmValue = '0';
             endif;
             pSeq =  %dec(parmValue: 5: 0);

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

     *----------------------------------------------------------------
     *  AddRecs   Add records
     *----------------------------------------------------------------

     p AddRecs         b
     d AddRecs         pi

     *  Local Variables

     D wkITem          s             15

      /free

        SqlStmt = 'select '
                + 'wkswhs, wksuid, wkswhdp, wkspage, wksstyp, wksbase '
                + 'from workrtcs where wksuid=' + %char(puid)
740 D        //   + ' order by wksuid,wkswhdp,wkspage,wksstyp,wksbase';
740 M           + ' order by wksuid,wkswhdp,wkspage,wksseq';

        exec sql prepare wksStmt from :SqlStmt;
        exec sql declare wksPg SCROLL cursor for wksStmt;
        exec sql open wksPg;

        prvpage=0;
        cnt=0;
        dow forever = forever;

          exec sql fetch next from wksPg
                   into :wkswhs, :wksuid, :wkswhdp, :wkspage,
                        :wksstyp, :wksbase;

          if sqlstt = sqlNoMoreData;
            leave;
          endif;

          if wkspage<>prvpage;
            if prvpage<>0;
              // get previous record for last slot on page id
              exec sql fetch prior from wksPg
                     into :wkswhs, :wksuid, :wkswhdp, :wkspage,
                          :wksstyp, :wksbase;
              smeslt = wksbase;
              smsltc=cnt;
              write smrec;
              // move back to current record
              exec sql fetch next from wksPg
                     into :wkswhs, :wksuid, :wkswhdp, :wkspage,
                          :wksstyp, :wksbase;
            endif;
            smbslt = wksbase;
            prvpage = wkspage;
            smsessid = pSessid;
            smaddts = %timestamp();
            smbslt = wksbase;
            smwhse = wkswhs;
            smuid=wksuid;
            smwhdp=wkswhdp;
            smpgid=wkspage;
            smstyp=wksstyp;
            cnt=0;

          endif;

          cnt=cnt+1;
        enddo;

        // Write out last record
        exec sql fetch prior from wksPg      // get last slot for previous record
               into :wkswhs, :wksuid, :wkswhdp, :wkspage,
                    :wksstyp, :wksbase;
        if sqlstt = sqlSuccess;
          smsltc=cnt;
          smeslt = wksbase;
          write smrec;
        endif;

        exec sql close wksPg;

      /end-free

     p AddRecs         e

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from sum008
                 where smsessid = :pSessId or
                       smaddts < current timestamp - 1440 MINUTES;

      /end-free

     p DeleteRecs      e
