      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  TSTTR*42   Test TR842
     *  08 December 2017
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d  iFileLen       s              3  0
     d  pVersion       s              5
     d  pCommand       s             30
     d  pEmpNo         s              5
     d  pWhse          s              3  0
     d  pRtid          s              5
     d  pStop          s              5
     d  pPath          s            100
     d  pFile          s            100
     d  pStamp         s             19
     d  pLatitude      s             15
     d  pLongitude     s             15
     d  pRtnCode       s             10
     d  pRtnMsg        s             60

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     d TR842           pr                  extpgm('TR842')
     d  pVersion                      5
     d  pCommand                     30
     d  pEmpNo                        5
     d  pWhse                         3  0
     d  pRtid                         5
     d  pStop                         5
     d  pPath                       100
     d  pFile                       100
     d  pStamp                       19
     d  pLatitude                    15
     d  pLongitude                   15
     d  pRtnCode                     10
     d  pRtnMsg                      60

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      iFile       XML File to process
     *      iPath       Path for XML file
     *      iCmd        Command
     *                    sendRouteStart
     *                    sendStopStart
     *                    postCompletedRoute
     *                    postCompletedStop
     *
     *----------------------------------------------------------------

     d tsttr842        pr                  extpgm('TSTTR842')
     d  iFile                        30
     d  iPath                        30
     d  iCommand                     30

     d tsttr842        pi
     d  iFile                        30
     d  iPath                        30
     d  iCommand                     30

      /free

        *inlr = *on;

        if %parms() < 3;
          dsply 'tsttr842 (file path cmd)';
          return;
        endif;

        iFileLen = %len(%trim(iFile));
        pVersion = %subst(iFile:iFileLen-9:3);
        pCommand = iCommand;
        pWhse    = %dec(%subst(iFile:2:3):3:0);
        pRtid    = %subst(iFile:6:5);
        pFile    = iFile;
        pPath    = iPath;

        pEmpNo   = '99999';

        tr842(pVersion: pCommand: pEmpNo: pWhse: pRtid: pStop: pPath: pFile:
              pStamp: pLatitude: pLongitude: pRtnCode: pRtnMsg);

        if pRtnCode <> '*OK';
        endif;

        return;
      /end-free

