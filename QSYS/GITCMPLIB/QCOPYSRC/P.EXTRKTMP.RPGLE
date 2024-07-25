     *----------------------------------------------------------------
     * Begin P.EXTRKTMP - Prototypes for EXTRKTMPD
     *
     *   08/28/20  KDE  7.40
     *     - Created
     *
     *----------------------------------------------------------------

     d exRow           s              2s 0
     d exTruk          s             10
     d ttxrec        e ds                  extname(trktmpdexa) inz(*EXTDFT)

     d EXTRKTMPD       pr                  extpgm('EXTRKTMPD')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ttxwhse                       3s 0
     d  ttxtruk                      10
     d  ttxrow                        2s 0
     d  ttxicub1                      5s 2  options(*nopass)
     d  ttxicub2                      5s 2  options(*nopass)
     d  ttxicub3                      5s 2  options(*nopass)
     d  ttxicub4                      5s 2  options(*nopass)
     d  ttxicub5                      5s 2  options(*nopass)
     d  ttxicub6                      5s 2  options(*nopass)
     d  ttxicub7                      5s 2  options(*nopass)
     d  ttxicub8                      5s 2  options(*nopass)
     d  ttxicub9                      5s 2  options(*nopass)

     *** End P.EXTRKTMP ***
