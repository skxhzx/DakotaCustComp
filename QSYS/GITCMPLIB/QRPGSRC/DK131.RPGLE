     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2009')
     H Option(*NODEBUGIO)

     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DK131     Assign route to Host Assigned Dock Door
     *  25 January 2006
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    01/25/06  MLB  5.00
     *      - Created.
     *
520 A*    09/22/09  MLB  5.20
     *      - Enh: Added Assignment Type to dock matrix file key to
     *        keep automatic assigned doors separate from manually
     *        assigned doors. This was done so that the next
     *        dock door to be assigned in the automatic sequence
     *        will always be correct even when a route is moved
     *        from one door to another.  Dooors assigned by this
     *        program will be treated as manually assigned doors.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  50        Array element look up found
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fdocmtrx   uf   e           k disk
     Fdocmtrx1  uf   e           k disk
     F                                     rename(dmrec:dmrec1)
     Fdochist   uf a e           k disk
     Foptions   if   e           k disk
     Frtecsum   if   e           k disk
     Frtecsum1  if   e           k disk
     F                                     rename(rcrec:rcrec1)
     Frtehed    if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D DDR             S              5    DIM(50)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D cubleft         s                   like(dmrtec)
     D                                     inz(0)
     D clctot          s              4    inz('*NO ')
     D clrtot          s              4    inz('*NO ')
     D curdate         s              8  0
     D curpass         s              3  0
     D curtime         s              6  0
     D dkdoor          s              5
     D forevr          s              1    inz('1')
     D k               s              3  0 inz(1)
520 AD kyatyp          s                   like(dmatyp)
520 AD                                     inz('M')
     D kydoor          s                   like(dmdoor)
     D kydrdp          s                   like(rcdrdp)
     D kyhdte          s                   like(dhhdte)
     D                                     inz(*hival)
     D kyhtim          s                   like(dhhtim)
     D                                     inz(*hival)
     D kywhdp          s                   like(dmwhdp)
     D lstdoor         s                   like(dmdoor)
     D lstpass         s                   like(dmpass)
     D lstwhdp         s                   like(dmwhdp)
     D $ptyp           s              1
     D mxpass          s              5
     D nohist          s              1    inz('0')
     D nopass          s              1    inz('0')
     D $pass           s              3  0
     D passblt         s              3  0 inz(0)
     D rem             s              3  0 inz(0)
     D result          s              3  0 inz(0)
     D svdrdp          s                   like(rcdrdp)
     D totcube         s                   like(dmrtec)
     D                                     inz(0)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   CONST('CVTDTE')
     D @clcdr          c                   CONST('CLCDUR')

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

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D    $lcmd                1      8
     D    $lprg                9     18
     D    $luky               19     68
     D    $lrtn               69     76
     D    $lerm               77    136
     D    $lmsg               77     80

     *   Redefine key

     D    $lwhse              19     21  0
     D    $lhdte              22     29  0
     D    $lhtim              30     35  0
     D    $lpass              36     38  0
     D    $ldoor              39     41  0
     D    $lrte               42     46
     D    $lrtid              47     51
     D    $lcube              52     56P 3
     D    $lwhdp              57     61
     D    $lltyp              62     62
520 AD    $latyp              63     63

     *----------------------------------------------------------------
     *  *DOCDOOR -  Dock Door options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPATYP  -  Dock door assignment. 0=No assigment, 1=Auto, 2=Manual.
     *    OPLTYP  -  Dock door loading. 1=Single door, 2=By Department.
     *
     * Data structure
     *
     D OPDATA          DS
     D  OPATYP                 1      1
     D  OPLTYP                 2      2

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
     *  Renamed fields - Route Compartment Summary - Logical
     *----------------------------------------------------------------
     IRCREC1
     I              RCWHSE                      R1WHSE
     I              RCRTID                      R1RTID
     I              RCCOMP                      R1COMP
     I              RCDRDP                      R1DRDP
     I              RCPCKC                      R1PCKC
     I              RCPCKW                      R1PCKW
     I              RCPCKP                      R1PCKP
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $parms
     *        $pwhse - Warehouse number
     *        $phdte - Pick date for route being assigned to door.
     *        $phtim - Pick time for route being assigned to door.
     *        $ppass - Dock door pass. Always 0.
     *        $pwhdp - Dock door dept. Always blank.
     *        $prtid - Route id
     *        $prtec - Total cube for route
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C                   select
     C     $pcmd         wheneq    '*NEWDOOR'
     *
     C                   exsr      zzinz2
     *
     C                   select
     *
     *   Dock doors are assigned automatically.
     C     opatyp        wheneq    '1'
     *
     C                   exsr      zztotal
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   eval      *inlr = *on
     *

     *----------------------------------------------------------------
     *          Subroutines in Alphabetical Order
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
     *
     C     *INZSR        BEGSR
     *
     *   Call user added initialization routine.
     *
     C                   exsr      ZZINZ
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZASN1   Assign entire route to single door.
     *----------------------------------------------------------------
     *
     C     ZZASN1        BEGSR
     *
     C                   eval      cubleft = totcube
     C                   eval      curpass = 0
     C                   eval      passblt = 0
     *
     *    Retrieve newest dock door history file record.
     C                   eval      nohist = *off
     C                   exsr      zzgtdh
     *
     *    If no record was found for this warehouse, then
     *    create a new dock door history record and call
     *    program to create new dock door matrix.
     C                   if        nohist = *on
     C                   exsr      zznwdh
     *    Retrieve new dock door history record.
     C                   eval      nohist = *off
     C                   exsr      zzgtdh
     C                   endif
     *
     C                   eval      curpass = dmpass
     *
     C     dmkey         setll     docmtrx
     C                   dow       cubleft >  0
     *
     C     dmkey         reade     docmtrx
     C                   select
     *
     *      Exit loop if unable to assign door and max. passes reached.
     C                   when      %eof(docmtrx) and curpass = 999
     C                   leave
     *
     C                   when      %eof(docmtrx)
     *
     *    No matrix records found - Create new set.
     C                   eval      curpass = curpass + 1
     C                   exsr      zznwdm
     C                   exsr      zzgtdm
     C                   endsl
     *
     C                   select
     *    Door is Unavailable, skip pass and go to next one.
     C                   when      $pdoor = dmdoor and dmstat >= '2'
     C                             or $pdoor <> dmdoor
     C                   iter
     *
     *    Process active / available door.
     C                   when      $pdoor = dmdoor and dmstat = '1'
     *
     *    Door available, force route to this door.
     C                   eval      $lrtn = '*DRAVAIL'
     C                   exsr      zzfill
     C                   exsr      zzupdm
     C                   endsl
     *
     C                   enddo
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZASN2   Assign doors for this route - By Department.
     *----------------------------------------------------------------
     *
     C     ZZASN2        BEGSR
     *
     C                   eval      cubleft = totcube
     C                   eval      curpass = 0
     C                   eval      passblt = 0
     *
     *    Retrieve newest dock door history file record.
     C                   eval      nohist = *off
     C                   exsr      zzgtdh
     *
     *    If no record was found for this warehouse, then
     *    create a new dock door history record and call
     *    program to create new dock door matrix.
     C                   if        nohist = *on
     C                   exsr      zznwdh
     *    Retrieve new dock door history record.
     C                   eval      nohist = *off
     C                   exsr      zzgtdh
     C                   endif
     *
     *    Get last dock door matrix record for department.
     C                   eval      nopass = *off
     C                   exsr      zzgtdm
     *
     *    No matrix records found - Create new set.
     C                   if        nopass = *on
     C                   eval      curpass = curpass + 1
     C                   exsr      zznwdm
     C                   eval      nopass = *off
     C                   exsr      zzgtdm
     C                   endif
     *
     C                   eval      curpass = dmpass
     *
     *
     C                   eval      kydrdp = rcdrdp
     *    Load Host assigned door to be assigned.
     C                   z-add     $pdoor        dmdoor
     C     dmkey1        setll     docmtrx1
     *
     C                   dow       cubleft >  0
     *
     C     dmkey1        reade     docmtrx1
     *
     C                   select
     C                   when      %eof(docmtrx1)
     *
     C                   select
     *    After 3 passes have been completed and route still isn't
     *    assigned. Force route to use last door read for current
     *    pass.
     C                   when      passblt >= 2
     C                   exsr      zzforce
     C                   leave
     *
     *    Ok to create new pass for department.
     C                   other
     *
     *    No matrix records found - Create new set.
     C                   eval      curpass = curpass + 1
     C                   exsr      zznwdm
     C                   eval      nopass = *off
     C                   exsr      zzgtdm
     C                   if        nopass = *on
     C                   leave
     C                   endif
     *
     C     dmkey1        setll     docmtrx1
     *    Determine if this will be an odd/even door assignment pass.
     C                   exsr      zzckps
     C                   iter
     C                   endsl
     *
     *    Door is Inactive, skip door and go to next one.
     C                   when      dmstat >= '2'
     C                   iter
     *
     *    Process active / available door.
     C                   other
     *    Find out if this is odd or even dock door.
     C                   exsr      zzckdr
     *
     C                   select
     *
     *    Processing odd pass - Pass and dock door match with Open status.
     C                   when      (mxpass = '*ODD ' and dkdoor = '*ODD ' and
     C                             dmstat = '1') or
     C                             (mxpass = '*EVEN' and dkdoor = '*EVEN' and
     C                             dmstat = '1')
     *
     C                   select
     *    Force return to be ok when its the first pass.
     C                   when      curpass = 1
     C                   eval      $lrtn = '*DRAVAIL'
     *
     *    Check if overflow assigned to this door on previous pass.
     C                   when      curpass > 1
     *
     C                   eval      $lrtn = '        '
     C                   eval      $lcmd = '*CKPRVDR'
     C                   exsr      zzlprm
520 AC                   eval      $latyp = kyatyp
     C                   exsr      zzprdr
     C                   endsl
     *
     *
     C                   select
     *
     *    Door NOT available. Update status and find next door.
     C                   when      $lrtn = '*DRUSED '
     *       Update dock door status - door skipped.
     C                   eval      dmstat = '3'
     *       Update dock door reason - Used for overflow previous pass.
     C                   eval      dmskpr = '2'
     C                   exsr      zzupdm
     *       Save last door info in case we need to force route if
     *       no doors are available.
     C                   exsr      zzsvlst
     *
     *    Door available and entire cube fits at this door.
     C                   when      $lrtn = '*DRAVAIL' and cubleft <= dmmaxc
     C                   exsr      zzfill
     C                   exsr      zzupdm
     *
     *    Door available and entire cube won't fit at this door.
     C                   when      $lrtn = '*DRAVAIL' and cubleft > dmmaxc
     *
     *    Processing available door. Check if next door available for ovrflow.
     C                   eval      $lcmd = '*CKNXTDR'
     C                   exsr      zzlprm
520 AC                   eval      $latyp = kyatyp
     C                   exsr      zzprdr
     *
     C                   select
     *
     *    Door NOT available. Update status and find next door.
     C                   when      $lrtn = '*DRUSED '
     *       Update dock door status - door skipped.
     C                   eval      dmstat = '3'
     *       Update dock door reason - Cube gt door max cube and next door
     *       not available.
     C                   eval      dmskpr = '3'
     C                   exsr      zzupdm
     *       Save last door info in case we need to force route if
     *       no doors are available.
     C                   exsr      zzsvlst
     *
     *    Current door and next door available. Assign cube.
     C                   when      $lrtn = '*DRAVAIL' and cubleft > dmmaxc
     C                   exsr      zzfill
     C                   exsr      zzupdm
     C                   exsr      zzoflw
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   enddo
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCKDR   Check if this is odd/even dock door.
     *----------------------------------------------------------------
     *
     C     ZZCKDR        BEGSR
     *
     C     dmdoor        div       2             result
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
     *  ZZFILL   Load matrix field values for update.
     *----------------------------------------------------------------
     *
     C     ZZFILL        BEGSR
     *
     *    Entire cube fits at this door.
     *
     C                   select
     C                   when      $lrtn = '*DRAVAIL' and cubleft <= dmmaxc
     *
     C                   eval      dmrtid = rcrtid
     C                   eval      dmrtec = dmrtec + cubleft
     C                   eval      cubleft = 0
     C                   eval      dmstat = '2'
     C                   eval      dmskpr = ' '
520 DC*                  eval      dmatyp = 'A'
     C                   eval      dmaby  = #user
     C                   eval      $cvcmd = '*CURCMD '
     *    Retrieve current date.
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      dmadte = $cvd8o
     C                   time                    dmatim
     *
     *    Cube needs this door and the next one.
     *
     C                   when      $lrtn = '*DRAVAIL' and cubleft > dmmaxc
     *
     C                   eval      dmrtid = rcrtid
     C                   eval      dmrtec = dmmaxc
     C                   eval      cubleft = cubleft - dmmaxc
     C                   eval      dmstat = '2'
     C                   eval      dmskpr = ' '
520 DC*                  eval      dmatyp = 'A'
     C                   eval      dmaby  = #user
     C                   eval      $cvcmd = '*CURCMD '
     *    Retrieve current date.
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      dmadte = $cvd8o
     C                   time                    dmatim
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZFORCE  Door not found during normal processing.
     *           Force route to use last door processed.
     *----------------------------------------------------------------
     *
     C     ZZFORCE       BEGSR
     *
     C     dmkey5        chain     docmtrx
     C                   select
     C                   when      %found(docmtrx)
     *
     *    Balance of cube goes to this door.
     *
     C                   eval      dmrtid = rcrtid
     C                   eval      dmrtec = dmrtec + cubleft
     C                   eval      cubleft = 0
     C                   eval      dmstat = '2'
     C                   eval      dmovrf = 'N'
     C                   eval      dmskpr = '6'
520 DC*                  eval      dmatyp = 'A'
     C                   eval      dmaby  = #user
     C                   eval      $cvcmd = '*CURCMD '
     *    Retrieve current date.
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      dmadte = $cvd8o
     C                   time                    dmatim
     *
     C                   update    dmrec
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZGTDH   Get last dock history record.
     *----------------------------------------------------------------
     *
     C     ZZGTDH        BEGSR
     *
     C     dhkey         setgt     dochist
     C     dhkey1        readpe(n) dochist
     C                   if        %eof(dochist)
     C                   eval      nohist = *on
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZGTDM   Get last dock matrix record.
     *----------------------------------------------------------------
     *
     C     ZZGTDM        BEGSR
     *
     C                   select
     *    Routes assigned to single door.  Get last pass to start
     *    search for next available door.
     C                   when      opltyp = '1'
     C     dmkey         setgt     docmtrx1
     C     dmkey         readpe(n) docmtrx1
     C                   if        %eof(docmtrx1)
     C                   eval      nopass = *on
     C                   endif
     *
     *    Routes assigned by dock door department. Get last pass for this
     *    department.
     C                   other
     *
     C     dmkey4        setgt     docmtrx1
     C     dmkey4        readpe(n) docmtrx1
     C                   if        %eof(docmtrx1)
     C                   eval      nopass = *on
     C                   endif
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------
     *
     C     ZZINZ         BEGSR
     *
     *  Define key for DOCHIST file.
     *
     C     dhkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    kyhdte
     C                   kfld                    kyhtim
     *
     C     dhkey1        klist
     C                   kfld                    $pwhse
     *
     *  Define FULL key for DOCMTRX file.
     *
     C     dmkey2        klist
     C                   kfld                    $pwhse
     C                   kfld                    dmhdte
     C                   kfld                    dmhtim
520 AC                   kfld                    kyatyp
     C                   kfld                    dmpass
     C                   kfld                    kydoor
     C                   kfld                    kywhdp
     *
     *  Define FULL key for DOCMTRX file. (Used to force route)
     *
     C     dmkey5        klist
     C                   kfld                    $pwhse
     C                   kfld                    dmhdte
     C                   kfld                    dmhtim
520 AC                   kfld                    kyatyp
     C                   kfld                    lstpass
     C                   kfld                    lstdoor
     C                   kfld                    lstwhdp
     *
     *  Define PARTIAL key for DOCMTRX file.
     *
     C     dmkey3        klist
     C                   kfld                    $pwhse
     C                   kfld                    dmhdte
     C                   kfld                    dmhtim
520 AC                   kfld                    kyatyp
     C                   kfld                    dmpass
     *
     *  Define key for DOCMTRX1 file.
     *
     C     dmkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    dhhdte
     C                   kfld                    dhhtim
520 AC                   kfld                    kyatyp
     C     dmkey1        klist
     C                   kfld                    $pwhse
     C                   kfld                    dmhdte
     C                   kfld                    dmhtim
520 AC                   kfld                    kyatyp
     C                   kfld                    kydrdp
     C                   kfld                    dmpass
     *
     *  Define key for DOCMTRX1 file.
     *
     C     dmkey4        klist
     C                   kfld                    $pwhse
     C                   kfld                    dhhdte
     C                   kfld                    dhhtim
520 AC                   kfld                    kyatyp
     C                   kfld                    rcdrdp
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         KLIST
     C                   KFLD                    $pwhse
     C                   KFLD                    opcode
     *
     *  Define key for RTECSUM  file.
     *
     C     rckey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
      *
      *  Define Full key for RTECSUM1.
      *
     C     rckey1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kydrdp
     *
     *  Define key for RTEHED file.
     *
     C     rhkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZINZ2  Extra program initialization. Called from main line.
     *----------------------------------------------------------------

     C     ZZINZ2        BEGSR

     *  Get Dock Door Options.

     C                   eval      opcode = '*DOCDOOR'
     C     opkey         chain     Options

     *    If options record not found:
     *      Default to not assign dock doors &
     *      use single door for loading route.

     C                   if        not %found(options)
     C*                  eval      opatyp = '1'
     C                   eval      opatyp = '0'
     C                   eval      opltyp = '1'
     C                   endif
     *
     *    Get Route Header record.
     *
     C     rhkey         chain     rtehed
     *
     *    Initialize calling program parms.
     *
     C                   eval      $lwhse = $pwhse
     C                   eval      $lrtid = $prtid
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZLPRM   Load calling program variables.
     *----------------------------------------------------------------
     *
     C     ZZLPRM        BEGSR
     *
     C                   eval      $lhdte = dmhdte
     C                   eval      $lhtim = dmhtim
     C                   eval      $lpass = dmpass
     C                   eval      $ldoor = dmdoor
     C                   eval      $lrte  = rhrte
     C                   eval      $lcube = cubleft
     C                   eval      $lwhdp = dmwhdp
     C                   eval      $lltyp = opltyp
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZNWDH  Create new Dock Door History record.
     *----------------------------------------------------------------
     C     ZZNWDH        BEGSR
     *
     *  Get current date/time
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   time                    curtime
     *
     *    Create history record.
     *
     C                   eval      dhwhse = $pwhse
     C                   eval      dhhdte = curdate
     C                   eval      dhhtim = curtime
     C                   write(e)  dhrec
     C                   if        %error
     C                   goto      endndh
     C                   endif
     C     endndh        ENDSR

     *----------------------------------------------------------------
     *  ZZNWDM  Create new dock matrix records.
     *----------------------------------------------------------------
     C     ZZNWDM        BEGSR
     *
     *    Call program to create matrix records for next pass.
     *
     C                   call      'DK105'
     C                   parm                    dhwhse
     C                   parm                    dhhdte
     C                   parm                    dhhtim
     C                   parm      curpass       $pass
     C                   parm      opltyp        $lltyp
     C                   parm      dmwhdp        $lwhdp
520 AC                   parm      kyatyp        $latyp
     *
     C                   eval      passblt = passblt + 1
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZOFLW   Process overflow cube to assign to next door.
     *----------------------------------------------------------------
     *
     C     ZZOFLW        BEGSR
     C                   eval      kydoor = $ldoor
     C                   eval      kywhdp = $lwhdp
     C     dmkey2        chain     docmtrx
     C                   select
     C                   when      %found(docmtrx)
     *
     *    Balance of cube goes to this door.
     *
     C                   eval      dmrtid = rcrtid
     C                   eval      dmrtec = dmrtec + cubleft
     C                   eval      cubleft = 0
     C                   eval      dmstat = '2'
     C                   eval      dmovrf = 'Y'
     C                   eval      dmskpr = ' '
520 DC*                  eval      dmatyp = 'A'
     C                   eval      dmaby  = #user
     C                   eval      $cvcmd = '*CURCMD '
     *    Retrieve current date.
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      dmadte = $cvd8o
     C                   time                    dmatim
     *
     C                   update    dmrec
     *
     C                   endsl
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZPRDR  Check if previous or next door is available.
     *----------------------------------------------------------------
     C     ZZPRDR        BEGSR
     *
     C                   call      'DK135'
     C                   parm                    $lparm
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZSVLST  Save last dock door info in case we need no
     *           dock doors are available.
     *----------------------------------------------------------------
     *
     C     ZZSVLST       BEGSR
     *
     C                   eval      lstpass = dmpass
     C                   eval      lstdoor = dmdoor
     C                   eval      lstwhdp = dmwhdp
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZTOTAL  Accumulate total cube for Route.
     *----------------------------------------------------------------
     *
     C     ZZTOTAL       BEGSR
     *
     C     rckey         setll     rtecsum
     C                   dow       forevr = forevr
     C
     C     rckey         reade     rtecsum
     *
     C                   select
     C                   when      %eof(rtecsum)
     C                   leave
     *
     *-------------------------------------------------------------------
     *    Routes assigned to single dock door.  Accumulate totals
     *    from all compartments.
     C                   when      opltyp = '1'
     *
     C                   eval      totcube = 0
     C                   eval      svdrdp = *loval
     *
     *    Truck loading from single door. Accumulate totals from
     *    all compartments. Do this one time only.
     *
     C     rckey         setll     rtecsum1
     C                   dow       forevr = forevr
     C     rckey         reade     rtecsum1
     C                   select
     C                   when      %eof(rtecsum1)
     C                   leave
     *
     C                   other
     *
     *    Compartment cube is zero, use compartment piece total in total cube c
     C                   if        r1pckc <= 0 and r1pckp > 0
     C                   eval      totcube = totcube + r1pckp
     C                   else
     C                   eval      totcube = totcube + r1pckc
     C                   endif
     C                   endsl
     *
     C                   enddo
     *
     *    Assign route to Single Dock Door.
     C                   exsr      zzasn1
     *
     *    Route assigned to dock door. Exit loop.
     C                   leave
     *
     *-------------------------------------------------------------------
     *
     *    Assign route to dock doors by department.
     C                   when      opltyp = '2'
     *
     C                   select
     *    Dock department same as last compartment.
     C                   when      rcdrdp = svdrdp
     C                   iter
     *
     *    Dock door dept changed....
     C                   when      rcdrdp <> svdrdp
     *
     *    Fill hold field(s).
     C                   eval      svdrdp = rcdrdp
     *
     C                   eval      clrtot = '*NO '
     C                   eval      clctot = '*NO '
     *    See if dock door dept already processed. 50=Yes.
     C                   eval      k = 1
     C     rcdrdp        lookup    ddr(k)                                 50
     C                   select
     *
     *    Dock door has already been processed. Skip this compartment.
     C                   when      *in50 = *on
     C                   eval      clrtot = '*YES'
     C                   eval      clctot = '*NO '
     *
     *      Dock door not found. Find next empty array element.
     C                   when      *in50 = *off
     C                   eval      k = 1
     C     '     '       lookup    ddr(k)                                 50
     C                   if        *in50 = *on
     C                   eval      ddr(k) = rcdrdp
     C                   eval      clrtot = '*YES'
     C                   eval      clctot = '*YES'
     C                   endif
     C                   endsl
     *
     *    Clear dock door totals before starting.
     C                   if        clrtot = '*YES'
     C                   eval      totcube = 0
     C                   endif
     *
     *    Dock door loading is by Department.
     *
     *    Accumulate totals for door summary based on dock
     *    door dept where product will be loaded onto truck.
     *
     *    Only do this once for each dock door department.
     C                   if        clctot = '*YES'
     C                   eval      kydrdp = rcdrdp
     C     rckey1        setll     rtecsum1
     C                   dow       forevr = forevr
     C     rckey1        reade     rtecsum1
     C                   select
     C                   when      %eof(rtecsum1)
     C                   leave
     C                   other
     *
     *    Compartment cube is zero, use compartment piece total in total cube c
     C                   if        r1pckc <= 0 and r1pckp > 0
     C                   eval      totcube = totcube + r1pckp
     C                   else
     C                   eval      totcube = totcube + r1pckc
     C                   endif
     C                   endsl
     C                   enddo
     *
     *    Assign route by department to Dock Door(s).
     C                   exsr      zzasn2
     *
     C                   endif
     C                   endsl
     *
     C                   endsl
     C                   enddo
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZUPDM  Update dock door Matrix record.
     *----------------------------------------------------------------
     C     ZZUPDM        BEGSR
     *
     C                   if        opltyp = '1'
     C                   update    dmrec
     C                   else
     C                   update    dmrec1
     C                   endif
     *
     C                   ENDSR
     *
