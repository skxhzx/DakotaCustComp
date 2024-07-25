640aA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  LT110B    Clear PRPLFIL for selected warehouse.
     *  Max Blacknik
     *  04 January 2000
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
417 A*    07/22/03  MLB  4.17
     *      - Enh: Recompile program. New fields added to PRPLFIL.
417aA*    01/05/04  RH   4.17a
     *      - Enh: Change to select for type and priority code.
     *        A=Active, S=Needs to be done, D=Done.
     *        Priority 0=Normal priority replenishment, <>0=just in time
640 A*    12/21/11  RH     6.40A
     *      - Enh: Convert to ILE
640aA*    12/21/11  RH/MLB  6.40A
     *      - Enh: Delete JIT replenishments older than 12 hours.
700aA*    08/04/16  DAS  7.00a
     *      - Enh: Revised to not delete Production replenishments
     *        (PRRPLT = 'D').
720 A*    09/27/18  KDE  7.20
     *      - Enh: Revised to only delete types requested
730 A*    08/26/19  KDE  7.20
     *      - Enh: Change Production Replen from 'D' to 'O'
740 A*    09/24/20  KDE  7.40
     *      - Enh: Add PRPLFIL to history file before purging
750 A*    02/17/21  KDE  7.50
     *      - Enh: Only clear Drop Pick replens for Drop Pick only
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     *----------------------------------------------------------------
     D sq1rec        e ds                  occurs(1) extname(prplfil)
640a *----------------------------------------------------------------
640a *  Called program parameters
640a *
640a D $cvtdt          ds
640a D  $cvcmd                 1      8
640a D  $cvprg                 9     18
640a D  $cvd6i                19     24
640a D  $cvd8i                25     32
640a D  $cvd6o                33     38  0
640a D  $cvd8o                39     46  0
640a D  $cvsto                47     64
640a D  $cvrtn                65     72
640a D  $cverm                73    132
640a D  $cvmsg                73     76
640a *
     D @cvtdt          c                   const('CVTDTE')
640aA*------------------------------------------------------------------
640aA* CLCDUR2 parameters
640aA*------------------------------------------------------------------

640a D $cdcmd          s              8

640a D $cddatein       s              8  0
640a D $cdtimein       s              6  0

640a D $cdyears        s              3  0
640a D $cdmonths       s              3  0
640a D $cddays         s              3  0
640a D $cdhours        s              3  0
640a D $cdminutes      s              3  0
640a D $cdseconds      s              3  0

640a D $cddateOut      s              8  0
640a D $cdtimeOut      s              6  0

640a *----------------------------------------------------------------
640a *  Variables
640a *
640a D cutdate         s              8  0
640a D cuttime         s              6  0
     D w1whse          s              3  0
640a D today           s              8  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
720 AC                   parm                    $prtype           1
     C                   eval      w1whse = $pwhse
640a *  Convert today's date into century format.
640a *
640a C                   eval      $cvcmd = '*CURCMD '
640a C                   call      @cvtdt
640a C                   parm                    $cvtdt
640a C                   eval      today = $cvd8o
640a *
640a C                   time                    $cdtimein
640a *
640a *  Get date and time to delete JIT replenishments
640aAC                   call      'CLCDUR2'
640 AC                   parm      '*SUB'        $cdcmd
640 AC                   parm      today         $cddatein
640 AC                   parm                    $cdtimein
640 AC                   parm      0             $cdyears
640 AC                   parm      0             $cdmonths
640 AC                   parm      0             $cddays
640 AC                   parm      12            $cdhours
640 AC                   parm      0             $cdminutes
640 AC                   parm      0             $cdseconds
640 AC     cutdate       parm      0             $cddateout
640 AC     cuttime       parm      0             $cdtimeout

740 A*
740 A*  Add current PRPLFIL into PRPLFILH (History File)
740 A*  before purging
740 A*
740 A /free
740 A   monitor;
740 A     // The sql below tries to prevent duplicates by using fields
740 A     // warehouse, department, from and to slot displays,
740 A     // item, sequence, quantity, creation date and time, item
740 A     // type and replenishment type.
740 A     exec sql insert into prplfilh
740 A         select p.*,(select current_timestamp
740 A               from sysibm/sysdummy1) from prplfil as p
750 A               where prrplt = (CASE when :$prtype ='A'
750 A                     then prrplt
750 A                   when :$prtype ='N' then ' '
750 A                     else :$prtype
750 A                   end)
740 A             and (select count(*) from prplfilh as h
750 A               where p.prrplt = (CASE when :$prtype ='A'
750 A                     then p.prrplt
750 A                   when :$prtype ='N' then ' '
750 A                     else :$prtype
750 A                   end)
740 A         and p.prwhse=h.prwhse and p.prwhdp=h.prwhdp and
740 A         p.prfdis=h.prfdis and p.prtdis=h.prtdis and p.pritem=h.pritem and
740 A         p.prseq#=h.prseq# and p.prqty=h.prqty and p.pradte=h.pradte and
740 A         p.pratim=h.pratim and p.prtype=h.prtype and p.prrplt=h.prrplt)=0;
740 A   on-error;
740 A   endmon;
740 A   monitor;
740 A     // delete anything beyond 30 days old to keep history purged ongoing
740 A     exec sql delete from prplfilh
740 A         where praddts < (current_timestamp - 30 days);
740 A   on-error;
740 A   endmon;
740 A /end-free
     *
     *  Delete records - Selected department.
     *
     C                   if        $pwhdp <> '*ALL '
     *
720 A*  all delete statements using a Case/When/End clause(s) to determine the
720 A*  records to delete based on user selected replen type.  'A' deletes All
720 A*  'N' Normal deletes blank types and all others use type selected to
720 A*  delete only that type.
     *
     C/EXEC SQL
     C+  delete
     C+  from   prplfil
     C+  where  (prwhse = :w1whse  and  prwhdp = :$pwhdp and
730 MC+         prflag = 'S' and prprty = 0 and prrplt <> 'O'
720 Ac+         and prrplt = (CASE when :$prtype ='A'
720 Ac+               then prrplt
720 Ac+                  when :$prtype ='N' then ' '
720 Ac+              else :$prtype
720 Ac+             end)) or
     C+         (prwhse = :w1whse  and  prwhdp = :$pwhdp and
730 MC+         prflag = 'D' and prrplt <> 'O'
720 Ac+         and prrplt = (CASE when :$prtype ='A'
720 Ac+               then prrplt
720 Ac+                  when :$prtype ='N' then ' '
720 Ac+              else :$prtype
720 Ac+             end))
     C/END-EXEC
     *
640a *  Delete records - JIT
640a C/EXEC SQL
640a C+  delete
640a C+  from   prplfil
640a C+  where  (prwhse = :w1whse  and  prwhdp = :$pwhdp and
730 MC+         pradte = :cutdate and pratim < :cuttime and prrplt <> 'O'
720 Ac+         and prrplt = (CASE when :$prtype ='A'
720 Ac+               then prrplt
720 Ac+                  when :$prtype ='N' then ' '
720 Ac+              else :$prtype
720 Ac+             end)) or
640a C+         (prwhse = :w1whse  and  prwhdp = :$pwhdp and
730 MC+         pradte < :cutdate and prrplt <> 'O'
720 Ac+         and prrplt = (CASE when :$prtype ='A'
720 Ac+               then prrplt
720 Ac+                  when :$prtype ='N' then ' '
720 Ac+              else :$prtype
720 Ac+             end))
640a C/END-EXEC
     C                   else
     *
     *  Delete records - Entire warehouse.
     *
     C/EXEC SQL
     C+  delete
     C+  from   prplfil
700aMC+  where  (prwhse = :w1whse and prflag = 'S' and prprty = 0
730 MC+          and prrplt <> 'O'
720 Ac+          and prrplt = (CASE when :$prtype ='A'
720 Ac+               then prrplt
720 Ac+                  when :$prtype ='N' then ' '
720 Ac+              else :$prtype
720 Ac+             end)) or
730 MC+         (prwhse = :w1whse and prflag = 'D' and prrplt <> 'O'
720 Ac+         and prrplt = (CASE when :$prtype ='A'
720 Ac+               then prrplt
720 Ac+                  when :$prtype ='N' then ' '
720 Ac+              else :$prtype
720 Ac+             end))
     C/END-EXEC
     *
640a *  Delete records - JIT
640a C/EXEC SQL
640a C+  delete
640a C+  from   prplfil
640a C+  where  (prwhse = :w1whse  and  pradte = :cutdate and
730 MC+          pratim < :cuttime and prrplt <> 'O'
720 Ac+          and prrplt = (CASE when :$prtype ='A'
720 Ac+               then prrplt
720 Ac+                  when :$prtype ='N' then ' '
720 Ac+              else :$prtype
720 Ac+             end)) or
730 DC*         (prwhse = :w1whse  and  pradte < :cutdate and prrplt <> 'D'
730 MC+         (prwhse = :w1whse  and  pradte < :cutdate and prrplt <> 'O'
720 Ac+          and prrplt = (CASE when :$prtype ='A'
720 Ac+               then prrplt
720 Ac+                  when :$prtype ='N' then ' '
720 Ac+              else :$prtype
720 Ac+             end))
640a C/END-EXEC
     *
     C                   endif
     *
     C                   return
