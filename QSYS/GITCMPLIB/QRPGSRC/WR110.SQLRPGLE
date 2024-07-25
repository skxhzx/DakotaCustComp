     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  WR110     Work orders / Repack - Display
     *  19 February 2007
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    07/19/07  DAS  5.10
     *      - Created
     *
510aA*    03/26/07  TJ   5.10a
     *      - Add additional fields to subfile; add View 2.
     *      - Retrieve item description using DRIITEM.
     *
530 A*    03/22/10  JCJ  5.30
     *      - ENH: added code to allow multiple W/O's to be closed
     *        when the ENTER key is pressed.
     *
530aA*    04/13/10  JCJ  5.30a
     *      - ENH: added option 6 to print repack labels.
     *
650bA*    05/30/10  KDE  6.50b
     *      - Fix: increased item number to full 15 positions sfl
     *
650cA*    02/02/15  KDE  6.50c
     *      - Fix: When taking multiple options from screen one only
     *        the last option was being processed for all selections
     *        Changed to use saved options array
     *
700aA*    12/07/15  JCJ  7.00a
     *      - Fix: When parent UOM is quantity is 0, force it to 1 to
     *        avoid a DDE divide by 0 problem.
     *
710 A*    08/25/17  KDE  7.10
     *      - Enh: Add screen sort by Item
     *
710aA*    09/05/17  KDE  7.10a
     *      - Enh: Remove Repack Replenishments from PRPLFIL once
     *        completed
740aA*    06/04/20  RH   7.40a
     *      - Fix: Was not getting total made for W1MADE.
740bA*    09/08/20  KDE  7.40b
     *      - Enh: Allow breakdown as zero when using case quantity
760aA*    03.04/22  JCJ  7.60a
     *      - Enh: added Work order#, pack description, Ref note to
     *        repack label.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position Cursor
     *  21 - 29   Field Input Error (Reverse Display)
     *  79        Chain Indicator
     *  90        Protect Input Fields for Delete Display
     *  97        Used by error message subfile
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

650bMF*wr110fm   cf   e             workstn
710 DF*wr11001   cf   e             workstn
700aDF*wr11002   cf   e             workstn
700aMFwr11003   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
     Fkitordh   if   e           k disk
     F                                     rename(kohrec:recordu)
510aD ***kitordh1  if   e           k disk
510aMFkitordh4  if   e           k disk
     F                                     rename(kohrec:record)
710 AFkitordh5  if   e           k disk
710 AF                                     rename(kohrec:record5)
510aAFkitordd   if   e           k disk
510aAF                                     rename(kodrec:recordd)
510aAFkitcomp   if   e           k disk
530aAFlblfmtd   if   e           k disk
530aAFunmesr    if   e           k disk
530aAFslot3     if   e           k disk
760aAFlabel93   if   e           k disk
760aAFlicense1  if   e           k disk

510aA*----------------------------------------------------------------
510aA*  DRI parameters
510aA*----------------------------------------------------------------
510aA
510aA /COPY *libl/qcopysrc,C#DRIPARMS
500dA /COPY *libl/qcopysrc,C#ITEM
500dA /COPY *libl/qcopysrc,C#ITEMQTY
500dA /COPY *libl/qcopysrc,C#SLOT
500dAD saveVer#        s                   like($slver#)
500dAD save$slot       s                   like($slot)
510aA
     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
710 DD*cmdln           s             79    dim(2) ctdata perrcd(1)
710 AD cmdln           s             79    dim(4) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Client data structures
     *----------------------------------------------------------------

510aA*COPY QCOPYSRC,ID#PACKERS

     *----------------------------------------------------------------
     *  Partial key redefinition
     *----------------------------------------------------------------

     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0

     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *----------------------------------------------------------------

     D                 ds
     D  dsfkey                 1     50
510aMD   fwhs                  1      3  0 inz(0)
510aAD   fndt                  4     11  0 inz(0)
     D   ford                 12     18  0 inz(0)
     D   fitm                 19     33

     D                 ds
     D  dsukey                 1     50
     D   ukwhse                1      3  0 inz(0)
510aAD   ukndt                 4     11  0 inz(0)
     D   ukord                12     18  0 inz(0)
     D   ukitem               19     33

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

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
510aAD  $lndt                 22     29  0
510aAD  $lord                 30     36  0
510aAD  $litem                37     51

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @chgpg          c                   const('WR112')
     D @delpg          c                   const('WR114')
530aAD @prtpg          c                   const('WR300')
     D @plfmtl         c                   const('REPACK ')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D                                     dim(3)
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
510aA
510aA*   Redefine key
510aA
510aAD  $pwhse                19     21  0

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     dim(128)

     *----------------------------------------------------------------
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371

     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *----------------------------------------------------------------

     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

510aAD                 ds
510aAD  w1pqndec               1      5  2
510aAD  dec                    4      5  0
     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
530aAD @lblset         s              6
     D bot             s              1
     D kitcount        s              4  0
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forceb          s              1
740aAD forevr          s              1
760aAD forever         s              1
     D frstky          s                   like($puky)
710 Ad f9sort          s              1  0
     D gobrtk          s              2  0
     D help            s              5  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D top             s              1
     D warn            s              1
510aAD zmsflag         s               n
510aAD maxvw           s              1  0
510aAD view            s              1  0
510aAD v               s              2  0
     D x               s              3  0
     D y               s              3  0
530aAD kyitem          s             15
530aAD kystat          s              2    inz('A ')
530aAD kypick          s              1    inz('Y')
510aAD #parentitwhse   s                   like($itwhse)
510aAD #parentititem   s                   like($ititem)
510aAD #parentittype   s                   like($ittype)
510aAD #parentitdesc   s                   like($itdesc)
510aAD #parentitpdsc   s                   like($itpdsc)
510aAD #parentithead   s             70
510aAD #parentitwhdp   s                   like($itwhdp)
510aAD #parentitstyp   s                   like($itstyp)
510aAD #parentitdesg   s                   like($itdesg)
510aAD #parentitum1    s                   like($itum1)
510aAD #parentitflg1   s                   like($itflg1)
510aAD #parentitum2    s                   like($itum2)
510aAD #parentitumq2   s                   like($itumq2)
510aAD #parentitflg2   s                   like($itflg2)
510aAD #parentitum3    s                   like($itum3)
510aAD #parentitumq3   s                   like($itumq3)
510aAD #parentitnrpk   s                   like($imnrpk)
510aAD #parentitflgd   s                   like($itflgd)
510aAD #parentitcube   s                   like($itcube)
510aAD #parentitswgt   s                   like($itswgt)
510aAD #parentitcwgt   s                   like($itcwgt)
510aAD #parentitmitem  s                   like($itmitem)
510aAD #parentitsdef   s                   like($idsdef)
510aAD #parentittie    s                   like($idtie)
510aAD #parentithigh   s                   like($idhigh)

510aAD #repackitwhse   s                   like($itwhse)
510aAD #repackititem   s                   like($ititem)
510aAD #repackittype   s                   like($ittype)
510aAD #repackitdesc   s                   like($itdesc)
510aAD #repackitpdsc   s                   like($itpdsc)
510aAD #repackithead   s             70
510aAD #repackitwhdp   s                   like($itwhdp)
510aAD #repackitstyp   s                   like($itstyp)
510aAD #repackitdesg   s                   like($itdesg)
510aAD #repackitum1    s                   like($itum1)
510aAD #repackitflg1   s                   like($itflg1)
510aAD #repackitum2    s                   like($itum2)
510aAD #repackitumq2   s                   like($itumq2)
510aAD #repackitflg2   s                   like($itflg2)
510aAD #repackitum3    s                   like($itum3)
510aAD #repackitumq3   s                   like($itumq3)
510aAD #repackitnrpk   s                   like($imnrpk)
510aAD #repackitflgd   s                   like($itflgd)
510aAD #repackitcube   s                   like($itcube)
510aAD #repackitswgt   s                   like($itswgt)
510aAD #repackitcwgt   s                   like($itcwgt)
510aAD #repackitmitem  s                   like($itmitem)
510aAD #repackitsdef   s                   like($idsdef)
510aAD #repackittie    s                   like($idtie)
510aAD #repackithigh   s                   like($idhigh)

510aAD chk4err         s               n
510aAD drierr          s               n
530aAD iso             s               d   Datfmt(*ISO) Inz
530aAD mdy             s               d   Datfmt(*mdy) Inz

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
     *
     *  Define keys
     *
     *     WORKOPT  (Unique key)
     *
     C     wkounq        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    wkokyf
     C                   kfld                    wkokyu
     *
     *     WORKOPT  (Partial key)
     *
     C     wkoprt        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     *
     *     WORKOPT  (Save key for top record on delete display)
     *
     C     deltop        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    $wkof
     C                   kfld                    $wkou
530aA*
530aA*     UNMESR
530aA*
530aAC     uomkey        klist
530aAC                   kfld                    #repackitum1
530aA*
530aA*     Slot
530aA*
530aAC     keys3         klist
530aAC                   kfld                    $kwhse
530aAC                   kfld                    kyitem
530aAC                   kfld                    kystat
530aAC                   kfld                    kypick

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

510aA* Get client id.
510aA
510aAC                   call      'GETCLIENT'
510aAC                   parm                    client           10
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo

     *   Do some clean up before leaving.

     C                   exsr      zsclr
     C                   exsr      clrsch
     C                   seton                                        lr

     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *----------------------------------------------------------------

     C     dspscr        begsr

     *   Set ON alarm indicator if error occured

     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif

     *   Set OFF command key indicators

     C                   setoff                                       kckekf
     C                   setoff                                       kl

     *   Overlay screen with title

     C                   write     title

     *   Overlay screen with error messages

     C                   exsr      zmdmsg

     *   Overlay screen with subfile screen

     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      deldsp
     C                   endif

     *   Initialize error indicators and fields

700aMC                   setoff                                       202122
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
510aAC                   select
510aAC                   when      view = 1
     C                   read      dspsfc                                 50
510aAC                   when      view = 2
510aAC                   read      vw2sfc                                 50
510aAC                   endsl
     *
     C                   endsr

     *----------------------------------------------------------------
     *     Screen initialization and wrap-up routines
     *----------------------------------------------------------------

     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endsr

     *----------------------------------------------------------------
     *  Screen 02 initialization
     *----------------------------------------------------------------

     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     clr0306
     C                   write     delrec
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   write     cmddel
     C                   endsr

     *----------------------------------------------------------------
     *  Screen 02 wrap-up
     *----------------------------------------------------------------

     C     scr02e        begsr
     C                   eval      nxtscr = '01 '
     C                   eval      *in90 = *off
     C                   write     clr0306
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = frstky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
     C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
     C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *              Screen Processing Routines
     *----------------------------------------------------------------

     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
     C     endsc1        endsr
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
     C                   endcs
     C     endsc2        endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
     C                   write     dspsfl                               79
510aAC                   write     vw2sfl                               79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr

     *----------------------------------------------------------------
     *  CLRSCH   Clear everything out of work file
     *----------------------------------------------------------------

     C     clrsch        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   endsr

     *----------------------------------------------------------------
     *  CMD01    Screen 1 command key routine
     *----------------------------------------------------------------

     C     cmd01         begsr
     *
     *  TEST FOR CMD3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        10            x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl
     C                   endif
510aAC     x             chain     vw2sfl                             79
510aAC                   if        not *in79
510aAC                   eval      option = '  '
510aAC                   update    vw2sfl
510aAC                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     *on           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD6 - ADD RECORD
     *
     C                   if        *inkf
     C                   exsr      inzpar
510aD ***                eval      $pcmd = '*ADD    '
510aMC                   eval      $lcmd = '*ADD    '
     C                   call      @chgpg
     C                   parm                    $lparm
510aD ***                if        $prtn = '*ERROR  '
510aMC                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
510aD ***                if        $prtn = '*PGMQ   '
510aMC                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
510aD ***                if        $prtn <> '*CANCEL '  and
510aD ***                          $prtn <> '*EXIT   '
510aMC                   if        $lrtn <> '*CANCEL '  and
510aMC                             $lrtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
510aD ***                eval      $pouky = $puky
510aAC                   eval      $pouky = $luky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
     C                   endif
220 AC                   eval      pagcmd = '*REFRESH'
220 AC                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
     C                   if        *inkj
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       10            row#
     C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     *R         CLERR     CABEQ*ON       CMD01E
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
510aA*
510aA*  Test for Cmd11 - Next view
510aA*
510aAC                   if        *inkk
510aAC                   if        view = maxvw
510aAC                   eval      view = 1
510aAC                   else
510aAC                   add       1             view
510aAC                   endif
510aAC                   eval      v = view
710 DC*                  eval      cmdln1 = cmdln(v)
710 A /free
710 A                    cmdln1 = %subst(cmdln(v):1:30) + '  ' +
710 A                             %trim(cmdln(f9sort)) +
710 A                             %subst(cmdln(v):31:25);
710 A /end-free
510aA*
710 DC*                  goto      cmd01e
510aAC                   endif
710 A*
710 A*  Test for Cmd9 - Sort by either Work Order or Item
710 A*
710 AC                   if        *inki
710 AC                   eval      v = view
710 Ac                   if        f9sort=3
710 Ac                   eval      Ptsort='** by Item **'
710 Ac                   eval      Ptsortd='  Position by Item Needed'
710 Ac                   eval      *in95=*on
710 Ac                   eval      f9sort=4
710 Ac                   else
710 Ac                   eval      Ptsort='** by Work Order **'
710 Ac                   eval      Ptsortd='  Position by Date Needed'
710 Ac                   eval      *in95=*off
710 Ac                   eval      f9sort=3
710 Ac                   endif
710 A /free
710 A                    cmdln1 = %subst(cmdln(v):1:30) + '  ' +
710 A                             %trim(cmdln(f9sort)) +
710 A                             %subst(cmdln(v):31:25);
710 A                    exsr clrsch;
710 A                    exsr scr01i;
710 A /end-free
710 Ac                   endif
710 AC*
710 AC                   if        *inki or *inkk
710 AC                   goto      cmd01e
710 Ac                   endif
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd01e        endsr

     *----------------------------------------------------------------
     *  CMD02    Screen 2 command key routine
     *----------------------------------------------------------------

     C     cmd02         begsr
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      scr02e
     C                   goto      cmd02e
     C                   endif
     C     cmd02e        endsr

     *----------------------------------------------------------------
     *  DELADD   Add record to subfile for delete display
     *----------------------------------------------------------------

     C     deladd        begsr
     C                   if        recno < 11
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *R         CLERR     CABEQ*ON       DELADE
     *
     *  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     *
     C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
     C                   endif
     C                   eval      dsfkey = wkokyf
     C                   eval      dsukey = wkokyu
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
510aA*  Get Repack Item information.
510aAC                   exsr      zzgetrepackit
510aA*  Get Parent Item information.
510aAC                   exsr      zzgetparentit
     C                   exsr      zzfill
     C                   eval      option = wkoopt
     C                   write     dspsfl
510aAC                   write     vw2sfl
     C                   endif
     C     delade        endsr

     *----------------------------------------------------------------
     *  DELDSP   Display subfile of records marked for deletion
     *----------------------------------------------------------------

     C     deldsp        begsr
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
510aD ***                eval      *in01 = *on
510aMC                   eval      *in81 = *on
     C                   eval      recno = 1
510aAC                   select
510aAC                   when      view = 1
     C                   write     dspsfc
510aAC                   when      view = 2
510aAC                   write     vw2sfc
510aAC                   endsl
     C                   endsr

     *----------------------------------------------------------------
     *  ENT01    Screen 1 enter key routine
     *----------------------------------------------------------------

     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     *on           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     *R         OTAKEN    IFEQ *OFF
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   END
     C     ent01e        endsr

     *----------------------------------------------------------------
     *  ENT02    Screen 2 enter key routine
     *----------------------------------------------------------------

     C     ent02         begsr
     *
     *  Save first delete key.
     *
     C                   eval      frstky = $puky
     *
     *  Delete the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   if        wkoopt = ' 4'
     *
     *  Call delete program
     *
     C                   exsr      inzpar
510aD ***                eval      $pcmd = '*DELETE '
510aMC                   eval      $lcmd = '*DELETE '
510aD ***                eval      $puky = wkokyu
530 AC                   eval      $luky = wkokyu
530 D ***                eval      $lord = w1ord
530 D ***                eval      $litem = w1item
     C                   call      @delpg
     C                   parm                    $lparm
     *
     *     Error occured - Error message sent back
     *
510aD ***                if        $prtn = '*ERROR  '
510aMC                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
510aD ***                if        $prtn = '*PGMQ   '
510aMC                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     *
     *     Delete canceled
     *
510aD ***                if        $prtn = '*CANCEL '
510aMC                   if        $lrtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   else
     *
     *     Delete was successful.
     *
510aD ***                if        $prtn = '*OK     '
510aMC                   if        $lrtn = '*OK     '
     C                   eval      #msgk = $pmsg
510aD ***                exsr      zmqmsg
510aMC                   exsr      zmpmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   if        cancel = *off
     C                   delete    wkorec
     C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   endif
     *
     C                   endif
     C                   enddo
     C                   exsr      scr02e
     C     ent02e        endsr

     *----------------------------------------------------------------
     *
     *  FGTWAY   Gateway to file handling routines
     *
     *    Input Parameters
     *      $POCMD   *INIT    - Initialize and return
     *               *GET     - Get record for $POUKY value
     *               *GETNEXT - Get next record
     *               *GETPREV - Get previous record
     *               *WRITPOS - Write position record to display
     *               *READPOS - Read position record
     *               *POSTN2  - Position to $POFKY
     *               *POSTN2U - Position to $POUKY
     *               *TOP     - Position to top of file
     *               *BOTTOM  - Position to bottom of file
     *      $POFKY   Key for positioning within file
     *      $POUKY   Unique key used for change/delete operations
     *
     *    Returned Parameters
     *      $PORTN   *NOMORE  - Beginning/End of file was reached
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took place
     *               *ERROR   - Error occured
     *      $POERM   Error message
     *
     C     fgtway        begsr
     C                   eval      $portn = *blanks
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
     C                   endcs
     C                   endsr
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  FGET     Get record using file with unique key
     *----------------------------------------------------------------

     *              In this case the lookup file and the unique key
     *              file are the same.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C**   fileky        chain     record                             79
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   exsr      zzkeyi
     C**                 eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  FGETN    Get next record
     *----------------------------------------------------------------

     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     C**                 eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  FGETP    Get previous record
     *----------------------------------------------------------------

     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     C**                 eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  FPOS2    Position to record
     *----------------------------------------------------------------

     C     fpos2         begsr
     C                   eval      dsfkey = $pofky
510aD ***  fileky        setll     record
710 Ac                   if        f9Sort=3
510aMC     partky2       setll     record
710 A /free
710 A                    else;
710 A      setll ($kwhse:kohitm:kohord) record5;
710 A                    endif;
710 A /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  FPOS2U   Position to record using unique key
     *----------------------------------------------------------------

     C     fpos2u        begsr
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     C                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     C                   exsr      fpos2
     C                   endsr

     *----------------------------------------------------------------
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *----------------------------------------------------------------

     C     inzpar        begsr
510aD ***                clear                   $parms
510aMC                   clear                   $lparm
     C                   eval      $lprg = #prog
     C                   eval      $luky = $prtky
     C                   endsr

     *----------------------------------------------------------------
     *  OPTNS    Perform options that user entered
     *----------------------------------------------------------------

     C     optns         begsr
     C                   eval      otaken = *off
     *
     *     DO ALL DELETES FIRST (OPTION 4)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 4'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 4'
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
     C                   goto      optnse
     C                   endif
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = *on  or
     C                             cancel = *on
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = *off
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = *on
     C                   eval      stop = *on
     C                   if        error = *on
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $luky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        refrsh = *on
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C     optnse        endsr

     *----------------------------------------------------------------
     *  OPTNS2   Execute individual options
     *----------------------------------------------------------------

     C     optns2        begsr
     C                   exsr      inzpar
510aD ***                eval      $puky = wkokyu
650cAc                   eval      $luky = wkokyu
     *
     *   Change
     *
     C                   if        wkoopt = ' 2'
510aD ***                eval      $pcmd = '*CHANGE '
510aMC                   eval      $lcmd = '*CHANGE '
650cDC*                  eval      $lord = w1ord
650cDC*                  eval      $litem = w1item
     C                   call      @chgpg
     C                   parm                    $lparm
     C                   else
     *
     *   View
     *
     C                   if        wkoopt = ' 5'
510aD ***                eval      $pcmd = '*VIEW   '
510aMC                   eval      $lcmd = '*VIEW   '
650cDC*                  eval      $lord = w1ord
650cDC*                  eval      $litem = w1item
     C                   call      @chgpg
     C                   parm                    $lparm
     C                   else
     *
     *   Print
     *
     C                   if        wkoopt = ' 6'

760aAC                   exsr      zzgetlicense

530aD ***                eval      $pcmd = '*PRINT  '
530aMC                   eval      $lcmd = '*REPACK '

530aAC                   eval      $ldisp = *blanks
530aAC                   eval      kyitem = w1item
530aAC     keys3         setll     slot3
530aAC     keys3         reade     slot3
530aAC                   if        not %eof(slot3)
530aAC                   eval      $ldisp = sldisp
530aAC                   endif
530aAC                   if        w1nddt <> *zeros
530aAC     *iso          move      w1nddt        iso
530aAC                   move      iso           mdy
530aAC                   move      mdy           $ldate
530aAC                   endif

     C                   call      @prtpg
530aD ***                parm                    $lparm
530aDC                   parm                    $lcmd             8
530aDC                   parm      @lblset       $llset            6
530aDC                   parm      @plfmtl       $llfmt            8
530aDC                   parm      w1need        $copies           5 0
530aAC                   parm      $kwhse        $lwhse            3 0
530aAC                   parm                    $ldisp           12
530aAC                   parm      w1desc        $ldesc           30
530aAC                   parm      w1item        $litem           15
     C                   parm                    $ldate            8
     C                   parm                    $llcn#           15
     C                   parm                    $lpo             15
530aAC                   parm      w1umshrt      $lshrt            5
760aAC                   parm      w1ord         $word             7 0
760aAC                   parm      w1pdesc       $lpdsc           15
760aAC                   parm      w1href        $lhref           15
     C                   else
     C                   exsr      zzopt
     C                   endif
     C                   endif
     C                   endif
     *
     C                   if        $lrtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $lrtn = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  PAG01    Screen 1 page routines
     *----------------------------------------------------------------

     C     pag01         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     *R         CLERR     CABEQ*ON       PAG01E
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
510aD ***                if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
510aD ***                else
510aD ***                eval      $pocmd = '*POSTN2 '
510aD ***                eval      $pofky = fkey(1)
510aD ***                endif
     C                   exsr      fgtway
     *R         CLERR     CABEQ*ON       PAG01E
     C                   eval      bot = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag01e        endsr

     *----------------------------------------------------------------
     *  PAG02    Screen 2 page routines
     *----------------------------------------------------------------

     C     pag02         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   eval      bot = *off
     C                   exsr      pag2fw
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr

     *----------------------------------------------------------------
     *  PAG1FW   Let's see that next page of records
     *----------------------------------------------------------------

     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     *on           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = *on
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfrt
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfrt        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf          endsr

     *----------------------------------------------------------------
     *  PAG1BK   Let's see the previous page
     *----------------------------------------------------------------

     C     pag1bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     *on           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BRTKWARDS
     *
     C     dsplyd        add       10            gobrtk
     C                   if        bot = *on
     C                   if        gobrtk = 10
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             gobrtk
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = *on
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBRTK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= gobrtk
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS RERTHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = *on
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr

     *----------------------------------------------------------------
     *  PAG2FW   Let's see that next page of delete records
     *----------------------------------------------------------------

     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     *on           endf2
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = *on
     C     wkoprt        reade     workopt                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw2
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C                   endif
     C     endfw2        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf2         endsr

     *----------------------------------------------------------------
     *  PAG2BK   Let's see the previous page of delete records
     *----------------------------------------------------------------

     C     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     *on           endb2
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BRTKWARDS
     *
     C     dsplyd        add       10            gobrtk
     C                   if        bot = *on
     C     wkoprt        setgt     workopt
     C                   add       1             gobrtk
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = *on
     C     wkoprt        readpe    workopt                                79
     *
     *  HIT TOP OF FILE
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk2
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBRTK' NUMBER OF GOOD RECS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   if        p >= gobrtk
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk2        tag
     C                   enddo
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
     C                   if        top = *on
     C     wkoprt        setll     workopt
     C                   endif
     C                   exsr      pag2fw
     C     endb2         endsr

     *----------------------------------------------------------------
     *  ROLL01   Screen 1 roll up/down routine
     *----------------------------------------------------------------

     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     *on           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     *on           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr

     *----------------------------------------------------------------
     *  ROLL02   Screen 2 roll up/down routine
     *----------------------------------------------------------------

     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr

     *----------------------------------------------------------------
     *  SAVOPT   Verify and save options that were entered
     *----------------------------------------------------------------

     C     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     C                   dou       nomore = *on
     C                   eval      *in21 = *off
700aAC                   eval      *in22 = *off
510aAC                   select
510aAC                   when      view = 1
     C                   readc     dspsfl                                 79
510aAC                   when      view = 2
510aAC                   readc     vw2sfl                                 79
510aAC                   endsl
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     C                   endif
     *
     *  SAVE OPTION
     *
510aAC                   select
510aAC                   when      view = 1
     C                   z-add     recno         y
510aAC                   when      view = 2
510aAC                   eval      y = recno
510aAC                   endsl
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     C                   endsr

     *----------------------------------------------------------------
     *  SFLADD   Add record to subfile
     *----------------------------------------------------------------

     C     sfladd        begsr
     C                   if        recno < 11
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
510aA*  Get Repack Item information.
510aAC                   exsr      zzgetrepackit
510aA*  Get Parent Item information.
510aAC                   exsr      zzgetparentit
     C                   exsr      zzfill
     C                   write     dspsfl
510aAC                   write     vw2sfl
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  SFLCLR   Clear display subfile
     *----------------------------------------------------------------

     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
510aD ***                eval      *in01 = *off
510aMC                   eval      *in81 = *off
510aAC                   eval      *in82 = *off
510aAC                   eval      *in83 = *on
     C                   write     dspsfc
510aAC                   write     vw2sfc
     C                   eval      recno = 0
510aAC                   eval      *in82 = *on
510aAC                   eval      *in83 = *off
     C                   endsr

     *----------------------------------------------------------------
     *  SFLDSP   Display subfile
     *----------------------------------------------------------------

     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> *on
510aAC                   select
510aAC                   when      view = 1
     C     1             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl
     C                   endif
510aAC                   when      view = 2
510aAC     1             chain     vw2sfl                             79
510aAC                   if        not *in79
510aAC                   eval      *in20 = *on
510aAC                   update    vw2sfl
510aAC                   endif
510aAC                   endsl
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
510aD ***                eval      *in01 = *on
510aMC                   eval      *in81 = *on
     C                   eval      recno = 1
510aAC                   select
510aAC                   when      view = 1
     C                   write     dspsfc
510aAC                   when      view = 2
510aAC                   write     vw2sfc
510aAC                   endsl
     C                   endsr

     *----------------------------------------------------------------
     *  SFLOPT   Initialize options for subfile
     *----------------------------------------------------------------

     C     sflopt        begsr
     C     1             do        10            x
510aAC                   select
510aAC                   when      view = 1
     C     x             chain     dspsfl                             79
510aAC                   when      view = 2
510aAC     x             chain     vw2sfl                             79
510aAC                   endsl
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
700aAC                   eval      *in22 = *off
700aAC                   if        in22 = '1'
700aAC                   eval      *in22 = *on
700aAC                   endif
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
700aAC                   eval      *in22 = *off
700aAC                   if        in22 = '1'
700aAC                   eval      *in22 = *on
700aAC                   endif
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
510aAC                   select
510aAC                   when      view = 1
     C                   update    dspsfl
510aAC                   when      view = 2
510aAC                   update    vw2sfl
510aAC                   endsl
     C                   endif
     C                   enddo
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    ZMCMSG  Clear message record subfile
     *----------------------------------------------------------------

     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *----------------------------------------------------------------

     C     zmdmsg        begsr
     C                   write     msgclr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *----------------------------------------------------------------
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr

     *----------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *----------------------------------------------------------------

     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *    ZMQMSG  Add message record to subfile from program queue
     *----------------------------------------------------------------

     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     *R                   WRITECLRSCR
     C                   eval      sclear = *on
     C                   endsr

     *----------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *----------------------------------------------------------------

     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *      0101  Program not found.
     *----------------------------------------------------------------

     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *      0102  Program not found.
     *----------------------------------------------------------------

     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *----------------------------------------------------------------

     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *----------------------------------------------------------------

     C     zm0104        begsr
     C                   eval      #msgid = 'PIR0104'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *      0105
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *----------------------------------------------------------------

     C     zm0106        begsr
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *----------------------------------------------------------------

     C     zm0107        begsr
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *----------------------------------------------------------------

     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *    ZZ Routeines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  ZZCMD    Process non-standard function keys
     *----------------------------------------------------------------

     C     zzcmd         begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFGET   Get record with unique key.
     *----------------------------------------------------------------

     C     zzfget        begsr

     *    Code to use when file key and unique key are the same.
     *
     *          FILEKY    CHAINRECORD               79
     *
     *    Code to use when file key and unique key are different.
     *
710 Ac                   if        f9Sort = 3
     C     filuky        chain     recordu                            79
710 Ac                   else
710 A /free
710 A      chain (ukwhse:ukitem:ukord) kitordh5;
710 A      if %found(kitordh5);
710 A         *in79=*off;
710 A      else;
710 A         *in79=*on;
710 A      endif;
710 A /end-free
710 Ac                   endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFGTN   Get next record
     *----------------------------------------------------------------

     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     C**                 read      record                                 79
     *
     *    Code to use when we do have a partial key to use.
     *
710 Ac                   if        f9Sort = 3
     C     partky        reade     record                                 79
710 Ac                   else
710 A /free
710 A      reade ($kwhse) kitordh5;
710 A      if %eof(kitordh5);
710 A         *in79=*on;
710 A      else;
710 A         *in79=*off;
710 A      endif;
710 A /end-free
710 Ac                   endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFGTP   Get previous record
     *----------------------------------------------------------------

     C     zzfgtp        begsr
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     C**                 readp     record                                 79
     *
     *    Code to use when we do have a partial key to use.
     *
710 Ac                   if        f9Sort = 3
     C     partky        readpe    record                                 79
710 Ac                   else
710 A /free
710 A      readpe ($kwhse) kitordh5;
710 A      if %eof(kitordh5);
710 A         *in79=*on;
710 A      else;
710 A         *in79=*off;
710 A      endif;
710 A /end-free
710 Ac                   endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *----------------------------------------------------------------

     C     zzfill        begsr

760aAC                   eval      w1pdesc = #repackitpdsc
760aAC                   eval      w1href  = kohref

     C                   eval      w1ord = kohord
     C                   eval      w1item = kohitm
510aAC                   eval      w1desc = #repackitdesc
     C                   eval      w1need = kohqty
510aAC                   eval      w1nddt = kohndt
     C                   select
     C                   when      kohsta = '1'
     C                   eval      w1stat = 'Open'
     C                   when      kohsta = '2'
     C                   eval      w1stat = 'Started'
     C                   when      kohsta = '4'
     C                   eval      w1stat = 'Closed'
     C                   other
     C                   eval      w1stat = 'Unknwn'
     C                   endsl

740aDC*    fileky2       chain     kitordd
740aDC*                  if        %found
740aDC*                  eval      w1made = kodqty
740aDC*                  else
740aDC*                  eval      w1made = *zeros
740aDC*                  endif
740aAC                   eval      w1made = *zeros
740aAC     fileky2       setll     kitordd
740aAC                   dow       forevr = forevr
740aAC     fileky2       reade(e)  kitordd                                79
740aAC                   if        *in79
740aAC                   leave
740aAC                   else
740aAC                   eval      w1made = w1made + kodqty
740aAC                   iter
740aAC                   endif
740aAC                   enddo

740bAc                   if        #parentitumq2 = 0 and kcqty1>0
740bAc                   eval      #parentitumq2 = 1
740bAc                   endif

700aAC                   eval      in22 = *off
700aAC                   eval      w1uerr = *blanks
700aAC                   if        #parentitumq2 = 0
700aAC                   eval      #parentitumq2 = 1
700aAC                   eval      in22 = *on
700aAC                   eval      w1uerr = 'UOMErr'
700aAC                   endif

530aAC                   eval      w1umshrt = *blanks
510aAC                   eval      w1ratio = ' '
510aAC                   select
510aAC                   when      kcqty1 > 0
510aAC                   eval      w1pqn   = kcqty1
510aAC                   eval      w1pqnu  = #parentitum1
510aAC                   eval      w1ratio = %trim(%editc(kcqty1:'P'))
510aAC                                    + ' '
510aAC                                    + #parentitum1
510aAC                   when      kcqty2 > 0
510aAC                   eval(h)   w1pqndec= (kohqty * kcqty2)
510aAC                                       / #parentitumq2
510aAC                   eval      w1pqn = w1pqndec
510aAC                   if        dec >= 01
510aAC                   eval      w1pqn   = w1pqn + 1
510aAC                   endif
510aAC                   eval      w1pqnu  = #parentitum1
510aAC                   eval      w1ratio = %trim(%editc(kcqty2:'P'))
510aAC                                    + ' '
510aAC                                    + #parentitum2
510aAC                   when      kcqty3 > 0
510aAC                   eval(h)   w1pqndec= (kohqty * kcqty3)
510aAC                                       / (#parentitumq2
510aAC                                           * #parentitumq3)
510aAC                   eval      w1pqn = w1pqndec
510aAC                   if        dec >= 01
510aAC                   eval      w1pqn   = w1pqn + 1
510aAC                   endif
510aAC                   eval      w1pqnu  = #parentitum1
510aAC                   eval      w1ratio = %trim(%editc(kcqty3:'P'))
510aAC                                    + ' '
510aAC                                    + #parentitum3
510aAC                   endsl
510aAC                   eval      w1ratio = %trim(w1ratio)
510aAC                                     + ' to 1 Repack'
530aAC     uomkey        chain     unmesr
530aAC                   if        %found(unmesr)
530aAC                   eval      w1umshrt = umshrt
530aAc                   endif

650aAc                   if        kitcount > 1
650aAc                   eval      w1Ratio = '*KIT - Reference Itm Mnt'
650aAC                   endif

     C                   endsr

510aA
510aA*----------------------------------------------------------------
510aA*  ZZGETPARENTIT   Get Parent item
510aA*----------------------------------------------------------------
510aA
510aAC     zzgetparentit begsr
510aA
650aAc                   eval      kitcount = 0
650aDC*    kitkey        chain     kitcomp
650aAC     kitkey        setll     kitcomp
650aAC     kitkey        reade(e)  kitcomp
650aAc                   dow       %equal and not %eof
650aAc                   eval      kitcount = kitcount + 1
650aAc                   if        kitcount > 1
650aAc                   leave
650aAc                   endif
510aA
510aA*  Get item.
510aA
510aAC                   exsr      clr$item
510aAC                   eval      $itwhse  = kohwhs
510aAC                   eval      $ititem  = kccitm
510aA
510aAC                   eval      $dricommand = '*ITEM'
510aAC                   eval      $drisubcmd  = '%GETALL'
510aAC                   eval      $drisys2upd = 'D'
510aAC                   eval      chk4err = *on
510aAC                   eval      zmsflag = *on
510aAC                   exsr      zzzdricop
510aMC                   if        drierr
510aAC                   eval      error = *on
510aAC                   eval      $prtn = '*PGMQ   '
510aAC                   goto      endgetparenti
510aAC                   endif
510aA
510aAC                   eval      #parentitwhse = $itwhse
510aAC                   eval      #parentititem = $ititem
510aAC                   eval      #parentittype = $ittype
510aAC                   eval      #parentitdesc = $itdesc
510aAC                   eval      #parentitpdsc = $itpdsc
510aAC                   eval      #parentitwhdp = $itwhdp
510aAC                   eval      #parentitstyp = $itstyp
510aAC                   eval      #parentitdesg = $itdesg
510aAC                   eval      #parentitum1  = $itum1
510aAC                   eval      #parentitflg1 = $itflg1
510aAC                   eval      #parentitum2  = $itum2
510aAC                   eval      #parentitumq2 = $itumq2
510aAC                   eval      #parentitflg2 = $itflg2
510aAC                   eval      #parentitum3  = $itum3
510aAC                   eval      #parentitumq3 = $itumq3
510aAC                   eval      #parentitnrpk = $imnrpk
510aAC                   eval      #parentitflgd = $itflgd
510aAC                   eval      #parentitcube = $itcube
510aAC                   eval      #parentitswgt = $itswgt
510aAC                   eval      #parentitcwgt = $itcwgt
510aAC                   eval      #parentitmitem = $itmitem
510aAC                   eval      #parentitsdef = ' '
510aAC                   eval      #parentittie  = 0
510aAC                   eval      #parentithigh = 0
510aA
510aA*  Create heading description.
510aA
510aAC                   call      'FRMTIT'
510aAC                   parm                    #parentititem
510aAC                   parm                    #parentitdesc
510aAC                   parm                    #parentitpdsc
510aAC                   parm      ' '           #parentithead
650aAC     kitkey        reade(e)  kitcomp
650aAc                   enddo
510aA
510aAC     endgetparenti endsr
510aA
510aA*----------------------------------------------------------------
510aA*  ZZGETREPACK   Get Repack item
510aA*----------------------------------------------------------------
510aA
510aAC     zzgetrepackit begsr
510aA
510aA*  Get item.
510aA
510aAC                   exsr      clr$item
510aAC                   if        nxtscr = '01'
510aAC                   eval      $itwhse  = kohwhs
510aAC                   eval      $ititem  = kohitm
510aAC                   else
510aAC                   eval      $itwhse  = $pwhse
510aAC                   eval      $ititem  = w1item
510aAC                   endif
510aA
510aAC                   eval      $dricommand = '*ITEM'
510aAC                   eval      $drisubcmd  = '%GETALL'
510aAC                   eval      $drisys2upd = 'D'
510aAC                   eval      chk4err = *on
510aAC                   eval      zmsflag = *on
510aAC                   exsr      zzzdricop
510aAC                   if        drierr
510aAC                   eval      error = *on
510aAC                   eval      $prtn = '*PGMQ   '
510aAC                   goto      endgetrepacki
510aAC                   endif
510aA
510aAC                   eval      #repackitwhse = $itwhse
510aAC                   eval      #repackititem = $ititem
510aAC                   eval      #repackittype = $ittype
510aAC                   eval      #repackitdesc = $itdesc
510aAC                   eval      #repackitpdsc = $itpdsc
510aAC                   eval      #repackitwhdp = $itwhdp
510aAC                   eval      #repackitstyp = $itstyp
510aAC                   eval      #repackitdesg = $itdesg
510aAC                   eval      #repackitum1  = $itum1
510aAC                   eval      #repackitflg1 = $itflg1
510aAC                   eval      #repackitum2  = $itum2
510aAC                   eval      #repackitumq2 = $itumq2
510aAC                   eval      #repackitflg2 = $itflg2
510aAC                   eval      #repackitum3  = $itum3
510aAC                   eval      #repackitumq3 = $itumq3
510aAC                   eval      #repackitnrpk = $imnrpk
510aAC                   eval      #repackitflgd = $itflgd
510aAC                   eval      #repackitcube = $itcube
510aAC                   eval      #repackitswgt = $itswgt
510aAC                   eval      #repackitcwgt = $itcwgt
510aAC                   eval      #repackitmitem = $itmitem
510aAC                   eval      #repackitsdef = ' '
510aAC                   eval      #repackittie  = 0
510aAC                   eval      #repackithigh = 0
510aA
510aA*  Create heading description.
510aA
510aAC                   call      'FRMTIT'
510aAC                   parm                    #repackititem
510aAC                   parm                    #repackitdesc
510aAC                   parm                    #repackitpdsc
510aAC                   parm      ' '           #repackithead
510aA
510aAC     endgetrepacki endsr
510aA
760aA*----------------------------------------------------------------
760aA*  ZZGETLICENSE  Get License Number
760aA*----------------------------------------------------------------

760aAC     zzgetlicense  begsr

760aA*  Get license

760aA /free

760aA    $llcn# = *blanks;

760aA    setll ($kwhse: w1ord) label93;
760aA    dow forever = forever;
760aA      reade ($kwhse:w1ord) label93;
760aA      if %eof(label93);
760aA        leave;
760aA      endif;
760aA      if %found(label93) and lbgrp1='K';
760aA         chain ($kwhse:lbtrn#) license1;
760aA         if %found(license1);
760aA           $llcn# = lilcns;
760aA           leave;
760aA         endif;
760aA      endif;
760aA    enddo;
760aA /end-free

760aAC                   endsr
     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.

     C     zzinz         begsr
     *
530aAC     *loval        setll     lblfmtd
530aAC                   dou       %eof(lblfmtd)
530aAC                   read      lblfmtd
530aAC                   if        not %eof(lblfmtd)
530aAC                   if        lfdfmt = @plfmtl
530aAC                   eval      @lblset = lfdset
530aAC                   leave
530aAC                   endif
530aAC                   endif
530aAC                   enddo
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    ukwhse
     C                   kfld                    ukord
     C                   kfld                    ukitem
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    kohwhs
510aAC                   kfld                    kohndt
     C                   kfld                    kohord
     C                   kfld                    kohitm

510aAC     fileky2       klist
510aAC                   kfld                    kohwhs
510aAC                   kfld                    kohord
510aAC                   kfld                    kohitm
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
510aA*
510aA*  Define partial key for main file (if needed).
510aA*
510aAC     partky2       klist
510aAC                   kfld                    $kwhse
510aAC                   kfld                    kohndt
510aAC                   kfld                    kohord
510aA*
510aA*  Define key for KITCOMP
510aA*
510aAC     kitkey        klist
510aAC                   kfld                    kohwhs
510aAC                   kfld                    kohitm
710aA*
710aA*  Remove any processed Repack Replenishments
710aA*
710aA /free
710aA     exec sql delete from prplfil
710aA               where prflag='D' and prtail='RPK';
710aA /end-free
     *
     *  Setup option and command display lines.
     *
     C                   eval      optln1 = optln(1)
710 DC*                  eval      cmdln1 = cmdln(1)
710 A /free
710 A                    cmdln1 = %subst(cmdln(1):1:30) + '  ' +
710 A                             %trim(cmdln(3)) +
710 A                             %subst(cmdln(1):31:25);
710 A /end-free
510aAC                   eval      view = 1
510aAC                   eval      maxvw = 2
710 Ac                   eval      F9sort=3
710 Ac                   eval      *in95=*off
710 Ac                   eval      Ptsort='** by Work Order **'
710 Ac                   eval      Ptsortd='  Position by Date Needed'
     *
     C                   eval      $pprg = #prog
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz2        begsr
     *
     *   Get warehouse for user.
     *
210 AC                   call      'GETWHSE'
210 AC                   parm                    #user
210 AC     kohwhs        parm      0             #whse             3 0
210 AC                   eval      $kwhse = kohwhs
     *
     *   Verify warehouse and get description.
     *
     C                   eval      whcode = kohwhs
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = kohwhs
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
413aMC                   eval      *in03 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
413aMC                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      $kwhse = kohwhs
     C                   eval      whcode = kohwhs
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
     *
223 AC                   eval      *in02 = *on
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   endsr

     *----------------------------------------------------------------
     *  ZZKEYF   Create key for file being used
     *----------------------------------------------------------------

     C     zzkeyf        begsr
510aAC                   eval      fwhs = kohwhs
510aAC                   eval      fndt = kohndt
510aAC                   eval      ford = kohord
510aAC                   eval      fitm = kohitm
     C                   eval      $pofky = dsfkey
     C                   endsr

     *----------------------------------------------------------------
     *  ZZKEYI   Initialize keys for files being used.
     *           Note: You must clear individual field when using
     *                 partial keys or one of the fields is numeric.
     *----------------------------------------------------------------

     C     zzkeyi        begsr
     *
     *   Initialize file key (DSFKEY)
     *
510aAC                   clear                   fwhs
510aAC                   clear                   ford
510aAC                   clear                   fndt
510aAC                   clear                   fitm
     *
     *   Initialize unique key (DSUKEY)
     *
     C                   clear                   ukwhse
510aAC                   clear                   ukndt
     C                   clear                   ukord
     C                   clear                   ukitem
     *
     C                   endsr

     *----------------------------------------------------------------
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *----------------------------------------------------------------

     C     zzkeyu        begsr
     C                   eval      ukwhse = kohwhs
510aAC                   eval      ukndt  = kohndt
     C                   eval      ukord  = kohord
     C                   eval      ukitem = kohitm
     C                   eval      $pouky = dsukey
     C                   endsr

     *----------------------------------------------------------------
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *----------------------------------------------------------------

     C     zzopt         begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZPOS    Position to a different record.
     *----------------------------------------------------------------

     C     zzpos         begsr
     *
     *      Verify warehouse entry.
     *
     C                   if        ptinp1 <> 0
     C                   eval      whcode = ptinp1
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
413aMC                   eval      *in03 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
413aMC                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      kohwhs = ptinp1
     C                   eval      $kwhse = kohwhs
     C                   eval      kohord = 0
     C                   eval      kohitm = ' '
501aAC                   eval      kohndt = 0
     C                   eval      whcode = kohwhs
     C                   movel     $lerm         whdesc
     C                   eval      ptinp1 = 0
     C                   eval      repos = *on
223 AC                   eval      *in02 = *on
     C                   endif
     C                   endif
     C                   endif
     *
     *  See if user is trying to position to a certain spot
     *
710 Ac                   if        f9sort=3
     C                   if        ptinp2 <> 0
510aD ***                eval      kohord = ptinp2
510aMC                   eval      kohndt = ptinp2
     C                   eval      ptinp2 = 0
     C                   eval      repos = *on
     C                   endif
710 Ac                   else
710 AC                   if        ptinp2N <> *blanks
710 AC                   eval      kohitm = ptinp2n
710 AC                   eval      ptinp2n = *blanks
710 AC                   eval      repos = *on
710 AC                   endif
710 Ac                   endif
     C     endzps        endsr

     *----------------------------------------------------------------
     *  ZZPOS2   Position to record
     *----------------------------------------------------------------

     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     C                   if        $pocmd = '*TOP'
710 Ac                   if        f9Sort=3
     C     *loval        setll     record
710 Ac                   else
710 A /free
710 A      setll *loval record5;
710 A /end-free
710 Ac                   endif
     C                   else
     C                   if        $pocmd = '*BOTTOM'
710 Ac                   if        f9Sort=3
     C     *hival        setll     record
710 Ac                   else
710 A /free
710 A      setll *hival record5;
710 A /end-free
710 Ac                   endif
     C                   endif
     C                   endif
     *
     *    Code to use when we do have a partial key to use.
     *
     *R         $POCMD    IFEQ '*TOP'
     *R         PARTKY    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         PARTKY    SETGTRECORD
     *R                   END
     *R                   END
     C                   endsr

510aA*----------------------------------------------------------------
510aA*----------------------------------------------------------------
510aA*                     DRI SUBROUTINES
510aA*----------------------------------------------------------------
510aA*----------------------------------------------------------------

510aA*----------------------------------------------------------------
510aA*  clr$item  Clear $item data structure fields
510aA*----------------------------------------------------------------
510aA
510aAC     clr$item      begsr
510aAC                   eval      savever# = $itver#
510aAC                   clear                   $item
510aAC                   eval      $itver# = savever#
510aAC                   endsr
510aA
510aA
510aA*----------------------------------------------------------------
510aA*  zzzdricop  Call DRICOP
510aA*----------------------------------------------------------------
510aA
510aAC     zzzdricop     begsr
510aAC                   eval      drierr = *off
510aA
510aAC                   select
510aAC                   when      $dricommand = '*SLOT'
510aAC                   eval      $dridata = $slot
510aAC                   when      $dricommand = '*ITEM'
510aAC                   eval      $dridata = $item
510aAC                   eval      $dridata2 = $item2
510aAC                   when      $dricommand = '*ITEMQTY'
510aAC                   eval      $dridata = $itemqty
510aAC                   endsl
510aA
510aAC                   if        $dricommand = '*ITEM'
510aAC                   call(e)   'DRICOP'
510aAC                   parm                    $dricommand
510aAC                   parm                    $drisubcmd
510aAC                   parm                    $drisys2upd
510aAC                   parm      #prog         $driprogram
510aAC                   parm      ' '           $drireturn
510aAC                   parm      ' '           $drimessage
510aAC                   parm                    $dridata
510aAC                   parm                    $dridata2
510aAC                   else
510aAC                   call(e)   'DRICOP'
510aAC                   parm                    $dricommand
510aAC                   parm                    $drisubcmd
510aAC                   parm                    $drisys2upd
510aAC                   parm      #prog         $driprogram
510aAC                   parm      ' '           $drireturn
510aAC                   parm      ' '           $drimessage
510aAC                   parm                    $dridata
510aAC                   endif
510aA
510aAC                   select
510aA
510aAC                   when      chk4err and %error
510aAC                   eval      drierr = *on
510aAC                   eval      errmsg    = 'Error occured on call to '
510aAC                                       + 'DRICOP'
510aAC                                       + '/' + %trim($drisubcmd)
510aAC                                       + ' from ' + #prog
510aAC                   if        zmsflag
510aAC                   exsr      zm0105s
510aAC                   else
510aAC                   exsr      zm0105
510aAC                   endif
510aA
510aAC                   when      chk4err and $drireturn <> '*OK'
510aAC                   eval      drierr = *on
510aAC                   if        zmsflag
510aAC                   exsr      zm0001s
510aAC                   else
510aAC***                exsr      zm0001
510aAC***                exsr      zzerrind
510aAC                   endif
510aA
510aAC                   endsl
510aA
510aAC                   select
510aAC                   when      $dricommand = '*SLOT'
510aAC                   eval      $slot = $dridata
510aAC                   when      $dricommand = '*ITEM'
510aAC                   eval      $item = $dridata
510aAC                   eval      $item2 = $dridata2
510aAC                   when      $dricommand = '*ITEMQTY'
510aAC                   eval      $itemqty = $dridata
510aAC                   endsl
510aA
510aAC                   eval      zmsflag = *off
510aAC                   eval      chk4err = *off
510aAC     enddricop     endsr
510aA
510aA*----------------------------------------------------------------
510aA*    DRI0001s Local system caused error (send to different program)
510aA*----------------------------------------------------------------
510aA
510aAC     zm0001s       begsr
510aAC                   if        %subst($drimessage:1:2) = 'H:'
510aAC                   move      'DRI0002'     #msgid
510aAC                   eval      $drimessage = %subst($drimessage:3)
510aAC                   else
510aAC                   move      'DRI0001'     #msgid
510aAC                   endif
510aAC                   eval      #msgtp = '*DIAG'
510aAC                   eval      #msgdt = $drimessage + $drireturn
510aAC                                    + $dricommand + $drisubcmd
510aAC                   exsr      zmsmsg
510aAC                   eval      $pmsg = #msgk
510aAC                   endsr
510aA
510aA*----------------------------------------------------------------
510aA*    PIR0105  Generic error (send to different program)
510aA*----------------------------------------------------------------
510aA
510aAC     zm0105s       begsr
510aAC                   eval      #msgid = 'PIR0105'
510aAC                   eval      #msgtp = '*DIAG'
510aAC                   eval      #msgdt = errmsg
510aAC                   exsr      zmsmsg
510aAC                   eval      $pmsg = #msgk
510aAC                   endsr
510aA
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Compile time tables
     *----------------------------------------------------------------
     *----------------------------------------------------------------

**  ZOPT - Valid options
 2 4 6
**  OPTLN - Option display line
  2=Build  4=Close  6=Print Repack labels
**  CMDLN - Command display line
F3=Exit  F5=Refresh  F6=Create  F11=View 2  F12=Cancel
F3=Exit  F5=Refresh  F6=Create  F11=View 1  F12=Cancel
F9=Sort Item
F9=Sort Work Order
