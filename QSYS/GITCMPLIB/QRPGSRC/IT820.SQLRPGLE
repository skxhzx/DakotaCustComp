     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  IT820    Update label/trans dept if item dept changes.
     *  Roxanne Harrison
     *  19 May 2005
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*  05/19/05  RH   5.00
     *    - Created
510aA*  05/18/07  RH   5.10a
     *    - FIX: SQL for PIRTRAN update was selecting ALL records.
     *      Change to select only if PTTRN# = LBTRN#.
520aA*  04/04/08  RH   5.20a
     *    - FIX: Do not update if whdp = ' '
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     *----------------------------------------------------------------
     D w1whse          s              3  0
     D w1whdp          s              5
     D w1styp          s              1
     D w1item          s             15
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHS   Warehouse
     *      $PWHD   Department
     *      $PSTY   Section
     *      $PRTN   Return code
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $pwhd             5
     C                   parm                    $psty             1
     C                   parm                    $pitm            15
     C                   parm                    $prtn             8
520a C                   if        $pwhd <> ' '
     C                   move      $pwhs         w1whse
     C                   move      $pwhd         w1whdp
     C                   move      $psty         w1styp
     C                   move      $pitm         w1item
     *
     *  Set commit, no special compile needed.
     C/EXEC SQL
     C+ SET OPTION COMMIT=*NONE
     C/END-EXEC
     *
     *  Update records - Open manual put away.
     *
     C/EXEC SQL
     C+  update Pirtran
     C+  set ptwhdp = :w1whdp, ptstyp=:w1styp
     C+  where exists (select lbtrn# from label
     C+                where lbwhse = :w1whse and lbitem = :w1item
     C+                and lbtrn# = pttrn#
     C+                and lbstat = 'P' and lbtype ='P'
     C+                and lbdsp2 ='*MANUAL')
     C/END-EXEC
     *
     C/EXEC SQL
     C+  update label
     C+  set lbwhdp=:w1whdp, lbstyp=:w1styp
     C+  where lbwhse = :w1whse
     C+        and lbitem = :w1item
     C+        and lbstat = 'P'
     C+        and lbtype = 'P'
     C+        and lbdsp2 = '*MANUAL'
     C/END-EXEC
500 A*
     *  What happened?
     *
     C                   select
     *
     *     Completed normally - Do nothing.
     *
     C                   when      sqlcod = 0  or
213 AC                             sqlcod = 100
     C                   eval      $PRTN = '*OK     '
     *
     *     Who knows? Display unmonitored SQL message.
     *
     C                   other
     C                   eval      $PRTN = '*ERROR  '
     C                   endsl
     *
520a C                   endif
     *
     C                   return
