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
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RH380     View Selector Info
     *  03 June 2010
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    06/03/10  DAS  5.30
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     FRH380fm   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl2:rrn1)
     F                                     infds(info)
     F                                     sfile(msgrec:msgk)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtbarse
      /copy qcopysrc,p.getsel
      /copy qcopysrc,p.putmsg
610fA /copy qcopysrc,p.getuser

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

     D label         e ds
     D piritem       e ds
     D ordh          e ds

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

     D $icmd           s              8

     D $pcmd           s                   like($icmd)

     *----------------------------------------------------------------
     *  Parameter fields for CvtBarSel
     *----------------------------------------------------------------

     D  cWhse          s              3
     D  cBarCode       s             15
     D  cLbl#          s              7  0
     D  cRtId          s              5
     D  cUnq#          s              5  0
     D  cReturn        s              8
     D  cErrMsg        s             60

     *----------------------------------------------------------------
     *  Parameter fields for GetSel
     *----------------------------------------------------------------

     D  sLbl#          s              7  0
     D  sSelEmp#       s              5  0
     D  sSelName       s             40
     D  sSelQty        s              5  0
     D  sSelVoice      s              1
     D  sRun1Emp#      s              5  0
     D  sRun1Name      s             40
     D  sRun1Qty       s              5  0
     D  sRun2Emp#      s              5  0
     D  sRun2Name      s             40
     D  sRun2Qty       s              5  0
     D  sReturn        s             10

     *----------------------------------------------------------------
     *  Parameter fields for GetUser
     *----------------------------------------------------------------

     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $code           s              2    inz(' ')
     D $count          s              8b 0 inz(0)
     D append1         s              1
     D append5         s              5
     D cqerm           s             60
     D cqrtn           s              8
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
     D recCount        s             10i 0
     D recpos          s                   like(rrn1)
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')
     D sortorder2      s             10    inz(' ')
     D sortorder3      s             10    inz(' ')
     D $msgf           s             10
     D $pmsg           s              4
     D $pprg           s             10
     D #msgid          s              7
     D*#msgdt          s            128
     D #msgtp          s              7
     D #pgmq           s             10
     D #msgk           s              4
     D dummy           s              1
     D msgk            s              4  0
     D sclear          s              1
     D wkWhse          s              3  0
     D wkDept          s              5
     D b               s             10  0
     D chk4err         s               n
     D zmsflag         s               n
     D zmflag          s               n

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1lbl#                 1      7  0
     D  h1dummy              100    100

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $icmd    - *DISPLAY
     *                 *PRINT
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

      /free

         noParmsPassed = *on;

         if %parms >= 1;
           $pcmd = $icmd;
         else;
           $pcmd = ' ';
         endif;

      /end-free

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

610hA    // Get default values for the user.

         getUser(#user: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

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
           //when $pcmd = '*SPECIAL';
           //  exsr sc2;
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

         sqlstmt = 'select lblbl#, lbitem, lbucod, lbqalc, lbqpck, itdesc '
                 + 'from label '
                 + 'left outer join piritem '
                 +   'on itwhse=lbwhse and ititem=lbitem ';

         // Add "where" statements

         sqlwhere = ' ';
         append5  = 'where';

           // Warehouse

           if wswhse > 0;
             sqlstmt = %trimr(sqlstmt) + ' ' + append5 + ' '
                     + 'lbwhse=' + %trim(%editc(wswhse:'P'));
             append5 = 'and';
           endif;

           // Customer order number

           if wscord > 0;
             sqlstmt = %trimr(sqlstmt) + ' ' + append5 + ' '
                     + 'lbord=' + %trim(%editc(ohord:'P'));
               append5 = 'and';
           endif;

           // Label #

           if wslbl# > ' ';
             sqlstmt = %trimr(sqlstmt) + ' ' + append5 + ' '
                     + 'lblbl#=' + %trim(%editc(h1lbl#:'P'));
             append5 = 'and';
           endif;

           // Tran #

           if wstrn# > 0;
             sqlstmt = %trimr(sqlstmt) + ' ' + append5 + ' '
                     + 'lbtrn#=' + %trim(%editc(wstrn#:'P'));
             append5 = 'and';
           endif;

           // Route Id

           if wsrtid <> ' ';
             sqlstmt = %trimr(sqlstmt) + ' ' + append5 + ' '
                     + 'lbrte=' + sq + %trim(wsrtid) + sq;
             append5 = 'and';
           endif;

           // Item

           if wsitem <> ' ';
             if %scan('%':wsitem) > 0;
               opcode = 'LIKE';
             else;
               opcode = '=';
             endif;
             sqlstmt = %trimr(sqlstmt) + ' ' + append5 + ' '
                     + 'lbitem' + ' ' + %trim(opcode) + ' '
                     + sq + %trim(wsitem) + sq;
             append5 = 'and';
           endif;

         // Create "Order By" clauses.

         if wsoby = '1';
           sqlstmt = %trimr(sqlstmt) + ' '
                   + 'order by lblbl#';
         else;
           sqlstmt = %trimr(sqlstmt) + ' '
                   + 'order by lbwhse,lbitem,lblbl#';
         endif;

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
                    INTO :lblbl#, :lbitem, :lbucod,
                         :lbqalc, :lbqpck, :itdesc;

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

         // Store hidden fields that aren't displayed on screen.

         //h1lcns = lalcns;

         // Format item number string

         w1Item = %trim(lbitem) + ' - ' + %trim(itdesc);

         // Get selector info

         getSel(lblbl#:
                sSelEmp#: sSelName: sSelQty: sSelVoice:
                sRun1Emp#: sRun1Name: sRun1Qty:
                sRun2Emp#: sRun2Name: sRun2Qty:
                sReturn);

         w1semp = sSelEmp#;
         w1sqty = %trim(%editc(sSelQty:'P'));
         if sSelVoice = 'Y';
           evalr w1sqty = %trim(w1sqty) + 'v';
         else;
           evalr w1sqty = %trim(w1sqty) + ' ';
         endif;

         w1rqty = sRun1Qty + sRun2Qty;

         w1xqty = lbqalc - sSelQty - sRun1Qty - sRun2Qty;
         if w1xqty < 0;
           w1xqty = 0;
         endif;

         w2item = w1item;

         w2r1emp = sRun1Emp#;
         w2r1qty = sRun1Qty;

         w2r2emp = sRun2Emp#;
         w2r2qty = sRun2Qty;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sfloption1 - Get entered option
     *----------------------------------------------------------------

      /free
       begsr sfloption1;

         recpos = csrrrn;

         //if rrn1 = 0;
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

         scrname = 'RH380.01';
         // w1sort = 'A';
         wsoby = '1';
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

                  when optiontaken = 'Change';

                  when optiontaken = 'View';

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
     *  sc2 - Process screen 2
     *----------------------------------------------------------------

      /free
       begsr sc2;

         // Initialize screen fields

         exsr sc2Init;

         // Process subfile until user wants to leave

         dou (cfkey = F3);

           // Set ON alarm indicator if error occured

           if error = *on;
             *in98 = *on;
           endIf;

           // Overlay screen with error messages

           exsr zmdmsg;

           exfmt screen2;

           *in98 = *off;
           *in22 = *off;
           *in23 = *off;
           *in24 = *off;
           exsr zmcmsg;

           Select;

             // Enter

             When cfkey = Enter;
               exsr sc2vfy;
               if error;
                 iter;
               endif;

               //$pwhse = w2whse;
               //$pwhdp = w2whdp;
               //$pdisp = w2type + '%';
               noParmsPassed = *off;
               exsr screen1;
               leave;

             // F5 = Refresh

             when cfkey = F5;
               exsr sc2init;
               cfkey = Enter;

             // F12 = Cancel

             when cfkey = F12;
               leave;

           EndSl;

         EndDo;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sc2init - Initialize screen2 fields.
     *----------------------------------------------------------------

      /free
       begsr sc2init;

         error = *off;
         exsr zmimsg;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sc2vfy  - Verify screen2 fields.
     *----------------------------------------------------------------

      /free

       begsr sc2vfy;

         error = *off;
         msgk = *zero;

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
     *  chkcriteria1 - Check select and sort criteria
     *----------------------------------------------------------------

      /free
       begsr chkcriteria1;

         error = *off;

        // Must enter something

        If wscord = 0
          and wslbl# = ' '
          and wstrn# = 0
          and wsrtid = ' ';
            error = *on;
            errmsg = 'Must enter at least one: Ord#, Lbl#, Trn# or Rtid';
            exsr zm0105;
            leavesr;
          endif;

        // There can only be one BFC order# for customer order#

        If wscord > 0;

          exec sql select count(*) into :recCount
                   from ordh
                   where ohcord = :wscord;

          If sqlstt <> sqlSuccess
            or recCount = 0;
            error = *on;
            errmsg = 'Error getting order header record';
            exsr zm0105;
            leavesr;
          endif;

          If recCount > 1;
            error = *on;
            errmsg = 'Order number sent more than once to Dakota';
            exsr zm0105;
            leavesr;
          endif;

          exec sql select ohord into :ohord
                   from ordh
                   where ohcord = :wscord;

          If sqlstt <> sqlSuccess;
            error = *on;
            errmsg = 'Error getting order header record';
            exsr zm0105;
            leavesr;
          endif;

        endif;

        // Verify label# exists

        If wslbl# <> ' ';
        endif;

        // Verify tranl# is for selection.

        If wstrn# > 0;
        endif;

        // Verify Route Id exists

        If wsrtid <> ' ';
        endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getcriteria1 - Prompt user for select and sort criteria
     *----------------------------------------------------------------

      /free
       begsr getcriteria1;

         dow forever = forever;

           // Display window.

           exfmt window1;

           if cfkey = F3 or cfkey = F12;
             leavesr;
           endif;

           // Check criteria

           exsr chkcriteria1;
           if error;
             iter;
           endif;

           // Set selection criteria.

           exsr setcriteria1;

           leave;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  inzcriteria1 - Initialize criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr inzcriteria1;

         wswhse = 0;
         wscord = 0;
         wslbl# = ' ';
         wstrn# = 0;
         wsrtid = ' ';
         wsitem = ' ';

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

         if wsoby <> '1' and wsoby <> '2';
           wsoby = '1';
         endif;

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
         //        + 'Descend';
         //  append1 = ',';
         //else;
         //  schead = %trimr(schead) + append1
         //         + 'Ascend';
         //  append1 = ',';
         //endif;

         if wsoby = '2';
           schead = %trimr(schead) + append1
                  + 'By Item';
           append1 = ',';
         else;
           schead = %trimr(schead) + append1
                  + 'By Label#';
           append1 = ',';
         endif;

         if wscord > 0;
           schead = %trimr(schead) + append1
                  + 'Ord#=' + %trim(%editc(wscord:'P'));
           append1 = ',';
         endif;

         if wslbl# > ' ';
           if wswhse > 0;
             cWhse = %char(wswhse);
           else;
             cWhse = %char(e$whse);
           endif;
           cBarCode = wslbl#;
           CvtBarSel(cWhse: cBarCode: cLbl#: cRtId:
                     cUnq#: cReturn: cErrMsg);
           h1Lbl# = cLbl#;
           schead = %trimr(schead) + append1
                  + 'Lbl#=' + %trim(%editc(h1Lbl#:'P'));
           append1 = ',';
         endif;

         if wstrn# > 0;
           schead = %trimr(schead) + append1
                  + 'Trn#=' + %trim(%editc(wstrn#:'P'));
           append1 = ',';
         endif;

         if wsrtid <> ' ';
           schead = %trimr(schead) + append1
                  + 'RteId=' + %trim(wsrtid);
           append1 = ',';
         endif;

         if wsitem <> ' ';
           schead = %trimr(schead) + append1
                  + 'Item=' + %trim(wsitem);
           append1 = ',';
         endif;

         if append1 = ' ';
           schead = %trimr(schead) + ',Everything';
         endif;

         exsr centerschead;

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

       //----------------------------------------------------------------
     *      0105
     *----------------------------------------------------------------

      /free
       begsr zm0105;

         #msgid = 'PIR0105';
         #msgtp = '*DIAG  ';
         #msgdt = errmsg;
         exsr zmpmsg;

       endsr;
      /end-free
