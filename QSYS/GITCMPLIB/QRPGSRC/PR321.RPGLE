      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PR321    Print Breakdown priority replenishments - Print
     *  27 October 2004
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    10/27/04  DAS  5.00
     *      - Created.
500aA*    12/09/04  MLB  5.00a
     *      - Enh: Revised program to use file PRPLFIL7 which
     *        displays slots in the "To Slot" sequence.
500bA*    03/09/05  MLB  5.00b
     *      - Enh: Revised program to call new label program with
     *        different parm list.
640aA*    04/11/11  DAS  6.40a
     *      - Added parms to LT108 call.
700aA*    06/01/15  JCJ  7.00a
     *      - Fix: use program field to populate feature code.
     *        Feature code was getting cleared after returning from
     *        program LT108.
     *
740 A*    01/23/20  MLB  7.40
     *      - Enh: Revised pgm to update PRSDEF with *N if LT108 returns
     *        with *NONE, meaning that it was unable to print Breaker
     *        replenishment label. Chg made at City Line.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
500aDF*prplfil6  uf   e           k disk
500aMFprplfil7  uf   e           k disk
     Fbatctl    o    e           k disk

640aA*----------------------------------------------------------------
640aA*  Data Formats
640aA*----------------------------------------------------------------
640aA
640aA /COPY *libl/qcopysrc,C#SLOT

     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *----------------------------------------------------------------

     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  prwhse                 1      3  0 inz(0)
     D  prwhdp                 4      8
     D  prfail                 9     11
     D  prtail                12     14
     D  prseq#                15     19  0 inz(0)

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $lfail                27     29
     D  $ltail                30     32
     D  $lseq#                33     37  0
     D  $ltrn3                38     44  0
     D  $lfeat                45     45
     D  $lrplt                46     46
     D  $lcrtt                47     47
     D  $lpbat                48     51p 0
     D  $llbl#                52     55p 0

     *----------------------------------------------------------------
     *  CVTDT program parameters
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

     *----------------------------------------------------------------
     *  *FEATURE  -  PIR Feature options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFEAT  -  PIR Installed feature.
     *                 1=Locator system installed.
     *                 2=Full system installed.
     *
     *----------------------------------------------------------------
     * Data structure
     *
     D opdata          ds
     D  opfeat                 1      1
     D  optend               117    117

     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *----------------------------------------------------------------
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
     *----------------------------------------------------------------
     * Data structure

     D opzdta          ds
     D  opclvl                 1      3  0 inz(0)
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0 inz(0)
     D  opcwgt                53     54  0 inz(0)
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  opzend               117    117

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
     *  Variables
     *----------------------------------------------------------------

     D $pwhse          s              3s 0
     D $pnrpl          s              3s 0
     D $pfail          s              3
     D $ptail          s              3

     D bypass          s               n
     D done            s               n
     D error           s               n
     D forever         s               n
     D kycode          s                   like(opcode)
     D kywhse          s                   like(opwhse)
     D labelpgm        s             10
     D labelscreated   s              3  0
     D loop            s              1
     D today           s              8  0
700aMD opfeatx         s              1

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE    -  Warehouse
     *      $PWHDP    -  Warehouse department
     *      $PRPLT    -  Replenishment Type
     *                    ' ' = Normal
     *                    'B' = Breakdown
     *                    'F' = Flowrack
     *      $PNRPL    -  Number of replenishments to print.
500aM*      $PAISL    -  Aisle or *ALL (To Aisle)
     *      $PLPGM    -  Label program
     *      $PDEV     -  Printer device
     *      $PFORM    -  Printer form
     *
     *    Returned Parameters
     *      $PLPRT    -  Labels printed
     *      $PRTN     -  *NONE - No labels printed.
     *                   *OK   - Labels printed.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $prplt            1
     C                   parm                    $pnrpl            3 0
     C                   parm                    $paisl            4
     C                   parm                    $plpgm           10
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $plprt            3
     C                   parm                    $prtn             8

     C                   if        $paisl = '*ALL'
     C                   eval      $pfail = ' '
     C                   else
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm      $paisl        $cstr            30
     C                   move      $cstr         $pfail
     C                   endif
     C                   eval      $ptail = $pfail

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Get batch number to be used for labels.
417aA*    This is needed by the printing program.

     C                   call      'PIRBAT#'
     C                   parm                    batch#            7 0

     C                   eval      btbat# = batch#
     C                   eval      btwhse = $pwhse
     C                   eval      bttype = '*REPLEN '
     C                   eval      btstat = *blanks
     C                   eval      btrte = *blanks
     C                   eval      btstrd = today
     C                   time                    btstrt
     C                   eval      btstrb = #user
     C                   write     btrec
417aA
     *  Get Priority replenishments to print.

     C                   eval      labelscreated = 0
     C                   eval      done = *off
     C                   eval      bypass = *off

500aDC*    prky6a        setll     prplfil6
500aMC     prky7a        setll     prplfil7

     C                   dow       forever = forever

     C                   exsr      zznxt1

     C                   if        done
     C                   leave
     C                   endif

     C                   eval      labelscreated = labelscreated + 1
     C                   if        labelscreated = $pnrpl
     C                   leave
     C                   endif

     C                   enddo

     *  If no labels were created, get out.

     C                   if        labelscreated = 0
     C                   eval      $plprt = ' '
     C                   eval      $prtn = '*NONE'
     C                   goto      bottom
     C                   endif

     *  Labels created, now print them

     *    Initialize pick zone data structure.

     C                   eval      opclvl = 0
     C                   eval      opcwrb = 'N'
     C                   eval      opcwra = 'N'
     C                   eval      opuwrb = 'N'
     C                   eval      opuwra = 'N'
     C                   eval      optext = ' '
     C                   eval      opcwgt = 0
     C                   eval      oplpgm = $plpgm
     C                   eval      oppdev = $pdev
     C                   eval      oppfrm = $pform

     *    Call label printing program.

     C                   if        %subst($plpgm:1:4) = 'PFMT'
     C                   eval      labelpgm = 'PFMT'
     C                   eval      $zset = %subst($plpgm:5:6)
     C                   else
     C                   eval      labelpgm = $plpgm
     C                   eval      $zset = ' '
     C                   endif

500bAC                   if        %subst($plpgm:1:4) = 'PFMT'
     C                   call      labelpgm
     C                   parm      '*PR321'      $zcmd             8
     C****               parm      '*REPLEN'     $zcmd             8
     C                   parm                    $zset             6
     C                   parm                    $zfmt             8
     C                   parm      $pwhse        $zwhse            3 0
     C                   parm      ' '           $zrtid            5
     C                   parm      ' '           $zcomp            1
     C                   parm      ' '           $ztzon            6
     C                   parm      0             $zgen             1 0
     C                   parm      ' '           $zszon            6
     C                   parm      ' '           $ztruk           10
     C                   parm      ' '           $zrte             5
     C                   parm                    opzdta
     C                   parm      batch#        $ztrn#            7 0
500bA
500bAC                   else
500bAC                   call      labelpgm
500bAC                   parm      '*REPLEN'     $zcmd             8
500bAC                   parm      $pwhse        $zwhse            3 0
500bAC                   parm      ' '           $zrtid            5
500bAC                   parm      ' '           $zcomp            1
500bAC                   parm      ' '           $ztzon            6
500bAC                   parm      0             $zgen             1 0
500bAC                   parm      ' '           $zszon            6
500bAC                   parm      ' '           $ztruk           10
500bAC                   parm      ' '           $zrte             5
500bAC                   parm                    opzdta
500bAC                   parm      batch#        $ztrn#            7 0
500bAC                   endif

     C                   eval      $plprt = %trim(%editc(labelscreated:'P'))
     C                   eval      $prtn = '*OK'

     C     bottom        tag
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *    Define Partial key for PRPLFIL6 file.

     C     prky6a        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $prplt
     C                   kfld                    $pfail

     C     prky6b        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $prplt

     *    Define Full key for PRPLFIL6 file.

     C     prky6e        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $prplt
     C                   kfld                    prfail
     C                   kfld                    prfloc
     C                   kfld                    prflvl
     C                   kfld                    prfpos
     C                   kfld                    prseq#

500aA*    Define Partial key for PRPLFIL7 file.

500aAC     prky7a        klist
500aAC                   kfld                    $pwhse
500aAC                   kfld                    $pwhdp
500aAC                   kfld                    $prplt
500aAC                   kfld                    $ptail

500aAC     prky7b        klist
500aAC                   kfld                    $pwhse
500aAC                   kfld                    $pwhdp
500aAC                   kfld                    $prplt

500aA*    Define Full key for PRPLFIL7 file.

500aAC     prky7e        klist
500aAC                   kfld                    $pwhse
500aAC                   kfld                    $pwhdp
500aAC                   kfld                    $prplt
500aAC                   kfld                    prtail
500aAC                   kfld                    prtloc
500aAC                   kfld                    prtlvl
500aAC                   kfld                    prtpos
500aAC                   kfld                    prseq#

     *    Define key for OPTIONS file.

     C     opkey         klist
     C                   kfld                    kywhse
     C                   kfld                    kycode
     C                   eval      kycode = '*FEATURE'

     *  Get Feature code

     C                   eval      kycode = '*FEATURE'
     C     opkey         chain     options                            79
     C                   if        *in79
700aMC                   eval      opfeatx = '2'
     C                   endif

     *  Get today's date.

     C                   eval      $cvcmd = '*CURCMD '
     C                   call      'CVTDTE'
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o

     C                   endsr

     *----------------------------------------------------------------
     *  ZZNEXT   Find next priority replenishment.
     *           Based on logic from LT107
     *----------------------------------------------------------------

     C     zznext        begsr

     *    -Skip priority replenishment - Get next replenisment avail.

     C                   if        bypass = *on
500aDC*    prky6e        setgt     prplfil6
500aMC     prky7e        setgt     prplfil7
     C                   endif

     C                   eval      loop = *off
     C                   dow       forever = forever
500aDC*    prky6b        reade     prplfil6                             7879
500aMC     prky7b        reade     prplfil7                             7879
     C                   select
     C                   when      *in79

     *     If end of file is reached and a replenishment was skipped,
     *     reset back to top of file looking for another or same trans.

     C                   if        loop = *off
500aDC*    prky6b        setll     prplfil6
500aMC     prky7b        setll     prplfil7
     C                   eval      loop = *on
     C                   iter
     C                   else
     C                   eval      done = *on
     C                   leave
     C                   endif

     C                   when      *in78  or

     C                             prflag <> 'S'  or

     C                             $pfail > *blanks  and
500aDC*                            prfail < $pfail  or
500aMC                             prtail < $ptail  or

     C                             $pfail > *blanks  and
     C                             prtail > $ptail  or

     *     User selected to skip this replenishment.

     C                             bypass = *on
     C                   iter

     C                   other

     *    Delete replenishment record.

     C                   eval      prflag = 'D'
     C                   update    prrec
     C                   eval      done = *off

     C                   leave

     C                   endsl
     C                   enddo
     C     endnxt        endsr

     *----------------------------------------------------------------
     *  ZZNXT1   Find & create next priority replenishment.
     *           Based on logic from LT107
     *----------------------------------------------------------------

     C     zznxt1        begsr

     C     #nxt1         tag

     C                   exsr      zznext
     C     done          cabeq     *on           endnx1

     C                   eval      $lprg = #prog
     C                   eval      $lcmd = ''
     C                   eval      $luky = dsfkey
700aMC                   eval      $lfeat = opfeatx
     C                   eval      $lrplt = $prplt
     C                   eval      $lcrtt = 'N'
     C                   eval      $ltrn3 = 0
     C                   eval      $lpbat = batch#
     C                   eval      $llbl# = 0

     C                   call      'LT108'
     C                   parm                    $lparm
640aAC                   parm                    $slot
640aAC                   parm                    $slot2

     C                   if        $lrtn = '*NONE'
500aDC*    prky6e        chain     prplfil6                           7978
500aMC     prky7e        chain     prplfil7                           7978
     C                   if        not *in79
     C                   eval      prflag = 'D'
740 AC                   eval      prsdef = '*N'
     C                   update    prrec                                78
     C                   endif
     C                   goto      #nxt1
     C                   endif

     C     endnx1        endsr
