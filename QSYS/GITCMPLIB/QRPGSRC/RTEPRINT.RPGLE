417cA /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RTEPRINT    Print Rte - Pgm for SQL procedure of same name
     *  10 October 2009
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
610 A*    10/10/09  DAS  6.10
     *      - Created.
     *
610aA*    05/12/12  DAS  6.40a
     *      - Changed RTEHED to update file to check for lock.
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
     *
700a *    05/19/15  LMC  7.00a
     *      - Enh: Revised client specific logic with Select.
     *
700b *    07/23/15  LMC  7.00b
     *      - Fix: Send *INUSE2 for pick print to chkiuse2
     *
730aA*    09/15/19  DAS  7.30a
     *      - Added JQ WRTRTELOG logic
     *
740aA*    09/22/20  LMC  7.40a
     *      - Enh: will also work for will call routes.               sing
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
     * Client Custom Changes: Dairyland
     *
DRY A*    04/18/17  MLB  DRY
     *      - Each warehouse needs to use their own set of JOBQ's.
     *        Per Kelly R email dated 04.13.17.
     *      - Added DRY to RFS mod.
     *
     *----------------------------------------------------------------
     * Client Custom Changes: PFG Performance Food Group
     *
PFG A*    02/08/19  MLB  PFG
     *      - Each warehouse needs to use their own set of JOBQ's.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    The verification logic was taken from RH130A.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

640aDF*tehed    if   e           k disk    usropn
640aMFrtehed    uf   e           k disk    usropn
650bAFbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

650bA /copy qcopysrc,id#sgc
RFSaA /copy qcopysrc,id#rfs
USFaA /copy qcopysrc,id#usfcorp
DRY A /copy qcopysrc,id#dairyla
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
650bAD bfcjobq         s             10
650bAD client          s             10
650bAD clientloc       s             10
700aAD cmdjobq         s           3000    varying
650aAD logText         s            100
650bAD sbmCmd          s           3000    varying
650bAD sbmJob          s             10A
650bAD sbmUser         s             10A
650bAD sbmJobNbr       s              6A
650bAD numWhse         s              3  0

730aA*----------------------------------------------------------------
730aA*  WRTRTELOG Parameters
730aA*----------------------------------------------------------------
730aA
730aAd rlmrid          s             26
730aAd rlGrpId         s              7  0
730aAd rlGrpCode       s             10
730aAd rlSubGrp        s             12
730aAd rlType          s              1
730aAd rlJobqTS        s             26
730aAd rlJobqUC        s             26

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

650aA /copy qcopysrc,p.chkiuse2
650aA /copy qcopysrc,p.wrtsessl
650bA /copy qcopysrc,p.qcmdexc
650bA /copy qcopysrc,p.getclien
730aA /copy qcopysrc,p.wrtrtelg

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
730aAC                   parm                    pSubGrp          12
730aAC                   parm                    pGrpId           15 5

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

730aA    // Record end of jobq to log
730aA
730aA    if %parms() >= 10;
730aA      rlGrpCode = '*PCKPRNT';
730aA      rlType = '2';
730aA      rlGrpId = pGrpId;
730aA      rlSubGrp = pSubGrp;
730aA      wrtrtelog(numWhse: pRtid: rlmrid: rlGrpId: rlGrpCode: rlSubGrp:
730aA                rlType: pUser: #pgm: rlJobqTS: rlJobqUC);
730aA    endif;

         // Call program to pick and print route

740aA   exsr getrtehed;
740aA   if rhtype = 'W';
740aA     $btype = '*WCPICK1';
740aA     $bprg  = 'GWPICK';
740aA   else;
740aA     $btype = '*PICK1';
740aA     $bprg  = ' ';
740aA   endif;
      /end-free
510bAC                   call(e)   'OR605'
510bAC                   parm      '*PICK   '    $bcmd             8
510bAC                   parm      '*PCKPRNT'    $bcmd2            8
740ADC*                  parm      '*PICK1  '    $btype            8
740AMC                   parm                    $btype            8
510bAC                   parm      '0'           $bjtyp            1
650bMC                   parm      numWhse       $bwhs            15 5
510bAC                   parm      0             $bbat             7 0
510bAC                   parm      ' '           $bstat            1
510bAC                   parm      pRtid         $brtid            5
510bAC                   parm      0             $bord             7 0
510bAC                   parm      0             $brwhs            3 0
510bAC                   parm      ' '           $btrte            5
510bAC                   parm      ' '           $brtn             8
510bAC                   parm      ' '           $bmsg             4
740ADC*                  parm      ' '           $bprg            10
740AMC                   parm                    $bprg            10
      /free

         // Error on call

         if %error;
             error = *on;
             pMessage = 'Error calling program OR605';
650bA        bdtype = 'ERROR';
650bA        bdvalues = pMessage;
650bA        exsr WrtDebug;
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

500sA*----------------------------------------------------------------
500sA*  getrtehed   Get RTEHED record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr getrtehed;

         error = *off;

500sA    // Open rtehed file

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

500sA    // Get rtehed record

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

640aA    unlock rtehed;

       endsr;
      /end-free

650bA*----------------------------------------------------------------
650bA*  PreJobQChecks   Pre-Jobq Checks
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr PreJobQChecks;

         error = *off;

         // Verify route is still at "built" status

         exsr getrtehed;
         if error;
             leavesr;
         endif;

         if rhstat <> '3';
             error = *on;
             pMessage = 'Route not at BUILT status '
                      + '('
                      + %Trim(rhstat)
                      + ')';
             leavesr;
         endif;

         // Set in-use flag

650aA    monitor;
700bD      //CallChkiuse2 ('*INUSE1');
700bM      CallChkiuse2 ('*INUSE2');
650aA    on-error;
           error = *on;
650aA      pMessage = 'Error calling GETIUSE2 program';
650aA      leavesr;
650aA    endmon;

650aA   if $iRtn = '*ERROR';
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
650aA      leavesr;
650aA    endif;

       endsr;
      /end-free

650bA*----------------------------------------------------------------
650bA*  SubmitProgram   Submit Program
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr SubmitProgram;

730aA    // Moved building of sbmCmd to just before submit

         // Determine jobq to use

700aD    //if client = sgc;
700aD      //bfcjobq = 'BFCJOBQ';
700aD    //else;
700aD      //bfcjobq = 'BFCJOBQPK';
700aD    //endif;

700aA    Select;
700aM      when client = sgc;
700aM        bfcjobq = 'BFCJOBQ';
RFSaA      when client = rfs
DRY A        or client = dairyland;
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

730aA    // Record start of jobq to log
730aA
730aA    rlGrpCode = '*PCKPRNT';
730aA    rlType = '1';
730aA    rlGrpId = 0;
730aA    rlSubGrp = 'JQ' + bfcjobq;
730aA    wrtrtelog(numWhse: pRtid: rlmrid: rlGrpId: rlGrpCode: rlSubGrp:
730aA              rlType: pUser: #pgm: rlJobqTS: rlJobqUC);

         // Build call string
730aM    // Moved here from beginning of routine

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
730aM           +      sq + '*JOBQ' + sq + ' '
730aA           +      sq + %trim(rlSubGrp) + sq + ' '
730aA           +      %char(rlGrpId)
                +   ')';

         // Submit job

         if SubmitJob(#pgm: bfcjobq:
                      sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;

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

