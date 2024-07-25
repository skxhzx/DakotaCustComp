      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     *  TAXR      Creates file to ftp to Tax-Right
     *  28 June 2006
     *  Robin Clark
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions:
     *
510 A*    06/28/06  RMC  5.10
     *      - Created.
     *        Client custom support included.
510aA*    08/03/06  MLB  5.10a
     *      - Enh: Changed program to use PLTSUM9 instead of PLTSUM8.
     *      - Enh: Changed program to use LABEL90 instead of LABEL13.
     *      - Enh: Revised program to call TAXRFTP program after
     *        each transaction/order is written to the TAXRDATA file.
     *        Only 1 order/file is allowed for Tax Right.
510bA*    08/04/06  RMC  5.10b
     *      - Mod: Changed program to create 12 digit stamping.
510cA*    08/08/06  MLB  5.10c
     *      - Fix: Revsied program to left-justify invoice number.
510dA*    08/10/06  DAS  5.10d
     *      - Fix: Changed $taxupc to alpha. TaxRite wanted it left
     *        justified with blank on right side.
510eA*    12/17/06  JCJ  5.10e
     *      - Enh: Do not call TAXRFTP when $pcmd = '*CREATE' and
     *             client = 'HARBOR'.
     *      - Enh: add TXFTPLOG file.
     *      - Enh: add $pcmd = '*SNDTRN' processing.
510fA*    01/05/07  MLB  5.10f
     *      - Fix: Revised program to skip all PLTSUM9 records that
     *        have zero transaction number.
520 A*    04/17/09  JCJ  5.20
     *      - Fix: Revised program to not create an initial TXFTPLOG
     *        record because that was already done in TAXRFTP.
640aA*    09/28/11  JCJ  6.40a
     *      - Fix: Revised to make stamp unit number unique.
640bA*    10/05/11  JCJ  6.40b
     *      - Enh: Revised program to not reset sequence number when
     *        the order number changes inside a tote transaction.
     *        This was done to provide support for multiple orders
     *        per tote. Also, this change ensure that header/detail
     *        records are sorted correctly.
640cA*    02/28/12  JCJ  6.40c
     *      - Enh: Softcode zone specifications.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CTW A*    11/04/08  JCJ  CTW A
     *      - Enh: add Citywholesale client ID
     *
CTWaA*    11/05/08  JCJ  CTWaA
     *      - Enh: add Cig011 & Cig091 tobacco zones
     *
CTWbA*    11/10/08  JCJ  CTWbA
     *      - Enh: add code to break out ommsc2 with the
     *        state, county, city jurisdiction codes
     *
CTWcA*    11/12/08  JCJ  CTWcA
     *      - Enh: add last 4 digits of slot to detail record
     *
CTWdA*    11/13/08  JCJ  CTWdA
     *      - Enh: add Cig011 & Cig091 tobacco zones to zzcreate
     *
CTWeA*    11/20/08  JCJ  CTWeA
     *      - Enh: shuffle jurisdiction codes.
     *             001 002 003 will become 010 020 003
     *             |      A
     *             |______|
     *
CTWfA*    11/21/08  JCJ  CTWfA
     *      - Fix: changed move to movel.
CTWg *    11/26/08  HNK  CTWg
     *      - Enh: Do not create Taxright file for CIG091 zone.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Harbor
     *
HAR A*    11/04/08  HAR  HAR A
     *      - Enh: add Harbor client ID
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Finkle
     *
FDI A*    02/05/09  JCJ  FDI A
     *      - Enh: add Finkle client ID
     *
FDIaA*    04/02/09  JCJ  FDIa
     *      - Enh: add cigarett zone.
     *      - Enh: load upc & juisdistric fields.
FDIbA*    04/20/09  MLB  FDIb
     *      - Enh: Revised mainline to call ZZSNDTRN_All after
     *        ZZCREATE when cmd is *CREATE so the files
     *        will be sent automatically to TaxRight.
FDIcA*    04/20/09  MLB  FDIc
     *      - Enh: Revised GETHEADER, GETHEADER2 to leave leading
     *        zeros on transaction number so barcode scanned in
     *        TaxRight will find file.
FDIdA*    04/28/09  JCJ  FDId
     *      - Enh: changed cigarett zone from DRYC to CIGS
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Silberman
     *
SLBaA*    09/08/11  JCJ  SLBaA
     *      - Enh: add Silberman client ID
     *      - Enh: add cigarette zones.
     *
SLBbA*    09/27/11  JCJ  SLBbA
     *      - Enh: change stamping unit number to Order/seqn instead
     *             of transaction number.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash-WA
     *
CWDaA*    03/04/12  JCJ  CWDaA
     *      - Enh: add Cash-Wa client ID
CWDbA*    03/17/12  JCJ  6.40d
     *      - Enh: Changed to use trax number for stamping unit number
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *
     *    Input Parameters
     *      $pwhse       Warehouse number
     *      $prteid      Route id
     *      $prte        Customer route number
     *      $ptrn#       Transaction Number
     *
     *    Output Parameters
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

510aMFpltsum9   if   e           k disk
640cAFpltsum8   if   e           k disk    rename(psrec:psrec8) prefix(b)
640cAFoptionz   if   e           k disk
640cAFtruckh    if   e           k disk
510aMFlabel90   if   e           k disk
     Fordh      if   e           k disk
     Forddm     if   e           k disk
     Fpiritem   if   e           k disk
510eAFtaxrdata  o    e           k disk
510eAFtaxrstmp  if a e           k disk
640aAFtaxrstmp2 if   e           k disk    rename(tstmp:tstmp2) prefix(a)
510eAFtxftplog  if a e           k disk
510eMFtxftplog3 if a e           k disk    rename(txftpr:txftp3)

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10
HAR AD/COPY QCOPYSRC,ID#HARBOR
CTW AD/copy qcopysrc,id#citywho
FDI AD/copy qcopysrc,id#finkle
SLBaAD/copy qcopysrc,id#silberm
CWDaAD/copy qcopysrc,id#cashwa

640cA*----------------------------------------------------------------
640cA*  *PICKLBL  -  Picking label options
640cA*----------------------------------------------------------------
640cA*
640cA* Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
     *    OPPDEV  -  Printer device.
     *    OPPFRM  -  Printer form.
     *    OPAISL  -  Print aisle change label (Y/N).
     *    OPTAXR  -  Include in Tax Right (Y=Yes, N=No).
     *    OPCHKR  -  Include in Check Right (Y=Yes, N=No).
     *
     * Data structure
     *
     D opdta2          ds
     D  opclvl                 1      3  0
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0
     D  opcwgt                53     54  0
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  opaisl                85     85
     D  optaxr                86     86
     D  opchkr                87     87
     D  optend               117    117
     *----------------------------------------------------------------
     *  Data conversion data structure
     *----------------------------------------------------------------

     D currdatestamp   s               z

     D dateconv        ds
     D  tsdatetime             1     26
     D  tsyear                 1      4
     D  tsmonth                6      7
     D  tsday                  9     10
     D  tshour                12     13
     D  tsmin                 15     16
     D  tssec                 18     19
     D  tssbsec               21     26

     *----------------------------------------------------------------
     *  Tax-Right Header record data structure
     *----------------------------------------------------------------
     D $taxheader      ds

1    D  $taxhrectype                  1    Inz('H')
2    D  $taxstampunit                16
18   D  $taxcustname                 30
48   D  $taxcustnum                  10s 0
58   D  $taxjurisdict                14
72   D  $taxinvnum                   16
88   D  $taxlineitems                 3s 0 Inz(0)
     D  $taxmisc1                    16
     D  $taxmisc2                    16
     D  $taxmisc3                    16
     D  $taxmisc4                    16
     D  $taxmisc5                    16

     *----------------------------------------------------------------
     *  Tax-Right Detail record data structure
     *----------------------------------------------------------------

     D $taxdetail      ds

     D  $taxdrectype                  1    Inz('D')
     D  $taxlinenum                   3s 0 Inz(0)
510dDD* $taxupc                      12s 0
510dMD  $taxupc                      12
     D  $taxdesc                     30
     D  $taxcartqty                   4s 0
CTWcAD  $taxslot                      4

     *----------------------------------------------------------------
     *  Re-definition data structures
     *----------------------------------------------------------------

     D                 ds
510bMD  txstampt                     12
510bMD   txcordtmp                    9s 0 overlay(txstampt:1)
510bMD   txordseq                     3s 0 overlay(txstampt:10)
ctwbAD  txstamptn                    12s 0
510aAD txseq#          s              3s 0 inz(0)

     D                 ds
     D  txexpdata                   256
     D  taxlineitems                  3s 0 overlay(txexpdata:88)

     D                 ds
     D  ommsc1                       40
     D   ommupc1                      6    overlay(ommsc1:15)
     D   ommupc2                      5    overlay(ommsc1:26)
     D   ommjur                       2    overlay(ommsc1:31)

ctwbA*----------------------------------------------------------------
ctwbA*  Misc field mappings
ctwbA*----------------------------------------------------------------

ctwbA /Copy qcopysrc,orddm2_ctw
ctwbA /Copy qcopysrc,orddm5_ctw
fdiaA /Copy qcopysrc,orddm2_rtx
fdiaA /Copy qcopysrc,orddm3_rtx
cwdaA /Copy qcopysrc,orddm1_cwd
cwdaA /Copy qcopysrc,orddm2_cwd

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d ommupc1and2c    s             11
     d ommupc1and2n    s             11s 0
     d savestop1       s                   like(psstp1)
     d saveorder#      s              7s 0 inz(0000000)
     d writeheader     s               n   inz(*off)
     d wroterecord     s               n   inz(*off)
CTWaD *tobaccozone     s              6    inz('TOBACO')
CTWaMd tobaccozone     s              6
CTWaAd tobacco         s              6    inz('TOBACO')
CTWaAd cig011          s              6    inz('CIG011')
CTWaAd cig091          s              6    inz('CIG091')
SLBaAd cig19           s              6    inz('CIG-19')
SLBaAd cig21           s              6    inz('CIG-21')
fdidD *** cig             s              6    inz('DRYC  ')
fdidMd cig             s              6    inz('CIGS  ')
510eAd $pwhse          s              3  0
510eAd xswhse          s              3  0
510eAd $prteid         s              5
510eAd $prte           s              5
510eAd $ptrn#          s              7  0
510eAd xstrn#          s              7  0
510eAd $pcmd           s              8
510eAd $pmbr           s             10
510eAd $pfile          s             30
510eAd $rrtn           s             10
510eAd $rmsg           s             30
510eAD currstamp       s               z
     D kycode          s                   like(opzcod)
510eAD kytype          s                   like(pftype)
CTWcAD len             S              3s 0 inz(0)
CTWcAD start           S              3s 0 inz(0)
CTWeAd $wrk9           s              9
CTWeAd w3              s              3
CTWeAd w2              s              2
CTWeAd w1              s              1
640cAD kyzone          s                   like(opzzon)
640cAD $ptmpl          s             10

     *----------------------------------------------------------------
     *  Program information data structure.
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $pcmd
     C                   parm                    $prteid
     C                   parm                    $prte
     C                   parm                    $ptrn#

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     c                   exsr      zzinz2

510eAc                   select
510eAc                   when      $pcmd = '*CREATE'
CTWaAC                             and client = harbor
CTWaAC                   eval      tobaccozone = tobacco
510eAc                   exsr      zzcreate

CTWaAc                   when      $pcmd = '*CREATE'
CTWaAc                             and client = citywholesale
640cD **                 eval      tobaccozone = cig011
640cAc                   exsr      zzcreatenew
CTWg c**                 eval      tobaccozone = cig091
CTWg c**                 exsr      zzcreate

FDI Ac                   when      $pcmd = '*CREATE'
FDI Ac                             and client = finkle
fdiaAc                   eval      tobaccozone = cig
FDI Ac                   exsr      zzcreate
FDIbA*
FDIbA*      Force created transactions over to TaxRight.
FDIbAc                   eval      $pcmd = '*SNDTRN '
FDIbAc                   exsr      zzsndtrn_all

SLBaAc                   when      $pcmd = '*CREATE'
SLBaAc                             and client = silberman
SLBaAc                   eval      tobaccozone = cig19
SLBaAc                   exsr      zzcreate
SLBaAc                   eval      tobaccozone = cig21
SLBaAc                   exsr      zzcreate

CWDaAc                   when      $pcmd = '*CREATE'
CWDaAc                             and client = cashwa
CWDaAc                             and clientloc = cashwakearney
CWDaAc                   exsr      zzcreatenew

510eAc                   when      $pcmd = '*SEND  '
CTWaAC                             and client = harbor
CTWaAC                   eval      tobaccozone = tobacco
510eAc                   exsr      zzsend

CTWaAc                   when      $pcmd = '*SEND  '
CTWaAc                             and client = citywholesale
CTWaAc                   eval      tobaccozone = cig011
CTWaAc                   exsr      zzsend
CTWgM **                 eval      tobaccozone = cig091
CTWgM **                 exsr      zzsend

FDI Ac                   when      $pcmd = '*SEND  '
FDI Ac                             and client = finkle
fdiaAc                   eval      tobaccozone = cig
FDI Ac                   exsr      zzsend

SLBaAc                   when      $pcmd = '*SEND  '
SLBaAc                             and client = silberman
SLBaAc                   eval      tobaccozone = cig19
SLBaAc                   exsr      zzsend
SLBaAc                   eval      tobaccozone = cig21
SLBaAc                   exsr      zzsend

CWDaAc                   when      $pcmd = '*SEND  '
CWDaAc                             and client = cashwa
CWDaAc                             and clientloc = cashwakearney
CWDaAc                   eval      tobaccozone = 'CIGS'
CWDaAc                   exsr      zzsend

510eAc                   when      $pcmd = '*SNDTRN'
510eAc                   exsr      zzsndtrn
510eAc                   endsl
510eAc                   return

     *----------------------------------------------------------------
     *          Subroutines
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  getdetail Get detail records
     *----------------------------------------------------------------

     C     getdetail     begsr

     C                   eval      $taxcartqty = 0
510aAC                   eval      saveorder#= -1

510aMC     keyl90        setll     label90
     C                   dou       forever <> forever
510aMC     keyl90        reade     label90

     C                   select
510aMC                   when      %eof(label90)
510aDc                   exsr      processheader
     c                   leave

     C                   other
     c                   if        lbord <> saveorder#
     c                   exsr      getheader
     c                   endif

     C                   eval      $taxcartqty = lbqpck
     C                   eval      txtrn# = lbtrn#

     c     keyordd3      chain     orddm
     C                   if        %found(orddm)
ctwbAC                   eval      ctwdm2_base = ommsc2
ctwbAC                   eval      ctwdm5_base = ommsc5
fdiaAC                   eval      rtxdm2_base = ommsc2
fdiaAC                   eval      rtxdm3_base = ommsc3
cwdaAC                   eval      cwddm1_base = ommsc1
cwdaAC                   eval      cwddm2_base = ommsc2

CTWbAC                   select
     * harbor
CTWbAC                   when      client = harbor
     C                   eval      $taxjurisdict = ommjur

     C                   eval      ommupc1and2c = ommupc1 + ommupc2
     C                   move      ommupc1and2c  ommupc1and2n
510dDC**                 eval      $taxupc     = ommupc1and2n
510dMC                   eval      $taxupc = %trim(ommupc1and2c)
     * city wholesale
CTWbAc                   when      client = citywholesale
CTWeAC                   eval      $wrk9 = ctwdm2_stjurc +
CTWbAC                                     ctwdm2_cojurc +
CTWbAC                                     ctwdm2_cijurc

CTWeAC                   eval      w3 = %subst($wrk9:2:3)
CTWeAC                   eval      w2 = %subst($wrk9:5:2)
CTWeAC                   eval      w1 = %subst($wrk9:1:1)

CTWeAC                   eval      $taxjurisdict = w3 +
CTWeAC                                             w2 +
CTWeAC                                             w1 +
CTWeAC                                             ctwdm2_cijurc

ctwbAC                   eval      $taxupc = ctwdm5_upc
     * finkle
FDI Ac                   when      client = finkle
fdiaAC                   eval      $taxjurisdict = %subst(rtxdm2_omtnme:1:14)
fdiaAC                   eval      $taxupc = %subst(rtxdm3_omupcn:1:12)
     * AJ Silberman
SLBaAc                   when      client = silberman
SLBaAC                   eval      $taxjurisdict = %subst(rtxdm2_omtnme:1:14)
SLBaAC                   eval      $taxupc = %subst(rtxdm3_omupcn:1:12)
     * Cash-Wa Kearney
CWDaAc                   when      client = cashwa
CWDaAc                             and clientloc = cashwakearney
CWDaAC                   eval      $taxjurisdict = %subst(ommsc2:4:15)
CWDaAC                   eval      $taxupc = %subst(ommsc1:28:8)
CTWbAC                   endsl
     c                   endif

     c     keyitem       chain     piritem
     C                   if        %found(piritem)
     C                   eval      $taxdesc = itdesc
     c                   else
     C                   eval      $taxdesc = *blanks
     c                   endif

     C                   eval      txseq# = txseq# + 1
     c                   eval      $taxlineitems = $taxlineitems + 1
     C                   eval      $taxlinenum = $taxlinenum + 1

CTWcA*      Find right most ' ', grab last 4 non blanks of slot.
CTWcAC                   eval      len = %checkr(' ':lbdisp)
CTWcAC                   if        len < 4
CTWcAC                   eval      start = 1
CTWcAC                   else
CTWcAC                   eval      start = len - 3
CTWcAC                   endif
CTWcAC                   eval      $taxslot = %subst(lbdisp:start:4)

     c                   eval      txexpdata =  $taxdetail
     C                   write(e)  taxrec
     c                   eval      wroterecord = *on

     c                   eval      saveorder# = lbord

     C                   endsl
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  getdetail2 Get detail records
     *----------------------------------------------------------------

     C     getdetail2    begsr

     C                   eval      $taxcartqty = 0
     C                   eval      saveorder#= -1

     C     keyl90        setll     label90
     C                   dou       forever <> forever
     C     keyl90        reade     label90

     C                   select
     C                   when      %eof(label90)
     c                   exsr      processheader
     c                   leave

     C                   other
     c                   if        lbord <> saveorder#
     c                   exsr      getheader2
     c                   endif

     C                   eval      $taxcartqty = lbqpck
     C                   eval      txtrn# = lbtrn#

     c     keyordd3      chain     orddm
     C                   if        %found(orddm)
ctwbAC                   eval      ctwdm2_base = ommsc2
ctwbAC                   eval      ctwdm5_base = ommsc5
fdiaAC                   eval      rtxdm2_base = ommsc2
fdiaAC                   eval      rtxdm3_base = ommsc3
cwdaAC                   eval      cwddm1_base = ommsc1
cwdaAC                   eval      cwddm2_base = ommsc2
CTWaAC                   select
     * harbor
CTWaAC                   when      client = harbor
     C                   eval      $taxjurisdict = ommjur
     C                   eval      ommupc1and2c = ommupc1 + ommupc2
     C                   move      ommupc1and2c  ommupc1and2n
     C                   eval      $taxupc = %trim(ommupc1and2c)
     * city wholesale
CTWaAc                   when      client = citywholesale
CTWeAC                   eval      $wrk9 = ctwdm2_stjurc +
CTWbAC                                     ctwdm2_cojurc +
CTWbAC                                     ctwdm2_cijurc

CTWeAC                   eval      w3 = %subst($wrk9:2:3)
CTWeAC                   eval      w2 = %subst($wrk9:5:2)
CTWeAC                   eval      w1 = %subst($wrk9:1:1)

CTWeAC                   eval      $taxjurisdict = w3 +
CTWeAC                                             w2 +
CTWeAC                                             w1 +
CTWeAC                                             ctwdm2_cijurc
ctwbAC                   eval      $taxupc = ctwdm5_upc
     * finkle
FDI Ac                   when      client = finkle
fdiaAC                   eval      $taxjurisdict = %subst(rtxdm2_omtnme:1:14)
fdiaAC                   eval      $taxupc = %subst(rtxdm3_omupcn:1:12)
     * AJ Silberman
SLBaAc                   when      client = silberman
SLBaAC                   eval      $taxjurisdict = %subst(rtxdm2_omtnme:1:14)
SLBaAC                   eval      $taxupc = %subst(rtxdm3_omupcn:1:12)
     * Cash-Wa Kearney
CWDaAc                   when      client = cashwa
CWDaAc                             and clientloc = cashwakearney
CWDaAC                   eval      $taxjurisdict = %subst(ommsc2:4:15)
CWDaAC                   eval      $taxupc = %subst(ommsc2:28:12)
SLBaAC                   endsl
     c                   endif

     c     keyitem       chain     piritem
     C                   if        %found(piritem)
     C                   eval      $taxdesc = itdesc
     c                   else
     C                   eval      $taxdesc = *blanks
     c                   endif

     C                   eval      txseq# = txseq# + 1
     c                   eval      $taxlineitems = $taxlineitems + 1
     C                   eval      $taxlinenum = $taxlinenum + 1

CTWcA*      Find right most ' ', grab last 4 non blanks of slot.
CTWcAC                   eval      len = %checkr(' ':lbdisp)
CTWcAC                   if        len < 4
CTWcAC                   eval      start = 1
CTWcAC                   else
CTWcAC                   eval      start = len - 3
CTWcAC                   endif
CTWcAC                   eval      $taxslot = %subst(lbdisp:start:4)

     c                   eval      txexpdata =  $taxdetail
     C                   write(e)  taxrec
     c                   eval      wroterecord = *on

     c                   eval      saveorder# = lbord

     C                   endsl
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  getheader get order header record and create header record.
     *----------------------------------------------------------------

     C     getheader     begsr

     C     keyordh       chain     ordh
     C                   if        %found(ordh)

640bA* Only reset sequence number on first pass of transaction number.

640bAC                   if        saveorder# = -1
     C                   eval      txseq# = 1
640bAC                   endif

     C                   eval      $taxcustname = ohcnam
     C                   eval      $taxcustnum = ohcust
510cMC                   movel     ohcord        $taxinvnum
     C                   eval      txwhse = $pwhse
     C                   eval      txrtid = $prteid
     C                   eval      txcord# = ohcord
510bMC                   eval      txcordtmp = txcord#
510aAC                   eval      txordseq = txordseq + 1

ctwbAC                   select
ctwbAc                   when      client = harbor
     C                   eval      $taxstampunit = txstampt
     C                   eval      txstamp = txstampt

ctwbAc                   when      client = citywholesale
ctwfAC                   movel     txstampt      txstamptn
ctwbAC                   eval      $taxstampunit = %char(txstamptn)
ctwbAC                   eval      txstamp = %char(txstamptn)
     * finkle
FDI Ac                   when      client = finkle
FDIcDC*                  eval      $taxstampunit = %char(xstrn#)
FDIcMC                   eval      $taxstampunit = %editc(xstrn#:'X')
FDIcDC*                  eval      txstamp = %char(xstrn#)
FDIcMC                   eval      txstamp = %editc(xstrn#:'X')
     * AJ Silberman
SLBaAc                   when      client = silberman
SLBbD ***                eval      $taxstampunit = %trim(%editc(xstrn#:'4'))
SLBbD ***                eval      txstamp = %trim(%editc(xstrn#:'4'))
SLBbAC                   movel     txstampt      txstamptn
SLBbAC                   eval      $taxstampunit = %char(txstamptn)
SLBbAC                   eval      txstamp = %char(txstamptn)
SLBaMC                   eval      $taxinvnum = %trim(%editc(ohcord:'4'))
     * Cash-Wa Kearney
CWDaAc                   when      client = cashwa
CWDaAc                             and clientloc = cashwakearney
CWDaAC                   movel     txstampt      txstamptn
CWDaAC                   eval      $taxstampunit = %char(txstamptn)
CWDaAC                   eval      txstamp = %char(txstamptn)
CWDaAC                   eval      $taxinvnum = %trim(%editc(ohcord:'4'))
ctwbAC                   endsl

     C                   eval      txrte  = $prte
     C                   time                    txaddts
     C                   time                    currdatestamp
     C                   eval      tsdatetime = %char(currdatestamp)

     c                   eval      writeheader = *on
510aAC                   eval      saveorder# = lbord

     C                   endif

     C                   endsr

510eA*----------------------------------------------------------------
510eA*  getheader2 get order header record and create header record.
510eA*----------------------------------------------------------------

510eAC     getheader2    begsr

510eAC     keyordh       chain     ordh
510eAC                   if        %found(ordh)

640bA* Only reset sequence number on first pass of transaction number.

640bAC                   if        saveorder# = -1
510eAC                   eval      txseq# = 1
640bAC                   endif

510eAC                   eval      $taxcustname = ohcnam
510eAC                   eval      $taxcustnum = ohcust
510eAC                   movel     ohcord        $taxinvnum
510eAC                   eval      txwhse = $pwhse
510eAC                   eval      txrtid = $prteid
510eAC                   eval      txcord# = ohcord
510eAC                   eval      txcordtmp = txcord#

510eAC     keyl90        chain     taxrstmp
510eAC                   if        %found(taxrstmp)

ctwbAC                   select
ctwbAc                   when      client = harbor
510eAC                   eval      $taxstampunit = tsstamp
510eAC                   eval      txstamp = tsstamp

ctwbAc                   when      client = citywholesale
ctwfAC                   movel     tsstamp       txstamptn
ctwbAC                   eval      $taxstampunit = %char(txstamptn)
ctwbAC                   eval      txstamp = %char(txstamptn)
     * finkle
FDI Ac                   when      client = finkle
FDIcDC*                  eval      $taxstampunit = %char(tstrn#)
FDIcMC                   eval      $taxstampunit = %editc(xstrn#:'X')
FDIcDC*                  eval      txstamp = %char(tstrn#)
FDIcMC                   eval      txstamp = %editc(tstrn#:'X')
     * AJ Silberman
SLBaAc                   when      client = silberman
SLBbD ***                eval      $taxstampunit = %trim(%editc(xstrn#:'4'))
SLBbD ***                eval      txstamp = %trim(%editc(xstrn#:'4'))
SLBbAC                   movel     tsstamp       txstamptn
SLBbAC                   eval      $taxstampunit = %char(txstamptn)
SLBbAC                   eval      txstamp = %char(txstamptn)
SLBaMC                   eval      $taxinvnum = %trim(%editc(ohcord:'4'))
     * Cash-Wa Kearney
CWDaAc                   when      client = Cashwa
CWDaAc                             and clientloc = Cashwakearney
CWDaAC                   movel     tsstamp       txstamptn
CWDaAC                   eval      $taxstampunit = %char(txstamptn)
CWDaAC                   eval      txstamp = %char(txstamptn)
CWDaMC                   eval      $taxinvnum = %trim(%editc(ohcord:'4'))
ctwbAC                   endsl
510eAC                   endif

510eAC                   eval      txrte  = $prte
510eAC                   time                    txaddts
510eAC                   time                    currdatestamp
510eAC                   eval      tsdatetime = %char(currdatestamp)

510eAc                   eval      writeheader = *on
510eAC                   eval      saveorder# = lbord

510eAC                   endif

510eAC                   endsr

510eA*----------------------------------------------------------------
510eA*  createstamp  Create stamping unit number.
510eA*----------------------------------------------------------------

510eAC     createstamp   begsr

510eAc     keyl902       chain     label90

510eAC     keyordh       chain     ordh
510eAC                   if        %found(ordh)

510eAC                   eval      txcord# = ohcord
510eAC                   eval      txcordtmp = txcord#
510eAC                   eval      txordseq = txordseq + 1
640aAC                   exsr      getnxtstamp

510eAC                   eval      saveorder# = lbord

510eAC                   eval      tswhse = $pwhse
510eaC                   eval      tsrtid = psrtid
510eAC                   eval      tstrn# = pstrn#

CWDbAC                   Select
CWDbAC                   when      client = cashwa
CWDbAC                   eval      tsstamp = '00' + $ptraxnumber
CWDbAC                   other
510eAC                   eval      tsstamp = txstampt
CWDbAC                   endsl

510eAC                   write     tstmp

510eAC                   endif

510eAC                   endsr

640aA*----------------------------------------------------------------
640aA*  Getnxtstamp   Get next stamping unit number
640aA*----------------------------------------------------------------

640aAC     getnxtstamp   begsr

640aAC     kystmp        setll     taxrstmp2
640aAC                   dou       %eof(taxrstmp2)
640aAC     kystmp        reade     taxrstmp2
640aAC                   if        not %eof(taxrstmp2)
640aAC                   eval      txordseq = txordseq + 1
640aAC                   eval      tsstamp = txstampt
640aAC     kystmp        setll     taxrstmp2
640aAC                   endif
640aAC                   enddo

CWDbAC                   if        client = cashwa
CWDbAC                   call      'GETTOTTRAX'
CWDbAC                   parm                    $pwhse
CWDbAC                   parm                    $prteid
CWDbAC                   parm                    pstrn#
CWDbAC                   parm      *blanks       $ptraxnumber     10
CWDbAC                   endif

640aAC                   endsr

510eA*----------------------------------------------------------------
510eA*  Gettxrec      Get TX FTP Status record.
510eA*----------------------------------------------------------------

510eAC     gettxrec      begsr

510eAC     txftpky3      chain     txftplog3
510eAC                   select
510eAC                   when      not %found(txftplog3)
510eAC                   eval      pfwhse = $pwhse
510eAC                   eval      pfrtid = $prteid
510eAC                   eval      pfrte  = $prte
510eAC                   eval      pftype = kytype
510eAC                   eval      pftrn# = pstrn#
510eAC                   eval      pffsts = '1'
510eAC                   eval      pflusr = #user
510eAC                   time                    currstamp
510eAC                   eval      pfaddts= currstamp
510eAC                   write     txftp3
510eAC                   endsl

510eAC     endgettxrec   endsr

     *----------------------------------------------------------------
     *  processheader - Write header record.
     *----------------------------------------------------------------

     C     processheader begsr

     c                   if        writeheader
     C                   eval      txseq# = 1
510aMC                   eval      txtrn# = xstrn#
     c                   eval      txexpdata =  $taxheader
     C                   write(e)  taxrec
510aA*
510aA*      Send customer order via FTP to Tax-Right.
510eA*
510eAc                   select
510eAc                   when      client = 'HARBOR'
CTW AC                             or client = citywholesale
FDI AC                             or client = finkle
SLBaAC                             or client = silberman
CWDaAC                             or client = cashwa
CWDaAC                             and clientloc = cashwakearney
510eAc                   if        $pcmd <> '*CREATE'
510eAc                   exsr      proctaxrftp
510eAc                   endif
510eAc                   other
510aAc                   exsr      proctaxrftp
510eAc                   endsl
510aA*
     C                   eval      $taxlinenum = 0
     c                   eval      $taxlineitems = 0
     c                   endif

     C                   endsr
510aA
510aA*----------------------------------------------------------------
510aA*  procetaxrftp - Process Tax Right FTP.
510aA*----------------------------------------------------------------

510aAC     proctaxrftp   begsr

510aA*    Call FTP program to send file to Tax-Right.
510aAC                   call      'TAXRFTP'
510aAC                   parm                    $pcmd
510aAC                   parm                    $pwhse
510aAC                   parm                    $prteid
510aAC                   parm                    $prte
510aAC                   parm                    $ptrn#
510aAC                   parm      *blanks       $pmbr
510aAC                   parm      *blanks       $pfile
510aAC                   parm      *blanks       $rrtn
510aAC                   parm      *blanks       $rmsg

510aAC                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Extra program initialization.
     *----------------------------------------------------------------

     c     zzinz2        begsr

     * Key definitions

640cA*  Define partial key for PLTSUM9 file.

640cAc     keyps8        klist
640cAc                   kfld                    $pwhse
640cAc                   kfld                    $prteid

510aA*  Define partial key for PLTSUM9 file.

510aAc     keyps9        klist
510aAc                   kfld                    $pwhse
510aAc                   kfld                    $prteid
510aAc                   kfld                    tobaccozone

640cA*  Define partial key for PLTSUM9 file.

640cAc     keyps9b       klist
640cAc                   kfld                    $pwhse
640cAc                   kfld                    $prteid
640cAc                   kfld                    bpsszon

     *  Define partial key for LABEL13 file.

     c     keyl13        klist
     c                   kfld                    pswhse
     c                   kfld                    psrtid
     c                   kfld                    psplid

510aA*  Define partial key for LABEL90 file.

510aAc     keyl90        klist
510eMc                   kfld                    xswhse
510eMc                   kfld                    xstrn#

510eA*  Define partial key for LABEL90 file.

510eAc     keyl902       klist
510eMc                   kfld                    pswhse
510eMc                   kfld                    pstrn#

     *  Define key for ORDH file.

     c     keyordh       klist
     c                   kfld                    lbwhse
     c                   kfld                    lbord

     *  Define key for ORDD3 and ORDDM files.

     c     keyordd3      klist
     c                   kfld                    lbwhse
     c                   kfld                    lbord
     c                   kfld                    lbseq
     c                   kfld                    lbitem

     *  Define key for PIRITEM file.

     c     keyitem       klist
     c                   kfld                    lbwhse
     c                   kfld                    lbitem
510eA*
510eA*  Define full key for TXFTPLOG file
510eA*
510eAc     txftpky       klist
510eAc                   kfld                    $pwhse
510eAc                   kfld                    $prteid
510eAc                   kfld                    kytype

510eA*
510eA*  Define full key for TXFTPLOG3 file
510eA*
510eAc     txftpky3      klist
510eAc                   kfld                    $pwhse
510eAc                   kfld                    $prte
510eAc                   kfld                    $prteid
510eAc                   kfld                    $ptrn#
FDIbA*
FDIbA*  Define partial key for TXFTPLOG3 file
FDIbA*
FDIbAc     txftpky3a     klist
FDIbAc                   kfld                    $pwhse
FDIbAc                   kfld                    $prte
FDIbAc                   kfld                    $prteid

640aAc     kystmp        klist
640aAc                   kfld                    $pwhse
640aAc                   kfld                    $prteid
640aAc                   kfld                    tsstamp
     *
640cA*  Define partial key for options file.
     *
     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
     C                   kfld                    $ptmpl
     C                   kfld                    kyzone
640cA*
640cA*  Define key for TRUCKH file.
640cA*
640cAC     keyth         klist
640cAC                   kfld                    $pwhse
640cAC                   kfld                    bpstruk

     *  Set initial values.
     c                   eval      txseq# = 0
510eAc                   eval      xswhse = $pwhse

     c                   endsr
     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Get client id

     c                   call      'GETCLIENT'
     c                   parm                    client
     c                   parm                    clientloc

     c                   endsr

510eA*----------------------------------------------------------------
510eA*  zzcreate  create txftplog records only
510eA*----------------------------------------------------------------

510eAc     zzcreate      begsr

510aAC                   eval      savestop1 = -1
510eAc     keyps9        setll     pltsum9
510eAc                   dou       forever <> forever
510eAc     keyps9        reade     pltsum9

510eAc                   select
510eAc                   when      %eof(pltsum9)
510eAc                   leave

510fA
510fA*    Skip all empty pallets.
510fAC                   when      pstrn# <= 0
510fAc                   iter
510fA
510eAc                   other
510eAc                   if        psstp1 <> savestop1
510eAc                   eval      txordseq = 0
510aAc                   eval      savestop1 = psstp1
510aAc                   endif

510eAc                   eval      kytype = '03'
510eAc                   exsr      gettxrec
510eAc                   exsr      createstamp

510eAc                   endsl

510eAc                   enddo

510eAC     endcreate     endsr

640cA*----------------------------------------------------------------
640cA*  zzcreatenew  create txftplog records only
640cA*----------------------------------------------------------------

640cAc     zzcreatenew   begsr

     c     keyps8        setll     pltsum8
     c                   dou       forever <> forever
     c     keyps8        reade     pltsum8

     c                   if        %eof(pltsum8)
     c                   leave
     c                   endif

     c                   exsr      zzgetpicklbl

     c                   if        optaxr = 'Y'
     c                   eval      tobaccozone = bpsszon

     c                   eval      savestop1 = -1
     c     keyps9        setll     pltsum9
     c                   dou       forever <> forever
     c     keyps9        reade     pltsum9

     c                   select
     c                   when      %eof(pltsum9)
     c                   leave

     *    Skip all empty pallets.
     C                   when      pstrn# <= 0
     c                   iter

     c                   other
     c                   if        psstp1 <> savestop1
     c                   eval      txordseq = 0
     c                   eval      savestop1 = psstp1
     c                   endif

     c                   eval      kytype = '03'
     c                   exsr      gettxrec
     c                   exsr      createstamp

     c                   endsl

     c                   enddo

     c                   endif
     c     keyps9b       setgt     pltsum8

     c                   enddo

640cAC     endcreatenew  endsr

640cA*----------------------------------------------------------------
640cA*  zzgetpicklbl  Get picking options for zone
640cA*----------------------------------------------------------------

640cAc     zzgetpicklbl  begsr
     *
     * Get Zone Template Code if Template type is T=Truck
     *
     C     keyth         chain     truckh
     C                   if        %found(truckh)
     C                             and thtype = 'T'
     C                   eval      $ptmpl =  thztmp
     C                   else
     C                   eval      $ptmpl =  bpstruk
     C                   endif
     *
     *    Get picking options for zone.
     *
     C                   eval      kycode = '*PICKLBL'
     C                   eval      kyzone = bpsszon
     C                   eval      opdta2 = *blanks
     C     keyopz        chain     optionz
     C                   if        %found(optionz)
     C                   eval      opdta2 = opzdta
     C                   else
     C                   eval      optaxr = 'N'
     C                   eval      opchkr = 'N'
     C                   endif
     *
640cAC     getpicklbl    endsr

     *----------------------------------------------------------------
     *  zzsend
     *----------------------------------------------------------------

     c     zzsend        begsr

510aAC                   eval      savestop1 = -1
510aAC     keyps9        setll     pltsum9
     C                   dou       forever <> forever
510aAC     keyps9        reade     pltsum9

     C                   select

510aAC                   when      %eof(pltsum9)
     c                   leave
510fA
510fA*    Skip all empty pallets.
510fAC                   when      pstrn# <= 0
510fAc                   iter

     c                   other
510aAc                   if        psstp1 <> savestop1
510aAc                   eval      txordseq = 0
510aAc                   eval      savestop1 = psstp1
510aAc                   endif
510eAc                   eval      xstrn# = pstrn#
     c                   exsr      getdetail
520 D ***                exsr      gettxrec

     C                   endsl

     C                   enddo

510eAC     endsend       endsr

510eA*----------------------------------------------------------------
510eA*  zzsndtrn  retieve voiced transaction from log file and FTP
510eA*----------------------------------------------------------------

510eAc     zzsndtrn      begsr

510eAC     txftpky3      chain     txftplog3
510eAC                   if        %found(txftplog3)

510eAc                   eval      xstrn# = $ptrn#
510eAc                   exsr      getdetail2

510eAc                   endif

510eAc     endsndtrn     endsr

FDIbA*----------------------------------------------------------------
FDIbA*  zzsndtrn_all  Retrieve all transactions from log file and FTP
FDIbA*----------------------------------------------------------------

FDIbAc     zzsndtrn_all  begsr

FDIbAC     txftpky3a     setll     txftplog3
FDIbAC                   dow       forever = forever
FDIbAC     txftpky3a     reade     txftplog3
FDIbAC                   if        %eof(txftplog3)
FDIbAc                   leave

FDIbAc                   else
FDIbAC                   if        not %eof(txftplog3)
FDIbAC                             and pffsts = '1'

FDIbAc                   eval      xstrn# = pftrn#
FDIbAc                   eval      $ptrn# = pftrn#
FDIbAc                   exsr      getdetail2

FDIbAc                   endif

FDIbAc                   endif
FDIbAc                   enddo

FDIbAc     endsndtrn_all endsr
