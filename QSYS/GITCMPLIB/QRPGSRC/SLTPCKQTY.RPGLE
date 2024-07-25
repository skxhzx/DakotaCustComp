      /COPY QCOPYSRC,HSPECS
     *----------------------------------------------------------------
     *   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  Slot Picked Quantity
     *  16 April 2013
     *  Kenneth Elder
     *
     *  This program will determine any quantity that has been voiced from
     *  a given slot for a given item including runner data that has been
     *  closed for given transaction.  This will enable the customer to
     *  perform cycle counts when picks span over multiple days
     *
     *  Revisions
     *
650aA*    10/01/13  KDE  6.50a
     *      - Fix: Change to only execute convert quantity if item
     *             found in Label file
710aA*    04/12/17  LMC  7.10a
     *      - Fix: Changed to exclude the dept from the klist when
     *             processing open pirtran12 and label records.
     *             The transaction records whdp don't have to match
     *             the slot whdp.
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpirtran12 if   e           k disk
     Flabel7    if   e           k disk
     Flabel     if   e           k disk    rename(lbrec:lbrec1)
     f                                     prefix(r_)
     Flabeldo   if   e           k disk
     Frunner5   if   e           k disk

      /copy *libl/qcopysrc,c#driparmp
      /copy *libl/qcopysrc,c#driparms
      /copy qcopysrc,p.driitem
      /copy *libl/qcopysrc,c#item

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $PWHSE   -  Warehouse
     *     $PWHDP   -  Department
     *     $PDISP   -  Slot Disply
     *     $PITEM   -  Contract, Alias, Same Slot Breakdown or Different
     *                 Slot Breakdown item number.
     *
     *  Output parameters
     *
     *     $PPQTY1  - Picked Quantity 1
     *     $PPQTY2  - Picked Quantity 2
     *     $PPQTY3  - Picked Quantity 3
     *
     *----------------------------------------------------------------
     *
     *  Variables
     D wrkQty1         s              5  0
     D wrkQty2         s              5  0
     D wrkQty3         s              5  0
     D totavl          s              5  0
     D totstk          s              5  0
     D totpck          s              5  0
     D $pwhse          s              3  0
     D saveVer#        s                   like($itver#)
     D saveSItem       ds                  likeds($item)
     D driItemCalled   s               n
     D itemMatch       s               n
     D oneTime         s               n
     D error           s               n
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $pwhdp            5
     C                   parm                    $pdisp           12
     C                   parm                    $pitem           15
     C                   parm                    $ppqty1           5 0
     C                   parm                    $ppqty2           5 0
     C                   parm                    $ppqty3           5 0
     C                   parm                    slstk1            5 0
     C                   parm                    slstk2            5 0
     C                   parm                    slstk3            5 0
     c                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main line
     *
     *    Initialize return parameters.
     *
      /free
         clear $ppqty1;
         clear $ppqty2;
         clear $ppqty3;
         wrkQty1 = 0;
         wrkQty2 = 0;
         wrkQty3 = 0;
         $prtn = '*OK     ';

         // Loop through PIRTRAN for open for picked quantities of select
         //  warehouse, department and item

710aD    //setll ($pwhse:$pwhdp) pirtran12;
710aM    setll ($pwhse) pirtran12;
         if %equal;
710aD       //reade ($pwhse:$pwhdp) pirtran12;
710aM       reade ($pwhse) pirtran12;
            dow not %eof(pirtran12);
               exsr accumQty;
710aD          //reade ($pwhse:$pwhdp) pirtran12;
710aM          reade ($pwhse) pirtran12;
            enddo;
650aD     //  exsr rmvneg;
         endif;
650aA    exsr rmvneg;

         return;
        //  --------------------------------------------------------------
        //  Accumulate Picked Quantities
        //  --------------------------------------------------------------
         begsr accumQty;

         // Loop through Label using transaction from PIRTRAN and      ct
         //  warehouse, department and item from parameters

         oneTime = *off;
         setll pttrn# label7;
         if %equal;
            reade pttrn# label7;
            dow not %eof(label7);
               //  get label quantity and add to appropriate quantity
710aD         //if lbwhse=$pwhse and lbwhdp=$pwhdp and lbdisp = $pdisp;
710aM          if lbwhse=$pwhse and lbdisp = $pdisp;
                  // ensure proper item
                  exsr getitem;
                  itemMatch = *on;
                  if $pitem <> lbitem;
                     if $pitem <> $itmitem;
                        itemMatch = *off;
                     endif;
                  endif;
                  // Process Runner transactions
                  if itemMatch and not oneTime;
                     exsr runner;
                     oneTime = *on;  //only process once per same transact
                  endif;
                  // Process voiced transactions
                  chain lblbl# labeldo;
                  if %found(labeldo) and itemMatch;
                     select;
                     when lbutyp= 'N';
                        wrkQty1+=lboqty;
                     when lbutyp= '1';
                        wrkQty2+=lboqty;
                     when lbutyp= '2';
                        wrkQty3+=lboqty;
                     endsl;
                  endif;
               endif;
               reade (pttrn#) label7;
            enddo;
         endif;
650aA    if oneTime;
            exsr cnvqty;
650aA    endif;

         endsr;
        //  --------------------------------------------------------------
        //  Convert quantity picked based on quantity buckei
        //  --------------------------------------------------------------
         begsr cnvQty;

            select;
               when lbutyp= '2';
                  if $itumq3 > 0;
                     dow wrkqty3 >= $itumq3;
                        wrkqty3 -= $itumq3;
                        wrkqty2 += 1;
                     enddo;
                  endif;
               when lbutyp= '1';
                  if $itumq2 > 0;
                     dow wrkqty2 >= $itumq2;
                        wrkqty2 -= $itumq2;
                        wrkqty1 += 1;
                     enddo;
                  endif;
            endsl;

         endsr;
        //  --------------------------------------------------------------
        //  getitem - Get Item Info
        //  --------------------------------------------------------------

       begsr getItem;

         error = *off;

         savever# = $itver#;
         clear $item;
         $itver# = savever#;

         $itwhse = lbwhse;
         $ititem = lbitem;
         $dridata = $item;
         $dridata2 = $item2;

         driItemCalled = *on;
         driItem('%GETMAIN': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);

         $item = $dridata;
         $item2 = $dridata2;

         select;
           when %error;
             error = *on;
           when $drireturn <> '*OK';
             error = *on;
         endsl;

       endsr;

        //  --------------------------------------------------------------
        //  Remove Negatives quantities if they exist
        //  --------------------------------------------------------------
         begsr rmvNeg;

            $ppqty1 = slstk1 - wrkQty1;
            $ppqty2 = slstk2 - wrkQty2;
            $ppqty3 = slstk3 - wrkQty3;

            if wrkQty1=0 and wrkQty2=0 and wrkQty3=0;
               $prtn = '*NOTHING';
               $ppqty1 = slstk1;
               $ppqty2 = slstk2;
               $ppqty3 = slstk3;
            else;
               // Breakdown 2 quantity and sign breakdown
               if slstk3<>0 or wrkqty3<>0;
                  totstk = (slstk1*$itumq2*$itumq3) + (slstk2*$itumq3) + slstk3;
                  totpck = (wrkQty1*$itumq2*$itumq3)+(wrkQty2*$itumq3)+wrkQty3;
                  totavl = totstk - totpck;
                  totavl = %abs(totavl);
                  if totavl > $itumq3;
                     wrkqty1 = 0;
                     wrkqty2 = 0;
                     dou totavl < $itumq3;
                        wrkqty2 = wrkqty2 + 1;
                        totavl = totavl - $itumq3;
                     enddo;
                  endif;
                  wrkqty3 = totavl;
                  if wrkQty2 > $itumq2;
                     wrkqty1 = 0;
                     dou wrkQty2 < $itumq2;
                        wrkqty1 = wrkqty1 + 1;
                        wrkQty2 = wrkQty2 - $itumq2;
                     enddo;
                  else;
                     wrkqty1 = 0;
                     if $ppqty1 < 0 or $ppqty2 < 0;
                        wrkqty2 = wrkqty2 * -1;
                     endif;
                  endif;
                  if $ppqty1 < 0;
                     wrkqty1 = wrkqty1 * -1;
                  endif;
               // Breakdown quantity and sign for Breakdown 1
               if (slstk2<>0 or wrkqty2<>0) and slstk3=0 and wrkQty3=0;
                  totstk = (slstk1 * $itumq2) + slstk2;
                  totpck = (wrkQty1 * $itumq2) + wrkQty2;
                  totavl = totstk - totpck;
                  totavl = %abs(totavl);
                  if totavl > $itumq2;
                     wrkqty1 = 0;
                     dou totavl < $itumq2;
                        wrkqty1 = wrkqty1 + 1;
                        totavl = totavl - $itumq2;
                     enddo;
                  else;
                     wrkqty1 = 0;
                     wrkqty2 = totavl;
                     wrkqty3 = 0;
                  endif;
                     wrkqty2 = totavl;
                     wrkqty3 = 0;
                  if $ppqty1 < 0;
                     wrkqty1 = wrkqty1 * -1;
                  endif;
                  $ppqty1 = wrkQty1;
                  $ppqty2 = wrkQty2;
                  $ppqty3 = wrkQty3;
               endif;
                  $ppqty1 = wrkQty1;
                  $ppqty2 = wrkQty2;
                  $ppqty3 = wrkQty3;
               endif;
            endif;

         endsr;

        //  --------------------------------------------------------------
        //  Process Runner quantities
        //  --------------------------------------------------------------
         begsr runner;
            // If records exist in runner file determine if
            // processed. if processed then add quantity found
            // into quantity picked for return request
            setll ($pwhse:pttrn#) runner5;
            if %equal;
               reade ($pwhse:pttrn#) runner5;
               dow not %eof(runner5);
                  if rustat = 'C';
                     // if runner label# different from original
                     // label read then read the label from the
                     // current runner record.  This happens when
                     // user changes UOM for found product.  The
                     // system creates a new records with different
                     // UOM so different label#
                     if rulbl#<>lblbl#;
                        chain (rulbl#) label;
                        if not %found(label);
                           // this condition should never occur.
                           // if found it will now use correct
                           // label data
                           iter;
                        else;
                           select;
                            when r_lbutyp= 'N';
                              wrkQty1+=ruqyfd;
                            when r_lbutyp= '1';
                              wrkQty2+=ruqyfd;
                            when r_lbutyp= '2';
                              wrkQty3+=ruqyfd;
                          endsl;
                        endif;
                     else;
                        select;
                         when lbutyp= 'N';
                           wrkQty1+=ruqyfd;
                         when lbutyp= '1';
                           wrkQty2+=ruqyfd;
                         when lbutyp= '2';
                           wrkQty3+=ruqyfd;
                        endsl;
                     endif;
                  endif;
                  reade ($pwhse:pttrn#) runner5;
               enddo;
            endif;
         endsr;
        //  --------------------------------------------------------------
        //  Initialization Routine
        //  --------------------------------------------------------------
         begsr *inzsr;
         endsr;
        /end-free
