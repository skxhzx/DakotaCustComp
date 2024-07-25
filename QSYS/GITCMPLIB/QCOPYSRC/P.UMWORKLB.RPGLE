     *----------------------------------------------------------------
     * Begin P.UMWORKLB   - Prototypes for UMWORKLBL
     *
     *   08/13/19  DAS  7.30
     *     - Created
     *
     *----------------------------------------------------------------

     d lwurec        e ds                  extname(worklblum) inz(*EXTDFT)

     d UMWORKLBL       pr                  extpgm('UMWORKLBL')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ilwuwhse                            like(lwuwhse)
     d  ilwulbl#                            like(lwulbl#)
     d  ilwufpflg                           like(lwufpflg) options(*nopass)
     d  ilwualq1                            like(lwualq1) options(*nopass)
     d  ilwualu1                            like(lwualu1) options(*nopass)
     d  ilwualq2                            like(lwualq2) options(*nopass)
     d  ilwualu2                            like(lwualu2) options(*nopass)
     d  ilwualq3                            like(lwualq3) options(*nopass)
     d  ilwualu3                            like(lwualu3) options(*nopass)
     d  ilwualman                           like(lwualman) options(*nopass)
     d  ilwualmab1                          like(lwualmab1) options(*nopass)
     d  ilwualmab2                          like(lwualmab2) options(*nopass)
     d  ilwualmrn                           like(lwualmrn) options(*nopass)
     d  ilwualmrb1                          like(lwualmrb1) options(*nopass)
     d  ilwualmrb2                          like(lwualmrb2) options(*nopass)
     d  ilwupkq1                            like(lwualq1) options(*nopass)
     d  ilwupku1                            like(lwualu1) options(*nopass)
     d  ilwupkq2                            like(lwualq2) options(*nopass)
     d  ilwupku2                            like(lwualu2) options(*nopass)
     d  ilwupkq3                            like(lwualq3) options(*nopass)
     d  ilwupku3                            like(lwualu3) options(*nopass)
     d  ilwupkman                           like(lwualman) options(*nopass)
     d  ilwupkmab1                          like(lwualmab1) options(*nopass)
     d  ilwupkmab2                          like(lwualmab2) options(*nopass)
     d  ilwupkmrn                           like(lwualmrn) options(*nopass)
     d  ilwupkmrb1                          like(lwualmrb1) options(*nopass)
     d  ilwupkmrb2                          like(lwualmrb2) options(*nopass)

     *** End P.UMWORKLB ***
