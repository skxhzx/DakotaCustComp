      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *----------------------------------------------------------------
     *
     *  QDCBI002
     *
     *    Created pgm to process the PIRTRAN file looking for field
     *    PTSTAT <> 4. When found, update PIRTRAN and LABEL files to
     *    close label and transaction records when LBDISP = blanks.
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
CBIaA*    11/27/16  MLB  CBIa
     *      - Enh: Revised pgm to process open receivings older than
     *        less than or equal to 11.24.2016. Per Keith S on-site.
CBIbA*    11/27/16  MLB  CBIb
     *      - Enh: Revised pgm to process open returns older than
     *        less than or equal to 11.24.2016. Per Keith S on-site.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
     *
     *----------------------------------------------------------------
     * File Specs

     Fpirtran4  uf   e           k disk
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
     C                   eval      $lprg  = 'QDCBI002'

     *  Loop through Trax route file and fix dates

     C     $pwhse        setll     pirtran4
     C                   dou       forevr <> forevr
     C     $pwhse        reade     pirtran4
     C                   if        %eof(pirtran4)
     C                   leave
     C                   endif
     *
     C                   select
     C                   when          pttask = 'PUTRTN'
     C                             and ptstat < '4'
CBIaAC                             and ptgdte <= 20161124
     *
     C     keylb90       setll     label90
     C     keylb90       reade     label90
     C                   if        not %eof(label90)
     *    Force label to Closed status.
     C                             and lbstat <> 'C'
     C                             and lbdisp = ' '
     C                   eval      lbstat = 'C'
     C                   update    lbrec

     *      Force Transaction closed.
     C                   eval      ptstat = '4'
     C                   eval      ptedte = ptgdte
     C                   eval      ptcdte = ptgdte
     C                   update    ptrec
     C                   endif
     C                   unlock    label90

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
     C                   kfld                    pttrn#

     C                   endsr
     *-------------------------------------------------------------------------
