      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  GAPLBL   Create GAP recs for LABEL
     *  04 April 2008
     *  Dave Sommerville
     *
     *  Revisions
     *
520 A*    04/04/08  DAS  5.20
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fworklbl   ip   e           k disk
     Fgap       o    e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

510bAD first           s               n   inz(*on)
     D lastNum         s              7  0

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   if        first
     C                   eval      first = *off
     C                   eval      gapFile = 'WORKLBL'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      'CVTDTE'
     C                   parm                    $cvtdt
     C                   eval      gapDate = $cvd8o
     C                   time                    gapTime
     C                   eval      lastNum = 0
     C                   endif

     C                   if        lwlbl# - lastNum > 1
     C                   eval      gapStart = lastNum + 1
     C                   eval      gapEnd   = lwlbl# - 1
     C                   eval      gapRecs  = lwlbl# - lastNum - 1
     C                   write(e)  gaprec
     C                   endif

     C                   eval      lastNum = lwlbl#

     CLR                 if        9999999 - lastNum > 1
     CLR                 eval      gapStart = lastNum + 1
     CLR                 eval      gapEnd   = 9999999
     CLR                 eval      gapRecs  = 9999999 - lastNum - 1
     CLR                 write(e)  gaprec
     CLR                 endif
