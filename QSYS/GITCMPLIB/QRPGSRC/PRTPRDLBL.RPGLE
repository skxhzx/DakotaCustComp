      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PRTPRDLBL    Print production label on Zebra printer
     *  14 May, 2014
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650aA*    05/14/2014 JCJ  6.50a
     *      - Created.
730 A*    12/04/2019 KDE  7.30
     *      - Return missing label format error
730aA*    12/06/2019 KDE  7.30a
     *      - Tweaked some stuff for new Orpahned item label format
740 A*    03/12/2020 KDE  7.40
     *      - Increase GS1 Barcode to 50
740aA*    03/12/2020 KDE  7.40a
     *      - Added Variable 462 to SR Fillb2.
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
     Fpiritem   if   e           k disk
     Fitemdsc   if   e           k disk
     Funmesr    if   e           k disk
     fwarehs    if   e           k disk
     Fzbrlogf   uf a e           k disk
     Fzbrlogs   uf a e           k disk
     Fpfmtpr    o    f  198        printer oflind(*in90)
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
     D @getcl          C                   CONST('GETCLIENT')
     *----------------------------------------------------------------
     *  Customer id
     *
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
     D $parms          ds
     D  $pcmd2                 1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
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

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D qlen            s             15  5
     D curdate         s              8  0
     D mmddyy          s              6  0
730aAd itmuom          s             15
     D @var            s              3  0
     D @len            s              3  0
     D ln              s              3  0
     D i               s              3  0
     D j               s              3  0
     D whse            s              3  0
     D $plen           s              3  0 inz(15)
     D qcmd            s             80
     D $pstr           s             60
     D workcus         s             46
     D wrklcn#         s             30
     D whdesc          s             30
     D $cstr           s             30
     D $pitm#          s             15
     D wkprtf          s             10
     D wkform          s             10
     D wkdev           s             10
     D wrkdate         s              8
     D $pCmd           s              8
     D work6a          s              6
     D $pszon          s              6    Inz('XXXXXX')
     D work5           s              5
     D $prtid          s              5
     D temp2a          s              2
     D vflag           s              1
     D forevr          s              1
     D GoodHit         s              1    Inz('0')
     D opened          s              1    Inz('0')
     D logzebra        s               n
     D forever         s               n
     D mdy             s               D   DatFmt(*MDY)
     D yyddd           s               D   DatFmt(*JUL)

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
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     D center          pr                  extpgm('CENTER')
      * Input
     D   pStr                              like($pstr)
     D   pLen                              like($plen)
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     D adjust          pr                  extpgm('ADJUST')
      * Input
     D   pCmd                              like($pCmd)
     D   cStr                              like($cStr)
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
     C                   parm                    $pwhse            3
     C                   parm                    $pitem           15
     C                   parm                    $pslot           12
     C                   parm                    $pord             7 0
     C                   parm                    $pnote1          50
     C                   parm                    $pnote2          50
     C                   parm                    $pnote3          50
     C                   parm                    $pnote4          50
     C                   parm                    $pnote5          50
     C                   parm                    $pnote6          50
     C                   parm                    $pucode           2
740 DC*                  parm                    $pgs1fmt         48
740 MC                   parm                    $pgs1fmt         50
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pcust           46
     C                   parm                    $pdate            5
     C                   parm                    $pwgt             6
     C                   parm                    $pLcn#           15
     c                   parm                    $pCaseUCI        50
     c                   parm                    $pLotSer         30

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

640cA   whse = %dec($pwhse:3:0);

        // Do zbrlog initialization
        exsr zzzInzZbrLog;

        chain ($plset) lblfmth;
        if not %found(lblfmth);
          lfhslg = *blanks;
730aA     $pnote1='nolbl';
730aA     return;
        endif;

        // Open printer file

        exsr opnprt;

        // Check to see if this is only a test.

        if $pcmd = '*TEST1  ';
          exsr test1;
          return;
        endif;

        // Get item description

        exsr getITEMDSC;

        // Get uom

        exsr getUNMESR;

        // Print Production label

        kyfmt = $plfmt;
        exsr fillb1;

      /end-free

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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     *
     *   Define key for LBLFMTD file.
     *
     C     *like         define    lfdfmt        kyfmt
     C     keylfd        klist
     C                   kfld                    $plset
     C                   kfld                    kyfmt
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
     C                   eval      wkform = $pform
     C                   eval      wkdev = $pdev

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
     *   Verify warehouse and get description.
     *
     C                   eval      whdesc = 'Not Found'
     C*                  eval      $lcmd = '*VERIFY '
     C*                  eval      $lwhse = whse
     C*                  call      'WH900'
     C*                  parm                    $lparm
     C*                  if        $lrtn = '*ERROR  '
     C*                  eval      whdesc = 'Not Found'
     C*                  else
     C*                  movel     $lerm         whdesc
     C*                  endif
      /free
                         chain (whse) warehs;
      /end-free
     *
     C                   endsr

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
     C                   parm                    qcmd
     C                   parm      80            qlen
     * Open printer file
     C                   open      pfmtpr
     C                   eval      opened = *on
     *
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getITEMDSC  Gett Item Description Record.
     *----------------------------------------------------------------
     C     getITEMDSC    begsr

      /free

        chain (whse: $pitem) piritem;
        if not %found(piritem);
          itdesc = *blanks;
        endif;

        chain (whse: $pitem) itemdsc;
        if not %found(itemdsc);
          ixdsc1 = itdesc;
          ixdsc2 = *blanks;
        endif;

      /end-free

     C                   endsr

     *----------------------------------------------------------------
     *  getUNMESR  Get UOM Record.
     *----------------------------------------------------------------
     C     getUNMESR     begsr

      /free

        chain ($pucode) unmesr;
        if not %found(unmesr);
          umshrt = *blanks;
        endif;

      /end-free

     C                   endsr

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
     C                   eval      zfwhse = whse
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
     C                   eval      zswhse = whse
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
      /free
       begsr fillb2;

        // Initialize zebra logging fields.

        zffnum = @var;
        zffnam = ' ';
        zffval = ' ';

        if $pcmd = '*TEST2  ';
          kyvnum = @var;
          chain (kyvnum) lblfmtv;
          if not %found(lblfmtv);
            leavesr;
          endif;
        endif;

        select;

          // warehouse @var02

          when @var = 2;
            zffnam = 'Whse';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                %subarr(a50:1) = *blanks;
                  For i = 1 to %len($pwhse);
                    a50(i) = %subst($pwhse:i:1);
                  endfor;
              endif;
            exsr filchr;

          // slot @var11

          when @var = 11;
            zffnam = 'Slot';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                %subarr(a50:1) = *blanks;
                  For i = 1 to %len($pslot);
                    a50(i) = %subst($pslot:i:1);
                  endfor;
              endif;
            exsr filchr;

          // unit of measure @var13

          when @var = 13;
730aA       // set special uom for Chefs Item Label
730aA       itmuom = %trim(itum1);
730aA       if itum2<>*blanks;
730aA         itmuom = %trim(itmuom) + '/' + %trim(itum2) + '-' +
730aA                  %char(itumq2);
730aA       endif;
            zffnam = 'UM';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                %subarr(a50:1) = *blanks;
730aA             For i = 1 to %len(itmuom);
730aA               a50(i) = %subst(itmuom:i:1);
                  endfor;
              endif;
730aA       @len=10;
            exsr filchr;

          // Pack Description @var15

          when @var = 15;
            zffnam = 'PACK';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;

          // Center report title.

                $pstr = itpdsc;
                $plen = 15;
                center ($pstr: $plen);
                itpdsc = $pstr;
                %subarr(a50:1) = *blanks;
                  For i = 1 to %len(itpdsc);
                    a50(i) = %subst(itpdsc:i:1);
                  endfor;
              endif;
            exsr filchr;
     *
730aA /end-free
730aAC                   when      @var = 16
730aAC                   eval      zffnam = 'DESC'
730aAC                   if        $pcmd = '*TEST2  '
730aAC                   movea     lfvdta        a50
730aAC                   else
730aA*
730aAC                   movea(p)  itdesc        a50
730aA*
730aAC                   endif
730aAC                   exsr      filchr
      /free

          // item number  @var17

          when @var = 17;
            zffnam = 'ITEM';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                %subarr(a50:1) = *blanks;
                  For i = 1 to %len($pitem);
                    a50(i) = %subst($pitem:i:1);
                  endfor;
              endif;
            ln=%checkr(' ':$pitm#);
              if ln > *zeros;
                @len = ln;
              endif;
            exsr filchr;

          // item description @var158

          when @var = 158;
            zffnam = 'Item desc1';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;

                %subarr(a50:1) = *blanks;

          // Center report title.

                if $plfmt = 'PRODUCE';
                  $pstr = ixdsc1;
                  $plen = 40;
                  center ($pstr: $plen);
                  ixdsc1 = $pstr;
                endif;


                  For i = 1 to %len(ixdsc1);
                    a50(i) = %subst(ixdsc1:i:1);
                  endfor;
              endif;
            exsr filchr;

          // item description @var159

          when @var = 159;
            zffnam = 'Item desc2';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                %subarr(a50:1) = *blanks;
                  For i = 1 to %len(ixdsc2);
                    a50(i) = %subst(ixdsc2:i:1);
                  endfor;
              endif;
            exsr filchr;

          // License number @var173

          when @var = 182;
            zffnam = 'License';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                %subarr(a50:1) = *blanks;
                  For i = 1 to %len($plcn#);
                    a50(i) = %subst($plcn#:i:1);
                  endfor;
              endif;
            ln=%checkr(' ':$plcn#);
              if ln > *zeros;
                @len = ln;
              endif;
            exsr filchr;

          // Current date @var182

          when @var = 182;
            zffnam = 'Date';
            wrkdate = %char(curdate);
              for i = 1 to %len(wrkdate);
                a50(i) = %subst(wrkdate:i:1);
              endfor;
            exsr filchr;

          // Customer# / Customer name @var185

          when @var = 185;
            zffnam = 'Cs#/Nm';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                  for i = 1 to %len($pcust);
                    a50(i) = %subst($pcust:i:1);
                  endfor;
              endif;
            exsr filchr;

          // Lot/Serial @var322

          when @var = 322;
            zffnam = 'Lot/Sr';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                  for i = 1 to %len($pLotSer);
                    a50(i) = %subst($pLotSer:i:1);
                  endfor;
              endif;
            exsr filchr;

          // Warhouse Description @var331

          when @var = 331;
            zffnam = 'Whse/Nm';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                  for i = 1 to %len(whdesc);
                    a50(i) = %subst(whdesc:i:1);
                  endfor;
              endif;
            exsr filchr;

          // Ingredients for marinated products @var350

          when @var = 350;
            zffnam = 'Cs#/Nm';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                for i = 1 to %len($pnote1);
                  a50(i) = %subst($pnote1:i:1);
                endfor;
              endif;
            exsr filchr;

          // Ingredients for marinated products @var351

          when @var = 351;
            zffnam = 'Cs#/Nm';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                for i = 1 to %len($pnote2);
                  a50(i) = %subst($pnote2:i:1);
                endfor;
              endif;
            exsr filchr;

          // Ingredients for marinated products @var352

          when @var = 352;
            zffnam = 'Cs#/Nm';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                for i = 1 to %len($pnote3);
                  a50(i) = %subst($pnote3:i:1);
                endfor;
              endif;
            exsr filchr;

          // Ingredients for marinated products @var353

          when @var = 353;
            zffnam = 'Cs#/Nm';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                for i = 1 to %len($pnote4);
                  a50(i) = %subst($pnote4:i:1);
                endfor;
              endif;
            exsr filchr;

          // Ingredients for marinated products @var354

          when @var = 354;
            zffnam = 'Cs#/Nm';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                for i = 1 to %len($pnote5);
                  a50(i) = %subst($pnote5:i:1);
                endfor;
              endif;
            exsr filchr;

          // Ingredients for marinated products @var355

          when @var = 355;
            zffnam = 'Cs#/Nm';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                for i = 1 to %len($pnote6);
                  a50(i) = %subst($pnote6:i:1);
                endfor;
              endif;
            exsr filchr;

          // Weight @var364

         when @var = 364;
           zffnam = 'Wgt';
             if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
             else;
                %subarr(a50:1) = *blanks;
                  For i = 1 to %len($pwgt);
                    a50(i) = %subst($pwgt:i:1);
                  endfor;
              endif;
            exsr filchr;

          // Case UCI @var373

          when @var = 373;
            zffnam = 'Case/UCI';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = lfvdta;
              else;
                  for i = 1 to %len($pCaseUCI);
                    a50(i) = %subst($pCaseUCI:i:1);
                  endfor;
              endif;
            exsr filchr;

          // Julian date @var406

          when @var = 406;
            zffnam = 'Date';
              for i = 1 to %len($pdate);
                a50(i) = %subst($pdate:i:1);
              endfor;
            exsr filchr;

          // GS1-99 barcode/readable number @VAR454

740 D     When @var = 454;
            zffnam = 'GS1  ';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = $pgs1fmt;
              else;
                %subarr(a50:1) = *blanks;
                  if $pgs1fmt <> ' ';
                    for i = 1 to %len($pgs1fmt);
                      a50(i) = %subst($pgs1fmt:i:1);
                    endfor;
                  endif;
              endif;
            exsr filchr;

740aD     When @var = 462;
            zffnam = 'GS1  ';
              if $pcmd = '*TEST2  ';
                %subarr(a50:1) = $pgs1fmt;
              else;
                %subarr(a50:1) = *blanks;
                  if $pgs1fmt <> ' ';
                    for i = 1 to %len($pgs1fmt);
                      a50(i) = %subst($pgs1fmt:i:1);
                    endfor;
                  endif;
              endif;
            exsr filchr;

          endsl;

          // Write ZBRLOGF record.

          if logzebra;
            write(e)  zfrec;
          endif;

       endsr;
      /end-free

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

      /free
       begsr zzzInzZbrLog;

         // Get out if not logging.

         if not logzebra;
           leavesr;
         endif;

         // Delete existing zbrlogf records for route/szone

         setll (whse: $prtid) zbrlogf;

         dow forever = forever;
           reade(e)(whse: $prtid) zbrlogf;

           if %eof(zbrlogf);
             leave;
           endif;

           if zfszon <> $pszon;
             iter;
           endif;

           delete zfrec;
         enddo;

         // Delete existing zbrlogs records for route/szone

         setll (whse: $prtid) zbrlogs;

         dow forever = forever;
           reade(e)(whse: $prtid) zbrlogs;

           if %eof(zbrlogs);
             leave;
           endif;

           if zsszon <> $pszon;
             iter;
           endif;

           delete zsrec;
         enddo;

         // Initialize sequence number.

         zfseq# = 0;

       endsr;
      /end-free

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
