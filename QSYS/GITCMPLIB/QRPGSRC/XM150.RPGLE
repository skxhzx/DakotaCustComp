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
     *  XM150     Create IFS text file for tote conveyor.
     *
     *  14 April 2011
     *  Retha Davis
     *
     *  Custom created for Harbor.
     *
     *----------------------------------------------------------------
     *
     *  To compile:
     *
     *    CRTBNDRPG PGM(xxxlib/*CTLSPEC) SRCFILE(xxxlib/QRPGSRC)
     *     SRCMBR(xm150) DBGVIEW(*SOURCE)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    04/14/11  RBD  6.40
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Harbor
     *
HARaA*    04/15/11  RBD  HARa
     *      - Include ship date in text record.
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
     Fworklbl   if   e           k disk
     Fordh      if   e           k disk
     Fordhm     if   e           k disk
     Fordp6     if   e           k disk
     Frtehed    if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Customer id
     *
HARaA /COPY QCOPYSRC,ID#harbor

     *----------------------------------------------------------------
     *  Order Misc field data structures
     *----------------------------------------------------------------

HARaA /copy qcopysrc,ohmisc_har

     *----------------------------------------------------------------
HARaA*  HARBOR header misc file data structures
     *----------------------------------------------------------------

HARaA /copy qcopysrc,ordhm1_har
HARaA /copy qcopysrc,ordhm2_har
HARaA /copy qcopysrc,ordhm3_har
HARaA /copy qcopysrc,ordhm4_har
HARaA /copy qcopysrc,ordhm5_har

     *----------------------------------------------------------------
     *  IFS Prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,c#ifsio_h
     D/copy qcopysrc,errno_h
      /copy qcopysrc,p.bfcdteti

     D chkifsobj       pr                  extpgm('CHKIFSOBJ')
     D  path                        640A   const
     D  authority                    10A   const

     *----------------------------------------------------------------
     *  Working variables
     *
     D bulk            s              1
     D canbrk1         s              1
     D canbrk2         s              1
     D cnvData         s             60
     D directions      s            800
     D error           s               n
     D errorCtr        s              2  0
     D fd              s             10I 0
     D filnam          s             25
     D first           s              1
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
     D hld_rtid2       s              2
     D hld_rtidplt     s              7
     D ix1             s              3  0 inz(0)
     D ix2             s              3  0 inz(0)
     D ItemStr         s            460
     D licpCtr         s              3  0
     D line            s           1024A
     D len             s             10I 0
     D lastStop        s              2  0 inz(0)
     D lastWhdp        s              5
     D miles           s              7  2 inz(0)
     D msg2snd         S            512A
     D NoNameDriver    s              5  0 inz(99999)
     D ordp_cub        s              9  3 inz(0)
     D ordp_wgt        s              9  2 inz(0)
     D ordp_pcs        s              5  0 inz(0)
     D pathlen         s              3  0
     D prg1c           s              4  3
     D prg2c           s              4  3
     D sFileRcv        s             30
     D sFileSnd        s             30
     D sFileTry        s             30
     D sMsg            s             60
     D sReturn         s             10
     D stmfSend        S            256A
     D stpcnt          s              3  0
     * The sv_ fields have been converted and may contain character
     * translations, thus the need for the field sizes to allow extra
     * room for the translations.
     D sv_comp         s             10
     D sv_desc         s            200
     D sv_item         s            100
     D sv_rncode       s             20
     D sv_rndesc       s            200
     D sv_styp         s             10
     D sv_ttfale       s            200
     D sv_ttfchr       s             10
     D sv_ttfico       s            100
     D sv_ttftyp       s            200
     D sv_ucod         s             20
     D sv_um2          s             20
     D sv_um3          s             20
     D sv_upc          s            150
     D sv_whdp         s             50
     D sv_zone         s             50
     D totrtec         s              9  3 inz(0)
     D totrtew         s              9  2 inz(0)
     D totrtep         s              5  0 inz(0)
     D totstpc         s              9  3 inz(0)
     D totstpw         s              9  2 inz(0)
     D totstpp         s              5  0 inz(0)
     D trlrctr         s              3  0
     D url             S            256A

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
     D micro2          s              2
     D timestamp       s               t   timfmt(*hms:)
     D traveltime      s               t   timfmt(*hms:)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------


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
     *
     *    Returned Parameters
     *      $FILNAM          - XML file name.
     *      $PRTN   *OK      - Route was processed.
     *              *CANCEL  - Route was not processed.
     *      $PERM            - Error message.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    sFileSnd
     C                   parm                    $prtn             8
     C                   parm                    $perm            60
     *
     * Main line
     *
     *  Get route header data ... get out if not found
     *
     C     fileky        chain     rtehed
     C                   if        not %found(rtehed)
     C                   eval      $perm = 'Route not found'
     C                   eval      $prtn = '*CANCEL'
     C                   goto      bottom
     C                   endif
     *
     *  Route is good, let's build the file
     *
     C                   eval      $prtn = '*OK     '
     *
     *  Construct file name using whse and route id
     *
     C                   eval      filnam = 'conveyorW'
     C                                +  %TrimL(%editc($pwhse:'X'))
     C                                + 'R'
     C                                + $prtid
     *
     C                   eval      sFileSnd = %trimr(filnam) + '.txt'
     *
     C                   eval      url = 'BFCConveyor/'
     C                   eval      stmfSend = %trimr(url) + sFileSnd
     *
     *  Open the file to write to, get out if error
     *
     c                   eval      fd = open(%trimr(stmfSend):
     c                                  O_TRUNC+O_CREAT+O_WRONLY+
     c                                  O_CODEPAGE:
     c                                  S_IWUSR+S_IRUSR+S_IRGRP+S_IROTH:
     c                                  819)
     c                   if        fd < 0
     C                   eval      $perm = 'File create error: '
     C                                     + %str(strerror(errno))
     C                   eval      $prtn = '*CANCEL'
     C                   goto      bottom
     c                   endif
     *
     *  Close, then re-open the file in text mode
     *
     C                   callp     close(fd)
     c                   eval      fd = open(%trimr(stmfSend):
     c                                  O_WRONLY+O_TEXTDATA)
     c                   if        fd < 0
     C                   eval      $perm = 'File reopen error: '
     C                                     + %str(strerror(errno))
     C                   eval      $prtn = '*CANCEL'
     C                   goto      bottom
     c                   endif
     *
     *  Read through ORDP6 file and write a record for each tote.
     *  A tote is always seq 0, the items inside the tote have
     *  seq numbers greater than 0.
     *
     C     fileky        setll     ordp6
     C                   dou       forevr <> forevr
     C     fileky        reade     ordp6
     C                   if        %eof(ordp6)
     C                              or orpsq# > 0
     C                   leave
     C                   endif
     *
     *  Get work label data.
     *
     c                   exsr      GetWorkLbl
     *
     *  Get ship date.
     *
     c                   exsr      GetOrdhm
     *
     *  Write tote text record.
     *
     C                   eval      cnvdata =
     C                               %trim(%editc($pwhse:'P')) + ','
     C                             + %trim(rhrte) + ','
     C                             + %trim($prtid) + ','
     C                             + %trim(%editc(lwstop:'P')) + ','
     C                             + %trim(lwwhdp) + ','
     C                             + %trim(lwszon) + ','
     C                             + %trim(%editc(orpup#:'P')) + ','
     C                             + %trim(%editc(lwpal#:'P')) + ','
     C                             + %TrimL(%editc(harhm1_shpdt:'X'))
     *
     C                   eval      line = %Trim(cnvdata)
     c                   eval      len = %len(%trimr(line))
     c                   callp     writeline(fd: %addr(line): len)
     *
     C                   enddo
     *
     *---------------------------------------------------------------------
     *
     *  Finish up
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
     C                   eval      first = *on
     *
     *   Get client id
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *   Define key for RTEHED and LABEL files
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     *   Define key for ORDHM file
     *
     C     keyOrdhm      klist
     C                   kfld                    $pwhse
     C                   kfld                    lword
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GetWorkLbl   Get work label data.
     *
     C     getWorkLbl    begsr

     C     orplbl        chain     worklbl
     C                   if        not %found(worklbl)
     C                   eval      lword  = 0
     C                   eval      lwstop = 0
     C                   eval      lwwhdp = *blanks
     C                   eval      lwszon = *blanks
     C                   eval      lwpal# = 0
     C                   endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  GetOrdhm   Get order header miscellaneous data
     *
     C     getOrdhm      begsr

     C     keyOrdhm      chain     ordhm
     C                   if        not %found(ordhm)
     C                   eval      hmmsc1 = *blanks
     C                   eval      hmmsc2 = *blanks
     C                   eval      hmmsc3 = *blanks
     C                   eval      hmmsc4 = *blanks
     C                   eval      hmmsc5 = *blanks
     C                   endif
     *
     C                   select
     *
HARaAC                   when      client = 'HARBOR    '
HARaAC                   eval      harhm1_base = hmmsc1
HARaAC                   eval      harhm2_base = hmmsc2
HARaAC                   eval      harhm3_base = hmmsc3
HARaAC                   eval      harhm4_base = hmmsc4
HARaAC                   eval      harhm5_base = hmmsc5
     *
     C                   endsl
     *
     C                   endsr

     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,errno_h

     *-------------------------------------------------------------------------
     *  COMPILE TIME TABLES
     *-------------------------------------------------------------------------
