510cA /COPY *libl/qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*
     F*  QDGMM030  Migrate Check Digits to BFC Slot from NDS Slot.
     F*  01 August 2012
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
GMM AF*    08/01/12  MLB  GMM
     F*      - Created.
     F*
     F*----------------------------------------------------------------
     F*  Notes:
     F*
     F*    This program was created to migrate the check digits from
     F*    the NDS slot to the new BFC slot.
     F*
     F*----------------------------------------------------------------
     FSLOTDGT1  IF   E           K DISK    rename(scdrec : scdrec1)
     F                                     prefix(s1)
     FSLOTDGTA1 IF   E           K DISK    rename(scdreca : scdreca1)
     F                                     prefix(sa1)
     FSLOTDGT   UF a E           K DISK
     FSLOTDGTA  UF a E           K DISK
     FSLOTXRF   IF   E           K DISK
     Fqsysprt   O    F  132        PRINTER OFLIND(*IN90)
     Derrorcode        s             20
     Derrmsg           s             60
     Dp1whdp           s              5
     Dp1disp           s             12
     D*
      *
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
     C                   time                    hmsmdy           12 0
     C                   Move      hmsmdy        rdate             6 0
     C                   movel     hmsmdy        rtime             6 0
     C                   eval      *in90 = '1'

     * Get import date/time.
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        impdte            8 0
     C                   time                    imptim            6 0
     C*
     C*  Define keys
     C*
     C     scdkey        KLIST
     C                   KFLD                    KYWHSE            3 0
     C                   Z-ADD     001           KYWHSE
     C*
     C     scd1key       KLIST
     C                   KFLD                    s1scdwhs
     C                   KFLD                    s1scdwhd
     C                   KFLD                    kydisp           12
     C*
     C     scda1key      KLIST
     C                   KFLD                    sa1scdwhsa
     C                   KFLD                    sa1scdwhda
     C                   KFLD                    kydisp
     C*
     C     xfkey         KLIST
     C                   KFLD                    KYcmpn            3
     C                   KFLD                    KYdivn            3
     C                   KFLD                    KYdptn            3
     C                   KFLD                    KYwhsn            3
     C                   KFLD                    kywhna            3
     C                   KFLD                    kysltn            7
     C                   eval      kycmpn = '1  '
     C                   eval      kydivn = '1  '
     C                   eval      kydptn = '1  '
     C                   eval      kywhsn = '1  '
     C*
     C*
     C*           Process SLOTDGT file.
     C                   move      'SCDDGT '     filename          7
     C     scdkey        SETLL     slotdgt1
     C                   dow       not %eof(slotdgt1)
     C     scdkey        READE     slotdgt1
     C*
     C                   SELECT
     C                   when      %eof(slotdgt1)
     C                   LEAVE
     C*
     C*      NDS slot with check digit to be moved.
     C                   when          %subst(s1scddsp:3:1) <> '-'
     C                             and %subst(s1scddsp:7:1) <> '-'
     C*
     C                   eval      kywhna = %subst(s1scdwhd:1:3)
     C                   eval      kysltn = %subst(s1scddsp:1:7)
     C     xfkey         chain     slotxrf
     C*
     C                   select
     C                   when      not %found(slotxrf)
     C                   eval      errorcode = '*NONDSXREF'
     C                   eval      p1whdp    = s1scdwhd
     C                   eval      p1disp    = s1scddsp
     C                   eval      xfdisp    = ' '
     C                   exsr      zzprinterr
     C*
     C                   when      %found(slotxrf)
     C                             and xfdisp = ' '
     C                   eval      errorcode = '*NOBFCSLOT'
     C                   eval      p1whdp    = s1scdwhd
     C                   eval      p1disp    = s1scddsp
     C                   exsr      zzprinterr
     C*
     C*      NDS slot found in Cross-Reference file.
     C                   other
     C*
     C                   eval      kydisp = xfdisp
     C     scd1key       chain     slotdgt
     C*
     C                   select
     C                   when      %found(slotdgta)
     C*
     C*      Load NDS check digits into BFC check digits.
     C*
     C                   eval      scddgt = s1scddgt
     C                   update    scdrec
     C                   unlock    slotdgt
     C*
     C                   when      not %found(slotdgt)
     C*
     C*      Load NDS check digits into BFC check digits.
     C*
     C                   eval      scdwhs = s1scdwhs
     C                   eval      scdwhd = s1scdwhd
     C                   eval      scddsp = xfdisp
     C*
     C                   eval      scddgt = s1scddgt
     C*
     C                   eval      scdadt = impdte
     C                   eval      scdatm = imptim
     C                   eval      scdaby = 'BFC'
     C*
     C                   write     scdrec
     C                   unlock    slotdgt
     C                   Endsl
     C*
     C                   Endsl                                                  Slotxref Endsl
     C*
     C                   ENDSL                                                  Slotdgt1 Endsl
     C*
     C                   ENDDO                                                  Slotdgt1 Enddo
     C*
     C*-----------------------------------------------------------------
     C*
     C*   Process the SLOTDGTA file.
     C                   eval      *in90 = '1'
     C                   move      'SCDDGTA'     filename
     C     scdkey        SETLL     slotdgta1
     C                   dow       not %eof(slotdgta1)
     C     scdkey        READE     slotdgta1
     C*
     C                   SELECT
     C                   when      %eof(slotdgta1)
     C                   LEAVE
     C*
     C*      NDS slot with check digit to be moved.
     C                   when          %subst(sa1scddspa:3:1) <> '-'
     C                             and %subst(sa1scddspa:7:1) <> '-'
     C*
     C                   eval      kywhna = %subst(sa1scdwhda:1:3)
     C                   eval      kysltn = %subst(sa1scddspa:1:7)
     C     xfkey         chain     slotxrf
     C*
     C                   select
     C                   when      not %found(slotxrf)
     C                   eval      errorcode = '*NONDSXREF'
     C                   eval      p1whdp    = sa1scdwhda
     C                   eval      p1disp    = sa1scddspa
     C                   eval      xfdisp    = ' '
     C                   exsr      zzprinterr
     C*
     C                   when      %found(slotxrf)
     C                             and xfdisp = ' '
     C                   eval      errorcode = '*NOBFCSLOT'
     C                   eval      p1whdp    = sa1scdwhda
     C                   eval      p1disp    = sa1scddspa
     C                   exsr      zzprinterr
     C*
     C*      NDS slot found in Cross-Reference file.
     C                   other
     C*
     C                   eval      kydisp = xfdisp
     C     scda1key      chain     slotdgta
     C*
     C                   select
     C                   when      %found(slotdgta)
     C*
     C*      Load NDS check digits into BFC check digits.
     C*
     C                   eval      scddgt2 = sa1scddgt2
     C                   eval      scddgt3 = sa1scddgt3
     C                   update    scdreca
     C                   unlock    slotdgt
     C*
     C                   when      not %found(slotdgt)
     C*
     C*      Load NDS check digits into BFC check digits.
     C*
     C                   eval      scdwhsa = sa1scdwhsa
     C                   eval      scdwhda = sa1scdwhda
     C                   eval      scddspa = xfdisp
     C*
     C                   eval      scddgt2 = sa1scddgt2
     C                   eval      scdadt2 = impdte
     C                   eval      scdatm2 = imptim
     C                   eval      scdaby2 = 'BFC'
     C*
     C                   eval      scdvdt2 = 0
     C                   eval      scdvtm2 = 0
     C                   eval      scdvby2 = ' '
     C*
     C                   eval      scddgt3 = sa1scddgt3
     C                   eval      scdadt3 = impdte
     C                   eval      scdatm3 = imptim
     C                   eval      scdaby3 = 'BFC'
     C*
     C                   eval      scdvdt3 = 0
     C                   eval      scdvtm3 = 0
     C                   eval      scdvby3 = ' '
     C*
     C                   write     scdreca
     C                   unlock    slotdgta
     C                   Endsl
     C*
     C                   Endsl                                                  Slotxref Endsl
     C*
     C                   ENDSL                                                  Slotdgta1 Endsl
     C*
     C                   ENDDO                                                  Slotdgta1 Enddo
     C*
     C                   MOVE      *ON           *INLR
     C*
     C*----------------------------------------------------------------
     C*
     C*
     C     ZZPRINTERR    BEGSR
     C                   IF        *IN90 = '1'
     C                   except    HEAD1
     C                   eval      *in90 = '0'
     C                   ENDIF
     C*
     C                   select
     C                   when      errorcode = '*NONDSXREF'
     C                   eval      errmsg = 'NDS Slot Not in XRef'
     C*
     C                   when      errorcode = '*NOBFCSLOT'
     C                   eval      errmsg = 'BFC Slot Not Found'
     C*
     C                   endsl
     C*
     C                   except    DETAIL1
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     OQSYSPRT   E            HEAD1          1  2
     O                                            8 'QDGMM030'
     O                                           76 'NDS to BFC CkDigit Migrati'
     O                                           89 'on Exceptions'
     O                                          127 'Page'
     O                       PAGE               132
     O*
     O          E            HEAD1          1
     O                       RDATE         Y      8
     O                       RTIME               18 '  :  :  '
     O                       filename            30
     O*
     O          E            HEAD1          1
     O                                           12 'Warehouse : '
     O                       KYWHSE        4     15
     O          E            HEAD1          1
     O                                          132 ' '
     O          E            HEAD1          0
     O                                            6 '______'
     O                                           20 '____________'
     O                                           34 '____________'
     O                                          105 '_____________'
     O          E            HEAD1          1
     O                                            6 'Whdp  '
     O                                           20 'NDS Slot '
     O                                           34 'BFC Slot '
     O                                          105 'Error Message'
     O          E            DETAIL1     1  1
     O                       p1whdp               5
     O                       p1disp              20
     O                       xfdisp              34
     O                       errmsg             132
