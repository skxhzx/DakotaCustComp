
     *----------------------------------------------------------------
     * Begin P.PCMGETQTR- Prototypes for PCMGETQTR
     *
     *   03/19/18  LMC  7.20
     *     - Created
730aA*   12/26/19  LMC  7.30a
     *     - Added the customer number parm for cust questions
     *
     *----------------------------------------------------------------

     D PCMGETQTR       pr                  extpgm('PCMGETQTR')
     D  pCallNum                      1p 0
     D  pUser                        10    varying
     D  pPgm                         20
     D  pCmd                          8    varying
     D  pWhse                         3  0
     D  pLevel                        4    varying
     D  pType                         3    varying
     D  pXML                      20000A   varying
730aAD  pCust                        15    varying

     *** End P.PCMGETQTR     ***
