     *----------------------------------------------------------------
     * Begin P.EXPOHDR  - Prototypes for EXPOHDR
     *
     *   09/12/18  DAS  7.20
     *     - Created
     *
     *----------------------------------------------------------------

     d pharec        e ds                  extname(pohdrexa) inz(*EXTDFT)

     d EXPOHDR         pr                  extpgm('EXPOHDR')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iphawhse                            like(phawhse)
     d  iphapo                              like(phapo)
     d  ipoacmpflg                          like(phacmpflg) options(*nopass)

     *** End P.EXPOHDR ***
