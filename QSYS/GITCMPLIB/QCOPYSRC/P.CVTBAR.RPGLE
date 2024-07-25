     *----------------------------------------------------------------
     * Begin P.CVTBAR - Prototypes for CVTBAR
     *
     *   10/01/12  DAS  6.40a
     *     - Created
700a *   04/19/16  LMC  7.00a
     *     - Added cbwhse for Metric system changes
740a *   04/15/20  LMC  7.40a
     *     - Added cbkilolbs and cbitem.
740b *   09/25/20  RBD  7.40b
     *     - IT222 wasn't compiling because it didn't reference
     *       the 2 new parms, cbkilolbs and cbitem, so I made
     *       them optional and left IT222 alone.
     *
     *----------------------------------------------------------------

     D cvtbar          pr                  extpgm('CVTBAR')
640dAD  $cbcmd                        8    const
640dAD  $cbbar                      100    const
640dAD  $cbcod                        3  0
640dAD  $cbdec                        1  0
640dAD  $cbdsc                       30
640dAD  $cbpos                        3  0
640dAD  $cbtyp                        1  0
640dAD  $cbv1                        11  3
640dAD  $cbv2                        50
640dAD  $cbrtn                        8
640dAD  $cberm                       60
640dAD  $cbven                       10  0
640dAD  $cvtdata                    256
640dAD  $cvtdata2                   256
700aAD  $cbwhse                       3  0
740bMD  $cbkilolbs                    1    options(*nopass)
740bMD  $cbitem                      15    options(*nopass)

     *** End P.CVTBAR ***
