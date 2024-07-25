     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PO330     PO Receiving Receipt
     *  Roxanne Harrison
     *  22 November 2004 Created - V5.00
     *
     *  Revisions
     *
417 A*    08/22/03  MLB  4.17
     *      - Fix: Headings not printing on page overflow.
500 A*    05/13/05  RLP  5.00
     *      - Enh: Add support for Super PO's.
     *      - Changed to full procedural file input method.
520 A*    03/03/08  RH   5.20
     *      - Enh: Add weight column.
530 A*    12/30/09  RH   5.30
     *      - Enh: Add PO seq #, change desc to 25 long W1DESC
530bA*    04/29/10  RH   5.30b
     *      - Enh: Add PO Qty Exceptions, Detail2.
530cA*    09/30/10  RBD  5.30c
     *      - Enh: Added client custom code support to program.
650a *    09/23/14  GJA  6.50a
     *      - Enh: Added PO number barcode
650b *    10/15/14  GJA  6.50b
     *      - Added DETAIL4; printing of tie high
650c *    01/29/15  LMC  6.50c
     *      - Added the printing of an '*' at the end of detail1
     *      line when the quantity received is different than the
     *      quantity ordered.
650d *    03/23/15  RH   6.50d
     *      - Fix: Change to write FOOT1S for SFCa mod, SFC only
700a *    08/03/15  GJA  7.00a
     *      - Enh: Add pallet count
700b *    04/19/16  LMC  7.00b
     *      - Enh: printer file changed to usropn - needed to work
     *        with Gui to get the printea overrides applied.
710a *    09/06/18  RH   7.10a
     *      - Enh: Add P#MEMO to print data from POHDRM
750a *    05/04/21  RH   7.50A
     *      - Added 700b mod missed in prev update - found at Presto
700b *        03/28/16  GJA  7.00b
     *        - Added pick slot to DETAIL4
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line
     *
CLD A*    09/30/10  RBD  CLD
     *      - Added DETAIL3; printing of harvested date, location,
     *        cert#, and license for items identified as CLAMS.
CLDaA*    12/07/11  RBD  CLDa
     *      - Added DETAIL3 printing for SHUCKED items also.
CLDbA*    11/13/13  RBD  CLDb
     *      - Fix: Look for multiple licenses for an item.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland
     *
EFCaA*    06/06/11  RH   EFCa
     *      - Added TOTAL1A; print container and Period/week lines
     *----------------------------------------------------------------
     *  Client Custom Revisions: Panos
PANaA*    10/03/17  RH   PANa
     *      - Added DETAIL5 to print Vend item #.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kellys
KFSaA*    09/06/18  RH   KFSa
     *      - Move Control # to P#MEMO
     *----------------------------------------------------------------
     *  Client Custom Revisions: Accardi
ACCaA*    12/10/18  RH   ACCa
     *      - Added DETAIL1A and DETAIL5A to print Vend item and long
     *        description
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greco & Sons
GRCaA*    12/16/19  RBD  GRCa
     *      - Added printing of DETAIL4.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jacmar
JACaA*    01/14/22  LMC  JACa
     *      - Added printing of DETAIL4. Same as Greco
     *----------------------------------------------------------------
     *  Indicator usage
     *
500 A*  76        POHDR   Not on file/End of file indicator
500 A*  77        POSPO   Not on file/End of file indicator
500 A*  78        PIRITEM Not on file/End of file indicator
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
417 A*  91        Print continuation line on headings
417 A*  92        Headings printed. Print detail 1 line.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
500 DF*ohdr     ip   e           k disk
500 AFpohdr     if   e           k disk
710 AFpohdrm    if   e           k disk
     Fpodtl     if   e           k disk
530bAFpoexcp    if   e           k disk
530bAFrcvexcp   if   e           k disk
     Fpiritem   if   e           k disk
ACCaAFitemdsc   if   e           k disk
650bAFitemmsc   if   e           k disk
     Fwarehs    if   e           k disk
650bAFitemdef   if   e           k disk
     Freports   if   e           k disk
500 AFpospo     if   e           k disk
700bAFslot10    if   e           k disk
CLD AFporcv     if   e           k disk
     Fpo330pr   o    e             printer oflind(*in90)
700bAF                                     usropn

     *----------------------------------------------------------------
CLD A*  DRI parameters
     *----------------------------------------------------------------
CLD A /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
CLD A*  Data Formats
     *----------------------------------------------------------------

CLD A /COPY *libl/qcopysrc,C#LICINFO

     *----------------------------------------------------------------

530cA*----------------------------------------------------------------
530cA*  Customer id
530cA*----------------------------------------------------------------
CLD A /copy qcopysrc,id#citylin
EFCaA /copy qcopysrc,id#eastlan
650bA /copy qcopysrc,id#pfc
650dA /copy qcopysrc,id#sgc
PANaA /copy qcopysrc,id#pan
KFSaA /copy qcopysrc,id#kfs
ACCaA /copy qcopysrc,id#acc
GRCaA /copy qcopysrc,id#grc
JACaA /copy qcopysrc,id#JAC

     *----------------------------------------------------------------
CLD A*  Called programs
     *
CLD AD @cvtdt          c                   const('CVTDTE')
700aAD @getptihi       c                   const('GETPTIHI')
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
     D desc            s             20    dim(4) ctdata perrcd(1)
     *  VARIABLES
500 AD #pwhse          s              3  0
CLD AD $pcode          s             10
CLD AD $phcat          s              1
CLD AD $phdtl          s              1
CLD AD $phhdr          s              1
     D $plen           s              3  0
     D $pstr           s             60
500 AD brk             s              1    inz(*off)
CLD AD ck4err          s               n
CLD AD error           s               n
     D count           s              3  0
     D eof             s              1
500 AD first           s               n
500 AD forever         s               n
     D l               s              1  0
     D m               s                   like(l)
     D p#              s              1  0
500 AD r1otot1         s              7  0
500 AD r1otot2         s              7  0
500 AD r1otot3         s              7  0
500 AD r1rtot1         s              7  0
500 AD r1rtot2         s              7  0
500 AD r1rtot3         s              7  0
CLD AD savever#        s                   like($lnver#)
CLD AD svhdte          s              8  0
700bAD status          s              2
     D wkprtf          s             10
710aAD work6           s              6
700aAD partplt         s              3  0
700bAD pick            s              1
700aAD putplt          s              3  0
700aAD putqty          s              6  0
700bAD wpdev           s             10
700bAD wpform          s             20
     *
     *----------------------------------------------------------------
500 DI*hrec
500 DI*                                         phwhse        l1
500 DI*                                         phpo          l1
500 A*----------------------------------------------------------------
500 A*  Parameters
500 A*
500 A*    Input Parameters
500 A*      $PWHSE    -  Warehouse
500 A*      $PPO      -  PO number
500 A*
500 A*    Returned Parameters
500 A*      *NONE
500 A*----------------------------------------------------------------
500 A*  Let the show begin .....
500 A*----------------------------------------------------------------
500 AC     *entry        plist
500 AC                   parm                    $pwhse            3
500 AC                   parm                    $ppo              9
500 A*----------------------------------------------------------------
500 A*  Main line
500 A*----------------------------------------------------------------
500 AC                   move      $pwhse        #pwhse
500 AC                   eval      phwhse = #pwhse
500 AC                   eval      phpo   = $ppo

500 AC     pohkey        setll     pohdr

500 AC                   dow       forever = forever
500 AC     pohkey        reade     pohdr                                  76
500 AC                   if        *in76 = *on
500 AC                   leave
500 AC                   else
     *
500 A* Determine if Super PO
500 A*
500 AC                   if        %subst(phpo:1:2) = 'SP'
500 AC                   goto      super
500 AC                   endif

     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     C                   if        *in90  or
500 DC*                            *inl1
500 AC                             brk = *on or
500 AC                             first = *on
     C                   exsr      zrzero
     C                   eval      p#desc = *blanks
     C                   move      phpo          p#desc
710aAC                   eval      p#memo = *blanks
KFSaA*  If Control # needed on report
KFSaAC                   if        client = kellys
KFSaAC     pohkey        chain     pohdrm                             74
KFSaAC                   eval      work6 = *blanks
KFSaAC                   movel     phmm5         work6
KFSaAC                   eval      p#memo = 'Control # ' + work6
KFSaAC                   endif
     *          TYPE      CAT  '/':0     P#DESC
     *          P#DESC    CAT  ITWHDP:0  P#DESC
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Warehouse/PO
     *
500 DC*                  if        *inl1
500 AC                   if        brk = *on
     C                   eval      l = 1
     C                   endif
     *
     *  Output Headings
     *
     C                   if        *in91  or
500 AC                             brk = *on or
500 DC*                            *inl1
500 AC                             first = *on
500 MC                   if        *in91 and
500 AC                             first <> *on
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   eval      first = *off
     C                   endif
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     *  Write detail line
     *
500 AC     super         tag
     C     podkey        setll     podtl                              79
     C                   eval      count = 0
500 AC                   eval      r1otot1 = 0
500 AC                   eval      r1otot2 = 0
500 AC                   eval      r1otot3 = 0
500 AC                   eval      r1rtot1 = 0
500 AC                   eval      r1rtot2 = 0
500 AC                   eval      r1rtot3 = 0
     C                   seton                                        61
     C                   move      *in79         eof
     *
500 A* Determine if Super PO
500 A*
500 AC                   if        %subst(phpo:1:2) = 'SP'
500 AC                   eval      *in77 = *off
500 AC                   eval      puwhse = phwhse
500 AC                   eval      puspo = phpo
500 A* Scan through individual po's
500 AC     poskey        setll     pospo
500 AC                   dow       *in77 = *off
500 AC     poskey        reade     pospo                                  77
500 AC                   if        *in77 = *off
500 AC                   eval      phpo  = pupo
500 AC     pohkey        chain     pohdr                              76
500 A*
500 AC                   eval      page = 0
500 AC                   eval      count = 0
500 AC                   eval      eof = *off
500 AC                   eval      phpo = pupo
500 AC     podkey        setll     podtl                              79
500 AC*                  eval      *in90 = *on
500 AC                   exsr      zrhead
500 AC                   write     columns
500 AC                   eval      first = *off
     *
     * Print detail for each PO in Super PO
     *
500 AC                   dow       eof = *off
500 AC     podkey        reade     podtl                                  79
500 AC                   move      *in79         eof
500 AC                   exsr      zzchkeof
500 AC                   if        not *in79
530bAC     poekey        setll     poexcp                             76
650bAC     itmkey        chain     itemdef                            78
650bAC                   if        *in78
650bAC                   eval      idtie = *zeros
650bAC                   eval      idhigh = *zeros
650bAC                   endif
500 AC     itmkey        chain     piritem                            78
500 AC                   if        *in78
500 AC                   eval      itdesc = *blanks
650bAC                   eval      itvit# = *blanks
650bAC                   eval      itwhdp = *blanks
500 AC                   endif
530aAC                   movel     itdesc        w1desc
ACCaAC                   if        client = accardi
ACCaAC     itmkey        chain     itemdsc                            78
ACCaAC                   if        *in78
ACCaAC                   eval      ixdsc1 = *blanks
ACCaAC                   eval      ixdsc2 = *blanks
ACCaAC                   endif
ACCaAC                   eval      w1desca = ixdsc1 + ixdsc2
ACCaAC                   endif
500 A*  Display all qty fields as one string
500 AC                   eval      $pqty1 = pdqor1
500 AC                   eval      $pqty2 = pdqor2
500 AC                   eval      $pqty3 = pdqor3
500 AC                   exsr      zzqtys
500 A*
500 AC                   eval      w1ord = $pqstr
500 A*
500 AC                   eval      $pqty1 = pdqrc1
500 AC                   eval      $pqty2 = pdqrc2
500 AC                   eval      $pqty3 = pdqrc3
500 AC                   exsr      zzqtys
500 A*
500 AC                   eval      w1rcv = $pqstr
500 A*
520 AC                   eval      w1wt = pddwgt
650cA /free
650cA   // if quantity received and quantity ordered are different
650cA   // we will print an '*' at the end of the line
650cA   *in62 = *off;
650cA   if w1ord <> w1rcv;
650cA     *in62 = *on;
650cA   endif;
650cA /end-free
ACCaA*  If desc on detail5a
ACCaAC                   if        client = accardi
ACCaAC                   write     detail1a
ACCaAC                   else
500 AC                   write     detail1                              90
ACCaAC                   endif
500 AC                   add       1             count
PANaA*  If Vendor item # needed on report
PANaAC                   if        client = panos
PANaAC                   write     detail5
PANaAC                   add       1             count
PANaAC                   endif
ACCaA*  If Vendor item # needed on report
ACCaAC                   if        client = accardi
ACCaAC                   write     detail5a
ACCaAC                   add       1             count
ACCaAC                   endif
650bA*  If tiexhigh needed on report
650bAC                   if        client = presto
GRCaAC                             or client = Greco
JACaAC                             or client = Jacmar
700a  /free
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
700b      eval status = 'A ';
          eval pick = 'Y';
          chain(e) (pdwhse: pditem: status: pick) slot10;
          if not %found(slot10);
           eval sldisp = *blanks;
700b      endif;
700a  /end-free
650bAC                   write     detail4
650bAC                   add       1             count
650bAC                   endif
500 AC                   exsr      zztotals
500 A*
500 AC                   if        *in90
500 AC                   write     head1
650aAC                   eval      val39=phpo
500 AC                   write     head2
500 AC                   if        *in91 and
500 AC                             first <> *on
500 AC                   write     rphead
500 AC                   endif
500 AC                   write     columns
500 AC                   eval      count = 0
500 AC                   eval      *in90 = *off
500 AC                   eval      *in92 = *on
500 AC                   endif
     *
500 AC                   if        *in90
500 AC                   write     head1
650aAC                   eval      val39=phpo
500 AC                   write     head2
500 AC                   if        *in91 and
500 AC                             first <> *on
500 AC                   write     rphead
500 AC                   endif
500 AC                   write     columns
500 AC                   eval      count = 0
650cA /free
650cA   // if quantity received and quantity ordered are different
650cA   // we will print an '*' at the end of the line
650cA   *in62 = *off;
650cA   if w1ord <> w1rcv;
650cA     *in62 = *on;
650cA   endif;
650cA /end-free
ACCaAC                   if        client = accardi
ACCaAC                   write     detail1a
ACCaAC                   else
500 AC                   write     detail1                              90
ACCaAC                   endif
500 AC                   add       1             count
PANaAC                   if        client = panos
PANaAC                   write     detail5
PANaAC                   add       1             count
PANaAC                   endif
ACCaA*  If Vendor item # needed on report
ACCaAC                   if        client = accardi
ACCaAC                   write     detail5a
ACCaAC                   add       1             count
ACCaAC                   endif
650bA*  If tiexhigh needed on report
650bAC                   if        client = presto
GRCaAC                             or client = Greco
JACaAC                             or client = Jacmar
700a  /free
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
700b      eval status = 'A ';
          eval pick = 'Y';
          chain(e) (pdwhse: pditem: status: pick) slot10;
          if not %found(slot10);
           eval sldisp = *blanks;
700b      endif;
700a  /end-free
650bAC                   write     detail4
650bAC                   add       1             count
650bAC                   endif
500 AC                   eval      *in90 = *off
500 AC                   eval      *in92 = *off
500 AC                   exsr      zztotals
500 AC                   endif
530bAC                   dow       *in76 = *off
530bAC     poekey        reade     poexcp                                 76
530bAC                   if        *in76 = *off
530bAC     pecode        chain     rcvexcp                            72
530bAC                   if        *in72 = *off
530bAC                   movel     redesc        w1excp
530bAC                   else
530bAC                   eval      w1excp = pecode
530bAC                   endif
530bA*  Display all qty fields as one string
530bAC                   eval      $pqty1 = peqex1
530bAC                   eval      $pqty2 = peqex2
530bAC                   eval      $pqty3 = peqex3
530bAC                   exsr      zzqtys
530bA*
530bAC                   eval      w1qexc = $pqstr
530bAC                   write     detail2
530bAC                   add       1             count
530bAC                   endif
530bAC                   enddo
530bA*
500 A*
500 A*    Detail 1 line overflowed. Headings already printed.
500 A*    Reprint detail 1 line for license plate(s).
500 DC*                  if        *in92
500 DC*                  write     detail1
500 DC*                  eval      *in92 = *off
500 DC*                  endif
500 A*
500 A*                    ENDIF
500 A*                    ENDIF

CLD A*  If item is a CLAMS product, print DETAIL3
CLDaA*  For SHUCKED products too.
CLD AC                   if        client = cityline
CLD AC                   exsr      prtClams
CLD AC                   endif

500 AC                   endif
500 AC                   enddo
500 A*
500 A*******              ENDIF
500 A*******              ENDDO
500 A*
500 A*  Increment record counters
500 A*
500 AC                   add       1             reck(1)
500 AC                   add       1             lvlk(1)
500 A*
500 AC                   if        *in77 = *on
500 AC                   write     skip1
SGCaAC                   if        client = sgc
SGCaAC                   write     foot1s
SGCaAC                   else
500 AC                   write     foot1
SGCaAC                   endif
500 AC                   endif
500 AC                   endif
500 AC                   enddo
500 A*
500 A*  If not Super PO, then process as normal
500 A*
500 AC                   else
500 A*
     C                   dow       eof = *off
     C     podkey        reade     podtl                                  79
     C                   move      *in79         eof
500 AC                   exsr      zzchkeof
     C                   if        not *in79
500 DC*                  add       1             count
530bAC     poekey        setll     poexcp                             76
650bAC     itmkey        chain     itemdef                            78
650bAC                   if        *in78
650bAC                   eval      idtie = *zeros
650bAC                   eval      idhigh = *zeros
650bAC                   endif
     C     itmkey        chain     piritem                            78
     C                   if        *in78
     C                   eval      itdesc = *blanks
650bAC                   eval      itvit# = *blanks
650bAC                   eval      itwhdp = *blanks
     C                   endif
530aAC                   movel     itdesc        w1desc
ACCaAC                   if        client = accardi
ACCaAC     itmkey        chain     itemdsc                            78
ACCaAC                   if        *in78
ACCaAC                   eval      ixdsc1 = *blanks
ACCaAC                   eval      ixdsc2 = *blanks
ACCaAC                   endif
ACCaAC                   eval      w1desca = ixdsc1 + ixdsc2
ACCaAC                   endif
     *  Display all qty fields as one string
     C                   eval      $pqty1 = pdqor1
     C                   eval      $pqty2 = pdqor2
     C                   eval      $pqty3 = pdqor3
     C                   exsr      zzqtys
     *
     C                   eval      w1ord = $pqstr
     *
     C                   eval      $pqty1 = pdqrc1
     C                   eval      $pqty2 = pdqrc2
     C                   eval      $pqty3 = pdqrc3
     C                   exsr      zzqtys
     *
     C                   eval      w1rcv = $pqstr
520 AC                   eval      w1wt = pddwgt
     *
417 D*                    WRITEDETAIL1
650cA /free
650cA   // if quantity received and quantity ordered are different
650cA   // we will print an '*' at the end of the line
650cA   *in62 = *off;
650cA   if w1ord <> w1rcv;
650cA     *in62 = *on;
650cA   endif;
650cA /end-free
ACCaAC                   if        client = accardi
ACCaAC                   write     detail1a
ACCaAC                   else
417 MC                   write     detail1                              90
ACCaAC                   endif
500 AC                   add       1             count
PANaAC                   if        client = panos
PANaAC                   write     detail5
PANaAC                   add       1             count
PANaAC                   endif
ACCaA*  If Vendor item # needed on report
ACCaAC                   if        client = accardi
ACCaAC                   write     detail5a
ACCaAC                   add       1             count
ACCaAC                   endif
650bA*  If tiexhigh needed on report
650bAC                   if        client = presto
GRCaAC                             or client = Greco
JACaAC                             or client = Jacmar
700a  /free
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
700b      eval status = 'A ';
          eval pick = 'Y';
          chain(e) (pdwhse: pditem: status: pick) slot10;
          if not %found(slot10);
           eval sldisp = *blanks;
700b      endif;
700a  /end-free
650bAC                   write     detail4
650bAC                   add       1             count
650bAC                   endif
500 AC                   exsr      zztotals
417 A*
417 AC                   if        *in90
417 AC                   write     head1
650aAC                   eval      val39=phpo
417 AC                   write     head2
500 MC                   if        *in91 and
500 AC                             first <> *on
417 AC                   write     rphead
417 AC                   endif
417 AC                   write     columns
500 AC                   eval      count = 0
417 AC                   eval      *in90 = *off
417 AC                   eval      *in92 = *on
417 AC                   endif
     *
417 A*                                                              2
417 AC                   if        *in90
417 AC                   write     head1
650aAC                   eval      val39=phpo
417 AC                   write     head2
500 MC                   if        *in91 and
500 AC                             first <> *on
417 AC                   write     rphead
417 AC                   endif
417 AC                   write     columns
500 AC                   eval      count = 0
650cA /free
650cA   // if quantity received and quantity ordered are different
650cA   // we will print an '*' at the end of the line
650cA   *in62 = *off;
650cA   if w1ord <> w1rcv;
650cA     *in62 = *on;
650cA   endif;
650cA /end-free
ACCaAC                   if        client = accardi
ACCaAC                   write     detail1a
ACCaAC                   else
417 AC                   write     detail1                              90
ACCaAC                   endif
500 AC                   add       1             count
PANaAC                   if        client = panos
PANaAC                   write     detail5
PANaAC                   add       1             count
PANaAC                   endif
ACCaA*  If Vendor item # needed on report
ACCaAC                   if        client = accardi
ACCaAC                   write     detail5a
ACCaAC                   add       1             count
ACCaAC                   endif
650bA*  If tiexhigh needed on report
650bAC                   if        client = presto
GRCaAC                             or client = Greco
JACaAC                             or client = Jacmar
700a  /free
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
700b      eval status = 'A ';
          eval pick = 'Y';
          chain(e) (pdwhse: pditem: status: pick) slot10;
          if not %found(slot10);
           eval sldisp = *blanks;
700b      endif;
700a  /end-free
650bAC                   write     detail4
650bAC                   add       1             count
650bAC                   endif
417 AC                   eval      *in90 = *off
417 AC                   eval      *in92 = *off
500 AC                   exsr      zztotals
417 AC                   endif
417 A*
530bAC                   dow       *in76 = *off
530bAC     poekey        reade     poexcp                                 76
530bAC                   if        *in76 = *off
530bAC     pecode        chain     rcvexcp                            72
530bAC                   if        *in72 = *off
530bAC                   movel     redesc        w1excp
530bAC                   else
530bAC                   eval      w1excp = pecode
530bAC                   endif
530bA*  Display all qty fields as one string
530bAC                   eval      $pqty1 = peqex1
530bAC                   eval      $pqty2 = peqex2
530bAC                   eval      $pqty3 = peqex3
530bAC                   exsr      zzqtys
530bA*
530bAC                   eval      w1qexc = $pqstr
530bAC                   write     detail2
530bAC                   add       1             count
530bAC                   endif
530bAC                   enddo
530bA*
417 A*    Detail 1 line overflowed. Headings already printed.
417 A*    Reprint detail 1 line for license plate(s).
500 DC*                  if        *in92
500 DC*                  write     detail1
500 DC*                  eval      *in92 = *off
500 DC*                  endif
417 A*
416a *                    ENDIF
416a *                    ENDIF

CLD A*  If item is a CLAMS product, print DETAIL3
CLDaA*  For SHUCKED products too.
CLD AC                   if        client = cityline
CLD AC                   exsr      prtClams
CLD AC                   endif

416a C                   endif
416a C                   enddo
     *
     *******              ENDIF
     *******              ENDDO
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     *  Set off top-of-page indicators
     *
     C     skip          tag
500 AC                   endif
500 AC                   endif
500 AC                   enddo
500 AC                   write     skip1
SGCaAC                   if        client = sgc
SGCaAC                   write     foot1s
SGCaAC                   else
500 AC                   write     foot1
SGCaAC                   endif
500 AC                   eval      *inlr = *on
700bA /free
700bA    // Close printer file.

700bA    close(e)   po330pr;
700bA    if %error;
700bA    endif;
700bA /end-free
     *----------------------------------------------------------------
     *
     * Warehouse/PO
     *
500 DC*1                 eval      l = 1
500 DC*1                 exsr      zrroll
     *
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
     CLr                 eval      l = 2
     *
     CLr                 if        reck(l) > 0
     CLr                 write     total1
EFCaACLr                 if        client = eastland
EFCaACLr                 write     total1a
EFCaACLr                 endif
PFCaACLr                 if        client = presto
PFCaACLr                 write     total1pfc
PFCaACLr                 endif
     CLr                 write     skip1
SGCaACLr                 if        client = sgc
SGCaACLr                 write     foot1s
SGCaACLr                 else
     CLr                 write     foot1
SGCaACLr                 endif
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
530cA* Get client id.
530cA*
530cAC                   call      'GETCLIENT'
530cAC                   parm                    client           10
530cAC                   parm                    clientloc        10
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
530b *
530b * P.O. Exception file - partial key
530b *
530b C     poekey        klist
530b C                   kfld                    pdwhse
530b C                   kfld                    pdpo
530b C                   kfld                    pdseq
530b C                   kfld                    pditem
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
CLD A* PORCV - partial key
CLD A*
CLD AC     porkey        klist
CLD AC                   kfld                    pdwhse
CLD AC                   kfld                    pdpo
CLD AC                   kfld                    pdseq
     *
     *   Get report title.
     *
     C                   movel     'PO330PR '    wkprtf
     C                   eval      rptttl = *blanks
     C                   eval      $pstr = *blanks
     C     rpkey         chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
700bAc                   eval      wpdev = rpdev
700bAc                   eval      wpform = rpform
     C                   else
     C                   move      'PO RCPT'     $pstr
700bAc                   eval      wpdev = '*JOB'
700bAc                   eval      wpform = '*STD'
     C                   endif
     C                   eval      $plen = 40
700bAc* ovrprtf and open file
700bA /free
700bA      qcmd = 'OVRPRTF '
700bA           + 'FILE(PO330PR) '
700bA           + 'OUTQ(*DEV) '
700bA           + 'DEV(' + %trim(wpdev) + ') '
700bA           + 'FORMTYPE(' + %trim(wpform) + ') ';

700bA /end-free
700bAC                   call      'QCMDEXC'
700bAC                   parm                    qcmd             80
700bAC                   parm      80            qlen             15 5
700bA /free
700bA    // Open printer file.

700bA    open(e)   po330pr;
700bA /end-free
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
500 DC*                  if        not *inl1
500 AC                   if        brk = *off
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
500 AC                   if        phstat = '0'
500 AC                   eval      p# = 1
500 AC                   endif
     C                   movea     desc(p#)      p#desc
     C                   eval      vadr1 = %trimr(phvad1) + ' ' + (phvad2)
     C                   eval      vadr2 = %trimr(phvcty) + ', ' +
     C                             %trimr(phvst) + '  ' + %trimr(phvzp1)
     * If POHDR chain/read unsuccessful
500 AC                   if        *in76 = *on
500 AC                   eval      phvnam = *blanks
500 AC                   eval      vadr1  = *blanks
500 AC                   eval      vadr2  = *blanks
500 AC                   movel     '*Not found*' phvnam
500 AC                   endif
650aAC                   eval      val39=phpo
     C                   write     head2
500 AC                   eval      count = 0
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
     *                    WRITETOTAL1
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
CLD A*  ZZGETICAT  Get item category
CLD A*
CLD AC     zzgetIcat     begsr
CLD A
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
500 AC     zzchkeof      begsr
     *
500 AC                   if        eof = *on
500 A*
500 AC                   if        count > 17
500 AC                   eval      *in90 = *on
500 AC                   write     head1
650aAC                   eval      val39=phpo
500 AC                   write     head2
500 MC                   if        *in91 and
500 AC                             first <> *on
500 AC                   write     rphead
500 AC                   endif
500 AC                   write     columns
500 AC                   eval      *in90 = *off
500 AC                   eval      count = 0
500 AC                   endif
500 A*
500 A*  Display all qty fields as one string
500 AC                   eval      $pqty1 = r1otot1
500 AC                   eval      $pqty2 = r1otot2
500 AC                   eval      $pqty3 = r1otot3
500 AC                   exsr      zzqtys
500 A*
500 AC                   eval      w1otot = $pqstr
500 A*
500 AC                   eval      $pqty1 = r1rtot1
500 AC                   eval      $pqty2 = r1rtot2
500 AC                   eval      $pqty3 = r1rtot3
500 AC                   exsr      zzqtys
500 A*
500 AC                   eval      w1rtot = $pqstr
500 A*
500 AC                   write     total2
500 AC                   write     total1
EFCaAC                   if        client = eastland
EFCaAC                   write     total1a
EFCaAC                   endif
PFCaAC                   if        client = presto
PFCaAC                   write     total1pfc
PFCaAC                   endif
500 MC                   eval      *in91 = *off
500 AC                   eval      r1otot1 = 0
500 AC                   eval      r1otot2 = 0
500 AC                   eval      r1otot3 = 0
500 AC                   eval      r1rtot1 = 0
500 AC                   eval      r1rtot2 = 0
500 AC                   eval      r1rtot3 = 0
500 AC                   endif
     *
500 AC                   endsr
     *
     *----------------------------------------------------------------
     *
500 AC     zztotals      begsr
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
     *
     * Compile time tables
     *
**  DESC  - Status description
Open
Part Rcvd
Rcvd in full
Ready for export
