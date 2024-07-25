     F*----------------------------------------------------------------
     F*   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  IT535    Recommend Transfers From Outside Storage - Report
     F*  Max Blacknik
     F*  26 May 2009
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
520 AF*    05/26/09  MLB  5.20
     F*      - Created.
     F*      - Included client custom code support to program.
640 A*   02/01/11  RH   6.40
     *     - Fix: Change SLKEY4A and SLKEY4B to use ITWHDP, was using
     *       entered value and incorrect if '*ALL' was entered.
640bA*   05/10/12  RTR  6.40b
     *     - Enh: Split into two programs.  Selection logic moved to
     *       IT534 to build work file. This now only prints sorted
     *       records from work file IT535, which is sorted using
     *       OPNQRYF in the calling CL.
640cA*   05/14/12  RTR  6.40c
     *     - Enh: Added sort and selection text to heading
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRYaA*   01/31/11  RH   DRYa
     *     - Changed program to select slots greater than or = aisle
     *       entered.
DRYbA*   04/26/11  RH   DRYb
     *     - Changed program to not count slot w/aisle starting 'T'
DRYc  *   06/06/11  RH   DRYc
      *     - Changed program to not count pick slots in aisle Offsite
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter County Bakers
     *
ICBaA*   03/15/12  RH   ICBa
     *     - Changed to select slots = aisle H, I, N, P, R, T
     *       no aisle was entered.
ICBbA*   03/27/12  RH   ICBb
     *     - Enh: allow *ORD for aisle, will use ITEMORD file in place
     *       of ITEMAVG (average sales)
ICBcA*   04/19/12  RBD  ICBc
     *     - Enh: per Brian, added aisle G to list of OSS aisles.
ICBdA*   05/10/12  RTR  ICBd
     *     - Enh: Add first OSS slot to report.
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Not on file/End of file indicator
     F*  90        Overflow Indicator
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FIT535     IF   E             DISK
     F*IRITEM1  IF   E           K DISK
     F*TEMAVG   IF   E           K DISK
ICBbAF*TEMORD   IF   E           K DISK
     F*LOT3     IF   E           K DISK
     F*                                    rename(slrec:slrec3)
     F*LOT4     IF   E           K DISK
     F*                                    rename(slrec:slrec4)
     FWAREHS    IF   E           K DISK
     FIT535PR   O    E             PRINTER OFLIND(*IN90)
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D*----------------------------------------------------------------
     D*  Customer id
DRYaA /copy qcopysrc,id#dairyla
ICBaA /copy qcopysrc,id#icb
     D*
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D*----------------------------------------------------------------
     D*  Working variable(s)
     D*
     D first           s              1a   inz('1')
     D forever         s              1a   inz('1')
     D osL             s              3s 0
     D $pdaysply       s              3s 0
     D $pstr           s             60a
     D $pwhse          s              3s 0
     D svwhdp          s                   like(itwhdp)
ICBbAD today           s              8s 0
     D*
     D*----------------------------------------------------------------
     D*
     D $PERM           DS
     D  XXERM                  1     60
     D  $PMSG                  1      4
     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PWHS    - Warehouse number
     C*      $PWHDP   - Warehouse department or *ALL
     C*      $PDYSP   - Days supply to have on-hand
     C*      $POSSLOC - Slot or *all
640cAC*      $PSORT   - Sort order
640cAC*      $PSEL    - Selection
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C     *ENTRY        PLIST
     C                   PARM                    $PWHS             3
     C                   PARM                    $PWHDP            5
     C                   PARM                    $PDYSP            3
     C                   PARM                    $POSSLOC         12
640cAC                   PARM                    $PSORT            5
640cAC                   PARM                    $PSEL             4
     C*----------------------------------------------------------------
     C*
     C                   dow       forever = forever
     C                   read      wkrec
     C*
     C                   if        %eof(it535)
     C                   leave
     C                   endif
     C
     C*  If processing all departtments, see if dept changed.
     C                   if            itwhdp <> svwhdp
     C                             and $pwhdp = '*ALL '
     C                   eval      svwhdp = itwhdp
     C                   eval      *in90 = '1'
     C                   endif
     C*
     C*  Report Heading
     C*
     C     *IN90         IFEQ      '1'
     C     FIRST         OREQ      '1'
     C                   EXSR      ZRHEAD
     C                   END
     C*
     C* Detail Calcs
     C*
     C                   WRITE     DETAIL1
     C*
     C*  Set off top-of-page indicators
     C*
     C                   MOVE      '0'           FIRST
     C                   MOVE      '0'           *IN91
     C                   MOVE      '0'           *IN92
     C
     C                   enddo
     C
     C                   eval      *inlr = *on
     C*
     C                   if        first = '1'
     C                   exsr      zrhead
     C                   write     detail2
     C                   endif
     C*
     C                   write     skip1
     C*
     CLR                 write     foot1
     C*
     C*****************************************************************
     C*
     C*  *INZSR  Initialization subroutine
     C*
     CSR   *INZSR        BEGSR
     C*
     C* Get client id.
     C*
     C                   CALL      'GETCLIENT'
     C                   PARM                    CLIENT           10
     C                   PARM                    CLIENTLOC        10
     C*
     C*    igkey         klist
     C*                  kfld                    $pwhse
     C*                  kfld                    ititem
     C*
     C*    itkey1        klist
     C*                  kfld                    $pwhse
     C*                  kfld                    $pwhdp
     C*
     C*    slkey3        klist
     C*                  kfld                    $pwhse
     C*                  kfld                    ititem
     C*                  kfld                    kystat
     C*                  kfld                    kypick
     C*
     C*    slkey4a       klist
     C*                  kfld                    $pwhse
640 DC*                  kfld                    $pwhdp
640 MC*                  kfld                    itwhdp
     C*                  kfld                    ititem
     C*                  kfld                    $possloc
     C*
     C*    slkey4b       klist
     C*                  kfld                    $pwhse
640 DC*                  kfld                    $pwhdp
640 MC*                  kfld                    itwhdp
     C*                  kfld                    ititem
     C*
     C                   move      $pwhs         $pwhse
     C                   move      $pdysp        $pdaysply
     C                   evalr     r1dmtx = %editc($pdaysply:'4')
     C     ' '           checkr    $possloc      osL
     C                   if        osL <= 0
     C                   eval      osL = 1
     C                   endif
     C*
     C*  Convert today's date into MMDDYY format.
     C*
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @CVTDT
     C                   parm                    $CVTDT
     C                   eval      rdate = $cvd6o
     C                   time                    rtime
ICBbA*      Compute today's date.
ICBbAC                   eval      $cvcmd = '*CURCMD '
ICBbAC                   call      @cvtdt
ICBbAC                   parm                    $cvtdt
ICBbAC                   eval      today  = $cvd8o
ICBbA*
     C*
     C                   exsr      zrfrmt
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRFRMT        BEGSR
     C*
     C*   Get warehouse description.
     C*
     C                   MOVE      *BLANKS       WHSE
     C                   MOVE      *BLANKS       $PSTR
     C     $pwhse        CHAIN     WAREHS
     C                   if        not %found(warehs)
     C                   eval      whdesc = ' '
     C                   ENDIF
     C                   eval      $pstr = $pwhs + ' / ' +
     C                             whdesc
     C                   Z-ADD     40            $PLEN
     C*
     C*   Center warehouse description.
     C*
     C                   CALL      'CENTER'
     C                   PARM                    $PSTR
     C                   PARM                    $PLEN             3 0
     C                   MOVEL     $PSTR         WHSE
     C*
640cAC                   if        $possloc = *blank
640cAC                   eval      $pstr = 'Outside Storage Lo-
640cAC                             cation *ALL'
640cAC                   else
     C                   eval      $pstr = 'Outside Storage Lo-
     C                             cation ' + $possloc
640cAC                   endif
     C*
     C*   Center warehouse description.
     C*
     C                   CALL      'CENTER'
     C                   PARM                    $PSTR
     C                   PARM                    $PLEN
     C                   MOVEL     $PSTR         OSSLOC
     C*
     C*   Move item # and slot description.
     C*
     C                   ENDSR
     C*****************************************************************
     C*
     CSR   ZRHEAD        BEGSR
     C*
     C*
     CSR                 eval      *in90 = '0'
     C*
640cACSR                 if        $psel = '*ORD'
640cACSR                 eval      hsel = 'Order'
640cACSR                 else
640cACSR                 eval      hsel = 'Sales'
640cACSR                 endif
     C*
640cACSR                 if        $psort = '*SLOT'
640cACSR                 eval      hsort = 'OSS Slot '
640cACSR                 else
640cACSR                 eval      hsort = 'Item     '
640cACSR                 endif
     C*
     CSR                 WRITE     HEAD1
     CSR                 WRITE     COLUMNS
     C*
     CSR                 ENDSR
     O*
     O*  COMPILE TIME TABLES
     O*
