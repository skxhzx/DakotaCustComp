      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LT110F    Create Priority replenishments - Select and sort.
     *  Jeffrey Jahnke
     *  11 May 2007
     *
     *  Revisions
     *
500 A*    05/11/07  JCJ  5.10
     *      - Copy of LT110A.
700 A*    04/22/15  KDE  7.00
     *      - Few changes to work correctly for Average Sales Replen
750 A*    02/26/21  KDE  7.50
     *      - Correct not producing Work Order when pick slot exists
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpiritem2  if   e           k disk
     Fslot3     if   e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#PRTYRPL
     D savever#        s                   like($prver#)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#PGMINFDS

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#STDVAR

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhsea  -  Warehouse
     *      $pwhdp   -  Department code or *ALL
     *      $prplb   -  Based on value
     *                  *ORDQTY - Ordered quantity (ITEMORD file)
     *                  *AVGQTY - Average sales (ITEMAVG file)
     *                  *AVGnnn - *AVGQTY plus nnn percent.
     *                  *RPLLVL - Item replenishment level.
     *
     *    Returned Parameters
     *      $prtn    -  Return code (not used)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhsa            3
     C                   parm                    $pwhdp            5
     C                   parm                    $prplb            8
     C                   parm                    $prtn             8
700 A
700 AC     itemky        klist
700 AC                   kfld                    pwhse             3 0
700 AC                   kfld                    ptype             1

     C     slotky        klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
     C                   kfld                    status            2
     C                   kfld                    pickflag          1

700 A /free
700 A        pwhse=0;
700 A        Monitor;
700 A          pwhse = %dec($pwhsa:3:0);
700 A        on-error 105;
700 A        Endmon;
700 A /end-free
700 AC                   eval      ptype = 'R'
     C                   eval      status = 'A '
     C                   eval      pickflag = 'Y'

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     c     itemky        setll     piritem2
     C                   dou       %eof(piritem2)
700 DC*                  read      piritem
700 AC     itemky        reade     piritem2
     C                   if        not %eof(piritem2)

750 MC*    slotky        chain     slot3
750 MC*                  if        not %found(slot3)

     C                   exsr      clr$prtyrpl

     C                   eval      $prwhseu = *on
     C                   eval      $prwhse  = itwhse

     C                   eval      $pritemu = *on
     C                   eval      $pritem  = ititem

     C                   eval      $prwhdpu = *on
     C                   eval      $prwhdp  = itwhdp

     C                   eval      $prslotu = *off
     C                   eval      $prslot  = *blanks

     C                   eval      $prqtynu = *on
417b C                   eval      $prqtyn  = 1

     *   Note, DRIPRTYRPL will determine if slot is filled to needed qty.

     C                   eval      $prfillu = *on
     C                   eval      $prfill  = 'Y'

     C                   eval      $dricommand = '*PRTYRPL'
     C                   eval      $drisubcmd  = $prplb

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

750 MC*                  endif
     C                   endif
     C                   enddo

     *  LR stuff - Finish by sorting the created replenishments.

     C                   exsr      sortrpl
     C                   return

417aA*----------------------------------------------------------------
417aA*----------------------------------------------------------------
417aA*            SUBROUTINES IN ALPHABETICAL ORDER
417aA*----------------------------------------------------------------
417aA*----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sortrpl  Sort (sequence) replenishments
     *----------------------------------------------------------------

     C     sortrpl       begsr

     C                   exsr      clr$prtyrpl
     C                   eval      $prwhseu = *on
     C                   eval      $prwhse  = itwhse

     C                   eval      $dricommand = '*PRTYRPL'
     C                   eval      $drisubcmd  = '*SEQPRTRPL'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   endsr

417aA*----------------------------------------------------------------
417aA*----------------------------------------------------------------
417aA*                     DRI SUBROUTINES
417aA*----------------------------------------------------------------
417aA*----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$prtyrpl  Clear $prtyrpl data structure fields
     *----------------------------------------------------------------

     C     clr$prtyrpl   begsr
     C                   eval      savever# = $prver#
     C                   clear                   $prtyrpl
     C                   eval      $prver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $dridata = $prtyrpl
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $prtyrpl = $dridata
     C                   endsl

     C     enddricop     endsr
