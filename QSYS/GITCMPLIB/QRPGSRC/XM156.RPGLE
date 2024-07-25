      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  XM156     Create XML/IFS POD AddPalletRequest export file
     *            Cloned from XM155
     *
     *  14 October 2008
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
     *     SRCMBR(xm156) DBGVIEW(*SOURCE)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    10/14/08  RBD  5.20  P#00004
     *      - Created for Harbor.
520aA*    06/02/09  RBD  5.20a  P#00213
     *      - Added logic to abort send attempt once 5 errors
     *        have occurred.
520bA*    06/03/09  RBD  5.20b  P#00212
     *      - Enh: Added 5 more POD error message recipients.
520cA*    06/25/09  RBD  5.20c
     *      - Do not zero suppress POD# written to xml file.
520dA*    07/30/09  RBD  5.20d
     *      - Fix: Allow for lwgen to be > 2.
520eA*    08/26/09  RBD  5.20e
     *      - Fix: Do not add ORDP rec to xml file if scan qty = 0.
520fA*    10/07/09  RBD  5.20f  P#00226
     *      - Revise palletNumber to include a date/time stamp.
     *        Airversent's POD system requires the palletNumber
     *        to be unique, even though without the date/time stamp
     *        the pallet number is unique within a given route.
530 A*    04/30/10  RBD  5.30
     *      - Fix: change klists for TOTEHDR since there is only
     *        1 TOTEHDR record per tote, even if there are multiple
     *        orders in the tote.
     *        Get cust order# by using ord# in ORDP and chaining
     *        back to ORDH.  This ensures the correct cust order#
     *        even if there are multiple orders in the tote.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Harbor
     *
HAR A*    02/17/09  RBD  HAR
     *      - Added logic to write AddPalletRequest files for CLR/FRZ
     *        zones.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *      - Use BFCIFSBND binding directory.
     *
     *      - Used code page logic to write the file as an
     *        ASCII file so that when downloaded to a PC it
     *        will be readable ... by wordpad or notepad.
     *        In essence, it will be written as ccsid 819
     *        rather than ccsid 37.
     *
     *      - In spite of the file name "addpalletrequest", this
     *        file will actually only contain totes.  Airversent uses
     *        this file to isolate totes for their POD processing.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Flabel     if   e           k disk
     Flabel94   if   e           k disk    rename(lbrec:lbrec94)
     Foptions   if   e           k disk
     Foptionz   if   e           k disk
HAR AForddm     if   e           k disk
     Fordh      if   e           k disk
     Fordp2     if   e           k disk
     Fpltsum3   if   e           k disk
     Ftotehdr   if   e           k disk
     Fpodlogp   uf a e           k disk
     Fworklb94  if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D recval          s             90    dim(3) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Customer id
     *
      /COPY QCOPYSRC,ID#harbor

     *----------------------------------------------------------------
     *  IFS Prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,c#ifsio_h
     D/copy qcopysrc,errno_h
      /copy qcopysrc,p.bfcdteti

     D chkifsobj       pr                  extpgm('CHKIFSOBJ')
     D  path                        640A   const
     D  authority                    10A   const

     D podsndmsg       pr                  extpgm('PODSNDMSG')
     D  user                         10A   const
     D  message                     512A   const

     D podsendp        pr                  extpgm('PODSENDP')
     D  cmd                           8    const
     D  program                      10    const
     D  whse                          3  0 const
     D  rtid                          5    const
     D  rte                           5    const
     D  stop                          2  0 const
     D  ord                           7  0 const
     D  cord                          7  0 const
     D  fileSend                     30    const
     D  fileRecv                     30    const
     D  fileTry                      33    const
     D  return                       10
     D  msg                          60
     D  plid                          7  0 const
     D  up#                           5  0 const

HAR A*----------------------------------------------------------------
HAR A*  Order detail misc file data structures
HAR A*----------------------------------------------------------------
HAR A
HAR A /copy qcopysrc,orddm1_har
HAR A /copy qcopysrc,orddm2_har
HAR A /copy qcopysrc,orddm3_har
HAR A /copy qcopysrc,orddm4_har
HAR A /copy qcopysrc,orddm5_har

     *----------------------------------------------------------------
     *  *POD1    -  POD options - Part 1
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPPOPT  -  Export to POD (Y,N)
     *    OPPIFS  -  IFS folder
     *    OPPSRV  -  POD HTTP Server
     *    OPPUSR  -  POD HTTP Server User Id
     *    OPPPWD  -  POD HTTP Server Password
     *
     * Data structure
     *
     D opdata1         ds
     D  oppopt                 1      1
     D  opppth                 2     33
     D  oppsrv                34     83
     D  oppusr                84     98
     D  opppwd                99    113
     D  optend1              117    117
     *----------------------------------------------------------------
     *  *POD2    -  POD options - Part 2
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPUSR1  -  Error message user 1
     *    OPUSR2  -  Error message user 2
     *    OPUSR3  -  Error message user 3
     *    OPUSR4  -  Error message user 4
     *    OPUSR5  -  Error message user 5
520bA*    OPUSR6  -  Error message user 6
520bA*    OPUSR7  -  Error message user 7
520bA*    OPUSR8  -  Error message user 8
520bA*    OPUSR9  -  Error message user 9
520bA*    OPUS10  -  Error message user 10
     *
     * Data structure
     *
     D opdata2         ds
     D  opusr1                 1     10
     D  opusr2                11     20
     D  opusr3                21     30
     D  opusr4                31     40
     D  opusr5                41     50
520bAD  opusr6                51     60
520bAD  opusr7                61     70
520bAD  opusr8                71     80
520bAD  opusr9                81     90
520bAD  opus10                91    100
     D  optend2              117    117

     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
     *    OPPBRK  -  Aisle to start new pallet.
     *    OPPBLD  -  Pallet building method.
     *                1 = By stop then slot location.
     *                2 = By slot location then stop.
     *                3 = Descending by stop then location.
     *    OPSELM  -  Selection method.
     *                1 = Single pass (By location).
     *                2 = Multiple pass (By stop).
     *    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
     *    OPNWPL  -  Start new pallet when aisle changes if build method
     *               is 2=Location.
     *    OPFORD  -  Maximum orders per pallet.
     *    OPPTYP  -  Pallet type (P=Pallet, T-Tote).
     *    OPFTOT  -  Maximum totes per pallet
     *    OPTECB  -  External tote cube.
     *    OPTICB  -  Internal tote cube.
     *    OPTSTP  -  Maximum stops per tote.
     *    OPTORD  -  Maximum orders per tote.
     *    OPFPCS  -  Maximum pieces per fixed pallet.
     *
     * Data structure
     *
     D opzdta          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  oppbld                34     34
     D  opselm                35     35
     D  opsplt                36     36
     D  opbmrg                37     37
     D  opnwpl                38     38
     D  opford                39     40  0
     D  opptyp                41     41
     D  opftot                42     43  0
     D  optecb                44     48  2
     D  opticb                49     53  2
     D  optstp                54     55  0
     D  optord                56     57  0
     D  optpcs                58     60  0
     D  opdend               117    117

     *----------------------------------------------------------------
     *  Working variables
     *
     D error           s               n
520aAD errorCtr        s              2  0
     D fd              s             10I 0
     D filnam          s             25
     D hld_label       s              7  0
     D i               s              3  0
     D kycode          s                   like(opzcod)
     D kyzone          s                   like(opzzon)
     D line            s           1024A
     D len             s             10I 0
     D logStatus       s                   like(pdpStatus)
     D logErrCode      s                   like(pdpErrCode)
     D logErrMsg       s                   like(pdpErrMsg)
     D msg2snd         S            512A
     D pathlen         s              3  0
     D purpose         s              2
     D sFileRcv        s             30
     D sFileSnd        s             30
     D sFileTry        s             30
     D sMsg            s             60
     D sReturn         s             10
     D stmfSend        S            256A
     D sv_orpup#       s              5  0
     D url             S            256A
     D value0          s              1  0 inz(0)

     *----------------------------------------------------------------
     *  Date/time variables
     *
     D bfcoffset       s              3  0 inz(0)
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D currtimestamp   s               z
     D datestamp       s               d
     D editdate        c                   '    -  -  '
     D edittime        c                   '  :  :  '
     D micro           s             26
     D micro4          s              4
     D timestamp       s               t   timfmt(*hms:)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     D keyop           ds                  likerec(oprec : *key)
     D keyopz          ds                  likerec(opzrec : *key)
     D keypodp         ds                  likerec(podpRec : *key)

     *----------------------------------------------------------------
     *  Constants
     *
     D forever         c                   const('1')

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
     *      $PRTE   Route
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
520aAC                   parm                    errorCtr          2 0
     *
     * Main line
     *
     *  If client doesn't use totes, get out.

     C                   if        client <> harbor
     C                   goto      bottom
     C                   endif
     *
     C                   exsr      getOptions
     C                   if        error
     C                   goto      bottom
     C                   endif
     *

     *  Loop through all pallets for route.

     C     keyps3        SETLL     pltsum3

     C                   dow       forever = forever
     C     keyps3        reade     pltsum3
     C                   if        %eof
     C                   leave
     C                   endif

     *  Get purpose number, which is truck zone.

     C                   exsr      getPurpose

     *  Loop through totehdr recs and go get corresponding tote item records

     C     keytote_p     setll     totehdr
     C                   dou       forever <> forever
     C     keytote_p     reade     totehdr
     C                   if        %eof(totehdr)
     C                   leave
     C                   endif

     *    Get unique piece# for the TOTE hdr (which is seq 0)

     C     keyMergeLbl   setll     ordp2
     C                   dow       forever = forever
     C     keyMergeLbl   reade     ordp2
     C                   if        %eof(ordp2)
     C                   eval      sv_orpup# = 0
     C                   leave
     C                   endif
     C                   if        orpsq# <> 0
     C                   iter
     C                   endif
     C                   eval      sv_orpup#  = orpup#
     C                   leave
     C                   enddo

     *    Get order header data

     C     keyordh       chain     ordh
     C                   if        not %found
     C                   eval      ohrte  = ' '
     C                   eval      ohord  = 0
     C                   eval      ohcord = 0
     C                   eval      ohstop = 0
     C                   endif
     *
     *    Construct file name using whse, route id, unique piece#
     *    and pallet id

     C                   eval      filnam = 'W'
     C                                +  %TrimL(%editc($pwhse:'X'))
     C                                + 'R'
     C                                + $prtid
     C                                + 'U'
520cDC***                             +  %TrimL(%editc(sv_orpup#:'Z'))
520cMC                                +  %TrimL(%editc(sv_orpup#:'X'))
     C                                + 'P'
     C                                +  %TrimL(%editc(psplid:'Z'))
     *
     C                   eval      sFileSnd = %trimr(filnam) + '.XML'
     C                   eval      sFileRcv = %trimr(filnam) + 'Rtn.XML'
     C                   eval      sFileTry = %trimr(filnam) + 'Rtn1.XML'
     *
     C                   eval      stmfSend = %trimr(url) + sFileSnd
     *
     *  Write initial record to log file.
     *
     C                   eval      logErrCode = 'FILESTART'
     C                   eval      logErrMsg = 'File creation start'
     C                   eval      logStatus = '1'
     C                   exsr      writePODLog
     *
     *  Open the file to write to, get out if error
     *
     c                   eval      fd = open(%trimr(stmfSend):
     c                                  O_TRUNC+O_CREAT+O_WRONLY+
     c                                  O_CODEPAGE:
     c                                  S_IWUSR+S_IRUSR+S_IRGRP+S_IROTH:
     c                                  819)
     c                   if        fd < 0
     C                   eval      logErrCode = 'CRTOPNERR1'
     C                   eval      logErrMsg = 'File create error: '
     C                                     + %str(strerror(errno))
     C                   eval      logStatus = '9'
     C                   exsr      updatePODLog
     C                   goto      bottom
     c                   endif
     *
     *  Close, then re-open the file in text mode.
     *
     C                   callp     close(fd)
     c                   eval      fd = open(%trimr(stmfSend):
     c                                  O_WRONLY+O_TEXTDATA)
     c                   if        fd < 0
     C                   eval      logErrCode = 'CRTOPNERR1'
     C                   eval      logErrMsg = 'File reopen error: '
     C                                     + %str(strerror(errno))
     C                   eval      logStatus = '9'
     C                   exsr      updatePODLog
     C                   goto      bottom
     c                   endif
     *
     *  Write XML version record
     *
     C                   eval      line = %Trim(recval(1))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write AddPalletRequest transaction ID record
     *
     *      Get and format date/time
     C                   time                    currtimestamp
     C                   move      currtimestamp datestamp
     C                   move      currtimestamp timestamp
     C                   move      currtimestamp micro
     C                   eval      micro4 = %subst(micro:20:4)

     C                   eval      line = %Trim(recval(2))
     C                                +  $prtid
520cDC***                             +  %TrimL(%editc(sv_orpup#:'Z'))
520cMC                                +  %TrimL(%editc(sv_orpup#:'X'))
     C                                +  '" timestamp="'
     C                                +  %Trim(%char(datestamp))
     C                                +  'T'
     C                                +  %Trim(%char(timestamp))
     C                                +  %Trim(micro4)
     C                                +  'Z">'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write System Name record
     *
     C                   eval      line = %Trim(recval(3))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write start tag pallet record
     *
     C                   eval      line = '<pallet>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write pallet number record
     *
     C                   eval      line = '<palletNumber>'
520cDC***                             +  %TrimL(%editc(sv_orpup#:'Z'))
520cMC                                +  %TrimL(%editc(sv_orpup#:'X'))
520fAC                                +  %Trim(%char(datestamp))
520fAC                                +  %Trim(%char(timestamp))
520fAC                                +  %Trim(micro4)
     C                                +  '</palletNumber>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write pallet description record
     *
     C                   eval      line = '<description>'
     C                                +  'TOTE'
     C                                +  '</description>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write pallet purpose number record
     *
     C                   eval      line = '<purposeNumber>'
     C                                +  %Trim(purpose)
     C                                +  '</purposeNumber>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write pallet barcode record
     *
     C                   eval      line = '<barcode typeName=" "'
     C                                +  ' typeDescription=" ">'
520cDC***                             +  %TrimL(%editc(sv_orpup#:'Z'))
520cMC                                +  %TrimL(%editc(sv_orpup#:'X'))
     C                                +  '</barcode>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  End of writing header records to XML export file
     *
     *-------------------------------------------------------------------------
     *
     *    Process true tote item records
     *
     C                   if        tohtr# <> tohmt#
     C                   exsr      zzGetTrueTote
     *
     C                   else
     *
HAR A*    For Harbor, process cooler/freezer tote item records
     *
HAR AC                   if        client = harbor
HAR AC                   exsr      zzGetClFzTote
HAR AC                   endif
     *
     C                   endif

     *---------------------------------------------------------------------
     *
     *  Write eof records
     *
     C                   exsr      zzadd1
     *
     *  You're done with this pallet (tote), close its file, send to POD,
     *  and see if there are more.
     *
     C                   callp     close(fd)
     *
     *  Update log record.
     *
     C                   eval      logErrCode = 'FILEEND'
     C                   eval      logErrMsg = 'File creation end'
     C                   eval      logStatus = '2'
     C                   exsr      updatePODLog
     *
520aA*  Try sending xml file to POD server if threshold of 5 errors
     *  has not been reached. However, continue to build XML files
     *  even if threshold is reached, so the user can try resending
     *  them if they wish (using menu PIRPOD, View POD pallet log
     *  option).
     *
520aAC                   if        errorCtr < 5
     C                   exsr      sendPODfile
520aAC                   if        sReturn <> 'OK'
520aAC                   eval      errorCtr = errorCtr + 1
520aAC                   endif
520aAC                   endif
     *
     C                   enddo
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
     * Get client id
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10

HAR A*   Define full key for LABEL94 file
     *
HAR AC     keylab94      klist
HAR AC                   kfld                    $pwhse
HAR AC                   kfld                    $prtid
HAR AC                   kfld                    tohtr#
530 DC**                 kfld                    tohord
530 DC**                 kfld                    ohstop
     *
     *  Define key for PLTSUM3 file.

     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     *  Define partial key for TOTEHDR file.

     C     keytote_p     klist
     C                   kfld                    pswhse
     C                   kfld                    psrtid
     C                   kfld                    psplid
     *
     *  Define key for ORDDM file.
     *
     C     keyorddm      klist
     C                   kfld                    pswhse
     C                   kfld                    lbord
     C                   kfld                    lbseq
     C                   kfld                    lbitem
     *
     *  Define key for ORDH file.
     *
     C     keyordh       klist
     C                   kfld                    pswhse
     C                   kfld                    tohord
     *
     *  Define key for ORDH file using ORDP order#.
     *
     C     keyordh_x     klist
     C                   kfld                    pswhse
     C                   kfld                    orpord
     *
     *  Define partial key for ORDP2 file using merge label number.
     *
     C     keyMergeLbl   klist
     C                   kfld                    tohml#
     *
     *  Define partial key for ORDP2 file using LABEL94 or WORKLB94
     *  label.
     *
     C     keyOrdp2      klist
     C                   kfld                    hld_label
     *
     *   Define full key for WORKLB94 file
     *
     C     keywrk94      klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    tohtr#
530 DC**                 kfld                    tohord
530 DC**                 kfld                    ohstop
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZADD      Write pallet item records
     *
     C     zzadd         begsr
     *
     *  Write start tag pallet item record
     *
     C                   eval      line = '<palletItem>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write order number record
     *
     C                   eval      line = '<orderNumber>'
530  C                                +  %TrimL(%editc(ohcord:'P'))
     C                                +  '</orderNumber>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write line number record
     *
     C                   eval      line = '<lineNumber>'
520cDC***                             +  %TrimL(%editc(orpup#:'P'))
520cMC                                +  %TrimL(%editc(orpup#:'X'))
     C                                +  '</lineNumber>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write quantity record
     *
     C                   eval      line = '<quantity>'
     C                                +  %TrimL(%editc(orpscn:'P'))
     C                                +  '</quantity>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag pallet item record
     *
     C                   eval      line = '</palletItem>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZADD1     Write eof records
     *
     C     zzadd1        begsr
     *
     *  Write end tag pallet record
     *
     C                   eval      line = '</pallet>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag add pallet request record
     *
     C                   eval      line = '</addPalletRequest>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     C                   endsr

     *----------------------------------------------------------------
HAR A*
HAR A*  ZZGetClFzTote   Process cooler/freezer totes
HAR A*
HAR AC     zzGetClFzTote begsr
     *
     *  Loop through label94 recs and write corresponding tote item records
     *
     C     keylab94      setll     label94
     C                   dou       forever <> forever
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
     *  Get unique piece# and write pallet item records
     *
     C                   eval      hld_label = lblbl#
     C                   exsr      zzGetUP#
     *
     C                   enddo
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZGetTrueTote   Process true totes
     *
     C     zzGetTrueTote begsr
     *
     *  Loop through worklb94 recs and write corresponding tote item records
     *
     C     keywrk94      setll     worklb94
     C                   dou       forever <> forever
     C     keywrk94      reade     worklb94
     C                   if        %eof(worklb94)
     C                   leave
     C                   endif
     *
     *  Use merge zone gen records only
     *
520dDC**                 if        lwgen <> 2
520dMC                   if        lwgen < 2
     C                   iter
     C                   endif
     *
     *  Get unique piece# and write pallet item records
     *
     C                   eval      hld_label = lwlbl#
     C                   exsr      zzGetUP#
     *
     C                   enddo
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZGetUP#   Get unique piece#
     *
     C     zzGetUP#      begsr
     *
     *  Loop through ORDP2 recs for this label and write pallet item records
     *  for each unique piece#.
     *
     C     keyOrdp2      SETLL     ordp2

     C                   dow       forever = forever
     C     keyOrdp2      reade     ordp2
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        orpitm = 'TOTE'
520eAC                             or orpscn = 0
     C                   iter
     C                   endif

530 A*    Get customer order number

530 AC     keyordh_x     chain     ordh
530 AC                   if        not %found
530 AC                   eval      ohrte  = ' '
530 AC                   eval      ohord  = 0
530 AC                   eval      ohcord = 0
530 AC                   eval      ohstop = 0
530 AC                   endif

     *  Write pallet item records
     *
     C                   exsr      zzadd
     *
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------

      /free

       //---------------------------------------------------------------
       //  getcurrstamp  Get current timestamps
       //---------------------------------------------------------------

       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;

       //---------------------------------------------------------------
       //  getOption   Get options
       //---------------------------------------------------------------

       begsr getOptions;
         error = *off;

         keyop.opWhse = $pWhse;
         keyop.opCode = '*POD1';

         chain %kds(keyop) options;
         if not %found();
           error = *on;
           eval logErrCode = 'OPTERR';
           eval logErrMsg = 'POD Options not found';
           eval logStatus = '9';
           exsr writePodErr;
           return;
         endif;
         eval opdata1 = opdata;

         // Return if not using POD.

         if oppopt <> 'Y';
           error = *on;
           eval logErrCode = 'OK';
           eval logErrMsg = 'POD option is turned off';
           eval logStatus = '8';
           exsr writePodErr;
           return;
         endif;

         // Ensure path isn't blank

         if opppth = ' ';
           error = *on;
           eval logErrCode = 'NOPATH';
           eval logErrMsg = 'No IFS folder defined';
           eval logStatus = '9';
           exsr writePodErr;
           return;
         endif;

         // Verify IFS folder

         callp(e) chkifsobj (opppth: ' ');
         if %error;
           error = *on;
           eval logErrCode = 'IFSNOTFND';
           eval logErrMsg = 'IFS folder not found';
           eval logStatus = '9';
           exsr writePodErr;
           return;
         endif;

         // Add '/' to end of path if necessary.

         pathLen = %len(%trimr(opppth));
         if %subst(opppth:pathLen:1) <> '/';
            url = %trimr(opppth)+ '/';
         else;
            url = opppth;
         endif;

       endsr;

       //---------------------------------------------------------------
       //  getPurpose  Get purpose number, which is truck zone.
       //---------------------------------------------------------------

       begsr getPurpose;

         purpose = ' ';

         select;
           when pstzon = 'ACOMPC';
             purpose = '12';
           when pstzon = 'ACOMPT';
             purpose = '14';
           when pstzon = 'ACOMPF' or pstzon = 'FRZ';
             purpose = '11';
           when pstzon = 'ZZZZZZ';
             purpose = '16';
           other;
             purpose = '13';
         endsl;

       endsr;

       //---------------------------------------------------------------
       //  sendMsg     Send message to users.
       //---------------------------------------------------------------

       begsr sendMsg;

         // Always send message to QSYSOPR.

         podsndmsg ('QSYSOPR':msg2snd);

         // Now send msg to extra users that have been defined.

         keyop.opWhse = $pWhse;
         keyop.opCode = '*POD2';

         chain %kds(keyop) options;
         if not %found();
           leavesr;
         endif;
         eval opdata2 = opdata;

520bD  //for i = 1 to 5;
520bM    for i = 1 to 10;
           select;
             when i = 1 and opusr1 <> ' ';
               podsndmsg (opusr1:msg2snd);
             when i = 2 and opusr2 <> ' ';
               podsndmsg (opusr2:msg2snd);
             when i = 3 and opusr3 <> ' ';
               podsndmsg (opusr3:msg2snd);
             when i = 4 and opusr4 <> ' ';
               podsndmsg (opusr4:msg2snd);
             when i = 5 and opusr5 <> ' ';
               podsndmsg (opusr5:msg2snd);
520bA        when i = 6 and opusr6 <> ' ';
               podsndmsg (opusr6:msg2snd);
520bA        when i = 7 and opusr7 <> ' ';
               podsndmsg (opusr7:msg2snd);
520bA        when i = 8 and opusr8 <> ' ';
               podsndmsg (opusr8:msg2snd);
520bA        when i = 9 and opusr9 <> ' ';
               podsndmsg (opusr9:msg2snd);
520bA        when i = 10 and opus10 <> ' ';
               podsndmsg (opus10:msg2snd);
           endsl;
         endfor;

       endsr;

       //---------------------------------------------------------------
       //  sendPODfile   Send file to POD server
       //---------------------------------------------------------------

       begsr sendPODfile;

         PODsendP('*SEND' : #pgm  : $pwhse : $prtid : $prte :
                 ohstop  : ohord : ohcord :
                 sFileSnd : sFileRcv : sFileTry :
                 sReturn : sMsg : psplid : sv_orpup#
                );

       endsr;

       //---------------------------------------------------------------
       //  setLogTime    Set appropriate log time fields
       //---------------------------------------------------------------

       begsr setLogTime;

         exsr getCurrStamp;

         select;
           when pdpStatus = '1';
             pdpTS1   = currStampLoc;
             pdpUC1   = currStampUc;
             pdpCall1 = #pgm;
             pdpPgm1  = #pgm;
             pdpUser1 = #user;
             pdpJob1  = #Job;
             pdpNbr1  = #Jobnbr;
           when pdpStatus = '2';
             pdpTS2   = currStampLoc;
             pdpUC2   = currStampUc;
         endsl;

         pdpTS9   = currStampLoc;
         pdpUC9   = currStampUc;

       endsr;

       //---------------------------------------------------------------
       //  updatePODLog   Update log
       //---------------------------------------------------------------

       begsr updatePodLog;

         keypodp.pdpWhse = $pwhse;
         keypodp.pdpRtid = $prtid;
         keypodp.pdpPlid = psplid;
         keypodp.pdpUp#  = sv_orpup#;
         keypodp.pdpTry  = 1;

         chain %kds(keyPodp) podlogp;

         pdpStatus = logStatus;
         pdpErrCode = logErrCode;
         pdpErrMsg  = logErrMsg;

         exsr setLogTime;

         update(e) podpRec;

         if pdpStatus = '9';
           msg2snd = 'Error occured sending RteId/ToteId '
520cD  //          + %trim(ohrte) + '/' + %trim(%editc(sv_orpup#:'Z'))
520cM              + %trim(ohrte) + '/' + %trim(%editc(sv_orpup#:'X'))
                   + ' to POD Server: '
                   + %trim(pdpErrCode) + ' - ' + %trim(pdpErrMsg);
           exsr sendMsg;
         endif;

       endsr;

       //---------------------------------------------------------------
       //  writePodLog   Write log record
       //---------------------------------------------------------------

       begsr writePodLog;

         clear podpRec;

         pdpWhse = $pWhse;
         pdpRtid = $prtid;
         pdpRte  = $pRte;
         pdpPlid = psplid;
         pdpUp#  = sv_orpup#;
         pdpStop = ohstop;
         pdpOrd  = ohord;
         pdpCord = ohcord;
         pdpTry = 1;
         pdpStatus = logStatus;
         pdpFileSnd = sFileSnd;
         pdpFileRcv = sFileRcv;
         pdpFileTry = sFileTry;
         pdpRcvXml  = ' ';
         pdpErrCode = logErrCode;
         pdpErrMsg  = logErrMsg;

         exsr setLogTime;

         write(e) podpRec;

       endsr;

       //---------------------------------------------------------------
       //  writePodErr   Write log error
       //---------------------------------------------------------------

       begsr writePodErr;

         clear podpRec;

         pdpWhse = $pWhse;
         pdpRtid = $pRtid;
         pdpRte  = $pRte;
         pdpPlid  = psplid;
         pdpUp#  = sv_orpup#;
         pdpStatus = logStatus;
         pdpErrCode = logErrCode;
         pdpErrMsg  = logErrMsg;

         exsr setLogTime;

         write(e) podpRec;

         if pdpStatus = '9';
           msg2snd = 'Error occured sending Rte/ToteId '
520cD  //          + %trim($prte) + '/' + %trimL(%editc(sv_orpup#:'Z'))
520cM              + %trim($prte) + '/' + %trimL(%editc(sv_orpup#:'X'))
                   + ' to POD Server: '
                   + %trim(pdpErrCode) + ' - ' + %trim(pdpErrMsg);
           exsr sendMsg;
         endif;

       endsr;

      /end-free

     *
     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,errno_h

     *-------------------------------------------------------------------------
     *  COMPILE TIME TABLES
     *-------------------------------------------------------------------------
**  recval
<?xml version="1.0" encoding="UTF-8" ?>
<addPalletRequest xmlns="http://www.airversent.com/integration" transactionId="
<systemName>HARBOR</systemName>
