      *----------------------------------------------------------------
      *   Copyright (C) 1996 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   799 Roosevelt Rd.  Bldg 6, Suite 108
      *   Glen Ellyn, IL  60137
      *   (708) 790-8383
      *----------------------------------------------------------------
      *
      *  CW135 - UCI Catch Weight verification
      *  Jeffrey Jahnke
      *  06 November, 2006
      *
      *  Revisions
      *
510 A *    07/17/06  JJ   5.10
      *      - Created.
510aA *    11/28/06  HNK  5.10a
      *      - Changed to verify item is a CW item.
      *
      *----------------------------------------------------------------
      *  Notes
      *
      *----------------------------------------------------------------
      *  File Specs
      *
     Fpodtl1    if   e           k disk
     Fucicw8    if   e           k disk
510a Fpiritem   if   e           k disk

      *----------------------------------------------------------------
      *  Program parameters

     D $parms          DS
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

      *   Redefine key

     D  $pwhse                19     21  0
     D  $po                   22     30

      *----------------------------------------------------------------
      *  Variables

     D rcount          S              5  0
     D ucount          S              5  0
     D svitem          S             15
     D forever         S              1

      *----------------------------------------------------------------
      *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $parms

      *----------------------------------------------------------------
      *  Main line

     C     pokey         setll     podtl1
     C                   dow       forever = forever
     C     pokey         reade     podtl1
     C                   if        %eof(podtl1) or $prtn <> *blanks
     C                   leave
     C                   endif

510a C     itkey         chain     piritem                            79
510a C                   if        *in79=*on
510a C                   iter
510a C                   endif

510a C                   if        *in79=*off and itcwgt<>'Y'
510a C                   iter
510a C                   endif

     C                   if        pditem <> svitem
     C                   exsr      ucicount
     C                   eval      svitem = pditem
     C                   eval      rcount = *zeros
     C                   endif

     C                   eval      rcount = rcount + pdqrc1

     C                   enddo

     C                   eval      *inlr = *on

      *----------------------------------------------------------------
      *  UCICount - Count UCI's for an item

     C     UCICount      begsr

     C                   eval      ucount = *zeros

     C     ucikey        setll     ucicw8
     C                   dow       forever = forever
     C     ucikey        reade     ucicw8
     C                   if        %eof(ucicw8)
     C                   leave
     C                   endif

     C                   eval      ucount = ucount + 1

     C                   enddo

      * Number of UCI's entered must be at least the number of Items received

     C                   if        ucount < rcount
     C                   eval      $prtn = '*ERROR'
     C                   endif

     C                   endsr

      *----------------------------------------------------------------
      *  ZZINZ    Extra program initialization. Called from *INZSR.

     C     zzinz         begsr

      *  Define full key for detail file.

     C     pokey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $po

     C     ucikey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $po
     C                   kfld                    svitem

510a C     itkey         klist
510a C                   kfld                    $pwhse
510a C                   kfld                    pditem

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
     C                   eval      $prtn = *blanks

     C                   endsr
