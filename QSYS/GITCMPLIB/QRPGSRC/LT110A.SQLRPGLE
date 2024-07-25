      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  LT110A    Create Priority replenishments - Select and sort.
     *  Max Blacknik
     *  07 January 2000
     *
     *  Revisions
     *
500 A*    10/14/04  DAS  5.00
     *      - Converted to ILE.
     *      - Converted to just call DRIPRTYRPL for each item.
     *      - All other code removed for clarity.
     *      - See LT110A.SAV for original code.
650aA*    04/09/14  RH   6.50a
     *      - Enh: Revised program to add support for Client id
720 A*    09/27/18  kde  7.20
     *      - Enh: Revised to accept parm for specific replen type
730aA*    09/24/18  kde  7.30a
     *      - Enh: Revised pass command CRTDDRPL (Create Drop Pick
     *        Replenishment).  Implemented at Chefs Warehouse first
     *      - Changed to SQLRPGLE
740aA*    05/20/20  kde  7.40a
     *      - Enh: Revised to call GETDDSLOT to ensure should replen
     *        to Drop Pick slot
740bA*    12/18/20  kde  7.40b
     *      - Enh: Revised to skip items with designation for Drop Pick
750 A*    02/17/21  kde  7.50
     *      - Enh: Revised to skip non drop pick items when Drop Pick only
750aA*    03/16/21  kde  7.50a
     *      - Enh: Revised sql to improve speed and review fewer items for drop pick
750bA*    08/15/21  kde  7.50b
     *      - Enh: Added new parms for GETDDSLOT
750cA*    11/03/21  kde  7.50c
     *      - Enh: Do not process items with multiple pick slots in main
     *        routine, but process at lr time, and pass different command
     *        to driprtyrpl
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
CSPa *    04/09/14  RH/MLB  CSPa **TEMPORARY**
     *      - Enh: Only create replenishment for first pick slot when
     *        multiple pick slots exist.
     *      ISSUE: Item has multiple pick slots, programs create repl
     *      to fill each pick slot for demand, should only create to
     *      meet the total demand.
     *      When multiple pick slot replenishments are created, uses
     *      the same overflow slots.  For the 2nd replenishment, the
     *      overflow slots will be empty if they were used to fill the
     *      fist pick slot priority replenishment.

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fit381     ip   e           k disk

650aA*----------------------------------------------------------------
650aA*  Customer id
650aA*
650aAD @getcl          c                   const('GETCLIENT')
650aA*
650aA /COPY qcopysrc,id#coastal
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#PRTYRPL
     D savever#        s                   like($prver#)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#PGMINFDS

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#STDVAR
      *copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
650a *  Variables
     *
650a D svitem          s                   like(qlitem)
730aAd ddCount         s              5  0
730aAd cmpItem         s             15
730aAd sltcnt          s              5  0
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
730aAd wktype          s              1
740bAd wkdesg          s              5
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhsea  -  Warehouse
     *      $pwhdp   -  Department code or *ALL
     *      $prplb   -  Based on value
     *                  *ORDQTY - Ordered quantity (ITEMORD file)
     *                  *AVGQTY - Average sales (ITEMAVG file)
     *                  *AVGnnn - *AVGQTY plus nnn percent.
     *                  *RPLLVL - Item replenishment level.
     *
     *    Returned Parameters
     *      $prtn    -  Return code (not used)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhsa            3
     C                   parm                    $pwhdp            5
     C                   parm                    $prplb            8
720 Ac                   parm                    $prtype           1
     C                   parm                    $prtn             8

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

750 Ac                   if        $prtype='D'
750 Ac                   goto      skipit
750 Ac                   endif

     C                   exsr      clr$prtyrpl
CSPa C                   if        client = coastl and
CSPaAC                             qlitem = svitem
CSPa C                   goto      skipit
CSPa C                   else
CSPa C                   eval      svitem = qlitem
CSPa C                   endif

750cA*    If item has multiple pick slots then skip in main loop
750cA*
750cA /free
750cA        sltcnt=0;
750cA        exec sql select count(*) into :sltcnt
750cA                  from slot3
750cA             where slwhse=:qlwhse and slitem=:qlitem and
750cA                   slstat='A' and slpick='Y';
750cA
750cA                    if sltcnt = 0 or sltcnt > 1;
750cA /end-free
750cAc                   goto      skipit
750cA /free
750cA                    endif;
750cA /end-free
750cA*
     C                   eval      $prwhseu = *on
     C                   eval      $prwhse  = qlwhse

     C                   eval      $pritemu = *on
     C                   eval      $pritem  = qlitem

     C                   eval      $prwhdpu = *on
     C                   eval      $prwhdp  = qlwhdp

     C                   eval      $prslotu = *on
     C                   eval      $prslot  = qldisp

     *   Note, DRIPRTYRPL will determine qty needed.

     C**                 eval      $prqtynu = *on
417b C**                 eval      $prqtyn  = tlqpck

     *   Note, DRIPRTYRPL will determine if slot is filled to needed qty.

     C**                 eval      $prfillu = *on
     C**                 eval      $prfill  = 'Y'
720 Ac                   eval      $prfill  = $prtype

     C                   eval      $dricommand = '*PRTYRPL'
     C                   eval      $drisubcmd  = $prplb

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif
CSPa C     skipit        tag

750cA*
750cA*  Process Multiple Pick Slot items separately
750cA*
750cAclr                 exsr      multPckSlt
750cA*
     *  go generate Drop Pick Replens if drop pick slots exists
     *     and this is a Order Quantity Replenishment run
730aAcLR                 if        ddCount<>0 and $prplb='*ORDQTY'
750 Ac**  Only do drop picks if specifically choosen, otherwise
750 Ac**  All could remove while someone is doing replens for DD
750aDc**                 if        $prtype='D'
750aMcLR                 if        $prtype='D' or $prtype='A'
730aAcLR                 exsr      bldDD
750 AcLR                 endif
730aAcLR                 endif
     *  LR stuff - Finish by sorting the created replenishments.

     CLR                 exsr      sortrpl
     CLR                 return

417aA*----------------------------------------------------------------
417aA*----------------------------------------------------------------
417aA*            SUBROUTINES IN ALPHABETICAL ORDER
417aA*----------------------------------------------------------------
417aA*----------------------------------------------------------------
     *
650a *  *INZSR  Initialization subrotine
     *
650a C     *inzsr        begsr
650aA*
650aA* Get client id.
650aA*
650aAC                   call      @getcl
650aAC                   parm                    client           10
650aAC                   parm                    clientloc        10
650aA*
730aA*  determine if *DROP slots exist.  If they do exist then
730aA*  set a flag that forces items without Fixed Pick Slots
730aA*  to be replenished to one of these slots.  Multiple items
730aA*  can live in one base slot
730aA*
730aA /free
730aA       exec sql select count(*) into :ddcount
730aA                       from slot
730aA                   where sldesg='*DROP';
730aA /end-free
     *
650a C                   endsr

730aA*----------------------------------------------------------------
730aA*  bldDD  -  Build Drop Pick Replenishments if used
730aA*----------------------------------------------------------------
730aA
730aAC     bldDD         begsr
730aA /free
730aA     // Create looping SQL looking for Fixed Items with no defined
730aA     // picked slots
730aA       sqlstmt = 'select itwhse,itwhdp,ititem,ittype,ITDESG from piritem' +
730aA                 ' where itstyp=' + sq + 'F' + sq + ' and' +
730aA                 ' (select count(*) from slot where itwhse=' +
730aA                 ' slwhse and itwhdp=slwhdp and ititem=slitem' +
730aA                 ' and slstat=' + sq + 'A ' + sq +
730aA                 ' and slpick=' + sq + 'Y' + sq +')=0' +
750aA                 ' and (select count(*) from slot where itwhse=slwhse' +
750aA                 ' and itwhdp=slwhdp and ititem=slitem and slstat=' + sq +
750aA                 'A ' + sq + ' and slpick=' + sq + 'N' + sq + ' and (' +
750aA                 'slstk1<>0 or slstk2<>0 or slstk3<>0))>0';
730aA       exec sql PREPARE dd FROM :SqlStmt;
730aA       exec sql DECLARE dropp SCROLL CURSOR FOR dd;
730aA       exec sql OPEN dropp;
730aA
730aA       dow forever = forever;
730aA          exec sql fetch next from dropp into :qlwhse,:qlwhdp,:qlitem,
730aA                                              :wktype,:wkdesg;
730aA          if sqlstt <> sqlSuccess;
730aA             leave;
730aA          endif;
730aA          cmpItem=qlitem;
730aA
740bA         // If designation code on item then skip
740bA         if wkdesg <> *blanks and wkdesg <> '*DROP';
740bA           iter;
740bA         endif;
740bA
730aA         //  If Contract, Alias or SSB item
730aA         //   Then get Base Slot item.
730aA         //
730aA         if wktype = 'A'  or
730aA            wktype = 'C'  or
730aA            wktype = 'S';
730aA /end-free
730aAc                   call      'GETSLOTITM'
730aAc                   parm                    qlwhse
730aAc                   parm                    qlitem
730aAc                   parm      ' '           #sitem           15
730aAc                   parm                    #sityp            1
730aAc                   parm                    #sdesc           30
730aAc                   parm                    #spdsc           15
730aAc                   parm                    #srtn            10
730aAc                   parm                    #smsg            60
730aA /free
730aA       cmpItem=#sitem;
730aA       exec sql select count(*) into :sltcnt
730aA                       from slot where slwhse=:qlwhse
730aA                   and slitem=:cmpItem
730aA                   and slpick='Y';
730aA       if sltCnt>0;
730aA          // if parent has a pick slot then, not drop pick
730aA          iter;
730aA       endif;
730aA       endif;
740aA          exsr zzchkDDDef;
740aA        if pReturn='*OK';
730aA          exsr clr$prtyrpl;
730aA
730aA          $prwhseu = *on;
730aA          $prwhse  = qlwhse;
730aA
730aA          $pritemu = *on;
730aA          $pritem  = cmpitem;
730aA
730aA          $prwhdpu = *on;
730aA          $prwhdp  = qlwhdp;
730aA
730aA          $prslotu = *on;
730aA          // logic in DRIPRTYRPL will determine if slot is assigned
730aA          // and will place there.  If no slot is assigned yet the
730aA          // PRPLFIL records will be added with PRTDIS *DDSLOT
730aA          // which will tell LT107 the user MUST supply the *DROP
730aA          // slot to be used for todays picks.  DRIPRTYRPL will read
               // ITEMORD and ITEMORDEXA for case and breakdown quantities
               // respectively when coming from LT110A.  For OR610 it will
               // use what is passed in via $PRQTYN (Case) and $PRQTYW(BD 1)
730aA          $prslot  = '*DDSLOT';
730aA
730aA          $prfill  = 'D';         // Drop Pick
730aA
730aA          $dricommand = '*PRTYRPL';
730aA          $drisubcmd  = '*CRTDDRPL';
730aA
730aA          $drisys2upd = 'D';
730aA          exsr zzzdricop;
740aA        endif;
730aA
730aA       enddo;
730aA
730aA       exec sql close dropp;
730aA
730aA /end-free
730aAc                   endsr

750cA*----------------------------------------------------------------
750cA*  multPckSlt  -  Generate replenishments for items with Multiple
750cA*                 Pick Slots
750cA*----------------------------------------------------------------
750cA
750cAC     multPckSlt    begsr
750cA /free
750cA     // Create looping SQL for Items with Multiple Pick Slots
750cA       sqlstmt = 'select itwhse,itwhdp,ititem from piritem' +
750cA                 ' where itwhse=' + %trim($pwhsa);
750cA       // Add department if selected
750cA       if $pwhdp <> '*ALL' and $pwhdp<>*blanks;
750cA         sqlStmt = %trim(sqlStmt) + ' and itwhdp=' +
750cA                   %trim($pwhdp);
750cA       endif;
750cA       // add condition to only include items with more than
750cA       // one pick slot
750cA       sqlStmt = %trim(sqlstmt) + ' and (select count(*) from' +
750cA                 ' slot where slwhse=itwhse and slitem=ititem' +
750cA                 ' and slwhdp=itwhdp and slstat=' + sq + 'A' + sq +
750cA                 ' and slpick=' + sq + 'Y' + sq + ')>1';
750cA       exec sql PREPARE mp FROM :SqlStmt;
750cA       exec sql DECLARE multp SCROLL CURSOR FOR mp;
750cA       exec sql OPEN multp;
750cA
750cA       dow forever = forever;
750cA          exec sql fetch next from multp into :qlwhse,:qlwhdp,:qlitem;
750cA          if sqlstt <> sqlSuccess;
750cA             leave;
750cA          endif;
750cA
750cA          exsr clr$prtyrpl;
750cA
750cA          $prwhseu = *on;
750cA          $prwhse  = qlwhse;
750cA
750cA          $pritemu = *on;
750cA          $pritem  = qlitem;
750cA
750cA          $prwhdpu = *on;
750cA          $prwhdp  = qlwhdp;
750cA
750cA          $prslotu = *on;
750cA          // logic in DRIPRTYRPL loop through the multiple pick slots
750cA          // and determine proper quantities to either replenish to
750cA          // one or multiple of the pick slots
750cA          $prslot  = *blanks;
730aA
750cA          $prfill  = $prtype;
750cA
750cA          $dricommand = '*PRTYRPL';
750cA          $drisubcmd  = 'M' + %trim($prplb);
750cA
750cA          $drisys2upd = 'D';
750cA          exsr zzzdricop;
750cA
750cA       enddo;
750cA
750cA       exec sql close multp;
750cA
750cA /end-free
750cAc                   endsr
FPR3A*
740aA*----------------------------------------------------------------
740aA*  zzChkDDDef   Check to ensure Drop Pick configuration exist for
740aA*               item/Overflow
740aA*----------------------------------------------------------------
740aA
740aAC     zzChkDDDef    begsr
740aA
740aA *  Call GETDDSLOT to determine if Drop Pick Slot defined
740aA
740aAc                   call      'GETDDSLOT'
740aAc                   parm                    qlwhse
740aAc                   parm                    qlwhdp
740aAc                   parm                    cmpitem
740aAc                   parm      *blanks       prfdis           12
740aAc                   parm      *blanks       prfail            3
740aAc                   parm      *zeros        prfloc            3 0
740aAc                   parm      *blanks       s_sldisp         12
740aAc                   parm      *blanks       s_slaisl          3
740aAc                   parm      *zeros        s_slloc           3 0
740aAc                   parm      *zeros        s_slrlvl          2 0
740aAc                   parm      *blanks       s_slhand          2
750bAc                   parm      0             pddqty1           3 0
750bAc                   parm      ' '           pddtype           1
750bAc                   parm      '   '         ptrntype          3
740aAc                   parm      *blanks       pReturn          10
740aA
740aAC                   endsr

     *----------------------------------------------------------------
     *  sortrpl  Sort (sequence) replenishments
     *----------------------------------------------------------------

     C     sortrpl       begsr

     C                   exsr      clr$prtyrpl
     C                   eval      $prwhseu = *on
     C                   eval      $prwhse  = qlwhse

     C                   eval      $dricommand = '*PRTYRPL'
     C                   eval      $drisubcmd  = '*SEQPRTRPL'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   endsr

417aA*----------------------------------------------------------------
417aA*----------------------------------------------------------------
417aA*                     DRI SUBROUTINES
417aA*----------------------------------------------------------------
417aA*----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$prtyrpl  Clear $prtyrpl data structure fields
     *----------------------------------------------------------------

     C     clr$prtyrpl   begsr
     C                   eval      savever# = $prver#
     C                   clear                   $prtyrpl
     C                   eval      $prver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $dridata = $prtyrpl
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C*                  eval      errmsg    = 'Error occured on call to '
     C*                                      + 'DRICOP'
     C*                                      + '/' + %trim($drisubcmd)
     C*                                      + ' from ' + #prog

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $prtyrpl = $dridata
     C                   endsl

     C     enddricop     endsr
