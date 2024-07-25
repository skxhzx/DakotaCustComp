      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     *  CKR      Creates file to ftp to Check Right
     *  23 June 2009
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
520 A*    06/23/09  JCJ  5.20
     *      - Created.
     *
520aA*    10/08/09  JCJ  5.20a
     *      - Zeros suppressed order number
     *      - Changed juridiction code to be 'CheckRight'
     *
640aA*    07/11/11  JCJ  6.40a
     *      - Added Zone PHN132.
640c0*    02/28/12  JCJ  6.40c
     *      - Enh: Softcode zone specifications.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
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

     Fpltsum9   if   e           k disk
640cAFpltsum8   if   e           k disk    rename(psrec:psrec8) prefix(b)
640cAFoptionz   if   e           k disk
640cAFtruckh    if   e           k disk
     Flabel90   if   e           k disk
     Fordh      if   e           k disk
     Forddm     if   e           k disk
     Fpiritem   if   e           k disk
     Fckrdata   o    e           k disk
     Fckrstmp   if a e           k disk
     Fckftplog  if a e           k disk
     Fckftplog3 if a e           k disk    rename(ckftpr:ckftp3)

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

     D client          s             10
     D/COPY QCOPYSRC,ID#HARBOR
     D/copy qcopysrc,id#citywho
     D/copy qcopysrc,id#finkle

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
     *  Check Right Header record data structure
     *----------------------------------------------------------------
     D $ckrheader      ds

1    D  $ckrhrectype                  1    Inz('H')
2    D  $ckrstampunit                16
18   D  $ckrcustname                 30
48   D  $ckrcustnum                  10s 0
58   D  $ckrjurisdict                14
72   D  $ckrinvnum                   16
88   D  $ckrlineitems                 3s 0 Inz(0)
     D  $ckrmisc1                    16
     D  $ckrmisc2                    16
     D  $ckrmisc3                    16
     D  $ckrmisc4                    16
     D  $ckrmisc5                    16

     *----------------------------------------------------------------
     *  Check Right Detail record data structure
     *----------------------------------------------------------------

     D $ckrdetail      ds

     D  $ckrdrectype                  1    Inz('D')
     D  $ckrlinenum                   3s 0 Inz(0)
      * $taxupc                      12s 0
     D  $ckrupc                      12
     D  $ckrdesc                     30
     D  $ckrcartqty                   4s 0
     D  $ckrslot                      4

     *----------------------------------------------------------------
     *  Re-definition data structures
     *----------------------------------------------------------------

     D                 ds
     D  ckstampt                     12
     D   ckcordtmp                    9s 0 overlay(ckstampt:1)
     D   ckordseq                     3s 0 overlay(ckstampt:10)
     D  ckstamptn                    12s 0
     D ckseq#          s              3s 0 inz(0)

     D                 ds
     D  ckexpdata                   256
     D  ckrlineitems                  3s 0 overlay(ckexpdata:88)

     D                 ds
     D  ommsc1                       40
     D   ommupc1                      6    overlay(ommsc1:15)
     D   ommupc2                      5    overlay(ommsc1:26)
     D   ommjur                       2    overlay(ommsc1:31)

     *----------------------------------------------------------------
     *  Misc field mappings
     *----------------------------------------------------------------

      /Copy qcopysrc,orddm2_ctw
      /Copy qcopysrc,orddm5_ctw
      /Copy qcopysrc,orddm2_rtx
      /Copy qcopysrc,orddm3_rtx

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
     d checkrzone      s              6
     d tobacco         c                   const('TOBACO')
     d candy           c                   const('CANDY')
     d cig091          c                   const('CIG091')
     d mez032          c                   const('MEZ032')
     d mez101          c                   const('MEZ101')
640aAd phn132          c                   const('PHN132')
     d retail          c                   const('RETAIL')
     d $pwhse          s              3  0
     d xswhse          s              3  0
     d $prteid         s              5
     d $prte           s              5
     d $ptrn#          s              7  0
     d xstrn#          s              7  0
     d $pcmd           s              8
     d $pmbr           s             10
     d $pfile          s             30
     d $rrtn           s             10
     d $rmsg           s             30
     D currstamp       s               z
     D kycode          s                   like(opzcod)
     D kytype          s                   like(pftype)
     D len             S              3s 0 inz(0)
     D start           S              3s 0 inz(0)
     d $wrk9           s              9
640bAd $pszon          s              6
     d w3              s              3
     d w2              s              2
     d w1              s              1
520aAd CheckRight      s             14    inz('CheckRight    ')
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

     c                   select
     c                   when      $pcmd = '*CREATE'
     c                             and client = citywholesale
640cD **                 eval      checkrzone = cig091
     c                   exsr      zzcreatenew
640cD **                 eval      checkrzone = tobacco
640cD **                 exsr      zzcreate
640cD **                 eval      checkrzone = candy
640cD **                 exsr      zzcreate
640cD **                 eval      checkrzone = mez032
640cD **                 exsr      zzcreate
640cD **                 eval      checkrzone = mez101
640cD **                 exsr      zzcreate
640cD **                 eval      checkrzone = retail
640cD **                 exsr      zzcreate
640cD **                 eval      checkrzone = phn132
640cD **                 exsr      zzcreate

     c                   when      $pcmd = '*SEND  '
     c                             and client = citywholesale
     c                   eval      checkrzone = cig091
     c                   exsr      zzsend
     c                   eval      checkrzone = tobacco
     c                   exsr      zzsend
     c                   eval      checkrzone = candy
     c                   exsr      zzsend
     c                   eval      checkrzone = mez032
     c                   exsr      zzsend
     c                   eval      checkrzone = mez101
     c                   exsr      zzsend
     c                   eval      checkrzone = retail
     c                   exsr      zzsend
640aAc                   eval      checkrzone = phn132
640aAc                   exsr      zzsend

     c                   when      $pcmd = '*SNDTRN'
     c                   exsr      zzsndtrn
     c                   endsl
     c                   return

     *----------------------------------------------------------------
     *          Subroutines
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  getdetail Get detail records
     *----------------------------------------------------------------

     C     getdetail     begsr

     C                   eval      $ckrcartqty = 0
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
     c                   exsr      getheader
     c                   endif

     C                   eval      $ckrcartqty = lbqpck
     C                   eval      cktrn# = lbtrn#

     c     keyordd3      chain     orddm
     C                   if        %found(orddm)
     C                   eval      ctwdm2_base = ommsc2
     C                   eval      ctwdm5_base = ommsc5
     C                   eval      rtxdm2_base = ommsc2
     C                   eval      rtxdm3_base = ommsc3

     C                   select
     * city wholesale
     c                   when      client = citywholesale
     C                   eval      $wrk9 = ctwdm2_stjurc +
     C                                     ctwdm2_cojurc +
     C                                     ctwdm2_cijurc

     C                   eval      w3 = %subst($wrk9:2:3)
     C                   eval      w2 = %subst($wrk9:5:2)
     C                   eval      w1 = %subst($wrk9:1:1)

     C                   eval      $ckrjurisdict = w3 +
     C                                             w2 +
     C                                             w1 +
     C                                             ctwdm2_cijurc
520aAC                   eval      $ckrjurisdict = checkright

     C                   eval      $ckrupc = ctwdm5_upc
     C                   endsl
     c                   endif

     c     keyitem       chain     piritem
     C                   if        %found(piritem)
     C                   eval      $ckrdesc = itdesc
     c                   else
     C                   eval      $ckrdesc = *blanks
     c                   endif

     C                   eval      ckseq# = ckseq# + 1
     c                   eval      $ckrlineitems = $ckrlineitems + 1
     C                   eval      $ckrlinenum = $ckrlinenum + 1

     *      Find right most ' ', grab last 4 non blanks of slot.
     C                   eval      len = %checkr(' ':lbdisp)
     C                   if        len < 4
     C                   eval      start = 1
     C                   else
     C                   eval      start = len - 3
     C                   endif
     C                   eval      $ckrslot = %subst(lbdisp:start:4)

     c                   eval      ckexpdata =  $ckrdetail
     C                   write(e)  ckrrec
     c                   eval      wroterecord = *on

     c                   eval      saveorder# = lbord

     C                   endsl
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  getdetail2 Get detail records
     *----------------------------------------------------------------

     C     getdetail2    begsr

     C                   eval      $ckrcartqty = 0
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

     C                   eval      $ckrcartqty = lbqpck
     C                   eval      cktrn# = lbtrn#

     c     keyordd3      chain     orddm
     C                   if        %found(orddm)
     C                   eval      ctwdm2_base = ommsc2
     C                   eval      ctwdm5_base = ommsc5
     C                   eval      rtxdm2_base = ommsc2
     C                   eval      rtxdm3_base = ommsc3
     C                   select
     * city wholesale
     c                   when      client = citywholesale
     C                   eval      $wrk9 = ctwdm2_stjurc +
     C                                     ctwdm2_cojurc +
     C                                     ctwdm2_cijurc

     C                   eval      w3 = %subst($wrk9:2:3)
     C                   eval      w2 = %subst($wrk9:5:2)
     C                   eval      w1 = %subst($wrk9:1:1)

     C                   eval      $ckrjurisdict = w3 +
     C                                             w2 +
     C                                             w1 +
     C                                             ctwdm2_cijurc
520aAC                   eval      $ckrjurisdict = checkright
     C                   eval      $ckrupc = ctwdm5_upc
     C                   endsl
     c                   endif

     c     keyitem       chain     piritem
     C                   if        %found(piritem)
     C                   eval      $ckrdesc = itdesc
     c                   else
     C                   eval      $ckrdesc = *blanks
     c                   endif

     C                   eval      ckseq# = ckseq# + 1
     c                   eval      $ckrlineitems = $ckrlineitems + 1
     C                   eval      $ckrlinenum = $ckrlinenum + 1

     *      Find right most ' ', grab last 4 non blanks of slot.
     C                   eval      len = %checkr(' ':lbdisp)
     C                   if        len < 4
     C                   eval      start = 1
     C                   else
     C                   eval      start = len - 3
     C                   endif
     C                   eval      $ckrslot = %subst(lbdisp:start:4)

     c                   eval      ckexpdata =  $ckrdetail
     C                   write(e)  ckrrec
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

     C                   eval      ckseq# = 1
     C                   eval      $ckrcustname = ohcnam
     C                   eval      $ckrcustnum = ohcust
520aD ***                movel     ohcord        $ckrinvnum
520aMC                   eval      $ckrinvnum = %char(ohcord)
     C                   eval      ckwhse = $pwhse
     C                   eval      ckrtid = $prteid

     C                   select
     * City Wholesale
     c                   when      client = citywholesale
     C                   eval      $ckrstampunit = %char(pstrn#)
     C                   eval      ckstamp = %char(pstrn#)
     C                   endsl

     C                   eval      ckrte  = $prte
     C                   time                    ckaddts
     C                   time                    currdatestamp
     C                   eval      tsdatetime = %char(currdatestamp)

     c                   eval      writeheader = *on
     C                   eval      saveorder# = lbord

     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getheader2 get order header record and create header record.
     *----------------------------------------------------------------

     C     getheader2    begsr

     C     keyordh       chain     ordh
     C                   if        %found(ordh)

     C                   eval      ckseq# = 1
     C                   eval      $ckrcustname = ohcnam
     C                   eval      $ckrcustnum = ohcust
520aD ***                movel     ohcord        $ckrinvnum
520aMC                   eval      $ckrinvnum = %char(ohcord)
     C                   eval      ckwhse = $pwhse
     C                   eval      ckrtid = $prteid
     C                   eval      ckcord# = ohcord
     C                   eval      ckcordtmp = ckcord#

     C     keyl90        chain     ckrstmp
     C                   if        %found(ckrstmp)

     C                   select
     * City Wholesale
     c                   when      client = citywholesale
     C                   movel     tsstamp       ckstamptn
     C                   eval      $ckrstampunit = tsstamp
     C                   eval      ckstamp = tsstamp
     C                   endsl
     C                   endif

     C                   eval      ckrte  = $prte
     C                   time                    ckaddts
     C                   time                    currdatestamp
     C                   eval      tsdatetime = %char(currdatestamp)

     c                   eval      writeheader = *on
     C                   eval      saveorder# = lbord

     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  createstamp  Create stamping unit number.
     *----------------------------------------------------------------

     C     createstamp   begsr

     C                   eval      tswhse = $pwhse
     C                   eval      tsrte  = *blanks
     C                   eval      tsrtid = psrtid
     C                   eval      tstrn# = pstrn#
     C                   eval      tsstamp = %char(pstrn#)

     C                   write     cstmp

     C                   endsr

     *----------------------------------------------------------------
     *  Getckrec      Get CK FTP Status record.
     *----------------------------------------------------------------

     C     getckrec      begsr

     C     ckftpky3      chain     ckftplog3
     C                   select
     C                   when      not %found(ckftplog3)
     C                   eval      pfwhse = $pwhse
     C                   eval      pfrtid = $prteid
     C                   eval      pfrte  = $prte
     C                   eval      pftype = kytype
     C                   eval      pftrn# = pstrn#
     C                   eval      pffsts = '1'
     C                   eval      pflusr = #user
     C                   time                    currstamp
     C                   eval      pfaddts= currstamp
     C                   write     ckftp3
     C                   endsl

     C     endgetckrec   endsr

     *----------------------------------------------------------------
     *  processheader - Write header record.
     *----------------------------------------------------------------

     C     processheader begsr

     c                   if        writeheader
     C                   eval      ckseq# = 1
     C                   eval      cktrn# = xstrn#
     c                   eval      ckexpdata =  $ckrheader
     C                   write(e)  ckrrec
     *
     *      Send customer order via FTP to Check-Right.
     *
     c                   select
     C                   when      client = citywholesale
     c                   if        $pcmd <> '*CREATE'
     c                   exsr      procckrftp
     c                   endif
     c                   other
     c                   exsr      procckrftp
     c                   endsl
     *
     C                   eval      $ckrlinenum = 0
     c                   eval      $ckrlineitems = 0
     c                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  proceckrftp - Process Check Right FTP.
     *----------------------------------------------------------------

     C     procckrftp    begsr

     *    Call FTP program to send file to Check Right
     C                   call      'CKRFTP'
     C                   parm                    $pcmd
     C                   parm                    $pwhse
     C                   parm                    $prteid
     C                   parm                    $prte
     C                   parm                    $ptrn#
     C                   parm      *blanks       $pmbr
     C                   parm      *blanks       $pfile
     C                   parm      *blanks       $rrtn
     C                   parm      *blanks       $rmsg

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Extra program initialization.
     *----------------------------------------------------------------

     c     zzinz2        begsr

     * Key definitions

640cA*  Define partial key for PLTSUM9 file.

640cAc     keyps8        klist
640cAc                   kfld                    $pwhse
640cAc                   kfld                    $prteid

     *  Define partial key for PLTSUM9 file.

     c     keyps9        klist
     c                   kfld                    $pwhse
     c                   kfld                    $prteid
     c                   kfld                    checkrzone

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

     *  Define partial key for LABEL90 file.

     c     keyl90        klist
     c                   kfld                    xswhse
     c                   kfld                    xstrn#

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
     *
     *  Define full key for CKFTPLOG file
     *
     c     ckftpky       klist
     c                   kfld                    $pwhse
     c                   kfld                    $prteid
     c                   kfld                    kytype

     *
     *  Define full key for CKFTPLOG3 file
     *
     c     ckftpky3      klist
     c                   kfld                    $pwhse
     c                   kfld                    $prte
     c                   kfld                    $prteid
     c                   kfld                    $ptrn#
     *
     *  Define partial key for CKFTPLOG3 file
     *
     c     ckftpky3a     klist
     c                   kfld                    $pwhse
     c                   kfld                    $prte
     c                   kfld                    $prteid
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
     c                   eval      ckseq# = 0
     c                   eval      xswhse = $pwhse

     c                   endsr
     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Get client id

     c                   call      'GETCLIENT'
     c                   parm                    client

     c                   endsr

     *----------------------------------------------------------------
     *  zzcreate  create txftplog records only
     *----------------------------------------------------------------

     c     zzcreate      begsr

     C                   eval      savestop1 = -1
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
     c                   eval      ckordseq = 0
     c                   eval      savestop1 = psstp1
     c                   endif

     c                   eval      kytype = '03'
     c                   exsr      getckrec
     c                   exsr      createstamp

     c                   endsl

     c                   enddo

     C     endcreate     endsr

640cA*----------------------------------------------------------------
640cA*  zzcreatenew  create ckftplog records only
640cA*----------------------------------------------------------------

640cAc     zzcreatenew   begsr

     c     keyps8        setll     pltsum8
     c                   dou       forever <> forever
     c     keyps8        reade     pltsum8

     c                   if        %eof(pltsum8)
     c                   leave
     c                   endif

     c                   exsr      zzgetpicklbl

     c                   if        opchkr = 'Y'
     c                   eval      checkrzone = bpsszon

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
     c                   eval      ckordseq = 0
     c                   eval      savestop1 = psstp1
     c                   endif

     c                   eval      kytype = '03'
     c                   exsr      getckrec
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

     C                   eval      savestop1 = -1
     C     keyps9        setll     pltsum9
     C                   dou       forever <> forever
     C     keyps9        reade     pltsum9

     C                   select

     C                   when      %eof(pltsum9)
     c                   leave

     *    Skip all empty pallets.
     C                   when      pstrn# <= 0
     c                   iter

     c                   other
     c                   if        psstp1 <> savestop1
     c                   eval      ckordseq = 0
     c                   eval      savestop1 = psstp1
     c                   endif
     c                   eval      xstrn# = pstrn#
     c                   exsr      getdetail

     C                   endsl

     C                   enddo

     C     endsend       endsr

     *----------------------------------------------------------------
     *  zzsndtrn  retieve voiced transaction from log file and FTP
     *----------------------------------------------------------------

     c     zzsndtrn      begsr

     C     ckftpky3      chain     ckftplog3
     C                   if        %found(ckftplog3)

     c                   eval      xstrn# = $ptrn#
     c                   exsr      getdetail2

     c                   endif

     c     endsndtrn     endsr
