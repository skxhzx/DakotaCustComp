640aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GetTotTrax  Get tote trax number
     *  16 March 2012
     *  Jeffrey Jahnkele
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    03/16/12  JCJ  6.40a
     *      - Created
     *
CWD A*    04/28/15  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. Physical file had order id added
     *        to make file key unique.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Ftotehdr   if   e           k disk
     Fordp5     if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D temp5a          s              5
     D forever         s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse  Warehouse
     *      $prtid  Route ID
     *      $ptrn#  Transaction number
     *
     *    Returned Parameters
     *      $ptoteTrax#  Trax number for a tote
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $ptrn#            7 0
     C                   parm                    $ptoteTrax#      10

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  Loop through TOTEHDR recs for route until Physical Tran
     *  is found.

     C     keythdr       setll     totehdr

     C                   dow       forever = forever
     C     keythdr       reade     totehdr
     C                   if        %eof(totehdr)
     C                   leave
     C                   endif

     C                   if        $ptrn# <> tohtr#
     C                   iter
     C                   endif

     C     keyod5        chain     ordp5
     C                   if        %found(ordp5)
     C                   eval      temp5a = %editc(orpup#:'X')
     C                   eval      $ptoteTrax# = $prtid + temp5a
     C                   leave
     C                   endif

     C                   enddo

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   eval      forever = *on

     *  Define key for TOTEHDR file.

     C     keythdr       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     *  Define key for ORDP5 file.

     C     keyod5        klist
     C                   kfld                    $prtid
     C                   kfld                    tohml#

     C                   endsr
