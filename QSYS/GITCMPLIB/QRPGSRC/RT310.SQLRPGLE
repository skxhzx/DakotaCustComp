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
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RT310     Route cube summary
     *  09 March 2009
     *  Dave Sommerville
     *
     *  Revisions
     *
520 A*    03/09/09  DAS  5.20
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Frt310fm   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl2:rrn1)
     F                                     infds(info)

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

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D*rtehed        e ds
     D dsfields        ds
     D   w1rte1                       5
     D   w1rtid                       5
     D   rhimpd                       8  0
     D   w1type                       1
     D   w1ttlcube                    7  2
     D   w1clrcube                    7  2
     D   w1frzcube                    7  2
     D   w1stops                      2  0

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

600eA /Copy qcopysrc,c#pgminfds

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
     D maxview         s              1  0 inz(1)
     D newordpos       s              3  0 inz(0)
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
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')
     D sortorder2      s             10    inz(' ')
     D sortorder3      s             10    inz(' ')

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1dummy               50     50

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $popt    - Option
     *      $pwhse   - Warehouse
     *      $pwhdp   - Warehouse department
     *      $pvalue  - Value
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         // Process main screen.

         //if $pcmd = '*PRINT';
         //  exsr printit;
         //else;
           exsr screen1;
         //endif;

         *inlr = *on;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;
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


         // Create "where" clause.

         sqlwhere = ' ';
         append5  = 'WHERE';

         // Warehouse

         if w9whse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'rhwhse=' + %trim(%editc(w9whse:'P'));
           append5 = ' and ';
         endif;

         // Route status

           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'rhstat='
                    + sq + '6' + sq;
           append5 = ' and ';

         // Route

         if w9rte <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'rhrte='
                    + sq + %trim(w9rte) + sq;
           append5 = ' and ';
         endif;

         // Route Id

         if w9rtid <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'rhrtid='
                    + sq + %trim(w9rtid) + sq;
           append5 = ' and ';
         endif;

         // Route type

         if w9type <> 'B';
           if w9type = 'N';
             w9type = ' ';
           endif;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'rhtype='
                    + sq + %trim(w9type) + sq;
           append5 = ' and ';
           if w9type = ' ';
             w9type = 'N';
           endif;
         endif;

         // From date

         if w9frmdte > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'rhimpd>=' + %char(%date(w9FrmDte:*mdy):*iso0);
           append5 = ' and ';
         endif;

         // To date

         if w9todte > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'rhimpd<=' + %char(%date(w9ToDte:*mdy):*iso0);
           append5 = ' and ';
         endif;

         // Create "Order By" clauses.

               sqlorder = 'ORDER BY rhrte,rhimpd';

         // Create SQL statement.

         SqlStmt = 'SELECT rhrte, rhrtid, rhimpd, rhtype, '
                 + '('
                 +   'select ifnull(sum(lbcube),0) from label '
                 +   'where lbwhse=rhwhse and lbrte=rhrtid '
                 +     'and (lbtype='+sq+'O'+sq+' '
                 +          'or lbtype='+sq+'B'+sq+')'
                 + ') as ttlcube, '
                 + '('
                 +   'select ifnull(sum(lbcube),0) from label, worklbl '
                 +   'where lbwhse=rhwhse and lbrte=rhrtid '
                 +     'and (lbtype='+sq+'O'+sq+' '
                 +          'or lbtype='+sq+'B'+sq+')'
                 +     'and lwlbl#=lblbl# and lwcomp='+sq+'C'+sq
                 + ') as ttlclr, '
                 + '('
                 +   'select ifnull(sum(lbcube),0) from label, worklbl '
                 +   'where lbwhse=rhwhse and lbrte=rhrtid '
                 +     'and (lbtype='+sq+'O'+sq+' '
                 +          'or lbtype='+sq+'B'+sq+')'
                 +     'and lwlbl#=lblbl# and lwcomp='+sq+'F'+sq
                 + ') as ttlfrz, '
                 + '('
                 +   'select count(distinct lbstop) from label '
                 +   'where lbwhse=rhwhse and lbrte=rhrtid '
                 +     'and (lbtype='+sq+'O'+sq+' '
                 +          'or lbtype='+sq+'B'+sq+')'
                 + ') as ttlstops '
                 + 'from rtehed as r '
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

           exec sql FETCH NEXT FROM mycsr INTO :dsfields;

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
         *in90 = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill1  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill1;

         if rhimpd = 0;
           w1impd = 0;
         else;
           w1impd = %dec(%char(%date(rhimpd:*iso):*mdy0):6:0);
         endif;

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

             when %trim(option) = '2';
               optiontaken = 'Change';
               recpos = rrn1;

             when %trim(option) = '5';
               optiontaken = 'View';
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

         scrname = 'RT310.01';
         exsr inzcriteria1;

         exsr setcriteria1;

         scopt1 = ' ';
         scopt2 = ' ';

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

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;

               select;

                  when optiontaken = 'Change';
                    // lt830(' ': h1lcns);

                  when optiontaken = 'View';
                    //lt830('*VIEW': h1lcns);

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

         // Display window.

         exfmt window1;

         if cfkey = F3 or cfkey = F12;
           leavesr;
         endif;

         // Set selection criteria.

         exsr setcriteria1;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  inzcriteria1 - Initialize criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr inzcriteria1;

         w9whse = 1;
         w9rte = '*ALL';
         w9rtid = '*ALL';
         w9type = 'B';
         w9frmdte = %dec(%date()-%days(1):*mdy);
         w9todte = w9frmdte;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr setcriteria1;

         // Create screen heading.

         schead = ' ';
         append1 = ' ';

         if w9rte <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Rte=' + w9rte;
           append1 = ',';
         endif;

         if w9rtid <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Rtid=' + w9rtid;
           append1 = ',';
         endif;

         select;
           when w9type = 'N';
             schead = %trimr(schead) + append1
                    + 'Normal';
             append1 = ',';
           when w9type = 'W';
             schead = %trimr(schead) + append1
                    + 'Willcall';
             append1 = ',';
         endsl;

         if w9frmdte > 0;
           schead = %trimr(schead) + append1
                  // + 'Range '
                  +  %char(%date(w9frmdte:*mdy):*mdy/)
                  + ' - '
                  + %char(%date(w9todte:*mdy):*mdy/);
           append1 = ',';
         endif;

         if append1 = ' ';
           schead = %trimr(schead) + ',Everything';
         endif;

         exsr centerschead;

       endsr;
      /end-free
