      /COPY *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  LT110G    Create Priority replenishments for Production Items
     *            Copy of LT110E
     *
     *  Kenneth Elder
     *  09 June 2014
     *
     *  Revisions
     *
     *    06/09/14  KDE  6.50
     *      - Created.
700  *    05/01/16  DLS  7.00
     *      - Changed program type to SQLRPGLE.
     *      - Add: Clear WIP replenishments from PRPLFIL before calling
     *             DRIPRTYRPL when WIP inventory exists.
710 A*    02/09/17  KDE  7.10
     *      - Added field to PLINED.  Recompiled
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fplined    if   e           k disk
     Fpiritem   if   e           k disk
     Fprplfil4  if   e           k disk

     D                 ds
     D  wopqndec               1     15  2
     D  dec                   14     15  0

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#PRTYRPL
      /COPY *libl/qcopysrc,C#ITEM
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
     *  Work Variables
     *----------------------------------------------------------------

     D prqtyn          s             15  2
     D qtyhld          s              5  0
     D pwhse           s              3  0
     D $prplb          s              8
     D $prtn           s              8
     D $pmsg           s             99
     D $pwhdp          s              5
     D $pwhsa          s              3
     D $pslt           s             12
     D $pqty           s              5  0
     D $brkqty         s              5  0
     D chk4err         s               n
     D ck4err          s               n
     D goodrecord      s              1
     D drierr          s               n
     D zmsflag         s               n

     D $parentititem   s                   like($ititem)
     D #parentitwhse   s                   like($itwhse)
     D #parentititem   s                   like($ititem)
     D #parentittype   s                   like($ittype)
     D #parentitdesc   s                   like($itdesc)
     D #parentitpdsc   s                   like($itpdsc)
     D #parentithead   s             70
     D #parentitwhdp   s                   like($itwhdp)
     D #parentitstyp   s                   like($itstyp)
     D #parentitdesg   s                   like($itdesg)
     D #parentitum1    s                   like($itum1)
     D #parentitflg1   s                   like($itflg1)
     D #parentitum2    s                   like($itum2)
     D #parentitumq2   s                   like($itumq2)
     D #parentitflg2   s                   like($itflg2)
     D #parentitum3    s                   like($itum3)
     D #parentitumq3   s                   like($itumq3)
     D #parentitnrpk   s                   like($imnrpk)
     D #parentitflgd   s                   like($itflgd)
     D #parentitcube   s                   like($itcube)
     D #parentitswgt   s                   like($itswgt)
     D #parentitcwgt   s                   like($itcwgt)
     D #parentitmitem  s                   like($itmitem)
     D #parentitsdef   s                   like($idsdef)
     D #parentittie    s                   like($idtie)
     D #parentithigh   s                   like($idhigh)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhsea  -  Warehouse
     *      $pwhdp   -  Department code or *ALL
     *      $prplb   -  Based on value
     *                  *PRDQTY - Production Qty sent PREPLEN file
     *                  *AVGPRD - Average sales (ITEMAVG file)
     *                  *RPLLVL - Item replenishment level.
     *      $pslt    -  Specific slot you want to replenish to
     *      $pqty    -  Quantity you want replenished
     *
     *    Returned Parameters
     *      $prtn    -  Return code (not used)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhsa
     C                   parm                    $pwhdp
     C                   parm                    $prplb
     C                   parm                    $parentititem
     c                   parm                    $pslt
     C                   parm                    $pqty
     c                   parm                    $brkqty
     C                   parm                    $prtn
     C                   parm                    $pmsg

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C                   exsr      zzinz

     C                   exsr      zzgetparentit
     C                   if        goodrecord = *on

      * Create rpl for Production Item Requested
      * Get parent UOM for new repack

     C                   exsr      createrpl

     C                   endif

     c                   if        $prplb <> '*AVFPRD'
     c                             and $prplb <> '*PRDQTY'
     C                   exsr      sortrpl
     c                   endif
     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *            SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

700 A*----------------------------------------------------------------
700 A*  CheckForWip - Clear WIP replenishments from PRPLFIL before
700 A*                calling DRIPRTYRPL when WIP inventory exists.
700 A*----------------------------------------------------------------
      /free
700 A  begsr CheckForWip;

700 A    exec sql
700 A     delete from prplfil
700 A      where prwhse = :$pwhsa
700 A        and prwhdp = :$pwhdp
700 A        and pritem = :$parentititem
700 A        and prtdis = :$pslt
700 A        and prstat = 'PR';

700 A  endsr;
      /end-free
     *----------------------------------------------------------------
     *  createrpl
     *----------------------------------------------------------------

     C     createrpl     begsr

     C                   exsr      clr$prtyrpl

     C                   if        $pqty > *zeros
     c                              or $brkqty > *zeros
     c                              or $prplb = '*AVGPRD'
     c                              or $prplb = '*RPLPRD'
     c                              or $prplb = '*PRDQTY'

     C                   eval      $prwhseu = *on
     C                   eval      $prwhse  = pwhse

     C                   eval      $pritemu = *on
     C                   eval      $pritem  = $parentititem

     c                   if        $pwhdp = ' '
     C                   eval      $prwhdpu = *off
     C                   eval      $prwhdp  = ' '
     c                   else
     C                   eval      $prwhdpu = *on
     C                   eval      $prwhdp  = $pwhdp
     c                   endif

     c                   if        $pslt   <> ' '
     C                   eval      $prslotu = *on
     C                   eval      $prslot = $pslt
     c                   else
     C                   eval      $prslot = ' '
     C                   eval      $prslotu = *off
     c                   endif

     c*  do not send quantity with Average Sales
     c                   if        $prplb <> '*AVGPRD'
     c                              and $prplb <> '*RPLPRD'
     c                              and $prplb <> '*PRDQTY'
     C                   eval      $prqtynu = *on
     C                   eval      $prqtyn = $pqty
     c                   else
     C                   eval      $prqtynu = *off
     C                   eval      $prqtyn = 0
     c                   endif
     c*
     c*  send breakdown qty in prqtyw for production
     c*
     c                   if        $brkqty <> 0
     C                   eval      $prqtywu = *on
     C                   eval      $prqtyw = $brkqty
     c                   else
     C                   eval      $prqtywu = *off
     C                   eval      $prqtyw = 0
     c                   endif

     C                   eval      $dricommand = '*PRTYRPL'
     c                   select
     c                   when      $prplb = '*SINGLE'
     C                   eval      $drisubcmd  = '*CRTPRDRPL'
700 AC                   exsr      CheckForWip
     c                   when      $prplb = '*PRDQTY'
     C                   eval      $drisubcmd  = '*PRDQTY'
     c                   when      $prplb = '*AVGPRD'
     C                   eval      $drisubcmd  = '*AVGPRD'
     c                   when      $prplb = '*RPLPRD'
     C                   eval      $drisubcmd  = '*RPLPRD'
     c                   other
     C                   eval      $drisubcmd  = '*CRTPRDQTY'
     c                   endsl

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop2
     c*  send quantities for repleneishments
     C                   if        error
     c                   eval      $prtn = '*REPLERR'
     c                   eval      $pmsg = $drimessage
     c                   else
     c*  if no error and breakdown was originally sent then zero
     c*  breakdown and generate the case quantity needed
     c                   if        $brkqty <> 0 and $pqty <>0
     C                   eval      $prqtywu = *off
     C                   eval      $prqtyw = 0
     c                   eval      $prqtyn = $pqty
     C                   exsr      zzzdricop2
     C                   if        error
     c                   eval      $prtn = '*REPLERR'
     c                   eval      $pmsg = $drimessage
     C                   endif
     C                   endif
     C                   endif
     C                   endif

     c                   if        $prplb = '*AVGPRD'
     c                              or $prplb = '*PRDQTY'
     c                   eval      $pqty = $prqtyn
     c                   endif

     C                   eval      prqtyn = *zeros

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGETPARENTIT   Get Parent item
     *----------------------------------------------------------------

     C     zzgetparentit begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = pwhse
     C                   eval      $ittypeu = *on
     C                   eval      $ittype  = ' '
     C                   eval      $itwhdpu = *on
     C                   eval      $itwhdp  = $pwhdp
     C                   eval      $ititem  = $parentititem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETPARENT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop2
     c                   eval      goodrecord = *on
     C                   if        drierr
     c                   eval      goodrecord = *off
     C                   eval      error = *on
     C                   eval      $prtn = '*ITMERR '
     c                   eval      $pmsg=$drimessage
     C                   goto      endgetparenti
     C                   endif

     C                   eval      #parentitwhse = $itwhse
     C                   eval      #parentititem = $ititem
     C                   eval      #parentittype = $ittype
     C                   eval      #parentitdesc = $itdesc
     C                   eval      #parentitpdsc = $itpdsc
     C                   eval      #parentitwhdp = $itwhdp
     C                   eval      #parentitstyp = $itstyp
     C                   eval      #parentitdesg = $itdesg
     C                   eval      #parentitum1  = $itum1
     C                   eval      #parentitflg1 = $itflg1
     C                   eval      #parentitum2  = $itum2
     C                   eval      #parentitumq2 = $itumq2
     C                   eval      #parentitflg2 = $itflg2
     C                   eval      #parentitum3  = $itum3
     C                   eval      #parentitumq3 = $itumq3
     C                   eval      #parentitnrpk = $imnrpk
     C                   eval      #parentitflgd = $itflgd
     C                   eval      #parentitcube = $itcube
     C                   eval      #parentitswgt = $itswgt
     C                   eval      #parentitcwgt = $itcwgt
     C                   eval      #parentitmitem = $itmitem
     C                   eval      #parentitsdef = ' '
     C                   eval      #parentittie  = 0
     C                   eval      #parentithigh = 0

     C     endgetparenti endsr

     *----------------------------------------------------------------
     *  sortrpl  Sort (sequence) replenishments
     *----------------------------------------------------------------

     C     sortrpl       begsr

     C                   exsr      clr$prtyrpl
     C                   eval      $prwhseu = *on
     C                   eval      $prwhse  = pwhse

     C                   eval      $dricommand = '*PRTYRPL'
     C                   eval      $drisubcmd  = '*SEQPRTRPL'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop2
     C                   if        error
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$prtyrpl  Clear $prtyrpl data structure fields
     *----------------------------------------------------------------

     C     clr$prtyrpl   begsr
     C                   eval      savever# = $prver#
     C                   clear                   $prtyrpl
     C                   eval      $prver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop2  Call DRICOP2
     *----------------------------------------------------------------

     C     zzzdricop2    begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM   '
     C                   eval      $dridata = $item
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $dridata = $prtyrpl
     C                   endsl

     C                   call(e)   'DRICOP2'
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
     C                   when      $dricommand = '*ITEM   '
     C                   eval      $item    = $dridata
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $prtyrpl = $dridata
     C                   endsl

     C     enddricop     endsr

     *----------------------------------------------------------------
     *  zzinz
     *----------------------------------------------------------------

     C     zzinz         begsr

     C                   move      $pwhsa        pwhse

     * retrieve first repack item

     C                   eval      goodrecord = *off
     c                   eval      qtyhld = $pqty

     C                   endsr
     *----------------------------------------------------------------
     *  *inzsr
     *----------------------------------------------------------------

     C     *inzsr        begsr

     C                   endsr
