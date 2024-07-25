      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OR635     Assign tran#'s to TOTEHDR records.
     *  12 February 2008
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    02/11/08  DAS  5.20  P#00003
     *      - Created.
     *
520aA*    02/29/08  RBD  5.20a P#00011
     *      - Added new lf LABEL33H to be used in place of LABEL33.
     *        Key is whse, rte, tran, stop, order.
     *
520bA*    10/06/08  RBD  5.20b P#00011
     *      - Fix: Change field name TOHNUM to TOHCNT as TOHNUM was
     *        already being used in TORDH.  Also, field sizes for
     *        TOHNUM (now TOHCNT) and TOHPCS have increased.
     *
CWD A*    04/28/15  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. Physical file had order id added
     *        to make file key unique.
     *
730aA*    04/05/19  DAS  730a
     *      - Enh: Revised to update Merge Pallet Id. Re: This field
     *        is not being updated during dragdrop.
     *
730bA*    11/03/19  DAS  7.30b
     *      - Revised to use LABELW
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - Harbor
     *
HARaA*    02/12/08  DAS  HARa  P#00011
     *      - Added logic to create TOTEHDR records for CLR/FRZ zones.
     *
HARbA*    02/22/08  DAS  HARb  P#000011
     *      - Revised where tote number is incremented.
     *
HARcA*    02/26/08  RBD  HARc  P#00011
     *      - Fix: Revised to allow for multiple orders on the same
     *        trans/stop.  Revised where tote order, tote phys tran,
     *        tote merge tran, tote phys pallet, and tote merge
     *        pallet are populated.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Cash Wa
     *
CWD A*    04/19/16  MLB  CWD  P#01349
     *      - Revised pgm to create TOTEHDR records for Tote zones.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

520aDF*abel33   if   e           k disk
520aAFlabel33h  if   e           k disk
730bDF*abel     if   e           k disk
730bMFlabelw    if   e           k disk
     Foptionz   if   e           k disk
     Ftotehdr   uf a e           k disk
HARaAForddm     if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#harbor
CWD A /copy qcopysrc,id#cashwa
     D client          s             10
     D clientloc       s             10

HARaA*----------------------------------------------------------------
HARaA*  Order detail misc file data structures
HARaA*----------------------------------------------------------------
HARaA
HARaA /copy qcopysrc,orddm1_har
HARaA /copy qcopysrc,orddm2_har
HARaA /copy qcopysrc,orddm3_har
HARaA /copy qcopysrc,orddm4_har
HARaA /copy qcopysrc,orddm5_har

     *----------------------------------------------------------------
     *  *PICK  -  Picking options
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
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
209 AD  opfbld                27     27  0 inz(0)
213 AD  opbpck                28     30  0 inz(0)
214 AD  oppbrk                31     33
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
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
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Variables.
     *----------------------------------------------------------------

     D error           s               n
     D toteItemFound   s               n   inz(*off)
     D first           s               n
     D forever         s               n
     D kycode          s                   like(opzcod)
     D kyzone          s                   like(opzzon)
HARcAD lastord         s                   like(lbord)
     D laststop        s                   like(lbstop)
     D lasttrn#        s                   like(lbtrn#)
     D lastzone        s                   like(psszon)
520bDD*clrTote#        s                   like(tohnum) inz(0)
520bMD clrTote#        s                   like(tohcnt) inz(0)
520bDD*frzTote#        s                   like(tohnum) inz(0)
520bMD frzTote#        s                   like(tohcnt) inz(0)
     D toteExtCube     s              5  2 inz(0)
     D toteIntCube     s              5  2 inz(0)
     D toteMaxOrd      s              2  0 inz(0)
     D toteMaxPcs      s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route id
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Update TOTEHDR recs with tran#'s.

     C                   exsr      updTOTEHDR

     *  For Harbor, create TOTEHDR records for CLR/FRZ zones.

CWD AC                   select
CWD MC                   when      client = harbor
     C                   exsr      crtClrFrzRecs
CWD A*
CWD A*  For Cash Wa, create TOTEHDR records for all Tote zones.
CWD AC                   when      client = Cashwa
CWD AC                   exsr      crttotehdrrecs
CWD MC                   endsl

     *  Bye, Bye

     C     bottom        tag
     C                   eval      *inlr = *on
     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *inzsr  -  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define route id key for LABEL33H file.

     C     keyRtid       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     *  Define tran# key for LABEL33H file.

     C     keyTrn#       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lbtrn#

     *   Define full key for ORDHM file

     C     keyod         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbord
     C                   kfld                    lbseq
     C                   kfld                    lbitem

     *  Define key for OPTIONZ file.

     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    lbwhse
     C                   kfld                    pstruk
     C                   kfld                    kyzone

     *  Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client
     C                   parm                    clientloc

     C                   endsr

HARaA*----------------------------------------------------------------
HARaA*  crtClrFrzRecs   Create CLR/FRZ TOTEHDR recs for Harbor
HARaA*----------------------------------------------------------------
HARaA
HARaAC     crtClrFrzRecs begsr

     *  Loop through all labels for route in tran# order.

     C                   eval      first = *on
     C                   eval      lasttrn# = *loval
     C                   eval      laststop = *loval
     C                   eval      lastzone = *loval
HARcAC                   eval      lastord  = *loval
520aMC     keyRtid       setll     label33h

     C                   dow       forever = forever
520aMC     keyRtid       reade     label33h
     C                   if        %eof
     C                   leave
     C                   endif

     *    Only read O and B label records.

     C                   if        lbtype <> 'O'
     C                             and lbtype <> 'B'
     C                   iter
     C                   endif

     *    First time through, get tote info.

     C                   if        first
CWD AC                   eval      kyzone = 'TRMEZZ'
     C                   exsr      getToteInfo
     C                   eval      first = *off
     C                   endif

     *    If transaction number changed ...

     C                   if        lasttrn# <> lbtrn#
     C                             or laststop <> lbstop
HARcAC                             or lastord  <> lbord

     *      ... Create TOTEHDR record for last tran if necessary.

     C                   if        toteItemFound
     C                   exsr      crtTOTEHDR
     C                   eval      ToteItemFound = *off
     C                   endif

     *      ... Inizialize TOTEHDR fields.

     C                   exsr      inzTOTEHDRflds

     C                   eval      lasttrn# = lbtrn#
     C                   eval      laststop = lbstop
HARcAC                   eval      lastord  = lbord
     C                   eval      lastzone = psszon
     C                   endif

     *    Only work with CLR/FRZ zones

     C                   if        psszon<>'CLR' and psszon<>'FRZ'
520aMC     keyTrn#       setgt     label33h
     C                   iter
     C                   endif

     *    Only work with tote items

     C     keyod         chain     orddm
     C                   if        not %found
     C                   iter
     C                   endif
     C                   eval      hardm1_base = ommsc1
     C                   if        lbutyp = 'N' and hardm1_toten <> 'Y'
     C                             or lbutyp = '1' and hardm1_tote1 <> 'Y'
     C                             or lbutyp = '2' and hardm1_tote2 <> 'Y'
     C                   iter
     C                   endif

     C                   if        ToteItemFound = *off
     C                   eval      tohlbl = lblbl#
     C                   eval      tohml# = lblbl#
HARcAC                   eval      tohord = lbord
HARcAC                   eval      tohtr# = lbtrn#
HARcAC                   eval      tohmt# = lbtrn#
HARcAC                   eval      tohppi = lbpal#
HARcAC                   eval      tohmpi = lbpal#
     C                   eval      ToteItemFound = *on
     C                   endif

     *    Update totals

     C                   eval      tohcub = tohcub + lbcube
     C                   eval      tohpcs = tohpcs + lbqpck
     C****               eval      tohwgt = tohwgt + lbswgt

     C                   enddo

     *  Create TOTEHDR record for last tran if necessary.

     C                   if        toteItemFound
     C                   exsr      crtTOTEHDR
     C                   eval      ToteItemFound = *off
     C                   endif

     C                   endsr

CWD A*----------------------------------------------------------------
CWD A*  crttotehdrrecs   Create TOTEHDR recs for Cash Wa
CWD A*----------------------------------------------------------------
CWD A
CWD AC     crttotehdrrecsbegsr

     *  Loop through all labels for route in tran# order.

     C                   eval      first = *on
     C                   eval      lasttrn# = *loval
     C                   eval      laststop = *loval
     C                   eval      lastzone = *loval
CWD AC                   eval      lastord  = *loval
CWD MC     keyRtid       setll     label33h

     C                   dow       forever = forever
CWD MC     keyRtid       reade     label33h
     C                   if        %eof
     C                   leave
     C                   endif

     *    Only read O and B label records.

     C                   if        lbtype <> 'O'
     C                             and lbtype <> 'B'
     C                   iter
     C                   endif

     *    First time through, get tote info.

     C                   if        first
     C                   exsr      getToteInfo
     C                   eval      first = *off
     C                   endif

     *    If transaction number changed ...

     C                   if        lasttrn# <> lbtrn#
     C                             or laststop <> lbstop
CWD AC                             or lastord  <> lbord

     *      ... Create TOTEHDR record for last tran if necessary.

     C                   if        toteItemFound
     C                   exsr      crtTOTEHDR
     C                   eval      ToteItemFound = *off
     C                   endif

     *      ... Inizialize TOTEHDR fields.

     C                   exsr      inzTOTEHDRflds

     C                   eval      lasttrn# = lbtrn#
     C                   eval      laststop = lbstop
CWD AC                   eval      lastord  = lbord
     C                   eval      lastzone = psszon
     C                   endif

     *    Only work with CLR/FRZ zones

CWD DC*                  if        psszon<>'CLR' and psszon<>'FRZ'
CWD DC*    keyTrn#       setgt     label33h
CWD DC*                  iter
CWD DC*                  endif

     *    Only work with tote items

     C     keyod         chain     orddm
     C                   if        not %found
     C                   iter
     C                   endif
     C                   eval      hardm1_base = ommsc1
     C                   if        lbutyp = 'N' and hardm1_toten <> 'Y'
     C                             or lbutyp = '1' and hardm1_tote1 <> 'Y'
     C                             or lbutyp = '2' and hardm1_tote2 <> 'Y'
     C                   iter
     C                   endif

     C                   if        ToteItemFound = *off
     C                   eval      tohlbl = lblbl#
     C                   eval      tohml# = lblbl#
CWD AC                   eval      tohord = lbord
CWD AC                   eval      tohtr# = lbtrn#
CWD AC                   eval      tohmt# = lbtrn#
CWD AC                   eval      tohppi = lbpal#
CWD AC                   eval      tohmpi = lbpal#
     C                   eval      ToteItemFound = *on
     C                   endif

     *    Update totals

     C                   eval      tohcub = tohcub + lbcube
     C                   eval      tohpcs = tohpcs + lbqpck

     C                   enddo

CWD A*  Create TOTEHDR record for last tran if necessary.

CWD AC                   if        toteItemFound
CWD AC                   exsr      crtTOTEHDR
CWD AC                   eval      ToteItemFound = *off
CWD AC                   endif

CWD AC                   endsr

HARaA*----------------------------------------------------------------
HARaA*  getToteInfo    Get Tote info
HARaA*----------------------------------------------------------------
HARaA
HARaAC     getToteInfo   begsr

CWD DC*                  eval      kyzone = 'TRMEZZ'
     C                   eval      kycode = '*PICK'
     C     keyopz        chain(e)  optionz
     C                   if        not %found
     C                   eval      toteExtCube = 2
     C                   eval      toteIntCube = 2
     C                   eval      toteMaxOrd  = 99
     C                   eval      toteMaxPcs  = 999
     C                   else
     C                   eval      toteExtCube = optecb
     C                   eval      toteIntCube = opticb
     C                   eval      toteMaxOrd  = optord
     C                   eval      toteMaxPcs  = optpcs
     C                   endif

     C                   endsr

HARaA*----------------------------------------------------------------
HARaA*  inzTOTEHDRflds  Initialize TOTEHDR fields
HARaA*----------------------------------------------------------------
HARaA
HARaAC     inzTOTEHDRfldsbegsr

     C                   eval      tohwhs = lbwhse
     C                   eval      tohrid = lbrte
HARcDC**                 eval      tohppi = lbpal#
HARcMC                   eval      tohppi = 0
HARbAC**520bD            eval      tohnum = clrTote#
520bMC                   eval      tohcnt = clrTote#
HARbDC**                 select
HARbDC**                 when      psszon = 'CLR'
HARbDC**                 eval      clrTote# = clrTote# + 1
HARbDC**                 eval      tohnum = clrTote#
HARbDC**                 when      psszon = 'FRZ'
HARbDC**                 eval      frzTote# = frzTote# + 1
HARbDC**                 eval      tohnum = frzTote#
HARbDC**                 endsl
HARcDC**                 eval      tohord = lbord
HARcMC                   eval      tohord = 0
     C                   eval      tohlay = 0
     C                   eval      tohsec = ' '
     C                   eval      tohecb = toteExtCube
     C                   eval      tohicb = toteIntCube
     C                   eval      tohmxp = toteMaxPcs
     C                   eval      tohcub = 0
     C                   eval      tohpcs = 0
     C                   eval      tohwgt = 0
     C                   eval      tohlbl = 0
HARcDC**                 eval      tohtr# = lbtrn#
HARcMC                   eval      tohtr# = 0
HARcDC**                 eval      tohmpi = lbpal#
HARcMC                   eval      tohmpi = 0
     C                   eval      tohml# = 0
HARcDC**                 eval      tohmt# = lbtrn#
HARcMC                   eval      tohmt# = 0

     C                   endsr

     *----------------------------------------------------------------
     *  crtTOTEHDR   Create TOTEHDR record for CLR/FRZ transaction
     *----------------------------------------------------------------

     C     crtTOTEHDR    begsr
HARbAC                   select
HARbAC                   when      lastzone = 'CLR'
HARbAC                   eval      clrTote# = clrTote# + 1
HARbAC**520bD            eval      tohnum = clrTote#
520bMC                   eval      tohcnt = clrTote#
HARbAC                   when      lastzone = 'FRZ'
HARbAC                   eval      frzTote# = frzTote# + 1
HARbAC**520bD            eval      tohnum = frzTote#
520bMC                   eval      tohcnt = frzTote#
HARbAC                   endsl
     C                   write     tohrec
     C                   endsr

     *----------------------------------------------------------------
     *  updTOTEHDR   Update TOTEHDR records with tran #'s
     *----------------------------------------------------------------

     C     updTOTEHDR    begsr

     *  Loop through TOTEHDR recs for route.

     C     keyRtid       setll     totehdr

     C                   dow       forever = forever
     C     keyRtid       reade     totehdr
     C                   if        %eof
     C                   leave
     C                   endif

     *    Get corresponding physical label record.

730bDC**   tohlbl        chain     label
730bA /free
730bA                    chain (tohwhs: tohlbl) labelw;
730bA /end-free
     C                   if        not %found
     C                   eval      tohtr# = 0
     C                   else
     C                   eval      tohtr# = lbtrn#
     C                   endif

     *    Get corresponding merge label record.

730bDC**   tohml#        chain     label
730bA /free
730bA                    chain (tohwhs: tohml#) labelw;
730bA /end-free
     C                   if        not %found
     C                   eval      tohmt# = 0
     C                   else
     C                   eval      tohmt# = lbtrn#
730aAC                   eval      tohmpi = lbpal#
     C                   endif

     *    Update record

     C                   update    tohrec

     C                   enddo

     C                   endsr
