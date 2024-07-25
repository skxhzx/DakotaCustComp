      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER513D    Employee Activity Report - Slot/Date
     *  Hemant Kapadia
     *  07 Sept, 2001
     *
     *  Revisions
     *
     *    09/07/01  HNK  4.16
     *      - Created
     *
     *  07/22/09   GJA  5.30
     *     -Enh:  Convert to RPGLE, cleaned up and revamped for
     *             suspended transactions.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fer513c    ip   e           k disk
     Fwarehs    if   e           k disk
     Fer513dpr  o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D tabt            s              1    dim(7) ctdata perrcd(1)
     D tabtyp          s             10    dim(7) ctdata perrcd(1)
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
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *----------------------------------------------------------------
     *  Variables
     *
     D $cmd            s              8
     D $name           s             40
     D $plen           s              3  0
     D $pstr           s             60
     D first           s              1
     D w1date          s              6  0
     D w1from          s              6  0
     D w1qty           s              5  0
     D w1to            s              6  0
     *****************************************************************
     Iwkrec
     I                                          wkdisp        l2
     I                                          wkdate        l1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $FROM  - From date - returned as unpacked numeric
     *      $TO    - To date - returned as unpacked numeric
     *      $ITEM  - Item # or *all
     *      $DISP  - Slot or *all
     *
     *    Returned Parameters
     *      None
     *
     C     *entry        plist
     C                   parm                    $from             8
     C                   parm                    $to               8
     C                   parm                    $item            15
     C                   parm                    $disp            12
     C                   parm                    $task             6
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     C                   if        *in90  or
     C                             first = '1'
     C                   eval      *in95 = *on
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   endif
     *
     *  L2 break - Slot change.
     *
     C                   if        *inl2
     C                   eval      *in92 = *on
     C                   endif
     *
     *  L1 break - Date change.
     *
     C                   if        *inl1
     C                   eval      *in91 = *on
     C                   endif
     *
     * Detail Calcs
     *
     *
     C                   movel     wkitem        w1item
     C                   movel     wkdesc        w1desc
     C                   eval      $cmd = '*LFM    '
     C                   eval      $name = *blanks
     C                   call      'FRMTNM'
     C                   parm                    $cmd
     C                   parm                    wkfnam
     C                   parm                    wkinit
     C                   parm                    wklnam
     C                   parm                    $name
     C                   movel     $name         w1name
     * Lookup Type
     C     wktype        lookup    tabt          tabtyp                   09
     C                   if        *in09
     C                   eval      w1type = tabtyp
     C                   else
     C                   movel     wktype        w1type
     C                   endif
     * Convert date
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      wkdate        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1date = $cvd6o
     *
     * Convert quantity
     C                   eval      w1qty = wkqty
     C                   write     detail1
     *
     *  Set off top-of-page indicators
     *
     C                   eval      first = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     *
     CL1                 write     skip1
     *
     CLrn95              exsr      zrfrmt
     CLrn95              exsr      zrhead
     CLrn95              write     detail2
     CLr                 write     foot1
     *****************************************************************
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     C                   eval      first = *on
     *
     *   Convert dates to MMDDYY format.
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   eval      $cvd8i = $from
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1from = $cvd6o
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   eval      $cvd8i = $to
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1to = $cvd6o
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     wkwhse        chain     warehs                             79
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
     *
     *   Move item # and slot description.
     *
     C                   eval      item = *blanks
     C                   eval      disp = *blanks
     C                   eval      item = $item
     C                   eval      disp = $disp
     C                   eval      task = $task
     C                   endsr
     *****************************************************************
     *
     C     zrhead        begsr
     *
     C                   if        not *inl1
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   if        not *inl2
     C                   eval      *in92 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     C                   write     head1
     C                   write     columns
     *
     C                   endsr
     *
     *  COMPILE TIME TABLES
     *
**
B
O
R
P
I
A
T
**
Bulk pick
Pick
Replenish
Put away
Inventory
Adjustment
Transfer
