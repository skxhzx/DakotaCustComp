      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  USFDLTRTE  USF delete route
     *  25 January 2016
     *  Dave Sommerville
     *
     *  Revisions:
     *
700 A*    01/25/16  DAS  7.00
     *      - Created.
     *
700aA*    02/26/16  DAS  7.00a
     *      - Revised to pause for 5 minutes when route @@@@@ is sent.
     *        This was done to allow USF to test a timeout condition.
     *      - Revised to exclude routes at status 4=Printed.
     *
700bA*    02/26/16  DAS  7.00b
     *      - Revised to have '@@@@' pause as well.
     *
700cA*    03/07/16  DAS  7.00c
     *      - Revised to send back different message if a route with
     *        status 4=Printed is found.
     *
700dA*    03/09/16  DAS  7.00d
     *      - Revised return code numbers at USF's request.
     *      - Revised put return code in pReturn at USF's request.
     *
700eA*    03/17/16  DAS  7.00e
     *      - Revised message for
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes:
     *
     *   This program assumes that PIRUSF650 and PIRUSF700M are on
     *   the library list.
     *
     *   Branch files library is added and removed by this program.
     *
     *   CHKIUSE determines if new or old route locking method is used.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Frtehed    uf   e           k disk    prefix(u_)
     F                                     usropn
     F                                     infds(file1ds)
     Frtehed1   if   e           k disk    rename(rhrec:rhrec1)
     F                                     usropn
     F                                     infds(file2ds)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pBranch     Branch code
     *      pRte        Host route code
     *
     *    Returned Parameters
     *      pReturn     Return code
     *      pMessage    Return message
     *
     *----------------------------------------------------------------

     D usfdltrte       pr                  extpgm('USFDLTRTE')
     D  pBranch                       2
     D  pRte                          5
     D  pReturn                      10
     D  pMessage                    100    varying

     D usfdltrte       pi
     D  pBranch                       2
     D  pRte                          5
     D  pReturn                      10
     D  pMessage                    100    varying

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n
700cAD stat4Found      s               n

     D cmd             s           3000    varying
     D count           s              3  0
     D filesLib        s             10
     D i               s              5p 0
     D iCmd            s              8
     D iWhse           s              3  0
     D iRteId          s              5
     D iRtn            s              8
     D iFlag           s              1  0
     D iSubFlag        s              1  0
     D iText10         s             10
     D iText30         s             30
     D lastRteId       s              5
     D svStat          s              1

     d ddWhse          s              3  0
     d ddRtid          s              5
     d ddmrid          s             26
     d ddGrpId         s              7  0
     d ddGrpCode       s             10
     d ddSubGrp        s             12
     d ddType          s              1
     d ddCurUsr        s             10
     d ddpgm           s             10
     d ddJobqTS        s             26
     d ddJobqUC        s             26

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

      /copy *libl/qcopysrc,c#file1ds
      /copy *libl/qcopysrc,c#file2ds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.chkiuse
      /copy qcopysrc,p.qcmdexc

     D AddBranchLib    pr            10I 0
     D   lib                         10A   const varying

     D AddLible        pr            10I 0
     D   lib                         10A   const varying

700aAD Delay           pr
700aAD   seconds                      5p 0 const

     D DeleteRouteId   pr            10I 0

     D LogEnd          pr

     D LogInfo         pr
     D   rteId                        5A   const
     D   subGroup                    12A   const

     D LogStart        pr

     D RmvLible        pr            10I 0
     D   lib                         10A   const varying

     D WrtRteLog       pr

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         pReturn = '';
         pMessage = '';

700aA    // Delay for 5 minutes when route @@@@@ sent in.
700aA
700aA    if pRte = '@@@@@' or pRte = '@@@@';
700aA      delay(300);
700aA    endif;

         // Hard code warehouse

         iWhse = 1;

         // Add branch files library to library list

         filesLib = 'PIRUSFF' + pBranch;

         if AddBranchLib(filesLib) < 0;
700dD      //pReturn = '*ERROR';
700dD      //pMessage = '55 - Error adding branch library '
700dD      //         + %trimr(filesLib) + ' to library list';
700dD      //LogInfo('': '55-AddLibErr');
700dM      pReturn = '53';
700dM      pMessage = 'Error adding branch library '
700dM               + %trimr(filesLib) + ' to library list';
700dM      LogInfo('': '53-AddLibErr');
           return;
         endif;

         // Open files

         open(e) rtehed;
         if %error;
700dD      //pReturn = '*ERROR';
700dD      //pMessage = '56 - Error opening '
700dD      //         + %trimr(filesLib) + '/RTEHED file - '
700dD      //         + f1messageid;
700dD      //LogInfo('': '56-OpnHedErr');
700dM      pReturn = '54';
700dM      pMessage = 'Error opening '
700dM               + %trimr(filesLib) + '/RTEHED file - '
700dM               + f1messageid;
700dM      LogInfo('': '54-OpnHedErr');
           return;
         endif;

         open(e) rtehed1;
         if %error;
700dD      //pReturn = '*ERROR';
700dD      //pMessage = '57 - Error opening '
700dD      //         + %trimr(filesLib) + '/RTEHED1 file - '
700dD      //         + f2messageid;
700dD      //LogInfo('': '57-OpnHd1Err');
700dM      pReturn = '55';
700dM      pMessage = 'Error opening '
700dM               + %trimr(filesLib) + '/RTEHED1 file - '
700dM               + f2messageid;
700dM      LogInfo('': '55-OpnHd1Err');
           return;
         endif;

         // Start logging

         LogStart();

         // Loop through route id's for host route

         count = 0;
700cA    stat4Found = *off;

         setll (iWhse: pRte) rtehed1;

         dow forever = forever;

           reade (iWhse: pRte) rtehed1;
           if %eof(rtehed1);
             leave;
           endif;

700cA      if rhstat = '4';
700cA        stat4Found = *on;
700cA      endif;

700aD      //if rhstat <> '1' and rhstat <> '2'
700aD      // and rhstat <> '3' and rhstat <> '4'
700aD      // and rhstat <> 'S';
700aD      //   iter;
700aD      //endif;

700aM      if rhstat <> '1' and rhstat <> '2'
700aM       and rhstat <> '3' and rhstat <> 'S';
700aM         iter;
700aM      endif;

           // First, lock route

           iCmd = '*INUSE11';
           chkiuse (iCmd:iWhse:rhrtid:iRtn:iFlag:iSubFlag:iText10:iText30);

           if iRtn = '*ERROR';
700dD        //pReturn = '*ERROR';
700dD        //pMessage = '51 - Route Id ' +  rhrtid + ' '
700dD        //         + 'not deleted - In use: ' + iText30;
700dD        //LogInfo(rhrtid: '51-InUse');
700dM        pReturn = '21';
700eD        //pMessage = 'Route Id ' +  rhrtid + ' '
700eD        //         + 'not deleted - In use: ' + iText30;
700eM        pMessage = 'Route ' + %trimr(pRte) + ', '
700eM                 + 'Id ' +  rhrtid + ' '
700eM                 + 'not deleted - In use: ' + iText30;
700dM        LogInfo(rhrtid: '21-InUse');
             leave;
           endif;

           // Now try to delete route id (-1 returned if error).

           if DeleteRouteId() < 0;
             iCmd = '*CLEAR';
             chkiuse (iCmd:iWhse:rhrtid:iRtn:iFlag:iSubFlag:iText10:iText30);
             leave;
           endif;

           // Clear route lock and loop.

           iCmd = '*CLEAR';
           chkiuse (iCmd:iWhse:rhrtid:iRtn:iFlag:iSubFlag:iText10:iText30);

           lastRteId = rhrtid;
           count += 1;

         enddo;

         // Send back appropriate Ok message when no error.

         select;

           when pReturn <> '';

700cA      when count = 0 and stat4Found;
700dD        //pReturn = '*ERROR';
700dD        //pMessage = '58 - Route ' +  %trimR(pRte) + ' '
700dD        //         + 'is in Printed Status - it will not be '
700dD        //         + 'deleted in TruckBuilder';
700dD        //LogInfo(rhrtid: '58-Stat4');
700dM        pReturn = '22';
700dM        pMessage = 'Route ' +  %trimR(pRte) + ' '
700dM                 + 'is in Printed Status - it will not be '
700dM                 + 'deleted in TruckBuilder';
700dM        LogInfo(rhrtid: '22-Stat4');

           when count = 0;
700dD        //pReturn = '*OK';
700dD        //pMessage = '03 - No open routes found for route '
700dD        //         + %trimr(pRte);
700dD        //LogInfo('': '03-NoOpnRtID');
700dM        pReturn = '20';
700dM        pMessage = 'Route ' + %trimr(pRte) + ' '
700dM                 + 'not found in open, built or staged '
700dM                 + 'status in TruckBuilder';
700dM        LogInfo('': '20-NoOpnRtID');

           when count = 1;
700dD        //pReturn = '*OK';
700dD        //pMessage = '01 - Route ' + %trimr(pRte) + ', '
700dD        //         + 'Id ' + lastRteId + ', deleted successfully';
700dM        pReturn = '01';
700dM        pMessage = 'Route ' + %trimr(pRte) + ', '
700dM                 + 'Id ' + lastRteId + ', deleted successfully';
             LogInfo(lastRteId: '01-Deleted');

           other;
700dD        //pReturn = '*OK';
700dD        //pMessage = '02 - ' + %char(count) + ' '
700dD        //         + 'routes deleted successfully '
700dD        //         + 'for Route ' + %trimr(pRte);
700dM        pReturn = '02';
700dM        pMessage = %char(count) + ' TruckBuilder '
700dM                 + 'routes deleted successfully '
700dM                 + 'for Route ' + %trimr(pRte);
             LogInfo('': '02-MultDlt');

         endsl;

         // End logging

         LogEnd();

         // Remove branch files library from library list

         if RmvLible(filesLib) < 0;
         endif;

         // Need to RCLRSC because CHKIUSE doesn't use *INLR

         cmd = 'rclrsc';

         monitor;
           qcmdexc(cmd: %len(cmd));
         on-error *all;
         endmon;

         // Bye, Bye

         return;

      /end-free

     *----------------------------------------------------------------
     *  Procedures
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  AddBranchLib  Add branch library to library list
     *----------------------------------------------------------------

     p AddBranchLib    b
     d AddBranchLib    pi            10i 0
     d   branchLib                   10a   const varying

     d flag            s             10i 0

      /free

         // We assume an error means the library exists on list
         // Therefore, we remove it and try again.

         if AddLible(branchLib) < 0;
           flag = RmvLible(branchLib);
           if AddLible(branchLib) < 0;
             return -1;
           endif;
         endif;

         return 0;

      /end-free

     p AddBranchLib    e

     *----------------------------------------------------------------
     *  AddLible    Add library to library list
     *----------------------------------------------------------------

     p AddLible        b
     d AddLible        pi            10I 0
     d   lib                         10A   const varying

      /free

         cmd = 'addlible lib(' + lib + ') position(*FIRST)';

         monitor;
           qcmdexc(cmd: %len(cmd));
         on-error *all;
           return -1;
         endmon;

         return 0;

      /end-free

     p AddLible        e

700aA*----------------------------------------------------------------
700aA*  Delay    Create a delay for sent in seconds
700aA*----------------------------------------------------------------
700aA
700aAp Delay           b
     d Delay           pi
     d   seconds                      5p 0 const

     C                   call(e)   'DLYJOBCL'
     C                   parm      seconds       dlysec            5 0

     p Delay           e

     *----------------------------------------------------------------
     *  DeleteRouteId   Delete route id
     *----------------------------------------------------------------

     p DeleteRouteId   b
     d DeleteRouteId   pi            10I 0

      /free

         // Get RTEHED record to update it

         chain(e) (iWhse: rhrtid) rtehed;

         // Error - Record locked

         if %status(rtehed) = 1218;
700dD      //pReturn = '*ERROR';
700dD      //pMessage = '52 - Route ' + %trimr(pRte) + ', '
700dD      //         + 'Id ' + rhrtid + ', '
700dD      //         + 'not deleted - Row locked';
700dD      //LogInfo(rhrtid: '52-RowLocked');
700dM      pReturn = '50';
700dM      pMessage = 'Route ' + %trimr(pRte) + ', '
700dM               + 'Id ' + rhrtid + ', '
700dM               + 'not deleted - Row locked';
700dM      LogInfo(rhrtid: '50-RowLocked');
           return -1;
         endif;

         // Record not found

         if not %found(rtehed);
700dD      //pReturn = '*ERROR';
700dD      //pMessage = '54 - Route ' + %trimr(pRte) + ', '
700dD      //         + 'Id ' + rhrtid + ', '
700dD      //         + 'not deleted - Unexpected error';
700dD      //LogInfo(rhrtid: '54-ChainErr');
700dM      pReturn = '52';
700dM      pMessage = 'Route ' + %trimr(pRte) + ', '
700dM               + 'Id ' + rhrtid + ', '
700dM               + 'not deleted - Unexpected error';
700dM      LogInfo(rhrtid: '52-ChainErr');
           return -1;
         endif;

         // Set Route status to 9 = Deleted

         svStat = u_rhstat;
         u_rhstat = '9';
         u_rhstsd = %dec(%date():*ymd);
         u_rhstst = %dec(%time():*hms);

         update(e) rhrec;
         if %error;
700dD      //pReturn = '*ERROR';
700dD      //pMessage = '53 - Route ' + %trimr(pRte) + ', '
700dD      //         + 'Id ' + rhrtid + ', '
700dD      //         + 'not deleted - Unexpected update error - '
700dD      //         + f1messageid;
700dD      //LogInfo(rhrtid: '53-UpdError');
700dM      pReturn = '51';
700dM      pMessage = 'Route ' + %trimr(pRte) + ', '
700dM               + 'Id ' + rhrtid + ', '
700dM               + 'not deleted - Unexpected update error - '
700dM               + f1messageid;
700dM      LogInfo(rhrtid: '51-UpdError');
           return -1;
         endif;

         LogInfo(rhrtid: '00-Deleted-' + svStat);
         return 0;

      /end-free

     p DeleteRouteId   e

     *----------------------------------------------------------------
     *  LogEnd       End logging for route
     *----------------------------------------------------------------

     p LogEnd          b
     d LogEnd          pi

      /free

         ddGrpCode = 'DLT-' + pRte;
         ddSubGrp = '';
         ddRtid = '';
         ddType = '2';

         WrtRteLog();

      /end-free

     p LogEnd          e

     *----------------------------------------------------------------
     *  LogInfo       Log info record
     *----------------------------------------------------------------

     p LogInfo         b
     d LogInfo         pi
     d   rteId                        5a   const
     d   subGroup                    12a   const

      /free

         ddGrpCode = 'DLT-' + pRte;
         ddSubGrp = subGroup;
         ddType = '5';
         ddRtid = rteId;

         WrtRteLog();

      /end-free

     p LogInfo         e

     *----------------------------------------------------------------
     *  LogStart     Start logging for route
     *----------------------------------------------------------------

     p LogStart        b
     d LogStart        pi

      /free

         ddRtid = '';
         ddmrid = '';
         ddGrpId = 0;
         ddGrpCode = 'DLT-' + pRte;
         ddSubGrp = '';
         ddType = '1';

         WrtRteLog();

      /end-free

     p LogStart        e

     *----------------------------------------------------------------
     *  RmvLible    Remove library from library list
     *----------------------------------------------------------------

     p RmvLible        b
     d RmvLible        pi            10I 0
     d   lib                         10A   const varying

      /free

         cmd = 'rmvlible lib(' + lib + ')';

         monitor;
           qcmdexc(cmd: %len(cmd));
         on-error *all;
           return -1;
         endmon;

         return 0;

      /end-free

     p RmvLible        e

     *----------------------------------------------------------------
     *  WrtRteLog  Write GLORTELOG record
     *----------------------------------------------------------------

     p WrtRteLog       b
     d WrtRteLog       pi

     C                   call      'WRTRTELOG'
     C                   parm      iWhse         ddWhse
     C                   parm                    ddRtid
     C                   parm                    ddmrid
     C                   parm                    ddGrpId
     C                   parm                    ddGrpCode
     C                   parm                    ddSubGrp
     C                   parm                    ddType
     C                   parm      ''            ddCurUsr
     C                   parm      #prog         ddpgm
     C                   parm      ''            ddJobqTS
     C                   parm      ''            ddJobqUC

     p WrtRteLog       e
