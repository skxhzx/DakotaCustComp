     *----------------------------------------------------------------
     * Begin P.EXTTRTE - Prototypes for EXTTRTE
     *
     *   09/26/18  DAS  7.20
     *     - Created
     *
740aA*   04/23/20  RBD  7.40a
     *     - Added: TRAPSS   PALLETSCAN scanned count
     *              TRAPSC   PALLETSCAN clicked count
     *              TRAPAL   Total pallet count
     *              TRAISS   INSTORESCAN scanned count
     *              TRAISC   INSTORESCAN clicked count
     *              TRAIST   INSTORESCAN total count
     *              TRARETSH Return code short count
     *              TRARET   Total qty items returned
     *
740bA*   12/11/20  RBD  7.40b
     *     - Fix: Enlarged size of iRtnMsg from 60 to 120 because
     *       #pgmmsg, which is 80 long, was being returned as part
     *       of the msg in EXTTRTE subr *PSSR and caused it to blow up.
     *
     *----------------------------------------------------------------

     d trarec        e ds                  extname(ttrteexa) inz(*EXTDFT)

     d EXTTRTE         pr                  extpgm('EXTTRTE')
     d  iCmd                         10    const
     d  iRtnCode                     10
740bDd* iRtnMsg                      60
740bMd  iRtnMsg                     120
     d  itrawhse                            like(trawhse)
     d  itrartid                            like(trartid)
     d  itradspid                           like(tradspid) options(*nopass)
     d  stradspid                      n    const options(*nopass)
     d  itrasnum                            like(trasnum) options(*nopass)
     d  strasnum                       n    const options(*nopass)
     d  itranetid                           like(tranetid) options(*nopass)
     d  stranetid                      n    const options(*nopass)
     d  itrablueid                          like(trablueid) options(*nopass)
     d  strablueid                     n    const options(*nopass)
     d  itrasimid                           like(trasimid) options(*nopass)
     d  strasimid                      n    const options(*nopass)
     d  itraphone                           like(traphone) options(*nopass)
     d  straphone                      n    const options(*nopass)
     d  itraappver                          like(traappver) options(*nopass)
     d  straappver                     n    const options(*nopass)
740aAd  itrapss                             like(trapss) options(*nopass)
740aAd  strapss                        n    const options(*nopass)
740aAd  itrapsc                             like(trapsc) options(*nopass)
740aAd  strapsc                        n    const options(*nopass)
740aAd  itrapal                             like(trapal) options(*nopass)
740aAd  strapal                        n    const options(*nopass)
740aAd  itraiss                             like(traiss) options(*nopass)
740aAd  straiss                        n    const options(*nopass)
740aAd  itraisc                             like(traisc) options(*nopass)
740aAd  straisc                        n    const options(*nopass)
740aAd  itraist                             like(traist) options(*nopass)
740aAd  straist                        n    const options(*nopass)
740aAd  itraretsh                           like(traretsh) options(*nopass)
740aAd  straretsh                      n    const options(*nopass)
740aAd  itraret                             like(traret) options(*nopass)
740aAd  straret                        n    const options(*nopass)

     *** End P.EXTTRTE ***
