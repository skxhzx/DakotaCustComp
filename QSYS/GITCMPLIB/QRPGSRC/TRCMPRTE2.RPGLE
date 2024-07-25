      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TRCMPRTE2   TRAX 2.0 - COmplete Route
     *  17 August 2017
     *  Dave Sommerville
     *
     *  Revisions:
     *
710 A*    08/17/17  DAS  7.10
     *      - Created.
     *
710aA*    09/19/17  DAS  7.10a
     *      - Removed VARYING CONST from incoming parameters.
     *        Webservice is not calling with SQL, but with AS400.Access
     *        which is using AS400Text.
     *      - Removed VARYING CONST from TR842.
     *
710bA*    12/11/17  DAS  7.10b
     *      - Revised to use the library list of the job.
     *        This assumes that each warehouse will have its own
     *        Tomcat server, which has its own web.xml file, which
     *        defines the user to connect to the IBM i for the
     *        direct call to the program. If we only wanted to use
     *        1 server for multiple warehouses, a parameter would
     *        need to be added to identify the jobd to use.
     *
720aA*    02/19/18  MR   7.20a
     *      - Add pEmailMsg parm and contatenate ppath and pfile
     *        to build pEmailMessage.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     fbfcdbgflg if   e           k disk    usropn
     fbfcdebug  o    e           k disk    usropn

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     d/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1
     d dpCombo         s             20
     d logText         s            100
     d whse3a          s              3
     d whse3n          s              3  0
     d pReturn         s             10
     d pMessage        s             60
     d jobd            s             10

     *----------------------------------------------------------------
     *  Sub-Procedure Prototypes
     *----------------------------------------------------------------

     d WrtDebugLibl    pr
     d WrtDebugParms   pr

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     d GetLiblCL       pr                  extpgm('GETLIBLCL')
     d  libList                    1024

     d SetJdLibl       pr                  extpgm('SETJDLIBL')
     d  pJobd                        10
     d  pReturn                      10
     d  pMessage                     60

     d TR842           pr                  extpgm('TR842')
     d  pVersion                      5
     d  pCommand                     30
     d  pEmpNo                        5
     d  pWhse3n                       3  0
     d  pRtid                         5
     d  pStop                         5
     d  pPath                       100
     d  pFile                       100
     d  pStamp                       19
     d  pLatitude                    15
     d  pLongitude                   15
     d  pRtnCode                     10
     d  pRtnMsg                      60

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pVersion    Trax Version
     *      pCommand    Command
     *      pEmpNo      Employee Number
     *      pWhse       Warehouse
     *      pRtid       Route id
     *      pStop       Stop number
     *      pPath       Path to file
     *      pFile       XML file name
     *      pStamp      Timestamp
     *      pLatitude   Latitude
     *      pLongitude  Longitude
     *
     *    Returned Parameters
     *      pRtnCode   -  Return code (*OK, *ERROR)
     *      pRtnMsg    -  Error message
     *
     *----------------------------------------------------------------

     d trcmprte2       pr                  extpgm('TRCMPRTE2')
     d  pVersion                      5
     d  pCommand                     30
     d  pEmpNo                        5
     d  pWhse                         3
     d  pRtid                         5
     d  pStop                         5
     d  pPath                       100
     d  pFile                       100
     d  pStamp                       19
     d  pLatitude                    15
     d  pLongitude                   15
     d  pRtnCode                     10
     d  pRtnMsg                      60
     d  pEmailMsg                   200

     d trcmprte2       pi
     d  pVersion                      5
     d  pCommand                     30
     d  pEmpNo                        5
     d  pWhse                         3
     d  pRtid                         5
     d  pStop                         5
     d  pPath                       100
     d  pFile                       100
     d  pStamp                       19
     d  pLatitude                    15
     d  pLongitude                   15
     d  pRtnCode                     10
     d  pRtnMsg                      60
     d  pEmailMsg                   200

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        // See if debug is turned on

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


        // *** TEST TEST TEST ***

        debug = *on;
        debugBefore = *on;
        debugAfter = *on;

        if debugBefore;
          WrtDebugParms();
        endif;

        // Convert warehouse to number

        monitor;
          whse3n = %dec(pWhse:3:0);
        on-error;
          pRtnCode = '*ERROR';
          pRtnMsg = 'Invalid warehouse (' + pWhse + ')';
          return;
        endmon;

        // Write out current library list if debugging

        if debug;
          WrtDebugLibl();
        endif;

        // Set library list based on user

        whse3a =  %TrimL(%editc(whse3n:'X'));
        jobd = '';

710bD   // Revised to used library list of the job

710bD   //select;

710bD   //  when #curruser = 'BFCTRAX';
710bD   //    jobd = %trim('PIRJOBD' + whse3a);

710bD   //  when #curruser = 'BFCTRAXTST';
710bD   //    jobd = %trim('PIRJOBT' + whse3a);

710bD   //endsl;

710bD   //if jobd <> '';
710bD   //  SetJdLibl(jobd: pReturn: pMessage);
710bD   //  if pReturn = '*ERROR';
710bD   //    pRtnCode = pReturn;
710bD   //    pRtnMsg = pMessage;
710bD   //    WrtDebugParms();
710bD   //    return;
710bD   //  endif;
710bD   //endif;

        // Write out library list if debugging

        if debug;
          WrtDebugLibl();
        endif;

        // Call program to process command

        TR842(pVersion: pCommand: pEmpNo: whse3n: pRtid: pStop: pPath: pFile:
              pStamp: pLatitude: pLongitude: pRtnCode: pRtnMsg);

        if pRtnCode <> '*OK';
          WrtDebugParms();
          return;
        endif;

        // Bye, Bye

720aA   pEmailMsg = %trim(ppath)+%trim(pFile);
        pRtnCode = '*OK';
        pRtnMsg = 'Process completed successfully';

        if debugAfter;
          WrtDebugParms();
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
     *  wrtDebugLibl   Write out debug parm record
     *----------------------------------------------------------------

     p WrtDebugLibl    b
     d WrtDebugLibl    pi

      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

        bdtype = 'LIBL';

        GetLiblCL(bdvalues);

        bdaddts = %timestamp();
        bdaddpgm = #pgm;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobnbr;

        write bdrec;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  wrtDebugParms  Write out debug parm record
     *----------------------------------------------------------------

     p WrtDebugParms   b
     d WrtDebugParms   pi


      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

        bdtype = 'PARMS';

        bdvalues = 'pCmd=' + %trim(pCommand) + ', '
                 + 'pVer=' + %trim(pVersion) + ', '
                 + 'pEmp=' + %trim(pEmpNo) + ', '
                 + 'pWhse=' + %trim(pWhse) + ', '
                 + 'pRtid=' + %trim(pRtId) + ', '
                 + 'pStp=' + %trim(pStop) + ', '
                 + 'pPath=' + %trim(pPath) + ', '
                 + 'pFile=' + %trim(pFile) + ', '
                 + 'pRtnCode=' + %trim(pRtnCode) + ', '
                 + 'pRtnMsg=' + %trim(pRtnMsg);

        bdaddts = %timestamp();
        bdaddpgm = #pgm;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobnbr;

        write(e) bdrec;

      /end-free

     p                 e

