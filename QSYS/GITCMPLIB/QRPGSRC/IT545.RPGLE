     F*----------------------------------------------------------------
     F*   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  IT545    Outside Storage Listing - Report
     F*  Ginger Andrews
     F*  02 September 2009
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
530 AF*    09/02/09  GJA  5.30
     F*      - Created.
     F*      - Included client custom code support to program.
640a F*    12/13/10  GJA  6.40a
     F*      - Fix:  Make sure item is found in PIRITEM with correct
     F*              department and item.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Not on file/End of file indicator
     F*  90        Overflow Indicator
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FSLOT4     IP   E           K DISK
     FPIRITEM1  IF   E           K DISK
     FWAREHS    IF   E           K DISK
     FIT545PR   O    E             PRINTER OFLIND(*IN90)
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D*----------------------------------------------------------------
     D*  Customer id
      /copy qcopysrc,id#sgc
     D client          s             10
     D clientloc       s             10
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
     D $pstr           s             60a
     D $pwhse          s                   like(itwhse)
     D svwhdp          s                   like(itwhdp)
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
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C     *ENTRY        PLIST
     C                   PARM                    $PWHS             3
     C                   PARM                    $PWHDP            5
     C*----------------------------------------------------------------
     C*
     C
     C
     C*  If processing all departments, see if dept changed.
     C                   if            slwhdp <> svwhdp
     C                             and $pwhdp = '*ALL '
     C                   eval      svwhdp = slwhdp
     C                   eval      *in90 = '1'
     C                   endif
     C
     C*
     C*  Report Heading
     C*
     C     *IN90         IFEQ      '1'
     C     FIRST         OREQ      '1'
     C                   EXSR      ZRHEAD
     C                   endif
     C*
     C* Detail Calcs
     C*
     C                   if            slaisl =  'OSS'
     C                                 or client = sgc and slaisl = ' CT'
     C                   if            slwhdp =  $pwhdp
     C                             or  $pwhdp = '*ALL '
     C     itkey1        chain     piritem1
640aAC                   if        not %found(piritem1)
640aAC                   eval      ititem = slitem
640aAC                   eval      *in20 = *on
640aAC                   endif
     C*
     C*  Convert today's date into MMDDYY format.
     C*
     C                   if            slentd <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      slentd        $cvd8i
     C                   call      @CVTDT
     C                   parm                    $CVTDT
     C                   eval      entd = $cvd6o
     C                   else
     C                   eval      entd = 0
     C                   endif
     C*
     C                   if        slexpd <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      slexpd        $cvd8i
     C                   call      @CVTDT
     C                   parm                    $CVTDT
     C                   eval      expd = $cvd6o
     C                   else
     C                   eval      expd = 0
     C                   endif
     C*
     C                   WRITE     DETAIL1
640aAC                   eval      *in20 = *off
     C                   endif
     C                   endif
     C*
     C*  Set off top-of-page indicators
     C*
     C                   MOVE      '0'           FIRST
     C                   MOVE      '0'           *IN91
     C                   MOVE      '0'           *IN92
     C
     C*
     CLR                 if        first = '1'
     CLR                 exsr      zrhead
     CLR                 write     detail2
     CLR                 endif
     C*
     CLR                 write     skip1
     C*
     CLR                 write     foot1
     C*
     C*****************************************************************
     C*
     C*  *INZSR  Initialization subroutine
     C*
     C     *INZSR        BEGSR
     C*
     C* Get client id.
     C*
     C                   CALL      'GETCLIENT'
     C                   PARM                    client
     C                   PARM                    clientloc
     C*
     C     itkey1        klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    slitem
     C*
     C                   move      $pwhs         $pwhse
     C*
     C*  Convert today's date into MMDDYY format.
     C*
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @CVTDT
     C                   parm                    $CVTDT
     C                   eval      rdate = $cvd6o
     C                   time                    rtime
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
     C                   eval      $pstr = 'Outside Storage Li-
     C                             sting'
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
     C     ZRHEAD        BEGSR
     C*
     C*
     C                   eval      *in90 = '0'
     C                   WRITE     HEAD1
     C                   WRITE     COLUMNS
     C*
     C                   ENDSR
     O*
     O*  COMPILE TIME TABLES
     O*
