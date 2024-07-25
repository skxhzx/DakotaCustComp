     *----------------------------------------------------------------
     * Begin P.EXWRKFLDS - Prototypes for DDWRKFLDS
     *
     *   03/24/21  KDE  7.50
     *     - Created
     *
     *----------------------------------------------------------------

     d ddrecw        e ds                  extname(ddwrkflds) inz(*EXTDFT)

     d ddwrkflds       pr                  extpgm('DDWRKFLDS')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iddwwhse                            like(ddwwhse)
     d  iddwrtid                            like(ddwrtid)
     d  iddwsnap                            like(ddwsnap)
720aAd  iddwid                              like(ddwid)
     d  iddwrow                             like(dddrow)
     d  iddwcol                             like(dddcol)
740 Ad  iddwmrg                             like(ddwmrg)
740 Ad  iddwspin                            like(ddwspin)

     *** End P.EXWRKFLD ***
