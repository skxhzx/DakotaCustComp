      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SG175) SRCFILE(XXX/QRPGSRC)
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
     *  SG175    Staging Import View Purchase Order Header
     *  04 April 2014
     *  Rod Roller
     *
     *  Revisions
     *
650 A*    04/04/14  RTR  6.50
     *      - Created using SG125A as a base.
700a *    08/12/16  RTR  7.00a
     *      - Added RP=Reset PO option.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

700aAF**sg175fm   cf   e             workstn
700aAFsg17501   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     infds(info)
700aAFlogstg    o  a e           k disk    usropn

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      *copy qcopysrc,p.cvtdte
      *copy qcopysrc,p.cvtqty
      *copy qcopysrc,p.bfcdteti

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

     D expspoh       e ds

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

     D sqlfile         c                   'EXPSPOH'
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

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $pbatid         s                   like($ibatid)

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
700aAD promptok        s               n
     D recpos          s                   like(rrn1)
     D resettext       s            200a
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')
700aAD userok          s               n

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

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------
     D sg176           pr                  extpgm('SG176')
     D  cmd176                        8a   const
     D  whse176                       3  0 const
     D  batid176                     11a   const
     D  ordid176                      9a   const

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
                    + 'pehwhs=' + %trim(%editc($pwhse:'P'));
           append5 = ' and ';

         // Batch

           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'pehbatid=' + sq + %trim($pbatid) + sq;
           append5 = ' and ';

         // Create "Order By" clauses.

         select;
           when sortorder1 = 'DESCEND';
             sqlorder = 'ORDER BY PEHPO DESC';
           other;
             sqlorder = 'ORDER BY PEHPO';
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

           exec sql FETCH NEXT FROM mycsr INTO :expspoh;

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
           when pehstatus = 'E';
             s1stat1 = 'Err';
             *in81 = *on;
           when pehstatus = 'P';
             s1stat1 = 'Prc';
           when pehstatus = 'R';
             s1stat1 = 'Rdy';
           when pehstatus = 'S';
             s1stat1 = 'Suc';
             *in82 = *on;
           when pehstatus = 'W';
             s1stat1 = 'Wrt';
           when pehstatus = 'X';
             s1stat1 = 'Wrt';
           other;
             s1stat1 = pehstatus;
         endsl;

         s1name = pehvnm;
         h1whse = pehwhs;
         h1batid = pehbatid;

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
               optiontaken = 'ViewFull';
               recpos = rrn1;

             when %trim(option) = '12';
               optiontaken = 'ViewDetail';
               recpos = rrn1;

700aA        when %trim(option) = 'RP'
700aA         and pehstatus = 'E';
700aA          optiontaken = 'ResetPO';
700aA          recpos = rrn1;

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

         scopt2 = '5=View Full Header  '
                + '12=View PO Detail  '
700aA           + 'RP=Reset PO  ';

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

                  when optiontaken = 'ViewDetail';
                    $pcmd2 = '*VIEW';
                    $pwhse2 = h1whse;
                    $pbatid2 = h1batid;
                    $pordid2 = pehpo;
                    sg176($pcmd2: $pwhse2: $pbatid2: $pordid2);

700aA             when optiontaken = 'ResetPO';
700aA               pgmopt = 'RP';
700aA               exsr CheckUser;
700aA               if userok;
700aA                 exsr PromptReset;
700aA               else;
700aA                 exfmt window3;
700aA                 promptok = *off;
700aA               endif;
700aA               if promptok;
700aA                 exsr resetmain;
700aA               endif;
700aA               exsr sflBldDisp;
700aA               cfkey = Enter;

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

700aA*----------------------------------------------------------------
700aA*  CheckUser - Check User Security
700aA*----------------------------------------------------------------
700aA
700aAc     CheckUser     begsr
700aA
700aAc                   call      'CHKLIST'
700aAc                   parm                    #prog
700aAc                   parm                    pgmopt           20
700aAc                   parm                    #user
700aAc                   parm                    $rtncd            8
700aA
700aAc                   if        $rtncd = '*NO'
700aAc                   eval      userok = *off
700aAc                   else
700aAc                   eval      userok = *on
700aAc                   endif
700aA
700aAc                   endsr
700aA
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

         scrname = 'SG175.01';

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

700aA*----------------------------------------------------------------
700aA*  promptreset - Prompt window for Reset PO.
700aA*----------------------------------------------------------------
700aA
700aA /free
700aA  begsr promptreset;
700aA
700aA    // Display window.
700aA    *in41 = *on;
700aA
700aA    dou forever = forever;
700aA      exfmt window2;
700aA      select;
700aA        when cfkey = F8;
700aA          promptok = *on;
700aA          leave;
700aA        when cfkey = F12;
700aA          promptok = *off;
700aA          leave;
700aA      endsl;
700aA    enddo;
700aA
700aA  endsr;
700aA /end-free
700aA
700aA*----------------------------------------------------------------
700aA*  resetmain - Reset batch driver
700aA*----------------------------------------------------------------
700aA
700aA /free
700aA  begsr resetmain;
700aA
700aA    resettext = 'Error reset by ' + %trim(#user);
700aA    error = *off;
700aA
700aA    exsr resetexppo;
700aA
700aA    if error = *off;
700aA      Exec sql update stgbatch
700aA                  set SBSTATUS = 'R',
700aA                      SBSTSTS = CURRENT_TIMESTAMP,
700aA                      SBSTSUC = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
700aA                      SBTEXT = :resettext
700aA                where SBWHSE = :h1whse
700aA                  and SBBATID = :h1batid;
700aA      // log it
700aA      sglwhse = h1whse;
700aA      sglbatid = h1batid;
700aA      sglrtid = *blanks;
700aA      sgltype = '*RESETBAT';
700aA      sgltext = resettext;
700aA      exsr writelog;
700aA    endif;
700aA
700aA  endsr;
700aA /end-free
700aA
700aA*----------------------------------------------------------------
700aA*  resetexppo - Reset EXPPO batches
700aA*----------------------------------------------------------------
700aA
700aA /free
700aA  begsr resetexppo;
700aA
700aA    Exec sql update expspod
700aA                set PEDSTATUS = 'R',
700aA                    PEDSTSTS  = CURRENT_TIMESTAMP,
700aA                    PEDSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
700aA                    PEDTEXT   = :resettext
700aA              where PEDWHS    = :h1whse
700aA                and PEDBATID  = :h1batid
700aA                and PEDPO     = :pehpo;
700aA    Exec sql update expspoh
700aA                set PEHSTATUS = 'R',
700aA                    PEHSTSTS  = CURRENT_TIMESTAMP,
700aA                    PEHSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
700aA                    PEHTEXT   = :resettext
700aA              where PEHWHS    = :h1whse
700aA                and PEHBATID  = :h1batid
700aA                and PEHPO     = :pehpo;
700aA
700aA  endsr;
700aA /end-free
700aA
700aA*----------------------------------------------------------------
700aA*  resetimppo - Reset IMPPO batches
700aA*----------------------------------------------------------------
700aA
700aA /free
700aA  begsr resetimppo;
700aA
700aA    Exec sql update impspoh
700aA                set PIHSTATUS = 'R',
700aA                    PIHSTSTS  = CURRENT_TIMESTAMP,
700aA                    PIHSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
700aA                    PIHTEXT   = :resettext
700aA              where PIHWHS   = :h1whse
700aA                and PIHBATID = :h1batid;
700aA    Exec sql update impspod
700aA                set PIDSTATUS = 'R',
700aA                    PIDSTSTS  = CURRENT_TIMESTAMP,
700aA                    PIDSTSUC  = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
700aA                    PIDTEXT   = :resettext
700aA              where PIDWHS   = :h1whse
700aA                and PIDBATID = :h1batid;
700aA
700aA  endsr;
700aA /end-free

     *----------------------------------------------------------------
     *  ViewFull - View Full Header Info
     *----------------------------------------------------------------

      /free
       begsr ViewFull;

         // Display detail screen
         dou (cfkey = F3);

           *in90 = *on;
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

         *in90 = *off;
       endsr;
      /end-free

700aA*----------------------------------------------------------------
700aA*  writelog - Write record to staging log file
700aA*----------------------------------------------------------------
700aA
700aA /free
700aA  begsr WriteLog;
700aA
700aA    open logstg;
700aA
700aA    sgladdpgm = #prog;
700aA    sgladdjusr = #user;
700aA    sgladdjob = #job;
700aA    sgladdnbr = #jobnbr;
700aA    sgladdts = %timestamp();
700aA
700aA    write(e) sglrec;
700aA
700aA    close logstg;
700aA
700aA  endsr;
700aA /end-free
700aA
