     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDTPC60   Q&D - Remove slots created in error in dept DRY.
     *  13 February 2017
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
TPC A*    02/13/17  MLB  TPC
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     FSLOT2RMV  if   e             disk    rename(slot2rmv : slot2rmvr)
     FSLOT1     uf   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D count           s              3  0
     D error           s              1
     D forevr          s              1

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
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse      - Warehouse
     *      $pwhdp      - Department
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
     *
     C     1             setll     slot2rmv
     C                   dow       forevr = forevr
     *
     C                   read      slot2rmv
     C                   if        %eof(slot2rmv)
     C                   leave
     C                   endif
     *
     *      Slot must be at Verified status in order to be deleted.
     C                   if        slstat <> 'V '
     C                   iter
     C                   endif
     *
     *      Delete SLOT1 record.
     *
     C     keySL1        chain     slot1
     C                   if            %found(slot1)
     C                             and slstat = 'V '
     C                   delete    slrec
     C                   endif
     *
     C                   enddo
     *
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * SLOT1 file
     *
     C     keysl1        klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    slaisl
     C                   kfld                    slloc
     C                   kfld                    slrlvl
     C                   kfld                    slhand
     *
     C                   endsr
