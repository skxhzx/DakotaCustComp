     *----------------------------------------------------------------
     * Begin P.EXORDH   - Prototypes for EXORDH
     *
     *   10/19/18  DAS  7.20
     *     - Created
     *
730aA*   01/22/19  DAS  7.30a
     *     - Added iohaaudts
     *
730bA*   03/14/19  DAS  7.30b
     *     - Added iohaorda, iohacusta
     *
     *----------------------------------------------------------------

     d oharec        e ds                  extname(ordhexa) inz(*EXTDFT)

     d EXORDH          pr                  extpgm('EXORDH')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iohawhse                            like(ohawhse)
     d  iohaord                             like(ohaord)
     d  iohaaudflg                          like(ohaaudflg) options(*nopass)
     d  iohaaudid                           like(ohaaudid) options(*nopass)
     d  iohaaudcmp                          like(ohaaudcmp) options(*nopass)
     d  iohaaudby                           like(ohaaudby) options(*nopass)
730aAd  iohaaudts                           like(ohaaudts) options(*nopass)
730bAd  iohaorda                            like(ohaorda) options(*nopass)
730bAd  iohacusta                           like(ohacusta) options(*nopass)

     *** End P.EXORDH ***
