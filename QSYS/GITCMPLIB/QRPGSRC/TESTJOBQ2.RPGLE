      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  TESTJOBQ    Test submitting job to jobq
     *  11 March 2014
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    This program demonstrates that the submitted job will fail.
     *    The reason is because we are CALLing the program and one
     *    of the parameters is numeric. Unfortunately, the CALL
     *    statement converts numeric parameters into 15.5 numbers.
     *    Thus our 3.0 numeric parameter causes a data decimal error.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

640aAFbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------


650cAD sbmCmd          s           3000    varying
650cAD sbmJob          s             10A
650cAD sbmUser         s             10A
650cAD sbmJobNbr       s              6A
650cAD jobq            s               n

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

650cA /copy qcopysrc,p.qcmdexc

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

650cA*----------------------------------------------------------------
650cA*  Sub-procedure prototypes
650cA*----------------------------------------------------------------
650cA
650cAD SubmitJob       PR            10I 0
     D   peName                      10A   const varying
     D   peJobQ                      10A   const varying
     D   peCmd                     3000A   const varying
     D   peSbmName                   10A   options(*nopass)
     D   peSbmUser                   10A   options(*nopass)
     D   peSbmNbr                     6A   options(*nopass)

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pUser            10
     C                   parm                    pWhse             3 0
     C                   parm                    pJobNbr           5
     C                   parm                    pJobq             5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
650cA
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
650cA      exsr SubmitProgram;
650cA      return;
650cA    endif;

         bdtype = 'JOBQ';
         bdvalues = 'whs:' + %char(pWhse) + ','
                  + 'user:' + %trim(pUser) + ','
                  + 'jobn:' + %trim(pJobNbr);
         exsr WrtDebug;

         return;
      /end-free

650cA*----------------------------------------------------------------
650cA*  SubmitProgram   Submit Program
650cA*----------------------------------------------------------------
650cA
650cA /free
650cA  begsr SubmitProgram;

         sbmCmd = 'CALL  '
                +   'PGM(TESTJOBQ2) '
                +   'PARM('
                +      %trim(pUser) + ' '
                +      %char(pWhse) + ' '
                +      %trim(pJobNbr) + ' '
                +      '*JOBQ'
                +   ')';

         if SubmitJob('TESTJOBQ2': 'BFCJOBQ':
                      sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;
           bdtype = 'SUBMITERR';
           bdvalues = 'Error submitting TESTJOBQ2';
           exsr WrtDebug;
           return;
         endif;

         bdtype = 'SUBMITTED';
         bdvalues = 'whs:' + %char(pWhse) + ','
                  + 'user:' + %trim(pUser) + ','
                  + 'jobn:' + %trim(pJobNbr) + ','
                  + 'sbmjob:' + %trim(sbmJob) + ','
                  + 'sbmuser:' + %trim(sbmUser) + ','
                  + 'sbmjobn:' + %trim(sbmJobNbr);
         exsr WrtDebug;

       endsr;
      /end-free

640aA*----------------------------------------------------------------
640aA*  wrtDebug       Write out debug record
640aA*----------------------------------------------------------------
640aA
640aA /free
640aA  begsr wrtDebug;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

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
