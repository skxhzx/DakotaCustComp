      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  EQ320      Equipment Check In/Out History
     *  26 February 2003
     *  Roxanne Harrison
     *
     *  Revisions
     *
417 A*    02/26/03  RH   4.17
     *      - Created.
417 A*    05/15/03  RH   4.17a
     *      - FIX: Change to read 16 rec for subfile, was reading 17
     *        and not displaying correctly.
417 b*    07/21/03  RH/DS 4.17b
     *      - Change to select records equipment type.
417 c*    07/23/03  RH/DS 4.17c
     *      - Change to sort records employee / date (sort order 3)
417 d*    07/24/03  RH    4.17d
     *      - Add existing work order to screen2.
417 e*    07/25/03  MLB   4.17e
     *      - Add code to change work # to character field.
500a *    09/14/05  RH    5.00a
     *      - ENH: Add meter field, EQUIPH file
     *      - Add indicator for meter field to handle "null" value if
     *        no record exists in EQUIPH file.
     *
530 A*    06/17/10  MLB  5.30
     *      - Fix: Revised SQLBUILD to include swap file names in From
     *        selection criteria. Program was issuing a 42972 SQLSTT
     *        error and no records were being displayed.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V4R4M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Feq320fm   cf   e             workstn usropn
     F                                     sfile(sfl1:rrn1)
     F                                     infds(info)
     Feq320pr   O    E             printer usropn
     F                                     oflind(*IN90)

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,f#eaflds
      /Copy qcopysrc,f#etflds
      /Copy qcopysrc,f#euflds
417b  /Copy qcopysrc,f#eqflds
417b  /Copy qcopysrc,f#ehflds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  SQL fields for screen 1
     *----------------------------------------------------------------

530 MD sqlfile1        c                   'EQUIP, EQUIPT'
530 DD*sqlfile1        c                   'EQUIPT, EQUIP'
500a D*sqlfile1        c                   'EQUIPT, EQUIP, EQUIPH'
     D sqlfields1      c                   'ETWHSE,ETTRN#,ETCODE,ETEMP#,-
417b D                                      ETODTS, ETIDTS, ETOXFL, ETIXFL,-
500a D                                      EQTYPE, EHMETR'
500a D*                                     EQTYPE'

     D fetchds1        ds
     D   #etwhse                           like(etwhse)
     D   #ettrn#                           like(ettrn#)
     D   #etcode                           like(etcode)
     D   #etemp#                           like(etemp#)
     D   #dtso                             like(etodts)
     D   #dtsi                             like(etidts)
     D   #etoxfl                           like(etoxfl)
     D   #etixfl                           like(etixfl)
417b D   #eqtype                           like(eqtype)
500a D   #ehmetr                           like(ehmetr)
500a D   #ehmetri                     2b 0

     *----------------------------------------------------------------
     *  SQL fields for screen 2
     *----------------------------------------------------------------

     D sqlfile2        c                   'EQUIPA'
     D sqlfields2      c                   'EAIO,EASEQ#,EAANSR,EAEXCP,-
     D                                     EAWRK#,EUQSTN'

     *  NOTE: "fetchds2" is not used in the sql fetch statment.
     *        Since outer joins are used the fields needed to be
     *        individually coded along with the necessary indicators.

     D fetchds2        ds
     D   #eaio2                            like(eaio)
     D   #easeq#2                          like(easeq#)
     D   #eaansr2                          like(eaansr)
     D   #eaexcp2                          like(eaexcp)
     D   #eawrk#2                          like(eawrk#)
     D   #euqstn2                          like(euqstn)
     D   #euqstn2i                    2b 0

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D noon            s               t   inz(t'12.00.00')

     D currtimestamp   s               z

     D $fromdate       s               d
     D $todate         s               d

     D datestamp       s               d
     D timestamp       s               t

     D datedsp         s              8
     D timedsp         s              8

     D dteodsp         s              8
     D timodsp         s              8

     D dteidsp         s              8
     D timidsp         s              8

     D nodate          s               d   inz(d'0001-01-01')

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants for attention key indicator byte
     *----------------------------------------------------------------

     D*F3              c                   const(X'33')
     D*F4              c                   const(X'34')
     D*F9              c                   const(X'39')
     D*F12             c                   const(X'3C')
     D*F21             c                   const(X'B9')

     D*Enter           c                   const(X'F1')
     D*PageDown        c                   const(X'F5')

     *----------------------------------------------------------------
     *  Constants for screen attributes
     *----------------------------------------------------------------

415aAD @attrib         s              1    inz(' ')

     D @n              c                   const(X'20')
     D @h              c                   const(X'22')
     D @u              c                   const(X'24')
     D @hu             c                   const(X'26')

     D @red            c                   const(X'28')

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

415aAD blanks          s            100    inz(' ')
417a D*SubfilePage     c                   Const(17)
417a D SubfilePage     c                   Const(16)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D inzscreen1      s               n
     D lastcode        s                   like(etcode)
417c D lastemp#        s                   like(etemp#)
     D lastrrn         s                   like(rrn1)
     D leftjoin        s             80a   inz(' ')
     D oldhead         s                   like(schead)
     D oldkey          s                   like(sckey)
     D oldname         s                   like(scrname)
     D oldopt          s                   like(scopt)
     D optiontaken     s             10    inz(' ')
     D orderby         s             50a   inz(' ')
     D printflag       s               n
415aAD sc1order1       s             10    inz(' ')
415aAD sc1order2       s             10    inz(' ')
415aAD sc2order1       s             20    inz(' ')
415aAD sc2order2       s             20    inz(' ')
415aAD scheadlen       s              3  0 inz(0)
415aAD scpad           s              3  0 inz(0)
415aAD sortorder1      s             10    inz(' ')
415aAD sortorder2      s             10    inz(' ')
415aAD*sortorder3      s             10    inz(' ')

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1whse                 1      3  0
     D  h1trn#                 4     10  0
     D  h1code                11     16
     D  h1io                  17     17
     D  h1mdyo                18     25
     D  h1timo                26     33
     D  h1mdyi                34     41
     D  h1timi                42     49

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Error message variables
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
415aAD $msgf           s             10    inz(' ')
     D #msgid          s              7
     D #msgtp          s              7
     D #msgdt          s            128

     D $mdt            ds
     D  errmsg                 1     50

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd    *DISPLAY - Display list.
     *               *PRINT   - Print list.
     *      $pwhse   Warehouse
417b *      $ptype   Equipment type or *ALL
     *      $pcode   Equipment code or *ALL
     *      $pfrom   From date (MMDDYY)
     *      $pto     To date (MMDDYY)
     *      $psort   Sort order ('1', '2', '3')
     *      $pdev    Printer device code.
     *      $pform   Printer form.
     *      NOTE: Only $ptype OR $pcode can have a value.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhsea           3
417b C                   parm                    $ptype            6
     C                   parm                    $pcode            6
     C                   parm                    $pfrom            6
     C                   parm                    $pto              6
     C                   parm                    $psort            1
     C                   parm                    $pdev            10
     C                   parm                    $pform           10


     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C                   time                    currtimestamp
     C                   move      currtimestamp datestamp

     *  Establish SQL connection.

     C                   exsr      sqlconnect

     *  Initialize selection/sort fields.

     C                   move      $pwhsea       w1whse
417b C                   eval      w1type = $ptype
     C                   eval      w1code = $pcode
     C                   move      $pfrom        w1from
     C                   move      $pto          w1to
     C                   eval      w1sort = $psort

     C                   eval      inzscreen1 = *on
     C                   exsr      getcriteria1

     *  Initialize print fields.

     C                   eval      wpdev  = $pdev
     C                   eval      wpform = $pform

     *  Process main screen.

     C                   if        $pcmd = '*PRINT'
     C                   exsr      printit
     C                   else
     C                   exsr      screen1
     C                   endif


     *  Disconnect SQL connection.

     C                   exsr      sqldisconnect

     * Bye, Bye.

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
     *  sqlbldstmt1 - Build SQL statment for screen 1
     *----------------------------------------------------------------

     C     sqlbldstmt1   BegSr

     * Create select statement.

     *   Create "From" clause.

     C                   eval      sqlfrom = 'FROM ' + sqlfile1

     *   Create "Where" clause.

     C                   eval      sqlwhere = 'WHERE '
417b C                               + 'EQWHSE=ETWHSE '
417b C                               + 'AND EQCODE=ETCODE '
417b C                               + 'AND ETWHSE=' + %editc(w1whse:'P')
500a
500a *   Create "left outer join" clause
500a C                   eval      sqljoin = 'LEFT OUTER JOIN EQUIPH '
500a C                                     + 'ON EHTRN#=ETTRN#'


417b C**                 if        w1code <> '*ALL'
417b C                   if        w1code <> '*ALL' and w1code <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND ETCODE='
     C                               +    sq + %trim(w1code) + sq
     C                   endif

417b C                   if        w1type <> '*ALL' and w1type <> ' '
417b C                   eval      sqlwhere = %trim(sqlwhere) + ' '
417b C                               + 'AND EQTYPE='
417b C                               +    sq + %trim(w1type) + sq
417b C                   endif

     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND DATE(ETODTS)>='
     C                               +      sq + %char($fromdate) + sq + ' '
     C                               + 'AND DATE(ETODTS)<='
     C                               +      sq + %char($todate) + sq + ' '

     *   Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(sqlfields1) + ' '
     C                                     + %trimr(sqlfrom) + ' '
     C                                     + %trimr(sqljoin) + ' '
     C                                     + %trimr(sqlwhere) + ' '

     * Add "Order By" clause.

     C                   Eval      SqlStmt = %trim(SqlStmt) + ' '
     C                                     + 'ORDER BY '
     C                                      + %trim(sc1order1) + ','
     C                                      + %trim(sc1order2)

     * Create list heading

     C                   exsr      createhead1

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlbldstmt2 - Build SQL statment for screen 2
     *----------------------------------------------------------------

     C     sqlbldstmt2   BegSr

     *   Create "From" clause.

     C                   eval      sqlfrom = 'FROM ' + sqlfile2

     *   Create "Where" clause.

     C                   eval      sqlwhere = 'WHERE '
     C                               + 'EAWHSE='
     C                               +   %trim(%editc(h1whse:'P')) + ' '
     C                               + 'AND EATRN#='
     C                               +   %trim(%editc(h1trn#:'P')) + ' '

     *   Create "left outer join" clause

     C                   eval      sqljoin = 'LEFT OUTER JOIN EQUIPQ '
     C                                     + 'ON EUSEQ#=EASEQ#'

     *   Create "Order By" clause.

     C                   eval      sqlorder = 'ORDER BY '
     C                                      + 'EAIO DESC, '
     C                                      + 'EASEQ#'

     *   Create SQL statement

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(sqlfields2) + ' '
     C                                     + %trimr(sqlfrom) + ' '
     C                                     + %trimr(sqljoin) + ' '
     C                                     + %trimr(sqlwhere) + ' '
     C                                     + sqlorder

     * Create list heading

     C                   exsr      createhead2

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlconnect - Establish SQL connection.
     *----------------------------------------------------------------

     C     sqlconnect    BegSr

     * Establish the connection to the remote machine. The -842 return
     * code indicates that the connection is already established. If
     * you want to connect to the local machine, use CONNECT RESET.

     C/EXEC SQL
     C+ CONNECT RESET
     C/END-EXEC

     *--- DEBUG ---
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlprep - Prepare SQL cursor
     *
     *    Note: This routine must come before any other routine
     *          using an SQL statement because it declares the
     *          SQL Cursor being used.
     *----------------------------------------------------------------

     C     sqlprep       BegSr

     * Prepare the SQL statement for validation, since the program was
     * compiled with DLYPRP (*YES), it will wait until it is used before
     * it prepares the cursor.

     C/EXEC SQL
     C+   PREPARE sel FROM :SqlStmt
     C/END-EXEC
     C                   eval      sqlstt = sqlstt
      *
      * Declare the SQL cursor to hold the data retrieved from the SELECT
      *
     C/EXEC SQL
     C+ DECLARE MYCSR DYNAMIC SCROLL CURSOR FOR SEL
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

     * Close the SQL cursor after all processing is complete.

     C/EXEC SQL
     C+   CLOSE mycsr
     C/END-EXEC

     *--- DEBUG ---
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   Endsr

     *----------------------------------------------------------------
     *  sqldisconnect - Disconnect SQL connection
     *----------------------------------------------------------------

     C     sqldisconnect BegSr

     C/EXEC SQL
     C+   DISCONNECT CURRENT
     C/END-EXEC

     *--- DEBUG ---
     C                   if        sqlstt <> '00000'
     C                   endif

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

     * Process the records in the SQL cursor until the return not = 0

     C                   Do        SubfilePage

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
500aDC*      INTO :fetchds1
500aMC+      INTO :#etwhse,:#ettrn#,:#etcode,:#etemp#,
500aMC+           :#dtso,:#dtsi,:#etoxfl,:#etixfl,
500aMC+           :#eqtype,:#ehmetr :#ehmetri
     C/END-EXEC

     C                   If        sqlstt = '00000'
     C                   exsr      createline1
     C                   Eval      rrn1  = rrn1  + 1
     C                   Eval      option = ' '
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
     *  sflbld2 - Build the subfile for item detail
     *----------------------------------------------------------------

     C     sflbld2       BegSr

     C                   Eval      rrn1 = Lastrrn

     * Process the records in the SQL cursor until the return not = 0

     C                   Do        SubfilePage

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
     C+      INTO :#eaio2,:#easeq#2,:#eaansr2,:#eaexcp2,
417eMC+           :#eawrk#2,:#euqstn2 :#euqstn2i
     C/END-EXEC

     C                   If        sqlstt = '00000'
     C                   exsr      createline2
     C                   Eval      rrn1  = rrn1  + 1
     C                   Eval      option = ' '
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

      * Clear the error message subfile

MSG MC                   exsr      zmcpmq

     C                   EndSr

     *----------------------------------------------------------------
     *  sfloption1 - Get entered option
     *----------------------------------------------------------------

     C     sfloption1    BegSr

     C                   Eval      optiontaken = *off
     C                   Eval      *in21 = *off

     C                   dow       forever = forever

     C                   readc     sfl1
     C                   if        %eof
     C                   leave
     C                   endif

     C                   select
     C                   when      %trim(option) = '12'
     C                   eval      optiontaken = 'Question'
     C                   leave
     C                   endsl

     C                   enddo

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

     *  Open screen file

     C                   open(e)   eq320fm
     C                   if        %error
     C                   endif
     C                   eval      #pgmq = #pgm

     *  Initialize some screen fields.

     C                   Eval      scrname = 'EQ320.01'
     C                   eval      scopt = '12=Questions'
     C                   eval      sckey = 'F3=Exit  '
     C                                   + 'F9=Select/Sort  '
     C                                   + 'F21=Print list  '
     C                                   + 'F12=Cancel'

     *  Do initial build and display of subfile.

     C                   exsr      sqlclean
     C                   exsr      sqlbldstmt1
     C                   exsr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1

     *  Process subfile until user wants to leave.

     C                   DoU       (cfkey = F3)

     C                   Write     fkey1
     C                   exsr      zmdmsg
     C                   ExFmt     sf1ctl
      *
     C                   Select

     *    Enter

     C                   when      cfkey = Enter
     C                   exsr      sfloption1
     C                   select
     C                   when      optiontaken = 'Question'
     C                   exsr      screen2
     C                   endsl
     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1

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

     *    F12 = Cancel

     C                   When      cfkey = F12
     C                   Leave

     *    F21 = Print list.

     C                   When      cfkey = F21
     C                   exsr      printit
     C                   if        cfkey = Enter
     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1
     C                   eval      errmsg = 'The list is printed'
     C                   exsr      zm0105
     C                   endif
     C                   eval      cfkey = Enter

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
     *  screen2 - Process screen 2
     *----------------------------------------------------------------

     C     screen2       BegSr

     *  Initialize screen fields.

     C                   Eval      oldname = scrname
     C                   Eval      oldhead = schead
     C                   Eval      oldopt  = scopt
     C                   Eval      oldkey  = sckey
     C                   Eval      scrname = 'EQ320.02'

     C                   eval      schead  = 'Id: '
     C                                     + %trim(h1code)
     C                                     + '  Date: '
     C                                     + %trim(h1mdyo)
     C                                     + '  Time: '
     C                                     + %trim(h1timo)

     C                   if        h1io = 'O'
     C                   eval      schead  = %trim(schead)
     C                                     + '  Type: Out'
     C                   else
     C                   eval      schead  = %trim(schead)
     C                                     + '  Type: In'
     C                   endif

     C                   exsr      centerschead

     C                   eval      scopt = ' '
     C                   eval      sckey = 'F3=Exit  '
     C                                   + 'F12=Cancel'

     C*******            eval      w2sort = '1'
     C                   eval      sortorder2 = 'EXCP'
     C                   Eval      sc2order1  = 'EAEXCP DESC'
     C                   Eval      sc2order2  = 'EASEQ#'

     *  Do initial build and display of subfile.

     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt2
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld2

     *  Process subfile until user wants to leave.

     C                   DoU       (cfkey = F3)

     C                   Write     fkey1
     C                   exsr      zmdmsg
     C                   ExFmt     sf1ctl

     C                   Select

     *    F12 = Cancel

     C                   When      cfkey = F12
     C                   Leave

     *    PageDown = More records

     C                   When      cfkey = PageDown
     C                   ExSr      sflbld2
      *
     C                   EndSl
      *
     C                   EndDo

     C                   eval      scrname = oldname
     C                   eval      schead  = oldhead
     C                   eval      scopt   = oldopt
     C                   eval      sckey   = oldkey
     C                   eval      cfkey = Enter
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                Print Processing Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  PrintIt - Print list
     *----------------------------------------------------------------

     C     printit       BegSr
     C                   eval      oldhead = schead

     * Display window to get device and form to use (Only in *DISPLAY mode)

     C                   if        $pcmd = '*DISPLAY'

     C                   exfmt     windowp

     C                   if        cfkey = F3 or cfkey = F12
     C                   goto      endprintit
     C                   endif

     C                   endif

     *  Override printer file

     C                   if        wpdev = ' '
     C                   eval      wpdev = '*JOB'
     C                   endif

     C                   if        wpform = ' '
     C                   eval      wpform = '*STD'
     C                   endif

     C                   eval      qcmd = 'OVRPRTF '
     C                                  + 'FILE(EQ320PR) '
     C                                  + 'OUTQ(*DEV) '
     C                                  + 'DEV(' + %trim(wpdev) + ') '
     C                                  + 'FORMTYPE(' + %trim(wpform) + ') '

     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5

     *  Open printer file

     C                   open(e)   eq320pr
     C                   if        %error
     C                   endif

     *  Prepare SQL statment.

     C                   exsr      sqlclean
     C                   exsr      sqlbldstmt1
     C                   exsr      sqlprep

     *  Print list.

     C                   exsr      printlist

     *  Print footer

     C                   write     foot1

     *  Close printer file

     C                   close(e)  eq320pr
     C                   if        %error
     C                   endif

     *  Delete override for printer file.

     C                   eval      qcmd = 'DLTOVR '
     C                                  + 'FILE(EQ320PR) '

     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5

     *  Cleanup and leave printing

     C                   ExSr      sqlclean
     C                   eval      schead = oldhead
     C                   eval      cfkey = Enter

     C     endprintit    endsr

     *----------------------------------------------------------------
     *  printlist - Print list
     *----------------------------------------------------------------

     C     printlist     BegSr

     * Process the records in the SQL cursor until the return not = 0

     C                   eval      printflag = *off
     C                   eval      lastcode = *hival
417c C                   eval      lastemp# = *hival
     C                   eval      *in90 = *on
     C                   eval      *in91 = *off

     C                   dow       forever = forever

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
500aDC*      INTO :fetchds1
500aMC+      INTO :#etwhse,:#ettrn#,:#etcode,:#etemp#,
500aMC+           :#dtso,:#dtsi,:#etoxfl,:#etixfl,
500aMC+           :#eqtype,:#ehmetr :#ehmetri
     C/END-EXEC

     C                   if        sqlstt = '00000'
     C                   exsr      printline
     C                   eval      printflag = *on
     C                   else
     C                   leave
     C                   endif

     C                   enddo

     * If no records were printed, Print heading.

     C                   if        not printflag
     C                   exsr      printhead
     C                   endif

     C                   endSr

     *----------------------------------------------------------------
     *  printhead - Print heading line.
     *----------------------------------------------------------------

     C     printhead     BegSr

     *  Create heading.

417c C                   select
     C                   when      sortorder1 = 'DATE'
     C                   eval      schead  = @u + 'Id: ' + %trim($pcode)
     C                   when      sortorder1 = 'CODE'
     C                   eval      schead  = @u + 'Id: ' + %trim(#etcode)
417c C                   other
417c C                   eval      schead  = @u + 'Id: ' + %trim(#etcode)
417c C                   endsl

     C                   eval      schead  = %trim(schead)
     C                                     + '  Range: '
     C                                     + %trim(%editc(w1from:'Y'))
     C                                     + ' thru '
     C                                     + %trim(%editc(w1to:'Y'))

     C                   exsr      centerschead

     *  Print report heading

     C                   write     head1
     C                   if        *in91
     C                   write     head2
     C                   endif

     *  Print column heading

417c C*                  if        sortorder1 = 'DATE'
417c C                   select
417c C                   when      sortorder1 = 'DATE'
     C                   write     columns1
417c C                   when      sortorder1 = 'CODE'
     C                   write     columns2
417c C                   other
417c C                   write     columns3
     C                   endsl

     C                   eval      *in90 = *off
     C                   eval      *in91 = *on
     C                   endsr

     *----------------------------------------------------------------
     *  printline - Print detail line.
     *----------------------------------------------------------------

     C     printline     BegSr

     *  See if heading needs to be printed.

     C                   if        *in90 or
     C                             sortorder1='CODE' and #etcode<>lastcode or
417c C                             sortorder1='EMPL' and #etemp#<>lastemp#
     C                   exsr      printhead
     C                   eval      lastcode = #etcode
417c C                   eval      lastemp# = #etemp#
     C                   endif

500a * Initailize outer join fields if necessary.

500a C                   if        #ehmetri < 0
500a C                   eval      #ehmetr = 0
500a C                   endif

     *  Convert check out datestamp to date/time output fields.

     C                   move      #dtso         datestamp
     C                   move      #dtso         timestamp

     C**   *MDY/         movel     datestamp     datedsp
     C                   if        datestamp <> nodate
     C     *MDY/         movel     datestamp     dteodsp

     C                   if        timestamp < noon
     C**                 eval      timedsp = %subst(%char(timestamp):1:5)
     C                   eval      timodsp = %subst(%char(timestamp):1:5)
     C                                     + ' am'
     C                   else
     C     timestamp     subdur    12:*H         timestamp
     C**                 eval      timedsp = %subst(%char(timestamp):1:5)
     C                   eval      timodsp = %subst(%char(timestamp):1:5)
     C                                     + ' pm'
     C                   endif
     C                   else
     C                   eval      dteodsp = ' '
     C                   eval      timodsp = ' '
     C                   endif

     *  Convert check in datestamp to date/time output fields.

     C                   move      #dtsi         datestamp
     C                   move      #dtsi         timestamp

     C**   *MDY/         movel     datestamp     datedsp
     C                   if        datestamp <> nodate
     C     *MDY/         movel     datestamp     dteidsp

     C                   if        timestamp < noon
     C**                 eval      timedsp = %subst(%char(timestamp):1:5)
     C                   eval      timidsp = %subst(%char(timestamp):1:5)
     C                                     + ' am'
     C                   else
     C     timestamp     subdur    12:*H         timestamp
     C**                 eval      timedsp = %subst(%char(timestamp):1:5)
     C                   eval      timidsp = %subst(%char(timestamp):1:5)
     C                                     + ' pm'
     C                   endif
     C                   else
     C                   eval      dteidsp = ' '
     C                   eval      timidsp = ' '
     C                   endif
     *  Change value for display.
     C                   if        #etoxfl = '1'
     C                   eval      #etoxfl = 'Y'
     C                   else
     C                   eval      #etoxfl = ' '
     C                   endif
     C                   if        #etixfl = '1'
     C                   eval      #etixfl = 'Y'
     C                   else
     C                   eval      #etixfl = ' '
     C                   endif


     *  Print detail line

417c C                   select
     C                   when      sortorder1 = 'DATE'
     C                   write     detail1
     C                   when      sortorder1 = 'CODE'
     C                   write     detail2
     C                   other
417c C                   write     detail3
     C                   endsl

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

     C                   select

     C                   when      sortorder1 = 'DATE'
     C                   eval      sflhead1=       '    ' + @n
     C                                      + @h + '----- '
     C                                      + @h + 'Check Out '
     C                                      + @h + '-----'
     C                                      + @h + ' ----- '
     C                                      + @h + 'Check In '
     C                                      + @h + '------'
     C                                           + '      ' + @n
     C                                           + '     ' + @n
     C                   eval      sflhead = @hu + 'Opt' + @n
     C                                     + @hu + '  Date  ' + @n
     C                                     + @hu + '  Time  ' + @n
     C                                     + @hu + 'Exc' + @n
     C                                     + @hu + '  Date  ' + @n
     C                                     + @hu + '  Time  ' + @n
     C                                     + @hu + 'Exc' + @n
     C                                     + @hu + 'Equip ' + @n
     C                                     + @hu + 'Emp#  ' + @n
500a C                                     + @hu + 'Meter  ' + @n
     C*                                    + @hu + 'I/O' + @n
     C*                                    + @hu + 'Question'
     C*                                    + '                 ' + @n
     C*                                    + @hu + 'Answer' + @n

     C                   when      sortorder1 = 'CODE'
     C                   eval      sflhead1=       '    ' + @n
     C                                      + @h + '      ' + @n
     C                                      + @h + '     ' + @n
     C                                      + @h + '----- '
     C                                      + @h + 'Check Out '
     C                                      + @h + '-----'
     C                                      + @h + ' ----- '
     C                                      + @h + 'Check In '
     C                                      + @h + '------'
     C                   eval      sflhead = @hu + 'Opt' + @n
     C                                     + @hu + 'Equip ' + @n
     C                                     + @hu + 'Emp# ' + @n
     C                                     + @hu + '  Date  ' + @n
     C                                     + @hu + '  Time  ' + @n
500a C                                     + @hu + 'Exc' + @n
500aDC**                                   + @hu + 'Excpt' + @n
     C                                     + @hu + '  Date  ' + @n
     C                                     + @hu + '  Time  ' + @n
500a C                                     + @hu + 'Exc' + @n
500a C                                     + @hu + 'Meter  ' + @n
500aDC**                                   + @hu + 'Excpt' + @n

417c C                   when      sortorder1 = 'EMPL'
417c C                   eval      sflhead1=       '    ' + @n
417c C                                      + @h + '     ' + @n
417c C                                      + @h + '      ' + @n
500aDC**                                    + @h + '------ '
500a C                                      + @h + '----- '
417c C                                      + @h + 'Check Out '
500a C                                      + @h + '-----'
500aDC**                                    + @h + '------'
500a C                                      + @h + ' ----- '
500aDC**                                    + @h + ' ------ '
417c C                                      + @h + 'Check In '
500a C                                      + @h + '------'
500aDC**                                    + @h + '-------'
417c C                   eval      sflhead = @hu + 'Opt' + @n
417c C                                     + @hu + 'Emp# ' + @n
417c C                                     + @hu + 'Equip ' + @n
417c C                                     + @hu + '  Date  ' + @n
417c C                                     + @hu + '  Time  ' + @n
500a C                                     + @hu + 'Exc' + @n
500aDC**                                   + @hu + 'Excpt' + @n
417c C                                     + @hu + '  Date  ' + @n
417c C                                     + @hu + '  Time  ' + @n
500a C                                     + @hu + 'Exc' + @n
500a C                                     + @hu + 'Meter  ' + @n
500aDC**                                   + @hu + 'Excpt' + @n

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  createhead2 - Create subfile heading line for item detail
     *----------------------------------------------------------------

     C     createhead2   BegSr

     C                   eval      sflhead1=       '    ' + @n
     C                   eval      sflhead = @hu + 'Opt' + @n
     C                                     + @hu + 'Question'
     C                                     + '                      ' + @n
     C                                     + @hu + 'Answer' + @n
     C                                     + @hu + 'Except' + @n
417d C                                     + @hu + 'Work ord#' + @n

     C                   endsr

     *----------------------------------------------------------------
     *  createline1- Create subfile display line
     *----------------------------------------------------------------

     C     createline1   BegSr

500a * Initailize outer join fields if necessary.

500a C                   if        #ehmetri < 0
500a C                   eval      #ehmetr = 0
500a C                   endif
     *  Convert check out datestamp to date/time output fields.

     C                   move      #dtso         datestamp
     C                   move      #dtso         timestamp

     C**   *MDY/         movel     datestamp     datedsp
     C                   if        datestamp <> nodate
     C     *MDY/         movel     datestamp     dteodsp

     C                   if        timestamp < noon
     C                   eval      timodsp = %subst(%char(timestamp):1:5)
     C                                     + ' am'
     C                   else
     C     timestamp     subdur    12:*H         timestamp
     C                   eval      timodsp = %subst(%char(timestamp):1:5)
     C                                     + ' pm'
     C                   endif
     C                   else
     C                   eval      dteodsp = ' '
     C                   eval      timodsp = ' '
     C                   endif

     *  Convert check in datestamp to date/time output fields.

     C                   move      #dtsi         datestamp
     C                   move      #dtsi         timestamp

     C**   *MDY/         movel     datestamp     datedsp
     C                   if        datestamp <> nodate
     C     *MDY/         movel     datestamp     dteidsp

     C                   if        timestamp < noon
     C                   eval      timidsp = %subst(%char(timestamp):1:5)
     C                                     + ' am'
     C                   else
     C     timestamp     subdur    12:*H         timestamp
     C                   eval      timidsp = %subst(%char(timestamp):1:5)
     C                                     + ' pm'
     C                   endif
     C                   else
     C                   eval      dteidsp = ' '
     C                   eval      timidsp = ' '
     C                   endif
     *  Change value for display.
     C                   if        #etoxfl = '1'
     C                   eval      #etoxfl = 'Y'
     C                   else
     C                   eval      #etoxfl = ' '
     C                   endif
     C                   if        #etixfl = '1'
     C                   eval      #etixfl = 'Y'
     C                   else
     C                   eval      #etixfl = ' '
     C                   endif

     *  Create subfile line.

     C                   select

     C                   when      sortorder1 = 'DATE'
     C                   eval      h1whse = #etwhse
     C                   eval      h1trn# = #ettrn#
     C                   eval      h1code = #etcode
     C**                 eval      h1mdy  = datedsp
     C                   eval      h1mdyo = dteodsp
     C**                 eval      h1time = timedsp
     C                   eval      h1timo = timodsp
     C***                eval      h1io   = #eaio
     C                   eval      h1mdyi = dteidsp
     C                   eval      h1timi = timidsp

     C                   eval      sflline = '  '
     C**                                   + datedsp + '  '
     C                                     + dteodsp + '  '
     C                                     + timodsp + '  '
500a C                                     + ' ' + #etoxfl + '   '
500a C**                                   + ' ' + #etoxfl + '     '
     C                                     + dteidsp + '  '
     C                                     + timidsp + '  '
500a C                                     + ' ' + #etixfl + '   '
500a C**                                   + ' ' + #etixfl + '     '
     C                                     + #etcode + '  '
500a C                                     + %editc(#etemp#:'Z') + ' '
500aDC**                                   + %editc(#etemp#:'Z') + '  '
500a C                                     + %editc(#ehmetr:'Z') + '  '

     C                   when      sortorder1 = 'CODE'
     C                   eval      h1whse = #etwhse
     C                   eval      h1trn# = #ettrn#
     C                   eval      h1code = #etcode
     C                   eval      h1mdyo = dteodsp
     C                   eval      h1timo = timodsp
     C                   eval      h1mdyi = dteidsp
     C                   eval      h1timi = timidsp

     C                   eval      sflline = '  '
500aDC**                                   + #etcode + '  '
500a C                                     + #etcode + ' '
500aDC**                                   + %editc(#etemp#:'Z') + '  '
500a C                                     + %editc(#etemp#:'Z') + ' '
     C                                     + dteodsp + '  '
     C                                     + timodsp + '  '
500a C                                     + ' ' + #etoxfl + '   '
500aDC**                                   + ' ' + #etoxfl + '     '
     C                                     + dteidsp + '  '
     C                                     + timidsp + '  '
500a C                                     + ' ' + #etixfl + '   '
500aDC**                                   + ' ' + #etixfl + '     '
500a C                                     + %editc(#ehmetr:'Z') + '  '
     C***                                  + ' ' + #eaio + '   '
     C***                                  + %subst(#euqstn:1:25) + '  '
     C***                                  + '  ' + #eaansr + '  '

417c C                   when      sortorder1 = 'EMPL'
417c C                   eval      h1whse = #etwhse
417c C                   eval      h1trn# = #ettrn#
417c C                   eval      h1code = #etcode
417c C                   eval      h1mdyo = dteodsp
417c C                   eval      h1timo = timodsp
417c C                   eval      h1mdyi = dteidsp
417c C                   eval      h1timi = timidsp

417c C                   eval      sflline = '  '
417c C                                     + %editc(#etemp#:'Z') + '  '
500aDC**                                   + #etcode + '  '
500a C                                     + #etcode
417c C                                     + dteodsp + '  '
417c C                                     + timodsp + '  '
500aDC**                                   + ' ' + #etoxfl + '     '
500a C                                     + #etoxfl + '    '
417c C                                     + dteidsp + '  '
417c C                                     + timidsp + '  '
500aDC**                                   + ' ' + #etixfl + '     '
500a C                                     + #etixfl + '    '
500a C                                     + %editc(#ehmetr:'Z') + '  '

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  createline2 - Create subfile display line for item detail
     *----------------------------------------------------------------

     C     createline2   BegSr

     * Initailize outer join fields if necessary.

     C                   if        #euqstn2i < 0
     C                   eval      #euqstn2 = '??? Question #'
     C                                     + %editc(#easeq#2:'P') + '  '
     C                                     + 'Not On File ???'
     C                   endif

     * Color exceptions red.

     C                   if        #eaexcp2 = '1'
     C                   eval      @attrib = @red
     C                   else
     C                   eval      @attrib = ' '
     C                   endif

     *  Change value for display.
     C                   if        #eaexcp2 = '1'
     C                   eval      #eaexcp2 = 'Y'
     C                   else
     C                   eval      #eaexcp2 = ' '
     C                   endif
     * Create subfile line.

     C                   eval      sflline = @attrib + ' '
     C                                     + #euqstn2 + '  '
     C                                     + '  ' + #eaansr2 + '  '
     C                                     + '     ' + #eaexcp2 + '  '
417eMC                                     + '     ' + %char(#eawrk#2) + '  '

     C                   endsr

     *----------------------------------------------------------------
     *  getcriteria1 - Prompt user for select and sort criteria
     *----------------------------------------------------------------

     C     getcriteria1  BegSr
     C                   move      currtimestamp datestamp

     * Display window.

     C                   if        not inzscreen1

     C                   ExFmt     window1

     C                   if        cfkey = F3 or cfkey = F12
     C                   goto      endgetc1
     C                   endif

     C                   endif

     * Set selection criteria.

     *    Convert From date into date type field.
     *    If date is invalid, set to today's date.

     C                   if        w1from = 0
     C                   eval      $fromdate = *loval
     C                   else
     C     *MDY          test(de)                w1from
     C                   if        %error
     C                   eval      $fromdate = datestamp
     C     *MDY          movel     $fromdate     w1from
     C                   else
     C     *MDY          move      w1from        $fromdate
     C                   endif
     C                   endif

     *    Convert To date into date type field.
     *    If date is invalid, set to today's date.

     C                   if        w1to = 999999
     C                   eval      $todate = *hival
     C                   else
     C     *MDY          test(de)                w1to
     C                   if        %error
     C                   eval      $todate = datestamp
     C     *MDY          movel     $todate       w1to
     C                   else
     C     *MDY          move      w1to          $todate
     C                   endif
     C                   endif

     *    Create screen heading.

     C                   eval      schead  = %trim(%editc(w1from:'Y'))
     C                                     + ' thru '
     C                                     + %trim(%editc(w1to:'Y'))
     C                   exsr      centerschead

     * Set sort order.

417c C*                  if        w1sort <> '1' and w1sort <> '2'
417c C                   if        w1sort <> '1' and w1sort <> '2'
417c C                             and w1sort <> '3'
     C                   eval      w1sort = '1'
     C                   endif

     C                   select

     C                   when      w1sort = '1'
     C                   eval      sortorder1 = 'DATE'
     C                   eval      sc1order1 = 'ETODTS'
     C                   eval      sc1order2 = 'ETCODE'

     C                   when      w1sort = '2'
     C                   eval      sortorder1 = 'CODE'
     C                   eval      sc1order1 = 'ETCODE'
     C                   eval      sc1order2 = 'ETODTS'

417c C                   other
417c C                   eval      sortorder1 = 'EMPL'
417c C                   eval      sc1order1 = 'ETEMP#'
417c C                   eval      sc1order2 = 'ETODTS'

     C                   endsl

     C                   eval      inzscreen1 = *off
     C     endgetc1      EndSr

     *---------------------------------------------------------------
     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *    ZMCPMQ  Clear program message queue.
     *---------------------------------------------------------------

     C     zmcpmq        begsr
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr

     *---------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *---------------------------------------------------------------

     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   write     msgctl
     C                   endsr

     *---------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *---------------------------------------------------------------

     C     zmpmsg        begsr

 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif

     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk

     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks

     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *---------------------------------------------------------------
     *    PIR0105 - Generic error message
     *---------------------------------------------------------------

     C     zm0105        begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr
