510aA /copy *libl/qcopysrc,hspecs
510aDH*COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')
510aDH*Option(*NODEBUGIO)

     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DH900     Retrieve Dock Door for Route
     *  12 April 2002
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    04/12/02  MLB  4.16
     *      - Created.
     *
417 A*    06/01/04  MLB  4.17
     *      - Fix: Revised program to clear TOTCUBE each time into
     *        program. Changed size of TOTCUBE to 7,0 from 5,0.
     *
520 A*    09/22/09  MLB  5.20
     *      - Enh: No program changes. Recompiled for changes in base
     *        file and logical files.
     *
740 A*    09/14/20  KDE  7.40
     *      - Revised to include US Foods mod 5.10
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        CHAIN INDICATOR
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fdocmtrx2  if   e           k disk
     F                                     rename(dmrec:record)
     Foptions   if   e           k disk
     Fpltsum4   if   e           k disk
     Ftrkcomp   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D msg             s             50    dim(1) ctdata perrcd(1)

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
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

     *   Redefine key

     D  $pwhse                19     21  0
     D  $prtid                22     26
     D  $ptrn#                27     33  0
     D  $pwhdp                34     38
     D  $pdoor                39     41  0
     D  $povrf                42     42
     D  $pofldr               43     45  0
     D  $ptlcub               46     54  3


     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D enter           s              5  0
     D error           s               n
     D forevr          s               n
     D svpass          s                   like(dmpass)
     D svdoor          s                   like(dmdoor)
     D svrtid          s                   like(dmrtid)
     D svwhdp          s                   like(dmwhdp)
417 DD*totcube         s                   like(dmmaxc)
417 MD totcube         s              7  0
     D                                     inz(0)

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

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
     *      $PCMD   Not used
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for retrieve.
     *        $PWHSE - Warehouse number
     *        $PTRN# - Transaction number
     *
     *    Returned Parameters
     *      $PUKY   Contains unique key for retrieve.
     *        $PWHDP - Dock door department
     *        $PDOOR - Dock door
     *        $POVRF - Dock door overflow flag (Y/N)
     *        $POFLDR- Overflow Dock door number
     *        $PTLCUB- Total cube assigned to dock door(s) including overflow d
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *              *OK      - Record retrieved successfully.
     *                         Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   exsr      zzinz2
     *
     C                   select
     *
     *    Route assigned to single door. Retrieve directly from file.
     *
     C                   when      opltyp = '1'
     *
     C     keydm         setll     docmtrx2
     C     keydm         reade     docmtrx2
     *
     C                   select
     C                   when      %eof(docmtrx2)
     C                   eval      $prtn = '*ERROR  '
     *
     C                   other
     *
     C                   eval      $prtn = '*OK     '
     C                   eval      svpass = dmpass
     C                   eval      $pwhdp = dmwhdp
     C                   eval      svwhdp = dmwhdp
     C                   eval      $pdoor = dmdoor
     C                   eval      svrtid = dmrtid
     *
     C                   eval      totcube = totcube + dmrtec
     *
     *    Look for overflow for this route.
     C     keydm         reade     docmtrx2
     *
     C                   if        not %eof  and dmpass = svpass and
     C                             dmrtid = svrtid and dmwhdp = svwhdp and
     C                             dmovrf = 'Y'
     *
     *    Door overflow found. Send back door# and overflow cube amt.
     C                   eval      $povrf  = dmovrf
     C                   eval      $pofldr = dmdoor
     C                   eval      totcube = totcube + dmrtec
     *
     C                   endif
     *
417 AC                   if        totcube > 999999.999
417 AC                   eval      $ptlcub = 999999.999
417 AC                   else
     C                   eval      $ptlcub = totcube
417 AC                   endif
     *
     C                   endsl
     *
     *    Route assigned to department/door. Retrieve compartment for pallet
     *    then retrieve the route from the dock matrix file.
     *
     C                   other
     *
     C     keyps         setll     pltsum4
     C     keyps         reade     pltsum4
     *
     C                   select
     C                   when      %eof(pltsum4)
     C                   eval      $prtn = '*ERROR  '
     *
     C                   other
     *
     C     keytp         chain     trkcomp
     C                   select
     C                   when      not %found(trkcomp)
     C                   eval      $prtn = '*ERROR  '
     *
     C                   when      %found(trkcomp)
     *
     C     keydm1        setll     docmtrx2
     C     keydm1        reade     docmtrx2
     C                   select
     C                   when      %eof(docmtrx2)
     C                   eval      $prtn = '*ERROR  '
     *
     C                   other
     *
     C                   eval      $prtn = '*OK     '
     C                   eval      $pwhdp = dmwhdp
     C                   eval      $pdoor = dmdoor
     *
     C                   eval      svpass = dmpass
     C                   eval      $pwhdp = dmwhdp
     C                   eval      svwhdp = dmwhdp
     C                   eval      $pdoor = dmdoor
     C                   eval      svrtid = dmrtid
     *
     C                   eval      totcube = totcube + dmrtec
     *
     *    Look for overflow for this route.
     C     keydm1        reade     docmtrx2
     *
     *    Door overflow found. Send back door# and overflow cube amt.
     C                   if        not %eof  and dmpass = svpass and
     C                             dmrtid = svrtid and dmwhdp = svwhdp and
     C                             dmovrf = 'Y'
     *
     C                   eval      $povrf  = dmovrf
     C                   eval      $pofldr = dmdoor
     C                   eval      totcube = totcube + dmrtec
     *
     C                   endif
     *
417 AC                   if        totcube > 999999.999
417 AC                   eval      $ptlcub = 999999.999
417 AC                   else
     C                   eval      $ptlcub = totcube
417 AC                   endif
     C                   endsl
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        BEGSR

     *   Call user added initialization routine.

     C                   exsr      zzinz
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         BEGSR
     *
     *  Define key for DOCMTRX2 - Partial
     *
     C     keydm         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     *  Define key for DOCMTRX2 - Partial
     *
     C     keydm1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    tpdrdp
     *
     *  Define key for OPTIONS file. - Full
     *
     C     keyop         KLIST
     C                   KFLD                    $pwhse
     C                   KFLD                    opcode
     *
     *  Define key for PLTSUM4 file. - Full
     *
     C     keyps         KLIST
     C                   KFLD                    $ptrn#
     *
     *  Define key for TRKCOMP - Full

     C     keytp         klist
     C                   kfld                    $pwhse
     C                   kfld                    pscomp

     C                   eval      forevr = *off
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZINZ2   Extra program initialization. Called from Mainline.
     *----------------------------------------------------------------

     C     zzinz2        BEGSR
417 AC                   eval      totcube = 0
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
510aA*
510aA*  Get override dock door method.
510aA*
510aAC                   call      'RTELM'
510aAC                   parm      '*GET'        $dcmd             8
510aAC                   parm      $pwhse        $dwhse            3 0
510aAC                   parm      $prtid        $drtid            5
510aAC                   parm                    $dltyp            1
510aAC                   parm                    $datyp            1
510aAC                   parm                    $drtn             8
510aAC                   parm                    $derm            60
510aAC                   if        $drtn <> '*ERROR'
510aAC                   eval      opltyp = $dltyp
510aAC                   endif
     *
     *  Clear return fields.
     *
     C                   eval      $pwhdp = *blanks
     C                   eval      $pdoor = *zeros
     C                   eval      $povrf = *blanks
     C                   eval      $pofldr= *zeros
     C                   eval      $ptlcub= *zeros
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  Compile time tables
     *----------------------------------------------------------------
**
Dock matrix
