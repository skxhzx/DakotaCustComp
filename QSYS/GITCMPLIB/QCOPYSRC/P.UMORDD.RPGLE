     *----------------------------------------------------------------
     * Begin P.UMORDD   - Prototypes for UMORDD
     *
     *   08/13/19  DAS  7.30
     *     - Created
     *
     *----------------------------------------------------------------

     d odurec        e ds                  extname(orddum) inz(*EXTDFT)

     d UMORDD          pr                  extpgm('UMORDD')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  ioduwhse                            like(oduwhse)
     d  ioduord                             like(oduord)
     d  ioduseq                             like(oduseq)
     d  ioduitem                            like(oduitem)
     d  iodufpflg                           like(odufpflg) options(*nopass)
     d  ioduorq1                            like(oduorq1) options(*nopass)
     d  ioduoru1                            like(oduoru1) options(*nopass)
     d  ioduorq2                            like(oduorq2) options(*nopass)
     d  ioduoru2                            like(oduoru2) options(*nopass)
     d  ioduorq3                            like(oduorq3) options(*nopass)
     d  ioduoru3                            like(oduoru3) options(*nopass)
     d  ioduorman                           like(oduorman) options(*nopass)
     d  ioduormab1                          like(oduormab1) options(*nopass)
     d  ioduormab2                          like(oduormab2) options(*nopass)
     d  ioduormrn                           like(oduormrn) options(*nopass)
     d  ioduormrb1                          like(oduormrb1) options(*nopass)
     d  ioduormrb2                          like(oduormrb2) options(*nopass)
     d  iodupkq1                            like(oduorq1) options(*nopass)
     d  iodupku1                            like(oduoru1) options(*nopass)
     d  iodupkq2                            like(oduorq2) options(*nopass)
     d  iodupku2                            like(oduoru2) options(*nopass)
     d  iodupkq3                            like(oduorq3) options(*nopass)
     d  iodupku3                            like(oduoru3) options(*nopass)
     d  iodupkman                           like(oduorman) options(*nopass)
     d  iodupkmab1                          like(oduormab1) options(*nopass)
     d  iodupkmab2                          like(oduormab2) options(*nopass)
     d  iodupkmrn                           like(oduormrn) options(*nopass)
     d  iodupkmrb1                          like(oduormrb1) options(*nopass)
     d  iodupkmrb2                          like(oduormrb2) options(*nopass)

     *** End P.UMORDD ***
