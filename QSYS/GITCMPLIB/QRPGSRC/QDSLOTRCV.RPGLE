     F*----------------------------------------------------------------
     F*
     F*  QDSLOTRCV   Recover slot info from journal
     F*  18 May 2005
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FJRNSLOT   IP   E             DISK    prefix(jr_)
     FSLOT2     UF A E           K DISK
     FVSLOT     O    E             DISK

     D found           s               n
     D len             s              3  0
     D savedisp        s             12

     C*----------------------------------------------------------------
     C* Main line
     C*
     C     keysl2        klist
     C                   kfld                    jr_slwhse
     C                   kfld                    jr_slwhdp
     C                   kfld                    jr_sldisp

     C                   if        jr_jopgm =  'INZTBS'
     C                             and jr_joentt =  'UB'

     C     keysl2        chain     slot2
     C                   if        not %found
     C                   exsr      jr2sl
     C                   write     slrec
     C                   else
     C                   exsr      jr2sl
     C                   update    slrec
     C                   endif

     C                   if        slrsrv = 'V'
     C                   exsr      crtvslot
     C                   endif

     C                   endif

     C     bottom        tag

     *----------------------------------------------------------------
     *  crtvslot
     *----------------------------------------------------------------

     C     crtvslot      begsr

     C                   eval      savedisp = sldisp
     C                   eval      found = *off
     C                   eval      len = %len(%trim(jr_sldisp))
     C     1             do        2
     C                   eval      len = len - 1
     C                   eval      jr_sldisp = %subst(jr_sldisp:1:len)
     C     keysl2        chain     slot2
     C                   if        %found and slrsrv <> 'V'
     C                   eval      found = *on
     C                   leave
     C                   endif
     C                   enddo

     C                   if        found
     C                   eval      vswhse = slwhse
     C                   eval      vswhdp = slwhdp
     C                   eval      vsaisl = slaisl
     C                   eval      vsloc  = slloc
     C                   eval      vsrlvl = slrlvl
     C                   eval      vshand = slhand
     C                   eval      vsdisp = savedisp
     C                   eval      vspdis = jr_sldisp
     C                   eval      vscdte = slsdte
     C                   eval      vsctim = slstim

     C                   write(e)  vsrec
     C                   if        %error
     C                   endif

     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  jr2sl
     *----------------------------------------------------------------

     C     jr2sl         begsr

     C                   eval      slwhse = jr_slwhse
     C                   eval      slwhdp = jr_slwhdp
     C                   eval      sldisp = jr_sldisp
     C                   eval      slaisl = jr_slaisl
     C                   eval      slloc  = jr_slloc
     C                   eval      slrlvl = jr_slrlvl
     C                   eval      slhand = jr_slhand
     C                   eval      slside = jr_slside
     C                   eval      slstyp = jr_slstyp
     C                   eval      slstat = jr_slstat
     C                   eval      slsdte = jr_slsdte
     C                   eval      slstim = jr_slstim
     C                   eval      slsdef = jr_slsdef
     C                   eval      sldesg = jr_sldesg
     C                   eval      slactv = jr_slactv
     C                   eval      slbld  = jr_slbld
     C                   eval      slpick = jr_slpick
     C                   eval      slpseq = jr_slpseq
     C                   eval      slprty = jr_slprty
     C                   eval      slentd = jr_slentd
     C                   eval      slexpd = jr_slexpd
     C                   eval      slslfd = jr_slslfd
     C                   eval      slrsrv = jr_slrsrv
     C                   eval      slitem = jr_slitem
     C                   eval      slstk1 = jr_slstk1
     C                   eval      slstk2 = jr_slstk2
     C                   eval      slstk3 = jr_slstk3
     C                   eval      slalc1 = jr_slalc1
     C                   eval      slalc2 = jr_slalc2
     C                   eval      slalc3 = jr_slalc3
     C                   eval      sltfr1 = jr_sltfr1
     C                   eval      sltfr2 = jr_sltfr2
     C                   eval      sltfr3 = jr_sltfr3
     C                   eval      slpck1 = jr_slpck1
     C                   eval      slpck2 = jr_slpck2
     C                   eval      slpck3 = jr_slpck3
     C                   eval      slrcv1 = jr_slrcv1
     C                   eval      slrcv2 = jr_slrcv2
     C                   eval      slrcv3 = jr_slrcv3

     C                   endsr
