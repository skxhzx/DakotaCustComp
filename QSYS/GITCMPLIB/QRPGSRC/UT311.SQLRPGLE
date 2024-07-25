610aA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  UT310     Move vslot item and qty to empty base slot.
     *  07 July 2000
     *  Roxanne Harrison
     *
     *  05/13/02  HNK 4.16
     *    - FIX - Update SLEXPD,SLENTD,SLSDTE and SLSLFD
     *  11/05/03  RH  4.17a
     *    - FIX:  Skip if Virtual slot has pending quantity.
     *  12/14/07  RH  5.10a
     *    - ENH:  Revised to move 1st virtual to empty base, was not
     *            moving if multiple virutals existed for empty base.
     *
610aA*  07/26/09  DAS  6.10a
     *    - Converted to ILE.
     *    - Replaced updates to slot file with calls to DRISLOT.
700aA*  11/11/15  RH   7.00a
     *    - Enh: Revised program to add support for new Client id
     *        modifications.
     *    - Enh: Added select for client EI to temp custom code.
700bA*  08/18/16  TAB  7.00b
     *    - Enh: Added SQL statement to check SLOT file for status
     *          'PR' and code 'V' and skip over deletion if found.
     *
720a *  06/19/18  RTR  7.20a
     *    - Fix: On OSS slots, DRISLOT transfer fails leaving item in
     *           USR slot. Changed to skip OSS slots.
730a *  08/08/19  RH   7.30a
     *    - ENH: Skip slots with BFC designation code.
730bA*    09/17/19  NLK/DAM  7.30b (DAMCO-Sachin)
     *      - Fix: Changed program to save slot status, so that all
     *        new base slots retain the same status as the virtual
     *        slots.
780a *  02/13/24  RH   7.80a
     *    - Fix: Dont Move Virtual slot to Base slot if status <>'V'
     *           Drislot creates virtual if slot status is <> 'V'
     *           Added call to Autoverify slots before process.
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
     *
EI  A*  04/02/14  MLB  EI  *Temporary* *Do Not Promote*
     *    - Revised pgm to only process slots where base_slaisl = Nxx
     *      where xx= 01 - 99. IT352 Full Screen slot transfers was
     *      creating virtual slots when the base slot is I=Inactive.
     *----------------------------------------------------------------
     *  Client Custom Revisions: H&M Wagner
     *
HMWaA*  11/11/15  RH  HMWa
     *    - Change to allow pick slots to be processed.
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot1     ip   e           k disk
610aAF                                     prefix(base_)
610aDF*lot2     uf   e           k disk
610aMFslot2     if   e           k disk
     F                                     rename(slrec:record)
610aAF                                     prefix(virt_)
610aDF*slot2    uf   e           k disk
610aMFvslot2    if   e           k disk
700aA*----------------------------------------------------------------
700aA*  Customer id
700aA*
EIa A /COPY QCOPYSRC,ID#EI
HMWaA /COPY QCOPYSRC,ID#hmwagne
610aA*----------------------------------------------------------------
610aA*  DRI parameters
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,C#DRIPARMS
610aA
610aA*----------------------------------------------------------------
610aA*  Data Formats
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,C#SLOT
610aAD saveVer#        s                   like($slver#)
     *----------------------------------------------------------------
     *  Variables
     *
610aAD chk4err         s               n
     D forevr          s              1
610aAD error           s               n
610aDD*svdisp          s                   like(sldisp)
610aDD*sventd          s                   like(slentd)
610aDD*svexpd          s                   like(slexpd)
610aDD*svitem          s                   like(slitem)
610aDD*svpdis          s                   like(sldisp)
610aDD*svsdte          s                   like(slsdte)
610aDD*svslfd          s                   like(slslfd)
610aDD*svstat          s                   like(slstat)
610aDD*svstk1          s                   like(slstk1)
610aDD*svstk2          s                   like(slstk2)
610aDD*svstk3          s                   like(slstk3)
     D usrdisp         s                   like(base_sldisp)
     D vcount          s              2  0
610aAD zmsflag         s               n
610aAD zmflag          s               n
700bA*----------------------------------------------------------------
700bAD$dsSLOT        E DS                  Extname(SLOT)
610aA*----------------------------------------------------------------
610aA*  Program info data structure
610aA*
610aA /Copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     *----------------------------------------------------------------
     *  Main line
     *
     *  Skip if not correct warehouse.
     *
610aMC                   if        base_slwhse <> $pwhse
     C                   goto      bottom
     C                   endif
EI  A*
EI  A*  Skip if not new whse slots.
EI  AC                   select
EI  AC                   when      client = ei
EI  AC                   if        %subst(base_slaisl:1:1) <> 'N'
EI  AC                   goto      bottom
EI  AC                   endif
700aAC                   endsl
     *
     *  Skip virtual slots
     *
610aMC                   if        base_slrsrv = 'V'
     C                   goto      bottom
     C                   endif
720aA*
720aA*  Skip OSS slots
720aA*
720aAc                   if        base_slaisl = 'OSS'
720aAc                             or virt_slaisl = 'OSS'
720aAc                   goto      bottom
720aAc                   endif
     *
730aA*
730aA*  Skip BFC slots
730aA*
730aAc                   if        base_sldesg = 'BFC'
730aAc                   goto      bottom
730aAc                   endif
     *
     *  Skip if pick slot
     *
     **         SLRSRV    IFEQ 'Y'
610aMC                   if        base_slpick = 'Y' and
700aAC                             client <> hmwagner
     C                   goto      bottom
     C                   endif
     *
     *  Skip if base is not status of Z or V.
     *
700aAC                   select
700aMC                   When      client = ei
780aDC*                  if        base_slstat <> 'Z'  and
780aDC*                            base_slstat <> 'V'
780aMC                   if        base_slstat <> 'V'
EI  AC                             and base_slstat <> 'I'
     C                   goto      bottom
     C                   endif
700aAC                   other
780aDC*                  if        base_slstat <> 'Z'  and
780aDC*                            base_slstat <> 'V'
780aMC                   if        base_slstat <> 'V'
700aAC                   goto      bottom
700aAC                   endif
700aAC                   endsl
     *
     *  Skip if quantity is allocated
     *
610aMC                   if        base_slalc1 <> 0  or
610aMC                             base_slalc2 <> 0  or
610aMC                             base_slalc3 <> 0
     C                   goto      bottom
     C                   endif
     *
     *  Skip if quantity in transfer.
610aMC                   if        base_sltfr1 <> 0  or
610aMC                             base_sltfr2 <> 0  or
610aMC                             base_sltfr3 <> 0
     C                   goto      bottom
     C                   endif
     *
     *  Skip if quantity in picking.
610aMC                   if        base_slpck1 <> 0  or
610aMC                             base_slpck2 <> 0  or
610aMC                             base_slpck3 <> 0
     C                   goto      bottom
     C                   endif
     *
     *  Skip if quantity in receiving.
610aMC                   if        base_slrcv1 <> 0  or
610aMC                             base_slrcv2 <> 0  or
610aMC                             base_slrcv3 <> 0
     C                   goto      bottom
     C                   endif
     *
     *  Count virtual slots for base.
     *
     C                   eval      vcount = 0
     C     keyv2         setll     vslot2
     C                   dou       forevr <> forevr
     C     keyv2         reade(n)  vslot2                                 79
     C                   if        *in79
     C                   leave
     C                   endif
700bA /Free
 |      //------------- Declare and Open SQL file  ----------------------
  |                 EXEC SQL Declare SlotR Cursor for
  |                          Select * from SLOT
  |                          Where SLWHSE = :VSWHSE and
  |                                SLDISP = :VSDISP;
  |
  |                 EXEC SQL Open SlotR;
 |      //------------- Start fetching records for printing  ------------
  |                 EXEC SQL Fetch SlotR into :$dsSLOT;
  |
  |                    Select;
  |                       When SQLCOD = 0;
  |                          If (SLSTAT = 'PR' and SLRSRV ='V');
  |                          Else;
  |                             Vcount = (Vcount +1);
  |                          EndIf;
  |                    Other;
  |                    EndSL;
  |                 EXEC SQL Close SlotR;
700bA /End-Free
 |      //------------- End Of new code 700b ----------------------------
700bDC**                 add       1             vcount
610aDC**                 if        vcount = 1
510a C                   leave
610aDC**                 endif
610aDC**                 iter
     C                   enddo
     *
     *  If only one vslot, get virtual slot item & quantity.
     *
610aAC                   if        vcount = 0
610aAC                   goto      bottom
610aAC                   endif
610aDC**                 if        vcount = 1
610aDC**                 eval      svpdis = vspdis
610aDC**                 eval      svdisp = vsdisp
     C     keysv         chain     slot2                              79
     C     *in79         cabeq     *on           bottom
417a *  Skip if virtual slot has pending quantities.
417a *  Skip if quantity is allocated
417a *
610aMC                   if        virt_slalc1 <> 0  or
610aMC                             virt_slalc2 <> 0  or
610aMC                             virt_slalc3 <> 0
417a C                   goto      bottom
417a C                   endif
417a *
417a *  Skip if quantity in transfer.
610aMC                   if        virt_sltfr1 <> 0  or
610aMC                             virt_sltfr2 <> 0  or
610aMC                             virt_sltfr3 <> 0
417a C                   goto      bottom
417a C                   endif
417a *
417a *  Skip if quantity in picking.
610aMC                   if        virt_slpck1 <> 0  or
610aMC                             virt_slpck2 <> 0  or
610aMC                             virt_slpck3 <> 0
417a C                   goto      bottom
417a C                   endif
417a *
417a *  Skip if quantity in receiving.
610aMC                   if        virt_slrcv1 <> 0  or
610aMC                             virt_slrcv2 <> 0  or
610aMC                             virt_slrcv3 <> 0
417a C                   goto      bottom
417a C                   endif
     *
610aDC**                 eval      svitem = slitem
610aDC**                 eval      svstk1 = slstk1
610aDC**                 eval      svstk2 = slstk2
610aDC**                 eval      svstk3 = slstk3
610aDC**                 eval      svstat = slstat
610aDC**                 eval      sventd = slentd
610aDC**                 eval      svexpd = slexpd
610aDC**                 eval      svslfd = slslfd
610aDC**                 eval      svsdte = slsdte
610aDC**                 delete    record
610aDC**
610aDC** Update base slot with virtual slot item & quantity.
610aDC**   keysp         chain     slot2                              79
610aDC**   *in79         cabeq     *on           bottom
610aDC**                 eval      slitem = svitem
610aDC**                 eval      slstk1 = svstk1
610aDC**                 eval      slstk2 = svstk2
610aDC**                 eval      slstk3 = svstk3
610aDC**                 eval      slstat = svstat
610aDC**                 eval      slentd = sventd
610aDC**                 eval      slexpd = svexpd
610aDC**                 eval      slslfd = svslfd
610aDC**                 eval      slsdte = svsdte
610aDC**                 update    record
610aDC**
610aDC**   keyv3         chain     vslot2                             79
610aDC**                 if        not *in79
610aDC**                 delete    vsrec
610aDC**                 endif
610aDC**                 endif

610aA*  Transfer from virtual into USR slot
610aA
610aAC                   exsr      virt2usr
610aA
610aA*  Transfer from USR slot into base slot
610aA
610aAC                   if        not error
610aAC                   exsr      usr2base
610aAC                   endif
     *
     C     bottom        tag
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
700aA*
700aA* Get client id.
700aA*
700aAC     *dtaara       define    pirclient     client           10
700aAC                   in        client
     C                   eval      forevr = *on
     *
     *  Define partial key for VSLOT2
     *
     C     keyv2         klist
610aMC                   kfld                    base_slwhse
610aMC                   kfld                    base_slwhdp
610aMC                   kfld                    base_sldisp
610aDC**
610aDC** Define partial key for VSLOT2
610aDC**
610aDC**   keyv3         klist
610aDC**                 kfld                    slwhse
610aDC**                 kfld                    slwhdp
610aDC**                 kfld                    svpdis
610aDC**                 kfld                    svdisp
     *
     *  Define key for SLOT2
     *
     C     keysv         klist
     C                   kfld                    vswhse
     C                   kfld                    vswhdp
     C                   kfld                    vsdisp
610aDC**
610aDC** Define key for SLOT2
610aDC**
610aDC**   keysp         klist
610aDC**                 kfld                    vswhse
610aDC**                 kfld                    vswhdp
610aDC**                 kfld                    vspdis
610aA *
610aA * Get employee options.
610aA *
610aAC                   call      'GETUSER'
610aMC                   parm      #curruser     e$code           10
610aAC                   parm                    e$whse            3 0
610aAC                   parm                    e$emp#            5 0
610aAC                   parm                    e$fnam           15
610aAC                   parm                    e$init            1
610aAC                   parm                    e$lnam           20
610aAC                   parm                    e$whdp            5
610aAC                   parm                    e$styp            1
610aAC                   parm                    e$shft            6
610aAC                   parm                    e$crew            6
610aAC                   parm                    e$nhrs            3 1
610aAC                   parm                    e$rtn             8
610aAC                   parm                    e$bpu             1
610aAC                   parm                    e$lng             2
780aA *
780aA * Call Auto Zero Verify
780aA *
780aAC                   move      $pwhse        $vwhse            3
780aAC                   CALL      'AUTOVFYCL'
780aAC                   parm                    $vwhse
     *
     C                   endsr

610aA*----------------------------------------------------------------
610aA*  Transfer from USR to base slot
610aA*----------------------------------------------------------------
610aA
610aAC     usr2base      begsr

     *   Call DRI interface to do update.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = base_slwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = base_slwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = base_sldisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = virt_slitem
730bAC                   eval      $slstatu = *on
730bAC                   eval      $slstat  = virt_slstat

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = virt_slstk1
     C                   eval      $saqty2 = virt_slstk2
     C                   eval      $saqty3 = virt_slstk3

     C                   eval      $sacwhdu = *on
     C                   eval      $sacwhd  = virt_slwhdp
     C                   eval      $sacdspu = *on
     C                   eval      $sacdsp  = usrdisp

     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = '*MULTIPLE'

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'TFR'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'S'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = 'Slot'

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%USR2PUT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif
     C                   endsr

610aA*----------------------------------------------------------------
610aA*  Transfer from virtual to USR slot
610aA*----------------------------------------------------------------
610aA
610aAC     virt2usr      begsr

     *    Transfer license to USR slot.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = virt_slwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = virt_slwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = virt_sldisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = virt_slitem
730bAC                   eval      $slstatu = *on
730bAC                   eval      $slstat  = virt_slstat

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = virt_slstk1
     C                   eval      $saqty2 = virt_slstk2
     C                   eval      $saqty3 = virt_slstk3

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'TFR'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'U'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = 'User'

     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = '*MULTIPLE'

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%TFR2USR'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif
     C                   eval      usrdisp = $sldisp
     C                   endsr

610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------
610aA*                     DRI SUBROUTINES
610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------

610aA*----------------------------------------------------------------
610aA*  clr$slot  Clear $slot data structure fields
610aA*----------------------------------------------------------------
610aA
610aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#
     C                   endsr
    A
610aA*----------------------------------------------------------------
610aA*  zzzdricop  Call DRICOP
610aA*----------------------------------------------------------------
610aA
610aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
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
     C                   eval      error = *on
     C*                  eval      errmsg    = 'Error occured on call to '
     C*                                      + 'DRICOP'
     C*                                      + '/' + %trim($drisubcmd)
     C*                                      + ' from ' + #prog
     C                   select
     C                   when      zmsflag
     C**                 exsr      zm0105s
     C                   when      zmflag
     C**                 exsr      zm0105
     C                   endsl

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C**                 exsr      zm0001s
     C                   when      zmflag
     C**                 exsr      zm0001
     C**                 exsr      zzerrind
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
