      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FR13800      PO Receiving - Print Receiving Report.
     *  10 February 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    02/10/15  LMC  7.00
     *      - Created.
700aA*    04/14/16  LMC  7.00a
     *      - Changed program to submit itself to the jobq.
     *      This change was done because we were unable to ovrprtf
     *      from gui. Error that was occurring - Ovrprtf is not
     *      allowed in a secondary thread. CPF180C.
     *      - Changed pWhse to character field.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jack Palmer Foodservice
JPF A*    07/26/17  LMC  JPF
     *      - Revised to call PO330CL client uses a custom version
     *        which does not use our receiver print program.
     *        other gui clients will call PO330 direct.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Accardi Foods
ACCaA*    11/09/18  LMC  ACCa
     *      - Revised to no longer print the PCM log for this client.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pSuper      Super PO flag
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

416 Afpospo     if   e           k disk
700aAFbfcdebug  o    e           k disk
     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Convert Barcode Parms
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

700aA /copy qcopysrc,p.qcmdexc

700aAD QMHRCVPM        PR                  ExtPgm('QMHRCVPM')
700aAD   MsgInfo                  32766A   options(*varsize)
700aAD   MsgInfoLen                  10I 0 const
700aAD   Format                       8A   const
700aAD   StackEntry                  10A   const
700aAD   StackCount                  10I 0 const
700aAD   MsgType                     10A   const
700aAD   MsgKey                       4A   const
700aAD   WaitTime                    10I 0 const
700aAD   MsgAction                   10A   const
700aAD   ErrorCode                32766A   options(*varsize)

700aA*----------------------------------------------------------------
700aA*  Sub-procedure prototypes
700aA*----------------------------------------------------------------

700aAD SubmitJob       PR            10I 0
700aAD   peName                      10A   const varying
700aAD   peJobQ                      10A   const varying
700aAD   peCmd                     3000A   const varying
700aAD   peSbmName                   10A   options(*nopass)
700aAD   peSbmUser                   10A   options(*nopass)
700aAD   peSbmNbr                     6A   options(*nopass)

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D rprec         E Ds                  Extname(reports)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

JPF A /copy qcopysrc,id#palmer
ACC A /copy qcopysrc,id#acc
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

700aDD*pWhse           s              3p 0
700aMD pWhse           s              3
     D pPo             s              9
     D pSuper          s              1
     D  pOutStr        s           1024    varying

     D client          s             10
     D clientloc       s             10

     D $pWhs           s              3
650gAD $prtn           s              8
650gAD $pdev           s             10
650gAD $pform          s             10
     D $hacmd          s              8
     D $hawhse         s              3  0
     D $lhapo          s              9
     D $lhaitem        s             15
     D $hanew          s              1
     D $hawhse15       s             15  5

650gAD hapo            s              9

700aAD jobq            s               n
700aAD bfcjobq         s             10
700aAD sbmCmd          s           3000    varying
700aAD sbmJob          s             10A
700aAD sbmUser         s             10A
700aAD sbmJobNbr       s              6A
700aAD numWhse         s              3  0
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Called Programs
     *----------------------------------------------------------------
     d @prtpg          c                   const('PO330CL')
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pSuper
     c                   parm                    pOutStr
700aAC                   parm                    pJobq             5

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
700aA    monitor;
700aA      numWhse = %dec(pWhse: 3: 0);
700aA    on-error;
700aA      bdtype = 'ERROR';
700aA      bdvalues = 'Whse conversion error: ' + pWhse;
700aA      exsr WrtDebug;
700aA      numWhse = 0;
700aA    endmon;
        $pform = '*STD';
        $pdev = '*JOB';
        // do we have printer overrides?
        exec sql select * into :rprec
             from reports
             where rpprtf = 'PO330PR';

        If sqlstt = sqlSuccess;
          $pform = rpform;
          $pdev = rpdev;
        endif;
700aA    // Set jobq flag
700aA
700aA    if %parms >= 5 and pJobq = '*JOBQ';
700aA      jobq = *on;
700aA    else;
700aA      jobq = *off;
700aA    endif;
700aA    // When not running from Jobq ...
700aA
700aA    if not jobq;
700aA
700aA      // Submit this program to Jobq
700aA
700aA      exsr SubmitProgram;
700aA      return;
700aA
700aA    endif;
700aA      qcmd = 'OVRPRTF '
700aA           + 'FILE(PO330PR) '
700aA           + 'OUTQ(*DEV) '
700aA           + 'DEV(' + %trim($pdev) + ') '
700aA           + 'FORMTYPE(' + %trim($pform) + ') ';
      /end-free
700aAC                   call      'QCMDEXC'                            78
700aAC                   parm                    qcmd            256
700aAC                   parm      80            qlen             15 5

700aDc*                  move      pwhse         $pwhs             3
JPF Ac                   Select
JPF Ac                   when      client = palmer
JPF Ac                   call      @prtpg
JPF Ac                   parm                    pwhse
JPF Ac                   parm                    ppo
JPF Ac                   parm                    $prtn
JPF Ac                   parm                    $pdev
JPF Ac                   parm                    $pform
JPF Ac                   other
     c                   call      'PO330'
700aDc*                  parm                    $pwhs
700aMc                   parm                    pwhse
     c                   parm                    ppo
JPF Ac                   endsl

      * Now print Haccp log
      * check for new or old haccp
      * check to make sure programs exist or don't do call
     C                   eval      qcmd = 'CHKOBJ '
     C                                  + 'OBJ(HA301) '
     C                                  + 'OBJTYPE(*PGM)'
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd            256
     C                   parm      80            qlen             15 5
     c                   if        *in78 = *off
      * super
      /free
        if psuper = 'Y';
700aD     //setll (pwhse:ppo) pospo;
700aM     setll (numwhse:ppo) pospo;
          dow not %eof(pospo);
700aD       //reade (pwhse:ppo) pospo;
700aM       reade (numwhse:ppo) pospo;
            if not %eof(pospo);
              hapo = pupo;

              exsr PrtLog;
            endif;
          enddo;
        else;
          hapo = ppo;
          exsr PrtLog;
        endif;
      /end-free
     c                   endif


700aA*----------------------------------------------------------------
700aA*  SubmitProgram   Submit Program
700aA*----------------------------------------------------------------
700aA
700aA /free
700aA  begsr SubmitProgram;

700aA    sbmCmd = 'CALL  '
700aA           +   'PGM(' + %trimr(#pgm) + ') '
700aA           +   'PARM('
700aA           +      sq + pwhse + sq + ' '
700aA           +      sq + pPO + sq + ' '
700aA           +      sq + pSuper + sq + ' '
700aA           +      sq + pOutstr + sq + ' '
700aA           +      sq + '*JOBQ' + sq
700aA           +   ')';

700aA    bfcjobq = 'BFCJOBQ';

700aA    if SubmitJob(#pgm: bfcjobq:
700aA                 sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;

700aA      bdtype = 'ERROR';
700aA      bdvalues = 'sbmcmd:' + %trimr(sbmcmd);
700aA      exsr WrtDebug;
700aA      //pMessage = 'Error submitting command ' + #pgm;
700aA      return;

700aA    endif;


700aA  endsr;
700aA /end-free

700aA*----------------------------------------------------------------
700aA*  wrtDebug       Write out debug record
700aA*----------------------------------------------------------------
700aA
700aA /free
700aA  begsr wrtDebug;

700aA    bdaddts = %timestamp();
700aA    bdaddpgm = #pgm;
700aA    bdaddcusr = #curruser;
700aA    bdaddjusr = #user;
700aA    bdaddjob = #job;
700aA    bdaddnbr = #jobnbr;

700aA    write(e) bdrec;

700aA  endsr;
700aA /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

     *
     *----------------------------------------------------------------
     *
     *  PrtLog   Print PCM log.
     *
     c     PrtLog        begsr
     C*
ACCaA * do not Print ha300 for Accardi
ACCaA /free
ACCaA   Select;
ACCaA     When client = ACCARDI;
ACCaA     other;
ACCaA /end-free
     c                   if        *in78 = *off
     c                   call      'HA301'
     c                   parm      ' '           $hacmd            8
700aDc*                  parm      pwhse         $hawhse           3 0
700aMc                   parm      numwhse       $hawhse           3 0
     c                   parm      hapo          $lhapo            9
     c                   parm      ' '           $lhaitem         15
     c                   parm                    $hanew            1
     c                   if         $hanew = '1'
     c                   call      'HA300'
     c                   parm      '*PRINT'      $hacmd            8
700aDc*                  parm      pwhse         $hawhse15        15 5
700aMc                   parm      numwhse       $hawhse15        15 5
     c                   parm      hapo          $lhapo            9
     c                   parm      ' '           $lhaitem         15
     c                   else
     c                   endif
     c                   else
     c                   eval      *in78 = *off
     c                   endif
ACCaA /free
ACCaA   endsl;
ACCaA /end-free
     c                   endsr
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

700aA*----------------------------------------------------------------
700aA*  SubmitJob   Submit job to job queue
700aA*
700aA*     peName    = name of job to submit
700aA*     peJobQ    = Queue to submit to
700aA*     peCmd     = Command to submit
700aA*     peSbmName = name returned by the submit job command
700aA*     peSbmUser = user returned by the submit job command
700aA*     peSbmNbr  = job number returned by the submit job command
700aA*
700aA*  Returns 0 if successful, or -1 if it failed
700aA*----------------------------------------------------------------
700aAP SubmitJob       B                   export
700aAD SubmitJob       PI            10I 0
700aAD   peName                      10A   const varying
700aAD   peJobQ                      10A   const varying
700aAD   peCmd                     3000A   const varying
700aAD   peSbmName                   10A   options(*nopass)
700aAD   peSbmUser                   10A   options(*nopass)
700aAD   peSbmNbr                     6A   options(*nopass)

700aA*  Local Variables

700aAD cmd             s           3000    varying

700aAD dsM1            DS
700aAD  dsM1_BytRtn                  10I 0
700aAD  dsM1_BytAvl                  10I 0
700aAD  dsM1_MsgSev                  10I 0
700aAD  dsM1_MsgID                    7A
700aAD  dsM1_MsgType                  2A
700aAD  dsM1_MsgKey                   4A
700aAD  dsM1_Reserv1                  7A
700aAD  dsM1_CCSID_st                10I 0
700aAD  dsM1_CCSID                   10I 0
700aAD  dsM1_DtaLen                  10I 0
700aAD  dsM1_DtaAvl                  10I 0
700aAD  dsM1_Dta                    256A

700aAD dsEC            DS
700aAD  dsECBytesP             1      4I 0 INZ(%size(dsEC))
700aAD  dsECBytesA             5      8I 0 INZ(0)
700aAD  dsECMsgID              9     15
700aAD  dsECReserv            16     16
700aAD  dsECMsgDta            17    256

700aAD wwMsgKey        S              4A
700aAD wwJobNo         S             26A

700aA /free

700aA    // Submit job

700aA    cmd = 'SBMJOB CMD(' + peCmd + ') ' +
700aA          'JOBQ(' + peJobQ +') ' +
700aA          'JOB(' + peName+ ')';

700aA    monitor;
700aA      qcmdexc(%trim(cmd): %len(%trim(cmd)));
700aA    on-error *all;
700aA      return -1;
700aA    endmon;

700aA    // Look for a success message

700aA    wwMsgKey = *ALLx'00';
700aA    dou dsECBytesA>0 or dsM1_MsgID='CPC1221';
700aA      QMHRCVPM(dsM1: %size(dsM1): 'RCVM0100':
700aA               '*': 0: '*PRV': wwMsgKey: 0: '*SAME':
700aA               dsEC);
700aA      wwMsgKey = dsM1_MsgKey;
700aA    enddo;

700aA    if dsECBytesA>0;
700aA      return -1;
700aA    endif;

700aA    // Grab the job info from the response

700aA    if dsM1_DtaAvl >= 26;
700aA      wwJobNo = %subst(dsM1_Dta:1:26);
700aA    else;
700aA      wwJobNo = *blanks;
700aA    endif;

700aA    if %parms >= 4;
700aA      peSbmName = %subst(wwJobNo:1:10);
700aA    endif;

700aA    if %parms >= 5;
700aA      peSbmUser = %subst(wwJobNo:11:10);
700aA    endif;

700aA    if %parms >= 6;
700aA      peSbmNbr = %subst(wwJobNo:21:6);
700aA    endif;

700aA    return 0;

700aA /end-free

700aAP                 E
