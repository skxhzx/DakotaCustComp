610aA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  UT313   Plus adjust ODR Repack Item and Negative adjust
     *          the case item by same value.  This is done for
     *          customers who use ODR process during inbound only
     *
     *          ** NOTE **
     *          This is intended to run for INBOUND only customers
     *          that are using the ODR process.  Once they are using
     *          OUTBOUND this should be stopped, since it would
     *          make adjustments based on Negative Repack item
     *          Stock Quantity 1 (Child item)
     *
     *  20 September 2018
     *  Kenneth Elder
     *
     *  09/20/18  KDE 7.20
     *    - Created
     *
     *----------------------------------------------------------------
     *  File Specs
     *
610aMFslot2     if   e           k disk
610aMFpiritem   if   e           k disk

610aA*----------------------------------------------------------------
610aA*  DRI parameters
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,C#DRIPARMS
610aA

610aA*----------------------------------------------------------------
610aA*  Data Structure for Negative Repack Slots
610aA*----------------------------------------------------------------

     d ngRpk           ds           100
     d   ngwhse                       3  0 overlay(ngrpk)
     d   ngwhdp                       5    overlay(ngrpk:*next)
     d   ngritm                      15    overlay(ngrpk:*next)
     d   ngpitm                      15    overlay(ngrpk:*next)
     d   ngrdis                      12    overlay(ngrpk:*next)
     d   ngpdis                      12    overlay(ngrpk:*next)
     d   ngbdis                      12    overlay(ngrpk:*next)
     d   ngstat                       2    overlay(ngrpk:*next)
     d   ngstk1                       5  0 overlay(ngrpk:*next)
     d   ngrptp                       1    overlay(ngrpk:*next)

610aA*----------------------------------------------------------------
610aA*  Data Formats
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,C#SLOT
610aAD saveVer#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
      *copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *
610aAD chk4err         s               n
     D forevr          s              1
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
     D vcount          s              2  0
610aAD zmsflag         s               n
610aAD zmflag          s               n
     d odoutq          s              3  0
     d odpqtn          s              5  0
     d odpqt1          s              3  0
     d odpqt2          s              3  0
     d newqtyn         s              5  0
     d newqty1         s              5  0
     d newqty2         s              5  0
     d numToProduce    s              4  0
700bA*----------------------------------------------------------------
700bAD$dsSLOT        E DS                  Extname(SLOT)
610aA*----------------------------------------------------------------
610aA*  Program info data structure
610aA*
610aA /Copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     *----------------------------------------------------------------
     *  Main line
EI  A*
     *
      /free
         // loop through all ODR Repack Item Pick Slots with
         // negative quantities and generate adjustments to
         // clear negative and reduce parent repack slot
            sqlstmt = 'select slwhse,slwhdp,slitem,kccitm,sldisp,' +
                      'kcdisp,vspdis,slstat,slstk1,kirptp' +
                      ' from slot,kititem,vslot,kitcomp,itemlnk' +
                      ' where slwhse=kiwhse and slitem=kiitem' +
                      ' and slwhse=vswhse and slwhdp=vswhdp ' +
                      ' and sldisp=vsdisp and slstat=' + sq +
                      'A' + sq + ' and slstk1<0 and slpick=' +
                      sq + 'Y' + sq + ' and kirptp=' + sq +
                      '2' + sq + ' and slwhse=kcwhse and ' +
                      'slitem=kcitem and slwhse=ilwhse and ' +
                      'slitem=ilitem and ilitm2=kccitm';

            exec sql PREPARE ri FROM :SqlStmt;
            exec sql DECLARE ngRpk SCROLL CURSOR FOR ri;
            exec sql OPEN ngRpk;
            exec sql fetch first from ngRpk into :ngrpk;

            dow sqlStt=sqlSuccess;
              exsr adjRepack;
              exec sql fetch next from ngRpk into :ngrpk;
            enddo;

            exec sql close ngRpk;
            *inlr=*on;

      /end-free
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
700aA*
700aA* Get client id.
700aA*
700aAC     *dtaara       define    pirclient     client           10
700aAC                   in        client
     C                   eval      forevr = *on
610aA *
610aA * Get employee options.
610aA *
610aAC                   call      'GETUSER'
610aMC                   parm      #curruser     e$code           10
610aAC                   parm                    e$whse            3 0
610aAC                   parm                    #emp#             5 0
610aAC                   parm                    e$fnam           15
610aAC                   parm                    e$init            1
610aAC                   parm                    e$lnam           20
610aAC                   parm                    e$whdp            5
610aAC                   parm                    e$styp            1
610aAC                   parm                    e$shft            6
610aAC                   parm                    e$crew            6
610aAC                   parm                    e$nhrs            3 1
610aAC                   parm                    e$rtn             8
610aAC                   parm                    e$bpu             1
610aAC                   parm                    e$lng             2
     *
     C                   endsr

610aA*----------------------------------------------------------------
610aA*  adjRepack - Adjust negative quantities in Repack Item to zero
610aA*              and negative adjust parent item by same value
610aA*----------------------------------------------------------------
610aA
610aAC     adjRepack     begsr
     **
     * Create plus adjustment to reverse negative qty on Repack Item

     *  Initialize data structure
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#

     *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = ngwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = ngwhdp

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ngrdis

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = ngritm

      /free
                   exec sql select kiqty1 into :odoutq
                       from kititem
                         where kiwhse=:ngwhse and kiitem=:ngritm;
720bA              numToProduce = *zeros;
720bA              // Determine how many iterations of the repack
720bA              // configuation must be produced to accomodate
720bA              // quantities invoiced
720bA              dow ngstk1 < *zeros;
720bA                 numToProduce = numToProduce + 1;
720bA                 ngstk1 = ngstk1 + odoutq;
720bA              enddo;
720bA              ngstk1=(numToProduce * odoutq)*-1;
      /end-free
     C                   eval      $saqtyu  = *on
620fAC                   eval      $saqty1  = -(ngstk1)

     C                   eval      $saqty2  = 0
     C                   eval      $saqty3  = 0

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = 0

     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = 'R1'

     c                   eval      $saemp#u = *on
     c                   eval      $saemp# = #emp#

     c                   eval      $saactionu = *on
     c                   eval      $saaction = 'ODR'

     C                   eval      $samemou = *on
     C                   eval      $samemo  = ' '

     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #user
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
650fAc                   exsr      zzzdricop
650bA
     *  Initialize data structure

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#

     *  Negative adjust Parent Item for quantity

     C                   eval      $slwhseu = *on
650bAC                   eval      $slwhse  = ngwhse

     C                   eval      $slwhdpu = *on
650bAC                   eval      $slwhdp = ngwhdp

     C                   eval      $sldispu = *on
650dAC                   eval      $sldisp  = ngpdis

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = ngpitm

     C                   eval      $saqtyu  = *on
      /free
                   chain (ngwhse:ngpitm) piritem;
                   exec sql select kcqty1,kcqty2,kcqty3
                         into :odpqtn,:odpqt1, :odpqt2
                       from kitcomp
                         where kcwhse=:ngwhse and kccitm=:ngpitm;
720bA                 $saqty1=(numToProduce * odpqtn);
720bA                 $saqty2=(numToProduce * odpqt1);
720bA                 $saqty3=(numToProduce * odpqt2);
720bA                 select;
720bA                   when itumq3<>0;
720bA                     newqty2 = (($saqty1 * itumq2 * itumq3) +
720bA                                ($saqty2 * itumq3) +
720bA                                 $saqty3);
720bA                     newqtyn=*zeros;
720bA                     newqty1=*zeros;
720bA                   when itumq2<>0;
720bA                     newqty1 = (($saqty1 * itumq2) +
720bA                                 $saqty2);
720bA                     newqty2=*zeros;
720bA                     newqtyn=*zeros;
720bA                   other;
720bA                     newqtyn = $saqty1;
720bA                     newqty1 = *zeros;
720bA                     newqty2 = *zeros;
720bA                 endsl;
720bA                 exsr zzupQty;
720bA                 $saqty1 = newqtyn * -1;
720bA                 $saqty2 = newqty1 * -1;
720bA                 $saqty3 = newqty2 * -1;
      /end-free

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = 0

     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = 'R1'

     c                   eval      $saemp#u = *on
     c                   eval      $saemp# = #emp#

     c                   eval      $saactionu = *on
     c                   eval      $saaction = 'ODR'

     C                   eval      $samemou = *on
     C                   eval      $samemo  = ' '

     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #user
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUSTORD'
     C                   eval      $drisys2upd = 'D'
     c                   exsr      zzzdricop

     C                   endsr

720bA *----------------------------------------------------------------
720bA *  ZZUPQTY       Up quantity
720bA *----------------------------------------------------------------
720bA
720bAC     zzupqty       begsr
720bA
720bA /free
720bA       // check for negative quantities
720bA       *in49=*off;
720bA       if newqtyn<0;
720bA          *in49=*on;
720bA          newqtyn = %abs(newqtyn);
720bA       endif;
720bA       if newqty1<0;
720bA          *in49=*on;
720bA          newqty1 = %abs(newqty1);
720bA       endif;
720bA       if newqty2<0;
720bA          *in49=*on;
720bA          newqty2 = %abs(newqty2);
720bA       endif;
720bA /end-free
720bA
720bAC                   dow       itumq3 > 0 and +
720bAC                               newqty2 >= itumq3
720bAC                   eval      newqty2 -= itumq3
720bAC                   eval      newqty1 += 1
720bAC                   enddo
720bA
720bAC                   dow       itumq2 > 0 and +
720bAC                               newqty1 >= itumq2
720bAC                   eval      newqty1 -= itumq2
720bAc                   eval      newqtyn += 1
720bAC                   enddo
720bA
720bA /free
720bA                    if *in49;
720bA                       newqtyn = newqtyn * -1;
720bA                       newqty1 = newqty1 * -1;
720bA                       newqty2 = newqty2 * -1;
720bA                    endif;
720bA /end-free
720bA
720bAC                   endsr

610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------
610aA*                     DRI SUBROUTINES
610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------

610aA*----------------------------------------------------------------
610aA*  clr$slot  Clear $slot data structure fields
610aA*----------------------------------------------------------------
610aA
610aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = #emp#
     C                   endsr
    A
610aA*----------------------------------------------------------------
610aA*  zzzdricop  Call DRICOP
610aA*----------------------------------------------------------------
610aA
610aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C                   endsl

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
