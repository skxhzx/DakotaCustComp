     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RU371     Cleared flags report
     *  15 july, 2004
     *  Jose Duque
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
500 A*    05/20/05  MLB  5.00
     *      - Fix: Change size of field rec# to 9,0.
     *
650  *    02/27/13  GJA  6.50
     *      - Enh: Converted to RPGLE
     *
650a *    02/27/13  GJA/LMC  6.50a
     *      - Enh: Add item total lines
     *
700 A*    12/04/15  MLB  7.00
     *      - Fix: Corrected page overflow errors and dde error on
     *        count field when it caused pgm to fail with MCH1210 -
     *        Receiver value too small to hold result.
     *
700a *    03/30/16  GJA  7.00a
     *      - Enh: Allow deleted flags
     *      - Enh: Add Loader option to populate closed
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Coastal
     *
CSPa *    02/27/13  GJA  6.50a
     *      - Enh: Print item total lines
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
     Fru371     ip   e           k disk
     Fwarehs    if   e           k disk
700aAFoptions   if   e           k disk
     Fru371pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *  Data structure To hold flag Open, Print and Close times.
     *
     D                 ds
     D  hldtim                 1      6
     D  hldhr                  1      2
     D  hldmm                  3      4
     D  hldss                  5      6
700aA*
700aA*----------------------------------------------------------------
700aA*  *RUNNER  -  PIR Runner Flag Options
700aA*----------------------------------------------------------------
700aA*
700aA* Fields
700aA*
700aA*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
700aA*    OPUPLR  -  Update Label with quantity shorted during manual
700aA*               flag entry (Y/N)
700aA*               NOTE: Any change to this field will cause OPUPLV
700aA*                     in the *VOICE options record to be updated.
700aA*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
700aA*               & create Priority Replenishment if necessary.
700aA*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
700aA*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
700aA*    OPRNRM  -  Send break message to user when new Runner
700aA*               task has been assigned. (Y/N)
700aA*    OPCLSF  -  Update Label quantity at flag close (Y/N).
700aA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
700aA*    OPRPCK  -  Print Runner pick list. (Y/N)
700aA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
700aA*               printer, 2=Belt printer
700aA*    OPRBDU  -  Allow shorts to be filled with breakdown units (Y/N).
700aA*    OPRSCN  -  Scan tran# or label# to start pick.
700aA*                 1=tran#, 2=label#.
700aA*    OPRVFS  -  Verify pick slot, Y/N.
700aA*    OPRVFQ  -  Verify qty found, Y/N.
700aA*    OPRLOA  -  Using loader module, Y/N.
700aA*----------------------------------------------------------------
700aA* Data structure
700aA*
700aAD oprdta          ds
700aAD  opcrtm                 1      1
700aAD  opuplr                 2      2
700aAD  oprplf                 3      3
700aAD  opmrgf                 4      4
700aAD  opclrf                 5      5
700aAD  oprnrm                 6      6
700aAD  opclsf                 7      7
700aAD  opoutf                 8      8
700aAD  oprpck                 9      9
700aAD  oprlbl                10     10
700aAD  oprbdu                11     11
700aAD  oprscn                12     12
700aAD  oprvfs                13     13
700aAD  oprvfq                14     14
700aAD  oprloa                15     15
700aAD  optendr              117    117

     *----------------------------------------------------------------
     *  Variables
     *
     D $plen           s              3  0
     D $pstr           s             60
     D count           s              3  0
     D dpttot          s              5  0
     D first           s              1
     D flgcnt          s              5  0
     D holdit          s             26
650aAD itmcnt          s              3  0
     D pag1            s              1
     D rec#            s              9  0
     D recpag          s              3  0
     D savitm          s             15
     *----------------------------------------------------------------
     Irurec
650aDI****                                      ruwhdp        l1
650aMI                                          ruwhdp        l2
650aAI                                          ititem        l1
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Level break occurred.
     *     - Filled page.
     *
     *
     C     *entry        plist
     C                   parm                    $sdte6            6
     C                   parm                    $pdte6            6
700aAC                   parm                    $dlt              1
     *
     C                   if        first = *on
     C                   exsr      zrfrmt
     C                   eval      first = *off
700aA*
700aA*      Retrieve *RUNNER options record.
700aAC                   exsr      zzgetruop
700aA*
     C                   endif
     *
     C                   if        count = recpag  or
650aDC***                          *inl1
650aMC                             *inl2
700 AC                             or *in90 = '1'
     C                   exsr      zrhead
     C                   endif
      *
650aAc                   select
650aAc                   when      *inl1 and itmcnt = 1
650aAc                   eval      itmcnt = 0
650aAc                   eval      witqty = 0
650aAc                   eval      wittto = 0
650aAc                   when      *inl1 and itmcnt > 1
650aAc                   eval      wittto = itmcnt
650aAc                   write     itmtot
650aAc                   eval      itmcnt = 0
650aAc                   eval      witqty = 0
650aAc                   eval      wittto = 0
650aAc                   eval      count = count + 1
650aAc                   endsl
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     C                   if        rustat <> 'D'                                Skip deleted
700aAC                             or  $dlt = 'Y'
700aAC                             and rustat = 'D'
     C                   exsr      zrdetl                                       flags
     C                   endif
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 if        rec# > 0
     CLr                 eval      wdptto = flgcnt
     CLr                 write     skip1
     CLr                 write     deptot
     CLr                 add       wdptto        walldp
     CLr                 write     skip1
     CLr                 write     alldpt
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
     C                   time                    time
     C                   eval      first = *on
     C                   eval      pag1 = *on
500 D**                   Z-ADD0         REC#    30
500 MC                   eval      rec# = 0
     C                   eval      count = 0
650aAC                   eval      itmcnt = 0
650aAC                   eval      wittto = 0
650aAC                   eval      witqty = 0
     C                   eval      flgcnt = 0
     C                   eval      dpttot = 0
     C                   eval      recpag = 55
     C                   move      $pdte6        frmdte
     C                   move      $sdte6        todte
     C                   eval      savitm = *blanks
700aA*
700aA*  Define key for OPTIONS file.
700aA*
700aAC     opkey         klist
700aAC                   kfld                    ruwhse
700aAC                   kfld                    opcode
     *
     C                   exsr      zrcler
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
     C     ruwhse        chain     warehs                             79
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
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   eval      *in90 = *off
     *
     C                   if        pag1 = *off  and
650aDC***                          *inl1
650aMC                             *inl2
     C                   eval      wdptto = flgcnt
     C                   write     skip1
     C                   write     deptot
     C                   add       wdptto        walldp
     C                   eval      flgcnt = *zeros
     C                   else
     C                   eval      pag1 = *off
     C                   endif
650aAC                   if        pag1 = *off  and
650aAC                             *inl2
650aAC                   eval      wdptto = flgcnt
650aAC                   write     skip1
650aAC                   write     deptot
650aAC                   add       wdptto        walldp
650aAC                   eval      flgcnt = *zeros
650aAC                   else
650aAC                   eval      pag1 = *off
     C                   endif
     *
     *  Print headings for the next page.
     *
     C                   write     head1
     C                   write     columns
     C                   eval      wdept = ruwhdp
     *
     *
     *  Print previous page detail lines.
     *
     C                   eval      count = 0
650aAC                   eval      itmcnt = 0
650aAC                   eval      wittto = 0
650aAC                   eval      witqty = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrcler        begsr
     *
     *   Initialize all data structures.
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrdetl        begsr
     *
     *
     *          Move flag start,close and diff times to report
     *
     C                   eval      hldhr = %subst(ruodtt:1:2)
     C                   eval      hldmm = %subst(ruodtt:3:2)
     C                   eval      hldss = %subst(ruodtt:5:2)
     C                   move      hldtim        w1strt                         FlagStarTime
     *
     C                   eval      holdit = rucdts
     *
     C                   eval      hldhr = %subst(holdit:12:2)
     C                   eval      hldmm = %subst(holdit:15:2)
     C                   eval      hldss = %subst(holdit:18:2)
     C                   move      hldtim        w1clst                         FlagClosTime
     *
     C                   eval      w1diff = rhshpt                              TimeDiff
     *
     *          Find type of flag
     *
     C                   eval      w1type = *blanks
     C                   select
700aAC                   when      rustat = 'D'
700aAC                             and $dlt = 'Y'
700aAC                   movel     'DELETE'      w1type
     *
     C                   when      rutype = 'N'
     C                   movel     'REPL'        w1type
     *
     C                   when      rutype = 'U'
     C                   movel     'OUT'         w1type
     *
     C                   when      rutype = 'M'
     C                   movel     'MERGE'       w1type
     *
     C                   endsl
     *
     *  Print detail line.
     *
     C                   if        ititem <> savitm
     C                   add       1             flgcnt
     C                   eval      savitm = ititem
     C                   endif
     *
700 DC*                  write     detail1
700 MC                   write     detail1                              90
     C                   add       1             count
650aAC                   add       1             itmcnt
     C                   add       1             rec#
650aAc                   eval      witqty = witqty + ruqyso
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *
     C     zrtotl        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZGETRUOP  Get Runner Options record.
700aA*
700aAC     zzgetruop     begsr
700aA*
700aAC                   eval      opcode = '*RUNNER '
700aA*
700aAC     opkey         chain     options
700aAC                   if        not %found(options)
700aAC                   eval      oprloa = 'N'
700aAC                   else
700aAC                   movel     opdata        oprdta
700aAC                   endif
700aA*
700aAC                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
