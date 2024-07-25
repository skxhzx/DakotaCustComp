     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2012')

     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CLNSTGEFIL Delete old SAP/Dakota Export Staging Interface files rec
     *  Jose G. Duque
     *  June 15, 2011
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    12/06/12  MLB  6.40
     *      - Enh: Revised program to add file EXPSRTN to the cleanup.
640aA*    12/06/12  MLB  6.40a
     *      - Enh: Revised program to add files EXPSPOH, EXPSPOD, EXPSPOE
     *        to the cleanup.
640bA*    12/06/12  MLB  6.40b
     *      - Enh: Revised program to add files EXPSLICLOG, EXPSQTY2 to
     *        the cleanup.
650aA*    12/13/13  RTR  6.50a
     *      - Enh: Revised program to add file EXPSTRN to the cleanup.
650bA*    07/17/14  RTR  6.50b
     *      - Enh: Revised program to add file EXPSPLBL to the cleanup.
710 A*    05/16/17  MR   7.10
     *      - Recompile for EXPSPLBL file change.
     *
750 A*    02/12/22  MLB  7.50
     *      - Enh: Revised program to add file EXPSADJ2 to the cleanup.
     *
760 A*    10/13/22  MLB  7.60
     *      - Enh: Revised program to add file EXPSUPC to the cleanup.
     *
770aA*    01/16/23  NLK  7.70a
     *      - Enh: Revised program to add file EXPSADJLT to the cleanup.
     *      - Enh: Revised program to add file EXPSORDLT to the cleanup.
     *      - Enh: Revised program to add file EXPSPOLT to the cleanup.
     *      - Enh: Revised program to add file EXPSRTNLT to the cleanup.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fstgbatch  uf   e           k disk
     F*jgdstgbt  uf   e           k disk
     *----------------------------------------------------------------

     *------------------------------------------------------------------
     * Misc defs ...
     *------------------------------------------------------------------

     D batchid         s             11
     D OldestStamp     s               z
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
     *----------------------------------------------------------------
     * Main line
     *
     * Update stgbatch record to start process
     *
     C     $pwhse        setll     stgbatch
     C     $pwhse        reade     stgbatch
     C                   dow       not %eof(stgbatch)
     *
     C                   if        sbststs < OldestStamp
     C                             and %subst(sbtype:1:3) = 'EXP'
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

    A*---The following four files are clear and reload every day
    A*-----------No need to be in this clean up job------------*

     C                   select
     C                   when      sbtype = 'EXPCBITIHI'

     C/EXEC SQL
     C+  delete
     C+  from   expstihigh
     C+  where  (tewhse = :sbwhse
     C+          and tebatid = :sbbatid and teststs < :OldestStamp)
     C/END-EXEC

    A*----------------------------------------------------------------
     C                   when      sbtype = 'EXPCBICASE'
     C/EXEC SQL
     C+  delete
     C+  from   expscasehr
     C+  where  (cewhse = :sbwhse
     C+         and cebatid = :sbbatid and ceststs < :OldestStamp)
     C/END-EXEC

    A*----------------------------------------------------------------
     C                   when      sbtype = 'EXPCBILOAD'

     C/EXEC SQL
     C+  delete
     C+  from   expsldrfil
640bMC+  where  (lefwhs = :sbwhse
     C+          and lebatid = :sbbatid and leststs < :OldestStamp)
     C/END-EXEC

    A*----------------------------------------------------------------
     C                   when      sbtype = 'EXPCBISHRT'

     C/EXEC SQL
     C+  delete
     C+  from   expshrmisp
     C+  where  (sewhse = :sbwhse
     C+          and sebatid = :sbbatid and seststs < :OldestStamp)
     C/END-EXEC

    A*----------------------------------------------------------------
     C                   when      sbtype = 'EXPITEMQTY'

     C/EXEC SQL
     C+  delete
     C+  from   expsqty
     C+  where  (qewhse = :sbwhse
     C+          and qebatid = :sbbatid and qeststs < :OldestStamp)
     C/END-EXEC

    A*----------------------------------------------------------------
     C                   when      sbtype = 'EXPROUTE'  or
     C                             sbtype = 'EXPSELTRAN'
     C/EXEC SQL
     C+  delete
     C+  from   expsordt
     C+  where  (oetwhs = :sbwhse
     C+          and oetbatid = :sbbatid and oetststs < :OldestStamp)
     C/END-EXEC


     C/EXEC SQL
     C+  delete
     C+  from   expsorde
     C+  where  (oeewhs = :sbwhse
     C+          and oeebatid = :sbbatid and oeeststs < :OldestStamp)
     C/END-EXEC


     C/EXEC SQL
     C+  delete
     C+  from   expsordb
     C+  where  (oebwhs = :sbwhse
     C+          and oebbatid = :sbbatid and oebststs < :OldestStamp)
     C/END-EXEC

     C/EXEC SQL
     C+  delete
     C+  from   expsordc
     C+  where  (oecwhs = :sbwhse
     C+          and oecbatid = :sbbatid and oecststs < :OldestStamp)
     C/END-EXEC


     C/EXEC SQL
     C+  delete
     C+  from   expsordp
     C+  where  (oepwhs = :sbwhse
     C+          and oepbatid = :sbbatid and oepststs < :OldestStamp)
     C/END-EXEC


     C/EXEC SQL
     C+  delete
     C+  from   expsordd
     C+  where  (oedwhs = :sbwhse
     C+          and oedbatid = :sbbatid and oedststs < :OldestStamp)
     C/END-EXEC


     C/EXEC SQL
     C+  delete
     C+  from   expsordl
     C+  where  (oelwhs = :sbwhse
     C+          and oelbatid = :sbbatid and oelststs < :OldestStamp)
     C/END-EXEC

     C/EXEC SQL
     C+  delete
     C+  from   expsordh
     C+  where  (oehwhs = :sbwhse
     C+          and oehbatid = :sbbatid and oehststs < :OldestStamp)
     C/END-EXEC


770a C/EXEC SQL
770a C+  delete
770a C+  from   expsordlt
770a C+  where  (oeltwhs = :sbwhse
770a C+          and oeltbatid = :sbbatid and oeltststs < :OldestStamp)
770a C/END-EXEC
    A*----------------------------------------------------------------
     C                   when      sbtype = 'EXPROUTE'  or
     C                             sbtype = 'EXPCLSRTE'

     C/EXEC SQL
     C+  delete
     C+  from   expsordh
     C+  where  (oehwhs = :sbwhse
     C+          and oehbatid = :sbbatid and oehststs < :OldestStamp)
     C/END-EXEC


     C/EXEC SQL
     C+  delete
     C+  from   expsordd
     C+  where  (oedwhs = :sbwhse
     C+          and oedbatid = :sbbatid and oedststs < :OldestStamp)
     C/END-EXEC

    A*----------------------------------------------------------------
     C                   when      sbtype = 'EXPADJUST'

     C/EXEC SQL
     C+  delete
     C+  from   expsadj
     C+  where  (iewhse = :sbwhse
     C+          and iebatid = :sbbatid and ieststs < :OldestStamp)
     C/END-EXEC
750 A
750 AC/EXEC SQL
750 AC+  delete
750 AC+  from   expsadj2
750 AC+  where  (iewhse = :sbwhse
750 AC+          and iebatid = :sbbatid and ieststs < :OldestStamp)
750 AC/END-EXEC
770aA
770aAC/EXEC SQL
770aAC+  delete
770aAC+  from   expsadjlt
770aAC+  where  (ieltwhs = :sbwhse
770aAC+          and ieltbatid = :sbbatid and ieltststs < :OldestStamp)
770aAC/END-EXEC

    A*----------------------------------------------------------------
     C                   when      sbtype = 'EXPLLCOMB'

     C/EXEC SQL
     C+  delete
     C+  from   expsllcomb
     C+  where  (lewhse = :sbwhse
     C+          and lebatid = :sbbatid and leststs < :OldestStamp)
     C/END-EXEC

640 A*----------------------------------------------------------------
640 AC                   when      sbtype = 'EXPRETURN'
640 A
640 AC/EXEC SQL
640 AC+  delete
640 AC+  from   expsrtn
640 AC+  where  (oewhse = :sbwhse
640 AC+          and oebatid = :sbbatid and oeststs < :OldestStamp)
640 AC/END-EXEC
640 A
770aAC/EXEC SQL
770aAC+  delete
770aAC+  from   expsrtnlt
770aAC+  where  (orltwhse = :sbwhse
770aAC+          and orltbatid = :sbbatid and orltststs < :OldestStamp)
770aAC/END-EXEC
640 A
640 A*----------------------------------------------------------------
640 AC                   when      sbtype = 'EXPPO'
640 A
640 AC/EXEC SQL
640 AC+  delete
640 AC+  from   expspoe
640 AC+  where  (poewhs = :sbwhse
640 AC+          and poebatid = :sbbatid and poeststs < :OldestStamp)
640 AC/END-EXEC
640 AC/EXEC SQL
640 AC+  delete
640 AC+  from   expspod
640 AC+  where  (pedwhs = :sbwhse
640 AC+          and pedbatid = :sbbatid and pedststs < :OldestStamp)
640 AC/END-EXEC
640 AC/EXEC SQL
640 AC+  delete
640 AC+  from   expspoh
640 AC+  where  (pehwhs = :sbwhse
640 AC+          and pehbatid = :sbbatid and pehststs < :OldestStamp)
640 AC/END-EXEC
770aAC/EXEC SQL
770aAC+  delete
770aAC+  from   expspolt
770aAC+  where  (peltwhs = :sbwhse
770aAC+          and peltbatid = :sbbatid and peltststs < :OldestStamp)
770aAC/END-EXEC
640bA
640bA*----------------------------------------------------------------
640bAC                   when      sbtype = 'EXPLICLOG'
640bA
640bAC/EXEC SQL
640bAC+  delete
640bAC+  from   expsliclog
640bAC+  where  (lewhse = :sbwhse
640bAC+          and lebatid = :sbbatid and leststs < :OldestStamp)
640bAC/END-EXEC
640bA
640bA*----------------------------------------------------------------
640bAC                   when      sbtype = 'EXPITMQTY2'
640bA
640bAC/EXEC SQL
640bAC+  delete
640bAC+  from   expsqty2
640bAC+  where  (qewhse = :sbwhse
640bAC+          and qebatid = :sbbatid and qeststs < :OldestStamp)
640bAC/END-EXEC
650aA*----------------------------------------------------------------
650aAC                   when      sbtype = 'EXPTRN'
650aA
650aAC/EXEC SQL
650aAC+  delete
650aAC+  from   expstrn
650aAC+  where  (pewhse = :sbwhse
650aAC+          and pebatid = :sbbatid and peststs < :OldestStamp)
650aAC/END-EXEC
650aA
650bA*----------------------------------------------------------------
      /free
650bA   when sbtype = 'EXPPCKLBL';
650bA
650bA   exec sql
650bA    delete from expsplbl
650bA     where (lbewhs = :sbwhse
650bA       and  lbebatid = :sbbatid
650bA       and  lbeststs < :OldestStamp);
650bA /end-free
760 A
760 A *----------------------------------------------------------------
760 A /free
760 A   when sbtype = 'EXPUPC';
760 A
760 A   exec sql
760 A    delete from expsupc
760 A     where (ucwhse = :sbwhse
760 A       and  ucbatid = :sbbatid
760 A       and  ucststs < :OldestStamp);
760 A /end-free
    A*----------------------------------------------------------------
     C                   endsl
    A*----------------------------------------------------------------

     C                   endsr

     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr

     *
     *  Variables and constants.
     *
     C                   eval      eofi = *off
     *
     C                   eval      oldestStamp = %timestamp(%date())-
     C                             %days($pdays2keep)

     C                   endsr
