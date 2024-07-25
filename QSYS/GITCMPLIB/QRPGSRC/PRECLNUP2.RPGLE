     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  PRECLNUP2    Cleanup PRE Slots & Licenses Only.
     *  06 July 2011
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  NOTES:
     *      - Must compile at V5R2 or greater
     *      - This program is meant to only cleanup PRE slots for routes
     *        that were picked, closed and exported back to Host. The
     *        item quantities must have been picked and deducted from
     *        inventory as this pgm will delete the PRE slots and re-
     *        compute item warehouse qty from slots.  The license
     *        plate info is updated by a call to LT001 with parm FIX
     *        and specific slot info to be updated.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    07/06/11  MLB  6.40
     *      - Created
     *
650 A*    03/28/13  MLB  6.50
     *      - Q&D: Revised pgm to process all PRE slots and delete the slot,
     *        re-calc whse qty and fix license info. This was done to
     *        cleanup a large number of stranded PRE pick slots that were
     *        created when the operator sent the routes to TB with the PRE-
     *        pick flag set to Y=Yes for the Regular routes.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
ccc A*    mm/dd/yy  iii  cccccccccc
     *      -
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

650 DF*prexref3  if   e           k disk
650 DF*slot2     uf   e           k disk
650 MFslot1     uf   e           k disk
     Fvslot1    uf   e           k disk

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------


     D client          s             10
     D clientloc       s             10
     D $utwhse         s             15  5

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s              1    inz('1')
     D $pwhse          s              3  0

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#PGMINFDS

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CLNPRE  - Cleanup PRE slots.
     *      $PWHS   Warehouse to process.
650 A*      $PWHDP  Warehouse department to process.
     *      $PAISL  Warehouse aisle to process.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pcmd            10
     C                   parm                    $pwhs             3
650 AC                   parm                    $pwhdp            5
     C                   parm                    $paisl            3
650 DC*                  parm                    $prte             5
650 DC*                  parm                    $prtid            5

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
     *
650 DC*    keypx         setll     prexref3
650 MC     keysl         setll     slot1
     C                   dow       forever = forever
     *
     *      Process PRE-pick Cross Ref file for selected Route/Route ID.
650 DC*    keypx         reade     prexref3
650 MC     keysl         reade     slot1
650 DC*                  if        %eof(prexref3)
650 MC                   if        %eof(slot1)
     C                   leave
     C                   endif
     *
650 DC*                  if        pxhrte <> $prte
650 DC*                  iter
650 DC*                  endif
     *
     *
650 DC*    keysl         chain     slot2
650 DC*                  if        not %found(slot2)
650 DC*                  iter
650 DC*                  endif
     *
     C                   select
     C                   when      $pcmd = '*CLNPRE'
     C
     C     keyvs         chain     vslot1
     C                   if        %found(vslot1)
     C                   delete    vsrec
     C                   endif
     C
     C                   delete    slrec
     C
     *      Recalc warehouse qty after JIT slot deleted.
     C                   exsr      zzical
     C
     *      Update license info after JIT slot deleted.
     C                   exsr      zzfixlic
     C                   endsl
     *
     C                   enddo
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr

     *  Get client id

     C                   call      'GETCLIENT'
     C                   parm                    client
     C                   parm                    clientloc
     *
     * Key definitions
     *
     * PRE Pick Cross Reference file
     *
650 DC*    keypx         klist
650 DC*                  kfld                    $pwhse
650 DC*                  kfld                    $prtid
     *
     * Item file
     *
     C     keysl         klist
     C                   kfld                    $pwhse
650 DC*                  kfld                    pxsdep
650 MC                   kfld                    $pwhdp
650 DC*                  kfld                    pxdisp
650 MC                   kfld                    $paisl
     *
     *  VSLOT file
     *
     C     keyvs         klist
     C                   kfld                    slwhse
     C                   kfld                    slwhdp
     C                   kfld                    sldisp
     *
     *  Define variables
     *
     C                   move      $pwhs         $pwhse
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZICAL   Recalculate item quantity from slots for individual item.
     *
     C     zzIcal        begsr
     *
     * Recalculate item qty.
     C                   eval      $utwhse = $pwhse
     C                   eval      $jobq = 'Y'
     C                   call      'UT812'
     C                   parm                    $utwhse
     C                   parm      slitem        $uitem           15
     C                   parm                    $jobq             1
     C                   parm                    $lprg
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *
     C     endcal        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIXLIC   Fix License Plate file after JIT slot is deleted.
     *
     C     zzFixLic      begsr
     *
     C                   call(e)   'LT001'
     C                   parm      'FIX'         lpAction          3
     C                   parm      slwhse        lpWhse            3 0
     C                   parm      slwhdp        lpWhdp            5
     C                   parm      sldisp        lpDisp           12
     C                   parm      ' '           lpDummy           1
     *
     C     endFixLic     endsr
     *
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
