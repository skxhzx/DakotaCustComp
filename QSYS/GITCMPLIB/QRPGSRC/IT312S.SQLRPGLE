     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT312S    Select records for item/slot report
     *  17 October 2007
     *  Lynn McMahon
     *
     *  Revisions
     *
     *    10/17/07  LMC  5.20 P#00023
     *      - Created.
     *
     *    05/13/08  GJA  5.20aP#00023
     *      - Added special compile instructions.
     *----------------------------------------------------------------
520a * SPECIAL COMPILE INSTRUCTIONS
     *      - parameter COMMIT should be set to *NONE...COMMIT(*NONE)
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Constants / Variables
     *----------------------------------------------------------------
     D wdisp1          s             12
     D wdisp           s             12
     D wfrom           s              8
     D witem           s             15
     D wto             s              8
     D wwhse           s              3  0
     *----------------------------------------------------------------
     *  Date data structures
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $whse     -  *MFRDATE
     *                  *INUSEDATE
     *     $from     -  From date
     *     $to       -  To date
     *     $item     -  Item number
     *     $disp     -  Display slot
     *     $hist     -  Extended history flag
     *  Output parameters
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $from             8
     C                   parm                    $to               8
     C                   parm                    $item            15
     C                   parm                    $disp            12
     C                   parm                    $hist             1
     C                   movel     $whse         wwhse
     C                   eval      wfrom = $from
     C                   eval      wto = $to
     C                   eval      witem = $item
     C                   eval      wdisp = $disp
     C                   eval      wdisp1 = %trim($disp) + '%'
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   select
     *
     * select all items all locations
     *
     C                   when      witem = '*ALL'  and wdisp = '*ALL'
     C                   if        $hist = 'Y'
     C/EXEC SQL
     C+  insert
     C+  into it312ah (lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+               lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+               lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+               lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+               lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+               lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+               lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+               lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+               lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+               lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+               wkwhse, wkitem)
     C+  select lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+         lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+         lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+         lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+         lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+         lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+         lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+         lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+         lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+         lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+         lbwhse, lbitem
     C+  from labelh
     C+  where lbwhse = :wwhse  and
     C+        lbitem <> '*PIRPICK' and
     C+        lbrdte between :wfrom and :wto and
     C+        lbqpck <> 0
     C/END-EXEC
     C                   endif
     C/EXEC SQL
     C+  insert
     C+  into it312ah (lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+               lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+               lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+               lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+               lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+               lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+               lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+               lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+               lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+               lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+               wkwhse, wkitem)
     C+  select lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+         lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+         lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+         lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+         lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+         lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+         lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+         lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+         lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+         lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+         lbwhse, lbitem
     C+  from label
     C+  where lbwhse = :wwhse  and
     C+        lbitem <> '*PIRPICK' and
     C+        lbrdte between :wfrom and :wto  and
     C+        lbqpck <> 0
     C/END-EXEC
     c                   eval      sqlstt = sqlstt
     *
     * select specific item all locations
     *
     C                   when      witem <> '*ALL'  and wdisp = '*ALL'
     C                   if        $hist = 'Y'
     C/EXEC SQL
     C+  insert
     C+  into it312ah (lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+               lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+               lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+               lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+               lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+               lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+               lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+               lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+               lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+               lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+               wkwhse, wkitem)
     C+  select lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+         lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+         lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+         lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+         lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+         lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+         lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+         lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+         lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+         lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+         lbwhse, lbitem
     C+  from labelh, it312
     C+  where lbwhse = :wwhse  and
     C+        lbitem <> '*PIRPICK' and
     C+        lbrdte between :wfrom and :wto and
     C+        lbqpck <> 0  and
     C+        (lbwhse = wkwhse and lbitem = wkitem)
     C/END-EXEC
     C                   endif
     C/EXEC SQL
     C+  insert
     C+  into it312ah (lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+               lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+               lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+               lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+               lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+               lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+               lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+               lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+               lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+               lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+               wkwhse, wkitem)
     C+  select lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+         lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+         lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+         lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+         lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+         lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+         lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+         lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+         lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+         lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+         lbwhse, lbitem
     C+  from label, it312
     C+  where lbwhse = :wwhse  and
     C+        lbitem <> '*PIRPICK' and
     C+        lbrdte between :wfrom and :wto  and
     C+        lbqpck <> 0  and
     C+        (lbwhse = wkwhse and lbitem = wkitem)
     C/END-EXEC
     *
     * select specific item specific location
     *
     C                   when      witem <> '*ALL'  and wdisp <> '*ALL'
     C                   if        $hist = 'Y'
     C/EXEC SQL
     C+  insert
     C+  into it312ah (lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+               lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+               lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+               lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+               lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+               lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+               lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+               lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+               lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+               lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+               wkwhse, wkitem)
     C+  select lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+         lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+         lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+         lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+         lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+         lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+         lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+         lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+         lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+         lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+         lbwhse, lbitem
     C+  from labelh, it312
     C+  where lbwhse = :wwhse  and
     C+        lbitem <> '*PIRPICK' and
     C+        lbrdte between :wfrom and :wto and
     C+        lbqpck <> 0  and
     C+        lbdisp like : wdisp1  and
     C+        (lbwhse = wkwhse and lbitem = wkitem) or
     C+        lbwhse = :wwhse  and
     C+        lbitem <> '*PIRPICK' and
     C+        lbrdte between :wfrom and :wto and
     C+        lbqpck <> 0  and
     C+        lbdsp2 like : wdisp1 and
     C+        (lbwhse = wkwhse and lbitem = wkitem)
     C/END-EXEC
     C                   endif
     C/EXEC SQL
     C+  insert
     C+  into it312ah (lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+               lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+               lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+               lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+               lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+               lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+               lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+               lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+               lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+               lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+               wkwhse, wkitem)
     C+  select lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+         lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+         lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+         lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+         lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+         lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+         lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+         lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+         lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+         lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+         lbwhse, lbitem
     C+  from label, it312
     C+  where lbwhse = :wwhse  and
     C+        lbitem <> '*PIRPICK' and
     C+        lbrdte between :wfrom and :wto  and
     C+        lbqpck <> 0  and
     C+        lbdisp like : wdisp1 and
     C+        (lbwhse = wkwhse and lbitem = wkitem) or
     C+        lbwhse = :wwhse  and
     C+        lbitem <> '*PIRPICK' and
     C+        lbrdte between :wfrom and :wto  and
     C+        lbqpck <> 0  and
     C+        lbdsp2 like : wdisp1 and
     C+        (lbwhse = wkwhse and lbitem = wkitem)
     C/END-EXEC
     *
     * select all items, specific location
     *
     C                   when      witem = '*ALL'  and wdisp <> '*ALL'
     C                   if        $hist = 'Y'
     C/EXEC SQL
     C+  insert
     C+  into it312ah (lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+               lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+               lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+               lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+               lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+               lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+               lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+               lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+               lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+               lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+               wkwhse, wkitem)
     C+  select lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+         lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+         lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+         lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+         lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+         lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+         lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+         lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+         lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+         lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+         lbwhse, lbitem
     C+  from labelh
     C+  where lbwhse = :wwhse  and
     C+        lbitem <> '*PIRPICK' and
     C+        lbrdte between :wfrom and :wto and
     C+        lbqpck <> 0 and
     C+        lbdisp like : wdisp1  or
     C+        lbwhse = :wwhse  and
     C+        lbitem <> '*PIRPICK' and
     C+        lbrdte between :wfrom and :wto  and
     C+        lbqpck <> 0  and
     C+        lbdsp2 like : wdisp1
     C/END-EXEC
     C                   endif
     C/EXEC SQL
     C+  insert
     C+  into it312ah (lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+               lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+               lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+               lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+               lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+               lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+               lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+               lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+               lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+               lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+               wkwhse, wkitem)
     C+  select lbwhse, lbwhdp, lbseq,  lbitem, lbpbat,
     C+         lbaisl, lbloc,  lbrlvl, lbhand, lbpseq,
     C+         lbstyp, lbqryf, lbdisp, lbqavl, lbwhs2,
     C+         lbwhd2, lbasl2, lbloc2, lblvl2, lbhnd2,
     C+         lbdsp2, lbrte,  lbstop, lbord,  lbspcl,
     C+         lbpo,   lbutyp, lbucod, lbucub, lbcube,
     C+         lbuwgt, lbswgt, lbqalc, lbqrmn, lbqpck,
     C+         lbtie,  lbhigh, lbgrp1, lbgrp2, lbtype,
     C+         lblbl#, lbpal#, lbtrn#, lbctr#, lbstat,
     C+         lbprty, lbsdte, lbstim, lbrdte, lbvrfy,
     C+         lbwhse, lbitem
     C+  from label
     C+  where lbwhse = :wwhse  and
     C+        lbitem <> '*PIRPICK' and
     C+        lbrdte between :wfrom and :wto  and
     C+        lbqpck <> 0  and
     C+        lbdisp like : wdisp1  or
     C+        lbwhse = :wwhse  and
     C+        lbitem <> '*PIRPICK' and
     C+        lbrdte between :wfrom and :wto  and
     C+        lbqpck <> 0  and
     C+        lbdsp2 like : wdisp1
     C/END-EXEC
     C                   endsl
     C                   eval      *inlr = *on
