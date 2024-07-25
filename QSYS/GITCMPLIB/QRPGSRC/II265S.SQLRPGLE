      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  II265S    Stage Import - Item updates
     *  21 January 2011
     *  Dave Sommerville
     *
     *  This program was based on II265. All II265 revision comments
     *  were kept in this program. See 640 notes.
     *
     *      For add or change, can not update ITEMDEF records,
     *      user will need to make any changes in item maintenance.
     *
     *----------------------------------------------------------------
     *
416 A*    01/23/03  HNK  4.16
     *      - Delete records from UPC file, if item is deleted.
     *
417aA*    04/03/03  RH   4.17a
     *      - Recompiled, ITEMMSC file changed.
     *      - Add IUODAY to IMPFITMN file. (HNK)
417bA*    06/17/03  DAS/MLB  4.17b
     *      - When deleting, revised to check ITEMQTY for base item.
     *        If quantity exists, item cannot be deleted.
417cA*    06/17/03  DAS/MLB  4.17c
     *      - Revised routine ZZCHKI to only allow the item type to
     *        change from 'A' to ' '.
     *      - Added new DESC message for invalid item type changes.
     *      - Revised routine ZZUPD1 to always try to delete ITEMLNK
     *        record for a Normal item. This will get rid of the
     *        ITEMLNK record when an item is changed from 'A' to ' '.
417dA*    06/17/03  DAS/MLB  4.17d
     *      - Revised routine ZZUPD1 to create ITEMQTY record when
     *        type changes from Alias to Normal.
417eA*    06/17/03  RH/MLB    4.17e
     *      - Revised routine ZZDELI to skip checks for Alias "A" item
     *      - Revised routine ZZDELI to only check break qty type "S"
417fA*    06/18/03  RH/MLB  4.17f
     *      - ITEMMSC changed, default values in new fields.
     *
510bA*    07/21/06  MLB  5.10b
     *      - Enh: Added client custom code support to program.
     *
600aA*    03/01/09  DAS  6.00a  P#00065
     *     - Enh: Revised to not hardcode IMLTRK license tracking value.
     *     - Enh: Revised to call LT002 at the end of the program to
     *       to set license tracking value of all items that do not
     *       have a valid value.
     *
640aA*    01/12/11  DAS  6.40a
     *      - Converted to ILE.
     *      - Revised to used staging file impsitmn in place of
     *        file impfitmn.
     *
640bA*    02/10/11  DAS  6.40b
     *      - Renamed IUVEN# to IUVEN
     *      - Renamed IUVIT# to IUVITM
640cA*    04/18/11  RH/MLB  6.40c
     *      - Fix: Revised program to update # of pick slots on update
640cA*    04/21/11  MLB  6.40c
     *     - Fix: Revised program when item cube is not updated from
     *        host and item dimensions are imported, to update item cube
     *        when the new computed cube is different from the cube on
     *        file.
640dA*    11/14/12  RTR  6.40d
     *     - Change to use logical so that base/parent items are
     *       created first.
     *
650 A*    08/10/13  MLB  6.50
     *      - Fix: Revised program to unlock record when chaining to
     *        DESIG, UNMESR, ACTIVITY and BLDCODE.
650aA*    02/12/14  MLB  6.50a
     *      - Enh: Revised pgm to add record to ITEMFLD file only when
     *        item doesn't exist. Initialize following new fields:
     *        IFUCICDE, IFRCVMTH, IFSLTMTH and IFBRDFLG.
700a *    07/23/15  RTR  7.00a
     *     - Fix: Revised to pad short unit of measure with blanks
     *        when UoM not found in table.
700bA*    11/02/16  LMC  7.00b
     *      - Recompile only - UPC file changed.
     *
710 A*    03/26/17  MLB  7.10
     *      - Fix: Corrected errors with 4.17f fix. Several ITEMMSC
     *        fields were being cleared when a item was added.
     *      - This patch was missed for this pgm. See 5.30b in II295S.
     *
     *----------------------------------------------------------------
     * Custom changes
     *
CBI A*    10/30/02 HNK CBI
     *      - Temporary change.  Disable error check if dist days is
     *        zero.
     *
CBIaA*    07/15/03 HNK CBIa
     *      - Disable error check if user days is zero.
CBIbA*    09/11/06  MLB  CBIb
     *      - Revised program to transfer item gross weight from
     *        IUBLNK into ITRCVD field which is unused at this time.
CBIcA*    02/09/17  LMC  CBIc
     *      - Revised to call LT313 for date sensitive items to update
     *        license expiration date.
CBIdA*    03/03/17  LMC  CBId
     *      - Added additional logic - CBI # 2017040 - to exclude the
     *        updating of license expiration date if the mfg dated
     *        field is changed.
CBIeA*    06/06/14  MLB  CBIe
     *      - Revised program to change PIRITEM/ITWHDP with value
     *        from file, ITMDIFFD. Not every whse is able to slot
     *        items based on the assigned whse from SAP. Use value
     *        from IDSDPT, if found.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Andrews Foodservice
     *
AFS A*    04/21/11  MLB  AFS
     *      - Revise program to default computed cube to 0.100 if zero.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program assumes that there is only items for one
     *    warehouse in the member.
     *
     *    This program is similar to II225 except for the following:
     *
     *      - Changed import file to IMPFITEM.
     *      - Removed parameter $PWHS.
     *      - Changed all references to $PWHS to IUWHSE.
     *      - Moved execution of ZZINZ2 to within the read loop.
     *        It will only be called after the first read.
     *      - Changed READE to READ.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  61        - Special order (Customer # > 0)
     *  79        - EOF for IMPITEM
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
640aDF*mpfitmn  uf   e           k disk
640dDF*mpsitmn  uf   e           k disk
640dAFimpsitmn1 uf   e           k disk
     Fwarehs    if   e           k disk
     Freports   if   e           k disk
     Fpiritem   uf a e           k disk
     Fitemdsc   uf a e           k disk
     Fitemdef   uf a e           k disk
650aAFitemfld   uf a e           k disk
     Fitemlnk   uf a e           k disk
     Fitemlnk1  if   e           k disk
     F                                     rename(ilrec:record1)
     Fitemmsc   uf a e           k disk
     Foptions   if   e           k disk
     Fitemqty   uf a e           k disk
CBIeAFitmdiffd  uf   e           k disk    usropn
     Fii265pr   o    e             printer oflind(*in91)
411bAFwhdept    if   e           k disk
412 MFdesig     uf a e           k disk
412 MFactivity  uf a e           k disk
412 MFunmesr    uf a e           k disk
412 MFbldcode   uf a e           k disk
416 AFupc1      uf   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
417cAD a30             s              1    dim(30)
417cD*                   DESC    1  44 30
417cMD desc            s             30    dim(45) ctdata perrcd(1)
412 AD cdsc            s             30    dim(1) ctdata perrcd(1)

510bA*----------------------------------------------------------------
510bA*  Client ID
510bA*
     D @getcl          c                   const('GETCLIENT')
500mA*
640aM /COPY QCOPYSRC,ID#CHENEY
AFS A /COPY QCOPYSRC,ID#andrews
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
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lsdef                22     23
     D  $lwhdp                22     26
     D  $litem                22     36
     *
     D  $ldesg                19     23
     *
     D  $lactv                19     20
     *
     D  $lum                  19     20
     *
     D  $lbc                  19     20
     *
     D  $lwhs1                19     21  0
     D  $litm1                22     36
     D  $lwhd1                37     41
     D  $lsty1                42     42
     D  $lst1                 43     44
     D  $lpal1                45     50
     D  $lovr1                51     53  2
     *
     D  $lwhs2                19     21  0
     D  $lwhd2                22     26
     D  $litm2                27     41
     D  $lcnt                 42     44  0
     D  $lrepl                45     45
     D  $lulen                46     50  2
     D  $luwdt                51     55  2
     D  $lstyp                56     56
     *----------------------------------------------------------------
     *  *ITEMMNT  -  Item maintenance options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPSTYP  -  Default section type
     *    OPWHDP  -  Default warehouse department
     *    OPUM1   -  Default normal unit of measure
     *    OPDUM   -  Unit of measure for dimensions
     *    OPCUM   -  Unit of measure for cube
     *    OPCDIV  -  Divisor for cube
     *    OPCAUT  -  Automaticaly calculate cube when zero (Y/N)
     *    OPCWRN  -  Display cube warning (Y/N)
     *    OPCRNG  -  Display cube warning range percentage
     *    OPWUM   -  Unit of measure for weight
     *
     * Data structure
     *
413cD*PDATA      DS
413cMD opdat1          ds
     *                                       1   1 OPSTYP
     *                                       2   6 OPWHDP
     *                                       7   8 OPUM1
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  3
     D  opwum                 58     72
     D  opxdsc                73     73
     D  optend               117    117
     *----------------------------------------------------------------
     *  *IMPITEM  -  Import Item options.
     *----------------------------------------------------------------
     *
     *    Y = Maintained by Host, imported to FSWMS
     * Fields
     *
     *    OPITYP  -  Item type
     *    OPDESC  -  Item description
     *    OPWHDP  -  Warehouse department
     *    OPSTYP  -  Section type
     *    OPWHDP  -  Default warehouse department
     *    OPDESG  -  Designation
     *    OPACTV  -  Activity
     *    OPBLD   -  Build code
     *    OPVEN#  -  Vendor number
     *    OPVIT#  -  Vendor item number
     *    OPPDSC  -  Pack description
     *    OPUM1   -  Normal unit of measure
     *    OPUM2   -  Breakdown 1 unit of measure
     *    OPUMQ2  -  Breakdown 1 UM quantity
     *    OPFLG1  -  Allow Breakdown 1 Sale
     *    OPUM3   -  Breakdown 2 unit of measure
     *    OPUMQ3  -  Breakdown 2 UM quantity
     *    OPFLG2  -  Allow Breakdown 2 Sale
     *    OPULEN  -  Unit length
     *    OPUWDT  -  Unit width
     *    OPUHGT  -  Unit height
     *    OPCUBE  -  Cube/Unit
     *    OPSWGT  -  Shipping weight
     *    OPCWGT  -  Catch weight
     *    OPREPL  -  Replenish level
     *    OPFLGD  -  Date sensitive
     *    OPFLGB  -  Allow bulk pick
     *    OPSLIF  -  Shelf life days
     *    OPNDAY  -  Notice days
     *    OPTIE   -  Mfr. Tie
     *    OPHIGH  -  Mfr. High
     *    OPMFLG  -  Manufacturing date
     *    OPDDAY  -  Distributor days
     *    OPUDAY  -  End user days
     *    OPMDAY  -  Mfr. shelf life days
     *    OPMITM  -  Master item number
     *    OPCITM  -  Contract Base item #
416a *    OPNSLT  -  Non-slotted item
416a *    OPXDCK  -  Crossdock item
416a *    OPBNBR  -  Buyer number
416a *    OPBNAM  -  Buyer name
416a *    OPVNAM  -  Vendor name
416a *    OPBRND  -  Brand
416a *    OPLOT   -  Lot code item
416a *    OPLTRK  -  Track by license
     *
     * Data structure
     *
     D opdat2          ds
     D  opityp                 1      1
     D  opdesc                 2      2
     D  opwhdp                 3      3
     D  opstyp                 4      4
     D  opdesg                 5      5
     D  opactv                 6      6
     D  opbld                  7      7
     D  opven#                 8      8
     D  opvit#                 9      9
     D  oppdsc                10     10
     D  opum1                 11     11
     D  opum2                 12     12
     D  opumq2                13     13
     D  opflg1                14     14
     D  opum3                 15     15
     D  opumq3                16     16
     D  opflg2                17     17
     D  opulen                18     18
     D  opuwdt                19     19
     D  opuhgt                20     20
     D  opcube                21     21
     D  opswgt                22     22
     D  opcwgt                23     23
     D  oprepl                24     24
     D  opflgd                25     25
     D  opflgb                26     26
     D  opslif                27     27
     D  opnday                28     28
     D  optie                 29     29
     D  ophigh                30     30
     D  opmflg                31     31
     D  opdday                32     32
     D  opuday                33     33
     D  opmday                34     34
     D  opmitm                35     35
     D  opcitm                36     36
416a D  opnslt                37     37
416a D  opxdck                38     38
416a D  opbnbr                39     39
416a D  opbnam                40     40
416a D  opvnam                41     41
416a D  opbrnd                42     42
416a D  oplot                 43     43
416a D  opltrk                44     44
     D  opten2               117    117
     *----------------------------------------------------------------
     *  Working Variables
     *
     D actcub          s                   like(itcube)
640aMD addflg          s               n
     D a2nflg          s              1
640aMD chgflg          s               n
     D count           s              3  0
     D eofd            s              1
     D eofi            s              1
     D eofl            s              1
640aMD error           s               n
     D first           s              1
     D forevr          s              1
     D grdord          s              5  0
     D impdte          s              8  0
640aAD importError     s               n
     D imptim          s              6  0
     D itumq3          s              3  0
     D itum2           s              2
     D itum3           s              2
     D kysdef          s              2
     D kywhse          s              3  0
     D len             s              1  0
     D linppg          s              3  0
     D opcode          s              8
     D pflag           s              1
     D pos             s              1  0
     D pxflg           s              1
CBIcAD saveitflgd      s              1
CBIcAD saveimmflg      s              1
640aAD stamp           s               z
640aAD stampUC         s               z
     D svactv          s              2
     D svapck          s              1
     D svbld           s              2
     D svbnam          s             40
     D svbnbr          s              3  0
     D svbrnd          s             10
     D svcube          s              7  3
     D svcwgt          s              1
     D svdday          s              3  0
     D svdesg          s              5
     D svflgb          s              1
     D svflgd          s              1
     D svflg1          s              1
     D svflg2          s              1
     D svhigh          s              2  0
     D svitem          s             15
     D svlot           s              1
     D svltrk          s              1
     D svmday          s              3  0
     D svmflg          s              1
     D svmhig          s              2  0
     D svmtie          s              4  0
     D svnday          s              3  0
     D svnrpk          s              3  0
     D svnslt          s              1
     D svoday          s              3  0
     D svpref          s              1
     D svrcvd          s              8  0
     D svreor          s              5  0
     D svrepl          s              5  0
     D svrg1c          s              3  1
     D svrg2c          s              3  1
     D svsdef          s              2
     D svslif          s              3  0
     D svstyp          s              1
     D svswgt          s              7  2
     D svtie           s              4  0
     D svuday          s              3  0
     D svuhgt          s              5  2
     D svulen          s              5  2
     D svum            s              1
     D svumq2          s              3  0
     D svumq3          s              3  0
     D svum1           s              2
     D svum2           s              2
     D svum3           s              2
     D svupc           s             15
     D svuwdt          s              5  2
     D svven#          s             10  0
     D svvit#          s             15
     D svvnam          s             40
     D svwhdp          s              5
     D svwhse          s              3  0
     D svwrnc          s              1
     D svxdck          s              1
     D tmpcub          s             15  6
     D today           s              8  0
     D work3a          s              3
640aA
640aA*----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
640aAD $pBatId         s             11
640aAD $pReturn        s             10
640aAD $pMessage       s            200
640aA
     *----------------------------------------------------------------
     *  Program info data structure
     *
640aA /copy qcopysrc,c#pgminfds
640aDD*               sds
640aDD* #prog            *proc
640aDD* #job                 244    253
640aDD* #user                254    263
640aDD* #jobn                264    269
640aDD* #jobdt               276    281  0
640aDD* #jobtm               282    287  0

640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

640aA*----------------------------------------------------------------
640aA*  File data data structure
640aA*----------------------------------------------------------------
640aA
640aAD sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
640aA*      $pBatId - Batch id
     *
     *    Returned Parameters
640aA*      $pReturn  - Return code
640aA*      $pMessage - Return message
     *
     *----------------------------------------------------------------

640aAc     *entry        plist
640aAc                   parm                    $pWhse3A
640aAc                   parm                    $pBatId
640aAc                   parm                    $pReturn
640aAc                   parm                    $pMessage
640aA
640aAc                   eval      $pWhse = %dec($pWhse3A: 3: 0)
640aAc                   eval      $pReturn = '*OK'
640aAc                   eval      $pMessage = ' '
640aAC                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *
640aA* Update stgbatch record to start process
640aA*
640aAC                   exsr      zzzStart
640aAC                   if        $pReturn <> '*OK'
640aAC                   return
640aAC                   endif
     *
     * Whip through all the download Update Item records
     *
     C                   eval      first = *on
     C                   eval      pflag = *on
     C                   eval      eofi = *off
     C                   eval      linppg = 55
     C                   eval      count = 0

640dDC**   keyiu         setll     impsitmn
640dMC     keyiu         setll     impsitmn1
     C                   dou       eofi = *on
     *
640aDC**                 read      impfitmn                               79
640dDC**   keyiu         reade     impsitmn                               79
640dMC     keyiu         reade     impsitmn1                              79
     C                   eval      error = *off
     C                   if        *in79
     C                   eval      eofi = *on
640aDC**                 goto      enddiu
640aAC                   leave
     C                   endif
     *
     *  First time through
     *
     C                   if        first = *on
     C                   exsr      zzinz2
     C                   eval      first = *off
     C                   endif
     *
     *  Print report heading if necessary.
     *
     C                   if        pflag = *on  or
     C                             count >= linppg
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   eval      pflag = *off
     C                   endif
640aA*
640aA*  Skip processed records.
640aA*
640aAC                   if        iustatus <> 'R'
640aAC                   iter
640aAC                   endif
     *
     *    Make sure item was entered.
     *
     C                   if        iuitem = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(26)
     C                   goto      enddiu
     C                   endif
     *
     *    Make sure warehouse was entered.
     *
     C                   if        iuwhse = 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(1)
     C                   goto      enddiu
     C                   endif
     *
     * DELETE RECORD OR ERROR CHECK FOR UPDATE/ADD
     C                   if        iuutyp = 'D'
     C                   exsr      zzdeli
     C                   else
     C                   exsr      zzchki
     C                   endif
     *
     C                   if        error = *off  and
     C                             iuutyp <> 'D'
     C                   eval      addflg = *off
     C                   eval      chgflg = *off
     C                   exsr      zzupd
     C                   endif
     *
     C                   if        error = *on  or
     C                             chgflg = *on  or
     C                             addflg = *on
     C                   write     detail
     C                   add       1             count
     C                   endif
     *
     *
     *       Delete detail record from download file
640aA*       Staging file records do not get deleted when processed.
     *
640aDC***                delete    iurec
     *
     C     enddiu        tag

640aAC                   if        error
640aAC                   eval      importError = *on
640aAC                   eval      iustatus = 'E'
640aAC                   eval      iutext   = detmsg
640aAC                   else
640aAC                   eval      iustatus = 'S'
640aAC                   if        addflg or chgflg
640aAC                   eval      iutext = detmsg
640aAC                   else
640aAC                   eval      iutext = ' '
640aAC                   endif
640aAC                   endif
640aAC                   exsr      zzzGetStamps
640aAC                   eval      iuststs = stamp
640aAC                   eval      iustsuc = stampuc
640aAC                   update    iurec

     C                   enddo
     *
     *
     *  Print order grand totals
     *
     C                   if        pflag = *on
     C                   if        count >= linppg
     C                   write     head1
     C                   endif
     C                   write     grndttl
     C                   endif
600aA
600aA*  Set all invalid item license tracking levels.
600aA
600aAC                   call(e)   'LT002'
600aAC                   parm      '*INVALID'    ltCmd             8
600aAC                   parm      iuwhse        ltWhse            3 0
600aAC                   parm                    ltDummy           1
     *
     *  We are finished so get out
     *
640aAC                   exsr      zzzEnd
640aDC**                 eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
510bA*
510bA* Get client id.
510bA*
510bAC                   call      @getcl
510bAC                   parm                    client           10
510bAC                   parm                    cliloc           10
CBIeA*
CBIeAC                   if        client = Cheney
CBIeAC                   if        not %open(itmdiffd)
CBIeAC                   open      itmdiffd
CBIeAC                   endif
CBIeAC                   endif
510bA*
     * Key definitions
640aA*
640aA*  Define key for impsitmn file.
640aA*
640aAC     keyiu         klist
640aAC                   kfld                    $pWhse
640aAC                   kfld                    $pBatId
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem
417bA*
417bA*  Define key for PIRITEM file for base item.
417bA*
417bAC     itkeyb        klist
417bAC                   kfld                    iuwhse
417bAC                   kfld                    #bitem
     *
     *  Define key for PIRITEM file using Master Item.
     *
     C     itkey2        klist
     C                   kfld                    iuwhse
     C                   kfld                    iumitm
     *
     *  Define key for PIRITEM file using Contract Base item.
     *
     C     itkey4        klist
     C                   kfld                    iuwhse
     C                   kfld                    iucitm
     *
     *  Define key for PIRITEM file using Linked Item.
     *
     C     itkey3        klist
     C                   kfld                    iuwhse
     C                   kfld                    ilitm2
650aA*
650aA*  Define key for ITEMFLD file.
650aA*
650aAC     ifkey         klist
650aAC                   kfld                    iuwhse
650aAC                   kfld                    iuitem
     *
     *  Define key for ITEMLNK file.
     *
     C     ilkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem
     *
     *  Define key for ITEMLNK1 file.
     *
     C     il1key        klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem
     *
     *  Define key for ITEMDSC file.
     *
     C     ixkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem
     *
     *  Define key for ITEMDEF file.
     *
     C     idkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem
     C                   kfld                    kysdef
     *
     *  Define key for ITEMDEF file for master item.
     *
     C     idkey2        klist
     C                   kfld                    iuwhse
     C                   kfld                    iumitm
     C                   kfld                    kysdef
     *
     *
     *  Define key for item misc info file.
     *
     C     imkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem
CBIeA*
CBIeA*  Define full key for ITMDIFFD file.
CBIeA*
CBIeAC     keyddp        klist
CBIeAC                   kfld                    ititem
     *
     *
     *  Define key for options file.
     *
     C     optnky        klist
411 D*R                   KFLD           IUWHSE
     C                   kfld                    kywhse
     C                   kfld                    opcode
     *
416 A*  Define key for UPC file.
     *
416 AC     upkey         klist
416 AC                   kfld                    iuwhse
416 AC                   kfld                    iuitem
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKI   Item update error checking.
     *
     C     zzchki        begsr
     C                   eval      error = *off
     *
     *  Begin specific checks when adding a record.
     *
413aD*R         IUUTYP    IFEQ 'A'
     *
     *  For base item, master item must be blank.
     *
     C                   if        iutype = ' '  and
     C                             iumitm <> *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(41)
     C                   goto      endcki
     C                   endif
     *
     *  For Alias, Brkdown, Contract, and Same slot Brkdown,
     *  Master item can't be blank.
     *
     C                   if        iutype = 'A'  or
     C                             iutype = 'B'  or
     C                             iutype = 'C'  or
     C                             iutype = 'S'
     C                   if        iumitm = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(37)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  For Contract breakdown item, Contract base item can't be
     *  blank.
     *
     C                   if        iutype = 'C'
     C     itkey2        chain(n)  piritem                            76
     C                   if        ittype = 'B'  and
     C                             iucitm = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(43)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  For same slot brkdown, base breakdown must be defined.
     *
     C                   if        iutype = 'S'
     C     itkey2        chain(n)  piritem                            76
     C                   if        itum2 = *blanks  and
     C                             itum3 = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(42)
     C                   goto      endcki
     C                   endif
     C                   if        itflg1 = 'Y'  or
413aMC                             itflg2 = 'Y'
413aD**         ITFLG2    ANDEQ'Y'
     C                   eval      error = *on
     C                   eval      detmsg = desc(42)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
413aD*R                   ENDIF
     *
     *
     *  Verify section type.
     *
     C                   if        opstyp = 'Y'
     C                   if        iustyp <> 'F'  and
     C                             iustyp <> 'P'
     C                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify warehouse department.
     *
     C                   if        opwhdp = 'Y'
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = iuwhse
     C                   eval      $lwhdp = iuwhdp
411bD*R                   CALL 'WD900'
411bD*R                   PARM           $LPARM
411bD*R         $LRTN     IFEQ '*ERROR  '
411bAC     keywd         chain     whdept                             75
411bAC                   if        *in75
     C                   eval      error = *on
     C                   eval      detmsg = desc(3)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify designation area (optional).
     *
     C                   if        opdesg = 'Y'  and
     C                             iudesg <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $ldesg = iudesg
411bD*R                   CALL 'DS900'
411bD*R                   PARM           $LPARM
411bD*R         $LRTN     IFEQ '*ERROR  '
411bAC     keyds         chain     desig                              75
411bAC                   if        *in75
412 AC                   eval      dscode = iudesg
412 AC                   eval      dsdesc = cdsc(1)
412 AC                   write     dsrec                                77
413aAC                   add       1             newdsg
412 D*R                   MOVE *ON       ERROR
412 D*R                   MOVE DESC,4    DETMSG
412 D*R                   GOTO ENDCKI
650 AC                   else
650 AC                   unlock    desig
     C                   endif
     C                   endif
     *
     *  Verify activity zone (optional).
     *
     C                   if        opactv = 'Y'  and
     C                             iuactv <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lactv = iuactv
411bD*R                   CALL 'AC900'
411bD*R                   PARM           $LPARM
411bD*R         $LRTN     IFEQ '*ERROR  '
411bAC     keyac         chain     activity                           75
411bAC                   if        *in75
412 AC                   eval      accode = iuactv
412 AC                   eval      acdesc = cdsc(1)
412 AC                   write     acrec                                77
413aAC                   add       1             newact
412 D*R                   MOVE *ON       ERROR
412 D*R                   MOVE DESC,5    DETMSG
412 D*R                   GOTO ENDCKI
650 AC                   else
650 AC                   unlock    activity
     C                   endif
     C                   endif
     *
     *  Verify Date Sensitive option.
     *
     C                   if        opflgd = 'Y'
     C                   if        iuflgd <> 'Y'  and
     C                             iuflgd <> 'N'
412 AC                   eval      iuflgd = 'N'
412 D*R                   MOVE *ON       ERROR
412 D*R                   MOVE DESC,6    DETMSG
412 D*R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify Allow Bulk Pick option.
     *
     C                   if        opflgb = 'Y'
     C                   if        iuflgb <> 'Y'  and
     C                             iuflgb <> 'N'
412 AC                   eval      iuflgb = 'N'
412 D*R                   MOVE *ON       ERROR
412 D*R                   MOVE DESC,7    DETMSG
412 D*R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify vendor number is within range.
     *
     C                   if        opven# = 'Y'
640bMC                   if        iuven < 0  or
640bMC                             iuven > 9999999999
     C                   eval      error = *on
     C                   eval      detmsg = desc(33)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify replenishment level is within range.
     *
     C                   if        oprepl = 'Y'
     C                   if        iurepl < 0  or
     C                             iurepl > 99999
     C                   eval      error = *on
     C                   eval      detmsg = desc(34)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify master item was entered.
     *
411bD*R         ITTYPE    IFEQ 'B'
411bD*R         ITTYPE    OREQ 'A'
411bD*R         ITTYPE    OREQ 'C'
411bD*R         ITTYPE    OREQ 'S'
411bMC                   if        iutype = 'B'  or
411bMC                             iutype = 'A'  or
411bMC                             iutype = 'C'  or
411bMC                             iutype = 'S'
     C                   if        iumitm = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(37)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify full case item.
     *
     C                   if        opmitm = 'Y'
     C                   if        iumitm <> *blanks
413aA*  Full case item number must be different from broken case item.
413aAC                   if        iumitm = iuitem
413aAC                   eval      error = *on
413aAC                   eval      detmsg = desc(10)
413aAC                   goto      endcki
413aAC                   endif
413aA*  Get full case item.
     C     itkey2        chain(n)  piritem                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(8)
     C                   goto      endcki
     C                   endif
     *
     *  Brk 1 quantity must be >0.
     C                   if        not *in79  and
412 AC                             itumq2 <= 0
     C                   if        iutype = 'B'  or
412 AC                             iutype = 'S'
412 D*R         ITUMQ2    ANDLE0
     C                   eval      error = *on
     C                   eval      detmsg = desc(9)
     C                   goto      endcki
     C                   endif
     C                   endif
413aD*  Full case item number must be different from broken case item.
413aD*R         IUMITM    IFEQ IUITEM
413aD*R                   MOVE *ON       ERROR
413aD*R                   MOVE DESC,10   DETMSG
413aD*R                   GOTO ENDCKI
413aD*R                   ENDIF
     C                   endif
     C                   endif
     *
     *  Brk 1 quantity must be >0 if UOM is entered.
     C                   if        opum2 = 'Y'
     C                   if        iuum2 <> *blanks  and
412 MC                             iuumq2 < 0
412 D*R         IUUMQ2    ANDLE0
     C                   eval      error = *on
     C                   eval      detmsg = desc(9)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  UOM must be entered if Brk1 qty is entered.
     C                   if        opumq2 = 'Y'
     C                   if        iuumq2 <> 0  and
     C                             iuum2 = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(9)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify Contract Base item for contract broken case item.
     *
     C                   if        opcitm = 'Y'  and
     C                             iucitm <> *blanks
     C     itkey4        chain(n)  piritem                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(44)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *
     *  Verify Mfg date flag.
     *
     C                   if        opmflg = 'Y'
     C                   if        iumflg <> 'Y'  and
     C                             iumflg <> 'N'
412 AC                   eval      iumflg = 'N'
412 D*R                   MOVE *ON       ERROR
412 D*R                   MOVE DESC,11   DETMSG
412 D*R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify date sensitive flag, if Mfg date flag = 'Y'.
     *
     C                   if        opmflg = 'Y'
     C                   if        opflgd = 'Y'
     C                   if        iumflg = 'Y'  and
     C                             iuflgd <> 'Y'
     C                   eval      error = *on
     C                   eval      detmsg = desc(12)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify mfg shelf life days, if Mfg date flag = 'Y'.
     *
     C                   if        opmday = 'Y'
     C                   if        iumflg = 'Y'  and
     C                             iumday = 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(13)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify distributor days, if Mfg date flag = 'Y'.
CBI D*
CBI D*R         OPDDAY    IFEQ 'Y'
CBI D*R         IUMFLG    IFEQ 'Y'
CBI D*R         IUDDAY    ANDEQ0
CBI D*R                   MOVE *ON       ERROR
CBI D*R                   MOVE DESC,14   DETMSG
CBI D*R                   GOTO ENDCKI
CBI D*R                   ENDIF
CBI D*R                   ENDIF
     *
     *  Verify user days, if Mfg date flag = 'Y'.
     *
CBI D*R         OPUDAY    IFEQ 'Y'
CBI D*R         IUMFLG    IFEQ 'Y'
CBI D*R         IUUDAY    ANDEQ0
CBI D*R                   MOVE *ON       ERROR
CBI D*R                   MOVE DESC,15   DETMSG
CBI D*R                   GOTO ENDCKI
CBI D*R                   ENDIF
CBI D*R                   ENDIF
     C                   endif
     **************
     *
     *  Verify catch weight.
     *
     C                   if        opcwgt = 'Y'
     C                   if        iucwgt <> 'Y'  and
     C                             iucwgt <> 'N'
412 AC                   eval      iucwgt = 'N'
412 D*R                   MOVE *ON       ERROR
412 D*R                   MOVE DESC,16   DETMSG
412 D*R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify normal unit of measure.
     *
     C                   if        opum1 = 'Y'  and
     C                             iuum1 <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lum = iuum1
411bD*R                   CALL 'UM900'
411bD*R                   PARM           $LPARM
411bD*R         $LRTN     IFEQ '*ERROR  '
411bAC     keyum         chain     unmesr                             75
411bAC                   if        *in75
412 AC                   eval      umcode = iuum1
700aDC*                  movel     iuum1         umshrt
700aMC                   movel (p) iuum1         umshrt
412 AC                   eval      umdesc = cdsc(1)
412 AC                   write     umrec                                77
413aAC                   add       1             newum
412 D*R                   MOVE *ON       ERROR
412 D*R                   MOVE DESC,17   DETMSG
412 D*R                   GOTO ENDCKI
650 AC                   else
650 AC                   unlock    unmesr
     C                   endif
     C                   endif
     *
     *  Verify breakdown 1 unit of measure.
     *
     C                   if        opum2 = 'Y'  and
     C                             iuum2 <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lum = iuum2
411bD*R                   CALL 'UM900'
411bD*R                   PARM           $LPARM
411bD*R         $LRTN     IFEQ '*ERROR  '
411bAC     keyum         chain     unmesr                             75
411bAC                   if        *in75
412 AC                   eval      umcode = iuum2
700aDC*                  movel     iuum2         umshrt
700aMC                   movel (p) iuum2         umshrt
412 AC                   eval      umdesc = cdsc(1)
412 AC                   write     umrec                                77
413aAC                   add       1             newum
412 D*R                   MOVE *ON       ERROR
412 D*R                   MOVE DESC,17   DETMSG
412 D*R                   GOTO ENDCKI
650 AC                   else
650 AC                   unlock    unmesr
     C                   endif
     C                   endif
     *
     *  Verify breakdown 1 unit of measure quantity.
     *
     C                   if        opumq2 = 'Y'
     C                   if        iuumq2 < 0  or
     C                             iuumq2 > 999
     C                   eval      error = *on
     C                   eval      detmsg = desc(18)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify breakdown 1 Info Only option.
     *
     C                   if        opflg1 = 'Y'
     C                   if        iuflg1 <> 'Y'  and
     C                             iuflg1 <> 'N'
412 AC                   eval      iuflg1 = 'N'
412 D*R                   MOVE *ON       ERROR
412 D*R                   MOVE DESC,19   DETMSG
412 D*R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify breakdown 2 unit of measure.
     *
     C                   if        opum3 = 'Y'  and
     C                             iuum3 <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lum = iuum3
411bD*R                   CALL 'UM900'
411bD*R                   PARM           $LPARM
411bD*R         $LRTN     IFEQ '*ERROR  '
411bAC     keyum         chain     unmesr                             75
411bAC                   if        *in75
412 AC                   eval      umcode = iuum3
700aDC*                  movel     iuum3         umshrt
700aMC                   movel (p) iuum3         umshrt
412 AC                   eval      umdesc = cdsc(1)
412 AC                   write     umrec                                77
412 D*R                   MOVE *ON       ERROR
412 D*R                   MOVE DESC,17   DETMSG
412 D*R                   GOTO ENDCKI
650 AC                   else
650 AC                   unlock    unmesr
     C                   endif
     C                   endif
     *
     *  Verify breakdown 2 unit of measure quantity.
     *
     C                   if        opumq3 = 'Y'
     C                   if        iuumq3 < 0  or
     C                             iuumq3 > 999
     C                   eval      error = *on
     C                   eval      detmsg = desc(18)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify breakdown 2 Info Only option.
     *
     C                   if        opflg2 = 'Y'
     C                   if        iuflg2 <> 'Y'  and
     C                             iuflg2 <> 'N'
412 AC                   eval      iuflg2 = 'N'
412 D*R                   MOVE *ON       ERROR
412 D*R                   MOVE DESC,19   DETMSG
412 D*R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Dimensions must be within range.
     *
     C                   if        opulen = 'Y'
     C                   if        iuulen < 0  or
     C                             iuulen > 999.99
     C                   eval      error = *on
     C                   eval      detmsg = desc(20)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     C                   if        opuwdt = 'Y'
     C                   if        iuuwdt < 0  or
     C                             iuuwdt > 999.99
     C                   eval      error = *on
     C                   eval      detmsg = desc(20)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     C                   if        opuhgt = 'Y'
     C                   if        iuuhgt < 0  or
     C                             iuuhgt > 999.99
     C                   eval      error = *on
     C                   eval      detmsg = desc(20)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *
     *  Verify shipping weight is within range.
     *
     C                   if        opswgt = 'Y'
     C                   if        iuswgt < 0  or
     C                             iuswgt > 99999.99
     C                   eval      error = *on
     C                   eval      detmsg = desc(22)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify build code.(Optional)
     *
     C                   if        opbld = 'Y'  and
     C                             iubld <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lbc = iubld
411bD*R                   CALL 'BC900'
411bD*R                   PARM           $LPARM
411bD*R         $LRTN     IFEQ '*ERROR  '
411bAC     keybc         chain     bldcode                            75
411bAC                   if        *in75
412 AC                   eval      bccode = iubld
412 AC                   eval      bcseq = 0
412 AC                   eval      bcdesc = cdsc(1)
412 AC                   write     bcrec                                77
413aAC                   add       1             newbld
413aD*R                   MOVE *ON       ERROR
413aD*R                   MOVE DESC,23   DETMSG
413aD*R                   GOTO ENDCKI
650 AC                   else
650 AC                   unlock    bldcode
     C                   endif
     C                   endif
     *
     *  Shelf life must must be >= 0.
     *
     C                   if        opslif = 'Y'
     C                   if        iuslif < 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(24)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Notice days must be >= 0.
     *
     C                   if        opnday = 'Y'
     C                   if        iunday < 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(25)
     C                   goto      endcki
     C                   endif
     C                   endif
417cA*
417cA*  See if item type is changing and if it is ok to do so.
417cA*
417cAC                   if        opityp = 'Y'
417cAC                   exsr      zzchkt
417cAC     error         cabeq     *on           endcki
417cAC                   endif
     *
     C     endcki        endsr
417cA*----------------------------------------------------------------
417cA*
417cA*  ZZCHKT   Check if item type can be changed.
417cA*
417cAC     zzchkt        begsr
417cAC                   eval      a2nflg = *off
417cA*
417cA*  See if import item exists in PIRITEM file.
417cA*
417cAC     itkey         chain(n)  piritem                            79
417cA*
417cA*  If it doesn't, move on.
417cA*
417cAC     *in79         cabeq     *on           endckt
417cA*
417cA*  If type didn't change, move on.
417cA*
417cAC     iutype        cabeq     ittype        endckt
417cA*
417cA*  Only allowed to change from 'A' to ' '.
417cA*
417cAC                   if        ittype = 'A'  and
417cAC                             iutype = ' '
417cAC                   eval      a2nflg = *on
417cAC                   goto      endckt
417cAC                   endif
417cA*
417cA*  For now, everthing else is an error.
417cA*
417cAC                   eval      error = *on
417cAC                   movea     desc(45)      a30
417cAC                   eval      a30(22) = ittype
417cAC                   eval      a30(29) = iutype
417cAC                   movea     a30           detmsg
417cA*
417cAC     endckt        endsr
     *----------------------------------------------------------------
     *
     *  ZZDELI   Item delete.
     *
     C     zzdeli        begsr
     C                   eval      error = *off
     *
     C     itkey         chain(n)  piritem                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(36)
     C                   goto      enddel
     C                   endif
     *
     *   Cannot delete, link record exists.
     *
413aD*R                   SELEC
413aD*R         IUTYPE    WHEQ ' '
413aD*R         IUTYPE    OREQ 'B'
     *
     C     il1key        setll     itemlnk1                           79
     C                   if        not *in79
     C     il1key        reade     itemlnk1                               79
     C                   if        not *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(38)
     C                   goto      enddel
     C                   endif
     C                   endif
413aD*R                   ENDSL
417eAC     ittype        cabeq     'A'           skip1
417bA*
417bA*   Get corresponding base item.
417bA*
417bAC                   exsr      zzgetb
     *
417bD*R                   SELEC
417bD*R         IUTYPE    WHEQ ' '
417bD*R         IUTYPE    OREQ 'B'
417bD*R         IUTYPE    OREQ 'C'
     *
     *   Get item quantity record.
417bA*      for Base item.
     *
417bD*R         ITKEY     CHAINITEMQTY              7978
417bMC     itkeyb        chain     itemqty                            7978
     C                   select
     C                   when      *in78
     C                   eval      error = *on
     C                   eval      detmsg = desc(39)
     C                   goto      enddel
     *
     C                   when      not *in79
     *
     *      Cannot delete if a quantity exists for item.
     *
417eA*      Only check break quantities for breakdown item
417eAC                   if        ittype = 'S'
417eA*
417eAC                   if        iqstk2 <> 0  or
417eAC                             iqstk3 <> 0  or
417eAC                             iqalc2 <> 0  or
417eAC                             iqalc3 <> 0  or
417eAC                             iqhld2 <> 0  or
417eAC                             iqhld3 <> 0  or
417eAC                             iqtri2 <> 0  or
417eAC                             iqtri3 <> 0  or
417eAC                             iqtro2 <> 0  or
417eAC                             iqtro3 <> 0  or
417eAC                             iqord1 <> 0
417eAC                   eval      error = *on
417eAC                   eval      detmsg = desc(39)
417eAC                   goto      enddel
417eAC                   endif
417eAC                   else
417eA*
417eA*      check all quantities for other item types.
     C                   if        iqstk1 <> 0  or
     C                             iqstk2 <> 0  or
     C                             iqstk3 <> 0  or
     C                             iqalc1 <> 0  or
     C                             iqalc2 <> 0  or
     C                             iqalc3 <> 0  or
     C                             iqhld1 <> 0  or
     C                             iqhld2 <> 0  or
     C                             iqhld3 <> 0  or
     C                             iqtri1 <> 0  or
     C                             iqtri2 <> 0  or
     C                             iqtri3 <> 0  or
     C                             iqtro1 <> 0  or
     C                             iqtro2 <> 0  or
     C                             iqtro3 <> 0  or
     C                             iqord1 <> 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(39)
     C                   goto      enddel
     C                   endif
417eAC                   endif
     *
     *      Delete item quantity record.
     *
417bA*       Don't do delete for 'A' and 'S' items
417bA*
417bAC                   if        ittype <> 'A'  and
417bAC                             ittype <> 'S'
     C                   delete    iqrec                                77
417bAC                   endif
     *
     C                   endsl
417bD*R                   ENDSL
     *
     *   Delete ITEMDEF records.
     *
     C     itkey         setll     itemdef
     C                   eval      *in79 = *off
     C                   dou       *in79
     C     itkey         reade     itemdef                              7879
     *
     *     If record is locked then send message back and abort.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      detmsg = desc(40)
     C                   goto      enddel
     C                   endif
     *
     *     Otherwise, delete record.
     *
     C                   if        not *in79
     C                   delete    idrec                                77
     C                   endif
     *
     C                   enddo
     *
     *     Delete ITEMDSC extended description rec.
     *
     C     ixkey         chain     itemdsc                            79
     C                   if        not *in79
     C                   delete    ixrec
     C                   endif
     *
     *     Delete ITEMMSC misc  record
     *
     C     itkey         chain     itemmsc                            79
     C                   if        not *in79
     C                   delete    imrec
     C                   endif
     *
417eAC     skip1         tag
     *
     C                   if        ittype = 'A'  or
     C                             ittype = 'B'  or
     C                             ittype = 'C'  or
     C                             ittype = 'S'
     C     ilkey         chain     itemlnk                            79
     C                   if        not *in79
     C                   delete    ilrec
     C                   endif
     C                   endif
     *
416 AC     upkey         setll     upc1
416 AC                   dow       forevr = forevr
416 AC     upkey         reade     upc1                                   79
416 AC                   if        *in79
416 AC                   leave
416 AC                   endif
416 AC                   delete    uprec
416 AC                   enddo
     *
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   delete    itrec
CBIeAC*
CBIeAC*     Delete ITMDIFFD if found in table.
CBIeAC                   if        client = Cheney
CBIeAC     keyddp        chain     itmdiffd
CBIeAC                   if        %found(itmdiffd)
CBIeAC                   delete    idifrc
CBIeAC                   endif
CBIeA*
CBIeAC                   endif
CBIeA*
     C                   endif
     *
     C     enddel        endsr
     *
     C*----------------------------------------------------------------
CBIeAC*
CBIeA *  ZZDIFF   Load Piritem/Itwhdp with value found in
CBIeA *           Itmdiffd table. Piritem update takes place
CBIeA *           when control goes back to calling statement.
CBIeAC*
CBIeAC     zzdiff        begsr
CBIeAC*
CBIeAC     keyddp        chain     itmdiffd
CBIeAC                   if        %found(itmdiffd)
CBIeAC                   eval      itwhdp = idsdpt
CBIeAC                   endif
CBIeAC*
CBIeAC     enddif        endsr
CBIeA*
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill Item fields.
     *
     C     zzfil1        begsr
     *
     *
     C                   if        opwhdp = 'Y'  and
     C                             iuwhdp <> itwhdp
     C                   eval      detmsg = desc(29)
     C                   eval      chgflg = *on
     C                   endif
     C                   if        opstyp = 'Y'  and
     C                             iustyp <> itstyp
     C                   eval      detmsg = desc(30)
     C                   eval      chgflg = *on
     C                   endif
     C                   if        opdesg = 'Y'  and
     C                             iudesg <> itdesg
     C                   eval      detmsg = desc(31)
     C                   eval      chgflg = *on
     C                   endif
     C                   if        opulen = 'Y'  and
     C                             iuulen <> itulen
     C                   eval      detmsg = desc(32)
     C                   eval      chgflg = *on
     C                   endif
     C                   if        opuwdt = 'Y'  and
     C                             iuuwdt <> ituwdt
     C                   eval      detmsg = desc(32)
     C                   eval      chgflg = *on
     C                   endif
     C                   if        opuhgt = 'Y'  and
     C                             iuuhgt <> ituhgt
     C                   eval      detmsg = desc(32)
     C                   eval      chgflg = *on
     C                   endif
     *
     *  Move fields from download file to PIRITEM fields
     *
     C                   if        opityp = 'Y'
     C                   eval      ittype = iutype
     C                   endif
     C                   if        opdesc = 'Y'
     C                   movel     iudesc        itdesc
     C                   endif
     C                   if        opstyp = 'Y'
     C                   eval      itstyp = iustyp
     C                   endif
     C                   if        opwhdp = 'Y'
     C                   eval      itwhdp = iuwhdp
     C                   endif
     C                   if        opdesg = 'Y'
     C                   eval      itdesg = iudesg
     C                   endif
     C                   if        opactv = 'Y'
     C                   eval      itactv = iuactv
     C                   endif
     C                   if        opflgd = 'Y'
     C                   eval      itflgd = iuflgd
     C                   endif
     C                   if        opflgb = 'Y'
     C                   eval      itflgb = iuflgb
     C                   endif
     C                   eval      itupc = *blanks
     C                   if        opven# = 'Y'
640bMC                   eval      itven# = iuven
     C                   endif
     C                   if        opvit# = 'Y'
640bMC                   eval      itvit# = iuvitm
     C                   endif
     C                   if        oprepl = 'Y'
     C                   eval      itrepl = iurepl
     C                   endif
     C                   if        oppdsc = 'Y'
     C                   eval      itpdsc = iupdsc
     C                   endif
     C                   if        opum1 = 'Y'
     C                   eval      itum1 = iuum1
     C                   endif
     C                   if        opum2 = 'Y'
     C                   eval      itum2 = iuum2
     C                   endif
     C                   if        opumq2 = 'Y'
     C                   eval      itumq2 = iuumq2
     C                   endif
     C                   if        opflg1 = 'Y'
     C                   if        iuum2 = ' '
     C                   eval      itflg1 = 'N'
     C                   else
     C                   eval      itflg1 = iuflg1
     C                   endif
     C                   endif
     C                   if        opum3 = 'Y'
     C                   eval      itum3 = iuum3
     C                   endif
     C                   if        opumq3 = 'Y'
     C                   eval      itumq3 = iuumq3
     C                   endif
     C                   if        opflg2 = 'Y'
     C                   if        iuum3 = ' '
     C                   eval      itflg2 = 'N'
     C                   else
     C                   eval      itflg2 = iuflg2
     C                   endif
     C                   endif
     C                   if        opulen = 'Y'
     C                   eval      itulen = iuulen
     C                   endif
     C                   if        opuwdt = 'Y'
     C                   eval      ituwdt = iuuwdt
     C                   endif
     C                   if        opuhgt = 'Y'
     C                   eval      ituhgt = iuuhgt
     C                   endif
     *
     C                   if        opcube = 'Y'
     C                   eval      itcube = iucube
     C                   else
     C                   if        opulen = 'Y'  and
     C                             opuwdt = 'Y'  and
     C                             opuhgt = 'Y'
     *  Calculate actual cube according to dimensions entered.
     *
     C                   if        opcdiv = 0
     C                   eval      actcub = 0
     C                   else
     C                   eval      tmpcub = itulen * ituwdt
     C                   mult      ituhgt        tmpcub
     C     tmpcub        div(h)    opcdiv        actcub
     C                   endif
AFS A*
AFS AC                   if        client = Andrews
AFS A*
AFS A*      Force default cube so that an item always has cube.
AFS AC                   if        actcub = 0
AFS AC                   eval      actcub = 0.100
AFS AC                   endif
AFS A*
AFS AC                   endif
     *
     *   Use calculated cube if ...
     *      Auto calculate option is 'Y'
413aA*      and Cube is zero
     *      and Cube is not imported from host.
640cA*      or Cube not imported from host and computed cube chg'd.
     *
     C                   if        opcaut = 'Y'  and
640cDC*                            itcube = 0
640bMC                             (itcube = 0
640bAC                             or itcube <> actcub)
     C                   eval      itcube = actcub
     C                   endif
     C                   endif
     C                   endif
     *
     C                   if        opswgt = 'Y'
     C                   eval      itswgt = iuswgt
     C                   endif
     C                   if        opcwgt = 'Y'
     C                   eval      itcwgt = iucwgt
     C                   endif
     C                   if        opbld = 'Y'
     C                   eval      itbld = iubld
     C                   endif
     C                   if        opslif = 'Y'
     C                   eval      itslif = iuslif
     C                   endif
     C                   if        opnday = 'Y'
     C                   eval      itnday = iunday
     C                   endif
CBIbA*
CBIbAC                   if        client = cheney
CBIbA*     Transfer item gross weight into last rcv'd date fld.
CBIbA*     Last received date not used by BFC at this time.
CBIbAC                   eval      itrcvd = iublnk
CBIbA*
CBIbAC                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill Item fields.
     *
     C     zzfil2        begsr
     *
     C                   if        opityp = 'Y'
     C                   eval      ittype = iutype
     C                   endif
     *   Fill PIRITEM using saved base item fields.
     C                   eval      itwhdp = svwhdp
413aAC                   eval      itstyp = svstyp
     C                   eval      itdesg = svdesg
     C                   eval      itactv = svactv
     C                   eval      itupc = svupc
     C                   eval      itbld = svbld
     C                   eval      itven# = svven#
     C                   eval      itvit# = svvit#
     C                   eval      itum1 = svum1
     C                   eval      itum2 = svum2
     C                   eval      itumq2 = svumq2
     C                   eval      itflg1 = svflg1
     C                   eval      itum3 = svum3
     C                   eval      itumq3 = svumq3
     C                   eval      itflg2 = svflg2
     C                   eval      itulen = svulen
     C                   eval      ituwdt = svuwdt
     C                   eval      ituhgt = svuhgt
     C                   eval      itcube = svcube
     C                   eval      itswgt = svswgt
     C                   eval      itcwgt = svcwgt
     C                   eval      itreor = svreor
     C                   eval      itrepl = svrepl
     C                   eval      itrcvd = svrcvd
     C                   eval      itflgd = svflgd
     C                   eval      itflgb = svflgb
     C                   eval      itslif = svslif
     C                   eval      itnday = svnday
     *
412 D*R                   MOVE IUDESC    ITDESC
412 MC                   movel     iudesc        itdesc
     C                   eval      itpdsc = iupdsc
     *
     C                   endsr
417bA*----------------------------------------------------------------
417bA*
417bA*  ZZGETB   Get base item to use for checking ITEMQTY.
417bA*
417bAC     zzgetb        begsr
417bA*
417bA*  Initialize base item info with current item.
417bA*
417bAC                   eval      #bitem = ititem
417bA*
417bA*  If Alias or SSB Item
417bA*   Then get Base item.
417bA*
417bAC                   if        ittype = 'A'  or
417bAC                             ittype = 'S'
417bA*
417bAC                   call      'GETBASE'
417bAC                   parm      itwhse        $gwhse            3 0
417bAC                   parm      ititem        $gitem           15
417bAC                   parm      ' '           #bitem           15
417bAC                   parm                    #bityp            1
417bAC                   parm                    #bdesc           30
417bAC                   parm                    #bpdsc           15
417bAC                   parm                    #bwhdp            5
417bAC                   parm                    #bstyp            1
417bAC                   parm                    #bum              2
417bAC                   parm                    #bum2             2
417bAC                   parm                    #bumq2            3 0
417bAC                   parm                    #bum3             2
417bAC                   parm                    #bumq3            3 0
417bAC                   parm      ' '           #bcitm           15
417bAC                   parm                    #bctyp            1
417bAC                   parm                    #bcdsc           30
417bAC                   parm                    #bcpds           15
417bAC                   parm                    #bcwdp            5
417bAC                   parm                    #bcstp            1
417bAC                   parm                    #bcum             2
417bAC                   parm                    #bcum2            2
417bAC                   parm                    #bcuq2            3 0
417bAC                   parm                    #bcum3            2
417bAC                   parm                    #bcuq3            3 0
417bAC                   parm                    #brtn             8
417bA*
417bAC                   endif
417bA*
417bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
411bA*  Define key for ACTIV file.
     *
     C     keyac         klist
     C                   kfld                    iuactv
     *
411bA*  Define key for BUILD file.
     *
     C     keybc         klist
     C                   kfld                    iubld
     *
411bA*  Define key for DESIG file.
     *
     C     keyds         klist
     C                   kfld                    iudesg
     *
411bA*  Define key for UNMSR file.
     *
     C     keyum         klist
     C                   kfld                    $lum
     *
411bA*  Define key for WHDEPT file.
     *
     C     keywd         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuwhdp
     *
     * Get import date/time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     'II235PR'     rpprtf
     C     rpprtf        chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     iuwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      iuwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     * Initialize grand total fields
     *
     C                   eval      grdord = 0
     C                   eval      grdlin = 0
     *                    Z-ADD0         PREOH
     *                    Z-ADD0         PREOD
     C                   eval      noitem = 0
     C                   eval      badbrk = 0
413aAC                   eval      newdsg = 0
413aAC                   eval      newact = 0
413aAC                   eval      newbld = 0
413aAC                   eval      newum = 0
     *
     *   Get item maintenance options.
     *
     C                   exsr      zzxopt
     *
     *   Get import item fields options.
     *
     C                   eval      kywhse = 0
     C                   eval      opcode = '*IMPITEM'
     C     optnky        chain     options                            79
     C                   if        not *in79
     C                   eval      opdat2 = opdata
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZSVIT   Save PIRITEM fields.
     *
     C     zzsvit        begsr
     *
     *   Save base item fields.
     C                   eval      svwhse = itwhse
     C                   eval      svitem = ititem
     C                   eval      svstyp = itstyp
     C                   eval      svwhdp = itwhdp
     C                   eval      svdesg = itdesg
     C                   eval      svactv = itactv
     C                   eval      svupc = itupc
     C                   eval      svbld = itbld
     C                   eval      svven# = itven#
     C                   eval      svvit# = itvit#
     C                   eval      svum1 = itum1
     C                   eval      svum2 = itum2
     C                   eval      svumq2 = itumq2
     C                   eval      svflg1 = itflg1
     C                   eval      svum3 = itum3
     C                   eval      svumq3 = itumq3
     C                   eval      svflg2 = itflg2
     C                   eval      svulen = itulen
     C                   eval      svuwdt = ituwdt
     C                   eval      svuhgt = ituhgt
     C                   eval      svcube = itcube
     C                   eval      svswgt = itswgt
     C                   eval      svcwgt = itcwgt
     C                   eval      svreor = itreor
     C                   eval      svrepl = itrepl
     C                   eval      svrcvd = itrcvd
     C                   eval      svflgd = itflgd
     C                   eval      svflgb = itflgb
     C                   eval      svslif = itslif
     C                   eval      svnday = itnday
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update for item type.
     *
     C     zzupd         begsr
     *
     C                   select
     *
     *  Base or Broken item type
     C                   when      iutype = ' '  or
     C                             iutype = 'B'
     *  Get PIRITEM record
     *
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   clear                   itrec
     C                   eval      itwhse = iuwhse
     C                   eval      ititem = iuitem
     C                   endif
CBIcA* For Cheney  - Date sensitive items
CBIcAC                   if        client = cheney and
CBIcAc                             itflgd = 'Y'
CBIcAc                   eval      saveitflgd = itflgd
CBIcAc                   else
CBIcAc                   eval      saveitflgd = ' '
CBIcAc                   endif
     *
     C                   exsr      zzfil1
     C                   exsr      zzupd1
     *
     *  Alias and Contract item type
     C                   when      iutype = 'A'  or
     C                             iutype = 'C'  or
     C                             iutype = 'S'
     *
413aD*          IUUTYP    IFEQ 'A'
413aD*  For Add, Get PIRITEM record for Base item
     *
     *
413bA*  If 'S' type record and Normal UOM is not blank
413bA*    Then get base item record for later update.
413bA*    Otherwise get base item record as non-update.
     *
413bAC                   if        iutype = 'S'  and
413bAC                             iuum1 <> ' '
413bAC     itkey2        chain     piritem                            79
413bAC                   else
     C     itkey2        chain(n)  piritem                            79
413bAC                   endif
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(37)
     C                   goto      endupd
     C                   else
     *
413bA*     If 'S' type record and Normal UOM is not blank
413bA*        force 'S' item UM1 into base UM2
413bA*        force 'S' item UM2 into base UM3
413bA*        force 'S' item UM2 QTY into base UM3 QTY
413bA*        update base item record.
413bA*
413bAC                   if        iutype = 'S'  and
413bAC                             iuum1 <> ' '
413bAC                   eval      itum2 = iuum1
413bAC                   eval      itum3 = iuum2
413bAC                   eval      itumq3 = iuumq2
CBIeA*
CBIeA*     Find out if item is found in Itmdiffd table.
CBIeAC                   if        client = Cheney
CBIeAC                   exsr      zzdiff
CBIeAC                   endif
CBIeAC*
413bAC                   update    itrec
413bAC                   endif
     C                   exsr      zzsvit
     C                   endif
     *  For Add, Get ITEMMSC record for Base item
     C     itkey2        chain(n)  itemmsc                            79
     *   Save base record for ITEMMSC file
413bAC                   if        *in79
413bAC                   eval      svmtie = 0
413bAC                   eval      svmhig = 0
413bAC                   eval      svmflg = *blanks
413bAC                   eval      svdday = 0
413bAC                   eval      svuday = 0
413bAC                   eval      svmday = 0
413bAC                   eval      svwrnc = *blanks
413bAC                   eval      svrg1c = 0
413bAC                   eval      svrg2c = 0
413bAC                   eval      svapck = *blanks
413bAC                   eval      svnrpk = 0
416 AC                   eval      svnslt = 'N'
416 AC                   eval      svxdck = 'N'
416 AC                   eval      svbnbr = 0
416 AC                   eval      svbnam = *blanks
416 AC                   eval      svvnam = *blanks
416 AC                   eval      svbrnd = *blanks
416 AC                   eval      svlot = 'N'
416 AC                   eval      svltrk = 'N'
413bAC                   else
     C                   eval      svmtie = imtie
     C                   eval      svmhig = imhigh
     C                   eval      svmflg = immflg
     C                   eval      svdday = imdday
     C                   eval      svuday = imuday
     C                   eval      svmday = immday
413aAC                   eval      svwrnc = imwrnc
413aAC                   eval      svrg1c = imrg1c
413aAC                   eval      svrg2c = imrg2c
413aAC                   eval      svapck = imapck
413aAC                   eval      svnrpk = imnrpk
416 AC                   eval      svnslt = imnslt
416 AC                   eval      svxdck = imxdck
416 AC                   eval      svbnbr = imbnbr
416 AC                   eval      svbnam = imbnam
416 AC                   eval      svvnam = imvnam
416 AC                   eval      svbrnd = imbrnd
416 AC                   eval      svlot = imlot
416 AC                   eval      svltrk = imltrk
413aD**                   ENDIF
413bAC                   endif
     *
     C     itkey         chain     piritem                            79
412 D*          IUUTYP    IFEQ 'A'
412 D*          *IN79     ANDEQ*OFF
412 D*R                   MOVE *ON       ERROR
412 D*R                   MOVE DESC,27   DETMSG
412 D*R                   GOTO ENDUPD
412 D*                    ENDIF
     C                   if        *in79
     C                   clear                   itrec
     C                   eval      itwhse = iuwhse
     C                   eval      ititem = iuitem
     C                   endif
     *
     C                   exsr      zzfil2
     C                   exsr      zzupd2
     *
     C                   endsl
     *
     C     endupd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update files for item type ' ' or 'B'
     *
     C     zzupd1        begsr
     *
411  *   Add record
     *
     C                   if        *in79
CBIeA*
CBIeA*     Find out if item is found in Itmdiffd table.
CBIeAC                   if        client = Cheney
CBIeAC                   exsr      zzdiff
CBIeAC                   endif
CBIeA*
     C                   write     itrec                                77
     C                   if        *in77
     C                   eval      error = *on
     C                   eval      detmsg = desc(27)
     C                   goto      endup1
     C                   endif
     *
     C                   eval      addflg = *on
     C                   eval      detmsg = desc(28)
     *
     *       Add record to item quantity file.
     *
     C                   clear                   iqrec
     C                   eval      iqwhse = iuwhse
     C                   eval      iqitem = iuitem
     C                   write     iqrec                                77
     C                   if        *in77
     C                   eval      error = *on
     C                   eval      detmsg = desc(35)
     C                   goto      endup1
     C                   endif
     *
     C                   else
CBIeA*
CBIeA*     Find out if item is found in Itmdiffd table.
CBIeAC                   if        client = Cheney
CBIeAC                   exsr      zzdiff
CBIeAC                   endif
CBIeA*
     C                   update    itrec
     C                   endif
417dA*
417dA*   Add record to item quantity file when type changes.
417dA*     If error occurs, assume record already exists.
417dA*
417dAC                   if        a2nflg = *on
417dAC                   clear                   iqrec
417dAC                   eval      iqwhse = iuwhse
417dAC                   eval      iqitem = iuitem
417dAC                   write     iqrec                                77
417dAC                   endif
     *
     *
     *   Add record to ITEMDSC file.
     *
     C                   if        opdesc = 'Y'  and
     C                             pxflg = '1'
     C     ixkey         chain     itemdsc                            76
     C                   movel     iudesc        ixdsc1
     C                   move      iudesc        ixdsc2
     C                   if        not *in76
     C                   update    ixrec
     C                   else
     C                   eval      ixwhse = itwhse
     C                   eval      ixitem = ititem
     C                   write     ixrec
     C                   endif
     C                   endif
     *
     *   Add/Change record to ITEMMSC file.
     *
     C     imkey         chain     itemmsc                            79
CBIcA* For Cheney  - Date sensitive items
CBIcAC                   if        client = cheney and
CBIcAc                             saveitflgd = 'Y'
CBIcAc                   eval      saveimmflg = immflg
CBIcA * we will only update if both the
CBIcA * End user days & Mfr shelf life days are setup to be imported
CBIcAc                   if        opuday = 'Y' and opmday = 'Y'
CbIdAc* don't execute license expiration udpate if the mfg dated
CbIdAc* item flag has changed.
CBIdAc                   if        immflg = iumflg
CBIcAc                   exsr      zzUpdExpDate
CBIdAc                   endif
CBIcAc                   endif
CBIcAc                   else
CBIcAc                   eval      saveimmflg = ' '
CBIcAc                   endif
     C                   if        optie = 'Y'
     C                   eval      imtie = iutie
     C                   endif
     C                   if        ophigh = 'Y'
     C                   eval      imhigh = iuhigh
     C                   endif
     C                   if        opmflg = 'Y'
     C                   eval      immflg = iumflg
     C                   endif
     C                   if        opdday = 'Y'
     C                   eval      imdday = iudday
     C                   endif
     C                   if        opuday = 'Y'
     C                   eval      imuday = iuuday
     C                   endif
     C                   if        opmday = 'Y'
     C                   eval      immday = iumday
     C                   endif
416  C                   if        opnslt = 'Y'
416  C                   eval      imnslt = iunslt
416  C                   endif
416  C                   if        opxdck = 'Y'
416  C                   eval      imxdck = iuxdck
416  C                   endif
416  C                   if        opbnbr = 'Y'
416  C                   eval      imbnbr = iubnbr
416  C                   endif
416  C                   if        opbnam = 'Y'
416  C                   eval      imbnam = iubnam
416  C                   endif
416  C                   if        opvnam = 'Y'
416  C                   eval      imvnam = iuvnam
416  C                   endif
416  C                   if        opbrnd = 'Y'
416  C                   eval      imbrnd = iubrnd
416  C                   endif
416  C                   if        oplot = 'Y'
416  C                   eval      imlot = iulot
416  C                   endif
640cA*
640cAC                   select
640cAC                   when      iustyp = 'P'
640cAC                   eval      imnrpk = *zeros
640cA*
640cAC                   when      iustyp = 'F' and
640cAC                             imnrpk = 0
640cAC                   eval      imnrpk = 1
640cAC                   endsl
640cA*
600aDC**                 if        opltrk = 'Y'
600aDC**                 eval      imltrk = iultrk
600aDC**                 endif
417aAC                   eval      imoday = iuoday
414 D**                   MOVE 'Y'       IMWRNC
414 D**                   Z-ADD0         IMRG1C
414 D**                   Z-ADD0         IMRG2C
414 D**                   MOVE 'N'       IMAPCK
414 D**                   Z-ADD0         IMNRPK
     C                   if        not *in79
     C                   update    imrec
     C                   else
414 AC                   eval      imwrnc = 'Y'
710 DC*                  eval      imrg1c = 0
710 MC                   eval      imrg1c = iurg1c
710 DC*                  eval      imrg2c = 0
710 MC                   eval      imrg2c = iurg2c
414 AC                   eval      imapck = 'N'
     C                   eval      imwhse = iuwhse
     C                   eval      imitem = iuitem
412bAC                   if        iustyp = 'F'
415  C                   eval      imnrpk = 1
412bAC                   else
412bAC                   eval      imnrpk = *zeros
412bAC                   endif
710 AC                   if        iunslt = ' '
417fAC                   eval      imnslt = 'N'
710 AC                   endif
710 AC                   if        iuxdck = ' '
417fAC                   eval      imxdck = 'N'
710 AC                   endif
710 AC                   if        iubnbr = 0
417fAC                   eval      imbnbr = 0
710 AC                   endif
710 AC                   if        iubnam = ' '
417fAC                   eval      imbnam = *blanks
710 AC                   endif
710 AC                   if        iuvnam = ' '
417fAC                   eval      imvnam = *blanks
710 AC                   endif
710 AC                   if        iubrnd = ' '
417fAC                   eval      imbrnd = *blanks
710 AC                   endif
710 AC                   if        iulot = ' '
710 AC                             or oplot = 'N'
417fAC                   eval      imlot = 'N'
710 AC                   endif
600aDC*                  eval      imltrk = 'N'
417aAC                   eval      imoday = iuoday
     C                   write     imrec
     C                   endif
     *   Save base record for ITEMMSC file
     C                   eval      svmtie = imtie
     C                   eval      svmhig = imhigh
     C                   eval      svmflg = immflg
     C                   eval      svdday = imdday
     C                   eval      svuday = imuday
     C                   eval      svmday = immday
413aAC                   eval      svwrnc = imwrnc
413aAC                   eval      svrg1c = imrg1c
413aAC                   eval      svrg2c = imrg2c
413aAC                   eval      svapck = imapck
413aAC                   eval      svnrpk = imnrpk
416 AC                   eval      svnslt = imnslt
416 AC                   eval      svxdck = imxdck
416 AC                   eval      svbnbr = imbnbr
416 AC                   eval      svbnam = imbnam
416 AC                   eval      svvnam = imvnam
416 AC                   eval      svbrnd = imbrnd
416 AC                   eval      svlot = imlot
600aDC**                 eval      svltrk = imltrk
417aAC                   eval      svoday = imoday
650aA*
650aA*
650aA*   Add record to ITEMFLD file.
650aAC     ifkey         chain     itemfld
650aAC                   if        not %found(itemfld)
650aAC                   eval      ifwhse    = iuwhse
650aAC                   eval      ifitem    = iuitem
650aAC                   eval      ifcat     = ' '
650aAC                   eval      ifcaseovf = 'N'
650aAC                   eval      ifodrslot = ' '
650aAC                   eval      ifucicde  = '1'
650aAC                   eval      ifrcvmth  = '1'
650aAC                   eval      ifsltmth  = '1'
650aAC                   eval      ifbrdflg  = 'N'
650aAC                   write     ifrec
650aA*
650aAC                   else
650aA*
650aAC                   unlock    itemfld
650aAC                   endif
     *
     *
     *   Add record to ITEMLNK file.
417cA*     for Brokencase item.
     *
     C                   select
     C                   when      iutype = 'B'
     *
     C                   if        opmitm = 'Y'  and
     C                             iumitm <> *blanks
     C     ilkey         chain     itemlnk                            79
     C                   eval      ilitm2 = iumitm
     C                   if        *in79
     C                   eval      ilwhse = iuwhse
     C                   eval      ilitem = iuitem
     C                   write     ilrec
     C                   else
     C                   update    ilrec
     C                   endif
     C                   endif
     *
     *   Delete record from ITEMLNK file.
417cA*     for Normal item.
417cA*
417cAC                   other
     *
417cD*R         OPMITM    IFEQ 'Y'
417cD*R         IUMITM    ANDEQ*BLANKS
     C     ilkey         chain     itemlnk                            79
     C                   if        not *in79
     C                   delete    ilrec
     C                   endif
417cD*R                   ENDIF
     *
     C                   endsl
     *
     *   Update any dependent file if update type = Change
     *
     C                   select
     C                   when      iuutyp = 'C'
     *   Save base item fields.
     C                   exsr      zzsvit
     C                   eval      eofl = *off
     C     ilkey         setll     itemlnk1
     C                   dou       eofl = *on
     *
     C     ilkey         reade     itemlnk1                               75
     C                   if        *in75
     C                   eval      eofl = *on
     C                   goto      endup1
     *
     C     itkey3        chain     piritem                            79
     C                   if        *in79
     C                   goto      endup1
     C                   endif
     C                   if        ittype = 'A'  or
     C                             ittype = 'C'  or
     C                             ittype = 'S'
     *   Create PIRITEM using saved base item fields.
     C                   eval      itwhdp = svwhdp
CBIeA*
CBIeA*     Find out if item is found in Itmdiffd table.
CBIeAC                   if        client = Cheney
CBIeAC                   exsr      zzdiff
CBIeAC                   endif
CBIeA*
413aAC                   eval      itstyp = svstyp
     C                   eval      itdesg = svdesg
     C                   eval      itactv = svactv
     C                   eval      itupc = svupc
     C                   eval      itbld = svbld
     C                   eval      itven# = svven#
     C                   eval      itvit# = svvit#
     C                   eval      itum1 = svum1
     C                   eval      itum2 = svum2
     C                   eval      itumq2 = svumq2
     C                   eval      itflg1 = svflg1
     C                   eval      itum3 = svum3
     C                   eval      itumq3 = svumq3
     C                   eval      itflg2 = svflg2
     C                   eval      itulen = svulen
     C                   eval      ituwdt = svuwdt
     C                   eval      ituhgt = svuhgt
     C                   eval      itcube = svcube
     C                   eval      itswgt = svswgt
     C                   eval      itcwgt = svcwgt
     C                   eval      itreor = svreor
     C                   eval      itrepl = svrepl
     C                   eval      itrcvd = svrcvd
     C                   eval      itflgd = svflgd
     C                   eval      itflgb = svflgb
     C                   eval      itslif = svslif
     C                   eval      itnday = svnday
     C                   update    itrec
     *
     C     itkey3        chain     itemmsc                            79
     C                   if        *in79
     C                   goto      endup1
     C                   endif
     *   Create ITEMMSC using saved base item fields.
     C                   eval      imtie = svmtie
     C                   eval      imhigh = svmhig
     C                   eval      immflg = svmflg
     C                   eval      imdday = svdday
     C                   eval      imuday = svuday
     C                   eval      immday = svmday
413aAC                   eval      imwrnc = svwrnc
413aAC                   eval      imrg1c = svrg1c
413aAC                   eval      imrg2c = svrg2c
413aAC                   eval      imapck = svapck
413aAC                   eval      imnrpk = svnrpk
416 AC                   eval      imnslt = svnslt
416 AC                   eval      imxdck = svxdck
416 AC                   eval      imbnbr = svbnbr
416 AC                   eval      imbnam = svbnam
416 AC                   eval      imvnam = svvnam
416 AC                   eval      imbrnd = svbrnd
416 AC                   eval      imlot = svlot
600aDC**                 eval      imltrk = svltrk
417aAC                   eval      imoday = svoday
     C                   endif
     *
     C                   endif
     C     endup1        tag
     C                   enddo
     C                   endsl
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update files for item type 'A' or 'C'
     *
     C     zzupd2        begsr
     *
411  *   Add record
     *
     C                   if        *in79
CBIeA*
CBIeA*     Find out if item is found in Itmdiffd table.
CBIeAC                   if        client = Cheney
CBIeAC                   exsr      zzdiff
CBIeAC                   endif
CBIeA*
     C                   write     itrec                                77
     C                   if        *in77
     C                   eval      error = *on
     C                   eval      detmsg = desc(27)
     C                   goto      endup2
     C                   endif
     *
     C                   eval      addflg = *on
     C                   eval      detmsg = desc(28)
     *
     C                   else
CBIeA*
CBIeA*     Find out if item is found in Itmdiffd table.
CBIeAC                   if        client = Cheney
CBIeAC                   exsr      zzdiff
CBIeAC                   endif
CBIeA*
     C                   update    itrec
     C                   endif
     *
     *
     *   Add record to ITEMDSC file.
     *
     C                   if        opdesc = 'Y'  and
     C                             pxflg = '1'
     C     ixkey         chain     itemdsc                            76
     C                   movel     iudesc        ixdsc1
     C                   move      iudesc        ixdsc2
     C                   if        not *in76
     C                   update    ixrec
     C                   else
     C                   eval      ixwhse = itwhse
     C                   eval      ixitem = ititem
     C                   write     ixrec
     C                   endif
     C                   endif
     *
     *   Add/Change record to ITEMMSC file.
     *
     C     itkey         chain     itemmsc                            79
412 D*R         *IN79     IFEQ *ON
     C                   eval      imwhse = iuwhse
     C                   eval      imitem = iuitem
     *   create using saved base fields.
     C                   eval      imtie = svmtie
     C                   eval      imhigh = svmhig
     C                   eval      immflg = svmflg
     C                   eval      imdday = svdday
     C                   eval      imuday = svuday
     C                   eval      immday = svmday
413aAC                   eval      imwrnc = svwrnc
413aAC                   eval      imrg1c = svrg1c
413aAC                   eval      imrg2c = svrg2c
413aAC                   eval      imapck = svapck
413aAC                   eval      imnrpk = svnrpk
416 AC                   eval      imnslt = svnslt
416 AC                   eval      imxdck = svxdck
416 AC                   eval      imbnbr = svbnbr
416 AC                   eval      imbnam = svbnam
416 AC                   eval      imvnam = svvnam
416 AC                   eval      imbrnd = svbrnd
416 AC                   eval      imlot = svlot
416 AC                   eval      imltrk = svltrk
     *
412 AC                   if        *in79
412bAC                   eval      imnrpk = *zeros
     C                   write     imrec
412 AC                   else
412 AC                   update    imrec
     C                   endif
     **
     *   Add record to ITEMDEF file using base fields.
     *
412 A*     First, delete an existing ITEMDEF records.
412 A*
412 AC     itkey         setll     itemdef
412 AC                   eval      *in79 = *off
412 AC                   dou       *in79
412 AC     itkey         reade     itemdef                                79
412 AC                   if        not *in79
412 AC                   delete    idrec                                77
412 AC                   endif
412 AC                   enddo
412 A*
412 A*     Then add the ITEMDEF records.
412 A*
     C                   eval      eofd = *off
     C     itkey2        setll     itemdef
     C                   dou       eofd = *on
     *
     C     itkey2        reade(n)  itemdef                                75
     C                   if        *in75
     C                   eval      eofd = *on
     C                   goto      enddu2
     C                   endif
     *   Save ITEMDEF base item fields.
     *R                   Z-ADDIDWHSE    SVWHSE  30
     *R                   MOVE IDITEM    SVITEM 15
     C                   eval      svsdef = idsdef
     C                   move      idtie         svtie
     C                   move      idhigh        svhigh
     C                   eval      svum = idum
     C                   eval      svpref = idpref
     C                   eval      kysdef = svsdef
     C     idkey         chain     itemdef                            75
     C                   eval      idwhse = iuwhse
     C                   eval      iditem = iuitem
     C                   eval      idsdef = svsdef
     C                   move      svtie         idtie
     C                   move      svhigh        idhigh
     C                   eval      idum = svum
     C                   eval      idpref = svpref
412 AC                   if        *in75
     C                   write     idrec
412 AC                   else
412 AC                   update    idrec
412 AC                   endif
     *
412 MC     idkey2        setgt     itemdef
     C     enddu2        tag
     C                   enddo
     *
     *   Add record to ITEMLNK file.
     *
     *
     C                   if        opmitm = 'Y'  and
     C                             iumitm <> *blanks
     C     ilkey         chain     itemlnk                            79
     C                   eval      ilitm2 = iumitm
     C                   if        *in79
     C                   eval      ilwhse = iuwhse
     C                   eval      ilitem = iuitem
     C                   write     ilrec
     C                   else
     C                   update    ilrec
     C                   endif
     C                   endif
     *
     *   Delete record from ITEMLNK file.
     *
     C                   if        opmitm = 'Y'  and
     C                             iumitm = *blanks
     C     ilkey         chain     itemlnk                            79
     C                   if        not *in79
     C                   delete    ilrec
     C                   endif
     C                   endif
     *
     *       Add record to item quantity file for Contract item.
     *
     C                   if        iutype = 'C'
413aD**         IUUTYP    ANDEQ'A'
412 AC     itkey         chain     itemqty                            79
412 AC                   if        *in79
     C                   clear                   iqrec
     C                   eval      iqwhse = iuwhse
     C                   eval      iqitem = iuitem
     C                   write     iqrec                                77
     C                   if        *in77
     C                   eval      error = *on
     C                   eval      detmsg = desc(35)
     C                   goto      endup2
     C                   endif
412 AC                   endif
     C                   endif
     *
     C     endup2        tag
     *
     C                   endsr
     *
CBIcA*
CBIcA*----------------------------------------------------------------
CBIcA*
CBIcA*  ZZUPDEXPDATE - Updates license/slot expiration dates
CBIcA*
CBIcAC     ZZUpdExpDate  begsr
CBIcAC                   call      'LT313'
CBIcAC                   parm      $pWhse        ltWhse            3 0
CBIcAC                   parm      iuitem        ltItem           15
CBIcAC                   parm      saveitflgd    ltitflgd          1
CBIcAC                   parm      saveimmflg    ltimmflg          1
CBIcAC                   parm      imuday        ltoldimuday       3 0
CBIcAC                   parm      iuuday        ltnewimuday       3 0
CBIcAC                   parm      immday        ltoldimmday       3 0
CBIcAC                   parm      iumday        ltnewimmday       3 0
CBIcAC                   parm                    $pReturn
CBIcAC                   parm                    $pMessage
CBIcAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
     C                   eval      kywhse = iuwhse
     C                   eval      pxflg = *off
     C                   eval      opcode = '*ITEMMNT'
     *
     C     optnky        chain     options                            79
     C                   if        not *in79
413cAC                   eval      opdat1 = opdata
     C                   if        opxdsc = 'Y'
413 D*R                   MOVE '1'       UXFLAG  1
413 MC                   eval      pxflg = *on
     C                   endif
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
      /free

        if importError;
          sbstatus = 'E';
          sbtext   = 'Import completed with error(s). See impsitmn file.';
          $pReturn = '*ERROR';
          $pMessage = sbtext;
        else;
          sbstatus = 'S';
          sbtext   = 'Import completed successfully';
        endif;

        exec sql
          update stgbatch
          set sbstatus = :sbstatus,
              sbtext   = :sbtext,
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = %trimr(sbtext) + ' - '
                    + 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- ii265s/zzzend';
          leavesr;
        endif;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetStamps   Get timestamps
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetStamps  begsr
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
              sbtext   = 'Import started',
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

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
*INVALID WAREHOUSE
*INVALID SECTION
*INVALID DEPARTMENT
*INVALID DESIGNATION
*INVALID ACTIVITY
*INVALID DATE SENSITIVE
*INVALID BULK PICK OPT.
*INVALID MASTER ITEM
*INVALID BREAKDOWN QTY
*INVALID ITEM & MASTER
*MANUFACTURER DATE FLAG
*INVALID DATE SENSITIVE
*INVALID MFG SHELF DAYS
*INVALID DIST. DAYS
*INVALID USER DAYS
*INVALID CATCH WEIGHT
*INVALID UNIT MEASURE
*INVALID UOM QUANTITY
*INVALID ALLOW BRK SALE
*INVALID DIMENSIONS
*INVALID CUBE
*INVALID SHIP WEIGHT
*INVALID BUILD CODE
*INVALID SHELF LIFE
*INVALID NOTICE DAYS
*INVALID ITEM
*ERROR ADDING RECORD
*ADDED RECORD
*DEPT CHANGED
*SECTION CHANGED
*DESIGNATION CHANGED
*DIMENSIONS CHANGED
*INVALID VENDOR #
*INVALID REPLENISHMENT LEVEL
*ERROR ADDING ITEMQTY RECORD
*DELETE RECORD NOT FOUND
*MISSING MASTER ITEM
*ERROR DELETING-ITEMLNK EXISTS
*ERROR DELETING-ITEMQTY EXISTS
*ERROR DELETING ITEMDEF RECORD
*MASTER ITEM MUST BE BLANK
*BREAKDOWN NOT DEFINED
*CONTRACT BASE ITEM MISSING
*INVALID CONTRACT BASE ITEM
*CANT CHG TYPE FROM 'X' TO 'Y'
**
*Auto created by item update*
