      /copy *libl/qcopysrc,hspecs
760 AH Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  RN235S    Staging - Import customer returns
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650  *    09/03/14  RTR  6.50
     *      - Created using RN235
     *      - Removed mod marks and deleted lines except for client code.
     *
700aA*    01/05/16  LMC  7.00a
     *      - Enh: Returns now use RTNDOCK slots instead of RCVDOCK.
     *        We send RTNIN command in place of RCVIN.                as
760  *    09/02/22  KDE  7.60
     *      - Enh:  Add call to interface found reporting in Report
     *        Scheduler when import has a failure or error
760a *    01/08/23  KDE  7.60d
     *      - Enh:  Change interface error report to R42600.  Also
     *        Add extended message for complete Stage Batch
     *
     *----------------------------------------------------------------
     *  Custom Client Revisions:  Glazier
GFCa *    04/10/12  GJA  GFCa
     *      - Remove edits, only allow item and license edits
     *
     *----------------------------------------------------------------
     *  Custom Client Revisions:  Will Foods
WILa *    10/01/14  RTR  WILa
     *      - Entree is sending negative qtys, flip sign.
WILb *    01/23/15  RTR  WILb
     *      - Per email from Jim Koester, do not load neg qtys.
WILc *    06/24/15  RTR  WILc
     *      - Changing returns, no longer process any returns sent from
     *        entree for Will Foods. Still need to set status so won't
     *        error in entree.
     *    *** removed until change in place ***
     *
     *----------------------------------------------------------------
     *  Custom Client Revisions:  Julius Silvert
JSLa *    07/20/15  RTR  JSLa
     *      - Changed to make sure returns not processed in Dakota.
     *
     *----------------------------------------------------------------
     *  Notes -
     *      - If breakdown qty being imported, verify if allowed.
     *      - If breakdown qty in not allowed, do not import brk qty.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  61        - Special order (Customer # > 0)
     *  79        - EOF for IMPRTN
     *  78        - EOF for ORTNBAT
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fimpsrtn   uf   e           k disk
     FLabel     uf a e           k disk
     FLabel2    if   e           k disk
     F                                     rename(lbrec:record)
     FLabelnk   o  a e           k disk
     FLicense   uf a e           k disk
     Fpirtran   if   e           k disk
     Fpomfr1    uf a e           k disk
     Frdscode   if   e           k disk
     Frtncode   if   e           k disk
     Freports   if   e           k disk
     Fwarehs    if   e           k disk
     Fitmexcp   o    e           k disk
     Forrtn     o  a e           k disk
     Frn235pr   o    e             printer oflind(*in91)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             20    dim(11)ctdata perrcd(1)
     *
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
730eA /copy qcopysrc,c#stdvar
760 AD/copy qcopysrc,p.mrcrptsc
760 AD/copy qcopysrc,p.qcmdexc

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#LICENSE

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#saval
      /copy qcopysrc,id#glazier
WILaA /copy qcopysrc,id#wil
JSLaA /copy qcopysrc,id#jsl

     D savever#        s                   like($slver#)
     D saveaisl        s                   like($slaisl)
     D saveloc         s                   like($slloc)
     D saverlvl        s                   like($slrlvl)
     D savehand        s                   like($slhand)
     D slotds        e ds                  extname(slot)

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D $pwhse          s              3  0
     D $pWhse3A        s              3
     D $pBatId         s             11
     D $pReturn        s             10
     D $pMessage       s            200
     D $pindt          s              8  0
     D $pfifo          s              8  0
     D ajcode          s              2
     D bad1            s              1
     D baddcd          s              7  0
     D badlbl          s              7  0
     D badlcn          s              7  0
     D badlbi          s              7  0
     D badmpi          s              7  0
     D ck4err          s              1
     D count           s              3  0
     D eofh            s              1
     D eofr            s              1
     D expd            s              8  0
     D first           s              1
     D importError     s               n
     D kyitem          s             15
     D kylcns          s             15
     D kystat          s              1
     D lcnflg          s              1
     D len             s              1  0
     D linppg          s              3  0
     D ocode           s              8
     D oslot           s             12
     D picksl          s              1
     D pflag           s              1
     D pslot           s             12
     D pos             s              1  0
     D stamp           s               z
     D stampUC         s               z
     D stop            s              1
     D sublin          s              3  0
     D subq1           s              7  0
     D subq2           s              7  0
     D subq3           s              7  0
     D svdate          s              8  0
     D svtime          s                   like(orutim)
     D today           s              8  0
     D w1qty           s              5  0
     D woinvf          s              1
     D work3a          s              3
760 AD currReport      s             20
760 AD url             s           3000
760 AD schEmail        s           1000
760 AD orient          s              1
760 AD grDev           s             10
760 Ad sbmusr          s             10
760 Ad sbmjobd         s             10
760 Ad sbmlibl         s             10
760 AD cmd             s           3000    varying
760 AD opmusr          s             10
760 Ad opjobd          s             10

     D currtimestamp   s               z

     D #rcvarea        s              6
     D #rcvitem        s                   like($ititem)
     D #rcvtype        s                   like($ittype)
     D #rcvdesc        s                   like($itdesc)
     D #rcvpdsc        s                   like($itpdsc)
     D #rcvwhdp        s                   like($itwhdp)
     D #rcvstyp        s                   like($itstyp)
     D #rcvdesg        s                   like($itdesg)
     D #rcvum1         s                   like($itum1)
     D #rcvflg1        s                   like($itflg1)
     D #rcvum2         s                   like($itum2)
     D #rcvumq2        s                   like($itumq2)
     D #rcvflg2        s                   like($itflg2)
     D #rcvum3         s                   like($itum3)
     D #rcvumq3        s                   like($itumq3)
     D #rcvdday        s                   like($imdday)
     D #rcvmday        s                   like($immday)
     D #rcvmflg        s                   like($immflg)
     D #rcvuday        s                   like($imuday)
     D #rcvnrpk        s                   like($imnrpk)
     D #rcvflgd        s                   like($itflgd)
     D #rcvcube        s                   like($itcube)
     D #rcvswgt        s                   like($itswgt)
     D #rcvupc         s                   like($itupc)

     D #slotitem       s                   like($ititem)
     D #slottype       s                   like($ittype)
     D #rcvcwgt        s                   like($itcwgt)

760 A*----------------------------------------------------------------
760 A*  Sub-procedure prototypes
760 A*----------------------------------------------------------------

760 Ad getSchTimeEml   pr

     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $litem                22     36
     *
     D  $lcode                19     20
     *
     D  $ldcde                19     23
     *
     D  $ltrn#                19     25  0
     *
     D  $luser                19     28
     *----------------------------------------------------------------
     *  Called programs
     D @cvtdt          c                   const('CVTDTE')
     D @addtr          c                   const('ADDSTDTRN')
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  Called program parameters
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
     *
     *----------------------------------------------------------------
     * Data structure
     *
     *----------------------------------------------------------------
     *  *RETURNS -  Customer Returns options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPRQCH  -  Allow changes to return quantity. (Y,N).
     *    OPRQEC  -  Allow changes to qty if return exported. (Y/N)
     *    OPRFLB  -  Force return label entry. (Y/N)
     *    OPREXQ  -  Export Quick returns.(Y/N)
     *    OPRULB  -  Use label for putaway.(Y/N)
     *
     * Data structure
     *
     D oprdta          ds
     D  oprqch                 1      1
     D  oprqec                 2      2
     D  oprflb                 3      3
     D  oprexq                 4      4
     D  oprulb                 5      5
     D  oprend               117    117
     *----------------------------------------------------------------
     *  Program info data structure
     *
      /COPY *libl/qcopysrc,C#PGMINFDS
760aAd/copy qcopysrc,p.wIntLog
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *      $pBatId - Batch id
     *
     *    Returned Parameters
     *      $pReturn  - Return code
     *      $pMessage - Return message
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pWhse3A
     c                   parm                    $pBatId
     c                   parm                    $pReturn
     c                   parm                    $pMessage

     c                   eval      $pWhse = %dec($pWhse3A: 3: 0)
     c                   eval      $pReturn = '*OK'
     c                   eval      $pMessage = ' '
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *
     * Update stgbatch record to start process
     *
     C                   exsr      zzzStart
     C                   if        $pReturn <> '*OK'
     C                   return
     C                   endif
     *
     C                   select
     C                   when      client = WillFoods
     * default is do nothing, should only import if option set
     C                   other
     C                   exsr      zzzEnd
     C                   return
     C                   endsl
     *
     * Whip through all the download records
     *
     C                   eval      pflag = *off
     C                   eval      eofh = *off
     C                   eval      linppg = 55
     C                   eval      count = 0
     *
     C     keyrtn        setll     impsrtn
     C                   dou       eofh = *on
     C                             or oirwhs <> $pwhse
     C                             or oirbatid <> $pbatid
     *
     C                   read      impsrtn                                79
     C                   if        *in79
     C                             or oirwhs <> $pwhse
     C                             or oirbatid <> $pbatid
     C                   eval      eofh = *on
     C                   goto      enddoh
     C                   endif
     *
     C                   if        oirsts <> ' '
     C                   iter
     C                   endif
     *
     *  Print report heading if necessary.
     *
     C                   if        pflag = *off  or
     C                             count >= linppg
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   eval      pflag = *off
     C                   endif
     *
     *    Print order heading
     *
     C                   if        pflag = *off
     C                   write     head2
     C                   add       2             count
     C                   eval      pflag = *on
     C                   endif
     *
     C                   eval      detmsg = *blanks
     C                   eval      bad1 = 'N'
     *
     *       Print return detail and update subtotals
     *
     C                   if        oirlbl > 0
     C                   eval      rmemo = %trim(%editc(oirlbl:'4'))
     C                   else
     C                   eval      rmemo = oirlcn
     C                   endif
     C                   write     detail
     C                   add       1             count
     C                   add       1             grdlin
     *
     *    Verify import fields, write error msg.
     *
     C                   exsr      zzchk1
     *  Update import return status to error (3)
     C                   if        bad1 = 'Y'
     C                   time                    currtimestamp
     C                   eval      oirsdt = currtimestamp
     C                   eval      oirsts ='3'
     C                   eval      oirstatus ='E'
     C                   update    oirrec
     *
     C                   iter
     C                   else
     *   Add records for Return if no errors.
     *
     *    Set notify inventory control flag (can be set using Return code)
     C                   eval      woinvf='N'
     *
WILaA*  For Will Foods, entree host is sending returns negative, fix.
WILaAC                   if        client = willfoods
WILaAC                   eval      oirqt1 = oirqt1 * -1
WILaAC                   eval      oirqt2 = oirqt2 * -1
WILaAC                   eval      oirqt3 = oirqt3 * -1
WILaAC                   endif
     *
     C                   select
WILbDC**                 when      oirqt1 <> 0
WILbMC                   when      oirqt1 > 0
     C                   eval      w1qty = oirqt1
WILbDC**                 when      oirqt2 <> 0
WILbMC                   when      oirqt2 > 0
     C                   eval      w1qty = oirqt2
WILbDC**                 when      oirqt3 <> 0
WILbMC                   when      oirqt3 > 0
     C                   eval      w1qty = oirqt3
     C                   endsl
WILbA*
WILbA* Skip if no qty
WILbAC                   if        w1qty > 0
     *
     * Update files (RN246 or RN246L)
     C                   exsr      zzurtf
     C                   exsr      zzumfr
     *      Write to label link file if Label # was entered.          .
     C                   exsr      zzulnk
     *
     * Update files  (like RN250) adj rec, orrec.
     C                   exsr      zzurtn
     *
WILbAC                   endif
     *
     *  Update import return status to compelte (4)
     *
     C                   eval      oirsts ='4'
     C                   eval      oirstatus ='S'
     C                   time                    currtimestamp
     C                   eval      oirsdt = currtimestamp
     C                   exsr      zzzGetStamps
     C                   eval      oirststs = stamp
     C                   eval      oirstsuc = stampuc
     C
     C                   update    oirrec
     C                   endif
     *
     C     enddoh        tag
     C                   enddo
     *
     *  Print order grand totals
     *
     C                   if        pflag = *on
     C                   if        count >= linppg
     C                   write     head1
     C                   endif
     C                   write     grndttl
     C                   endif
     *
     C                   exsr      zzzEnd
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Get Client
     C                   call      @getcl
     C                   parm                    client           10
     *
     C                   eval      first = *on
     C                   eval      kystat = *blanks
     *
     * Key definitions
     *
     *  Define key for impsrtn file.
     *
     C     keyrtn        klist
     C                   kfld                    $pWhse
     C                   kfld                    $pBatId
     *
     * Download return file - Partial key
     *
     C     oirkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    kystat
     *
     * Item file
     *
     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    kyitem
     *
     * License file
     *
     C     lcnsky        klist
     C                   kfld                    oirwhs
     C                   kfld                    oirlcn
     *
     *  Define key for LICENSE file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    kylcns
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ocode
     *
     *     Label
     C     partk2        klist
     C                   kfld                    $pbat
     C                   kfld                    $pwhse
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   move      #prog         $cvprg
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   exsr      zzinz
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     *
     C     zzinz         begsr
     C                   eval      $pwhse = oirwhs
     * Regrieve current date and time for batch
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *
     C                   eval      svdate = $cvd8o
     C                   time                    svtime
     * Reposition file pointer to BOF.
     C     *loval        setll     impsrtn
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     'RN235PR'     rpprtf
     C     rpprtf        chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      $pwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   if        pos = 0
     C                   eval      pos = 1
     C                   endif
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     * Initialize grand total fields
     *
     C                   eval      grdlin = 0
     C                   eval      baditm = 0
     C                   eval      baddte = 0
     C                   eval      badbrk = 0
     C                   eval      badrcd = 0
     C                   eval      badtrn = 0
     C                   eval      baddcd = 0
     C                   eval      badlbl = 0
     C                   eval      badlcn = 0
     C                   eval      badmpi = 0
     *
     *    Initialize order subtotals
     *
     C                   eval      sublin = 0
     C                   eval      subq1 = 0
     C                   eval      subq2 = 0
     C                   eval      subq3 = 0
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZBKDN  Check breakdown quanties.
     *
     C     zzbkdn        begsr
     C                   if        oirqt2 <> 0  and
     C                             #rcvflg1 <> 'Y'
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endif
     *
     C                   if        oirqt3 <> 0  and
     C                             #rcvflg2 <> 'Y'
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endif

     *   Only allowed to send one qty type.

     C                   if        oirqt1<>0  and oirqt2<>0
     C                             or (oirqt1<>0  and oirqt3<>0)
     C                             or (oirqt2<>0  and oirqt3<>0)
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1  Verify return code and transaction #
     *
     C     zzchk1        begsr
     *       If item doesn't exist write error message,
     *          don't write to ORTNBAT file.
     *
     C                   exsr      clr$item
     C                   eval      $itwhse = oirwhs
     C                   eval      $ititem = oiritm
     *
     C                   exsr      zrvfyitm
     *
     C                   If        $drireturn <> '*OK'
     C                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   add       1             baditm
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endif
     *  If corresponding item doesn't exist (mispick)
     *    write error message, don't write to ORTNBAT file.
     *
     C                   if        oircit <> ' '
     C                   exsr      clr$item
     C                   eval      $itwhse = oirwhs
     C                   eval      $ititem = oircit
     *
     C                   exsr      zrvfyitm
     *
     C                   If        $drireturn <> '*OK'
     C                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   add       1             badmpi
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endif
     C                   endif
     *
     *       Get item info.
     C                   exsr      zzgeti
     *       If invalid date, write error message,
     *          don't write to ORTNBAT file.
     *
     C                   if        $itflgd = 'Y'
     C                   exsr      zzexdt
     C                   else
     C                   eval      expd = 0
     C                   endif
     *
     *       Check if breakdown qty is allowed using piritem file.
     *       If invalid qty1, brk qty2 or brk qty3 , write error msg.
     *          don't write to ORTNBAT file.
     C                   exsr      zzbkdn
     *
     *
      *  Mispick item must be different than ordered item.
     *
     C                   if        oircit = oiritm
     C                   eval      error = *on
     C                   add       1             badmpi
     C                   eval      detmsg = desc(10)
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endif
     *
     *  Verify return code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lcode = oirrcd
     C                   eval      $lprg  = #prog
     C     oirrcd        setll     rtncode
     C                   if        not %equal(rtncode)
     C                   add       1             badrcd
     C                   eval      detmsg = desc(5)
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   add       1             badrcd
     C                   eval      detmsg = desc(5)
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endif
     C                   endif
     *
     *  Verify disposition code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lprg  = #prog
     C                   eval      $ldcde = oirdcd
     C     oirdcd        setll     rdscode
     C                   if        not %equal(rdscode)
     C                   add       1             baddcd
     C                   eval      detmsg = desc(7)
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   add       1             baddcd
     C                   eval      detmsg = desc(7)
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endif
     C                   endif
     *
     *  Verify label #.
     *
     C                   if        oirlbl <> 0
     C     oirlbl        chain     label                              79
     C                   if        *in79
     C                   add       1             badlbl
     C                   eval      detmsg = desc(8)
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   else
     C                   select
     C                   when          lbtype <> 'O'
     C                             and lbtype <> 'B'
     C                   add       1             badlbl
     C                   eval      detmsg = desc(8)
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C*
     C                   when      oiritm <> lbitem
     C                   add       1             badlbi
     C                   eval      detmsg = desc(11)
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endsl
     C                   endif
     C                   endif
     C*
     *  License must be unique.
     *
     C                   if        oirlcn <> ' '
     C     lcnsky        setll     license                                79
     C                   if        *in79
     C                   add       1             badlcn
     C                   eval      detmsg = desc(9)
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endif
     C                   endif
     *
     *  Verify transaction number.
     *
     C                   if        oirtrn <> 0
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lprg  = #prog
     C                   eval      $ltrn# = oirtrn
     C     oirtrn        setll     pirtran
     C                   if        not %equal(pirtran)
     C                   add       1             badtrn
     C                   eval      detmsg = desc(6)
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDET2  Print error message lines.
     *
     C     zzdet2        begsr
     *
     C                   exsr      zrhead
     C                   write     detl2
     C                   add       1             count
     C                   eval      detmsg = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZEXCP Write item exception record to file.
     *
     C     zzexcp        begsr
     *
     *    Write an item exception record for item (mispick).
     *
     C                   eval      exwhdp = #rcvwhdp
     C                   eval      exstyp = #rcvstyp
     *

     *  Use DRI interface to get Slot item for ordered item

     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = exitem
     C                   exsr      zzsltitm
     *
     C                   eval      $scmd = '*FIRST'
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      $pwhse        $swhse            3 0
     C                   parm      $ititem       #sitem           15
     C                   parm                    woslot           12
     C                   parm                    $saisl            3
     C                   parm                    $sloc             3 0
     C                   parm                    $srlvl            2 0
     C                   parm                    $shand            2
     C                   parm                    $srtn             8
     C                   if        $srtn <> '*NONE   '
     C                   eval      extdis = woslot
     C                   else
     C                   eval      extdis = *blanks
     C                   endif
     C                   eval      exwhse = $pwhse
     *
     C                   if        oirqt1 > 999
     C                   eval      exqty = 999
     C                   else
     *
     C                   z-add     oirqt1        exqty
     C                   endif
     *
     C                   if        oirqt2 > 999
     C                   eval      exqty = 999
     C                   else
     *
     C                   eval      exqty2 = oirqt2
     C                   endif
     *
     C                   if        oirqt3 > 999
     C                   eval      exqty = 999
     C                   else
     *
     C                   eval      exqty3 = oirqt3
     C                   endif
     *
     C                   eval      extask = 'PUTRTN'
     *    Retrieve current date.
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      exgdte = $cvd8o
     C                   time                    exgtim
     C                   eval      exgby = #user
     C                   eval      exesta = '1 '
     C                   write     exrec
     *
     C     endexc        endsr
     *----------------------------------------------------------------
     *
     *  ZZEXDT  Check expiration date.
     *
     C     zzexdt        begsr
     *
     *  Verify expiration date.
     *
     C                   if        oiredt <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      oiredt        $cvd6i
     C                   move      #prog         $cvprg
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      detmsg = desc(4)
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   add       1             baddte
     C                   else
     *
     *  Convert expiration date into century format.
     *
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      #prog         $cvprg
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     *
     *  Expiration date must be greater than today.
     *
     C                   if        expd <= today
     C                   eval      detmsg = desc(4)
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   add       1             baddte
     C                   endif
     C                   endif
     C                   endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *  ZZGETI      Get Item
     *----------------------------------------------------------------

     *  Use DRI interface to get item.
     C     zzgeti        begsr

     C                   exsr      clr$item
     C                   eval      $itwhse  = $pwhse
     *  Use mis-pick picked item.
     C                   if        oircit > ' '
     C                   eval      $ititem = oircit
     C                   else
     C                   eval      $ititem  = oiritm
     C                   endif

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   clear                   #rcvitem
     C                   clear                   #rcvtype
     C                   clear                   #rcvdesc
     C                   clear                   #rcvpdsc
     C                   clear                   #rcvwhdp
     C                   clear                   #rcvstyp
     C                   clear                   #rcvdesg
     C                   clear                   #rcvum1
     C                   clear                   #rcvflg1
     C                   clear                   #rcvum2
     C                   clear                   #rcvumq2
     C                   clear                   #rcvflg2
     C                   clear                   #rcvum3
     C                   clear                   #rcvumq3
     C                   clear                   #rcvnrpk
     C                   clear                   #rcvmflg
     C                   clear                   #rcvdday
     C                   clear                   #rcvmday
     C                   clear                   #rcvuday
     C                   clear                   #rcvflgd
     C                   clear                   #rcvcube
     C                   clear                   #rcvswgt
     C                   clear                   #slotitem
     C                   clear                   #slottype
     C                   clear                   #rcvcwgt
     C                   goto      enditm
     C                   endif

     C                   eval      #rcvitem = $ititem
     C                   eval      #rcvtype = $ittype
     C                   eval      #rcvdesc = $itdesc
     C                   eval      #rcvpdsc = $itpdsc
     C                   eval      #rcvwhdp = $itwhdp
     C                   eval      #rcvstyp = $itstyp
     C                   eval      #rcvdesg = $itdesg
     C                   eval      #rcvum1  = $itum1
     C                   eval      #rcvflg1 = $itflg1
     C                   eval      #rcvum2  = $itum2
     C                   eval      #rcvumq2 = $itumq2
     C                   eval      #rcvflg2 = $itflg2
     C                   eval      #rcvum3  = $itum3
     C                   eval      #rcvumq3 = $itumq3
     C                   eval      #rcvnrpk = $imnrpk
     C                   eval      #rcvmflg = $immflg
     C                   eval      #rcvdday = $imdday
     C                   eval      #rcvmday = $immday
     C                   eval      #rcvuday = $imuday
     C                   eval      #rcvflgd = $itflgd
     C                   eval      #rcvcube = $itcube
     C                   eval      #rcvswgt = $itswgt
     C                   eval      #rcvcwgt = $itcwgt
     C     enditm        tag
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZRVFYITM   Verify Item using DRI interface
     *
     C     zrvfyitm      begsr
     *
     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   write     head2
     C                   add       2             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  ZZLICINFO   Update licinfo
     *----------------------------------------------------------------

     C     zzlicinfo     begsr

     *  Write out standard license information.

     C                   exsr      clr$licinfo

     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr  = #jobnbr

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
     C                   if        oirlcn > *blanks
     C                   eval      $lnlcns  = oirlcn
     C                   else
     C                   eval      $lnlcns  = $saToLcns
     C                   endif

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*ITEM'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'A'
     C                   eval      $lnvalchr(1) = oiritm
     C                   eval      $lnvalnum(1) = 0


     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*RCVTRN#'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = pttrn#


     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*RCVLQTY'
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'N'
     C                   eval      $lnvalchr(3) = ' '
     C                   eval      $lnvalnum(3) = w1qty

     C*                  if        $plotc <> ' '
     C*                  eval      $lncodeu(4) = *on
     C*                  eval      $lncode(4) = '*LOT'
     C*                  eval      $lncseq(4) = 1
     C*                  eval      $lnvaltyp(4) = 'A'
     C*                  eval      $lnvalchr(4) = $plotc
     C*                  eval      $lnvalnum(4) = 0
     C*                  endif

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%ADD'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   endif

     *  Write out more standard and optional license information.

     C                   exsr      clr$licinfo

     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr  = #jobnbr

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
     C                   if        oirlcn > *blanks
     C                   eval      $lnlcns  = oirlcn
     C                   else
     C                   eval      $lnlcns  = $saToLcns
     C                   endif

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*RCVLBL#'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'N'
     C                   eval      $lnvalchr(1) = ' '
     C                   eval      $lnvalnum(1) = lblbl#

     C                   if        expd > 0
     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*EXPDTE'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = expd
     C                   endif

     C                   if        expd > 0
     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*DATEIN '
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'N'
     C                   eval      $lnvalchr(3) = ' '
     C                   eval      $lnvalnum(3) = expd
     C                   endif

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%ADD'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPSLT   Get Put pick slot for mispick items
     *
     C     zzpslt        begsr
     *

     *  Use DRI interface to get Slot item for ordered item

     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = exitem
     C                   exsr      zzsltitm
     *
     C                   eval      picksl = *off
     C                   eval      oslot = *blanks
     C                   eval      pslot = *blanks
     C                   movel     '*FIRST'      $scmd
     C                   call      'GETPSLT'
     C                   parm                    $scmd
     C                   parm      $pwhse        $swhse
     C                   parm      $ititem       #sitem
     C                   parm                    woslot
     C                   parm                    $saisl
     C                   parm                    $sloc
     C                   parm                    $srlvl
     C                   parm                    $shand
     C                   parm                    $srtn
     C                   if        $srtn <> '*NONE   '
     C                   eval      oslot = woslot

     *  Use DRI interface to get Slot item for picked item

     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = excitm
     C                   exsr      zzsltitm
     *
     *
     C                   movel     '*FIRST'      $scmd
     C                   call      'GETPSLT'
     C                   parm                    $scmd
     C                   parm      $pwhse        $swhse
     C                   parm      $ititem       #sitem
     C                   parm                    woslot
     C                   parm                    $saisl
     C                   parm                    $sloc
     C                   parm                    $srlvl
     C                   parm                    $shand
     C                   parm                    $srtn
     C                   if        $srtn <> '*NONE   '
     C                   eval      pslot = woslot
     *
     C                   eval      picksl = *on
     C                   endif
     C                   endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *  zzsltitm    Get slot item (base item)
     *----------------------------------------------------------------

     C     zzsltitm      begsr

     *  Use DRI interface to get Slot item.

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSLOT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error  = *on
     C                   clear                   #slotitem
     C                   clear                   #slottype
     C                   endif

     C                   eval      #slotitem = $ititem
     C                   eval      #slottype = $ittype
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZULNK   Update for LABELNK FILE
     *
     C     zzulnk        begsr
     *
     *
     *      Write to label link file if Label # was entered.          .
     *
     *  $PBAT in PARTK2 has batch number for new label.
     C                   if        oirlbl <> 0
     C     partk2        setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     partk2        reade     label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   eval      lllblo = oirlbl
     C                   eval      lllbl# = lblbl#
     C                   eval      lltrn# = lbtrn#
     C                   eval      llqpck = lbqpck
     C                   eval      llucod = lbucod
     C                   write     llrec
     C                   endif
     C                   enddo
     C                   endif
     C     endlnk        endsr
     *----------------------------------------------------------------
     *
     *  ZZUMFR   Update for POMFR FILE
     *
     C     zzumfr        begsr
     *
     C                   if        expd <> 0
     *
     C     partk2        setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     partk2        reade     label2                                 79
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C     lblbl#        chain     pomfr1                             78
     C                   eval      pmwhse = $pwhse
     C                   eval      pmpo = *blanks
     C                   eval      pmseq = 0
     *
     C                   if        oircit <> *blanks
     C                   eval      pmitem = oircit
     C                   else
     C                   eval      pmitem = oiritm
     C                   endif
     C                   eval      pmexpd = expd
     *
     C                   eval      pmmfgd = 0
     C                   eval      pmtrn# = lbtrn#
     C                   eval      pmlbl# = lblbl#
     C                   if        *in78  = *off
     C                   update    pmrec
     C                   else
     C                   write     pmrec
     C                   endif
     *
     C                   endif
     C                   enddo
     C                   endif
     *
     C                   endsr
     *---------------------------------------------------------------
     *
     *  zzurcvSlot   Put license into RCV slot
     *
     C     zzurcvSlot    begsr

     *  Put license into a RCV slot

     C                   eval      #rcvArea = 'DOCK'

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #rcvwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = #rcvitem
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = #rcvstyp
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = expd
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #rcvitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0
     C                   eval      $saqty1 = oirqt1
     C                   eval      $saqty2 = oirqt2
     C                   eval      $saqty3 = oirqt3

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'RCV'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = pttrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = newlbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     C                   if        oirlcn <> *blanks
     C                   eval      $saToLcns = oirlcn
     C                   else
     C                   eval      $saToLcns = '*RT'
     C                                       + %editc(pttrn#:'X')
     C                   endif

     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea
     C                   eval      $saOLcnsU = *on

     C                   if        oirlcn = *blanks
     C                   eval      $saOLcns = $saToLcns
     C                   else
     C                   eval      $saOLcns = oirlcn
     C                   endif

     C                   eval      $dricommand = '*SLOT'
700aDC*                  eval      $drisubcmd  = '%RCVIN'
700aMC                   eval      $drisubcmd  = '%RTNIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error = *on
     C                   goto      endurcvslot
     C                   endif

     C     endurcvslot   endsr
     *----------------------------------------------------------------
     *
     *  ZZURTF   Update Files for Return
     *         Uses OIRLCN if entered or generates system license
     *
     C     zzurtf        begsr
     C                   eval      error = *off
     *
     C                   eval      @pgrp1 = 'R'
     *
     *
     *  Get batch number for labels.
     *
     C                   call      'PIRBAT#'
     C                   parm      *zeros        $pbat             7 0
     *
     *        Get transaction number.
     *
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#            7 0
     *
     *        Get transaction label
     *
     C                   call      'PIRLBL#'
     C                   parm                    newlbl#           7 0

     *  Create license

     C                   exsr      zzurcvSlot

     ***********************************************
     *
     *    - Create transaction record.
     *    - Create label record for each quantity type.
     *
     *        Create label record for Normal qty.
     *
     C                   clear                   lbrec
     C                   eval      lbwhse = $pwhse
     C                   eval      lbwhdp = #rcvwhdp
     C                   eval      lbaisl = *blanks
     C                   eval      lbloc = 0
     C                   eval      lbrlvl = 0
     C                   eval      lbhand = *blanks
     C                   eval      lbpseq = 0
     C                   eval      lbstyp = #rcvstyp
     C                   eval      lbqryf = 0
     C                   eval      lbdisp = *blanks
     C                   movel     '*MANUAL'     lbdsp2
     *      Mis-pick item return.
     C                   if        oircit > ' '
     C                   eval      lbitem = oircit
     C                   else
     C                   eval      lbitem = oiritm
     C                   endif
     C                   eval      lbseq = 0
     C                   eval      lbpbat = $pbat
     C                   eval      lbpo = *blanks
     C                   eval      lbord = oirord
     C                   eval      lbtie = 0
     C                   eval      lbhigh = 0
     *        Create label record for Normal qty.
     C                   if        oirqt1 > 0 and #rcvtype <> 'S'
     C                   eval      lbutyp = 'N'
     C                   eval      lbqpck = oirqt1
     C                   eval      lbucod = #rcvum1
     C                   eval      lbucub = #rcvcube
     C     lbucub        mult      lbqpck        lbcube
     C                   eval      lbuwgt = #rcvswgt
     C     lbuwgt        mult      lbqpck        lbswgt
     C                   endif
     *
     *        Create label record for breakdown 1 qty.
     *
     C                   if        oirqt2 > 0 and #rcvtype <> 'S'
     C                             or oirqt1 > 0 and #rcvtype = 'S'
     C                   if        oirqt1 > 0 and #rcvtype = 'S'
     C                   eval      lbutyp = 'N'
     C                   eval      lbqpck = oirqt1
     C                   else
     C                   eval      lbutyp = '1'
     C                   eval      lbqpck = oirqt2
     C                   endif
     C                   eval      lbucod = #rcvum2
     C                   if        #rcvumq2 <> 0
     C     #rcvcube      div(h)    #rcvumq2      lbucub
     C     lbucub        mult      lbqpck        lbcube
     C     #rcvswgt      div(h)    #rcvumq2      lbuwgt
     C     lbuwgt        mult      lbqpck        lbswgt
     C                   endif
     C                   endif
     *
     *        Create label record for breakdown 2 qty.
     *
     C                   if        oirqt3 > 0 and #rcvtype <> 'S'
     C                             or oirqt2 > 0 and #rcvtype = 'S'
     C                   if        oirqt2 > 0 and #rcvtype = 'S'
     C                   eval      lbutyp = '1'
     C                   eval      lbqpck = oirqt2
     C                   else
     C                   eval      lbutyp = '2'
     C                   eval      lbqpck = oirqt3
     C                   endif
     C                   eval      lbucod = #rcvum3
     C                   if        #rcvumq2 <> 0  and
     C                             #rcvumq3 <> 0
     C     #rcvcube      div(h)    #rcvumq2      lbucub
     C     lbcube        div(h)    #rcvumq3      lbucub
     C     lbucub        mult      lbqpck        lbcube
     C     #rcvswgt      div(h)    #rcvumq2      lbuwgt
     C     lbswgt        div(h)    #rcvumq3      lbuwgt
     C     lbuwgt        mult      lbqpck        lbswgt
     C                   endif
     C                   endif
     *
     C                   eval      lbqalc = lbqpck
     C                   eval      lbtrn# = pttrn#
     C                   eval      lblbl# = newlbl#
     C                   eval      lbgrp1 = @pgrp1
     C                   eval      lbgrp2 = @pgrp2
     C                   eval      lbtype = 'P'
     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   write     lbrec
     *
     *
     *        Create transaction record.
     *
     C                   eval      @pwhdp = #rcvwhdp
     C                   eval      @pstyp = #rcvstyp
     *
     C                   call      @addtr
     C                   parm      '*CREATE '    @pcmd             8
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      'PUTRTN'      @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm      #rcvwhdp      @pwhdp            5
     C                   parm      #rcvstyp      @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      1             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'R'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     *    Update licinfo.

     C                   exsr      zzlicinfo
     *
     *  Create license record.
     *
     C                   if        oirlcn <> *blanks
     C                   eval      kylcns  = oirlcn
     C                   else
     C                   eval      kylcns  = $saToLcns
     C                   endif

     C     fileky        chain     license                            7978
     *
     C                   eval      liwhse = $pwhse
     **
     C                   if        oirlcn <> *blanks
     C                   eval      lilcns  = oirlcn
     C                   else
     C                   eval      lilcns  = $saToLcns
     C                   endif
     C                   eval      litrn# = pttrn#
     *     Record not found. Try adding record.
     *
     C                   if        *in79
     C                   write     lirec                                76
     C                   if        *in76
     C                   eval      error = *on
     C                   endif
     *     Initialize record fields before trying to add or update.
     *
     C                   eval      liwhse = $pwhse
     C                   if        oirlcn <> *blanks
     C                   eval      lilcns  = oirlcn
     C                   else
     C                   eval      lilcns  = $saToLcns
     C                   endif
     C                   eval      litrn# = pttrn#
     *
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZURTN   Create Returns like RN250
     *
     C     zzurtn        begsr
     C                   eval      error = *off
     *      If mispick, create exceptions for item and corresponding  .
     *      item.
     *      if both items don't have pick slots.
     C                   eval      exfdis = *blanks
     C                   if        oircit <> *blanks
     C                   eval      exitem = oiritm
     C                   eval      excitm = oircit
     C                   eval      exerid = 'MISPICK'
     C                   exsr      zzpslt
     C                   if        picksl = *off
     C                   movel     '*ORDER'      exfdis
     C                   exsr      zzexcp
     C                   eval      kyitem = oircit
     C                   eval      exitem = oircit
     C                   eval      excitm = oiritm
     C                   eval      exerid = 'MISPICK'
     C                   movel     '*PUT  '      exfdis
     C                   exsr      zzexcp
     C                   else
     *       Write adjustment for ordered item.
     C                   eval      ajcode = 'MO'
     C                   eval      kyitem = oiritm
     C                   exsr      fill$adj
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUSTRTN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     *       Write adjustment for physical item.
     C                   eval      kyitem = oircit
     C                   eval      ajcode = 'MP'
     C                   exsr      fill$adj
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   endif
     *
     C                   endif
     *
     *
     *      Product put away. Write history record and display message.
     C                   clear                   orrec
     C                   eval      orwhse = $pwhse
     C                   eval      ortrn# = pttrn#
     C                   eval      orord = oirord
     C                   eval      oritem = oiritm
     C                   eval      orqty1 = oirqt1
     C                   eval      orqty2 = oirqt2
     C                   eval      orqty3 = oirqt3
     C                   eval      orcwtr = oircwt
     *    Retrieve current date.
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      orrdte = $cvd8o
     C                   time                    orrtim
     C                   eval      orrusr = 'BATCHRTN'
     C                   eval      ortype = 'Q'
     C                   eval      ortrn# = oirtrn
     C                   eval      orpbat = $pbat
     C                   eval      orcitm = oircit
     C                   eval      orrcod = oirrcd
     C                   eval      ordcod = oirdcd
     C                   eval      oriinv = 'Y'
     C                   eval      orolb# = oirlbl
     C                   eval      orinv# = *zero
     C                   eval      orrmem = oirmem
     C                   eval      orslot = *blanks
     C                   eval      orudte = svdate
     C                   eval      orutim = svtime
     C                   write     orrec
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$license  Clear $license data structure fields
     *----------------------------------------------------------------

     C     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = 99990
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = $pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = 'BATCHRTN'
     C                   eval      $lnemp# = 99990
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

     C                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = 99990
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error
     C                   eval      error = *on

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C     enddricop     endsr

     *
     *----------------------------------------------------------------
     *  fill$adj   Fill $slot data structure fields for adjustment.
     *----------------------------------------------------------------

     C     fill$adj      begsr

     *  Initialize data structure

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = #rcvwhdp

     C                   eval      $sldispu = *on
     C                   if        ajcode = 'MO'
     C                   eval      $sldisp  = oslot
     C                   else
     C                   eval      $sldisp  = pslot
     C                   endif

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = kyitem

     C                   eval      $saqtyu  = *on
     C                   if        ajcode = 'MO'
     C                   eval      $saqty1  = oirqt1
     C                   eval      $saqty2  = oirqt2
     C                   eval      $saqty3  = oirqt3
     C                   else
     C                   eval      $saqty1  = oirqt1 * -1
     C                   eval      $saqty2  = oirqt2 * -1
     C                   eval      $saqty3  = oirqt3 * -1
     C                   endif

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = 0

     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = ajcode

     C                   eval      $samemou = *on
     C                   eval      $samemo  = ' '

     C                   eval      $sabyu   = *on
     C                   eval      $saby    = 'RTN'

     C                   endsr

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------

     c     zzzEnd        begsr
      /free

        if importError;
          sbstatus = 'E';
          sbtext   = 'Import completed with error(s). '
                   + 'See IMPSRTN file.';
          $pReturn = '*ERROR';
          $pMessage = sbtext;
        else;
          sbstatus = 'S';
          sbtext   = 'Import completed successfully';
        endif;

        exec sql
          update stgbatch
          set sbstatus = :sbstatus,
              sbtext   = :sbtext,
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = %trimr(sbtext) + ' - '
                    + 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- RN235S/zzzend';
          leavesr;
        endif;

760 A   if importError;
760 A     // if Staging Interface error report is scheduled then submit
760 A     // Use a timestamp as a session id.  MRCRPTSCH will call the
760 A     // update program to update the correct work file to report
760 A     exsr zzErrRpt;
760 A   endif;

      /end-free
     c                   endsr

760 A*----------------------------------------------------------------
760 A*  zzErrRpt   Send Error report for Staging File if scheduled
760 A*----------------------------------------------------------------
760 A
760 Ac     zzErrRpt      begsr
760 A /free
760 A
760 A *   Determine if scheduled, and if so what email to use based
760 A *   on current time compared to scheduled time(s).
760 A *   Loops thru BFCMRCRPRM looking for scheduled events and
760 A *   determining which one is closest to current time, but not
760 A *   after current time.
760aD     //currReport = 'BFCREPORTS.R40700';
760aM     currReport = 'BFCREPORTS.R42600';
760 A     // get the closest scheduled email address to current time.
760 A     // if email is return empty we assume not schedule and
760 A     // nothing is sent
760 A     schEmail=*blanks;
760 A     getSchTimeEml();

          // if email is returned then send out requested error report
          if schEmail <> *blanks;
            orient = 'P';
            grDev=*blanks;
            // Format URL
            // Note: pdf fields are genreated by MRCRPTSCH program
            url = '&OUTFMT=11'
                + '&D_DETAIL=1'
760aD           //+ '&CALCULA001=' + %char(%timestamp())
760aD           //+ '&CALCULA002=' + %char($pWhse)
760aD           //+ '&CALCULA003=' + $pBatid;
760aM           + '&R001=' + %char($pWhse)
760aM           + '&R002=' + $pBatid;

760aA       // Call program to populate Subject and Email Body to
760aA       // file intlog.  These are printed on Email error Report
760aA       // R42600 called below
760aA       wintlog ($pWhse:$pBatid);

            // Call program to print report

            monitor;

760 A         // get iSeries user and jobd from Report Scheduling
760 A         exec sql select opmusr,opjobd into :opmusr,:opjobd
760 A                   from opsmrcrpt
760 A                where opwhse=:$pwhse
760 A               fetch first row only;
760 A         if sqlstt = '00000';
760 A            sbmusr = opmusr;
760 A            sbmjobd = opjobd;
760 A            sbmlibl = '*JOBD';
760 A         else;
760 A            sbmusr = '*CURRENT';
760 A            sbmjobd = '*USRPRF';
760 A            sbmlibl = '*CURRENT';
760 A         endif;
760 A
760 A         cmd = 'sbmjob '
760 A               +   'cmd('
760 A               +      'MRCRPTSCH ' +
760 A                    'WHSE(' + %char($pwhse) + ') '  +
760 A                    'RPTNAM(''' + %trim(currReport) + ''') ' +
760 A                    'URL(''' + %trim(url) + ''') ' +
760 A                    'EMAIL(' + sq + %trim(schEmail) + sq + ') ' +
760 A                    'PRINTER(' + sq + %trim(grdev) + sq + ') ' +
760 A                    'ORIENT(' + sq + %trim(orient) + sq + ')) ' +
760 A               'inllibl(' + %trim(sbmlibl) + ') ' +
760 A               'jobd(' + %trim(sbmjobd) + ') ' +
760 A               'user(' + %trim(sbmusr) + ') ' +
760 A               'jobq(QSYSNOMAX) ' +
760 A               'job(OI285SRSCH)';
760 A         qcmdexc(cmd: %len(cmd));

            on-error;
            endmon;
          endif;
760 A
760 A /end-free
760 Ac                   endsr

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------

     c     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp - current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *  zzzStart   Start processing
     *----------------------------------------------------------------

     c     zzzStart      begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'P',
              sbtext   = 'Import started',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbstrts  = current_timestamp,
              sbstruc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- RN235S/zzzstart';
          leavesr;
        endif;

        importError = *off;

      /end-free
     c                   endsr
760 A *----------------------------------------------------------------
760 A *  getSchTimeEml - Get Email address for specific error  report
760 A *----------------------------------------------------------------

760 Ap getSchTimeEml   b
760 Ad getSchTimeEml   pi

      *  Local Variables

     D weekday         s              3
     D currTime        s              5

            // Set 3 character value for day
            select;
              when DayofWeek(%date()) = 0;
                weekday = 'SUN';
              when DayofWeek(%date()) = 1;
                weekday = 'MON';
              when DayofWeek(%date()) = 2;
                weekday = 'TUE';
              when DayofWeek(%date()) = 3;
                weekday = 'WED';
              when DayofWeek(%date()) = 4;
                weekday = 'THU';
              when DayofWeek(%date()) = 5;
                weekday = 'FRI';
              when DayofWeek(%date()) = 6;
                weekday = 'SAT';
            endsl;

            // get current time (hh:mm)
            currTime = %subst(%char(%time():*ISO):1:5);

            // now query scheduled entries for closest
            // time to current system time that is active
            // for the current Report being processed
            exec sql select bsvalue into :schEmail
                from bfcmrcrprm as a where a.bswhse=:$pWhse and
              a.bsrptpgm=:currReport and a.bsmrctbl='E' and
              a.bsmrcprm='EMAIL' and
               (select b.bsvalue from bfcmrcrprm as b where
                 b.bswhse=a.bswhse and b.bsrptpgm=a.bsrptpgm and
                 b.bsschseq=a.bsschseq and b.bsmrctbl='D'
                 and b.bsmrcprm=:weekday)='Y' and
               (select min(b.bsvalue) from bfcmrcrprm as b where
                 b.bswhse=a.bswhse and b.bsrptpgm=a.bsrptpgm and
                 b.bsschseq=a.bsschseq and b.bsmrctbl='X'
                 and b.bsmrcprm='SCHTIME')<:currTime;

760 Ap getSchTimeEml   e
760 A*----------------------------------------------------------------*
760 A* Procedure:  DayOfWeek
760 A* Purpose:  Determine the day of week for a particular date
760 A* Parameters:
760 A*    I: dt   -- date
760 A* Returns:
760 A*    0..6    -- 0=Sunday, 1=Monday, 2=Tuesday, etc.
760 A* Notes:
760 A*    January 5, 1800 is a Sunday.  This procedure only works for
760 A*    dates later than 1800-01-05.
760 A*----------------------------------------------------------------*

760 AP DayOfWeek       b
760 AD DayOfWeek       pi            10i 0
760 AD   dt                            d   value datfmt(*iso)
      /free
        return %rem (%diff (dt: d'1800-01-05': *days): 7);
      /end-free
760 AP DayOfWeek       e

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
*EXIST*
*INVALID ITEM*
*BREAKDOWN INVALID*
*INVALID DATE*
*INVALID RETURN CODE*
*INVALID TRANS# *
*INVALID DISPOSITION*
*INVALID LABEL*
*INVALID LICENSE*
*INVALID MISPICK*
*INVALID LABEL ITEM*
