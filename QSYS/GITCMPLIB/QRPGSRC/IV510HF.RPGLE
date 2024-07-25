      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  IV510     Post inventory counts - Update slot qtys
     *  05 March 1996
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program needs to be compiled with DEFER=*NO so the status
     *    messages can be displayed.
     *
     *    This program uses a revised method to display error messages.
     *    Instead of the program writting each message to the subfile
     *    using the message key the subfile has been revised to display
     *    all messages from the program message queue automatically.
     *
     *  Revisions
     *
408 A*    01/09/98 RH   4.08
     *      - If only exporting aisle partial inventory and item in
     *        slot changed, write existing slot item to BFRSLOT file.
412 A*    08/27/99  RH   4.12
     *      - Create label rec. type I, Status C, for item
     *        inventoried in slot and item replaced in slot.
414aA*    05/11/00  RH   4.14a
     *      - Create adjustment record for aisle cycle count.
     *      - Call program to recalculate the the item.
414bA*    09/07/00  RH   4.14b
     *      - Revised to check for corresponding SSB record. If one
     *        exists, two records are written to ITEMADJ.
414cA*    09/07/00  RH   4.14c
     *      - Use ship weight for catch weight item adjust. record.
414dA*    10/24/00  RH   4.14d
     *      - Do not set status to Z if slot is reserved.(UPSTAT)
415aA*    07/12/01  RH   4.15a
     *      - Fix to update ITEMQTY, use AJQTY not IAQTY.
415bA*    07/27/01  RH   4.15b
     *      - Fix to not zero IACWT field after caculated.
415cA*    07/27/01  RH   4.15c
     *      - If cycle count, write label rec with type 'A' and
     *        adjustment quantity, else write rec with type 'I'
     *        and inventory quantity.
416aA*    08/27/01  RH   4.16a
     *      - Fix - write label record for breakdown item.
416 A*  09/25/01    RH   4.16
     *    - Recompile - INVSLOT file changed.
416bA*    12/16/01  DAS  4.16b
     *      - Revised to deal with divide by zero error that occured.
     *      - Added routine ZZZUMQ to set ITUM quantities to 1 when
     *        they are zero to prevent error second time around.
     *      - Calling new routine after every chain to PIRITEM.
416cA*    03/04/02  RH   4.16c
     *      - Fix to process when old slot item # is invalid.
416dA*    09/17/02  RH   4.16d
     *      - Change to process cycle count by department.
417aA*    07/08/04  RH   4.17a
     *      - Fix: If breakdown qty being used in calculation is
     *        0, set to one to prevent data decimal error.
510aA*    07/07/06  RH   5.10a
     *      - Fix: Change to Zero slot Reserve = 'N', was setting
     *        empty virutal pick slots to 'Z'.
510bA*    11/30/06  RH   5.10b
     *      - Fix: Change to calc CW if AJQTY1 <> 0. was not creating
     *        negative CW if item was removed from slot.
510cA*    02/23/07  RH   5.10c
     *      - Fix: Change to total CW when calculated for case and ea.
510dA*    12/28/07  RH   5.10d
     *      - Fix: Change to not zero Pick slots, normal or virutal.
520aA*    05/02/08  RH   5.20a
     *      - Enh: Update status to Z for empty overflow, not speical order.
     *
600aA*    05/11/09  DAS  6.00a  P#00045
     *      - License tracking
530aA*    01/05/10  RH   5.30a
     *      - Fix: 510c change was using wrong field for calculated   order.
     *        catch weight.                                           order.
640aA*    06/15/12  RH   6.40a
     *      - Enh: Add inventory page # to item adjustment memo field order.
640bA*    09/06/12  RH   6.40b
     *      - Enh: Update status to 'Z' for empty virtual Quarantine. order.
     *
     *----------------------------------------------------------------
     *    CUSTOM
JOR1A*    07/07/06  RH   JOR1
     *      -  Enh: Revised to Zero special order item pick slots
     *         if item number is 6 characters long and not an E.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  78        Chain indicator
     *  79        Chain indicator
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fiv505fm   cf   e             workstn usropn
     Finvslot   if   e           k disk
     Fpiritem   if   e           k disk
     Fslot1     uf   e           k disk
408 AFinvbslt   o  a e           k disk
412 AFLabel     o  a e           k disk
414 AFitemadj   o  a e           k disk
HAL  Finvsdate  uf   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.drislot

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($slver#)

510aA*----------------------------------------------------------------
510aA*  Customer id
510aA*
510aA /COPY QCOPYSRC,ID#JORDANO

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
JOR1AD                 ds
JOR1AD  itpos6                 6      6
JOR1AD  slitem                 1     15
JOR1A*
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  erwhse                 1      2p 0
     D  erwhdp                 3      7
     D  erstyp                 8     12
     D                 ds
     D  $ec                    1      2p 0
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
600aAD  #curruser            358    367
     *----------------------------------------------------------------
     *  Variables
     *
HAL  D fifolcns        s             15
HAL  D fifoOlcns       s             15
HAL  D slotentd        s                   like($slentd)
HAL  D slotprty        s                   like($slprty)
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D ajqty1          s              5  0
     D ajqty2          s              5  0
     D ajqty3          s              5  0
     D brkqty          s              5  0
     D brkwgt          s              6  3
     D curdte          s              8  0
     D curtim          s              6  0
     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2
     D forevr          s              1
     D lststp          s              1
     D lstwhd          s              5
     D lstwhs          s              3  0
640aAD oamemo          s             14
     D tacwta          s              9  2
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *POSTINV - Posting inventory counts first time.
     *              *RESTART - Restarting abnormally ended batch.
     *      $PWHSE  Warehouse
     *      $PBAT   Batch number
     *      $PJOBQ  Running from JOBQ (Y,N)
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message sent to pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pbat             7 0
     C                   parm                    $pwhse            3 0
416d C                   parm                    $pwhdp            5
     C                   parm                    $pjobq            1
     C                   parm                    $prtn             8
408 AC                   parm                    $ppexp            1
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      $prtn = *blanks
640aAC                   eval      oamemo = 'Inv Pg#: '

      /free

         // Get employee #

         getUser(#curruser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

      /end-free
     *
     C     keyivs        setll     invslot
     C                   dou       forevr <> forevr
     *
416d C     try1          tag
     C     keyivs        reade     invslot                                79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        not *in79  and
     C                             $pwhdp <> '*ALL'  and
     C                             ivswhd <> $pwhdp
     C                   goto      try1
     C                   endif
     *
     *  Keep user informed.
     *
     C                   if        slwhse <> lstwhs  or
     C                             slwhdp <> lstwhd  or
     C                             slstyp <> lststp
     C                   eval      erwhse = slwhse
     C                   eval      erwhdp = slwhdp
     C                   if        slstyp = 'P'
     C                   eval      erstyp = 'PIR  '
     C                   else
     C                   eval      erstyp = 'FIXED'
     C                   endif
     C                   exsr      zm21
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   eval      lstwhs = slwhse
     C                   eval      lstwhd = slwhdp
     C                   eval      lststp = slstyp
     C                   endif
     *
     C     keysl1        chain     slot1                              78
     C                   if        *in78
     C                   iter
     C                   endif
408 A*
408 A*    If only exporting items for partial inventory,
408 A*     and item changed, write into to BFRSLOT file.
408 A*
408 AC                   if        ivspex = 'Y'  and
408 AC                             ivsitm <> slitem
408 AC                   eval      ibswhs = slwhse
408 AC                   eval      ibsdsp = sldisp
408 AC                   eval      ibswhd = slwhdp
408 AC                   eval      ibsasl = slaisl
408 AC                   eval      ibsloc = slloc
408 AC                   eval      ibslvl = slrlvl
408 AC                   eval      ibshnd = slhand
408 AC                   eval      ibssid = slside
408 AC                   eval      ibsstp = slstyp
408 AC                   eval      ibsitm = slitem
408 AC                   eval      ibsqt1 = slstk1
408 AC                   eval      ibsqt2 = slstk2
408 AC                   eval      ibsqt3 = slstk3
408 AC                   write     ibsrec
408 AC                   endif
412 A*
412 A*    If item changed in slot, create label rec for replaced item.
412 A*    Normal UOM
412 A*
412 AC                   if        ivsitm <> slitem
412 AC     keyit         chain     piritem                            75
416bAC                   exsr      zzzumq
412 A*
412 AC                   clear                   lbrec
412 AC                   eval      lbwhse = $pwhse
412 AC                   eval      lbwhdp = slwhdp
412 AC                   eval      lbaisl = slaisl
412 AC                   eval      lbloc = slloc
412 AC                   eval      lbrlvl = slrlvl
412 AC                   eval      lbhand = slhand
412 AC                   eval      lbpseq = slpseq
412 AC                   eval      lbstyp = slstyp
412 AC                   if        slstyp = 'P'
412 AC                   eval      lbqryf = 1
412 AC                   else
412 AC                   eval      lbqryf = 0
412 AC                   endif
412 AC                   eval      lbdisp = sldisp
412 AC                   eval      lbitem = slitem
412 AC                   eval      lbseq = 0
412 AC                   eval      lbpbat = 0
412 AC                   eval      lbpo = *blanks
412 AC                   eval      lbord = 0
412 AC                   eval      lbutyp = 'N'
412 AC                   eval      lbucod = *blanks
412 AC                   if        not *in75
412 AC                   eval      lbucod = itum1
412 AC                   endif
412 AC                   eval      lbqalc = 0
412 AC                   eval      lbqpck = slstk1 * -1
412 A*                    Z-ADDSLSTK1    LBQPCK
412 AC                   eval      lbucub = 0
412 AC                   eval      lbcube = 0
412 AC                   eval      lbuwgt = 0
412 AC                   eval      lbswgt = 0
412 AC                   eval      lbtie = 0
412 AC                   eval      lbhigh = 0
412 AC                   eval      lbtrn# = 0
412 AC                   call      'PIRLBL#'
412 AC                   parm                    lblbl#
415cA*  Label type for aisle cycle count or inventory
415cAC                   if        ivsadj <> ' '
415cAC                   eval      lbtype = 'A'
415cAC                   else
415cAC                   eval      lbtype = 'I'
415cAC                   endif
412DA*                    MOVE @PGRP1    LBGRP1
412 AC                   eval      lbgrp1 = *blanks
412 AC                   eval      lbgrp2 = *blanks
415cD*                    MOVE 'I'       LBTYPE
412 AC                   eval      lbstat = 'C'
412 AC                   eval      lbsdte = curdte
412 AC                   eval      lbstim = curtim
412 AC                   eval      lbrdte = curdte
412 AC                   write     lbrec
412 A*
412 A*    BRK1 UOM
412 AC                   if        slstk2 <> 0
412 AC                   eval      lbqpck = slstk2 * -1
412 AC                   call      'PIRLBL#'
412 AC                   parm                    lblbl#
415cA*  Label type for aisle cycle count or inventory
415cAC                   if        ivsadj <> ' '
415cAC                   eval      lbtype = 'A'
415cAC                   else
415cAC                   eval      lbtype = 'I'
415cAC                   endif
412 D*                    MOVE @PGRP1    LBGRP1
412 AC                   eval      lbgrp1 = *blanks
412 AC                   eval      lbgrp2 = *blanks
412 AC                   eval      lbutyp = *on
412 AC                   eval      lbucod = *blanks
412 AC                   if        not *in75
412 AC                   eval      lbucod = itum2
412 AC                   endif
415cD*                    MOVE 'I'       LBTYPE
412 AC                   eval      lbstat = 'C'
412 AC                   eval      lbsdte = curdte
412 AC                   eval      lbstim = curtim
412 AC                   eval      lbrdte = curdte
412 AC                   write     lbrec
412 AC                   endif
412 A*
412 A*    BRK2 UOM
412 AC                   if        slstk3 <> 0
412 AC                   eval      lbqpck = slstk3 * -1
412 AC                   call      'PIRLBL#'
412 AC                   parm                    lblbl#
415cA*  Label type for aisle cycle count or inventory
415cAC                   if        ivsadj <> ' '
415cAC                   eval      lbtype = 'A'
415cAC                   else
415cAC                   eval      lbtype = 'I'
415cAC                   endif
412 D*                    MOVE @PGRP1    LBGRP1
412 AC                   eval      lbgrp1 = *blanks
412 AC                   eval      lbgrp2 = *blanks
412 AC                   eval      lbutyp = '2'
412 AC                   eval      lbucod = *blanks
412 AC                   if        not *in75
412 AC                   eval      lbucod = itum3
412 AC                   endif
415cD*                    MOVE 'I'       LBTYPE
412 AC                   eval      lbstat = 'C'
412 AC                   eval      lbsdte = curdte
412 AC                   eval      lbstim = curtim
412 AC                   eval      lbrdte = curdte
412 AC                   write     lbrec
412 AC                   endif
414aA*    Create adjustment record for replaced item.
414aA*
414aA*
414aAC                   if        ivsadj <> ' '
510cAC                   eval      tacwta = 0
416cAC                   eval      $grtn = *blanks
416cA*     Only process for valid item #.
416cAC                   if        not *in75
    A*
414bA*     Get corresponding SSB item if one exists.
414bA*
414bAC                   call      'GETSSB'
414bAC                   parm      itwhse        $gwhse            3 0
414bAC                   parm      ititem        $gitem           15
414bAC                   parm                    $gssb            15
414bAC                   parm                    $gdesc           30
414bAC                   parm                    $gpdsc           15
414bAC                   parm                    $gwhdp            5
414bAC                   parm                    $gstyp            1
414bAC                   parm                    $gum              2
414bAC                   parm                    $gum2             2
414bAC                   parm                    $gumq2            3 0
414bAC                   parm                    $gum3             2
414bAC                   parm                    $gumq3            3 0
414bAC                   parm                    $grtn             8
416cAC                   endif
414bA*
414bA*       When SSB item exists.
414bA*
414bAC                   select
414bAC                   when      $grtn = '*FOUND  '
414b *       Write adjustment for base item.
414bAC                   eval      iawhse = itwhse
414bAC                   eval      iaitem = ititem
414aAC                   eval      iadate = curdte
414aAC                   eval      iatime = curtim
414aAC                   movel     'INV'         iaby
414aAC                   eval      iawhdp = slwhdp
414aAC                   eval      iadisp = sldisp
414cAC                   if        itcwgt = 'Y'
414cAC     itswgt        mult      slstk1        iacwta
414cAC                   eval      iacwta = iacwta * -1
414cAC                   else
414cAC                   eval      iacwta = 0
414cAC                   endif
414bAC                   eval      iaqty1 = slstk1 * -1
414bAC                   eval      iaqty2 = 0
414bAC                   eval      iaqty3 = 0
414bAC                   eval      iacode = ivsadj
640aAC                   move      ivspag        oamemo
640aAC                   move      oamemo        iamemo
414bAC                   write     iarec
414b *       Write adjustment for breakdown item.
414bAC                   eval      iawhse = itwhse
414bAC                   eval      iaitem = $gssb
414bAC                   eval      iadate = curdte
414bAC                   eval      iatime = curtim
414bAC                   movel     'INV'         iaby
414bAC                   eval      iawhdp = slwhdp
414bAC                   eval      iadisp = sldisp
414bAC                   eval      iacwta = 0
414cAC                   if        itcwgt = 'Y'
414cAC                   eval      brkwgt = 0
414cAC                   eval      brkqty = 0
414cAC     itswgt        div       itumq2        brkwgt
414cAC                   if        itumq3 <> 0
414cAC     brkwgt        div       itumq3        brkwgt
414cAC                   endif
414cAC                   if        itumq3 <> 0
 14cAC     slstk2        mult      itumq3        brkqty
414cAC     brkqty        add       slstk3        brkqty
414cAC                   else
414cAC                   eval      brkqty = slstk2
414cAC                   endif
414c *
414cAC     brkwgt        mult      brkqty        iacwta
414cAC                   eval      iacwta = iacwta * -1
414cAC                   else
414cAC                   eval      iacwta = 0
414cAC                   endif
414c *
414bAC                   eval      iaqty1 = slstk2 * -1
414bAC                   eval      iaqty2 = slstk3 * -1
414bAC                   eval      iaqty3 = 0
414bAC                   eval      iacode = ivsadj
640aAC                   move      ivspag        oamemo
640aAC                   move      oamemo        iamemo
414bAC                   write     iarec
414b *
414b *       When SSB item does not exist.
414b *
414bAC                   other
414bAC                   clear                   iarec
414bAC                   eval      iawhse = $pwhse
416cMC                   eval      iaitem = slitem
416cD**                   MOVE ITITEM    IAITEM
414bAC                   eval      iadate = curdte
414bAC                   eval      iatime = curtim
414bAC                   movel     'INV'         iaby
414bAC                   eval      iawhdp = slwhdp
414bAC                   eval      iadisp = sldisp
414c *
416c *       Only process for valid item.
414cAC                   if        itcwgt = 'Y'  and
416cAC                             not *in75
414cA*
414cAC                   if        slstk1 > 0
510cAC     itswgt        mult      slstk1        tacwta
530aDC*                  eval      tacwta = iacwta * -1
530aMC                   eval      tacwta = tacwta * -1
510cAC     iacwta        add       tacwta        iacwta
510cD*          ITSWGT    MULT SLSTK1    IACWTA
510cD*          IACWTA    MULT -1        IACWTA
414cAC                   endif
414c *
414cAC                   if        slstk2 > 0
414cAC                   eval      brkwgt = 0
414cAC     itswgt        div       itumq2        brkwgt
510cAC                   eval      tacwta = brkwgt * slstk2
530aDC*                  eval      tacwta = iacwta * -1
530aMC                   eval      tacwta = tacwta * -1
510cAC     iacwta        add       tacwta        iacwta
510cD*          BRKWGT    MULT SLSTK2    IACWTA
510cD*          IACWTA    MULT -1        IACWTA
414cAC                   endif
414c *
414cAC                   if        slstk3 > 0
414cAC                   eval      brkwgt = 0
414cAC     itswgt        div       itumq2        brkwgt
414cAC     brkwgt        div       itumq3        brkwgt
510cAC                   eval      tacwta = brkwgt * slstk3
530aDC*                  eval      tacwta = iacwta * -1
530aMC                   eval      tacwta = tacwta * -1
510cAC     iacwta        add       tacwta        iacwta
510cD*          BRKWGT    MULT SLSTK3    IACWTA
510cA*          IACWTA    MULT -1        IACWTA
414cAC                   endif
414c *
414cAC                   else
414cAC                   eval      iacwta = 0
414cAC                   endif
414c *
414bAC                   eval      iaqty1 = slstk1 * -1
414bAC                   eval      iaqty2 = slstk2 * -1
414bAC                   eval      iaqty3 = slstk3 * -1
414bAC                   eval      iacode = ivsadj
640aAC                   move      ivspag        oamemo
640aAC                   move      oamemo        iamemo
414bAC                   write     iarec
414b *
414bAC                   endsl
     *
414aA*
414aA*  Update general quantities for item.
414aA*
416c *       Only process for valid item.
416cAC                   if        not *in75
414aAC                   eval      $acmd = '*STOCK  '
414aAC                   eval      $aprg = #prog
414aAC                   eval      $atype = '*INTER  '
414aAC                   eval      $awhse = $pwhse
414aAC                   eval      $aitem = ititem
414aAC                   eval      $aqty1 = iaqty1
414aAC                   eval      $aqty2 = iaqty2
414aAC                   eval      $aqty3 = iaqty3
414aAC                   call      'ADJQTY'
414aAC                   parm                    $acmd             8
414aAC                   parm                    $aprg            10
414aAC                   parm                    $atype            8
414aAC                   parm                    $awhse            3 0
414aAC                   parm                    $aitem           15
414aAC                   parm                    $aqty1            7 0
414aAC                   parm                    $aqty2            7 0
414aAC                   parm                    $aqty3            7 0
414aAC                   parm                    $artq1            7 0
414aAC                   parm                    $artq2            7 0
414aAC                   parm                    $artq3            7 0
414aAC                   parm                    $artn             8
414aAC                   parm                    $aerm
416cAC                   endif
416cA*
414aAC                   endif
414aA*
412 AC                   endif
     *
414aA*    Calculate item adjustment quantity for inventoried item.
414aAC                   eval      ajqty1 = 0
414aAC                   eval      ajqty2 = 0
414aAC                   eval      ajqty3 = 0
     *    If inventoried item changed.
414aAC                   if        ivsitm <> slitem
414aAC                   eval      ajqty1 = ivsqt1
414aAC                   eval      ajqty2 = ivsqt2
414aAC                   eval      ajqty3 = ivsqt3
414aAC                   else
414aAC                   eval      ajqty1 = ivsqt1 - slstk1
414aAC                   eval      ajqty2 = ivsqt2 - slstk2
414aAC                   eval      ajqty3 = ivsqt3 - slstk3
414aAC                   endif
     *
     *
     *    Update item number and quantities.
     *
     C                   eval      slitem = ivsitm
     C                   eval      slstk1 = ivsqt1
     C                   eval      slstk2 = ivsqt2
     C                   eval      slstk3 = ivsqt3
     *
     *    Update slot status code.
     *
     C                   exsr      upstat
     *
     *    Up breakdown quantities.
     *
     C                   if        slitem <> ' '  and
     C                             slstat <> 'Z'  and
     C                             slstat <> 'V'
     C                   exsr      upqty
     C                   endif
     *
     *    Update slot record.
     *
     C                   update    slrec
600aA
600aA*    Call program to sync slot and licenses.
600aA
600aAC                   exsr      synclcns
HAL A*
HAL A*    At this point if we have a date entered need to setfifo
HAL A*
HAL AC                   exsr      setfifo
412 A*
412 A*    Create label rec for inventoried item.
412 A*    Normal UOM
412 A*
412 AC     keyit         chain     piritem                            75
416bAC                   exsr      zzzumq
412 A*
412 AC                   clear                   lbrec
412 AC                   eval      lbwhse = $pwhse
412 AC                   eval      lbwhdp = slwhdp
412 AC                   eval      lbaisl = slaisl
412 AC                   eval      lbloc = slloc
412 AC                   eval      lbrlvl = slrlvl
412 AC                   eval      lbhand = slhand
412 AC                   eval      lbpseq = slpseq
412 AC                   eval      lbstyp = slstyp
412 AC                   if        slstyp = 'P'
412 AC                   eval      lbqryf = 1
412 AC                   else
412 AC                   eval      lbqryf = 0
412 AC                   endif
412 AC                   eval      lbdisp = sldisp
412 AC                   eval      lbitem = slitem
412 AC                   eval      lbseq = 0
412 AC                   eval      lbpbat = 0
412 AC                   eval      lbpo = *blanks
412 AC                   eval      lbord = 0
412 AC                   eval      lbutyp = 'N'
412 AC                   eval      lbucod = *blanks
412 AC                   if        not *in75
412 AC                   eval      lbucod = itum1
412 AC                   endif
412 AC                   eval      lbqalc = 0
412 A*          SLSTK1    MULT -1        LBQPCK
415cD*                    Z-ADDSLSTK1    LBQPCK
412 AC                   eval      lbucub = 0
412 AC                   eval      lbcube = 0
412 AC                   eval      lbuwgt = 0
412 AC                   eval      lbswgt = 0
412 AC                   eval      lbtie = 0
412 AC                   eval      lbhigh = 0
412 AC                   eval      lbtrn# = 0
412 AC                   call      'PIRLBL#'
412 AC                   parm                    lblbl#
415cA*  Label type for aisle cycle count or inventory
415cAC                   if        ivsadj <> ' '
415cAC                   eval      lbtype = 'A'
415cAC                   eval      lbqpck = ajqty1
415cAC                   else
415cAC                   eval      lbtype = 'I'
415cAC                   eval      lbqpck = slstk1
415cAC                   endif
412 D*                    MOVE @PGRP1    LBGRP1
412 AC                   eval      lbgrp1 = *blanks
412 AC                   eval      lbgrp2 = *blanks
415cD*                    MOVE 'I'       LBTYPE
412 AC                   eval      lbstat = 'C'
412 AC                   eval      lbsdte = curdte
412 AC                   eval      lbstim = curtim
412 AC                   eval      lbrdte = curdte
412 AC                   write     lbrec
412 A*
412 A*    BRK1 UOM
412 AC                   if        slstk2 <> 0  or
416aAC                             ajqty2 <> 0
415cD*                    Z-ADDSLSTK2    LBQPCK
412 A*          SLSTK2    MULT -1        LBQPCK
412 AC                   call      'PIRLBL#'
412 AC                   parm                    lblbl#
415cA*  Label type for aisle cycle count or inventory
415cAC                   if        ivsadj <> ' '
415cAC                   eval      lbtype = 'A'
415cAC                   eval      lbqpck = ajqty2
415cAC                   else
415cAC                   eval      lbtype = 'I'
415cAC                   eval      lbqpck = slstk2
415cAC                   endif
412 D*                    MOVE @PGRP1    LBGRP1
412 AC                   eval      lbgrp1 = *blanks
412 AC                   eval      lbgrp2 = *blanks
412 AC                   eval      lbutyp = *on
412 AC                   eval      lbucod = *blanks
412 AC                   if        not *in75
412 AC                   eval      lbucod = itum2
412 AC                   endif
415cD*                    MOVE 'I'       LBTYPE
412 AC                   eval      lbstat = 'C'
412 AC                   eval      lbsdte = curdte
412 AC                   eval      lbstim = curtim
412 AC                   eval      lbrdte = curdte
412 AC                   write     lbrec
412 AC                   endif
412 A*
412 A*    BRK2 UOM
412 AC                   if        slstk3 <> 0  or
416aAC                             ajqty3 <> 0
415cD*                    Z-ADDSLSTK3    LBQPCK
412 A*          SLSTK3    MULT -1        LBQPCK
412 AC                   call      'PIRLBL#'
412 AC                   parm                    lblbl#
415cA*  Label type for aisle cycle count or inventory
415cAC                   if        ivsadj <> ' '
415cAC                   eval      lbtype = 'A'
415cAC                   eval      lbqpck = ajqty3
415cAC                   else
415cAC                   eval      lbtype = 'I'
415cAC                   eval      lbqpck = slstk3
415cAC                   endif
412 AC                   eval      lbgrp1 = *blanks
412 AC                   eval      lbgrp2 = *blanks
412 AC                   eval      lbutyp = '2'
412 AC                   eval      lbucod = *blanks
412 AC                   if        not *in75
412 AC                   eval      lbucod = itum3
412 AC                   endif
415cD*                    MOVE 'I'       LBTYPE
412 AC                   eval      lbstat = 'C'
412 AC                   eval      lbsdte = curdte
412 AC                   eval      lbstim = curtim
412 AC                   eval      lbrdte = curdte
412 AC                   write     lbrec
412 AC                   endif
414aA*
414aA*    Create adjustment record for inventoried item.
414aA*
414aAC                   if        ivsadj <> ' '
414aAC                   clear                   iarec
    A*
414bA*     Get corresponding SSB item if one exists.
414bA*
414bAC                   call      'GETSSB'
414bAC                   parm      itwhse        $gwhse
414bAC                   parm      ititem        $gitem
414bAC                   parm                    $gssb
414bAC                   parm                    $gdesc
414bAC                   parm                    $gpdsc
414bAC                   parm                    $gwhdp
414bAC                   parm                    $gstyp
414bAC                   parm                    $gum
414bAC                   parm                    $gum2
414bAC                   parm                    $gumq2
414bAC                   parm                    $gum3
414bAC                   parm                    $gumq3
414bAC                   parm                    $grtn
414bA*
414bA*       When SSB item exists.
414bA*
414bAC                   select
414bAC                   when      $grtn = '*FOUND  '
414b *       Write adjustment for base item.
414bAC                   eval      iawhse = itwhse
414bAC                   eval      iaitem = ititem
414aAC                   eval      iadate = curdte
414aAC                   eval      iatime = curtim
414aAC                   movel     'INV'         iaby
414aAC                   eval      iawhdp = slwhdp
414aAC                   eval      iadisp = sldisp
414cAC                   if        itcwgt = 'Y'
414cAC     itswgt        mult      ajqty1        iacwta
414c**          IACWTA    MULT -1        IACWTA
414cAC                   else
414cAC                   eval      iacwta = 0
414cAC                   endif
414bAC                   eval      iaqty1 = ajqty1
414bAC                   eval      iaqty2 = 0
414bAC                   eval      iaqty3 = 0
414bAC                   eval      iacode = ivsadj
640aAC                   move      ivspag        oamemo
640aAC                   move      oamemo        iamemo
414bAC                   write     iarec
414b *       Write adjustment for breakdown item.
414bAC                   eval      iawhse = itwhse
414bAC                   eval      iaitem = $gssb
414bAC                   eval      iadate = curdte
414bAC                   eval      iatime = curtim
414bAC                   movel     'INV'         iaby
414bAC                   eval      iawhdp = slwhdp
414bAC                   eval      iadisp = sldisp
414bAC                   eval      iacwta = 0
414cAC                   if        itcwgt = 'Y'
414cAC     itswgt        div       itumq2        brkwgt
414cAC                   if        itumq3 <> 0
414cAC     brkwgt        div       itumq3        brkwgt
414cAC                   endif
414cAC                   if        itumq3 <> 0
414cAC     ajqty2        mult      itumq3        brkqty
414cAC     brkqty        add       ajqty3        brkqty
414cAC                   else
414cAC                   eval      brkqty = ajqty2
414cAC                   endif
414cAC     brkwgt        mult      brkqty        iacwta
414cA**         IACWTA    MULT -1        IACWTA
414cAC                   else
414cAC                   eval      iacwta = 0
414cAC                   endif
414bAC                   eval      iaqty1 = ajqty2
414bAC                   eval      iaqty2 = ajqty3
414bAC                   eval      iaqty3 = 0
414bAC                   eval      iacode = ivsadj
640aAC                   move      ivspag        oamemo
640aAC                   move      oamemo        iamemo
414bAC                   write     iarec
414b *
414b *       When SSB item does not exist.
414b *
414bAC                   other
414bAC                   clear                   iarec
414bAC                   eval      iawhse = $pwhse
414bAC                   eval      iaitem = ititem
414bAC                   eval      iadate = curdte
414bAC                   eval      iatime = curtim
414bAC                   movel     'INV'         iaby
414bAC                   eval      iawhdp = slwhdp
414bAC                   eval      iadisp = sldisp
414cAC                   if        itcwgt = 'Y'
510cAC                   eval      tacwta = 0
414cA*
510bD*          AJQTY1    IFGT 0
510bMC                   if        ajqty1 <> 0
510cAC     itswgt        mult      ajqty1        tacwta
510cAC                   add       tacwta        iacwta
510cD*          ITSWGT    MULT AJQTY1    IACWTA
414c**          IACWTA    MULT -1        IACWTA
414cAC                   endif
414c *
510bD*          AJQTY2    IFGT 0
510bMC                   if        ajqty2 <> 0
414cAC                   eval      brkwgt = 0
417aAC                   if        itumq2 = 0
417aAC                   eval      itumq2 = 1
417aAC                   endif
414cAC     itswgt        div       itumq2        brkwgt
510cAC     brkwgt        mult      ajqty2        tacwta
510cAC                   add       tacwta        iacwta
510cD*          BRKWGT    MULT AJQTY2    IACWTA
414c**          IACWTA    MULT -1        IACWTA
414cAC                   endif
414c *
510bD*          AJQTY3    IFGT 0
510bMC                   if        ajqty3 <> 0
414cAC                   eval      brkwgt = 0
417aAC                   if        itumq2 = 0
417aAC                   eval      itumq2 = 1
417aAC                   endif
417aAC                   if        itumq3 = 0
417aAC                   eval      itumq3 = 1
417aAC                   endif
414cAC     itswgt        div       itumq2        brkwgt
414cAC     brkwgt        div       itumq3        brkwgt
510cAC     brkwgt        mult      ajqty3        tacwta
510cAC                   add       tacwta        iacwta
510cD*          BRKWGT    MULT AJQTY3    IACWTA
414c**          IACWTA    MULT -1        IACWTA
414cAC                   endif
414c *
414cAC                   else
414cAC                   eval      iacwta = 0
414cAC                   endif
414c *
415cD**                   Z-ADD0         IACWTA
414bAC                   eval      iaqty1 = ajqty1
414bAC                   eval      iaqty2 = ajqty2
414bAC                   eval      iaqty3 = ajqty3
414bAC                   eval      iacode = ivsadj
640aAC                   move      ivspag        oamemo
640aAC                   move      oamemo        iamemo
414bAC                   write     iarec
414b *
414bAC                   endsl
     *
414aA*
414aA*  Update general quantities for item.
414aA*
414aAC                   eval      $acmd = '*STOCK  '
414aAC                   eval      $aprg = #prog
414aAC                   eval      $atype = '*INTER  '
414aAC                   eval      $awhse = $pwhse
414aAC                   eval      $aitem = ititem
415aMC                   eval      $aqty1 = ajqty1
415aMC                   eval      $aqty2 = ajqty2
415aMC                   eval      $aqty3 = ajqty3
415aD*                    Z-ADDIAQTY1    $AQTY1
415aD*                    Z-ADDIAQTY2    $AQTY2
415aD*                    Z-ADDIAQTY3    $AQTY3
414aAC                   call      'ADJQTY'
414aAC                   parm                    $acmd
414aAC                   parm                    $aprg
414aAC                   parm                    $atype
414aAC                   parm                    $awhse
414aAC                   parm                    $aitem
414aAC                   parm                    $aqty1
414aAC                   parm                    $aqty2
414aAC                   parm                    $aqty3
414aAC                   parm                    $artq1
414aAC                   parm                    $artq2
414aAC                   parm                    $artq3
414aAC                   parm                    $artn
414aAC                   parm                    $aerm
414aAC                   endif
414aA*
     *
     C                   enddo
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *on
     C                   eval      #pgmq = #prog
510aA*
510aA* Get client id.
510aA*
510aAC     *dtaara       define    pirclient     client           10
510aAC                   in        client
     *
     *  Define keys.
     *
     *    INVSLOT file (Partial key)
     *
     C     keyivs        klist
     C                   kfld                    $pwhse
     *
     *    PIRITEM file
     *
     C     keyit         klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
     *
     *    SLOT1 file.
     *
     C     keysl1        klist
     C                   kfld                    ivswhs
     C                   kfld                    ivswhd
     C                   kfld                    ivsasl
     C                   kfld                    ivsloc
     C                   kfld                    ivslvl
     C                   kfld                    ivshnd
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdte = $cvd8o
     C                   time                    curtim
     *
     *  Open workstation file if not on JOBQ.
     *
     C                   if        $pjobq <> 'Y'
     C                   open      iv505fm
     C                   endif
     *
     *  Dummy read for compiler.
     *
     C                   if        1 <> 1
     C                   read      iv505fm                                50
     C                   endif
     *
     C                   endsr
HAL A*----------------------------------------------------------------
HAL A*
HAL A*  SETFIFO   SET DATES
HAL A*

      /free
       begsr setfifo;
         // first do I have a date in the invsdate file for this slot
         chain (slwhse: slwhdp: sldisp) invsdate;
         if %found(invsdate);
           // Now need to get the slot license
           // Call drislot

           savever# = $slver#;
           clear $slot;
           clear $slot2;
           $slver# = savever#;

           $slwhseu = *on;
           $slwhse = slwhse;

           $slwhdpu = *on;
           $slwhdp = slwhdp;

           $sldispu = *on;
           $sldisp = sldisp;

           $saemp#u = *on;
           $saemp# = e$emp#;

           $dridata = $slot;
           $dridata2 = $slot2;

           driSlot('%GET': $pprogram: $drireturn: $drimessage:
                                $dridata: $dridata2);

           $slot = $dridata;
           $slot2 = $dridata2;

           // should have the license for the slot now
           fifolcns = $satolcns;
           fifoOlcns = $saOLcns;

           slotentd = $slentd;
           slotprty = $slprty;

           savever# = $slver#;
           clear $slot;
           clear $slot2;
           $slver# = savever#;

           $slwhseu = *on;
           $slwhse = slwhse;

           $slwhdpu = *on;
           $slwhdp = slwhdp;

           $sldispu = *on;
           $sldisp = sldisp;

           $slitemu = *on;
           $slitem  = slitem;

           $saemp#u = *on;
           $saemp# = e$emp#;

           $saToLcnsu = *on;
           $saToLcns  = fifolcns;

           $saOLcnsu  = *on;
           $saOLcns   = fifoOlcns;

           $slentdu = *on;
           $slentd  = slotentd;

           $slexpdu = *on;
           $slexpd  = ivdexp;

           $slprtyu = *on;
           $slprty  = slotprty;

           $saActionu = *on;
           $saAction  = 'FIF';

           $satrn#u = *on;
           $satrn#  = 0;

           $dridata = $slot;
           $dridata2 = $slot2;

           driSlot('%SETFIFO': $pprogram: $drireturn: $drimessage:
                                $dridata: $dridata2);
           delete ivdrec;
         endif;
       endsr;
      /end-free

600aA*----------------------------------------------------------------
600aA*
600aA*  SYNCLCNS  Synch LICACTIVE with slot
600aA*

      /free
       begsr synclcns;

         // Call drislot

         savever# = $slver#;
         clear $slot;
         clear $slot2;
         $slver# = savever#;

         $slwhseu = *on;
         $slwhse = slwhse;

         $slwhdpu = *on;
         $slwhdp = slwhdp;

         $sldispu = *on;
         $sldisp = sldisp;

         $saemp#u = *on;
         $saemp# = e$emp#;

         $saActionU = *on;
         $saToLcnsU = *on;
         if ivsadj <> ' ';
           $saAction = 'CNT';
           $saToLcns = '*CC';
         else;
           $saAction = 'INV';
           $saToLcns = '*IC';
         endif;

         $dridata = $slot;
         $dridata2 = $slot2;

         driSlot('%SYNCLCNS': $pprogram: $drireturn: $drimessage:
                              $dridata: $dridata2);

         //select;
         //  when %error;
         //    error = *on;
         //  when $drireturn <> '*OK';
         //    error = *on;
         //endsl;

         //driSlot('%CLOSE': $pprogram: $drireturn: $drimessage:
         //                  $dridata: $dridata2);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  UPQTY   Up breakdown quantities.
     *
     C     upqty         begsr
     *
     *   Get item record for the units of measure.
     *
     C     keyit         chain     piritem                            75
416bAC                   exsr      zzzumq
     C                   if        not *in75
     *
     *      Calculate available quantity
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
     *
     *
     *      Make sure breakdown qty's are not greater than
     *        quantity in the unit of measure.
     *
     *          SLSTK3    DOWGEITUMQ3
     C                   dow       avail3 >= itumq3  and
     C                             itumq3 <> 0
     C                   eval      slstk3 = slstk3 - itumq3
     C                   eval      avail3 = avail3 - itumq3
     C                   add       1             slstk2
     C                   add       1             avail2
     C                   enddo
     *
     *          SLSTK2    DOWGEITUMQ2
     C                   dow       avail2 >= itumq2  and
     C                             itumq2 <> 0
     C                   eval      slstk2 = slstk2 - itumq2
     C                   eval      avail2 = avail2 - itumq2
     C                   add       1             slstk1
     C                   add       1             avail1
     C                   enddo
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  UPSTAT  Update slot status code.
     *
     C     upstat        begsr
     *
     C                   select
     *
     *    When item number is blank and the current status is 'A'
     *      the status should be set to 'Z'.
     *
     C                   when      slitem = ' '
     C                   if        slstat = 'A'
     C                   eval      slstat = 'Z '
     C                   eval      slsdte = curdte
     C                   eval      slstim = curtim
     C                   endif
     *
     *    When at least one slot qty is greater than zero and the
     *    current status is 'Z' or 'V' the status should be set to 'A'.
     *
     C                   when      slstk1 > 0  or
     C                             slstk2 > 0  or
     C                             slstk3 > 0  or
     C                             slalc1 > 0  or
     C                             slalc2 > 0  or
     C                             slalc3 > 0  or
     C                             sltfr1 > 0  or
     C                             sltfr2 > 0  or
     C                             sltfr3 > 0  or
     C                             slpck1 > 0  or
     C                             slpck2 > 0  or
     C                             slpck3 > 0  or
     C                             slrcv1 > 0  or
     C                             slrcv2 > 0  or
     C                             slrcv3 > 0
     *
     C                   if        slstat = 'Z'  or
     C                             slstat = 'V'
     C                   eval      slstat = 'A '
     C                   eval      slsdte = curdte
     C                   eval      slstim = curtim
     C                   eval      slentd = curdte
     C                   endif
     *
     *    When all slot quantities are less than or equal to zero and
     *    the current status is 'A' the status should be set to 'Z'.
     *
     C                   when      slstk1 <= 0  and
     C                             slstk2 <= 0  and
     C                             slstk3 <= 0  and
     C                             slalc1 <= 0  and
     C                             slalc2 <= 0  and
     C                             slalc3 <= 0  and
     C                             sltfr1 <= 0  and
     C                             sltfr2 <= 0  and
     C                             sltfr3 <= 0  and
     C                             slpck1 <= 0  and
     C                             slpck2 <= 0  and
     C                             slpck3 <= 0  and
     C                             slrcv1 <= 0  and
     C                             slrcv2 <= 0  and
     C                             slrcv3 <= 0
     *
     C                   if        slstat = 'A'  and
510dD**         SLRSRV    ANDEQ'N'
510dMC                             slrsrv <> 'Y'  and
510dMC                             slpick <> 'Y'
     C                   eval      slstat = 'Z '
     C                   eval      slsdte = curdte
     C                   eval      slstim = curtim
     C                   endif
640bA*
640bA*  Zero emtpy Quarantine virutal slots.
640bAC                   if        slstat = 'QU' and
640bAC                             slrsrv = 'V'  and
640bAC                             slpick <> 'Y'
640bAC                   eval      slstat = 'Z '
640bAC                   eval      slsdte = curdte
640bAC                   eval      slstim = curtim
640bAC                   endif
520a *     Zero empty overflow
520a C                   if        slstat = 'A'  and
520a C                             slpick = 'N'
520a C                   eval      slstat = 'Z '
520a C                   eval      slsdte = curdte
520a C                   eval      slstim = curtim
520a C                   endif
520a *
JOR1A*     Special order item. Zero vrt slot.
JOR1AC                   if        client = jordanos  and
JOR1AC                             itpos6 <> ' '  and
JOR1AC                             itpos6 <> 'E'
JOR1AC                   eval      slstat = 'Z '
JOR1AC                   eval      slsdte = curdte
JOR1AC                   eval      slstim = curtim
JOR1AC                   endif
     *
     C                   endsl
     *
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   if        $pjobq <> 'Y'
     C                   eval      *in97 = *on
     C                   write     msgctl
     C                   endif
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *    IV51021  Updating slot records for whse/dept/section.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'IV51021'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
416b *    ZZZUMQ   Set zero ITUM quantiites to 1.
416b *
416b C     zzzumq        begsr
416b C                   if        itumq2 = 0
416b C                   eval      itumq2 = 1
416b C                   endif
416b C                   if        itumq3 = 0
416b C                   eval      itumq3 = 1
416b C                   endif
416b C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
