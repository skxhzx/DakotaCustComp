      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  TSTTR847    Test for TR847
     *  20 February 2018
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d  pWhse          s              3  0
     d  pRtid          s              5
     D  prtn           s              8
     D  perm           s             60

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D tr847           pr                  extpgm('TR847')
     D  pwhse                         3  0
     D  prtid                         5
     D  prtn                          8
     D  perm                         60

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      iWhse       Warehouse
     *      iRtid       Route id or *ALL
     *
     *----------------------------------------------------------------

     d tsttr847        pr                  extpgm('TSTTR847')
     D  iwhse                        15  5
     D  irtid                         5

     d tsttr847        pi
     D  iwhse                        15  5
     D  irtid                         5

      /free

        *inlr = *on;

        if %parms() < 2;
          dsply 'tsttr847 (whse rtid)';
          return;
        endif;

        pWhse = iwhse;
        pRtid = irtid;

        TR847(pWhse: pRtid: prtn: perm);

        return;
      /end-free
