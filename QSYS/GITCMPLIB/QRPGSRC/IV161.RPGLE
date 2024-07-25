     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IV161     Inventory variance report by item - Print
     *  27 March, 1996
     *  Hemant Kapadia/Roxanne Harrison
     *
     *  Note:
     *    If print exception option is YES, program may print detail
     *    line with difference = 0 if one rec for the item has a
     *    difference of 5 and another has a difference of -5, the
     *    total variance will be 0 but will print.
     *
     *  Revisions:
     *
217  *    01/09/97  RH   2.17
     *      - Add allow item breakdown flag(ITFLG1 & ITFLG2) to print.
416a *    01/16/02  RH   4.16a
     *      - FIX - Was printing all rec. for exceptions only.
416b *    04/25/02  RH   4.16b
     *      - Print lines with variance greater than minimum.
500a *    05/11/05  RH   500a
     *      - FIX - Remove 416a code causing to always print exceptions
     *        only.
500b *    06/21/05  RH   500b
     *      - FIX - Change to not print Detail1 for summary.          s
650aA*    05/10/13  RH   6.50a
     *      - Enh: Convert to ILE
     *      - Enh: Add DETAILS to list ALL slots for scope and linked
     *        items.
720aA*    04/27/18  RH/LMC   7.20a
     *      - Fix: Was not printing line for neg qty 1
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *  96        Prints '--' in current qty fields
     *  97        Prints '--' in new qty fields
     *  9X        Top of page and level X continues.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fiv161     ip   e           k disk
     Fpiritem   if   e           k disk
650AAFslot3     if   e           k disk
650AAFitemlnk   if   e           k disk
650AAFitemlnk1  if   e           k disk    rename(ilrec:ilrec1)
650AAFinvslot4  if   e           k disk
     Freports   if   e           k disk
     Fiv161pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D rpd             s             25    dim(3) ctdata perrcd(1)
     D reck            s              7  0 dim(4)
     D lvlk            s              7  0 dim(4)
     D sqt1            s              7  0 dim(4)
     D sqt2            s              7  0 dim(4)
     D sqt3            s              7  0 dim(4)
     D stk1            s              7  0 dim(4)
     D stk2            s              7  0 dim(4)
     D stk3            s              7  0 dim(4)
     D dqt1            s              7  0 dim(4)
     D dqt2            s              7  0 dim(4)
     D dqt3            s              7  0 dim(4)
     *
     D a22             s              1    dim(22)
     D optn            s             15    dim(2) ctdata perrcd(1)
     *                                             WKSSTPL1
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
     *  Called programs
     *
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
     D                 ds
     D  t#date                 1      6  0
     D  month                  1      2  0
     D  day                    3      4  0
     D  year                   5      6  0
     *----------------------------------------------------------------
     * Variables
     D $plen           s              3  0
     D $pstr           s             60
     D $pwhse          s              3  0
     D $rpd            s             25
     D first           s              1
     D good1           s              1
     D l               s              1  0
     D m               s                   like(l)
     D n               s              3  0
     D pmvar           s              5  0
     D pnvar           s              5  0
650aAD stop            s              1
650aAD stop1           s              1
     D wkprtf          s             10
     *
     *
     *----------------------------------------------------------------
     Iwkrec
     I                                          wkswhs        l3
     I                                          wkswhd        l2
     I                                          wkitem        l1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse #
     *      $PXCP   Print exceptions only
     *      $PSUM   Print summary only
416b *      $PVAR   Minimum variance
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $pxcp             1
     C                   parm                    $psum             1
416b C                   parm                    $pvar             5
650a C                   parm                    $plnkd            1
     C                   move      $pwhs         $pwhse
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Overflow occurred.
     *
     C                   if        *in90  or
     C                             first = *on  or
     C                             *inl3  or
     C                             *inl2
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *
     *  Level 1 break -
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
     *  Print headings if level break.
     *
     C                   if        *in93  or
     C                             *inl3  or
     C                             *in92  or
     C                             *inl2
     C                   write     sbhead
     C                   write     columns
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     *  Calculate difference of NEW qty's SUB OLD qyt's.
     *
     C                   eval      wkdqt1 = wksqt1 - wkstk1
     C                   eval      wkdqt2 = wksqt2 - wkstk2
     C                   eval      wkdqt3 = wksqt3 - wkstk3
     *
     C                   eval      *in96 = *off
     C                   eval      *in97 = *off
     C                   if        wktype = '1'
     C                   eval      *in97 = *on
     C                   endif
     C                   if        wktype = '2'
     C                   eval      *in96 = *on
     C                   endif
     *
     *  Print exceptions only $PXCP = Y
     *
     C                   select
     C                   when      $pxcp = 'Y'
     C                   if        wkdqt1 <> 0  or
     C                             wkdqt2 <> 0  or
     C                             wkdqt3 <> 0
     C     itkey1        chain     piritem                            79
     C                   if        not *in79
     C                   eval      idesc = itdesc
217 AC                   if        itflg1 = 'Y'
217 AC                   eval      iflg1 = itflg1
217 AC                   else
217 AC                   eval      iflg1 = *blanks
217 AC                   endif
217 AC                   if        itflg2 = 'Y'
217 AC                   eval      iflg2 = itflg2
217 AC                   else
217 AC                   eval      iflg2 = *blanks
217 AC                   endif
     C                   else
     C                   eval      idesc = *blanks
217 AC                   eval      iflg1 = *blanks
217 AC                   eval      iflg2 = *blanks
     C                   endif
     C                   if        $psum = 'N'
416b C                   if        wkdqt1 >= pmvar  or
416b C                             wkdqt2 >= pmvar  or
416b C                             wkdqt3 >= pmvar  or
416b C                             wkdqt1 < pnvar  or
416b C                             wkdqt2 < pnvar  or
416b C                             wkdqt3 < pnvar
     C                   write     detail1
416b C                   endif
     C                   endif
416aAC                   eval      good1 = *on
     C                   endif
     *
     C                   when      $pxcp = 'N'
     C     itkey1        chain     piritem                            79
     C                   if        not *in79
     C                   eval      idesc = itdesc
217 AC                   if        itflg1 = 'Y'
217 AC                   eval      iflg1 = itflg1
217 AC                   else
217 AC                   eval      iflg1 = *blanks
217 AC                   endif
217 AC                   if        itflg2 = 'Y'
217 AC                   eval      iflg2 = itflg2
217 AC                   else
217 AC                   eval      iflg2 = *blanks
217 AC                   endif
     C                   else
     C                   eval      idesc = *blanks
217 AC                   eval      iflg1 = *blanks
217 AC                   eval      iflg2 = *blanks
     C                   endif
500b C                   if        $psum = 'N'
500aD*          WKDQT1    IFGE PMVAR
500aD*          WKDQT2    ORGE PMVAR
500aD*          WKDQT3    ORGE PMVAR
500aD*          WKDQT1    ORLT PNVAR
500aD*          WKDQT2    ORLT PNVAR
500aD*          WKDQT3    ORLT PNVAR
     C                   write     detail1
500aD*                    ENDIF
500b C                   endif
416aAC                   eval      good1 = *on
     C                   endsl
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     C                   add       wksqt1        sqt1(1)
     C                   add       wksqt2        sqt2(1)
     C                   add       wksqt3        sqt3(1)
     C                   add       wkstk1        stk1(1)
     C                   add       wkstk2        stk2(1)
     C                   add       wkstk3        stk3(1)
     C                   add       wkdqt1        dqt1(1)
     C                   add       wkdqt2        dqt2(1)
     C                   add       wkdqt3        dqt3(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
     C                   eval      first = *off
     *----------------------------------------------------------------
     *
     * Level 1 break
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     CL1                 if        reck(l) > 0
     CL1                 exsr      zrtotl
     CL1                 endif
     *----------------------------------------------------------------
     *
     * Grand totals
     *
     *R                   Z-ADD3         L
     *
     CLr                 if        reck(l) > 0
     *R                   EXSR ZRTOTL
     CLr                 write     skip1
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
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     C     itkey1        klist
     C                   kfld                    $pwhse
     C                   kfld                    wkitem
     *
650aAc     *like         define    wkitem        kyitem
650aAc     *like         define    wkitem        klitem
     C     itkey2        klist
     C                   kfld                    $pwhse
650aMC                   kfld                    kyitem
650aDC*                  kfld                    wkitem
650aA*
650aAC     itkeyL        klist
650aAC                   kfld                    $pwhse
650aMC                   kfld                    klitem
650aA*
650aAC     Ivkey1        klist
650aAC                   kfld                    $pwhse
650aAC                   kfld                    slwhdp
650aAC                   kfld                    sldisp
     *
     C                   if        $pxcp = 'Y'
     C                   eval      optn1 = optn(1)
     C                   endif
     C                   if        $psum = 'Y'
     C                   eval      optn2 = optn(2)
     C                   endif
     C                   time                    time
     C                   eval      first = *on
     C                   eval      l = 1
     C                   eval      n = 0
     C                   eval      $cvprg = #prog
416b C                   move      $pvar         pmvar
416b C                   eval      pnvar = pmvar * -1
     C                   exsr      zrzero
     C                   endsr
650a *----------------------------------------------------------------
650a *
650a C     getlnk        begsr
650a *
650a *   Get linked items for counted item.
650a *
650a *   Get base item for B, S, R items.
650a C                   if        ittype <> ' '
650a C     itkey2        setll     itemlnk
650a C     itkey2        reade     itemlnk                                77
650a C     *in77         cabeq     *on           endlnk
650a C**                 eval      kyitem = ilitm2
650a C                   eval      klitem = ilitm2
650a C                   else
650a C                   eval      klitem = wkitem
650a C                   endif
650a * Process all linked items for base
650a C     itkeyL        setll     itemlnk1
     C                   eval      stop1 = *off
650a C                   dou       stop1 = *on
650a C     itkeyL        reade     itemlnk1                               77
650a C                   if        *in77
650a C                   eval      stop1 = *on
650a C                   else
650a C                   if        ilitem = wkitem
650a C                   iter
650a C                   else
650a C                   eval      kyitem = ilitem
650a C                   exsr      lstslt
650a C                   endif
650a C                   endif
650a C                   enddo
650a C
650a C     endlnk        endsr
650a *----------------------------------------------------------------
650a *
650a C     lstslt        begsr
650a *
650a *   Print all slots for counted item and linked items.
650a *
650a C     itkey2        setll     slot3
650aAC                   eval      stop = *off
650a C                   dou       stop = *on
650a C     itkey2        reade     slot3                                  79
650a C                   if        *in79
650a C                   eval      stop = *on
650a C                   else
650a C                   if        kyitem = wkitem
650a C                   eval      woitem = *blanks
650a C                   else
650a C                   eval      woitem = slitem
650a C                   endif
650a C                   eval      wosdsp = sldisp
650a C                   eval      wostk1 = slstk1
650a C                   eval      wostk2 = slstk2
650a C                   eval      wostk3 = slstk3
650a
650a C     ivkey1        setll     invslot4
650a C                   if        %equal(invslot4)
650a C                   eval      wocnt = 'C'
650a C                   else
650a C                   eval      wocnt = ' '
650a C                   endif
650a C                   write     details
650a C                   endif
650a C                   enddo
650a C     endlst        tag
650a C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Format report title.
     *
     *  Get report title.
     *
     C                   movel     'IV161PR '    wkprtf
     C                   eval      rptttl = *blanks
     C     rpkey         chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 40
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     *
     C                   if        not *inl1
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   if        not *inl2
     C                   eval      *in92 = *on
     C                   endif
     *
     C                   if        not *inl3
     C                   eval      *in93 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
     C                   write     skip1
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
     C                   add       sqt1(l)       sqt1(m)
     C                   add       sqt2(l)       sqt2(m)
     C                   add       sqt3(l)       sqt3(m)
     C                   add       stk1(l)       stk1(m)
     C                   add       stk2(l)       stk2(m)
     C                   add       stk3(l)       stk3(m)
     C                   add       dqt1(l)       dqt1(m)
     C                   add       dqt2(l)       dqt2(m)
     C                   add       dqt3(l)       dqt3(m)
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     *
     C                   eval      $rpd = rpd(l)
     C                   z-add     stk1(l)       tstk1
     C                   z-add     stk2(l)       tstk2
     C                   z-add     stk3(l)       tstk3
     C                   z-add     sqt1(l)       tsqt1
     C                   z-add     sqt2(l)       tsqt2
     C                   z-add     sqt3(l)       tsqt3
     C                   z-add     dqt1(l)       tdqt1
     C                   z-add     dqt2(l)       tdqt2
     C                   z-add     dqt3(l)       tdqt3
     *
416a C                   if        good1 = *on
     C                   if        $psum = 'Y'
416b C                   if        tdqt1 >= pmvar  or
416b C                             tdqt2 >= pmvar  or
416b C                             tdqt3 >= pmvar  or
720aDC*                            tdqt1 < pnvar  or
720aDC*                            tdqt2 < pnvar  or
720aDC*                            tdqt3 < pnvar
720aMC                             tdqt1 <= pnvar  or
720aMC                             tdqt2 <= pnvar  or
720aMC                             tdqt3 <= pnvar
     C                   write     totals
650aAC                   if        $plnkd = 'Y'
650aAC                   if        wkitem <> ' '
650aAC                   eval      kyitem = wkitem
650aAC                   exsr      lstslt
650aA* Get linked items.
650aAC                   exsr      getlnk
650aAC                   endif
650aAC                   endif
650aA*
416b C                   endif
     C                   else
500b C                   if        $pxcp = 'Y'
416b C                   if        tdqt1 >= pmvar  or
416b C                             tdqt2 >= pmvar  or
416b C                             tdqt3 >= pmvar  or
416b C                             tdqt1 < pnvar  or
416b C                             tdqt2 < pnvar  or
416b C                             tdqt3 < pnvar
     C                   write     total1
416b C                   endif
500b C                   else
500b C                   write     total1
500b C                   endif
     C                   endif
416a C                   eval      good1 = *off
416a C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     C                   eval      sqt1(l) = 0
     C                   eval      sqt2(l) = 0
     C                   eval      sqt3(l) = 0
     C                   eval      stk1(l) = 0
     C                   eval      stk2(l) = 0
     C                   eval      stk3(l) = 0
     C                   eval      dqt1(l) = 0
     C                   eval      dqt2(l) = 0
     C                   eval      dqt3(l) = 0
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      RPD   Report level descriptions
 * Not used *
 Average for week:
 *** Grand totals ***
**      OPTN  Options selected for report
Variances only
    Summary
