     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TAGFMT       Print Clam Tag labels on Zebra printer
     *  22 November 2005
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    11/22/05  DAS  5.00
     *      - Created.
     *
650aA*    09/06/13  JCJ/LMC  6.50a
     *      - added variable 452 for GS1 barcode
     *
650bA*    07/09/14  JCJ/RBD  6.50b
     *      - added variable 315 for Lot number and 330 for wet date.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Flblfmth   if   e           k disk
     Flblfmtd   if   e           k disk
     Flblfmtv   if   e           k disk
     Flblfmtt   if   e           k disk
     Foptions   if   e           k disk
     FReports   if   e           k disk
650bAFclammsc   if   e           k disk
     Ftagfmtpr  o    f  198        printer oflind(*IN90)
     F                                     usropn

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a12             s              1    dim(12)
     D a40             s              1    dim(40)
     D a50             s              1    dim(50)
     D a58             s              1    dim(58)
     D a80             s              1    dim(80)
     D sti             s              1    dim(75)
     D sto             s              1    dim(198)
     D ovrprt          s             80    DIM(1) CTDATA PERRCD(1)

     *----------------------------------------------------------------
     *  CVTDTE definitions
     *----------------------------------------------------------------

     D @CVTDT          C                   CONST('CVTDTE')

     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
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
     *----------------------------------------------------------------

650bAD WetDate         s             30    inz('Product Wet Stored to')
     D curdate         s              8  0
     D lblset          s              6
     D lblformat       s              8
     D wktihi          s              7
650bAD mdy2            s              8
650bAD mdyDate         s               d   datfmt(*mdy)
650bAD isoDate         s               d   datfmt(*iso)

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     D                 ds
     D  $ec                    1      2p 0

     D                 ds
     D  dssdte                 1      8
     D  dsyy                   3      4
     D  dsmm                   5      6
     D  dsdd                   7      8

     D                 ds
     D  wksdte                 1      8
     D  wkmm                   1      2
     D  wksl1                  3      3
     D  wkdd                   4      5
     D  wksl2                  6      6
     D  wkyy                   7      8

     *----------------------------------------------------------------
     *  Options data
     *----------------------------------------------------------------

     D opdata          DS
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opten2               117    117

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
     *
     *      $pcmd   - Command
     *      $pwhse  - Warehouse
     *      $ppo    - P.O. number
     *      $pseq   - P.O. detail seq#
     *      $pitem  - Item
     *      $plic#  - License number
     *      $pqty   - License quantity
     *      $phdte  - Harvest date (yyyymmdd)
     *      $phloc  - Harvest location
     *      $phcert - Harvest original shippers certification number
     *      $plbl#  - Label number
     *      $pdev   - Printer device
     *      $pform  - Printer form
     *
     *    Returned Parameters
     *
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $ppo              9
     C                   parm                    $pseq             5 0
     C                   parm                    $pitem           15
     C                   parm                    $pdesc           30
     C                   parm                    $plic#           15
     C                   parm                    $pqty             5 0
     C                   parm                    $phdte            8 0
     C                   parm                    $phloc           20
     C                   parm                    $phcert          20
     C                   parm                    $plbl#            7 0
     C                   parm                    $pdev            10
     C                   parm                    $pform           10

650bAC                   exsr      zzinz2
     C                   eval      wkdev = $pdev
     C                   eval      wkform = $pform

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     * Set label format to use.

650aMC                   eval      lblset = 'ZBRCT2'
     C                   eval      lblformat = 'CLAMTAG'

     * Retrive label format information.

     C     keylfh        chain     lblfmth
     C                   if        not %found
     C                   eval      lfhslg = *blanks
     C                   endif

     * Open printer file

     C                   exsr      opnprt

     * Print a label for each piece recieved.

     C     1             do        $pqty
650aA /free
650aA   $lwhse = %char(opwhse);
650aA /end-free
650aAc                   call      'LB411'
650aAc                   parm                    $lwhse            3
650aAc                   parm      ' '           $lrtn             8
650aAc                   parm      $pitem        $litem           15
650aAc                   parm      0             $lqty             2 0
650aAc                   parm      ' '           $ldev            10
650aAc                   parm      ' '           $lform           10
650aAc                   parm      '*DOCLAM'     $lcmd            10
650aAc                   parm      $plic#        $llcns           15
650aAc                   parm      ' '           $lgs199fmt       12
     C                   exsr      fillb1
     C                   enddo

     C     bottom        tag
     C                   eval      *inlr = *on

     * Close up shop and return home.

     CLR                 if        opened = *on
     CLR                 close     tagfmtpr
     CLR                 endif

     CLR                 return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *   Define key for LBLFMTH

     C     keylfh        klist
     C                   kfld                    lblset

     *   Define key for LBLFMTD file.

     C     keylfd        klist
     C                   kfld                    lblset
     C                   kfld                    lblformat

     *   Define key for OPTIONS file.

     C     opkey         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode

     *  Define key for REPORTS file.

     C     Rpkey         Klist
     C                   Kfld                    Wkprtf           10

     *  Define key for LBLFMTV file.

     C     *like         define    lfvnum        kyvnum
     C     keylfv        klist
     C                   kfld                    kyvnum

     * Convert today's date into century format.

     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o

     *   Get system options

     C                   z-add     0             opwhse
     C                   move      '*SYSTEM '    opcode
     C
     C     opkey         chain     options                            79
     C                   if        *in79 = *on
     C                   eval      opletd = 'Y'
     C                   endif

     *   Get report device and form.


     C**                 MOVEL     'TAGFMTPR  '  WKPRTF
     C                   MOVE      *BLANKS       wkdev            10
     C                   MOVE      *BLANKS       wkform           10
     C**   Rpkey         Chain     Reports
     C**                 If        %Found
     C**                 Movel     RPDEV         wkdev
     C**                 Movel     RPFORM        wkform
     C**                 Else
     C**                 eval      wkdev = '*JOB      '
     C**                 eval      wkform = '*STD      '
     C**                 Endif
     C
416aAC                   Move      *On           Forevr            1
416aAC                   Move      *Off          opened            1
     C                   z-add     75            maxsti            2 0
     C                   z-add     198           maxsto            3 0
     C                   endsr

     *----------------------------------------------------------------
     *  OPNPRT   Open printer file.
     *----------------------------------------------------------------

     C     opnprt        begsr

     C                   if        opened <> *on
     C                   movea     ovrprt(1)     a80
     C                   movea     wkdev         a80(39)
     C                   movea     wkform        a80(60)
     C                   movea     a80           qcmd
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5

     * Open printer file

     C                   open      tagfmtpr
     C                   eval      opened = *on

     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  PRINT    Output string to printer.
     *----------------------------------------------------------------

     C     print         begsr
     *
     C                   move      *off          prtflg            1
     C                   movea     sto           @outpt          198
     C                   except    #str
     C                   eval      sto = *blanks
     C                   z-add     0             op

     C                   endsr

     *----------------------------------------------------------------
     *  FILLB1   Process script for single label format.
     *----------------------------------------------------------------

     C     fillb1        begsr

     C                   eval      sto = *blanks
     C                   z-add     0             op                3 0

     C     keylfd        setll     lblfmtd
     C     forevr        doweq     forevr
     C     keylfd        reade     lblfmtd
     C                   if        %eof(lblfmtd)
     C                   leave
     C                   endif

     C                   if        lfdstr = *blanks
     C                   iter
     C                   endif

     C                   movea     lfdstr        sti
     C                   z-add     0             ip                3 0

     C                   move      *off          vflag             1
     C                   z-add     0             @var              3 0
     C                   z-add     0             @len              3 0

     * Loop through each character of label.

     C     1             do        maxsti        ip                3 0

     C                   select

     *      Beginning of variable.

     C     sti(ip)       wheneq    '<'
     C     $pcmd         andne     '*TEST1  '
     C                   if        vflag = *on
     C                   exsr      fillb2
     C                   endif
     C                   eval      vflag = *on
     C                   z-add     0             @var
     C                   z-add     1             @len

     *      End of variable.

     C     sti(ip)       wheneq    '>'
     C     vflag         andeq     *on
     C                   add       1             @len
     C                   exsr      fillb2
     C                   eval      vflag = *off

     *      Within variable.

     C     vflag         wheneq    *on
     C                   add       1             @len

     *      Extract variable id number

     C                   select
     C     @len          wheneq    2
     C     sti(ip)       andge     '0'
     C     sti(ip)       andle     '9'
     C                   move      sti(ip)       temp1a            1
     C                   move      temp1a        temp1n            1 0
     C                   z-add     temp1n        @var
     C     @len          wheneq    3
     C     sti(ip)       andge     '0'
     C     sti(ip)       andle     '9'
     C                   move      sti(ip)       temp1a            1
     C                   move      temp1a        temp1n            1 0
     C                   mult      10            @var
     C                   add       temp1n        @var
     C     @len          wheneq    4
     C     sti(ip)       andge     '0'
     C     sti(ip)       andle     '9'
     C                   move      sti(ip)       temp1a            1
     C                   move      temp1a        temp1n            1 0
     C                   mult      10            @var
     C                   add       temp1n        @var
     C                   endsl

     *      Not within variable - Move character to output string

     C                   other
     C                   add       1             op
     C                   move      sti(ip)       sto(op)
     C     op            ifeq      maxsto
     C                   exsr      print
     C                   endif

     C                   endsl

     C                   enddo

     *      Output variable if necessary.

     C     vflag         ifeq      *on
     C                   exsr      fillb2
     C                   endif

     C                   exsr      print

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  FILLB2   Added variable to output string.
     *----------------------------------------------------------------

     C     fillb2        begsr

     C     $pcmd         ifeq      '*TEST2  '
     C                   z-add     @var          kyvnum
     C     keylfv        chain     lblfmtv                            78
     C     *in78         cabeq     *on           endfi2
     C                   endif

     C                   select
     *  Origianal certificate #
     C     @var          wheneq    150
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $phcert       a50
     C                   endif
     C                   exsr      filchr
     *  Harvest Date
     C     @var          wheneq    151
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      $phdte        dssdte
     C                   move      dsmm          wkmm
     C                   move      '/'           wksl1
     C                   move      dsdd          wkdd
     C                   move      '/'           wksl2
     C                   move      dsyy          wkyy
     C                   move      *blanks       a50
     C                   movea     wksdte        a50
     C                   endif
     C                   exsr      filchr
     *  Harvest Location
     C     @var          wheneq    152
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $phloc        a50
     C                   endif
     C                   exsr      filchr
     *  Shellfish type
     C     @var          wheneq    153
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $pdesc        a50
     C                   endif
     C                   exsr      filchr
650bA*  Lot #
     C     @var          wheneq    315
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   if        clmwdt = 0
     C                   movea     'N/A'         a50
     C                   else
     C                   movea     clmlot        a50
     C                   endif
     C                   endif
     C                   exsr      filchr
650bA*  Wet stored to Date
     C     @var          wheneq    330
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   if        clmwdt <> *zeros
     C                   move      clmwdt        isodate
     C                   move      isodate       mdydate
     C                   move      mdydate       mdy2
     C                   eval      wetdate = %trim(wetdate)
     C                             + ' '
     C                             + %trim(mdy2)
     C                   else
     C                   eval      wetdate = %trim(wetdate) + ' N/A'
     C                   endif
     C                   move      *blanks       a50
     C                   movea     wetdate       a50
     C                   endif
     C                   exsr      filchr
650aA*  GS1 Barcode
650aAC     @var          wheneq    452
650aAC     $pcmd         ifeq      '*TEST2  '
650aAC                   movel     lfvdta        a50
650aAC                   else
650aAC                   move      *blanks       a50
     c
650aAC                   movea     $lgs199fmt    a50
650aAC                   endif
650aAC                   exsr      filchr
     *
     C                   endsl
     *
     C     endfi2        endsr

     *----------------------------------------------------------------
     *  FILCHR   Fill character variable.
     *----------------------------------------------------------------

     C     filchr        begsr

     *  Move character string into output string.

     C                   z-add     @len          lc                3 0
     C     1             do        lc            y                 3 0
     C                   add       1             op
     C                   move      a50(y)        sto(op)
     C     op            ifeq      maxsto
     C                   exsr      print
     C                   endif
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  FILLNUM  Fill numeric variable.
     *----------------------------------------------------------------

     C     filnum        begsr

     *  Format number.

     C                   exsr      editna

     *  Find first character in array string.

     C                   z-add     1             fc                3 0
     C     fc            doueq     13
     C     a12(fc)       ifne      *blanks
     C                   leave
     C                   endif
     C                   add       1             fc
     C                   enddo

     *  Move formatted number into output string.

     C                   move      *blanks       a50
     C                   z-add     @len          y
     C                   z-add     12            x                 3 0
     C     x             doueq     0
     C     y             oreq      0
     C                   move      a12(x)        a50(y)
     C                   sub       1             x
     C                   sub       1             y
     C                   enddo
     C                   exsr      filchr

     C                   endsr

     *----------------------------------------------------------------
     *  EDITNA   Edit nemeric to alpha.
     *----------------------------------------------------------------

     C     editna        begsr

     C                   move      *blanks       a40
     C     $nanum        cabeq     0             ena01
     C                   move      *blanks       temp40           40
     C                   movel     $nanum        temp40
     C                   movea     temp40        a40
     C     12            sub       $nadec        dpos              2 0
     C     dpos          add       2             tenpos            2 0
     C                   z-add     12            ax                2 0
     C                   z-add     40            ay                2 0
     C     lna01         tag
     C                   sub       1             ax
     C     ax            cabeq     0             ena01
     C     ax            iflt      tenpos
     C                   move      a40(ax)       a40(ay)
     C                   sub       1             ay
     C                   else
     C     a40(ax)       ifgt      '0'
     C                   move      a40(ax)       a40(ay)
     C                   sub       1             ay
     C                   z-add     99            tenpos
     C                   endif
     C                   endif
     C     ax            ifeq      dpos
     C                   move      '.'           a40(ay)
     C                   sub       1             ay
     C                   endif
     C                   goto      lna01
     C     ena01         tag
     C                   z-add     28            ax
     C     lna02         tag
     C                   add       1             ax
     C     ax            comp      41                                     50
     C   50              goto      ena02
     C     a40(ax)       comp      '0'                                    50
     C  N50a40(ax)       comp      ' '                                    50
     C  N50              goto      ena02
     C                   move      ' '           a40(ax)
     C                   goto      lna02
     C     ena02         tag

     C                   movea     a40(29)       a12
     C     ax            ifgt      40
     C                   z-add     12            $nafp             2 0
     C     ax            sub       28            $nafp
     C                   endif

     C                   z-add     0             $nanum           11 0
     C                   z-add     0             $nadec            2 0
     C                   endsr
     *----------------------------------------------------------------
650bA*  ZZINZ2   Program initialization. Called from main line.
650bA*----------------------------------------------------------------
650bAC     zzinz2        begsr
650bA

650bA*   Define key for CLAMMSC file.

650bAC     clmkey        klist
650bAC                   kfld                    $pwhse
650bAC                   kfld                    $plic#

650bA*   Get CLAMMSC data.

650bAC     clmkey        chain     clammsc

650bAC                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Ouput Spec
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     Otagfmtpr  e            #str           1
     O                       @outpt             198

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Compile time tables
     *----------------------------------------------------------------
     *----------------------------------------------------------------

**   OVRPRTF statment
OVRPRTF FILE(TAGFMTPR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
