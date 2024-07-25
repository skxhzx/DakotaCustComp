      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2018BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TSTDD420    Test DD420
     *  12 April 2018
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

     D gCmd            s             10    varying
     D gWhse           s              3  0
     D gRtid           s              5    varying
     D gDropId         s             20    varying
     D gDragIds        s           2000    varying
     D gUser           s             10    varying
     D gSessId         s             40    varying
     D gDict           s             10    varying
     D gPgm            s             10    varying
     d gJSON           s           2000    varying

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------


     D DD420           pr                  extpgm('DD420')
     D  dCmd                         10    varying
     D  dWhse                         3p 0
     D  dRtid                         5    varying
     D  dDropId                      20    varying
     D  dDragIds                   2000    varying
     D  dSessId                      40    varying
     D  dUser                        10    varying
     D  dDict                        10    varying
     D  dPgm                         10    varying
     D  dJSON                      2000    varying

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     D TSTDD420        pr                  extpgm('TSTDD420')
     D  pCmd                         10
     D  pWhse                        15p 5
     D  pRtid                         5
     D  pDropId                      20
     D  pDragIds                     50

     D TSTDD420        pi
     D  pCmd                         10
     D  pWhse                        15p 5
     D  pRtid                         5
     D  pDropId                      20
     D  pDragIds                     50

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       if %parms >= 1 and pCmd > '';
         gCmd = pCmd;
       else;
         gCmd = 'DROP';
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

       if %parms >= 4 and pDragIds > '';
         gDragIds = %trim(pDragIds);
       else;
         gDragIds = 'lr5c2';
       endif;

       if %parms >= 5 and pDropId > '';
         gDropId = %trim(pDropId);
       else;
         gDropId = 'lr1c1';
       endif;

       dd420(gCmd: gWhse: gRtid: gDropId: gDragIds:
             gSessId: gUser: gDict: gPgm: gJSON);

       gJSON = gJSON;

      /end-free

