      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TESTVAR2  - Test variable length parm
     *  03 February 2009
     *  Dave
     *----------------------------------------------------------------

520aMd pOptStr         s             10A   varying
520aMd len             s              3  0

     c                   eval      len = %len(pOptStr)
     c                   eval      len = %len(%trim(pOptStr))
     c                   eval      len = %size(pOptStr)

     c                   call      'TESTVAR1'
     c                   parm                    pOptStr

     c                   eval      len = %len(pOptStr)
     c                   eval      len = %len(%trim(pOptStr))
     c                   eval      len = %size(pOptStr)

     c                   eval      *inlr = *on
