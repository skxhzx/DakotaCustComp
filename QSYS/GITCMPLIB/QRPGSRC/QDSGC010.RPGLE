500 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDSGC010   Q& SGC - Create Missing LICINFO Records
     *  15 December 2013
     *  Max Blacknik
     *  Jeff Jahnke
     *
     *  Note:
     *      - Pgm created create missing LICINFO records that were not
     *        created during receiving due to power failure.
     *
     *----------------------------------------------------------------
     *  Revisions
SGC A*    12/15/13  MLB/JCJ  SGC
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
ccc A*    mm/dd/yy  iii  ccc
     *      -
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     FLabel7    if   e           k disk
     F                                     prefix(lb7)
     Fpomfr     if   e           k disk
     Fporcv1    if   e           k disk
     Foptions   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D lcns            s             15    dim(500)
     D desc            s             50    dim(12) ctdata perrcd(1)

     d $lparm1         s             48    dim(20)
     D $parms1         s             48    dim(20)
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#XDOCK
      /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#LICHIST
      /COPY *libl/qcopysrc,C#LICENSE
      /COPY *libl/qcopysrc,C#ITEM
     D savever#        s                   like($lnver#)

     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *

     *  Extra parameters not part of data structure.

     D $ppo            s              9
     D $pitem          s             15
     D $plcns          s             15
     D $pseq           s              5  0
     D $pindt          s              8  0
     D $pfifo          s              8  0
     D  $pwhse         s              3  0
     D  $emp#          s              5  0

     D $p1parms1       ds
     D  $p1whse                1      3
     D  $p1po                  4     12
     D  $p1poseq              13     17
     D  $p1qstseq             18     22
     D  $p1uctime                      Z

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erlcns                 1     15
     D  erdsp                 16     27
     D  erpos                 28     29p 0
     *
     D  erfld                  1     30
     D  erfromrng             31     40
     D  ertorng               41     50
     *
     D  erpnbr                 1     15
     D  erpusr                16     25

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lstat                19     20
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $lrack                22     26
     *
     D  $lbld                 19     20
     *
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0
     *   for Haccp
     D  $llevel               22     25
     D  $llicense             26     40
     D  $lhpo                 41     49
     D  $lhseq                50     54  0
     D  $lhtype               55     57
     *
     D $mparm          ds
     D  $mcmd                  1      8
     D  $mprg                  9     18
     D  $muky                 19     68
     D  $mrtn                 69     76
     D  $merm                 77    136
     D  $mmsg                 77     80
     D  $mtype                81     88
     *
     D  $mwhs2                19     20P 0
     D  $mpo2                 21     29
     D  $mseq                 30     32P 0
     D  $mitem                33     47
     D  $mqyr1                48     50P 0
     D  $mqyr2                51     53P 0
     D  $mqyr3                54     56P 0
     D  $mcwte                57     59P 0
     D  $mcwtt                60     64P 2
     D  $mcwta                65     68P 2
     D rcv01           c                   const('Receiving')
     D rcv02           c                   const('Dock')
     D Clams           c                   const('CLAMS     ')
     D Shucked         c                   const('SHUCKED   ')
     *----------------------------------------------------------------
     *  Name constants
     *
     D valid           c                   const('0123456789 ABCDEFGHI-
     D                                     JKLMNOPQRSTUVWXYZabc-
     D                                     defghijklmnopqrstuvw-
     D                                     xyz')
     *
     D GLZvalid        c                   const('0123456789 ABCDEFGHI-
     D                                     JKLMNOPQRSTUVWXYZabc-
     D                                     defghijklmnopqrstuvw-
     D                                     xyz-')
     D SGCvalid        c                   const('0123456789')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @fmti2          c                   const('FRMTIT2')
     D @addtr          c                   const('ADDSTDTRN')
     D @uci            c                   const('CW130')
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
     *
     *----------------------------------------------------------------
     * Data structure
     *
     D opdata          ds
     D  opstyp                 1      1
     D  opwhdp                 2      6
     D  opum1                  7      8
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1
     D  opwum                 58     72
     D  opxdsc                73     73
     *
     *  Receiving options.
     D  oplpgm                 1     10
     *
     *  OPUPCT was changed to have 2 decimal positions.
     *
     D  opupct                11     13  2
     D  oppdef                14     14  0
     D  oppbld                15     15  0
     D  oppact                16     16  0
     D  opfdef                17     17  0
     D  opfasl                18     18  0
     D  opfsid                19     19  0
     D  opflvl                20     20  0
     D  oppasl                21     21  0
     D  oppfrc                22     22
     D  optend               117    117
     *----------------------------------------------------------------
     *  *SYSTEM   -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPUCI   -  Use UCI processing (Y,N)
     *----------------------------------------------------------------
     *
     * Data structure
     *
     D opdat4          ds
     D  opuci                 36     36
     D  op4end               117    117
     *
     *----------------------------------------------------------------
     *  *FEATURE  -  PIR Feature options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFEAT  -  PIR Installed feature.
     *                 1=Locator system installed.
     *                 2=Full system installed.
     *                 3=Stand Alone system installed.
     *
     * Data structure
     *
     D opdat3          ds
     D  opfeat                 1      1
     D  op3end               117    117
     *----------------------------------------------------------------
     *  Program info data structure
     *
      /COPY *libl/qcopysrc,C#PGMINFDS
     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10
     D $vstat          s                   like($slstat)
     *----------------------------------------------------------------
     *  Variables
     *
     D $adisp          s             12
     D $apslt          s             12
     D $astyp          s              1
     D $ewhdp          s              5
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D blklcn          s             15
     D ck4err          s              1
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D dummy           s              3  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D extstgFlag      s               n
     D forevr          s              1
     D help            s              5  0
     D hxwhse          s              3  0
     D hxpo            s              9
     D hxposeq         s              5  0
     D hxseq#          s              5  0
     D hxadduc         s               z
     D hxlcns          s             15
     D i               s              3  0
     D l               s              3  0
     D lcnsExists      s               n
     D locatr          s              1
     D lowumq2         s                   like($itumq2)
     D lowumq3         s                   like($itumq3)
     D lwtqty          s              6  0
     D msgk            s              4  0
     D need1           s              5  0
     D need2           s              5  0
     D need3           s              5  0
     D newlbl#         s                   like(lb7lblbl#)
     D noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
     D nxtrec          s              5  0
     D nxtscr          s              3
     D ocode           s              8
     D ossLcns         s               n
     D $pseq#          s              5  0
     D $ptrn#          s              7  0
     D pctr            s              3  0
     D pllStampSys     s               z
     D pllStampUc      s               z
     D posrec          s              4  0
     D ptqty           s              6  0
     D q1lft           s              5  0
     D q2lft           s              5  0
     D q3lft           s              5  0
     D rcvdday         s              3
     D rcvmday         s              3
     D rcvuday         s              3
     D reccnt          s              4  0
     D recno           s              4  0
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D rpal            s              3  0
     D savdsp          s             12
     D sclear          s              1
     D sflrec          s              5  0
     D sv_pdspcl       s              2
     D tmpflg          s              1
     D tmploc          s              3  0
     D today           s              8  0
     D today6          s              6  0
     D totqty          s              6  0
     D t1qty           s              6  0
     D t2qty           s              6  0
     D t3qty           s              6  0
     D uxflag          s              1
     D warn            s              1
     D wtlqty          s              6  0
     D x               s              5  0
     D xdkdri          s              1
     D xdkflg          s              1
     D xdkupd          s              1
     D xqty            s              6  0
     D xx              s              5  0
     D zmflag          s               n
     D zmsflag         s               n
     D $phdte          s              8  0
     D $phloc          s             20
     D $pcert          s             20
     D $pcode          s             10
     D $phhdr          s              1
     D $phdtl          s              1
     D $phcat          s              1
     D sav$pcmd        s              8
     D $plbl#          s              7  0
     D $plic#          s             15
     D $pqty           s              5  0
     D $pprt           s             10
     D $pform          s             10
     D @pttrn#         s              7  0
     D $p1qty          s              6  0
     D $p2qty          s              6  0
     D $p3qty          s              6  0

     D currtimestamp   s               z

     D #rcvarea        s              6
     D #rcvitem        s                   like($ititem)
     D #rcvtype        s                   like($ittype)
     D #rcvdesc        s                   like($itdesc)
     D #rcvpdsc        s                   like($itpdsc)
     D #rcvwhdp        s                   like($itwhdp)
     D #rcvstyp        s                   like($itstyp)
     D #rcvdesg        s                   like($itdesg)
     D #rcvum1         s                   like($itum1)
     D #rcvflg1        s                   like($itflg1)
     D #rcvum2         s                   like($itum2)
     D #rcvumq2        s                   like($itumq2)
     D #rcvflg2        s                   like($itflg2)
     D #rcvum3         s                   like($itum3)
     D #rcvumq3        s                   like($itumq3)
     D #rcvdday        s                   like($imdday)
     D #rcvmday        s                   like($immday)
     D #rcvmflg        s                   like($immflg)
     D #rcvuday        s                   like($imuday)
     D #rcvnrpk        s                   like($imnrpk)
     D #rcvflgd        s                   like($itflgd)
     D #rcvcube        s                   like($itcube)
     D #rcvswgt        s                   like($itswgt)
     D #rcvupc         s                   like($itupc)

     D #slotitem       s                   like($ititem)
     D #slottype       s                   like($ittype)
     D #rcvcwgt        s                   like($itcwgt)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CREATE  - Create missing LICINFO rcds
     *      $PWHS   Warehouse number (alpha)
     *      $PLCNS  License number
     *      $PTRN#  Transaction number
     *      $PPO    P/O Number
     *      $PSEQ   P/O Sequence number
     *      $PITEM  Item number
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pCmd             8
     C                   parm                    $pwhs             3
     C                   parm                    $ppo              9
     C                   parm                    $pseqa            5
     C                   parm                    $pitem           15
     C                   parm                    $plcns           15
     C                   parm                    $ptrn#a           7
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   exsr      zzinz2
     *
     C                   if        error = '0'
     C                   exsr      zzlicinfo
     C                   endif
     *
     *   Do some clean up before leaving.
     *
     C                   eval      *inlr = '1'
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *   Call user added initialization routine.
     *
     C                   move      $pwhs         $pwhse
     C                   move      $pseqa        $pseq#
     C                   move      $ptrn#a       $ptrn#
     C                   exsr      zzinz
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for LABEL7 file.
     *
     C     keylb7        klist
     C                   kfld                    $ptrn#
     C                   kfld                    $pitem
     C                   kfld                    $pseq#
     *
     *  Define key for item POMFR file.
     *
     C     keypm         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    $pseq#
     C                   kfld                    $pitem
     *
     *  Define key for item PORCV1 file.
     *
     C     keypor1       klist
     C                   kfld                    $ptrn#
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ocode
     *
     *  Define key for PODTL file.
     *
     C     keypd         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    $pseq
     C                   kfld                    $pitem
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     *
     *  Get Feature option.
     *
     C                   eval      ocode = '*FEATURE'
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opfeat = '2'
     C                   else
     C                   eval      opdat3 = opdata
     C                   endif
     C                   if        opfeat = '1'
     C                   eval      locatr = *on
     C                   else
     C                   eval      locatr = *off
     C                   endif
     *
     *  Get System option.
     *
     C                   eval      ocode = '*SYSTEM '
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opuci  = 'N'
     C                   else
     C                   eval      opdat4 = opdata
     C                   endif
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Convert today's date into MMDDYY format.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today6 = $cvd6o
     *
     C                   eval      $lprg = #pgm
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     C     keylb7        setll     label7
     C     keylb7        reade     label7
     C                   if        %eof(label7)
     C                   eval      error = '1'
     C                   goto      #endinz2
     C                   endif
     *
     C     keypor1       setll     porcv1
     C     keypor1       reade     porcv1
     C                   if        %eof(porcv1)
     C                   eval      error = '1'
     C                   goto      #endinz2
     C                   endif
     C
     C     keypm         chain     pomfr
     C                   if        not %found(pomfr)
     C                   eval      pmwhse = 0
     C                   eval      pmpo   = ' '
     C                   eval      pmseq  = 0
     C                   eval      pmitem = ' '
     C                   eval      pmexpd = 0
     C                   eval      pmmfgd = 0
     C                   eval      pmtrn# = 0
     C                   eval      pmlbl# = 0
     C                   endif

     *  Use DRI interface to get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = $pitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif


     C                   eval      #rcvitem = $ititem
     C                   eval      #rcvtype = $ittype
     C                   eval      #rcvdesc = $itdesc
     C                   eval      #rcvpdsc = $itpdsc
     C                   eval      #rcvwhdp = $itwhdp
     C                   eval      #rcvstyp = $itstyp
     C                   eval      #rcvdesg = $itdesg
     C                   eval      #rcvum1  = $itum1
     C                   eval      #rcvflg1 = $itflg1
     C                   eval      #rcvum2  = $itum2
     C                   eval      #rcvumq2 = $itumq2
     C                   eval      #rcvflg2 = $itflg2
     C                   eval      #rcvum3  = $itum3
     C                   eval      #rcvumq3 = $itumq3
     C                   eval      #rcvnrpk = $imnrpk
     C                   eval      #rcvmflg = $immflg
     C                   eval      #rcvdday = $imdday
     C                   eval      #rcvmday = $immday
     C                   eval      #rcvuday = $imuday
     C                   eval      #rcvflgd = $itflgd
     C                   eval      #rcvcube = $itcube
     C                   eval      #rcvswgt = $itswgt
     C                   eval      #rcvcwgt = $itcwgt

     *  Use DRI interface to get Slot item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = $pitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSLOT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   clear                   #slotitem
     C                   clear                   #slottype
     C                   endif

     C                   eval      #slotitem = $ititem
     C                   eval      #slottype = $ittype
     *
     C     enditm        tag
     *
     *  Get receiving options.
     *
     C                   eval      ocode = '*RCVLBL '
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*NOOPT  '
     C                   endif

     C     #endinz2      endsr

     *----------------------------------------------------------------
     *  ZZLICINFO   Update licinfo
     *----------------------------------------------------------------

     C     zzlicinfo     begsr

     *  Write out standard license information.

     C                   exsr      clr$licinfo

     C                   eval      $lnpgm  = 'PO236'
     C                   eval      $lnjob  = pordev
     C                   eval      $lnjobnbr  = '000000'

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
     C                   eval      $lnlcns  = $pLcns

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*PO'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'A'
     C                   eval      $lnvalchr(1) = $ppo
     C                   eval      $lnvalnum(1) = 0

     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*POSEQ'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = $pseq#

     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*ITEM'
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'A'
     C                   eval      $lnvalchr(3) = $pitem
     C                   eval      $lnvalnum(3) = 0


     C                   eval      $lncodeu(5) = *on
     C                   eval      $lncode(5) = '*RCVTRN#'
     C                   eval      $lncseq(5) = 1
     C                   eval      $lnvaltyp(5) = 'N'
     C                   eval      $lnvalchr(5) = ' '
     C                   eval      $lnvalnum(5) = lb7lbtrn#


     C                   eval      $lncodeu(7) = *on
     C                   eval      $lncode(7) = '*RCVLQTY'
     C                   eval      $lncseq(7) = 1
     C                   eval      $lnvaltyp(7) = 'N'
     C                   eval      $lnvalchr(7) = ' '
     C                   eval      $lnvalnum(7) = lb7lbqpck

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%ADD'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     *  Write out more standard and optional license information.

     C                   exsr      clr$licinfo

     C                   eval      $lnpgm  = 'PO236'
     C                   eval      $lnjob  = pordev
     C                   eval      $lnjobnbr  = '000000'

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
     C                   eval      $lnlcns  = $plcns

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*RCVLBL#'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'N'
     C                   eval      $lnvalchr(1) = ' '
     C                   eval      $lnvalnum(1) = lb7lblbl#

     C                   if        pmexpd > 0
     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*EXPDTE'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = pmexpd
     C                   endif

     C                   if        pmmfgd > 0
     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*DATEIN '
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'N'
     C                   eval      $lnvalchr(3) = ' '
     C                   eval      $lnvalnum(3) = pmmfgd
     C                   endif

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%ADD'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     *  Write out date type license information.

     C                   if        #rcvflgd = 'N'
     *  Do not write out any date info if not date sensitive.
     C                   else
     *
     C                   if        #rcvflgd = 'Y'
     C                   exsr      clr$licinfo

     C                   eval      $lnpgm  = 'PO236'
     C                   eval      $lnjob  = pordev
     C                   eval      $lnjobnbr  = '000000'

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
     C                   eval      $lnlcns  = $plcns

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*DATETYP'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'A'
     C                   eval      $lnvalnum(1) = 0
     C                   select
     C                   when      #rcvuday > 0 or
     C                             #rcvdday > 0
     C                   if        #rcvmflg = 'Y'
     C                   eval      $lnvalchr(1) = '*MFGDTE'
     C                   else
     C                   eval      $lnvalchr(1) = '*USEDTE'
     C                   endif
     C                   other
     C                   eval      $lnvalchr(1) = '*EXPDTE'
     C                   endsl
     C                   else
     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*DATETYP'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'A'
     C                   eval      $lnvalchr(1) = '*ENTDTE'
     C                   eval      $lnvalnum(1) = 0
     C                   endif

     C                   move      #rcvuday      rcvuday
     C                   move      #rcvdday      rcvdday
     C                   move      #rcvmday      rcvmday
     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*DTESET1'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'A'
     C                   eval      $lnvalchr(2) = '&DTEF='+(#rcvflgd) +
     C                             ' &MFGF='+(#rcvmflg)
     C                   eval      $lnvalnum(2) = 0

     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*DTESET2'
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'A'
     C                   eval      $lnvalchr(3) = '&MFGD='+(rcvmday) +
     C                             ' &USRD='+(rcvuday) +
     C                             ' &DSTD='+(rcvdday)
     C                   eval      $lnvalnum(3) = 0

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%ADD'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$license  Clear $license data structure fields
     *----------------------------------------------------------------

     C     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = poremp
     C                   eval      $liuser = porusr
     C                   eval      $lipgm  = 'PO236'
     C                   eval      $lijob  = pordev
     C                   eval      $lijobn = '000000'
     C                   eval      $liTowhse = $pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr

     *----------------------------------------------------------------
     *  clr$lichist  Clear $lichist data structure fields
     *----------------------------------------------------------------

     C     clr$lichist   begsr
     C                   eval      savever# = $lrver#
     C                   clear                   $lichist
     C                   eval      $lrver# = savever#
     C                   eval      $lremp# = poremp
     C                   eval      $lruser = porusr
     C                   eval      $lrpgm  = 'PO236'
     C                   eval      $lrjob  = pordev
     C                   eval      $lrjobn = '000000'
     C                   eval      $lrwhse = $pwhse
     C                   eval      $lrwhseu = *on
     C                   endsr

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #curruser
     C                   eval      $lnemp# = poremp
     C                   eval      $lnpgm  = 'PO236'
     C                   eval      $lnjob  = pordev
     C                   eval      $lnjobnbr = '000000'

     C                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = $emp#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $dridata = $xdock
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $dridata = $lichist
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
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

     C                   when      %error and ck4err = *on
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C                   endsl

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $xdock = $dridata
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $lichist = $dridata
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      ck4err = *off
     C     enddricop     endsr

     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Aisle
Start From
Starting Level
Detail record
Starting Number
Current Maximum Level
Future Maximum Level
Racks on One Side
Duplicate license numbers found
license number
Status
Statu58757 not be A, V, or Z
