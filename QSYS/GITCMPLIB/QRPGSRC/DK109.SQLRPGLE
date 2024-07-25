     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DK109     Delete dock door history
     *  06 November 2001
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    11/06/01  DAS  4.16
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

415aAD day             s              1  0
415aAD oldest          s              8  0
415aAD today           s              8  0

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   CONST('CVTDTE')
     D @clcdr          c                   CONST('CLCDUR')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

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
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0
     D  $cvdr2               146    153
     D  $cvvl2               154    158  0
     D  $cvdr3               159    166
     D  $cvvl3               167    171  0
     D  $cvdr4               172    179
     D  $cvvl4               180    184  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse   - Warehouse number
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse           15 5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Delete matrix records

     C/EXEC SQL
     C+  DELETE
     C+  FROM   DOCMTRX
     C+  WHERE  (DMWHSE = :$pwhse and DMHDTE < :Oldest)
     C/END-EXEC

     *  Delete history records

     C/EXEC SQL
     C+  DELETE
     C+  FROM   DOCHIST
     C+  WHERE  (DHWHSE = :$pwhse and DHHDTE < :Oldest)
     C/END-EXEC

     C                   Eval      *inlr = *ON
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Get current date.

     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      Today = $cvd8o

     *  Convert current date to day number.

     C                   eval      $cvcmd = '*CMDNBR '
     C                   move      today         $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      Day = $cvd6o

     *  Compute oldest date to keep (keeping 5 days)

     C                   eval      $cvcmd = '*CMDCMD '
     C                   move      today         $cvd8i
     C                   eval      $cvdr1 = '*SUBDAYS'
     C                   eval      $cvvl1 = 5
     C                   call      @clcdr
     C                   parm                    $cvtdt
     C                   eval      oldest = $cvd8o

     C                   endsr
