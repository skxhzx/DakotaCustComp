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
     *  LT330     P.O. Recall Listing
     *  19 August 2009
     *  Dave Sommerville
     *
     *  Revisions
     *
610 A*    08/19/09  DAS  6.10  P#00045
     *      - Created.
     *
610bA*    08/19/09  CWM  6.10b P#00045
     *      - Added Print Functionality
     *
610cA*    08/21/09  DAS  6.10c
     *      - Revised to display F9 window if no parms passed in.
610dA*    09/22/10  RH   6.10d
     *      - Enh: Include adjustments made to license to account
     *        for total quantity received.
     *
640a *    01/19/11  GJA  6.40a
     *      - Fix:  If does not find order it would not show on report
     *        the view works correctly.
     *
640b *    01/20/11  GJA  6.40b
     *      - Enh:  Add F22 for ability to download a file
     *
640c *    06/14/12  LMC  6.40c
     *      - Fix: Order by on sqlStmt was on different fields then
     *        the screen headings description. Changed the order by
     *        to agree with screen heading description.
     *      - corrected display file changes to use new source member
     *        from mod 6.40b
640d *    06/26/12  LMC  6.40d
     *      - Fix: Added the ability to call this program from item
     *        maintenance, along with some additional selection fields
     *        New Display file LT33002 replaces LT33001.
640e *    10/19/12  LMC  6.40e
     *      - Fix: Mods so program will work with new LICINFO file
650a *    05/16/13  RH   6.50a
     *      - Enh: Re-compile only, added original lic to LT330PR
650bA*    05/16/13  RBD  6.50b
     *      - Enh: Added ship date, count total per item, and qty
     *        total per item to printed report.
     *      - Enh: Changed screen format to LT33003.
650cA*    10/10/14  LMC  6.50c
     *      - Fix: If invalid expiration date is entered assume no
     *        date is entered.
650dA*    01/20/15  LMC  6.50d
     *      - Fix: If qty is negative reverse the sign for the
     *        totqty.
700aA*    02/25/16  LMC/RH  7.00a
     *      - Fix: Neg Breakdown adj was causing decimal data error.
     *        Item qty was not displaying breakdown UOM qty in totqty
700bA*    07/26/16  NLK     7.00b
     *      - Fix: ICB needed 1 more character to show on the display
     *        for Cust Name to see Kings Supermaret #99, locations.
     *        Display allowed for 2 more so these were added.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

640cDF*lt330fm   cf   e             workstn
640dMF*lt33001   cf   e             workstn
650bDF*lt33002   cf   e             workstn
700bDF*lt33003   cf   e             workstn
700bAFlt33004   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl2:rrn1)
640dAF                                     sfile(sfl5:rrn1)
640dAF                                     sfile(sfl6:rrn1)
     F                                     infds(info)
600BAFlt330pr   O    E             printer usropn
600BAF                                     oflind(*IN90)
600BAFlt331     O    E             disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.cvtqty
      /copy qcopysrc,p.lt320
      /copy qcopysrc,p.lp130
610aA /copy qcopysrc,p.la830
610aA /copy qcopysrc,p.ll830

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

     D licactive     e ds                  inz
     D liclog        e ds                  inz
     D ordh          e ds                  inz
640dAD licinfo       e ds                  inz

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

     D fetchds         ds
     D   #fwhse                            like(lawhse)
     D   #fitem                            like(laitem)
     D   #flcns                            like(lalcns)
     D   #folcns                           like(laolcns)
     D   #fwhdp                            like(lawhdp)
     D   #fdisp                            like(ladisp)
     D   #ford                             like(llord)
     D   #fqty1                            like(laqty1)
     D   #fqty2                            like(laqty2)
     D   #fqty3                            like(laqty3)
     D   #fadduc                     26
640eDD*  #flnvalue                         like(lnvalue)
640eAD   #flnpo                            like(lnpo)
640dAD   #fexpdt                           like(laexpd)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

     D $icmd           s              8
     D $iwhse          s              3  0
     D $ipo            s              9
     D $iitem          s             15
     D $idev           s             10
     D $iform          s             10

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $ppo            s                   like($ipo)
     D $pitem          s                   like($iitem)
     D $pdev           s                   like($idev)
     D $pform          s                   like($iform)

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
640dAD foundCustOrd    s               n
     D groupby         S            100a   inz(' ')
     D groupfields     S            100a   inz(' ')
     D iorder1         s             20    inz(' ')
     D iorder2         s             20    inz(' ')
650bAD lastitem        s                   like(laitem)
     D lastrrn         s                   like(rrn1)
640dDD*maxview         s              1  0 inz(2)
640dMD maxview         s              1  0 inz(4)
     D newordpos       s              3  0 inz(0)
610cAD noParmsPassed   s               n
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
650bAD ordqty          s             10  0 inz(0)
     D posfld          s              5    inz(' ')
     D recpos          s                   like(rrn1)
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')
     D sortorder2      s             10    inz(' ')
     D sortorder3      s             10    inz(' ')
     D printflag       s               n
     D wkCount         s             10  0 inz(0)
700aAD wkiqty1         s              7  0 inz(0)
700aAD wkiqty2         s              7  0 inz(0)
700aAD wkiqty3         s              7  0 inz(0)
700aAD wkrqty          s             10
640dAD w1expdta        s              8

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1lcns                 1     15
     D  h1olcns               16     30
     D  h1item                31     45
     D  h1whdp                46     50
     D  h1disp                51     62
610aAD  h1adduc               63     88
610aAD  h1ord                 89     95S 0
610aAD  h1whse                96     98S 0
640dAD  h1po                  99    107
     D  h1dummy              110    110
640dAD  h1expdt              111    118s 0
650bAD  h1sdte               119    124s 0

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
     *      $pvalue  - Value
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
     C                   parm                    $ipo
     C                   parm                    $iitem
     C                   parm                    $idev
     C                   parm                    $iform

      /free

610cA    noParmsPassed = *on;

         if %parms >= 1;
           $pcmd = $icmd;
         else;
           $pcmd = ' ';
         endif;

         if %parms >= 2 and $iwhse > 0;
           $pwhse = $iwhse;
610cA      noParmsPassed = *off;
         else;
           $pwhse = 0;
         endif;

610cM    if %parms >= 3 and $ipo <> ' ';
           $ppo  = $ipo;
610cA      noParmsPassed = *off;
         else;
           $ppo  = ' ';
         endif;

610cM    if %parms >= 4 and $iitem <> ' ';
           $pitem = $iitem;
610cA      noParmsPassed = *off;
         else;
           $pitem = ' ';
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

640bD    //if $pcmd = '*PRINT';
640bD    //  exsr printit;
640bD    //else;
640bD    //  exsr screen1;
640bD    //endif;

640bM    select;
640bM      when $pcmd = '*PRINT';
640bM        exsr printit;
640bA        w1msg1 = 'Report has been printed';
640bA        *in55 = *on;
640bM      when $pcmd = '*FILE ';
640bM        exsr fileit;
640bA        w1msg1 = 'File LT331 has been created and ready for export';
640bA        *in55 = *on;
640bM      other;
640dA      if $pcmd = '*DISPITM';
640dA        *in41 = *on;
640dA        *in40 = *off;
640dA      else;
640dA        *in40 = *on;
640dA        *in41 = *off;
640dA      endif;
640bM      exsr screen1;
640bA        w1msg1 = blanks;
640bA        *in55 = *off;
640bM    endsl;

         // Clear work file before leaving.

         exsr sqlClrWrkFile;

         *inlr = *on;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;
650bA    h1sdte = 0;
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


         // Create first part of Union

         sqlStmt = 'SELECT '
                 +   'lawhse,laitem,lalcns,laolcns,'
                 +   'lawhdp,ladisp,0,'
                 +   'laqty1,laqty2,laqty3,'
640dD            //+   'lachguc '
640eD            //+   'lachguc, lnvalue, laexpd '
640eM            +   'lachguc, lnpo, laexpd '
                 + 'FROM worklt330 '
                 + 'INNER JOIN licactive '
                 +   'ON lawhse=wltwhse and laolcns=wltlcns '
640dA            + 'LEFT JOIN licinfo '
640dA            +   'ON lnwhse=wltwhse and lnlcns=wltlcns '
                 + 'WHERE '
                 +   'wltcurusr=' + sq + %trim(#curruser) + sq + ' '
                 +   'and wltjob=' + sq + %trim(#job) + sq + ' '
640dD            //+   'and wltjobnbr=' + sq + %trim(#jobnbr) + sq;
640dM            +   'and wltjobnbr=' + sq + %trim(#jobnbr) + sq + ' '
640eD            //+   'and lncode=' + sq + '*PO' + sq;
640eM            +   'and lnpo <>' + sq + '   ' + sq;

         // Add the Union keyword

         sqlStmt = %trimr(sqlStmt) + ' '
                 + 'UNION ';

         // Now add second part of union

         sqlStmt = %trimr(sqlStmt) + ' '
                 + 'SELECT '
                 +   'llwhse,llitem,lllcns,llolcns,'
                 +   sq+' '+sq+',' + sq+' '+sq + ',llord,'
                 +   'llaqty1,llaqty2,llaqty3,'
640dD            //+   'lladduc '
640eD            //+   'lladduc, lnvalue, llexpd '
640eM            +   'lladduc, lnpo, llexpd '
                 + 'FROM worklt330 '
                 + 'INNER JOIN liclog '
                 +   'ON llwhse=wltwhse and llolcns=wltlcns and llord<>0 '
640dA            + 'LEFT JOIN licinfo '
640dA            +   'ON lnwhse=wltwhse and lnlcns=wltlcns '
                 + 'WHERE '
                 +   'wltcurusr=' + sq + %trim(#curruser) + sq + ' '
                 +   'and wltjob=' + sq + %trim(#job) + sq + ' '
640dD            //+   'and wltjobnbr=' + sq + %trim(#jobnbr) + sq;
640dM            +   'and wltjobnbr=' + sq + %trim(#jobnbr) + sq + ' '
640eD            //+   'and lncode=' + sq + '*PO' + sq;
640eA            +   'and lnpo  <> ' + sq + '  ' + sq;

         // Add adjustment union

         sqlStmt = %trimr(sqlStmt) + ' '
                 + 'UNION ';

         // Now add second part of union

         sqlStmt = %trimr(sqlStmt) + ' '
                 + 'SELECT '
                 +   'llwhse,llitem,lllcns,llolcns,'
                 +   sq+' '+sq+',' + sq+' '+sq + ',llord,'
                 +   'llaqty1,llaqty2,llaqty3,'
640dD            //+   'lladduc '
640eD            //+   'lladduc,lnvalue,llexpd '
640eM            +   'lladduc,lnpo,llexpd '
                 + 'FROM worklt330 '
                 + 'INNER JOIN liclog '
                 +   'ON llwhse=wltwhse and llolcns=wltlcns '
                 +   ' and llaction=' + sq + 'ADJ' + sq + ' '
640dA            + 'LEFT JOIN licinfo '
640dA            +   'ON lnwhse=wltwhse and lnlcns=wltlcns '
                 + 'WHERE '
                 +   'wltcurusr=' + sq + %trim(#curruser) + sq + ' '
                 +   'and wltjob=' + sq + %trim(#job) + sq + ' '
640dD            //+   'and wltjobnbr=' + sq + %trim(#jobnbr) + sq;
640dM            +   'and wltjobnbr=' + sq + %trim(#jobnbr) + sq + ' '
640eD            //+   'and lncode=' + sq + '*PO' + sq;
640eA            +   'and lnpo  <> ' + sq + '   ' + sq;
640cD    // Last of all add the order (item, ord#, disp)
640cM    // Last of all add the order (item, disp, ord#)

         select;
           when w1oby = '1' and w1sort = 'A';
             sqlStmt = %trimr(sqlStmt) + ' '
640cD                //+ 'ORDER BY 1,6,5';
640cM                + 'ORDER BY 2,6,7';
           when w1oby = '1' and w1sort = 'D';
             sqlStmt = %trimr(sqlStmt) + ' '
640cD                //+ 'ORDER BY 1 desc, 6 desc, 5 desc';
640cM                + 'ORDER BY 2 desc, 6 desc, 7 desc';
         endsl;

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
     *  sqlClrWrkFile  -  Clear work file
     *----------------------------------------------------------------

      /free
       begsr sqlClrWrkFile;

         exec sql DELETE FROM worklt330
                  WHERE wltcurusr = :#curruser;

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlInzWrkFile  -  Initialize work file
     *----------------------------------------------------------------

      /free
       begsr sqlInzWrkFile;

         exsr sqlClrWrkFile;

640dA    select;
640dA      when $pcmd = '*DISPITM' or
640dA           $pcmd = '*PRNTITM' or
640dA           $pcmd = '*FILEITM';
640dA        sqlStmt = 'INSERT INTO worklt330 '
640dA                + '(wltcurusr,wltjob,wltjobnbr,wltwhse,wltlcns) '
640dA                +  'SELECT '
640dA                +  sq + %trim(#curruser) + sq + ','
640dA                +  sq + %trim(#job) + sq + ','
640dA                +  sq + %trim(#jobnbr) + sq + ','
640dA                +  'lnwhse,lnlcns '
640dA                +  'FROM licinfo as a '
640dA                +  'WHERE '
640eD                //+  'lncode=' + sq + '*ITEM' + sq + ' '
640eD                //+  'and lnvalue=' + sq + %trim(w1item) + sq;
640eA                +  'a.lnitem = ' + sq + %trim(w1item) + sq;
640dA
640dA        if w1whse > 0;
640dA          sqlStmt = %trimr(sqlStmt) + ' '
640dA                  +  'and lnwhse=' + %trim(%editc(w1whse:'Z'));
640dA        endif;
640dA
640dA        if w1po   <> '*ALL';
640dA          sqlStmt = %trimr(sqlStmt) + ' '
640dA                  + 'and exists(select lnlcns '
640dA                  + 'from licinfo as b '
640dA                  + 'where b.lnwhse=a.lnwhse '
640dA                  +   'and b.lnlcns=a.lnlcns '
640eD                  //+   'and b.lncode=' + sq + '*PO' + sq + ' '
640eD                  //+   'and b.lnvalue=' + sq + %trim(w1po) + sq
640eA                  +   'and b.lnpo =' + sq + %trim(w1po) + sq
640dA                  + ')';
640dA        endif;

650cA        // validate the date - if invalid assume w1expdt = 0
650cA        test(de) *mdy w1expdt;
650cA        if %error;
650cA          w1expdt = 0;
650cA        endif;
640dA        if w1expdt > 0;
640dA          $cvcmd = '*MDYCMD';
640dA          $cvd6i = %char(w1expdt);
640dA          cvtdte($cvtdt);
640dA          #fexpdt = $cvd8o;
640dA          w1expdta = %char(#fexpdt);
640dA          sqlStmt = %trimr(sqlStmt) + ' '
640dA                  + 'and exists(select lnlcns '
640dA                  + 'from licinfo as c '
640dA                  + 'where c.lnwhse=a.lnwhse '
640dA                  +   'and c.lnlcns=a.lnlcns '
640eD                //+   'and c.lncode=' + sq + '*EXPDTE'  + sq + ' '
640eD                //+   'and c.lnvalue=' + sq + %trim(w1expdta) + sq
640eA                  +   'and c.lnexpdate =' + sq + %trim(w1expdta) + sq
640dA                  + ')';
640dA        endif;
640dA
640dA      other;
             sqlStmt = 'INSERT INTO worklt330 '
                     + '(wltcurusr,wltjob,wltjobnbr,wltwhse,wltlcns) '
                     +  'SELECT '
                     +  sq + %trim(#curruser) + sq + ','
                     +  sq + %trim(#job) + sq + ','
                     +  sq + %trim(#jobnbr) + sq + ','
                     +  'lnwhse,lnlcns '
                     +  'FROM licinfo as a '
                     +  'WHERE '
640eD                //+  'lncode=' + sq + '*PO' + sq + ' '
640eD                //+  'and lnvalue=' + sq + %trim(w1po) + sq;
640eM                +  'lnpo =' + sq + %trim(w1po) + sq;

             if w1whse > 0;
               sqlStmt = %trimr(sqlStmt) + ' '
                       +  'and lnwhse=' + %trim(%editc(w1whse:'Z'));
             endif;

             if w1item <> '*ALL';
               sqlStmt = %trimr(sqlStmt) + ' '
                       + 'and exists(select lnlcns '
                       + 'from licinfo as b '
                       + 'where b.lnwhse=a.lnwhse '
                       +   'and b.lnlcns=a.lnlcns '
640eD                  //+   'and b.lncode=' + sq + '*ITEM' + sq + ' '
640eD                  //+   'and b.lnvalue=' + sq + %trim(w1item) + sq
640eM                  +   'and b.lnitem =' + sq + %trim(w1item) + sq
                       + ')';
             endif;

640dA    endsl;
         exec sql EXECUTE IMMEDIATE :sqlStmt;

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlGetORDH   -  Get Order Header record
     *----------------------------------------------------------------

      /free
       begsr sqlGetORDH;

         //Added customer number to SELECT statement
         exec sql SELECT ohcord, ohcnam, ohcust, ohmisc
                  INTO :ohcord, :ohcnam, :ohcust, :ohmisc
                  FROM  ordh
                  WHERE ohwhse = :#fwhse and ohord = :#ford;

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

         exsr sqlInzWrkFile;
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

640dA    select;
640dA      when w1cord > 0;
640dA        dou rrn1 = subfilepage;
640dA        // Get the next row from the SQL cursor.
640dA
640dA        exec sql FETCH NEXT FROM mycsr INTO :fetchds;
640dA
640dA        If sqlstt = sqlSuccess;
640dA          exsr sflFill1;
640dA          if w1cord > 0 and foundCustOrd = *on or
640dA             w1cord = 0;
640dA            rrn1 = rrn1  + 1;
640dA            if first;
640dA              first = *off;
640dA              recpos = rrn1;
640dA            endif;
640dA            option = ' ';
640dA            write sfl1;
640dA            write sfl2;
640dA            write sfl5;
640dA            write sfl6;
640dA            endif;
640dA          else;
640dA            leave;
640dA          endif;
640da
640dA        enddo;
640dA      other;
             for i = 1 to subfilePage;

               // Get the next row from the SQL cursor.

               exec sql FETCH NEXT FROM mycsr INTO :fetchds;

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
640dA            write sfl5;
640dA            write sfl6;
               else;
                 leave;
               endif;

             endfor;
640dA    endsl;

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
640dA    write sf5ctl;
640dA    write sf6ctl;
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

         h1whse = #fwhse;
         h1lcns = #flcns;
         h1olcns = #folcns;
         h1item = #fitem;
         h1whdp = #fwhdp;
         h1disp = #fdisp;
610aA    h1adduc = #fadduc;
610aA    h1ord   = #ford;
640eD    //h1po    = %Subst(#flnvalue:1:9);
640eM    h1po    = #flnpo;
640dA    h1expdt = #fexpdt;

         // Format quantity string

         if #ford <> 0;
           cqqty1 = -(#fqty1);
           cqqty2 = -(#fqty2);
           cqqty3 = -(#fqty3);
         else;
           cqqty1 = #fqty1;
           cqqty2 = #fqty2;
           cqqty3 = #fqty3;
         endif;
         cvtqty('*QTY2STR': #pgm:
                cqqty1: cqqty2: cqqty3:
                cqum1: cqum2: cqum3:
                w1rqty: cqustr: cqrtn: cqerm);
         evalr w1rqty = %trimr(w1rqty);

         select;
           when #ford <> 0;
             exsr sqlGetORDH;
             //w1loc = 'Ord# '
640aA    If sqlstt = sqlSuccess;
             w1loc = '#'
                   + %trim(%editc(ohcord:'Z'))
                   + ' - '
                   + %trim(ohcnam);
640bA        #fcust# = ohcust;
640bA        #fcustn = ohcnam;
640bA        #fcord = ohcord;

650bA        monitor;
650bA          h1sdte = %dec(%subst(ohmisc:1:6):6:0);
650bA        on-error;
650bA          h1sdte = 0;
650bA        endmon;
650bA        test(de) *MDY h1sdte;
650bA        if %error;
650bA          h1sdte = 0;
650bA        endif;

640dA        // customer order selection, set flag to control load
640dA        if #fcord = w1cord and w1cord > 0;
640dA          foundCustOrd = *on;
640dA        else;
640dA          foundCustOrd = *off;
640dA        endif;
640aA      else;
640aA        w1loc = 'order not found';
640aA    endif;
           other;
             //w1loc = 'Slot '
             w1loc = %trim(#fwhdp) + '/'
                   + %trim(#fdisp);
             if #fdisp = ' ';
             w1loc = 'Adj  ';
             endif;
         endsl;

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
640dA        when curview = 3;
640dA          readc sfl5;
640dA        when curview = 4;
640dA          readc sfl6;
             other;
               readc sfl1;
           endsl;
           if %eof;
             leave;
           endif;

           select;

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

             when %trim(option) = '75';
               optiontaken = 'LcnsInfo';
               recpos = rrn1;

           endsl;

           option = ' ';
           select;
             when curview = 2;
               update sfl2;
640dA        when curview = 3;
640dA          update sfl5;
640dA        when curview = 4;
640dA          update sfl6;
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

         scrname = 'LT330.01';
         w1sort = 'A';
         w1oby = '1';
         exsr inzcriteria1;

         exsr setcriteria1;

610aA    scopt1 = '5=View  ';
610aM    scopt2 = '71=Lcns hist  '
                + '72=Item hist  '
                + '73=Slot hist  '
                + '74=OLcns hist  '
                + '75=Lcnse Info  ';

610cA    // If no parms are passed in, display F9 window.
610cA
610cA    if noParmsPassed;
610cA      exsr getcriteria1;
610cA      if cfkey <> Enter;
610cA        leavesr;
610cA      endif;
610cA    endif;

         // Do initial build and display of subfile

         exsr sflBldDisp;

         // Process subfile until user wants to leave

         dou (cfkey = F3);

           Write fkey1;
640bA      Write mkey1;
           if recpos > 0 and recpos <= lastrrn;
             rrn1 = recpos;
           else;
             rrn1 = 1;
           endif;
           select;
             when curview = 2;
               exfmt sf2ctl;
640dA        when curview = 3;
640dA          exfmt sf5ctl;
640dA        when curview = 4;
640dA          exfmt sf6ctl;
             other;
               exfmt sf1ctl;
           endsl;

600aA      recpos = csrrrn;

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;

               select;

                  when optiontaken = 'View';
610aA               if h1ord <> 0;
610aA                 ll830('*VIEW': $pwhse: h1lcns: h1adduc);
610aA               else;
610aA                 la830('*VIEW': $pwhse: h1lcns);
610aA               endif;

                  when optiontaken = 'LcnsLog';
                    lt320('*VIEW': $pwhse: ' ': ' ': ' ':
                          h1lcns: 0: ' ': ' ');

                  when optiontaken = 'ItemLog';
                    lt320('*VIEW': $pwhse: ' ': ' ': h1item:
                          ' ': 0: ' ': ' ');

                  when optiontaken = 'SlotLog';
                    lt320('*VIEW': $pwhse: h1whdp: h1disp: ' ':
                          ' ': 0: ' ': ' ');

                  when optiontaken = 'OLcnsLog';
                    lt320('*VIEW': $pwhse: ' ': ' ': ' ':
                          h1olcns: 0: ' ': ' ');

                  when optiontaken = 'LcnsInfo';
                    lp130('*NOOPT': h1lcns);

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

             // F21 = Print

             when cfkey = F21;
               exsr printlist;
640bA        w1msg1 = 'Report has been printed';
640bA        *in55 = *on;

640bA       // F22 = File

640bA       when cfkey = F22;
640bA         exsr fileit;
640bA        w1msg1 = 'File LT331 was created and ready for export';
640bA        *in55 = *on;

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
     *                File Processing Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
640bA*  fileit - Create work file
     *----------------------------------------------------------------

      /free
       begsr fileit;

         exsr inzcriteria1;
         exsr setcriteria1;
         exsr sqlInzWrkFile;

         // Clean up LT331 work file
         exec sql DELETE FROM LT331;
         sqlstt = sqlstt;

         exsr sqlclean;
         exsr sqlbldstmt1;
         exsr sqlprep;

         // Process the records in the SQL cursor until the return not = 0

         dou 1 <> 1;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr INTO :fetchds;

           If sqlstt = sqlSuccess;
             exsr sflFill1;
640dA        if w1cord > 0 and foundCustOrd = *on or
640dA           w1cord = 0;
640bA          #fcust# = ohcust;
640bA          #fcustn = ohcnam;
640bA          #fcord = ohcord;
               write porrec;
640dA        endif;
640aA      else;
640aA        leave;
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                Print Processing Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
600BA*  printit - Print list
     *----------------------------------------------------------------

      /free
       begsr printit;

         w1sort = 'A';
         w1oby = '1';

         wpdev = $pdev;
         wpform = $pform;

         exsr inzcriteria1;
         exsr setcriteria1;
         exsr sqlInzWrkFile;

         exsr printlist;

       endsr;
      /end-free

     *----------------------------------------------------------------
600BA*  printlist - Print list
     *----------------------------------------------------------------

      /free
       begsr printlist;

         exsr sqlclean;
         exsr sqlbldstmt1;
         exsr sqlprep;
         exsr setupPrint;

         exsr prtRprt;

       endsr;

      /end-free

     *----------------------------------------------------------------
600BA*  printhead - Print heading line
     *----------------------------------------------------------------

      /free

       begsr printhead;

        // Print report heading
         write head1;

         // Print Column Headings
         write columns1;

         *in90 = *off;
         *in91 = *on;

       endsr;

      /end-free

     *----------------------------------------------------------------
600BA*  printDetl - Print detail line
     *----------------------------------------------------------------

      /free

       begsr printDetl;

         // See if heading needs to be printed.

         if *in90;
           exsr printhead;
         endif;

        // Print detail line

         write detail1;
         printflag = *on;

700aA  //ordqty = %dec(w1rqty:10:0);
700aD    //if ordqty < 0;
700aD      //ordqty = ordqty * -1;
700aD    //endif;
700aA    if cqqty1 < 0;
700aA      cqqty1 = cqqty1 * -1;
700aA    endif;
700aA    if cqqty2 < 0;
700aA      cqqty2 = cqqty2 * -1;
700aA    endif;
700aA    if cqqty3 < 0;
700aA      cqqty3 = cqqty3 * -1;
700aA    endif;
700aA    wkiqty1 = wkiqty1 + cqqty1;
700aA    wkiqty2 = wkiqty2 + cqqty2;
700aA    wkiqty3 = wkiqty3 + cqqty3;
700aA    cvtqty('*QTY2STR': #pgm:
700aA           wkiqty1: wkiqty2: wkiqty3:
700aA           cqum1: cqum2: cqum3:
700aA           wkrqty: cqustr: cqrtn: cqerm);
700aA    evalr wkrqty = %trimr(wkrqty);

700aD  //wkiqty = wkiqty + ordqty;
650bA    wkicnt = wkicnt + 1;
         wkCount = wkCount + 1;

       endsr;

      /end-free

     *----------------------------------------------------------------
600BA*  prtRprt -  Print the Report
     *----------------------------------------------------------------

      /free

       begsr prtRprt;

         // Open printer file.

         open(e)   lt330pr;
         if %error;
         endif;

         // Process the records in the SQL cursor until the return not = 0

640aA      // dou sqlstt <> sqlSuccess;
640aA    dou 1 <> 1;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr INTO :fetchds;

           If sqlstt = sqlSuccess;
             exsr sflFill1;

640dA        if w1cord > 0 and foundCustOrd = *on or
640dA           w1cord = 0;
               if first;
                 exsr printhead;
                 first = *off;
650bA            lastitem = #fitem;
                 exsr printdetl;
                 else;
650bA            if lastitem <> #fitem;
650bA              lastitem = #fitem;
650bA              exsr printTotItm;
650bA            endif;
                 exsr printdetl;
               endif;
640dA        endif;
640aA      else;
640aA        leave;
           endif;

         enddo;

         if sqlstt = sqlNoMoreData;
         endif;

          if        not printflag;
            exsr      printhead;
            else;
650bA       exsr      printTotItm;
            write total1;
          endif;

         // Close printer file.

         close(e)   lt330pr;
         if %error;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
650bA*  printTotItm - Print total item line
     *----------------------------------------------------------------

      /free

       begsr printTotItm;

         // See if heading needs to be printed.

         if *in90;
           exsr printhead;
         endif;

        // Print total item line

         write totitm;
700aD    //wkiqty = 0;
700aA    wkiqty1 = 0;
700aA    wkiqty2 = 0;
700aA    wkiqty3 = 0;
         wkicnt = 0;

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

         if $ppo = ' ';
           w1po = '*NotSent*';
         else;
           w1po = $ppo;
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

         if w1sort <> 'A' and w1sort <> 'D';
           w1sort = 'A';
         endif;

         //if w1oby <> '1' and w1oby <> '2';
         if w1oby <> '1';
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

         //if w1oby = '2';
         //  schead = %trimr(schead) + append1
         //         + 'By FIFO';
         //  append1 = ',';
         //else;
           schead = %trimr(schead) + append1
                  + 'By Item/Slots/Orders';
           append1 = ',';
         //endif;

         if w1po <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'PO=' + %trim(w1po);
           append1 = ',';
         endif;

         if w1item <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Item=' + %trim(w1item);
           append1 = ',';
         endif;

         if append1 = ' ';
           schead = %trimr(schead) + ',Everything';
         endif;

         exsr centerschead;

       endsr;
      /end-free
     *----------------------------------------------------------------
600BA*  setupPrint - Setup Report
     *----------------------------------------------------------------

      /free
       begsr setupPrint;

         // Load device and form if not loaded.

         if wpdev = ' ';
           wpdev = '*JOB';
         endif;

         if wpform = ' ';
           wpform = '*STD';
         endif;

         //  Display window to get device and form to use (Only in *DISPLAY mode

640dD    //if $pcmd = '*DISPLAY';
640dM    if $pcmd = '*DISPLAY' or
640dA       $pcmd = '*DISPITM';
           exfmt windowp;
         endif;

         if cfkey <> F3 and cfkey <> F12;

           // Override printer file.

           if wpdev = ' ';
             wpdev = '*JOB';
           endif;

           if wpform = ' ';
             wpform = '*STD';
           endif;

           qcmd = 'OVRPRTF '
                + 'FILE(LT330PR) '
                + 'OUTQ(*DEV) '
                + 'DEV(' + %trim(wpdev) + ') '
                + 'FORMTYPE(' + %trim(wpform) + ') ';

      /end-free
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
      /free

         endif;

         first = *on;
         wkCount = 0;
         printflag = *off;

       endsr;

      /end-free
