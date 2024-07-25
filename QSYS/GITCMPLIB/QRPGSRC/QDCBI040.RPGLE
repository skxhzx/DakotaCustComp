      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *----------------------------------------------------------------
     *
     *  QDCBI040
     *
     *    Created pgm to process the IMPFSTUF3 file to update SLOT2
     *    SLSDEF with value from SIDGTP if SLSDEF = XX.
     *
     *----------------------------------------------------------------
     *  28 March 2017
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
CBI A*    03/28/17  MLB  CBI
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
     *
     *----------------------------------------------------------------
     * File Specs

     Fimpfstuf3 if   e           k disk
     Fslot2     uf   e           k disk    rename(slrec : slrec2)

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

     C     $pwhse        setll     impfstuf3
     C                   dou       forevr <> forevr
     C     $pwhse        reade     impfstuf3
     C                   if        %eof(impfstuf3)
     C                   leave
     C                   endif
     *
     C     keysl2        chain     slot2
     C                   if            %found(slot2)
     C                             and slsdef = 'XX'
     C                             and sidgtp > ' '

     C                   eval      slsdef = sidgtp

     C                   update    slrec2
     C                   else
     C                   unlock    slot2
     C                   endif

     C                   enddo

     C     bottom        tag

     C                   eval      *inlr = *on
     *----------------------------------------------------------------

     *          SUBROUTINES IN ALPHABETICAL ORDER

     *----------------------------------------------------------------

     *  *INZSR  Initialization subroutine

     C     *inzsr        begsr

     *   Define full key for SLOT2 file.

     C     keysl2        klist
     C                   kfld                    $pwhse
     C                   kfld                    siwhdp
     C                   kfld                    sidisp
     C                   endsr
     *-------------------------------------------------------------------------
