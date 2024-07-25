      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FIXSLTDTE   Fix SLOTDTE file.
     *  05 June 2006
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    06/05/06  DAS  5.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fslot1     ip   e           k disk
     Fslotdte   if   e           k disk

500 A*----------------------------------------------------------------
500 A*  DRI parameters
500 A*----------------------------------------------------------------
500 A /COPY *libl/qcopysrc,C#DRIPARMS

500 A*----------------------------------------------------------------
500 A*  Data Formats
500 A*----------------------------------------------------------------
500 A /COPY *libl/qcopysrc,C#ITEM
500 AD savever#        s                   like($itver#)
500 AD ck4err          s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

500 AD error           s               n
     d forever         s               n   inz(*on)
     d difqty1         s                   like($pqty1)
     d difqty2         s                   like($pqty2)
     d difqty3         s                   like($pqty3)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Calculate difference between slot and slot date quantities.

     C                   eval      difQty1 = slstk1
     C                   eval      difQty2 = slstk2
     C                   eval      difQty3 = slstk3

     C                   exsr      getDateTotal
500 A
500 A*  Use DRI interface to get item.
500 A
500 AC                   exsr      clr$item
500 AC                   eval      $itwhse  = slwhse
500 AC                   eval      $ititem  = slitem
500 A
500 AC                   eval      $dricommand = '*ITEM'
500 AC                   eval      $drisubcmd  = '%GETMAIN'
500 AC                   eval      $drisys2upd = 'D'
500 AC                   eval      ck4err = *on
500 AC                   exsr      zzzdricop

     C                   if        error
     C                   eval      $itflgd = 'N'
     C                   endif

     *  Call program to update slot date quantity.

     C                   call      'UPDSLTDTE'
     C                   parm      '*FIX'        $pcmd             8
     C                   parm      #prog         $ppgm            10
     C                   parm      ' '           $ppgm2           10
     C                   parm      slwhse        $pwhse            3 0
     C                   parm      slwhdp        $pwhdp            5
     C                   parm      sldisp        $pslot           12
     C                   parm      slpick        $ppick            1
     C                   parm      slitem        $pitem           15
     C                   parm      ' '           $pnewi           15
     C                   parm      slentd        $pentd            8 0
     C                   parm      slexpd        $pexpd            8 0
     C                   parm      difqty1       $pqty1            5 0
     C                   parm      difqty2       $pqty2            5 0
     C                   parm      difqty3       $pqty3            5 0
     C                   parm      ' '           $prtn             8

     C     bottom        tag

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   eval      forever = *on

     *  Define partial key for SLOTDTE file.

     C     sdtkey        klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
     C                   kfld                    slitem

     C                   endsr

     *----------------------------------------------------------------
     *  getDateTotal   Get total qty from SLOTDTE.
     *----------------------------------------------------------------

     C     getDateTotal  begsr

     *  Loop through records for slot.

     C     sdtkey        setll     slotdte
     C                   dow       forever = forever
     C     sdtkey        reade     slotdte

     C                   if        %eof
     C                   leave
     C                   endif

     C                   eval      difQty1 = difQty1 - sdtqt1
     C                   eval      difQty2 = difQty2 - sdtqt2
     C                   eval      difQty3 = difQty3 - sdtqt3

     C                   enddo

     C                   endsr

500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------
500 A*                     DRI SUBROUTINES
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  clr$item  Clear $item data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

500 A*----------------------------------------------------------------
500 A*  zzzdricop  Call DRICOP
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error and ck4err = *on
     C                   eval      error = *on

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      ck4err = *off
     C     enddricop     endsr
