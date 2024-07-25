     *----------------------------------------------------------------
     * Begin P.UMLABEL    - Prototypes for UMLABEL
     *
     *   08/13/19  DAS  7.30
     *     - Created
     *
     *----------------------------------------------------------------

     d lburec        e ds                  extname(labelum) inz(*EXTDFT)

     d UMLABEL         pr                  extpgm('UMLABEL')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ilbuwhse                            like(lbuwhse)
     d  ilbulbl#                            like(lbulbl#)
     d  ilbufpflg                           like(lbufpflg) options(*nopass)
     d  ilbualq1                            like(lbualq1) options(*nopass)
     d  ilbualu1                            like(lbualu1) options(*nopass)
     d  ilbualq2                            like(lbualq2) options(*nopass)
     d  ilbualu2                            like(lbualu2) options(*nopass)
     d  ilbualq3                            like(lbualq3) options(*nopass)
     d  ilbualu3                            like(lbualu3) options(*nopass)
     d  ilbualman                           like(lbualman) options(*nopass)
     d  ilbualmab1                          like(lbualmab1) options(*nopass)
     d  ilbualmab2                          like(lbualmab2) options(*nopass)
     d  ilbualmrn                           like(lbualmrn) options(*nopass)
     d  ilbualmrb1                          like(lbualmrb1) options(*nopass)
     d  ilbualmrb2                          like(lbualmrb2) options(*nopass)
     d  ilbupkq1                            like(lbualq1) options(*nopass)
     d  ilbupku1                            like(lbualu1) options(*nopass)
     d  ilbupkq2                            like(lbualq2) options(*nopass)
     d  ilbupku2                            like(lbualu2) options(*nopass)
     d  ilbupkq3                            like(lbualq3) options(*nopass)
     d  ilbupku3                            like(lbualu3) options(*nopass)
     d  ilbupkman                           like(lbualman) options(*nopass)
     d  ilbupkmab1                          like(lbualmab1) options(*nopass)
     d  ilbupkmab2                          like(lbualmab2) options(*nopass)
     d  ilbupkmrn                           like(lbualmrn) options(*nopass)
     d  ilbupkmrb1                          like(lbualmrb1) options(*nopass)
     d  ilbupkmrb2                          like(lbualmrb2) options(*nopass)

     *** End P.UMLABEL ***
