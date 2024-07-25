      /copy *libl/qcopysrc,hspecs
650cAH DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RTEBUILDU   Undo Built Rte - Pgm for SQL procedure of same name
     *  18 September 2013
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650 A*    09/17/13  DAS  6.50
     *      - Created.
     *
650aA*    02/14/14  DAS  6.50a
     *      - Added pSessId, pUser, pPgm.
     *      - Revised to use CHKIUSE2
     *      - Added call to WRTSESSLOG
     *
650b *    03/05/14  DAS  6.50b
     *      - Moved pSessId, pUser, pPgm paramters
     *
650c *    03/11/14  DAS  6.50c
     *      - Changed pWhse to character field.
     *      - Revised to submit this program to jobq.
     *      - Moved call to chkiuse2 into subprocedure
     *
700a *    05/28/15  LMC  7.00a
     *      - Enh: Revised program to add support for Client id
     *
700b *    05/28/15  LMC  7.00b
     *      - Enh: Revised to undo staged routes also.
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
     * PFG Performance Food Group - Custom Changes
     *
PFG A*    02/08/19  MLB  PFG
     *      - Each branch needs to use their own set of JOBQ's.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Frtehed    uf   e           k disk    usropn
650cAFbfcdebug  o    e           k disk

700aA*----------------------------------------------------------------
700aA*  Customer id
700aA*----------------------------------------------------------------

RFSaA /copy qcopysrc,id#rfs
USFaA /copy qcopysrc,id#usfcorp
PFG A /copy qcopysrc,id#pfg

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650cAD sq              c                   Const('''')

     D error           s               n
650cAD jobq            s               n

650aAD $irtn           s              8
650aAD $iuText10       s             10
650aAD $iuText30       s             30
650aAD $iuCmd          s              8
650aAD $iuPgm          s             20
650aAD $iuUser         s             10
650aAD $iuSessId       s             40
650aAD $iuJobName      s             10
650aAD $iuJobNbr       s              6
650aAD $iuJobUser      s             10
650aAD $iuStamp        s             26
700aAD bfcjobq         s             10
700aAD client          s             10
700aAD clientloc       s             10
700aAD cmdjobq         s           3000    varying
650aAD logText         s            100
650cAD sbmCmd          s           3000    varying
650cAD sbmJob          s             10A
650cAD sbmUser         s             10A
650cAD sbmJobNbr       s              6A
650cAD numWhse         s              3  0

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80

     *   Redefine key

     D  $lwhse                19     21  0
     D  $lrte                 22     26
     D  $lrtid                27     31

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

650aM /copy qcopysrc,p.chkiuse2
650aA /copy qcopysrc,p.wrtsessl
650cA /copy qcopysrc,p.qcmdexc
700aA /copy qcopysrc,p.getclien

     D rh134           pr                  extpgm('RH134')
     D  lParm                       136

650cAD QMHRCVPM        PR                  ExtPgm('QMHRCVPM')
650cAD   MsgInfo                  32766A   options(*varsize)
650cAD   MsgInfoLen                  10I 0 const
650cAD   Format                       8A   const
650cAD   StackEntry                  10A   const
650cAD   StackCount                  10I 0 const
650cAD   MsgType                     10A   const
650cAD   MsgKey                       4A   const
650cAD   WaitTime                    10I 0 const
650cAD   MsgAction                   10A   const
650cAD   ErrorCode                32766A   options(*varsize)

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

650cAd CallChkiuse2    pr
650cAd  cmd                          10    const

650cAD SubmitJob       PR            10I 0
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
     *      pWhse    Warehouse
650bM*      pSessId  Session id
650bM*      pUser    User
650bM*      pPgm     Calling dictionary.pgm
     *      pRtid    Route id
     *      pRte     Route
650cA*      pJobq    *JOBQ when submitted to jobq from this program.
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
650bMC                   parm                    pSessId          40
650bMC                   parm                    pUser            10
650bMC                   parm                    pPgm             20
650cMC                   parm                    pWhse             3
     C                   parm                    pRtid             5
     C                   parm                    pRte              5
650cAC                   parm                    pJobq             5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

650cA    // Convert parameters to numeric
650cA
650cA    monitor;
650cA      numWhse = %dec(pWhse: 3: 0);
650cA    on-error;
650cA      bdtype = 'ERROR';
650cA      bdvalues = 'Whse conversion error: ' + pWhse;
650cA      exsr WrtDebug;
650cA      numWhse = 0;
650cA    endmon;

650cA    // Set jobq flag
650cA
650cA    if %parms >= 8 and pJobq = '*JOBQ';
650cA      jobq = *on;
650cA    else;
650cA      jobq = *off;
650cA    endif;

650cA    // When not running from Jobq ...
650cA
650cA    if not jobq;
650cA
650cA      // Do pre-Jobq checks
650cA
650cA      exsr PreJobqChecks;
650cA      if error;
650cA        return;
650cA      endif;
650cA
650cA      // Submit this program to Jobq
650cA
650cA      exsr SubmitProgram;
650cA      return;
650cA
650cA    endif;

         // Call program to undo route

         $lcmd = '*UNDOWEB';
         $lprg = #prog;
         $lrtn = ' ';
         $lerm = ' ';
650dM    $lwhse = numWhse;
         $lrte  = pRte;
         $lrtid = pRtid;

         monitor;
           rh134 ($lparm);
         on-error;
           pMessage = 'Error calling program RH134';
650cA      bdtype = 'ERROR';
650cA      bdvalues = pMessage;
650cA      exsr WrtDebug;
650cM      CallChkiuse2('*CLEAR');
           return;
         endmon;

         if $lrtn <> ' ' and $lrtn <> '*OK';
           pMessage = $lerm;
650cA      bdtype = 'ERROR';
650cA      bdvalues = pMessage;
650cA      exsr WrtDebug;
650cM      CallChkiuse2('*CLEAR');
           return;
         endif;

         // Clear inuse flag.

650cM    CallChkiuse2('*CLEAR');

         return;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------
700aA*----------------------------------------------------------------
700aA*  *INZSR    Initialization subroutine
700aA*----------------------------------------------------------------
700aA
700aA /free
700aA  begsr *inzsr;

700aA   getclient(client: clientLoc);

       endsr;
700aA /end-free

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
700aA      bfcjobq = 'BFCJOBQ';
700aA    endmon;
700aA  endsr;
700aA /end-free

     *----------------------------------------------------------------
     *  GetRteHed   Get RTEHED record
     *----------------------------------------------------------------

      /free
       begsr GetRteHed;

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

650cA*----------------------------------------------------------------
650cA*  PreJobQChecks   Pre-Jobq Checks
650cA*----------------------------------------------------------------
650cA
650cA /free
650cA  begsr PreJobQChecks;

         error = *off;

         // Verify route is still at "built" status

         exsr getrtehed;
         if error;
             leavesr;
         endif;

700bD    //if rhstat <> '3';
700bM    if rhstat <> '3' and rhstat <> 'S';
             error = *on;
             pMessage = 'Route not at Built status '
                      + '('
                      + %Trim(rhstat)
                      + ')';
             leavesr;
         endif;

         // Check inuse flag.

         monitor;
650cM      CallChkiuse2('*INUSE21');
         on-error;
           error = *on;
650aM      pMessage = 'Error calling GETIUSE2 program';
           leavesr;
         endmon;

650aM    if $iRtn = '*ERROR';
           error = *on;
650aA      pMessage = 'Route in use - ' + %trimr($iuText30) + ' '
650aA               + '('
650aA               + %Trim(%editc(numWhse:'Z'))
650aA               + '/'
650aA               + %Trim(pRte)
650aA               + '/'
650aA               + %Trim(pRtid)
650aA               + '/'
650aA               + %Trim($iuUser)
650aA               + '/'
650aA               + %Trim($iuSessId)
650aA               + ')';
           leavesr;
         endif;

       endsr;
      /end-free

650cA*----------------------------------------------------------------
650cA*  SubmitProgram   Submit Program
650cA*----------------------------------------------------------------
650cA
650cA /free
650cA  begsr SubmitProgram;

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

700aA    Select;
RFSaA      when client = rfs;
RFSaA        bfcjobq = 'BFCALC' + pwhse;
RFSaA        exsr chkjobq;

USFaA      when client = usfcorp;
USFaA        bfcjobq = 'BFCALCA_' + %trim(clientloc);
USFaA        exsr chkjobq;

PFG A      when client = pfg;
PFG A        bfcjobq = 'BFCALCB' + pwhse;
PFG A        exsr chkjobq;

700aA      other;
700aA        bfcjobq = 'BFCJOBQ';
700aA    endsl;

700aD    //if SubmitJob(#pgm: 'BFCJOBQ':
700aD                 //sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;
700aM    if SubmitJob(#pgm: bfcjobq:
700aM                 sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;

650cA      bdtype = 'ERROR';
650cA      bdvalues = 'sbmcmd:' + %trimr(sbmcmd);
650cA      exsr WrtDebug;
           pMessage = 'Error submitting command ' + #pgm;
650cM      CallChkiuse2('*CLEAR');
           return;

         endif;

650aA    // Write GLOSESSLOG record
650aA
650aA    logText = 'whs:' + pWhse + ','
650aA            + 'rtid:' + %trim(pRtid) + ','
650aA            + 'rte:' + %trim(pRte);
650aA    wrtsesslog(pSessId: #pgm: pPgm: pUser: logText:
650aA               sbmJob: sbmUser: sbmJobNbr);

       endsr;
      /end-free

650cA*----------------------------------------------------------------
650cA*  wrtDebug       Write out debug record
650cA*----------------------------------------------------------------
650cA
650cA /free
650cA  begsr wrtDebug;

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

650aM    chkiuse2 (cmd: numWhse: pRtid:
650aM              pPgm: pUser: pSessId: $irtn:
650aM              $iuText10: $iuText30: $iuCmd: $iuPgm:
650aM              $iuUser: $iuSessId: $iuJobName: $iuJobNbr:
650aM              $iuJobUser: $iuStamp);

      /end-free

     p CallChkiuse2    e

650cA*----------------------------------------------------------------
650cA*  SubmitJob   Submit job to job queue
650cA*
650cA*     peName    = name of job to submit
650cA*     peJobQ    = Queue to submit to
650cA*     peCmd     = Command to submit
650cA*     peSbmName = name returned by the submit job command
650cA*     peSbmUser = user returned by the submit job command
650cA*     peSbmNbr  = job number returned by the submit job command
650cA*
650cA*  Returns 0 if successful, or -1 if it failed
650cA*----------------------------------------------------------------
650cAP SubmitJob       B                   export
650cAD SubmitJob       PI            10I 0
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
