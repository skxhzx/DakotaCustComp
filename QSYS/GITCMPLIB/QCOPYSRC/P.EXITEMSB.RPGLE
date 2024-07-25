     *----------------------------------------------------------------
     * Begin P.EXITEMSB - Prototypes for EXITEMSUB
     *
     *   06/11/21  KDE  7.50
     *     - Created
     *
     *----------------------------------------------------------------

     d isxrec        e ds                  extname(itemsubexa) inz(*EXTDFT)

     d EXITEMSUB       pr                  extpgm('EXITEMSUB')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iisxwhse                            like(isxwhse)
     d  iisxitem                            like(isxitem)
     d  iisxcust                            like(isxcust)
     d  iisxisub                            like(isxisub) options(*nopass)
     d  iisxas                              like(isxas) options(*nopass)
     d  iisxseq                             like(isxseq) options(*nopass)
     d  iisxaddts                           like(isxaddts) options(*nopass)
     d  iisxaddusr                          like(isxaddusr) options(*nopass)
     *** End P.EXITEMSUB **
