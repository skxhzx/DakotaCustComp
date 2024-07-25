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
      *               C$prt  = *NONE
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
     *  TR329     View Trax trax file
     *  11 October 2011
     *  Ginger Andrews
     *
     *  Revisions
     *
640 A*    10/11/11  GJA  6.40
     *      - Created.
     *
640aA*    02/22/12  RBD  6.40a
     *      - Fix: Changed heading; added route, stop, and item.
     *        Fixed delivery date logic and included scan time.
     *      - Changed scrn format to tr32901.
     *
650aA*    04/12/13  RBD  6.50a
     *      - Fix: Enclosed item in quotes in sqlwhere.  Had an item
     *        at SGC named 00MAIL which caused sql error 42601 because
     *        it saw MAIL in 00MAIL as an sql token.
     *
650bA*    11/26/13  RBD  6.50b
     *      - Changed screen format name to TR32902.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

640aDF*tr329fm   cf   e             workstn
650bDF*tr32901   cf   e             workstn
650bMFtr32902   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     infds(info)
     F                                     sfile(msgrec:msgk)
     Frtehed    if   e           k disk
     Ftr329pr   O    E             printer usropn
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
     D SubfilePage     C                   Const(14)

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D tttrx         e ds

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

     D sqlfile         c                   'TTTRX'
     D sqlfields       c                   '*'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds


     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

     D $icmd           s              8
     D $iwhse          s              3  0
     D $irti           s              5
     D $istp           s              2  0
     D $iitm           s             15
     D $idev           s             10
     D $iform          s             10

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $prti           s                   like($irti)
     D $pstp           s                   like($istp)
     D $pitm           s                   like($iitm)
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
     D maxview         s              1  0 inz(4)
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
     *      $irti    - Route ID
     *      $istp    - Stop
     *      $iitm    - Item
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
     C                   parm                    $irti
     C                   parm                    $istp
     C                   parm                    $iitm

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

         if %parms >= 3 and $irti <> ' ';
           $prti  = $irti;
           noParmsPassed = *off;
         else;
           $prti  = ' ';
         endif;

         if %parms >= 4 and $istp <> 0;
           $pstp  = $istp;
           noParmsPassed = *off;
         else;
           $pstp  = 0;
         endif;

         if %parms >= 5 and $iitm <> ' ';
           $pitm  = $iitm;
           noParmsPassed = *off;
         else;
           $pitm  = ' ';
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

640aA    chain ($iwhse: $irti) rtehed;
640aA    if  not %found;
640aA       rhrte = *blanks;
640aA    endif;

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

640aD    //if w1whse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
640aD    //         + 'ttxwhs=' + %trim(%editc(w1whse:'P'));
640aM               + 'ttxwhs=' + %trim(%editc($pwhse:'P'));
           append5 = ' and ';
640aD    //endif;

640aM    // Stop

640aM    if w1stp > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
640aD    //         + 'ttxsrd' + %trim(%editc(w1dlvd:'P'));
640aM               + 'ttxstp=' + %trim(%editc(w1stp:'P'));
           append5 = ' and ';
         endif;

         // Route

640aD    //if w1rte  <> ' ';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
640aD    //         + 'ttxrti=' + %trim(w1rte);
640aM               + 'ttxrti=' + %trim($prti);
           append5 = ' and ';
640aD    //endif;

         // Item

         if w1itm <> ' ';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
650aD    //         + 'ttxitm=' + %trim(w1itm);
650aA               + 'ttxitm='
650aA               + sq + %trim(w1itm) + sq;
           append5 = ' and ';
         endif;

640aA    // Trax#

640aA    if w1trx > 0;
640aA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
640aA               + 'ttxtrx=' + %trim(%editc(w1trx:'P'));
640aA      append5 = ' and ';
640aA    endif;

         // Non-scanned items only

640aD    //if w1nscn  = 'Y';
640aD    //endif;

         // Returned items only

640aD    //if w1retn  = 'Y';
640aD    //endif;

         // Create "Order By" clauses.

         select;

           when sortorder1 = 'DESCEND';
             if w1oby = '1';
               sqlorder = 'ORDER BY TTXTRX DESC,TTXSRD DESC';
             else;
640aD    //    sqlorder = 'ORDER BY TTXSRD DESC,TTXTRX DESC';
640aM          sqlorder = 'ORDER BY TTXSRD DESC,TTXSRT DESC,TTXTRX DESC';
             endif;

           other;
             if w1oby = '1';
               sqlorder = 'ORDER BY TTXTRX,TTXSRD';
             else;
640aD    //    sqlorder = 'ORDER BY TTXSRD,TTXTRX';
640aM          sqlorder = 'ORDER BY TTXSRD,TTXSRT,TTXTRX';
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

           exec sql FETCH NEXT FROM mycsr INTO :tttrx;

           If sqlstt = sqlSuccess;
             exsr sflFill1;
             rrn1 = rrn1  + 1;
             if first;
               first = *off;
               recpos = rrn1;
             endif;
             write sfl1;
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
640aA      *in84 = *on;
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

         w1qdln = ttxqn1 + ttxqn2 + ttxqn3;
         w1qdlv = ttxqs1 + ttxqs2 + ttxqs3 + w1qdln;
         w1qcrt = ttxqc1 + ttxqc2 + ttxqc3;
         w1qprt = ttxqp1 + ttxqp2 + ttxqp3;

         // Convert Start date

         if ttxsrd = 0;
           w1srd  = 0;
         else;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(ttxsrd);
           cvtdte($cvtdt);
           w1srd  = $cvd6o;
         endif;

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


               readc sfl1;

           if %eof;
            leave;
           endif;

           update sfl1;

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

         scrname = 'TR329.01';
         w1sort = 'A';
         w1oby = '2';
         exsr inzcriteria1;

         exsr setcriteria1;

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
640bA      Write mkey1;
           if recpos > 0 and recpos <= lastrrn;
             rrn1 = recpos;
           else;
             rrn1 = 1;
           endif;

               exfmt sf1ctl;

           recpos = csrrrn;

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;


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

         open(e)   tr329pr;
         if %error;
         endif;

         // Process the records in the SQL cursor until the return not = 0

         dou 1 <> 1;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr INTO :tttrx;

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

         close(e)   tr329pr;
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

640aD    //if $pwhse = 0;
640aD    //  w1whse = 0;
640aD    //else;
640aD    //  w1whse = $pwhse;
640aD    //endif;

640aD    //if $prti = ' ';
640aD    //  w1rte = '*ALL';
640aD    //else;
640aD    //  w1rte = $prti;
640aD    //endif;

         if $pstp = 0;
           w1stp = 0;
         else;
           w1stp = $pstp;
         endif;

         if $pitm  = ' ';
           w1itm = ' ';
         else;
           w1itm = $pitm;
         endif;

640aD    //  w1dlvd = 0;
           w1trx  = 0;
640aD    //  w1nscn = 'N';
640aD    //  w1retn = 'N';

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
640aM             + 'By Scan Dte&Time';
           append1 = ',';
         else;
           schead = %trimr(schead) + append1
640aD    //       + 'By Route';
640aM             + 'By Trax#';
           append1 = ',';
         endif;

           schead = %trimr(schead) + append1
640aD    //       + 'Route=' + %trim($prti);
640aM             + 'Rte=' + %trim(rhrte) + '/' + %trim($prti);
           append1 = ',';

640aM    if w1stp <> 0;
           schead = %trimr(schead) + append1
640aM             + 'Stop=' + %trim(%editc(w1stp:'P'));
           append1 = ',';
         endif;

640aM    if w1itm <> *blanks;
640aM      schead = %trimr(schead) + append1
640aM             + 'Item=' + %trim($pitm);
640aM      append1 = ',';
640aM    endif;

640aA    if w1trx <> 0;
640aA      schead = %trimr(schead) + append1
640aA             + 'Trax#=' + %trim(%editc(w1trx:'P'));
640aA      append1 = ',';
640aA    endif;

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

640aA          $pstp  = w1stp;
640aA          $pitm  = w1itm;

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
