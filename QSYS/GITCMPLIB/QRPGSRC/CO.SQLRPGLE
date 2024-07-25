     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')

      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/CO) SRCFILE(XXX/QRPGSRC)
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
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CO        Customer order detail
     *  29 August 2002
     *  Dave Sommerville
     *
     *  Revisions
     *
416 A*    08/29/02  DAS  4.16
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fcofm      cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     infds(info)

     *----------------------------------------------------------------
     *  External Record Layout Data Structures
     *----------------------------------------------------------------

     D OHPARM        E DS                  EXTNAME(ORDH)
     D ODPARM        E DS                  EXTNAME(ORDD)
     D LBPARM        E DS                  EXTNAME(LABEL)
     D ITPARM        E DS                  EXTNAME(PIRITEM)

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants for attention key indicator byte
     *----------------------------------------------------------------

     D F3              C                   const(X'33')
     D F4              C                   const(X'34')
     D F9              C                   const(X'39')
     D F12             C                   const(X'3C')

     D Enter           C                   const(X'F1')
     D PageDown        C                   const(X'F5')

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

415aAD blanks          s            100    inz(' ')
     D forever         s               n
     D Quote           C                   Const('''')
     D SubfilePage     C                   Const(16)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

415aAD $odseqind       s              2b 0 inz(0)
415aAD $oditemind      s              2b 0 inz(0)
415aAD $odqor1ind      s              2b 0 inz(0)
415aAD $odqor2ind      s              2b 0 inz(0)
415aAD $odqor3ind      s              2b 0 inz(0)
415aAD $lblbl#ind      s              2b 0 inz(0)
415aAD $lbqpckind      s              2b 0 inz(0)
415aAD $lbdispind      s              2b 0 inz(0)
415aAD $lbucodind      s              2b 0 inz(0)
415aAD $itdescind      s              2b 0 inz(0)
415aAD $itum1ind       s              2b 0 inz(0)
415aAD $itum2ind       s              2b 0 inz(0)
415aAD $itum3ind       s              2b 0 inz(0)
     D groupby         S             50a   inz(' ')
     D itemdesc        S             35a   inz(' ')
     D lastrrn         s                   like(rrn1)
     D leftjoin        S            100a   inz(' ')
     D leftjoin2       S            100a   inz(' ')
415aAD order1          s             10    inz(' ')
415aAD order2          s             10    inz(' ')
     D orderby         S             50a   inz(' ')
     D orderqty        S             10a   inz(' ')
     D pickqty         S              6a   inz(' ')
415aAD scheadlen       s              3  0 inz(0)
415aAD scpad           s              3  0 inz(0)
     D selectfields    s            200a   inz(' ')
415aAD sortorder1      s             10    inz(' ')
     D sqlStmt         s           1000a   inz(' ')
     D whereclause     S            200a   inz(' ')
415aAD x               s              5  0 inz(0)

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1seq                  1      5  0
     D  h1item                 6     20
     D  h1lbl#                21     27  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pord#
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pord#           15 5

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

     *  Process main screen.

     C                   exsr      screen1

      *
      *  Disconnect the current connection.
      *
     C/EXEC SQL
     C+   DISCONNECT CURRENT
     C/END-EXEC
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
     *  sqlbldstmt1h - Build SQL statment for order header
     *----------------------------------------------------------------

     C     sqlbldstmt1h  BegSr

     * Create list of select fields.

     C                   eval      SelectFields = 'OHWHSE, OHRTE, OHORD, '
     C                                          + 'OHCNAM'

     * Create "where" clause.

     C                   Eval      WhereClause = 'WHERE OHWHSE = '
     C                                           + %trim(%editc(w1whse:'3'))
     C                                           + ' AND OHCORD = '
     C                                           + %trim(%editc(w1ord#:'3'))

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(SelectFields) + ' '
     C                                     + 'FROM ORDH '
     C                                     + %trim(whereclause)

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlbldstmt1d - Build SQL statment for oderer detail
     *----------------------------------------------------------------

     C     sqlbldstmt1d  BegSr

     * Create list of select fields.

     C                   eval      selectfields = 'ODSEQ, ODITEM, '
     C                                          + 'ODQOR1, ODQOR2, ODQOR3, '
     C                                          + 'LBLBL#, LBQPCK, LBDISP, '
     C                                          + 'LBUCOD, '
     C                                          + 'ITDESC, ITUM1, ITUM2, '
     C                                          + 'ITUM3'

     * Create "left outer join" clause

     C                   eval      LeftJoin = 'LEFT OUTER JOIN LABEL '
     C                                      + 'ON LBWHSE = ODWHSE '
     C                                      + 'AND LBRTE = '
     C                                      + quote + ohrte + quote + ' '
     C                                      + 'AND LBORD = ODORD '
     C                                      + 'AND LBSEQ = ODSEQ'

     C                   eval      LeftJoin2 = 'LEFT OUTER JOIN PIRITEM '
     C                                       + 'ON ITWHSE = ODWHSE '
     C                                       + 'AND ITITEM = ODITEM'

     * Create "where" clause.

     C                   Eval      WhereClause = 'WHERE ODWHSE = '
     C                                         + %trim(%editc(ohwhse:'3'))
     C                                         + ' AND ODORD = '
     C                                         + %trim(%editc(ohord:'3'))

     * Create "Order By" clause.

     C                   eval      OrderBy = 'ORDER BY '
     C                                     + %trim(order1) + ', '
     C                                     + %trim(order2)

     * Create list heading

     C                   exsr      createhead1

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(SelectFields) + ' '
     C                                     + 'FROM ORDD '
     C                                     + %trimr(LeftJoin) + ' '
     C                                     + %trimr(LeftJoin2) + ' '
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
      * it prepares th cursor.

     C/EXEC SQL
     C+   PREPARE sel FROM :SqlStmt
     C/END-EXEC
     C                   eval      sqlstt = sqlstt
      *
      * Declare the SQL cursor to hold the data retrieved from the SELECT
      *
     C/EXEC SQL
     C+ DECLARE MYCSR SCROLL CURSOR FOR SEL
     C/END-EXEC
     C                   eval      sqlstt = sqlstt
      *
      * Open the SQL cursor.
      *
     C
     C/EXEC SQL
     C+ OPEN MYCSR
     C/END-EXEC
     C                   eval      sqlstt = sqlstt
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
     *                    Subfile Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sflbld1  - Build the subfile line for order detail
     *----------------------------------------------------------------

     C     sflbld1       BegSr

     C                   Eval      rrn1 = Lastrrn

     * Process the records in the SQL cursor until the return not = 0

     C                   Do        SubfilePage

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
     C+      INTO :odseq :$odseqind,
     C+           :oditem :$oditemind,
     C+           :odqor1 :$odqor1ind,
     C+           :odqor2 :$odqor2ind,
     C+           :odqor3 :$odqor3ind,
     C+           :lblbl# :$lblbl#ind,
     C+           :lbqpck :$lbqpckind,
     C+           :lbdisp :$lbdispind,
     C+           :lbucod :$lbucodind,
     C+           :itdesc :$itdescind,
     C+           :itum1 :$itum1ind,
     C+           :itum2 :$itum2ind,
     C+           :itum3 :$itum3ind
     C/END-EXEC

     * Check for null values being returned because of joins.

     C                   if        $odseqind < 0
     C                   eval      odseq = 0
     C                   eval      oditem = ' '
     C                   eval      odqor1 = 0
     C                   eval      odqor2 = 0
     C                   eval      odqor3 = 0
     C                   endif

     C                   if        $lblbl#ind < 0
     C                   eval      lblbl# = 0
     C                   eval      lbqpck = 0
     C                   eval      lbdisp = ' '
     C                   eval      lbucod = ' '
     C                   endif

     C                   if        $itdescind < 0
     C                   eval      itdesc = '* Not on File *'
     C                   eval      itum1 = ' '
     C                   eval      itum2 = ' '
     C                   eval      itum3 = ' '
     C                   endif

     * If record was found, build line. Otherwise, get out.

     C                   If        sqlstt = '00000'
     C                   exsr      createline1
     C                   Eval      rrn1  = rrn1  + 1
     C                   Write     sfl1
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
     C                   Eval      *in90 = *on
     C                   EndIf

     C                   EndSr

     *----------------------------------------------------------------
     *  sflclr - Clear subfile
     *----------------------------------------------------------------

     C     sflclr        BegSr

      * Clear the subfile

     C                   Eval      *in31 = *on
     C                   Write     sf1ctl
     C                   Eval      *in31 = *off
     C                   Eval      *in32 = *off
     C                   Eval      rrn1 = 0
     C                   Eval      Lastrrn = 0
     C                   Eval      *in90 = *off
     C                   EndSr

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

     C                   eval      scrname = 'CO.01'

     C                   eval      w1whse   = 1
     C                   eval      w1ord#   = $pord#
     C                   Eval      w1sort   = '1'

     C                   eval      sortorder1 = 'SEQ'
     C                   Eval      order1   = 'ODSEQ'
     C                   Eval      order2   = 'ODITEM'

     C                   exsr      bldschead

     *  Do initial build and display of subfile.

     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1d
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1

     *  Process subfile until user wants to leave.

     C                   DoU       (cfkey = F3)

     C                   Write     fkey1
     C                   ExFmt     sf1ctl
      *
     C                   Select

     *    F9 = Get Select/Sort criteria.

     C                   When      cfkey = F9
     C                   ExSr      getcriteria1
     C                   if        cfkey = Enter
     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1d
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1
     C                   endif
     C                   eval      cfkey = Enter

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
     *  bldschead - Build screen heading
     *----------------------------------------------------------------

     C     bldschead     BegSr

     C                   Eval      schead = ' '

     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1h
     C                   ExSr      sqlprep

     * Process the records in the SQL cursor until the return not = 0

     C                   Do        2

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
     C+      INTO :ohwhse,:ohrte, :ohord, :ohcnam
     C/END-EXEC

     * If record was found, build line. Otherwise, get out.

     C                   if        sqlstt = '00000'

     C                   select
     C                   when      schead = ' '
     C                   eval      schead = 'Ord# '
     C                                    + %trim(%editc(w1ord#:'3'))
     C                                    + ' - '
     C                                    + %trim(ohcnam)
     C                   other
     C                   eval      schead = 'Ord# '
     C                                    + %trim(%editc(w1ord#:'3'))
     C                                    + ' - '
     C                                    + '* Multiple Header Recs Found *'
     C                   endsl

     C                   else
     C                   leave
     C                   endIf

     C                   endDo

     C                   if        schead = ' '
     C                   eval      ohwhse = w1whse
     C                   eval      ohord  = w1ord#
     C                   eval      schead = 'Ord# '
     C                                    + %trim(%editc(w1ord#:'3'))
     C                                    + ' - '
     C                                    + '* Not on File *'
     C                   endIf

     C                   exsr      centerschead

     C                   EndSr

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

     C                   eval      sflhead1 = ' '
     C                   eval      sflhead2 = ' '

     C                   select

     C                   when      sortorder1 = 'SEQ'
     C                   eval      sflhead1 = %subst(blanks:1:43)
     C                                      + 'Quantity'
     C                                      + %subst(blanks:1:16)
     C                                      + 'Quantity'
     C                   eval      sflhead2 = @hu + 'Seq #'
     C                                      + @hu + 'Item'
     C                                      + %subst(blanks:1:31)
     C                                      + @hu + 'Ordered   '
     C                                      + @hu + 'Slot        '
     C                                      + @hu + 'Picked  ' + @n

     C                   when      sortorder1 = 'ITEM'
     C                   eval      sflhead1 = %subst(blanks:1:43)
     C                                      + 'Quantity'
     C                                      + %subst(blanks:1:16)
     C                                      + 'Quantity'
     C                   eval      sflhead2 = @hu + 'Item'
     C                                      + %subst(blanks:1:31)
     C                                      + @hu + 'Seq #'
     C                                      + @hu + 'Ordered   '
     C                                      + @hu + 'Slot        '
     C                                      + @hu + 'Picked  ' + @n

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  createline1- Create subfile display line
     *----------------------------------------------------------------

     C     createline1   BegSr

     *  Create item description display

     C                   eval      itemdesc = %trim(oditem) + ' - '
     C                                      + %trim(itdesc)

     *  Create order quantity display

     C                   eval      orderqty = ' '
     C                   if        odqor1 <> 0
     C                   eval      orderqty = %trim(%editc(odqor1:'L'))
     C                                      + ' ' + itum1
     C                   endif

     C                   if        odqor2 <> 0
     C                   if        orderqty = ' '
     C                   eval      orderqty = %trim(%editc(odqor2:'L'))
     C                                      + ' ' + itum2
     C                   else
     C                   eval      orderqty = %trimr(orderqty) + '.'
     C                                      + %trim(%editc(odqor2:'L'))
     C                                      + ' ' + itum2
     C                   endif
     C                   endif

     C                   if        odqor3 <> 0
     C                   if        orderqty = ' '
     C                   eval      orderqty = %trim(%editc(odqor3:'L'))
     C                                      + ' ' + itum3
     C                   else
     C                   eval      orderqty = %trimr(orderqty) + '.'
     C                                      + %trim(%editc(odqor3:'L'))
     C                                      + ' ' + itum3
     C                   endif
     C                   endif

     *  Create picked quantity display

     C                   eval      pickqty = %trim(%editc(lbqpck:'L'))
     C                                      + ' ' + lbucod

     *  Save key fields

     C                   eval      h1seq  = odseq
     C                   eval      h1item = oditem
     C                   eval      h1lbl# = lblbl#

     *  Create subfile line

     C                   select

     C                   when      sortorder1 = 'SEQ'
     C                   eval      sflline = %editc(odseq:'3') + ' '
     C                                     + itemdesc +' '
     C                                     + orderqty + ' '
     C                                     + lbdisp + ' '
     C                                     + pickqty

     C                   when      sortorder1 = 'ITEM'
     C                   eval      sflline = itemdesc +' '
     C                                     + %editc(odseq:'3') + ' '
     C                                     + orderqty + ' '
     C                                     + lbdisp + ' '
     C                                     + pickqty


     C                   endsl

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

     *    Convert From date into CMD format.

     * Set sort order.

     C                   if        w1sort <> '1' and w1sort <> '2'
     C                   eval      w1sort = '1'
     C                   endif

     C                   select

     C                   when      w1sort = '1'
     C                   eval      sortorder1 = 'SEQ'
     C                   eval      Order1 = 'ODSEQ'
     C                   eval      Order2 = 'ODITEM'

     C                   other
     C                   eval      sortorder1 = 'ITEM'
     C                   eval      Order1 = 'ODITEM'
     C                   eval      Order2 = 'ODSEQ'

     C                   endsl

     C                   exsr      bldschead

     C     endgetc1      EndSr
