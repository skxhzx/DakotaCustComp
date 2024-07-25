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
     *  M01400F    Misc. Functions for Open Truck Orders
     *
     *  22 April 2021
     *  Kenneth Elder
     *
     *  Revisions
     *
750 A*    04/22/21  KDE  7.50
     *      - Created.
750aA*    08/11/21  KDE  7.50a
     *      - Return total Cube, Weight and Piece count for Super Route
750bA*    09/22/21  KDE  7.50b
     *      - Change position of Super Route option value
     *      - Change sort order for Rtestp when creating Super Route from
     *        merge orders
750cA*    01/17/22  KDE  7.50c
     *      - Add warehouse to Route Head sql
750dA*    02/15/22  KDE  7.50d
     *      - Fix: Correct issues with how it is resequencing route stops
     *      - Change how it is restoring the child stop id's on merge reversal
     *      - Enh: Return cummulative number of stops for Super Route
750eA*    03/07/22  LMC  7.50e
     *      - Enh: Added Auto Assignment of Truck.
760 A*    04/23/22  KDE  7.60
     *      - Fix: Include route from child routes as well as stop id when
     *        resequencing stop ids
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     fordh3     uf   e           k disk
     f                                     rename(ohrec:ohrec3)
     fsrrte     uf a e           k disk
     fsrord     uf a e           k disk
     fsrord1    uf a e           k disk
650gAF                                     rename(srorec:srorec1)
     frtehed1   uf a e           k disk
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     foptions   if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

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

     D ordstp        E Ds                  Extname(Ordh) prefix(o_)
750eAD autorhrec     E Ds                  Extname(rtehed)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D ts              s               z
     D bfcoffset       s              3  0 inz(0)
     D cntEmpTran      s              3p 0
     D cntEmpTrand     s              3p 0
     d groupStamp      s               z
750dAd first           s               n
750dAd hldStop         s              2  0
760 Ad hldMrte         s              5
760 Ad wkMrte          s              5
750dAd childStops      s              3  0
750dAd superStops      s              3  0

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
750 Ad super           s              1
     d rteCnt          s              3  0
     d wrksrtid        s              5
     d wrksrte         s              5
     d sqlnum          s              3  0
     d nextSR          s              3  0
     d lastSR          s              3  0
     d wkimpd          s              8  0
     d psrnum          s              2  0
     d perrmsg         s             99
750aAd rtnOrdc         s              9  3
750aAd rtnOrdw         s              9  2
750aAd rtnOrdp         s              5  0
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
     d  pRte           s              5
     d  pSrte          s              5
     d  pRtid          s              5
     d  pSrtid         s              5
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

     ***  ReSequence Stop Id's from merge or un-merge of Super Route
     d reseqStpId      pr
     D  iRtid                         5    value
     D  iSuperRoute                   1    const

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

     D oi300           PR                  EXTPGM('OI300')
     D  iWhse                              like(rhwhse)
     D  iRtid                              like(rhrtid)

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
750 A      when pCmd='*SUPER';
750 A         // Get super route option so M014xx know whether to
              // to display Super Route button and data
750 A         chain (0: '*SYSTEM') options;
750 A         if not %found(options);
750 A           super = 'N';
750 A         else;
750bD           //super = %subst(opdata:43:1);
750bM           super = %subst(opdata:46:1);
                // if route id passed in confirm it is a super route
                // used from open order view.  Option can be on but
                // displaying orders for non super route
                if pRtid <> *blanks;
                  setll (pWhse:pRtid) srrte;
                  reade (pWhse:pRtid) srrte;
                  if %equal(srrte) and not %eof(srrte);
                    super = 'Y';
                  else;
                    super = 'N';
                  endif;
                  unlock srrte;
750 A           endif;
750 A         endif;
750 A         pOutStr = '{'
750 A          +    '"super":"' + %char(super) + '"'
750 A          + '}';
750 A          return;
750 A      when pCmd='SUPERDATA';
              // Return Super Route if one exists for Merge Route
750 A         exsr Superdata;
750 A      when pCmd='SUPERCRT';
              // Create Super Route/Associate to selected Merge Routes
750 A         exsr SuperCreate;
750aA      when pCmd='SUPERVALS';
750aA         // Get and Return summary values for Super Route
750aA         exsr Supervals;
750 A      when pCmd='REMOVEMRTE';
              // Remove "M" type route from Super Route
750 A         exsr RmvMRTE;
750eA      when pCmd='*AUTOTRUCK';
750eA         // Auto Assign Truck to Route
750eA         exsr AutoTruck;
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
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free

750eA*----------------------------------------------------------------
750eA*  AutoTruck  -  Auto Assign Truck
750eA*----------------------------------------------------------------

750eA /free
750eA  begsr AutoTruck;

750eA /end-free
750eAC                   call      'OI260'
750eAC                   parm      pwhse         $xwhse            3 0
750eAC                   parm                    prtid
750eAC                   parm      ' '           w1truk           10
750eAC                   parm                    $xrtn             8
750eAC                   parm      '*AUTO  '     $lcmd             8
750eAC                   if        $xrtn <> '*OK'
750eAc                   eval      w1truk = ' '
750eAc                   else
750eA /free
750eA       // Change Route Id in Rtehed based on auto assigned
750eA       exec sql update rtehed set rhtruk= :w1truk
750eA             where rhwhse=:pWhse and rhrtid=:pRtid;

750eA /end-free
750eAC                   endif
750eA /free
750eA     pOutStr = '{'
750eA      +    '"newtruck":"' + %trim(w1truk) + '",'
750eA      +    '"routeid":"' + %trim(prtid) + '"'
750eA      + '}';
750eA     return;

750eA  endsr;
750eA /end-free

     *----------------------------------------------------------------
     *  SuperData  -  Build json string for Super Route Data
     *----------------------------------------------------------------

      /free
       begsr SuperData;

          // get Super Route if one exist for Merge route sent
          wrksrtid=*blanks;
          wrksrte=*blanks;
          exec sql select srsrtid,srsrte into :wrksrtid, :wrksrte
                     from srrte
                   where srwhse=:pWhse and srmrte=:pRte and srmrtid=:pRtid;
750 A     pOutStr = '{'
750 A      +    '"superrte":"' + %trim(wrksrte) + '",'
750 A      +    '"superrtid":"' + %trim(wrksrtid) + '"'
750 A      + '}';
          return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  SuperCreate - Assign next Super Route if unassiged, and build
     *                neccesary data from Merg Route
     *----------------------------------------------------------------

      /free
       begsr SuperCreate;

760 A     // Ensure that child route exists in Order Header and return an
760 A     // error if it does not.  Most likely to occur in test environment
760 A     // if data gets out of sync but still unlikely
760 A     exec sql select ohrte into :wkMrte
760 A           from ordh
760 A          where ohwhse=:pWhse and ohrte=:pRtid;
760 A
760 A     if sqlstt<>'00000';
760 A         perrMsg = 'This route is missing in the Order Header file.'
760 A                 + ' This route cannot be used without order info.';
760 A         pOutStr = '{'
760 A            +    '"perrmsg":"' + %trim(perrmsg) + '"'
760 A      + '}';
760 A         return;
760 A     endif;

          // Super Route Id is sent in when user clicks on previously
          // assigned Merge order to Super Route
          if pSrtid <> *blanks;
            exec sql select rhrte into :pSrte
                      from rtehed
750cD              //where rhrtid=:pSrtid;
750cM              where rhwhse=:pWhse and rhrtid=:pSrtid;
            if sqlstt = '00000' and %subst(pSrte:1:3)='#SR';
              monitor;
                pSrNum = %dec(%subst(pSrte:4:2):2:0);
750dA           exsr chkMaxStp;
              on-error;
                pSrNum=*zeros;
              endmon;
            else;
              pSrNum = *zeros;
            endif;
          endif;

          // get next Super Route number if not sent.
          nextsr = 1;
          lastsr = 0;
          if pSrNum = 0;
            sqlstmt = 'with avlSR AS (SELECT rhrte,rhimpd, ' +
                       'RANK() OVER(PARTITION BY rhrte ' +
                       'ORDER BY rhimpd desc) imprank ' +
                          'FROM rtehed) ' +
                      'SELECT RHRTE,RHIMPD,COUNT(*) ' +
                      'FROM avlSR ' +
                      'WHERE imprank=1 AND SUBSTRING(RHRTE,1,3)=' +
                       sq + '#SR' + sq +
                      ' GROUP BY rhrte,rhimpd' +
                      ' order BY rhrte,rhimpd';

            exec sql PREPARE srn FROM :SqlStmt;
            exec sql DECLARE srns SCROLL CURSOR FOR srn;
            exec sql OPEN srns;

            dow forever = forever;
              exec sql fetch next from srns into :wrksrte,:wkimpd,:rtecnt;
              if sqlstt <> '00000';
                if nextSR < 100;
                  // the system has read through Super Route numbers.  As long as
                  // the next number is below 100 it uses that Super Route.  Otherwise
                  // it will reuse the oldest #SRxx it finds based on rhimpd (Import
                  // date).  It performs that below in a when clause when nextsr>99
                  pSrNum = nextSR;
                  leave;
                else;
                  pSrNum = *zeros;
                  leave;
                endif;
              endif;
              if %dec(%subst(wrksrte:4:2):2:0) > nextSR;
                // if what we read is greater than the nextSR that means
                // we have a gap in RTEHED with the Super Route numbering
                // so we will use that available Super Route and leave
                pSrNum = nextSR;
                leave;
              else;
                if %dec(%subst(wrksrte:4:2):2:0) = nextSR;
                  if nextSR <> lastsr;
                    // what we read matches the nextSR but it is different
                    // than the last SR, therefore we add one to nextSR to
                    // keep looking for open Super Route number to use
                    nextSR = nextSR + 1;
                    lastSR = %dec(%subst(wrksrte:4:2):2:0);
                  else;
                    // what we read matches the nextSR and also equal
                    // to lastSR read.  This means there are multiple
                    // route id's for the same super route so we simply
                    // set both nextSR and lastSR to the currently read
                    // Super route and read next.
                    nextsr = %dec(%subst(wrksrte:4:2):2:0);
                    lastSR = %dec(%subst(wrksrte:4:2):2:0);
                  endif;
                endif;
              endif;
            enddo;
            exec sql close srns;
          endif;

          select;
            when pSrNum <> *zeros;
              // Retrieved Super Route from Super Route Id above
              // so nothing necessary here
            when nextsr > 99;
              // reuse oldest super route since 1-99 used
              exec sql
               with avlSR AS (SELECT rhrte,rhimpd,
                       RANK() OVER(PARTITION BY rhrte
                           ORDER BY rhimpd desc) imprank
                   FROM rtehed)
               SELECT RHRTE,RHIMPD,COUNT(*)
                      into :wrksrte,:wkimpd,:rtecnt
               FROM avlSR
               WHERE imprank=1 AND SUBSTRING(RHRTE,1,3)='#SR'
               GROUP BY rhimpd,rhrte
               order BY rhimpd,rhrte
               fetch first row only;
               pSrNum = %dec(%subst(wrksrte:4:2):3:0);
            other;
              // and unexpected wrror occurred trying to retrieve next super rte
              perrMsg = 'An error occurred trying to retrieve the next Super'
                      + ' route.  Please contact the BFC Helpdesk';
750 A         pOutStr = '{'
750 A            +    '"perrmsg":"' + %trim(perrmsg) + '"'
750 A      + '}';
              return;
          endsl;

          // Now that we have a new Super Route lets proceed.
          // If this super Route exists in RTEHED we should get that record
          // information to proceed, otherwise we should get next route id
          // and add new route head record

          pSrte = '#SR' + %editc(pSrNum:'X');
          setll (pWhse:pSrte:'99999') rtehed1;
          readp rtehed1;
          if %eof(rtehed1);
            // get next available route id and create Route Header
            exsr crtSRHead;
          else;
            if rhrte <> pSrte or rhstat > '1';
              // get next available route id and create Route Header
              exsr crtSRHead;
            endif;
          endif;
          unlock rtehed1;

          // Add cross reference information between Merge Route "M" Type
          // and new Super Route
          clear srrec;
          exec sql select rhrte into :srmrte
               from rtehed
             where rhwhse=:pWhse and rhrtid=:pRtid;
          srwhse=pwhse;
          srsrtid=rhrtid;
          srsrte='#SR' + %editc(pSrNum:'X');
          srmrtid=pRtid;
          write srrec;

          // Add cross reference information for Orders from M type order
          // before we associate them all to the new super route id
          setll (pWhse:pRtid) ordh3;
          dow forever = forever;
            reade (pWhse:pRtid) ordh3;
            if %eof(ordh3) or not %equal(ordh3);
              leave;
            endif;

            srowhs = pWhse;
            srosrtid = rhRtid;
            sromordid = ohord;
            sromrte = srmrte;
            sromrtid = pRtid;
            sromstop = ohstop;
            write srorec;

            // update Order Route Id to new Super Route Id
            ohrte = rhrtid;
            update ohrec3;

          enddo;
          unlock ordh3;

          // Remove existing RTESUM records for Super Route
          exec sql delete from rtesum where rswhse=:pWhse and
                               rsrtid=:rhrtid;
          // Recreate RTESUM records for Super Route
          exec sql
            insert into rtesum
               select rswhse,srsrtid,rswhdp,sum(rsordc),sum(rsordw),sum(rsordp),
                      sum(rspckc),sum(rspckw),sum(rspckp)
                   from rtesum,srrte
                     where rswhse=srwhse and rsrtid=srmrtid and
                           srsrtid=:rhrtid
                     group by rswhse,srsrtid,rswhdp;
750aA
750aA     // Get updated sum of totals for new Super Route to return to Screen
750aA     rtnordc=0;
750aA     rtnordw=0;
750aA     rtnordp=0;
750dA     superStops=0;
750aA     exec sql
750aA          select sum(rsordc),sum(rsordw),sum(rsordp)
750aA                 into :rtnordc, :rtnordw, :rtnordp
750aA              from rtesum,srrte
750aA                where rswhse=srwhse and rsrtid=srmrtid and
750aA                      srsrtid=:rhrtid;

            // Change Route Id in RteStp Super Route Id
            exec sql update rtestp set rtsrid = :rhrtid
                  where rtswhs=:pWhse and rtsrid=:pRtid;
            // Resequence RTESTP stopid
            reseqstpid(rhrtid:'1');

750dA      // Get total number of current stops for Super Route
750dA      exec sql select count(*) into :SuperStops
750dA                  from
750dA          (select distinct rtsstp from rtestp where rtsrid=:rhrtid);

            // Just send back all good to return some json if good
750 A       pOutStr = '{'
750 A          +    '"rtnSRNUM":"' + srSrtid + '",'
750aA          +    '"rtnOrdc":"' + %char(rtnordc) + '",'
750aA          +    '"rtnOrdw":"' + %char(rtnOrdw) + '",'
750aA          +    '"rtnOrdp":"' + %char(rtnOrdp) + '",'
750aA          +    '"numStops":"' + %char(superStops) + '",'
750 A          +    '"rtnSRTE":"' + pSrte + '"'
750 A          + '}';
            return;

       endsr;
      /end-free

750dA*----------------------------------------------------------------
750dA*  chkMaxStp - Ensure Max stops of 99 will not be exceeded
750dA*----------------------------------------------------------------

750dA /free
750dA  begsr chkMaxStp;

750dA      SuperStops=0;
750dA      ChildStops=0;

750dA      // Get total number of current stops for Super Route
750dA      exec sql select count(*) into :SuperStops
750dA                  from
750dA          (select distinct rtsstp from rtestp where rtsrid=:pRtid);

750dA      // Get total number of current stops for Child Route
750dA      exec sql select count(*) into :childStops
750dA                  from
750dA          (select distinct rtsstp from rtestp where rtsrid=:pSrtId);

750dA      // if sum of super stops and child stops will exceed 99 return an error
750dA      if (superStops + childStops) > 99;
750dA        perrMsg = 'Adding this child route will exceed 99 stops'
750dA                + ' You must create another Super Route';
750dA        pOutStr = '{'
750dA                +    '"perrmsg":"' + %trim(perrmsg) + '"'
750dA                + '}';
750dA        return;
750dA      endif;

750dA  endsr;
750dA /end-free

     *----------------------------------------------------------------
     *  RmvMRTE - Remove Merge Route from associated Super Route
     *----------------------------------------------------------------

      /free
       begsr RmvMRTE;

          // Reset Route Id back to Merger id for the Merge
          // route being un-associated to the Super Route
          validRead = *off;
          setll (pWhse:pRtid) srord1;
          dow forever = forever;
            reade (pWhse:pRtid) srord1;
            if %eof(srord1) or not %equal(srord1);
              leave;
            endif;
750aA       // get super route
750aA       pSrte=*blanks;
750aA       exec sql select rhrte into :pSrte from rtehed
750aA            where rhwhse=:pWhse and rhrtid=:srosrtid
750aA           fetch first row only;
            validRead = *on;

            wrksrtid = srosrtid;
            // update order header to point back to Merge Order Id
750dD       //exec sql update ordh set ohrte=:pRtid
750dM       exec sql update ordh set ohrte=:pRtid,ohstop=:sromstop
               where ohwhse=:srowhs and ohrte=:srosrtid
                 and ohord=:sromordid;
            // Change Route Id in RteStp
750dD       //exec sql update rtestp set rtsrid = :pRtid
750dM       exec sql update rtestp set rtsrid=:pRtid,rtsstp=:sromstop
                  where rtswhs=:srowhs and rtsrid=:srosrtid
                    and rtsord = :sromordid;
            // Delete Super Route Order Xref
            delete srorec1;
          enddo;

          if validRead;
            // Resequence RTESTP stopid for Super Route
            reseqstpid(wrksrtid:'1');
            // Resequence RTESTP stopid for Merge Route
750dD       //reseqstpid(pRtid:'0');
          endif;

          unlock srord1;
          // if no records found return error
          if not validRead;
            perrMsg = 'An error occurred trying to retrieve the next Super'
                    + ' route.  Please contact the BFC Helpdesk';
750 A       pOutStr = '{'
750 A          +    '"perrmsg":"' + %trim(perrmsg) + '"'
750 A          + '}';
            return;
          endif;

          // Remove Super Route Merge Route Xref
          exec sql delete from srrte where srwhse=:pWhse and
               srmrtid=:pRtid;

          // Remove existing RTESUM records for Super Route
          exec sql delete from rtesum where rswhse=:pWhse and
                          (rsrtid=:wrksrtid);
          // Recreate RTESUM records for Super Route
          exec sql
            insert into rtesum
               select rswhse,srsrtid,rswhdp,sum(rsordc),sum(rsordw),sum(rsordp),
                      sum(rspckc),sum(rspckw),sum(rspckp)
                   from rtesum,srrte
                     where rswhse=srwhse and rsrtid=srmrtid and
                           srsrtid=:wrksrtid
                     group by rswhse,srsrtid,rswhdp;
750aA
750aA     // Get updated sum of totals for new Super Route to return to Screen
750aA     rtnordc=0;
750aA     rtnordw=0;
750aA     rtnordp=0;
750dA     superSTops=0;
750aA     exec sql
750aA          select sum(rsordc),sum(rsordw),sum(rsordp)
750aA                 into :rtnordc, :rtnordw, :rtnordp
750aA              from rtesum,srrte
750aA                where rswhse=srwhse and rsrtid=srmrtid and
750aA                      srsrtid=:wrksrtid;

750dA      // Get total number of current stops for Super Route
750dA      exec sql select count(*) into :SuperStops
750dA                  from
750dA          (select distinct rtsstp from rtestp where rtsrid=:wrksrtid);

            // if all merge routes have been removed for Super Route
            // we should remove the super route from Pltsum
            exec sql delete from rtehed where rhwhse=:pWhse and rhrtid=:wrksrtid
                     and (select count(*) from ordh where ohwhse=:pWhse and
                          ohrte=:wrksrtid)=0 and (select count(*) from rtesum
                          where rswhse=:pWhse and rsrtid=:wrksrtid)=0;
            if sqlstt = '00000';
750 A         pOutStr = '{'
750 A            +    '"allgood":"' + 'allgone' + '",'
750aA          +    '"rtnOrdc":"' + %char(rtnordc) + '",'
750aA          +    '"rtnOrdw":"' + %char(rtnOrdw) + '",'
750aA          +    '"rtnOrdp":"' + %char(rtnOrdp) + '",'
750dA          +    '"numStops":"' + %char(superStops) + '",'
750aA          +    '"rtnSRTE":"' + pSrte + '"'
750 A            + '}';
            return;
            endif;

            // Just send back all good to return some json if good
750 A       pOutStr = '{'
750 A          +    '"allgood":"' + 'AllGood' + '",'
750aA          +    '"rtnOrdc":"' + %char(rtnordc) + '",'
750aA          +    '"rtnOrdw":"' + %char(rtnOrdw) + '",'
750aA          +    '"rtnOrdp":"' + %char(rtnOrdp) + '",'
750dA          +    '"numStops":"' + %char(superStops) + '",'
750aA          +    '"rtnSRTE":"' + pSrte + '"'
750 A          + '}';
            return;

       endsr;
      /end-free

750aA*----------------------------------------------------------------
750aA*  Supervals - Get and Return Super Route Summary Values
750aA*----------------------------------------------------------------

750aA /free
750aA  begsr SuperVals;

750aA     // Get Super Route
750aA     pSrte=*blanks;
750aA     exec sql select rhrte into :pSrte from rtehed
750aA          where rhwhse=:pWhse and rhrtid=:pRtid
750aA       fetch first row only;
750aA
750aA     // Get sum of totals for Super Route to return to Screen
750aA     rtnordc=0;
750aA     rtnordw=0;
750aA     rtnordp=0;
750dA     SuperStops=0;
750aA     exec sql
750aA          select sum(rsordc),sum(rsordw),sum(rsordp)
750aA                 into :rtnordc, :rtnordw, :rtnordp
750aA              from rtesum,srrte
750aA                where rswhse=srwhse and rsrtid=srmrtid and
750aA                      srsrtid=:pRtid;

750dA      // Get total number of current stops for Super Route
750dA      exec sql select count(*) into :SuperStops
750dA                  from
750dA          (select distinct rtsstp from rtestp where rtsrid=:pRtid);

750aA       // Just send back all good to return some json if good
750aA       pOutStr = '{'
750aA          +    '"allgood":"' + 'AllGood' + '",'
750aA          +    '"rtnOrdc":"' + %char(rtnordc) + '",'
750aA          +    '"rtnOrdw":"' + %char(rtnOrdw) + '",'
750aA          +    '"rtnOrdp":"' + %char(rtnOrdp) + '",'
750dA          +    '"numStops":"' + %char(SuperStops) + '",'
750aA          +    '"rtnSRTE":"' + pSrte + '"'
750aA          + '}';
750aA       return;

750aA  endsr;
750aA /end-free

     *----------------------------------------------------------------
     *  crtSRHead  -  Create Super Route Header record (RTEHED)
     *----------------------------------------------------------------

     c     crtSRHead     begsr
     *
     *  Initialize record
     *
     C                   clear                   rhrec
     *
     *  Update fields.
     *
     C                   eval      rhwhse = pWhse
     C                   call      'PIRRTE#'
     C                   parm      pWhse         $rwhse            3 0
     C                   parm      ' '           rhrtid
     *
     C                   eval      rhrte = pSrte
      /free
              exec sql select rhtruk,rhimpd,rhimpt into :rhtruk,:rhimpd,:rhimpt
                   from rtehed
                 where rhwhse=:Pwhse and rhrtid=:pRtid;
      /end-free
     *
     C                   eval      rhstsd = rhimpd
     C                   eval      rhstst = rhimpt
     C                   eval      rhrptd = rhimpd
     C                   eval      rhprtt = rhimpt
     c                   eval      rhtype = ' '
640pAC                   eval      rhstat = '1'
     c                   write     rhrec
     *
     c                   endsr

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

           when parmName = 'SRNUM';
             // first three of super route is #SR
             // and then we use 01-99 to identify unique route
             if %len(%trim(parmValue)) = 5;
               monitor;
                 pSrNum = %dec(%subst(parmValue:4:2):2:0);
               on-error;
                 pSrNum=0;
               endmon;
             else;
               pSrNum=0;
             endif;

           when parmName = 'SRRTID';
             pSRTID = %trim(parmValue);

           when parmName = 'RTE';
             pRte = %trim(parmValue);

           when parmName = 'RTID';
             pRtid = %trim(parmValue);

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

     *----------------------------------------------------------------
     *  reseqStpId  -  Resequence Stop Id's after merging or un-merging
     *                 for Super Route
750dA*                 No longer calling with iTypeRoute = 0
750dA*                 We use sql in mainline to address the stop id reversal
760 A*                 Also use Customer Route in resequence
     *----------------------------------------------------------------

     p reseqStpId      b
     d reseqStpId      pi
     d  iRtid                         5    value
     d  iTypeRoute                    1    const

     d  stopId         s              2  0

      /free


            sqlStmt = 'Select ordh3.* from ordh3';

            // when adding merge route to super route
            // we should include file srord so we can
            // sort and sequence stops by Merge Route and
            // Stop
            if iTypeRoute = '1';
750bD         //sqlStmt = %trim(sqlStmt) + ',srord where ' +
750bM         sqlStmt = %trim(sqlStmt) + ',srord,rtestp where ' +
                 'ohwhse=srowhs and ohrte=srosrtid and ' +
                 'ohord=sromordid and ';
750bA         sqlStmt = %trim(sqlStmt) + ' rtswhs=srowhs and ' +
750bA            'rtsrid=srosrtid and rtsord=sromordid and ';
            else;
              sqlstmt = %trim(sqlStmt) + ' where ';
            endif;

            sqlstmt = %trim(sqlStmt) + ' ohwhse=' + %char(pWhse) +
                      ' and ohrte=' + sq + iRtid + sq;

            if iTypeRoute = '1';
750bD         //sqlstmt = %trim(sqlStmt) + ' order by srowhs,sromrte,sromstop';
750bM         sqlstmt = %trim(sqlStmt) + ' order by srowhs,sromrte,rtsst5';
            else;
              sqlstmt = %trim(sqlStmt) + ' order by ohwhse,ohord,ohstop';
            endif;

            exec sql PREPARE stp FROM :SqlStmt;
            exec sql DECLARE stops SCROLL CURSOR FOR stp;
            exec sql OPEN stops;

750dA  first=*on;
       stopId = 1;

       dow forever = forever;

            exec sql fetch next from stops into :ordstp;
            if sqlStt <> sqlSuccess;
              leave;
            endif;

760 A       // get customer route for child route read
760 A       exec sql select sromrte into :wkMrte
760 A                from srord
760 A            where srowhs=:pWhse and srosrtid=:o_ohrte and
760 A                        sromordid=:o_ohord;

750dA       if first;
750dA         first=*off;
750dA         hldStop = o_ohstop;
760 A         hldMrte  = wkMrte;
750dA       endif;

            // if Route being removed from Super Route
            // we should use stopId from original order
            if iTypeRoute = '0';
              exec sql select sromstop into :stopid
                     from srord
                  where srowhs=:o_ohwhse and sromrtid=:o_ohrte
                    and sromordid=:o_ohord;
            endif;

            // when super route resequence 1 to 99
            if iTypeRoute = '1';
760 D          //if o_ohstop <> hldStop;
760 M          if o_ohstop <> hldStop or wkMrte<>hldMrte;
                 stopid = stopid + 1;
750dA            hldstop = o_ohstop;
760 A            hldMrte = wkMrte;
750dA          endif;
            endif;

            // Update stop id in both order header and rtestp
            // for the respective route id and order id with
            // either a sequencial value when adding to a super
            // route or using the previously assigned stop id from
            // the original merge route if undoing the child from
            // the super super route. Value stopid below is set by
            // getting value from SRORD when undoing the child route.
            exec sql update ordh set ohstop = :stopid
                  where ohwhse=:o_ohwhse and ohord=:o_ohord
                    and ohrte=:o_ohrte;
            exec sql update rtestp set rtsstp = :stopid
                  where rtswhs=:o_ohwhse and rtsrid=:o_ohrte
                    and rtsord=:o_ohord;

       enddo;
       exec sql close stops;

       return;

      /end-free

     p                 e

