      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *
     *   Notes:  Version of this program duplicated for GUI in
     *           PIRSQLPGM/RCVEXCPT.  Make sure you consider any
     *           changes here in that program as well
     *           This was created on 11/15/2018
     *
     *----------------------------------------------------------------
     *
     *  EX126   Receiving exception report.
     *  03 October 2001
     *  Dave Sommerville
     *
     *  Revisions:
     *
416 A*    10/03/01  DAS  4.16
     *      - Created.
416aA*    12/03/01  RH   4.16a
     *      - Recompiled, ITMEXCP file changed.
417aA*    04/08/03  RH   4.17a
     *      - Recompiled, license field increased.
417bA*    05/08/03  RH   4.17b
     *      - FIX: Was not chaining to POMFR1 file when needed.
417cA*    05/22/03  RH   4.17c
     *      - Add exception UPC code to report.
417dA*    06/04/03  RH   4.17d
     *      - FIX: Blank LCNUPC field, had garbage left in it after
     *        a UPC was printed.
510aA*    12/29/06  RH   5.10a
     *      - Enh: Add date override exceptions to match PO232 overrid
510bA*    12/03/07  LMC  5.10b
     *      - Enh: Added date decipher code exceptions
520aA*    02/27/08  RH   5.20a
     *      - Enh: Add buyer, PO and calculated expiration date.
     *        Remove generated time, task and shorten description.
520bA*    01/06/09  RH   5.20b
     *      - Enh: Add detail2 to print entered MFG date if entered
     *
610 A*    09/10/09  MLB  6.10
     *      - Fix: Revised program load value from DSPO if chain to
     *        POMFR1 fails.
650aA*    07/31/13  LMC  6.50a
     *      - Enh: Added Receiving Catch Weight override exception.
     *      - Converted to RPGLE.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  91        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fitmexcp   ip   e           k disk
     Fpiritem   if   e           k disk
520a Fitemmsc   if   e           k disk
     Fwarehs    if   e           k disk
     Freports   if   e           k disk
     Fpomfr1    if   e           k disk
650aAFpocwexcp  if   e           k disk    rename(exrec:cwexrec) prefix(c_)
     FLicense1  if   e           k disk
     Fex126pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     *
     D cls             s              5  0 dim(3)
510aD*                   DESC    1   3 50
510bD*                   DESC    1   9 50
650aD*                   DESC    1  10 50
650aMD desc            s             50    dim(11) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D                 ds
     D  exfdis                 1     12
     D  extdis                13     24
     D  dspo                   1      9
     D  dslbl                 10     16  0
     D  dsexpd                17     24  0
417c D  dsupc                  1     20
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
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
     *  Variables
     *----------------------------------------------------------------

     D $llen           s              3  0
     D $lstr           s             60
     D $plen           s              3  0
     D $pstr           s             60
     D expdte          s              6  0
     D fmdt            s              6  0
     D gendte          s              6  0
     D l               s              1  0
     D m               s                   like(l)
     D mfgdte          s              6  0
     D todt            s              6  0
     D type            s              5
     D wkprtf          s             10
     D wodesc          s             21
     *----------------------------------------------------------------
     Iexrec
     I                                          exesta        l2
     I                                          exwhdp        l1
     I                                          exstyp        l1
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $from             8
     C                   parm                    $to               8
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Level break occurred.
     *     - Filled page.
     *
     C                   if        *in90  or
     C                             *inl1
     C                   exsr      zrzero
     *
     *  Format Dept/Section/Desig
     *
     C                   if        exstyp = 'P'
     C                   eval      type = 'PIR  '
     C                   else
     C                   if        exstyp = 'F'
     C                   eval      type = 'Fixed'
     C                   else
     C                   eval      type = '*Both'
     C                   endif
     C                   endif
     C                   eval      p#desc = *blanks
     C     'Dept:'       cat       exwhdp:1      p#desc
     C     p#desc        cat       'Type:':2     p#desc
     C     p#desc        cat       type:1        p#desc
     C                   movel     p#desc        $lstr
     C                   eval      $llen = 40
     C                   call      'CENTER'
     C                   parm                    $lstr
     C                   parm                    $llen
     C                   movel     $lstr         p#desc
     *
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Dept/Section
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   endif
     *
     *
     *  Output Headings
     *
     C                   if        *in91  or
     C                             *inl1
     C                   if        *in91
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   endif
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *  Convert Generated date
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      exgdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      gendte = $cvd6o
     *
     *  Retrieve item description.
     *
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   endif
520a C                   movel     itdesc        wodesc
520a *
520a C     itkey         chain     itemmsc                            79
520a C                   if        *in79
520a C                   eval      imbnbr = *zeros
520a C                   endif
     *
     *  Setup error description for printing.
     *
     C                   select
     C                   when      exerid = 'EXPDOVR'
     C                   movel     desc(3)       errmsg
510aAC                   when      exerid = 'OA-DOVR'
510aAC                   movel     desc(4)       errmsg
510aAC                   when      exerid = 'OB-DOVR'
510aAC                   movel     desc(5)       errmsg
510aAC                   when      exerid = 'OC-DOVR'
510aAC                   movel     desc(6)       errmsg
510aAC                   when      exerid = 'OD-DOVR'
510aAC                   movel     desc(7)       errmsg
510aAC                   when      exerid = 'OE-DOVR'
510aAC                   movel     desc(8)       errmsg
510aAC                   when      exerid = 'OF-DOVR'
510aAC                   movel     desc(9)       errmsg
510bAC                   when      exerid = 'DD-CODE'
510bAC                   movel     desc(10)      errmsg
650aAC                   when      exerid = 'CW-OVR '
650aAC                   movel     desc(11)      errmsg
     C                   other
     C                   eval      errmsg = exerid
     C                   endsl
     *
     *    Get POMFR record.
     *
417bD*          EXTASK    IFEQ 'EXPOVR'
417b C                   if        exerid = 'EXPDOVR'  or
510a C                             exerid = 'OA-DOVR'  or
510a C                             exerid = 'OB-DOVR'  or
510a C                             exerid = 'OC-DOVR'  or
510a C                             exerid = 'OD-DOVR'  or
510a C                             exerid = 'OE-DOVR'  or
510a C                             exerid = 'OF-DOVR'  or
510bAC                             exerid = 'DD-CODE'
650aAC*                            exerid = 'CW-OVR '
     C     dslbl         chain     pomfr1                             78
     C                   if        *in78
610 AC                   eval      pmpo = dspo
     C                   eval      pmseq = 0
     C                   eval      pmtrn# = 0
     C                   eval      pmexpd = 0
417a C                   eval      lilcns = *blanks
417a *                    Z-ADD0         LILCNS
     C                   endif
417a C                   else
610 AC                   eval      pmpo = dspo
417a C                   eval      pmseq = 0
417a C                   eval      pmtrn# = 0
417a C                   eval      pmexpd = 0
417a C                   eval      lilcns = *blanks
417a C                   endif
520aA*  Convert Expiration date
520aA*
520aAC                   eval      expdte = 0
520aAC                   if        pmexpd <> 0
520aAC                   eval      $cvcmd = '*CMDMDY '
520aAC                   move      pmexpd        $cvd8i
520aAC                   call      @cvtdt
520aAC                   parm                    $cvtdt
520aAC                   eval      expdte = $cvd6o
520aAC                   endif
     *
520bA*  Convert Mfg date
520bA*
520bAC                   eval      mfgdte = 0
520bAC                   if        pmmfgd <> 0
520bAC                   eval      $cvcmd = '*CMDMDY '
520bAC                   move      pmmfgd        $cvd8i
520bAC                   call      @cvtdt
520bAC                   parm                    $cvtdt
520bAC                   eval      mfgdte = $cvd6o
520aAC                   endif
     *
     *    Get LICENSE record.
     *
     C                   if        pmtrn# <> 0
     C     keyli         chain     license1                           78
     C                   if        *in78
417a *                    Z-ADD0         LILCNS
417aMC                   eval      lilcns = *blanks
     C                   endif
     C                   endif
650aA /free
650aA    if exerid = 'CW-OVR ';
650aA      chain (exwhse: dslbl) pocwexcp;
650aA      if not %found(pocwexcp);
650aA        eval lilcns = ' ';
650aA      else;
650aA        chain (c_exwhse:c_extrn#) license1;
650aA        if %found(license1);
650aA        else;
650aA          eval lilcns = ' ';
650aA        endif;
650aA      endif;
650aA      pmtrn# = c_extrn#;
650aA      pmpo = c_expo;
650aA    endif;
650aA /end-free
417c *
417c *  Move License or UPC to out field
417d C                   eval      lcnupc = *blanks
417c C                   if        exerid = 'RDUPUPC'
417c C                   eval      lcnupc = dsupc
417c C                   else
417c C                   movel     lilcns        lcnupc
417c C                   endif
     *
     *  Write detail line
     *
     C                   write     detail1
     *
650aAC                   if        exerid <> 'CW-OVR '
520bAC                   if        mfgdte <> 0
520bAC                   write     detail2                              90
520bAC                   endif
650aAC                   endif
     *
     *  Accumulate totals
     *
     C                   add       1             cls(1)
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in92 = *off
     C                   eval      *in91 = *off
     *----------------------------------------------------------------
     *
     * Slot type totals
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     CL1                 if        reck(l) > 0
     CL1                 write     skip1
     CL1                 exsr      zrtotl
     CL1                 endif
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 3
     *
     CLr                 if        reck(l) > 0
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
     C     itkey         klist
     C                   kfld                    exwhse
     C                   kfld                    exitem
     *
     C     exkey         klist
     C                   kfld                    exwhse
     C                   kfld                    exwhdp
     C                   kfld                    exstyp
     C                   kfld                    exitem
     C                   kfld                    exgdte
     C                   kfld                    exgtim
     *
     *  Define key for LICENSE1
     *
     C     keyli         klist
     C                   kfld                    pmwhse
     C                   kfld                    pmtrn#
     *
     *   Get report title.
     *
     C                   movel     'EX126PR '    wkprtf
     C                   eval      rptttl = *blanks
     C                   eval      $pstr = *blanks
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
     *   Convert dates to MMDDYY format.
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   eval      $cvd8i = $from
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      fmdt = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   eval      $cvd8i = $to
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      todt = $cvd6o
     *
     *
     C                   eval      $cvprg = #prog
     *
     C                   eval      l = 3
     C                   exsr      zrzero
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     exwhse        chain     warehs                             79
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
     *  Format Dept/Section/Desig
     *
     C                   if        exstyp = 'P'
     C                   eval      type = 'PIR  '
     C                   else
     C                   if        exstyp = 'F'
     C                   eval      type = 'Fixed'
     C                   else
     C                   eval      type = '*Both'
     C                   endif
     C                   endif
     C                   eval      p#desc = *blanks
     C     'Dept:'       cat       exwhdp:1      p#desc
     C     p#desc        cat       'Type:':2     p#desc
     C     p#desc        cat       type:1        p#desc
     C                   movel     p#desc        $lstr
     C                   eval      $llen = 40
     C                   call      'CENTER'
     C                   parm                    $lstr
     C                   parm                    $llen
     C                   movel     $lstr         p#desc
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
     C                   eval      *in90 = *off
     C                   exsr      zrfrmt
     *
     C                   write     head1
     C                   write     head2
     *                    WRITECOLUMNS
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
     C                   add       cls(l)        cls(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   eval      t#cls = cls(l)
     C                   eval      t#desc = *blanks
     C     exwhdp        cat       '/':1         t#desc
     C     t#desc        cat       type:1        t#desc
     *
     C                   if        l = 1
     C                   write     total1
     C                   endif
     *
     C                   if        l = 2
     C                   write     total2
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
     C                   eval      cls(l) = 0
     *
     *    Setup heading for either open/closed exceptions.
     C                   select
     C                   when      exesta = '1 '                                Open excpt
     C                   movel     desc(1)       p#stat
     *
     C                   when      exesta = '4 '                                Closed excpt
     C                   movel     desc(2)       p#stat
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
** Descriptions
            Open Exceptions
             Closed Exceptions
Exp dte ovrride
MFG Dt-Newer OFlow (PO13233)
MFG Dt-Dt > today  (PIR1010)
Exp Dt-> # days out(PO13243)
Exp Dt-Short sell  (PO13229)
MFG Dt-Short sell  (PO13228)
Exp Dt-Newer OFlow (PO13231)
Date Decipher
Catch Weight Ovr   (PT13019)
