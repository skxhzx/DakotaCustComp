500 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  WR310        Print Repack label
     *  13 April, 2010
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    04/13/10  JCJ  5.30
     *      - Created.
760aA*    03.04/22  JCJ  7.60a
     *      - Enh: added Work order#, pack description, Ref note to
     *        repack label.
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
     Fzbrlogf   uf a e           k disk
     Fzbrlogs   uf a e           k disk
     Fpfmtpr    o    f  198        printer oflind(*in90)
     F                                     usropn
610aAFslot2     if   e           k disk
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

     D curdate         s              8  0
     D k               s              5  0
     D @var            s              3  0
     D @len            s              3  0
     D ln              s              3  0
     D i               s              3  0
     D j               s              3  0
     D @qty1           s              1  0 inz(1)
     D wrkdate         s              8
     D wrklcn#         s             30
     D $pitem          s             15
     D cwdqtyfld       s             15
     D wkprtf          s             10
     D wkform          s             10
     D wkdev           s             10
760aAD temp70          s              7  0
     D temp7a          s              7
     D temp2a          s              2
     D vflag           s              1
     D logzebra        s               n
     D forever         s               n
     D GoodHit         s              1    Inz('0')
     D $pszon          s              6    Inz('XXXXXX')

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
610aAD                 ds
610aAD  wkdesc                 1     30
610aAD  wkd1to9                1      9
610aAD  wkd10to18             10     18
610aAD  wkd1to7                1      7
610aAD  wkd8to16               8     16
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
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $plset            6
     C                   parm                    $plfmt            8
     C                   parm                    $copies           5 0
     C                   parm                    $pwhse            3 0
     C                   parm                    $pdisp           12
     C                   parm                    $pdesc           30
     C                   parm                    $pitem           15
     C                   parm                    $pdate            8
     C                   parm                    $plcn#           15
     C                   parm                    $po              15
     C                   parm                    $pshrt            5
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
760aAC                   parm                    $word             7 0
760aAC                   parm                    $lpdsc           15
760aAC                   parm                    $lhref           15
     *
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
     *
     * Do zbrlog initialization
     *
     C                   exsr      zzzInzZbrLog
     *
     C     keylfh        chain     lblfmth
     C                   if        not %found
     C                   eval      lfhslg = *blanks
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
     C                   for       k = 1 to $copies
     *
     C                   select
     * Print Pallet Label
     C                   when      $plfmt = 'REPACK  '
     C                   eval      kyfmt = $plfmt
     C                   exsr      fillb1
     *
     C                   endsl
     *
     C                   endfor
     *
     C     bottom        tag
520aAC                   select
520aAC                   when      $pcmd = '*REPACK '
     C                   eval      *inlr = *on
     *
     * Close up shop and return home.
     *
     C                   if        opened = *on
     C                   close     pfmtpr
     C                   endif
     *
520aAC                   when      $pcmd <> '*REPACK '
     C                   return
     C                   endsl
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
     *  Define partial key for ZBRLOGF/S files.
      *
     C     keyzbr        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid            5
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

     C                   eval      wkprtf = 'PFMTPR    '
     C                   eval      wkform = $pform
     C                   eval      wkdev = $pdev
     C
     C                   Move      *On           Forevr            1
     C                   Move      *Off          opened            1
     C                   z-add     75            maxsti            2 0
     C                   z-add     198           maxsto            3 0
     *
     *  Get zebra logging flag.
     *
     C     *DTAARA       define    zbrlog        logzebra
     C                   in(e)     logzebra
     C                   if        %error
     C                   eval      logzebra = *off
     C                   endif
     *
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
     C                   open      pfmtpr
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

     *----------------------------------------------------------------
     *  FILLB1   Process script for single label format.
     *----------------------------------------------------------------
     C     fillb1        begsr
     *
     C                   eval      sto = *blanks
     C                   z-add     0             op                3 0
     *
     C                   eval      GoodHit = '0'
     *
     *   Initialize zebra logging fields.
     *
     C                   eval      zfwhse = $pwhse
     C                   eval      zfrte  = *blanks
     C                   eval      zfrtid = *blanks
     C                   eval      zfseq# = zfseq# + 1
     C                   eval      zfline = *zeros
     C                   eval      zflset = $plset
     C                   eval      zflfmt = kyfmt
     C                   eval      zftrn# = *zeros
     C                   eval      zflbl# = *zeros
     C                   eval      zfcomp = *blanks
     C                   eval      zftzon = *blanks
     C                   eval      zfgen  = *zeros
     C                   eval      zfszon = $pszon
     C                   eval      zftruk = *blanks
     C                   eval      zffnum = 0
     C                   eval      zffnam = ' '
     C                   eval      zffval = ' '
     C                   time                    zfts
      *
     C                   eval      zswhse = $pwhse
     C                   eval      zsrte  = *blanks
     C                   eval      zsrtid = *blanks
     C                   eval      zsseq# = zsseq# + 1
     C                   eval      zsline = *zeros
     C                   eval      zslset = $plset
     C                   eval      zslfmt = kyfmt
     C                   eval      zstrn# = *zeros
     C                   eval      zslbl# = *zeros
     C                   eval      zscomp = *blanks
     C                   eval      zstzon = *blanks
     C                   eval      zsgen  = *zeros
     C                   eval      zsszon = $pszon
     C                   eval      zstruk = *blanks
     C                   eval      zsparm = ' '
     C                   eval      zsts   = zfts
     *
     C     keylfd        setll     lblfmtd
     C     forevr        doweq     forevr
     C     keylfd        reade     lblfmtd
     C                   if        %eof(lblfmtd)
     C                   leave
     C                   endif
     *
     C                   eval      GoodHit = '1'
     *
     C                   if        lfdstr = *blanks
     C                   iter
     C                   endif
     *
     C                   movea     lfdstr        sti
     C                   z-add     0             ip                3 0
     *
     C                   eval      vflag = *off
     C                   eval      @var = *zeros
     C                   eval      @len = *zeros
     *
     * Loop through each character of label.
     *
     C     1             do        maxsti        ip                3 0
     *
     C                   select
     *
     *      Beginning of variable.
     *
     C                   when      sti(ip) = '<'
     C                             and  $pcmd <> '*TEST1  '
     C                   if        vflag = *on
     C                   exsr      fillb2
     C                   endif
     C                   eval      vflag = *on
     C                   eval      @var = *zeros
     C                   eval      @len = 1
     *
     *      End of variable.
     *
     C                   when      sti(ip) = '>'
     C                             and  vflag = *on
     C                   add       1             @len
     C                   exsr      fillb2
     C                   eval      vflag = *off
     *
     *      Within variable.
     *
     C                   when      vflag = *on
     C                   add       1             @len
     *
     *      Extract variable id number
     *
     C                   select
     C                   when      @len = 2
     C                             and  sti(ip) > '0'
     C                             and  sti(ip) <= '9'
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
     *   Write ZBRLOGS record.
     *
     C                   if        logzebra and GoodHit = '1'
     C                   write(e)  zsrec
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *  FILLB2   Added variable to output string.
     *----------------------------------------------------------------
     C     fillb2        begsr
     *
     *   Initialize zebra logging fields.
     *
     C                   eval      zffnum = @var
     C                   eval      zffnam = ' '
     C                   eval      zffval = ' '
     *
     C                   if        $pcmd = '*TEST2  '
     C                   eval      kyvnum = @var
     C     keylfv        chain     lblfmtv
     C                   if        not %found(lblfmtv)
     C                   goto      endfi2
     C                   endif
     C                   endif
     *
     C                   select
     * Slot
     C                   when      @var = 11
     C                   eval      zffnam = 'SLOT'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  $pdisp        a50
     C                   endif
     C                   exsr      filchr
     *
760aA* Pack Description
     *
     C                   when      @var = 15
     C                   eval      zffnam = 'PACK'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     c                   movea(p)  $lpdsc        a50
     C                   endif
     C                   exsr      filchr
     *
     * Item Desc
     C                   when      @var = 16
     C                   eval      zffnam = 'DESC'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  $pdesc        a50
     C                   endif
     C                   exsr      filchr
     * Item
     C                   when      @var = 17
     C                   eval      zffnam = 'ITEM'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  $pitem        a50
     C                   endif
     C                   exsr      filchr
     * Date
     C                   when      @var = 20
     C                   eval      zffnam = 'DATE'
     C                   movea(p)  $pdate        a50
     C                   exsr      filchr
     *
760aA*  Country of Origin
     *
     C                   when      @var = 73
     C                   eval      zffnam = 'DESC'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   movea(p)  $lhref        a50
     C                   endif
     C                   exsr      filchr
     *
760aA*  Work Order number
     *    @VAR = 107
     *
     C                   when      @var = 107

     C                   eval      zffnam = 'WkOrd'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   z-add     $word         temp70
     C                   eval      temp7a = %char(temp70)
     C                   endif
     C                   movea(p)  temp7a        a50
     C                   exsr      filchr
     *
     * License number
     *
     C                   when      @var = 173
     C                   eval      zffnam = 'License'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $plcn#        a50
     C                   endif
     C     ' '           checkr    $plcn#        ln
     C                   if        ln > *zeros
     C                   eval      @len = ln
     C                   endif
     C                   exsr      filchr
     * Purchase Order
     C                   when      @var = 311
     C                   eval      zffnam = 'P/O'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        A50
     C                   else
     C                   movea(p)  *blanks       a50
     C                   movea(p)  $po           a50
     C                   endif
     C                   exsr      filchr
     *
     *  Create Combined Qty field.
     *    @VAR = 315
     C                   when      @var = 315
     C                   eval      zffnam = 'Qty'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        A50
     C                   else

     C                   movea(p)  *blanks       A50
     C                   eval      @qty1 = 1
     C                   eval      cwdqtyfld = *blanks
     C                   eval      cwdqtyfld = %trim(%editc(@qty1:'4'))
     C                                         + ' '
     C                                         + %trim($pshrt)
     C                   movea(p)  cwdqtyfld     a50
     C                   endif
     C                   EXSR      FILCHR
     *
     C                   endsl
     *
     *   Write ZBRLOGF record.
     *
     C                   if        logzebra
     C                   write(e)  zfrec
     C                   endif
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
     *   Move value into ZBRLOGF log field
     *
     C                   if        logzebra
     C                   movea     a50           temp50a          50
     C                   eval      zffval = %trim(temp50a)
     C                   endif
      *
      *   Add field to ZBRLOGS log field.
      *
     C                   if        logzebra
     C                   eval      zsparm = %trim(zsparm)
     C                                    + ' <'
     C                                    + %trim(%editc(@var:'Z'))
     C                                    + ':'
     C                                    + %trim(zffnam)
     C                                    + '>'
     C                                    + %trim(zffval)
     C                   endif
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

     *----------------------------------------------------------------
     *  zzzInzZbrLog  Initialization for zbrlog.
     *
     C     zzzInzZbrLog  begsr

     *  Get out if not logging.

     C     logzebra      cabeq     *off          endInzZbrLog

     *  Delete existing zbrlogf records for route/szone

     C     keyzbr        setll     zbrlogf
     C                   dow       forever = forever
     C     keyzbr        reade(e)  zbrlogf
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        zfszon <> $pszon
     C                   iter
     C                   endif
     C                   delete    zfrec
     C                   enddo

     *  Delete existing zbrlogs records for route/szone

     C     keyzbr        setll     zbrlogs
     C                   dow       forever = forever
     C     keyzbr        reade(e)  zbrlogs
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        zsszon <> $pszon
     C                   iter
     C                   endif
     C                   delete    zsrec
     C                   enddo

     *  Initialize sequence number.

     C                   eval      zfseq# = 0

     C     endInzZbrLog  endsr
     O*----------------------------------------------------------------
     O*  Output Specs
     O*
     Opfmtpr    e            #str           1
     O                       @outpt             198
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**   OVRPRTF statment
OVRPRTF FILE(PFMTPR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
