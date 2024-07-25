      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OR639     Create unique sscc-18 ASN detail records.
     *            Cloned from pgm OR637.
     *  24 January 2008
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    01/24/08  RBD  5.20  P#00003
     *      - Created.
     *
520aA*    02/10/08  DAS  5.20  P#00011
     *      - Changed to just use LABEL33.
     *        Re: Join file that contain the information needed.
     *      - Revised to use OHMISC flag to determine ASN order.
     *      - Revised to ignore all 'M' records.
     *        Re: Totes will be handled using file TOTEHDR.
     *      - Added new file TOTEHDR.
     *      - Revised to assign 1 SSCC-18 number to each TOTEHDR
     *        record for the route.
     *      - Removed all old logic for clarity.
     *
520bA*    10/06/08  RBD  5.20b P#00011
     *      - Fix: Recompile for TOTEHDR changes.
     *
CWD A*    04/28/15  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. TOTEHDR file had order id added
     *        to make file key unique.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - Harbor
     *
HARaA*    02/10/08  DAS  HARa  P#00011
     *      - Added ORDDM file.
     *      - Revised to not assign SSCC-18 number to Tote items
     *        in the CLR/FRZ zones.
     *
HARbA*    07/25/08  RBD  HARb  P#00011
     *      - Even when it's a combo label situation, assign an
     *        SSCC-18 number for each qty picked.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Flabel33   if   e           k disk
     Foptionz   if   e           k disk
520aAFtotehdr   if   e           k disk
520aAFordh      if   e           k disk
HARaAForddm     if   e           k disk
     Fordad     o    e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#harbor
     D client          s             10
     D clientloc       s             10

HARaA*----------------------------------------------------------------
HARaA*  Order Misc field data structures
HARaA*----------------------------------------------------------------
HARaA
HARaA /copy qcopysrc,ohmisc_har

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
     D opzdtaPICK      ds
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
     *  *PICKLBL  -  Picking label options
     *
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
     *    OPPDEV  -  Printer device.
     *    OPPFRM  -  Printer form.
     *
     * Data structure
     *
     D opzdtaPICKLBL   ds
     D  opclvl                 1      3  0
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0
     D  opcwgt                53     54  0
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  optend               117    117

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

     D asnOrder        s               n
     D error           s               n
     D forever         s               n
     D J               s                   like(lbqpck)
     D kycode          s                   like(opzcod)
     D lasttrn#        s                   like(lbtrn#)
     D qty2Create      s                   like(lbqpck)

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

     *  If client doesn't use ASN labels, then get out.

     C                   if        client <> harbor
     C                   goto      bottom
     C                   endif

     *  Create SSCC-18 recs for 'O' and 'B' records.

     C                   exsr      crtItemSSCC18

     *  Create SSCC-18 recs for totes.

     C                   exsr      crtToteSSCC18

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
520aA
520aA*  Define route key for LABEL33 file.
520aA
520aAC     keyRtid       klist
520aAC                   kfld                    $pwhse
520aAC                   kfld                    $prtid
520aA
520aA*  Define tran# key for LABEL33 file.
520aA
520aAC     keyTrn#       klist
520aAC                   kfld                    lbwhse
520aAC                   kfld                    lbrte
520aAC                   kfld                    lbtrn#
520aA
520aA*   Define full key for ORDH file
520aA
520aAC     keyoh         klist
520aAC                   kfld                    tohwhs
520aAC                   kfld                    tohord
HARaA
HARaA*   Define full key for ORDDM file
HARaA
HARaAC     keyod         klist
HARaAC                   kfld                    lbwhse
HARaAC                   kfld                    lbord
HARaAC                   kfld                    lbseq
HARaAC                   kfld                    lbitem

     *  Define key for OPTIONZ file.

     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    lbwhse
     C                   kfld                    pstruk
     C                   kfld                    psszon

     *  Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client
     C                   parm                    clientloc

     C                   endsr

     *----------------------------------------------------------------
     *  crtItemSSCC18   Create item SSCC-18 numbers
     *----------------------------------------------------------------

     C     crtItemSSCC18 begsr

     *  Loop through all labels for route in tran# order.

     C                   eval      lasttrn# = *loval
     C     keyRtid       setll     label33

     C                   dow       forever = forever
     C     keyRtid       reade     label33
     C                   if        %eof
     C                   leave
     C                   endif

     *    Only assign SSCC-18 number to O and B label records.

     C                   if        lbtype <> 'O'
     C                             and lbtype <> 'B'
     C                   iter
     C                   endif

     *    Only assign SSCC-18 number to items on ASN orders.

     C                   eval      asnOrder = *off

     C                   select

HARaAC                   when      client = harbor
HARaAC                   eval      harmsc_base = ohmisc
HARaAC                   if        harmsc_asn = 'Y'
HARaAC                   eval      asnOrder = *on
HARaAC                   endif

     C                   endsl

     C                   if        not asnOrder
     C                   iter
     C                   endif

     *    If transaction number changed ...
     *      Get zone options

     C                   if        lasttrn# <> lbtrn#
     C                   exsr      getZoneOpts
     C                   eval      lasttrn# = lbtrn#
     C                   endif

     *    Do not assign SSCC-18 number to Tote zone label recs.

     C                   if        opptyp = 'T'
     C     keyTrn#       setgt     label33
     C                   iter
     C                   endif
HARaA
HARaA*    For Harbor CLR and FRZ zones, ignore tote items.
HARaA
HARaAC                   if        client = Harbor
HARaAC                   if        psszon='CLR' or psszon='FRZ'
HARaAC     keyod         chain     orddm
HARaAC                   if        not %found
HARaAC                   iter
HARaAC                   endif
     C                   eval      hardm1_base = ommsc1
HARaAC                   if        lbutyp = 'N' and hardm1_toten = 'Y'
HARaAC                             or lbutyp = '1' and hardm1_tote1 = 'Y'
HARaAC                             or lbutyp = '2' and hardm1_tote2 = 'Y'
HARaAC                   iter
HARaAC                   endif
HARaAC                   endif
HARaAC                   endif

     *    Initialize piece record fields.

     C                   eval      ordwhs = lbwhse
     C                   eval      ordord = lbord
     C                   eval      ordsq# = lbseq
     C                   eval      orditm = lbitem
     C                   eval      ordlbl = lblbl#
     C                   eval      ordlty = lbtype
     C                   eval      ordpal = lbpal#
     C                   eval      ordtrn = lbtrn#
     C                   eval      ordumt = lbutyp

     *    Determine how many numbers need to be created.

     C                   exsr      getQty2Create

     *    Create piece records.

     C                   eval      ordcnt = 0
     C                   eval      ordttl = qty2Create
     C                   if        qty2Create = 1
     C                   eval      ordscn = lbqpck
     C                   else
     C                   eval      ordscn = 1
     C                   endif

     C     1             do        qty2Create    J

     *       Get next available unique ordup#

     C                   call      'PIRSSCC#'
     C                   parm                    $nxt#             9 0

     C                   eval      ordup# = $nxt#
     C                   eval      ordcnt = ordcnt + 1
     C                   write(e)  ordrec
     C                   enddo

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  crtToteSSCC18   Create tote SSCC-18 numbers
     *----------------------------------------------------------------

     C     crtToteSSCC18 begsr

     *  Loop through TOTEHDR recs for route.

     C     keyRtid       setll     totehdr

     C                   dow       forever = forever
     C     keyRtid       reade     totehdr
     C                   if        %eof
     C                   leave
     C                   endif

     *    Get corresponding order header record.

     C     keyoh         chain     ordh
     C                   if        not %found
     C                   iter
     C                   endif

     *    Only assign SSCC-18 number to totes for ASN orders.

     C                   eval      asnOrder = *off

     C                   select

HARaAC                   when      client = harbor
HARaAC                   eval      harmsc_base = ohmisc
HARaAC                   if        harmsc_asn = 'Y'
HARaAC                   eval      asnOrder = *on
HARaAC                   endif

     C                   endsl

     C                   if        not asnOrder
     C                   iter
     C                   endif

     *    Initialize piece record fields.

     C                   eval      ordwhs = tohwhs
     C                   eval      ordord = tohord
     C                   eval      ordsq# = 0
     C                   eval      orditm = ' '
     C                   eval      ordlbl = tohlbl
     C                   eval      ordlty = 'T'
     C                   eval      ordpal = tohppi
     C                   eval      ordtrn = tohtr#
     C                   eval      ordumt = ' '

     *    Create piece records.

     C                   call      'PIRSSCC#'
     C                   parm                    $nxt#

     C                   eval      ordup# = $nxt#
     C                   eval      ordcnt = 1
     C                   eval      ordttl = 1
     C                   eval      ordscn = 1
     C                   write(e)  ordrec

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  getQty2Create   Get quantity of numbers to create.
     *----------------------------------------------------------------

     C     getQty2Create begsr

     C                   select

     *   For bulk picks and totes, only create 1 number.

     C                   when         lbtype = 'B'
     C                   eval      qty2Create = 1

     *   For normal order picks :
     *     If it's a combo label only create 1 number,
     *     otherwise create 1 for each piece.

HARbA*     If Harbor, create 1 number for each piece irrespective
HARbA*     of combo level.

     C                   when      lbtype = 'O'
     C                   if        lbqpck >= opclvl
HARbAC                             and client <> Harbor
     C                   eval      qty2Create = 1
     C                   else
     C                   eval      qty2Create = lbqpck
     C                   endif

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  getZoneOpts   Get zone options
     *----------------------------------------------------------------

     C     getZoneOpts   begsr

     C                   eval      kycode = '*PICK'
     C     keyopz        chain(e)  optionz
     C                   if        not %found
     C                   eval      opptyp = 'P'
     C                   else
     C                   eval      opzdtaPICK = opzdta
     C                   endif

     C                   eval      kycode = '*PICKLBL'
     C     keyopz        chain(e)  optionz
     C                   if        not %found
     C                   eval      opclvl = *hival
     C                   else
     C                   eval      opzdtaPICKLBL = opzdta
     C                   endif

     C                   endsr
