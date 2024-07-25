      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RTEDOOR    Dock door entry
     *  07 May 2014
     *  Dave Sommerville
     *
     *  NOTE:
     *      Based on DH122
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    05/07/14  DAS  6.50
     *      - Created
     *
650aA*    05/30/14  DAS  6.50a
     *      - Fix: Revised to use setll/read logic when clearing
     *        existing records.
     *
650bA*    05/30/14  DAS  6.50b
     *      - Revised to handle non-unique doors across departments
     *      - Revised to handle by department assignments
     *
650cA*    03/09/15  DAS  6.50c
     *      - Revised to get OPTIONS rec using pWhse instead of $pwhse.
     *
700aA*    06/07/16  DAS  7.00a
     *      - Added '(e)' to Write's so that we would drop into
     *        the %error logic instead of getting a hard duplicate
     *        key error.
     *
740  *    02/06/20  KDE  7.40
     *      - Revised to pass Route overrides for OPLTYP
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fdocmtrx   uf   e           k disk
     F                                     rename(dmrec:record)
     Fdocmtrx1  uf a e           k disk
     F                                     rename(dmrec:dmrec1)
     Fdocdoor   if   e           k disk
     Fdocmtrx2  if   e           k disk    prefix(dm2_)
     F                                     rename(dmrec:dmrec2)
     Fdochist   if   e           k disk
740 AFrtelm     if   e           k disk
416dAFoptions   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
510
     D assigned        s               n
     D currDoor        s              3  0
     D currDept        s              5
     D dkdoor          s              5
     D error           s               n
     D forevr          s               n
520 AD kyatyp          s                   like(dmatyp)
     D kypass          s                   like(dmpass)
     D                                     inz(*hival)
     D mxpass          s              5
     D rem             s              3  0 inz(0)
     D result          s              3  0 inz(0)
     D savpass         s                   like(dmpass)
740 Ad hldtyp          s              1
     D w1door          s              3  0
     D w1whdp          s              5
     D w1ovrf          s              1
     D w1ofdr          s              3  0
     D w1ofcb          s              7  2
     D w1rtec          s              7  2
     D $pwhse          s              3  0
     D $prtid          s              5
     D $phdte          s              8  0
     D $phtim          s              6  0
510
416dA*----------------------------------------------------------------
416dA*  *DOCDOOR -  Dock Door options
416dA*----------------------------------------------------------------
416dA*
416dA* Fields
416dA*
417 M*    OPATYP  -  Dock door assignment. 0=No assigment,1=Auto,2=Manual.
416dA*    OPLTYP  -  Dock door loading. 1=Single door, 2=By Department.
416dA*
416dA* Data structure
416dA*
416dAD opdata          ds
416dAD  opatyp                 1      1
416dAD  opltyp                 2      2

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')
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
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0
     D  $cvdr2               146    153
     D  $cvvl2               154    158  0
     D  $cvdr3               159    166
     D  $cvvl3               167    171  0
     D  $cvdr4               172    179
     D  $cvvl4               180    184  0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pWhse          s              3  0
     D  pRtid          s              5
     D  pDoor          s              3  0
     D  pDept          s              5

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pWhse       Warehouse
     *      pRtid       Route id
     *      pDoor       Door
     *      pDept       Department
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pWhse
     C                   parm                    pRtid
     C                   parm                    pDoor
     C                   parm                    pDept

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMessage = '';
        error = *off;

        exsr zzinz;
650bA   exsr zzinz2;

        // Door cannot be zero

        if pDoor = 0;
          pMessage = 'Door cannot be zero';
          return;
        endif;

        // Get current matrix date/time

        exsr GetMatrixDate;
        if error;
          return;
        endif;

        // Get existing door, if any

        exsr GetDoor;

        // If nothing has changed, then get out.

650bD   //if currDoor = pDoor
650bM   if (opltyp = '1' and currDoor = pDoor)
650bA     or (currDoor = pDoor and currDept = pDept);
            return;
        endif;

        // Verify door is active

        exsr ChkActive;
        if error;
          return;
        endif;

        // Update using ZH122 routines

        $pwhse = pWhse;
        $prtid = pRtid;
        $phdte = dhhdte;
        $phtim = dhhtim;
        w1door = pDoor;
650bA   if opltyp = '1';
          w1whdp = ddwhdp;
650bA   else;
650bA     w1whdp = pDept;
650bA   endif;
        w1ovrf = 'N';
        w1ofdr = 0;
        w1ofcb = 0;
        w1rtec = 0;

        exsr zzupd;

        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkActive   Check if door is active
     *----------------------------------------------------------------

      /free
       begsr ChkActive;

740 D    //if opltyp = '1';
740 M    if opltyp = '1' and hldtyp<>'2';
           setll (pWhse: pDoor) docdoor;
           reade (pWhse: pDoor) docdoor;
650bA    else;
650bA      setll (pWhse: pDoor: pDept) docdoor;
650bA      reade (pWhse: pDoor: pDept) docdoor;
650bA    endif;

         if %eof(docdoor);
           error = *on;
           pMessage = 'Door ' + %char(pDoor) + ' not found '
                    + 'in DOCDOOR file';
           return;
         endif;

         // Error if door is not active

         if ddstat <> 'A';
           error = *on;
           pMessage = 'Door ' + %char(pDoor) + ' not active';
           return;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetDoor     Get current door, if any
     *----------------------------------------------------------------

      /free
       begsr GetDoor;

         assigned = *off;
         currDoor = 0;
         currDept = '';

650bA    if opltyp = '1';
           setll (pWhse: pRtId) docmtrx2;
           reade (pWhse: pRtId) docmtrx2;
650bA    else;
650bA      setll (pWhse: pRtId: pDept) docmtrx2;
650bA      reade (pWhse: pRtId: pDept) docmtrx2;
650bA    endif;

         if not %eof(docmtrx2);
           assigned = *on;
           currDoor = dm2_dmdoor;
           currDept = dm2_dmwhdp;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetMatrixDate  Get Matrix date
     *----------------------------------------------------------------

      /free
       begsr GetMatrixDate;

         setgt (pWhse) dochist;
         readpe (pWhse) dochist;
         if %eof(dochist);
           error = *on;
           pMessage = 'Dock door matrix date/time '
                    + 'not found in DOCHIST file';
           return;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     ZZINZ         BEGSR
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    dm2_dmwhse
     C                   kfld                    dm2_dmhdte
     C                   kfld                    dm2_dmhtim
520 AC                   kfld                    dm2_dmatyp
     C                   kfld                    dm2_dmpass
     C                   kfld                    dm2_dmdoor
     C                   kfld                    dm2_dmwhdp
     *
     *  Define key for main file.
     *
     C     oflkey        klist
     C                   kfld                    dm2_dmwhse
     C                   kfld                    dm2_dmhdte
     C                   kfld                    dm2_dmhtim
520 AC                   kfld                    dm2_dmatyp
     C                   kfld                    dm2_dmpass
     C                   kfld                    w1ofdr
     C                   kfld                    w1whdp
650aA*
650aA*  Define partial history date key for main file
650aA*
650aAC     dateky        klist
650aAC                   kfld                    dm2_dmwhse
650aAC                   kfld                    dm2_dmhdte
650aAC                   kfld                    dm2_dmhtim
     *
     *  Define key for DOCMTRX1 file - Partial key.
     *
     C     kydm1         klist
     C                   kfld                    $pwhse
     C                   kfld                    $phdte
     C                   kfld                    $phtim
520 AC                   kfld                    kyatyp
     C                   kfld                    w1whdp
     C                   kfld                    kypass
     C                   kfld                    w1door
     *
     *  Define key for DOCMTRX1 file - Partial key.
     *
     C     kydm1a        klist
     C                   kfld                    $pwhse
     C                   kfld                    $phdte
     C                   kfld                    $phtim
520 AC                   kfld                    kyatyp
     C                   kfld                    w1whdp
     *
     *  Define key for DOCMTRX1 file - Partial key.
     *
     C     kydm1b        klist
     C                   kfld                    $pwhse
     C                   kfld                    $phdte
     C                   kfld                    $phtim
520 AC                   kfld                    kyatyp
     C                   kfld                    w1whdp
     C                   kfld                    dmpass
     C                   kfld                    w1door
     *
     *  Define key for OPTIONS file. - Full
     *
     C     keyop         KLIST
650cDC**                 KFLD                    $pwhse
650cMC                   KFLD                    pWhse
     C                   KFLD                    opcode
     *
     C                   eval      forevr = *on
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     ZZINZ2        BEGSR
     *
     *  Get Dock Door Options.
     *
     C                   eval      opcode = '*DOCDOOR'
     C     keyop         chain     Options

      /free
740 A    chain (pWhse:pRtid) rtelm;
740 A    if %found(rtelm);
740 A      hldtyp = opltyp;
740 A      opltyp = rltype;
740 A    endif;
      /end-free
     *
     *    If options record not found:
     *      Default to auto assign dock doors &
     *      use single door for loading route.
     *
     C                   if        not %found(options)
740 AC                   eval      hldtyp = '1'
     C                   eval      opatyp = '1'
     C                   eval      opltyp = '1'
     C                   endif

     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCKDR   Check if this is odd/even dock door.
     *----------------------------------------------------------------
     *
     C     ZZCKDR        BEGSR
     *
     C     w1door        div       2             result
     C                   mvr                     rem
     *
     C                   if        rem > 0
     C                   eval      dkdoor = '*ODD '
     C                   else
     C                   eval      dkdoor = '*EVEN'
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCKPS   Check if this is odd/even dock door assignment pass.
     *----------------------------------------------------------------
     *
     C     ZZCKPS        BEGSR
     *
     C     dmpass        div       2             result
     C                   mvr                     rem
     *
     C                   if        rem > 0
     C                   eval      mxpass = '*ODD '
     C                   else
     C                   eval      mxpass = '*EVEN'
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZDRADD  Add new pass / dock door.
     *----------------------------------------------------------------

     C     ZZDRADD       BEGSR
520 A*
520 A*      Increment matrix pass if zero.
520 AC                   if        dmpass = 0
520 AC                   eval      dmpass = dmpass + 1
520 AC                   endif
520 A*
     C                   exsr      zzckps
     C                   exsr      zzckdr
     C***********        exsr      zzgtdr
     *
     *    Dock matrix pass and dock door not both even/odd.
     *    Increment pass to match door selected by user.
     C                   if        mxpass <> dkdoor or
     C                             mxpass = dkdoor and (dmstat = '2' or
     C                             dmstat = '4')
     C                   eval      dmpass = dmpass + 1
     C                   exsr      zzckps
     C                   if        mxpass <> dkdoor
     C                   eval      dmpass = dmpass + 1
     C                   endif
     C                   endif
     *
520 AC                   eval      dmwhse = $pwhse
520 AC                   eval      dmhdte = $phdte
520 AC                   eval      dmhtim = $phtim
520 AC                   eval      dmwhdp = w1whdp
520 A*
     C                   eval      dmdoor = w1door
     C                   eval      dmrtid = $prtid
     C                   eval      dmmaxc = ddmaxc
     C                   eval      dmrtec = w1rtec + w1ofcb
     C                   eval      dmstat = '2'
     C                   eval      dmovrf = 'N'
     C                   eval      dmskpr = ' '
520 MC                   eval      dmatyp = kyatyp
     C                   eval      dmaby  = #user
     C                   eval      $cvcmd = '*CURCMD '
     *    Retrieve current date.
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      dmadte = $cvd8o
     C                   time                    dmatim
700aDC**                 write     dmrec1
700aMC                   write(e)  dmrec1
     *
     C                   if        %error
     C                   eval      error = *on
     C                   eval      pMessage = 'Error writing record '
     C                             + '(zzdradd/'
     C                             + %char(dmhdte) + '/'
     C                             + %char(dmhtim) + '/'
     C                             + %trim(dmatyp) + '/'
     C                             + %char(dmpass) + '/'
     C                             + %char(dmdoor) + '/'
     C                             + %trim(dmwhdp) + '/'
     C                             + %trim(dmrtid) + ')'
     C                   endif
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZDRUPD  Update pass / dock door info.
     *----------------------------------------------------------------

     C     ZZDRUPD       BEGSR
     *
     C                   exsr      zzckps
     C                   exsr      zzckdr
     *
     *    Dock matrix pass and dock door not both even/odd.
     *    Increment pass to match door selected by user.
     C                   if        mxpass <> dkdoor
     C                   eval      dmpass = dmpass + 1
     C                   endif
     *
     C                   eval      dmdoor = w1door
     C                   eval      dmrtid = $prtid
     C                   eval      dmrtec = w1rtec + w1ofcb
     C                   eval      dmstat = '2'
     C                   eval      dmovrf = 'N'
     C                   eval      dmskpr = ' '
520 DC*                  eval      dmatyp = 'M'
520 MC                   eval      dmatyp = kyatyp
     C                   eval      dmaby  = #user
     C                   eval      $cvcmd = '*CURCMD '
     *    Retrieve current date.
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      dmadte = $cvd8o
     C                   time                    dmatim
     *
     *    Dock matrix pass and dock door not both even/odd.
     *    Add record to match door selected by user.
     C                   if        mxpass <> dkdoor
700aDC**                 write     dmrec1
700aMC                   write(e)  dmrec1
     C                   else
700aDC**                 update    dmrec1
700aMC                   update(e) dmrec1
     C                   endif
     *
     C                   if        %error
     C                   eval      error = *on
     C                   if        mxpass <> dkdoor
     C                   eval      pMessage = 'Error writing record '
     C                   else
     C                   eval      pMessage = 'Error updating record '
     C                   endif
     C                   eval      pMessage = %trimr(pMessage) + ' '
     C                             + '(zzdrupd/'
     C                             + %char(dmhdte) + '/'
     C                             + %char(dmhtim) + '/'
     C                             + %trim(dmatyp) + '/'
     C                             + %char(dmpass) + '/'
     C                             + %char(dmdoor) + '/'
     C                             + %trim(dmwhdp) + '/'
     C                             + %trim(dmrtid) + ')'
     C                   endif
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZUPD    Update record.
     *----------------------------------------------------------------

     C     ZZUPD         BEGSR

     *    Remove route from existing matrix records

     C                   if        assigned

650aAC**   fileky        chain     docmtrx
650aAC**                 if        %found(docmtrx) and dmstat = '2'
650aAC**                 eval      dmrtid = *blanks
650aAC**                 eval      dmrtec = *zeros
520 DC*                  eval      dmstat = '3'
650aAC**                 eval      dmstat = '1'
650aAC**                 eval      dmovrf = 'N'
520 DC*                  eval      dmskpr = '7'
650aAC**                 eval      dmskpr = ' '
520 DC*                  eval      dmatyp = 'M'
650aAC**                 eval      dmaby = *blanks
650aAC**                 eval      dmadte = *zeros
650aDC**                 eval      dmatim = *zeros
650aDC**                 update    record
650aDC**                 endif
650aD **
650aD **   Remove route from overflow door if one assigned.
650aD **
650aDC**                 if        w1ovrf = 'Y'
650aD **
650aDC**   oflkey        chain     docmtrx
650aDC**                 if        %found(docmtrx) and dmstat = '2'
650aDC**                 eval      dmrtid = *blanks
650aDC**                 eval      dmrtec = *zeros
520 DC*                  eval      dmstat = '3'
650aDC**                 eval      dmstat = '1'
650aDC**                 eval      dmovrf = 'N'
520 DC*                  eval      dmskpr = '7'
650aDC**                 eval      dmskpr = '7'
520 DC*                  eval      dmatyp = 'M'
650aDC**                 eval      dmaby = *blanks
650aDC**                 eval      dmadte = *zeros
650aDC**                 eval      dmatim = *zeros
650aDC**                 update    record
650aDC**                 endif
650aDC**                 endif
650aA*
650aA*    Clear existing records
650aA*
650aAC     dateky        setll     docmtrx
650aAC                   dow       forevr = forevr
650aA*
650aAC     dateky        reade     docmtrx
650aAC                   if        %eof(docmtrx)
650aAC                   leave
650aAC                   endif
650aA*
650aA*      Only look for records that are ...
650aA*        - Same route id
650aA*        - Active
650aA*        - Same department if loading is by department
650aA*
650aAC                   if        dmrtid <> prtid
650aAC                             or dmstat <> '2'
650aAC                             or (opltyp = '2' and dmwhdp <> w1whdp)
650aAC                   iter
650aAC                   endif
650aA*
650aA*      Clear record
650aA*
650aAC                   eval      dmrtid = ' '
650aAC                   eval      dmrtec = 0
650aAC                   eval      dmstat = '1'
650aAC                   eval      dmovrf = 'N'
650aAC                   eval      dmskpr = ' '
650aAC                   eval      dmaby = ' '
650aAC                   eval      dmadte = 0
650aAC                   eval      dmatim = 0
650aAC                   update    record
650aA*
650aAC                   enddo

     C                   endif
     *
     *    Find last pass.  See if dock door is available.
     *
520 A*    Force assignment type to manual for add and update.
520 AC                   eval      kyatyp = 'M'
     C     kydm1         setgt     docmtrx1
     C     kydm1a        readpe    docmtrx1
416aAC                   if        %eof
416aAC                   eval      savpass = *hival
416aAC                   else
416aAC                   eval      savpass = dmpass
416aAC                   endif
     C     kydm1b        setgt     docmtrx1
     C     kydm1a        readpe    docmtrx1
416aA*
416aA*    Pass read is less than previous pass. Get very last pass.
416aAC                   if        dmpass < savpass
416aAC     kydm1         setgt     docmtrx1
416aAC     kydm1a        readpe    docmtrx1
416aAC                   endif
     C                   select
     *
     *    Pass found and door ok to use.
     C                   when      not %eof and
     C                             (dmstat = '1' or dmstat = '3') and
     C                             w1door = dmdoor
     C                   exsr      zzdrupd
     *
     *    Pass not found or door at wrong status. Create new pass
     *    update door with new info.
     C                   when      %eof or
     C                             not %eof and (dmstat = '2' or dmstat = '4')
     C                             or not %eof and (dmstat = '1' or dmstat = '3'
     C                             and (w1door <> dmdoor))
     C                   exsr      zzdradd
     *
     C                   endsl
510bA*
510bAC                   unlock    docmtrx
510bAC                   unlock    docmtrx1
     *
     C     endupd        ENDSR
