      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TSTSUM001C  Test UPDSUM001C
     *  02 January 2017
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pUser          s             10
     d  pdpCombo       s             20
     d  pObjLoc        s             10
     d  pWhse          s              3p 0
650bAd  pDropHrs       s              3p 0
650gAd  pSelPlotVal    s              1
650gAd  pSelMrgPcs     s              1
650gAd  pSelMrgBlk     s              1
650gAd  pSelIdle       s              1
650gAd  pPutPlotVal    s              1
650gAd  pPutIdle       s              1
650gAd  pRplPlotVal    s              1
650gAd  pRplIdle       s              1
650gAd  pRcvPlotVal    s              1
650gAd  pRcvIdle       s              1
700dAd  pTfrPlotVal    s              1
700dAd  pTfrIdle       s              1
700fAd  pLodPlotVal    s              1
700fAd  pLodIdle       s              1

     D updsum001C      pr                  extpgm('UPDSUM001C')
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pPgm                         20
     D  pObjLoc                      10
     D  pWhse                         3p 0
650aAD  pDropHrs                      3p 0
650bAd  pSelPlotVal                   1
650bAd  pSelMrgPcs                    1
650bAd  pSelMrgBlk                    1
650bAd  pSelIdle                      1
650bAd  pPutPlotVal                   1
650bAd  pPutIdle                      1
650bAd  pRplPlotVal                   1
650bAd  pRplIdle                      1
650bAd  pRcvPlotVal                   1
650bAd  pRcvIdle                      1
700aAd  pTfrPlotVal                   1
700aAd  pTfrIdle                      1
700bAd  pLodPlotVal                   1
700bAd  pLodIdle                      1

      /free
         pSessId = '1234';
         pUser = 'USER';
         pdpCombo = 'TSTSUM001C';
         pObjLoc = '';
         pWhse = 1  ;
650bA    pDropHrs     = 24;
650gA    pSelPlotVal  = 'P';
650gA    pSelMrgPcs   = 'N';
650gA    pSelMrgBlk   = 'N';
650gA    pSelIdle     = 'N';
650gA    pPutPlotVal  = 'P';
650gA    pPutIdle     = 'N';
650gA    pRplPlotVal  = 'P';
650gA    pRplIdle     = 'N';
650gA    pRcvPlotVal  = 'P';
650gA    pRcvIdle     = 'N';
700dA    pTfrPlotVal  = 'P';
700dA    pTfrIdle     = 'N';
700fA    pLodPlotVal  = 'P';
700fA    pLodIdle     = 'N';

         updsum001C(pErrMsg:
                    pSessId:
                    pUser:
                    pdpCombo:
                    pObjLoc:
                    pWhse:
650aA               pDropHrs:
650bA               pSelPlotVal:
650bA               pSelMrgPcs:
650bA               pSelMrgBlk:
650bA               pSelIdle:
650bA               pPutPlotVal:
650bA               pPutIdle:
650bA               pRplPlotVal:
650bA               pRplIdle:
650bA               pRcvPlotVal:
650bA               pRcvIdle:
700aA               pTfrPlotVal:
700bM               pTfrIdle:
700bA               pLodPlotVal:
700bA               pLodIdle);

       *inlr = *on;
      /end-free
