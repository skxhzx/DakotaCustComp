      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  XM157     Create XML/ASN Advance Ship Notice files and
     *            EXPFORDASN export file.
     *
     *  16 January 2008
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
CWD A*    04/28/15  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. TOTEHDR file had order id added
     *        to make file key unique.
     *
     *----------------------------------------------------------------
     *
     *  To compile:
     *
     *    CRTBNDRPG PGM(xxxlib/*CTLSPEC) SRCFILE(xxxlib/QRPGSRC)
     *     SRCMBR(xm157) DBGVIEW(*SOURCE)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    01/16/08  RBD  5.20  P#00003
     *      - Created for Harbor.
     *
520aA*    02/12/08  DAS  5.20a  P#00003
     *      - Modified order header misc file definitions.
     *      - Revised to use BFCIFSBND binding directory.
     *
520bA*    02/14/08  RBD  5.20b  P#00011
     *      - Added new file TOTEHDR and logic to write the tote
     *        hdr record and its corresponding items to the ASN file.
     *      - Added new export file EXPFORDASN.
     *      - Added new file LABEL94.
     *      - Added new file WORKLB94.
     *      - Removed old logic for clarity.
     *
520cA*    05/14/08  RBD  5.20c  P#00011
     *      - Revised to write HL Pack record for non-tote
     *        items as well as totes.  Removed former logic for
     *        clarity.
     *      - In the second parm of the HL Item record, write
     *        the parent HL Pack number.
     *
520dA*    10/06/08  RBD  5.20d P#00011
     *      - Fix: Change field name TOHNUM to TOHCNT as TOHNUM was
     *        already being used in TORDH.  Also, field sizes for
     *        TOHNUM (now TOHCNT), TOHPCS, and OEATOT have increased.
     *
520eA*    07/01/09  RBD  5.20e P#00218
     *      - Output cust ord# to OEAORD instead of BFC ord#.
     *      - Added host line seq#.
     *      - Added qty shipped.
     *
520fA*    07/01/09  RBD  5.20f P#00218
     *      - Skip the creation of the XML file.
     *      - NOTE: If creation of the XML file ever needs to be
     *        reinstated, simply delete all 520f revisions.
     *
520gA*    07/30/09  RBD  5.20g
     *      - Fix: Allow for lwgen to be > 2.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - Harbor
     *
HARaA*    02/18/08  RBD  HARa  P#00011
     *      - Added logic to write XML records and EXPFORDASN recs
     *        for CLR/FRZ zones.
     *
HARbA*    03/03/08  RBD  HARb  P#00011
     *      - Hardcode item status code as 'AC'.
     *
HARcA*    05/22/08  RBD  HARc  P#00011
     *      - Retrieve upc code from ORDDM/OMMSC1/hardm1_mfgcd and
     *        hardm1_item.
     *
HARdA*    07/01/09  RBD  HARd  P#00218
     *      - Qty shipped will be 1 for non-tote items, qty picked
     *        for tote items.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

520eMFlabel     if   e           k disk    prefix(L_)
520bAFlabel94   if   e           k disk    rename(lbrec:lbrec94)
     Fordad     if   e           k disk
520eAFordd      if   e           k disk
HARaAForddm     if   e           k disk
     Fordhm     if   e           k disk
     Fordh9     if   e           k disk
     Fpiritem   if   e           k disk
520bAFtotehdr   if   e           k disk
     Fwarehs    if   e           k disk
     Fwarehsad  if   e           k disk
520bAFworklb94  if   e           k disk
520bAFexpfordasno    e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D recval          s             90    dim(1) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /COPY QCOPYSRC,ID#harbor

     *----------------------------------------------------------------
     *  IFS Prototypes
     *----------------------------------------------------------------

520aAD/copy qcopysrc,c#ifsio_h
520aAD/copy qcopysrc,c#errno_h

HARaA*----------------------------------------------------------------
HARaA*  Order Misc field data structures
HARaA*----------------------------------------------------------------
HARaA
HARaA /copy qcopysrc,ohmisc_har

     *----------------------------------------------------------------
     *  HARBOR header misc file data structures
     *----------------------------------------------------------------

      /copy qcopysrc,ordhm1_har
      /copy qcopysrc,ordhm2_har
      /copy qcopysrc,ordhm3_har
      /copy qcopysrc,ordhm4_har
      /copy qcopysrc,ordhm5_har

HARaA*----------------------------------------------------------------
HARaA*  Order detail misc file data structures
HARaA*----------------------------------------------------------------
HARaA
HARaA /copy qcopysrc,orddm1_har
HARaA /copy qcopysrc,orddm2_har
HARaA /copy qcopysrc,orddm3_har
HARaA /copy qcopysrc,orddm4_har
HARaA /copy qcopysrc,orddm5_har

     *----------------------------------------------------------------
     *  SSCC-18 data structure
     *----------------------------------------------------------------

     D sscc18          ds
     D  AIcode                 1      2  0 inz(0)
     D  UCCcodePrefix          3      3  0 inz(0)
     D  UCCcode                4     10  0 inz(0)
     D  ordup#                11     19  0 inz(0)
     D  checkdigit            20     20  0 inz(0)
     D  sscc18bcode            1     20  0 inz(0)
520bAD  sscc18right18          3     20  0 inz(0)

     *----------------------------------------------------------------
     *  Working variables
     *----------------------------------------------------------------

520aAD asnOrder        s               n
     D fd              s             10I 0
     D filnam          s             29
520bAD hld_item        s             15
520bAD hld_label       s              7  0
520bAD hld_labtype     s              1
520bAD hld_seq         s              5  0
520bAD hld_totenum     s              3  0
520bAD hld_trans       s              7  0
520bAD hld_umt         s              1
     D hld_upc         s             16
     D ItemStatCode    s              2
     D line            s           1024A
     D len             s             10I 0
     D LoopCtrPack     s              3  0
     D LoopCtrTot      s              3  0
     D UnfmtDate       s              8  0
     D UnfmtTime       s              6  0
     D value0          s              1  0 inz(0)

     *----------------------------------------------------------------
     *  Date/time variables
     *----------------------------------------------------------------

     D currtimestamp   s               z
     D datestamp       s               d   datfmt(*iso )
     D editdate        c                   '    -  -  '
     D edittime        c                   '  :  :  '
     D micro           s             26
     D micro4          s              4
     D timestamp       s               t   timfmt(*hms )

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D forevr          c                   const('1')

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
     *      $PRTE   Route
     *
     *    Returned Parameters
     *      $PRTN   *OK      - Stop was processed.
     *              *CANCEL  - Stop was not processed.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
     C                   parm                    $prtn             8

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  Get order header record

     C     keyoh_p       setll     ordh9
     C                   dou       forevr <> forevr
     C     keyoh_p       reade     ordh9
     *
     C                   if        %eof(ordh9)
     C                   leave
     C                   endif
520aA
520aA*  Skip if not an ASN order.
520aA
520aAC                   eval      asnOrder = *off
520aA
520aAC                   select
520aA
HARaAC                   when      client = harbor
HARaAC                   eval      harmsc_base = ohmisc
HARaAC                   if        harmsc_asn = 'Y'
HARaAC                   eval      asnOrder = *on
HARaAC                   endif
520aA
520aAC                   endsl
520aA
520aAC                   if        not asnOrder
520aAC                   iter
520aAC                   endif
     *
     *  Get order header miscellaneous record
     *
     C     keyod         chain     ordhm
     C                   if        not %found(ordhm)
     C                   iter
     C                   endif
     *
     C                   eval      harhm1_base = hmmsc1
     C                   eval      harhm2_base = hmmsc2
     C                   eval      harhm3_base = hmmsc3
     C                   eval      harhm4_base = hmmsc4
     C                   eval      harhm5_base = hmmsc5
     *
     *  Get field defaults.
     *
     C                   exsr      zzDft
     *
520fAC                   goto      skip1
     *
     *  Construct file name using ASN_ , whse, route id, Dakota ord number,
     *  and stop
     *
     C                   eval      filnam = 'ASN_W'
     C                                +  %TrimL(%editc($pwhse:'X'))
     C                                + 'R'
     C                                + $prtid
     C                                + 'O'
     C                                +  %TrimL(%editc(ohord:'X'))
     C                                + 'S'
     C                                +  %TrimL(%editc(ohstop:'X'))
     C                                +  '.TXT'
     *
     *  Open the file to write to, get out if error
     *
     c                   eval      fd = open('/Harbor/' + filnam:
     c                                  O_TRUNC+O_CREAT+O_WRONLY:
     c                                  S_IWUSR+S_IRUSR+S_IRGRP+S_IROTH)
     c                   if        fd < 0
     c                   callp     die('open(): ' + %str(strerror(errno)))
     C                   goto      bottom
     c                   endif
     *
520fAC     skip1         tag
     *
     C                   eval      $prtn = '*OK    '
     *
     *  Get warehouse name
     *
     C     keywhs        chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *  Get warehouse address
     *
     C     keywhs        chain     warehsad
     C                   if        not %found(warehsad)
     C                   eval      whaad1 = *blanks
     C                   eval      whaad2 = *blanks
     C                   eval      whacty = *blanks
     C                   eval      whast  = *blanks
     C                   eval      whazip = *blanks
     C                   endif
     *
520fAC                   goto      skip2
     *
     *  Write HDR record
     *
     C                   eval      line = 'HDR|'
520aMC                                +  %TrimL(%editc(harhm1_Duns#:'X'))
     C                                +  '|'
     C                                +  %Trim(whdesc)
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write BSN record
     *
     *      Get and format date/time
     C                   time                    currtimestamp
     C                   move      currtimestamp datestamp
     C                   move      datestamp     UnfmtDate
     C                   move      currtimestamp timestamp
     C                   move      timestamp     UnfmtTime

     C                   eval      line = 'BSN|00|'
     C                                +  %TrimL(%editc(ohcord:'P'))
     C                                +  '|'
     C                                +  %Trim(%editc(UnfmtDate:'X'))
     C                                +  '|'
     C                                +  %Trim(%editc(UnfmtTime:'X'))
     C                                +  '|0001|AS'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Shipment HL Loop ... HL record
     *
     C                   eval      LoopCtrTot = 1
     *
     C                   eval      line = 'HL|'
     C                                +  %TrimL(%editc(LoopCtrTot:'P'))
     C                                +  '||S|1'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Shipment HL Loop ... REF vendor record
     *
     C                   eval      line = 'REF|VR|'
     C                                +  %TrimL(%editc(harhm1_WlgV#:'X'))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Shipment HL Loop ... DTM record
     *
     C                   eval      line = 'DTM|011|'
     C                                +  %TrimL(%editc(harhm1_ShpDt:'X'))
     C                                +  '|'
     C                                +  %Trim(%editc(UnfmtTime:'X'))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write N1 Loop ... N1 ST store number record
     *
     C                   eval      line = 'N1|ST||92|'
     C                                +  %TrimL(%editc(harhm1_WlgS#:'X'))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write N1 Loop ... N3 ship to address
     *
     C                   eval      line = 'N3|'
     C                                +  %Trim(ohcad1)
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write N1 Loop ... N4 ship to city, state, and zip
     *
     C                   eval      line = 'N4|'
     C                                +  %Trim(ohccty)
     C                                +  '|'
     C                                +  %Trim(ohcst)
     C                                +  '|'
     C                                +  %Trim(ohczip)
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write N1 Loop ... N1 SE shipper name record
     *
     C                   eval      line = 'N1|SE|'
     C                                +  %Trim(whdesc)
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write N1 Loop ... N3 shipper address
     *
     C                   eval      line = 'N3|'
     C                                +  %Trim(whaad1)
     C                                +  '  '
     C                                +  %Trim(whaad2)
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write N1 Loop ... N4 shipper city, state, and zip
     *
     C                   eval      line = 'N4|'
     C                                +  %Trim(whacty)
     C                                +  '|'
     C                                +  %Trim(whast)
     C                                +  '|'
     C                                +  %Trim(whazip)
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Order HL Loop
     *
     C                   eval      LoopCtrTot = LoopCtrTot + 1
     *
     C                   eval      line = 'HL|'
     C                                +  %TrimL(%editc(LoopCtrTot:'P'))
     C                                +  '|1|O|1'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Order HL Loop ... PRF, PO record
     *
     C                   eval      line = 'PRF|'
     C                                +  %Trim(ohcpo)
     C                                +  '|||'
520aMC                                +  %TrimL(%editc(harhm1_PODte:'X'))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
520fAC     skip2         tag
     *
     *  End of writing header records to XML/ASN export file
     *
     *-------------------------------------------------------------------------
     *
     *  Loop through order detail SSCC-18 recs and write XML/ASN export
     *  detail records and EXPFORDASN records
     *
     C     keyod         setll     ordad
     C                   dou       forevr <> forevr
     C     keyod         reade     ordad
     C                   if        %eof(ordad)
     C                   leave
     C                   endif
     *
     *  Do not process merge records
     *
     C                   if        ordlty = 'M'
     C                   iter
     C                   endif
     *
520bA*  Initialize EXPFORDASN fields
     *
520bAC                   exsr      zzInzExpf
     *
520fAC                   goto      skip3
     *
520cA*  Write Pack HL Loop ... HL record
     *
     C                   eval      LoopCtrTot  = LoopCtrTot  + 1
     C                   eval      LoopCtrPack = LoopCtrTot
     *
     C                   eval      line = 'HL|'
     C                                +  %TrimL(%editc(LoopCtrTot:'P'))
     C                                +  '|2|P|1'
     C                   eval      len = %len(%trimr(line))
     C                   callp     writeline(fd: %addr(line): len)
     *
520fAC     skip3         tag
     *
520cA*  Write Pack HL Loop ... MAN (sscc18) record
     *    Get mod 10 check digit for sscc-18
     *
     C                   exsr      zzGetMod10
     *
520fAC                   goto      skip4
     *
     C                   eval      line = 'MAN|GM|'
     C                                +  %TrimL(%editc(sscc18bcode:'X'))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
520fAC     skip4         tag
     *
     *  Special processing for totes to create pack record,
     *  then tote item records
     *
     C                   if        ordlty = 'T'
     C                   exsr      zzTotes
     C                   iter
     C                   endif
     *
     *  Get item master data
     *
520bAC                   eval      hld_item = orditm
520bAC                   eval      hld_seq = ordsq#
     C                   exsr      zzGetIt
     *
     *  Get label data
     *
     C                   exsr      zzGetLab
     *
     *  Write XML export detail records
     *
     C                   exsr      zzAddXMLdet
     *
520bA*  Write EXPFORDASN export detail records for non-totes
     *
HARdAC                   if        client = harbor
HARdAC                   eval      oeaqty = 1
HARdAC                   endif
     *
520bAC                   eval      hld_label = ordlbl
520bAC                   eval      hld_labtype = ordlty
520bAC                   eval      hld_umt = ordumt
520bAC                   eval      hld_trans = ordtrn
520bAC                   eval      hld_totenum = 0
520bAC                   exsr      zzAddExpf
     *
     C                   enddo
     *
     *---------------------------------------------------------------------
     *
     *  Write eof records
     *
     C                   exsr      zzAddEOF
     *
     *  You're done with this ord/stop, close its file and see if there
     *  are more.
     *
     C                   callp     close(fd)
     *
     C     keyoh         setgt     ordh9
     *
     C                   enddo
     *
     C     bottom        tag
     *
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
     *
     *  Initialize return code to *CANCEL. If file opens successfully,
     *    will change to *OK.
     *
     C                   eval      $prtn = '*CANCEL'
     *
     *  Get client id
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *  Set UCC code and Item Status Code
     *
     C                   if        client = harbor
     C                   eval      UCCcode = 7248913
HARbAC                   eval      ItemStatCode = 'AC'
     C                   endif
     *
     *
HARaA*   Define full key for LABEL94 file
     *
HARaAC     keylab94      klist
HARaAC                   kfld                    $pwhse
HARaAC                   kfld                    $prtid
HARaAC                   kfld                    tohtr#
HARaAC                   kfld                    tohord
HARaAC                   kfld                    ohstop
     *
     *   Define partial key for ORDAD file
     *
     C     keyod         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord
     *
     *   Define full key for ORDH9 file
     *
     C     keyoh         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    ohstop
     C                   kfld                    ohcord
     *
     *   Define partial key for ORDH9 file.
     *
     C     keyoh_p       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
520bA*   Define full key for ORDDM file
     *
520bAC     keyorddm      klist
520bAC                   kfld                    $pwhse
520bAC                   kfld                    ohord
520bAC                   kfld                    hld_seq
520bAC                   kfld                    hld_item
     *
     *   Define full key for PIRITEM file
     *
     C     keyit         klist
     C                   kfld                    ordwhs
520bAC                   kfld                    hld_item
     *
520bA*   Define partial key for TOTEHDR file
     *
520bAC     keytote       klist
520bAC                   kfld                    ordwhs
520bAC                   kfld                    $prtid
520bAC                   kfld                    ordpal
     *
     *   Define full key for WAREHS and WAREHSAD
     *
     C     keywhs        klist
     C                   kfld                    ohwhse
     *
520bA*   Define full key for WORKLB94 file
     *
520bAC     keywrk94      klist
520bAC                   kfld                    $pwhse
520bAC                   kfld                    $prtid
520bAC                   kfld                    tohtr#
520bAC                   kfld                    tohord
520bAC                   kfld                    ohstop
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZADDEOF   Write XML eof records
     *
     C     zzAddEOF      begsr
     *
520fAC                   goto      skip5
     *
     *  Write CTT record
     *
     C                   eval      line = 'CTT|'
     C                                +  %TrimL(%editc(LoopCtrTot:'P'))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
520fAC     skip5         tag
     *
     C                   endsr

520bA*----------------------------------------------------------------
520bA*
520bA*  ZZADDEXPF        Write EXPFORDASN export detail records
520bA*
520bAC     zzAddExpf     begsr
     *
520eAC     keyorddm      chain     ordd
520eAC                   if        not %found(ordd)
520eAC                   eval      oeahln = 0
520eAC                   else
520eAC                   eval      oeahln = odor2
520eAC                   endif
     *
     C                   eval      oeasq# = hld_seq
     C                   eval      oeaitm = hld_item
     C                   eval      oeaus# = sscc18right18
     C                   eval      oealbl = hld_label
     C                   eval      oealty = hld_labtype
     C                   eval      oeaumt = hld_umt
     C                   eval      oeatrn = hld_trans
     C                   eval      oeatot = hld_totenum
     *
     C                   write     oearec
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZADDXMLDET      Write XML export detail records
     *
     C     zzAddXMLdet   begsr
     *
520fAC                   goto      skip6
     *
     *  Write Item HL Loop ... HL record
     *
     C                   eval      LoopCtrTot = LoopCtrTot + 1
     *
     C                   eval      line = 'HL|'
     C                                +  %TrimL(%editc(LoopCtrTot:'P'))
520cMC                                +  '|'
520cMC                                +  %TrimL(%editc(LoopCtrPack:'P'))
520cMC                                +  '|I|0'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Item HL Loop ... LIN record
     *
     C                   eval      line = 'LIN|'
520bAC                                +  %TrimL(%editc(hld_seq:'P'))
     C                                +  '||UI|'
     C                                +  (hld_upc)
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Item HL Loop ... SN1 record
     *
     C                   eval      line = 'SN1|'
520bAC                                +  %TrimL(%editc(hld_seq:'P'))
     C                                +  '|'
     C                                +  %TrimL(%editc(ordscn:'P'))
     C                                +  '|'
520eMC                                +  %Trim(L_lbucod)
     C                                +  '|||||'
     C                                +  %Trim(ItemStatCode)
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Item HL Loop ... PID record
     *
     C                   eval      line = 'PID|F||||'
     C                                +  %Trim(itdesc)
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
520fAC     skip6         tag
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZDFT      Get default values
     *
     C     zzDft         begsr
     *
520bAC                   eval      loopctrpack  = 0
     C                   eval      loopctrtot  = 0
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZGETIT    Get item master data
     *
     C     zzGetIt       begsr
     *
     C     keyit         chain     piritem
     C                   if        not %found(piritem)
     C                   eval      itdesc = *blanks
     C                   eval      itupc  = *blanks
     C                   endif
     C                   eval      hld_upc = itupc
     *
HARcA*  Get 'mfg item' in lieu of itupc
HARcAC                   if        client = harbor
     *
HARcAC     keyorddm      chain     orddm
HARcAC                   if        not %found(orddm)
HARcAC                   eval      hld_upc = *blanks
HARcAC                   else
HARcAC                   eval      hardm1_base = ommsc1
HARcAC                   eval      hld_upc = %trim(hardm1_mfgcd)
HARcAC                                     + %trim(hardm1_item)
HARcAC                   endif
HARcAC                   endif
     *
     C                   endsr

     *-------------------------------------------------------------------------
     *
     *  ZZGETLAB   Get label data
     *
     C     zzGetLab      begsr
     *
     C     ordlbl        chain     label
     C                   if        not %found(label)
520eMC                   eval      L_lbucod = *blanks
     C                   endif

     C                   endsr
     *
     *----------------------------------------------------------------
     *  ZZGetMod10   Get barcode Modulus 10 check digit
     *----------------------------------------------------------------
     C     zzGetMod10    begsr

     C                   eval      CheckDigit = 0
     C                   movel     sscc18bcode   $cbbar

     C                   call      'CVTBAR'
     C                   parm      '*SSCC-18'    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     C                   parm                    ordwhs
     C                   parm                    orditm

     C                   if        %subst($cberm:1:17) = 'Check digit error'
     C                   eval      CheckDigit = %dec(%subst($cberm:20:1):1:0)
     C                   endif

     C     EndChk10      endsr

HARaA*----------------------------------------------------------------
HARaA*
HARaA*  ZZGetClFzTote   Process cooler/freezer totes
HARaA*
HARaAC     zzGetClFzTote begsr
     *
     *  Loop through label94 recs and write corresponding tote item records
     *
     C     keylab94      setll     label94
     C                   dou       forevr <> forevr
     C     keylab94      reade     label94
     C                   if        %eof(label94)
     C                   leave
     C                   endif
     *
     *    Process only O and B label records
     *
     C                   if        lbtype <> 'O'
     C                             and lbtype <> 'B'
     C                   iter
     C                   endif
     *
     C                   eval      hld_item = lbitem
     C                   eval      hld_seq = lbseq
     *
     *  Get corresponding order detail misc rec and see if this is a tote item
     *
     C     keyorddm      chain     orddm
     C                   if        not %found
     C                   iter
     C                   endif
     C                   eval      hardm1_base = ommsc1
     C                   if        lbutyp = 'N' and hardm1_toten <> 'Y'
     C                             or lbutyp = '1' and hardm1_tote1 <> 'Y'
     C                             or lbutyp = '2' and hardm1_tote2 <> 'Y'
     C                   iter
     C                   endif

     *
     *  Get item master data
     *
     C                   exsr      zzGetIt
     *
     *  Write XML export detail records
     *
     C                   exsr      zzAddXMLdet
     *
     *  Write EXPFORDASN export detail records for cooler/freezer totes
     *
     C                   eval      hld_label = lblbl#
     C                   eval      hld_labtype = lbtype
     C                   eval      hld_umt = lbutyp
     C                   eval      hld_trans = lbtrn#
520dDC**                 eval      hld_totenum = tohnum
520dMC                   eval      hld_totenum = tohcnt
520eAC                   eval      oeaqty = lbqpck
     C                   exsr      zzAddExpf
     *
     C                   enddo
     *
     C                   endsr

520bA*----------------------------------------------------------------
520bA*
520bA*  ZZGetTrueTote   Process true totes
520bA*
520bAC     zzGetTrueTote begsr
     *
     *  Loop through worklb94 recs and write corresponding tote item records
     *
     C     keywrk94      setll     worklb94
     C                   dou       forevr <> forevr
     C     keywrk94      reade     worklb94
     C                   if        %eof(worklb94)
     C                   leave
     C                   endif
     *
     *  Use merge zone gen records only
     *
520gDC**                 if        lwgen <> 2
520gMC                   if        lwgen < 2
     C                   iter
     C                   endif
     *
     *  Get item master data
     *
     C                   eval      hld_item = lwitem
     C                   eval      hld_seq = lwseq
     C                   exsr      zzGetIt
     *
     *  Populate label um code with worklb94 um code
     *
520eMC                   eval      L_lbucod = lwucod
     *
     *  Write XML export detail records
     *
     C                   exsr      zzAddXMLdet
     *
     *  Write EXPFORDASN export detail records for true totes
     *
520eAC     lwlbl#        chain     label
520eAC                   if        %found(label)
520eAC                   eval      oeaqty = L_lbqpck
520eAC                   endif
     *
     C                   eval      hld_label = lwlbl#
     C                   eval      hld_labtype = lwtype
     C                   eval      hld_umt = lwutyp
     C                   eval      hld_trans = lwtrn#
520dDC**                 eval      hld_totenum = tohnum
520dMC                   eval      hld_totenum = tohcnt
     C                   exsr      zzAddExpf
     *
     C                   enddo
     *
     C                   endsr

520bA*----------------------------------------------------------------
520bA*  zzInzExpf       Initialize EXPFORDASN fields
520bA*----------------------------------------------------------------
520bA
520bAC     zzInzExpf     begsr

     C                   eval      oeawhs = $pwhse
520eDC**                 eval      oeaord = ohord
520eMC                   eval      oeaord = ohcord
     C                   eval      oeasq# = 0
     C                   eval      oeaitm = ' '
     C                   eval      oeaus# = 0
     C                   eval      oealbl = 0
     C                   eval      oealty = ' '
     C                   eval      oeaumt = ' '
     C                   eval      oeatrn = 0
     C                   eval      oeatot = 0
520eAC                   eval      oeahln = 0
520eAC                   eval      oeaqty = 0

     C                   endsr

520bA*----------------------------------------------------------------
520bA*
520bA*  ZZTOTES    Process totes
520bA*
520bAC     zzTotes       begsr
     *
     *  Loop through totehdr recs and go get corresponding tote item records
     *
     C     keytote       setll     totehdr
     C                   dou       forevr <> forevr
     C     keytote       reade     totehdr
     C                   if        %eof(totehdr)
     C                   leave
     C                   endif
     *
520bA*    Check for matching trans/ord
     *
520bAC                   if        tohtr# <> ordtrn
520bAC                             or tohord <> ordord
520bAC                   iter
520bAC                   endif
     *
     *
     *    Process true tote item records
     *
     C                   if        tohtr# <> tohmt#
     C                   exsr      zzGetTrueTote
     *
     C                   else
     *
HARa *    For Harbor, process cooler/freezer tote item records
     *
HARaAC                   if        client = harbor
HARaAC                   exsr      zzGetClFzTote
HARaAC                   endif
     *
     C                   endif
     *
     C                   enddo
     *
     C                   endsr

     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,c#errno_h

     *-------------------------------------------------------------------------
     *  COMPILE TIME TABLES
     *-------------------------------------------------------------------------
**  recval
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
