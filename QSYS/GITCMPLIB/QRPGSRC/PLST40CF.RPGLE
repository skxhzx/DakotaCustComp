      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PLST40CF  Truck build picking list - Colony Foods
     *  29 November 2018
     *  Retha Davis
     *
     *  Revisions
     *
     *    12/02/97  DAS  4.07
     *      - Created
     *      - Includes changes made to PLBL43 through 4.06
     *
409 A*    03/19/98  DAS  4.09
     *      - Revised to print potential replenishments.
409 A*    03/23/98  RH   4.09
     *      - Revised to use LABEL34 file to print by stop/location
     *      - BFC DOES NOT RECOMMEND USING LABEL34 CHANGE.
     *      - NOT THE NORMAL PROCESS
409 A*    04/06/98  RH   4.09
     *      - Skip replenishment label if status is closed.
410 A*    12/01/98  RH   4.10
     *      - Print 'OUT' on exception label.
     *
412 A*    09/06/99  DAS 4.12
     *      - Created for West Side
     *
412aA*    09/08/99  DAS 4.12a
     *      - Changed format. Removed Cust name & Number. Rearranged
     *        columns.
     *
412bA*    09/15/99  DAS 4.12b
     *      - Added code to print 'OUT' for exception labels.
     *
412cA*    09/21/99  DAS 4.12c
     *      - Revised PRTBLK to print catchweight lines.
     *
413 A*    10/07/99  DAS 4.13
     *      - Revised PRTBLK to ignore extra PLTSUM3 and PLTSTP3 recs.
     *        Note: PLTSUM3 can have multiple bulk picks on a single
     *        pallet which then causes PLTSTP3 to create duplicate
     *        join records for a single label record because the files
     *        are only joined by pallet id.
     *
413aA*    03/09/00  DAS 4.13a
     *      - Revised PRTSEL to move LBASL2 into output field instead
     *        of doing check for 'OUT'.
     *
415 A*    02/28/01  HNK 4.15
     *      - Count lines to control overflow on pick and catch weight
415aA*    03/20/01  HNK 4.15a
     *      - Print overflow if count GE 27.
520 A*    03/30/09  JCJ 5.20
     *      - Converted to RPG4.
     *      - Set *in90 at beginning of SETBEG to fix overflow problem
     *
520bA*    03/30/09  JCJ 5.20b
     *      - Add three digit stop processing.
530 A*    12/17/09  JCJ 530
     *      - Removed Deleted Commented out code for readability.
     *      - Add *PICKLBB chain for OPTIONZ file.
530aA*    01/25/10  RH  530a
     *      - Enh: Add Order Seq # (Halsey) re-compile only.
530bA*    07/28/10  JCJ 530b
     *      - Revised to use TRUCKH to lookup Template code for
     *        printing.
640aA*    06/07/11  JCJ 640a
     *      - Fix: fixed stop count in SETHD heading.
640bA*    06/08/11  JCJ 640b
     *      - Enh: Squeezed pack description on bulk and pick labels.
640cA*    08/25/11  JCJ 640c
     *      - Enh: added zone description to tote heading.
     *      - Fix: default stop if not found in RTESTP file.
640dA*    09/16/11  JCJ 640d
     *      - Enh: Revised program to add support for Client id
640eA*    04/30/12  JCJ 640e
     *      - Enh: Added call to DH900 for dock door.
640fA*    05/01/12  MLB 640f
     *      - Fix: Revised program to omit PLTSUM3 records if trans-
     *        action = 0 and bulk pick count <> 0. This happens when
     *        bulk picks are the only items going onto a truck pallet.
710aA*    11/15/17  JCJ  7.10a
     *      - Enh: Added new stop/drop field.
     *
720aA*    11/29/18  RBD  7.20a
     *      - Created using PLST40WS as the base, kept all mod marks.
     *      - Changed to use new prtf PLST40PCF.
     *      - Removed PACK and OUT columns from BEGBLK, BULK, PICK
     *        and SETHED2.
     *      - Bold print slot and quantity on BEGBLK, BULK, PICK
     *        and SETHED2.
     *      - Rearranged PICK and SETHED2 columns.
     *      - Added dock door to SETHD.
     *      - Changed sort by changing LABEL32 to LABEL32X.
     *
720bA*    12/27/18  RBD  7.20b
     *      - Changed mdydat8 from current day to ship date from ohmisc.
     *      - Changed number of underlines on weight line from 10 to 8
     *        to fit the width of the form.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Cash-Wa
     *
CWDaA*    08/30/12  RTR  CWDa
     *      - Added PICKCWD with slot qty
CWDbA*    04/24/13  JCJ  CWDb
     *      - Added customer number from OHCZIP to customer name
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CTWa *    10/10/08  HNK CTWa
     *      - Change length of QCMD to 100 and add HOLD parm to Override
     *        print file to put the picklist on hold for regular route
     *        but not for WILLCALLS.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Turning Point
     *
TPSaA*    09/16/11  JCJ  TPSa
     *      - Added printing of ITEMNOTE.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier
     *
GFCaA*    04/30/12  JCJ  GFCa
     *      - added dock door to headings.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hearn Kirkwood
     *
HKWa *    12/20/13  JCJ  HKWa
     *      - ENH: Added GETORDHM to get customer code to print on
     *        pick list.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Westside
     *
WSFa *    09/17/08  HNK WSFa
     *      - Change file LABEL32 to LABEL32W and recompile.
     *
WSFb *    10/07/12  GJA WSFb
     *      - Enh:  Changed back to item description instead of zone
     *              description
WSFc *    03/08/14  GJA WSFc
     *      - Enh:  Add slot display if zone pickup is *BULK*
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program prints on green bar paper instead of labels but
     *    uses the same basic logic as the labels. The biggest
     *    difference is that the layout is not defined in a table. The
     *    printer file defines all of the fields and record formats.
     *
     *    To print all of the labels exactly as they are in the tables,
     *    call this program like this:
     *
     *                      CALL PLBL40 *TEST1
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *  90        Overflow indicator for exception report
     *  91        Overflow indicator for catch weight report
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpltsum3   if   e           k disk
     Fpltstp1   if   e           k disk
409 AFLabel3    if   e           k disk
     FLabel31   if   e           k disk
720aDF*Label32   if   e           k disk
720aMFLabel32x  if   e           k disk
WSFaMFLabel32w  if   e           k disk
     FLabel33   if   e           k disk
720bAFLabel94   if   e           k disk    prefix(l94_)
213 AFpiritem   if   e           k disk
213 AFitemlnk   if   e           k disk
405 AFoptions   if   e           k disk
530 AFoptionz   if   e           k disk
530bAFtruckh    if   e           k disk
640cAFzoneh     if   e           k disk
TPSaAForddm     if   e           k disk
HKWaAFordhm     if   e           k disk
720bAFordh      if   e           k disk
720aDF*plst40pw  o    e             printer oflind(*in90)
720aMFplst40pcf o    e             printer oflind(*in90)
     F                                     usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *    General
     *
     D cw              s              1    dim(120)
     D a12             s              1    dim(12)
     D a40             s              1    dim(40)
     D a50             s              1    dim(50)
     D a58             s              1    dim(58)
     D a80             s              1    dim(80)
     *
     *    Printer override
     *
     D ovrprt          s             80    dim(2) ctdata perrcd(1)
640dA*----------------------------------------------------------------
640dA*  Dakota Client IDs
640dA*
TPSaA /copy qcopysrc,id#tps
520aA /copy qcopysrc,id#citywho
GFCaA /copy qcopysrc,id#glazier
WSFaA /copy qcopysrc,id#westsid
520aA /copy qcopysrc,id#cashwa
HKWaA /copy qcopysrc,id#hkw
640dA*----------------------------------------------------------------
640dA*  Customer id
640dA*
640dAD                 ds
640dAD  client                 1     10
640dAD  cliloc                11     20
640dAD @getcl          c                   const('GETCLIENT')

CWDaA*----------------------------------------------------------------
CWDaA*  Misc field mappings
CWDaA*----------------------------------------------------------------
CWDaA /Copy qcopysrc,orddm1_cwd

405 A*----------------------------------------------------------------
405 A*  *SYSTEM  -  System options.
405 A*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opten2               117    117
     *----------------------------------------------------------------
     *  Data structure for label variables.
     *
     D dslbl           ds                  occurs(18)
     D  @var                   1    120
     D  @beg                 121    240
     D  @end                 241    360
     D  @len                 361    480
     *----------------------------------------------------------------
720bA*  Ship date
720bA*
     *
720bAD                 ds
720bAD  dsmisc                 1     20
720bAD  dsmm                   1      2
720bAD  dsdd                   3      4
720bAD  dsyy                   5      6
     *
720bAD                 ds
720bAD  mdydat8                1      8
720bAD  mm                     1      2
720bAD  slash1                 3      3    inz('/')
720bAD  dd                     4      5
720bAD  slash2                 6      6    inz('/')
720bAD  yy                     7      8
     *
     *----------------------------------------------------------------
     *  Stop summary data structure for one set of labels.
     *  Maximum of 9 stops on one pallet, for fixed section items.
213 M*  Maximum of 99 stops on one pallet, for PIR section items.
     *
213 MD stpsum          ds                  occurs(99)
     D  dssstp                 1      2  0
     D  dsscub                 3      8  3
     D  dsswgt                 9     15  2
     D  dsspcs                16     18  0
     D  dsscnm                19     58
     *----------------------------------------------------------------
     *  Pallet summary data structure for one set of labels.
     *
     D palsum          ds                  occurs(9)
     D  dsppal                 1      7  0
     D  dspstp                 8      9  0
     D  dspcub                10     15  3
     D  dspwgt                16     22  2
     D  dsppcs                23     25  0
     D  stp                   26     43  0
     D                                     DIM(9)
404 AD  dsppli                44     50  0
     *----------------------------------------------------------------
     *  PIR stop summary data structure for route.
     *
213 MD pirsum          ds                  occurs(99)
     D  dsrstp                 1      2  0
     D  dsrcub                 3      8  3
     D  dsrwgt                 9     15  2
     D  dsrpcs                16     18  0
     D  dsrwdp                19     23
     D  dsrcnm                24     63
     D  dsrflg                64     64
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
530 D ***opzdta          ds
530 MD opdta2          ds
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
530 A*  *PICKLBB -  Label printing options for the pick list and
530 A*               ASN labels and pick list report.
530 A*
530 A*     08/12/09  RBD  5.20  P#00219
530 A*       - Added record type *PICKLBB which holds printing info
530 A*         for the pick list and ASN labels and pick list report.
530 A*
530 A*----------------------------------------------------------------
530 A* Fields
530 A*
530 A*    OPLB4   -  Print pick list label Y/N.       - Pick list label
530 A*    OPCU4   -  Use cutter option Y/N.           - Pick list label
530 A*    OPLP4   -  Label printing program.          - Pick list label
530 A*    OPDV4   -  Printer device.                  - Pick list label
530 A*    OPFM4   -  Form.                            - Pick list label
530 A*
530 A*    OPLB5   -  Print ASN label Y/N.             - ASN label
530 A*    OPCU5   -  Use cutter option Y/N.           - ASN label
530 A*    OPLP5   -  Label printing program.          - ASN label
530 A*    OPDV5   -  Printer device.                  - ASN label
530 A*    OPFM5   -  Form.                            - ASN label
530 A*
530 A*    OPLB6   -  Print pick list report Y/N.      - Pick list report
530 A*    OPCU6   -  Use cutter option Y/N.           - Pick list report
530 A*    OPLP6   -  Label printing program.          - Pick list report
530 A*    OPDV6   -  Printer device.                  - Pick list report
530 A*    OPFM6   -  Form.                            - Pick list report
530 A*
530 A*    OPLB7   -  Print PICK labels for ZONPKUP 1/2- Pick labels
530 A*
530 A* Data structure
530 A*
530 AD opdta4          ds
530 AD  oplb4                  1      1
530 AD  opcu4                  2      2
530 AD  oplp4                  3     12
530 AD  opdv4                 13     22
530 AD  opfm4                 23     32
530 AD  oplb5                 33     33
530 AD  opcu5                 34     34
530 AD  oplp5                 35     44
530 AD  opdv5                 45     54
530 AD  opfm5                 55     64
530 AD  oplb6                 65     65
530 AD  opcu6                 66     66
530 AD  oplp6                 67     76
530 AD  opdv6                 77     86
530 AD  opfm6                 87     96
530 AD  oplb7                 97     97
530 AD  opend4               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
520bAD @getst          c                   const('GETSTOP')
     D @cvtdt          c                   const('CVTDTE')
640eAD @getdr          c                   const('DH900')
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
640eA*----------------------------------------------------------------
640eA*
640eAD $lparm          ds
640eAD  $lcmd                  1      8
640eAD  $lprg                  9     18
640eAD  $luky                 19     68
640eAD  $lrtn                 69     76
640eAD  $lerm                 77    136
640eAD  $lmsg                 77     80
640eA*
640eA*   Redefine key
640eA*
640eAD  $lwhse                19     21  0
640eAD  $lrtid                22     26
640eAD  $ltrn#                27     33  0
640eAD  $lwhdp                34     38
640eAD  $ldoor                39     41  0 inz
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
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D count           s              5  0
     D curcol          s                   like(pscol)
     D curpal          s              2  0
     D currow          s                   like(psrow)
     D curunl          s                   like(psunld)
     D dox             s              2  0
     D first           s              1
     D first2          s              1
     D forevr          s              1
     D frdesc          s             30
     D kyltyp          s                   like(lbtype)
     D kytype          s                   like(pstype)
     D l               s              3  0
     D lbls            s              3  0
     D lcount          s              3  0
     D lincnt          s              3  0
     D lins            s              3  0
     D lmax            s              1  0
     D lstlb#          s                   like(lblbl#)
     D lstpid          s                   like(psplid)
     D lststp          s                   like(lbstop)
     D lstum           s                   like(lbutyp)
     D lstwdp          s                   like(lbwhdp)
     D opened          s              1
     D pal#            s              7  0
     D palcnt          s              2  0
     D remain          s              2  0
     D s               s              3  0
     D tmpzon          s                   like(psszon)
     D today           s              8  0
     D todesc          s             30
     D toqty           s              5  0
     D toum            s              2
     D ttlcub          s              8  3
     D ttlpcs          s              7  0
     D ttlwgt          s              9  2
     D wrkcnt          s              3  0
     D w1pcub          s              6  3
     D w1pick          s                   like(lbqpck)
     D w1ppcs          s              5  0
     D w1pstp          s              5  0
     D w1pwgt          s              7  2
     D w1qty2          s                   like(lbqpck)
     D w1rcnm          s             30
     D w1rcub          s              6  3
     D w1rpcs          s              5  0
     D w1rstp          s              5  0
     D w1rwgt          s              7  2
CWDbD *w1scnm          s             30
CWDbMD w1scnm          s             41
     D w1scub          s              6  3
     D w1spcs          s              5  0
     D w1sstp          s              5  0
     D w1swgt          s              7  2
     D z1              s              3  0
     D z2              s              3  0
520bAD fdistp          s              5  0
520bAD ohst5p          s              5  0
530 AD kycod4          s                   like(opzcod)
530bAD $ptmpl          s             10
640aAD isodate         s               d   datfmt(*iso)
640aAD mdydate         s               d   datfmt(*mdy)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Command
409 A*              *REPLEN  -  Print potential replenishments.
     *      $PWHSE  Warehouse
     *      $PRTID  Route Id
     *      $PCOMP  Compartment
     *      $PTZON  Truck zone
     *      $PGEN   Generation
     *      $PSZON  Slot zone
     *      $PTRUK  Truck
     *      $PRTE   Route
     *      OPZDTA  Picking label options
     *      $PTRN#  Transaction number for reprints
409 A*              Batch number for *REPL
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $pcomp            1
     C                   parm                    $ptzon            6
     C                   parm                    $pgen             1 0
     C                   parm                    $pszon            6
     C                   parm                    $ptruk           10
     C                   parm                    $prte             5
530 D ***                parm                    opzdta
530 MC                   parm                    opdta2
     C                   parm                    $ptrn#            7 0
     *----------------------------------------------------------------
     *  Main line
530 A*
530 AC                   eval      kycod4 = '*PICKLBB'
530 AC                   eval      opdta4 = *blanks
530 AC     opzkyb        chain     optionz
530 AC                   if        %found(optionz)
530 AC                   eval      opdta4 = opzdta
530 AC                   endif
     *
     * Check to see if this is only a test.
     *
     C                   if        $pcmd = '*TEST1  '
     C                   exsr      test1
     C                   goto      bottom
     C                   endif
     *
     * Open printer file for zone.
     *
     C                   exsr      opnprt
409 A*
409 A* Print potential replenishments
409 A*
409 AC                   if        $pcmd = '*REPLEN '
409 AC                   if        opletd = 'Y'
409 AC                   exsr      prtprp
409 AC                   endif
409 AC                   goto      bottom
409 AC                   endif
     *
     * Print letdowns for zone.
     *
405 AC                   if        opletd = 'Y'
     C                   exsr      prtrpl
405 AC                   endif
     *
     * Print bulk picks for zone.
     *
     C                   exsr      prtblk
     *
     * Print selection labels for zone.
     *
     *    Note: First the pallet summary records will be read
     *          and the information saved.  Then, when the
     *          transaction number changes, we go and print
     *          the labels for the previous transacton
     *          number (LSTTRN).
     *
     *    Loop through truck pallets for zone.
     *
     C                   eval      first = *on
     *
     C                   eval      kytype = 'O'
     C     keyps3        setll     pltsum3
     C                   dou       forevr <> forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     Skip pallet if nothing was picked.
     *
     C                   if        pspcs = 0
     C                   iter
     C                   endif
640fA*
640fA*     Skip pallet if tran# = 0 and pallet contains bulk pick.
640fA*     In that case we assume that the pallet only contains a
640fA*     bulk pick and was not assigned a tran# in OR630.
640fA*
640fAC                   if        pstrn# = 0  and
640fAC                             psbcnt <> 0
640fAC                   iter
640fAC                   endif
     *
     *     First time through initialization.
     *
     C                   if        first = *on
     C                   eval      lsttrn = pstrn#
     C                   eval      palcnt = 0
     C                   eval      first = *off
     C                   endif
     *
     *     If transaction number changed, go and print the detail
     *       for the previous transaction (LSTTRN).
     *
     C                   if        pstrn# <> lsttrn
404 AC                   eval      curunl = psunld
404 AC                   eval      currow = psrow
404 AC                   eval      curcol = pscol
     C                   exsr      prtsel
404 AC     keyps         setll     pltsum3
404 AC                   read      pltsum3                                79
     C                   eval      lsttrn = pstrn#
     C                   eval      palcnt = 0
     C                   endif
     *
     *     Add pallet info to pallet summary data structure.
     *
     C                   add       1             palcnt
     C     palcnt        occur     palsum
     C                   eval      dsppal = pspal#
     C                   z-add     pscube        dspcub
     C                   z-add     psswgt        dspwgt
     C                   z-add     pspcs         dsppcs
     C                   eval      dspstp = 0
     C                   eval      lststp = -(1)
404 AC                   eval      dsppli = psplid
     C     keyss1        setll     pltstp1
     C                   dow       forevr = forevr
     C     keyss1        reade     pltstp1                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        pssstp <> lststp
     C                   add       1             dspstp
     C                   eval      lststp = pssstp
     C                   endif
     C                   enddo
     *
     C                   enddo
     *
     *   Print last pallet(s), if any.
     *
     C                   if        palcnt > 0
     C                   exsr      prtsel
     C                   endif
     *
     *
     *   Bye, Bye.
     *
     C     bottom        tag
     C                   eval      *inlr = *on
     *
     *   Close up shop and return home.
     *
     CLr                 if        opened = *on
720aDC*Lr                 close     plst40pw
720aMCLr                 close     plst40pcf
     CLr                 endif
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
640dA*
640dA* Get client id.
640dA*
640dAC                   call      @getcl
640dAC                   parm                    client
640dAC                   parm                    cliloc
640dA*
     C                   eval      forevr = *off
QF  MC                   eval      lmax = 1
     C                   eval      lcount = 1
405 A*
405 A*  Define key for OPTIONS file.
405 A*
405 AC     opkey         klist
405 AC                   kfld                    opwhse
405 AC                   kfld                    opcode
     *
     *  Define partial key for PLTSUM3 file.
     *
     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kytype
     C                   kfld                    $pcomp
     C                   kfld                    $ptzon
     C                   kfld                    $pgen
     C                   kfld                    $pszon
404 A*
404 AC     keyps         klist
404 AC                   kfld                    $pwhse
404 AC                   kfld                    $prtid
404 AC                   kfld                    kytype
404 AC                   kfld                    $pcomp
404 AC                   kfld                    $ptzon
404 AC                   kfld                    $pgen
404 AC                   kfld                    $pszon
404 AC                   kfld                    curunl
404 AC                   kfld                    currow
404 AC                   kfld                    curcol
     *
     *  Define partial key for PLTSTP1 file.
     *
     C     keyss1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
402 AC                   kfld                    psplid
     C                   kfld                    psrow
     C                   kfld                    pscol
     *
     *  Define partial key for LABEL31 file.
     *
     C     keyl31        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kyltyp
     C                   kfld                    psplid
     *
     *  Define partial key for LABEL32 & LABEL34 file.
     *
     C     keyl32        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kyltyp
     C                   kfld                    lsttrn
     *
     *  Define partial key for LABEL33 file.
     *
     C     keyl33        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lsttrn
409 A*
409 A*  Define partial key for LABEL3 file.
409 A*
409 AC     keyl3f        klist
409 AC                   kfld                    $ptrn#
409 AC                   kfld                    $pwhse
216 A*
216 A*  Define key for PIRITEM file. (FOR BROKEN CASE ITEM)
216 A*
216 AC     keyib         klist
216 AC                   kfld                    $pwhse
216 AC                   kfld                    lbitem
213 A*
213 A*  Define key for PIRITEM file. (FOR LINK ITEM)
213 A*
213 AC     keyit         klist
213 AC                   kfld                    $pwhse
213 AC                   kfld                    ilitm2
213 A*
213 A*  Define key for ITEMLNK file.
213 A*
213 AC     keyil         klist
213 AC                   kfld                    $pwhse
213 AC                   kfld                    lbitem
530 A*
530 AC     opzkyb        klist
530 AC                   kfld                    kycod4
530 AC                   kfld                    $pwhse
530bD ***                kfld                    $ptruk
530bMC                   kfld                    $ptmpl
530 AC                   kfld                    $pszon
530 A*
530 A*  Define key for TRUCKH file.
530 A*
530 AC     trkey         klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
640cA*
640cA*  Define key for Zone header.
640cA*
640cAC     zonkey        klist
640cAC                   kfld                    $pwhse
640cAC                   kfld                    $ptmpl
640cAC                   kfld                    $pszon
640dA*
640dA*  Define key for ORDDM file.
640dA*
640dAC     keyodm        klist
640dAC                   kfld                    $pwhse
640dAC                   kfld                    lbord
640dAC                   kfld                    lbseq
640dAC                   kfld                    lbitem
HKWaA*
HKWaA*  Define key for ORDHM file.
HKWaA*
HKWaAC     keyodh        klist
HKWaAC                   kfld                    $pwhse
HKWaAC                   kfld                    lbord
     *
720bA*  Define key for ORDH file.
720bA*
720bAC     keyordh       klist
720bAC                   kfld                    $pwhse
720bAC                   kfld                    l94_lbord
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
640aAC                   move      today         isodate
640aAC                   move      isodate       mdydate
720bAC**                 move      mdydate       mdydat8
     *
     *   Define variables.
     *
405 A*
405 A*  Get system options.
405 A*
405 AC                   eval      opwhse = 0
405 AC                   eval      opcode = '*SYSTEM '
405 AC     opkey         chain     options                            79
405 AC                   if        *in79
405 AC                   eval      opletd = 'Y'
405 AC                   endif
530bA*
530bA* Get Zone Template Code if Template type is T=Truck
530bA*
530bAC     trkey         chain     truckh
530bAC                   if        %found(truckh) and thtype = 'T'
530bAC                   eval      $ptmpl =  thztmp
530bAC                   else
530bAC                   eval      $ptmpl =  $ptruk
530bAC                   endif
     *
     C                   endsr
404 A*----------------------------------------------------------------
404 A*
404 A*  GETPAL  Get pallet number.
404 A*
     C     getpal        begsr
     C                   eval      pal# = 0
     C     1             do        palcnt        curpal
     C     curpal        occur     palsum
     C                   if        dsppli = lbpal#
     C                   eval      pal# = dsppal
     C                   endif
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
720aDC**                 close     plst40pw
720aMC                   close     plst40pcf
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(PLBL__PR) OUTQ(*DEV) DEV(rodev)
     *                  FORMTYPE(roform)
     *
     C                   movea     ovrprt(1)     a80
530 D ***                movea     oppdev        a80(39)
530 D ***                movea     oppfrm        a80(60)
720aDC**                 movea     opdv6         a80(39)
720aMC                   movea     opdv6         a80(40)
720aDC**                 movea     opfm6         a80(60)
720aMC                   movea     opfm6         a80(61)
     C                   movea     a80           qcmd
CTWa C                   if        client = citywho and
CTWa C                             $ptruk <> 'WILLCALL'
CTWa C                   eval      qcmd = %trim(qcmd) + ' HOLD(*YES)'
CTWa C                   endif
     C                   call      'QCMDEXC'
CTWaDC*                  parm                    qcmd             80
CTWaMC                   parm                    qcmd            100
CTWaDC*                  parm      80            qlen             15 5
CTWaMC                   parm      100           qlen             15 5
     *
     *      Open printer file.
     *
720aDC**                 open      plst40pw
720aMC                   open      plst40pcf
     C                   eval      opened = *on
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTBLK  Print bulk pick labels for route/department.
     *
     C     prtblk        begsr
     *
     C                   eval      first = *on
     *
     *  Loop bulk picks for zone.
     *
413 A*    Revised to only use a pallet id once.
     *
413 AC                   eval      lstpid = -(1)
     C                   eval      kytype = 'B'
     C     keyps3        setll     pltsum3
     C                   dou       forevr <> forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
413 AC                   if        psplid = lstpid
413 AC                   iter
413 AC                   endif
413 AC                   eval      lstpid = psplid
     *
     *    Loop through bulk pick labels for pallet.
     *      Note: There should only be one label, but this keeps
     *            the coding consistant with replenishments.
     *
413 A*      The above statment is false. There can be more than
     *      one bulk pick to a pallet especially if an item didn't
     *      have home slot.
     *
413 A*      The 413 fix was necessary because the LABEL31 file
     *      is joined to the PLTSUM file only using the pallet
     *      id. When there are multiple bulk picks on a pallet
     *      the LABEL31 ends up with duplicate records. These
     *      dups are created in sequence so we can check the
     *      label number against the last one and skip the
     *      record if they are the same.
     *
413 AC                   eval      lstlb# = -(1)
     C                   eval      kyltyp = 'B'
     C     keyl31        setll     label31
     *
     C                   dou       forevr <> forevr
     *
     C     keyl31        reade     label31                                78
     C                   if        *in78
     C                   leave
     C                   endif
413 AC                   if        lblbl# = lstlb#
413 AC                   iter
413 AC                   endif
413 AC                   eval      lstlb# = lblbl#
     *
     *       Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
HKWaA*
HKWaA*     Get order header misc
HKWaA*
HKWaAC                   exsr      getORDHM
640bA*
640bA*     Get pack description.
640bA*
640bAC                   eval      w1pack = itpdsc
640bA*
520bAC                   eval      work2 = ohstop
520bAC                   call      @getst
520bAC                   parm      '*PLTSTP'     $lcmd
520bAC                   parm                    $pwhse
520bAC                   parm                    $prtid
520bAC                   parm      *zeros        $pordr
520bAC                   parm                    work2
520bAC                   parm                    $phstp
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520bAC                   if        $phstp <> *zeros
520bAC                   eval      ohst5p = $phstp
520bAC                   else
520bAC                   eval      ohst5p = ohstop
520bAC                   endif
640eA*
640eA*     Get dock door for the transaction.
640eA*
640eAC                   eval      $lwhse = $pwhse
640eAC                   eval      $lrtid = $prtid
640eAC                   eval      $ltrn# = lbtrn#
640eAC                   eval      $lwhdp = *blanks
640eAC                   eval      $ldoor = 0
640eAC                   call      'DH900'
640eAC                   parm                    $lparm
     *
     *       Print beginning bulk pick label.
     *
     C                   if        first = *on
     C                   eval      *in81 = *on
GFCaAC                   select
GFCaAC                   when      client = glazier
GFCaAC                   write     begblkgfc
GFCaAC                   other
     C                   write     begblk
720aAC                   write     begblkBold
GFCaAC                   endsl
     C                   eval      *in81 = *off
     C                   eval      first = *off
     C                   endif
     *
     *       Print warning for bulk/replenishment combo.
     *
     *
     *       Print bulk label.
     *
     C                   eval      w1qty = lbqpck
     C                   movel     lbitem        w1item
720aAC                   write     bulkBold
     C                   write     bulk
     C                   if        *in90
GFCaAC                   select
GFCaAC                   when      client = glazier
GFCaAC                   write     begblk2gfc
GFCaAC                   other
     C                   write     begblk2
GFCaAC                   endsl
     C                   eval      *in90 = *off
     C                   endif
     *
     *       Print replenishment label if necessary.
     *
     *
     * ***** Ignored. Call to OR631 was commented out 9/3/99 ********
     *
     C                   if        lbdsp2 <> *blanks
     C                   eval      w1qty = lbqrmn
     C                   endif
     *
412cAC                   if        itcwgt = 'Y'
412cAC     lbqpck        div       10            lins
412cAC                   mvr                     remain
412cAC                   if        remain <> 0
412cAC                   add       1             lins
412cAC                   endif
412cAC     1             do        lins          z1
412cAC                   if        z1 = lins  and
412cAC                             remain > 0
412cAC                   eval      dox = remain
412cAC                   else
412cAC                   eval      dox = 10
412cAC                   endif
412cAC                   eval      z2 = 1
412cAC                   eval      cw = *blanks
412cAC     1             do        dox
412cAC                   movea     '_____'       cw(z2)
412cAC                   add       5             z2
412cAC                   movea     '_____'       cw(z2)
412cAC                   add       7             z2
412cAC                   enddo
412cAC                   movea     cw            w1wgt
412cAC                   write     cachwt
412cAC                   enddo
415aAC                   add       lins          lincnt
412cAC                   endif
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   endsr
409 A*----------------------------------------------------------------
409 A*
409 A*  PRTPRP  Print potential replenishment labels.
409 A*
409 AC     prtprp        begsr
409 A*
409 AC                   eval      first = *on
409 A*
409 A*    Loop through potential replenishment batch of labels.
409 A*
409 AC     keyl3f        setll     label3
409 A*
409 AC                   dou       forevr <> forevr
409 A*
409 AC     keyl3f        reade     label3                                 78
409 AC                   if        *in78
409 AC                   leave
409 AC                   endif
409 A*
409 A*       Skip label if nothing was picked.
409 A*
409 AC                   if        lbqpck = 0
409 AC                   iter
409 AC                   endif
409 A*
409 A*       Skip label if closed.
409 A*
409 AC                   if        lbstat = 'C'
409 AC                   iter
409 AC                   endif
409 A*
409 A*       Print "Beginning Replenishment" pick label.
409 A*
409 AC                   if        first = *on
     C                   eval      *in81 = *on
409 AC                   write     begrpl
     C                   eval      *in81 = *off
409 AC                   eval      first = *off
409 AC                   endif
409 A*
409 A*       Print replenishment label if necessary.
409 A*
409 AC                   eval      w1qty = lbqpck
     C                   movel     lbitem        w1item
409 AC                   if        ittype = 'B'
409 AC                   movel     lbitem        toitem
409 AC                   eval      todesc = itdesc
409 AC     keyil         chain     itemlnk                            79
409 AC                   movel     ilitm2        fritem
409 AC     keyit         chain     piritem                            79
409 AC                   eval      frdesc = itdesc
409 AC                   eval      toqty = itumq2
409 AC                   eval      toum = itum2
409 AC                   write     repl2
409 AC                   else
409 AC                   write     repl1
409 AC                   endif
     C                   if        *in90
     C                   write     begrpl2
     C                   eval      *in90 = *off
     C                   endif
409 A*
409 AC                   enddo
409 A*
409 AC                   endsr
     *----------------------------------------------------------------
     *
     *  PRTRPL  Print replenishment labels for zone
     *
     C     prtrpl        begsr
     *
     C                   eval      first = *on
     *
     *  Loop through pallets for zone.
     *
     C                   eval      kytype = 'O'
     C     keyps3        setll     pltsum3
     C                   dou       forevr <> forevr
     C     keyps3        reade     pltsum3                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *    Loop through replenishment labels for pallet.
     *
     C                   eval      kyltyp = 'R'
     C     keyl31        setll     label31
     *
     C                   dou       forevr <> forevr
     *
     C     keyl31        reade     label31                                78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *       Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
520bAC                   eval      work2 = ohstop
520bAC                   call      @getst
520bAC                   parm      '*PLTSTP'     $lcmd             8
520bAC                   parm                    $pwhse            3 0
520bAC                   parm                    $prtid            5
520bAC                   parm      *zeros        $pordr            7 0
520bAC                   parm                    work2             2 0
520bAC                   parm                    $phstp            5 0
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520bAC                   if        $phstp <> *zeros
520bAC                   eval      ohst5p = $phstp
520bAC                   else
520bAC                   eval      ohst5p = ohstop
520bAC                   endif
     *
     *       Print "Beginning Replenishment" pick label.
     *
     C                   if        first = *on
     C                   eval      *in81 = *on
     C                   write     begrpl
     C                   eval      *in81 = *off
     C                   eval      first = *off
     C                   endif
     *
     *       Print replenishment label if necessary.
     *
     C                   eval      w1qty = lbqpck
     C                   movel     lbitem        w1item
213 AC                   if        ittype = 'B'
213 AC                   movel     lbitem        toitem
213 AC                   eval      todesc = itdesc
213 AC     keyil         chain     itemlnk                            79
213 AC                   movel     ilitm2        fritem
213 AC     keyit         chain     piritem                            79
213 AC                   eval      frdesc = itdesc
213 AC                   eval      toqty = itumq2
213 AC                   eval      toum = itum2
213 AC                   write     repl2
213 AC                   else
     C                   write     repl1
213 AC                   endif
     C                   if        *in90
     C                   write     begrpl2
     C                   eval      *in90 = *off
     C                   endif
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PRTSEL  Print normal selection labels for zone.
     *
     C     prtsel        begsr
     *
720bA*     Get ohmisc date
720bA*
720bAC                   eval      l94_lbord = *zeros
720bAC     keyl33        chain     label94
720bAC                   eval      ohmisc = *blanks
720bAC     keyordh       chain     ordh
720bAC                   eval      dsmisc = ohmisc
720bAc                   eval      mm = dsmm
720bAc                   eval      dd = dsdd
720bAc                   eval      yy = dsyy
     *
     *   Print header for this set of selection labels.
     *
     C                   exsr      setbeg
     *
     *   Loop through selection labels for transaction.
     *
     C                   eval      count = 0
     C                   eval      kyltyp = 'O'
409 AC*WSFa              if        $pgen = 1    **this does nothing**
WSFaAC                   select
WSFaAC                   when      client = westside
WSFaAC     keyl32        setll     label32w
WSFaAC                   other
720aMC     keyl32        setll     label32x
WSFaAC                   endsl
409 AC*WSFakeyl32        setll     label32      **this does nothing**
409 AC*WSFa              else                   **this does nothing**
     C*WSFakeyl32        setll     label32      **this does nothing**
409 AC*WSFa              endif                  **this does nothing**
     *
     C                   dou       forevr <> forevr
409 AC*WSFa              if        $pgen = 1    **this does nothing**
409 AC*WSFakeyl32        reade     label32      **this does nothing**     78
409 AC*WSFa              else                   **this does nothing**
     C*WSFakeyl32        reade     label32      **this does nothing**     78
409 AC*WSFa              endif                  **this does nothing**
WSFaAC                   select
WSFaAC                   when      client = westside
WSFaAC     keyl32        reade     label32w                               78
WSFaAC                   other
720aMC     keyl32        reade     label32x                               78
WSFaAC                   endsl
     C                   if        *in78
     C                   leave
     C                   endif
     *
404 A*     Skip label if cross dock.
     *
404 AC                   if        lbstyp = 'X'
404 AC                   iter
404 AC                   endif
     *
     *     Skip label if nothing was picked.
     *
     C                   if        lbqpck = 0
     C                   iter
     C                   endif
640bA*
640bA*     Get pack description.
640bA*
640bAC                   eval      w1pack = itpdsc
HKWaA*
HKWaA*     Get order header misc
HKWaA*
HKWaAC                   exsr      getORDHM
TPSdA*
TPSdA*     Get order header misc
TPSdA*
TPSdAC                   exsr      getORDDM
     *
520bAC                   eval      work2 = ohstop
520bAC                   call      @getst
520bAC                   parm      '*PLTSTP'     $lcmd
520bAC                   parm                    $pwhse
520bAC                   parm                    $prtid
520bAC                   parm      *zeros        $pordr
520bAC                   parm                    work2
520bAC                   parm                    $phstp
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520bAC                   if        $phstp <> *zeros
520bAC                   eval      ohst5p = $phstp
520bAC                   else
520bAC                   eval      ohst5p = ohstop
520bAC                   endif
     C                   add       1             count
     *
     *     See if we should print the "before" um warning.
     *
     C                   if        lbutyp <> 'N'  and
     C                             opuwrb = 'Y'
     C                   endif
     *
     *     Initialize label fields.
     *
     C                   eval      w1qty2 = lbqpck
     *
     *        Print one label.
     *
     C                   eval      w1pick = lbqpck
     C                   movel     lbitem        w1item
413aAC                   eval      w1out = lbasl2
415 AC                   exsr      zzoflo
     *
CWDaAC                   select
CWDaAC                   when      client = cashwa
CWDaAC                   monitor
720aDC**                 eval      w1sqty = cwddm1_qoh
CWDaAC                   on-error
720aDC**                 eval      w1sqty = 0
CWDaAC                   endmon
CWDaAC                   write     pickcwd
CWDaAC                   other
     C                   write     pick
720aAC                   write     pickBold
CWDaAC                   endsl
     *
TPSaAC                   if        client = tps
TPSaAC                             and w1note <> *blanks
TPSaAC                   write     picknote
TPSaAC                   endif
415 AC                   add       1             lincnt
     C                   if        *in90
415 AC                   eval      lincnt = 0
GFCaAC                   select
GFCaAC                   when      client = glazier
GFCaAC                   write     sethdgfc
GFCaAC                   other
     C                   write     sethd
GFCaAC                   endsl
CWDaAC                   select
CWDaAC                   when      client = cashwa
CWDaAC                   write     sethcwd
CWDaAC                   other
     C                   write     sethed2
720aAC                   write     sethd2Bold
CWDaAC                   endsl
415 AC                   add       3             lincnt
     C                   eval      *in90 = *off
     C                   endif
     *
     *     Print catch weight labels.
     *
     C                   if        itcwgt = 'Y'
720bMC     lbqpck        div       8             lins
     C                   mvr                     remain
     C                   if        remain <> 0
     C                   add       1             lins
     C                   endif
     C     1             do        lins          z1
     C                   if        z1 = lins  and
     C                             remain > 0
     C                   eval      dox = remain
     C                   else
     C                   eval      dox = 8
     C                   endif
     C                   eval      z2 = 1
     C                   eval      cw = *blanks
     C     1             do        dox
     C                   movea     '_____'       cw(z2)
     C                   add       5             z2
     C                   movea     '_____'       cw(z2)
     C                   add       7             z2
     C                   enddo
     C                   movea     cw            w1wgt
     C                   write     cachwt
     C                   enddo
415aAC                   add       lins          lincnt
     C                   endif
     *
     C                   enddo
     *
     *   Print summary for this set of selection labels.
     *
     C                   exsr      setend
     *
     C                   endsr
     *----------------------------------------------------------------
     *
404 A*  PRTXDK  Print cross dock labels.
     *
404 AC     prtxdk        begsr
     *
     *
404 A*   Loop through selection labels for transaction.
404 A*
404 AC                   eval      count = 0
404 AC                   eval      kyltyp = 'O'
404 A*
409 AC*WSFa              if        $pgen = 1   **this does nothing**
404 AC*WSFakeyl32        setll     label32     **this does nothing**
409 AC*WSFa              else                  **this does nothing**
404 AC*WSFakeyl32        setll     label32     **this does nothing**
409 AC*WSFa              endif                 **this does nothing**
WSFaAC                   select
WSFaAC                   when      client = westside
WSFaAC     keyl32        setll     label32w
WSFaAC                   other
720aMC     keyl32        setll     label32x
WSFaAC                   endsl
404 A*
404 AC                   dou       forevr <> forevr
409 AC*WSFa              if        $pgen = 1      **this does nothing**
404 AC*WSFakeyl32        reade     label32        **this does nothing**   78
409 AC*WSFa              else                     **this does nothing**
404 AC*WSFakeyl32        reade     label32        **this does nothing**   78
409 AC*WSFa              endif                    **this does nothing**
WSFaAC                   select
WSFaAC                   when      client = westside
WSFaAC     keyl32        reade     label32w                               78
WSFaAC                   other
720aMC     keyl32        reade     label32x                               78
WSFaAC                   endsl
404 AC                   if        *in78
404 AC                   leave
404 AC                   endif
404 A*
404 A*
404 A*     Skip label if not cross dock.
404 A*
404 AC                   if        lbstyp <> 'X'
404 AC                   iter
404 AC                   endif
404 A*
404 A*     Skip label if nothing was picked.
404 A*
404 AC                   if        lbqpck = 0
404 AC                   iter
404 AC                   endif
404 A*
404 AC                   add       1             count
HKWaA*
HKWaA*     Get order header misc
HKWaA*
HKWaAC                   exsr      getORDHM
404 A*
404 A*   Print warning "Cross dock labels next".
404 A*
404 AC                   if        count = 1
404 AC                   write     xdck
404 AC                   endif
404 A*
404 A*     See if we should print the "before" um warning.
404 A*
404 AC                   if        lbutyp <> 'N'  and
404 AC                             opuwrb = 'Y'
404 AC                   endif
404 A*
404 A*     Initialize label fields.
404 A*
404 AC                   eval      w1qty2 = lbqpck
404 A*
404 AC                   eval      w1pick = lbqpck
     C                   movel     lbitem        w1item
412bAC                   if        lbasl2 = 'OUT'
412bAC                   eval      w1out = 'OUT'
412bAC                   else
412bAC                   move      '   '         w1out
412bAC                   endif
415 AC                   exsr      zzoflo
     *
CWDaAC                   select
CWDaAC                   when      client = cashwa
CWDaAC                   monitor
720aDC**                 eval      w1sqty = cwddm1_qoh
CWDaAC                   on-error
720aDC**                 eval      w1sqty = 0
CWDaAC                   endmon
CWDaAC                   write     pickcwd
CWDaAC                   other
404 AC                   write     pick
720aAC                   write     pickBold
CWDaAC                   endsl
     *
415 AC                   add       1             lincnt
     C                   if        *in90
415 AC                   eval      lincnt = 0
GFCaAC                   select
GFCaAC                   when      client = glazier
GFCaAC                   write     sethdgfc
GFCaAC                   other
     C                   write     sethd
GFCaAC                   endsl
CWDaAC                   select
CWDaAC                   when      client = cashwa
CWDaAC                   write     sethcwd
CWDaAC                   other
     C                   write     sethed2
720aAC                   write     sethd2Bold
CWDaAC                   endsl
415 AC                   add       3             lincnt
     C                   eval      *in90 = *off
     C                   endif
404 A*
404 A*     See if we should print the "after" um warning.
404 A*
404 AC                   if        lbutyp <> 'N'  and
404 AC                             opuwra = 'Y'
404 AC                   endif
404 A*
404 A*     Print catch weight labels.
404 A*
404 AC                   if        itcwgt = 'Y'
     C     lbqpck        div       10            lins
     C                   mvr                     remain
     C                   if        remain <> 0
     C                   add       1             lins
     C                   endif
     C     1             do        lins          z1
     C                   if        z1 = lins  and
     C                             remain > 0
     C                   eval      dox = remain
     C                   else
     C                   eval      dox = 10
     C                   endif
     C                   eval      z2 = 1
     C                   eval      cw = *blanks
     C     1             do        dox
     C                   movea     '_____'       cw(z2)
     C                   add       5             z2
     C                   movea     '_____'       cw(z2)
     C                   add       7             z2
     C                   enddo
     C                   movea     cw            w1wgt
     C                   write     cachwt
     C                   enddo
415aAC                   add       lins          lincnt
404 AC                   endif
404 A*
404 AC                   enddo
404 A*
404 AC                   endsr
     *----------------------------------------------------------------
     *
     *  SETBEG  Start new set of labels.
     *
     C     setbeg        begsr
520 A*
520 AC                   eval      *in90 = *off
     *
     *   Print set header label.
     *
415 AC                   eval      lincnt = 0
     C                   eval      lbtrn# = lsttrn
     C                   eval      w1trn# = lbtrn#
     C                   eval      *in81 = *on
720aA*
720aA*     Get dock door for the transaction.
720aA*
720aAC                   eval      $lwhse = $pwhse
720aAC                   eval      $lrtid = $prtid
720aAC                   eval      $ltrn# = lbtrn#
720aAC                   eval      $lwhdp = *blanks
720aAC                   eval      $ldoor = 0
720aAC                   call      'DH900'
720aAC                   parm                    $lparm
     *
GFCaAC                   select
GFCaAC                   when      client = glazier
GFCaAC                   write     sethdgfc
GFCaAC                   other
     C                   write     sethd
GFCaAC                   endsl
415 AC                   add       2             lincnt
     C                   eval      *in81 = *off
     *
     *   Print pallet summary.
     *
     C                   write     pltsumh
415 AC                   add       1             lincnt
     C     1             do        palcnt        curpal
     C     curpal        occur     palsum
     C                   eval      w1pal# = dsppal
640aD ***                eval      work2 = dspstp
640aD ***                call      @getst
640aD ***                parm      '*PLTSTP'     $lcmd
640aD ***                parm                    $pwhse
640aD ***                parm                    $prtid
640aD ***                parm      *zeros        $pordr
640aD ***                parm                    work2
640aD ***                parm                    $phstp
640aD ***                if        $phstp <> *zeros
640aD ***                eval      fdistp = $phstp
640aD ***                eval      w1pstp = $phstp
640aD ***                endif
640aMC                   eval      w1pstp = dspstp
     C                   eval      w1pcub = dspcub
     C                   eval      w1pwgt = dspwgt
     C                   eval      w1ppcs = dsppcs
     C                   write     pltsumd
415 AC                   add       1             lincnt
     C                   enddo
     *
CWDaAC                   select
CWDaAC                   when      client = cashwa
CWDaAC                   write     sethcwd
CWDaAC                   other
     C                   write     sethed2
720aAC                   write     sethd2Bold
CWDaAC                   endsl
415 AC                   add       1             lincnt
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SETEND  End set of labels.
     *
     C     setend        begsr
     *
404 A*   Print cross dock labels.
     *
404 AC                   exsr      prtxdk
     *
     *   Print discrepancy labels.
     *
     C                   if        operr <> 0
     C     count         div       operr         lbls
     C                   mvr                     remain
     C                   if        remain <> 0
     C                   add       1             lbls
     C                   endif
     C     1             do        lbls
     C                   enddo
     C                   endif
     *
     *   Print merge summary(s) for transaction.
     *
     *     Loop through selection labels for transaction.
     *
     C                   eval      first2 = *on
     C                   eval      kyltyp = 'M'
406 AC                   eval      s = 0
     *
409 AC*WSFa              if        $pgen = 1      **this does nothing**
409 AC*WSFakeyl32        setll     label32        **this does nothing**
409 AC*WSFa              else                     **this does nothing**
     C*WSFakeyl32        setll     label32        **this does nothing**
409 AC*WSFa              endif                    **this does nothing**
WSFaAC                   select
WSFaAC                   when      client = westside
WSFaAC     keyl32        setll     label32w
WSFaAC                   other
720aMC     keyl32        setll     label32x
WSFaAC                   endsl
     *
     C                   dou       forevr <> forevr
409 AC*WSFa              if        $pgen = 1    **this does nothing**
409 AC*WSFakeyl32        reade     label32      **this does nothing**     78
409 AC*WSFa              else                   **this does nothing**
     C*WSFakeyl32        reade     label32      **this does nothing**     78
409 AC*WSFa              endif                  **this does nothing**
WSFaAC                   select
WSFaAC                   when      client = westside
WSFaAC     keyl32        reade     label32w                               78
WSFaAC                   other
720aMC     keyl32        reade     label32x                               78
WSFaAC                   endsl
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *       Put together zone from label fields.
     *
     C                   movel     lbwhdp        tmpzon
     C                   move      lbstyp        tmpzon
     *
     C                   movel     lbitem        w1item
520bD ***                eval      w1rstp = lbstop
520bAC                   eval      work2 = lbstop
520bAC                   call      @getst
520bAC                   parm      '*PLTSTP'     $lcmd
520bAC                   parm                    $pwhse
520bAC                   parm                    $prtid
520bAC                   parm      *zeros        $pordr
520bAC                   parm                    work2
520bAC                   parm                    $phstp
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520bAC                   if        $phstp <> *zeros
520bAC                   eval      fdistp = $phstp
520bAC                   eval      w1rstp = $phstp
640cAC                   else
640cAC                   eval      fdistp = lbstop
640cAC                   eval      w1rstp = lbstop
520bAC                   endif
     *
     *       First time through initialization.
     *
     C                   if        first2 = *on
     C                   eval      lstzon = tmpzon
404 AC                   exsr      getpal
404 AC                   eval      w1pal# = pal#
     C                   write     zonsumh
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
404 AC                   eval      w1rcub = 0
404 AC                   eval      w1rwgt = 0
404 AC                   eval      w1rpcs = 0
     C                   eval      s = 0
     C                   eval      first2 = *off
     C                   endif
405 D*
405 D*       When zone or stop changes, print detail line.
405 D*
404 AC                   exsr      getpal
404 AC                   eval      w1pal# = pal#
     *
     *       When zone changes, print summary totals.
     *
     C                   if        tmpzon <> lstzon
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
     C                   eval      s = 0
     C                   eval      lstzon = tmpzon
403 AC                   write     zonsumh
     C                   endif
     *
     *       Update summary amounts for stop.
     *
405 MC                   z-add     lbcube        w1rcub
405 MC                   z-add     lbswgt        w1rwgt
405 MC                   eval      w1rpcs = lbqpck
     C                   movel     ohcnam        w1rcnm
405 A*
405 A*       Print detail line.
405 A*
404 AC                   exsr      getpal
404 AC                   eval      w1pal# = pal#
405 AC                   add       1             s
405 AC                   if        s > 9
405 AC                   eval      s = 1
405 AC                   endif
640cAC     zonkey        chain     zoneh
640cAC                   if        not %found(zoneh)
640cAC                   eval      zhdesc = *blanks
640cAC                   endif
     C                   eval      ix = %trimr(lbitem) + ' ' + '-'
WSFbAC                   if        client = westside and
WSFbAC                             lstzon = '*BULK*'
WSFbMC                   eval      ix = %trimr(ix) + ' ' + itdesc
WSFcAC                   eval      w1zdsp = lbdisp
640cD ***                eval      ix = %trimr(ix) + ' ' + itdesc
WSTbMC                   else
WSFcAC                   eval      w1zdsp = *blanks
640cMC                   eval      ix = %trimr(ix) + ' ' + zhdesc
WSFbMC                   endif
     C                   if        *in90
415 AC                   eval      lincnt = 0
GFCaAC                   select
GFCaAC                   when      client = glazier
GFCaAC                   write     sethdgfc
GFCaAC                   other
     C                   write     sethd
GFCaAC                   endsl
     C                   write     zonsumh
     C                   eval      *in90 = *off
     C                   endif
405 AC                   write     zonsumd
405 AC                   add       w1rcub        ttlcub
405 AC                   add       w1rwgt        ttlwgt
405 AC                   add       w1rpcs        ttlpcs
     *
     C                   enddo
405 A*
405 A*     Force printing of label.
405 A*
405 AC                   if        s > 0  and
405 AC                             s < 9
405 AC                   endif
     *
     *   Print set summary for transaction.
     *
     *     Print header label.
     *
     C                   write     setsumh
     *
     *     Loop through all labels for transaction.
     *
     C                   eval      first2 = *on
     C     keyl33        setll     label33
     *
     C                   dou       forevr <> forevr
     C     keyl33        reade     label33                                78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     *       First time through initialization.
     *
     C                   if        first2 = *on
     C                   eval      w1sstp = lbstop
     C                   eval      w1scub = 0
403 AC                   eval      w1swgt = 0
     C                   eval      w1spcs = 0
     C                   eval      w1scnm = *blanks
     C                   eval      ttlcub = 0
     C                   eval      ttlwgt = 0
     C                   eval      ttlpcs = 0
     C                   eval      s = 0
     C                   eval      first2 = *off
     C                   endif
     *
     *       When stop changes, print detail line.
     *
     C                   if        lbstop <> w1sstp
520bAC                   eval      work2 = w1sstp
520bAC                   call      @getst
520bAC                   parm      '*PLTSTP'     $lcmd
520bAC                   parm                    $pwhse
520bAC                   parm                    $prtid
520bAC                   parm      *zeros        $pordr
520bAC                   parm                    work2
520bAC                   parm                    $phstp
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520bAC                   if        $phstp <> *zeros
520bAC                   eval      fdistp = $phstp
520bAC                   eval      w1sstp = $phstp
520bAC                   endif
     C                   add       1             s
     C                   if        s > 9
     C                   eval      s = 1
     C                   endif
     C                   if        *in90
415 AC                   eval      lincnt = 0
GFCaAC                   select
GFCaAC                   when      client = glazier
GFCaAC                   write     sethdgfc
GFCaAC                   other
     C                   write     sethd
GFCaAC                   endsl
     C                   write     setsumh
     C                   eval      *in90 = *off
     C                   endif
     C                   write     setsumd
     C                   add       w1scub        ttlcub
     C                   add       w1swgt        ttlwgt
     C                   add       w1spcs        ttlpcs
     C                   eval      w1scub = 0
     C                   eval      w1swgt = 0
     C                   eval      w1spcs = 0
     C                   eval      w1sstp = lbstop
     C                   endif
     *
     *       Update summary amounts for stop.
     *
     C                   add       lbcube        w1scub
     C                   add       lbswgt        w1swgt
     C                   add       lbqpck        w1spcs
CWDbAC                   select
CWDbAC                   when      client = cashwa
CWDbAC                   eval      w1scnm = %trim(ohczip)
CWDbAC                                         + ' '
CWDbAC                                         + %trim(ohcnam)
CWDbAC                   other
     C                   movel     ohcnam        w1scnm
CWDbAC                   endsl
     *
     C                   enddo
     *
     *     Print last stop and totals.
     *
     C                   if        first2 = *off
520bAC                   eval      work2 = w1sstp
520bAC                   call      @getst
520bAC                   parm      '*PLTSTP'     $lcmd
520bAC                   parm                    $pwhse
520bAC                   parm                    $prtid
520bAC                   parm      *zeros        $pordr
520bAC                   parm                    work2
520bAC                   parm                    $phstp
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520bAC                   if        $phstp <> *zeros
520bAC                   eval      fdistp = $phstp
520bAC                   eval      w1sstp = $phstp
520bAC                   endif
     *
     *       Detail line.
     *
     C                   add       1             s
     C                   if        s > 9
     C                   eval      s = 1
     C                   endif
     C                   if        *in90
415 AC                   eval      lincnt = 0
GFCaAC                   select
GFCaAC                   when      client = glazier
GFCaAC                   write     sethdgfc
GFCaAC                   other
     C                   write     sethd
GFCaAC                   endsl
     C                   write     setsumh
     C                   eval      *in90 = *off
     C                   endif
     C                   write     setsumd
     C                   add       w1scub        ttlcub
     C                   add       w1swgt        ttlwgt
     C                   add       w1spcs        ttlpcs
     *
     *       Summary totals.
     *
     C                   if        s = 9
     C                   eval      s = 1
     C                   else
     C                   add       1             s
     C                   endif
     C                   eval      l = s
     C                   write     setsuml
     *
     C                   if        s = 9
     C                   eval      s = 1
     C                   else
     C                   add       1             s
     C                   endif
     C                   eval      l = s
     C                   write     setsumt
     C                   endif
     *
     *
     *  End of transaction, force print.
     *
     C                   eval      lcount = lmax
     C                   write     setfoot
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST1   Test 1 - Print label definitions
     *
     C     test1         begsr
     *
     C                   eval      oppdev = *blanks
     C                   movel     'LABELS'      oppdev
     C                   eval      oppfrm = *blanks
     C                   movel     '*STD'        oppfrm
     C                   exsr      opnprt
     *
     C                   endsr
     *----------------------------------------------------------------
     *
415 A*  ZZOFLO  Page Overflow
     *
415 AC     zzoflo        begsr
     C                   eval      wrkcnt = 0
     C                   eval      lins = 0
     *  Count how many CW lines to be printed.
     C                   if        itcwgt = 'Y'
720bMC     lbqpck        div       8             lins
     C                   mvr                     remain
     C                   if        remain <> 0
     C                   add       1             lins
     C                   endif
     C                   endif
     *  Add CW lines to be printed to line count.
     C     lincnt        add       lins          wrkcnt
415aM*  Go to next page, if total count >= 27.
415aMC                   if        wrkcnt >= 27
     C                   eval      *in90 = *on
415aAC                   eval      lincnt = 0
GFCaAC                   select
GFCaAC                   when      client = glazier
GFCaAC                   write     sethdgfc
GFCaAC                   other
     C                   write     sethd
GFCaAC                   endsl
CWDaAC                   select
CWDaAC                   when      client = cashwa
CWDaAC                   write     sethcwd
CWDaAC                   other
     C                   write     sethed2
720aAC                   write     sethd2Bold
CWDaAC                   endsl
     C                   eval      *in90 = *off
     C                   endif
     *
415 AC                   endsr
HKWaA*----------------------------------------------------------------
HWKaA*  getORDHM  Get Order Header Miscellaneous Record.
HKWa *----------------------------------------------------------------
HKWaAC     getORDHM      begsr

     C     keyodh        chain     ordhm

     C                   select
     C                   when      not %found(ordhm)
     C                   eval      ProduceCde = *blanks

     C                   when      client = hkw
     C                   eval      ProduceCde = %subst(hmmsc5:1:3)

     C                   other
     C                   eval      ProduceCde = *blanks
     C                   endsl

HKWaAC                   endsr
640dA*----------------------------------------------------------------
640dA*  getORDDM  Get Order Detail Misc Record.
640dA*----------------------------------------------------------------
640dAC     getORDDM      begsr

640dAC     keyodm        chain     orddm

640dAC                   select
640dAC                   when      not %found(orddm)
640dAC                   eval      w1note = *blanks
CWDaAC                   eval      cwddm1_qoh  = *zeros
     *
TPSaAC                   when      client = tps
TPSaAC                   eval      w1note = ommsc5
     *
CWDaAC                   when      client = cashwa
CWDaAC                   eval      cwddm1_base = ommsc1
     *
640cAC                   other
640cAC                   eval      w1note = *blanks
640cAC                   endsl
640cA
640cAC                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**   OVRPRTF statment
OVRPRTF FILE(PLST40PCF) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
) FORMTYPE(
