      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDLT006    Create OSS slots for misrouted OSS pallets
     *  26 May 2009
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
417yA /COPY *libl/qcopysrc,C#SLOT
417aAD savever#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D error           s               n
     D $pwhse          s              3S 0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#PGMINFDS

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $cmd              8

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     * Get out if proper command is not sent in.

     C                   if        $cmd <> '*UPDATE'
     C                   eval      *inlr = *on
     C                   return
     C                   endif
414 A*
414 A*    Get User's employee number to be written to PORCV file
414 A*    if any records are flagged as touched.
414 A*
414 AC                   call      'GETUSER'
600bAC                   parm      #curruser     $code            10
414 AC                   parm      0             $whse             3 0
414 AC                   parm      0             $emp#             5 0
414 AC                   parm      *blanks       $fnam            15
414 AC                   parm      *blanks       $init             1
414 AC                   parm      *blanks       $lnam            20
414 AC                   parm      *blanks       $whdp             5
414 AC                   parm      *blanks       $styp             1
414 AC                   parm      *blanks       $shft             6
414 AC                   parm      *blanks       $crew             6
414 AC                   parm      0             $nhrs             3 1
414 AC                   parm      *blanks       $rtn              8

     *  Create special license

     C                   call      'PIROSSLCN'
     C                   parm      900           $pwhse
     C                   parm      'K'           w9stg             1
     C                   parm      ' '           ossLcns          15

     *  Initialize slot fields

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = 'DRY'
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = 'DA101'
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = 'F'
     C                   eval      $slentdu = *on
     C                   eval      $slentd  = 20080522
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = 0
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = $slitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'TFR'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = 0
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = 0
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = 'OSS'

     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = ossLcns
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = ossLcns

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%OSSIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      $saOLcns = $saOLcns
     C                   endif

     * Bye, Bye.

     C                   eval      *inlr = *on

600dA*----------------------------------------------------------------
600dA*  clr$slot  Clear $slot data structure fields
600dA*----------------------------------------------------------------
600dA
600dAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600aAC                   clear                   $slot2
     C                   eval      $slver# = savever#
600aAC                   eval      $saemp#U = *on
600aAC                   eval      $saemp# = $emp#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
417yAC                   when      $dricommand = '*SLOT'
417yAC                   eval      $dridata = $slot
600aAC                   eval      $dridata2 = $slot2
     C                   endsl

500 AC                   call(e)   'DRICOP'
500 AC                   parm                    $dricommand
500 AC                   parm                    $drisubcmd
500 AC                   parm                    $drisys2upd
500 AC                   parm      #pgm          $driprogram
500 AC                   parm      ' '           $drireturn
500 AC                   parm      ' '           $drimessage
500 AC                   parm                    $dridata
500 AC                   parm                    $dridata2

     C                   select

417yMC                   when      %error
     C                   eval      error = *on

417yMC                   when      $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
417yAC                   when      $dricommand = '*SLOT'
417yAC                   eval      $slot = $dridata
600aAC                   eval      $slot2 = $dridata2
     C                   endsl

     C     enddricop     endsr
