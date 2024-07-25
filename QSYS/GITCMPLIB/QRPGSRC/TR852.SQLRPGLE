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
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TR852     Trax - Stop Level Options - Display
     *
     *  19 March 2012
     *  Retha Davis
     *
     *  Revisions
     *
640 A*    03/19/12  RBD  6.40
     *      - Created.
     *
650 A*    08/26/13  RBD  6.50
     *      - Recompiled, TTLOG file changed.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Ftr852FM   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F**                                   sfile(sfl2:rrn1)
     F                                     infds(info)
     F                                     sfile(msgrec:msgk)
     Fordh9     if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.putmsg
      /copy qcopysrc,p.tr854
      /copy qcopysrc,p.tr856

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
     *  File field data structure
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
     D sqlfields       c                   'ttpwhs,ttprti,ttpstp,ttprte,-
     D                                      ttpcce,ttpsig,ttppiv,ttppal,-
     D                                      ttpbul,0,'''

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $icmd           s              8
     D $iwhse          s              3  0
     D $irte           s              5
     D $istop          s              2  0
     D $irtn           s             10
     D $idev           s             10
     D $iform          s             10

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $prte           s                   like($irte)
     D $pstop          s                   like($istop)
     D $pdate          s              8  0
     D $pdev           s                   like($idev)
     D $pform          s                   like($iform)

     D $tcmd           s                   like($icmd)

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
     D rtnMessage      s             50
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
     D wkStop          s              2  0
     D wkDate          s              8  0
     D wkts9           s              8  0
     D wkWhse          s              3  0
     D b               s             10  0
     D chk4err         s               n
     D zmsflag         s               n
     D zmflag          s               n

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1rte                  1      5
     D  h1rtid                 6     10
     D  h1stop                11     12  0
     D  h1dummy              100    100

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure
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
     *  Data structures
     *----------------------------------------------------------------

     D wkdateDS        ds
     D  wkcmd                  1      8  0
     D  wkccyy                 1      4  0
     D  wkmm                   5      6  0
     D  wkdd                   7      8  0

     D EdtWkdate       ds
     D  Edtcmd                 1     10
     D  ccyy                   1      4  0
     D  dash1                  5      5    inz('-')
     D  mm                     6      7  0
     D  dash2                  8      8    inz('-')
     D  dd                     9     10  0

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $icmd    - *SPECIAL
     *                 *PRINT
     *      $iwhse   - Warehouse
     *      $irte    - Route
     *      $istop   - Stop
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
     C                   parm                    $istop
     C                   parm                    $idev
     C                   parm                    $iform
     C                   parm                    $irtn

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
      /end-free
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
      /free
           $pwhse = #whse;
         endif;

         if %parms >= 3 and $irte <> ' ';
           $prte = $irte;
           noParmsPassed = *off;
         else;
           $prte = ' ';
         endif;

         if %parms >= 4 and $istop <> 0;
           $pstop = $istop;
           noParmsPassed = *off;
         else;
           $pstop = 0;
         endif;

         if %parms >= 5;
           $pdev = $idev;
         else;
           $pdev = ' ';
         endif;

         if %parms >= 6;
           $pform = $iform;
         else;
           $pform = ' ';
         endif;

         exsr zzinz2;

         // -----------------------------------------------------------
         // Main Line
         // -----------------------------------------------------------

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

         w1sort = 'A';
         w1oby = '1';
         w1whse = 0;
         w1over = 'N';
         w1rte = '*ALL';
         w1stop = 0;

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

         sqlfrom = 'FROM ' + sqlfile
                 + 'LEFT OUTER JOIN ttlog '
                 +   'ON ttlrtid=ttprti ';

         // Create "where" clause.

         sqlwhere = ' ';
         append5  = 'WHERE';

         // Exclude downloaded and uploaded routes and routes which haven't
         // been written to TTLOG yet.

           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + '((ttlstatus<>'
                    + sq + '3' + sq
                    + ' and '
                    + 'ttlstatus<>'
                    + sq + '4' + sq
                    + ')'
                    + ' or '
                    + 'ifnull(ttlstatus,'
                    + sq + '@' + sq
                    + ')='
                    + sq + '@' + sq
                    + ')';
           append5 = ' and ';

         // Warehouse

         if w1whse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'ttpwhs=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';
         endif;

         // Overrides only : select recs with non-blank stop level options.
         // Only need to check one stop level opt, because when a user enters
         // one or more stop level options. all of them must be entered Y
         // or N, otherwise they'all all be blank.

         if w1over = 'Y';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + '(ttpcce='
                    + sq + 'Y' + sq
                    + ' or '
                    + 'ttpcce='
                    + sq + 'N' + sq
                    + ')';
           append5 = ' and ';
         endif;

         // Route

         if w1rte <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'ttprte='
                    + sq + %trim(w1rte) + sq;
           append5 = ' and ';
         endif;

         // Stop

         if w1stop > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'ttpstp=' + %trim(%editc(w1stop:'P'));
           append5 = ' and ';
         endif;

         // Create "Order By" clauses.

         select;

           when sortorder1 = 'DESCEND';
             if w1oby = '1';
               sqlorder = 'ORDER BY TTPRTE DESC';
             else;
               sqlorder = 'ORDER BY TTPRTI DESC';
             endif;

           other;
             if w1oby = '1';
               sqlorder = 'ORDER BY TTPRTE';
             else;
               sqlorder = 'ORDER BY TTPRTI';
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

           // Ignore warning 01503 " The number of result columns is
           // larger than the number of variables provided."

           if sqlstt <> sqlSuccess and sqlstt = '01503';
             exsr sflFill1;
             rrn1 = rrn1  + 1;
             if first;
               first = *off;
               recpos = rrn1;
             endif;
             option = ' ';
             write sfl1;
         //  write sfl2;
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
       //write sf2ctl;
         *in31 = *off;
         *in32 = *off;
         rrn1 = 0;
         lastrrn = 0;
         recpos = 0;
         *in84 = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill1  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill1;

         // Store hidden fields that aren't displayed on screen.

         h1rte  = ttprte;
         h1rtid = ttprti;
         h1stop = ttpstp;

         chain (ttpwhs: ttprti: ttpstp) ordh9;
         if %found;
           w1cnam = ohcnam;
         else;
           w1cnam = *blanks;
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

           select;
             when curview = 2;
         //    readc sfl2;
             other;
               readc sfl1;
           endsl;

           if %eof;
            leave;
           endif;

           select;

             when %trim(option) = '2';
               optiontaken = 'Change    ';
               recpos = rrn1;

             when %trim(option) = '4';
               optiontaken = 'Delete    ';
               recpos = rrn1;

           endsl;

           option = ' ';
           select;
             when curview = 2;
         //    update sfl2;
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

         scrname = 'TR852.01';
         exsr inzcriteria1;

         exsr setcriteria1;

         scopt1 = '2=Change  4=Delete';
         scopt2 = ' ';

         legnd1 = 'Enable Y/N: CCE=CredCrd  SIG=Signature';
         legnd2 = 'PIV=PrtInv  PAL=Pallets  BUL=BulkItems';

         $tcmd = *blanks;

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
         //    exfmt sf2ctl;
             other;
               exfmt sf1ctl;
           endsl;

           recpos = csrrrn;

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;

               select;

                  when optiontaken = 'Change    ';
                    $tcmd = '*CHANGE ';
                    tr854($tcmd: $pwhse: h1rte: h1rtid: h1stop:
                          rtnCode: rtnMessage);
                    exsr sflBldDisp;

                  when optiontaken = 'Delete    ';
                    exsr zsclr;
                    exfmt delrec;
                    if cfkey = F10;
                      tr856($tcmd: $pwhse: h1rtid: h1stop: rtnCode: rtnMessage);
                      exsr sflBldDisp;
                    endif;

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
           *in26 = *off;
           *in25 = *off;
           *in24 = *off;
           *in23 = *off;
           *in22 = *off;
           *in06 = *off;
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
               $pstop  = w1stop;
               $pdate = wkdate;
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

         if $pstop = 0;
           w1stop = 0;
         else;
           w1stop = $pstop;
         endif;

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

         schead = *blanks;
         append1 = ' ';

         if w1sort = 'D';
           schead = 'Descend';
           append1 = ',';
         else;
           schead = 'Ascend';
           append1 = ',';
         endif;

         if w1oby = '2';
           schead = %trimr(schead) + append1
                  + 'By Rte ID';
           append1 = ',';
         else;
           schead = %trimr(schead) + append1
                  + 'By Route';
           append1 = ',';
         endif;

           schead = %trimr(schead) + append1
                  + 'Whse=' + %trimL(%editc(w1whse:'P'));
           append1 = ',';

         if w1over = 'Y';
           schead = %trimr(schead) + append1
                  + 'Overrides only';
           append1 = ',';
         endif;

         if w1rte <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Rte=' + %trim(w1rte);
           append1 = ',';
         endif;

         if w1stop <> 0;
           schead = %trimr(schead) + append1
                  + 'Stop=' + %trimL(%editc(w1stop:'P'));
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
         wkdate = *zero;

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

         // Verify Overrides only = Y or N

         if w1over <> 'Y' and w1over <> 'N';
             error = *on;
             *in26 = *on;
             *in06 = *on;
             errmsg = 'Overrides only must be Y or N';
             exsr zm0105;
           endIf;

         // Verify route exists in TTSTP

         if w1rte  <> '*ALL';
           exec sql
             select ttprte into :wkrte
             from ttstp
             where ttprte = :w1rte and ttpwhs = :w1whse;

         // Sqlstt = '21000' when multiple recs found for route
           if sqlstt <> '21000' and sqlstt <> sqlSuccess;
             error = *on;
             *in23 = *on;
             *in03 = *on;
             errmsg = 'No Trax data exists for route '
                    + %trim(w1rte);
             exsr zm0105;
           endIf;
         endIf;

         // Verify route is not in downloaded or uploaded status in TTLOG

         if w1rte  <> '*ALL';
           exec sql
             select ttlrte into :wkrte
             from ttlog
             where ttlrte = :w1rte and ttlwhse = :w1whse and ttlstatus = '3'
             or
             ttlrte = :w1rte and ttlwhse = :w1whse and ttlstatus = '4';

         // Sqlstt = '21000' when multiple recs found for route
           if sqlstt = '21000' or sqlstt = sqlSuccess;
             error = *on;
             *in23 = *on;
             *in03 = *on;
             errmsg = 'Route '
                    + %trim(w1rte)
                    + ' has already been downloaded';
             exsr zm0105;
           endIf;
         endIf;

         // Verify route is entered if stop is entered

         if w1rte = '*ALL' and w1stop <> 0;
             error = *on;
             *in24 = *on;
             *in04 = *on;
             errmsg = 'When you enter Stop you must also enter '
                    + 'Route';
             exsr zm0105;
           endIf;

         // Verify route/stop exists in TTSTP

         if w1stop  <> 0;
           exec sql
             select ttpstp into :wkstop
             from ttstp
             where ttpstp = :w1stop and ttpwhs = :w1whse and ttprte = :w1rte;

         // Sqlstt = '21000' when multiple recs found for route
           if sqlstt <> '21000' and sqlstt <> sqlSuccess;
             error = *on;
             *in24 = *on;
             *in04 = *on;
             errmsg = 'No route/stop exists for '
                    + %trim(w1rte)
                    + '/'
                    + %trimL(%editc(w1stop:'P'));
             exsr zm0105;
           endIf;
         endIf;

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
     *      ZZINZ2  Extra program initialization.
     *----------------------------------------------------------------

      /free
       begsr zzinz2;

       endsr;
      /end-free

     *----------------------------------------------------------------
