      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  TSTTR340   Test TR340
     *  16 March 2020
     *  Retha Davis
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d  pWhse          s              3  0
     d  pRtid          s              5

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     d TR340           pr                  extpgm('TR340')
     d  pWhse                         3  0
     d  pRtid                         5

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       warehouse
     *      pRtid       route id
     *
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        tr340(pWhse: pRtid);

        return;
      /end-free

