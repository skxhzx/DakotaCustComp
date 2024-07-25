     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
510 A*  PT650     Transaction error notes print
     *  31 January  2007
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
     *    xx/xx/xx  xxx  x.xx
     *
     *----------------------------------------------------------------
      *----------------------------------------------------------------
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
     Fpterrpf   if   e           k disk
     Fwarehs    if   e           k disk
     Fpt650pr   o    e             printer  oflind(*in90)

      *----------------------------------------------------------------
      *  Variables
      *
     D forever         S              1
     D ISODate         s               D   DatFmt(*ISO) Inz
     D USADate         s               D   DatFmt(*USA) Inz
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $msg#                 22     24

      *----------------------------------------------------------------
      *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $parms
      *----------------------------------------------------------------
      *  Main line

     C     fileky        setll     pterrpf
     C                   dou       %eof(pterrpf)
     C     fileky        reade     pterrpf
     C                   if        not %eof(pterrpf)

     C   90              write     head1
     C   90              write     head2
     C   90              write     columns
     C                   write     detail1

     C                   endif
     C                   enddo

     C                   eval      $pcmd = '*OK'
     C                   eval      $perm = 'Tran notes printed successfully'

     C                   eval      *inlr = *on

      *----------------------------------------------------------------
      *
      *  ZZINZ    Extra program initialization. Called from *INZSR.

     C     zzinz         begsr

      *  Define full key for detail file.

     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $msg#

      *   Get warehouse description.

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
