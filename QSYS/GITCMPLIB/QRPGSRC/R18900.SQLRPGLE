      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  R18900       PO History Receiving - Print Receiving Report.
     *  02 June 2016
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    06/02/16  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
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

      /copy qcopysrc,p.qcmdexc

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

     D SubmitJob       PR            10I 0
     D   peName                      10A   const varying
     D   peJobQ                      10A   const varying
     D   peCmd                     3000A   const varying
     D   peSbmName                   10A   options(*nopass)
     D   peSbmUser                   10A   options(*nopass)
     D   peSbmNbr                     6A   options(*nopass)

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

     D pWhse           s              3
     D pPo             s              9
     D  pOutStr        s           1024    varying

     D client          s             10
     D clientloc       s             10

     D $pWhs           s              3
     D $prtn           s              8
     D $pdev           s             10
     D $pform          s             10
     D $hacmd          s              8
     D $hawhse         s              3  0
     D $lhapo          s              9
     D $lhaitem        s             15
     D $hanew          s              1
     D $hawhse15       s             15  5

     D hapo            s              9

     D jobq            s               n
     D bfcjobq         s             10
     D sbmCmd          s           3000    varying
     D sbmJob          s             10A
     D sbmUser         s             10A
     D sbmJobNbr       s              6A
     D numWhse         s              3  0
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Called Programs
     *----------------------------------------------------------------
     d @prtpg          c                   const('PO332CL')
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pOutStr
     C                   parm                    pJobq             5

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
         monitor;
           numWhse = %dec(pWhse: 3: 0);
         on-error;
           bdtype = 'ERROR';
           bdvalues = 'Whse conversion error: ' + pWhse;
           exsr WrtDebug;
           numWhse = 0;
         endmon;
        $pform = '*STD';
        $pdev = '*JOB';
        // do we have printer overrides?
        exec sql select * into :rprec
             from reports
             where rpprtf = 'PO332PR';

        If sqlstt = sqlSuccess;
          $pform = rpform;
          $pdev = rpdev;
        endif;
         // Set jobq flag

         if %parms >= 4 and pJobq = '*JOBQ';
           jobq = *on;
         else;
           jobq = *off;
         endif;
         // When not running from Jobq ...

         if not jobq;

           // Submit this program to Jobq

           exsr SubmitProgram;
           return;

         endif;
           qcmd = 'OVRPRTF '
                + 'FILE(PO332PR) '
                + 'OUTQ(*DEV) '
                + 'DEV(' + %trim($pdev) + ') '
                + 'FORMTYPE(' + %trim($pform) + ') ';
      /end-free
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd            256
     C                   parm      80            qlen             15 5

     c                   call      'PO332'
     c                   parm                    pwhse
     c                   parm                    ppo

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
      /free
        hapo = ppo;
        exsr PrtLog;
      /end-free
     c                   endif


     *----------------------------------------------------------------
     *  SubmitProgram   Submit Program
     *----------------------------------------------------------------

      /free
       begsr SubmitProgram;

         sbmCmd = 'CALL  '
                +   'PGM(' + %trimr(#pgm) + ') '
                +   'PARM('
                +      sq + pwhse + sq + ' '
                +      sq + pPO + sq + ' '
                +      sq + pOutstr + sq + ' '
                +      sq + '*JOBQ' + sq
                +   ')';

         bfcjobq = 'BFCJOBQ';

         if SubmitJob(#pgm: bfcjobq:
                      sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;

           bdtype = 'ERROR';
           bdvalues = 'sbmcmd:' + %trimr(sbmcmd);
           exsr WrtDebug;
           //pMessage = 'Error submitting command ' + #pgm;
           return;

         endif;


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
     c                   if        *in78 = *off
     c                   call      'HA301'
     c                   parm      ' '           $hacmd            8
     c                   parm      numwhse       $hawhse           3 0
     c                   parm      hapo          $lhapo            9
     c                   parm      ' '           $lhaitem         15
     c                   parm                    $hanew            1
     c                   if         $hanew = '1'
     c                   call      'HA300'
     c                   parm      '*PRINT'      $hacmd            8
     c                   parm      numwhse       $hawhse15        15 5
     c                   parm      hapo          $lhapo            9
     c                   parm      ' '           $lhaitem         15
     c                   else
     c                   endif
     c                   else
     c                   eval      *in78 = *off
     c                   endif
     c                   endsr
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

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
