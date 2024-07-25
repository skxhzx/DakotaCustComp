     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PI265     Import FTP purchase orders - Post
     *  Dave Sommerville
     *  3 November 2000
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
640 A*    09/09/11  MLB  6.40
     *      - Fix: Revised program to write out HEAD41 the first time
     *        when there is a terminal error when processing the import
     *        p/o header file.
     *      - Fix: Revised program to chain to PIRITEM file when import
     *        detail type not a valid code. This is done so that the
     *        item description will print for code exceptions.
     *
720a *    08/15/18  RTR  7.20a
     *      - Enh: Added OPTIONINT value for checking history before
     *        importing PO. If PO in history, do not import.
     *      - Enh: Added Start/End logging in BFCLOG controlled by
     *        OPTIONINT flag.
720b *    11/12/18  RTR  7.20b
     *      - Enh: Check OPTIONINT value for Aspen multi warehouse
     *        item number conversion.
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
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
CLD A*    01/28/05  MLB  CLD
     *      - Tst: * Temporary Debug Mod * Revised program to not
     *        delete records from import files.
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
     *  Client Custom Revisions: Crumbley Paper & Foodservice
     *
CPC A*    09/09/11  MLB  CPC
     *      - Revised program to not import any purchase order that is
     *        found in p/o history file. This mod is being done because
     *        p/o's are being sent over to Dakota when they shouldn't be
     *        due to a user printing a p/o and having the update flag date
     *        being changed. Per Roxanne's email dated 09/09/11.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*    03/05/13  MLB  GFS
     *      - Revised program to use partial key when chaining to
     *        p/o detail file. This is needed because Thyme allows
     *        the user to change the item number attached to a
     *        specific line number.
GFSaA*    07/18/13  MLB  GFSa
     *      - Revised program to disable printing of error message,
     *        *Already Received* on import exception report. Per
     *        email from David H.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa Distributing
     *
CWD A*    10/23/13  MLB  CWD
     *      - Revised program to not import any purchase order that is
     *        found in p/o history file. This mod is being done because
     *        p/o's are being sent over to Dakota when they shouldn't be
     *        due to a user printing a p/o and having the update flag date
     *        being changed. Per Dustin's email dated 10/22/13.
     *      - Added CWD to CPC mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa Distributing
     *
HMWa *    07/02/14  RTR  HMWa
     *      - Convert right justified PO/Item/Vendno fields to left
     *        justified. This is to prevent even longer delay from
     *        Aspen reprogramming.
HMWb *    02/03/15  RTR  HMWb
     *      - Added vendor name to HMWa mod.
HMWc *    02/17/15  RTR  HMWc
     *      - Temp change to zero out when invalid breakdown qty ordered.
     *        This is because Aspen has an error sending brkdwn qty when
     *        none exists. Will be removed after fixed.
HMWd *    01/07/20  RTR  HMWd
     *      - Fix - Clear Special Order code when not XD, Canopy sending
     *        garbage.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S.Bertram
     *
SBRa *    07/27/15  RTR  SBRa
     *      - Added S.Bertram to H&M Wagner mods.
SBRb *    06/21/16  RTR  SBRb
     *      - Changed to allow warehouse 4.
SBRc *    08/01/18  RTR  SBRc
     *      - Changed to allow warehouse 9 for OSS I.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFC A*    10/02/14  RTR  PFC
     *      - Converted to ILE.
     *      - Added conversion to uppercase for PO number.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: TPC Foodservice
     *
TPC A*    01/31/17  MLB  TPC
     *      - Revised pgm to process CROSSDK3 LF to match p/o detail item
     *        with order detail item for p/o being processed and if found
     *        update PDSPCL = XD. This mod is needed because host is ex-
     *        pected to send cross dock items with PDSPCL = XD. TPC's
     *        Host is not able to make this change. A similar mod has
     *        been made in pgm, OI255 to update PDSPCL for cross dock
     *        items.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCaA*    10/02/14  RTR  PFCa
     *      - Converted to ILE.
     *      - Added conversion to uppercase for PO number.
PFCbA*    12/19/14  RTR  PFCb
     *      - Added fix for Target leaving off detail record type,
     *        assumes 'C' when blank.
PFCcA*    01/17/16  RTR  PFCc
     *      - Added fix for Target not sending detail deletes, always
PFCdA*    02/09/16  RTR  PFCd
     *      - Added PFC to CPC mod to check history and not re-import
     *        if already exported.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Seashore Fruit & Produce
     *
SFP A*    07/25/22  MLB  SFP  *Temporary Mod*
     *      - Revised pgm to set switch, ASPENWHSE = '0'. Was
     *        causing change to item number to add -01.
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
     Fimpfpoh2  uf   e           k disk
510aMFimpfpohm  uf   e           k disk    usropn
     Fimpfpod2  uf   e           k disk
520bMFimpfpodm  uf   e           k disk    usropn
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Fpohdr     uf a e           k disk
510aMFpohdrm    uf a e           k disk    usropn
CPC AFpohhdr    if   e           k disk    usropn
     Fpodtl     uf a e           k disk
520bMFpodtlm    uf a e           k disk    usropn
     Fcrossdk3  if   e           k disk
     Fcrossdk2  uf   e           k disk
     Fordd      if   e           k disk
     Fpi265pr   o    e             printer oflind(*in91)
417 AFpi2651pr  o    e             printer oflind(*in92)
     F                                     usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
510 D*                   DESC    1   7 20
520bD*                   DESC    1   8 20
CPC D*                   DESC    1   9 20
CPC MD desc            s             20    dim(10) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
417 AD a80             s              1    dim(80)
417 AD ovrprt          s             80    dim(1) ctdata perrcd(1)
500bA*----------------------------------------------------------------
500bA*  Customer id
500bA*
     D @getcl          c                   const('GETCLIENT')
750bA*----------------------------------------------------------------
750bA*  Standard SQL variables and constants
750bA*----------------------------------------------------------------
750bA
750bA /copy qcopysrc,c#stdsql
750bA
YHT A /COPY QCOPYSRC,Id#YHATA
CSP A /COPY QCOPYSRC,Id#COASTAL
CLD A /COPY QCOPYSRC,Id#CITYLIN
CPC A /COPY QCOPYSRC,Id#CPC
GFS A /COPY QCOPYSRC,Id#GFS
CWD A /COPY QCOPYSRC,Id#CASHWA
HMWaA /copy qcopysrc,id#hmwagne
SBRaA /copy qcopysrc,id#sbr
PFC A /COPY QCOPYSRC,Id#PFC
TPC A /COPY QCOPYSRC,Id#TPC
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
720aA /copy *libl/qcopysrc,p.getopint
720aA /copy *libl/qcopysrc,p.wrtlog
720aA /copy *libl/qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Called Program Prototypes
     *----------------------------------------------------------------
720bAd PreProc         pr                  extpgm('PI264')
     *----------------------------------------------------------------
     *  Variables
     *
SFP MD AspenWhse       s               n   inz('0')
     D count           s              3  0                                      LINE COUNTER
720aAd DebugFlag       s               n   inz('0')
     D dtype           s              1
     D error           s              1
     D excprt          s              1
     D excpr1          s              1
     D forevr          s              1
     D good1           s              1
     D len             s              1  0
     D linppg          s              3  0                                      MAX LINES PER PAGE
     D lstdev          s             10
     D lstfrm          s             10
     D lstwhs          s              3  0
     D nodetl          s              4
750aAD nostamp         s               z     inz
     D opened          s              1
720aAd optChkHist      s               n   inz('0')
     D pflag           s              1
     D pos             s              1  0
     D prhdr1          s              1
PFCaAD savpo           s                   like(phpo)
     D seq             s                   like(pidseq)
     D sublin          s              3  0
     D subq1           s              7  0
     D subq2           s              7  0
     D subq3           s              7  0
     D svitem          s             15
     D wflag           s              1
     D wktime          s                   like(phtime)
     D work3a          s              3
PFCaAD lower           c                   'abcdefghijklmnopqrstuvwxyz'
PFCaAD UPPER           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
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
CPC AD                 ds
CPC AD  opnphh                 1      1
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
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Main line
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
     *
     * Whip through all the download header records
     *
     C                   eval      wflag = *off
     C                   eval      pflag = *off
     C                   eval      linppg = 55                                  MAX LINES PER PAGE
     C                   eval      count = 0                                    LINE COUNTER
     *
     C                   dow       forevr = forevr
     *
     C                   read      impfpoh2                               79
     C                   if        *in79
     C                   leave
     C                   endif
     *
PFCaAC                   select
PFCaAC                   when      client = prestofoods
PFCaAC                   eval      savpo = pihpo
PFCaAC                   eval      pihpo = %xlate(lower:UPPER:pihpo)
PFCcAC                   exsr      zzdel
PFCaAC                   endsl
510 A*
510 A*   Get P/O Header Misc. file
510aAC                   if        mschup = '*YES'
510 AC                   exsr      getmis
510aAC                   endif
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
CPC A*
CPC A*   Check if P/O was previously exported.
CPC AC                   if        client = cpc  or
PFCdAC                             client = prestofoods or
CWD AC                             client = cashwa
720aAc                             or optChkHist
CPC A*   Only check if p/o isn't flagged for deletion.
CPC AC                   if        pihtyp <> 'D'
CPC AC                   exsr      zzchke
CPC AC                   endif
CPC AC                   endif
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
     *
     *   Do as user instructed.
     *
     C                   eval      hedmsg = *blanks
     C                   eval      error = *off
530 AC                   eval      nodetl = '*NO '
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
510aAC                   if        mschup = '*YES'
510 AC                   exsr      zzuphm
510aAC                   endif
     *
     *     Ignore because of invalid type.
     *
     C                   other
CPC A*
CPC AC                   if        client = cpc  or
PFCdAC                             client = prestofoods or
CWD AC                             client = cashwa
720aAc                             or optChkHist
CPC A*
CPC AC                   if        pihtyp = 'E'
CPC AC                   eval      hedmsg = desc(10)
CPC AC                   else
CPC AC                   eval      hedmsg = desc(2)
CPC AC                   endif
CPC A*
CPC AC                   else
CPC A*
     C                   eval      hedmsg = desc(2)
CPC AC                   endif
CPC A*
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
640 AC                   write     head41
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
     *
     *   Whip through all the download detail records
     *
417 AC                   eval      excpr1 = *off

PFCaAC                   select
PFCaAC                   when      client = prestofoods
PFCaAC                   eval      pihpo = savpo
PFCaAC                   endsl

     C     pidkey        setll     impfpod2
     C                   dow       forevr = forevr
     *
HMWaAC                   if        client = hmwagner
SBRaAC                             or client = sbertram
HMWaAC     pidky2        reade     impfpod2                               78
HMWaAC                   else
     C     pidkey        reade     impfpod2                               78
HMWaAC                   endif
     C                   if        *in78
     C                   leave
     C                   endif
520bA*
520bA*   Get P/O Detail Misc. file
520bAC                   if        mscdup = '*YES'
520bAC                   exsr      gtpodm
520bAC                   endif
     *
PFCaAC                   select
PFCaAC                   when      client = prestofoods
PFCaAC                   eval      pidpo = %xlate(lower:UPPER:pidpo)
PFCaAC                   eval      piditm = %xlate(lower:UPPER:piditm)
PFCaAC                   endsl
CPC A*
CPC AC                   if        client = cpc  or
PFCdAC                             client = prestofoods or
CWD AC                             client = cashwa
720aAc                             or optChkHist
CPC A*
CPC A*    If p/o previously exported, chg update code to bypass update.
CPC AC                   if        pihtyp = 'E'
CPC AC                   eval      pidtyp = 'E'
CPC AC                   endif
CPC A*
CPC AC                   endif
CPC A*
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
     C                   eval      good1 = 'N'
     C                   eval      error = *off
     *
     *        Fix Presto Detail Type
PFCbAC                   if        client = prestofoods
PFCbAC                             and pidtyp = ' '
PFCbAC                   eval      pidtyp = 'C'
PFCbAC                   endif
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
520bAC                   if        mscdup = '*YES'  and
520bA*     No error writing P/O Detail record.
520bAC                             not *in49  and
520bA*     Item master record on file.
520bAC                             not *in76
520bAC                   exsr      zzupdm
520bAC                   endif
     *
     *         Ignore because of invalid type.
     *
     C                   other
640 A*
640 AC     itkey         chain     piritem                            76
640 AC                   if        *in76
640 AC                   eval      itdesc = *blanks
640 AC                   movel     '*****'       itdesc
640 AC                   endif
CPC A*
CPC AC                   if        client = cpc  or
PFCdAC                             client = prestofoods or
CWD AC                             client = cashwa
720aAc                             or optChkHist
CPC A*
CPC AC                   if        pidtyp = 'E'
CPC AC                   eval      detmsg = desc(10)
CPC AC                   else
CPC AC                   eval      detmsg = desc(2)
CPC AC                   endif
CPC A*
CPC AC                   else
CPC A*
     C                   eval      detmsg = desc(2)
CPC AC                   endif
CPC A*
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
     *
CLD AC                   select
CLD AC                   when      client = cityln
CLD D***        1         IFEQ -1
CLD AC                   other
720aD **                 delete    pidrec
CLD AC                   endsl
520bA*
520bA*  Delete Detail misc. record from download file.
520bA*  Ignore not found.
520bAC                   if        mscdup = '*YES'
720bD **                 delete    pidmrc                               71
520bAC                   endif
417 A*
417 A*       Exception occurred, print on report.
417 AC                   select
417 AC                   when      detmsg > *blanks
GFSaA*
GFSaAC                   if        client = gtfrsh
GFSaA*
GFSaAC                   if        detmsg = desc(4)
GFSaA*       Bypass logging this error, Already Received.
GFSaAC                   goto      enddod
GFSaAC                   endif
GFSaA*
GFSaAC                   endif
GFSaA*
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
     C                   enddo
     *
     *    Print order subtotals and update grand totals
     *
     **                   EXSR ZRHEAD
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
     *
CLD AC                   select
CLD AC                   when      client = cityln
CLD D**         1         IFEQ -1
CLD AC                   other
720aD **                 delete    pihrec
CLD AC                   endsl
510 A*  Delete header misc. record from download file.
510 A*  Ignore not found.
510aAC                   if        mschup = '*YES'
720aD **                 delete    pihmrc                               72
510aAC                   endif
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
720aA /free
720aA   // Log program end
720aA   if debugflag;
720aA     log.pgm = #pgm;
720aA     log.type = 'End      ';
720aA     log.text = 'Import FTP Purchase Orders.';
720aA     WrtLog(log.pgm: log.type: log.text);
720aA   endif;
720aA /end-free

     C                   eval      *inlr = *on
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
500bA*
     C                   eval      forevr = *off
     C                   eval      error = *off
510aAC                   eval      opnihm = *off
510aAC                   eval      opnhdm = *off
510aAC                   eval      mschup = '*NO '
520bAC                   eval      opnidm = *off
520bAC                   eval      opndtm = *off
520bAC                   eval      mscdup = '*NO '
530 AC                   eval      nodetl = '*NO '
     *
     * Key definitions
     *
     * Download purchase order detail file - Partial key
     *
     C     pidkey        klist
     C                   kfld                    pihwhs
     C                   kfld                    pihpo
     C                   kfld                    pihcdt
     C                   kfld                    pihctm
HMW A*
HMW A* Download purchase order detail file - Partial key
HMW A*
HMW AC     pidky2        klist
HMW AC                   kfld                    pihwhs
HMW AC                   kfld                    pihpo
HMW AC                   kfld                    pihcdt
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
GFS A*
GFS A* P.O. Detail file - Partial key
GFS A*
GFS AC     podkyp        klist
GFS AC                   kfld                    pidwhs
GFS AC                   kfld                    pidpo
GFS AC                   kfld                    pidseq
520bA*
520bA* Import P.O. Detail Misc. file - Full key
520bA*
520bAC     podmky        klist
520bAC                   kfld                    pidwhs
520bAC                   kfld                    pidpo
520bAC                   kfld                    pidcdt
520bAC                   kfld                    pidctm
520bAC                   kfld                    pidseq
520bAC                   kfld                    piditm
520bA*
520bA* P.O. Detail Misc. file - Full key
520bA*
520bAC     pdmkey        klist
520bAC                   kfld                    pidwhs
520bAC                   kfld                    pidpo
520bAC                   kfld                    pidseq
520bAC                   kfld                    piditm
     *
     * Item file
     *
     C     itkey         klist
     C                   kfld                    pidwhs
     C                   kfld                    piditm
CPC A*
CPC A* P/O History Header
CPC A*
CPC AC     phhkey        klist
CPC AC                   kfld                    pihwhs
CPC AC                   kfld                    pihpo
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
720bA /free
720bA
720bA   // Aspen Pre-processing
720bA   if AspenWhse;
720bA     PreProc();
720bA   endif;
720bA
720bA /end-free
510aA*
510aA* Open IMPFPOHM file.
510aAC                   if        opnihm <> *on
510aAC                   open      impfpohm                             68
510aAC                   if        not *in68
510aAC                   eval      opnihm = *on
510aAC                   eval      mschup = '*YES'
510aAC                   else
510aAC                   eval      mschup = '*NO '
510aAC                   endif
510aAC                   endif
510aA*
510aM* Open POHDRM file if import file was sent.
510aAC                   if        opnhdm <> *on  and
510aAC                             mschup = '*YES'
510aMC                   open      pohdrm                               68
510aAC                   if        not *in68
510aAC                   eval      opnhdm = *on
510aAC                   eval      mschup = '*YES'
510aAC                   else
510aAC                   eval      mschup = '*NO '
510aAC                   endif
510aAC                   endif
520bA*
520bA* Open IMPFPODM file.
520bAC                   if        opnidm <> *on
520bAC                   open      impfpodm                             68
520bAC                   if        not *in68
520bAC                   eval      opnidm = *on
520bAC                   eval      mscdup = '*YES'
520bAC                   else
520bAC                   eval      mscdup = '*NO '
520bAC                   endif
520bAC                   endif
520bA*
520bA* Open PODTLM file if import file was sent.
520bAC                   if        opndtm <> *on  and
520bAC                             mscdup = '*YES'
520bAC                   open      podtlm                               68
520bAC                   if        not *in68
520bAC                   eval      opndtm = *on
520bAC                   eval      mscdup = '*YES'
520bAC                   else
520bAC                   eval      mscdup = '*NO '
520bAC                   endif
520bAC                   endif
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

CPC A*
CPC AC                   if        client = cpc  or
PFCdAC                             client = prestofoods or
CWD AC                             client = cashwa
720aAc                             or optChkHist
CPC A*
CPC A* Open POHHDR file.
CPC AC                   if        opnphh <> *on
CPC AC                   open      pohhdr                               68
CPC AC                   if        not *in68
CPC AC                   eval      opnphh = *on
CPC AC                   else
CPC AC                   eval      opnphh = *off
CPC AC                   endif
CPC AC                   endif
CPC A*
CPC AC                   endif
     *
HMWaA* For H&M Wagner, clean up data
HMWaAc                   if        client = hmwagner
SBRaAc                             or client = sbertram
HMWaAc                   exsr      zzWagner
HMWaAc                   endif
     *
720aA*
720aA*   Get option for debugging.
720aA*
720aA /free
720aA   // Get debug flag
720aA   optint.type = 'Interface   ';
720aA   optint.cat  = 'Import POs          ';
720aA   optint.name = 'Debug Flag          ';
720aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
720aA             optint.valn: optint.vala: optint.return);
720aA   if optint.return = '*OK'
720aA    and optint.vala = 'Y';
720aA     debugflag = *on;
720aA   else;
720aA     debugflag = *off;
720aA   endif;
720aA
720aA   // Log program start
720aA   if debugflag;
720aA     log.pgm = #pgm;
720aA     log.type = 'Start    ';
720aA     log.text = 'Import FTP Purchase orders.';
720aA     WrtLog(log.pgm: log.type: log.text);
720aA   endif;
720aA /end-free
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
     C                   eval      pdwhse = pidwhs
PFCaAC                   select
PFCaAC                   when      client = prestofoods
PFCaAC                   eval      pdpo = %xlate(lower:UPPER:pidpo)
PFCaAC                   other
     C                   eval      pdpo = pidpo
PFCaAC                   endsl
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
HMWdAc                   if        client = hmwagner
HMWdAc                             and pidspc <> 'XD'
HMWdAC                   eval      pdspcl = *blanks
HMWdAC                   else
     C                   eval      pdspcl = pidspc
HMWdAC                   endif
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
PFCaAC                   select
PFCaAC                   when      client = prestofoods
PFCaAC                   eval      phpo = %xlate(lower:UPPER:pihpo)
PFCaAC                   other
     C                   eval      phpo = pihpo
PFCaAC                   endsl
     C                   eval      phven = pihven
     C                   eval      phvnam = pihvna
     C                   eval      phvad1 = pihva1
     C                   eval      phvad2 = pihva2
     C                   eval      phvcty = pihvct
     C                   eval      phvst = pihvst
     C                   eval      phvzp1 = pihvzp
     C                   eval      phstat = *off
     C                   move      pihdte        phdate
     C                   eval      phtime = pihtim
     C                   eval      phampm = *blanks
     *R                   MOVE '*CURCMD '$CVCMD
     *R                   CALL @CVTDT
     *R                   PARM           $CVTDT
     *R                   Z-ADD$CVD8O    OHSDTE
     *R                   TIME           OHSTIM
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
510 A*----------------------------------------------------------------
510 A*
510 A*  GETMIS  Get P/O Header Misc.
510 A*
510 AC     getmis        begsr
510 A*
510 AC     pidkey        chain     impfpohm                           72
510 AC                   if        *in72
510 AC                   eval      pihmm1 = *blanks
510 AC                   eval      pihmm2 = *blanks
510 AC                   eval      pihmm3 = *blanks
510 AC                   eval      pihmm4 = *blanks
510 AC                   eval      pihmm5 = *blanks
510 AC                   endif
510 A*
510 AC                   endsr
510 A*
520bA*----------------------------------------------------------------
520bA*
520bA*  GTPODM  Get P/O Detail Misc.
520bA*
520bAC     gtpodm        begsr
520bA*
520bAC     podmky        chain     impfpodm                           70
520bAC                   if        *in70
520cAC                   eval      pidods = *blanks
520bAC                   eval      pidpom = *blanks
520bAC                   eval      pidms1 = *blanks
520bAC                   eval      pidms2 = *blanks
520bAC                   eval      pidms3 = *blanks
520bAC                   eval      pidms4 = *blanks
520bAC                   eval      pidms5 = *blanks
520bAC                   endif
520bA*
520bAC                   endsr
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
417 A*
417 A*      If printer already open then close it.
417 A*
417 AC                   if        opened = *on
417 AC                   close     pi2651pr
417 AC                   endif
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
417 A*
417 AC                   endif
417 A*
417 AC                   endsr
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
HMWxAC                   select
HMWxAC                   when      client = hmwagner
SBRaAC                             or client = sbertram
HMWxAC                   eval      pidqo2 = 0
HMWxAC                   other
     C                   eval      detmsg = desc(7)
     C                   add       1             ttlexc
HMWxAC                   endsl
     C                   endif
     *
     C                   if        pidqo3 <> 0  and
     C                             itflg2 <> 'Y'
HMWxAC                   select
HMWxAC                   when      client = hmwagner
SBRaAC                             or client = sbertram
HMWxAC                   eval      pidqo3 = 0
HMWxAC                   other
     C                   eval      detmsg = desc(7)
     C                   add       1             ttlexc
HMWxAC                   endsl
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
CPC A*
CPC A*----------------------------------------------------------------
CPC A*
CPC A*  ZZCHKE   Check if p/o has been previously exported to Host.
CPC A*
CPS AC     zzchke        begsr
CPC A*
CPC AC     phhkey        setll     pohhdr                                 65
CPC AC                   if        *in65
CPC AC                   eval      pihtyp = 'E'
CPC AC                   endif
CPC A*
CPC AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDEL   Delete P.O.
     *
     C     zzdel         begsr
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
750aA   // Set status for DockVue
750aA   exec sql update postatus
750aM   //          set posstat = 'X',
750cM               set posstat = 'D',
750aA                   posupdts = current_timestamp
750aA             where poswhs = :phwhse
750aA               and pospo = :phpo;
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
PFCaAC                   select
PFCaAC                   when      client = prestofoods
PFCaAC                   eval      pidpo = %xlate(lower:UPPER:pidpo)
PFCaAC                   endsl
     *
GFS AC                   if        client = gtfrsh
GFS AC     podkyp        chain     podtl                              75
GFS AC                   else
GFS A*
     C     podkyf        chain     podtl                              75
GFS AC                   endif
GFS A*
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
520bA*
520bA*    Delete Misc. detail file record.
520bAC                   if        mscdup = '*YES'
GFS A*
GFS AC                   if        client = gtfrsh
GFS AC     podkyp        chain     podtlm                             69
GFS AC                   else
GFS A*
520bAC     pdmkey        chain     podtlm                             69
GFS AC                   endif
GFS A*
520bAC                   if        not *in69
520bAC                   delete    pdmrec
520bAC                   endif
520bAC                   endif
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
TPC A*
TPC AC                   if        client = TPC
TPC A*      Item found on cross dock order. Update XD flag.
TPC AC     podkyf        chain     podtl
TPC AC                   if            %found(podtl)
TPC AC                             and pdspcl = ' '
TPC AC                   eval      pdspcl = 'XD'
TPC AC                   update    pdrec
TPC AC                   else
TPC AC                   unlock    podtl
TPC AC                   endif
TPC A*
TPC AC                   endif
TPC A*
     C                   leave
TPC A*
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
     C     good1         cabne     'Y'           endupd
     *
     *  See if detail line exists. Change Type accordingly.
     *
PFCaAC                   select
PFCaAC                   when      client = prestofoods
PFCaAC                   eval      pidpo = %xlate(lower:UPPER:pidpo)
PFCaAC                   endsl
GFS AC                   if        client = gtfrsh
GFS AC     podkyp        chain     podtl                              75
GFS AC                   else
GFS A*
     C     podkyf        chain     podtl                              75
GFS AC                   endif
GFS A*
     C                   if        *in75
     C                   eval      dtype = 'A'
     C                   eval      pdqrc1 = *zeros
     C                   eval      pdqrc2 = *zeros
     C                   eval      pdqrc3 = *zeros
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
415 AC                   goto      endupd
415 AC                   endif
415 AC                   endif
     *
     *  Type = Change
     *
     C                   if        dtype = 'C'
     C                   exsr      fillod
     C                   update    pdrec
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
     C                   endif
750aA /free
750aA   // Set status for DockVue
750aA   exec sql insert into postatus
750aA            values (:phwhse, :phpo, :phstat,
750aA                    current_timestamp, :nostamp);
750bA*
750bA   if sqlstate <> '00000';
750bA   exec sql update postatus
750bA               set posstat = :phstat,
750bA                   posupdts = current_timestamp
750bA             where poswhs = :phwhse
750bA               and pospo = :phpo;
750bA   endif;
750bA*
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
     C                   endif
750aA /free
750aA   // Set status for DockVue
750aA   exec sql insert into postatus
750aA            values (:phwhse, :phpo, :phstat,
750aA                    current_timestamp, :nostamp);
750bA*
750bA   if sqlstate <> '00000';
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
520bA*  See if detail misc. exists.
520bA*
GFS AC                   if        client = gtfrsh
GFS AC     podkyp        chain     podtlm                             69
GFS AC                   else
GFS A*
520bAC     pdmkey        chain     podtlm                             69
GFS AC                   endif
520bA*
520bA*  Detail Misc. does not exist, create it and leave.
520bA*
520bAC                   if        *in69
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
CSP D*          CLIENT    IFEQ YHATA
CSP MC                   when      client = yhata
YHT A*     Last 3 bytes are reserved for H&S freight code.
YHTbD*          37        SUBSTPIHVA2:1  PHVAD2
YHTbMC     31            subst     pihva2:1      phvad2
CSP A*
CSP D*                    ELSE
CSP MC                   other
520fAC                   eval      phvad2 = pihva2
CSP D*                    ENDIF
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
750bA   if sqlstate <> '00000';
750bA   exec sql insert into postatus
750bA            values (:phwhse, :phpo, :phstat,
750bA                    current_timestamp, :nostamp);
750bA   endif;
750aA /end-free
500 A*
500 AC     endupt        endsr
HMWaA*
HMWaA*----------------------------------------------------------------
HMWaA*
HMWaA*  ZZWAGNER   Fix fields for H&M Wagner import.
HMWaA*
HMWaAC     zzwagner      begsr
HMWaA /free
HMWa
HMWaA   // left adjust PO# in header
HMWaA   exec sql
HMWaA     update impfpoh2
HMWaA       set pihpo  = ltrim(pihpo),
HMWbA           pihvna = ltrim(pihvna);
HMWaA
HMWaA   // left adjust PO#, item#, and vend item# in detail
HMWaA   exec sql
HMWaA     update impfpod2
HMWaA       set pidpo  = ltrim(pidpo),
HMWaA           piditm = ltrim(piditm),
HMWaA           pidvit = ltrim(pidvit);
HMWa
SBRaA   // change warehouse for S.Bertram
SBRaA   if client = sbertram;
SBRaA     exec sql
SBRaA      delete from impfpoh2
SBRaD   //  where pihwhs > 3;
SBRbM       where pihwhs > 6
SBRcM         and pihwhs <> 9;
SBRaA     exec sql
SBRaA      delete from impfpod2
SBRaD   //  where pidwhs > 3;
SBRbM       where pidwhs > 6
SBRcM         and pihwhs <> 9;
SBRaA
SBRaA     exec sql
SBRaA      update impfpoh2
SBRaA         set pihven = :pihwhs,
SBRaA             pihwhs = 1
SBRaA       where pihwhs <> 1;
SBRaA
SBRaA     exec sql
SBRaA      update impfpod2
SBRaA         set pidwhs = 1
SBRaA       where pidwhs <> 1;
SBRa    endif;
HMWa
HMWaA /end-free
HMWaAC                   endsr
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
*PO Exported.No Upd*
**
Import FTP Purchase Orders
**   OVRPRTF statment
OVRPRTF FILE(PI2651PR)           OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
