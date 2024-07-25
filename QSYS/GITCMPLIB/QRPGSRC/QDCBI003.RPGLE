      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *----------------------------------------------------------------
     *
     *  QDCBI003
     *
     *    Created pgm to process the IMPSRCVP file looking for field
     *    RCPTEXT = *NOTRAN. Use RCPLCNS to read LICATIVE and if a
     *    RCVDOCK slot is found, update SLOT2 file to set SLSTK1-3 = 0.
     *    Lastly, call LT001 FIX + SLWHSE+SLWHDP+SLDISP to cleanup
     *    license.
     *
     *----------------------------------------------------------------
     *  14 October 2015
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
CBI A*    10/14/15  MLB  CBI
     *      - Created.
CBIaA*    10/19/15  MLB  CBIa
     *      - Enh: Revised pgm to not delete RCVDOCK-xx slots if only
     *        RCVDOCK-xx slots containing item.
CBIbA*    10/19/15  MLB  CBIb
     *      - Enh: Added logic to CBIa mod to skip item if slot has
     *        zero qty in slot.
CBIcA*    10/19/15  MLB  CBIc
     *      - Enh: Added logic to CBIa mod to call LT001 FIX when
     *        RCVDOCK-xx slot not found in SLOT2.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
     *
     *----------------------------------------------------------------
     * File Specs

     Fimpsrcvp  uf   e           k disk
     Flicactive if   e           k disk
     fslot2     uf   e           k disk    rename(slrec : slrec2)
CBIaAfslot3     if   e           k disk    rename(slrec : slrec3)
CBIaAF                                     prefix(sl3)

     *----------------------------------------------------------------
     *  Table and array definitions

     *----------------------------------------------------------------
     *  Customer id

     *----------------------------------------------------------------
     *  Working variables

     D first           s              1
     D impdate         s              6  0 inz(0)
     D lastStop        s              2  0
     D $pwhse          s              3  0
     D $ptrn#          s              7  0 inz(0)
     D svstk1          s                   like(slstk1)
     D svstk2          s                   like(slstk2)
     D svstk3          s                   like(slstk3)
     D slottxt         s             45
     D wrktrn          s              7

     *----------------------------------------------------------------
     *  Date/time variables

     D bfcoffset       s              3  0 inz(0)
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D currtimestamp   s               z
     D datestamp       s               d
     D editdate        s               d
     D edittime        s               t   timfmt(*hms:)
     D micro           s             26
     D micro4          s              4
CBIaAD othersltsfound  s              1    inz('0')
     D timestamp       s               t   timfmt(*hms:)
     D*
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*

     *----------------------------------------------------------------
     *  Program info data structure

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Constants

     D forevr          c                   const('1')

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHS    Warehouse (alpha)
     *
     *    Returned Parameters
     *      -None-
     *
     *----------------------------------------------------------------
     *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $pwhs             3

     * Main line

     C                   eval      $pwhse = %dec($pwhs : 3:0)

     *  Loop through Trax route file and fix dates

     C     $pwhse        setll     impsrcvp
     C                   dou       forevr <> forevr
     C     $pwhse        reade     impsrcvp
     C                   if        %eof(impsrcvp)
     C                   leave
     C                   endif
     *
     C                   select
     C                   when      rcptype = 'D'
     C                             and (%subst(rcptext:193:8) =
     C                             '*NOTRAN ')
     *
CBIdDC***                move      rcpststs      datestamp
CBIdDC***  *mdy          move      datestamp     impdate
CBIdDC***                if        impdate = 092115
     *
     *      Try to delete stranded RCVDOCK-xx slot.
     *
     C     keyla         setll     licactive
     C     keyla         reade     licactive
     C                   if        not %eof(licactive)
     C                             and laaisl = 'RCV'
     *
     C     keysl         chain     slot2
CBIcAC                   if        not %found(slot2)
CBIcA*
CBIcAC                   call(e)   'LT001'
CBIcAC                   parm      'FIX'         lpAction
CBIcAC                   parm      $pwhse        lpWhse
CBIcAC                   parm      lawhdp        lpWhdp
CBIcAC                   parm      ladisp        lpDisp
CBIcAC                   parm      ' '           lpDummy
CBIcA
CBIcA*      Update status of RCVDOCK slsot delete.
CBIcAC                   eval      slottxt = %trim(lawhdp)
CBIcAC                             + '/'
CBIcAC                             + %trim(laitem)
CBIcAC                             + '/'
CBIcAC                             + %trim(ladisp)
CBIcAC                             + '/'
CBIcAC                             + 'NOSLT'
CBIcAC                             + '/'
CBIcAC                             + %editc(svstk2 : 'X')
CBIcAC                             + '/'
CBIcAC                             + %editc(svstk3 : 'X')
CBIcA
CBIcAC                   eval      rcptext = %replace(slottxt:rcptext:147:45)
CBIcA
CBIcAC                   update    rcprec
CBIcA
CBIcAC                   iter
CBIcAC                   endif
     C                   if        %found(slot2)
CBIaA*
CBIaAC                   eval      othersltsfound = '0'
CBIaAC     keysl3        setll     slot3
CBIaAC                   dow       forevr = forevr
CBIaAC     keysl3        reade     slot3
CBIaAC                   if        %eof(slot3)
CBIaAC                   leave
CBIaAC                   endif
CBIaA*
CBIaAC                   if           sl3sldisp =  LADISP
CBIaA*
CBIaAC                             or sl3slstat = 'Z '
CBIbA*
CBIbA*       Skip item if no qty in stock.
CBIbAC                             or (sl3slstk1 = 0
CBIbAC                             and sl3slstk2 = 0
CBIbAC                             and sl3slstk3 = 0)
CBIaAC                   iter
CBIaAC                   else
CBIaAC                   eval      othersltsfound = '1'
CBIaAC                   leave
CBIaAC                   endif
CBIaA*
CBIaAC                   enddo
CBIaA*
CBIaA*    Bypass license if no other slots found.
CBIaAC                   if        othersltsfound = '0'
CBIaAC                   unlock    impsrcvp
CBIaAC                   iter
CBIaAC                   endif
CBIaA*
     C                   eval      slstat = 'Z '
     C                   eval      svstk1 = slstk1
     C                   eval      svstk2 = slstk2
     C                   eval      svstk3 = slstk3
     C                   eval      slstk1 = 0
     C                   eval      slstk2 = 0
     C                   eval      slstk3 = 0
     C                   update    slrec2
     *
     C                   call(e)   'LT001'
     C                   parm      'FIX'         lpAction          3
     C                   parm      slwhse        lpWhse            3 0
     C                   parm      slwhdp        lpWhdp            5
     C                   parm      sldisp        lpDisp           12
     C                   parm      ' '           lpDummy           1

     *      Update status of RCVDOCK slsot delete.
CBIaMC                   eval      slottxt = %trim(slwhdp)
CBIaAC                             + '/'
CBIaAC                             + %trim(slitem)
     C                             + '/'
CBIaMC                             + %trim(sldisp)
     C                             + '/'
     C                             + %editc(svstk1 : 'X')
     C                             + '/'
     C                             + %editc(svstk2 : 'X')
     C                             + '/'
     C                             + %editc(svstk3 : 'X')

     C                   eval      rcptext = %replace(slottxt:rcptext:147:45)
     C                   update    rcprec

     C                   endif
     C                   endif

CBIdDC*                  endif

     C                   endsl

     C                   enddo

     C     bottom        tag

     C                   eval      *inlr = *on
     *----------------------------------------------------------------

     *          SUBROUTINES IN ALPHABETICAL ORDER

     *----------------------------------------------------------------

     *  *INZSR  Initialization subroutine

     C     *inzsr        begsr

     *   Define full key for LICACTIVE file.

     C     keyLA         klist
     C                   kfld                    $pwhse
     C                   kfld                    rcplcns

     *   Define full key for SLOT2 file.

     C     keySL         klist
     C                   kfld                    $pwhse
     C                   kfld                    lawhdp
     C                   kfld                    ladisp

CBIaA
CBIaA*   Define partial key for SLOT3 file.
CBIaA
CBIaAC     keySL3        klist
CBIaAC                   kfld                    $pwhse
CBIaAC                   kfld                    slitem
CBIaA
     C                   endsr
     *-------------------------------------------------------------------------
