     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ZROLINSLT  Zero out LIN slot on a daily basis (Production)
     *  27 November 2018
     *  Mike Rooker
     *
416  *    11/27/18  MR   7.20
     *      - Created
     *
     *
     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     Fslot11    if   e           k disk
     *----------------------------------------------------------------
GFC A* Function prototypes.
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#SLOT
600bA /Copy qcopysrc,c#pgminfds
     D savever#        s                   like($slver#)
     *----------------------------------------------------------------
GFC A* Variables
     *----------------------------------------------------------------
     D Pwhse           S              3s 0
     D Paisl2          S              3A
     D Paisle          S              3A
     D Ploc            S              3s 0
     D Prlvl           S              2s 0
     D Phand           S              2a
     D error           S               n
     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D*$parms          ds
     D* $pcmd                  1      8
     D* $pprg                  9     18
     D* $puky                 19     68
     D* $prtn                 69     76
     D* $perm                 77    136
     D* $pmsg                 77     80
     *
     *   Redefine key
     *
     D* $pwhse                19     21  0
     D* $pwhdp                22     26
     D* $pdisp                27     38
213 AD* $puser                39     48
     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    pwhse

     C                   eval      paisle = 'LIN'
     C     sltky         setll     slot11
     C                   dou       %eof
     C     sltky         reade     slot11
     C                   if        %eof
     C                   leave
     C                   endif
     c                   eval      paisl2 = slaisl
     c                   eval      ploc   = slloc
     c                   eval      prlvl  = slrlvl
     c                   eval      phand  = slhand

     *  Call interface to do update.
     *  Call DRISLOT to zero out LIN slot.

600bAC                   exsr      clr$slot
600bAC                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = pwhse
600bAC                   eval      $slwhdpu = *on
600bAC                   eval      $slwhdp  = slwhdp
600bAC                   eval      $sldispu = *on
600bAC                   eval      $sldisp  = sldisp
600bAC                   eval      $saitemu = *on
600bAC                   eval      $saitem  = slitem
600bA
600bAC                   eval      $saqtyu  = *on
600bAC                   eval      $saqty1  = slstk1 * -1
600bAC                   eval      $saqty2  = slstk2 * -1
600bAC                   eval      $saqty3  = slstk3 * -1
600bA
600bAC                   eval      $sacwtau = *on
700aDC*                  eval      $sacwta  =
700aMC                   eval      $sacwta  = 0
600bAC                   eval      $sacodeu = *on
600bAC                   eval      $sacode  = 'LN'
600bAC                   eval      $samemou = *on
600bAC                   eval      $samemo  = ''
600bAC                   eval      $sabyu   = *on
600bAC                   eval      $saby    = ''
600bA
600bAC                   eval      $saActionU = *on
600bAC                   eval      $saAction = 'ADJ'
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   enddo
     C
     c                   eval      *inLR = *on
600bA*----------------------------------------------------------------
600bA*  clr$slot  Clear $slot data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C*                  eval      $saemp# = #emp#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   eval      $dridata = $slot
600bAC                   eval      $dridata2 = $slot2

416dAC                   select

416dAC                   when      $dricommand = '*SLOT'
416dAC                   call(e)   'DRICOP'
416dAC                   parm                    $dricommand
416dAC                   parm                    $drisubcmd
416dAC                   parm                    $drisys2upd
416dAC                   parm      #prog         $driprogram
416dAC                   parm      ' '           $drireturn
416dAC                   parm      ' '           $drimessage
416dAC                   parm                    $dridata
416dAC                   parm                    $dridata2
416dA
416dAC                   other
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
416dA
416dAC                   endsl

     C                   eval      $slot = $dridata
600bAC                   eval      $slot2 = $dridata2

     C     enddricop     endsr
     *----------------------------------------------------------------
     C     sltky         klist
     C                   kfld                    pwhse
     C                   kfld                    paisle
