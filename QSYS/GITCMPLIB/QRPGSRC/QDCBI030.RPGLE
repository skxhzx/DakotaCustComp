      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *----------------------------------------------------------------
     *
     *  QDCBI030
     *
     *    Created pgm to process the ITMDIFFD file to update PIRITEM
     *    ITWHDP with dept different that what is on file in SAP.
     *
     *----------------------------------------------------------------
     *  27 February 2017
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
CBI A*    02/27/17  MLB  CBI
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
     *
     *----------------------------------------------------------------
     * File Specs

     Fitmdiffd  if   e           k disk
     Fpiritem   uf   e           k disk

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

     C     *loval        setll     itmdiffd
     C                   dou       forevr <> forevr
     C                   read      itmdiffd
     C                   if        %eof(itmdiffd)
     C                   leave
     C                   endif
     *
     C     keyit         chain     piritem
     C                   if            %found(piritem)
     C                             and itwhdp <> idsdpt

     C                   eval      itwhdp = idsdpt

     C                   update    itrec
     C                   else
     C                   unlock    piritem
     C                   endif

     C                   enddo

     C     bottom        tag

     C                   eval      *inlr = *on
     *----------------------------------------------------------------

     *          SUBROUTINES IN ALPHABETICAL ORDER

     *----------------------------------------------------------------

     *  *INZSR  Initialization subroutine

     C     *inzsr        begsr

     *   Define full key for PIRITEM file.

     C     keyIT         klist
     C                   kfld                    $pwhse
     C                   kfld                    iditem
     C                   endsr
     *-------------------------------------------------------------------------
