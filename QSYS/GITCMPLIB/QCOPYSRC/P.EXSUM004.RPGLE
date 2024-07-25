     *----------------------------------------------------------------
     * Begin P.EXSUM004  - Prototypes for EXSUM004
     *
     *   02/17/20  RBD  7.40
     *     - Created
     *
740aA*   05/24/20  RBD  7.40a
     *     - Added label number.
     *     - Added date type entered.
     *
     *----------------------------------------------------------------

     d smarec        e ds                  extname(sum004exa) inz(*EXTDFT)

     d EXSUM004        pr                  extpgm('EXSUM004')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ismawhse                            like(smawhse)
     d  ismarptid                           like(smarptid)
     d  ismalcns                            like(smalcns)
     d  ismadlvdat                          like(smadlvdat) options(*nopass)
     d  ismatran                            like(smatran) options(*nopass)
     d  ismalbl                             like(smalbl) options(*nopass)
     d  ismadtetyp                          like(smadtetyp) options(*nopass)

     *** End P.EXSUM004 ***
