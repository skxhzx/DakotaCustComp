     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETSLOT   Get base/virtual slot for item.
     *  02 February 2004
     *  Dave Sommerville
     *
     *  Revisions:
     *
417 A*    02/02/04  DAS  4.17
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *   This program searchs a physical slot location looking a specific
     *   item. It returns the first slot it finds with the item.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
     D savever#        s                   like($slver#)
410 AD slotds        e ds                  extname(slot)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s               n
     D forever         s               n
     D savewhdp        s                   like($slwhdp)
     D saveaisl        s                   like($slaisl)
     D saveloc         s                   like($slloc)
     D saverlvl        s                   like($slrlvl)
417 AD savehand        s                   like($slhand)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PWHDP  Warehouse department
     *      $PBASE  Base slot display
     *      $PITEM  Item
     *
     *    Returned Parameters
     *      $PSLOT    Slot display (if one found)
     *      $PRETURN  *FOUND  - Slot found with item in it.
     *                *NOTFND - Slot not found with item in it.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $pbase           12
     C                   parm                    $pitem           15
     C                   parm                    $pslot           12
     C                   parm                    $preturn          8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      $pslot = ' '
     C                   eval      $preturn = '*NOTFND'

     *  Get base slot information.

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $pbase

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *    If base slot not found, then don't any further.

 1B  C                   if        error
goto C                   goto      bottom
 1E  C                   endif

     *  Base slot found.

     *    If item is in the base slot, look no more.

 1B  C                   if        $slitem = $pitem
goto C                   eval      $pslot = $sldisp
goto C                   eval      $preturn = '*FOUND'
goto C                   goto      bottom
 1E  C                   endif

     *  Item not in base slot. Now start reading virtual slots.

     C                   eval      savewhdp = $slwhdp
     C                   eval      saveaisl = $slaisl
     C                   eval      saveloc = $slloc
     C                   eval      saverlvl = $slrlvl
417 AC                   eval      savehand = $slhand

417 AC                   eval      $slprtyu = *on
417 AC                   eval      $slexpdu = *on
417 AC                   eval      $slentdu = *on
417 AC                   eval      $slaislu = *on
417 AC                   eval      $slaisl  = Saveaisl
417 AC                   eval      $sllocu  = *on
417 AC                   eval      $slloc   = Saveloc
417 AC                   eval      $slrlvlu = *on
417 AC                   eval      $slrlvl  = Saverlvl
417 AC                   eval      $slhandu = *on
417 AC                   eval      $slhand  = savehand
417 AC                   eval      $slpsequ = *on

     *  Loop through slots.

     C                   dow       forever = forever

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%NXTSLOTI'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   if        error
     C                             or $drireturn = 'EOF'
     C                             or $slwhdp <> savewhdp
     C                             or $slaisl <> saveaisl
     C                             or $slloc <> saveloc
     C                             or $slrlvl <> saverlvl
     C                   leave
     C                   endif

     *    If slot has item, then we're done.

 1B  C                   if        $slitem = $pitem
goto C                   eval      $pslot = $sldisp
goto C                   eval      $preturn = '*FOUND'
goto C                   leave
 1E  C                   endif

 1E  C                   enddo

 1E  C     bottom        tag

     C                   return

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   eval      $dridata = $slot

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      ' '           $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C*                  eval      errmsg    = 'Error occured on call to '
     C*                                      + 'DRICOP'
     C*                                      + '/' + %trim($drisubcmd)
     C*                                      + ' from ' + #prog

     C                   when      $drireturn <> '*OK' and
     C                             $drireturn <> 'EOF'
     C                   eval      error = *on

     C                   endsl

     C                   eval      $slot = $dridata

     C     enddricop     endsr
