
     *----------------------------------------------------------------
     * Begin P.WRTRTELG   - Prototypes for WRTRTELOG
     *
     *   12/31/17  DAS  7.10
     *     - Created
720aA*   10/07/18  DAS  7.20a
     *     - Added parameter minutes
     *
     *----------------------------------------------------------------

     d WrtRteLog       pr                  extpgm('WRTRTELOG')
     d  $pwhse                        3  0
     d  $prtid                        5
     d  $pmrid                       26
     d  $pgrpid                       7  0
     d  $pgrpcode                    10
     d  $psubgrp                     12
     d  $ptype                        1
     d  $pcurusr                     10
     d  $ppgm                        10
     d  $jobqts                      26
     d  $jobquc                      26
720aAd  $pmin                         7  2 options(*nopass)

     *** End P.WRTRTELG ***
