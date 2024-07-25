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
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TR320     View Trax at route level
     *  18 July 2011
     *  Retha Davis
     *
     *  Revisions
     *
640aA*    07/18/11  RBD  6.40a
     *      - Created.
     *
640bA*    11/17/11  DAS  6.40b
     *      - Revised to use the sflhide field for key fields.
     *        Re: Field ttrrti was being passed to TR325, but that
     *        field only existed on the second subfile screen.
     *      - Revised chain to rtehed to use $pwhse instead of
     *        $iwhse because $pwhse contains value from prompt
     *        screen, where $iwhse comes in as zero.
     *
640cA*    02/22/12  RBD  6.40c
     *      - Removed non-scan and returns parms from sort/select
     *        as they were not being used.
     *      - Shrank some columns and added new column for Total Pcs.
     *      - Changed screen format to TR32001.
     *      - Fixed 'more/bottom' subfile logic.
     *
640dA*    09/13/12  RBD  6.40d
     *      - Renamed TR32001 to TR32002.
     *      - Added selection by 'Route Printed Date'.
     *
650aA*    08/19/13  RBD  6.50a
     *      - Added option 6 to call TR340, Route Completion Report.
     *
650bA*    08/28/13  RBD  6.50b
     *      - Removed %trim on w1rte in sql statement.
     *
650cA*    12/04/13  RBD  6.50c
     *      - Fix: driver selection wasn't working.
     *
720aA*    02/21/18  RBD  7.20a
     *      - Discovered that some routes are coming back from the
     *        handheld without a start date and because of that they
     *        don't show up if a date range is selected.  Will now
     *        include zero start dates if date range is entered.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

640cDF*tr320FM   cf   e             workstn
640dDF*tr32001   cf   e             workstn
640dMFtr32002   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl2:rrn1)
     F                                     infds(info)
     F                                     sfile(msgrec:msgk)
     Fpiruser   if   e           k disk
640dDF*rtehed    if   e           k disk
640cAFrtesum    if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.putmsg

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     D  erdate                 1      6  0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')
     D SubfilePage     C                   Const(14)

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D fetchds         ds
     D   #fwhs                             like(ttrwhs)
     D   #frti                             like(ttrrti)
     D   #fusr                             like(ttrusr)
     D   #fstd                             like(ttrstd)
     D   #fstt                             like(ttrstt)
     D   #frte                             like(ttrrte)
     D   #ftru                             like(ttrtru)
     D   #fscn                             like(ttrscn)
     D   #fs                               like(ttrs)
     D   #fsd                              like(ttrsd)
     D   #fqs1                             like(ttrqs1)
     D   #fqs2                             like(ttrqs2)
     D   #fqs3                             like(ttrqs3)
     D   #fqn1                             like(ttrqn1)
     D   #fqn2                             like(ttrqn2)
     D   #fqn3                             like(ttrqn3)
     D   #fqc1                             like(ttrqc1)
     D   #fqc2                             like(ttrqc2)
     D   #fqc3                             like(ttrqc3)
     D   #fqp1                             like(ttrqp1)
     D   #fqp2                             like(ttrqp2)
     D   #fqp3                             like(ttrqp3)
     D   #fsrd                             like(ttrsrd)
     D   #fsrt                             like(ttrsrt)
     D   #ffid                             like(ttrfid)
     D   #ffit                             like(ttrfit)
     D   #fser                             like(ttrser)
     D   #frwhse                           like(rhwhse)
     D   #frrtid                           like(rhrtid)
     D   #frrte                            like(rhrte)
     D   #frtruk                           like(rhtruk)
     D   #frorig                           like(rhorig)
     D   #frtype                           like(rhtype)
     D   #frpbat                           like(rhpbat)
     D   #frrptd                           like(rhrptd)
     D   #frimpd                           like(rhimpd)
     D   #frimpt                           like(rhimpt)
     D   #frstat                           like(rhstat)
     D   #frstsd                           like(rhstsd)
     D   #frstst                           like(rhstst)
     D   #frbldd                           like(rhbldd)
     D   #frbldt                           like(rhbldt)
     D   #frprtd                           like(rhprtd)
     D   #frprtt                           like(rhprtt)
     D   #frexpd                           like(rhexpd)
     D   #frexpt                           like(rhexpt)
     D   #frshpd                           like(rhshpd)
     D   #frshpt                           like(rhshpt)

     D ttrte         e ds
640dAD rtehed        e ds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  SQL fetch fields
     *----------------------------------------------------------------

     D sqlfile         c                   'TTRTE'
640dAD sqlfile1        c                   'RTEHED'
640dMD sqlfields       c                   'ttrwhs,ttrrti,ttrusr,+
640dAD                                      ttrstd,ttrstt,ttrrte,+
640dAD                                      ttrtru,ttrscn,ttrs,ttrsd,+
640dAD                                      ttrqs1,ttrqs2,ttrqs3,+
640dAD                                      ttrqn1,ttrqn2,ttrqn3,+
640dAD                                      ttrqc1,ttrqc2,ttrqc3,+
640dAD                                      ttrqp1,ttrqp2,ttrqp3,+
640dAD                                      ttrsrd,ttrsrt,ttrfid,+
640dAD                                      ttrfit,ttrser,+
640dAD                                      rhwhse,rhrtid,rhrte,+
640dAD                                      rhtruk,rhorig,rhtype,+
640dAD                                      rhpbat,rhrptd,rhimpd,+
640dAD                                      rhimpt,rhstat,rhstsd,+
640dAD                                      rhstst,rhbldd,rhbldt,+
640dAD                                      rhprtd,rhprtt,rhexpd,+
640dAD                                      rhexpt,rhshpd,rhshpt'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

640cA*----------------------------------------------------------------
640cA*  Key definitions
640cA*----------------------------------------------------------------

640cAD keyWhsRtid      ds
640cAD  kywhse                        3  0
640cAD  kyrtid                        5

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $icmd           s              8
     D $iwhse          s              3  0
     D $irte           s              5
     D $idev           s             10
     D $iform          s             10

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $prte           s                   like($irte)
     D $pdlvd          s              8  0
640dAD $pprtd          s              8  0
     D $pusr           s                   like(ttrusr)
     D $pdev           s                   like($idev)
     D $pform          s                   like($iform)

     D #whse           s              3  0
     D #emp#           s              5  0
     D #fnam           s             15
     D #init           s              1
     D #lnam           s             20
     D #whdp           s              5
     D #styp           s              1
     D #shft           s              6
     D #crew           s              6
     D #nhrs           s              3  1
     D #rtn            s              8
     D #BeltPrt        s              1
     D #Language       s              2

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $code           s              2    inz(' ')
     D $count          s              8b 0 inz(0)
     D append1         s              1
     D append5         s              5
     D cqerm           s             60
     D cqqty1          s              7  0
     D cqqty2          s              7  0
     D cqqty3          s              7  0
     D cqrtn           s              8
     D cqum1           s              2
     D cqum2           s              2
     D cqum3           s              2
     D cqustr          s             17
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
     D noParmsPassed   s               n
     D oldhead         s                   like(schead)
     D oldname         s                   like(scrname)
     D oldopt          s                   like(scopt1)
     D opcode          s              6
     D optiontaken     s             10    inz(' ')
     D order1          s             10    inz(' ')
     D order2          s             10    inz(' ')
     D orderby         S            100a   inz(' ')
     D orderfield      s             10    inz(' ')
     D orderposition   s              3  0 inz(0)
     D posfld          s              5    inz(' ')
     D recpos          s                   like(rrn1)
     D rtnCode         s             10
     D rtnMessage      s            200
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')
     D sortorder2      s             10    inz(' ')
     D sortorder3      s             10    inz(' ')
     D $msgf           s             10
     D $pmsg           s              4
     D $pprg           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D #msgk           s              4
     D dummy           s              1
     D msgk            s              4  0
     D sclear          s              1
     D wkRte           s              5
     D wkDlvd          s              8  0
640dAD wkPrtd          s              8  0
640dAD wkPrt           s              8  0
     D wkSrd           s              8  0
     D wkWhse          s              3  0
     D b               s             10  0
     D chk4err         s               n
     D zmsflag         s               n
     D zmflag          s               n

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
640aDD**h1lcns                 1     15
640aDD**h1olcns               16     30
640aDD**h1item                31     45
640aDD**h1whdp                46     50
640aDD**h1disp                51     62
640aDD**h1whse                63     65S 0
640aDD**h1qty1                66     70S 0
640aDD**h1qty2                71     75S 0
640aDD**h1qty3                76     80S 0
640aDD**h1base                81     92
640aAD  h1rtid                 1      5
     D  h1dummy              100    100

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------
     D @cvtdt          c                   const('CVTDTE')

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

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D TR325           pr                  extpgm('TR325')
      * Input
     D   pCmd                         8    const
     D   pWhse                        3  0 const
     D   pRtid                        5    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

650aAD TR340           pr                  extpgm('TR340')
650aA * Input
650aAD   pWhse                        3  0 const
650aAD   pRtid                        5    const

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $icmd    - *SPECIAL
     *                 *PRINT
     *      $iwhse   - Warehouse
     *      $irte    - Route
     *      $idev    - Printer device
     *      $iform   - Form type
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $icmd
     C                   parm                    $iwhse
     C                   parm                    $irte
     C                   parm                    $idev
     C                   parm                    $iform

      /free

         noParmsPassed = *on;

         if %parms >= 1;
           $pcmd = $icmd;
         else;
           $pcmd = ' ';
         endif;

         if %parms >= 2 and $iwhse > 0;
           $pwhse = $iwhse;
           noParmsPassed = *off;
         else;
           $pwhse = 0;
         endif;

         if %parms >= 3 and $irte <> ' ';
           $prte = $irte;
           noParmsPassed = *off;
         else;
           $prte = ' ';
         endif;

         if %parms >= 4;
           $pdev = $idev;
         else;
           $pdev = ' ';
         endif;

         if %parms >= 5;
           $pform = $iform;
         else;
           $pform = ' ';
         endif;

      /end-free

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         // Get default values for the user.

         getUser(#user: #whse: #emp#: #fnam: #init: #lnam: #whdp:
               #styp: #shft: #crew: #nhrs: #rtn: #BeltPrt: #Language);


         // Establish the connection to the remote machine. The -842 return
         // code indicates that the connection is already established. If
         // you want to connect to the local machine, use CONNECT RESET.

         exec sql CONNECT RESET;

         If sqlstt = sqlSuccess;
         endif;

         // Process main screen.

         select;
           when $pcmd = '*PRINT';
             exsr printit;
           when $pcmd = '*SPECIAL';
             exsr sc2;
         other;
             exsr screen1;
         endsl;

         // Cleanup
         exsr zsclr;

         *inlr = *on;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

         // Initialize message handling

         error = *off;
         exsr zmimsg;

         w1sort = 'D';
         w1oby = '2';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      SQL Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sqlbldstmt1 - Build SQL statment
     *----------------------------------------------------------------

      /free
       begsr sqlbldstmt1;

         // Create "From" clause.

         sqlfrom = 'FROM ' + sqlfile;

640dA    // Create "Inner join" clause.
640dA
640dA    sqljoin = 'INNER JOIN ' + sqlfile1 + ' ' +
640dA               'ON ' + 'rhwhse=ttrwhs and rhrtid=ttrrti';

         // Create "where" clause.

         sqlwhere = ' ';
         append5  = 'WHERE';

         // Warehouse

         if w1whse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'ttrwhs=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';
         endif;

         // Route

         if w1rte <> '*ALL';
650bD    //sqlwhere = %trimr(sqlwhere) + append5 + ' '
650bD    //         + 'ttrrte='
650bD    //         + sq + %trim(w1rte) + sq;
650bM      sqlwhere = %trimr(sqlwhere) + append5 + ' '
650bM               + 'ttrrte='
650bM               + sq + (w1rte) + sq;
           append5 = ' and ';
         endif;

640dA    // Route Printed Date
640dA
640dA    if wkPrtd > 0;
640dA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
640dA               + 'rhprtd=' + %trim(%editc(wkPrtd:'P'));
640dA      append5 = ' and ';
640dA    endif;

         // Delivery Date

         if wkDlvd > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
720aD    //         + 'ttrsrd=' + %trim(%editc(wkDlvd:'P'));
720aM               + '(ttrsrd=' + %trim(%editc(wkDlvd:'P'));
720aA      append5 = ' or  ';
720aA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
720aA               + 'ttrsrd=0)';
           append5 = ' and ';
         endif;

         //  Driver

         if w1usr <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'ttrusr='
                    + sq + %trim(w1usr) + sq;
           append5 = ' and ';
         endif;

640cD    // Non-scanned items only

640cD    // if w1nscn  = 'Y';
640cD    // endif;

640cD    // Returned items only

640cD    // if w1retn  = 'Y';
640cD    // endif;

         // Create "Order By" clauses.

         select;

           when sortorder1 = 'DESCEND';
             if w1oby = '1';
               sqlorder = 'ORDER BY TTRRTE DESC,TTRSRD DESC';
             else;
               sqlorder = 'ORDER BY TTRSRD DESC,TTRRTE DESC';
             endif;

           other;
             if w1oby = '1';
               sqlorder = 'ORDER BY TTRRTE,TTRSRD';
             else;
               sqlorder = 'ORDER BY TTRSRD,TTRRTE';
             endif;

         endsl;

         // Create SQL statement.

         SqlStmt = 'SELECT '
                 + %trimr(sqlfields) + ' '
                 + %trimr(sqlfrom) + ' '
640dA            + %trimr(sqljoin) + ' '
                 + %trimr(sqlwhere) + ' '
                 + sqlorder;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlprep - Prepare SQL cursor
     *
     *    Note: This routine must come before any other routine
     *          using an SQL statement because it declares the
     *          SQL Cursor being used.
     *----------------------------------------------------------------

      /free
       begsr sqlprep;

         // Prepare the SQL statement for validation, since the program was
         // compiled with DLYPRP (*YES), it will wait until it is used before
         // it prepares the cursor.

         exec sql PREPARE sel FROM :SqlStmt;

         sqlstt = sqlstt;

         // Declare the leavesror to hold the data retrieved from the SELECT

         exec sql DECLARE MYCSR SCROLL CURSOR FOR SEL;

         sqlstt = sqlstt;

         // Open the SQL cursor.

         exec sql OPEN MYCSR;

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlclean - Clean up before exiting
     *----------------------------------------------------------------

      /free
       begsr sqlclean;

         // Close the SQL cursor after all processing is complete.

         exec sql CLOSE mycsr;

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                    Subfile Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sflBldDisp   Build and display subfile
     *----------------------------------------------------------------

      /free
       begsr sflBldDisp;

         exsr sqlclean;
         exsr sqlbldstmt1;
         exsr sqlprep;
         exsr sflclr;
         exsr sflbld1;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflbld1 - Build the subfile
     *----------------------------------------------------------------

      /free
       begsr sflbld1;

         rrn1 = Lastrrn;
         recpos = lastrrn;
         first = *on;

         // Process the records in the SQL cursor until the return not = 0

         for i = 1 to subfilePage;

           // Get the next row from the SQL cursor.

640dD      //exec sql FETCH NEXT FROM mycsr INTO :ttrte;
640dM      exec sql FETCH NEXT FROM mycsr INTO :fetchds;

           If sqlstt = sqlSuccess;
             exsr sflFill1;
             rrn1 = rrn1  + 1;
             if first;
               first = *off;
               recpos = rrn1;
             endif;
             option = ' ';
             write sfl1;
             write sfl2;
           else;
             leave;
           endif;

         endfor;

         if rrn1 = 0;
           *in32 = *on;
         else;
           lastrrn = rrn1;
         endif;

         if sqlstt = sqlNoMoreData;
640cA      *in84 = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflclr - Clear subfile
     *----------------------------------------------------------------

      /free
       begsr sflclr;

         // Clear the subfile

         *in31 = *on;
         write sf1ctl;
         write sf2ctl;
         *in31 = *off;
         *in32 = *off;
         rrn1 = 0;
         lastrrn = 0;
         recpos = 0;
640cD    // *in90 = *off;
640cM    *in84 = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill1  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill1;

640aA    // Store hidden fields that aren't displayed on screen.
640aA
640dD    //h1rtid = ttrrti;
640dM    h1rtid = #frti;

         // Calculate totals:  pieces delivered, pieces non-scanned,
         // curr rte pieces returned, prev rte pieces returned.

640dD    //w1qdln = ttrqn1 + ttrqn2 + ttrqn3;
640dD    //w1qdlv = ttrqs1 + ttrqs2 + ttrqs3 + w1qdln;
640dD    //w1qcrt = ttrqc1 + ttrqc2 + ttrqc3;
640dD    //w1qprt = ttrqp1 + ttrqp2 + ttrqp3;
640dM    w1qdln = #fqn1 + #fqn2 + #fqn3;
640dM    w1qdlv = #fqs1 + #fqs2 + #fqs3 + w1qdln;
640dM    w1qcrt = #fqc1 + #fqc2 + #fqc3;
640dM    w1qprt = #fqp1 + #fqp2 + #fqp3;

         // Convert Start date

640dD    //if ttrsrd = 0;
640dM    if #fsrd = 0;
           w1strd = 0;
         else;
           $cvcmd = '*CMDMDY';
640dD      //$cvd8i = %char(ttrsrd);
640dM      $cvd8i = %char(#fsrd);
           cvtdte($cvtdt);
           w1strd = $cvd6o;
         endif;

         // Get truck

640aD    //chain ($iwhse: ttrrti) rtehed;
640dD    //chain ($pwhse: ttrrti) rtehed;
640dA    exec sql
640dA      select rhwhse into :wkwhse
640dA      from rtehed
640dA      where rhwhse = :$pwhse and rhrtid = :#frti;

640dD    //if  not %found;
640dA      if sqlstt <> sqlSuccess;
             w1truk = ' ';
640cA        eval kywhse = *zero;
640cA        eval kyrtid = ' ';
640dD        //eval rhstat = ' ';
640cA        eval #frstat = ' ';
           else;
640dD        //w1truk = rhtruk;
640dM        w1truk = #frtruk;
640dD       //eval kywhse = rhwhse;
640dM       eval kywhse = #frwhse;
640dD       //eval kyrtid = rhrtid;
640dM       eval kyrtid = #frrtid;
           endif;

         // User id
640dD    //w1unam = ttrusr;
640dM    w1unam = #fusr;

640cA    // Get total pieces ordered for open, built, and printed
640cA    // routes.  Get total pieces picked for closed and exported
640cA    // routes.

640cA    w1tpcs = 0;
640cA    setll %kds(keyWhsRtid) rtesum;
640cA    dow forever = forever;
640cA      reade %kds(keyWhsRtid) rtesum;
640cA      if %eof;
640cA        leave;
640cA      endif;
640dD      //if rhstat <= '4';
640cA      if #frstat <= '4';
640cA        w1tpcs = w1tpcs + rsordp;
640cA      else;
640cA        w1tpcs = w1tpcs + rspckp;
640cA      endif;
640cA    enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sfloption1 - Get entered option
     *----------------------------------------------------------------

      /free
       begsr sfloption1;

         recpos = csrrrn;

         if recpos = 0;
           leavesr;
         endif;

         optiontaken = ' ';
         *in21 = *off;

         dow  forever = forever;

           select;
             when curview = 2;
               readc sfl2;
             other;
               readc sfl1;
           endsl;

           if %eof;
            leave;
           endif;

           select;

             when %trim(option) = '12';
               optiontaken = 'StopDetail';
               recpos = rrn1;

650aA        when %trim(option) = '6';
650aA          optiontaken = 'RteReport';
650aA          recpos = rrn1;

           endsl;

           option = ' ';
           select;
             when curview = 2;
               update sfl2;
             other;
               update sfl1;
           endsl;

           leave;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                Screen Processing Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  screen1 - Process screen 1
     *----------------------------------------------------------------

      /free
       begsr screen1;

         // Initialize screen fields

         scrname = 'TR320.01';
         exsr inzcriteria1;

         exsr setcriteria1;

650aD    // scopt1 = '12=Stop details';
650aM    scopt1 = '6=Print Comp Rpt   12=Stop details';

         scopt2 = ' ';

         // If no parms are passed in, display F9 window.

         if noParmsPassed;
           exsr getcriteria1;
           if cfkey <> Enter;
             leavesr;
           endif;
         endif;

         // Do initial build and display of subfile

         exsr sflBldDisp;

         // Process subfile until user wants to leave

         dou (cfkey = F3);

           Write fkey1;
           if recpos > 0 and recpos <= lastrrn;
             rrn1 = recpos;
           else;
             rrn1 = 1;
           endif;
           select;
             when curview = 2;
               exfmt sf2ctl;
             other;
               exfmt sf1ctl;
           endsl;

           recpos = csrrrn;

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;

               select;

                  when optiontaken = 'StopDetail';
640aD               //tr325('*VIEW': ttrwhs: ttrrti: rtnCode: rtnMessage);
640aM               tr325('*VIEW': $pwhse: h1rtid: rtnCode: rtnMessage);

650aA             when optiontaken = 'RteReport';
650aA               tr340($pwhse: h1rtid);

               endsl;

             // F5 = Refresh

             when cfkey = F5;
               exsr sflBldDisp;
               cfkey = Enter;

             // F9 = Get Select/Sort criteria.

             when cfkey = F9;
               exsr getcriteria1;
               if cfkey = Enter;
                 exsr sflBldDisp;
               endif;
               cfkey = Enter;

             // F10 = Previous view.

             when cfkey = F10;
               if curview <= 1;
                 curview = maxview;
               else;
                 curview = curview - 1;
               endif;
               cfkey = Enter;

             // F11 = Next view

             When cfkey = F11;
               if curview >= maxview;
                 curview = 1;
               else;
                 curview = curview + 1;
               endif;
               cfkey = Enter;

             // F3 = Exit or F12 = Cancel

             when cfkey = F3 or cfkey = F12;
               exsr sc2;
             // Cleanup
               exsr zsclr;
               *inlr = *on;
               return;
               leave;

             // PageDown = More records

             When cfkey = PageDown;
               exsr sflbld1;

           EndSl;

         EndDo;

         ExSr sqlclean;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sc2 - Process screen 2
     *----------------------------------------------------------------

      /free
       begsr sc2;

         // Initialize screen fields

         exsr sc2Init;

         // Process subfile until user wants to leave

         dou (cfkey = F3);

           // Set ON alarm indicator if error occured

           if error = *on;
             *in98 = *on;
           endIf;

           // Overlay screen with error messages

           exsr zmdmsg;

           exfmt screen2;

           *in98 = *off;
           *in25 = *off;
           *in24 = *off;
           *in23 = *off;
           *in22 = *off;
           *in05 = *off;
           *in04 = *off;
           *in03 = *off;
           *in02 = *off;
           exsr zmcmsg;

           Select;

             // Enter

             When cfkey = Enter;
               exsr sc2vfy;
               if error;
                 iter;
               endif;

               $pwhse = w2whse;
               $prte  = w2rte;
640dA          $pprtd = wkprtd;
               $pdlvd = wkdlvd;
               $pusr  = w2usr;
               noParmsPassed = *off;
               exsr screen1;
               leave;

             // F5 = Refresh

             when cfkey = F5;
               exsr sc2init;
               cfkey = Enter;

             // F12 = Cancel

             when cfkey = F12;
               leave;

           EndSl;

         EndDo;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sc2init - Initialize screen2 fields.
     *----------------------------------------------------------------

      /free
       begsr sc2init;

         error = *off;
         exsr zmimsg;

         // Get default values for the user.

         getUser(#user: #whse: #emp#: #fnam: #init: #lnam: #whdp:
               #styp: #shft: #crew: #nhrs: #rtn: #BeltPrt: #Language);

         w2whse = #whse;
         w2rte  = '*ALL';
640dA    w2prtd = 0;
         w2dlvd = 0;
         w2usr  = '*ALL';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sc2vfy  - Verify screen2 fields.
     *----------------------------------------------------------------

      /free

       begsr sc2vfy;

         error = *off;
         msgk = *zero;
640dA    wkprtd = *zero;
         wkdlvd = *zero;

         // Verify warehouse

         exec sql
           select whcode into :wkwhse
           from warehs
           where whcode = :w2whse;

         if sqlstt <> sqlSuccess;
           error = *on;
           *in22 = *on;
           *in02 = *on;
           errmsg = 'Invalid Warehouse entered';
           exsr zm0105;
         endIf;

         // Verify route exists in TTRTE

         if w2rte  <> '*ALL';
           exec sql
             select ttrrte into :wkrte
             from ttrte
             where ttrrte = :w2rte and ttrwhs = :w2whse;

         // Sqlstt = '21000' when multiple recs found for route
           if sqlstt <> '21000' and sqlstt <> sqlSuccess;
             error = *on;
             *in23 = *on;
             *in03 = *on;
             errmsg = 'Invalid Route entered';
             exsr zm0105;
           endIf;
         endIf;
640dA
640dA    // Verify route printed date
640dA
         if w2prtd <> 0;
           $cvcmd = '*MDYEDT';
           $cvd6i = %char(w2prtd);
           $cvprg = #pgm;
           cvtdte($cvtdt);
          if $cvrtn = '*PGMQ   ';
            error = *on;
            *in26 = *on;
            *in06 = *on;
            errmsg = 'Date';
            #msgk = $cvmsg;
            exsr zm1007;
          endIf;
         endif;

         if w2prtd  <> 0;
           $cvcmd = '*MDYCMD';
           $cvd6i = %char(w2prtd);
           cvtdte($cvtdt);
           wkPrtd = $cvd8o;

           exec sql
             select rhprtd into :wkprt
             from rtehed
             where rhprtd = :wkPrtd and rhwhse = :w2whse;

         // Sqlstt = '21000' when multiple recs found for route
           if sqlstt <> '21000' and sqlstt <> sqlSuccess;
             error = *on;
             *in26 = *on;
             *in06 = *on;
             errmsg = 'No rtes for date entered';
             exsr zm0105;
           endIf;
         endIf;

         // Verify delivery date

         if w2dlvd <> 0;
           $cvcmd = '*MDYEDT';
           $cvd6i = %char(w2dlvd);
           $cvprg = #pgm;
           cvtdte($cvtdt);
          if $cvrtn = '*PGMQ   ';
            error = *on;
            *in24 = *on;
            *in04 = *on;
            errmsg = 'Date';
            #msgk = $cvmsg;
            exsr zm1007;
          endIf;
         endif;

         if w2dlvd  <> 0;
           $cvcmd = '*MDYCMD';
           $cvd6i = %char(w2dlvd);
           cvtdte($cvtdt);
           wkDlvd = $cvd8o;

           exec sql
             select ttrsrd into :wksrd
             from ttrte
720aD        //where ttrsrd = :wkDlvd and ttrwhs = :w2whse;
720aM        where ttrwhs = :w2whse and (ttrsrd = :wkDlvd or ttrsrd = 0);

         // Sqlstt = '21000' when multiple recs found for route
           if sqlstt <> '21000' and sqlstt <> sqlSuccess;
             error = *on;
             *in24 = *on;
             *in04 = *on;
             errmsg = 'No rtes for date entered';
             exsr zm0105;
           endIf;
         endIf;

         // Verify driver

         if  w2usr <> '*ALL';
         chain (w2usr) piruser;
         if  not %found;
             error = *on;
             *in25 = *on;
             *in05 = *on;
             errmsg = 'Invalid Driver entered';
             exsr zm0105;
         endif;
         endif;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                Print Processing Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  printit - Print list
     *----------------------------------------------------------------

      /free
       begsr printit;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printlist - Print list
     *----------------------------------------------------------------

      /free
       begsr printlist;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printhead - Print heading line
     *----------------------------------------------------------------

      /free
       begsr printhead;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printline - Print detail line
     *----------------------------------------------------------------

      /free
       begsr printline;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     Misc. Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  centerschead - Center characters in schead
     *----------------------------------------------------------------

      /free
       begsr centerschead;

         scheadlen = %len(%trim(schead));
         if scheadlen > 0
            and scheadlen < %size(schead);
              scpad = %int((%size(schead)-scheadlen)/2);
              schead = %subst(blanks:1:scpad)
                     + %trim(schead);
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getcriteria1 - Prompt user for select and sort criteria
     *----------------------------------------------------------------

      /free
       begsr getcriteria1;

         dou (cfkey = F3) or (cfkey = F12);

           // Set ON alarm indicator if error occured

           if error = *on;
             *in98 = *on;
           endIf;

           // Overlay screen with error messages

           exsr zmdmsg;

           exfmt window1;

           *in98 = *off;
640dA      *in26 = *off;
           *in25 = *off;
           *in24 = *off;
           *in23 = *off;
           *in22 = *off;
640dA      *in06 = *off;
           *in05 = *off;
           *in04 = *off;
           *in03 = *off;
           *in02 = *off;
           exsr zmcmsg;

           Select;

             // Enter

             When cfkey = Enter;
               exsr winvfy;
               if error;
                 iter;
               endif;

               $pwhse = w1whse;
               $prte  = w1rte;
640dA          $pprtd = wkprtd;
               $pdlvd = wkdlvd;
               $pusr  = w1usr;
               noParmsPassed = *off;
               exsr screen1;
               leave;

           EndSl;

         EndDo;

         // Set selection criteria.

         exsr setcriteria1;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  inzcriteria1 - Initialize criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr inzcriteria1;

         if $pwhse = 0;
           w1whse = 0;
         else;
           w1whse = $pwhse;
         endif;

         if $prte = ' ';
           w1rte = '*ALL';
         else;
           w1rte = $prte;
         endif;

640dA      w1prtd = 0;
           w1dlvd = 0;

650cA    if $pusr = ' ';
           w1usr = '*ALL';
650cA    else;
650cA      w1usr = $pusr;
650cA    endif;

640cD    // w1nscn = 'N';
640cD    // w1retn = 'N';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr setcriteria1;

         // Set sort order

         if w1sort <> 'A' and w1sort <> 'D';
           w1sort = 'A';
         endif;

         if w1oby <> '1' and w1oby <> '2';
           w1oby = '2';
         endif;

         select;

           when w1sort = 'D';
             sortorder1 = 'DESCEND';

           other;
             sortorder1 = 'ASCEND';

         endsl;

         // Create screen heading.

         schead = ' ';
         append1 = ' ';

         if w1sort = 'D';
           schead = %trimr(schead) + append1
                  + 'Descend';
           append1 = ',';
         else;
           schead = %trimr(schead) + append1
                  + 'Ascend';
           append1 = ',';
         endif;

         if w1oby = '2';
           schead = %trimr(schead) + append1
                  + 'By Delivery Date';
           append1 = ',';
         else;
           schead = %trimr(schead) + append1
                  + 'By Route';
           append1 = ',';
         endif;

         if w1rte <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Route=' + %trim(w1rte);
           append1 = ',';
         endif;

640dA    if w1prtd <> 0;
640dA      schead = %trimr(schead) + append1
640dA             + 'Rte Prtd Date=' + %trim(%editc(w1prtd:'Y'));
640dA      append1 = ',';
640dA    endif;

         if w1dlvd <> 0;
           schead = %trimr(schead) + append1
                  + 'Delivery Date=' + %trim(%editc(w1dlvd:'Y'));
           append1 = ',';
         endif;

         if w1usr <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Driver=' + %trim(w1usr);
           append1 = ',';
         endif;

         if append1 = ' ';
           schead = %trimr(schead) + ',Everything';
         endif;

         exsr centerschead;

       endsr;
      /end-free

     *---------------------------------------------------------------
     *  winvfy  - Verify window fields.
     *----------------------------------------------------------------

      /free

       begsr winvfy;

         error = *off;
         msgk = *zero;
640dA    wkprtd = *zero;
         wkdlvd = *zero;

         // Verify warehouse

         exec sql
           select whcode into :wkwhse
           from warehs
           where whcode = :w1whse;

         if sqlstt <> sqlSuccess;
           error = *on;
           *in22 = *on;
           *in02 = *on;
           errmsg = 'Invalid Warehouse entered';
           exsr zm0105;
         endIf;

         // Verify route exists in TTRTE

         if w1rte  <> '*ALL';
           exec sql
             select ttrrte into :wkrte
             from ttrte
             where ttrrte = :w1rte and ttrwhs = :w1whse;

         // Sqlstt = '21000' when multiple recs found for route
           if sqlstt <> '21000' and sqlstt <> sqlSuccess;
             error = *on;
             *in23 = *on;
             *in03 = *on;
             errmsg = 'Invalid Route entered';
             exsr zm0105;
           endIf;
         endIf;
640dA
640dA    // Verify route printed date
640dA
         if w1prtd <> 0;
           $cvcmd = '*MDYEDT';
           $cvd6i = %char(w1prtd);
           $cvprg = #pgm;
           cvtdte($cvtdt);
          if $cvrtn = '*PGMQ   ';
            error = *on;
            *in26 = *on;
            *in06 = *on;
            errmsg = 'Date';
            #msgk = $cvmsg;
            exsr zm1007;
          endIf;
         endif;

         if w1prtd  <> 0;
           $cvcmd = '*MDYCMD';
           $cvd6i = %char(w1prtd);
           cvtdte($cvtdt);
           wkPrtd = $cvd8o;

           exec sql
             select rhprtd into :wkprt
             from rtehed
             where rhprtd = :wkPrtd and rhwhse = :w1whse;

         // Sqlstt = '21000' when multiple recs found for route
           if sqlstt <> '21000' and sqlstt <> sqlSuccess;
             error = *on;
             *in26 = *on;
             *in06 = *on;
             errmsg = 'No rtes for date entered';
             exsr zm0105;
           endIf;
         endIf;

         // Verify delivery date

         if w1dlvd <> 0;
           $cvcmd = '*MDYEDT';
           $cvd6i = %char(w1dlvd);
           $cvprg = #pgm;
           cvtdte($cvtdt);
          if $cvrtn = '*PGMQ   ';
            error = *on;
            *in24 = *on;
            *in04 = *on;
            errmsg = 'Date';
            #msgk = $cvmsg;
            exsr zm1007;
          endIf;
         endif;

         if w1dlvd  <> 0;
           $cvcmd = '*MDYCMD';
           $cvd6i = %char(w1dlvd);
           cvtdte($cvtdt);
           wkDlvd = $cvd8o;

           exec sql
             select ttrsrd into :wksrd
             from ttrte
720aD        //where ttrsrd = :wkDlvd and ttrwhs = :w1whse;
720aM        where ttrwhs = :w1whse and (ttrsrd = :wkDlvd or ttrsrd = 0);

         // Sqlstt = '21000' when multiple recs found for route
           if sqlstt <> '21000' and sqlstt <> sqlSuccess;
             error = *on;
             *in24 = *on;
             *in04 = *on;
             errmsg = 'No rtes for date entered';
             exsr zm0105;
           endIf;
         endIf;

         // Verify driver

         if  w1usr <> '*ALL';
         chain (w1usr) piruser;
         if  not %found;
             error = *on;
             *in25 = *on;
             *in05 = *on;
             errmsg = 'Invalid Driver entered';
             exsr zm0105;
         endif;
         endif;

       endsr;

      /end-free

     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *    ZMCMSG  Clear message record subfile
     *---------------------------------------------------------------

      /free
       begsr zmcmsg;

         *in97 = *off;
         write  msgctl;
         msgk = *zeros;
         write  msgclr;
         #msgid = '*CLEAR ';
         #msgtp = '*NULL  ';
         exsr  zmpmsg;

       endsr;
      /end-free

     *---------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *---------------------------------------------------------------

      /free
       begsr zmdmsg;

         *in97 = *on;
         if  msgk > 0;
           write  msgctl;
           msgk = *zeros;
         endif;

       endsr;
      /end-free

     *---------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *---------------------------------------------------------------

      /free
       begsr zmimsg;

         #pgmq = #prog;
         exsr  zmcmsg;

       endsr;
      /end-free

     *---------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *---------------------------------------------------------------

      /free
       begsr zmpmsg;

         if $msgf = *blanks;
           $msgf = #msgf;
         endif;

         putmsg($msgf: #msgid: #msgtp: #msgdt: #pgmq: #msgk);

         if #msgid <> '*CLEAR ';
           msgk += 1;
           write  msgrec;
         endif;

         #msgdt = *blanks;
         #msgk = *blanks;

       endsr;
      /end-free

     *---------------------------------------------------------------
     *    ZMQMSG  Add message record to subfile from program queue
     *---------------------------------------------------------------

      /free
       begsr zmqmsg;

         msgk = msgk + 1;
         write  msgrec;

       endsr;
      /end-free

     *---------------------------------------------------------------
     *    ZSCLR   Clear screen
     *---------------------------------------------------------------

      /free
       begsr zsclr;

         write  clrscr;
         sclear = *on;

       endsr;
      /end-free

     *---------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *---------------------------------------------------------------

      /free
       begsr zmsmsg;

         if $msgf = *blanks;
           $msgf = #msgf;
         endif;

         putmsg($msgf: #msgid: #msgtp: #msgdt: #pgmq: #msgk);
         #msgdt = *blanks;
         $msgf = *blanks;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *      PIR0105  Generic message id.
     *----------------------------------------------------------------

      /free
       begsr zm0105;

         #msgid = 'PIR0105';
         #msgtp = '*DIAG  ';
         #msgdt = errmsg;
         exsr zmpmsg;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *      PIR1007  Invalid date entered.
     *----------------------------------------------------------------

      /free
       begsr zm1007;

         #msgid = 'PIR1007';
         #msgtp = '*DIAG  ';
         #msgdt = errmsg;
         exsr zmpmsg;

       endsr;
      /end-free

     *----------------------------------------------------------------
