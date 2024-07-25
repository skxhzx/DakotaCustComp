      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT971   Item Quantity Compare Report - Print
     *  18 January 2010
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *
530 A*    01/18/10  RBD  5.30
     *      - Created.
     *      - Client custom code support included.
530aA*    02/22/10  MLB  5.30a
     *      - Enh: Revised program to change file used in pgm to IMPFCQTY
     *        from IMPFPQTY.
     *      - Passed in $PCMD parm to be used in future updates.
     *
640a *    02/22/11  GJA  6.40a
     *      - Enh:  Add pick slot to report
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier Foods
     *
GFCa *    09/30/10  MLB  GFCa
     *      - Revised program to call CHKLIVE to only process items
     *        for active departments.
GFCbA*    05/22/12  GJA  GFCb
     *    - Enh: Revised program to pass warehouse number to pgm, CHKLIVE.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter-County Bakers
     *
ICBa *    07/17/12  GJA  ICBa
     *      - Revised program to get PO's not exported to host yet
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
530aDF*impfpqty  if   e           k disk
530aMFimpfcqty  if   e           k disk
     Fitemqty   if   e           k disk
     Fpiritem   if   e           k disk
     Freports   if   e           k disk
     Fwarehs    if   e           k disk
640aAFslot3     if   e           k disk
ICBaAFpodtl     if   e           k disk
     Fit971pr   o    e             printer oflind(*in91)
     *----------------------------------------------------------------
     *  Customer id
     *
GFCaA /copy qcopysrc,id#glazier
ICBaA /copy qcopysrc,id#icb
     *
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a30             s              1    dim(30)
     D desc            s             60    dim(2) ctdata perrcd(1)
     *
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
     D  $lwhdp                22     26
     *
     *----------------------------------------------------------------
     *  Working Variables
     *
     D addflg          s              1
     D chgflg          s              1
     D count           s              3  0
     D error           s              1
     D first           s              1
     D forever         s              1
     D grdord          s              5  0
640aAD k3pick          s              1
640aAD k3stat          s              2
     D len             s              1  0
     D linppg          s              3  0
     D pflag           s              1
     D pos             s              1  0
     D whs#            s              3  0
     D work3a          s              3
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
530aA*      $CMD    *EXCPTN - Print only exceptions
     *      $WHSE   Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
530aAC                   parm                    $pcmd             8
     C                   parm                    $whse             3
     *
     * Main line
     *
     * Whip through all the Itemqty records
     *
     C                   eval      first = *on
     C     whs#          setll     itemqty
     C                   dow       forever = forever
     *
     C     whs#          reade     itemqty
     C                   eval      error = *off
     C                   if        %eof(itemqty)
     C                   leave
     C                   endif
     *
     *  First time through
     *
     C                   if        first = *on
     C                   exsr      zzinz2
     C                   eval      first = *off
     C                   endif
     *
     *  Get matching import quantity record
     *
530aMC     keyit         chain     impfcqty
530aMC                   if        not %found(impfcqty)
530aMC                   eval      ictqh1 = 0
530aMC                   eval      ictqh2 = 0
530aAC                   eval      ictqh3 = 0
     C                   endif
     *
     *  Calculate differences between host and Dakota qty's
     *  If no differences, don't print
     *
     C                   exsr      zzcalc
     C                   if        diff1 = 0 and diff2 = 0
530aAC                             and diff3 = 0
     C                   goto      skipiq
     C                   endif
     *
     *  Get item description
     *
     C     keyit         chain     piritem
     C                   if        not %found(piritem)
     C                   eval      itdesc = ' '
GFCaAC                   eval      itwhdp = ' '
     C                   endif
GFCaA*
GFCaA*  Omit items for non-active departments
GFCaAC                   if        client = Glazier
GFCaA*
GFCaAC                   call      'CHKLIVE'
GFCbAC                   parm      whs#          $cwhse            3 0
GFCaAC                   parm                    itwhdp
GFCaAC                   parm                    livestat          8
GFCaA
GFCaA*  If department is not live, then read next item.
GFCaA
GFCaAC                   if        livestat = '*NOTLIVE'
GFCaAC                   Iter
GFCaAC                   Endif
GFCaA*
GFCaAC                   endif
640aA*
640aA*  Get pick slot
640aA*
640aAC                   eval      k3pick = 'Y'
640a C                   eval      k3stat = 'A '
640aAC     keysl         chain     slot3
640aAC                   if        not %found(slot3)
640aAC                   eval      sldisp = *blanks
640aAC                   endif
     *
     *  Write detail
     *
     C                   if        *in91 = '1'
     C                   write     head1                                91
     C                   endif
     C                   write     detail                               91
     *
     C     skipiq        tag
     C                   enddo
     *
     * Whip through the import item records and print those with no
     * match to itemqty
     *
     C                   eval      first = *on
530aMC     whs#          setll     impfcqty
     C                   dow       forever = forever
     *
530aMC     whs#          reade     impfcqty
     C                   eval      error = *off
530aMC                   if        %eof(impfcqty)
     C                   leave
     C                   endif
     *
     *  First time through
     *
     C                   if        first = *on
     C                   exsr      zzinz3
     C                   eval      first = *off
     C                   endif
     *
     *  Look for matching itemqty record, if not found, print exception
     *
     C     keyiq         chain     itemqty
     C                   if        not %found(itemqty)
     C                   if        *in91 = '1'
     C                   write     head2                                91
     C                   endif
     C                   write     detail2                              91
     C                   endif
     *
     C                   enddo
     *
     *  Print grand totals
     *
     C                   if        *in91 = *on
     C                   write     head1                                91
     C                   endif
     C                   write     foot1                                91
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
530aM*          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *  Variables and constants.
     *
     C                   eval      forever = *off
     *
     *  Convert today's date into MMDDYY format.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rdate = $cvd6o
     C                   time                    rtime
     *
     C                   eval      $lprg = #prog
     C                   move      $whse         whs#
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCALC   Calculate differences between host and Dakota qty's
     *
     C     zzcalc        begsr
     *
530aMC                   eval      diff1 = ictqh1 - iqstk1
530aMC                   eval      diff2 = ictqh2 - iqstk2
530aAC                   eval      diff3 = ictqh3 - iqstk3
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *  Define key for piritem and import qty files.
     *
     C     keyit         klist
     C                   kfld                    whs#
     C                   kfld                    iqitem
640aA*
640aA*  Define key for slot file.
640aA*
     C     keysl         klist
     C                   kfld                    whs#
     C                   kfld                    iqitem
     C                   kfld                    k3stat
     C                   kfld                    k3pick
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     'IT971PR'     rpprtf
     C     rpprtf        chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = desc(1)
     C                   endif
     C                   eval      $plen = 60
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     whs#          chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      whs#          work3a
     C     ' 0'          check     work3a        pos
     C                   if        pos = 0
     C                   eval      pos = 1
     C                   endif
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     *   Write headings
     *
     C                   write     head1
     *
     *   Get options.
     *
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ3   Program initialization. Called from main line.
     *
     C     zzinz3        begsr
     *
     *  Define key for item quantity file.
     *
     C     keyiq         klist
     C                   kfld                    whs#
530aMC                   kfld                    icitem
     *
     * Get report heading.
     *
     C                   eval      w2head = *blanks
     C                   eval      $pstr = desc(2)
     C                   eval      $plen = 60
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w2head
     *
     *   Write headings
     *
     C                   write     head2
     *
     *   Get options.
     *
     *
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  Compile Time Tables
     *
**
Item Quantity Compare Report
Item Quantity Compare Report: Host Items Not Found On Dakota
