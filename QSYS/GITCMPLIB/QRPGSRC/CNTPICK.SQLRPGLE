     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  CNTPICK     Count pick slots for item.
     *  12 October 2001
     *  Dave Sommerville
     *
     *  Revisions
     *
412 A*    10/12/01  DAS  4.16
     *      - Created.
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
     *   item. If a slot is sent to the program, it will be excluded
     *   from the count.
     *
     *----------------------------------------------------------------

     Fslot3     if   e           k disk
700aAFslotdef   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

700bAD EachCnt         s              2  0
     D forever         s               n
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D pssrflag        s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse  Warehouse number.
     *      $pitem  Item number.
     *      $pwhdp  Warehouse department of slot to skip (optional).
     *      $pdisp  Pick slot to skip (optional).
     *
     *    Returned Parameters
     *      $pcount Pick slot count, excluding skipped slot.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pitem           15
     C                   parm                    $pwhdp            5
     C                   parm                    $pdisp           12
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

     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'

     *  Count active pick slots for item.

     C     sl3key        setll     slot3

 1B  C                   dow       forever = forever

     C     sl3key        reade     slot3
     C                   if        %eof
 1L  C                   leave
 2E  C                   endif

     C                   if        slwhdp = $pwhdp and sldisp = $pdisp
 1L  C                   iter
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
