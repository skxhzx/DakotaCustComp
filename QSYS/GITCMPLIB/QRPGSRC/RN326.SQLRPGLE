     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2005')
     H Option(*NODEBUGIO)

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
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RN326     Print Customer Returns Anaylsis Summary
     *  02 November 2005
     *  Bob Perry
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    11/02/05  RLP  5.00
     *      - Created from RN325.
500aA*    02/01/06  MLB  5.00a
     *      - Fix: Revised program to change Where clause to
     *        include quotes around return code.
     *      - Fix: Revised program to initialize file numeric
     *        fields used in program.
510aA*    10/13/06  RAH  5.10a
     *      - Fix: Correct program to report all selectors.
510bA*    03/07/07  RH   5.10b
     *      - Fix: Print *NONE if employee name is blank.
510cA*    03/21/07  RBD  5.10c
     *      - Fix: Print employee# even if user record doesn't exist.
510dA*    03/23/07  RBD  5.10d
     *      - Added code to print grand total count and pieces.
520aA*    04/14/09  RH   5.20a
     *      - Fix: Remove SLOT3 left outer join, was selecting all
     *        pick slots for returned item, not just one.
530a *    06/21/10  GJA  5.30a
     *      - Fix: Decimal data error if no records found.
     *
650 A*    06/09/14  MLB  6.50
     *      - Fix: Increased size of LRRTNR in RN326PR to correct
     *        RNQ0103 - Receiver variable too small to hold result
     *        error.  No pgm changes, prtf changes only and recompile.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
     *
     *----------------------------------------------------------------
     *  Notes:
     *    - Routine RPTFILL1 has code commented out for the extraction
     *      of ship date from field OHMISC from ORDH.  Activate this
     *      code to include ship date on the report. Revise starting
     *      position of %subst to match clients' data.
     *      Revise Code marked with 'ENH1'.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fwarehs    if   e           k disk
     FRN326PR   o    e             printer oflind(*IN90)

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')
     D forever         s               n   inz('1')
     D Quote           C                   Const('''')

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     Dorrec          e ds                  extname(orrtn)
     Dlbrec          e ds                  extname(label)
     Drnrec          e ds                  extname(rtncode)
     Dptrec          e ds                  extname(pirtran)
     Dusrec          e ds                  extname(piruser)
     Ditrec          e ds                  extname(piritem)
     Dohrec          e ds                  extname(ordh)
     D #rtnqty         s              8b 0 inz(0)
     D $code           s              2    inz(' ')
     D $count          s              8b 0 inz(0)
     D $date           s              8  0 inz(0)
     D $emp#           s              5  0 inz(0)
     D $emp#ind        s              2b 0 inz(0)
     D $empfnam        s             15    inz(' ')
     D $empfnamind     s              2b 0 inz(0)
     D $emplnam        s             20    inz(' ')
     D $emplnamind     s              2b 0 inz(0)
     D $empname        s             37    inz(' ')
     D $idesc          s             30    inz(' ')
     D $item           s             15    inz(' ')
     D begofmonth6     s              6  0 inz(0)
     D brklvl1         s              1    inz(*OFF)
     D brklvl2         s              1    inz(*OFF)
     D brklvl3         s              1    inz(*OFF)
     D desc01          s             30    inz(' ')
     D desc02          s             30    inz(' ')
     D desc01ind       s              2b 0 inz(0)
     D desc02ind       s              2b 0 inz(0)
     D empnam          s             20    inz(' ')
     D endofmonth6     s              6  0 inz(0)
     D first           s              1    inz(*ON)
     D groupby         S             50a   inz(' ')
     D groupfields     S             50a   inz(' ')
     D hld_emp#        s                   like(ptemp#)
     D hld_name        s             20a   inz(*blanks)
     D hld_orrcod      s                   like(orrcod)
     D hld_orrdte      s                   like(orrdte)
     D hld_rndesc      s                   like(rndesc)
     D hld_rtndte      s              6  0 inz(0)
     D innerjoin       S            200a   inz(' ')
     D leftjoin        S            200a   inz(' ')
     D leftjoin2       S            200a   inz(' ')
     D leftjoin3       S            200a   inz(' ')
     D leftjoin4       S            200a   inz(' ')
     D leftjoin5       S            200a   inz(' ')
     D leftjoin6       S            200a   inz(' ')
     D leftjoin7       S            200a   inz(' ')
     D leftjoin8       S            200a   inz(' ')
     D order1          s             10a   inz(' ')
     D order2          s             10a   inz(' ')
     D order3          s             10a   inz(' ')
     D order4          s             10a   inz(' ')
     D order5          s             10a   inz(' ')
     D orderby         S             50a   inz(' ')
     D orderfieldS     s             50a   inz(' ')
     D ohmiscind       s              2b 0 inz(0)
     D ohcustind       s              2b 0 inz(0)
     D ohcnamind       s              2b 0 inz(0)
     D pcnt            s              7b 0 inz(0)
     D ptcrewind       s              2b 0 inz(0)
     D ptemp#ind       s              2b 0 inz(0)
     D ptshftind       s              2b 0 inz(0)
     D rcnt            s              4b 0 inz(0)
     D rndescind       s              2b 0 inz(0)
     D rtndte          s              6  0 inz(0)
     D scpad           s              3  0 inz(0)
     D selectfields    s            500a   inz(' ')
     D shpdat          s              6a   inz(' ')
     D slot01          s             12a   inz(' ')
     D slot01ind       s              2b 0 inz(0)
     D slot02          s             12a   inz(' ')
     D slot02ind       s              2b 0 inz(0)
     D sortorder1      s             10a   inz(' ')
     D sortorder2      s             10a   inz(' ')
     D sortorder3      s             10a   inz(' ')
     D sqlStmt         s           1000a   inz(' ')
     D tlqty1          s              7  0 inz(0)
     D tlqty2          s              7  0 inz(0)
     D tlqty3          s              7  0 inz(0)
     D usemp#ind       s              2b 0 inz(0)
     D usfnamind       s              2b 0 inz(0)
     D usinitind       s              2b 0 inz(0)
     D uslnamind       s              2b 0 inz(0)
     D $whse           s              3  0 inz(0)
     D whereclause     S            500a   inz(' ')

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
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $pfmdt            8
     C                   parm                    $ptodt            8
     C                   parm                    $pcrew            6
     C                   parm                    $pemp#            5
     C                   parm                    $pdetl            1
     C                   parm                    $prcod            4
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

     C                   select

     *  Print detail report for all Crews.

     C                   when      $pcrew = '*ALL '
     C                   exsr      report1

     *  Print detail report for specific Crew.

     C                   when      $pcrew <> '*ALL ' and $pcrew > *blanks
     C                   exsr      report2

     *  Print detail report for Single Employee.

     C                   when      $pemp# > '00000'
     C                   exsr      report3

     C                   endsl
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

     *  Get warehouse name for report.

     C                   move      $pwhs         $whse
     C     $whse         chain     warehs                             79
     C                   if        not %found
     C                   eval      whdesc = *blanks
     C                   endif
     C                   eval      wowhse = %editc($whse:'Z') + ' - ' +
     C                             whdesc
     *
     *  Center report title.
     *
     C                   call      'CENTER'
     C                   parm      wowhse        $str             60
     C                   parm      60            $plen             3 0
     C                   eval      wowhse = $str

     *  Get current date in MMDDYY format.

     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd6o        Rptdate
     C                   time                    Rpttim

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

     C                   eval      $cvprg = 'RN325'
500aA*  Initialize file numeric fields.
530aAC                   eval      ptemp# = 0
500aAC                   eval      usemp# = 0
500aAC                   eval      ohcust = 0
500aAC                   eval      ohord  = 0
500aA*
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

     C                   eval      SelectFields = 'ORWHSE,ORORD,ORITEM,ORQTY1, +
     C                             ORQTY2,ORQTY3,ORRDTE,ORRTIM,ORRUSR,ORTRN#, +
     C                             ORCITM,ORRCOD,ORRMEM,ORSLOT,RNDESC, +
     C                             B1.ITDESC,B2.ITDESC,PTSHFT,PTCREW,PTEMP#, +
520aMC                             C1.LBDISP,USFNAM,USINIT,USLNAM, +
520aDC*                            C1.LBDISP,D1.SLDISP,USFNAM,USINIT,USLNAM, +
     C                             OHMISC,OHCUST,OHCNAM,USEMP#'

     * Create "left outer join" clause

     C                   eval      LeftJoin = 'LEFT OUTER JOIN RTNCODE '
     C                                      + 'ON RNCODE = ORRCOD'

     C                   eval      LeftJoin2 = 'LEFT OUTER JOIN PIRITEM B1 '
     C                                      + 'ON B1.ITWHSE = ORWHSE '
     C                                      + 'AND B1.ITITEM = ORITEM'

     C                   eval      LeftJoin3 = 'LEFT OUTER JOIN PIRITEM B2 '
     C                                       + 'ON B2.ITWHSE = ORWHSE '
     C                                       + 'AND B2.ITITEM = ORCITM'

     C                   eval      LeftJoin4 = 'LEFT OUTER JOIN PIRTRAN '
     C                                      + 'ON PTTRN# = ORTRN#'

     C                   eval      LeftJoin5 = 'LEFT OUTER JOIN LABEL  C1 '
     C                                      + 'ON C1.LBLBL# = OROLB# '

520aDC*                  eval      LeftJoin6 = 'LEFT OUTER JOIN SLOT3 D1 '
520aDC*                                     + 'ON D1.SLWHSE = ORWHSE AND '
520aDC*                                     + 'D1.SLITEM = ORCITM and '
520aDC*                                     + 'D1.SLSTAT = ''A '' and  '
520aDC*                                     + 'D1.SLPICK = ''Y'' '

     C                   eval      LeftJoin7 = 'LEFT OUTER JOIN PIRUSER '
510aAC                                       + 'ON usemp# = ptemp#'
510aDC*                                      + 'ON USCODE = ORRUSR'

     C                   eval      LeftJoin8 = 'LEFT OUTER JOIN ORDH    '
     C                                       + 'ON lbwhse = ohwhse and '
     C                                       + 'lbord     = ohord'


     * Create "where" clause.

     C                   select
     C                   when      $prcod = '*ALL'
     C                   Eval      WhereClause = 'WHERE ORWHSE = ' + $pwhs
     C                                           + ' AND ORRDTE >= '
     C                                           + %trim($pfmdt)
     C                                           + ' AND ORRDTE <= '
     C                                           + %trim($ptodt)

     C                   when      $prcod <> '*ALL'
     C                   Eval      WhereClause = 'WHERE ORWHSE = ' + $pwhs
     C                                           + ' AND ORRDTE >= '
     C                                           + %trim($pfmdt)
     C                                           + ' AND ORRDTE <= '
     C                                           + %trim($ptodt)
     C                                           + ' AND ORRCOD = '
500aAC                                           + quote
     C                                           + %trim($prcod)
500aAC                                           + quote
     C                   endsl

     * Create "Order By" clauses.

     C                   eval      OrderFields = %trim(order1) + ', '
     C                                         + %trim(order2) + ', '
     C                                         + %trim(order3) + ', '
     C                                         + %trim(order4)

     C                   eval      OrderBy = 'ORDER BY '
     C                                      + %trim(orderFields)

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(SelectFields) + ' '
     C                                     + 'FROM ORRTN '
     C                                     + %trimr(LeftJoin) + ' '
     C                                     + %trimr(LeftJoin2) + ' '
     C                                     + %trimr(LeftJoin3) + ' '
     C                                     + %trimr(LeftJoin4) + ' '
     C                                     + %trimr(LeftJoin5) + ' '
520aDC*                                    + %trimr(LeftJoin6) + ' '
     C                                     + %trimr(LeftJoin7) + ' '
     C                                     + %trimr(LeftJoin8) + ' '
     C                                     + %trimr(WhereClause) + ' '
     C                                     + OrderBy

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlbldstmt2 - Build SQL statment
     *----------------------------------------------------------------

     C     sqlbldstmt2   BegSr

     * Create list of select fields.

     C                   eval      SelectFields = 'ORWHSE,ORORD,ORITEM,ORQTY1, +
     C                             ORQTY2,ORQTY3,ORRDTE,ORRTIM,ORRUSR,ORTRN#, +
     C                             ORCITM,ORRCOD,ORRMEM,ORSLOT,RNDESC, +
     C                             B1.ITDESC,B2.ITDESC,PTSHFT,PTCREW,PTEMP#, +
520aMC                             C1.LBDISP,USFNAM,USINIT,USLNAM, +
520aDC*                            C1.LBDISP,D1.SLDISP,USFNAM,USINIT,USLNAM, +
     C                             OHMISC,OHCUST,OHCNAM,USEMP#'

     * Create "left outer join" clause

     C                   eval      LeftJoin = 'LEFT OUTER JOIN RTNCODE '
     C                                      + 'ON RNCODE = ORRCOD'

     C                   eval      LeftJoin2 = 'LEFT OUTER JOIN PIRITEM B1 '
     C                                      + 'ON B1.ITWHSE = ORWHSE '
     C                                      + 'AND B1.ITITEM = ORITEM'

     C                   eval      LeftJoin3 = 'LEFT OUTER JOIN PIRITEM B2 '
     C                                       + 'ON B2.ITWHSE = ORWHSE '
     C                                       + 'AND B2.ITITEM = ORCITM'

510aDC*                  eval      LeftJoin4 = 'LEFT OUTER JOIN PIRTRAN '
510aDC*                                     + 'ON PTTRN# = ORTRN#'

     C                   eval      LeftJoin5 = 'LEFT OUTER JOIN LABEL  C1 '
     C                                      + 'ON C1.LBLBL# = OROLB# '

520aDC*                  eval      LeftJoin6 = 'LEFT OUTER JOIN SLOT3 D1 '
520aDC*                                     + 'ON D1.SLWHSE = ORWHSE AND '
520aDC*                                     + 'D1.SLITEM = ORCITM and '
520aDC*                                     + 'D1.SLSTAT = ''A '' and  '
520aDC*                                     + 'D1.SLPICK = ''Y'' '

     C                   eval      LeftJoin7 = 'LEFT OUTER JOIN PIRUSER '
510aAC                                       + 'ON usemp# = ptemp#'
510aDC*                                      + 'ON USCODE = ORRUSR'

     C                   eval      LeftJoin8 = 'LEFT OUTER JOIN ORDH    '
     C                                       + 'ON lbwhse = ohwhse and '
     C                                       + 'lbord     = ohord'

     * Create "Inner join" clause.

     C                   eval      Innerjoin = 'INNER JOIN PIRTRAN '
     C                                       + 'ON PTTRN# = ORTRN#'


     * Create "where" clause.

     C                   select
     C                   when      $prcod = '*ALL'
     C                   Eval      WhereClause = 'WHERE ORWHSE = ' + $pwhs
     C                                           + ' AND ORRDTE >= '
     C                                           + %trim($pfmdt)
     C                                           + ' AND ORRDTE <= '
     C                                           + %trim($ptodt)
510aAC                                           + ' AND ptcrew = '
510aDC*                                          + ' AND USCREW = '
     C                                           + quote + $pcrew + quote

     C                   when      $prcod <> '*ALL'
     C                   Eval      WhereClause = 'WHERE ORWHSE = ' + $pwhs
     C                                           + ' AND ORRDTE >= '
     C                                           + %trim($pfmdt)
     C                                           + ' AND ORRDTE <= '
     C                                           + %trim($ptodt)
510aAC                                           + ' AND ptcrew = '
510aDC*                                          + ' AND USCREW = '
     C                                           + quote + $pcrew + quote
     C                                           + ' AND ORRCOD = '
500aAC                                           + quote
     C                                           + %trim($prcod)
500aAC                                           + quote
     C                   endsl

     * Create "Order By" clauses.

     C                   eval      OrderFields = %trim(order1) + ', '
     C                                         + %trim(order2) + ', '
     C                                         + %trim(order3) + ', '
     C                                         + %trim(order4)

     C                   eval      OrderBy = 'ORDER BY '
     C                                      + %trim(orderFields)

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(SelectFields) + ' '
     C                                     + 'FROM ORRTN '
     C                                     + %trimr(InnerJoin) + ' '
     C                                     + %trimr(LeftJoin)  + ' '
     C                                     + %trimr(LeftJoin2) + ' '
     C                                     + %trimr(LeftJoin3) + ' '
510aDC*                                    + %trimr(LeftJoin4) + ' '
     C                                     + %trimr(LeftJoin5) + ' '
520aDC*                                    + %trimr(LeftJoin6) + ' '
     C                                     + %trimr(LeftJoin7) + ' '
     C                                     + %trimr(LeftJoin8) + ' '
     C                                     + %trimr(WhereClause) + ' '
     C                                     + OrderBy

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlbldstmt3 - Build SQL statment
     *----------------------------------------------------------------

     C     sqlbldstmt3   BegSr

     * Create list of select fields.

     C                   eval      SelectFields = 'ORWHSE,ORORD,ORITEM,ORQTY1, +
     C                             ORQTY2,ORQTY3,ORRDTE,ORRTIM,ORRUSR,ORTRN#, +
     C                             ORCITM,ORRCOD,ORRMEM,ORSLOT,RNDESC, +
     C                             B1.ITDESC,B2.ITDESC,PTSHFT,PTCREW,PTEMP#, +
520aMC                             C1.LBDISP,USFNAM,USINIT,USLNAM, +
520aDC*                            C1.LBDISP,D1.SLDISP,USFNAM,USINIT,USLNAM, +
     C                             OHMISC,OHCUST,OHCNAM,USEMP#'

     * Create "left outer join" clause

     C                   eval      LeftJoin = 'LEFT OUTER JOIN RTNCODE '
     C                                      + 'ON RNCODE = ORRCOD'

     C                   eval      LeftJoin2 = 'LEFT OUTER JOIN PIRITEM B1 '
     C                                      + 'ON B1.ITWHSE = ORWHSE '
     C                                      + 'AND B1.ITITEM = ORITEM'

     C                   eval      LeftJoin3 = 'LEFT OUTER JOIN PIRITEM B2 '
     C                                       + 'ON B2.ITWHSE = ORWHSE '
     C                                       + 'AND B2.ITITEM = ORCITM'

510aDC*                  eval      LeftJoin4 = 'LEFT OUTER JOIN PIRTRAN '
510aDC*                                     + 'ON PTTRN# = ORTRN#'

     C                   eval      LeftJoin5 = 'LEFT OUTER JOIN LABEL  C1 '
     C                                      + 'ON C1.LBLBL# = OROLB# '

520aDC*                  eval      LeftJoin6 = 'LEFT OUTER JOIN SLOT3 D1 '
520aDC*                                     + 'ON D1.SLWHSE = ORWHSE AND '
520aDC*                                     + 'D1.SLITEM = ORCITM and '
520aDC*                                     + 'D1.SLSTAT = ''A '' and  '
520aDC*                                     + 'D1.SLPICK = ''Y'' '

     C                   eval      LeftJoin7 = 'LEFT OUTER JOIN PIRUSER '
510aAC                                       + 'ON usemp# = ptemp#'
510aDC*                                      + 'ON USCODE = ORRUSR'

     C                   eval      LeftJoin8 = 'LEFT OUTER JOIN ORDH    '
     C                                       + 'ON lbwhse = ohwhse and '
     C                                       + 'lbord     = ohord'

     * Create "Inner join" clause.

     C                   eval      Innerjoin = 'INNER JOIN PIRTRAN '
     C                                       + 'ON PTTRN# = ORTRN#'


     * Create "where" clause.

     C                   select
     C                   when      $prcod = '*ALL'
     C                   Eval      WhereClause = 'WHERE ORWHSE = ' + $pwhs
     C                                           + ' AND ORRDTE >= '
     C                                           + %trim($pfmdt)
     C                                           + ' AND ORRDTE <= '
     C                                           + %trim($ptodt)
510aAC                                           + ' AND ptemp# = '
510aDC*                                          + ' AND USEMP# = '
     C                                           + $pemp#

     C                   when      $prcod <> '*ALL'
     C                   Eval      WhereClause = 'WHERE ORWHSE = ' + $pwhs
     C                                           + ' AND ORRDTE >= '
     C                                           + %trim($pfmdt)
     C                                           + ' AND ORRDTE <= '
     C                                           + %trim($ptodt)
510aAC                                           + ' AND ptemp# = '
510aDC*                                          + ' AND USEMP# = '
     C                                           + $pemp#
     C                                           + ' AND ORRCOD = '
500aAC                                           + quote
     C                                           + %trim($prcod)
500aAC                                           + quote
     C                   endsl

     * Create "Order By" clauses.

     C                   eval      OrderFields = %trim(order1) + ', '
     C                                         + %trim(order2) + ', '
     C                                         + %trim(order3) + ', '
     C                                         + %trim(order4)

     C                   eval      OrderBy = 'ORDER BY '
     C                                      + %trim(orderFields)

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(SelectFields) + ' '
     C                                     + 'FROM ORRTN '
     C                                     + %trimr(InnerJoin) + ' '
     C                                     + %trimr(LeftJoin)  + ' '
     C                                     + %trimr(LeftJoin2) + ' '
     C                                     + %trimr(LeftJoin3) + ' '
510aDC*                                    + %trimr(LeftJoin4) + ' '
     C                                     + %trimr(LeftJoin5) + ' '
520aDC*                                    + %trimr(LeftJoin6) + ' '
     C                                     + %trimr(LeftJoin7) + ' '
     C                                     + %trimr(LeftJoin8) + ' '
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
     *  rptbld1 - Build the report - For All Crews
     *----------------------------------------------------------------

     C     rptbld1       BegSr

     C                   move      *loval        hld_orrcod
     C                   move      *loval        hld_orrdte
     C                   move      *loval        hld_emp#

     * Process the records in the SQL cursor until the return not = 0

     C                   Dow       forever = forever

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
     C+      INTO :orwhse, :orord, :oritem, :orqty1, :orqty2, :orqty3, :orrdte,
     C+      :orrtim, :orrusr, :ortrn#, :orcitm, :orrcod, :orrmem, :orslot,
     C+      :rndesc :rndescind, :desc01 :desc01ind, :desc02 :desc02ind,
     C+      :ptshft :ptshftind, :ptcrew :ptcrewind, :ptemp# :ptemp#ind,
     C+      :slot01 :slot01ind, :usfnam :usfnamind,
520aDC*      :slot01 :slot01ind, :slot02 :slot02ind, :usfnam :usfnamind,
     C+      :usinit :usinitind, :uslnam :uslnamind, :ohmisc :ohmiscind,
     C+      :ohcust :ohcustind, :ohcnam :ohcnamind, :usemp# :usemp#ind
     C/END-EXEC

     C                   select
     C                   when      sqlstt = '00000'

     C                   select
     *  Page overflow - Print headings.
     C                   when      *in90 = *on
     C                   exsr      rpthead1
     C                   If        orrcod = hld_orrcod
     C                   eval      hld_orrcod = *loval
     C                   Endif
     C                   endsl
     *
     *  Check for control breaks and print when true.
     *
     C                   select
     *
     *  Emp# changed - break level 1
510cDC*                  when      usemp# <> hld_emp# and
510cMC                   when      ptemp# <> hld_emp# and
     C                             hld_emp# <> *loval
     C                   eval      brklvl1 = *on
     C                   eval      brklvl2 = *on
     C                   eval      brklvl3 = *on
     C                   exsr      rptdetail1
     C                   eval      first = *on
     C                   write     skip1
     *
     *  When return date changes - break level 2
     C                   when      orrdte <> hld_orrdte and
     C                             hld_orrdte <> *loval
     C                   eval      brklvl2 = *on
     C                   eval      brklvl3 = *on
     C                   exsr      rptdetail1
     *
     *  Rtn code changed - break level 3
     C                   when      orrcod <> hld_orrcod and
     C                             hld_orrcod <> *loval
     C                   eval      brklvl2 = *on
     C                   eval      brklvl3 = *on
     C                   exsr      rptdetail1

     C                   endsl

     C                   eval      brklvl1 = *off
     C                   eval      brklvl2 = *off
     C                   eval      brklvl3 = *off

     *
     C                   exsr      rptfill1

     *--------------------------------------------------------
     C                   other
     *
     *  Page overflow - Print headings.
     C                   select
     C                   when      *in90 = *on
     C                   exsr      rpthead1
     C                   endsl
     *
     *  Pick up last record.
     *
510cDC*                  if        usemp# <> hld_emp#
510cMC                   if        ptemp# <> hld_emp#
     C                   write     skip1
     C                   eval      brklvl1 = *on
     C                   endif
     C                   eval      brklvl2 = *on
     C                   eval      brklvl3 = *on
     C                   exsr      rptdetail1
     *
     *  Page overflow - Print headings.
     C                   select
     C                   when      *in90 = *on
     C                   exsr      rpthead1
     C                   endsl
     *
     *  Print grand totals and footer
510dAC                   write     TotalLR                              90
     C                   write     Foot1                                90
     *
     C                   Leave
     C                   Endsl

     C                   EndDo

     C                   EndSr

     *----------------------------------------------------------------
     *  Rpthead1 - Print Report headings
     *----------------------------------------------------------------

     C     Rpthead1      BegSr

     C                   write     head1                                90
     C                   write     columns                              90

     C                   endsr

     *----------------------------------------------------------------
     *  rptdetail1 -  Print the report - For All Crews
     *----------------------------------------------------------------

     C     rptdetail1    BegSr
     C                   if        *in90 = *on
     C                   exsr      rpthead1
     C                   write     skip1                                90
     C                   endif
     C*
     C                   if        first = *on
     C                   eval      p1emp# = hld_emp#
     C                   eval      p1name = hld_name
     C                   eval      p1rdte = hld_rtndte
     C                   eval      p1rcod = hld_orrcod
     C                   eval      p1rdsc = hld_rndesc
     C                   endif
     C
     C                   if        brklvl3 = *on
     C                   eval      p1rcod = hld_orrcod
     C                   eval      p1rdsc = hld_rndesc
     C                   endif
     *
     C                   if        brklvl2 = *on
     C                   eval      p1rdte = hld_rtndte
     C                   eval      p1rcod = hld_orrcod
     C                   eval      p1rdsc = hld_rndesc
     C                   endif
     *
     C                   if        brklvl1 = *on
     C                   eval      p1emp# = hld_emp#
     C                   eval      p1name = hld_name
     C                   eval      p1rdte = hld_rtndte
     C                   eval      p1rcod = hld_orrcod
     C                   eval      p1rdsc = hld_rndesc
     C                   endif
     *
     C                   eval      rcount = rcnt
     C                   eval      pcount = pcnt
     C                   write     detail1                              90

     C                   eval      first = *off
     C                   clear                   p1emp#
     C                   clear                   p1name
     C                   clear                   p1rdte
     C                   clear                   p1rcod
     C                   clear                   p1rdsc
     *
     *  Clear total fields.
     C                   eval      tlqty1 = 0
     C                   eval      tlqty2 = 0
     C                   eval      tlqty3 = 0
     C                   eval      rcnt = 0
     C                   eval      pcnt = 0


     C                   endsr

     *----------------------------------------------------------------
     *  rptdetail2 -  Print the report - For All Crews
     *----------------------------------------------------------------

     C     rptdetail2    BegSr
     C*                  if        *in90 = *on
     C*                  exsr      rpthead1
     C*                  write     level1                               90
     C*                  endif
     C*
     C*                  write     detail2                              90

     C                   endsr

     *----------------------------------------------------------------
     *  rptfill1 -  Fill detail print fields.
     *----------------------------------------------------------------

     C     rptfill1      BegSr
     *
     C                   eval      empnam = %trimr(usfnam) + ' ' + uslnam
510b C                   if        empnam = *blanks
510b C                   eval      empnam = '*NONE'
510b C                   endif
     *
     *  Convert return date into mm/dd/yy format.
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      orrdte        $cvd8i
     C                   exsr      zzcvtdt
     C                   move      $cvd6o        rtndte
     *
     *  Accumulate total pieces returned for return code.
     C                   eval      tlqty1 = tlqty1 + orqty1
     C                   eval      tlqty2 = tlqty2 + orqty2
     C                   eval      tlqty3 = tlqty3 + orqty3
     C                   eval      #rtnqty = orqty1 + orqty2 + orqty3
     C                   eval      pcnt   = pcnt   + #rtnqty
     C                   eval      rcnt   = rcnt   + 1
     *
510dA*  Accumulate LR total pieces and count.
510dAC                   eval      lrrtnp = lrrtnp + #rtnqty
510dAC                   eval      lrrtnr = lrrtnr + 1

     *  Update holding fields.
510cDC*                  eval      hld_emp# = usemp#
510cMC                   eval      hld_emp# = ptemp#
     C                   eval      hld_name = empnam
     C                   eval      hld_orrdte = orrdte
     C                   eval      hld_rtndte = rtndte
     C                   eval      hld_orrcod = orrcod
     C                   eval      hld_rndesc = rndesc
ENH1A
ENH1A*  Extract ship date from order header.
ENH1A
ENH1AC*                  select
ENH1AC*                  when      ohmiscind >= 0
ENH1AC*                  eval      shpdat = %subst(ohmisc:13:6)
ENH1AC*                  move      shpdat        shpdte
ENH1AC*                  other
ENH1AC*                  eval      shpdte = 0
ENH1AC*                  endsl
     *
     C                   endsr

     *----------------------------------------------------------------
     *  Report1 - Process report 1
     *----------------------------------------------------------------

     C     Report1       BegSr

     *  Initialize report fields.

     C                   eval      sortorder1 = 'DATE'
     C                   Eval      order1   = 'ORWHSE'
510aAC                   Eval      order2   = 'ptemp#'
510aDC*                  Eval      order2   = 'USEMP#'
     C                   Eval      order3   = 'ORRDTE'
     C                   Eval      order4   = 'ORRCOD'

     *  Do initial build and display of subfile.

     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      rptbld1

     C                   ExSr      sqlclean
     C                   endsr

     *----------------------------------------------------------------
     *  Report2 - Process report 2
     *----------------------------------------------------------------

     C     Report2       BegSr

     *  Initialize report fields.

     C                   eval      sortorder1 = 'DATE'
     C                   Eval      order1   = 'ORWHSE'
510aAC                   Eval      order2   = 'ptemp#'
510aDC*                  Eval      order2   = 'USEMP#'
     C                   Eval      order3   = 'ORRDTE'
     C                   Eval      order4   = 'ORRCOD'

     *  Do initial build and display of subfile.

     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt2
     C                   ExSr      sqlprep
     C                   ExSr      rptbld1

     C                   ExSr      sqlclean
     C                   endsr

     *----------------------------------------------------------------
     *  Report3 - Process report 3
     *----------------------------------------------------------------

     C     Report3       BegSr

     *  Initialize report fields.

     C                   eval      sortorder1 = 'DATE'
     C                   Eval      order1   = 'ORWHSE'
510aAC                   Eval      order2   = 'ptemp#'
510aDC*                  Eval      order2   = 'USEMP#'
     C                   Eval      order3   = 'ORRDTE'
     C                   Eval      order4   = 'ORRCOD'

     *  Do initial build and display of subfile.

     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt3
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
