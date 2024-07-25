     *----------------------------------------------------------------
     * Begin P.EXRTEHED - Prototypes for EXRTEHED
     *
     *   09/06/18  DAS  7.20
     *     - Created
740 A*   11/24/20  KDE  7.40
     *     - Add field RHRDYPP
     *
     *----------------------------------------------------------------

     d rharec        e ds                  extname(rtehedexa) inz(*EXTDFT)

     d EXRTEHED        pr                  extpgm('EXRTEHED')
     d  iCmd                         10    const
     d  iRtnCode                     10
     d  iRtnMsg                      60
     d  irhawhse                            like(rhawhse)
     d  irhartid                            like(rhartid)
     d  irhatbtype                          like(rhatbtype) options(*nopass)
     d  irhardypp                           like(rhardypp) options(*nopass)
750 Ad  irhaasn                             like(rhaasn) options(*nopass)

     *** End P.EXRTEHED ***
