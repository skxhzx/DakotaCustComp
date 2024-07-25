
     *----------------------------------------------------------------
     * Begin P.GETFEAT - Prototypes for GETFEAT
     *
     *   09/16/11  DAS  6.40
     *     - Created
     *
730aA*   04/02/19  DAS  7.30
     *     - Added pTBType, pTBCol
     *
     *----------------------------------------------------------------

     D getFeat         pr                  extpgm('GETFEAT')
     D  pCmd                          8    const
610aMD  pWhse                         3  0
     D  pFeature                      1
     D  pLight                        1
730aAD  pTBType                       1    options(*nopass)
730aAD  pTBCol                        1    options(*nopass)

     *** End P.GETFEAT ***
