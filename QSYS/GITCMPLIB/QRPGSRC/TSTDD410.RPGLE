      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2018BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TSTDD410    Test DD410
     *  22 March 2018
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

     D gCmd            s             10
     D gRtid           s              5
     D gWhse           s              3  0
     D gGroup          s              1
     D gRow            s              3p 0
     D gCol            s              2p 0
     D gUser           s             10
     D gSessId         s             10
     D gDict           s             10
     D gPgm            s             10
     D gRtnCode        s             10
     D gRtnMsg         s            100

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     D DD410           pr                  extpgm('DD410')
     D  pCmd                         10    const
     D  pWhse                         3p 0 const
     D  pRtid                         5    const
     D  pGroup                        1    const
     D  pRow                          3p 0 const
     D  pCol                          2p 0 const
     D  pUser                        10    const
     D  pSessId                      10    const
     D  pDict                        10    const
     D  pPgm                         10    const
     D  pRtnCode                     10
     D  pRtnMsg                     100

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     D TSTDD410        pr                  extpgm('TSTDD410')
     D  pCmd                         10
     D  pWhse                        15p 5
     D  pRtid                         5

     D TSTDD410        pi
     D  pCmd                         10
     D  pWhse                        15p 5
     D  pRtid                         5


     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       if %parms >= 1 and pCmd > '';
         gCmd = pCmd;
       else;
         gCmd = '*ROUTE';
       endif;

       if %parms >= 2 and pWhse > 0;
         gWhse = pWhse;
       else;
         gWhse = 900;
       endif;

       if %parms >= 3 and pRtid > '';
         gRtid = pRtid;
       else;
         gRtid = '99001';
       endif;

       dd410(gCmd: gWhse: gRtid: gGroup: gRow: gCol:
             gUser: gSessId: gDict: gPgm: gRtnCode: gRtnMsg);

       gRtnCode = gRtnCode;

      /end-free

