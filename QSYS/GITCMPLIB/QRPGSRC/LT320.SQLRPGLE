      /copy *libl/qcopysrc,hspecs
650aAH dftactgrp(*NO) actgrp(*NEW)
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
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  LT320     View LICLOG file
     *  25 February 2009
     *  Dave Sommerville
     *
     *  Revisions
     *
600 A*    02/25/09  DAS  6.00  P#00045
     *      - Created.
     *
600aA*    05/20/09  DAS  6.00a
     *      - Added 4th view
     *
600bA*    05/27/09  DAS  6.00b
     *      - Added option VT (view transaction) and
     *        VL (view label)
     *
600cA*    06/01/09  DAS  6.00c
     *      - Revised to stay on same subfile page when pressing
     *        function keys.
     *
600dA*    06/10/09  DAS  6.00d
     *      - Added tran# to parms and selection criteria.
     *
600eA*    07/01/09  DAS  6.00e
     *      - Added sql CONNECT RESET to ensure we are connected to db.
     *
610aA*    07/08/09  DAS  6.10a
     *      - Added 5=View to call LL830.
     *      - Added h1whse and h1adduc fields.
     *      - Changed length of sflhide from 100 to 110.
     *
610bA*    08/21/09  DAS  6.10b
     *      - Revised to display F9 window if no parms passed in.
     *
610cA*    11/03/10  DAS  6.10c
     *      - Revised to call LT325 for option 5=View instead of
     *        ll830.
     *
640aA*    06/02/11  DAS  6.40a
     *      - Recompiled because of change to LICLOG file.
     *
640bA*    12/12/12  RBD  6.40b
     *      - Changed format to lt32001.
     *      - Copied view 1 to new view 5.
     *      - Changed view 1. Whittled down Action Qty and Result
     *        Qty to 6 char. Removed License and Corr License cols.
     *        Expanded Emp# col to include last and first name. Added
     *        timestamp column.
     *
650aA*    02/12/13  LMC  6.50a
     *      - Enh: Add slot item to selection screen.
     *      - Add date range to selection screen.
     *      - Default date range to last 3 days.
     *      - Default slot item to item being passed in.
     *      - Add driitem to get the slot item for item selected.
     *
650bA*    04/02/13  LMC  6.50b
     *      - Enh: Add Action selection to screen.
650cA*    14/10/14  LMC  6.50c
     *      - Fix: Invalid date selection produces an error from my
     *      650a mod. If invalid from date or to date is entered
     *      selection screen will be redisplayed
700aA*    07/18/16  LMC  7.00a
     *      - Fix: When user presses enter from subfile display and
     *      no records exist. Session/Device error was occurring.
710aA*    12/21/17  NLK  7.10a  (was WSFa now standard)
     *    - Revised program to set from date to 7 days instead of 3.
     *      Wants to see a whole week of data.
740aA*    02/04/20  RH   7.40a
     *    - Revised program to default Hide User='Y'
     *----------------------------------------------------------------
     *  Client Custom Revisions: BFC
     *
BFCaA*  04/15/15  RBD  BFCa
     *    - Revised program to set from date to 0, Lyle wants to
     *      see all history for demo, not just the last 3 days.
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line Distributors Custom Mod
     *
CLDaA*  10/01/13  LMC  CLDa
     *    - Revised program to set from date to 0, client wants to
     *      see all history not just the last 3 days.
     *----------------------------------------------------------------
     *  Client Custom Revisions: WestSide Foods
     *
WSFa *  03/10/14  GJA  WSFa
     *    - Revised program to set from date to 7 days instead of 3.
     *      Wants to see a whole week of data.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Royal Foods
RYLa *  03/09/17  RH   RYLa
     *    - Revised program to set from date to 10 days instead of 3.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Holt Paper
HPC A*  01/27/21  MLB  HPC
     *    - Revised program to set from date to 30 days instead of 7.
     *
650aA*----------------------------------------------------------------
650aA*  Binding Directories
650aA*----------------------------------------------------------------

650aAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

640bDF*lt320fm   cf   e             workstn
650aDF*lt32001   cf   e             workstn
650bDF*lt32002   cf   e             workstn
650cDF*lt32003   cf   e             workstn
650cMFlt32004   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl2:rrn1)
     F                                     sfile(sfl3:rrn1)
600aAF                                     sfile(sfl4:rrn1)
640bAF                                     sfile(sfl5:rrn1)
     F                                     infds(info)
640bAFpiruser1  if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.cvtqty
      /copy qcopysrc,p.lp130
600bA /copy qcopysrc,p.lb830
600bA /copy qcopysrc,p.pt830
610aA /copy qcopysrc,p.ll830
610cA /copy qcopysrc,p.lt325
650aA /copy qcopysrc,p.bfcdteti
650aA /copy qcopysrc,p.clcdur2
650aA /copy qcopysrc,p.driitem
CLDaA*----------------------------------------------------------------
CLDaA* Client ID
CLDaA*----------------------------------------------------------------
BFCaA /COPY QCOPYSRC,ID#BFCDEMO
CLDaA /COPY QCOPYSRC,ID#CITYLIN
WSFaA /COPY QCOPYSRC,ID#WESTSID
RYLaA /COPY QCOPYSRC,ID#ROYAL
HPC A /COPY QCOPYSRC,ID#HPC
650aA*----------------------------------------------------------------
650aA*  DRI parameters
650aA*----------------------------------------------------------------
650aA
650aA /COPY *libl/qcopysrc,C#DRIPARMP
650aA /COPY *libl/qcopysrc,C#DRIPARMS
650aA
650aA*----------------------------------------------------------------
650aA*  Data Formats
650aA*----------------------------------------------------------------
650aA /COPY *libl/qcopysrc,C#ITEM
650aAD savever#        s                   like($itver#)

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

415aAD blanks          s            100    inz(' ')
     D SubfilePage     C                   Const(14)

650aA*----------------------------------------------------------------
650aA*  Verify Subprogram Variables.
650aA*----------------------------------------------------------------

650aAD $cdCmd          s              8
650aAD $cdDatein       s              8  0
650aAD $cdTimein       s              6  0
650aAD $cdYears        s              3  0
650aAD $cdMonths       s              3  0
650aAD $cdDays         s              3  0
650aAD $cdHours        s              3  0
650aAD $cdMinutes      s              3  0
650aAD $cdSeconds      s              3  0
650aAD $cdDateout      s              8  0
650aAD $cdTimeout      s              6  0

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D liclog        e ds

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

     D sqlfile         c                   'LICLOG'
     D sqlfields       c                   '*'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

600eA /Copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

415aAD $icmd           s              8
500eMD $iwhse          s              3  0
415aAD $iwhdp          s              5
415aAD $idisp          s             12
415aAD $iitem          s             15
415aAD $ilcns          s             15
415aAD $iemp#          s              5  0
415aAD $idev           s             10
415aAD $iform          s             10
415aAD $itrn#          s              7  0

415aAD $pcmd           s                   like($icmd)
415aAD $pwhse          s                   like($iwhse)
415aAD $pwhdp          s                   like($iwhdp)
415aAD $pdisp          s                   like($idisp)
415aAD $pitem          s                   like($iitem)
415aAD $plcns          s                   like($ilcns)
415aAD $pemp#          s                   like($iemp#)
415aAD $pdev           s                   like($idev)
415aAD $pform          s                   like($iform)
600dAD $ptrn#          s                   like($itrn#)

650aA*----------------------------------------------------------------
650aA*  Called program flags
650aA*----------------------------------------------------------------

650aAD driItemCalled   s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

415aAD $code           s              2    inz(' ')
415aAD $count          s              8b 0 inz(0)
415aAD append1         s              1
415aAD append5         s              5
CLDaAd client          s             10    inz
     D cqerm           s             60
500bAD cqqty1          s              7  0
500bAD cqqty2          s              7  0
500bAD cqqty3          s              7  0
     D cqrtn           s              8
     D cqum1           s              2
     D cqum2           s              2
     D cqum3           s              2
     D cqustr          s             17
500bAD curview         s              1  0 inz(1)
415aAD eorder1         s             20    inz(' ')
415aAD eorder2         s             20    inz(' ')
500cAD first           s               n
416aMD groupby         S            100a   inz(' ')
416aMD groupfields     S            100a   inz(' ')
415aAD iorder1         s             20    inz(' ')
415aAD iorder2         s             20    inz(' ')
     D lastrrn         s                   like(rrn1)
640bDD*maxview         s              1  0 inz(4)
640bMD maxview         s              1  0 inz(5)
415aAD newordpos       s              3  0 inz(0)
610bAD noParmsPassed   s               n
     D oldhead         s                   like(schead)
     D oldname         s                   like(scrname)
     D oldopt          s                   like(scopt1)
415aAD opcode          s              6
     D optiontaken     s             10    inz(' ')
415aAD order1          s             10    inz(' ')
415aAD order2          s             10    inz(' ')
416aMD orderby         S            100a   inz(' ')
415aAD orderfield      s             10    inz(' ')
415aAD orderposition   s              3  0 inz(0)
500bAD posfld          s              5    inz(' ')
500aAD recpos          s                   like(rrn1)
650cAD redisplay       s               n
415aAD scheadlen       s              3  0 inz(0)
415aAD scpad           s              3  0 inz(0)
415aAD sortorder1      s             10    inz(' ')
415aAD sortorder2      s             10    inz(' ')
415aAD sortorder3      s             10    inz(' ')
640bAD w1aqty10        s             10    inz(' ')
640bAD w1rqty10        s             10    inz(' ')
650aA*----------------------------------------------------------------
650aA*  Time variables
650aA*----------------------------------------------------------------
650aAD CurrStamploc    s               z
650aAD CurrStampsys    s               z
650aAD CurrStampuc     s               z
650aAD Fromdatestamp   s               z
650aAD todatestamp     s               z

650aAD bfcoffset       s              3  0 inz(0)
650aAD ucOffset        s              3  0

650aAD w1tdatwork      s              8  0
650aAD w1fdatwork      s              8  0

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
500cMD  h1lcns                 1     15
500cMD  h1olcns               16     30
500cMD  h1item                31     45
500cMD  h1whdp                46     50
500cMD  h1disp                51     62
600bMD  h1lbl#                63     69S 0
600bMD  h1trn#                70     76S 0
610aAD  h1whse                77     79S 0
610aAD  h1adduc               80    105
610aMD  h1dummy              110    110

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
     *      $popt    - Option
     *      $pwhse   - Warehouse
     *      $pwhdp   - Warehouse department
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
     C                   parm                    $iwhdp
     C                   parm                    $idisp
     C                   parm                    $iitem
     C                   parm                    $ilcns
     C                   parm                    $iemp#
     C                   parm                    $idev
     C                   parm                    $iform
600dAC                   parm                    $itrn#

      /free

610bA    noParmsPassed = *on;

         if %parms >= 1;
           $pcmd = $icmd;
         else;
           $pcmd = ' ';
         endif;

610bM    if %parms >= 2  and $iwhse > 0;
           $pwhse = $iwhse;
610bA      noParmsPassed = *off;
         else;
           $pwhse = 0;
         endif;

610bM    if %parms >= 3 and $iwhdp <> ' ';
           $pwhdp = $iwhdp;
610bA      noParmsPassed = *off;
         else;
           $pwhdp = ' ';
         endif;

610bA    if %parms >= 4 and $idisp <> ' ';
           $pdisp = $idisp;
610bA      noParmsPassed = *off;
         else;
           $pdisp = ' ';
         endif;

610bM    if %parms >= 5 and $iitem <> ' ';
           $pitem = $iitem;
610bA      noParmsPassed = *off;
         else;
           $pitem = ' ';
         endif;

610bM    if %parms >= 6 and $ilcns <> ' ';
           $plcns = $ilcns;
610bA      noParmsPassed = *off;
         else;
           $plcns = ' ';
         endif;

610bM    if %parms >= 7 and $iemp# > 0;
           $pemp# = $iemp#;
610bA      noParmsPassed = *off;
         else;
           $pemp# = 0;
         endif;

         if %parms >= 8;
           $pdev = $idev;
         else;
           $pdev = ' ';
         endif;

         if %parms >= 9;
           $pform = $iform;
         else;
           $pform = ' ';
         endif;

600dA    if %parms >= 10;
600dA      $ptrn# = $itrn#;
600dA    else;
600dA      $ptrn# = 0;
600dA    endif;

      /end-free

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

600eA    // Establish the connection to the remote machine. The -842 return
600eA    // code indicates that the connection is already established. If
600eA    // you want to connect to the local machine, use CONNECT RESET.
600eA
600eA    exec sql CONNECT RESET;
600eA
600eA    If sqlstt = sqlSuccess;
600eA    endif;

         // Process main screen.

         if $pcmd = '*PRINT';
           exsr printit;
         else;
           exsr screen1;
         endif;

         *inlr = *on;

650aA    if driItemCalled;
650aA      driItem('%CLOSE': $pprogram: $drireturn: $drimessage:
650aA               $dridata: $dridata2);
650aA    endif;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

CLDaA /end-free
CLDaA* Get client id.

CLDaAc                   call      'GETCLIENT'
CLDaAc                   parm                    client           10
CLDaAc                   parm                    clientloc        10
CLDaA /free
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
                    + 'llwhse=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';
         endif;

         // Department

         if w1whdp <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'llwhdp='
                    + sq + %trim(w1whdp) + sq;
           append5 = ' and ';
         endif;

         // Slot

         if w1slot <> '*ALL';
           if %scan('%':w1slot) > 0;
             opcode = 'LIKE';
           else;
             opcode = '=';
           endif;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + '('
                    + 'lldisp' + ' ' + %trim(opcode) + ' '
                    + sq + %trim(w1slot) + sq
                    + ')';
           append5 = ' and ';
         endif;

         //  Base Slot

         if w1base <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'llbase='
                    + sq + %trim(w1base) + sq;
           append5 = ' and ';
         endif;

         // Slot Item

         if w1item <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
650aD               //+ 'llitem='
650aM               + 'llsitem='
650aD               //+ sq + %trim(w1item) + sq;
650aM               + sq + %trim($ititem) + sq;
           append5 = ' and ';
         endif;

650aA    // License Item

650aA    if w1iteml <> '*ALL';
650aA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
650aA               + 'llitem='
650aA               +  sq + %trim(w1iteml) + sq;
650aA      append5 = ' and ';
650aA    endif;

         // License

         if w1lcns <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + '('
                    + 'lllcns='
                    + sq + %trim(w1lcns) + sq
                    + ' or '
                    + 'llolcns='
                    + sq + %trim(w1lcns) + sq
                    + ')';
           append5 = ' and ';
         endif;

650bA    // Action

650bA    if w1action <> 'ALL';
650bA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
650bA               + '('
650bA               + 'llaction='
650bA               + sq + %trim(w1action) + sq
650bA               + ')';
650bA      append5 = ' and ';
650bA    endif;

         // Employee #

         if w1emp# > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'lladdemp=' + %trim(%editc(w1emp#:'P'));
           append5 = ' and ';
         endif;

600dA    // Tran#
600dA
600dA    if w1trn# > 0;
600dA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
600dA               + 'lltrn#=' + %trim(%editc(w1trn#:'P'));
600dA      append5 = ' and ';
600dA    endif;

650aA    // Date Range
650aA
650aA    if w1fdat > 0;
650aA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
650aA               + 'lladdts>='
650aA               + sq + %char(fromdatestamp) + sq;
650aA      append5 = ' and ';
650aA    endif;

650aA    if w1tdat > 0;
650aA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
650aA               + 'lladdts<='
650aA               + sq + %char(todatestamp) + sq;
650aA      append5 = ' and ';
650aA    endif;

         // Hide USR recs

         if w1hide = 'Y';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'llaisl<>'
                    + sq + 'USR' + sq;
           append5 = ' and ';
         endif;

         // Create "Order By" clauses.

         select;

           when sortorder1 = 'DESCEND';
             if w1oby = '1';
               sqlorder = 'ORDER BY LLLCNS DESC';
             else;
               sqlorder = 'ORDER BY LLADDUC DESC';
             endif;

           other;
             if w1oby = '1';
               sqlorder = 'ORDER BY LLLCNS';
             else;
               sqlorder = 'ORDER BY LLADDUC';
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
         // it prepares th cursor.

         exec sql PREPARE sel FROM :SqlStmt;

         sqlstt = sqlstt;

         // Declare the SQL cursor to hold the data retrieved from the SELECT

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

           exec sql FETCH NEXT FROM mycsr INTO :liclog;

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
             write sfl3;
600aA        write sfl4;
640bA        write sfl5;
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
         write sf3ctl;
600aA    write sf4ctl;
640bA    write sf5ctl;
         *in31 = *off;
         *in32 = *off;
         rrn1 = 0;
         lastrrn = 0;
         recpos = 0;
         *in90 = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill1  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill1;

         // Store hiddent fields that aren't displayed on screen.

         h1lcns = lllcns;
         h1olcns = llolcns;
         h1item = llitem;
         h1whdp = llwhdp;
         h1disp = lldisp;
600bA    h1lbl# = lllbl#;
600bA    h1trn# = lltrn#;
610aA    h1whse = llwhse;
610aA    h1adduc = %char(lladduc);

         // Format action quantity string

         cqqty1 = llaqty1;
         cqqty2 = llaqty2;
         cqqty3 = llaqty3;
         cvtqty('*QTY2STR': #pgm:
                cqqty1: cqqty2: cqqty3:
                cqum1: cqum2: cqum3:
640bD    //     w1aqty: cqustr: cqrtn: cqerm);
640bM           w1aqty10: cqustr: cqrtn: cqerm);
640bD    //evalr w1aqty = %trimr(w1aqty);
640bA    w1aqty = %triml(w1aqty10);
640bM    evalr w1aqty = %trimr(w1aqty);

         // Format result quantity string

         cqqty1 = llrqty1;
         cqqty2 = llrqty2;
         cqqty3 = llrqty3;
         cvtqty('*QTY2STR': #pgm:
                cqqty1: cqqty2: cqqty3:
                cqum1: cqum2: cqum3:
640bD    //     w1rqty: cqustr: cqrtn: cqerm);
640bM           w1rqty10: cqustr: cqrtn: cqerm);
640bD    //evalr w1rqty = %trimr(w1rqty);
640bA    w1rqty = %triml(w1rqty10);
640bM    evalr w1rqty = %trimr(w1rqty);
600aA
600aA    // Convert Entered date
600aA
600aA    if llentd = 0;
600aA      w1entd = 0;
600aA    else;
600aA      $cvcmd = '*CMDMDY';
600aA      $cvd8i = %char(llentd);
600aA      cvtdte($cvtdt);
600aA      w1entd = $cvd6o;
600aA    endif;
600aA
600aA    // Convert Expiration date
600aA
600aA    if llexpd = 0;
600aA      w1expd = 0;
600aA    else;
600aA      $cvcmd = '*CMDMDY';
600aA      $cvd8i = %char(llexpd);
600aA      cvtdte($cvtdt);
600aA      w1expd = $cvd6o;
600aA    endif;

640bA    chain (lladdemp) piruser1;
640bA    if %found;
640bA      w1emp#nam = %trim(%editc(lladdemp:'4')) +
640bA                  ' ' + %trim(uslnam) +
640bA                  ', ' + %trim(usfnam);
640bA    else;
640bA      w1emp#nam = %trim(%editc(lladdemp:'4'));
640bA    endif;

640bA    w1added = %char(lladdts);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sfloption1 - Get entered option
     *----------------------------------------------------------------

      /free
       begsr sfloption1;

         recpos = csrrrn;

         if rrn1 = 0;
           leavesr;
         endif;

700aA    if csrrrn = 0;
700aA      leavesr;
700aA    endif;

         optiontaken = ' ';
         *in21 = *off;

         dow  forever = forever;

           select;
640bA        when curview = 5;
640bA          readc sfl5;
600aA        when curview = 4;
600aA          readc sfl4;
             when curview = 3;
               readc sfl3;
             when curview = 2;
               readc sfl2;
             other;
               readc sfl1;
           endsl;
           if %eof;
             leave;
           endif;

           select;

             when %trim(option) = '2';
               optiontaken = 'Change';
               recpos = rrn1;

             when %trim(option) = '5';
               optiontaken = 'View';
               recpos = rrn1;

             when %trim(option) = '71';
               optiontaken = 'LcnsLog';
               recpos = rrn1;

             when %trim(option) = '72';
               optiontaken = 'ItemLog';
               recpos = rrn1;

             when %trim(option) = '73';
               optiontaken = 'SlotLog';
               recpos = rrn1;

             when %trim(option) = '74';
               optiontaken = 'OLcnsLog';
               recpos = rrn1;

600bA        when %trim(option) = 'VL';
600bA          optiontaken = 'ViewLabel';
600bA          recpos = rrn1;

600bA        when %trim(option) = 'VT';
600bA          optiontaken = 'ViewTran';
600bA          recpos = rrn1;

610aA        when %trim(option) = 'V1';
610aA          optiontaken = 'V1';
610aA          recpos = rrn1;

           endsl;

           option = ' ';
           select;
640bA        when curview = 5;
640bA          update sfl5;
600aA        when curview = 4;
600aA          update sfl4;
             when curview = 3;
               update sfl3;
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

         scrname = 'LT320.01';
         w1sort = 'D';
600aM    w1oby = '2';
         exsr inzcriteria1;
650aA    exsr zzgettime;
650aA    exsr zzgetslotitem;

         exsr setcriteria1;

610aA    scopt1 = '5=View  '
610aM           + '71=Lcns hist  '
                + '72=Item hist  '
                + '73=Slot hist  '
                + '74=OLcns hist  ';
            //  + '75=Lcnse Info  ';

         scopt2 = ' ';

610bA    // If no parms are passed in, display F9 window.
610bA
610bA    if noParmsPassed;
610bA      exsr getcriteria1;
610bA      if cfkey <> Enter;
610bA        leavesr;
610bA      endif;
610bA    endif;

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
640bA        when curview = 5;
640bA          exfmt sf5ctl;
600aA        when curview = 4;
600aA          exfmt sf4ctl;
             when curview = 3;
               exfmt sf3ctl;
             when curview = 2;
               exfmt sf2ctl;
             other;
               exfmt sf1ctl;
           endsl;

600cA      recpos = csrrrn;

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;

               select;

                  when optiontaken = 'Change';
                    // lt830(' ': h1lcns);

                  when optiontaken = 'View';
610cD               //ll830('*VIEW': h1whse: h1lcns: h1adduc);
610cM               lt325('*VIEW': h1whse: h1lcns: h1adduc);

610aA             when optiontaken = 'V1';
610aA               ll830(' ': h1whse: h1lcns: h1adduc);

                  when optiontaken = 'LcnsLog';
                    exsr clrcriteria1;
                    w1lcns = h1lcns;
                    w1sort = 'A';
                    w1oby = '2';
                    exsr setcriteria1;
                    exsr sflBldDisp;

                  when optiontaken = 'ItemLog';
                    exsr clrcriteria1;
                    w1item = h1item;
                    exsr setcriteria1;
                    exsr sflBldDisp;

                  when optiontaken = 'SlotLog';
                    exsr clrcriteria1;
                    w1whdp = h1whdp;
                    w1slot = h1disp;
                    exsr setcriteria1;
                    exsr sflBldDisp;

                  when optiontaken = 'OLcnsLog';
                    exsr clrcriteria1;
                    w1lcns = h1olcns;
                    w1sort = 'A';
                    w1oby = '2';
                    exsr setcriteria1;
                    exsr sflBldDisp;

                  when optiontaken = 'LcnsInfo';
                    lp130('*NOOPT': h1lcns);

600bA             when optiontaken = 'ViewLabel';
600bA               lb830(' ': %editc(h1lbl#:'X'));

600bA             when optiontaken = 'ViewTran';
600bA               pt830(' ': %editc(h1trn#:'X'));

               endsl;

             // F5 = Refresh

             when cfkey = F5;
               exsr sflBldDisp;
               cfkey = Enter;

             // F9 = Get Select/Sort criteria.

             when cfkey = F9;
650cA          dou not %error;
                 exsr getcriteria1;
650cA          enddo;
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
     *  clrcriteria1 - Clear criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr clrcriteria1;

         w1whse = $pwhse;
         w1whdp = '*ALL';
         w1slot = '*ALL';
         w1item = '*ALL';
650aA    w1itemL= '*ALL';
         w1lcns = '*ALL';
650bA    w1action = 'ALL';
         w1emp# = 0;
600dA    w1trn# = 0;
         w1base = '*ALL';
740aM    w1hide = 'Y';
740aD    // w1hide = 'N';

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
650cA    // validate Dates
650cA    redisplay = *off;
650cA    *in22 = *off;
650cA    *in23 = *off;
650cA    test(de) *mdy w1fdat;
650cA    if %error;
650cA      redisplay = *on;
650cA      *in22 = *on;
650cA      leavesr;
650cA    else;
650cA      test(de) *mdy w1tdat;
650cA      if %error;
650cA        redisplay = *on;
650cA        *in23 = *on;
650cA        leavesr;
650cA      endif;
650cA    endif;
650aA    // Convert Dates.

650aA    exsr zzconvertdate;
650aA    exsr zzgetslotitem;

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

         if $pwhdp = ' ';
           w1whdp = '*ALL';
         else;
           w1whdp = $pwhdp;
         endif;

         if $pdisp = ' ';
           w1slot = '*ALL';
         else;
           w1slot = $pdisp;
         endif;

         if $pitem = ' ';
           w1item = '*ALL';
         else;
           w1item = $pitem;
         endif;

         if $plcns = ' ';
           w1lcns = '*ALL';
         else;
           w1lcns = $plcns;
           w1sort = 'A';
           w1oby = '2';
         endif;

         if $pemp# = 0;
           w1emp# = 0;
         else;
           w1emp# = $pemp#;
         endif;

600dA    if $ptrn# = 0;
600dA      w1trn# = 0;
600dA    else;
600dA      w1trn# = $ptrn#;
600dA    endif;

650bA    w1action= 'ALL';
650aA    w1itemL= '*ALL';
         w1base = '*ALL';
740aM    w1hide = 'Y';
740aD    // w1hide = 'N';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr setcriteria1;

         // Set sort order

         if w1sort <> 'A' and w1sort <> 'D';
           w1sort = 'D';
         endif;

         if w1oby <> '1' and w1oby <> '2';
           w1oby = '1';
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
                  + 'By Date';
           append1 = ',';
         else;
           schead = %trimr(schead) + append1
                  + 'By Lcns';
           append1 = ',';
         endif;

         if w1emp# <> 0;
           schead = %trimr(schead) + append1
                  + 'Emp#=' + %trim(%editc(w1emp#:'P'));
           append1 = ',';
         endif;

         if w1lcns <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Lcns=' + w1lcns;
           append1 = ',';
         endif;

650bA    if w1action <> '*ALL';
650bA      schead = %trimr(schead) + append1
650bA             + 'Act=' + w1action;
650bA      append1 = ',';
650bA    endif;

         if w1whdp <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Dept=' + w1whdp;
           append1 = ',';
         endif;

         if w1slot <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Slot=' + w1slot;
           append1 = ',';
         endif;

         if w1base <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Base=' + w1base;
           append1 = ',';
         endif;

         if w1item <> '*ALL';
           schead = %trimr(schead) + append1
650aD             //+ 'Item=' + w1item;
650aM             + 'Slot Item=' + w1item;
           append1 = ',';
         endif;

600dA    if w1trn# <> 0;
600dA      schead = %trimr(schead) + append1
600dA             + 'Trn#=' + %trim(%editc(w1trn#:'P'));
600dA      append1 = ',';
600dA    endif;

650aA    if w1fdat <> 0;
650aA      schead = %trimr(schead) + append1
650aA             + 'Date=' + %trim(%editc(w1fdat:'Y'));
650aA      if w1tdat <> 0;
650aA        schead = %trimr(schead) +
650aA                '-' + %trim(%editc(w1tdat:'Y'));
650aA        append1 = ',';
650aA      else;
650aA        schead = %trimr(schead) +
650aA                 '-Today';
650aA        append1 = ',';
650aA      endif;
650aA    else;
650aA      if w1tdat <> 0;
650aA        schead = %trimr(schead) + append1
650aA               + 'Date='
650aA               + 'Thru ' + %trim(%editc(w1tdat:'Y'));
650aA        append1 = ',';
650aA      else;
650aA        schead = %trimr(schead) + append1
650aA               + 'Date='
650aA               + 'Thru Today';
650aA        append1 = ',';
650aA      endif;
650aA    endif;

         if append1 = ' ';
           schead = %trimr(schead) + ',Everything';
         endif;

         exsr centerschead;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*
650aA*  ZZCONVERTDATE - Convert selection dates.
650aA*
650aA*----------------------------------------------------------------
650aA /free
650aA  begsr zzconvertdate;
         if w1fdat = 0;
           fromdatestamp = *loval;
         else;
           fromdatestamp = %timestamp(
                %char(%date(w1fdat:*MDY)) + '-' +
                '00.00.00' + '.000000');
         endif;

         if w1tdat = 0;
           todatestamp = *hival;
         else;
           todatestamp = %timestamp(
                %char(%date(w1tdat:*MDY)) + '-' +
                '23.59.59' + '.999999');
         endif;
650aA  endsr;
650aA /end-free
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZGETTIME Get Timestamp information.
650aA*
650aA*----------------------------------------------------------------
650aA /free
650aA  begsr zzgettime;
         getmicrotime(currstampuc:currstampsys);
         w1tdatwork = %dec(%date(currstampsys));
         // Convert to date for display

         if w1tdatwork = 0;
           w1tdat = 0;
         else;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(w1tdatwork);
           cvtdte($cvtdt);
           w1tdat = $cvd6o;
         endif;
         // Sub 3 from today's date to get from date.

         $cdcmd = '*SUB    ';
RYLaA    select;
710aD    // when client = westside;
710aD    //  $cddays = 6;
RYLaA    when client = royal;
RYLaA      $cddays = 9;
HPC A    when client = holtpaper;
HPC A      $cddays = 30;
WSFaA    // else;
RYLaA    other;
710aD    //  $cddays = 2;
710aM      $cddays = 6;
WSFaA    // endif;
RYLaA    endsl;
         clcdur2($cdcmd: w1tdatwork: $cdtimein: $cdyears:
                 $cdmonths: $cddays: $cdhours: $cdminutes:
                 $cdseconds: $cddateout: $cdtimeout);
         w1fdatwork = $cddateout;
BFCmA    if client = cityln or client = bfcdemo;
CLDaA      w1fdatwork = 0;
CLDaA    endif;
         // Convert to date for display

         if w1fdatwork = 0;
           w1fdat = 0;
         else;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(w1fdatwork);
           cvtdte($cvtdt);
           w1fdat = $cvd6o;
         endif;
         exsr zzconvertdate;
650aA  endsr;
650aA /end-free

650aA*----------------------------------------------------------------
650aA*
650aA*  ZZGETSLOTITEM - Get slot item.
650aA*
650aA*----------------------------------------------------------------
650aA /free
650aA  begsr zzgetslotitem;

         //exsr clr$item;
         error = *off;

         savever# = $itver#;
         clear $item;
         clear $item2;
         $itver# = savever#;

         $itWhse = $pwhse;
         $ititem = w1item;
         $dridata = $item;
         $dridata2 = $item2;

         driItemCalled = *on;
         driItem('%GETSLOT': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;


650aA  endsr;
650aA /end-free
