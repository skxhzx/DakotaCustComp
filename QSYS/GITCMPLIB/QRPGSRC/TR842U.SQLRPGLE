      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   24 Washington Ave North #203
     *   Batavia IL  60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR842U  Update TTRTE, TTSTP, and TTITM display data
     *          using TTTRX.
     *          Based TR845. Created to create separation from Trax 1
     *
     *  03 October 2011
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    10/03/11  RBD  6.40
     *      - Created.
     *
640aA*    01/31/12  RBD  6.40a
     *      - Fix.  If no Trax record found on first pass, get out.
     *      - Fix.  In updstop routine file name should be ttstp.
     *
640bA*    03/06/12  RBD  6.40b
     *      - Recompiled, TTSTP file changed.
     *
710aA*    09/21/17  DAS  7.10a
     *      - Added optional parameters Version, Command and Stop.
     *      - Revised to limit for a Stop if Stop passed in.
     *
720aA*    01/15/18  DAS  7.20a
     *     - Revised new single Stop logic. Always want to read
     *       everything in order to recalculate TTRTE values.
     *
720bA*    01/16/18  DAS  7.20b
     *      - Added file RTESTP2.
     *      - Revises ZZINIT to calculate number of stops on the
     *        route (ttrs) from RTESTP2 file.
     *
720cA*    01/23/18  DAS  7.20c
     *      - Revised 720b to use PLTSUM2 instead of RTESTP2.
     *        Cityline's RTESTP file was not being populated.
     *
720dA*    02/19/18  DAS  7.20d
     *      - Revised to update ttrte if no tttrx records found.
     *
740aA*    04/23/20  RBD 7.40a
     *      - Added client custom code support.
     *      - Call EXTTRTE to update fields in TTRTEEXA.
     *      - Call EXTTSTP to update fields in TTSTPEXA.
     *
740bA*   12/11/20  RBD  7.40b
     *     - Fix: Enlarged size of rtnMsg from 60 to 120 because
     *       #pgmmsg, which is 80 long, was being returned as part
     *       of the msg in EXTTRTE *PSSR and could potentially cause
     *       it to blow up.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Southwest Traders
     *
SWTaA*    04/27/20  RBD  SWTa
     *      - Count 'short returns', identified by return code 8.
     *
     *----------------------------------------------------------------
     * File Specs

     Ftttrx     if   e           k disk
     Fttrte     uf a e           k disk
     fttstp     uf a e           k disk
     fttitm     uf a e           k disk
720cMfpltstp2   if   e           k disk
740aAfpltsum2   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     *  Customer id
     *----------------------------------------------------------------

SWTaA /copy qcopysrc,id#swt

     *----------------------------------------------------------------
     *  Working variables

710aAD byStop          s               n
710bAD forever         s               n
     D first           s              1
     D lastItemKey     s             28
     D lastStop        s              2  0
740aAD client          s             10
740aAD clientloc       s             10
740aAD pDspid          s             30
740aAD pSnum           s             30
740aAD pNetid          s             30
740aAD pBlueid         s             30
740aAD pSimid          s             30
740aAD pPhone          s             30
740aAD pAppver         s             20
740aAD rtnCode         s             10
740bDD*rtnMsg          s             60
740bMD rtnMsg          s            120
740aAD stp_pss         s              3p 0 inz(0)
740aAD stp_psc         s              3p 0 inz(0)
740aAD stp_pal         s              3p 0 inz(0)
740aAD stp_iss         s              3p 0 inz(0)
740aAD stp_isc         s              3p 0 inz(0)
740aAD stp_ist         s              3p 0 inz(0)
740aAD stp_retsh       s              4p 0 inz(0)
740aAD stp_ret         s              4p 0 inz(0)
740aAD rte_pss         s              3p 0 inz(0)
740aAD rte_psc         s              3p 0 inz(0)
740aAD rte_pal         s              3p 0 inz(0)
740aAD rte_iss         s              3p 0 inz(0)
740aAD rte_isc         s              3p 0 inz(0)
740aAD rte_ist         s              3p 0 inz(0)
740aAD rte_retsh       s              4p 0 inz(0)
740aAD rte_ret         s              4p 0 inz(0)
740aAD returncd        s              2

740aA*----------------------------------------------------------------
740aA*  Standard SQL variables and constants
740aA*----------------------------------------------------------------

740aA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Date/time variables

     D bfcoffset       s              3  0 inz(0)
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D currtimestamp   s               z
     D datestamp       s               d
     D editdate        s               d
     D edittime        s               t   timfmt(*hms:)
     D micro           s             26
     D micro4          s              4
     D timestamp       s               t   timfmt(*hms:)

     *----------------------------------------------------------------
     *  Program info data structure

      /copy qcopysrc,c#pgminfds

740aA*----------------------------------------------------------------
740aA*  Called Programs Prototypes
740aA*----------------------------------------------------------------

740aA /copy qcopysrc,p.getclien
740aAd/copy qcopysrc,p.exttrte
740aAd/copy qcopysrc,p.exttstp

     *----------------------------------------------------------------
     *  Constants

     D forevr          c                   const('1')

     *----------------------------------------------------------------
     *  TTITM data structure key

     D                 ds
     D  keyitm                 1     28
     D  ttxwhs                 1      3  0 inz(0)
     D  ttxrti                 4      8
     D  ttxstp                 9     10  0
     D  ttxitm                11     25
     D  ttxum                 26     27
     D  ttxopf                28     28

740aA*----------------------------------------------------------------
740aA*  Pallet id data structure
740aA*
740aA*    DSPLID  -  Pallet id.
740aA*    DSPLXX  -  Unused.
740aA*    DSPLGN  -  Generation.
740aA*    DSPLRW  -  Pallet row.
740aA*    DSPLCL  -  Pallet column.
740aA*    DSPLSQ  -  Sequence number.
740aA*               Equal to zero     - Only one pallet in this position.
740aA*               Greater than zero - Multiple pallets in this position.
740aA*
740aAD pltid           ds
740aAD  dsplid                 1      7  0 inz(0)
740aAD  dsplxx                 1      2  0
740aAD  dsplgn                 3      3  0
740aAD  dsplrw                 4      5  0
740aAD  dsplcl                 6      6  0
740aAD  dsplsq                 7      7  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
710aA*      $PVER   Trax Version
710aA*      $PCMD   Command passed into TRCMPRTE2, TR842
710aA*      $PSTOP2 2-digit Stop
     *
     *    Returned Parameters
     *      $PRTN   *OK      - Route was processed.
     *              *CANCEL  - Route was not processed.
     *      $PERM            - Error message.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prtn             8
     C                   parm                    $perm            60
710aAC                   parm                    $pver             5
710aAC                   parm                    $pcmd            30
710aAC                   parm                    $pStop2           2 0

     * Main line

     C                   eval      $prtn = '*OK    '
     C                   eval      first = *on
710aA* See if we are processing a single Stop
710aA
710aAC                   eval      byStop = *off
710aAC                   if        %parms >= 7
710aAC                   if        $pcmd = 'postCompletedStop'
710aAC                   eval      byStop = *on
710aAC                   endif
710aAC                   endif

     *  Loop through Trax pieces file and update TTRTE, TTSTP, and TTITM
     *  display and report data.

720aDC**                 if        byStop
720aDC**   keyTrxStp     setll     tttrx
720aDC**                 else
     C     keyTrx        setll     tttrx
720aDC**                 endif
     C                   dou       forevr <> forevr
720aDC**                 if        byStop
720aDC**   keyTrxStp     reade     tttrx
720aDC**                 else
     C     keyTrx        reade     tttrx
720aDC**                 endif

     *  At end of file write last item, update last stop, update route
     *  and get out.

640aAC                   if        %eof(tttrx) and first = *on
720dAC                   if        %found(ttrte)
720dAC                   update    ttrrec
720dAC                   else
720dAC                   write     ttrrec
720dAC                   endif
640aAC                   goto      bottom
640aAC                   endif

     C                   if        %eof(tttrx)
720aAC                   if        not byStop
720aAC                             or byStop and ttistp = $pStop2
     C                   write     ttirec
720aAC                   endif
     C                   exsr      addToStop
     C                   exsr      updStop
     C                   exsr      addToRte

     C                   if        %found(ttrte)
     C                   update    ttrrec
     C                   else
     C                   write     ttrrec
     C                   endif

740aAc                   exsr      updRouteEXA

     C                   leave
     C                   endif

     *  At end of item, when item changes, write TTITM record
     *  and update TTSTP fields.

     C                   if        lastItemKey <> keyitm
     C                             and first = *off
720aAC                   if        not byStop
720aAC                             or byStop and ttistp = $pStop2
     C                   write     ttirec
720aAC                   endif
     C                   exsr      addToStop
     C                   endif

     *  At end of stop, when stop changes, update TTSTP record
     *  and TTRTE fields.

     C                   if        lastStop <> ttxstp
     C                             and first = *off
     C                   exsr      updStop
     C                   exsr      addToRte
     C                   endif

     *  At beginning of item, when item changes, clear and fill
     *  TTITM fields.

     C                   if        lastItemKey <> keyitm
     C                   exsr      fillItem
     C                   eval      lastItemKey = keyitm
     C                   endif

     *  At beginning of stop, when stop changes, retrieve and clear
     *  TTSTP fields.

     C                   if        lastStop <> ttxstp
     C                   exsr      fillStop
     C                   eval      lastStop = ttxstp
     C                   endif

     C                   if        first = *on
     C                   eval      first = *off
     C                   endif

     *  Add TTTRX values to TTITM fields.

     C                   exsr      addToItem

740aA*  Add TTTRX values to TTSTPEXA fields.

740aAc                   if        %Subst(ttxitm:1:10) = 'PALLETSCAN'
740aAc                             or %Subst(ttxitm:1:12) = 'INSTORESCAN '
740aAc                   exsr      addToExa
740aAc                   endif

     C                   enddo

     C     bottom        tag

     C                   eval      *inlr = *on
     *----------------------------------------------------------------

     *          SUBROUTINES IN ALPHABETICAL ORDER

     *----------------------------------------------------------------

     *  *INZSR  Initialization subroutine

     C     *inzsr        begsr

     *   Define partial key for TTTRX file

     C     keyTrx        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
720aD **  Define partial key for TTTRX file with Stop
720aDC**   keyTrxStp     klist
720aDC**                 kfld                    $pwhse
720aDC**                 kfld                    $prtid
720aDC**                 kfld                    $pstop2

     *   Define full key for TTSTP file

     C     keyStp        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    ttxstp

740aA /free
740aA    getclient(client: clientLoc);
740aA /end-free

     *   Call user added initialization routine.

     C                   exsr      zzinz

     C                   endsr
     *----------------------------------------------------------------

     *  addToItem   Add Trax record values to item totals

     C     addToItem     begsr

     C                   eval      ttiqs1 = ttiqs1 + ttxqs1
     C                   eval      ttiqs2 = ttiqs2 + ttxqs2
     C                   eval      ttiqs3 = ttiqs3 + ttxqs3
     C                   eval      ttiqn1 = ttiqn1 + ttxqn1
     C                   eval      ttiqn2 = ttiqn2 + ttxqn2
     C                   eval      ttiqn3 = ttiqn3 + ttxqn3
     C                   eval      ttiqc1 = ttiqc1 + ttxqc1
     C                   eval      ttiqc2 = ttiqc2 + ttxqc2
     C                   eval      ttiqc3 = ttiqc3 + ttxqc3
     C                   eval      ttiqp1 = ttiqp1 + ttxqp1
     C                   eval      ttiqp2 = ttiqp2 + ttxqp2
     C                   eval      ttiqp3 = ttiqp3 + ttxqp3

     C                   endsr

     *----------------------------------------------------------------

     *  addToRte   Add stop totals to route totals

     C     addToRte      begsr

720bDC**                 eval      ttrs   = ttrs + 1
     C                   if        ttpdlv = '1'
     C                   eval      ttrsd  = ttrsd + 1
     C                   endif
     C                   if        ttpscn = '0'
     C                   eval      ttrscn = '0'
     C                   endif
     C                   eval      ttrqs1 = ttrqs1 + ttpqs1
     C                   eval      ttrqs2 = ttrqs2 + ttpqs2
     C                   eval      ttrqs3 = ttrqs3 + ttpqs3
     C                   eval      ttrqn1 = ttrqn1 + ttpqn1
     C                   eval      ttrqn2 = ttrqn2 + ttpqn2
     C                   eval      ttrqn3 = ttrqn3 + ttpqn3
     C                   eval      ttrqc1 = ttrqc1 + ttpqc1
     C                   eval      ttrqc2 = ttrqc2 + ttpqc2
     C                   eval      ttrqc3 = ttrqc3 + ttpqc3
     C                   eval      ttrqp1 = ttrqp1 + ttpqp1
     C                   eval      ttrqp2 = ttrqp2 + ttpqp2
     C                   eval      ttrqp3 = ttrqp3 + ttpqp3

     C                   endsr

     *----------------------------------------------------------------

     *  addToStop  Add item totals to stop totals

     C     addToStop     begsr

     C                   eval      ttpqs1 = ttpqs1 + ttiqs1
     C                   eval      ttpqs2 = ttpqs2 + ttiqs2
     C                   eval      ttpqs3 = ttpqs3 + ttiqs3
     C                   eval      ttpqn1 = ttpqn1 + ttiqn1
     C                   eval      ttpqn2 = ttpqn2 + ttiqn2
     C                   eval      ttpqn3 = ttpqn3 + ttiqn3
     C                   eval      ttpqc1 = ttpqc1 + ttiqc1
     C                   eval      ttpqc2 = ttpqc2 + ttiqc2
     C                   eval      ttpqc3 = ttpqc3 + ttiqc3
     C                   eval      ttpqp1 = ttpqp1 + ttiqp1
     C                   eval      ttpqp2 = ttpqp2 + ttiqp2
     C                   eval      ttpqp3 = ttpqp3 + ttiqp3

     C                   endsr

740aA*----------------------------------------------------------------
740aA
740aA*  addToExa  Add TTTRX counts to extended route and stop totals
740aA
      /free

        begsr addToExa;

          select;

            when ttxitm = 'PALLETSCAN';
              if ttxopf = 'S';
                stp_pss += 1;
                rte_pss += 1;
              else;
                stp_psc += 1;
                rte_psc += 1;
              endif;

            when ttxitm = 'INSTORESCAN';
              if ttxopf = 'S';
                stp_iss += 1;
                rte_iss += 1;
              endif;
              if ttxopf = 'C';
                stp_isc += 1;
                rte_isc += 1;
              endif;

              stp_ist += 1;
              rte_ist += 1;

          endsl;

        endsr;

      /end-free

     *----------------------------------------------------------------

     *  fillItem   Clear and fill item fields

     C     fillItem      begsr

     C                   clear                   ttirec
     C                   eval      ttiwhs = ttxwhs
     C                   eval      ttirti = ttxrti
     C                   eval      ttirte = ttxrte
     C                   eval      ttistp = ttxstp
     C                   eval      ttiitm = ttxitm
     C                   eval      ttium  = ttxum
     C                   eval      ttiopf = ttxopf
     C                   eval      ttisrd = ttxsrd
     C                   eval      ttisrt = ttxsrt

     C                   endsr

     *----------------------------------------------------------------

     *  fillStop   Fill stop fields

     C     fillStop      begsr

720aAC                   if        not byStop
720aAC                             or byStop and ttxstp = $pStop2
     C     keyStp        chain     ttstp
720aAC                   else
710aAC     keyStp        chain(n)  ttstp
720aAC                   endif

     C                   if         not %found(ttstp)
     C                   eval      ttpwhs = ttxwhs
     C                   eval      ttprti = ttxrti
     C                   eval      ttpstp = ttxstp
     C                   eval      ttpmem = 'Did not exist, added by TR845'
     C                   eval      ttpsrd = 0
     C                   eval      ttpsrt = 0
     C                   eval      ttpfid = 0
     C                   eval      ttpfit = 0
     C                   endif

     C                   eval      ttprte = ttxrte
     C                   eval      ttpdlv = '1'
     C                   eval      ttpscn = '0'
     C                   eval      ttpqs1 = 0
     C                   eval      ttpqs2 = 0
     C                   eval      ttpqs3 = 0
     C                   eval      ttpqn1 = 0
     C                   eval      ttpqn2 = 0
     C                   eval      ttpqn3 = 0
     C                   eval      ttpqc1 = 0
     C                   eval      ttpqc2 = 0
     C                   eval      ttpqc3 = 0
     C                   eval      ttpqp1 = 0
     C                   eval      ttpqp2 = 0
     C                   eval      ttpqp3 = 0
740aAC                   eval      stp_pss = 0
740aAC                   eval      stp_psc = 0
740aAC                   eval      stp_pal = 0
740aAC                   eval      stp_iss = 0
740aAC                   eval      stp_isc = 0
740aAC                   eval      stp_ist = 0
740aAC                   eval      stp_retsh = 0
740aAC                   eval      stp_ret = 0

     C                   endsr

740aA*----------------------------------------------------------------
740aA
740aA*  updRouteEXA  Update route EXA file
740aA
740aA /free
740aA   begsr updRouteEXA;
740aA
          trawhse = $pwhse;

          exttrte ('*ADD': rtnCode: rtnMsg: trawhse: $prtid:
                   pDspid: '0': pSnum: '0': pNetid: '0':
                   pBlueid: '0': pSimid: '0':  pPhone: '0': pAppver: '0':
                   rte_pss: '1': rte_psc: '1':
                   rte_pal: '1': rte_iss: '1':  rte_isc: '1':
                   rte_ist: '1': rte_retsh: '1':  rte_ret: '1');

          if rtnCode <> '*OK';
            exttrte ('*CHANGE': rtnCode: rtnMsg: trawhse: $prtid:
                     pDspid: '0': pSnum: '0': pNetid: '0':
                     pBlueid: '0': pSimid: '0':  pPhone: '0': pAppver: '0':
                     rte_pss: '1': rte_psc: '1':
                     rte_pal: '1': rte_iss: '1':  rte_isc: '1':
                     rte_ist: '1': rte_retsh: '1':  rte_ret: '1');
          endif;

        endsr;
      /end-free

     *----------------------------------------------------------------

     *  updStop  Update stop

     C     updStop       begsr

     C                   if        (ttpqs1 + ttpqs2 + ttpqs3 +
     C                              ttpqn1 + ttpqn2 + ttpqn3) = 0
     C                   eval      ttpdlv = '0'
     C                   endif
     C                   if        (ttpqs1 + ttpqs2 + ttpqs3) > 0
     C                              and (ttpqn1 + ttpqn2 + ttpqn3) = 0
     C                   eval      ttpscn = '1'
     C                   endif
720aAC                   if        not byStop
720aAC                             or byStop and ttpstp = $pStop2
640aDC**                 if        %found(ttrte)
640aMC                   if        %found(ttstp)
     C                   update    ttprec
     C                   else
     C                   write     ttprec
     C                   endif
720aAC                   endif

740aA /free

740aA  // Whip through the PLTSUM records to get pallet count

740aA  setll ($pwhse: $prtid: 'O': 1) pltsum2;
740aA  dow forever = forever;

740aA    reade ($pwhse: $prtid: 'O': 1) pltsum2;
740aA    if %eof(pltsum2);
740aA      leave;
740aA    endif;

740aA    // Skip pallets not included on this stop
740aA    if  (laststop < psstp1) or
740aA        (laststop > psstp2);
740aA      iter;
740aA    endif;

740aA    // Skip pallets that are empty
740aA    if pspcs = 0;
740aA      iter;
740aA    endif;

740aA    // Skip pallets that don't have a zero for last digit
740aA    dsplid = psplid;
740aA    if dsplsq > 0;
740aA      iter;
740aA    endif;

740aA    stp_pal += 1;
740aA    rte_pal += 1;

740aA  enddo;


SWTaA  // Count number of returns on stop with return code '8'
SWTaA  if client = swt;
SWTaA    returncd = '8 ';
SWTaA  endif;

740aA  if returncd <> *blanks;

740aA    exec sql select count(*)
740aA             into :stp_retsh
740aA             from ttrtn
740aA             where ttwhse = :$pwhse
740aA               and ttrtid = :$prtid
740aA               and ttstop = :laststop
740aA               and ttrcod = :returncd;

740aA    If sqlstt = sqlSuccess;
740aA      rte_retsh += stp_retsh;
740aA    endif;

740aA  endif;


740aA  // Count total number of returns on stop

740aA  exec sql select count(*)
740aA          into :stp_ret
740aA          from ttrtn
740aA          where ttwhse = :$pwhse
740aA            and ttrtid = :$prtid
740aA            and ttstop = :laststop;

740aA  If sqlstt = sqlSuccess;
740aA    rte_ret += stp_ret;
740aA  endif;


740aA  ttpawhs = $pwhse;
740aA  ttpastp = ttpstp;

740aA  exttstp ('*ADD': rtnCode: rtnMsg: ttpawhs: $prtid:
740aA           ttpastp: stp_pss: '1': stp_psc: '1':
740aA           stp_pal: '1': stp_iss: '1':  stp_isc: '1':
740aA           stp_ist: '1': stp_retsh: '1':  stp_ret: '1');

740aA  if rtnCode <> '*OK';
740aA    exttstp ('*CHANGE': rtnCode: rtnMsg: ttpawhs: $prtid:
740aA             ttpastp: stp_pss: '1': stp_psc: '1':
740aA             stp_pal: '1': stp_iss: '1':  stp_isc: '1':
740aA             stp_ist: '1': stp_retsh: '1':  stp_ret: '1');
740aA  endif;

740aA /end-free

     C                   endsr

     *----------------------------------------------------------------

     *  ZZINZ    Extra program initialization. Called from *INZSR.

     C     zzinz         begsr

     C                   eval      lastItemKey = '@@@@@@@@@@@@@@@'
     C                   eval      lastStop = *loval

     *  Get current date & time
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt

     *   Get Trax route record and clear display fields.

     C     keyTrx        chain     ttrte

     C                   if        not %found(ttrte)
     C                   eval      ttrwhs = $pwhse
     C                   eval      ttrrti = $prtid
     C                   eval      ttrsrd = 0
     C                   eval      ttrsrt = 0
     C                   eval      ttrfid = 0
     C                   eval      ttrfit = 0
     C                   endif

     C                   eval      ttrstd = $cvd8o
     C                   time                    ttrstt
     C                   eval      ttrscn = '1'
     C                   eval      ttrs   = 0
     C                   eval      ttrsd  = 0
     C                   eval      ttrqs1 = 0
     C                   eval      ttrqs2 = 0
     C                   eval      ttrqs3 = 0
     C                   eval      ttrqn1 = 0
     C                   eval      ttrqn2 = 0
     C                   eval      ttrqn3 = 0
     C                   eval      ttrqc1 = 0
     C                   eval      ttrqc2 = 0
     C                   eval      ttrqc3 = 0
     C                   eval      ttrqp1 = 0
     C                   eval      ttrqp2 = 0
     C                   eval      ttrqp3 = 0

720bA*   Calculate number of Stop on the route
720bA
720bA /free
720bA
720cM   setll ($pWhse: $prtid) pltstp2;
720bA   dow forever = forever;
720cM     reade ($pwhse: $prtid) pltstp2;
720cM     if %eof(pltstp2);
720bA       leave;
720bA     endif;
720cM     if pssstp <> laststop and psspcs > 0;
720bA       ttrs += 1;
720cM       laststop = pssstp;
720bA     endif;
720bA   enddo;
720bA   laststop = *loval;
720bA
720bA /end-free

     C                   endsr

     *-------------------------------------------------------------------------
