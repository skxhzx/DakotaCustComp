      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *  P.O. Box 1957
     *  Batavia, IL 60510
     *  (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LB401   Produce Labels - Processing
     *  17 August 2009
     *  Ginger Andrews
     *
     *----------------------------------------------------------------
     *  Revisions
     *
610aA*    08/17/09  GJA  6.10a
     *      - Created
610bA*    09/24/09  GJA  6.10b
     *      - Enh:  Create one spool file instead of individual
     *              spool files for each produce label
650aA*    01/23/14  RH   6.50
     *      - Fix: Add missing previous 610b code.
710a *    10/05/17  RTR  7.10a
     *      - Fix: Change variable i from 3,0 to 5,0. When qty>999 it
     *        was blowing up.
710bA*    10/25/17  JCJ  7.10b
     *      - Enh: Add Date to label.
     *
720a *    10/10/18  DAS  7.20a
     *      - Fix: Added optional parameters for item and qty.
     *
730a *    02/11/19  LMC  7.30a
     *      - Fix: If item and qty are sent in, do not loop thru
     *        anymore podtl records once the item has been found.
     *        Otherwise we get multiple sets of labels, if the item
     *        is on the po multiple times.
     *
740bA*    07/03/20  MLB  7.40b  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Saval
     *
SVLaA*    08/17/09  GJA  SVLa
     *      - Restricted produce labels for quantity < 25
SVLbA*    11/01/16  MLB  SVLb
     *      - Removed > 25 restriction from pgm per Gary P email
     *        dated 11/01/2016. Other portions of mods not touched.
SVLcA*    06/07/19  JCJ  SVLc
     *      - Changed label set name to ZBRSV2 for 300dpi printer
     *        Change.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Isupply
     *
ISPaA*    12/20/10  GJA  ISPa
     *      - Setup label format
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - TPC
     *
TPCbA*    05/10/19  RBD  TPCb
     *      - Pass PO due date in $pindt.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Earls Organic Produce
     *
EOPaA*    10/15/18  LMC  EOPa
     *      - Setup label format
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (Reverse Display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
TPCbAFpohdr     if   e           k disk
     Fpodtl     if   e           k disk
     Fpiritem   if   e           k disk
     FReports   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

740bMD @prtpg          c                   const('BFCPRTLBL')
ISPaMD @lblset         c                   const('ZBRISP')
     D @plfmtr         c                   const('RETURNS')
710bAD @cvtdt          c                   const('CVTDTE')
     *
710bAD $cvtdt          ds
710bAD  $cvcmd                 1      8
710bAD  $cvprg                 9     18
710bAD  $cvd6i                19     24
710bAD  $cvd8i                25     32
710bAD  $cvd6o                33     38  0
710bAD  $cvd8o                39     46  0
710bAD  $cvsto                47     64
710bAD  $cvrtn                65     72
710bAD  $cverm                73    132
710bAD  $cvmsg                73     76
710bAD  $cvdr1               133    140
710bAD  $cvvl1               141    145  0
710bAD  $cvdr2               146    153
710bAD  $cvvl2               154    158  0
710bAD  $cvdr3               159    166
710bAD  $cvvl3               167    171  0
710bAD  $cvdr4               172    179
710bAD  $cvvl4               180    184  0

     *----------------------------------------------------------------
     *  Program parameters
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
     D  $licns                22     36
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D                 ds
     D  $ec                    1      2p 0
710bA*
710bAD                 ds
710bAD  zksdte                 1      6  0
710bAD  zkmm                   1      2  0
710bAD  zkdd                   3      4  0
710bAD  zkyy                   5      6  0
710bA*
710bAD                 ds
710bAD  pkdate                 1      8
710bAD  pkmm                   1      2
710bAD  pkds1                  3      3
710bAD  pkdd                   4      5
710bAD  pkds2                  6      6
710bAD  pkyy                   7      8
710bA*
TPCbAD                 ds
TPCbAD  phdateX                1      8
TPCbAD  phyy                   3      4
TPCbAD  phmm                   5      6
TPCbAD  phdd                   7      8
TPCbA*
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
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
SVLaA /COPY QCOPYSRC,id#saval
ISYaA /COPY QCOPYSRC,id#isupply
TPCaA /COPY QCOPYSRC,id#tpc
EOPaA /COPY QCOPYSRC,id#eop

     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D $plen           s              3  0
     D $pstr           s             60
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D forevr          s               n
710aDD*i               s              3  0
710aMD i               s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D warn            s              1
     D wkprtf          s             10
     D wkwhse          s              3  0
     D work1a          s              1
710bAD today           s              8  0
720aAD printQty        s                   like(pdqor1)
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse  - warehouse
     *      $prtn   - return
     *      $pdev   - device
     *      $pform  - form
     *      $ppo    - po number to process
720aA*      $pitem  - item (optional)
720aA*      $pqty   - qty (optional)
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3
     C                   parm                    $prtn             8
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $ppo              9
720aAC                   parm                    $pitem           15
720aAC                   parm                    $pqty             5
     *----------------------------------------------------------------
     *  Main line
     *
     C                   move      $pwhse        wkwhse
     C                   exsr      zznxt1
     *
     *
     *   Do some clean up before leaving.
     *
     C                   eval      *inlr = *on
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
     C                   eval      forevr = *off
     *  Purchase Order Detail
     C     keypo         klist
     C                   kfld                    wkwhse
     C                   kfld                    $ppo
     *  Item Number
     C     keyit         klist
     C                   kfld                    wkwhse
     C                   kfld                    pditem
710bA*
710bA*  Convert today's date into MM/DD/YY format.
710bA*
710bAC                   eval      $cvcmd = '*CURMDY '
710bAC                   call      @cvtdt
710bAC                   parm                    $cvtdt
710bAC                   eval      zksdte = $cvd6o
710bA*
710bAC                   move      zkmm          pkmm
710bAC                   eval      pkds1 = '/'
710bAC                   move      zkdd          pkdd
710bAC                   eval      pkds2 = '/'
710bAC                   move      zkyy          pkyy
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
     C                   if        $pdev='*JOB' or $pdev=*blanks
     C                   eval      wkprtf = 'PRODUCE   '
     C     wkprtf        Chain     reports
     C                   If        %Found(reports)
     C                   eval      $pdev = rpdev
     C                   eval      $pform = rpform
     C                   endif
     C                   endif
     *  Print label

     C                   eval      $plfmt = 'PRODUCE'
ISPaAC                   select
ISPaAC                   when      client = isupply
ISPaAC                   eval      $plset = 'ZBRISP'
SVLaAC                   when      client = saval
SVLcMC                   eval      $plset = 'ZBRSV2'
TPCaAC                   when      client = tpc
TPCaAC                   eval      $plset = 'ZBRTPC'
TPCbAC                   eval      phdate = 0
TPCbAC     keypo         chain     pohdr
TPCbAC                   move      phdate        phdateX
TPCbAC                   move      phmm          pkmm
TPCbAC                   eval      pkds1 = '/'
TPCbAC                   move      phdd          pkdd
TPCbAC                   eval      pkds2 = '/'
TPCbAC                   move      phyy          pkyy
     *
EOPaAC                   when      client = earls
EOPaAC                   eval      $plset = 'ZBREOP'
ISPaAC                   other
     C                   eval      $plset = 'PLBL40'
     C                   endSL
     *
     C     keypo         setll     podtl
     C                   dow       forevr = forevr
     C     keypo         reade     podtl                                  77
     C                   if        *in77
     C                   leave
     C                   else
SVLbDC*                  if        client=saval and pdqor1 > 25
SVLbDC*                  else

720aA*    See if we only want to print labels for single item
720aA
720aAC                   if        %parms >= 6
720aAC                             and $pitem <> '' and pditem <> $pitem
720aAC                   iter
720aAC                   endif

720aA*    See if qty was sent in
720aA
720aAC                   if        %parms < 7
720aAC                   eval      printQty = pdqor1
720aAC                   else
720aAC                   monitor
720aAC                   eval      printQty = %dec($pqty:5:0)
720aAC                   if        printQty <= 0
720aAC                   eval      printQty = pdqor1
720aAC                   endif
720aAC                   on-error
720aAC                   eval      printQty = pdqor1
720aAC                   endmon
720aAC                   endif

     C     keyit         chain     piritem
     C                   if        %found

720aDC**                 for       i = 1 to pdqor1
720aMC                   for       i = 1 to printQty
     C                   call      @prtpg
     C                   parm      '*PRODUCE'    $pcmd             8
     C                   parm                    $plset            6
     C                   parm                    $plfmt            8
     C                   parm      wkwhse        $plwhse           3 0
     C                   parm                    $pwhsd           30
     C                   parm      itwhdp        $slwhdp           5
     C                   parm                    $sldisp          12
     C                   parm                    $pdispa           1
     C                   parm                    $pdispb          11
     C                   parm                    $pchkd1           3
     C                   parm                    $pchkd2           3
     C                   parm                    $pchkd3           3
     C                   parm                    wklic            15
     C                   parm                    $plcn2           15
     C                   parm      ititem        $pditem          15
     C                   parm                    $pbrnd           10
     C                   parm      itpdsc        $ppdesc          15
     C                   parm      itdesc        $itdesc          30
     C                   parm      $ppo          $ptxt1           30
     C                   parm                    $ptxt2           30
     C                   parm                    $ptxt3           30
     C                   parm                    $ptrailr          8
     C                   parm                    $psize            3
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pexpda           8
710bMC                   parm      pkdate        $pindta           8
     C                   parm                    $lparm
     C                   endfor
     *  Force last record so it will close the spool
     *
610bAC                   if        i=pdqor1
610aAC                   call      @prtpg
610aAC                   parm      '*PRODEND'    $pcmd             8
610aAC                   parm                    $plset            6
610aAC                   parm                    $plfmt            8
610aAC                   parm      wkwhse        $plwhse           3 0
610aAC                   parm                    $pwhsd           30
610aAC                   parm      itwhdp        $slwhdp           5
610aAC                   parm                    $sldisp          12
610bAC                   parm                    $pdispa           1
610bAC                   parm                    $pdispb          11
610bAC                   parm                    $pchkd1           3
610bAC                   parm                    $pchkd2           3
610bAC                   parm                    $pchkd3           3
610bAC                   parm                    wklic            15
610bAC                   parm                    $plcn2           15
610bAC                   parm      ititem        $pditem          15
610bAC                   parm                    $pbrnd           10
610bAC                   parm      itpdsc        $ppdesc          15
610bAC                   parm      itdesc        $itdesc          30
610bAC                   parm      $ppo          $ptxt1           30
610bAC                   parm                    $ptxt2           30
610bAC                   parm                    $ptxt3           30
610bAC                   parm                    $ptrailr          8
610bAC                   parm                    $psize            3
610bAC                   parm                    $pdev            10
610bAC                   parm                    $pform           10
610bAC                   parm                    $pexpda           8
610bAC                   parm                    $pindta           8
610bAC                   parm                    $lparm
610baC                   endif
     C                   endif
SVLbDC*                  endif
     *
     C                   endif
730aA*    process the labels for this item only one time.
730aA
730aAC                   if        %parms >= 6
730aAC                             and $pitem <> ''
730aAC                   leave
730aAC                   endif
     C                   enddo
     *
     *
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
