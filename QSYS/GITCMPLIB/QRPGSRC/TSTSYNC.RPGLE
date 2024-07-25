      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTSYNCH   Test *SYNCLCNS
     *  21 February 2009
     *  Dave Sommerville
     *----------------------------------------------------------------

500aA /COPY *libl/qcopysrc,C#DRIPARMS
500aA /COPY *libl/qcopysrc,C#SLOT
500aAD saveVer#        s                   like($slver#)

     C                   eval      savever# = $slver#
     C                   clear                   $slot
600bAC                   clear                   $slot2
     C                   eval      $slver# = savever#
600bAC                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = 900
600bAC                   eval      $saToLcnsU = *on
600bAC                   eval      $saToLcns = '*SU'
600bAC                   eval      $saActionU = *on
600bAC                   eval      $saAction = 'SU '
600bA
600bAC                   eval      $dricommand = '*SLOT'
600bAC                   eval      $drisubcmd  = '%SYNCLCNS'
600bAC                   eval      $drisys2upd = 'D'
     C                   eval      $dridata = $slot
600bAC                   eval      $dridata2 = $slot2
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      'TSTSYNC'     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2

     C                   eval      $slot = $dridata
600bAC                   eval      $slot2 = $dridata2

600bAC                   eval      *inlr = *on
