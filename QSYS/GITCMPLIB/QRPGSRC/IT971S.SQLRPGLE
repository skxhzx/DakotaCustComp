     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT971S   Staging Item Quantity Compare Report - Submit
     *  11 November 2015
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Notes
     *    The comparison takes a few minutes to run. Since there is
     *    no need for the host to wait on a response, set staging
     *    records to processing status and submit to batch, and return
     *    ok to stored procedure call.
     *----------------------------------------------------------------
     *
700  *    11/11/15  RTR  7.00
     *      - Created.
     *
750 A*    12/14/21  TDC  7.50
     *      - Brought in undocumented changes from Earl's.
     *
     *----------------------------------------------------------------
     *  Program info data structure
      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Program Prototype and Entry Parms
     d Main            pr                  extpgm('IT971S')
     d                                3    const
     d                               11    const
     d                               10
     d                              200
     d Main            pi
     d  pWhse3A                       3a   const
     d  pBatId                       11a   const
     d  pReturn                      10a
     d  pMessage                    200a
     *----------------------------------------------------------------
     *  Called Program Prototypes
      /copy qcopysrc,p.qcmdexc
     *----------------------------------------------------------------
     *  Working Variables
     d cmd             s           3000a
     d len             s             15p 5
     d pWhse           s              3p 0
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse3A   Warehouse
     *      pBatId    Batch ID
     *
     *    Returned Parameters
     *      pReturn   Returned code
     *      pMessage  Returned message
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     * Main line
      /free

        exec sql
          update stgbatch
          set sbstatus = 'P',
              sbtext   = 'Processing records.',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :pWhse
750 A       and sbbatid = :pBatId;
750 D       //and sbbatid = :pBatId
750 D       //and sbstatus <> 'S';

        if sqlstt <> sqlSuccess;   // send error message
          cmd = 'SNDMSG MSG('+ sq + 'ERROR: Comparison Report '
              + sqlstt + ' in staging batch ID ' + pBatId
              + sq + ') TOUSR(*SYSOPR)';
          len = %len(cmd);
          qcmdexc(cmd: len);
        else;                      // submit report to batch
          cmd = 'SBMJOB CMD(CALL PGM(IT971SCL) PARM('
              + sq + pWhse3a + sq + ' ' + sq + pBatId
750 D         //+ sq + ')) JOB(COMPARISON)';
750 A         + sq + ')) JOB(COMPARISON) JOBQ(QS36EVOKE)';
          len = %len(cmd);
          qcmdexc(cmd: len);
          cmd = 'SNDMSG MSG('+ sq + 'Comparison Report submitted '
              + 'for staging batch ID ' + pBatId
              + sq + ') TOUSR(*SYSOPR)';
          len = %len(cmd);
          qcmdexc(cmd: len);
        endif;

        *inlr = *on;
      /end-free
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
      /free
        begsr *inzsr;

          pWhse = %dec(pWhse3A: 3: 0);

        endsr;   //  *inzsr
      /end-free
     *----------------------------------------------------------------
