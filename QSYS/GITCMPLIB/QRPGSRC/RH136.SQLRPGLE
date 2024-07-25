      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RH136     Move Exported route to Open,  Printed, or
     *            Closed status.
     *
     *  20 October 2010
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
530 A*    10/20/10  RBD  5.30
     *      - Created.
640aA*    06/08/12  LMC  6.40a
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
650aA*    03/15/13  LMC  6.50a
     *      - Enh: Added CWLOG. This adds a call to a new program
     *        CW800 and new file CWLOG.
650bA*    12/27/13  DAS  6.50b
     *      - RHSHPD no longer used for locking route.
     *      - Program did not need to be changed because it is okay
     *        to clear RHSHPD when creating new RTEHED record.
650cA*    10/14/14  RBD  6.50c
     *      - Disabled hidden option VO in RH160A, which required no
     *        changes in this program since RH160A will no longer be
     *        calling this program with cmd *UNDO.  Option VO should
     *        remain disabled until changes can be made to this pgm
     *        to either not update slots at all for option VO or only
     *        update slots where the item has not been changed, and
     *        that determination has yet to be made. In the meantime,
     *        if you wish to take a route from exported to open status,
     *        use option VP to get it to printed status, then undo it.
     *
CWD A*    04/26/16  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. WORKLBL5 had order id, descending
     *        added to key for tote processing.
650dA*    11/14/17  RBD  6.50a
     *      - Recompiled, RTESTP file changed.
730aA*    11/04/19  DAS  7.30a
     *      - Revised to use PIRTRANW
730bA*    12/05/19  DAS  7.30b
     *      - Revised to call PIRLBL#W instead of PIRLBL#
     *      - Added file BFCDEBUG to record error getting next label#.
     *      - Forcing divide by zero to halt program if error.
750aA*    04/02/21  DAS  7.50a
     *      - Added *UNDOTRN. Only called from QDTRNRESET.
750bA*    06/29/21  LMC  7.50b
     *      - Added passtran file to the *UNDOTRN process.
     *----------------------------------------------------------------
     *  Notes
     *
     *  This program attempts to take a route from Exported status to
     *  Open,  Printed, or Closed status.
     *
     *   When going from Exported to Closed, change the status of route
     *   header and order header records.
     *
     *   When going from Exported to Printed, change the status of the
     *   route header, label, order, and transaction records. Also zero
     *   picked qty fields in order detail.
     *
     *   If you want to go from Exported to Built status, you will need
     *   to reverse the route to Open status, then use Truck Builder to
     *   build it.
     *
     *   To prevent unpredictable results when the route is allocated and
     *   picked a second time, this program will assign a new route id to
     *   the route if going from Exported to Open status.
     *   The original route header record will be given a status
     *   of '8', a new route header record will be created and all order
     *   records will be updated with the new route id.
     *
     *   In addition, if going from Exported to Open status,
     *   the picked quantity in the Label and WorkLbl files will be set
     *   to zero to reflect that the record was closed to zero. The
     *   original picked quantity will be saved in the RteUndo file. Also,
     *   the LBVRFY file will be set to 'U' to flag that the record was
     *   'Undone" by this program.
     *
     *   This program does not delete a route, it only sets it back to
     *   an Open status if that was the option requested.
     *   After that, the route can be deleted through the
     *   Open routes display, if needed. This was done in order to prevent
     *   routes from accidentally being deleted.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frtehed    uf a e           k disk
     Frtesum    uf a e           k disk
     Frtecsum   uf a e           k disk
     Frtestp    uf a e           k disk
     FLabel13   uf a e           k disk
     Fworklbl5  uf   e           k disk    rename(lwrec : lwrec5)
     Fslot2     uf   e           k disk
     Fordh3     uf   e           k disk
     Fordc      uf   e           k disk
     Fordd      uf   e           k disk
     Fordt      uf   e           k disk
730aDF*irtran   uf   e           k disk
730aMFpirtranw  uf   e           k disk
     Fbatctl    uf   e           k disk
     Fbulkdrp   uf   e           k disk
     Foptions   if   e           k disk
     Fpiritem   if   e           k disk
     Frunner6   uf   e           k disk    rename(rurec : rurec6)
     Fordhm     uf   e           k disk
750aAFmultran1w uf   e           k disk
     Fitemadj   o    e             disk
     Frteundo   o    e             disk
730bAFbfcdebug  o  a e           k disk    rename(bdrec : bdbrec)

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a30             s              1    dim(30)
     D a50             s              1    dim(50)
     D msg             s             50    dim(5) ctdata perrcd(1)

650aA*----------------------------------------------------------------
650aA*  Data Formats
650aA*----------------------------------------------------------------
650aA /COPY *libl/qcopysrc,C#CWLOG
650aAD savever#        s                   like($cwver#)
     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

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
     D  $pwhse                19     21  0
     D  $prte                 22     26
     D  $prtid                27     31
750a D  $ptrn#                32     38  0

     *------------------------------------------------------------------
     * Constants ...
     *------------------------------------------------------------------
     D   forever       c                   const('1')

     *------------------------------------------------------------------
     * Misc defs ...
     *------------------------------------------------------------------

     D currstamp       s               z
     D flagop          s              1    inz(*off)
     D kywhse          s                   like(lbwhse)
     D kyitem          s                   like(lbitem)
     D kytrn#          s                   like(pttrn#)
     D lasttrn#        s              7  0
     D lasttime        s              6  0
     D newrtid         s                   like(rhrtid)
     D rundate         s              8  0
     D runtime         s              6  0
     D svqty2          s                   like(lbqpck)
     D svqpck          s                   like(lbqpck)
     D svstat          s                   like(lbstat)
     D tempa7          s              7
     D today           s              8  0
750aAD trnFound        s               n

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------
     D @cvtdt          c                   const('CVTDTE')
     D @clcdr          c                   const('CLCDUR')
     D @getsi          c                   const('GETSLOTITM')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------
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
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0
     D  $cvdr2               146    153
     D  $cvvl2               154    158  0
     D  $cvdr3               159    166
     D  $cvvl3               167    171  0
     D  $cvdr4               172    179
     D  $cvvl4               180    184  0

     *----------------------------------------------------------------
     *  *CLOSE   -  Transaction close options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEXCD  -  Exception labels picked - code.
     *    OPNSCD  -  Not enough stock to close transaction - code.
     *    OPDICD  -  Different item found in slot - code.
     *
     * Data structure
     *
     D opdata          ds
     D  opexcd                 1      2
     D  opnscd                 3      4
     D  opdicd                 5      6
     D  clsend               117    117

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

730bA /copy qcopysrc,c#pgminfds
730bDD*               sds
730bDD* #prog            *proc
730bDD* #job                 244    253
730bDD* #user                254    263
730bDD* #jobn                264    269
730bDD* #jobdt               276    281  0
730bDD* #jobtm               282    287  0

640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aA
640aAD wrttran1        pr                  extpgm('WRTTRAN1')
640aA * Input
640aAD   ppcmd                        8
640aAD   ppwait                       2  0
640aAD   ppwhse                       3  0
640aAD   pptran#                      7  0
640aAD   ppfromdate                   8  0
640aAD   pptodate                     8  0
640aAD   ppemp#                       5  0
650aA /copy qcopysrc,p.cw800
650aA /copy qcopysrc,p.getuser
730bA /copy qcopysrc,p.pirlbl#w
     *----------------------------------------------------------------
     *  Work Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #litem          s             15
     D forevr          s              1
     D hld_rhstat      s                   like(rhstat)
640aAD wrtpcmd         s             10
640aAD wrtpwait        s              2  0
640aAD wrtpwhse        s              3  0
640aAD wrtptran#       s                   like(pttrn#)
640aAD wrtpfrmdate     s              8  0
640aAD wrtptodate      s              8  0
640aAd wrtpemp#        s                   like(ptemp#)
650aAD CWcmd           s             10
650aAD CWpgm           s             10
650aAD CWrtn           s             10
650aAD CWmsg           s             60
650aAD CWdata          s            512
650aAD processstatus   s             10
650aAD e$whse          s              3  0
650aAD e$emp#          s              5  0
650aAD e$fnam          s             15
650aAD e$init          s              1
650aAD e$lnam          s             20
650aAD e$whdp          s              5
650aAD e$styp          s              1
650aAD e$shft          s              6
650aAD e$crew          s              6
650aAD e$nhrs          s              3  1
650aAD e$rtn           s              8
650aAD e$bpu           s              1
650aAD e$lng           s              2
730bAD pNextLbl#       s             11  0
730bAd nextLbl#        s                   like(lwlbl#)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------
     *
     *    Input Parameters
     *      $PCMD   *UNDO    -  Undo route to open status.
750aA*      $PCMD   *UNDOTRN -  Undo transaction
     *      $PCMD   *PRINTED -  Reverse route to printed status.
     *      $PCMD   *CLOSED  -  Reverse route to closed status.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $MSGK   Message id sent to previous message queue.
     *      $PRTN   *OK      - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $parms

     C                   eval      $prtn = '*OK'

     *----------------------------------------------------------------
     *  Main line

     *  Grab RteHed record.

     C     keyrte        chain     rtehed                             7978

     *    Record not found.

     C                   if        *in79 = *on
     C                   movea     msg(1)        a50
     C                   movea     $prte         a50(7)
     C                   movea     a50           errmsg
     C                   exsr      zm0105
     C                   eval      $prtn = '*PGMQ'
     C                   goto      bottom
     C                   endif

     *    Record is locked.

     C                   if        *in78 = *on
     C                   movea     msg(2)        a50
     C                   movea     $prte         a50(7)
     C                   movea     a50           errmsg
     C                   exsr      zm0105
     C                   eval      $prtn = '*PGMQ'
     C                   goto      bottom
     C                   endif

     *    Route is not at Exported status.
750aA*      when not *UNDOTRN

     C                   if        rhstat <> '6'
750aAC                             and $pcmd <> '*UNDOTRN'
     C                   movea     msg(3)        a50
     C                   movea     $prte         a50(7)
     C                   movea     a50           errmsg
     C                   exsr      zm0105
     C                   eval      $prtn = '*PGMQ'
     C                   unlock    rtehed
     C                   goto      bottom
     C                   endif

750aA*    Route is not at Printed status for *UNDOTRN
750aA
750aAC                   if        $pcmd = '*UNDOTRN' and rhstat <> '4'
750aAC                   eval      errmsg = 'Route Id (' + %trim($prtid) + ') '
750aAC                                    + 'must be status 4'
750aAC                   exsr      zm0105
750aAC                   eval      $prtn = '*PGMQ'
750aAC                   unlock    rtehed
750aAC                   goto      bottom
750aAC                   endif

     C                   select

     *  If reversing route to Closed status, change route header
     *  status, go down to set info msg, then you're done.

     C                   when      $pcmd = '*CLOSED'
     C                   eval      hld_rhstat = '5'
     C                   exsr      updRouteStat
     C                   goto      infmsg

     *  If reversing route to Printed status, change the status
     *  of route header, label, order, and transaction records.
     *  Zero out picked qty's in order detail records.
     *  Go down to set info msg and you're done.

     C                   when      $pcmd = '*PRINTED'
     C                   eval      hld_rhstat = '4'
     C                   exsr      updRouteStat
     C                   exsr      updLabelStat
     C                   exsr      updOrders
     C                   goto      infmsg

750aA*  If reversing transaction, just undo labels
750aA
750aAC                   when      $pcmd = '*UNDOTRN'
750aAC                   unlock    rtehed
750aAC                   exsr      undotrn
750aAC                   goto      bottom

     *  If reversing route to Open status, change the status
     *  of original route header, get new route id for open
     *  route, then undo, delete, update, and write associated
     *  records.

     C                   when      $pcmd = '*UNDO'

     *  Get new route id.

     C                   call      'PIRRTE#'
     C                   parm      $pwhse        $rwhse            3 0
     C                   parm                    newrtid

     *  Undo WorkLbl records.

     C                   exsr      undoworklbl

     *  Undo Label records.

     C                   exsr      undolabel

     *  Undo Order records.

     C                   exsr      undoorders

     *  Delete ORDAD sscc-18 records.

     C                   call      'OR639D'
     C                   parm      $pwhse        $rwhse
     C                   parm                    $prtid

     *  Delete TOTEHDR records.

     C                   call      'OR635D'
     C                   parm      $pwhse        $rwhse
     C                   parm                    $prtid

     *  Delete ORDP records.

     C                   call      'OR637D'
     C                   parm      $pwhse        $rwhse
     C                   parm                    $prtid

     *  Delete ORDBSUM records.

     C                   call      'OR611D'
     C                   parm      $pwhse        $rwhse
     C                   parm                    $prtid

     *  Update batch record.

     C     rhpbat        chain     btrec                              79
     C                   if        *in79 = *off
     C                   eval      btstat = '9'
     C                   eval      btendd = rundate
     C                   eval      btendt = runtime
     C                   update    btrec
     C                   endif

     *  Update original route record.

     C                   eval      rhstat = '8'
     C                   eval      rhstsd = rundate
     C                   eval      rhstst = runtime
     C                   update    rhrec

     *  Get original RteSum record.

     C     keyrte        setll     rtesum
     C                   dow       forevr = forevr
     C     keyrte        reade     rtesum                                 79

     C                   if        *in79 = *on
     C                   leave
     C                   endif

     *    Create out new RteSum record.

     C                   if        *in79 = *off
     C                   eval      rsrtid = newrtid
     C                   write     rsrec
     C                   endif
     C                   enddo

     *  Get original RteCSum records.

     C     keyrte        setll     rtecsum
     C                   dow       forevr = forevr
     C     keyrte        reade     rtecsum                                79

     *    Create new RteCSum record.

     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     C                   eval      rcrtid = newrtid
     C                   eval      rcpckc = 0
     C                   eval      rcpckw = 0
     C                   eval      rcpckp = 0
     C                   write     rcrec
     C                   endsl
     C                   enddo

     *  Get original RteSum record.

     C     keyrte        setll     rtestp
     C                   dow       forevr = forevr
     C     keyrte        reade     rtestp

     C                   if        %eof(rtestp)
     C                   leave
     C                   endif

     *    Create new RteStp record.

     C                   if        not %eof(rtestp)
     C                   eval      rtsrid = newrtid
     C                   write     rtsrec
     C                   endif
     C                   enddo

     *  Create new route record.

     C                   eval      rhrtid = newrtid
     C                   eval      rhstat = '1'
     C                   eval      rhstsd = rundate
     C                   eval      rhstst = runtime
     C                   eval      rhbldd = 0
     C                   eval      rhbldt = 0
     C                   eval      rhprtd = 0
     C                   eval      rhprtt = 0
     C                   eval      rhpbat = 0
     C                   eval      rhshpd = 0
     C                   eval      rhshpt = 0
     C                   write     rhrec

     C                   endsl

     C     infmsg        tag

     C                   movea     msg(5)        a50
     C                   movea     $prte         a50(7)
     C                   movea     a50           errmsg
     C                   exsr      zm0105

     C     bottom        tag

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define key for Options file.

     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode

     *  Define partial key for LABEL13/WORKLBL5 files.

     C     keyrte        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     *  Define key for SLOT2 file from LABEL fields.

     C     keysl2        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    lbdisp

     *  Define key for SLOT2 file from WORKLBL fields.

     C     keysl2w       klist
     C                   kfld                    lwwhse
     C                   kfld                    lwwhdp
     C                   kfld                    lwdisp

     *  Define key for PIRITEM file.

     C     keyit         klist
     C                   kfld                    kywhse
     C                   kfld                    kyitem

     *  Define key for PirTran file.

     C     keypt         klist
730aAC                   kfld                    $pwhse
     C                   kfld                    kytrn#

     *  Define key for OrdD file.

     C     keyod         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord

     *  Define key for RUNNER6 file.

     C     keyru         klist
     C                   kfld                    lbwhse
     C                   kfld                    lblbl#

     *  Get current date.

     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   time                    currstamp

     *  Capture Run date/time

     C                   eval      rundate = today
     C                   time                    runtime
     C                   eval      lasttime = rutime
     C                   eval      forevr = *on

650aA /free
650aA    getUser(#user: e$whse: e$emp#: e$fnam: e$init: e$lnam:
650aA            e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
650aA            e$bpu: e$lng);
650aA /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  avail   Calculate available quantities for slot.
     *----------------------------------------------------------------

     C     avail         begsr

     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3

     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3

     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3

     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3

     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3

     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0

     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0

     C                   if        avail1 < 0
     C                   eval      avail1 = 0
     C                   endif
     C                   if        avail2 < 0
     C                   eval      avail2 = 0
     C                   endif
     C                   if        avail3 < 0
     C                   eval      avail3 = 0
     C                   endif

     C                   endsr

650aA*----------------------------------------------------------------
650aA*  clrCWLog     Clear $cwlog   data structure fields
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr ClrCWLog;

650aA     savever# = $cwver#;
650aA     clear $cwlog;
650aA     $cwver# = savever#;
650aA     $cwaddemp = e$emp#;
650aA     $cwaddusr = #user;
650aA     $cwaddpgm  = #prog;
650aA     $cwaddjob  = #job;
650aA     $cwaddnbr = #jobn;

650aA   endsr;
650aA /end-free

650aA*----------------------------------------------------------------
650aA*  ProcessCWLog  Process the CWLOG file Add/Update/Delete
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr processCWlog;
650aA     exsr clrCWLog;
650aA     $cwwhse = ocwhse;
650aA     $cwitem = ocitem;
650aA     $cwseltrn# = octran;
650aA     $cwsellbl# = oclbl#;
650aA     $cwselord  = ocord;
650aA     $cwselseq  = ocseq#;
650aA     $cwselcseq = ocseq;
650aA     $cwwgtlbs = occwgt;

650aA     cwdata = $cwlog;
650aA     cw800(processstatus: cwpgm: cwrtn: cwmsg: cwdata);

650aA     $cwlog = cwdata;

650aA   endsr;
650aA /end-free

     *----------------------------------------------------------------
     *  DelRunner  Delete Runner Flag entries.
     *----------------------------------------------------------------

     C     delrunner     begsr
     C     keyru         setll     runner6
     C                   dow       forever = forever
     C     keyru         reade     runner6
     C                   select
     C                   when      %eof(runner6)
     C                   leave

     C                   other
     C                   delete    rurec6
     C                   endsl

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  DelTrans   Delete transaction records.
     *----------------------------------------------------------------

     C     delTrans      begsr

     C                   if        kytrn# = 0 or kytrn# = lasttrn#
     C                   goto      enddelTrans
     C                   endif

730aMC     keypt         chain     pirtranw

730aMC                   if        %found(pirtranw)
     C                   delete    ptrec
640aAc                   exsr      zzwrttrandl
     C                   endif

     C                   eval      lasttrn# = kytrn#

     C     enddelTrans   endsr


     *----------------------------------------------------------------
     *  GetCloseOpt  Get *CLOSE options.
     *----------------------------------------------------------------

     C     getcloseopt   begsr

     C                   if        flagop = *off
     C                   eval      flagop = *on

     C                   eval      opcode = '*CLOSE'
     C     keyop         chain     options                            78
     C                   if        *in78 = *on
     C                   eval      opexcd = 'X1'
     C                   endif

     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  GetItem  Get item record.
     *----------------------------------------------------------------

     C     getitem       begsr

     C                   eval      #litem = kyitem
     C                   eval      #bitem = kyitem

     C     keyit         chain     piritem                            78
     C                   if        *in78
     C                   eval      ittype = *blanks
     C                   eval      itumq2 = 0
     C                   eval      itumq3 = 0
     C                   endif

     C                   eval      #bityp = ittype
     C                   eval      #bdesc = itdesc
     C                   eval      #bpdsc = itpdsc
     *
     *     If Contract, Alias or SSB item
     *       Then get Base item.
     *
     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'
     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum             2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
     C                   endif
     *     get slot item.
     C                   call      @getsi
     C                   parm      itwhse        $gwhse
     C                   parm      ititem        $gitem
     C                   parm      ' '           #sitem           15
     C                   parm                    #sityp            1
     C                   parm                    #sdesc           30
     C                   parm                    #spdsc           15
     C                   parm                    #srtn            10
     C                   parm                    #smsg            60

     C                   endsr

730bA*----------------------------------------------------------------
730bA*  GetNextLbl#    Get next label number
730bA*----------------------------------------------------------------
730bA
730bAC     getNextLbl#   begsr
      /free

         // Get next label number

         PirLbl#W($pwhse: pNextLbl#);

         // Make sure it isn't too large

         monitor;
           nextLbl# = pNextLbl#;
         on-error;
           nextLbl# = -9;
         endmon;

         // See if there was an error getting label number

         if nextLbl# <= 0;

           // Write message to BFCDEBUG

           bdvalues = 'Error getting lbl# '
                    + '(p' + %char(pNextLbl#) + '/' + %char(nextLbl#) + ') '
                    + 'for '
                    + 'Whse: ' + %char(lbwhse) + ', '
                    + 'Rtid: ' + %trimr(lbrte) + ', '
                    + 'Ord: ' + %char(lbord) + ', '
                    + 'Seq: ' + %char(lbseq) + ', '
                    + 'Itm: ' + %trimr(lbitem);
           bdtype = '*ERROR';
           exsr wrtDebug;

           // Force divide by zero error to abnormally end program.

           nextLbl# = 0;
           pNextLbl# = pNextLbl# / nextLbl#;

         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  LogIt   Log record that was changed.
     *----------------------------------------------------------------

     C     logit         begsr

     C                   eval      ruwhse = $pwhse
     C                   eval      rurtid = $prtid
     C                   eval      runewr = newrtid
     C                   time                    rutime
     C                   if        rutime < lasttime
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   endif
     C                   eval      rudate = today
     C                   eval      lasttime = rutime

     C                   select

     C                   when      rufile = 'L'
     C                   eval      runum = lblbl#
     C                   eval      ruqpck = lbqpck
     C                   eval      rustat = lbstat
     C                   eval      rusdte = lbsdte
     C                   eval      rustim = lbstim

     C                   when      rufile = 'T'
     C                   eval      runum = pttrn#
     C                   eval      ruqpck = 0
     C                   eval      rustat = ptstat
     C                   eval      rusdte = ptcdte
     C                   eval      rustim = ptctim

     C                   when      rufile = 'W'
     C                   eval      runum = lwlbl#
     C                   eval      ruqpck = lwqpck
     C                   eval      rustat = lwstat
     C                   eval      rusdte = lwsdte
     C                   eval      rustim = lwstim

     C                   endsl

     C                   write     rurec

     C                   endsr

     *----------------------------------------------------------------
     *  RmvBulk  Remove Bulk Drop records for Bulk pick labels.
     *----------------------------------------------------------------

     C     rmvbulk       begsr
     C     lblbl#        chain     bdrec                              79
     C                   if        *in79 = *off
     C                   delete    bdrec
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  RmvRunner  Remove Runner Flag entries.
     *----------------------------------------------------------------

     C     rmvrunner     begsr
     C     keyru         setll     runner6
     C                   dow       forever = forever
     C     keyru         reade     runner6
     C                   select
     C                   when      %eof(runner6)
     C                   leave

     C                   other
     C                   eval      rustat = 'D'
     C                   eval      rucdts = currstamp
     C                   update    rurec6
     C                   endsl

     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *  UndoLabel  Un-Allocate/Pick LABEL records.
     *----------------------------------------------------------------

     C     undolabel     begsr

     *  Loop through Label records for route.

     C     keyrte        setll     label13
     C                   dow       forever = forever
     C     keyrte        reade     label13                                77

     C                   if        *in77 = *on
     C                   leave
     C                   endif

     *     Only work with normal, bulk pick and merge records.

     C                   if        lbtype <> 'O' and
     C                             lbtype <> 'B' and
     C                             lbtype <> 'M'
     C                   iter
     C                   endif

     *     Only update slot for Merge labels and unclosed OUT labels.

     C                   if        lbtype = 'M' or lbasl2 = 'OUT'
     C                   goto      updlbl
     C                   endif

     *    Get Item Info.

     C                   eval      kywhse = lbwhse
     C                   eval      kyitem = lbitem
     C                   exsr      getitem

     *     Get slot record.

     C     keysl2        chain     slot2                              77
     C                   if        *in77 = *on
     C                   goto      updlbl
     C                   endif

     *  Update slot record.

     C                   select

     *    Record alredy 'Closed'

     C                   when      lbstat = 'C'

     *      Normal uom.

     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      slstk1 = slstk1 + lbqpck
     C                   eval      $acmd = '*STOCK'
     C                   eval      $aqty1 = lbqpck
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   exsr      updwhseqty

     *      Breakdown 1 uom.

     C                   when      lbutyp = '1'
     C                   eval      $acmd = '*STOCK'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = lbqpck
     C                   eval      $aqty3 = 0
     C                   exsr      undoslotstk2
     C                   exsr      updwhseqty

     *      Breakdown 2 uom.

     C                   when      lbutyp = '2'
     C                   eval      slstk3 = slstk3 + lbqpck
     C                   eval      $acmd = '*STOCK'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = lbqpck
     C                   exsr      updwhseqty

     C                   endsl

     *    Record not 'Closed', only picked.

     C                   other

     *      Normal uom.

     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      slpck1 = slpck1 - lbqpck
     C                   if        slpck1 < 0
     C                   eval      slpck1 = 0
     C                   endif
     C                   eval      $acmd = '*UNALOCN'
     C                   eval      $aqty1 = lbqpck
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   exsr      updwhseqty

     *      Breakdown 1 uom.

     C                   when      lbutyp = '1'
     C                   eval      $acmd = '*UNALOC1'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = lbqpck
     C                   eval      $aqty3 = 0
     C                   exsr      undoslotpck2
     C                   exsr      updwhseqty

     *      Breakdown 2 uom.

     C                   when      lbutyp = '2'
     C                   eval      slpck3 = slpck3 - lbqpck
     C                   if        slpck3 < 0
     C                   eval      slpck3 = 0
     C                   endif
     C                   eval      $acmd = '*UNALOC2'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = lbqpck
     C                   exsr      updwhseqty

     C                   endsl

     C                   endsl

     C                   update    slrec

     *  Update records.

     C     updlbl        tag

     C                   eval      rufile = 'L'
     C                   exsr      logit

     C                   eval      svstat = lbstat
     C                   eval      svqpck = lbqpck
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = rundate
     C                   eval      lbstim = runtime
     C                   eval      lbqpck = 0
     C                   eval      lbvrfy = 'U'
     C                   update    lbrec

     *  Remove Bulk Drop Records.
     C                   if        lbtype = 'B'
     C                   exsr      rmvbulk
     C                   endif

     *  Remove Runner Flag records.
     C                   exsr      rmvrunner

     C                   eval      kytrn# = lbtrn#
     C                   exsr      updtranrec

     *  If label record was not for a closed OUT label.
     *    Then loop and get next label record.

     C                   if        lbasl2 <> 'OUT' or
     C                             svstat <> 'C' or
     C                             svqpck = 0
     C                   iter
     C                   endif

     *  Otherwise, create reverse adjustment.

     C                   eval      iawhse = $pwhse
     C                   if        ittype = 'A'
     C                   eval      iaitem = #sitem
     C                   else
     C                   eval      iaitem = lbitem
     C                   endif
     C                   eval      iadate = rundate
     C                   eval      iatime = runtime
     C                   eval      iaby   = #user
     C                   eval      iawhdp = lbwhdp
     C                   eval      iadisp = lbdisp
     C                   eval      iacwta = 0
     C                   eval      iaqty1 = 0
     C                   eval      iaqty2 = 0
     C                   eval      iaqty3 = 0
     C                   eval      iaudte = 0
     C                   eval      iautim = 0

     *    For SSB item, qty must be converted from Base qty type
     *      into SSB qty type (ie. Brkdwn1 into Normal).

     C                   if        ittype = 'S'

     C                   select
     C                   when      lbutyp = '1'
     C                   eval      iaqty1 = svqpck * -1
     C                   when      lbutyp = '2'
     C                   eval      iaqty2 = svqpck * -1
     C                   endsl

     C                   else

     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      iaqty1 = svqpck * -1
     C                   when      lbutyp = '1'
     C                   eval      iaqty2 = svqpck * -1
     C                   when      lbutyp = '2'
     C                   eval      iaqty3 = svqpck * -1
     C                   endsl

     C                   endif

     C                   movea     msg(4)        a30
     C                   movea     lbrte         a30(16)
     C                   move      lblbl#        tempa7
     C                   movea     tempa7        a30(24)
     C                   movea     a30           iamemo

     C                   exsr      getcloseopt
     C                   eval      iacode = opexcd
     C                   write     iarec

     *      Create label adjustment record.

     C                   eval      lbctr# = lblbl#
730bDC**                 call      'PIRLBL#'
730bDC**                 parm                    lblbl#
730bMC                   exsr      GetNextLbl#
730bMC                   eval      lblbl# = nextLbl#
     C                   eval      lbgrp1 = ' '
     C                   eval      lbgrp2 = ' '
     C                   eval      lbtype = 'A'
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = rundate
     C                   eval      lbstim = runtime
     C                   eval      lbrdte = rundate
     C                   eval      lbqpck = svqpck * -1
     C                   write     lbrec

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  UndoOrders   Undo order records.
     *----------------------------------------------------------------

     C     undoorders    begsr

     *  Loop through order header records for route.

     C     keyrte        setll     ordh3
     C                   dow       forever = forever
     C     keyrte        reade     ordh3                                  77

     C                   if        *in77 = *on
     C                   leave
     C                   endif

     *    Loop through order detail records for order.

     C     keyod         setll     ordd
     C                   dow       forever = forever
     C     keyod         reade     ordd                                   76

     C                   if        *in76 = *on
     C                   leave
     C                   endif

     *      Update detail record.

     C                   eval      odstat = 'O'
     C                   eval      odqpk1 = 0
     C                   eval      odqpk2 = 0
     C                   eval      odqpk3 = 0

     C                   update    odrec

     C                   enddo

     *    Loop through order catchwgt records for order.

     C     keyod         setll     ordc
     C                   dow       forever = forever
     C     keyod         reade     ordc                                   76

     C                   if        *in76 = *on
     C                   leave
     C                   endif

     *      Delete all catchweight entries.

     C                   delete    ocrec
650aAc                   eval      processstatus = '*DELETE'
650aAc                   exsr      processCWLog

     C                   enddo

     *    Loop through order transaction records for order.

     C     keyod         setll     ordt
     C                   dow       forever = forever
     C     keyod         reade     ordt                                   76

     C                   if        *in76 = *on
     C                   leave
     C                   endif

     *      Delete all order transaction entries.

     C                   delete    otrec

     C                   enddo

     *    Update order header misc record with new route id.
     C     keyod         chain     ordhm
     C                   if        %found(ordhm)
     C                   eval      hmrtid  = newrtid
     C                   update    hmrec
     C                   endif

     *    Update header record.

     C                   eval      ohstat = 'O'
     C                   eval      ohsdte = rundate
     C                   eval      ohstim = runtime
     C                   eval      ohpbat = 0
     C                   eval      ohrte  = newrtid
     C                   update    ohrec

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  UndoWorkLbl  Un-Allocate/Pick WORKLBL records.
     *----------------------------------------------------------------

     C     undoworklbl   begsr

     *  Loop through WorkLbl records for route.

     C     keyrte        setll     worklbl5
     C                   dow       forever = forever
     C     keyrte        reade     worklbl5                               77

     C                   if        *in77 = *on
     C                   leave
     C                   endif

     *     Ignore labels that have already been processed.

     C                   if        lwstat = 'X'
     C                   iter
     C                   endif

     *     Only work with normal, bulk pick and merge records.

     C                   if        lwtype <> 'O' and
     C                             lwtype <> 'B' and
     C                             lwtype <> 'M'
     C                   iter
     C                   endif

     *     Only update slot for Merge and Out labels.

     C                   if        lwtype = 'M' or
     C                             lwasl2 = 'OUT'
     C                   goto      updlblw
     C                   endif

     *    Get Item Info.

     C                   eval      kywhse = lwwhse
     C                   eval      kyitem = lwitem
     C                   exsr      getitem

     *     Get slot record.

     C     keysl2w       chain     slot2                              77
     C                   if        *in77 = *on
     C                   goto      updlblw
     C                   endif

     *  Update slot record.

     C                   select

     *    Record alredy 'Picked'

     C                   when      lwstat = 'P'

     *      Normal uom.

     C                   select
     C                   when      lwutyp = 'N'
     C                   eval      slpck1 = slpck1 - lwqpck
     C                   if        slpck1 < 0
     C                   eval      slpck1 = 0
     C                   endif
     C                   eval      $acmd = '*UNALOCN'
     C                   eval      $aqty1 = lwqpck
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   exsr      updwhseqty

     *      Breakdown 1 uom.

     C                   when      lwutyp = '1'
     C                   eval      $acmd = '*UNALOC1'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = lwqpck
     C                   eval      $aqty3 = 0
     C                   exsr      undoslotpck2
     C                   exsr      updwhseqty

     *      Breakdown 2 uom.

     C                   when      lwutyp = '2'
     C                   eval      slpck3 = slpck3 - lwqpck
     C                   if        slpck3 < 0
     C                   eval      slpck3 = 0
     C                   endif
     C                   eval      $acmd = '*UNALOC1'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = lwqpck
     C                   exsr      updwhseqty

     C                   endsl

     *    Record not 'Picked', only allocated.

     C                   other

     *      Normal uom.

     C                   select
     C                   when      lwutyp = 'N'
     C                   eval      slalc1 = slalc1 - lwqalc
     C                   if        slalc1 < 0
     C                   eval      slalc1 = 0
     C                   endif
     C                   eval      $acmd = '*UNALLOC'
     C                   eval      $acmd = '*UNALOCN'
     C                   eval      $aqty1 = lwqalc
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   exsr      updwhseqty

     *      Breakdown 1 uom.

     C                   when      lwutyp = '1'
     C                   eval      $acmd = '*UNALOC1'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = lwqalc
     C                   eval      $aqty3 = 0
     C                   exsr      undoslotalc2
     C                   exsr      updwhseqty

     *      Breakdown 2 uom.

     C                   when      lwutyp = '2'
     C                   eval      slalc3 = slalc3 - lwqalc
     C                   if        slalc3 < 0
     C                   eval      slalc3 = 0
     C                   endif
     C                   eval      $acmd = '*UNALOC2'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = lwqalc
     C                   exsr      updwhseqty

     C                   endsl

     C                   endsl

     C                   update    slrec

     *  Update records.

     C     updlblw       tag

     C                   eval      rufile = 'W'
     C                   exsr      logit

     C                   eval      lwstat = 'X'
     C                   eval      lwsdte = rundate
     C                   eval      lwstim = runtime
     C                   eval      lwqpck = 0
     C                   eval      lwvrfy = 'U'
     C                   update    lwrec5

     C                   eval      kytrn# = lwtrn#
     C                   exsr      updtranrec

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  UndoSlotAlc2  Un-Allocate qty from slot
     *----------------------------------------------------------------

     C     undoslotalc2  begsr

     C                   eval      svqty2 = $aqty2

     *  First, try to undo full cases.

     C                   dow       svqty2 >= itumq2
     C                             and slalc1 > 0
     C                             and itumq2 > 0

     C                   eval      slalc1 -= 1
     C                   eval      svqty2 -= itumq2

     C                   enddo

     *  Then undo the rest from the brkdn 1 qty

     C                   dow       svqty2 > 0

     *     If enough avaialble, unallocate entire qty.

     C                   if        svqty2 <= slalc2
     C                   eval      slalc2 -= svqty2
     C                   eval      svqty2 = 0
     C                   leave
     C                   endif

     *     Not enough available, break down a case and loop.

     C                   if        slalc1 > 0
     C                              and itumq2 > 0
     C                   eval      slalc1 -= 1
     C                   eval      slalc2 += itumq2
     C                   iter
     C                   endif

     *     Case not available, zero out allocated qty.

     C                   eval      slalc2 = 0

     C                   leave
     C                   enddo

     *  Last, see if stock brkdn1 can be converted to cases.

     C                   exsr      avail
     C                   dow       avail2 >= itumq2
     C                              and slstk2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slstk1 += 1
     C                   eval      slstk2 -= itumq2
     C                   eval      avail2 -= itumq2
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  UndoSlotPck2  Un-Pick qty from slot
     *----------------------------------------------------------------

     C     undoslotpck2  begsr

     C                   eval      svqty2 = $aqty2

     *  First, try to undo full cases.

     C                   dow       svqty2 >= itumq2
     C                             and slpck1 > 0
     C                             and itumq2 > 0

     C                   eval      slpck1 -= 1
     C                   eval      svqty2 -= itumq2

     C                   enddo

     *  Then undo the rest from the brkdn 1 qty

     C                   dow       svqty2 > 0

     *     If enough avaialble, unallocate entire qty.

     C                   if        svqty2 <= slpck2
     C                   eval      slpck2 -= svqty2
     C                   eval      svqty2 = 0
     C                   leave
     C                   endif

     *     Not enough avaialble, break down a case and loop.

     C                   if        slpck1 > 0
     C                              and itumq2 > 0
     C                   eval      slpck1 -= 1
     C                   eval      slpck2 += itumq2
     C                   iter
     C                   endif

     *     Case not available, zero out allocated qty.

     C                   eval      slpck2 = 0

     C                   leave
     C                   enddo

     *  Last, see if stock brkdn1 can be converted to cases.

     C                   exsr      avail
     C                   dow       avail2 >= itumq2
     C                              and slstk2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slstk1 += 1
     C                   eval      slstk2 -= itumq2
     C                   eval      avail2 -= itumq2
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  UndoSlotStk2  Un-Stock qty from slot
     *----------------------------------------------------------------

     C     undoslotstk2  begsr

     C                   eval      svqty2 = $aqty2

     *  First, undo full cases.
     *    Actually, we are adding the qty back into stock.

     C                   dow       svqty2 >= itumq2
     C                             and itumq2 > 0

     C                   eval      slstk1 += 1
     C                   eval      svqty2 -= itumq2

     C                   enddo

     *  Then undo the rest from the brkdn 1 qty
     *    Again, we are adding the qty back into stock.

     C                   eval      slstk2 += svqty2

     *  Last, see if stock brkdn1 can be converted to cases.

     C                   exsr      avail
     C                   dow       avail2 >= itumq2
     C                              and slstk2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slstk1 += 1
     C                   eval      slstk2 -= itumq2
     C                   eval      avail2 -= itumq2
     C                   enddo

     C                   endsr

750aA*----------------------------------------------------------------
750aA*  UndoTrn  Undo transaction for *UNDOTRN
750aA*----------------------------------------------------------------
750aA
750aAC     undotrn       begsr
      /free

        // Update transaction

        chain(n) ($pwhse: $ptrn#) pirtranw;
        if not %found(pirtranw) or ptrtpo <> $prtid;
          errmsg = 'Trn# ' + %char($ptrn#) + ' '
                 + 'not found in ' + 'Rte Id ' + %trim($prtid);
          exsr zm0105;
          $prtn = '*PGMQ';
          leavesr;
        endif;

        // Update PIRTRAN record

        kytrn# = $ptrn#;
        lasttrn# = 0;
        exsr updTransPrt;

        // Update LABEL records

        exec sql update label
                 set lbstat = 'P', lbvrfy = '', lbqpck = lbqalc
                 where lbwhse = :$pwhse and lbtrn# = :$ptrn#;

        // Delete records from other files based on transaction #

        exec sql delete from multran
                 where muwhse = :$pwhse and mutrn# = :$ptrn#;

        exec sql delete from ordc
                 where ocwhse = :$pwhse and octran = :$ptrn#;

        exec sql delete from uciinfo
                 where uiwhse = :$pwhse and uiseltrn# = :$ptrn#;

        exec sql delete from voexcp
                 where sxwhse = :$pwhse and sxtrn# = :$ptrn#;

        exec sql delete from ordskipcw
                 where oscwhs = :$pwhse and osctrn = :$ptrn#;

        exec sql delete from runner
                 where ruwhse = :$pwhse and ruotrn = :$ptrn#;

        exec sql delete from labeldo
                 where lbowhse = :$pwhse and lbotrn# = :$ptrn#;

        exec sql delete from sktlbl
                 where slwwhse = :$pwhse and slwtrn# = :$ptrn#;

750bA   exec sql delete from passtrn
750bA            where paswhse = :$pwhse and pastrn# = :$ptrn#;

        // Send back reset message

        errmsg = 'Trn# ' + %char($ptrn#) + ' reset';
        exsr zm0105;
        $prtn = '*PGMQ';

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  UpdLabelStat  Update label status.
     *----------------------------------------------------------------

     C     updLabelStat  begsr

     *  Loop through Label records for route.

     C     keyrte        setll     label13
     C                   dow       forever = forever
     C     keyrte        reade     label13                                77

     C                   if        *in77 = *on
     C                   leave
     C                   endif

     *     Only work with normal, bulk pick and merge records.

     C                   if        lbtype <> 'O' and
     C                             lbtype <> 'B' and
     C                             lbtype <> 'M'
     C                   iter
     C                   endif

750aA*     See if working with specific tran
750aA
750aAC                   if        $pcmd = '*UNDOTRN'
750aAC                   if        lbtrn# <> $ptrn#
750aAC                   iter
750aAC                   else
750aAC                   eval      trnFound = *on
750aAC                   endif
750aAC                   endif

     *  Update label record.

     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = rundate
     C                   eval      lbstim = runtime
750aAC                   if        $pcmd = '*UNDOTRN'
750aAC                   eval      lbvrfy = ''
750aAC                   endif
     C                   update    lbrec

     *  Update transaction fields to printed status.

     C                   eval      kytrn# = lbtrn#
     C                   exsr      updTransPrt

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  UpdOrders     Update order status and zero out picked qty's.
     *----------------------------------------------------------------

     C     updOrders     begsr

     *  Loop through order header records for route.

     C     keyrte        setll     ordh3
     C                   dow       forever = forever
     C     keyrte        reade     ordh3                                  77

     C                   if        *in77 = *on
     C                   leave
     C                   endif

     *    Loop through order detail records for order.

     C     keyod         setll     ordd
     C                   dow       forever = forever
     C     keyod         reade     ordd                                   76

     C                   if        *in76 = *on
     C                   leave
     C                   endif

     *      Update detail record.

     C                   eval      odstat = 'P'
     C                   eval      odqpk1 = 0
     C                   eval      odqpk2 = 0
     C                   eval      odqpk3 = 0

     C                   update    odrec

     C                   enddo

     *    Update header record.

     C                   eval      ohstat = 'P'
     C                   eval      ohsdte = rundate
     C                   eval      ohstim = runtime
     C                   update    ohrec

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  UpdRouteStat  Update route header status.
     *----------------------------------------------------------------

     C     updRouteStat  begsr

     C                   eval      rhstat = hld_rhstat
     C                   eval      rhstsd = rundate
     C                   eval      rhstst = runtime
     C                   update    rhrec

     C                   endsr

     *----------------------------------------------------------------
     *  UpdTranRec  Update transaction record.
     *----------------------------------------------------------------

     C     updtranrec    begsr

     C                   if        kytrn# = 0 or kytrn# = lasttrn#
     C                   goto      endupdtrn
     C                   endif

730aMC     keypt         chain     pirtranw                           77

     C                   if        *in77 = *off

     C                   eval      rufile = 'T'
     C                   exsr      logit

     C                   if        ptstat <> '4'
     C                   eval      ptstat = '4'
     C                   eval      ptcdte = rundate
     C                   eval      ptctim = runtime
     C                   endif
     C                   update    ptrec
640aAc                   exsr      zzwrttrand

     C                   endif

     C                   eval      lasttrn# = kytrn#

     C     endupdtrn     endsr

     *----------------------------------------------------------------
     *  UpdTransPrt   Update transaction fields to printed status.
     *----------------------------------------------------------------

     C     updTransPrt   begsr

     C                   if        kytrn# = 0 or kytrn# = lasttrn#
     C                   goto      endupdTransP
     C                   endif

730aMC     keypt         chain     pirtranw

730aMC                   if        %found(pirtranw)
     C                   eval      ptstat = '1'
     C                   eval      ptcrew = *blanks
     C                   eval      ptemp# = 0
     C                   eval      ptetyp = *blanks
     C                   eval      ptsdte = 0
     C                   eval      ptstim = 0
     C                   eval      ptedte = 0
     C                   eval      ptetim = 0
     C                   eval      ptcdte = 0
     C                   eval      ptctim = 0
     C                   eval      ptrdte = rundate
     C                   eval      ptdmin = 0
     C                   eval      ptimin = 0
     C                   update    ptrec
640aAc                   exsr      zzwrttrand
     C                   endif

     C                   eval      lasttrn# = kytrn#

     C     endupdTransP  endsr

     *----------------------------------------------------------------
     *  UpdWhseQty  Update warehouse quantity.
     *----------------------------------------------------------------

     C     updwhseqty    begsr

     *    When item is an Alias or SSB ...
     *      Update Base item instead of label item.

     C                   if        ittype = 'A' or ittype = 'S'
     C                   eval      $aitem = #sitem
     C                   else
     C                   eval      $aitem = #litem
     C                   endif

     *    Call program to update warehouse quantity.

     C                   call      'ADJQTY'
     C                   parm                    $acmd             8
     C                   parm      #prog         $aprg            10
     C                   parm      '*BATCH  '    $atype            8
     C                   parm      kywhse        $awhse            3 0
     C                   parm                    $aitem           15
     C                   parm                    $aqty1            7 0
     C                   parm                    $aqty2            7 0
     C                   parm                    $aqty3            7 0
     C                   parm                    $artq1            7 0
     C                   parm                    $artq2            7 0
     C                   parm                    $artq3            7 0
     C                   parm                    $artn             8
     C                   parm                    $aerm            60

     *    If item is a Contract item and restocking slot
     *      Then we must restock and allocate base item.

     C                   if        ittype = 'C' and $acmd = '*STOCK'

     C                   call      'ADJQTY'
     C                   parm      '*STOCK  '    $acmd
     C                   parm      #prog         $aprg
     C                   parm      '*BATCH  '    $atype
     C                   parm      kywhse        $awhse
     C                   parm      #sitem        $aitem
     C                   parm                    $aqty1
     C                   parm                    $aqty2
     C                   parm                    $aqty3
     C                   parm                    $artq1
     C                   parm                    $artq2
     C                   parm                    $artq3
     C                   parm                    $artn
     C                   parm                    $aerm

     C                   call      'ADJQTY'
     C                   parm      '*ALLOC  '    $acmd
     C                   parm      #prog         $aprg
     C                   parm      '*BATCH  '    $atype
     C                   parm      kywhse        $awhse
     C                   parm      #sitem        $aitem
     C                   parm                    $aqty1
     C                   parm                    $aqty2
     C                   parm                    $aqty3
     C                   parm                    $artq1
     C                   parm                    $artq2
     C                   parm                    $artq3
     C                   parm                    $artn
     C                   parm                    $aerm

     C                   endif

     C                   endsr
730bA*----------------------------------------------------------------
730bA*  wrtDebug    Write out debug record
730bA*----------------------------------------------------------------
730bA
730bA /free
730bA  begsr wrtDebug;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdbrec;

       endsr;
      /end-free

640aA*----------------------------------------------------------------*********
640aA*
640aA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640aA*
640aA /free
640aA   begsr zzwrttrand;
640aA     wrtpcmd = '*UNDOTRAN';
640aA     wrtpwait = 0;
640aA     wrtpwhse = ptwhse;
640aA     wrtptran# = pttrn#;
640aA     wrtpfrmdate = 0;
640aA     wrtptodate = 0;
640aA     wrtpemp# = 0;
640aA
640aA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640aA               wrtpfrmdate: wrtptodate: wrtpemp#);
640aA   endsr;
640aA /end-free
640cA*----------------------------------------------------------------*********
640cA*
640cA*  ZZWRTTRANDL Execute new WRTTRAN1 program to turn off flags/indicators
640cA*
640cA /free
640cA   begsr zzwrttrandl;
640cA     wrtpcmd = '*DLTTRAN';
640cA     wrtpwait = 0;
640cA     wrtpwhse = %dec(ptwhse);
640cA     wrtptran# = pttrn#;
640cA     wrtpfrmdate = 0;
640cA     wrtptodate = 0;
640cA     wrtpemp# = 0;
640cA
640cA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640cA               wrtpfrmdate: wrtptodate: wrtpemp#);
640cA   endsr;
640cA /end-free
     *----------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *----------------------------------------------------------------

     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSGP'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *      0105
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
     *----------------------------------------------------------------

**  MSG - Error Messages
Route xxxxx does not exist
Route xxxxx locked by another program
Route xxxxx is not at Exported Status
Out Lbl Undo R:99999 L:9999999
Route xxxxx reversed successfully
