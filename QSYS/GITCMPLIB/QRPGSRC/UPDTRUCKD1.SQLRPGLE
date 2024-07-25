      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  UPDTRUCKD  Rebuild truck TRUCKD from TRKTMPD
     *  15 April 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720  *    04/15/18  DAS  7.10a
     *      - Created.
     *
720a *    09/07/18  LMC  7.20a
     *      - Enh: Adding logic to handle up to 9 columns.
     *
740  *    08/28/20  KDE  7.40
     *      - Enh: Update for extension file TRKTMPDEXA
     *      - Enh: Change to perform all updates instead of MRC
     *             updating TRKTMPD since adding TRKTMPDEXA and
     *             TRUCKDEXA
     *
     *----------------------------------------------------------------
     *  File Info
     *----------------------------------------------------------------

     Ftruckd    uf a e           k disk
     Ftrktmpd   if   e           k disk    rename(ttdrec:ttdreci)
720aAFtruckc    if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D ttdrec        E ds                  extname(trktmpd) inz(*EXTDFT)

740 A*----------------------------------------------------------------
740 A*  Standard SQL variables and constants
740 A*----------------------------------------------------------------
740 A
740 A /copy qcopysrc,c#stdsql
740 A /COPY *libl/qcopysrc,p.extrktmp
740 A /COPY *libl/qcopysrc,p.extruckd
740 A /COPY *libl/qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d lastWhse        s                   like(tdwhse)
     d lasttruk        s                   like(tdtruk)
740 Ad wkRow           s              2s 0
740 Ad wkCol           s              1s 0
740 Ad wkCube          s              5s 2
740 Ad reccnt          s              5  0
740 Ad dpcombo         s             20
740 Ad mode            s             10
740 Ad pWhse           s              3  0
740 Ad pTruk           s             10
740 Ad pRow            s              2  0
740 Ad pCmp1           s              1
740 Ad pMcub1          s              5  2
740 Ad pPick1          s              2  0
740 Ad pSpin1          s              1
740 Ad pIcub1          s              5s 2
740 Ad pCmp2           s              1
740 Ad pMcub2          s              5  2
740 Ad pPick2          s              2  0
740 Ad pSpin2          s              1
740 Ad pIcub2          s              5s 2
740 Ad pCmp3           s              1
740 Ad pMcub3          s              5  2
740 Ad pPick3          s              2  0
740 Ad pSpin3          s              1
740 Ad pIcub3          s              5s 2
740 Ad pCmp4           s              1
740 Ad pMcub4          s              5  2
740 Ad pPick4          s              2  0
740 Ad pSpin4          s              1
740 Ad pIcub4          s              5s 2
740 Ad pCmp5           s              1
740 Ad pMcub5          s              5  2
740 Ad pPick5          s              2  0
740 Ad pSpin5          s              1
740 Ad pIcub5          s              5s 2
740 Ad pCmp6           s              1
740 Ad pMcub6          s              5  2
740 Ad pPick6          s              2  0
740 Ad pSpin6          s              1
740 Ad pIcub6          s              5s 2
740 Ad pCmp7           s              1
740 Ad pMcub7          s              5  2
740 Ad pPick7          s              2  0
740 Ad pSpin7          s              1
740 Ad pIcub7          s              5s 2
740 Ad pCmp8           s              1
740 Ad pMcub8          s              5  2
740 Ad pPick8          s              2  0
740 Ad pSpin8          s              1
740 Ad pIcub8          s              5s 2
740 Ad pCmp9           s              1
740 Ad pMcub9          s              5  2
740 Ad pPick9          s              2  0
740 Ad pSpin9          s              1
740 Ad pIcub9          s              5s 2

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d wrtTruckD       pr
     d  row                           2s 0
     d  col                           1  0 const
     d  comp                               like(tdcomp)
     d  cube                          5s 2
     d  pick                          2s 0
     d  icube                         5s 2

     *----------------------------------------------------------------
     *  Parameters
     *
740 A*    Input Parameters
740 A*      pSessId     Session Id
740 A*      pUser       User
740 A*      pDict       Dictionary
740 A*      pPgm        Program
740 A*      pObjLoc     External object location called from.
740 A*      pParmStr1   String of '|' delimited parameters
740 A*      pParmStr2   String of '|' delimited parameters
740 A*      pParmStr3   String of '|' delimited parameters
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

740 AD updtruckd1      pr                  extpgm('UPDTRUCKD1')
     D  pErrmsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pDict                        10
     D  pPgm                         10
     D  pObjLoc                      10
     D  pParmStr1                   999
     D  pParmStr2                   999
     D  pParmStr3                   999

740 AD updtruckd1      pi
     D  pErrmsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pDict                        10
     D  pPgm                         10
     D  pObjLoc                      10
     D  pParmStr1                   999
     D  pParmStr2                   999
     D  pParmStr3                   999

740 A*----------------------------------------------------------------
740 A*  Translation strings
740 A*----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     30    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr
     d  parmStr                     999    varying

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

740 A    // Combine dictionary/program

740 A    dpCombo = %trim(pDict) + '.' + pPgm;

740 A    // Extract parameters from delimited string

740 A    ExtractParms();

740 A    // Get out if error

740 A    if pErrMsg <> '';
740 A      return;
740 A    endif;

740 A  // Add/Update/Delete TRKTMPD first
740 A  exsr PrcUpdate;

720aA  // get number of columns being used from TRUCKC
720aA  chain (pwhse: ptruk) truckc;
720aA  if not %found(truckc);
720aA    tccols = 2;
720aA  endif;
       setll (pwhse: ptruk) trktmpd;

       dow forever = forever;

         reade (pwhse: ptruk) trktmpd;
         if %eof(trktmpd);
           leave;
         endif;

740 A    // Read extension Truck Maintenance file
740 A      exWhse = ttdwhse;
           exRow  = ttdrow;
           exTruk  = ttdtruk;
740 A      extrktmpd ('*GET': exRtnCode: exRtnMsg: exWhse: exTruk:
740 A                  exRow: ttxicub1: ttxicub2: ttxicub3: ttxicub4:
740 A                  ttxicub5: ttxicub6: ttxicub7: ttxicub8: ttxicub9);
740 A      if exRtnCode = '*ERROR';
740 A        ttxicub1=0;
740 A        ttxicub2=0;
740 A        ttxicub3=0;
740 A        ttxicub4=0;
740 A        ttxicub5=0;
740 A        ttxicub6=0;
740 A        ttxicub7=0;
740 A        ttxicub8=0;
740 A        ttxicub9=0;
740 A      endif;

         // Delete existing records for truck

         if ttdwhse <> lastWhse or ttdtruk <> lastTruk;
           lastWhse = ttdwhse;
           lastTruk = ttdtruk;
           setll (ttdwhse: ttdtruk) truckd;
           dow forever = forever;
             reade (ttdwhse: ttdtruk) truckd;
             if %eof(truckd);
               leave;
             endif;
             delete tdrec;
740 A        exec sql delete from truckdexa
740 A            where tdxwhse=:ttdwhse and tdxtruk=:ttdtruk;
           enddo;
         endif;

740 D    //WrtTruckD(ttdrow: 1: ttdcomp1: ttdcube1: ttdpick1);
740 D    //WrtTruckD(ttdrow: 2: ttdcomp2: ttdcube2: ttdpick2);
740 M    WrtTruckD(ttdrow: 1: ttdcomp1: ttdcube1: ttdpick1: ttxicub1);
740 M    WrtTruckD(ttdrow: 2: ttdcomp2: ttdcube2: ttdpick2: ttxicub2);
720aA    if tccols >= 3;
740 D      //WrtTruckD(ttdrow: 3: ttdcomp3: ttdcube3: ttdpick3);
740 M      WrtTruckD(ttdrow: 3: ttdcomp3: ttdcube3: ttdpick3: ttxicub3);
720aA    else;
720aA      ttdcomp3 = ' ';
720aA      ttdcube3 = 0;
720aA      ttdpick3 = 0;
740 D      //WrtTruckD(ttdrow: 3: ttdcomp3: ttdcube3: ttdpick3);
740 M      WrtTruckD(ttdrow: 3: ttdcomp3: ttdcube3: ttdpick3: ttxicub3);
720aA    endif;
720aA    if tccols >= 4;
740 D      //WrtTruckD(ttdrow: 4: ttdcomp4: ttdcube4: ttdpick4);
740 M      WrtTruckD(ttdrow: 4: ttdcomp4: ttdcube4: ttdpick4: ttxicub4);
720aA    else;
720aA      ttdcomp4 = ' ';
720aA      ttdcube4 = 0;
720aA      ttdpick4 = 0;
740 D      //WrtTruckD(ttdrow: 4: ttdcomp4: ttdcube4: ttdpick4);
740 M      WrtTruckD(ttdrow: 4: ttdcomp4: ttdcube4: ttdpick4: ttxicub4);
720aA    endif;
720aA    if tccols >= 5;
740 D      //WrtTruckD(ttdrow: 5: ttdcomp5: ttdcube5: ttdpick5);
740 M      WrtTruckD(ttdrow: 5: ttdcomp5: ttdcube5: ttdpick5: ttxicub5);
720aA    else;
720aA      ttdcomp5 = ' ';
720aA      ttdcube5 = 0;
720aA      ttdpick5 = 0;
740 D      //WrtTruckD(ttdrow: 5: ttdcomp5: ttdcube5: ttdpick5);
740 M      WrtTruckD(ttdrow: 5: ttdcomp5: ttdcube5: ttdpick5: ttxicub5);
720aA    endif;
720aA    if tccols >= 6;
740 D      //WrtTruckD(ttdrow: 6: ttdcomp6: ttdcube6: ttdpick6);
740 M      WrtTruckD(ttdrow: 6: ttdcomp6: ttdcube6: ttdpick6: ttxicub6);
720aA    else;
720aA      ttdcomp6 = ' ';
720aA      ttdcube6 = 0;
720aA      ttdpick6 = 0;
740 D      //WrtTruckD(ttdrow: 6: ttdcomp6: ttdcube6: ttdpick6);
740 M      WrtTruckD(ttdrow: 6: ttdcomp6: ttdcube6: ttdpick6: ttxicub6);
720aA    endif;
720aA    if tccols >= 7;
740 D      //WrtTruckD(ttdrow: 7: ttdcomp7: ttdcube7: ttdpick7);
740 M      WrtTruckD(ttdrow: 7: ttdcomp7: ttdcube7: ttdpick7: ttxicub7);
720aA    else;
720aA      ttdcomp7 = ' ';
720aA      ttdcube7 = 0;
720aA      ttdpick7 = 0;
740 D      //WrtTruckD(ttdrow: 7: ttdcomp7: ttdcube7: ttdpick7);
740 M      WrtTruckD(ttdrow: 7: ttdcomp7: ttdcube7: ttdpick7: ttxicub7);
720aA    endif;
720aA    if tccols >= 8;
740 D      //WrtTruckD(ttdrow: 8: ttdcomp8: ttdcube8: ttdpick8);
740 M      WrtTruckD(ttdrow: 8: ttdcomp8: ttdcube8: ttdpick8: ttxicub8);
720aA    else;
720aA      ttdcomp8 = ' ';
720aA      ttdcube8 = 0;
720aA      ttdpick8 = 0;
740 D      //WrtTruckD(ttdrow: 8: ttdcomp8: ttdcube8: ttdpick8);
740 M      WrtTruckD(ttdrow: 8: ttdcomp8: ttdcube8: ttdpick8: ttxicub8);
720aA    endif;
720aA    if tccols >= 9;
740 D      //WrtTruckD(ttdrow: 9: ttdcomp9: ttdcube9: ttdpick9);
740 M      WrtTruckD(ttdrow: 9: ttdcomp9: ttdcube9: ttdpick9: ttxicub9);
720aA    else;
720aA      ttdcomp9 = ' ';
720aA      ttdcube9 = 0;
720aA      ttdpick9 = 0;
740 D      //WrtTruckD(ttdrow: 9: ttdcomp9: ttdcube9: ttdpick9);
740 M      WrtTruckD(ttdrow: 9: ttdcomp9: ttdcube9: ttdpick9:ttxicub9);
720aA    endif;

       enddo;

       return;
      /end-free

740 A*----------------------------------------------------------------
740 A*  PrcUpdate    Process Update to TRKTMPD
740 A*----------------------------------------------------------------

      /free
       begsr PrcUpdate;

         exsr GetRec;

         select;
           when mode = 'A';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when mode = 'U' or mode = 'C';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when mode = 'D';
             if found;
               exsr DelRec;
             endif;
           other;
             PErrMsg  = 'Invalid command sent: ' + mode
                      + %trim(Mode)
                      + ' (' + %trim(#pgm) +')';
         endsl;

740 A  endsr;
740 A /end-free

740 A*----------------------------------------------------------------
740 A*  AddRec    Add record
740 A*----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

         exsr FillRec;

         exec sql insert into trktmpd values(:ttdrec);

         if sqlstt <> sqlSuccess;
           pErrMsg = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Truck(' + %trim(pTruk) +') '
                    + 'Row(' + %char(pRow) +')';
         else;
           exwhse=pWhse;
           extruk=pTruk;
           exrow=pRow;
           // Add/Update TRKTMPDEXA
740 A      extrktmpd ('*GET': exRtnCode: exRtnMsg: exWhse: exTruk:
740 A                  exRow: ttxicub1: ttxicub2: ttxicub3: ttxicub4:
740 A                  ttxicub5: ttxicub6: ttxicub7: ttxicub8: ttxicub9);
740 A      if exRtnCode = '*ERROR';
             // add record
             exwhse=pWhse;
             extruk=pTruk;
             exrow=pRow;
740 A        extrktmpd ('*ADD': exRtnCode: exRtnMsg: exWhse: exTruk:
740 A                    exRow: picub1: picub2: picub3: picub4:
740 A                    picub5: picub6: picub7: picub8: picub9);
           else;
             // update record
             exwhse=pWhse;
             extruk=pTruk;
             exrow=pRow;
740 A        extrktmpd ('*CHANGE': exRtnCode: exRtnMsg: exWhse: exTruk:
740 A                    exRow: picub1: picub2: picub3: picub4:
740 A                    picub5: picub6: picub7: picub8: picub9);
740 A      endif;
         endif;

740 A  endsr;
740 A /end-free

     *----------------------------------------------------------------
     *  DelRec    Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         exec sql delete from trktmpd
               where ttdwhse=:pwhse and ttdtruk=:pTruk
                      and ttdrow=:pRow;

         if sqlstt <> sqlSuccess;
           pErrMsg  = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Truck(' + %trim(pTruk) + ') '
                    + 'Row(' + %char(prow) +')';
         else;
           exwhse=pwhse;
           extruk=ptruk;
           exrow=prow;
740 A      extrktmpd ('*DELETE': exRtnCode: exRtnMsg: exWhse: exTruk:
740 A                  exRow);
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         ttdwhse = pWhse;
         ttdtruk = pTruk;
         ttdrow =  pRow;
         ttdcomp1= pCmp1;
         ttdcube1= pMcub1;
         ttdpick1= pPick1;
         ttdspin1= pspin1;
         ttdcomp2= pCmp2;
         ttdcube2= pMcub2;
         ttdpick2= pPick2;
         ttdspin2= pspin2;
         ttdcomp3= pCmp3;
         ttdcube3= pMcub3;
         ttdpick3= pPick3;
         ttdspin3= pspin3;
         ttdcomp4= pCmp4;
         ttdcube4= pMcub4;
         ttdpick4= pPick4;
         ttdspin4= pspin4;
         ttdcomp5= pCmp5;
         ttdcube5= pMcub5;
         ttdpick5= pPick5;
         ttdspin5= pspin5;
         ttdcomp6= pCmp6;
         ttdcube6= pMcub6;
         ttdpick6= pPick6;
         ttdspin6= pspin6;
         ttdcomp7= pCmp7;
         ttdcube7= pMcub7;
         ttdpick7= pPick7;
         ttdspin7= pspin7;
         ttdcomp8= pCmp8;
         ttdcube8= pMcub8;
         ttdpick8= pPick8;
         ttdspin8= pspin8;
         ttdcomp9= pCmp9;
         ttdcube9= pMcub9;
         ttdpick9= pPick9;
         ttdspin9= pspin9;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         exec sql update trktmpd
               set ttdcomp1=:pcmp1, ttdcube1=:pMcub1, ttdpick1=:pPick1,
                   ttdspin1=:pspin1,
                   ttdcomp2=:pcmp2, ttdcube2=:pMcub2, ttdpick2=:pPick2,
                   ttdspin2=:pspin2,
                   ttdcomp3=:pcmp3, ttdcube3=:pMcub3, ttdpick3=:pPick3,
                   ttdspin3=:pspin3,
                   ttdcomp4=:pcmp4, ttdcube4=:pMcub4, ttdpick4=:pPick4,
                   ttdspin4=:pspin4,
                   ttdcomp5=:pcmp5, ttdcube5=:pMcub5, ttdpick5=:pPick5,
                   ttdspin5=:pspin5,
                   ttdcomp6=:pcmp6, ttdcube6=:pMcub6, ttdpick6=:pPick6,
                   ttdspin6=:pspin6,
                   ttdcomp7=:pcmp7, ttdcube7=:pMcub7, ttdpick7=:pPick7,
                   ttdspin7=:pspin7,
                   ttdcomp8=:pcmp8, ttdcube8=:pMcub8, ttdpick8=:pPick8,
                   ttdspin8=:pspin8,
                   ttdcomp9=:pcmp9, ttdcube9=:pMcub9, ttdpick9=:pPick9,
                   ttdspin9=:pspin9
               where ttdwhse=:pwhse and ttdtruk=:pTruk
                      and ttdrow=:pRow;

         if sqlstt <> sqlSuccess;
           pErrMSg  = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Truck(' + %trim(pTruk) + ') '
                    + 'Row(' + %char(tdrow) +')';
         else;
           // Add/Update TRKTMPDEXA
           exwhse=pWhse;
           extruk=pTruk;
           exrow=pRow;
           // Add/Update TRKTMPDEXA
740 A      extrktmpd ('*GET': exRtnCode: exRtnMsg: exWhse: exTruk:
740 A                  exRow: ttxicub1: ttxicub2: ttxicub3: ttxicub4:
740 A                  ttxicub5: ttxicub6: ttxicub7: ttxicub8: ttxicub9);
740 A      if exRtnCode = '*ERROR';
             // add record
             exwhse=pWhse;
             extruk=pTruk;
             exrow=pRow;
740 A        extrktmpd ('*ADD': exRtnCode: exRtnMsg: exWhse: exTruk:
740 A                    exRow: picub1: picub2: picub3: picub4:
740 A                    picub5: picub6: picub7: picub8: picub9);
           else;
             // update record
             exwhse=pWhse;
             extruk=pTruk;
             exrow=pRow;
740 A        extrktmpd ('*CHANGE': exRtnCode: exRtnMsg: exWhse: exTruk:
740 A                    exRow: picub1: picub2: picub3: picub4:
740 A                    picub5: picub6: picub7: picub8: picub9);
740 A      endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;


         found = *off;

         exec sql select * into :ttdrec
                  from trktmpd
               where ttdwhse=:pwhse and ttdtruk=:pTruk
                      and ttdrow=:pRow;

         if sqlstt = sqlSuccess;
           found = *on;
740 A      ttxwhse=ttdwhse;
740 A      ttxtruk=ttdtruk;
740 A      ttxrow=ttdrow;
740 A      ttxicub1=*zeros;
740 A      ttxicub2=*zeros;
740 A      ttxicub3=*zeros;
740 A      ttxicub4=*zeros;
740 A      ttxicub5=*zeros;
740 A      ttxicub6=*zeros;
740 A      ttxicub7=*zeros;
740 A      ttxicub8=*zeros;
740 A      ttxicub9=*zeros;
740 A      // either get extension record or zero values
740 A      exec sql select * into :ttxrec
740 A              from trktmpdexa
740 A          where ttxwhse=:pwhse and ttxtruk=:pTruk
740 A                 and ttxrow=:pRow;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WrtTruckD       Write TRUCKD record
     *----------------------------------------------------------------

     p WrtTruckD       b
     d WrtTruckD       pi
     d  row                           2s 0
     d  col                           1  0 const
     d  comp                               like(tdcomp)
     d  cube                          5s 2
     d  pick                          2s 0
740 Ad  icube                         5s 2

      /free

       if comp = '' and cube = 0 and pick = 0;
         return;
       endif;

       tdwhse = pwhse;
       tdtruk = ptruk;
       tdrow = row;
       tdcol = col;
       tdcomp = comp;
       tdcube = cube;
       tdpick = pick;

       write tdrec;

740 A   exwhse = tdwhse;
        extruk = tdtruk;
740 A   wkRow = tdrow;
740 A   wkCol = tdcol;
        wkCube= icube;
740 A   // Update TruckD extension file TRUCKDEXA
740 A      extruckd ('*GET': exRtnCode: exRtnMsg: exwhse: extruk:
740 A                 wkrow: wkcol: wkcube);
740 A      if exRtnCode = '*ERROR';
740 A        exwhse = tdwhse;
             extruk = tdtruk;
740 A        wkRow = tdrow;
740 A        wkCol = tdcol;
             wkCube= icube;
740 A        extruckd ('*ADD': exRtnCode: exRtnMsg: exwhse: extruk:
740 A                   wkrow: wkcol: wkcube);
740 A      else;
740 A        exwhse = tdwhse;
             extruk = tdtruk;
740 A        wkRow = tdrow;
740 A        wkCol = tdcol;
             wkCube= icube;
740 A        extruckd ('*CHANGE': exRtnCode: exRtnMsg: exwhse: extruk:
740 A                   wkrow: wkcol: wkcube);
740 A      endif;

      /end-free

     p                 e


     *----------------------------------------------------------------
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     30    varying
     d  parmValue                   100    varying

     * Local Variables

     d testDate        s               d

      /free

       monitor;

         select;

           when parmName = 'MODE';
             mode = %xlate(xlower: xupper: parmValue);

           when parmName = 'TTDWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pWhse = %dec(parmValue: 3: 0);

           when parmName = 'TTDTRUK';
             pTruk = %xlate(xlower: xupper: parmValue);

           when parmName = 'TTDROW';
             if parmValue = '';
               parmValue = '0';
             endif;
             pRow = %dec(parmValue: 2: 0);

           when parmName = 'TTDCOMP1';
             pCmp1 = %xlate(xlower: xupper: parmValue);

           when parmName = 'TTDCUBE1';
             if parmValue = '';
               parmValue = '0';
             endif;
             pMcub1 = %dec(parmValue: 5: 2);

           when parmName = 'TTDPICK1';
             if parmValue = '';
               parmValue = '0';
             endif;
             pPick1 = %dec(parmValue: 2: 0);

           when parmName = 'TTDSPIN1';
             pSpin1 = %xlate(xlower: xupper: parmValue);

           piCub1=0;
           when parmName = 'TTXICUB1';
             if parmValue = '';
               parmValue = '0';
             endif;
             pIcub1 = %dec(parmValue: 5: 2);

           when parmName = 'TTDCOMP2';
             pCmp2 = %xlate(xlower: xupper: parmValue);

           when parmName = 'TTDCUBE2';
             if parmValue = '';
               parmValue = '0';
             endif;
             pMcub2 = %dec(parmValue: 5: 2);

           when parmName = 'TTDPICK2';
             if parmValue = '';
               parmValue = '0';
             endif;
             pPick2 = %dec(parmValue: 2: 0);

           when parmName = 'TTDSPIN2';
             pSpin2 = %xlate(xlower: xupper: parmValue);

           piCub2=0;
           when parmName = 'TTXICUB2';
             if parmValue = '';
               parmValue = '0';
             endif;
             pIcub2 = %dec(parmValue: 5: 2);

           when parmName = 'TTDCOMP3';
             pCmp3 = %xlate(xlower: xupper: parmValue);

           when parmName = 'TTDCUBE3';
             if parmValue = '';
               parmValue = '0';
             endif;
             pMcub3 = %dec(parmValue: 5: 2);

           when parmName = 'TTDPICK3';
             if parmValue = '';
               parmValue = '0';
             endif;
             pPick3 = %dec(parmValue: 2: 0);

           when parmName = 'TTDSPIN3';
             pSpin3 = %xlate(xlower: xupper: parmValue);

           piCub3=0;
           when parmName = 'TTXICUB3';
             if parmValue = '';
               parmValue = '0';
             endif;
             pIcub3 = %dec(parmValue: 5: 2);

           when parmName = 'TTDCOMP4';
             pCmp4 = %xlate(xlower: xupper: parmValue);

           when parmName = 'TTDCUBE4';
             if parmValue = '';
               parmValue = '0';
             endif;
             pMcub4 = %dec(parmValue: 5: 2);

           when parmName = 'TTDPICK4';
             if parmValue = '';
               parmValue = '0';
             endif;
             pPick4 = %dec(parmValue: 2: 0);

           when parmName = 'TTDSPIN4';
             pSpin4 = %xlate(xlower: xupper: parmValue);

           piCub4=0;
           when parmName = 'TTXICUB4';
             if parmValue = '';
               parmValue = '0';
             endif;
             pIcub4 = %dec(parmValue: 5: 2);

           when parmName = 'TTDCOMP5';
             pCmp5 = %xlate(xlower: xupper: parmValue);

           when parmName = 'TTDCUBE5';
             if parmValue = '';
               parmValue = '0';
             endif;
             pMcub5 = %dec(parmValue: 5: 2);

           when parmName = 'TTDPICK5';
             if parmValue = '';
               parmValue = '0';
             endif;
             pPick5 = %dec(parmValue: 2: 0);

           when parmName = 'TTDSPIN5';
             pSpin5 = %xlate(xlower: xupper: parmValue);

           piCub5=0;
           when parmName = 'TTXICUB5';
             if parmValue = '';
               parmValue = '0';
             endif;
             pIcub5 = %dec(parmValue: 5: 2);

           when parmName = 'TTDCOMP6';
             pCmp6 = %xlate(xlower: xupper: parmValue);

           when parmName = 'TTDCUBE6';
             if parmValue = '';
               parmValue = '0';
             endif;
             pMcub6 = %dec(parmValue: 5: 2);

           when parmName = 'TTDPICK6';
             if parmValue = '';
               parmValue = '0';
             endif;
             pPick6 = %dec(parmValue: 2: 0);

           when parmName = 'TTDSPIN6';
             pSpin6 = %xlate(xlower: xupper: parmValue);

           piCub6=0;
           when parmName = 'TTXICUB6';
             if parmValue = '';
               parmValue = '0';
             endif;
             pIcub6 = %dec(parmValue: 5: 2);

           when parmName = 'TTDCOMP7';
             pCmp7 = %xlate(xlower: xupper: parmValue);

           when parmName = 'TTDCUBE7';
             if parmValue = '';
               parmValue = '0';
             endif;
             pMcub7 = %dec(parmValue: 5: 2);

           when parmName = 'TTDPICK7';
             if parmValue = '';
               parmValue = '0';
             endif;
             pPick7 = %dec(parmValue: 2: 0);

           when parmName = 'TTDSPIN7';
             pSpin7 = %xlate(xlower: xupper: parmValue);

           piCub7=0;
           when parmName = 'TTXICUB7';
             if parmValue = '';
               parmValue = '0';
             endif;
             pIcub7 = %dec(parmValue: 5: 2);

           when parmName = 'TTDCOMP8';
             pCmp8 = %xlate(xlower: xupper: parmValue);

           when parmName = 'TTDCUBE8';
             if parmValue = '';
               parmValue = '0';
             endif;
             pMcub8 = %dec(parmValue: 5: 2);

           when parmName = 'TTDPICK8';
             if parmValue = '';
               parmValue = '0';
             endif;
             pPick8 = %dec(parmValue: 2: 0);

           when parmName = 'TTDSPIN8';
             pSpin7 = %xlate(xlower: xupper: parmValue);

           piCub8=0;
           when parmName = 'TTXICUB8';
             if parmValue = '';
               parmValue = '0';
             endif;
             pIcub8 = %dec(parmValue: 5: 2);

           when parmName = 'TTDCOMP9';
             pCmp9 = %xlate(xlower: xupper: parmValue);

           when parmName = 'TTDCUBE9';
             if parmValue = '';
               parmValue = '0';
             endif;
             pMcub9 = %dec(parmValue: 5: 2);

           when parmName = 'TTDPICK9';
             if parmValue = '';
               parmValue = '0';
             endif;
             pPick9 = %dec(parmValue: 2: 0);

           when parmName = 'TTDSPIN9';
             pSpin9 = %xlate(xlower: xupper: parmValue);

           piCub9=0;
           when parmName = 'TTXICUB9';
             if parmValue = '';
               parmValue = '0';
             endif;
             pIcub9 = %dec(parmValue: 5: 2);

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
     D parmName        s             30    varying
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
