500 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO144     PO receiving - Delete
     *  07 July, 1997
     *  Hemant Kapadia
     *
     *  SK114 - 1.00
     *
     *----------------------------------------------------------------
     *  Revisions
     *
401 A*    07/10/97  HNK  4.01
     *      - *ZERO instead of *CLOSE command passed to PT132.
401 A*    07/14/97  HNK  4.01
     *      - Error check added. (Cannot delete transactions, if the
     *        PO is ready to export.)
     *      - ZZUHDR subroutine revised set the partial flag right.
409 A*    03/02/98  RH   4.09
     *      - Reduce PO Detail weight by label ship weight if trans.
     *        is deleted.  Total weight is entered.  Label ship weight
     *        is calculated, (item wt times quantity).
     *        When we reduce using the label ship weight and the new
     *        transaction catch weight is entered, the P.O. detail
     *        weight might not equal the total of label ship weights.
409 A*    05/22/98  HNK  4.09
     *      - Delete POMFR records.
409 A*    06/01/98  RH   4.09
     *      - Add $PMPUT and $LMPUT Manual put away options, pass parm
410 A*    12/04/98  RH   4.10
     *      - Move LBWHSE into $LWHSE to pass to PT132.
410 A*    12/07/98  RH   4.10
     *      - Add ZZAVAL, can't delete if trans. qty is > available.
413 A*    10/11/99  DAS  4.13
     *      - Revised to not allow delete if stat <> '1'
413 A*    10/14/99  DAS  4.13
     *      - Revised to make sure rcv qtys don't go negative.
     *
414 A*    09/28/00  KDE  4.14
     *      - Revised to add record to PORCV when receipt is deleted
     *
414 A*    10/12/00  DAS
     *      - Added CVTDT call to get date for TODAY.
     *      - Made misc mods to above 414 changes.
416  *    05/23/02  RH   4.16
     *      - PORCV file changed, initialize POREDT and PORETI.
     *
500  *    05/20/05  MLB  5.00
     *      - Enh: Revised program to allow transactions received for a
     *        non-live department to be deleted(reset) back to zero.
     *      - Added call to CHKLIVE for active departments.
500a *    07/19/05  RH   5.00a
     *      - FIX: Change to update PORCV if record is found.
     *        Was causing rec lock error when reading rec and adding new rec.
     *        because read record remained locked.
520a *    10/10/08  RH   5.10a
     *      - Fix: Convert to ILE.  Change to reduce PO detail weight
     *        by LICINFO weight, not label ship weight if trans is
     *        deleted.
600aA*    02/22/09  DAS  6.00a  P#00045
     *      - Revised to work with new STG/RCV/USR slots.
600bA*    02/22/09  DAS  6.00b
     *      - Revised to use DRI programs.
     *      - Revised not to use PT132.
     *      - Changed all #user to #curruser.
     *
640 A*    01/13/11  RH   6.40
     *      - Enh: Add Whse to CHKLIVE parms
640aA*    02/24/11  DAS  6.40a
     *      - Revised to verify qty using DRISLOT *VERIFY.
     *        Re: Program didn't work correctly when eaches were
     *        received because the qty in the slot was up'd and
     *        the qty in the label is left as eaches.
640bA*    10/11/12  DAS  6.40b
     *      - Revised to clean up items that Directed Putaway
     *        put into slots.
640cA*    08/08/12  LMC  6.40c
     *      - Enh: Remove License from POASN file - so record no
     *      longer shows received.
640dA*    12/10/12  LMC  6.40d
     *      NOTE: do not install this mod unless the NEW LICINFO
     *      FILE is installed.
     *      - Enh: Change catch weight to use Total Lbs from the
     *      NEW LICINFO instead of using the avgwgt * qty
650aA*    05/20/13  LMC  6.50a
     *      - Enh: Added RCVPO Reversing transaction.
650bA*    01/28/14  LMC  6.50b
     *      - Enh: Delete UCI if transaction is deleted.
650cA*    03/17/15  LMC  6.50c
     *      - Enh: Now called from GUI receiving - needs to be
     *        able to send text messages back to GUI.
     *      - Revised to return selection error messages as text through
     *        $perm if TEXT is sent in $prtn.
700aA*    05/27/16  LMC  7.00a
     *      - Enh: Added logic for branded Items, need to reduce both
     *        PODTL records, for parent item, then for Branded Item.
710aA*    01/20/17  LMC  7.10a
     *      - Enh: Provided additional logic to allow a non live
     *        departments transaction to be reversed/deleted.
     *        The transation/label are already closed.
720aA*    07/29/16  LMC  7.20a
     *      - Enh: UCI Tracking.
730aA*    05/21/19  LMC  7.30a
     *      - Enh: Do not process a *DP license, it should not be in
     *        printed status.
730b *    07/31/19  RTR  7.30b
     *      - Fix: Monitor call to PUTMSG, so that it does not throw
     *        errors during call from GUI.
730c *    08/21/19  LMC  7.30c
     *      - Fix: Don't call the normal message routines if this
     *        comes from gui, just return $DRIMESSAGE in $perm
730d *    09/30/19  LMC  7.30d
     *      - Fix: Send po# from po detail to RCVPO transaction
     *        so it will get cleaned up properly.
730e *    12/16/19  LMC  7.30e
     *      - Enh: Send delete license information to PO728s. RTI
740a *    05/06/20  LMC  7.40a
     *      - Enh: Send whse to ADJTRAN2. With the new W files
     *        ADJTRAN2 uses whse & tran# to chain to pirtranw.
     *        it attempts to get a whse from the user table. But
     *        when called thru gui, the default gui user is not in
     *        the user table.
740b *    06/11/20  LMC  7.40b
     *      - Enh: Send user to CRTRCVTRN if sent in.
770b *    03/16/23  LMC  7.70b
     *      - Enh: When getting an error from a call to the DRI pgms
     *        don't call putmsg subr if called from gui.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        CHAIN INDICATOR
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
600bDF*abel     if   e           k disk
600bMFLabel     uf   e           k disk
     Fpohdr     uf   e           k disk
     Fpodtl     uf   e           k disk
700aAFpodtl1    uf   e           k disk    prefix(BR_) rename(pdrec:pdrec1)
409 AFpomfr1    uf   e           k disk
600bDF*lot2     if   e           k disk
600bDF*irtran   if   e           k disk
520aAFlicense1  if   e           k disk
600bDF*icinfo   if   e           k disk
414 AFporcv1    uf a e           k disk
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

700aA /copy qcopysrc,p.GETBRAND

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D msg             s             50    dim(1) ctdata perrcd(1)

600bA*----------------------------------------------------------------
600bA*  DRI parameters
600bA*----------------------------------------------------------------
600bA
600bA /COPY *libl/qcopysrc,C#DRIPARMS
600bA
600bA*----------------------------------------------------------------
600bA*  Data Formats
600bA*----------------------------------------------------------------
600bA
600bA /COPY *libl/qcopysrc,C#LICENSE
600bA /COPY *libl/qcopysrc,C#LICINFO
600bA /COPY *libl/qcopysrc,C#PIRTRAN
600bA /COPY *libl/qcopysrc,C#SLOT
650bA /COPY *libl/qcopysrc,C#UCIINFO
600bAD saveVer#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $ptrn#                19     22p 0
     D  $plbl#                23     26p 0
740bAD  $puser                27     36
740bDD* $pqpck                27     31  0
740bDD* $pqrmn                32     36  0
     D  $ppckc                37     39  0
     D  $precc                40     42  0
     D  $pcwgt                43     43
409 AD  $pmput                44     44
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
409 AD  $lmput                89     89
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0
414 A*----------------------------------------------------------------
414 A*  Called programs
414 A*
     D @cvtdt          c                   const('CVTDTE')
650aAD @crtrcv         c                   const('CRTRCVTRN')
414 A*----------------------------------------------------------------
414 A*  Called program parameters
414 A*
414 AD $cvtdt          ds
414 AD  $cvcmd                 1      8
414 AD  $cvprg                 9     18
414 AD  $cvd6i                19     24
414 AD  $cvd8i                25     32
414 AD  $cvd6o                33     38  0
414 AD  $cvd8o                39     46  0
414 AD  $cvsto                47     64
414 AD  $cvrtn                65     72
414 AD  $cverm                73    132
414 AD  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D                 ds
     D  $ec                    1      2p 0
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
600bA /Copy qcopysrc,c#pgminfds
600bDD**              sds
600bDD**#prog            *proc
600bDD**#job                 244    253
600bDD**#user                254    263
600bDD**#jobn                264    269
600bDD**#jobdt               276    281  0
600bDD**#jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     D $msgf           s             10
600bAD chk4err         s               n
650aAd del$ptpcs       s                   like($ptpcs)
650aAd del$ptqty1      s                   like($ptqty1)
650aAd*del$ptqty2      s                   like($ptqty2)
     D eof             s              1
600bMD error           s               n
     D full            s              1
600bDD*kytype          s                   like(lntype)
600bDD*kylcns          s                   like(lnlcns)
600bDD*kycode          s                   like(lncode)
600bDD*kycseq          s                   like(lncseq)
     D lftqty          s              5  0
730eAD lCommand        s             10
     D nwswgt          s              9
     D part            s              1
     D recv            s              1
650cMD rtnMsgType      s                   like($prtn)
     D svqpck          s                   like(lbqpck)
     D svswgt          s                   like(lbswgt)
     D today           s              8  0
600bAD zmsflag         s               n
600bAD zmflag          s               n
700aAD bCmd            s             10
700aAD bBrand          s             10
700aAD bParentitm      s             15
700aAD bBranditm       s             15
700aAD bBrandFlg       s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Not used
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for delete.
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *              *OK      - Record deleted successfully.
     *                         Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   if        error = *on
     C                   goto      out
     C                   endif
600bA*
600bA*   Reduce qty in RCV slot.
600bA*
710aAC                   if        $crtn <> '*NOTLIVE'
600bAC                   exsr      zzUpdRcvSlt
600bAC                   if        error = *on
600bAC                   goto      out
600bAC                   endif
710aAC                   endif
     *
     *  Close label and PirTran recs and update slot and whse qtys
     *
600bDC**                 eval      $lcmd = '*ZERO   '
600bDC**                 eval      $lrtn = *blanks
600bDC**                 eval      $prtn = *blanks
600bDC**                 eval      $lprg = $pprg
600bDC**                 eval      $ltrn# = $ptrn#
600bDC**                 eval      $lmput = $pmput
600bDC**                 eval      $lwhse = lbwhse
600bDC**                 call      'PT132'
600bDC**                 parm                    $lparm
600bDC**                 eval      $pmsg = $lmsg
600bDC**                 eval      $perm = $lerm
600bD **
600bDC**                 if        $lrtn = '*INVALID'
600bDC**                 eval      $prtn = '*ERROR  '
600bDC**                 else
600bDC**                 eval      $prtn = $lrtn
600bDC**                 endif
     *
600bAC                   exsr      zzclose
     *
600bDC**                 if        $lrtn = '*OKOKOK '
700aA * Detemine if item from label is a branded Item
700aA * if so we will need to reduce both podtl records
700aA * for Parent and Branded Item.
700aA /free
700aA   bCmd = '*GET4BITM';
700aA   bBrand = ' ';
700aA   bParentItm = ' ';
700aA   bBrandItm = lbitem;
700aA   bBrandFlg = ' ';
700aA   GetBranded(bCmd: lbwhse: bParentItm: bBrand:
700aA              bBrandItm: bBrandFlg);
700aA
700aA   if bParentItm <> ' ';
700aA     chain (lbwhse: lbpo: lbseq: bParentItm) podtl;
700aA   else;
700aA     chain (lbwhse: lbpo: lbseq: lbitem) podtl;
700aA   endif;
700aA /end-free
700aDC*    pdkey         chain     podtl                              79
700aDC*                  if        not *in79
700aMC                   if        %found(podtl)
     C                   if        lbutyp = 'N'
413 AC                   if        pdqrc1 > svqpck
     C                   eval      pdqrc1 = pdqrc1 - svqpck
413 AC                   else
413 AC                   eval      pdqrc1 = 0
413 AC                   endif
     C                   endif
     C                   if        lbutyp = '1'
413 AC                   if        pdqrc2 > svqpck
     C                   eval      pdqrc2 = pdqrc2 - svqpck
413 AC                   else
413 AC                   eval      pdqrc2 = 0
413 AC                   endif
     C                   endif
     C                   if        lbutyp = '2'
413 AC                   if        pdqrc3 > svqpck
     C                   eval      pdqrc3 = pdqrc3 - svqpck
413 AC                   else
413 AC                   eval      pdqrc3 = 0
413 AC                   endif
     C                   endif
409 AC                   if        pdqrc1 = 0  and
409 AC                             pdqrc2 = 0  and
409 AC                             pdqrc3 = 0
409 AC                   eval      pddwgt = 0
409 AC                   else
409 AC                   eval      pddwgt = pddwgt - svswgt
409 AC                   if        pddwgt < 0
409 AC                   eval      pddwgt = 0
409 AC                   endif
409 AC                   endif
     C                   update    pdrec
414 A*
414 A*  Add record to PORCV file.
414 A*
     C                   exsr      zzurcv
     C                   endif
      /free
700aA   if bParentItm <> ' ';
700aA     chain (lbwhse: lbpo: lbitem) podtl1;
700aA /end-free
700aAC                   if        %found(podtl1)
700aAC                   if        lbutyp = 'N'
700aAC                   if        br_pdqrc1 > svqpck
700aAC                   eval      br_pdqrc1 = br_pdqrc1 - svqpck
700aAC                   else
700aAC                   eval      br_pdqrc1 = 0
700aAC                   endif
700aAC                   endif
700aAC                   if        lbutyp = '1'
700aAC                   if        br_pdqrc2 > svqpck
700aAC                   eval      br_pdqrc2 = br_pdqrc2 - svqpck
700aAC                   else
700aAC                   eval      br_pdqrc2 = 0
700aAC                   endif
700aAC                   endif
700aAC                   if        lbutyp = '2'
700aAC                   if        br_pdqrc3 > svqpck
700aAC                   eval      br_pdqrc3 = br_pdqrc3 - svqpck
700aAC                   else
700aAC                   eval      br_pdqrc3 = 0
700aAC                   endif
700aAC                   endif
700aAC                   if        br_pdqrc1 = 0  and
700aAC                             br_pdqrc2 = 0  and
700aAC                             br_pdqrc3 = 0
700aAC                   eval      br_pddwgt = 0
700aAC                   else
700aAC                   eval      br_pddwgt = br_pddwgt - svswgt
700aAC                   if        br_pddwgt < 0
700aAC                   eval      br_pddwgt = 0
700aAC                   endif
700aAC                   endif
700aAC                   update    pdrec1
700aAC                   endif
700aA /free
700aA   endif;
700aA /end-free
600bDC**                 endif
     *
     C                   exsr      zzuhdr
409 A*  Delete POMFR recs.
409 AC                   exsr      zzumfr
650bA*  Delete UCI recs.
650bAC                   exsr      zzuci
730eA*  RTI- Real time interface
730eAC                   exsr      zzrti
     *
     C     out           tag
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
650cAC                   eval      rtnMsgType = $prtn
650cAC                   eval      $prtn = ' '
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
730bAC                   monitor
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
730bAC                   on-error
730bAC                   endmon
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*    DRI0001s Local system caused error (send to different program)
600aA*----------------------------------------------------------------
600aA
600aAC     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
770bAC                   if        rtnMsgType = 'TEXT'
770bAC                   eval      $prtn = $drireturn
770bAC                   eval      $perm = $drimessage
770bAc                   else
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
770bAc                   endif
     C                   endsr

600bA*----------------------------------------------------------------
600bA*      0105s
600bA*
600bAC     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7975  Error while deleting record.
     *
     C     zm75          begsr
     C                   eval      #msgid = 'PIR7975'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PO14402  Cannot delete closed transaction.
     *
     C     zm4402        begsr
     C                   eval      #msgid = 'PO14402'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
401 A*----------------------------------------------------------------
401 A*     PO14403  Cannot delete transactions whose PO is ready to
401 A*              export.
401 A*
401 AC     zm4403        begsr
401 AC                   eval      #msgid = 'PO14403'
401 AC                   eval      #msgtp = '*DIAG  '
401 AC                   movea     errmsg        $md(1)
401 AC                   exsr      zmsmsg
401 AC                   eval      $pmsg = #msgk
401 AC                   endsr
401 A*----------------------------------------------------------------
410 A*     PO14404  Cannot delete transaction, transaction quantity
410 A*              already allocated.
410 A*
410 AC     zm4404        begsr
410 AC                   eval      #msgid = 'PO14404'
410 AC                   eval      #msgtp = '*DIAG  '
410 AC                   movea     errmsg        $md(1)
410 AC                   exsr      zmsmsg
410 AC                   eval      $pmsg = #msgk
410 AC                   endsr
413 A*----------------------------------------------------------------
413 A*     PO14405  Cannot delete transaction, transaction alread
413 A*              started.
413 A*
413 AC     zm4405        begsr
413 AC                   eval      #msgid = 'PO14405'
413 AC                   eval      #msgtp = '*DIAG  '
413 AC                   movea     errmsg        $md(1)
413 AC                   exsr      zmsmsg
413 AC                   eval      $pmsg = #msgk
413 AC                   endsr
     *----------------------------------------------------------------
     *     PIR9803  Deleted record successfully.
     *
     C     zm9803        begsr
     C                   eval      #msgid = 'PIR9803'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
600bD **---------------------------------------------------------------
600bD **
600bD ** ZZAVAL  Calculate available quantities for slot.
600bD **
600bDC**   zzaval        begsr
600bD **
600bD ** Call program to calculate availabe slot quantities.
600bD **
600bDC**                 call      'SLOTQTY'
600bDC**                 parm                    slstk1
600bDC**                 parm                    slstk2
600bDC**                 parm                    slstk3
600bD **
600bDC**                 parm                    slalc1
600bDC**                 parm                    slalc2
600bDC**                 parm                    slalc3
600bD **
600bDC**                 parm                    sltfr1
600bDC**                 parm                    sltfr2
600bDC**                 parm                    sltfr3
600bD **
600bDC**                 parm                    slpck1
600bDC**                 parm                    slpck2
600bDC**                 parm                    slpck3
600bD **
600bDC**                 parm                    slrcv1
600bDC**                 parm                    slrcv2
600bDC**                 parm                    slrcv3
600bD **
600bDC**                 parm                    stock1            5 0
600bDC**                 parm                    stock2            3 0
600bDC**                 parm                    stock3            3 0
600bD **
600bDC**                 parm                    avail1            5 0
600bDC**                 parm                    avail2            3 0
600bDC**                 parm                    avail3            3 0
600bD **
600bDC**                 endsr

600bA*----------------------------------------------------------------
600bA*  ZZCLOSE    Close transaction and label
600bA*----------------------------------------------------------------
600bA
600bAC     zzclose       begsr

     *  Zero transaction totals

     C                   call      'ADJTRAN2'
     C                   parm      '*DECTTL'     @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      $pttrn#       @ptrn#            7 0
     C                   parm      ' '           @ptask            6
740aDC*                  parm      0             @pwhse            3 0
740aMC                   parm      lbwhse        @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      $ptcube       @pcube            9 3
     C                   parm      $ptswgt       @pswgt            9 2
     C                   parm      $ptpcs        @ppcs             5 0
     C                   parm      $ptaisl       @paisl            5 0
     C                   parm      $ptqty1       @pqty1            5 0
     C                   parm      $ptqty2       @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
600jDC*                  parm      0             @pdate            8 0
600jDC*                  parm      0             @ptime            6 0
600jMC                   parm      0             @pdate            8 0
600jMC                   parm      0             @ptime            6 0
     C                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     *  Close transaction

     C                   call      'ADJTRAN2'
     C                   parm      '*CLOSE'      @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      lbtrn#        @ptrn#            7 0
     C                   parm      ' '           @ptask            6
740aDC*                  parm      0             @pwhse            3 0
740aMC                   parm      lbwhse        @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
600eMC                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     *  Close label

     C     lbkey         chain     label
     C                   if        %found(label)
     C                   eval      lbqpck = 0
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   update    lbrec
     C                   endif

640cA*  cleanup POASN file
640cA*
640cA*  Make sure the program exist
640cA*
640cAC                   eval      qcmd = 'CHKOBJ '
640cAC                                  + 'OBJ(GETASN) '
640cAC                                  + 'OBJTYPE(*PGM)'
640cA
640cAC                   call      'QCMDEXC'                            99
640cAC                   parm                    qcmd             80
640cAC                   parm      80            qlen             15 5
640cA*
640cA*  Only continue if program is found
640cA*
640cAC                   if        *in99 = *off
640cAc                   if        lilcns <> ' '
640cAc                   eval      $ascmd = '*RMVLCNS'
640cAC                   call      'GETASN'
640cAc                   parm                    $ascmd            8
640cAC                   parm      ' '           $ASRTN            8
640cAC                   parm      lbwhse        $AWHSE            3 0
640cAC                   parm      ' '           $ASPO             9
640cAC                   parm      ' '           $ASLPN           50
640cAC                   parm                    lilcns
640cAC                   parm      ' '           $ASLOT           20
640cAC                   parm      ' '           $ASITM           15
640cAC                   parm      0             $ASSEQ            5 0
640cAC                   parm      0             $ASQTY            8 0
640cAC                   parm      0             $ASMFD            6 0
640cAC                   parm      0             $ASMFE            6 0
640cAC                   parm      0             $ASWGT           11 3
640cAC                   endif
640cAC                   else
640cAC                   eval      *in99 = *off
640cAC                   endif
640cAC*
650aAc                   exsr      zzrcvpodelete
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      error = *off
     *
     *  Define key for main file.
     *
     C     lbkey         klist
     C                   kfld                    $plbl#
520a *
520a *  Define key for LINCENSE file.
520a *
520a C     likey         klist
520a C                   kfld                    lbwhse
520a C                   kfld                    lbtrn#
600bD **
600bD ** Define key for LICINFO file.
600bD **
600bDC**   lnkey         klist
600bDC**                 kfld                    lbwhse
600bDC**                 kfld                    kytype
600bDC**                 kfld                    kylcns
600bDC**                 kfld                    kycode
600bDC**                 kfld                    kycseq
     *
     *  Define key for POHDR file.
     *
     C     phkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbpo
     *
     *  Define key for PODTL file.
     *
     C     pdkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbpo
     C                   kfld                    lbseq
     C                   kfld                    lbitem
     *
     C     partky        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbpo
409 A*
409 A*  Define key for POMFR file.
409 A*
409 AC     pmkey         klist
409 AC                   kfld                    lblbl#
600bD **
600bD ** Define key for SLOT2 file.
600bD **
600bDC**   slkey         klist
600bDC**                 kfld                    lbwhse
600bDC**                 kfld                    lbwhdp
600bDC**                 kfld                    lbdisp
414 A*
414 A*    Key list for PORCV1
414 A*
414 AC     keypor        klist
414 AC                   kfld                    $ptrn#
     *
     *   Cannot delete closed transaction.
     *
600bDC**   lbkey         chain     label                              79
600bMC     lbkey         chain(n)  label                              79
     C                   eval      svqpck = lbqpck
500 A*
500 A*   Check if department is a "live" department.
500 AC                   if        not *in79
500 AC                   call      'CHKLIVE'
640 AC                   parm      lbwhse        $cwhse            3 0
500 AC                   parm      lbwhdp        $cwhdp            5
500 AC                   parm      *blanks       $crtn             8
500 AC                   else
500 AC                   eval      $crtn = '*LIVE   '
500 AC                   endif
500 A*
409 AC                   eval      svswgt = lbswgt
520aA*    See if we can use weight in LICINFO
520aAC     likey         chain     license1
520aAC                   if        %found
730aAc                   if        %subst(lilcns:1:3) = '*DP'
730aAc                   eval      error = *on
730aAc                   leavesr
730aAc                   endif
600bDC**                 eval      kytype = 'P'
600bDC**                 eval      kylcns = lilcns
600bDC**                 eval      kycode = '*AVGWGT'
600bDC**                 eval      kycseq = 1
600bDC**   lnkey         chain     licinfo
600bDC**                 if        %found
520aAC**                 movel     lnvalue       svswgt
600bDC**                 eval      nwswgt = %trimr(lnvalue)
600bDC**                 eval      svswgt = %dec(nwswgt:7:2)
600bDC**                 eval      svswgt = svswgt * lbqpck
600bDC**                 endif
600bA
600bAC                   exsr      clr$licinfo
600bA
600bAC                   eval      $lnwhse  = lbwhse
600bAC                   eval      $lnlcns  = lilcns
600bAC                   eval      $lntype  = 'P'
600bA
640dDC*                  eval      $lncodeu(1) = *on
640dDC*                  eval      $lncode(1) = '*AVGWGT'
640dDC*                  eval      $lncseq(1) = 1
600bA
600bAC                   eval      $dricommand = '*LICINFO'
600bAC                   eval      $drisubcmd  = '%GET'
600bAC                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *on
600bAC                   eval      zmflag  = *off
600bAC                   exsr      zzzdricop
600bAC                   if        not error
640dDC*                  eval      svswgt = lbqpck * $lnvalnum(1)
640dMC                   eval      svswgt = $lnttllbs
600bAC                   endif
600bAC                   eval      error = *off
520aAC                   endif
500 A*
500 A*    Allow non-"live" departments to have Closed transactions
500 A*    Reversed.
     C                   if        lbstat = 'C'  and
500 AC                             $crtn = '*LIVE   '  or
500 A*    IF non-"live" department and rcv qty = 0 , then error.
500 AC                             $crtn = '*NOTLIVE'  and
500 AC                             lbqpck = 0
     C                   eval      error = *on
650cAC                   if        rtnMsgType = 'TEXT'
650cAC                   eval      $prtn = 'NODELT '
650cAC                   eval      $perm = 'Cannot Delete Closed '
650cAC                                   + 'Transaction.'
650cAc                   else
     C                   exsr      zm4402
     C                   eval      $prtn = '*PGMQ   '
650cAc                   endif
401 AC                   goto      endinz
     C                   endif
401 A*
401 A*   Cannot delete transactions whose PO is ready to export.
401 A*
401 AC     phkey         chain(n)  pohdr                              79
401 AC                   if        not *in79  and
401 AC                             phstat = '3'
401 AC                   eval      error = *on
650cAC                   if        rtnMsgType = 'TEXT'
650cAC                   eval      $prtn = 'NODELT1'
650cAC                   eval      $perm = 'Cannot Delete Transaction '
650cAC                                   + 'PO is ready for export'
650cAc                   else
401 AC                   exsr      zm4403
401 AC                   eval      $prtn = '*PGMQ   '
650cAc                   endif
401 AC                   goto      endinz
401 AC                   endif
     *
410 A*
410 A*   Cannot delete transactions if after delete, qty is < 0.
410 A*
600bDC**   slkey         chain     slot2                              79
600bDC**                 if        not *in79
600bA
710aAC                   if        $crtn <> '*NOTLIVE'
600bAC                   exsr      clr$slot
600bAC                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = lbwhse
600bAC                   eval      $slwhdpu = *on
600bAC                   eval      $slwhdp  = lbwhdp
600bAC                   eval      $sldispu = *on
600baC                   eval      $sldisp  = lbdisp
640aAC                   eval      $saitemu = *on
640aAC                   eval      $saitem  = lbitem
640aA
640aAC                   eval      $sacodeu = *on
640aAC                   eval      $sacode  = '@R'
640aA
640aAC                   eval      $saqtyu  = *on
640aAC                   eval      $saqty1  = 0
640aAC                   eval      $saqty2  = 0
640aAC                   eval      $saqty3  = 0
640aAC                   select
640aAC                   when      lbutyp = 'N'
640aAC                   eval      $saqty1  = -(lbqpck)
640aAC                   when      lbutyp = '1'
640aAC                   eval      $saqty2  = -(lbqpck)
640aAC                   when      lbutyp = '2'
640aaC                   eval      $saqty2  = -(lbqpck)
640aAC                   endsl
640aA
600bA
600bAC                   eval      $dricommand = '*SLOT'
640aDC**                 eval      $drisubcmd  = '%GET'
640aMC                   eval      $drisubcmd  = '%VERIFY'
600bAC                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *on
600bAC                   eval      zmsflag = *on
600bAC                   exsr      zzzdricop
640aAC                   if        error
640aAC                   eval      $prtn = '*PGMQ'
640aAC                   leavesr
640aAC                   endif
710aAC                   endif
640aDC*                  if        not error
640aDC*                  eval      lftqty = 0
600bDC**                 exsr      zzaval
640aDC*                  select
640aDC*                  when      lbutyp = 'N'
600bMC*                  eval      lftqty = $slavl1 - lbqalc
640aDC*                  if        lftqty < 0
640aDC*                  eval      error = *on
640aDC*                  exsr      zm4404
640aDC*                  eval      $prtn = '*PGMQ   '
640aDC*                  goto      endinz
640aDC*                  endif
410 A*
640aDC*                  when      lbutyp = '1'
600bMC*                  eval      lftqty = $slavl2 - lbqalc
640aDC*                  if        lftqty < 0
640aDC*                  eval      error = *on
640aDC*                  exsr      zm4404
640aDC*                  eval      $prtn = '*PGMQ   '
640aDC*                  goto      endinz
640aDC*                  endif
410 A*
640aDC*                  when      lbutyp = '2'
600bMC*                  eval      lftqty = $slavl3 - lbqalc
640aDC*                  if        lftqty < 0
640aDC*                  eval      error = *on
640aDC*                  exsr      zm4404
640aDC*                  eval      $prtn = '*PGMQ   '
640aDC*                  goto      endinz
640aDC*                  endif
640aDC*                  endsl
640aDC*                  endif
410 A*
413 A*
413 A*   Cannot delete transactions if already started.
413 A*
600bDC**   lbtrn#        chain     pirtran                            79
600bDC**                 if        *in79  or
600bAC                   exsr      clr$pirtran
600bAC                   eval      $pttrn#u = *on
600bAC                   eval      $pttrn#  = lbtrn#
600bAC                   eval      $dricommand = '*PIRTRAN'
600bAC                   eval      $drisubcmd  = '%GET'
600bAC                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *on
600bAC                   eval      zmflag = *off
600bAC                   exsr      zzzdricop
600bAC                   if        error or
600bMC                             $ptstat <> '1'  and
500 AC                             $crtn = '*LIVE   '
413 AC                   eval      error = *on
650cAC                   if        rtnMsgType = 'TEXT'
650cAC                   eval      $prtn = 'NODELT2'
650cAC                   eval      $perm = 'Cannot Delete Transaction '
650cAC                                   + 'Transaction already started'
650cAc                   else
413 AC                   exsr      zm4405
413 AC                   eval      $prtn = '*PGMQ   '
650cAc                   endif
413 AC                   goto      endinz
413 AC                   endif
     *
414 A*
414 A*    Get User's employee number to be written to PORCV file
414 A*    if any records are flagged as touched.
414 A*
414 AC                   call      'GETUSER'
600bMC                   parm      #curruser     $code            10
414 AC                   parm      0             $whse             3 0
414 AC                   parm      0             $emp#             5 0
414 AC                   parm      *blanks       $fnam            15
414 AC                   parm      *blanks       $init             1
414 AC                   parm      *blanks       $lnam            20
414 AC                   parm      *blanks       $whdp             5
414 AC                   parm      *blanks       $styp             1
414 AC                   parm      *blanks       $shft             6
414 AC                   parm      *blanks       $crew             6
414 AC                   parm      0             $nhrs             3 1
414 AC                   parm      *blanks       $rtn              8
414 A*
414 A*  Convert today's date into century format.
414 A*
414 AC                   eval      $cvcmd = '*CURCMD '
414 AC                   call      @cvtdt
414 AC                   parm                    $cvtdt
414 AC                   eval      today = $cvd8o
    A*
410 MC     endinz        endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   eval      $md = *blanks
     C                   movea     msg(1)        $md(1)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr
650aA*----------------------------------------------------------------
650aA*  ZZRCVPODELETE Create a negative qty transaction for RCVPO
650aA*----------------------------------------------------------------
650aA
650aAC     zzrcvpodelete begsr

650aA*  Send Negative qty Transaction
650aAc                   eval      del$ptpcs = $ptpcs * -1
650aAc                   eval      del$ptqty1 = $ptqty1 * -1
740bAc                   if        $puser <> ' ' and $puser <> '0000000000'
740bAc                   eval      $puserin = $puser
740bAc                   endif
650aAC                   call      @crtrcv
650aAC                   parm      '*PO'         $lcmdr           10
650aAC                   parm      '*DELETE'     $lsubcmd         10
650aAC                   parm      lbwhse        @lwhse            3 0
650aAC                   parm      del$ptpcs     $lpcs             5 0
650aAC                   parm      del$ptqty1    $lpallets         5 0
650aAC                   parm                    $lsavetrn         7 0
730dDC*                  parm                    $ppo              9
730dMC                   parm      lbpo          $ppo              9
650aAC                   parm      lbstyp        $litstyp          1
650aAC                   parm      lbwhdp        $litwhdp          5
650aAC                   parm                    $lrtnr           10
740bAC                   parm                    $puserin         10

650aAC                   endsr
730eA*----------------------------------------------------------------
730eA*
730eA*  ZZRTI - real time interface
730eA*
730eAC     zzRTI         begsr
730eAc                   eval      lCommand = 'Delete'
730eAC                   call      'PO728SCL'
730eAC                   parm                    $lnwhse
730eAC                   parm                    $lnlcns
730eAC                   parm                    lCommand

730eAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUHDR
     *
     C     zzuhdr        begsr
401 MC                   eval      full = *on
     C                   eval      part = *off
401 AC                   eval      recv = *off
     C     partky        setll     podtl                              79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     partky        reade     podtl                                  79
     C                   move      *in79         eof
     C                   if        not *in79
401 AC                   if        pdqrc1 < pdqor1
401 AC                   eval      part = *on
401 AC                   eval      full = *off
401 AC                   endif
401 A*
401 AC                   if        pdqrc2 < pdqor2
401 AC                   eval      part = *on
401 AC                   eval      full = *off
401 AC                   endif
401 A*
401 AC                   if        pdqrc3 < pdqor3
401 AC                   eval      part = *on
401 AC                   eval      full = *off
401 AC                   endif
401 A*
401 AC                   if        pdqrc1 > 0
401 AC                   eval      recv = *on
401 AC                   endif
401 A*
401 AC                   if        pdqrc2 > 0
401 AC                   eval      recv = *on
401 AC                   endif
401 A*
401 AC                   if        pdqrc3 > 0
401 AC                   eval      recv = *on
401 AC                   endif
401 A*
     C                   endif
     C                   enddo
401 A*
401 AC                   if        recv = *off
401 AC                   eval      full = *off
401 AC                   eval      part = *off
401 AC                   endif
401 A*
     C     phkey         chain     pohdr                              79
     C                   if        not *in79
     C                   if        part = *on
     C                   eval      phstat = *on
     C                   endif
     C                   if        full = *on
     C                   eval      phstat = '2'
     C                   endif
401 AC                   if        part = *off  and
401 AC                             full = *off
401 AC                   eval      phstat = *off
401 AC                   endif
     C                   update    phrec
     C                   endif
     *
     C     endhdr        endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZUCI    Delete UCI records.
650bA*
650bA /free
650bA   begsr zzuci;
650bA     exsr clr$uciinfo;
650bA       // warehouse
650bA       $uiWhse = lbwhse;

650bA       // License
650bA         $uiLcns = lilcns;

650bA       $dricommand = '*UCIINFO';
650bA       $drisubcmd  = '%CANCEL';
650bA       $drisys2upd = 'D';
650bA       chk4err = *on;
650bA       zmflag  = *off;
650bA       exsr zzzdricop;
650bA       if error;
650bA       endif;
650bA   endsr;
650bA /end-free

     *----------------------------------------------------------------
     *
     *  ZZUMFR   Delete POMFR records.
     *
409 AC     zzumfr        begsr
     C     pmkey         chain     pomfr1                             79
     C                   if        not *in79
     C                   delete    pmrec
     C                   endif
409 AC     endmfr        endsr

600bA*----------------------------------------------------------------
600bA*  zzUpdRcvSlt   Remove qty from corresponding RCV slot
600bA*----------------------------------------------------------------
600bA
600bAC     zzUpdRcvSlt   begsr

640bA*  First, we need to do some Directed Putaway cleanup.
640bA*     DRISLOT will determine if we are working with a DP.
640bA
640bAC                   exsr      clr$slot
640bAC                   eval      $slwhseu = *on
640bAC                   eval      $slwhse  = lbwhse
640bAC                   eval      $slwhdpu = *on
640bAC                   eval      $slwhdp  = lbwhdp
640bAC                   eval      $sldispu = *on
640bAC                   eval      $sldisp  = lbdsp2
640bAC                   eval      $saitemu = *on
640bAC                   eval      $saitem  = lbitem
640bA
640bAC                   eval      $dricommand = '*SLOT'
640bAC                   eval      $drisubcmd  = '%DPUNDO'
640bAC                   eval      $drisys2upd = 'D'
640bAC                   eval      chk4err = *on
640bAC                   eval      zmsflag = *on
640bAC                   exsr      zzzdricop
640bA
640bAC                   if        error = *on
640bAC                   eval      $prtn = '*PGMQ'
640bAC                   leavesr
640bAC                   endif
640bA
640bA*  Now we can proceed with the RCV stuff

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = lbwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = lbwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = lbdisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = lbitem

600bAC                   eval      $sacodeu = *on
600bAC                   eval      $sacode  = '@R'
600bAC                   eval      $samemou = *on
600bAC                   eval      $samemo  = 'PO144 - Lbl#'
600bAC                                      + %editc(lblbl#:'P')
600bAC                   eval      $sabyu   = *on
600bAC                   eval      $saby    = #curruser

     C                   eval      $saqtyu  = *on
     C                   eval      $saqty1  = 0
     C                   eval      $saqty2  = 0
     C                   eval      $saqty3  = 0
     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      $saqty1  = -(lbqpck)
     C                   when      lbutyp = '1'
     C                   eval      $saqty2  = -(lbqpck)
     C                   when      lbutyp = '2'
     C                   eval      $saqty2  = -(lbqpck)
     C                   endsl

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'RCV'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = lbtrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = lblbl#

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
640bA
640bAC                   if        error = *on
640bAC                   eval      $prtn = '*PGMQ'
640bAC                   leavesr
640bAC                   endif

     C                   endsr
414 A*---------------------------------------------------------------
414 A*
414 A*  ZZURCV   Update PORCV file.
414 A*
414 AC     zzurcv        begsr
414 A*
414 A*   Read PORCV.  If not found then add...
414 A*
414 AC     keypor        setgt     porcv1
414 AC     keypor        readpe    porcv1                                 55
414 AC                   if        *in55
414 AC                   eval      porwhs = pdwhse
414 AC                   eval      porpo = pdpo
414 AC                   eval      porseq = pdseq
414 AC                   eval      pordte = today
414 AC                   time                    portim
600bMC                   eval      porusr = #curruser
414 AC                   eval      pordev = #job
414 AC                   eval      poremp = $emp#
414 AC                   eval      portrn = $ptrn#
416 MC                   eval      porlic = *blanks
414 AC                   eval      porlbl = 0
414 AC                   eval      poract = 'D'
416 AC                   eval      poredt = 0
416 AC                   eval      poreti = 0
414 AC                   write     porrec
414 AC                   else
414 AC                   eval      pordte = today
414 AC                   time                    portim
600bMC                   eval      porusr = #curruser
414 AC                   eval      poremp = $emp#
414 AC                   eval      poract = 'D'
416 AC                   eval      poredt = 0
416 AC                   eval      poreti = 0
500aMC                   update    porrec
500aD**                   WRITEPORREC
414 AC                   endif
     C                   endsr

600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------
600bA*                     DRI SUBROUTINES
600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------

600bA*----------------------------------------------------------------
600bA*  clr$license  Clear $license data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = $emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = lbwhse
     C                   eval      $liTowhseu = *on
     C                   endsr

600bA*----------------------------------------------------------------
600bA*  clr$licinfo  Clear $licinfo data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
640dAC                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnemp# = $emp#
     C                   eval      $lnuser = #curruser
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobn
     C                   endsr

600bA*----------------------------------------------------------------
600bA*  clr$pirtran  Clear $pirtran data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$pirtran   begsr
     C                   eval      savever# = $ptver#
     C                   clear                   $pirtran
     C                   eval      $ptver# = savever#
     C                   endsr

600bA*----------------------------------------------------------------
600bA*  clr$slot  Clear $slot data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = $emp#
     C                   endsr

650bA*----------------------------------------------------------------
650bA*  clr$uciinfo  Clear $uciinfo data structure fields
650bA*----------------------------------------------------------------

650bAC     clr$uciinfo   begsr
650bAC                   eval      savever# = $uiver#
650bAC                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
650bAC                   eval      $uiver# = savever#
650bAC                   eval      $uiaddemp = $emp#
650bAC                   eval      $uiaddusr = #curruser
650bAC                   eval      $uiaddpgm  = #pgm
650bAC                   eval      $uiaddjob  = #job
650baC                   eval      $uiaddnbr = #jobnbr
650bAC                   endsr

600bA*----------------------------------------------------------------
600bA*  zzzdriclose   Close any open files or programs.
600bA*----------------------------------------------------------------
600bA
600bAC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

720aAC                   eval      $dricommand = '*UCIINFO'
720aAC                   eval      $drisubcmd  = '%CLOSE'
720aAC                   eval      $drisys2upd = 'D'
720aAC                   eval      chk4err = *off
720aAC                   exsr      zzzdricop

     C                   endsr

600bA*----------------------------------------------------------------
600bA*  zzzdricop  Call DRICOP
600bA*----------------------------------------------------------------
600bA
600bAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
640dAC                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*PIRTRAN'
     C                   eval      $dridata = $pirtran
650bAC                   when      $dricommand = '*UCIINFO'
650bAC                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
640dAC                             or $dricommand = '*LICINFO'
720aAC                             or $dricommand = '*UCIINFO'
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
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   select
770bDc*                  when      $prtn = 'TEXT'
770bMc                   when      rtnMsgType = 'TEXT'
730cAc                   eval      $perm = $DRIMESSAGE
     C                   when      zmsflag
     C                   exsr      zm0105s
     C                   when      zmflag
     C**                 exsr      zm0105
     C                   endsl

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   select
770bDc*                  when      $prtn = 'TEXT'
770bMc                   when      rtnMsgType = 'TEXT'
730cAc                   eval      $perm = $DRIMESSAGE
     C                   when      zmsflag
     C                   exsr      zm0001s
     C                   when      zmflag
     C**                 exsr      zm0001
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
640dAC                   eval      $licinfo2= $dridata2
     C                   when      $dricommand = '*PIRTRAN'
     C                   eval      $pirtran = $dridata
650bAC                   when      $dricommand = '*UCIINFO'
650bAC                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
PO
