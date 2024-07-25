     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IV015     Import inventory Count file - Post
     *  Dave Sommerville
     *  Roxanne Harrison
     *  31 March, 1997
     *       created using PI215
     *
     *  Revisions
414 A*  05/15/00  RH   4.14
     *    - Recompile - INVSLOT file changed.
416 A*  09/25/01  RH   4.16
     *    - Recompile - INVSLOT file changed.
700 A*  08/18/16  MR   7.00a
     *    - Covered to RPGLE
     *    - Enh: Update ICDCNTD when INVSLOT is updated for
     *           history purposes.
700bA*  09/14/16  LMC  7.00b
     *    - Enh: New history files names changed.
     *    - Enh: Dept added to invinuse file to ensure unique # is
     *           by whse/department.
     *
710aA*  03/23/17  LMC  7.10a
     *    - Enh: Database change to INVHSTD. Recompile only.
710bA*  12/22/17  LMC  7.10b
     *    - Enh: Database change to INVHSTD. Recompile only.
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for IMPCNT
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpcnt    uf   e           k disk
     Fwarehs    if   e           k disk
     *EPORTS IF  E           K        DISK
     Fpiritem   if   e           k disk
     Fslot2     if   e           k disk
     Finvslot   uf   e           k disk
     Finvpage   uf   e           k disk
700bDF*icdcntd   uf   e           k disk
700bAFinvhstd   uf   e           k disk
700aAFinvinuse  if   e           k disk
     Fiv015pr   o    e             printer oflind(*in91)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             20    dim(4) ctdata perrcd(1)
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
     D $pwhse          s              3  0
     D count           s              3  0                                      LINE COUNTER
     D eofh            s              1
     D good1           s              1
     D len             s              1  0
     D linppg          s              3  0                                      MAX LINES PER PAGE
     D pflag           s              1
     D pos             s              1  0
     D work3a          s              3
700bAD savdpt          s              5
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHS   Warehouse to process.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs            15 5
     *----------------------------------------------------------------
     C                   z-add     $pwhs         $pwhse
     * Key definitions
     *
     * Download inventory count file - Partial key
     *
     C     iickey        klist
     C                   kfld                    $pwhse
     *
     * INVSLOT key - Full key
     *
     C     ivskey        klist
     C                   kfld                    iicwhs
     C                   kfld                    iicwhd
     C                   kfld                    slaisl
     C                   kfld                    slloc
     C                   kfld                    slrlvl
     C                   kfld                    slhand
     *
     *  Define key for INVPAGE file.
     *
     C     ipkey         klist
     C                   kfld                    ivswhs
     C                   kfld                    ivspag
     *
     * Item file
     *
     C     itkey         klist
     C                   kfld                    iicwhs
     C                   kfld                    iicitm
     *
     * SLOT file
     *
     C     slkey         klist
     C                   kfld                    iicwhs
     C                   kfld                    iicwhd
     C                   kfld                    iicdsp
700aA*    Cycle Count History Detail
700aAC     dkey          klist
700aAc                   kfld                    icduid
700bAc                   kfld                    ivswhs
700bAc                   kfld                    ivswhd
     c                   kfld                    ivsdsp
700aA*    Inventory In Use
700aAC     ikey          klist
700aAc                   kfld                    $pwhse
     *----------------------------------------------------------------
     * Main line
     *
     * Get report heading.
     *
     *                    MOVE *BLANKS   W1HEAD
     *                    MOVEL'IV015PR' RPPRTF
     *          RPPRTF    CHAINREPORTS              79
     *          *IN79     IFEQ *OFF
     *                    MOVELRPDESC    $PSTR
     *                    ELSE
     *                    MOVE *BLANKS   $PSTR
     *                    ENDIF
     *                    Z-ADD50        $PLEN
     *
     *                    CALL 'CENTER'
     *                    PARM           $PSTR  60
     *                    PARM           $PLEN   30
     *                    MOVEL$PSTR     W1HEAD
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      $pwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     * Get Inventory In Use #
700bA * moved below - need department first
700bDC*    ikey          chain     invinuse
700bDc*                  if        %found
700bDc*                  eval      icduid = inuuid
700bDc*                  endif
     *
     * Initialize grand total fields
     *
     C                   eval      grdord = 0
     C                   eval      noslot = 0
     C                   eval      noitem = 0
     C                   eval      badqty = 0
     *
     * Whip through all the download records
     *
     C                   eval      pflag = *off
     C                   eval      eofh = *off
     C                   eval      linppg = 55                                  MAX LINES PER PAGE
     C                   eval      count = 0                                    LINE COUNTER
     C     iickey        setll     impcnt
     C                   dou       eofh = *on
     *
     C     iickey        reade     impcnt                                 79
     C                   if        *in79
     C                   eval      eofh = *on
     C                   goto      enddoh
     C                   endif
700bAC* need to get the invinuse when the department changes
700bA /free
700bA   if savdpt <> iicwhd;
700bA     chain ($pwhse: iicwhd) invinuse;
700bA     if %found(invinuse);
700bA       icduid = inuuid;
700bA     endif;
700bA     savdpt = iicwhd;
700bA   endif;
700bA /end-free
     *
     *  Print report heading if necessary.
     *
     C                   if        pflag = *off  or
     C                             count >= linppg
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   eval      pflag = *off
     C                   endif
     *
     C                   if        pflag = *off
     C                   write     head4
     C                   add       2             count
     C                   eval      pflag = *on
     C                   endif
     *
     C                   eval      detmsg = *blanks
     C                   eval      good1 = 'Y'
     *
     *       If item doesn't exist write error message.
     *
     C     itkey         chain     piritem                            76
     C                   if        *in76
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   eval      good1 = 'N'
     C                   eval      itdesc = *blanks
     C                   movel     '*****'       itdesc
     C                   goto      endit
     C                   endif
     *
     C                   if        iicqt1 <> 0  or
     C                             iicqt2 <> 0  or
     C                             iicqt3 <> 0
     C                   if        iicitm = *blanks
     C                   eval      detmsg = desc(3)
     C                   add       1             badqty
     C                   eval      good1 = 'N'
     C                   goto      endit
     C                   endif
     C                   endif
     *
     *  Verify normal quantity is within range.
     *
     C                   if        iicqt1 < 0  or
     C                             iicqt1 > 99999
     C                   eval      detmsg = desc(3)
     C                   add       1             badqty
     C                   eval      good1 = 'N'
     C                   goto      endit
     C                   endif
     *
     *  Verify Breakdown qty 1 is within range.
     *
     C                   if        iicqt2 < 0  or
     C                             iicqt2 > 999
     C                   eval      detmsg = desc(3)
     C                   add       1             badqty
     C                   eval      good1 = 'N'
     C                   goto      endit
     C                   endif
     *
     *  Verify Breakdown qty 2 is within range.
     *
     C                   if        iicqt3 < 0  or
     C                             iicqt3 > 999
     C                   eval      detmsg = desc(3)
     C                   add       1             badqty
     C                   eval      good1 = 'N'
     C                   goto      endit
     C                   endif
     *
     *
     *  Verify Slot.
     *
     C     slkey         chain     slot2                              77
     C                   if        *in77
     C                   eval      detmsg = desc(1)
     C                   add       1             noslot
     C                   eval      good1 = 'N'
     C                   goto      endit
     C                   endif
     *
     C                   if        good1 = 'Y'
     C     ivskey        chain     invslot                            78
     C                   if        not *in78
     C                   exsr      fillis
     C                   update    ivsrec                               49
     C     ipkey         chain     invpage                            77
     C                   if        not *in77
     C                   eval      ivpedt = $cvd8o
     C                   time                    ivpetm
     C                   move      '*IMPORT'     ivpeby
     C                   eval      ivpsta = 'E'
     C                   update    ivprec
     C                   endif
     C                   else
     C                   eval      detmsg = desc(4)
     C                   add       1             noslot
     C                   eval      good1 = 'N'
     C                   goto      endit
     C                   endif
     C                   endif
     *
     C     endit         tag
     C                   if        good1 = 'N'
     C                   write     detail
     C                   endif
     *
     *
     *    Print order subtotals and update grand totals
     *
     **                   EXSR ZRHEAD
     **                   ADD  3         COUNT
     C                   add       1             grdord
     *
     *  Delete header record from download file
     *
     C                   delete    iicrec
     *
     C     enddoh        tag
     C                   enddo
     *
     *  Print order grand totals
     *
     C                   if        pflag = *on
     C                   if        count >= linppg
     C                   write     head1
     C                   endif
     C                   write     grndttl
     C                   endif
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  FILLIS  Fill INVSLOT fields.
     *
     C     fillis        begsr
     *
     *
     *  Move fields from download file to INVSLOT  fields
     *
     C                   eval      ivsitm = iicitm
     C                   eval      ivsqt1 = iicqt1
     C                   eval      ivsqt2 = iicqt2
     C                   eval      ivsqt3 = iicqt3
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ivsedt = $cvd8o
     C                   time                    ivsetm
     C                   move      '*IMPORT'     ivseby
     *
700bDC*    dkey          chain     icdcntd
700bMC     dkey          chain     invhstd
700aAC                   if        %found
700aAC                   eval      icdaqty1 = iicqt1
700aAC                   eval      icdaqty2 = iicqt2
700aAC                   eval      icdaqty3 = iicqt3
700aAc                   eval      icdadj1 = icdaqty1 - icdbqty1
700aAc                   eval      icdadj2 = icdaqty2 - icdbqty2
700aAc                   eval      icdadj3 = icdaqty3 - icdbqty3
700aAc                   if        ivsedt > 0
700aAc                   eval      icdslcnt= 'Y'
700aAc                   eval      icdsltts= %timestamp
700aAc                   endif
700aAC                   update    icdrec
700aAc                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   write     head4
     C                   add       2             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
*INVALID SLOT*
*INVALID ITEM*
*INVALID QUANTITY*
*INVALID SCOPE*
