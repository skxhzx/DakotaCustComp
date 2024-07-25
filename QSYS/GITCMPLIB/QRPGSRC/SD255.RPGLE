     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  SD255     FTP - Import slot check digit updates - Post
     *  08 January 2010
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *
     *----------------------------------------------------------------
     *
530 A*    01/08/10  MLB  5.30
     *      - Created.
     *      - Client custom code support included.
530aA*    02/09/10  MLB  5.30a
     *      - Fix: Revised program to seton report overflow indicator
     *        so headings are printed first time.
530bA*    12/16/10  MLB  5.30b
     *      - Fix: Revised program to not allow virtual slots to be
     *        imported with check digits attached.
     *
650 A*    09/19/13  MLB  6.50
     *      - Fix: Revised program to only allow new check digits to
     *        be created for Update Type A or C.
650aA*    02/25/14  MLB  6.50a
     *      - Fix: Revised program to monitor for record lock on SLOTDGT
     *        and SLOTDGTA. If lock error is encountered, log error and
     *        continue with next record.
     *
650bA*    04/18/13  MLB  6.50b
     *      - Enh: Revised program to only print out check digit update
     *        exceptions.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpfckdgt uf   e             disk
     Foptions   if   e           k disk
     Fslot2     if   e           k disk
     Fslotdgt   uf a e           k disk
     Fslotdgta  uf a e           k disk
     Freports   if   e           k disk
     Fwarehs    if   e           k disk
     Fsd255pr   o    e             printer oflind(*in91)
     *----------------------------------------------------------------
     *  Customer id
     *
     *
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a30             s              1    dim(30)
530bDD*desc            s             30    dim(7) ctdata perrcd(1)
650aDD*desc            s             30    dim(8) ctdata perrcd(1)
650aMD desc            s             30    dim(10) ctdata perrcd(1)
     *
     *----------------------------------------------------------------
     *  *CHKDGT  -  Check digit options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCOD#  -  Number of check digit codes per slot (1,2,3)
     *    OPDGT#  -  Maximum number of digits per code  (2,3)
     *    OPIDC1  -  Code 1 identifier
     *    OPIDC2  -  Code 2 identifier
     *    OPUNU2  -  Unused
     *    OPIDC3  -  Code 3 identifier
     *    OPUNU3  -  Unused
     *    OPIDD1  -  Digit 1 identifier
     *    OPIDD2  -  Digit 2 identifier
     *    OPIDD3  -  Digit 3 identifier
     *    OPRCOD  -  Current code to read (S=Single,R=Random)
     *    OPRCD1  -  Use code 1 for current reading (Y,N)
     *    OPRCD2  -  Use code 2 for current reading (Y,N)
     *    OPRCD3  -  Use code 3 for current reading (Y,N)
     *    OPRORD  -  Current read order (S=Single, R=Random)
     *    OPRLCR  -  Use read order Left/Center/Right (Y,N)
     *    OPRRCL  -  Use read order Right/Center/Left (Y,N)
     *    OPRLRC  -  Use read order Left/Right/Center (Y,N)
     *    OPRRLC  -  Use read order Right/Left/Center (Y,N)
     *    OPRCLR  -  Use read order Cener/Left/Right  (Y,N)
     *    OPRCRL  -  Use read order Cener/Right/Left  (Y,N)
     *    OPREAD  -  Number of digits user reads for codes
     *               less than 100.
     *
     * Data structure
     *
     D opdata          ds
     D  opcod#                 1      1  0
     D  opdgt#                 2      2  0
     D  opidc1                 3      8
     D  opidc2                 9     14
     D  opunu2                15     16
     D  opidc3                17     22
     D  opunu3                23     24
     D  opidd1                25     30
     D  opidd2                31     36
     D  opidd3                37     42
     D  oprcod                43     43
     D  oprcd1                44     44
     D  oprcd2                45     45
     D  oprcd3                46     46
     D  oprord                47     47
     D  oprlcr                48     48
     D  oprrcl                49     49
     D  oprlrc                50     50
     D  oprrlc                51     51
     D  oprclr                52     52
     D  oprcrl                53     53
     D  opread                54     54  0
     D  opreada               54     54
     D  optend               117    117
     *
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

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *
     *----------------------------------------------------------------
     *  Working Variables
     *
     D addflg          s              1
     D chgflg          s              1
     D count           s              3  0
     D error           s              1
     D first           s              1
     D forever         s              1
     D grdord          s              5  0
     D impdate         s              8  0
     D imptime         s              6  0
     D kywhse          s              3  0
     D len             s              1  0
     D linppg          s              3  0
     D pflag           s              1
     D pos             s              1  0
     D work3a          s              3
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * Main line
     *
     * Whip through all the download Update slot check digit records.
     *
     C                   eval      first = *on
     C                   dow       forever = forever
     *
     C                   read      impfckdgt
     C                   eval      error = *off
     C                   if        %eof(impfckdgt)
     C                   leave
     C                   endif
530aA*
530aA*  Count records read in from import file.
530aAC                   eval      grdlin = grdlin + 1
     *
     *  First time through
     *
     C                   if        first = *on
     C                   exsr      zzinz2
     C                   eval      first = *off
     C                   endif
     *
     *    Make sure warehouse was entered.
     *
     C                   if        icdwhs = 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(1)
     C                   goto      endicd
     C                   endif
     *
     *    Delete record or error check for update/add.
     C                   if        icdtyp = 'D'
     C                   exsr      zzdelckdgt
     C                   else
     C                   exsr      zzchkd
     C                   endif
     *
     C                   if        error = *off  and
     C                             icdtyp <> 'D'
     C                   exsr      zzupd
     C                   endif
     *
650bAC                   if        error = '1'
650bA*
     C                   if        *in91 = '1'
     C                   write     head1                                91
     C                   endif
     C                   write     detail                               91
     *
650 AC                   endif
     *
     *       Delete detail record from download file
     *
     C                   delete    icdrec
     *
     C     endicd        tag
     C                   enddo
     *
     *
     *  Print order grand totals
     *
     C                   if        *in91 = *on
     C                   write     head1                                91
     C                   endif
     C                   write     grndttl                              91
     *
     C                   if        *in91 = *on
     C                   write     head1                                91
     C                   endif
     C                   write     foot1                                91
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
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
     * Key definitions
     *
     *  Define key for options file.
     *
     C     opkey         klist
     C                   kfld                    kywhse
     C                   kfld                    opcode
     *
     *  Define key for slot2 file.
     *
     C     slkey         klist
     C                   kfld                    icdwhs
     C                   kfld                    icdwhd
     C                   kfld                    icddsp
     *
     *  Define key for slotdgt file.
     *
     C     scdky         klist
     C                   kfld                    icdwhs
     C                   kfld                    icdwhd
     C                   kfld                    icddsp
     *
     *  Define key for slotdgta file.
     *
     C     scdaky        klist
     C                   kfld                    icdwhs
     C                   kfld                    icdwhd
     C                   kfld                    icddsp
     *
     *  Variables and constants.
     *
     C                   eval      forever = *off
     *
     *  Convert today's date into MMDDYY format.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rdate = $cvd6o
     C                   time                    rtime
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdate = $cvd8o
     C                   time                    imptime
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKD   Slot check digit update error checking.
     *
     C     zzchkd        begsr
     C                   eval      error  = *off
     C                   eval      detmsg = ' '
     *
     *  Begin specific checks when adding a record.
     *
     *  Verify warehouse department.
     *
     C                   eval      $lcmd = '*VERIFYB'
     C                   eval      $lwhse = icdwhs
     C                   eval      $lwhdp = icdwhd
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn <> '*OK'
     C                   eval      error = *on
     C                   eval      noslot = noslot + 1
     C                   eval      detmsg = desc(2)
     C                   goto      endchkd
     C                   endif
     *
     *  Verify slot is on file.
     *
     C                   select
     C                   when      icddsp = ' '
     C                   eval      error = *on
     C                   eval      noslot = noslot + 1
     C                   eval      detmsg = desc(3)
     C                   goto      endchkd
     *
     C                   when      icddsp > ' '
530bDC*    slkey         setll     slot2
530bMC     slkey         chain     slot2
530bAC                   select
530bDC*                  if        not %equal(slot2)
530bMC                   when      not %found(slot2)
     C                   eval      error = *on
     C                   eval      noslot = noslot + 1
     C                   eval      detmsg = desc(4)
     C                   goto      endchkd
530bAC*
530bA*      Virtual slots not allowed for check digits.
530bAC                   when      %found(slot2)
530bAC                             and slrsrv = 'V'
530bAC                   eval      error = *on
530bAC                   eval      noslot = noslot + 1
530bAC                   eval      detmsg = desc(8)
530bAC                   goto      endchkd
530bAC*
530bDC*                  endif
530bMC                   endsl
     C                   endsl
     *
     *  Verify slot check digits sent.
     *
     C                   select
     C                   when      icddg1 < 0
     C                             or icddg2 < 0
     C                             or icddg3 < 0
     C                   eval      error = *on
     C                   eval      baddgt = baddgt + 1
     C                   eval      detmsg = desc(5)
     C                   goto      endchkd
     *
     C                   when           opcod# = 1
     C                             and (icddg2 > 0
     C                             or   icddg3 > 0)
     C                   eval      error = *on
     C                   eval      maxsnt = maxsnt + 1
     C                   eval      detmsg = desc(6)
     C                   goto      endchkd
     *
     C                   when      opcod# = 2
     C                             and icddg3 > 0
     C                   eval      error = *on
     C                   eval      maxsnt = maxsnt + 1
     C                   eval      detmsg = desc(6)
     C                   goto      endchkd
     *
     C                   endsl
     *
     *  Verify max check digits per code not exceeded.
     *
     C                   select
     C                   when      opdgt# = 2
     C                             and (icddg1 > 99
     C                             or   icddg2 > 99
     C                             or   icddg3 > 99)
     C                   eval      error = *on
     C                   eval      maxdgt = maxdgt + 1
     C                   eval      detmsg = desc(7)
     C                   goto      endchkd
     *
     C                   endsl
     *
     C     endchkd       endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZDELCKDGT    Delete check digits on file.
     *
     C     zzdelckdgt    begsr
     C                   eval      error = *off
     *
650 DC*    scdky         chain     slotdgt
650aMC     scdky         chain (e) slotdgt
650aAC                   select
650aAC                   when      %error
650aAC                   eval      detmsg = desc(9)
650aA*
650aMC                   when      %found(slotdgt)
     C                   delete    scdrec
650aMC                   endsl
     *
650aDC*    scdaky        chain     slotdgta
650aMC     scdaky        chain (e) slotdgta
650aAC                   select
650aAC                   when      %error
650aAC                   eval      detmsg = desc(10)
650aA*
650aMC                   when      %found(slotdgta)
     C                   delete    scdreca
650aMC                   endsl
     *
     C     enddelckdgt   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *  Define key for SLOT2 file.
     *
     C     keysl         klist
     C                   kfld                    icdwhs
     C                   kfld                    icdwhd
     C                   kfld                    icddsp
     *
     * Get report heading.
     *
530aAC                   eval      *in91 = '1'
     C                   eval      w1head = *blanks
     C                   movel     'SD255PR'     rpprtf
     C     rpprtf        chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     icdwhs        chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      icdwhs        work3a
     C     ' 0'          check     work3a        pos
     C                   if        pos = 0
     C                   eval      pos = 1
     C                   endif
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     * Initialize grand total fields
     *
     C                   eval      grdlin = 0
     C                   eval      noslot = 0
     C                   eval      baddgt = 0
     C                   eval      maxsnt = 0
     C                   eval      maxdgt = 0
     *
     *   Get check digit options.
     *
     C                   eval      kywhse = icdwhs
     C                   eval      opcode = '*CHKDGT '
     C     opkey         chain     options
     C                   if        not %found(options)
     C                   eval      opcod# = 3
     C                   eval      opdgt# = 3
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update for check digits
     *
     C     zzupd         begsr
     *
     *      Update primary check digit.
650aDC*    scdky         chain     slotdgt
650aMC     scdky         chain (e) slotdgt
650aAC                   select
650aAC                   when      %error
650aAC                   eval      detmsg = desc(9)
650aA*
650aMC                   when      not %found(slotdgt)
650 AC                             and (icdtyp = 'A'
650 AC                               or icdtyp = 'C')
     C                   clear                   scdrec
     C                   eval      scdwhs = icdwhs
     C                   eval      scdwhd = icdwhd
     C                   eval      scddsp = icddsp
     C                   eval      scddgt = icddg1
     C                   eval      scdadt = impdate
     C                   eval      scdatm = imptime
     C                   eval      scdaby = #user
     C                   Write     scdrec
650aMC                   other
650 A*
650 AC                   if        icdtyp = 'C'
     C                   eval      scddgt = icddg1
     C                   eval      scdadt = impdate
     C                   eval      scdatm = imptime
     C                   eval      scdaby = #user
     C                   Update    scdrec
650 AC                   else
650 aC                   unlock    slotdgt
650 AC                   endif
650 A*
650aMC                   endsl
     *
     *      Clear any values on file for 2nd, 3rd ck digits.
     C                   if        opcod# = 1
650aDC*    scdaky        chain     slotdgta
650aMC     scdaky        chain (e) slotdgta
650aAC                   select
650aAC                   when      %error
650aAC                   eval      detmsg = desc(9)
650aA*
650aMC                   when      %found(slotdgta)
     C     *nokey        clear                   scdreca
     C                   Update    scdreca
650aMC                   endsl
     C                   endif
     *
     *      Two check digit codes being used.
     C                   select
     C                   when      opcod# = 2
     *
650aDC*    scdaky        chain     slotdgta
650aMC     scdaky        chain (e) slotdgta
650aAC                   select
650aAC                   when      %error
650aAC                   eval      detmsg = desc(10)
650aA*
650aMC                   when      not %found(slotdgta)
650 AC                             and (icdtyp = 'A'
650 AC                               or icdtyp = 'C')
     C                   clear                   scdreca
     C                   eval      scdwhsa = icdwhs
     C                   eval      scdwhda = icdwhd
     C                   eval      scddspa = icddsp
     *
     C                   eval      scddgt2 = icddg2
     C                   eval      scdadt2 = impdate
     C                   eval      scdatm2 = imptime
     C                   eval      scdaby2 = #user
     *
     C                   eval      scddgt3 = 0
     C                   eval      scdadt3 = 0
     C                   eval      scdatm3 = 0
     C                   eval      scdaby3 = ' '
     C                   Write     scdreca
     *
650aMC                   other
     *
650 AC                   if        icdtyp = 'C'
     C                   eval      scddgt2 = icddg2
     C                   eval      scdadt2 = impdate
     C                   eval      scdatm2 = imptime
     C                   eval      scdaby2 = #user
     *
     C                   eval      scddgt3 = 0
     C                   eval      scdadt3 = 0
     C                   eval      scdatm3 = 0
     C                   eval      scdaby3 = ' '
     C                   Update    scdreca
650 AC                   else
650 aC                   unlock    slotdgta
650 AC                   endif
650 A*
650aMC                   endsl
     *
     *      Three check digit codes being used.
     C                   when      opcod# = 3
     *
650aDC*    scdaky        chain     slotdgta
650aMC     scdaky        chain (e) slotdgta
650aAC                   select
650aAC                   when      %error
650aAC                   eval      detmsg = desc(10)
650 A*
650aMC                   when      not %found(slotdgta)
650 AC                             and (icdtyp = 'A'
650 AC                               or icdtyp = 'C')
     C                   clear                   scdreca
     C                   eval      scdwhsa = icdwhs
     C                   eval      scdwhda = icdwhd
     C                   eval      scddspa = icddsp
     *
     C                   eval      scddgt2 = icddg2
     C                   eval      scdadt2 = impdate
     C                   eval      scdatm2 = imptime
     C                   eval      scdaby2 = #user
     *
     C                   eval      scddgt3 = icddg3
     C                   eval      scdadt3 = impdate
     C                   eval      scdatm3 = imptime
     C                   eval      scdaby3 = #user
     C                   Write     scdreca
     *
650aMC                   other
     *
650 AC                   if        icdtyp = 'C'
     C                   eval      scddgt2 = icddg2
     C                   eval      scdadt2 = impdate
     C                   eval      scdatm2 = imptime
     C                   eval      scdaby2 = #user
     *
     C                   eval      scddgt3 = icddg3
     C                   eval      scdadt3 = impdate
     C                   eval      scdatm3 = imptime
     C                   eval      scdaby3 = #user
     C                   Update    scdreca
650 AC                   else
650 aC                   unlock    slotdgta
650 AC                   endif
650 A*
650aMC                   endsl
     *
     C                   endsl
     *
     C     endupd        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  Compile Time Tables
     *
**
*Invalid warehouse
*Invalid department
*Slot display is blank
*Slot not on file
*Ck digit < zero
*Too many codes sent
*Max digits > 99
*Virtual slot not allowed
*SlotDgt rcd locked. No Update
*SlotDgtA rcd locked.No Update
