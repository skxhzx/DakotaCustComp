     *----------------------------------------------------------------
     * Begin P.GETSTOP - Prototypes for GETSTOP
     *
     *   09/19/17  DAS  7.10
     *     - Created
     *
720aA*   06/16/18  DAS  7.20a
     *     - Drop fields added
     *
     *----------------------------------------------------------------

     D GetStop         pr                  extpgm('GETSTOP')
      * Input
     D   pCmd                         8    const
     D   pWhse                        3  0 const
     D   pRtid                        5    const
     D   pOrder                       7  0 const
      * Output
     D   pStopId                      2  0
     D   pHostStop                    5  0
720aAD   pDrop                        3    options(*nopass)
720aAD   pExtDesc                    30    options(*nopass)
720aAD   pStpDrpDsp                   9    options(*nopass)

     *** End P.GETSTOP ***
