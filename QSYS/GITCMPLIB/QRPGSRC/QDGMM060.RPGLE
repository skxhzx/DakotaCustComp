510cA /COPY *libl/qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*
     F*  QDGMM060  Remove Type B/Type S Items from Dakota/Retalix.
     F*  09 August 2019
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
GMM AF*    08/09/19  MLB  GMM
     F*      - Created.
     F*
     F*
     F*----------------------------------------------------------------
     F*  Notes:
     F*
     F*    This program was created to remove type B, type S items from
     F*    Dakota item files and from slot file. Needed as part of move
     F*    to NCR Retalix. Decision to use 1 item# for case/each.
     F*
     F*----------------------------------------------------------------
     Fpiritem   UF   E           K DISK    rename(itrec : itrec1)
     Fpiritem3  UF   E           K DISK    rename(itrec : itrec3)
     F                                     prefix(iT3)
     Fitemqty   uF   E           K DISK
     Fitemmsc   uF   E           K DISK
     Fitemdsc   uF   E           K DISK
     Fitemext1  uF   E           K DISK
     Fitemfld   uF   E           K DISK
     Fitemlnk   uF   E           K DISK
     Derrmsg           s             60
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

GMMaA*----------------------------------------------------------------
GMMaA*  Table and array definitions
GMMaA*----------------------------------------------------------------
GMMaA
GMMaAD a2              s              1    dim(2)
GMMaAD a2n             s              1    dim(2)
GMMaAD hnd             s              2    dim(702)
GMMaAD ltr             s              1    dim(27) ctdata perrcd(27)
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
     C     brkkey        KLIST
     C                   KFLD                    itwhse
     C                   kfld                    ititem
     C     baskey        KLIST
     C                   KFLD                    ilitm2
     C                   kfld                    itwhse
     C*
     C*
     C     *loval        SETLL     piritem
     C                   dow       not %eof(piritem)
     C                   read      piritem
     C*
     C                   SELECT
     C                   when      %eof(piritem)
     C                   leave
     C*
     C*     Bypass all regular items.
     C                   when      ittype =  ' '
     C                   iter
     C*
GMMbAC*-------------------------------------------------------------
GMMbAC                   when      ittype = 'S'
     C*
     C     brkkey        chain     itemqty
     C                   if        %found(itemqty)
     C                   delete    iqrec
     C                   endif
     C*
     C     brkkey        chain     itemmsc
     C                   if        %found(itemmsc)
     C                   delete    imrec
     C                   endif
     C*
     C     brkkey        chain     itemdsc
     C                   if        %found(itemdsc)
     C                   delete    ixrec
     C                   endif
     C*
     C     brkkey        chain     itemext1
     C                   if        %found(itemext1)
     C                   delete    ikrec
     C                   endif
     C*
     C     brkkey        chain     itemfld
     C                   if        %found(itemfld)
     C                   delete    ifrec
     C                   endif
     C*
     C     brkkey        chain     itemlnk
     C                   if        %found(itemlnk)
     C     baskey        chain     piritem3
     C                   if        %found(piritem3)
     C                             and it3itum2 > ' '
     C                             and it3itumq2 > 0
     C                   eval      it3itflg1 = 'Y'
     C                   update    itrec3
     C                   endif
     C
     C                   delete    ilrec
     C                   endif
     C
     C                   delete    itrec1
     C
GMMbAC*-------------------------------------------------------------
GMMbAC                   when      ittype = 'B'
     C*
     C     brkkey        chain     itemqty
     C                   if        %found(itemqty)
     C                   delete    iqrec
     C                   endif
     C*
     C     brkkey        chain     itemmsc
     C                   if        %found(itemmsc)
     C                   delete    imrec
     C                   endif
     C*
     C     brkkey        chain     itemdsc
     C                   if        %found(itemdsc)
     C                   delete    ixrec
     C                   endif
     C*
     C     brkkey        chain     itemext1
     C                   if        %found(itemext1)
     C                   delete    ikrec
     C                   endif
     C*
     C     brkkey        chain     itemfld
     C                   if        %found(itemfld)
     C                   delete    ifrec
     C                   endif
     C*
     C     brkkey        chain     itemlnk
     C                   if        %found(itemlnk)
     C     baskey        chain     piritem3
     C                   if        %found(piritem3)
     C                             and it3itum2 > ' '
     C                             and it3itumq2 > 0
     C                   eval      it3itflg1 = 'Y'
     C                   update    itrec3
     C                   endif
     C
     C                   delete    ilrec
     C                   endif
     C
     C                   delete    itrec1
     C*
GMMaAC*----------------------------------------------
     C                   other
GMMaAC*
GMMaAC                   unlock    piritem
     C*
     C                   ENDSL                                                  piritem Endsl
     C*
     C                   ENDDO                                                  piritem Enddo
     C*
     C                   MOVE      *ON           *INLR
     C*
