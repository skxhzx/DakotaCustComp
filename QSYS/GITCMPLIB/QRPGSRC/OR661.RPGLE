      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR661     Catchweight report
     *  28 July, 2007
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
510 A*    07/28/07  JCJ  510
     *      - Copied from OR660.
510aA*    08/20/07  RBD  510a
     *      - Removed L1 break so that individual UCICW records
     *        will print.
     *
520 A*    02/05/09  CWM/MLB 5.20   01/26   02/04
     *      - Enh: Added support for new extended stop number.
     *             Retrieve stop# in routine ZZFGTS and PGM GETSTOP
     *
710aA*    11/15/17  JCJ  7.10a
     *      - Enh: Added new stop/drop field.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *  9X        Top of page and level X continues.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     For661     ip   e           k disk
     Fwarehs    if   e           k disk
     Frtehed    if   e           k disk
     For661pr   o    e             printer oflind(*in90)
     F                                     usropn
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D a80             s              1    dim(80)
     D ttl             s             40    dim(1) ctdata perrcd(1)
     D rpd             s             25    dim(5) ctdata perrcd(1)
     D reck            s              7  0 dim(5)
     D lvlk            s              7  0 dim(5)
     *
     D qpck            s              5  0 dim(5)
     D cube            s              9  3 dim(5)
     D wght            s              9  2 dim(5)
     D ovrprt          s             80    dim(1) ctdata perrcd(1)
     *
     *----------------------------------------------------------------
     D @unld           c                   const('Unload Seq:')
     D @comp           c                   const('Compartment:')
     D @palt           c                   const('Pallet:')
     D @tran           c                   const('Tran:')
     *----------------------------------------------------------------
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
     D  $lrtid                22     26
     D  $ltrn#                27     33  0
     D  $lwhdp                34     38
     D  $ldoor                39     41  0
     *
     *----------------------------------------------------------------
     * Data structure
     *
     D opdata          ds
     D  opstyp                 1      1
     D  opwhdp                 2      6
     D  opum1                  7      8
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1
     D  opwum                 58     72
     D  opxdsc                73     73
     D  optend               117    117
     *----------------------------------------------------------------
     * Work Variables
     *
     D $plen           s              3  0
     D $pstr           s             60
     D dtran           s              7
     D first           s              1
     D l               s              1  0
     D lbbat           s              7
     D lstdev          s                   like($dev)
     D lstfrm          s                   like($form)
     D lstwhs          s                   like($whse)
     D m               s                   like(l)
     D opened          s              1
     D pspal           s              2
     D psunl           s              2
     D wktrn#          s              7  0
     D wktype          s              1
     *----------------------------------------------------------------
     Ioqrec
     I                                          pscomp        l4
     I                                          psplid        l3
     I                                          lbitem        l2
     I                                          ohcord        l2
510aDI**                                        ucisq2        l1
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $cmd              8
     C                   parm                    $rtype            8
     C                   parm                    $dev             10
     C                   parm                    $form            10
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Overflow occurred.
     *
     C                   if        *in90  or
     C                             first = *on
     C                   exsr      opnprt
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
510aD***Level 1 break - ORDC record
510aM*  Detail - UCICW record
     *
510aDC**                 if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
510aDC**                 endif
     *
     *  Level 2 break - Order detail line
     *
     C                   if        *inl2
     C                   eval      l = 2
     C                   exsr      zrzero
     C                   endif
     *
     * Left justify order number
     *
     C                   eval      $cstr = *blanks
     C                   eval      ordn# = *blanks
     C                   move      ohcord        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         ordn#
520 AC                   exsr      zzfgts
     *
     *  Level 3 break - Pallet ID/Unload sequence
     *
     C                   if        *inl3
     C                   eval      l = 3
     C                   exsr      zrzero
     *
     C                   if        pstrn# = 0
     C                   eval      wktype = 'B'
     C                   eval      wktrn# = 0
     C                   call      'GETBLTRN'
     C                   parm                    pswhse
     C                   parm                    psrtid
     C                   parm                    pscomp
     C                   parm                    pstzon
     C                   parm                    psgen
     C                   parm                    psszon
     C                   parm                    wktype
     C                   parm                    psunld
     C                   parm                    psrow
     C                   parm                    pscol
     C                   parm                    wktrn#
     C                   else
     C                   eval      wktrn# = lbtrn#
     C                   endif
     *
     *     Get dock door for the transaction.
     *
     C                   eval      $lwhse = pswhse
     C                   eval      $lrtid = psrtid
     C                   eval      $ltrn# = wktrn#
     C                   eval      $lwhdp = *blanks
     C                   eval      $ldoor = 0
     C                   call      'DH900'
     C                   parm                    $lparm
     *
     C                   eval      p#desc = *blanks
     C     p#desc        cat       '** ':1       p#desc
     C     p#desc        cat       @comp:1       p#desc
     C     p#desc        cat       '-':1         p#desc
     C     p#desc        cat       pscomp:1      p#desc
     C     p#desc        cat       '    - ':1    p#desc
     C     p#desc        cat       @unld:1       p#desc
     C                   eval      $cstr = *blanks
     C                   move      psunld        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         psunl
     C     p#desc        cat       psunl:1       p#desc
     C     p#desc        cat       '    - ':1    p#desc
     C     p#desc        cat       @palt:1       p#desc
     C                   move(p)   pspal#        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         pspal
     C     p#desc        cat       pspal:1       p#desc
     *
     C                   eval      $cstr = *blanks
     C                   move      $ltrn#        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         dtran
     C     p#desc        cat       '    - ':1    p#desc
     C     p#desc        cat       @tran:1       p#desc
     C     p#desc        cat       dtran:1       p#desc
     C                   endif
     *
     *  Level 4 break - Compartment
     *
     C                   if        *inl4
     C                   eval      l = 4
     C                   exsr      zrzero
     C                   endif
     *
     *  Print headings.
     *
     C                   if        *in93  or
     C                             *inl3
     C                   write     head2
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *  Accumulate totals
     *
     C                   add       lbqpck        qpck(1)
     C                   add       lbcube        cube(1)
     C                   add       uciwgt        wght(1)
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in94 = *off
     C                   eval      *in93 = *off
     C                   eval      *in91 = *off
     C                   eval      first = *off
     *----------------------------------------------------------------
     *
510aD**ORDC totals
510aM* UCICW records
510aM* The following code IS NOW detail, it WAS total L1.
510aMC                   eval      l = 1
510aMC                   exsr      zrroll
     *
510aMC                   if        reck(l) > 0
510aMC                   if        *in90
510aMC                   exsr      zrhead
510aMC                   endif
510aMC                   exsr      zrtotl
510aMC                   endif
     *----------------------------------------------------------------
     *
     * Order detail line totals
     CL2                 eval      l = 2
     CL2                 exsr      zrroll
     *
     CL2                 if        reck(l) > 0
     CL2                 if        *in90
     CL2                 exsr      zrhead
     CL2                 endif
     CL2                 exsr      zrtotl
     CL2                 endif
     *----------------------------------------------------------------
     *
     * Pallet totals
     *
     CL3                 eval      l = 3
     CL3                 exsr      zrroll
     *
     CL3                 if        reck(l) > 0
     CL3                 if        *in90
     CL3                 exsr      zrhead
     CL3                 endif
     CL3                 exsr      zrtotl
     CL3                 endif
     *----------------------------------------------------------------
     *
     * Compartment totals
     *
     CL4                 eval      l = 4
     CL4                 exsr      zrroll
     *
     CL4                 if        reck(l) > 0
     CL4                 if        *in90
     CL4                 exsr      zrhead
     CL4                 endif
     CL4                 exsr      zrtotl
     CL4                 endif
     *----------------------------------------------------------------
     *
     * Batch totals
     *
     CLr                 eval      l = 5
     *
     CLr                 if        reck(l) > 0
     CLr                 if        *in90
     CLr                 exsr      zrhead
     CLr                 endif
     CLr                 exsr      zrtotl
     CLr                 write     foot1
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
     *
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 1
     C                   exsr      zrzero
     *
     *  Variables and constants.
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Get device and form type for department.
     *
     C                   if        pswhse <> lstwhs  and
     C                             $dev = '*JOB'
     *
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd
     C                   parm      'OR661PR '    $lrpt            10
     C                   parm      pswhse        $whse             3 0
     C                   parm      ' '           $styp             1
     C                   parm      ' '           $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev
     C                   parm                    $form
     C                   eval      lstwhs = $whse
     C                   endif
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on  or
     C                             $dev <> lstdev  or
     C                             $form <> lstfrm
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C                   close     or661pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OR661PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *
     C                   movea     ovrprt(1)     a80
     C                   movea     $dev          a80(39)
     C                   movea     $form         a80(60)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *      Open printer file.
     *
     C                   open      or661pr
     C                   eval      opened = *on
     C                   eval      lstdev = $dev
     C                   eval      lstfrm = $form
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Format report title.
     *
     C                   eval      title = ttl(1)
     C                   movel     title         $pstr
     C                   eval      $plen = 40
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         title
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     lbwhse        chain     warehs                             79
     C                   if        not *in79
     C                   movel     whdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 30
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     *
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         lbbat
     *
     *   Format Route number.
     *
     C     rtkey         klist
     C                   kfld                    pswhse
     C                   kfld                    psrtid
     C     rtkey         chain     rtehed                             79
     C                   if        *in79
     C                   eval      rhrte = *blanks
     C                   endif
     C                   eval      batch = *blanks
     C                   eval      $pstr = *blanks
     C     batch         cat       'Route:':1    batch
     C     batch         cat       rhrte:1       batch
     C                   movel     batch         $pstr
     C                   eval      $plen = 30
     *
     *   Center batch/route description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         batch
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   if        not *inl4
     C                   eval      *in94 = *on
     C                   endif
     *
     C                   if        not *inl3
     C                   eval      *in93 = *on
     C                   endif
     *
     C                   if        not *inl2
     C                   eval      *in92 = *on
     C                   endif
     *
510aDC**                 if        not *inl1
     C                   eval      *in91 = *on
510aDC**                 endif
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
     C                   write     columns
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrroll        begsr
     *
     C     l             add       1             m
     *
     C                   add       1             lvlk(m)
     C                   add       reck(l)       reck(m)
     *
     C                   add       qpck(l)       qpck(m)
     C                   add       cube(l)       cube(m)
     C                   add       wght(l)       wght(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   eval      t#wght = wght(l)
     *
     C                   eval      $rpd = rpd(l)
     *
     C                   if        l = 1
     C                   write     detail1
     C                   endif
     *
     C                   if        l = 2
     C                   write     skip1
     C                   write     total1
     C                   endif
     *
     C                   if        l = 3
     C                   write     skip1
     C                   write     total2
     C                   endif
     *
     C                   if        l = 4
     C                   write     skip1
     C                   write     total3
     C                   endif
     *
     C                   if        l = 5
     C                   write     skip1
     C                   write     total4
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     *
     *                    Z-ADD0         CLS,L
     C                   eval      qpck(l) = 0
     C                   eval      cube(l) = 0
     C                   eval      wght(l) = 0
     *
     C                   endsr
     C*----------------------------------------------------------------
     C*
520 AC*  ZZFGTS   Get Host Stop Number
520 AC*
520 AC     ZZFGTS        BEGSR
520 AC*
520 AC*    Get Stop From RTESTP
520 AC*
520 AC                   CALL      'GETSTOP'
520 MC                   PARM      '*ORDSTP '    $SCMD             8
520 MC                   PARM      LBWHSE        $SWHSE            3 0
520 MC                   PARM      LBRTE         $SRTID            5
520 MC                   PARM      LBORD         $SORD             7 0
520 MC                   PARM      0             $SDSTP            2 0
520 MC                   PARM                    $SSTP             5 0
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
520 AC*
520 AC                   if         $sstp > 0
520 MC                   eval      dspstp = $sstp
520 AC                   else
520 AC                   eval      dspstp = lbstop
520 AC                   endif
520 AC*
520 AC                   ENDSR
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      TTL   Report title description
Truck Pallet Catchweight Report
**      RPD   Report level descriptions

 * Dtl Line totals *
 ** Pallet totals **
 *** Compartment totals ***
 **** Totals ****
**   OVRPRTF statment
OVRPRTF FILE(OR661PR)  OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
