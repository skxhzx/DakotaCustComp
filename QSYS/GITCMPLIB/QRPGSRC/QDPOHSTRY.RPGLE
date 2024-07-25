     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDPOHSTRY Move P.O.'s to history without exporting
     *  05 July 2011
     *  Ginger Andrews
     *
     *  This program will move PO to history without export step.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    07/05/11  GJA  6.40
     *      - Created.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  74        - NRF for POHDRM
     *  75        - ERR for POHDR
     *  76        - EOF for POEXCP
     *  77        - Super P/O found.
     *  78        - EOF for PODTL
     *  79        - EOF for POSPO
     *
     *----------------------------------------------------------------
     * File Specs
     *
     fpohdr     uf   e           k disk
     fpohdrm    uf   e           k disk
     fpodtl     uf   e           k disk
     fpodtlm    uf   e           k disk
     fpoexcp    uf   e           k disk
     fpospo     uf   e           k disk
     fpohexcp   o  a e           k disk
     fpohhdr    o  a e           k disk
     fpohhdrm   o  a e           k disk
     fpohdtl    o  a e           k disk
     fpohdtlm   o    e           k disk
     flumper    uf   e           k disk
     fporcv     uf   e           k disk
     fpohaccp   uf   e           k disk
     fpohhaccp  o  a e           k disk
     *
     *----------------------------------------------------------------
     *  Constants
     *
     d forevr          c                   const('1')
     *----------------------------------------------------------------
     *  Working variables
     *
     D $whse           s              3  0
     D dltpo           s              4    inz('*NO ')
     D dltpohdrm       s              4    inz('*NO ')
     D expdate         s              8  0
     D exptime         s              6  0
     d spo             s              2
     d today           s              8  0
     d wkgrp2          s              1    inz(' ')
     *----------------------------------------------------------------
     *  Called programs
     *
     d @cvtdt          c                   const('CVTDTE')
     d $cvtdt          ds
     d  $cvcmd                 1      8
     d  $cvprg                 9     18
     d  $cvd6i                19     24
     d  $cvd8i                25     32
     d  $cvd6o                33     38  0
     d  $cvd8o                39     46  0
     d  $cvsto                47     64
     d  $cvrtn                65     72
     d  $cverm                73    132
     d  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      Purchase order
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * PARMS
     *----------------------------------------------------------------
     c     *entry        plist
     c                   parm                    $po               9
     * Main line
     *
     *  Skip order if error on reading PO header.
     *
     c                   eval      $whse = 1
     c     keypoh        chain     pohdr
     c                   if        not %found(pohdr)
     c                   goto      bottom
     c                   endif
     * Make sure PO is not a super PO
     c                   movel     phpo          spo
     c                   if        spo = 'SP'
     c                   goto      bottom
     c                   endif
     *
     *
     *  Add PO header record to history header file.
     *
     c                   exsr      filphh
     c                   write     phhrec
     *
     *  Add PO header record to history header file.
     *
     c     keyod         chain     pohdrm                             74
     c                   if        not *in74
     c                   eval      dltpohdrm = '*YES'
     c                   exsr      filphm
     c                   write     phhmrc
     c                   endif
     *
     c     lmkey         chain     lumper                             79
     c                   if        not *in79
    Ac                   eval      lmhedt = today
    Ac                   time                    lmheti
    Ac                   update    lmrec
    Ac                   endif
    A*  Update PORCV records with export date/time.
     c     keyod         setll     porcv
     c                   dou       forevr <> forevr
     c     keyod         reade     porcv                                  78
     c                   if        *in78
     c                   leave
     c                   endif
     c                   if        poredt = 0
    Ac                   eval      poredt = phhedt
    Ac                   eval      poreti = phheti
    Ac                   update    porrec
     c                   endif
     c                   iter
     c                   enddo
     *
     *  Add order detail records to export detail file.
     *
     c     keyod         setll     podtl
     c                   dou       forevr <> forevr
     c     keyod         reade     podtl                                  78
     c                   if        *in78
     c                   leave
     c                   endif
     *
     *
     *  Add order detail records to HISTORY detail file.
     c                   exsr      filphd
     c                   write     phdrec
     *  Delete order detail records from PODTL file.
     c                   delete    pdrec
     c                   enddo
     *
     *  Add p/o detail misc. records to history p/o detail misc file.
     *
     c     keyod         setll     podtlm
     c                   dou       forevr <> forevr
     c     keyod         reade     podtlm
     c                   select
     c                   when      %eof(podtlm)
     c                   leave
     *
     c                   other
     *
     c                   exsr      filpdm
     c                   write     phdmrc
     *
     *  Delete p/o detail misc. records from PODTLM file.
     c                   delete    pdmrec
     *
     c                   endsl
     *
     c                   enddo
     *
     *
     *  Add exception detail records to history exception file.
     *
     c     keyod         setll     poexcp
     c                   dou       forevr <> forevr
     c     keyod         reade     poexcp                                 76
     c                   select
     c                   when      *in76
     c                   leave
     *
     c                   other
     *
     c                   exsr      filphe
     c                   write     pherec
     *
     *  Delete exception detail records from POEXCP file.
     c                   delete    perec
     *
     c                   endsl
     *
     c                   enddo
     *
     *  Create HACCP history record and delete original.
     c     keyod         setll     pohaccp
     c     keyod         reade     pohaccp
     c                   dow       not %eof
     *
     c                   exsr      filhaccp
     c                   write     hahrec
     c                   delete    harec
     *
     c     keyod         reade     pohaccp
     c                   enddo
     *
     *  Delete order header records from POHDR file.
     c                   delete    phrec
     *
     *  Delete order header misc. record from POHDRM file.
     C                   if        dltpohdrm = '*YES'
     c                   delete    phmrec
     c                   endif
     *
     *
     c     bottom        tag
     c                   eval      *inlr = *on
     c                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     c     *inzsr        begsr
     *
     *   Define full key for POHDR  file
     *
     C     keypoh        klist
     C                   kfld                    $whse
     C                   kfld                    $po
     *
     *   Define full key for POHDRM file
     *
     C     keyphm        klist
     C                   kfld                    phwhse
     C                   kfld                    phpo
     *
     *   Define full key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    pdwhse
     C                   kfld                    pditem
     *
     *   Define partial key for PODTL file.
     *
     c     keyod         klist
     c                   kfld                    phwhse
     c                   kfld                    phpo
     *
     *   Define key for Lumper file.
     *
     c     lmkey         klist
     c                   kfld                    phwhse
     c                   kfld                    phpo
     *
     *   Define partial key for LABEL5 file.
     *
     *
     *  Convert today's date into century format.
     *
     c                   eval      $cvcmd = '*CURCMD '
     c                   call      @cvtdt
     c                   parm                    $cvtdt
     c                   eval      today = $cvd8o
     C                   eval      expdate = today
     C                   time                    exptime
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  FILPHD  Fill history detail fields.
     *
     c     filphd        begsr
     *
     *  Initialize record
     *
     c                   clear                   phdrec
     *
     *  Move fields from order file to po history detail file.
     *
     c                   eval      phdwhs = pdwhse
     c                   eval      phdpo = pdpo
     c                   eval      phdseq = pdseq
     c                   eval      phditm = pditem
     c                   eval      phdvit = pdvitm
     c                   eval      phdspc = pdspcl
     c                   eval      phdqo1 = pdqor1
     c                   eval      phdqo2 = pdqor2
     c                   eval      phdqo3 = pdqor3
     c                   eval      phdqr1 = pdqrc1
     c                   eval      phdqr2 = pdqrc2
     c                   eval      phdqr3 = pdqrc3
     c                   eval      phdwgt = pddwgt
     c                   eval      phdedt = phhedt
     c                   eval      phdeti = phheti
     *
     c                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FILPHE  Fill history receiving exception detail file.
     *
     c     filphe        begsr
     *
     *  Initialize record
     *
     c                   clear                   pherec
     *
     *  Move fields from exception file to po history exception file
     *
     c                   eval      phewhs = pewhse
     c                   eval      phepo = pepo
     c                   eval      pheseq = peseq
     c                   eval      pheitm = peitem
     c                   eval      phecod = pecode
     c                   eval      pheqy1 = peqex1
     c                   eval      pheqy2 = peqex2
     c                   eval      pheqy3 = peqex3
     c                   eval      pheusr = peuser
     c                   eval      phedev = pedev
     c                   eval      pheemp = peemp
     *
     c                   eval      pheedt = phhedt
     c                   eval      pheeti = phheti
     *
     c                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FILPHH   Fill history header fields.
     *
     c     filphh        begsr
     *
     *  Initialize record
     *
     c                   clear                   phhrec
     *
     *  Move fields from PO Header file to PO Header history file.
     *
     c                   eval      phhwhs = phwhse
     c                   eval      phhpo = phpo
     c                   eval      phhven = phven
     c                   eval      phhvna = phvnam
     c                   eval      phhva1 = phvad1
     c                   eval      phhva2 = phvad2
     c                   eval      phhvct = phvcty
     c                   eval      phhvst = phvst
     c                   eval      phhvzp = phvzp1
     c                   eval      phhdte = phdate
     c                   eval      phhtim = phtime
     c                   eval      phhamp = phampm
     c                   eval      phhudt = phudte
     c                   eval      phhuti = phutim
     c                   eval      phhedt = today
     c                   time                    phheti
     *
     c                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FILPHM   Fill history header misc. fields.
     *
     c     filphm        begsr
     *
     *  Initialize record
     *
     c                   clear                   phhmrc
     *
     *  Move flds from PO Hdr Misc. file to PO Hdr Misc. history
     *
     c                   eval      phhmwh = phwhse
     c                   eval      phhmpo = phpo
     c                   eval      phhmm1 = phmm1
     c                   eval      phhmm2 = phmm2
     c                   eval      phhmm3 = phmm3
     c                   eval      phhmm4 = phmm4
     c                   eval      phhmm5 = phmm5
     c                   eval      phhmed = phhedt
     c                   eval      phhmet = phheti
     *
     c                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FILPDM   Fill history detail misc. fields.
     *
     c     filpdm        begsr
     *
     *  Initialize record
     *
     c                   clear                   phdmrc
     *
     *  Move flds from PO Hdr Misc. file to PO Hdr Misc. history
     *
     c                   eval      phdmwh = pdmwhs
     c                   eval      phdmpo = pdmpo
     c                   eval      phdmsq = pdmseq
     c                   eval      phdmit = pdmitm
     c                   eval      phdmod = pdmods
     c                   eval      phdmpm = pdmpom
     c                   eval      phdms1 = pdmms1
     c                   eval      phdms2 = pdmms2
     c                   eval      phdms3 = pdmms3
     c                   eval      phdms4 = pdmms4
     c                   eval      phdms5 = pdmms5
     c                   eval      phdmed = phhedt
     c*                  eval      phhmet = phheti
     c                   eval      phdmet = phheti
     *
     c                   endsr
     *----------------------------------------------------------------
     *
     *  FILHACCP  Fill HACCP history fields.
     *
     c     filhaccp      begsr
     *
     *  Initialize record
     *
     c                   clear                   hahrec
     *
     *  Move fields from POHACCP to POHHACCP
     *
     c                   eval      hahwhse = hawhse
     c                   eval      hahpo = hapo
     c                   eval      hahseq = haseq
     c                   eval      hahitem = haitem
     c                   eval      hahest# = haest#
     c                   eval      hahtksl = hatksl
     c                   eval      hahprda = haprda
     c                   eval      hahprdt = haprdt
     c                   eval      hahrsrq = harsrq
     c                   eval      hahrsdl = harsdl
     c                   eval      hahttrr = hattrr
     c                   eval      hahttmd = hattmd
     c                   eval      hahttns = hattns
     c                   eval      hahptrt = haptrt
     c                   eval      hahptrm = haptrm
     c                   eval      hahptrb = haptrb
     c                   eval      hahptmt = haptmt
     c                   eval      hahptmm = haptmm
     c                   eval      hahptmb = haptmb
     c                   eval      hahptnt = haptnt
     c                   eval      hahptnm = haptnm
     c                   eval      hahptnb = haptnb
     c                   eval      hahldcn = haldcn
     c                   eval      hahinsp = hainsp
     c                   eval      hahedt = phhedt
     c                   eval      haheti = phheti
     *
     c                   endsr
     *
