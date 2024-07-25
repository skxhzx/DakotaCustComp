     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PO332     PO History Receiving Receipt
     *  Retha Davis
     *  Copied from PO330
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    12/29/10  RBD  6.40
     *      - Created.
640aA*    06/08/11  MLB  6.40a
     *      - Enh: Revised program to use PO332PR to retrieve report
     *        title from REPORTS file.
650a *    03/12/15  LMC  6.50a
     *      - Added the printing of an '*' at the end of detail1
     *      line when the quantity received is different than the
     *      quantity ordered.
700a *    06/02/16  LMC  7.00a
     *      - Enh: printer file changed to usropn - needed to work
     *        with Gui to get the printer overrides applied.
710a *    10/03/17  RH   7.10a
     *      - Enh: Add itvit# and itwhdp to print on detail5 line.
710b *    09/06/18  RH   7.10b
     *      - Enh: Add P#MEMO to print data from POHDRM
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line
     *
CLD A*    12/29/10  RBD  CLD
     *      - Added DETAIL3; printing of harvested date, location,
     *        cert#, and license for items identified as CLAMS.
CLDaA*    11/13/13  RBD  CLDa
     *      - Added DETAIL3 printing for SHUCKED items also.
CLDbA*    11/13/13  RBD  CLDb
     *      - Fix: Look for multiple licenses for an item.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Panos
PANaA*    10/03/17  RH   PANa
     *      - Added DETAIL5 to print Vend item #.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kellys
KFSaA*    09/06/18  RH   KFSa
     *      - Move Control # to P#MEMO
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  76        POHHDR  Not on file/End of file indicator
     *  77        POSPO   Not on file/End of file indicator
     *  78        PIRITEM Not on file/End of file indicator
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *  91        Print continuation line on headings
     *  92        Headings printed. Print detail 1 line.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpohhdr    if   e           k disk
710bAFpohhdrm   if   e           k disk
     Fpohdtl    if   e           k disk
     Fpohexcp   if   e           k disk
     Frcvexcp   if   e           k disk
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
     Freports   if   e           k disk
     Fpospo     if   e           k disk
CLD AFporcv     if   e           k disk
     Fpo332pr   o    e             printer oflind(*in90)
700aAF                                     usropn

     *----------------------------------------------------------------
CLD A*  DRI parameters
     *----------------------------------------------------------------
CLD A /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
CLD A*  Data Formats
     *----------------------------------------------------------------

CLD A /COPY *libl/qcopysrc,C#LICINFO

     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
CLD A /copy qcopysrc,id#citylin
PANaA /copy qcopysrc,id#pan
KFSaA /copy qcopysrc,id#kfs

     *----------------------------------------------------------------
CLD A*  Called programs
     *
CLD AD @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
CLD A*  Called program parameters
     *
CLD AD $cvtdt          ds
CLD AD  $cvcmd                 1      8
CLD AD  $cvprg                 9     18
CLD AD  $cvd6i                19     24
CLD AD  $cvd8i                25     32
CLD AD  $cvd6o                33     38  0
CLD AD  $cvd8o                39     46  0
CLD AD  $cvsto                47     64
CLD AD  $cvrtn                65     72
CLD AD  $cverm                73    132
CLD AD  $cvmsg                73     76

     *----------------------------------------------------------------
CLD A*  Data structure for harvested date
     *
CLD AD                 ds
CLD AD  hrvdte                 1      6  0
CLD AD  hrvdd                  1      2  0
CLD AD  hrvmm                  3      4  0
CLD AD  hrvyy                  5      6  0

     *----------------------------------------------------------------
CLD A*  Program info data structure
     *
CLD AD                sds
CLD AD  #prog            *proc
CLD AD  #job                 244    253
CLD AD  #user                254    263
CLD AD  #jobn                264    269
CLD AD  #jobdt               276    281  0
CLD AD  #jobtm               282    287  0
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     *  VARIABLES
     D #pwhse          s              3  0
CLD AD $pcode          s             10
CLD AD $phcat          s              1
CLD AD $phdtl          s              1
CLD AD $phhdr          s              1
     D $plen           s              3  0
     D $pstr           s             60
     D brk             s              1    inz(*off)
CLD AD ck4err          s               n
CLD AD error           s               n
     D count           s              3  0
     D eof             s              1
     D first           s               n
     D forever         s               n
     D l               s              1  0
     D m               s                   like(l)
     D r1otot1         s              7  0
     D r1otot2         s              7  0
     D r1otot3         s              7  0
     D r1rtot1         s              7  0
     D r1rtot2         s              7  0
     D r1rtot3         s              7  0
CLD AD savever#        s                   like($lnver#)
CLD AD svhdte          s              8  0
     D wkprtf          s             10
710bAD work6           s              6
700aAD wpdev           s             10
700aAD wpform          s             20
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE    -  Warehouse
     *      $PPO      -  PO number
     *
     *    Returned Parameters
     *      *NONE
     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $pwhse            3
     C                   parm                    $ppo              9
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
     C                   move      $pwhse        #pwhse
     C                   eval      phhwhs = #pwhse
     C                   eval      phhpo  = $ppo

     C     pohhky        setll     pohhdr

     C                   dow       forever = forever
     C     pohhky        reade     pohhdr                                 76
     C                   if        *in76 = *on
     C                   leave
     C                   else
     *
     * Determine if Super PO
     *
     C                   if        %subst(phhpo:1:2) = 'SP'
     C                   goto      super
     C                   endif

     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     C                   if        *in90  or
     C                             brk = *on or
     C                             first = *on
     C                   exsr      zrzero
     C                   eval      p#desc = *blanks
     C                   move      phhpo         p#desc
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *  Level 1 break - Warehouse/PO
     *
     C                   if        brk = *on
     C                   eval      l = 1
     C                   endif
     *
     *  Output Headings
     *
     C                   if        *in91  or
     C                             brk = *on or
     C                             first = *on
     C                   if        *in91 and
     C                             first <> *on
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   eval      first = *off
     C                   endif
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *  Write detail line
     *
     C     super         tag
     C     pohdky        setll     pohdtl                             79
     C                   eval      count = 0
     C                   eval      r1otot1 = 0
     C                   eval      r1otot2 = 0
     C                   eval      r1otot3 = 0
     C                   eval      r1rtot1 = 0
     C                   eval      r1rtot2 = 0
     C                   eval      r1rtot3 = 0
     C                   seton                                        61
     C                   move      *in79         eof
     *
     * Determine if Super PO
     *
     C                   if        %subst(phhpo:1:2) = 'SP'
     C                   eval      *in77 = *off
     C                   eval      puwhse = phhwhs
     C                   eval      puspo = phhpo
     * Scan through individual po's
     C     poskey        setll     pospo
     C                   dow       *in77 = *off
     C     poskey        reade     pospo                                  77
     C                   if        *in77 = *off
     C                   eval      phhpo  = pupo
     C     pohhky        chain     pohhdr                             76
     *
     C                   eval      page = 0
     C                   eval      count = 0
     C                   eval      eof = *off
     C                   eval      phhpo = pupo
     C     pohdky        setll     pohdtl                             79
     C                   exsr      zrhead
     C                   write     columns
     C                   eval      first = *off
     *
     * Print detail for each PO in Super PO
     *
     C                   dow       eof = *off
     C     pohdky        reade     pohdtl                                 79
     C                   move      *in79         eof
     C                   exsr      zzchkeof
     C                   if        not *in79
     C     poheky        setll     pohexcp                            76
     C     itmkey        chain     piritem                            78
     C                   if        *in78
     C                   eval      itdesc = *blanks
710aAC                   eval      itvit# = *blanks
710aAC                   eval      itwhdp = *blanks
     C                   endif
     C                   movel     itdesc        w1desc
     *  Display all qty fields as one string
     C                   eval      $pqty1 = phdqo1
     C                   eval      $pqty2 = phdqo2
     C                   eval      $pqty3 = phdqo3
     C                   exsr      zzqtys
     *
     C                   eval      w1ord = $pqstr
     *
     C                   eval      $pqty1 = phdqr1
     C                   eval      $pqty2 = phdqr2
     C                   eval      $pqty3 = phdqr3
     C                   exsr      zzqtys
     *
     C                   eval      w1rcv = $pqstr
     *
     C                   eval      w1wt = phdwgt
650aA /free
650aA   // if quantity received and quantity ordered are different
650aA   // we will print an '*' at the end of the line
650aA   *in62 = *off;
650aA   if w1ord <> w1rcv;
650aA     *in62 = *on;
650aA   endif;
650aA /end-free
     C                   write     detail1                              90
     C                   add       1             count
PANaAC                   if        client = panos
PANaAC                   write     detail5
PANaAC                   add       1             count
PANaAC                   endif
     C                   exsr      zztotals
     *
     C                   if        *in90
     C                   write     head1
     C                   write     head2
     C                   if        *in91 and
     C                             first <> *on
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   eval      count = 0
     C                   eval      *in90 = *off
     C                   eval      *in92 = *on
     C                   endif
     *
     C                   if        *in90
     C                   write     head1
     C                   write     head2
     C                   if        *in91 and
     C                             first <> *on
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   eval      count = 0
650aA /free
650aA   // if quantity received and quantity ordered are different
650aA   // we will print an '*' at the end of the line
650aA   *in62 = *off;
650aA   if w1ord <> w1rcv;
650aA     *in62 = *on;
650aA   endif;
650aA /end-free
     C                   write     detail1                              90
     C                   add       1             count
PANaAC                   if        client = panos
PANaAC                   write     detail5
PANaAC                   add       1             count
PANaAC                   endif
     C                   eval      *in90 = *off
     C                   eval      *in92 = *off
     C                   exsr      zztotals
     C                   endif
     C                   dow       *in76 = *off
     C     poheky        reade     pohexcp                                76
     C                   if        *in76 = *off
     C     phecod        chain     rcvexcp                            72
     C                   if        *in72 = *off
     C                   movel     redesc        w1excp
     C                   else
     C                   eval      w1excp = phecod
     C                   endif
     *  Display all qty fields as one string
     C                   eval      $pqty1 = pheqy1
     C                   eval      $pqty2 = pheqy2
     C                   eval      $pqty3 = pheqy3
     C                   exsr      zzqtys
     *
     C                   eval      w1qexc = $pqstr
     C                   write     detail2
     C                   add       1             count
     C                   endif
     C                   enddo
     *
CLD A*  If item is a CLAMS product, print DETAIL3
CLDaA*  For SHUCKED products too.
CLD AC                   if        client = cityline
CLD AC                   exsr      prtClams
CLD AC                   endif

     C                   endif
     C                   enddo
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     C                   if        *in77 = *on
     C                   write     skip1
     C                   write     foot1
     C                   endif
     C                   endif
     C                   enddo
     *
     *  If not Super PO, then process as normal
     *
     C                   else
     *
     C                   dow       eof = *off
     C     pohdky        reade     pohdtl                                 79
     C                   move      *in79         eof
     C                   exsr      zzchkeof
     C                   if        not *in79
     C     poheky        setll     pohexcp                            76
     C     itmkey        chain     piritem                            78
     C                   if        *in78
     C                   eval      itdesc = *blanks
710aAC                   eval      itvit# = *blanks
710aAC                   eval      itwhdp = *blanks
     C                   endif
     C                   movel     itdesc        w1desc
     *  Display all qty fields as one string
     C                   eval      $pqty1 = phdqo1
     C                   eval      $pqty2 = phdqo2
     C                   eval      $pqty3 = phdqo3
     C                   exsr      zzqtys
     *
     C                   eval      w1ord = $pqstr
     *
     C                   eval      $pqty1 = phdqr1
     C                   eval      $pqty2 = phdqr2
     C                   eval      $pqty3 = phdqr3
     C                   exsr      zzqtys
     *
     C                   eval      w1rcv = $pqstr
     C                   eval      w1wt = phdwgt
     *
650aA /free
650aA   // if quantity received and quantity ordered are different
650aA   // we will print an '*' at the end of the line
650aA   *in62 = *off;
650aA   if w1ord <> w1rcv;
650aA     *in62 = *on;
650aA   endif;
650aA /end-free
     C                   write     detail1                              90
     C                   add       1             count
PANaAC                   if        client = panos
PANaAC                   write     detail5
PANaAC                   add       1             count
PANaAC                   endif
     C                   exsr      zztotals
     *
     C                   if        *in90
     C                   write     head1
     C                   write     head2
     C                   if        *in91 and
     C                             first <> *on
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   eval      count = 0
     C                   eval      *in90 = *off
     C                   eval      *in92 = *on
     C                   endif
     *
     C                   if        *in90
     C                   write     head1
     C                   write     head2
     C                   if        *in91 and
     C                             first <> *on
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   eval      count = 0
650aA /free
650aA   // if quantity received and quantity ordered are different
650aA   // we will print an '*' at the end of the line
650aA   *in62 = *off;
650aA   if w1ord <> w1rcv;
650aA     *in62 = *on;
650aA   endif;
650aA /end-free
     C                   write     detail1                              90
     C                   add       1             count
PANaAC                   if        client = panos
PANaAC                   write     detail5
PANaAC                   add       1             count
PANaAC                   endif
     C                   eval      *in90 = *off
     C                   eval      *in92 = *off
     C                   exsr      zztotals
     C                   endif
     *
     C                   dow       *in76 = *off
     C     poheky        reade     pohexcp                                76
     C                   if        *in76 = *off
     C     phecod        chain     rcvexcp                            72
     C                   if        *in72 = *off
     C                   movel     redesc        w1excp
     C                   else
     C                   eval      w1excp = phecod
     C                   endif
     *  Display all qty fields as one string
     C                   eval      $pqty1 = pheqy1
     C                   eval      $pqty2 = pheqy2
     C                   eval      $pqty3 = pheqy3
     C                   exsr      zzqtys
     *
     C                   eval      w1qexc = $pqstr
     C                   write     detail2
     C                   add       1             count
     C                   endif
     C                   enddo
     *
CLD A*  If item is a CLAMS product, print DETAIL3
CLDaA*  For SHUCKED products too.
CLD AC                   if        client = cityline
CLD AC                   exsr      prtClams
CLD AC                   endif

     C                   endif
     C                   enddo
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     *  Set off top-of-page indicators
     *
     C     skip          tag
     C                   endif
     C                   endif
     C                   enddo
     C                   write     skip1
     C                   write     foot1
     C                   eval      *inlr = *on
700aA /free
700aA    // Close printer file.

700aA    close(e)   po332pr;
700aA    if %error;
700aA    endif;
700aA /end-free
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 2
     *
     CLr                 if        reck(l) > 0
     CLr                 write     total1
     CLr                 write     skip1
     CLr                 write     foot1
     CLr                 endif
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
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *----------------------------------------------------------------
     *
     *  Key fields
     *
     * P.O. History Header file -
     *
     C     pohhky        klist
     C                   kfld                    phhwhs
     C                   kfld                    phhpo
     *
     * P.O. History Detail file - Partial key
     *
     C     pohdky        klist
     C                   kfld                    phhwhs
     C                   kfld                    phhpo
     *
     * P.O. History Exception file - partial key
     *
     C     poheky        klist
     C                   kfld                    phdwhs
     C                   kfld                    phdpo
     C                   kfld                    phdseq
     C                   kfld                    phditm
     *
     *  Key for PIRITEM file
     C     itmkey        klist
     C                   kfld                    phdwhs
     C                   kfld                    phditm
     *
     * P.O. Super PO cross ref file key
     *
     C     poskey        klist
     C                   kfld                    puwhse
     C                   kfld                    puspo
     *
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
CLD A* PORCV - partial key
CLD A*
CLD AC     porkey        klist
CLD AC                   kfld                    phdwhs
CLD AC                   kfld                    phdpo
CLD AC                   kfld                    phdseq
     *
     *   Get report title.
     *
640aDC*                  movel     'PO330PR '    wkprtf
640aMC                   movel     'PO332PR '    wkprtf
     C                   eval      rptttl = *blanks
     C                   eval      $pstr = *blanks
     C     rpkey         chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
700aAc                   eval      wpdev = rpdev
700aAc                   eval      wpform = rpform
     C                   else
     C                   move      'PO RCPT'     $pstr
700aAc                   eval      wpdev = '*JOB'
700aAc                   eval      wpform = '*STD'
     C                   endif
     C                   eval      $plen = 40
700aAc* ovrprtf and open file
700aA /free
700aA      qcmd = 'OVRPRTF '
700aA           + 'FILE(PO332PR) '
700aA           + 'OUTQ(*DEV) '
700aA           + 'DEV(' + %trim(wpdev) + ') '
700aA           + 'FORMTYPE(' + %trim(wpform) + ') ';

700aA /end-free
700aAC                   call      'QCMDEXC'
700aAC                   parm                    qcmd             80
700aAC                   parm      80            qlen             15 5
700aA /free
700aA    // Open printer file.

700aA    open(e)   po332pr;
700aA /end-free
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *
     C                   time                    time
     C                   eval      count = 0
     C                   eval      l = 2
     C                   eval      first = *on
     C                   exsr      zrzero
     C                   endsr
     *----------------------------------------------------------------
CLD A*  clr$licinfo  Clear $licinfo data structure fields
CLD A*----------------------------------------------------------------
CLD A
CLD AC     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #user
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobn

     C                   endsr

     *----------------------------------------------------------------
CLD A*   Print license and harvest data for CLAMS products.
CLDaA*   For SHUCKED products too.
CLD A*
CLD AC     prtClams      begsr
CLD A*
CLDaM*   If not CLAMS or SHUCKED, get out.
     C                   exsr      zzgetIcat
     C                   if        $pcode <> 'CLAMS'
CLDaAC                             and $pcode <> 'SHUCKED'
     C                   goto      endprtCl
     C                   endif
     *
     *   If you find license and harvest data, print DETAIL3.
CLDbDC**   porkey        chain     porcv
CLDbDC**                 if        not %found(porcv)
CLDbDC**                 goto      endprtCl
CLDbDC**                 endif
     *
CLDbAC     porkey        setll     porcv
CLDbAC                   dow       forever = forever
CLDbAC     porkey        reade     porcv
CLDbAC                   if        %eof
CLDbAC                   leave
CLDbAC                   else
     *
     C                   exsr      clr$licinfo

     C                   eval      $lnemp# = 0
     C                   eval      $lnuser = #user
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr  = #jobn

     C                   eval      $lnwhse  = %dec($pwhse:3:0)
     C                   eval      $lntype  = 'P'
     C                   eval      $lnlcns  = porlic

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*HRVDATE'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'N'
     C                   eval      $lnvalchr(1) = *blanks
     C                   eval      $lnvalnum(1) = *Zeros

     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*HRVLOC'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'A'
     C                   eval      $lnvalchr(2) = *blanks
     C                   eval      $lnvalnum(2) = *zeros

     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*HRVCERT'
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'A'
     C                   eval      $lnvalchr(3) = *blanks
     C                   eval      $lnvalnum(3) = *zeros

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   if        $lnvalnum(1) = *zeros
     C                   eval      hrvdte = *zeros
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   z-add     $lnvalnum(1)  $cvd8o
     C                   z-add     $lnvalnum(1)  svhdte
     C                   move      $cvd8o        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      hrvdte = $cvd6o
     C                   endif

     C                   eval      clams1 = ' '
     C                   eval      clams2 = ' '
     C                   eval      clams1 = 'Lic: '
     C                                +  %Trim(porlic)
     C                                +  '   '
     C                                +  'Harvested: '
     C                                +  %TrimL(%editc(hrvdd:'P'))
     C                                +  '/'
     C                                +  %TrimL(%editc(hrvmm:'P'))
     C                                +  '/'
     C                                +  %TrimL(%editc(hrvyy:'X'))
     C                   eval      clams2 = 'Loc: '
     C                                +  %Trim($lnvalchr(2))
     C                                +  '  '
     C                                +  'Cert: '
     C                                +  %Trim($lnvalchr(3))
     C                   write     detail3
     C                   add       2             count
     *
CLDbAC                   endif
CLDbAC                   enddo
     *
     C     endprtCl      endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   if        brk = *off
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     phhwhs        chain     warehs                             79
     C                   if        not *in79
     C                   movel     whdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 30
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     *
     C                   write     head1
     C                   eval      p#desc = *blanks
     C                   eval      p#desc = 'Exported'
     C                   eval      vadr1 = %trimr(phhva1) + ' ' + (phhva2)
     C                   eval      vadr2 = %trimr(phhvct) + ', ' +
     C                             %trimr(phhvst) + '  ' + %trimr(phhvzp)
710bAC                   eval      p#memo = *blanks
KFSaA*  If Control # needed on report
KFSaAC                   if        client = kellys
KFSaAC     pohhky        chain     pohhdrm                            74
KFSaAC                   eval      work6 = *blanks
KFSaAC                   movel     phhmm5        work6
KFSaAC                   eval      p#memo = 'Control # ' + work6
KFSaAC                   endif
     * If POHHDR chain/read unsuccessful
     C                   if        *in76 = *on
     C                   eval      phhvna = *blanks
     C                   eval      vadr1  = *blanks
     C                   eval      vadr2  = *blanks
     C                   movel     '*Not found*' phhvna
     C                   endif
     C                   write     head2
     C                   eval      count = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrroll        begsr
     *
     C     l             add       1             m
     *
     C                   add       1             lvlk(m)
     C                   add       reck(l)       reck(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
CLD A*  ZZGETICAT  Get item category
CLD A*
CLD AC     zzgetIcat     begsr
CLD A
     C                   eval      $pcode = ' '
     C                   call      'GETICAT'
     C                   parm                    $pwhse
     C                   parm                    phditm
     C                   parm                    $pcode
     C                   parm                    $phhdr
     C                   parm                    $phdtl
     C                   parm                    $phcat

     C                   endsr
     *----------------------------------------------------------------
     *
     C     zzqtys        begsr
     *
     *  Display all qty fields as one string
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn             8
     C                   parm                    $perm            60
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Check if end of detail
     *
     C     zzchkeof      begsr
     *
     C                   if        eof = *on
     *
     C                   if        count > 17
     C                   eval      *in90 = *on
     C                   write     head1
     C                   write     head2
     C                   if        *in91 and
     C                             first <> *on
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   eval      *in90 = *off
     C                   eval      count = 0
     C                   endif
     *
     *  Display all qty fields as one string
     C                   eval      $pqty1 = r1otot1
     C                   eval      $pqty2 = r1otot2
     C                   eval      $pqty3 = r1otot3
     C                   exsr      zzqtys
     *
     C                   eval      w1otot = $pqstr
     *
     C                   eval      $pqty1 = r1rtot1
     C                   eval      $pqty2 = r1rtot2
     C                   eval      $pqty3 = r1rtot3
     C                   exsr      zzqtys
     *
     C                   eval      w1rtot = $pqstr
     *
     C                   write     total2
     C                   write     total1
     C                   eval      *in91 = *off
     C                   eval      r1otot1 = 0
     C                   eval      r1otot2 = 0
     C                   eval      r1otot3 = 0
     C                   eval      r1rtot1 = 0
     C                   eval      r1rtot2 = 0
     C                   eval      r1rtot3 = 0
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     C     zztotals      begsr
     *
     C                   eval      r1otot1 = r1otot1 + phdqo1
     C                   eval      r1otot2 = r1otot2 + phdqo2
     C                   eval      r1otot3 = r1otot3 + phdqo3
     *
     C                   eval      r1rtot1 = r1rtot1 + phdqr1
     C                   eval      r1rtot2 = r1rtot2 + phdqr2
     C                   eval      r1rtot3 = r1rtot3 + phdqr3
     *
     C                   endsr
     *----------------------------------------------------------------
CLD A*  zzzdricop  Call DRICOP
CLD A*----------------------------------------------------------------
CLD A
CLD AC     zzzdricop     begsr
     C                   eval      error = *off

     C                   eval      $dridata = $licinfo

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   eval      $licinfo = $dridata

     C                   eval      ck4err = *off

     C     enddricop     endsr

     *----------------------------------------------------------------
