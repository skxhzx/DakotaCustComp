      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  LT341   Order License - Report
     *  04 Octomer 2011
     *  Jeff Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    10/04/11  JCJ  6.40  Quote 1035
     *      - Created
640bA*    10/10/12  LMC  6.40b
     *      - Revised to call drilicinfo instead of using file directly.
650aA*    12/11/13  RH   6.50a
     *      - Moved 640b mods and re-activated to clear error issue.  y.
     *      - Fix: change to use license action quantity not label
     *        pick quantity.
700a *    09/27/16  LMC  7.00a
     *      - Fix: Endif was in he wrong spot, so we were loading the y.
     *        last liclog SEL when we encountered a SOS Action.       y.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position Cursor
     *  21 - 29   Field Input Error (Reverse Display)
     *  70        Chain Indicator (ORDHM2)
     *  79        Chain Indicator
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  21        Manually set subfile change flag (SFLNXTCHG)
     *  90        Protect Input Fields for Delete Display
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Foptions   if   e           k disk
     Fordd1     if   e           k disk
     F                                     rename(odrec:record)
     Flabel93   if   e           k disk
     Fliclog2   if   e           k disk
640bDF*licinfo2  if   e           k disk
     Fpohhdr    if   e           k disk
     Freports   if   e           k disk
     Flt341pr   o    e             printer usropn
     F                                     oflind(*IN90)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a80             s              1    dim(80)
     *
     *    Printer override
     *
     D ovrprt          s             80    dim(2) ctdata perrcd(1)
640bA*----------------------------------------------------------------
640bA*  DRI parameters
640bA*----------------------------------------------------------------
640bA /COPY *libl/qcopysrc,C#DRIPARMS
640bA
640bA*----------------------------------------------------------------
640bA*  Data Formats
640bA*----------------------------------------------------------------
640bA /COPY *libl/qcopysrc,C#LICINFO
640bAD savever#        s                   like($lnver#)
     *----------------------------------------------------------------
     *  Customer id
     *
      /copy qcopysrc,id#coastal
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $kord                  4     10  0
     D  $krteid               11     15
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  rdwhse                 1      3  0 inz(0)
     D  rdord                  4     10  0 inz(0)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('none')
     D @delpg          c                   const('none')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D                                     DIM(3)
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     D  $pwhse                19     21  0 inz(0)
     D  $prte                 22     26
     D  $prtid                27     31

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
     D  $ltruk                22     31
     D  $ltrk2                32     41
     *
     D  $lhdte                22     29  0
     D  $lhtim                30     35  0
     *
     D  $krte                 32     36
     D  $krtid                37     41

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
     *  Other data structures
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *  Program info data structure
     *
640bA /Copy qcopysrc,c#pgminfds
640bDD*               sds
640bDD* #prog            *proc
640bDD* #job                 244    253
640bDD* #user                254    263
640bDD* #jobn                264    269
640bDD* #jobdt               276    281  0
640bDD* #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
640bAD chk4err         s               n
640bAD error           s               n
     D x               s              3  0
     D y               s              3  0
     D dsplyd          s              2  0
     D w3addts         s             26
     D w1vnam          s             24
     D w2olcns         s             15
     D w3adduser       s             10
     D $pdev           s             10
     D $pform          s             10
     D #pgmq           s             10
     D wkprtf          s             10
     D wkpo#           s              9
     D $pcmmd          s              8
     D $rtn            s              8
     D wkinfocd        s              8    inz('*PO')
     D w3code          s              8
     D opened          s              1
640bAD zmflag          s               n
640bAD zmsflag         s               n
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     C                   exsr      zzinz2
     *
     C     partky        setll     ordd1
     C                   dou       %eof(ordd1)
     C     partky        reade     ordd1
     C                   if        not %eof(ordd1)
     C                   exsr      zzfill
     C                   endif
     C                   enddo
     *
     C                   seton                                        lr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     C                   eval      w1item = oditem
     C                   eval      w1rqty = *zeros
     C                   eval      w1loc = *blanks
     C                   eval      w1lcns = *blanks
     C                   eval      w1vnam = *blanks
     C                   eval      w2olcns = *blanks
     C                   eval      w3po# = *blanks
     C                   eval      w3code = *blanks
     *
     C     keyl93        setll     label93
     C                   dou       %eof(label93)
     C     keyl93        reade     label93
     C                   if        not %eof(label93)

     C                   eval      w1rqty = 0
     C                   if        $krteid = lbrte
     C                             and lbtype <> 'M'
     C                   eval      w1loc = lbdisp
650aDC*                  eval      w1rqty = lbqpck
      ***                leave
     *
     C     kylic2        setgt     liclog2
     C                   dou       %eof(liclog2)
     C     kylic2        readpe    liclog2
     C                   if        not %eof(liclog2)

     C                   if        llaction = 'SEL'
     C                   eval      w1lcns = lllcns
     C                   eval      w2olcns = llolcns
     C                   eval      w3active = llaction
     C                   eval      w3adduser = lladdcusr
     C                   move      lladdts       w3addts
650aAC                   select
650aAC                   when      lbutyp = 'N'
650aAC                   eval      w1rqty = llaqty1
650aAC                   when      lbutyp = '1'
650aAC                   eval      w1rqty = llaqty2
650aAC                   when      lbutyp = '2'
650aAC                   eval      w1rqty = llaqty3
650aAC                   endsl
      ****               leave
700aDC*                  endif

650aDC*    kylifo        setll     licinfo2
650aDC******             dou       %eof(licinfo2)
650aDC*    kylifo        reade     licinfo2
650aDC*                  if        not %eof(licinfo2)
650aD *
650aDC*                  if        lncode = wkinfocd
650aDC*                  eval      wkpo# = %subst(lnvalue:1:9)
650aDC*                  eval      w3po# = %subst(lnvalue:1:9)
650aDC*    kyphdr        chain     pohhdr
650aDC*                  if        %found(pohhdr)
650aDC*                  eval      w1vnam = phhvna
650aDC*                  eval      w3code = lncode
650aDC*                  endif
650aDC*                  leave
650aDC*                  endif
650aD
650aDC*                  endif
650aDC******             enddo

640bA*  Get Licinfo Information
640bA
640bAC                   exsr      clr$licinfo
640bA
640bAC                   eval      $lnemp# = 0
640bAC                   eval      $lnuser = #user
640bAC                   eval      $lnpgm  = #prog
640bAC                   eval      $lnjob  = #job
640bAC                   eval      $lnjobnbr  = #jobn
640bA
640bAC                   eval      $lnwhse  = lbwhse
640bAC                   eval      $lnlcns  = w1lcns
640bA
640bAC                   eval      $dricommand = '*LICINFO'
640bAC                   eval      $drisubcmd  = '%GET'
640bAC                   eval      $drisys2upd = 'D'
640bAC                   eval      chk4err = *on
640bAC                   exsr      zzzdricop
640bAC                   if        error
640bAC                   endif
640bA
640bA*  Now process the return information
640bAc                   eval      wkpo#  = $lnpo
640bAc                   eval      w3po#  = $lnpo
640bA
650aAC     kyphdr        chain     pohhdr
650aAC                   if        %found(pohhdr)
650aAC                   eval      w1vnam = phhvna
640bMC                   eval      w3code = wkinfocd
640bAC                   endif

     C                   write     detail1

700aAC                   endif
     C                   endif
     C                   enddo

     C                   endif
     C                   endif
     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C                   close     lt341pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(PLBL__PR) OUTQ(*DEV) DEV(rodev)
     *                  FORMTYPE(roform)
     *
     C                   movea     ovrprt(1)     a80
     C                   movea     $pdev         a80(39)
     C                   movea     $pform        a80(60)
     C                   movea     a80           qcmd
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *      Open printer file.
     *
     C                   open      lt341pr
     C                   eval      opened = *on
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *  ZZHeading - Print headings
     *
     C     zzheadings    begsr
     C                   write     head1
     C                   write     columns1
     C                   endsr
     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kord
     *
     *  Define key for file OPTIONS - Full key.
     *
     C     keyop         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     *  Define key for file LABEL93.
     *
     C     keyl93        klist
     C                   kfld                    odwhse
     C                   kfld                    odord
     C                   kfld                    oditem
     C                   kfld                    odseq
     *
     *  Define key for file LICLOG2.
     *
     C     kylic2        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbtrn#
     C                   kfld                    lblbl#
     *
     *  Define key for file LICINFO1.
     *
     C     kylifo        klist
     C                   kfld                    lbwhse
     C                   kfld                    w1lcns
     *
     *  Define key for file POHHDR.
     *
     C     kyphdr        klist
     C                   kfld                    lbwhse
     C                   kfld                    wkpo#
     *
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     zzinz2        begsr
     *
     *   Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     rdwhse        parm      0             #whse             3 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *   Get report title and dev/form and override printer file.
     *
     C                   movel     'LT341PR '    wkprtf
     C     rpkey         chain     reports
     C                   if        %found(reports)
     C                   movel     rpdev         $pdev
     C                   movel     rpform        $pform
     C                   else
     C                   eval      $pdev  = '*JOB'
     C                   eval      $pform = '*STD'
     C                   endif
     *
     * Open printer file for zone.
     *
     C                   exsr      opnprt
     *
     C                   time                    time
     C                   exsr      zzheadings
     *
     C                   endsr
640bA*----------------------------------------------------------------
640bA*  clr$licinfo  Clear $licinfo data structure fields
640bA*----------------------------------------------------------------
640bA
640bAC     clr$licinfo   begsr
640bAC                   eval      savever# = $lnver#
640bAC                   clear                   $licinfo
640bAC                   clear                   $licinfo2
640bAC                   eval      $lnver# = savever#
640bAC                   eval      $lnuser = #user
640bAC                   eval      $lnpgm  = #prog
640bAC                   eval      $lnjob  = #job
640bAC                   eval      $lnjobnbr = #jobn
640bAC                   endsr

640bA*----------------------------------------------------------------
640bA*  zzzdricop  Call DRICOP
640bA*----------------------------------------------------------------
640bA
640bAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   endsl

     C                   if        $dricommand = '*LICINFO'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C*                  eval      errmsg    = 'Error occured on call to '
     C*                                      + 'DRICOP'
     C*                                      + '/' + %trim($drisubcmd)
     C*                                      + ' from ' + #prog
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C*                  exsr      zm0105
     C                   endsl

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**   OVRPRTF statment
OVRPRTF FILE(LT341PR)  OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
