      /copy qcopysrc,hspecs
     h dftactgrp(*no) actgrp(*caller)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT821     Move *MULTI Licenses to Virtual Slots
     *  24 June 2014
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  NOTE: This program was written to be called from DRIITEM, and
     *    DRICOP has already been called and is active. To prevent a
     *    recursive call to DRICOP, the calls to DRISLOT and DRILICENSE
     *    have been done directly. If any other DRI* calls are added
     *    they will have to be done directly also.
     *----------------------------------------------------------------
     *  Revisions
     *
650a *    06/24/14  RTR  6.50a
     *      - Created.
     *
     *----------------------------------------------------------------
     * File Specs
     D slotrec       e ds                  extname(slot) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Program info data structure
      /copy *libl/qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  DRI parameters
      /copy *libl/qcopysrc,c#driparms
      /copy qcopysrc,p.drilcns
      /copy qcopysrc,p.drislot

     *----------------------------------------------------------------
     *  Called program flags
     D driLcnsCalled   s               n
     D driSlotCalled   s               n

     *----------------------------------------------------------------
     *  Data Formats
      /copy *libl/qcopysrc,c#slot
      /copy *libl/qcopysrc,c#license
     D saveVer#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy *libl/qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy *libl/qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Working variables
     D clear           s              5  0
     D nextdept        s                   like(slwhdp)
     D nextslot        s                   like(sldisp)
     D nextwhse        s                   like(slwhse)
     D pDept           s                   like(slwhdp)
     D pItem           s                   like(slitem)
     D pWhse           s                   like(slwhse)
     D rtnCode         s             10
     D rtnMessage      s            200

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *      $pDept  - Department
     *      $pItem  - Item
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     D main            pr                  extpgm('IT821')
      * Input
     D  $pWhse                       15  5 const
     D  $pDept                        5    const
     D  $pItem                       15    const

     D main            pi
     D  $pWhse                       15  5 const
     D  $pDept                        5    const
     D  $pItem                       15    const

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        // Select active reserve base slots for item passed.
        exec Sql
          declare slts cursor for
            select slwhse,slwhdp,sldisp from slot
             where slwhse =  :pWhse
               and slwhdp =  :pDept
               and slitem =  :pItem
               and slpick <> 'Y'
               and slhand =  ' '
               and slstat <> 'Z';

        exec sql open slts;
        if sqlstt <> sqlSuccess;
        endif;

        dow forever = forever;

          // Read next slot record.
          exec sql fetch next from slts
                   into :nextwhse,:nextdept,:nextslot;

          // If no more, you are done.
          if sqlstt <> sqlSuccess;
            leave;
          endif;

          dow forever = forever;

            // Get next license in reverse fifo order.
            exsr getlicense;

            if error
             or $liToLcns <> '*MULTIPLE';
              leave;
            endif;

            // Retrieve and put license back.
            exsr movelicense;

          enddo;

        enddo;

        exec sql close slts;
        exsr zzzclose;
        *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------
      /free
       begsr *inzsr;

         pWhse = $pWhse;
         pDept = $pDept;
         pItem = $pItem;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GETLICENSE   Get license in reverse fifo order
     *----------------------------------------------------------------
      /free
       begsr getlicense;

         exsr clr$license;
         $liToWhseU = *on;
         $liToWhse = nextwhse;
         $liToWhdpU = *on;
         $liToWhdp = nextdept;
         $liToDispU = *on;
         $liToDisp = nextslot;
         $dricommand = '*LICENSE';
         $drisubcmd  = '%GETSLTREV';
         $drisys2upd = 'D';

         exsr zzzdrilicense;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  movelicense   Move license to virtual slot
     *----------------------------------------------------------------

      /free
       begsr movelicense;

         // Transfer license to USR slot.
         exsr clr$slot;
         $slwhseu = *on;
         $slwhse  = $liToWhse;
         $slwhdpu = *on;
         $slwhdp  = $liToWhdp;
         $sldispu = *on;
         $sldisp  = $liToDisp;
         $saitemu = *on;
         $saitem  = $liToItem;

         $saqtyu = *on;
         $saqty1 = $liToRQty1;
         $saqty2 = $liToRQty2;
         $saqty3 = $liToRQty3;

         $saActionU = *on;
         $saAction = 'SPL';
         $saETrn#U = *on;
         $saETrn# = 0;
         $saToLcnsU = *on;
         $saToLcns = $liFrmOldLcns;
         $saToPosU = *on;
         $saToPos = 1;
         $saToVrfyU = *on;
         $saToVrfy = 'N';
         $saToCodeu = *on;
         $saToCode = 'U';
         $saToAreaU = *on;
         $saToArea = 'User';
         $saOLcnsU = *on;
         $saOLcns = $liOLcns;

       //$dricommand = '*SLOT';
         $drisubcmd  = '%TFR2USRR';
       //$drisys2upd = 'D';

         exsr zzzdrislot;

         if error;
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
         $slwhse  = $slwhse;
         $slwhdpu = *on;
         $slwhdp  = $slwhdp;
         $sldispu = *on;
         $sldisp  = $litodisp;
         $saitemu = *on;
         $saitem  = $slitem;

         $saqtyu = *on;
         $saqty1 = $liToRQty1;
         $saqty2 = $liToRQty2;
         $saqty3 = $liToRQty3;

         $saActionU = *on;
         $saAction = 'SPL';
         $saETrn#U = *on;
         $saETrn# = 0;
         $saToLcnsU = *on;
         $saToLcns = $liFrmOldLcns;
         $saToPosU = *on;
         $saToPos = 1;
         $saToVrfyU = *on;
         $saToVrfy = 'N';
         $saToCodeu = *on;
         $saToCode = 'U';
         $saToAreaU = *on;
         $saToArea = 'User';
         $saOLcnsU = *on;
         $saOLcns = $liOLcns;

         $dricommand = '*SLOT';
         $drisubcmd  = '%USR2PUT';
         $drisys2upd = 'D';

         exsr zzzdrislot;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$license  Clear $license data structure fields
     *----------------------------------------------------------------

     C     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = 0
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdrilicense   Call DRILICENSE
     *----------------------------------------------------------------

      /free
        begsr zzzdrilicense;

         $dridata = $license;
         $dridata2 = $license2;

         driLcnsCalled = *on;
         driLicense($drisubcmd: #prog: $drireturn:
                    $drimessage: $dridata: $dridata2);

         $license = $dridata;
         $license2 = $dridata2;

         select;
           when %error;
             error = *on;
           when $drireturn <> '*OK';
             error = *on;
           other;
             error = *off;
         endsl;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzdrislot      Call DRISLOT
     *----------------------------------------------------------------

      /free
        begsr zzzdrislot;

         $dridata = $slot;
         $dridata2 = $slot2;

         driSlotCalled = *on;
         driSlot($drisubcmd: #prog: $drireturn:
                 $drimessage: $dridata: $dridata2);

         $slot = $dridata;
         $slot2 = $dridata2;

         select;
           when %error;
             error = *on;
           when $drireturn <> '*OK';
             error = *on;
           other;
             error = *off;
         endsl;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzclose   Close called DRI programs
     *----------------------------------------------------------------
      /free
        begsr zzzclose;

          if driSlotCalled;
            driSlot('%CLOSE': #prog: $drireturn:
                    $drimessage: $dridata: $dridata2);
          endif;

          if driLcnsCalled;
            driLicense('%CLOSE': #prog: $drireturn:
                       $drimessage: $dridata: $dridata2);
          endif;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr

     *  Make sure we don't get caught in an infinite loop

     C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

     C                   eval      *inlr = *on
     C                   return

     C     endpssr       endsr
