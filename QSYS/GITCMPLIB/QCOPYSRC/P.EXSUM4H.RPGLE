     *----------------------------------------------------------------
     * Begin P.EXSUM4H  - Prototypes for EXSUM004H
     *
     *   02/17/20  RBD  7.40
     *     - Created
     *
     *----------------------------------------------------------------

     d sharec        e ds                  extname(sum004hexa) inz(*EXTDFT)

     d EXSUM004H       pr                  extpgm('EXSUM004H')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ishawhse                            like(shawhse)
     d  isharptid                           like(sharptid)
     d  isharoute                           like(sharoute) options(*nopass)
     d  ishartid                            like(shartid) options(*nopass)
     d  ishafdlvdat                         like(shafdlvdat) options(*nopass)
     d  ishatdlvdat                         like(shatdlvdat) options(*nopass)
     d  ishapo                              like(shapo) options(*nopass)
     d  ishatrn                             like(shatrn) options(*nopass)

     *** End P.EXSUM4H ***
