      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETPSLT   Get pick slot
     *  30 March 2001
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
415 A*   03/30/01  DAS  4.15
     *     -Created.
415aA*   04/09/01  MLB  4.15a
     *     -Revised program to display the first pick slot for item or
     *      or the last overflow slot if no pick slot found.
     *     -Revised message returned if a slot is found. *OKPICK for
     *      pick slot and *OKOVRF for overflow slot found.
     *
416 A*   01/10/02  MLB  4.16
     *     -Revised program to pass back to the calling program
     *      following fields: SLAISL, SLLOC, SLRLVL, SLHAND.
416aA*   05/15/02  MLB  4.16a
     *     -Revised program to add new cmd *NEXT. This command
     *      will allow the program to retrieve the next pick slot
     *      using the value passed into the program on $PSLOT for
     *      positioning purposes.
416bA*   05/28/02  MLB  4.16b
     *     -Revised program to add new cmd: *FRSTFRS this will allow
     *      the program to retrieve the first pick slot, first over
     *      flow slot.
     *
500 A*   09/11/05  MLB  5.00
     *     -Revised program to add new cmds:
     *      *FRSTOFL to retrieve first overflow slot for item.
     *      *NEXTOFL to retrieve next overflow slot for item.
500aA*   10/13/05  MLB  5.00a
     *     -Enh: Revised program to pass back slot department.
500bA*   10/19/05  MLB  5.00b
     *     -Enh: Revised program to add new cmds: *MORPICK, *MOROVFL
     *      will look for more pick/overflow slots. If more found
     *      will do a read previous to put file pointer back to current
     *      slot.
500cA*   12/23/05  MLB  5.00c
     *     -Fix: Revised program to skip any slot that has an expired
     *      date. Loop for next slot.
     *
610 A*  03/05/10  MLB  6.10   P#00045
     *    - Enh: Added support for License Tracking.
     *    - Revised program to omit slots with SLDESG=BFC when looking
     *      for slots to make inventory adjustments against.
     *
640 A*   03/02/11  MLB  6.40
     *     -Enh: Revised program to check if $pdesg passed into program.
     *      If $pdesg=JIT then look for overflow slots with status XD.
     *
650 A*   01/20/13  MLB  6.50
     *     -Enh: Revised program to check if $pdesg passed into program.
     *      If $pdesg=XDK then look for overflow slots with status XD.
     *      Mod done for HearnKirkwood.
650aA*   04/20/13  MLB  6.50a
     *     -Enh: Revised program to check if $pdesg passed into program.
     *      If $pdesg=ODRRP then look for pick slots with status RP.
     *      Mod done for Greenleaf.
650bA*   08/01/13  KDE  6.50b
     *     -Enh: Convert to ILE
650cA*   02/19/14  KDE  6.50c
     *     -Enh: Ignore trailer aisles
650dA*   03/17/15  MLB  6.50d
     *     -Enh: Revised program to update Slot Status code (KYSTAT) when
     *      $PDESG = FPRSR or FPRFR.
     *     -Mod done for FoodPro to support Chef's Outlet and Fair whse
     *      slots in Dakota Whse 001.
     *
720aA*   12/29/18  MR  7.20a
     *     -Enh: Add command FRSTOFLL, NEXTOFLL and MOROVFLL for
     *           for LIN slot processing.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot3     if   e           k disk
500cA*----------------------------------------------------------------
500cA*
     D @cvtdt          c                   const('CVTDTE')
500cAD $cvtdt          ds
500cAD  $cvcmd                 1      8
500cAD  $cvprg                 9     18
500cAD  $cvd6i                19     24
500cAD  $cvd8i                25     32
500cAD  $cvd6o                33     38  0
500cAD  $cvd8o                39     46  0
500cAD  $cvsto                47     64
500cAD  $cvrtn                65     72
500cAD  $cverm                73    132
500cAD  $cvmsg                73     76
640 A*----------------------------------------------------------------
640 AD                sds
640 AD  #parms                37     39  0

640 A*----- Variables ------------------------------------------------
     D forevr          s              1
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D sltfnd          s              4
     D sltskp          s              7  0
     D svdisp          s                   like(sldisp)
     D today           s              8  0

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $PCMD    -  *FIRST - Get first slot to be picked from
     *                 *LAST  - Get last slot to be picked from
416aA*                 *NEXT    - Get next pick slot in sequence
416bA*                 *FRSTFRS - Get first pick slot, first overflow slot
500 A*                 *FRSTOFL - Get first overflow slot
500 A*                 *NEXTOFL - Get nextt overflow slot
720aA*                 FRSTOFLL- Get first overflow slot for LIN slot
720aA*                 NEXTOFLL - Get next overflow slot for LIN slot
500bA*                 *MORPICK - Look for more pick slots. If more
500bA*                            found, read prior to previous slot.
500bA*                 *MOROVFL - Look for more overflow slots. If more
500bA*                            found, read prior to previous slot.
     *     $PWHSE   -  Warhouse
     *     $PITEM   -  Item
     *
     *  Output parameters
     *
500aA*     $PWHDP   - Slot department
     *     $PSLOT   - Slot
416 A*     $PAISL   - Aisle
416 A*     $PLOC    - Location
416 A*     $PRLVL   - Rack level
416 A*     $PHAND   - Handstack
415aD*     $PRTN    - *OK      -  Slot found
415aM*     $PRTN    - *OKPICK  -  Pick Slot found
415aA*                *OKOVRF  -  Overflow slot found
     *                *NONE    -  No slot found
640 M*     $PDESG   - Item designation. If JIT, look for slots with XD
640 A*                status.
650 A*                If XDK, then look for slots with XD status.
650dA*                If FPRSR, then look for slots with SR status.
650dA*                If FPRFR, then look for slots with FR status.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
500aAC                   parm                    $pwhdp            5
     C                   parm                    $pitem           15
     C                   parm                    $pslot           12
416 AC                   parm                    $paisl            3
416 AC                   parm                    $ploc             3 0
416 AC                   parm                    $prlvl            2 0
416 AC                   parm                    $phand            2
     C                   parm                    $prtn             8
640 AC                   parm                    $pdesg            5
     *----------------------------------------------------------------
     *  Main line
     *
     *    Initialize return parameters.
     *
416aAC                   eval      svdisp = $pslot
     C                   eval      $pslot = '*NONE*'
     C                   eval      $prtn = '*NONE'
500 AC                   eval      sltfnd = '*NO '
650aA*
650aA*     If item is ODR Repack item, look for slots with RP status.
650dAC                   select
650dMC                   when      #parms >= 11  and
650aAC                             $pdesg = 'ODRRP'
650aAC                   eval      kystat = 'RP'
650dA*
650dAC                   when      #parms >= 11  and
650dAC                             %subst($pdesg:1:3) = 'FPR'
650dAC                   eval      kystat = %subst($pdesg:4:2)
650dA*
650dMC                   other
650aA*
640 AC                   eval      kystat = 'A '
720aAC                   if        $pcmd = 'FRSTOFLL'
720aAc                             or $pcmd = 'NEXTOFLL'
720aAc                             or $pcmd = 'MOROVFLL'
720aAc                   eval      kystat='PR'
720aAC                   endif
650dMC                   endsl
     *
     *   Get the picking slot for the item.
     *
500 D*                    MOVE '*NO '    SLTSKP  4
500 AC                   select
500bA*
500bA*   Looking for more pick/overflow slots.
500bAC                   when      $pcmd = '*MORPICK'  or
720aMC                             $pcmd = '*MOROVFL'  or
720aAC                             $pcmd = 'MOROVFLL'
610 AC                   eval      sltskp = *zeros
610 AC                   dow       forevr = forevr
500bAC     keysl3        reade     slot3                                  79
500bAC                   if        *in79
500bAC                   movel     '*NONE*'      $pslot
610 AC                   leave
500bAC                   else
610 A*
610 A*    Skip all internal use slots.
610 AC                   if        sldesg = 'BFC'                                                  t
650cAC                               or slaisl = ' TR'
610 AC                   add       1             sltskp
610 AC                   iter
610 AC                   endif
610 A*
610 A*    No internal use slots found, but at least 1 good slot
610 A*    found, so add 1 to get back to last slot read.
610 AC                   add       1             sltskp
610 A*
500bA*   If more found, reset file pointer back to previous slot.
610 AC                   dow       sltskp >= 1
500bAC     keysl3        readpe    slot3                                  79
610 AC                   eval      sltskp = sltskp - 1
610 AC                   enddo
610 A*
500bAC                   eval      $pslot = sldisp
500bAC                   if        $pcmd = '*MORPICK'
500bAC                   eval      $prtn = '*OKPICK '
500bAC                   else
500bAC                   eval      $prtn = '*OKOVRF '
500bAC                   endif
610 AC                   leave
500bAC                   endif
610 A*
610 AC                   enddo
500bA*
500 AC                   when      $pcmd = '*FIRST  '  or
500 AC                             $pcmd = '*NEXT   '  or
500 AC                             $pcmd = '*LAST   '  or
500 AC                             $pcmd = '*FRSTFRS'
500 A*
415aAC                   eval      kypick = 'Y'
MLB AC                   if        $pcmd <> '*NEXT   '
     C     keysl3        setll     slot3
MLB AC                   endif
     *
     C                   dow       forevr = forevr
     *
     C     keysl3        reade     slot3                                  79
     C                   if        *in79
     C                   leave
     C                   endif
500cA*
500cA*    Skip all slots with expired product.
500cAC                   if        slexpd < today  and
500cAC                             slexpd > 0  and
500cAC                             slstyp = 'P'  or
610 A*
610 A*    Skip all internal use slots.
610 AC                             sldesg = 'BFC'
650cAC                               or slaisl = ' TR'
610 A*
500cAC                   iter
500cAC                   endif
     *
416aAC                   select
416aA*    Looking for pick slot from previous run of program.
416aA*    When we find slot, set flag so that we can get
416aA*    next slot in sequence.
416aAC                   when      $pcmd = '*NEXT   '  and
416aAC                             sltfnd = '*NO '  and
416aAC                             sldisp <> svdisp
MLB D*****                ITER
416aA*
416aAC                   when      $pcmd = '*NEXT   '  and
MLB D*****      SLTFND    ANDEQ'*NO '
416aAC                             sldisp = svdisp
MLB D*****                MOVE '*YES'    SLTFND
416AAC                   iter
416aA*
416aAC                   endsl
416aA*
500aAC                   eval      $pwhdp = slwhdp
     C                   eval      $pslot = sldisp
416 AC                   eval      $paisl = slaisl
416 AC                   eval      $ploc = slloc
416 AC                   eval      $prlvl = slrlvl
416 AC                   eval      $phand = slhand
415aD*                    MOVEL'*OK'     $PRTN     P
415aMC                   eval      $prtn = '*OKPICK '
     *
     C                   if        $pcmd = '*FIRST'  or
416aAC                             $pcmd = '*NEXT   '  or
416bAC                             $pcmd = '*FRSTFRS'
     C                   leave
     C                   endif
     *
     C                   enddo
500 A*
500 AC                   endsl
     *
500 A*
500 AC                   select
500 AC                   when      $pcmd = '*FRSTOFL'  or
720aAC                             $pcmd = 'FRSTOFLL' or
500 AC                             $pcmd = '*NEXTOFL'  or
720aAC                             $pcmd = 'NEXTOFLL' or
500 AC                             $pcmd = '*FRSTFRS'  and
500 AC                             $prtn = '*NONE   '
500 A*
500 D*          $PRTN     IFEQ '*NONE   '
415aA*
415aA*   Get last overflow slot for item.
415aA*
640 A*     If item is JIT cross dock item, look for slots with XD status.
650dAC                   select
650dMC                   when      #parms >= 11  and
640 AC                             $pdesg = 'JIT'  or
650 AC                             #parms >= 11  and
650 AC                             $pdesg = 'XDK'
640 AC                   eval      kystat = 'XD'
650dA*
650dAC                   when      #parms >= 11  and
650dAC                             %subst($pdesg:1:3) = 'FPR'
650dAC                   eval      kystat = %subst($pdesg:4:2)
650dA*
650dMC                   endsl
640 A*
415aAC                   eval      kypick = 'N'
500 AC                   if        $pcmd <> '*NEXTOFL'
     C                             and $pcmd <> 'NEXTOFLL'
415aAC     keysl3        setll     slot3
500 AC                   endif
415aA*
415aAC                   dow       forevr = forevr
415aA*
415aAC     keysl3        reade     slot3                                  79
415aAC                   if        *in79
415aAC                   leave
415aAC                   endif
500cA*
500cA*    Skip all slots with expired product.
500cAC                   if        slexpd < today  and
500cAC                             slexpd > 0  or
610 A*
610 A*    Skip all internal use slots.
610 AC                             sldesg = 'BFC'
650cAC                              or slaisl = ' TR'
610 A*
500cAC                   iter
500cAC                   endif
415aA*
416aAC                   select
416aA*    Looking for overflow slot from previous run of program.
416aA*    When we find slot, set flag so that we can get
416aA*    next slot in sequence.
416aAC                   when      $pcmd = '*NEXT   '  and
416aAC                             sltfnd = '*NO '  and
416aAC                             sldisp <> svdisp
500 D**                   ITER
416aA*
416aAC                   when      $pcmd = '*NEXT   '  and
416aAC                             sltfnd = '*NO '  and
416aAC                             sldisp = svdisp
500 D**                   MOVE '*YES'    SLTFND
416aAC                   iter
416aA*
416aAC                   endsl
416aA*
500aAC                   eval      $pwhdp = slwhdp
415aAC                   eval      $pslot = sldisp
416 AC                   eval      $paisl = slaisl
416 AC                   eval      $ploc = slloc
416 AC                   eval      $prlvl = slrlvl
416 AC                   eval      $phand = slhand
415aMC                   eval      $prtn = '*OKOVRF '
416bA*
416bA*    Overflow slot found - exit loop.
500 D*          $PCMD     IFEQ '*NEXT   '
500 MC                   if        $pcmd = '*NEXTOFL'  or
720aAC                             $pcmd = 'NEXTOFLL'  or
500 AC                             $pcmd = '*FRSTOFL'  or
720aAC                             $pcmd = 'FRSTOFLL'  or
416bAC                             $pcmd = '*FRSTFRS'
416bAC                   leave
416bAC                   endif
415aA*
415aAC                   enddo
500 D*                    ENDIF
     *
500 MC                   endsl
     *
     C                   return
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *off
     *
     *  Define partial key for SLOT3 file.
     *
     C     keysl3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     *
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
500cA*
414iAC                   eval      $cvcmd = '*CURCMD '
500cAC                   call      @cvtdt
500cAC                   parm                    $cvtdt
500cAC                   eval      today = $cvd8o
     *
     C                   endsr
