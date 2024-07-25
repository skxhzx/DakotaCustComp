600aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RN235     Import customer returns - Process
     *  Dave Sommerville/Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions
     *  Created using RN135, RN250 and RN246
     *
610aA*    08/21/09  DAS  6.10a
     *      - Revised zzbkdn to use #RCV fields.
     *      - Revised zzbkdn to only allow one qty field to be sent.
     *
610bA*    08/21/09  DAS  6.10b
     *      - Removed PIRITEM file.
     *      - Revised code that used IT fields to use #RCV fields.
     *      - Commented out code that moved '*****' into ITDESC.
     *        Doesn't look like it is needed because ITDESC is not
     *        used elsewhere in the program or printer file.
610cA*    08/28/09  DAS  6.10c
     *      - Fix:  SSB wasn't being handled correctly everywhere.
610dA*    08/27/09  MLB  6.10d
     *      - Replace IT900 with DRI to verify item, IT900 could not
     *        not run in bactch because of display file.
     *      - Revised program to remove calls to RN900, RD900 and
     *        PT900 because all 3 open DSPF's which is not allowed
     *        in batch processing.
     *      - Added files: RTNCODE, RDSCODE and PIRTRAN.
610eA*    09/01/09  RH   6.10e
     *      - Only write expiration date for date sensitive items.
610fA*    09/01/09  RH/MB  6.10f
     *      - Load OIRCIT into LBITEM when mis-pick return being processed
     *        else load OIRITM.
640a *    04/10/12  GJA  6.40a
     *      - Add client code.
     *
650 A*    03/08/13  MLB  6.50
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
650aA*    02/12/14  MLB  6.50a
     *      - Fix: Revised routine ZZURCV to set $SAOLCNS to the value of
     *        $SATOLCN when license sent from Host, OIRLCN = Blanks. Was
     *        not displaying correct tranaction/license information for
     *        return.
700aA*    01/05/16  LMC  7.00a
     *      - Enh: Returns now use RTNDOCK slots instead of RCVDOCK.
     *        We send RTNIN command in place of RCVIN.                as
     *
     *----------------------------------------------------------------
     *  Custom Client Revisions:  Glazier
GFCa *    04/10/12  GJA  GFCa
     *      - Remove edits, only allow item and license edits
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
     Fimpfrtn   uf   e           k disk
     FLabel     uf a e           k disk
     FLabel2    if   e           k disk
     F                                     rename(lbrec:record)
     FLabelnk   o  a e           k disk
     FLicense   uf a e           k disk
610bDF*iritem   if   e           k disk
610dAFpirtran   if   e           k disk
     Fpomfr1    uf a e           k disk
610dAFrdscode   if   e           k disk
610dAFrtncode   if   e           k disk
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
GFCaA /copy qcopysrc,id#glazier

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
     D error           s              1
     D expd            s              8  0
     D first           s              1
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
640aAD @getcl          c                   const('GETCLIENT')
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
     D*          sds
     D* #prog            *program
     D* #job                 244    253
     D* #user                254    263
     D* #jobn                264    269
     D* #jobdt               276    281  0
     D* #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHS   Warehouse to process.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs            15 5
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * Main line
     *
     *
     * Whip through all the download records
     *
     C                   eval      pflag = *off
     C                   eval      eofh = *off
     C                   eval      linppg = 55
     C                   eval      count = 0
     C*    oirkey        setll     impfrtn
     C                   dou       eofh = *on
     *
     C                   read      impfrtn                                79
     C                   if        *in79
     C                   eval      eofh = *on
     C                   goto      enddoh
     C                   endif
     C                   if        oirsts <> ' '
     C                   iter
     C                   endif
     C                   eval      $pwhse = oirwhs
     *  Update import return status to in-process
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
     *                    EXSR ZRHEAD
     C                   if        oirlbl > 0
     C                   eval      rmemo = %trim(%editc(oirlbl:'4'))
     C                   else
     C                   eval      rmemo = oirlcn
     C                   endif
     C*                  movel     oirmem        rmemo
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
     C                   update    oirrec
     *
     C                   iter
     C                   else
     *   Add records for Return if no errors.
     *
     C**                 if        bad1 = 'N'
     *
     *    Get license options.
     C**                 exsr      zzlcns
     *    Set notify inventory control flag (can be set using Return code)
     C                   eval      woinvf='N'
     *
     C                   select
     C                   when      oirqt1 <> 0
     C*                  eval      woumt = 'N'
     C                   eval      w1qty = oirqt1
     C                   when      oirqt2 <> 0
     C*                  eval      woumt = '1'
     C                   eval      w1qty = oirqt2
     C                   when      oirqt3 <> 0
     C*                  eval      woumt = '2'
     C                   eval      w1qty = oirqt3
     C                   endsl
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
     *  Update import return status to compelte (4)
     *
     C                   eval      oirsts ='4'
     C                   time                    currtimestamp
     C                   eval      oirsdt = currtimestamp
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
     C*                  kfld                    oirwhs
     C*                  kfld                    oiritm
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
    DC**                 eval      $pwhse = 900
     C     *loval        setll     impfrtn
     C                   read      impfrtn
     C                   if        %eof(impfrtn)
     C                   eval      oirwhs = 001
     C                   endif
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
     C     *loval        setll     impfrtn
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
610aMC                             #rcvflg1 <> 'Y'
610aDC**                           itflg1 <> 'Y'
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endif
     *
     C                   if        oirqt3 <> 0  and
610aMC                             #rcvflg2 <> 'Y'
610aDC**                           itflg2 <> 'Y'
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endif

610aA*   Only allowed to send one qty type.
610aA
610aAC                   if        oirqt1<>0  and oirqt2<>0
610aAC                             or (oirqt1<>0  and oirqt3<>0)
610aAC                             or (oirqt2<>0  and oirqt3<>0)
610aAC                   eval      detmsg = desc(3)
610aAC                   add       1             badbrk
610aAC                   eval      bad1 = 'Y'
610aAC                   exsr      zzdet2
610aAC                   endif
610aA
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1  Verify return code and transaction #
     *
     C     zzchk1        begsr
     *       If item doesn't exist write error message,
     *          don't write to ORTNBAT file.
     *
     C**   itkey         chain     piritem                            76
     C**                 if        *in76
610dAC                   exsr      clr$item
610dDC*                  eval      $lcmd = '*VERIFY '
610dDC*                  eval      $lprg  = #prog
610dDC*                  eval      $lwhse = oirwhs
610dMC                   eval      $itwhse = oirwhs
610dDC*                  eval      $litem = oiritm
610dMC                   eval      $ititem = oiritm
610dDC*                  call      'IT900'
610dDC*                  parm                    $lparm
610dA*
610dAC                   exsr      zrvfyitm
610dA*
610dDC*                  if        $lrtn = '*PGMQ   '
610dMC                   If        $drireturn <> '*OK'
     C                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   add       1             baditm
610bDC**                 eval      itdesc = *blanks
610bDC**                 movel     '*****'       itdesc
     C                   eval      bad1 = 'Y'
     C                   exsr      zzdet2
     C                   endif
     *  If corresponding item doesn't exist (mispick)
     *    write error message, don't write to ORTNBAT file.
     *
     C                   if        oircit <> ' '
610dAC                   exsr      clr$item
610dDC*                  eval      $lcmd = '*VERIFY '
610dDC*                  eval      $lprg  = #prog
610dDC*                  eval      $lwhse = oirwhs
610dMC                   eval      $itwhse = oirwhs
610dDC*                  eval      $litem = oircit
610dMC                   eval      $ititem = oircit
610dDC*                  call      'IT900'
610dDC*                  parm                    $lparm
610dA*
610dAC                   exsr      zrvfyitm
610dA*
610dDC*                  if        $lrtn = '*PGMQ   '
610dMC                   If        $drireturn <> '*OK'
     C                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   add       1             badmpi
610bDC**                 eval      itdesc = *blanks
610bDC**                 movel     '*****'       itdesc
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
610dDC*                  call      'RN900'
610dDC*                  parm                    $lparm
610dAC     oirrcd        setll     rtncode
610dDC*                  if        $lrtn = '*ERROR  '
610dAC                   if        not %equal(rtncode)
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
610dDC*                  call      'RD900'
610dDC*                  parm                    $lparm
610dAC     oirdcd        setll     rdscode
610dDC*                  if        $lrtn = '*ERROR  '
610dAC                   if        not %equal(rdscode)
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
610b *  Verify label #.
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
610dDC*                  call      'PT900'
610dDC*                  parm                    $lparm
610dAC     oirtrn        setll     pirtran
610dDC*                  if        $lrtn = '*PGMQ   '
610dMC                   if        not %equal(pirtran)
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
610bDC**   itkey         chain     piritem                            79
610bDC**                 if        not *in79
610bDC**                 eval      exwhdp = itwhdp
610bDC**                 eval      exstyp = itstyp
610bMC                   eval      exwhdp = #rcvwhdp
610bMC                   eval      exstyp = #rcvstyp
610bDC**                 else
610bDC**                 eval      exwhdp = *blanks
610bDC**                 eval      exstyp = *blanks
610bDC**                 endif
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
    DC*                  parm      exitem        #sitem           15
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
     **                   MOVE $PITEM    EXITEM
     **                   MOVE W2CITM    EXCITM
650 A*
650 AC                   if        oirqt1 > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
     C                   z-add     oirqt1        exqty
650 AC                   endif
650 A*
650 AC                   if        oirqt2 > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
     C                   eval      exqty2 = oirqt2
650 AC                   endif
650 A*
650 AC                   if        oirqt3 > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
     C                   eval      exqty3 = oirqt3
650 AC                   endif
650 A*
     **                   MOVE *BLANKS   EXFDIS
     C                   eval      extask = 'PUTRTN'
     **                   MOVE 'MISPICK' EXERID
     *    Retrieve current date.
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *R                   Z-ADDTODAY     EXGDTE
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
     C*                  else
     C*                  eval      obredt = expd
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
610fA*  Use mis-pick picked item.
610fAC                   if        oircit > ' '
610fAC                   eval      $ititem = oircit
610fAC                   else
     C                   eval      $ititem  = oiritm
610fAC                   endif

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
610dA*----------------------------------------------------------------
610dA*
610dA*  ZRVFYITM   Verify Item using DRI interface
610dA*
610dAC     zrvfyitm      begsr
610dA*
610dAC                   eval      $dricommand = '*ITEM'
610dAC                   eval      $drisubcmd  = '%GETALL'
610dAC                   eval      $drisys2upd = 'D'
610dAC                   exsr      zzzdricop
610dA*
610dAC                   endsr
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

610eDC*                  if        oiredt > 0
610eMC                   if        expd > 0
     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*EXPDTE'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = expd
     C                   endif

610eDC*                  if        oiredt > 0
610eMC                   if        expd > 0
     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*DATEIN '
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'N'
     C                   eval      $lnvalchr(3) = ' '
     C                   eval      $lnvalnum(3) = expd
     C                   endif

     *  W1FIFO is not entered for returns, only movein PO.
     C*                  if        $pfifo > 0
     C*                  eval      $lncodeu(4) = *on
     C*                  eval      $lncode(4) = '*FIFODTE'
     C*                  eval      $lncseq(4) = 1
     C*                  eval      $lnvaltyp(4) = 'N'
     C*                  eval      $lnvalchr(4) = ' '
     C*                  eval      $lnvalnum(4) = $pfifo
     C*                  endif

     C*                  eval      $lncodeu(5) = *on
     C*                  eval      $lncode(5) = '*AVGWGT'
     C*                  eval      $lncseq(5) = 1
     C*                  eval      $lnvaltyp(5) = 'N'
     C*                  eval      $lnvalchr(5) = ' '
     C*                  eval      $lnvalnum(5) = $pcwgt

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
500eDC*                  parm      exitem        #sitem
500eMC                   parm      $ititem       #sitem
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
610eDC*                  if        oiredt <> 0
610eMC                   if        expd <> 0
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
610cDC**                 select
610cDC**                 when      oirqt1 > 0  and #rcvtype <> 'S'
     C                   eval      $saqty1 = oirqt1
610cDC**                 when      oirqt2 >0
     C                   eval      $saqty2 = oirqt2
610cDC**                 when      oirqt1 > 0 and #rcvtype = 'S'
610cDC**                 eval      $saqty2 = oirqt1
610cDC**                 when      oirqt3 > 0
     C                   eval      $saqty3 = oirqt3
610cDC**                 endsl

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

650aAC                   if        oirlcn = *blanks
650aAC                   eval      $saOLcns = $saToLcns
650aAC                   else
     C                   eval      $saOLcns = oirlcn
650aAC                   endif

     C                   eval      $dricommand = '*SLOT'
700aDC*                  eval      $drisubcmd  = '%RCVIN'
700aMC                   eval      $drisubcmd  = '%RTNIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C**                 eval      zmflag  = *on
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
     C***                eval      tmpflg = *off
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
610fA*      Mis-pick item return.
610fAC                   if        oircit > ' '
610fAC                   eval      lbitem = oircit
610fAC                   else
     C                   eval      lbitem = oiritm
610fAC                   endif
     C                   eval      lbseq = 0
     C                   eval      lbpbat = $pbat
     C                   eval      lbpo = *blanks
     C                   eval      lbord = oirord
610cDC**                 eval      lbqalc = oirqt1
610cDC**                 eval      lbqpck = oirqt1
     C                   eval      lbtie = 0
     C                   eval      lbhigh = 0
     *        Create label record for Normal qty.
     C*                  if        woumt = 'N'
610cDC**                 if        oirqt1> 0
610cMC                   if        oirqt1 > 0 and #rcvtype <> 'S'
     C                   eval      lbutyp = 'N'
610cAC                   eval      lbqpck = oirqt1
     C                   eval      lbucod = #rcvum1
     C                   eval      lbucub = #rcvcube
610cMC     lbucub        mult      lbqpck        lbcube
     C                   eval      lbuwgt = #rcvswgt
610cMC     lbuwgt        mult      lbqpck        lbswgt
     C                   endif
     *
     *        Create label record for breakdown 1 qty.
     *
     C*                  if        woumt = '1'
610cDC**                 if        oirqt2> 0
610cMC                   if        oirqt2 > 0 and #rcvtype <> 'S'
610cMC                             or oirqt1 > 0 and #rcvtype = 'S'
610cMC                   if        oirqt1 > 0 and #rcvtype = 'S'
610cAC                   eval      lbutyp = 'N'
610cAC                   eval      lbqpck = oirqt1
610cAC                   else
     C                   eval      lbutyp = '1'
610cAC                   eval      lbqpck = oirqt2
610cAC                   endif
     C                   eval      lbucod = #rcvum2
     C                   if        #rcvumq2 <> 0
     C     #rcvcube      div(h)    #rcvumq2      lbucub
610cMC     lbucub        mult      lbqpck        lbcube
     C     #rcvswgt      div(h)    #rcvumq2      lbuwgt
610cMC     lbuwgt        mult      lbqpck        lbswgt
     C                   endif
     C                   endif
     *
     *        Create label record for breakdown 2 qty.
     *
     C*                  if        woumt = '2'
610cDC**                 if        oirqt3> 0
610cMC                   if        oirqt3 > 0 and #rcvtype <> 'S'
610cMC                             or oirqt2 > 0 and #rcvtype = 'S'
610cMC                   if        oirqt2 > 0 and #rcvtype = 'S'
610cAC                   eval      lbutyp = '1'
610cAC                   eval      lbqpck = oirqt2
610cAC                   else
     C                   eval      lbutyp = '2'
610cAC                   eval      lbqpck = oirqt3
610cAC                   endif
     C                   eval      lbucod = #rcvum3
     C                   if        #rcvumq2 <> 0  and
     C                             #rcvumq3 <> 0
     C     #rcvcube      div(h)    #rcvumq2      lbucub
     C     lbcube        div(h)    #rcvumq3      lbucub
610cMC     lbucub        mult      lbqpck        lbcube
     C     #rcvswgt      div(h)    #rcvumq2      lbuwgt
     C     lbswgt        div(h)    #rcvumq3      lbuwgt
610cMC     lbuwgt        mult      lbqpck        lbswgt
     C                   endif
     C                   endif
     *
610cAC                   eval      lbqalc = lbqpck
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
610b C****               eval      $prtn = '*OK     '
610b C****               eval      $pord = $pbat
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
610aDC**                 eval      $drisubcmd  = '%ADJUST'
610aMC                   eval      $drisubcmd  = '%ADJUSTRTN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     *       Write adjustment for physical item.
     C                   eval      kyitem = oircit
     C                   eval      ajcode = 'MP'
     C                   exsr      fill$adj
     C                   eval      $dricommand = '*SLOT'
610fAC                   eval      $drisys2upd = 'D'
610fAC                   exsr      zzzdricop
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
     *R                   Z-ADD0         ORORD
     C                   eval      oritem = oiritm
     C                   eval      orqty1 = oirqt1
     C                   eval      orqty2 = oirqt2
     C                   eval      orqty3 = oirqt3
     *R                   Z-ADD0         ORCWTR
     C                   eval      orcwtr = oircwt
     *    Retrieve current date.
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *R                   Z-ADDTODAY     ORRDTE
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
     C**                                                               o '

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
610x C**  Update status OIRSTS to 3=error.                             o '

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

     C*                  eval      ck4err = *off
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
610bDC**   itkey         chain     piritem                            79
610bDC**                 if        not *in79
610bDC**                 eval      $slwhdp = itwhdp
610bMC                   eval      $slwhdp = #rcvwhdp
610bDC**                 else
610bDC**                 eval      $slwhdp = *blanks
610bDC**                 endif
     C**                 eval      $slwhdp  = $pwhdp

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
