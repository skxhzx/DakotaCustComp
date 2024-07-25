     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  WR255     FTP Import Repack Item Demand - Post
     *  16 September 2010
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
530 A*    09/16/10  MLB  5.30
     *      - Created
530aA*    09/30/10  MLB  5.30a
     *      - Enh: Revised program to set DRSTAT to 0=Open
     *        creating records in RPKDEMD file.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfrpkdm if   e           k disk
     Frpkdemd   uf a e           k disk
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
     Fwr255pr   o    e             printer oflind(*in91)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             30    dim(4) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Working variable(s)
     *
     D currstamp       s               z
     D $plen           s              3  0
     D $pstr           s             60
     D $pwhs           s              3
     D $pwhse          s              3  0
     D count           s              3  0
     D eofi            s              1
     D error           s              1
     D first           s              1
     D forevr          s              1
     D len             s              1  0
     D linppg          s              3  0
     D pflag           s              1
     D pos             s              1  0
     D today           s              8  0
     D work3a          s              3
     *
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     *
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
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     * Main line
     *
     * Whip through all the download Total qty ordered records.
     *
     C                   eval      first = *on
     C                   eval      pflag = *on
     C                   eval      eofi = *off
     C                   eval      linppg = 55
     C                   eval      count = 0
     *
     C                   dou       eofi = *on
     *
     C                   read      impfrpkdm
     C                   eval      error = *off
     C                   if        %eof(impfrpkdm)
     C                   eval      eofi = *on
     C                   iter
     C                   endif
     *
     *    Frist time through, delete existing records for warehouse.
     *
     *       Note: It is assumed that the file contains records
     *             for a single warehouse.
     *
     C                   if        first = *on
     C                   eval      $pwhse = rdiwhs
     C                   move      rdiwhs        $pwhs
     C                   exsr      zzinz2
     C                   call      'WR254'
     C                   parm                    $pwhs
     C                   eval      first = *off
     C                   endif
     *
     *    Error check for update/add.
     *
     C                   exsr      zzchki
     *
     C                   if        error = *off
     C                   exsr      zzupd
     C                   endif
     *
     C                   if        error = *on
     *
     *  Print report heading if necessary.
     *
     C                   if        pflag = *on  or
     C                             count >= linppg
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   eval      pflag = *off
     C                   endif
     *
     C                   write     detail
     C                   add       1             count
     C                   endif
     *
     C                   enddo
     *
     *  Print record error grand totals.
     *
     C                   if        noitem > *zeros
     C                   if        count >= linppg
     C                   write     head1
     C                   endif
     C                   write     grndttl                              91
     C                   if        *in91 = '1'
     C                   write     head1                                91
     C                   endif
     C                   write     foot1
     C                   endif
     *
     *  We are finished so get out.
     *
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
     * Key definitions
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    rdiwhs
     C                   kfld                    rdiitm
     *
     *  Define key for RPKDEMD file.
     *
     C     keydr         klist
     C                   kfld                    rdiwhs
     C                   kfld                    rdiitm
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   move      #prog         $lprg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKI   Item update error checking.
     *
     C     zzchki        begsr
     C                   eval      error = *off
     *
     *  Verify Repack item number sent.
     *
     C                   if        rdiitm = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   goto      endcki
     C                   endif
     *
     C                   if        rdiitm <> *blanks
     C     keyit         chain     piritem
     C                   select
     C                   when      not %found(piritem)
     C                   eval      itwhdp = *blanks
     C                   eval      itpdsc = *blanks
     C                   eval      itdesc = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(1)
     C                   add       1             noitem
     C                   goto      endcki
     *
     *  Verify item sent is a Repack item.
     *
     C                   when          %found(piritem)
     C                             and ittype <> 'R'
     C                   eval      error = *on
     C                   eval      detmsg = desc(4)
     C                   add       1             notrpk
     C                   goto      endcki
     C                   endsl
     C                   endif
     *
     *  Verify Repack item demand > zero.
     *
     C                   if        rdirpd <= 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(3)
     C                   add       1             demerr
     C                   goto      endcki
     C                   endif
     *
     C     endcki        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     * Get import date/time.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rdate = $cvd6o
     C                   time                    rtime
     *
     *  et report heading.
     *
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      $pwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   if        pos = 0
     C                   eval      pos = 1
     C                   endif
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     * Initialize grand total fields
     *
     C                   eval      grdlin = *zeros
     C                   eval      noitem = *zeros
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update Repack Item Demand for Item.
     *
     C     zzupd         begsr
     *
     C     keydr         chain     rpkdemd
     C                   select
     C                   when      not %found(rpkdemd)
     C                   eval      drwhse = rdiwhs
     C                   eval      dritem = rdiitm
     C                   eval      drrpkd = rdirpd
     C                   time                    currstamp
     C                   eval      dradts = currstamp
530aAC                   eval      drstat = '0'
     C                   write     drrec
     *
     C                   other
     C                   eval      drrpkd = rdirpd
     C                   time                    currstamp
     C                   eval      dradts = currstamp
530aAC                   eval      drstat = '0'
     C                   update    drrec
     C                   endsl
     C*
     C*    Accumulate total number of records processed.
     C*
     C                   add       1             grdlin
     C     endupd        endsr
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZRHEAD   Print report headings.
     C*
     C     zrhead        begsr
     C*
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   setoff                                       81
     C                   endif
     C*
     C                   endsr
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
* Invalid item
* Item number cannot be blank
* Repack item demand <= zero
* Item sent not a Repack Item
**
FTP Import Repack Item Demand
