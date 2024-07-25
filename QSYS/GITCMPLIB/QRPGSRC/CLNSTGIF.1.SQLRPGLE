     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2012')

     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CLNSTGIFIL Delete old SAP/Dakota Import Staging Interface records
     *  Jose G. Duque
     *  June 15, 2011
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    12/07/12  MLB  6.40
     *      - Enh: Added code to cleanup the following file:
     *        IMPSPCKQ.
     *
650 A*    07/16/14  MLB  6.50
     *      - Fix: Corrected batch type for import p/o's to IMPPO.
     *
730 A*    04/27/19  MLB  7.30
     *      - Enh: Added 1 new files for cleanup: IMPSPCKQ2.
     *      - Enh: Added 1 new group for cleanup: IMPCOMPQTY with
     *        2 new files: IMPSCQTY, IMPSCQTY2.
     *
730aA*    12/23/19  KDE  7.30a
     *      - ENH: File IMPSITMO was changed to include field IJBD1
     *        breakdown one quantity
740a *    11/08/20  RTR  7.40a
     *      - Enh: Added IMPSCQTY.
     *
750 A*    05/26/21  MLB  7.50
     *      - Enh: Recompiled pgm due to new fields added to IMPSPCKQ.
     *
760 A*    06/09/22  MLB  7.60
     *      - Enh: Added file IMPSORSF to cleanup process.
     *
770aA*    01/17/23  NLK  7.70a
     *      - Enh: Added file INTLOG to cleanup process.
     *        Hardcode 14 days for now.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fstgbatch  uf   e           k disk
     *----------------------------------------------------------------

     *------------------------------------------------------------------
     * Misc defs ...
     *------------------------------------------------------------------

     D batchid         s             11
     D OldestStamp     s               z
770a D OldestADJ       s               z
770a D $pdays2ADJ      s              3  0
     D $pdays2keep     s              3  0
     D $pwhse          s              3  0
     D eofi            s              1
     D prefix          s              3

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0
     D  $cvdr2               146    153
     D  $cvvl2               154    158  0
     D  $cvdr3               159    166
     D  $cvvl3               167    171  0
     D  $cvdr4               172    179
     D  $cvvl4               180    184  0

     *----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

640aA*----------------------------------------------------------------
640aA*  File data data structure
640aA*----------------------------------------------------------------
640aA

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse       Warehouse number
     *      $pdays2keep  Number of days to keep
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $pdays2keep


     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     * Main line
     *
     * Update stgbatch record to start process
     *
     *
     C     $pwhse        setll     stgbatch
     C     $pwhse        reade     stgbatch
     C                   dow       not %eof(stgbatch)
     *
     C                   if        sbststs < OldestStamp
     C                             and %subst(sbtype:1:3) = 'IMP'
     C                   eval      batchid = sbbatid
     C                   exsr      zzzDelChild
     C                   delete    sbrec
     C                   endif
     *
     C     $pwhse        reade     stgbatch
     *
     C                   enddo

     C                   return

    A*----------------------------------------------------------------
    A*  zzzDelChild   - Delete records
    A*----------------------------------------------------------------
    AC     zzzDelChild   begsr
      *
     C                   select
     C                   when      sbtype = 'IMPHSTQTY'

     C/EXEC SQL
     C+  delete
     C+  from   impspqty
     C+  where  (ijwhse = :sbwhse
     C+          and ijbatid = :sbbatid and ijststs < :OldestStamp)
     C/END-EXEC

    A*----------------------------------------------------------------
     C                   when      sbtype = 'IMPRCVPLT'

     C/EXEC SQL
     C+  delete
     C+  from   impsrcvp
     C+  where  (rcpwhse = :sbwhse
     C+          and rcpbatid = :sbbatid and rcpststs < :OldestStamp)
     C/END-EXEC
770aA
770aAC/EXEC SQL
770aAC+  delete
770aAC+  from   intlog
770aAC+  where  (ilwhse = :sbwhse
770aAC+          and ilbatid = :sbbatid and ilfromts < :OldestStamp)
770aAC/END-EXEC

    A*----------------------------------------------------------------
     C                   when      sbtype = 'IMPRTNPLT'

     C/EXEC SQL
     C+  delete
     C+  from   impsrtnp
     C+  where  (rtpwhse = :sbwhse
     C+          and rtpbatid = :sbbatid and rtpststs < :OldestStamp)
     C/END-EXEC

    A*----------------------------------------------------------------
     C                   when      sbtype = 'IMPSTUFIT'

     C/EXEC SQL
     C+  delete
     C+  from   impsstuf
     C+  where  (siwhse = :sbwhse
     C+          and sibatid = :sbbatid and siststs < :OldestStamp)
     C/END-EXEC

    A*----------------------------------------------------------------
     C*                  when      sbtype = 'IMPSMHITEM'

     C/EXEC SQL
     C+  delete
     C+  from   impsmhitem
     C+  where  (miwhse = :sbwhse
640 MC+          and mibatid = :sbbatid)
640 DC*          and mibatid = :sbbatid and miststs < :OldestStamp)
     C/END-EXEC

    A*----------------------------------------------------------------
     C                   when      sbtype = 'IMPITEM'

     C/EXEC SQL
     C+  delete
     C+  from   impsitmn
     C+  where  (iuwhse = :sbwhse
     C+          and iubatid = :sbbatid and iuststs < :OldestStamp)
     C/END-EXEC
770aA
770aAC/EXEC SQL
770aAC+  delete
770aAC+  from   intlog
770aAC+  where  (ilwhse = :sbwhse
770aAC+          and ilbatid = :sbbatid and ilfromts < :OldestStamp)
770aAC/END-EXEC

    A*----------------------------------------------------------------
     C                   when      sbtype = 'IMPQTYORD'
      *
     C/EXEC SQL
     C+  delete
     C+  from   impsitmo
     C+  where  (ijwhse = :sbwhse
     C+          and ijbatid = :sbbatid and ijststs < :OldestStamp)
     C/END-EXEC

    A*----------------------------------------------------------------
650 DC*                  when      sbtype = 'IMPPPO'
650 MC                   when      sbtype = 'IMPPO'

     C/EXEC SQL
     C+  delete
     C+  from   impspoh
     C+  where  (pihwhs = :sbwhse
     C+          and pihbatid = :sbbatid and pihststs < :OldestStamp)
     C/END-EXEC

     C/EXEC SQL
     C+  delete
     C+  from   impspod
     C+  where  (pidwhs = :sbwhse
     C+          and pidbatid = :sbbatid and pidststs < :OldestStamp)
     C/END-EXEC
770aA
770aAC/EXEC SQL
770aAC+  delete
770aAC+  from   intlog
770aAC+  where  (ilwhse = :sbwhse
770aAC+          and ilbatid = :sbbatid and ilfromts < :OldestStamp)
770aAC/END-EXEC

    A*----------------------------------------------------------------
     C                   when      sbtype = 'IMPROUTE'  or
     C                             sbtype = 'IMPWILCAL'

     C/EXEC SQL
     C+  delete
     C+  from   impsordh
     C+  where  (oihwhs = :sbwhse
     C+          and oihbatid = :sbbatid and oihststs < :OldestStamp)
     C/END-EXEC

     C/EXEC SQL
     C+  delete
     C+  from   impsordd
     C+  where  (oidwhs = :sbwhse
     C+          and oidbatid = :sbbatid and oidststs < :OldestStamp)
     C/END-EXEC
760 A
760 AC/EXEC SQL
760 AC+  delete
760 AC+  from   impsorsf
760 AC+  where  (oiswhs = :sbwhse
760 AC+          and oisbatid = :sbbatid and oisststs < :OldestStamp)
760 AC/END-EXEC
770aA
770aAC/EXEC SQL
770aAC+  delete
770aAC+  from   intlog
770aAC+  where  (ilwhse = :sbwhse
770aAC+          and ilbatid = :sbbatid and ilfromts < :OldestStamp)
770aAC/END-EXEC
640 A
640 A*----------------------------------------------------------------
640 AC                   when         sbtype = 'IMPPICKED'
640 AC                             or sbtype = 'IMPDEMAND'
640 AC                             or sbtype = 'IMPPCKDEM'
640 A
640 AC/EXEC SQL
640 AC+  delete
640 AC+  from   impspckq
640 AC+  where  (ipqwhs = :sbwhse
640 AC+          and ipqbatid = :sbbatid and ipqststs < :OldestStamp)
640 AC/END-EXEC
730 A
730 AC/EXEC SQL
730 AC+  delete
730 AC+  from   impspckq2
730 AC+  where  (ipqwhs = :sbwhse
730 AC+          and ipqbatid = :sbbatid and ipqststs < :OldestStamp)
730 AC/END-EXEC
770aA
770aAC/EXEC SQL
770aAC+  delete
770aAC+  from   intlog
770aAC+  where  (ilwhse = :sbwhse
770aAC+          and ilbatid = :sbbatid and ilfromts < :OldestStamp)
770aAC/END-EXEC

730 A*----------------------------------------------------------------
730 AC                   when         sbtype = 'IMPCOMPQTY'
730 A
730 AC/EXEC SQL
730 AC+  delete
730 AC+  from   impscqty
730 AC+  where  (icwhse = :sbwhse
730 AC+          and icbatid = :sbbatid and icststs < :OldestStamp)
730 AC/END-EXEC
730 A
730 AC/EXEC SQL
730 AC+  delete
730 AC+  from   impscqty2
730 AC+  where  (icwhse = :sbwhse
730 AC+          and icbatid = :sbbatid and icststs < :OldestStamp)
730 AC/END-EXEC

740aA
740aA*----------------------------------------------------------------
740aA /free
740aA    when sbtype = 'IMPSCQTY';
740aA      exec sql delete from impscqty
740aA                where (icwhse  = :sbwhse
740aA                  and  icbatid = :sbbatid
740aA                  and  icststs < :OldestStamp);
740aA /end-free

     C                   endsl
    A*----------------------------------------------------------------

     C                   endsr


     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr

     *
     *  Define key for impsitmo file.
     *
     C*    stgbkey       klist
     C*                  kfld                    $pWhse
     C*                  kfld                    $pBatId
     *
     *  Define key for PIRITEM file.
     *
     C*    keyit         klist
     C*                  kfld                    ijwhse
     C*                  kfld                    ijitem
     *
     *  Variables and constants.
     *
     C                   eval      eofi = *off
     *
     C*                  eval      $pdays2keep = 14

     C                   eval      oldestStamp = %timestamp(%date())-
     C                             %days($pdays2keep)

     *
     *  Hardcode INTLOG 14 days for now.
     *  Later it will delete when STGBatch file deletes.
     *
770aAC                   eval      $pdays2adj = 14

770aAC                   eval      oldestADJ = %timestamp(%date())-
770aAC                             %days($pdays2adj)

770aA
770aAC/EXEC SQL
770aAC+  delete
770aAC+  from   intlog
770aAC+  where  (ilfromts < :OldestADJ)
770aAC/END-EXEC

     C                   endsr
