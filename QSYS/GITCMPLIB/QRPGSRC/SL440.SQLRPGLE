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
     *  SL440     View slot breakdown
     *  13 May 2011
     *  Dave Sommerville
     *
     *  Revisions
     *
640 A*    05/13/11  DAS  6.11
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fsl440fm   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl2:rrn1)
     F                                     infds(info)
     F                                     sfile(msgrec:msgk)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.putmsg

     *----------------------------------------------------------------
     *  Client id's
     *----------------------------------------------------------------

      /copy qcopysrc,id#eastlan

610fA*----------------------------------------------------------------
610fA*  Data structure for error message parameters
610fA*----------------------------------------------------------------
610fA
610fAD $mdt            ds
610fAD  errmsg                 1     50
610fA
610fA*----------------------------------------------------------------
610fA*  Message control
610fA*----------------------------------------------------------------
610fA
610fAD #msgf           c                   const('PIRMSGF   ')
610fA
610fAD                 ds
610fAD  #msgdt                 1    128
610fAD  $md                    1    128
610fAD                                     DIM(128)

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

415aAD blanks          s            100    inz(' ')
     D SubfilePage     C                   Const(99)

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D slot          e ds

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

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

415aAD $icmd           s              8
500eMD $iwhse          s              3  0
415aAD $iitem          s             15
415aAD $idev           s             10
415aAD $iform          s             10

415aAD $pcmd           s                   like($icmd)
415aAD $pwhse          s                   like($iwhse)
415aAD $pitem          s                   like($iitem)
415aAD $pdev           s                   like($idev)
415aAD $pform          s                   like($iform)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

415aAD $code           s              2    inz(' ')
415aAD $count          s              8b 0 inz(0)
415aAD append1         s              1
415aAD append5         s              5
     D client          s             10
     D clientLoc       s             10
500bAD curview         s              1  0 inz(1)
415aAD eorder1         s             20    inz(' ')
415aAD eorder2         s             20    inz(' ')
500cAD first           s               n
416aMD groupby         S            100a   inz(' ')
416aMD groupfields     S            100a   inz(' ')
415aAD iorder1         s             20    inz(' ')
415aAD iorder2         s             20    inz(' ')
     D lastrrn         s                   like(rrn1)
500bAD maxview         s              1  0 inz(2)
415aAD newordpos       s              3  0 inz(0)
610dAD noParmsPassed   s               n
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
415aAD scheadlen       s              3  0 inz(0)
415aAD scpad           s              3  0 inz(0)
415aAD sortorder1      s             10    inz(' ')
415aAD sortorder2      s             10    inz(' ')
415aAD sortorder3      s             10    inz(' ')
415aAD temp3           s              3
610fAD $msgf           s             10
610fAD $pmsg           s              4
610fAD $pprg           s             10
610fAD #msgid          s              7
610fAD*#msgdt          s            128
610fAD #msgtp          s              7
610fAD #pgmq           s             10
610fAD #msgk           s              4
610fAD dummy           s              1
610fAD msgk            s              4  0
610fAD sclear          s              1
610fAD wkWhse          s              3  0
610fAD wkDept          s              5
     D b               s             10  0
610hAD chk4err         s               n
610hAD zmsflag         s               n
610hAD zmflag          s               n

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
500cMD  h1item                 1     15
500cMD  h1whdp                16     20
500cMD  h1aisl                21     23
610aAD  h1stat                24     26
500cMD  h1dummy              100    100

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
     *  Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $icmd    - *DISPLAY
     *                 *PRINT
610eA*                 *SPECIAL - Choose special slot (i.e. RCV)
     *      $iwhse   - Warehouse
     *      $iitem   - Item
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
     C                   parm                    $iitem
     C                   parm                    $idev
     C                   parm                    $iform

      /free

610dA    noParmsPassed = *on;

         if %parms >= 1;
           $pcmd = $icmd;
         else;
           $pcmd = ' ';
         endif;

610dM    if %parms >= 2 and $iwhse > 0;
           $pwhse = $iwhse;
610dA      noParmsPassed = *off;
         else;
           $pwhse = 0;
         endif;

610dM    if %parms >= 3 and $iitem <> ' ';
           $pitem = $iitem;
610dA      noParmsPassed = *off;
         else;
           $pitem = ' ';
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

         // Get client id

         getclient(client: clientLoc);

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

         sqlstmt = 'select '
                 + 'slwhse, slwhdp, slaisl, slstat, '
                 + 'sum(slstk1+slrcv1-slalc1-slpck1-sltfr1), '
                 + 'sum(slstk2+slrcv2-slalc2-slpck2-sltfr2), '
                 + 'sum(slstk3+slrcv3-slalc3-slpck3-sltfr3) '
                 + 'FROM slot '
                 + 'WHERE '
                 + 'slitem='
                 + sq + %trim(w1item) + sq;

         append5 = ' and ';

         // Warehouse

         if w1whse > 0;
           sqlstmt = %trimr(sqlstmt)
                   + ' and slwhse=' + %trim(%editc(w1whse:'P'));
         endif;

         // Aisles

         if w1asl1<>' ' or w1asl2<>' ' or w1asl3<>' '
            or w1asl4<>' ' or w1asl5<>' ';
              sqlstmt = %trimr(sqlstmt) + ' and (';
              append5 = '';

              if w1asl1 <> ' ';
                evalr temp3 = %trim(w1asl1);
                sqlstmt = %trimr(sqlstmt) + append5 + ' '
                         + 'slaisl=' + sq + temp3 + sq;
                append5 = ' or ';
              endif;

              if w1asl2 <> ' ';
                evalr temp3 = %trim(w1asl2);
                sqlstmt = %trimr(sqlstmt) + append5 + ' '
                         + 'slaisl=' + sq + temp3 + sq;
                append5 = ' or ';
              endif;

              if w1asl3 <> ' ';
                evalr temp3 = %trim(w1asl3);
                sqlstmt = %trimr(sqlstmt) + append5 + ' '
                         + 'slaisl=' + sq + temp3 + sq;
                append5 = ' or ';
              endif;

              if w1asl4 <> ' ';
                evalr temp3 = %trim(w1asl4);
                sqlstmt = %trimr(sqlstmt) + append5 + ' '
                         + 'slaisl=' + sq + temp3 + sq;
                append5 = ' or ';
              endif;

              if w1asl5 <> ' ';
                evalr temp3 = %trim(w1asl5);
                sqlstmt = %trimr(sqlstmt) + append5 + ' '
                         + 'slaisl=' + sq + temp3 + sq;
                append5 = ' or ';
              endif;

              sqlstmt = %trimr(sqlstmt) + ')';
              append5 = ' and ';

            endif;

            sqlstmt = %trimr(sqlstmt) + append5 + ' '
                    + 'slstat<>' + sq + 'V' + sq;

            sqlstmt = %trimr(sqlstmt) + append5 + ' '
                    + 'slstat<>' + sq + 'Z' + sq;

         // Create "Order By" clauses.

         sqlstmt = %trimr(sqlstmt) + ' '
                 + 'group by slwhse, slwhdp, slaisl, slstat '
                 + 'order by slwhse, slwhdp, slaisl, slstat ';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlbldstmt2 - Build SQL statment 2
     *----------------------------------------------------------------

      /free
       begsr sqlbldstmt2;

         // Create "From" clause.

         sqlstmt = 'select '
                 + 'slwhse, slstat, '
                 + 'sum(slstk1+slrcv1-slalc1-slpck1-sltfr1), '
                 + 'sum(slstk2+slrcv2-slalc2-slpck2-sltfr2), '
                 + 'sum(slstk3+slrcv3-slalc3-slpck3-sltfr3) '
                 + 'FROM slot '
                 + 'WHERE '
                 + 'slitem=' + sq + %trim(w1item) + sq;

         append5 = ' and ';

         // Warehouse

         if w1whse > 0;
           sqlstmt = %trimr(sqlstmt)
                   + ' and slwhse=' + %trim(%editc(w1whse:'P'));
         endif;

         // Aisles

         if w1asl1<>' ' or w1asl2<>' ' or w1asl3<>' '
            or w1asl4<>' ' or w1asl5<>' ';
              sqlstmt = %trimr(sqlstmt) + ' and (';
              append5 = '';

              if w1asl1 <> ' ';
                evalr temp3 = %trim(w1asl1);
                sqlstmt = %trimr(sqlstmt) + append5 + ' '
                         + 'slaisl<>' + sq + temp3 + sq;
                append5 = ' and ';
              endif;

              if w1asl2 <> ' ';
                evalr temp3 = %trim(w1asl2);
                sqlstmt = %trimr(sqlstmt) + append5 + ' '
                         + 'slaisl<>' + sq + temp3 + sq;
                append5 = ' and ';
              endif;

              if w1asl3 <> ' ';
                evalr temp3 = %trim(w1asl3);
                sqlstmt = %trimr(sqlstmt) + append5 + ' '
                         + 'slaisl<>' + sq + temp3 + sq;
                append5 = ' and ';
              endif;

              if w1asl4 <> ' ';
                evalr temp3 = %trim(w1asl4);
                sqlstmt = %trimr(sqlstmt) + append5 + ' '
                         + 'slaisl<>' + sq + temp3 + sq;
                append5 = ' and ';
              endif;

              if w1asl5 <> ' ';
                evalr temp3 = %trim(w1asl5);
                sqlstmt = %trimr(sqlstmt) + append5 + ' '
                         + 'slaisl<>' + sq + temp3 + sq;
                append5 = ' and ';
              endif;

              sqlstmt = %trimr(sqlstmt) + ')';
              append5 = ' and ';

            endif;

            sqlstmt = %trimr(sqlstmt) + append5 + ' '
                    + 'slstat<>' + sq + 'V' + sq;

            sqlstmt = %trimr(sqlstmt) + append5 + ' '
                    + 'slstat<>' + sq + 'Z' + sq;

         // Create "Order By" clauses.

         sqlstmt = %trimr(sqlstmt) + ' '
                 + 'group by slwhse, slstat '
                 + 'order by slwhse, slstat ';

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
     *  sflBldDisp2  Build and display subfile
     *----------------------------------------------------------------

      /free
       begsr sflBldDisp2;

         exsr sqlclean;
         exsr sqlbldstmt2;
         exsr sqlprep;
         exsr sflbld2;

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

           exec sql FETCH NEXT FROM mycsr
                    INTO :slwhse, :slwhdp, :slaisl, :slstat,
                         :w1qty1, :w1qty2, :w1qty3;

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
             if w1asl1<>' ' or w1asl2<>' ' or w1asl3<>' '
               or w1asl4<>' ' or w1asl5<>' ';
                 exsr sflBldDisp2;
             endif;
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
     *  sflbld2 - Build the subfile
     *----------------------------------------------------------------

      /free
       begsr sflbld2;

         // Process the records in the SQL cursor until the return not = 0

         for j = 1 to subfilePage;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr
                    INTO :slwhse, :slstat,
                         :w1qty1, :w1qty2, :w1qty3;

           If sqlstt = sqlSuccess;
             exsr sflFill2;
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

         // Store hidden fields that aren't displayed on screen.

         h1item = slitem;
         h1whdp = slwhdp;
         h1aisl = slaisl;
610aA    h1stat = slstat;

         w1val1 = slaisl;
         w1val2 = slstat;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill2  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill2;

         // Store hidden fields that aren't displayed on screen.

         h1item = slitem;
         h1whdp = ' ';
         h1aisl = ' ';
610aA    h1stat = slstat;

         w1val1 = 'OTH';
         w1val2 = slstat;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sfloption1 - Get entered option
     *----------------------------------------------------------------

      /free
       begsr sfloption1;

         recpos = csrrrn;

610gD    //if rrn1 = 0;
610gA    if recpos = 0;
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

         scrname = 'SL440.01';
         //w1sort = 'A';
         //w1oby = '2';
         exsr inzcriteria1;

         exsr setcriteria1;

610iA    scopt1 = ' ';
610iD    scopt2 = ' ';

610dA    // If no parms are passed in, display F9 window.
610dA
610dA    if noParmsPassed;
610dA      exsr getcriteria1;
610dA      if cfkey <> Enter;
610dA        leavesr;
610dA      endif;
610dA    endif;

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

600aA      recpos = csrrrn;

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;

               select;

                  when optiontaken = 'Change';
610bA               //lt312('*CHANGE': h1Whse: h1lcns);
610iA               //exsr sflBldDisp;

                  when optiontaken = 'View';
610aA               //la830('*VIEW': h1whse: h1lcns);

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
               //if curview <= 1;
               //  curview = maxview;
               //else;
               //  curview = curview - 1;
               //endif;
               cfkey = Enter;

             // F11 = Next view

             When cfkey = F11;
               //if curview >= maxview;
               //  curview = 1;
               //else;
               //  curview = curview + 1;
               //endif;
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

         if $pwhse = 0;
           w1whse = 0;
         else;
           w1whse = $pwhse;
         endif;

         if $pitem = ' ';
           w1item = ' ';
         else;
           w1item = $pitem;
         endif;

         w1asl1 = ' ';
         w1asl2 = ' ';
         w1asl3 = ' ';
         w1asl4 = ' ';
         w1asl5 = ' ';

         if client = eastland;
           w1asl1 = 'CF';
           w1asl2 = 'CB';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr setcriteria1;

         // Set sort order

         //if w1sort <> 'A' and w1sort <> 'D';
         //  w1sort = 'A';
         //endif;

         //if w1oby <> '1' and w1oby <> '2';
         //  w1oby = '2';
         //endif;

         //select;

         //  when w1sort = 'D';
         //    sortorder1 = 'DESCEND';

         //  other;
         //    sortorder1 = 'ASCEND';

         //endsl;

         // Create screen heading.

         schead = ' ';
         append1 = ' ';

         //if w1sort = 'D';
         //  schead = %trimr(schead) + append1
         //         + 'Descend';
         //  append1 = ',';
         //else;
         //  schead = %trimr(schead) + append1
         //         + 'Ascend';
         //  append1 = ',';
         //endif;

         //if w1oby = '2';
         //  schead = %trimr(schead) + append1
         //         + 'By FIFO';
         //  append1 = ',';
         //else;
         //  schead = %trimr(schead) + append1
         //         + 'By Lcns';
         //  append1 = ',';
         //endif;

         schead = %trimr(schead) + append1
                + 'Item=' + %trim(w1item);
         append1 = ',';

         exsr centerschead;

         wocol1 = 'Aisle';
         wocol2 = 'Status';

       endsr;
      /end-free

610fA*---------------------------------------------------------------
610fA*  SUBROUTINE ZMxxxx  Control message display subfile
610fA*---------------------------------------------------------------
610fa
610fA*---------------------------------------------------------------
610fA*    ZMCMSG  Clear message record subfile
610fA*---------------------------------------------------------------
610fA
610fA /free
610fA  begsr zmcmsg;

         *in97 = *off;
         write  msgctl;
         msgk = *zeros;
         write  msgclr;
         #msgid = '*CLEAR ';
         #msgtp = '*NULL  ';
         exsr  zmpmsg;

       endsr;
      /end-free

610fA*---------------------------------------------------------------
610fA*    ZMDMSG  Display message record subfile
610fA*---------------------------------------------------------------
610fA
610fA /free
610fA  begsr zmdmsg;

         *in97 = *on;
         if  msgk > 0;
           write  msgctl;
           msgk = *zeros;
         endif;

       endsr;
      /end-free

610fA*---------------------------------------------------------------
610fA*    ZMIMSG  Initialization necessary for message subfile
610fA*---------------------------------------------------------------
610fA
610fA /free
610fA  begsr zmimsg;

         #pgmq = #prog;
         exsr  zmcmsg;

       endsr;
      /end-free

610fA*---------------------------------------------------------------
610fA*    ZMPMSG  Add message record to subfile
610fA*---------------------------------------------------------------
610fA
610fA /free
610fA  begsr zmpmsg;

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

610fA*---------------------------------------------------------------
610fA*    ZMQMSG  Add message record to subfile from program queue
610fA*---------------------------------------------------------------
610fA
610fA /free
610fA  begsr zmqmsg;

         msgk = msgk + 1;
         write  msgrec;

       endsr;
      /end-free

610fA*---------------------------------------------------------------
610fA*    ZSCLR   Clear screen
610fA*---------------------------------------------------------------
610fA
610fA /free
       begsr zsclr;

         write  clrscr;
         sclear = *on;

       endsr;
      /end-free

610fA*---------------------------------------------------------------
610fA*    ZMSMSG  Send program message to a different program msgq
610fA*---------------------------------------------------------------
610fA
610fA /free
610fA  begsr zmsmsg;

         if $msgf = *blanks;
           $msgf = #msgf;
         endif;

         putmsg($msgf: #msgid: #msgtp: #msgdt: #pgmq: #msgk);
         #msgdt = *blanks;
         $msgf = *blanks;

       endsr;
      /end-free

610fA*----------------------------------------------------------------
610fA*    ZMnnnn  Build and send message nnnn to this program
610fA*----------------------------------------------------------------

610fA*----------------------------------------------------------------
610fA*      0105
610fA*----------------------------------------------------------------
610fA
610fA /free
610fA  begsr zm0105;

         #msgid = 'PIR0105';
         #msgtp = '*DIAG  ';
         #msgdt = errmsg;
         exsr zmpmsg;

       endsr;
      /end-free
