      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   24 Washington Ave North #203
     *   Batavia IL  60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR810     Create ROUTE, STOP, ITEM_LABEL, and SUMMARY
     *            Tracker data base files.
     *
     *  16 December 2009
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *
     *  To compile:
     *
     *    CRTBNDRPG PGM(xxxlib/*CTLSPEC) SRCFILE(xxxlib/QRPGSRC)
     *     SRCMBR(tr810db) DBGVIEW(*SOURCE)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    12/16/09  RBD  5.30
     *      - Created.
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
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
     fitem_labelo    e           k disk
     Flabel     if   e           k disk
     Foptions   if   e           k disk
     Fordh9     if   e           k disk
     Fordp1     if   e           k disk
     Fpiritem   if   e           k disk
     Fpltsum4p  if   e           k disk
     Fpodlog    uf a e           k disk
     froute     o    e           k disk
     Frtehed    if   e           k disk
     Frtesum    if   e           k disk
     fstop      uf a e           k disk
     fsummary   uf a e           k disk
     Ftotehdr1  if   e           k disk
     Fworklbl   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

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
     *    OPUSR6  -  Error message user 6
     *    OPUSR7  -  Error message user 7
     *    OPUSR8  -  Error message user 8
     *    OPUSR9  -  Error message user 9
     *    OPUS10  -  Error message user 10
     *
     * Data structure
     *
     D opdata2         ds
     D  opusr1                 1     10
     D  opusr2                11     20
     D  opusr3                21     30
     D  opusr4                31     40
     D  opusr5                41     50
     D  opusr6                51     60
     D  opusr7                61     70
     D  opusr8                71     80
     D  opusr9                81     90
     D  opus10                91    100
     D  optend2              117    117

     *----------------------------------------------------------------
     *  Order Misc field data structures
     *----------------------------------------------------------------

      /copy qcopysrc,ohmisc_har

     *----------------------------------------------------------------
     *  Working variables
     *
     D error           s               n
     D errorCtr        s              2  0
     D false           s              5    inz('false')
     D fd              s             10I 0
     D filnam          s             25
     D i               s              3  0
     D licpCtr         s              3  0
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
     D totrtec         s              9  3 inz(0)
     D totrtew         s              9  2 inz(0)
     D totrtep         s              5  0 inz(0)
     D trlrctr         s              3  0
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
     *
     *    Returned Parameters
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
     C                   parm                    $prtn             8
     C                   parm                    $perm            60
     *
     * Main line
     *
     *  Get route header data ... get out if not found
     *
     C     keyoh_p       chain     rtehed
     C                   if        not %found(rtehed)
     C                   goto      bottom
     C                   endif
     c                   eval      tdrwhse = $pwhse
     c                   eval      tdrrte  = rhrte
     c                   eval      tdrrtid = $prtid
     c                   eval      tdrlicp = 'LICPLx'
     c                   eval      tdrtruk = rhtruk
     c                   eval      tdremp  = 999
     *
     C                   eval      $prtn = '*OK    '
     *
     *  Get order header data and write STOP record
     *
     C     keyoh_p       setll     ordh9
     C                   dou       forevr <> forevr
     C     keyoh_p       reade     ordh9
     C                   if        %eof(ordh9)
     C                   leave
     C                   endif
     c     keystop       chain     stop
     c                   if        not %found(stop)
     c                   eval      tdpwhse = $pwhse
     c                   eval      tdprtid = $prtid
     c                   eval      tdpstop = ohstop
     c                   eval      tdpcusn = ohcnam
     c                   eval      tdpcmpn = ohcnam
     c                   eval      tdpadd1 = ohcad1
     c                   eval      tdpadd2 = ohcad2
     c                   eval      tdpcity = ohccty
     c                   eval      tdpstate = ohcst
     c                   eval      tdpzip  = ohczip
     c                   eval      tdpcon1 = 'Contact first name'
     c                   eval      tdpcon2 = 'Contact last name'
     c                   eval      tdpphon = '800.555.1234'
     c                   eval      tdpstpc = 0
     c                   eval      tdpstpw = 0
     c                   eval      tdpstpp = 0
     c                   write     tdprec
     c                   endif
     *
     *-------------------------------------------------------------------------
     *
     *  Loop through unique piece number recs and write ITEM_LABEL records
     *
     C     keyordp1      setll     ordp1
     C                   dou       forevr <> forevr
     C     keyordp1      reade     ordp1
     C                   select
     C                   when      %eof(ordp1)
     C                   leave
     C                   when      orpscn = 0
     C                   iter
     C                   other
     *
     c                   if        orpcnt = 1
     C     orplbl        chain     worklbl
     c                   if        not %found(worklbl)
     c                   iter
     c                   endif
     c                   if        orpitm <> 'TOTE'
     c                   eval      tditote = ' '
     C                   exsr      zztotRoute
     C                   exsr      zzupdSumm
     C                   exsr      zzupdStop
     C                   exsr      zzchkTote
     c                   else
     c                   eval      tditote = lwitem
     c                   endif
     C                   exsr      zzgetit
     c                   endif
     *
     C                   exsr      zzadd
     C                   endsl
     C                   enddo
     *
     *---------------------------------------------------------------------
     *
     C     keyoh         setgt     ordh9
     *
     C                   enddo

     * Write ROUTE record
     c                   eval      tdrrtec = totrtec
     c                   eval      tdrrtew = totrtew
     c                   eval      tdrrtep = totrtep
     c                   write     tdrrec

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
     *   Define partial key for ORDP1 file
     *
     C     keyordp1      klist
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
     *   Define full key for STOP file
     *
     C     keystop1      klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lwstop
     *
     *   Define full key for STOP file
     *
     C     keystop       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    ohstop
     *
     *   Define full key for PIRITEM file
     *
     C     keyit         klist
     C                   kfld                    ohwhse
     C                   kfld                    orpitm
     *
     *   Define full key for PLTSUM4P
     *
     C     keyplts       klist
     C                   kfld                    lwtrn#
     C                   kfld                    lwpal#
     *
     *   Define full key for SUMMARY
     *
     C     keysumm       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    lwcomp
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZADD      Write ITEM_LABEL records
     *
     C     zzadd         begsr

     c                   eval      tdiwhse = $pwhse
     c                   eval      tdirtid = $prtid
     c                   eval      tdistop = lwstop
     c                   eval      tdiitem = lwitem
     c                   eval      tdiitmc = lwcube
     c                   eval      tdiitmw = lwswgt
     c                   eval      tdiitmp = lwqpck
     c                   eval      tdidept = lwwhdp
     c                   eval      tditype = lwstyp
     c                   eval      tdidesc = itdesc
     c                   eval      tdibulk = lwtype
     c                   eval      tdiscan = orpup#
     c                   movel     lwpal#        tdiplsc
     c                   eval      tdiupc  = itupc
     c                   eval      tdium   = lwucod
     c                   eval      tdiord  = lword
     c                   eval      tdicord = ohcord
     C                   eval      tdicomp = lwcomp
     c                   eval      tdiplid = lwpal#
     C                   eval      tdizone = lwtzon
     c                   eval      tdiunl  = 0
     c     keyplts       chain     pltsum4p
     c                   eval      tdiunl  = psunld
     c                   write     tdirec
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCHKTOTE  Check to see if this a tote item, and if so,
     *             write tote name in this tote record.
     *
     C     zzchkTote     begsr
     *
     C     lwtrn#        chain     totehdr1
     C                   if        not %found(totehdr1)
     C                   eval      tditote = ' '
     C                   else
     C                   eval      lbitem = ' '
     C     tohml#        chain     label
     C                   eval      tditote = lbitem
     C                   endif
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
     *
     C                   endsr

     *-------------------------------------------------------------------------
     *
     *  ZZTOTROUTE  Total route's cube, weight, and pieces.
     *
     C     zztotRoute    begsr
     *
     C                   eval      totrtec = totrtec + lwcube
     C                   eval      totrtew = totrtew + lwswgt
     C                   eval      totrtep = totrtep + lwqpck

     C                   endsr

     *-------------------------------------------------------------------------
     *
     *  ZZUPDSTOP  Update STOP records with item's cube, weight, and pieces.
     *
     C     zzupdStop     begsr
     *
     C     keystop1      chain     Stop
     C                   if        %found
     C                   eval      tdpstpc = tdpstpc + lwcube
     C                   eval      tdpstpw = tdpstpw + lwswgt
     C                   eval      tdpstpp = tdpstpp + lwqpck
     C                   update    tdprec
     C                   endif
     *
     C                   endsr
     *
     *-------------------------------------------------------------------------
     *
     *  ZZUPDSUMM  Update Summary file.
     *
     C     zzupdSumm     begsr
     *
     c     keysumm       chain     summary
     c                   if        %found(summary)
     C                   eval      tdsrtec = tdsrtec + lwcube
     C                   eval      tdsrtew = tdsrtew + lwswgt
     C                   eval      tdsrtep = tdsrtep + lwqpck
     c                   update    tdsrec
     c                   else
     c                   eval      tdswhse = $pwhse
     c                   eval      tdsrtid = $prtid
     C                   eval      tdscomp = lwcomp
     C                   eval      tdsrtec = lwcube
     C                   eval      tdsrtew = lwswgt
     C                   eval      tdsrtep = lwqpck
     c                   eval      tdsdlvc = 0
     c                   eval      tdsdlvw = 0
     c                   eval      tdsdlvp = 0
     c                   write     tdsrec
     c                   endif

     C                   endsr
     *
     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,errno_h

     *-------------------------------------------------------------------------
