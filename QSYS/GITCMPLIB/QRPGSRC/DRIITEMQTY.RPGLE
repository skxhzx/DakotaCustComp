500aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  DRIITEMQTY  Dakota realtime interface - Item quantities
     *  04 December 2001
     *  Dave Sommerville
     *
416  *    12/04/01  DAS  4.16
     *      - Created
     *
416aA*    01/30/02  DAS  4.16a
     *      - Implemented logging.
     *
416bA*    02/11/02  DAS  4.16b
     *      - Added special check for status 'XD' (crossdock).
     *
416cA*    02/28/02  DAS  4.16c
     *      - Added *HOLD subcommand.
     *
416dA*    06/11/02  DAS  4.16d
     *      - Recompiled because of change to C#SLOT.
     *
417a *    10/17/03  DAS  4.17a
     *      - Added *TFRINCHG, *TFROUTCHG, *CLSTFICHG, *CLSTFOCHG.
     *      - Added commands specific for Returns. Letdowns, Specific Slot
     *        Replenishments and Priority Replenishments. This was done
     *        1) to provide more informative commands that can be viewed in
     *        the log and 2) because entered/expirations date logic needs
     *        to know what type of transaction is being performed.
     *
417e *    10/07/04  DAS  4.17e
     *      - Enh: Added command *CLSRCVADJ.
     *
500  *    02/09/05  DAS  5.00
     *      - Enh: Added command *STUFFIT.
     *
500a *    08/05/05  DAS  5.00a
     *      - Enh: Added command *STAGEPUT,*CLSSTGPUT,*VFYSTGPUT
     *
600aA*    10/23/08  DAS  6.00a
     *      - Added commands *RCVIN, *STGIN, *OSSIN, *USRIN,
     *        *USR2RTN, *USR2PUT.
     *
600bA*    04/30/09  DAS  6.00b
     *      - Added command *ADJUSTOSS
     *
600cA*    05/18/09  DAS  6.00c
     *      - Added command *CHGITEM
     *
600dA*    06/02/09  DAS  6.00d
     *      - Removed special XDK code.
     *
600eA*    06/03/09  DAS  6.00e
     *      - Addded command *USR2RCV.
     *
610aA*    07/20/09  DAS  6.10a
     *      - Addded command *ADJUSTRTN.
     *
610bA*    09/19/09  DAS  6.10b
     *      - Addded command *QTY2PUT, *QTY2PUT0.
     *
700aA*    01/05/17  LMC  7.00a
     *      - Addded command *RTNIN.
     *      - Addded command *USR2RTNO
     *
720 A*    02/21/18  KDE  7.20
     *      - Addded command *RPAIN.
     *      - Addded command *USR2RPA
     *
730 A*    02/27/19  MR   7.30a
     *      - Recalculate item quantities if item quantites go
     *        negative.
     *
730bA*    09/24/19  LMC  7.30b
     *      - Addded command *RWOIN.
     *      - Addded command *USR2RWO
     *
750aA*    12/03/21  LMC  7.50a
     *      - Addded add call to ut812 to close.
     *      - gui WTW transfers introduced an issue so we have to
     *        shutdown ut812 if called from here.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *  Except for special circumstances, when updating quantities, this
     *  interface should only be called from the slot interface program.
     *
     *  All user interface programs should call the slot interface to
     *  update quantities and then the slot interface will call this
     *  program to update the warehouse quantities correctly.
     *
     *  This method will eliminate the need for user interface programs
     *  to determine when quantities, such as the hold quantity, should
     *  be updated.
     *
     *  So the slot interface doesn't have to determine what to send to
     *  this program, it will just pass along the command and quanities
     *  that were sent to it along with some item and slot information
     *  needed to determine which quantities should be updated.
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
      *      *GET              Get item quantity information.
      *
      *      *GET&LOCK         Get & Lock item quantity record.
      *
      *      *UNLOCK           Unlock item quantity record.
      *
      *    Maintenance Sub-Commands
      *
      *      *ADD              Add item quantity record.
      *
      *      *DELETE           Delete item quantity record.
      *
      *    Quantity Sub-Commands (These should be identical to DRISLOT)
      *
      *      *ADJUST           Normal stock adjustment.
      *
600bA *      *ADJUSTOSS        Adjust OSS slot quantity.
      *
      *      *ADJUSTORD        Selection order stock adjustment.
      *
610aA *      *ADJUSTRTN        Return stock adjustment.
      *
      *      *ALC2PCK          Move qty from allocated to picked.
      *
      *      *ALLOCATE         Update allocated quantity.
      *
600cA *      *CHGITEM          Change item
      *
417aA *      *CLSLETIN         Close letdown-in
417aA *                        Same as *CLSTFRIN.
      *
417aA *      *CLSLTICHG        Close letdown-in with possible item change.
417aA *                        Same as *CLSTFICHG.
      *
417aA *      *CLSLETOUT        Close letdown-out.
417aA *                        Same as *CLSTFROUT.
      *
417aA *      *CLSLTOCHG        Close letdown-out with possible item change.
417aA *                        Same as *CLSTFOCHG.
      *
417aA *      *CLSPRIN          Close priority repl - in
417aA *                        Same as *CLSTFRIN.
      *
417aA *      *CLSPRICHG        Close prty repl-in with possible item change.
417aA *                        Same as *CLSTFICHG.
      *
417aA *      *CLSPROUT         Close priority repl - out
417aA *                        Same as *CLSTFROUT.
      *
417aA *      *CLSPROCHG        Close prty rpl-out with possible item change.
417aA *                        Same as *CLSTFOCHG.
      *
      *      *CLSPICK          Close pick.
      *
417aA *      *CLSPUTAWY        Close putaway.
417aA *                        Same as *CLSRCV.
      *
      *      *CLSRCV           Close receiving/putaway.
      *
417eA *      *CLSRCVADJ        Close receiving adjustment.
      *
417aA *      *CLSRTN           Close return/putaway.
417aA *                        Same as *CLSRCV.
      *
417aA *      *CLSSSIN          Close specific slot - in
417aA *                        Same as *CLSTFRIN.
      *
417aA *      *CLSSSICHG        Close spec slot-in with possible item change.
417aA *                        Same as *CLSTFICHG.
      *
417aA *      *CLSSSICHG        Close spec slot-in with possible item change.
417aA *                        Same as *CLSTFICHG.
      *
417aA *      *CLSSSOUT         Clost specific slot - out
417aA *                        Same as *CLSTFROUT.
      *
417aA *      *CLSSSOCHG        Close spec slt-out with possible item change.
417aA *                        Same as *CLSTFOCHG.
      *
417aA *      *CLSTFICHG        Close transfer-in.
      *
417aA *      *CLSTFOCHG        Close transfer-out.
      *
      *      *CLSTFRIN         Close transfer-in.
      *
      *      *CLSTFROUT        Close transfer-out.
      *
500aA *      *CLSSTGPUT        Close stage putaway.
500aA *                        Same as *CLSRCV.
      *
417aA *      *LETIN            Transfer Letdown quantity into slot.
417aA *                        Same as *TFRIN.
      *
417aA *      *LETINCHG         Transfer Letdown quantity into slot
417aA *                          with possible item change.
417aA *                        Same as *TFRINCHG.
      *
417aA *      *LETOUT           Transfer Letdown quantity out of slot.
417aA *                        Same as *TFROUT.
      *
417sA *      *LETOUTCHG        Transfer Letdown quantity out of slot
417sA *                          with possible item change.
417sA *                        Same as *TFROUTCHG.
      *
600aA *      *OSSIN            Same as *RECEIVE
      *
      *      *PCK2ALC          Move qty from picked to allocated.
      *
      *      *PICK             Update picked quantity.
      *
417aA *      *PRIN             Transfer Priority Repl quantity into slot.
417aA *                        Same as *TFRIN.
      *
417aA *      *PRINCHG          Transfer Priority Repl quantity into slot
417aA *                          with possible item change.
417aA *                        Same as *TFRINCHG.
      *
417aA *      *PROUT            Transfer Priority Repl quantity out of slot.
417aA *                        Same as *TFROUT.
      *
417aA *      *PROUTCHG         Transfer Priority Repl quantity out of slot
417aA *                          with possible item change.
417aA *                        Same as *TFROUTCHG.
      *
417aA *      *PUTAWAY          Update receive quantity for Putaway.
417aA *                        Same as *RECEIVE.
      *
610bA *      *QTY2PUT          Put quantity into slot.
      *
610bA *      *QTY2PUT0         Put zero quantity into slot.
      *
600aA *      *RCVIN            Same as *RECEIVE
      *
730bA *      *RWOIN            Same as *RCVIN
      *
700aA *      *RTNIN            For Returns - Same *RECEIVE
      *
720 A *      *RPAIN            For Store Staged Replenishments
      *
      *      *RECEIVE          Update receive quantity.
      *
417aA *      *RETURN           Update receive quantity for Return.
417aA *                        Same as *RECEIVE.
      *
417aA *      *SSIN             Tfr Specific Slot Repl quantity into slot.
417aA *                        Same as *TFRIN.
      *
417aA *      *SSINCHG          Tfr Specific Slot Repl quantity into slot
417aA *                          with possible item change.
417aA *                        Same as *TFRINCHG.
      *
417aA *      *SSOUT            Tfr Specific Slot Repl quantity out of slot.
417aA *                        Same as *TFROUT.
      *
417aA *      *SSOUTCHG         Tfr Specific Slot Repl quantity out of slot
417aA *                          with possible item change.
417aA *                        Same as *TFROUTCHG.
      *
500aA *      *STAGEPUT         Update receive quantity for Stage putaway.
500aA *                        Same as *RECEIVE.
      *
600aA *      *STGIN            Same as *RECEIVE
      *
      *      *STOCK            Update stock quantity.
      *
500 A *      *STUFFIT          Stuff item into slot.
500 A *                        Similar to *CLSRTN.
      *
      *      *TFRIN            Transfer quantity into slot.
      *
417aA *      *TFRINCHG         Transfer quantity into slot.
      *
      *      *TFROUT           Transfer quantity out of slot.
      *
417aA *      *TFROUTCHG        Transfer quantity out of slot.
      *
600aA *      *USRIN            Same as *RECEIVE
      *
600aA *      *USR2PUT          Same as *TFRINCHG
      *
600aA *      *USR2RTN          Same as *TFRINCHG
      *
      *      *VERIFY           Do verification for *ADJUST.
      *
      *      *VERIFYORD        Do verification for *ADJUSTORD.
      *
416cA *    Special subcommand for holding a quantity.
      *
416cA *      *HOLD             Update hold bucket.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fitemqty   uf a e           k disk    infds(file1ds)
     Flogiqty   o    e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEMQTY
     D saveVer#        s                   like($iqver#)
     D $iqtybefore     s                   like($itemqty)
     D $iqtyinput      s                   like($itemqty)
     D $preturninput   s                   like($preturn)
     D $pmessageinput  s                   like($pmessage)

     *----------------------------------------------------------------
     *  Computed slot quantities.
     *----------------------------------------------------------------

     D iqphy1          s                   like(iqstk1)
     D iqphy2          s                   like(iqstk2)
     D iqphy3          s                   like(iqstk3)
     D iqavl1          s                   like(iqstk1)
     D iqavl2          s                   like(iqstk2)
     D iqavl3          s                   like(iqstk3)
     D wiqstk1         s                   like(iqstk1)
     D remainder       s                   like(iqstk1)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcount         s              3p 0
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D activestats     C                   const('AZV')
     D forever         s               n   inz(*on)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D #umq2           s                   like($iqumq2)
     D #umq3           s                   like($iqumq3)
     D check4err       s               n
     D curdate         s              8  0
     D curtime         s              6  0
     D error           s               n
     D inactiveslot    s               n
     D item#           s                   like(iqitem)
     D kywhse          s                   like(iqwhse)
     D lasttime        s              6  0 inz(999999)
     D lock            s               n
     D lockitem        s                   like(iqitem)
     D                                     inz('*none')
     D lockwhse        s                   like(iqwhse)
     D logit           s               n
     D loopcount       s              3  0
     D lowadj          s              7  0
     D lowavl          s              7  0
     D nextseq#        s              7  0
     D pssrflag        s               n
     D warningtype     s                   like($psubcmd)

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

     C                   eval      $iqtyinput     = $pdata
     C                   eval      $preturninput  = $preturn
     C                   eval      $pmessageinput = $pmessage

     C                   eval      $itemqty = $pdata
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See if we are just opening or closing program.

     C                   select

     C                   when      $psubcmd = '*OPEN'
     C                   eval      logit = *off
     C                   goto      bottom

     C                   when      $psubcmd = '*CLOSE'
     C                   eval      logit = *off
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Otherwise, do some initialization and move on.

     C                   exsr      aaainit
     C                   eval      error = *off

     *  Do what user has requested.

     C                   select

     C                   when      $psubcmd = '*ADD'
     C                   eval      logit = *on
     C                   exsr      verifygen
     C                   if        not error
     C                   exsr      verifyadd
     C                   endif
     C                   if        not error
     C                   exsr      additemqty
     C                   endif

     C                   when      $psubcmd = '*ALLOCATE' or
     C                             $psubcmd = '*PICK'     or
     C                             $psubcmd = '*TFROUT'   or
417aAC                             $psubcmd = '*LETOUT'   or
417aAC                             $psubcmd = '*PROUT'   or
417aAC                             $psubcmd = '*SSOUT'   or
417aAC                             $psubcmd = '*TFROUTCHG' or
417aAC                             $psubcmd = '*LETOUTCHG' or
417aAC                             $psubcmd = '*PROUTCHG' or
417aAC                             $psubcmd = '*SSOUTCHG' or
     C                             $psubcmd = '*ALC2PCK'  or
     C                             $psubcmd = '*PCK2ALC'
     C                   eval      logit = *on
     C                   exsr      verifyqty
     C                   if        not error
     C                   exsr      savebefore
     C                   exsr      qtyallocate
     C                   endif

     C                   when      $psubcmd = '*CLSPICK'  or
417aMC                             $psubcmd = '*CLSTFROUT' or
417aMC                             $psubcmd = '*CLSLETOUT' or
417aMC                             $psubcmd = '*CLSPROUT' or
417aMC                             $psubcmd = '*CLSSSOUT' or
417aAC                             $psubcmd = '*CLSTFOCHG' or
417aAC                             $psubcmd = '*CLSLTOCHG' or
417aAC                             $psubcmd = '*CLSPROCHG' or
417aAC                             $psubcmd = '*CLSSSOCHG'
     C                   eval      logit = *on
     C                   exsr      verifyqty
     C                   if        not error
     C                   exsr      savebefore
     C                   exsr      qtyclspick
     C                   endif

     C                   when      $psubcmd = '*DELETE'
     C                   eval      logit = *on
     C                   exsr      deleteitemqty

     C                   when      $psubcmd = '*GET'
     C                   eval      logit = *off
     C                   eval      lock = *off
     C                   exsr      getitemqty
     C                   if        not error
     C                   exsr      iq2ds
     C                   endif

     C                   when      $psubcmd = '*GET&LOCK'
     C                   eval      logit = *off
     C                   eval      lock = *on
     C                   exsr      getitemqty
     C                   if        not error
     C                   exsr      iq2ds
     C                   endif

416cAC                   when      $psubcmd = '*HOLD'
416cAC                   eval      logit = *on
416cAC                   exsr      verifyqty
416cAC                   if        not error
416cAC                   exsr      qtyhold
416cAC                   endif

     C                   when      $psubcmd = '*STOCK'    or
     C                             $psubcmd = '*RECEIVE'  or
417aAC                             $psubcmd = '*RETURN'   or
417aAC                             $psubcmd = '*PUTAWAY'  or
500aAC                             $psubcmd = '*STAGEPUT' or
     C                             $psubcmd = '*CLSRCV'   or
417eAC                             $psubcmd = '*CLSRCVADJ' or
417aAC                             $psubcmd = '*CLSRTN'   or
500 AC                             $psubcmd = '*STUFFIT'  or
417aAC                             $psubcmd = '*CLSPUTAWY' or
500aAC                             $psubcmd = '*CLSSTGPUT' or
     C                             $psubcmd = '*TFRIN'    or
417aAC                             $psubcmd = '*LETIN'    or
417aAC                             $psubcmd = '*PRIN'    or
417aAC                             $psubcmd = '*SSIN'    or
600aAC                             $psubcmd = '*RCVIN'   or
730bAC                             $psubcmd = '*RWOIN'   or
700aAC                             $psubcmd = '*RTNIN'   or
720 AC                             $psubcmd = '*RPAIN'   or
600aAC                             $psubcmd = '*STGIN'   or
600aAC                             $psubcmd = '*OSSIN'   or
600aAC                             $psubcmd = '*USRIN'   or
610bAC                             $psubcmd = '*QTY2PUT' or
610bAC                             $psubcmd = '*QTY2PUT0' or
600aAC                             $psubcmd = '*USR2RTN' or
600aAC                             $psubcmd = '*USR2PUT' or
600eAC                             $psubcmd = '*USR2RCV' or
730bAC                             $psubcmd = '*USR2RWO' or
700aAC                             $psubcmd = '*USR2RTNO' or
720 AC                             $psubcmd = '*USR2RPA' or
600eAC                             $psubcmd = '*USR2STG' or
417aAC                             $psubcmd = '*TFRINCHG' or
417aAC                             $psubcmd = '*LETINCHG' or
417aAC                             $psubcmd = '*PRINCHG' or
417aAC                             $psubcmd = '*SSINCHG' or
     C                             $psubcmd = '*CLSTFRIN' or
417aAC                             $psubcmd = '*CLSLETIN' or
417aAC                             $psubcmd = '*CLSPRIN' or
417aAC                             $psubcmd = '*CLSSSIN' or
417aAC                             $psubcmd = '*CLSTFICHG' or
417aAC                             $psubcmd = '*CLSLTICHG' or
417aAC                             $psubcmd = '*CLSPRICHG' or
417aAC                             $psubcmd = '*CLSSSICHG' or
     C                             $psubcmd = '*ADJUST'   or
     C                             $psubcmd = '*ADJUSTORD' or
600bAC                             $psubcmd = '*ADJUSTOSS' or
610aAC                             $psubcmd = '*ADJUSTRTN' or
600cAC                             $psubcmd = '*CHGITEM'
     C                   eval      logit = *on
     C                   exsr      verifyqty
     C                   if        not error
     C                   exsr      savebefore
     C                   exsr      qtystock
     C                   endif

     C                   when      $psubcmd = '*UNLOCK'
     C                   eval      logit = *off
     C                   exsr      unlockitemqty

     C                   when      $psubcmd = '*VERIFYADD'
     C                   eval      logit = *off
     C                   exsr      verifygen
     C                   if        not error
     C                   exsr      verifyadd
     C                   endif

     C                   when      $psubcmd = '*VERIFYDEL'
     C                   eval      logit = *off
     C                   exsr      deleteitemqty

     C                   other
     C                   eval      logit = *on
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
     C                   exsr      getmsg

     C                   endsl

     C     bottom        tag

     *  Log it

     C                   if        logit
     C                   exsr      writelog
     C                   endif

     *  Unlock record if error occured.

     C                   if        error
     C                   exsr      unlockitemqty
     C                   endif

     *  We are finished so get out

     C                   eval      $pdata = $itemqty
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     *  Define key for ItemQty file.

     C     keyiq         klist
     C                   kfld                    $iqwhse
     C                   kfld                    $iqitem

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

     *  Flag inactive status codes ('A', 'Z' or 'V').

     C                   if        $iqstat <> 'A' and
     C                             $iqstat <> 'Z' and
416bMC                             $iqstat <> 'V'
600dDC**                           $iqstat <> 'XD'
     C                   eval      inactiveslot = *on
     C                   else
     C                   eval      inactiveslot = *off
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  additemqty  Add ItemQty record.
     *----------------------------------------------------------------

     C     additemqty    begsr

     *  Clear itemqty record.

     C                   clear                   iqrec

     *  Move information into slot fields.

     C                   eval      iqwhse = $iqwhse
     C                   eval      iqitem = $iqitem

     *  Add record

     C                   write(e)  iqrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Slot" command '
     C                                       + '('
     C                                       + %Trim(%editc(iqwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(iqitem)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endadditemqty
     C                   endif

     C     endadditemqty endsr

     *----------------------------------------------------------------
     *  calcqtys  Calculate itemqty quantities.
     *----------------------------------------------------------------

     C     calcqtys      begsr

     *  Calculate physical quantities.

     C                   eval      iqphy1 = iqstk1
     C                   eval      iqphy2 = iqstk2
     C                   eval      iqphy3 = iqstk3

     *  Calculate available quantities.

     *    Initialize to zero.

     C                   eval      iqavl1 = 0
     C                   eval      iqavl2 = 0
     C                   eval      iqavl3 = 0

     *    Add in stock.

     C                   if        iqstk1 > 0
     C                   eval      iqavl1 = iqstk1
     C                   endif

     C                   if        iqstk2 > 0
     C                   eval      iqavl2 = iqstk2
     C                   endif

     C                   if        iqstk3 > 0
     C                   eval      iqavl3 = iqstk3
     C                   endif

     *    Subtract allocated.

     C                   if        iqalc1 > 0
     C                   eval      iqavl1 = iqavl1 - iqalc1
     C                   endif

     C                   if        iqalc2 > 0
     C                   eval      iqavl2 = iqavl2 - iqalc2
     C                   endif

     C                   if        iqalc3 > 0
     C                   eval      iqavl3 = iqavl3 - iqalc3
     C                   endif

     *    Subtract held.

     C                   if        iqhld1 > 0
     C                   eval      iqavl1 = iqavl1 - iqhld1
     C                   endif

     C                   if        iqhld2 > 0
     C                   eval      iqavl2 = iqavl2 - iqhld2
     C                   endif

     C                   if        iqhld3 > 0
     C                   eval      iqavl3 = iqavl3 - iqhld3
     C                   endif

     *    Set negative available to zero.

     C                   if        iqavl1 < 0
     C                   eval      iqavl1 = 0
     C                   endif

     C                   if        iqavl2 < 0
     C                   eval      iqavl2 = 0
     C                   endif

     C                   if        iqavl3 < 0
     C                   eval      iqavl3 = 0
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  clearerrflags  Clear error flag fields.
     *----------------------------------------------------------------

     C     clearerrflags begsr

     C                   if        $iqwhsee = '1'
     C                   eval      $iqwhsee = '0'
     C                   endif

     C                   if        $iqiteme = '1'
     C                   eval      $iqiteme = '0'
     C                   endif

     C                   if        $iqstke  = '1'
     C                   eval      $iqstke  = '0'
     C                   endif

     C                   if        $iqalce  = '1'
     C                   eval      $iqalce  = '0'
     C                   endif

     C                   if        $iqhlde  = '1'
     C                   eval      $iqhlde  = '0'
     C                   endif

     C                   if        $iqtrie  = '1'
     C                   eval      $iqtrie  = '0'
     C                   endif

     C                   if        $iqtroe  = '1'
     C                   eval      $iqtroe  = '0'
     C                   endif

     C                   if        $iqorde  = '1'
     C                   eval      $iqorde  = '0'
     C                   endif

     C                   if        $iqadje  = '1'
     C                   eval      $iqadje  = '0'
     C                   endif

     C                   if        $iqorge  = '1'
     C                   eval      $iqorge  = '0'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  cvt2low   Convert quantities into lowest uom.
     *----------------------------------------------------------------

     C     cvt2low       begsr

     *  Initialize uom quantities.

     C                   if        $iqumq2 <= 0
     C                   eval      #umq2 = 1
     C                   else
     C                   eval      #umq2 = $iqumq2
     C                   endif

     C                   if        $iqumq3 <= 0
     C                   eval      #umq3 = 1
     C                   else
     C                   eval      #umq3 = $iqumq3
     C                   endif

     *  Converty available quantities to lowest uom quantitiy.

     C                   eval      lowavl = (iqavl1 * #umq2 * #umq3)
     C                                    + (iqavl2 * #umq3)
     C                                    + iqavl3

     *  Converty adjust quantities to lowest uom quantitiy.

     C                   eval      lowadj = ($iqadj1 * #umq2 * #umq3)
     C                                    + ($iqadj2 * #umq3)
     C                                    + $iqadj3

     C                   endsr

     *----------------------------------------------------------------
     *  deleteitemqty  Delete itemqty record.
     *----------------------------------------------------------------

     C     deleteitemqty begsr
     C                   eval      error = *off

     C*  Get and lock itemqty record.

     C                   if        $psubcmd = '*DELETE'
     C                   eval      lock = *on
     C                   else
     C                   eval      lock = *off
     C                   endif

     C                   exsr      getitemqty

     C                   if        error
     C                   goto      enddel
     C                   endif

     C*  Check for quantity.

     C                   if        iqstk1 <> 0 or
     C                             iqstk2 <> 0 or
     C                             iqstk3 <> 0 or
     C                             iqalc1 <> 0 or
     C                             iqalc2 <> 0 or
     C                             iqalc3 <> 0 or
     C                             iqtri1 <> 0 or
     C                             iqtri2 <> 0 or
     C                             iqtri3 <> 0 or
     C                             iqtro1 <> 0 or
     C                             iqtro2 <> 0 or
     C                             iqtro3 <> 0 or
     C                             iqord1 <> 0
     C                   eval      error = *on
     C                   exsr      unlockitemqty
     C                   eval      $preturn = 'DELQTYEXST'
     C                   exsr      getmsg
     C                   goto      enddel
     C                   endif

      *  Skip actual delete for *VERIFY.

     C                   if        $psubcmd = '*VERIFYDEL'
     C                   goto      enddel
     C                   endif

      *  Delete slot record.

     C                   eval      lockwhse = 0
     C                   eval      lockitem = '*none'

     C                   delete(e) iqrec
     C                   if        %error
     C                   eval      $preturn = 'DELERROR'
     C                   eval      $pmessage = 'Error on "Delete Item Qty" '
     C                                       + 'command '
     C                                       + '('
     C                                       + %Trim(%editc($iqwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($iqitem)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      enddel
     C                   endif

     C     enddel        endsr

     *----------------------------------------------------------------
     *  fixbrkdn  Fix breakdown quantities.
     *----------------------------------------------------------------

     C     fixbrkdn      begsr

     *  First make sure there are no negative available brkdn2/3 qtys.

     *    Breakdown 3 ...

 2B  C                   if        $iqumq3 > 0
 2B  C                   dow       iqavl3 < 0
     C                   eval      iqstk2 = iqstk2 - 1
     C                   eval      iqstk3 = iqstk3 + $iqumq3
     C                   eval      iqavl2 = iqavl2 - 1
     C                   eval      iqavl3 = iqavl3 + $iqumq3
 2E  C                   enddo
 2E  C                   endif

     *    Breakdown 2 ...

 2B  C                   if        $iqumq2 > 0
 2B  C                   dow       iqavl2 < 0
     C                   eval      iqstk1 = iqstk1 - 1
     C                   eval      iqstk2 = iqstk2 + $iqumq2
     C                   eval      iqavl1 = iqavl1 - 1
     C                   eval      iqavl2 = iqavl2 + $iqumq2
 2E  C                   enddo
 2E  C                   endif

     *  Now try to "up" available/stock quantities.

     *    Breakdown 3 ...

 2B  C                   if        $iqumq3 >= 0
 2B  C                   dow       iqavl3 > $iqumq3
     C                   eval      iqstk3 = iqstk3 - $iqumq3
     C                   eval      iqstk2 = iqstk2 + 1
     C                   eval      iqavl3 = iqavl3 - $iqumq3
     C                   eval      iqavl2 = iqavl2 + 1
 2E  C                   enddo
 2E  C                   endif

     *    Breakdown 2 ...

 2B  C                   if        $iqumq2 >= 0
 2B  C                   dow       iqavl2 > $iqumq2
     C                   eval      iqstk2 = iqstk2 - $iqumq2
     C                   eval      iqstk1 = iqstk1 + 1
     C                   eval      iqavl2 = iqavl2 - $iqumq2
     C                   eval      iqavl1 = iqavl1 + 1
 2E  C                   enddo
 2E  C                   endif
 2E
     C                   endsr

     *----------------------------------------------------------------
     *  getdatetime  Get current date & time
     *----------------------------------------------------------------

     C     getdatetime   begsr

     C                   time                    curtime

     C                   if        curtime < lasttime
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr

     *----------------------------------------------------------------
     *  getitemqty  Get itemqty info.
     *----------------------------------------------------------------

     C     getitemqty    begsr

     C                   eval      loopcount = 1
     C                   dow       forever = forever

     *    Get ItemQty record.

     C                   if        lock
     C                   if        lockwhse = $iqwhse and
     C                             lockitem = $iqitem
     C                   leave
     C                   else
     C     keyiq         chain     itemqty
     C                   endif
     C                   else
     C     keyiq         chain(n)  itemqty
     C                   endif

     *    If found, get out of loop and calculate quantities.

     C                   if        %found
     C                   if        lock
     C                   eval      lockwhse = iqwhse
     C                   eval      lockitem = iqitem
     C                   else
     C                   eval      lockwhse = 0
     C                   eval      lockitem = '*none'
     C                   endif
     C                   leave
     C                   endif

     *    If not found ...

     *      If first time through, try and create ItemQty record.

     C                   select
     C                   when      loopcount = 1
     C                   eval      loopcount = loopcount + 1
     C                   exsr      additemqty
     C                   iter

     *      Otherwise, bomb out with error.

     C                   other
     C                   eval      error = *on
     C                   eval      lockwhse = 0
     C                   eval      lockitem = '*none'
     C                   eval      $preturn = 'IQNOTFND'
     C                   exsr      getmsg
     C                   goto      endgetitemqty
     C                   endsl

     C                   enddo

     C                   exsr      calcqtys

     C     endgetitemqty endsr

     *----------------------------------------------------------------
     *  getmsg   Get message for error code.
     *----------------------------------------------------------------

     C     getmsg        begsr

     C                   select

     C                   when      $preturn = 'ADJNOTSNT'
     C                   eval      $pmessage = 'Adjust quantity not sent'

     C                   when      $preturn = 'BLANKITEM'
     C                   eval      $pmessage = 'Item number cannot be blank'

     C                   when      $preturn = 'DELQTYEXST'
     C                   eval      $pmessage = 'ItemQty not deleted - '
     C                                       + 'Quantity exists '
     C                                       + '('
     C                                       + %Trim(%editc($iqwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($iqitem)
     C                                       + ')'

     C                   when      $preturn = 'INVLDBRKDN'
     C                   eval      $pmessage = 'Breakdown qty sent w/o '
     C                                       + 'corresponding uom qty'

     C                   when      $preturn = 'INVLDSBCMD'
     C                   eval      $pmessage = 'Invalid subcommand '
     C                                       + '(' + %trim($psubcmd) + ') '
     C                                       + 'sent to ' + %trim(#prog)

     C                   when      $preturn = 'ITMNOTSNT'
     C                   eval      $pmessage = 'Item number must be sent'

     C                   when      $preturn = 'IQNOTFND'
     C                   eval      $pmessage = 'ItemQty record not found '
     C                                       + 'and could not be created '
     C                                       + '('
     C                                       + %Trim(%editc($iqwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($iqitem)
     C                                       + ')'

     C                   when      $preturn = 'WHSNOTSNT'
     C                   eval      $pmessage = 'Warehouse must be sent'

     C                   other
     C                   eval      $pmessage = %trim($preturn)
     C                                       + ': Unknown return code'

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  iq2ds  Move itemqty fields to data structure fields
     *----------------------------------------------------------------

     C     iq2ds         begsr

     C* Move information to data structure.

     C                   eval      $iqwhse = iqwhse
     C                   eval      $iqitem = iqitem
     C                   eval      $iqstk1 = iqstk1
     C                   eval      $iqstk2 = iqstk2
     C                   eval      $iqstk3 = iqstk3
     C                   eval      $iqalc1 = iqalc1
     C                   eval      $iqalc2 = iqalc2
     C                   eval      $iqalc3 = iqalc3
     C                   eval      $iqhld1 = iqhld1
     C                   eval      $iqhld2 = iqhld2
     C                   eval      $iqhld3 = iqhld3
     C                   eval      $iqtri1 = iqtri1
     C                   eval      $iqtri2 = iqtri2
     C                   eval      $iqtri3 = iqtri3
     C                   eval      $iqtro1 = iqtro1
     C                   eval      $iqtro2 = iqtro2
     C                   eval      $iqtro3 = iqtro3
     C                   eval      $iqord1 = iqord1
     C                   eval      $iqphy1 = iqphy1
     C                   eval      $iqphy2 = iqphy2
     C                   eval      $iqphy3 = iqphy3
     C                   eval      $iqavl1 = iqavl1
     C                   eval      $iqavl2 = iqavl2
     C                   eval      $iqavl3 = iqavl3

     C                   endsr

     *----------------------------------------------------------------
     *  qtyallocate  Update allocated quantities.
     *----------------------------------------------------------------

     C     qtyallocate   begsr
     C                   move      *off          error

     *  Extra verification ...

     *  Update quantities ...

     *    Apply fixes due to uping slot quantities.

     C                   exsr      qtyfix

     *    Update allocated quantities with adjustment quantities.

     *      Skip if an inactive status code was sent.
     *      Re: Inactive status codes already have the quantity allocated
     *          through the Hold bucket.

     C                   if        not inactiveslot
     C                   eval      iqalc1 = iqalc1 + $iqadj1
     C                   eval      iqalc2 = iqalc2 + $iqadj2
     C                   eval      iqalc3 = iqalc3 + $iqadj3
     C                   endif

     *    Update allocated quantities with original quantities.

     *      Skip if an inactive status code was sent.
     *      Re: Inactive status codes already have the quantity allocated
     *          through the Hold bucket.

     C                   if        not inactiveslot
     C                   if        $psubcmd = '*ALC2PCK' or
     C                             $psubcmd = '*PCK2ALC'
     C                   if        $iqorgu
     C                   eval      iqalc1 = iqalc1 - $iqorg1
     C                   eval      iqalc2 = iqalc2 - $iqorg2
     C                   eval      iqalc3 = iqalc3 - $iqorg3
     C                   endif
     C                   endif
     C                   endif

     *    Recalculate quantities.

     C                   exsr      calcqtys

     *    Update record.

     C                   exsr      updaterec
     C                   if        error
     C                   goto      endqtyalc
     C                   endif

     *  Move current quantities to data structure parameter fields.

     C                   exsr      iq2ds

     C     endqtyalc     endsr

     *----------------------------------------------------------------
     *  qtyclspick   Update allocated and stock quantities.
     *----------------------------------------------------------------

     C     qtyclspick    begsr
     C                   move      *off          error

     *  Extra verification ...

     *  Update quantities ...

     *    Apply fixes due to uping slot quantities.

     C                   exsr      qtyfix

     *    Reduce allocated quantities with original quantities.

     *      Skip if an inactive status code was not sent.

     C                   if        not inactiveslot
     C                   eval      iqalc1 = iqalc1 - $iqorg1
     C                   eval      iqalc2 = iqalc2 - $iqorg2
     C                   eval      iqalc3 = iqalc3 - $iqorg3
     C                   endif

     *    Reduce stock quantities with adjust quantities.

     C                   eval      iqstk1 = iqstk1 - $iqadj1
     C                   eval      iqstk2 = iqstk2 - $iqadj2
     C                   eval      iqstk3 = iqstk3 - $iqadj3

     *    Reduce hold qty if an inactive status code was sent.

     C                   if        inactiveslot
     C                   eval      iqhld1 = iqhld1 - $iqadj1
     C                   eval      iqhld2 = iqhld2 - $iqadj2
     C                   eval      iqhld3 = iqhld3 - $iqadj3
     C                   endif

     *    Recalculate quantities.

     C                   exsr      calcqtys

     *    Update record.

     C                   exsr      updaterec
     C                   if        error
     C                   goto      endqtyclspck
     C                   endif

     *  Move current quantities to data structure parameter fields.

     C                   exsr      iq2ds

     C     endqtyclspck  endsr

     *----------------------------------------------------------------
     *  qtyfix       Apply fix quantities from uping slot quantities.
     *----------------------------------------------------------------

     C     qtyfix        begsr

     C                   if        $iqfixu
     C                   eval      iqstk1 = iqstk1 + $iqfix1
     C                   eval      iqstk2 = iqstk2 + $iqfix2
     C                   eval      iqstk3 = iqstk3 + $iqfix3
     C                   endif

     C                   if        $iqfixu and inactiveslot
     C                   eval      iqhld1 = iqhld1 + $iqfix1
     C                   eval      iqhld2 = iqhld2 + $iqfix2
     C                   eval      iqhld3 = iqhld3 + $iqfix3
     C                   endif

     C                   endsr

416cA*----------------------------------------------------------------
416cA*  qtyhold   Update held quantities.
416cA*----------------------------------------------------------------
416cA
416cAC     qtyhold       begsr
     C                   move      *off          error

     *    Update hold qty with adj qty if an inactive status code was sent.

     C                   eval      iqhld1 = iqhld1 + $iqadj1
     C                   eval      iqhld2 = iqhld2 + $iqadj2
     C                   eval      iqhld3 = iqhld3 + $iqadj3

     *    Recalculate quantities.

     C                   exsr      calcqtys

     *    Update record.

     C                   exsr      updaterec
     C                   if        error
     C                   goto      endqtyhold
     C                   endif

     *  Move current quantities to data structure parameter fields.

     C                   exsr      iq2ds

     C     endqtyhold    endsr

     *----------------------------------------------------------------
     *  qtystock  Update stock/held quantities.
     *----------------------------------------------------------------

     C     qtystock      begsr
     C                   move      *off          error

     *  Extra verification ...

     *  Update quantities ...

     *    Apply fixes due to uping slot quantities.

     C                   exsr      qtyfix

     *    Update stock quantities with adjust quantity.

     C                   eval      iqstk1 = iqstk1 + $iqadj1
     C                   eval      iqstk2 = iqstk2 + $iqadj2
     C                   eval      iqstk3 = iqstk3 + $iqadj3

     *    Update hold qty with adj qty if an inactive status code was sent.

     C                   if        inactiveslot
     C                   eval      iqhld1 = iqhld1 + $iqadj1
     C                   eval      iqhld2 = iqhld2 + $iqadj2
     C                   eval      iqhld3 = iqhld3 + $iqadj3
     C                   endif

     *    Update stock quantities with original quantities.

     C                   if        $psubcmd = '*CLSRCV' or
417eAC                             $psubcmd = '*CLSRCVADJ' or
417aMC                             $psubcmd = '*CLSRTN' or
500 MC                             $psubcmd = '*STUFFIT' or
417aAC                             $psubcmd = '*CLSPUTAWY' or
500aAC                             $psubcmd = '*CLSSTGPUT' or
417aMC                             $psubcmd = '*CLSTFRIN' or
417aAC                             $psubcmd = '*CLSLETIN' or
417aAC                             $psubcmd = '*CLSPRIN' or
417aAC                             $psubcmd = '*CLSSSIN' or
417aAC                             $psubcmd = '*CLSTFICHG' or
417aAC                             $psubcmd = '*CLSLTICHG' or
417aAC                             $psubcmd = '*CLSPRICHG' or
417aAC                             $psubcmd = '*CLSSSICHG'
     C                   if        $iqorgu
     C                   eval      iqstk1 = iqstk1 - $iqorg1
     C                   eval      iqstk2 = iqstk2 - $iqorg2
     C                   eval      iqstk3 = iqstk3 - $iqorg3
     C                   endif
     C                   endif

     *    Update hold qty with org qty if an inactive status code was sent.

     C                   if        inactiveslot
     C                   if        $psubcmd = '*CLSRCV'  or
417eAC                             $psubcmd = '*CLSRCVADJ' or
417aMC                             $psubcmd = '*CLSRTN' or
500 AC                             $psubcmd = '*STUFFIT' or
417aAC                             $psubcmd = '*CLSPUTAWY' or
500aAC                             $psubcmd = '*CLSSTGPUT' or
417aMC                             $psubcmd = '*CLSTFRIN' or
417aAC                             $psubcmd = '*CLSLETIN' or
417aAC                             $psubcmd = '*CLSPRIN' or
417aAC                             $psubcmd = '*CLSSSIN' or
417aAC                             $psubcmd = '*CLSTFICHG' or
417aAC                             $psubcmd = '*CLSLTICHG' or
417aAC                             $psubcmd = '*CLSPRICHG' or
417aAC                             $psubcmd = '*CLSSSICHG'
     C                   if        $iqorgu
     C                   eval      iqhld1 = iqhld1 - $iqorg1
     C                   eval      iqhld2 = iqhld2 - $iqorg2
     C                   eval      iqhld3 = iqhld3 - $iqorg3
     C                   endif
     C                   endif
     C                   endif

     *    Recalculate quantities.

     C                   exsr      calcqtys

     *    Update record.

     C                   exsr      updaterec
     C                   if        error
     C                   goto      endqtystk
     C                   endif

730aAc*  Recalculate item qty if quantites go negative.
730aAc                   if        iqstk1 < 0
730aAc                             or iqstk2 < 0
730aAc                             or iqstk3 < 0
730aAc                             or iqhld1 < 0
730aAc                             or iqhld2 < 0
730aAc                             or iqhld3 < 0
730aAc                             or iqalc1 < 0
730aAc                             or iqalc2 < 0
730aAc                             or iqalc3 < 0
730aAc                             or iqtri1 < 0
730aAc                             or iqtri2 < 0
730aAc                             or iqtri3 < 0
730aAc                             or iqtro1 < 0
730aAc                             or iqtro2 < 0
730aAc                             or iqtro3 < 0
730aAc                   eval      whse = $iqwhse
730aAC                   call      'UT812'
730aAc                   parm                    whse             15 5
730aAc                   parm                    $iqitem
730aAc                   parm                    type              1
730aAc                   parm                    p1               10
730aAc                   parm                    p2                8
730aAc                   parm                    p3                4
750aAC                   call      'UT812'
750aAc                   parm                    whse             15 5
750aAc                   parm      '*CLOSE'      $iqitem
750aAc                   parm                    type              1
750aAc                   parm                    p1               10
750aAc                   parm                    p2                8
750aAc                   parm                    p3                4
730aAC                   endif

     *  Move current quantities to data structure parameter fields.

     C                   exsr      iq2ds
      *

     C     endqtystk     endsr

     *----------------------------------------------------------------
     *  savebefore   Save before image of itemqty.
     *----------------------------------------------------------------

     C     savebefore    begsr

     *  Move information about itemqty into ds fields.

     C                   exsr      iq2ds

     *  Save as before image.

     C                   eval      $iqtybefore = $itemqty

     *  Restore original input (saved at beginning of program).

     C                   eval      $itemqty = $iqtyinput

     C                   endsr

     *----------------------------------------------------------------
     *  unlockitemqty  Unlock itemqty record.
     *----------------------------------------------------------------

     C     unlockitemqty begsr

     C                   if        lockitem <> '*none'
     C                   unlock    itemqty
     C                   endif

     C                   if        %error
     C                   endif

     C                   eval      lockwhse = 0
     C                   eval      lockitem = '*none'

     C                   endsr

     *----------------------------------------------------------------
     *  updaterec    Update ItemQty record.
     *----------------------------------------------------------------

     C     updaterec     begsr

     *  Update record.

     C                   update(e) iqrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'IQUPDERR'
     C                   eval      $pmessage = 'Error updating ItemQty '
     C                                       + '('
     C                                       + %Trim($psubcmd)
     C                                       + '/'
     C                                       + %Trim(%editc($iqwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($iqitem)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   endif

     *  Clear "lock" flags.

     C                   eval      lockwhse = 0
     C                   eval      lockitem = '*none'

     C                   endsr

     *----------------------------------------------------------------
     *  verifyadd  Verify slot information when adding.
     *----------------------------------------------------------------

     C     verifyadd     begsr

     *  Item cannot be blank.

     C                   if        $iqitem = ' '
     C                   eval      error = *on
     C                   eval      $iqiteme = '1'
     C                   eval      $preturn = 'BLANKITEM'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     C     endvfyadd     endsr

     *----------------------------------------------------------------
     *  verifygen   General verification.
     *----------------------------------------------------------------

     C     verifygen     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $iqwhseu
     C                   eval      error = *on
     C                   eval      $iqwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif

     *  Item must be sent.

     C                   if        not $iqitemu
     C                   eval      error = *on
     C                   eval      $iqiteme = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen
     C                   endif

     *  Verify warehouse.

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $iqwhse       $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $iqwhsee = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $iqwhsee = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen

     C                   endsl

     C     endvfygen     endsr

     *----------------------------------------------------------------
     *  verifyqty  Verify information when changing quantities.
     *----------------------------------------------------------------

     C     verifyqty     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $iqwhseu
     C                   eval      error = *on
     C                   eval      $iqwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyqty
     C                   endif

     *  Item must be sent.

     C                   if        not $iqitemu
     C                   eval      error = *on
     C                   eval      $iqiteme = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyqty
     C                   endif

     *  Adjust quantity must be sent.

     C                   if        not $iqadju
     C                   eval      error = *on
     C                   eval      $iqadje = '1'
     C                   eval      $preturn = 'ADJNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfyqty
     C                   endif

     *    Breakdown quantities sent must have corresponding uom quantity.

416cMC                   if        $iqadj2 <> 0 and $iqumq2 <= 0 or
416cMC                             $iqadj3 <> 0 and $iqumq3 <= 0
     C                   eval      error = *on
     C                   eval      $iqadje = '1'
     C                   eval      $preturn = 'INVLDBRKDN'
     C                   exsr      getmsg
     C                   goto      endvfyqty
     C                   endif

     *  Get & lock itemqty record.

     C                   eval      lock = *on
     C                   exsr      getitemqty
     C                   if        error
     C                   eval      error = *on
     C                   eval      $iqiteme = '1'
     C                   goto      endvfyqty
     C                   endif

     C     endvfyqty     endsr

     *----------------------------------------------------------------
     *  verifyqty2 Verify information when changing quantities.
     *----------------------------------------------------------------

     C     verifyqty2    begsr

     *    Breakdown quantities sent must have corresponding uom quantity.

     C                   if        $iqalc2 <> 0 and $iqumq2 <= 0 or
     C                             $iqalc3 <> 0 and $iqumq3 <= 0
     C                   eval      error = *on
     C                   eval      $iqadje = '1'
     C                   eval      $preturn = 'INVLDBRKDN'
     C                   exsr      getmsg
     C                   goto      endvfyqty2
     C                   endif

     C     endvfyqty2    endsr

     *----------------------------------------------------------------
     *  writelog    Write record to log file
     *----------------------------------------------------------------

     C     writelog      begsr

     * Get next sequence number to use.

     C     *dtaara       define    logiqty#      nextseq#
     C     *lock         in        nextseq#
     C                   eval      lgiqtyseq# = nextseq#
     C                   if        nextseq# = 9999999
     C                   eval      nextseq# = 1
     C                   else
     C                   eval      nextseq# = nextseq# + 1
     C                   endif

     * Initialize log fields.

     C                   exsr      getdatetime

     C                   eval      lgiqtydate = curdate
     C                   eval      lgiqtytime = curtime
     C                   eval      lgiqtyscmd = $psubcmd
     C                   eval      lgiqtypgm  = $pprogram

     * Write log record.

     C                   select

     *   Single record if error occured during update.

     C                   when      error
     C                   eval      lgiqtytype = 'ER'
     C                   eval      lgiqtyrtn  = $preturn
     C                   eval      lgiqtymsg  = $pmessage
     C                   eval      lgiqtydata = $itemqty
     C                   write(e)  lgiqtyrec
     C                   if        %error
     C                   endif

     *   Single record for *ADD.

     C                   when      $psubcmd = '*ADD'
     C                   eval      lgiqtytype = 'PT'
     C                   eval      lgiqtyrtn  = $preturn
     C                   eval      lgiqtymsg  = $pmessage
     C                   eval      lgiqtydata = $itemqty
     C                   write(e)  lgiqtyrec
     C                   if        %error
     C                   endif

     *   Single record for *DELETE.

     C                   when      $psubcmd = '*DELETE'
     C                   eval      lgiqtytype = 'DL'
     C                   eval      lgiqtyrtn  = $preturn
     C                   eval      lgiqtymsg  = $pmessage
     C                   eval      lgiqtydata = $itemqty
     C                   write(e)  lgiqtyrec
     C                   if        %error
     C                   endif

     *   Before/After records for everything else.

     C                   other
     C                   eval      lgiqtytype = 'UB'
     C                   eval      lgiqtyrtn  = $preturninput
     C                   eval      lgiqtymsg  = $pmessageinput
     C                   eval      lgiqtydata = $iqtybefore
     C                   write(e)  lgiqtyrec
     C                   if        %error
     C                   endif
     C                   eval      lgiqtyseq# = nextseq#
     C                   if        nextseq# = 9999999
     C                   eval      nextseq# = 1
     C                   else
     C                   eval      nextseq# = nextseq# + 1
     C                   endif
     C                   eval      lgiqtytype = 'UP'
     C                   eval      lgiqtyrtn  = $preturn
     C                   eval      lgiqtymsg  = $pmessage
     C                   eval      lgiqtydata = $itemqty
     C                   write(e)  lgiqtyrec
     C                   if        %error
     C                   endif

     C                   endsl

     * Update sequence number to use.

     C                   out       nextseq#

     C                   endsr
