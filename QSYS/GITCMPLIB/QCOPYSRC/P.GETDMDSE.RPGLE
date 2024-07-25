     *----------------------------------------------------------------
     * Begin P.GETDMDSE - Prototype for GETDMDSEL
     *
750  *   09/10/21  DAS  7.50
     *     - Created
     *
     *----------------------------------------------------------------

     d GETDMDSEL       pr                  extpgm('GETDMDSEL')
     d  pCmd                         10    const
     d  pWhse                         3p 0
     d  pUser                        10
     d  pTran#                        7p 0
760 Dd* pRtnCode                     10
760 Dd* pRtnMsg                      50
760 Ad  pPalCnt                       1p 0
760 Ad  pRtid                         5
760 Ad  pZone                         6
760 Md  pRtnCode                     10
760 Md  pRtnMsg                      50

     *** End P.GETDMDSE ***
