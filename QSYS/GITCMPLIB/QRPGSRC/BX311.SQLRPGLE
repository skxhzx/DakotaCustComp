      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
      *****************************************************************
      **************************************************    5/10/16 ***
      ****   work in progress to modify BX310 to BX311      NANCY   ***
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
     *  BX311     View AMPXREF file
     *  10 May 2016
     *  Nancy Koelz
     *
     *  Revisions
     *
700 A*    05/10/16  NLK  7.00
     *      - Created.
     *
     *
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fbx311fm   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
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
     D fetchds         ds
     D   #bwhse                            like(axwhse)
     D   #bcord                            like(axcord)
     D   #bitem                            like(axitem)
     D   #btrn#                            like(axatrn#)
     D   #blbl#                            like(axalbl#)
     D   #bboxid                           like(axaboxid)
     D   #bdrtid                           like(axdrtid)
     D   #bdesc                            like(itdesc)
     D   #bqalc                            like(lbqalc)
     D   #bqpck                            like(lbqpck)
     D ampxref       e ds
     D ampbox        e ds
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
     D sqlfields       c                   'axwhse,axcord,axitem,+
     D                                      axatrn#,axalbl#,+
     D                                      axaboxid,axdrtid,+
     D                                      itdesc,lbqalc,lbqpck'
700aAD sqlfieldt       c                   'axwhse,axcord,axitem,+
     D                                      axatrn#,axalbl#,+
     D                                      axaboxid,axdrtid,+
     D                                      itdesc,lbqalc,lbqpck,+
700aDD                                      abxbox#'
     D sqlfilea        c                   'AMPXREF'
     D sqlfileb        c                   'AMPBOX'
     D sqlfilec        c                   'PIRITEM'
700aAD sqlfiled        c                   'LABEL'
700aAD sqljoinfldb     c                   'a.axwhse=b.abxwhse +
     D                                      and +
     D                                      a.axaboxid=b.abxboxid'
     D sqljoinfldc     c                   'a.axwhse=c.itwhse +
     D                                      and +
     D                                      a.axitem=c.ititem'
700aAD sqljoinfldd     c                   'a.axwhse=d.lbwhse +
     D                                      and +
     D                                      a.axalbl#=d.lblbl#'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

     D $icmd           s              8
     D $iwhse          s              3  0
     D $idt            s              8  0
     D $itranLO        s              7  0
     D $itranHI        s              7  0

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $pdt            s                   like($idt)
     D $ptranLO        s                   like($itranLO)
     D $ptranHI        s                   like($itranHI)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D append1         s              1
     D append5         s              5
     D appendo         s              7
     D BLK             s              5a   inz(' ')
     D first           s               n
     D groupby         S            100a   inz(' ')
     D groupfields     S            100a   inz(' ')
     D lastrrn         s                   like(rrn1)
     D orderby         S            100a   inz(' ')
     D orderfield      s             10    inz(' ')
     D orderposition   s              3  0 inz(0)
     D recpos          s                   like(rrn1)
     D today           s              8  0
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
     D w1Whse          s              3  0
     D wkWhse          s              3  0
     D wkDept          s              5
     D b               s             10  0
     D chk4err         s               n
     D zmsflag         s               n
     D zmflag          s               n

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
     *      $icmd    - *NoDelRt
     *                 *NoBoxID
     *      $iwhse   - Warehouse
     *      $idt     - date
     *      $itranLO - tranLO (represents selected date)
     *      $itranHI - custHI
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
     C                   parm                    $iTranLO
     C                   parm                    $iTranHI

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         // Process main screen.

         $pcmd = $icmd;
         w1whse = $iwhse;
         w1dt = $idt;
         tranLO = $iTranLO;
         tranHI = $iTranHI;

         select;
           when $pcmd = '*NoDelRt';
             *in45=*off;
             exsr screen1;
           when $pcmd = '*NoBoxID';
             *in45=*on;
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
     *  sqlbldstmt6 - Build SQL statment (AMPxRef)
     *----------------------------------------------------------------

      /free
       begsr sqlbldstmt1;

         // Create "From" clause.

         sqlfrom = 'FROM ' + sqlfilea + ' a ';

         sqlwhere = ' ';
         appendo  = ' ';

         // JOIN file and AMPBOX not needed if NoBox#

         sqljoin  = 'INNER JOIN ' + sqlfileb + ' b ' + 'on ';
            sqljoin = %trimr(sqljoin) + ' ' + sqljoinfldb;

         sqljoin2 = 'INNER JOIN ' + sqlfilec + ' c ' + 'on ';
            sqljoin2 = %trimr(sqljoin2) + ' ' + sqljoinfldc;

700aA    sqljoin3 = 'INNER JOIN ' + sqlfiled + ' d ' + 'on ';
            sqljoin3 = %trimr(sqljoin3) + ' ' + sqljoinfldd;

         // Create "where" clause.

         // Warehouse

           append5 = 'WHERE';
           sqlwhere = %trimr(sqlwhere) + append5
                    + ' axwhse=' + %trim(%editc(w1whse:'P'));
           append5 = ' and';

         // add in a range of Date to LOOK for No Delv Rt
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'axatrn#>='
                    + sq + %trim(%editc(tranLO:'P')) + sq;
           append5 = ' and';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'axatrn#<='
                    + sq + %trim(%editc(tranHI:'P')) + sq;
           append5 = ' and ';

         // No Box ID or No Delv Rt
         select;
           when $pcmd = '*NoBoxID';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'axaboxid=0';

           when $pcmd = '*NoDelRt';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'axdrtid = ' + sq + '  ' + sq;

           endsl;

         // Create "Order By" clauses.

               sqlorder = 'ORDER BY axcord';


         // Create SQL statement.

         select;
           when $pcmd = '*NoDelRt';
           SqlStmt = 'SELECT '
                 + %trimr(sqlfieldt) + ' '
                 + %trimr(sqlfrom) + ' '
700aA            + %trimr(sqljoin) + ' '
700aA            + %trimr(sqljoin2) + ' '
700aA            + %trimr(sqljoin3) + ' '
                 + %trimr(sqlwhere) + ' '
                 + sqlorder;

           when $pcmd = '*NoBoxID';
           SqlStmt = 'SELECT '
                 + %trimr(sqlfields) + ' '
                 + %trimr(sqlfrom) + ' '
700aA            + %trimr(sqljoin2) + ' '
700aA            + %trimr(sqljoin3) + ' '
                 + %trimr(sqlwhere) + ' '
                 + sqlorder;
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
     *  sflBldDisp   Build and display subfile (date's boxes)
     *----------------------------------------------------------------

      /free
       begsr sflBldDisp;

         exsr sqlclean;
         exsr sqlbldstmt1;
         exsr sqlprep;
         exsr sflclr;
         select;
           when $pcmd = '*NoDelRt';
           exsr sflbld2;

           when $pcmd = '*NoBoxID';
           exsr sflbld1;

         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflbld1 - Build the subfile  AMPxRef
     *----------------------------------------------------------------

      /free
       begsr sflbld1;

         rrn1 = Lastrrn;
         recpos = lastrrn;
         first = *on;

         // Process the records in the SQL cursor until the return not = 0

         for i = 1 to subfilePage;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr INTO
                   :fetchds;

           If sqlstt = sqlSuccess;
             exsr sflFill1;
             rrn1 = rrn1  + 1;
             if first;
               first = *off;
               recpos = rrn1;
             endif;
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

         // ************Add Box#

       begsr sflbld2;

         rrn1 = Lastrrn;
         recpos = lastrrn;
         first = *on;

         // Process the records in the SQL cursor until the return not = 0

         for i = 1 to subfilePage;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr INTO
                   :fetchds, :abxbox#;

           If sqlstt = sqlSuccess;
             exsr sflFill1;
             rrn1 = rrn1  + 1;
             if first;
               first = *off;
               recpos = rrn1;
             endif;
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

         // Store hidden fields that aren't displayed on screen
         // and will be used later.

         select;
           when $pcmd = '*NoBoxID';
           #BBOX = 0;
           when $pcmd = '*NoDelRt';
           #BBOX = abxbox#;
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                Screen Processing Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  screen1 - Process screen 1  (sfl - boxes for the day)
     *----------------------------------------------------------------

      /free
       begsr screen1;

         // Initialize screen fields
         scrname = 'BX311.01';

         exsr sflBldDisp;

         // Process subfile until user wants to leave

         dou (cfkey = F3);

           Write fkey1;
           if recpos > 0 and recpos <= lastrrn;
             rrn1 = recpos;
           else;
             rrn1 = 1;
           endif;
               exfmt sf1ctl;

           recpos = csrrrn;

           Select;
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

