      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SG110A) SRCFILE(XXX/QRPGSRC)
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
     *  SG110A    Staging Import/Export Maintenance
     *  21 March 2014
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    03/21/14  RTR  6.50
     *      - Created using LT320 as a base.
710 A*    05/16/17  MR   7.10
     *      - Recompile for EXPSPLBL file change.
     *
750 A*    05/26/21  MLB  7.50
     *      - Enh: Recompiled pgm due to new fields added to IMPSPCKQ.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fsg110fm   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     infds(info)
     Flogstg    o  a e           k disk    usropn

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

     D stgbatch      e ds

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

     D sqlfile         c                   'STGBATCH'
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
     D $istatus        s              5
     D $itype          s             10

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $pstatus        s                   like($istatus)
     D $ptype          s                   like($itype)

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
     D promptok        s               n
     D recpos          s                   like(rrn1)
     D resettext       s            200a
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')
     D userok          s               n

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1lcns                 1     15
     D  h1olcns               16     30
     D  h1item                31     45
     D  h1whdp                46     50
     D  h1disp                51     62
     D  h1lbl#                63     69S 0
     D  h1trn#                70     76S 0
     D  h1whse                77     79S 0
     D  h1adduc               80    105
     D  h1dummy              110    110

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------
     D sg112           pr                  extpgm('SG112')
     D  parms                        80    const

     D sg120           pr                  extpgm('SG120')
     D  cmd120                        8a   const
     D  whse120                       3  0 const
     D  batid120                     11a   const

     D sg125           pr                  extpgm('SG125')
     D  cmd125                        8a   const
     D  whse125                       3  0 const
     D  batid125                     11a   const

     D sg130           pr                  extpgm('SG130')
     D  cmd130                        8a   const
     D  whse130                       3  0 const
     D  batid130                     11a   const

     D sg135           pr                  extpgm('SG135')
     D  cmd135                        8a   const
     D  whse135                       3  0 const
     D  batid135                     11a   const

     D sg175           pr                  extpgm('SG175')
     D  cmd175                        8a   const
     D  whse175                       3  0 const
     D  batid175                     11a   const

     D sg180           pr                  extpgm('SG180')
     D  cmd180                        8a   const
     D  whse180                       3  0 const
     D  batid180                     11a   const

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

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $popt    - Option
     *      $pwhse   - Warehouse
     *      $pstatus - Status
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
     C                   parm                    $istatus
     C                   parm                    $itype

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

         if %parms >= 3 and $istatus <> ' ';
           $pstatus = $istatus;
           noParmsPassed = *off;
         else;
           $pstatus = *blanks;
         endif;

         if %parms >= 4 and $itype <> ' ';
           $ptype = $itype;
           noParmsPassed = *off;
         else;
           $ptype = *blanks;
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

         if w1whse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'sbwhse=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';
         endif;

         // Status

         if w1status <> '*ALL';
           if %scan('%':w1status) > 0;
             opcode = 'LIKE';
           else;
             opcode = '=';
           endif;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + '('
                    + 'sbstatus' + ' ' + %trim(opcode) + ' '
                    + sq + %trim(w1status) + sq
                    + ')';
           append5 = ' and ';
         endif;

         // Type

         if w1type <> '*ALL';
           if %scan('%':w1type) > 0;
             opcode = 'LIKE';
           else;
             opcode = '=';
           endif;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + '('
                    + 'sbtype' + ' ' + %trim(opcode) + ' '
                    + sq + %trim(w1type) + sq
                    + ')';
           append5 = ' and ';
         endif;

         // Create "Order By" clauses.

         select;

           when sortorder1 = 'DESCEND';
             if w1oby = '1';
               sqlorder = 'ORDER BY SBSTSTS DESC';
             else;
               sqlorder = 'ORDER BY SBTYPE DESC, SBSTSTS DESC';
             endif;

           other;
             if w1oby = '1';
               sqlorder = 'ORDER BY SBSTSTS';
             else;
               sqlorder = 'ORDER BY SBTYPE, SBSTSTS';
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

           exec sql FETCH NEXT FROM mycsr INTO :stgbatch;

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
           when sbstatus = 'E';
             sbstat1 = 'Err';
             *in81 = *on;
           when sbstatus = 'J';
             sbstat1 = 'Jbq';
           when sbstatus = 'P';
             sbstat1 = 'Prc';
           when sbstatus = 'R';
             sbstat1 = 'Rdy';
           when sbstatus = 'S';
             sbstat1 = 'Suc';
             *in82 = *on;
           when sbstatus = 'W';
             sbstat1 = 'Wrt';
           when sbstatus = 'X';
             sbstat1 = 'Wrt';
           other;
             sbstat1 = sbstatus;
         endsl;

         // format timestamp
         sbstst1 = %char(sbststs);
         %subst(sbstst1:11:1) = ' ';
         %subst(sbstst1:14:1) = ':';
         %subst(sbstst1:17:1) = ':';

         // build desc
         if %len(%trim(sbtext)) > 24;
           sbtext1 = %subst(sbtext:1:25) + '...';
         else;
           sbtext1 = sbtext;
         endif;
         h1whse = sbwhse;

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

             when %trim(option) = '5';
               optiontaken = 'View';
               recpos = rrn1;

             when %trim(option) = '12';
               optiontaken = 'ViewDetail';
               recpos = rrn1;

             when %trim(option) = 'RB'
              and sbstatus = 'E';
               optiontaken = 'ResetBatch';
               recpos = rrn1;

             when %trim(option) = 'CR'
              and sbstatus = 'E';
               optiontaken = 'ClearRoute';
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

         scopt2 = '5=View Summary  '
                + '12=View Detail  '
                + 'RB=Reset Batch  '
                + 'CR=Clear Route Errors';

         // If no parms are passed in, display F9 window.

       //if noParmsPassed;
       //  exsr getcriteria1;
       //  if cfkey <> Enter;
       //    leavesr;
       //  endif;
       //endif;

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

                  when optiontaken = 'ResetBatch';
                    pgmopt = 'RB';
                    exsr CheckUser;
                    if userok;
                      exsr PromptReset;
                    else;
                      exfmt window3;
                      promptok = *off;
                    endif;
                    if promptok;
                      exsr resetmain;
                    endif;
                    exsr sflBldDisp;
                    cfkey = Enter;

                  when optiontaken = 'ClearRoute';
                    if sbtype = 'IMPROUTE   '
                     or sbtype = 'IMPWILCAL  ';
                      pgmopt = 'CR';
                      exsr CheckUser;
                      if userok;
                        exsr PromptClear;
                      else;
                        exfmt window3;
                        promptok = *off;
                      endif;
                      if promptok;
                        exsr ClearRoute;
                      endif;
                    endif;
                    exsr sflBldDisp;
                    cfkey = Enter;

                  when optiontaken = 'View';
                    $pcmd2 = '*VIEW';
                    $pwhse2 = h1whse;
                    $pbatid2 = sbbatid;
                    sg112($parms);

                  when optiontaken = 'ViewDetail';
                    $pcmd2 = '*VIEW';
                    $pwhse2 = h1whse;
                    $pbatid2 = sbbatid;
                    exsr ViewDetail;
                    exsr sflBldDisp;
                    cfkey = Enter;

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
     *  CheckUser - Check User Security
     *----------------------------------------------------------------

     c     CheckUser     begsr

     c                   call      'CHKLIST'
     c                   parm                    #prog
     c                   parm                    pgmopt           20
     c                   parm                    #user
     c                   parm                    $rtncd            8

     c                   if        $rtncd = '*NO'
     c                   eval      userok = *off
     c                   else
     c                   eval      userok = *on
     c                   endif

     c                   endsr

     *----------------------------------------------------------------
     *  ClearRoute - Clear route errors.
     *----------------------------------------------------------------

      /free
       begsr ClearRoute;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  clrcriteria1 - Clear criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr clrcriteria1;

         w1whse = $pwhse;
         w1status = '*ALL';

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

         scrname = 'SG110A.01';
         w1sort = 'D';
         w1oby = '1';

         if $pwhse = 0;
           w1whse = 0;
         else;
           w1whse = $pwhse;
         endif;

         if $pstatus = ' ';
           w1status = 'E   ';
         else;
           w1status = $pstatus;
         endif;

         if $ptype = ' ';
           w1type = '*ALL';
         else;
           w1type = $ptype;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  promptclear - Prompt window for Clear Route Error.
     *----------------------------------------------------------------

      /free
       begsr promptclear;

         // Display window.
         *in42 = *on;

         dou forever = forever;
           exfmt window2;
           select;
             when cfkey = F8;
               promptok = *on;
               leave;
             when cfkey = F12;
               promptok = *off;
               leave;
           endsl;
         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  promptreset - Prompt window for Reset Batch.
     *----------------------------------------------------------------

      /free
       begsr promptreset;

         // Display window.
         *in41 = *on;

         dou forever = forever;
           exfmt window2;
           select;
             when cfkey = F8;
               promptok = *on;
               leave;
             when cfkey = F12;
               promptok = *off;
               leave;
           endsl;
         enddo;

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

         if w1oby = '1';
           schead = %trimr(schead) + append1
                  + 'By Timestamp';
           append1 = ',';
         else;
           schead = %trimr(schead) + append1
                  + 'By Type/Timestamp';
           append1 = ',';
         endif;

         if append1 = ' ' or append1 = '*ALL';
           schead = %trimr(schead) + ',Everything';
         endif;

         exsr centerschead;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetmain - Reset batch driver
     *----------------------------------------------------------------

      /free
       begsr resetmain;

         resettext = 'Error reset by ' + %trim(#user);
         error = *off;

         select;
           when sbtype = 'EXPADJUST  ';
             exsr resetexpadj;
           when sbtype = 'EXPITEMQTY ';
             exsr resetexpiq;
           when sbtype = 'EXPITEMQTY2';
             exsr resetexpiq2;
           when sbtype = 'EXPPCKLBL  ';
             exsr resetexppl;
           when sbtype = 'EXPPO      ';
             exsr resetexppo;
           when sbtype = 'EXPROUTE   ';
             exsr resetexprte;

           when sbtype = 'IMPHSTQTY  ';
             exsr resetimphq;
           when sbtype = 'IMPITEM    ';
             exsr resetimpitem;
           when sbtype = 'IMPPCKDEM  ';
             exsr resetimppd;
           when sbtype = 'IMPPO      ';
             exsr resetimppo;
           when sbtype = 'IMPQTYORD  ';
             exsr resetimpqo;
           when sbtype = 'IMPROUTE   '
             or sbtype = 'IMPWILCAL  ';
             exsr resetimprte;
           when sbtype = 'IMPSTUFIT  ';
             exsr resetimpstuf;
           other;
             error = *on;
         endsl;

         if error = *off;
           Exec sql update stgbatch
                       set SBSTATUS = 'R',
                           SBSTSTS = CURRENT_TIMESTAMP,
                           SBSTSUC = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                           SBTEXT = :resettext
                     where SBWHSE = :h1whse
                       and SBBATID = :sbbatid;
           // log it
           sglwhse = h1whse;
           sglbatid = sbbatid;
           sglrtid = *blanks;
           sgltype = '*RESETBAT';
           sgltext = resettext;
           exsr writelog;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetexpadj - Reset EXPADJUST batches
     *----------------------------------------------------------------

      /free
       begsr resetexpadj;

         Exec sql update expsadj
                     set IESTATUS  = 'R',
                         IESTSTS   = CURRENT_TIMESTAMP,
                         IESTSUC   = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         IETEXT    = :resettext
                   where IEWHSE    = :h1whse
                     and IEBATID   = :sbbatid;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetexpiq - Reset EXPITEMQTY batches
     *----------------------------------------------------------------

      /free
       begsr resetexpiq;

         Exec sql update expsqty
                     set QESTATUS  = 'R',
                         QESTSTS   = CURRENT_TIMESTAMP,
                         QESTSUC   = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         QETEXT    = :resettext
                   where QEWHSE    = :h1whse
                     and QEBATID   = :sbbatid;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetexpiq2 - Reset EXPITEMQTY2 batches
     *----------------------------------------------------------------

      /free
       begsr resetexpiq2;

         Exec sql update expsqty2
                     set QESTATUS  = 'R',
                         QESTSTS   = CURRENT_TIMESTAMP,
                         QESTSUC   = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         QETEXT    = :resettext
                   where QEWHSE    = :h1whse
                     and QEBATID   = :sbbatid;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetexppl - Reset EXPPCKLBL batches
     *----------------------------------------------------------------

      /free
       begsr resetexppl;

         Exec sql update expsplbl
                     set LBESTATUS = 'R',
                         LBESTSTS  = CURRENT_TIMESTAMP,
                         LBESTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         LBETEXT   = :resettext
                   where LBEWHS    = :h1whse
                     and LBEBATID  = :sbbatid;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetexppo - Reset EXPPO batches
     *----------------------------------------------------------------

      /free
       begsr resetexppo;

         Exec sql update expspod
                     set PEDSTATUS = 'R',
                         PEDSTSTS  = CURRENT_TIMESTAMP,
                         PEDSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         PEDTEXT   = :resettext
                   where PEDWHS    = :h1whse
                     and PEDBATID  = :sbbatid;
         Exec sql update expspoh
                     set PEHSTATUS = 'R',
                         PEHSTSTS  = CURRENT_TIMESTAMP,
                         PEHSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         PEHTEXT   = :resettext
                   where PEHWHS    = :h1whse
                     and PEHBATID  = :sbbatid;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetexprte - Reset EXPROUTE batches
     *----------------------------------------------------------------

      /free
       begsr resetexprte;

         Exec sql update expsordd
                     set OEDSTATUS = 'R',
                         OEDSTSTS  = CURRENT_TIMESTAMP,
                         OEDSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         OEDTEXT   = :resettext
                   where OEDWHS    = :h1whse
                     and OEDBATID  = :sbbatid;
         Exec sql update expsordl
                     set OELSTATUS = 'R',
                         OELSTSTS  = CURRENT_TIMESTAMP,
                         OELSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         OELTEXT   = :resettext
                   where OELWHS    = :h1whse
                     and OELBATID  = :sbbatid;
         Exec sql update expsordc
                     set OECSTATUS = 'R',
                         OECSTSTS  = CURRENT_TIMESTAMP,
                         OECSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         OECTEXT   = :resettext
                   where OECWHS    = :h1whse
                     and OECBATID  = :sbbatid;
         Exec sql update expsordp
                     set OEPSTATUS = 'R',
                         OEPSTSTS  = CURRENT_TIMESTAMP,
                         OEPSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         OEPTEXT   = :resettext
                   where OEPWHS    = :h1whse
                     and OEPBATID  = :sbbatid;
         Exec sql update expsordt
                     set OETSTATUS = 'R',
                         OETSTSTS  = CURRENT_TIMESTAMP,
                         OETSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         OETTEXT   = :resettext
                   where OETWHS    = :h1whse
                     and OETBATID  = :sbbatid;
         Exec sql update expsordh
                     set OEHSTATUS = 'R',
                         OEHSTSTS  = CURRENT_TIMESTAMP,
                         OEHSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         OEHTEXT   = :resettext
                   where OEHWHS    = :h1whse
                     and OEHBATID  = :sbbatid;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetimphq - Reset IMPHSTQTY batches
     *----------------------------------------------------------------

      /free
       begsr resetimphq;

         Exec sql update impspqty
                     set IJSTATUS  = 'R',
                         IJSTSTS   = CURRENT_TIMESTAMP,
                         IJSTSUC   = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         IJTEXT    = :resettext
                   where IJWHSE    = :h1whse
                     and IJBATID   = :sbbatid;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetimpitem - Reset IMPITEM batches
     *----------------------------------------------------------------

      /free
       begsr resetimpitem;

         Exec sql update impsitmn
                     set IUSTATUS = 'R',
                         IUSTSTS = CURRENT_TIMESTAMP,
                         IUSTSUC = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         IUTEXT = :resettext
                   where IUWHSE = :h1whse
                     and IUBATID = :sbbatid;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetimppd - Reset IMPPCKDEM batches
     *----------------------------------------------------------------

      /free
       begsr resetimppd;

         Exec sql update impspckq
                     set IPQSTATUS = 'R',
                         IPQSTSTS  = CURRENT_TIMESTAMP,
                         IPQSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         IPQTEXT   = :resettext
                   where IPQWHS    = :h1whse
                     and IPQBATID  = :sbbatid;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetimppo - Reset IMPPO batches
     *----------------------------------------------------------------

      /free
       begsr resetimppo;

         Exec sql update impspoh
                     set PIHSTATUS = 'R',
                         PIHSTSTS  = CURRENT_TIMESTAMP,
                         PIHSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         PIHTEXT   = :resettext
                   where PIHWHS   = :h1whse
                     and PIHBATID = :sbbatid;
         Exec sql update impspod
                     set PIDSTATUS = 'R',
                         PIDSTSTS  = CURRENT_TIMESTAMP,
                         PIDSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         PIDTEXT   = :resettext
                   where PIDWHS   = :h1whse
                     and PIDBATID = :sbbatid;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetimpqo - Reset IMPQTYORD batches
     *----------------------------------------------------------------

      /free
       begsr resetimpqo;

         Exec sql update impsitmo
                     set IJSTATUS  = 'R',
                         IJSTSTS   = CURRENT_TIMESTAMP,
                         IJSTSUC   = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         IJTEXT    = :resettext
                   where IJWHSE    = :h1whse
                     and IJBATID   = :sbbatid;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetimprte - Reset IMPROUTE batches
     *----------------------------------------------------------------

      /free
       begsr resetimprte;

         Exec sql update impsordd
                     set OIDSTATUS = 'R',
                         OIDSTSTS = CURRENT_TIMESTAMP,
                         OIDSTSUC = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         OIDTEXT = :resettext
                   where OIDWHS = :h1whse
                     and OIDBATID = :sbbatid;
         Exec sql update impsordh
                     set OIHSTATUS = 'R',
                         OIHSTSTS = CURRENT_TIMESTAMP,
                         OIHSTSUC = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         OIHTEXT = :resettext
                   where OIHWHS = :h1whse
                     and OIHBATID = :sbbatid;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  resetimpstuf - Reset IMPSTUFIT batches
     *----------------------------------------------------------------

      /free
       begsr resetimpstuf;

         Exec sql update impsstuf
                     set SISTATUS  = 'R',
                         SISTSTS   = CURRENT_TIMESTAMP,
                         SISTSUC   = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                         SITEXT    = :resettext
                   where SIWHSE    = :h1whse
                     and SIBATID   = :sbbatid;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ViewDetail - View batch header/detail
     *----------------------------------------------------------------

      /free
       begsr ViewDetail;

         select;

           when sbtype = 'IMPITEM  ';
             sg120($pcmd2: $pwhse2: $pbatid2);

           when sbtype = 'IMPROUTE '
             or sbtype = 'IMPWILCAL';
             sg125($pcmd2: $pwhse2: $pbatid2);

           when sbtype = 'IMPPO    ';
             sg130($pcmd2: $pwhse2: $pbatid2);

           when sbtype = 'IMPSTUFIT';
             sg135($pcmd2: $pwhse2: $pbatid2);

           when sbtype = 'EXPPO    ';
             sg175($pcmd2: $pwhse2: $pbatid2);

           when sbtype = 'EXPROUTE '
             or sbtype = 'EXPWILCAL';
             sg180($pcmd2: $pwhse2: $pbatid2);

         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  writelog - Write record to staging log file
     *----------------------------------------------------------------

      /free
       begsr WriteLog;

         open logstg;

         sgladdpgm = #prog;
         sgladdjusr = #user;
         sgladdjob = #job;
         sgladdnbr = #jobnbr;
         sgladdts = %timestamp();

         write(e) sglrec;

         close logstg;

       endsr;
      /end-free

