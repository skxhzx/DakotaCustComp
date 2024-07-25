      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SG131) SRCFILE(XXX/QRPGSRC)
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
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  SG131    Staging Import View Purchase Order Detail
     *  04 April 2014
     *  Rod Roller
     *
     *  Revisions
     *
650 A*    04/04/14  RTR  6.50
     *      - Created using SG126 as a base.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fsg131fm   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     infds(info)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.cvtqty
      /copy qcopysrc,p.bfcdteti

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

     D impspod       e ds

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

     D sqlfile         c                   'IMPSPOD'
     D sqlfields       c                   '*'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $icmd           s              8a
     D $iwhse          s              3  0
     D $ibatid         s             11a
     D $iordid         s              9a

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $pbatid         s                   like($ibatid)
     D $pordid         s                   like($iordid)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D append1         s              1
     D append5         s              5
     d client          s             10    inz
     D curview         s              1  0 inz(1)
     D first           s               n
     D lastrrn         s                   like(rrn1)
     D maxview         s              1  0 inz(5)
     D noParmsPassed   s               n
     D opcode          s              6
     D optiontaken     s             10    inz(' ')
     D recpos          s                   like(rrn1)
     D resettext       s            200a
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1item                31     45
     D  h1whdp                46     50
     D  h1disp                51     62
     D  h1lbl#                63     69S 0
     D  h1trn#                70     76S 0
     D  h1whse                77     79S 0
     D  h1batid               80     90
     D  h1dummy              110    110

     D $parms          ds
     D  $pcmd2                 1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse2               19     21  0
     D  $pbatid2              22     32
     D  $pordid2              33     41

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd    - Command
     *      $pwhse   - Warehouse
     *      $pbatid  - Batch ID
     *      $pordid  - Order ID
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
     C                   parm                    $ibatid
     C                   parm                    $iordid

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

         if %parms >= 3 and $ibatid <> ' ';
           $pbatid = $ibatid;
           noParmsPassed = *off;
         else;
           $pbatid = *blanks;
         endif;

         if %parms >= 4 and $iordid <> ' ';
           $pordid = $iordid;
           noParmsPassed = *off;
         else;
           $pordid = *blanks;
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

         *inlr = *on;
         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

      /end-free
     * Get client id.

     c                   call      'GETCLIENT'
     c                   parm                    client           10
     c                   parm                    clientloc        10
      /free
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

           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'pidwhs=' + %trim(%editc($pwhse:'P'));
           append5 = ' and ';

         // Batch

           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'pidbatid=' + %trim($pbatid);
           append5 = ' and ';

         // Order

           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'pidpo=' + %trim($pordid);
           append5 = ' and ';

         // Create "Order By" clauses.

         select;
           when sortorder1 = 'DESCEND';
             sqlorder = 'ORDER BY PIDPO DESC, PIDSEQ DESC';
           other;
             sqlorder = 'ORDER BY PIDPO, PIDSEQ';
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

           exec sql FETCH NEXT FROM mycsr INTO :impspod;

           If sqlstt = sqlSuccess;
             exsr sflFill1;
             rrn1 = rrn1  + 1;
             if first;
               first = *off;
               recpos = rrn1;
             endif;
             option = ' ';
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
           *in91 = *on;
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
         *in91 = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill1  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill1;

         *in81 = *off;
         *in82 = *off;
         select;
           when pidstatus = 'E';
             s1stat1 = 'Err';
             *in81 = *on;
           when pidstatus = 'P';
             s1stat1 = 'Prc';
           when pidstatus = 'R';
             s1stat1 = 'Rdy';
           when pidstatus = 'S';
             s1stat1 = 'Suc';
             *in82 = *on;
           when pidstatus = 'W';
             s1stat1 = 'Wrt';
           when pidstatus = 'X';
             s1stat1 = 'Wrt';
           other;
             s1stat1 = pidstatus;
         endsl;

         h1whse = pidwhs;
         h1batid = pidbatid;
         s1qty = %char(pidqo1) + '.' + %char(pidqo2) + '.' + %char(pidqo3);

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

           readc sfl1;
           if %eof;
             leave;
           endif;

           select;

             when %trim(option) = '12';
               optiontaken = 'ViewFull';
               recpos = rrn1;

           endsl;

           option = '  ';
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
         exsr inzcriteria1;

         exsr setcriteria1;

         scopt2 = '12=View Detail  ';

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
             when curview = 5;
             other;
               exfmt sf1ctl;
           endsl;

           recpos = csrrrn;

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;

               select;

                  when optiontaken = 'ViewFull';
                    exsr ViewFull;
                    exsr sflBldDisp;
                    cfkey = Enter;

               endsl;

             // F5 = Refresh

             when cfkey = F5;
               exsr sflBldDisp;
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

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getcriteria1 - Prompt user for select and sort criteria
     *----------------------------------------------------------------

      /free
       begsr getcriteria1;

         // Set selection criteria.

         exsr setcriteria1;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  inzcriteria1 - Initialize criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr inzcriteria1;

         scrname = 'SG131.01';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr setcriteria1;

         // Set sort order

         sortorder1 = 'ASCEND';

         // Create screen heading.

         schead = ' ';
         append1 = ' ';

         schead = 'Whse ' + %char($pwhse) + ', Batch ' + %trim($pbatid);
         exsr centerschead;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ViewFull - View Full Header Info
     *----------------------------------------------------------------

      /free
       begsr ViewFull;

         // Display detail screen
         dou (cfkey = F3);

           s2qty = %char(pidqo1) + '.' + %char(pidqo2) + '.' + %char(pidqo3);
           exfmt screen2;

           Select;
             // Enter
             when cfkey = Enter;
               leave;
             // F5 = Refresh
             when cfkey = F5;
               leave;
             // F12 = Cancel
             when cfkey = F12;
               leave;
           EndSl;

         EndDo;

       endsr;
      /end-free

