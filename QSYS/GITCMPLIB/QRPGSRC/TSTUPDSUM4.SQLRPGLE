      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTUPDSUM4   Test UPDSUM004
     *  20 March 2014
     *  Retha Davis
     *
     *  Revisions
     *
     *    03/20/14  RBD
     *      - Created.
     *
740aA*    02/26/20  RBD  7.40a
     *      - Added parms.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pDaysBefL      s              3  0
     D  pDaysAftL      s              3  0
     D  pDaysBefI      s              3  0
     D  pDaysAftI      s              3  0
     D  pFMfgDt        s              6  0
     D  pTMfgDt        s              6  0
     D  pFMfgEDt       s              6  0
     D  pTMfgEDt       s              6  0
     D  pFMfgDt8       s              8  0
     D  pTMfgDt8       s              8  0
     D  pFMfgEDt8      s              8  0
     D  pTMfgEDt8      s              8  0
     D  pItem          s             15
     D  pLcns          s             15
     D  pLot           s             30
     D  pErrMsg        s             99
     d  pObjLoc        s             10
     D  pPgm           s             10
740aDd**pPo            s              9
740aMd  pPO            s            500    varying
     D  pRptDesc       s             40
     D  pSerial        s             30
     d  pSessId        s             40
     D  pUser          s             10
     d  pWhse          s              3  0
740aAd  pRoute         s              5
740aAd  pRouteId       s              5
740aAd  pFdlvDat       s              6  0
740aAd  pTdlvDat       s              6  0
740aAd  pFdlvDat8      s              8  0
740aAd  pTdlvDat8      s              8  0
740aAd  pTran          s            500    varying

     C                   eval      pwhse = 900
     C                   eval      pFMfgDt = 0
     C                   eval      pTMfgDt = 0
     C                   eval      pFMfgEDt = 0
     C                   eval      pTMfgEDt = 0
     C                   eval      pDaysBefL = 0
     C                   eval      pDaysAftL = 0
     C                   eval      pDaysBefI = 0
     C                   eval      pDaysAftI = 0
740aAC                   eval      pFdlvdat = 0
740aAC                   eval      pTdlvdat = 0

     C                   call      'UPDSUM004'
     C                   parm                    pErrMsg
     c                   parm                    pSessId
     C                   parm                    pUser
     C                   parm      'TSTUPDSUM4'  pPgm
     C                   parm                    pObjLoc
     C                   parm                    pWhse
     C                   parm      'Test recall' pRptDesc
     C                   parm                    pItem
     C                   parm                    pPo
     C                   parm                    pLot
     C                   parm                    pLcns
     C                   parm                    pSerial
     C                   parm                    pFMfgDt
     C                   parm                    pTMfgDt
     C                   parm                    pFMfgEDt
     C                   parm                    pTMfgEDt
     C                   parm                    pDaysBefL
     C                   parm                    pDaysAftL
     C                   parm                    pDaysBefI
     C                   parm                    pDaysAftI
740aAC                   parm                    pRoute
740aAC                   parm                    pRouteId
740aAC                   parm                    pFdlvDat
740aAC                   parm                    pTdlvDat
740aAC                   parm                    pTran

     c                   eval      *inlr = *on
