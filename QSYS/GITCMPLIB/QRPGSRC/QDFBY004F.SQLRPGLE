      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDFBY004F   FRZ Put items in pick slots
     *  09 November 2017
     *  Rod Roller
     *
     *  11/09/17  RTR  7.10
     *    - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     fqdfbyxrf1fuf   e           k disk    extmbr('TEST1')

     *----------------------------------------------------------------
     *  Standard Variables
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL Variables
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  DRI parameters
      /copy *libl/qcopysrc,c#driparms
     d saveVer#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Data Formats
      /copy *libl/qcopysrc,c#slot

     *----------------------------------------------------------------
     *  Program info data structure
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Table and array definitions
     d lower           c                   'abcdefghijklmnopqrstuvwxyz'
     d upper           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

     *----------------------------------------------------------------
     *  Variables
     d chk4err         s               n
     d holdDisp        s             12a
     d wkItem          s             15a
     d wkStk1          s              5s 0
     d wkStk2          s              3s 0

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
      /free

        dou forever <> forever;
          read qdfbyxrf1f;

          if %eof(qdfbyxrf1f);
            leave;
          endif;

          holddisp = %subst(xrdisp:1:2) + '-'
                   + %subst(xrdisp:3:3) + '-'
                   + %subst(xrdisp:6:3);

          // set slots to A for aisles 65 & 66
          if %subst(holddisp:1:2) = '65'
           or %subst(holddisp:1:2) = '66';
            %subst(holddisp:9:1) = 'A';
          endif;

          // check for slot existing
          exec sql select slitem, slstk1, slstk2
                     into :wkItem, :wkStk1, :wkStk2
                     from slot
                    where sldisp = :holddisp;

          if sqlstt <> sqlsuccess;
            xract = 'ER1';
            xrtext = 'Slot not found - ' + holddisp;
            update rlrec;
            iter;

          else;
            select;
              when wkItem <> ' ' and wkItem = xritem;
                xract = 'SK2';
                xrtext = 'Same item already in slot - ' + holddisp;
                update rlrec;
              when wkItem <> ' ' and wkItem <> xritem;
                exsr crtvslot;
                if error = *on
                 and $drireturn <> 'VRTPCKCRT';
                  xract = 'ER5';
                  xrtext = 'DRI error: ' + %trimr($drireturn)
                         + ' ' + %trimr($drimessage);
                  update rlrec;
                else;
                  xract = 'UPV';
                  xrtext = 'Virtual slot created.';
                  update rlrec;
                endif;
              when wkItem = ' ';
                exec sql update slot
                            set slitem = :xritem,
                                slstat = 'A',
                                slpick = 'Y',
                                slrsrv = 'Y'
                          where sldisp = :holddisp;
                xract = 'UPD';
                xrtext = 'Item put into slot - ' + holddisp;
                update rlrec;
              other;
                xract = 'ER2';
                xrtext = 'Skipped for some other reason';
                update rlrec;
            endsl;
          endif;
        enddo;

        exsr zzzdriclose;
        *inlr = *on;
      /end-free

      *----------------------------------------------------------------
      *
      *          SUBROUTINES IN ALPHABETICAL ORDER
      *
      *----------------------------------------------------------------
      *----------------------------------------------------------------
      *  crtvslot   Create virtual slot
      *----------------------------------------------------------------

     C     crtvslot      begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = 1
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = '1    '
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = holddisp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = xritem

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd = '%CRTVPICK'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   endsr

      *----------------------------------------------------------------
      *----------------------------------------------------------------
      *                     DRI SUBROUTINES
      *----------------------------------------------------------------
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  clr$slot  Clear $slot data structure fields

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr

      *----------------------------------------------------------------
      *  zzzdriclose   Close any open files or programs.
      *----------------------------------------------------------------

     C     zzzdriclose   begsr

      *  Close interfaces

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

     C                   endsr

      *----------------------------------------------------------------
      *  zzzdricop  Call DRICOP
      *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   eval      $dridata = $slot

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   eval      $slot = $dridata

     C                   eval      chk4err = *off
     C     enddricop     endsr
