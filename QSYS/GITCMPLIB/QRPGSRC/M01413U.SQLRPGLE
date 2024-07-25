      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M01413U    Open route maintenance
     *  02 April 2019
     *  Dave Sommerville
     *
     *  Revisions:
     *
730aA*    04/02/19  DAS  7.30a
     *      - Created. Based on M01400U.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  This program is called via the GENPRC SQL Stored Procedure
     *
     *  The parameters are strings containing value pairs,
     *  with multiple pairs being separated by a '|', for example:
     *
     *    fieldname1=value|fieldname2=value|fieldname3=value
     *
     *  All that is passed back is pErrMsg. Blank = Successful.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------
     D rhrec         E Ds                  Extname(rtehed)
     D ttrrec        E Ds                  Extname(ttrte)
     D rlrec         E Ds                  Extname(rtelm)
700aAD rttrec        E Ds                  Extname(rtetrailer)

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     d dpCombo         s             20    varying
     d mode            s              1
     D pWhse           s              3p 0
     D pRtid           s              5
     D pRte            s              5
     D pTruck          s             10
     D pDriver         s             10
     D pLoadMth        s              1
     D pAlcBld         s              1
700aAD pTrailer        s              8
     D pTBType         s              1
     D pTBProc         s              1

720  D chrwhse         s              3
720  D TBCmd           s             10
720  D TBRtn           s             10
720  D TBRtnMsg        s             60
720  D TBProcess       s              1
720  D TBText10        s             10
720  D TBText30        s             30
720  D TBWhse          s              3s 0
     D $gfCmd          s              8
     D $gfFeature      s              1
     D $gfLight        s              1
     D $gfTBType       s              1
     D $gfWhse         s              3p 0

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     * Call program prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
720   /copy qcopysrc,p.exrtehed
      /copy qcopysrc,p.getfeat

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pObjLoc     External object location called from.
     *      pParmStr1   String of '|' delimited parameters
     *      pParmStr2   String of '|' delimited parameters
     *      pParmStr3   String of '|' delimited parameters
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

     D m01413u         pr                  extpgm('M01413U')
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pDict                        10
     D  pPgm                         10
     D  pObjLoc                      10
     D  pParmStr1                   999
     D  pParmStr2                   999
     D  pParmStr3                   999

     D m01413u         pi
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pDict                        10
     D  pPgm                         10
     D  pObjLoc                      10
     D  pParmStr1                   999
     D  pParmStr2                   999
     D  pParmStr3                   999

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d Edit            pr
     d UpdateRte       pr

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
     * Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = '';

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

         // Combine dictionary/program

         dpCombo = %trim(pDict) + '.' + pPgm;

         // Write out 'Before' Debug info

         if debugBefore;
           debugLoc = 'B';
           wrtBeforeDebug();
         endif;

         // Extract parameters from delimited string

         ExtractParms();

         // Get out if error

         if pErrMsg <> '';
           WrtDebugError();
           return;
         endif;

         // Do processing

         Edit();

         if pErrMsg <> '';
           WrtDebugError();
           return;
         endif;

         UpdateRte();

         if pErrMsg <> '';
           WrtDebugError();
           return;
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
     *  Edit         Edit parameters
     *----------------------------------------------------------------

     p Edit            b
     d Edit            pi

      /free

         // Get Truck Builder Process Feature
         //   S=Standard, E=Advanced/Enhanced, B=Both

         monitor;
           $gfCmd = '*GET';
           $gfWhse = pWhse;
           GetFeat ($gfCmd: $gfwhse: $gfFeature: $gfLight: $gfTBType);
         on-error;
           // Default to Standard
           $gfTBType = 'S';
           return;
         endmon;

         // Alloc and build not allowed until TB Process is set.

         if palcbld = 'Y'
            and $gfTBType = 'B'
            and pTBProc = '';
              pErrMsg = 'Select TruckBuilder Process before Allocate & Build';
         endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  UpdateRte    Update route
     *----------------------------------------------------------------

     p UpdateRte       b
     d UpdateRte       pi

      /free

         // update truck
         exec sql update rtehed set
                    rhtruk = :pTruck
                  where rhwhse = :pWhse
                    and rhrtid = :pRtid
                    and rhrte  = :pRte;
         If sqlstt <> sqlSuccess;
         endif;

         // update/add driver
         // get current date
         $cvcmd = '*CURCMD';
         cvtdte($cvtdt);
         ttrstd = $cvd8o;
         ttrstt = %Dec(%Time(): *ISO);

         exec sql update ttrte set
                    ttrusr = :pDriver,
                    ttrstd = :ttrstd,
                    ttrstt = :ttrstt,
700aA               ttrtru = :PTruck
                  where ttrwhs = :pWhse
                    and ttrrti = :pRtid;
700aD    //If sqlstt <> sqlSuccess;
700aM    If sqlstt <> sqlSuccess and pDriver <> ' ';
           // need to add the record to store the driver
           ttrwhs = pWhse;
           ttrrti = pRtid;
           ttrrte = pRte;
           ttrtru = pTruck;
           ttrusr = pDriver;
           ttrs = 0;
           ttrsd = 0;
           ttrqs1 = 0;
           ttrqs2 = 0;
           ttrqs3 = 0;
           ttrqn1 = 0;
           ttrqn2 = 0;
           ttrqn3 = 0;
           ttrqc1 = 0;
           ttrqc2 = 0;
           ttrqc3 = 0;
           ttrqp1 = 0;
           ttrqp2 = 0;
           ttrqp3 = 0;
           ttrsrd = 0;
           ttrsrt = 0;
           ttrfid = 0;
           ttrfit = 0;
           exec sql insert into ttrte values(:ttrrec);
           If sqlstt <> sqlSuccess;
           endif;
         endif;

700aA    // update the Route Trailer file - RTETRAILER
700aA    if pTrailer <> ' ';

700aA      exec sql update rtetrailer set
700aA                 rttcode = :pTrailer
700aA               where rttwhse = :pWhse
700aA                 and rttrtid = :pRtid;
700aA      If sqlstt <> sqlSuccess;
700aA        // need to add the record to store the trailer
700aA        rttwhse = pWhse;
700aA        rttrtid = pRtid;
700aA        rttcode = pTrailer;
700aA        exec sql insert into rtetrailer values(:rttrec);
700aA        If sqlstt <> sqlSuccess;
700aA        endif;
700aA      endif;
700aA    endif;

700aA    // delete rtetrailer if it exists and user removes the trailer

700aA    if pTrailer = ' ';
700aA      exec sql Delete from rtetrailer
700aA               where rttwhse = :pWhse
700aA                 and rttrtid = :pRtid;
700aA      If sqlstt <> sqlSuccess;
700aA      endif;
700aA    endif;

         // update/add/delete loading method
         select;
           when pLoadMth = ' ';
             exec sql delete from Rtelm
                  where rlwhse = :pWhse
                    and rlrtid = :pRtid;
             If sqlstt = sqlSuccess;
             endif;
           other;
             exec sql update rtelm set
                        rltype = :ploadmth
                      where rlwhse = :pWhse
                        and rlrtid = :pRtid;
             If sqlstt <> sqlSuccess;
               // need to add the record to store the loading method
               rlwhse = pWhse;
               rlrtid = pRtid;
               rltype = pLoadmth;
               exec sql insert into rtelm values(:rlrec);
               If sqlstt <> sqlSuccess;
               endif;
             endif;
         endsl;

         // Update the TruckBuilder Process flag
         // Feature must be 'Both'

         If $gfTBType = 'B';

           TBCmd = '*CHANGE';
           TBWhse = pWhse;
           TBProcess = pTBProc;

           monitor;
             EXRTEHED(TBCmd: TBRtn: TBRtnMsg:
                      TBWhse: pRtId: TBProcess);
           on-error;
             TBRtn = '*ERROR';
             TBText10 = 'EXRTEHED NF';
             TBText30 = 'Error calling EXRTEHED program';
           endmon;
           // If we couldn't update, lets try to add
           if TBRtn = '*ERROR';
             TBCmd = '*ADD';
             TBWhse = pWhse;

             Monitor;
               EXRTEHED(TBCmd: TBRtn: TBRtnMsg:
                        TBWhse: pRtId: TBProcess);
             on-error;
               TBRtn = '*ERROR';
               TBText10 = 'EXRTEHED NF';
               TBText30 = 'Error calling EXRTEHED program';
             endmon;
           endif;

         endif;

         // submit Allocate & Build if requeted

         select;
           when pAlcBld = 'Y';
650cA
650dA        // Convert numeric fields into character fields
650dA        chrWhse = %editc(pWhse: 'X');

650bA /end-free
     C                   call(e)   'RTEBUILD'
     C                   parm                    pErrMsg
650cMC                   parm                    pSessId
650cMC                   parm                    pUser
650cMC                   parm                    dpCombo
650dMC                   parm                    chrWhse
     C                   parm                    pRtid
     C                   parm                    pRte

640aAC                   if        %error
640aAC                   eval      pErrMsg  = 'Error occured calling '
640aAC                                      + 'RTEBUILD ('
640aAC                                      + %trimr(#job) + '/'
640aAC                                      + %trimr(#jobnbr) + '/'
640aAC                                      + %trimr(#user) + ')'
640aAC                   endif

      /free
           other;
         endsl;

       return;

      /end-free

     p                 e

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

           when parmName = 'MODE';
             mode = %xlate(xlower: xupper: parmValue);

           when parmName = 'RHWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pWhse =  %dec(parmValue: 3: 0);

           when parmName = 'RHRTID';
             pRtid = %xlate(xlower: xupper: parmValue);

           when parmName = 'RHRTE';
             pRte = %xlate(xlower: xupper: parmValue);

           when parmName = 'RHTRUK';
             pTruck = %xlate(xlower: xupper: parmValue);

           when parmName = 'TTRUSR';
             pDriver = %xlate(xlower: xupper: parmValue);

           when parmName = 'RLTYPE';
             pLoadMth = %xlate(xlower: xupper: parmValue);

           when parmName = 'ALOCFLAG';
             pAlcBld = %xlate(xlower: xupper: parmValue);

           when parmName = 'RTTCODE';
             pTrailer = %xlate(xlower: xupper: parmValue);

           when parmName = 'TBPROC';
             pTBProc = %xlate(xlower: xupper: parmValue);

         endsl;

       on-error;

         pErrMsg = 'Error extracting parameter '
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
           pErrMsg = 'Error: Parameter string is empty '
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

         if pErrMsg <> '';
           return;
         endif;

         // Extract parms for string 2

         parmStr = %trim(pParmStr2);
         ExtractParmStr(parmStr);

         if pErrMsg <> '';
           return;
         endif;

         // Extract parms for string 3

         parmStr = %trim(pParmStr3);
         ExtractParmStr(parmStr);

         if pErrMsg <> '';
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
           pErrMsg = 'Error: Invalid parameter group '
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
         if pErrMsg <> '';
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
                  + 'pObjLoc:' + %trimr(pObjLoc) + ', '
                  + 'pParm1:' + pParmStr1;

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
                  + 'pObjLoc:' + %trimr(pObjLoc) + ', '
                  + 'pParm1:' + pParmStr1 + ','
                  + 'pErrMsg:' + %trimr(pErrMsg);

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

         if not debugBefore;
           debugLoc = 'B';
           wrtBeforeDebug();
         endif;

         bdtype = 'ERROR';

         bdvalues = pErrMsg;

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

