      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CRTWRKORD   Create work order
     *  24 February 2007
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    02/24/07  DAS  5.10
     *      - Created
     *
510aA*    03/05/07  DAS  5.10a
     *      - Revised to use DRICOP2 instead of DRICOP.
     *        Re: Caused a recursive error when called from
     *        DRIPRTYRPL.
     *
510bA*    03/06/07  DAS  5.10b
     *      - Revised to pass back work order number.
     *
510cA*    03/22/07  JCJ  5.10c
     *      - Initialize date needed in kitordh to todays date.
     *
510dA*    04/03/07  TJ   5.10d
     *      - Pass in screen entered Date Needed for KITORDH.
     *
530 A*    03/29/10  JCJ  5.30
     *      - Enh: no longer create Parent Repack slots (RPK-501-1).
     *
650aA*    04/03/13  KDE  6.50a
     *      - Enh: Move the call for Work Order Replenishments from
     *        WR112 to the loop for KITCOMP while creating Work Order
     *        This allows us to pass the specific slot that we want
     *        the system to move stock to for the Work Order build
     *
650bA*    06/10/13  KDE  6.50b
     *      - Enh: If on-demand item calls another on-demand item
     *        do not try to create parent slot.  The process will
     *        ensure pick slot exists for parent and breakdown qty
     *        will be taken from that item
710 A*    09/01/17  KDE  7.10
     *      - Enh: Add command *UPDWRKORD to pass through Replenishment
     *        calculations in DRIPRTYRPL to update after delete
740 A*    09/08/20  KDE  7.40
     *      - Enh: Pass in parent item dept when creating RPK slot
750 A*    03/03/21  KDE  7.50
     *      - Enh: Only generate Work Order when parent stock available
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fkitordh   uf a e           k disk
     Fkitcomp   if   e           k disk
650bAFkititem   if   e           k disk
650aAFoptions   if   e           k disk
750 Afslot3     if   e           k disk
750 Afpiritem   if   e           k disk

500dA*----------------------------------------------------------------
500dA*  DRI parameters
500dA*----------------------------------------------------------------
500dA
500dA /COPY *libl/qcopysrc,C#DRIPARMS
500dA
500dA*----------------------------------------------------------------
500dA*  Data Formats
500dA*----------------------------------------------------------------
500dA
500dA /COPY *libl/qcopysrc,C#ITEM
500dA /COPY *libl/qcopysrc,C#SLOT
510aA /COPY *libl/qcopysrc,C#PRTYRPL
500dA
500dAD saveVer#        s                   like($slver#)
500dAD save$slot       s                   like($slot)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76

650aA*----------------------------------------------------------------
650aA*  *REPACK  -  Repack options
650aA*----------------------------------------------------------------
650aA*
650aA* Fields
650aA*
650aA*    OPPADJ  -  Parent adjustment code
650aA*    OPWADJ  -  Parent waste adjustment code
650aA*    OPRADJ  -  Repack adjustment code
650aA*    OPRASL  -  Repack area aisle
750 A*    OPPSAVL -  Only Create Work Orders when parent stock exists
650aA*
650aA * Data structure
650aA*
650aAD opdat1          ds
650aAD  opfeat                 1      1
650aAD  oppadj                 1      2
650aAD  opwadj                 3      4
650aAD  opradj                 5      6
650aAD  oprasl                 7      9
750 AD  oppsavl               11     11
650aAD  optend               117    117
650aA
650aA
650aA*----------------------------------------------------------------
650aA*  *REPLEN  -  Replenishment options.
650aA*----------------------------------------------------------------
650aA*
650aA* Fields
650aA*
650aA*    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY).
650aA*    OPOQRP  -  Order qty replenishment (Y/N).
650aA*
650aA* Data structure
650aA*
650aAD opdat2          ds
650aAD  oprplb                 1      8
650aAD  opoqrp                 9      9
650aAD  opten2               117    117

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $nxtord         s                   like(kohord)
     D chk4err         s               n
500jMD drierr          s               n
     D error           s               n
     D forever         s               n
650bAD onDmdonDmd      s               n
650bAD odrslot         s                   like(kidisp)
650aAD kycode          s                   like(opcode)
750 AD slphy1          s                   like(slstk1)
750 AD slphy2          s                   like(slstk2)
750 AD slphy3          s                   like(slstk3)
750 AD slavl1          s                   like(slstk1)
750 AD slavl2          s                   like(slstk2)
750 AD slavl3          s                   like(slstk3)
750 AD wkQty1          s                   like(kcqty1)
750 AD wkQty2          s                   like(kcqty2)
750 AD wkQty3          s                   like(kcqty3)
750 Ad pQtyExists      s               n
750 AD today           s              8  0
     D curdate         s              8  0
750 AD curtime         s              6  0
750 AD lasttime        s              6  0 inz(999999)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd   *CRTWRKORD  - Create work order
     *              *CRTRPKSLT  - Create Repack slots
     *      $pwhse  Warehouse
     *      $pitem  Repack item
     *      $pqty   Repack quantity needed
     *      $pby    Sent by
     *      $pref   Host reference
     *
     *    Returned Parameters
     *      $prtn   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message
     *      $pmsg   Error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd            10
     C                   parm                    $pwhse            3 0
     C                   parm                    $pitem           15
     C                   parm                    $pqty             5 0
     C                   parm                    $pby              1
     C                   parm                    $pref            15
     C                   parm                    $prtn            10
     C                   parm                    $pmsg            60
510bAC                   parm                    $pord             7 0
510dAC                   parm                    $pndtc            8 0

     C                   eval      $prtn = ' '

710aA /free
710aA       // Set SQL default parms
710aA       exec sql
710aA         set Option Commit=*none, Dlyprp=*Yes,
710aA                    Closqlcsr = *ENDMOD;
710aA /end-free

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Get Repack item information.

     C                   exsr      clr$item
     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = $pitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      $prtn = '*ERROR'
     C                   eval      $pmsg = $drimessage
     C                   goto      bottom
     C                   endif

     *  Execute appropriate routine

     C                   select
     C                   when      $pcmd = '*CRTWRKORD'
     C                   exsr      crtwrkord
     C                   when      $pcmd = '*CRTRPKSLT'
     C                   exsr      crtrpkslt
710 AC                   when      $pcmd = '*UPDWRKORD'
710 AC                   exsr      crtrpkslt
     C                   other
     C                   eval      $prtn = '*ERROR'
     C                   eval      $pmsg = 'Invalid command: ' + $pcmd
     C                   endsl

     C     bottom        tag
     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10

750  c                   eval      today=%dec(%date():*iso)
750 A*
750 A*    Retrieve FS-WMS repack options
750 A*
750 AC                   eval      kycode = '*REPACK '
750 AC     keyop         chain     options                            79
750 AC                   select
750 AC                   when      *in79
750 AC                   eval      oppsavl = 'N'
750 AC                   when      not *in79
750 AC                   eval      opdat1 = opdata
750 AC                   endsl

     * Define key for KITCOMP

     C     keykc         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem

650aA*  Define key for OPTIONS file.
650aA
650aAC     keyop         klist
650aAC                   kfld                    $pwhse
650aAC                   kfld                    kycode

     C                   endsr

     *----------------------------------------------------------------
     *  crtwrkord   Create work order
     *----------------------------------------------------------------

     C     crtwrkord     begsr
     C                   eval      error = *off

750 Ac*  Make sure parents have quantity to produce work order
750 Ac*  if any parents are short of stock it will not produce
750 Ac*  work order if the option is set to prevent creation when
750 Ac*  short.  If that option is turned off it will still produce
750 Ac*  the work order but no replen since stock is short
750 Ac                   exsr      calcPQty
750 Ac                   if        not pQtyExists
750 Ac                   if        oppsavl = 'Y'
750 Ac                   leavesr
750 Ac                   endif
750 Ac                   endif

     *  Get next work order number.

     C                   call      'PIRWRKORD#'
     C                   parm                    $pwhse
     C                   parm                    $nxtord

510bA*  Send back work order number.
510bA
510bAC                   if        %parms >= 9
510bAC                   eval      $pord = $nxtord
510bAC                   endif

     *  Create work order record.

     C                   eval      kohwhs = $pwhse
     C                   eval      kohord = $nxtord
     C                   eval      kohby  = $pby
     C                   eval      kohref = $pref
     C                   eval      kohitm = $pitem
     C                   eval      kohqty = $pqty
     C                   eval      kohsta = '1'

414iAC                   eval      $cvcmd = '*CURCMD '
414iAC                   call      @cvtdt
414iAC                   parm                    $cvtdt
     C                   eval      kohodt = $cvd8o
510cAD***                eval      kohndt = $cvd8o
510cMC                   eval      kohndt = $pndtc
     C                   time                    kohotm

     C                   eval      kohsdt = 0
     C                   eval      kohstm = 0
     C                   eval      kohcdt = 0
     C                   eval      kohctm = 0

     C                   write     kohrec

     *  Make sure Repack slots exist for Parent and Repack items.

     C                   exsr      crtrpkslt

     C                   endsr

     *----------------------------------------------------------------
     *  crtrpkslt   Create repack slots
     *----------------------------------------------------------------

     C     crtrpkslt     begsr

710 Ac*  get passed in order when upd Work ORder Call
710 A /free
710 A        if $pcmd='*UPDWRKORD';
710 A           chain(n) ($pwhse:$pord) kitordh;
710 A        endif;
710 A /end-free

     C                   eval      error = *off

     *  Create slot for Repack item.

530 D ***                exsr      clr$slot
530 D ***                eval      $slwhseu = *on
530 D ***                eval      $slwhse  = $pwhse
530 D ***                eval      $slwhdpu = *on
530 D ***                eval      $slwhdp  = $itwhdp
530 D ***                eval      $slitemu = *on
530 D ***                eval      $slitem  = $pitem
530 D ***                eval      $sldispu = *on
530 D ***                eval      $sldisp  = 'RPK-501-1'

530 D ***                eval      $dricommand = '*SLOT'
530 D ***                eval      $drisubcmd  = '%CRTREPAKR'
530 D ***                eval      $drisys2upd = 'D'
530 D ***                eval      chk4err = *on
530 D ***                exsr      zzzdricop
530 D ***                if        drierr
530 D ***                          and $drireturn <> 'INSLOT'
530 D ***                eval      $prtn = '*ERROR'
530 D ***                eval      $pmsg = 'Repack area slot could not be '
530 D ***                                + 'created for Repack item '
530 D ***                                + $pitem
530 D ***                goto      endcrtrpkslt
530 D ***                endif


     *  Read the Repack Item config from Kititem to determine if ODR

650bAc                   eval      onDmdonDmd = *off
710 DC     keykc         chain     kititem
650bAc                   if        %found(kititem)
650bAc                   eval      odrslot = kidisp
650bAc                   else
650bAc                   eval      odrslot = ' '
650bAc                   endif

     *  loop thru parent items

     C     keykc         setll     kitcomp
     C                   dow       forever = forever
     C     keykc         reade(e)  kitcomp
     C                   if        %eof
     C                   leave
650bAc                   else
650bA /free
650bA    // see if this parent is also an on-demand item
650bA       chain (kcwhse:kccitm) kititem;
650bA       if %found and kirptp='2';
650bA          onDmdonDmd = *on;
650bA       endif;
650bA /end-free
650bAc                   endif

     *    Create slot for Parent item.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $itwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = kccitm
     C                   eval      $sldispu = *on
     C                   eval      $drisubcmd  = '%CRTREPAKP'

740 A /free
740 A     exec sql select itwhdp into :$slwhdp
740 A               from piritem
740 A             where itwhse=:$pWhse and ititem=:kccitm
740 A               fetch first row only;
740 A /end-free

650bA *  if Item is an On-Demand then pass the slot instead of passing
650bA *   a virtual slot
650bAc                   if        kcdisp=' ' and not onDmdonDmd
     C                   eval      $sldisp  = 'RPK-101-1'
650bAc                   else
650bAc                   eval      $sldisp = kcdisp
650bAc                   eval      $drisubcmd  = '%GET'
650bAc                   if        onDmdonDmd
650bAc                   eval      $sldisp = kidisp
650bAc                   eval      $drisubcmd  = '%GETODRRPK'
650bAc                   endif
650bAc                   endif

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   exsr      zzzdricop
     C                   if        drierr
     C                             and $drireturn <> 'INSLOT'
     C                   eval      $prtn = '*ERROR'
     C                   eval      $pmsg = 'Repack area slot could not be '
     C                                   + 'created for Parent item'
     C                                   + $pitem
     C                   goto      endcrtrpkslt
650aAc                   else

650bAC                   if        $drisubcmd  <> '%CRTREPAKP'
650bAC                              and $drisubcmd  <> '*CRTREPAKP'
650bAC*                             and $drisubcmd  <> '*GET'
650bAC*                             and $drisubcmd  <> '%GET'
650bAc                   iter
650fAc                   endif
650aA*
650aA* Create Priority Replenishment to move parent qty to repack area
650aA
650aA*  Loop through each parent item associated to the repack item
650aA
650aAC                   exsr      clr$prtyrpl
650aA*
650aA*    Retrieve FS-WMS replenishment options.
650aA*
650aAC                   eval      kycode = '*REPLEN '
650aAC     keyop         chain     options                            79
650aAC                   select
650aAC                   when      *in79
650aAC                   eval      opoqrp = 'N'
650aAC                   when      not *in79
510aAC                   eval      opdat2 = opdata
510aAC                   endsl
510aA*
510aAC                   move      $pwhse        $twhse            3
650aAc                   eval      $twhdp = $itwhdp
650aAc                   eval      $tpitm = $slitem
650aAC                   call      'LT110E'
650aAC                   parm                    $twhse
650aAC                   parm                    $twhdp            5
650aAC                   parm      oprplb        $tplb             8
650aAC                   parm                    $tpitm           15
650aAc                   parm                    $sldisp
650aAC                   parm                    $trtn             8
650a C                   endif

     C                   enddo

     C     endcrtrpkslt  endsr
500dA*----------------------------------------------------------------
500dA*----------------------------------------------------------------
500dA*                     DRI SUBROUTINES
500dA*----------------------------------------------------------------
500dA*----------------------------------------------------------------

500dA*----------------------------------------------------------------
500dA*  clr$item  Clear $item data structure fields
500dA*----------------------------------------------------------------
500dA
500dAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

650aA*----------------------------------------------------------------
650aA*  clr$prtyrpl  Clear $prtyrpl data structure fields
650aA*----------------------------------------------------------------
650aA
650aAC     clr$prtyrpl   begsr
650aAC                   eval      savever# = $prver#
650aAC                   clear                   $prtyrpl
650aAC                   eval      $prver# = savever#
650aAC                   endsr

500dA*----------------------------------------------------------------
500dA*  clr$slot  Clear $slot data structure fields
500dA*----------------------------------------------------------------
500dA
500dAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr
500dA
500dA*----------------------------------------------------------------
500dA*  zzzdriclose   Close any open files or programs.
500dA*----------------------------------------------------------------
500dA
500dAC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

     C                   endsr
500dA
500dA*----------------------------------------------------------------
500dA*  zzzdricop  Call DRICOP
500dA*----------------------------------------------------------------
500dA
500dAC     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
510aDC**                 call(e)   'DRICOP'
510aMC                   call(e)   'DRICOP2'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
510aDC**                 call(e)   'DRICOP'
510aMC                   call(e)   'DRICOP2'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      drierr = *on
     C                   eval      $drimessage = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      drierr = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      chk4err = *off
     C     enddricop     endsr
750 A*----------------------------------------------------------------
750 A*  calcPQty   Ensure Parent quantity available for Work Order
750 A*----------------------------------------------------------------

750 AC     calcPQty      begsr

750 AC                   eval      pQtyExists = '0'

750 A ** Loop Repack KIT and ensure all parents have availability
      /free
750 A            setll ($pWhse:$pItem) kitcomp;

750 A              dow forever = forever;
750 A                reade ($pWhse:$pItem) kitcomp;
750 A                if not %equal(kitcomp) or %eof(kitcomp);
750 A                  leave;
750 A                endif;

750 A                chain (kcwhse:kccitm) piritem;
750 A                if not %found(piritem);
750 A                   itumq2=0;
750 A                   itumq3=0;
750 A                endif;

     *  Whip through all slots for sepecif parent item from kit.
     *  Set pQtyExists off if any items are short of required stock
                         setll (kcwhse:kccitm) slot3;

750 A                    eval slphy1=0;
750 A                    eval slphy2=0;
750 A                    eval slphy3=0;
750 A                    eval slavl1=0;
750 A                    eval slavl2=0;
750 A                    eval slavl3=0;
      /end-free

750 AC                   dow       forever = forever

      /free
                         reade (kcwhse:kccitm) slot3;
      /end-free

750 AC                   if        %eof
750 AC                   leave
750 AC                   endif

750 Ac                   if        slstat<>'A ' and slstat<>'RP'
750 Ac                   iter
750 Ac                   endif
750 A
750 AC                   if        itflgd = 'Y'  and
750 AC                             slexpd <> *zeros  and
750 AC                             slexpd < today
750 AC                   iter
750 AC                   endif

     *    Calculate available slot qty.

750 AC                   exsr      calcqtys

750 AC                   enddo

750 A *    If available quantity is less than required then set
750 A *    parent required quantity indicator off and exit routine
750 A                    select;
750 A                      // When Breakdown 1 and 2 exists
750 A                      when itumq3 > 0;
750 A                        wkQty3 = ((kcqty1*itumq2*itumq3) + (kcqty2*itumq3)
750 A                                 + kcqty3);
750 A                        if ((slavl1*itumq2*itumq3) + (slavl2*itumq3)
750 A                           + slavl3) >= wkqty3 and wkQty3<>0;
750 A                          pQtyExists = '1';
750 A                        else;
750 A                          pQtyExists = '0';
750 A                          leavesr;
750 A                        endif;
750 A                      when itumq2 > 0;
750 A                        wkQty2 = ((kcqty1*itumq2) + kcqty2);
750 A                        if ((slavl1*itumq2) + slavl2) >= wkQty2
750 A                           and wkQty2<>0;
750 A                          pQtyExists = '1';
750 A                        else;
750 A                          pQtyExists = '0';
750 A                          leavesr;
750 A                        endif;
750 A                      other;
750 A                        wkQty1 = kcqty1;
750 A                        if slavl1 >= wkQty1 and wkQty1<>0;
750 A                          pQtyExists = '1';
750 A                        else;
750 A                          pQtyExists = '0';
750 A                          leavesr;
750 A                        endif;
750 A                    endsl;
750 A
750 Ac                   enddo

750 Ac                   endsr
750 A*----------------------------------------------------------------
750 A*  calcqtys  Calculate slot quantities.
750 A*
750 A*     *** This routine should be identical to the one ***
750 A*     *** in program DRISLOT.                         ***
750 A*
750 A*----------------------------------------------------------------

750 AC     calcqtys      begsr

     *  Calculate physical quantity in slot.

     *    Note: The quantities that are used to calculate the physical
     *          slot quantity are part of processes which should be
     *          completed soon. We can not wait until the processes
     *          are closed to say the stock is or isn't there.

     *          For example: A replenishment request can not be refused
     *          because the picks that depleted the slot have not been
     *          closed yet. Timing is everything.

     C                   eval      slphy1 = slphy1 +
     C                                      (slstk1+slrcv1)-(sltfr1+slpck1)
     C                   eval      slphy2 = slphy2 +
     C                                      (slstk2+slrcv2)-(sltfr2+slpck2)
     C                   eval      slphy3 = slphy3 +
     C                                      (slstk3+slrcv3)-(sltfr3+slpck3)

     *  Calculate available quantity in slot.

     C                   eval      slavl1 = slavl1 +
     C                                      (slphy1 - slalc1)
     C                   eval      slavl2 = slavl2 +
     C                                      (slphy2 - slalc2)
     C                   eval      slavl3 = slavl3 +
     C                                      (slphy3 - slalc3)

750 AC                   endsr
750 A*----------------------------------------------------------------
750 A*  getdatetime  Get current date & time
750 A*----------------------------------------------------------------

750 AC     getdatetime   begsr

     C                   time                    curtime

     C                   if        curtime < lasttime
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

750 AC                   endsr

