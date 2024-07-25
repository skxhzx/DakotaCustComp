
     *----------------------------------------------------------------
     * Begin P.INTAPINS   - Prototypes for INTAPINS
     *
     *   06/03/20  RTR  7.40
     *     - Created
     *
     *----------------------------------------------------------------
     *
     *  Add to D-Spec Section:
     *    /copy *libl/qcopysrc,p.intapins
     *
     *  Sample call of INTAPINS:
     *    /free
     *      ApiNS.Whse = $pwhse;
     *      ApiNS.Batch = BatId;
     *      ApiNS.Type = 'EXPROUTE';
     *      IntApiNS(ApiNS.Whse: ApiNS.Batch: ApiNS.Type:
     *               ApiNS.Ret: ApiNS.Msg);
     *      if ApiNS.Ret <> '*OK';
     *        (your code here)
     *      endif;
     *    /end-free
     *
     *----------------------------------------------------------------

     d IntApiNS        pr                  extpgm('INTAPINS')
      * Input
     d   pWhse                        3    const
     d   pBatch                      11    const
     d   pType                       10    const
      * Output
     d   pRet                        10
     d   pMsg                       100

     d ApiNS           ds                  qualified
      * Input
     d   Whse                         3a
     d   Batch                       11a
     d   Type                        10a
      * Output
     d   Ret                         10a
     d   Msg                        100a

     *** End P.INTAPINS   ***
