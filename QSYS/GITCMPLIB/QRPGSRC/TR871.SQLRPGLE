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
     *  TR871     Routes List Display
     *  10 January 2012
     *  Retha Davis
     *
     *  Revisions
     *
640aA*    01/10/12  RBD  6.40a
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Ftr871FM   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl2:rrn1)
     F                                     infds(info)
     F                                     sfile(msgrec:msgk)
     Frtesum    if   e           k disk
     Fttrte     if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.putmsg
      /copy qcopysrc,p.clcdur2

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
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $cdCmd          s              8
     D $cdDatein       s              8  0
     D $cdTimein       s              6  0
     D $cdYears        s              3  0
     D $cdMonths       s              3  0
     D $cdDays         s              3  0
     D $cdHours        s              3  0
     D $cdMinutes      s              3  0
     D $cdSeconds      s              3  0
     D $cdDateout      s              8  0
     D $cdTimeout      s              6  0

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D rtehed        e ds

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

     D sqlfile         c                   'RTEHED'
     D sqlfields       c                   '*'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

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
     *  Key definitions
     *----------------------------------------------------------------

     D keyWhsRtid      ds
     D  kywhse                        3  0
     D  kyrtid                        5


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
     D today           s              8  0
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
     D wkExpo          s              8  0
     D wkDlvd          s              8  0
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
     D  h1rtid                 1      5
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

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $iwhse   - Warehouse
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

      /free

         noParmsPassed = *on;

         if %parms >= 1 and $iwhse > 0;
           $pwhse = $iwhse;
           noParmsPassed = *off;
         else;
           $pwhse = 0;
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

             exsr screen1;

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

         // Initialize sort criteria

         w1sort = 'A';
         w1oby = '1';

         // Initialize exported date selection to yesterday's date
         // so that routes exported yesterday or today are initially
         // displayed.

         // Convert today's date into century format.

           $cvcmd = '*CURCMD';
           cvtdte($cvtdt);
           today = $cvd8o;

         // Sub 1 from today's date to get yesterday's date.

           $cdcmd = '*SUB    ';
           $cddays = 1;
           clcdur2($cdcmd: today: $cdtimein: $cdyears:
                    $cdmonths: $cddays: $cdhours: $cdminutes:
                    $cdseconds: $cddateout: $cdtimeout);
           wkexpo = $cddateout;

         // Convert exported work date to exported display date.

           $cvcmd = '*CMDMDY';
           $cvd8i = %char(wkexpo);
           cvtdte($cvtdt);
           w1expo = $cvd6o;

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

         // Route type normal

           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'rhtype='
                    + sq + ' ' + sq;
           append5 = ' and ';

         // Warehouse

         if w1whse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'rhwhse=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';
         endif;

         //  Route or generic route

         if w1rte <> '*ALL';
           if %scan('%':w1rte) > 0;
             opcode = 'LIKE';
           else;
             opcode = '=';
           endif;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'rhrte' + ' ' + %trim(opcode) + ' '
                    + sq + %trim(w1rte) + sq;
           append5 = ' and ';
         endif;

         // Route status' selected by user

         if w1open = 'Y' or w1bilt = 'Y' or w1prnt = 'Y'
            or w1clos = 'Y' or w1expo > 0;
              sqlwhere = %trimr(sqlwhere) + ' and (';
              append5 = '';

              if w1open = 'Y';
                sqlwhere = %trimr(sqlwhere) + append5 + ' '
                         + 'rhstat=' + sq + '1' + sq;
                append5 = ' or ';
              endif;

              if w1bilt = 'Y';
                sqlwhere = %trimr(sqlwhere) + append5 + ' '
                         + 'rhstat=' + sq + '2' + sq;
                append5 = ' or ';
                sqlwhere = %trimr(sqlwhere) + append5 + ' '
                         + 'rhstat=' + sq + '3' + sq;
                append5 = ' or ';
              endif;

              if w1prnt = 'Y';
                sqlwhere = %trimr(sqlwhere) + append5 + ' '
                         + 'rhstat=' + sq + '4' + sq;
                append5 = ' or ';
              endif;

              if w1clos = 'Y';
                sqlwhere = %trimr(sqlwhere) + append5 + ' '
                         + 'rhstat=' + sq + '5' + sq;
                append5 = ' or ';
              endif;

              if w1expo > 0;
                sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'rhexpd>=' + %trim(%editc(wkExpo:'P'));
                append5 = ' or ';
              endif;

              sqlwhere = %trimr(sqlwhere) + ')';
              append5 = ' and ';

            endif;

         //---------------------------------


         // Create "Order By" clauses.

         select;

           when sortorder1 = 'DESCEND';
             if w1oby = '1';
               sqlorder = 'ORDER BY RHRTE DESC,RHRTID DESC';
             else;
               sqlorder = 'ORDER BY RHRTID DESC';
             endif;

           other;
             if w1oby = '1';
               sqlorder = 'ORDER BY RHRTE,RHRTID';
             else;
               sqlorder = 'ORDER BY RHRTID';
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

           exec sql FETCH NEXT FROM mycsr INTO :rtehed;

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
         *in84 = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill1  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill1;

         // Status description

         select;
           when rhstat = '1';
             w1stat = 'OPEN';
           when rhstat = '2' or rhstat = '3';
             w1stat = 'BUILT';
           when rhstat = '4';
             w1stat = 'PRINTED';
           when rhstat = '5';
             w1stat = 'CLOSED';
           when rhstat = '6';
             w1stat = 'EXPORTED';
         endsl;

         // Get driver name.

         eval kywhse = rhwhse;
         eval kyrtid = rhrtid;
         eval w1unam = *blanks;
          chain %kds(keyWhsRtid) ttrte;
         if %found(ttrte);
          eval w1unam = ttrusr;
         endif;

         // Get total pieces ordered for open, built, and printed
         // routes.  Get total pieces picked for closed and exported
         // routes.

         w1pcs = 0;
         setll %kds(keyWhsRtid) rtesum;
         dow forever = forever;
           reade %kds(keyWhsRtid) rtesum;
           if %eof;
             leave;
           endif;
           if rhstat <= '4';
             w1pcs = w1pcs + rsordp;
           else;
             w1pcs = w1pcs + rspckp;
           endif;
         enddo;

         // Convert imported date

         if rhimpd = 0;
           w1impd = 0;
         else;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(rhimpd);
           cvtdte($cvtdt);
           w1impd = $cvd6o;
         endif;

         // Convert built date

         if rhbldd = 0;
           w2bldd = 0;
         else;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(rhbldd);
           cvtdte($cvtdt);
           w2bldd = $cvd6o;
         endif;

         // Convert printed date

         if rhprtd = 0;
           w2prtd = 0;
         else;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(rhprtd);
           cvtdte($cvtdt);
           w2prtd = $cvd6o;
         endif;

         // Convert exported date

         if rhexpd = 0;
           w2expd = 0;
         else;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(rhexpd);
           cvtdte($cvtdt);
           w2expd = $cvd6o;
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

         scrname = 'TR871.01';
         exsr inzcriteria1;

         exsr setcriteria1;

         scopt1 = ' ';

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

                  when optiontaken = ' ';

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
     *                Print Processing Subroutines
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
           *in30 = *off;
           *in29 = *off;
           *in28 = *off;
           *in27 = *off;
           *in26 = *off;
           *in25 = *off;
           *in24 = *off;
           *in23 = *off;
           *in22 = *off;
           *in10 = *off;
           *in09 = *off;
           *in08 = *off;
           *in07 = *off;
           *in06 = *off;
           *in05 = *off;
           *in04 = *off;
           *in03 = *off;
           *in02 = *off;
           exsr zmcmsg;

               exsr winvfy;
               if error;
                 iter;
               endif;

         // Set selection criteria.

         exsr setcriteria1;

         leave;

         EndDo;

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

         w1rte = '*ALL';
         w1open = 'Y';
         w1bilt = 'Y';
         w1prnt = 'Y';
         w1clos = 'Y';

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
                  + 'By Rte Id';
           append1 = ',';
         else;
           schead = %trimr(schead) + append1
                  + 'By Rte';
           append1 = ',';
         endif;

         //  Route

         if w1rte <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Rte=' + %trim(w1rte);
           append1 = ',';
         endif;

         //  Route status

         if w1open = 'Y';
           schead = %trimr(schead) + append1
                  + 'Open';
           append1 = ',';
         endif;

         if w1bilt = 'Y';
           schead = %trimr(schead) + append1
                  + 'Built';
           append1 = ',';
         endif;

         if w1prnt = 'Y';
           schead = %trimr(schead) + append1
                  + 'Printed';
           append1 = ',';
         endif;

         if w1clos = 'Y';
           schead = %trimr(schead) + append1
                  + 'Closed';
           append1 = ',';
         endif;

         if w1expo > 0;
           schead = %trimr(schead) + append1
                  + 'Exported ' + %trim(%editc(w1expo:'Y')) + ' or later';
           append1 = ',';
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
         wkexpo = *zero;

         // Verify warehouse

         exec sql
           select whcode into :wkwhse
           from warehs
           where whcode = :w1whse;

         if sqlstt <> sqlSuccess;
           error = *on;
           *in24 = *on;
           *in04 = *on;
           errmsg = 'Invalid Warehouse entered';
           exsr zm0105;
         endIf;

         // Verify route status Y/N

         if w1open <> 'Y' and w1open <> 'N';
           error = *on;
           *in25 = *on;
           *in05 = *on;
           errmsg = 'Open must be Y or N';
           exsr zm0105;
         endIf;

         if w1bilt <> 'Y' and w1bilt <> 'N';
           error = *on;
           *in26 = *on;
           *in06 = *on;
           errmsg = 'Built must be Y or N';
           exsr zm0105;
         endIf;

         if w1prnt <> 'Y' and w1prnt <> 'N';
           error = *on;
           *in27 = *on;
           *in07 = *on;
           errmsg = 'Printed must be Y or N';
           exsr zm0105;
         endIf;

         if w1clos <> 'Y' and w1clos <> 'N';
           error = *on;
           *in28 = *on;
           *in08 = *on;
           errmsg = 'Closed must be Y or N';
           exsr zm0105;
         endIf;

         // Verify exported date

         if w1expo <> 0;
           $cvcmd = '*MDYEDT';
           $cvd6i = %char(w1expo);
           $cvprg = #pgm;
           cvtdte($cvtdt);
           if $cvrtn = '*PGMQ   ';
             error = *on;
             *in29 = *on;
             *in09 = *on;
             errmsg = 'Date';
             #msgk = $cvmsg;
             exsr zm1007;
           endIf;
         endif;

         if w1expo  <> 0;
           $cvcmd = '*MDYCMD';
           $cvd6i = %char(w1expo);
           cvtdte($cvtdt);
           wkExpo = $cvd8o;
         endif;

         if w1open = 'N' and w1bilt = 'N' and w1prnt = 'N'
            and w1clos = 'N' and w1expo = 0;
              error = *on;
              *in25 = *on;
              *in05 = *on;
              errmsg = 'Please make a route status selection';
              exsr zm0105;
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
