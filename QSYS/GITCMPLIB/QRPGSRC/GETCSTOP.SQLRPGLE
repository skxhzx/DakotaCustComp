      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETCSTOP    Get Current Stop and Start Time
     *  30 Jan 2018
     *  Kenneth Elder
     *
     *  Revisions:
     *
720 A*    01/30/18  KDE  7.20
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     F*piritem   if   e           k disk

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

        // SQL Data Structure for TTSTP retrieval

     d StpDta          ds            30    Qualified
     d  wkstop                        2  0 overlay(stpdta)
     D  wkstrd                        8  0 overlay(stpdta:*next)
     D  wkstrt                        6  0 overlay(stpdta:*next)
     D  wkfind                        8  0 overlay(stpdta:*next)
     D  wkfint                        6  0 overlay(stpdta:*next)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d true            c                   *on
     d false           c                   *off
     d alreadyStr      s              1
     d rDate           s             40
     d hldstp          s              2  0
     d stpStr          s             75

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

     D  pWhse          s              3p 0
     D  pRteid         s              5
     D  pRte           s              5
     D  pOutStr        s            100

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pRteId      Route ID
     *
     *    Returned Parameters
     *      pOutStr     Json Return String
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pRteid
     C                   parm                    pRte
     C                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        pOutStr = ' ';
        rDate = *blanks;
        hldstp=*zeros;
        alreadyStr = 'N';

           // loop through stop data for route and determine current
           // stop if begun
           sqlStmt = 'select ttpstp,ttpsrd,ttpsrt,ttpFid,ttpfit ' +
                      'from ttstp ' +
                       'where ttpwhs=' + %char(pWhse) + ' and ' +
                       'ttprti=' + %trim(pRteid) + ' and ttprte=' +
                        %trim(pRte);

720 A      exec sql PREPARE stp FROM :SqlStmt;
720 A      exec sql DECLARE stprec SCROLL CURSOR FOR stp;
720 A      exec sql OPEN stprec;
720 A
720 A      exec sql fetch first from stprec into :stpdta;

          dow sqlStt='00000';
             select;
                when stpdta.wkstrd>0 and stpdta.wkstrt>0 and stpdta.wkfind=0;
                   // when began and not finished mark as current
                   if alreadyStr = 'Y';
                      stpStr = 'ATTENTION: Multiple Stops Started';
                   else;
                      hldstp = stpdta.wkstop;
                      alreadyStr = 'Y';
                      rdate = %subst(%char(stpdta.wkstrd):5:2) + '/' +
                              %subst(%char(stpdta.wkstrd):7:2) + '/' +
                              %subst(%char(stpdta.wkstrd):3:2) + '  ' +
                              %subst(%editc(stpdta.wkstrt:'X'):1:2) + ':' +
                              %subst(%editc(stpdta.wkstrt:'X'):3:2);
                      stpStr = 'Stop ' + %editc(hldStp:'X') +
                               ' began on ' +
                               %subst(%char(stpdta.wkstrd):5:2) + '/' +
                               %subst(%char(stpdta.wkstrd):7:2) + '/' +
                               %subst(%char(stpdta.wkstrd):3:2) + '  ' +
                               ' at ' +
                               %subst(%editc(stpdta.wkstrt:'X'):1:2) + ':' +
                               %subst(%editc(stpdta.wkstrt:'X'):3:2);
                   endif;
                when stpdta.wkstrd>0 and stpdta.wkstrt>0
                      and stpdta.wkfind>0 and stpdta.wkfint>0;
                   if hldstp=*zeros;   // if no current stop identified
                      stpStr = 'Completed';
                   endif;
                when stpdta.wkstrd=0 and stpdta.wkfind=0;
                   if hldstp=*zeros;  // if no current stop identified
                      stpStr = 'Open';
                   endif;
              endsl;
720 A       exec sql fetch next from stprec into :stpdta;
          enddo;
720 A     exec sql close stprec;

          // Return the Current Stop and Stop Status/Current Date and Time
          if hldstp=*zeros;
             hldstp=99;
          endif;
          pOutStr = '{'
            +  '"rStop":"'  + %trim(%char(hldstp)) + '",'
            +  '"stpStr":"'  + %trim(stpStr) + '",'
            +  '"rDate":"'  + %trim(rDate) + '"}';

        *inlr = *on;
        return;

      /end-free

