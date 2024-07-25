     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  JITCLNUP     Cleanup JIT Slots Until Fully Live on TruckBuilder
     *  25 February 2011
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  NOTES:
     *      - Must compile at V5R2 or greater
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    02/25/11  MLB  6.40
     *      - Created
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

     Fslot11    uf   e           k disk
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
     *      $PCMD   *CLNJIT  - Cleanup JIT slots.
     *      $PWHS   Warehouse to process.
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
     C                   parm                    $paisl            3

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
     *
     C     keysl         setll     slot11
     C                   dow       forever = forever
     *
     C     keysl         reade     slot11
     C                   if        %eof(slot11)
     C                   leave
     C                   endif
     *
     C                   select
     C                   when      $pcmd = '*CLNJIT'
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
     * Item file
     *
     C     keysl         klist
     C                   kfld                    $pwhse
     C                   kfld                    $paisl
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
