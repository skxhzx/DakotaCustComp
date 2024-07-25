     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  WR355     FTP Import JIT Repack Item Slot Setup - Post
     *  20 April 2013
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    04/20/13  MLB  6.50
     *      - Created
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfrepak2if   e           k disk
     Fpiritem   if   e           k disk
     Fpiritem3  if   e           k disk    rename(itrec : itrec3)
     F                                     prefix(it3)
     Fitemfld   uf a e           k disk
     Fslot2     uf   e           k disk    rename(slrec : slrec2)
     Fwarehs    if   e           k disk
     Fwr355pr   o    e             printer oflind(*in91)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             30    dim(7) ctdata perrcd(1)
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
     * Whip through all the JIT Repack Slot Item Setup records.
     *
     C                   eval      first = *on
     C                   eval      pflag = *on
     C                   eval      eofi = *off
     C                   eval      linppg = 55
     C                   eval      count = 0
     *
     C                   dou       eofi = *on
     *
     C                   read      impfrepak2
     C                   eval      error = *off
     C                   if        %eof(impfrepak2)
     C                   eval      eofi = *on
     C                   iter
     C                   endif
     *
     *       Note: It is assumed that the file contains records
     *             for a single warehouse.
     *
     C                   if        first = *on
     C                   exsr      zzinz2
     *
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
     C                   if        first = '1'
     *      Generate report headings, warehouse desc. setup.
     C                   exsr      zzinz2
     C                   endif
     *
     C                   if        noitem > *zeros
     C                             or rpkerr > *zeros
     C                             or slterr > *zeros
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
     C                   kfld                    jiwhse
     C                   kfld                    jiitem
     *
     *  Define key for PIRITEM3 file.
     *
     C     key3it        klist
     C                   kfld                    jiitmp
     C                   kfld                    jiwhse
     *
     *  Define key for ITEMFLD file.
     *
     C     keyif         klist
     C                   kfld                    jiwhse
     C                   kfld                    jiitem
     *
     *  Define key for SLOT2 file.
     *
     C     key2sl        klist
     C                   kfld                    jiwhse
     C                   kfld                    itwhdp
     C                   kfld                    jidisp
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
     C                   if           jiitem = *blanks
     C                             or jiitmp = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   goto      endcki
     C                   endif
     *
     C                   if        jiitem <> *blanks
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
     C                   add       1             rpkerr
     C                   goto      endcki
     C                   endsl
     C                   endif
     *
     C                   if        jiitmp <> *blanks
     C     key3it        chain     piritem3
     C                   select
     C                   when      not %found(piritem3)
     C                   eval      detmsg = desc(5)
     C                   add       1             noitem
     C                   goto      endcki
     *
     *  Verify parent item sent is a Normal item.
     *
     C                   when          %found(piritem3)
     C                             and it3ittype <> ' '
     C                   eval      error = *on
     C                   eval      detmsg = desc(6)
     C                   add       1             rpkerr
     C                   goto      endcki
     C                   endsl
     C                   endif
     *
     *  Verify JIT Repack item slot.
     *
     C     key2sl        chain (n) slot2
     C                   if           not %found(slot2)
     C                             or jidisp = ' '
     C                             or (slitem <> jiitmp
     C                             and slitem > ' '
     C                             and slitem <> jiitem)
     C                             and slitem > ' '
     C                   eval      error = *on
     *
     C                   select
     C                   when      not %found(slot2)
     C                             or jidisp = ' '
     C                   eval      detmsg = desc(3)
     *
     C                   when          slitem <> jiitmp
     C                             and slitem > ' '
     C                             and slitem <> jiitem
     C                             and slitem > ' '
     C                   eval      detmsg = desc(7)
     C                   endsl
     *
     C                   add       1             slterr
     C                   goto      endcki
     C                   endif
     *
     C     endcki        endsr
     *
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
     * Get report heading.
     *
     C                   eval      $pstr = rdsc(1)
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     jiwhse        chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      jiwhse        work3a
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
     *  ZZUPD    Update JIT Repack Slot Info.
     *
     C     zzupd         begsr
     *
     C     keyif         chain     itemfld
     C                   select
     C                   when      not %found(itemfld)
     C                   eval      ifwhse = jiwhse
     C                   eval      ifitem = jiitem
     C                   eval      ifcat     = ' '
     C                   eval      ifcaseovf = 'N'
     C                   eval      ifodrslot = ' '
     C                   eval      ifucicde  = '1'
     C                   eval      ifrcvmth  = '1'
     C                   eval      ifsltmth  = '1'
     C                   eval      ifbrdflg  = 'N'
     C                   eval      ifodrslot  = jidisp
     C                   write     ifrec
     *
     C                   other
     C                   eval      ifodrslot = jidisp
     C                   update    ifrec
     C                   endsl
     *
     C     key2sl        chain     slot2
     C                   if        %found(slot2)
     C                             and (slitem = ' '
     C                               or slitem = jiitem)
     C                   eval      slitem = jiitmp
     C                   eval      slstat = jistat
     C                   eval      slsdte = today
     C                   eval      slstim = rtime
     C                   update    slrec2
     C                   else
     C                   unlock    slot2
     C                   endif
     *
     *    Accumulate total number of records processed.
     *
     C                   add       1             grdlin
     *
     C     endupd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
* Invalid item
* Item number cannot be blank
* Repack slot not found
* Item sent not a Repack Item
* Invalid parent item
* Parent Item sent not a Normal Item
* Repack slot has wrong item
**
FTP Import JIT Repack Item Slot Setup
