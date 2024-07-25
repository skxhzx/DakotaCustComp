     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')
     H Option(*NODEBUGIO)

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  RH375     Truck Builder Daily Loading Worksheet
     *  18 July 2002
     *  Max Blacknik
     *
     *  Revisions:
     *
416 A*  07/18/02  MLB  4.16
     *    - Created.
     *
520 A*    09/22/09  MLB  5.20
     *      - Enh: Added Assignment Type to dock matrix file key to
     *        keep automatic assigned doors separate from manually
     *        assigned doors. This was done so that the next
     *        dock door to be assigned in the automatic sequence
     *        will always be correct even when a route is moved
     *        from one door to another.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fdocmtrx1  if   e           k disk
     F                                     rename(dmrec:dmrec1)
     Fdocmtrx2  if   e           k disk
     F                                     rename(dmrec:dmrec2)
     Foptions   if   e           k disk
     Frtehed2   if   e           k disk
     Fwarehs    if   e           k disk
     Frh375pr   o    e             printer oflind(*in90)
     F                                     usropn
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D a80             s              1    dim(80)
     D ovrprt          s             80    dim(1) ctdata perrcd(1)
     *
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
     * Program parameters
     *
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD6T                19     24  0
     D  $CVD8I                25     32
     D  $CVD8D                25     32  0
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D  $CVDR1               133    140
     D  $CVVL1               141    145  0
     D  $CVDR2               146    153
     D  $CVVL2               154    158  0
     D  $CVDR3               159    166
     D  $CVVL3               167    171  0
     D  $CVDR4               172    179
     D  $CVVL4               180    184  0
     *----------------------------------------------------------------
     *  Variables
     *
     D $PLEN           s              3  0
     D $PSTR           s             60
     D clctot          s              4    inz('*NO ')
     D clrtot          s              4    inz('*NO ')
     D COUNT           s              3  0
     D dlvdat          S               D   DATFMT(*ISO)
     D eof             S              4    inz('*NO ')
     D FIRST           s              1    inz(*off)
     D Forevr          s              1    inz(*off)
     D K               s              3  0 inz(*zeros)
     D kystat          s                   like(rhstat)
     D                                     inz('4')
     D kytype          s                   like(rhtype)
     D                                     inz(*blanks)
     D LSTDEV          s                   like($DEV)
     D LSTFRM          s                   like($FORM)
     D LSTWHS          s                   like(rhwhse)
     D OPENED          s              1
     D $pwhse          s                   like(rhwhse)
     D nbrprt          s              3s 0 inz(*zeros)
     D today           s              8s 0 inz(*zeros)

     *----------------------------------------------------------------
     *  Renamed fields - Dock door matrix by dept/pass - Logical
     *----------------------------------------------------------------
     IDMREC1
     I              dmwhse                      d1whse
     I              dmhdte                      d1hdte
     I              dmhtim                      d1htim
     I              dmpass                      d1pass
     I              dmdoor                      d1door
     I              dmwhdp                      d1whdp
     I              dmmaxc                      d1maxc
     I              dmrtid                      d1rtid
     I              dmrtec                      d1rtec
     I              dmstat                      d1stat
     I              dmovrf                      d1ovrf
     I              dmskpr                      d1skpr
     I              dmatyp                      d1atyp
     I              dmaby                       d1aby
     I              dmadte                      d1adte
     I              dmatim                      d1atim
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pwhsea           3
     *
     *----------------------------------------------------------------
     *
     C                   exsr      zzinz2
     *
     * Detail Calcs
     *
     C                   exsr      zzread
     *
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Get device and form type for department.
     *
 1B  C                   if        $pwhse <> lstwhs
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'RH375PR'     $lrpt            10
     C                   parm      $pwhse        $rwhse            3 0
     C                   parm      ' '           $styp             1
     C                   parm      ' '           $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   eval      lstwhs = $pwhse
 1E  C                   endif
     *
     *   Open printer file for department.
     *
 1B  C                   if        opened <> *on  or
     C                             $dev <> lstdev  or
     C                             $form <> lstfrm
     *
     *      If printer already open then close it.
     *
 2B  C                   if        opened = *on
     C                   close     rh375pr
 2E  C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(RH375PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *
     C                   movea     ovrprt(1)     a80
     C                   movea     $dev          a80(38)
     C                   movea     $form         a80(59)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *      Open printer file.
     *
     C                   open      rh375pr
     C                   eval      opened = *on
     C                   move      $dev          lstdev
     C                   move      $form         lstfrm
     *
 1E  C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     $pwhse        chain     warehs
 1B  C                   if        %found
     C                   eval      $pstr = $pwhsea + ' - ' + whdesc
 1X  C                   else
     C                   eval      $pstr = *blanks
 1E  C                   endif
     *
     *   Center warehouse description.
     *
     C                   eval      $plen = 30
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     *
     *   Retrieve current date.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      'CVTDTE'
     C                   parm                    $CVTDT
     C                   Eval      today  = $cvd8o
     C                   time                    time
     *
     *   Calculate Delivery Date = Route picked date + 1 day.
     *
     C                   eval      $cvcmd = '*CMDCMD '
     C                   move      rhprtd        $cvd8i
     C                   eval      $CvDr1 = '*ADDDAYS'
     C                   eval      $CvVl1 = 1
     C                   call      'CLCDUR'
     C                   parm                    $CVTDT
     *
     C     *ISO          test (d)                $cvd8o                 77
     *    Invalid date calculated. Use current system date.
     C                   if        *in77 = *on
     C                   eval      $cvd8o = today
     C                   endif
     *
     C     *ISO          move      $cvd8o        dlvdat
     C     *USA          move      dlvdat        dlvdt
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
     C                   write     head2
     C                   write     columns
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrdetl        begsr
     *  Print detail line.
     C                   write     detail1
     *
     C                   write     dash2
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     ZZINZ         BEGSR
     *
     *  Define keys
     *
     *  Define full key for RTEHED2.
     *
     C     rhkey         KLIST
     C                   KFLD                    $pwhse
     C                   KFLD                    kystat
     C                   KFLD                    kytype
     *
     *  Define key for DOCMTRX2 - Partial  (used when opltyp = '1')
     *
     C     kydm2a        klist
     C                   kfld                    $pwhse
     C                   kfld                    rhrtid
     *
     *  Define key for DOCMTRX1 - Full key.
     *
     C     kydm1         klist
     C                   kfld                    dmwhse
     C                   kfld                    dmhdte
     C                   kfld                    dmhtim
520 AC                   kfld                    dmatyp
     C                   kfld                    dmwhdp
     C                   kfld                    dmpass
     C                   kfld                    dmdoor
     *
     *  Define key for DOCMTRX1 - Partial key.
     *
     C     kydm1a        klist
     C                   kfld                    dmwhse
     C                   kfld                    dmhdte
     C                   kfld                    dmhtim
520 AC                   kfld                    dmatyp
     C                   kfld                    dmwhdp
     C                   kfld                    dmpass
     *
     *  Define Full key for OPTIONS file.
     *
     C     KEYOP         KLIST
     C                   KFLD                    $pwhse
     C                   KFLD                    opcode
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     ZZINZ2        BEGSR
     C                   move      $pwhsea       $pwhse
     *
     *    Retrieve Dock Door Options record.
     *
     C                   Z-ADD     $pwhse        OPWHSE
     C                   MOVE      '*DOCDOOR'    OPCODE
     C     KEYOP         CHAIN     OPTIONS
     C                   IF        not %found
     C                   MOVE      '1'           OPATYP
     C                   MOVE      '1'           OPLTYP
     C                   ENDIF
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  ZZREAD   Read Route Header file.
     *
     C     ZZREAD        BEGSR
     *
     *    See if any routes are at Picked status. If yes, print report.
     *
     C     rhkey         setll     rtehed2
     C     rhkey         reade     rtehed2
     C                   select
     C                   when      %eof
     C
     C                   other
     *
     *    Report setup.
     C                   exsr      opnprt
     C                   exsr      zrfrmt
     C                   exsr      zrhead
     C                   eval      eof = '*NO '
     *
     C                   dow       eof = '*NO '
     *
     C                   exsr      zzread2
     *
     *    Read next Route header record
     C     rhkey         reade     rtehed2
     C                   if        %eof
     C                   eval      eof = '*YES'
     *
     *    Report overflow.
     C                   if        *in90 = *on
     C                   exsr      zrhead
     C                   endif
     *
     *    Write report footer.
     C                   write     skip1                                90
     C                   write     foot1                                90
     C                   endif
     C                   enddo
     *
     C                   endsl
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  ZZREAD2  Retrieve Assigned Dock Doors.
     *
     C     ZZREAD2       BEGSR
     *
     C                   eval      c1rte  = rhrte
     C     kydm2a        setll     docmtrx2
     C                   dow       forevr = forevr
     C     kydm2a        reade     docmtrx2
     *
     C                   select
     C                   when      %eof(docmtrx2)
     *
     *    Page overflow - write headings.
     C                   if        *in90 = *on
     C                   exsr      zrhead
     C                   endif
     C                   write     dash2                                90
     C                   leave
     *
     *    Dock door overflow record - skip it.
     C                   when      dmovrf = 'Y'
     C                   iter
     *
     C                   other
     *
     C                   eval      c1cube = dmrtec
     C                   eval      c1whdp = dmwhdp
     C                   eval      c1door = dmdoor
     *
     *    Check if route has overflow at dock door.
     C                   exsr      zzoflw
     *
     *    page overflow - write headinds.
     C                   if        *in90 = *on
     C                   exsr      zrhead
     C                   eval      c1rte  = rhrte
     C                   endif
     *
     C                   if        c1rte = *blanks
     C                   write     dash1                                90
     C                   endif
     *
     C                   write     detail1                              90
     C                   eval      c1rte  = *blanks
     *
     C                   endsl
     C                   enddo
     *
     C                   eval      nbrprt = nbrprt + 1
     *    Maximum 7 routes per page.
     C                   if        nbrprt = 7
     C                   eval      nbrprt = 0
     C                   eval      *in90 = *on
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *
     *  ZZOFLW   Check for overflow for dock door.
     *
     C     ZZOFLW        BEGSR
     *
     C     kydm1         setgt     docmtrx1
     C     kydm1a        reade     docmtrx1
     C                   select
     *    No overflow found.
     C                   when      %eof
     C                   eval      c1ovrf = ' '
     *
     *   Overflow found. Load printer fields.
     C                   when      d1ovrf = 'Y' and d1rtid = dmrtid and
     C                             d1whdp = dmwhdp and dmstat = '2'
     C                   eval      c1ovrf = d1ovrf
     C                   eval      c1cube = c1cube + d1rtec
     *
     *   No overflow found.
     C                   other
     C                   eval      c1ovrf = ' '
     *
     C                   endsl
     *
     C                   ENDSR
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**   OVRPRTF statment
OVRPRTF FILE(RH375PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
