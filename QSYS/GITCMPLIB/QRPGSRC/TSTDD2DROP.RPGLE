      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2018BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TSTDD2DROP  Test DD2DROP
     *  07 April 2018
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     F*dtask    uf a e           k disk

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

     D  i              s              1p 0
     D  pCmd           s             10
     D  pWhse          s              3p 0
     D  pRtid          s              5    varying
     D  pType          s             10    varying
     D  pGroup         s              5p 0
     D  pSessId        s             40    varying
     D  pUser          s             10    varying
     D  pPgm           s             20
     D  pDragIds       s           2000    varying
     D  pDropId        s             50    varying
     D  pJSON          s           9999    varying

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     D dd2drop         pr                  extpgm('DD2DROP')
     D  pCmd                         10
     D  pWhse                         3p 0
     D  pRtid                         5    varying
     D  pType                        10    varying
     D  pGroup                        5p 0
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pPgm                         20
     D  pDragIds                   2000    varying
     D  pDropId                      50    varying
     D  pJSON                      9999    varying

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       dd2drop(pCmd: pWhse: pRtid: pType: pGroup:
             pSessId: pUser: pPgm: pDragIds: pDropId: pJSON);

       //ddtwhse = 0;
       //ddtrtid = '';
       //ddttype = 'TSTDD2DROP';
       //ddtsubtype = 'pJSON';
       //ddttaskgrp = 0;
       //ddtseq = 0;
       //ddtsessid = '';

       //chain (ddtwhse: ddtrtid: ddttype: ddtsubtype:
       //       ddttaskgrp: ddtseq) ddtask;

       //ddtstr = pJSON;

       //if %found;
       //  update ddtrec;
       //else;
       //  write ddtrec;
       //endif;

      /end-free

