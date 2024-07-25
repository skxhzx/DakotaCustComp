      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TESTVAR2  - Test variable length parm
     *  03 February 2009
     *  Dave
     *----------------------------------------------------------------

520aMd pOptStr         s           2048A
520aMd len             s              5  0

     c                   call      'GETDDOPTS'
     c                   parm                    pOptStr

     c                   eval      len = %len(pOptStr)
     c                   eval      len = %len(%trim(pOptStr))
     c                   eval      len = %size(pOptStr)

     c                   eval      *inlr = *on
