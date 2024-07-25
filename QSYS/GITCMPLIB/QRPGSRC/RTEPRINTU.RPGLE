      /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RTEPRINTU   Undo Printed Rte - Pgm for SQL procedure of same name
     *  18 September 2013
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650 A*    09/17/13  DAS  6.50
     *      - Created.
     *
650a *    03/06/14  DAS  6.50a
     *      - Added pSessId, pUser, pPgm paramters
     *      - Revised to use CHKIUSE2
     *      - Added call to WRTSESSLOG
     *
650b *    03/11/14  DAS  6.50b
     *      - Changed pWhse to character field.
     *      - Revised to submit this program to jobq.
     *      - Moved call to chkiuse2 into subprocedure
700a *    05/28/15  LMC  7.00a
     *      - Enh: Revised client specific logic with Select.
     *
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
     * Client Custom Changes: PFG Performance Food Group
     *
PFG A*    02/08/19  MLB  PFG
     *      - Each warehouse needs to use their own set of JOBQ's.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Frtehed    uf   e           k disk    usropn
417c Fpirtran4  if   e           k disk
620aAFprexref3  if   e           k disk
650bAFbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

700aA /copy qcopysrc,id#sgc
RFSaA /copy qcopysrc,id#rfs
USFaA /copy qcopysrc,id#usfcorp
PFG A /copy qcopysrc,id#pfg

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650bAD sq              c                   Const('''')

     D error           s               n
     D forever         s               n
     D forevr          s               n
     D $irtn           s              8
650bAD jobq            s               n

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
     D kygrp2          s                   like(ptgrp2)
     D kyrtpo          s                   like(ptrtpo)
     D kywhse          s                   like(rhwhse)
     D trnflg          s              1
650bAD sbmCmd          s           3000    varying
650bAD sbmJob          s             10A
650bAD sbmUser         s             10A
650bAD sbmJobNbr       s              6A
650bAD numWhse         s              3  0

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
650bA /copy qcopysrc,p.qcmdexc
700aA /copy qcopysrc,p.getclien

     D rh134           pr                  extpgm('RH134')
     D  lParm                       136

650bAD QMHRCVPM        PR                  ExtPgm('QMHRCVPM')
650bAD   MsgInfo                  32766A   options(*varsize)
650bAD   MsgInfoLen                  10I 0 const
650bAD   Format                       8A   const
650bAD   StackEntry                  10A   const
650bAD   StackCount                  10I 0 const
650bAD   MsgType                     10A   const
650bAD   MsgKey                       4A   const
650bAD   WaitTime                    10I 0 const
650bAD   MsgAction                   10A   const
650bAD   ErrorCode                32766A   options(*varsize)

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

650bAd CallChkiuse2    pr
     d  cmd                          10    const

650bAD SubmitJob       PR            10I 0
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
650aA*      pSessId     Session id
650aA*      pUser       User
650aA*      pPgm        Calling dictionary.pgm
     *      pWhse       Warehouse
     *      pRtid       Route id
     *      pRte        Route
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
650aMC                   parm                    pSessId          40
650aMC                   parm                    pUser            10
650aMC                   parm                    pPgm             20
650bMC                   parm                    pWhse             3
     C                   parm                    pRtid             5
     C                   parm                    pRte              5
650d C                   parm                    pJobq             5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

650bA    // Convert parameters to numeric
650bA
650bA    monitor;
650bA      numWhse = %dec(pWhse: 3: 0);
650bA    on-error;
650bA      bdtype = 'ERROR';
650bA      bdvalues = 'Whse conversion error: ' + pWhse;
650bA      exsr WrtDebug;
650bA      numWhse = 0;
650bA    endmon;

650bA    // Set jobq flag
650bA
650bA    if %parms >= 8 and pJobq = '*JOBQ';
650bA      jobq = *on;
650bA    else;
650bA      jobq = *off;
650bA    endif;

650bA    // When not running from Jobq ...
650bA
650bA    if not jobq;
650bA
650bA      // Do pre-Jobq checks
650bA
650bA      exsr PreJobqChecks;
650bA      if error;
650bA        return;
650bA      endif;
650bA
650bA      // Submit this program to Jobq
650bA
650bA      exsr SubmitProgram;
650bA      return;
650bA
650bA    endif;

         // Call program to undo route

         $lcmd = '*UNDOWEB';
         $lprg = #prog;
         $lrtn = ' ';
         $lerm = ' ';
         $lwhse = numWhse;
         $lrte  = pRte;
         $lrtid = pRtid;

         monitor;
           rh134 ($lparm);
         on-error;
           pMessage = 'Error calling program RH134';
650cA      bdtype = 'ERROR';
650cA      bdvalues = pMessage;
650cA      exsr WrtDebug;
650bM      CallChkiuse2 ('*CLEAR');
           return;
         endmon;

         if $lrtn <> ' ' and $lrtn <> '*OK';
           pMessage = $lerm;
650cA      bdtype = 'ERROR';
650cA      bdvalues = pMessage;
650cA      exsr WrtDebug;
650bM      CallChkiuse2 ('*CLEAR');
           return;
         endif;

         // Clear inuse flag.

650bM    CallChkiuse2 ('*CLEAR');

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

700aA /free
700aA  begsr *Inzsr;

700aA    getclient(client: clientLoc);

700aA  endsr;
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

650bA*----------------------------------------------------------------
650bA*  PreJobQChecks   Pre-Jobq Checks
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr PreJobQChecks;

         error = *off;

         // Verify route is still at "Printed" status

         exsr getrtehed;
         if error;
             leavesr;
         endif;

         if rhstat <> '4';
             error = *on;
             pMessage = 'Route not at Printed status '
                      + '('
                      + %Trim(rhstat)
                      + ')';
             leavesr;
         endif;

         // Check inuse flag.

         monitor;
650bM      CallChkiuse2 ('*INUSE31');
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

         // Do extra RH140A checks

640aA    exsr rh140aChecks;
640aA    if pMessage <> ' ';
           error = *on;
650bM      CallChkiuse2 ('*CLEAR');
640aA      return;
640aA    endif;

       endsr;
      /end-free

640aA*----------------------------------------------------------------
640aA*  rh140aChecks    Extra checks from RH140A
640aA*----------------------------------------------------------------
640aA
640aAC     rh140aChecks  begsr
417c *
417cAC     trnsky        klist
417cAC                   kfld                    kywhse
417cAC                   kfld                    kygrp2
417cAC                   kfld                    kyrtpo
620aA
620aAC     keypx3        klist
620aAC                   kfld                    rhwhse
620aAC                   kfld                    rhrtid

417cA*    Check If any transactions have been scanned or started.
417cA*
417cAC                   eval      kywhse = rhwhse
417cAC                   eval      kygrp2 = *blanks
417cAC                   movel     rhrtid        kyrtpo
417cAC                   eval      trnflg = *off
417c C     trnsky        setll     pirtran4
417c C                   dow       forevr = forevr
417c C     trnsky        reade     pirtran4                               79
417c C                   if        *in79
417c C                   leave
417c C                   endif
417c C                   if        ptgrp1 <> 'S'
417c C                   iter
417c C                   endif
417c C                   if        ptstat <> '1'
417c C                   eval      trnflg = *on
417c C                   leave
417c C                   endif
417c C                   iter
417c C                   enddo
417cAC                   if        trnflg = *on
417cA*
417cA*    If some transactions have been started, Halt from proceeding
417cA*
417cAC                   eval      pMessage = 'Route '
417cAC                                      + %trimr(rhrte) + ' '
417cAC                                      + 'has started transactions'
417cAC                   leavesr
417cAC                   endif
620aA
620aA*    For a pre-pick route,
620aA*      Cannot undo if already touched by Normal route.
620aA
620aAC     keypx3        setll     prexref3
620aA
620aAC                   dow       forever = forever
620aAC     keypx3        reade     prexref3
620aAC                   if        %eof(prexref3)
620aAC                   leave
620aAC                   endif
620aA
620aAC                   if        pxnrte = ' '
620aAC                   iter
620aAC                   endif
620aA
620aAC                   eval      pMessage = 'Pre-Pick rte '
620aAC                                      + %trim(rhrte) + ' '
620aAC                                      + 'already allocated by '
620aAC                                      + 'Normal rte'
417cAC                   leavesr
620aA
620aAC                   enddo

     C                   endsr

650bA*----------------------------------------------------------------
650bA*  SubmitProgram   Submit Program
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr SubmitProgram;

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
700aM      when client = sgc;
700aM        bfcjobq = 'BFCJOBQ';
RFSaA      when client = rfs;
RFSaA        bfcjobq = 'BFCPCK' + pwhse;
RFSaA        exsr chkjobq;
USFaA      when client = usfcorp;
USFaA        bfcjobq = 'BFCPCKA_' + %trim(clientloc);
RFSaA        exsr chkjobq;

PFG A      when client = pfg;
PFG A        bfcjobq = 'BFCPCKB' + pwhse;
PFG A        exsr chkjobq;

700aA      other;
700aM        bfcjobq = 'BFCJOBQPK';
700aA    endsl;

700aD    //if SubmitJob(#pgm: 'BFCJOBQ':
700aD                 //sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;
700aM    if SubmitJob(#pgm: bfcjobq:
700aM                 sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;

650dA      bdtype = 'ERROR';
650dA      bdvalues = 'sbmcmd:' + %trimr(sbmcmd);
650dA      exsr WrtDebug;
           pMessage = 'Error submitting command ' + #pgm;
650cM      CallChkiuse2('*CLEAR');
           return;

         endif;

650aA    // Write GLOSESSLOG record
650aA
650aA    logText = 'whs:' + pWhse + ','
650aA            + 'nwhse:' + %char(numWhse) + ','
650aA            + 'rtid:' + %trim(pRtid) + ','
650aA            + 'rte:' + %trim(pRte);
650aA    wrtsesslog(pSessId: #pgm: pPgm: pUser: logText:
650aA               sbmJob: sbmUser: sbmJobNbr);

       endsr;
      /end-free

650bA*----------------------------------------------------------------
650bA*  wrtDebug       Write out debug record
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr wrtDebug;

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

650bA*----------------------------------------------------------------
650bA*  SubmitJob   Submit job to job queue
650bA*
650bA*     peName    = name of job to submit
650bA*     peJobQ    = Queue to submit to
650bA*     peCmd     = Command to submit
650bA*     peSbmName = name returned by the submit job command
650bA*     peSbmUser = user returned by the submit job command
650bA*     peSbmNbr  = job number returned by the submit job command
650bA*
650bA*  Returns 0 if successful, or -1 if it failed
650bA*----------------------------------------------------------------
650bAP SubmitJob       B                   export
650bAD SubmitJob       PI            10I 0
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
