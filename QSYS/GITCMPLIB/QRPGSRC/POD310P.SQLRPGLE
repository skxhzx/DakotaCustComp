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
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  POD310P   View PODP log
     *  23 October 2008
     *  Retha Davis
     *
     *  Revisions
     *
520 A*    10/23/08  RBD  5.20
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fpod310pfm cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl2:rrn1)
     F                                     infds(info)
     Foptions   if   e           k disk
     Fpodlogp1  if   e           k disk

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D qcmdexc         pr                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     D podsendp        pr                  extpgm('PODSENDP')
     D  cmd                           8    const
     D  program                      10    const
     D  whse                          3  0 const
     D  rtid                          5    const
     D  rte                           5    const
     D  stop                          2  0 const
     D  ord                           7  0 const
     D  cord                          7  0 const
     D  fileSend                     30    const
     D  fileRecv                     30    const
     D  fileTry                      33    const
     D  return                       10
     D  msg                          60
     D  plid                          7  0 const
     D  up#                           5  0 const

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
     *  *POD1    -  POD options - Part 1
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPPOPT  -  Export to POD (Y,N)
     *    OPPIFS  -  IFS folder
     *    OPPSRV  -  POD HTTP Server
     *    OPPUSR  -  POD HTTP Server User Id
     *    OPPPWD  -  POD HTTP Server Password
     *
     * Data structure
     *
     D opdata          ds
     D  oppopt                 1      1
     D  opppth                 2     33
     D  oppsrv                34     83
     D  oppusr                84     98
     D  opppwd                99    113
     D  optend               117    117

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     D keyop           ds                  likerec(oprec : *key)

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')
     D SubfilePage     C                   Const(16)

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D f#pdpflds     E ds                  extname(podlogp)
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

     D sqlfile         c                   'PODLOGP'
     D sqlfields       c                   'pdpWhse,pdpRtid,-
     D                                      pdpPlid,pdpUp#,pdpStop,-
     D                                      pdpOrd,pdpTry,-
     D                                      pdpRte,pdpCord,pdpStatus,-
     D                                      pdpFileSnd,pdpFileRcv,-
     D                                      pdpFileTry,-
     D                                      pdpRcvXml,pdpErrCode,-
     D                                      pdpErrMsg,-
     D                                      pdpTS1,pdpUC1,pdpTS2,pdpUC2,-
     D                                      pdpCall1,pdpPgm1,pdpUser1,-
     D                                      pdpJob1,pdpNbr1,-
     D                                      pdpTS3,pdpUC3,pdpTS4,pdpUC4,-
     D                                      pdpCall3,pdpPgm3,pdpUser3,-
     D                                      pdpJob3,pdpNbr3'

     D fetchds         ds
     D   #pdpWhse                          like(pdpwhse)
     D   #pdpRtid                          like(pdprtid)
     D   #pdpPlid                          like(pdpplid)
     D   #pdpUp#                           like(pdpup#)
     D   #pdpStop                          like(pdpstop)
     D   #pdpOrd                           like(pdpord)
     D   #pdpTry                           like(pdptry)
     D   #pdpRte                           like(pdprte)
     D   #pdpCord                          like(pdpcord)
     D   #pdpStatus                        like(pdpstatus)
     D   #pdpFileSnd                       like(pdpfilesnd)
     D   #pdpFileRcv                       like(pdpfilercv)
     D   #pdpFileTry                       like(pdpfiletry)
     D   #pdpRcvXml                        like(pdprcvxml)
     D   #pdpErrCode                       like(pdperrcode)
     D   #pdpErrMsg                        like(pdperrmsg)
     D   #pdpTS1                           like(pdpTS1)
     D   #pdpUC1                           like(pdpUC1)
     D   #pdpTS2                           like(pdpTS2)
     D   #pdpUC2                           like(pdpUC2)
     D   #pdpCall1                         like(pdpCall1)
     D   #pdpPgm1                          like(pdpPgm1)
     D   #pdpUser1                         like(pdpUser1)
     D   #pdpJob1                          like(pdpJob1)
     D   #pdpNbr1                          like(pdpNbr1)
     D   #pdpTS3                           like(pdpTS3)
     D   #pdpUC3                           like(pdpUC3)
     D   #pdpTS4                           like(pdpTS4)
     D   #pdpUC4                           like(pdpUC4)
     D   #pdpCall3                         like(pdpCall3)
     D   #pdpPgm3                          like(pdpPgm3)
     D   #pdpUser3                         like(pdpUser3)
     D   #pdpJob3                          like(pdpJob3)
     D   #pdpNbr3                          like(pdpNbr3)

     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

     D $iwhse          s              3  0
     D $iRtid          s              5
     D $iRte           s              5
     D $iPlid          s              7  0
     D $iUp#           s              5  0
     D $iStop          s              2  0
     D $iOrd           s              7  0
     D $iCord          s              7  0
     D $iDate          s              6  0
     D $iErrOnly       s              1

     D $pwhse          s                   like($iwhse)
     D $prtid          s                   like($irtid)
     D $prte           s                   like($irte)
     D $pplid          s                   like($iplid)
     D $pup#           s                   like($iup#)
     D $pstop          s                   like($istop)
     D $pord           s                   like($iord)
     D $pcord          s                   like($icord)
     D $pdate          s                   like($idate)
     D $perronly       s                   like($ierronly)

     D $lcmd           s              8
     D $lwhse          s                   like(pdpwhse)
     D $lrtid          s                   like(pdprtid)
     D $lplid          s                   like(pdpplid)
     D $lup#           s                   like(pdpup#)
     D $lstop          s                   like(pdpstop)
     D $lord           s                   like(pdpord)
     D $ltry           s                   like(pdptry)
     D $lstmf          s                   like(pdpfilesnd)
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
     D posfld          s              5    inz(' ')
     D recpos          s                   like(rrn1)
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')
     D sortorder2      s             10    inz(' ')
     D sortorder3      s             10    inz(' ')
     D sv_w1rte        s                   like(w1rte)
     D svrte           s                   like(pdprte)
     D w1ts            s               z
     D cmd             s            200
     D stmf            s                   like(pdpfilesnd)
     D pathLen         s              3  0

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1whse                             like(pdpwhse)
     D  h1rtid                             like(pdprtid)
     D  h1rte                              like(pdprte)
     D  h1plid                             like(pdpplid)
     D  h1up#                              like(pdpup#)
     D  h1stop                             like(pdpstop)
     D  h1ord                              like(pdpord)
     D  h1cord                             like(pdpcord)
     D  h1try                              like(pdptry)
     D  h1filesnd                          like(pdpfilesnd)
     D  h1filercv                          like(pdpfilercv)
     D  h1filetry                          like(pdpfiletry)
     D  h1user1                            like(pdpuser1)
     D  h1job1                             like(pdpjob1)
     D  h1nbr1                             like(pdpnbr1)
     D  h1user3                            like(pdpuser3)
     D  h1job3                             like(pdpjob3)
     D  h1nbr3                             like(pdpnbr3)
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
     *      $iWhse   - Warehouse
     *      $iRtid   - Route Id
     *      $iRte    - Route Code
     *      $iPlid   - Pallet Id
     *      $iUp#    - Unique piece#
     *      $iStop   - Stop
     *      $iOrd    - Order Id
     *      $iCord   - Customer order number
     *      $iDate   - From date
     *      $iErronly  - Display only errors
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
     C                   parm                    $iplid
     C                   parm                    $iup#
     C                   parm                    $istop
     C                   parm                    $iord
     C                   parm                    $icord
     C                   parm                    $idate
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
     C                   eval      $pplid = $iplid
     C                   else
     C                   eval      $pplid = 0
     C                   endif

     C                   if        %parms >= 5
     C                   eval      $pup#  = $iup#
     C                   else
     C                   eval      $pup#  = 0
     C                   endif

     C                   if        %parms >= 6
     C                   eval      $pstop = $istop
     C                   else
     C                   eval      $pstop = 0
     C                   endif

     C                   if        %parms >= 7
     C                   eval      $pord = $iord
     C                   else
     C                   eval      $pord = 0
     C                   endif

     C                   if        %parms >= 8
     C                   eval      $pcord = $icord
     C                   else
     C                   eval      $pcord = 0
     C                   endif

     C                   if        %parms >= 9
     C                   eval      $pdate = $idate
     C                   else
     C                   eval      $pdate = 0
     C                   endif

     C                   if        %parms >= 10
     C                   eval      $perronly = $ierronly
     C                   else
     C                   eval      $perronly = 'Y'
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

     *  Define partial key for PODLOGP1 file.
     *
     C     svkey         klist
     C                   kfld                    svrte

     C                   endsr

     *----------------------------------------------------------------
     *                      SQL Subroutines
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
     C                                      + 'pdpts1>=timestamp('
     C                                      + sq + %char(w1ts) + sq + ')'
     C                                      + ' OR '
     C                                      + 'pdpts3>=timestamp('
     C                                      + sq + %char(w1ts) + sq + ')'
     C                                      + ')'
     C                   eval      append5 = ' and '
     C                   endif

     *   Warehouse

     C                   if        w1whse > 0
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' pdpWhse='
     C                                      + %editc(w1whse:'P')
     C                   eval      append5 = ' and '
     C                   endif

     *   Route id

     C                   if        w1rtid <> '*ALL'
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' pdpRtid='
     C                                      + sq + %trim(w1rtid) + sq
     C                   eval      append5 = ' and '
     C                   endif

     *   Route

     C                   if        w1rte <> '*ALL'
     C                   if        cfkey <> rolldn
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' pdprte='
     C                                      + sq + %trim(w1rte) + sq
     C                   else
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' pdpRte>='
     C                                      + sq + %trim(w1rte) + sq
     C                   eval      w1rte = sv_w1rte
     C                   endif
     C                   eval      append5 = ' and '
     C                   endif

     *   Pallet id

     C                   if        w1plid > 0
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' pdpPlid='
     C                                      + %editc(w1plid:'P')
     C                   eval      append5 = ' and '
     C                   endif

     *   Unique piece#

     C                   if        w1up#  > 0
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' pdpup# ='
     C                                      + %editc(w1up#:'P')
     C                   eval      append5 = ' and '
     C                   endif

     *   Stop

     C                   if        w1stop > 0
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' pdpStop='
     C                                      + %editc(w1stop:'P')
     C                   eval      append5 = ' and '
     C                   endif

     *   Customer Order

     C                   if        w1cord > 0
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' pdpcord='
     C                                      + %editc(w1cord:'P')
     C                   eval      append5 = ' and '
     C                   endif

     *   Order

     C                   if        w1ord > 0
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' pdpOrd='
     C                                      + %editc(w1ord:'P')
     C                   eval      append5 = ' and '
     C                   endif

     *   Errors only

     C                   if        w1erronly = 'Y'
     C                   eval      sqlwhere = %trimr(sqlwhere) + append5
     C                                      + ' pdpStatus='
     C                                      + sq + '9' + sq
     C                   eval      append5 = ' and '
     C                   endif

     * Create "Order By" clauses.

     C                   select
     C                   when      w1orderby = '2'
     C                   eval      sqlorder = 'ORDER BY PDPUC1'
     C                   other
     C                   eval      sqlorder = 'ORDER BY PDPRTE, PDPPLID, PDPTRY'
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
     *                    Subfile Subroutines
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  goback  - Page backward one page
     *----------------------------------------------------------------

     C     goback        BegSr

     * Position data file to first record of subfile

     C     svkey         setll     podlogp1

     * Re-position pointer in file for rolling backward. If beginning
     * of file hit before done, set pointer to first record of data
     * file.

     C                   Do        SubfilePage
     C                   readp     podlogp1
     C                   if        %eof
     C     *loval        setll     podlogp1
     C                   leave
     C                   endif
     C                   enddo

     C                   eval      sv_w1rte = w1rte
     C                   eval      w1rte = pdprte

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
     C                   Eval      svrte = #pdprte
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
     C                   Eval      *in90 = *off
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

     C                   when      %trim(option) = '9'
     C                   eval      optiontaken = 'ViewRecv'
     C                   eval      recpos = rrn1
     C                   leave

     C                   when      %trim(option) = '11'
     C                   eval      optiontaken = 'ViewJobF'
     C                   eval      recpos = rrn1
     C                   leave

     C                   when      %trim(option) = '12'
     C                   eval      optiontaken = 'ViewJobS'
     C                   eval      recpos = rrn1
     C                   leave

     C                   when      %trim(option) = 'RS'
     C                   eval      optiontaken = 'ReSend'
     C                   eval      recpos = rrn1
     C                   leave

     C                   endsl

     C                   enddo

     C                   eval      option = ' '
     C                   select
     C                   when      curview = 2
     C                   update    sfl2
     C                   other
     C                   update    sfl1
     C                   endsl

     C     endsflopt1    EndSr

     *----------------------------------------------------------------
     *                Screen Processing Subroutines
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  screen1 - Process screen 1
     *----------------------------------------------------------------

     C     screen1       BegSr

     *  Initialize screen fields.

     C                   Eval      scrname = 'POD310P.01'
     C                   eval      w1orderby = '1'
     C                   exsr      inzcriteria1

     C                   exsr      setcriteria1

     C                   eval      scopt1 = '5=View  '
     C                                    + '7=View sent file  '
     C                                    + '9=View response file  '
     C                                    + 'RS=Resend'

     C                   eval      scopt2 = '11=View file job log  '
     C                                    + '12=View send job log  '

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
     C                   Select

     *    Enter

     C                   When      cfkey = Enter
     C                   ExSr      sfloption1

     C                   select

     C                   when      optiontaken = 'View'
     C                   call      'POD312P'
     C                   parm      h1whse        $lwhse
     C                   parm      h1rtid        $lrtid
     C                   parm      h1plid        $lplid
     C                   parm      h1up#         $lup#
     C                   parm      h1stop        $lstop
     C                   parm      h1ord         $lord
     C                   parm      h1try         $ltry
     C                   parm      #pgm          $lpgm
     C                   parm      ' '           $lrtn
     C                   parm      ' '           $lerm

     C                   when      optiontaken = 'ViewSent'
     C                   eval      stmf = h1filesnd
     C                   exsr      dspStmf

     C                   when      optiontaken = 'ViewRecv'
     C                   eval      stmf = h1filetry
     C                   exsr      dspStmf

     C                   when      optiontaken = 'ViewJobF'
     C                   exsr      dspJobFile

     C                   when      optiontaken = 'ViewJobS'
     C                   exsr      dspJobSend

     C                   When      optiontaken = 'ReSend'
     C                   ExFmt     window2
     C                   if        cfkey = Enter and ynopt='Y'
     C                   exsr      resend
     C                   exsr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1
     C                   endif
     C                   eval      cfkey = Enter

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

     C                   When      (cfkey = Rollup) and (not *in90)
     C                   exsr      sflclr
     C                   ExSr      sflbld1

     *    Rolldn = Look at previous records

     C                   When      (cfkey = Rolldn) and (not *in32)
     C                   exsr      goback
     C                   exSr      sqlclean
     C                   exSr      sqlbldstmt1
     C                   exSr      sqlprep
     C                   exsr      sflclr
     C                   exsr      sflbld1
      *
     C                   EndSl
      *
     C                   EndDo

     C                   ExSr      sqlclean
     C                   endsr

     *----------------------------------------------------------------
     *                     Misc. Subroutines
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
     C                                     + @hu + 'Pallet '
     C                                     + @hu + 'Tote '
     C                                     + @hu + 'Try'
     C                                     + @hu + 'Sta'
     C                                     + @hu + 'Code      '
     C                                     + @hu + 'Message        '

     C                   eval      sflhead2 = @hu + 'Opt'
     C                                     + @hu + 'RteId'
     C                                     + @hu + 'Order# '
     C                                     + @hu + 'Sent File Name'
     C                                     + '                '
     C                                     + @hu + 'Sent Date'

     C                   endsr

     *----------------------------------------------------------------
     *  createline1- Create subfile display line
     *----------------------------------------------------------------

     C     createline1   BegSr

     C                   eval      sflline = ' '
     C                                     + #pdprte + ' '
     C                                     + %editc(#pdpplid:'Z') + ' '
     C                                     + %editc(#pdpup#:'Z') + '  '
     C                                     + %editc(#pdptry:'Z') + '  '
     C                                     + #pdpstatus + '  '
     C                                     + #pdperrcode + ' '
     C                                     + #pdperrmsg

     C                   eval      sflline2 = ' '
     C                                     + #pdprtid + ' '
     C                                     + %editc(#pdpcord:'Z') + ' '
     C                                     + #pdpfilesnd + ' '
     C                                     + %char(#pdpts3)

     C                   eval              h1whse  = #pdpwhse
     C                   eval              h1rtid  = #pdprtid
     C                   eval              h1rte   = #pdprte
     C                   eval              h1plid  = #pdpplid
     C                   eval              h1up#   = #pdpup#
     C                   eval              h1stop  = #pdpstop
     C                   eval              h1ord   = #pdpord
     C                   eval              h1cord  = #pdpcord
     C                   eval              h1try   = #pdptry
     C                   eval              h1filesnd = #pdpfilesnd
     C                   eval              h1filercv = #pdpfilercv
     C                   eval              h1filetry = #pdpfiletry
     C                   eval              h1user1 = #pdpuser1
     C                   eval              h1job1  = #pdpjob1
     C                   eval              h1nbr1  = #pdpnbr1
     C                   eval              h1user3 = #pdpuser3
     C                   eval              h1job3  = #pdpjob3
     C                   eval              h1nbr3  = #pdpnbr3

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
     C                   eval      w1rte    = $prte
     C                   eval      w1rtid   = $prtid
     C                   eval      w1plid   = $pplid
     C                   eval      w1up#    = $pup#
     C                   eval      w1stop   = $pstop
     C                   eval      w1cord   = $pcord
     C                   eval      w1ord    = $pord
     C                   eval      w1whse   = $pwhse
     C                   eval      w1date   = $pdate
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
     C                                    + 'By Rte/Pal/Try'
     C                   eval      append1 = '-'
     C                   endif

     C                   if        w1erronly = 'Y'
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Only Errors'
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1rtid <> '*ALL'
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Rtid=' + w1rtid
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1rte  <> '*ALL'
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Rte=' + w1rte
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1plid  <> 0
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Pal=' + %trim(%editc(w1plid:'Z'))
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1up#   <> 0
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Tote=' + %trim(%editc(w1up#:'Z'))
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1stop <> 0
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Stop=' + %trim(%editc(w1stop:'Z'))
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1ord <> 0
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'OrdId=' + %trim(%editc(w1ord:'Z'))
     C                   eval      append1 = ','
     C                   endif

     C                   if        w1cord <> 0
     C                   eval      schead = %trimr(schead) + append1
     C                                    + 'Ord=' + %trim(%editc(w1cord:'Z'))
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

         keyop.opwhse = $pwhse;
         keyop.opcode = '*POD1';
         chain %kds(keyop) options;
         if not %found();
           eval opppth = ' ';
         endif;

         pathLen = %len(%trimr(opppth));
         if %subst(opppth:pathLen:1) <> '/';
            cmd = %trimr(opppth)+ '/';
         else;
            cmd = opppth;
         endif;

         cmd = 'dspf ' + sq + %trim(cmd) + %trim(stmf) + sq;

         monitor;
           qcmdexc(%trim(cmd): 200);
         on-error *all;
         endmon;

      /end-free

     C                   EndSr

     *----------------------------------------------------------------
     *  resend  -  Resend file
     *----------------------------------------------------------------

     C     resend        BegSr

      /free

         PODsendP('*RESEND' : #pgm  : h1whse : h1rtid : h1rte :
                 h1stop  : h1ord : h1cord :
                 h1FileSnd : h1FileRcv : h1FileTry :
                 rReturn : rMsg : h1plid : h1up#
                );

      /end-free

     C                   EndSr

