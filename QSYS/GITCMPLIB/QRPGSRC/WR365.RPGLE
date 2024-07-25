     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  WR365     FTP Import Repack Templates - Post
     *  19 September 2013
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    09/19/13  RTR  6.50
     *      - Created from WR355
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfrepak if   e           k disk
     Fpiritem   if   e           k disk
     Fpiritem3  if   e           k disk    rename(itrec : itrec3)
     F                                     prefix(it3)
     Fitemlnk   uf a e           k disk
     Fkititem   uf a e           k disk
     Fkitcomp   uf a e           k disk
     Fslot2     if   e           k disk    rename(slrec : slrec2)
     Fwarehs    if   e           k disk
     Fbfclog    uf a e           k disk
     Fwr365pr   o    e             printer oflind(*in91)
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
     *  Standard variables and constants
     *
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Program info data structure
     *
      /copy qcopysrc,c#pgminfds
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
     D first           s              1
     D forevr          s              1
     D len             s              1  0
     D linppg          s              3  0
     D pflag           s              1
     D pos             s              1  0
     D today           s              8  0
     D work3a          s              3
     D debugflag       s            117a
     D optype          s              8a
     D oppos           s              3a
     D oplen           s              3a
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
     * Whip through all the repack records.
     *
     C                   eval      first = *on
     C                   eval      pflag = *on
     C                   eval      eofi = *off
     C                   eval      linppg = 55
     C                   eval      count = 0
     *
     C                   dou       eofi = *on
     *
     C                   read      impfrepak
     C                   eval      error = *off
     C                   if        %eof(impfrepak)
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
     C                   if        debugflag = 'Y'
     C                   write     detail
     C                   add       1             count
     C                   endif
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
     C                   eval      blgtype = '*DEBUG'
     C                   eval      blgtext = 'Invalid item numbers: '
     C                                     + %char(noitem)
     C                   exsr      WrtDebug
     C                   eval      blgtype = '*DEBUG'
     C                   eval      blgtext = 'Item not a repack item: '
     C                                     + %char(rpkerr)
     C                   exsr      WrtDebug
     C                   eval      blgtype = '*DEBUG'
     C                   eval      blgtext = 'Repacks Updated: ' + %char(grdlin)
     C                   exsr      WrtDebug
     C                   eval      blgtype = '*DEBUG'
     C                   eval      blgtext = 'Records Read: '
     C                                     + %char(noitem + rpkerr + grdlin)
     C                   exsr      WrtDebug
     C                   eval      blgtype = '*END  '
     C                   eval      blgtext = 'Repack Import is complete.'
     C                   exsr      WrtDebug
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
     C                   kfld                    rtwhs
     C                   kfld                    rtitem
     *
     *  Define key for PIRITEM3 file.
     *
     C     key3it        klist
     C                   kfld                    rtpitm
     C                   kfld                    rtwhs
     *
     *  Define key for ITEMLNK file.
     *
     C     keykit        klist
     C                   kfld                    rtwhs
     C                   kfld                    rtitem
     C                   kfld                    rtpitm
     *
     *  Define key for SLOT2 file.
     *
     C     key2sl        klist
     C                   kfld                    rtwhs
     C                   kfld                    itwhdp
     C                   kfld                    rtirps
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
     C                   eval      blgtype = '*START'
     C                   eval      blgtext = 'Starting Repack Import.'
     C                   exsr      WrtDebug
     *
     *  Get debug flag from option record.
     *
     C                   call      'GETOPTIONS'
     C                   parm                    $pwhs
     C                   parm      '*DBGINTF'    optype
     C                   parm      '005'         oppos
     C                   parm      '001'         oplen
     C                   parm                    debugflag
     *
     C                   endsr

     *----------------------------------------------------------------
     *  WrtDebug  Write out debug record

      /free
        begsr WrtDebug;

          blgstrts = %timestamp();
          blgaddts = %timestamp();
          blgaddpgm = #pgm;
          blgaddcusr = #curruser;
          blgaddjusr = #user;
          blgaddjob = #job;
          blgaddnbr = #jobnbr;

          write(e) blgrec;

          blgtype = *blanks;
          blgtext = *blanks;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZCHKI   Item update error checking.
     *
     C     zzchki        begsr
     C                   eval      error = *off
     *
     *  Verify Repack item number sent.
     *
     C                   if           rtitem = *blanks
     C                             or rtpitm = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   goto      endcki
     C                   endif
     *
     C                   if        rtitem <> *blanks
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
     C                   if        rtpitm <> *blanks
     C     key3it        chain     piritem3
     C                   select
     C                   when      not %found(piritem3)
     C                   eval      detmsg = desc(5)
     C                   add       1             noitem
     C                   goto      endcki
     *
     *  Verify parent item sent is a Normal item.
     *
     C*                  when          %found(piritem3)
     C*                            and it3ittype <> ' '
     C*                  eval      error = *on
     C*                  eval      detmsg = desc(6)
     C*                  add       1             rpkerr
     C*                  goto      endcki
     C                   endsl
     C                   endif
     *
     *  Verify Repack item slot.
     *
     C*    key2sl        chain (n) slot2
     C*                  if           not %found(slot2)
     C*                            or rtirps = ' '
     C*                            or (slitem <> rtpitm
     C*                            and slitem > ' '
     C*                            and slitem <> rtitem)
     C*                            and slitem > ' '
     C*                  eval      error = *on
     *
     C*                  select
     C*                  when      not %found(slot2)
     C*                            or rtirps = ' '
     C*                  eval      detmsg = desc(3)
     *
     C*                  when          slitem <> rtpitm
     C*                            and slitem > ' '
     C*                            and slitem <> rtitem
     C*                            and slitem > ' '
     C*                  eval      detmsg = desc(7)
     C*                  endsl
     *
     C*                  add       1             slterr
     C*                  goto      endcki
     C*                  endif
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
     C     rtwhs         chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      rtwhs         work3a
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
     *  ZZUPD    Update Repack Info.
     *
     C     zzupd         begsr
     *
     C     keyit         chain     kititem
     C                   select
     C                   when      not %found(kititem)
     C                   eval      kiwhse = rtwhs
     C                   eval      kiitem = rtitem
     C                   eval      kirptp = rtrtyp
     C                   eval      kidisp = rtirps
     C                   eval      kiqty1 = rtqm1
     C                   eval      kiqty2 = rtqm2
     C                   eval      kiqty3 = rtqm3
     C                   write     kirec
     *
     C                   other
     C                   eval      kirptp = rtrtyp
     C                   eval      kidisp = rtirps
     C                   eval      kiqty1 = rtqm1
     C                   eval      kiqty2 = rtqm2
     C                   eval      kiqty3 = rtqm3
     C                   update    kirec
     C                   endsl
     *
     C     keykit        chain     kitcomp
     C                   select
     C                   when      not %found(kitcomp)
     C                   eval      kcwhse = rtwhs
     C                   eval      kcitem = rtitem
     C                   eval      kccitm = rtpitm
     C                   eval      kcdisp = rtprps
     C                   eval      kcqty1 = rtpqm1
     C                   eval      kcqty2 = rtpqm2
     C                   eval      kcqty3 = rtpqm3
     C                   write     kcrec
     *
     C                   other
     C                   eval      kccitm = rtpitm
     C                   eval      kcdisp = rtprps
     C                   eval      kcqty1 = rtpqm1
     C                   eval      kcqty2 = rtpqm2
     C                   eval      kcqty3 = rtpqm3
     C                   update    kcrec
     C                   endsl
     *
     C     keykit        chain     itemlnk
     C                   select
     C                   when      not %found(itemlnk)
     C                   eval      ilwhse = rtwhs
     C                   eval      ilitem = rtitem
     C                   eval      ilitm2 = rtpitm
     C                   eval      ilitm3 = *blanks
     C                   write     ilrec
     *
     C                   other
     C                   eval      ilitm2 = rtpitm
     C                   eval      ilitm3 = *blanks
     C                   update    ilrec
     C                   endsl
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
     *-------------------------------------------------------------------------
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
FTP Import Repack Template Setup
