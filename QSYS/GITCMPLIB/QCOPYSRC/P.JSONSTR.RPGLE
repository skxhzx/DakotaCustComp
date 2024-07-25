     *----------------------------------------------------------------
     * Begin P.JSONSTR     Prototypes used by $JSONSTR subprocedures
     *                     $JSONSTR is needed for this
     *
     *   04/22/21  DAS  7.50
     *     - Created
     *
     *----------------------------------------------------------------

     d JsonGetFields   pr
     d  node                               like(yajl_val) const

     d JsonGetValue    pr         65535A   varying
     d  node                               like(yajl_val) const
     d  key                          50A   varying const

     *** End P.JSONSTR ***
