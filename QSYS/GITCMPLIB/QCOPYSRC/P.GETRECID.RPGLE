     *----------------------------------------------------------------
     * Begin P.GETRECID - Prototypes for GETRECID
     *
     *   12/05/18  DAS  7.30
     *     - Created
     *     - This used to contain everything from P.BFCPHRASE
     *       plus a section for GETRECID to be called with CALLP.
     *     - Removed all non-getrecid code.
     *     - Changed getrecid to be called from /free without CALLP.
     *
     *----------------------------------------------------------------

     D getRecId        pr                  extpgm('GETRECID')
     D  pWhse                         3s 0 const
     D  pFile                        10    const
     D  pRecId                       11p 0
     D  pRtnCode                     10    options(*nopass)

     *** End P.GETRECID ***
