      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  DH140     Dock Matrix - Route assign from DOCROUTE
     *  28 July 2015
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700  *    07/28/15  RTR  7.00
     *      - Created from DH122.
     *
730a *    07/31/19  RTR  7.30a
     *      - Fix: If matrix already full, don't try to add record.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fdocdoor   if   e           k disk
     Fdocmtrx   uf   e           k disk
     F                                     rename(dmrec:record)
     Fdocmtrx1  uf a e           k disk
     F                                     rename(dmrec:dmrec1)
     Fdocmtrx2  if   e           k disk
     F                                     rename(dmrec:dmrec2)
     Foptions   if   e           k disk
     Frtehed    if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a10             s              1    dim(10)
     D desc            s             20    dim(2) ctdata perrcd(1)
     D dmxsts          s             30    dim(4) ctdata perrcd(1)
     D skpdsc          s             50    dim(7) ctdata perrcd(1)
     D dckasn          s             10    dim(2) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  *DOCDOOR -  Dock Door options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPATYP  -  Dock door assignment. 1=Auto, 2=Manual.
     *    OPLTYP  -  Dock door loading. 1=Single door, 2=By Department.
     *
     * Data structure
     *
     D OPDATA          DS
     D  OPATYP                 1      1
     D  OPLTYP                 2      2

     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $phdte                22     29  0
     D  $phtim                30     35  0
     D  $ppass                36     38  0
     D  $pdoor                39     41  0
     D  $pwhdp                42     46
     D  $prtid                47     51
     D  $prtec                52     56P 3
     D  $patyp                57     57
     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

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
     D  $ldoor                27     29  0
     *
     D  $lhdte                22     29  0
     D  $lhtim                30     35  0
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
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D dkdoor          s              5
     D drasn           s              4    inz('    ')
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D fillscreen      s              3
     D forevr          s               n
     D help            s              5  0
     D kyatyp          s                   like(dmatyp)
     D kypass          s                   like(dmpass)
     D                                     inz(*hival)
     D msgk            s              4  0
     D mxpass          s              5
     D nxtscr          s              3
     D pndoor          s              3a
     D prte            s              5a
     D prtid           s              5a
     D pwhsa           s              3a
     D rem             s              3  0 inz(0)
     D result          s              3  0 inz(0)
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D savpass         s                   like(dmpass)
     D svpass          s                   like(dmpass)
     D svrtid          s                   like(dmrtid)
     D svwhdp          s                   like(dmwhdp)
     D warn            s              1
     D wkdoor          s              3  0
     D wkovrf          s              1a
     D wkofcb          s              9  3
     D wkofdr          s              3  0
     D wkrtec          s              9  3
     D wkwhdp          s              5a

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

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
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pwhsa
     C                   parm                    prtid
     C                   parm                    prte
     C                   parm                    pndoor

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
      /free

        exsr zzinz2;

        // get route doors from file
        exsr zzget;

        // write door to matrix
        exsr zzupd;

        if wkdoor > 0;
          pndoor = %editc(wkdoor:'X');
        else;
          pndoor = *blanks;
        endif;

        *inlr = *on;
        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *INZSR        BEGSR
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZGET    Get record(s) from route/door file.
     *----------------------------------------------------------------
      /free
        begsr zzget;

          exec sql declare rtecsr cursor for
            select drwhdp, drdoor from docroute
             where drrte = :prte;
          exec sql open rtecsr;
          if sqlstt <> sqlSuccess;
            wkwhdp = *blanks;
            wkdoor = 0;
            leavesr;
          endif;

          exec sql fetch next from rtecsr
                    into :wkwhdp,:wkdoor;
          dou sqlstt <> sqlSuccess;

            // write door to matrix
            exsr zzupd;

            exec sql fetch next from rtecsr
                      into :wkwhdp,:wkdoor;
          enddo;

          exec sql close rtecsr;
        endsr;  // zzget
      /end-free

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     ZZINZ         BEGSR
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $phdte
     C                   kfld                    $phtim
     C                   kfld                    $patyp
     C                   kfld                    $ppass
     C                   kfld                    $pdoor
     C                   kfld                    $pwhdp
     *
     *  Define key for main file.
     *
     C     oflkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $phdte
     C                   kfld                    $phtim
     C                   kfld                    $patyp
     C                   kfld                    $ppass
     C                   kfld                    wkofdr
     C                   kfld                    wkwhdp
     *
     *  Define key for DOCDOOR file - Full key.
     *
     C     keydd         klist
     C                   kfld                    $pwhse
     C                   kfld                    wkdoor
     C                   kfld                    wkwhdp
     *
     *  Define key for DOCMTRX1 file - Partial key.
     *
     C     kydm1         klist
     C                   kfld                    $pwhse
     C                   kfld                    $phdte
     C                   kfld                    $phtim
     C                   kfld                    kyatyp
     C                   kfld                    wkwhdp
     C                   kfld                    kypass
     C                   kfld                    wkdoor
     *
     *  Define key for DOCMTRX1 file - Partial key.
     *
     C     kydm1a        klist
     C                   kfld                    $pwhse
     C                   kfld                    $phdte
     C                   kfld                    $phtim
     C                   kfld                    kyatyp
     C                   kfld                    wkwhdp
     *
     *  Define key for DOCMTRX1 file - Partial key.
     *
     C     kydm1b        klist
     C                   kfld                    $pwhse
     C                   kfld                    $phdte
     C                   kfld                    $phtim
     C                   kfld                    kyatyp
     C                   kfld                    wkwhdp
     C                   kfld                    dmpass
     C                   kfld                    wkdoor
     *
     *  Define key for DOCMTRX2 - Partial
     *
     C     kydm2         klist
     C                   kfld                    $pwhse
     C                   kfld                    dmrtid
     C                   kfld                    dmwhdp
     C                   kfld                    dmdoor
     *
     *  Define key for DOCMTRX2 - Partial
     *
     C     kydm2a        klist
     C                   kfld                    $pwhse
     C                   kfld                    dmrtid
     C                   kfld                    dmwhdp
     *
     *  Define key for OPTIONS file. - Full
     *
     C     keyop         KLIST
     C                   KFLD                    $pwhse
     C                   KFLD                    opcode
     *
     *  Define key for RTEHED file.
     *
     C     rhkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     C                   eval      forevr = *on
     C                   eval      $lprg = #prog
     *
      /free
        // reset initial parms
        error = *off;
        clear $parms;
        monitor;
          $pwhse = %dec(pwhsa:3:0);
        on-error;
          $pwhse = 1;
        endmon;
        $prtid = prtid;
      /end-free
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
     *
     *    If options record not found:
     *      Default to auto assign dock doors &
     *      use single door for loading route.
     *
     C                   if        not %found(options)
     C                   eval      opatyp = '1'
     C                   eval      opltyp = '1'
     C                   endif
     *
     *   Set flag if route already assigned to dock door.
     *
     C     fileky        setll     docmtrx
     C                   if        %equal
     C                   eval      drasn  = '*YES'
     *
     C                   else
     *
     C                   eval      drasn  = '*NO '
     *
     *    Retrieve last dock matrix history record.
     C                   eval      $lprg = #prog
     C                   eval      $luky  = $puky
     C                   call      'DH910'
     C                   parm                    $lparm
     C                   if        $lrtn = '*OK     '
     C                   eval      $phdte = $lhdte
     C                   eval      $phtim = $lhtim
     C                   endif
     *
     C                   endif
     *
     *   Select first screen to display.
     *
     C                   eval      $pwhdp = *blanks
     C                   eval      $pdoor = 0
     C                   eval      $ppass = 1
     C                   eval      $prtec = 0
     C     kydm1         setgt     docmtrx1
     C     kydm1a        readpe(n) docmtrx1
     C                   if        not %eof(docmtrx1)
     C                   eval      $ppass = dmpass
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCKDR   Check if this is odd/even dock door.
     *----------------------------------------------------------------
     *
     C     ZZCKDR        BEGSR
     *
     C     wkdoor        div       2             result
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
     *  ZZCVTDT  Convert date.
     *----------------------------------------------------------------

     C     ZZCVTDT       BEGSR
     *
     *    Retrieve current date.
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      dmadte = $cvd8o
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZDRADD  Add new pass / dock door.
     *----------------------------------------------------------------

     C     ZZDRADD       BEGSR
     *
     *      Increment matrix pass if zero.
     C                   if        dmpass = 0
     C                   eval      dmpass = dmpass + 1
     C                   endif
     *
     C                   exsr      zzckps
     C                   exsr      zzckdr
     C                   exsr      zzgtdr
730aA
730aA*      If matrix is already full, don't add.
730aAC                   if        dmpass = 999
730aAC                   leavesr
730aAC                   endif
     *
     *    Dock matrix pass and dock door not both even/odd.
     *    Increment pass to match door selected by user.
     C                   if        mxpass <> dkdoor or
     C                             mxpass = dkdoor and (dmstat = '2' or
     C                             dmstat = '4')
     C                   eval      dmpass = dmpass + 1
     C                   exsr      zzckps
730aA
730aA*      If matrix is already full, don't add.
730aAC                   if        dmpass = 999
730aAC                   leavesr
730aAC                   endif
     C                   if        mxpass <> dkdoor
     C                   eval      dmpass = dmpass + 1
     C                   endif
     C                   endif
     *
     C                   eval      dmwhse = $pwhse
     C                   eval      dmhdte = $phdte
     C                   eval      dmhtim = $phtim
     C                   eval      dmwhdp = wkwhdp
     *
     C                   eval      dmdoor = wkdoor
     C                   eval      dmrtid = $prtid
     C                   eval      dmmaxc = ddmaxc
     C                   eval      dmrtec = wkrtec + wkofcb
     C                   eval      dmstat = '2'
     C                   eval      dmovrf = 'N'
     C                   eval      dmskpr = ' '
     C                   eval      dmatyp = kyatyp
     C                   eval      dmaby  = #user
     C                   eval      $cvcmd = '*CURCMD '
     *    Retrieve current date.
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      dmadte = $cvd8o
     C                   time                    dmatim
     C                   write     dmrec1
     *
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
     C                   eval      dmdoor = wkdoor
     C                   eval      dmrtid = $prtid
     C                   eval      dmrtec = wkrtec + wkofcb
     C                   eval      dmstat = '2'
     C                   eval      dmovrf = 'N'
     C                   eval      dmskpr = ' '
     C                   eval      dmatyp = kyatyp
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
     C                   write     dmrec1
     C                   else
     C                   update    dmrec1
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZGTDR  Get dock door master.
     *----------------------------------------------------------------

     C     ZZGTDR        BEGSR
     *
     C     keydd         chain     docdoor
     C                   if        not %found
     C                   eval      ddmaxc = 0
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZOVFL  Look for overflow dock door, if any.
     *----------------------------------------------------------------

     C     ZZOVFL        BEGSR
     *
     C                   eval      *in41 = *off
     C                   eval      wkovrf  = 'N'
     *
     *    Save values for this door.
     *
     C                   eval      svpass = dmpass
     C                   eval      svwhdp = dmwhdp
     C                   eval      svrtid = dmrtid
     *
     *    Look for overflow for this route.
     C     kydm2         setgt     docmtrx2
     C     kydm2a        reade     docmtrx2
     *
     C                   if        not %eof  and dmpass = svpass and
     C                             dmrtid = svrtid and dmwhdp = svwhdp and
     C                             dmovrf = 'Y'
     *
     *    Door overflow found. Send back door# and overflow cube amt.
     C                   eval      wkovrf  = dmovrf
     C                   eval      wkofdr  = dmdoor
     C                   eval      wkofcb  = dmrtec
     C                   eval      *in41   = *on
     *
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZUPD    Update record.
     *----------------------------------------------------------------

     C     ZZUPD         BEGSR
     *
     C                   eval      error = *off
     *
     C                   select
     *
     *    No changes. Release record lock.
     C                   when      $pwhdp = Wkwhdp and
     C                             $pdoor = Wkdoor
     C                   unlock    docmtrx
     C                   unlock    docmtrx1
     *
     *    Door changes. Update dock matrix.
     C                   other
     *
     C                   select
     *
     *    Dock department or dock door changed.
     C                   when      ($pwhdp <> Wkwhdp or
     C                             $pdoor <> Wkdoor) and drasn  = '*YES'
     *
     *    Remove route from current door.
     C     fileky        chain     docmtrx
     C                   if        %found(docmtrx) and dmstat = '2'
     C                   eval      dmrtid = *blanks
     C                   eval      dmrtec = *zeros
     C                   eval      dmstat = '1'
     C                   eval      dmovrf = 'N'
     C                   eval      dmskpr = ' '
     C                   eval      dmaby = *blanks
     C                   eval      dmadte = *zeros
     C                   eval      dmatim = *zeros
     C                   update    record
     C                   endif
     *
     *    Remove route from overflow door if one assigned.
     *
     C                   if        wkovrf = 'Y'
     *
     C     oflkey        chain     docmtrx
     C                   if        %found(docmtrx) and dmstat = '2'
     C                   eval      dmrtid = *blanks
     C                   eval      dmrtec = *zeros
     C                   eval      dmstat = '1'
     C                   eval      dmovrf = 'N'
     C                   eval      dmskpr = '7'
     C                   eval      dmaby = *blanks
     C                   eval      dmadte = *zeros
     C                   eval      dmatim = *zeros
     C                   update    record
     C                   endif
     C                   endif
     C                   endsl
     *
     *    Find last pass.  See if dock door is available.
     *
     *    Force assignment type to manual for add and update.
     C                   eval      kyatyp = 'M'
     C     kydm1         setgt     docmtrx1
     C     kydm1a        readpe    docmtrx1
     C                   if        %eof
     C                   eval      savpass = *hival
     C                   else
     C                   eval      savpass = dmpass
     C                   endif
     C     kydm1b        setgt     docmtrx1
     C     kydm1a        readpe    docmtrx1
     *
     *    Pass read is less than previous pass. Get very last pass.
     C                   if        dmpass < savpass
     C     kydm1         setgt     docmtrx1
     C     kydm1a        readpe    docmtrx1
     C                   endif
     C                   select
     *
     *    Pass found and door ok to use.
     C                   when      not %eof and
     C                             (dmstat = '1' or dmstat = '3') and
     C                             wkdoor = dmdoor
     C                   exsr      zzdrupd
     *
     *    Pass not found or door at wrong status. Create new pass
     *    update door with new info.
     C                   when      %eof or
     C                             not %eof and (dmstat = '2' or dmstat = '4')
     C                             or not %eof and (dmstat = '1' or dmstat = '3'
     C                             and (wkdoor <> dmdoor))
     C                   exsr      zzdradd
     *
     C                   endsl
     *
     C                   unlock    docmtrx
     C                   unlock    docmtrx1
     *
     *   Move key values to parameters
     *
     C                   eval      $pwhdp = wkwhdp
     C                   eval      $pdoor = wkdoor
     *
     C                   endsl
     *
     C     endupd        ENDSR

     *----------------------------------------------------------------*********
     *  COMPILE TIME TABLES
     *----------------------------------------------------------------*********
**
Dock Door
Status
** Dock matrix status
Open
Assigned
Skipped
Inactive
** Dock matrix skip reasons
Skipped - Pass mismatch
Skipped - Door used on previous pass
Skipped - Cube overflow. Next door not available
New pass created manually
Route manually removed
Route forced. No doors avail. during auto assign.
Route moved manually by user.
** Dock matrix assignment types
Automatic
Manual
