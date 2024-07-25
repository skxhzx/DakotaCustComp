     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2004')
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
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RN325     Print Customer Returns Anaylsis
     *  18 September 2002
     *  Max Blacknik
     *
     *  Revisions
     *
416 A*    09/18/02  MLB  4.16
     *      - Created.
416aA*    10/02/02  MLB  4.16a
     *      - Enh: Added support to pgm to print total pieces
     *        returned by code.
     *
417 A*    04/16/04  MLB  4.17
     *      - Fix: Changed program print sub-totals when page over-
     *        flow occurs and return code changes.
500aA*    10/13/05  RH   5.00a
     *      - ENH: Add DETAIL2 to print cust # and name, add OHCUST
     *        and OHCNAM to SQL.
500bA*    10/31/05  RLP  5.00b
     *      - ENH: Add parm $prcod to options program, which filters
     *        to this program to enable reporting for specific return
     *        code if $prcod not equal *ALL, revised SQL where clauses.
500cA*    02/07/06  MLB  5.00c
     *      - Fix: Revised program to change Where clause to
     *        include quotes around return code.
     *      - Fix: Revised program to initialize file numeric
     *        fields used in program.
510bA*    03/07/07  RH   5.10b
     *      - Fix: Print *NONE if employee name is blank.
510cA*    03/22/07  RBD  5.10c
     *      - Added code to print grand total pieces returned.
520aA*    04/14/09  RH   5.20a
     *      - Fix: Remove SLOT3 left outer join, was selecting all
     *        pick slots for returned item, not just one. Change to
     *        chain and get one pick slot for mispicked item.
640aA*    09/28/11  RH   6.40a
     *      - Enh: Revised program to add support for Client id
     *
720 A*    06/30/18  MLB  7.20
     *      - Enh: Added field OHORD to sql select clause. Needed for
     *        MJKb mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: MJ Kellner
MJKaA*    09/28/11  RH   MJKa
     *      - Enh: Get ship date from positon 16-19 OHMISC field.
MJKbA*    06/26/18  MLB  MJKb
     *      - Enh: Revised pgm to retrieve ship date from ORDH if
     *        positions 1-8 are blank in ORDHM.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocery
SGCaA*    10/09/17  RH   SGCa
     *      - Revised program to NOT get ship date from OHMISC field.
     *        New PE needs to use ORDER MISC file.
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

520a Fslot3     if   e           k disk
MJKbAFordhm     if   e           k disk    usropn
     Fwarehs    if   e           k disk
     FRN325PR   o    e             printer oflind(*IN90)

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
     D $code           s              2    inz(' ')
     D $count          s              8b 0 inz(0)
     D $date           s              8  0 inz(0)
     D desc01          s             30    inz(' ')
     D desc02          s             30    inz(' ')
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
640aAD client          s             10
     D desc01ind       s              2b 0 inz(0)
     D desc02ind       s              2b 0 inz(0)
     D endofmonth6     s              6  0 inz(0)
     D groupby         S             50a   inz(' ')
     D groupfields     S             50a   inz(' ')
     D hld_orrcod      s                   like(orrcod)
     D hld_orrdte      s                   like(orrdte)
     D innerjoin       S            200a   inz(' ')
520a D kyitem          s                   like(slitem)
520a D kystat          S              2a   inz('A ')
520a D kypick          S              1a   inz('Y')
520a D kywhse          s              3s 0 inz(0)
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
720 AD ohordind        s              2b 0 inz(0)
     D ohmiscind       s              2b 0 inz(0)
500a D ohcustind       s              2b 0 inz(0)
500a D ohcnamind       s              2b 0 inz(0)
     D ptcrewind       s              2b 0 inz(0)
     D ptemp#ind       s              2b 0 inz(0)
     D ptshftind       s              2b 0 inz(0)
     D rndescind       s              2b 0 inz(0)
     D scpad           s              3  0 inz(0)
     D selectfields    s            500a   inz(' ')
     D shpdat          s              6a   inz(' ')
MJKa D shpdatp         s              7a   inz(' ')
     D slot01          s             12a   inz(' ')
     D slot01ind       s              2b 0 inz(0)
     D slot02          s             12a   inz(' ')
     D slot02ind       s              2b 0 inz(0)
     D sortorder1      s             10a   inz(' ')
     D sortorder2      s             10a   inz(' ')
     D sortorder3      s             10a   inz(' ')
     D sqlStmt         s           1000a   inz(' ')
416aAD tlqty1          s              7  0 inz(0)
416aAD tlqty2          s              7  0 inz(0)
416aAD tlqty3          s              7  0 inz(0)
510cAD lrqty1          s              7  0 inz(0)
510cAD lrqty2          s              7  0 inz(0)
510cAD lrqty3          s              7  0 inz(0)
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

MJK AD ohmisci         ds
MJK AD  ohblk1                 1     15
MJK AD  ohshpd                16     19P 0
MJK AD  ohblk2                20     20
640aA*----------------------------------------------------------------
640aA*  Customer id
640aA*----------------------------------------------------------------

MJKaA /copy qcopysrc,id#mjkelln
SGCaA /COPY *libl/qcopysrc,id#sgc
MJKbA /copy qcopysrc,ordhm2_rtx
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
500bAC                   parm                    $prcod            4
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

MJKbA*
MJKbAC     hmkey         klist
MJKbAC                   kfld                    $whse
MJKbAC                   kfld                    ohord
520a *
520a *  Define partial key for SLOT3 file.
520a *
520a C     ptkeys        klist
520a C                   kfld                    kywhse
520a C                   kfld                    kyitem
520a C                   kfld                    kystat
520a C                   kfld                    kypick
     *  Get warehouse name for report.

     C                   move      $pwhs         $whse
     C     $whse         chain     warehs                             79
     C                   if        not %found
213 AC                   eval      whdesc = *blanks
     C                   endif
213 AC                   eval      wowhse = %editc($whse:'Z') + ' - ' +
     C                             whdesc
     C*
     C*   Center report title.
     C*
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
500cA*  Initialize file numeric fields.
500cAC                   eval      usemp# = 0
500cAC                   eval      ohcust = 0
500cAC                   eval      ohord  = 0
500cA*
     *  Force overflow on.
     C                   eval      *in90  = *on
640aA*
640aA* Get client id.
640aA*
640aAC                   call      'GETCLIENT'
640aAC                   parm                    client
MJKbA*
MJKbAC                   if        client = MJKellner
MJKbAC                   if        not %open(ordhm)
MJKbAC                   open      ordhm
MJKbAC                   endif
MJKaAC                   endif
640aA*
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
720 MC                             OHORD,OHMISC,OHCUST,OHCNAM'
520aDC*                            C1.LBDISP,D1.SLDISP,USFNAM,USINIT,USLNAM, +
500aDC*                            OHMISC'

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
     C                                       + 'ON USEMP# = PTEMP#'

     C                   eval      LeftJoin8 = 'LEFT OUTER JOIN ORDH    '
     C                                       + 'ON lbwhse = ohwhse and '
     C                                       + 'lbord     = ohord'

     * Create "where" clause.

500bAC                   select
500bAC                   when      $prcod = '*ALL'
     C                   Eval      WhereClause = 'WHERE ORWHSE = ' + $pwhs
     C                                           + ' AND ORRDTE >= '
     C                                           + %trim($pfmdt)
     C                                           + ' AND ORRDTE <= '
     C                                           + %trim($ptodt)

500bAC                   when      $prcod <> '*ALL'
500bAC                   Eval      WhereClause = 'WHERE ORWHSE = ' + $pwhs
500bAC                                           + ' AND ORRDTE >= '
500bAC                                           + %trim($pfmdt)
500bAC                                           + ' AND ORRDTE <= '
500bAC                                           + %trim($ptodt)
500bAC                                           + ' AND ORRCOD = '
500cAC                                           + quote
500bAC                                           + %trim($prcod)
500cAC                                           + quote
500bAC                   endsl

     * Create "Order By" clauses.

     C                   eval      OrderFields = %trim(order1) + ', '
     C                                         + %trim(order2) + ', '
     C                                         + %trim(order3) + ', '
     C                                         + %trim(order4) + ', '
     C                                         + %trim(order5)

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
720 MC                             OHORD,OHMISC,OHCUST,OHCNAM'
520aDC*                            C1.LBDISP,D1.SLDISP,USFNAM,USINIT,USLNAM, +
500aDC*                            OHMISC'

     * Create "left outer join" clause

     C                   eval      LeftJoin = 'LEFT OUTER JOIN RTNCODE '
     C                                      + 'ON RNCODE = ORRCOD'

     C                   eval      LeftJoin2 = 'LEFT OUTER JOIN PIRITEM B1 '
     C                                      + 'ON B1.ITWHSE = ORWHSE '
     C                                      + 'AND B1.ITITEM = ORITEM'

     C                   eval      LeftJoin3 = 'LEFT OUTER JOIN PIRITEM B2 '
     C                                       + 'ON B2.ITWHSE = ORWHSE '
     C                                       + 'AND B2.ITITEM = ORCITM'

     C                   eval      LeftJoin4 = 'LEFT OUTER JOIN LABEL  C1 '
     C                                      + 'ON C1.LBLBL# = OROLB# '

520aDC*                  eval      LeftJoin5 = 'LEFT OUTER JOIN SLOT3 D1 '
520aDC*                                     + 'ON D1.SLWHSE = ORWHSE AND '
520aDC*                                     + 'D1.SLITEM = ORCITM and '
520aDC*                                     + 'D1.SLSTAT = ''A '' and  '
520aDC*                                     + 'D1.SLPICK = ''Y'' '

     C                   eval      LeftJoin6 = 'LEFT OUTER JOIN PIRUSER '
     C                                        + 'ON USEMP# = PTEMP#'

     C                   eval      LeftJoin7 = 'LEFT OUTER JOIN ORDH    '
     C                                       + 'ON lbwhse = ohwhse and '
     C                                       + 'lbord     = ohord'

     * Create "Inner join" clause.

     C                   eval      Innerjoin = 'INNER JOIN PIRTRAN '
     C                                       + 'ON PTTRN# = ORTRN#'


     * Create "where" clause.

500bAC                   select
500bAC                   when      $prcod = '*ALL'
     C                   Eval      WhereClause = 'WHERE ORWHSE = ' + $pwhs
     C                                           + ' AND ORRDTE >= '
     C                                           + %trim($pfmdt)
     C                                           + ' AND ORRDTE <= '
     C                                           + %trim($ptodt)
     C                                           + ' AND PTCREW = '
     C                                           + quote + $pcrew + quote

500bAC                   when      $prcod <> '*ALL'
500bAC                   Eval      WhereClause = 'WHERE ORWHSE = ' + $pwhs
500bAC                                           + ' AND ORRDTE >= '
500bAC                                           + %trim($pfmdt)
500bAC                                           + ' AND ORRDTE <= '
500bAC                                           + %trim($ptodt)
500bAC                                           + ' AND PTCREW = '
500bAC                                           + quote + $pcrew + quote
500bAC                                           + ' AND ORRCOD = '
500cAC                                           + quote
500bAC                                           + %trim($prcod)
500cAC                                           + quote
500bAC                   endsl

     * Create "Order By" clauses.

     C                   eval      OrderFields = %trim(order1) + ', '
     C                                         + %trim(order2) + ', '
     C                                         + %trim(order3) + ', '
     C                                         + %trim(order4) + ', '
     C                                         + %trim(order5)

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
     C                                     + %trimr(LeftJoin4) + ' '
520aDC*                                    + %trimr(LeftJoin5) + ' '
     C                                     + %trimr(LeftJoin6) + ' '
     C                                     + %trimr(LeftJoin7) + ' '
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
500aMC                             C1.LBDISP,USFNAM,USINIT,USLNAM, +
500aMC                             OHMISC,OHCUST,OHCNAM'
520aDC*                            C1.LBDISP,D1.SLDISP,USFNAM,USINIT,USLNAM, +
500aDC*                            OHMISC'

     * Create "left outer join" clause

     C                   eval      LeftJoin = 'LEFT OUTER JOIN RTNCODE '
     C                                      + 'ON RNCODE = ORRCOD'

     C                   eval      LeftJoin2 = 'LEFT OUTER JOIN PIRITEM B1 '
     C                                      + 'ON B1.ITWHSE = ORWHSE '
     C                                      + 'AND B1.ITITEM = ORITEM'

     C                   eval      LeftJoin3 = 'LEFT OUTER JOIN PIRITEM B2 '
     C                                       + 'ON B2.ITWHSE = ORWHSE '
     C                                       + 'AND B2.ITITEM = ORCITM'

     C                   eval      LeftJoin4 = 'LEFT OUTER JOIN LABEL  C1 '
     C                                      + 'ON C1.LBLBL# = OROLB# '

520aDC*                  eval      LeftJoin5 = 'LEFT OUTER JOIN SLOT3 D1 '
520aDC*                                     + 'ON D1.SLWHSE = ORWHSE AND '
520aDC*                                     + 'D1.SLITEM = ORCITM and '
520aDC*                                     + 'D1.SLSTAT = ''A '' and  '
520aDC*                                     + 'D1.SLPICK = ''Y'' '

     C                   eval      LeftJoin6 = 'LEFT OUTER JOIN PIRUSER '
     C                                        + 'ON USEMP# = PTEMP#'

     C                   eval      LeftJoin7 = 'LEFT OUTER JOIN ORDH    '
     C                                       + 'ON lbwhse = ohwhse and '
     C                                       + 'lbord     = ohord'

     * Create "Inner join" clause.

     C                   eval      Innerjoin = 'INNER JOIN PIRTRAN '
     C                                       + 'ON PTTRN# = ORTRN#'


     * Create "where" clause.

500bAC                   select
500bAC                   when      $prcod = '*ALL'
     C                   Eval      WhereClause = 'WHERE ORWHSE = ' + $pwhs
     C                                           + ' AND ORRDTE >= '
     C                                           + %trim($pfmdt)
     C                                           + ' AND ORRDTE <= '
     C                                           + %trim($ptodt)
     C                                           + ' AND PTEMP# = '
     C                                           + $pemp#

500bAC                   when      $prcod <> '*ALL'
500bAC                   Eval      WhereClause = 'WHERE ORWHSE = ' + $pwhs
500bAC                                           + ' AND ORRDTE >= '
500bAC                                           + %trim($pfmdt)
500bAC                                           + ' AND ORRDTE <= '
500bAC                                           + %trim($ptodt)
500bAC                                           + ' AND PTEMP# = '
500bAC                                           + $pemp#
500bAC                                           + ' AND ORRCOD = '
500cAC                                           + quote
500bAC                                           + %trim($prcod)
500aAC                                           + quote
500bAC                   endsl

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
     C                                     + %trimr(LeftJoin4) + ' '
520aDC*                                    + %trimr(LeftJoin5) + ' '
     C                                     + %trimr(LeftJoin6) + ' '
     C                                     + %trimr(LeftJoin7) + ' '
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

     * Process the records in the SQL cursor until the return not = 0

     C                   Dow       forever = forever

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
     C+      INTO :orwhse, :orord, :oritem, :orqty1, :orqty2, :orqty3, :orrdte,
     C+      :orrtim, :orrusr, :ortrn#, :orcitm, :orrcod, :orrmem, :orslot,
     C+      :rndesc :rndescind, :desc01 :desc01ind, :desc02 :desc02ind,
     C+      :ptshft :ptshftind, :ptcrew :ptcrewind, :ptemp# :ptemp#ind,
520aMC+      :slot01 :slot01ind, :usfnam :usfnamind                    ,
720 MC+      :usinit :usinitind, :uslnam :uslnamind, :ohord :ohordind,
720 MC+      :ohmisc :ohmiscind
520aDC*      :slot01 :slot01ind, :slot02 :slot02ind, :usfnam :usfnamind,
500aDC*      :usinit :usinitind, :uslnam :uslnamind, :ohmisc :ohmiscind
     C/END-EXEC

     C                   select
     C                   when      sqlstt = '00000'

     C                   select
     *  Page overflow - Print headings.
     C                   when      *in90 = *on
     C                   exsr      rpthead1
417 AC                   If        orrcod = hld_orrcod
     C                   eval      hld_orrcod = *loval
417 AC                   Endif
     C                   endsl
416aA*
416aA*  Rtn code changed and not just page overflow.
416aAC                   select
416aAC                   when      orrcod <> hld_orrcod and
416aAC                             hld_orrcod <> *loval
416aA*
416aAC                   eval      $pcmd  = '*QTY2STR'
416aAC                   eval      $pqty1 = tlqty1
416aAC                   eval      $pqty2 = tlqty2
416aAC                   eval      $pqty3 = tlqty3
416aAC                   eval      $pqstr = *blanks
416aAC                   exsr      zzcvtst
416aAC                   eval      tlrtnq =  $pqstr
416aA*
416aAC                   write     total1                               90
416aA*
416aA*  Clear total fields.
416aAC                   eval      tlqty1 = 0
416aAC                   eval      tlqty2 = 0
416aAC                   eval      tlqty3 = 0
416aA*
416aAC                   endsl
416aA*

     C                   select
     C                   when      orrcod <> hld_orrcod
     C                   eval      hld_orrcod = orrcod
     *
     C                   write     level1                               90
     *
     C                   endsl

     *  Check for fields not returned.

     C                   select
     C                   when      rndescind < 0
     C                   eval      rndesc = '* Code not found *'
     C                   endsl

     C                   select
     C                   when      desc01ind < 0
     C                   eval      desc01 = '* Item Master not found *'
     C                   endsl

     C                   select
     C                   when      desc02ind < 0
     C                   eval      desc02 = *blanks
     C                   endsl

     C                   select
     C                   when      ptshftind < 0
     C                   eval      ptshft = *blanks
     C                   eval      ptcrew = *blanks
     C                   eval      ptemp# = *zeros
     C                   endsl

     C                   select
     C                   when      slot01ind < 0
     C                   eval      slot01 = *blanks
     C                   endsl

     C                   select
     C                   when      slot02ind < 0
     C                   eval      slot02 = *blanks
     C                   endsl
520aA
520a C                   eval      slot02 = *blanks
520aAC                   select
520a C                   when      orcitm<> ' '
520a C                   eval      kywhse = $whse
520a C                   eval      kyitem = orcitm
520a C     ptkeys        setll     slot3
520a C     ptkeys        reade     slot3                                  79
520a C                   if        *in79
520a C                   eval      slot02 = *blanks
520a C                   else
520a C                   eval      slot02 = sldisp
520a C                   endif
520aAC                   endsl

     C                   select
     C                   when      usfnamind < 0 or +
     C                             usinitind < 0 or +
     C                             usfnamind < 0
     C                   eval      usfnam = *blanks
     C                   eval      usinit = *blanks
     C                   eval      uslnam = *blanks
     C                   endsl

     C                   exsr      rptfill1
     C                   exsr      rptdetail1
500a C                   exsr      rptdetail2

     C                   other
     *
416aAC                   eval      $pcmd  = '*QTY2STR'
416aAC                   eval      $pqty1 = tlqty1
416aAC                   eval      $pqty2 = tlqty2
416aAC                   eval      $pqty3 = tlqty3
416aAC                   eval      $pqstr = *blanks
416aAC                   exsr      zzcvtst
416aAC                   eval      tlrtnq =  $pqstr
416aA*
416aA*  Page overflow - Print headings.
416aAC                   select
416aAC                   when      *in90 = *on
416aAC                   exsr      rpthead1
416aAC                   endsl
416aAC                   write     total1                               90
416aA*
416aA*  Page overflow - Print headings.
416aAC                   select
416aAC                   when      *in90 = *on
416aAC                   exsr      rpthead1
416aAC                   endsl
     *
510cA*  Print grand total pieces returned.
510cAC                   eval      $pcmd  = '*QTY2STR'
510cAC                   eval      $pqty1 = lrqty1
510cAC                   eval      $pqty2 = lrqty2
510cAC                   eval      $pqty3 = lrqty3
510cAC                   eval      $pqstr = *blanks
510cAC                   exsr      zzcvtst
510cAC                   eval      lrrtnq =  $pqstr
510cAC                   write     totallr                              90
     *
416aAC                   write     Foot1                                90
416aA*
     *
     C                   Leave
     C                   Endsl

     C                   EndDo

     C                   EndSr

     *----------------------------------------------------------------
     *  Rpthead1 - Print Report headings
     *----------------------------------------------------------------

     C     Rpthead1      BegSr

     C                   write     Head1                                90
     C                   write     columns                              90

     C                   endsr

     *----------------------------------------------------------------
     *  rptdetail1 -  Print the report - For All Crews
     *----------------------------------------------------------------

     C     rptdetail1    BegSr
     C                   if        *in90 = *on
     C                   exsr      rpthead1
     C                   write     level1                               90
     C                   endif
     C*
     C                   write     detail1                              90

     C                   endsr

500a *----------------------------------------------------------------
500a *  rptdetail2 -  Print the report - For All Crews
500a *----------------------------------------------------------------
500a
500a C     rptdetail2    BegSr
500a C                   if        *in90 = *on
500a C                   exsr      rpthead1
500a C                   write     level1                               90
500a C                   endif
500a C*
500a C                   write     detail2                              90
500a
500a C                   endsr
500a
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
     C                   if        orrdte <> hld_orrdte
     C                   eval      hld_orrdte = orrdte
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      orrdte        $cvd8i
     C                   exsr      zzcvtdt
     C                   move      $cvd6o        rtndte
     C                   endif
     *
     C                   eval      $pcmd  = '*QTY2STR'
     C                   eval      $pqty1 = orqty1
     C                   eval      $pqty2 = orqty2
     C                   eval      $pqty3 = orqty3
     C                   eval      $pqstr = *blanks
     C                   exsr      zzcvtst
     C                   eval      rtnqty =  $pqstr

416aA*  Accumulate total pieces returned for return code.
416aAC                   eval      tlqty1 = tlqty1 + orqty1
416aAC                   eval      tlqty2 = tlqty2 + orqty2
416aAC                   eval      tlqty3 = tlqty3 + orqty3

510cA*  Accumulate grand total pieces returned.
510cAC                   eval      lrqty1 = lrqty1 + orqty1
510cAC                   eval      lrqty2 = lrqty2 + orqty2
510cAC                   eval      lrqty3 = lrqty3 + orqty3

ENH1A*  Extract ship date from order header.
ENH1A
ENH1AC                   select
ENH1AC                   when      ohmiscind >= 0
MJKaAC                   if        client = mjkellner
MJKbAC     hmkey         chain     ordhm
MJKbAC                   if        not %found(ORDHM)
MJKbAC                   eval      rtxhm2_hmdtei = 0
MJKbAC                   else
MJKbAC                   eval      rtxhm2_base = hmmsc2
MJKbAC                   endif
MJKbA*
MJKbA*       Ship date from Retalix P/E v6
MJKbAC                   if        %subst(hmmsc2:1:8) > ' '
MJKbAC                   eval      $cvd8i = %editc(rtxhm2_hmdtei : 'X')
MJKbAC                   eval      $cvcmd = '*CMDMDY '
MJKbAC                   call      @cvtdt
MJKbAC                   parm                    $cvtdt
MJKbAC                   eval      shpdte = $cvd6o
MJKbA*
MJKbAC                   else
MJKbA*       Ship date from Retalix IDS v3
MJKbA*
MJKaAC                   eval      ohmisci = ohmisc
MJKaAC                   eval      shpdatp = %editc(ohshpd:'X')
MJKaAC                   move      shpdatp       shpdte
MJKbA*
MJKbAC                   endif                                                  Endif hmmsc2 = ' '
MJKbA*
MJKaAC                   else
SGCaAC                   if        client = SGC
SGCaAC                   eval      shpdte = 0
SGCaAC                   else
ENH1AC                   eval      shpdat = %subst(ohmisc:13:6)
ENH1AC                   move      shpdat        shpdte
SGCaAC                   endif
MJKaAC                   endif
ENH1AC                   other
ENH1AC                   eval      shpdte = 0
ENH1AC                   endsl
     *
     C                   endsr

     *----------------------------------------------------------------
     *  Report1 - Process report 1
     *----------------------------------------------------------------

     C     Report1       BegSr

     *  Initialize report fields.

     C                   eval      sortorder1 = 'DATE'
     C                   Eval      order1   = 'ORWHSE'
     C                   Eval      order2   = 'ORRCOD'
     C                   Eval      order3   = 'ORRDTE'
     C                   Eval      order4   = 'PTEMP#'
     C                   Eval      order5   = 'ORRTIM'

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
     C                   Eval      order2   = 'ORRCOD'
     C                   Eval      order3   = 'ORRDTE'
     C                   Eval      order4   = 'PTEMP#'
     C                   Eval      order5   = 'ORRTIM'

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
     C                   Eval      order2   = 'ORRCOD'
     C                   Eval      order3   = 'ORRDTE'
     C                   Eval      order4   = 'ORRTIM'

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
