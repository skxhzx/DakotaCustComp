     *----------------------------------------------------------------
     * Begin P.GETBATID - Prototypes for GETBATID / GETRECID
     *
     *   06/10/17  DAS  7.10
     *     - Created
     *
     *----------------------------------------------------------------

     D GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

     D GetRecId        pr                  extpgm('GETRECID')
     D  pWhse                         3s 0 const
     D  pFile                        10    const
     D  pRecId                       11p 0

     *** End P.GETBATID ***
