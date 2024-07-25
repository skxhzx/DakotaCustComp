      /copy *libl/qcopysrc,hspecs

      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
      *
      *
      * COMPILING. In order to compile this program you will need
      *            to use options which allow it to work correctly
      *            between machines. These options are---
      *
      *               COMMIT = *NONE
      *               DLYPRP = *YES
      *****************************************************************

     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  HT100     Populate DLYHITS file.
     *  10 July 2004
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    07/10/04  DAS  4.17
     *      - Created.
     *
417aA*    07/14/04  DAS  4.17a
     *      - Added fields HTMEDIAN and HTVAR to DLYHITS file.
     *      - Added HTVAR to SQL statement.
     *      - Added logic to update base slot and item.
     *      - Change to select records less than end time.
     *
417bA*    07/14/04  RH   4.17b
     *      - Add options for start time.
417cA*    07/16/04  RH   4.17c
     *      - Skip undone orders (LBVRFY='U')
     *
650 A*    03/02/15  MLB  6.50
     *      - Enh: Added client custom code support to pgm.
     *
750 A*    02/14/22  KDE  7.50
     *      - Enh: Use first parent only for base item when repack
     *        item has more than one parent
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
     *
EI  A*    03/02/15  MLB  EI
     *      - Revised program to process FIXED, PIR transactions created
     *        for will-call orders since all routes/orders sent to TB
     *        are for will-call orders.
     *
     *----------------------------------------------------------------

417bA*----------------------------------------------------------------
417bA*  File Specs
417bA*----------------------------------------------------------------
417bAFoptions   if   e           k disk

650 A*----------------------------------------------------------------
650 A*  Customer id
650 A*
650 AD @getcl          c                   const('GETCLIENT')
650 A*
EI  A /copy qcopysrc,id#EI
     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')
     D forever         s               n   inz('1')
     D Quote           C                   Const('''')

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $pbegdte        s              8  0
     D $pbegdted       s               d
     D $pbegtim        s              6  0
     D $penddte        s              8  0
     D $penddted       s               d
     D $pendtim        s              6  0

     D error           s               n
     D lastdate        s              8  0

     D substmt1        s            500a   inz(' ')
     D substmt2        s            500a   inz(' ')
     D sqlstmt         s           1000a   inz(' ')

     D today           s               d

     *----------------------------------------------------------------
     *  Data conversion data structure
     *----------------------------------------------------------------

     D dateconv        ds

     D  dateyyyymmdd           1      8  0 inz(0)
     D  dateyyyy               1      4  0 inz(0)
     D  datemm                 5      6  0 inz(0)
     D  datedd                 7      8  0 inz(0)

     D  charyy                 3      4
     D  charmm                 5      6
     D  chardd                 7      8

417bA*----------------------------------------------------------------
417bA*  *DLYHIT  -  Daily Slot Hit options
417bA*----------------------------------------------------------------
417bA*
417bA* Fields
417bA*
417bA*    OPHSTR  -  Slot Hit day start time
417bA*    OPHWKS  -  # of weeks history to keep
417bA*
417bA* Data structure
417bA*
417bAD opdat2          ds
417bAD  ophstr                 1      6  0
417bAD  ophwks                 7      8  0
417bAD  opten2               117    117

417bA*----------------------------------------------------------------
417bA*  Program information data structure.
417bA*----------------------------------------------------------------
417bA
417bA /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pstartdte  -  Start date (yyyymmdd)
     *      $pfromtime  -  From time (hhmmss)
     *      $ptotime    -  To time (hhmmss)
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pstartdte        8
     C                   parm                    $pfromtime        6
     C                   parm                    $ptotime          6

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     * Establish the connection to the remote machine. The -842 return
     * code indicates that the connection is already established. If
     * you want to connect to the local machine, use CONNECT RESET.

     C/EXEC SQL
     C+ CONNECT RESET
     C/END-EXEC

     *  Move starting date into beginning date for selection.

     C                   select

     C                   when      $pstartdte = ' '
     C                   exsr      getmaxdate
     C     error         cabeq     *on           bottom
     C                   eval      $pbegdted = %date(lastdate:*ISO)
     C                   eval      $pbegdted = $pbegdted + %days(1)
     C                   extrct    $pbegdted:*m  datemm
     C                   extrct    $pbegdted:*d  datedd
     C                   extrct    $pbegdted:*y  dateyyyy
     C                   eval      $pbegdte = dateyyyymmdd

     C                   other
     C                   move      $pstartdte    $pbegdte
     C                   eval      $pbegdted = %date($pbegdte:*ISO)

     C                   endsl
417bA
417bA*  Get start/end times for selection.
417bA

417bAC                   if        $pfromtime = ' '
417bAC                   exsr      gettime
417bAC                   else
     C                   move      $pfromtime    $pbegtim
     C                   move      $ptotime      $pendtim
417bAC                   endif

     *  Loop until we hit today's date.

     C                   time                    today
     C                   dou       $pbegdted >= today

     C                   eval      $penddted = $pbegdted + %days(1)
     C                   extrct    $penddted:*m  datemm
     C                   extrct    $penddted:*d  datedd
     C                   extrct    $penddted:*y  dateyyyy
     C                   eval      $penddte = dateyyyymmdd

     C                   exsr      sqlbldstmt
     C                   exsr      runsqlstmt

     C                   eval      $pbegdte  = $penddte
     C                   eval      $pbegdted = $penddted

     C                   enddo

417aA*  Update base slots and items.
417aA
417aAC                   exsr      updatebase

     C     bottom        tag

     *  Disconnect the current connection.

     C/EXEC SQL
     C+   DISCONNECT CURRENT
     C/END-EXEC
     *
     C                   Eval      *inlr = *on

     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
650 A*
650 A* Get client id.
650 A*
650 AC                   call      @getcl
650 AC                   parm                    client           10
650 AC                   parm                    clientloc        10

417bA*  Define key for options file.
417bA
417bAC     optnky        klist
417bAC                   kfld                    #whse
417bAC                   kfld                    opcode

     C                   endsr

417bA*----------------------------------------------------------------
417bA*  gettime  -  Get start/end time from option file.
417bA*----------------------------------------------------------------
417bA
417bAC     gettime       begsr

     *  Get default warehouse for user.

     C                   call      'GETWHSE'
     C                   parm                    #user            10
     C                   parm      0             #whse             3 0

     *  Get beginning time from Slot Hit options.

     C                   eval      opcode = '*DLYHIT '
     C     optnky        chain     options
     C                   if        not %found
     C                   eval      $pbegtim = 50000
     C                   else
     C                   eval      opdat2 = opdata
     C                   eval      $pbegtim = ophstr
     C                   endif

     *  Calculate end time

     C                   eval      $pendtim = $pbegtim

     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      SQL Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sqlbldstmt - Build SQL statment
     *----------------------------------------------------------------

     C     sqlbldstmt    BegSr

     *   Create sub-select to extract transaction records for the night.

EI  AC                   select
EI  AC                   when      client = EI
EI  AC                   eval      substmt1 =
EI  AC                             'select pttrn# from pirtran +
EI  AC                              where ((ptgdte=' + %char($pbegdte) +
EI  AC                              ' and ptgtim>=' + %char($pbegtim) + ')'+
EI  AC                              ' or (ptgdte=' + %char($penddte) +
EI  AC                              ' and ptgtim<' + %char($pendtim) +'))'+
EI  AC                              ' and (pttask=''FIXED'' +
EI  AC                               or pttask=''PIR'')'
EI  AC
EI  AC                   other
     C
     C                   eval      substmt1 =
     C                             'select pttrn# from pirtran +
     C                              where ((ptgdte=' + %char($pbegdte) +
     C                              ' and ptgtim>=' + %char($pbegtim) + ')'+
     C                              ' or (ptgdte=' + %char($penddte) +
     C                              ' and ptgtim<' + %char($pendtim) +'))'+
     C                              ' and (pttask=''FIXED'' +
     C                               or pttask=''PIR'')' +
     C                              ' and ptgrp2<>''W'''
EI  AC                   endsl

     *   Create sub-select to summarize label recs by transaction/slot/item

     *     Essentially, we are joining the sub-selection above (the
     *     selection tran records for the night) with the label file,
     *     and then summarizing by transaction/slot/item.

     *     Each resulting record is considered a "hit".

     C                   eval      substmt2 =
     C                             'select pttrn#,lbwhse,lbwhdp,lbdisp,+
     C                              lbitem,sum(lbqpck) as qty +
     C                              from (' + %trimr(substmt1) + ') as A,+
     C                              label +
     C                              where lbtrn#=pttrn# and lbtype=''O'' +
417c C                              and lbvrfy<>''U'' +
     C                              group by pttrn#,lbwhse,lbwhdp,lbdisp,+
     C                              lbitem'

     * Create main sql statement

     *   Start with the 'insert' line.

     C                   eval      sqlstmt =
     C                             'insert into dlyhits (htwhse,htwhdp,+
     C                              htdisp,htbaseslt,htitem,htbaseitm,+
     C                              htbegdte,htbegtim,htenddte,htendtim,+
     C                              htweek,htdow,hthits,htqty,htmin,htmax,+
417aMC                              htavg,htmedian,htvar,htstdev,htstamp)'

     *   Add the main select statement

     *     Fields of main select (must match insert fields).

     C                   eval      sqlstmt = %trimr(sqlstmt) + ' ' +
     C                             'select b.lbwhse,b.lbwhdp,b.lbdisp,+
     C                              '' '',b.lbitem,'' '','+
     C                              %char($pbegdte) + ','+
     C                              %char($pbegtim) + ','+
     C                              %char($penddte) + ','+
     C                              %char($pendtim)

     C                   eval      sqlstmt = %trimr(sqlstmt) + ',' +
     C                              'week(''' + %char($pbegdted) + ''')'+
     C                              ',dayofweek(''' + %char($pbegdted) +
     C                              ''')'

     C                   eval      sqlstmt = %trimr(sqlstmt) + ',' +
     C                              'count(*),sum(b.qty),min(b.qty),+
     C                              max(b.qty),avg(decimal(b.qty,7,2)),+
417aAC                              0,var(decimal(b.qty,7,2)),+
     C                              stddev(b.qty),now()'

     *     The From portion is sub-selection #2 above, which are the
     *     hits for the night.

     C                   eval      sqlstmt = %trimr(sqlstmt) + ' ' +
     C                             'from (' + %trimr(substmt2) + ') as B'

     *     The Group portion summarizes the hits by slot/item.

     C                   eval      sqlstmt = %trimr(sqlstmt) + ' ' +
     C                             'group by b.lbwhse,b.lbwhdp,b.lbdisp,+
     C                              b.lbitem'

     C                   EndSr

     *----------------------------------------------------------------
     *  runsqlstmt  -  Execute SQL statement.
     *----------------------------------------------------------------

     C     runsqlstmt    begsr

     C/EXEC SQL
     C+   execute immediate :sqlstmt
     C/END-EXEC

     C                   if        sqlstt <> '00000'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getmaxdate  -  Get maximum date in the file.
     *----------------------------------------------------------------

     C     getmaxdate    begsr
     C                   eval      error = *off

     C                   eval      sqlstmt = 'select max(htbegdte) +
     C                                       from dlyhits'

     C/EXEC SQL
     C+   PREPARE sel FROM :sqlstmt
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     C/EXEC SQL
     C+ DECLARE MYCSR SCROLL CURSOR FOR SEL
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     C/EXEC SQL
     C+ OPEN MYCSR
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
     C+      INTO :lastdate
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   eval      error = *on
     C                   endif

     C/EXEC SQL
     C+   CLOSE mycsr
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   endsr

417aA*----------------------------------------------------------------
417aA*  updatebase  -  Update base slot and item.
417aA*----------------------------------------------------------------
417aA
417aAC     updatebase    begsr
     C                   eval      error = *off

     *  Update base slot.

     C/EXEC SQL
     C+   UPDATE dlyhits
     C+   SET htbaseslt = coalesce((select distinct vspdis from
     C+   vslot where vsdisp=htdisp),htdisp)
     C+   where htdisp<>' ' and htbaseslt=' '
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Update base item.

     C/EXEC SQL
     C+   UPDATE dlyhits
     C+   SET htbaseitm = coalesce((select distinct ilitm2 from
750 DC*   itemlnk where ilitem=htitem),htitem)
750 MC+   itemlnk where ilitem=htitem fetch first row only),htitem)
     C+   where htitem<>' ' and htbaseitm=' '
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   endsr
