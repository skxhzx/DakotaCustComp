     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
510 A*  UI351     UCI Inventory Adjustment Stuffit Listing
     *  05 April  2007
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
     *    xx/xx/xx  xxx  x.xx
     *
     *----------------------------------------------------------------
      *  Notes
      *
      *----------------------------------------------------------------
      *  Indicator usage
      *
      *  21 - 30   Field input error (Reverse Display)
      *  90        View mode (Protect input fields)
      *  91        Change mode (Protect key)
      *  97        Always ON (Used for SFLEND Keyword)
      *  98        Error on screen (Sound buzzer)
      *  99        Universal record indicator (Very temporary usage)
      *
      *----------------------------------------------------------------
      *  File Specs
      *
     Fuistuffit uf   e           k disk
     Fwarehs    if   e           k disk
     Fui351pr   o    e             printer  oflind(*in90)

     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

      *----------------------------------------------------------------
      *  Variables
      *
     D $pwhse          S              3  0
     D $perm           S             50
     D $pcmd           S              8
     D $pwhdp          S              5
     D $pwhsea         S              3
     D $padj           S              1
     D forever         S              1
     D error           s               n
     D savever#        s                   like($slver#)
     D ISODate         s               D   DatFmt(*ISO) Inz
     D USADate         s               D   DatFmt(*USA) Inz

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
410 AD slotds        e ds                  extname(slot)
510aA*----------------------------------------------------------------
510aA*  Customer id
510aA*----------------------------------------------------------------

510aA /copy qcopysrc,id#packers

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50

      *----------------------------------------------------------------
      *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $pwhsea
     C                   parm                    $pwhdp
     C                   parm                    $padj
     C                   parm                    $pcmd
     C                   parm                    $perm
      *----------------------------------------------------------------
      *  Main line

     C     fileky        setll     uistuffit
     C                   dou       %eof(uistuffit)
     C     fileky        reade     uistuffit
     C                   if        not %eof(uistuffit)

     C   90              write     head1
     C   90              write     head2
     C   90              write     columns
     C                   write     detail1

     C                   if        $padj = 'Y' and usuadj <> 'Y'
     C                                         and usucnt <> usstk1
     C                   exsr      zzcrtadj
     C                   endif

     C                   endif
     C                   enddo

     C                   eval      $pcmd = '*OK'
     C                   eval      $perm = 'Tran notes printed successfully'

     C                   eval      *inlr = *on

      *----------------------------------------------------------------
      *
      *  ZZCRTADJ  Creat an inventory Adjustment

     C     zzcrtadj      begsr
     C                   move      *off          error

     *   Fill interface data structure fields.

     C                   exsr      fill$adj

     *   Call interface to do update.

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   if        error = *off
     C                   eval      usuadj = 'Y'
     C                   update    uistuf
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  fill$adj   Fill $slot data structure fields for adjustment.
     *----------------------------------------------------------------

     C     fill$adj      begsr

     *  Initialize data structure

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = usudsp

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = usuitm

     C                   eval      $saqtyu  = *on
     C                   eval      $saqty1  = usucnt - usstk1
     C                   eval      $saqty2  = *zeros
     C                   eval      $saqty3  = *zeros

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = *zeros

     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = 'UC'

     C                   eval      $samemou = *on
     C                   eval      $samemo  = *blanks

417 AC                   eval      $sabyu   = *on
417 AC                   eval      $saby    = #user

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
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
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   endsl

     C     enddricop     endsr

      *----------------------------------------------------------------
      *
      *  ZZINZ    Extra program initialization. Called from *INZSR.

     C     zzinz         begsr

      *  Define full key for detail file.

     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp

      *   Get warehouse description.

     C                   move      $pwhsea       $pwhse
     C                   eval      whdesc = *blanks
     C     $pwhse        chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = 'Not Found'
     C                   endif

     C                   write     head1
     C                   write     head2
     C                   write     columns

     C                   endsr

      *----------------------------------------------------------------
      *
      *  *INZSR  Initialization subrotine
      *
     C     *inzsr        begsr
      *
      *  Initialize message handling
      *
     C                   exsr      zzinz
     C                   endsr
      *----------------------------------------------------------------
