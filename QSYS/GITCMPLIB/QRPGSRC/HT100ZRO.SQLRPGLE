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
     *  HT100ZRO  Populate DLYZROR file.
     *  19 August 2004
     *  Dave Sommerville
     *
     *  Revisions
     *
417 A*    08/19/04  DAS  4.17
     *      - Created.
     *
417bA*    08/23/04  DAS  4.17b
     *      - Added selection to include REPLTF
     *
640aA*    09/22/11  DAS  6.40a
     *      - Revised to populate dept/slot with pick slot instead
     *        of overflow slot. We want to know how many times the
     *        Pick slot was replenshed.
     *
     *----------------------------------------------------------------

417bA*----------------------------------------------------------------
417bA*  Notes
     *
     *  This program will only select replenishments with LBQPCK <= 0.
     *
417bA*----------------------------------------------------------------

417bA*----------------------------------------------------------------
417bA*  File Specs
417bA*----------------------------------------------------------------
417bAFoptions   if   e           k disk

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

     C                   eval      substmt1 =
     C                             'select pttrn# from pirtran +
     C                              where ((ptgdte=' + %char($pbegdte) +
     C                              ' and ptgtim>=' + %char($pbegtim) + ')'+
     C                              ' or (ptgdte=' + %char($penddte) +
     C                              ' and ptgtim<' + %char($pendtim) +'))'+
     C                              ' and (pttask=''REPL''' +
417bAC                              ' or pttask=''REPLTF''' +
     C                              ' or pttask=''REPLBK'')'

     * Create main sql statement

     *   Start with the 'insert' line.

     C                   eval      sqlstmt =
     C                             'insert into dlyzror (hzwhse,hzwhdp,+
     C                              hzdisp,hzbaseslt,hzitem,hzbaseitm,+
     C                              hzbegdte,hzbegtim,hzenddte,hzendtim,+
     C                              hzweek,hzdow,hzhits,hzqty,hzmin,hzmax,+
417aMC                              hzavg,hzmedian,hzvar,hzstdev,hzstamp)'

     *   Add the main select statement

     *     Fields of main select (must match insert fields).

     C                   eval      sqlstmt = %trimr(sqlstmt) + ' ' +
     C**                           'select lbwhse,lbwhdp,lbdisp,+
     C                             'select lbwhse,lbwhd2,lbdsp2,+
     C                              '' '',lbitem,'' '','+
     C                              %char($pbegdte) + ','+
     C                              %char($pbegtim) + ','+
     C                              %char($penddte) + ','+
     C                              %char($pendtim)

     C                   eval      sqlstmt = %trimr(sqlstmt) + ',' +
     C                              'week(''' + %char($pbegdted) + ''')'+
     C                              ',dayofweek(''' + %char($pbegdted) +
     C                              ''')'

     C                   eval      sqlstmt = %trimr(sqlstmt) + ',' +
     C                              'count(*),sum(lbqpck),min(lbqpck),+
     C                              max(lbqpck),avg(decimal(lbqpck,7,2)),+
417aAC                              0,var(decimal(lbqpck,7,2)),+
     C                              stddev(lbqpck),now()'

     *     The From portion is sub-selection #1 above, which are the
     *     replenishment hits for the night.

     C                   eval      sqlstmt = %trimr(sqlstmt) + ' ' +
     C                             'from (' + %trimr(substmt1) + ') as A,+
     C                              label +
     C                              where lbtrn#=pttrn# and lbqpck<=0'

     *     The Group portion summarizes the hits by slot/item.

     C                   eval      sqlstmt = %trimr(sqlstmt) + ' ' +
     C**                           'group by lbwhse,lbwhdp,lbdisp,lbitem'
     C                             'group by lbwhse,lbwhd2,lbdsp2,lbitem'

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

     C                   eval      sqlstmt = 'select max(hzbegdte) +
     C                                       from dlyzror'

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
     C+   UPDATE dlyzror
     C+   SET hzbaseslt = coalesce((select distinct vspdis from
     C+   vslot where vsdisp=hzdisp),hzdisp)
     C+   where hzdisp<>' ' and hzbaseslt=' '
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Update base item.

     C/EXEC SQL
     C+   UPDATE dlyzror
     C+   SET hzbaseitm = coalesce((select distinct ilitm2 from
     C+   itemlnk where ilitem=hzitem),hzitem)
     C+   where hzitem<>' ' and hzbaseitm=' '
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   endsr
