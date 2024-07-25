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

640aMD maxrow          s                   like(tdrow)
640aMD tmp1            s              1

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

640aA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

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

         select;

         // Either get row to add

         when $tdrow = 0;
           exec sql select max(tdrow) into :maxrow
                    from truckd
                    where tdwhse = :$tdwhse
                      and tdtruk = :$tdtruk;

           $tdrow += 1;

         // Or increment existing rows

         when $tdrow > 0;
           exec sql select tdrow into :tdrow
                    from truckd
                    where tdwhse = :$tdwhse
                      and tdtruk = :$tdtruk
                      and tdrow  = :$tdrow;

           if sqlstt = sqlSuccess;
             exec sql update truckd
                      set tdrow = tdrow * -1
                      where tdwhse = :$tdwhse
                        and tdtruk = :$tdtruk
                        and tdrow  >= :$tdrow;
             exec sql update truckd
                      set tdrow = (tdrow * -1) + 1
                      where tdwhse = :$tdwhse
                        and tdtruk = :$tdtruk
                        and tdrow  < 0;
           endif;

         endsl;

         clear tdrec;

         tdwhse = $tdwhse;
         tdtruk = $tdtruk;
         tdrow  = $tdrow;
         tdcomp = 'D';
         tdcube = 0;
         tdpick = 0;

         // Default to creating 2 columns if not sent.

         if $tdcol = 0;
           $tdcol = 2;
         endif;

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
                       + %Trim(%editc($tdrow:'Z'))
                       + '/'
                       + %Trim(%editc($tdcol:'Z'))
                       + ') ' + sqlstt;
             leavesr;
           endif;

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

         if sqlstt <> sqlSuccess;
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
         endif;

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
         endif;

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
