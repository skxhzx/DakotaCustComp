     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  LOG755    Delete old Dakota Realtime Interface log records
     *  Dave Sommerville
     *  22 February 2002
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    02/22/02  DAS  4.16
     *      - Created.
     *
416aA*    03/29/02  DAS  4.16a
     *      - Added $phours2keep parameter.
     *      - Revised to use CLCDUR2 routine.
     *
500 A*    01/05/05  DAS  5.00
     *      - Added logic to CONNECT to database.
     *
530 A*    04/22/10  MLB  5.30
     *      - Fix: Revised pgm to add support for LOGSLOTDTE file
     *        cleanup.
     *
     *----------------------------------------------------------------

     *------------------------------------------------------------------
     * Misc defs ...
     *------------------------------------------------------------------

     D $pdays2keep     s             15  5
416aAD $phours2keep    s             15  5
416aAD curtime         s              6  0
     D oldest          s              8  0
416aAD hoursdate       s              8  0
416aAD hourstime       s              6  0
     D today           s              8  0

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
     *      $phours2keep  Number of hours to keep
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pdays2keep
416aAC                   parm                    $phours2keep

500 A*----------------------------------------------------------------
500 A* Establish the connection to the remote machine. The -842 return
500 A* code indicates that the connection is already established. If
500 A* you want to connect to the local machine, use CONNECT RESET.
500 A*----------------------------------------------------------------
500 A
500 AC/EXEC SQL
500 AC+ CONNECT RESET
500 AC/END-EXEC

     *----------------------------------------------------------------
     *  Delete records
     *----------------------------------------------------------------

     C/EXEC SQL
     C+  delete
     C+  from   logdri
     C+  where  (lgdridate = :hoursdate and lgdritime < :hourstime) or
     C+         (lgdridate < :hoursdate)
     C/END-EXEC

     C/EXEC SQL
     C+  delete
     C+  from   logslot
     C+  where  (lgslotdate < :oldest)
     C/END-EXEC
530 A
530 AC/EXEC SQL
530 AC+  delete
530 AC+  from   logslotdte
530 AC+  where  (lgsldtentd < :oldest)
530 AC/END-EXEC

     C/EXEC SQL
     C+  delete
     C+  from   logiqty
     C+  where  (lgiqtydate < :oldest)
     C/END-EXEC

     C/EXEC SQL
     C+  delete
     C+  from   logprtyrpl
     C+  where  (lgprdate < :oldest)
     C/END-EXEC

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

     *  Get current time.

     C                   time                    curtime

     *  Compute oldest date/time to keep for "hours"

     C                   call      'CLCDUR2'
     C                   parm      '*SUB'        $pcmd
     C                   parm      today         $pdatein
     C                   parm      curtime       $ptimein
     C                   parm      0             $pyears
     C                   parm      0             $pmonths
     C                   parm      0             $pdays
     C                   parm      $phours2keep  $phours
     C                   parm      0             $pminutes
     C                   parm      0             $pseconds
     C     hoursdate     parm      0             $pdateout
     C     hourstime     parm      0             $ptimeout

     C                   endsr
