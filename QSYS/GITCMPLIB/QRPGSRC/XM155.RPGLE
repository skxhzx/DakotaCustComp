      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  XM155     Create XML/IFS Add Order Request export file
     *            Cloned from RH155 and ifsebook/ch5text
     *
     *  15 November 2007
     *  Retha Davis
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *
     *  To compile:
     *
     *    CRTBNDRPG PGM(xxxlib/*CTLSPEC) SRCFILE(xxxlib/QRPGSRC)
     *     SRCMBR(xm155) DBGVIEW(*SOURCE)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    11/15/07  RBD  5.20  P#00004
     *      - Created for Harbor.
520aA*    06/02/09  RBD  5.20a  P#00213
     *      - Added logic to abort send attempt once 5 errors
     *        have occurred.
520bA*    06/03/09  RBD  5.20b  P#00212
     *      - Enh: Added 5 more POD error message recipients.
520cA*    06/11/09  RBD  5.20c  P#00214
     *      - Enh: Added logic to only build xml files if new flag
     *        passed in imported order header files = Y.
520dA*    06/16/09  RBD  5.20d  P#00215
     *      - Per T Caulfield, added output of stop to Group Number
     *        element, even though it's already being written in
     *        other elements.
520eA*    06/25/09  RBD  5.20e
     *      - Do not zero suppress POD# written to xml file.
520fA*    08/26/09  RBD  5.20f
     *      - Fix: Do not add ORDP rec to xml file if scan qty = 0.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Harbor
     *
HAR A*    08/20/08  RBD  HAR   P#00004
     *      - Retrieve upc code from ORDDM/OMMSC1/hardm1_mfgcd and
     *        hardm1_item.
     *
HARaA*    02/10/09  RBD  HARa  P#00004
     *      - For CLR/FRZ totes, added new routine zzaddClrFrz to
     *        write a detail record for each of the totes needed per
     *        order and stop in the CLR/FRZ zone.  Each of these
     *        totes is assigned a unique piece# in ORDP.  A detail
     *        rec will not be written however for the first tote of
     *        the series, as it is used to create a record in the
     *        addpalletrequest file.
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
     *----------------------------------------------------------------
     * Indicators
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Flabel93   if   e           k disk
     Foptions   if   e           k disk
     Fordd      if   e           k disk
HAR AForddm     if   e           k disk
     Fordhm     if   e           k disk
     Fordh9     if   e           k disk
     Fordp1     if   e           k disk
HARaAFordp2     if   e           k disk    rename(orprec:orprec2)
HARaAF                                     prefix(o_)
     Fpiritem   if   e           k disk
     Fpodlog    uf a e           k disk
     Funmesr    if   e           k disk
     Fwarehsad  if   e           k disk
     Fworklbl   if   e           k disk

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

     D podsend         pr                  extpgm('PODSEND')
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
     *  Order Misc field data structures
     *----------------------------------------------------------------

      /copy qcopysrc,ohmisc_har

     *----------------------------------------------------------------
     *  HARBOR header misc file data structures
     *----------------------------------------------------------------

      /copy qcopysrc,ordhm1_har
      /copy qcopysrc,ordhm2_har
      /copy qcopysrc,ordhm3_har
      /copy qcopysrc,ordhm4_har
      /copy qcopysrc,ordhm5_har

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
     *  Working variables
     *
     D error           s               n
520aAD errorCtr        s              2  0
     D false           s              5    inz('false')
     D fd              s             10I 0
     D filnam          s             25
HARaAD FirstClrFrz     s               n
     D i               s              3  0
HAR AD hld_upc         s             16
     D line            s           1024A
     D len             s             10I 0
     D logStatus       s                   like(podStatus)
     D logErrCode      s                   like(podErrCode)
     D logErrMsg       s                   like(podErrMsg)
     D msg2snd         S            512A
     D pathlen         s              3  0
     D propname        s             60
     D propvalu        s             60
     D purpose         s              2
     D SameStop        s               n
     D sFileRcv        s             30
     D sFileSnd        s             30
     D sFileTry        s             30
     D sMsg            s             60
     D sReturn         s             10
     D stmfSend        S            256A
     D sv_lbucod       s              2
     D true            s              4    inz('true')
     D truefalse       s              5
     D url             S            256A
     D value0          s              1  0 inz(0)
     D value1          s              1  0 inz(1)

     *----------------------------------------------------------------
     *  Date/time variables
     *
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
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     D keyop           ds                  likerec(oprec : *key)
     D keypod          ds                  likerec(podrec : *key)

     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')

     *----------------------------------------------------------------
     *
     * Data structure
     *

     *----------------------------------------------------------------
     *  CVTTEXT Parameters

     D $cmd            s             10
     D $in             s            500
     D $out            s            500

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
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
     C                   parm                    $prtn             8
     *
     * Main line
     *
     C                   exsr      getOptions
     C                   if        error
     C                   goto      bottom
     C                   endif
     *
     *  Get order header record
     *
     C     keyoh_p       setll     ordh9
     C                   dou       forevr <> forevr
     C     keyoh_p       reade     ordh9
     *
     C                   if        %eof(ordh9)
     C                   leave
     C                   endif
     *
520cA*  Do not build xml files unless 'create POD files' flag = Y.
     *
520cAC                   eval      harmsc_base = ohmisc
520cAC                   if        harmsc_POD <> 'Y'
520cAC                   goto      bottom
520cAC                   endif
     *
     *  Initialize return code to *CANCEL. If file opens successfully,
     *    will change to *OK.
     *
     C                   eval      $prtn = '*CANCEL'
     *
     *  Construct file name using whse, route id, Dakota ord number,
     *  and stop
     *
     C                   eval      filnam = 'W'
     C                                +  %TrimL(%editc($pwhse:'X'))
     C                                + 'R'
     C                                + $prtid
     C                                + 'O'
     C                                +  %TrimL(%editc(ohord:'X'))
     C                                + 'S'
     C                                +  %TrimL(%editc(ohstop:'X'))
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
     C                   eval      $prtn = '*OK    '
     *
     *  Get order header miscellaneous record
     *
     C                   eval      hmmsc1 = *blanks
     C                   eval      hmmsc2 = *blanks
     C                   eval      hmmsc3 = *blanks
     C                   eval      hmmsc4 = *blanks
     C                   eval      hmmsc5 = *blanks
     C     keyhm         chain     ordhm
     *
     C                   if        not %found
     C                   reset                   harhm1_base
     C                   reset                   harhm2_base
     C                   reset                   harhm3_base
     C                   reset                   harhm4_base
     C                   reset                   harhm5_base
     C                   else
     C                   eval      harhm1_base = hmmsc1
     C                   eval      harhm2_base = hmmsc2
     C                   eval      harhm3_base = hmmsc3
     C                   eval      harhm4_base = hmmsc4
     C                   eval      harhm5_base = hmmsc5
     C                   endif
     *
     *  Write XML version record
     *
     C                   eval      line = %Trim(recval(1))
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *
     *  Write Add Order and Customer Request transaction ID record
     *
     *      Get and format date/time
     C                   time                    currtimestamp
     C                   move      currtimestamp datestamp
     C                   move      currtimestamp timestamp
     C                   move      currtimestamp micro
     C                   eval      micro4 = %subst(micro:20:4)

     C                   eval      line = %Trim(recval(2))
     C                                +  %TrimL(%editc(ohcord:'P'))
     C                                +  %TrimL(%editc(ohstop:'X'))
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
     *  Write start tag Customer record
     *
     C                   eval      line = '<customer>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Customer Number record
     *
     C                   eval      line = '<customerNumber>'
     C                                +  %TrimL(%editc(ohcust:'P'))
     C                                +  '</customerNumber>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Customer Name record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ohcnam        $in
     C                   parm      *blanks       $out
     C                   eval      line = '<customerName>'
     C                                +  %Trim($out)
     C                                +  '</customerName>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Customer record
     *
     C                   eval      line = '</customer>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write start tag Customer Address record
     *
     C                   eval      line = '<customerAddress>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write customer Address Line 1 record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ohcad1        $in
     C                   parm      *blanks       $out
     C                   eval      line = '<addressLine1>'
     C                                +  %Trim($out)
     C                                +  '</addressLine1>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write customer City record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ohccty        $in
     C                   parm      *blanks       $out
     C                   eval      line = '<city>'
     C                                +  %Trim($out)
     C                                +  '</city>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write customer State record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ohcst         $in
     C                   parm      *blanks       $out
     C                   eval      line = '<state>'
     C                                +  %Trim($out)
     C                                +  '</state>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write customer Zip Code record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ohczip        $in
     C                   parm      *blanks       $out
     C                   eval      line = '<zipCode>'
     C                                +  %Trim($out)
     C                                +  '</zipCode>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write customer Country record
     *
     C                   eval      line = '<country>'
     C                                +  'USA'
     C                                +  '</country>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Customer Address record
     *
     C                   eval      line = '</customerAddress>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write start tag Contact record
     *
     C                   eval      line = '<contact>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Contact First Name record
     *
     C                   eval      line = '<firstName>'
     C                                +  'X'
     C                                +  '</firstName>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Contact Last Name record
     *
     C                   eval      line = '<lastName>'
     C                                +  'X'
     C                                +  '</lastName>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Contact record
     *
     C                   eval      line = '</contact>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Center Number record
     *
     C     keywhs        chain     warehsad
     C                   if        not %found(warehsad)
     C                   eval      whacty = *blanks
     C                   endif
     *
     C                   eval      line = '<centerNumber>'
     C                                +  %Trim(whacty)
     C                                +  '</centerNumber>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Route Number record
     *
     C                   eval      line = '<routeNumber>'
     C                                +  %Trim($prte)
     C                                +  '</routeNumber>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write start tag Orders record
     *
     C                   eval      line = '<orders>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
520dA*  Write Group Number, populated with stop number
     *
520dAC                   eval      line = '<groupNumber>'
520dAC                                +  %TrimL(%editc(ohstop:'P'))
520dAC                                +  '</groupNumber>'
520dAC                   eval      len = %len(%trimr(line))
520dAC                   callp     writeline(fd: %addr(line): len)
     *
     *  Write start tag Order record
     *
     C                   eval      line = '<order>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Order Number record
     *
     C                   eval      line = '<orderNumber>'
     C                                +  %TrimL(%editc(ohcord:'P'))
     C                                +  '</orderNumber>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Order Date record
     *
     C                   move      ohsdte        editdate
     C                   move      ohstim        edittime
     C                   eval      line = '<orderDate>'
     C                                +  %Trim(%char(editdate))
     C                                +  'T'
     C                                +  %Trim(%char(edittime))
     C                                +  '.000Z'
     C                                +  '</orderDate>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write PO Number record. It must be non-blank, even though Airversent's
     *  documentation defines it as being optional.  If left blank, the file
     *  will not transmit to POD, and will end with an HTTP syntax error.
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      ohcpo         $in
     C                   parm      *blanks       $out
     C                   if        $out = *blanks
     C                   eval      $out = 'X'
     C                   endif
     C                   eval      line = '<poNumber>'
     C                                +  %Trim($out)
     C                                +  '</poNumber>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Service Window Start record
     *
     C                   eval      line = '<serviceWindowStart>'
     C                                +  %Trim(%char(datestamp))
     C                                +  'T'
     C                                +  %Trim(%char(timestamp))
     C                                +  %Trim(micro4)
     C                                +  'Z</serviceWindowStart>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Service Window End record
     *
     C                   eval      line = '<serviceWindowEnd>'
     C                                +  %Trim(%char(datestamp))
     C                                +  'T'
     C                                +  %Trim(%char(timestamp))
     C                                +  %Trim(micro4)
     C                                +  'Z</serviceWindowEnd>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Expected Service Sequence record
     *
     C                   eval      line = '<expectedServiceSequence>'
     C                                +  %TrimL(%editc(ohstop:'P'))
     C                                +  '</expectedServiceSequence>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Expected Payment record
     *
     C                   eval      line = '<expectedPayment>'
     C                                +  %TrimL(%editc(value0:'P'))
     C                                +  '</expectedPayment>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Signature Required record
     *
     C                   if        harhm2_signat = '1'
     C                   eval      truefalse = 'true '
     C                   else
     C                   eval      truefalse = 'false'
     C                   endif
     C                   eval      line = '<signatureRequired>'
     C                                +  %Trim(truefalse)
     C                                +  '</signatureRequired>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Backorder record
     *
     C                   eval      line = '<backOrder>'
     C                                +  %Trim(false)
     C                                +  '</backOrder>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Alert record
     *
     C                   eval      line = '<alert>'
     C                                +  ' '
     C                                +  '</alert>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Accept All record
     *
     C                   eval      line = '<acceptAll>'
     C                                +  %Trim(false)
     C                                +  '</acceptAll>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Service Instructions record
     *
     C                   eval      line = '<serviceInstructions>'
     C                                +  ' '
     C                                +  '</serviceInstructions>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Send Wireless record
     *
     C                   eval      line = '<sendWireless>'
     C                                +  %Trim(true)
     C                                +  '</sendWireless>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Scheduled Empty record
     *
     C                   eval      line = '<scheduledEmpty>'
     C                                +  %Trim(false)
     C                                +  '</scheduledEmpty>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Expected Item Quantity record
     *
     C                   eval      line = '<expectedItemQuantity>'
     C                                +  %TrimL(%editc(value0:'P'))
     C                                +  '</expectedItemQuantity>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Property Name record
     *
     C                   eval      propname = 'Route ID'
     C                   eval      propvalu = $prtid
     C                   eval      line = '<property name="'
     C                                +  %Trim(propname)
     C                                +  '" dataType="string"'
     C                                +  ' description="X"'
     C                                +  '>'
     C                                +  %Trim(propvalu)
     C                                +  '</property>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  End of writing header records to XML export file
     *
     *-------------------------------------------------------------------------
     *
     *  Loop through order detail recs and write XML export
     *  detail records
     *
     C     keyod         setll     ordd
     C                   dou       forevr <> forevr
     C     keyod         reade     ordd
     C                   if        %eof(ordd)
     C                   leave
     C                   endif
     *
     *  Get order item data
     *
     C                   exsr      zzgetord
     *
     *  Check for same stop
     *
     C                   if        SameStop = '0'
     C                   iter
     C                   endif
     *
     *  Get item master data
     *
     C                   exsr      zzgetit
     *
     *  Write XML export detail records for each unique piece#.
     *  For example, line item 1, qty 8, item XYZ, could have 8
     *  unique piece#'s.  If it's a bulk item or has met the combo
     *  label qty, there will only be 1 unique piece# for the item.
     *  Also note that the line number output in the orderItem line
     *  number record is the unique piece#, not the item line number,
     *  because the POD system requires the line number be unique.
     *
     C     keyordp1      setll     ordp1
     C                   dou       forevr <> forevr
     C     keyordp1      reade     ordp1
     C                   select
     C                   when      %eof(ordp1)
     C                   leave
520fAC                   when      orpscn = 0
520fAC                   iter
     C                   other
     C                   exsr      zzadd
     C                   endsl
     C                   enddo
     *
     C                   enddo
     *
     *---------------------------------------------------------------------
     *
     *  Write eof records
     *
     C                   exsr      zzaddEOF
     *
     *  You're done with this ord/stop, close its file, send to POD,
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
     *  them if they wish (using menu PIRPOD, View POD log option).
     *
520aAC                   if        errorCtr < 5
     C                   exsr      sendPODfile
520aAC                   if        sReturn <> 'OK'
520aAC                   eval      errorCtr = errorCtr + 1
520aAC                   endif
520aAC                   endif
     *
     C     keyoh         setgt     ordh9
     *
     C                   enddo
     *
     *  Call pgm to create and send AddPalletRequest files to POD
     *  server.  One AddPalletRequest file will be created and sent
     *  for each tote.
     *
     c                   call      'XM156'
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    $prte
520aAC                   parm                    errorCtr
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
     *
     *   Define full key for LABEL93
     *
     C     keylb93       klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord
     C                   kfld                    oditem
     C                   kfld                    odseq
     *
     *   Define partial key for ORDD file
     *
     C     keyod         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord
     *
HAR A*   Define full key for ORDDM file
     *
     C     keyorddm      klist
     C                   kfld                    $pwhse
     C                   kfld                    ohord
     C                   kfld                    odseq
     C                   kfld                    oditem
     *
     *   Define full key for ORDHM file.
     *
     C     keyhm         klist
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
     *   Define partial key for ORDP1 file
     *
     C     keyordp1      klist
     C                   kfld                    odwhse
     C                   kfld                    odord
     C                   kfld                    odseq
     C                   kfld                    oditem
     *
HARaA*   Define partial key for ORDP2 file
     *
HARaAC     keyordp2      klist
HARaAC                   kfld                    lblbl#
     *
     *   Define full key for PIRITEM file
     *
     C     keyit         klist
     C                   kfld                    odwhse
     C                   kfld                    oditem
     *
     *   Define full key for WAREHSAD
     *
     C     keywhs        klist
     C                   kfld                    ohwhse
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZADD      Write XML export detail records
     *
     C     zzadd         begsr
     *
     *  Write Order Item Type Name record
     *
     C                   eval      line = '<orderItem typeName="item"'
     C                                +  ' typeDescription=" "'
     C                                +  ' purposeNumber="'
     C                                +  %Trim(purpose)
     C                                +  '">'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Line Number record
     *
     C                   eval      line = '<lineNumber>'
520eDC****                            +  %TrimL(%editc(orpup#:'P'))
520eMC                                +  %TrimL(%editc(orpup#:'X'))
     C                                +  '</lineNumber>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write start tag Identification record
     *
     C                   eval      line = '<identification>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Identification Name record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      oditem        $in
     C                   parm      *blanks       $out
     C                   eval      line = '<name>'
     C                                +  %Trim($out)
     C                                +  '</name>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Identification Description record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      itdesc        $in
     C                   parm      *blanks       $out
     C                   eval      line = '<description>'
     C                                +  %Trim($out)
     C                                +  '</description>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Unit of Measure record
     *
     C                   eval      line = '<unitOfMeasure>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Unit of Measure Abbreviation record
     *
     C                   eval      line = '<abbreviation>'
     C                                +  %Trim(sv_lbucod)
     C                                +  '</abbreviation>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Unit of Measure Description record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      umdesc        $in
     C                   parm      *blanks       $out
     C                   eval      line = '<description>'
     C                                +  %Trim($out)
     C                                +  '</description>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Unit of Measure record
     *
     C                   eval      line = '</unitOfMeasure>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Identification record
     *
     C                   eval      line = '</identification>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Ordered Quantity record
     *
     C                   eval      line = '<orderedQuantity>'
     C                                +  %TrimL(%editc(odqor1:'P'))
     C                                +  '</orderedQuantity>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Fulfilled Quantity record
     *
     C                   eval      line = '<fulfilledQuantity>'
     C                                +  %TrimL(%editc(value0:'P'))
     C                                +  '</fulfilledQuantity>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Service Quantity record
     *
     C                   eval      line = '<serviceQuantity>'
     C                                +  %TrimL(%editc(orpscn:'P'))
     C                                +  '</serviceQuantity>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Note record
     *
     C                   eval      line = '<note>'
     C                                +  ' '
     C                                +  '</note>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Barcode record
     *
     c                   call      'CVTTEXT'
     C                   parm      '*XML      '  $cmd
     C                   parm      hld_upc       $in
     C                   parm      *blanks       $out
     C                   if        $out = *blanks
     C                   eval      $out = 'X'
     C                   endif
     C                   eval      line = '<barcode>'
     C                                +  %Trim($out)
     C                                +  '</barcode>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Order Item record
     *
     C                   eval      line = '</orderItem>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     C                   endsr

     *----------------------------------------------------------------
     *
HARaA*  ZZADDCLRFRZ  Write CLR/FRZ tote records for this label record,
HARaA*  if any.  Skip the first one, as it will be used to create an
HARaA*  addpalletrequest file.
     *
HARaAC     zzaddClrFrz   begsr
     *
     C                   eval      firstClrFrz = '1'
     *
     C     keyordp2      setll     ordp2
     C                   dow       forevr = forevr
     C     keyordp2      reade     ordp2
     *
     C                   if        %eof(ordp2)
     C                   leave
     C                   endif
     *
     C                   if        o_orpsq# <> 0
     C                   iter
     C                   endif
     *
     C                   if        firstClrFrz = '1'
     C                   eval      firstClrFrz = '0'
     C                   iter
     C                   endif
     *
     *  Write Order Item Type Name record
     *
     C                   eval      line = '<orderItem typeName="TOTE"'
     C                                +  ' typeDescription=" "'
     C                                +  ' purposeNumber="'
     C                                +  %Trim(purpose)
     C                                +  '">'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Line Number record
     *
     C                   eval      line = '<lineNumber>'
520eDC****                            +  %TrimL(%editc(o_orpup#:'P'))
520eMC                                +  %TrimL(%editc(o_orpup#:'X'))
     C                                +  '</lineNumber>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write start tag Identification record
     *
     C                   eval      line = '<identification>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Identification Name record
     *
     C                   eval      line = '<name>'
     C                                +  'TOTE'
     C                                +  '</name>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Identification Description record
     *
     C                   eval      line = '<description>'
     C                                +  'TOTE'
     C                                +  '</description>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Unit of Measure record
     *
     C                   eval      line = '<unitOfMeasure>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Unit of Measure Abbreviation record
     *
     C                   eval      line = '<abbreviation>'
     C                                +  'x'
     C                                +  '</abbreviation>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Unit of Measure Description record
     *
     C                   eval      line = '<description>'
     C                                +  'x'
     C                                +  '</description>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Unit of Measure record
     *
     C                   eval      line = '</unitOfMeasure>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Identification record
     *
     C                   eval      line = '</identification>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Ordered Quantity record
     *
     C                   eval      line = '<orderedQuantity>'
     C                                +  %TrimL(%editc(value1:'P'))
     C                                +  '</orderedQuantity>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Fulfilled Quantity record
     *
     C                   eval      line = '<fulfilledQuantity>'
     C                                +  %TrimL(%editc(value0:'P'))
     C                                +  '</fulfilledQuantity>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Service Quantity record
     *
     C                   eval      line = '<serviceQuantity>'
     C                                +  %TrimL(%editc(value1:'P'))
     C                                +  '</serviceQuantity>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write Note record
     *
     C                   eval      line = '<note>'
     C                                +  ' '
     C                                +  '</note>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Order Item record
     *
     C                   eval      line = '</orderItem>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     C                   enddo
     *
HARaAC                   endsr

     *----------------------------------------------------------------
     *
     *  ZZADDEOF   Write eof records
     *
     C     zzaddEOF      begsr
     *
     *  Write end tag Order record
     *
     C                   eval      line = '</order>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag Orders record
     *
     C                   eval      line = '</orders>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     *  Write end tag for Add Order and Customer Request record
     *
     C                   eval      line = '</addOrderAndCustomerRequest>'
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZGETIT    Get item master data
     *
     C     zzgetit       begsr
     *
     C     keyit         chain     piritem
     C                   if        not %found(piritem)
     C                   eval      itdesc = *blanks
     C                   eval      itupc  = *blanks
     C                   endif
     C                   eval      hld_upc = itupc
     *
HAR A*  Get 'mfg item' in lieu of itupc
HAR AC                   if        client = harbor
     *
HAR AC     keyorddm      chain     orddm
HAR AC                   if        not %found(orddm)
HAR AC                   eval      hld_upc = *blanks
HAR AC                   else
HAR AC                   eval      hardm1_base = ommsc1
HAR AC                   eval      hld_upc = %trim(hardm1_mfgcd)
HAR AC                                     + %trim(hardm1_item)
HAR AC                   endif
HAR AC                   endif
     *
     C                   endsr

     *-------------------------------------------------------------------------
     *
     *  ZZGETORD   Set stop flag.  If same stop as ORDH, get order item data.
     *
     C     zzgetord      begsr
     *
     *  Clear save fields
     *
     C                   eval      SameStop  = '0'
     C                   eval      sv_lbucod = *blanks
     C                   eval      umdesc    = *blanks
     C                   eval      purpose   = *blanks
     *
     C     keylb93       setll     label93
     C                   dow       forevr = forevr
     C     keylb93       reade     label93
     *
     C                   if        %eof(label93)
     C                             or lbstop <> ohstop
     C                   leave
     C                   endif
     *
     C                   if        lbtype <> 'O'  and
     C                             lbtype <> 'B'
     C                   iter
     C                   endif
     *
     *  Save u/m code, sum quantity picked.
     *
     C                   eval      SameStop  = '1'
     C                   eval      sv_lbucod = lbucod
     *
     *  Get truck zone to determine purpose number
     *
     C     lblbl#        chain     worklbl
     C                   if        %found(worklbl)
     C                   select

     C                   when      lwtzon = 'ACOMPC'
     C                   eval      purpose = '12'

     C                   when      lwtzon = 'ACOMPT'
     C                   eval      purpose = '14'

     C                   when      lwtzon = 'ACOMPF' or
     C                             lwtzon = 'FRZ'
     C                   eval      purpose = '11'

     C                   when      lwtzon = 'ZZZZZZ'
     C                   eval      purpose = '16'

     C                   other
     C                   eval      purpose = '13'

     C                   endsl
     C                   endif
     *
HARaA*  Go get and write CLR/FRZ totes for this label, if any.
HARaAC                   if        client = harbor
HARaAC                   exsr      zzaddClrFrz
HARaAC                   endif
     *
     C                   enddo

     C     sv_lbucod     chain     unmesr
     *
     C                   endsr

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

         PODsend('*SEND' : #pgm  : ohwhse : ohrte : $prte :
                 ohstop  : ohord : ohcord :
                 sFileSnd : sFileRcv : sFileTry :
                 sReturn : sMsg
                );

       endsr;

       //---------------------------------------------------------------
       //  setLogTime    Set appropriate log time fields
       //---------------------------------------------------------------

       begsr setLogTime;

         exsr getCurrStamp;

         select;
           when podStatus = '1';
             podTS1   = currStampLoc;
             podUC1   = currStampUc;
             podCall1 = #pgm;
             podPgm1  = #pgm;
             podUser1 = #user;
             podJob1  = #Job;
             podNbr1  = #Jobnbr;
           when podStatus = '2';
             podTS2   = currStampLoc;
             podUC2   = currStampUc;
         endsl;

         podTS9   = currStampLoc;
         podUC9   = currStampUc;

       endsr;

       //---------------------------------------------------------------
       //  updatePODLog   Update log
       //---------------------------------------------------------------

       begsr updatePodLog;

         keypod.podWhse = ohwhse;
         keypod.podRtid = ohrte;
         keypod.podStop = ohstop;
         keypod.podOrd  = ohord;
         keypod.podTry  = 1;

         chain %kds(keyPod) podlog;

         podStatus = logStatus;
         podErrCode = logErrCode;
         podErrMsg  = logErrMsg;

         exsr setLogTime;

         update(e) podrec;

         if podStatus = '9';
           msg2snd = 'Error occured sending RteId/OrdId '
                   + %trim(ohrte) + '/' + %trim(%editc(ohord:'Z'))
                   + ' to POD Server: '
                   + %trim(podErrCode) + ' - ' + %trim(podErrMsg);
           exsr sendMsg;
         endif;

       endsr;

       //---------------------------------------------------------------
       //  writePodLog   Write log record
       //---------------------------------------------------------------

       begsr writePodLog;

         clear podRec;

         podWhse = ohWhse;
         podRtid = ohrte;
         podRte  = $pRte;
         podStop = ohstop;
         podOrd  = ohord;
         podCord = ohcord;
         podTry = 1;
         podStatus = logStatus;
         podFileSnd = sFileSnd;
         podFileRcv = sFileRcv;
         podFileTry = sFileTry;
         podRcvXml  = ' ';
         podErrCode = logErrCode;
         podErrMsg  = logErrMsg;

         exsr setLogTime;

         write(e) podrec;

       endsr;

       //---------------------------------------------------------------
       //  writePodErr   Write log error
       //---------------------------------------------------------------

       begsr writePodErr;

         clear podRec;

         podWhse = $pWhse;
         podRtid = $pRtid;
         podRte  = $pRte;
         podStatus = logStatus;
         podErrCode = logErrCode;
         podErrMsg  = logErrMsg;

         exsr setLogTime;

         write(e) podrec;

         if podStatus = '9';
           msg2snd = 'Error occured sending Rte/RteId '
                   + %trim($prte) + '/' + %trim($prte)
                   + ' to POD Server: '
                   + %trim(podErrCode) + ' - ' + %trim(podErrMsg);
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
<addOrderAndCustomerRequest xmlns="http://www.airversent.com/integration" transa
<systemName>HARBOR</systemName>
