700aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  II255     Import FTP Total Quantity Ordered by Item - Post
     *  30 March 2000
     *  Max Blacknik
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
413 A*    03/30/00  DAS  4.13
     *      - Created
     *
414aA*    07/07/00  MLB  4.14a
     *      - Re-compiled. Fields added to ITEMORD.
     *      - Revised ZZUPD to update ITEMORD with host qty onhand.
     *
530 A*    11/04/10  MLB  5.30
     *      - Fix: Revised program to send $PWHS to II245B if
     *        indicator FIRST still on meaning that no records
     *        were read from the import file. The will ensure
     *        that II245B is called even if no records in the
     *        import file.
     *
650aA*    01/19/15  MLB  6.50a
     *      - Fix: Revised pgm to store on-rder qty for type S and type A
     *        items in base item. On-order quantities will be converted
     *        accordingly.
     *      - Added ITEMLNK, PIRITEM3 to pgm.
     *
700a *    12/28/15  RTR  7.00a
     *      - Enh: Converted to ILE RPG.
     *      - Enh: Added Client logic.
     *
700b *    06/11/16  DAS  7.00b
     *      - Enh: Added *EACH logic.
     *
730  *    11/04/19  KDE  7.30
     *      - Enh: Added extension file for ITEMORD.  ITEMORDEXA allows
     *        for customer to send breakdown one quantities as order quantities
     *        Originally for Chefs Droppick process.  Also add change for
     *        IMPSITMO to have additonal field for breakdown quantity
740  *    05/07/20  KDE  7.40
     *      - Enh: Changed to use EXITEMORD for I/O to ITEMORDEX instead of
     *        doing direct i/o
     *      - Enh: Subtract breakdown quantity from case quantity for normal items
     *        Max added nearest case quantity in HII250.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S.Bertram
     *
SBRa *    12/28/15  RTR  SBR
     *      - Check/Fix warehouse.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for IMPITEM
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
700bA*  *EACH Notes
     *
     *     Instead of changing the files to include breakdown qtys, it
     *     was decided to create an extra record where '*EACH' was
     *     appended to the item number, like '123456*EACH'. Therefore,
     *     the Host system will need to send such an item in order
     *     to tell Dakota how many eaches were ordered so a
     *     priority replenishment can be generated.
     *
     *----------------------------------------------------------------

     * File Specs
     *
     Fimpfitmo  if   e           k disk
650aAFitemlnk   if   e           k disk
     Fitemord   uf a e           k disk
     Fpiritem   if   e           k disk
650aAFpiritem3  if   e           k disk    rename(itrec : itrec3)
650aAf                                     prefix(i3)
     Fwarehs    if   e           k disk
     Fii255pr   o    e             printer oflind(*in91)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             30    dim(2) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Variables
650 A*
650aAD basefound       s               n   inz('0')
     D $plen           s              3  0
     D $pstr           s             60
     D $pwhse          s              3  0
     D count           s              3  0                                      LINE COUNTER
700bAD eachPos         s              3  0
     D eofi            s              1
740 DD*error           s              1
     D first           s              1
     D forevr          s              1
     D impdte          s              8  0
     D imptim          s              6  0
700bAD kyitem          s                   like(ititem)
     D len             s              1  0
     D linppg          s              3  0                                      MAX LINES PER PAGE
     D pflag           s              1
     D pos             s              1  0
     D today           s              8  0
650aAD rem             s              9  3
740 AD remf            s              7  0
740 AD div             s              7  0
650aAD wkqty           s                    like(iitqo)
     D work3a          s              3
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
700aA*----------------------------------------------------------------
700aA*  Customer id
700aA*
700aAD @getcl          c                   const('GETCLIENT')
700aA*
700aA /copy qcopysrc,id#sbr
700aA*
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

740 A*----------------------------------------------------------------
740 A*  Standard SQL variables and constants
740 A*----------------------------------------------------------------
740 A
740 A /copy qcopysrc,c#stdsql
740 A /COPY *libl/qcopysrc,p.exitemor
740 A /COPY *libl/qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PWHSE  Warehouse to process.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     *----------------------------------------------------------------
     * Main line
     *
     * Whip through all the download Total qty ordered records.
     *
     C                   eval      first = *on
     C                   eval      pflag = *on
     C                   eval      eofi = *off
     C                   eval      linppg = 55                                  MAX LINES PER PAGE
     C                   eval      count = 0                                    LINE COUNTER
     C                   dou       eofi = *on
     *
     C                   read      impfitmo                               79
     C                   eval      error = *off
     C                   if        *in79
530 A*
530 A*    Delete existing records when no import rcds read.
530 AC                   if        first = *on
530 AC                   call      'II245B'
530 AC                   parm                    $pwhs
530 AC                   endif
530 A*
     C                   eval      eofi = *on
     C                   goto      enddij
     C                   endif
     *
     *    Frist time through, delete existing records for warehouse.
     *
     *       Note: It is assumed that the file contains records
     *             for a single warehouse.
     *
     C                   if        first = *on
SBRaAC                   monitor
     C                   eval      $pwhse = ijwhse
SBRaAC                   on-error
     C                   eval      $pwhse = 1
SBRaAC                   endmon
     C                   move      ijwhse        $pwhs
     C                   exsr      zzinz2
     C                   call      'II245B'
     C                   parm                    $pwhs
     C                   eval      first = *off
     C                   endif
     *
     *    Error check for update/add.
     *
     C                   exsr      zzchki
     *
     C                   if        error = *off
650aA*
650aAC                   if           ittype = 'S'
650aAC                             or ittype = 'A'
650aA*      Convert SSB & Alias items to Baseitem for *ORDQTY
650aA*      Replenishments processing.
650aAC                   exsr      zzgetbaseitem
650aAC                   if        basefound
650aAC                   eval      ijitem = ilitm2
650aAC                   if           ittype = 'S'
650aAC                             or i3ittype = 'S'
650aAC                   exsr      zzcvtqty
650aAC                   endif
650aA*
650aAC                   endif
650aA*
650aAC                   endif
650aA*
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
     C     enddij        tag
     C                   enddo
     *
     *  Print record error grand totals.
     *
     C                   if        noitem > *zeros
     C                   if        count >= linppg
     C                   write     head1
     C                   endif
     C                   write     grndttl
     C                   endif
     *
     *  We are finished so get out.
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     * Key definitions
650aA*
650aA* ITEMLINK Partial file key
650aA*
650aAc     keyil         klist
650aAc                   kfld                    ijwhse
650aAc                   kfld                    ijitem
650aA*
650aA* ITEMLINK Partial file key
650aA*
650aAc     keyilalias    klist
650aAc                   kfld                    ijwhse
650aAc                   kfld                    i3ititem
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    ijwhse
700bMC                   kfld                    kyitem
700bDC**                 kfld                    ijitem
650aA*
650aA* Define key for PIRITEM3 file
650aA*
650aAc     keyit3        klist
650aAc                   kfld                    ilitm2
650aAc                   kfld                    ijwhse
700aA*
700aA* Get client id.
700aA*
700aAC                   call      @getcl
700aAC                   parm                    client           10
700aAC                   parm                    cliloc           10
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
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKI   Item update error checking.
     *
     C     zzchki        begsr
     C                   eval      error = *off
     *
     *  Check and fix warehouse.
     *
SBRaAC                   if        client = sbertram
SBRaAC                   monitor
SBRaAC                   eval      $pwhse = ijwhse
SBRaAC                   on-error
SBRaAC                   eval      $pwhse = 1
SBRaAC                   eval      ijwhse = 1
SBRaAC                   endmon
SBRaAC                   endif
     *
700bM*  Item cannot be blank
     *
     C                   if        ijitem = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   goto      endcki
     C                   endif
700bA*
700bA*  Look for *EACH item
700bA*    We will assume if we find '*E' it is attached to '*EACH'.
700bA*    This will help to eliminate the possibility '*EACH' gets chopped off
700bA*    because of an extra lone item number.
700bA*
700bAC                   eval      eachPos = %scan('*E': ijitem)
700bAC                   if        eachPos > 0
700bAC                   eval      kyitem = %subst(ijitem: 1: eachPos-1)
700bAC                   else
700bAC                   eval      kyitem = ijitem
700bAC                   endif
700bA*
700bA*  Verify item exists
     *
700bDC**                 if        ijitem <> *blanks
     C     keyit         chain     piritem                            78
     C                   if        *in78
     C                   eval      itwhdp = *blanks
     C                   eval      itpdsc = *blanks
     C                   eval      itdesc = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(1)
     C                   add       1             noitem
     C                   goto      endcki
     C                   endif
700bDC**                 endif
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
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     rdsc(1)       $pstr
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             77
     C                   if        *in77
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      $pwhse        work3a
     C     ' 0'          check     work3a        pos
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
650aA*
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZCVTQTY    Convert quantity for SSB items.
650aA*
650aAC     zzcvtqty      begsr
650aA*
650aAC                   if        i3itumq2 > 0
650aA*      Convert eaches into case units.
650aAC     ijtqo         div       i3itumq2      wkqty
650aAC                   mvr                     rem
650aAC                   eval      ijtqo = wkqty
650aA*      Add 1 if any remainder to for additional case of demand.
650aAC                   if        rem > 0
650aAC                   eval      ijtqo = ijtqo + 1
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   endsr
650aA*
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZGETBASEITEM    Retrieve base item for SSB or Alias item.
650aA*
650aAC     zzgetbaseitem begsr
650aA*
650aAc                   eval      basefound = *off
650aAc     keyil         chain     itemLnk
650aAc                   if        not %found(itemLnk)
650aAc                   eval      ilitm2  = ' '
650aAc                   eval      ilitm3  = ' '
650aAc                   else
650aAc                   eval      basefound = '1'
650aAc                   endif
650aA*
650aAc                   if            basefound = '1'
650aAc     keyit3        chain     piritem3
650aAC                   if        not %found(piritem3)
650aAc                   eval      basefound = '0'
650aAc                   eval      i3ittype  = ' '
650aAc                   eval      i3itumq2  = 0
650aAc                   endif
650aA*
650aA*      Alias item linked to SSB item. Retrieve parent for SSB.
650aAC                   if        i3ittype = 'S'
650aA*      Retrieve parent for SSB of Alias item.
650aAc     keyilalias    chain     itemLnk
650aAc                   if        not %found(itemLnk)
650aAc                   eval      ilitm2    = ' '
650aAc                   eval      ilitm3    = ' '
650aAc                   eval      i3itumq2  = 0
650aAc                   eval      basefound = '0'
650aAc                   endif
650aA*
650aAc                   endif
650aA*
650aAc                   endif
650aA*
650aAC                   endsr
650aA*
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update Total Quantity Ordered for Item.
     *
     C     zzupd         begsr
     *

740 A /free
740 A      // for Normal Items back out breakdown quantity from case quantity
740 A      if itumq2 <> 0 and ittype=' ';
740 A        if ijbd1 <> 0 and ijbd1 < itumq2;
740 A          ijtqo = ijtqo - 1;
740 A        else;
740 A          div = (ijbd1 / itumq2);
740 A          remf = (ijbd1 / itumq2);
740 A          if remf > 0;
740 A            div = div + 1;
740 A          endif;
740 A          ijtqo = ijtqo - div;
740 A        endif;
740 A        if ijtqo < 0;
740 A          ijtqo = 0;
740 A        endif;
740 A      endif;
740 A /end-free

700bAC                   eval      kyitem = ijitem
     C     keyit         chain     itemord                            76
     C                   select
     C                   when      *in76
     C                   eval      iiwhse = ijwhse
     C                   eval      iiitem = ijitem
     C                   eval      iiwhdp = itwhdp
     C                   eval      iitqo = ijtqo
     C                   eval      iiidte = impdte
     C                   eval      iiitim = imptim
414aAC                   eval      iiqyoh = ijqyoh
     C                   write     iirec
     *
     C                   other
     C                   eval      iiwhdp = itwhdp
650aDC*                  eval      iitqo = ijtqo
650aMC                   eval      iitqo  = iitqo + ijtqo
     C                   eval      iiidte = impdte
     C                   eval      iiitim = imptim
414aAC                   eval      iiqyoh = ijqyoh
     C                   update    iirec
     C                   endsl
730 A*
730 A*    Accumulate breakdown quantity ordered per item
730 A*
740 A /free
740 A      exWhse = ijwhse;
740 A      ioeitm = kyitem;
740 A      exitemord ('*GET': exRtnCode: exRtnMsg: exWhse: ioeitm:
740 A                   ioebd1);
740 A      if exRtnCode = '*ERROR';
740 A        ioewhs = ijwhse;
740 A        ioeitm = kyitem;
740 A        ioebd1 = ijbd1;
740 A        exWhse = ijwhse;
740 A        exitemord ('*ADD': exRtnCode: exRtnMsg: exWhse: ioeitm:
740 A                     ioebd1);
740 A      else;
740 A        ioeitm = kyitem;
740 A        ioebd1  = ioebd1 + ijbd1;
740 A        exWhse = ijwhse;
740 A        exitemord ('*CHANGE': exRtnCode: exRtnMsg: exWhse: ioeitm:
740 A                     ioebd1);
740 A      endif;
740 A /end-free
     *
     *    Accumulate total number of records processed.
     *
     C                   add       1             grdlin
     C     endupd        endsr
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
**
Import FTP Order Quantities by Item
