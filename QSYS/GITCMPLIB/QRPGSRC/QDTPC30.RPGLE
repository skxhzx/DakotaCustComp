     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDTPC30   Q&D - Remove PO header with NO detail lines
     *  06 November 2007
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    11/06/07  RH  5.10
     *      - Created
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fpodtl     if   e           k disk
     Fpohdr     uf   e             disk

     D client          s             10

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D bfcslot         s             10
     D impslot         s             10
     D count           s              3  0
     D error           s              1
     D forevr          s              1
     D len             s              1  0
     D linppg          s              3  0
     D lstwhs          s              3  0
     D pflag           s              1
     D pos             s              1  0
     D work3a          s              3
     D temp6a          s              6

     *----------------------------------------------------------------
     *  Date fields
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')
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
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
     *
     C     1             setll     pohdr
     C                   dow       forevr = forevr
     *
     C                   read      pohdr
     C                   if        %eof(pohdr)
     C                   leave
     C                   endif
     *
     C                   if        phpo>= 'SP0000001' and
     C                             phpo<= 'SP9999999'
     C                   iter
     C                   endif
     *
     *  Get po detail record.
     *
     C     keypd         chain     podtl                              50
     C                   if        *in50 = *on
     C                   delete    phrec
     C                   endif
     *
     C                   enddo
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr

     *  Get client id

     C                   call      'GETCLIENT'
     C                   parm                    client

     C                   eval      error = *off
     *
     * Key definitions
     *
     * PIRITEM file
     *
     C     keypd         klist
     C                   kfld                    phwhse
     C                   kfld                    phpo
     *
     *  Define variables
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
