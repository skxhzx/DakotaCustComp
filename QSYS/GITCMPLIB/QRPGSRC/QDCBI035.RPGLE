      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *----------------------------------------------------------------
     *
     *  QDCBI035
     *
     *    Created pgm to process the PIRITEM file to add/update rcds
     *    in file ITMDIFFD for buyer#: 150, 155 and 160 where ITWHDP
     *    = FRZ. Add or update new dept = CLR. Then update ITWHDP in
     *    PIRITEM. Only do update for items with no inventory.
     *
     *----------------------------------------------------------------
     *  27 March 2017
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
CBI A*    03/27/17  MLB  CBI
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
     *
     *----------------------------------------------------------------
     * File Specs

     Fpiritem   uf   e           k disk
     Fitmdiffd  uf a e           k disk
     Fitemmsc   if   e           k disk
     Fitemqty   if   e           k disk

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

     C     $pwhse        setll     piritem
     C                   dou       forevr <> forevr
     C     $pwhse        reade     piritem
     C                   if        %eof(piritem)
     C                   leave
     C                   endif
     *
     *      Process only dept FRZ items.
     C                   if        itwhdp <> 'FRZ'
     C                   iter
     C                   endif
     *
     *      Bypass an items with qty in stock.
     C     keyit         chain     itemqty
     C                   if        not %found(itemqty)
     C                             or %found(itemqty)
     C                             and (iqstk1 <> 0
     C                               or iqstk2 <> 0
     C                               or iqstk3 <> 0)
     C                   iter
     C                   endif
     *
     C     keyit         chain     itemmsc
     C                   if             %found(itemmsc)
     C                              and itwhdp = 'FRZ'
     C                             and (imbnbr = 150
     C                               or imbnbr = 155
     C                               or imbnbr = 160)

     C     ititem        chain     itmdiffd
     C                   if        not %found(itmdiffd)
     C                   eval      iditem = ititem
     C                   eval      iddesc = itdesc
     C                   eval      idodpt = itwhdp
     C                   eval      idsdpt = 'CLR  '
     C                   write     idifrc

     C                   eval      itwhdp = idsdpt
     C                   update    itrec

     C                   else

     C                   eval      idodpt = itwhdp
     C                   eval      idsdpt = 'CLR  '
     C                   update    idifrc

     C                   eval      itwhdp = idsdpt
     C                   update    itrec
     C                   endif

     C                   endif

     C                   enddo

     C     bottom        tag

     C                   eval      *inlr = *on
     *----------------------------------------------------------------

     *          Subroutines In Alphabetical Order

     *----------------------------------------------------------------

     *  *INZSR  Initialization subroutine

     C     *inzsr        begsr

     *   Define full key for PIRITEM file.

     C     keyIT         klist
     C                   kfld                    $pwhse
     C                   kfld                    ititem
     C                   endsr
     *-------------------------------------------------------------------------
