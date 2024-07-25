
     *----------------------------------------------------------------
     * Begin P.WRTLOG     - Prototypes for WRTLOG
     *
     *   10/20/17  RTR  7.10
     *     - Created
     *
     *----------------------------------------------------------------
     *
     *  Add to D-Spec Section:
     *    /copy *libl/qcopysrc,p.wrtlog
     *
     *  Sample call of WRTLOG:
     *    /free
     *      log.pgm = 'PROGRAM';
     *      log.type = '*INFO    ';
     *      log.text = 'Your info here.';
     *      WrtLog(log.pgm: log.type: log.text);
     *    /end-free
     *
     *----------------------------------------------------------------

     d WrtLog          pr                  extpgm('WRTLOG')
      * Input
     d   ppgm                        10    const
     d   ptype                       10    const
     d   ptext                     1024    const

     d log             ds                  qualified
     d  pgm                          10a
     d  type                         10a
     d  text                       1024a

     *** End P.WRTLOG     ***
