      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OR204     RF single order pick - Create ORDDSOS records
     *  26 April 2011
     *  Dave Sommerville
     *
     *  Revisions
     *
640  *    04/26/11  DAS  6.40
     *      - Created
     *
640aA*    07/07/11  DAS  6.40a
     *      - Revised sql stmt to qualify the file and fields.
     *        This was done to prevent a record being written
     *        to the job log.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
     D savever#        s                   like($slver#)

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D odrec         E ds                  extname(ordd) inz(*EXTDFT)
     D odsrec        E ds                  extname(orddsos) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $pwhse          s                   like(odswhs)
     D $prtid          s                   like(odsrid)
     D $pord           s                   like(odsord)
     D $preturn        s              8

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s               n
     D forever         s               n   inz(*on)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $pwhse     Warehouse
      *      $pord      Order id
      *
      *    Returned Parameters
      *      $preturn   Return code
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    $pord
     C                   parm                    $preturn

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;
        $preturn = '*OK';

        exsr DeleteMismatch;

        exsr CreateORDDSOS;

        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  createORDDSOS   Create missing ORDDS records
     *----------------------------------------------------------------

      /free
       begsr createORDDSOS;

640aM    sqlstmt = 'select * from ordd as a '
                 + 'where odwhse=' + %char($pwhse)
                 + ' and odord=' + %char($pord)
                 + ' and not exists (select odswhs '
                 +                  'from orddsos '
640aM            +                  'where odswhs = a.odwhse '
640aM            +                    'and odsord = a.odord '
640aM            +                    'and odsseq = a.odseq '
640aM            +                    'and odsitm = a.oditem)';

         exec sql prepare orddSel from :SqlStmt;
         exec sql declare orddCsr dynamic scroll cursor for orddSel;
         exec sql open orddCsr;

         dow forever = forever;

           exec sql fetch next from orddCsr
                    into :odrec;

           if sqlstt <> sqlSuccess;
             leave;
           endif;

           odswhs = odwhse;
           odsord = odord;
           odsseq = odseq;
           odsitm = oditem;
           odsrid = $prtid;

           exsr GetSlot;
           odswhd = $slwhdp;
           odsdsp = $sldisp;

           exec sql insert into orddsos values(:odsrec);

         enddo;

         exec sql close orddCsr;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  deleteMismatch   Delete mismatched ORDDS records
     *----------------------------------------------------------------

      /free
       begsr deleteMismatch;

         exec sql delete from orddsos
                  where odswhs = :$pwhse
                    and odsord = :$pord
                    and not exists (select odwhse
                                    from ordd
                                    where odwhse = odswhs
                                      and odord = odsord
                                      and odseq = odsseq
                                      and oditem = odsitm);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetSlot    Create label record for order detail line
     *----------------------------------------------------------------

     C     Getslot       begsr

     *  Get slot for item.

     *    Try to get slot with available quantity

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = odwhse

     C                   eval      $slwhdpu = *on

     C                   eval      $slitemu = *on
     C                   eval      $slitem = oditem

     C                   eval      $slstatu = *on
     C                   eval      $slstat = 'A'

     C                   eval      $slaislu = *on
     C                   eval      $slpsequ = *on
     C                   eval      $slrlvlu = *on
     C                   eval      $slhandu = *on
     C                   eval      $slprtyu = *on
     C                   eval      $slexpdu = *on
     C                   eval      $slentdu = *on
     C                   eval      $slpicku = *on

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%NXTPICKAV'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *    If error, just get next slot.

     C                   if        $drireturn = 'EOF'
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = odwhse

     C                   eval      $slwhdpu = *on

     C                   eval      $slitemu = *on
     C                   eval      $slitem = oditem

     C                   eval      $slstatu = *on
     C                   eval      $slstat = 'A'

     C                   eval      $slaislu = *on
     C                   eval      $slpsequ = *on
     C                   eval      $slrlvlu = *on
     C                   eval      $slhandu = *on
     C                   eval      $slprtyu = *on
     C                   eval      $slexpdu = *on
     C                   eval      $slentdu = *on
     C                   eval      $slpicku = *on

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%NXTITEM'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select
     C                   when      %error
     C                   when      $drireturn <> '*OK'
     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   endsl

     C     enddricop     endsr
