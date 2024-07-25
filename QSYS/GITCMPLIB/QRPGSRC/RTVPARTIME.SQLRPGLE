      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H bnddir('QC2LE':'QUSAPIBD':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 601510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RTVPARTIME   Retrieve Partition Time
     *  04 May 2023
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    05/04/23  KDE  7.70
     *      - Created
     *
     *----------------------------------------------------------------
     *  Custom Revisions:
     *
     *  File Specs
     *
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------

     *  Customer id
     *

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

     *
     *----------------------------------------------------------------
     *  Variables
     *
     D returnTime      s              8

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Returned Parameters
     *      Time formatted as hh:mm:ss
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    returnTime
     *
     c                   monitor
     c                   eval      returntime=' '
     c                   on-error
     c                   return
     c                   endmon

     c                   call      'CHKOBJCL'
     c                   parm      'TZNEXE'      obj              10
     c                   parm      '*LIB'        objtype          10
     c                   parm      ' '           objerror          6
      /free
                         if        objerror = 'ERROR';
              // a return of error means no timezone/400 loaded
              // so we use basic system time
                           eval returnTime = %editc(%dec( %time() : *HMS ):'X');
                         else;
              // else, we will call program in Timezone/400 to retrieve
              // non adjusted partition time
      /end-free
     c                   call      'TZNAPI07'
     c                   parm      ' '           baseTime         26
      /free
                           eval returnTime = %editc(%dec(
                                         %time(%timestamp(baseTime)):*hms):'X');
                         endif;
                         *inlr = *on;
      /end-free
