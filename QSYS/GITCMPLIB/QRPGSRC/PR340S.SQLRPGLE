     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PR340S    Select records for TPC priority replenishment report
     *  29 October 2007
     *  Lynn McMahon
     *
     *  Revisions
     *
     *    10/29/07  LMC  5.10
     *      - Created.
     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------
     D wwhse           s              3  0
600aAD wwhdp           s              5
     D wfaisl          s              4
     D wtaisl          s              4
     D wfaisl3         s              3
     D wtaisl3         s              3
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $whdp             5
     C                   parm                    $faisl            4
     C                   parm                    $taisl            4

     C                   movel     $whse         wwhse
     C                   eval      wwhdp = $whdp
     C                   eval      wfaisl = $faisl
     C                   eval      wtaisl = $taisl
     c                   move      $faisl        wfaisl3
     c                   move      $taisl        wtaisl3

     C                   select
     *
     * select all items all locations
     *
     C                   when      wfaisl = '*ALL'
     C/EXEC SQL
     C+  insert
     C+  into pr341  (prwhse, prwhdp, prfail, prfloc, prflvl,
     C+               prfhnd, prfpos, prtail, prtloc, prtlvl,
     C+               prthnd, prtpos, prfdis, prtdis, pritem,
     C+               prseq#, prqty,  prsdef, prflag, prprty,
     C+               prfree, prstat, prtype, prrplt, pradte,
     C+               pratim, praqs)
     C+  select   prwhse, prwhdp, prfail, prfloc, prflvl,
     C+           prfhnd, prfpos, prtail, prtloc, prtlvl,
     C+           prthnd, prtpos, prfdis, prtdis, pritem,
     C+           prseq#, prqty,  prsdef, prflag, prprty,
     C+           prfree, prstat, prtype, prrplt, pradte,
     C+           pratim, praqs
     C+  from prplfil
     C+  where prwhse = :wwhse  and
     c+        prwhdp = :wwhdp
     C/END-EXEC
     *
     * select specific aisle
     C                   when      wfaisl <> '*ALL'
     C/EXEC SQL
     C+  insert
     C+  into pr341  (prwhse, prwhdp, prfail, prfloc, prflvl,
     C+               prfhnd, prfpos, prtail, prtloc, prtlvl,
     C+               prthnd, prtpos, prfdis, prtdis, pritem,
     C+               prseq#, prqty,  prsdef, prflag, prprty,
     C+               prfree, prstat, prtype, prrplt, pradte,
     C+               pratim, praqs)
     C+  select   prwhse, prwhdp, prfail, prfloc, prflvl,
     C+           prfhnd, prfpos, prtail, prtloc, prtlvl,
     C+           prthnd, prtpos, prfdis, prtdis, pritem,
     C+           prseq#, prqty,  prsdef, prflag, prprty,
     C+           prfree, prstat, prtype, prrplt, pradte,
     C+           pratim, praqs
     C+  from prplfil
     C+  where prwhse = :wwhse    and
     c+        prwhdp = :wwhdp    and
     c+        prfail >= :wfaisl3 and
     c+        prfail <= :wtaisl3
     C/END-EXEC
     *
     C                   endsl
     C                   eval      *inlr = *on
