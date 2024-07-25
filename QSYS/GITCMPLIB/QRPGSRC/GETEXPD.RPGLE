     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  GETEXPD   Get expiration date range of slots for item.
     *  24 September 2001
     *  Dave Sommerville
     *
     *  Revisions
     *
416 A*   09/24/01  DAS  4.16
     *     -Created.
     *
520 A*    01/23/08  JCJ  5.20
     *      - Enh: Revised program to add support for Client id
     *      - Converted source to RPGIV.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Royal
     *
RYL A*    01/23/08  JCJ  RYL
     *      - Revise program to include Pick Slots.
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot3     if   e           k disk
520 A*----------------------------------------------------------------
520 A*  Customer id
520 A*
520 AD @getcl          c                   const('GETCLIENT')
520 A*
520 A /copy qcopysrc,id#royal
     *----------------------------------------------------------------
     * Work Fields
     *----------------------------------------------------------------
     D forevr          s              1
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $PWHSE   -  Warhouse
     *     $PITEM   -  Item
     *
     *  Output parameters
     *
     *     $PFROM   - From date (earliest date)
     *     $PTO     - To date (latest date)
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pitem           15
     C                   parm                    $pfrom            8 0
     C                   parm                    $pto              8 0
     *----------------------------------------------------------------
     *  Main line
     *
     *   Initialize return parameters.
     *
     C                   eval      $pfrom = 0
     C                   eval      $pto = 0
     *
     *   Loop through active overflow slots for item.
     *
ryl AC                   select
ryl AC                   when      client = royal
ryl AC     keysl4        setll     slot3
ryl AC                   other
     C     keysl3        setll     slot3
ryl AC                   endsl
     *
     C                   dow       forevr = forevr
     *
ryl AC                   select
ryl AC                   when      client = royal
ryl AC     keysl4        reade     slot3                                  79
ryl AC                   other
     C     keysl3        reade     slot3                                  79
ryl AC                   endsl
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   if        $pfrom = 0  or
     C                             slexpd < $pfrom
     C                   eval      $pfrom = slexpd
     C                   endif
     *
     C                   if        $pto = 0  or
     C                             slexpd > $pto
     C                   eval      $pto = slexpd
     C                   endif
     *
     C                   enddo
     *
     C                   return
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *off
520 A*
520 A* Get client id.
520 A*
520 AC                   call      @getcl
520 AC                   parm                    client           10
     *
     *  Define partial key for SLOT3 file.
     *
     C     keysl3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     C                   kfld                    kystat
     C                   kfld                    kypick
ryl A*
ryl AC     keysl4        klist
ryl AC                   kfld                    $pwhse
ryl AC                   kfld                    $pitem
ryl AC                   kfld                    kystat
     *
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'N'
     *
     C                   endsr
