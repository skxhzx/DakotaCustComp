     *----------------------------------------------------------------
     * Begin P.EXITEMOR - Prototypes for EXITEMORD
     *
     *   05/07/20  DAS  7.40
     *     - Created
     *
     *----------------------------------------------------------------

     d ioerec        e ds                  extname(itemordexa) inz(*EXTDFT)

     d EXITEMORD       pr                  extpgm('EXITEMORD')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iioewhs                             like(ioewhs)
     d  iioeitm                             like(ioeitm)
     d  iioebd1                             like(ioebd1) options(*nopass)

     *** End P.EXITEMOR ***
