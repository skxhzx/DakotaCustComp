     *----------------------------------------------------------------
     * Begin P.EXCUSTMA - Prototypes for EXCUSTMAST
     *
     *   10/19/18  DAS  7.20
     *     - Created
     *
720aA*   10/23/18  DAS  7.20a
     *     - Added icmaaudexpd.
     *
740 A*   05/06/20  KDE  7.40
     *     - Added icmspflg  (Single Pallet Flag)
     *     - Added icmaudr   (Audit Reason Description)
     *
     *----------------------------------------------------------------

     d cmarec        e ds                  extname(custmastxa) inz(*EXTDFT)

     d EXCUSTMAST      pr                  extpgm('EXCUSTMAST')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  icmawhse                            like(cmawhse)
     d  icmacust                            like(cmacust)
     d  icmaaudflg                          like(cmaaudflg) options(*nopass)
720aAd  icmaaudexpd                         like(cmaaudexpd) options(*nopass)
740 Ad  icmspflg                            like(cmspflg) options(*nopass)
740 Ad  icmaudr                             like(cmaudr) options(*nopass)

     *** End P.EXCUSTMA ***
