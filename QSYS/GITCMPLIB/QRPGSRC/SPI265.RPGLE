     H option(*nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  SPI265     SAP - Import host purchase orders - Extract
     *  25 June 2006
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*  06/25/06  MLB  5.10
     *    - Created.
     *    - Client custom code support included.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
PAK A*    09/18/06  MLB  PAK
     *      - P/O import will only be done for orders coming
     *        from warehouses: 200, 300 or 310.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfordh  if   e           k disk
     Fimpfordhm if   e           k disk
     Fimpfordd  if   e           k disk
     Fpiritem   if   e           k disk
     Fimpfpoh2  o    e           k disk
     Fimpfpohm  o    e           k disk
     Fimpfpod2  o    e           k disk
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
PAK A /COPY QCOPYSRC,ID#packers
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Working variables
     *
     D forever         s              1    inz('0')
     D impdte          s              8  0
     D imptim          s              6  0
     *
     *----------------------------------------------------------------
     *  Re-mapped file fields.
     *
     D hdrmsc1         ds
     D  sapplant#              1      3  0
     D  sapship#               4     14  0
     D  sapslsorg             15     18  0
     D  sapdestplant          19     22  0
     D  sapdlvrytype          23     26
     D  ohmms1                 1     40
     *
     D hdrmsc2         ds
     D  sapdeststgloc          1      4  0
     D  sapdestshippt          5      8  0
     D  ohmms2                 1     40
     *
     D hdrmsc3         ds
     D  ohmms3                 1     40
     *
     D hdrmsc4         ds
     D  ohmms4                 1     40
     *
     D hdrmsc5         ds
     D  sapdlvrynbr            1      9  0
     D  ohmms5                 1     40
     *
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
     *  Constants
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *IMPZPLF - Import Delivery Order as Purchase order
     *
     *    Returned Parameters
     *      $Pimport_po   *YES - Purchase order(s) written to export file
     *                    *NO  - No purchase order(s) written to export file
     *      $Preturn      *OK  - No errors encountered during processing.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd            10
     C                   parm                    $pimport_po       4
     C                   parm                    $preturn          8
     *----------------------------------------------------------------
     * Main line
     *
     C                   exsr      zzinz2
     *
     C                   select
     *      Import sales order as purchase order.
     C                   when      $pcmd = '*IMPZPLF'
     C                   exsr      zzzplf
     *
     C                   endsl
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *
     * Key definitions
     *
     *    Customer order misc. header - Full.
     C     keyhm         klist
     C                   kfld                    oihwhs
     C                   kfld                    oihord
     *
     *    Customer order detail - Partial.
     C     keyoid        klist
     C                   kfld                    oihwhs
     C                   kfld                    oihord
     *
     *    FS-WMS Item master - Full.
     C     keyit         klist
     C                   kfld                    oidwhs
     C                   kfld                    oiditm
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZZPLF   Process ALL customer orders for delivery type ZPLF.
     *
     C     zzzplf        begsr
     *
     C                   dow       forever = forever
     C                   read      impfordh
     C                   select
     C                   when      %eof(impfordh)
     C                   leave
     *
     C                   other
     *
     C     keyhm         chain     impfordhm
     C                   if        %found(impfordhm)
     C                             and %subst(ohmms1:23:4) = 'ZPLF'
PAK AC                             and (oihwhs = 200 or oihwhs = 300 or
PAK AC                                  oihwhs = 310)
     C
     *
     C                   exsr      zzfill1
     *
     C                   exsr      zzwrt1
     *
     C                   exsr      zzread
     *
     C                   endif
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZREAD   Read customer order detail records.
     *
     C     zzread        begsr
     C     keyoid        setll     impfordd
     *
     C                   dow       forever = forever
     C     keyoid        reade     impfordd
     C                   select
     C                   when      %eof(impfordd)
     C                   leave
     *
     C                   other
     *
     C                   exsr      zzgetit
     *
     C                   exsr      zzfill2
     *
     C                   exsr      zzwrt2
     *
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL1   Load import header fields with values from files.
     *
     C     zzfill1       begsr
     *
     C                   clear                   pihrec
     C                   clear                   pihmrc
     C                   eval      $pimport_po = '*YES'
     *
     *      Fill p/o header record fields.
     C                   eval      pihwhs = oihwhs
     C                   eval      pihcdt = impdte
     C                   eval      pihctm = imptim
     C                   movel     sapdlvrynbr   pihpo
     C                   eval      pihvna = oihcnm
     C                   eval      pihva1 = oihca1
     C                   eval      pihva2 = oihca2
     C                   eval      pihvct = oihcct
     C                   eval      pihvst = oihcst
     C                   eval      pihvzp = oihczp
     C                   eval      pihdte = impdte
     C                   eval      pihtyp = 'C'
     *
     *      Fill p/o header miscelleanous record fields.
     C                   eval      pihmwh = oihwhs
     C                   movel     sapdlvrynbr   pihmpo
     C                   eval      pihmcd = impdte
     C                   eval      pihmct = imptim
     C                   movel     sapdeststgloc pihmm5
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFILL2   Load detail import fields with values from files.
     *
     C     zzfill2       begsr
     *
     C                   clear                   pidrec
     *
     C                   eval      pidwhs = oihwhs
     C                   eval      pidcdt = impdte
     C                   eval      pidctm = imptim
     C                   movel     sapdlvrynbr   pidpo
     C                   eval      piditm = oiditm
     C                   eval      pidvit = itvit#
     C                   eval      pidseq = oidseq
     C                   eval      pidqo1 = oidq1
     C                   eval      pidqo2 = oidq2
     C                   eval      pidqo3 = oidq3
     C                   eval      pidtyp = 'C'
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGETIT   Get FS-WMS item master record.
     *
     C     zzgetit       begsr
     *
     C     keyit         chain     piritem
     *
     C                   if        not %found(piritem)
     C                   eval      itvit# = ' '
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     C                   eval      $pimport_po = '*NO '
     C                   eval      $preturn    = '*OK'
     *
     *    Get import date/time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZWRT1   Write P/O header record to import file.
     *
     C     zzwrt1        begsr
     C                   write     pihrec
     *
     C                   write     pihmrc
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZWRT2   Write P/O detail record to import file.
     *
     C     zzwrt2        begsr
     C                   write     pidrec
     *
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
