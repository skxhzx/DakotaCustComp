500gA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CNTPICKTFR  Count pick slots for item - Transfer version
     *  10 May 2005
     *  Dave Sommerville
     *
     *  Revisions
     *
412 A*    05/10/05  DAS  5.00
     *      - Created.
500aA*    05/27/05  RLP  5.00a
     *      - With the 5.00f mod to IT352, we are allowing transfers
     *        between dept's, there is possibility that product exist
     *        in pick slots from different departments, changed main
     *        loop to count/skip ALL pick slots for item even if in
     *        different dept.
     *
600aA*    05/20/00  DAS  6.00a  P#00045
     *      - License tracking
     *      - Revised logic on how to determine if original pick
     *        slot is empty.
     *
700aA*    04/29/16  DAS  7.00a
     *      - Revised to ignore slots with pallet type *EACH.
     *
700bA*    05/03/16  KDE  7.00b
     *      - Revised allow only ONE *EACH pallet type
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *   This program counts the number of active pick slots for an
     *   item. The 'To' slot will be excluded from the count.
     *
     *   This program is only called when a transfer is taking place.
     *   Therfore, if the entire quantity of the 'From' slot is being
     *   transfered, it will be excluded from the count.
     *
     *----------------------------------------------------------------

     Fslot3     if   e           k disk
600aAFworkusr6  if   e           k disk
700aAFslotdef   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D alltfr          s               n
700bAD EachCnt         s              2  0
     D forever         s               n
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
600aDD*pssrflag        s               n
     D wktype          s                   like(wurectype)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

600aA /Copy qcopysrc,c#pgminfds
600aDD*               sds
600aDD* #prog            *proc
600aDD* #status               11     15
600aDD* #stmt                 21     28  0
600aDD* #pgmmsg               91    170
600aDD* #job                 244    253
600aDD* #user                254    263
600aDD* #jobn                264    269
600aDD**#jobdt               276    281  0
600aDD**#jobtm               282    287  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse  Warehouse number.
     *      $pitem  Item number.
     *      $pwhdp  Warehouse department.
     *      $pto    'To' slot.
     *      $pfrom  'From' slot.
     *
     *    Returned Parameters
     *      $pcount Pick slot count, excluding skipped slot.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pitem           15
     C                   parm                    $pwhdp            5
     C                   parm                    $pto             12
     C                   parm                    $pfrom           12
     C                   parm                    $pcount           3 0
     C                   parm                    $preturn          8
     C                   parm                    $pmessage        60

 1L  C                   eval      $pcount = 0
 1L  C                   eval      $preturn = '*OK'
 1L  C                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Set key to only look at active pick slots.

     C     sl3key        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     C                   kfld                    kystat
     C                   kfld                    kypick
600aA*
600aA*  Define full Key For WORKUSR6
600aA*
600aAC     keyUsr6       klist
600aAC                   kfld                    wkType
600aAC                   kfld                    #emp#
600aAC                   kfld                    $pwhse
600aAC                   kfld                    $pwhdp
600aAC                   kfld                    $pfrom
600aA
600aA* Get user information
600aA
600aAC                   call      'GETUSER'
600aMC                   parm                    #curruser
600aAC                   parm      0             #whse             3 0
600aAC                   parm      0             #emp#             5 0
600aAC                   parm                    #fnam            15
600aAC                   parm                    #init             1
600aAC                   parm                    #lnam            20
600aAC                   parm                    #whdp             5
600aAC                   parm                    #styp             1
600aAC                   parm                    #shft             6
600aAC                   parm                    #crew             6
600aAC                   parm      0             #nhrs             3 1
600aAC                   parm                    #rtn              8
600aAC                   parm                    e$bpu             1
600aAC                   parm                    e$lng             2
600aA
600aA* Get Pull slot from WORKUSR file.
600aA
600aAC                   if        %subst($pfrom:1:3) <> 'USR'
600aAC                   eval      wuPulWhdp = $pwhdp
600aAC                   eval      wuPulDisp = $pfrom
600aAC                   else
600aAC                   eval      wktype = 'TFR'
600aAC     keyUsr6       chain(e)  workusr6
600aAC                   if        not %found(workusr6)
600aAC                   eval      wuPulWhdp = ' '
600aAC                   eval      wuPulDisp = ' '
600aAC                   endif
600aAC                   endif

     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'

     *  Count active pick slots for item.

     C     sl3key        setll     slot3

 1B  C                   dow       forever = forever

     C     sl3key        reade     slot3
     C                   if        %eof
 1L  C                   leave
 2E  C                   endif

     *    Skip 'To' slot.

500aDC*                  if        slwhdp = $pwhdp and sldisp = $pto
500aMC                   if        sldisp = $pto
 1L  C                   iter
 2E  C                   endif

     *    Skip 'From' slot if entire qty being transfered.

500aDC*                  if        slwhdp = $pwhdp and sldisp = $pfrom
600aDC**                 if        sldisp = $pfrom
600aMC                   if        sldisp = wuPulDisp
 1L  C                   exsr      chktfrqty
 1L  C                   if        alltfr
 1L  C                   iter
 1L  C                   endif
 2E  C                   endif
700aA
700aA*  Count active pick slots for item.
700aA
700aAC                   exsr      GetSlotdef
700aAC                   if        sdpal = '*EACH'
700bA /free
700bA           // confirm that no *EACH already exist for item
700bA           EachCnt = *zeros;
700bA           exec sql select count(*) into :EachCnt
700bA                      from Slot,SlotDef
                         where slwhse = sdwhse and
                               slsdef = sdcode and
                               sdpal = '*EACH' and
700bA                          slwhse = :$pwhse and
700bA                          slitem = :$pitem;

                         if EachCnt > 0;
                            $pReturn = '*OK';
                            $pMessage = '*ONEEACH';
700bA                    endif;
700bA /end-free
700aAC                   iter
700aAC                   endif

 1L  C                   eval      $pcount = $pcount + 1

 1E  C                   enddo

     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr

     *  Make sure we don't get caught in an infinite loop

 1B  C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

     *  Send message back to calling program.

     C                   eval      $preturn = 'U:' + #status
     C                   eval      $pmessage = 'U:'
     C                                       + %trim(#prog)
     C                                       + '('
     C                                       + %trim(%editc(#stmt:'Z'))
     C                                       + ')-'
     C                                       + #pgmmsg
     C                   eval      *inlr = *on
 1E  C                   return

     C                   endsr

     *----------------------------------------------------------------
     *  chktfrqty   Check transfer quantity.
     *----------------------------------------------------------------

     C     chktfrqty     begsr
     C                   eval      alltfr = *off
600aD **
600aD ** See if entiry quantity is being transfered.
600aD **
600aD **   First, tfr qty must equal stk + rcv qtys.
600aD **
600aDC**                 if        sltfr1 <> (slstk1+slrcv1)
600aDC**                           or sltfr2 <> (slstk2+slrcv2)
600aDC**                           or sltfr3 <> (slstk3+slrcv3)
600aDC**                 goto      endchktfrqty
600aDC**                 endif

     *    Last, nothing can be in pck / alc buckets.
600aA*    With license tracking, all buckets must be zero.
600aA*    Re: Tfr qty is transfered into a USR slot so nothing
600aA*        would be left in Pick slot if everything was taken.

     C                   if        slpck1 <> 0
     C                             or slpck2 <> 0
     C                             or slpck3 <> 0
     C                             or slalc1 <> 0
     C                             or slalc2 <> 0
     C                             or slalc3 <> 0
600aAC                             or slstk1 <> 0
600aAC                             or slstk2 <> 0
600aAC                             or slstk3 <> 0
600aAC                             or sltfr1 <> 0
600aAC                             or sltfr2 <> 0
600aAC                             or sltfr3 <> 0
600aAC                             or slrcv1 <> 0
600aAC                             or slrcv2 <> 0
600aAC                             or slrcv3 <> 0
     C                   goto      endchktfrqty
     C                   endif

     *    Otherwise, it looks like everything is being transfered.

     C                   eval      alltfr = *on

     C     endchktfrqty  endsr

700aA*----------------------------------------------------------------
700aA*  GetSlotdef   Get slotdef record
700aA*----------------------------------------------------------------
700aA
700aAC     GetSlotdef    begsr
      /free
         chain (slwhse: slsdef) slotdef;
         if not %found;
           sdpal = '';
         endif;
      /end-free
     C                   endsr
