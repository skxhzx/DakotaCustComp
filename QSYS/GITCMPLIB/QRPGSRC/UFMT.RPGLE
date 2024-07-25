      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UFMT         Print UPC barcodes on zebra printer
     *  27 October, 2017
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    10/27/17  JCJ  7.1
     *      - Created from RFMT
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Flblfmth   if   e           k disk
     Flblfmtd   if   e           k disk
     Flblfmtv   if   e           k disk
     Flblfmtt   if   e           k disk
     Foptions   if   e           k disk
     FReports   if   e           k disk
     Fupc       if   e           k disk
     Fufmtpr    o    f  198        printer oflind(*IN90)
     F                                     usropn
      *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a12             s              1    dim(12)
     D a40             s              1    dim(40)
     D a50             s              1    dim(50)
     D a58             s              1    dim(58)
     D a80             s              1    dim(80)
     D sti             s              1    dim(75)
     D sto             s              1    dim(198)
     D ovrprt          s             80    DIM(1) CTDATA PERRCD(1)

      *----------------------------------------------------------------
      *  Called programs
      *----------------------------------------------------------------
     D @CVTDT          C                   CONST('CVTDTE')
      *----------------------------------------------------------------
      *  Called program parameters
      *----------------------------------------------------------------
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
     *  Program parameters
     *
     *
     *   Redefine key
     *
     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $pdesc          s             30
     D work17a         s             17
     D worklcns        s             15
     D $pitem          s             15
     D $ppdsc          s             15
     D $pupc           s             15
     D $pvitm          s             15
     D $posslcns       s             15
     D $pdisp          s             12
     D $ppslt          s             12
     D $pven           s             11  0
     D $pdev           s             10
     D $pform          s             10
     D $imbrnd         s             10
     D $ppo            s              9
     D $pcmd           s              8
     D $plfmt          s              8    inz('UPC')
     D curdate         s              8  0
     D $plset          s              6    inz('ZBRCDI')
     D wktihi          s              7
     D $ptrn#          s              7  0
     D $prcvd          s              6  0
     D $pexpd          s              6  0
     D $pwhdp          s              5
     D $pqty           s              5  0
     D $ptie           s              4  0
     D $pwhse          s              3  0
     D $pum            s              2
     D $phigh          s              2  0
     D $pstyp          s              1

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D                 ds
     D  $ec                    1      2p 0
     *
     D                 ds
     D  dssdte                 1      6
     D  dsmm                   1      2
     D  dsdd                   3      4
     D  dsyy                   5      6
     *
     D                 ds
     D  wksdte                 1      8
     D  wkmm                   1      2
     D  wksl1                  3      3
     D  wkdd                   4      5
     D  wksl2                  6      6
     D  wkyy                   7      8
      *----------------------------------------------------------------
     D opdata          DS
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opten2               117    117
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
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
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C*    *entry        plist
     C*                  parm                    $pcmd             8
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C     keylfh        chain     lblfmth
     C                   if        not %found
     C                   eval      lfhslg = *blanks
     C                   goto      bottom
     C                   endif
     * Open printer file
     C                   exsr      opnprt
     *
     * Check to see if this is only a test.
     *
     C                   if        $pcmd = '*TEST1  '
     C                   exsr      test1
     C                   goto      bottom
     C                   endif
     *
     * Print Putaway label
     *
     C                   exsr      prtupc
     *
     C     bottom        tag
     C                   eval      *inlr = *on
     *
     * Close up shop and return home.
     *
     CLR                 if        opened = *on
     CLR                 close     ufmtpr
     CLR                 endif
     *
     CLR                 return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *   Define key for LBLFMTH
     *
     C     keylfh        klist
     C                   kfld                    $plset
     *
     *   Define key for LBLFMTD file.
     *
     C     *like         define    lfdfmt        kyfmt
     C     keylfd        klist
     C                   kfld                    $plset
     C                   kfld                    kyfmt
     *
     *   Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     *  Define key for REPORTS file.
     *
     C     Rpkey         Klist
     C                   Kfld                    Wkprtf           10
     *
     *  Define key for LBLFMTV file.
     *
     C     *like         define    lfvnum        kyvnum
     C     keylfv        klist
     C                   kfld                    kyvnum
     * Convert today's date into century format.
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     *
     *   Get system options
     *
     C                   z-add     0             opwhse
     C                   move      '*SYSTEM '    opcode
     C
     C     opkey         chain     options                            79
     C                   if        *in79 = *on
     C                   eval      opletd = 'Y'
     C                   endif

     *
     *   Get report device and form.
     *

     c                   eval      wkprtf = 'UFMTPR'
     C                   MOVE      *BLANKS       wkdev            10
     C                   MOVE      *BLANKS       wkform           10
     C     Rpkey         Chain     Reports
     C                   If        %Found
     C                   Movel     RPDEV         wkdev
     C                   Movel     RPFORM        wkform
     C                   Else
     C                   eval      wkdev = '*JOB      '
     C                   eval      wkform = '*STD      '
     C                   Endif
     C
     C                   Move      *On           Forevr            1
     C                   Move      *Off          opened            1
     C                   z-add     75            maxsti            2 0
     C                   z-add     198           maxsto            3 0
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  OPNPRT   Open printer file.
     *
     C     opnprt        begsr
     *
     C                   if        opened <> *on
     C                   movea     ovrprt(1)     a80
     C                   movea     wkdev         a80(37)
     C                   movea     wkform        a80(58)
     C                   movea     a80           qcmd
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     * Open printer file
     C                   open      ufmtpr
     C                   eval      opened = *on
     *
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  PRINT    Output string to printer.
     *
     C     print         begsr
     *
     C                   move      *off          prtflg            1
     C                   movea     sto           @outpt          198
     C                   except    #str
     C                   eval      sto = *blanks
     C                   z-add     0             op
     *
     C                   endsr
     *

     *----------------------------------------------------------------
     *  PRTUPC  Print UPC label
     *----------------------------------------------------------------

     C     prtupc        begsr

710aAC                   eval      kyfmt = $plfmt
     C                   dou       forevr <> forevr

     C                   read      upc
     C                   if        %eof(upc)
     C                   leave
     C                   endif

     C                   if        upupc <> *blanks
     C                   exsr      fillb1
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  FILLB1   Process script for single label format.
     *----------------------------------------------------------------
     C     fillb1        begsr
     *
     C                   eval      sto = *blanks
     C                   z-add     0             op                3 0
     *
     C     keylfd        setll     lblfmtd
     C     forevr        doweq     forevr
     C     keylfd        reade     lblfmtd
     C                   if        %eof(lblfmtd)
     C                   leave
     C                   endif
     *
     C                   if        lfdstr = *blanks
     C                   iter
     C                   endif
     *
     C                   movea     lfdstr        sti
     C                   z-add     0             ip                3 0
     *
     C                   move      *off          vflag             1
     C                   z-add     0             @var              3 0
     C                   z-add     0             @len              3 0
     *
     * Loop through each character of label.
     *
     C     1             do        maxsti        ip                3 0
     *
     C                   select
     *
     *      Beginning of variable.
     *
     C     sti(ip)       wheneq    '<'
     C     $pcmd         andne     '*TEST1  '
     C                   if        vflag = *on
     C                   exsr      fillb2
     C                   endif
     C                   eval      vflag = *on
     C                   z-add     0             @var
     C                   z-add     1             @len
     *
     *      End of variable.
     *
     C     sti(ip)       wheneq    '>'
     C     vflag         andeq     *on
     C                   add       1             @len
     C                   exsr      fillb2
     C                   eval      vflag = *off
     *
     *      Within variable.
     *
     C     vflag         wheneq    *on
     C                   add       1             @len
     *
     *      Extract variable id number
     *
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
     *
     *      Not within variable - Move character to output string
     *
     C                   other
     C                   add       1             op
     C                   move      sti(ip)       sto(op)
     C     op            ifeq      maxsto
     C                   exsr      print
     C                   endif
     *
     C                   endsl
     *
     C                   enddo
     *
     *      Output variable if necessary.
     *
     C     vflag         ifeq      *on
     C                   exsr      fillb2
     C                   endif
     *
     C                   exsr      print
     *
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *  FILLB2   Added variable to output string.
     *----------------------------------------------------------------
     C     fillb2        begsr
     *
     C     $pcmd         ifeq      '*TEST2  '
     C                   z-add     @var          kyvnum
     C     keylfv        chain     lblfmtv                            78
     C     *in78         cabeq     *on           endfi2
     C                   endif
     *
     C                   select
     *  Pick slot
700aDC*    @var          wheneq    4
700aMC     @var          wheneq    412
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $ppslt        a50
     C                   endif
     C                   exsr      filchr
     *  Exp date
     C     @var          wheneq    5
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      $pexpd        dssdte
     C                   move      dsmm          wkmm
     C                   move      '/'           wksl1
     C                   move      dsdd          wkdd
     C                   move      '/'           wksl2
     C                   move      dsyy          wkyy
     C                   move      *blanks       a50
     C                   movea     wksdte        a50
     C                   endif
     C                   exsr      filchr
     *  Transaction number
     C     @var          wheneq    10
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         $nanum
     C                   else
     C                   move      $ptrn#        $nanum
     C                   endif
     C                   z-add     0             $nadec
     C                   exsr      filnum
     *  Slot number
     C     @var          wheneq    11
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $pdisp        a50
     C                   endif
     C                   exsr      filchr
     *  Quantity
     C     @var          wheneq    12
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         $nanum
     C                   else
     C                   move      $pqty         $nanum
     C                   endif
     C                   z-add     0             $nadec
     C                   exsr      filnum
     *  Unit of measure
     C     @var          wheneq    13
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $pum          a50
     C                   endif
     C                   exsr      filchr
     *  Tie/High
     C     @var          wheneq    14
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   eval      wktihi    = %trim(%editc($ptie:'Z'))
     C                                       + '/'
     C                                       + %trim(%editc($phigh:'Z'))
     C                   move      *blanks       a50
     C                   movea     wktihi        a50
     C                   endif
     C                   exsr      filchr
     *  Pack description
     C     @var          wheneq    15
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $ppdsc        a50
     C                   endif
     C                   exsr      filchr
     *  Description
     C     @var          wheneq    16
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $pdesc        a50
     C                   endif
     C                   exsr      filchr
     *  Item number
     C     @var          wheneq    17
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     upitem        a50
     C                   endif
     C                   exsr      filchr
     *  Receive date
     C     @var          wheneq    20
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      $prcvd        dssdte
     C                   move      dsmm          wkmm
     C                   move      '/'           wksl1
     C                   move      dsdd          wkdd
     C                   move      '/'           wksl2
     C                   move      dsyy          wkyy
     C                   move      *blanks       a50
     C                   movea     wksdte        a50
     C                   endif
     C                   exsr      filchr
     *  Vendor number
     C     @var          wheneq    58
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         $nanum
     C                   else
     C                   move      $pven         $nanum
     C                   endif
     C                   z-add     0             $nadec
     C                   exsr      filnum
     *  PO number
700aDC*    @var          wheneq    88
700aMC     @var          wheneq    415
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $ppo          a50
     C                   endif
     C                   exsr      filchr
     *  Vendor Item number
     C     @var          wheneq    97
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $pvitm        a50
     C                   endif
     C                   exsr      filchr
     *  UPC
     C     @var          wheneq    100
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $pupc         a50
     C                   endif
     C                   exsr      filchr
     *  Department
     C     @var          wheneq    103
     C     $pcmd         ifeq      '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $pwhdp        a50
     C                   endif
     C                   exsr      filchr
     *
     *  Generic 20-Char field - UPC
     *    @VAR = 320
     C                   when      @var = 320
     C                   movea(p)  *blanks       a50
     C                   movea(p)  upupc         a50
     C                   exsr      filchr
     *
     C                   endsl
     *
     C     endfi2        endsr
     *
     *----------------------------------------------------------------
     *  FILCHR   Fill character variable.
     *----------------------------------------------------------------
     C     filchr        begsr
     *
     *  Move character string into output string.
     *
     C                   z-add     @len          lc                3 0
     C     1             do        lc            y                 3 0
     C                   add       1             op
     C                   move      a50(y)        sto(op)
     C     op            ifeq      maxsto
     C                   exsr      print
     C                   endif
     C                   enddo
     *
     C                   endsr

     *
     *----------------------------------------------------------------
     *  FILLNUM  Fill numeric variable.
     *----------------------------------------------------------------
     C     filnum        begsr
     *
     *  Format number.
     *
     C                   exsr      editna
     *
     *  Find first character in array string.
     *
     C                   z-add     1             fc                3 0
     C     fc            doueq     13
     C     a12(fc)       ifne      *blanks
     C                   leave
     C                   endif
     C                   add       1             fc
     C                   enddo
     *
     *  Move formatted number into output string.
     *
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
     *
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
     *
     C                   movea     a40(29)       a12
     C     ax            ifgt      40
     C                   z-add     12            $nafp             2 0
     C     ax            sub       28            $nafp
     C                   endif
     *
     C                   z-add     0             $nanum           11 0
     C                   z-add     0             $nadec            2 0
     C                   endsr

     *
     *----------------------------------------------------------------
     *
     *  TEST1    Test 1 - Print label definitions
     *
     C     test1         begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINIT   Initialize fields.
     *
     C     zzinit        begsr
     *
     C                   endsr
     O*----------------------------------------------------------------
     O*  Output Specs
     O*
     Oufmtpr    e            #str           1
     O                       @outpt             198
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**   OVRPRTF statment
OVRPRTF FILE(UFMTPR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
