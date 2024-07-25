      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  TSTTR875    Test for TR875
     *  23 June 2020
     *  Retha Davis
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d  pWhse          s              3  0
     D  pRte           s              5
     d  pRtid          s              5
     d  pPassedRtTm    s              6  0
     d  pStime         s              6  0
     d  pEtime         s              6  0
     D  prtn           s             10

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D tr875           pr                  extpgm('TR875')
     D  pwhse                         3  0
     D  pRte                          5
     D  prtid                         5
     d  pPassedRtTm                   6  0
     d  pStime                        6  0
     d  pEtime                        6  0
     D  prtn                         10

     *----------------------------------------------------------------
     *  Parameters
     *
     *----------------------------------------------------------------

     d tsttr875        pr                  extpgm('TSTTR875')
     D  iwhse                        15  5
     D  iRte                          5
     D  irtid                         5
     d  iPassedRtTm                  15  5
     d  iStime                       15  5
     d  iEtime                       15  5

     d tsttr875        pi
     D  iwhse                        15  5
     D  iRte                          5
     D  irtid                         5
     d  iPassedRtTm                  15  5
     d  iStime                       15  5
     d  iEtime                       15  5

      /free

        *inlr = *on;

        if %parms() < 6;
          dsply 'tsttr875 (whse rte rtid ptime stime etime)';
          return;
        endif;

        pWhse = iwhse;
        pRte  = irte;
        pRtid = irtid;
        pPassedRtTm = iPassedRtTm;
        pStime = iStime;
        pEtime = iEtime;

        TR875(pWhse: pRte: pRtid: pPassedRtTm: pStime: pEtime: prtn);

        return;
      /end-free
