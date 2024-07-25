     H option(*NODEBUGIO)
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  KT200     Print KIT Repack Errors Report
     *  30 January 2014
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650 A*  01/30/14  KDE  6.50
     *    - Created.
700 A*  05/14/15  KDE  7.00
     *    - Modified to update KitComp and KitItem when capable
     *      instead of simply throwing an error and requiring
     *      a user to manully update.  Changed error messages
     *      to report the update was done vs. the error exists
720 A*  08/23/18  KDE  7.20
     *    - Modified to create virtual on Ondemand Pick item if not
     *      found
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
     *----------------------------------------------------------------
     * Merit Foods Custom Revisions:
     *
MRT A*    09/19/19  MRT A
     *      - ENH: Create Virtual RP Status slot if not found
     *
MRTaA*    10/18/19  MRTaA
     *      - ENH: Always force base on baseodr for Merit.  ex, 42-250-1
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  xx        Universal xxxxxx xxxxxxxxx (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Dakota File Specs
     *----------------------------------------------------------------

     fkitcomp   if   e           k disk
     fkititem   if   e           k disk
     f*  for releases V6r1 and below override kitcmp to kitcomp
     f*  and compile using the kitcmp EXTFILE statement below
     f*  for releases above V6r1 simply un-asterick the *EXTDESC
     f*  and EXTDESC additional parm and apply asterick to
     f*  EXTFILE('KITCOMP') line
     f*kitcmp    if   e           k disk    EXTFILE('KITCOMP')
     fkitcmp    if   e           k disk    EXTFILE(*EXTDESC)
     f                                     EXTDESC('KITCOMP')
     f                                     rename(kcrec:kcrec1)
     f                                     prefix(kr)
     fpiritem2  if   e           k disk
     fpiritem1  if   e           k disk    rename(itrec:itrec1)
     f                                     prefix(i1_)
     fpiritem   if   e           k disk    rename(itrec:itrecm)
     f                                     prefix(im_)
     fslot12    if   e           k disk    rename(slrec:slrec12)
     fslot3     if   e           k disk    prefix(s3)
     fvslot1    if   e           k disk
     fitemdsc   if   e           k disk
     fkt200pr   o    e             printer oflind(*in90)

720 A*----------------------------------------------------------------
720 A*  DRI parameters
720 A*----------------------------------------------------------------
720 A
720 A /COPY *libl/qcopysrc,C#DRIPARMS
720 A
720 A*----------------------------------------------------------------
720 A*  Data Formats
720 A*----------------------------------------------------------------
720 A
720 A /COPY *libl/qcopysrc,C#SLOT
720 AD saveVer#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

MRT A /COPY QCOPYSRC,Id#mrt

     *----------------------------------------------------------------
     *  Sub Procedure Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     d desc            s             40    dim(15) ctdata perrcd(1)

     D ODRData         ds
     D aryODR                              dim(20)
     d  odritm                       15a   overlay(aryODR:*next)

700 A*----------------------------------------------------------
700 A*  SQL record layouts referenced
700 A*----------------------------------------------------------

700 AD ktrecu        E Ds                  Extname(Kitcomp)
700 Ad                                     prefix(k_)
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d #pwhse          s              3p 0 inz(0)
     d $type           s              1    inz('R')
     d baseODRSlot     s                   like(kcdisp)
     D fndrpSlot       s               n   inz('0')
     d forever         s              1    inz('1')
     D hldcitm         s                   like(kccitm)
     D hldItem         s                   like(kcitem)
     D hldWhdp         s                   like(itwhdp)
     D hldWhse         s                   like(kcwhse)
     d hmsmdy          s             12  0 inz
     d inactive        S               n
     D leaveNow        s               n   inz('0')
     d normalPck       S               n
     d odrelem         s              2  0 inz(0)
     D odritemflag     s               n   inz('0')
     d odrnext         s              2  0 inz(0)
     d pos             s              2  0 inz(0)
     D prvItem         s                   like(ititem)
     d rdate           s              6  0 inz
     d rppck           S               n
     d rtime           s              6  0 inz
     D rpslotfound     s               n   inz('0')
     D sq              c                   Const(X'7D')
     D SqlStmt         s           2000    inz(' ')
     D sqlSuccess      c                   '00000'
     d virtPck         S               n
     d wkpick          s              1    inz('Y')
     d wkstat          s              2    inz('A')
     D chk4err         s               n
     D error           s               n


     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     d                sds
     d  #prog            *proc
     D  #pgm             *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *     -Warehouse
     *     -Department
     *
     *    Returned Parameters
     *      -None -
     *
     *
     *----------------------------------------------------------------
     *
     *  Main line
     *
     *
     *----------------------------------------------------------------     ****
     C     *entry        plist
     C                   parm                    $pwhse            3
     C                   parm                    $pwhdp            5
     C                   parm                    $pinfo            1
      /free
         exsr init;
         // loop through all "R" type records for warehouse and
         //  department passed in looking for KIT errors

         setll (#pwhse:$type) piritem2;
         reade (#pwhse:$type) piritem2;

         dow forever = forever;

            if %eof(piritem2) or not %found(piritem2);
               leave;
            else;

              if $pwhdp = '*ALL' or itwhdp = $pwhdp;
                 wkrerr2 = ' ';
                // when record found locate in KITCOMP file
                 setll (itwhse:ititem) kitcomp;
                 reade (itwhse:ititem) kitcomp;

                 // if kit records missing report error
                 if %eof(kitcomp) or not %found(kitcomp);
                    kcqty1=0;
                    kcqty2=0;
                    kcqty3=0;
                    kcdisp = '** NOF **';
                    kcitem = ititem;
                    wkrerr = 'Repack configuration missing';
                    wkrerr2 = ' ';
                    exsr detailline;
                 endif;

                 dow not %eof(kitcomp) and %found(kitcomp);
                    chain (itwhse:ititem) kititem;

                    if not %found(kititem);
                      // odr header record not found
                       wkrerr = desc(4);
                       exsr detailline;
                    else;

                       //  set active flag
                       chain (itwhse:ititem) itemdsc;
                       if %found(itemdsc);
                          pos = %scan('*INACTIVE' : ixdsc2);
                          if pos > 0;
                             inactive = *on;
                          else;
                             inactive = *off;
                          endif;
                       else;
                          inactive = *off;
                          pos = 0;
                       endif;

                // if Work Order Item make sure slot empty
                       if kirptp = '1' and (kidisp<>' '
                           or kcdisp<>' ');
                          wkrerr = desc(7);
                          exsr detailline;
                       endif;

                // if On-Demand and no slot(s) in flag error if active
                       if kirptp = '2' and (kidisp = ' '
                           or kcdisp = ' ') and not inactive;
700 A                        eval  wkstat = 'RP';
700 A                        eval  wkpick = 'Y';
700 A                        setll (itwhse:kccitm:wkstat:wkpick)       slot3;
700 A                        reade (itwhse:kccitm:wkstat:wkpick)       slot3;
700 A                        // build dynamic message for user
700 A                        if not %eof(slot3) and %found(slot3)      ;
700 A                           wkrerr = 'ODR slot updated to ' +
700 A                                    %trim(s3sldisp);
                                exsr detailline;
700 A                           exsr updKitFiles;
700 A                        else;
700 A                           wkrerr = desc(8);
700 A                           wkrerr2 = ' ';
                                exsr detailline;
MRT A                           if client = Merit;
MRT A                             exsr clr$slot;
MRT A                             $slpicku = *on;
MRT A                             $slpick='Y';
MRT A                             $slrsrvu = *on;
MRT A                             $slrsrv='Y';
MRT A                             $slstatu = *on;
MRT A                             $slstat='RP';
MRT A                             $slwhseu = *on;
MRT A                             $slwhse  = kcwhse;
MRT A                             $slwhdpu = *on;
MRT A                             $slwhdp  = itwhdp;
MRT A                             $sldispu = *on;
MRT A                             select;
MRT A                               when %scan('42-250-1':kcdisp)>0;
MRT A                                  baseODRSlot = '42-250-1';
MRT A                               when %scan('84-208-1':kcdisp)>0;
MRT A                                  baseODRSlot = '84-208-1';
MRT A                               other;
MRT A                                  baseODRSlot = *blanks;
MRT A                             endsl;
MRT A                             $sldisp  = baseODRSlot;
MRT A                             $slitemu = *on;
MRT A                             $slitem  = kccitm;
MRT A                             $dricommand = '*SLOT';
MRT A                             $drisubcmd = '%CRTVPICK';
MRT A                             $drisys2upd = 'D';
MRT A                             chk4err = *on;
MRT A                             exsr zzzdricop;
MRT A                             if $drireturn = 'VRTPCKCRT';
MRT A                                // make sure RP Status is correct and
MRT A                                // pick and reserved
MRT A                                exec sql update slot2 set slstat='RP'
MRT A                                                         ,slrsrv='Y'
MRT A                                         where slwhse=:kcwhse and
MRT A                                             sldisp=:$sldisp and
MRT A                                             slwhdp=:itwhdp and
MRT A                                             slitem=:kccitm;
MRT A                             endif;
MRT A                          endif;
700 A                        endif;
                       endif;

                // Ensure dept for on-demand matches parent on kit record
                       if kirptp = '2' and not inactive;
720 A                     // Ensure virtual pick slot is created
720 A                     // for Case ODR slot if not found
720 A                     eval  wkstat = 'A';
720 A                     eval  wkpick = 'Y';
720 A                     setll (itwhse:kcitem:wkstat:wkpick)          slot3;
720 A                     reade (itwhse:kcitem:wkstat:wkpick)          slot3;
720 A                     if not %eof(slot3) and %found(slot3)         ;
720 A                        // do nothing since pick found on actual
720 A                        // Repack item
720 A                     else;
720 A                        baseODRSlot = kcdisp;
720 A                        // when found see if virtual or base
720 A                        chain (itwhse:itwhdp:kcdisp) vslot1;
720 A                        if %found(vslot1);
720 A                           baseODRSlot = vspdis;
720 A                        endif;
MRTaA                             if client = Merit;
MRTaA                               select;
MRTaA                                 when %scan('42-250-1':baseODRSlot)>0;
MRTaA                                    baseODRSlot = '42-250-1';
MRTaA                                 when %scan('84-208-1':baseODRSlot)>0;
MRTaA                                    baseODRSlot = '84-208-1';
MRTaA                                 other;
MRTaA                                    baseODRSlot = *blanks;
MRTaA                               endsl;
MRTaA                             endif;
720 A
720 A                  //    Call DRISLOT to create Virtual Pick Slot
720 A
720 A                        if baseODRSlot <> *blanks;
720 A                          exsr clr$slot;
720 A                          $slwhseu = *on;
720 A                          $slwhse  = kcwhse;
720 A                          $slwhdpu = *on;
720 A                          $slwhdp  = itwhdp;
720 A                          $sldispu = *on;
720 A                          $sldisp  = baseODRSlot;
720 A                          $slitemu = *on;
720 A                          $slitem  = kcitem;
720 A                          $dricommand = '*SLOT';
720 A                          $drisubcmd = '%CRTVPICK';
720 A                          $drisys2upd = 'D';
720 A                          chk4err = *on;
720 A                          exsr zzzdricop;
720 A                          if $drireturn = 'VRTPCKCRT';
720 A                             // make sure repack virtual is stat A
720 A                             exec sql update slot2 set slstat='A'
720 A                                      where slwhse=:kcwhse and
720 A                                            sldisp=:$sldisp and
720 A                                            slwhdp=:itwhdp and
720 A                                            slitem=:kcitem;
720 A                          endif;
720 A                        endif;
720 A                     endif;
                          chain (itwhse:kccitm) piritem;
                             if not %eof(piritem);
                                if im_itwhdp<>itwhdp;
                                   wkrerr = 'Dept mismatch item(' +
                                    %trim(ititem) + ') and (' +
                                    %trim(im_ititem) + ')';
                                    exsr detailline;
                                endif;
                                if im_itum2=' ' and im_itumq2 = 0
                                   and im_itum3=' ' and im_itumq3 = 0;
                                   wkrerr2 = ' ';
                                   wkrerr = 'Parent item(' +
                                    %trim(im_ititem) + ')' +
                                    ' must have brkdwn UOM';
                                    exsr detailline;
                                endif;
                             else;
                                wkrerr = desc(7);
                                exsr detailline;
                             endif;
                       endif;
                    endif;

                   // make sure kit slot is found on either parent
                   //  or odr item and warn of any repack item with
                   //  normal pick slot and any missing an odr slot
                    if kirptp = '2';
                       if not inactive;
                          exsr chkSlots;
                       endif;
                       wkstat='A';
                       clear slrec12;
                       setll (itwhse:kcdisp) slot12;
                       chain (itwhse:kcdisp) slot12;
                       if not %found(slot12) or %eof(slot12);
                          if not inactive and kcdisp <> ' ';
700 D     //                 wkrerr = 'Slot ' + %trim(kcdisp) +
700 D     //                    ' is not defined in slot file';
700 A                        eval  wkstat = 'RP';
700 A                        eval  wkpick = 'Y';
700 A                        setll (itwhse:kccitm:wkstat:wkpick)       slot3;
700 A                        reade (itwhse:kccitm:wkstat:wkpick)       slot3;
700 A                        // build dynamic message for user
700 A                        if not %eof(slot3) and %found(slot3)      ;
700 A                           wkrerr = 'ODR slot updated to ' +
700 A                                    %trim(s3sldisp);
700 A                           exsr updKitFiles;
700 A                        else;
700 A                           wkrerr = desc(8);
MRT A                           if client = Merit;
MRT A                             exsr clr$slot;
MRT A                             $slpicku = *on;
MRT A                             $slpick='Y';
MRT A                             $slrsrvu = *on;
MRT A                             $slrsrv='Y';
MRT A                             $slstatu = *on;
MRT A                             $slstat='RP';
MRT A                             $slwhseu = *on;
MRT A                             $slwhse  = kcwhse;
MRT A                             $slwhdpu = *on;
MRT A                             $slwhdp  = itwhdp;
MRT A                             $sldispu = *on;
MRT A                             select;
MRT A                               when %scan('42-250-1':kcdisp)>0;
MRT A                                  baseODRSlot = '42-250-1';
MRT A                               when %scan('84-208-1':kcdisp)>0;
MRT A                                  baseODRSlot = '84-208-1';
MRT A                               other;
MRT A                                  baseODRSlot = *blanks;
MRT A                             endsl;
MRT A                             $sldisp  = baseODRSlot;
MRT A                             $slitemu = *on;
MRT A                             $slitem  = kccitm;
MRT A                             $dricommand = '*SLOT';
MRT A                             $drisubcmd = '%CRTVPICK';
MRT A                             $drisys2upd = 'D';
MRT A                             chk4err = *on;
MRT A                             exsr zzzdricop;
MRT A                             if $drireturn = 'VRTPCKCRT';
MRT A                                // make sure RP Status is correct and
MRT A                                // pick and reserved
MRT A                                exec sql update slot2 set slstat='RP'
MRT A                                                         ,slrsrv='Y'
MRT A                                         where slwhse=:kcwhse and
MRT A                                             sldisp=:$sldisp and
MRT A                                             slwhdp=:itwhdp and
MRT A                                             slitem=:kccitm;
MRT A                             endif;
MRT A                          endif;
700 A                        endif;
                             wkrerr2 = ' ';
                             exsr detailline;
                          endif;
                       else;

                         // when found ensure it matches one of the items
                          if slitem <> kcitem and slitem <> kccitm
                              or slwhdp <> itwhdp;
                             // print for ONLY active items
                             if not inactive;
                                if slwhdp = itwhdp;    // slot dept and item dep
                                   eval  wkstat = 'RP';
                                   eval  wkpick = 'Y';
                                   setll (itwhse:kccitm:wkstat:wkpick) slot3;
                                   reade (itwhse:kccitm:wkstat:wkpick) slot3;
                                  // build dynamic message for user
                                   if not %eof(slot3) and %found(slot3);
700 D   //                            wkrerr = 'Item ' + %trim(kccitm) +
700 D   //                               ' not in slot ' + %trim(kcdisp);
700 D   //                            wkrerr2 = '   ODR slot should be ' +
700 D   //                               %trim(s3sldisp);
700 A                                 wkrerr = 'ODR slot updated to ' +
700 A                                          %trim(s3sldisp);
700 A                                 wkrerr2 = ' ';
700 A                                 exsr updKitFiles;
                                      exsr detailline;
                                   else;
                                      if not fndRpSlot;
                                         wkrerr = desc(8);
                                         wkrerr2 = ' ';
                                         exsr detailline;
MRT A                                    if client = Merit;
MRT A                                      exsr clr$slot;
MRT A                                      $slpicku = *on;
MRT A                                      $slpick='Y';
MRT A                                      $slrsrvu = *on;
MRT A                                      $slrsrv='Y';
MRT A                                      $slstatu = *on;
MRT A                                      $slstat='RP';
MRT A                                      $slwhseu = *on;
MRT A                                      $slwhse  = kcwhse;
MRT A                                      $slwhdpu = *on;
MRT A                                      $slwhdp  = itwhdp;
MRT A                                      $sldispu = *on;
MRT A                                      select;
MRT A                                         when %scan('42-250-1':kcdisp)>0;
MRT A                                           baseODRSlot = '42-250-1';
MRT A                                         when %scan('84-208-1':kcdisp)>0;
MRT A                                           baseODRSlot = '84-208-1';
MRT A                                         other;
MRT A                                           baseODRSlot = *blanks;
MRT A                                      endsl;
MRT A                                      $sldisp  = baseODRSlot;
MRT A                                      $slitemu = *on;
MRT A                                      $slitem  = kccitm;
MRT A                                      $dricommand = '*SLOT';
MRT A                                      $drisubcmd = '%CRTVPICK';
MRT A                                      $drisys2upd = 'D';
MRT A                                      chk4err = *on;
MRT A                                      exsr zzzdricop;
MRT A                                      if $drireturn = 'VRTPCKCRT';
MRT A                                         // make sure RP Status is correct and
MRT A                                         // pick and reserved
MRT A                                      exec sql update slot2 set slstat='RP'
MRT A                                                               ,slrsrv='Y'
MRT A                                                where slwhse=:kcwhse and
MRT A                                                      sldisp=:$sldisp and
MRT A                                                      slwhdp=:itwhdp and
MRT A                                                     slitem=:kccitm;
MRT A                                      endif;
MRT A                                    endif;
                                      endif;
                                   endif;
                                else;     // else print error that depts mismatc
                                   wkrerr = 'Dept (' + %trim(itwhdp) + ')' +
                                            ' for Item(' + %trim(kccitm) + ')';
                                   wkrerr2 = '   does not match slot dept(' +
                                             %trim(slwhdp) + ')';
                                   exsr detailline;
                                endif;   // end if for compare of slot and item
                             endif;
                          else;   //  print informational message that odr slot
                             if slitem = kcitem and not inactive;
                                wkrerr = '** Error **  RP Pick Slot' +
                                         ' exists on the';
                                wkrerr2 = '   ODR Item vs. the Parent Item';
                                exsr detailline;
                             endif;
                          endif;
                       endif;

                      // make sure if parent item is ODR item and has
                      //  pick that it is virtual over RP slot
                       chain (itwhse:itwhdp:kccitm) piritem1;
                       if %found(piritem1);
                          eval  wkstat = 'A';
                          eval  wkpick = 'Y';
                          setll (itwhse:kccitm:wkstat:wkpick) slot3;
                          reade (itwhse:kccitm:wkstat:wkpick) slot3;
                          dow not %eof(slot3);
                             chain (itwhse:itwhdp:s3sldisp) vslot1;
                              if not %found(vslot1);

                         //  print error if odr calling odr and
                         // pick slot on odr not virtual of RP slot
                                if i1_ittype = 'R';
                                   wkrerr = desc(5);
                                   exsr detailline;
                                endif;
                             endif;
                             reade (itwhse:kccitm:wkstat:wkpick) slot3;
                          enddo;
                       else;
                          if not inactive;
                             wkrerr = desc(6);
                             exsr detailline;
                          endif;
                       endif;
                    endif;   // on-demand type
                    reade (itwhse:ititem) kitcomp;
                 enddo;
               endif;   // does WHDP match something passed
            endif;   // has end of file been reached for PIRITEM
            reade (#pwhse:$type) piritem2;
         enddo;

          write total;
         *inlr = *on;

      /end-free

     * -------------------------------------------------------------------
     **  Initialize everything
     *--------------------------------------------------------------------

     c     Init          begsr
     c                   eval      #pwhse = %DEC($pwhse:3:0)
     c                   eval      *in90 = *off
     c                   time                    hmsmdy
     c                   Move      hmsmdy        rdate
     c                   movel     hmsmdy        rtime
     c                   write     header
MRT A
MRT A * Get client id.
MRT A
MRT AC                   call      'GETCLIENT'
MRT AC                   parm                    client           10
MRT AC                   parm                    clientloc        10
MRT A
     c                   endsr

     * -------------------------------------------------------------------
     **  Check items for slot issues
     *--------------------------------------------------------------------

     c     chkslots      begsr
      /free
        // first loop through slots for Repack item and warn of normal pick
           hldWhse = kcWhse;
           hldItem = Kcitem;
           hldcitm = Kccitm;
           hldWhdp = itWhdp;
           WKRERR2 = ' ';
           normalPck = *off;
           rpPck = *off;
           virtPck = *off;

           setll (itwhse:ititem) slot3;
           reade (itwhse:ititem) slot3;

           dow forever = forever;
              if not %eof(slot3) and %found(slot3);

                 select;
                    when s3slstat='A' and s3slrsrv='Y' and s3slpick='Y'
                         and slaisl<>'TR';
                       normalPck = *on;
                    when s3slstat='RP' and s3slpick='Y' and s3slaisl<>'RPK';
                       rpPck = *on;
                    when s3slstat='A' and s3slpick='Y' and s3slrsrv='V';
                       virtPck = *on;
                 endsl;

                 // warn when normal pick is on repack item
                 if normalPck and not rpPck;
                    wkrerr = '** Error **  Normal Pick' +
                     ' slot(' + %trim(s3sldisp) + ')';
                    wkrerr2 = '   found';
                    exsr detailline;
                 endif;

              else;
                 leave;
              endif;

              reade (itwhse:ititem) slot3;
           enddo;

       //  make sure rp slot exist for multi level odr structure

          fndrpSlot = *off;
          leavenow = *off;
          wkstat = 'RP';

          for odrelem = 1 to 20;
             odritm(odrelem) = ' ';
          endfor;

          odritm(1) = ititem;
          odrelem = 1;
          odrnext = 1;

          dow odritm(odrelem) <> ' ';

             // print informational message identifying multi-level odr item
             if odrelem = 2;
                if $pinfo = 'Y';
                   wkrerr = '** Info **  Repack Item' +
                         ' calls multiple';
                   wkrerr2 = '   levels deep';
                   exsr detailline;
                endif;
             endif;

             // if multi-level structure then ensure each level has breakdown de
             if odrelem > 1;
                chain (#pwhse:prvitem) piritem;
                if %found(piritem) and not %eof(piritem);
                   if im_itumq2 = 0 and im_itumq3 = 0;
                      wkrerr = '** Error **  Repack Item' +
                         ' in multi-level';
                      wkrerr2 = '  structure.  A breakdown qty must exist';
                      exsr detailline;
                   endif;
                endif;
             endif;

             setll (itwhse:odritm(odrelem)) kitcmp;
             reade (itwhse:odritm(odrelem)) kitcmp;

       //  check to see if RP slot exist on odr level first
             setll (itwhse:krkcitem:wkstat:wkpick) slot3;
             reade (itwhse:krkcitem:wkstat:wkpick) slot3;

             if not %eof(slot3) and %found(slot3);
                fndrpSlot = *on;
           //   leavenow = *on;
           //   leave;
             endif;

             dow not %eof(kitcmp) and %found(kitcmp);

                setll (itwhse:krkccitm:wkstat:wkpick) slot3;
                reade (itwhse:krkccitm:wkstat:wkpick) slot3;

                if not %eof(slot3) and %found(slot3);
                   fndrpSlot = *on;
            //     leavenow = *on;
            //     leave;
                endif;

                chain (hldwhse:hldwhdp:krkccitm) piritem1;
                if %found(piritem1);
                   if i1_ittype = 'R';
                      odrnext = odrnext+1;
                      if odrnext <= 20;
                         odritm(odrnext) = krkccitm;
                      else;
                         leavenow = *on;
                         leave;
                      endif;
                   endif;
                else;
                   leave;
                endif;

                reade (itwhse:odritm(odrelem)) kitcmp;
             enddo;

         if leavenow;
            leave;
         else;
            prvItem = odritm(odrelem);
            odrelem = odrelem+1;
         endif;

       enddo;

      /end-free
     c                   endsr

     * -------------------------------------------------------------------
     **  Print Error Detail line
     *--------------------------------------------------------------------

     c     detailline    begsr
      /free
          // if overflow on print headings
          if *in90 = *on;
             write header;
             *in90 = *off;
          endif;

          wktote =wktote + 1;

          write detail;
          if wkRerr2 <>' ';
             write detail2;
          endif;
          wkrerr2 = ' ';

      /end-free
     c                   endsr

     * -------------------------------------------------------------------
     **  Update Kit Files when possible from info available
     *--------------------------------------------------------------------

     c     updKitFiles   begsr
      /free
          SqlStmt = 'Select KITCOMP.* from KITCOMP,KITITEM ' +
                 ' where kcwhse = ' + %char(itwhse) +
                 ' and kccitm = ' + sq + %trim(kccitm) + sq +
                 ' and kcdisp <> ' + sq + %trim(s3sldisp) + sq +
                 ' and kcwhse = kiwhse and kcitem=kiitem' +
                 ' and kirptp = ' + sq + '2' + sq;

           exec sql PREPARE ktc FROM :SqlStmt;
           exec sql DECLARE KitC SCROLL CURSOR FOR ktc;
           exec sql OPEN KitC;

           exec sql
            fetch first from KitC into :ktrecu;
            if sqlstt = '00000';
               dow sqlstt = '00000';
                  if kirptp = '2';  // if on demand item update odr slot
                     // update KitItem record
                     exec sql
                      update kititem set kidisp = :s3sldisp
                       where kiwhse = :itwhse and kiitem = :k_kcitem;
                     // update KitComp record
                     exec sql
                      update kitcomp set kcdisp = :s3sldisp
                       where kcwhse = :itwhse and kcitem = :k_kcitem
                           and kccitm = :k_kccitm and kcdisp <> :s3sldisp;
                  endif;
                  exec sql
                   fetch next from KitC into :ktrecu;
               enddo;
            endif;
            exec sql CLOSE KitC;
      /end-free
     c                   endsr
720 A*----------------------------------------------------------------
720 A*----------------------------------------------------------------
720 A*                     DRI SUBROUTINES
720 A*----------------------------------------------------------------
720 A*----------------------------------------------------------------

720 A*----------------------------------------------------------------
720 A*  clr$slot  Clear $slot data structure fields
720 A*----------------------------------------------------------------
720 A
720 AC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr
720 A
720 A*----------------------------------------------------------------
720 A*  zzzdricop  Call DRICOP
720 A*----------------------------------------------------------------
720 A
720 AC     zzzdricop     begsr
     C                   eval      error = *off

     C                   eval      $dridata = $slot

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C*                  eval      errmsg    = 'Error occured on call to '
     C*                                      + 'DRICOP'
     C*                                      + '/' + %trim($drisubcmd)
     C*                                      + ' from ' + #prog
     C*                  exsr      zm0105

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C*                  exsr      zm0001

     C                   endsl

     C                   eval      $slot = $dridata

     C                   eval      chk4err = *off
     C     enddricop     endsr
     *
     *  COMPILE TIME TABLES
     *
**
Item Not Found In Dakota.
ODR Slot not found for parent item
Warehouse Not Found, Not Adjusted.
Repack item has NO Kititem record
Parent itm pck slt NOT virtual of RP Slot
Parent item not found in item master
Slot not valid for Work Order Repack
RP slot not found for parent
ODR Slot required for On-Demand Item
