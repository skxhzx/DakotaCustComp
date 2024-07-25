
     *----------------------------------------------------------------
     * Begin P.GETOPINT   - Prototypes for GETOPTINT
     *
     *   09/22/16  RTR  7.00
     *     - Created
     *
     *----------------------------------------------------------------
     *
     *  Add to D-Spec Section:
     *    /copy *libl/qcopysrc,p.getopint
     *
     *  Sample call of GETOPTINT:
     *    /free
     *      optint.type = 'EXPORD';
     *      optint.cat = 'ORDER POD';
     *      optint.name = 'EXPORT POD RECORD';
     *      GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
     *                optint.valn: optint.vala: optint.return);
     *      if optint.return = '*OK';
     *        (your code here)
     *      endif;
     *    /end-free
     *
     *----------------------------------------------------------------

     d GetOptInt       pr                  extpgm('GETOPTINT')
      * Input
     d   pType                       12    const
     d   pCat                        20    const
     d   pName                       20    const
      * Output
     d   pValT                        1
     d   pValN                       15  5
     d   pValA                      100
     d   pReturn                     10

     d optint          ds                  qualified
     d  type                         12a
     d  cat                          20a
     d  name                         20a
     d  valt                          1a
     d  valn                         15p 5
     d  vala                        100a
     d  return                       10a

     *** End P.GETOPINT   ***
