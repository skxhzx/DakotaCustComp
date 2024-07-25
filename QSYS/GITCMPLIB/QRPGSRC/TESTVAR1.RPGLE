      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TESTVAR1  - Test variable length parm
     *  03 February 2009
     *  Dave
     *----------------------------------------------------------------

520aMd pOptStr         s             10A   varying

     c     *entry        plist
     c                   parm                    pOptStr

     c**                 eval      pOptStr  = 'abcdefghijklmn'
     c                   eval      pOptStr  = 'abc'

     c                   eval      *inlr = *on
