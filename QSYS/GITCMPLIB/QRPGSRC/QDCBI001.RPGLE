      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *----------------------------------------------------------------
     *
     *  QDCBI001
     *
     *    Created pgm to process the IMPSRCVP file looking for field
     *    RCPTYPE = D. When found, update PIRTRAN and LABEL files to
     *    clear qty, cube, wgt from records and set to Closed status.
     *    Needed due to PO236S pgm not updating p/o license deletes
     *    the date will be corrupted if the client's router feeds it an
     *    incorrect date.
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
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
     *
     *----------------------------------------------------------------
     * File Specs

     Fimpsrcvp  uf   e           k disk
     Fpirtran   uf   e           k disk
     flabel90   uf   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions

     *----------------------------------------------------------------
     *  Customer id

     *----------------------------------------------------------------
     *  Working variables

     D first           s              1
     D lastStop        s              2  0
     D $pwhse          s              3  0
     D $ptrn#          s              7  0 inz(0)
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
     D timestamp       s               t   timfmt(*hms:)
     D*
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D $LPARM          DS
     D  $LCMD                  1      8
     D  $LPRG                  9     18
     D  $LUKY                 19     68
     D  $LRTN                 69     76
     D  $LERM                 77    136
     D  $LMSG                 77     80
405 AD  $LTYPE                81     88
     D*
     D*   Redefine key
     D*
     D  $LWHSE                19     21  0
     D  $LWHDP                22     26
     D  $LRACK                22     26
     D*
     D  $LBLD                 19     20
     D*
405 AD  $LRTE                 22     26
405 AD  $LPO                  27     35
405 AD  $LTRN#                36     42  0
700cAD*
700cAD  $LTRN2#               19     22p 0  inz(0)
700cAD  $LLBL#                23     26p 0  inz(0)
700cAD  $LQPCK                27     31  0  inz(0)
700cAD  $LQRMN                32     36  0  inz(0)
700cAD  $LPCKC                37     39  0  inz(0)
700cAD  $LRECC                40     42  0  inz(0)
700cAD  $LCWGT                43     43     inz(' ')
700cAD  $LMPUT                44     44     inz('Y')


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
     C                   eval      $lprg  = 'QDCBI001'

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
     C                             '*NOTRAN '
     C                              or  %subst(rcptext:193:8) =
     C                             '*DELETED'
     C                              or  %subst(rcptext:193:8) =
     C                             '*FAILED ')
     *       Skip previously processed records.
     C                   iter
     *
     C                   when      rcptype = 'D'
     C                             and %subst(rcptext:1:27) =
     C                             'Putaway transaction deleted'
     *
     C                   evalr     wrktrn = %trimr(%subst(rcptext:29:7))
     C                   eval      $ptrn# = %dec(wrktrn : 7 :0)
     *
     C     $ptrn#        chain     pirtran
     C                   if        not %found(pirtran)
     *      Update status of license delete.
     C                   eval      rcptext = %replace('*NOTRAN ':rcptext:193:8)
     C                   update    rcprec
     C                   iter
     C                   endif
     *
     *      Try to delete license plate/transaction/label info.
     C                   if        ptstat > '1'
     C                   eval      ptstat = '1'
     C***                eval      ptcube = 0
     C***                eval      ptswgt = 0
     C***                eval      ptpcs  = 0
     C***                eval      ptaisl = 0
     C***                eval      ptqty1 = 0
     C***                eval      ptedte = ptgdte
     C***                eval      ptcdte = ptgdte
     C                   update    ptrec
     C                   endif
     C                   unlock    pirtran
     *
     C     keylb90       setll     label90
     C     keylb90       reade     label90
     C                   if        %eof(label90)
     C                   eval      lblbl# = 0
     C                   else
     *    Reset label back to Printed status so delete can proceed.
     C                   if        lbstat <> 'P'
     C                   eval      lbstat = 'P'
     C                   update    lbrec
     C                   endif
     C                   unlock    label90
     C                   endif

700cAC                   eval      $lcmd = '*DELETE'
700cAC                   eval      $lrtn = ' '
700cAC                   eval      $ltrn2# = $ptrn#
700cAC                   eval      $llbl#  = lblbl#
700cAC                   eval      $lqpck = 0
700cAC                   eval      $lqrmn = 0
700cAC                   eval      $lpckc = 0
700cAC                   eval      $lrecc = 0
700cAC                   eval      $lcwgt = '0'
700cAC                   eval      $lmput = 'N'
700cA*
700cAC                   call      'PO144'
700cAC                   parm                    $lparm
     *
     C                   select
     C                   when          $lrtn = '*OK'
     C                              or $LRTN = '*OKOKOK '
     *      Update status of license delete.
     C                   eval      rcptext = %replace('*DELETED':rcptext:193:8)
     C                   update    rcprec

     C                   other
     C     keylb90       setll     label90
     C     keylb90       reade     label90
     C                   if        not %eof(label90)
     *      Force Label closed.
     C                   eval      lbstat = 'C'
     C                   eval      lbcube = 0
     C                   eval      lbswgt = 0
     C                   eval      lbqpck = 0
     C                   update    lbrec
     C                   endif
     *
     C     $ptrn#        chain     pirtran
     C                   if        %found(pirtran)
     C                             and ptstat <> '4'
     *      Force Transaction closed.
     C                   eval      ptstat = '4'
     C                   eval      ptcube = 0
     C                   eval      ptswgt = 0
     C                   eval      ptpcs  = 0
     C                   eval      ptaisl = 0
     C                   eval      ptqty1 = 0
     C                   eval      ptedte = ptgdte
     C                   eval      ptcdte = ptgdte
     C                   update    ptrec
     C                   endif
     *      Update status of license delete.
     C                   eval      rcptext = %replace('*FAILED ':rcptext:193:8)
     C                   update    rcprec

     C                   unlock    pirtran

     C***                endif
     C***                endif

     C                   endsl

     C                   endsl

     C                   enddo

     C     bottom        tag

     C                   eval      *inlr = *on
     *----------------------------------------------------------------

     *          SUBROUTINES IN ALPHABETICAL ORDER

     *----------------------------------------------------------------

     *  *INZSR  Initialization subroutine

     C     *inzsr        begsr

     *   Define partial key for LABEL90 file.

     C     keyLB90       klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptrn#

     C                   endsr
     *-------------------------------------------------------------------------
