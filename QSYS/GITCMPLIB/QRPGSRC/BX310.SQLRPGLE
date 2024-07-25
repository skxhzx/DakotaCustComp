      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
      *****************************************************************
      **************************************************    3/29/16 ***
      ****   work in progress to chg this LT310 to BX310    NANCY   ***
      *****************************************************************
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
     *  BX310     View AMPBOX file
     *  30 March 2016
     *  Nancy Koelz
     *
     *  Revisions
     *
700 A*    03/30/16  NLK  7.00
     *      - Created.
     *
     *
700aA*    05/02/16  NLK  7.00a
     *      - ENH: GLP asked for different fields in the subfiles
     *
700bA*    05/09/16  NLK  7.00b
     *      - ENH: Initial Screen; rmv Box ID add Cust Order #
     *
700cA*    06/14/16  NLK  7.00c
     *      - ENH: Increase BOX# from 3.0 to 5.0-w1box# + #bbox
     *
700dA*    07/20/16  NLK  7.00d
     *      - ENH: Add BX300 to see where AMP reduction needed
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fampxref12 if   e           k disk
     Fampxref10 if   e           k disk
     F                                     rename(axrec:axrec10)
700dAForddm     if   e           k disk
     Fordh      if   e           k disk
     Frtehed    if   e           k disk
     Fpirtran8  if   e           k disk
     Fbx310fm   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl6:rrn1)
     F                                     infds(info)
     F                                     sfile(msgrec:msgk)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.cvtqty
      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.putmsg
      /copy qcopysrc,p.chklist

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D bx311           pr                  extpgm('BX311')
      * Input
     D   pcmd                         8    const
     D   pwhse                        3  0 const
     D   pdt                          8  0 const
     D   pTrLO                        7  0 const
     D   pTrHI                        7  0 const

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP

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
     D fetchds1        ds
     D   #bwhse                            like(abxwhse)
     D   #bboxid                           like(abxboxid)
     D   #bbox                             like(abxbox#)
     D   #bcdgt                            like(abxchkdgt)
     D   #btrn                             like(abxatrn#)
     D   #bcust                            like(abxacust)
     D   #bemp                             like(abxaemp#)
     D fetchds         ds
     D   #fwhse                            like(axwhse)
     D   #fcord                            like(axcord)
     D   #fitem                            like(axitem)
     D   #fartid                           like(axartid)
     D   #fboxid                           like(axaboxid)
     D   #fdrtid                           like(axdrtid)
     D ampbox        e ds
     D ampxref       e ds
     D label         e ds
     D piritem       e ds
     D   #fdesc                            like(itdesc)

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

700aDD*sqlfields       c                   '*'
700aAD sqlfields       c                   'abxwhse,abxboxid,+
     D                                      abxbox#,abxchkdgt,+
     D                                      abxatrn#,abxacust,+
     D                                      abxaemp#,ohcnam,ohcord'
     D sqlfield6       c                   'axwhse,axcord,axitem,+
     D                                      axartid,+
     D                                      axaboxid,axdrtid,+
     D                                      itdesc,lbqalc,lbqpck'
     D sqlfile         c                   'AMPBOX'
700aAD sqlfileb        c                   'ORDH'
700aAD sqlfilec        c                   'LABEL'
     D sqlfile6a       c                   'AMPXREF'
     D sqlfile6b       c                   'PIRITEM'
700aAD sqljoinfld      c                   's.abxwhse=t.ohwhse +
     D                                      and +
     D                                      u.lbord=t.ohord'
700aAD sqljoinfld2     c                   's.abxwhse=u.lbwhse +
     D                                      and +
     D                                      s.abxalbl#=u.lblbl#'
     D sqljoinflds     c                   'a.axwhse=b.itwhse +
     D                                      and +
     D                                      a.axitem=b.ititem'
700aAD sqljoinflds2    c                   'a.axwhse=c.lbwhse +
     D                                      and +
     D                                      a.axalbl#=c.lblbl#'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /COPY QCOPYSRC,ID#GLP
      /COPY QCOPYSRC,ORDDM1_AMP
      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

     D $icmd           s              8
     D $iwhse          s              3  0
     D $idt            s              8  0
700cMD $ibox#          s              5  0
     D $icord          s              7  0
     D $itran          s              7  0
     D $icust          s             11  0
     D $idev           s             10
     D $iform          s             10
700dAD w2dt            s              8  0
700dAD w1time          s              6  0 inz(050000)
700d  *inz 5 a.m. which is actual cutoff for day to day activity

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $pdt            s                   like($idt)
     D $pbox#          s                   like($ibox#)
     D $pcord          s                   like($icord)
     D $ptran          s                   like($itran)
     D $pcust          s                   like($icust)
     D $pdev           s                   like($idev)
     D $pform          s                   like($iform)

     D #whse           s              3  0
     D #emp#           s              5  0
     D #BeltPrt        s              1
     D #Language       s              2

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D BoxidLO         s              7  0
     D BoxidHI         s              7  0
     D append1         s              1
     D append5         s              5
     D appendo         s              7
     D dartid          s                   like(axartid)
     D ddrtid          s                   like(axdrtid)
     D arte            s                   like(rhrte)
     D drte            s                   like(rhrte)
     D first           s               n
     D firstx          s               n
     D groupby         S            100a   inz(' ')
     D groupfields     S            100a   inz(' ')
     D lastrrn         s                   like(rrn1)
     D nodelvrt        s               n
     D noboxid         s               n
     D noParmsPassed   s               n
     D optiontaken     s             10    inz(' ')
     D orderby         S            100a   inz(' ')
     D orderfield      s             10    inz(' ')
     D orderposition   s              3  0 inz(0)
     D recpos          s                   like(rrn1)
     D today           s              8  0
700dAD ordLO           s              7  0
700dAD ordHI           s              7  0
     D tranLO          s              7  0
     D tranHI          s              7  0
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
     D  h1bxid                 1      7  0
     D  h1cust                 8     18  0
     D  h1dummy              100    100
     D sf6hide         ds
     D  h6bxid                 1      7  0
     D  h6dummy              100    100

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
     *      $icmd    - *AMPINFO
     *                 *REPRINT
     *      $iwhse   - Warehouse
     *      $idt     - date
     *      $ibox#   - box #
     *      $icord   - Cust Ord#
     *      $itran   - tran
     *      $icust   - cust
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
     C                   parm                    $idt
     C                   parm                    $ibox#
     C                   parm                    $icord
     C                   parm                    $itran
     C                   parm                    $icust

      /free


         //    exsr dspscr;

         noParmsPassed = *off;

      /end-free

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         // Process main screen.

         select;
           when $pcmd = '*REPRINT';
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
     *  sqlbldstmt1 - Build SQL statment (AMPBOX)
     *----------------------------------------------------------------

      /free
       begsr sqlbldstmt1;

         // Create "From" clause.

         sqlfrom = 'FROM ' + sqlfile + ' s ';

         // Create "where" clause.

         sqlwhere = ' ';
         schead = ' ';
         appendo  = ' ';

         // JOIN

700aA    sqljoin2 = 'INNER JOIN ' + sqlfilec + ' u ' + 'on ';
            sqljoin2 = %trimr(sqljoin2) + ' ' + sqljoinfld2;

         sqljoin = 'INNER JOIN ' + sqlfileb + ' t ' + 'on ';
            sqljoin = %trimr(sqljoin) + ' ' + sqljoinfld;


         // Warehouse

         append5  = 'WHERE';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'abxwhse=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';

         // Box#

         if w1box# <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'abxbox#='
                    + sq + %trim(w1box#) + sq;
           append5 = ' and ';
         endif;

         // Customer Order Number

         if w1cord <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'ohcord='
                    + sq + %trim(w1cord) + sq;
           append5 = ' and ';
         endif;

         // DATE - Allows User to pull one date at a time (w1dt)
         // using abxaddts didn't pull the BOX#s created after midnight

         // Using TranLo/TranHI allows us to use this as a date and
         // grab all current records created by the requested date
         // sort by just BOX# now that we have the complete date rcds

         if w1dt > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'abxatrn#>='
                    + sq + %trim(%editc(tranLO:'P')) + sq;
           append5 = ' and ';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'abxatrn#<='
                    + sq + %trim(%editc(tranHI:'P')) + sq;
           append5 = ' and ';

           schead = 'Selected Date Boxes';
           sqlorder = 'ORDER BY abxboxid';
         else;

         // if date 0 show entire file DESCEND by boxid(most recent)
           schead = 'Most Recent Box first';
           sqlorder = 'ORDER BY abxboxid DESC';
         endif;

         // Tran#

         if w1tran <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'abxatrn#='
                    + sq + %trim(w1tran) + sq;
           append5 = ' and ';
         endif;

         // Cust#

         if w1cust <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'abxacust='
                    + sq + %trim(w1cust) + sq;
           append5 = ' and ';
         endif;


         // Create "Order By" clauses.
         // see Date which order to use

         //    sqlorder = 'ORDER BY abxboxid';


         // Create SQL statement.

         SqlStmt = 'SELECT '
                 + %trimr(sqlfields) + ' '
                 + %trimr(sqlfrom) + ' '
700aA            + %trimr(sqljoin2) + ' '
                 + %trimr(sqljoin) + ' '
                 + %trimr(sqlwhere) + ' '
                 + sqlorder;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlbldstmt6 - Build SQL statment (AMPxRef)
     *----------------------------------------------------------------

      /free
       begsr sqlbldstmt6;

         // Create "From" clause.

         sqlfrom = 'FROM ' + sqlfile6a + ' a ';

         sqlwhere = ' ';
         schead = ' ';
         appendo  = ' ';

         // JOIN

         sqljoin = 'INNER JOIN ' + sqlfile6b + ' b ' + 'on ';
            sqljoin = %trimr(sqljoin) + ' ' + sqljoinflds;

700aA    sqljoin2 = 'INNER JOIN ' + sqlfilec + ' c ' + 'on ';
            sqljoin2 = %trimr(sqljoin2) + ' ' + sqljoinflds2;

         // Create "where" clause.

         // Warehouse

           append5 = 'WHERE';
           sqlwhere = %trimr(sqlwhere) + append5
                    + ' axwhse=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';

         // Box ID

           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'axaboxid='
                    + %trim(%editc(h1bxid:'P'));
         //         + %trim(%editc(#bboxid:'P'));
         //         + %trim(%editc(abxboxid:'P'));

         // Create "Order By" clauses.

               sqlorder = 'ORDER BY axitem';


         // Create SQL statement.

         SqlStmt = 'SELECT '
                 + %trimr(sqlfield6) + ' '
                 + %trimr(sqlfrom) + ' '
                 + %trimr(sqljoin) + ' '
700aA            + %trimr(sqljoin2) + ' '
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

         // Declare the leavesror to hold the data retrieved from the SELECT

         exec sql DECLARE MYCSR SCROLL CURSOR FOR SEL;

         sqlstt = sqlstt;

         // Open the SQL cursor.

         exec sql OPEN MYCSR;

         sqlstt = sqlstt;

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
       begsr sqlprep6;

         // Prepare the SQL statement for validation, since the program was
         // compiled with DLYPRP (*YES), it will wait until it is used before
         // it prepares th cursor.

         exec sql PREPARE sel6 FROM :SqlStmt;

         sqlstt = sqlstt;

         // Declare the leavesror to hold the data retrieved from the SELECT

         exec sql DECLARE MYCSR6 SCROLL CURSOR FOR SEL6;

         sqlstt = sqlstt;

         // Open the SQL cursor.

         exec sql OPEN MYCSR6;

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
     *  sqlclean - Clean up before exiting
     *----------------------------------------------------------------

      /free
       begsr sqlclean6;

         // Close the SQL cursor after all processing is complete.

         exec sql CLOSE mycsr6;

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                    Subfile Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sflBldDisp   Build and display subfile (date's boxes)
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
     *  sflBldDisp6  Build and display subfile (Box Items)
     *----------------------------------------------------------------

      /free
       begsr sflBldDisp6;

         exsr sqlclean6;
         exsr sqlbldstmt6;
         exsr sqlprep6;
         exsr sflclr6;
         exsr sflbld6;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflbld1 - Build the subfile  AMPBOX
     *----------------------------------------------------------------

      /free
       begsr sflbld1;

         rrn1 = Lastrrn;
         recpos = lastrrn;
         first = *on;
         firstx = *on;

         // Process the records in the SQL cursor until the return not = 0

         for i = 1 to subfilePage;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr INTO
                               :fetchds1, :ohcnam, :ohcord;

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
     *  sflbld6 - Build the subfile (AMPXREF)
     *----------------------------------------------------------------

      /free
       begsr sflbld6;

         rrn1 = Lastrrn;
         recpos = lastrrn;
         first = *on;

         // Process the records in the SQL cursor until the return not = 0

         for i = 1 to subfilePage;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr6 INTO
                          :fetchds, :itdesc, :lbqalc, :lbqpck;

           If sqlstt = sqlSuccess;
             exsr sflFill6;
             rrn1 = rrn1  + 1;
             if first;
               first = *off;
               recpos = rrn1;
             endif;
         //  option = ' ';
             write sfl6;
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
         scrname = 'BX310.02';

         *in31 = *on;
         write sf1ctl;
         *in31 = *off;
         *in32 = *off;
         eval i = i+1;
         rrn1 = 0;
         lastrrn = 0;
         recpos = 0;
         *in90 = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflclr - Clear subfile  AMPXREF
     *----------------------------------------------------------------

      /free
       begsr sflclr6;

         // Clear the subfile
         scrname = 'BX310.04';

         *in31 = *on;
         write sf6ctl;
         *in31 = *off;
         *in32 = *off;
         eval i = i+1;
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

            h1bxid = #bboxid;
            h1cust = #bcust;

         // If I use LO HI here, I may NOT be getting whole day
         // if they entered criteria fields-is that OK?

             if firstx;
               firstx = *off;
               BoxidLO = #bboxid;
             else;
               BoxidHI = #bboxid;
             endif;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill6  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill6;

         // Store hidden fields that aren't displayed on screen.

            dartid = #fartid;
            ddrtid = #fdrtid;

            exsr rtename;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  rtename  -  grab route names
     *----------------------------------------------------------------

      /free
       begsr rtename;

         // Store route names to display

700aA    setll (w1whse: dartid) rtehed;
         reade (w1whse: dartid) rtehed;

           if not %eof(rtehed);
             arte = rhrte;
           endif;

700aA    setll (w1whse: ddrtid) rtehed;
         reade (w1whse: ddrtid) rtehed;

           if not %eof(rtehed);
             drte = rhrte;
           endif;

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

           readc sfl1;

           if %eof;
            leave;
           endif;

           select;

             when %trim(option) = '5';
               optiontaken = 'View';
               recpos = rrn1;

             when %trim(option) = '6';
               optiontaken = 'Items';
               recpos = rrn1;

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
     *  Prompt Screen - dspsrc
     *----------------------------------------------------------------

      /free
       begsr dspscr;

         // Initialize screen fields

         scrname = 'BX310.02';

               exfmt sf1ctl;
           w1msg1 = '   ';
           *in55 = *off;

             // F12 = Cancel or F3 leave or display box#s
         if cfkey = F3 or cfkey = F12;
           leavesr;
         endif;

               exsr sflBldDisp;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  screen1 - Process screen 1  (sfl - boxes for the day)
     *----------------------------------------------------------------

      /free
       begsr screen1;

         // Initialize screen fields

         exsr inzcriteria1;

         //scopt1 = '5=View  6=RePrint';
         scopt1 = '5=View  6=Items In Box ';


         // If no parms are passed in, display F9 window.

         // if noParmsPassed;
           exsr getcriteria1;
           if cfkey = F3 or cfkey = F12;
             leavesr;
           endif;
         // endif;

         // Do initial build and display of subfile

         exsr sflBldDisp;

         // Process subfile until user wants to leave

         dou (cfkey = F3);
         scrname = 'BX310.02';

           Write fkey1;
           Write mkey1;
           if recpos > 0 and recpos <= lastrrn;
             rrn1 = recpos;
           else;
             rrn1 = 1;
           endif;
               exfmt sf1ctl;
           w1msg1 = '   ';
           *in55 = *off;

           recpos = csrrrn;

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;

               select;
                  when optiontaken = 'View';
                  exsr srampxref;
             // return back here and refresh the subfile to continue
                  exsr sflBldDisp;
                  cfkey = Enter;

                  when optiontaken = 'Items';
                  exsr screen6;
             // return back here and refresh the subfile to continue
                  exsr sflBldDisp;
                  cfkey = Enter;

               endsl;

             // F5 = Refresh

             when cfkey = F5;
               exsr sflBldDisp;
               cfkey = Enter;

             // F8 = List all AMPxRef items w/ no AMP Box ID

             when cfkey = F8;
               exsr getnoBox;
               if cfkey = Enter;
                 exsr sflBldDisp;
               endif;
               cfkey = Enter;

             // F9 = List all AMPxRef items w/ no Delv Rt

             When cfkey = F9;
               exsr getnoDelv;
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
     *  screen6 - Process screen opt 6  (sfl - box items)
     *----------------------------------------------------------------

      /free
       begsr screen6;

         // Initialize screen fields


         // Do initial build and display of subfile

         exsr sflBldDisp6;

         // Process subfile until user wants to leave

         dou (cfkey = F3 or cfkey = F12);
         scrname = 'BX310.04';

           Write fkey6;
           Write mkey1;
           if recpos > 0 and recpos <= lastrrn;
             rrn1 = recpos;
           else;
             rrn1 = 1;
           endif;
               exfmt sf6ctl;
           w1msg1 = '   ';
           *in55 = *off;

           recpos = csrrrn;

           Select;

             // PageDown = More records

             When cfkey = PageDown;
               exsr sflbld6;

           EndSl;

         EndDo;

         option = ' ';
         ExSr sqlclean;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Info Screen - srampxref
     *----------------------------------------------------------------

      /free
       begsr srampxref;

         // Get info

700b     setll (w1whse: h1bxid) ampxref12;
700b     reade (w1whse: h1bxid) ampxref12;

           if %eof(ampxref12);
             leavesr;
           endif;

         setll (axWhse: axaord) ordh;
         reade (axWhse: axaord) ordh;

         dartid = axartid;
         ddrtid = axdrtid;
         exsr rtename;

               exfmt screen2;
           w1msg1 = '   ';
           *in55 = *off;

             // F12 = Cancel or F3 leave
             // return back here and refresh the subfile to continue
         if cfkey = F3 or cfkey = F12;
           option = ' ';
           leavesr;
         endif;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  Display ALL BoxID zero (voiced Skip Box)
     *--(F8)----------------------------------------------------------
     *  remember tranLo/tranHI is the range for date selected
     *  1st-are there AMP records in this date selected
     *  2nd-do any rcds have boxid zero
     *  3rd-dsp Error-All Items in a Box -or- show the items listed
     *----------------------------------------------------------------

      /free
       begsr getnoBox;

         // read ampxref for ALL BoxID 0 for Date.

         // Get tran# range of selected date (Fill1)
         // May have to reread ampbox IF Fill1 doesn't

         noBoxID = *off;
         setll (w1Whse: tranLO) ampxref10;
         reade (w1Whse) ampxref10;
         dou axatrn# >= tranHI;
           if not %eof(ampxref10) and axaboxid = 0;
             noBoxID = *on;
             leave;
           else;
             if %eof(ampxref10);
             leave;
             endif;
           endif;
         reade (w1Whse) ampxref10;
         enddo;

         if noBoxID = *off;
           w1msg1 = 'All Items placed in a BOX';
           *in55 = *on;
         else;
           $pcmd = '*NoBoxID';
           BX311($pcmd : w1whse : w1dt : TranLO : TranHI);
         endif;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  Display ALL Delv Rt zero (on AMP order; cancelled before Delv)
     *--(F9)----------------------------------------------------------
     *  remember tranLo/tranHI is the range for date selected
     *  1st-are there AMP records in this date selected
     *  2nd-do any rcds have NO Delv Rt (cancelled AMP order picked)
     *  3rd-dsp Error-All Items Assigned -or- show the items listed
     *----------------------------------------------------------------

      /free
       begsr getnoDelv;
         // read ampxref for ALL DelvRt 0 for DATE.

         // Get tran# range of selected date (Fill1)
         // May have to reread ampbox IF Fill1 doesn't

         noDelvRt = *off;
         setll (w1Whse: tranLO) ampxref10;
         reade (w1Whse) ampxref10;
         dou axatrn# >= tranHI;
           if not %eof(ampxref10) and axdrtid = *blanks;
             noDelvRt = *on;
             leave;
           else;
             if %eof(ampxref10);
             leave;
             endif;
           endif;
         reade (w1Whse) ampxref10;
         enddo;

         if noDelvRt = *off;
           w1msg1 = 'All Items assigned to DelvRt';
           *in55 = *on;
         else;
           $pcmd = '*NoDelRt';
           BX311($pcmd : w1whse : w1dt : TranLO : TranHI);
         endif;
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

     *  getcriteria1 - Prompt user for select and sort criteria
     *----------------------------------------------------------------

      /free
       begsr getcriteria1;

         // Display window with 'parm' values or *ALL (inzcriteria1)

         exfmt window1;
           w1msg1 = '   ';
           *in55 = *off;

         // This is some weird code due to weird scenerous
         //   and trying to figure out when the user wants this info.
         // I'm not happy with this code but lets see how it runs.
         //
         // Due to ORDDM not having a datestamp makes me have to
         //   figure out what ord#s match the selected date.
700dA    // Figure out SelectDate using Tran#s range and/or Ord#s range

         // To Allow Date as an extracting field, we need to use a
         // generate date since ADD timestamps may go into the next day
         // Use Tran# range for Date to know which AMPBOX rcds to grab
700dA    // Added 'time' to get a true tran# range for day's activity

        setll (w1Whse: w1dt: w1time) pirtran8;
        reade (w1Whse: w1dt) pirtran8;
          if not %eof(pirtran8);
           tranLO = pttrn#;
           setgt (w1Whse: w1dt) pirtran8;
700dA      reade (w1Whse) pirtran8;
             if not %eof(pirtran8);
700dA          w2dt = ptgdte;
               else;
700dA    // Tran#s didn't go into next day so grab last one of w1dt
700dA          w1time = 235959;
700dA          w2dt = w1dt;
             endif;
700dA    // w2dt is continuation into next day
700dA      setll (w1Whse: w2dt: w1time) pirtran8;
           readpe (w1Whse) pirtran8;
           tranHI = pttrn#;

700dA    // Get Ord# to see if ORDDM 'R' to reduce AMP qty

700dA    // Use AMPxRef by tran# looking at AMP Ord ID
700dA      setll (w1whse: tranLO) ampxref10;
700dA      reade (w1whse) ampxref10;
             if not %eof(ampxref10);
700dA          ordLO = axaord;
             endif;

700dA    // Use AMPxRef by tran# looking at Delv Ord ID
700dA      setll (w1whse: tranHI) ampxref10;
700dA      reade (w1whse) ampxref10;
             if not %eof(ampxref10);
700dA          ordHI = axdord;
               else;
700dA      setll (w1whse: tranHI) ampxref10;
700dA      readpe (w1whse) ampxref10;
               if axdord <> 0;
700dA           ordHI = axdord;
                else;
700dA           ordHI = 99999;
               endif;
             endif;
700dA    // 99999 may happen if an AMP was cancelled(odd)

700dA    // do loop -or- lf Incl only 'R's -or- sort ommsc1
700dA    // keep in mind 'R's may only be Greenleaf(today 1287 reads)
700dA       setll (w1whse: ordLO) orddm;
700dA       dow  forever = forever;
700dA         reade (w1whse) orddm;
              if not %eof(orddm);
              orddm1_amp = ommsc1;
                if ampdm4_ampfl = 'R';
                  *in56 = *on;

      /end-free
700dA    // Since Delv Rt has reduce AMP qty, print report
700dA    // Remove report here, allow it when alloc of route
700bAC*                  call      'BX300'
700bAC*                  parm                    w1whse            3 0
700bAC*                  parm                    ordLO             7 0
700bAC*                  parm                    ordHI             7 0
      /free

700bA
                  leave;
                endif;
                if ordHI < omord;
                  leave;
                endif;
              endif;
              if %eof;
                leave;
              endif;
700dA       enddo;

          endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  inzcriteria1 - Initialize criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr inzcriteria1;

         // Retrieve today's date into century format

         $cvcmd = '*CURCMD ';
         cvtdte ($cvtdt);
         today = $cvd8o;

         if $pdt = 0;
           w1dt = today;
         else;
           w1dt = $pdt;
         endif;

         if $pwhse = 0;
           w1whse = 1;
         else;
           w1whse = $pwhse;
         endif;

         if $pbox# = 0;
           w1box# = '*ALL';
         else;
           w1box# = %editc($pbox#:'P');
         endif;

         if $pcord = 0;
           w1cord = '*ALL';
         else;
           w1cord = %editc($pcord:'P');
         endif;

         if $ptran = 0;
           w1tran = '*ALL';
         else;
           w1tran = %editc($ptran:'P');
         endif;

         if $pcust = 0;
           w1cust = '*ALL';
         else;
           w1cust = %editc($pcust:'P');
         endif;

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
610fA
610hA*----------------------------------------------------------------
610hA*    DRI0001  Local system caused error
610hA*----------------------------------------------------------------
610hA
      /free
610hA  begsr zm0001;

         if %subst($drimessage:1:2) = 'H:';
           #msgid = 'DRI0002';
           $drimessage = %subst($drimessage:3);
         else;
           #msgid = 'DRI0001';
         endif;
         #msgtp = '*DIAG';
         #msgdt = $drimessage + $drireturn
             + $dricommand + $drisubcmd;
         exsr zmpmsg;

       endsr;
      /end-free

610fA  //----------------------------------------------------------------
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

