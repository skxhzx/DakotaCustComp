      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  APTFTPCMD  Send command to APTFTP
     *  November 9, 2011
     *  Rod Roller
     *
     *  Revisions
     *
     *    11/09/11  RTR  LED
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Data Queue Variables
     *----------------------------------------------------------------

     D  dqdata         s            128
     D  dqlen          s              5  0
     D  dqlib          s             10    inz('*LIBL')
     D  dqname         s             10    inz('APTDTAQ')
     D  dqwaitsec      s              5  0 inz(600)

     D $qdata          ds
     D  $qcmd                  1      8
     D  $qwaitsec              9     13
     D  $qfilename             9     38
     D  $qend                128    128

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pparm           30
     C                   parm                    $plib            10

     C                   clear                   $qdata
     C                   eval      $qcmd = $pcmd
     C                   eval      $qfilename = $pparm
     C                   eval      dqdata = $qdata
     C                   eval      dqlen = %len(%trimr(dqdata))

     C                   call      'QSNDDTAQ'
     C                   parm                    dqname
     C                   parm                    $plib
     C                   parm                    dqlen
     C                   parm                    dqdata

     C                   eval      *inlr = *on
