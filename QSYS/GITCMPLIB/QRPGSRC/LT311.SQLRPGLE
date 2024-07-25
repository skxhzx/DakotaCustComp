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
     *  LT311     View LICACTIVE file
     *  21 April 2013
     *  Lynn McMahon
     *
     *  Revisions
     *
700 A*    04/21/13  LMC  7.00
     *      - Created.
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

     Flt311FM   cf   e             workstn
     F                                     infds(info)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(dspsfl:rrn1)
     F                                     sfile(dspsfl2:rrn1)
     F                                     sfile(d16sfl:rrn1)
     F                                     sfile(dspsflsp:rrn1)
     F                                     sfile(d16sflsp:rrn1)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.drislot
      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.cvtqty
      /copy qcopysrc,p.lt320
      /copy qcopysrc,p.lt312
      /copy qcopysrc,p.lp130
      /copy qcopysrc,p.la830
      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.putmsg
      /copy qcopysrc,p.driitem

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($slver#)
     D save$slot       s                   like($slot)


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

     D licactive     e ds

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

     D sqlfile         c                   'LICACTIVE'
     D sqlfields       c                   '*'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

     D $icmd           s              8
     D $iwhse          s              3  0
     D $iwhdp          s              5
     D $idisp          s             12
     D $iitem          s             15
     D $idev           s             10
     D $iform          s             10
     D $ilcns          s             15

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $pwhdp          s                   like($iwhdp)
     D $pdisp          s                   like($idisp)
     D $pitem          s                   like($iitem)
     D $plcns          s                   like($ilcns)
     D $pdev           s                   like($idev)
     D $pform          s                   like($iform)

     D #whse           s              3  0
     D #emp#           s              5  0
     D #fnam           s             15
     D #init           s              1
     D #lnam           s             20
     D #whdp           s              5
     D #styp           s              1
     D #shft           s              6
     D #crew           s              6
     D #nhrs           s              3  1
     D #rtn            s              8
     D #BeltPrt        s              1
     D #Language       s              2

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
     D maxview         s              1  0 inz(2)
     D newordpos       s              3  0 inz(0)
     D noParmsPassed   s               n
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
     D  h1lcns                 1     15
     D  h1olcns               16     30
     D  h1item                31     45
     D  h1whdp                46     50
     D  h1disp                51     62
     D  h1whse                63     65S 0
     D  h1qty1                66     70S 0
     D  h1qty2                71     75S 0
     D  h1qty3                76     80S 0
     D  h1base                81     92
     D  h1dummy              100    100

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
     *      $icmd    - *VIEW
     *      $iwhse   - Warehouse
     *      $iwhdp   - Warehouse department
     *      $ivalue  - Value
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
     C                   parm                    $iwhdp
     C                   parm                    $idisp
     C                   parm                    $ilcns
     C                   parm                    $iitem

      /free

         noParmsPassed = *on;

         if %parms >= 1;
           $pcmd = $icmd;
         else;
           $pcmd = ' ';
         endif;

         if %parms >= 2 and $iwhse > 0;
           $pwhse = $iwhse;
           noParmsPassed = *off;
         else;
           $pwhse = 0;
         endif;

         if %parms >= 3 and $iwhdp <> ' ';
           $pwhdp = $iwhdp;
           noParmsPassed = *off;
         else;
           $pwhdp = ' ';
         endif;

         if %parms >= 4 and $idisp <> ' ';
           $pdisp = $idisp;
           noParmsPassed = *off;
         else;
           $pdisp = ' ';
         endif;

         if %parms >= 5 and $ilcns <> ' ';
           $plcns = $ilcns;
           noParmsPassed = *off;
         else;
           $plcns = ' ';
         endif;

         if %parms >= 6 and $iitem <> ' ';
           $pitem = $iitem;
           noParmsPassed = *off;
         else;
           $pitem = ' ';
         endif;



      /end-free

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         // Get default values for the user.

         getUser(#user: #whse: #emp#: #fnam: #init: #lnam: #whdp:
               #styp: #shft: #crew: #nhrs: #rtn: #BeltPrt: #Language);


         // Establish the connection to the remote machine. The -842 return
         // code indicates that the connection is already established. If
         // you want to connect to the local machine, use CONNECT RESET.

         exec sql CONNECT RESET;

         If sqlstt = sqlSuccess;
         endif;

         // Process main screen.

         select;
           when $pcmd = '*SPECIAL';
             exsr sc2;
         other;
             exsr screen1;
         endsl;

         // Cleanup
         exsr zsclr;

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

         // Initialize message handling

         error = *off;
         exsr zmimsg;

      /end-free
     *
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
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
                    + 'lawhse=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';
         endif;

         // Department

         if w1whdp <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'lawhdp='
                    + sq + %trim(w1whdp) + sq;
           append5 = ' and ';
         endif;

         // Slot

         if w1slot <> '*ALL';
           if %scan('%':w1slot) > 0;
             opcode = 'LIKE';
           else;
             opcode = '=';
           endif;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + '('
                    + 'labase' + ' ' + %trim(opcode) + ' '
                    + sq + %trim(w1slot) + sq
                    + ')';
           append5 = ' and ';
         endif;

         //  Base Slot

         if w1base <> '*ALL';
           if %scan('%':w1base) > 0;
             opcode = 'LIKE';
           else;
             opcode = '=';
           endif;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'labase' + ' ' + %trim(opcode) + ' '
                    + sq + %trim(w1base) + sq;
           append5 = ' and ';
         endif;

         // Slot Item

         if w1item <> '*ALL';
           if %scan('%':w1item) > 0;
             opcode = 'LIKE';
           else;
             opcode = '=';
           endif;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'lasitem' + ' ' + %trim(opcode) + ' '
                    + sq + %trim($ititem) + sq;
           append5 = ' and ';
         endif;

         // License Item

         if w1itemL <> '*ALL';
           if %scan('%':w1itemL) > 0;
             opcode = 'LIKE';
           else;
             opcode = '=';
           endif;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'laitem' + ' ' + %trim(opcode) + ' '
                    + sq + %trim(w1itemL) + sq;
           append5 = ' and ';
         endif;

         // License

         if w1lcns <> '*ALL';
           if %scan('%':w1lcns) > 0;
             opcode = 'LIKE';
           else;
             opcode = '=';
           endif;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'lalcns' + ' ' + %trim(opcode) + ' '
                    + sq + %trim(w1lcns) + sq;
           append5 = ' and ';
         endif;

         // Create "Order By" clauses.

         select;

           when sortorder1 = 'DESCEND';
             if w1oby = '1';
               sqlorder = 'ORDER BY LALCNS DESC';
             else;
               sqlorder = 'ORDER BY LAPRTY DESC,LAEXPD DESC,'
                        + 'LAENTD DESC,LALCNS DESC';
             endif;

           other;
             if w1oby = '1';
               sqlorder = 'ORDER BY LALCNS';
             else;
               sqlorder = 'ORDER BY LAPRTY,LAEXPD,LAENTD,LALCNS';
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

           exec sql FETCH NEXT FROM mycsr INTO :licactive;

           If sqlstt = sqlSuccess;
             exsr sflFill1;
             // check for multiple licinfo records - load multiple to screen
             rrn1 = rrn1  + 1;
             if first;
               first = *off;
               recpos = rrn1;
             endif;
             option = ' ';
             select;
               when #Language = 'SP' and #lline = '16';
                 write d16sflsp;
               when #Language = 'SP';
                 write dspsflsp;
               when #Language = 'EN' and #lline = '16';
                 write d16sfl;
               other;
                 write dspsfl;
                 write dspsfl2;
             endsl;
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
         select;
           when #lline = '16'  and
              #Language = 'SP';
             write d16sfcsp;
           when #lline = '16'  and
              #Language = 'EN';
             write d16sfc;
           when #lline <> '16'  and
              #Language = 'SP';
             write dspsfcsp;
           when #lline <> '16'  and
              #Language = 'EN';
             write dspsfc;
         endsl;
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

         h1lcns = lalcns;
         h1olcns = laolcns;
         h1item = laitem;
         h1whdp = lawhdp;
         h1disp = labase;
         h1whse = lawhse;
         h1qty1 = laqty1;
         h1qty2 = laqty2;
         h1qty3 = laqty3;
         h1base = labase;

         // Format quantity string

         cqqty1 = laqty1;
         cqqty2 = laqty2;
         cqqty3 = laqty3;
         cvtqty('*QTY2STR': #pgm:
                cqqty1: cqqty2: cqqty3:
                cqum1: cqum2: cqum3:
                w1qty: cqustr: cqrtn: cqerm);
         evalr w1qty = %trimr(w1qty);

         // Change priority from negative to positive

         w1prty = -(laprty);

         // Convert Entered date

         if laentd = 0;
           w1entd = 0;
         else;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(laentd);
           cvtdte($cvtdt);
           w1entd = $cvd6o;
         endif;

         // Convert Expiration date

         if laexpd = 0;
           w1expd = 0;
         else;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(laexpd);
           cvtdte($cvtdt);
           w1expd = $cvd6o;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sfloption1 - Get entered option
     *----------------------------------------------------------------

      /free
       begsr sfloption1;

         recpos = csrrrn;

         if recpos = 0;
           leavesr;
         endif;

         optiontaken = ' ';
         *in21 = *off;

         dow  forever = forever;

           select;
             when curview = 2;
               select;
                 when #lline = '16'  and
                    #Language = 'SP';
                   readc d16sflsp;
                 when #lline = '16'  and
                    #Language = 'EN';
                   readc d16sfl;
                 when #lline <> '16'  and
                    #Language = 'SP';
                   readc dspsflsp;
                 when #lline <> '16'  and
                    #Language = 'EN';
                   readc dspsfl2;
               endsl;
             other;
               select;
                 when #lline = '16'  and
                    #Language = 'SP';
                   readc d16sflsp;
                 when #lline = '16'  and
                    #Language = 'EN';
                   readc d16sfl;
                 when #lline <> '16'  and
                    #Language = 'SP';
                   readc dspsflsp;
                 when #lline <> '16'  and
                    #Language = 'EN';
                   readc dspsfl;
               endsl;
           endsl;

           if %eof;
            leave;
           endif;

           select;

             when %trim(option) = '1';
               optiontaken = 'Select';
               recpos = rrn1;


           endsl;

           option = ' ';
           select;
             when curview = 2;
               select;
                 when #lline = '16'  and
                    #Language = 'SP';
                   update d16sflsp;
                 when #lline = '16'  and
                    #Language = 'EN';
                   update d16sfl;
                 when #lline <> '16'  and
                    #Language = 'SP';
                   update dspsflsp;
                 when #lline <> '16'  and
                    #Language = 'EN';
                   update dspsfl2;
               endsl;
             other;
               select;
                 when #lline = '16'  and
                    #Language = 'SP';
                   update d16sflsp;
                 when #lline = '16'  and
                    #Language = 'EN';
                   update d16sfl;
                 when #lline <> '16'  and
                    #Language = 'SP';
                   update dspsflsp;
                 when #lline <> '16'  and
                    #Language = 'EN';
                   update dspsfl;
               endsl;
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

         scrname = 'LT311.01';
         cmdln1 = 'F3=Exit F11=Next F12=Cancel';
         w1sort = 'A';
         w1oby = '2';
         exsr inzcriteria1;

         exsr zzgetslotitem;

         exsr setcriteria1;

         scopt1 = '1=Select';



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

           select;
             when #lline = '16';
               write c16rec;
             other;
               write cmdrec;
           endsl;
           if recpos > 0 and recpos <= lastrrn;
             rrn1 = recpos;
           else;
             rrn1 = 1;
           endif;
           select;
             when curview = 2;
               select;
                 when #lline = '16'  and
                    #Language = 'SP';
                   exfmt d16sfcsp;
                 when #lline = '16'  and
                    #Language = 'EN';
                   exfmt d16sfc;
                 when #lline <> '16'  and
                    #Language = 'SP';
                   exfmt dspsfcsp;
                 when #lline <> '16'  and
                    #Language = 'EN';
                   exfmt dspsfc2;
               endsl;
             other;
               select;
                 when #lline = '16'  and
                    #Language = 'SP';
                   exfmt d16sfcsp;
                 when #lline = '16'  and
                    #Language = 'EN';
                   exfmt d16sfc;
                 when #lline <> '16'  and
                    #Language = 'SP';
                   exfmt dspsfcsp;
                 when #lline <> '16'  and
                    #Language = 'EN';
                   exfmt dspsfc;
               endsl;
           endsl;

           recpos = csrrrn;

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;

               select;

                  when optiontaken = 'Select';
                    if %subst(lalcns:1:1) = '*' and lalcns <> laolcns;
                      $ilcns = laolcns;
                      $iitem = laitem;
                    else;
                      $ilcns = lalcns;
                      $iitem = laitem;
                    endif;
                    return;

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
               if error;
                 iter;
               endif;

               $pdisp = w2type + '%';
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

         // Get default values for the user.

         getUser(#user: #whse: #emp#: #fnam: #init: #lnam: #whdp:
               #styp: #shft: #crew: #nhrs: #rtn: #BeltPrt: #Language);


         w2type = ' ';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     Misc. Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

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

         // get slot item
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

         w1base = '*ALL';

         w1lcns = '*ALL';
         w1itemL= '*ALL';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr setcriteria1;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  split  -  Split LP into new virtual slot for base slot
     *----------------------------------------------------------------

      /free
       begsr split;

         // Not allowd for * LP's
         if %subst(h1lcns:1:1) = '*';
           errmsg = 'SP not allowed for license '
               + %trim(h1lcns);
           exsr zm0105;
           leavesr;
         endif;

         // Transfer license to USR slot.
         exsr clr$slot;
         $slwhseu = *on;
         $slwhse  = h1whse;
         $slwhdpu = *on;
         $slwhdp  = h1whdp;
         $sldispu = *on;
         $sldisp  = h1disp;
         $saitemu = *on;
         $saitem  = h1item;

         $saqtyu = *on;
         $saqty1 = h1qty1;
         $saqty2 = h1qty2;
         $saqty3 = h1qty3;

         $saActionU = *on;
         $saAction = 'SPL';
         $saETrn#U = *on;
         $saETrn# = 0;
         $saToLcnsU = *on;
         $saToLcns = h1lcns;
         $saToPosU = *on;
         $saToPos = 1;
         $saToVrfyU = *on;
         $saToVrfy = 'N';
         $saToCodeu = *on;
         $saToCode = 'U';
         $saToAreaU = *on;
         $saToArea = 'User';
         $saOLcnsU = *on;
         $saOLcns = h1olcns;

         $dricommand = '*SLOT';
         $drisubcmd  = '%TFR2USR';
         $drisys2upd = 'D';
         chk4err = *on;
         zmflag = *off;
         exsr zzzdricop;
         if error;
           errmsg = 'Error transfering '
               + %trim(h1lcns)
               + ' to USR slot';
           exsr zm0105;
           exsr zm0001;
           leavesr;
         endif;

         // Transfer license back into slot.
         $sacwhdu = *on;
         $sacwhd  = $slwhdp;
         $sacdspu = *on;
         $sacdsp  = $sldisp;
         $sacitemu = *on;
         $sacitem  = $slitem;

         $slwhseu = *on;
         $slwhse  = h1whse;
         $slwhdpu = *on;
         $slwhdp  = h1whdp;
         $sldispu = *on;
         $sldisp  = h1base;
         $saitemu = *on;
         $saitem  = h1item;

         $saqtyu = *on;
         $saqty1 = h1qty1;
         $saqty2 = h1qty2;
         $saqty3 = h1qty3;

         $saActionU = *on;
         $saAction = 'SPL';
         $saETrn#U = *on;
         $saETrn# = 0;
         $saToLcnsU = *on;
         $saToLcns = h1lcns;
         $saToPosU = *on;
         $saToPos = 1;
         $saToVrfyU = *on;
         $saToVrfy = 'N';
         $saToCodeu = *on;
         $saToCode = 'U';
         $saToAreaU = *on;
         $saToArea = 'User';
         $saOLcnsU = *on;
         $saOLcns = h1olcns;

         $dricommand = '*SLOT';
         $drisubcmd  = '%USR2PUT';
         $drisys2upd = 'D';
         chk4err = *on;
         zmflag = *off;
         exsr zzzdricop;
         if error;
           errmsg = 'Error transfering '
               + %trim(h1lcns)
               + ' back to '
               + %trim(h1disp);
           exsr zm0105;
           exsr zm0001;
           leavesr;
         endif;

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

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

      /free
       begsr zm0001;

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

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = #emp#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C                   exsr      zm0105
     C                   endsl

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C                   exsr      zm0001
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *
     *  ZZGETSLOTITEM - Get slot item.
     *
     *----------------------------------------------------------------
      /free
       begsr zzgetslotitem;

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
