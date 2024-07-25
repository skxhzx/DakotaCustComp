500eA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDTPC40   Q&D-Update CROSSDK file with ORDD info
     *  01 July 2010
     *  Max Blacknik / Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions
     *
TPC A*    07/01/10  MLB  TPC
     *      - Created pgm to update CROSSDK, SLOT file for items that
     *        did not get imported as cross dock items.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fpiritem   if   e           k disk
416bAFslot1     uf a e           k disk
416bAFslot4     uf   e           k disk
     F                                     rename(slrec:slrec4)
520aAFslot11    uf   e           k disk
520aAF                                     rename(slrec:slrec11)
416aAFordd1     if   e           k disk
     F                                     rename(odrec:odrec1)
416bAFpodtl1    if   e           k disk
520bMFcrossdk   uf a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
416bMD desc            s             20    dim(6) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
416 AD a80             s              1    dim(80)
500dA*----------------------------------------------------------------
500dA*  Customer id
500dA*
     D @getcl          c                   const('GETCLIENT')
500dA*
     *----------------------------------------------------------------
     *  Working variables
     *
     D $pwhse          s              3  0
     D count           s              3  0
     D difqy1          s                   like(odqor1)
     D difqy2          s                   like(odqor2)
     D difqy3          s                   like(odqor3)
     D dummy           s              3  0
     D eofd            s              1
     D eofh            s              1
     D excprt          s              1
     D excpr1          s              1
     D forevr          s              1
     D good1           s              1
     D good2           s              1
     D impdte          s              8  0
     D imptim          s              6  0
     D kyaisl          s                   like(slaisl)
     D kydisp          s                   like(sldisp)
     D kystat          s                   like(odstat)
     D kywhdp          s                   like(itwhdp)
     D len             s              1  0
     D linppg          s              3  0
     D lstwhs          s              3  0
     D mrgitm          s              1
     D mrgord          s              1
     D mrgrte          s              1
     D opened          s              1
     D pflag           s              1
     D pos             s              1  0
     D prhdr1          s              1
     D rcdlck          s              1
     D rtcnt           s              3  0
     D skpwrt          s              1
510aMD sublin          s              7  0
     D subq1           s              7  0
     D subq2           s              7  0
     D subq3           s              7  0
     D tmpcub          s                   like(itcube)
     D tmploc          s              3  0
     D tmpwgt          s                   like(itswgt)
     D today           s              8  0
     D work3a          s              3
     D wrgsts          s              1
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHS   Warehouse number - (alpha)
     *      $PORD   Order ID (alpha)
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
     C                   parm                    $pord             7
     C                   parm                    $ppo              9
     *
     *----------------------------------------------------------------
     * Key definitions
     *
     *
     * Item file
     *
     C     itkey         klist
     C                   kfld                    odwhse
     C                   kfld                    oditem
     *----------------------------------------------------------------
     * Main line
     *
     C                   move      $pwhs         $pwhse            3 0
     C                   move      $pord         kyord             7 0
     *
     * Get import date/time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
520aA*
520aA* Delete all status 'Z' XDK slots.
520aA*
520aAC                   exsr      zzzdelxdk
     *
     *    Whip through all the download detail records
     *
     C                   eval      eofd = *off
     C     odkey         setll     ordd1
     C                   dou       eofd = *on
     *
     C     odkey         reade     ordd1
     C                   if        %eof(ordd1)
     C                   leave
     C                   endif
     *
     *       If item doesn't exist write error message.
     *
     C     itkey         chain     piritem                            76
     C                   if        *in76
     C                   endif
     C                   if        odspcl = 'XD'
     C                   exsr      zzxdck
     C                   endif
     *
     C                   enddo
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
416aA*
416aA*  *INZSR  Initialization subroutine
416aA*
416aAC     *inzsr        begsr
500dA*
500dA* Get client id.
500dA*
500dAC                   call      @getcl
500dAC                   parm                    client           10
500dAC                   parm                    cliloc           10
520bA*
520bA* CROSSDK  Cross Dock - Full key
520bAC     cdkey         klist
520bAC                   kfld                    slwhse
520bAC                   kfld                    slwhdp
520bAC                   kfld                    sldisp
416aA*
416aA* ORDD1 Order detail file - Partial key
416aA*
416aAC     odkey         klist
416aAC                   kfld                    $pwhse
416aAC                   kfld                    kyord
416bA*
416bA* PODTL1 PO DETAIL file
416bA*
416bAC     keypd1        klist
416bAC                   kfld                    $pwhse
416bAC                   kfld                    $ppo
416bAC                   kfld                    oditem
416bA*
416bA* SLOT1 file
416bAC     keysl1        klist
416bAC                   kfld                    $pwhse
416bAC                   kfld                    itwhdp
416bAC                   kfld                    kyaisl
416bA*
416bA* SLOT4 file
416bAC     keysl4        klist
416bAC                   kfld                    $pwhse
416bAC                   kfld                    itwhdp
416bAC                   kfld                    oditem
416bAC                   kfld                    kydisp
520aA*
520aA* SLOT11 file
520aAC     keysl11       klist
520aAC                   kfld                    $pwhse
520aAC                   kfld                    kyaisl
416aA*
416aA*  Variables and constants.
416aA*
416aAC                   eval      forevr = *off
416bA*
416aAC                   endsr
416bA*
416bA*----------------------------------------------------------------
416bA*
416bA*  ZZXDCK  Attach cross dock item to PO detail line.
416bA*
416bAC     zzxdck        begsr
416aA*
416bA* Loop through P.O. detail records looking for item.
416bAC     keypd1        setll     podtl1
416bAC                   dow       forevr = forevr
416bAC     keypd1        reade     podtl1                                 79
416bA* Error if none found.
416bAC                   if        *in79
416bAC                   eval      pdseq = 0
416bAC                   eval      pdpo = $ppo
416bAC                   endif
416bA* If cross dock slot record exists, update
416bAC                   movel     'XDK'         kydisp
416bAC     keysl4        setll     slot4
416bAC                   dow       forevr = forevr
416bAC                   read      slot4                                  79
416bAC                   if        not *in79  and
416bMC                             slstat = 'XD'  and
416bAC                             slwhse = $pwhse  and
416bAC                             slwhdp = itwhdp  and
416bAC                             slitem = oditem  and
416bAC                             slaisl = 'XDK'
416bA* Pre-allocate product in case receiving is done before picking.
416bAC                   add       odqor1        slalc1
416bAC                   if        itflg1 = 'Y'
416bAC                   add       odqor2        slalc2
416bAC                   endif
416bAC                   if        itflg2 = 'Y'
416bAC                   add       odqor3        slalc3
416bAC                   endif
416bAC                   update    slrec4
416bAC                   goto      addxdk
416bAC                   else
416bAC                   unlock    slot4
416bAC                   leave
416bAC                   endif
416bAC                   enddo
416bA* Create cross dock slot record.
416bAC                   eval      tmploc = 1
416bAC                   eval      kyaisl = 'XDK'
416bAC     keysl1        setll     slot1
416bAC                   dow       forevr = forevr
416bAC     keysl1        reade(n)  slot1                                  79
416bAC                   if        *in79  or
416bAC                             slloc > tmploc
416bAC                   leave
416bAC                   endif
416bAC     slloc         add       1             tmploc
416bAC                   enddo
416bA*
416bAC                   clear                   slrec
416bAC                   eval      slwhse = odwhse
416bAC                   eval      slwhdp = itwhdp
416bAC                   eval      slaisl = 'XDK'
416bAC                   eval      slloc = tmploc
416bAC                   eval      slrlvl = 1
416bAC                   eval      slhand = *blanks
416bAC                   eval      slstyp = 'X'
416bAC                   eval      slpseq = tmploc
416bAC                   eval      slitem = oditem
416bAC                   eval      slstat = odspcl
416bAC                   eval      slsdte = today
416bAC                   time                    slstim
416bAC                   eval      slpick = 'N'
416bAC                   eval      slrsrv = 'N'
416bA* Format display slot.
416bAC                   call      'FRMTSL'
416bAC                   parm                    slwhse
416bAC                   parm                    slwhdp
416bAC                   parm                    slaisl
416bAC                   parm                    slloc
416bAC                   parm                    slrlvl
416bAC                   parm                    slhand
416bAC                   parm                    slstyp
416bAC                   parm                    slpseq
416bAC                   parm                    sldisp
416bA* Pre-allocate product in case receiving is done before picking.
416bAC                   eval      slalc1 = odqor1
416bAC                   if        itflg1 = 'Y'
416bAC                   z-add     odqor2        slalc2
416bAC                   endif
416bAC                   if        itflg2 = 'Y'
416bAC                   z-add     odqor3        slalc3
416bAC                   endif
416bA* Add record
416bAC     slloc         div       2             dummy
416bAC                   mvr                     slside
416bAC                   if        slside < 0
416bAC                   eval      slside = -(slside)
416bAC                   endif
416bAC                   write     slrec                                77
416bA* Error if slot not created.
416bAC                   if        *in77
416bAC                   leave
416bAC                   endif
416bA* Create cross dock record.
416bAC     addxdk        tag
416bAC                   eval      cdwhse = slwhse
416bAC                   eval      cdwhdp = slwhdp
416bAC                   eval      cdslot = sldisp
416bAC                   eval      cdord = odord
416bAC                   eval      cdorsq = odseq
416bAC                   eval      cdort# = 0
416bAC                   eval      cdorl# = 0
416bAC                   eval      cdpo = pdpo
416bAC                   eval      cdposq = pdseq
416bAC                   eval      cdpot# = 0
416bAC                   eval      cdpol# = 0
416bAC                   write     cdrec                                79
416bAC                   if        *in79
416bAC                   else
416bAC                   eval      good2 = 'Y'
416bAC                   endif
416bAC                   leave
416bAC                   enddo
416bA*
416bAC     endxd         endsr
416bA*
520aA*----------------------------------------------------------------
520aA*
520aA*  ZZXDELXDK   Delete status 'Z' XDK slots
520aA*
520aAC     zzzDelXDK     begsr

     C                   eval      kyaisl = 'XDK'
     C     keysl11       setll     slot11
     C                   dow       forevr = forevr
     C     keysl11       reade     slot11
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        slstat = 'Z'
     C                   delete    slrec11
520bA*
520bA*      Delete matching record from Cross Dock file.
520bAC     cdkey         setll     crossdk
520bAC                   dow       forevr = forevr
520bAC     cdkey         reade     crossdk
520bAC                   if        %eof(crossdk)
520bAC                   leave
520bAC                   endif
520bAC
520bAC                   delete    cdrec
520bAC                   enddo
520bA*
     C                   endif
     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
*EXIST*
*INVALID ITEM*
*BREAKDOWN INVALID*
*INVALID X-DOCK PO*
*XDK SLOT ERROR*
*NO XDK REC CREATED*
**
Import FTP Orders
