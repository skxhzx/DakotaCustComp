      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M24000  Export Marked Po's- Pgm for SQL procedure of same name
     *  21 July 2017
     *  Lynn McMahon
     *
     *  Revisions:
     *
710 A*    07/21/17  LMC  7.10
     *      - Created.
730aA*    10/07/19  LMC  7.30a
     *      - Treat export flag R same as S.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * Client Custom Changes:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fbfcdebug  o    e           k disk
     foptions   if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

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
     D bfcjobq         s             10
     D client          s             10
     D clientloc       s             10
     D cmdjobq         s           3000    varying
     D logText         s            100
     D sbmCmd          s           3000    varying
     D sbmJob          s             10A
     D sbmUser         s             10A
     D sbmJobNbr       s              6A
     D numWhse         s              3  0

     *----------------------------------------------------------------
     *  *FTP      -  FTP options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFTP   -  Use FTP for exporting (Y,N)
     *    OPSRVR  -  FTP Server name
     *    OPUSER  -  FTP User id
     *    OPPWD   -  FTP Password
     *
     * Data structure
     *
     D opdata          ds
     D  opftp                  1      1
     D  opsrvr                 2     33
     D  opuser                34     48
     D  oppwd                 49     63
     D  ftpend               117    117

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.qcmdexc
      /copy qcopysrc,p.getclien

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
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session id
     *      pUser       User
     *      pPgm        Calling dictionary.pgm
     *      pWhse       Warehouse
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

         if %parms >= 6 and pJobq = '*JOBQ';
           jobq = *on;
         else;
           jobq = *off;
         endif;

         // When not running from Jobq ...

         if not jobq;

           // Do pre-Jobq checks

           exsr PreJobqChecks;
           if error;
             return;
           endif;

           // Submit this program to Jobq

           exsr SubmitProgram;
           return;

         endif;

         // Call program to export marked po's

         // get FTP options
         opwhse = 0;
         opcode = '*FTP';
         chain (opwhse: opcode) options;
         if not %found(options);
           opftp = 'N';
         endif;
      /end-free
     C*   FTP calls po726cl
     c*   Stage calls PO726scl
     c                   if        opftp = 'Y'
     C                   call(e)   'PO726CL'
     C                   parm      pWhse         $bwhs             3
     c                   endif
     c                   if        opftp = 'S'
730aAc                             or opftp = 'R'
     C                   call(e)   'PO726SCL'
     C                   parm      pWhse         $bwhs             3
     c                   endif
      /free

         // Error on call

         if %error;
             error = *on;
             pMessage = 'Error calling program PO720CL';
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

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  PreJobQChecks   Pre-Jobq Checks
     *----------------------------------------------------------------

      /free
       begsr PreJobQChecks;

         error = *off;

         if error;
             leavesr;
         endif;




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
                +      sq + '*JOBQ' + sq
                +   ')';

         bfcjobq = 'BFCJOBQ';


         if SubmitJob(#pgm: bfcjobq:
                      sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;

           bdtype = 'ERROR';
           bdvalues = 'sbmcmd:' + %trimr(sbmcmd);
           exsr WrtDebug;
           pMessage = 'Error submitting command ' + #pgm;
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
