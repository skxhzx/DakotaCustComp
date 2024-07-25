      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pUser          s             10
     d  pPgm           s             20
     d  pObjLoc        s             10
     d  pWhse          s              3p 0
     d  pMinBefDep     s              3p 0 inz(32)
     d  pMinAftDep     s              3p 0 inz(32)
     d  pSelMrgPcs     s              1    inz('Y')
     d  pSelMrgBlk     s              1    inz('Y')
     d  pSelIdle       s              1    inz('Y')

     d  i              s              5p 0
     d  loops          s              5p 0

     C     *entry        plist
     C                   parm                    $pwhse           15 5
     C                   parm                    $ploops          15 5
     C                   parm                    $pdelay          15 5

     C                   eval      pWhse   = $pwhse
     C                   eval      loops = $ploops

     C                   do        loops         i

     C                   eval      pSessId = %editc(i: 'X') + ':'
     C                                     + %char(%timestamp)

     C                   call      'UPDSUM003'
     c                   parm                    pErrMsg
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm      'TSTUPDSUM3'  pPgm
     c                   parm                    pObjLoc
     c                   parm                    pWhse
     c                   parm                    pMinBefDep
     c                   parm                    pMinAftDep
     c                   parm                    pSelMrgPcs
     c                   parm                    pSelMrgBlk
     c                   parm                    pSelIdle

     C                   call(e)   'DLYJOBCL'
     C                   parm      $pdelay       seconds           5 0

     C                   enddo

     c                   eval      *inlr = *on
