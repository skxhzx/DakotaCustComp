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
     *  FR14700      PO Receiving - Print Produce Labels
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
710aA*    10/10/18  DAS  7.20a
     *      - Added optional parameter for item and qty.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
720aA*      pItem       Item (optional)
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

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

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

700aDD*pWhse           s              3p 0
700aMD pWhse           s              3
     D pPo             s              9
     D  pOutStr        s           1024    varying

     D client          s             10
     D clientloc       s             10

700aDD*$pWhs           s              3
     D $prtn           s              8
     D $pdev           s             10
     D $pform          s             10
     D $hacmd          s              8
     D $hawhse         s              3  0
     D $lhapo          s              9
     D $lhaitem        s             15
     D $hanew          s              1
     D $hawhse15       s             15  5
720aAD $pitem          s             15

     D hapo            s              9


700aAD jobq            s               n
700aAD bfcjobq         s             10
700aAD sbmCmd          s           3000    varying
700aAD sbmJob          s             10A
700aAD sbmUser         s             10A
700aAD sbmJobNbr       s              6A
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Called Programs
     *----------------------------------------------------------------
     d @lblpg          c                   const('LB401')
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pOutStr
700aAC                   parm                    pJobq             5
720aAC                   parm                    pItem            15
720aAC                   parm                    pQty              5

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
        $pform = '*STD';
        $pdev = '*JOB';
        // do we have printer overrides?
        exec sql select * into :rprec
             from reports
             where rpprtf = 'PRODUCE';

        If sqlstt = sqlSuccess;
          $pform = rpform;
          $pdev = rpdev;
        endif;

700aA    // Set jobq flag
700aA
700aA    if %parms >= 4 and pJobq = '*JOBQ';
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
      /end-free

700aDc*                  move      pwhse         $pwhs             3
720aA
720aAc                   if        %parms < 5
720aA
     c                   call      @lblpg
700aDc*                  parm                    $pwhs
700aMc                   parm                    pwhse
     c                   parm                    $prtn
     c                   parm                    $pdev
     c                   parm                    $pform
     c                   parm                    ppo
720aA
720aAc                   else
720aA
720aAc                   call      @lblpg
720aMc                   parm                    pwhse
720aAc                   parm                    $prtn
720aAc                   parm                    $pdev
720aAc                   parm                    $pform
720aAc                   parm                    ppo
720aAc                   parm                    pitem
720aAc                   parm                    pqty
720aA
720aAc                   endif

700aA*----------------------------------------------------------------
700aA*  SubmitProgram   Submit Program
700aA*----------------------------------------------------------------
700aA
700aA /free
700aA  begsr SubmitProgram;

720aA    if %parms < 5;
720aA
700aA      sbmCmd = 'CALL  '
700aA             +   'PGM(' + %trimr(#pgm) + ') '
700aA             +   'PARM('
700aA             +      sq + pwhse + sq + ' '
700aA             +      sq + pPO + sq + ' '
700aA             +      sq + pOutstr + sq + ' '
700aA             +      sq + '*JOBQ' + sq
700aA             +   ')';

720aA    else;
720aA
720aA      sbmCmd = 'CALL  '
720aA             +   'PGM(' + %trimr(#pgm) + ') '
720aA             +   'PARM('
720aA             +      sq + pwhse + sq + ' '
720aA             +      sq + pPO + sq + ' '
720aA             +      sq + pOutstr + sq + ' '
720aA             +      sq + '*JOBQ' + sq + ' '
720aA             +      sq + pItem + sq + ' '
720aA             +      sq + pQty + sq
720aA             +   ')';
720aA
720aA    endif;

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
