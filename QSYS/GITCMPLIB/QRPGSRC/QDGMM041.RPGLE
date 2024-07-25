510cA /COPY *libl/qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*
     F*  QDGMM041  Remove NDS KZZZ slots
     F*  29 August 2012
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
GMM AF*    08/29/12  MLB  GMM
     F*      - Created.
GMMaAF*    02/06/13  MLB  GMMa
     F*      - Revised pgm to set KYWHSE = 010 for Vinita Inbound.
     F*
     F*----------------------------------------------------------------
     F*  Notes:
     F*
     F*    This program was created to delete NDS KZZZ base and virtual slots
     F*
     F*----------------------------------------------------------------
     FSLOT1     UF   E           K DISK    rename(slrec : slrec1)
     FVSLOT1    UF   E           K DISK
     D forevr          s              1     inz('0')
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

     C*
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
     C     SL1key        KLIST
     C                   KFLD                    KYWHSE            3 0
GMMaDC*                  Z-ADD     001           KYWHSE
GMMaMC                   Z-ADD     010           KYWHSE
     C*
     C*
     C     vs1key        KLIST
     C                   KFLD                    slwhse
     C                   KFLD                    slwhdp
     C                   KFLD                    sldisp
     C*
     C     sl1key        SETLL     slot1
     C                   dow       not %eof(slot1)
     C     sl1key        READE     slot1
     C*
     C                   SELECT
     C                   when      %eof(slot1)
     C                   LEAVE
     C*
     C*      NDS slot with item number to be moved.
     C                   when          %subst(sldisp:3:1) <> '-'
     C                             and %subst(sldisp:7:1) <> '-'
     C                             and %subst(sldisp:1:4) =  'KZZZ'
     C                             and slitem > ' '
     C                             and slstk1 = 0
     C                             and slstk2 = 0
     C*
     C*      Virtual pick slot.
     C                   if        slrsrv = 'V'
     C     vs1key        chain     vslot1
     C                   if        %found(vslot1)
     C                   delete    vsrec
     C                   endif
     C                   delete    slrec1
     C*
     C*      Regular pick slot.
     C                   else
     C                   delete    slrec1
     C                   endif
     C*
     C*
     C                   ENDSL                                                  Slot1 Endsl
     C*
     C                   ENDDO                                                  Slot1 Enddo
     C*
     C                   MOVE      *ON           *INLR
     C*
