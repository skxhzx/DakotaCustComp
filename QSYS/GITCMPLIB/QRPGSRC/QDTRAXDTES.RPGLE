      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *----------------------------------------------------------------
     *
     *  QDTRAXDTES
     *
     *    Fix Trax dates which were uploaded incorrectly because of bad
     *    dates coming from the handheld. The date in the handheld which
     *    populates dates in the upload file is updated automatically when
     *    the Trax option "Sync date and time" is set to Y. But if it's not,
     *    the date will be corrupted if the client's router feeds it an
     *    incorrect date.
     *
     *  13 April 2015
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    04/13/15  RBD  7.00
     *      - Created.
     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
     *
     *----------------------------------------------------------------
     * File Specs

     Fttrte     uf   e           k disk
     Fttrtn3    uf   e           k disk
     fttstp     uf   e           k disk
     fttitm     uf   e           k disk
     Ftttrx     uf   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions

     *----------------------------------------------------------------
     *  Customer id

     *----------------------------------------------------------------
     *  Working variables

     D first           s              1
     D lastStop        s              2  0

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
     *      $PWHSE   Warehouse
     *      $PRTID   Route ID
     *      $PSTADTE Status Date
     *      $PSTATIM Status Time
     *      $PSTRDTE Start Date
     *      $PSTRTIM Start Time
     *      $PFINDTE Finish Date
     *      $PFINTIM Finish Time
     *      $PSCNDTE Scan Date
     *      $PSCNTIM Scan Time
     *      $PSIGDTE Signature Date
     *      $PSIGTIM Signature Time
     *
     *    Returned Parameters
     *      $PRTN   *OK      - Route was processed.
     *              *CANCEL  - Route was not processed.
     *      $PERM            - Error message.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $pstadte          8 0
     C                   parm                    $pstatim          8 0
     C                   parm                    $pstrdte          8 0
     C                   parm                    $pstrtim          8 0
     C                   parm                    $pfindte          8 0
     C                   parm                    $pfintim          8 0
     C                   parm                    $pscndte          8 0
     C                   parm                    $pscntim          8 0
     C                   parm                    $psigdte          8 0
     C                   parm                    $psigtim          8 0
     C                   parm                    $prtn             8
     C                   parm                    $perm            60

     * Main line

     C                   eval      $prtn = '*OK    '

     *  Loop through Trax route file and fix dates

     C     keyTrx        setll     ttrte
     C                   dou       forevr <> forevr
     C     keyTrx        reade     ttrte
     C                   if        %eof(ttrte)
     C                   leave
     C                   endif
     C                   eval      ttrstd = $pstadte
     C                   eval      ttrstt = $pstatim
     C                   eval      ttrsrd = $pstrdte
     C                   eval      ttrsrt = $pstrtim
     C                   eval      ttrfid = $pfindte
     C                   eval      ttrfit = $pfintim
     C                   update    ttrrec
     C                   enddo

     *  Loop through Trax returns file and fix dates

     C     keyTrx        setll     ttrtn3
     C                   dou       forevr <> forevr
     C     keyTrx        reade     ttrtn3
     C                   if        %eof(ttrtn3)
     C                   leave
     C                   endif
     C                   eval      ttudte = $pfindte
     C                   eval      ttutim = $pfintim
     C                   eval      ttstsd = $pstadte
     C                   eval      ttstst = $pstatim
     C                   update    ttrec
     C                   enddo

     *  Loop through Trax stop file and fix dates

     C     keyTrx        setll     ttstp
     C                   dou       forevr <> forevr
     C     keyTrx        reade     ttstp
     C                   if        %eof(ttstp)
     C                   leave
     C                   endif
     C                   eval      ttpsrd = $pstrdte
     C                   eval      ttpsrt = $pstrtim
     C                   eval      ttpfid = $pfindte
     C                   eval      ttpfit = $pfintim
     C                   eval      ttpgdt = $psigdte
     C                   eval      ttpgtm = $psigtim
     C                   update    ttprec
     C                   enddo

     *  Loop through Trax item file and fix dates

     C     keyTrx        setll     ttitm
     C                   dou       forevr <> forevr
     C     keyTrx        reade     ttitm
     C                   if        %eof(ttitm)
     C                   leave
     C                   endif
     C                   eval      ttisrd = $pscndte
     C                   eval      ttisrt = $pscntim
     C                   update    ttirec
     C                   enddo

     *  Loop through Trax pieces file and fix dates

     C     keyTrx        setll     tttrx
     C                   dou       forevr <> forevr
     C     keyTrx        reade     tttrx
     C                   if        %eof(tttrx)
     C                   leave
     C                   endif
     C                   eval      ttxsrd = $pscndte
     C                   eval      ttxsrt = $pscntim
     C                   update    ttxrec
     C                   enddo

     C     bottom        tag

     C                   eval      *inlr = *on
     *----------------------------------------------------------------

     *          SUBROUTINES IN ALPHABETICAL ORDER

     *----------------------------------------------------------------

     *  *INZSR  Initialization subroutine

     C     *inzsr        begsr

     *   Define partial key for TTTRX file

     C     keyTrx        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     C                   endsr
     *-------------------------------------------------------------------------
