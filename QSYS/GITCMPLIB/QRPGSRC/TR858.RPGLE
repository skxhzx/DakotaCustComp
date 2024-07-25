      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   24 Washington Ave North #203
     *   Batavia IL  60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR858   Create TTSTP records.
     *
     *  29 May 2012
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    05/29/12  RBD  6.40
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
     *
     *----------------------------------------------------------------
     * File Specs

     fordh9     if   e           k disk
     fttstp     uf a e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *
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

     *----------------------------------------------------------------
     *  Customer id

     *----------------------------------------------------------------
     *  Working variables

     D first           s              1
     D lastItemKey     s             28
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
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
     *
     *    Returned Parameters
     *      $PRTN   *OK      - Route was processed.
     *              *ERROR   - Error occurred.
     *      $PERM            - Error message.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
     C                   parm                    $prtn             8
     C                   parm                    $perm            60

     * Main line

     C                   eval      $prtn = '*OK     '

     *  Loop through order header and write a Trax stop record for each
     *  stop on the route that doesn't already exist.

     C     keyOrdh9      setll     ordh9
     C                   dou       forevr <> forevr
     C     keyOrdh9      reade     ordh9

     C                   if        %eof(ordh9)
     C                   leave
     C                   endif

     C     keyStp        chain     ttstp
     C                   if        not %found(ttstp)
     C                   exsr      addStop
     C                   endif

     C                   enddo

     C     bottom        tag

     C                   eval      *inlr = *on
     *----------------------------------------------------------------

     *          SUBROUTINES IN ALPHABETICAL ORDER

     *----------------------------------------------------------------

     *  *INZSR  Initialization subroutine

     C     *inzsr        begsr

     *   Define partial key for ORDH9 file

     C     keyOrdh9      klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     *   Define full key for TTSTP file

     C     keyStp        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    ohstop

     *   Call user added initialization routine.

     C                   exsr      zzinz

     C                   endsr
     *----------------------------------------------------------------

     *  addStop   Add Trax stop record

     C     addStop       begsr

     C                   eval      ttpwhs = $pwhse
     C                   eval      ttprti = $prtid
     C                   eval      ttpstp = ohstop
     C                   eval      ttpmem = *blanks
     C                   eval      ttprte = $prte
     C                   eval      ttpdlv = '0'
     C                   eval      ttpscn = '0'
     C                   eval      ttpqs1 = 0
     C                   eval      ttpqs2 = 0
     C                   eval      ttpqs3 = 0
     C                   eval      ttpqn1 = 0
     C                   eval      ttpqn2 = 0
     C                   eval      ttpqn3 = 0
     C                   eval      ttpqc1 = 0
     C                   eval      ttpqc2 = 0
     C                   eval      ttpqc3 = 0
     C                   eval      ttpqp1 = 0
     C                   eval      ttpqp2 = 0
     C                   eval      ttpqp3 = 0
     C                   eval      ttpsrd = 0
     C                   eval      ttpsrt = 0
     C                   eval      ttpfid = 0
     C                   eval      ttpfit = 0
     C                   eval      ttpgna = *blanks
     C                   eval      ttpgfn = *blanks
     C                   eval      ttpguc = *blanks
     C                   eval      ttpgsn = *blanks
     C                   eval      ttpgdt = 0
     C                   eval      ttpgtm = 0
     C                   eval      ttpcce = *blanks
     C                   eval      ttpsig = *blanks
     C                   eval      ttppiv = *blanks
     C                   eval      ttppal = *blanks
     C                   eval      ttpbul = *blanks

     C                   write(e)  ttprec
     C                   if        %error
     C                   eval      $prtn = '*ERROR  '
     C                   endif

     C                   endsr

     *----------------------------------------------------------------

     *  ZZINZ    Extra program initialization. Called from *INZSR.

     C     zzinz         begsr

     C                   endsr

     *-------------------------------------------------------------------------
