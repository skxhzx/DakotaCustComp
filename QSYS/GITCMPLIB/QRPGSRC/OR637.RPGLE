510 A /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OR637     Create unique piece numbers within route.
     *  20 June 2007
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    06/20/07  DAS  5.10
     *      - Created
     *
510aA*    06/25/07  DAS  5.10a
     *      - Revised to read through PLTSUM2, then LABEL13.
     *      - Revised to only create 1 number for a bulk pick.
     *      - Revised create numbers based on combo label criteria.
     *      - Added DRI logic for Cheney custom revisions.
     *
510bA*    07/14/07  DAS  5.10b
     *      - Revised to not start number at zero, but to retrieve
     *        it from a data area. Re: Multiple willcalls get put
     *        onto the same truck, which was causing duplicate
     *        Cadec numbers on the truck, which is not allowed.
     *
510cA*    09/13/07  DAS  5.10c
     *      - Added fields ORPCNT, ORPTTL and ORPSCN.
     *
520aA*    02/16/07  DAS  5.20a
     *      - Added Harbor.
     *      - Added getting *PICK information.
     *      - Revised to make the standard to do all 'O' and 'B'
     *        records for all generations.
     *      - Added logic to assign a number to each Tote.
     *
520bA*    10/06/08  RBD  5.20b P#00011
     *      - Fix: Recompile for TOTEHDR changes.
     *
530 A*    10/12/10  RBD  5.30
     *      - Fix: If lbqpck = 0 (in other words, the item is
     *        out), still create an ORDP record in case any
     *        of the item ends up getting picked.
     *
640aA*    03/02/11  DAS  6.40a
     *      - Fix: Revised to check for dup key.
     *      - Revised to create numbers for all clients.
     *
640bA*    11/19/12  RBD  6.40b
     *      - Fix: Added call to GETZONTMPL to retrieve truck template
     *        if one exists.
     *
650aA*    09/06/13  RBD  6.50a
     *      - Added logic for batch picks, will only create 1 number.
     *
CWD A*    04/28/15  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. TOTEHDR file had order id added
     *        to make file key unique.
     *
730aA*    11/03/19  DAS  7.30a
     *      - Revised to use LABELW
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - Cheney
     *
CBIaA*    06/25/07  DAS  CBIa
     *      - Revised to create individual numbers for
     *        catchweight items
     *
CBIbA*    02/23/08  DAS  CBIb
     *      - Changed logic for reading only working with generation
     *        1 to be Cheney specific.
     *      - Changed logic for reading 'M' records to be
     *        Cheney specific.
     *
CBIc *    10/13/14  DAS  CBIc  (was CBIb in Cheney's version)
     *      - Revised to only create 1 number for GWB PK's.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - Harbor
     *
HARaA*    02/20/09  RBD  HARa
     *      - For CLR/FRZ totes, calculate totes needed and write an
     *        ORDP rec for each tote needed.
     *
HARbA*    03/20/09  RBD  HARb
     *      - In additional to opclvl, consider it a combo if unit of
     *        measure = EA and qty is greater than 1.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - Ellenbee Leggett
     *
EBL A*    09/03/09  RBD  EBL
     *      - Added Ellenbee to list of clients using unique piece#.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - Mattingly
     *
MAT A*    09/04/09  RBD  MAT
     *      - Added Mattingly to list of clients using unique piece#.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - City Line
     *
CLD A*    09/04/09  RBD  CLD
     *      - Added City Line to list of clients using unique piece#.
     *
CLDaA*    07/02/10  RBD  CLDa
     *      - If ITTYPE = 'S', only create one unique piece# record.
     *
CLDbA*    11/13/12  RBD  CLDb
     *      - Reverse CLDa, will now use SSBXREF file instead of item
     *        type to identify these special meat items.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - Halsey
     *
BD  A*    10/06/10  JCJ  BD
     *      - Added BFCDEMO to list of clients using unique piece#.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Cash Wa
     *
CWD A*    05/31/16  MLB  CWD  P#01349
     *      - Revised pgm create only a single record in the ORDP file.
     *        File TOTEHDR now has a rcd for each order in the tote.
     *        The rcd that will be written to ORDP will have the order
     *        id from the merge label rcd.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Kelly Foods
     *
KFSaA*    08/30/18  JCJ  KFSa
     *      - Ignore batch pick logic.  Client want individual Unique .
     *        Piece numbers for each label.
     *
     *----------------------------------------------------------------
     *   Client Custom Revisions - Southwest Traders
     *
SWTa *     07/19/19  LMC  SWTa
     *       - User SSBXREF to determine combo.
     *
     *----------------------------------------------------------------
     *   Client Custom Revisions - Big Apple Deli
     *
BADa *    10/01/19  GJA  BADa
     *      - User SSBXREF to determine combo.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpltsum3   if   e           k disk
730aDF*abel     if   e           k disk    usropn
730aMFlabelw    if   e           k disk    usropn
     Flabel13   if   e           k disk
CWD AF                                     rename(lbrec : lbrec13)
     Foptionz   if   e           k disk
520aAFtotehdr   if   e           k disk
CLDbAFssbxref   if   e           k disk
     Fordp      o    e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#cheney
CBIb  /copy qcopysrc,id#cheneyg
520aA /copy qcopysrc,id#harbor
EBL A /copy qcopysrc,id#ellenbe
MAT A /copy qcopysrc,id#matt
CLD A /copy qcopysrc,id#citylin
BD  A /copy qcopysrc,id#bfcdemo
CWD A /copy qcopysrc,id#cashwa
KFSaA /copy qcopysrc,id#kfs
SWT A /copy qcopysrc,id#swt
BADaA /copy qcopysrc,id#bad
     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item
     D savever#        s                   like($itver#)
     D save$item       s                   like($item)
     D save$item2      s                   like($item2)

650aA*----------------------------------------------------------------
650aA*  OPTIONZ data structure
650aA*----------------------------------------------------------------
650aAD opzdta          ds
650aAD  opzend               117    117

     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *----------------------------------------------------------------
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
650aDD*opzdta          ds
650aMD opzdt1          ds
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

650aA*----------------------------------------------------------------
650aA*  *PICK  -  Picking options
650aA*
650aA*----------------------------------------------------------------
650aA*
650aA* Fields
650aA*
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
     *    OPPBRK  -  Aisle to start new pallet.
     *    OPPBLD  -  Pallet building method.
     *                1 = By stop then slot location.
     *                2 = By slot location then stop.
     *                3 = By descening stop, then slot location.
     *    OPSELM  -  Selection method.
     *                1 = Single pass (By location).
     *                2 = Multiple pass (By stop).
     *    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
     *    OPNWPL  -  Start new pallet when aisle changes if build method
     *               is 2=Location.
     *    OPFORD  -  Maximun orders per pallet.
     *    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
     *    OPFTOT  -  Maximum totes per pallet.
     *    OPTECB  -  External tote cube.
     *    OPTICB  -  Internal tote cube.
     *    OPTSTP  -  Maximum stops per tote.
     *    OPTPCS  -  Maximum pieces per tote.
     *    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
     *    OPGCDE  -  USF Group Code (0-9).
     *    OPPKUP  -  Picked up by (S=Selector, L=Loader).
     *    OPSPAL  -  Merge pallet should only contain
     *               items for single truck pallet (Y=Yes, N=No).
     *    OPPITM  -  Maximum items per pallet.
     *
     * Data structure
     *
     D opzdt2          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  oppbld                34     34
     D  opselm                35     35
     D  opsplt                36     36
     D  opbmrg                37     37
     D  opnwpl                38     38
     D  opford                39     40  0 inz(0)
     D  opptyp                41     41
     D  opftot                42     43  0 inz(0)
     D  optecb                44     48  2 inz(0)
     D  opticb                49     53  2 inz(0)
     D  optstp                54     55  0 inz(0)
     D  optord                56     57  0 inz(0)
     D  optpcs                58     60  0 inz(0)
     D  opstop                61     61
     ** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
     D**opgcde                62     62
     D  oppkup                62     62
     D  opspal                63     63
     D  oppitm                64     67  0 inz(0)
     D  opend1               117    117

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
     D forever         s               n
     D i               s                   like(lbqpck)
HARaAD int1            s              5  0
HARaAD int2            s              5  0
     D kycode          s                   like(opzcod)
     D lastzone        s                   like(psszon)
     D qty2Create      s                   like(lbqpck)
HARaAD totesNeeded     s              3  0

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

530aA*  Now creating numbers for all clients.
640aD ** If client doesn't use unique piece seq#, then get out.
640aD **
640aDC**                 if        client <> cheney
640aDC**                           and client <> harbor
640aDC**                           and client <> ellenbee
640aDC**                           and client <> mattfd
640aDC**                           and client <> cityline
640aDC**                           and client <> bfcdemo
640aDC**                 goto      bottom
640aDC**                 endif

510bD** Start piece seq# at zero for the route.
510bD **
510bDC**                 eval      orpup# = 0

     *  Loop through all pallets for route.

     C                   eval      lastzone = ' '
     C     keyps3        SETLL     pltsum3
     C*
     C                   dow       forever = forever
     C     keyps3        reade     pltsum3
     C                   if        %eof
     C                   leave
     C                   endif

     *    Only create numbers for gen 1 pallets.
CBIbA*      - Only for Cheney.

     C                   if        psgen <> 1
CBIbAC                             and client = cheney
     C                   iter
     C                   endif

     *    Get zone options

     C                   if        lastzone <> psszon
     C                   exsr      getZoneOpts
     C                   eval      lastzone = psszon
     C                   endif

     *      Loop through all labels for pallet.

     C     keyl13        SETLL     label13

     C                   dow       forever = forever
     C     keyl13        reade     label13
     C                   if        %eof
     C                   leave
     C                   endif

520aA*    Skip 'M' records.
CBIbA*      - unless Cheney.
520aA
520aAC                   if        lbtype = 'M'
CBIbAC                             and client <> cheney
520aAC                   iter
520aAC                   endif

     *        Initialize piece record fields.

     C                   eval      orpwhs = lbwhse
     C                   eval      orprid = lbrte
     C                   eval      orpord = lbord
     C                   eval      orpsq# = lbseq
     C                   eval      orpitm = lbitem
     C                   eval      orplbl = lblbl#
     C                   eval      orpseq = 0
     C                   eval      orpwgt = 0

     *        Determine how many numbers need to be created.

     C                   exsr      getQty2Create

     *        Create piece records.

510cAC                   eval      orpcnt = 0
510cAC                   eval      orpttl = qty2Create
510cAC                   if        qty2Create = 1
510cAC                   eval      orpscn = lbqpck
510cAC                   else
510cAC                   eval      orpscn = 1
510cAC                   endif

     C     1             do        qty2Create    i
510aDC**                 eval      orpup# = orpup# + 1
640aDC**                 call      'PIRCADEC#'
640aDC**                 parm                    orpup#
510cAC                   eval      orpcnt = orpcnt + 1

640aAC                   dow       forever = forever
640aAC                   call      'PIRCADEC#'
640aAC                   parm                    orpup#
     C                   write(e)  orprec
640aAC                   if        %error
640aAC                   iter
640aAC                   endif
640aAC                   leave
640aAC                   enddo

     C                   enddo


     C                   enddo

     C                   enddo
520aA
520aA*  Assign number to each tote.
520aA
CWD AC                   if        client = Cashwa
CWD AC                   exsr      assignToteCwd
CWD AC                   else
CWD A*
520aAC                   exsr      assignToteNum
     C                   endif

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

     *  Define key for PLTSUM3 file.

     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     *  Define key for LABEL13 file.

     C     keyl13        klist
     C                   kfld                    pswhse
     C                   kfld                    psrtid
     C                   kfld                    psplid

     *  Define key for OPTIONZ file.

     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    pswhse
640bDC**                 kfld                    pstruk
640bMC                   kfld                    $ptmpl
     C                   kfld                    psszon

CLDbA*  Define key for SSBXREF file.
CLDbA
CLDbAC     keyssb        klist
CLDbAC                   kfld                    $pwhse
CLDbAC                   kfld                    $ititem

     *  Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client
     C                   parm                    clientloc
CWD A*
CWD AC                   if        client = Cashwa
CWD A*
730aMC                   if        not %open(labelw)
730aMC                   open      labelw
CWD AC                   endif
CWD A*
CWD AC                   endif
CWD A*
     C                   endsr

520aA*----------------------------------------------------------------
520aA*  assignToteNum   Assign number to totes
520aA*----------------------------------------------------------------
520aA
520aAC     assignToteNum begsr

     *  Loop through TOTEHDR recs for route.

     C     keyps3        setll     totehdr

     C                   dow       forever = forever
     C     keyps3        reade     totehdr
     C                   if        %eof
     C                   leave
     C                   endif

HARaA*    If Harbor CLR/FRZ tote, calculate actual number of totes needed
HARaA*    and write that many ORDP records, otherwise, write 1.

HARaAC                   if        client = Harbor
HARaAC                             and tohtr# = tohmt#
HARaAC                   eval      int1 = tohcub * 100
HARaAC                   eval      int2 = tohicb * 100
HARaAC                   eval      totesNeeded = %div(int1:int2)
HARaAC                   if        %rem(int1:int2) > 0
HARaAC                   eval      totesNeeded = totesNeeded + 1
HARaAC                   endif
HARaAC                   else
HARaAC                   eval      totesNeeded = 1
HARaAC                   endif

HARaAC     1             do        totesNeeded

     *    Create piece record

     C                   eval      orpwhs = tohwhs
     C                   eval      orprid = tohrid
     C                   eval      orpord = tohord
     C                   eval      orpsq# = 0
     C                   eval      orpitm = 'TOTE'
     C                   eval      orplbl = TOHML#
     C                   eval      orpseq = 0
     C                   eval      orpwgt = 0
     C                   eval      orpcnt = 1
     C                   eval      orpttl = 1
     C                   eval      orpscn = 1

     C                   call      'PIRCADEC#'
     C                   parm                    orpup#
     C                   write(e)  orprec

HARaAC                   enddo
     C                   enddo

     C                   endsr

CWD A*----------------------------------------------------------------
CWD A*  assignToteCwd   Assign number to totes - Cash Wa
CWD A*----------------------------------------------------------------
CWD A
CWD AC     assignToteCwd begsr
CWD A
CWD A*  Loop through TOTEHDR recs for route.
CWD A
CWD AC     keyps3        setll     totehdr
CWD A
CWD AC                   dow       forever = forever
CWD AC     keyps3        reade     totehdr
CWD AC                   if        %eof(totehdr)
CWD AC                   leave
CWD AC                   endif
CWD A*
CWD A*      Create ORDP record with Merge label order id.
CWD A*      Necessary due to fact that rcd for each order id
CWD A*      in tote is created in pgm, OR620.
730aDC*    tohml#        chain     label
730aA /free
730aA                    chain (tohwhs: tohml#) labelw;
730aA /end-free
CWD AC                   if        tohord <> lbord
CWD AC                   iter
CWD AC                   endif
CWD A*
CWD AC                   eval      totesNeeded = 1
CWD A
CWD AC     1             do        totesNeeded
CWD A
CWD A*    Create piece record
CWD A
CWD AC                   eval      orpwhs = tohwhs
CWD AC                   eval      orprid = tohrid
CWD AC                   eval      orpord = tohord
CWD AC                   eval      orpsq# = 0
CWD AC                   eval      orpitm = 'TOTE'
CWD AC                   eval      orplbl = TOHML#
CWD AC                   eval      orpseq = 0
CWD AC                   eval      orpwgt = 0
CWD AC                   eval      orpcnt = 1
CWD AC                   eval      orpttl = 1
CWD AC                   eval      orpscn = 1
CWD A
CWD AC                   call      'PIRCADEC#'
CWD AC                   parm                    orpup#
CWD AC                   write(e)  orprec
CWD A
CWD AC                   enddo
CWD AC                   enddo
CWD A
CWD AC                   endsr

     *----------------------------------------------------------------
     *  getItem    Get item information
     *----------------------------------------------------------------

     C     getItem       begsr

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#

     C                   eval      $itwhse   = lbwhse
     C                   eval      $ititem   = lbitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   eval      $itcwgt = 'N'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getQty2Create   Get quantity of numbers to create.
     *----------------------------------------------------------------

     C     getQty2Create begsr

     *    Get item information.

     C                   if        client = cheney
CLDaAC                             or client = cityline
SWTaAC                             or client = swt
BADaAC                             or client = BigApple
     C                   exsr      getItem
     C                   endif

     C                   select

     *   For bulk picks only create 1 number.

     C                   when      lbtype = 'B'
     C                   eval      qty2Create = 1

CBIbA*   For Cheney GWB PK's, only create 1 number.
CBIbA
CBIbAC                   when      client = cheney
CBIbAC                             and clientloc = Cheneygwb
CBIbAC                             and lbutyp <> 'N'
CBIbAC                   eval      qty2Create = 1

     *   For Cheney catchweights create 1 for each piece.

     C                   when      client = cheney
     C                             and $itcwgt = 'Y'
     C                   eval      qty2Create = lbqpck

     *   For a combo label only create 1 number.

     C                   when      lbqpck >= opclvl
     C                   eval      qty2Create = 1

HARbA*   For Harbor, consider it a combo if u/m EA and qty > 1.

HARbAC                   when      client = harbor
HARbAC                             and lbucod = 'EA'
HARbAC                             and lbqpck > 1
HARbAC                   eval      qty2Create = 1

CLDbD*** For City Line, if ITTYPE = 'S', only create 1 unique piece#.
CLDbM*   For City Line, if item in SSBXREF, only create 1 unique piece#.

CLDaAC                   when      client = cityline
SWTaAC                             or client = swt
BADaAC                             or client = BigApple
CLDbDC**                           and $ittype = 'S'
CLDbAC     keyssb        chain     ssbxref
CLDbAC                   if        %found(ssbxref)
CLDaAC                   eval      qty2Create = 1
CLDbAC                   else
CLDbAC                   eval      qty2Create = lbqpck
CLDbAC                   endif

650aA*   For batch picks only create 1 number.
650aA
650aAC                   when      opptyp = 'B'
KFSaAC                             and client <> kellys
650aAC                   eval      qty2Create = 1
650aA
     *   Otherwise create 1 for each piece.

     C                   other
     C                   eval      qty2Create = lbqpck

     C                   endsl

530 A*        If item is out, still create 1 ORDP record.
530 AC                   if        qty2Create = 0
530 AC                   eval      qty2Create = 1
530 AC                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getZoneOpts   Get zone options
     *----------------------------------------------------------------

     C     getZoneOpts   begsr

640bAC                   call      'GETZONTMPL'
640bAC                   parm                    $pwhse
640bAC                   parm                    pstruk
640bAC                   parm                    $ptmpl           10

     C                   eval      kycode = '*PICKLBL'
     C     keyopz        chain(e)  optionz
     C                   if        not %found
650aAC                   clear                   opzdt1
     C                   eval      opclvl = *hival
650aAC                   else
650aAC                   eval      opzdt1 = opzdta
     C                   endif

650aAC                   eval      kycode = '*PICK   '
650aAC     keyopz        chain(e)  optionz
650aAC                   if        not %found
650aAC                   clear                   opzdt2
650aAC                   else
650aAC                   eval      opzdt2 = opzdta
650aAC                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata
     C     $item2        parm      $item2        $dridata2

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   endsl

     C     enddricop     endsr
