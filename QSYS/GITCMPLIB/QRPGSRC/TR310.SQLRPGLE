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
      *               RDB    = Machine name that you will connect to.
      *               DLYPRP = *YES
      *               SQLPKG = The name & library that you want to
      *                        use for the package. This will put the
      *                        package on the RDB machine that you
      *                        specify.
      *****************************************************************
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TR310    View TRAX log
     *  07 July 2010
     *  Retha Davis
     *
     *  Revisions
     *
530 A*    07/07/10  RBD  5.30
     *      - Created.
     *
640 A*    01/25/12  RBD  6.40
     *      - Corrected placement of error code.
     *
640aA*    02/13/12  RBD  6.40a
     *      - Changed scrn format name to TR31002.
     *      - Fixed scrolling, was not working properly.
     *      - At pgm startup go to sort/select screen rather than
     *        command prompt where nothing was edited.
650aA*    01/22/13  LMC  6.50a
     *      - Fix: If an invalid option was selected program was
     *      getting a session or device error.
     *
650bA*    08/26/13  RBD  6.50b
     *      - Recompiled, TTLOG file changed.
     *
710aA*    11/18/17  DAS  7.10a
     *      - Revised to get IFS folder from *TRAX2 options
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    04/04/17  RBD/GJA   JSLa
     *      - Format URL for CLOUD
     *      - Add client code
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

640aDF*tr31001   cf   e             workstn
640aMFtr31002   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl2:rrn1)
     F                                     infds(info)
     Fttlog     if   e           k disk
710aAFoptions   if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *
JSLaA /COPY QCOPYSRC,ID#jsl
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D qcmdexc         pr                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants for attention key indicator byte
     *----------------------------------------------------------------

     D Rollup          C                   const(X'F5')
     D Rolldn          C                   const(X'F4')

     *----------------------------------------------------------------
     *  Constants for screen attributes
     *----------------------------------------------------------------

     D @n              C                   const(X'20')
     D @h              C                   const(X'22')
     D @u              C                   const(X'24')
     D @hu             C                   const(X'26')

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')
     D SubfilePage     C                   Const(16)

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D f#trxflds     E ds                  extname(ttlog)
     D f#rtehed      E ds                  extname(rtehed)
     D f#ordh        E ds                  extname(ordh)

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
     D sqlfunc         s            200a   inz(' ')

     *----------------------------------------------------------------
     *  SQL fetch fields
     *----------------------------------------------------------------

     D sqlfile         c                   'TTLOG'
     D sqlfields       c                   'ttlWhse,ttlRtid,ttlTry,-
     D                                      ttlRte,ttlStatus,-
     D                                      ttlFileSnd,ttlErrCode,ttlErrMsg,-
     D                                      ttlTs1,ttlTs2,ttlPgm1,-
     D                                      ttlUser1,-
     D                                      ttlJob1,ttlNbr1,-
     D                                      ttlTs3,ttlPgm3,-
     D                                      ttlUser3,ttlJob3,ttlNbr3'

     D fetchds         ds
     D   #ttlWhse                          like(ttlwhse)
     D   #ttlRtid                          like(ttlrtid)
     D   #ttlTry                           like(ttltry)
     D   #ttlRte                           like(ttlrte)
     D   #ttlStatus                        like(ttlstatus)
     D   #ttlFileSnd                       like(ttlfilesnd)
     D   #ttlErrCode                       like(ttlerrcode)
     D   #ttlErrMsg                        like(ttlerrmsg)
     D   #ttlTS1                           like(ttlTS1)
     D   #ttlTS2                           like(ttlTS2)
     D   #ttlPgm1                          like(ttlPgm1)
     D   #ttlUser1                         like(ttlUser1)
     D   #ttlJob1                          like(ttlJob1)
     D   #ttlNbr1                          like(ttlNbr1)
     D   #ttlTS3                           like(ttlTS3)
     D   #ttlPgm3                          like(ttlPgm3)
     D   #ttlUser3                         like(ttlUser3)
     D   #ttlJob3                          like(ttlJob3)
     D   #ttlNbr3                          like(ttlNbr3)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $iwhse          s              3  0
     D $iRtid          s              5
     D $iRte           s              5
     D $iDate          s              6  0
     D $iDwnUp         s              1
     D $iErrOnly       s              1

     D $pwhse          s                   like($iwhse)
     D $prtid          s                   like($irtid)
     D $prte           s                   like($irte)
     D $pdate          s                   like($idate)
     D $pDwnUp         s                   like($iDwnUp)
     D $perronly       s                   like($ierronly)

     D $lcmd           s              8
     D $lwhse          s                   like(ttlwhse)
     D $lrtid          s                   like(ttlrtid)
     D $ltry           s                   like(ttltry)
     D $lstmf          s                   like(ttlfilesnd)
     D $lpgm           s             10
     D $lrtn           s              8
     D $lerm           s             60

     D rReturn         s             10
     D rMsg            s             60

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $code           s              2    inz(' ')
     D $count          s              8b 0 inz(0)
     D append1         s              1
     D append5         s              5
     D curview         s              1  0 inz(1)
710aAD dirLen          s              3  0
     D eorder1         s             20    inz(' ')
     D eorder2         s             20    inz(' ')
     D first           s               n
     D groupby         S            100a   inz(' ')
     D groupfields     S            100a   inz(' ')
     D iorder1         s             20    inz(' ')
     D iorder2         s             20    inz(' ')
     D lastrrn         s                   like(rrn1)
     D maxview         s              1  0 inz(2)
     D newordpos       s              3  0 inz(0)
     D oldhead         s                   like(schead)
     D oldname         s                   like(scrname)
     D oldopt          s                   like(scopt1)
     D optiontaken     s             10    inz(' ')
     D order1          s             10    inz(' ')
     D order2          s             10    inz(' ')
     D orderby         S            100a   inz(' ')
     D orderfield      s             10    inz(' ')
     D orderposition   s              3  0 inz(0)
     D path            S             32a   inz(' ')
     D posfld          s              5    inz(' ')
     D recpos          s                   like(rrn1)
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')
     D sortorder2      s             10    inz(' ')
     D sortorder3      s             10    inz(' ')
     D sv_w1rte        s                   like(w1rte)
     D svrte           s                   like(ttlrte)
     D w1ts            s               z
     D cmd             s            200
     D stmf            s                   like(ttlfilesnd)
     D pathLen         s              3  0
710aA*----------------------------------------------------------------
710aA*  *TRAX2  -  More TRAX options
710aA*----------------------------------------------------------------
710aA*
     * Fields
     *
     *    OPTSBU  -  Use system suspend battery power timeout.
     *    OPTSB   -  System suspend battery power timeout.
     *    OPTSEU  -  Use system suspend external power timeout.
     *    OPTSE   -  System suspend external power timeout.
     *    OPTBBU  -  Use backlight off battery power timeout.
     *    OPTBB   -  Backlight off battery power timeout.
     *    OPTBEU  -  Use backlight off external power timeout.
     *    OPTBE   -  Backlight off external power timeout.
     *    OPTV12  -  Default = N.  Y = create V1.2 xml.
     *    OPTV20  -  Default = N.  Y = create V2.0 xml.
     *    OPTDIR  -  IFS main directory
     *
     * Data structure
     *
     D opdta2          ds
     D  optsbu                 1      1
     D  optsb                  2      4  0
     D  optseu                 5      5
     D  optse                  6      8  0
     D  optbbu                 9      9
     D  optbb                 10     13  0
     D  optbeu                14     14
     D  optbe                 15     17  0
     D  optv12                18     18
     D  optv20                19     19
     D  optdir                20     39
     D  opten2               117    117

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1whse                             like(ttlwhse)
     D  h1rtid                             like(ttlrtid)
     D  h1rte                              like(ttlrte)
     D  h1try                              like(ttltry)
     D  h1filesnd                          like(ttlfilesnd)
     D  h1user1                            like(ttluser1)
     D  h1job1                             like(ttljob1)
     D  h1nbr1                             like(ttlnbr1)
     D  h1user3                            like(ttluser3)
     D  h1job3                             like(ttljob3)
     D  h1nbr3                             like(ttlnbr3)
     D  h1dummy              200    200

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
     *      $iWhse    - Warehouse
     *      $iRtid    - Route Id
     *      $iRte     - Route Code
     *      $iDate    - From Date
     *      $iDwnUp   - Downloaded but not uploaded yet Y/N
     *      $iErronly - Display only errors Y/N
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $iwhse
     C                   parm                    $irtid
     C                   parm                    $irte
     C                   parm                    $idate
     C                   parm                    $idwnUp
     C                   parm                    $ierronly

     C                   if        %parms >= 1
     C                   eval      $pwhse = $iwhse
     C                   else
     C                   eval      $pwhse = 0
     C                   endif

     C                   if        %parms >= 2
     C                   eval      $prtid = $irtid
     C                   else
     C                   eval      $prtid = '*ALL'
     C                   endif

     C                   if        %parms >= 3
     C                   eval      $prte = $irte
     C                   else
     C                   eval      $prte = '*ALL'
     C                   endif

     C                   if        %parms >= 4
     C                   eval      $pdate = $idate
     C                   else
     C                   eval      $pdate = 0
     C                   endif

     C                   if        %parms >= 5
     C                   eval      $pDwnUp = $iDwnUp
     C                   else
     C                   eval      $pDwnUp = 'Y'
     C                   endif

     C                   if        %parms >= 6
     C                   eval      $perronly = $ierronly
     C                   else
     C                   eval      $perronly = 'N'
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

     *  Define partial key for TTLOG file.
     *
     C     svkey         klist
     C                   kfld                    $iwhse
     C                   kfld                    svrte
     *
JSLaAC                   call      'GETCLIENT'
JSLaAC                   parm                    client           10
JSLaAC                   parm                    clientloc        10
     *
710aA /free
710aA  //  get *TRAX2 options
710aA
710aA    chain ($pwhse: '*TRAX2') Options;
710aA
710aA    if not %found;
710aA      opdta2  = ' ';
710aA    else;
710aA      opdta2  = opdata;
710aA    endif;
710aA /end-free
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

     * Create "where" clause.

     C                   eval      sqlwhere = ' '
     C                   eval      append5  = 'WHERE'

     *   Date

     C                   if        w1date > 0
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' ('
     C                                      + 'ttlts1>=timestamp('
     C                                      + sq + %char(w1ts) + sq + ')'
     C                                      + ' OR '
     C                                      + 'ttlts3>=timestamp('
     C                                      + sq + %char(w1ts) + sq + ')'
     C                                      + ')'
     C                   eval      append5 = ' and '
     C                   endif

     *   Warehouse

     C                   if        w1whse > 0
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' ttlWhse='
     C                                      + %editc(w1whse:'P')
     C                   eval      append5 = ' and '
     C                   endif

     *   Route id

     C                   if        w1rtid <> '*ALL'
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' ttlRtid='
     C                                      + sq + %trim(w1rtid) + sq
     C                   eval      append5 = ' and '
     C                   endif

     *   Route

     C                   if        w1rte <> '*ALL'
     C                   if        cfkey <> rolldn
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' ttlrte='
     C                                      + sq + %trim(w1rte) + sq
     C                   else
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' ttlRte>='
     C                                      + sq + %trim(w1rte) + sq
     C                   eval      w1rte = sv_w1rte
     C                   endif
     C                   eval      append5 = ' and '
     C                   endif

     *   Downloaded but not yet uploaded

     C                   if        w1DwnUp  = 'Y'
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' ttlStatus='
     C                                      + sq + '3' + sq
     C                   eval      append5 = ' and '
     C                   endif

     *   Errors only

     C                   if        w1erronly = 'Y'
     C                             and w1DwnUp = 'N'
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' ttlStatus='
     C                                      + sq + '9' + sq
     C                   eval      append5 = ' and '
     C                   endif

     * Create "Order By" clauses.


     C                   select
     C                   when      w1orderby = '2'
     C                   eval      sqlorder = 'ORDER BY TTLTS1'
     C                   other
     C                   eval      sqlorder = 'ORDER BY TTLRTE, TTLTRY'
     C                   endsl

     * Create list heading

     C                   exsr      createhead1

     * Create SQL statement.

     C                   Eval      SqlStmt = 'SELECT '
     C                                     + %trimr(sqlfields) + ' '
     C                                     + %trimr(sqlfrom) + ' '
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
     *  goback  - Page backward one page
     *----------------------------------------------------------------

     C     goback        BegSr

     * Position data file to first record of subfile

     C     svkey         setll     ttlog

     * Re-position pointer in file for rolling backward. If beginning
     * of file hit before done, set pointer to first record of data
     * file.

     C                   Do        SubfilePage
     C                   readp     ttlog
     C                   if        %eof
     C     *loval        setll     ttlog
     C                   leave
     C                   endif
     C                   enddo

     C                   eval      sv_w1rte  = w1rte
     C                   eval      w1rte  = ttlrte

     C                   endsr

     *----------------------------------------------------------------
     *  sflbld1 - Build the subfile
     *----------------------------------------------------------------

     C     sflbld1       BegSr

     C                   Eval      rrn1 = Lastrrn
     C                   Eval      recpos = lastrrn
     C                   Eval      first = *on

     * Process the records in the SQL cursor until the return not = 0

     C                   Do        SubfilePage

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
     C+      INTO :fetchds
     C/END-EXEC

     C                   If        sqlstt = '00000'
     C                   exsr      createline1
     C                   Eval      rrn1  = rrn1  + 1
     C                   if        first
     C                   eval      first = *off
     C                   Eval      recpos = rrn1
     C                   Eval      svrte  = #ttlrte
     C                   endif
     C                   Eval      option = ' '
     C                   Write     sfl1
     C                   Write     sfl2
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
     C                   Eval      *in84 = *on
     C                   EndIf

     C                   EndSr

     *----------------------------------------------------------------
     *  sflclr - Clear subfile
     *----------------------------------------------------------------

     C     sflclr        BegSr

      * Clear the subfile

     C                   Eval      *in31 = *on
     C                   Write     sf1ctl
     C                   Write     sf2ctl
     C                   Eval      *in31 = *off
     C                   Eval      *in32 = *off
     C                   Eval      rrn1 = 0
     C                   Eval      Lastrrn = 0
     C                   Eval      recpos = 0
     C                   Eval      *in84 = *off
     C                   EndSr

     *----------------------------------------------------------------
     *  sfloption1 - Get entered option
     *----------------------------------------------------------------

     C     sfloption1    BegSr

     C                   eval      recpos = csrrrn

     C                   if        rrn1 = 0
     C                   goto      endsflopt1
     C                   endif

     C                   Eval      optiontaken = *off
     C                   Eval      *in21 = *off

     C                   dow       forever = forever

     C                   select
     C                   when      curview = 2
     C                   readc     sfl2
     C                   other
     C                   readc     sfl1
     C                   endsl
     C                   if        %eof
     C                   leave
     C                   endif

     C                   select

     C                   when      %trim(option) = '5'
     C                   eval      optiontaken = 'View'
     C                   eval      recpos = rrn1
     C                   leave

     C                   when      %trim(option) = '7'
     C                   eval      optiontaken = 'ViewSent'
     C                   eval      recpos = rrn1
     C                   leave

     C                   when      %trim(option) = '11'
     C                   eval      optiontaken = 'ViewJobF'
     C                   eval      recpos = rrn1
     C                   leave

650aAc                   other
650aAc                   leave

     C                   endsl

     C                   enddo

     C                   if        option <> ' '
     C                   eval      option = ' '
     C                   select
     C                   when      curview = 2
     C                   update    sfl2
     C                   other
     C                   update    sfl1
     C                   endsl
     C                   endif

     C     endsflopt1    EndSr

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

     C                   Eval      scrname = 'TR310.01'
     C                   eval      w1orderby = '1'
     C                   exsr      inzcriteria1

640aAC                   exsr      getcriteria1

     C                   exsr      setcriteria1

     C                   eval      scopt1 = '5=View  '
     C                                    + '7=View sent file  '

     C                   eval      scopt2 = '11=View file job log  '

     *  Do initial build and display of subfile.

     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1

     *  Process subfile until user wants to leave.

     C                   DoU       (cfkey = F3)

     C                   Write     fkey1
     C                   if        recpos > 0 and recpos <= lastrrn
     C                   eval      rrn1 = recpos
     C                   else
     C                   eval      rrn1 = 1
     C                   endif
     C                   select
     C                   when      curview = 2
     C                   ExFmt     sf2ctl
     C                   other
     C                   ExFmt     sf1ctl
     C                   endsl
      *
640aAC                   eval      recpos = csrrrn
      *
     C                   Select

     *    Enter

     C                   When      cfkey = Enter
     C                   ExSr      sfloption1

     C                   select

     C                   when      optiontaken = 'View'
     C                   call      'TR312'
     C                   parm      h1whse        $lwhse
     C                   parm      h1rtid        $lrtid
     C                   parm      h1try         $ltry
     C                   parm      #pgm          $lpgm
     C                   parm      ' '           $lrtn
     C                   parm      ' '           $lerm

     C                   when      optiontaken = 'ViewSent'
     C                   eval      stmf = h1filesnd
     C                   exsr      dspStmf

     C                   when      optiontaken = 'ViewJobF'
     C                   exsr      dspJobFile

     C                   endsl

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

     *    F10 = Previous view.

     C                   When      cfkey = F10
     C                   if        curview <= 0
     C                   eval      curview = maxview
     C                   else
     C                   eval      curview = curview - 1
     C                   endif
     C                   eval      cfkey = Enter

     *    F11 = Next view.

     C                   When      cfkey = F11
     C                   if        curview >= maxview
     C                   eval      curview = 1
     C                   else
     C                   eval      curview = curview + 1
     C                   endif
     C                   eval      cfkey = Enter

     *    F12 = Cancel

     C                   When      cfkey = F12
     C                   Leave

     *    Rollup = More records

640aDC**                 When      (cfkey = Rollup) and (not *in84)
640aMC                   When      (cfkey = Pagedown)
640aDC**                 exsr      sflclr
     C                   ExSr      sflbld1

640aD*    Rolldn = Look at previous records

640aDC**                 When      (cfkey = Rolldn) and (not *in32)
640aDC**                 exsr      goback
640aDC**                 exSr      sqlclean
640aDC**                 exSr      sqlbldstmt1
640aDC**                 exSr      sqlprep
640aDC**                 exsr      sflclr
640aDC**                 exsr      sflbld1
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

     C                   eval      sflhead = @hu + 'Opt'
     C                                     + @hu + 'Route'
     C                                     + @hu + 'Try'
     C                                     + @hu + 'Stat'
     C                                     + @hu + 'Code      '
     C                                     + @hu + 'Message        '

     C                   eval      sflhead2 = @hu + 'Opt'
     C                                     + @hu + 'RteId'
     C                                     + @hu + 'Sent File Name'
     C                                     + '                '
     C                                     + @hu + 'Sent Date'

     C                   endsr

     *----------------------------------------------------------------
     *  createline1- Create subfile display line
     *----------------------------------------------------------------

     C     createline1   BegSr

     C                   eval      sflline = ' '
     C                                     + #ttlrte + '  '
     C                                     + %editc(#ttltry:'Z') + '    '
640 DC**                                   + #ttlstatus + '  '
640 MC                                     + #ttlstatus + ' '
     C                                     + #ttlerrcode + ' '
     C                                     + #ttlerrmsg

     C                   eval      sflline2 = ' '
     C                                     + #ttlrtid + ' '
     C                                     + #ttlfilesnd + ' '
     C                                     + %char(#ttlts3)

     C                   eval              h1whse  = #ttlwhse
     C                   eval              h1rtid  = #ttlrtid
     C                   eval              h1rte   = #ttlrte
     C                   eval              h1try   = #ttltry
     C                   eval              h1filesnd = #ttlfilesnd
     C                   eval              h1user1 = #ttluser1
     C                   eval              h1job1  = #ttljob1
     C                   eval              h1nbr1  = #ttlnbr1
     C                   eval              h1user3 = #ttluser3
     C                   eval              h1job3  = #ttljob3
     C                   eval              h1nbr3  = #ttlnbr3

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

     *----------------------------------------------------------------
     *  inzcriteria1 - Initialize criteria 1 values.
     *----------------------------------------------------------------

     C     inzcriteria1  BegSr

640aAC                   if        $pwhse = 0
640aAC                   call      'GETWHSE'
640aAC                   parm                    #user
640aAC     $pwhse        parm      0             #whse             3 0
640aAC                   endif

640aAC                   if        $prtid = *blanks
640aAC                   eval      $prtid = '*ALL'
640aAC                   endif

640aAC                   if        $prte = *blanks
640aAC                   eval      $prte = '*ALL'
640aAC                   endif

640aAC                   if        $pDwnUp = *blanks
640aAC                   eval      $pDwnUp = 'Y'
640aAC                   endif

640aAC                   if        $perronly = *blanks
640aAC                   eval      $perronly = 'N'
640aAC                   endif

     C                   eval      w1rte    = $prte
     C                   eval      w1rtid   = $prtid
     C                   eval      w1whse   = $pwhse
     C                   eval      w1date   = $pdate
     C                   eval      w1DwnUp  = $pDwnUp
     C                   eval      w1erronly = $perronly
     C                   eval      w1orderby = '1'

     C                   EndSr

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------

     C     setcriteria1  BegSr

     * Convert date to timestamp.

     C                   if        w1date <> 0
     C     *MDY          TEST(de)                w1date
     C                   if        not %error
     C                   eval      w1ts = %timestamp(%date(w1date:*MDY))
     C                   else
     C                   eval      w1date = 0
     C                   endif
     C                   endif

     * Set sort order.

     C                   if        w1orderby <> '1'
     C                             and w1orderby <> '2'
     C                   eval      w1orderby = '1'
     C                   endif

     *    Create screen heading.

     C                   eval      schead = ' '
     C                   eval      append1 = ' '

     C                   if        w1orderby = '2'
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'By Date'
     C                   eval      append1 = '-'
     C                   else
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'By Rte/Try'
     C                   eval      append1 = '-'
     C                   endif

     C                   if        w1DwnUp = 'Y'
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Downloaded & Not Yet Uploaded'
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1erronly = 'Y'
     C                             and w1DwnUp = 'N'
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Only Errors'
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1rte  <> '*ALL'
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Rte=' + w1rte
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1rtid <> '*ALL'
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Rtid=' + w1rtid
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1date <> 0
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Date>=' + %char(w1date)
     C                   eval      append1 = ','
     C                   endif

     C                   if        append1 = '-'
     C                   eval      schead = %trimr(schead) + '-Everything'
     C                   endif

     C                   exsr      centerschead

     C     endsetc1      EndSr

     *----------------------------------------------------------------
     *  dspJobFile -  Display job log for file creation
     *----------------------------------------------------------------

     C     dspJobFile    BegSr

      /free

         if h1nbr1=' ' or h1user1=' ' or h1job1=' ';
           leavesr;
         endif;

         cmd = 'dspjoblog '
             + 'job('
             + %trim(h1nbr1)
             + '/'
             + %trim(h1user1)
             + '/'
             + %trim(h1job1)
             + ')';

         monitor;
           qcmdexc(%trim(cmd): 200);
         on-error *all;
         endmon;

      /end-free

     C                   EndSr

     *----------------------------------------------------------------
     *  dspJobSend -  Display job log for send
     *----------------------------------------------------------------

     C     dspJobSend    BegSr

      /free

         if h1nbr3=' ' or h1user3=' ' or h1job3=' ';
           leavesr;
         endif;

         cmd = 'dspjoblog '
             + 'job('
             + %trim(h1nbr3)
             + '/'
             + %trim(h1user3)
             + '/'
             + %trim(h1job3)
             + ')';

         monitor;
           qcmdexc(%trim(cmd): 200);
         on-error *all;
         endmon;

      /end-free

     C                   EndSr

     *----------------------------------------------------------------
     *  dspStmf  -  Display stream file.
     *----------------------------------------------------------------

     C     dspStmf       BegSr

      /free

710aA    select;
710aA
710aA      when optdir <> '';
710aA        dirLen = %len(%trimr(optdir));
710aA        if %subst(optdir:1:1) <> '/';
710aA          path = '/' + optdir;
710aA        else;
710aA          path = optdir;
710aA        endif;
710aA        if %subst(optdir:dirLen:1) <> '/';
710aA          path = %trimr(path) + '/';
710aA        endif;

710aD      //if client = JSilvert;
710aM      when client = JSilvert;
JSLaA        eval path = '/JSLTrax';

710aD      //else;
710aM      other;
JSLaA        eval path = '/BFCTrax';

710aD      //endif;
710aA    endsl;

         pathLen = %len(%trimr(path));
         if %subst(path:pathLen:1) <> '/';
            cmd = %trimr(path)+ '/';
         else;
            cmd = path;
         endif;

         cmd = 'dspf ' + sq + %trim(cmd) + %trim(stmf) + sq;

         monitor;
           qcmdexc(%trim(cmd): 200);
         on-error *all;
         endmon;

      /end-free

     C                   EndSr

     *----------------------------------------------------------------
