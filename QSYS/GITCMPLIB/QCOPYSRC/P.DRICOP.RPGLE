     *----------------------------------------------------------------
     * Begin P.DRICOP - Prototypes for DRICOP
     *
     *   08/12/11  DAS  6.40
     *     - Created
     *
     *   09/09/11  DAS  6.40a
     *     - Added *NOPASS to pData2.
     *
     *   08/17/17  LMC  7.10a
     *     - Added pData3.
     *     - Added *NOPASS to pData3.
     *
     *----------------------------------------------------------------

     D driCop          pr                  extpgm('DRICOP')
     D  pCmd                         10
     D  pSubCmd                      10
     D  pSys2Upd                      1
     D  pProgram                     10
     D  pReturn                      10
     D  pMessage                     60
     D  pData                       512
     D  pData2                      512    options(*NOPASS)
     D  pData3                      512    options(*NOPASS)

     *** End P.DRICOP ***
