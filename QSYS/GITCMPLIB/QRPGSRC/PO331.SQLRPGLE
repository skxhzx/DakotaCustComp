      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PO331     PO Receiving Receipt - Print Wide Version
     *  January 16, 2019
     *  Rod Roller
     *
     *  Revisions
     *
730  *    01/16/19  RTR  7.30
     *      - Created from PO330, originally for Earl's Organic.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  76        POHDR   Not on file/End of file indicator
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
     Fpohdr     if   e           k disk
     Fpohdrm    if   e           k disk
     Fpodtl     if   e           k disk
     Fpoexcp    if   e           k disk
     Frcvexcp   if   e           k disk
     Fpiritem   if   e           k disk
     Fitemmsc   if   e           k disk
     Fwarehs    if   e           k disk
     Fitemdef   if   e           k disk
     Freports   if   e           k disk
     Fpospo     if   e           k disk
     Fporcv     if   e           k disk
     Fpo331pr   o    e             printer oflind(*in90)
     F                                     usropn

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#LICINFO

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
      /copy qcopysrc,id#citylin
      /copy qcopysrc,id#eastlan
      /copy qcopysrc,id#pfc
      /copy qcopysrc,id#sgc
      /copy qcopysrc,id#pan
      /copy qcopysrc,id#kfs
      /copy qcopysrc,id#eop

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @getptihi       c                   const('GETPTIHI')
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

     *----------------------------------------------------------------
     *  Data structure for harvested date
     *
     D                 ds
     D  hrvdte                 1      6  0
     D  hrvdd                  1      2  0
     D  hrvmm                  3      4  0
     D  hrvyy                  5      6  0

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
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     D desc            s             20    dim(4) ctdata perrcd(1)
     *  VARIABLES
     D #pwhse          s              3  0
     D $pcode          s             10
     D $phcat          s              1
     D $phdtl          s              1
     D $phhdr          s              1
     D $plen           s              3  0
     D $pstr           s             60
     D brk             s              1    inz(*off)
     D ck4err          s               n
     D error           s               n
     D count           s              3  0
     D eof             s              1
     D first           s               n
     D forever         s               n
     D l               s              1  0
     D m               s                   like(l)
     D p#              s              1  0
     D rcvuser         s             15a
     D r1otot1         s              7  0
     D r1otot2         s              7  0
     D r1otot3         s              7  0
     D r1rtot1         s              7  0
     D r1rtot2         s              7  0
     D r1rtot3         s              7  0
     D savever#        s                   like($lnver#)
     D svhdte          s              8  0
     D wkprtf          s             10
     D work6           s              6
     D partplt         s              3  0
     D putplt          s              3  0
     D putqty          s              6  0
     D wpdev           s             10
     D wpform          s             20
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
     C                   eval      phwhse = #pwhse
     C                   eval      phpo   = $ppo

     C     pohkey        setll     pohdr

     C                   dow       forever = forever
     C     pohkey        reade     pohdr                                  76
     C                   if        *in76 = *on
     C                   leave
     C                   else
     *
     * Determine if Super PO
     *
     C                   if        %subst(phpo:1:2) = 'SP'
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
     C                   move      phpo          p#desc
     C                   eval      p#memo = *blanks
     *  If Control # needed on report
     C                   if        client = kellys
     C     pohkey        chain     pohdrm                             74
     C                   eval      work6 = *blanks
     C                   movel     phmm5         work6
     C                   eval      p#memo = 'Control # ' + work6
     C                   endif
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
     C                   select
     C                   when      client = EarlsOrganic
     c                   eval      coltxt1 = '    Sub   '
     c                   eval      coltxt2 = '  Update  '
     c                   eval      coltxt3 = '     Price     '
     C                   endsl
     C                   write     columns
     C                   eval      first = *off
     C                   endif
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *  Write detail line
     C     super         tag
     C     podkey        setll     podtl                              79
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
     C                   if        %subst(phpo:1:2) = 'SP'
     C                   eval      *in77 = *off
     C                   eval      puwhse = phwhse
     C                   eval      puspo = phpo
     * Scan through individual po's
     C     poskey        setll     pospo
     C                   dow       *in77 = *off
     C     poskey        reade     pospo                                  77
     C                   if        *in77 = *off
     C                   eval      phpo  = pupo
     C     pohkey        chain     pohdr                              76
     *
     C                   eval      page = 0
     C                   eval      count = 0
     C                   eval      eof = *off
     C                   eval      phpo = pupo
     C     podkey        setll     podtl                              79
     C                   exsr      zrhead
     C                   write     columns
     C                   eval      first = *off
     *
     * Print detail for each PO in Super PO
     *
     C                   dow       eof = *off
     C     podkey        reade     podtl                                  79
     C                   move      *in79         eof
     C                   exsr      zzchkeof
     C                   if        not *in79
     C     poekey        setll     poexcp                             76
     C     itmkey        chain     itemdef                            78
     C                   if        *in78
     C                   eval      idtie = *zeros
     C                   eval      idhigh = *zeros
     C                   endif
     C     itmkey        chain     piritem                            78
     C                   if        *in78
     C                   eval      itdesc = *blanks
     C                   eval      itvit# = *blanks
     C                   eval      itwhdp = *blanks
     C                   endif
     C                   movel     itdesc        w1desc
     *  Display all qty fields as one string
     C                   eval      $pqty1 = pdqor1
     C                   eval      $pqty2 = pdqor2
     C                   eval      $pqty3 = pdqor3
     C                   exsr      zzqtys
     *
     C                   call      'CENTER'
     C                   parm      $pqstr        $pstr
     C                   parm      10            $plen
     C                   eval      w1ord = $pstr
     *
     C                   eval      $pqty1 = pdqrc1
     C                   eval      $pqty2 = pdqrc2
     C                   eval      $pqty3 = pdqrc3
     C                   exsr      zzqtys
     *
     C                   call      'CENTER'
     C                   parm      $pqstr        $pstr
     C                   parm      10            $plen
     C                   eval      w1rcv = $pstr
     *
     C                   eval      w1wt = %editc(pddwgt:'3')
     C                   call      'CENTER'
     C                   parm      w1wt          $pstr
     C                   parm      10            $plen
     C                   eval      w1wt = $pstr
     *
      /free
        // if quantity received and quantity ordered are different
        // we will print an '*' at the end of the line
        *in62 = *off;
        if w1ord <> w1rcv;
          *in62 = *on;
        endif;
      /end-free
     C                   write     detail1                              90
     C                   add       1             count
     *  If Vendor item # needed on report
     C                   if        client = panos
     C                   write     detail5
     C                   add       1             count
     C                   endif
     *  If tiexhigh needed on report
     C                   if        client = presto
      /free
          eval      putqty = idtie * idhigh;
          if putqty > 0;
          eval putplt = pdqor1 / putqty;
          partplt = pdqor1-(%int(putplt)*putqty);
          if partplt > 0;
          eval putplt = putplt + 1;
          endif;
          else;
          eval putplt = 1;
          endif;
          eval      totplt = totplt + putplt;
      /end-free
     C                   write     detail4
     C                   add       1             count
     C                   endif
     C                   exsr      zztotals
     *
     C                   if        *in90
     C                   write     head1
     C                   eval      val39=phpo
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
     C                   eval      val39=phpo
     C                   write     head2
     C                   if        *in91 and
     C                             first <> *on
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   eval      count = 0
      /free
        // if quantity received and quantity ordered are different
        // we will print an '*' at the end of the line
        *in62 = *off;
        if w1ord <> w1rcv;
          *in62 = *on;
        endif;
      /end-free
     C                   write     detail1                              90
     C                   add       1             count
     C                   if        client = panos
     C                   write     detail5
     C                   add       1             count
     C                   endif
     *  If tiexhigh needed on report
     C                   if        client = presto
      /free
          eval      putqty = idtie * idhigh;
          if putqty > 0;
          eval putplt = pdqor1 / putqty;
          partplt = pdqor1-(%int(putplt)*putqty);
          if partplt > 0;
          eval putplt = putplt + 1;
          endif;
          else;
          eval putplt = 1;
          endif;
          eval      totplt = totplt + putplt;
      /end-free
     C                   write     detail4
     C                   add       1             count
     C                   endif
     C                   eval      *in90 = *off
     C                   eval      *in92 = *off
     C                   exsr      zztotals
     C                   endif
     C                   dow       *in76 = *off
     C     poekey        reade     poexcp                                 76
     C                   if        *in76 = *off
     C     pecode        chain     rcvexcp                            72
     C                   if        *in72 = *off
     C                   movel     redesc        w1excp
     C                   else
     C                   eval      w1excp = pecode
     C                   endif
     *  Display all qty fields as one string
     C                   eval      $pqty1 = peqex1
     C                   eval      $pqty2 = peqex2
     C                   eval      $pqty3 = peqex3
     C                   exsr      zzqtys
     *
     C                   eval      w1qexc = $pqstr
     C                   write     detail2
     C                   add       1             count
     C                   endif
     C                   enddo
     *
     *                    ENDIF
     *                    ENDIF

     *  If item is a CLAMS product, print DETAIL3
     *  For SHUCKED products too.
     C                   if        client = cityline
     C                   exsr      prtClams
     C                   endif

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
     C                   if        client = sgc
     C                   write     foot1s
     C                   else
     C                   write     foot1
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     *
     *  If not Super PO, then process as normal
     *
     C                   else
     *
     C                   dow       eof = *off
     C     podkey        reade     podtl                                  79
     C                   move      *in79         eof
     C                   exsr      zzchkeof
     C                   if        not *in79
     C     poekey        setll     poexcp                             76
     C     itmkey        chain     itemdef                            78
     C                   if        *in78
     C                   eval      idtie = *zeros
     C                   eval      idhigh = *zeros
     C                   endif
     C     itmkey        chain     piritem                            78
     C                   if        *in78
     C                   eval      itdesc = *blanks
     C                   eval      itvit# = *blanks
     C                   eval      itwhdp = *blanks
     C                   endif
     C                   movel     itdesc        w1desc
     *  Display all qty fields as one string
     C                   eval      $pqty1 = pdqor1
     C                   eval      $pqty2 = pdqor2
     C                   eval      $pqty3 = pdqor3
     C                   exsr      zzqtys
     *
     C                   call      'CENTER'
     C                   parm      $pqstr        $pstr
     C                   parm      10            $plen
     C                   eval      w1ord = $pstr
     *
     C                   eval      $pqty1 = pdqrc1
     C                   eval      $pqty2 = pdqrc2
     C                   eval      $pqty3 = pdqrc3
     C                   exsr      zzqtys
     *
     C                   call      'CENTER'
     C                   parm      $pqstr        $pstr
     C                   parm      10            $plen
     C                   eval      w1rcv = $pstr
     *
     C                   eval      w1wt = %editc(pddwgt:'3')
     C                   call      'CENTER'
     C                   parm      w1wt          $pstr
     C                   parm      10            $plen
     C                   eval      w1wt = $pstr
     *
      /free
        // if quantity received and quantity ordered are different
        // we will print an '*' at the end of the line
        *in62 = *off;
        if w1ord <> w1rcv;
          *in62 = *on;
        endif;
        if client = EarlsOrganic;
          exec sql select substr(ikmsc1,1,10) into :w1uom
                     from itemext
                    where ikwhse = :pdwhse
                      and ikitem = :pditem;
          if sqlstt <> sqlsuccess;
            w1uom = *blanks;
          endif;
          w1txt1 = '  Sub [ ] ';
          w1txt2 = 'Update [ ]';
          w1txt3 = ' Price ________';
        endif;
      /end-free
     C                   call      'CENTER'
     C                   parm      w1uom         $pstr
     C                   parm      10            $plen
     C                   eval      w1uom = $pstr
     *
     C                   write     detail1                              90
     C                   add       1             count
     C                   if        client = panos
     C                   write     detail5
     C                   add       1             count
     C                   endif
     *  If tiexhigh needed on report
     C                   if        client = presto
      /free
          eval      putqty = idtie * idhigh;
          if putqty > 0;
          eval putplt = pdqor1 / putqty;
          partplt = pdqor1-(%int(putplt)*putqty);
          if partplt > 0;
          eval putplt = putplt + 1;
          endif;
          else;
          eval putplt = 1;
          endif;
          eval      totplt = totplt + putplt;
      /end-free
     C                   write     detail4
     C                   add       1             count
     C                   endif
     C                   exsr      zztotals
     *
     C                   if        *in90
     C                   write     head1
     C                   eval      val39=phpo
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
     *                                                              2
     C                   if        *in90
     C                   write     head1
     C                   eval      val39=phpo
     C                   write     head2
     C                   if        *in91 and
     C                             first <> *on
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   eval      count = 0
      /free
        // if quantity received and quantity ordered are different
        // we will print an '*' at the end of the line
        *in62 = *off;
        if w1ord <> w1rcv;
          *in62 = *on;
        endif;
      /end-free
     C                   write     detail1                              90
     C                   add       1             count
     C                   if        client = panos
     C                   write     detail5
     C                   add       1             count
     C                   endif
     *  If tiexhigh needed on report
     C                   if        client = presto
      /free
          eval      putqty = idtie * idhigh;
          if putqty > 0;
          eval putplt = pdqor1 / putqty;
          partplt = pdqor1-(%int(putplt)*putqty);
          if partplt > 0;
          eval putplt = putplt + 1;
          endif;
          else;
          eval putplt = 1;
          endif;
          eval      totplt = totplt + putplt;
      /end-free
     C                   write     detail4
     C                   add       1             count
     C                   endif
     C                   eval      *in90 = *off
     C                   eval      *in92 = *off
     C                   exsr      zztotals
     C                   endif
     *
     C                   dow       *in76 = *off
     C     poekey        reade     poexcp                                 76
     C                   if        *in76 = *off
     C     pecode        chain     rcvexcp                            72
     C                   if        *in72 = *off
     C                   movel     redesc        w1excp
     C                   else
     C                   eval      w1excp = pecode
     C                   endif
     *  Display all qty fields as one string
     C                   eval      $pqty1 = peqex1
     C                   eval      $pqty2 = peqex2
     C                   eval      $pqty3 = peqex3
     C                   exsr      zzqtys
     *
     C                   eval      w1qexc = $pqstr
     C                   write     detail2
     C                   add       1             count
     C                   endif
     C                   enddo
     *
     *    Detail 1 line overflowed. Headings already printed.
     *

     *  If item is a CLAMS product, print DETAIL3
     *  For SHUCKED products too.
     C                   if        client = cityline
     C                   exsr      prtClams
     C                   endif

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
     C                   if        client = sgc
     C                   write     foot1s
     C                   else
     C                   write     foot1
     C                   endif
     C                   eval      *inlr = *on
      /free
         // Close printer file.

         close(e)   po331pr;
         if %error;
         endif;
      /end-free
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 2
     *
     CLr                 if        reck(l) > 0
     CLr                 write     total1
     CLr                 if        client = eastland
     CLr                 write     total1a
     CLr                 endif
     CLr                 if        client = presto
     CLr                 write     total1pfc
     CLr                 endif
     CLr                 write     skip1
     CLr                 if        client = sgc
     CLr                 write     foot1s
     CLr                 else
     CLr                 write     foot1
     CLr                 endif
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
     *
     * P.O. Header file -
     *
     C     pohkey        klist
     C                   kfld                    phwhse
     C                   kfld                    phpo
     *
     * P.O. Detail file - Partial key
     *
     C     podkey        klist
     C                   kfld                    phwhse
     C                   kfld                    phpo
     *
     * P.O. Exception file - partial key
     *
     C     poekey        klist
     C                   kfld                    pdwhse
     C                   kfld                    pdpo
     C                   kfld                    pdseq
     C                   kfld                    pditem
     *
     *  Key for PIRITEM file
     C     itmkey        klist
     C                   kfld                    pdwhse
     C                   kfld                    pditem
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
     * PORCV - partial key
     *
     C     porkey        klist
     C                   kfld                    pdwhse
     C                   kfld                    pdpo
     C                   kfld                    pdseq
     *
     *   Get report title.
     *
     C                   movel     'PO331PR '    wkprtf
     C                   eval      rptttl = *blanks
     C                   eval      $pstr = *blanks
     C     rpkey         chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     c                   eval      wpdev = rpdev
     c                   eval      wpform = rpform
     C                   else
     C                   move      'PO RCPT'     $pstr
     c                   eval      wpdev = '*JOB'
     c                   eval      wpform = '*STD'
     C                   endif
     C                   eval      $plen = 40
     c* ovrprtf and open file
      /free
           qcmd = 'OVRPRTF '
                + 'FILE(PO331PR) '
                + 'OUTQ(*DEV) '
                + 'DEV(' + %trim(wpdev) + ') '
                + 'FORMTYPE(' + %trim(wpform) + ') ';

      /end-free
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
      /free
         // Open printer file.

         open(e)   po331pr;
      /end-free
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
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #user
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobn

     C                   endsr

     *----------------------------------------------------------------
     *   Print license and harvest data for CLAMS products.
     *   For SHUCKED products too.
     *
     C     prtClams      begsr
     *
     *   If not CLAMS or SHUCKED, get out.
     C                   exsr      zzgetIcat
     C                   if        $pcode <> 'CLAMS'
     C                             and $pcode <> 'SHUCKED'
     C                   goto      endprtCl
     C                   endif
     *
     C     porkey        setll     porcv
     C                   dow       forever = forever
     C     porkey        reade     porcv
     C                   if        %eof
     C                   leave
     C                   else
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
     C                   endif
     C                   enddo
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
     C     phwhse        chain     warehs                             79
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
     C                   move      phstat        p#
     C                   if        phstat = '0'
     C                   eval      p# = 1
     C                   endif
     C                   movea     desc(p#)      p#desc
     C                   eval      vadr1 = %trimr(phvad1) + ' ' + (phvad2)
     C                   eval      vadr2 = %trimr(phvcty) + ', ' +
     C                             %trimr(phvst) + '  ' + %trimr(phvzp1)
     * If POHDR chain/read unsuccessful
     C                   if        *in76 = *on
     C                   eval      phvnam = *blanks
     C                   eval      vadr1  = *blanks
     C                   eval      vadr2  = *blanks
     C                   movel     '*Not found*' phvnam
     C                   endif
     C                   eval      val39=phpo
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
     C                   if        l = 1
     C                   endif
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
     *  ZZGETICAT  Get item category
     *
     C     zzgetIcat     begsr

     C                   eval      $pcode = ' '
     C                   call      'GETICAT'
     C                   parm                    $pwhse
     C                   parm                    pditem
     C                   parm                    $pcode
     C                   parm                    $phhdr
     C                   parm                    $phdtl
     C                   parm                    $phcat

     C                   endsr
     *----------------------------------------------------------------
     *  zzGetUser  Get Receiving User
     *
      /free
        begsr zzGetUser;
            exec sql select min(porusr) into :rcvuser
                       from porcv
                      where porpo = :pdpo
                        and porseq = :pdseq
                        and poract = 'R';
            if sqlstt = sqlsuccess;
              exec sql select trim(usfnam) ||' '|| trim(uslnam)
                         into :t1txt1
                         from piruser
                        where uscode = :rcvuser;
            else;
              t1txt1 = '__________________';
            endif;
        endsr; // zzGetUser
      /end-free
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
     C                   eval      val39=phpo
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
     *
     C                   select
     C                   when      client = EarlsOrganic
     C                   exsr      zzGetUser
     C                   write     total1eop
      *
     C                   other
     C                   write     total1
     C                   endsl
      *
     C                   if        client = eastland
     C                   write     total1a
     C                   endif
     C                   if        client = presto
     C                   write     total1pfc
     C                   endif
      *
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
     C                   eval      r1otot1 = r1otot1 + pdqor1
     C                   eval      r1otot2 = r1otot2 + pdqor2
     C                   eval      r1otot3 = r1otot3 + pdqor3
     *
     C                   eval      r1rtot1 = r1rtot1 + pdqrc1
     C                   eval      r1rtot2 = r1rtot2 + pdqrc2
     C                   eval      r1rtot3 = r1rtot3 + pdqrc3
     *
     C                   endsr
     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
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
     *
     * Compile time tables
     *
**  DESC  - Status description
Open
Part Rcvd
Rcvd in full
Ready for export
