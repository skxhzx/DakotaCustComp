      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  II255S    Stage - Import FTP Total Qty Ordered by Item - Post
     *  18 Feb 2011
     *  Retha Davis
     *  Cloned from Cheney's II255
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
413 A*    03/30/00  DAS  4.13
     *      - Created
414aA*    07/06/00  MLB  4.14a
     *      - Re-compiled. Fields added to ITEMORD.
     *      - Revised ZZUPD to update ITEMORD with host qty onhand.
640aA*    02/18/11  RBD  6.40a
     *      - Copied from II255.  Converted to ILE.
     *      - Revised to use staging file impsitmo in place of
     *        file impfitmo.
     *
650aA*    01/19/15  MLB  6.50a
     *      - Fix: Revised pgm to store on-rder qty for type S and type A
     *        items in base item. On-order quantities will be converted
     *        accordingly.
     *      - Added ITEMLNK, PIRITEM3 to pgm.
     *
700b *    06/11/16  DAS  7.00b
     *      - Enh: Added *EACH logic.
     *
710 A*    07/25/17  MLB  7.10
     *      - Enh: Revised pgm to call LT110CL to create *ORDQTY replen-
     *        ishments when import is complete just like FTP interface.
720a *    01/09/19  RTR  7.20a
     *      - Enh: Added new parm to LT110CL call.
730  *    11/04/19  KDE  7.30
     *      - Enh: Added extension file for ITEMORD.  ITEMORDEXA allows
     *        for customer to send breakdown one quantities as order quantities
     *        Originally for Chefs Droppick process.  Also add change for
     *        IMPSITMO to have additonal field for breakdown quantity
740  *    05/07/20  KDE  7.40
     *      - Enh: Changed to use EXITEMORD for I/O to ITEMORDEX instead of
     *        doing direct i/o
750a *    12/17/21  RH   7.50a
     *      - add 730a mod missed. 04/05/19  RTR  7.30a
     *      - Enh: Added client processing.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Chefs Custom Mods
     *
DRYaA*    04/08/21  KDE  DRYa
     *      - Enh: Revised to pass along replenishment type from
     *        impsitmo so Drop Pick replenishments only purge
     *        Drop Pick replenishments when ran as Drop Pick only
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic Produce
     *
EOPa *    04/05/19  RTR  EOPa
     *      - Handle breakdown UOMs.
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

     *----------------------------------------------------------------
     * File Specs
     *
640aDF*impfitmo  if   e           k disk
640aMFimpsitmo  uf   e           k disk
650aAFitemlnk   if   e           k disk
     Fitemord   uf a e           k disk
     Fpiritem   if   e           k disk
650aAFpiritem3  if   e           k disk    rename(itrec : itrec3)
650aAf                                     prefix(i3)
     Fwarehs    if   e           k disk
     Fii255pr   o    e             printer oflind(*in91)
730aA*----------------------------------------------------------------
730aA*  Customer id
EOPaA /copy qcopysrc,id#eop
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             30    dim(2) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------
DRYaA /copy qcopysrc,id#dairyla
DRYaAD client          s             10

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
     *----------------------------------------------------------------
     *  Variables
     *
650aAD basefound       s               n   inz('0')
     D $plen           s              3  0
     D $pstr           s             60
640aDD*$pwhse          s              3  0
     D count           s              3  0                                      LINE COUNTER
700bAD eachPos         s              3  0
     D eofi            s              1
640aDD*error           s              1
740 DD*error           s               n
     D first           s              1
     D forevr          s              1
     D impdte          s              8  0
640aAD importError     s               n
     D imptim          s              6  0
700bAD kyitem          s                   like(ititem)
     D len             s              1  0
     D linppg          s              3  0                                      MAX LINES PER PAGE
     D pflag           s              1
     D pos             s              1  0
DRYaAd rtype           s              1
640aAD stamp           s               z
640aAD stampUC         s               z
     D today           s              8  0
650aAD rem             s              9  3
650aAD wkqty           s                    like(iitqo)
     D work3a          s              3

640aA*----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
640aAD $pBatId         s             11
640aAD $pReturn        s             10
640aAD $pMessage       s            200
640aA
     *----------------------------------------------------------------
     *  Program info data structure
     *
640aA /copy qcopysrc,c#pgminfds
     *
640aDD*               sds
640aDD* #prog            *proc
640aDD* #job                 244    253
640aDD* #user                254    263
640aDD* #jobn                264    269
640aDD* #jobdt               276    281  0
640aDD* #jobtm               282    287  0

640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql
740 A /COPY *libl/qcopysrc,p.exitemor
740 A /COPY *libl/qcopysrc,c#stdvar

640aA*----------------------------------------------------------------
640aA*  File data data structure
640aA*----------------------------------------------------------------
640aA
640aAD sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
640aA*      $pBatId - Batch id
     *
     *    Returned Parameters
     *      $PWHSE  Warehouse to process.
640aA*      $pReturn  - Return code
640aA*      $pMessage - Return message
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
640aMC                   parm                    $pWhse3A
640aAc                   parm                    $pBatId
640aAc                   parm                    $pReturn
640aAc                   parm                    $pMessage
640aA
640aAc                   eval      $pWhse = %dec($pWhse3A: 3: 0)
640aAc                   eval      $pReturn = '*OK'
640aAc                   eval      $pMessage = ' '
640aAC                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *
640aA* Update stgbatch record to start process
640aA*
640aAC                   exsr      zzzStart
640aAC                   if        $pReturn <> '*OK'
640aAC                   return
640aAC                   endif
     *
     * Whip through all the download Total qty ordered records.
     *
     C                   eval      first = *on
     C                   eval      pflag = *on
     C                   eval      eofi = *off
     C                   eval      linppg = 55                                  MAX LINES PER PAGE
     C                   eval      count = 0                                    LINE COUNTER
     *
640aAC     keysit        setll     impsitmo
     C                   dou       eofi = *on
     *
640aDC**                 read      impfitmo                               79
640aMC     keysit        reade     impsitmo                               79
     C                   eval      error = *off
     C                   if        *in79
     C                   eval      eofi = *on
     C                   goto      enddij
     C                   endif
DRYa c                   eval      rtype = %subst(ijtext:1:1)
     *
640aA*  Skip processed records.
640aA*
640aAC                   if        ijstatus <> 'R'
640aAC                   iter
640aAC                   endif
     *
     *    Frist time through, delete existing records for warehouse.
     *
     *       Note: It is assumed that the file contains records
     *             for a single warehouse.
     *
     C                   if        first = *on
     C                   eval      $pwhse = ijwhse
     C                   move      ijwhse        $pWhse3A
     C                   exsr      zzinz2
     C                   call      'II245B'
     C                   parm                    $pWhse3A
     C                   eval      first = *off
     C                   endif
     *
     *    Error check for update/add.
     *
     C                   exsr      zzchki
     *
     C                   if        error = *off

EOPaAc                   if        client = Earls
EOPaAc                   exsr      PreProcEOP
EOPaAc                   endif
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
640aAC                   if        error
640aAC                   eval      importError = *on
640aAC                   eval      ijstatus = 'E'
640aAC                   eval      ijtext   = detmsg
640aAC                   else
640aAC                   eval      ijstatus = 'S'
DRYaAc                   if        client <> dairyland or
EOPaAc                             client <> Earls
640aAC                   eval      ijtext = ' '
DRYaAc                   endif
640aAC                   endif
640aAC                   exsr      zzzGetStamps
640aAC                   eval      ijststs = stamp
640aAC                   eval      ijstsuc = stampuc
640aAC                   update    ijrec
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

DRYa *  When Dairyland we look for D replen type (Drop Pick) and pass
DRYa *  that in to LT110CL if passed so it will not purge anything other
DRYa *  than Drop Picks.  Any other letter will pass A for All.  This
DRYa *  is to safeguard from something else being written into the field
DRYaAC                   if        client = dairyland
DRYaAc                   if        rtype<>'D'
DRYaAc                   eval      rtype='A'
DRYaAc                   endif
DRYaAc                   else
DRYaAc                   eval      rtype='A'
DRYaAc                   endif
     *
     *  We are finished so get out.
     *
710 A*  Create *ORDQTY Replenishments based on on-order quantity.
710 AC                   call      'LT110CL'
710 AC                   parm      $pWhse3A      $rwhse            3
710 AC                   parm      '*ALL '       $rwhdp            5
710 AC                   parm      '*ORDQTY'     $rpltype          8
710 AC                   parm      '0'           $rjobq            1
DRYaDC*                  parm      'A'           $rtype            1
DRYaMC                   parm      rtype         $rtype            1
710 A*
640aAC                   exsr      zzzEnd
640aDC**                 eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
730aA*
730aA* Get client id.
730aA*
730aAC                   call      'GETCLIENT'
730aAC                   parm                    client           10
730aAC                   parm                    clientloc        10
     *
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
640aA*
640aA*  Define key for impsitmo file.
640aA*
640aAC     keysit        klist
640aAC                   kfld                    $pWhse
640aAC                   kfld                    $pBatId
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

DRYaA* Get client id
DRYaA
DRYaAC                   call      'GETCLIENT'
DRYaAC                   parm                    client
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
EOPaA*
EOPaA*  PreProcEOP   Pre-Process Earl's Organic Items.
EOPaA*
EOPaA /free
EOPaA   begsr PreProcEOP;
EOPaA
EOPaA     // Skip Repack items, already handled.
EOPaA     if ittype = 'R';
EOPaA       leavesr;
EOPaA     endif;
EOPaA
EOPaA     // Convert half dozens
EOPaA     select;
EOPaA       when itum2 = 'HD' and ijtqo > 1;
EOPaA         ijtext = 'HD reduction: ' + %char(ijtqo);
EOPaA         ijtqo = ijtqo / 2;
EOPaA     endsl;
EOPaA
EOPaA   endsr; // PreProcEOP
EOPaA /end-free
     *----------------------------------------------------------------
     *
     *  ZZCHKI   Item update error checking.
     *
     C     zzchki        begsr
     C                   eval      error = *off
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
640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
      /free

        if importError;
          sbstatus = 'E';
          sbtext   = 'Import completed with error(s). See impsitmo file.';
          $pReturn = '*ERROR';
          $pMessage = sbtext;
        else;
          sbstatus = 'S';
          sbtext   = 'Import completed successfully';
        endif;

        exec sql
          update stgbatch
          set sbstatus = :sbstatus,
              sbtext   = :sbtext,
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = %trimr(sbtext) + ' - '
                    + 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- ii255s/zzzend';
          leavesr;
        endif;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetStamps   Get timestamps
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzStart   Start processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzStart      begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'P',
              sbtext   = 'Import started',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbstrts  = current_timestamp,
              sbstruc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- ii255s/zzzstart';
          leavesr;
        endif;

        importError = *off;

      /end-free
     c                   endsr

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
* Invalid item
* Item number cannot be blank
**
Import FTP Order Quantities by Item
