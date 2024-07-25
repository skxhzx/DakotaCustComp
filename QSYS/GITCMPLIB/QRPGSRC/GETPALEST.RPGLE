      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETPALEST Calculate Estimated pallets for receiving
     *  07 October 2014
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    10/07/14  LMC  6.50
     *      - Created
650aA*    10/28/14  LMC  6.50a
     *      - Added super po logic
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fpohdr     if   e           k disk
     Fpodtl     if   e           k disk
     Fitemdef   if   e           k disk
650aAFpospo     if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
     *
     *----------------------------------------------------------------
     *  Constants
     *
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D $pwhse          s              3s 0
     D $ppo            s              9
     D $pposeq         s              5  0
     D $poitem         s             15
     D $ptotpallet     s              5s 0
     D forever         s              1
     D wotie           s              5  0
     D wohi            s              5  0
650aAD super           s               n
     D svtie           s              5  0
     D svhi            s              5  0
     D tihiqty         s              5  0
     D workpallet      s              5s 0
     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *----------------------------------------------------------------
     *  Program info data structure
     *
      /copy qcopysrc,c#pgminfds
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PPO    Purchase Order
     *      $PPOSEQ Purchase Order Detail Seq#
     *      $POITEM  Item Number
     *
     *    Returned Parameters
     *      $PTOTPALLET  Total Pallets
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $ppo
     C                   parm                    $pposeq
     C                   parm                    $poitem
     C                   parm                    $ptotpallet
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * Main line
     *
      /free
         *inlr = *on;
650aA    // is $ppo a super po?
650aA    chain ($pwhse: $ppo) pospo;
650aA    if %found(pospo);
650aA      super = *on;
650aA    else;
650aA      super = *off;
650aA    endif;
         select;
           when $pposeq <> 0;
             exsr getone;
650aA      when super;
650aA        exsr getallsuper;
           other;
             exsr getall;
             return;
         endsl;
      /end-free

     *
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETONE        Calculate pallet for one item
     *
     C     getone        begsr
      /free
        $ptotpallet = 0;
        chain ($pwhse: $ppo: $pposeq: $poitem) podtl;
        select;
          when not %found(podtl);
          when %found(podtl);
            exsr zztihi;
            if tihiqty > 0;
              $ptotpallet = %div(pdqor1:tihiqty);
              if (%rem(pdqor1:tihiqty) <> 0);
                $ptotpallet += 1;
              endif;
            else;
              $ptotpallet = 1;
            endif;
        endsl;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETALL        Calculate pallets for all items on po
     *
     C     getall        begsr
      /free

        setll ($pwhse: $ppo) podtl;
        dow forever = forever;
          workpallet = 0;
          reade ($pwhse: $ppo) podtl;
          if %eof(podtl);
            leave;
          endif;
          exsr zztihi;
          if tihiqty > 0;
            workpallet = %div(pdqor1:tihiqty);
            if (%rem(pdqor1:tihiqty) <> 0);
              workpallet += 1;
            endif;
          else;
            workpallet = 1;
          endif;
          $ptotpallet = $ptotpallet + workpallet;
        enddo;
      /end-free
     C                   endsr
650aA*----------------------------------------------------------------
650aA*
650aA*  GETALLSUPER   Calculate pallets for all items on super po
650aA*
650aAC     getallsuper   begsr
650aA /free

650aA   // get the po's linked to the super po
650aA   setll ($pwhse: $ppo) pospo;
650aA   dow forever = forever;
650aA     reade ($pwhse: $ppo) pospo;
650aA     if %eof(pospo);
650aA       leave;
650aA     endif;
650aA     setll ($pwhse: pupo) podtl;
650aA     dow forever = forever;
650aA       workpallet = 0;
650aA       reade ($pwhse: pupo) podtl;
650aA       if %eof(podtl);
650aA         leave;
650aA       endif;
650aA       exsr zztihi;
650aA       if tihiqty > 0;
650aA         workpallet = %div(pdqor1:tihiqty);
650aA         if (%rem(pdqor1:tihiqty) <> 0);
650aA           workpallet += 1;
650aA         endif;
650aA       else;
650aA         workpallet = 1;
650aA       endif;
650aA       $ptotpallet = $ptotpallet + workpallet;
650aA     enddo;
650aA   enddo;
650aA /end-free
650aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZTIHI        Get Tie/Hi
     *
     C     ZZTIHI        begsr
      /free
        // get ti hi, preferred or 1st record
        wotie = 0;
        wohi = 0;
        svtie = 0;
        svhi = 0;
        tihiqty = 0;
        setll ($pwhse: pditem) itemdef;
        dow forever = forever;
          reade ($pwhse: pditem) itemdef;
          if %eof(itemdef);
            leave;
          endif;
          if svtie = 0  and
             svhi = 0;
            svtie = idtie;
            svhi = idhigh;
          endif;
          if idpref = 'Y';
            wotie = idtie;
            wohi = idhigh;
            leave;
          endif;
        enddo;
        // if no tie/hi preferred, use tie hi we found
        if wotie = 0  and
           wohi = 0;
          wotie = svtie;
          wohi = svhi;
        endif;
        tihiqty = wotie * wohi;
      /end-free
     C                   endsr
