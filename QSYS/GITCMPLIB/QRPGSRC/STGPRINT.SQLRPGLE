      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
720 AH Bnddir('QC2LE':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  STGPRINT    Print Staged Routes- Pgm for SQL procedure of same name
     *  28 April 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    04/28/15  LMC  7.00
     *      - Created.
     *
700a *    05/19/15  LMC  7.00a
     *      - Enh: Revised client specific logic with Select.
     *
720 A*    01/23/18  KDE  7.20
     *      - Add code to use getmicrotime instead of sql time
     *        Getmicrotime was changed to return proper time based
     *        on use of TimeZone/400
     *
740  *    02/04/19  KDE  7.40
     *      - Enh: Ignore GLOSESS when coming from TBW600
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Reinhart  Custom Changes
     *
RFSa *    05/19/15  LMC  RFSa
     *      - Each warehouse needs to use their own set of JOBQ's.
     *
     *----------------------------------------------------------------
     * US Foods  Custom Changes
     *
USFa *    05/19/15  LMC  USFa
     *      - Each branch needs to use their own set of JOBQ's.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Notes
     *
     *    The verification logic was taken from RH135A.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Frtehed    uf   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     Fglosess   if   e           k disk
     Frtestg    o    e           k disk
     Freports   if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#sgc
RFSaA /copy qcopysrc,id#rfs
USFaA /copy qcopysrc,id#usfcorp

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

720 AD CurrStampsys    s               z
720 AD CurrStampuc     s               z
     D sq              c                   Const('''')

     D error           s               n
     D jobq            s               n

     D $irtn           s              8
     D $iuText10       s             10
     D $iuText30       s             30
     D $iuCmd          s              8
     D $iuPgm          s             20
     D $iuUser         s             10
     D $iuSessId       s             40
     D $iuJobName      s             10
     D $iuJobNbr       s              6
     D $iuJobUser      s             10
     D $iuStamp        s             26
     D $prtn           s              8
     D bfcjobq         s             10
     D client          s             10
     D clientloc       s             10
700aAD cmdjobq         s           3000    varying
     D logText         s            100
     D sbmCmd          s           3000    varying
     D sbmJob          s             10A
     D sbmUser         s             10A
     D sbmJobNbr       s              6A
     D numWhse         s              3  0
     D wkprtf          s             10
     D $swhse          s             15  5

     D holdts          s               z
     D holduc          s               z
     D forever         s               n

     D RteChar         s              5    varying
     D RouteChar       s              5    varying
     D delimiter       s              1    varying

     D i               s              5p 0
     D j               s              2p 0
     D RteBeg          s              5p 0
     D RteEnd          s              5p 0
     D RteLen          s              5p 0
     D RtePos          s              5p 0
     D RouteBeg        s              5p 0
     D RouteEnd        s              5p 0
     D RouteLen        s              5p 0
     D RoutePos        s              5p 0

     D Prte            s              5
     D Prtid           s              5
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------

     D Routes          s              5    dim(99)
     D RouteIDs        s              5    dim(99)
     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.chkiuse2
      /copy qcopysrc,p.wrtsessl
      /copy qcopysrc,p.qcmdexc
      /copy qcopysrc,p.getclien
720 A /copy qcopysrc,p.bfcdteti

     D QMHRCVPM        PR                  ExtPgm('QMHRCVPM')
     D   MsgInfo                  32766A   options(*varsize)
     D   MsgInfoLen                  10I 0 const
     D   Format                       8A   const
     D   StackEntry                  10A   const
     D   StackCount                  10I 0 const
     D   MsgType                     10A   const
     D   MsgKey                       4A   const
     D   WaitTime                    10I 0 const
     D   MsgAction                   10A   const
     D   ErrorCode                32766A   options(*varsize)

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CallChkiuse2    pr
     d  cmd                          10    const

     D SubmitJob       PR            10I 0
     D   peName                      10A   const varying
     D   peJobQ                      10A   const varying
     D   peCmd                     3000A   const varying
     D   peSbmName                   10A   options(*nopass)
     D   peSbmUser                   10A   options(*nopass)
     D   peSbmNbr                     6A   options(*nopass)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session id
     *      pUser       User
     *      pPgm        Calling dictionary.pgm
     *      pWhse       Warehouse
     *      pJson       String of routes
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage         80
     C                   parm                    pSessId          40
     C                   parm                    pUser            10
     C                   parm                    pPgm             20
     C                   parm                    pWhse             3
     C                   parm                    pJson           999
     C                   parm                    pJobq             5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

         // Convert parameters to numeric

         monitor;
           numWhse = %dec(pWhse: 3: 0);
         on-error;
           bdtype = 'ERROR';
           bdvalues = 'Whse conversion error: ' + pWhse;
           exsr WrtDebug;
           numWhse = 0;
         endmon;

         // Set jobq flag

         if %parms >= 8 and pJobq = '*JOBQ';
           jobq = *on;
         else;
           jobq = *off;
         endif;


         if not jobq;

         // process Json for Route/Route ID
         exsr ProcessJson;

         // load rtestg file
         exsr LoadRTESTG;
         if error;
           return;
         endif;

         // print truck summary
         exsr PrintTruckSum;

         // Process the routes
         exsr ProcessRoutes;


           return;

         endif;

      /end-free
      /free

         // Error on call

         if %error;
             error = *on;
             //pMessage = 'Error calling program OR605';
             bdtype = 'ERROR';
             bdvalues = pMessage;
             exsr WrtDebug;
             return;
         endif;

         return;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);
720 D    //exec sql values (current timestamp,
720 D    //                 (current timestamp - current timezone))
720 D    //         into :holdts, :holduc;
720 A   getmicrotime(currstampuc:currstampsys);
720 A   holdts = currstampsys;
720 A   holduc = currstampuc;

       endsr;
      /end-free

700aA*----------------------------------------------------------------
700aA*  chkjobq     Check to make sure jobq exists
700aA*----------------------------------------------------------------
700aA
700aA /free
700aA  begsr chkjobq;

700aA    // check for jobq
700aA    cmdjobq = 'CHKOBJ ' +
700aA    'OBJ('+ bfcjobq +') ' +
700aA    'OBJTYPE(*JOBQ)';

700aA    monitor;
700aA      qcmdexc(%trim(cmdjobq): %len(%trim(cmdjobq)));
700aA    on-error *all;
700aA      bfcjobq = 'BFCJOBQPK';
700aA    endmon;
700aA  endsr;
700aA /end-free

     *----------------------------------------------------------------
     *  getrtehed   Get RTEHED record
     *----------------------------------------------------------------

      /free
       begsr getrtehed;

         error = *off;

         // Open rtehed file

         if not %open(rtehed);
             open(e) rtehed;
             if %error;
                 error = *on;
                 pMessage = 'Error occured trying to '
                          + 'open file RTEHED in pgm '
                          + #pgm;
                 leavesr;
             endif;
         endif;

         // Get rtehed record

         chain(e) (numWhse: pRtid) rtehed;

         if %status = 01218; //locked
             error = *on;
             pMessage = 'Route locked by another user '
                      + '('
                      + %Trim(%editc(numWhse:'Z'))
                      + '/'
                      + %Trim(pRte)
                      + '/'
                      + %Trim(pRtid)
                      + ')';
             leavesr;
         endif;

         if not %found;
             error = *on;
             pMessage = 'Route not found '
                      + '('
                      + %Trim(%editc(numWhse:'Z'))
                      + '/'
                      + %Trim(pRte)
                      + '/'
                      + %Trim(pRtid)
                      + ')';
             leavesr;
         endif;

         unlock rtehed;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  LoadRTESTG    Load RTESTG file with routes
     *----------------------------------------------------------------

      /free
       begsr LoadRTESTG;
         // process all routes from the arry loaded in ProcessJson
         j = 1;
         dow forever = forever;
           if routes(j) <> ' ';
             Prte = routes(j);
             Prtid = routeids(j);
             exsr PreJobQChecks;
             if error;
               leavesr;
             endif;
             rsgwhse = numWhse;
             rsgrte  = routes(j);
             rsgrtid = routeids(j);
             rsgstat = 'S';
             rsgkydts = holdts;
             rsgaddts = holdts;
             rsgaddus = puser;
             write rsgrec;
             j += 1;
           else;
             leave;
           endif;
         enddo;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  PrintTruckSum Print truck summary for each route
     *----------------------------------------------------------------

      /free
       begsr PrintTruckSum;
         // process all routes from the arry loaded in ProcessJson
         j = 1;
         dow forever = forever;
           if routes(j) <> ' ';
             Prte = routes(j);
             Prtid = routeids(j);
             $dev = *blanks;
             $form = *blanks;
             wkprtf = 'PS311PR';
             chain (wkprtf) reports;
             if %found(reports);
               $dev = rpdev;
               $form = rpform;
             else;
               $dev = '*JOB      ';
               $form = '*STD      ';
             endif;
      /end-free
     C                   call      'PS310CL'
     C                   parm                    pWhse
     C                   parm                    Prtid
     C                   parm                    $prtn
     C                   parm                    $dev             10
     C                   parm                    $form            10
      /free
             j += 1;
           else;
             leave;
           endif;
         enddo;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  PreJobQChecks   Pre-Jobq Checks
     *----------------------------------------------------------------

      /free
       begsr PreJobQChecks;

         error = *off;

         // Verify route is still at "built" status

         exsr getrtehed;
         if error;
             leavesr;
         endif;

         if rhstat <> 'S';
             error = *on;
             pMessage = 'Route not at STAGED status '
                      + '('
                      + %Trim(rhstat)
                      + ')';
             leavesr;
         endif;

         // Set in-use flag

         monitor;
           CallChkiuse2 ('*INUSE2');
         on-error;
           error = *on;
           pMessage = 'Error calling GETIUSE2 program';
           leavesr;
         endmon;

        if $iRtn = '*ERROR';
           error = *on;
           pMessage = 'Route in use - ' + %trimr($iuText30) + ' '
                    + '('
                    + %Trim(%editc(numWhse:'Z'))
                    + '/'
                    + %Trim(pRte)
                    + '/'
                    + %Trim(pRtid)
                    + '/'
                    + %Trim($iuUser)
                    + '/'
                    + %Trim($iuSessId)
                    + ')';
           leavesr;
         endif;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  ProcessJSON   Process JSON string
     *----------------------------------------------------------------

      /free
       begsr ProcessJSON;

         if %len(pJSON) = 0;
           leavesr;
         endif;

740 A    // TBW600 send it's program name nd timestamp as session
740 A    if %subst(psessid:1:6)<>'TBW600';
           chain (pSessId) glosess;
           if not %found(glosess);
             leavesr;
           endif;
740 A    endif;

         i = 1;
         j = 0;
         dow forever = forever;

           // Get next Route info

           RtePos = %scan('"Rte': pJSON: i);
           if RtePos = 0;
             leave;
           endif;

           // Get end of Rte field id
           RtePos = %scan('":"': pJSON: RtePos);
           if RtePos = 0;
             leave;
           endif;
           // Calculate beginning of Rte code

           RteBeg = RtePos + 3;

           // Get end of id code

           RteEnd = %scan('",': pJSON: RteBeg);
           if RteEnd = 0;
             leave;
           endif;

           // Calculate length of id code

           RteLen = RteEnd - RteBeg;
           //RteLen = 5;

           // Get id

           RteChar = %subst(pJSON: RteBeg: RteLen);
           j += 1;
           Routes(j) = RteChar;

           // Calculate beginning of Routeid

           RtePos = %scan('"Routeid': pJSON: RteEnd);
           if RtePos = 0;
             leave;
           endif;

           // Get end of Routeid field id
           RtePos = %scan('":"': pJSON: RtePos);
           if RtePos = 0;
             leave;
           endif;

           // Calculate beginning of Route Id Code

           RteBeg = RtePos + 3;

           // Get end of id code

           RteEnd = %scan('",': pJSON: RteBeg);
           if RteEnd = 0;
             //leave;
           endif;

           // Calculate length of id code

           RteLen = 5;

           // Get id

           RouteChar = %subst(pJSON: RteBeg: RteLen);
           RouteIDs(j) = RouteChar;

           // RteEnd = 0, we are done extracting routes from JSON.
           if RteEnd = 0;
             leave;
           endif;

           i = RteEnd;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ProcessRoutes Process the Routes
     *----------------------------------------------------------------

      /free
       begsr ProcessRoutes;
         $swhse = numwhse;
      /end-free
     C                   call      'RH530C2'
     C                   parm                    $pcmd             8
     C                   parm                    $pcmd2            8
     C                   parm                    $swhse
     C                   parm                    rsgkydts
     C                   parm                    $srtn             8
     C                   parm                    $grpid            7 0
     C                   parm                    $jobqts          26
     C                   parm                    $jobquc          26
      /free
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  SubmitProgram   Submit Program
     *----------------------------------------------------------------

      /free
       begsr SubmitProgram;

         sbmCmd = 'CALL  '
                +   'PGM(' + %trimr(#pgm) + ') '
                +   'PARM('
                +      sq + pMessage + sq + ' '
                +      sq + pSessId + sq + ' '
                +      sq + pUser + sq + ' '
                +      sq + pPgm + sq + ' '
                +      sq + pWhse + sq + ' '
                +      sq + pRtid + sq + ' '
                +      sq + pRte + sq + ' '
                +      sq + '*JOBQ' + sq
                +   ')';

700aD    //if client = sgc;
700aD      //bfcjobq = 'BFCJOBQ';
700aD    //else;
700aD      //bfcjobq = 'BFCJOBQPK';
700aD    //endif;

700aA    Select;
700aM      when client = sgc;
700aM        bfcjobq = 'BFCJOBQ';
RFSaA      when client = rfs;
RFSaA        bfcjobq = 'BFCPCK' + pwhse;
RFSaA        exsr chkjobq;
USFaA      when client = usfcorp;
USFaA        bfcjobq = 'BFCPCKA_' + %trim(clientloc);
RFSaA        exsr chkjobq;
700aA      other;
700aM        bfcjobq = 'BFCJOBQPK';
700aA    endsl;

         if SubmitJob(#pgm: bfcjobq:
                      sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;

           bdtype = 'ERROR';
           bdvalues = 'sbmcmd:' + %trimr(sbmcmd);
           exsr WrtDebug;
           pMessage = 'Error submitting command ' + #pgm;
           CallChkiuse2('*CLEAR');
           return;

         endif;

         // Write GLOSESSLOG record

         logText = 'whs:' + pWhse + ','
                 + 'nwhse:' + %char(numWhse) + ','
                 + 'rtid:' + %trim(pRtid) + ','
                 + 'rte:' + %trim(pRte);
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText:
                    sbmJob: sbmUser: sbmJobNbr);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtDebug       Write out debug record
     *----------------------------------------------------------------

      /free
       begsr wrtDebug;

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
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CallChkiuse2  Call CHKIUSE2
     *----------------------------------------------------------------

     p CallChkiuse2    b
     d CallChkiuse2    pi
     d  cmd                          10    const

      /free

         chkiuse2 (cmd: numWhse: pRtid:
                   pPgm: pUser: pSessId: $irtn:
                   $iuText10: $iuText30: $iuCmd: $iuPgm:
                   $iuUser: $iuSessId: $iuJobName: $iuJobNbr:
                   $iuJobUser: $iuStamp);

      /end-free

     p CallChkiuse2    e

     *----------------------------------------------------------------
     *  SubmitJob   Submit job to job queue
     *
     *     peName    = name of job to submit
     *     peJobQ    = Queue to submit to
     *     peCmd     = Command to submit
     *     peSbmName = name returned by the submit job command
     *     peSbmUser = user returned by the submit job command
     *     peSbmNbr  = job number returned by the submit job command
     *
     *  Returns 0 if successful, or -1 if it failed
     *----------------------------------------------------------------
     P SubmitJob       B                   export
     D SubmitJob       PI            10I 0
     D   peName                      10A   const varying
     D   peJobQ                      10A   const varying
     D   peCmd                     3000A   const varying
     D   peSbmName                   10A   options(*nopass)
     D   peSbmUser                   10A   options(*nopass)
     D   peSbmNbr                     6A   options(*nopass)

     *  Local Variables

     D cmd             s           3000    varying

     D dsM1            DS
     D  dsM1_BytRtn                  10I 0
     D  dsM1_BytAvl                  10I 0
     D  dsM1_MsgSev                  10I 0
     D  dsM1_MsgID                    7A
     D  dsM1_MsgType                  2A
     D  dsM1_MsgKey                   4A
     D  dsM1_Reserv1                  7A
     D  dsM1_CCSID_st                10I 0
     D  dsM1_CCSID                   10I 0
     D  dsM1_DtaLen                  10I 0
     D  dsM1_DtaAvl                  10I 0
     D  dsM1_Dta                    256A

     D dsEC            DS
     D  dsECBytesP             1      4I 0 INZ(%size(dsEC))
     D  dsECBytesA             5      8I 0 INZ(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256

     D wwMsgKey        S              4A
     D wwJobNo         S             26A

      /free

         // Submit job

         cmd = 'SBMJOB CMD(' + peCmd + ') ' +
               'JOBQ(' + peJobQ +') ' +
               'JOB(' + peName+ ')';

         monitor;
           qcmdexc(%trim(cmd): %len(%trim(cmd)));
         on-error *all;
           return -1;
         endmon;

         // Look for a success message

         wwMsgKey = *ALLx'00';
         dou dsECBytesA>0 or dsM1_MsgID='CPC1221';
           QMHRCVPM(dsM1: %size(dsM1): 'RCVM0100':
                    '*': 0: '*PRV': wwMsgKey: 0: '*SAME':
                    dsEC);
           wwMsgKey = dsM1_MsgKey;
         enddo;

         if dsECBytesA>0;
           return -1;
         endif;

         // Grab the job info from the response

         if dsM1_DtaAvl >= 26;
           wwJobNo = %subst(dsM1_Dta:1:26);
         else;
           wwJobNo = *blanks;
         endif;

         if %parms >= 4;
           peSbmName = %subst(wwJobNo:1:10);
         endif;

         if %parms >= 5;
           peSbmUser = %subst(wwJobNo:11:10);
         endif;

         if %parms >= 6;
           peSbmNbr = %subst(wwJobNo:21:6);
         endif;

         return 0;

      /end-free

     P                 E
