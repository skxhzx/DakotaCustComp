      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  VC255S    Stage - Import Customer Invoices for Trax
     *  02 December 2020
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740 A*    12/02/20  DAS  7.40
     *      - Created.
     *
750aA*    04/06/21  RBD  7.50a
     *      - Revs following testing at beta site Food Pro.
     *
750bA*    04/08/21  MLB  7.50b
     *      - Enh: Added call to TR812 to create/re-create XML file
     *        upon successful import of invoices to Trax.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpsivch  uf   e           k disk
     Fimpsivcd  uf   e           k disk
     Fimpsivcc  uf   e           k disk
     Fwarehs    if   e           k disk
     Fttivch    o  a e           k disk
     Fttivcd    o  a e           k disk
     Fttivcc    o  a e           k disk
     F*c255pr   o    e             printer oflind(*in91)
     F*                                    usropn
     F*c2551pr  o    e             printer oflind(*in92)
     F*                                    usropn

     *----------------------------------------------------------------
     *  File record
     *----------------------------------------------------------------
     d ohrec         e ds                  extname(ordh) inz(*EXTDFT)
750aAD oharecx       E ds                  extname(ordhexa) prefix(x_)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             20    dim(9) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
     D a80             s              1    dim(80)
     D ovrprt          s             80    dim(2) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  Constants
     *
     D exchdr          c                   const('- Exceptions')
     D sts01           c                   const('** Added to existing-
     D                                      Open Order. ')
     D sts02           c                   const('** New Order Added t-
     D                                     o Open Route.')
     D sts03           c                   const('** Upd''d on existin-
     D                                     g Open Order.')
CSPaAD spclchar        c                   const('`~!@$%^&*()=+-[{]}\|-
CSPaAD                                     <>/?')
CSPaA* *IMPORTANT* If any special chars are added to string SPCLCHAR,
CSPaA*             NbrSpclChar must be updated for number added.
CSPaAD NbrSpclChar     s              3  0 inz(24)
PANdAd lower           c                   'abcdefghijklmnopqrstuvwxyz'
PANdAd UPPER           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     *

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
730eA /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Working variables
     *
640eAD chk4err         s               n
530dAD ck4err          s               n
     D count           s              3  0
640eAD curdate         s              8  0
640eAD curtime         s              6  0
     D excprt          s              1
     D excpr1          s              1
640aAD filnam          s             10
     D impdte          s              8  0
640aAD importError     s               n
     D imptim          s              6  0
640eAD lasttime        s              6  0
     D linppg          s              3  0
     D lstwhs          s              3  0
     D opened          s              1
     D pflag           s              1
     D prhdr1          s              1
750aMD savever#        s                   like($itver#)
640aAD stamp           s               z
640aAD stampUC         s               z

750aAD detmsg          s            200    varying
750aAD errorDetail     s               n
750aAD errorHeader     s               n
750aAD errorWeight     s               n
750aAD errText         s            200
750aAD first           s              1

640aA*----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
640aAD $pBatId         s             11
640aAD $pReturn        s             10
640aAD $pMessage       s            200
640aA
640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

640aA*----------------------------------------------------------------
640aA*  File data data structure
640aA*----------------------------------------------------------------
640aA
640aAD sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)
710aAD cstrec        E ds                  extname(custmast) inz(*EXTDFT)

EFCaA*----------------------------------------------------------------
EFCaA*  Called program parameters
EFCaA*
EFCaAD $parms          ds
EFCaAD  $pcmd                  1      8
EFCaAD  $pprg                  9     18
EFCaAD  $puky                 19     68
EFCaAD  $prtn                 69     76
EFCaAD  $perm                 77    136
EFCaAD  $pmsg                 77     80
EFCaA*
EFCaAD  $pwhs                 19     21  0 inz(0)
EFCaAD  $prte                 22     26
EFCaAD  $prtid                27     31
720aA /copy *libl/qcopysrc,p.getopint
720aA /copy *libl/qcopysrc,p.wrtlog
730dA /copy *libl/qcopysrc,p.umordd
PANdA /copy qcopysrc,p.getcust
PANDA /copy qcopysrc,p.exordh
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
EFCaAD @unpckpg        c                   const('RH134')
EFCaAD @delpg          c                   const('RH124')
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
530dA*  Program info data structure
     *
640aA /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

750bAd zzzCrtxml       pr
750bA

     d FillIVC         pr

     d FillIVD         pr

     d FillIVH         pr

     d GetId           pr

     d Getstamps       pr

     d OpnPrt          pr

     d ProcessDetail   pr

     d ProcessHeader   pr

     d ProcessWeights  pr

750aAd UpdateIVC       pr
750aAd  status                        1    const
750aAd  text                        200    const varying

750aAd UpdateIVD       pr
750aAd  status                        1    const
750aAd  text                        200    const varying

750aAd UpdateIVH       pr
750aAd  status                        1    const
750aAd  text                        200    const varying

     d zrHead          pr

     d zzInz           pr

     d zzGetDateTime   pr

     d zzzEnd          pr

     d zzzStart        pr

     d clr$Item        pr

     d zzzDriClose     pr

     d zzzDriCop       pr

750aAD GetAddOn        pr                  extpgm('GETADDON')
750aAD  ggwhs                         3  0
750aAD  ggrteid                       5
750aAD  ggparent                      5
750aAD  ggrtetype                    10

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
640aA*      $pBatId - Batch id
     *
     *    Returned Parameters
640aM*      $pWhse  - Warehouse
640aA*      $pReturn  - Return code
640aA*      $pMessage - Return message
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
640aMc                   parm                    $pWhse3A
640aAc                   parm                    $pBatId
640aAc                   parm                    $pReturn
640aAc                   parm                    $pMessage

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
       $pWhse = %dec($pWhse3A: 3: 0);
       $pReturn = '*OK';
       $pMessage = ' ';
       *inlr = *on;

750aD  //exsr zzinz;
750aM  zzinz();

       // Update stgbatch record to start process

       zzzStart();
       if $pReturn <> '*OK';
         return;
       endif;

       // Initialize print report fields

       first = *on;
       pflag = *on;
       linppg = 55;
       count = 0;

750aD  //grdinv = 0;
750aD  //grdord = 0;
750aD  //grdlin = 0;
750aD  //grord1 = 0;
750aD  //grlin1 = 0;
       pflag = *off;

       //    Get exceptions report override if any.

       // opnprt();

       //    Print report heading if necessary.

       prhdr1 = *off;
       if pflag = *off or count >= linppg;
         count = 0;
         //write head1;
         count += 3;
         pflag = *off;
       endif;
750aD  //hedmsg = *blanks;

       ProcessHeader();

       //  Print grand totals

       if pflag = *on and first = *off;
         if count >= linppg;
           //write head1;
         endif;
         //write grndttl;
       endif;

       //  We are finished so get out

       zzzEnd();

750bA
750bA  //  We had successful import of invoices, so create Trax XML.
750bA
750bA  if    $pReturn = '*OK'
750bA    and sbstatus = 'S';
750bA    zzzCrtxml();
750bA  endif;

       zzzDriClose();

       *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
     C     *inzsr        begsr
      /free
        log.pgm = 'VC255S';
        log.type = '*INFO    ';
        log.text = 'Customer Invoice Import started for whse: ' + $pwhse3a
                 + ' batid: ' + $pbatid;
        WrtLog(log.pgm: log.type: log.text);

        $pWhse = %dec($pWhse3A: 3: 0);

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  FillIVD       Fill TTIVCD fields
     *----------------------------------------------------------------

     p FillIVD         b
     d FillIVD         pi

      /free

       tvdwhs     = ivdwhs;
750aD  //tvdrteid   = ivdrteid;
750aM  tvdrteid   = ivhrteid;
       tvdinvoice = ivdinvoice;
       tvdorda    = ivdorda;
750aD  //tvdordid   = ivdordid;
750aM  tvdordid   = ivhordid;
       tvdseq     = ivdseq;
       tvdcsqnr   = ivdcsqnr;
       tvdcsqdsc  = ivdcsqdsc;
750aM  tvditem    = ivditm;
       tvdqo1     = ivdqo1;
       tvdqo2     = ivdqo2;
       tvdqo3     = ivdqo3;
       tvdqp1     = ivdqp1;
       tvdqp2     = ivdqp2;
       tvdqp3     = ivdqp3;
       tvduprc    = ivduprc;
       tvdextprc  = ivdextprc;
       tvdextwgt  = ivdextwgt;
       tvdutax    = ivdutax;
       tvdexttax  = ivdexttax;
       tvdufee    = ivdufee;
       tvdextfee  = ivdextfee;
       tvdwh2     = ivdwh2;
       tvdor2     = ivdor2;
       tvdoit     = ivdoit;
       tvdcitm    = ivdcitm;
       tvdspc     = ivdspc;
750aM  tvdlvr     = ivddlvr;
       tvdpo      = ivdpo;
       tvddsc     = ivddsc;
       tvdms1     = ivdms1;
       tvdms2     = ivdms2;
       tvdms3     = ivdms3;
       tvdms4     = ivdms4;
750aM  tvdms5     = ivdms5;

750aD  //GetStamp();
750aM  GetStamps();
       tvdaddts   = stamp;
       tvdadduc   = stampuc;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  FillIVC       Fill TTIVCC fields
     *----------------------------------------------------------------

     p FillIVC         b
     d FillIVC         pi

      /free

       tvcwhs     = ivcwhs;
750aD  //tvcrteid   = ivcrteid;
750aM  tvcrteid   = ivhrteid;
       tvcinvoice = ivcinvoice;
       tvcorda    = ivcorda;
750aD  //tvcordid   = ivcordid;
750aM  tvcordid   = ivdordid;
       tvcseq     = ivcseq;
       tvcosq     = ivcosq;
       tvcitm     = ivcitm;
       tvcseq     = ivcseq;
       tvcwgt     = ivcwgt;

750aD  //GetStamp();
750aM  GetStamps();
750aD  //tvdaddts   = stamp;
750aM  tvcaddts   = stamp;
750aD  //tvdadduc   = stampuc;
750aM  tvcadduc   = stampuc;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  FillIVH       Fill TTIVCH fields
     *----------------------------------------------------------------

     p FillIVH         b
     d FillIVH         pi

      /free

       tvhwhs     = ivhwhs;
       tvhrteid   = ivhrteid;
       tvhinvoice = ivhinvoice;
       tvhorda    = ivhorda;
       tvhordid   = ivhordid;
       tvhtyp     = ivhtyp;
       tvhcusa    = ivhcusa;
       tvhcpo     = ivhcpo;
       tvhcnm     = ivhcnm;
       tvhca1     = ivhca1;
       tvhca2     = ivhca2;
       tvhcct     = ivhcct;
       tvhcst     = ivhcst;
       tvhczp     = ivhczp;
       tvhrte     = ivhrte;
       tvhest     = ivhest;
       tvhtotinv  = ivhtotinv;
       tvhtottax  = ivhtottax;
       tvhtotfee  = ivhtotfee;
       tvhpmode   = ivhpmode;
       tvhterms   = ivhterms;
       tvhactmgr  = ivhactmgr;
       tvhpwgts   = ivhpwgts;
       tvhmsc     = ivhmsc;
       tvhms1     = ivhms1;
       tvhms2     = ivhms2;
       tvhms3     = ivhms3;
       tvhms4     = ivhms4;
       tvhms5     = ivhms5;

750aD  //GetStamp();
750aM  GetStamps();
       tvhaddts   = stamp;
       tvhadduc   = stampuc;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  GetId         Get id's for Order and Route
     *----------------------------------------------------------------

     p GetId           b
     d GetId           pi

     *  Local Variables

     D rteType         s             10

      /free

       // Get order id from

       exec sql select * into :oharecx
                from ordhexa
                where ohawhse = :ivhwhs
                  and ohaorda = :ivhorda
                fetch first 1 rows only;

       if sqlstt <> sqlSuccess;
         error = *on;
         errText = 'Order Id not found for '
                 + %char(ivhwhs) + '/' + %char(ivhorda)
                 + ' (' + sqlstt + ')';
         return;
       endif;

750aA  ivhordid = x_ohaord;

       // Get route id for order

       exec sql select ohrte into :ohrte
                from ordh
                where ohwhse = :ivhwhs
                  and ohord = :ivhordid;

       if sqlstt <> sqlSuccess;
         error = *on;
         errText = 'Route Id not found for '
                 + %char(ivhwhs) + '/' + %char(ivhordid)
                 + ' (' + sqlstt + ')';
         return;
       endif;

       // Get parent route id for for route

750aA  GetAddOn(ivhwhs: ohrte: ivhrteid: rteType);

750aA  if ivhrteid = *blanks;
750aA    ivhrteid = ohrte;
750aA  endif;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  GetStamps    Get timestamps
     *----------------------------------------------------------------

     p GetStamps       b
     d GetStamps       pi

      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  OPNPRT  Open printer file.
     *----------------------------------------------------------------

     p Opnprt          b
     d Opnprt          pi

     *
     *   Get device and form type for department.
     *
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'OI2851PR'    $lrpt            10
     C                   parm      lstwhs        $whse             3 0
     C                   parm      *blanks       $styp             1
     C                   parm      *blanks       $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   if        $dev = *blanks
     C                   movel     '*JOB'        $dev
     C                   endif
     C                   if        $form = *blanks
     C                   movel     '*STD'        $form
     C                   endif
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C******             close     oi2851pr
     C******             close     oi285pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OI2851PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *        NOTE: Ending array positions for $DEV 39, $FORM 60 are one
     *              greater than standard code. This is due to the
     *              extra character in the printer file name.
     *
     C                   movea     ovrprt(1)     a80
     C                   movea     $dev          a80(39)
     C                   movea     $form         a80(60)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *   Get device and form type for main report.
     *
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd
     C                   parm      'OI285PR '    $lrpt
     C                   parm      lstwhs        $whse
     C                   parm      *blanks       $styp
     C                   parm      *blanks       $whdp
     C                   parm                    $desc
     C                   parm                    $dev
     C                   parm                    $form
     C                   if        $dev = *blanks
     C                   movel     '*JOB'        $dev
     C                   endif
     C                   if        $form = *blanks
     C                   movel     '*STD'        $form
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OI285PR) OUTQ(*DEV) DEV($dev)
     *                  FORMTYPE($form)
     *
     C                   movea     ovrprt(2)     a80
     C                   movea     $dev          a80(38)
     C                   movea     $form         a80(59)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen
     *
     *      Open printer file.
     *
     C******             open      oi2851pr
     C******             open      oi285pr
     C                   eval      opened = *on
     *
     C                   endif

     p                 e

     *----------------------------------------------------------------
     *  ProcessDetail   Process import detail records for invoice rec
     *----------------------------------------------------------------

     p ProcessDetail   b
     d ProcessDetail   pi

      /free

       errorDetail = *off;

750aD  //setll (ivhwhse: ivhbatid: ivhrte: ivhinvoice: ivhorder) impsivcd;
750aM  setll (ivhwhs: ivhbatid: ivhinvoice: ivhorda) impsivcd;
       dow forever = forever;

750aD    //reade (ivhwhse: ivhbatid: ivhrte: ivhinvoice: ivhorder) impsivcd;
750aM    reade (ivhwhs: ivhbatid: ivhinvoice: ivhorda) impsivcd;
         if %eof(impsivcd);
           leave;
         endif;

         error = *off;

         //  Skip processed records.

         if ivdstatus <> 'R';
           iter;
         endif;

         // Verify data


         // Error occured

         if error = *on;

           errorDetail = *on;

           // Print error

750aD      //write detail;
           count += 1;

           // Update import record

           UpdateIVD('E': detmsg);

          iter;

         endif;

         // No error ...

         // Process weights

         ProcessWeights();
         if errorWeight;
           errorDetail = *on;
           iter;
         endif;

         // Write TTIVCD record

         FillIVD();

         write(e) tvdrec;
         if %error();
           errorDetail = *on;
           UpdateIVD('E': 'Error writing TTIVCD record');
         else;
           UpdateIVD('S': '');
         endif;

       enddo;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  ProcessHeader   Process import header records for batch id
     *----------------------------------------------------------------

     p ProcessHeader   b
     d ProcessHeader   pi

     *  Local Variables

     D lastInvoice     s                   like(ivhinvoice)
750aDD*lastOrder       s                   like(ivhorder)
750aMD lastOrder       s                   like(ivhorda)
     D lastRte         s                   like(ivhrte)
750aDD*lastWhse        s                   like(ivhwhse)
750aMD lastWhse        s                   like(ivhwhs)
750aAD lstInv          s                   like(ivhinvoice)
750aAD lstOrd          s                   like(ivhorda)
750aAD lstRte          s                   like(ivhrte)

      /free

       errorHeader = *off;

       lastWhse = -(1);
       lastRte = '@@@@@';

       setll ($pWhse: $pBatid) impsivch;
       dow forever = forever;

         reade ($pWhse: $pBatid) impsivch;
         if %eof(impsivch);
           leave;
         endif;

         error = *off;

         //  Skip processed records.

         if ivhstatus <> 'R';
           iter;
         endif;

         // Check for route change

         if lstRte <> ivhrte;
           lstInv = '@@@@@';
           lstRte = ivhrte;
         endif;

         // Check for invoice change

         if lstInv <> ivhinvoice;
           lstOrd = '@@@@@';
           lstInv = ivhinvoice;
         endif;

         // Check for order change

         if lstOrd <> ivhorda;
750aD      //WriteIVH();
750aD      //ivhordid = GetOrderId();
750aM      GetId();
           FillIVH();
           lstOrd = ivhorda;
         endif;

         //  Print report heading if necessary.

         if pflag = *on or count >= linppg;
750aD      //rdate = %dec(%char(%date():*mdy0):6:0);
           count = 0;
           //write head1;
           count += 3;
           pflag = *off;
         endif;

         // Verify data


         // Error occured

         if error = *on;

           errorHeader = *on;

           // Print error

750aD      //write detail;
           count += 1;

           // Update import record

           UpdateIVH('E': detmsg);

          iter;

         endif;

         // No error ...

         // Process detail

         ProcessDetail();
         if errorDetail;
           errorHeader = *on;
           iter;
         endif;

         // Write TTIVCH record

         FillIVH();

         write(e) tvhrec;
         if %error();
           errorHeader = *on;
           UpdateIVH('E': 'Error writing TTIVCH record');
         else;
           UpdateIVH('S': '');
         endif;

       enddo;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  ProcessWeights   Process import weight records for detail rec
     *----------------------------------------------------------------

     p ProcessWeights  b
     d ProcessWeights  pi

      /free

       errorWeight = *off;

750aD  //setll (ivdwhse: ivdbatid: ivdrte: ivdinvoice: ivhorder:
750aD  //       ivdosq: ivdseq: ivditem) impsivcc;
750aM  setll (ivdwhs: ivdbatid: ivdinvoice: ivdorda:
750aM         ivdseq) impsivcc;
       dow forever = forever;

750aD    //reade (ivdwhse: ivdbatid: ivdrte: ivdinvoice: ivhorder:
750aD    //       ivdosq: ivdseq: ivditem) impsivcc;
750aM    reade (ivdwhs: ivdbatid: ivdinvoice: ivdorda:
750aM           ivdseq) impsivcc;
         if %eof(impsivcc);
           leave;
         endif;

         error = *off;

         //  Skip processed records.

         if ivcstatus <> 'R';
           iter;
         endif;

         // Verify data


         // Error occured

         if error = *on;

           errorWeight = *on;

           // Print error

           //write detail;
           count += 1;

           // Update import record

           UpdateIVC('E': detmsg);

          iter;

         endif;

         // No error ...

         // Write TTIVCC record

         FillIVC();

         write(e) tvcrec;
         if %error();
           errorWeight = *on;
           UpdateIVC('E': 'Error writing TTIVCC record');
         else;
           UpdateIVC('S': '');
         endif;

       enddo;

      /end-free
     p                 e

750aA*----------------------------------------------------------------
750aA*  UpdateIVC   Update IMPSIVCC record
750aA*----------------------------------------------------------------

750aAp UpdateIVC       b
750aAd UpdateIVC       pi
750aAd  status                        1    const
750aAd  text                        200    const varying

750aA /free

750aA  ivcrteid = ivhrteid;
750aA  ivcordid = ivdordid;
750aA  ivcstatus = status;
750aA  ivctext = text;
750aA  GetStamps();
750aA  ivcststs = stamp;
750aA  ivcstsuc = stampuc;
750aA  update ivcrec;

750aA /end-free

750aAp                 e

     *----------------------------------------------------------------
     *  UpdateIVD   Update IMPSIVCD record
     *----------------------------------------------------------------

     p UpdateIVD       b
     d UpdateIVD       pi
750aAd  status                        1    const
750aAd  text                        200    const varying

      /free

750aA  ivdordid = ivhordid;
       ivdstatus = status;
       ivdtext = text;
       GetStamps();
       ivdststs = stamp;
       ivdstsuc = stampuc;
       update ivdrec;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  UpdateIVH   Update IMPSIVCH record
     *----------------------------------------------------------------

     p UpdateIVH       b
     d UpdateIVH       pi
750aAd  status                        1    const
750aAd  text                        200    const varying

      /free

       ivhstatus = status;
       ivhtext = text;
       GetStamps();
       ivhststs = stamp;
       ivhstsuc = stampuc;
       update ivhrec;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ZRHEAD   Print report headings.
     *----------------------------------------------------------------

     p zrHead          b
     d zrHead          pi

     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C******             write     head1
     C                   add       3             count
     C******             write     head2
     C                   add       2             count
     C******             write     head3
     C                   add       2             count
     C******             write     head4
     C                   add       2             count
     C                   setoff                                       81
     C                   endif

     p                 e

     *----------------------------------------------------------------
     *  zzgetdatetime  Get current date & time
     *----------------------------------------------------------------

     p zzGetDateTime   b
     d zzGetDateTime   pi

     C                   time                    curtime

     C                   if        curtime < lasttime or curdate = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     p                 e

     *----------------------------------------------------------------
     *  ZZINZ    Program initialization. Called from main line.
     *----------------------------------------------------------------

     p zzInz           b
     d zzInz           pi

     *
     * Get import date/time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
     *
     * Get report heading.
     *
750aDC*                  eval      w1head = *blanks
     C                   movel     rdsc(1)       $pstr
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
750aDC*                  movel     $pstr         w1head
     *
     *    Create heading for exceptions report.
     *
     C                   eval      $pstr = %trimr(rdsc(1)) + ' ' + exchdr
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
750aDC*                  movel     $pstr         w1hdr1
     C                   eval      *in92 = *on
     C                   eval      prhdr1 = *off
     C                   eval      excprt = *off
     C                   eval      excpr1 = *off
     *
     *    Format warehouse for heading
     *
      /free

         whcode = $pWhse;
         $pwhse = $pWhse;
         chain whcode warehs;
         if not %found(warehs);
           whdesc = *blanks;
         endif;

750aD    //whhead = %char($pWhse) + '-' + whdesc;

      /end-free
750aDC*                  call      'CENTER'
750aDC*                  parm      whhead        $cstr            60
750aDC*                  parm      40            $clen             3 0
750aDC*                  movel     $cstr         whhead

     p                 e

750bA*----------------------------------------------------------------
750bA*  zzzCrtxml     Create Trax XML file after successful import of invoices.
750bA*----------------------------------------------------------------
750bA
750bAp zzzCrtxml       b
750bAd zzzCrtxml       pi
750bA
750bAC                   call      'TR812'
750bAC                   parm      '*ROUTE'      $trcmd           10
750bAC                   parm      $pwhse        $trwhse           3 0
750bAC                   parm      tvhrteid      $trrtid           5
750bAC                   parm      ' '           $tremp#           5
750bAC                   parm      ' '           $trsFilesnd      30
750bAC                   parm      ' '           $trrtn            8
750bAC                   parm      ' '           $trerrmsg        60
750bA
750bAp                 e

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------

     p zzzEnd          b
     d zzzEnd          pi

      /free

        if importError;
          sbstatus = 'E';
          sbtext   = 'Import completed with error(s). See '
                    + %trimr(filnam)
                    + ' file.';
          $pReturn = '*ERROR';
          $pMessage = sbtext;
          filnam   = *blanks;
        else;
          sbstatus = 'S';
          sbtext   = 'Import completed successfully';
        endif;

        exec sql
          update stgbatch
          set sbstatus = :sbstatus,
              sbtext   = :sbtext,
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = %trimr(sbtext) + ' - '
                    + 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- oi285s/zzzend';
          return;
        endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  zzzStart   Start processing
     *----------------------------------------------------------------

     p zzzStart        b
     d zzzStart        pi

      /free

        exec sql
          update stgbatch
          set sbstatus = 'P',
750aM         sbtext   = 'Import started - Trax invoices',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbstrts  = current_timestamp,
              sbstruc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
750aM               + '- VC255S/zzzstart';
          return;
        endif;

        importError = *off;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     p clr$item        b
     d clr$item        pi

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#

     p                 e

     *----------------------------------------------------------------
     *  zzzdriclose   Close any open files or programs.
     *----------------------------------------------------------------

     p zzzDriClose     b
     d zzzDriClose     pi

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      chk4err = *off
     C                   eval      $drisys2upd = 'D'
750aDC*                  exsr      zzzdricop

750aA /free
750aA   zzzdricop();
750aA /end-free

     p                 e

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     p zzzDriCop       b
     d zzzDriCop       pi

     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   endif

     C                   select

     C                   when      %error and ck4err = *on
     C                   eval      error = *on

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     p                 e

     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
*EXIST*
*INVALID ITEM*
*BREAKDOWN INVALID*
*INVALID X-DOCK PO*
*XDK SLOT ERROR*
*NO XDK REC CREATED*
*QTY ORDERED PICKED*
*ORD ALREADY CLOSED*
*ERROR,CAN'T DELETE*
**
Import FTP Orders
**   OVRPRTF statment
OVRPRTF FILE(OI2851PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
OVRPRTF FILE(OI285PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
