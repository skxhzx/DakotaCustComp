
     *----------------------------------------------------------------
     * Begin P.WRTSESSL - Prototypes for WRTSESSLOG
     *
     *   02/04/14  DAS  6.50
     *     - Created
     *
     *----------------------------------------------------------------

     D WRTSESSLOG      pr                  extpgm('WRTSESSLOG')
     D  pSessId                      40    const
     D  pPgm                         10    const
     D  pGUIPgm                      20    const
     D  pGUIUser                     10    const
     D  pText                       100    const
     D  pJobName                     10    const options(*nopass)
     D  pJobUser                     10    const options(*nopass)
     D  pJobNbr                       6    const options(*nopass)

     *** End P.WRTSESSLOG ***
