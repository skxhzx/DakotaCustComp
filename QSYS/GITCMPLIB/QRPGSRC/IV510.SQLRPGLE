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
650aA*    11/12/13  RH   6.50a
     *      - Enh: Call UT812 to recalculate ITEMQTY for items.       order.
     *        Was not updateing HOLD quantity correctly.              order.
700aA*    04/28/15  RH   7.00a
     *      - Fix: was calling UT812 with previous item in IAITEM.    order.
700bA*    03/31/16  RH   7.00b
     *      - Fix: Change to update empty PIR slots to 'Z'            order.
700cA*    08/04/16  MR   7.00c
     *      - Fix: Update slot quantities for cycle count history.
700dA*  09/15/16  LMC  7.00d
     *    - Enh: New history files names changed.
     *    - Enh: Dept added to invinuse file to ensure unique # is
     *           by whse/department.
700e *  09/28/16  RTR  7.00e
     *    - Enh: Added LICADJ processing.
710a *  03/23/17  LMC  7.10a
     *    - Enh: INVHSTD has a database change, we are adding some
     *      additional tracking fields. At this time will will be
     *      populating the following fields during the post process.
     *      ICDASL,ICDLOC,ICDLVL,ICDHND,ICDPAGE,ICDADJ,ICDTEAM.
     *      We will only load the User Id during posting if the change
     *      by field in invslot is not blank.
     *      When then realtime version of cycle counting is completed
     *      all the new CNT fields will be populated at the time the
     *      counts are taken.
710b *  09/07/17  KDE  7.10b
     *    - Fix: Update slot status to "Z" for Repack slots that have
     *      balances.  d no open work orders
710c *  12/21/17  LMC  7.10c
     *    - Enh: INVHSTD has a database change, we are adding Item and
     *      base slot.
720a *  06/13/18  LMC  7.20a
     *    - Fix: ITEMADJ was getting loaded with the last ititem that
     *      was populated. Which caused an issue when counting an
     *      empty slot. IVSITM is ' ' and SLITEM = ' '.
750  *  02/17/22  KDE  7.50
     *    - Fix: Exclude ondemand repacks from mod 710b
     *
750aA*  03/04/22  RBD  7.50a
     *    - Reserved.
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
700cAFinvinuse  if   e           k disk
     Fslot1     uf   e           k disk
700dDF*ichcnth   uf   e           k disk
700dAFinvhsth   uf   e           k disk
700dDF*icdcntd   uf   e           k disk
700dAFinvhstd   uf   e           k disk
408 AFinvbslt   o  a e           k disk
412 AFLabel     o  a e           k disk
414 AFitemadj   o  a e           k disk
700eAFlicadj    o  a e           k disk    usropn

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
GLP A /copy qcopysrc,id#glp

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
700eA*----------------------------------------------------------------
700eA* Function prototypes.
700eA*----------------------------------------------------------------
700eA /copy qcopysrc,p.getoptio
700eA
700eAD getRecId        pr                  extpgm('GETRECID')
700eAD  pWhse                         3s 0 const
700eAD  pFile                        10    const
700eAD  pRecId                       11p 0
700eA
700eAD getAdjCode      pr                  extpgm('GETADJCOD')
700eAD  pCode                         2    const
700eAD  pDesc                        30
700eAD  pSys                          1

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
650aAD $item           s             15
650aAD $jtyp           s              1
650aAD $lmsg           s              4
650aAD $lprg           s             10
650aAD $lrtn           s              8
     D $msgf           s             10
650aAD $pwhs           s             15  5
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
700eAD gaDesc          s             30a
700eAD gaSys           s              1a
700eAD getoptval       s            117a
     D lststp          s              1
     D lstwhd          s              5
     D lstwhs          s              3  0
640aAD oamemo          s             14
700eAD recidnum        s             11p 0
710bAd rplcnt          s              3  0
750 Ad odrcnt          s              3  0
     D tacwta          s              9  2
700eAD useLicAdj       s               n
700cAD wadjcnt         s              7s 0
710bAd wocnt           s              3  0
700dAD savdpt          s              5
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
700dA * Getting the Inventory In Use # was moved after we read the
700dA * invslot file, because multiple departments can be posted at the
700dA * same time. They will have different unique numbers.
     * Get Inventory In Use #
700dDc*                  z-add     0             wadjcnt
700dDC*    ikey          chain     invinuse
700dDc*                  if        %found
700dDc*                  eval      ichuid = inuuid
700dDc*                  eval      icduid = inuuid
700dDc*                  endif
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
     c
700dAC* need to get the invinuse when the department changes
700dA /free
700dA   if savdpt <> ivswhd;
700dA     // when savdpt is not blank we have read a new dept record
700dA     // need to update the history header file for the department
700dA     // that was just finished
700dA     if savdpt <> ' ';
700dA       chain (ichuid: $pwhse) invhsth;
700dA       if %found(invhsth);
700dA         ichadj = wadjcnt;
700dA         ichpstts = %timestamp;
700dA         ichsts = '0';
700dA         update ichrec;
700dA       endif;
700dA     endif;
700dA     wadjcnt = 0;
700dA     chain ($pwhse: ivswhd) invinuse;
700dA     if %found(invinuse);
700dA       ichuid = inuuid;
700dA       icduid = inuuid;
700dA     endif;
700dA     savdpt = ivswhd;
700dA   endif;
700dA /end-free
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
720aA*    Clear out piritem ititem if no item in slot and no item
720aA*    counted. Without this the previous values for the last item
720aA*    were being retained and used.
720aAC                   If        ivsitm = slitem and
720aAc                             ivsitm = ' ' and
720aAc                             slitem = ' '
720aAc                   eval      ititem = ' '
720aAc                   endif
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
700eAC                   exsr      wrtlicadj
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
700eAC                   exsr      wrtlicadj
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
700eAC                   exsr      wrtlicadj
414b *
414bAC                   endsl
650aAC                   exsr      zzrcal
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
700aAC                   exsr      zzrcal
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
     *
700dDC*    dkey          chain     icdcntd
700dAC     dkey          chain     invhstd
700cAC                   if        %found
700cAC                   eval      icdaqty1 = ivsqt1
700cAC                   eval      icdaqty2 = ivsqt2
700cAC                   eval      icdaqty3 = ivsqt3
700cAc                   eval      icdadj1 = ajqty1
700cAc                   eval      icdadj2 = ajqty2
700cAc                   eval      icdadj3 = ajqty3
700cAc                   if        ajqty1 <> 0
700cAc                             or ajqty2 <> 0
700cAc                             or ajqty3 <> 0
700cAc                   eval      wadjcnt = wadjcnt + 1
700cAc                   endif
700cAc                   if        ivsedt > 0
700cAc                   eval      icdslcnt= 'Y'
700cAc                   eval      icdsltts= %timestamp
700cAc                   endif
710aA /free
710aA   icdasl = ivsasl;
710aA   icdloc = ivsloc;
710aA   icdlvl = ivslvl;
710aA   icdhnd = ivshnd;
710aA   icdadj = ivsadj;
710aA   icdpage = ivspag;
710aA   // if changed load changed by to team field until real time
710aA   // cycle count is installed.
710aA   if ivscby <> ' ';
710aA     icdteam = ivscby;
710aA   else;
710aA     icdteam = ivseby;
710aA   endif;
710aA   icdpstusr = #curruser;
710cA   icditem = ivsitm;
710cA   // need to get base slot
710cA   savever# = $slver#;
710cA   clear $slot;
710cA   clear $slot2;
710cA   $slver# = savever#;

710cA   $slwhseu = *on;
710cA   $slwhse  = icwhse;
710cA   $slwhdpu = *on;
710cA   $slwhdp  = ICDWHSDP;
710cA   $sldispu = *on;
710cA   $sldisp  = ICDSLDSP;

710cA    $dridata = $slot;
710cA    $dridata2 = $slot2;

710cA    driSlot('%GET': $pprogram: $drireturn: $drimessage:
710cA                         $dridata: $dridata2);

710cA    $slot = $dridata;
710cA    $slot2 = $dridata2;

710cA   icdbase = $sacdsp;
710aA /end-free
700cAC                   update    icdrec
700cAc                   endif
     *
700aDC***                exsr      zzrcal
600aA
600aA*    Call program to sync slot and licenses.
600aA
600aAC                   exsr      synclcns
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
700eAC                   exsr      wrtlicadj
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
700eAC                   exsr      wrtlicadj
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
700eAC                   exsr      wrtlicadj
414b *
414bAC                   endsl
700aDC**                 exsr      zzrcal
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
700aAC                   exsr      zzrcal
414aAC                   endif
414aA*
     *
     C                   enddo
     *
700dDC*    hkey          chain     ichcnth
700dMC     hkey          chain     invhsth
700cAc                   if        %found
700cAc                   eval      ichadj = wadjcnt
700cAc                   eval      ichpstts = %timestamp
700cAc                   eval      ichsts = '0'
700cAc                   update    ichrec
700cAc                   endif
     *
     C                   eval      *inlr = *on
650aAC                   exsr      zzzcls812
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
700cA*    Cycle Count History Header
700cAC     hkey          klist
700cAc                   kfld                    ichuid
700cAc                   kfld                    $pwhse
700cA*    Cycle Count History Detail
700cAC     dkey          klist
700cAc                   kfld                    icduid
700dAc                   kfld                    slwhse
700dAc                   kfld                    slwhdp
700cAc                   kfld                    sldisp
700cA*    Inventory In Use
700cAC     ikey          klist
700cAc                   kfld                    $pwhse
700dAc                   kfld                    ivswhd
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
700bA**
700b *  Zero empty PIR slots.
700bAC                   if        slstat = 'A'  and
700bAC                             slrsrv <> 'Y'  and
700bAC                             slstyp = 'P'
700bAC                   eval      slstat = 'Z '
700bAC                   eval      slsdte = curdte
700bAC                   eval      slstim = curtim
700bAC                   endif
700bA**
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
710b *  Zero Repack slots that are empty and have no open work orders and replens
710bAC                   if        slstat = 'RP' and slhand<>*blanks
750 A /free
750 A           odrcnt=*zeros;
750 A           exec sql select count(*) into :odrcnt
750 A                     from kititem,itemlnk where
750 A                           ilwhse=kiwhse and ilitem=kiitem
750 A                       and ilitm2=:slitem and kirptp = '2';
750 A
710bA           rplcnt=*zeros;
710bA           exec sql select count(*) into :rplcnt
710bA                     from prplfil where
710bA                           pritem=:slitem and prtail='RPK'
710bA                       and prflag <>'D';
710bA
710bA           wocnt=*zeros;
710bA           exec sql select count(*) into :wocnt
710bA                     from kitordh,kitcomp where kohwhs=kcwhse and
710bA                           kohitm=kcitem and kccitm=:slitem and
710bA                           kohsta<'4';
710bA /end-free
710bAc*  if no open replenishments and no open work orders then zero slot
750 DC*                  if        rplcnt=0 and wocnt=0
750 MC                   if        rplcnt=0 and wocnt=0 and odrcnt=0
710bAC                   eval      slstat = 'Z '
710bAC                   eval      slsdte = curdte
710bAC                   eval      slstim = curtim
710bAC                   endif
710bAC                   endif
     *
     C                   endsl
     *
     C                   endsr
     *---------------------------------------------------------------
     *
     *  WRTLICADJ  Write LICADJ record.
700eA /free
700eA  begsr wrtlicadj;
700eA   monitor;
700eA     GetOptions(%editc(iawhse:'X'): '*ADJUST': '002': '001': getoptval);
700eA     if getoptval = 'Y';
700eA       useLicAdj = *on;
700eA     else;
700eA       useLicAdj = *off;
700eA     endif;
700eA   on-error;
700eA     useLicAdj = *off;
700eA   endmon;
700eA
700eA   // If option not on, do nothing.
700eA   if useLicAdj = *off;
700eA     leavesr;
700eA   endif;
700eA
700eA   // If file not open, open it.
700eA   if not %open(licadj);
700eA     open LicAdj;
700eA   endif;
700eA
700eA   // Get unique adjustment record id.
700eA   GetRecId(iawhse: 'LICADJ': recidnum);
700eA
700eA   // Get adjustment code description/system.
700eA   GetAdjCode(iacode: gaDesc: gaSys);
700eA
700eA   adjwhs = iawhse;
700eA   adjnbr = %char(recidnum);
700eA   adjparent = *blanks;
700eA   adjcode = iacode;
700eA   adjcsys = gaSys;
700eA   adjitem = iaitem;
700eA   adjaqty1 = iaqty1;
700eA   adjaqty2 = iaqty2;
700eA   adjaqty3 = iaqty3;
700eA   adjcqta = iacwta;
700eA   adjwhdp = iawhdp;
700eA   adjdisp = iadisp;
700eA   adjaisl = slaisl;
700eA   adjloc = slloc;
700eA   adjrlvl = slrlvl;
700eA   adjhand = slhand;
700eA   adjstat = 'A';
700eA   adjmemo = iamemo;
700eA   //ADJLLTRN =
700eA   //ADJLLTRSQ =
700eA   adjlcns = *blank;
700eA   adjaddts = %timestamp();
700eA   adjadduc = %timestamp();
700eA   adjaddcpgm = #prog;
700eA   adjaddjpgm = #prog;
700eA   adjaddemp = *zero;
700eA   adjaddcusr = #curruser;
700eA   adjaddjusr = #user;
700eA   adjaddjob = #job;
700eA   adjaddnbr = #jobn;
700eA   adjexpflag = *blank;
700eA   //ADJEXPTS
700eA   //ADJEXPUC
700eA   //ADJEXPJUSR
700eA   //ADJEXPJOB
700eA   //ADJEXPNBR
700eA   adjdrislot = *blanks;
700eA   adjdrilic = *blanks;
700eA
700eA   write adjrec;
700eA
700eA  endsr;  // wrtlicadj
700eA /end-free
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
650a *----------------------------------------------------------------
650a *
650aA*  ZZRCAL   Recalculate item quantity from slots.
     *
650aAC     zzrcal        begsr
     *
     * Recalculate item qty.
     C                   eval      $pwhs = iawhse
650aAC                   eval      $item = iaitem
     C                   eval      $jtyp = *off
     C                   eval      $lprg = #prog
     C                   eval      $lrtn = *blanks
     C                   eval      $lmsg = *blanks
     C                   call      'UT812'
     C                   parm                    $pwhs
     C                   parm                    $item
     C                   parm                    $jtyp
     C                   parm                    $lprg
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *
650aAC     endcal        endsr
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZZCLS812   Close UT812
650aA*
650aAC     zzzcls812     begsr
     C                   call      'UT812'
     C                   parm                    $pwhs
     C                   parm      '*CLOSE'      $item
     C                   parm                    $jtyp
     C                   parm                    $lprg
     C                   parm                    $lrtn
     C                   parm                    $lmsg
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
