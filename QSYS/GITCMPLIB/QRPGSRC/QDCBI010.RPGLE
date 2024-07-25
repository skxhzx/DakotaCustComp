      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *----------------------------------------------------------------
     *
     *  QDCBI010
     *
     *    Created pgm to process individual items and re-compute
     *    slot expiration date and update license FIFO date.
     *    PUrchasing staff updated item date sensitive days on a number
     *    of items necessitating the expiration date, fifo dates needing
     *    to be recomputed.
     *
     *----------------------------------------------------------------
     *  08 February 2017
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
CBI A*    02/08/17  MLB  CBI
     *      - Created.
     *
CBIaA*    02/17/17  MLB  CBIa
     *      - Enh: Revised pgm to only update overflow slots with
     *        Entered Date <= 20170206. Per Gus C. phone call.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
     *
     *----------------------------------------------------------------
     * File Specs

     Fcbiitem   if   e           k disk
     F                                     prefix(a)
     Fslot10    if   e           k disk
     Flicactive1if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.clcdur2

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $cdCmd          s              8
     D $cdDatein       s              8  0
     D $cdTimein       s              6  0
     D $cdYears        s              3  0
     D $cdMonths       s              3  0
     D $cdDays         s              3  0
     D $cdHours        s              3  0
     D $cdMinutes      s              3  0
     D $cdSeconds      s              3  0
     D $cdDateout      s              8  0
     D $cdTimeout      s              6  0

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
     *      $Pitem   Item number
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
     C                   eval      $lprg  = 'QDCBI010'

     *  Loop through CBI Item Work file and fix dates

     C     $pwhse        setll     cbiitem
     C                   dou       forevr <> forevr
     C     $pwhse        reade     cbiitem
     C                   if        %eof(cbiitem)
     C                   leave
     C                   endif
     *
     *      Skip items with no change in days.
     C                   if        acbidiff = 0
     C                   iter
     C                   endif
     *
     C                   eval      kypick = 'N'
     C                   eval      kystat = 'A'
     *
     C     keysl10       setll     slot10
     C                   dou       forevr <> forevr
     C     keysl10       reade     slot10
     C                   if        %eof(slot10)
     C                   leave
     C                   endif
     *
     *      Skip slots with BFC designation.
     C                   if        sldesg = 'BFC'
CBIaAC                             or slentd >= 20170207
     C                   iter
     C                   endif
     *
     C     keyla         setll     licactive1
     C     keyla         reade     licactive1
     C                   if        not %eof(licactive1)
     *
     *    Compute new expiration date to be updated on license/slot.
     *
      /free
       if acbidiff > 0;
         $cddays = acbidiff;
         $cdcmd = '*SUB    ';
         else;
         $cddays = acbidiff * -1;
         $cdcmd = '*ADD    ';
       endif;

       clcdur2($cdcmd: laexpd: $cdtimein: $cdyears:
               $cdmonths: $cddays: $cdhours: $cdminutes:
               $cdseconds: $cddateout: $cdtimeout);

      /end-free
     C                   call      'LT312CBI'
     C                   parm      '*CHANGEB'    $pcmd             8
     C                   parm      acbiwhse      $pwhse            3 0
     C                   parm      lalcns        $plcns           15
     C                   parm      $cddateout    $pexpd            8 0
     C                   parm      ' '           $prtn             8
     C                   endif
     *
     C                   enddo
     *
     C                   enddo

     C     bottom        tag

     C                   eval      *inlr = *on
     *----------------------------------------------------------------

     *          SUBROUTINES IN ALPHABETICAL ORDER

     *----------------------------------------------------------------

     *  *INZSR  Initialization subroutine

     C     *inzsr        begsr

     *   Define partial key for LABEL90 file.

     C     *like         define    slstat        kystat
     C     *like         define    slpick        kypick
     C     keysl10       klist
     C                   kfld                    $pwhse
     C                   kfld                    acbiitem
     C                   kfld                    kystat
     C                   kfld                    kypick

     *   Define partial key for LICACTIVE1 file.

     C     keyla         klist
     C                   kfld                    acbiwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
     C                   kfld                    slitem

     C                   endsr
     *-------------------------------------------------------------------------
