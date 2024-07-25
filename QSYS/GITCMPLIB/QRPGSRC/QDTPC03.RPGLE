     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDTPC03   Q&D - Remove deleted items from SLOT file.
     *  01 November 2007
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    11/01/07  MLB 5.10
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

     Fpiritem   if   e           k disk
     Fslot      uf   e             disk

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
     C     1             setll     slot
     C                   dow       forevr = forevr
     *
     C                   read      slot
     C                   if        %eof(slot)
     C                   leave
     C                   endif
     C                   if        slitem = ' '
     C                   iter
     C                   endif
     *
     *  Get pick slot record.
     *
     C     keyit         setll     piritem                                50
     C                   if        *in50 = *off
     C                   eval      slstat = 'Z '
     C                   eval      slitem = ' '
     C                   update    slrec
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
     C     keyit         klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
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
