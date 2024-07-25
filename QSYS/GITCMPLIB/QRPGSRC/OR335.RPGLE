     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR335     Order Lookup by Item Report
     *  Ginger Andrews
     *  10 March, 2008
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    03/10/08  GJA  5.20  P#00023
     *      - Creation
710aA*    09/19/17  JCJ  7.10a
     *      - Renamed to OR335
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *  91        Customer change
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     FOR330     ip   e           k disk
     Fwarehs    if   e           k disk
     FOR330PR   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *----------------------------------------------------------------
     *
     *  Program parameters
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
     D  $litem                22     36
     D  $llsld                37     42  0
     *
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
     *-----VARIABLES--------------------------------------------------
     D $plen           s              3  0
     D $pstr           s             60
     D first           s              1
     D hlditm          s                   like($item)
     D wkwhse          s              3  0
     D w1date          s              6  0
     D w1from          s              6  0
     D w1to            s              6  0
     *****************************************************************
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $WHSE  - Warehouse
     *      $FROM  - From date - returned as unpacked numeric
     *      $TO    - To date - returned as unpacked numeric
     *      $ITEM  - Item # or *all
     *
     *    Returned Parameters
     *      None
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $from             8
     C                   parm                    $to               8
     C                   parm                    $item            15
     C                   parm                    #user            10
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
     * Detail Calcs
     *
     *
     * Convert import date
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      wkimpd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1date = $cvd6o
     *
     C                   write     detail1
     *
     *  Set off top-of-page indicators
     *
     C                   eval      first = *off
     C                   eval      *in91 = *off
     C                   eval      *in93 = *off
     *
     CLrn95              exsr      zrfrmt
     CLrn95              exsr      zrhead
     CLrn95              write     detail2
     CLr                 write     foot1
     *
     *
     *****************************************************************
     *
     *  *INZSR  Initialization subroutine
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
     C                   eval      hlditm=$item
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
     C                   move      $whse         wkwhse
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
     C                   eval      item = $item
     C                   endsr
     *****************************************************************
     *
     C     zrhead        begsr
     *
     C                   eval      *in91 = *on
     *
     C                   eval      *in90 = *off
     C                   write     head1
     *
     C                   write     columns
     *
     C                   endsr
     *
