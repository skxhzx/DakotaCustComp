      /copy qcopysrc,hspecs
760 AH Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *
     *  PO236S    Stage Import - Received Pallets
     *  23 February 2011
     *  Dave Sommerville
     *
     *  This program was based on PO236.
     *  Compile it with Commitment Control set to *NONE
     *
     *     LATEST VER, FIXED BY ROD/BFC
     *----------------------------------------------------------------
     *
640 A*    02/23/11  DAS  6.40
     *      - Created
     *
650 A*    09/18/14  MLB  6.50
     *      - Fix: Revised pgm to write record to POHHDR file if
     *        if entry not found. Set Export Date to current date
     *        and export time to zeros. Not having an entry in the
     *        POHHDR file was causing other p/o receiving files to
     *        not be cleaned up because the POHHDR file is what
     *        triggers the cleanup process once a given p/o has
     *        reached the cutoff date based on the export date.
650aA*    09/18/14  MLB  6.50a
     *      - Enh: Revised pgm to add custom client support.
     *
700a *    08/06/15  RTR  7.00a
     *      - Fix: Added DRISLOT call to create licenses and put into
     *        RCV slot.
700bA*    09/21/15  MLB  7.00b
     *      - Fix: Revised pgm to release record locks on LICENSE. Pgm
     *        was causing "Unable to allocate record" errors.
700cA*    10/06/15  MLB  7.00c
     *      - Fix: Revised to call pgm, PO144 when RCPTYPE = D. Pgm
     *        was not fully deleting a received license/transaction.
700dA*    12/07/16  MLB  7.00d
     *      - Fix: Revised pgm to load user id from RCPUSR if greater
     *        than blanks otherwise use #CURRUSER.
     *      - Fix: Revised pgm to call GETUSER to retrieve emp# for
     *        receiver id. Emp# will be sent to DRISLOT. Send zeros if
     *        not found.
710aA*    02/13/17  LMC  7.10a
     *      - Fix: load up date information fields into LICINFO.
     *
720 A*   01/31/18  MLB  7.20
     *     - Fix: Revised pgm to move $pwhse back into $pwhse3a prior
     *       to call to PO236S. In certain unknown instances, $pwhse3a
     *       was being sent to us as 1bb instead of 001. %dec function
     *       is correctly converting value from $pwhse3a but does not
     *       update the value prior to call to PO236S.
720aA*   11/12/18  MLB  7.20a
     *     - Fix: Revised 7.20 mod. Revised pgm to load $pwhse back into
     *       $PWHSE3A at top of mainline. Same problem happening on call
     *       to PO237S.
     *
730 A*    12/12/19  MLB  7.30  Was 6.50g in PO236.
     *      - Enh: Added additional checks for unique license.
     *      LICINFO and LICLOG records stay longer with new cleanup.
     *      We need to check LICLOG before we allow the user to
     *      reuse a license number.
730aA*    12/12/19  MLB  7.30a  Was 6.50i in PO236.
     *      - Fix: Edit in mod 650g does not apply for OS license.
     *      The OS* license will exist in licactive/liclog because
     *      it was just created for use.
730bA*    12/12/19  MLB  7.30b  Was 7.10b in PO236.
     *      - Fix - Need to check to make sure old LICINFO record
     *        doesn't exist. If it does, the program actually fails
     *        in the update process.
730cA*    12/12/19  MLB  7.30c
     *      - Enh - Revised ZZZDRICOP to add logic to only turn on
     *        ERROR ind if chk4err = on. Needed with 7.30b mod.
730dA*    12/12/19  MLB  7.30d
     *      - Enh - Revised ZZZDRICOP to test for *LICENSE to call
     *        DRICOP with different set of parms.
760  *    09/02/22  KDE  7.60
     *      - Enh:  Add call to interface error reporting in Report
     *        Scheduler when import has a failure or error
760a *    01/08/23  KDE  7.60d
     *      - Enh:  Change interface error report to R42600.  Also
     *        Add extended message for complete Stage Batch
     *
     *----------------------------------------------------------------
     F*  Client Custom Revisions
     F*
CBI AF*    09/12/11  CBI-JGD
     F*      Modify error message (rcpText) logic to display IMPSRCVP
     F*      file error message on receiver screen instead of STGBATCH
     F*      file general message.
     F*
CBIaAF*    10/19/11  CBIa-JGD ( This logic was added on 2/22/12)
     F*      Add logic to retrieve new info loaded in IMPSRCVP, and
     F*      load it into new added files POMFR and PORCV.
     F*      NOTE: These new files were incorporated to this process
     F*            to be able to display receiving information when
     F*            inquiring on EPM License/Tran information.
     F*
CBIbAF*    11/23/11  CBIb-JGD
     F*      Modify "IF" statement to bypass LBTYPE ='Q'= recalc
     F*      item qty label record (created every day by scheduled
     F*      SAP/WMS interface job IMPFPQTY) at the time of checking
     F*      whether or not the put away qty was altered by another
     F*      inventory activity (Order Pick, Replenisment, Transfer
     F*      Merge, etc...)
     F*
CBIcAF*    12/07/11  CBIc-JGD
     F*      Add logic to not allowed license change on a pallet
     F*      that has already been put away also, do nothing if
     F*      qty being change is the same as the existing one.
     F*
CBIdAF*    08/28/12  CBId-JGD
     F*      Verify, before writing record to file "POMFR",
     F*      that the item being processed is date sensitive.
     F*
CBIeAF*    06/14/13  CBIe-JGD
     F*      Modify error message (rcpText) logic to also display the
     F*      license number and item sequence number when duplicate
     F*      license has been sent thru from SAP.
     F*
CBIfAF*    08/12/13  CBIf-JGD
     F*      Add logic to verify if the input record comming
     F*      thru holds a date sensitive item. Check in file
     F*      "Impsrcvp/rcpexpd", if greater than zero, it is
     F*      date sensitive, write a record into file "POMFR",
     F*
CBIgA*    09/18/14  MLB  CBIg
     *      - Enh: Included in 6.50 fix, update vendor name into
     *        POHHDR file since Cheney version of IMPSRCVP file has
     *        vendor name included.
      *
CBIhA *    09/18/14  CBIh-JGD
      *      - Load PORCV fields POREDT and PORETI with values
      *        from PORCV fields PORDTE and PORTIM respectably.
      *
CBIiA *    01/20/17  CBIi-JGD
      *      - Load dept name into lbwhsedpt var instead of warehouse#.
      *
      *      - Stop delete license process if the status of the tran#
      *        being proces is greater than 2 (pallet already put away)
      *
CBIjA*    02/20/18  NLK  CBIj
     *      - Enh: Items coming from OCA, Import as *XDKnnn.
     *        Create License # if *XDK.
     *        Create sldisp with slaisl XDK; slloc nnn;
     *               slrlvl 1; slhand incrementing; close trn and lbl
CBIkA*    04/26/18  NLK  CBIk
     *      - FIX: ErrorCheck if qty1 is zero, check qty2 as well.
     *        Watch rcpqty2 and where it is moved when rcpqty1 is 0.
     *        In Addtl, need to move qty2 if no qty1 to label file.
CBIlA*    05/15/18  NLK  CBIl
     *      - Enh: Buyers & CHEM from OCA coming in as *XDHnnn and
     *        *XDPnnn - Create License # if *XDK and *XDH/*XDP.
CBImA*    06/22/18  NLK  CBIm
     *      - Enh: From OCA coming in as *XDOnnn (Oyster) and
     *        *XDLnnn (Clam) - Create License # if *XDK and *XDO/*XDL.
     *
     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fimpsrcvp  uf   e           k disk
     Flabel     uf a e           k disk
     Flabel90   uf   e           k disk
     F                                     rename(lbrec:lbrec2)
     Flicense   uf a e           k disk
650 AFpohhdr    if a e           k disk
     Flabel91   if   e           k disk
     F                                     rename(lbrec:lbrec91)
     Fslot      if   e           k disk
     Fitemdsc   if   e           k disk
CBIdAFitemmsc   if   e           k disk
700cAFoptiond   if   e           k disk
     Fpiritem   if   e           k disk
     Fpirtran   uf   e           k disk
CBIaAFpomfr     uf a e           k disk
CBIaAFporcv     uf a e           k disk
CBIaAFstgbatch  uf   e           k disk
650aA
650aA*----------------------------------------------------------------
650aA*  Client id's
650aA*----------------------------------------------------------------
650aA
650aA /copy qcopysrc,id#cheney

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------
     D @cvtdt          c                   const('CVTDTE')
     D @addtr          c                   CONST('ADDSTDTRN')
     D @fixpo1s        c                   CONST('FIXPO1S')

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
700cA*
700cA*----------------------------------------------------------------
700cA*  *PICK  -  Picking options
700cA*----------------------------------------------------------------
700cA*
700cA* Fields
700cA*
700cA*    OPNXTP  -  Next pallet number.
700cA*    OPBPCK  -  Bulk pick definition.
700cA*    OPPCUB  -  Maximum cube for PIR.
700cA*    OPFPAL  -  Pallets on fixed fork lift.
700cA*    OPFCUB  -  Maximum cube per fixed pallet.
700cA*    OPFSTP  -  Maximum stops per fixed pallet.
700cA*    OPINCL  -  Include PIR in fixed cube.
700cA*    OPSRCH  -  Number of previous pallets to search for space.
700cA*    OPFBLD  -  Fixed pallet building method.
700cA*                1 = By piece without concern for splitting stop.
700cA*                2 = By stop without splitting stop between plts.
700cA*    OPPBRK  -  Break pallets by aisle (Y,N).
700cA*    OPMPUT  -  Manual Put away (Y,N).
700cA*
700cA* Data structure
700cA*
700cAD opddta          ds
700cAD  opnxtp                 1      7  0 inz(0)
700cAD  oppcub                10     14  2 inz(0)
700cAD  opfpal                15     15  0 inz(0)
700cAD  opfcub                16     20  2 inz(0)
700cAD  opincl                22     22
700cAD  opsrch                23     24  0 inz(0)
700cAD  opfstp                25     26  0 inz(0)
700cAD  opfbld                27     27  0 inz(0)
700cAD  opbpck                28     30  0 inz(0)
700cAD  oppbrk                31     33
700cAD  opmput                34     34
700cAD  opdend               117    117
700cA*

     *----------------------------------------------------------------
     D*  Program parameters
     D*
     D $PARMS          DS
     D  $PCMD                  1      8
     D  $PPRG                  9     18
     D  $PUKY                 19     68
     D  $PRTN                 69     76
     D  $PERM                 77    136
     D  $PMSG                 77     80
     D*
     D*   Redefine key
     D*
     D  $PITEM                22     36
     D  $PPO                  37     45
     D  $PRQ1                 46     50  0
     D  $PRQ2                 51     55  0
     D  $PRQ3                 56     60  0
     D  $PRPAL                61     63  0
417bAD  $PLOTT                64     64
417bAD  $PLICT                65     65
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D $LPARM          DS
     D  $LCMD                  1      8
     D  $LPRG                  9     18
     D  $LUKY                 19     68
     D  $LRTN                 69     76
     D  $LERM                 77    136
     D  $LMSG                 77     80
405 AD  $LTYPE                81     88
     D*
     D*   Redefine key
     D*
     D  $LWHSE                19     21  0
     D  $LWHDP                22     26
     D  $LRACK                22     26
     D*
     D  $LBLD                 19     20
     D*
405 AD  $LRTE                 22     26
405 AD  $LPO                  27     35
405 AD  $LTRN#                36     42  0
700cAD*
700cAD  $LTRN2#               19     22p 0  inz(0)
700cAD  $LLBL#                23     26p 0  inz(0)
700cAD  $LQPCK                27     31  0  inz(0)
700cAD  $LQRMN                32     36  0  inz(0)
700cAD  $LPCKC                37     39  0  inz(0)
700cAD  $LRECC                40     42  0  inz(0)
700cAD  $LCWGT                43     43     inz(' ')
700cAD  $LMPUT                44     44     inz('Y')

700aA*----------------------------------------------------------------
700aA*  DRI parameters
700aA*----------------------------------------------------------------
700aA /COPY *libl/qcopysrc,C#DRIPARMS
700aA
700aA*----------------------------------------------------------------
700aA*  Data Formats
700aA*----------------------------------------------------------------
700aA /COPY *libl/qcopysrc,C#SLOT
700aA /COPY *libl/qcopysrc,C#ITEM
700aA /COPY *libl/qcopysrc,C#LICINFO
CBIjA /COPY *libl/qcopysrc,C#LICHIST
CBIjA /COPY *libl/qcopysrc,C#XDOCK
CBIjA /COPY *libl/qcopysrc,C#LICENSE

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

CBIjAD ck4err          s              1
CBIeAD exists          s             15
     D importError     s               n
     D label#          s              7
     D lbdispl         s             12
     D lbitem#         s             15
     D lbpo#           s              9
     D lbwhsedpt       s              5
CBIjAD newlbl#         s                   like(lblbl#)
     D stamp           s               z
     D stampUC         s               z
     D $pbat           s              7  0
     D $pflag          s              1
     D @pgrp1          s              1
     D @pgrp2          s              1
     D @plott          s              1
     D @plict          s              1
     D $pseq           s              5  0
     D pttrn#          s              7  0
     D putawayloc#     s             12
CBIjAD pdspcl          s              2
CBIjAD sv_pdspcl       s              2
CBIjAD savloc          s              3
CBIjAD savlocn         s              3  0
     D savtrn#         s              7  0
CBIeAD savseq          s              5
CBIeAD seq#            s              8
     D $pord           s              7  0
     D today           s              8  0
     D today6          s              8  0
     D tran#           s              7
700dAD usrfound        s              1    inz('0')
     D w1xdk           s              1
CBIj D ocaxdk          s              1
CBIj D w1lcns          s             15
CBIj D zmflag          s              1

700aAD #rcvarea        s              6
700aAD #rcvitem        s                   like($ititem)
700aAD #rcvtype        s                   like($ittype)
700aAD #rcvdesc        s                   like($itdesc)
700aAD #rcvpdsc        s                   like($itpdsc)
700aAD #rcvwhdp        s                   like($itwhdp)
700aAD #rcvstyp        s                   like($itstyp)
700aAD #rcvdesg        s                   like($itdesg)
700aAD #rcvum1         s                   like($itum1)
700aAD #rcvflg1        s                   like($itflg1)
700aAD #rcvum2         s                   like($itum2)
700aAD #rcvumq2        s                   like($itumq2)
700aAD #rcvflg2        s                   like($itflg2)
700aAD #rcvum3         s                   like($itum3)
700aAD #rcvumq3        s                   like($itumq3)
700aAD #rcvdday        s                   like($imdday)
700aAD #rcvmday        s                   like($immday)
700aAD #rcvmflg        s                   like($immflg)
700aAD #rcvuday        s                   like($imuday)
700aAD #rcvnrpk        s                   like($imnrpk)
700aAD #rcvflgd        s                   like($itflgd)
700aAD #rcvcube        s                   like($itcube)
700aAD #rcvswgt        s                   like($itswgt)
700aAD #rcvupc         s                   like($itupc)
700aA
700aAD #slotitem       s                   like($ititem)
700aAD #slottype       s                   like($ittype)
700aAD #rcvcwgt        s                   like($itcwgt)
700aAD savever#        s                   like($slver#)
CBIjAD $pgslcns        s                   like(w1lcns)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $pWhse          s              3p 0
     D $pWhse3A        s              3
     D $pBatId         s             11
     D $pReturn        s             10
     D $pMessage       s            200

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
760 A /copy qcopysrc,c#stdvar
760 AD/copy qcopysrc,p.mrcrptsc
760 AD/copy qcopysrc,p.qcmdexc
760aAd/copy qcopysrc,p.wIntLog
760 AD currReport      s             20
760 AD url             s           3000
760 AD schEmail        s           1000
760 AD orient          s              1
760 AD grDev           s             10
760 Ad sbmusr          s             10
760 Ad sbmjobd         s             10
760 Ad sbmlibl         s             10
760 AD cmd             s           3000    varying
760 AD opmusr          s             10
760 Ad opjobd          s             10

760 A*----------------------------------------------------------------
760 A*  Sub-procedure prototypes
760 A*----------------------------------------------------------------

760 Ad getSchTimeEml   pr

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D*sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *      $pBatId - Batch id
     *
     *    Returned Parameters
     *      $pReturn  - Return code
     *      $pMessage - Return message
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $pWhse3A
     c                   parm                    $pBatId
     c                   parm                    $pReturn
     c                   parm                    $pMessage

     c                   eval      $pWhse = %dec($pWhse3A: 3: 0)
720aAC                   eval      $pWhse3A = %char($pwhse)
     c                   eval      $pReturn = '*OK'
     c                   eval      $pMessage = ' '
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     * Update stgbatch record to start process

     C                   exsr      zzzStart
     C                   if        $pReturn <> '*OK'
     C                   return
     C                   endif

     * Whip through stage records and create putaway transactions

     C     rcpkey        setll     impsrcvp
     C                   dow       forever = forever

     C     rcpkey        reade     impsrcvp
     C                   if        %eof(impsrcvp)
     C                   leave
     C                   endif

     *   Skip processed records.

     C                   if        rcpstatus <> 'R'
     C                   iter
     C                   endif

     *   Check for errors

     C                   exsr      ErrorChecks
     C                   if        error
     C                   exsr      UpdateStgRec
     C                   iter
     C                   endif

     *   Create a new putaway or recreate a deleted one

     C                   if        rcptype = 'A' or
     C                             rcplcns2 <> *blanks
     C                   exsr      CreatePutaway
     C                   if        error
     C                   exsr      UpdateStgRec
     C                   iter
     C                   endif

CBIaA*  Add record to PORCV file to marked as touched/received.
CBIaAC                   exsr      zzzUrcv

CBIdM*  Add record to POMFR file if item being processed is a
CBIdM*  date sensitive item.
CBI AC                   if        client = cheney
CBIfAC                   if        rcpexpd <> 0
CBIaAC                   exsr      zzzUmfr
CBIdAC                   endif
CBI AC                   endif

     C                   endif

     *   Update stage record

     C                   exsr      UpdateStgRec

     C                   enddo

     *  Close up loose ends and leave

     C                   exsr      zzzEnd
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
650aA*
650aA*  Retrieve client details.
650aAC                   call      'GETCLIENT'
650aAC                   parm                    client           10
650aAC                   parm                    clientloc        10

     * Key definitions

     *  Define key for impsrcvp file.
     *
     C     rcpkey        klist
     C                   kfld                    $pWhse
     C                   kfld                    $pBatId

     *  Define key for license file current license#.
     *
     C     lickey        klist
     C                   kfld                    $pWhse
     C                   kfld                    rcplcns

     *  Define key for license file replacing license#.
     *
     C     lickey2       klist
     C                   kfld                    $pWhse
     C                   kfld                    rcplcns2
700cA
700cA*  Define key for opitond file.
700cA*
700cAC     *like         define    opdcod        kycode
700cAC     opdkey        klist
700cAC                   kfld                    kycode
700cAC                   kfld                    $pWhse
700cAC                   kfld                    lbwhdp

     *  Define key for piritem file.
     *
     C     pirkey        klist
     C                   kfld                    $pWhse
     C                   kfld                    rcpitem

     *  Define key for label90 file.
     *
     C     lbl90key      klist
     C                   kfld                    $pWhse
     C                   kfld                    litrn#

     *  Define key for label91 file.
     *
     C     lbl91key      klist
     C                   kfld                    $pWhse
     C                   kfld                    rcpitem
     C                   kfld                    today

     *  Define key for porcv file.
     *
     C     porcvkey      klist
     C                   kfld                    $pWhse
     C                   kfld                    rcppo
     C                   kfld                    rcpseq

     *  Define key for pomfr file.
     *
     C     pomfrkey      klist
     C                   kfld                    $pWhse
     C                   kfld                    rcppo
     C                   kfld                    rcpseq
     C                   kfld                    rcpitem

     C                   exsr      zzinz

     C                   endsr

     *----------------------------------------------------------------
     *  ChkPutAwayQty
     *----------------------------------------------------------------

     C     ChkPutAwayQty begsr

     *  Find if pallet/license has been put away and qty in the put
     *  away location qty has not been altered (transferred, picked,
     *  replenished), if it had, stop process..

     C                   eval      error = *off
     C                   eval      putawayloc# = *blanks
     C                   eval      found       = *off

     C     lbl91key      setll     label91
     C     lbl91key      reade     label91                                76
     C                   dow       *in76 = *off

     *  Label found indicator, if not found error.
     C                   if        found = *off
     C                   eval      found = *on
     C                   endif

     *  Save put away location for possible further verification
     C                   if        putawayloc# = *blanks
     C                   eval      putawayloc# = lbdisp
     C                   endif

     C                   if        lbtype <> 'P' and
CBIbAC                             lbtype <> 'Q' and
     C                             lbdisp = putawayloc#
     C                   eval      error = *on
     C                   eval      rcpText = 'Can''t update, put away '
     C                                     + 'location qty has been up'
     C                                     + 'dated by another process'

CBI AC                   eval      sbText  = rcpText
     C                   leavesr
     C                   endif
     C     lbl91key      reade     label91                                76
     C                   enddo

CBIbAC                   if        found = *off
     C                   eval      error = *on
     C                   eval      rcpText = 'Label record not found '
     C                                     + 'in ChkputawayLoc Rtn.   '

     C                   eval      sbText  = rcpText
     C                   endif

     C                   endsr

710aA*----------------------------------------------------------------
710aA*  clr$item  Clear $item data structure fields
710aA*----------------------------------------------------------------
710aA
710aAC     clr$item      begsr
710aAC                   eval      savever# = $itver#
710aAC                   clear                   $item
710aAC                   clear                   $item2
710aAC                   eval      $itver# = savever#
710aAC                   endsr
730 A
730 A*----------------------------------------------------------------
730 A*  clr$license  Clear $license data structure fields
730 A*----------------------------------------------------------------
730 A
730 AC     clr$license   begsr
730 AC                   eval      savever#   = $liver#
730 AC                   clear                   $license
730 AC                   eval      $liver#    = savever#
730 AC                   eval      $liemp#    = #emp#
730 AC                   eval      $liuser    = #curruser
730 AC                   eval      $lipgm     = #pgm
730 AC                   eval      $lijob     = #job
730 AC                   eval      $lijobn    = #jobnbr
730 AC                   eval      $liTowhse  = $pwhse
730 AC                   eval      $liTowhseu = *on
730 AC                   endsr

700aA*----------------------------------------------------------------
700aA*  clr$licinfo  Clear $licinfo data structure fields
700aA*----------------------------------------------------------------
700aA
700aAC     clr$licinfo   begsr
700aAC                   eval      savever# = $lnver#
700aAC                   clear                   $licinfo
700aAC                   clear                   $licinfo2
700aAC                   eval      $lnver# = savever#
700dA*
700dAC                   if        rcpusr > ' '
700dAC                   eval      $lnuser = rcpusr
700dAC                   else
700dA*
700aAC                   eval      $lnuser = #curruser
700dAC                   endif
700dA*
700aAC                   eval      $lnpgm  = #pgm
700aAC                   eval      $lnjob  = #job
700aAC                   eval      $lnjobnbr = #jobnbr
700aAC                   endsr
700aA
700aA*----------------------------------------------------------------
700aA*  clr$slot  Clear $slot data structure fields
700aA*----------------------------------------------------------------
700aA
700aAC     clr$slot      begsr
700aAC                   eval      savever# = $slver#
700aAC                   clear                   $slot
700aAC                   clear                   $slot2
700aAC                   eval      $slver# = savever#
700dA
700dAC                   if        usrfound = '1'
700dAC                   eval      $saemp#U = *on
640cAC                   eval      $saemp#  = #emp#
640cAC                   else
700dA
700aAC                   eval      $saemp#U = *off
700aAC                   eval      $saemp# = 0
640cAC                   endif
700dA
700aAC                   endsr

     *----------------------------------------------------------------
     *  CreatePutaway check for data errors
     *----------------------------------------------------------------

     C     CreatePutaway begsr
     C                   eval      error = *off
     *  Replacing existing license.

     C                   if        rcplcns2 <> *blanks
     C                   eval      rcplcns  = rcplcns2
     C                   endif

     *  Get batch # for label.

     C                   call      'PIRBAT#'
     C                   parm      *zeros        $pbat

     C                   eval      @pgrp1 = 'P'

     *  Get transaction number.

     C                   call      'PIRTRN#'
     C                   parm                    pttrn#


CBIj
CBIj *  Create License if *XDK coming from Import (OCA Order)
CBIj
CBIjD *                  if   **   rcplcns = '*XDK'
CBIjMC                   if        %subst(rcplcns:1:4) = '*XDK'
CBIlAC                             or %subst(rcplcns:1:4) = '*XDH'
CBIlAC                             or %subst(rcplcns:1:4) = '*XDP'
CBImAC                             or %subst(rcplcns:1:4) = '*XDO'
CBImAC                             or %subst(rcplcns:1:4) = '*XDL'
CBIjAC                   eval      ocaxdk = 'Y'
CBIjAC                   eval      savloc = %subst(rcplcns:5:3)
CBIjAC                   if        savloc < '001'
CBIjAC                             or savloc >'999'
CBIjAC                   eval      savloc = '999'
CBIjAC                   endif
CBIjAC                   move      savloc        savlocn
CBIjAC                   eval      pdspcl = 'XD'
CBIjAC                   eval      sv_pdspcl = 'XD'

CBIlAC                   select
CBIlAC                   when      %subst(rcplcns:1:4) = '*XDK'
CBIjAC                   eval      $saToLcns = '*XD'
CBIjAC                                       + %editc(pttrn#:'X')

CBImAC                   when      %subst(rcplcns:1:4) = '*XDO'
CBImAC                   eval      $saToLcns = '*XO'
CBImAC                                       + %editc(pttrn#:'X')

CBImAC                   when      %subst(rcplcns:1:4) = '*XDL'
CBImAC                   eval      $saToLcns = '*XL'
CBImAC                                       + %editc(pttrn#:'X')

CBIlAC                   when      %subst(rcplcns:1:4) = '*XDH'
CBIlAC                   eval      $saToLcns = '*XH'
CBIlAC                                       + %editc(pttrn#:'X')

CBIlAC                   when      %subst(rcplcns:1:4) = '*XDP'
CBIlAC                   eval      $saToLcns = '*XP'
CBIlAC                                       + %editc(pttrn#:'X')
CBIlAC                   endsl

CBIjAC                   eval      rcplcns = $saToLcns
CBIjAC                   endif

     C                   if        rcpqty1 > *zeros
CBIkAC                             or rcpqty2 > *zeros
CBIkAC                             and client = cheney

     *  Create label record for normal qty (CS)

     C                   clear                   lbrec2

     C                   eval      lbwhse = $pwhse
     C                   eval      lbwhdp = itwhdp
     C                   eval      lbaisl = *blanks
     C                   eval      lbloc  = *zeros
     C                   eval      lbrlvl = *zeros
     C                   eval      lbhand = *blanks
     C                   eval      lbpseq = *zeros
     C                   eval      lbstyp = *blanks
     C                   eval      lbqryf = *zero
     C                   eval      lbdisp = *blanks
     C                   eval      lbdsp2 = '*MANUAL'
     C                   eval      lbitem = rcpitem
     C                   eval      lbseq  = rcpseq
     C                   eval      lbpbat = $pbat
     C                   eval      lbpo   = rcppo
     C                   eval      lbord  = $pord
     C                   eval      lbqalc = rcpqty1
     C                   eval      lbqpck = rcpqty1
     C                   eval      lbtie  = *zeros
     C                   eval      lbhigh = *zeros

     *  Create label record for normal qty (CS)

     C*>                 IF        w1umt  = 'N' and

     C                   IF        rcpqty1 > *zeros and
415dAC                             ittype <>'S'
     C                   eval      lbutyp = 'N'
     C                   eval      lbucod = itum1
     C                   eval      lbucub = itcube
     C                   eval      lbcube = lbucub * rcpqty1
     C                   eval      lbuwgt = itswgt
     C                   eval      lbswgt = lbuwgt * rcpqty1
     C                   endif

     *  Create label record for breakdown 1 qty (PK)

     C*>                 if        w1umt   = '1' or
     C*>                           w1umt   = 'N'

     C                   if        rcpqty2 > *zeros or
     C                             rcpqty1 > *zeros and
     C                             ittype  = 'S'
     C                   eval      lbutyp  = '1'
     C                   eval      lbucod  = itum2

     C                   if        itumq2 <> *zeros
500cAC     itcube        div(h)    itumq2        lbucub
500cAC     lbucub        mult      rcpqty1       lbcube
500cAC     itswgt        div(h)    itumq2        lbuwgt
500cAC     lbuwgt        mult      rcpqty1       lbswgt

CBIkAC                   if        client = cheney
CBIkAC                             and rcpqty2 > *zeros
CBIkAC     lbucub        mult      rcpqty2       lbcube
CBIkAC     lbuwgt        mult      rcpqty2       lbswgt
CBIkAC                   eval      lbqalc = rcpqty2
CBIkAC                   eval      lbqpck = rcpqty2
CBIkAC                   endif

     C                   endif
     C                   endif

     *  Create label record for break 2 qty (PK)

     C*--->              if        w1umt  = '2' or
     C*--->                        w1umt  = '1' and

     C                   if        rcpqty3 > *zeros or
     C                             rcpqty2 > *zeros and
     C                             ittype = 'S'
     C                   eval      lbutyp = '2'
     C                   eval      lbucod = itum3
     C                   if        itumq2 <> *zeros and
     C                             itumq3 <> *zeros
500cAC     itcube        div(h)    itumq2        lbucub
     C     lbcube        div(h)    itumq3        lbucub
     C     lbucub        mult      rcpqty1       lbcube
     C     itswgt        div(h)    itumq2        lbuwgt
     C     lbswgt        div(h)    itumq3        lbuwgt
     C     lbuwgt        mult      rcpqty1       lbswgt
     C                   endif
     C                   endif

     C                   eval      lbtrn# = pttrn#
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#

     C                   eval      lbgrp1 = @pgrp1
     C                   eval      lbgrp2 = @pgrp2
     C                   eval      lbtype = 'P'
     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   if        w1xdk  = 'Y'
     C                   eval      lbaisl = slaisl
     C                   eval      lbloc  = slloc
     C                   eval      lbrlvl = slrlvl
     C                   eval      lbhand = slhand
     C                   eval      lbpseq = slpseq
     C                   eval      lbstyp = slstyp
     C                   eval      lbdisp = sldisp
     C                   eval      lbdsp2 = *blanks
     C                   eval      lbasl2 = 'XDK'
     C                   endif

700aAC
700aA*  Put into RCV slot and create license.
700aAC                   exsr      zzurcvSlot
700aAC                   if        error
700aAC                   endif
700aAC                   eval      lbaisl = $slaisl
700aAC                   eval      lbloc  = $slloc
700aAC                   eval      lbrlvl = $slrlvl
700aAC                   eval      lbhand = $slhand
700aAC                   eval      lbpseq = $slpseq
700aAC                   eval      lbstyp = $slstyp
700aAC                   eval      lbdisp = $sldisp

     C                   write     lbrec

     *  Print label.  BYPASS THE $PFLAG LOGIC

     C                   goto      bypas1

     C*                  if        not $pflag
     C*                  eval      $acmd  = '*LABEL  '
     C*                  eval      $atie  = *zeros
     C*                  eval      $ahigh = *zeros
     C*                  eval      $aqty  = rcpqty1
     C*                  move      *blanks       $apslt           12
     C*                  move      *blanks       $adisp           12
     C*                  move      *blanks       $astyp            1
     C*                  move      lbucod        $aum

     C*                  if        $pexpd = *zeros
     C*                  eval      $aexpd = *zeros
     C*                  else
     C*                  eval      $cvcmd = '*CMDMDY '
     C*                  eval      $cvd8i = $pexpd
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt

     C*                  eval      $aexpd = $cvd6o
     C*                  endif

     C*                  call      'OPLPGM'
     C*                  parm                    $acmd             8
     C*                  parm                    pttrn#
410 MC*                  parm      $pwhse        $pwhs             3 0
     C*                  parm                    itwhdp
     C*                  parm                    $astyp
     C*                  parm                    $adisp
     C*                  parm                    $apslt
     C*                  parm                    $aqty             5 0
     C*                  parm                    $aum              2
     C*                  parm                    $atie             4 0
     C*                  parm                    $ahigh            2 0
     C*                  parm                    $rcpitem
     C*                  parm                    itdesc
     C*                  parm                    itpdsc
     C*                  parm                    itupc
     C*                  parm                    $pven
     C*                  parm                    $pvitm
     C*                  parm                    $rcppo
     C*                  parm                    today6
     C*                  parm                    $aexpd            6 0
     C*                  parm                    $pdev
     C*                  parm                    $pform
     C*                  endif
     C     bypas1        tag

     *  Create transaction record.

     C                   if        w1xdk  = 'Y'
     C                   eval      @pwhdp = slwhdp
     C                   eval      @pstyp = slstyp
     C                   else
     C                   eval      @pwhdp = itwhdp
     C                   eval      @pstyp = itstyp
     C                   endif

     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd             8
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      'PUTEMP'      @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm                    @pwhdp            5
     C                   parm                    @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      1             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      rcppo         @ppo              9
     C                   parm      'P'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
650 A
650 A*  Create P/O History record when not on file.
650 A
650 AC                   eval      kyeti = 0
650 AC     keyphh        setll     pohhdr
650 AC                   if        not %equal(pohhdr)
650 AC                   exsr      zzaddpohhdr
650 AC                   endif

405 A
     *  Close transaction if it is a for cross dock.
405 A
     C                   if        w1xdk  = 'Y'
CBIjA **>                   **?**  or ocaxdk  = 'Y'
     C                   eval      $lcmd  = '*CLOSE  '
     C                   eval      $ltype = '*INTER  '
     C                   eval      $lwhse = *zeros
     C                   eval      $lrte  = *blanks
     C                   eval      $lpo   = *blanks
     C                   eval      $ltrn# = pttrn#
405 A
405 AC                   call      'PT132'
405 AC                   parm                    $lparm
405 AC                   endif
414 A
     *  Add record to PORCV to marked as touched/received.
414 A
414 AC*-------->?        exsr      zzurcv

     *  Close license record.

     C                   if        w1xdk <> 'Y'
     C     fileky        chain     license                            7978

     C                   eval      liwhse = $pwhse
     C                   eval      lilcns = rcplcns
     C                   eval      litrn# = pttrn#

     *  Record not found. Try adding record.

     C                   if        *in79
     C                   write     lirec                                76
     C                   if        not *in79
417bA
     *  License tracking item. Write out tracking record.
417bA
     C                   if        $plict = 'Y' or
     C                             $plott = 'Y'
417bAC*--->              exsr      zzllp
417bAC                   endif
     C                   endif
417bA
     C*--->              eval      error  = *on
     C*--->              seton                                        85
     C*--->              seton                                        39
     C*--->              seton                                        40
     C*--->              seton                                        19
     C*--->              eval      errmsg = desc(4)
     C*--->              exsr      zm7871
     C*--->              exsr      sfldsp
700bA*
700bAC                   else
700bAC                   unlock    license
409 AC                   endif
     C                   endif
     C                   endif


     *  Flush labels out of spool file.

     C                   goto      bypas2

     C*                  if        $pflag = *off
     C*                  eval      $acmd  = '*FLUSH'
     C*                  call      'OPLPGM'
     C*                  parm                    $acmd             8
     C*                  parm                    pttrn#
     C*                  parm                    $pwhse
     C*                  parm                    itwhdp
     C*                  parm                    $astyp
     C*                  parm                    $adisp
     C*                  parm                    $apslt
     C*                  parm                    $aqty             5 0
     C*                  parm                    $aum              2
     C*                  parm                    $atie             4 0
     C*                  parm                    $ahigh            2 0
     C*                  parm                    $rcpitem
     C*                  parm                    itdesc
     C*                  parm                    itpdsc
     C*                  parm                    itupc
     C*                  parm                    $pven
     C*                  parm                    $pvitm
     C*                  parm                    $rcppo
     C*                  parm                    today6
     C*                  parm                    $aexpd            6 0
     C*                  parm                    $pdev
     C*                  parm                    $pform
     C*                  endif
     C*
     C     bypas2        tag


     *  Update PO detail record.

     C                   goto      bypas3

218 AC*    keypd         chain     podtl                              79
     C*                  if        not *in79
     C*                  eval      pdqrc1 = $prq1
     C*                  eval      pdqrc2 = $prq2
     C*                  eval      pdqrc3 = $prq3
     C*                  eval      pddwgt = $pdwgt
218 AC*                  update    pdrec
218 AC*                  endif

     C*                  eval      $prtn  = '*OK      '
     C*                  eval      $pord  = $pbat

     C     bypas3        tag

     C                   if        rcplcns2 <> *blanks
     C                   eval      rcpText = *blanks
     C                   eval      rcplcns2 = *blanks
     *  Existing put away deleted new one created
     C                   eval      rcpText = 'Putaway transaction deleted '
     C                                     + %char(savtrn#)
     C                                     + 'Putaway transaction created '
     C                                     + %char(pttrn#)
     C                   else
     *  Putaway created successfully
     C                   eval      rcpText = 'Putaway transaction '
     C                                     + %char(pttrn#)
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ErrorChecks  Check for data errors
     *----------------------------------------------------------------

     C     ErrorChecks   begsr

     *  Verify update type: A=add, C=change, D=delete

     C                   eval      error = *off
700dA*
700dA*   Get default values for the user.
700dA*
700dAC                   call      'GETUSER'
700dAC                   parm                    rcpusr
700dAC                   parm      0             #whse             3 0
700dAC                   parm      0             #emp#             5 0
700dAC                   parm                    #fnam            15
700dAC                   parm                    #init             1
700dAC                   parm                    #lnam            20
700dAC                   parm                    #whdp             5
700dAC                   parm                    #styp             1
700dAC                   parm                    #shft             6
700dAC                   parm                    #crew             6
700dAC                   parm      0             #nhrs             3 1
700dAC                   parm                    #rtn              8
700dAC                   if        #rtn = '*OK'
700dAC                   eval      usrfound = '1'
700dAC                   else
700dAC                   eval      usrfound = '0'
700dAC                   endif

     C                   select
     C                   when      rcptype = 'A'

     *  Verify license doesn't exist
     C     lickey        chain(n)  license                            76
     C                   if        not *in76
     C                   eval      error = *on
CBIeAC     'License '    cat       rcplcns       rcpText
CBIeAC     rcpText       cat       exists:1      rcpText
CBIeAC                   move      rcpseq        savseq
CBIeAC     rcpText       cat       seq#:1        rcpText
CBIeAC     rcpText       cat       savseq:1      rcpText
730 AC                   eval      rcpText = %trim(rcpText)
730 AC                                       + ' in file License'
CBI AC                   eval      sbText  = rcpText
     C                   leavesr
     C                   endif
730 A*
730 A*  Check LICLOG before accepting this license
730 A*
730 AC                   exsr      clr$license
730 AC                   eval      $liToLcnsU  = *on
730 AC                   eval      $liToLcns   = rcplcns
730 AC                   eval      $liOLcnsU   = *on
730 AC                   eval      $liOLcns    = rcplcns
730 AC                   eval      $dricommand = '*LICENSE'
730 AC                   eval      $drisubcmd  = '%GETINFO'
730 AC                   eval      $drisys2upd = 'D'
730 AC                   eval      ck4err      = *off
730 AC                   exsr      zzzdricop
730 Ac* if we get an ok on the return this means it exist - don't use
730 AC                   if        $drireturn    = '*OK'
730aAC                             and $liToAisl <> 'OSS'
730 AC                   eval      error   = *on
730 AC                   eval      rcptext = 'License '
730 AC                                       + %trim(rcplcns)
730 AC                                       + ' '
730 AC                                       + exists
730 AC                                       + ' '
730 AC                                       + seq#
730 AC                                       + %editc(rcpseq : 'X')
730 AC                                       + ' in file LicLog'
730 AC                   eval      sbText  = rcpText
730 AC                   leavesr
730 AC                   endif
730bA*
730bA*  Check LICINFO before accepting this license
730bA*
730bAC                   exsr      clr$licinfo
730bAC                   eval      $lnwhse     = $pwhse
730bAC                   eval      $lnlcns     = rcplcns
730bAC                   eval      $dricommand = '*LICINFO'
730bAC                   eval      $drisubcmd  = '%GET'
730bAC                   eval      $drisys2upd = 'D'
730bAC                   eval      ck4err      = *off
730bAC                   exsr      zzzdricop
730bAc* if it exist don't allow to use.
730bAC                   if        $drireturn = '*OK'
730bAC                   eval      error   = *on
730bAC                   eval      rcptext = 'License '
730bAC                                       + %trim(rcplcns)
730bAC                                       + ' '
730bAC                                       + exists
730bAC                                       + ' '
730bAC                                       + seq#
730bAC                                       + %editc(rcpseq : 'X')
730bAC                                       + ' in file LicInfo'
730bAC                   eval      sbText  = rcpText
730bAC                   leavesr
730bAC                   endif

     *  Verify item number

     C     pirkey        chain     piritem                            76
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      rcpText = 'Invalid item number'
CBI AC                   eval      sbText  = rcpText
     C                   leavesr
     C                   endif

     *  Verify Case Qty is not zero.

     C                   if        rcpqty1 <= 0
     *  For Cheney, check qty2 before allowing error.                 it
CBIkAC                   if        client = Cheney
CBIkAC                             and rcpqty2 > 0
CBIkAC                   else
     C                   eval      error = *on
     C                   eval      rcpText = 'Case qty 1 can not be zero'
CBI AC                   eval      sbText  = rcpText
     C                   leavesr
CBIkAC                   endif
     C                   endif

     *  Current Dakota system does not receive PKs, if any on pallet, it
     *  is sent to repack dept, they put it away. Also, Rfscrn/Put Away
     *  option does not process PKs.

     *  Verify breakdown qty1 are not sent.

     C                   if        rcpqty2 > 0
     *  For Cheney, check qty2 before allowing error.                 it
CBIkAC                             and client <> Cheney
     C                   eval      error = *on
     C                   eval      rcpText = 'Breakdown qty 1 not allowed'
CBI AC                   eval      sbText  = rcpText
     C                   leavesr
     C                   endif

     *  Verify breakdown qty2 are not sent.

     C                   if        rcpqty3 > 0
     C                   eval      error = *on
     C                   eval      rcpText = 'Breakdown qty 2 not allowed'
CBI AC                   eval      sbText  = rcpText
     C                   leavesr
     C                   endif
      *---------------------------------------------------------------------
     *  The "C" tansaction operation, is to be used for two purposes:
     *  To delete an existing put away info (zero out all quantity fields
     *  found in all records involved) and create a replacement put away
     *  process. The other purpose is simply change qty values in all
     *  records quantity fields involved in the creation of the existing
     *  put away info (per SAP team).
      *---------------------------------------------------------------------

     C                   when      rcptype = 'C'

     *  Verify current license does exist

     C     lickey        chain     license                            76
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      rcpText = 'License does not exist'
CBI AC                   eval      sbText  = rcpText
     C                   leavesr
     C                   endif

     *  Verify item number

     C     pirkey        chain     piritem                            76
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      rcpText = 'Invalid item number'
CBI AC                   eval      sbText  = rcpText
700bAC                   unlock    license
     C                   leavesr
     C                   endif

     *  Verify transaction does exist

     C     litrn#        chain     pirtran                            76
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      rcpText = 'Transaction does not exist'
CBI AC                   eval      sbText  = rcpText
700bAC                   unlock    license
     C                   leavesr
     C                   else
     *  Being put away?

     C                   if        ptstat = '2'
     C                   eval      error = *on
     C                   eval      rcpText = 'Pallet is being put away'
CBI AC                   eval      sbText  = rcpText
700bAC                   unlock    license
     C                   leavesr
     C                   endif
     C                   endif

     *  Get label record and change qty

     C     lbl90key      chain     label90                            76
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      rcpText = 'Label record does not exist'
CBI AC                   eval      sbText  = rcpText
700bAC                   unlock    license
     C                   leavesr
     C                   endif

     *  Verify new replace values

     C                   if        rcplcns2 = *blanks and
     C                             rcpqty1  = *zeros
     C                   eval      error = *on
     C                   eval      rcpText = 'Invalid replace values'
CBI AC                   eval      sbText  = rcpText
700bAC                   unlock    license
     C                   leavesr
     C                   endif

     *  If deleting existing license, qty for new license must be > 0

     C                   if        rcplcns2 <> *blanks and
     C                             rcpqty1 = *zeros
     C                   eval      error = *on
     C                   eval      rcpText = 'New license, Qty must be '
     C                                     + 'greater than zero'
CBI AC                   eval      sbText  = rcpText
700bAC                   unlock    license
     C                   leavesr
     C                   endif

     *  Verify replace license does not exist

     C                   if        rcplcns2 <> *blanks
     C     lickey2       chain     license                            76
     C                   if        not *in76
     C                   eval      error = *on
     C                   eval      rcpText = 'Replace license already'
     C                                     + ' exists'
CBI AC                   eval      sbText  = rcpText
700bAC                   unlock    license
     C                   leavesr
     C                   endif
     C                   endif

     C                   eval      savtrn# = pttrn#

     *  Update received quantity while has not been put away

     C                   if        ptstat = '1'
     C                   if        rcplcns2 <> *blanks

     *  Set reading mechanism to existing license record to delete it

     C     lickey        chain     license                            76

     *  Delete all records involved in the current pallet receving process.
     *  for the item received.

     C                   delete    lirec
     C                   delete    ptrec
     C                   delete    lbrec2

CBIaA*  Set reading mechanism to existing porcv and pomfr records
CBIaA*  to delete them.
CBIaA
CBIaAC     porcvkey      chain     porcv                              76
CBIaAC                   if        not *in76
CBIaAC                   delete    porrec
CBIaAC                   endif

CBIaAC     pomfrkey      chain     pomfr                              76
CBIaAC                   if        not *in76
CBIaAC                   delete    pmrec
CBIaAC                   endif

     C                   eval      rcpText = 'Putaway transaction deleted '
     C                                     + %char(pttrn#)
CBI AC                   eval      sbText  = rcpText
     C                   else

     *  Update label quantity

     C                   eval      lbqalc  = rcpqty1
     C                   eval      lbqpck  = rcpqty1
     C                   eval      lbcube  = lbucub * lbqpck
     C                   eval      lbswgt  = lbuwgt * lbqpck
     C                   update    lbrec2

     *  Update transaction quantity

     C                   eval      ptpcs   = rcpqty1
     C                   eval      ptcube  = lbcube
     C                   eval      ptswgt  = lbswgt
     C                   update    ptrec
     C                   endif
     C                   endif


     *  Update received quantity after it has been put away

     C                   if        ptstat > '2'

     C                   if        rcplcns2 <> *blanks
CBIcAC                   eval      error = *on
CBIcAC                   eval      rcpText = 'Can''t change license on'
CBIcAC                                     + ' an already put away'
CBIcAC                                     + ' pallet'
CBIcAC                   eval      sbText  = rcpText
CBIcA*  Can't change $icense, pallet has been already put away.
CBIcAC                   leavesr
     C                   else
     *  Update existing put away qty.

     C                   move      rcpqty1       chgqty            5
     C                   endif

     C                   unlock    pirtran
     C                   unlock    label90
700bAC                   unlock    license

CBIcAC                   if        lbqpck  = rcpqty1
CBIcA*  Existing qty = record qty being processed, do nothing.
CBIcAC                   goto      bypas4
CBIcAC                   endif

     C                   move      lbtrn#        tran#
     C                   move      lblbl#        label#
     C                   move      lbdisp        lbdispl
     C                   move      lbitem        lbitem#
     C                   move      lbpo          lbpo#
CBIiDC*>                 move      lbwhse        lbwhsedpt
CBIiMC                   move      lbwhdp        lbwhsedpt

     *  Verify put away qty has not been altered (Transferred, Picked, etc)
     C                   exsr      ChkPutAwayQty
     C                   if        error = *on
     C                   leavesr
     C                   endif

     C                   eval      $lmsg   = *blanks

     C                   call      @fixpo1s
     C                   parm                    $pWhse3A
     C                   parm                    lbpo#
     C                   parm                    lbwhsedpt
     C                   parm                    lbitem#
     C                   parm                    tran#
     C                   parm                    label#
     C                   parm                    lbdispl
     C                   parm                    chgqty
     C                   parm                    $lrtn
     C                   parm                    $pMessage

     C                   if        $pMessage <> *blanks
     C                   eval      error = *on
     C                   eval      rcpText = $pMessage
CBI AC                   eval      sbText  = rcpText
     C                   leavesr
     C                   endif
     C                   endif

CBIcAC     bypas4        tag
     C                   eval      rcpText = 'Putaway transaction changed '
     C                                     + %char(pttrn#)
      *---------------------------------------------------------------------
     *  "D" transaction is to be used to delete an existing put away info
     *  (zero out quantitiy fields in all records involved in the put away
     *  creation process) only (per SAP team).
      *---------------------------------------------------------------------

     C                   when      rcptype = 'D'

     *  Verify license does exist

700cDC*    lickey        chain     license                            76
700cMC     lickey        chain (n) license                            76
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      rcpText = 'License does not exists'
CBI AC                   eval      sbText  = rcpText
     C                   leavesr
     C                   endif

     *  Verify transaction does exist

700cDC*    litrn#        chain     pirtran                            76
700cMC     litrn#        chain (n) pirtran                            76
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      rcpText = 'Transaction does not exist'
CBI AC                   eval      sbText  = rcpText
     C                   leavesr
     C                   endif

     *  Pallet is being put away?

     C                   if        ptstat = '2'
     C                   eval      error = *on
     C                   eval      rcpText = 'Pallet is being put away'
CBI AC                   eval      sbText  = rcpText
700bAC                   unlock    license
     C                   leavesr
     C                   endif

     *  Pallet has been put away?
CBIiAC                   if        ptstat > '2'
CBIiAC                   eval      error = *on
CBIiAC                   eval      rcpText = 'Pallet has been put away'
CBIiAC                   eval      sbText  = rcpText
CBIiAC                   leavesr
CBIiAC                   endif

     *  The delete license transaction will be driven by code "D" and the
     *  the value of an existing license # to be deleted. This will
     *  be the only function performed by this block of logic.

     *  Get label record and change qty

700cDC*    lbl90key      chain     label90                            76
700cMC     lbl90key      chain (n) label90                            76
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      rcpText = 'Label record does not exist'
CBI AC                   eval      sbText  = rcpText
700bAC                   unlock    license
     C                   leavesr
     C                   endif

     *  Delete received related records while has not been put away

     C                   if        ptstat = '1'
700cAC                   eval      $lcmd = '*DELETE'
700cAC                   eval      $lrtn = ' '
700cAC                   eval      $ltrn2# = litrn#
700cAC                   eval      $llbl# = lblbl#
700cAC                   eval      $lqpck = 0
700cAC                   eval      $lqrmn = 0
700cAC                   eval      $lpckc = 0
700cAC                   eval      $lrecc = 0
700cAC                   eval      $lcwgt = '0'
700cAC                   eval      kycode = '*PICK   '
700cAC     opdkey        chain     optiond
700cAC                   if        not %found(optiond)
700cAC                   eval      opmput = 'N'
700cAC                   endif
700cA*
700cAC                   eval      $lmput = opmput
700cAC                   if        opmput = 'Y'
700cAC                   if        lbdisp <> ' '
700cAC                   eval      $lmput = 'N'
700cAC                   endif
700cAC                   endif
700cA*
700cAC                   call      'PO144'
700cAC                   parm                    $lparm

     *  Delete all records involved in the pallet receving process.
     *  for the item received.
700cDC*                  delete    lirec
700cDC*                  delete    ptrec
700cDC*                  delete    lbrec2

CBIaA*  Set reading mechanism to existing porcv and pomfr records
CBIaA*  to delete them.
CBIaA
700cDC*    porcvkey      chain     porcv                              76
700cDC*                  if        not *in76
700cDC*                  delete    porrec
700cDC*                  endif

700cDC*    pomfrkey      chain     pomfr                              76
700cDC*                  if        not *in76
700cDC*                  delete    pmrec
700cDC*                  endif

     C                   eval      rcpText = 'Putaway transaction deleted '
     C                                     + %char(pttrn#)
     C                   endif

     *  instead of deleting zero out received quantity after put away

     C                   if        ptstat > '2'

     C                   unlock    pirtran
     C                   unlock    label90
700bAC                   unlock    license

     C                   move      lbtrn#        tran#
     C                   move      lblbl#        label#
     C                   move      lbdisp        lbdispl
     C                   move      lbitem        lbitem#
     C                   move      lbpo          lbpo#
CBIiDC*>                 move      lbwhse        lbwhsedpt
CBIiMC                   move      lbwhdp        lbwhsedpt

     *  Verify put away qty has not been altered (Transferred, Picked, etc)

     C                   exsr      ChkPutAwayQty
     C                   if        error = *on
     C                   leavesr
     C                   endif

     C                   move      *zeros        chgqty            5
     C                   eval      $lmsg   = *blanks

     C                   call      @fixpo1s
     C                   parm                    $pWhse3A
     C                   parm                    lbpo#
     C                   parm                    lbwhsedpt
     C                   parm                    lbitem#
     C                   parm                    tran#
     C                   parm                    label#
     C                   parm                    lbdispl
     C                   parm                    chgqty
     C                   parm                    $lrtn
     C                   parm                    $pMessage

     C                   if        $pMessage <> *blanks
     C                   eval      error = *on
     C                   eval      rcpText = $pMessage
CBI AC                   eval      sbText  = rcpText
     C                   leavesr
     C                   end

     C                   if        rcplcns2 = *blanks
     C                   eval      rcpText = 'Putaway transaction deleted '
     C                                     + %char(pttrn#)
     C*>                 else
     C*>                 eval      rcpText = 'Putaway transaction deleted '
     C*>                                   + %char(pttrn#)
     C                   endif
     C                   endif

     C                   Other
     C                   eval      error = *on
     C                   eval      rcpText = 'Invalid update type'
CBI AC                   eval      sbText  = rcpText
     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  UpdateStgRec  Update staging record
     *----------------------------------------------------------------

     C     UpdateStgRec  begsr

     C                   if        error
     C                   eval      importError = *on
     C                   eval      rcpstatus = 'E'
     C                   else
     C                   eval      rcpstatus = 'S'
     C                   endif

     C                   exsr      zzzGetStamps
     C                   eval      rcpststs = stamp
     C                   eval      rcpstsuc = stampuc

     C                   update    rcprec

     C                   endsr

     *----------------------------------------------------------------
     *  zINZ     Extra program initialization
     *----------------------------------------------------------------

     C     zzINZ         begsr

      *  Define key for LICENSE file.

     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    rcplcns
650 A
650 A *  Define key for POHHDR file.
650 A
650 AC     *like         define    phheti        kyeti
650 AC     keyphh        klist
650 AC                   kfld                    $pwhse
650 AC                   kfld                    rcppo
650 AC                   kfld                    today
650 AC                   kfld                    kyeti

     *  Convert today's date into century format.

     C                   eval      $cvcmd  = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt

     C                   eval      today   = $cvd8o

     *                  FOR TEST PURPOSE ONLY
     C*--->              eval      today   = 20111215

     *  Convert today's date into MMDDYY format.

     C                   eval      $cvcmd  = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt

     C                   eval      today6  = $cvd6o
     C     pirkey        chain     itemdsc                            79

     C                   eval      $lprg   = #prog
     C                   eval      $plott  = 'N'
     C                   eval      $plict  = 'N'
     C                   eval      rcpText = *blanks
CBIeAC                   eval      exists  = ' already exists'
CBIeAC                   eval      seq#    = '- seq # '

     C                   endsr
650 A
650 A*----------------------------------------------------------------
650 A*  zzAddPOHHdr     Add P/O History Header Record
650 A*----------------------------------------------------------------
650 A
650 Ac     zzAddPOHHdr   begsr
650 A
650 Ac                   clear                   phhrec
650 A
650 Ac                   eval      phhwhs = $pwhse
650 Ac                   eval      phhpo  = rcppo
650 Ac                   eval      phhven = rcpven
CBIgA*
CBIgAC                   if        client = Cheney
CBIgAc                   eval      phhvna = rcpvnam
CBIgAC                   endif
CBIgA*
650 Ac                   eval      phhedt = today
650 Ac                   eval      phheti = 0
650 A*
650 AC                   write (e) phhrec
650 A*
650 Ac                   endsr

700aA*----------------------------------------------------------------
700aA*  zzurcvSlot   Put license into RCV slot
700aA*----------------------------------------------------------------
700aA*
700aAc     zzurcvSlot    begsr
710aA*
710aA*  Use DRI interface to get item.
710aA
710aAC                   exsr      clr$item
710aAC                   eval      $itwhse  = $pwhse
710aAC                   eval      $ititem  = rcpitem
710aA
710aAC                   eval      $dricommand = '*ITEM'
710aAC                   eval      $drisubcmd  = '%GETALL'
710aAC                   eval      $drisys2upd = 'D'
730cAC                   eval      ck4err      = *on
710aAC                   exsr      zzzdricop
710aAC                   if        error
710aAC                   clear                   #rcvdday
710aAC                   clear                   #rcvmday
710aAC                   clear                   #rcvuday
710aAC                   clear                   #rcvflgd
710aAC                   clear                   #rcvmflg
710aAc                   else
710aAC                   eval      #rcvdday = $imdday
710aAC                   eval      #rcvmday = $immday
710aAC                   eval      #rcvuday = $imuday
710aAC                   eval      #rcvflgd = $itflgd
710aAC                   eval      #rcvmflg = $immflg
710aAC                   endif
700aA*
700aAc                   exsr      clr$licinfo
700aAC                   eval      $lnwhse  = $pwhse
700aAC                   eval      $lnlcns  = rcplcns
700aAC                   eval      $lnseq = 1
700aAC                   eval      $lnitem = rcpitem
700aAC                   eval      $lnpo = rcppo
700aAC                   eval      $lnposeq = rcpseq
700aAC                   eval      $lnrcvtrn# = pttrn#
700aAC                   eval      $lnrcvlbl# = lblbl#
700aAC                   eval      $lnrcvqty = rcpqty1
700aAC                   eval      $lnexpdate = rcpexpd
700aAC                   eval      $lnmfgdate = rcpmfgd
700aAC                   eval      $lnmfgexp = rcpmfgd
700aAc                   eval      $lnenttype = *blank
700aAC                   if        rcpexpd > 0
710aDc*                  eval      $lndateflag = 'Y'
700aAc                   eval      $lnenttype = '*ENTDTE'
700aAC                   else
710aDc*                  eval      $lndateflag = 'N'
700aAC                   endif
700aAC                   if        rcpmfgd > 0
710aDc*                  eval      $lnmfgflag = 'Y'
700aAc                   eval      $lnenttype = '*MFGDTE'
700aAC                   else
710aAc*                  eval      $lnmfgflag = 'N'
700aAC                   endif
700aAC                   eval      $lnaddts = %timestamp()
710aAc                   eval      $lnmfgdays = #rcvmday
710aAc                   eval      $lnusrdays = #rcvuday
710aAc                   eval      $lndstdays = #rcvdday
710aAC                   eval      $lndateflag = #rcvflgd
710aAC                   eval      $lnmfgflag = #rcvmflg
700aA*
700aAc                   eval      $dricommand = '*LICINFO'
700aAc                   eval      $drisubcmd  = '%ADDS'
700aAc                   eval      $drisys2upd = 'D'
730cAC                   eval      ck4err      = *on
700aAc                   exsr      zzzdricop
700aAc                   if        error
700aAC                   goto      endurcvslot
700aAc                   endif
700aA
700aA*  Put license into a RCV slot
700aA
700aAC                   eval      #rcvArea = 'DOCK'
700aA
700aAC                   exsr      clr$slot
700aAC                   eval      $slwhseu = *on
700aAC                   eval      $slwhse  = $pwhse
700aAC                   eval      $slwhdpu = *on
700aAC                   eval      $slwhdp  = itwhdp
700aAC                   eval      $slitemu = *on
700aAC                   eval      $slitem  = rcpitem
700aAC                   eval      $sldispu = *on
700aAC                   eval      $sldisp  = ' '
700aAC                   eval      $slstatu = *on
700aAC                   eval      $slstat  = 'A'
700aAC                   eval      $slstypu = *on
700aAC                   eval      $slstyp = itstyp
700aAC                   eval      $slexpdu = *on
700aAC                   eval      $slexpd = rcpexpd
700aAC                   eval      $saitemu = *on
700aAC                   eval      $saitem  = rcpitem
700aA
700aAC                   eval      $saqtyu = *on
700aAC                   eval      $saqty1 = rcpqty1
700aAC                   eval      $saqty2 = rcpqty2
700aAC                   eval      $saqty3 = rcpqty3
700aA
700aAC                   eval      $saActionU = *on
700aAC                   eval      $saAction = 'RCV'
700aAC                   eval      $saTrn#U = *on
700aAC                   eval      $saTrn# = pttrn#
700aAC                   eval      $saETrn#U = *on
700aAC                   eval      $saETrn# = 0
700aAC                   eval      $saLbl#U = *on
700aAC                   eval      $saLbl# = lblbl#
700aAC                   eval      $saToPosU = *on
700aAC                   eval      $saToPos = 1
700aAC                   eval      $saToLcnsU = *on
700aAC                   eval      $saToLcns = rcplcns
700aAC                   eval      $saToVrfyU = *on
700aAC                   eval      $saToVrfy = 'Y'
700aAC                   eval      $saToCodeu = *on
700aAC                   eval      $saToCode = 'D'
700aAC                   eval      $saToAreaU = *on
700aAC                   eval      $saToArea = #rcvarea
700aAC                   eval      $saOLcnsU = *on
700aAC                   eval      $saOLcns = rcplcns
700aA
700aAC                   eval      $dricommand = '*SLOT'
700aAC                   eval      $drisubcmd  = '%RCVIN'
700aAC                   eval      $drisys2upd = 'D'

CBIjA*  May be *XDK coming from Ocala
CBIjAC                   if        ocaxdk = 'Y'
CBIjAC                   eval      $slaisl = 'XDK'
CBIjAC                   eval      $slaislu = *on
CBIjAC                   eval      $slloc = savlocn
CBIjAC                   eval      $sllocu = *on
CBIjAC                   eval      $slrlvlu = *on
CBIjAC                   eval      $slhandu = *on

CBIjAC                   eval      #rcvArea = savloc
CBIjAC                   eval      $saToArea = #rcvarea
CBIjAC                   eval      $saAction = 'XDK'
CBIjD **                 eval   ** $drisubcmd  = '%CRTXDOCK'
CBIjA **                 eval   ** $drisubcmd  = '%CRTAMP'
CBIjAC                   eval      $drisubcmd  = '%AMPIN'
CBIjAC                   endif

730cAC                   eval      ck4err      = *on
700aAC                   exsr      zzzdricop
700aAC                   if        error
700aAC                   goto      endurcvslot
700aAC                   endif
700aAC     endurcvslot   endsr

700aA*----------------------------------------------------------------
700aA*  zzzdricop  Call DRICOP
700aA*----------------------------------------------------------------
700aA
700aAC     zzzdricop     begsr
700aAC                   eval      error = *off
700aA
700aAC                   select
700aAC                   when      $dricommand = '*ITEM'
700aAC                   eval      $dridata = $item
700aAC                   eval      $dridata2 = $item2
700aAC                   when      $dricommand = '*SLOT'
700aAC                   eval      $dridata = $slot
700aAC                   eval      $dridata2 = $slot2
700aAC                   when      $dricommand = '*LICINFO'
700aAC                   eval      $dridata = $licinfo
700aAC                   eval      $dridata2 = $licinfo2
730dAC                   when      $dricommand = '*LICHIST'
730dAC                   eval      $dridata = $lichist
730dAC                   when      $dricommand = '*LICENSE'
730dAC                   eval      $dridata = $license
730dAC                   eval      $dridata2 = $license2
700aAC                   endsl
700aA
700aAC                   if        $dricommand = '*ITEM'
700aAC                             or $dricommand = '*SLOT'
730dAC                             or $dricommand = '*LICENSE'
700aAC                             or $dricommand = '*LICINFO'
700aAC                   call(e)   'DRICOP'
700aAC                   parm                    $dricommand
700aAC                   parm                    $drisubcmd
700aAC                   parm                    $drisys2upd
700aAC                   parm      #pgm          $driprogram
700aAC                   parm      ' '           $drireturn
700aAC                   parm      ' '           $drimessage
700aAC                   parm                    $dridata
700aAC                   parm                    $dridata2
700aAC                   else
700aAC                   call(e)   'DRICOP'
700aAC                   parm                    $dricommand
700aAC                   parm                    $drisubcmd
700aAC                   parm                    $drisys2upd
700aAC                   parm      #pgm          $driprogram
700aAC                   parm      ' '           $drireturn
700aAC                   parm      ' '           $drimessage
700aAC                   parm                    $dridata
700aAC                   endif
700aA
700aAC                   select
700aA
730cDC*                  when      %error
730cMC                   when      %error and ck4err = *on
700aAC                   eval      error = *on
700aA
730cDC*                  when      $drireturn <> '*OK'
730cMC                   when      $drireturn <> '*OK' and ck4err = *on
700aAC                   eval      error = *on
700aAC                   endsl
700aA
700aAC                   select
700aAC                   when      $dricommand = '*ITEM'
700aAC                   eval      $item = $dridata
700aAC                   eval      $item2 = $dridata2
700aAC                   when      $dricommand = '*SLOT'
700aAC                   eval      $slot = $dridata
700aAC                   eval      $slot2 = $dridata2
700aAC                   when      $dricommand = '*LICINFO'
700aAC                   eval      $licinfo = $dridata
700aAC                   eval      $licinfo2 = $dridata2
730dAC                   when      $dricommand = '*LICHIST'
730dAC                   eval      $lichist = $dridata
730dAC                   when      $dricommand = '*LICENSE'
730dAC                   eval      $license = $dridata
730dAC                   eval      $license2 = $dridata2
700aAC                   endsl
700aA
700aAC     enddricop     endsr

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------

     c     zzzEnd        begsr
      /free

        if importError;
          sbstatus = 'E';
          $pReturn = '*ERROR';
          $pMessage = sbText;
        else;
          sbstatus = 'S';
          sbText   = 'Import completed successfully';
        endif;

        exec sql
          update stgbatch
          set sbstatus = :sbstatus,
              sbText   = :sbText,
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = %trimr(sbText) + ' - '
                    + 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- po236s/zzzend';
          leavesr;
        endif;

760 A   if importError;
760 A     // if Staging Interface error report is scheduled then submit
760 A     // Use a timestamp as a session id.  MRCRPTSCH will call the
760 A     // update program to update the correct work file to report
760 A     exsr zzErrRpt;
760 A   endif;

      /end-free
     c                   endsr

760 A*----------------------------------------------------------------
760 A*  zzErrRpt   Send Error report for Staging File if scheduled
760 A*----------------------------------------------------------------
760 A
760 Ac     zzErrRpt      begsr
760 A /free
760 A
760 A *   Determine if scheduled, and if so what email to use based
760 A *   on current time compared to scheduled time(s).
760 A *   Loops thru BFCMRCRPRM looking for scheduled events and
760 A *   determining which one is closest to current time, but not
760 A *   after current time.
760aD     //currReport = 'BFCREPORTS.R40700';
760aM     currReport = 'BFCREPORTS.R42600';
760 A     // get the closest scheduled email address to current time.
760 A     // if email is return empty we assume not schedule and
760 A     // nothing is sent
760 A     schEmail=*blanks;
760 A     getSchTimeEml();

          // if email is returned then send out requested error report
          if schEmail <> *blanks;
            orient = 'P';
            grDev=*blanks;
            // Format URL
            // Note: pdf fields are genreated by MRCRPTSCH program
            url = '&OUTFMT=11'
                + '&D_DETAIL=1'
760aD           //+ '&CALCULA001=' + %char(%timestamp())
760aD           //+ '&CALCULA002=' + %char($pWhse)
760aD           //+ '&CALCULA003=' + $pBatid;
760aM           + '&R001=' + %char($pWhse)
760aM           + '&R002=' + $pBatid;

760aA       // Call program to populate Subject and Email Body to
760aA       // file intlog.  These are printed on Email error Report
760aA       // R42600 called below
760aA       wintlog ($pWhse:$pBatid);

            // Call program to print report

            monitor;

760 A         // get iSeries user and jobd from Report Scheduling
760 A         exec sql select opmusr,opjobd into :opmusr,:opjobd
760 A                   from opsmrcrpt
760 A                where opwhse=:$pwhse
760 A               fetch first row only;
760 A         if sqlstt = '00000';
760 A            sbmusr = opmusr;
760 A            sbmjobd = opjobd;
760 A            sbmlibl = '*JOBD';
760 A         else;
760 A            sbmusr = '*CURRENT';
760 A            sbmjobd = '*USRPRF';
760 A            sbmlibl = '*CURRENT';
760 A         endif;
760 A
760 A         cmd = 'sbmjob '
760 A               +   'cmd('
760 A               +      'MRCRPTSCH ' +
760 A                    'WHSE(' + %char($pwhse) + ') '  +
760 A                    'RPTNAM(''' + %trim(currReport) + ''') ' +
760 A                    'URL(''' + %trim(url) + ''') ' +
760 A                    'EMAIL(' + sq + %trim(schEmail) + sq + ') ' +
760 A                    'PRINTER(' + sq + %trim(grdev) + sq + ') ' +
760 A                    'ORIENT(' + sq + %trim(orient) + sq + ')) ' +
760 A               'inllibl(' + %trim(sbmlibl) + ') ' +
760 A               'jobd(' + %trim(sbmjobd) + ') ' +
760 A               'user(' + %trim(sbmusr) + ') ' +
760 A               'jobq(QSYSNOMAX) ' +
760 A               'job(OI285SRSCH)';
760 A         qcmdexc(cmd: %len(cmd));

            on-error;
            endmon;
          endif;
760 A
760 A /end-free
760 Ac                   endsr

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------

     c     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzStart   Start processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzStart      begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'P',
              sbText   = 'Import started',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbstrts  = current_timestamp,
              sbstruc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- ii265s/zzzstart';
          leavesr;
        endif;

        importError = *off;

      /end-free
     c                   endsr

CBIaA*----------------------------------------------------------------
CBIaA*  zzzUrcv   Create PORCV record
CBIaA*----------------------------------------------------------------
CBIaAC*
CBIaAc     zzzUrcv       begsr

     C                   clear                   porrec

     C                   eval      porwhs = rcpwhse
     C                   eval      porpo  = rcppo
     C                   eval      porseq = rcpseq
     C                   eval      pordte = rcpdte
     C                   eval      portim = rcptim
     C                   eval      porusr = rcpusr
     C                   eval      pordev = *blanks
     C                   eval      poremp = *zeros
     C                   eval      portrn = pttrn#
     C                   eval      porlic = rcplcns
     C                   eval      porlbl = lblbl#
     C                   eval      poract = 'R'
CBIhAC                   eval      poredt = pordte
CBIhAC                   eval      poreti = portim

     C                   write     porrec

     C                   endsr

CBIaA*----------------------------------------------------------------
CBIaA*  zzzUmfr   Create POMFR record
CBIaA*----------------------------------------------------------------
CBIaAC*
CBIaAc     zzzUmfr       begsr

     C                   clear                   pmrec

     C                   eval      pmwhse = rcpwhse
     C                   eval      pmpo   = rcppo
     C                   eval      pmseq  = rcpseq
     C                   eval      pmitem = rcpitem
     C                   eval      pmexpd = rcpexpd
     C                   eval      pmmfgd = rcpmfgd
     C                   eval      pmtrn# = pttrn#
     C                   eval      pmlbl# = lblbl#

     C                   write     pmrec

     C                   endsr

760 A *----------------------------------------------------------------
760 A *  getSchTimeEml - Get Email address for specific error  report
760 A *----------------------------------------------------------------

760 Ap getSchTimeEml   b
760 Ad getSchTimeEml   pi

      *  Local Variables

     D weekday         s              3
     D currTime        s              5

            // Set 3 character value for day
            select;
              when DayofWeek(%date()) = 0;
                weekday = 'SUN';
              when DayofWeek(%date()) = 1;
                weekday = 'MON';
              when DayofWeek(%date()) = 2;
                weekday = 'TUE';
              when DayofWeek(%date()) = 3;
                weekday = 'WED';
              when DayofWeek(%date()) = 4;
                weekday = 'THU';
              when DayofWeek(%date()) = 5;
                weekday = 'FRI';
              when DayofWeek(%date()) = 6;
                weekday = 'SAT';
            endsl;

            // get current time (hh:mm)
            currTime = %subst(%char(%time():*ISO):1:5);

            // now query scheduled entries for closest
            // time to current system time that is active
            // for the current Report being processed
            exec sql select bsvalue into :schEmail
                from bfcmrcrprm as a where a.bswhse=:$pWhse and
              a.bsrptpgm=:currReport and a.bsmrctbl='E' and
              a.bsmrcprm='EMAIL' and
               (select b.bsvalue from bfcmrcrprm as b where
                 b.bswhse=a.bswhse and b.bsrptpgm=a.bsrptpgm and
                 b.bsschseq=a.bsschseq and b.bsmrctbl='D'
                 and b.bsmrcprm=:weekday)='Y' and
               (select min(b.bsvalue) from bfcmrcrprm as b where
                 b.bswhse=a.bswhse and b.bsrptpgm=a.bsrptpgm and
                 b.bsschseq=a.bsschseq and b.bsmrctbl='X'
                 and b.bsmrcprm='SCHTIME')<:currTime;

760 Ap getSchTimeEml   e
760 A*----------------------------------------------------------------*
760 A* Procedure:  DayOfWeek
760 A* Purpose:  Determine the day of week for a particular date
760 A* Parameters:
760 A*    I: dt   -- date
760 A* Returns:
760 A*    0..6    -- 0=Sunday, 1=Monday, 2=Tuesday, etc.
760 A* Notes:
760 A*    January 5, 1800 is a Sunday.  This procedure only works for
760 A*    dates later than 1800-01-05.
760 A*----------------------------------------------------------------*

760 AP DayOfWeek       b
760 AD DayOfWeek       pi            10i 0
760 AD   dt                            d   value datfmt(*iso)
      /free
        return %rem (%diff (dt: d'1800-01-05': *days): 7);
      /end-free
760 AP DayOfWeek       e
