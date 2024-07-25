     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')

     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  AAAHSTSLOT   Test host slot interface for testing adjustments
     *  11 April 2002
     *  Dave Sommerville
     *
416  *    04/11/03  DAS  4.16
     *      - Created
     *
     *----------------------------------------------------------------
     * Notes
     *
     *
     *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *    Standard Sub-Commands
      *
      *      *OPEN             Open program and return.
      *
      *      *CLOSE            Close program with *INLR = *ON
      *
      *    Retrieval Sub-Commands
      *
      *      *GET              Get slot information using slot display.
      *
      *      *GETI             Get slot information using individual fields.
      *
416jA *      *GETXDOCK         Get crossdock slot for item.
416jA *                          - Assumes only 1 crossdock slot for item.
      *
416bA *      *NXTITEM          Get next slot for item.
      *                        Does a SETGT and then a READE.
      *
416bA *      *NXTOVRF          Get next overflow slot.
      *                        Does a SETGT and then a READE.
      *
416bA *      *NXTPICK          Get next pick slot.
      *                        Does a SETGT and then a READE.
      *
416rA *      *NXTPICKAV        Get next pick slot with available quantity.
      *                        Does a SETGT and then a READE.
      *
416bA *      *NXTSLOT          Get next slot using slot display field.
      *                        Does a SETGT and then a READE.
      *
416bA *      *NXTSLOTI         Get next slot using individual fields.
      *                        Does a SETGT and then a READE.
      *
416bA *      *PRVITEM          Get previous slot for item.
      *                        Does a SETLL and then a READPE.
      *
416bA *      *PRVOVRF          Get previous overflow slot.
      *                        Does a SETLL and then a READPE.
      *
416bA *      *PRVPICK          Get previous pick slot.
      *                        Does a SETLL and then a READPE.
      *
416bA *      *PRVSLOT          Get previous slot using slot display field.
      *                        Does a SETLL and then a READPE.
      *
416bA *      *PRVSLOTI         Get previous slot using individual fields.
      *                        Does a SETLL and then a READPE.
      *
      *    Maintenance Sub-Commands
      *
      *      *ADD              Add slot.
      *
      *      *ADDVS            Add virtual slot.
      *
416jA *      *ADDXDOCK         Add crossdock slot.
416jA *                         - Not used by program
416jA *                         - If sent, assumed to be sent by Dakota and
416jA *                           is passed through to host.
416jA *                         - Used to tell host that XDK slot created
416jA *                           by Dakota using *CRTXDOCK command.
416jA *                         - Host system should only send *CRTXDOCK.
      *
      *      *CHANGE           Change slot.
      *
416nA *      *CHGITEM          Change item number in slot.
      *
416jA *      *CRTXDOCK         Create crossdock slot.
      *
      *      *DELETE           Delete slot using slot display field.
      *      *DELETEI          Delete slot using individual slot fields.
      *      *DELETEX          Delete slot w/o checks using slot display fld
      *
      *      *SET2VFY          Set slot to Verified state.
      *
      *      *VERIFYADD        Do "*ADD" verification without update.
      *      *VERIFYCHG        Do "*CHANGE" verification without update.
      *      *VERIFYDEL        Do "*DELETE" verification without update.
416nA *      *VFYCHGITM        Do "*CHGITEM" verification without update.
      *
      *      *WARN             Check for warnings. Only one warning is
      *                        flagged at a time.
      *
      *      *WARNOVR          Override warning. Check for another warning.
      *
      *    Quantity Sub-Commands
      *
      *      *ADJUST           Normal stock adjustment.
      *                        For negative adjustment, the adjustment qty
      *                        cannot be greater than the calculated
      *                        adjustable quantity.
      *
      *      *ADJUSTORD        Selection order stock adjustment.
      *                        This adjustment should only be used with the
      *                        Locator system. Slot quantity is allowed to
      *                        go negative. If slot is a pick slot and slot
      *                        quantity goes negative, generate a Priority
      *                        Replenishment.
      *
416uA *      *ADJUSTTFR        Transfer adjustment record created.
      *                        This subcommand does not update an local
      *                        files. It is only passed to the host system.
      *
416cA *      *ALC2PCK          Move qty from allocated to picked.
416cA *                        Decrease allocated qty with original qty.
416cA *                        Increase pick qty with adjust qty.
      *
416cA *      *ALLOCATE         Update allocated quantity.
416cA *                        Inc/Dec allocated qty with adjust qty.
      *
416cA *      *CLSPICK          Close pick.
416cA *                        Decrease pick qty with original qty.
416cA *                        Decrease stock qty with adjust qty.
      *
416cA *      *CLSRCV           Close receiving/putaway.
416cA *                        Decrease receive qty with original qty.
416cA *                        Increase stock qty with adjust qty.
      *
416cA *      *CLSTFRIN         Close transfer-in.
416cA *                        Decrease receive qty with original qty.
416cA *                        Increase stock qty with adjust qty.
      *
416cA *      *CLSTFROUT        Clost transfer-out.
416cA *                        Decrease transfer qty with original qty.
416cA *                        Decrease stock qty with adjust qty.
      *
416cA *      *PCK2ALC          Move qty from picked to allocated.
416cA *                        Decrease pick qty with original qty.
416cA *                        Increase allocated qty with adjust qty.
      *
416cA *      *PICK             Update picked quantity.
416cA *                        Inc/Dec pick qty with adjust qty.
      *
416cA *      *RECEIVE          Update receive quantity.
416cA *                        Inc/Dec receive qty with adjust qty.
      *
416eA *      *SEQPTYRPL        Sequence priority replenishments
      *
416cA *      *STOCK            Update stock quantity.
416cA *                        Inc/Dec stock qty with adjust qty.
      *
416cA *      *TFRIN            Transfer quantity into slot.
416cA *                        Inc/Dec receive qty with adjust qty.
      *
416cA *      *TFROUT           Transfer quantity out of slot.
416cA *                        Inc/Dec transfer qty with adjust qty.
      *
      *      *VERIFY           Do verification for *ADJUST.
      *
      *      *VERIFYORD        Do verification for *ADJUSTORD.
      *
416oA *      *VERIFYTFI        Do verification for *TFRIN.
      *      *VERIFYTFO        Do verification for *TFROUT.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Faaahstqty uf a e           k disk    usropn
     F                                     infds(file1ds)
     Faaahstadj o    e           k disk    usropn

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS
     D savesubcmd      s                   like($psubcmd)

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($slver#)
     D savedisp        s                   like($sldisp)
     D saveexpdu       s                   like($slexpdu)
     D saveexpd        s                   like($slexpd)
     D saveslfdu       s                   like($slslfdu)
     D saveslfd        s                   like($slslfd)
     D saveprtyu       s                   like($slprtyu)
     D saveprty        s                   like($slprty)
     D $slotbefore     s                   like($slot)
     D $slotinput      s                   like($slot)
     D $preturninput   s                   like($preturn)
     D $pmessageinput  s                   like($pmessage)

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D pgm2close       s             10

     D driitem         s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D DakotaCall      s               n
     D HostCall        s               n
     D UpdateDakota    s               n

     D DirectPutaway   s               n
     D ManualPutaway   s               n

     D check4err       s               n
     D curdate         s              8  0
     D curtime         s              6  0
     D desigcode       s                   like($sldesg)
     D dummy           s                   like($slloc)
     D error           s               n
     D exist           s               n
     D flaghs          s               n
     D forever         s               n   inz(*on)
     D found           s               n
     D i               s              3  0
     D item#           s                   like($slitem)
     D j               s              3  0
     D k               s              3  0
     D lasttime        s              6  0 inz(999999)
     D lock            s               n
     D lockedhstqty    s               n
     D logit           s               n
     D lowiaorg        s              7  0
     D lowiaqty        s              7  0
     D lowunitwgt      s              9  2
     D lowwhavl        s              7  0
     D openstack       s             10    dim(15)
     D                                     inz(' ')
     D pssrflag        s               n
     D remaincw        s              7  2
     D ssbflag         s               n
     D warningtype     s                   like($psubcmd)

416dAD #sentitem       s                   like($ititem)
416dAD #senttype       s                   like($ittype)
416dAD #sentdesc       s                   like($itdesc)
416dAD #sentpdsc       s                   like($itpdsc)
416dAD #sentwhdp       s                   like($itwhdp)
416dAD #sentstyp       s                   like($itstyp)
416dAD #sentdesg       s                   like($itdesg)
416dAD #sentum1        s                   like($itum1)
416dAD #sentflg1       s                   like($itflg1)
416dAD #sentum2        s                   like($itum2)
416dAD #sentumq2       s                   like($itumq2)
416dAD #sentflg2       s                   like($itflg2)
416dAD #sentum3        s                   like($itum3)
416dAD #sentumq3       s                   like($itumq3)

416dAD #slotitem       s                   like($ititem)
416dAD #slottype       s                   like($ittype)
416dAD #slotdesc       s                   like($itdesc)
416dAD #slotpdsc       s                   like($itpdsc)
416dAD #slotwhdp       s                   like($itwhdp)
416dAD #slotstyp       s                   like($itstyp)
416dAD #slotdesg       s                   like($itdesg)
416dAD #slotum1        s                   like($itum1)
416dAD #slotflg1       s                   like($itflg1)
416dAD #slotum2        s                   like($itum2)
416dAD #slotumq2       s                   like($itumq2)
416dAD #slotflg2       s                   like($itflg2)
416dAD #slotum3        s                   like($itum3)
416dAD #slotumq3       s                   like($itumq3)
416dAD #slotnrpk       s                   like($imnrpk)
416dAD #slotflgd       s                   like($itflgd)
416nAD #slotswgt       s                   like($itswgt)
416nAD #slotcwgt       s                   like($itcwgt)

416dAD #ssbitem        s                   like($ititem)
416dAD #ssbtype        s                   like($ittype)
416dAD #ssbdesc        s                   like($itdesc)
416dAD #ssbpdsc        s                   like($itpdsc)
416dAD #ssbwhdp        s                   like($itwhdp)
416dAD #ssbstyp        s                   like($itstyp)
416dAD #ssbdesg        s                   like($itdesg)
416dAD #ssbum1         s                   like($itum1)
416dAD #ssbum2         s                   like($itum2)
416dAD #ssbumq2        s                   like($itumq2)
416dAD #ssbum3         s                   like($itum3)
416dAD #ssbumq3        s                   like($itumq3)

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
     *  File info data structures
     *----------------------------------------------------------------

     D File1DS         ds
     D  f1filename             1      8
     D  f1openind              9      9
     D  f1endoffile           10     10
     D  f1status              11     15  0
     D  f1opercode            16     21
     D  f1routine             22     29
     D  f1stmtnbr             30     37
     D  f1recordcd            38     45
     D  f1messageid           46     52
     D  f1sourceid            53     54

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
      *      $pmessage  Return code
      *      $pdata     Data returned by command
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd
     C                   parm                    $pprogram
     C                   parm                    $preturn
     C                   parm                    $pmessage
     C                   parm                    $pdata

     C                   eval      $slotinput     = $pdata
     C                   eval      $preturninput  = $preturn
     C                   eval      $pmessageinput = $pmessage

     C                   eval      $slot    = $pdata
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See if we are just opening or closing program.

     C                   select

     C                   when      $psubcmd = '*OPEN'
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   goto      bottom

     C                   when      $psubcmd = '*CLOSE'
     C                   exsr      aaaclose
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Otherwise, do some initialization and move on.

     C                   exsr      aaainit
     C                   eval      error = *off

     *  Do what user has requested.

     C                   select

     C                   when      $psubcmd = '*ADD'
     C                   when      $psubcmd = '*ADDVS'
416jAC                   when      $psubcmd = '*ADDXDOCK' and DakotaCall

416cAC                   when      $psubcmd = '*ADJUST'    or
416cAC                             $psubcmd = '*ADJUSTORD' or
416cAC                             $psubcmd = '*ADJUSTTFR'
416cAC                   exsr      verifyqty
416pAC                   exsr      shiftssbqty
416cAC                   exsr      qtyadjust
416cAC                   exsr      writeadj

416cAC                   when      $psubcmd = '*ALC2PCK'
416cAC                   when      $psubcmd = '*ALLOCATE'
     C                   when      $psubcmd = '*CHANGE'
416nAC                   when      $psubcmd = '*CHGITEM'
416cAC                   when      $psubcmd = '*CLSPICK'
416cAC                   when      $psubcmd = '*CLSRCV' or
416cAC                             $psubcmd = '*CLSTFRIN'
416cAC                   when      $psubcmd = '*CLSTFROUT'
     C                   when      $psubcmd = '*CRTXDOCK'
     C                   when      $psubcmd = '*DELETE' or
     C                             $psubcmd = '*DELETEI'
     C                   when      $psubcmd = '*DELETEX'
     C                   when      $psubcmd = '*SET2VFY'
     C                   when      $psubcmd = '*GET'
     C                   when      $psubcmd = '*GETI'
416jAC                   when      $psubcmd = '*GETXDOCK'
416bAC                   when      (%subst($psubcmd:1:4) = '*NXT' or
416bAC                              %subst($psubcmd:1:4) = '*PRV') and
416bAC                             (%subst($psubcmd:5:5) = 'ITEM '  or
416bAC                              %subst($psubcmd:5:5) = 'OVRF '  or
416bAC                              %subst($psubcmd:5:5) = 'PICK '  or
416rAC                              %subst($psubcmd:5:6) = 'PICKAV' or
416bAC                              %subst($psubcmd:5:5) = 'SLOT '  or
416bAC                              %subst($psubcmd:5:5) = 'SLOTI')
416cAC                   when      $psubcmd = '*PCK2ALC'
416cAC                   when      $psubcmd = '*PICK'
416cAC                   when      $psubcmd = '*RECEIVE' or
416cAC                             $psubcmd = '*TFRIN'
416eAC                   when      $psubcmd = '*SEQPTYRPL'
416cAC                   when      $psubcmd = '*STOCK'
416cAC                   when      $psubcmd = '*TFROUT'
416cAC                   when      $psubcmd = '*VERIFY'    or
416cAC                             $psubcmd = '*VERIFYORD'
     C                   when      $psubcmd = '*VERIFYADD'
     C                   when      $psubcmd = '*VERIFYCHG'
     C                   when      $psubcmd = '*VERIFYDEL'
416oAC                   when      $psubcmd = '*VERIFYTFI'
416cAC                   when      $psubcmd = '*VERIFYTFO'
416nAC                   when      $psubcmd = '*VFYCHGITM'
     C                   other
     C                   eval      logit = *on
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'

     C                   endsl

     C     bottom        tag

     *  Make sure that nothing is locked.

     C                   exsr      unlock

     *  We are finished so get out

     C                   eval      $pdata = $slot
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     *  Define key for AAAHSTQTY file.

     C     keyhq         klist
     C                   kfld                    $slwhse
     C                   kfld                    $slitem

     C                   endsr

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
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

     C     aaainit       begsr

     C                   endsr

     *----------------------------------------------------------------
     *  aaaclose   Close called programs
     *----------------------------------------------------------------

     C     aaaclose      begsr

     C                   if        driitem
     C                   call(e)   'DRIITEM'
     C                   parm      '*CLOSE'      $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      ' '           $dridata
     C                   if        %error
     C                   endif
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  clearerrflags  Clear error flag fields.
     *----------------------------------------------------------------

     C     clearerrflags begsr

     C                   if        $slwhsee = '1'
     C                   eval      $slwhsee = '0'
     C                   endif

     C                   if        $slwhdpe = '1'
     C                   eval      $slwhdpe = '0'
     C                   endif

     C                   if        $slaisle = '1'
     C                   eval      $slaisle = '0'
     C                   endif

     C                   if        $slloce = '1'
     C                   eval      $slloce = '0'
     C                   endif

     C                   if        $slrlvle = '1'
     C                   eval      $slrlvle = '0'
     C                   endif

     C                   if        $slhande = '1'
     C                   eval      $slhande = '0'
     C                   endif

     C                   if        $sldispe = '1'
     C                   eval      $sldispe = '0'
     C                   endif

     C                   if        $slstype = '1'
     C                   eval      $slstype = '0'
     C                   endif

     C                   if        $slstate = '1'
     C                   eval      $slstate = '0'
     C                   endif

     C                   if        $slsdefe = '1'
     C                   eval      $slsdefe = '0'
     C                   endif

     C                   if        $sldesge = '1'
     C                   eval      $sldesge = '0'
     C                   endif

     C                   if        $slactve = '1'
     C                   eval      $slactve = '0'
     C                   endif

     C                   if        $slblde = '1'
     C                   eval      $slblde = '0'
     C                   endif

     C                   if        $slpicke = '1'
     C                   eval      $slpicke = '0'
     C                   endif

     C                   if        $slpseqe = '1'
     C                   eval      $slpseqe = '0'
     C                   endif

     C                   if        $slprtye = '1'
     C                   eval      $slprtye = '0'
     C                   endif

     C                   if        $slslfde = '1'
     C                   eval      $slslfde = '0'
     C                   endif

     C                   if        $slrsrve = '1'
     C                   eval      $slrsrve = '0'
     C                   endif

     C                   if        $sliteme = '1'
     C                   eval      $sliteme = '0'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getitem  Get item info.
     *----------------------------------------------------------------

     C     getitem       begsr

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#

     C                   eval      $itwhse = $slwhse
     C                   eval      $ititem = item#

     C                   eval      driitem = *on
     C                   call(e)   'DRIITEM'
     C                   parm                    $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIITEM'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   when      $drireturn <> '*OK' and
     C                             check4err = *on
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   goto      endgetitem
     C                   endsl

     C     endgetitem    endsr

     *----------------------------------------------------------------
     *  gethstqty  Get host qty record from AAAHSTQTY.
     *----------------------------------------------------------------

     C     gethstqty     begsr
     C                   eval      lockedhstqty = *off

     C* Open aaahstqty file.

     C                   if        not %open(aaahstqty)
     C                   exsr      openhstqty
     C                   if        error
     C                   goto      endgethstqty
     C                   endif
     C                   endif

     C* Get aaahstqty record

     C                   if        lock
     C     keyhq         chain     aaahstqty
     C                   else
     C     keyhq         chain(n)  aaahstqty
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDHQTY'
     C                   eval      $pmessage = 'Error occured getting '
     C                                       + 'AAAHSTQTY record '
     C                                       + %trim($saitem)
     C                   goto      endgethstqty
     C                   endif

     C                   if        lock
     C                   eval      lockedhstqty = *on
     C                   endif

     C     endgethstqty  endsr

416bA*----------------------------------------------------------------
416bA*  openhstadj  Open file aaahstadj
416bA*----------------------------------------------------------------
416bA
416bAC     openhstadj    begsr

     C                   if        not %open(aaahstadj)
     C                   open(e)   aaahstadj
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRHADJ'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file AAAHSTADJ in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  openhstqty  Open file aaahstqty
416bA*----------------------------------------------------------------
416bA
416bAC     openhstqty    begsr

     C                   if        not %open(aaahstqty)
     C                   open(e)   aaahstqty
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRHQTY'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file AAAHSTQTY in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  qtyadjust Update stock/held quantities.
     *----------------------------------------------------------------

     C     qtyadjust     begsr
     C                   move      *off          error

     *  Extra verification ...

     *  Update quantities ...

     *    Update stock quantities with adjust quantity.

     C                   eval      iqstk1 = iqstk1 + $saqty1
     C                   eval      iqstk2 = iqstk2 + $saqty2
     C                   eval      iqstk3 = iqstk3 + $saqty3

     *    Update record.

     C                   update(e) iqrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'HQUPDERR'
     C                   eval      $pmessage = 'Error updating AAAHSTQTY '
     C                                       + '('
     C                                       + %Trim(%editc($slwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($saitem)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endqtystk
     C                   endif

     C     endqtystk     endsr

416pA*----------------------------------------------------------------
416pA*  shiftssbqty   Shift quantities for SSB item.
416pA*----------------------------------------------------------------

416pAC     shiftssbqty   begsr

     *  Shift quantities if sent item is an SSB item.

     C                   if        #senttype = 'S'
     C                   eval      $saqty3 = $saqty2
     C                   eval      $saqty2 = $saqty1
     C                   eval      $saqty1 = 0
     C                   eval      $saorg3 = $saorg2
     C                   eval      $saorg2 = $saorg1
     C                   eval      $saorg1 = 0
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  unlock         Unlock records.
     *----------------------------------------------------------------

     C     unlock        begsr

     C                   if        lockedhstqty
     C                   unlock    aaahstqty
     C                   if        %error
     C                   endif
     C                   endif

     C                   endsr

416dA*----------------------------------------------------------------
416dA*  verifyqty  Verify information when changing quantities.
416dA*----------------------------------------------------------------
416dA
416daC     verifyqty     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $slwhseu
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   goto      endvfyqty
     C                   endif

     *  Item must be sent.

     C                   if        not $saitemu
     C                   eval      error = *on
     C                   eval      $sliteme = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   goto      endvfyqty
     C                   endif

     *  Adjustment qtys must be sent.

     C                   if        not $saqtyu
     C                   eval      error = *on
     C                   eval      $saqty1e = '1'
     C                   eval      $saqty2e = '1'
     C                   eval      $saqty3e = '1'
     C                   eval      $preturn = 'QTYNOTSNT'
     C                   goto      endvfyqty
     C                   endif

     *  Initialize original qty to zero if not sent.
     *    This will help with future calculations.

     C                   if        not $saorgu
     C                   eval      $saorg1 = 0
     C                   eval      $saorg2 = 0
     C                   eval      $saorg3 = 0
     C                   endif

     *  Get "sent" item information.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETMAIN'
     C                   eval      item# = $saitem
     C                   exsr      getitem
     C                   if        error
     C                   goto      endvfyqty
     C                   endif

     C                   eval      #sentitem = $ititem
     C                   eval      #senttype = $ittype
     C                   eval      #sentdesc = $itdesc
     C                   eval      #sentpdsc = $itpdsc
     C                   eval      #sentwhdp = $itwhdp
     C                   eval      #sentstyp = $itstyp
     C                   eval      #sentdesg = $itdesg
     C                   eval      #sentum1  = $itum1
     C                   eval      #sentflg1 = $itflg1
     C                   eval      #sentum2  = $itum2
     C                   eval      #sentumq2 = $itumq2
     C                   eval      #sentflg2 = $itflg2
     C                   eval      #sentum3  = $itum3
     C                   eval      #sentumq3 = $itumq3

416pA*  Shift SSB quantities.

416pAC                   exsr      shiftssbqty

     *  Get corresponding "slot" item for "sent" item.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETSLOT'
     C                   eval      item# = $saitem
     C                   exsr      getitem
     C                   if        error
     C                   goto      endvfyqty
     C                   endif

     C                   eval      #slotitem = $ititem
     C                   eval      #slottype = $ittype
     C                   eval      #slotdesc = $itdesc
     C                   eval      #slotpdsc = $itpdsc
     C                   eval      #slotwhdp = $itwhdp
     C                   eval      #slotstyp = $itstyp
     C                   eval      #slotdesg = $itdesg
     C                   eval      #slotum1  = $itum1
     C                   eval      #slotflg1 = $itflg1
     C                   eval      #slotum2  = $itum2
     C                   eval      #slotumq2 = $itumq2
     C                   eval      #slotflg2 = $itflg2
     C                   eval      #slotum3  = $itum3
     C                   eval      #slotumq3 = $itumq3
     C                   eval      #slotnrpk = $imnrpk
     C                   eval      #slotflgd = $itflgd
416nAC                   eval      #slotswgt = $itswgt
416nAC                   eval      #slotcwgt = $itcwgt

416pM*  Get corresponding SSB item for "slot" item (if any)
416pM*    (moved from before getting slot item)
416pM*    (revised to get SSB for slot item)

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETSSB'
416pDC**                 eval      item# = $saitem
416pMC                   eval      item# = #slotitem
     C                   exsr      getitem

     C                   if        error

     C                   eval      error = *off
     C                   eval      ssbflag = *off
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     C                   else

     C                   eval      ssbflag = *on
     C                   eval      #ssbitem = $ititem
     C                   eval      #ssbtype = $ittype
     C                   eval      #ssbdesc = $itdesc
     C                   eval      #ssbpdsc = $itpdsc
     C                   eval      #ssbwhdp = $itwhdp
     C                   eval      #ssbstyp = $itstyp
     C                   eval      #ssbdesg = $itdesg
     C                   eval      #ssbum1  = $itum1
     C                   eval      #ssbum2  = $itum2
     C                   eval      #ssbumq2 = $itumq2
     C                   eval      #ssbum3  = $itum3
     C                   eval      #ssbumq3 = $itumq3

     C                   endif

     *  Get itemqty record - Lock if not verifying.

     C                   eval      lock = *on
     C                   exsr      gethstqty
     C                   if        error
     C                   eval      $saiteme = '1'
     C                   goto      endvfyqty
     C                   endif

     *  Converty adjustment quantities to lowest uom quantitiy.

     C                   if        #slotumq2 <= 0
     C                   eval      #slotumq2 = 1
     C                   endif

     C                   if        #slotumq3 <= 0
     C                   eval      #slotumq3 = 1
     C                   endif

     C                   eval      lowiaqty = ($saqty1 * #slotumq2 * #slotumq3)
     C                                      + ($saqty2 * #slotumq3)
     C                                      + $saqty3

     C                   eval      lowiaorg = ($saorg1 * #slotumq2 * #slotumq3)
     C                                      + ($saorg2 * #slotumq3)
     C                                      + $saorg3

     *    Converty warehouse available qtys to lowest uom quantitiy.

     C     endvfyqty     endsr

416nA*----------------------------------------------------------------
416nA*  writeadj    Write aaahstadj record.
416nA*----------------------------------------------------------------
416nA
416nAC     writeadj      begsr

     *  Open AAAHSTADJ file.

     C                   exsr      openhstadj
     C                   if        error
     C                   goto      endwriteadj
     C                   endif

     *  Calculate unit weight for lowest uom.

     C                   eval      lowunitwgt = 0
416mMC                   if        $sacwta <> 0 and lowiaqty <> 0
     C                   eval      lowunitwgt = $sacwta / lowiaqty
     C                   endif

     *  Create adjustment record(s) ...

     C                   clear                   iarec
     C                   eval      iawhse = $slwhse
     C                   eval      iaitem = $saitem
     C                   eval      iawhdp = $slwhdp
     C                   eval      iadisp = $sldisp
     C                   eval      iacode = $sacode
     C                   eval      iamemo = $samemo
     C                   eval      iaby   = $saby
     C                   eval      iadate = curdate
     C                   eval      iatime = curtime

     C                   select

     *    When only catch weight sent ...

     C                   when      $sacwta <> 0 and
     C                             $saqty1 = 0  and
     C                             $saqty2 = 0  and
     C                             $saqty3 = 0

     C                   eval      iacwta = $sacwta
     C                   write     iarec
     C                   if        %error
     C                   endif

     *    When SSB item exists ...

     C                   when      ssbflag = *on

     C                   eval      remaincw = $sacwta

     *      Write adjustment record for base item.

     C                   if        $saqty1 <> 0

     C                   eval      iaqty1 = $saqty1
     C                   eval      iaqty2 = 0
     C                   eval      iaqty3 = 0
     C                   if        $saqty2 = 0 and $saqty3 = 0
     C                   eval      iacwta = $sacwta
     C                   else
     C                   eval      iacwta = ($saqty1 * #slotumq2 * #slotumq3)
     C                                    * lowunitwgt
     C                   eval      remaincw = $sacwta - iacwta
     C                   endif
     C                   write     iarec
     C                   if        %error
     C                   endif

     C                   endif

     *      Write adjustment record for SSB item.

     C                   if        $saqty2 <> 0 or $saqty3 <> 0

     C                   eval      iaqty1 = $saqty2
     C                   eval      iaqty2 = $saqty3
     C                   eval      iaqty3 = 0
     C                   eval      iacwta = remaincw
     C                   write     iarec
     C                   if        %error
     C                   endif

     C                   endif

     *    When SSB item does not exist ...

     C                   other

     *      Write single adjustment record for item.

     C                   eval      iaqty1 = $saqty1
     C                   eval      iaqty2 = $saqty2
     C                   eval      iaqty3 = $saqty3
     C                   eval      iacwta = $sacwta
     C                   write     iarec
     C                   if        %error
     C                   endif

     C                   endsl

     C     endwriteadj   endsr
