500gA /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)

      *----------------------------------------------------------------
      *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   (630) 562-0375
      *----------------------------------------------------------------
      *
      *  JOBREVIEW  Loop through Prestart jobs and determine
      *             which have not serviced job for more than
      *             passed parm in minutes and cancel the job. This
      *             is submitted on Sunday morning at 7am and ends
      *             itself Saturday night when runs after 7pm.
      *
      *             Suggested to first try 30 minute delay.  If it
      *             never ends the common BFCGUIxxx jobs try 15 minute
      *             parm.
      *
      *  Kenneth Elder
      *
650 A*    11/10/17  KDE  7.10
     *      - Created
720 A*    08/08/18  KDE  7.20
     *      - Add Trax jobs to ensure they are kept clean
740 A*    05/27/20  KDE  7.40
     *      - Add email alert for GUI Report Scheduler job
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: PFG
     *
PFGaA*    02/19/19  KDE  PFGa
     *      - Revised to only end jobs where actual user begins with
     *        BFC
     *
     *----------------------------------------------------------------

      *----------------------------------------------------------------
      * Notes
      *
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      * File Specs
      *----------------------------------------------------------------
650aAFwrkActJ   if   e           k disk    usropn
     f                                     rename(wrkactjobs:wa)

      *----------------------------------------------------------------
      *  Customer id
      *----------------------------------------------------------------

PFGaA /copy qcopysrc,id#PFG

      *----------------------------------------------------------------
      * Function prototypes.
      *----------------------------------------------------------------

710 A***    Prototype for QUSRJOBI API
     D RtvJobInf       PR                  ExtPgm('QUSRJOBI')
     D   RcvVar                   65535A   options(*varsize)
     D   RcvVarLen                   10I 0 CONST
     D   Format                       8A   CONST
     D   JobName                     26A   CONST
     D   IntJobID                    16A   CONST
     D   ErrorCode                65535A   options(*varsize)

     * Prototype for QCMDEXC
     D QCMDEXC         PR                  EXTPGM('QCMDEXC')
     D   CMD                        500A   OPTIONS(*VARSIZE) CONST
     D   CMDLEN                      15P 5 CONST

     *  Prototype to pause execution
     D sleep           PR            10I 0 extproc('sleep')
     D   seconds                     10U 0 value

      *----------------------------------------------------------------
      *  Customer id
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  DRI parameters
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Data Formats
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Standard variables and constants
      *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
      *copy qcopysrc,c#stdsql

      *----------------------------------------------------------------
      *  Variables
      *----------------------------------------------------------------

PFGaAD client          s             10
PFGaAD clientloc       s             10
     d cmd             s            500a
     d cnt             s              5  0
     d jobAry          s             26    dim(5000)
     d jobName         s             28
     d nummins         s              3  0
     d option          s              7    inz('*IMMED')

      *----------------------------------------------------------------
410aA *  *SYSTEM  -  System options.
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  File information data structure
      *----------------------------------------------------------------
      *  Explanation of JOBI1000 for API QUSRJOBI
      * BINARY(4) Number of bytes returned
      * BINARY(4) Number of bytes available
      * CHAR(10) Job name
      * CHAR(10) User name
      * CHAR(6) Job number
      * CHAR(16) Internal job identifier
      * CHAR(10) Job status
      * CHAR(1) Job type
      * CHAR(1) Job subtype
      * CHAR(2) Reserved
      * BINARY(8), UNSIGNED Elapsed time
      * BINARY(8), UNSIGNED Disk I/O count during the elapsed time (job)
      * BINARY(8), UNSIGNED Disk I/O count during the elapsed time - asynchronous I/O (job)
      * BINARY(8), UNSIGNED Disk I/O count during the elapsed time - synchronous I/O (job)
      * BINARY(4) Interactive response time - total during the elapsed time
      * BINARY(4) Interactive transactions - count during the elapsed time
      * BINARY(4) Processing unit used - percent used during the elapsed time (job)
      * BINARY(4) Processing unit used for database - percent used during the elapsed time (job)
      * BINARY(8) Processing unit used - time during the elapsed time (job)
      * BINARY(8) Processing unit used for database - time during the elapsed time (job)
      * BINARY(8) Lock wait time - time during the elapsed time
      * BINARY(8) Page fault count during the elapsed time (job)

     D dsJobI1000      DS
     D   JobI_ByteRtn                10I 0
     d   JobI_ByteAvl                10I 0
     D   JobI_JobName                10A
     D   JobI_UserID                 10A
     D   JobI_JobNbr                  6A
     D   JobI_IntJob                 16A
     D   JobI_Status                 10A
     D   JobI_Type                    1A
     D   JobI_SbType                  1A
     D   JobI_Reserv1                 2A
     D   JobI_Elptime                20u 0
     D   JobI_Elpdioa                20u 0
     D   JobI_Elpdios                20u 0
     D   JobI_IntResT                10i 0
     D   JobI_IntResC                10i 0
     D   JobI_PrcUnt_                10i 0
     D   JobI_PrcUtd_                10i 0
     D   JobI_PrcUntU                20u 0
     D   JobI_PrcUtdb                20u 0
     D   JobI_Lcktime                20u 0
     D   JobI_PgFault                20u 0

     *  Error data Structure for QUSRJOBI API
     D dsEC            DS
     D  dsECBytesP             1      4I 0 INZ(256)
     D  dsECBytesA             5      8I 0 INZ(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256

      *----------------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------------

     D pssrflag        s               n

     D                sds
     D  #prog            *proc
500gAD  #pgm             *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
600fAD  #curruser            358    367

      *----------------------------------------------------------------
      *  Parameters
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      * Main line
      *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    loopmins          3
PFGaAC*
PFGaAC*   Get Client Code
PFGaAC*
PFGaAc                   call      'GETCLIENT'
PFGaAC                   parm                    client           10
PFGaAC                   parm                    clientloc        10

      *  Create WRKACTJ work file to read through.  API exist
      *  but requires at least 7.1 OS release
     c                   eval      subsys = '*ALL'
     c                   eval      jobsel = '*ALL'
     c                   call      'WRKACTJOBS'
     c                   parm                    subsys           10
     c                   parm                    jobsel           10
      /free
         // make sure loop minutes is numeric
         monitor;
            nummins = %dec(loopmins:3:0);
         on-error;
            // if not numeric then end
            *inlr=*on;
            return;
         endmon;

         // if negative for some reason flip to positive
         if nummins < 0;
            nummins = nummins * -1;
         endif;

         clear JobAry;
         if not %open(wrkactj);
            cmd = 'OVRDBF FILE(WRKACTJ) TOFILE(QTEMP/WRKACTJOBS)';
            callp(e) qcmdexc (%trim(cmd) : %len(%trim(cmd)));
            open wrkactj;
         endif;
         // Loop through Active Jobs files created from CL above.
         // We look for QZDASOINIT jobs to cancel if inactive for
         // number of minutes passed in parm

         read wrkactj;

         // loop active jobs looking for all qzdasoinit or QZRCSRVS jobs for
         // user QUSER.  These jobs will be stored in array and then checked xx
         // minutes later to see if processing occured since.  If no processing
         // in number minutes passed in it will be cancelled
         cnt=0;
         dow not %eof(wrkactj);
            // load jobs array
            if %subst(wrkActJobs:51:2) = 'PJ'               // Prestart jobs
               and (%scan('QZDASOINIT':%subst(wrkActJobs:1:17):1)>0 or
                    %scan('QZRCSRVS':%subst(wrkActJobs:1:17):1)>0)
720 M          and (%subst(wrkActJobs:18:5)='QUSER'
720 A          or %subst(wrkActJobs:18:9)='BFTRAXPRD')
PFGaA          // when PFG we should only consider cancelling prestart jobs
PFGaA          // specifically for actual users that begin with BFC
PFGaA          and ((%subst(wrkActJobs:39:3)='BFC' and
PFGaA               %trim(client)='PFG') or (%trim(client)<>'PFG'))
               and %subst(wrkActJobs:117:4)<>'PSRW'   // exclude jobs to manage prestarts
740            or %scan('SCHLER':%subst(wrkActJobs:1:17):1)>0;
               cnt=cnt+1;
               jobAry(cnt) = %subst(%triml(%subst(wrkActJobs:1:17)):1:10) +
                             %subst(wrkActJobs:18:10) +
                             %subst(wrkActJobs:30:6);
               // call API to set counters to zero
               callp  RtvJobInf(dsJOBI1000: %size(dsJOBI1000):
                               'JOBI1000': %trim(jobAry(cnt)): *BLANKS:
                                dsEC);
               if dsECBytesA > 0;
                  dsECMsgID = dsECMsgID;
               endif;
            endif;
            read wrkactj;
         enddo;
         close wrkactj;

         // Pause for number of minutes passed in nummins
         sleep(nummins*60);

         // Loop thru Job Array and call API QUSRJOBI to
         // determine if processing time.  If job did nothing
         // then end job
         cnt=0;
         dow cnt < 1001;
            cnt=cnt+1;
            // call API to set counters to zero
            if jobAry(cnt) = *blanks;
               leave;
            endif;
            callp  RtvJobInf(dsJOBI1000: %size(dsJOBI1000):
                            'JOBI1000': %trim(jobAry(cnt)): *BLANKS:
                             dsEC);
            if dsECBytesA > 0;
               dsECMsgID = dsECMsgID;
            else;
               // put code in to verify whether activity
               // if not activity then cancel job
               JobI_JobNbr = JobI_JobNbr;
               if JobI_prcUntU=*zeros and JobI_PrcUtdb=*zeros and
                  JobI_Elpdioa=*zeros and JobI_Elpdios=*zeros;
                  // if no acticity for specified wait above then cancel
                  jobName = %trim(JobI_Jobnbr) + '/' +
                            %trim(JobI_UserID) + '/' +
                            %trim(JobI_Jobname);
740 A             if %scan('SCHLER':JobI_jobName:1)>0;
740 A               // If scheduler job is not running then send
740 A               // email to Kenneth Elder at BFC
740 A               cmd = 'SBMJOB CMD(BFCEMAIL EMAILTO(KENNETHE@BFCASSOCIATES' +
740 A                     '.COM) SUBJECT(' + sq + 'Report Scheduler Issues' +
740 A                     sq + ') BODY(' + sq + 'Report Scheduler ' +
740 A                     %trim(JobI_jobName) + ' seems to be having issues.' +
740 A                     ' Also make sure no BFCSNDEML jobs in wait state.' +
740 A                     sq + ')) JOB(BFCSNDEML) JOBQ(QSYSNOMAX)';
740 A             else;
740 A               // else, not scheduler, then endjob
                    cmd = 'ENDJOB JOB(' + %TRIM(jobName) +
                                     ') OPTION(' + OPTION + ')';
740 A             endif;
                  callp(e) qcmdexc (%trim(cmd) : %len(%trim(cmd)));
               endif;
            endif;
         enddo;
         cmd = 'DLTOVR FILE(WRKACTJ)';
         callp(e) qcmdexc (%trim(cmd) : %len(%trim(cmd)));
         // will reSubmit itself unless Saturday and after 18:00 6pm
         // Sunday=0, Monday=1, Tuesday =2, etc.,
         if %rem(%diff(%date():d'1800-01-05':*days):7) = 6
            and %dec(%Time():*ISO) > 190000;
            // if Saturday and 7pm or later then end job
            // by no re-submitting
         else;
            // otherwise reSubmit and review in one hour cycle
            // throughout the day
            cmd = 'SBMJOB CMD(CALL PGM(JOBREVIEW) PARM(' +
                          sq + loopmins + sq + '))' +
                          ' JOBQ(QSYSNOMAX)';
            callp(e) qcmdexc (%trim(cmd) : %len(%trim(cmd)));
         endif;
         *inlr = *on;

      /end-free
