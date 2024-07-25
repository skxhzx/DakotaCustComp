      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2018BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TSTDD430    Test DD430
     *  22 March 2018
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

     D gCmd            s             10
     D gOutput         s             10
     D gWhse           s              3  0
     D gRtid           s              5
     D gUser           s             10
     D gSessId         s             40
     D gDict           s             10
     D gPgm            s             10
     D gRtnCode        s             10
     D gRtnMsg         s            100
     d gRtnStr         s          65535    varying

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     D DD430           pr                  extpgm('DD430')
     D  pCmd                         10    const
     D  pOutput                      10    const
     D  pWhse                         3p 0 const
     D  pRtid                         5    const
     D  pUser                        10    const
     D  pSessId                      40    const
     D  pDict                        10    const
     D  pPgm                         10    const
     D  pRtnCode                     10
     D  pRtnMsg                     100
     d  pRtnStr                   65535    varying

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     D TSTDD430        pr                  extpgm('TSTDD430')
     D  pCmd                         10
     D  pOutput                      10
     D  pWhse                        15p 5
     D  pRtid                         5

     D TSTDD430        pi
     D  pCmd                         10
     D  pOutput                      10
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
         gCmd = '*CRTALL';
       endif;

       if %parms >= 2 and pOutput > '';
         gOutput = pOutput;
       else;
         gOutput = '*FILE';
       endif;

       if %parms >= 3 and pWhse > 0;
         gWhse = pWhse;
       else;
         gWhse = 900;
       endif;

       if %parms >= 4 and pRtid > '';
         gRtid = pRtid;
       else;
         gRtid = '99001';
       endif;

       dd430(gCmd: gOutput: gWhse: gRtid:
             gUser: gSessId: gDict: gPgm:
             gRtnCode: gRtnMsg: gRtnStr);

       gRtnCode = gRtnCode;

      /end-free

