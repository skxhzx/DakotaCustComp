      /copy qcopysrc,hspecs
650aAH DFTACTGRP(*NO) ACTGRP(*NEW)
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
      *               RDB    = Machine name that you will connect to.
      *               DLYPRP = *YES
      *               SQLPKG = The name & library that you want to
      *                        use for the package. This will put the
      *                        package on the RDB machine that you
      *                        specify.
      *****************************************************************
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PH310     View phrase log
     *  19 July 2008
     *  Dave Sommerville
     *
     *  Revisions
     *
600 A*    07/19/08  DAS  6.00  P#00045
     *      - Created.
     *
610aA*    08/03/10  DAS  6.10a
     *      - Added time, emp# and user to selection criteria.
     *      - Added timestamp selection to SQL statement.
     *      - Revised to display F9 window if no parms passed in.
     *      - Revised display 1 to show time stamp.
     *      - Added a 3rd view.
     *
650aA*    11/27/13  DAS  6.50a
     *      - Revised to call fmtphrase after record is read instead
     *        of as a function in the SQL statement. For some reason
     *        the fucntion stopped working.
     *      - Revised to not blow up on F3.
     *
     *----------------------------------------------------------------

650aA*----------------------------------------------------------------
650aA*  Binding Directories
650aA*----------------------------------------------------------------
650aA
650aAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fph310fm   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl2:rrn1)
610aAF                                     sfile(sfl3:rrn1)
     F                                     infds(info)

650aA*----------------------------------------------------------------
650aA* Function prototypes.
650aA*----------------------------------------------------------------
650aA
650aA /copy qcopysrc,p.bfcphras

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants for screen attributes
     *----------------------------------------------------------------

     D @n              C                   const(X'20')
     D @h              C                   const(X'22')
     D @u              C                   const(X'24')
     D @hu             C                   const(X'26')

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')
     D SubfilePage     C                   Const(16)

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D f#phlflds     E ds                  extname(phraselog)
     D f#phflds      E ds                  extname(phrasetbl)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
     D sqlfunc         s            200a   inz(' ')

     *----------------------------------------------------------------
     *  SQL fetch fields
     *----------------------------------------------------------------

     D sqlfile         c                   'PHRASELOG'
     D sqlfields       c                   'phlRecId,phlId,phlWhse,-
     D                                      phlEmp#,phlUser,phlPgm,-
     D                                      phlItem,phlWhdp,phlLoc,-
     D                                      phlTrn#,phlLcns,phlLtrn,-
     D                                      phlVars,-
     D                                      phlAddTS,phlAddUC,phlAddPgm,-
     D                                      phlAddJob,phlAddNbr,-
     D                                      phxml'

     D fetchds         ds
500aMD   #phlRecId                         like(phlRecId)
500aMD   #phlId                            like(phlId)
500aMD   #phlWhse                          like(phlWhse)
500aMD   #phlEmp#                          like(phlEmp#)
500aMD   #phlUser                          like(phlUser)
500aMD   #phlPgm                           like(phlPgm)
500aMD   #phlItem                          like(phlItem)
500aMD   #phlWhdp                          like(phlWhdp)
500aMD   #phlLoc                           like(phlLoc)
500aMD   #phlTrn#                          like(phlTrn#)
500aMD   #phlLcns                          like(phlLcns)
500aMD   #phlLtrn                          like(phlLtrn)
500aMD   #phlVars                          like(phlVars)
500aMD   #phlAddTS                         like(phlAddTS)
500aMD   #phlAddUC                         like(phlAddUC)
500aMD   #phlAddPgm                        like(phlAddPgm)
500aMD   #phlAddJob                        like(phlAddJob)
500aMD   #phlAddNbr                        like(phlAddNbr)
500aMD   #phXml                            like(phXml)
650aDD** #fPhrase                          like(phXml)

     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

415aAD $iopt           s              2
415aAD $ivalue         s             15
415aAD $iwhdp          s              5
500eDD*$iwhse          s              2  0
500eMD $iwhse          s              3  0

415aAD $popt           s                   like($iopt)
415aAD $pvalue         s                   like($ivalue)
415aAD $pwhdp          s                   like($iwhdp)
415aAD $pwhse          s                   like($iwhse)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD   #fPhrase      s                   like(phXml)
415aAD $code           s              2    inz(' ')
415aAD $count          s              8b 0 inz(0)
415aAD append1         s              1
415aAD append5         s              5
500bAD curview         s              1  0 inz(1)
610aAD dur             s              3
415aAD eorder1         s             20    inz(' ')
415aAD eorder2         s             20    inz(' ')
500cAD first           s               n
416aMD groupby         S            100a   inz(' ')
416aMD groupfields     S            100a   inz(' ')
415aAD iorder1         s             20    inz(' ')
415aAD iorder2         s             20    inz(' ')
     D lastrrn         s                   like(rrn1)
610aAD lastAddTS       s               z   inz(z'0001-01-01-00.00.00.000000')
610aAD lastAddTSind    s              2b 0
610aMD maxview         s              1  0 inz(3)
415aAD newordpos       s              3  0 inz(0)
610aAD noParmsPassed   s               n
610aAD noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
     D oldhead         s                   like(schead)
     D oldname         s                   like(scrname)
     D oldopt          s                   like(scopt1)
     D optiontaken     s             10    inz(' ')
415aAD order1          s             10    inz(' ')
415aAD order2          s             10    inz(' ')
416aMD orderby         S            100a   inz(' ')
415aAD orderfield      s             10    inz(' ')
415aAD orderposition   s              3  0 inz(0)
500bAD posfld          s              5    inz(' ')
500aAD recpos          s                   like(rrn1)
415aAD scheadlen       s              3  0 inz(0)
415aAD scpad           s              3  0 inz(0)
610aAD seconds         s              9  0
610aAD seconds3        s              3  0
610aAD skipRec         s               n
415aAD sortorder1      s             10    inz(' ')
415aAD sortorder2      s             10    inz(' ')
415aAD sortorder3      s             10    inz(' ')

610aA*----------------------------------------------------------------
610aA*  From Date/Time Redefinition Data Structures
610aA*----------------------------------------------------------------
610aA
610aAD w1fts           s             26
610aA
610aAD                 ds
610aAD  w1fdte                 1      6  0
610aAD  w1fmm                  1      2
610aAD  w1fdd                  3      4
610aAD  w1fyy                  5      6
610aA
610aAD                 ds
610aAD  w1ftim                 1      6  0
610aAD  w1fhh                  1      2
610aAD  w1fmi                  3      4
610aAD  w1fss                  5      6

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1recid                1     11  0
500cMD  h1dummy              200    200

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

     D @cvtdt          c                   CONST('CVTDTE')

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
     *      $popt    - Option
     *      $pwhse   - Warehouse
     *      $pwhdp   - Warehouse department
     *      $pvalue  - Value
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $iopt
     C                   parm                    $iwhse
     C                   parm                    $iwhdp
     C                   parm                    $ivalue

610aAC                   eval      noParmsPassed = *on

     C                   if        %parms >= 1
     C                   eval      $popt = $iopt
     C                   else
     C                   eval      $popt = ' '
     C                   endif

610aMC                   if        %parms >= 2 and $iwhse > 0
     C                   eval      $pwhse = $iwhse
610aAC                   eval      noParmsPassed = *off
     C                   else
     C                   eval      $pwhse = 0
     C                   endif

610aMC                   if        %parms >= 3 and $iwhdp > ' '
     C                   eval      $pwhdp = $iwhdp
610aAC                   eval      noParmsPassed = *off
     C                   else
     C                   eval      $pwhdp = '*ALL'
     C                   endif

610aMC                   if        %parms >= 4 and $ivalue > ' '
     C                   eval      $pvalue = $ivalue
610aAC                   eval      noParmsPassed = *off
     C                   else
     C                   eval      $pvalue = '*ALL'
     C                   endif

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      *
      * Establish the connection to the remote machine. The -842 return
      * code indicates that the connection is already established. If
      * you want to connect to the local machine, use CONNECT RESET.

     C/EXEC SQL
     C+ CONNECT RESET
     C/END-EXEC
     C                   If        sqlstt = '00000'
     C                   endif

     *  Process main screen.

     C                   exsr      screen1

      *
      *  Disconnect the current connection.
      *
     C/EXEC SQL
     C+   DISCONNECT CURRENT
     C/END-EXEC
     C                   If        sqlstt = '00000'
     C                   endif
      *
     C                   Eval      *inlr = *on

     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
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

     * Create "From" clause.

     C                   eval      sqlfrom = 'FROM ' + sqlfile

     * Add function call.

610aDC**                 eval      sqlfunc = ', '
610aDC**                                   + 'fmtphrase(phLid,'
610aMC                   eval      sqlfunc = 'fmtphrase(phLid,'
     C                                     + 'phXml,phlWhse,phlEmp#,'
     C                                     + 'phlUser,phlPgm,phlItem,'
     C                                     + 'phlWhdp,phlloc,phlTrn#,'
     C                                     + 'phlLcns,phlLtrn,phlVars)'

     * Add Left outer join.

     C                   eval      sqljoin = 'left outer join '
     C                                     + 'phrasetbl on '
     C                                     + 'phId=phlId and '
     C                                     + 'phLang='+sq+'EN'+sq

     * Create "where" clause.

     C                   eval      sqlwhere = ' '
     C                   eval      append5  = 'WHERE'

     *   Warehouse

     C                   if        w1whse > 0
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' phlWhse='
     C                                      + %editc(w1whse:'P')
     C                   eval      append5 = ' and '
     C                   endif

     *   Original License

     C**                 if        w1olic <> '*ALL'
     C**                 eval      sqlwhere = %trimr(sqlwhere) + append5
     C**                                    + ' lrolic='
     C**                                    + sq + %trim(w1olic) + sq
     C**                 eval      append5 = ' and '
     C**                 endif

     *   License

     C                   if        w1lic <> '*ALL'
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' phlLcns='
     C                                      + sq + %trim(w1lic) + sq
     C                   eval      append5 = ' and '
     C                   endif

     *   Department

     C                   if        w1whdp <> '*ALL'
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' phlWhdp='
     C                                      + sq + %trim(w1whdp) + sq
     C                   eval      append5 = ' and '
     C                   endif

     *   Program

     C                   if        w1pgm  <> '*ALL'
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' phlPgm='
     C                                      + sq + %trim(w1Pgm) + sq
     C                   eval      append5 = ' and '
     C                   endif

     *   Location

     C                   if        w1loc  <> '*ALL'
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' phlLoc='
     C                                      + sq + %trim(w1Loc) + sq
     C                   eval      append5 = ' and '
     C                   endif

     *   Item

     C                   if        w1item <> '*ALL'
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' phlItem='
     C                                      + sq + %trim(w1item) + sq
     C                   eval      append5 = ' and '
     C                   endif

     *   Job Number

     C                   if        w1jobn <> '*ALL'
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' phladdnbr='
     C                                      + sq + %trim(w1jobn) + sq
     C                   eval      append5 = ' and '
     C                   endif
610aA
610aA*   Employee #
610aA
610aAC                   if        w1emp# > 0
610aAC                   eval      sqlwhere = %trimr(sqlwhere) + append5
610aAC                                      + ' phlEmp#='
610aAC                                      + %editc(w1emp#:'P')
610aAC                   eval      append5 = ' and '
610aAC                   endif
610aA
610aA*   User
610aA
610aAC                   if        w1user <> '*ALL'
610aAC                   eval      sqlwhere = %trimr(sqlwhere) + append5
610aAC                                      + ' phlEmp#='
610aAC                                      + sq + %trim(w1user) + sq
610aAC                   eval      append5 = ' and '
610aAC                   endif
610aA
610aA*   From Date/Time
610aA
610aAC                   if        w1fdte > 0
610aAC                   eval      w1fts = '20' + w1fyy + '-'
610aAC                                   + w1fmm + '-'
610aAC                                   + w1fdd + '-'
610aAC                                   + w1fhh + '.'
610aAC                                   + w1fmi + '.'
610aAC                                   + w1fss + '.'
610aAC                                   + '000000'
610aAC                   eval      sqlwhere = %trimr(sqlwhere) + append5
610aAC                                      + ' phlAddTS>='
610aAC                                      + sq + w1fts + sq
610aAC                   eval      append5 = ' and '
610aAC                   endif

     * Create "Order By" clauses.

     C                   eval      sqlorder = 'ORDER BY PHLADDUC'

     C*                  select

     C*                  when      sortorder1 = 'DESCEND'
500cAC*                  if        w1oby = '1'
     C*                  eval      sqlorder = 'ORDER BY LRADDUC DESC'
500cAC*                  else
500cAC*                  eval      sqlorder = 'ORDER BY LRLTRN DESC'
500cAC*                  endif

     C*                  other
500cAC*                  if        w1oby = '1'
     C*                  eval      sqlorder = 'ORDER BY LRADDUC'
500cAC*                  else
500cAC*                  eval      sqlorder = 'ORDER BY LRLTRN'
500cAC*                  endif

     C*                  endsl

     * Create list heading

     C                   exsr      createhead1

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
650aMC                                     + %trimr(sqlfields) + ' '
650aDC**                                   + %trimr(sqlfields) + ','
650aDC**                                   + %trimr(sqlfunc) + ' '
     C                                     + %trimr(sqlfrom) + ' '
     C                                     + %trimr(sqljoin) + ' '
     C                                     + %trimr(sqlwhere) + ' '
     C                                     + sqlorder

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
      * it prepares th cursor.

     C/EXEC SQL
     C+   PREPARE sel FROM :SqlStmt
     C/END-EXEC
     C                   If        sqlstt = '00000'
     C                   endif
      *
      * Declare the SQL cursor to hold the data retrieved from the SELECT
      *
     C/EXEC SQL
     C+ DECLARE MYCSR SCROLL CURSOR FOR SEL
     C/END-EXEC
     C                   If        sqlstt = '00000'
     C                   endif
      *
      * Open the SQL cursor.
      *
     C
     C/EXEC SQL
     C+ OPEN MYCSR
     C/END-EXEC
     C                   If        sqlstt = '00000'
     C                   endif
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
     C                   If        sqlstt = '00000'
     C                   endif
      *
     C                   Endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                    Subfile Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sflbld1 - Build the subfile
     *----------------------------------------------------------------

     C     sflbld1       BegSr

     C                   Eval      rrn1 = Lastrrn
     C                   Eval      recpos = lastrrn
     C                   Eval      first = *on

     * Process the records in the SQL cursor until the return not = 0

610aAC                   eval      i = 0
610aDC**                 Do        SubfilePage
610aAC                   dou       i = SubfilePage

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
     C+      INTO :fetchds
     C/END-EXEC

     C                   If        sqlstt = '00000'

     C                   exsr      createline1
610aAC                   if        skipRec
610aAC                   iter
610aAC                   endif
610aAC                   eval      i += 1
     C                   Eval      rrn1  = rrn1  + 1
     C                   if        first
     C                   eval      first = *off
     C                   Eval      recpos = rrn1
     C                   endif
     C                   Eval      option = ' '
     C                   Write     sfl1
     C                   Write     sfl2
610aAC                   Write     sfl3
     C                   Else
     C                   Leave
     C                   EndIf

     C                   EndDo

     C                   If        rrn1 = 0
     C                   Eval      *in32 = *on
     C                   Else
     C                   Eval      Lastrrn = rrn1
     C                   EndIf

      * A code of 2000 means end of file.

     C                   If        sqlstt = '02000'
500aDC**                 Eval      *in90 = *on
     C                   EndIf

     C                   EndSr

     *----------------------------------------------------------------
     *  sflclr - Clear subfile
     *----------------------------------------------------------------

     C     sflclr        BegSr

      * Clear the subfile

     C                   Eval      *in31 = *on
     C                   Write     sf1ctl
500bAC                   Write     sf2ctl
500bAC                   Write     sf3ctl
     C                   Eval      *in31 = *off
     C                   Eval      *in32 = *off
     C                   Eval      rrn1 = 0
     C                   Eval      Lastrrn = 0
500aAC                   Eval      recpos = 0
     C                   Eval      *in90 = *off
     C                   EndSr

     *----------------------------------------------------------------
     *  sfloption1 - Get entered option
     *----------------------------------------------------------------

     C     sfloption1    BegSr

500dAC                   eval      recpos = csrrrn

     C                   if        rrn1 = 0
     C                   goto      endsflopt1
     C                   endif

     C                   Eval      optiontaken = *off
     C                   Eval      *in21 = *off

500dDC**                 eval      recpos = 1

     C                   dow       forever = forever

500bAC                   select
610aAC                   when      curview = 3
610aAC                   readc     sfl3
500bAC                   when      curview = 2
500bAC                   readc     sfl2
500bAC                   other
     C                   readc     sfl1
500bAC                   endsl
     C                   if        %eof
     C                   leave
     C                   endif

500dDC**                 eval      recpos = csrrrn

     C                   select

     C                   when      %trim(option) = '2'
     C                   eval      optiontaken = 'Change'
500dAC                   eval      recpos = rrn1
     C                   leave

     C                   when      %trim(option) = '5'
     C                   eval      optiontaken = 'View'
500dAC                   eval      recpos = rrn1
     C                   leave

     C                   when      option = 'LO'
     C                             or option = 'LL'
     C                             or option = 'LS'
     C                             or option = 'LI'
     C                             or option = 'LB'
     C                             or option = 'OL'
     C                             or option = 'FL'
     C                             or option = 'TL'
     C                             or option = 'FS'
     C                             or option = 'TS'
     C                             or option = 'FI'
     C                             or option = 'TI'
     C                             or option = 'FB'
     C                             or option = 'TB'
500cAC                             or option = 'AJ'
500cAC                             or option = 'CJ'
     C                   eval      optiontaken = option
500dAC                   eval      recpos = rrn1
     C                   leave

     C                   endsl

     C                   enddo

500aAC                   eval      option = ' '
500bAC                   select
610aAC                   when      curview = 3
610aAC                   update    sfl3
500bAC                   when      curview = 2
500bAC                   update    sfl2
500bAC                   other
500aAC                   update    sfl1
500bAC                   endsl

500dMC     endsflopt1    EndSr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                Screen Processing Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  screen1 - Process screen 1
     *----------------------------------------------------------------

     C     screen1       BegSr

     *  Initialize screen fields.

     C                   Eval      scrname = 'PH310.01'
     C*                  eval      w1sort   = 'D'
500cAC*                  eval      w1oby    = '1'
     C                   exsr      inzcriteria1

     C                   select
     C                   when      $popt = 'LS'
     C                   eval      w1whdp   = $pwhdp
     C***                eval      w1slot   = $pvalue
     C                   when      $popt = 'LI'
     C**********         eval      w1item   = $pvalue
     C                   endsl

     C                   exsr      setcriteria1

     C                   eval      scopt1 = ' '
     C                   eval      scopt2 = ' '
     C*                  eval      scopt1 = '5=View'
     C*                                   + '       FL/TL=Frm/To lic'
     C*                                   + '   FI/TI=Frm/To item'

     C*                  eval      scopt2 = 'OL=Orig lic'
     C*                                   + '  FS/TS=Frm/To slot'
     C*                                   + '  FB/TB=Frm/To base slot'
500cAC*                                   + '  AJ/CJ=Add/Chg jobnbr'
610aA
610aA*  If not parms are passed in, display F9 window.
610aA
610aAC                   if        noParmsPassed
610aAC                   exsr      getcriteria1
610aAC                   if        cfkey <> Enter
610aAC                   leavesr
610aAC                   endif
610aAC                   endif

     *  Do initial build and display of subfile.

     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1

     *  Process subfile until user wants to leave.

     C                   DoU       (cfkey = F3)

     C                   Write     fkey1
500aAC                   if        recpos > 0 and recpos <= lastrrn
500aAC                   eval      rrn1 = recpos
500aAC                   else
500aAC                   eval      rrn1 = 1
500aAC                   endif
500bAC                   select
610aAC                   when      curview = 3
610aAC                   ExFmt     sf3ctl
500bAC                   when      curview = 2
500bAC                   ExFmt     sf2ctl
500bAC                   other
     C                   ExFmt     sf1ctl
500bAC                   endsl
      *
     C                   Select

     *    Enter

     C                   When      cfkey = Enter
     C                   ExSr      sfloption1

     C                   select

     C                   when      optiontaken = 'Change'
     C                   call      'LT830'
     C                   parm      ' '           $pcmd             8
     C*                  parm      h1ltrna       $plictrn#         7

     C                   when      optiontaken = 'View'
     C                   call      'LT830'
     C                   parm      '*VIEW'       $pcmd             8
     C*                  parm      h1ltrna       $plictrn#         7

     C                   when      optiontaken = 'LO'
     C                             or optiontaken = 'OL'
     C                   exsr      inzcriteria1
     C**                 eval      w1olic = h1olic
     C                   exsr      setcriteria1
500aAC                   ExSr      sqlclean
500aAC                   ExSr      sqlbldstmt1
500aAC                   ExSr      sqlprep
500aAC                   ExSr      sflclr
500aAC                   ExSr      sflbld1

     C                   when      optiontaken = 'FL'
     C                   exsr      inzcriteria1
     C**                 eval      w1lic = h1flic
     C                   exsr      setcriteria1

     C                   when      optiontaken = 'TL'
     C                             or optiontaken = 'LL'
     C                   exsr      inzcriteria1
     C**                 eval      w1lic = h1lcns
     C                   exsr      setcriteria1
500aAC                   ExSr      sqlclean
500aAC                   ExSr      sqlbldstmt1
500aAC                   ExSr      sqlprep
500aAC                   ExSr      sflclr
500aAC                   ExSr      sflbld1

     C                   when      optiontaken = 'FS'
     C                   exsr      inzcriteria1
     C**                 eval      w1whdp = h1fwhd
     C**                 eval      w1slot = h1fdsp
     C                   exsr      setcriteria1
500aAC                   ExSr      sqlclean
500aAC                   ExSr      sqlbldstmt1
500aAC                   ExSr      sqlprep
500aAC                   ExSr      sflclr
500aAC                   ExSr      sflbld1

     C                   when      optiontaken = 'TS'
     C                             or optiontaken = 'LS'
     C                   exsr      inzcriteria1
     C**                 eval      w1whdp = h1twhd
     C**                 eval      w1slot = h1tdsp
     C                   exsr      setcriteria1
500aAC                   ExSr      sqlclean
500aAC                   ExSr      sqlbldstmt1
500aAC                   ExSr      sqlprep
500aAC                   ExSr      sflclr
500aAC                   ExSr      sflbld1

     C                   when      optiontaken = 'FB'
     C                   exsr      inzcriteria1
     C**                 eval      w1whdp = h1fwhd
     C**                 eval      w1base = h1fbase
     C                   exsr      setcriteria1
500aAC                   ExSr      sqlclean
500aAC                   ExSr      sqlbldstmt1
500aAC                   ExSr      sqlprep
500aAC                   ExSr      sflclr
500aAC                   ExSr      sflbld1

     C                   when      optiontaken = 'TB'
     C                             or optiontaken = 'LB'
     C                   exsr      inzcriteria1
     C**                 eval      w1whdp = h1twhd
     C**                 eval      w1base = h1tbase
     C                   exsr      setcriteria1
500aAC                   ExSr      sqlclean
500aAC                   ExSr      sqlbldstmt1
500aAC                   ExSr      sqlprep
500aAC                   ExSr      sflclr
500aAC                   ExSr      sflbld1

     C                   when      optiontaken = 'FI'
     C                   exsr      inzcriteria1
     C**                 eval      w1item = h1fitm
     C                   exsr      setcriteria1
500aAC                   ExSr      sqlclean
500aAC                   ExSr      sqlbldstmt1
500aAC                   ExSr      sqlprep
500aAC                   ExSr      sflclr
500aAC                   ExSr      sflbld1

     C                   when      optiontaken = 'TI'
     C                             or optiontaken = 'LI'
     C                   exsr      inzcriteria1
     C**                 eval      w1item = h1titm
     C                   exsr      setcriteria1
500aAC                   ExSr      sqlclean
500aAC                   ExSr      sqlbldstmt1
500aAC                   ExSr      sqlprep
500aAC                   ExSr      sflclr
500aAC                   ExSr      sflbld1

500cAC                   when      optiontaken = 'AJ'
500cAC                   exsr      inzcriteria1
500cAC**                 eval      w1jobn = h1addnbr
500cAC                   exsr      setcriteria1
500cAC                   ExSr      sqlclean
500cAC                   ExSr      sqlbldstmt1
500cAC                   ExSr      sqlprep
500cAC                   ExSr      sflclr
500cAC                   ExSr      sflbld1

500cAC                   when      optiontaken = 'CJ'
500cAC                   exsr      inzcriteria1
500cAC**                 eval      w1jobn = h1chgnbr
500cAC                   exsr      setcriteria1
500cAC                   ExSr      sqlclean
500cAC                   ExSr      sqlbldstmt1
500cAC                   ExSr      sqlprep
500cAC                   ExSr      sflclr
500cAC                   ExSr      sflbld1

     C                   endsl

650aA*    F3 = Exit
650aA
650aAC                   When      cfkey = F3
650aAC                   Leave

     *    F5 = Refresh

     C                   When      cfkey = F5
     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1
     C                   eval      cfkey = Enter

     *    F9 = Get Select/Sort criteria.

     C                   When      cfkey = F9
     C                   ExSr      getcriteria1
     C                   if        cfkey = Enter
     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1
     C                   endif
     C                   eval      cfkey = Enter
500bA
500bA*    F10 = Previous view.
500bA
500bAC                   When      cfkey = F10
500bAC                   if        curview <= 0
500bAC                   eval      curview = maxview
500bAC                   else
500bAC                   eval      curview = curview - 1
500bAC                   endif
500bAC                   eval      cfkey = Enter
500bA
500bA*    F11 = Next view.
500bA
500bAC                   When      cfkey = F11
500bAC                   if        curview >= maxview
500bAC                   eval      curview = 1
500bAC                   else
500bAC                   eval      curview = curview + 1
500bAC                   endif
500bAC                   eval      cfkey = Enter

     *    F12 = Cancel

     C                   When      cfkey = F12
     C                   Leave

     *    PageDown = More records

     C                   When      cfkey = PageDown
     C                   ExSr      sflbld1
      *
     C                   EndSl
      *
     C                   EndDo

     C                   ExSr      sqlclean
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     Misc. Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  centerschead - Center characters in schead
     *----------------------------------------------------------------

     C     centerschead  BegSr

     C                   eval      scheadlen = %len(%trim(schead))
     C                   if        scheadlen > 0 and
     C                             scheadlen < %size(schead)
     C                   eval      scpad = %int((%size(schead)-scheadlen)/2)
     C                   eval      schead = %subst(blanks:1:scpad)
     C                                    + %trim(schead)
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  createhead1- Create subfile heading line
     *----------------------------------------------------------------

     C     createhead1   BegSr

500bMC                   eval      sflhead = @hu + 'Opt'
500bMC                                     + @hu + 'Phrase'
500bMC                                     + '                      '
610aMC                                     + '                  '
610aMC                                     + @hu + 'Dur'
610aMC                                     + @hu + 'Add Stamp               '
610aDC**                                   + '                      '
610aDC**                                   + @hu + 'Rec Id     '
610aDC**                                   + @hu + 'Program   '

500bAC                   eval      sflhead2 = @hu + 'Opt'
500bMC                                     + @hu + 'Rec Id     '
500bAC                                     + @hu + 'Phrase#'
500bAC                                     + @hu + 'Emp# '
500bAC                                     + @hu + 'User      '
500bAC                                     + @hu + 'License        '
500bAC                                     + @hu + 'LicTran'
500bAC                                     + @hu + 'Item           '

610aAC                   eval      sflhead3 = @hu + 'Opt'
610aAC                                      + @hu + 'Phrase'

     C                   endsr

     *----------------------------------------------------------------
     *  createline1- Create subfile display line
     *----------------------------------------------------------------

     C     createline1   BegSr
610aAC                   eval      skipRec = *off

650aA* Format phrase
650aA
650aA /free
650aA    #fPhrase = fmtPhrase(#phlId:
650aA                    #phXml:
650aA                    #phlWhse:
650aA                    #phlEmp#:
650aA                    #phlUser:
650aA                    #phlPgm:
650aA                    #phlItem:
650aA                    #phlWhdp:
650aA                    #phlLoc:
650aA                    #phlTrn#:
650aA                    #phlLcns:
650aA                    #phlLtrn:
650aA                    #phlVars
650aA          );
650aA /end-free

610aA* Calculate duration since last entry

610aAC                   exsr      GetLastTS
610aAC                   if        lastAddTS = noStamp
610aAC                   eval      seconds = 0
610aAC                   else
610aAC                   eval      seconds = %diff(#phlAddTS:lastAddTS:*seconds)
610aAC                   endif

610aAC                   select
610aAC                   when      seconds = 0
610aAC                   eval      dur = ' '
610aAC                   when      seconds <= 999
610aAC                   evalr     dur = %trim(%editc(seconds:'P'))
610aAC                   other
610aAC                   eval      dur = '***'
610aAC                   endsl

610aA* Do 'Phrase contains' check
610aA*   Note, we do it here instead of in the SQL statement so we can get
610aA*   an accurate duration from the previous record.

610aAC                   if        w1cont <> ' '
610aAC                             and %scan(%trim(w1cont): #fPhrase) = 0
610aAC                   eval      skipRec = *on
610aAC                   leavesr
610aAC                   endif

610aA* Create subfile lines

500bMC                   eval      sflline = ' '
610aMC                                     + %subst(#fPhrase:1:46) + ' '
610aMC                                     + dur + ' '
610aMC                                     + %subst(%char(#phlAddTS):1:24)
610aDC**                                   + %subst(#fPhrase:1:50) + ' '
610aDC**                                   + %editc(#phlRecId:'X') + ' '
610aDC**                                   + %editc(#phlRecId:'X') + ' '
610aDC**                                   + #phlPgm

500bAC                   eval      sflline2 = ' '
500bMC                                     + %editc(#phlRecId:'X') + '  '
500bMC                                     + %editc(#phlId:'Z') + '  '
500bMC                                     + %editc(#phlEmp#:'Z') + ' '
500bAC                                     + #phlUser + ' '
500bAC                                     + #phlLcns + ' '
500bMC                                     + %editc(#phlLtrn:'Z') + ' '
500bAC                                     + #phlItem

610aMC                   eval      sflline3 = ' '
610aMC                                      + %subst(#fPhrase:1:75)

     C                   eval              h1RecId = #phlRecId

     C                   endsr

     *----------------------------------------------------------------
     *  getcriteria1 - Prompt user for select and sort criteria
     *----------------------------------------------------------------

     C     getcriteria1  BegSr

     * Display window.

     C                   ExFmt     window1

     C                   if        cfkey = F3 or cfkey = F12
     C                   goto      endgetc1
     C                   endif

     * Set selection criteria.

     C                   exsr      setcriteria1

     C     endgetc1      EndSr

610aA*----------------------------------------------------------------
610aA*  GetLastTS  -  Get last stamp for employee
610aA*----------------------------------------------------------------
610aA
610aaC     GetLastTS     BegSr

      /free

        exec sql select max(phladdts) into :lastAddTS :lastAddTSind
                 from phraselog
                 where phlemp# = :#phlemp#
                   and phladdts < :#phladdts;

        if sqlstt <> sqlSuccess;
          lastAddTS = noStamp;
        endif;

      /end-free

     C                   EndSr

     *----------------------------------------------------------------
     *  inzcriteria1 - Initialize criteria 1 values.
     *----------------------------------------------------------------

     C     inzcriteria1  BegSr
     C                   eval      w1olic   = '*ALL'
     C                   eval      w1lic    = '*ALL'
     C                   eval      w1whdp   = '*ALL'
     C                   eval      w1pgm    = '*ALL'
     C                   eval      w1loc    = '*ALL'
     C                   eval      w1item   = '*ALL'
500cAC                   eval      w1jobn   = '*ALL'
610aAC                   eval      w1user   = '*ALL'
610aAC                   eval      w1emp#   = 0
610aAC                   eval      w1fdte   = 0
610aAC                   eval      w1ftim   = 0
610aAC                   eval      w1fts    = ' '
610aAC                   eval      w1cont   = ' '
     C                   EndSr

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------

     C     setcriteria1  BegSr

     * Set sort order.

     C*                  if        w1sort <> 'A' and w1sort <> 'D'
     C*                  eval      w1sort = 'D'
     C*                  endif

500cAC*                  if        w1oby <> '1' and w1oby <> '2'
500cAC*                  eval      w1oby = '1'
500cAC*                  endif

     C*                  select

     C*                  when      w1sort = 'D'
     C*                  eval      sortorder1 = 'DESCEND'

     C*                  other
     C*                  eval      sortorder1 = 'ASCEND'

     C*                  endsl

     *    Create screen heading.

     C                   eval      schead = ' '
     C                   eval      append1 = ' '

     C*                  if        w1sort = 'D'
     C*                  eval      schead = %trimr(schead) + append1
     C*                                   + 'Descend'
     C*                  eval      append1 = ','
     C*                  else
     C*                  eval      schead = %trimr(schead) + append1
     C*                                   + 'Ascend'
     C*                  eval      append1 = ','
     C*                  endif

500cAC*                  if        w1oby = '2'
500cAC*                  eval      schead = %trimr(schead) + append1
500cAC*                                   + 'By Lic Trn#'
500cAC*                  eval      append1 = ','
500cAC*                  else
500cAC*                  eval      schead = %trimr(schead) + append1
500cAC*                                   + 'By Add Time'
500cAC*                  eval      append1 = ','
500cAC*                  endif

610aAC                   select
610aAC                   when      w1fdte > 0 and w1ftim = 0
610aAC                   eval      schead = %trimr(schead) + append1
610aAC                                    + 'Date>='
610aAC                                    + %trim(%editc(w1fdte:'Y'))
610aAC                   eval      append1 = ','
610aA
610aAC                   when      w1fdte > 0 and w1ftim > 0
610aAC                   eval      schead = %trimr(schead) + append1
610aAC                                    + 'Date/Time>='
610aAC                                    + %trim(%editc(w1fdte:'Y')) + '-'
610aAC                                    + %trim(%editw(w1ftim:'  :  :  '))
610aAC                   eval      append1 = ','
610aAC                   endsl

610aAC                   if        w1emp# > 0
610aAC                   eval      schead = %trimr(schead) + append1
610aAC                                    + 'Emp#='
610aAC                                    + %trim(%editc(w1emp#:'P'))
610aAC                   eval      append1 = ','
610aAC                   endif

610aAC                   if        w1user <> '*ALL'
610aAC                   eval      schead = %trimr(schead) + append1
610aAC                                    + 'User=' + w1user
610aAC                   eval      append1 = ','
610aAC                   endif

     C                   if        w1olic <> '*ALL'
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Orig=' + w1olic
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1lic <> '*ALL'
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Lic=' + w1lic
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1whdp <> '*ALL'
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Dept=' + w1whdp
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1pgm <> '*ALL'
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Pgm=' + w1pgm
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1item <> '*ALL'
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Item=' + w1item
     C                   eval      append1 = ','
     C                   endif

500cAC                   if        w1jobn <> '*ALL'
500cAC                   eval      schead = %trimr(schead) + append1
500cAC                                    + 'JobNbr=' + w1jobn
500cAC                   eval      append1 = ','
500cAC                   endif

610aAC                   if        w1cont <> ' '
610aAC                   eval      schead = %trimr(schead) + append1
610aAC                                    + 'Contains=' + %trim(w1cont)
610aAC                   eval      append1 = ','
610aAC                   endif

     C                   if        append1 = ' '
     C                   eval      schead = %trimr(schead) + ',Everything'
     C                   endif

     C                   exsr      centerschead

     C     endsetc1      EndSr
