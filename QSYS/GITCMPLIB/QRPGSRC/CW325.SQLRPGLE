      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
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
     *  CW325     View Catch Weight Log - all for C sequence
     *  27 February 2014
     *  Lynn McMahon
     *
     *  Revisions
     *
650 A*    02/25/14  LMC  6.50
     *      - Created. Copied from LT320
     *
700a *    02/12/16  GJA  7.00a  (with LMC of course)
     *      - Fix:when the item is a type "S" it was looking for catch
     *        weight for the base item
     *
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     FCW325FM   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     infds(info)
     Fpiruser1  if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.cvtqty
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.clcdur2
      /copy qcopysrc,p.driitem
     *----------------------------------------------------------------
     * Client ID
     *----------------------------------------------------------------
      /COPY QCOPYSRC,ID#CITYLIN
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
     D savever#        s                   like($itver#)

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

     D cwlog         e ds

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

     D sqlfile         c                   'CWLOG'
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
     D $ilbl#          s              7  0
     D $iord           s              7  0
     D $iseq           s              5  0
     D $icseq          s              3  0
     D $iitem          s             15
     D $iemp#          s              5  0
     D W1whse          s              3  0
     D W1item          s             15

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $plbl#          s                   like($ilbl#)
     D $pord           s                   like($iord)
     D $pseq           s                   like($iseq)
     D $pcseq          s                   like($icseq)
     D $pitem          s                   like($iitem)
     D*$pdisp          s                   like($idisp)
     D*$plcns          s                   like($ilcns)
     D $pemp#          s                   like($iemp#)
     D*$pdev           s                   like($idev)
     D*$pform          s                   like($iform)
     D*$ptrn#          s                   like($itrn#)

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D driItemCalled   s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $code           s              2    inz(' ')
     D $count          s              8b 0 inz(0)
     D append1         s              1
     D append5         s              5
     d client          s             10    inz
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
     D maxview         s              1  0 inz(1)
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
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')
     D sortorder2      s             10    inz(' ')
     D sortorder3      s             10    inz(' ')
     D w1aqty10        s             10    inz(' ')
     D w1rqty10        s             10    inz(' ')
     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D Fromdatestamp   s               z
     D todatestamp     s               z

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     D w1tdatwork      s              8  0
     D w1fdatwork      s              8  0

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1lcns                 1     15
     D  h1olcns               16     30
     D  h1item                31     45
     D  h1cseq                46     48s 0
     D  h1disp                51     62
     D  h1lbl#                63     69S 0
     D  h1trn#                70     76S 0
     D  h1whse                77     79S 0
     D  h1adduc               80    105
     D  h1dummy              110    110

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
     *      $plbl#   - Label
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
     C                   parm                    $ilbl#
     C                   parm                    $iord
     C                   parm                    $iseq
     C                   parm                    $iitem
     C                   parm                    $icseq

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

         if %parms >= 3 and $ilbl# > 0;
           $plbl# = $ilbl#;
           noParmsPassed = *off;
         else;
           $plbl# = 0;
         endif;

         if %parms >= 4 and $iord > 0;
           $pord = $iord;
           noParmsPassed = *off;
         else;
           $pord = 0;
         endif;

         if %parms >= 5 and $iseq > 0;
           $pseq = $iseq;
           noParmsPassed = *off;
         else;
           $pseq = 0;
         endif;

         if %parms >= 6 and $iitem <> ' ';
           $pitem = $iitem;
           noParmsPassed = *off;
         else;
           $pitem = ' ';
         endif;

         if %parms >= 7 and $icseq > 0;
           $pcseq = $icseq;
           noParmsPassed = *off;
         else;
           $pcseq = 0;
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

         if $pcmd = '*PRINT';
           exsr printit;
         else;
           exsr screen1;
         endif;

         *inlr = *on;

         if driItemCalled;
           driItem('%CLOSE': $pprogram: $drireturn: $drimessage:
                    $dridata: $dridata2);
         endif;

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
                    + 'cwwhse=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';
         endif;

         // item

         if w1item <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'cwitem='
700aM               + sq + %trim(w1item) + sq;
700aD    //         + sq + %trim($ititem) + sq;
           append5 = ' and ';
         endif;

         // label

         if w1lbl#  > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'cwsellbl#='
                    + %trim(%editc(w1lbl#:'P'));
           append5 = ' and ';
         endif;

         // ord #

         if $pord > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'cwselord=' + %trim(%editc($pord:'P'));
           append5 = ' and ';
         endif;

         // seq#

         if $pseq > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'cwselseq=' + %trim(%editc($pseq:'P'));
           append5 = ' and ';
         endif;

         if $pcseq > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'cwselcseq=' + %trim(%editc($pcseq:'P'));
           append5 = ' and ';
         endif;


         // Create "Order By" clauses.

               sqlorder = 'ORDER BY CWSELCSEQ,CWADDUC';

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

           exec sql FETCH NEXT FROM mycsr INTO :cwlog;

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
         *in90 = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill1  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill1;

         // Store hiddent fields that aren't displayed on screen.

         // deleted log records will display in red
         if cwstat = 'O';
           *in50 = '1';
         else;
           *in50 = '0';
         endif;

         h1item = cwitem;
         h1lbl# = cwsellbl#;
         h1whse = cwwhse;
         h1cseq = cwselcseq;
         h1adduc = %char(cwadduc);
         w1wgtlbs = cwwgtlbs;
         select;
           when cwentflg = 1;
             w1entry = 'Scanned';
           when cwentflg = 2;
             w1entry = 'Voiced';
           when cwentflg = 3;
             w1entry = 'Manual';
           other;
         endsl;


         chain (cwaddemp) piruser1;
         if %found;
           w1emp#nam = %trim(%editc(cwaddemp:'4')) +
                       ' ' + %trim(uslnam) +
                       ', ' + %trim(usfnam);
         else;
           w1emp#nam = %trim(%editc(cwaddemp:'4'));
         endif;

         w1added = %char(cwaddts);

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

             when %trim(option) = 'VL';
               optiontaken = 'ViewLabel';
               recpos = rrn1;

             when %trim(option) = 'VT';
               optiontaken = 'ViewTran';
               recpos = rrn1;

             when %trim(option) = 'V1';
               optiontaken = 'V1';
               recpos = rrn1;

           endsl;

           option = ' ';
           select;
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

         scrname = 'CW325.01';
         exsr inzcriteria1;
         exsr zzgettime;
         exsr zzgetslotitem;

         exsr setcriteria1;

         scopt1 = ' ';

         scopt2 = ' ';

         // If no parms are passed in, display F9 window.

         if noParmsPassed;
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
             other;
               exfmt sf1ctl;
           endsl;

           recpos = csrrrn;

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;

               select;

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
         w1lbl# = 0;
         w1item = '*ALL';

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

         if $plbl# = 0;
           w1lbl# = 0;
         else;
           w1lbl# = $plbl#;
         endif;


         if $pitem = ' ';
           w1item = '*ALL';
         else;
           w1item = $pitem;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr setcriteria1;

         // Set sort order

         // Create screen heading.

         schead = ' ';
         append1 = ' ';

         if w1lbl# <> 0;
           schead = %trimr(schead) + append1
                  + 'Label=' + %trim(%editc(w1lbl#:'P'));
           append1 = ',';
         endif;

         if $pord  > 0;
           schead = %trimr(schead) + append1
                  + 'Order=' + %trim(%editc($pord:'P'));
           append1 = ',';
         endif;

         if $pseq  > 0;
           schead = %trimr(schead) + append1
                  + 'Seq#=' + %trim(%editc($pseq:'P'));
           append1 = ',';
         endif;

         if $pcseq  > 0;
           schead = %trimr(schead) + append1
                  + 'CSeq#=' + %trim(%editc($pcseq:'P'));
           append1 = ',';
         endif;

         if w1item <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Slot Item=' + w1item;
           append1 = ',';
         endif;


         if append1 = ' ';
           schead = %trimr(schead) + ',Everything';
         endif;

         exsr centerschead;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZGETTIME Get Timestamp information.
     *
     *----------------------------------------------------------------
      /free
       begsr zzgettime;
         getmicrotime(currstampuc:currstampsys);
         w1tdatwork = %dec(%date(currstampsys));
         // Convert to date for display

         // Sub 3 from today's date to get from date.

         $cdcmd = '*SUB    ';
         $cddays = 2;
         clcdur2($cdcmd: w1tdatwork: $cdtimein: $cdyears:
                 $cdmonths: $cddays: $cdhours: $cdminutes:
                 $cdseconds: $cddateout: $cdtimeout);
         w1fdatwork = $cddateout;
         if client = cityln;
           w1fdatwork = 0;
         endif;
         // Convert to date for display

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZGETSLOTITEM - Get slot item.
     *
     *----------------------------------------------------------------
      /free
       begsr zzgetslotitem;

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


       endsr;
      /end-free
