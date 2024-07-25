     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2004')
     H Option(*NODEBUGIO)

      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
      *
      *
      * COMPILING. In order to ctlqtye this program you will need
      *            to use options which allow it to work correctly
      *            between machines. These options are---
      *
      *               COMMIT = *NONE
      *               DLYPRP = *YES
      *****************************************************************
     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Associates, Inc.
     *   Batavia, IL
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RH355     Print Daily Route Weight Report
     *  23 February, 2013
     *  Ginger Andrews
     *
     *      - Created 6.50
     *
     *  Revisions
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fwarehs    if   e           k disk
     Flabel90   if   e           k disk
     Fpltsum12  if   e           k disk
     FRH355PR   o    e             printer oflind(*IN90)

     *----------------------------------------------------------------
     *  Table and array
     *----------------------------------------------------------------
     D tme             s             22    dim(1) ctdata perrcd(1)
     D a22             s              1    dim(22)
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')
     D forever         s               n   inz('1')

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     Drhrec          e ds                  extname(rtehed)
     D begofmonth6     s              6  0 inz(0)
     D btim            s              6  0 inz(0)
     D chkpre          s              3    inz(' ')
     D etim            s              6  0 inz(0)
     D endofmonth6     s              6  0 inz(0)
     D frmdte          s              8  0 inz(0)
     D groupby         S             50a   inz(' ')
     D groupfields     S             50a   inz(' ')
     D hld_rhrte       s                   like(rhrte)
     D innerjoin       S            200a   inz(' ')
     D leftjoin1       S            200a   inz(' ')
     D leftjoin2       S            200a   inz(' ')
     D order1          s             10a   inz(' ')
     D order2          s             10a   inz(' ')
     D orderby         S             50a   inz(' ')
     D orderfieldS     s             50a   inz(' ')
     D selectfields    s            500a   inz(' ')
     D sqlStmt         s           1000a   inz(' ')
     D tlqty1          s              7  0 inz(0)
     D tlqty2          s              7  2 inz(0)
     D tlqty3          s              7  2 inz(0)
     D todte           s              8  0 inz(0)
     D $whse           s              3  0 inz(0)
     D whereclause     S            500a   inz(' ')
     D where1          s             10a   inz(' ')

     *----------------------------------------------------------------
     *  Time redefinition data structure
     *
     D $pbtim          ds
     D  $pbhrs                 1      2
     D  $pbmin                 3      4
     D  $pbsec                 5      6
     D $petim          ds
     D  $pehrs                 1      2
     D  $pemin                 3      4
     D  $pesec                 5      6
     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

     D @cvtdt          c                   CONST('CVTDTE')
     D @cvtqt          c                   CONST('CVTQTY')

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
     *      $pfmdt - From date range
     *      $ptodt - To date range
     *      $pwhse - Warehouse
     *      $pbtim - From time
     *      $petim - To time
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pfmdt            8
     C                   parm                    $ptodt            8
     C                   parm                    $pwhs             3
     C                   parm                    $pbtim            6
     C                   parm                    $petim            6
     *
     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *
     * Establish the connection to the remote machine. The -842 return
     * code indicates that the connection is already established. If
     * you want to connect to the local machine, use CONNECT RESET.
     *
     C/EXEC SQL
     C+ CONNECT RESET
     C/END-EXEC

     *  Print detail report.

     C                   exsr      report1
     C                   write     total1                               90
     C                   write     Foot1                                90
     *
     *  Disconnect the current connection.
     *
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

     *
     *  Key field for PLTSUM12
     *
     C     keyplts       klist
     C                   kfld                    rhwhse
     C                   kfld                    rhrtid
     *
     *  Key field for LABEL90
     *
     C     keyl90        klist
     C                   kfld                    pswhse
     C                   kfld                    pstrn#

     *  Get warehouse name for report.

     C                   move      $pwhs         $whse
     C     $whse         chain     warehs                             79
     C                   if        not %found
     C                   eval      whdesc = *blanks
     C                   endif
     C*                  eval      wowhse = %editc($whse:'Z') + ' - ' +
     C*                            whdesc

     *  Get current date in MMDDYY format.

     C*                  eval      $cvcmd = '*CURMDY '
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  move      $cvd6o        Rptdate
     C*                  time                    Rpttim

     *  Convert starting and ending dates to MMDDYY.

     C                   move      $pfmdt        $cvd8i
     C                   eval      $cvcmd = '*CMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      begofmonth6 = $cvd6o

     C                   move      $ptodt        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      endofmonth6 = $cvd6o

     *  Build date range string for report heading.

     C                   eval      dterng = %editc(begofmonth6:'Y') +
     C                             ' to ' + %editc(endofmonth6:'Y')
     *
     *  Format TIME range
     *
     C                   eval      a22 = *blanks
     C                   movea     tme(1)        a22
     C                   movea     $pbhrs        a22(1)
     C                   movea     $pbmin        a22(4)
     C                   movea     $pbsec        a22(7)
     C                   movea     $pehrs        a22(15)
     C                   movea     $pemin        a22(18)
     C                   movea     $pesec        a22(21)
     C                   movea     a22           tmerng
     *
     C                   eval      $cvprg = 'RH355'
     *
     *  Initalize date and time
     C                   move      $pfmdt        frmdte
     C                   move      $ptodt        todte
     C                   move      $pbtim        btim
     C                   move      $petim        etim
     *
     *  Force overflow on.
     C                   eval      *in90  = *on
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      SQL Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sqlbldstmt1 - Build SQL statment
     *----------------------------------------------------------------

     C     sqlbldstmt1   BegSr

     * Create list of select fields.

     C                   eval      SelectFields = 'RHWHSE,RHRTID,RHRTE,RHTRUK, +
     C                             RHSTAT,RHPRTD,RHPRTT,RHEXPD,RHEXPT'

     * Create "left outer join" clause


     * Create "where" clause.

     C                   Eval      WhereClause = 'WHERE RHWHSE = ' + $pwhs
     C                                           + ' AND RHPRTD >= '
     C                                           + %trim($pfmdt)
     C                                           + ' AND RHPRTD <= '
     C                                           + %trim($ptodt)
     C                                           + ' AND RHTYPE <> '
     C                                           + %trim(where1)


     * Create "Order By" clauses.

     C                   eval      OrderFields = %trim(ORDER1) + ', '
     C                                         + %trim(ORDER2)

     C                   eval      OrderBy = 'ORDER BY '
     C                                      + %trim(OrderFields)

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(SelectFields) + ' '
     C                                     + 'FROM RTEHED '
     C                                     + %trimr(WhereClause) + ' '
     C                                     + OrderBy

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlprep - Prepare SQL cursor
     *
     *    Note: This routine must come before any other routine
     *          using an SQL statement because it declares the
     *          SQL Cursor being used.
     *----------------------------------------------------------------

     C     sqlprep       BegSr

      * Prepare the SQL statement for validation, since the program was
      * compiled with DLYPRP (*YES), it will wait until it is used before
      * it prepares the cursor.

     C/EXEC SQL
     C+   PREPARE sel FROM :SqlStmt
     C/END-EXEC
      *
      * Declare the SQL cursor to hold the data retrieved from the SELECT
      *
     C/EXEC SQL
     C+ DECLARE MYCSR SCROLL CURSOR FOR SEL
     C/END-EXEC
      *
      * Open the SQL cursor.
      *
     C
     C/EXEC SQL
     C+ OPEN MYCSR
     C/END-EXEC
      *
     C                   EndSr

     *----------------------------------------------------------------
     *  sqlclean - Clean up before exiting
     *----------------------------------------------------------------

     C     sqlclean      BegSr
      *
      *  Close the SQL cursor after all processing is complete.
      *
     C/EXEC SQL
     C+   CLOSE mycsr
     C/END-EXEC
      *
     C                   Endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                    Report Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  rptbld1 - Build the report
     *----------------------------------------------------------------

     C     rptbld1       BegSr

     C                   move      *loval        hld_rhrte

     * Process the records in the SQL cursor until the return not = 0

     C                   Dow       forever = forever

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
     C+      INTO :rhwhse, :rhrtid, :rhrte, :rhtruk, :rhstat, :rhprtd, :rhprtt,
     C+      :rhexpd, :rhexpt
     C/END-EXEC

     C                   select
     C                   when      sqlstt = '00000'

     C                   movel     rhtruk        chkpre
     C                   select

     C                   when      chkpre = 'PRE'
     C                   iter

     C                   when      rhprtd = frmdte and
     C                             rhprtt < btim
     C                   iter

     C                   when      rhprtd = todte  and
     C                             rhprtt > etim
     C                   iter

     C                   when      rhstat = '8'    or
     C                             rhstat = '9'
     C                   iter

     C                   Endsl

     C                   select
     *  Page overflow - Print headings.
     C                   when      *in90 = *on
     C                   exsr      rpthead1
     C                   endsl
     *
     *  Rtn code changed and not just page overflow.
     C                   select
     C                   when      rhrte <> hld_rhrte and
     C                             hld_rhrte <> *loval
     *
     C                   write     total1                               90
     C*                  exsr      rptdetail1
     *
     *  Clear total fields.
     C                   eval      tlqty1 = 0
     C                   eval      tlqty2 = 0
     C                   eval      tlqty3 = 0
     C                   eval      tlwgt  = 0
     *
     *
     C                   endsl
     *
     C                   exsr      rptfill1
     C                   eval      hld_rhrte = rhrte

     *
     *  Page overflow - Print headings.
     C                   select
     C                   when      *in90 = *on
     C                   exsr      rpthead1
     C                   endsl
     *
     *
     C                   other
     C                   Leave
     C                   Endsl

     C                   EndDo

     C                   EndSr

     *----------------------------------------------------------------
     *  Rpthead1 - Print Report headings
     *----------------------------------------------------------------

     C     Rpthead1      BegSr

     C                   write     Head1                                90
     C                   write     Head2                                90
     C                   write     columns                              90

     C                   endsr

     *----------------------------------------------------------------
     *  rptdetail1 -  Print the report - For All Crews
     *----------------------------------------------------------------

     C     rptdetail1    BegSr
     C                   if        *in90 = *on
     C                   exsr      rpthead1
     C                   endif
     C*
     C                   eval      wkwgt = tlqty2
     C                   eval      tlwgt = tlwgt + wkwgt
     C                   write     detail1                              90

     C                   eval      tlqty1 = 0
     C                   eval      tlqty2 = 0
     C                   eval      tlqty3 = 0
     C                   endsr

     *----------------------------------------------------------------
     *  rptfill1 -  Fill detail print fields.
     *----------------------------------------------------------------

     C     rptfill1      BegSr
     *
     C     keyplts       setll     pltsum12

     C                   Dow       forever = forever
     C                   read      pltsum12
     C                   select
     C                   when      %eof(pltsum12)
     C                   leave
     C                   when      psrtid <> rhrtid
     C                   leave
     C                   when      pstrn# = 0
     C                   iter
     C                   other

     C                   eval      wkplt = psunld
     C     keyl90        setll     label90
     C                   Dow       forever = forever
     C                   read      label90
     C                   if        %eof(label90) or
     C                             pstrn# <> lbtrn#
     C                   leave
     C                   else
     *  Accumulate total pieces returned for return code.
     C                   eval      tlqty1 = tlqty1 + lbqpck
     C                   eval(h)   tlqty2 = tlqty2 + lbswgt
     C                   eval(h)   tlqty3 = tlqty3 + lbcube
     C                   endif

     C                   enddo

     C                   endsl

     C                   if        tlqty2 <> *zeros
     C                   exsr      rptdetail1
     C                   endif

     C                   enddo

     *
     C                   endsr

     *----------------------------------------------------------------
     *  Report1 - Process report 1
     *----------------------------------------------------------------

     C     Report1       BegSr


     *  Initialize report fields.

     C                   Eval      order1   = 'RHWHSE'
     C                   Eval      order2   = 'RHRTE'

     *  Exclude route type 'W' for will call

     C                   Eval      where1   = '''W'''

     *  Do initial build and display of subfile.

     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      rptbld1

     C                   ExSr      sqlclean
     C                   endsr


     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     Misc. Subroutines
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  ZZCVTDT  Convert date to selected format.
     *
     C     zzcvtdt       begsr
     *
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCVTST  Convert qty's to string.
     *
     C     zzcvtst       begsr
     *
     C                   call      @cvtqt
     C                   parm                    $pcmd             8
     C                   parm                    $pprg             1 0
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn             8
     C                   parm                    $perm            60
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      TME   TIME headings
99:99:99 thru 99:99:99
