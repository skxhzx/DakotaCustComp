     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
510 A*  UI300     UCI Code listing
     *  29 August  2006
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
     Fucicw4    if   e           k disk
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Fqsysprt   o    f  132        printer oflind(*inof)

     D                 ds
     D wktime                  1     12  0
     D htime                   1      6  0
     D hdate                   7     12  0

      *----------------------------------------------------------------
      *  Variables
      *
     D #itdesc         S             45
     D forever         S              1
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
     D  $pitem                22     36

      *----------------------------------------------------------------
      *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $parms
      *----------------------------------------------------------------
      *  Main line

     C     key1          setll     ucicw4
     C                   dow       forever = forever
     C     key1          reade     ucicw4
     C                   if        %eof(ucicw4)
     C                   leave
     C                   endif

     C   of              except    header
     C                   except    detail1

     C                   enddo

     C                   eval      *inlr = *on
      *----------------------------------------------------------------
      *
      *  ZZINZ    Extra program initialization. Called from *INZSR.

     C     zzinz         begsr

      *  Define full key for detail file.

     C     key1          klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem

      *   Get warehouse description.

     C                   eval      whdesc = *blanks
     C     $pwhse        chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = 'Not Found'
     C                   endif

      *   Get item description.

     C                   eval      itdesc = *blanks
     C     key1          chain     piritem
     C                   if        %found(piritem)
     C                   eval      #itdesc = %trim($pitem) + ' - ' +
     C                                       %trim(itdesc)
     C                   endif

     C                   time                    wktime
     C                   except    header

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
     Oqsysprt   E            header           03
     O                                            3 'RUN'
     O                       hdate         Y     13
     O                                           66 'Item UCI Codes'
     O                                          111 'TIME'
     O                       HTime              120 '  :  :  '
     O                                          127 'PAGE'
     O                       Page          Z    132

     O          E            header      1
     O                       $pwhse        Z     04
     O                       whdesc              35

     O          E            header      1  1
     O                       #itdesc             46

     O          E            header      1  0
     O                                           11 '__________'
     O                                           27 '_______________'
     O                                           40 '____________'

     O          E            header      0  1
     O                                           11 'UCI Number'
     O                                           27 'License Number '
     O                                           40 'Catch Weight'

     O          E            detail1        1
     O                       ucinbr              11
     O                       ucilcn              27
     O                       uciwgt        k     38
