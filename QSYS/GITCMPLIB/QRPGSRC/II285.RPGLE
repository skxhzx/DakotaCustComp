RFS A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  II285     FTP - Import item updates - Ver 3
     *  21 February 2006
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *      For add or change, can not update ITEMDEF records,
     *      user will need to make any changes in item maintenance.
     *
     *      This program is a mirror of II265.
     *      - Uses IMPFITM3 to process ITEMMSC fields added in 4.16.
     *
     *----------------------------------------------------------------
     *
500 A*    02/21/060 MLB  5.00
     *      - Created.
     *
510 A*    07/10/06  RH/MLB  5.10
     *      - Fix: Change to not send to ENDUP1 tag, added ENDUPI tag
     *        could not be converted to JAVA.
510bA*    07/21/06  MLB  5.10b
     *      - Enh: Added client custom code support to program.
510cA*    07/24/06  MLB  5.10c
     *      - Enh: Added support to program for new IMPFITMM file.
     *      - Enh: Added support to program for new ITEMEXT1 file.
     *        Note: IMPFITMM is an optional file, but if it is used,
     *              there must be a record in the IMPFITMM file for
     *              every record in the IMPFITMN file.
510dA*    07/24/06  MLB  5.10d
     *      - Enh: Revised program to delete all records for an item
     *        from files; ITEMSLS, ITEMQTY.
510eA*    09/07/06  MLB  5.10e
     *      - Enh: Revised program to process new field added to file,
     *        IMPFITMM.
510fA*    12/17/06  MLB  5.10f
     *      - Enh: Revised program to remove item type C=Contract item
     *        as valid type. Not supported at this time.
510gA*    01/04/07  RH   5.10g
     *      - Fix: Change to default ITFLGB = 'Y' for ADD if not
     *        maintained thru item interface.
510hA*    01/25/07  MLB  5.10h
     *      - Fix: Revised program to unlock record when chaining to
     *        UNMESR, ACTIVITY and BLDCODE.
510iA*    05/08/07  MLB  5.10i
     *      - Fix: Revised program to populate RDATE field instead
     *        of using DATE var. DATE var uses session/job date
     *        which does not always yield the correcte date.
510jA*    05/25/07  MLB  5.10j
     *      - Fix: Corrected errors with 4.17f fix. Several ITEMMSC
     *        fields were being cleared when a item was added.
     *
520 A*    02/17/09  MLB  5.20
     *      - Enh: Revised program to add support for stand catchweight
     *        items. IUCWGT = 'S'
     *
600aA*    03/01/09  DAS  6.00a  P#00065
     *     - Enh: Revised to not hardcode IMLTRK license tracking value.
     *     - Enh: Revised to call LT002 at the end of the program to
     *       to set license tracking value of all items that do not
     *       have a valid value.
     *
610 A*    09/03/09  MLB  6.10
     *     - Fix: Revised to pad short unit of measure with blanks
     *        when UoM not found in table.
     *
530 A*    11/20/09  MLB  5.30
     *      - Fix: Revised program to set IMLOT to N=No if OPLOT = N.
530aA*    03/15/10  MLB  5.30a
     *     - Fix: Revised program to update program so that IUODAY
     *        - # of Days Out is defaulted to 360 days for date
     *        sensitive items when IMODAY=0. If Host sends a value in
     *        IUODAY, then that value will be updated in IMODAY.
     *
640aA*    04/18/11  RH/MLB  6.40a
     *      - Fix: Revised program to update # of pick slots on update
640bA*    04/21/11  MLB  6.40b
     *     - Fix: Revised program when item cube is not updated from
     *        host and item dimensions are imported, to update item cube
     *        when the new computed cube is different from the cube on
     *        file.
     *
650 A*    01/21/13  MLB  6.50
     *      - Enh: Recompiled pgm due to change in import file keys.
650aA*    08/10/13  MLB  6.50a
     *      - Fix: Revised program to unlock record when chaining to
     *        DESIG.
650dA*    12/09/13  MLB  6.50d
     *      - Enh: Revised pgm to add record to ITEMFLD file only when
     *        item doesn't exist. Initialize following new fields:
     *        IFUCICDE, IFRCVMTH, IFSLTMTH and IFBRDFLG.
650dA*    12/12/13  RTR  6.50d
     *      - Fix: If empty member in IMPFITMM program was trying to
     *        write empty record to ITEMEXT1. Change to not attempt
     *        to write if empty fields.
     *
700 A*    06/22/15  MLB  7.00
     *      - Fix: Revised program to set ITFLGD to N=No if OPFLGD = N.
     *      - Fix: Revised program to set IMMFLG to N=No if OPMFLG = N.
700a *    07/23/15  RTR  7.00a
     *      - Fix: Add mod 610 to brkdwn 1 & 2 also.
700bA*    06/11/16  DAS  7.00b
     *      - Enh - Revised to delete *EACH records from
     *        ITEMAVG, ITEMSLS.
700cA*    11/02/16  LMC  7.00c
     *      - Recompile only - UPC file changed.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's Provision
     *
PAK A*    09/13/06  MLB  PAK
     *      - Revise program to convert IUWHDP code to DRY, FRZ or REF.
     *----------------------------------------------------------------
     *
     *  Client Custom Revisions: Cash-WA
     *
CWD A*    02/01/10  JCJ  CWD
     *      - Revise program to set flag IMWRNC to Y/N based on value in
     *        IUBLNK where IUBLNK=0=N or =1=Y. This flag will be used
     *        in CW112 to control whether 1 total wgt or multiple
     *        individual wgts are entered.
     *
     *----------------------------------------------------------------
     *
     *  Client Custom Revisions: Dairyland
     *
DRY A*    02/18/10  JCJ  DRY
     *      - Revise program to set flag IMWRNC to Y/N based on value in
     *        IUBLNK where IUBLNK=0=N or =1=Y. This flag will be used
     *        in CW112 to control whether 1 total wgt or multiple
     *        individual wgts are entered.
DRYaA*    01/11/12  MLB  DRYa
     *      - Revise program to update ITWHDP for new items only even
     *        though OPWHDP = N. Item will be defaulted to Host depart-
     *        ment when item is added. After that, individual warehouse
     *        locations will maintain the department. This mod is being
     *        done because not all of Dairyland's warehouses store an
     *        item in the same warehouse area. This mod will allow each
     *        warehouse to control where they store an item.
DRYbA*    06/08/15  MLB  DRYb
     *      - Revise program to update IMODAY to 720 days for items with
     *        ITWHDP = 'DRY'. All other items will default to 360.
     *      - Per Kelly R email dated 06/05/2015.
DRYcA*    09/22/15  MLB  DRYc
     *      - Revise DRYa mod. Revise pgm to update ITWHDP when OPWHDP=N
     *        and item on file, but ITWHDP = ' '.
DRYdA*    11/07/16  MLB  DRYd
     *      - Revise program to update item c/wgt variance fields for new
     *        items and update if variances are zero and update has
     *        positive values.
DRYeA*    03/02/22  MLB  DRYe
     *      - Revise DRYd mod to correct update for c/wgt variance 2 field.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Andrews Foodservice
     *
AFS A*    04/21/11  MLB  AFS
     *      - Revise program to default computed cube to 0.100 if zero.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer Foods
     *
FFCa *    03/12/15  RTR  FFCa
     *      - Change to handle breakdown UOMs on type S items.
     *        For parents, if Bkdn 1 UOM is ** change to PC.
     *        For type S, change Normal UOM to PC and Bkdn 1 to blank.
FFCb *    06/18/15  RTR  FFCb
     *      - Change to turn of Mfr Date flag when Date Sensitive=N.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Reinhart Food Service
     *
RFS A*    05/28/13  RTR  RFS
     *      - Changed to check for invalid buyer number and set to zero.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  61        - Special order (Customer # > 0)
     *  79        - EOF for IMPITM3
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfitm3  uf   e             disk
510cAFimpfitmm  uf   e           k disk    usropn
     Fwarehs    if   e           k disk
     Freports   if   e           k disk
     Fpiritem   uf a e           k disk
     Fitemdsc   uf a e           k disk
     Fitemdef   uf a e           k disk
650dAFitemfld   Uf a e           k disk
     Fitemlnk   uf a e           k disk
     Fitemlnk1  if   e           k disk
     F                                     rename(ilrec:record1)
     Fitemmsc   uf a e           k disk
510cAFitemext1  uf a e           k disk
510dAFitemsls   uf   e           k disk    usropn
510dAFitemavg   uf   e           k disk    usropn
     Foptions   if   e           k disk
     Fitemqty   uf a e           k disk
     Fii265pr   o    e             printer oflind(*in91)
     Fwhdept    if   e           k disk
     Fdesig     uf a e           k disk
     Factivity  uf a e           k disk
     Funmesr    uf a e           k disk
     Fbldcode   uf a e           k disk
     Fslot3     uf   e           k disk
     Fupc1      uf   e           k disk
510bA*----------------------------------------------------------------
510bA*  Customer id
510bA*
PAK A /COPY QCOPYSRC,ID#packers
CWD A /COPY QCOPYSRC,ID#Cashwa
DRY A /copy qcopysrc,id#dairyla
AFS A /COPY QCOPYSRC,ID#andrews
FFCaA /COPY QCOPYSRC,ID#fischer
RFS A /COPY QCOPYSRC,ID#rfs
510bA*
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a30             s              1    dim(30)
     *                   DESC    1  44 30
510fDD*desc            s             30    dim(45) ctdata perrcd(1)
510fMD desc            s             30    dim(46) ctdata perrcd(1)
     D cdsc            s             30    dim(1) ctdata perrcd(1)
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
     *PDATA      DS
     D opdat1          ds
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
     *    OPNSLT  -  Non-slotted item
     *    OPXDCK  -  Crossdock item
     *    OPBNBR  -  Buyer number
     *    OPBNAM  -  Buyer name
     *    OPVNAM  -  Vendor name
     *    OPBRND  -  Brand
     *    OPLOT   -  Lot code item
     *    OPLTRK  -  Track by license
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
     D  opnslt                37     37
     D  opxdck                38     38
     D  opbnbr                39     39
     D  opbnam                40     40
     D  opvnam                41     41
     D  opbrnd                42     42
     D  oplot                 43     43
     D  opltrk                44     44
     D  opten2               117    117
510bA*----------------------------------------------------------------
510bA*  Working Variables
510bA*
     D actcub          s                   like(itcube)
     D addflg          s              1
     D a2nflg          s              1
     D chgflg          s              1
     D count           s              3  0
700bAD dltItem         s                   like(ititem)
     D eofd            s              1
     D eofi            s              1
     D eofl            s              1
     D error           s              1
     D first           s              1
     D forevr          s              1
     D grdord          s              5  0
700bAD i               s              3  0
     D impdte          s              8  0
     D imptim          s              6  0
     D itumq3          s              3  0
     D itum2           s              2
     D itum3           s              2
     D kysdef          s              2
     D kywhse          s              3  0
     D len             s              1  0
     D linppg          s              3  0
510cAD miscitmupd      s              4    inz('*NO ')
510cAD opnimpitmm      s              1    inz('0')
     D opcode          s              8
     D pflag           s              1
     D pos             s              1  0
     D pxflg           s              1
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
CWD AD cashwak         c                   const('KEARNEY')
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
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * Main line
     *
     * Whip through all the download Update Item records
     *
     C                   eval      first = *on
     C                   eval      pflag = *on
     C                   eval      eofi = *off
     C                   eval      linppg = 55
     C                   eval      count = 0
     C                   dou       eofi = *on
     *
     C                   read      impfitm3                               79
     C                   eval      error = *off
     C                   if        *in79
     C                   eval      eofi = *on
     C                   goto      enddiu
     C                   endif
PAK A*
PAK AC                   select
PAK AC                   when      client = Packers
PAK A*
PAK AC                   select
PAK AC                   when      iuwhdp = 'Z1   '
PAK AC                   eval      iuwhdp = 'FRZ  '
PAK AC                   when      iuwhdp = 'Z2   '
PAK AC                   eval      iuwhdp = 'REF  '
PAK AC                   when      iuwhdp = 'Z3   '
PAK AC                   eval      iuwhdp = 'DRY  '
PAK AC                   endsl
PAK A*
FFCaAC                   when      client = FischerFoods
FFCaAC                   select
FFCaAC                   when      iutype = *blank
FFCaAC                             and iuum2 = '**'
PAK AC                   eval      iuum2 = 'PC'
FFCaAC                   when      iutype = 'S'
PAK AC                   eval      iuum1 = 'PC'
PAK AC                   eval      iuum2 = *blank
FFCaAC                   endsl
PAK A*
PAK AC                   endsl
PAK A*
510cA*
510cA*  Retrieve Import Item Update Misc. file.
510cAC                   if        miscitmupd = '*YES'
510cAC     itkey         chain     impfitmm
510cAC                   if        not %found(impfitmm)
510cAC                   clear                   impgrp
510eAC                   clear                   imppnt
510cAC                   clear                   impvar
510cAC                   clear                   impcat
510cAC                   clear                   impms1
510cAC                   clear                   impms2
510cAC                   clear                   impms3
510cAC                   clear                   impms4
510cAC                   clear                   impms5
510cAC                   endif
510cAC                   endif
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
     C                   if        error = *on
     **         CHGFLG    OREQ *ON
     **         ADDFLG    OREQ *ON
     C                   write     detail
     C                   add       1             count
     C                   endif
     *
     *
     *       Delete detail record from download file
     *
     C                   delete    iurec
510cA*
510cA*      Import Item Updates Misc file record imported.
510cAC                   if        miscitmupd = '*YES'
510cAC                             and %found(impfitmm)
510cAC                   delete    imprec
510cAC                   endif
     *
     C     enddiu        tag
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
     C                   eval      *inlr = *on
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
510bAC                   call      'GETCLIENT'
510bAC                   parm                    client           10
510bAC                   parm                    clientloc        10
510bA*
510cA*
510cA* Open IMPFORDHM file.
510cAC                   if        opnimpitmm <> *on
510cAC                   open      impfitmm                             67
510cAC                   if        *in67 = *off
510cAC                   eval      opnimpitmm = *on
510cAC                   eval      miscitmupd = '*YES'
510cAC                   else
510cAC                   eval      miscitmupd = '*NO '
510cAC                   endif
510cAC                   endif
510cA*
     * Key definitions
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem

700bAC     keyitdel      klist
700bAC                   kfld                    iuwhse
700bAC                   kfld                    dltItem
     *
     *  Define key for PIRITEM file for base item.
     *
     C     itkeyb        klist
     C                   kfld                    iuwhse
     C                   kfld                    #bitem
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
     C                   kfld                    ilitem
     **                   KFLD           ILITM2
650dA*
650dA*  Define key for ITEMFLD file.
650dA*
650dAC     ifkey         klist
650dAC                   kfld                    iuwhse
650dAC                   kfld                    iuitem
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
     *
     *
     *  Define key for options file.
     *
     C     optnky        klist
     *R                   KFLD           IUWHSE
     C                   kfld                    kywhse
     C                   kfld                    opcode
     *
     *  Define key for UPC file.
     *
     C     upkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
510iA*
510iA*  Convert today's date into MMDDYY format.
510iA*
510iAC                   eval      $cvcmd = '*CURMDY '
510iAC                   call      @cvtdt
510iAC                   parm                    $cvtdt
510iAC                   eval      rdate = $cvd6o
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
     *R         IUUTYP    IFEQ 'A'
     *
     *  For base item, master item must be blank.
     *
     C                   if        iutype = ' '  and
     C                             iumitm <> *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(41)
     C                   goto      endcki
     C                   endif
510fA*
510fA*  Invalid Item Type,
510fA*
510fAC                   if            iutype <> ' '
510fAC                             and iutype <> 'A'
510fAC                             and iutype <> 'B'
510fAC                             and iutype <> 'S'
510fAC                   eval      error = *on
510fAC                   eval      detmsg = %trim(desc(46))
510fAC                                      + iutype
510fAC                                      + ''''
510fAC                   goto      endcki
510fAC                   endif
     *
     *  For Alias, Brkdown, Contract, and Same slot Brkdown,
     *  Master item can't be blank.
     *
     C                   if        iutype = 'A'  or
     C                             iutype = 'B'  or
510fDC*                            iutype = 'C'  or
     C                             iutype = 'S'
     C                   if        iumitm = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(37)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
510fD*  For Contract breakdown item, Contract base item can't be
510fD*  blank.
510fD*
510fDC*                  if        iutype = 'C'
510fDC*    itkey2        chain(n)  piritem                            76
510fDC*                  if        ittype = 'B'  and
510fDC*                            iucitm = *blanks
510fDC*                  eval      error = *on
510fDC*                  eval      detmsg = desc(43)
510fDC*                  goto      endcki
510fDC*                  endif
510cA*
510cA*      Retrieve item extension file record.
510fDC*    itkey2        chain(n)  itemext1
510fDC*                  if        not %found(itemext1)
510fDC*                  clear                   ikrec
510fDC*                  endif
510cA*
510fDC*                  endif
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
510cA*
510cA*      Retrieve item extension file record.
510cAC     itkey2        chain(n)  itemext1
510cAC                   if        not %found(itemext1)
510cAC                   clear                   ikrec
510cAC                   endif
510cA*
     C                   if        itflg1 = 'Y'  or
     C                             itflg2 = 'Y'
     **         ITFLG2    ANDEQ'Y'
     C                   eval      error = *on
     C                   eval      detmsg = desc(42)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *R                   ENDIF
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
     *R                   CALL 'WD900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keywd         chain     whdept                             75
     C                   if        *in75
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
     *R                   CALL 'DS900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keyds         chain     desig                              75
     C                   if        *in75
     C                   eval      dscode = iudesg
     C                   eval      dsdesc = cdsc(1)
     C                   write     dsrec                                77
     C                   add       1             newdsg
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,4    DETMSG
     *R                   GOTO ENDCKI
650aAC                   else
650aAC                   unlock    desig
     C                   endif
     C                   endif
     *
     *  Verify activity zone (optional).
     *
     C                   if        opactv = 'Y'  and
     C                             iuactv <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lactv = iuactv
     *R                   CALL 'AC900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keyac         chain     activity                           75
     C                   if        *in75
     C                   eval      accode = iuactv
     C                   eval      acdesc = cdsc(1)
     C                   write     acrec                                77
     C                   add       1             newact
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,5    DETMSG
     *R                   GOTO ENDCKI
510hAC                   else
510hAC                   unlock    activity
     C                   endif
     C                   endif
     *
     *  Verify Date Sensitive option.
     *
     C                   if        opflgd = 'Y'
     C                   if        iuflgd <> 'Y'  and
     C                             iuflgd <> 'N'
     C                   eval      iuflgd = 'N'
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,6    DETMSG
     *R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify Allow Bulk Pick option.
     *
     C                   if        opflgb = 'Y'
     C                   if        iuflgb <> 'Y'  and
     C                             iuflgb <> 'N'
     C                   eval      iuflgb = 'N'
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,7    DETMSG
     *R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify vendor number is within range.
     *
     C                   if        opven# = 'Y'
     C                   if        iuven# < 0  or
     C                             iuven# > 9999999999
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
     *R         ITTYPE    IFEQ 'B'
     *R         ITTYPE    OREQ 'A'
     *R         ITTYPE    OREQ 'C'
     *R         ITTYPE    OREQ 'S'
     C                   if        iutype = 'B'  or
     C                             iutype = 'A'  or
510fDC*                            iutype = 'C'  or
     C                             iutype = 'S'
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
     *  Full case item number must be different from broken case item.
     C                   if        iumitm = iuitem
     C                   eval      error = *on
     C                   eval      detmsg = desc(10)
     C                   goto      endcki
     C                   endif
     *  Get full case item.
     C     itkey2        chain(n)  piritem                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(8)
     C                   goto      endcki
     C                   endif
510cA*
510cA*      Retrieve item extension file record.
510cAC     itkey2        chain(n)  itemext1
510cAC                   if        not %found(itemext1)
510cAC                   clear                   ikrec
510cAC                   endif
510cA*
     *
     *  Brk 1 quantity must be >0.
     C                   if        not *in79  and
     C                             itumq2 <= 0
     C                   if        iutype = 'B'  or
     C                             iutype = 'S'
     *R         ITUMQ2    ANDLE0
     C                   eval      error = *on
     C                   eval      detmsg = desc(9)
     C                   goto      endcki
     C                   endif
     C                   endif
     *  Full case item number must be different from broken case item.
     *R         IUMITM    IFEQ IUITEM
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,10   DETMSG
     *R                   GOTO ENDCKI
     *R                   ENDIF
     C                   endif
     C                   endif
     *
     *  Brk 1 quantity must be >0 if UOM is entered.
     C                   if        opum2 = 'Y'
     C                   if        iuum2 <> *blanks  and
     C                             iuumq2 < 0
     *R         IUUMQ2    ANDLE0
     C                   eval      error = *on
     C                   eval      detmsg = desc(9)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  UOM must be entered if Brk1 qty is entered.
     **         OPUMQ2    IFEQ 'Y'
     **         IUUMQ2    IFNE 0
     **         IUUM2     ANDEQ*BLANKS
     **                   MOVE *ON       ERROR
     **                   MOVE DESC,9    DETMSG
     **                   GOTO ENDCKI
     **                   ENDIF
     **                   ENDIF
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
510cA*
510cA*      Retrieve item extension file record.
510cAC     itkey4        chain(n)  itemext1
510cAC                   if        not %found(itemext1)
510cAC                   clear                   ikrec
510cAC                   endif
510cA*
     C                   endif
     *
     *
     *  Verify Mfg date flag.
     *
     C                   if        opmflg = 'Y'
     C                   if        iumflg <> 'Y'  and
     C                             iumflg <> 'N'
     C                   eval      iumflg = 'N'
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,11   DETMSG
     *R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify date sensitive flag, if Mfg date flag = 'Y'.
     *
     C                   if        opmflg = 'Y'
     C                   if        opflgd = 'Y'
     C                   if        iumflg = 'Y'  and
     C                             iuflgd <> 'Y'
FFCbAC                   select
FFCbAC                   when      client = FischerFoods
FFCbAC                   eval      iumflg = 'N'
FFCbAC                   other
     C                   eval      error = *on
     C                   eval      detmsg = desc(12)
     C                   goto      endcki
FFCbAC                   endsl
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
     *
     C                   if        opdday = 'Y'
     C                   if        iumflg = 'Y'  and
     C                             iudday = 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(14)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify user days, if Mfg date flag = 'Y'.
     *
     C                   if        opuday = 'Y'
     C                   if        iumflg = 'Y'  and
     C                             iuuday = 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(15)
     C                   goto      endcki
     C                   endif
     C                   endif
     C                   endif
     **************
     *
     *  Verify catch weight.
     *
     C                   if        opcwgt = 'Y'
     C                   if        iucwgt <> 'Y'  and
     C                             iucwgt <> 'N'
520 AC                             and iucwgt <> 'S'
     C                   eval      iucwgt = 'N'
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,16   DETMSG
     *R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify normal unit of measure.
     *
     C                   if        opum1 = 'Y'  and
     C                             iuum1 <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lum = iuum1
     *R                   CALL 'UM900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keyum         chain     unmesr                             75
     C                   if        *in75
     C                   eval      umcode = iuum1
610 DC*                  movel     iuum1         umshrt
610 MC                   movel (p) iuum1         umshrt
     C                   eval      umdesc = cdsc(1)
     C                   write     umrec                                77
     C                   add       1             newum
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,17   DETMSG
     *R                   GOTO ENDCKI
510hAC                   else
510hAC                   unlock    unmesr
     C                   endif
     C                   endif
     *
     *  Verify breakdown 1 unit of measure.
     *
     C                   if        opum2 = 'Y'  and
     C                             iuum2 <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lum = iuum2
     *R                   CALL 'UM900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keyum         chain     unmesr                             75
     C                   if        *in75
     C                   eval      umcode = iuum2
700aDC*                  movel     iuum2         umshrt
700aMC                   movel (p) iuum2         umshrt
     C                   eval      umdesc = cdsc(1)
     C                   write     umrec                                77
     C                   add       1             newum
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,17   DETMSG
     *R                   GOTO ENDCKI
510hAC                   else
510hAC                   unlock    unmesr
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
     C                   eval      iuflg1 = 'N'
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,19   DETMSG
     *R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify breakdown 2 unit of measure.
     *
     C                   if        opum3 = 'Y'  and
     C                             iuum3 <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lum = iuum3
     *R                   CALL 'UM900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keyum         chain     unmesr                             75
     C                   if        *in75
     C                   eval      umcode = iuum3
700aDC*                  movel     iuum3         umshrt
700aMC                   movel (p) iuum3         umshrt
     C                   eval      umdesc = cdsc(1)
     C                   write     umrec                                77
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,17   DETMSG
     *R                   GOTO ENDCKI
510hAC                   else
510hAC                   unlock    unmesr
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
     C                   eval      iuflg2 = 'N'
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,19   DETMSG
     *R                   GOTO ENDCKI
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
     *R                   CALL 'BC900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keybc         chain     bldcode                            75
     C                   if        *in75
     C                   eval      bccode = iubld
     C                   eval      bcseq = 0
     C                   eval      bcdesc = cdsc(1)
     C                   write     bcrec                                77
     C                   add       1             newbld
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,23   DETMSG
     *R                   GOTO ENDCKI
510hAC                   else
510hAC                   unlock    bldcode
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
     *
     *  See if item type is changing and if it is ok to do so.
     *
     C                   if        opityp = 'Y'
     C                   exsr      zzchkt
     C     error         cabeq     *on           endcki
     C                   endif
     *
     C     endcki        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKT   Check if item type can be changed.
     *
     C     zzchkt        begsr
     C                   eval      a2nflg = *off
     *
     *  See if import item exists in PIRITEM file.
     *
     C     itkey         chain(n)  piritem                            79
     *
     *  If it doesn't, move on.
     *
     C     *in79         cabeq     *on           endckt
     *
     *  If type didn't change, move on.
     *
     C     iutype        cabeq     ittype        endckt
     *
     *  Only allowed to change from 'A' to ' '.
     *
     C                   if        ittype = 'A'  and
     C                             iutype = ' '
     C                   eval      a2nflg = *on
     C                   goto      endckt
     C                   endif
     *
     *  For now, everthing else is an error.
     *
     C                   eval      error = *on
     C                   movea     desc(45)      a30
     C                   eval      a30(22) = ittype
     C                   eval      a30(29) = iutype
     C                   movea     a30           detmsg
     *
     C     endckt        endsr
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
     *R                   SELEC
     *R         IUTYPE    WHEQ ' '
     *R         IUTYPE    OREQ 'B'
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
     *R                   ENDSL
     C     ittype        cabeq     'A'           skip1
     *
     *   Get corresponding base item.
     *
     C                   exsr      zzgetb
     *
     *R                   SELEC
     *R         IUTYPE    WHEQ ' '
     *R         IUTYPE    OREQ 'B'
     *R         IUTYPE    OREQ 'C'
     *
     *   Get item quantity record.
     *      for Base item.
     *
     *R         ITKEY     CHAINITEMQTY              7978
     C     itkeyb        chain     itemqty                            7978
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
     *      Only check break quantities for breakdown item
     C                   if        ittype = 'S'
     *
     C                   if        iqstk2 <> 0  or
     C                             iqstk3 <> 0  or
     C                             iqalc2 <> 0  or
     C                             iqalc3 <> 0  or
     C                             iqhld2 <> 0  or
     C                             iqhld3 <> 0  or
     C                             iqtri2 <> 0  or
     C                             iqtri3 <> 0  or
     C                             iqtro2 <> 0  or
     C                             iqtro3 <> 0  or
     C                             iqord1 <> 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(39)
     C                   goto      enddel
     C                   endif
     C                   else
     *
     *      check all quantities for other item types.
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
     C                   endif
     *
     *      Delete item quantity record.
     *
     *       Don't do delete for 'A' and 'S' items
     *
     C                   if        ittype <> 'A'  and
     C                             ittype <> 'S'
     C                   delete    iqrec                                77
     C                   endif
     *
     C                   endsl
     *R                   ENDSL
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
     C     skip1         tag
     *
     C                   if        ittype = 'A'  or
     C                             ittype = 'B'  or
510fDC*                            ittype = 'C'  or
     C                             ittype = 'S'
     C     ilkey         chain     itemlnk                            79
     C                   if        not *in79
     C                   delete    ilrec
     C                   endif
     C                   endif
510dA
510dA*  Delete ITEMSLS records.
510dA
510dAC                   if        not %open(itemsls)
510dAC                   open      itemsls
510dAC                   endif
700bA
700bAC                   for       i = 1 to 2
700bA
700bAC                   if        i = 1
700bAC                   eval      dltItem = iuitem
700bAC                   else
700bAC                   eval      dltItem = %trim(iuitem) + '*EACH'
700bAC                   endif
510dA
700bDC**   itkey         setll     itemsls
700bMC     keyitdel      setll     itemsls
510dA
510dAC                   dow       forevr = forevr
700bDC**   itkey         reade (e) itemsls
700bMC     keyitdel      reade (e) itemsls
510dAC                   if        %eof(itemsls)
510dAC                   leave
510dAC                   endif
510dA*     If record is locked then send skip record.
510dAC                   if        %status = 01218
510dAC                   iter
510dAC                   endif
510dA*     Otherwise, delete record.
510dAC                   delete(e) ihrec
510dAC                   if        %error
510dAC                   iter
510dAC                   endif
510dA
510dAC                   enddo
700bA
700bAC                   endfor
510dA
510dA*  Delete ITEMAVG record
510dA*
510dAC                   if        not %open(itemavg)
510dAC                   open      itemavg
510dAC                   endif
700bA
700bAC                   for       i = 1 to 2
700bA
700bAC                   if        i = 1
700bAC                   eval      dltItem = iuitem
700bAC                   else
700bAC                   eval      dltItem = %trim(iuitem) + '*EACH'
700bAC                   endif
510dA
700bDC**   itkey         chain (e) itemavg
700bMC     keyitdel      chain (e) itemavg
510dA*     If record is locked then send skip record.
510dA
510dAC                   if        %status = 01218
510dAC                   else
510dAC                   if        %found(itemavg)
510dAC                   delete(e) igrec
510dAC                   if        %error
510dAC                   endif
510dAC                   endif
510dAC                   endif
700bA
700bAC                   endfor
     *
     C     upkey         setll     upc1
     C                   dow       forevr = forevr
     C     upkey         reade     upc1                                   79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   delete    uprec
     C                   enddo
     *
     *   Update SLOT3 records. Change slot status to Zero.
     *
     C     itkey         setll     slot3
     C                   eval      *in79 = *off
     C                   dou       *in79
     C     itkey         reade     slot3                                7879
     *
     *     If record is locked then skip slot.
     *
     C                   if        *in78
     C                   iter
     C                   endif
     *
     *     Otherwise, Change status to Zero.
     *
     C                   if        not *in79  and
     C                             slstat <> 'Z '
     C                   eval      slstat = 'Z '
     C                   eval      slsdte = today
     C                   time                    slstim
     C                   update    slrec                                77
     C                   endif
     *
     C                   enddo
510cA*
510cA*      Delete Item Extension Misc. record.
510cAC     itkey         chain     itemext1
510cAC                   if        %found(itemext1)
510cAC                   delete    ikrec
510cAC                   endif
     *
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   delete    itrec
     C                   endif
     *
     C     enddel        endsr
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
DRYaA*
DRYaA*      Update department for Dairyland on new items only.
DRYaAC                             or  client = Dairyland
DRYcMC                             and (opwhdp = 'N'
DRYaAC                             and *in79 = '1'
DRYcA*
DRYcAC                             or opwhdp = 'N'
DRYcAC                             and *in79 = '0'
DRYcAC                             and itwhdp = ' ')
DRYaA*
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
700 AC                   else
700 AC                   if        itflgd = ' '
700 AC                   eval      itflgd = 'N'
700 AC                   endif
     C                   endif
     C                   if        opflgb = 'Y'
     C                   eval      itflgb = iuflgb
     C                   endif
510g C                   if        opflgb = 'N' and
510g C                             *in79 = *on
510g C                   eval      itflgb = 'Y'
510g C                   endif
     C                   eval      itupc = *blanks
     C                   if        opven# = 'Y'
     C                   eval      itven# = iuven#
     C                   endif
     C                   if        opvit# = 'Y'
     C                   eval      itvit# = iuvit#
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
     *      and Cube is zero
     *      and Cube is not imported from host.
640bA*      or Cube not imported from host and computed cube chg'd.
     *
     C                   if        opcaut = 'Y'  and
640bDC*                            itcube = 0
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
     C                   eval      itstyp = svstyp
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
     *R                   MOVE IUDESC    ITDESC
     C                   movel     iudesc        itdesc
     C                   eval      itpdsc = iupdsc
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGETB   Get base item to use for checking ITEMQTY.
     *
     C     zzgetb        begsr
     *
     *  Initialize base item info with current item.
     *
     C                   eval      #bitem = ititem
     *
     *  If Alias or SSB Item
     *   Then get Base item.
     *
     C                   if        ittype = 'A'  or
     C                             ittype = 'S'
     *
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
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *  Define key for ACTIV file.
     *
     C     keyac         klist
     C                   kfld                    iuactv
     *
     *  Define key for BUILD file.
     *
     C     keybc         klist
     C                   kfld                    iubld
     *
     *  Define key for DESIG file.
     *
     C     keyds         klist
     C                   kfld                    iudesg
     *
     *  Define key for UNMSR file.
     *
     C     keyum         klist
     C                   kfld                    $lum
     *
     *  Define key for WHDEPT file.
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
     *                    MOVEL'II235PR' RPPRTF
     C                   movel     'II265PR'     rpprtf
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
     C                   eval      newdsg = 0
     C                   eval      newact = 0
     C                   eval      newbld = 0
     C                   eval      newum = 0
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
     *
     C                   exsr      zzfil1
     C                   exsr      zzupd1
     *
     *  Alias and Contract item type
     C                   when      iutype = 'A'  or
510fDC*                            iutype = 'C'  or
     C                             iutype = 'S'
     *
     *          IUUTYP    IFEQ 'A'
     *  For Add, Get PIRITEM record for Base item
     *
     *
     *  If 'S' type record and Normal UOM is not blank
     *    Then get base item record for later update.
     *    Otherwise get base item record as non-update.
     *
     C                   if        iutype = 'S'  and
     C                             iuum1 <> ' '
     C     itkey2        chain     piritem                            79
     C                   else
     C     itkey2        chain(n)  piritem                            79
     C                   endif
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(37)
     C                   goto      endupd
     C                   else
     *
     *     If 'S' type record and Normal UOM is not blank
     *        force 'S' item UM1 into base UM2
     *        force 'S' item UM2 into base UM3
     *        force 'S' item UM2 QTY into base UM3 QTY
     *        update base item record.
     *
     C                   if        iutype = 'S'  and
     C                             iuum1 <> ' '
     C                   eval      itum2 = iuum1
     C                   eval      itum3 = iuum2
     C                   eval      itumq3 = iuumq2
     C                   update    itrec
     C                   endif
     C                   exsr      zzsvit
     C                   endif
     *  For Add, Get ITEMMSC record for Base item
     C     itkey2        chain(n)  itemmsc                            79
     *   Save base record for ITEMMSC file
     C                   if        *in79
     C                   eval      svmtie = 0
     C                   eval      svmhig = 0
     C                   eval      svmflg = *zeros
     C                   eval      svdday = 0
     C                   eval      svuday = 0
     C                   eval      svmday = 0
CWD A
CWD AC                   if        client = cashwa
CWD AC                             and clientloc = cashwak
DRY AC                             or client = Dairyland
CWD A
CWD AC                   if        iublnk = 1
CWD AC                   eval      svwrnc = 'Y'
CWD AC                   else
CWD AC                   eval      svwrnc = 'N'
CWD AC                   endif
CWD A
CWD AC                   else
CWD A
     C                   eval      svwrnc = *zeros
CWD AC                   endif
CWD A
     C                   eval      svrg1c = 0
     C                   eval      svrg2c = 0
     C                   eval      svapck = *zeros
     C                   eval      svnrpk = 0
     C                   eval      svnslt = 'N'
     C                   eval      svxdck = 'N'
     C                   eval      svbnbr = 0
     C                   eval      svbnam = *zeros
     C                   eval      svvnam = *zeros
     C                   eval      svbrnd = *zeros
     C                   eval      svlot = 'N'
     *                    MOVE 'N'       SVLTRK
     C                   eval      svltrk = 'L'
     C                   else
     C                   eval      svmtie = imtie
     C                   eval      svmhig = imhigh
     C                   eval      svmflg = immflg
     C                   eval      svdday = imdday
     C                   eval      svuday = imuday
     C                   eval      svmday = immday
CWD A
CWD AC                   if        client = cashwa
CWD AC                             and clientloc = cashwak
DRY AC                             or client = Dairyland
CWD A
CWD AC                   if        iublnk = 1
CWD AC                   eval      svwrnc = 'Y'
CWD AC                   else
CWD AC                   eval      svwrnc = 'N'
CWD AC                   endif
CWD A
CWD AC                   else
CWD A
     C                   eval      svwrnc = imwrnc
CWD AC                   endif
CWD A
     C                   eval      svrg1c = imrg1c
     C                   eval      svrg2c = imrg2c
     C                   eval      svapck = imapck
     C                   eval      svnrpk = imnrpk
     C                   eval      svnslt = imnslt
     C                   eval      svxdck = imxdck
     C                   eval      svbnbr = imbnbr
     C                   eval      svbnam = imbnam
     C                   eval      svvnam = imvnam
     C                   eval      svbrnd = imbrnd
     C                   eval      svlot = imlot
     C                   eval      svltrk = imltrk
     **                   ENDIF
     C                   endif
     *
     C     itkey         chain     piritem                            79
     *          IUUTYP    IFEQ 'A'
     *          *IN79     ANDEQ*OFF
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,27   DETMSG
     *R                   GOTO ENDUPD
     *                    ENDIF
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
510cA*
510cA*      Extended Item Misc. update.
510cAC                   if        miscitmupd = '*YES'
650eAC                             and impwhs <> 0
650eAC                             and impitm <> *blank
510cAC     itkey         chain     itemext1
510cAC                   eval      ikgrp = impgrp
510eAC                   eval      ikplnt= imppnt
510cAC                   eval      ikvar = impvar
510cAC                   eval      ikcat = impcat
510cAC                   eval      ikmsc1= impms1
510cAC                   eval      ikmsc2= impms2
510cAC                   eval      ikmsc3= impms3
510cAC                   eval      ikmsc4= impms4
510cAC                   eval      ikmsc5= impms5
510cA*
510cAC                   if        not %found(itemext1)
510cAC                   eval      ikwhse= impwhs
510cAC                   eval      ikitem= impitm
510cAC                   write     ikrec
510cAC                   else
510cAC                   update    ikrec
510cAC                   endif
510cA*
510cAC                   endif
510cA*
     *
     C     endupd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update files for item type ' ' or 'B'
     *
     C     zzupd1        begsr
     *
     *   Add record
     *
     C                   if        *in79
     C                   write     itrec                                77
     C                   if        *in77
     C                   eval      error = *on
     C                   eval      detmsg = desc(27)
510 MC                   goto      endupi
510 DC*                  goto      endup1
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
510 MC                   goto      endupi
510 DC*                  goto      endup1
     C                   endif
     *
     C                   else
     C                   update    itrec
     C                   endif
     *
     *   Add record to item quantity file when type changes.
     *     If error occurs, assume record already exists.
     *
     C                   if        a2nflg = *on
     C                   clear                   iqrec
     C                   eval      iqwhse = iuwhse
     C                   eval      iqitem = iuitem
     C                   write     iqrec                                77
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
     C     imkey         chain     itemmsc                            79
     C                   if        optie = 'Y'
     C                   eval      imtie = iutie
     C                   endif
     C                   if        ophigh = 'Y'
     C                   eval      imhigh = iuhigh
     C                   endif
     C                   if        opmflg = 'Y'
     C                   eval      immflg = iumflg
700 AC                   else
700 AC                   if        immflg = ' '
700 AC                   eval      immflg = 'N'
700 AC                   endif
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
CWD A
CWD AC                   if        client = cashwa
CWD AC                             and clientloc = cashwak
DRY AC                             or client = Dairyland
CWD A
CWD AC                   if        iublnk = 1
CWD AC                   eval      imwrnc = 'Y'
CWD AC                   else
CWD AC                   eval      imwrnc = 'N'
CWD AC                   endif
CWD A
CWD AC                   endif
CWD A
     C                   if        opnslt = 'Y'
     C                   eval      imnslt = iunslt
     C                   endif
     C                   if        opxdck = 'Y'
     C                   eval      imxdck = iuxdck
     C                   endif
     C                   if        opbnbr = 'Y'
RFS AC                   monitor
     C                   eval      imbnbr = iubnbr
RFS AC                   on-error
RFS AC                   eval      iubnbr = 0
RFS AC                   eval      imbnbr = 0
RFS AC                   endmon
     C                   endif
     C                   if        opbnam = 'Y'
     C                   eval      imbnam = iubnam
     C                   endif
     C                   if        opvnam = 'Y'
     C                   eval      imvnam = iuvnam
     C                   endif
     C                   if        opbrnd = 'Y'
     C                   eval      imbrnd = iubrnd
     C                   endif
     C                   if        oplot = 'Y'
     C                   eval      imlot = iulot
     C                   endif
640aA*
640aAC                   select
640aAC                   when      iustyp = 'P'
640aAC                   eval      imnrpk = *zeros
640aA*
640aAC                   when      iustyp = 'F' and
640AAC                             imnrpk = 0
640aAC                   eval      imnrpk = 1
640aAC                   endsl
640aA*
600aDC**                 if        opltrk = 'Y'
600aDC**                 eval      imltrk = iultrk
600aDC**                 endif
530aDC*                  eval      imoday = iuoday
530aAC*
530aAC                   select
530aA*    Install update from Host for Date Sensitive items.
530aAC                   when          iuoday > 0
530aAC                             and itflgd = 'Y'
530aAC                             and immflg = 'N'
530aAC                   eval      imoday = iuoday
530aA*
530aA*    Force Days Out to 360 for Date Sensitive items.
530aAC                   when          imoday = 0
530aAC                             and itflgd = 'Y'
530aAC                             and immflg = 'N'
530aAC                   eval      imoday = 360
530aAC                   endsl
530aAC*
     **                   MOVE 'Y'       IMWRNC
DRYdA
DRYdAC                   if        client = Dairyland
DRYdAC                   if            imrg1c <> iurg1c
DRYdAC                             and iurg1c > 0
DRYdAC                   eval      imrg1c = iurg1c
DRYdAC                   endif
DRYdA*
DRYdAC                   if            imrg2c <> iurg2c
DRYdAC                             and iurg2c > 0
DRYeMC                   eval      imrg2c = iurg2c
DRYdAC                   endif
DRYdA*
DRYdAC                   else
     C                   eval      imrg1c = iurg1c
     C                   eval      imrg2c = iurg2c
DRYdAC                   endif
DRYdA
     **                   MOVE 'N'       IMAPCK
     **                   Z-ADD0         IMNRPK
     C                   if        not *in79
     C                   update    imrec
     C                   else
CWD A
CWD AC                   if        client = cashwa
CWD AC                             and clientloc = cashwak
DRY AC                             or client = Dairyland
CWD A
CWD AC                   if        iublnk = 1
CWD AC                   eval      imwrnc = 'Y'
CWD AC                   else
CWD AC                   eval      imwrnc = 'N'
CWD AC                   endif
CWD A
CWD AC                   else
CWD A
     C                   eval      imwrnc = 'Y'
CWD AC                   endif
CWD A
DRYdAC                   if        client = Dairyland
DRYdAC                   if            imrg1c <> iurg1c
DRYdAC                             and iurg1c > 0
DRYdAC                   eval      imrg1c = iurg1c
DRYdAC                   endif
DRYdA*
DRYdAC                   if            imrg2c <> iurg2c
DRYdAC                             and iurg2c > 0
DRYeMC                   eval      imrg2c = iurg2c
DRYdAC                   endif
DRYdA*
DRYdAC                   else
     C                   eval      imrg1c = iurg1c
     C                   eval      imrg2c = iurg2c
DRYdAC                   endif
DRYdA*
     C                   eval      imapck = 'N'
     C                   eval      imwhse = iuwhse
     C                   eval      imitem = iuitem
     C                   if        iustyp = 'F'
     C                   eval      imnrpk = 1
     C                   else
     C                   eval      imnrpk = *zeros
     C                   endif
510jAC                   if        iunslt = ' '
     C                   eval      imnslt = 'N'
510jAC                   endif
510jAC                   if        iuxdck = ' '
     C                   eval      imxdck = 'N'
510jAC                   endif
RFS AC                   monitor
510jAC                   if        iubnbr = 0
     C                   eval      imbnbr = 0
510jAC                   endif
RFS AC                   on-error
RFS AC                   eval      imbnbr = 0
RFS AC                   endmon
510jAC                   if        iubnam = ' '
     C                   eval      imbnam = *blanks
510jAC                   endif
510jAC                   if        iuvnam = ' '
     C                   eval      imvnam = *blanks
510jAC                   endif
510jAC                   if        iubrnd = ' '
     C                   eval      imbrnd = *blanks
510jAC                   endif
510jAC                   if        iulot = ' '
530 AC                             or oplot = 'N'
     C                   eval      imlot = 'N'
510jAC                   endif
600aDC**                 if        iultrk = ' '
     *                    MOVE 'N'       IMLTRK
600aDC**                 eval      imltrk = 'L'
600aDC**                 endif
530aDC*                  eval      imoday = iuoday
530aAC*
530aAC                   select
530aA*    Install update from Host for Date Sensitive items.
530aAC                   when          iuoday > 0
530aAC                             and itflgd = 'Y'
530aAC                             and immflg = 'N'
530aAC                   eval      imoday = iuoday
530aA*
530aA*    Force Days Out to 360 for Date Sensitive items.
530aAC                   when      imoday = 0
530aAC                             and itflgd = 'Y'
530aAC                             and immflg = 'N'
DRYbAC                   select
DRYbAC                   when      client = Dairyland
DRYbA*    Dry items have longer shelf life so default to 2 yrs.
DRYbAC                   if        itwhdp = 'DRY'
DRYbAC                   eval      imoday = 720
DRYbAC                   else
DRYbAC                   eval      imoday = 360
DRYbAC                   endif
DRYbAC                   other
DRYbA*
530aAC                   eval      imoday = 360
DRYbAC                   endsl
DRYbA*
530aAC                   endsl
530aAC*
     C                   write     imrec
     C                   endif
     *   Save base record for ITEMMSC file
     C                   eval      svmtie = imtie
     C                   eval      svmhig = imhigh
     C                   eval      svmflg = immflg
     C                   eval      svdday = imdday
     C                   eval      svuday = imuday
     C                   eval      svmday = immday
CWD A
CWD AC                   if        client = cashwa
CWD AC                             and clientloc = cashwak
DRY AC                             or client = Dairyland
CWD A
CWD AC                   if        iublnk = 1
CWD AC                   eval      svwrnc = 'Y'
CWD AC                   else
CWD AC                   eval      svwrnc = 'N'
CWD AC                   endif
CWD A
CWD AC                   else
CWD A
     C                   eval      svwrnc = imwrnc
CWD AC                   endif
CWD A
     C                   eval      svrg1c = imrg1c
     C                   eval      svrg2c = imrg2c
     C                   eval      svapck = imapck
     C                   eval      svnrpk = imnrpk
     C                   eval      svnslt = imnslt
     C                   eval      svxdck = imxdck
     C                   eval      svbnbr = imbnbr
     C                   eval      svbnam = imbnam
     C                   eval      svvnam = imvnam
     C                   eval      svbrnd = imbrnd
     C                   eval      svlot = imlot
     C                   eval      svltrk = imltrk
     C                   eval      svoday = imoday
650dA*
650dA*
650dA*   Add record to ITEMFLD file.
650dAC     ifkey         chain     itemfld
650dAC                   if        not %found(itemfld)
650dAC                   eval      ifwhse    = iuwhse
650dAC                   eval      ifitem    = iuitem
650dAC                   eval      ifcat     = ' '
650dAC                   eval      ifcaseovf = 'N'
650dAC                   eval      ifodrslot = ' '
650dAC                   eval      ifucicde  = '1'
650dAC                   eval      ifrcvmth  = '1'
650dAC                   eval      ifsltmth  = '1'
650dAC                   eval      ifbrdflg  = 'N'
650dAC                   write     ifrec
650dA*
650dAC                   else
650dA*
650dAC                   unlock    itemfld
650dAC                   endif
     *
     *
     *   Add record to ITEMLNK file.
     *     for Brokencase item.
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
     *     for Normal item.
     *
     C                   other
     *
     *R         OPMITM    IFEQ 'Y'
     *R         IUMITM    ANDEQ*BLANKS
     C     ilkey         chain     itemlnk                            79
     C                   if        not *in79
     C                   delete    ilrec
     C                   endif
     *R                   ENDIF
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
510 MC                   iter
510 DC*                  goto      endup1
     C                   else
     *
     C     itkey3        chain     piritem                            79
     C                   if        *in79
510 MC                   iter
510 DC*                  goto      endup1
     C                   endif
     C                   if        ittype = 'A'  or
510fDC*                            ittype = 'C'  or
     C                             ittype = 'S'
     *   Create PIRITEM using saved base item fields.
     C                   eval      itwhdp = svwhdp
     C                   eval      itstyp = svstyp
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
510 MC                   iter
510 DC*                  goto      endup1
     C                   endif
     *   Create ITEMMSC using saved base item fields.
     C                   eval      imtie = svmtie
     C                   eval      imhigh = svmhig
     C                   eval      immflg = svmflg
     C                   eval      imdday = svdday
     C                   eval      imuday = svuday
     C                   eval      immday = svmday
     C                   eval      imwrnc = svwrnc
     C                   eval      imrg1c = svrg1c
     C                   eval      imrg2c = svrg2c
     C                   eval      imapck = svapck
     C                   eval      imnrpk = svnrpk
     C                   eval      imnslt = svnslt
     C                   eval      imxdck = svxdck
     C                   eval      imbnbr = svbnbr
     C                   eval      imbnam = svbnam
     C                   eval      imvnam = svvnam
     C                   eval      imbrnd = svbrnd
     C                   eval      imlot = svlot
600aDC**                 eval      imltrk = svltrk
     C                   eval      imoday = svoday
     C                   endif
     *
     C                   endif
     C     endup1        tag
     C                   enddo
     C                   endsl
510 MC     endupi        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update files for item type 'A' or 'C'
     *
     C     zzupd2        begsr
     *
     *   Add record
     *
     C                   if        *in79
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
     *R         *IN79     IFEQ *ON
     C                   eval      imwhse = iuwhse
     C                   eval      imitem = iuitem
     *   create using saved base fields.
     C                   eval      imtie = svmtie
     C                   eval      imhigh = svmhig
     C                   eval      immflg = svmflg
     C                   eval      imdday = svdday
     C                   eval      imuday = svuday
     C                   eval      immday = svmday
     C                   eval      imwrnc = svwrnc
     C                   eval      imrg1c = svrg1c
     C                   eval      imrg2c = svrg2c
     C                   eval      imapck = svapck
     C                   eval      imnrpk = svnrpk
     C                   eval      imnslt = svnslt
     C                   eval      imxdck = svxdck
     C                   eval      imbnbr = svbnbr
     C                   eval      imbnam = svbnam
     C                   eval      imvnam = svvnam
     C                   eval      imbrnd = svbrnd
     C                   eval      imlot = svlot
600aDC**                 eval      imltrk = svltrk
     *
     C                   if        *in79
     C                   eval      imnrpk = *zeros
     C                   write     imrec
     C                   else
     C                   update    imrec
     C                   endif
     **
     *   Add record to ITEMDEF file using base fields.
     *
     *     First, delete an existing ITEMDEF records.
     *
     C     itkey         setll     itemdef
     C                   eval      *in79 = *off
     C                   dou       *in79
     C     itkey         reade     itemdef                                79
     C                   if        not *in79
     C                   delete    idrec                                77
     C                   endif
     C                   enddo
     *
     *     Then add the ITEMDEF records.
     *
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
     C                   if        *in75
     C                   write     idrec
     C                   else
     C                   update    idrec
     C                   endif
     *
     C     idkey2        setgt     itemdef
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
510fDC*                  if        iutype = 'C'
     **         IUUTYP    ANDEQ'A'
510fDC*    itkey         chain     itemqty                            79
510fDC*                  if        *in79
510fDC*                  clear                   iqrec
510fDC*                  eval      iqwhse = iuwhse
510fDC*                  eval      iqitem = iuitem
510fDC*                  write     iqrec                                77
510fDC*                  if        *in77
510fDC*                  eval      error = *on
510fDC*                  eval      detmsg = desc(35)
510fDC*                  goto      endup2
510fDC*                  endif
510fDC*                  endif
510fDC*                  endif
     *
     C     endup2        tag
     *
     C                   endsr
     *
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
     C                   eval      opdat1 = opdata
     C                   if        opxdsc = 'Y'
     *R                   MOVE '1'       UXFLAG  1
     C                   eval      pxflg = *on
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
*INVALID ITEM TYPE '
**
*Auto created by item update*
