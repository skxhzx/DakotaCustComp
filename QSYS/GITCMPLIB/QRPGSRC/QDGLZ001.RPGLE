      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDGLZ001  Q&D - Glaizer Foods - Create o/flow slots from pick.
     *  09 July 2009
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    07/09/09  MLB  5.20
     *      - Created.
     *
     *----------------------------------------------------------------
     *
     fslot8qd   if   e           k disk    rename(slrec:slrec8)
     F                                     prefix(QD_)
     fslot1     if a e           k disk    rename(slrec:slrec1)
     *----------------------------------------------------------------
     *  Customer id
     *
GLZ A /COPY QCOPYSRC,ID#glazier
     *----------------------------------------------------------------
     D svaisl          s                   like(slaisl)
     D svloc           s                   like(slloc )
     D svrlvl          s                   like(slrlvl)
     D wkrlvl          s                   like(slrlvl)
     *
     D                 ds
     D bay                     4      5
     D rlvl                    7      7  0
     D lvlseq                  7      8
     D QD_sldisp               1     12
     *
     D                 ds
     D wkpseq4a                1      4
     D wkpseq4                 1      4  0 inz(0)
     *
     C     sl1key        klist
     C                   kfld                    qd_slwhse
     C                   kfld                    qd_slwhdp
     C                   kfld                    qd_slaisl
     C                   kfld                    qd_slloc
     C                   kfld                    wkrlvl
     C                   kfld                    qd_slhand
     *
     C     sl8key        klist
     C                   kfld                    $pwhse
     C
     C                   z-add     001           $pwhse            3 0
     C                   move      '1'           forever           1
     C
     C     sl8key        setll     slot8qd
     C                   dow       forever = forever
     C     sl8key        reade     slot8qd
     C                   select
     C                   when      %eof(slot8qd)
     C                   leave
     C                   when      qd_slpick <> 'Y'
     C                             or qd_slrsrv = 'V'
     C                             or qd_sldisp = 'CWNEW'
     C                             or qd_sldisp = 'CWOLD'
     C                             or qd_sldisp = 'DARES'
     C                             or qd_sldisp = 'DROPS'
     C                             or qd_sldisp = 'DWNEW'
     C                             or qd_sldisp = 'DWOLD'
     C                             or qd_sldisp = 'FWNEW'
     C                             or qd_sldisp = 'FWOLD'
     C                   iter
     C*
     C                   when      qd_slpick = 'Y'
     C                             and (qd_slaisl <> svaisl
     C                              or  qd_slloc <> svloc
     C                              or  qd_slrlvl <> svrlvl)
     C*      Process only slots less than physical rack lvl 7.
     C                             and qd_slrlvl < 8
     C*      Process only slots with numeric rack level.
     C                             and %subst(qd_sldisp:7:1) >= '0'
     C                             and %subst(qd_sldisp:7:1) <= '9'
     C*
     C                   eval      svaisl = qd_slaisl
     C                   eval      svloc  = qd_slloc
     C                   eval      svrlvl = qd_slrlvl
     C                   eval      wkrlvl = qd_slrlvl
     C*
     C                   dow       rlvl < 8
     C                   eval      rlvl = rlvl + 1
     C                   eval      wkrlvl = wkrlvl + 1
     C*
     C*      Only create slots up to display rack lvl 7.
     C                   if        rlvl <= 7
     C     sl1key        chain     slot1
     C                   select
     C                   when      not %found(slot1)
     C                   eval      slwhse = qd_slwhse
     C                   eval      slwhdp = qd_slwhdp
     C                   eval      slaisl = qd_slaisl
     C                   eval      slloc  = qd_slloc
     C                   eval      slrlvl = wkrlvl
     C                   eval      slhand = qd_slhand
     C                   eval      slside = qd_slside
     C                   eval      slstyp = qd_slstyp
     C                   eval      sldisp = qd_sldisp
     C                   eval      slstat = qd_slstat
     C                   eval      slsdte = qd_slsdte
     C                   eval      slstim = qd_slstim
     C                   eval      slsdef = qd_slsdef
     C                   eval      sldesg = qd_sldesg
     C                   eval      slactv = qd_slactv
     C                   eval      slbld  = qd_slbld
     C                   eval      slpick = 'N'
     C                   eval      wkpseq4a = bay + lvlseq
     C                   eval      slpseq = wkpseq4
     C                   eval      slprty = 0
     C                   eval      slentd = 0
     C                   eval      slexpd = 0
     C                   eval      slrsrv = 'N'
     C                   eval      slstk1 = 0
     C                   eval      slstk2 = 0
     C                   eval      slstk3 = 0
     C                   eval      slalc1 = 0
     C                   eval      slalc2 = 0
     C                   eval      slalc3 = 0
     C                   eval      sltfr1 = 0
     C                   eval      sltfr2 = 0
     C                   eval      sltfr3 = 0
     C                   eval      slpck1 = 0
     C                   eval      slpck2 = 0
     C                   eval      slpck3 = 0
     C                   eval      slrcv1 = 0
     C                   eval      slrcv2 = 0
     C                   eval      slrcv3 = 0
     C                   write     slrec1
     C                   endsl
     C                   endif
     C*
     C                   enddo
     *
     C                   endsl
     *
     C                   enddo
     *
     C                   eval      *inlr = '1'
     *
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
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     C                   endsr
