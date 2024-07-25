      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  CRTROLEDTA   Create data for Role Tables
     *  24 June 2021
     *  Kennethe Elder
     *
     *  Revisions
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  How to add a new file
     *
     *  - Add File Data Structure line
     *  - Add Sub-Procedure Prototype
     *  - Add Mainline call to new sub-procedure
     *  - Create new sub-procedure by copying an exsing one.
     *    - Revise second line of gPart1 field.
     *      - Change file name.
     *      - Change field names.
     *    - Add a WrtRec line for each value to create.
     *      - The value being sent will be become the 'VALUES' parameter,
     *        therefore, we need to send the quotes around the values.
     *        To do this, each quote should be 2 single quotes. However,
     *        there is an extra single quote needed a the beginning and
     *        the end because we are passing a string to WrtRec.
     *      - Example: WrtRec('''A'',''Active''') will end up adding
     *        "values('A','Active') to the gPart1 SQL statement.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D rRorec        E ds                  extname(roles) inz(*EXTDFT)
     D rRtrec        E ds                  extname(roletasks) inz(*EXTDFT)
     D rRlrec        E ds                  extname(rolelvl) inz(*EXTDFT)
     D tkrec         E ds                  extname(task) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
     d  dsplyMsg       s             52
     D  gPart1         s            200

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d Roles           pr
     d RoleTasks       pr
     d RoleLvl         pr

     d WrtRec          pr
     d  val                         200    const

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pLib         Library to update
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pLib             10

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        // Verify parameter has been sent in

        if %parms < 1 or pLib = '';
            dsplyMsg = 'Error: Missing Parm - '
                     + 'CALL CRTGLODTA (library)';
            dsply DsplyMsg;
            return;
        endif;

        Roles(); // Roles for Auto Assign Trans process and Labor Processes
        RoleTasks(); // Rols Tasks per the Task table and Roles above
        RoleLvl(); // Role levels of employees

        return;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  WrtRec  Build/Execute SQL statement to write record
     *----------------------------------------------------------------

     p WrtRec          b
     d WrtRec          pi
     d  val                         200    const

      /free

        sqlstmt = %trimr(gPart1) + ' values ('
                + %trim(val)
                +')';

        exec sql execute immediate :sqlstmt;

        if sqlstt <> sqlSuccess;
          if sqlstt <> sqlDupRecd;
            if sqlstt = sqlUndefObject;
              dsplyMsg = 'WrtRec Error ' + sqlstt + ' - File not found';
              dsply dsplyMsg;
            else;
              dsplyMsg = 'WrtRec Error ' + sqlstt + sqlerm;
              dsply dsplyMsg;
            endif;
            dsplyMsg = %subst(sqlstmt:13);
            dsply dsplyMsg;
          endif;
        endif;

        return;

      /end-free

     p WrtRec          e

     *----------------------------------------------------------------
     *  Roles  Create Roles
     *----------------------------------------------------------------

     p Roles           b
     d Roles           pi

      /free

        gPart1 = 'insert into ' + %trimr(pLib) + '/'
               + 'roles (rocode, rosrtd, rolngd, roznec)';

        WrtRec('01,''Select'',''Selection'',''@SELECT''');
        WrtRec('02,''Replen'',''Replenishment'',''@REPLEN''');
        WrtRec('03,''Putaway'',''Putaway'',''@PUTAWAY''');
        WrtRec('04,''Receiving'',''Receiving'',''@RECEIVE''');
        WrtRec('05,''Runner'',''Runner'',''@RUNNER''');
        WrtRec('06,''Transfers'',''Transfers'',''@TRANSFER''');

        return;

      /end-free

     p Roles           e

     *----------------------------------------------------------------
     *  Rolelvl   Create Role Levels that can be associated to Users
     *----------------------------------------------------------------

     p Rolelvl         b
     d Rolelvl         pi

      /free

        gPart1 = 'insert into ' + %trimr(pLib) + '/'
               + 'rolelvl (rlcode, rlseq, rlsrtd, rllngd)';

        WrtRec('01,01,''Entry'',''Entry''');
        WrtRec('02,02,''Normal'',''Normal''');
        WrtRec('03,03,''Expert'',''Expert''');

        return;

      /end-free

     p Rolelvl         e

     *----------------------------------------------------------------
     *  RoleTasks   Create Associated Tasks per each Role
     *----------------------------------------------------------------

     p Roletasks       b
     d Roletasks       pi

     * Local Variables

     D valstr          s            200
     D wkcode          s              3  0

      /free

            gPart1 = 'insert into ' + %trimr(pLib) + '/'
                   + 'roletasks (rtcode, rttask)';

            sqlstmt = 'select * from task where tktype=' + sq + 'D' + sq +
                      ' order by tkcat, tksub';

            exec sql PREPARE tk FROM :SqlStmt;
            exec sql DECLARE tasks SCROLL CURSOR FOR tk;
            exec sql OPEN tasks;

            dow forever=forever;
              valstr=*blanks;
              exec sql fetch next from tasks into :tkrec;
              if sqlstt <> '00000';
                return;
              endif;
              select;
                when tkcode='RUNNER';
                  exec sql select rocode into :wkcode
                        from roles where roznec='@RUNNER';
                        valstr = %editc(wkcode:'X') + ',' + sq +
                                 %trim(tkcode) + sq;
                when tksub='TRNSFR' or %subst(tkcode:1:3)='TFR';
                  exec sql select rocode into :wkcode
                        from roles where roznec='@TRANSFER';
                        valstr = %editc(wkcode:'X') + ',' + sq +
                                 %trim(tkcode) + sq;
                when tkcat='SELECT';
                  exec sql select rocode into :wkcode
                        from roles where roznec='@SELECT';
                        valstr = %editc(wkcode:'X') + ',' + sq +
                                 %trim(tkcode) + sq;
                when tkcat='RECV' and tksub='RCV';
                  exec sql select rocode into :wkcode
                        from roles where roznec='@RECEIVE';
                        valstr = %editc(wkcode:'X') + ',' + sq +
                                 %trim(tkcode) + sq;
                when tksub='PUTAWY';
                  exec sql select rocode into :wkcode
                        from roles where roznec='@PUTAWAY';
                        valstr = %editc(wkcode:'X') + ',' + sq +
                                 %trim(tkcode) + sq;
                when tksub='REPL';
                  exec sql select rocode into :wkcode
                        from roles where roznec='@REPLEN';
                        valstr = %editc(wkcode:'X') + ',' + sq +
                                 %trim(tkcode) + sq;
              endsl;

              if valStr = *blanks;
                iter;
              endif;

              sqlstmt = %trimr(gPart1) + ' values ('
                      + %trim(valStr)
                      +')';

              exec sql execute immediate :sqlstmt;

              if sqlstt <> sqlSuccess;
                if sqlstt <> sqlDupRecd;
                  if sqlstt = sqlUndefObject;
                    dsplyMsg = 'WrtRec Error ' + sqlstt + ' - File not found';
                    dsply dsplyMsg;
                  else;
                    dsplyMsg = 'WrtRec Error ' + sqlstt + sqlerm;
                    dsply dsplyMsg;
                  endif;
                  dsplyMsg = %subst(sqlstmt:13);
                  dsply dsplyMsg;
                endif;
              endif;
            enddo;

        return;

      /end-free

     p Roletasks       e

