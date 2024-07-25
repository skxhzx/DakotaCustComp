      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  DRITRUCKD   Dakota realtime interface - Truck Detail
     *  22 April 2012
     *  Dave Sommerville
     *
640  *    04/22/12  DAS  6.40
     *      - Created
     *
650aA*    04/22/14  DAS  6.50
     *      - Created routine RenumberRows.
     *      - Revised to call RenumberRows from DeleteRow routine.
     *
650bA*    05/01/14  DAS  6.50a
     *      - Added *COPYTRK command.
     *      - Added /copy field $tdfrmtrk
700aA*    08/07/15  LMC  7.00a
     *      - Fix sql statement when renumbering rows on the truck
     *      - Moved the renumbering routine to the update.
     *      - The updates happen after the delete from MRC, this was
     *        causing the wrong data to be updated, if we have already
     *        renumbered the rows.
700bA*    11/16/16  LMC  7.00b
     *      - Fix Maxrow was holding it's value from the last row
     *        added, when we don't find any records on sql, we set
     *        the value of maxrow to 0.
720aA*    04/22/18  DAS  7.20a
     *      - Revised to work with file TRKTMPD when working with DD2.
     *
720bA*    09/12/18  DAS  7.20b
     *      - Revised to call GetTBType instead of reading
     *        data area dragdrop2 directly.
     *      - Replaced dd2 with tbEnhanced.
720cA*    09/14/18  LMC  7.20c
     *      - Don't base any logic on the tbEnhanced flag for adding
     *        or deleting records from the trktmpd file.
740 A*    09/02/20  KDE  7.40
     *      - Add TRUCKDEXA and TRKTMPDEXA
     *
     *----------------------------------------------------------------
     * Notes
     *
     *  - *ADD will add generic records for an entire row. The column
     *    field should contain the number of columns to create. The
     *    compartment will be set to 'D' and the unload seq# to zero.
     *    If the row is zero, then we add a row to the end of the truck.
     *    If the row already exists, then we will do an Insert Before
     *    and change the existing row and all that follow by +1.
     *
     *  - Because the Sys2Upd parameter is not being sent into this
     *    program, another method needed to be created to determine
     *    if the call to this program was initiated by Dakota or by
     *    the Host system. Therefore, the first character of the
     *    subcommand is used to make this determination. If the
     *    character is a '%', then we assume that Dakota initiated
     *    the call. Otherwise, we assume that the Host system
     *    initiated the call.
     *
     *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *    Sub-Commands
      *
      *      *OPEN             Open program and return.
      *
      *      *CLOSE            Close program with *INLR = *ON
      *
      *      *ADD              Add row of records
      *                        Column field will indicate how many columns to create.
      *
      *      *CHANGE           Change single row/col record
      *
650aA *      *COPYTRK          Copy all TRUCKD records from $tdfrmtrk to $tdtruk.
      *
      *      *DELETE           Delete all recors for a row
      *
      *      *DELETETRK        Delete all records for a truck
      *
      *      *GET              Get single row/col record
      *
      *      *VERIFYADD        Do "*ADD" verification without update.
      *      *VERIFYCHG        Do "*CHANGE" verification without update.
      *      *VERIFYDEL        Do "*DELETE" verification without update.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D tdrec         E ds                  extname(truckd) inz(*EXTDFT)
740 AD tdxrec        E ds                  extname(truckdexa) inz(*EXTDFT)
720aAD ttdrec        E ds                  extname(trktmpd) inz(*EXTDFT)
740 AD ttxrec        E ds                  extname(trktmpdexa) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#TRUCKD
     D saveVer#        s                   like($tdver#)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D DakotaCall      s               n
     D HostCall        s               n

     D error           s               n
     D forever         s               n   inz(*on)
     D lock            s               n

640aMD i               s              2  0
650aAD lastRow         s                   like(tdrow)
700aAD finalrow        s                   like(tdrow)
640aMD maxrow          s                   like(tdrow)
650aAD newRow          s                   like(tdrow)
640aMD rowsToCreate    s              2  0
640aMD startRow        s              2  0
640aMD tmp1            s              1
650aAD sq              c                   Const('''')
720bAd tbEnhanced      s               n
720bAd tbPalletType    s              1
720bAd tbRtid          s              5
720bAd tbType          s              1
720bAd tbWhse          s              3  0

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

640aA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

720bAd/copy qcopysrc,p.gettbtyp

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
      *      $pmessage  Return code
      *      $pdata     Data returned by command
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd
     C                   parm                    $pprogram
     C                   parm                    $preturn
     C                   parm                    $pmessage
     C                   parm                    $pdata

     C                   eval      $truckd = $pdata
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See which system is calling the program.

     C                   if        %subst($psubcmd:1:1) = '%'
     C                   eval      DakotaCall = *on
     C                   eval      HostCall   = *off
     C                   eval      %subst($psubcmd:1:1) = '*'
     C                   else
     C                   eval      HostCall   = *on
     C                   eval      DakotaCall = *off
     C                   endif

     *  See if we are just opening or closing program.

     C                   select

     C                   when      $psubcmd = '*OPEN'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   endif
     C                   goto      bottom

     C                   when      $psubcmd = '*CLOSE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   endif
     C                   exsr      aaaclose
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Otherwise, do some initialization and move on.

     C                   exsr      aaainit
     C                   eval      error = *off

     *  Do what user has requested.

     C                   select

     C                   when      $psubcmd = '*ADD'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      VerifyAdd
     C                   if        not error
     C                   exsr      AddRow
     C                   endif
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*CHANGE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      VerifyChg
     C                   if        not error
     C                   exsr      ChangeRec
     C                   endif
     C                   endif
     C                   endif

650aAC                   when      $psubcmd = '*COPYTRK'
650aAC                   if        DakotaCall
650aAC                   exsr      aaacallhost
650aAC                   if        not error
650aAC                   exsr      VerifyCopyTrk
650aAC                   if        not error
650aAC                   exsr      CopyTruck
650aAC                   endif
650aAC                   endif
650aAC                   endif

     C                   when      $psubcmd = '*DELETE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      VerifyDel
     C                   if        not error
     C                   exsr      DeleteRow
     C                   endif
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*DELETETRK'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      VerifyDel
     C                   if        not error
     C                   exsr      DeleteTruck
     C                   endif
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*GET'
     C                   eval      lock = *off
     C                   exsr      GetRec
     C                   if        not error
     C                   exsr      Truckd2DS
     C                   endif

     C                   when      $psubcmd = '*VERIFYADD'
     C                   exsr      VerifyAdd
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VERIFYCHG'
     C                   exsr      VerifyChg
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VERIFYDEL'
     C                   exsr      VerifyDel
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
     C                   exsr      getmsg

     C                   endsl

     C     bottom        tag

     *  We are finished so get out

     C                   eval      $pdata = $truckd
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr

     *  Make sure we don't get caught in an infinite loop

 1B  C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

     *  Send message back to calling program.

     C                   eval      $preturn = 'U:' + #status
     C                   eval      $pmessage = 'U:'
     C                                       + %trim(#prog)
     C                                       + '('
     C                                       + %trim(%editc(#stmt:'Z'))
     C                                       + ')-'
     C                                       + #pgmmsg
     C                   eval      *inlr = *on
 1E  C                   return

     C                   endsr

     *----------------------------------------------------------------
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

     C     aaainit       begsr
720bAc*
720bAc*   Determine if using TruckBUilder Enhanced
720bAc*
720bA /free
720bA      tbWhse = $tdwhse;
720bA      tbrtid = '';
720bA      GetTBType(tbWhse: tbrtid: tbType);
720bA      if tbType = 'E';
720bA        tbEnhanced = *on;
720bA        tbPalletType = 'P';
720bA      else;
720bA        tbEnhanced = *off;
720bA        tbPalletType = 'O';
720bA      endif;
720bA /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  aaacallhost   Call host program.
     *----------------------------------------------------------------

     C     aaacallhost   begsr
     C                   endsr

     *----------------------------------------------------------------
     *  aaaclose   Close called programs
     *----------------------------------------------------------------

     C     aaaclose      begsr
     C                   endsr

     *----------------------------------------------------------------
     *  AddRow   Add row of records
     *           This will add a generic row of records, where the
     *           seq will be zero and the compartment will be 'D'.
     *----------------------------------------------------------------

     C     AddRow        begsr
      /free

         // Get max row

         exec sql select max(tdrow) into :maxrow
                  from truckd
                  where tdwhse = :$tdwhse
                    and tdtruk = :$tdtruk;

         if sqlstt <> sqlSuccess;
           startRow = 1;
700bA      maxrow   = 0;
         endif;

         // Set starting row

         select;
           when $tdrow = 0;
             startRow = maxrow + 1;
           when $tdrow > maxrow;
             startRow = maxrow + 1;
           other;
             startRow = $tdrow;
         endsl;

         // Determine how many rows to create:

         if not $tdr2cu or $tdr2c = 0;
           rowsToCreate = 1;
         else;
           rowsToCreate = $tdr2c;
         endif;

         // Increment existing rows
         // It is assumed that there are no gaps between rows.
         // To avoid unique key problems, first negate rows being changed,
         // then make it positive and add 1.

         exec sql update truckd
                  set tdrow = tdrow * -1
                  where tdwhse = :$tdwhse
                    and tdtruk = :$tdtruk
                    and tdrow  >= :startRow;
         exec sql update truckd
                  set tdrow = (tdrow * -1) + :rowsToCreate
                  where tdwhse = :$tdwhse
                    and tdtruk = :$tdtruk
                    and tdrow < 0;

         // Create rows

         clear tdrec;

         tdwhse = $tdwhse;
         tdtruk = $tdtruk;
         tdcomp = 'D';
         tdcube = 0;
         tdpick = 0;

         // Default to creating 2 columns if not sent.

         if $tdcol = 0;
           $tdcol = 2;
         endif;

         tdrow = startRow - 1;

         for i = 1 to rowsToCreate;

           tdrow += 1;

           for tdcol = 1 to $tdcol;

             exec sql insert into truckd values(:tdrec);

             if sqlstt <> sqlSuccess;
               error = *on;
               $preturn = 'ERRADDROW';
               $pmessage = 'Error creating records for row '
                         + '('
                         + %Trim(%editc($tdwhse:'Z'))
                         + '/'
                         + %trim($tdtruk)
                         + '/'
                         + %Trim(%editc(startRow:'Z'))
                         + '/'
                         + %Trim(%editc($tdcol:'Z'))
                         + '/'
                         + %Trim(%editc(rowsToCreate:'Z'))
                         + ') ' + sqlstt;
               leavesr;
             endif;

           endfor;

         endfor;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  ChangeRec   Change record.
     *----------------------------------------------------------------

     C     ChangeRec     begsr
      /free

         exec sql update truckd
                  set tdcomp = :$tdcomp,
                      tdcube = :$tdcube,
                      tdpick = :$tdpick
                  where tdwhse = :$tdwhse
                    and tdtruk = :$tdtruk
                    and tdrow  = :$tdrow
                    and tdcol  = :$tdcol;

         if sqlstt <> sqlSuccess;
           error = *on;
           $preturn = 'ERRUPDREC';
           $pmessage = 'Error updating truck row/column '
                     + '('
                     + %Trim(%editc($tdwhse:'Z'))
                     + '/'
                     + %trim($tdtruk)
                     + '/'
                     + %trim(%editc($tdrow:'Z'))
                     + '/'
                     + %trim(%editc($tdcol:'Z'))
                     + ') ' + sqlstt;
           leavesr;
         endif;
700aA    // if this is the last row to be updated run the resequence
700aA    exec sql select max(tdrow) into :finalrow
700aA             from truckd
700aA             where tdwhse = :$tdwhse
700aA               and tdtruk = :$tdtruk;

700aA    if sqlstt = sqlSuccess;
700aA      if finalrow = $tdrow and $tdcol = 2;
700aA        exsr RenumberRows;
700aA      endif;
700aA    endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  ClearErrFlags  Clear error flag fields.
     *----------------------------------------------------------------

     C     ClearErrFlags begsr
      /free

         if $tdwhsee = '1';
           $tdwhsee = '0';
         endif;

         if $tdtruke = '1';
           $tdtruke = '0';
         endif;

650aA    if $tdfrmtrke = '1';
650aA      $tdfrmtrke = '0';
650aA    endif;

         if $tdrowe = '1';
           $tdrowe = '0';
         endif;

         if $tdcole = '1';
           $tdcole = '0';
         endif;

         if $tdcompe = '1';
           $tdcompe = '0';
         endif;

         if $tdcubee = '1';
           $tdcubee = '0';
         endif;

         if $tdpicke = '1';
           $tdpicke = '0';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  CopyTruck   Copy records for truck
     *----------------------------------------------------------------

     C     CopyTruck     begsr
      /free
         error = *off;

         SqlStmt = 'select * from truckd  '
                 + 'where tdwhse=' + %char($tdwhse) + ' '
                 + 'and tdtruk=' + sq + %trimr($tdfrmtrk) + sq;

         exec sql prepare cpysel from :SqlStmt;
         exec sql declare cpycsr cursor for cpysel;
         exec sql open cpycsr;

         dow forever = forever;

           exec sql fetch next from cpycsr into :tdrec;
           if sqlstt <> sqlSuccess;
             leave;
           endif;

           tdtruk = $tdtruk;

           exec sql insert into truckd values(:tdrec);

           if sqlstt <> sqlSuccess;
             error = *on;
             $preturn = 'ERRCPYTRK';
             $pmessage = 'Error copying rows for truck '
                       + '('
                       + %Trim(%editc($tdwhse:'Z'))
                      + '/'
                       + %trim($tdtruk)
                       + ') ' + sqlstt;
720aD        //leave;
720aM        leavesr;
740 A      else;
740 A        // copy extension file for TRUCKD
740 A        exec sql select * into :tdxrec
740 A                   from truckdexa
740 A                 where tdxwhse=:$tdwhse and tdxtruk=:$tdfrmtrk
740 A                        and tdxrow=:tdrow and tdxcol=:tdcol;
740 A        if sqlstt = sqlSuccess;
740 A          tdxtruk = $tdtruk;
740 A          exec sql insert into truckdexa values(:tdxrec);
740 A        endif;
           endif;

         enddo;

         exec sql close cpycsr;

720aA    // Copy record for TruckBuilder Enhanced
720aA
720cD    //if tbEnhanced;
720aA      SqlStmt = 'select * from trktmpd  '
720aA              + 'where ttdwhse=' + %char($tdwhse) + ' '
720aA              + 'and ttdtruk=' + sq + %trimr($tdfrmtrk) + sq;
720aA
720aA      exec sql prepare cpysel2 from :SqlStmt;
720aA      exec sql declare cpycsr2 cursor for cpysel2;
720aA      exec sql open cpycsr2;
720aA
720aA      dow forever = forever;
720aA
720aA        exec sql fetch next from cpycsr2 into :ttdrec;
720aA        if sqlstt <> sqlSuccess;
720aA          leavesr;
720aA        endif;
720aA
720aA        ttdtruk = $tdtruk;
720aA
720aA        exec sql insert into trktmpd values(:ttdrec);
720aA
720aA        if sqlstt <> sqlSuccess;
720aA          error = *on;
720aA          $preturn = 'ERRCPYTRK';
720aA          $pmessage = 'Error copying TRKTMPD rows for truck '
720aA                    + '('
720aA                    + %Trim(%editc($tdwhse:'Z'))
720aA                    + '/'
720aA                    + %trim($tdtruk)
720aA                    + ') ' + sqlstt;
720aA          leave;
740 A        else;
740 A          // when success we should copy extension for trktmpd
740 A          exec sql select * into :ttxrec
740 A                     from trktmpdexa
740 A                   where ttxwhse=:$tdwhse and ttxtruk=:$tdfrmtrk
740 A                          and ttxrow=:ttdrow;
740 A          if sqlstt = sqlSuccess;
740 A            ttxtruk = $tdtruk;
740 A            exec sql insert into trktmpdexa values(:ttxrec);
740 A          endif;
720aA        endif;
720aA
720aA      enddo;
720aA
720aA      exec sql close cpycsr2;
720aA
720cD    //endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  DeleteRow   Delete row of records
     *----------------------------------------------------------------

     C     DeleteRow     begsr
      /free
         error = *off;

         // Skip actual delete for *VERIFY.

         if $psubcmd = '*VERIFYDEL';
           leavesr;
         endif;

         // Delete all records for the row

         exec sql delete from truckd
                  where tdwhse = :$tdwhse
                    and tdtruk = :$tdtruk
                    and tdrow  = :$tdrow;

         if sqlstt <> sqlSuccess and sqlstt <> sqlNoData;
           error = *on;
           $preturn = 'ERRDELROW';
           $pmessage = 'Error deleting row '
                     + '('
                     + %Trim(%editc($tdwhse:'Z'))
                     + '/'
                     + %trim($tdtruk)
                     + '/'
                     + %trim(%editc($tdrow:'Z'))
                     + ') ' + sqlstt;
           leavesr;
740 A    else;
740 A      exec sql delete from truckdexa
740 A               where tdxwhse = :$tdwhse
740 A                 and tdxtruk = :$tdtruk
740 A                 and tdxrow  = :$tdrow;
         endif;

650aA    // Renumber rows
650aA
700aD    //exsr RenumberRows;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  DeleteTruck   Delete records for truck
     *----------------------------------------------------------------

     C     DeleteTruck   begsr
      /free
         error = *off;

         // Delete all records for the truck

         exec sql delete from truckd
                  where tdwhse = :$tdwhse
                    and tdtruk = :$tdtruk;

         if sqlstt <> sqlSuccess;
           error = *on;
           $preturn = 'ERRDELTRK';
           $pmessage = 'Error deleting rows for truck '
                     + '('
                     + %Trim(%editc($tdwhse:'Z'))
                     + '/'
                     + %trim($tdtruk)
                     + ') ' + sqlstt;
           leavesr;
740 A    else;
740 A      exec sql delete from truckdexa
740 A               where tdxwhse = :$tdwhse
740 A                 and tdxtruk = :$tdtruk;
         endif;

720aA    // Deletes records for TruckBuilder Enhanced
720aA
720cD    //if tbEnhanced;
720aA      exec sql delete from trktmpd
720aA              where ttdwhse = :$tdwhse
720aA                and ttdtruk = :$tdtruk;
720aA
720aA      if sqlstt <> sqlSuccess;
720aA       error = *on;
720aA        $preturn = 'ERRDELTRK';
720aA        $pmessage = 'Error deleting TRKTMPD rows for truck '
720aA                  + '('
720aA                  + %Trim(%editc($tdwhse:'Z'))
720aA                  + '/'
720aA                  + %trim($tdtruk)
720aA                  + ') ' + sqlstt;
720aA        leavesr;
740 A      else;
740 A        // delete from extension file
740 A        exec sql delete from trktmpdexa
740 A                where ttxwhse = :$tdwhse
740 A                  and ttxtruk = :$tdtruk;
720aA      endif;
710aA
720cD    //endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  GetRec     Get record
     *----------------------------------------------------------------

     C     GetRec        begsr
      /free

         exec sql select * into :tdrec
                  from truckd
                  where tdwhse = :$tdwhse
                    and tdtruk = :$tdtruk
                    and tdrow  = :$tdrow
                    and tdcol  = :$tdcol;

         if sqlstt = sqlSuccess;
           error = *on;
           $preturn = 'RECNOTFND';
           $pmessage = 'Record not found '
                     + '('
                     + %Trim(%editc($tdwhse:'Z'))
                     + '/'
                     + %trim($tdtruk)
                     + '/'
                     + %Trim(%editc($tdrow:'Z'))
                     + '/'
                     + %Trim(%editc($tdcol:'Z'))
                     + ') ' + sqlstt;
           leavesr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  GetMsg   Get message for error code.
     *----------------------------------------------------------------

     C     GetMsg        begsr
      /free

         select;

           when $preturn = 'INVLDSBCMD';
             $pmessage = 'Invalid subcommand '
                       + '(' + %trim($psubcmd) + ') '
                       + 'sent to ' + %trim(#prog);

           other;
             $pmessage = %trim($preturn) + ': Unkown return code';

         endsl;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  Truckd2DS  Move fields to data structure fields
     *----------------------------------------------------------------

     C     Truckd2DS     begsr
      /free

         // Initialize data structure

         savever# = $tdver#;
         clear $truckd;
         $tdver# = savever#;

         // Move information to data structure.

         $tdwhse = tdwhse;
         $tdtruk = tdtruk;
         $tdrow  = tdrow;
         $tdcol  = tdcol;
         $tdcomp = tdcomp;
         $tdcube = tdcube;
         $tdpick = tdpick;

      /end-free
     C                   endsr

650aA*----------------------------------------------------------------
650aA*  RenumberRows   Renumber rows
650aA*----------------------------------------------------------------
650aA
650aAC     RenumberRows  begsr
      /free
         error = *off;

          SqlStmt = 'select * '
                  + 'from truckd '
                  + 'where tdwhse = ' + %char($tdwhse) + ' '
700aD             //+   'and tdtruk = ' + %trimr($tdtruk)
700aM            + 'and tdtruk=' + sq + %trimr($tdtruk) + sq
                  + 'order by tdwhse, tdtruk, tdrow, tdcol '
                  + 'for update of tdrow';

        exec sql prepare renumSel from :SqlStmt;
        exec sql declare renumCsr dynamic scroll cursor for renumSel;
        exec sql open renumCsr;

        newRow = 0;
        lastRow = 0;

        dow forever = forever;

          exec sql fetch next from renumCsr
                   into :tdrec;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          if tdrow <> lastRow;
            newRow += 1;
            lastRow = tdrow;
          endif;

          exec sql update truckd set
                     tdrow = :newRow
                   where current of renumCsr;

        enddo;

        exec sql close renumCsr;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VerifyAdd  Verify information when adding.
     *----------------------------------------------------------------

     C     VerifyAdd     begsr
      /free

         exsr clearerrflags;

         // Verify that necessary fields were sent.

         exsr vfytdwhseSent;
         if error;
           leavesr;
         endif;

         exsr vfytdtrukSent;
         if error;
           leavesr;
         endif;

         exsr vfytdrowSent;
         if error;
           leavesr;
         endif;

         exsr vfytdcolSent;
         if error;
           leavesr;
         endif;

         // Warehouse must exist

         exsr vfytdwhse;
         if error;
           leavesr;
         endif;

         // Truck must exist

         exsr vfytdtruk;
         if error;
           leavesr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VerifyChg   Verfify slot information for change
     *----------------------------------------------------------------

     C     VerifyChg     begsr
      /free

         exsr clearerrflags;

         // Verify that necessary fields were sent.

         exsr vfytdwhseSent;
         if error;
           leavesr;
         endif;

         exsr vfytdtrukSent;
         if error;
           leavesr;
         endif;

         exsr vfytdrowSent;
         if error;
           leavesr;
         endif;

         exsr vfytdcolSent;
         if error;
           leavesr;
         endif;

         exsr vfytdcompSent;
         if error;
           leavesr;
         endif;

         exsr vfytdcubeSent;
         if error;
           leavesr;
         endif;

         exsr vfytdpickSent;
         if error;
           leavesr;
         endif;

         // Verify compartment code

         exsr vfytdcomp;
         if error;
           leavesr;
         endif;

      /end-free
     C                   endsr

650aA*----------------------------------------------------------------
650aA*  VerifyCopyTrk  Verify information when copying truck
650aA*----------------------------------------------------------------
650aA
650aAC     VerifyCopyTrk begsr
      /free

         exsr clearerrflags;

         // Verify that necessary fields were sent.

         exsr vfytdwhseSent;
         if error;
           leavesr;
         endif;

         exsr vfytdtrukSent;
         if error;
           leavesr;
         endif;

         exsr vfytdfrmtrkSnt;
         if error;
           leavesr;
         endif;

         // Trucks cannot be the same

         if $tdtruk = $tdfrmtrk;
          error = *on;
          $tdtruke = $drierror;
          $preturn  = 'SAMETRUCK';
          $pmessage = 'Trucks cannot be the same'
                    + '('
                    + %Trim($tdtruk)
                    + ') ';
           leavesr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VerifyDel  Verify information when deleting
     *----------------------------------------------------------------

     C     VerifyDel     begsr
      /free

         exsr clearerrflags;

         // Verify that necessary fields were sent.

         exsr vfytdwhseSent;
         if error;
           leavesr;
         endif;

         exsr vfytdtrukSent;
         if error;
           leavesr;
         endif;

         if $psubcmd = '*DELETE';
           exsr vfytdrowSent;
           if error;
             leavesr;
           endif;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Field Verification Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  vfytdcomp      Verify compartment
     *----------------------------------------------------------------

     C     vfytdcomp     begsr
      /free

        exec sql select tpcode into :tdcomp
                 from trkcomp
                 where tpwhse = :$tdwhse
                   and tpcode = :$tdcomp;

        if sqlstt <> sqlSuccess;
           error = *on;
           $tdcompe = $drierror;
           $preturn  = 'INVLDCOMP';
           $pmessage = 'Invalid compartment code (' + $tdcomp + ')';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfytdtruk      Verify truck
     *----------------------------------------------------------------

     C     vfytdtruk     begsr
      /free

        exec sql select thtruk into :tdtruk
                 from truckh
                 where thwhse = :$tdwhse
                   and thtruk = :$tdtruk;

        if sqlstt <> sqlSuccess;
           error = *on;
           $tdtruke = $drierror;
           $preturn  = 'TRUKNOTFND';
           $pmessage = 'Truck must exist '
                     + '('
                     + %Trim(%editc($tdwhse:'Z'))
                     + '/'
                     + %trim($tdtruk)
                     + ') ' + sqlstt;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfytdwhse      Verify warehouse
     *----------------------------------------------------------------

     C     vfytdwhse     begsr
      /free

        exec sql select whcode into :tdwhse
                 from warehs
                 where whcode = :$tdwhse;

        if sqlstt <> sqlSuccess;
          error = *on;
          $tdwhsee = $drierror;
          $preturn  = 'WHSENOTFND';
          $pmessage = 'Warehouse must exist '
                    + '('
                    + %Trim(%editc($tdwhse:'Z'))
                    + ') ' + sqlstt;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Sent Verification Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  vfytdcolSent  Verify column was sent
     *----------------------------------------------------------------

     C     vfytdcolSent  begsr
      /free

         if not $tdcolu;
           error = *on;
           $tdcole = $drierror;
           $preturn  = 'COLNOTSNT';
           $pmessage = 'Column must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfytdcompSent  Verify comparment was sent
     *----------------------------------------------------------------

     C     vfytdcompSent begsr
      /free

         if not $tdcompu;
           error = *on;
           $tdcompe = $drierror;
           $preturn  = 'COMPNOTSNT';
           $pmessage = 'Compartment must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfytdcubeSent  Verify cube was sent
     *----------------------------------------------------------------

     C     vfytdcubeSent begsr
      /free

         if not $tdcubeu;
           error = *on;
           $tdcubee = $drierror;
           $preturn  = 'CUBENOTSNT';
           $pmessage = 'Cube must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfytdpickSent  Verify pick (unload) seq was sent
     *----------------------------------------------------------------

     C     vfytdpickSent begsr
      /free

         if not $tdpicku;
           error = *on;
           $tdpicke = $drierror;
           $preturn  = 'PICKNOTSNT';
           $pmessage = 'Pick seq must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfytdrowSent  Verify row was sent
     *----------------------------------------------------------------

     C     vfytdrowSent  begsr
      /free

         if not $tdrowu;
           error = *on;
           $tdrowe = $drierror;
           $preturn  = 'ROWNOTSNT';
           $pmessage = 'Row must be sent';
         endif;

      /end-free
     C                   endsr

650aA*----------------------------------------------------------------
650aA*  vfytdfrmtrkSnt  Verify from truck was sent
650aA*----------------------------------------------------------------
650aA
650aAC     vfytdfrmtrksntbegsr
650aA /free

         if not $tdfrmtrku;
           error = *on;
           $tdtruke = $drierror;
           $preturn  = 'FTRKNOTSNT';
           $pmessage = 'From Truck code must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfytdtrukSent  Verify truck was sent
     *----------------------------------------------------------------

     C     vfytdtrukSent begsr
      /free

         if not $tdtruku;
           error = *on;
           $tdtruke = $drierror;
           $preturn  = 'TRUKNOTSNT';
           $pmessage = 'Truck code must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfytdwhseSent  Verify warehouse was sent
     *----------------------------------------------------------------

     C     vfytdwhseSent begsr
      /free

         if not $tdwhseu;
           error = *on;
           $tdwhsee = $drierror;
           $preturn  = 'WHSNOTSNT';
           $pmessage = 'Warehouse must be sent';
         endif;

      /end-free
     C                   endsr
