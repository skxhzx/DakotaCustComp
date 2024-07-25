     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  HQ122S   Stage - Upd slot qty from host (Custom)-Submit
     *  17 May 2016
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Notes
     *    This process takes a few minutes to run. Since there is
     *    no need for the host to wait on a response, set staging
     *    records to processing status and submit to batch, and return
     *    ok to stored procedure call.
     *----------------------------------------------------------------
     *
700  *    05/17/16  RTR  7.00
     *      - Created.
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
     d Main            pr                  extpgm('HQ122S')
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
              sbtext   = 'Submitting to batch.',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :pWhse
            and sbbatid = :pBatId
            and sbstatus <> 'S';

        if sqlstt <> sqlSuccess;   // send error message
          cmd = 'SNDMSG MSG('+ sq + 'ERROR: HQ122S status '
              + sqlstt + ' in staging batch ID ' + pBatId
              + sq + ') TOUSR(*SYSOPR)';
          len = %len(cmd);
          qcmdexc(cmd: len);
        else;                      // submit to batch
          cmd = 'SBMJOB CMD(CALL PGM(HQ121S) PARM('
              + sq + pWhse3a + sq + ' '
              + sq + pBatId + sq + ' '
              + sq + ' ' + sq + ' '
              + sq + ' ' + sq + ')) JOB(BFC.HQ121S)';
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
