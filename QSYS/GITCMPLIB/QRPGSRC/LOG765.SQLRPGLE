      /copy *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LOG765    Delete old DRI License Tracking records
     *  Max Blacknik
     *  10 May 2005
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    05/10/05  MLB  5.00
     *      - Created.
     *
600 A*    04/25/08  DAS  6.00  P#00045
     *      - License Tracking
     *
     *----------------------------------------------------------------

     *------------------------------------------------------------------
     * Misc defs ...
     *------------------------------------------------------------------

     D $pdays2keep     s              3  0
     D oldest          s              8  0
     D today           s              8  0
     D oldestdate      s               d

     *------------------------------------------------------------------
     * CLCDUR2 parameters
     *------------------------------------------------------------------

     D $PCmd           s              8

     D $PDateIn        s              8  0
     D $PTimeIn        s              6  0

     D $PYears         s              3  0
     D $PMonths        s              3  0
     D $PDays          s              3  0
     D $PHours         s              3  0
     D $PMinutes       s              3  0
     D $PSeconds       s              3  0

     D $PDateOut       s              8  0
     D $PTimeOut       s              6  0

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')
     *
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
     *      $pdays2keep  Number of days to keep
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pdays2keep

     *----------------------------------------------------------------
     *  Delete records
     *----------------------------------------------------------------
     *
     *         User wants to remove ALL records from file.
     C                   if        $pdays2keep < 0
     C/EXEC SQL
     C+ delete from loglt210
     C/END-EXEC

     C                   else

     *         User wants to remove records older than x days.
     C/EXEC SQL
     C+ delete from loglt210
     C+ where (DATE(lg210stamp) < :oldestdate)
     C/END-EXEC
     C                   endif

     C                   eval      *inlr = *on
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr

     *  Get current date.

     C                   if        $pdays2keep > 0
     C
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o

     *  Compute oldest date to keep for "days"

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $pcmd
     C                   parm      today         $pdatein
     C                   parm      0             $ptimein
     C                   parm      0             $pyears
     C                   parm      0             $pmonths
     C                   parm      $pdays2keep   $pdays
     C                   parm      0             $phours
     C                   parm      0             $pminutes
     C                   parm      0             $pseconds
     C     oldest        parm      0             $pdateout
     C                   parm      0             $ptimeout

     C     *iso          move      oldest        oldestdate

     C                   endif

     C                   endsr
