     *----------------------------------------------------------------
     * Begin P.EXPALLET - Prototypes for EXPALLET
     *
     *   06/02/18  DAS  7.20
     *     - Created
     *
     *----------------------------------------------------------------

     d plarec        e ds                  extname(palletexa) inz(*EXTDFT)

     D EXPALLET        pr                  extpgm('EXPALLET')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  iplacode                           like(placode)
     d  iplatype                           like(platype) options(*nopass)
     d  iplawgt                            like(plawgt) options(*nopass)
     d  iplamaxwgt                         like(plamaxwgt) options(*nopass)

     *** End P.EXPALLET ***
