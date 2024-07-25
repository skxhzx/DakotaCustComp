      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('HTTPAPI')
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TR840  Trax - Returns - Parse XML into TTRTN
     *  22 Feb 2010
     *  Retha Davis
     *
     *  Revisions
     *
     *    02/22/10   RBD  5.30
     *      - Created.
     *
640aA*    11/29/11   RBD  6.40a
     *      - Output user id to ttusr if the driver Id gets
     *        a hit to PIRUSER, if not, output driver Id.
     *
640bA*    12/01/11   RBD  6.40b
     *      - Added override to send report to QPRINT and then
     *        delete the override.
     *
640cA*    12/15/11   RBD  6.40c
     *      - Update TTRTE driver with driver from handheld.
     *
640dA*    01/30/12   RBD  6.40d
     *      - If scanID is blank in pos 6-10, change it to 0's.
     *
640eA*    03/06/12   RBD  6.40e
     *      - Update TTRTE with serial no and TTSTP with signature
     *        capture data.
     *
640fA*    05/14/12   RBD  6.40f
     *      - Fix: If driver in upload file = 'N/A' or 'uid' populate
     *        drvId with 99999.  This is a temporary fix until Susan
     *        gets it fixed on the handheld.
     *
650aA*    04/04/13   RBD  6.50a
     *      - Fix: breakDownFlag coming back in upload file = 0 if it
     *        didn't get changed on the handheld.  If it comes back
     *        as 1 or 2, it means the driver is returning breakdown 1
     *        or breakdown 2 unit of measure, and that it is different
     *        from the original breakdown (normal, 1, or 2) that was
     *        downloaded and delivered.
     *
650bA*    07/18/13   RBD  6.50b
     *      - Enh: Added Trax stop flag response file.
     *      - Included logic for order# in stop flag response file
     *        for future use, though it's currently not included in
     *        the file being uploaded from the handheld.
     *
650cA*    08/16/13   RBD  6.50c
     *      - Enh: Added call to TR340 to print Route Completion Report.
     *
650dA*    08/26/13  RBD  6.50d
     *      - Added serial# to log record.
     *
650eA*    08/27/13  RBD  6.50e
     *      - Per Susan, write deliveredStamp to date and time fields
     *        instead of scanStamp because the handheld only writes
     *        scanStamp if the item is actually scanned; deliveredStamp
     *        is written regardless of whether or not it was scanned.
     *
650f *    11/12/13  GJA  6.50f
     *      - Enh:  Add GETCLIENT process for custom client revisions.
     *
710aA*    11/18/17  DAS  7.10a
     *      - Revised to get IFS folder from *TRAX2 options
     *
     *----------------------------------------------------------------
     *    Custom Client Revisions:  ISupply
     *
ISPa *    11/12/13   GJA  ISPa
     *      - Enh: Do no print Completion Report.
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    04/04/17  RBD/GJA   JSLa
     *      - Format URL for CLOUD
     *      - Add client code
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *
650aAFordd      if   e           k disk
     Fordp      if   e           k disk
     Foptions   if   e           k disk
640aAFpiruser1  if   e           k disk
     Frtehed    if   e           k disk
     Fttlog     uf   e           k disk
     Fttrte     uf a e           k disk
     Fttrtn     uf a e           k disk
     Fttstp     uf a e           k disk
     Ftttrx1    uf a e           k disk
650bAFttstpfr   uf a e           k disk
     Fqsysprt   o    f  132        printer oflind(*inof)
640bAF                                     usropn

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,c#ifsio_h
      /copy qcopysrc,httpapi_h
      /copy qcopysrc,ifsio_h
      /copy qcopysrc,errno_h
      /copy qcopysrc,p.bfcdteti

650fA*----------------------------------------------------------------
650fA* Customer ID.
650fA*----------------------------------------------------------------

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

650cAD TR340           pr                  extpgm('TR340')
650cAD  whse                          3  0
650cAD  rtid                          5

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

640eAD StartSigEPM     PR
640eAD   userdata                      *   value
640eAD   depth                       10I 0 value
640eAD   name                      1024A   varying const
640eAD   path                     24576A   varying const
640eAD   attrs                         *   dim(32767)
640eAD                                     const options(*varsize)

640eAD EndSigEPM       PR
640eAD   userdata                      *   value
640eAD   depth                       10I 0 value
640eAD   name                      1024A   varying const
640eAD   path                     24576A   varying const
640eAD   value                    65535A   varying const
640eAD   Attrs                         *   dim(32767)
640eAD                                     const options(*varsize)

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

650bAD StartStpFlgRsp  PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

650bAD EndStpFlgRsp    PR
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

650aAD keyordd         ds
650aAD  kywhse4                            like(orpwhs)
650aAD  kyord4                             like(orpord)
650aAD  kyseq4                             like(orpsq#)

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

650bAD keystpfr        ds
650bAD  kywhse5                            like(ttfrwh)
650bAD  kyrtid5                            like(ttfrri)
650bAD  kystop5                            like(ttfrst)
650bAD  kyord5                             like(ttfror)
650bAD  kychar5                            like(ttfrch)

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
640aAD drvId           s              5  0
     D filename        s             45A   varying
     D forever         s               n   inz(*on)
     D hld_delivPcs    s              5  0
     D hld_item        s                   like(ttxitm)
     D hld_opFlg       s                   like(ttxopf)
     D hld_qtybrk      s              5  0
     D hld_qtybrkRtn   s              5  0
     D hld_qtypcs      s              5  0
     D hld_retnPcs     s              5  0
650aAD hld_ttbflg      s                   like(ttbflg)
650bAD hld_ttfror      s                   like(ttfror)
650bAD hld_ttfrch      s                   like(ttfrch)
650bAD hld_ttfrre      s                   like(ttfrre)
650bAD hld_ttfrd       s                   like(ttfrd)
650bAD hld_ttfrt       s                   like(ttfrt)
     D hld_ttpfid      s                   like(ttpfid)
     D hld_ttpfit      s                   like(ttpfit)
640eAD hld_ttpgna      s                   like(ttpgna)
640eAD hld_ttpgfn      s                   like(ttpgfn)
640eAD hld_ttpguc      s                   like(ttpguc)
640eAD hld_ttpgsn      s                   like(ttpgsn)
640eAD hld_ttpgdt      s                   like(ttpgdt)
640eAD hld_ttpgtm      s                   like(ttpgtm)
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

     *   Delete or update route in Trax files before uploading
     *   in case this route has been uploaded before.

     C                   call      'TR844'
     C                   parm                    $pwhse
     C                   parm                    kyrtid
     C                   parm                    $prtn             8
     C                   parm                    $perm            60

      /free

         exsr getTraxRte;

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
        pRtnMessage = 'TR840:Error uploading returns '
                       + %trimr($pfile);
           return;
        endif;

       //  update TTLOG record
         exsr updateTTLog;

640bA /end-free

640bAC                   eval      qcmd = 'DLTOVR '
640bAC                                  + 'FILE(QSYSPRT) '

640bAC                   call      'QCMDEXC'
640bAC                   parm                    qcmd
640bAC                   parm      80            qlen

640bA /free
640bA   close(e)   qsysprt;

        if pRtnCode = '*OK';
          TR845($pwhse : kyrtid : pRtnCd : pRtnMessage);
ISPaA     select;
ISPaA       when client = ISupply;
ISPaA         // no report
ISPaA       other;
650cA         TR340($pwhse : kyrtid);
ISPaA     endsl;
        endif;

        return;

640bA   //-------------------------------------------------------------
640bA   //  *inzsr  Initialization subroutine
640bA   //-------------------------------------------------------------
640bA
640bA   begsr *inzsr;

640bA      qcmd = 'OVRPRTF '
640bA           + 'FILE(QSYSPRT) '
640bA           + 'OUTQ(QPRINT) ';

640bA /end-free
640bAC                   call      'QCMDEXC'
640bAC                   parm                    qcmd             80
640bAC                   parm      80            qlen             15 5

650fAC                   call      'GETCLIENT'
650fAC                   parm                    client           10
650fAC                   parm                    clientloc        10

640bA /free

640bA    // Open printer file.
640bA      open(e) qsysprt;

640bA   endsr;

       //---------------------------------------------------------------
       //  getcurrstamp  Get current timestamps
       //---------------------------------------------------------------

       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

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

       //---------------------------------------------------------------
       //  getTraxRte    Get Trax route record
       //---------------------------------------------------------------

        begsr getTraxRte;

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
640eA    ttrser = ' ';

       endsr;

       //---------------------------------------------------------------
       //  setLogTime    Set appropriate log time fields
       //---------------------------------------------------------------

       begsr setLogTime;

         exsr getCurrStamp;

         ttlTS9   = currStampLoc;

       endsr;

       //---------------------------------------------------------------
       //  UpdateTTLog   Update log record
       //---------------------------------------------------------------

       begsr updateTTLog;

         keyttl.ttlWhse = $pwhse;
         keyttl.ttlrtid = (%subst($pfile:6:5));

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
650dA       ttlSer = ttrSer;

         exsr setLogTime;

         update(e) ttlrec;

         enddo;

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

            select;

            when name = 'returns';
               // Switch to StartReturns.
               http_parser_switch_cb(%addr(usrdta1)
                                     : %paddr(StartReturns)
                                     : %paddr(EndReturns));
               return;

            endsl;

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
640aD    //    ttusr  = attrval;
640fA          if attrval = 'N/A  ' or attrval = 'uid  ';
640fA            eval attrval = '99999';
640fA          endif;
640aM          drvId  = %dec(attrval:5:0);
            when attrname = 'routeID';
               ttrtid = attrval;
               ttrrti = attrval;
               ttprti = attrval;
               ttxrti = attrval;
650bA          ttfrri = attrval;
            when attrname = 'warehouseCode';
               ttwhse = %dec(attrval:3:0);
               ttrwhs = %dec(attrval:3:0);
               ttpwhs = %dec(attrval:3:0);
               ttxwhs = %dec(attrval:3:0);
650bA          ttfrwh = %dec(attrval:3:0);
            endsl;
            enddo;

         // Go get route

         chain %kds(keyrte) rtehed;
         if %found();
           ttrout = rhrte;
           ttrrte = rhrte;
           ttxrte = rhrte;
650bA      ttfrrt = rhrte;
           gRhrte = rhrte;
           ttrtru = rhtruk;
         else;
           rhrte  = ' ';
           ttrout = ' ';
           ttrrte = ' ';
           ttxrte = ' ';
650bA      ttfrrt = ' ';
           ttrtru = ' ';
         endif;

640aA    // Go get user id
640aA
640aA    chain (drvId) piruser1;
640aA    if %found();
640aA      ttusr = uscode;
640aA    else;
640aA      ttusr = %char(drvId);
640aA    endif;

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
640eA       when attrname = 'deviceSerialNumber';
640eA          ttrser = attrval;
            endsl;
            enddo;

640cA /end-free

640cA*  getDateTime  Get current date & time
640cAC                   eval      $cvcmd = '*CURCMD '
640cAC                   call      @cvtdt
640cAC                   parm                    $cvtdt
640cAC                   eval      ttrstd = $cvd8o
640cAC                   time                    ttrstt

640cA /free

            // Update or write Trax route record
              if TTrteUpdFlg = *on;
640cA          ttrusr = ttusr;
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
640dA          if hld_uci = *blanks;
640dA            hld_uci = '00000';
640dA          endif;
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
650aD    //    ttbflg = attrval;
650aM          hld_ttbflg = attrval;
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

650aA    // MOVED THIS LOGIC TO COME AFTER CHAIN TO ORDP
650aD    // Populate qty and uom fields for TTRTN file
650aD    //
650aD    //   if ttbflg = '0';
650aD    //     ttoqty = hld_qtypcs;
650aD    //     ttuom = hld_uomnormal;
650aD    //   else;
650aD    //     ttoqty = hld_qtybrkRtn;
650aD    //     ttuom = hld_uombrk;
650aD    //   endif;

         // Go get label#

650aA      orpwhs = 0;
650aA      orpord = 0;
650aA      orpsq# = 0;
           kywhse1 = ttwhse;
           kyrtid1 = ttrtid;
           kyuci  = ttuci;
         chain %kds(keyordp) ordp;
         if %found();
           ttolbl = orplbl;
         else;
           ttolbl = 0;
         endif;

650aA    // Write uploaded breakdown flag if not 0, as that means the
650aA    // driver changed it.

650aA    select;
650aA      when hld_ttbflg <> '0';
650aA        ttbflg = hld_ttbflg;

650aA      other;
650aA
650aA    // Write downloaded breakdown flag if uploaded breakdown flag
650aA    // is 0, as that means the driver didn't change it. Go to ORDD
650aA    // to determine what the downloaded breakdown flag was.
650aA
650aA      kywhse4 = orpwhs;
650aA      kyord4 = orpord;
650aA      kyseq4  = orpsq#;
650aA    chain %kds(keyordd) ordd;
650aA    if %found();
650aA      select;
650aA        when odqor1 > 0;
650aA          ttbflg = '0';
650aA        when odqor2 > 0;
650aA          ttbflg = '1';
650aA        when odqor3 > 0;
650aA          ttbflg = '2';
650aA      endsl;
650aA    else;
650aA      ttbflg = '0';
650aA    endif;
650aA    endsl;

650aA    // Populate qty and uom fields for TTRTN file
650aA
650aA    if hld_qtybrkRtn = 0;
650aA      ttoqty = hld_qtypcs;
650aA      ttuom = hld_uomnormal;
650aA    else;
650aA      ttoqty = hld_qtybrkRtn;
650aA      ttuom = hld_uombrk;
650aA    endif;

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

640eA  // Clear stop fields before writing new stop record
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
640eA          ttpgna = *blanks;
640eA          ttpgfn = *blanks;
640eA          ttpguc = *blanks;
640eA          ttpgsn = *blanks;
640eA          ttpgdt = 0;
640eA          ttpgtm = 0;

               write(e) ttprec;
             endif;
           endif;
         endif;

640eA    if name = 'SignatureCapture';
640eA      // Switch to StartSigEPM.
640eA      http_parser_switch_cb(%addr(usrdta1)
640eA                            : %paddr(StartSigEPM)
640eA                            : %paddr(EndSigEPM));
640eA      return;
640eA    endif;

         if name = 'Item';
            // Switch to StartItemEPM.
            http_parser_switch_cb(%addr(usrdta1)
                                  : %paddr(StartItemEPM)
                                  : %paddr(EndItemEPM));
            return;
         endif;

650bA    if name = 'StopFlag';
650bA       // Switch to StartStpFlgRsp.
650bA       http_parser_switch_cb(%addr(usrdta1)
                                  : %paddr(StartStpFlgRsp)
                                  : %paddr(EndStpFlgRsp));
650bA       return;
650bA    endif;

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

640eA *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
640eA *  StartSigEPM(): Specialized to gather 'stop signature' info
640eA *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
640eAP StartSigEPM     B
640eAD StartSigEPM     PI
640eAD   userdata                      *   value
640eAD   depth                       10I 0 value
640eAD   name                      1024A   varying const
640eAD   path                     24576A   varying const
640eAD   attrs                         *   dim(32767)
640eAD                                     const options(*varsize)

640eAD count           s             10I 0
640eAD attrname        s            100A   varying
640eAD attrval         s            100A   varying
640eAD text            s            132A

640eA /free

640eA       log(depth: name: path: 'StartSigEPM');

640eA  // Get signature capture data
640eA    if name = 'SignatureCapture';
640eA      count = 1;
640eA      dow attrs(count) <> *NULL;
640eA        attrname = %str(attrs(count));
640eA        count = count + 1;
640eA        attrval = %str(attrs(count));
640eA        count = count + 1;

640eA        select;
640eA          when attrname = 'signatureName';
640eA            hld_ttpgna = attrval;
640eA          when attrname = 'signatureFileName';
640eA            hld_ttpgfn = attrval;
640eA          when attrname = 'signatureSigneeNotFound';
640eA            hld_ttpgsn = attrval;
640eA          when attrname = 'signatureUseContact';
640eA            hld_ttpguc = attrval;
640eA          when attrname = 'signatureCaptured';
640eA            hld_timeStamp = attrval;
640eA            CCYY = timStmpCCYY;
640eA            MM = timStmpMM;
640eA            DD = timStmpDD;
640eA            HH = timStmpHH;
640eA            MIN = timStmpMIN;
640eA            SS = timStmpSS;
640eA            hld_ttpgdt = %dec(hld_CCYYMMDD:8:0);
640eA            hld_ttpgtm = %dec(hld_HHMMSS:6:0);
640eA        endsl;
640eA      enddo;

640eA    // Write or update Stop note file
640eA      if ttpstp > 0;
640eA        kywhse2 = ttwhse;
640eA        kyrtid2 = ttrtid;
640eA        kystop  = ttpstp;
640eA        chain %kds(keystp) ttstp;
640eA        ttprte = rhrte;
640eA        ttpgna = hld_ttpgna;
640eA        ttpgfn = hld_ttpgfn;
640eA        ttpgsn = hld_ttpgsn;
640eA        ttpguc = hld_ttpguc;
640eA        ttpgdt = hld_ttpgdt;
640eA        ttpgtm = hld_ttpgtm;
640eA        if %found();
640eA          update(e) ttprec;
640eA        else;

640eA  // Clear stop fields before writing new stop record
640eA      ttpscn = *blanks;
640eA      ttpsrd = 0;
640eA      ttpsrt = 0;
640eA      ttpfid = 0;
640eA      ttpfit = 0;
640eA      ttpqs1 = 0;
640eA      ttpqs2 = 0;
640eA      ttpqs3 = 0;
640eA      ttpqn1 = 0;
640eA      ttpqn2 = 0;
640eA      ttpqn3 = 0;
640eA      ttpqc1 = 0;
640eA      ttpqc2 = 0;
640eA      ttpqc3 = 0;
640eA      ttpqp1 = 0;
640eA      ttpqp2 = 0;
640eA      ttpqp3 = 0;

640eA          write(e) ttprec;
640eA        endif;
640eA      endif;
640eA    endif;

640eA    return;
640eA /end-free
640eAP                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
640eA *  EndSigEPM(): Specialized to gather 'stop signature' info
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
640eAP EndSigEPM       B
640eAD EndSigEPM       PI
640eAD   userdata                      *   value
640eAD   depth                       10I 0 value
640eAD   name                      1024A   varying const
640eAD   path                     24576A   varying const
640eAD   value                    65535A   varying const
640eAD   attrs                         *   dim(32767)
640eAD                                     const options(*varsize)

640eAD count           s             10I 0
640eAD attrname        s            100A   varying
640eAD attrval         s            100A   varying
640eAD text            s            132A

640eA /free

640eA       log(depth: name: path: 'EndSigEPM');

640eA    return;
640eA /end-free
640eAP                 E

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
640dA          if hld_uci = *blanks;
640dA            hld_uci = '00000';
640dA          endif;
               hld_ttxtrx = %dec(hld_uci:5:0);
            when attrname = 'unitMeasure';
               hld_um = attrval;
            when attrname = 'operationFlag';
               hld_opflg = attrval;
            when attrname = 'initialBreakDownFlag';
               hld_ttxibf = attrval;
650eD    // when attrname = 'scanStamp';
650eM       when attrname = 'deliveredStamp';
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

650bA *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
650bA *  StartStpFlgRsp(): Specialized to gather 'stop flag response' info
650bA *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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

650bA *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
650bA *  EndStpFlgRsp(): Specialized to gather 'stop flag response' info
650bA *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
