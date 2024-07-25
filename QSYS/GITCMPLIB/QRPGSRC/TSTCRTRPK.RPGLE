      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTCRTRPK  Test creating repack slot
     *  27 August 2010
     *  Dave Sommerville
     *----------------------------------------------------------------

610bA /COPY *libl/qcopysrc,C#DRIPARMS

610bA /COPY *libl/qcopysrc,C#SLOT
610bAD saveVer#        s                   like($slver#)
610bAD save$slot       s                   like($slot)

     D                sds
     D  #prog            *proc

520eAD drierr                          n

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = 001
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = 'REF'
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = 'LET01EA'
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = '63-275-3D'
     C                   eval      $saactionu = *on
     C                   eval      $saAction  = 'RPK'

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CRTREPAKD'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
413aA
     C                   eval      *inlr = *on

610bA*----------------------------------------------------------------
610bA*----------------------------------------------------------------
610bA*                     DRI SUBROUTINES
610bA*----------------------------------------------------------------
610bA*----------------------------------------------------------------

610bA*----------------------------------------------------------------
610bA*  clr$slot  Clear $slot data structure fields
610bA*----------------------------------------------------------------

610bAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr

610bA*----------------------------------------------------------------
610bA*  zzzdricop  Call DRICOP
610bA*----------------------------------------------------------------

610bAC     zzzdricop     begsr

     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2

     C                   select

     C                   when      %error
     C                   eval      drierr = *on

     C                   when      $drireturn <> '*OK'
     C                   eval      drierr = *on

     C                   endsl

     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2

     C     enddricop     endsr
