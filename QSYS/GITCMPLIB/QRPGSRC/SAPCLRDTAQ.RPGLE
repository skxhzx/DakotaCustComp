      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  CLRSAPDTAQ    Clear SAP Qty In/Out data queues
     *  20 January 2020
     *  Dave Sommerville
     *
     *  Revisions
     *
740 A*    01/30/20  DAS  7.40
     *      - Created
     *
     *----------------------------------------------------------------

     C     *Entry        PList
     C                   Parm                    $ptype            5
     C                   Parm                    $plib            10

     C                   if        $ptype = '*IN' or $ptype = '*BOTH'
     C                   call      'QCLRDTAQ'
     C                   parm      'SAPQTYIN'    dqin             10
     C                   parm                    $plib
     C                   endif

     C                   if        $ptype = '*OUT' or $ptype = '*BOTH'
     C                   call      'QCLRDTAQ'
     C                   parm      'SAPQTYOUT'   dqout            10
     C                   parm                    $plib
     C                   endif

     C                   seton                                        lr
