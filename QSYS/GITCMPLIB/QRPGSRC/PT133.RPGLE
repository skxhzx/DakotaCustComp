640 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  PT133     Update PLTSUM AND PLTSTP file
     *  20 August, 1997
     *  Dave Sommerville
     *  Hemant Kapadia
     *
     *  Revisions:
     *
500 A*    08/11/05  MLB  5.00
     *      - Fix: Revised program to loop if LBRTE <> $PRTID.
     *        Duplicate label records can occur when more than
     *        6 months of label history is kept.
     *
520 A*    09/29/08  MLB  5.20
     *      - Fix: Revised program to loop if PSRTID <> $PRTID.
     *
520aA*    04/24/09  DAS  5.20a
     *      - Converted to ILE
     *      - Fix: Revised program to update Tote Merge records
     *        correctly.
     *
640 A*    04/26/12  RBD  6.40
     *      - Fix: Added update of RTESUM and RTECSUM files.
     *
710aA*    10/20/17  NLK  7.10
     *      - Fix: Merge record QPCK was not updated in Voice
     *             when Orig record was changed. Don't allow
     *             QPCK to exceed QALC. Discovered at Jordanos.
     *
720aA*    09/17/18  DAS  7.20a
     *      - If PLTSUM record is type 'P' (Enhanced TruckBuildr),
     *        revised to also update corresponding type 'O' record.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpltsum4   uf   e           k disk
720aAFpltsum2   uf   e           k disk    rename(psrec:psrec2) prefix(P2_)
     Fpltstp1   uf   e           k disk
640 AFlabel     if   e           k disk    rename(lbrec:lbrecx) prefix(L_)
     FLabel11   uf   e           k disk
520aAFlabel7    if   e           k disk    prefix(L7_)
520aAFoptionz   if   e           k disk
640 AFrtesum    uf   e           k disk
640 AFrtecsum   uf   e           k disk
     *----------------------------------------------------------------
     *  General Data structure.
     *
     D ds0             ds
     D  dsrec                  1     30
     D  dslbl#                 1      7  0
     D  dsfpck                 8     12  0
     D  dsfcub                13     21  3
     D  dsfwgt                22     30  2
     *----------------------------------------------------------------
     *  Data structure.
     *
     D ds1             ds                  occurs(50)
     D  ary                    1   1500
     D                                     DIM(30)
     D  lstary              1501   1502  0
520aA*----------------------------------------------------------------
520aA*
520aA*  OPTIONZDS  Redefinition data structures for OPTIONZ file
520aA*
520aA*  *PICK  -  Picking options
     *
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
214 D**** OPPBRK  -  Break pallets by aisle (Y,N).
214 M*    OPPBRK  -  Aisle to start new pallet.
400 A*    OPPBLD  -  Pallet building method.
400 A*                1 = By stop then slot location.
400 A*                2 = By slot location then stop.
416 A*                3 = Descending by stop then location.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
500aA*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
500aA*    OPNWPL  -  Start new pallet when aisle changes if build method
500aA*               is 2=Location.
500dA*    OPFORD  -  Maximu orders per pallet.
500dM*    OPPTYP  -  Pallet type (P=Pallet, T=Tote).
500dA*    OPFTOT  -  Maximum totes per pallet.
500dA*    OPTECB  -  External tote cube.
500dA*    OPTICB  -  Internal tote cube.
500dA*    OPTSTP  -  Maximum stops per tote.
500dA*    OPTORD  -  Maximum orders per tote.
500dA*    OPTPCS  -  Maximum pieces per tote.
510 A*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
510aA*    OPGCDE  -  USF Group Code (0-9).
     *
     * Data structure
     *
     D opzdta          ds
     D  opnxtp                 1      7  0 inz(0)
213 D*I            0                         8   90OPBPCK
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     *I            0                        21  210OPFSTP
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
209 AD  opfbld                27     27  0 inz(0)
213 AD  opbpck                28     30  0 inz(0)
214 D*                                      31  31 OPPBRK
214 AD  oppbrk                31     33
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
500 D*                                      37  37 OPTOTE
500 D*             0                        38  422OPTCUB
500aAD  opbmrg                37     37
500aAD  opnwpl                38     38
500dAD  opford                39     40  0 inz(0)
500cMD  opptyp                41     41
500dAD  opftot                42     43  0 inz(0)
500dAD  optecb                44     48  2 inz(0)
500dAD  opticb                49     53  2 inz(0)
500dAD  optstp                54     55  0 inz(0)
500dAD  optord                56     57  0 inz(0)
500dAD  optpcs                58     60  0 inz(0)
510 AD  opstop                61     61
510aAD  opgcde                62     62
     D  opdend               117    117
     *----------------------------------------------------------------
     *  Variables
     *
     D diflft          s                   like(lbqpck)
520aAD difcub          s                   like($pfcub)
520aAD difpck          s                   like($pfpck)
520aAD difwgt          s                   like($pfwgt)
     D forevr          s               n
     D kycod1          s                   like(opzcod)
     D lstmlt          s              3  0
520aAD mFound          s               n
     D nwfcub          s                   like($pfcub)
     D nwfpck          s                   like($pfpck)
     D nwfwgt          s                   like($pfwgt)
720aAD odifcub         s                   like($pfcub)
720aAD odifpck         s                   like($pfpck)
720aAD odifwgt         s                   like($pfwgt)
     D svctr#          s                   like(lbctr#)
     D svfcub          s                   like($pfcub)
     D svfpck          s                   like($pfpck)
     D svfwgt          s                   like($pfwgt)
520aAD totePcs         s              5  0
520aAD toteWgt         s              9  2
     D wkstop          s                   like(lbstop)
     D wktrn#          s                   like(lbtrn#)
     D x               s              3  0
     D y               s              3  0
     D z               s              3  0
     *----------------------------------------------------------------
720aA*  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *
     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $ptrn#            7 0
     C                   parm                    $plbl#            7 0
     C                   parm                    $ppal#            7 0
     C                   parm                    $pctr#            7 0
     C                   parm                    $pstop            2 0
     C                   parm                    $pfpck            5 0
     C                   parm                    $pfcub            9 3
     C                   parm                    $pfwgt            9 2
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      wktrn# = $ptrn#
     C                   eval      wkstop = $pstop
     *
     *     Update corresponding PLTSUM and PLTSTP records.
640 A*     Also update corresponding RTESUM and RTECSUM records.
     *
     C     keyps4        setll     pltsum4
     C                   dou       forevr <> forevr
     C     keyps4        reade     pltsum4                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        $ppal# <> psplid  or
520 A*     or Omit pallet records for wrong route.
520 AC                             $prtid <> psrtid
     C                   iter
     C                   endif
     C                   eval      pspcs = pspcs - $pfpck
     C                   sub       $pfcub        pscube
     C                   eval      psswgt = psswgt - $pfwgt
     C                   update    psrec
     *
     C     keypss        chain     pltstp1                            77
     C                   if        *in77 <> *on
     C                   eval      psspcs = psspcs - $pfpck
     C                   sub       $pfcub        psscub
     C                   eval      pssswt = pssswt - $pfwgt
     C                   update    pssrec
     C                   endif
720aA
720aA*     Update corresponding O rec if necessary
720aA
720aaC                   if        pstype = 'P'
720aAC                   eval      odifpck = -$pfpck
720aAC                   eval      odifcub = -$pfcub
720aAC                   eval      odifwgt = -$pfwgt
720aAC                   exsr      UpdateORec
720aAC                   endif
     *
640 AC     $plbl#        chain     label
640 AC                   if        %found
640 AC     keyrtes       chain     rtesum                             77
640 AC                   if        *in77 <> *on
640 AC                   eval      rspckp = rspckp - $pfpck
640 AC                   sub       $pfcub        rspckc
640 AC                   eval      rspckw = rspckw - $pfwgt
640 AC                   update    rsrec
640 AC                   endif
640 AC                   endif
     *
640 AC     keyrtec       chain     rtecsum                            77
640 AC                   if        *in77 <> *on
640 AC                   eval      rcpckp = rcpckp - $pfpck
640 AC                   sub       $pfcub        rcpckc
640 AC                   eval      rcpckw = rcpckw - $pfwgt
640 AC                   update    rcrec
640 AC                   endif
     *
     C                   enddo
     *
520aA*   Determine zone type of pallet.
520aA*
520aAC     pickky        chain     optionz
520aAC                   if        not %found(optionz)
520aAC                   eval      opptyp = 'P'
520aAC                   endif
520aA*
520aA*   Update merge record(s).
520aA*
520aAC                   if        opptyp = 'T'
520aAC                   exsr      totzon
520aAC                   else
520aAC                   exsr      pltzon
520aAC                   endif
     *
     C                   eval      *inlr = *on
     C                   return
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *on
     *
     *  Define key for PLTSUM4 file.
     *
     C     keyps4        klist
     C                   kfld                    wktrn#
     *
     *  Define key for PLTSTP file.
     *
     C     keypss        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    psplid
     C                   kfld                    psrow
     C                   kfld                    pscol
     C                   kfld                    wkstop
     C                   kfld                    psbcnt
     *
     *  Define key for LABEL11 file.
     *
     C     keylb11       klist
     C                   kfld                    svctr#

     *  Define key for LABEL7 file.

520aAC     keylb7        klist
520aAC                   kfld                    $ptrn#
     *
     *  Define key for WORKLBL file.
     *
     C     keylw         klist
     C                   kfld                    $plbl#
     *
     *  Define key for pick options.
     *
     C                   eval      kycod1 = '*PICK   '
     C     pickky        klist
     C                   kfld                    kycod1
     C                   kfld                    pswhse
     C                   kfld                    pstruk
     C                   kfld                    psszon
     *
640 A*  Define key for RTESUM file.

640 AC     keyrtes       klist
640 AC                   kfld                    $pwhse
640 AC                   kfld                    $prtid
640 AC                   kfld                    L_lbwhdp
     *
640 A*  Define key for RTECSUM file.

640 AC     keyrtec       klist
640 AC                   kfld                    $pwhse
640 AC                   kfld                    $prtid
640 AC                   kfld                    pscomp
     *
     C                   endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  PLTZON  Pallet zone
520aA*
520aAC     pltzon        begsr
     *
     *
     C     1             occur     ds1
     C                   eval      dslbl# = $plbl#
     C                   eval      dsfpck = $pfpck
     C                   eval      dsfcub = $pfcub
     C                   eval      dsfwgt = $pfwgt
     C                   move      dsrec         ary(1)
     C                   eval      lstary = 1
     C                   eval      lstmlt = 1
     *
     C     1             do        lstmlt        x
     C     x             occur     ds1
     *
     C     1             do        lstary        y
     C                   move      ary(y)        dsrec
     C                   eval      svctr# = dslbl#
     C                   eval      svfpck = dsfpck
     C                   eval      svfcub = dsfcub
     C                   eval      svfwgt = dsfwgt
     *
     C     x             add       1             lstmlt
     C     lstmlt        occur     ds1
     C                   eval      lstary = 0
     C                   eval      ary = *blanks
     *
     *     Update corresponding merge label records.
     *
     C                   eval      diflft = svfpck
     *
     C     keylb11       setll     label11
     C                   dow       forevr = forevr
     C     keylb11       reade     label11                                78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     C                   if        diflft = 0
     C                   leave
     C                   endif
500 A*
500 A*   Wrong label record found. Read next record.
500 AC                   if        lbrte <> $prtid
500 AC                   iter
500 AC                   endif
     *
     C                   if        lbqpck >= svfpck
     C                   eval      nwfpck = svfpck
     C                   eval      nwfcub = svfcub
     C                   eval      nwfwgt = svfwgt
     C                   eval      lbqpck = lbqpck - svfpck
     C                   eval      lbcube = lbcube - svfcub
     C                   eval      lbswgt = lbswgt - svfwgt
     C                   eval      diflft = 0
710aAC                   if        lbqpck > lbqalc
710aAC                   eval      lbqpck = l_lbqpck
710aAC                   eval      lbcube = l_lbcube
710aAC                   eval      lbswgt = l_lbswgt
710aAC                   endif
     C                   else
     C                   eval      nwfpck = lbqpck
     C                   eval      nwfcub = lbcube
     C                   eval      nwfwgt = lbswgt
     C                   eval      svfpck = svfpck - lbqpck
     C                   eval      svfcub = svfcub - lbcube
     C                   eval      svfwgt = svfwgt - lbswgt
     C                   eval      lbqpck = 0
     C                   eval      lbcube = 0
     C                   eval      lbswgt = 0
     C                   eval      diflft = diflft - nwfpck
     C                   endif
     *
     C                   update    lbrec
     *
     *        Update corresponding PLTSUM and PLTSTP records.
     *
     C                   eval      wktrn# = lbtrn#
     C                   eval      wkstop = lbstop
     C     keyps4        setll     pltsum4
     C                   dou       forevr <> forevr
     C     keyps4        reade     pltsum4                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        lbpal# <> psplid  or
520 A*     or Omit pallet records for wrong route.
520 AC                             $prtid <> psrtid
     C                   iter
     C                   endif
     C                   eval      pspcs = pspcs - nwfpck
     C                   sub       nwfcub        pscube
     C                   eval      psswgt = psswgt - nwfwgt
     C                   update    psrec
     *
     C     keypss        chain     pltstp1                            77
     C                   if        *in77 <> *on
     C                   eval      psspcs = psspcs - nwfpck
     C                   sub       nwfcub        psscub
     C                   eval      pssswt = pssswt - nwfwgt
     C                   update    pssrec
     C                   endif
720aA
720aA*     Update corresponding O rec if necessary
720aA
720aaC                   if        pstype = 'P'
720aAC                   eval      odifpck = -nwfpck
720aAC                   eval      odifcub = -nwfcub
720aAC                   eval      odifwgt = -nwfwgt
720aAC                   exsr      UpdateORec
720aAC                   endif
     *
     C                   enddo
     *
     C                   eval      dslbl# = lblbl#
     C                   eval      dsfpck = nwfpck
     C                   eval      dsfcub = nwfcub
     C                   eval      dsfwgt = nwfwgt
     C                   add       1             lstary
     C                   eval      z = lstary
     C                   move      dsrec         ary(z)
     *
     C                   enddo
     *
     C     x             occur     ds1
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  TOTZON  Tote zone
520aA*
520aAC     totzon        begsr
     C                   eval      mFound = *off
     C                   eval      totePcs = 0
     C                   eval      toteWgt = 0

     *  Whip through all records for tote transaction

     C     keylb7        setll     label7

     C                   dow       forevr = forevr
     C     keylb7        reade     label7

     C                   if        %eof(label7)
     C                   leave
     C                   endif

     *    Total pieces picked for transaction

     C                   eval      totePcs += L7_lbqpck
     C                   eval      toteWgt += L7_lbswgt

     *    Get and lock corresponding 'M' record
     *    (only one tote 'O' record will correspond with the 'M' record)

     C                   if        not mFound
     C     L7_lblbl#     setll     label11
     C                   dow       forevr = forevr
     C     L7_lblbl#     reade     label11
     C                   if        %eof(label11)
     C                   leave
     C                   endif
     C                   if        lbrte <> $prtid
     C                   iter
     C                   endif
     C                   eval      mFound = *on
     C                   leave
     C                   enddo
     C                   endif

     C                   enddo

     *  If M record not found, get out (this shouldn't happen)

     C                   if        not mFound
     C                   leavesr
     C                   endif

     *  Update M record.

     C                   if        totePcs = 0
     C                   eval      nwfpck = 0
     C                   eval      nwfcub = 0
     C                   eval      nwfwgt = 0
     C                   else
     C                   eval      nwfpck = 1
     C                   eval      nwfcub = optecb
     C                   eval      nwfwgt = toteWgt
     C                   endif

     C                   eval      difpck = nwfpck - lbqpck
     C                   eval      difcub = nwfcub - lbcube
     C                   eval      difwgt = nwfwgt - lbswgt

     *  If no differences, then get out

     C                   if        difpck = 0
     C                             and difcub = 0
     C                             and difwgt = 0
     C                   unlock    label11
     C                   leavesr
     C                   endif

     *  Otherwise, update label M record.

     C                   eval      lbqpck = nwfpck
     C                   eval      lbcube = nwfcub
     C                   eval      lbswgt = nwfwgt
     C                   update    lbrec

     *  Update corresponding PLTSUM and PLTSTP records.

     C                   eval      wktrn# = lbtrn#
     C                   eval      wkstop = lbstop
     C     keyps4        setll     pltsum4

     C                   dou       forevr <> forevr
     C     keyps4        reade     pltsum4

     C                   if        %eof(pltsum4)
     C                   leave
     C                   endif
     C                   if        lbpal# <> psplid
     C                             or $prtid <> psrtid
     C                   iter
     C                   endif
     C                   eval      pspcs += difpck
     C                   eval      pscube += difcub
     C                   eval      psswgt += difwgt
     C                   update    psrec
     *
     C     keypss        chain     pltstp1
     C                   if        %found (pltstp1)
     C                   eval      psspcs += difpck
     C                   eval      psscub += difcub
     C                   eval      pssswt += difwgt
     C                   update    pssrec
     C                   endif
720aA
720aA*     Update corresponding O rec if necessary
720aA
720aaC                   if        pstype = 'P'
720aAC                   eval      odifpck = difpck
720aAC                   eval      odifcub = difcub
720aAC                   eval      odifwgt = difwgt
720aAC                   exsr      UpdateORec
720aAC                   endif

     C                   enddo

     C                   endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  UpdateORec  Update corresponding O rec
720aA*
720aAC     UpdateORec    begsr
720aA /free

       // Update PLTSUM O record

       chain (pswhse: psrtid: 'O': psgen: psrow: pscol) pltsum2;
       if %found(pltsum2);
         P2_pspcs += odifpck;
         P2_pscube += odifcub;
         P2_psswgt += odifwgt;
         update psrec2;
       endif;

       // Update PLTSTP O record

       dsplid = psplid;
       dsplsq = 0;
       chain (pswhse: psrtid: dsplid: psrow: pscol: wkstop: 0) pltstp1;
       if %found(pltstp1);
         psspcs += odifpck;
         psscub += odifcub;
         pssswt += odifwgt;
         update pssrec;
       endif;

720aa /end-free
     C                   endsr

