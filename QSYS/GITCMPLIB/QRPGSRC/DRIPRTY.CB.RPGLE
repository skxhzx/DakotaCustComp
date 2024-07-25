     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  DRIPRTYRPL  Dakota realtime interface - Priority replenishments
     *  20 October 2001
     *  Dave Sommerville
     *
416  *    10/30/01  DAS  4.16
     *      - Created
     *
416a *    01/11/02  DAS  4.16a
     *      - Added subcommands *CRTRPLSEQ and *SEQPRTRPL.
     *      - Added SLOT2 file.
     *      - Replaced call to DRISLOT with subroutine drislotsr
     *        because it created a recursive call.
     *
416b *    02/22/02  DAS  4.16b
     *      - Revised chk4rpl routine to delete any 'D' records.
     *
416c *    02/25/02  DAS  4.16c
     *      - Revised createrpl to not check for existing repl.
     *      - Revised createrpl to delete all open priority replenishments
     *        for item first.
     *      - Added routine updprtyrpl.
     *
416d *    03/06/02  DAS  4.16d
     *      - Revised updprtyrpl to iter after deleting record.
     *      - Revised addprtyrpl to init prflag after getting seq#.
     *
416eA*    06/11/02  DAS  4.16e
     *      - Recompiled because of change to C#SLOT.
     *
417 A*    07/22/03  MLB  4.17
     *      - Enh: Revised program to update new fields added to
     *        PRPLFIL.
417aA*    09/09/03  MLB  4.17a
     *      - Enh: Revised program to set replenishment type flag.
     *      - Enh: Added *LICENSE options record to program.
      *
417bA*    12/30/03  DAS  4.17b
     *      - Enh: Added *CRTRPLSQ1 through *CRTRPLSQ9. See notes.
     *
417cA*    01/05/04  RH   4.17c
     *      - Enh: Do not delete Just in time replenishments (priority <>0)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Custom Mods
     *
CBIaA*    02/03/04  DAS  CBIa
     *      - Enh: Revised to added Container/Cruise pick/allocated qtys
     *        into the pick slot's available qty.
     *
     *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *    Sub-Commands
      *
      *      *OPEN             Open program and return.
      *
      *      *CLOSE            Close program with *INLR = *ON
      *
      *      *CRTRPL           Create priority replenishment.
      *                        Don't assign seq#. Assigned with *SEQPRTRPL.
      *
      *      *CRTRPLDKA        Create priority repl using Dakota avg sales.
      *
      *      *CRTRPLSEQ        Create priority replenishment.
      *                        Assign seq# immediately.
417bA *                        Set priority to 0.
      *
417bA *      *CRTRPLSQ1 - 9    Create priority replenishment.
417bA *                        Assign negative seq# immediately.
417bA *                        Set priority to last character (1-9).
      *
      *      *REMOVE           Remove open priority replenishements
      *
416aA *      *SEQPRTRPL        Sequence priority replenishements
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fprplfil   uf a e           k disk
     F                                     infds(file1ds)
416bDF**plfil4  if   e           k disk
416bMFprplfil4  uf   e           k disk
     F                                     infds(file2ds)
     F                                     rename(prrec:prrec4)
416aAFprplfil1  if   e           k disk
416aAF                                     rename(prrec:p1rec)
416aAFprplfil2  uf   e           k disk
416aAF                                     rename(prrec:p2rec)
416aAFprplfil3  uf   e           k disk
416aAF                                     rename(prrec:p3rec)
     Fitemavg   if   e           k disk
     Fslotdef   if   e           k disk
     Fslot3     if   e           k disk
     F                                     infds(file3ds)
     Fslot2     if   e           k disk
416aAF                                     rename(slrec:s2rec)
     Foptions   if   e           k disk
     Flogprtyrplo    e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#PRTYRPL
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($prver#)
     D driitem         s               n
     D drislot         s               n

     *----------------------------------------------------------------
     *  Computed slot quantities.
     *----------------------------------------------------------------

     D slphy1          s                   like(slstk1)
     D slphy2          s                   like(slstk2)
     D slphy3          s                   like(slstk3)
     D slavl1          s                   like(slstk1)
     D slavl2          s                   like(slstk2)
     D slavl3          s                   like(slstk3)
     D sladj1          s                   like(slstk1)
     D sladj2          s                   like(slstk2)
     D sladj3          s                   like(slstk3)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcount         s              3p 0
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vitem          s                   like($slitem)
     D $vwhdp          s                   like($slwhdp)
     D $vwhse          s              3p 0

     D vfywhdp         s               n
     D vfywhse         s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D addrplflag      s               n
     D check4err       s               n
     D curdate         s              8  0
     D curdef          s              3  0
     D curtime         s              6  0
     D duration        s              7  2
     D d               s              1  0
     D dshigh          s              2  0
     D dspqty          s              5  0
     D dstie           s              4  0
     D dstqty          s              7  0
     D dummy           s                   like(slloc)
     D emptylayer      s              7  0
     D emptyq          s              7  0
     D error           s               n
     D forever         s               n   inz(*on)
     D found           s               n
     D foundpslot      s               n
     D foundtihi       s               n
     D fromdate        s              8  0
     D fromtime        s              6  0
     D homeavlqty      s              7  0
     D homeemplayer    s              7  0
     D homeempqty      s              7  0
     D homehigh        s              2  0
     D homelayer       s              7  0
     D homepltqty      s              7  0
     D hometie         s              4  0
     D homettlqty      s              7  0
     D item#           s                   like(slitem)
     D kyaisl          s                   like(slaisl)
     D kycode          s                   like(opcode)
     D kyentd          s                   like(slentd)
     D kyexpd          s                   like(slexpd)
     D kyhand          s                   like(slhand)
     D kyitem          s                   like(slitem)
     D kyitem2         s                   like(slitem)
     D kypick          s                   like(slpick)
     D kyprty          s                   like(slprty)
     D kypseq          s                   like(slpseq)
     D kyrlvl          s                   like(slrlvl)
     D kysdef          s                   like(slsdef)
     D kystat          s                   like(slstat)
     D kystyp          s                   like(slstyp)
     D kywhdp          s                   like(slwhdp)
     D lasttime        s              6  0 inz(999999)
     D lastwhse        s                   like(prwhse)
     D                                     inz(-1)
     D layer           s              5  0
     D locator         s               n
     D lock            s               n
     D lstseq          s                   like(prseq#)
417bAD maxseq#         s                   like(prseq#)
417bAD minseq#         s                   like(prseq#)
     D n               s                   like(prseq#)
     D nextseq#        s                   like(prseq#)
     D ovravlqty       s              7  0
     D pallet          s              7  0
417aAD picksdef        s                   like(slsdef)
     D pssrflag        s               n
     D qtyneeded       s              7  0
417aAD rpltype         s              1
     D saveavail       s                   like($slavl1)
     D savepick        s                   like(sldisp)
     D savewhdp        s                   like(slwhdp)
     D svavl1          s                   like($slavl1)
     D startover       s               n
417bAD temp1n          s              1s 0
     D todate          s              8  0
     D totime          s              6  0
     D today           s              8  0
     D topick          s              7  0
     D updflag         s               n
     D warningtype     s                   like($psubcmd)

     D $kaqs           s                   like(praqs)
     D $kfail          s                   like(prfail)
417bAD $kseq#          s                   like(prseq#)
     D $ktail          s                   like(prtail)
     D $ktdis          s                   like(prtdis)
     D $kwhdp          s                   like(prwhdp)
     D $kwhse          s                   like(prwhse)
     D $prplb          s              8

     *----------------------------------------------------------------
     *  Field/array overlay
     *----------------------------------------------------------------

     D aqsds           ds
     D  igaqs1                 1      7  2
     D  igaqs2                 8     14  2
     D  igaqs3                15     21  2
     D  igaqs4                22     28  2
     D  igaqs5                29     35  2
     D  igaqs6                36     42  2
     D  igaqs7                43     49  2
     D  igaqsw                50     56  2
     D  aqs                    1     56  2
     D                                     DIM(8)

     *----------------------------------------------------------------
     *  *FEATURE  -  PIR Feature options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFEAT  -  PIR Installed feature.
     *
     * Data structure
     *
     D opdata          ds
     D  opfeat                 1      1
     D  optend               117    117

417aA*----------------------------------------------------------------
417aA*  *LICENSE  -  License Plate Tracking options
417aA*----------------------------------------------------------------
417aA*
417aA* Fields
417aA*
417aA*    OPLPTR  -  Allow license plate tracking.  (Y/N)
417aA*    OPLPAL  -  Track All items.  (Y/N)
417aA*    OPLPDS  -  Track All date sensitive items.
417aA*    OPLPLC  -  Track All lot code items.  (Y/N)
417aA*    OPLPCW  -  Track All catchweight items.  (Y/N)
417aA*    OPTKSP  -  Track All push back slot positions. (Y/N)
417aA*
417aA* Data structure
417aA*
417aAD opdatl          ds
417aAD  Oplptr                 1      1
417aAD  Oplpal                 2      2
417aAD  Oplpds                 3      3
417aAD  Oplplc                 4      4
417aAD  Oplpcw                 5      5
417aAD  Optksp                 6      6
417aAD  Optenl               117    117

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

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
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

     D File1DS         ds
     D  f1filename             1      8
     D  f1openind              9      9
     D  f1endoffile           10     10
     D  f1status              11     15  0
     D  f1opercode            16     21
     D  f1routine             22     29
     D  f1stmtnbr             30     37
     D  f1recordcd            38     45
     D  f1messageid           46     52
     D  f1sourceid            53     54

     D File2DS         ds
     D  f2filename             1      8
     D  f2openind              9      9
     D  f2endoffile           10     10
     D  f2status              11     15  0
     D  f2opercode            16     21
     D  f2routine             22     29
     D  f2stmtnbr             30     37
     D  f2recordcd            38     45
     D  f2messageid           46     52
     D  f2sourceid            53     54

     D File3DS         ds
     D  f3filename             1      8
     D  f3openind              9      9
     D  f3endoffile           10     10
     D  f3status              11     15  0
     D  f3opercode            16     21
     D  f3routine             22     29
     D  f3stmtnbr             30     37
     D  f3recordcd            38     45
     D  f3messageid           46     52
     D  f3sourceid            53     54

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
      *      $pmessage  Return code
      *      $pdata     Data returned by command
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd
     C                   parm                    $pprogram
     C                   parm                    $preturn
     C                   parm                    $pmessage
     C                   parm                    $pdata

     C                   eval      $prtyrpl = $pdata
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See if we are just opening or closing program.

     C                   select

     C                   when      $psubcmd = '*OPEN'
     C                   goto      bottom

     C                   when      $psubcmd = '*CLOSE'
     C                   exsr      zzzclose
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Otherwise, do some initialization and move on.

     C                   exsr      aaainit
     C                   eval      error = *off

     *  Do what user has requested.

     C                   select

     C                   when      $psubcmd = '*CRTRPL'    or
     C                             $psubcmd = '*CRTRPLDKA' or
417bMC                             $psubcmd = '*CRTRPLSEQ' or
417bAC                             $psubcmd = '*CRTRPLSQ1' or
417bAC                             $psubcmd = '*CRTRPLSQ2' or
417bAC                             $psubcmd = '*CRTRPLSQ3' or
417bAC                             $psubcmd = '*CRTRPLSQ4' or
417bAC                             $psubcmd = '*CRTRPLSQ5' or
417bAC                             $psubcmd = '*CRTRPLSQ6' or
417bAC                             $psubcmd = '*CRTRPLSQ7' or
417bAC                             $psubcmd = '*CRTRPLSQ8' or
417bAC                             $psubcmd = '*CRTRPLSQ9'
     C                   exsr      verifygen
     C                   if        not error
     C                   exsr      verifycrt
     C                   endif
     C                   if        not error
     C                   exsr      createrpl
     C                   endif

     C                   when      $psubcmd = '*REMOVE'
     C                   exsr      verifygen
     C                   if        not error
     C                   exsr      verifyrmv
     C                   endif
     C                   if        not error
     C                   exsr      remove
     C                   endif

416aAC                   when      $psubcmd = '*SEQPRTRPL'
416aAC                   exsr      verifygen
416aAC                   if        not error
416aAC                   exsr      seqprtyrpl
416aAC                   endif

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
     C                   exsr      getmsg

     C                   endsl

     C     bottom        tag

     *  We are finished so get out

     C                   eval      $pdata = $prtyrpl
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     *  Define partial keys for PRPLFIL.

     C     keyprw        klist
     C                   kfld                    $prwhse

     C     keyprd        klist
     C                   kfld                    $prwhse
     C                   kfld                    $prwhdp
417bA
417bA*  Define key for PRPLFIL1
417bA
417bAC     keypr1        klist
417bAC                   kfld                    $prwhse
417bAC                   kfld                    $prwhdp
417bAC                   kfld                    $kseq#

     *  Define key for PRPLFIL4

     C     keypr4        klist
     C                   kfld                    $prwhse
     C                   kfld                    $pritem

     *  Define key for ITEMAVG

     C     keyig         klist
     C                   kfld                    $prwhse
     C                   kfld                    $pritem

     *  Define key for SLOT2 file.

     C     keysl2        klist
     C                   kfld                    $slwhse
     C                   kfld                    $slwhdp
     C                   kfld                    $sldisp

     *  Define partial key for SLOT3 file.

     C     keys3         klist
     C                   kfld                    $prwhse
     C                   kfld                    kyitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     *
     *  Define partial key for SLOT3 file including dates.
     *
     C     keys3b        klist
     C                   kfld                    $prwhse
     C                   kfld                    kyitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     C                   kfld                    kyprty
     C                   kfld                    kyexpd
     C                   kfld                    kyentd
     *
     *  Define full key for SLOT3 file.
     *
     C     keys3c        klist
     C                   kfld                    $prwhse
     C                   kfld                    kyitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     C                   kfld                    kyprty
     C                   kfld                    kyexpd
     C                   kfld                    kyentd
     C                   kfld                    kywhdp
     C                   kfld                    kystyp
     C                   kfld                    kyaisl
     C                   kfld                    kypseq
     C                   kfld                    kyrlvl
     C                   kfld                    kyhand

     *  Define key for SLOTDEF file.

     C     keysd         klist
     C                   kfld                    $prwhse
     C                   kfld                    kysdef

     *  Define key for OPTIONS file.

     C     keyop         klist
     C                   kfld                    $prwhse
     C                   kfld                    kycode

     *  Define key for PRPLFIL2 file.

     C     keypr2        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kwhdp
     C                   kfld                    $kaqs
     C                   kfld                    $kfail
     C                   kfld                    $ktail

     *    Define key for PRPLFIL3 file.

     C     keypr3        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kwhdp
     C                   kfld                    $ktail
     C                   kfld                    $ktdis

     C                   endsr

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr

     *  Make sure we don't get caught in an infinite loop

 1B  C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

     *  Send message back to calling program.

     C                   eval      $preturn = 'U:' + #status
     C                   eval      $pmessage = 'U:'
     C                                       + %trim(#prog)
     C                                       + '('
     C                                       + %trim(%editc(#stmt:'Z'))
     C                                       + ')-'
     C                                       + #pgmmsg
     C                   eval      *inlr = *on
 1E  C                   return

     C                   endsr

     *----------------------------------------------------------------
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

     C     aaainit       begsr

     *  Initialize log fields

     C                   clear                   lgprrec

     *  Convert today's date into century format.

     C                   exsr      getdatetime
     C                   eval      today = curdate

     *  Convert today's date into day number.

     C                   eval      $cvcmd = '*CMDNBR '
     C                   move      today         $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      d = $cvd6o

     C                   if        $prwhse <> lastwhse
     C                   eval      lastwhse = $prwhse
417aA
417aA*    Retrieve FS-WMS License options code.
417aA
417aAC                   eval      kycode = '*LICENSE'
417aAC     keyop         chain     options
417aAC                   if        not %found
417aAC                   eval      oplptr = 'N'
417aAC                   eval      optksp = 'N'
417aAC                   else
417aAC                   eval      opdatl = opdata
417aAC                   endif

     *    Retrieve FS-WMS installed feature code.

     C                   eval      kycode = '*FEATURE'
     C     keyop         chain     options
 1B  C                   if        not %found or opfeat = '2'
     C                   eval      locator = *off
 1E  C                   else
     C                   eval      locator = *on
 1E  C                   endif
 1E  C                   endif

     C                   endsr

CBIaA*----------------------------------------------------------------
CBIaA*  addccqty    Add container/cruise qtys to avail qtys.
CBIaA*----------------------------------------------------------------
CBIaA
CBIaAC     addccqty      begsr

     *  Get picked/allocated qtys associated with container/cruise ord

     C                   call      'CCQTY'
     C                   parm                    $slwhse
     C                   parm                    $slitem
     C                   parm                    $slstyp
     C                   parm                    $slwhdp
     C                   parm                    $slaisl
     C                   parm                    $slpseq
     C                   parm                    $slrlvl
     C                   parm                    $slhand
     C                   parm                    $ccpck1           5 0
     C                   parm                    $ccpck2           3 0
     C                   parm                    $ccpck3           3 0
     C                   parm                    $ccalc1           5 0
     C                   parm                    $ccalc2           3 0
     C                   parm                    $ccalc3           3 0

     *  Add CC qtys to slot available qtys.

     C                   eval      $slavl1 = $slavl1+$ccpck1+$ccalc1
     C                   eval      $slavl2 = $slavl2+$ccpck2+$ccalc2
     C                   eval      $slavl3 = $slavl3+$ccpck3+$ccalc3

     C                   endsr

     *----------------------------------------------------------------
     *  addprtyrpl  Add priority replenishment record
     *----------------------------------------------------------------

     C     addprtyrpl    begsr

     *  Initialize flag and sequence number.

     C                   if        $psubcmd = '*CRTRPLSEQ'
417bAC                             or $psubcmd = '*CRTRPLSQ1'
417bAC                             or $psubcmd = '*CRTRPLSQ2'
417bAC                             or $psubcmd = '*CRTRPLSQ3'
417bAC                             or $psubcmd = '*CRTRPLSQ4'
417bAC                             or $psubcmd = '*CRTRPLSQ5'
417bAC                             or $psubcmd = '*CRTRPLSQ6'
417bAC                             or $psubcmd = '*CRTRPLSQ7'
417bAC                             or $psubcmd = '*CRTRPLSQ8'
417bAC                             or $psubcmd = '*CRTRPLSQ9'
416dDC**                 eval      prflag = 'S'
     C                   exsr      getnxtseq
     C                   eval      prseq# = nextseq#
416dAC                   eval      prflag = 'S'
     C                   else
     C                   eval      prflag = ' '
     C                   eval      prseq# = 0
     C                   endif

     *  Check to see if replenishment will free up a slot?

 1B  C                   if        topick <> slavl1
     C                   eval      prfree = 'N'
 1X  C                   else
     C                   eval      prfree = 'Y'
 1E  C                   endif

     *  Add records to work file.

     C                   eval      prwhse = $slwhse
     C                   eval      prwhdp = $slwhdp
     C                   eval      prfail = slaisl
417 AC                   eval      prfloc = slloc
417 AC                   eval      prflvl = slrlvl
417 AC                   eval      prfhnd = slhand
     C                   eval      prtail = $slaisl
417 AC                   eval      prtloc = $slloc
417 AC                   eval      prtlvl = $slrlvl
417 AC                   eval      prthnd = $slhand
     C                   eval      prfdis = sldisp
     C                   eval      prtdis = $sldisp
     C                   eval      pritem = $slitem
     C                   eval      prqty  = topick
     C                   eval      prsdef = slsdef
     C                   eval      prstat = $slstat
417bAC                   if         $psubcmd = '*CRTRPLSQ1'
417bAC                             or $psubcmd = '*CRTRPLSQ2'
417bAC                             or $psubcmd = '*CRTRPLSQ3'
417bAC                             or $psubcmd = '*CRTRPLSQ4'
417bAC                             or $psubcmd = '*CRTRPLSQ5'
417bAC                             or $psubcmd = '*CRTRPLSQ6'
417bAC                             or $psubcmd = '*CRTRPLSQ7'
417bAC                             or $psubcmd = '*CRTRPLSQ8'
417bAC                             or $psubcmd = '*CRTRPLSQ9'
417bAC                   move      $psubcmd      prprty
417bAC                   else
     C                   eval      prprty = 0
417bAC                   endif
     C                   eval      prtype = $ittype
417aAC                   eval      prrplt = rpltype
     C                   exsr      getdatetime
     C                   eval      pradte = curdate
     C                   eval      pratim = curtime
     C                   eval      praqs  = qtyneeded

     C                   write(e)  prrec
     C                   if        %error
     C                   endif

     *  write record to log file.

     C                   eval      lgprcrt  = 'Y'
     C                   eval      lgprowhd = slwhdp
     C                   eval      lgproslt = sldisp
     C                   eval      lgproavl = slavl1
     C                   exsr      writelog

     C     endadd        endsr

     *----------------------------------------------------------------
     *  calcovrflw    Calculate overflow available quantity
     *----------------------------------------------------------------

     C     calcovrflw    begsr

     C                   eval      ovravlqty = 0

     *  Whip through all active overflow slots for item.

     C                   eval      kyitem = $pritem
     C                   eval      kystat = 'A'
     C                   eval      kypick = 'N'
     C     keys3         setll     slot3

     C                   dow       forever = forever

     C     keys3         reade     slot3

     C                   if        %eof
     C                   leave
     C                   endif

     *    Calculate available slot qty.

     C                   exsr      calcqtys
     C                   eval      ovravlqty = ovravlqty + slavl1

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  calcqtys  Calculate slot quantities.
     *
     *     *** This routine should be identical to the one ***
     *     *** in program DRISLOT.                         ***
     *
     *----------------------------------------------------------------

     C     calcqtys      begsr

     *  Calculate physical quantity in slot.

     *    Note: The quantities that are used to calculate the physical
     *          slot quantity are part of processes which should be
     *          completed soon. We can not wait until the processes
     *          are closed to say the stock is or isn't there.

     *          For example: A replenishment request can not be refused
     *          because the picks that depleted the slot have not been
     *          closed yet. Timing is everything.

     C                   eval      slphy1 = (slstk1+slrcv1)-(sltfr1+slpck1)
     C                   eval      slphy2 = (slstk2+slrcv2)-(sltfr2+slpck2)
     C                   eval      slphy3 = (slstk3+slrcv3)-(sltfr3+slpck3)

     *  Calculate available quantity in slot.

     C                   eval      slavl1 = slphy1 - slalc1
     C                   eval      slavl2 = slphy2 - slalc2
     C                   eval      slavl3 = slphy3 - slalc3

     *  Calculate adjustable quantity in slot.

     C                   eval      sladj1 = slavl1 - slrcv1
     C                   eval      sladj2 = slavl2 - slrcv2
     C                   eval      sladj3 = slavl3 - slrcv3

     C                   endsr

     *----------------------------------------------------------------
     *  clearerrflags  Clear error flag fields.
     *----------------------------------------------------------------

     C     clearerrflags begsr

     C                   if        $prwhsee = '1'
     C                   eval      $prwhsee = '0'
     C                   endif

     C                   if        $priteme = '1'
     C                   eval      $priteme = '0'
     C                   endif

     C                   if        $prwhdpe = '1'
     C                   eval      $prwhdpe = '0'
     C                   endif

     C                   if        $prslote = '1'
     C                   eval      $prslote = '0'
     C                   endif

     C                   if        $prqtyne = '1'
     C                   eval      $prqtyne = '0'
     C                   endif

     C                   if        $prqtywe = '1'
     C                   eval      $prqtywe = '0'
     C                   endif

     C                   if        $prfille = '1'
     C                   eval      $prfille = '0'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  chk4rpl    Check if replenishment already exists
     *----------------------------------------------------------------

     C     chk4rpl       begsr

     *  See if replenishment already exists.

     C     keypr4        setll     prplfil4

     C                   dow       forever = forever

     C     keypr4        reade     prplfil4

     C                   if        %eof
     C                   leave
     C                   endif

416bAC                   if        prflag = 'D'
416bAC                   delete(e) prrec4
416bAC                   if        %error
416bAC                   endif
416bAC                   iter
416bAC                   endif

     C                   if        $prslotu and prtdis <> $prslot
     C                   iter
     C                   endif

416bAC                   unlock    prplfil4
     C                   eval      error = *on
     C                   eval      $preturn  = 'REPLEXIST'
     C                   exsr      getmsg
     C                   if        $psubcmd = '*CRTSLTRPL'
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   endif
     C                   exsr      writelog
     C                   leave

     C                   enddo

     C     endchk4rpl    endsr

     *----------------------------------------------------------------
     *  createrpl  Create replenishment
     *----------------------------------------------------------------

     C     createrpl     begsr

     *  See if replenishment already exists.

416cDC**                 exsr      chk4rpl
416cDC**                 if        error
416cDC**                 goto      endcreaterpl
416cDC**                 endif

     *  Get quantity needed.

 1B  C                   exsr      getqtyneeded
 1B  C                   if        error
     C                   goto      endcreaterpl
     C                   endif

     *  Get slot to fill.

 1B  C                   exsr      getslt2fil
 1B  C                   if        error
     C                   goto      endcreaterpl
     C                   endif

     *  At this point ...

     *    - We have the pick slot we are going to replenish.
     *    - We have already calculated the total qty the slot can hold.
     *    - We have already determined the qty of a single layer.
     *    - We have already calculated the empty qty of the slot.
     *    - We have already calculated the quantity needed.

     *  Now, see if replenishment needs to be done.

 1B  C                   exsr      rplcriteria
 1B  C                   if        error
     C                   goto      endcreaterpl
     C                   endif

     *  We passed the tests.
417aA*
417aA*  Set the replenishment type flag.
417aA*
417aAC                   Exsr      setrpltype

     *  If item is a broken case item, then get base item information.

 3B  C                   if        $ittype = 'B'
     C                   exsr      getbase
 1B  C                   if        error
     C                   goto      endcreaterpl
     C                   endif
 3E  C                   endif

     *  Reduce quantity needed by home slot available quantity.

 1B  C                   eval      qtyneeded = qtyneeded - homeavlqty

     *  Create replenishment.

 1B  C                   select

 1X  C                   when      $ittype = ' '
     C                   exsr      crtnorm

 1X  C                   when      $ittype = 'B' and #bstyp = 'F'
     C                   exsr      crtbrkfix

 1X  C                   when      $ittype = 'B' and #bstyp = 'P'
     C                   exsr      crtbrkpir

 1E  C                   endsl

     C     endcreaterpl  endsr

     *----------------------------------------------------------------
     *  crtbrkfix  Create replenishment for brokencase item
     *              where base item is in Fixed section.
     *----------------------------------------------------------------

     C     crtbrkfix     begsr
     C                   eval      addrplflag = *off
     C                   eval      foundpslot = *off

     *   Loop through picking slot for breakdown item.

     C                   eval      kyitem = #bitem
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keys3         setll     slot3
 1B  C                   dow       forever = forever
     C     keys3         reade     slot3                                7879

     *     Item does not have a pick slot, replenish from overflow slots.

 2B  C                   if        *in79 and not foundpslot
     C                   exsr      crtbrkovr
 1L  C                   leave
 2E  C                   endif

     *     If record is locked, try to get next one.

 2B  C                   if        *in78
 1L  C                   iter
 2E  C                   endif

     *     Ignore slot if past expiration date.

 2B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
     C                   iter
 2E  C                   endif

     *     Ignore slot if nothing available in slot.

     C                   exsr      calcqtys
 2B  C                   if        slavl1 <= 0
     C                   iter
 2E  C                   endif

     *     Found a usable pick slot.

     C                   eval      foundpslot = *on

     *     Calculate quantity to pick.

 2B  C                   select

     *       When filling to needed qty and that qty is > home empty qty
     *         Then calculate qty to pick based on needed qty.

 2B  C                   when      $prfillu and $prfill = 'Y' and
 2B  C                             qtyneeded > homeempqty
     C                   eval      topick = (qtyneeded / #bumq2)
     C                   if        topick * #bumq2 < qtyneeded
     C                   eval      topick = topick + 1
     C                   endif

     *       Otherwise, calculate qty to pick based on home empty qty.

 2B  C                   other
     C                   eval      topick = (homeempqty / #bumq2)
     C                   if        topick * #bumq2 < homeempqty
     C                   eval      topick = topick + 1
     C                   endif

     C                   endsl

     *     Make sure pick quantity isn't greater than available quantity.

     C                   if        topick > slavl1
     C                   eval      topick = slavl1
     C                   endif
416cA
416cA*     See if existing replenishment record can be updated.
416cA
416cAC                   exsr      updprtyrpl
416cAC                   if        updflag = *on
416cAC                   eval      addrplflag = *on
416cAC                   endif

     *     Create priority replenishment.

416cAC                   if        updflag = *off
     C                   exsr      addprtyrpl
     C                   eval      addrplflag = *on
416cAC                   endif

     *     Reduce empty and needed quantities.

     C                   eval      homeempqty = homeempqty - (topick*#bumq2)
     C                   eval      qtyneeded  = qtyneeded - (topick*#bumq2)

     *     If we got what we needed, get out.

 2B  C                   if        qtyneeded <= 0
 2B  C                   leave
 2B  C                   endif

     *     If we are not trying to fill need and slot is full, get out.

 2B  C                   if        not $prfillu or $prfill <> 'Y'
 2B  C                   if        homeempqty <= 0
 2B  C                   leave
 2B  C                   endif
 2B  C                   endif

     *     Otherwise, we loop around and try for another replenishment.

 1E  C                   enddo

     *  Throw error if a replenishment was not created.

 2B  C                   if        not addrplflag
     C                   eval      error = *on
     C                   eval      $preturn  = 'NOFULLCASE'
     C                   exsr      getmsg
     C                   exsr      writelog
 2E  C                   endif

     C     pickfe        endsr

     *----------------------------------------------------------------
     *  crtbrkovr  Create replenishment for brokencase item
     *              where base item does not have a pick slot.
     *----------------------------------------------------------------

     C     crtbrkovr     begsr

     *   Loop through replenishment slots for item.

     C                   eval      kyitem = #bitem
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'N'
     C     keys3         setll     slot3
 1B  C                   dow       forever = forever
     C     keys3         reade     slot3                                7879
 2B
 2B  C                   if        *in79
 1L  C                   leave
 2E  C                   endif
 2B
 2B  C                   if        *in78
 1L  C                   iter
 2E  C                   endif

     *     Ignore slot if no normal stock or past expiration date.

 2B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
 1I  C                   iter
 2E  C                   endif

     *     Calculate quantity available in slot.

     C                   exsr      calcqtys
 2B  C                   if        slavl1 <= 0
 1I  C                   iter
 2E  C                   endif

     *     Save slot information and available quantities.

     C                   eval      kyprty = slprty
     C                   eval      kyexpd = slexpd
     C                   eval      kyentd = slentd
     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand

     C                   eval      svavl1 = slavl1

     *     Loop through slots with same priority and dates.
     *     We want the slot with the least quantity available.

 2B  C                   dou       forever <> forever
     C     keys3b        reade     slot3                                  76
 3B  C                   if        *in76
 2L  C                   leave
 3E  C                   endif

     *        Ignore slot if past expiration date.

 3B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
 2I  C                   iter
 3E  C                   endif

     *        Calculate quantity available in slot.

     C                   exsr      calcqtys

 3B  C                   if        slavl1 <= 0
 2I  C                   iter
 3E  C                   endif

     *        If this slot has the least qty available then
     *        save slot information and available quantities.

 3B  C                   if        slavl1 <= svavl1

     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand

     C                   eval      svavl1 = slavl1

 3E  C                   endif

 2E  C                   enddo

     *     Get the selected slot.

     C     keys3c        chain     slot3                              76
 2B  C                   if        *in76
 1I  C                   iter
 2E  C                   endif

     *     Ignore slot if past expiration date.

 2B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
 1I  C                   iter
 2E  C                   endif

     *     Calculate quantity available in slot.

     C                   exsr      calcqtys
 2B  C                   if        slavl1 <= 0
 1I  C                   iter
 2E  C                   endif

     *     Calculate quantity to pick.

 2B  C                   select

     *       When filling to needed qty and that qty is > home empty qty
     *         Then calculate qty to pick based on needed qty.

 2B  C                   when      $prfillu and $prfill = 'Y' and
 2B  C                             qtyneeded > homeempqty
     C                   eval      topick = (qtyneeded / #bumq2)
     C                   if        topick * #bumq2 < qtyneeded
     C                   eval      topick = topick + 1
     C                   endif

     *       Otherwise, calculate qty to pick based on home empty qty.

 2B  C                   other
     C                   eval      topick = (homeempqty / #bumq2)
     C                   if        topick * #bumq2 < homeempqty
     C                   eval      topick = topick + 1
     C                   endif

     C                   endsl

     *     Make sure pick quantity isn't greater than available quantity.

     C                   if        topick > slavl1
     C                   eval      topick = slavl1
     C                   endif
416cA
416cA*     See if existing replenishment record can be updated.
416cA
416cAC                   exsr      updprtyrpl
416cAC                   if        updflag = *on
416cAC                   eval      addrplflag = *on
416cAC                   endif

     *     Create priority replenishment.

416cAC                   if        updflag = *off
     C                   exsr      addprtyrpl
     C                   eval      addrplflag = *on
416cAC                   endif

     *     Reduce empty and needed quantities.

     C                   eval      homeempqty = homeempqty - (topick*#bumq2)
     C                   eval      qtyneeded  = qtyneeded - (topick*#bumq2)

     *     If we got what we needed, get out.

 2B  C                   if        qtyneeded <= 0
 2B  C                   leave
 2B  C                   endif

     *     If we are not trying to fill need and slot is full, get out.

 2B  C                   if        not $prfillu or $prfill <> 'Y'
 2B  C                   if        homeempqty <= 0
 2B  C                   leave
 2B  C                   endif
 2B  C                   endif

 1E  C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  crtbrkpir  Create replenishment for brokencase item
     *              where base item is in PIR section.
     *----------------------------------------------------------------

     C     crtbrkpir     begsr
     C                   eval      addrplflag = *off

     *   Loop through picking slots for item.

     C                   eval      kyitem = #bitem
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keys3         setll     slot3
 1B  C                   dow       forever = forever
     C     keys3         reade     slot3                                7879
 2B
 2B  C                   if        *in79
 1L  C                   leave
 2E  C                   endif
 2B
 2B  C                   if        *in78
 1L  C                   iter
 2E  C                   endif

     *     Ignore slot if past expiration date.

 2B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
 1I  C                   iter
 2E  C                   endif

     *     Calculate quantity available in slot.

     C                   exsr      calcqtys
 2B  C                   if        slavl1 <= 0
 1I  C                   iter
 2E  C                   endif

     *     Save slot information and available quantities.

     C                   eval      kyprty = slprty
     C                   eval      kyexpd = slexpd
     C                   eval      kyentd = slentd
     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand

     C                   eval      svavl1 = slavl1

     *     Loop through slots with same priority and dates.
     *     We want the slot with the least quantity available.

 2B  C                   dou       forever <> forever
     C     keys3b        reade     slot3                                  76
 3B  C                   if        *in76
 2L  C                   leave
 3E  C                   endif

     *        Ignore slot if past expiration date.

 3B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
 2I  C                   iter
 3E  C                   endif

     *        Calculate quantity available in slot.

     C                   exsr      calcqtys
 3B  C                   if        slavl1 <= 0
 2I  C                   iter
 3E  C                   endif

     *        If this slot has the least qty available then
     *        save slot information and available quantities.

 3B  C                   if        slavl1 <= svavl1

     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand

     C                   eval      svavl1 = slavl1

 3E  C                   endif

 2E  C                   enddo

     *     Get the selected slot.

     C     keys3c        chain     slot3                              76
 2B  C                   if        *in76
 1I  C                   iter
 2E  C                   endif

     *     Ignore slot if past expiration date.

 2B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
 1I  C                   iter
 2E  C                   endif

     *     Calculate quantity available in slot.

     C                   exsr      calcqtys
 2B  C                   if        slavl1 <= 0
 1I  C                   iter
 2E  C                   endif

     *     Calculate quantity to pick.

 2B  C                   select

     *       When filling to needed qty and that qty is > home empty qty
     *         Then calculate qty to pick based on needed qty.

 2B  C                   when      $prfillu and $prfill = 'Y' and
 2B  C                             qtyneeded > homeempqty
     C                   eval      topick = (qtyneeded / #bumq2)
     C                   if        topick * #bumq2 < qtyneeded
     C                   eval      topick = topick + 1
     C                   endif

     *       Otherwise, calculate qty to pick based on home empty qty.

 2B  C                   other
     C                   eval      topick = (homeempqty / #bumq2)
     C                   if        topick * #bumq2 < homeempqty
     C                   eval      topick = topick + 1
     C                   endif

     C                   endsl

     *     Make sure pick quantity isn't greater than available quantity.

     C                   if        topick > slavl1
     C                   eval      topick = slavl1
     C                   endif
416cA
416cA*     See if existing replenishment record can be updated.
416cA
416cAC                   exsr      updprtyrpl
416cAC                   if        updflag = *on
416cAC                   eval      addrplflag = *on
416cAC                   endif

     *     Create priority replenishment.

416cAC                   if        updflag = *off
     C                   exsr      addprtyrpl
     C                   eval      addrplflag = *on
416cAC                   endif

     *     Reduce empty and needed quantities.

     C                   eval      homeempqty = homeempqty - (topick*#bumq2)
     C                   eval      qtyneeded  = qtyneeded - (topick*#bumq2)

     *     If we got what we needed, get out.

 2B  C                   if        qtyneeded <= 0
 2B  C                   leave
 2B  C                   endif

     *     If we are not trying to fill need and slot is full, get out.

 2B  C                   if        not $prfillu or $prfill <> 'Y'
 2B  C                   if        homeempqty <= 0
 2B  C                   leave
 2B  C                   endif
 2B  C                   endif

 1E  C                   enddo

     *  Throw error if a replenishment was not created.

 2B  C                   if        not addrplflag
     C                   eval      error = *on
     C                   eval      $preturn  = 'NOFULLCASE'
     C                   exsr      getmsg
     C                   exsr      writelog
 2E  C                   endif

     C     pickpe        endsr

     *----------------------------------------------------------------
     *  crtnorm  Create replenishment for Normal item.
     *----------------------------------------------------------------

     C     crtnorm       begsr
     C                   eval      addrplflag = *off

     *  Loop through replenishment slots for item.

     C                   eval      kyitem = $ititem
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'N'
     C     keys3         setll     slot3
 1B  C                   dow       forever = forever
     C     keys3         reade     slot3                                7879

 2B  C                   if        *in79
 1L  C                   leave
 2E  C                   endif

 2B  C                   if        *in78
 1L  C                   iter
 2E  C                   endif

     *     Ignore slot if no normal stock or past expiration date.

 2B  C                   if        slstk1 <= 0   or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0   and
     C                             slexpd < today
 1I  C                   iter
 2E  C                   endif

     *     If nothing available then go to next slot.

     C                   exsr      calcqtys
 2B  C                   if        slavl1 <= 0
 1I  C                   iter
 2E  C                   endif

     *     Get tie/high info

     C                   eval      kysdef = slsdef
     C                   exsr      gettihi
     C                   eval      pallet = dspqty

     *     Grab one pallet or less.

 2B  C                   if        pallet > 0 and pallet <= slavl1
     C                   eval      topick = pallet
 2X  C                   else
     C                   eval      topick = slavl1
 2E  C                   endif

     *     If we are not filling to needed quantity,
     *       Then make sure quantity will fit in slot.

 2B  C                   if        not $prfillu or $prfill <> 'Y'
 2B  C                   if        topick > homeempqty
     C                   eval      topick = homeempqty
 2E  C                   endif
 2E  C                   endif
416cA
416cA*     See if existing replenishment record can be updated.
416cA
416cAC                   exsr      updprtyrpl
416cAC                   if        updflag = *on
416cAC                   eval      addrplflag = *on
416cAC                   endif

     *     Create priority replenishment.

416cAC                   if        updflag = *off
     C                   exsr      addprtyrpl
     C                   eval      addrplflag = *on
416cAC                   endif

     *     Reduce empty and needed quantities.

     C                   eval      homeempqty = homeempqty - topick
     C                   eval      qtyneeded  = qtyneeded - topick

     *     If we got what we needed, get out.

 2B  C                   if        qtyneeded <= 0
 2B  C                   leave
 2B  C                   endif

     *     If we are not trying to fill need and slot is full, get out.

 2B  C                   if        not $prfillu or $prfill <> 'Y'
 2B  C                   if        homeempqty <= 0
 2B  C                   leave
 2B  C                   endif
 2B  C                   endif

     *     Otherwise, we loop around and try for another replenishment.

 1E  C                   enddo

     *  Throw error if a replenishment was not created.

 2B  C                   if        not addrplflag
     C                   eval      error = *on
     C                   eval      $preturn  = 'NOOVERFLOW'
     C                   exsr      getmsg
     C                   exsr      writelog
 2E  C                   endif

     C     endfix        endsr

     *----------------------------------------------------------------
     *  drislotsr   Fake call to DRISLOT.
     *----------------------------------------------------------------

     C     drislotsr     begsr
     C                   eval      $drireturn = '*OK'

     C* Get slot2 record

     C     keysl2        chain     slot2

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $drireturn = 'INVLDSLOT'
     C                   eval      $drimessage = 'Invalid slot '
     C                                         + '('
     C                                         + %Trim(%editc($slwhse:'Z'))
     C                                         + '/'
     C                                         + %trim($slwhdp)
     C                                         + '/'
     C                                         + %trim($sldisp)
     C                                         + ')'
     C                   goto      enddrislot
     C                   endif

     C                   exsr      calcqtys

     C* Move information to data structure.

     C                   eval      $slwhse = slwhse
     C                   eval      $slwhdp = slwhdp
     C                   eval      $sldisp = sldisp
     C                   eval      $slaisl = slaisl
     C                   eval      $slloc  = slloc
     C                   eval      $slrlvl = slrlvl
     C                   eval      $slhand = slhand
     C                   eval      $slside = slside
     C                   eval      $slstyp = slstyp
     C                   eval      $slstat = slstat
     C                   eval      $slsdte = slsdte
     C                   eval      $slstim = slstim
     C                   eval      $slsdef = slsdef
     C                   eval      $sldesg = sldesg
     C                   eval      $slactv = slactv
     C                   eval      $slbld  = slbld
     C                   eval      $slpick = slpick
     C                   eval      $slpseq = slpseq
     C                   eval      $slprty = slprty
     C                   eval      $slentd = slentd
     C                   eval      $slexpd = slexpd
     C                   eval      $slslfd = slslfd
     C                   eval      $slrsrv = slrsrv
     C                   eval      $slitem = slitem
     C                   eval      $slstk1 = slstk1
     C                   eval      $slstk2 = slstk2
     C                   eval      $slstk3 = slstk3
     C                   eval      $slalc1 = slalc1
     C                   eval      $slalc2 = slalc2
     C                   eval      $slalc3 = slalc3
     C                   eval      $sltfr1 = sltfr1
     C                   eval      $sltfr2 = sltfr2
     C                   eval      $sltfr3 = sltfr3
     C                   eval      $slpck1 = slpck1
     C                   eval      $slpck2 = slpck2
     C                   eval      $slpck3 = slpck3
     C                   eval      $slrcv1 = slrcv1
     C                   eval      $slrcv2 = slrcv2
     C                   eval      $slrcv3 = slrcv3
     C                   eval      $slphy1 = slphy1
     C                   eval      $slphy2 = slphy2
     C                   eval      $slphy3 = slphy3
     C                   eval      $slavl1 = slavl1
     C                   eval      $slavl2 = slavl2
     C                   eval      $slavl3 = slavl3
     C                   eval      $sladj1 = sladj1
     C                   eval      $sladj2 = sladj2
     C                   eval      $sladj3 = sladj3

     C     enddrislot    endsr

     *----------------------------------------------------------------
     *  getbase  Get base item information
     *----------------------------------------------------------------

     C     getbase       begsr

     *  Get base item information.

     C                   call      'GETBASE'
     C                   parm      $itwhse       $gwhse            3 0
     C                   parm      $ititem       $gitem           15
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

     *  See if base item was found.

     C                   if        #brtn = '*ERROR'
     C                   eval      error = *on
     C                   eval      $preturn  = 'BASENOTFND'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endgetbase
     C                   endif

     *  Make sure base item has a brokencase uom.

     C                   if        #bumq2 <= 0
     C                   eval      error = *on
     C                   eval      $preturn  = 'UM2NOTDEF'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endgetbase
     C                   endif

     C     endgetbase    endsr

     *----------------------------------------------------------------
     *  getdatetime  Get current date & time
     *----------------------------------------------------------------

     C     getdatetime   begsr

     C                   time                    curtime

     C                   if        curtime < lasttime
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr

     *----------------------------------------------------------------
     *  getitem  Get item info.
     *----------------------------------------------------------------

     C     getitem       begsr

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#

     C                   eval      $itwhse = $prwhse
     C                   eval      $ititem = item#

     C                   eval      driitem = *on
     C                   call(e)   'DRIITEM'
     C                   parm                    $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIITEM'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   when      $drireturn <> '*OK' and
     C                             check4err = *on
     C                   eval      error = *on
     C                   eval      $priteme = '1'
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   goto      endgetitem
     C                   endsl

     C     endgetitem    endsr

     *----------------------------------------------------------------
     *  getmsg   Get message for error code.
     *----------------------------------------------------------------

     C     getmsg        begsr

     C                   select

     C                   when      $preturn = 'BASENOTFND'
     C                   eval      $pmessage = 'Parent item not found'

     C                   when      $preturn = 'FLDNOTSNT'
     C                   eval      $pmessage = 'Department and slot fields '
     C                                       + 'must be sent as a pair'

     C                   when      $preturn = 'FULLSLOT'
     C                   eval      $pmessage = 'Slot is full'

     C                   when      $preturn = 'INVLDSBCMD'
     C                   eval      $pmessage = 'Invalid subcommand '
     C                                       + '(' + %trim($psubcmd) + ') '
     C                                       + 'sent to ' + %trim(#prog)

     C                   when      $preturn = 'ITMNOTSNT'
     C                   eval      $pmessage = 'Item must be sent'

     C                   when      $preturn = 'NEGATIVQTN'
     C                   eval      $pmessage = 'Quantity needed must be '
     C                                       + 'positive'

     C                   when      $preturn = 'NEGATIVQTW'
     C                   eval      $pmessage = 'Warehouse quantity must be '
     C                                       + 'positive'

     C                   when      $preturn = 'NOFULLCASE'
     C                   eval      $pmessage = 'No full cases available'

     C                   when      $preturn = 'NOLAYER'
     C                   eval      $pmessage = 'Empty space in slot is '
     C                                       + 'less than a single layer'

     C                   when      $preturn = 'NOOVERFLOW'
     C                   eval      $pmessage = 'No overflow available'

     C                   when      $preturn = 'NOPICKSLOT'
     C                   eval      $pmessage = 'No pick slot with defined '
     C                                       + 'tie/high found for item '
     C                                       + %trim($pritem)

     C                   when      $preturn = 'NOTIEHIGH'
     C                   eval      $pmessage = 'Slot '
     C                                       + %Trim(%editc($prwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($prwhdp)
     C                                       + '/'
     C                                       + %trim($prslot)
     C                                       + ' does not have defined'
     C                                       + ' tie/high'

     C                   when      $preturn = 'NOTPICKSLT'
     C                   eval      $pmessage = 'Slot '
     C                                       + %Trim(%editc($prwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($prwhdp)
     C                                       + '/'
     C                                       + %trim($prslot)
     C                                       + ' not a pick slot'

     C                   when      $preturn = 'PIRNOTRSRV'
     C                   eval      $pmessage = 'PIR slot '
     C                                       + %Trim(%editc($prwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($prwhdp)
     C                                       + '/'
     C                                       + %trim($prslot)
     C                                       + ' not reserved'

     C                   when      $preturn = 'QTYEXISTS'
     C                   eval      $pmessage = 'Qty needed ('
     C                                       + %Trim(%editc(qtyneeded:'J'))
     C                                       + ') is less than or equal to '
     C                                       + 'available ('
     C                                       + %Trim(%editc(homeavlqty:'J'))
     C                                       + ')'

     C                   when      $preturn = 'QTYNOTSNT'
     C                   eval      $pmessage = 'Quantity needed must be '
     C                                       + 'sent when slot is not sent'

     C                   when      $preturn = 'QTYNSENT'
     C                   eval      $pmessage = 'Quantity needed cannot be '
     C                                       + 'sent for *CRTRPLDKA'

     C                   when      $preturn = 'QTYZERO'
     C                   eval      $pmessage = 'Qty needed is zero'

     C                   when      $preturn = 'REPLEXIST'
     C                   eval      $pmessage = 'Replenishment already '
     C                                       + 'exists for item '
     C                                       + %trim($pritem)

     C                   when      $preturn = 'UM2NOTDEF'
     C                   eval      $pmessage = 'Base item does not have '
     C                                       + 'breakdown 1 qty defined'

     C                   when      $preturn = 'WHSNOTSNT'
     C                   eval      $pmessage = 'Warehouse must be sent'

     C                   when      $preturn = 'WRONGITEM'
     C                   eval      $pmessage = 'Item ' + %trim($pritem)
     C                                       + ' not in slot '
     C                                       + %Trim(%editc($prwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($prwhdp)
     C                                       + '/'
     C                                       + %trim($prslot)

     C                   when      $preturn = 'WRONGITYP'
     C                   eval      $pmessage = 'Item is not '
     C                                       + 'Fix Norm/Bkdn '
     C                                       + 'or PIR Bkdn '
     C                                       + '('
     C                                       + %trim($pritem)
     C                                       + '/' + $itstyp + '/' + $ittype
     C                                       + ')'

     C                   other
     C                   eval      $pmessage = %trim($preturn)
     C                                       + ': Unknown return code'

     C                   endsl

     C                   endsr

416aA*----------------------------------------------------------------
416aA*  getnxtseq   Get next sequence number.
416aA*
416aA*
416aA*
416aA*----------------------------------------------------------------
416aA
416aAC     getnxtseq     begsr

417bAC                   select

417bA*  When creating a positive sequence number.

417bAC                   when      $psubcmd = '*CRTRPLSEQ'
     C     keyprd        setgt     prplfil1
     C     keyprd        readpe    prplfil1
 2X  C                   if        %eof           or
 2X  C                             prseq# < 0     or
 2X  C                             prseq# = 99999
     C                   eval      nextseq# = 1
 1L  C                   else
     C                   eval      nextseq# = prseq# + 1
 2E  C                   endif

417bA*  When creating a negative sequence number.
417bA
417bAC                   other
417bAC                   move      $psubcmd      temp1n
417bAC                   eval      maxseq# = -(temp1n * 1000)
417bAC                   eval      minseq# = maxseq# - 999
417bAC                   eval      $kseq# = maxseq#
417bAC     keypr1        setll     prplfil1
417bAC     keyprd        readpe    prplfil1
417bAC                   if        %eof           or
417bAC                             prseq# < minseq#
417bAC                   eval      nextseq# = minseq#
417bAC                   else
417bAC                   eval      nextseq# = prseq# + 1
417bAC                   endif
417bA
417bAC                   endsl

     C     endnxtseq     endsr

     *----------------------------------------------------------------
     *  getqtyavl    Get home slot quantity available
     *----------------------------------------------------------------

     C     getqtyavl     begsr

     C                   eval      homeavlqty = 0

 1B  C                   select

     *  When warehouse qty is not sent, use slot's actual available qty.

 1B  C                   when      not $prqtywu
CBIaAC                   exsr      addccqty
     C                   if        $slavl1 > 0
     C                   eval      homeavlqty = $slavl1
     C                   endif

     *  Otherwise, calculate available qty.

 1B  C                   other

     C                   exsr      calcovrflw
 2B  C                   eval      homeavlqty = $prqtyw - ovravlqty

     C                   eval      lgprqtyw = $prqtyw
     C                   eval      lgproavl = ovravlqty

     C                   endsl

     C                   eval      lgprhavl = homeavlqty

     C     endgetavl     endsr

     *----------------------------------------------------------------
     *  getqtyneeded   Get quantity needed
     *----------------------------------------------------------------

     C     getqtyneeded  begsr

     C                   eval      qtyneeded = 0

 1B  C                   select

     *  When *CRTRPLDKA is sent,
     *    the qty needed is the Dakota avg sales for today.

 1B  C                   when      $psubcmd = '*CRTRPLDKA'
     C     keyig         chain     itemavg
 2B  C                   if        %found and aqs(d) > 0
     C                   eval      qtyneeded = aqs(d)
     C                   endif

     *  When quantity needed is sent, use it.

 1B  C                   when      $prqtynu
     C                   eval      qtyneeded = $prqtyn

     *  When quantity needed is not sent and the slot is sent,
     *    the qty needed is the qty that would bring the available slot
     *    qty to zero. If available is already positive, then nothing
     *    is needed.

 1B  C                   when      not $prqtynu and $prslotu
 2B  C                   if        $slavl1 < 0
     C                   eval      qtyneeded = %abs($slavl1)
     C                   endif

     C                   endsl

     C                   eval      lgprqtyn = qtyneeded

     *  If quantity needed is zero, there is nothing to do.

     C                   if        qtyneeded <= 0
     C                   eval      error = *on
     C                   eval      $preturn  = 'QTYZERO'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endgetqty
     C                   endif

     C     endgetqty     endsr

     *----------------------------------------------------------------
     *  getslt2fil   Get slot to fill
     *----------------------------------------------------------------

     C     getslt2fil    begsr

     C                   eval      error = *off

     *  If slot was sent in, then just get tie/high info.

     C                   if        $prslotu
     C                   goto      skipsearch
     C                   endif

     *  Otherwise, whip through all active pick slots for item.

     C                   eval      $slavl1 = 0

     C                   eval      savepick  = ' '
     C                   eval      saveavail = 0

     C                   eval      kyitem = $pritem
     C                   eval      kystat = 'A'
     C                   eval      kypick = 'Y'
     C     keys3         setll     slot3

     C                   dow       forever = forever

     C     keys3         reade     slot3

     C                   if        %eof
     C                   leave
     C                   endif

     *    If slot is in PIR section, it must be a reserved slot.

     C                   if        slstyp = 'P' and slrsrv <> 'Y'
     C                   iter
     C                   endif

     *    Calculate available slot qty.

     C                   exsr      calcqtys
     C                   eval      $slavl1  = $slavl1 + slavl1
     C                   eval      lgprhcnt = lgprhcnt + 1

     *    Save last pick slot (this will be the last one in FIFO order).

     C                   eval      found = *on
     C                   eval      savewhdp = slwhdp
     C                   eval      savepick = sldisp
     C                   eval      saveavail = slavl1

     C                   enddo

     *  If slot not found, send back error.

     C                   if        not found
     C                   eval      error = *on
     C                   eval      $preturn  = 'NOPICKSLOT'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endslt2fil
     C                   endif

     *  Otherwise, get pick slot record that was found.

     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = $prwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = savewhdp
     C                   eval      $sldispu  = *on
     C                   eval      $sldisp   = savepick

     C                   eval      drislot = *on
     C                   exsr      drislotsr
     C*                  call(e)   'DRISLOT'
     C*                  parm      '*GET'        $drisubcmd
     C*                  parm      $pprogram     $driprogram
     C*                  parm      ' '           $drireturn
     C*                  parm      ' '           $drimessage
     C*    $slot         parm      $slot         $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRISLOT'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   exsr      writelog
     C                   goto      endslt2fil

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $prslote = '1'
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   exsr      writelog
     C                   goto      endslt2fil

     C                   endsl

     *  Get available qty to use and tie/high information.

     C     skipsearch    tag

     *    Save slot information for log file.

     C                   eval      lgprhwhd = $slwhdp
     C                   eval      lgprhslt = $sldisp

     *    Get available qty for selected slot.

     C                   exsr      getqtyavl

     *    Get tie/high info for selected slot.

     C                   eval      kysdef = $slsdef
417aAC                   eval      picksdef = $slsdef
 1B  C                   exsr      gettihi
     C                   eval      homepltqty   = dspqty
     C                   eval      homelayer    = layer
     C                   eval      homettlqty   = dstqty
     C                   eval      hometie      = dstie
     C                   eval      homehigh     = dshigh

     *    Calculate empty quantity in slot.

     C                   select
     C                   when      not foundtihi
     C                   eval      homeempqty   = homettlqty
     C                   eval      homeemplayer = homelayer

     C                   when      homeavlqty >= homettlqty
     C                   eval      homeempqty   = 0
     C                   eval      homeemplayer = 0

     C                   other
     C                   eval      homeempqty   = homettlqty - homeavlqty
 1B  C                   if        homelayer > 0
 1B  C                   eval      homeemplayer = homeempqty / homelayer
     C                   else
 1B  C                   eval      homeemplayer = 0
     C                   endif

     C                   endsl

     C     endslt2fil    endsr

     *----------------------------------------------------------------
     *  gettihi      Get item tie/high for slot
     *----------------------------------------------------------------

     C     gettihi       begsr

     *  Initialize the following quantities that are needed.

     *    - Single pallet quantity for slot (dspqty).
     *    - Single layer quantity for pallet (layer).
     *    - Total quantity that can fit into slot (dstqty).

     C                   eval      dspqty = 0
     C                   eval      dstqty = 0
     C                   eval      layer  = 0
417aAC                   eval      sdpos  = 0

     *  Loop through item's definitions looking for a match.

     C                   eval      foundtihi = *off

     C                   eval      curdef = 0
     C                   dou       curdef = %elem($idsdef)
     C                   eval      curdef = curdef + 1

     C                   if        $idsdef(curdef) = kysdef
     C                   eval      foundtihi = *on
     C                   leave
     C                   endif

     C                   enddo

     *  If match is not found then all qtys end up being avail qty.

 1B  C                   if        not foundtihi
     C                   eval      dspqty = 9999
     C                   eval      dstqty = 9999
     C                   eval      emptyq = 9999
     C                   eval      emptylayer = 1
     C                   eval      layer  = 9999
     C                   endif

     *  If match is found then calculate the needed quantities.

 1B  C                   if        foundtihi

 1B  C                   select

 1X  C                   when      $idtie(curdef) = 0
     C                   eval      dspqty = $idhigh(curdef)
     C                   eval      layer  = $idhigh(curdef)

 1X  C                   when      $idhigh(curdef) = 0
     C                   eval      dspqty = $idtie(curdef)
     C                   eval      layer  = $idtie(curdef)

 1X  C                   other
     C                   eval      dspqty = $idtie(curdef) * $idhigh(curdef)
     C                   eval      layer  = $idtie(curdef)

 1E  C                   endsl

     C     keysd         chain     slotdef
     C                   if        not %found or sdpos <= 0
     C                   eval      dstqty = dspqty
     C                   else
     C                   eval      dstqty = dspqty * sdpos
     C                   endif

     C                   endif

     C     endgettihi    endsr

     *----------------------------------------------------------------
     *  remove     Remove priority replenishments
     *----------------------------------------------------------------

     C     remove        begsr
     C                   move      *off          error

 1B  C                   if        not $prwhdpu or
 1B  C                             $prwhdp = ' ' or $prwhdp = '*ALL'
     C     keyprw        setll     prplfil
     C                   else
     C     keyprd        setll     prplfil
     C                   endif

     C                   dow       forever = forever

 1B  C                   if        not $prwhdpu or
 1B  C                             $prwhdp = ' ' or $prwhdp = '*ALL'
     C     keyprw        reade     prplfil                              78
     C                   else
     C     keyprd        reade     prplfil                              78
     C                   endif

     C                   if        %eof
     C                   leave
     C                   endif

417c C                   if        prprty <> 0
417c C                   iter
417c C                   endif

     C                   if        *in78
     C                   iter
     C                   endif

     C                   delete(e) prrec
     C                   if        %error
     C                   endif

     C                   enddo

     C     endremove     endsr

     *----------------------------------------------------------------
     *  rplcriteria  See if replenishment should be done
     *----------------------------------------------------------------

     C     rplcriteria   begsr

     *  If that met the need, get out.

 2B  C                   if        qtyneeded <= homeavlqty
     C                   eval      error = *on
     C                   eval      $preturn  = 'QTYEXISTS'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endcriteria
 2E  C                   endif

     *  If we are filling to needed qty, there is nothing else to check.

 1X  C                   if        $prfillu and $prfill = 'Y'
     C                   goto      endcriteria
 2E  C                   endif

     *  Otherwise ...

     *    See if slot has any more room.

 1X  C                   if        homeempqty <= 0
     C                   eval      error = *on
     C                   eval      $preturn  = 'FULLSLOT'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endcriteria
 2E  C                   endif
 2E
     *    See if slot has at least one empty layer
     *      (Only do check if high value is greater than 1)

 1X  C                   if        homehigh > 1 and homeemplayer < 1
     C                   eval      error = *on
     C                   eval      $preturn  = 'NOLAYER'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endcriteria
 2E  C                   endif

     C     endcriteria   endsr

416aA*----------------------------------------------------------------
416aA*  seqprtyrpl  Sequence priority replenishments                  ent
416aA*----------------------------------------------------------------
416aA
416aAC     seqprtyrpl    begsr
     C                   eval      lstseq = 0

     *    Find highest sequence number in file. Then add 1 more.

     C     keyprw        setll     prplfil1
 1B  C                   dow       forever = forever
     C     keyprw        reade     prplfil1

 2B  C                   select

 2X  C                   when      %eof
     C                   add       1             lstseq
 1L  C                   leave

 2X  C                   when      prseq# > lstseq
     C                   eval      lstseq = prseq#
 2E  C                   endsl

 1E  C                   enddo

     C                   eval      $kwhse = $prwhse
     C                   eval      $kwhdp = *blanks
     C                   eval      $ktdis = *blanks
     C                   move      *hival        $kaqs
     C                   eval      $kfail = *blanks
     C                   eval      $ktail = *blanks
 1B  C                   if        locator
     C     keypr3        setll     prplfil3
 1X  C                   else
     C     keypr2        setll     prplfil2
 1E  C                   endif
     C                   eval      startover = *off

     *    Initialize starting sequence number.

     C                   eval      n = lstseq

     C     start         tag

 1B  C                   dou       forever <> forever
 2B  C                   if        startover
 3B  C                   if        locator
     C     keypr3        setll     prplfil3
 3X  C                   else
     C     keypr2        setll     prplfil2
 3E  C                   endif
     C                   eval      startover = *off
 2E  C                   endif
     C     again         tag
 2B  C                   if        locator
     C     keyprw        reade     prplfil3
 2X  C                   else
     C     keyprw        reade     prplfil2
 2E  C                   endif
 2B  C                   if        %eof
 1L  C                   leave
 2E  C                   endif
     C     prflag        cabne     ' '           again
     C                   add       1             n
     C                   eval      prseq# = n
     C                   eval      prflag = 'S'
 2B  C                   if        locator
     C                   update    p3rec
 2X  C                   else
     C                   update    p2rec
 2E  C                   endif
     C                   eval      $kwhse = prwhse
     C                   eval      $kwhdp = prwhdp
     C                   eval      $kaqs = praqs
     C                   eval      $kfail = prfail
     C                   eval      $ktail = prtail
     C                   eval      $ktdis = prtdis
     C     prtail        cabeq     prfail        again
     C                   eval      $kfail = prtail
     C                   eval      $ktail = *blanks
     C                   eval      $ktdis = *blanks
     C                   eval      startover = *on
 1I  C                   iter
 1E  C                   enddo

     * Make sure that all aisles are done.

 1B  C                   if        locator
     C     keyprw        setll     prplfil3
 1X  C                   else
     C     keyprw        setll     prplfil2
 1E  C                   endif
 1B  C                   dou       forever <> forever
 2B  C                   if        locator
     C     keyprw        reade     prplfil3
 2X  C                   else
     C     keyprw        reade     prplfil2
 2E  C                   endif
 2B  C                   if        %eof
 1L  C                   leave
 2E  C                   endif
 2B  C                   if        prflag > ' '
 1I  C                   iter
 2E  C                   endif
     C                   eval      startover = *on
 1L  C                   leave
 1E  C                   enddo

     * Start again, if any aisles are not done.

 1B  C                   if        startover
     C                   eval      $ktdis = *blanks
     C                   eval      $kwhdp = *blanks
     C                   move      *hival        $kaqs
     C                   eval      $kfail = *blanks
     C                   eval      $ktail = *blanks
goto Csr                 goto      start
 1E  C                   endif

     C     endseq        endsr
417aA
417aA*----------------------------------------------------------------
417aA*  setrpltype  Set replenishment type
417aA*----------------------------------------------------------------
417aA
417aAC     setrpltype    begsr
417aA
417aAC                   eval      kysdef = picksdef
417aAC     keysd         chain     slotdef
417aAC                   if        not %found
417aAC                   eval      sdpos = 0
417aAC                   endif
417aA
417aAC                   select
417aA*    To create a Pushback replenishment, License
417aA*    Tracking & Track pushback slots must be active
417aA*    & slot position is 2 or greater.
417aAC     oplptr        wheneq    'Y'
417aAC     optksp        andeq     'Y'
417aAC     sdpos         andge     2
417aAC                   eval      rpltype = 'P'
417aA
417aA*    If breakdown item, treat as Eaches replenishment.
417aAC     $ittype       wheneq    'B'
417aAC                   eval      rpltype = 'E'
417aA
417aA*    Otherwise, treat as Normal replenishment.
417aAC                   other
417aAC                   eval      rpltype = ' '
417aAC*
417aAC                   endsl
417aA
417aAC                   endsr

416cA*----------------------------------------------------------------
416cA*  updprtyrpl   Update existing priority replenishment
416cA*----------------------------------------------------------------
416cA
416cAC     updprtyrpl    begsr

     C                   eval      updflag = *off
     C                   exsr      getdatetime

     *  Loop through existing priority replenishments for item.

     C     keypr4        setll     prplfil4

     C                   dow       forever = forever

     C     keypr4        reade(e)  prplfil4

     C                   if        %eof
     C                   leave
     C                   endif

     C                   if        %error
     C                   iter
     C                   endif

     *    Remove deleted records to keep file clean.

     C                   if        prflag = 'D'
     C                   delete(e) prrec4
     C                   if        %error
416dDC**                 iter
     C                   endif
416dAC                   iter
     C                   endif

     *    Remove active records older than 1 day.
417c *    and not just-in-time replenishments.

417cDC**                 if        prflag = 'A'
417cMC                   if        prflag = 'A' and
417cMC                             prprty =  0
     C                   Call      'CALCTIME'
     C                   Parm      '*DAYS'       calccmd           8
     C                   Parm      pradte        fromdate
     C                   Parm      pratim        fromtime
     C                   Parm      curdate       todate
     C                   Parm      curtime       totime
     C                   Parm      0             duration
     C                   if        duration > 1
     C                   delete(e) prrec4
     C                   if        %error
     C                   iter
     C                   endif
     C                   endif
     C                   endif

     *    If slot information doesn't match, then get next record.

     C                   if        prwhdp <> $slwhdp or
     C                             prfdis <> sldisp  or
     C                             prtdis <> $sldisp
     C                   iter
     C                   endif

     *    Otherwise, update existing priority replenishment record.

 1B  C                   if        topick <> slavl1
     C                   eval      prfree = 'N'
 1X  C                   else
     C                   eval      prfree = 'Y'
 1E  C                   endif

     C                   eval      prqty  = topick
     C                   eval      prstat = $slstat
     C                   eval      praqs  = qtyneeded

     C                   update(e) prrec4
     C                   if        %error
     C                   endif

     C                   eval      lgprcrt  = 'U'
     C                   eval      lgprowhd = prwhdp
     C                   eval      lgproslt = prfdis
     C                   eval      lgproavl = slavl1
     C                   exsr      writelog

     C                   eval      updflag = *on
     C                   leave

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  verifycrt  Verify information when trying to create replenishment
     *----------------------------------------------------------------

     C     verifycrt     begsr

     *  Item must be sent.

     C                   if        not $pritemu
     C                   eval      error = *on
     C                   eval      $priteme = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif

     *  Get/Verify item.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETALL'
     C                   eval      item# = $pritem
     C                   exsr      getitem
     C                   if        error
     C                   eval      $priteme = '1'
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif

     *  Only create replenishments for following item types ...

     *    - Fixed Normal, Fixed Breakdown or PIR Breakdown.

 1B  C                   if        $itstyp = 'F'  and
 1B  C                             $ittype <> ' ' and $ittype <> 'B'  or
 1B  C                             $itstyp = 'P' and $ittype <> 'B'
     C                   eval      error = *on
     C                   eval      $preturn  = 'WRONGITYP'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif

     *  Quantity needed can't be sent for *CRTRPLDKA.

     C                   if        $prqtynu and $psubcmd = '*CRTRPLDKA'
     C                   eval      error = *on
     C                   eval      $prqtyne = '1'
     C                   eval      $preturn = 'QTYNSENT'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif

     *  Quantity needed must be sent if slot is not sent.

     C                   if        $prslotu and not $prqtynu
     C                   eval      error = *on
     C                   eval      $prqtywe = '1'
     C                   eval      $preturn = 'QTYNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfycrt
     C                   endif

     *  Quantity needed can't be negative.

     C                   if        $prqtynu and $prqtyn < 0
     C                   eval      error = *on
     C                   eval      $prqtyne = '1'
     C                   eval      $preturn = 'NEGATIVQTN'
     C                   exsr      getmsg
     C                   goto      endvfycrt
     C                   endif

     *  Warehouse quantity can't be negative.

     C                   if        $prqtywu and $prqtyw < 0
     C                   eval      error = *on
     C                   eval      $prqtywe = '1'
     C                   eval      $preturn = 'NEGATIVQTW'
     C                   exsr      getmsg
     C                   goto      endvfycrt
     C                   endif

     *  If department and slot not sent, nothing else to verify.

     C                   if        not $prwhdpu and not $prslotu
     C                   goto      endvfycrt
     C                   endif

     *  Department and slot must be sent together.

     C                   if        $prwhdpu or $prslotu
     C                   if        not $prwhdpu or
     C                             not $prslotu
     C                   eval      error = *on
     C                   eval      $prwhdpe = '1'
     C                   eval      $prslote = '1'
     C                   eval      $preturn  = 'FLDNOTSNT'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif
     C                   endif

     *  Verify department that was sent.

     C                   eval      vfywhdp = *on
     C                   call(e)   'VFYWHDP'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $prwhse       $vwhse
     C                   parm      $prwhdp       $vwhdp
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $prwhdpe = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHDP'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $prwhdpe = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt

     C                   endsl

     *  Get slot information

     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = $prwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = $prwhdp
     C                   eval      $sldispu  = *on
     C                   eval      $sldisp   = $prslot

     C                   eval      drislot = *on
     C                   exsr      drislotsr
     C*                  call(e)   'DRISLOT'
     C*                  parm      '*GET'        $drisubcmd
     C*                  parm      $pprogram     $driprogram
     C*                  parm      ' '           $drireturn
     C*                  parm      ' '           $drimessage
     C*    $slot         parm      $slot         $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRISLOT'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $prslote = '1'
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt

     C                   endsl

     *  Slot doesn't contain item.

     C                   if        $slitem <> $pritem
     C                   eval      error = *on
     C                   eval      $prslote = '1'
     C                   eval      $preturn  = 'WRONGITEM'
     C                   exsr      getmsg
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif

     *  Slot not a pick slot.

     C                   if        $slpick <> 'Y'
     C                   eval      error = *on
     C                   eval      $prslote = '1'
     C                   eval      $preturn  = 'NOTPICKSLT'
     C                   exsr      getmsg
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif

     *  Slot is PIR but not reserved.

     C                   if        $slstyp = 'P' and $slrsrv <> 'Y'
     C                   eval      error = *on
     C                   eval      $prslote = '1'
     C                   eval      $preturn  = 'PIRNOTRSRV'
     C                   exsr      getmsg
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif
     C     endvfycrt     endsr

     *----------------------------------------------------------------
     *  verifygen   General verification.
     *----------------------------------------------------------------

     C     verifygen     begsr

     *  Clear log fields

     C                   clear                   lgprrec

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $prwhseu
     C                   eval      error = *on
     C                   eval      $prwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endvfygen
     C                   endif

     *  Verify warehouse.

     C                   eval      vfywhse = *on
     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $prwhse       $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   exsr      writelog
     C                   goto      endvfygen

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   exsr      writelog
     C                   goto      endvfygen

     C                   endsl

     C     endvfygen     endsr

     *----------------------------------------------------------------
     *  verifyrmv   Verify information when removing replenishments.
     *----------------------------------------------------------------

     C     verifyrmv     begsr

     *  Department can be blank or *ALL.

     C                   if        not $prwhdpu or
     C                             $prwhdp = ' ' or
     C                             $prwhdp = '*ALL'
     C                   goto      endvfyrmv
     C                   endif

     *  Verify department that was sent.

     C                   eval      vfywhdp = *on
     C                   call(e)   'VFYWHDP'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $prwhse       $vwhse
     C                   parm      $prwhdp       $vwhdp
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $prwhdpe = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHDP'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   exsr      writelog
     C                   goto      endvfyrmv

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $prwhdpe = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   eval      lgprhwhd = $prwhdp
     C                   exsr      writelog
     C                   goto      endvfyrmv

     C                   endsl

     C     endvfyrmv     endsr

     *----------------------------------------------------------------
     *  writelog    Write record to priority replenishment log file
     *----------------------------------------------------------------

     C     writelog      begsr

     C                   exsr      getdatetime

     C                   eval      lgprwhse = $prwhse
     C                   eval      lgpritem = $pritem
     C                   eval      lgprdate = curdate
     C                   eval      lgprtime = curtime
     C                   eval      lgprscmd = $psubcmd
     C                   eval      lgprpgm  = $pprogram
     C                   eval      lgprfill = $prfill

     C                   eval      lgprrtn  = $preturn
     C                   eval      lgprmsg  = $pmessage
     C                   eval      lgprdata = $prtyrpl

     C                   write(e)  lgprrec
     C                   if        %error
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  zzzclose  Close open programs
     *----------------------------------------------------------------

     C     zzzclose      begsr

     C                   if        drislot
     C*                  call(e)   'DRISLOT'
     C*                  parm      '*CLOSE'      $drisubcmd
     C*                  parm      $pprogram     $driprogram
     C*                  parm      ' '           $drireturn
     C*                  parm      ' '           $drimessage
     C*                  parm      ' '           $dridata
     C                   endif

     C                   if        driitem
     C                   call(e)   'DRIITEM'
     C                   parm      '*CLOSE'      $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      ' '           $dridata
     C                   endif

     C                   if        vfywhdp
     C                   call(e)   'VFYWHDP'
     C                   parm      '*CLOSE'      $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $prwhse       $vwhse
     C                   parm      $prwhdp       $vwhdp
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     C                   endif

     C                   if        vfywhse
     C                   call(e)   'VFYWHSE'
     C                   parm      '*CLOSE'      $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $prwhse       $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     C                   endif

     C                   endsr
