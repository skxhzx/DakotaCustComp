      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETDDSLOT    Get Drop Pick Slot
     *  19 May 2020
     *  Kenneth Elder
     *
740 A*    05/19/20  KDE  7.40
     *      - Created
     *
750aA*    08/12/21  KDE  7.50a
     *      - Fix to get first slot with no item, then lowest cube
     *      - Change logic to limit number of items in a pick
     *        slot.  An new replenishment option has been added
     *        to specify how many items per slot.  Routine will
     *        only consider base slots that have fewer items.  If
     *        no bse slots have fewer items we will treat as bulk pick
     *      - Change pass in quantity to be consider during replenishment
     *        for cube calculation.  Replens first call and create dd slot
     *        in lt108 before quantity is committed
     *      - SQL statement compring against overflow slot when it should
     *        be against drop pick slot
     *
750bA*    08/30/21  KDE  7.50b
     *      - Several fixes that showed up with Jordanos data versus Chefs.
     *        Had to do with trimming Aisles and ovf locations on dd items
     *        that had no drop pick slot and some items that did
     *
750cA*    11/15/21  KDE  7.50c
     *      - Breakout sent in Drop Pick Location when RPL sent as trans type
     *
     *----------------------------------------------------------------
     *  SPECIAL NOTES:  If any items have special class code *BFCDD
     *                  only the items with *BFCDD will be considered
     *                  for Drop Pick logic.  If you want to open up
     *                  to all items simply remove class code *BFCDD
     *                  from existing items and all no pick slots will
     *                  considered
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     *
     Fpiritem   if   e           k disk
     Fvslot2    if   e           k disk
     Fslot2     if   e           k disk
750aAfoptions   if   e           k disk

740aA*----------------------------------------------------------------
740aA*  SQL format to loop though Drop Picks for Overflow Slot
740aA*----------------------------------------------------------------
740aA
750aAd slfmt           ds            42
750aAd   sfwhse                       3  0 overlay(slfmt)
750aAd   sfaisl                       3    overlay(slfmt:*next)
750aAd   sfwhdp                       5    overlay(slfmt:*next)
750aAd   sfdisp                      12    overlay(slfmt:*next)
750aAd   sfitem                      15    overlay(slfmt:*next)
740aA
740aAd ddfmt           ds            42
740aAd   sqwhse                       3  0 overlay(ddfmt)
740aAd   sqwhdp                       5    overlay(ddfmt:*next)
740aAd   sqfdais                      3    overlay(ddfmt:*next)
740aAd   sqtdais                      3    overlay(ddfmt:*next)
740aAd   sqfdloc                      3  0 overlay(ddfmt:*next)
740aAd   sqtdloc                      3  0 overlay(ddfmt:*next)
740aAd   sqdisp                      12    overlay(ddfmt:*next)
740aAd   sqaisl                       3    overlay(ddfmt:*next)
740aAd   sqloc                        3  0 overlay(ddfmt:*next)
740aAd   sqrlvl                       2  0 overlay(ddfmt:*next)
740aAd   sqhand                       2    overlay(ddfmt:*next)
740aA
740aAd hlfmt           ds            42
740aAd   hlwhse                       3  0 overlay(hlfmt)
740aAd   hlwhdp                       5    overlay(hlfmt:*next)
740aAd   hlfdais                      3    overlay(hlfmt:*next)
740aAd   hltdais                      3    overlay(hlfmt:*next)
740aAd   hlfdloc                      3  0 overlay(hlfmt:*next)
740aAd   hltdloc                      3  0 overlay(hlfmt:*next)
740aAd   hldisp                      12    overlay(hlfmt:*next)
740aAd   hlaisl                       3    overlay(hlfmt:*next)
740aAd   hlloc                        3  0 overlay(hlfmt:*next)
740aAd   hlrlvl                       2  0 overlay(hlfmt:*next)
740aAd   hlhand                       2    overlay(hlfmt:*next)
740aAd

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d ddclscnt        s             10  0
     d first           s               n
     d hldTotCube      s             10  3
750aAd hldTotItems     s              3  0
     d iterCnt         s              1  0
     D pwhse           s              3  0
     D pdept           s              5
     d pItem           s             15
     d pOvfDisp        s             12
     d pOvfAisle       s              3
     d pOvfLoc         s              3  0
     d pddDisp         s             12
     d pddAisle        s              3
     d pddLoc          s              3  0
     d pddLvl          s              2  0
     d pddHand         s              2
750aAd pddqty          s              3  0
750aAd pddtype         s              1
750aAd ptrntype        s              3
     d pReturn         s             10
     d totCube         s             10  3
750aAd totItems        s              3  0
750aAd opDDMax         s              2  0
     d wkdispdd        s             12
     d wkaisldd        s              3
     d wklocdd         s              3  0
750cAd wkAlcQty        s              6  0
750aAd wkstk1          s                   like(slstk1)
750aAd wkstk2          s                   like(slstk2)

750aA *----------------------------------------------------------------
750aA *  DRI parameters
750aA *----------------------------------------------------------------

750aA /COPY *libl/qcopysrc,C#DRIPARMP
750aA /COPY *libl/qcopysrc,C#DRIPARMS
750aA /COPY *libl/qcopysrc,C#SLOT
750aAd errmsg          s             50
750aAD saveVer#        s                   like($slver#)
750aAd wkError         s               n
750aAd wkRerr2         s             50

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

750aA*----------------------------------------------------------------
750aA*   Sub-Procedures
750aA*---------------------------------------------------------------

750aA*  Item on Drop Pick Slot
750aAd itemsOnDDS      pr             2  0
750aAd  iDisp                              like(sqdisp)

750aA*  Get Slot cube for multiple replen pulls
750aAd getSlotCube     pr            10  3
750aAd  iRecType                      3
750aAd  iEmp                          5  0
750aAd  iWhse                         3  0
750aAd  iPckWhdp                      5
750aAd  iPckAisl                      3
750aAd  iPckLoc                       3s 0
750aAd  iPckRlvl                      2s 0
750aAd  iPckHnd                       2

     *----------------------------------------------------------------
     * Parameters
     *   Parameters:
     *     pWhse  - Warehouse
     *     pPO    - Purchase order
     *     pPOSeq - Po seq#
     *
     *   Return Value:
     *     pqty       -  total number of records not loaded
     *     pwgt       -  total weight of records not laoded
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pDept
     C                   parm                    pItem
     C                   parm                    pOvfDisp
     C                   parm                    pOvfAisle
     c                   parm                    pOvfLoc
     c                   parm                    pddDisp
     c                   parm                    pddAisle
     c                   parm                    pddLoc
     c                   parm                    pddLvl
     c                   parm                    pddHand
750aAc                   parm                    pddqty
750aAc                   parm                    pddtype
750aAc                   parm                    ptrntype
     c                   parm                    pReturn

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

        pReturn = '*NODD';
750aA   // get number of items per drop pick slot option
750aA   chain (pWhse:'*REPLEN') options;
750aA   if not %found(options);
750aA     opddMax = 0;
750aA   else;
750aA     monitor;
750aA       opddMAx = %dec(%subst(opdata:33:2):2:0);
750aA     on-error;
750aA       opddMax=0;
750aA     endmon;
750aA   endif;

        if pTrnType <> ' ';
750aA     exsr chkZstat;
        endif;
        exsr loadDDSlt;

       return;

      /end-free

     *----------------------------------------------------------------
     *  loadDDSlt     Load Drop Pick Slot if one exist
     *----------------------------------------------------------------

      /free
       begsr loadDDSlt;

750 A      // If pTrnType is blank, ALC (Allocate) and RPL(Replenishment)
750 A      // we are not trying to get exact in knowing the number of items per slot
750 A      // are not exceeeded, not worrying about cube capacity.  In this case we
750 A      // only want to confirm a Drop Pick config exists for an overflow slot passed
750 A      // in for this item and department
750 A      if pTrnType = *blanks;
750 A        totItems = 0;
750 A        exec sql select count(*)
750 A              into :totItems
750 A               from slot as a
750 A              where a.slwhse=:pWhse and a.slitem=:pitem
750 A                   and a.slwhdp=:pdept and a.slpick='N' and slstat='A'
750 A                   and (slstk1>0 or slstk2>0 or slstk3>0) and
750 A               (select count(*) from drprnge where drpwhse=
750 A               a.slwhse and drpwhdp=a.slwhdp and drpstat='Y' and
750bD               //(drpfoais=' ' or (drpfoais<=a.slaisl and drptoais>=
750bM               (drpfoais=' ' or (drpfoais<=trim(a.slaisl) and drptoais>=
750bD               //a.slaisl)) and (drpfoloc=0 or (drpfoloc<=a.slloc and
750bM               trim(a.slaisl))) and (drpfoloc=0 or (drpfoloc<=a.slloc and
750 A               drptoloc>=a.slloc)))>0 and
750 A               (select count(*) from slot as b where b.slwhse=:pWhse and
750 A                b.slwhdp=:pDept and b.slitem=:pItem and b.slstat='A' and
750 A                b.slpick='Y')=0;
750 A        if sqlstt = '00000' and totItems>0;
750 A          pReturn='*OK';
750 A          return;
750 A        else;
750 A          pReturn='*NODD';
750 A          return;
750 A        endif;
750 A      endif;
750 A
          hldTotCube=0;
          first=*on;
          // Create looping SQL looking for Fixed Items with no defined
          // picked slots

750cA    // Populate drop pick location fields when trans type RPL
750cA    wkAlcQty=0;
750cA    if pTrnType='RPL' and pddDisp<>*blanks;
750cA       exec sql select slaisl,slloc,slrlvl,slhand,
750cA          (select sum(dd.slalc1+dd.slalc2+dd.slalc3+
750cA              dd.slpck1+dd.slpck2+dd.slpck3) from
750cA            slot3 as dd  where dd.slwhse=:pWhse and dd.slitem=:pItem
750cA                 and dd.slstat='DP')
750cA           into :pddAisle,:pddLoc,:pddLvl,:pddHand,:wkalcqty
750cA                 from slot2 as s2
750cA            where s2.slwhse=:pWhse and s2.slwhdp=:pDept
750cA                  and s2.sldisp=:pddDisp;
750cA    endif;

         // First look for item already assigned.  Item could
         // have been assigned slot since replen was created.
         // The query below returns the base slot for the virtual
         clear hlfmt;
         exec sql select b.sldisp,b.slaisl,b.slloc,b.slrlvl,b.slhand
                   into :pdddisp,:pddaisle,:pddloc,:pddlvl,:pddhand
                    from slot as a,vslot,slot as b
                   where a.sldesg='*DROP' and a.slitem=:pitem
                        and a.slwhdp=:pdept and a.slstat='DP' and
                    a.slwhse=vswhse and a.slwhdp=vswhdp and a.sldisp=vsdisp
                    and vswhse=b.slwhse and vswhdp=b.slwhdp and vspdis=b.sldisp
                    and (select count(*) from drprnge where drpwhse=
                    a.slwhse and drpwhdp=a.slwhdp and drpstat='Y' and
750 D               //(drpfoais=' ' or (drpfoais<=a.slaisl and drptoais>=
750bD               //(drpfdais=' ' or (drpfdais<=a.slaisl and drptdais>=
750bM               (drpfdais=' ' or (drpfdais<=trim(a.slaisl) and drptdais>=
750 D               //a.slaisl)) and (drpfoloc=0 or (drpfoloc<=a.slloc and
750bD               //a.slaisl)) and (drpfdloc=0 or (drpfdloc<=a.slloc and
750bM               trim(a.slaisl))) and (drpfdloc=0 or (drpfdloc<=a.slloc and
750 D               //drptoloc>=a.slloc)))>0
750 M               drptdloc>=a.slloc)))>0
                       fetch first row only;
         // Next, look for the Drop Pick BASE location with the least cube
         // consumed.  Only look through *DROP slots defined for this overflow
         // location.
         if sqlstt <> sqlSuccess
750cA       or (sqlstt = sqlSuccess and pTrnType='RPL' and opDDMax<>0);
           if pOvfDisp = *blanks;
             wkdispdd=*blanks;
             wkaisldd=*blanks;
             wklocdd=*zeros;
             // get single overflow slot to use as example for Drop Pick Ranges
             sqlStmt =  'select sldisp,slaisl,slloc from slot ' +
                        'where slwhse=' + %char(pWhse) + ' and slwhdp=' +
                        sq + %trim(pDept) + sq + ' and slitem=' + sq +
                        %trim(pItem) + sq + ' and slpick=' + sq + 'N' + sq +
                        ' and slstat=' + sq + 'A' + sq;
             exec sql PREPARE al FROM :SqlStmt;
             exec sql DECLARE aislp SCROLL CURSOR FOR al;
             exec sql OPEN aislp;
             dow forever = forever;
               exec sql fetch next from aislp into :wkdispdd, :wkaisldd,
                                                   :wklocdd;
               if sqlstt <> '00000';
                 leave;
               endif;
               exsr getDDinfo;
               if pReturn='*OK';
                 // Leave loop on first hit for this item
                 leave;
               endif;
             enddo;
             exec sql close aislp;
           else;
             wkdispdd = pOvfdisp;
             if pOvfAisle=*blanks or pOvfloc=*zeros;
               // Be sure to pull Aisle and Location if missing
               // but Display was sent
               exec sql select slaisl,slloc into :wkaisldd,:wklocdd
                    from slot2
                      where slwhse=:pWhse and slwhdp=:pDept and sldisp=:pOvfDisp
                   fetch first row only;
             else;
               // use what was passed in
               wkaisldd = povfaisle;
               wklocdd = povfloc;
             endif;
             // When overflow slot is sent we only process against that one slot
             exsr getDDInfo;
           endif;
         else;
           // Since slot was found to already be assigned we should return ok
           pReturn = '*OK';
         endif;
       endsr;
      /end-free
      *
      **************************************************************************
      **  getDDinfo   Get Drop Pick Slot Data
      **************************************************************************
      *
      /free
        begsr getDDinfo;
           iterCnt = 1;
           // Originally I was doing iterations starting with most detailed up
           // to simply department and determined I could expand query and get
           // it to work by reading most detailed data first.  That is why it
           // is set to iterate but only loops once
           dow iterCnt < 2;
              // get proper range to search for desired Drop Pick locations
              sqlStmt = 'select drpwhse,drpwhdp,drpfdais,drptdais,drpfdloc,' +
                        'drptdloc,b.sldisp,b.slaisl,b.slloc,b.slrlvl,b.slhand' +
                         ' from drprnge,slot as a,slot as b ' +
                         ' where drpwhse=' + %char(pwhse) +
                         ' and drpwhdp=' + sq + %trim(pdept) + sq +
                         ' and drpstat=' + sq + 'Y' + sq + ' and ' +
                         'a.slwhse=drpwhse and a.slwhdp=drpwhdp and a.slitem=' +
                         sq + %trim(pitem) + sq + ' and ' +
                         'a.sldisp=' + sq + %trim(wkdispdd) + sq + ' and ' +
                         'a.slwhse=b.slwhse and a.slwhdp=b.slwhdp and ' +
                         'b.sldesg=' + sq + '*DROP' + sq + ' and ' +
                         'b.slstat=' + sq + 'DP' + sq + ' and ' +
                         'drpfdais<=trim(b.slaisl) and ' +
                         'drptdais>=trim(b.slaisl) and ' +
                         '(select count(*) from vslot where ' +
                         'b.slwhse=vswhse and b.slwhdp=vswhdp and ' +
                         'b.sldisp=vsdisp)=0';

                         // if class *BFCDD is assigned to any items then
                         // ONLY include those items in the search
                         ddclscnt=0;
                         exec sql select count(*) into :ddclscnt
                              from itemcls where iclwhs=:pwhse
                                   and iclcde='*BFCDD';
                         if ddclscnt <> 0;
                           sqlStmt = %trim(sqlStmt) + ' and ' +
                           '(select count(*) from itemcls where a.slwhse=iclwhs'
                              + ' and a.slitem=iclitm and iclcde=' + sq +
                                     '*BFCDD' + sq + ')>0';
                         endif;

                          // Include Overflow Aisle range
                          sqlStmt = %trim(sqlStmt) + ' and ' +
                          '((drpfoais>' + sq + ' ' + sq + ' and drptoais>' +
                          sq + ' ' + sq + ' and ' +
                          'drpfoais<= ' + sq + %trim(wkaisldd) + sq + ' and ' +
                          'drptoais >= ' + sq + %trim(wkaisldd) + sq + ')' +
                          ' or (drpfoais=' + sq + ' ' + sq + ' and ' +
                          ' drptoais=' + sq + ' ' + sq + '))';

                          // Include any overflow or drop pick location ranges
                          sqlStmt = %trim(sqlStmt) + ' and ' +
                          '(((drpfoloc>0  and drptoloc>0 and ' +
                          'drpfoloc <= ' + %char(wklocdd) + ' and ' +
                          'drptoloc >= ' + %char(wklocdd) + ') or  ' +
                          '(drpfoloc=0 and drptoloc=0)) and ' +
                          '((drpfdloc>0  and drptdloc>0 and ' +
                          'drpfdloc<=b.slloc and drptdloc>=b.slloc)' +
                          ' or (drpfdloc=0 and drptdloc=0)))' +
750aA                     ' order by b.slrlvl,b.slaisl,b.slloc,' +
                          '  drpwhdp,drpfoais desc,drptoais desc,' +
                          '  drpfoloc desc,drptoloc desc,' +
                          '  drpfdais desc,drptdais desc,' +
                          '  drpfdloc desc,drptdloc desc';
                       //   '   fetch first row only';
              exec sql PREPARE lc FROM :SqlStmt;
              exec sql DECLARE locsl SCROLL CURSOR FOR lc;
              exec sql OPEN locsl;
              dow forever = forever;
                exec sql fetch next from locsl into :ddfmt;
                if sqlstt <> '00000';
                  leave;
                endif;
                // If specific Drop Pick Slot is passed in we should
                // iter if not equal.  This is done to validate a specifc
                // slot scanned
750aA           if pddDisp<>*blanks and pddDisp<>sqDisp;
750aA             iter;
750aA           endif;
                // loop through each virtual for this base slot
                // and determine cube used for base slot
                totCube = 0;
750aA           // before looping we should ensure base slot has less
750aA           // items than option if not zero
750aA           if itemsOnDDS(sqdisp) >= opDDMax and opDDMax<>0
750cA                  and ((ptrntype='RPL' and wkAlcQty=0) or
750cA                       (pTrnType='ALC'));
750aA             // only check item counts when performing replenishment or
750aA             // allocation.  When simply checking to see if item is a
750aA             // drop pick item on screen or even LT110A generating order
750aA             // quantity replens we should only confirm config exists.
750aA             // When actually performing replen or allocation it will check
750aA             // item counts and jump out if not available.  pTrnType will
750aA             // have either 'ALC' (OR610) or 'RPL' when coming from LT108
750aA             // or LT107 if we want it to consider item counts.
750aA             iter;
750aA           endif;
                setll (pWhse:pDept:sqdisp) vslot2;
                dow forever=forever;
                  reade (pWhse:pDept:sqDisp) vslot2;
                  if not %equal(vslot2) or %eof(vslot2);
                    leave;
                  endif;
                  // now read the virtual slot from Slot file and
                  // get quantities and item to calculate cube
                  chain (pwhse:vswhdp:vsdisp) slot2;
                  if %found(slot2) and sldesg='*DROP' and slstat='DP';
                    chain (pwhse:pitem) piritem;
                    if not %found(piritem);
                      itcube = 1;
                    endif;

                    // extend cube for virtual
750aA
750aA               select;
750aA                 when slstk1 >= (slalc1+slpck1);
750aA                   wkstk1 = slstk1;
750aA                 other;
750aA                   wkstk1 = (slalc1+slpck1);
750aA               endsl;
750aA
750aA               select;
750aA                 when slstk2 >= (slalc2+slpck2);
750aA                   wkstk2 = slstk2;
750aA                 other;
750aA                   wkstk2 = (slalc2+slpck2);
750aA               endsl;
750aA
750aA               if pddtype = 'E';
750aA                 wkstk2 = wkstk2 + pddqty;
750aA               else;
750aA                 wkstk1 = wkstk1 + pddqty;
750aA               endif;
750aD               //totCube = totcube + (slstk1*itcube);
750aM               totCube = totcube + (wkstk1*itcube);
                    if itumq2 <> 0;
750aD                 //totCube = totCube + (slstk2*(itcube/itumq2));
750aM                 totCube = totCube + (wkstk2*(itcube/itumq2));
                    endif;
750aA               // Add cube from previous items for this slot if in multi
750aA               // item replenishment.  Only send this in if when you need
750aA               // the returned location.  Send blank if you are sending
750aA               // actual slot for simple verification
750aA               if ptrntype='RPL';
750aA                 totCube = totCube + getSlotCube(ptrntype:#Emp#:pWhse:
750aA                           sqWhdp:sqaisl:sqloc:sqrlvl:sqhand);
750aA               endif;
                  endif;
                enddo;
                // for first slot simply move cube and base info
                // to hld fields, otherwise only move in if total
                // cube is less than what is in hold cube
                if first;
                  hldTotCube = totCube;
                  hldTotItems = totItems;
                  hlfmt = ddfmt;
                  first=*off;
                else;
750aA             select;
750aA               when totItems < hldtotItems;
750aA                 hldTotCube = totCube;
750aA                 hldTotItems = totItems;
750aA                 hlfmt = ddfmt;
                    when totCube < hldTotCube ;
                      hldTotCube = totCube;
                      hldTotItems = totItems;
                      hlfmt = ddfmt;
                  endsl;
                endif;
                // no reason to keep reading through available Drop Pick slots
                // if one is read with no item and no cube.
                if totCube = 0 and totItems = 0;
                  leave;
                endif;
              enddo;
              // Now that all base slots have been reviewed we use
              // the one with least cube consumed.
              if hldisp = *blanks;
750aD           //iterCnt = iterCnt + 1;
750aA           pReturn = '*NODD';
750bA           exec sql close locsl;
750aA           leave;
              else;
                pReturn = '*OK';
                pddDisp = hldisp;
                pddAisle = hlaisl;
                pddLoc = hlloc;
                pddLvl = hlrlvl;
                pddHand = hlhand;
                exec sql close locsl;
                leave;
              endif;
750bD         //exec sql close locsl;
           enddo;

       endsr;
      /end-free

750aA *----------------------------------------------------------------
750aA *  chkZstat  -   Zero Verify any Production Slots of "Z" status
750aA *                that were left behind for any reason.  This will
750aA *                keep these slots clean automaically as zeroed
750aA *----------------------------------------------------------------

      /free
750aA  begsr chkZstat;
      /end-free
      *
      *   Get default values for the user.
      *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
      /free

         // build sql to retrieve any left behind "Z" status
         // Drop Pick Slots to keep clean and ensure all works well

         SqlStmt = 'select slwhse,slaisl,slwhdp,sldisp,slitem ' +
                    'from slot where  ' +
                    'slwhse=' + %char(pWhse) + ' and slstat=' +
                    sq + 'Z' + sq + ' and sldesg=' + sq + '*DROP' +
                    sq;

         exec sql Prepare Selsl from :Sqlstmt;
         exec sql Declare Slotz scroll cursor for selsl;
         exec sql Open Slotz;
         exec sql Fetch first from Slotz into :slfmt;

         if Sqlstt = sqlsuccess;
            dow Sqlstt = sqlsuccess;
               savever# = $slver#;
               clear $slot;
               clear $slot2;
               $slver# = savever#;

               $slwhseu = *on;
               $slwhse  = sfwhse;

               $slaislu = *on;
               $slaisl  = sfaisl;

               $slwhdpu = *on;
               $slwhdp = sfwhdp;

               $sldispu = *on;
               $sldisp = %trim(sfdisp);

               $saitemu = *on;
               $saitem  = sfitem;

               $sabyu   = *on;
               $saby    = #user;

               $saemp#u = *on;
               $saemp# = #emp#;

               $saToAreaU = *on;
               $saToArea = 'Slot';

               $dricommand = '*SLOT';
               $drisubcmd  = '%ZEROVFY';
               $drisys2upd = 'D';
               exsr zzDriCop2;
               exec sql Fetch next from Slotz into :slfmt;
            enddo;
         endif;
         exec sql Close Slotz;

       endsr;

      /end-free

750aA *----------------------------------------------------------------
750aA *  zzdricop2  Call DRICOP2
750aA *----------------------------------------------------------------

750aAc     zzDriCop2     begsr
      *
     c                   eval      wkError = *off
      *
     c                   select
      *
     c                   when      $dricommand = '*SLOT'
     c                   eval      $dridata = $slot
     c                   eval      $dridata2 = $slot2

     c                   endsl
      *
     c                   select
      *
     c                   when      $dricommand = '*SLOT'
     c                   call(e)   'DRICOP2'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP2'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      errmsg    = 'Error occured on call to '
     c                                       + 'DRICOP2'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*SLOT'
     c                   eval      $slot = $dridata
     c                   eval      $slot2 = $dridata2
     c                   endsl

750aAc                   endsr

750aA *----------------------------------------------------------------
750aA *  itemsOnDDS - Item count in this base slot
750aA *----------------------------------------------------------------
750aA
750aAp itemsOnDDS      b
750aA
     * Local Files

     Fslot2     if   e           k disk

750aAd itemsOnDDS      pi             2  0
750aAd  iDisp                              like(sqdisp)
750aA
     d  wkitmcnt       s              3  0

     * Local File Data Structures

     d slt             ds                  likerec(slrec: *input)

750aA /free
750aA
750aA      totItems=0;
           chain (pWhse:pDept:iDisp) slot2 slt;
           if not %eof(slot2);
             // if base slot found as drop pick count unless this item
             if slt.slitem <> pItem and slt.slitem<>*blanks;
               totItems = 1;
             endif;
           endif;

           // get number of virtuals for this base
           wkitmcnt=0;
750aA      exec sql select count(*) into :wkitmcnt
750aA                   from vslot
750aA           where (select count(*) from slot where slwhse=vswhse
750aA             and slwhdp=vswhdp and sldisp=vspdis and sldesg='*DROP'
750aA             and slstat='DP')<>0 and vspdis=:iDisp;
750aA
750aA      return totITems + wkitmcnt;

750aA /end-free
750aA
750aAp                 e

750aAC*----------------------------------------------------------------
750aAC*  getSlotCube  Calc slot cube built with multiple item replenishment
750aAC*----------------------------------------------------------------

750aAp getSlotCube     b

     * Local Files

     Fworkusr5  if   e           k disk
     Fpiritem   if   e           k disk

     d getSlotCube     pi            10  3
750aAd  iRecType                      3
750aAd  iEmp                          5  0
750aAd  iWhse                         3  0
750aAd  iPckWhdp                      5
750aAd  iPckAisl                      3
750aAd  iPckLoc                       3s 0
750aAd  iPckRlvl                      2s 0
750aAd  iPckHnd                       2

     * Local File Data Structures

     d wrk             ds                  likerec(wurec: *input)
     d itm             ds                  likerec(itrec: *input)

     * Local Variables

     d  rtnCube        s             10  3

      /free

       // loop workusr5 file looking for replenishment entries for specific
       // entries for this replenishment bunch for passed employee
       setll (iRecType:iEmp:iWhse:iPckWhdp:iPckAisl:iPckLoc:iPckRlvl
                                 :iPckHnd) workusr5;

       rtnCube = 0;
       dow forever = forever;

         reade (iRecType:iEmp:iWhse:iPckWhdp:iPckAisl:iPckLoc:iPckRlvl
                                 :iPckHnd) workusr5 wrk;
         if %eof(workusr5);
           leave;
         endif;

         chain (iWhse:wrk.wupulitem) piritem itm;
         if %eof(piritem);
           // if item not found simply read next workusr5 for slot
           iter;
         endif;

         if wrk.wurectype='RPL';
           rtnCube = rtnCube + (wrk.wuremqty1*itm.itcube);
           if itm.itumq2<>0;
             rtnCube = rtnCube + (wrk.wuremqty2*(itcube/itumq2));
           endif;
         endif;

       enddo;

       return rtnCube;

      /end-free

750aAp                 e
