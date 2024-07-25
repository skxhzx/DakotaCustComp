      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IV395     Inventory scope to Assign
     *  18 September, 2006
     *  Roxanne Harrison
     *
     *
     *  Revisions:
     *  09/18/06  RH   5.10
     *    - Created using IV325
     *
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
     Finvpage   ip   e           k disk
     Fwarehs    if   e           k disk
     *HDEPT  IF  E           K        DISK
     Fiv395pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *
     *----------------------------------------------------------------
     *  Variables
     D $plen           s              3  0
     D $pstr           s             60
     D first           s              1
     D l               s              1  0
     D m               s                   like(l)
     *----------------------------------------------------------------
     Iivprec
     I                                          ivpwhs        l1
     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     *  Start new page if one of following happened.
     *     - Level break occurred.
     *     - Page overflow.
     *
     C                   if        *inl1  or
     C                             *in90
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Warehouse
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     *
     *  Write detail line.
     *
     C                   write     detail1
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     *
     *  Set off top-of-page indicators
     *
     C                   eval      *in91 = *off
     *----------------------------------------------------------------
     *
     * Slot type totals
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 2
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
     *  Define key for main file.
     *
411 D*R         KEYIT     KLIST
     *R                   KFLD           IVPWHS
     *R                   KFLD           IVPPAG
     *
     *    File WHDEPT
     *
     C     keywd         klist
     C                   kfld                    ivpwhs
     C                   kfld                    ivpwhd
     *
     C                   time                    time
     C                   eval      first = *on
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
     C     ivpwhs        chain     warehs                             79
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
     *   Get warehouse department description.
     *
    D*R         IVPWHD    IFNE LSTWHD
     *R                   MOVE *BLANKS   W1WHDP
     *R                   MOVE *BLANKS   $PSTR
     *R         KEYWD     CHAINWHDEPT               79
     *R         *IN79     IFEQ *ON
     *R                   MOVE *BLANKS   WDDESC
     *R                   ENDIF
     *R         IVPWHD    CAT  '-':1     W1WHDP
     *R         W1WHDP    CAT  WDDESC:1  W1WHDP
    D*R                   ENDIF
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   if        *inl1
     C                   exsr      zrfrmt
     C                   else
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
     C                   write     head2
     C                   write     columns
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrroll        begsr
     *
     C     l             add       1             m
     *
     *                    ADD  1         LVLK,M
     C                   add       reck(l)       reck(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     *                    Z-ADD0         LVLK,L
     C                   eval      reck(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
