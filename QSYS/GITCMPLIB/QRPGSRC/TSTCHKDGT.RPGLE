417cA /copy *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *
     *  TSTCHKDGT   Test SETCHKDGT
     *  29 Nobember 2006
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    11/29/06  DAS  5.10
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Frtehed    ip   e           k disk

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   move      rhwhse        $pwhse
     C                   call      'SETCHKDGT'
     C                   parm                    $pwhse            3
     C                   parm      rhrtid        $prtid            5
