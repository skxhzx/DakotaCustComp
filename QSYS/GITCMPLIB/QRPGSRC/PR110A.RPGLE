600 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PR110A  Veiew priority replenishments by item - Display
     *  23 Auguse 2000
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
414 A*    08/23/00  DAS  4.14
     *      - Created
     *
417 A*    07/22/03  MLB  4.17
     *      - Enh: Recompiled. New fields added to PRPLFIL.
417aA*    10/01/03  MLB  4.17a
     *      - Enh: Revised program to allow user to select Department,
     *        aisle range and Replenishment status to display.
417bA*    10/07/03  MLB  4.17b
     *      - Enh: Revised ZZFILL to load new replenishment type
     *        field.
     *      - Enh: Revised ZZFILL to load new item type field
500 A*    10/15/04  DAS  5.00
     *      - Enh: Revised Pushback to be FlowRack.
510 A*    07/22/07  JCJ  5.10
     *      - Enh: Converted tp RPG4.  Added new option to reactivate
     *             skipped replenishments.
     *
600 A*    04/28/08  DAS  6.00  P#00045
     *      - License Tracking
     *      - 500 added from Jordano's code.
     *
610aA*    12/18/10  DAS  6.10
     *      - Added Repack type
     *
710a *    02/28/17  GJA  7.10a
     *      - Fix:  F4 prompt was not positioned to correct field
     *              Added Department F4 lookup
     *
720  *    03/12/18  KDE  7.20
     *      - Enh:  Add Staging Replenishment Type
720a *    10/05/18  RH   7.20a
     *      - Enh:  Add option 9=Deactivate - Mark done. Opt not added
     *        to display.  Used by authorized users only.
     *      - Enh:  Add chklist processing for option 8 and 9
720b *    10/05/18  RH   7.20b
     *      - Enh:  Change option 8 to activate done replenishments,
     *        not ony 'A'active replenishments.
730a *    04/24/19  RH   7.30a
     *      - - Fix:  Add option 9 to ZOPT table, missed in 720a
740a *    11/12/20  RH   7.40a
     *      - Enh:  Add Created by field to View 3, JIT or Priority
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program has been revised to work with option '1'
     *    selections similar to how it works with option '4' selections.
     *
     *    This program uses to display subfiles to show more than one
     *    view of the record. To see what was changed search for VW2
     *    starting in column 1.
     *
     *    Allowed F17 and F18 for positioning to top and bottom.
     *
     *    Created a second line for commands.
     *
     *    CMD5 changed to chain and update each view seperately.
     *
     *    RECNO used for all subfiles, SFLRCDNBR not used in format member.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position Cursor
     *  21 - 29   Field Input Error (Reverse Display)
     *  79        Chain Indicator
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        Protect Input Fields for Delete Display
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
740aDF*pr110afm  cf   e             workstn
740aMFpr110a01  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(vw3sfl:recno)
     F                                     sfile(msgrec:msgk)
417aAFslot1     if   e           k disk
     F                                     rename(slrec:slrec1)
     Fworkopt   uf a e           k disk
417aD*PRPLFIL4IF  E           K        DISK
417aMFprplfil3  if   e           k disk
     F                                     rename(prrec:record)
510 AFprplfil8  uf   e           k disk    prefix('R')
720aAFprplfil1  uf   e           k disk    prefix('D')
720a F                                     rename(prrec:drrec)
417aAFwhdept    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
401 MD optln           s             75    dim(2) ctdata perrcd(1)
VW2 D*                   CMDLN   1   1 79
VW2 MD cmdln           s             79    dim(6) ctdata perrcd(1)
417aAD desc            s             50    dim(7) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
417aAD  $kwhdp                 4      8
417aAD  $ktail                 9     11
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  prwhse                 1      3  0 inz(0)
417aAD  prwhdp                 4      8
417aAD  prtail                 9     11
417aAD  prtdis                12     23
417aD*                                       4  18 PRITEM
417aMD  pritem                24     38
417aAD  prseq#                39     43  0 inz(0)
720aA*----------------------------------------------------------------
720aA* Error message(s)
720aAD err01           c                   const('You are not authorized -
720aAD                                     to use this option.')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('NONE')
405 D*             '*NONE'               C         @DELPG
     D @delpg          c                   const('NONE')
     D @prtpg          c                   const('NONE')
720aAD @autpg          c                   const('CHKLIST')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D                                     DIM(3)
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
417aAD  $lwhdp                22     26
     D  $ltruk                22     31
     D  $ltrk2                32     41
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
     *  Other data structures
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     D                 ds
     D  $ec                    1      2p 0
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
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
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
     *  Variables
     *
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
     D kytail          s                   like(slaisl)
     D maxvw           s              1  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D posrec          s              4  0
     D reccnt          s              4  0
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D top             s              1
     D v               s              2  0
     D view            s              1  0
     D warn            s              1
     D wofasl          s                   like(slaisl)
     D wotasl          s                   like(slaisl)
     D x               s              3  0
     D y               s              3  0
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
     *  Let the show begin .....
     *
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
     *
     *    Define key for PRPLFIL8 file.
     *
     C     prkey8        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kwhdp
     C                   kfld                    prseq#
     C                   kfld                    pritem
720aA*
720aAC     prkey1        klist
720aAC                   kfld                    $kwhse
720aAC                   kfld                    $kwhdp
720aAC                   kfld                    prseq#
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
OP1 AC     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     C                   seton                                        lr
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     C                   write     title
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      deldsp
     C                   endif
OP1 AC                   if        nxtscr = '03 '
OP1 AC                   exsr      deldsp
OP1 AC                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
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
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   read      dspsfc                                 50
VW2 AC                   when      view = 2
VW2 AC                   read      vw2sfc                                 50
VW2 AC                   when      view = 3
VW2 AC                   read      vw3sfc                                 50
VW2 AC                   endsl
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
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
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
     *
     *  Screen 02 wrap-up
     *
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
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  Screen 03 initialization
OP1 A*
OP1 AC     scr03i        begsr
OP1 AC                   eval      nxtscr = '03 '
OP1 AC                   eval      *in90 = *on
OP1 AC                   move      *loval        $wkof
OP1 AC                   move      *loval        $wkou
OP1 AC                   write     clr0306
OP1 AC                   write     op1rec
OP1 AC                   eval      pagcmd = '*REFRESH'
OP1 AC                   exsr      pag03
OP1 AC                   write     cmdop1
OP1 AC                   endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  Screen 03 wrap-up
OP1 A*
OP1 AC     scr03e        begsr
OP1 AC                   eval      nxtscr = '01 '
OP1 AC                   eval      *in90 = *off
OP1 AC                   write     clr0306
OP1 A*
OP1 A*   If option 1 was not canceled (no errors)
OP1 A*     then reposition to record just before first deleted rec.
OP1 A*
OP1 AC                   if        cancel = *off
OP1 AC                   eval      $pocmd = '*POSTN2 '
OP1 AC                   eval      $pofky = frstky
OP1 AC                   exsr      fgtway
OP1 AC                   eval      $pocmd = '*GETPREV'
OP1 AC                   exsr      fgtway
OP1 AC                   if        $portn = '*NOMORE '
OP1 AC                   eval      $pocmd = '*TOP    '
OP1 AC                   else
OP1 A*
OP1 A*   Otherwise, position to last record read.
OP1 A*
OP1 AC                   eval      $pocmd = '*POSTN2 '
OP1 AC                   endif
OP1 AC                   exsr      fgtway
OP1 AC                   eval      pagcmd = '*REPOS  '
OP1 AC                   exsr      pag01
OP1 AC                   exsr      optns
OP1 AC                   else
OP1 AC                   eval      $pocmd = '*POSTN2U'
OP1 AC                   eval      $pouky = $puky
OP1 AC                   exsr      fgtway
OP1 AC                   eval      pagcmd = '*REPOS  '
OP1 AC                   exsr      pag01
OP1 AC                   endif
OP1 AC                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
     C     endsc1        endsr
     *----------------------------------------------------------------
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
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  SC3  -  Screen 3
OP1 A*
OP1 AC     sc3           begsr
OP1 AC     status        caseq     rollup        roll03
OP1 AC     status        caseq     rolldn        roll03
OP1 AC     status        caseq     comand        cmd03
OP1 AC                   cas                     ent03
OP1 AC                   endcs
OP1 AC     endsc3        endsr
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
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
     C                   write     dspsfl                               79
222 D*                    Z-ADD1         RECNO2
VW2 AC                   write     vw2sfl                               79
222 D*                    Z-ADD1         RECNO3
VW2 AC                   write     vw3sfl                               79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
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
222 D*R         X         CHAINVW2SFL               79
222 D*R         X         CHAINVW3SFL               79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl
222 D*R                   UPDATVW2SFL
222 D*R                   UPDATVW3SFL
     C                   endif
222 AC     x             chain     vw2sfl                             79
222 AC                   if        not *in79
222 AC                   eval      option = '  '
222 AC                   update    vw2sfl
222 AC                   endif
222 AC     x             chain     vw3sfl                             79
222 AC                   if        not *in79
222 AC                   eval      option = '  '
222 AC                   update    vw3sfl
222 AC                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD6 - ADD RECORD
     *
     C                   if        *inkf
     C                   exsr      inzpar
     C                   eval      $pcmd = '*ADD    '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     C                   if        $prtn <> '*CANCEL '  and
     C                             $prtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
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
VW2 D*  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
VW2 M*  TEST FOR CMD20 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
VW2 D*R         *INKJ     IFEQ '1'
VW2 MC                   if        *inku
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
     *R         CLERR     CABEQ'1'       CMD01E
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
VW2 A*
VW2 A*  TEST FOR CMD10 - Previous view
VW2 A*
VW2 AC                   if        *inkj
VW2 AC                   if        view = 1
VW2 AC                   eval      view = maxvw
VW2 AC                   else
VW2 AC                   eval      view = view - 1
VW2 AC                   endif
VW2 AC                   eval      v = view * 2
VW2 AC                   eval      cmdln2 = cmdln(v)
VW2 AC                   eval      v = v - 1
VW2 AC                   eval      cmdln1 = cmdln(v)
VW2 AC                   goto      cmd01e
VW2 AC                   endif
VW2 A*
VW2 A*  TEST FOR CMD11 - Next view
VW2 A*
VW2 AC                   if        *inkk
VW2 AC                   if        view = maxvw
VW2 AC                   eval      view = 1
VW2 AC                   else
VW2 AC                   add       1             view
VW2 AC                   endif
VW2 AC                   eval      v = view * 2
VW2 AC                   eval      cmdln2 = cmdln(v)
VW2 AC                   eval      v = v - 1
VW2 AC                   eval      cmdln1 = cmdln(v)
VW2 AC                   goto      cmd01e
VW2 AC                   endif
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
     *
     *  CMD02    Screen 2 command key routine
     *
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
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  CMD03    Screen 3 command key routine
OP1 A*
OP1 AC     cmd03         begsr
OP1 A*
OP1 A*  TEST FOR CMD12 - PREVIOUS
OP1 A*
OP1 AC                   if        *inkl
OP1 AC                   eval      cancel = *on
OP1 AC                   exsr      scr03e
OP1 AC                   goto      cmd03e
OP1 AC                   endif
OP1 AC     cmd03e        endsr
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
     C                   if        recno < 11
     C                   add       1             recno
222 D*R                   ADD  1         RECNO2
222 D*R                   ADD  1         RECNO3
     C                   z-add     recno         y
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       DELADE
     *
     *  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     *
     C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
     C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   eval      option = wkoopt
     C                   write     dspsfl
VW2 AC                   write     vw2sfl
VW2 AC                   write     vw3sfl
     C                   endif
     C     delade        endsr
     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     C     deldsp        begsr
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in81 = *on
     C                   eval      recno = 1
222 A*R                   Z-ADD1         RECNO2
222 A*R                   Z-ADD1         RECNO3
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   write     dspsfc
VW2 AC                   when      view = 2
VW2 AC                   write     vw2sfc
VW2 AC                   when      view = 3
VW2 AC                   write     vw3sfc
VW2 AC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
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
     *R         OTAKEN    IFEQ '0'
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   END
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
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
     C                   dou       stop = '1'
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
     C                   eval      $pcmd = '*DELETE '
     C                   eval      $puky = wkokyu
     C                   call      @delpg
     C                   parm                    $parms
     *
     *     Error occured - Error message sent back
     *
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     *
     *     Delete canceled
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   else
     *
     *     Delete was successful.
     *
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   if        cancel = '0'
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
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  ENT03    Screen 3 enter key routine
OP1 A*
OP1 AC     ent03         begsr
OP1 A*
OP1 A*  Save first option 1 key.
OP1 A*
OP1 AC                   eval      frstky = $puky
OP1 A*
OP1 A*  Perform option 1 on the records that have been selected
OP1 A*
OP1 AC     wkoprt        setll     workopt
OP1 AC                   eval      stop = *off
OP1 AC                   dou       stop = '1'
OP1 AC     wkoprt        reade     workopt                                79
OP1 AC                   if        *in79
OP1 AC                   eval      stop = *on
OP1 AC                   else
OP1 A*
OP1 AC                   if        wkoopt = ' 1'
OP1 A*
OP1 A*  Call option 1 program
OP1 A*
OP1 AC                   eval      $puky = wkokyu
OP1 AC                   eval      dsukey = $puky
OP1 A*
OP1 A*     Error occured - Error message sent to program msgq
OP1 A*
     C                   if        $prtn = '*PGMQ   '
OP1 AC                   eval      error = *on
OP1 AC                   eval      cancel = *on
OP1 AC                   eval      stop = *on
     C                   eval      #msgk = $pmsg
OP1 AC                   exsr      zmqmsg
OP1 AC                   else
OP1 A*
OP1 A*     Option 1 was successful.
OP1 A*
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
OP1 AC                   exsr      zmqmsg
OP1 AC                   endif
OP1 AC                   endif
OP1 AC                   if        cancel = '0'
OP1 AC                   delete    wkorec
OP1 AC                   else
OP1 AC                   eval      wkoerr = *on
OP1 AC                   update    wkorec
OP1 AC                   endif
OP1 AC                   endif
OP1 A*
OP1 AC                   endif
OP1 AC                   enddo
OP1 AC                   exsr      scr03e
OP1 AC     ent03e        endsr
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
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are the same.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pouky = *blanks
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
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
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
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
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
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     C     inzpar        begsr
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
OP1 A*
OP1 A*     Do all option 1's together.
OP1 A*
OP1 AC     wkoprt        setll     workopt
OP1 AC                   eval      stop = *off
OP1 AC     wkoprt        reade     workopt                                79
OP1 AC                   dow       not *in79  and
OP1 AC                             wkoopt <> ' 1'
OP1 AC     wkoprt        reade     workopt                                79
OP1 AC                   enddo
OP1 AC                   if        not *in79  and
OP1 AC                             wkoopt = ' 1'
OP1 AC                   eval      otaken = *on
OP1 AC                   eval      $puky = wkokyu
OP1 AC                   exsr      scr03i
OP1 AC                   goto      optnse
OP1 AC                   endif
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
     C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = '0'
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = '1'
     C                   eval      stop = *on
     C                   if        error = '1'
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        refrsh = '1'
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     *   Change
     *
     C                   if        wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   View
     *
     C                   if        wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
510 A*
510 A*   Activate
510 A*
510 AC                   if        wkoopt = ' 8'
720aA*     Check if user is authorized to use this option.
720aAc                   eval      pgmopt = %trim(wkoopt)
720aAC                   call      @AUTPG
720aAC                   parm                    #prog
720aAC                   parm      '9'           pgmopt           20
720aAC                   parm                    #user
720aAC                   parm                    $rtncd
720aAC                   if        $rtncd = '*NO'
720aAC                   eval      error = '1'
720aAC                   eval      errmsg = err01
720aAC                   exsr      ZM0105
720aAC                   goto      eoptns2
720aAC                   endif
510 AC     prkey8        chain     prplfil8
510 AC                   if        %found(prplfil8)
510 AC                   eval      rprflag = 'S'
510 AC                   update    prrec
720bAC                   else
720bAC     prkey1        chain     prplfil1
720bAC                   if        %found(prplfil1)
720bAC                             and dprflag='D'
720bAC                   eval      dprflag = 'S'
720bAC                   update    drrec
720bAC                   endif
510 AC                   endif
510 AC                   else
     *
720aA*   DeActivate - Mark Done
720aA*
720aAC                   if        wkoopt = ' 9'
720aA*     Check if user is authorized to use this option.
720aAc                   eval      pgmopt = %trim(wkoopt)
720aAC                   call      @AUTPG
720aAC                   parm                    #prog
720aAC                   parm      '9'           pgmopt           20
720aAC                   parm                    #user
720aAC                   parm                    $rtncd
720aAC                   if        $rtncd = '*NO'
720aAC                   eval      error = '1'
720aAC                   eval      errmsg = err01
720aAC                   exsr      ZM0105
720aAC                   goto      eoptns2
720aAC                   endif
720aAC     prkey1        chain     prplfil1
720aAC                   if        %found(prplfil1)
720aAC                             and dprflag='S'
720aAC                   eval      dprflag = 'D'
720aAC                   update    drrec
720aAC                   endif
720aAC                   else
     *
     *   Print
     *
     C                   if        wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
     C                   else
     C                   exsr      zzopt
     C                   endif
     C                   endif
510 AC                   endif
720aAC                   endif
     C                   endif
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $prtn = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
720aAC     eoptns2       tag
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
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
     *R         CLERR     CABEQ'1'       PAG01E
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
     C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
     C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
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
     *
     *  PAG02    Screen 2 page routines
     *
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
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  PAG03    Screen 3 page routines
OP1 A*
OP1 AC     pag03         begsr
OP1 A*
OP1 A*  NEXT PAGE
OP1 A*
OP1 AC                   if        pagcmd = '*NEXT   '
OP1 AC                   exsr      pag3fw
OP1 AC                   else
OP1 A*
OP1 A*  PREVIOUS PAGE
OP1 A*
OP1 AC                   if        pagcmd = '*PREV   '
OP1 AC                   exsr      pag3bk
OP1 AC                   else
OP1 A*
OP1 A*  REFRESH SCREEN
OP1 A*
OP1 AC                   if        pagcmd = '*REFRESH'
OP1 AC     deltop        setll     workopt
OP1 AC                   eval      bot = *off
OP1 AC                   exsr      pag3fw
OP1 AC                   endif
OP1 AC                   endif
OP1 AC                   endif
OP1 AC                   eval      pagcmd = *blanks
OP1 AC     pag03e        endsr
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
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
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfac        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C                   if        goback = 10
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
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
     C                   dou       stop = '1'
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
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf2
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
     C                   dou       stop = '1'
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
     C                   if        forceb = '1'
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
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     C     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb2
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C     wkoprt        setgt     workopt
     C                   add       1             goback
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
     C                   dou       stop = '1'
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
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk2        tag
     C                   enddo
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C     wkoprt        setll     workopt
     C                   endif
     C                   exsr      pag2fw
     C     endb2         endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  PAG3FW   Let's see that next page of delete records
OP1 A*
OP1 AC     pag3fw        begsr
OP1 A*
OP1 A*  IF WE ARE AT THE BOTTOM THEN DO NOTHING
OP1 A*
OP1 AC     bot           cabeq     '1'           endf3
OP1 A*
OP1 A*  INITIALIZE VARIABLES FOR LOOKUP
OP1 A*
OP1 AC                   exsr      sflclr
OP1 AC                   move      *loval        $wkof
OP1 AC                   move      *loval        $wkou
OP1 AC                   eval      bot = *off
OP1 AC                   eval      top = *off
OP1 AC                   eval      stop = *off
OP1 AC                   eval      p = 0
OP1 A*
OP1 A*  GET 10 RECORDS TO DISPLAY
OP1 A*
OP1 AC                   dou       stop = '1'
OP1 AC     wkoprt        reade     workopt                                79
OP1 A*
OP1 A*  OUT OF RECORDS - INFORM USER AND SET FLAG
OP1 A*
OP1 AC                   if        *in79
OP1 AC                   eval      stop = *on
OP1 AC                   eval      bot = *on
OP1 AC                   eval      moreln = 'Bottom '
OP1 AC                   goto      endfw3
OP1 AC                   endif
OP1 A*
OP1 A*  RECORD READ - STOP AFTER 10 GOOD RECORDS
OP1 A*
OP1 AC                   if        wkoopt = ' 1'
OP1 AC                   add       1             p
OP1 AC                   exsr      deladd
OP1 AC                   if        p >= 10
OP1 AC                   eval      stop = *on
OP1 AC                   if        forceb = '1'
OP1 AC                   eval      bot = *on
OP1 AC                   eval      moreln = 'Bottom '
OP1 AC                   else
OP1 AC                   eval      moreln = 'More...'
OP1 AC                   endif
OP1 AC                   endif
OP1 AC                   endif
OP1 AC     endfw3        tag
OP1 AC                   enddo
OP1 A*
OP1 A*  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
OP1 A*
OP1 AC                   eval      dsplyd = p
OP1 AC                   eval      forceb = *off
OP1 AC     endf3         endsr
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  PAG3BK   Let's see the previous page of delete records
OP1 A*
OP1 AC     pag3bk        begsr
OP1 A*
OP1 A*  IF WE ARE AT THE TOP THEN DO NOTHING
OP1 A*
OP1 AC     top           cabeq     '1'           endb3
OP1 AC                   eval      forceb = *off
OP1 A*
OP1 A*  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
OP1 A*
OP1 AC     dsplyd        add       10            goback
OP1 AC                   if        bot = '1'
OP1 AC     wkoprt        setgt     workopt
OP1 AC                   add       1             goback
OP1 AC                   endif
OP1 A*
OP1 A*  INITIALIZE VARIABLES FOR LOOKUP
OP1 A*
OP1 AC                   eval      p = 0
OP1 AC                   eval      top = *off
OP1 AC                   eval      bot = *off
OP1 AC                   eval      stop = *off
OP1 A*
OP1 A*  READ SPECIFIED FLITCHES FILE
OP1 A*
OP1 AC                   dou       stop = '1'
OP1 AC     wkoprt        readpe    workopt                                79
OP1 A*
OP1 A*  HIT TOP OF FILE
OP1 A*
OP1 AC                   if        *in79
OP1 AC                   eval      stop = *on
OP1 AC                   eval      top = *on
OP1 AC                   goto      endbk3
OP1 AC                   endif
OP1 A*
OP1 A*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
OP1 A*
OP1 AC                   if        wkoopt = ' 1'
OP1 AC                   add       1             p
OP1 AC                   if        p >= goback
OP1 AC                   eval      stop = *on
OP1 AC                   endif
OP1 AC                   endif
OP1 AC     endbk3        tag
OP1 AC                   enddo
OP1 A*
OP1 A* IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
OP1 A*
OP1 AC                   if        top = '1'
OP1 AC     wkoprt        setll     workopt
OP1 AC                   endif
OP1 AC                   exsr      pag3fw
OP1 AC     endb3         endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
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
OP1 A*----------------------------------------------------------------
OP1 A*
OP1 A*  ROLL03   Screen 3 roll up/down routine
OP1 A*
OP1 AC     roll03        begsr
OP1 A*
OP1 A*  TEST FOR ROLLUP
OP1 A*
OP1 AC                   if        status = rollup
OP1 AC                   eval      pagcmd = '*NEXT   '
OP1 AC                   exsr      pag03
OP1 AC                   goto      rol03e
OP1 AC                   endif
OP1 A*
OP1 A*  TEST FOR ROLLDOWN
OP1 A*
OP1 AC                   if        status = rolldn
OP1 AC                   eval      pagcmd = '*PREV   '
OP1 AC                   exsr      pag03
OP1 AC                   goto      rol03e
OP1 AC                   endif
OP1 AC     rol03e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   readc     dspsfl                                 79
VW2 AC                   when      view = 2
VW2 AC                   readc     vw2sfl                                 79
VW2 AC                   when      view = 3
VW2 AC                   readc     vw3sfl                                 79
VW2 AC                   endsl
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
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   z-add     recno         y
VW2 AC                   when      view = 2
222 D*R                   Z-ADDRECNO2    Y       30
222 MC                   z-add     recno         y
VW2 AC                   when      view = 3
222 D*R                   Z-ADDRECNO3    Y       30
222 MC                   z-add     recno         y
VW2 AC                   endsl
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
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   if        reccnt < 11
     C                   add       1             reccnt
     C                   eval      recno = reccnt
222 D*R                   Z-ADDRECCNT    RECNO2
222 D*R                   Z-ADDRECCNT    RECNO3
     C                   z-add     reccnt        y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   write     dspsfl
VW2 AC                   write     vw2sfl
VW2 AC                   write     vw3sfl
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
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     *
     C                   write     dspsfc
VW2 AC                   write     vw2sfc
VW2 AC                   write     vw3sfc
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     C                   eval      recno = 0
222 D*R                   Z-ADD0         RECNO2  40
222 D*R                   Z-ADD0         RECNO3  40
     *
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
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
     C                   if        error <> '1'
VW2 AC                   select
VW2 AC                   when      view = 1
     C     1             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl
     C                   endif
VW2 AC                   when      view = 2
VW2 AC     1             chain     vw2sfl                             79
VW2 AC                   if        not *in79
VW2 AC                   eval      *in20 = *on
VW2 AC                   update    vw2sfl
VW2 AC                   endif
VW2 AC                   when      view = 3
VW2 AC     1             chain     vw3sfl                             79
VW2 AC                   if        not *in79
VW2 AC                   eval      *in20 = *on
VW2 AC                   update    vw3sfl
VW2 AC                   endif
VW2 AC                   endsl
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
222 D*R         RECCNT    IFGT 0
     C                   eval      *in81 = *on
222 D*R                   ENDIF
     C                   eval      recno = posrec
222 D*R                   Z-ADDPOSREC    RECNO2
222 D*R                   Z-ADDPOSREC    RECNO3
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   write     dspsfc
VW2 AC                   when      view = 2
VW2 AC                   write     vw2sfc
VW2 AC                   when      view = 3
VW2 AC                   write     vw3sfc
VW2 AC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        10            x
VW2 AC                   select
VW2 AC                   when      view = 1
     C     x             chain     dspsfl                             79
VW2 AC                   when      view = 2
VW2 AC     x             chain     vw2sfl                             79
VW2 AC                   when      view = 3
VW2 AC     x             chain     vw3sfl                             79
VW2 AC                   endsl
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   update    dspsfl
VW2 AC                   when      view = 2
VW2 AC                   update    vw2sfl
VW2 AC                   when      view = 3
VW2 AC                   update    vw3sfl
VW2 AC                   endsl
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
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
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
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
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0001  Option under construction.
     *
     C     zm0001        begsr
     C                   eval      #msgid = 'PIR0001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
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
     *
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
     *
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
     *
     C     zm0104        begsr
     C                   eval      #msgid = 'PIR0104'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
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
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Warehouse.
     *
     C                   if        row# = 3  and
710aMC                             col# >= 65
710aDC***                if        row# = 4  and
710aDC***                          col# >= 48
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      ptinp1 = $lwhse
     C                   endif
     C                   else
710aA*
710aA*     Warehouse department.
710aA*
710aAC                   if        row# = 4
710aAC                   eval      *in02 = *on
710aAC                   eval      $lcmd = '*LOOKUP '
710aAC                   eval      $lwhse = ptinp1
710aAC                   eval      $lwhdp = ptinp2
710aAC                   call      'WD900'
710aAC                   parm                    $lparm
710aAC                   if        $lrtn = '*SELECT '
710aAC                   eval      ptinp2 = $lwhdp
710aAC                   endif
710aAC                   endif
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endif
     C                   goto      endcm1
     C                   endif
     *
     *  Test for F9 - Display all warehouses
     *
     C                   if        *inki
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*F9     '
     C                   goto      endcm1
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     C     fileky        chain     record                             79
     *
     *    Code to use when file key and unique key are different.
     *
     *R         FILUKY    CHAINRECORDU              79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *                    READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        reade     record                                 79
417aA*
417aAC                   select
417aAC                   when      *in79
417aA*
417aA*    Display only Open Priority Replenishments.
417aAC                   when      wostat = '*OPN'  and
417aAC                             prflag <> 'S'
417aAC                   goto      try1
417aA*
417aA*    Display only Closed Priority Replenishments.
417aAC                   when      wostat = '*CLS'  and
417aAC                             prflag <> 'D'
417aAC                   goto      try1
417aA*
417aA*    Omit aisles not in range entered by user.
417aAC                   when      wofasl > *blanks  and
417aAC                             prtail < wofasl  or
417aAC                             wofasl > *blanks  and
417aAC                             prtail > wotasl
417aAC                   goto      try1
417aA*
417aAC                   endsl
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
     *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        readpe    record                                 79
417aA*
417aAC                   select
417aAC                   when      *in79
417aA*
417aA*    Display only Open Priority Replenishments.
417aAC                   when      wostat = '*OPN'  and
417aAC                             prflag <> 'S'
417aAC                   goto      try2
417aA*
417aA*    Display only Closed Priority Replenishments.
417aAC                   when      wostat = '*CLS'  and
417aAC                             prflag <> 'D'
417aAC                   goto      try2
417aA*
417aA*    Omit aisles not in range entered by user.
417aAC                   when      wofasl > *blanks  and
417aAC                             prtail < wofasl  or
417aAC                             wofasl > *blanks  and
417aAC                             prtail > wotasl
417aAC                   goto      try2
417aA*
417aAC                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     *   Added date
     *
     C                   if        pradte = 0
     C                   eval      w2adte = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      pradte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2adte = $cvd6o
     C                   endif
417bA*
417bA*   Item type
417bA*
417bAC                   select
417bAC                   when      prtype = 'B'
417bAC                   eval      w2itmt = 'Breakdow'
417bAC                   move      'n '          w2itmt
417bA*
417bAC                   other
417bA*
417bAC                   eval      w2itmt = 'Normal  '
417bAC                   endsl
417bA*
417bA*   Replenishment type
417bA*
417bAC                   select
500 DC**                 when      prrplt = 'E'
500 DC**                 eval      w3rplt = 'Eaches  '
500 MC                   when      prrplt = 'B'
720 DC*                  eval      w3rplt = 'Breadkdown'
720 AC                   eval      w3rplt = 'Breakdown'
417bA*
500 DC**                 when      prrplt = 'P'
500 DC**                 eval      w3rplt = 'Pushback'
500 MC                   when      prrplt = 'F'
500 MC                   eval      w3rplt = 'FlowRack'
610aAC                   when      prrplt = 'R'
610aAC                   eval      w3rplt = 'Repack'
720 AC                   when      prrplt = 'S'
720 AC                   eval      w3rplt = 'Staging'
417bA*
417bAC                   other
417bA*
417bAC                   eval      w3rplt = 'Normal  '
417bAC                   endsl
740aA*
740aA*   Created by: JIT or Priority
740aA*
740aAC                   select
740aAC                   when      prseq# < 0
740aAC                   eval      w3crtd = 'JIT       '
740aAC                   other
740aAC                   eval      w3crtd = 'Priority  '
740aAC                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    prwhse
417aD*R                   KFLD           PRITEM
417aMC                   kfld                    prwhdp
417aAC                   kfld                    prtail
     *
     *  Define UNIQ key for main file.
     *
     C     filuky        klist
     C                   kfld                    prwhse
417aD*R                   KFLD           PRITEM
417aMC                   kfld                    prwhdp
417aAC                   kfld                    prtail
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
417aAC                   kfld                    $kwhdp
417aA*
417aA*    Define key for SLOT1 file. (Verify Aisle range)
417aA*
417aAC     keysl1        klist
417aAC                   kfld                    $kwhse
417aAC                   kfld                    $kwhdp
417aAC                   kfld                    kytail
     *
     *  Setup option and command display lines.
     *
VW2 AC                   eval      view = 1
VW2 AC                   eval      maxvw = 3
     C                   eval      optln1 = optln(1)
401 AC                   eval      optln2 = optln(2)
     C                   eval      cmdln1 = cmdln(1)
VW2 AC                   eval      cmdln2 = cmdln(2)
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     zzinz2        begsr
     *
     *   Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     prwhse        parm      0             #whse             3 0
     *
     *   Verify warehouse and get description.
     *
     C                   eval      whcode = prwhse
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = prwhse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
417aD*R                   MOVE '1'       *IN01
417aMC                   eval      *in11 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      $kwhse = prwhse
     C                   eval      whcode = prwhse
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
417aA*
417aA*  Get initial department.
417aA*
417aAC     keywd         klist
417aAC                   kfld                    $kwhse
417aAC                   kfld                    wdcode
417aA*
417aAC                   eval      wdcode = *blanks
417aAC     keywd         setll     whdept
417aAC                   read      whdept                                 79
417aAC                   if        *in79
417aAC                   eval      wddesc = *blanks
417aAC                   endif
417aAC                   eval      $kwhdp = wdcode
417aAC                   eval      prwhdp = wdcode
417aA*
417aA*
417aA*    Display 'Open' Priority Replenishments.
417aAC                   eval      wostat = '*OPN'
417aAC                   movel     desc(5)       wostsd
     *
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   endsr
417aA*----------------------------------------------------------------
417aA*
417aA*  ZZCKAI   Verify aisle range entered.
417aA*
417aAC     zzckai        begsr
417aA*
417aAC                   eval      *in23 = *off
417aAC                   eval      *in13 = *off
417aAC                   eval      *in24 = *off
417aAC                   eval      *in14 = *off
417aA*
417aA*    Verify from/to aisles both blank or both filled in.
417aA*
417aAC                   if        ptinp3 = *blanks  and
417aAC                             ptinp4 > *blanks  or
417aA*
417aAC                             ptinp3 > *blanks  and
417aAC                             ptinp4 = *blanks
417aA*
417aAC                   eval      error = *on
417aAC                   eval      *in23 = *on
417aAC                   eval      *in13 = *on
417aAC                   eval      *in24 = *on
417aAC                   eval      *in14 = *on
417aAC                   eval      errmsg = *blanks
417aAC                   eval      errmsg = desc(3)
417aAC                   exsr      zm0105
417aAC                   endif
417aA*
417aA*    Right adjust From aisle code.
417aA*
417aAC                   eval      wofasl = *blanks
417aAC                   if        ptinp3 > *blanks
417aAC                   eval      $cstr = ptinp3
417aAC                   call      'ADJUST'
417aAC                   parm      '*RIGHT  '    $ccmd             8
417aAC                   parm                    $cstr            30
417aA*
417aAC                   move      $cstr         kytail
417aAC                   move      $cstr         wofasl
417aAC     keysl1        setll     slot1                                  78
417aAC                   if        not *in78
417aAC                   eval      error = *on
417aAC                   eval      *in23 = *on
417aAC                   eval      *in13 = *on
417aAC                   eval      errmsg = *blanks
417aAC                   eval      errmsg = desc(1)
417aAC                   exsr      zm0105
417aAC                   endif
417aAC                   endif
417aA*
417aA*    Verify To aisle.
417aA*
417aA*    Right adjust To aisle code.
417aA*
417aAC                   eval      wotasl = *blanks
417aAC                   if        ptinp4 > *blanks
417aAC                   eval      $cstr = ptinp4
417aAC                   call      'ADJUST'
417aAC                   parm      '*RIGHT  '    $ccmd
417aAC                   parm                    $cstr
417aA*
417aAC                   move      $cstr         kytail
417aAC                   move      $cstr         wotasl
417aAC     keysl1        setll     slot1                                  78
417aAC                   if        not *in78
417aAC                   eval      error = *on
417aAC                   eval      *in24 = *on
417aAC                   eval      *in14 = *on
417aAC                   eval      errmsg = *blanks
417aAC                   eval      errmsg = desc(4)
417aAC                   exsr      zm0105
417aAC                   endif
417aAC                   endif
417aA*
417aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to change warehouse.
     *
     C                   if        ptinp1 <> 0
     *
     *      Verify warehouse entry.
     *
     C                   eval      whcode = ptinp1
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
417aD*R                   MOVE *ON       *IN01
417aMC                   eval      *in11 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
417aD*R                   MOVE '1'       *IN01
417aMC                   eval      *in11 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      prwhse = ptinp1
     C                   eval      $kwhse = prwhse
     C                   eval      pritem = *blanks
     C                   eval      whcode = ptinp1
     C                   movel     $lerm         whdesc
     C                   eval      ptinp1 = 0
     C                   eval      repos = *on
     C                   endif
     C                   endif
     C                   endif
417aA*
417aA*  See if user is trying to change department.
417aA*
417aAC                   if        ptinp2 <> *blanks
417aA*
417aA*      Verify department entry.
417aA*
417aAC                   eval      wdcode = ptinp2
417aAC                   eval      wddesc = *blanks
417aAC                   eval      $lcmd = '*VERIFY '
417aAC                   eval      $lwhse = $kwhse
417aAC                   eval      $lwhdp = ptinp2
417aAC                   call      'WD900'
417aAC                   parm                    $lparm
417aAC                   if        $lrtn = '*ERROR  '
417aAC                   eval      error = *on
417aAC                   eval      *in32 = *on
417aAC                   eval      *in12 = *on
417aAC                   movel     $lerm         errmsg
417aAC                   exsr      zm0105
417aAC                   goto      endzps
417aAC                   else
417aAC                   if        $lrtn = '*PGMQ   '
417aAC                   eval      error = *on
417aAC                   eval      *in32 = *on
417aAC                   eval      *in12 = *on
417aAC                   eval      #msgk = $lmsg
417aAC                   exsr      zmqmsg
417aAC                   goto      endzps
417aAC                   endif
417aAC                   endif
417aAC                   eval      prwhdp = ptinp2
417aAC                   eval      $kwhdp = ptinp2
417aAC                   eval      prtail = *blanks
417aAC                   eval      prtdis = *blanks
417aAC                   eval      pritem = *blanks
417aAC                   movel     $lerm         wddesc
417aAC                   eval      ptinp2 = *blanks
417aAC                   eval      repos = *on
417aAC                   endif
     *
417aD*  See if user is trying to position to code
417aM*  See if user is trying to change Aisle Range.
     *
417aD*R         PTINP2    IFNE *BLANKS
417aMC                   if        ptinp3 <> *blanks  or
417aAC                             ptinp4 <> *blanks  or
417aA*
417aA*  Aisle range previously entered. User wants all aisles now.
417aAC                             ptinp3 = *blanks  and
417aAC                             wofasl > *blanks  or
417aAC                             ptinp4 = *blanks  and
417aAC                             wofasl > *blanks
417aA*
417aA*  Aisle range previously entered. User wants all aisles now.
417aA*  Clear key fields to reposition at top of list.
417aAC                   if        ptinp3 = *blanks  and
417aAC                             ptinp4 = *blanks
417aAC                   eval      prtail = *blanks
417aAC                   eval      prtdis = *blanks
417aAC                   eval      pritem = *blanks
417aAC                   endif
417aA*
417aA*    Verify aisle range entered.
417aAC                   exsr      zzckai
417aAC     error         cabeq     *on           endzps
417aA*
417aD*R                   MOVE PTINP2    PRITEM
417aAC                   eval      prtail = wofasl
417aAC                   eval      prtdis = *blanks
417aAC                   eval      pritem = *blanks
417aD*R                   MOVE *BLANKS   PTINP2
     C                   eval      repos = *on
     C                   endif
417aA*
417aA*  See if user is trying to change Replenishment status.
417aA*
417aAC                   if        ptinp5 <> *blanks
417aA*
417aAC                   select
417aAC                   when      ptinp5 <> '*OPN'  and
417aAC                             ptinp5 <> '*CLS'  and
417aAC                             ptinp5 <> '*ALL'
417aAC                   eval      *in25 = *on
417aAC                   eval      *in15 = *on
417aAC                   eval      errmsg = desc(4)
417aAC                   exsr      zm0105
417aA*
417aAC                   other
417aA*
417aA*    Initialize status description.
417aAC                   select
417aAC                   when      ptinp5 = '*OPN'
417aAC                   movel     desc(5)       wostsd
417aAC                   when      ptinp5 = '*CLS'
417aAC                   movel     desc(6)       wostsd
417aAC                   when      ptinp5 = '*ALL'
417aAC                   movel     desc(7)       wostsd
417aAC                   endsl
417aAC                   eval      wostat = ptinp5
417aAC                   eval      ptinp5 = *blanks
417aAC                   eval      prtail = *blanks
417aAC                   eval      prtdis = *blanks
417aAC                   eval      pritem = *blanks
417aAC                   eval      repos = *on
417aAC                   endsl
417aAC                   endif
417aA*
     C     endzps        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *R         $POCMD    IFEQ '*TOP'
     *R         *LOVAL    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         *HIVAL    SETLLRECORD
     *R                   END
     *R                   END
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 8 9
**  OPTLN - Option display line
8=Activate

**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F9=Seq order  F12=Cancel
F10=View 3  F11=View 2  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F9=Seq order  F12=Cancel
F10=View 1  F11=View 3  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F9=Seq order  F12=Cancel
F10=View 2  F11=View 1  F17=Top  F18=Bottom  F20=Move to top
**
From aisle not valid.
To aisle not valid.
From/to both blank or only one filled in.
Invalid status selection entered.
Open Priority Replenishments
Closed Priority Replenishments
All Priority Replenishments
