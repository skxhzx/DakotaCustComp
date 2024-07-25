640aA /copy qcopysrc,hspecs
760 AH Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PI265S    Stage Import - Purchase orders
     *  14 February 2011
     *  Dave Sommerville
     *
     *  This program was based on PI265. All PI265 revision comments
     *  were kept in this program. See 640 notes.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
414 A*    11/02/00  DAS  4.14
     *      - Created
     *
415 A*    02/16/01  DAS  4.15
     *      - Revised ZZUPDD routine so that a detail line cannot
     *        be changed if it has already been received.
     *
417 A*    03/18/04  MLB  4.17
     *      - Enh: Added exception report PI2651PR to program.
CBI5A*    12/22/04  HNK  CBI5
     *      - Clear record code removed from FILLOD routine. Added
     *        just before calling FILLOD when type='A'
     *        CODE ORIGINALLY DATED 11/20/00 4.15 @ CBI.
     *
500 A*    01/14/05  MLB  5.00
     *      - Fix: Revised program to update delivery date/time
     *        when p/o status is 'C'.
500aA*    04/29/05  MLB  5.00a
     *      - Fix: Revised program to update vendor number for
     *        purchase order when p/o status is 'C'.
500bA*    04/29/05  MLB  5.00b
     *      - Enh: Revised program to add support for new Client id
     *        modifications.
     *
510 A*    06/08/06  MLB  5.10
     *      - Enh: Revised program to add support for new P/O header
     *        misc. file.
510aA*    09/27/06  MLB  5.10a
     *      - Enh: Revised 5.10 mod to make new file, IMPFPOHM an
     *        optional file.
     *
520aA*    11/05/08  MLB  5.20a
     *      - Enh: Revised program to use OUTQ instead of DEV when
     *        processing OVRPRTF cmd.
520bA*    12/11/08  MLB  5.20b
     *      - Enh: Revised program to add support for new P/O detail
     *        misc. file. This file is optional, but if used, there
     *        must be a record in the P/O detail misc. file for every
     *        record in the P/O detail file.
520cA*    02/26/09  MLB  5.20c
     *      - Enh: Revised program to load PIDODS into PDMODS when
     *        processing import p/o detail file.
520dA*    03/06/09  MLB  5.20d
     *      - Fix: Revised routine FILPDM to load item number from
     *        import file into PDMITM.
520eA*    10/12/09  MLB  5.20e
     *      - Fix: Revised routine ZZDEL to open POHDRM and PODTLM
     *        if not opened before attempting to delete rcds from files.
520fA*    10/21/09  MLB  5.20f
     *      - Fix: Revised program to update additional information
     *        when p/o status is 'C'.
     *
530 A*    09/01/10  MLB  5.30
     *      - Fix: Revised program after processing updates for p/o to
     *        ck p/o for any detail records and if there are no detail
     *        records remaining, delete p/o header record.
     *
640aA*    01/25/11  DAS  6.40a
     *      - Revised to used staging files impspoh/impspod instead
     *        of files impfpoh2/impfpohm/impfpod2/impfpodm.
640bA*    09/09/11  MLB  6.40b
     *      - Fix: Revised program to write out HEAD41 the first time
     *        when there is a terminal error when processing the import
     *        p/o header file.
     *      - Fix: Revised program to chain to PIRITEM file when import
     *        detail type not a valid code. This is done so that the
     *        item description will print for code exceptions.
     *
650 A*    01/22/13  MLB  6.50
     *      - Enh: Revised program to retrieve printer override for
     *        p/o import detail report, PI265PR so that import reportst
     *        can be directed where the user wants them to go.
650aA*    04/16/14  RTR  6.50a
     *      - Enh: hold for change from Chef's Whse
650bA*    02/05/15  RTR  6.50b
     *      - Fix: Not writing PODTLM records.
700a *    09/27/16  RTR  7.00a
     *      - Fix: Misc field update turned off by conversion to staging,
     *        changed mschup and mscdup to *YES to fix.
     *
710a *    09/27/17  RTR  7.10a
     *      - Enh: For NECS entree customers, also check PO History and
     *        if PO exists give error and do not import.
     *
720a *    09/18/18  RTR  7.20a
     *      - Enh: Added OPTIONINT value for checking history before
     *        importing PO. If PO in history, do not import. Replaces
     *        mod 710a.
     *      - Enh: Added Start/End logging in BFCLOG controlled by
     *        OPTIONINT flag.
720b *    10/29/18  RTR  7.20b
     *      - Enh: Added OPTIONINT value for using partial key PO/Seq,
     *        some customers don't send changes but send all lines.
     *        This was mod GFS in PI265, adding here with option switch.
     *
730a *    09/29/18  RTR  7.20b
     *      - Enh: Added OPTIONINT value for using partial key PO/Seq,
     *        some customers don't send changes but send all lines.
740aA*    03/06/20  DAS  7.40a
     *      - Added call to GetClient
750a *    05/14/21  RTR  7.50a
     *      - DockVue: Added update of POSTATUS table when PO added or
     *        updated.
     *
750bA*    10/01/21  TDC  7.50b
     *      - DockVue: (change 7.50a) added checks to verify insert/update
     *        of POSTATUS. If an insert fails, try an update. If update
     *        fails, try insert.
     *
750cA*    10/28/21  MLB  7.50c
     *      - DockVue: (change 7.50a) revised pgm to update status with
     *        'D' when purchase order is deleted when no items found.
     *
750dA*    10/28/21  TDC  7.50d
     *      - DockVue: (change 7.50a) revised pgm to only update the
     *        POSTATUS record when actual changes to POHDR or PODTL
     *        records.
760  *    09/02/22  KDE  7.60
     *      - Enh:  Add call to interface error reporting in Report
     *        Scheduler when import has a failure or error
760a *    10/24/22  DAS  7.60a
     *      - Added special code for NetSuite to add Delete records
     *        to IMPSPOD file.
760bA*    12/16/22  MLB  7.60b
     *      - Enh: Added special code for AFS to add Delete records
     *        to IMPSPOD file.
760c *    01/08/23  KDE  7.60c
     *      - Enh:  Change interface error report to R42600.  Also
     *        Add extended message for complete Stage Batch
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Aspen Clients
     *
ASPaA*    03/06/20  DAS  ASPa
     *      - Revised to append '-ww' to item numbers, where ww is
     *        the 2-digit warehouse
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Y.Hata
     *
YHT A*    05/10/10  MLB  YHT
     *      - Revised program to only update first 37 bytes of field
     *        PHVAD2.  Last 3 bytes of PHVAD2 are reserved for Frgt Code.
YHTbA*    12/02/10  RH   YHTb  P#01024
     *      - Revised program to only update first 31 bytes of field
     *        PHVAD2.  32 to 37 are reserved for container code.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*    12/15/10  MLB  CSP  P#01028
     *      - Revised program to only update first 34 bytes of field
     *        PHVAD2.  Last 6 bytes of PHVAD2 are reserved for Load Nbr.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hearn Kirkwood
     *
HKWa *    09/13/13  GJA  HKWa
     *      - Revised program to force XD for special code if item
     *        starts with 9999.                                       r.
     *
HKWb *    12/20/13  GJA  HKWb
     *      - Do not cross dock items starting with 999920, 999922,
     *        999930, 999932, 999934, 999940, 999942, and 999960      r.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Colony Foods
     *
CFIa *    04/15/21  RTR  CFIa
     *      - Revised to update PIRITEM, ITEMMSC with:
     *        Vendor number, vendor name, vendor item number.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sunrise Foods
     *
SUNa *    11/02/00  RTR  SUNa
     *      - changed description
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Big Apple Deli
     *
BADa *    04/08/21  RTR  BADa
     *      - Set vendors to vendor 1 to not  to not record PCM       ines
     *        truck and product temp, PreProcBADh
BADb *    07/13/21  LMC  BADb
     *      - Added vendor Golden Cannoli to the list of vendors that ines
     *        get set to vendor 1 in PreProcBADh
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic Produce
     *
EOPa *    10/17/18  RTR  EOPa
     *      - If PO detail message is same as item description, clear it.
     *
EOPb *    11/07/18  RTR  EOPb
     *      - If PO Detail message is blank, load pack description.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program assumes that there is only P.O.'s for one
     *    warehouse in the member.
     *
     *----------------------------------------------------------------
     * File Specs
     *
640aAFimpspoh   uf   e           k disk
640aAFimpspod   uf   e           k disk
640aDF*mpfpoh2  uf   e           k disk
650aDF*mpfpohm  uf   e           k disk    usropn
650aDF*mpfpod2  uf   e           k disk
640aDF*mpfpodm  uf   e           k disk    usropn
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Fpohdr     uf a e           k disk
640aDF*ohdrm    uf a e           k disk    usropn
640aMFpohdrm    uf a e           k disk
     Fpodtl     uf a e           k disk
640aDF*odtlm    uf a e           k disk    usropn
640aMFpodtlm    uf a e           k disk
     Fcrossdk3  if   e           k disk
     Fcrossdk2  uf   e           k disk
     Fordd      if   e           k disk
710aAFpohhdr    if   e           k disk    usropn
710aAFoptions   if   e           k disk
     Fpi265pr   o    e             printer oflind(*in91)
417 AFpi2651pr  o    e             printer oflind(*in92)
     F                                     usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
510 D*                   DESC    1   7 20
520bD*                   DESC    1   8 20
520bMD desc            s             20    dim(9) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
417 AD a80             s              1    dim(80)
650 DD*ovrprt          s             80    dim(1) ctdata perrcd(1)
650 MD ovrprt          s             80    dim(2) ctdata perrcd(1)
650aAD okchar          c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ+
650aAD                                      abcdefghijklmnopqrstuvwxyz+
650aAD                                      0123456789+
650aAD                                      .%/- ()*&$#!?='
500bA*----------------------------------------------------------------
500bA*  Customer id
500bA*
     D @getcl          c                   const('GETCLIENT')
740aA /copy qcopysrc,hostsystem
YHT A /COPY QCOPYSRC,ID#YHATA
CSP A /COPY QCOPYSRC,ID#COASTAL
HKWaA /COPY QCOPYSRC,ID#HKW
CFIaA /copy qcopysrc,id#cfi
EOPaA /copy qcopysrc,id#eop
SUNaA /copy qcopysrc,id#sun
BADaA /copy qcopysrc,id#bad
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
510 A*----------------------------------------------------------------
510 A*  Re-Definition data structures
510 A*
510 AD hdrmsc          ds
510 AD  pihbuy                 1      3
510 AD  pihbyn                 4     33
510 AD  pihmm1                 1     40
510aAD                 ds
510aAD  opnihm                 1      1
510aAD  opnhdm                 2      2
510aAD  mschup                 3      6
520bAD                 ds
520bAD  opnidm                 1      1
520bAD  opndtm                 2      2
520bAD  mscdup                 3      6
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
     *  Variables
     *
     D count           s              3  0                                      LINE COUNTER
HKWaAD chkitem         s              4
HKWbAD chkitem6        s              6
720aAd DebugFlag       s               n   inz('0')
EOPaAd chkpos          s              3  0
EOPaAd chkstr          s             30a
640aAD detailError     s               n
750dAD dockvuedupd     s               n   inz('0')
     D dtype           s              1
720bAd dtlCntOld       s              5  0
720bAd dtlCntNew       s              5  0
650 AD dtlDev          s             10
650 AD dtlForm         s             10
     D excprt          s              1
     D excpr1          s              1
640aMD forevr          s               n
     D good1           s              1
640aAD headerError     s               n
710aAD host            s             20a
640aAD importError     s               n
     D len             s              1  0
     D linppg          s              3  0                                      MAX LINES PER PAGE
     D lstdev          s             10
     D lstfrm          s             10
     D lstwhs          s              3  0
     D nodetl          s              4
750aAD nostamp         s               z     inz
     D opened          s              1
720aAd optChkHist      s               n   inz('0')
720bAd optPartKey      s               n   inz('0')
     D pflag           s              1
     D pos             s              1  0
     D prhdr1          s              1
710aAD reccnt          s              9  0
     D seq             s                   like(pidseq)
640aAD stamp           s               z
640aAD stampUC         s               z
     D sublin          s              3  0
     D subq1           s              7  0
     D subq2           s              7  0
     D subq3           s              7  0
     D svitem          s             15
     D wflag           s              1
     D wktime          s                   like(phtime)
     D work3a          s              3
760 AD currReport      s             20
760 AD url             s           3000
760 AD schEmail        s           1000
760 AD orient          s              1
760 AD grDev           s             10
760 Ad sbmusr          s             10
760 Ad sbmjobd         s             10
760 Ad sbmlibl         s             10
760 AD cmd             s           3000    varying
760 AD opmusr          s             10
760 Ad opjobd          s             10

760 A*----------------------------------------------------------------
760 A*  Sub-procedure prototypes
760 A*----------------------------------------------------------------

760 Ad getSchTimeEml   pr

640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql
730eA /copy qcopysrc,c#stdvar
760 AD/copy qcopysrc,p.mrcrptsc
760 AD/copy qcopysrc,p.qcmdexc
760cAd/copy qcopysrc,p.wIntLog

640aA*----------------------------------------------------------------
640aA*  File data data structure
640aA*----------------------------------------------------------------
640aA
640aAD sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

640aA*----------------------------------------------------------------
640aA*  Program info data structure
640aA*----------------------------------------------------------------
640aA /copy qcopysrc,c#pgminfds
720aA /copy *libl/qcopysrc,p.getopint
720aA /copy *libl/qcopysrc,p.wrtlog
640aA
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
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
640aA*      $pBatId - Batch id
     *
     *    Returned Parameters
640aA*      $pReturn  - Return code
640aA*      $pMessage - Return message
     *
     *----------------------------------------------------------------

640aAc     *entry        plist
640aAc                   parm                    $pWhse3A
640aAc                   parm                    $pBatId
640aAc                   parm                    $pReturn
640aAc                   parm                    $pMessage
640aA
640aAc                   eval      $pWhse = %dec($pWhse3A: 3: 0)
640aAc                   eval      $pReturn = '*OK'
640aAc                   eval      $pMessage = ' '
640aAC                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *
640aA* Update stgbatch record to start process
640aA*
640aAC                   exsr      zzzStart
640aAC                   if        $pReturn <> '*OK'
640aAC                   return
640aAC                   endif
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     rdsc(1)       $pstr
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     * Initialize grand total fields
     *
     C                   eval      hdradd = 0
     C                   eval      hdrchg = 0
     C                   eval      hdrdel = 0
     C                   eval      hdrrpl = 0
     C                   eval      hdroth = 0
     C                   eval      hdrttl = 0
     C                   eval      dtladd = 0
     C                   eval      dtlchg = 0
     C                   eval      dtldel = 0
     C                   eval      dtloth = 0
     C                   eval      dtlttl = 0
     C                   eval      ttlexc = 0
417 AC                   eval      prhdr1 = *off
760aA*
760aA* For NetSuite, need to look for deletes
760aA*
760aAC                   if        hostSys = netsuite
760bAC                             or hostSys = afs
760aAC                   exsr      NSDelete
760aAC                   endif
     *
     * Whip through all the download header records
     *
     C                   eval      wflag = *off
     C                   eval      pflag = *off
     C                   eval      linppg = 55                                  MAX LINES PER PAGE
     C                   eval      count = 0                                    LINE COUNTER
     *
640aAC     keypih        setll     impspoh
     C                   dow       forevr = forevr
     *
640aDC**                 read      impfpoh2                               79
640aMC     keypih        reade     impspoh                                79
     C                   if        *in79
     C                   leave
     C                   endif
510 A*
640aD **  Get P/O Header Misc. file
640aDC**                 if        mschup = '*YES'
640aDC**                 exsr      getmis
640aDC**                 endif
     *
     *   Create warehouse heading if necessary.
     *
     C                   if        wflag = *off  or
417 AC                             pihwhs <> lstwhs
     *
     C                   eval      whcode = pihwhs
     C     whcode        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   move      pihwhs        work3a
     C     ' 0'          check     work3a        pos
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
417 A*
417 A* Get Exception report heading.
417 A*
417 AC                   call      'GETRPT'
417 AC                   parm      '*DESC   '    $cmd              8
417 AC                   parm      'PI2651PR'    $lrpt            10
417 AC                   parm      pihwhs        $whse             3 0
417 AC                   parm      ' '           $styp             1
417 AC                   parm      ' '           $whdp             5
417 AC                   parm                    $desc            50
417 AC                   parm                    $dev             10
417 AC                   parm                    $form            10
417 A*
417 AC                   eval      $pstr = $desc
417 AC                   call      'CENTER'
417 AC                   parm                    $pstr
417 AC                   parm                    $plen
417 AC                   movel     $pstr         w1hdr1
417 A*
417 A* Open exception printer file.
417 A*
417 AC                   exsr      opnprt
417 A*
417 AC                   eval      *in92 = *on
417 AC                   eval      pflag = *off
417 A*
     C                   eval      wflag = *on
     C                   endif
     *
     *   Print report heading if necessary.
     *
417 AC                   eval      prhdr1 = *off
     C                   if        pflag = *off  or
     C                             count >= linppg
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   eval      pflag = *off
     C                   endif
640aA*
640aA*  Skip processed records.
640aA*
640aAC                   if        pihstatus <> 'R'
640aAC                   iter
640aAC                   endif
     *
     *   Update header totals
     *
     C                   add       1             hdrttl
     C                   select
     C                   when      pihtyp = 'A'
     C                   add       1             hdradd
     C                   when      pihtyp = 'C'
     C                   add       1             hdrchg
     C                   when      pihtyp = 'D'
     C                   add       1             hdrdel
     C                   when      pihtyp = 'R'
     C                   add       1             hdrrpl
     C                   other
     C                   add       1             hdroth
     C                   endsl
BADaA*
     *   Do any HEADER preprocessing.
BADaA /free
BADaA   select;
BADaA     when client = BigApple;
BADaA       exsr PreProcBADh;
BADaA   endsl;
BADaA /end-free
     *
     *   Do as user instructed.
     *
     C                   eval      hedmsg = *blanks
640aAC                   eval      headerError = *off
     C                   eval      error = *off
530 AC                   eval      nodetl = '*NO '
720aA /free
720aA   // Check if PO already received.
720aA   if optChkHist;
720aA     reccnt = 0;
720aA     exec sql select count(*) into :reccnt
720aA                from pohhdr
720aA               where phhwhs = : pihwhs
720aA                 and phhpo = : pihpo;
720aA     if sqlstt = sqlSuccess
720aA      and reccnt > 0;
720aA       hedmsg = desc(4);
720aA       ttlexc =ttlexc + 1;
720aA       error = *on;
720aA       headerError = *on;
720aA       pihtext = %trim(pihtext) + ' ' + hedmsg;
720aA /end-free
720aAc                   goto      enddoh
720aA /free
720aA     endif;
720aA   endif;
720aA /end-free
720bA /free
720bA   if optPartKey;
720bA     // Compare line counts to see if line deleted
720bA     dtlCntOld = 0;
720bA     dtlCntNew = 0;
720bA     exec sql select count(*) into :dtlCntOld
720bA                from podtl
720bA               where pdwhse = :pihwhs
720bA                 and pdpo = :pihpo;
720bA     exec sql select count(*) into :dtlCntNew
720bA                from impspod
720bA               where pidwhs = :pihwhs
720bA                 and pidbatid = :pihbatid
720bA                 and pidpo = :pihpo;
720bA     // if line deleted, try to delete PO to start clean
720bA     if dtlCntOld > dtlCntNew;
720bA       exsr zzdel;
720bA     endif;
720bA   endif;
720bA /end-free
     *
     C                   select
     *
     *     Delete P.O.
     *
     C                   when      pihtyp = 'D'
     C                   exsr      zzdel
     *
     *     Add/Change/Replace.
     *
     C                   when      pihtyp = 'A'  or
     C                             pihtyp = 'C'  or
     C                             pihtyp = 'R'
     C                   exsr      zzupdh
510 A*     Update P/O header misc. file.
640aDC**                 if        mschup = '*YES'
510 AC                   exsr      zzuphm
640aDC**                 endif
     *
     *     Ignore because of invalid type.
     *
     C                   other
     C                   eval      hedmsg = desc(2)
640aAC                   eval      headerError = *on
640aAC                   eval      pihtext = %trim(pihtext) + ' ' + hedmsg
     C                   endsl
     *
     *   Print order heading
     *
     C                   if        pflag = *off
     C                   write     head2
     C                   add       2             count
     C                   endif
     *
     C                   write     head3
     C                   add       2             count
     *
     C                   if        pflag = *off
     C                   write     head4
     C                   add       2             count
     C                   eval      pflag = *on
     C                   endif
417 A*
417 A*    Exception occurred, print on report.
417 A*
417 AC                   select
417 AC                   when      hedmsg > *blanks
417 A*
417 A*    Print exception report page headings.
417 AC                   if        *in92
417 AC                   write     head11                               92
417 AC                   write     head21
417 AC                   endif
417 AC                   write     head31
640bAC                   write     head41
417 A*    Set on flag that purchase order heading printed already.
417 AC                   eval      prhdr1 = *on
417 A*
417 AC                   endsl
     *
     *   Skip detail if error or deleting P.O.
     *
     C                   if        error = *on  or
     C                             pihtyp = 'D'
     C                   goto      enddoh
     C                   endif
     *
     *   Initialize order subtotals
     *
     C                   eval      sublin = 0
     C                   eval      subq1 = 0
     C                   eval      subq2 = 0
     C                   eval      subq3 = 0
417 AC                   eval      subq11 = *zeros
417 AC                   eval      subq21 = *zeros
417 AC                   eval      subq31 = *zeros
750dAC                   eval      dockvuedupd = *off
     *
     *   Whip through all the download detail records
     *
417 AC                   eval      excpr1 = *off
640aDC**   pidkey        setll     impfpod2
640aMC     pidkey        setll     impspod
     C                   dow       forevr = forevr
     *
640aDC**   pidkey        reade     impfpod2                               78
640aMC     pidkey        reade     impspod                                78
     C                   if        *in78
     C                   leave
     C                   endif
ASPaA
ASPaA* For Aspen clients, append warehouse to item number
ASPaA /free
ASPaA  if hostSys = Aspen;
ASPaA    piditm = %trim(piditm) + '-' + %subst(%editc(pidwhs:'X'):2:2);
ASPaA  endif;
ASPaA /end-free
520bA*
640aD **  Get P/O Detail Misc. file
640aDC**                 if        mscdup = '*YES'
640aDC**                 exsr      gtpodm
640aDC**                 endif
640aA*
640aA*  Skip processed records.
640aA*
640aAC                   if        pidstatus <> 'R'
640aAC                   iter
640aAC                   endif
     *
     *      Update detail totals
     *
     C                   add       1             dtlttl
     C                   select
     C                   when      pidtyp = 'A'
     C                   add       1             dtladd
     C                   when      pidtyp = 'C'
     C                   add       1             dtlchg
     C                   when      pidtyp = 'D'
     C                   add       1             dtldel
     C                   other
     C                   add       1             dtloth
     C                   endsl
     *
     *      Do as user instructed.
     *
     C                   eval      itdesc = *blanks
     C                   eval      detmsg = *blanks
640aAC                   eval      detailError = *off
     C                   eval      good1 = 'N'
     C                   eval      error = *off
     *
     C                   select
     *
     *        Delete P.O. detail line
     *
     C                   when      pidtyp = 'D'
     C                   exsr      zzdeld
     *
     *        Add/Change
     *
     C                   when      pidtyp = 'A'  or
     C                             pidtyp = 'C'
     C                   exsr      zzupdd
520bA*
520bA*     Update P/O detail misc. file.
650bDC*                  if        mscdup = '*YES'  and
520bA*     No error writing P/O Detail record.
650bDC*                            not *in49  and
650bMC                   if        not *in49  and
520bA*     Item master record on file.
520bAC                             not *in76
520bAC                   exsr      zzupdm
520bAC                   endif
     *
     *         Ignore because of invalid type.
     *
     C                   other
640bAC     itkey         chain     piritem
640bAC                   if        %eof(piritem)
640bAC                   eval      itdesc = *blanks
640bAC                   eval      itdesc = '*****'
640bAC                   endif
     C                   eval      detmsg = desc(2)
640aAC                   eval      detailError = *on
640aAC                   eval      pidtext = %trim(pidtext) + ' ' + detmsg
     C                   endsl
     *
     *       Print order detail and update subtotals
     *
     C                   exsr      zrhead
     C                   write     detail
     *
     C                   add       1             count
     C                   add       1             sublin
     C                   add       pidqo1        subq1
     C                   add       pidqo2        subq2
     C                   add       pidqo3        subq3
     *
     *       Delete detail record from download file
640aA*       Staging file records do not get deleted when processed.
     *
640aDC**                 delete    pidrec
520bA*
640aA ** Delete Detail misc. record from download file.
640aA ** Ignore not found.
640aAC**                 if        mscdup = '*YES'
640aDC**                 delete    pidmrc                               71
640aDC**                 endif
417 A*
417 A*       Exception occurred, print on report.
417 AC                   select
417 AC                   when      detmsg > *blanks
417 A*
417 A*    Turn on flag to indicate at least one exception printed.
417 A*    Print grand totals when complete.
417 AC                   eval      excprt = *on
417 A*    Turn on flag to indicate at least one exception printed.
417 A*    Print sub totals when complete.
417 AC                   eval      excpr1 = *on
417 A*
417 AC                   add       pidqo1        subq11
417 AC                   add       pidqo2        subq21
417 AC                   add       pidqo3        subq31
417 A*
417 A*    Print exception report page headings.
417 AC                   if        *in92
417 AC                   write     head11                               92
417 AC                   write     head21
417 AC                   write     head31
417 AC                   write     head41
417 AC                   eval      prhdr1 = *on
417 AC                   endif
417 A*
417 A*    Print exception report Customer info and headings.
417 AC                   if        prhdr1 = *off
417 AC                   write     head31                               92
417 AC                   eval      prhdr1 = *on
417 AC                   endif
417 A*
417 A*    Print exception report page headings.
417 AC                   if        *in92
417 AC                   write     head11                               92
417 AC                   write     head21
417 AC                   write     head31
417 AC                   write     head41
417 AC                   endif
417 A*
417 AC                   write     detail1                              92
417 A*
417 AC                   endsl
     *
     C     enddod        tag

640aAC                   if        detailError
640aAC                   eval      importError = *on
640aAC                   eval      pidstatus = 'E'
640aAC                   else
640aAC                   eval      pidstatus = 'S'
640aAC                   endif
640aAC                   exsr      zzzGetStamps
640aAC                   eval      pidststs = stamp
640aAC                   eval      pidstsuc = stampuc
640aAC                   update    pidrec

     C                   enddo
     *
     *    Print order subtotals and update grand totals
     *
     C                   write     subttl
     C                   add       3             count
417 A*
417 A*    Print Order exception subtotals.
417 AC                   if        excpr1 = *on
417 AC                   if        *in92
417 AC                   write     head11                               92
417 AC                   write     head21
417 AC                   write     head31
417 AC                   write     head41
417 AC                   endif
417 AC                   write     subttl1                              92
417 AC                   endif
     *
     C     enddoh        tag
530 A*
530 A*  Check p/o to see if items still attached. If no, delete p/o.
530 AC     pohkey        setll     podtl                                  63
530 AC                   if        not *in63
530 AC                   eval      nodetl = '*YES'
530 A*  Since no items attached, ignore p/o status.
530 AC                   exsr      zzdel
530 AC                   eval      nodetl = '*NO '
530 AC                   endif
     *
     *  Delete header record from download file
640aA*       Staging file records do not get deleted when processed.
     *
640aDC**                 delete    pihrec
640aD ** Delete header misc. record from download file.
640aD ** Ignore not found.
640aDC**                 if        mschup = '*YES'
640aDC**                 delete    pihmrc                               72
640aDC**                 endif

640aAC                   if        headerError
640aAC                             or detailError
640aAC                   eval      importError = *on
640aAC                   eval      pihstatus = 'E'
640aAC                   if        detailError
640aAC                   eval      pihtext = %trim(pihtext) + ' - '
640aAC                                     + 'Error occured with a Detail line'
640aAC                   endif
640aAC                   else
640aAC                   eval      pihstatus = 'S'
640aAC                   endif
640aAC                   exsr      zzzGetStamps
640aAC                   eval      pihststs = stamp
640aAC                   eval      pihstsuc = stampuc
640aAC                   update    pihrec
750dAC                   if        dockvuedupd = '1'
750dA /free
750dA   // Set status for DockVue when any changes to p/o detail.
750dA   exec sql insert into postatus
750dA            values (:phwhse, :phpo, :phstat,
750dA                    current_timestamp, :nostamp);
750dA*
750dA   if sqlstt <> sqlSuccess;
750dA   exec sql update postatus
750dA               set posstat = :phstat,
750dA                   posupdts = current_timestamp
750dA             where poswhs = :phwhse
750dA               and pospo = :phpo;
750dA   endif;
750dA /end-free
750dAC                   endif
     *
     C                   enddo
     *
     *  Print order grand totals
     *
     C                   if        pflag = *on
     C                   if        count >= linppg
     C                   write     head1
     C                   endif
     C                   write     grndttl
     C                   endif
417 A*
417 A*    Print exception grand totals.
417 AC                   if        excprt = *on
417 AC                   if        *in92
417 AC                   write     head11                               92
417 AC                   endif
417 AC                   write     grndttl1
417 AC                   endif
417 A*
     *
     *  We are finished so get out
     *
640aAC                   exsr      zzzEnd
640aDC**                 eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
500bA*
500bA* Get client id.
500bA*
500bAC                   call      @getcl
500bAC                   parm      *blanks       client           10
500bAC                   parm      *blanks       cliloc           10
740aAC                   parm                    cliInit           3
740aAC                   parm                    hostSys          10
500bA*
     C                   eval      forevr = *off
     C                   eval      error = *off
510aAC                   eval      opnihm = *off
510aAC                   eval      opnhdm = *off
700aDC**                 eval      mschup = '*NO '
700aMC                   eval      mschup = '*YES'
520bAC                   eval      opnidm = *off
520bAC                   eval      opndtm = *off
700aDC**                 eval      mscdup = '*NO '
700aMC                   eval      mscdup = '*YES'
530 AC                   eval      nodetl = '*NO '
     *
     * Key definitions
640aA*
640aA*  Define key for impspoh file.
640aA*
640aAC     keypih        klist
640aAC                   kfld                    $pWhse
640aAC                   kfld                    $pBatId
     *
     * Download purchase order detail file - Partial key
     *
     C     pidkey        klist
     C                   kfld                    pihwhs
640aAC                   kfld                    pihBatId
     C                   kfld                    pihpo
640aDC**                 kfld                    pihcdt
640aDC**                 kfld                    pihctm
     *
     * P.O. Header file - Partial key
     *
     C     pohkey        klist
     C                   kfld                    pihwhs
     C                   kfld                    pihpo
     *
     * P.O. Detail file - Partial key
     *
     C     podkey        klist
     C                   kfld                    pihwhs
     C                   kfld                    pihpo
     *
     * P.O. Detail file - Full key
     *
     C     podkyf        klist
     C                   kfld                    pidwhs
     C                   kfld                    pidpo
     C                   kfld                    pidseq
     C                   kfld                    piditm
720bA*
720bA* P.O. Detail file - Partial key
720bA*
720bAC     podkyp        klist
720bAC                   kfld                    pidwhs
720bAC                   kfld                    pidpo
720bAC                   kfld                    pidseq
640aD **
640aD **Import P.O. Detail Misc. file - Full key
640aD **
640aDC**   podmky        klist
640aDC**                 kfld                    pidwhs
640aDC**                 kfld                    pidpo
640aDC**                 kfld                    pidcdt
640aDC**                 kfld                    pidctm
640aDC**                 kfld                    pidseq
640aDC**                 kfld                    piditm
520bA*
520bA* P.O. Detail Misc. file - Full key
520bA*
520bAC     pdmkey        klist
520bAC                   kfld                    pidwhs
520bAC                   kfld                    pidpo
520bAC                   kfld                    pidseq
520bAC                   kfld                    piditm
720bA*
720bA* P.O. Detail Misc. file - Partial key
720bA*
720bAC     pdmkyp        klist
720bAC                   kfld                    pidwhs
720bAC                   kfld                    pidpo
720bAC                   kfld                    pidseq
     *
     * Item file
     *
     C     itkey         klist
     C                   kfld                    pidwhs
     C                   kfld                    piditm
     *
     * Cross Dock file
     *
     C     xdkey         klist
     C                   kfld                    pidwhs
     C                   kfld                    pidpo
     C                   kfld                    seq
     *
     * Order detail file.
     *
     C     odkey         klist
     C                   kfld                    pidwhs
     C                   kfld                    cdord
     C                   kfld                    cdorsq
     C                   kfld                    svitem
     *
     * CROSSDK3 file.
     *
     C     xd3key        klist
     C                   kfld                    pidwhs
     C                   kfld                    pdpo
     C                   kfld                    pdseq
640aD **
640aD **Open IMPFPOHM file.
640aDC**                 if        opnihm <> *on
640aDC**                 open      impfpohm                             68
640aDC**                 if        not *in68
640aDC**                 eval      opnihm = *on
640aDC**                 eval      mschup = '*YES'
640aDC**                 else
640aDC**                 eval      mschup = '*NO '
640aDC**                 endif
640aDC**                 endif
640aD**
640aD**Open POHDRM file if import file was sent.
610aDC**                 if        opnhdm <> *on  and
610aDC**                           mschup = '*YES'
610aDC**                 open      pohdrm                               68
610aDC**                 if        not *in68
610aDC**                 eval      opnhdm = *on
610aDC**                 eval      mschup = '*YES'
610aDC**                 else
610aDC**                 eval      mschup = '*NO '
610aDC**                 endif
610aDC**                 endif
610aD**
610aD**Open IMPFPODM file.
610aDC**                 if        opnidm <> *on
610aDC**                 open      impfpodm                             68
610aDC**                 if        not *in68
610aDC**                 eval      opnidm = *on
610aDC**                 eval      mscdup = '*YES'
610aDC**                 else
610aDC**                 eval      mscdup = '*NO '
610aDC**                 endif
610aDC**                 endif
610aD**
610aD**Open PODTLM file if import file was sent.
610aDC**                 if        opndtm <> *on  and
610aDC**                           mscdup = '*YES'
610aDC**                 open      podtlm                               68
610aDC**                 if        not *in68
610bDC**                 eval      opndtm = *on
610bDC**                 eval      mscdup = '*YES'
610aDC**                 else
610aDC**                 eval      mscdup = '*NO '
610aDC**                 endif
610aDC**                 endif

710aA*
710aA* OPTIONS Options file - Full key
710aA*
710aAC     opkey         klist
710aAC                   kfld                    opwhse
710aAC                   kfld                    opcode
710aA*
710aA*   Get import item fields options.
710aA*
710aAC                   eval      opwhse = %dec($pWhse3A: 3: 0)
710aAC                   eval      opcode = '*HOST   '
710aAC     opkey         chain     options
710aAC                   if        %found(options)
710aAC                   eval      host = opdata
710aAC                   else
710aAC                   eval      host = *blanks
710aAC                   endif
710aA*
710aA* Open CUSTMISC file if NECS entree host.
710aAC                   if        host = 'NECS-ENTREE'
710aAC                             and not %open(pohhdr)
710aAC                   open      pohhdr
710aAC                   endif
720aA*
720aA*   Get option for checking PO history to prevent importing received
720aA*
720aA /free
720aA   // Get Check History Flag
720aA   optint.type = 'Interface   ';
720aA   optint.cat  = 'Import POs          ';
720aA   optint.name = 'If In History Skip  ';
720aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
720aA             optint.valn: optint.vala: optint.return);
720aA   if optint.return = '*OK'
720aA    and optint.vala = 'Y';
720aA     optChkHist = *on;
720aA   else;
720aA     optChkHist = *off;
720aA   endif;
720aA /end-free
720bA*
720bA*   Get option for using partial key PO/seq
720bA*
720bA /free
720bA   // Get Partial Key PO/Seq Flag
720bA   optint.type = 'Interface   ';
720bA   optint.cat  = 'Import POs          ';
720bA   optint.name = 'Partial Key PO/Seq  ';
720bA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
720bA             optint.valn: optint.vala: optint.return);
720bA   if optint.return = '*OK'
720bA    and optint.vala = 'Y';
720bA     optPartKey = *on;
720bA   else;
720bA     optPartKey = *off;
720bA   endif;
720bA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLOD  Fill order detail fields.
     *
     C     fillod        begsr
     *
CBI5D*  Initialize record
CBI5D*
CBI5D**                   CLEARPDREC
     *
     *  Move fields from download file to purchase order detail fields
     *
750dA*       Turn on DockVue update flag if changes.
750dAC                   if           pditem <> piditm
750dAC                             or pdqor1 <> pidqo1
750dAC                             or pdqor2 <> pidqo2
750dAC                             or pdqor3 <> pidqo3
750dAC                             or pdvitm <> pidvit
750dAC                             or pdspcl <> pidspc
750dAC                   eval      dockvuedupd = '1'
750dAC                   endif
750dA*
     C                   eval      pdwhse = pidwhs
     C                   eval      pdpo = pidpo
     C                   eval      pdseq = pidseq
     C                   eval      pditem = piditm
     C                   eval      pdqor1 = pidqo1
     C                   if        itflg1 = 'Y'
     C                   eval      pdqor2 = pidqo2
     C                   else
     C                   eval      pdqor2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   eval      pdqor3 = pidqo3
     C                   else
     C                   eval      pdqor3 = 0
     C                   endif
HKWaA*  If Hearn Kirkwood and item starts with 9999 force XD
HKWaAC                   select
HKWaAC                   when      client = hkw  and
HKWaAc                             %subst(pditem:1:4) = '9999'
HKWbAc                   eval      chkitem6 = %subst(pditem:1:6)
HKWbAC                   if        chkitem6 <> '999920' and
HKWbAC                             chkitem6 <> '999922' and
HKWbAC                             chkitem6 <> '999930' and
HKWbAC                             chkitem6 <> '999932' and
HKWbAC                             chkitem6 <> '999934' and
HKWbAC                             chkitem6 <> '999940' and
HKWbAC                             chkitem6 <> '999942' and
HKWbAC                             chkitem6 <> '999960'
HKWbAC                   eval      pdspcl = 'XD'
HKWbAC                   else
HKWaAC                   eval      pdspcl = pidspc
HKWbAC                   endif
HKWaAC                   other
HKWaAC                   eval      pdspcl = pidspc
HKWaAC                   endsl
HKWaA*
HKWaDC*                  eval      pdspcl = pidspc
     C                   eval      pdvitm = pidvit
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLOH   Fill purchase order header fields.
     *
     C     filloh        begsr
     *
     *  Initialize record
     *
     C                   clear                   phrec
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      phwhse = pihwhs
     C                   eval      phpo = pihpo
     C                   eval      phven = pihven
SUNaAc                   if        client = Sunrise
SUNaAc                             and pihvna = 'La Espaola Meats, Inc.'
SUNaAc                   eval      phvnam = 'La Española Meats, Inc.'
SUNaAc                   else
     C                   eval      phvnam = pihvna
SUNaAc                   endif
     C                   eval      phvad1 = pihva1
     C                   eval      phvad2 = pihva2
     C                   eval      phvcty = pihvct
     C                   eval      phvst = pihvst
     C                   eval      phvzp1 = pihvzp
     C                   eval      phstat = *off
     C                   move      pihdte        phdate
     C                   eval      phtime = pihtim
     C                   eval      phampm = *blanks
     *
     C                   endsr
510 A*
510 A*----------------------------------------------------------------
510 A*
510 A*  FILPHM   Fill purchase order header misc. fields.
510 A*
510 AC     filphm        begsr
510 A*
510 A*  Move fields from download file to purchase order hdr misc. fields
510 A*
510 AC                   eval      phmm1 = pihmm1
510 AC                   eval      phmm2 = pihmm2
510 AC                   eval      phmm3 = pihmm3
510 AC                   eval      phmm4 = pihmm4
510 AC                   eval      phmm5 = pihmm5
510 A*
510 AC                   endsr
520bA*
520bA*----------------------------------------------------------------
520bA*
520bA*  FILPDM   Fill purchase order detail misc. fields.
520bA*
520bAC     filpdm        begsr
520bA*
520bA*  Move fields from download file to purchase order dtl misc. fields
520bA*
520dAC                   eval      pdmseq = pidseq
520dAC                   eval      pdmitm = piditm
520dA*
520cAC                   eval      pdmods = pidods
520bAC                   eval      pdmpom = pidpom
520bAC                   eval      pdmms1 = pidms1
520bAC                   eval      pdmms2 = pidms2
520bAC                   eval      pdmms3 = pidms3
520bAC                   eval      pdmms4 = pidms4
520bAC                   eval      pdmms5 = pidms5
520bA*
520bAC                   endsr
510 A*
640aD *----------------------------------------------------------------
640aD **
640aD ** GETMIS  Get P/O Header Misc.
640aD **
640aDC**   getmis        begsr
640aD **
640aDC**   pidkey        chain     impfpohm                           72
640aDC**                 if        *in72
640aDC**                 eval      pihmm1 = *blanks
640aDC**                 eval      pihmm2 = *blanks
640aDC**                 eval      pihmm3 = *blanks
640aDC**                 eval      pihmm4 = *blanks
640aDC**                 eval      pihmm5 = *blanks
640aDC**                 endif
640aD **
640aDC**                 endsr
640aD **
640aD *----------------------------------------------------------------
640aD **
640aD ** GTPODM  Get P/O Detail Misc.
640aD **
640aDC**   gtpodm        begsr
640aD **
640aDC**   podmky        chain     impfpodm                           70
640aDC**                 if        *in70
640aDC**                 eval      pidods = *blanks
640aDC**                 eval      pidpom = *blanks
640aDC**                 eval      pidms1 = *blanks
640aDC**                 eval      pidms2 = *blanks
640aDC**                 eval      pidms3 = *blanks
640aDC**                 eval      pidms4 = *blanks
640aDC**                 eval      pidms5 = *blanks
640aDC**                 endif
640aD **
640aDC**                 endsr
520bA*
417 A*----------------------------------------------------------------
417 A*
417 A*  OPNPRT  Open printer file.
417 A*
417 AC     opnprt        begsr
417 A*
417 A*   Get device and form type for department.
417 A*
417 AC                   if        pihwhs <> lstwhs
650 A *
650 AC                   call      'GETRPT'
650 AC                   parm      '*DEVFORM'    $cmd
650 AC                   parm      'PI265PR'     $lrpt
650 AC                   parm      pihwhs        $whse
650 AC                   parm      ' '           $styp
650 AC                   parm      ' '           $whdp
650 AC                   parm                    $desc
650 AC                   parm                    $dev
650 AC                   parm                    $form
650 AC                   eval      dtlDev = $dev
650 AC                   eval      dtlForm = $form
650 A *
417 AC                   call      'GETRPT'
417 AC                   parm      '*DEVFORM'    $cmd
417 AC                   parm      'PI2651PR'    $lrpt
417 AC                   parm      pihwhs        $whse
417 AC                   parm      ' '           $styp
417 AC                   parm      ' '           $whdp
417 AC                   parm                    $desc
417 AC                   parm                    $dev
417 AC                   parm                    $form
417 AC                   eval      lstwhs = $whse
417 AC                   endif
417 A*
417 A*   Open printer file for department.
417 A*
417 AC                   if        opened <> *on  or
417 AC                             $dev <> lstdev  or
417 AC                             $form <> lstfrm
650 AC                             or not %open(pi265pr)
417 A*
417 A*      If printer already open then close it.
417 A*
417 AC                   if        opened = *on
417 AC                   close     pi2651pr
417 AC                   endif
650 A*
650 AC                   if        %open(pi265pr)
650 AC                   close     pi265pr
650 AC                   endif
417 A*
417 A*      Override printer file.
417 A*
417 A*          OVRPRTF FILE(PI2651PR) OUTQ(*DEV) DEV($dev)
417 A*                  FORMTYPE($form)
417 A*
417 AC                   movea     ovrprt(1)     a80
417 AC                   movea     $dev          a80(39)
417 AC                   movea     $form         a80(60)
417 AC                   movea     a80           qcmd
417 A*
417 AC                   call      'QCMDEXC'
417 AC                   parm                    qcmd             80
417 AC                   parm      80            qlen             15 5
417 A*
417 A*      Open printer file.
417 A*
417 AC                   open      pi2651pr
417 AC                   eval      opened = *on
417 AC                   eval      lstdev = $dev
417 AC                   eval      lstfrm = $form
650 A*
650 A*     Override printer file.
650 A*
650 A*         OVRPRTF FILE(PI265PR) OUTQ(*DEV) DEV($dev)
650 A*                 FORMTYPE($form)
650 A*
650 AC                   movea     ovrprt(2)     a80
650 AC                   movea     dtlDev        a80(39)
650 AC                   movea     dtlForm       a80(60)
650 AC                   movea     a80           qcmd
650 A*
650 AC                   call      'QCMDEXC'
650 AC                   parm                    qcmd             80
650 AC                   parm      80            qlen             15 5
650 A*
650 A*      Open Detail printer file.
650 A*
650 AC                   open      pi265pr
417 A*
417 AC                   endif
417 A*
417 AC                   endsr
BADaA*----------------------------------------------------------------
BADaA*  PreProcBADh   Pre-process records - Big Apple Header
BADaA /free
BADaA   begsr PreProcBADh;
BADaA     select;
BADaA       when pihmm1 ='ALYSSA';
BADaA         pihven = 1;
BADaA       when pihmm1 ='MYDADS';
BADaA         pihven = 1;
BADaA       when pihmm1 ='VIGNER';
BADaA         pihven = 1;
BADaA       when pihmm1 ='BARRY ';
BADaA         pihven = 1;
BADbA       when pihmm1 ='GOLDCA';
BADbA         pihven = 1;
BADaA     endsl;
BADaA   endsr; // PreProcBADh
760aA*----------------------------------------------------------------
760aA*
760aA*  NSDelete - Create Delete recs for Netsuite
760aA*
760aA*    When NetSuite deletes a PO Detail line, the import does not
760aA*    send that line. Therefore, we will look for any missing
760aA*    lines and create IMPSPOD Delete records.
760aA*
760aAC     NSDelete      begsr

        exec sql
          insert into impspod
            (pidwhs, pidbatid, pidtyp, pidstatus, pidststs,
             pidpo, pidseq, piditm, pidtext, pidaddts)
          select pdwhse, :$pBatId, 'D', 'R', current_timestamp,
                 pdpo, pdseq, pditem,
                 'Created by PI265S', current_timestamp
          from podtl
          where not exists
            (select pidpo
             from impspod
             where pidbatid = :$pBatId
               and pidwhs=pdwhse and pidpo=pdpo
               and pidseq=pdseq and piditm=pditem);

        if sqlstt <> sqlSuccess;
        endif;

     C                   endsr
     *----------------------------------------------------------------
     *
     *  UPDXDK  Zero out PO seq #, when PO detail line is deleted.
     *
     C     updxdk        begsr
     C     xd3key        setll     crossdk3
     C                   dow       forevr = forevr
     C     xd3key        reade     crossdk3                               79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   eval      svitem = oditem
     C                   if        oditem = pditem
     C     xd3key        setll     crossdk2
     C                   dow       forevr = forevr
     C     xd3key        reade     crossdk2                               77
     *
     C                   if        *in77
     C                   leave
     C                   endif
     C     odkey         chain     ordd                               75
     C                   if        not *in75
     C                   eval      cdposq = 0
     C                   update    cdrec
     C                   leave
     C                   else
     C                   iter
     C                   endif
     C                   enddo
     *
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZBKDN  Check breakdown quanties.
     *
     C     zzbkdn        begsr
     *
     C                   if        pidqo2 <> 0  and
     C                             itflg1 <> 'Y'
     C                   eval      detmsg = desc(7)
     C                   add       1             ttlexc
640aAC                   eval      detailError = *on
640aAC                   eval      pidtext = %trim(pidtext) + ' ' + detmsg
     C                   endif
     *
     C                   if        pidqo3 <> 0  and
     C                             itflg2 <> 'Y'
     C                   eval      detmsg = desc(7)
     C                   add       1             ttlexc
640aAC                   eval      detailError = *on
640aAC                   eval      pidtext = %trim(pidtext) + ' ' + detmsg
     C                   endif
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   if        pidqo1 <> 0
     C                   eval      good1 = 'Y'
     C                   else
     C                   if        pidqo2 <> 0  and
     C                             itflg1 = 'Y'
     C                   eval      good1 = 'Y'
     C                   else
     C                   if        pidqo3 <> 0  and
     C                             itflg2 = 'Y'
     C                   eval      good1 = 'Y'
     C                   endif
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDEL   Delete P.O.
     *
     C     zzdel         begsr
710aA*
710aA*  For entree, check for history record. Get out if found.
710aA*
710aA /free
720aD * if host = 'NECS-ENTREE';
720aA   if host = 'NECS-ENTREE'
720aA    or optChkHist;
710aA     reccnt = 0;
710aA     exec sql select count(*) into :reccnt
710aA                from pohhdr
710aA               where phhwhs = : pihwhs
710aA                 and phhpo = : pihpo;
710aA     if sqlstt = sqlSuccess
710aA      and reccnt > 0;
710aA       hedmsg = desc(4);
710aA       ttlexc =ttlexc + 1;
710aA       error = *on;
710aA       headerError = *on;
710aA       pihtext = %trim(pihtext) + ' ' + hedmsg;
710aA       unlock pohdr;
710aA /end-free
710aAC                   goto      enddel
710aA /free
710aA     endif;
710aA   endif;
710aA /end-free
     *
     *  Get header record. Get out if not found.
     *
     C     pohkey        chain     pohdr                              75
     C                   if        *in75
     C                   goto      enddel
     C                   endif
     *
     *  Make sure nothing has been received.
     *
     C                   if        phstat <> '0'  and
530 A*  Ignore this test when there are no items on the p/o.
530 AC                             nodetl = '*NO '
     C                   eval      hedmsg = desc(4)
     C                   add       1             ttlexc
     C                   eval      error = *on
640aAC                   eval      headerError = *on
640aAC                   eval      pihtext = %trim(pihtext) + ' ' + hedmsg
     C                   unlock    pohdr
     C                   goto      enddel
     C                   endif
     *
     *  Delete detail lines.
     *
     C     podkey        setll     podtl
     C                   dow       forevr = forevr
     C     podkey        reade     podtl                                  74
     C                   if        *in74
     C                   leave
     C                   endif
     *
     *     Update PO seq# with 0 in Crossdock file.
     *
     C                   exsr      updxdk
     *
     *     Delete detail record from PODTL file
     *
     C                   delete    pdrec
     *
     C                   enddo
520eA*
520eA* Open PODTLM file, if not previously opened.
520eAC                   if        opndtm <> *on
520eAC                   open      podtlm                               68
520eAC                   if        *in68
520eAC                   eval      opndtm = *off
520eAC                   else
520eAC                   eval      opndtm = *on
520eAC                   endif
520eAC                   endif
520bA*
520bA*  Delete misc. po detail lines.
520bA*
520eAC                   if        opndtm = *on
520eA*
520bAC     podkey        setll     podtlm
520bAC                   dow       forevr = forevr
520bAC     podkey        reade     podtlm                                 69
520bAC                   if        *in69
520bAC                   leave
520bAC                   endif
520bA*
520bA*     Delete misc. detail record from PODTLM file
520bA*
520bAC                   delete    pdmrec
520bA*
520bAC                   enddo
520eA*
520eAC                   endif
     *
     *  Delete header record from POHDR file
     *
750aA /free
750dM   // Set status for DockVue when not replacing p/o.
750dA   if pihtyp <> 'R';
750cA   exec sql insert into postatus
750cA            values (:phwhse, :phpo, 'D',
750cA                    current_timestamp, :nostamp);
750cA*
750cA   if sqlstt <> sqlSuccess;
750aA   exec sql update postatus
750cM               set posstat = 'D',
750aA                   posupdts = current_timestamp
750aA             where poswhs = :phwhse
750aA               and pospo = :phpo;
750cA   endif;
750dA   endif;
750aA /end-free
     C                   delete    phrec
520eA*
520eA* Open POHDRM file, if not previously opened.
520eAC                   if        opnhdm <> *on
520eAC                   open      pohdrm                               68
520eAC                   if        *in68
520eAC                   eval      opnhdm = *off
520eAC                   else
520eAC                   eval      opnhdm = *on
520eAC                   endif
520eAC                   endif
510 A*
510 A*  Get header misc. record and delete it. Ignore if not found.
510 A*
520eAC                   if        opnhdm = *on
520eA*
510 AC     pohkey        chain     pohdrm                             73
510 AC                   if        not *in73
510 AC                   delete    phmrec
510 AC                   endif
520eA*
520eAC                   endif
     *
     C     enddel        endsr
     *----------------------------------------------------------------
     *
     *  ZZDELD  Delete detail record.
     *
     C     zzdeld        begsr
     *
     *  Get item description.
     *
     C     itkey         chain     piritem                            76
     C                   if        *in76
     C                   eval      itdesc = *blanks
     C                   movel     '*****'       itdesc
     C                   endif
     *
     *  Get detail record. Get out if not found.
     *
720bAC                   if        optPartKey = *on
720bAC     podkyp        chain     podtl                              75
720bAC                   else
     C     podkyf        chain     podtl                              75
720bAC                   endif
     C                   if        *in75
     C                   goto      enddld
     C                   endif
     *
     *  Make sure nothing has been received.
     *
     C                   if        pdqrc1 <> *zeros  or
     C                             pdqrc2 <> *zeros  or
     C                             pdqrc3 <> *zeros
     C                   eval      detmsg = desc(4)
     C                   add       1             ttlexc
     C                   eval      error = *on
640aAC                   eval      detailError = *on
640aAC                   eval      pidtext = %trim(pidtext) + ' ' + detmsg
     C                   unlock    podtl
     C                   goto      enddld
     C                   endif
     *
     *  Update PO seq# with 0 in Crossdock file.
     *
     C                   exsr      updxdk
     *
     *  Delete detail record from PODTL file
     *
     C                   delete    pdrec
750dAC                   eval      dockvuedupd = '1'
520bA*
520bA*    Delete Misc. detail file record.
650bDC*                  if        mscdup = '*YES'
720bA*
720bAC                   if        optPartKey = *on
720bAC     pdmkyp        chain     podtlm                             69
720bAC                   else
520bAC     pdmkey        chain     podtlm                             69
720bAC                   endif
720bA*
520bAC                   if        not *in69
520bAC                   delete    pdmrec
520bAC                   endif
650bDC*                  endif
     *
     C     enddld        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDC  Update crossdock record.
     *
     C     zzupdc        begsr
     *
     C                   eval      seq = 0
     C     xdkey         setll     crossdk3
     C                   dow       forevr = forevr
     C     xdkey         reade     crossdk3                               79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   eval      svitem = oditem
     C                   if        oditem = piditm
     C     xdkey         setll     crossdk2
     C                   dow       forevr = forevr
     C     xdkey         reade     crossdk2                               77
     C                   if        *in77
     C                   leave
     C                   endif
     C     odkey         chain     ordd                               75
     C                   if        not *in75
     C                   eval      cdposq = pidseq
     C                   update    cdrec
     C                   leave
     C                   else
     C                   iter
     C                   endif
     C                   enddo
     C                   endif
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDD  Update P.O. detail
     *
     C     zzupdd        begsr
     C                   eval      error = *off
     *
     *  Check for valid item.
     *
     C     itkey         chain     piritem                            76
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      detmsg = desc(6)
     C                   add       1             ttlexc
     C                   eval      itdesc = *blanks
     C                   movel     '*****'       itdesc
640aAC                   eval      detailError = *on
640aAC                   eval      pidtext = %trim(pidtext) + ' ' + detmsg
     C                   goto      endupd
     C                   endif
     *
     *  Check Mfg. Code sent in IMPFPOD2.  If different than
     *  PIRITEM then force item master code on imported PO.
     *
     C                   if        pidvit = *blanks
     C                   eval      pidvit = itvit#
     C                   endif
     *
     *  Check if breakdown qty is allowed using piritem file.
     *  Add rec if qty1, brk qty2 or brk qty3 has good qty.
     *
     C                   exsr      zzbkdn
     *
     *  If a good quantity not found, get out.
     *
720bDC***  good1         cabne     'Y'           endupd
     *
     *  See if detail line exists. Change Type accordingly.
     *
720bAC                   if        optPartKey = *on
720bAC     podkyp        chain     podtl                              75
720bAC                   else
     C     podkyf        chain     podtl                              75
720bAC                   endif
720bA*
     C                   if        *in75
     C                   eval      dtype = 'A'
     C                   eval      pdqrc1 = *zeros
     C                   eval      pdqrc2 = *zeros
     C                   eval      pdqrc3 = *zeros
750dAC                   eval      dockvuedupd = '1'
     C                   else
     C                   eval      dtype = 'C'
     C                   endif
415 A*
415 A*  Detail line cannot be changed if already received.
415 A*
415 AC                   if        dtype = 'C'
415 AC                   if        pdqrc1 > 0  or
415 AC                             pdqrc2 > 0  or
415 AC                             pdqrc3 > 0
415 AC                   eval      error = *on
415 AC                   eval      detmsg = desc(4)
415 AC                   add       1             ttlexc
640aAC                   eval      detailError = *on
640aAC                   eval      pidtext = %trim(pidtext) + ' ' + detmsg
415 AC                   goto      endupd
415 AC                   endif
415 AC                   endif
     *
     *  Type = Change
     *
     C                   if        dtype = 'C'
     C                   exsr      fillod
     C                   update    pdrec
CFIaA /free
CFIaA   // Attempt to update item vendor name/num/vend itemnum
CFIaA   if client = Colony;
CFIaA     exec sql update piritem
CFIaA                 set itvit# = :pidvit,
CFIaA                     itven# = :pihven
CFIaA               where itwhse = :pihwhs
CFIaA                 and ititem = :piditm;
CFIaA     exec sql update itemmsc
CFIaA                 set imvnam = :pihvna
CFIaA               where imwhse = :pihwhs
CFIaA                 and imitem = :piditm;
CFIaA   endif;
CFIaA /end-free
     C                   endif
     *
     *  Type = Add
     *
     C                   if        dtype = 'A'
CBI5AC                   clear                   pdrec
     C                   exsr      fillod
     C                   write     pdrec                                49
     C                   if        *in49
     C                   eval      detmsg = desc(3)
     C                   add       1             ttlexc
     C                   eval      error = *on
640aAC                   eval      detailError = *on
640aAC                   eval      pidtext = %trim(pidtext) + ' ' + detmsg
     C                   else
     C                   exsr      zzupdc
     C                   endif
     *
     C                   endif
     *
     C     endupd        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDH  Update P.O. header
     *
     C     zzupdh        begsr
     C                   eval      error = *off
EOPaA /free
EOPaA   select;
EOPaA     when client = EarlsOrganic;
EOPaA       pihvna = %trim(pihmm1) + ' ' + pihvna;
EOPaA   endsl;
EOPaA /end-free
     *
     *  See if header exists.
     *
     C     pohkey        chain(n)  pohdr                              75
     *
     *  Header does not exist, create it and leave.
     *
     C                   if        *in75
     C                   exsr      filloh
     C                   write     phrec                                49
     C                   if        *in49
     C                   eval      hedmsg = desc(3)
     C                   add       1             ttlexc
     C                   eval      error = *on
640aAC                   eval      headerError = *on
640aAC                   eval      pihtext = %trim(pihtext) + ' ' + hedmsg
     C                   endif
750aA /free
750aA   // Set status for DockVue
750aA   exec sql insert into postatus
750aA            values (:phwhse, :phpo, :phstat,
750aA                    current_timestamp, :nostamp);
750bA*
750bA   if sqlstt <> sqlSuccess;
750bA   exec sql update postatus
750bA               set posstat = :phstat,
750bA                   posupdts = current_timestamp
750bA             where poswhs = :phwhse
750bA               and pospo = :phpo;
750bA   endif;
750aA /end-free
     C                   goto      enduph
     C                   endif
     *
     *  Header exists.
     *
     *     If only changing a P.O., move on.
     *
     C                   if        pihtyp = 'C'
500 A*
500 A*     Update delivery date/time if it changed.
500 AC                   eval      wktime = pihtim
500 AC                   if        pihdte <> phdate  or
500 AC                             wktime <> phtime  or
500aA*
500aA*     Update vendor number for p/o.
500aAC                             pihven <> phven  or
520fA*
520fAC                             pihvna <> phvnam  or
520fAC                             pihva1 <> phvad1  or
520fAC                             pihva2 <> phvad2  or
520fAC                             pihvct <> phvcty  or
520fAC                             pihvst <> phvst  or
520fAC                             pihvzp <> phvzp1
500 AC                   exsr      zzupdt
500 AC                   endif
500 A*
     C                   goto      enduph
     C                   endif
     *
     *     Otherwise, check if anything has been received for P.O.
     *
     *        Something received, cannot proceed.
     *
     C                   if        phstat <> '0'
     C                   eval      hedmsg = desc(4)
     C                   add       1             ttlexc
     C                   eval      error = *on
640aAC                   eval      headerError = *on
640aAC                   eval      pihtext = %trim(pihtext) + ' ' + hedmsg
     C                   goto      enduph
     C                   endif
     *
     *        Nothing received, delete P.O. then create new header.
     *
     C                   exsr      zzdel
     C     error         cabeq     *on           enduph
     C                   exsr      filloh
     C                   write     phrec                                49
     C                   if        not *in49
     C                   eval      hedmsg = *blanks
     C                   else
     C                   eval      hedmsg = desc(3)
     C                   add       1             ttlexc
     C                   eval      error = *on
640aAC                   eval      headerError = *on
640aAC                   eval      pihtext = %trim(pihtext) + ' ' + hedmsg
     C                   endif
750aA /free
750aA   // Set status for DockVue
750aA   exec sql insert into postatus
750aA            values (:phwhse, :phpo, :phstat,
750aA                    current_timestamp, :nostamp);
750aA*
750bA   if sqlstt <> sqlSuccess;
750bA   exec sql update postatus
750bA               set posstat = :phstat,
750bA                   posupdts = current_timestamp
750bA             where poswhs = :phwhse
750bA               and pospo = :phpo;
750bA   endif;
750aA /end-free
     *
     C     enduph        endsr
510 A*
510 A*----------------------------------------------------------------
510 A*
510 A*  ZZUPHM  Update P.O. header misc. file
510 A*
510 AC     zzuphm        begsr
510 AC                   eval      error = *off
510 A*
510 A*  See if header misc. exists.
510 A*
510 AC     pohkey        chain     pohdrm                             73
510 A*
510 A*  Header Misc. does not exist, create it and leave.
510 A*
510 AC                   if        *in73
640aA
640aA*    Don't create record if all fields are blank.
640aA
640aAC                   if        pihmm1 = ' '
640aAC                             and pihmm2 = ' '
640aAC                             and pihmm3 = ' '
640aAC                             and pihmm4 = ' '
640aAC                             and pihmm5 = ' '
640aAC                   goto      enuphm
640aAC                   endif
510 A*
510 A*  Initialize record
510 A*
510 AC                   clear                   phmrec
510 AC                   eval      phmwh = pihwhs
510 AC                   eval      phmpo = pihpo
510 AC                   exsr      filphm
510 AC                   write     phmrec                               48
510 AC                   if        *in48  and
510 AC                             hedmsg = *blanks
510 AC                   eval      hedmsg = desc(8)
510 AC                   add       1             ttlexc
510 AC                   eval      error = *on
640aAC                   eval      headerError = *on
640aAC                   eval      pihtext = %trim(pihtext) + ' ' + hedmsg
510 AC                   endif
510 AC                   goto      enuphm
510 AC                   endif
510 A*
510 A*  Header Misc. file exists.
510 A*
510 AC                   if        pihtyp = 'C'
510 A*
510 A*     Update Misc. fields if any changes.
510 AC                   if        pihmm1 <> phmm1  or
510 AC                             pihmm2 <> phmm2  or
510 AC                             pihmm3 <> phmm3  or
510 AC                             pihmm4 <> phmm4  or
510 AC                             pihmm5 <> phmm5
510 AC                   exsr      filphm
510 AC                   update    phmrec
510 AC                   else
510 AC                   unlock    pohdrm
510 AC                   endif
510 A*
510 AC                   goto      enuphm
510 AC                   endif
510 A*
510 AC     enuphm        endsr
520bA*
520bA*----------------------------------------------------------------
520bA*
520bA*  ZZUPDM  Update P.O. detail misc. file
520bA*
520bAC     zzupdm        begsr
520bAC                   eval      error = *off
520bA*
EOPaA /free
EOPaA   // for Earl's, ignore message if same as item description
EOPaA   if client = EarlsOrganic;
EOPaA     chkstr = pidpom;
EOPaA   //exsr zzzspcl2spc;
EOPaA     pidpom = chkstr;
EOPaA     if pidpom = itdesc;
EOPaA       pidpom = *blanks;
EOPaA     endif;
EOPaA     // put pack desc into message if message blank
EOPbA   //if pidpom = *blanks;
EOPbA   //  exec sql select itpdsc into :pidpom
EOPbA   //             from piritem
EOPbA   //            where ititem = :piditm;
EOPbA   //endif;
EOPaA     // if message still blank, use UOM
EOPbA     if pidpom = *blanks;
EOPbA     //exec sql select uvdscp into :pidpom
EOPbA     //           from piritem, unmesrv
EOPbA     //          where ititem = :piditm
EOPbA     //            and itum1 = uvcode;
EOPbA       exec sql select ikmsc1 into :pidpom
EOPbA                  from itemext
EOPbA                 where ikitem = :piditm;
EOPbA     endif;
EOPaA   endif;
EOPaA /end-free
EOPaA
520bA*  See if detail misc. exists.
520bA*
720bAC                   if        optPartKey = *on
720bAC     pdmkyp        chain     podtlm                             69
720bAC                   else
520bAC     pdmkey        chain     podtlm                             69
720bAC                   endif
520bA*
520bA*  Detail Misc. does not exist, create it and leave.
520bA*
520bAC                   if        *in69
640aA
640aA*    Don't create record if all fields are blank.
640aA
640aAC                   if        pidms1 = ' '
640aAC                             and pidms2 = ' '
640aAC                             and pidms3 = ' '
640aAC                             and pidms4 = ' '
640aAC                             and pidms5 = ' '
640aAC                             and pidods = ' '
640aAC                             and pidpom = ' '
640aAC                   goto      enupdm
640aAC                   endif
520bA*
520bA*  Initialize record
520bA*
520bAC                   clear                   pdmrec
520bAC                   eval      pdmwhs = pihwhs
520bAC                   eval      pdmpo = pihpo
520bAC                   exsr      filpdm
520bAC                   write     pdmrec                               47
520bAC                   if        *in47  and
520bAC                             detmsg = *blanks
520bAC                   eval      detmsg = desc(9)
520bAC                   add       1             ttlexc
520bAC                   eval      error = *on
640aAC                   eval      detailError = *on
640aAC                   eval      pidtext = %trim(pidtext) + ' ' + detmsg
520bAC                   endif
520bAC                   goto      enupdm
520 AC                   endif
520bA*
520bA*  Detail Misc. file exists.
520bA*
520bAC                   if        pidtyp = 'C'
520bA*
520bA*     Update Misc. fields if any changes.
520bAC                   if        pidpom <> pdmpom  or
520dAC                             piditm <> pdmitm  or
520cAC                             pidods <> pdmods  or
520bAC                             pidms1 <> pdmms1  or
520bAC                             pidms2 <> pdmms2  or
520bAC                             pidms3 <> pdmms3  or
520bAC                             pidms4 <> pdmms4  or
520bAC                             pidms5 <> pdmms5
520bAC                   exsr      filpdm
520bAC                   update    pdmrec
520bAC                   else
520bAC                   unlock    podtlm
520bAC                   endif
520bA*
520bAC                   goto      enupdm
520bAC                   endif
520bA*
520bAC     enupdm        endsr
500 A*
500 A*----------------------------------------------------------------
500 A*
500 A*  ZZUPDT  Update P.O. header Delivery date/time.
500 A*
500 AC     zzupdt        begsr
500 AC                   eval      error = *off
500 A*
500 AC     pohkey        chain     pohdr                              7575
500 AC                   if        not *in75
500 AC                   move      pihdte        phdate
500 AC                   eval      phtime = pihtim
500aA*
500aAC                   eval      phven = pihven
520fA*
520fAC                   eval      phvnam = pihvna
520fAC                   eval      phvad1 = pihva1
YHT A*
CSP AC                   select
CSP AC                   when      client = coastl
CSP A*     Last 6 bytes are reserved for Load Number.
CSP AC     34            subst     pihva2:1      phvad2
CSP A*
CSP MC                   when      client = yhata
YHT A*     Last 3 bytes are reserved for H&S freight code.
YHTbMC     31            subst     pihva2:1      phvad2
CSP A*
CSP MC                   other
520fAC                   eval      phvad2 = pihva2
CSP MC                   endsl
YHT A*
520fAC                   eval      phvcty = pihvct
520fAC                   eval      phvst = pihvst
520fAC                   eval      phvzp1 = pihvzp
520fA*
500 AC                   update    phrec                                75
500 AC                   endif
750aA /free
750aA   // Set status for DockVue
750aA   exec sql update postatus
750aA               set posstat = :phstat,
750aA                   posupdts = current_timestamp
750aA             where poswhs = :phwhse
750aA               and pospo = :phpo;
750bA
750bA   if sqlstt <> sqlSuccess;
750bA   exec sql insert into postatus
750bA            values (:phwhse, :phpo, :phstat,
750bA                    current_timestamp, :nostamp);
750bA   endif;
750aA /end-free
500 A*
500 AC     endupt        endsr
500 A*
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   write     head2
     C                   add       2             count
     C                   write     head3
     C                   add       2             count
     C                   write     head4
     C                   add       2             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
      /free

720aA   // Log program end
720aA   if debugflag;
720aA     log.pgm = #pgm;
720aA     log.type = 'End      ';
720aA     log.text = 'Import FTP Purchase Orders.';
720aA     WrtLog(log.pgm: log.type: log.text);
720aA   endif;
720aA

        if importError;
          sbstatus = 'E';
          sbtext   = 'Import completed with error(s). '
                   + 'See impspoh/impspod files.';
          $pReturn = '*ERROR';
          $pMessage = sbtext;
        else;
710aD   //sbstatus = 'C';
710aM     sbstatus = 'S';
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
                    + '- PI265s/zzzend';
          leavesr;
        endif;

760 A   if importError;
760 A     // if Staging Interface error report is scheduled then submit
760 A     // Use a timestamp as a session id.  MRCRPTSCH will call the
760 A     // update program to update the correct work file to report
760 A     exsr zzErrRpt;
760 A   endif;

720aA   // Log program end
720aA   if debugflag;
720aA     log.pgm = #pgm;
720aA     log.type = 'End      ';
720aA     log.text = $pMessage;
720aA     WrtLog(log.pgm: log.type: log.text);
720aA   endif;

      /end-free
     c                   endsr

760 A*----------------------------------------------------------------
760 A*  zzErrRpt   Send Error report for Staging File if scheduled
760 A*----------------------------------------------------------------
760 A
760 Ac     zzErrRpt      begsr
760 A /free
760 A
760 A *   Determine if scheduled, and if so what email to use based
760 A *   on current time compared to scheduled time(s).
760 A *   Loops thru BFCMRCRPRM looking for scheduled events and
760 A *   determining which one is closest to current time, but not
760 A *   after current time.
760cD     //currReport = 'BFCREPORTS.R40700';
760cM     currReport = 'BFCREPORTS.R42600';
760 A     // get the closest scheduled email address to current time.
760 A     // if email is return empty we assume not schedule and
760 A     // nothing is sent
760 A     schEmail=*blanks;
760 A     getSchTimeEml();

          // if email is returned then send out requested error report
          if schEmail <> *blanks;
            orient = 'P';
            grDev=*blanks;
            // Format URL
            // Note: pdf fields are genreated by MRCRPTSCH program
            url = '&OUTFMT=11'
                + '&D_DETAIL=1'
760cD           //+ '&CALCULA001=' + %char(%timestamp())
760cD           //+ '&CALCULA002=' + %char($pWhse)
760cD           //+ '&CALCULA003=' + $pBatid;
760cM           + '&R001=' + %char($pWhse)
760cM           + '&R002=' + $pBatid;

760cA       // Call program to populate Subject and Email Body to
760cA       // file intlog.  These are printed on Email error Report
760cA       // R42600 called below
760cA       wintlog ($pWhse:$pBatid);

            // Call program to print report

            monitor;

760 A         // get iSeries user and jobd from Report Scheduling
760 A         exec sql select opmusr,opjobd into :opmusr,:opjobd
760 A                   from opsmrcrpt
760 A                where opwhse=:$pwhse
760 A               fetch first row only;
760 A         if sqlstt = '00000';
760 A            sbmusr = opmusr;
760 A            sbmjobd = opjobd;
760 A            sbmlibl = '*JOBD';
760 A         else;
760 A            sbmusr = '*CURRENT';
760 A            sbmjobd = '*USRPRF';
760 A            sbmlibl = '*CURRENT';
760 A         endif;
760 A
760 A         cmd = 'sbmjob '
760 A               +   'cmd('
760 A               +      'MRCRPTSCH ' +
760 A                    'WHSE(' + %char($pwhse) + ') '  +
760 A                    'RPTNAM(''' + %trim(currReport) + ''') ' +
760 A                    'URL(''' + %trim(url) + ''') ' +
760 A                    'EMAIL(' + sq + %trim(schEmail) + sq + ') ' +
760 A                    'PRINTER(' + sq + %trim(grdev) + sq + ') ' +
760 A                    'ORIENT(' + sq + %trim(orient) + sq + ')) ' +
760 A               'inllibl(' + %trim(sbmlibl) + ') ' +
760 A               'jobd(' + %trim(sbmjobd) + ') ' +
760 A               'user(' + %trim(sbmusr) + ') ' +
760 A               'jobq(QSYSNOMAX) ' +
760 A               'job(OI285SRSCH)';
760 A         qcmdexc(cmd: %len(cmd));

            on-error;
            endmon;
          endif;
760 A
760 A /end-free
760 Ac                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetStamps   Get timestamps
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetStamps  begsr
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
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzStart   Start processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzStart      begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'P',
              sbtext   = 'Import started',
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
                    + '- PI265s/zzzstart';
          leavesr;
        endif;

        importError = *off;

      /end-free
     c                   endsr
EOPaA*----------------------------------------------------------------
EOPaA*  zzzspcl2spc  Remove unallowed characters.
EOPaA*----------------------------------------------------------------
EOPaA
EOPaAC     zzzspcl2spc   begsr
EOPaA
EOPaAC                   eval      chkpos = 0
EOPaA
EOPaAC*                  dou       chkpos = 0
EOPaAC                   dou       chkpos = 0 or chkpos + 1 > 30
EOPaAC                   eval      chkpos = %check(okchar:chkstr:chkpos+1)
EOPaAC                   if        chkpos > 0
EOPaAC                   eval      %subst(chkstr:chkpos:1) = ' '
EOPaAC                   endif
EOPaAC                   enddo
EOPaA
EOPaAC                   endsr

760 A *----------------------------------------------------------------
760 A *  getSchTimeEml - Get Email address for specific error  report
760 A *----------------------------------------------------------------

760 Ap getSchTimeEml   b
760 Ad getSchTimeEml   pi

      *  Local Variables

     D weekday         s              3
     D currTime        s              5

            // Set 3 character value for day
            select;
              when DayofWeek(%date()) = 0;
                weekday = 'SUN';
              when DayofWeek(%date()) = 1;
                weekday = 'MON';
              when DayofWeek(%date()) = 2;
                weekday = 'TUE';
              when DayofWeek(%date()) = 3;
                weekday = 'WED';
              when DayofWeek(%date()) = 4;
                weekday = 'THU';
              when DayofWeek(%date()) = 5;
                weekday = 'FRI';
              when DayofWeek(%date()) = 6;
                weekday = 'SAT';
            endsl;

            // get current time (hh:mm)
            currTime = %subst(%char(%time():*ISO):1:5);

            // now query scheduled entries for closest
            // time to current system time that is active
            // for the current Report being processed
            exec sql select bsvalue into :schEmail
                from bfcmrcrprm as a where a.bswhse=:$pWhse and
              a.bsrptpgm=:currReport and a.bsmrctbl='E' and
              a.bsmrcprm='EMAIL' and
               (select b.bsvalue from bfcmrcrprm as b where
                 b.bswhse=a.bswhse and b.bsrptpgm=a.bsrptpgm and
                 b.bsschseq=a.bsschseq and b.bsmrctbl='D'
                 and b.bsmrcprm=:weekday)='Y' and
               (select min(b.bsvalue) from bfcmrcrprm as b where
                 b.bswhse=a.bswhse and b.bsrptpgm=a.bsrptpgm and
                 b.bsschseq=a.bsschseq and b.bsmrctbl='X'
                 and b.bsmrcprm='SCHTIME')<:currTime;

760 Ap getSchTimeEml   e
760 A*----------------------------------------------------------------*
760 A* Procedure:  DayOfWeek
760 A* Purpose:  Determine the day of week for a particular date
760 A* Parameters:
760 A*    I: dt   -- date
760 A* Returns:
760 A*    0..6    -- 0=Sunday, 1=Monday, 2=Tuesday, etc.
760 A* Notes:
760 A*    January 5, 1800 is a Sunday.  This procedure only works for
760 A*    dates later than 1800-01-05.
760 A*----------------------------------------------------------------*

760 AP DayOfWeek       b
760 AD DayOfWeek       pi            10i 0
760 AD   dt                            d   value datfmt(*iso)
      /free
        return %rem (%diff (dt: d'1800-01-05': *days): 7);
      /end-free
760 AP DayOfWeek       e

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
*PO DELETED*
*INVALID TYPE*
*CREATION ERROR*
*ALREADY RECEIVED*
*LINE DELETED*
*INVALID ITEM*
*BREAKDOWN INVALID*
*MISC HDR CRT ERR*
*MISC DTL CRT ERR*
**
Import FTP Purchase Orders
**   OVRPRTF statment
OVRPRTF FILE(PI2651PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
OVRPRTF FILE(PI265PR)            OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
