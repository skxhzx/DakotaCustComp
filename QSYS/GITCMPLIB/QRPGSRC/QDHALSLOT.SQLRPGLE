      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.

     *
     *  QDHALSLOT Zero Slots
     *  13 July 2017
     *  Lynn McMahon
     *
     *  Revisions:
     *
     *----------------------------------------------------------------
     *  Indicator usage                                              2
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fslot14    if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a3              s              1    dim(3)
     D a10             s              1    dim(10)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#LICENSE
      /COPY *libl/qcopysrc,C#LICINFO

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------


     D savever#        s                   like($slver#)
     D saveaisl        s                   like($slaisl)
     D saveloc         s                   like($slloc)
     D saverlvl        s                   like($slrlvl)
     D savehand        s                   like($slhand)
     D savepick        s                   like($slpick)


     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhdp          s                   like($slwhdp)
     D $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D #pgmq           s             10
     D chk4err         s               n
     D clear           s              5  0
     D cmdtkn          s              1
     D CnvWgt          s              9  2
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D errng           s              3  1
     D error           s               n
     D forever         s              1
     D help            s              5  0
     D sclear          s              1
     D whse            s              3  0
     D today           s              8  0
     D zmsflag         s               n
     D client          s             10
     D slotstat        s              2
     *
     D                 ds
     D  $hwhse                 1      3  0 inz(0)
     D  $hqty                  4     11  2 inz(0)
     D  $hwt                  12     19  2 inz(0)
     D  $hitem                20     44    inz(' ')

     *----------------------------------------------------------------
     *  Program parameters
     *
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     *   Redefine key
     *
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D lbrec         E ds                  extname(label) inz(*EXTDFT)
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *
      /Copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
      /free
700eA   // Set SQL default parms
700eA   exec sql
700eA   set Option Commit=*none, Dlyprp=*Yes,
700eA              Closqlcsr = *ENDMOD;

              exec sql
               update slot
                set SLALC1 = 0,
                    SLALC2 = 0,
                    SLALC3 = 0,
                    SLTFR1 = 0,
                    SLTFR2 = 0,
                    SLTFR3 = 0,
                    SLPCK1 = 0,
                    SLPCK2 = 0,
                    SLPCK3 = 0,
                    SLRCV1 = 0,
                    SLRCV2 = 0,
                    SLRCV3 = 0;

        slotstat = '  ';
        setll (slotstat) slot14;
        dow forever = forever;
          read slot14;
          if %eof(slot14);
            *inlr = *on;
            leave;
          endif;
          if slstat = 'V ';
            slotstat = 'V ';
            setgt (slotstat) slot14;
            iter;
          endif;
          if slstat = 'Z ';
            slotstat = 'Z ';
            setgt (slotstat) slot14;
            iter;
          endif;
          // is this item a catchweight item?
          exsr clr$item;
          $itwhse = slwhse;
          $ititem = slitem;
          $dricommand = '*ITEM';
          $drisubcmd  = '%GETALL';
          $drisys2upd = 'D';
          chk4err = *on;
          exsr zzzdricop;
          if error = *on;
          endif;
          exsr zzupd;
        enddo;
      /end-free
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Initialize special keys
     *
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client
500 A*
500 A*   Get default values for the user.
500 A*
500 AC                   call      'GETUSER'
600bMC                   parm                    #curruser
500 AC                   parm      0             #whse             3 0
500 AC                   parm      0             #emp#             5 0
500 AC                   parm                    #fnam            15
500 AC                   parm                    #init             1
500 AC                   parm                    #lnam            20
500 AC                   parm                    #whdp             5
500 AC                   parm                    #styp             1
500 AC                   parm                    #shft             6
500 AC                   parm                    #crew             6
500 AC                   parm      0             #nhrs             3 1
500 AC                   parm                    #rtn              8
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   move      *off          error

     *   Call interface to do quantity adjustment.

     C                   exsr      fill$adj
     C                   eval      $dricommand = '*SLOT'
     c*
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop


     *
     C     endupd        endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr



     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = #emp#
     C                   endsr

     *----------------------------------------------------------------
     *  fill$adj   Fill $slot data structure fields for adjustment.
     *----------------------------------------------------------------

     C     fill$adj      begsr

     *  Initialize data structure

     C                   exsr      clr$slot

     *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = slwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = slwhdp

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = sldisp

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = slitem

     C                   eval      $saqtyu  = *on
     C                   eval      $saqty1  = slstk1 * -1
     C                   eval      $saqty2  = slstk2 * -1
     C                   eval      $saqty3  = slstk3 * -1

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = 0

     C                   eval      $sacodeu = *on
      * need halsey adjustment code  *************
     C                   eval      $sacode  = 'DK'

     C                   eval      $samemou = *on
     C                   eval      $samemo  = 'Reactivate Dakota'

     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #curruser

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'ADJ'
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0

     C                   endsr



     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   select

     C                   when      $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2

     C                   other
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   endsl

     C                   select

     C                   when      %error
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl
      * moved from above - fields for $slot were not populated
     c                   select
     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   endsl

     C                   eval      zmsflag = *off
     C     enddricop     endsr

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


     C     endpssr       endsr


     *----------------------------------------------------------------     ****
     *  COMPILE TIME TABLES
     *----------------------------------------------------------------     ****
