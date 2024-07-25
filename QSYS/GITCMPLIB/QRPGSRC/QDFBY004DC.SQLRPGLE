      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDFBY004B  Put items in pick slots - 26 fix slot
     *  01 December 2016
     *  Rod Roller
     *
     *  12/01/16  RTR  7.00
     *    - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     fqdfbyxref3uf   e           k disk    extmbr('TEST26')

     *----------------------------------------------------------------
     *  Standard Variables
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL Variables
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Data Formats
      /copy *libl/qcopysrc,c#slot

     *----------------------------------------------------------------
     *  DRI parameters
      /copy *libl/qcopysrc,c#driparms
     d saveVer#        s                   like($slver#)

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
     d currCnt         s             10i 0
     d currDisp        s             12a
     d currItem        s             15a
     d currWhdp        s              5a

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
      /free

        dou forever <> forever;
          read qdfbyxref3;

          if %eof(qdfbyxref3);
            leave;
          endif;

          if x3act <> *blanks;
            iter;
          endif;

          // check if item exists
          exec sql select itwhdp into :currWhdp from piritem
                    where ititem = :x3item;
          if sqlstt <> sqlsuccess;
            x3act = 'ER1';
            x3text = 'Item does not exist.';
            update x3rec;
            iter;
          endif;

          // check if item already has a pick slot
          currCnt = 0;
          exec sql select count(*) into :currCnt from slot
                    where slitem = :x3item
                      and slpick = 'Y';
          if currCnt>= 1;
            exec sql select sldisp into :currDisp from slot
                      where slitem = :x3item
                        and slpick = 'Y';
            x3act = 'ER2';
            x3text = 'Pick slot ' + %trim(currDisp)
                   + ' already exists for item.';
            update x3rec;
            iter;
          endif;

          // check if wanted slot exists
          exec sql select slitem into :currItem from slot
                    where sldisp = :x3disp1;
          if sqlstt <> sqlsuccess;
            x3act = 'ER3';
            x3text = 'Slot does not exist.';
            update x3rec;
            iter;
          endif;

          // check if item already in pick slot
          if currItem = x3item;
            x3act = 'ER4';
            x3text = 'Item already in pick slot.';
            update x3rec;
            iter;
          endif;

          // create virtual slot
          exsr crtvslot;
          if error = *on;
            x3act = 'ER5';
            x3text = 'DRI error: ' + %trimr($drireturn) + %trimr($drimessage);
            update x3rec;
          else;
            x3act = 'OK ';
            x3text = 'Item added to slot.';
            update x3rec;
          endif;

        enddo;

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
     C                   eval      $slwhdp  = currWhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = x3disp1
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = x3item

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
