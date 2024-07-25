      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/US220) SRCFILE(XXX/QRPGSRC)
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
     *  US220    Import View Import Item Updates
     *  September 11, 2014
     *  Rod Roller
     *
     *  Revisions
     *
650 A*    09/11/14  RTR  6.50
     *      - Created.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Files
     *
     Fus220fm   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     infds(info)

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
     D pgmusrid      e ds

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

     D sqlfile         c                   'PGMUSRID'
     D sqlfields       c                   'DISTINCT PGUSER'

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
     D ObjNam          s             10a
     D ObjLib          s             10a   inz('*ALL      ')
     D ObjTyp          s             10a   inz('*USRPRF   ')
     D opcode          s              6
     D optiontaken     s             10    inz(' ')
     D recpos          s                   like(rrn1)
     D resettext       s            200a
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')
     D userfound       s               n

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
     *   Api error data structure:
     D ApiError        Ds
     D  AeBytPro                     10i 0 Inz( %Size( ApiError ))
     D  AeBytAvl                     10i 0 Inz
     D  AeMsgId                       7a
     D                                1a
     D  AeMsgDta                    128a
     *----------------------------------------------------------------
     *   Object description structure OBJD0200:
     D RoData          Ds
     D  RoBytRtn                     10i 0
     D  RoBytAvl                     10i 0
     D  RoObjNam                     10a
     D  RoObjLib                     10a
     D  RoObjTypRt                   10a
     D  RoObjLibRt                   10a
     D  RoObjASP                     10i 0
     D  RoObjOwn                     10a
     D  RoObjDmn                      2a
     D  RoObjCrtDts                  13a
     D  RoObjChgDts                  13a
     D  RoExtAtr                     10a
     D  RoTxtDsc                     50a
     D  RoSrcF                       10a
     D  RoSrcLib                     10a
     D  RoSrcMbr                     10a
     *----------------------------------------------------------------
     *   Retrieve object description:
     D RtvObjD         Pr                  ExtPgm( 'QUSROBJD' )
     D  RoRcvVar                  32767a         Options( *VarSize )
     D  RoRcvVarLen                  10i 0 Const
     D  RoFmtNam                      8a   Const
     D  RoObjNamQ                    20a   Const
     D  RoObjTyp                     10a   Const
     D  RoError                   32767a         Options( *VarSize )

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

         // Create "Order By" clauses.
         select;
           when sortorder1 = 'DESCEND';
             sqlorder = 'ORDER BY PGUSER DESC';
           other;
             sqlorder = 'ORDER BY PGUSER';
         endsl;

         // Create SQL statement.
         SqlStmt = 'SELECT '
                 + %trimr(sqlfields) + ' '
                 + %trimr(sqlfrom) + ' '
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

           exec sql FETCH NEXT FROM mycsr INTO :pguser;

           If sqlstt = sqlSuccess;
             exsr sflFill1;
             rrn1 = rrn1  + 1;
             if first;
               first = *off;
               recpos = rrn1;
             endif;
             option = ' ';
             // Get Description
             ObjNam = pguser;
             exsr checkuser;
             if userfound;
               s1desc = RoTxtDsc;
             else;
               s1desc = '** User does not exist';
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

             when %trim(option) = '3';
               optiontaken = 'CopyUser';
               recpos = rrn1;

             when %trim(option) = '4';
               optiontaken = 'DeleteUser';
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

         scopt1 = '3=Copy Security  4=Remove Security';

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

                  when optiontaken = 'CopyUser';
                    exsr CopyUser;
                    exsr sflBldDisp;
                    cfkey = Enter;

                  when optiontaken = 'DeleteUser';
                    exsr DeleteUser;
                    exsr sflBldDisp;
                    cfkey = Enter;

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

       endsr;
      /end-free

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

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------
      /free
       begsr setcriteria1;

         // Set sort order
         sortorder1 = 'ASCEND';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  CopyUser - View User Info
     *----------------------------------------------------------------
      /free
       begsr CopyRecs;

         Exec sql insert into pgmusrid
                   (select b.pgpgm, b.pgopt, :s3tuser
                      from pgmusrid b
                     where b.pguser = :s3fuser);

         If sqlstt <> sqlSuccess;
           error = *on;
           *in82 = *on;
         else;
           error = *off;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  CopyUser - View User Info
     *----------------------------------------------------------------
      /free
       begsr CopyUser;

         // Display detail screen
         dou (cfkey = F3);

           *in90 = *on;
           s3fuser = pguser;
           exfmt screen3;

           Select;
             // F5 = Refresh
             when cfkey = F5;
               leave;
             // F12 = Cancel
             when cfkey = F12;
               leave;
             other;
               // Check if 'to' user exists
               ObjNam = s3tuser;
               exsr checkuser;
               if userfound;
                 exsr copyrecs;
               else;
                 error = *on;
                 *in81 = *on;
               endif;
           EndSl;

         EndDo;

         *in90 = *off;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  CheckUser - Verify User ID exists and retrieve description
     *----------------------------------------------------------------
      /free
        begsr CheckUser;

          callp RtvObjD( RoData
                       : %Size( RoData )
                       : 'OBJD0200'
                       : ObjNam + ObjLib
                       : ObjTyp
                       : ApiError );

          if AeBytAvl > *Zero and AeMsgId = 'CPF9801';
            userfound = *off;
          else;
            userfound = *on;
          endif;

        endsr;  // CheckUser
      /end-free

     *----------------------------------------------------------------
     *  DeleteRecs - Delete user auth recs
     *----------------------------------------------------------------
      /free
       begsr DeleteRecs;

         Exec sql delete from pgmusrid
                   where pguser = :pguser;

         If sqlstt <> sqlSuccess;
           error = *on;
         else;
           error = *off;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DeleteUser - Prompt for User Delete
     *----------------------------------------------------------------
      /free
       begsr DeleteUser;

         // Display screen
         dou (cfkey = F3);

           *in90 = *on;
           s4fuser = %trim(pguser) + '?';
           exfmt screen4;

           select;
             // F12 = Cancel
             when cfkey = F12;
               leave;
             when cfkey = F5;
               exsr DeleteRecs;
               leave;
             other;
           endsl;

         enddo;

         *in90 = *off;
       endsr;
      /end-free

