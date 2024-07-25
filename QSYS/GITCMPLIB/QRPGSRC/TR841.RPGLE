      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('HTTPAPI')
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TR841  Trax - Returns - Parse Version 1.3 XML into TTRTN
     *  11 Dec 2014
     *  Retha Davis
     *
     *  Revisions
     *
     *    12/11/14   RBD  6.50
     *      - Created.
     *
710aA*    11/18/17  DAS  7.10c
     *      - Revised to get IFS folder from *TRAX2 options
     *
     *----------------------------------------------------------------
     *    Custom Client Revisions:  ISupply
     *
ISPa *    12/11/14   RBD  ISPa
     *      - Enh: Do not print Completion Report.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    04/04/17  RBD/GJA   JSLa
     *      - Format URL for CLOUD
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *        Process the parent route xml first, as it will be the
     *        first route in the file, then process each of the child
     *        routes.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *
     Fordd      if   e           k disk
     Fordp      if   e           k disk
     Foptions   if   e           k disk
     Fpiruser1  if   e           k disk
     Frtehed    if   e           k disk
     Fttlog     uf   e           k disk
     Fttrte     uf a e           k disk
     Fttrtn     uf a e           k disk
     Fttstp     uf a e           k disk
     Ftttrx1    uf a e           k disk
     Fttstpfr   uf a e           k disk
     Fqsysprt   o    f  132        printer oflind(*inof)
     F                                     usropn

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,c#ifsio_h
      /copy qcopysrc,httpapi_h
      /copy qcopysrc,ifsio_h
      /copy qcopysrc,errno_h
      /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     * Customer ID.
     *----------------------------------------------------------------

ISPaA /copy qcopysrc,id#isupply
JSLaA /COPY QCOPYSRC,ID#jsl

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D TR845           pr                  extpgm('TR845')
     D  whse                          3  0
     D  rtid                          5
     D  rtncd                         8
     D  pRtnMessage                  60

     D TR340           pr                  extpgm('TR340')
     D  whse                          3  0
     D  rtid                          5

     *----------------------------------------------------------------
     *  *TRAX  -  TRAX options
     *
     * Fields
     *
     *    OPTHST  -  Days to keep TRAX export data (1-999)
     *    OPTSLI  -  Save log info
     *    OPTCWR  -  Catch weight required
     *    OPTOFT  -  Order number field type
     *    OPTDFT  -  Driver field type
     *    OPTRFT  -  Route field type
     *    OPTCAP  -  Capitalize input
     *    OPTDBL  -  Double click delivery
     *    OPTEKD  -  Entry key delivery
     *    OPTDAR  -  Delivery after return
     *    OPTIDB  -  Include item data base
     *    OPTBDA  -  Breakdowns allowed
     *    OPTGBD  -  Generic breakdown allowed
     *    OPTRTQ  -  Pre-trip questions
     *    OPTOTQ  -  Post-trip questions
     *    OPTCCE  -  Credit card enabled
     *    OPTSIG  -  Signature enabled
     *    OPTPIV  -  Print invoice
     *    OPTSDA  -  Send data after stop
     *    OPTWSP  -  Ws port
     *    OPTWSI  -  Ws IP
     *    OPTSVD  -  Save days
     *    OPTERT  -  Environment run time
     *    OPTEDV  -  Environment device
     *    OPTEOS  -  Environment OS
     *    OPTESW  -  Environment screen width
     *    OPTESH  -  Environment screen height
     *    OPTARE  -  Add return enabled
     *
     * Data structure
     *
     D opdat2          ds
     D  opthst                 1      3  0
     D  optsli                 4      4
     D  optcwr                 5      5
     D  optoft                 6      6
     D  optdft                 7      7
     D  optrft                 8      8
     D  optcap                 9      9
     D  optdbl                10     10
     D  optekd                11     11
     D  optdar                12     12
     D  optidb                13     13
     D  optbda                14     14
     D  optgbd                15     15
     D  optrtq                16     16
     D  optotq                17     17
     D  optcce                18     18
     D  optsig                19     19
     D  optpiv                20     20
     D  optsda                21     21
     D  optwsp                22     26  0
     D  optwsi                27     41
     D  optsvd                42     43  0
     D  optert                44     47
     D  optedv                48     57
     D  opteos                58     67
     D  optesw                68     71  0
     D  optesh                72     75  0
     D  optare                76     76
     D  opten2               117    117
710aA*----------------------------------------------------------------
710aA*  *TRAX2  -  More TRAX options
710aA*----------------------------------------------------------------
710aA*
     * Fields
     *
     *    OPTSBU  -  Use system suspend battery power timeout.
     *    OPTSB   -  System suspend battery power timeout.
     *    OPTSEU  -  Use system suspend external power timeout.
     *    OPTSE   -  System suspend external power timeout.
     *    OPTBBU  -  Use backlight off battery power timeout.
     *    OPTBB   -  Backlight off battery power timeout.
     *    OPTBEU  -  Use backlight off external power timeout.
     *    OPTBE   -  Backlight off external power timeout.
     *    OPTV12  -  Default = N.  Y = create V1.2 xml.
     *    OPTV20  -  Default = N.  Y = create V2.0 xml.
     *    OPTDIR  -  IFS main directory
     *
     * Data structure
     *
     D opdta3          ds
     D  optsbu                 1      1
     D  optsb                  2      4  0
     D  optseu                 5      5
     D  optse                  6      8  0
     D  optbbu                 9      9
     D  optbb                 10     13  0
     D  optbeu                14     14
     D  optbe                 15     17  0
     D  optv12                18     18
     D  optv20                19     19
     D  optdir                20     39
     D  opten3               117    117
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

     D print           PR
     D   text                       132A   value

     *----------------------------------------------------------------
     D log             PR
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   proc                        30A   varying const

     D StartIncoming   PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D EndIncoming     PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   Attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D StartReturns    PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D EndReturns      PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   Attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D StartStop       PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D EndStop         PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   Attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D StartItem       PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D EndItem         PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   Attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D StartStopEPM    PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D EndStopEPM      PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   Attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D StartSigEPM     PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D EndSigEPM       PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   Attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D StartItemEPM    PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D EndItemEPM      PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   Attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D StartStpFlgRsp  PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D EndStpFlgRsp    PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   Attrs                         *   dim(32767)
     D                                     const options(*varsize)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     D keyop           ds                  likerec(oprec : *key)

     D keyttl          ds                  likerec(ttlrec : *key)

     D keyrte          ds
     D  kywhse                             like(ttwhse)
     D  kyrtid                             like(ttrtid)

     D keyordd         ds
     D  kywhse4                            like(orpwhs)
     D  kyord4                             like(orpord)
     D  kyseq4                             like(orpsq#)

     D keyordp         ds
     D  kywhse1                            like(ttwhse)
     D  kyrtid1                            like(ttrtid)
     D  kyuci                              like(ttuci)

     D keystp          ds
     D  kywhse2                            like(ttwhse)
     D  kyrtid2                            like(ttrtid)
     D  kystop                             like(ttstop)

     D keytrx          ds
     D  kywhse3                            like(ttwhse)
     D  kyrtid3                            like(ttxrti)
     D  kyTrax#                            like(ttxtrx)

     D keystpfr        ds
     D  kywhse5                            like(ttfrwh)
     D  kyrtid5                            like(ttfrri)
     D  kystop5                            like(ttfrst)
     D  kyord5                             like(ttfror)
     D  kychar5                            like(ttfrch)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $prtid          s              5
     D $pwhse          s              3  0
     D bfcoffset       s              3  0 inz(0)
     D convertDelivQ   s              5  0
     D CurrentRte      s               n   inz(*off)
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
710aAD dirLen          s              3  0
     D drvId           s              5  0
     D filename        s             45A   varying
     D forever         s               n   inz(*on)
     D hld_delivPcs    s              5  0
     D hld_item        s                   like(ttxitm)
     D hld_opFlg       s                   like(ttxopf)
     D hld_qtybrk      s              5  0
     D hld_qtybrkRtn   s              5  0
     D hld_qtypcs      s              5  0
     D hld_retnPcs     s              5  0
     D hld_ttbflg      s                   like(ttbflg)
     D hld_ttfror      s                   like(ttfror)
     D hld_ttfrch      s                   like(ttfrch)
     D hld_ttfrre      s                   like(ttfrre)
     D hld_ttfrd       s                   like(ttfrd)
     D hld_ttfrt       s                   like(ttfrt)
     D hld_ttpfid      s                   like(ttpfid)
     D hld_ttpfit      s                   like(ttpfit)
     D hld_ttpgna      s                   like(ttpgna)
     D hld_ttpgfn      s                   like(ttpgfn)
     D hld_ttpguc      s                   like(ttpguc)
     D hld_ttpgsn      s                   like(ttpgsn)
     D hld_ttpgdt      s                   like(ttpgdt)
     D hld_ttpgtm      s                   like(ttpgtm)
     D hld_ttpmem      s                   like(ttpmem)
     D hld_ttpsrd      s                   like(ttpsrd)
     D hld_ttpsrt      s                   like(ttpsrt)
     D hld_ttxibf      s                   like(ttxibf)
     D hld_ttxsrd      s                   like(ttxsrd)
     D hld_ttxsrt      s                   like(ttxsrt)
     D hld_ttxstp      s                   like(ttxstp)
     D hld_ttxtrx      s                   like(ttxtrx)
     D hld_uci         s              5
     D hld_um          s              2
     D hld_uombrk      s              2
     D hld_uomnormal   s              2
     D msg             s             50A
     D  noStamp        s               z   inz(z'0001-01-01-00.00.00.000000')
     D PrintLine       s            132A
     D pRtnCode        s             10
     D pRtnCd          s              8
     D pRtnMessage     s             60
     D rc              s             10I 0
     D rte_uci         s             10
     D TTrteUpdFlg     s               n   inz(*off)
     D url             s            100A   varying
     D userData        ds                  likeds(userData_t) inz
     D usrdta1         s              1
     D x               s             10I 0

     *----------------------------------------------------------------

     D hld_timeStamp   ds
     D  timStmpCCYY            1      4
     D  timStmpMM              6      7
     D  timStmpDD              9     10
     D  timStmpHH             12     13
     D  timStmpMIN            15     16
     D  timStmpSS             18     19

     D hld_CCYYMMDD    ds
     D  CCYY                   1      4
     D  MM                     5      6
     D  DD                     7      8

     D hld_HHMMSS      ds
     D  HH                     1      2
     D  MIN                    3      4
     D  SS                     5      6

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

     D gRhrte          s              5

     *----------------------------------------------------------------

     D userData_t      ds                  qualified               based(pDummy)
     D  returns                            likeds(returns_t)

     D returns_t       ds                  qualified               based(pDummy)
     D  firstName                   100A   varying

     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pfile           30
     C                   parm                    pRtnCode
     C                   parm                    pRtnMessage

      /free

        *inlr = *on;
        pRtnCode = '*OK';

         exsr getOptions;

           kywhse = $pwhse;
           kyrtid = (%subst($pfile:6:5));

      /end-free

     *   Delete or update route (including children) in Trax files
     *   before uploading in case this route has been uploaded before.

     C                   call      'TR844'
     C                   parm                    $pwhse
     C                   parm                    kyrtid
     C                   parm                    $prtn             8
     C                   parm                    $perm            60

      /free

         select;

710aA      when optdir <> '';
710aA        dirLen = %len(%trimr(optdir));
710aA        if %subst(optdir:1:1) <> '/';
710aA          url = '/' + optdir;
710aA        else;
710aA          url = optdir;
710aA        endif;
710aA        if %subst(optdir:dirLen:1) <> '/';
710aA          url = %trimr(url) + '/';
710aA        endif;

           when optert = 'PROD';
JSLaA        if client = JSilvert;
JSLaA          url = '/JSLTrax/';
JSLaA        else;
             url = '/BFCTrax/';
JSLaA        endif;

           when optert = 'TEST';
JSLaA        if client = JSilvert;
JSLaA          url = '/JSLTraxTest/';
JSLaA        else;
             url = '/BFCTraxTest/';
JSLaA        endif;

           when optert = 'DEV ';
             url = '/BFCTraxDev/';

         endsl;

        filename = %trimr(url) + %trim($pfile);

        // ****************************************************
        //   Parse the XML from the Trax Returns file.
        // ****************************************************

        if (http_parse_xml_stmf( filename
                               : HTTP_XML_CALC
                               : %paddr(StartIncoming)
                               : %paddr(EndIncoming)
                               : %addr(userData) ) < 0 );
           print(http_error());
        pRtnCode = '*ERROR';
        pRtnMessage = 'TR841:Error uploading returns '
                       + %trimr($pfile);
           return;
        endif;

      /end-free

     C                   eval      qcmd = 'DLTOVR '
     C                                  + 'FILE(QSYSPRT) '

     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm      80            qlen

      /free
        close(e)   qsysprt;

        if pRtnCode = '*OK';
          kyrtid = (%subst($pfile:6:5));
          TR845($pwhse : kyrtid : pRtnCd : pRtnMessage);
ISPaA     select;
ISPaA       when client = ISupply;
ISPaA         // no report
ISPaA       other;
              TR340($pwhse : kyrtid);
ISPaA     endsl;
        endif;

        return;

        //-------------------------------------------------------------
        //  *inzsr  Initialization subroutine
        //-------------------------------------------------------------

        begsr *inzsr;

           qcmd = 'OVRPRTF '
                + 'FILE(QSYSPRT) '
                + 'OUTQ(QPRINT) ';

      /end-free
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5

     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10

      /free

         // Open printer file.
           open(e) qsysprt;

        endsr;

       //---------------------------------------------------------------
       //  getOptions    Get options
       //---------------------------------------------------------------

        begsr getOptions;

       //  get *TRAX options

         $pwhse = %dec(%subst($pfile:2:3):3:0);

         keyop.opWhse = $pwhse;
         keyop.opCode = '*TRAX   ';

         chain %kds(keyop) Options;

         if not %found;
         opdat2 = ' ';
         else;
         opdat2 = opdata;
       endif;

710aA  //  get *TRAX2 options
710aA
         keyop.opWhse = $pwhse;
         keyop.opCode = '*TRAX2  ';

         chain %kds(keyop) Options;

         if not %found;
           opdta3  = ' ';
         else;
           opdta3  = opdata;
         endif;

       endsr;

      /end-free

       //---------------------------------------------------------------

     Oqsysprt   E
     O                       PrintLine          132


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  logs procedure flow.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P log             B
     D log             PI
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   proc                        30A   varying const

     D logLine         ds                  qualified
     D  proc                         20A
     D  spacer_1                      3
     D  depth                         3A
     D  spacer_2                      3
     D  name                         15A
     D  spacer_3                      3
     D  path                         50A

      /free

         clear logLine;
         logLine.proc  = proc;
         logLine.depth = %char(%dec(depth: 3: 0));
         logLine.name  = name;
         logLine.path  = path;

         print(logLine);

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  prints a given text.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P print           B
     D print           PI
     D   text                       132A   value

      /free

         PrintLine = text;
         except;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This is called for each XML element that's received in the
      *  document. The http_parser_switch_cb() is used to delegate
      *  element processing to specialized procedures.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P StartIncoming   B
     D StartIncoming   PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'StartIncoming');

            dou name <> 'returns';
               // Switch to StartReturns.
               http_parser_switch_cb(%addr(usrdta1)
                                     : %paddr(StartReturns)
                                     : %paddr(EndReturns));
            enddo;
               return;

         return;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  EndIncoming():
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P EndIncoming     B
     D EndIncoming     PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

         // There is nothing to do here.

         log(depth: name: path: 'EndIncoming');

         return;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  StartReturns(): Specialized to gather 'returns' information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P StartReturns    B
     D StartReturns    PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'StartReturns');

       select;
       when  path = '/returns/CurrentRouteReturns';
         currentRte = *on;
       when  path = '/returns/PreviousRouteReturns';
         currentRte = *off;
       endsl;

         if name = 'returns';

       // Clear Trax returns record
         clear ttRec;

            count = 1;
            dow attrs(count) <> *NULL;
               attrname = %str(attrs(count));
               count = count + 1;
               attrval = %str(attrs(count));
               count = count + 1;

            select;
            when attrname = 'driverID';
               if attrval = 'N/A  ' or attrval = 'uid  ';
                 eval attrval = '99999';
               endif;
               drvId  = %dec(attrval:5:0);
            when attrname = 'routeID';
               ttrtid = attrval;
               ttrrti = attrval;
               ttprti = attrval;
               ttxrti = attrval;
               ttfrri = attrval;
            when attrname = 'warehouseCode';
               ttwhse = %dec(attrval:3:0);
               ttrwhs = %dec(attrval:3:0);
               ttpwhs = %dec(attrval:3:0);
               ttxwhs = %dec(attrval:3:0);
               ttfrwh = %dec(attrval:3:0);
            endsl;
            enddo;

       //  Get Trax route record

         kyrtid = ttrtid;
         chain %kds(keyrte) TTrte;

       //  There may or may not be a TTRTE record, turn on update flag
       //  if it exists.

       //  Initialize fields.

         if not %found;
           TTrteUpdFlg = *off;
           ttrwhs = 0;
           ttrrti = ' ';
           ttrusr = ' ';

         else;
           TTrteUpdFlg = *on;
         endif;

         ttrtru = ' ';
         ttrscn = ' ';
         ttrs   = 0;
         ttrsd  = 0;
         ttrqs1 = 0;
         ttrqs2 = 0;
         ttrqs3 = 0;
         ttrqn1 = 0;
         ttrqn2 = 0;
         ttrqn3 = 0;
         ttrqc1 = 0;
         ttrqc2 = 0;
         ttrqc3 = 0;
         ttrqp1 = 0;
         ttrqp2 = 0;
         ttrqp3 = 0;
         ttrsrd = 0;
         ttrsrt = 0;
         ttrfid = 0;
         ttrfit = 0;
         ttrser = ' ';

         // Go get route

         chain %kds(keyrte) rtehed;
         if %found();
           ttrout = rhrte;
           ttrrte = rhrte;
           ttxrte = rhrte;
           ttfrrt = rhrte;
           gRhrte = rhrte;
           ttrtru = rhtruk;
         else;
           rhrte  = ' ';
           ttrout = ' ';
           ttrrte = ' ';
           ttxrte = ' ';
           ttfrrt = ' ';
           ttrtru = ' ';
         endif;

         // Go get user id

         chain (drvId) piruser1;
         if %found();
           ttusr = uscode;
         else;
           ttusr = %char(drvId);
         endif;

         endif;

         if name = 'EPM';

            count = 1;
            dow attrs(count) <> *NULL;
               attrname = %str(attrs(count));
               count = count + 1;
               attrval = %str(attrs(count));
               count = count + 1;

            select;
            when attrname = 'begnRouteTimeStamp';
               hld_timeStamp = attrval;
               CCYY = timStmpCCYY;
               MM = timStmpMM;
               DD = timStmpDD;
               HH = timStmpHH;
               MIN = timStmpMIN;
               SS = timStmpSS;
               ttrsrd = %dec(hld_CCYYMMDD:8:0);
               ttrsrt = %dec(hld_HHMMSS:6:0);
            when attrname = 'endRouteTimeStamp';
               hld_timeStamp = attrval;
               CCYY = timStmpCCYY;
               MM = timStmpMM;
               DD = timStmpDD;
               HH = timStmpHH;
               MIN = timStmpMIN;
               SS = timStmpSS;
               ttrfid = %dec(hld_CCYYMMDD:8:0);
               ttrfit = %dec(hld_HHMMSS:6:0);
            when attrname = 'deviceSerialNumber';
               ttrser = attrval;
            endsl;
            enddo;

      /end-free

     *  getDateTime  Get current date & time
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ttrstd = $cvd8o
     C                   time                    ttrstt

      /free

            // Update or write Trax route record
              if TTrteUpdFlg = *on;
               ttrusr = ttusr;
               update(e) ttrrec;
              else;
               ttrusr = ttusr;
               write(e) ttrrec;
              endif;
            endif;

       select;
       when  path <> '/returns/EPM';

            if name = 'Stop';
               // Switch to StartStop.
               http_parser_switch_cb(%addr(usrdta1)
                                     : %paddr(StartStop)
                                     : %paddr(EndStop));
               return;
            endif;

           other;

            if name = 'Stop';
               // Switch to StartStopEPM.
               http_parser_switch_cb(%addr(usrdta1)
                                     : %paddr(StartStopEPM)
                                     : %paddr(EndStopEPM));
               return;
            endif;

           endsl;

       //  Update log record

         keyttl.ttlWhse = $pwhse;
         keyttl.ttlrtid = ttrtid;

         setll %kds(keyttl:2) ttlog;
            dow forever = forever;
         reade %kds(keyttl:2) ttlog;

         if %eof;
             leave;
         endif;

         if ttlStatus <> '3';
             iter;
         endif;

       //  This one's a status 3, so change it to 4.
            ttlStatus = '4';
            ttlErrCode = 'UPLOADED';
            ttlErrMsg  = 'File has been uploaded';
            ttlSer = ttrSer;

       //  Set appropriate log time fields

       //    Get current timestamps

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

         ttlTS9   = currStampLoc;

         update(e) ttlrec;

         enddo;

         return;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  EndReturns(): Specialized to gather 'returns' information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P EndReturns      B
     D EndReturns      PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'EndReturns');

         return;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  StartStop(): Specialized to gather 'stop' information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P StartStop       B
     D StartStop       PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'StartStop');

       // Clear some stop fields at beginning of stop
              if name = 'Stop';
               ttstop = 0;
               ttcnam = *blanks;
               hld_ttpmem = *blanks;

            count = 1;
            dow attrs(count) <> *NULL;
               attrname = %str(attrs(count));
               count = count + 1;
               attrval = %str(attrs(count));
               count = count + 1;

            select;
            when attrname = 'stopNumber';
               ttstop = %dec(attrval:2:0);
               hld_ttxstp = %dec(attrval:2:0);
            when attrname = 'customerName';
               ttcnam = attrval;
            when attrname = 'notes';
               hld_ttpmem = attrval;
            endsl;

            enddo;

         // Write or update Stop note file
              if ttstop > 0;
                kywhse2 = ttwhse;
                kyrtid2 = ttrtid;
                kystop  = ttstop;
              chain %kds(keystp) ttstp;
                ttprte = rhrte;
                ttpmem = hld_ttpmem;
              if %found();
                update(e) ttprec;
              else;
                ttpstp = ttstop;
                write(e) ttprec;
              endif;
              endif;
              endif;

            if name = 'Item';
               // Switch to StartItem.
               http_parser_switch_cb(%addr(usrdta1)
                                     : %paddr(StartItem)
                                     : %paddr(EndItem));
               return;
            endif;

         return;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  EndStop(): Specialized to gather 'stop' information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P EndStop         B
     D EndStop         PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'EndStop');

         return;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  StartItem(): Specialized to gather 'item' information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P StartItem       B
     D StartItem       PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'StartItem');

         if name = 'Item';

       // Clear item fields
               ttitem = *blanks;
               hld_qtypcs = 0;
               rte_uci  = *blanks;
               hld_uci  = *blanks;
               ttuci = 0;
               hld_uomnormal = *blanks;
               ttord  = 0;
               ttrcod = *blanks;
               ttmemo = *blanks;
               ttbflg = *blanks;
               hld_ttbflg = *blanks;
               hld_uombrk = *blanks;
               hld_qtybrkRtn = 0;
               hld_qtybrk = 0;
               ttcwgt = 0;
               ttoqty = 0;
               ttuom = *blanks;
               ttolbl = 0;

            count = 1;
            dow attrs(count) <> *NULL;
               attrname = %str(attrs(count));
               count = count + 1;
               attrval = %str(attrs(count));
               count = count + 1;

            select;
            when attrname = 'itemNumber';
               ttitem = attrval;
            when attrname = 'pieces';
               hld_qtypcs = %dec(attrval:5:0);
            when attrname = 'scanID';
               rte_uci  = attrval;
               hld_uci  = %subst(rte_uci:6:5);
               if hld_uci = *blanks;
                 hld_uci = '00000';
               endif;
               ttuci    = %dec(hld_uci:5:0);
            when attrname = 'unitMeasure';
               hld_uomnormal = attrval;
            when attrname = 'internalOrderNumber';
               ttord  = %dec(attrval:7:0);
            when attrname = 'returnCode';
               ttrcod = attrval;
            when attrname = 'notes';
               ttmemo = attrval;
            when attrname = 'breakDownFlag';
               hld_ttbflg = attrval;
            when attrname = 'breakDownUM';
               hld_uombrk = attrval;
            when attrname = 'breakDownReturnQuantity';
               hld_qtybrkRtn = %dec(attrval:5:0);
            when attrname = 'breakDownQuantity';
               hld_qtybrk = %dec(attrval:5:0);
            when attrname = 'catchWeight';
                   ttcwgt = %dec(attrval:10:3);
            endsl;
            enddo;

         // Go get label#

           orpwhs = 0;
           orpord = 0;
           orpsq# = 0;
           kywhse1 = ttwhse;
           kyrtid1 = ttrtid;
           kyuci  = ttuci;
         chain %kds(keyordp) ordp;
         if %found();
           ttolbl = orplbl;
         else;
           ttolbl = 0;
         endif;

         // Write uploaded breakdown flag if not 0, as that means the
         // driver changed it.

         select;
           when hld_ttbflg <> '0';
             ttbflg = hld_ttbflg;

           other;

         // Write downloaded breakdown flag if uploaded breakdown flag
         // is 0, as that means the driver didn't change it. Go to ORDD
         // to determine what the downloaded breakdown flag was.

           kywhse4 = orpwhs;
           kyord4 = orpord;
           kyseq4  = orpsq#;
         chain %kds(keyordd) ordd;
         if %found();
           select;
             when odqor1 > 0;
               ttbflg = '0';
             when odqor2 > 0;
               ttbflg = '1';
             when odqor3 > 0;
               ttbflg = '2';
           endsl;
         else;
           ttbflg = '0';
         endif;
         endsl;

         // Populate qty and uom fields for TTRTN file

         if hld_qtybrkRtn = 0;
           ttoqty = hld_qtypcs;
           ttuom = hld_uomnormal;
         else;
           ttoqty = hld_qtybrkRtn;
           ttuom = hld_uombrk;
         endif;

      /end-free

     *  getDateTime  Get current date & time
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ttudte = $cvd8o
     C                   time                    ttutim

      /free

         ttstsd = 0;
         ttstst = 0;
         ttstat = '1';

         // Write Trax return record
         write(e) ttrec;


         // Populate fields for Trax pieces file
         // Write or update Trax pieces file

                kywhse3 = ttwhse;
                kyrtid3 = ttrtid;
                kyTrax# = ttuci;
                ttxqc1 = 0;
                ttxqc2 = 0;
                ttxqc3 = 0;
                ttxqp1 = 0;
                ttxqp2 = 0;
                ttxqp3 = 0;
              chain %kds(keytrx) tttrx1;
                ttxstp = hld_ttxstp;
                ttxitm = ttitem;
                ttxum  = ttuom;
                ttxrbf = ttbflg;
                ttxbq  = hld_qtybrk;
                ttxbqr = hld_qtybrkRtn;

       select;

           when currentRte = *on;
           select;
           when ttxrbf = '0';
                ttxqc1 = ttoqty;
           when ttxrbf = '1';
                ttxqc2 = ttoqty;
           when ttxrbf = '2' or ttxrbf = 'G';
                ttxqc3 = ttoqty;
           endsl;

           other;
           select;
           when ttxrbf = '0';
                ttxqp1 = ttoqty;
           when ttxrbf = '1';
                ttxqp2 = ttoqty;
           when ttxrbf = '2' or ttxrbf = 'G';
                ttxqp3 = ttoqty;
           endsl;

        endsl;

              if %found();
        // If breakDownFlag in return record <> initialBreakDownFlag
        // in EPM record, the delivered qty must be converted to the
        // new breakdown qty.
                if ttxrbf <> ttxibf;
                ttxqs1 = 0;
                ttxqs2 = 0;
                ttxqs3 = 0;
                ttxqn1 = 0;
                ttxqn2 = 0;
                ttxqn3 = 0;
                convertDelivQ = hld_qtybrk - hld_qtybrkRtn;
                   select;
                   when ttxopf = 'S';
                      select;
                      when ttxrbf = '0';
                      ttxqs1 = convertDelivQ;
                      when ttxrbf = '1';
                      ttxqs2 = convertDelivQ;
                      when ttxrbf = '2' or ttxrbf = 'G';
                      ttxqs3 = convertDelivQ;
                      endsl;
                   other;
                      select;
                      when ttxrbf = '0';
                      ttxqn1 = convertDelivQ;
                      when ttxrbf = '1';
                      ttxqn2 = convertDelivQ;
                      when ttxrbf = '2' or ttxrbf = 'G';
                      ttxqn3 = convertDelivQ;
                      endsl;
                   endsl;
                endif;
                update(e) ttxrec;
              else;
                ttxtrx = ttuci;
                ttxibf = ' ';
                ttxqs1 = 0;
                ttxqs2 = 0;
                ttxqs3 = 0;
                ttxqn1 = 0;
                ttxqn2 = 0;
                ttxqn3 = 0;
                ttxsrd = 0;
                ttxsrt = 0;
                write(e) ttxrec;
              endif;


         endif;

         return;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  EndItem(): Specialized to gather 'item' information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P EndItem         B
     D EndItem         PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'EndItem');

         return;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  StartStopEPM(): Specialized to gather 'stop EPM' information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P StartStopEPM    B
     D StartStopEPM    PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'StartStopEPM');

         if name = 'Stop';

           count = 1;
           dow attrs(count) <> *NULL;
             attrname = %str(attrs(count));
             count = count + 1;
             attrval = %str(attrs(count));
             count = count + 1;

             select;
               when attrname = 'stopNumber';
                 ttpstp = %dec(attrval:2:0);
                 hld_ttxstp = %dec(attrval:2:0);
               when attrname = 'beginStopTravel';
                 hld_timeStamp = attrval;
                 CCYY = timStmpCCYY;
                 MM = timStmpMM;
                 DD = timStmpDD;
                 HH = timStmpHH;
                 MIN = timStmpMIN;
                 SS = timStmpSS;
                 hld_ttpsrd = %dec(hld_CCYYMMDD:8:0);
                 hld_ttpsrt = %dec(hld_HHMMSS:6:0);
               when attrname = 'completeStop';
                 hld_timeStamp = attrval;
                 CCYY = timStmpCCYY;
                 MM = timStmpMM;
                 DD = timStmpDD;
                 HH = timStmpHH;
                 MIN = timStmpMIN;
                 SS = timStmpSS;
                 hld_ttpfid = %dec(hld_CCYYMMDD:8:0);
                 hld_ttpfit = %dec(hld_HHMMSS:6:0);
             endsl;
           enddo;

         // Write or update Stop note file
           if ttpstp > 0;
             kywhse2 = ttwhse;
             kyrtid2 = ttrtid;
             kystop  = ttpstp;
             chain %kds(keystp) ttstp;
             ttprte = rhrte;
             ttpsrd = hld_ttpsrd;
             ttpsrt = hld_ttpsrt;
             ttpfid = hld_ttpfid;
             ttpfit = hld_ttpfit;
             if %found();
               update(e) ttprec;
             else;

       // Clear stop fields before writing new stop record
               ttpscn = *blanks;
               ttpqs1 = 0;
               ttpqs2 = 0;
               ttpqs3 = 0;
               ttpqn1 = 0;
               ttpqn2 = 0;
               ttpqn3 = 0;
               ttpqc1 = 0;
               ttpqc2 = 0;
               ttpqc3 = 0;
               ttpqp1 = 0;
               ttpqp2 = 0;
               ttpqp3 = 0;
               ttpgna = *blanks;
               ttpgfn = *blanks;
               ttpguc = *blanks;
               ttpgsn = *blanks;
               ttpgdt = 0;
               ttpgtm = 0;

               write(e) ttprec;
             endif;
           endif;
         endif;

         if name = 'SignatureCapture';
           // Switch to StartSigEPM.
           http_parser_switch_cb(%addr(usrdta1)
                                 : %paddr(StartSigEPM)
                                 : %paddr(EndSigEPM));
           return;
         endif;

         if name = 'Item';
            // Switch to StartItemEPM.
            http_parser_switch_cb(%addr(usrdta1)
                                  : %paddr(StartItemEPM)
                                  : %paddr(EndItemEPM));
            return;
         endif;

         if name = 'StopFlag';
            // Switch to StartStpFlgRsp.
            http_parser_switch_cb(%addr(usrdta1)
                                  : %paddr(StartStpFlgRsp)
                                  : %paddr(EndStpFlgRsp));
            return;
         endif;

         return;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  EndStopEPM(): Specialized to gather 'stop EPM' information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P EndStopEPM      B
     D EndStopEPM      PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'EndStopEPM');

         return;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  StartSigEPM(): Specialized to gather 'stop signature' info
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P StartSigEPM     B
     D StartSigEPM     PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'StartSigEPM');

       // Get signature capture data
         if name = 'SignatureCapture';
           count = 1;
           dow attrs(count) <> *NULL;
             attrname = %str(attrs(count));
             count = count + 1;
             attrval = %str(attrs(count));
             count = count + 1;

             select;
               when attrname = 'signatureName';
                 hld_ttpgna = attrval;
               when attrname = 'signatureFileName';
                 hld_ttpgfn = attrval;
               when attrname = 'signatureSigneeNotFound';
                 hld_ttpgsn = attrval;
               when attrname = 'signatureUseContact';
                 hld_ttpguc = attrval;
               when attrname = 'signatureCaptured';
                 hld_timeStamp = attrval;
                 CCYY = timStmpCCYY;
                 MM = timStmpMM;
                 DD = timStmpDD;
                 HH = timStmpHH;
                 MIN = timStmpMIN;
                 SS = timStmpSS;
                 hld_ttpgdt = %dec(hld_CCYYMMDD:8:0);
                 hld_ttpgtm = %dec(hld_HHMMSS:6:0);
             endsl;
           enddo;

         // Write or update Stop note file
           if ttpstp > 0;
             kywhse2 = ttwhse;
             kyrtid2 = ttrtid;
             kystop  = ttpstp;
             chain %kds(keystp) ttstp;
             ttprte = rhrte;
             ttpgna = hld_ttpgna;
             ttpgfn = hld_ttpgfn;
             ttpgsn = hld_ttpgsn;
             ttpguc = hld_ttpguc;
             ttpgdt = hld_ttpgdt;
             ttpgtm = hld_ttpgtm;
             if %found();
               update(e) ttprec;
             else;

       // Clear stop fields before writing new stop record
           ttpscn = *blanks;
           ttpsrd = 0;
           ttpsrt = 0;
           ttpfid = 0;
           ttpfit = 0;
           ttpqs1 = 0;
           ttpqs2 = 0;
           ttpqs3 = 0;
           ttpqn1 = 0;
           ttpqn2 = 0;
           ttpqn3 = 0;
           ttpqc1 = 0;
           ttpqc2 = 0;
           ttpqc3 = 0;
           ttpqp1 = 0;
           ttpqp2 = 0;
           ttpqp3 = 0;

               write(e) ttprec;
             endif;
           endif;
         endif;

         return;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  EndSigEPM(): Specialized to gather 'stop signature' info
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P EndSigEPM       B
     D EndSigEPM       PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'EndSigEPM');

         return;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  StartItemEPM(): Specialized to gather 'item EPM' information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P StartItemEPM    B
     D StartItemEPM    PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'StartItemEPM');

         if name = 'Item';

       // Clear item fields
               hld_item = *blanks;
               rte_uci  = *blanks;
               hld_uci  = *blanks;
               hld_ttxtrx = 0;
               hld_um = *blanks;
               hld_opflg = *blanks;
               hld_ttxibf = *blanks;
               hld_delivPcs = 0;
               hld_retnPcs = 0;
               hld_ttxsrd = 0;
               hld_ttxsrt = 0;

            count = 1;
            dow attrs(count) <> *NULL;
               attrname = %str(attrs(count));
               count = count + 1;
               attrval = %str(attrs(count));
               count = count + 1;

            select;
            when attrname = 'itemNumber';
               hld_item = attrval;
            when attrname = 'deliveredPieces';
               hld_delivPcs = %dec(attrval:5:0);
            when attrname = 'returnedPieces';
               hld_retnPcs = %dec(attrval:5:0);
            when attrname = 'scanID';
               rte_uci  = attrval;
               hld_uci  = %subst(rte_uci:6:5);
               if hld_uci = *blanks;
                 hld_uci = '00000';
               endif;
               hld_ttxtrx = %dec(hld_uci:5:0);
            when attrname = 'unitMeasure';
               hld_um = attrval;
            when attrname = 'operationFlag';
               hld_opflg = attrval;
            when attrname = 'initialBreakDownFlag';
               hld_ttxibf = attrval;
            when attrname = 'deliveredStamp';
               hld_timeStamp = attrval;
               CCYY = timStmpCCYY;
               MM = timStmpMM;
               DD = timStmpDD;
               HH = timStmpHH;
               MIN = timStmpMIN;
               SS = timStmpSS;
               hld_ttxsrd = %dec(hld_CCYYMMDD:8:0);
               hld_ttxsrt = %dec(hld_HHMMSS:6:0);
            endsl;
            enddo;


         // Populate fields for Trax pieces file
         // Write or update Trax pieces file

                kywhse3 = ttwhse;
                kyrtid3 = ttrtid;
                kyTrax# = hld_ttxtrx;
              chain %kds(keytrx) tttrx1;
                ttxstp = hld_ttxstp;
                ttxopf = hld_opflg;
                ttxibf = hld_ttxibf;
                ttxqs1 = 0;
                ttxqs2 = 0;
                ttxqs3 = 0;
                ttxqn1 = 0;
                ttxqn2 = 0;
                ttxqn3 = 0;
                   select;
                   when ttxopf = 'S';
                      select;
                      when ttxibf = '0';
                      ttxqs1 = hld_delivPcs;
                      when ttxibf = '1';
                      ttxqs2 = hld_delivPcs;
                      when ttxibf = '2' or ttxrbf = 'G';
                      ttxqs3 = hld_delivPcs;
                      endsl;
                   other;
                      select;
                      when ttxibf = '0';
                      ttxqn1 = hld_delivPcs;
                      when ttxibf = '1';
                      ttxqn2 = hld_delivPcs;
                      when ttxibf = '2' or ttxrbf = 'G';
                      ttxqn3 = hld_delivPcs;
                      endsl;
                   endsl;
                ttxsrd = hld_ttxsrd;
                ttxsrt = hld_ttxsrt;


              if %found();
        // If breakDownFlag in return record <> initialBreakDownFlag
        // in EPM record, the delivered qty must be converted to the
        // new breakdown qty.
                if ttxrbf <> ttxibf;
                ttxqs1 = 0;
                ttxqs2 = 0;
                ttxqs3 = 0;
                ttxqn1 = 0;
                ttxqn2 = 0;
                ttxqn3 = 0;
                convertDelivQ = ttxbq - ttxbqr;
                   select;
                   when ttxopf = 'S';
                      select;
                      when ttxrbf = '0';
                      ttxqs1 = convertDelivQ;
                      when ttxrbf = '1';
                      ttxqs2 = convertDelivQ;
                      when ttxrbf = '2' or ttxrbf = 'G';
                      ttxqs3 = convertDelivQ;
                      endsl;
                   other;
                      select;
                      when ttxrbf = '0';
                      ttxqn1 = convertDelivQ;
                      when ttxrbf = '1';
                      ttxqn2 = convertDelivQ;
                      when ttxrbf = '2' or ttxrbf = 'G';
                      ttxqn3 = convertDelivQ;
                      endsl;
                   endsl;
                endif;
                update(e) ttxrec;
              else;
                ttxtrx = hld_ttxtrx;
                ttxitm = hld_item;
                ttxum  = hld_um;
                ttxbq  = 0;
                ttxbqr = 0;
                ttxqc1 = 0;
                ttxqc2 = 0;
                ttxqc3 = 0;
                ttxqp1 = 0;
                ttxqp2 = 0;
                ttxqp3 = 0;
                write(e) ttxrec;
              endif;


         endif;

         return;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  EndItemEPM(): Specialized to gather 'item EPM' information
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P EndItemEPM      B
     D EndItemEPM      PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'EndItemEPM');

         return;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  StartStpFlgRsp(): Specialized to gather 'stop flag response' info
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P StartStpFlgRsp  B
     D StartStpFlgRsp  PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'StartStpFlgRsp');

         if name = 'StopFlag';

       // Clear stop flag response fields
               hld_ttfror = 0;
               hld_ttfrch = *blanks;
               hld_ttfrre = *blanks;
               hld_ttfrd  = 0;
               hld_ttfrt  = 0;

            count = 1;
            dow attrs(count) <> *NULL;
               attrname = %str(attrs(count));
               count = count + 1;
               attrval = %str(attrs(count));
               count = count + 1;

            select;
            when attrname = 'stopFlagChar';
               hld_ttfrch = attrval;
            when attrname = 'stopFlagResponse';
               hld_ttfrre = attrval;
            when attrname = 'stopFlagTimeStamp';
               hld_timeStamp = attrval;
               CCYY = timStmpCCYY;
               MM = timStmpMM;
               DD = timStmpDD;
               HH = timStmpHH;
               MIN = timStmpMIN;
               SS = timStmpSS;
               hld_ttfrd = %dec(hld_CCYYMMDD:8:0);
               hld_ttfrt = %dec(hld_HHMMSS:6:0);
            endsl;
            enddo;

         // Populate fields for Trax stop flag response file
         // Write or update

                kywhse5 = ttfrwh;
                kyrtid5 = ttfrri;
                kystop5 = hld_ttxstp;
                kyord5  = hld_ttfror;
                kychar5 = hld_ttfrch;
              chain %kds(keystpfr) ttstpfr;
                ttfrst = hld_ttxstp;
                ttfror = hld_ttfror;
                ttfrch = hld_ttfrch;
                ttfrre = hld_ttfrre;
                ttfrd  = hld_ttfrd;
                ttfrt  = hld_ttfrt;

              if %found();
                update(e) ttfrrc;
              else;
                write(e) ttfrrc;
              endif;

         endif;

         return;
      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  EndStpFlgRsp(): Specialized to gather 'stop flag response' info
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P EndStpFlgRsp    B
     D EndStpFlgRsp    PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D text            s            132A

      /free

            log(depth: name: path: 'EndStpFlgRsp');

         return;
      /end-free
     P                 E
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      /define ERRNO_LOAD_PROCEDURE
      /copy qcopysrc,errno_h
