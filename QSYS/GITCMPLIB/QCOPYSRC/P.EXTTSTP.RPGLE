     *----------------------------------------------------------------
     * Begin P.EXTTSTP - Prototypes for EXTTSTP
     *
     *   04/23/20  RBD  7.40
     *     - Created
     *
740aA*   12/14/20  RBD  7.40a
     *     - Fix: Enlarged size of iRtnMsg from 60 to 120 because
     *       #pgmmsg, which is 80 long, is being returned as part of
     *       the msg in EXTTSTP subr *PSSR.
     *
     *----------------------------------------------------------------

     d ttparec       e ds                  extname(ttstpexa) inz(*EXTDFT)

     d EXTTSTP         pr                  extpgm('EXTTSTP')
     d  iCmd                         10    const
     d  iRtnCode                     10
740aDd* iRtnMsg                      60
740aMd  iRtnMsg                     120
     d  ittpawhs                            like(ttpawhs)
     d  ittparti                            like(ttparti)
     d  ittpastp                            like(ttpastp)
     d  ittpapss                            like(ttpapss) options(*nopass)
     d  sttpapss                       n    const options(*nopass)
     d  ittpapsc                            like(ttpapsc) options(*nopass)
     d  sttpapsc                       n    const options(*nopass)
     d  ittpapal                            like(ttpapal) options(*nopass)
     d  sttpapal                       n    const options(*nopass)
     d  ittpaiss                            like(ttpaiss) options(*nopass)
     d  sttpaiss                       n    const options(*nopass)
     d  ittpaisc                            like(ttpaisc) options(*nopass)
     d  sttpaisc                       n    const options(*nopass)
     d  ittpaist                            like(ttpaist) options(*nopass)
     d  sttpaist                       n    const options(*nopass)
     d  ittparetsh                          like(ttparetsh) options(*nopass)
     d  sttparetsh                     n    const options(*nopass)
     d  ittparet                            like(ttparet) options(*nopass)
     d  sttparet                       n    const options(*nopass)

     *** End P.EXTTSTP ***
