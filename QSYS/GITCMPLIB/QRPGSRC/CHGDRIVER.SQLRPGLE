      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *  (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CHGDRIVER  -  Change driver
     *  17 November 2017
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
710 A*    11/25/17  DAS/RBD  7.10
     *      - Created.
     *
720aA*    07/02/18  RBD  7.20
     *      - Added bfcdebug logic.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpiruser   if   e           k disk
     Frtehed    if   e           k disk
     Fttlog     if   e           k disk
     Fttrte     uf a e           k disk
     Ftttrain   if   e           k disk
     Fwarehs    if   e           k disk
720aAFbfcdbgflg if   e           k disk    usropn
720aAFbfcdebug  o    e           k disk
     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')
     *
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
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

720aA*----------------------------------------------------------------
720aA*  Variables
720aA*----------------------------------------------------------------

720aAD dbgflgExists    s               n
720aAD debug           s               n

     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------

     D xmlCreated      s               n
     D rebuildXML      s               n
     D updateDriver    s               n

     *----------------------------------------------------------------
     * Parameters
     *----------------------------------------------------------------

     D pMessage        s             99
     D psessid         s             40
     D puser           s             10
     D pdict           s             10
     D ppgm            s             10
     D pWhse           s              3p 0
     D pRtid           s              5
     D pRte            s              5
     D pDriver         s             10

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lemp           s              5
     D $lfilsn         s             30
     D $lrtn           s              8
     D $lerm           s             60

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

     D gEmp#           s              5  0
     D gUser           s             10
     D gWhse           s              3  0

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     D VfyDownLoad     pr

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D tr810           pr                  extpgm('TR810')
      * Input
     D   ppWhse                       3  0
     D   ppRtid                       5
     D   ppEmp                        5
      * Output
     D   ppFilNam                    30
     D   ppRtn                        8
     D   ppErm                       60

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pSessid     Session
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pWhse       Warehouse
     *      pRtid       Route Id
     *      pRte        Route
     *      pDriver     Driver
     *
     *    Returned Parameters
     *      pMessage    Message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pDict
     C                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pRtid
     c                   parm                    pRte
     c                   parm                    pDriver

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

720aA   if dbgflgExists;
720aA     chain(e) (#pgm) bfcdbgflg;
720aA     if %found(bfcdbgflg);
720aA       debug = (bdfflag = 1);
720aA     else;
720aA       debug = *off;
720aA     endif;
720aA   endif;

720aA   if debug;
720aA     exsr wrtDebugParms;
720aA   endif;

        exsr zzchk1;

720aA   if debug and pMessage <> ' ';
720aA     bdtype = '*ERROR';
720aA     bdvalues = 'pDriver: ' + %trim(pDriver) + ', '
720aA              + 'updateDriver: ' + %trim(updateDriver) + ', '
720aA              + 'pMessage: ' + %trim(pMessage);
720aA     exsr wrtDebug;
720aA   endif;

        if pMessage = ' ' and updateDriver;
          exsr zzupd1;
        endif;
        return;
      /end-free

720aA*----------------------------------------------------------------
720aA*  *INZSR   Initialization subroutine
720aA*----------------------------------------------------------------

720aA /free
720aA  begsr *INZSR;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

       endsr;

      /end-free

720aA*----------------------------------------------------------------
720aA*  wrtDebugParms  Write out debug parm record
720aA*----------------------------------------------------------------

720aA /free
720aA  begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = '&pSessId=' + %trimr(pSessId) + ','
                  + '&pUser=' + %trimr(pUser) + ','
                  + '&pDict=' + %trimr(pDict) + ','
                  + '&pPgm=' + %trimr(pPgm) + ','
                  + '&pWhse=' + %char(pWhse) + ','
                  + '&pRtid=' + %trimr(pRtid) + ','
                  + '&pRte=' + %trimr(pRte) + ','
                  + '&pDriver=' + %trimr(pDriver) + ','
                  + '&pMessage=' + %trimr(pMessage);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

720aA*----------------------------------------------------------------
720aA*  wrtDebug  Write out debug error
720aA*----------------------------------------------------------------

720aA /free
720aA  begsr wrtDebug;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

      /free
        begsr zzchk1;

        // Verify warehouse

        chain (pWhse) warehs;
        if not %found(warehs);
          pMessage = 'Invalid warehouse (' + %char(pWhse) + ')';
          leavesr;
        endif;

        // Verify route id

        chain (pWhse: pRtid) rtehed;
        if not %found(rtehed);
          pMessage = 'Route not found (' + %trim(pRtid) + ')';
          leavesr;
        endif;

        // Verify employee number if driver not blank,
        // if driver is blank it will be blanked out in TTRTE

        if pDriver <> ' ';
          chain (pDriver) piruser;
          if not %found(piruser);
            pMessage = 'Driver id not found (' + %trim(pDriver) + ')';
            leavesr;
          endif;
        endif;

        // Nothing to do if driver didn't change

        updateDriver = *on;
        chain(n) (pwhse: pRtid) ttrte;
        if %found(ttrte) and pDriver = ttrusr;
          updateDriver = *off;
          leavesr;
        endif;

        // If not a Trax training route ...
        // Verify download status, if already downloaded, do not allow driver ch

        chain (pWhse: pRtid) tttrain;
        if not %found(tttrain);
          VfyDownload();
          if pMessage <> ' ';
            leavesr;
          endif;
        endif;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  ZZUPD1   Update record.
     *----------------------------------------------------------------

      /free
        begsr zzupd1;

        // Get current date & time

        $cvcmd = '*CURCMD';
        cvtdte($cvtdt);

        //  Update or write TTRTE record with driver assigned to route.
        //
        //  If updating TTRTE rec and the xml file has been written but
        //  not downloaded, call TR810 to rebuild the xml file since it
        //  has now been assigned a different driver.
        //  Note: TR810 uses Trax options to determine if version 1.2
        //  and/or version 2.0 should be created and proceeds accordingly.

        chain(e) (pWhse: pRtid) ttrte;
        ttrrte = rhrte;
        ttrtru = rhtruk;
        if not %found(ttrte);
          ttrwhs = pWhse;
          ttrrti = pRtid;
          ttrusr = pDriver;
          ttrstd = $cvd8o;
          ttrstt = %Dec(%Time(): *ISO);
720aA     if debug;
720aA       bdtype = '*STATUS';
720aA       bdvalues = 'Write TTRREC';
720aA       exsr wrtDebug;
720aA     endif;
          write ttrrec;
        else;
          ttrusr = pDriver;
          ttrstd = $cvd8o;
          ttrstt = %Dec(%Time(): *ISO);
720aA     if debug;
720aA       bdtype = '*STATUS';
720aA       bdvalues = 'Update TTRREC';
720aA       exsr wrtDebug;
720aA     endif;
          update ttrrec;
          //  Rebuild xml file if built but not yet downloaded
          if rebuildXML;
            if pDriver <> ' ';
              evalr $lemp = %editc(usemp#:'X');
            endif;
            tr810(pWhse: pRtid: $lemp: $lfilsn: $lrtn: $lerm);
          endif;
        endif;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  VfyDownload   Verify download status
     *----------------------------------------------------------------

     p VfyDownload     b
     d VfyDownload     pi

      /free

         rebuildXML = *off;

         // Verify route has not been downloaded

         ttlStatus = ' ';

         setll (pWhse: pRtid) ttlog;
         dow forever = forever;
           reade (pWhse: pRtid) ttlog;
           if %eof(ttlog);
             leave;
           endif;
           if ttlStatus <> '3' and ttlStatus <> '4';
             rebuildXML = *on;
             iter;
           endif;
           if ttlStatus = '3' or ttlStatus = '4';
             pMessage = 'Cannot change driver - '
                      + 'Route already downloaded (' + %trim(pRtid) + ')';
             leave;
           endif;
         enddo;

       return;
      /end-free

     p VfyDownload     e

