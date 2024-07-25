      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *
     *  STRJOBHIST   Start GETJOBHIST
     *  27 August 2015
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    08/27/15  DAS  7.00
     *      - Created.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.qcmdexc

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D cmd             s            500
     D jobName         s             10
     D jobUser         s             10
     D jobNbr          s              6
     D return          s             10

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D ChkActJob       pr                  extpgm('CHKACTJOB')
     D   pJobName                    10
     D   pReturn                     10
     D   pJobUser                    10
     D   pJobNbr                      6

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        jobName = 'BFCJOBHIST';

        ChkActJob(jobName: return: jobUser: JobNbr);

        if return = '*EXIST';
          return;
        endif;

        cmd = 'SBMJOB CMD(call getjobhist 15) ' +
              'JOBQ(qsysnomax) ' +
              'MSGQ(*NONE) ' +
              'JOBMSGQFL(*PRTWRAP) ' +
              'JOB(' + %trimr(jobName) + ')';

        qcmdexc(%trimr(cmd): %len(%trimr(cmd)));

        return;

      /end-free
