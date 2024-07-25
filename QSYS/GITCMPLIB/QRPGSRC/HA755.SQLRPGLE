640 A /copy qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  HA755      Clean up HACCPLOG records
     *  16 May 2012
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    05/16/12  LMC
     *      - Created
     *
720a *    08/22/18  LMC  7.20a
     *      - Recompile only - Databases changes.
730a *    07/11/19  LMC  7.30a
     *      - Warehouse parm is being removed.
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D haccplog      e ds
     D haccpqt       e ds

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

     D sqlfile         c                   'HACCPQT '
     D sqlfields       c                   '*'

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D append5         s              5
     D cleanwhat       s             10
     D curdate         s               d
     D $dtetme         s               z
     D dtetme          s             26
     d kywhse          s              3  0
     D chkwks          s              3  0
     D chkdays         s              4  0
     D chkymd          s              8  0
     D forevr          s              1
     D inactive        s              1    inz('0')
     D $pcmd           s              8
     D $pwhse          s              3  0
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
     c     *entry        plist
     c                   parm                    $pcmd
730aDc*                  parm                    $pwhse

      /free

        // cleanup HACCPLOG file
        cleanwhat = 'HACCPLOG';
        exsr sqlconnect;
        exsr sqlclean;
        exsr sqlbldstmt;
        exsr sqlprep;
        exsr sqlprocess;
        exsr sqlclean;

        *inlr = *On;
        return;
      /end-free

     *----------------------------------------------------------------
     *  sqlbldstmt - build sql statement
     *----------------------------------------------------------------

      /free
       begsr sqlbldstmt;
         select;

           when cleanwhat = 'HACCPLOG';
             // Create "From" clause.
             sqlfrom = 'FROM ' + sqlfile;

             // Create "where" clause.
             sqlwhere = ' ';
             append5  = 'WHERE';
730aD        //if $pwhse > 0;
730aD          //sqlwhere = %trimr(sqlwhere) + append5 + ' '
730aD               //+ 'hbwhse=' + %trim(%editc($pwhse:'P'));
730aD          //append5 = ' and ';
730aD        //endif;

             // Create "Order" clause.
             sqlorder = ' ';

             // Create SQL statement.
             SqlStmt = 'SELECT '
                     + %trimr(sqlfields) + ' '
                     + %trimr(sqlfrom) + ' '
                     + %trimr(sqlwhere) + ' '
                     + sqlorder;

         endsl;
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
     *  sqlconnect - connect
     *----------------------------------------------------------------

      /free
       begsr sqlconnect;
         exec sql CONNECT RESET;

         If sqlstt = sqlSuccess;
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
         // it prepares the cursor.

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
     *  sqlprocess - process the records
     *----------------------------------------------------------------

      /free
       begsr sqlprocess;
         select;
           when cleanwhat = 'HACCPLOG';
             // Get the next row from the SQL cursor.

             dow forever = forever;
               exec sql FETCH NEXT FROM mycsr INTO :haccpqt;

               If sqlstt = sqlSuccess;
                 curdate = %date();
                 chkdays = hbwkhst * 7;
                 curdate = curdate - %days(chkdays);
                 $dtetme= %timestamp(%char(curdate) +
                         '-00.00.00.000000');

                 // delete the haccplog based on the whse/type/levl/date
                 exec sql delete from haccplog
                          where hladdts <= :$dtetme
730aD                       //and hlwhse = :$pwhse
730aM                       and hlwhse = :hbwhse
                            and hllevl = :hblevl
                            and hltype = :hbtype;
               else;
                 leave;
               endif;
             enddo;
         endsl;
       endsr;
      /end-free
     *--------------------------------------------------------------
     *  *INZSR
      /free
        begsr *inzsr;
        endsr;
      /end-free
