      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  GETPSLT   Get pick slot
     *  30 March 2001
     *  Dave Sommerville
     *
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
500 A*   05/24/06  DAS  5.00
     *     - Converted to ILE
     *     - Added parameter $ppseq.
     *
600aA*   06/27/09  DAS  6.00a
     *     - Revise to ignore special license tracking slots.
640aA*   07/30/12  RH   6.40a
     *     - Enh: Add client code
     *
700aA*    06/08/16  LMC     7.00a
     *      - ENH: Added New command to find *each pick slots
     *
700bA*    06/28/16  LMC     7.00b
     *      - Fix: Ignore Each Pick slots unless we are looking
     *        for a *EACH pick slot.
     *
720 A*    03/26/18  KDE     7.20
     *      - Enh: When *NEXT is sent it will automatically roll
     *        back to beginning slot when end of file reached
     *
     *   West Side Food Custom
WST A*   12/06/01  DAS  WST
     *     - Changed to return blanks instead of *NONE* when pick
     *       slot is not found.
720aA*   10/12/18  DAS  720a
     *     - Added command *FRSTPCK to get the first Pick slot
     *       because *FIRST will get an Overflow slot if a
     *       Pick slot didn't exist.
750aA*   12/21/21  RH   750a
     *     - Change to read and process Repack RP status pick slots
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslot3     if   e           k disk
700aAFslotdef   if   e           k disk
     *----------------------------------------------------------------
     *  Variables
     *
     D forevr          s              1
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D sltfnd          s              4
     D svdisp          s                   like(sldisp)

640aA*------------------------------------------------------------------
640aA*  Client id's for custom mods.
640aA*------------------------------------------------------------------
640aA /copy qcopysrc,id#westsid
640aAD client          s             10
640aAD clientloc       s             10

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $PCMD    -  *FIRST - Get first slot to be picked from
     *                 *LAST  - Get last slot to be picked from
416aA*                 *NEXT    - Get next pick slot in sequence
416bA*                 *FRSTFRS - Get first pick slot, first overflow slot
720aA*                 *FRSTPCK - Get first Pick slot
     *     $PWHSE   -  Warhouse
     *     $PITEM   -  Item
     *
     *  Output parameters
     *
     *     $PSLOT   - Slot
416 A*     $PAISL   - Aisle
416 A*     $PLOC    - Location
416 A*     $PRLVL   - Rack level
416 A*     $PHAND   - Handstack
415aD*     $PRTN    - *OK      -  Slot found
415aM*     $PRTN    - *OKPICK  -  Pick Slot found
415aA*                *OKOVRF  -  Overflow slot found
     *                *NONE    -  No slot found
500 A*     $PPSEQ   - Picking sequence
500 A*                Note, this has to come at the end of the parm list
500 A*                so that we can determine if it was sent or not.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $pitem           15
     C                   parm                    $pslot           12
416 AC                   parm                    $paisl            3
416 AC                   parm                    $ploc             3 0
416 AC                   parm                    $prlvl            2 0
416 AC                   parm                    $phand            2
     C                   parm                    $prtn             8
500 AC                   parm                    $ppseq            5 0
     *----------------------------------------------------------------
     *  Main line
     *
     *    Initialize return parameters.
     *
416aAC                   eval      svdisp = $pslot
     C                   eval      $pslot = '*NONE*'
WST AC                   if        client = westside
WST AC                   eval      $pslot = *blanks
WST AC                   endif
     C                   eval      $prtn = '*NONE'
     *
     *   Get the picking slot for the item.
     *
416aAC                   eval      sltfnd = '*NO '
415aAC                   eval      kypick = 'Y'
     C     keysl3        setll     slot3
     *
     C                   dow       forevr = forevr
     *
750aDC*    keysl3        reade     slot3                                  79
750aDC*                  if        *in79
750aMC                   read      slot3                                  79
750aMC                   if        slitem <> $pitem
750aMC                             or *in79 = *on
720 AC                   if        $pCmd = '*NEXT'
720 AC                   eval      $pCmd = '*FIRST'
     C     keysl3        setll     slot3
750aDC*    keysl3        reade     slot3                                  79
750aMC                   read      slot3                                  79
720 Ac                   else
     C                   leave
720 AC                   endif
     C                   endif
     *
416aAC                   select
750aA*    Ignore when not a pick slot.
750aAC                   when      slpick <> 'Y'
750aAC                   iter
750aA*    Ignore when slstat is not A or RP for pick slot
750aAC                   when      slstat <>'A' and
750aAC                             slstat <> 'RP'
750aAC                   iter
600aA*    Ignore license tracking special slots.
600aAC                   when      sldesg = 'BFC'
600aAC                   iter
700aA*    Looking for pick slot for *EACH pallet code.
700aAC                   when      $pcmd = '*FIRSTEA'
700aAC                   exsr      GetSlotdef
700aAC                   if        sdpal <> '*EACH'
700aAc                   iter
700aAc                   endif
700aA
700bA*    Need to exclude pick slot for *EACH pallet code.
700bAC                   when      $pcmd = '*FIRST  '
700bAC                   exsr      GetSlotdef
700bAC                   if        sdpal = '*EACH'
700bAc                   iter
700bAc                   endif
700bA
416aA*    Looking for pick slot from previous run of program.
416aA*    When we find slot, set flag so that we can get
416aA*    next slot in sequence.
416aAC                   when      $pcmd = '*NEXT   '  and
416aAC                             sltfnd = '*NO '  and
416aAC                             sldisp <> svdisp
416aAC                   iter
416aA*
416aAC                   when      $pcmd = '*NEXT   '  and
416aAC                             sltfnd = '*NO '  and
416aAC                             sldisp = svdisp
416aAC                   eval      sltfnd = '*YES'
416aAC                   iter
416aA*
416aAC                   endsl
416aA*
     C                   eval      $pslot = sldisp
416 AC                   eval      $paisl = slaisl
416 AC                   eval      $ploc = slloc
416 AC                   eval      $prlvl = slrlvl
416 AC                   eval      $phand = slhand
500 AC                   if        %parms >= 10
500 AC                   eval      $ppseq = slpseq
500 AC                   endif
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
     *
415aAC                   if        $prtn = '*NONE   '
700aAc                             and $pcmd <> '*FIRSTEA'
720aAc                             and $pcmd <> '*FRSTPCK'
415aA*
415aA*   Get last overflow slot for item.
415aA*
415aAC                   eval      kypick = 'N'
415aAC     keysl3        setll     slot3
415aA*
415aAC                   dow       forevr = forevr
415aA*
415aAC     keysl3        reade     slot3                                  79
415aAC                   if        *in79
415aAC                   leave
415aAC                   endif
415aA*
416aAC                   select
600aA*    Ignore license tracking special slots.
600aAC                   when      sldesg = 'BFC'
600aAC                   iter
416aA*    Looking for overflow slot from previous run of program.
416aA*    When we find slot, set flag so that we can get
416aA*    next slot in sequence.
416aAC                   when      $pcmd = '*NEXT   '  and
416aAC                             sltfnd = '*NO '  and
416aAC                             sldisp <> svdisp
416aAC                   iter
416aA*
416aAC                   when      $pcmd = '*NEXT   '  and
416aAC                             sltfnd = '*NO '  and
416aAC                             sldisp = svdisp
416aAC                   eval      sltfnd = '*YES'
416aAC                   iter
416aA*
416aAC                   endsl
416aA*
415aAC                   eval      $pslot = sldisp
416 AC                   eval      $paisl = slaisl
416 AC                   eval      $ploc = slloc
416 AC                   eval      $prlvl = slrlvl
416 AC                   eval      $phand = slhand
500 AC                   if        %parms >= 10
500 AC                   eval      $ppseq = slpseq
500 AC                   endif
415aMC                   eval      $prtn = '*OKOVRF '
416bA*
416bA*    Overflow slot found - exit loop.
416bAC                   if        $pcmd = '*NEXT   '  or
416bAC                             $pcmd = '*FRSTFRS'
416bAC                   leave
416bAC                   endif
415aA*
415aAC                   enddo
415aAC                   endif
     *
     C                   return
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *off
640 A
640 A*  Get client id
640 A
640 AC                   call      'GETCLIENT'
640 AC                   parm                    client
640 AC                   parm                    clientloc

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
     *
     C                   endsr
700aA*----------------------------------------------------------------
700aA*  GetSlotdef   Get slotdef record
700aA*----------------------------------------------------------------
700aA
700aAC     GetSlotdef    begsr
700aA /free
700aA    chain (slwhse: slsdef) slotdef;
700aA    if not %found;
700aA      sdpal = '';
700aA    endif;
700aA /end-free
700aAC                   endsr
