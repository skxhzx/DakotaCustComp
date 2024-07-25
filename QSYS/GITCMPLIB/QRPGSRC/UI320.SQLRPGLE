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
     *  UI320     View UCIINFO file
     *  18 February 2014
     *  Lynn McMahon
     *
     *  Revisions
     *
650 A*    02/18/14  LMC  6.50
     *      - Created.- copied from LT320
     *
650aA*    03/12/14  LMC  6.50a
     *      - Enh - GS199 label data.
     *      - Fix - When bad scanned data is loaded to file, this
     *        program can't convert the date correctly. Send program
     *        name to cvtdte, so putmsg error does not occur.
650bA*    05/13/14  LMC  6.50b
     *      - Enh - Pass Vendor# to CVTBAR.
650cA*    07/25/14  LMC  6.50c
     *      - Enh - Display CW entries being stored in UCIINFO -
     *        Non UCI receiving.
650dA*    01/16/15  LMC  6.50d
     *      - Enh - Added Item description to display
     *        Renamed display file to UI32002.
     *        Added print function.
650eA*    01/30/15  LMC  6.50e
     *      - Enh - Changed the heading to allow for the
     *        License, PO and Item selection to fit
700aA*    02/17/16  LMC  7.00a
     *      - Added Total Count to total line on report.
700bA*    03/14/16  LMC  7.00b
     *      - Fix - Since we allow multiple licinfo records, if we
     *        have different lots or dates in UCI receiving. We need
     *        to condition the sql select on LNSEQ = 1 only.
700cA*    03/22/16  LMC  7.00c
     *      - Enh: Adding logic for Metric.
710aA*    09/25/17  LMC  7.10a
     *      - Enh: If the weight that was extracted from a GS1 barcode
     *        is zeroed out by the user in cw122, then we should show
     *        the zeroed weight, not the weight that was in the GS1
     *        barcode.
720aA*    05/15/18  LMC  7.20a
     *      - Enh: If the weight is zero and the uiucilcns is a P:lcns
     *        then exclude these records. the P:lcns records are being
     *        used to store pti codes, and some records are being
     *        captured like this is the barcode has a GTIN & lot.
730aA*    11/15/19  LMC  7.30a
     *      - Enh: If uci is no longer in the warehouse will display
     *        the weight field in blue.
730bA*    12/19/19  LMC  7.30b
     *      - Enh: Added logic to handle displaying the production
     *        import data. The original code only showed received
     *        weights which was based on finding the license in
     *        the licinfo file.
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter County Bakers
     *
ICBaA*    03/09/17  LMC  ICBa
     *      - Revised program to get Lot from Licinfo.
     *        changed printer file to display lot in place of UCI
     *        scanned field.
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

650cDF*ui320fm   cf   e             workstn
650dDF*ui32001   cf   e             workstn
730aDF*ui32002   cf   e             workstn
730aMFui32003   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl2:rrn1)
     F                                     sfile(sfl3:rrn1)
     F                                     infds(info)
     Fpiruser1  if   e           k disk
730bAFlicinfo2  if   e           k disk
650dAFui320pr   O    E             printer usropn
650dAF                                     oflind(*IN90)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.cvtqty
      /copy qcopysrc,p.lp130
      /copy qcopysrc,p.lb830
      /copy qcopysrc,p.pt830
      /copy qcopysrc,p.ll830
      /copy qcopysrc,p.lt325
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.clcdur2
      /copy qcopysrc,p.driitem
700cA /copy qcopysrc,p.getimuom
     *----------------------------------------------------------------
     * Client ID
     *----------------------------------------------------------------
      /COPY QCOPYSRC,ID#CITYLIN
ICBaA /COPY QCOPYSRC,ID#ICB
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE

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

650cA*----------------------------------------------------------------
650cA*  File field data structure.
650cA*----------------------------------------------------------------

650cAD fetchds         ds
650cAD   #fwhse                            like(uiwhse)
650cAD   #fitem                            like(uiitem)
650cAD   #fuci                             like(uiuci)
650cAD   #fucilcns                         like(uiucilcns)
650cAD   #flcns                            like(uilcns)
650cAD   #fseq                             like(uiseq)
650cAD   #fserial                          like(uiserial)
650cAD   #fwgtlbs                          like(uiwgtlbs)
650cAD   #fwgtkgs                          like(uiwgtkgs)
650cAD   #fcrtby                           like(uicrtby)
650cAD   #flnlcns                          like(lnlcns)
650cAD   #fpo                              like(lnpo)
ICBaAD   #flnlot                           like(lnlot)
730aAD   #fseltrn#                         like(uiseltrn#)
730aAD   #frtntrn#                         like(UIRTNTRN#)
730bAD fetchds2        ds
730bAD   #f2whse                           like(uiwhse)
730bAD   #f2item                           like(uiitem)
730bAD   #f2uci                            like(uiuci)
730bAD   #f2ucilcns                        like(uiucilcns)
730bAD   #f2lcns                           like(uilcns)
730bAD   #f2seq                            like(uiseq)
730bAD   #f2serial                         like(uiserial)
730bAD   #f2wgtlbs                         like(uiwgtlbs)
730bAD   #f2wgtkgs                         like(uiwgtkgs)
730bAD   #f2crtby                          like(uicrtby)
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

     D uciinfo       e ds
650cAD licinfo       e ds

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

     D sqlfile         c                   'UCIINFO'
650cAD sqlfile1        c                   'LICINFO  '
650cDD*sqlfields       c                   '*'
650cMD sqlfields       c                   'uiwhse,uiitem,uiuci,+
650cAD                                      uiucilcns,uilcns,+
650cAD                                      uiseq,uiserial,uiwgtlbs,+
650cAD                                      uiwgtkgs,uicrtby,lnlcns,lnpo,+
730aDD*                                     lnlot'
730aAD                                      lnlot,uiseltrn#,uirtntrn#'
730bAD sqlfields2      c                   'uiwhse,uiitem,uiuci,+
730bAD                                      uiucilcns,uilcns,+
730bAD                                      uiseq,uiserial,uiwgtlbs,+
730bAD                                      uiwgtkgs,uicrtby'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $icmd           s              8
     D $iwhse          s              3  0
     D $iwhdp          s              5
     D $idisp          s             12
     D $iitem          s             15
     D $ilcns          s             15
     D $iemp#          s              5  0
     D $idev           s             10
     D $iform          s             10
     D $itrn#          s              7  0
650cAD $ipo            s              9

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $pwhdp          s                   like($iwhdp)
     D $pdisp          s                   like($idisp)
     D $pitem          s                   like($iitem)
     D $plcns          s                   like($ilcns)
     D $pemp#          s                   like($iemp#)
     D $pdev           s                   like($idev)
     D $pform          s                   like($iform)
     D $ptrn#          s                   like($itrn#)
650cAD $ppo            s                   like($ipo)

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
700cAD IMkilolbs       s              1
700cAD IMUom           s              3
     D lastrrn         s                   like(rrn1)
730bAD licinfofound    s               n
     D maxview         s              1  0 inz(3)
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
650dAD scdesclen       s              3  0 inz(0)
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')
     D sortorder2      s             10    inz(' ')
     D sortorder3      s             10    inz(' ')
650dAD printflag       s               n
     D w1aqty10        s             10    inz(' ')
     D w1rqty10        s             10    inz(' ')
730aAD wgtgone         s              1    inz(' ')
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
     D  h1whdp                46     50
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
     C                   parm                    $iitem
     C                   parm                    $ilcns
     C                   parm                    $itrn#
650cAC                   parm                    $ipo

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

         if %parms >= 3 and $iitem <> ' ';
           $pitem = $iitem;
           noParmsPassed = *off;
         else;
           $pitem = ' ';
         endif;

         if %parms >= 4 and $ilcns <> ' ';
           $plcns = $ilcns;
           noParmsPassed = *off;
         else;
           $plcns = ' ';
         endif;

         if %parms >= 5;
           $ptrn# = $itrn#;
         else;
           $ptrn# = 0;
         endif;

650cA    if %parms >= 6;
650cA      $ppo   = $ipo;
650cA    else;
650cA      $ppo   = ' ';
650cA    endif;

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

730bA    // IS THE LICENSE IN LICINFO
730bA    if $ilcns <> ' ';
730bA      chain ($iwhse: $ilcns) licinfo2;
730bA      if %found(licinfo2);
730bA        licinfofound = *on;
730bA      else;
730bA        licinfofound  = *off;
730bA      endif;
730bA    else;
730bA      licinfofound = *on;
730bA    endif;
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
700cA   exsr zzimopt;
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
650cA    if $ppo <> '*ALL';
650cA      // Create "Inner join" clause.
650cA
650cA      sqljoin = 'INNER JOIN ' + sqlfile1 + ' ' +
650cA               'ON ' + 'lnwhse=uiwhse and lnlcns=uilcns';
650cA    endif;

         // Create "where" clause.

         sqlwhere = ' ';
         append5  = 'WHERE';

700bA    // only select lnseq = 1
700bA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
700bA               + 'lnseq=1';
700bA      append5 = ' and ';

         // Warehouse

         if w1whse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'uiwhse=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';
         endif;

         // License

         if w1lcns <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + '('
                    + 'uilcns='
                    + sq + %trim(w1lcns) + sq
                    + ')';
           append5 = ' and ';
         endif;
650cA    // item
650cA
650cA    if w1item <> '*ALL';
650cA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
650cA               + '('
650cA               + 'lnitem='
650cA               + sq + %trim(w1item) + sq
650cA               + ')';
650cA      append5 = ' and ';
650cA    endif;

650cA    // po
650cA
650cA    if w1po   <> '*ALL';
650cA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
650cA               + '('
650cA               + 'lnpo='
650cA               + sq + %trim(w1po) + sq
650cA               + ')';
650cA      append5 = ' and ';
650cA    endif;

         // Create "Order By" clauses.

         select;

           when sortorder1 = 'DESCEND';
             if w1oby = '1';
               sqlorder = 'ORDER BY UILCNS DESC';
             else;
               sqlorder = 'ORDER BY UILCNS DESC';
             endif;

           other;
             if w1oby = '1';
               sqlorder = 'ORDER BY UILCNS';
             else;
               sqlorder = 'ORDER BY UILCNS';
             endif;

         endsl;

         // Create SQL statement.

         SqlStmt = 'SELECT '
                 + %trimr(sqlfields) + ' '
                 + %trimr(sqlfrom) + ' '
650cA            + %trimr(sqljoin) + ' '
                 + %trimr(sqlwhere) + ' '
                 + sqlorder;

       endsr;
      /end-free

730bA*----------------------------------------------------------------
730bA*  sqlbldstmt2 - Build SQL statment
730bA*----------------------------------------------------------------

730bA /free
730bA  begsr sqlbldstmt2;

730bA    // Create "From" clause.

730bA      sqlfrom = 'FROM ' + sqlfile;
730bA

730bA    // Create "where" clause.

730bA    sqlwhere = ' ';
730bA    append5  = 'WHERE';


730bA    // Warehouse

730bA    if w1whse > 0;
730bA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
730bA               + 'uiwhse=' + %trim(%editc(w1whse:'P'));
730bA      append5 = ' and ';
730bA    endif;

730bA    // License

730bA    if w1lcns <> '*ALL';
730bA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
730bA               + '('
730bA               + 'uilcns='
730bA               + sq + %trim(w1lcns) + sq
730bA               + ')';
730bA      append5 = ' and ';
730bA    endif;
730bA    // item
730bA
730bA    if w1item <> '*ALL';
730bA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
730bA               + '('
730bA               + 'lnitem='
730bA               + sq + %trim(w1item) + sq
730bA               + ')';
730bA      append5 = ' and ';
730bA    endif;

730bA    // po
730bA
730bA    if w1po   <> '*ALL';
730bA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
730bA               + '('
730bA               + 'lnpo='
730bA               + sq + %trim(w1po) + sq
730bA               + ')';
730bA      append5 = ' and ';
730bA    endif;

730bA    // Create "Order By" clauses.

730bA    select;

730bA      when sortorder1 = 'DESCEND';
730bA        if w1oby = '1';
730bA          sqlorder = 'ORDER BY UILCNS DESC';
730bA        else;
730bA          sqlorder = 'ORDER BY UILCNS DESC';
730bA        endif;

730bA      other;
730bA        if w1oby = '1';
730bA          sqlorder = 'ORDER BY UILCNS';
730bA        else;
730bA          sqlorder = 'ORDER BY UILCNS';
730bA        endif;

730bA    endsl;

730bA    // Create SQL statement.

730bA    SqlStmt = 'SELECT '
730bA            //+ %trimr(sqlfields) + ' '
730bA            + %trimr(sqlfields2) + ' '
730bA            + %trimr(sqlfrom) + ' '
730bA            + %trimr(sqljoin) + ' '
730bA            + %trimr(sqlwhere) + ' '
730bA            + sqlorder;

730bA  endsr;
730bA /end-free

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
730bA    if licinfofound;
         exsr sqlbldstmt1;
730bA    else;
730bA      exsr sqlbldstmt2;
730bA    endif;
         exsr sqlprep;
         exsr sflclr;
730bA    if licinfofound;
         exsr sflbld1;
730bA    else;
730bA      exsr sflbld2;
730bA    endif;

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

650cD      //exec sql FETCH NEXT FROM mycsr INTO :uciinfo;
650cM      exec sql FETCH NEXT FROM mycsr INTO :fetchds;

           If sqlstt = sqlSuccess;
710aA        if #fwgtlbs = 0 and #fcrtby = '6'
720aA           or #fwgtlbs = 0 and %subst(#fucilcns:1:1) = 'P';
710aA        else;
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
710aA        endif;
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

730bA*----------------------------------------------------------------
730bA*  sflbld2 - Build the subfile
730bA*----------------------------------------------------------------

730bA /free
730bA  begsr sflbld2;

730bA    rrn1 = Lastrrn;
730bA    recpos = lastrrn;
730bA    first = *on;

730bA    // Process the records in the SQL cursor until the return not = 0

730bA    for i = 1 to subfilePage;

730bA      // Get the next row from the SQL cursor.

730bA      exec sql FETCH NEXT FROM mycsr INTO :fetchds2;

730bA      If sqlstt = sqlSuccess;
730bA        if #f2wgtlbs = 0 and #f2crtby = '6'
730bA           or #f2wgtlbs = 0 and %subst(#f2ucilcns:1:1) = 'P';
730bA        else;
730bA          exsr sflFill2;
730bA          rrn1 = rrn1  + 1;
730bA          if first;
730bA            first = *off;
730bA            recpos = rrn1;
730bA          endif;
730bA          option = ' ';
730bA          write sfl1;
730bA          write sfl2;
730bA          write sfl3;
730bA        endif;
730bA      else;
730bA        leave;
730bA      endif;

730bA    endfor;

730bA    if rrn1 = 0;
           *in32 = *on;
730bA    else;
730bA      lastrrn = rrn1;
730bA    endif;

730bA    if sqlstt = sqlNoMoreData;
730bA    endif;


730bA  endsr;
730bA /end-free

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
         //write sf4ctl;
         //write sf5ctl;
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
650cD    //h1whse = uiwhse;
650cM    h1whse = #fwhse;

650cD    //#uilcns = uilcns;
650cM    //#uiuci = uiuci;
650cA    #uilcns = #flcns;
650cA    #uiuci = #fuci;
650dA    #uiucia = #fuci;
ICBaA    select;
ICBaA      when client = icb;
ICBaA        #lnlot = #flnlot;
ICBaA      other;
ICBaA        #lnlot = ' ';
ICBaA    endsl;
730aA    if #fseltrn# <> 0 and #fRTNTRN# = 0;
730aA      *in40 = *on;
730aA      wgtgone = '*';
730aA    else;
730aA      *in40 = *off;
730aA      wgtgone = ' ';
730aA    endif;
      /end-free
         // call to convert the uci barcode information
     C                   eval      $cbcmd = '*ALL    '
650cDC*                  eval      $cbbar = uiuci
650cMC                   eval      $cbbar = #fuci
     c                   clear                   $barcode
     c                   clear                   $barcode2
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     C*                  parm      phven         $cbven           10 0
650bDC*                  parm                    $cbven           10 0
650bMC                   parm      $itven#       $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2
700cAC                   parm      $pwhse        $cbwhse
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
      * we have gs1 barcode
     c                   if        not $bcgtinsent
740aAc                             and not $bcai99sent
      * go look for weight only
     C                   eval      $cbcmd = '*CWGTLBS'
650cDC*                  eval      $cbbar = uiuci
650cMC                   eval      $cbbar = #fuci
     c                   clear                   $barcode
     c                   clear                   $barcode2
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     C*                  parm      phven         $cbven           10 0
650bDC*                  parm                    $cbven           10 0
650bMC                   parm      $itven#       $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
     c                   endif
      * if no weight found, just use uci as weight, as if someone entered it
      /free
650aA    $cvprg = #pgm;
650aA    Select;
650aD    //if $bcgtinsent;
650aM    When $bcgtinsent;
           // Convert prod date
           if $bcProdDSent;
             $cvcmd = '*YMDMDY';
             $cvd6i = %char($bcProdD);
             cvtdte($cvtdt);
             #proddt = %trim(%editc($cvd6o:'Y'));
           else;
             #proddt = ' ';
           endif;

           // Convert pack date
           if $bcPackDSent;
             $cvcmd = '*YMDMDY';
             $cvd6i = %char($bcPackD);
             cvtdte($cvtdt);
             #packdt = %trim(%editc($cvd6o:'Y'));
           else;
             #packdt = ' ';
           endif;

           // Convert sell by date
           if $bcslbyDSent;
             $cvcmd = '*YMDMDY';
             $cvd6i = %char($bcslbyD);
             cvtdte($cvtdt);
             #sellby = %trim(%editc($cvd6o:'Y'));
           else;
             #sellby = ' ';
           endif;

           // Convert expiration date
           if $bcexpDSent;
             $cvcmd = '*YMDMDY';
             $cvd6i = %char($bcexpD);
             cvtdte($cvtdt);
             #expdat = %trim(%editc($cvd6o:'Y'));
           else;
             #expdat = ' ';
           endif;

           // load weight to display
700cA      select;
700cA        when IMkilolbs = 'K';
700cA          Select;
700cA            when $bcpntkgsent;
730aD              //#weight = %trim(%editc($bcpntkg:'3'));
730aM              #weight = %trim(%editc($bcpntkg:'3')) + wgtgone;
700cA              totwgt = totwgt + $bcpntkg;
700aA              totcnt = totcnt + 1;
700cA            other;
700cA              #weight = ' ';
700cA              totcnt = totcnt + 1;
700cA          endsl;
700cA        other;
               Select;
710aA            when #fwgtlbs = 0;
710aA              #weight = ' ';
710aA              totcnt = totcnt + 0;
                 when $bcpntlbsent;
730aD              //#weight = %trim(%editc($bcpntlb:'3'));
730aM              #weight = %trim(%editc($bcpntlb:'3')) + wgtgone;
650dA              totwgt = totwgt + $bcpntlb;
700aA              totcnt = totcnt + 1;
                 when $bcpntkgsent;
730aD              //#weight = %trim(%editc($bcpntkg:'3'));
730aM              #weight = %trim(%editc($bcpntkg:'3')) + wgtgone;
650dA              totwgt = totwgt + $bcpntkg;
700aA              totcnt = totcnt + 1;
                 other;
                   #weight = ' ';
700aA              totcnt = totcnt + 1;
               endsl;
700cA      endsl;
           // load GTIN to display
           #gtin = $bcgtin;
           // load lot to display
           if $bclotsent;
             #lot    = %trim($bclot);
           else;
             #lot    = ' ';
           endif;
           // load Serial# to display
           if $bcser#sent;
             #Serial = %trim($bcser#);
           else;
             #Serial = ' ';
           endif;
650aA    when $bcai99sent;
650aA      #proddt = ' ';

650aA      // Convert pack date
650aA      #packdt = ' ';

650aA      // Convert sell by date
650aA      #sellby = ' ';

650aA      // Convert expiration date
650aA      #expdat = ' ';

650aA      // load weight to display
700cA      select;
700cA        when IMkilolbs = 'K';
700cA          Select;
700cA            when #fwgtkgs >0;
730aD              //#weight = %trim(%editc(#fwgtkgs:'3'));
730aM              #weight = %trim(%editc(#fwgtkgs:'3')) + wgtgone;
700cA              totwgt = totwgt + #fwgtkgs;
700cA              totcnt = totcnt + 1;
700cA            other;
700cA              #weight = ' ';
700cA              totcnt = totcnt + 1;
700cA          endsl;
700cA        other;
650aA          Select;
650cD            //when uiwgtlbs >0;
650cD              //#weight = %trim(%editc(uiwgtlbs:'3'));
650cD            //when uiwgtkgs >0;
650cD              //#weight = %trim(%editc(uiwgtkgs:'3'));
650cM            when #fwgtlbs >0;
730aD              //#weight = %trim(%editc(#fwgtlbs:'3'));
730aM              #weight = %trim(%editc(#fwgtlbs:'3')) + wgtgone;
650dA              totwgt = totwgt + #fwgtlbs;
700aA              totcnt = totcnt + 1;
650cM            when #fwgtkgs >0;
730aD              //#weight = %trim(%editc(#fwgtkgs:'3'));
730aM              #weight = %trim(%editc(#fwgtkgs:'3')) + wgtgone;
650dA              totwgt = totwgt + #fwgtkgs;
700aA              totcnt = totcnt + 1;
650aA            other;
650aA              #weight = ' ';
700aA              totcnt = totcnt + 1;
650aA          endsl;
700cA      endsl;
650aA      // load GTIN to display
650aA      #gtin = ' ';
650aA      #lot    = ' ';
650aA      #Serial = ' ';
650cA    when #fCRTBY = '6' or #fCRTBY = '7';
650cA      #proddt = ' ';

650cA      // Convert pack date
650cA      #packdt = ' ';

650cA      // Convert sell by date
650cA      #sellby = ' ';

650cA      // Convert expiration date
650cA      #expdat = ' ';

650cA      // load weight to display
650cA      Select;
650cA        when #fwgtlbs >0;
730aD          //#weight = %trim(%editc(#fwgtlbs:'3'));
730aM          #weight = %trim(%editc(#fwgtlbs:'3')) + wgtgone;
650dA          totwgt = totwgt + #fwgtlbs;
700aA          totcnt = totcnt + 1;
650cA        when #fwgtkgs >0;
730aD          //#weight = %trim(%editc(#fwgtkgs:'3'));
730aM          #weight = %trim(%editc(#fwgtkgs:'3')) + wgtgone;
650dA          totwgt = totwgt + #fwgtkgs;
700aA          totcnt = totcnt + 1;
650cA        other;
650cA          #weight = ' ';
700aA          totcnt = totcnt + 1;
650cA      endsl;
650cA      // load GTIN to display
650cA      #gtin = ' ';
ICBaA      select;
ICBaA        when client = icb;
ICBaA          #lot = #flnlot;
ICBaA        other;
650cA      #lot    = ' ';
ICBaA      endsl;
650cA      #Serial = ' ';
650aD    //else;
650aM    other;
           $bcExpDSent = *off;
           $bcProdDSent = *off;
           $bcPackDSent = *off;
           $bcslbyDSent = *off;
           $bcPNtLbSent = *off;
           $bcPNtkgSent = *off;
           $bcser#Sent = *off;
           $bcLotSent = *off;
650aD    //endif;
650aA    endsl;

       endsr;
      /end-free

730bA*----------------------------------------------------------------
730bA*  sflFill2  -  Fill subfile line
730bA*----------------------------------------------------------------

730bA /free
730bA  begsr sflFill2;

730bA    // Store hiddent fields that aren't displayed on screen.
730bA    h1whse = #f2whse;

730bA    #uilcns = #f2lcns;
730bA    #uiuci = #f2uci;
730bA    #uiucia = #f2uci;
730bA    #lnlot = ' ';
730bA /end-free
730bA    // call to convert the uci barcode information
730bAC                   eval      $cbcmd = '*ALL    '
730bAC                   eval      $cbbar = #f2uci
730bAc                   clear                   $barcode
730bAc                   clear                   $barcode2
     *
730bAC                   call      'CVTBAR'
730bAC                   parm                    $cbcmd            8
730bAC                   parm                    $cbbar          100
730bAC                   parm                    $cbcod            3 0
730bAC                   parm                    $cbdec            1 0
730bAC                   parm                    $cbdsc           30
730bAC                   parm                    $cbpos            3 0
730bAC                   parm                    $cbtyp            1 0
730bAC                   parm                    $cbv1            11 3
730bAC                   parm                    $cbv2            50
730bAC                   parm                    $cbrtn            8
730bAC                   parm                    $cberm           60
730bAC                   parm      $itven#       $cbven           10 0
730bAC                   parm                    $cvtdata
730bAC                   parm                    $cvtdata2
730bAC                   parm      $pwhse        $cbwhse
730bAc                   eval      $barcode = $cvtdata
730bAc                   eval      $barcode2 = $cvtdata2
730bA * we have gs1 barcode
730bAc                   if        not $bcgtinsent
730bA * go look for weight only
730bAC                   eval      $cbcmd = '*CWGTLBS'
730bAC                   eval      $cbbar = #f2uci
730bAc                   clear                   $barcode
730bAc                   clear                   $barcode2
730bA*
730bAC                   call      'CVTBAR'
730bAC                   parm                    $cbcmd            8
730bAC                   parm                    $cbbar          100
730bAC                   parm                    $cbcod            3 0
730bAC                   parm                    $cbdec            1 0
730bAC                   parm                    $cbdsc           30
730bAC                   parm                    $cbpos            3 0
730bAC                   parm                    $cbtyp            1 0
730bAC                   parm                    $cbv1            11 3
730bAC                   parm                    $cbv2            50
730bAC                   parm                    $cbrtn            8
730bAC                   parm                    $cberm           60
730bAC                   parm      $itven#       $cbven           10 0
730bAC                   parm                    $cvtdata
730bAC                   parm                    $cvtdata2
730bAc                   eval      $barcode = $cvtdata
730bAc                   eval      $barcode2 = $cvtdata2
730bAc                   endif
730bA * if no weight found, just use uci as weight, as if someone entered it
730bA /free
730bA    $cvprg = #pgm;
730bA    Select;
730bA    When $bcgtinsent;
730bA      // Convert prod date
730bA      if $bcProdDSent;
730bA        $cvcmd = '*YMDMDY';
730bA        $cvd6i = %char($bcProdD);
730bA        cvtdte($cvtdt);
730bA        #proddt = %trim(%editc($cvd6o:'Y'));
730bA      else;
730bA        #proddt = ' ';
730bA      endif;

730bA      // Convert pack date
730bA      if $bcPackDSent;
730bA        $cvcmd = '*YMDMDY';
730bA        $cvd6i = %char($bcPackD);
730bA        cvtdte($cvtdt);
730bA        #packdt = %trim(%editc($cvd6o:'Y'));
730bA      else;
730bA        #packdt = ' ';
730bA      endif;

730bA      // Convert sell by date
730bA      if $bcslbyDSent;
730bA        $cvcmd = '*YMDMDY';
730bA        $cvd6i = %char($bcslbyD);
730bA        cvtdte($cvtdt);
730bA        #sellby = %trim(%editc($cvd6o:'Y'));
730bA      else;
730bA        #sellby = ' ';
730bA      endif;

730bA      // Convert expiration date
730bA      if $bcexpDSent;
730bA        $cvcmd = '*YMDMDY';
730bA        $cvd6i = %char($bcexpD);
730bA        cvtdte($cvtdt);
730bA        #expdat = %trim(%editc($cvd6o:'Y'));
730bA      else;
730bA        #expdat = ' ';
730bA      endif;

730bA      // load weight to display
730bA      select;
730bA        when IMkilolbs = 'K';
730bA          Select;
730bA            when $bcpntkgsent;
730bA              #weight = %trim(%editc($bcpntkg:'3'));
730bA              totwgt = totwgt + $bcpntkg;
730bA              totcnt = totcnt + 1;
730bA            other;
730bA              #weight = ' ';
730bA              totcnt = totcnt + 1;
730bA          endsl;
730bA        other;
730bA          Select;
730bA            when #f2wgtlbs = 0;
730bA              #weight = ' ';
730bA              totcnt = totcnt + 0;
730bA            when $bcpntlbsent;
730bA              #weight = %trim(%editc($bcpntlb:'3'));
730bA              totwgt = totwgt + $bcpntlb;
730bA              totcnt = totcnt + 1;
730bA            when $bcpntkgsent;
730bA              #weight = %trim(%editc($bcpntkg:'3'));
730bA              totwgt = totwgt + $bcpntkg;
730bA              totcnt = totcnt + 1;
730bA            other;
730bA              #weight = ' ';
730bA              totcnt = totcnt + 1;
730bA          endsl;
730bA      endsl;
730bA      // load GTIN to display
730bA      #gtin = $bcgtin;
730bA      // load lot to display
730bA      if $bclotsent;
730bA        #lot    = %trim($bclot);
730bA      else;
730bA        #lot    = ' ';
730bA      endif;
730bA      // load Serial# to display
730bA      if $bcser#sent;
730bA        #Serial = %trim($bcser#);
730bA      else;
730bA        #Serial = ' ';
730bA      endif;
730bA    when $bcai99sent;
730bA      #proddt = ' ';

730bA      // Convert pack date
730bA      #packdt = ' ';

730bA      // Convert sell by date
730bA      #sellby = ' ';

730bA      // Convert expiration date
730bA      #expdat = ' ';

730bA      // load weight to display
730bA      select;
730bA        when IMkilolbs = 'K';
730bA          Select;
730bA            when #f2wgtkgs >0;
730bA              #weight = %trim(%editc(#f2wgtkgs:'3'));
730bA              totwgt = totwgt + #f2wgtkgs;
730bA              totcnt = totcnt + 1;
730bA            other;
730bA              #weight = ' ';
730bA              totcnt = totcnt + 1;
730bA          endsl;
730bA        other;
730bA          Select;
730bA            when #f2wgtlbs >0;
730bA              #weight = %trim(%editc(#f2wgtlbs:'3'));
730bA              totwgt = totwgt + #f2wgtlbs;
730bA              totcnt = totcnt + 1;
730bA            when #f2wgtkgs >0;
730bA              #weight = %trim(%editc(#f2wgtkgs:'3'));
730bA              totwgt = totwgt + #f2wgtkgs;
730bA              totcnt = totcnt + 1;
730bA            other;
730bA              #weight = ' ';
730bA              totcnt = totcnt + 1;
730bA          endsl;
730bA      endsl;
730bA      // load GTIN to display
730bA      #gtin = ' ';
730bA      #lot    = ' ';
730bA      #Serial = ' ';
730bA    when #f2CRTBY = '6' or #f2CRTBY = '7';
730bA      #proddt = ' ';

730bA      // Convert pack date
730bA      #packdt = ' ';

730bA      // Convert sell by date
730bA      #sellby = ' ';

730bA      // Convert expiration date
730bA      #expdat = ' ';

730bA      // load weight to display
730bA      Select;
730bA        when #f2wgtlbs >0;
730bA          #weight = %trim(%editc(#f2wgtlbs:'3'));
730bA          totwgt = totwgt + #f2wgtlbs;
730bA          totcnt = totcnt + 1;
730bA        when #f2wgtkgs >0;
730bA          #weight = %trim(%editc(#f2wgtkgs:'3'));
730bA          totwgt = totwgt + #f2wgtkgs;
730bA          totcnt = totcnt + 1;
730bA        other;
730bA          #weight = ' ';
730bA          totcnt = totcnt + 1;
730bA      endsl;
730bA      // load GTIN to display
730bA      #gtin = ' ';
730bA      #lot    = ' ';
730bA      #Serial = ' ';
730bA    //else;
730bA    other;
730bA      $bcExpDSent = *off;
730bA      $bcProdDSent = *off;
730bA      $bcPackDSent = *off;
730bA      $bcslbyDSent = *off;
730bA      $bcPNtLbSent = *off;
730bA      $bcPNtkgSent = *off;
730bA      $bcser#Sent = *off;
730bA      $bcLotSent = *off;
730bA    endsl;

730bA  endsr;
730bA /end-free
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

         scrname = 'UI320.01';
         w1sort = 'D';
         w1oby = '2';
         exsr inzcriteria1;
         exsr zzgettime;
         exsr zzgetslotitem;

         exsr setcriteria1;

         scopt1 = ' ';
         // scopt1 = '5=View  ';
            //  + '71=Lcns hist  '
            //  + '72=Item hist  '
            //  + '73=Slot hist  '
            //  + '74=OLcns hist  ';
            //  + '75=Lcnse Info  ';

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
             //when curview = 5;
               //exfmt sf5ctl;
             //when curview = 4;
               //exfmt sf4ctl;
             when curview = 3;
               exfmt sf3ctl;
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
                    lt325('*VIEW': h1whse: h1lcns: h1adduc);

                  when optiontaken = 'V1';
                    ll830(' ': h1whse: h1lcns: h1adduc);

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

                  when optiontaken = 'ViewLabel';
                    lb830(' ': %editc(h1lbl#:'X'));

                  when optiontaken = 'ViewTran';
                    pt830(' ': %editc(h1trn#:'X'));

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

650dA        // F21 = Print

650dA        when cfkey = F21;
650dA          exsr printlist;


             // PageDown = More records

             When cfkey = PageDown;
730bA          if licinfofound;
                 exsr sflbld1;
730bA          else;
730bA            exsr sflbld2;
730bA          endif;

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

650dA    w1sort = 'A';
650dA    w1oby = '1';

650dA    wpdev = $pdev;
650dA    wpform = $pform;

650dA    exsr inzcriteria1;
650dA    exsr setcriteria1;

650dA    exsr printlist;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printlist - Print list
     *----------------------------------------------------------------

      /free
       begsr printlist;

650dA    totwgt = 0;
700aA    totcnt = 0;
650dA    exsr sqlclean;
730bA    if licinfofound;
650dA      exsr sqlbldstmt1;
730bA    else;
730bA      exsr sqlbldstmt2;
730bA    endif;
650dA    exsr sqlprep;
650dA    exsr setupPrint;

730bA    if licinfofound;
650dA    exsr prtRprt;
730bA    else;
730bA      exsr prtRprt2;
730bA    endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printhead - Print heading line
     *----------------------------------------------------------------

      /free
       begsr printhead;
         // Print report heading
650dA    write head1;
650dA    write desc1;

         // Print Column Headings
ICBaA    select;
ICBaA      when client = icb;
ICBaA        write columns2;
ICBaA      other;
650dA        write columns1;
ICBaA    endsl;

650dA    *in90 = *off;
650dA    *in91 = *on;

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
650dA*----------------------------------------------------------------
650dA*  centerscdesc - Center characters in scdesc
650dA*----------------------------------------------------------------

650dA /free
650dA  begsr centerscdesc;

650dA    scdesc = $itdesc;
650dA    scdesclen = %len(%trim(scdesc));
650dA    if scdesclen > 0
650dA       and scdesclen < %size(scdesc);
650dA         scpad = %int((%size(scdesc)-scdesclen)/2);
650dA         scdesc = %subst(blanks:1:scpad)
650dA                + %trim(scdesc);
650dA    endif;

650dA  endsr;
650dA /end-free


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
         w1itemL= '*ALL';
         w1lcns = '*ALL';
650cA    w1po   = '*ALL';
         w1action = 'ALL';
         w1emp# = 0;
         w1trn# = 0;
         w1base = '*ALL';
         w1hide = 'N';

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
         // Convert Dates.

         exsr zzconvertdate;
         exsr zzgetslotitem;

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

650cA    if $ppo = ' ';
650cA      w1po = '*ALL';
650cA    else;
           w1po = $ppo;
           w1sort = 'A';
           w1oby = '2';
650cA    endif;

         if $pemp# = 0;
           w1emp# = 0;
         else;
           w1emp# = $pemp#;
         endif;

         if $ptrn# = 0;
           w1trn# = 0;
         else;
           w1trn# = $ptrn#;
         endif;

         w1action= 'ALL';
         w1itemL= '*ALL';
         w1base = '*ALL';
         w1hide = 'N';

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


         if w1oby = '2';
650eD      //schead = %trimr(schead) + append1
650eM      schead = %trimr(schead) + append1;
650eD             //+ 'By Lcns';
650eD      //append1 = ',';
         endif;

         if w1lcns <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Lcns=' + w1lcns;
           append1 = ',';
         endif;

650cA    if w1po   <> '*ALL';
650cA      schead = %trimr(schead) + append1
650cA             + 'PO=' + w1po;
650cA      append1 = ',';
650cA    endif;

         if w1item <> '*ALL';
           schead = %trimr(schead) + append1
                  //+ 'Item=' + w1item;
                  + 'Slot Item=' + w1item;
           append1 = ',';
         endif;



         if append1 = ' ';
           schead = %trimr(schead) + ',Everything';
         endif;

         exsr centerschead;
650dA    exsr centerscdesc;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZCONVERTDATE - Convert selection dates.
     *
     *----------------------------------------------------------------
      /free
       begsr zzconvertdate;
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
         $cddays = 2;
         clcdur2($cdcmd: w1tdatwork: $cdtimein: $cdyears:
                 $cdmonths: $cddays: $cdhours: $cdminutes:
                 $cdseconds: $cddateout: $cdtimeout);
         w1fdatwork = $cddateout;
         if client = cityln;
           w1fdatwork = 0;
         endif;
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
     *----------------------------------------------------------------
650dA*  setupPrint - Setup Report
     *----------------------------------------------------------------

650dA /free
650dA  begsr setupPrint;

650dA    // Load device and form if not loaded.

650dA    if wpdev = ' ';
650dA      wpdev = '*JOB';
650dA    endif;

650dA    if wpform = ' ';
650dA      wpform = '*STD';
650dA    endif;

650dA    //  Display window to get device and form to use (Only in *DISPLAY mode

650dA      exfmt windowp;

650dA    if cfkey <> F3 and cfkey <> F12;

650dA      // Override printer file.

650dA      if wpdev = ' ';
650dA        wpdev = '*JOB';
650dA      endif;

650dA      if wpform = ' ';
650dA        wpform = '*STD';
650dA      endif;

650dA      qcmd = 'OVRPRTF '
650dA           + 'FILE(UI320PR) '
650dA           + 'OUTQ(*DEV) '
650dA           + 'DEV(' + %trim(wpdev) + ') '
650dA           + 'FORMTYPE(' + %trim(wpform) + ') ';

650dA /end-free
650dAC                   call      'QCMDEXC'
650dAC                   parm                    qcmd             80
650dAC                   parm      80            qlen             15 5
650dA /free

650dA    endif;

650dA    first = *on;
650dA    printflag = *off;

650dA  endsr;
650dA /end-free

650dA*----------------------------------------------------------------
650dA*  printDetl - Print detail line
650dA*----------------------------------------------------------------

650dA /free

650dA  begsr printDetl;

650dA    // See if heading needs to be printed.

650dA    if *in90;
650dA      exsr printhead;
650dA    endif;

        // Print detail line

ICBaA    select;
ICBaA      when client = icb;
ICBaA        write detail2;
ICBaA      other;
650dA        write detail1;
ICBaA    endsl;
650dA    printflag = *on;

650dA  endsr;

650dA /end-free

650dA*----------------------------------------------------------------
650dA*  prtRprt -  Print the Report
650dA*----------------------------------------------------------------

650dA /free

650dA  begsr prtRprt;

650dA    // Open printer file.

650dA    open(e)   ui320pr;
650dA    if %error;
650dA    endif;

650dA    // Process the records in the SQL cursor until the return not = 0

650dA      // dou sqlstt <> sqlSuccess;
650dA    dou 1 <> 1;

650dA      // Get the next row from the SQL cursor.

650dA      exec sql FETCH NEXT FROM mycsr INTO :fetchds;

650dA      If sqlstt = sqlSuccess;
710aA        if #fwgtlbs = 0 and #fcrtby = '6'
720aA           or #fwgtlbs = 0 and %subst(#fucilcns:1:1) = 'P';
710aA        else;
650dA          exsr sflFill1;

650dA          if first;
650dA            exsr printhead;
650dA            first = *off;
650dA            exsr printdetl;
650dA            else;
650dA            exsr printdetl;
650dA          endif;
710aA        endif;
650dA      else;
650dA        leave;
650dA      endif;

650dA    enddo;

650dA    if sqlstt = sqlNoMoreData;
650dA    endif;

650dA     if        not printflag;
650dA       exsr      printhead;
650dA       else;
            write total1;
650dA     endif;

650dA    // Close printer file.

650dA    close(e)   ui320pr;
650dA    if %error;
650dA    endif;

650dA  endsr;
650dA /end-free
730bA*----------------------------------------------------------------
730bA*  prtRprt2-  Print the Report
730bA*----------------------------------------------------------------

730bA /free

730bA  begsr prtRprt2;

730bA    // Open printer file.

730bA    open(e)   ui320pr;
730bA    if %error;
730bA    endif;

730bA    // Process the records in the SQL cursor until the return not = 0

730bA      // dou sqlstt <> sqlSuccess;
730bA    dou 1 <> 1;

730bA      // Get the next row from the SQL cursor.

730bA      exec sql FETCH NEXT FROM mycsr INTO :fetchds2;

730bA      If sqlstt = sqlSuccess;
730bA        if #f2wgtlbs = 0 and #f2crtby = '6'
730bA           or #f2wgtlbs = 0 and %subst(#f2ucilcns:1:1) = 'P';
730bA        else;
730bA          exsr sflFill2;

730bA          if first;
730bA            exsr printhead;
730bA            first = *off;
730bA            exsr printdetl;
730bA            else;
730bA            exsr printdetl;
730bA          endif;
730bA        endif;
730bA      else;
730bA        leave;
730bA      endif;

730bA    enddo;

730bA    if sqlstt = sqlNoMoreData;
730bA    endif;

730bA     if        not printflag;
730bA       exsr      printhead;
730bA       else;
730bA       write total1;
730bA     endif;

730bA    // Close printer file.

730bA    close(e)   ui320pr;
730bA    if %error;
730bA    endif;

730bA  endsr;
730bA /end-free
700cA*----------------------------------------------------------------
700cA*
700cA*  ZZIMOPT  Get Item Maintenance option
700cA*
700cAC     zzimopt       begsr
700cA*
700cA*   Get UOM for weight.
700cA /free
700aA    getimuom($iwhse: IMkilolbs: IMUom);
700cA /end-free
700cA*
700cAC                   endsr

