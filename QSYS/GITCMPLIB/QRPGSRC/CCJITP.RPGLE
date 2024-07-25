      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CCJITP    Process Truck Builder Transactions to create Priority
     *            Replenishments
     *
     *  10 October 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
500 A*    10/07/05  MLB  5.00
     *      - Created.
     *
730aA*    11/04/19  DAS  7.30a
     *      - Revised to use LABEL7W
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     FPirtran3  if   e           k disk
730aMFlabel7w   if   e           k disk

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

     *   Redefine key

     D  $pwhse                19     21  0
     D  $prte                 22     26
     D  $pgrp1                27     27
     D  $pgrp2                28     28

     *----------------------------------------------------------------
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80

     *   Redefine key

     D  $ltrn#                19     25  0
     D  $litem                26     40

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n
     D kywhse          s                   like(lbwhse)
     D kytrn#          s                   like(lbtrn#)
     D holditem        s                   like(lbitem)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD     -  *TKPRTY - Create Truck Builder priority Replen
     *      $PWHSE    -  Warehouse
     *      $PRTE     -  Route ID number
     *      $PGRP1    -  Always S=Selection
     *      $PGRP2    -  Blank for regular routes
     *                   W for Will Call routes
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     * Call program to create JIT replenishment for each label in tran.

     C                   eval      kyrtpo = $prte
     C     keypt         setll     pirtran3
     C     keypt         reade     pirtran3
     C                   dow       Not %eof(pirtran3)
     C
     C                   eval      holditem = *blanks
     C                   eval      kywhse = ptwhse
     C                   eval      kytrn# = pttrn#
730aMC     lbkey         setll     label7W
     C                   dow       forever = forever

730aMC     lbkey         reade     label7W
     C                   select
730aMC                   when      %eof(label7W)
     C                   leave

     * We want to make sure that we are in correct warehouse.
     C                   when      lbwhse <> ptwhse
     C                   leave

     * Only process 'O' label records.
     C                   when      lbtype <> 'O'
     C                   iter

     * We also only want to do the call if item has changed           .
     C                   when      lbitem = holditem
     C                   iter

     C                   other

     * Item changed. Call Priority Replenishment pgm.
     C                   eval      holditem = lbitem

     C                   eval      $ltrn# = lbtrn#
     C                   eval      $litem = lbitem

     C                   call      'CCRPL'
     C                   parm                    $lparm

     C                   endsl

     C                   enddo

     C     keypt         reade     pirtran3
     C                   enddo

     C                   eval      *inlr = *on
     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define partial key for LABEL7 file.

     C     lbkey         klist
730aAC                   kfld                    $pwhse
     C                   kfld                    kytrn#

     *  Define partial key for PIRTRAN3 file.

     C     *like         define    ptrtpo        kyrtpo
     C     keypt         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pgrp1
     C                   kfld                    $pgrp2
     C                   kfld                    kyrtpo

     C                   eval      $lprg = #prog
     C                   endsr
