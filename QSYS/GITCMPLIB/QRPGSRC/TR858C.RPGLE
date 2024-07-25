      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------
     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TR858C    Change/Undo TRAX Stop flag records
     *  07 April 2020
     *  Ginger Andrews
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    04/07/20  GJA0 7.40
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fttstpflg  uf   e           k disk

     *----------------------------------------------------------------
     *  Program info data structure

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables.
     *----------------------------------------------------------------

     D forever         s               n

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStampsys    s               z
     D CurrStampuc     s               z

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------
     ***    Used to Get time stamp values
     d GetCurrStamp    pr

     D GetMicroTime    pr
     D  $pmicrouc                      z
     D  $pmicrolocal                   z
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route id current
     *      $PRTID2 Route id new
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prtid2           5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C     keystp        setll     ttstpflg

      /free
        GetCurrStamp();
      /end-free
     C                   dow       forever = forever
     C     keystp        reade     ttfrec
     C                   if        %eof(ttstpflg)
     C                   leave
     C                   else
     C                   eval      ttfrti=$prtid2
     C                   eval      ttfchgts= CurrStampSys
     C                   eval      ttfchguc= CurrStampUC
     C                   eval      ttfchgusr= #user
     C                   eval      ttfchgjob= #job
     C                   eval      ttfchgnbr = #jobnbr
     C                   update    ttfrec
     C                   endif
     C                   enddo

     *  Bye, Bye

     C     bottom        tag
     C                   eval      *inlr = *on
     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *inzsr  -  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define partial key for TTSTP file.

     C     keystp        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     C                   endsr
     *----------------------------------------------------------------
     *  GetCurrStamp - Get Current TimeStamps
     *----------------------------------------------------------------
     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free
         getmicrotime(currstampuc:currstampsys);
      /end-free

     p GetCurrStamp    e
