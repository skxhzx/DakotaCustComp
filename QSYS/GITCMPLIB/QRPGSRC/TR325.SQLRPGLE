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
     *  TR325     View Trax Stop file
     *  11 October 2011
     *  Ginger Andrews
     *
     *  Revisions
     *
640 A*    10/11/11  GJA  6.40
     *      - Created.
     *
640aA*    11/28/11  RBD  6.40a
     *      - Changed display of route id to route/route id.
     *      - Added display of customer name.
     *      - Shortened and moved stop memo to view 2.
     *      - Fixed end of subfile indicator.
     *
640bA*    02/17/12  RBD  6.40b
     *      - Increased sfl page from 12 to 14 to be consistent with
     *        other Trax view routes programs.
     *
640cA*    03/06/12  RBD  6.40c
     *      - Recompiled, TTSTP file changed.
     *
640dA*    06/28/12  RBD  6.40d
     *      - Changed screen format name to TR32501.
     *
650aA*    03/06/13  RBD  6.50a
     *      - Fix: Maxview should be 2.
     *      - Fix: FKEY1 was not displaying, should be on line 23.
     *      - Changed screen format name to TR32501.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

640dDF*tr325fm   cf   e             workstn
650aDF*tr32501   cf   e             workstn
650aMFtr32502   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl2:rrn1)
     F                                     infds(info)
     F                                     sfile(msgrec:msgk)
640aAFordh9     if   e           k disk
     Ftr325pr   O    E             printer usropn
     F                                     oflind(*IN90)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.cvtqty
      /copy qcopysrc,p.putmsg

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

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
640bDD*SubfilePage     C                   Const(12)
640bMD SubfilePage     C                   Const(14)

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D ttstp         e ds

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

     D sqlfile         c                   'TTSTP'
     D sqlfields       c                   '*'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D TR327           pr                  extpgm('TR327')
      * Input
     D   pCmd                         8    const
     D   pWhse                        3  0 const
     D   pRtid                        5    const
     D   pStop                        2  0 const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

     D $icmd           s              8
     D $iwhse          s              3  0
     D $irte           s              5
     D $idev           s             10
     D $iform          s             10

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $prte           s                   like($irte)
     D $pdlvd          s              6  0
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
650aDD*maxview         s              1  0 inz(4)
650aMD maxview         s              1  0 inz(2)
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
     D printflag       s               n
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
     D wkWhse          s              3  0
     D b               s             10  0
     D chk4err         s               n
     D zmsflag         s               n
     D zmflag          s               n
     D cure            s               n

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1lcns                 1     15
     D  h1olcns               16     30
     D  h1item                31     45
     D  h1whdp                46     50
     D  h1disp                51     62
     D  h1whse                63     65S 0
     D  h1qty1                66     70S 0
     D  h1qty2                71     75S 0
     D  h1qty3                76     80S 0
     D  h1base                81     92
     D  h1dummy              100    100

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

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

      /free

         noParmsPassed = *on;

         if %parms >= 1;
           $pcmd = $icmd;
         else;
           $pcmd = ' ';
         endif;

         if %parms >= 2  and $iwhse > 0;
           $pwhse = $iwhse;
           noParmsPassed = *off;
         else;
           $pwhse = 0;
         endif;

         if %parms >= 3 and $irte <> ' ';
           $prte  = $irte;
           noParmsPassed = *off;
         else;
           $prte  = ' ';
         endif;

      /end-free

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

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
         wkcount = 0;
         exsr zmimsg;

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

         // Create "where" clause.

         sqlwhere = ' ';
         append5  = 'WHERE';

         // Warehouse

         if w1whse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'ttpwhs=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';
         endif;

         // Route

         if w1rte  <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'ttprti='
                    + sq + %trim(w1rte) + sq;
           append5 = ' and ';
         endif;

         // Delivery Date

         if w1dlvd > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'ttpsrd' + %trim(%editc(w1dlvd:'P'));
           append5 = ' and ';
         endif;

         // Non-scanned items only

         if w1nscn  = 'Y';
         endif;

         // Returned items only

         if w1retn  = 'Y';
         endif;

         // Create "Order By" clauses.

         select;

           when sortorder1 = 'DESCEND';
             if w1oby = '1';
               sqlorder = 'ORDER BY TTPSTP DESC,TTPSRD DESC';
             else;
               sqlorder = 'ORDER BY TTPSRD DESC,TTPSTP DESC';
             endif;

           other;
             if w1oby = '1';
               sqlorder = 'ORDER BY TTPSTP,TTPSRD';
             else;
               sqlorder = 'ORDER BY TTPSTP,TTPRTI';
             endif;

         endsl;

         // Create SQL statement.

         SqlStmt = 'SELECT '
                 + %trimr(sqlfields) + ' '
                 + %trimr(sqlfrom) + ' '
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

           exec sql FETCH NEXT FROM mycsr INTO :ttstp;

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
           *in84 = *on;
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
640aD    // *in90 = *off;
640aM    *in84 = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill1  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill1;

         // Calculate totals:  pieces delivered, pieces non-scanned,
         // curr rte pieces returned, prev rte pieces returned.

         w1qdln = ttpqn1 + ttpqn2 + ttpqn3;
         w1qdlv = ttpqs1 + ttpqs2 + ttpqs3 + w1qdln;
         w1qcrt = ttpqc1 + ttpqc2 + ttpqc3;
         w1qprt = ttpqp1 + ttpqp2 + ttpqp3;

         // Convert Start date

         if ttpsrd = 0;
           w1strd = 0;
         else;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(ttpsrd);
           cvtdte($cvtdt);
           w1strd = $cvd6o;
         endif;

         if ttpfid = 0;
           w1find = 0;
         else;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(ttpfid);
           cvtdte($cvtdt);
           w1find = $cvd6o;
         endif;

         if ttpdlv = '0';
           w1pdlv = 'N';
         else;
           w1pdlv = 'Y';
         endif;

         if ttpscn = '0';
           w1pscn = 'N';
         else;
           w1pscn = 'Y';
         endif;

640aA    // Get customer name
640aA    w1cnam = *blanks;
640aA    exec sql
640aA      select ohcnam into :w1cnam
640aA      from ordh9
640aA      where ohwhse = :ttpwhs and ohrte = :ttprti and ohstop = :ttpstp;

640aA    // Move stop memo into smaller field
640aA    w1mem = ttpmem;

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
               optiontaken = 'ItemDetail';
               recpos = rrn1;

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

         scrname = 'TR325.01';
         w1sort = 'A';
         w1oby = '2';
         exsr inzcriteria1;

         exsr setcriteria1;

         scopt1 = '12=Item details';

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
           Write mkey1;
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

                  when optiontaken = 'ItemDetail';
                    tr327('*VIEW': ttpwhs: ttprti: ttpstp: rtnCode: rtnMessage);

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

             // F12 = Cancel

             when cfkey = F12;
               leave;

             // F21 = Print

             when cfkey = F21;
               exsr printit;

             // PageDown = More records

             When cfkey = PageDown;
               exsr sflbld1;

           EndSl;

         EndDo;

         ExSr sqlclean;

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
         w1sort = 'A';
         w1oby = '1';
      /end-free
     C                   time                    timecur
      /free
         wpdev = $pdev;
         wpform = $pform;

         exsr inzcriteria1;
         exsr setcriteria1;

         exsr printlist;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printlist - Print list
     *----------------------------------------------------------------

      /free
       begsr printlist;

         exsr sqlclean;
         exsr sqlbldstmt1;
         exsr sqlprep;
         exsr setupPrint;

         exsr prtRprt;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printhead - Print heading line
     *----------------------------------------------------------------

      /free
       begsr printhead;

        // Print report heading
         write head1;

         // Print Column Headings
         write columns1;

         *in90 = *off;
         *in91 = *on;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printline - Print detail line
     *----------------------------------------------------------------

      /free
       begsr printline;

         // See if heading needs to be printed.

         if *in90;
           exsr printhead;
         endif;

        // Print detail line

         write detail1;
         wkcount = wkcount + 1;
         printflag = *on;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  prtRprt -  Print the Report
     *----------------------------------------------------------------

      /free

       begsr prtRprt;

         // Open printer file.

         open(e)   tr325pr;
         if %error;
         endif;

         // Process the records in the SQL cursor until the return not = 0

         dou 1 <> 1;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr INTO :ttstp;

           If sqlstt = sqlSuccess;
             exsr sflFill1;

             if first;
               exsr printhead;
               first = *off;
               exsr printline;
               else;
               exsr printline;
             endif;
           else;
             leave;
             endif;

         enddo;

         if sqlstt = sqlNoMoreData;
         endif;

          if        not printflag;
            exsr      printhead;
            else;
            write total1;
          endif;

         // Close printer file.

         close(e)   tr325pr;
         if %error;
         endif;

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

           w1dlvd = 0;
           w1usr = '*ALL';
           w1nscn = 'N';
           w1retn = 'N';

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
640aA      wkrte = *blanks;
640aA      if $iwhse > 0;
640aA      // Get route
640aA        exec sql
640aA        select rhrte into :wkrte
640aA        from rtehed
640aA        where rhwhse = :$iwhse and rhrtid = :w1rte;
640aA      endif;
           schead = %trimr(schead) + append1
640aM             + 'Route=' + %trim(wkrte) + '/' + %trim(w1rte);
           append1 = ',';
         endif;

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

     *----------------------------------------------------------------
     *  getcriteria1 - Prompt user for select and sort criteria
     *----------------------------------------------------------------

      /free
       begsr getcriteria1;

         // Display window.

         exfmt window1;

         if cfkey = F3 or cfkey = F12;
           leavesr;
         endif;

         // Set selection criteria.

         exsr setcriteria1;

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
     *      PIR9906  Invalid date entered.
     *----------------------------------------------------------------

      /free
       begsr zm9906;

         #msgid = 'PIR9906';
         #msgtp = '*DIAG  ';
         #msgdt = errmsg;
         exsr zmpmsg;

       endsr;
      /end-free

     *----------------------------------------------------------------
600BA*  setupPrint - Setup Report
     *----------------------------------------------------------------

      /free
       begsr setupPrint;

         // Load device and form if not loaded.

         if wpdev = ' ';
           wpdev = '*JOB';
         endif;

         if wpform = ' ';
           wpform = '*STD';
         endif;

         //  Display window to get device and form to use (Only in *DISPLAY mode

         if $pcmd = '*VIEW';
           exfmt windowp;
         endif;

         if cfkey <> F3 and cfkey <> F12;

           // Override printer file.
             w1msg1 = 'Report has been printed';
             *in55 = *on;

           if wpdev = ' ';
             wpdev = '*JOB';
           endif;

           if wpform = ' ';
             wpform = '*STD';
           endif;

           qcmd = 'OVRPRTF '
                + 'FILE(LT330PR) '
                + 'OUTQ(*DEV) '
                + 'DEV(' + %trim(wpdev) + ') '
                + 'FORMTYPE(' + %trim(wpform) + ') ';

      /end-free
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
      /free

         endif;

         first = *on;
         wkCount = 0;
         printflag = *off;

       endsr;

      /end-free
     *----------------------------------------------------------------
