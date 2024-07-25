      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  R23600     Build workfile for Production Labor Cost
     *
     *  24 May 2017
     *  Thomas Bryant
     *
     *  Revisions
     *
     *    05/24/17  TAB  7.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fsum005    uf a e           k disk
     Fpiritem   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
     D Up              C                   CONST('ABCDEFGHIJKLMNOPQRST+
     D                                     UVWXYZ')
     D Low             C                   CONST('abcdefghijklmnopqrst+
     D                                     uvwxyz')

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D client          s             10
     D clientloc       s             10
     D Line#           s              3  0
     D RecCount        s             15  5
     *----------------------------------------------------------------
     *  Files  Data Structures
     *----------------------------------------------------------------
     D lcmrec          ds
     D lcmwhs                         3  0
     D lcmdte                         8  0
     D lcmmfg                         3  0
     D lcmwo#                        13
     D lcmfgi                        15
     D lcmfgq                         5  0
     D lcmsup                         9  4
     D lcmwsp                         9  4
     D lcmsus                         9  4
     D lcmwss                         9  4
     D lcmsua                         9  4
     D lcmwsa                         9  4

     D lcorec          ds
     D lcowhs                         3  0
     D lcodte                         8  0
     D lcomfg                         3  0
     D lcowo#                        13
     D lcofgi                        15
     D lcolbc                         9  4
     D lcoohc                         9  4
     D lcobfc                         9  4
     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------
     d DeleteRecs      pr
     d GetCurrStamp    pr

     D GetMicroTime    pr
     D  $pmicrouc                      z
     D  $pmicrolocal                   z
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     D  r23600         pr                  extpgm('R23600')
     D  pErrmsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pDict                        10
     D  pPgm                         10
     D  pWhse                         3  0
     D  pMfgl                         4
     D  pSdte                         8  0
     D  pEdte                         8  0
     D  pCost                         1

     D  r23600         pi
     D  pErrmsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pDict                        10
     D  pPgm                         10
     D  pWhse                         3  0
     D  pMfgl                         4
     D  pSdte                         8  0
     D  pEdte                         8  0
     D  pCost                         1
     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pErrmsg     Error Message
     *      pSessID     Session ID
     *      pUser       User ID
     *      pDict       Dictionary
     *      pPgm        Program ID
     *      pWhse       Warehouse
     *      pMfgl       Mfg Line
     *      pSdte       From Date
     *      pEdte       To Date
     *      pCost       Cost requested
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         // Set SQL default parms
         exec sql
           set Option Commit=*none, Dlyprp=*Yes,
                      Closqlcsr = *ENDMOD;
         *inlr = *on;

         // Delete existing records for session id

         DeleteRecs();

         // Validate input
         error = *off;
         exsr errorcheck;

         // Add records
         If error = *off;
           ExSR Addrecs;
         EndIf;

         return;

      /end-free

     *----------------------------------------------------------------
     *  ErrorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

         // Check Manufacturing line selected
         If pMfgL = ' ';
           pErrmsg = 'Mfg Line must be selected';
           error = *on;
           leavesr;
         Else;
           If pMfgL <> '*ALL';
              Line# = %Dec(pMfgL :3 :0);
           EndIf;
         EndIf;

         // Check Date criteria
         If pSdte = 0 or
            pEdte = 0;
           pErrmsg = 'Invalid or No date selected';
           error = *on;
           leavesr;
         Else;
         EndIf;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  AddRecs   Add records
     *----------------------------------------------------------------
      /free

        BegSR Addrecs;

        Select;

        When Line# > 0;
        SqlStmt = 'SELECT CSMWHSE, CSMPRDDATE, CSMLINE, CSMWO, CSMFGITM, '
                + 'CSMFGQTY, sum(CSMUSECPO), sum(CSMWSTCPO), '
                + 'sum(CSMUSECS), sum(CSMWSTCS), sum(CSMUSECA), '
                + 'sum(CSMWSTCA) '
                + 'FROM pcostwom WHERE '
                + 'CSMWHSE = ' + %char(pWhse) + ' and '
                + 'CSMLINE = ' + %char(Line#) + ' and '
                + 'CSMPRDDATE >= ' + %char(pSdte) + ' and '
                + 'CSMPRDDATE <= ' + %char(pEdte) + ' '
                + 'GROUP BY '
                + 'CSMWHSE, CSMPRDDATE, CSMLINE, '
                + 'CSMWO, CSMFGITM, CSMFGQTY';

        Other;
        SqlStmt = 'SELECT CSMWHSE, CSMPRDDATE, CSMLINE, CSMWO, CSMFGITM, '
                + 'CSMFGQTY, sum(CSMUSECPO), sum(CSMWSTCPO), '
                + 'sum(CSMUSECS), sum(CSMWSTCS), sum(CSMUSECA), '
                + 'sum(CSMWSTCA) '
                + 'FROM pcostwom WHERE '
                + 'CSMWHSE = ' + %char(pWhse) + ' and '
                + 'CSMPRDDATE >= ' + %char(pSdte) + ' and '
                + 'CSMPRDDATE <= ' + %char(pEdte) + ' '
                + 'GROUP BY '
                + 'CSMWHSE, CSMPRDDATE, CSMLINE, '
                + 'CSMWO, CSMFGITM, CSMFGQTY';

        EndSl;

        exec sql prepare BldStmt from :SqlStmt;
        exec sql declare BldCsr cursor for BldStmt;
        exec sql open BldCsr;

        dow forever = forever;

          exec sql fetch next from BldCsr
                   into :lcmrec;

          if sqlstt = sqlNoMoreData;
            leave;
          endif;

        Select;
          When pCost = 'L';
            Eval LSEXTC = (lcmsup + lcmwsp);
            Eval LSCSTA = lcmwsp;
            Eval LSOACS = lcmsup;
            Eval LSCOST = pCost;

          When pCost = 'S';
            Eval LSEXTC = (lcmsus + lcmwss);
            Eval LSCSTA = lcmwss;
            Eval LSOACS = lcmsus;
            Eval LSCOST = pCost;

          When pCost = 'A';
            Eval LSEXTC = (lcmsua + lcmwsa);
            Eval LSCSTA = lcmwsa;
            Eval LSOACS = lcmsua;
            Eval LSCOST = pCost;

        Other;
        EndSL;

        // Now let's start build the fieldds in the sumnmary file
        // and write the record.

        Exec SQL Select CSOWHSE, CSOPRDDATE, CSOLINE, CSOWO, CSOFGITM,
                        sum(CSOLABCST), sum(CSOOVRCST), sum(CSOBFITCST)
                 INTO :lcorec FROM pcostwoo
                 WHERE
                   CSOWHSE = :lcmwhs and
                   CSOWO   = :lcmwo# and
                   CSOLINE = :lcmmfg and
                   CSOPRDDATE = :lcmdte and
                   CSOFGITM = : lcmfgi
                 GROUP BY
                   CSOWHSE, CSOPRDDATE, CSOLINE,
                   CSOWO, CSOFGITM;

         If sqlstt = sqlSuccess;
            Eval LSEXTC = LSEXTC +(lcolbc + lcoohc + lcobfc);
            Eval LSOOCS = lcoohc;
            Eval LSOBCS = lcobfc;
            Eval LSCTSU = lcolbc;
         EndIf;

         Chain (lcmwhs :lcmfgi) piritem;
         If %Found(piritem);
           Eval LSFGD  = ITDESC;
         Else;
           Eval LSFGD  ='*NONE';
         EndIf;

            Eval LSWHSE = lcmwhs;
            Eval LSMFGL = lcmmfg;
            Eval LSPDTE = lcmdte;
            Eval LSWRKO = lcmwo#;
            Eval LSFGI  = lcmfgi;
            Eval LSFGQ  = lcmfgq;
            GetCurrStamp();
                 LSLOCTS = CurrStamploc;
                 LSSYSTS = CurrStampsys;
                 LSUTCTS = CurrStampuc;
                 LSSESSID = pSessID;
                 LSJOB   = #Pgm;
                 LSUSER  = pUser;
                 LSJOBN  = #jobn;
                 RecCount = (RecCount + 1);
            write LSREC;

        enddo;

        exec sql close BldCsr;

        If RecCount=0;
           pErrmsg = 'No records for selection criteria';
           error = *on;
        EndIf;

        EndSR;
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
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
640jA    ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from SUM005
                 where LSSESSID = :pSessId;

      /end-free

     p DeleteRecs      e

