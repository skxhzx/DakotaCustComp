     H option(*nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CE120   UCI Catch Weight Entry Display
     *
     *  Created using CW120
     *
     *----------------------------------------------------------------
     *  Notes
     *       8 X 20 Screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
510 A*  10/03/06  RAH  5.10
     *    Enh:  Remove PAKERLB and PAKERCW and replace with UCICW.

510aA*  11/01/06  JCJ  5.10a
     *    Enh:  Added Warehouse selection to screen1.

510bA*  11/01/06  RAH  5.10b
     *    Enh:  Enable '16' to be entered in W2OPT.  Call CE190 to
     *          display list of UCI's.  Correct problem with msgsfl
     *          not displaying.
     *
510cA*  02/01/07  JCJ  5.10c
     *    Enh:  Post the outbound delivery number and outbound
     *          delivery line number to the ucicw file (UCIOUT,UCISQO)
     *
510dA*  02/02/07  HNK  5.10d
     *    Fix:  Correct checking of valid label.
     *
510eA*  02/15/07  JCJ  5.10e
     *    Fix:  added logic to sr ent02 to process scanned label and
     *          no option selected.  Changed zzchk2 to not edit scanned
     *          label field if not entered.
     *
510fA*  02/27/07  JCJ  5.10f
     *    Fix:  Renamed cwentry to screen1 and spackrlb to screen3.
     *          Changed zzfil3 to chain to label file instead of
     *          setgt/readp.  Added file piritem.
     *          To view previous version see ce120.0227 qrpgsrc/work510old.
510gA*  03/03/07  MLB  5.10g
     *    Fix:  Revised ZZCHK2 to skip subfile processing when label number
     *          is scanned. It was causing the LABEL record info to be
     *          corrupted when the subfile records are accessed.
510hA*  03/13/07  MLB  5.10h
     *    Fix:  Revised ZZUPD3 to correctly update UCICW file with
     *          catchweight info when UCI's are scanned.
510iA*  04/04/07  HNK  5.10i
     *    Fix:  Revised to add label number.
510jA*  04/25/07  JCJ  5.10j
     *    Enh:  Added screen4 for license scanning.
510kA*  08/09/07  JCJ  5.10k
     *    Enh:  Added parm list.
510lA*  08/19/07  RH   5.10l
     *    Enh:  Added code to check UCI for Returns and update UCICW
     *    Enh:  Only allow F20 from UCI entry for Returns if all UCI's
     *          were scanned for quantity returned, no F12 allowed.
650aA*    03/15/13  LMC  6.50a
     *      - Enh: Added CWLOG. This adds a call to a new program
     *        CW800 and new file CWLOG.
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fce120fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(cwesfl:recno)
     F                                     sfile(msgrec:msgk)
     Fpiruser1  if   e           k disk
     Fpirtran   if   e           k disk
     Flabel7    if   e           k disk
     F                                     rename(l7rec:record)
510d Flabel     if   e           k disk
510 aFucicw     uf   e           k disk
510jAFucicw1    uf   e           k disk    rename(ucirec:ucirec1)
510 aFucicw7    if   e           k disk
510 aF                                     rename(ucirec:ucirec2)
     Fordc1     uf a e           k disk
510cAFordhm     if   e           k disk
510lAForrtn1    if   e           k disk
510fAFpiritem   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
510gDD*desc            s             50    dim(10) ctdata perrcd(1)
510jDD*desc            s             50    dim(11) ctdata perrcd(1)
510jMD desc            s             50    dim(15) ctdata perrcd(1)
     D fkey            s             50    dim(14)
     D ukey            s             50    dim(14)
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D status            *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @adjtrn         c                   const('ADJTRAN2')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D dsfkey          ds
     D  wblbl#                 1      7  0
     *
     D dsukey          ds
     D  uklbl#                 1      7  0
     *----------------------------------------------------------------
PAKa D                 ds
PAKa D  dslb10                 1     10
PAka D  dslb8                  2      9
     *----------------------------------------------------------------
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
510kA*----------------------------------------------------------------
510kA* Entry parms
510kA*
510kAD $parms          ds
510kAD  $pcmd                  1      8
510kAD  $pprg                  9     18
510kAD  $puky                 19     68
510kAD  $prtn                 69     76
510kAD  $perm                 77    136
510kAD  $pmsg                 77     80
510kA*
510kA*   Redefine key
510kA*
510kAD  $pwhse                19     21  0
510kaD  $plbl                 22     28  0
510kaD  $pqty                 29     33  0
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
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lcode                22     27
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  erfld                  1     30
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
510cA*
510cA*----------------------------------------------------------------
510cA*  SAP Header Misc. File data structures
510cA*
510cA /copy qcopysrc,ordhm1_pak
650aA*----------------------------------------------------------------
650aA*  Data Formats
650aA*----------------------------------------------------------------
650aA /COPY *libl/qcopysrc,C#CWLOG
650aAD savever#        s                   like($cwver#)
650aA*----------------------------------------------------------------
650aA*  Prototypes
650aA*----------------------------------------------------------------
650aA /copy qcopysrc,p.cw800
510cA*----------------------------------------------------------------
510cA* Work Fields
510cA*
     D @pcube          s              9  3
     D @pswgt          s              9  2
     D @pdate          s              8  0
     D hldptrn#        s              7  0
     D $ptrn#          s              7  0
     D w2hlbl          s              7  0
     D @ptrn#          s              7  0
     D $time           s              6  0
     D @ptime          s              6  0
     D w3qrmn          s              5  0
     D w3scan          s              5  0
     D comand          s              5  0
     D enter           s              5  0
     D clear           s              5  0
     D help            s              5  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D #emp#           s              5  0
     D @ppcs           s              5  0
     D @paisl          s              5  0
     D @pqty1          s              5  0
     D @pqty2          s              5  0
     D @pqty3          s              5  0
     D msgk            s              4  0
     D recno           s              4  0
     D y               s              4  0
     D #nhrs           s              3  1
     D sub2            s              3  0
     D #whse           s              3  0
     D @pwhse          s              3  0
     D dsplyd          s              2  0
     D goback          s              2  0
     D p               s              2  0
     D #lnam           s             20
     D w16item         s             16
     D w3item          s             15
     D #fnam           s             15
     D $rtncd          s             10
     D $msgf           s             10
     D #pgmq           s             10
     D @puser          s             10
     D @pcmd           s             10
     D @ppo            s              9
     D #rtn            s              8
     D cmdchk          s              8
     D pagcmd          s              8
     D w8lbl#          s              8
     D #lcmd           s              8
     D @ptype          s              8
     D @prtn           s              8
     D #msgid          s              7
     D #msgtp          s              7
     D moreln          s              7
     D #shft           s              6
     D #crew           s              6
     D @ptask          s              6
     D #whdp           s              5
     D @pwhdp          s              5
     D @prte           s              5
     D @pmsg           s              4
     D nxtscr          s              3
     D #lcol           s              3
     D #lline          s              2
     D warn            s              1
     D cmdtkn          s              1
     D error           s              1
     D bot             s              1
     D first           s              1
     D forceb          s              1
     D forevr          s              1
     D optionsel       s              1
     D refrsh          s              1
     D sclear          s              1
     D stop            s              1
     D top             s              1
     D #init           s              1
     D #styp           s              1
     D @pstyp          s              1
     D @pgrp1          s              1
     D @pgrp2          s              1
650aAD CWcmd           s             10
650aAD CWpgm           s             10
650aAD CWrtn           s             10
650aAD CWmsg           s             60
650aAD CWdata          s            512
650aAD processstatus   s             10
510kA*----------------------------------------------------------------
510kA*  Parameters
510kA*
510kA*    Input Parameters
510kA*      $PCMD   *Pick   -
510kA*              *Return -
510kA*      $PPRG   Program to send messages back to.
510kA*      $PUKY   Contains key to be verified.
510kA*
510kA*    Returned Parameters
510kA*      $PUKY   Contains first key selected.
510kA*      $PRTN   blank    - No problem encountered.
510kA*              *OK      - Unique key exists for *VERIFY
510kA*              *CANCEL  - CMD12 was entered
510kA*              *ERROR   - Error occured. Message in $PERM
510kA*              *PGMQ    - Error occured. Message sent to pgmq.
510kA*      $PERM   Error message or pointer to message in pgmq.
510kA*
510kA*----------------------------------------------------------------
510kA*  Let the show begin .....
510kA*
510kAC     *entry        plist
510kAC                   parm                    $parms
510kA*
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *on
     C                   eval      *in91 = *on
     C                   eval      error = *off
     C                   exsr      zzinz2
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
510jAC     nxtscr        caseq     '04 '         sc4
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   eval      *inlr = *on
     C                   return
     *
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98=*on
     C                   endif
     *
     *   Set OFF command key indicators
     *
     c                   setoff                                       kckekf
     c                   setoff                                       kl
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   select
     C                   when      nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   eval      first = '0'
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   when      nxtscr = '02 '
     C                   exsr      sfldsp
     *
     *   Initialize error subfile
     *
510gAC                   if        status <> rollup and
510gAC                             status <> rolldn
     C                   exsr      zmcmsg
510gAC                   endif
     *
     C                   when      nxtscr = '03 '
     C                   exfmt     screen3                              50
     C                   eval      first = '0'
510jA*
510jAC                   when      nxtscr = '04 '
510jAC                   exfmt     screen4                              50
510jAC                   eval      first = '0'
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     C                   endsl
PAka *
PAka *   Initialize error indicators and fields
PAka *
PAKaAC                   eval      *in21 = *off
PAKaAC                   eval      *in22 = *off
PAKaAC                   eval      *in23 = *off
PAKaAC                   eval      *in24 = *off
PAKaAC                   eval      *in90 = *off
PAKaAC                   eval      *in02 = *off
PAKaAC                   eval      warn = *off
PAKaAC                   eval      cmdtkn = *off
PAKaAC                   eval      error = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     C                   exsr      zzfil1
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      wblbl# = w1tran
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     *
     *  INVALID IF NO SUBFILE RECORDS LOADED
     *
     C                   if        recno = 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in01 = *on
510jD ***                eval      errmsg = desc(3)
510jMC                   eval      w2msg  = desc(3)
510jD ***                exsr      zm1001
     C                   exsr      scr01i
     C                   endif
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   exsr      zzfil3
     C                   eval      refrsh = *off
     C     end03i        endsr
510jA*----------------------------------------------------------------
510jA*
510jA*  Screen 04 initialization
510jA*
510jAC     scr04i        begsr
510jAC                   eval      nxtscr = '04 '
510jAC                   exsr      zzfil4
510jAC                   eval      refrsh = *off
510jAC     end04i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc = *on or *inkl = *on
     C                   eval      nxtscr = 'EOJ'
     *
     C                   exsr      sridle
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  create transaction in PIRTRAN to track time
     *
     C                   call      @adjtrn
     C                   parm      '*CRTSTRT'    @pcmd
     C                   parm                    #job
     C                   parm      '*INTER'      @ptype
     C                   parm      *zeros        @ptrn#
     C                   parm      'CWENTRY'     @ptask
     C                   parm                    @pwhse
     C                   parm      *blanks       @pwhdp
     C                   parm      *blanks       @pstyp
     C                   parm      *zeros        @pcube
     C                   parm      *zeros        @pswgt
     C                   parm      *zeros        @ppcs
     C                   parm      *zeros        @paisl
     C                   parm      *zeros        @pqty1
     C                   parm      *zeros        @pqty2
     C                   parm      *zeros        @pqty3
     C                   parm      *blanks       @prte
     C                   parm      *blanks       @ppo
     C                   parm      'S'           @pgrp1
     C                   parm      'S'           @pgrp2
     C                   parm      *zeros        @pdate
     C                   parm      *zeros        @ptime
     C                   parm      uscode        @puser
     C                   parm      *blanks       @prtn
     C                   parm      *blanks       @pmsg
     C                   eval      hldptrn# = @ptrn#
     C                   exsr      scr02i
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2     Screen 2
     *
     C     sc2           begsr
     *
PAKa C                   if        status <> rollup  and
PAKa C                             status <> rolldn
     C                   exsr      zzcmd2
510baC                   if        nxtscr<>'01'
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   if        optionsel = 'N' and w2scnl=0
     C                   exsr      scr02i
     C                   endif
PAKa C                   endif
510baC                   endif
     *
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C                   cas                     ent02
     C                   endcs
     *
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F12 - Cancel
     *
510lDC*                  if        *inkl = *on or *inkt = *on
510lMC                   if        *inkl = *on and
510lMC                             $pcmd <>'*RETURN'
     C                   eval      nxtscr = '02 '
     *
     C                   goto      endsc3
     C                   endif
     *
510l *
510l *  Test for F12 - Cancel
510l *
510l C                   if        *inkt = *on
510l C                   eval      nxtscr = '02 '
510l C                   goto      endsc3
510l C                   endif
     *  Test for other command key2 BEFORE verification and update.
     *
PAKa C                   move      w10lbl        dslb10
PAKa C                   eval      w8lbl# = dslb8
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
PAKa C                   eval      w10lbl = ' '
     *                  exsr      scr03i
     *
     C     endsc3        endsr
510jA*----------------------------------------------------------------
510jA*
510jA*  SC4  -  Screen 4
510jA*
510jAC     sc4           begsr
510jA*
510jA*  Test for F12 - Cancel
510jA*
510jAC                   if        *inkl = *on or *inkt = *on
510jAC                   eval      nxtscr = '02 '
510jA*
510jAC                   goto      endsc4
510jAC                   endif
510jA*
510jA*  Test for other command keys BEFORE verification and update.
510jA*
510jAC                   eval      cmdchk = '*BEFORE '
510jAC                   exsr      zzcmd4
510jAC     cmdtkn        cabeq     *on           endsc4
510jA*
510jA*  Some other key pressed.
510jA*
510jA*     Check input and write/update record.
510jA*
510jAC                   exsr      zzchk4
510jAC     error         cabeq     *on           endsc4
510jA*
510jA*  Test for other command keys AFTER verification and update.
510jA*
510jAC                   eval      cmdchk = '*AFTER  '
510jAC                   exsr      zzcmd4
510jAC     cmdtkn        cabeq     *on           endsc4
510jAC     error         cabeq     *on           endsc4
510jAC                   exsr      zzupd4
510jAC                   eval      w4lcn# = ' '
510jA*
510jAC     endsc4        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C     error         cabeq     '1'           rol02e
     C                   eval      pagcmd = '*NEXT'
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C     error         cabeq     '1'           rol02e
     C                   eval      pagcmd = '*PREV'
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr
     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     C     pag02         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT'
     C                   exsr      pag2fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV'
     C                   exsr      pag2bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP'
     C                   eval      $pocmd = '*TOP'
     C                   exsr      fgtway
     C                   eval      top = '0'
     C                   eval      bot = '0'
     C                   eval      forceb = '0'
     C                   exsr      pag2fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM'
     C                   eval      bot = '1'
     C                   eval      dsplyd = 0
     C                   exsr      pag2bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval or fkey(1) = *blanks
     C                               or nxtscr = '02'
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*TOP'
     C                   else
     C                   eval      $pocmd = '*POSTND'
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     C                   eval      bot = '0'
     C                   exsr      pag2fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS'
     C                   eval      bot = '0'
     C                   eval      forceb = '0'
     C                   exsr      pag2fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   eval      fkey = dsfkey
     C                   eval      ukey = *loval
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 8 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = '1'
     C                   eval      bot = '1'
     C                   eval      moreln = 'Bottom '
     C                   goto      endfwd
     C                   endif
     *
     *  RECORD READ - STOP AFTER 3 GOOD RECORDS
     *
     C                   exsr      sfladd
     C                   if        p = 3
     C                   eval      stop = '1'
     C                   if        forceb = '1'
     C                   eval      bot = '1'
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfwd        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = '0'
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page
     *
     C     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C                   select
PCKa C                   when      #lline<>'16'
     C     dsplyd        add       3             goback
     C                   other
     C     dsplyd        add       3             goback
     C                   endsl
     C                   if        bot = '1'
     C                   if        goback = 3
PCKa C                             and #lline<>'16'
     C                   eval      forceb = '1'
     C                   endif
     C                   eval      $pocmd = '*BOTTOM'
     C                   exsr      fgtway
     C                   eval      goback = goback +1
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = '0'
     C                   eval      bot = '0'
     C                   eval      stop = '0'
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = '1'
     C                   eval      top = '1'
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   if        lbtrn# = w1tran and
     C                             itcwgt = 'Y'    and
     C                             lbqpck <> *zeros
     C                   eval      p = p+1
     C                   endif
     C                   if        p>goback
     C                   eval      stop = '1'
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP'
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag2fw
     C     endb          endsr
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
     C     $pocmd        caseq     '*POSTN2'     fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
     C                   endcs
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYI   Initialize keys for files being used.
     *           Note: You must clear individual field when using
     *                 partial keys or one of the fields is numeric.
     *
     C     zzkeyi        begsr
     *
     *   Initialize unique key (DSUKEY)
     *
     C                   eval      uklbl# = lblbl#
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      uklbl# = lblbl#
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        begsr
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
PAKa C     w1tran        readpe    record                                 79
     C     endgtp        endsr
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are DIFFERENT.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79 = '1'
     C                   eval      $portn = '*NOTFND '
     C                   exsr      zzkeyi
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79 = '1'
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79  = '1'
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dsfkey = $pofky
     C     fileky        setll     record
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
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
     *
     *  ZZCMD2   Screen 2 command key routine
     *
     C     zzcmd2        begsr
     *
     *  TEST FOR F3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = '01'
     C                   eval      $rtncd = '*EXIT'
     C                   goto      cmd02e
     C                   endif
     *
     *  TEST FOR F12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01'
     C                   eval      $rtncd = '*CANCEL'
     C                   goto      cmd02e
     C                   endif
     *
     C     error         cabeq     '1'           cmd02e
     *
     C     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   if        not *inkc and not *inkl
510eAC                   select
510eA*  Label scanned
510eAC                   when      optionsel = 'N' and w2scnl <> *zeros
510eAC                   eval      w2hlbl = w2scnl
510gAC                   eval      w2scnl = *zeros
510eAC                   exsr      scr03i
510eAC                   other
     *
     *  Label selected from screen
     *
     C                   eval      w2hlbl = *zeros
     C                   eval      sub2 = 1
     C     sub2          chain     cwesfl                             79
     C                   dow       sub2<4
     C                   if        w2opt='1 ' or w2opt=' 1'
     C                                        or w2opt='01'
     C                   eval      w2hlbl = w2lbl#
     C                   exsr      scr03i
     C                   eval      w2scnl = *zeros
     C                   eval      w2opt = *blanks
     C  n79              update    cwesfl
     C                   leave
     C                   endif

510jAC                   if        w2opt='2 ' or w2opt=' 2'
510jAC                                        or w2opt='02'
510jAC                   eval      w2hlbl = w2lbl#
510jAC                   exsr      scr04i
510jAC                   eval      w2scnl = *zeros
510jAC                   eval      w2opt = *blanks
510jAC  n79              update    cwesfl
510jAC                   leave
510jAC                   endif
510jA
510bAC                   if        w2opt = '16'
510eAC                   eval      w2hlbl = w2lbl#
510fDC     w2hlbl        chain     label
510baC                   eval      $portn = '*NORMAL'
510baC                   call      'CE190'
510baC                   parm                    lbord
510baC                   parm                    lbseq
510baC                   parm                    lbitem
510baC                   parm                    lbtrn#
510baC                   parm                    portn             8
     *
     *
     *  Verify that label had catch weight entries to display
     *
     C                   if        $portn = '*NOGOOD'
     C                   eval      *in24 = *on
     C                   eval      error = *on
510jD ***                eval      errmsg = desc(10)
510jMC                   eval      w2msg  = desc(10)
510jD ***                exsr      zm1001
     C                   leave
     C                   endif
510baC                   eval      w2opt = *blanks
     C                   eval      w2scnl = *zeros
     C  n79              update    cwesfl
510baC                   endif
     C                   eval      sub2 = sub2 + 1
     C     sub2          chain     cwesfl                             79
     C                   enddo
510eAC                   endsl
     C                   endif
     *
     C     ent02e        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
PAKa C     w1tran        reade     record                                 79
     *
     C     endgtn        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     C                   if        $pocmd = '*TOP'
     C     w1tran        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     w1tran        setgt     record
     C                   endif
     C                   endif
     C                   endsr
     *
     C     zzpos         begsr
     C                   endsr
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
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     C                   eval      first = *on
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *  SUBROUTINE - srIdle - Create idle transaction when employee
     *                exits from catch weight entry
     *---------------------------------------------------------------
     C     sridle        begsr
     *
     *  create an idle transaction once employee comes off particular load
     *
     C                   call      @adjtrn
     C                   parm      '*CRTSTRT'    @pcmd
     C                   parm                    #job
     C                   parm      '*INTER'      @ptype
     C                   parm      *zeros        @ptrn#
     C                   parm      'IDLE '       @ptask
     C                   parm                    @pwhse
     C                   parm      *blanks       @pwhdp
     C                   parm      *blanks       @pstyp
     C                   parm      *zeros        @pcube
     C                   parm      *zeros        @pswgt
     C                   parm      *zeros        @ppcs
     C                   parm      *zeros        @paisl
     C                   parm      *zeros        @pqty1
     C                   parm      *zeros        @pqty2
     C                   parm      *zeros        @pqty3
     C                   parm      *blanks       @prte
     C                   parm      *blanks       @ppo
     C                   parm      'S'           @pgrp1
     C                   parm      'S'           @pgrp2
     C                   parm      *zeros        @pdate
     C                   parm      *zeros        @ptime
     C                   parm      uscode        @puser
     C                   parm      *blanks       @prtn
     C                   parm      *blanks       @pmsg
     *
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0110  Number must be > 0
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1060  Pallet already scanned
     *
     C     zm1060        begsr
     C                   eval      #msgid = 'PIR1060'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  Value cannot be blank
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      $md = *blanks
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
510jAC                   eval      w1msg = *blanks
510aA*
510aA*  Verify warehouse code.
510aA*
510aAC                   eval      $lcmd = '*VERIFY '
510aAC                   eval      $lwhse = w1whse
510aAC                   call      'WH900'
510aAC                   parm                    $lparm
510aAC                   if        $lrtn = '*ERROR  '
510aAC                   eval      error = *on
510aAC                   eval      *in21 = *on
510aAC                   eval      *in01 = *on
510jD ***                eval      errmsg = $lerm
510jMC                   eval      w1msg  = desc(15)
510jD ***                exsr      zm0105
510aAC                   else
510aAC                   if        $lrtn = '*PGMQ   '
510aAC                   eval      error = *on
510aAC                   eval      *in21 = *on
510aAC                   eval      *in01 = *on
510jD ***                eval      #msgk = $lmsg
510jMC                   eval      w1msg = desc(15)
510jD ***                exsr      zmqmsg
510aAC                   endif
510aAC                   endif
     *
     *  Verify Transaction Scanned
     *
     C     w1tran        chain     pirtran
     C                   if        not %found(pirtran)
     C                   eval      error = *on
     C                   eval      *in24 = *on
510jD ***                eval      errmsg = desc(1)
510jMC                   eval      w1msg  = desc(1)
510jD ***                exsr      zm0105
     C                   goto      endck1
     C                   endif
     *
     *  do not allow status 4 transactions
     *
     C                   if        %found(pirtran) and ptstat='4'
     C                   eval      error = *on
     C                   eval      *in24 = *on
510jD ***                eval      errmsg = desc(2)
510jMC                   eval      w1msg  = desc(2)
510jD ***                exsr      zm1001
     C                   endif
     *
     C     endck1        tag
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     *
510gDC*                  eval      error = *on
510gAC                   eval      optionsel = 'N'
510gAC                   eval      error     = *off
510gAC                   eval      sub2      = 1
     *
510d *  Verify that scanned label is for the pallet transaction being shipped
510d *
510eAC                   if        w2scnl <> *zeros
510d C     w2scnl        chain     label                              79
510d C                   if        *in79 = *off and lbtrn# <> w1tran
510d C                             or *in79 = *on
510d *
510gAC                   eval      error = *on
     C                   eval      *in24 = *on
510jD ***                eval      errmsg = desc(4)
510jMC                   eval      w2msg  = desc(4)
510jD ***                exsr      zm1001
510gAC                   endif
510gAc     itmkey        chain     piritem
510gAc                   if        Not %found(piritem)
510gAc                             or %found(piritem)
510gAc                             and itcwgt <> 'Y'
510gAC                   eval      error  = *on
510gAC                   eval      *in24  = *on
510jD ***                eval      errmsg = desc(11)
510jMC                   eval      w2msg  = desc(11)
510jD ***                exsr      zm1001
510gAc                   endif
510gAC
510gAC                   eval      w2item  = lbitem
510gAC                   eval      w16item = lbitem
510gAC                   eval      w2qrmn  = lbqpck
510gAC
510gAC                   goto      endck2
510gDC*                  endif
     *
510eAC                   endif
     *
     *  Verify that option field is valid
     *
510gDC*                  eval      optionsel = 'N'
510gDC*                  eval      error = *off
510gDC*                  eval      sub2 = 1
     C     sub2          chain     cwesfl                             79
     C                   dow       sub2<4
     C                   if        w2opt<>*blanks and w2opt<>'1 '
     C                                            and w2opt<>'01'
     C                                            and w2opt<>' 1'
510jAC                                            and w2opt<>'2 '
510jAC                                            and w2opt<>'02'
510jAC                                            and w2opt<>' 2'
     C                                            and w2opt<>'16'
     C                   eval      error = *on
     C                   else
     *  set indicator to know at least one option was selected
     C                   if        w2opt<>*blanks
     C                   eval      optionsel = 'Y'
     C                   leave
     C                   endif
     C                   endif
     C                   eval      sub2 = sub2 + 1
     C     sub2          chain     cwesfl                             79
     C                   enddo
     C                   if        error = *on
     C                   eval      *in24 = *on
510jD ***                eval      errmsg = desc(5)
510jMC                   eval      w2msg  = desc(5)
510jD ***                exsr      zm1001
     C                   goto      endck2
     C                   else
     C                   if        optionsel = 'N' and w2scnl=0
     C                   eval      error = *on
     C                   eval      *in24 = *on
510jD ***                eval      errmsg = desc(8)
510jMC                   eval      w2msg  = desc(8)
510jD ***                exsr      zm1001
     C                   goto      endck2
     C                   endif
     C                   endif
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *    zzchk3 - Check for valid entry on screen three
     *
     C     zzchk3        begsr
     *
     C                   eval      error = *off
510jAC                   eval      w3msg = *blanks
510l *
     C                   select
510l *  Error check for *RETURN.
510l C                   when      $pcmd = '*RETURN'
     *
     *  Verify that label entered is found in UCI and not in stock
     *
510l C     ucikey        chain (n) ucicw                              79
510laC                   if        *in79 = *on or uciitm<>w16item
510l C                   eval      *in24 = *on
510l C                   eval      error = *on
510l C                   eval      w3msg  = desc(6)
510l C                   goto      endck3
510l C                   endif
510lAC                   if        *in79 = *off and ucists = 'Y'
510lAC                   eval      *in24 = *on
510lAC                   eval      error = *on
510lAC                   eval      w3msg  = desc(7)
510l C                   goto      endck3
510lAC                   endif
     *
510l *  Verify that quantity scanned does not exceed quantity on order
510l *
510l C                   if        w3scan >= w3qrmn
510l C                   eval      *in24 = *on
510l C                   eval      error = *on
510l C                   eval      w3msg  = desc(9)
510l C                   goto      endck3
510l C                   endif
     *
510l C                   other
     *
     *  Verify that label entered is found
     *
510gDC*    ucikey        chain     ucicw                              79
510gMC     ucikey        chain (n) ucicw                              79
510 aC                   if        *in79 = *on or uciitm<>w16item
     C                   eval      *in24 = *on
     C                   eval      error = *on
510jD ***                eval      errmsg = desc(6)
510jMC                   eval      w3msg  = desc(6)
510jD ***                exsr      zm1001
     C                   goto      endck3
     C                   endif
510jAC                   if        *in79 = *off and ucists = 'N'
510jAC                   eval      *in24 = *on
510jAC                   eval      error = *on
510jAC                   eval      w3msg  = desc(7)
     C                   goto      endck3
510jAC                   endif
     *
     *  Verify that label has not already been scanned
     *
510 aC     uciky2        chain     ucicw7
510 aC                   if        %found
     C                   eval      *in24 = *on
     C                   eval      error = *on
510jD ***                eval      errmsg = desc(7)
510jMC                   eval      w3msg  = desc(7)
510jD ***                exsr      zm1001
     C                   goto      endck3
     C                   endif
     *
     *  Verify that quantity scanned does not exceed quantity on order
     *
     C                   if        w3scan >= w3qrmn
     C                   eval      *in24 = *on
     C                   eval      error = *on
510jD ***                eval      errmsg = desc(9)
510jMC                   eval      w3msg  = desc(9)
510jD ***                exsr      zm1001
     C                   goto      endck3
     C                   endif
     *
510l C                   endsl
     C     endck3        endsr
510jA*----------------------------------------------------------------
510jA*
510jA*    zzchk4 - Check for valid entry on screen four
510jA*
510jAC     zzchk4        begsr
510jA
510jAC                   eval      error = *off
510jAC                   eval      w4msg = *blanks
510jA*
510jA*
510jA*  License required
510jA*
510jAC                   if        w4lcn# = *Blanks
510jAC                   eval      *in24 = *on
510jAC                   eval      error = *on
510jAC                   eval      w4msg = desc(12)
510jD ***                exsr      zm1001
510jAC                   goto      endck4
510jAC                   endif
510jA*
510jA*  Verify that license entered is found
510jA*
510jAC     uciky1        chain (n) ucicw1                             79
510jAC                   if        *in79 = *on
510jAC                   eval      *in24 = *on
510jAC                   eval      error = *on
510jAC                   eval      w4msg = desc(13)
510jD ***                exsr      zm1001
510jAC                   goto      endck4
510jAC                   endif
510jA*
510jA*  If no errors, count up quantity
510jA*
510jAC                   if        error = *off
510jA
510jAC     uciky1        setll     ucicw1
510jAC                   dou       %eof(ucicw1)
510jAC     uciky1        reade     ucicw1
510jAC                   if        not %eof(ucicw1)
510jAC                             and ucists = 'Y'
510 aC                             and uciitm = w16item
510jAC                   eval      w4scan = w4scan + 1
510jAC                   endif
510jAC                   enddo
510jA
510jA*  Error; cannot scan by lic#  Must scan by UCI
510jAC                   if        w4qrmn > w2qrmn
510jAC                   eval      *in24 = *on
510jAC                   eval      error = *on
510jAC                   eval      w4msg = desc(14)
510jD ***                exsr      zm1001
510jAC                   goto      endck4
510jAC                   endif
510jA
510jAC                   endif
510jA*
510jAC     endck4        endsr
     *----------------------------------------------------------------
     *
     *    zzupd3 - Update screen three - Write record to PAKERCW
     *
     C     zzupd3        begsr

     *
510l C                   if        $pcmd <> '*RETURN'
510cAC                   eval      uciout = *blanks
510hDC*                  eval      ucisqo = lbseq
510cAC     ordmky        chain     ordhm
510cAC                   if        %found(ordhm)
510cAC                   eval      pakhm1_base = hmmsc1
510hDC*                  eval      uciout = pakhm1_vblen
510cAC                   endif
510lAC                   endif

     C                   eval      w3scan = w3scan + 1
     *
510gAC     ucikey        chain     ucicw                              79
510lDC*                  eval      uciout = pakhm1_vblen
510lDC*                  eval      ucisqo = lbseq
510hAC                   eval      uciitm = lbitem
     *
510kAC                   Select
510kAC                   when      $pcmd = '*RETURN'
     *   Get return fields.
510lAC     rtnkey        chain     orrtn1                             79
510lAC                   if        %found(orrtn1)
510lAC                   eval      ucirde = orrdte
510lAC                   eval      ucirti = orrtim
510lAC                   eval      ucircd = orrcod
510lAC                   else
510lAC                   eval      ucirde = *zeros
510lAC                   eval      ucirti = *zeros
510lAC                   eval      ucircd = *blanks
510lAC                   endif
510lAC                   if        oriinv = 'Y'
510kAC                   eval      ucists = 'Y'
510lAC                   else
510lAC                   eval      ucists = 'N'
510lAC                   endif
510kAC                   eval      ucipck = 'N'
510kAC                   eval      ucirts = 'Y'
510lDC*                  eval      ucirti = *zeros
510lDC*                  eval      ucirde = *zeros
510lAC                   eval      ucirtt = lbtrn#
     *
510kAC                   other
510 AC                   eval      ucists = 'N'
510 AC                   eval      ucipck = 'Y'
510 AC                   eval      ucirts = 'N'
510lAC                   eval      uciout = pakhm1_vblen
510lAC                   eval      ucisqo = lbseq
510lAC                   eval      ucirtt = *zero
510lAC                   eval      ucipkt = w1tran
510lAC                   eval      ucilbl = w2lbl#
510kAC                   endsl
     *
510lDC*                  eval      ucirtt = *zero
510lDC*                  eval      ucipkt = w1tran
510lDC*                  eval      ucilbl = w2lbl#
510 AC                   update    ucirec
     *
510lAC                   if        $pcmd <> '*RETURN'
     C                   eval      ocwhse = lbwhse
     C                   eval      ocord  = lbord
     C                   eval      ocseq# = lbseq
     C                   eval      ocseq  = w3scan
     C                   eval      ocitem = w3item
510 aC                   eval      occwgt = uciwgt
     C                   eval      octran = w1tran
     C                   eval      oclbl# = w2hlbl
     C                   write     ocrec
650aAc                   eval      processstatus = '*ADD'
650aAc                   exsr      processCWLog
510lAC                   endif
     *
     C                   endsr
     *
510jA*----------------------------------------------------------------
510jA*
510jA*    zzupd4 - Update screen four
510jA*
510jAC     zzupd4        begsr

     C                   eval      w4scan = *zeros

510jAC                   eval      uciout = *blanks
510jDC*                  eval      ucisqo = lbseq
510jAC     ordmky        chain     ordhm
510jAC                   if        %found(ordhm)
510jAC                   eval      pakhm1_base = hmmsc1
510jDC*                  eval      uciout = pakhm1_vblen
510jAC                   endif

510jAC     uciky1        setll     ucicw1
510jAC                   dou       %eof(ucicw1)
510jAC     uciky1        reade     ucicw1
510jAC                   if        not %eof(ucicw1)
510jAC                             and ucists = 'Y'
510jAC                             and uciitm = w16item

     C                   eval      w4scan = w4scan + 1

510jAC                   eval      uciout = pakhm1_vblen
510jAC                   eval      ucisqo = lbseq
510jAC                   eval      uciitm = lbitem
510jAC                   eval      ucists = 'N'
510jAC                   eval      ucipck = 'Y'
510jAC                   eval      ucirts = 'N'
510jAC                   eval      ucirtt = *zero
510jAC                   eval      ucipkt = w1tran
510jAC                   eval      ucilbl = w2lbl#
510jAC                   update    ucirec1
     *
510jAC                   eval      ocwhse = lbwhse
510jAC                   eval      ocord  = lbord
510jAC                   eval      ocseq# = lbseq
510jAC                   eval      ocseq  = w4scan
510jAC                   eval      ocitem = w3item
510jAC                   eval      occwgt = uciwgt
510jAC                   eval      octran = w1tran
510jAC                   eval      oclbl# = w2hlbl
510jAC                   write     ocrec
650aAc                   eval      processstatus = '*ADD'
650aAc                   exsr      processCWLog
     *
510jAC                   endif
510jAC                   enddo

510jAC                   endsr
510jA*
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     *
     C     endcm1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
510jD ***                if        *inkl = *on or *inkq = *on or *inku = *on
510jMC                   if        *inkl = *on or *inkq = *on
510jAC                             or *inkr = *on or *inku = *on
     C                   eval      cmdtkn = *on
     *
     *  command 12 previous screen
     C                   if        *inkl = *on
510kAC                   select
510kAC                   when      $pcmd = '*PICK'
510kAC                   eval      nxtscr = 'EOJ'
510lAC                   when      $pcmd = '*RETURN'
510lAC                   eval      cmdtkn = *off
510kAC                   other
     C                   eval      nxtscr = '02'
510kAC                   endsl
     C                   goto      endcm3
     C                   endif
     *
     *  command 16 Catch Weight Detail Display
     C                   if        *inkq = *on
510fDC     w2hlbl        chain     label
     C                   eval      $portn = '*NORMAL'
     C                   call      'CE190'
510 aC                   parm                    lbord
510 aC                   parm                    lbseq
510 aC                   parm                    lbitem
510 aC                   parm                    lbtrn#
510 aC                   parm                    portn
     *
     *  Verify that label had catch weight entries to display
     *
     C                   if        $portn = '*NOGOOD'
     C                   eval      *in24 = *on
     C                   eval      error = *on
510jD ***                eval      errmsg = desc(10)
510jMC                   eval      w3msg  = desc(10)
510jD ***                exsr      zm1001
     C                   goto      endcm3
     C                   endif
     C                   endif
510jA*  command 17 scan lic# (go to scrn4)
510jAC                   if        *inkr = *on
510jAC                   eval      nxtscr = '04'
510jAC                   exsr      scr04i
510jAC                   goto      endcm3
510jAC                   endif
     *
     *  command 20 Complete
     C                   if        *inku = *on
510kAC                   select
510kAC                   when      $pcmd = '*PICK'
510kAC                   eval      nxtscr = 'EOJ'
510lAC                   when      $pcmd = '*RETURN'
510lAC                   if        w3scan = w3qrmn
510lAC                   eval      nxtscr = 'EOJ'
510lAC                   else
510lAC                   eval      cmdtkn = *off
510lAC                   endif
510kAC                   other
     C                   eval      nxtscr = '02'
510kAC                   endsl
510kAC                   goto      endcm3
     C                   endif
     *
     C                   endif
     *
     C     endcm3        endsr
     *
510jA*----------------------------------------------------------------
510jA*
510jA*  ZZCMD4   User defined command keys for screen 4.
510jA*
510jAC     zzcmd4        begsr
510jA*
510jAC                   if        *inkl = *on or *inkq = *on or *inku = *on
510jAC                   eval      cmdtkn = *on
510jA*
510jA*  command 12 previous screen
510jAC                   if        *inkl = *on
510jAC                   eval      nxtscr = '02'
510jAC                   goto      endcm4
510jAC                   endif
510jA*
510jA*  command 16 Catch Weight Detail Display
510jAC                   if        *inkq = *on
510jAC     w2hlbl        chain     label
510jAC                   eval      $portn = '*NORMAL'
510jAC                   call      'CE190'
510jAC                   parm                    lbord
510jAC                   parm                    lbseq
510jAC                   parm                    lbitem
510jAC                   parm                    lbtrn#
510jAC                   parm                    portn
510jA*
510jA*  Verify that label had catch weight entries to display
510jA*
510jAC                   if        $portn = '*NOGOOD'
510jAC                   eval      *in24 = *on
510jAC                   eval      error = *on
510jD ***                eval      errmsg = desc(10)
510jMC                   eval      w4msg  = desc(10)
510jD ***                exsr      zm1001
510jAC                   goto      endcm4
510jAC                   endif
510jAC                   endif
510jA*
510jA*  command 20 Complete
510jAC                   if        *inku = *on
510jAC                   eval      nxtscr = '02'
510jAC                   endif
510jA*
510jAC                   endif
510jA*
510jAC     endcm4        endsr
     *
     *----------------------------------------------------------------
     *
     *  zzfIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      w1tran = *zeros
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   eval      w2item = lbitem
     C                   eval      w2desc = itdesc
     C                   eval      w2qrmn = lbqpck
     C                   eval      w2lbl# = lblbl#
     *
     C     endfl2        endsr
     *----------------------------------------------------------------
     *
     *  zzfIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
510kAC                   select
510kAC                   when      $pcmd = '*PICK'
510kaC                   eval      w2hlbl = $plbl
510kaC                   eval      w2lbl# = $plbl
510fDC     w2hlbl        chain     label
510kAC                   eval      w3item = lbitem
510kaC                   eval      w16item= lbitem
510kAC                   eval      w3qrmn = $pqty
510kAC                   eval      w1tran = lbtrn#
510kAC                   eval      w10lbl = *blanks
510kAC                   eval      @pwhse = $pwhse
     C*
510lAC                   when      $pcmd = '*RETURN'
510laC                   eval      w2hlbl = $plbl
510laC                   eval      w2lbl# = $plbl
510laC     w2hlbl        chain     label
510lAC                   eval      w3item = lbitem
510laC                   eval      w16item= lbitem
510lAC                   eval      w3qrmn = $pqty
510lAC                   eval      w1tran = lbtrn#
510lAC                   eval      w10lbl = *blanks
510lAC                   eval      @pwhse = $pwhse
510kAC                   other
     C                   eval      w3item = w2item
     C                   eval      w3qrmn = w2qrmn
PAKa C                   eval      w10lbl = *blanks
     C                   eval      w16item= w2item
510kAC                   endsl
     *
510fD ***  labkey        setgt     label7
510fD ***                readp     label7                                 77
510fDC     w2hlbl        chain     label
510fAc     itmkey        chain     piritem
510fAc                   if        %found(piritem)
     C                   eval      w3desc = itdesc
510fAc                   else
510fAC                   eval      w3desc = 'item not found'
510fAC                   eval      itcwgt = 'N'
510fAc                   endif
     *  get last sequence scanned from ordc
     C     ordkey        setgt     ordc1
510 aC                   readp(n)  ordc1                                  77
510 aC                   if        *in77 = *off and oclbl# = w2hlbl
     C                   eval      w3scan = ocseq
     C                   else
     C                   eval      w3scan = 0
     C                   endif
     C                   endsr
510jA*----------------------------------------------------------------
510jA*
510jA*  zzfIl4   Fill screen 4 fields with info from file.
510jA*
510jAC     zzfil4        begsr
510jA*
510jAC                   eval      w3item = w2item
510jAC                   eval      w4qrmn = w2qrmn
510jAC                   eval      w4scan = *zeros
510jAC                   eval      w4lcn# = *blanks
510jAC                   eval      w16item= w2item
510jA*
510jA*
510jAC                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error<>'1'
     C     1             chain     cwesfl                             79
PAKa C                   if        *in79 = *off
     C                   eval      *in20 = '1'
     C                   update    cwesfl
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = '1'
     C                   eval      recno = 1
PAka C                   write     cwcmdline
     C                   write     cwectl
510baC                   read      cwectl                               50
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     *
     *  only display in subfile if selected transaction, catch weight item,
     *   and open quantity remaining
     *
     C                   if        lbtrn# = w1tran and itcwgt='Y'
     C                               and lbqpck<>0
PAKa C                   eval      p = p+1
     C                   eval      recno = recno +1
     C                   eval      recnox = recno
     C                   eval      y = recno
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfil2
     C                   write     cwesfl
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in01 = '0'
     C                   write     cwectl
     C                   eval      recno = 0
     C                   endsr
650aA*----------------------------------------------------------------
650aA*  clrCWLog     Clear $cwlog   data structure fields
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr ClrCWLog;

650aA     savever# = $cwver#;
650aA     clear $cwlog;
650aA     $cwver# = savever#;
650aA     $cwaddemp = #emp#;
650aA     $cwaddusr = #user;
650aA     $cwaddpgm  = #prog;
650aA     $cwaddjob  = #job;
650aA     $cwaddnbr = #jobn;

650aA   endsr;
650aA /end-free

650aA*----------------------------------------------------------------
650aA*  ProcessCWLog  Process the CWLOG file Add/Update/Delete
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr processCWlog;
650aA     exsr clrCWLog;
650aA     $cwwhse = ocwhse;
650aA     $cwitem = ocitem;
650aA     $cwseltrn# = octran;
650aA     $cwsellbl# = oclbl#;
650aA     $cwselord  = ocord;
650aA     $cwselseq  = ocseq#;
650aA     $cwselcseq = ocseq;
650aA     $cwwgtlbs = occwgt;
650aA     $cwentflg = 3;

650aA     cwdata = $cwlog;
650aA     cw800(processstatus: cwpgm: cwrtn: cwmsg: cwdata);

650aA     $cwlog = cwdata;

650aA   endsr;
650aA /end-free
     *----------------------------------------------------------------
     *
     *  ZZINZ    Initialization.  Called from Mainline
     *
     C     zzinz         begsr
     *
     *  Define keys used in program.
     *
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    uklbl#
     *
     *  Define full key for main file.
     *
     C     fileky        klist
PAKa C                   kfld                    wblbl#
     *
     *  Define key to get last sequence number assigned per the label
     C     ordkey        klist
     C                   kfld                    lbwhse
     C                   kfld                    w2hlbl
     *
     C     labkey        klist
     C                   kfld                    w1tran
     C                   kfld                    w3item
     *
     C     plblky        klist
PAKa C                   kfld                    w8lbl#
     C                   kfld                    lbord
     C                   kfld                    lbseq
     C                   kfld                    w3item
510l *
510l C     rtnkey        klist
510l C                   kfld                    lbwhse
510l C                   kfld                    lbpbat
510l C                   kfld                    lbitem
     *
510 aC     ucikey        klist
510aMC                   kfld                    w1whse
510 aC                   kfld                    w10lbl

510jAC     uciky1        klist
510jAC                   kfld                    w1whse
510jAC                   kfld                    w4lcn#

510 aC     uciky2        klist
510aMC                   kfld                    w1whse
510 aC                   kfld                    w1tran
510 aC                   kfld                    w10lbl

510cAC     ordmky        klist
510cAC                   kfld                    @pwhse
510cAC                   kfld                    lbord

510fAC     itmkey        klist
510fAC                   kfld                    @pwhse
510fAC                   kfld                    lbitem

     C                   eval      forevr = *off
510kAC                   if        $pcmd = '*PICK' or
510lAC                             $pcmd = '*RETURN'
510kAC                   exsr      scr03i
510kAC                   else
     C                   eval      nxtscr = '01'
510kAC                   endif
     C                   eval      *in02 = *on
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse
     C                   parm      0             #emp#
     C                   parm                    #fnam
     C                   parm                    #init
     C                   parm                    #lnam
     C                   parm                    #whdp
     C                   parm                    #styp
     C                   parm                    #shft
     C                   parm                    #crew
     C                   parm      0             #nhrs
     C                   parm                    #rtn
     *
     C                   eval      @pwhse = #whse
510aAC                   eval      w1whse = #whse
     *
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd
PCKa C                   parm                    #lline
     C                   parm                    #lcol
     C                   endsr
     *----------------------------------------------------------------
     *  COMPILE TIME TABLES
     *
**
Transaction not found.
Transaction already at Status 4.
Transaction. No valid catch weight entries.
Scanned lbl not for this transaction.
Option must be 1 2 or 16.
UCI Number not found in UCICW.
UCI Number already been scanned.
BFC Label. Label or Option required.
UCI Number Exceeds pick quantity.
Option.  No CW Entries Exists.
Item not a catchwgt
License cannot be blank.
Lic# not found in UCICW.
UCI Scanning Only
Invalid Warehouse.
