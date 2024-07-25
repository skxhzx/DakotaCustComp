640aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RN146      License entry Customer Returns
     *  02 July, 1997
     *  Roxanne Harrison
     *
     *  SK112 - 1.02
     *
     *  Revisions
     *
222 A*    06/27/97  DAS
     *      - Set on indicator 85 to force SFLNXTCHG read for all records.
411 A*    05/13/99  RH
     *      - Add slot to screen, screen is no longer multi column.   rds.
416 A*    05/23/02  RRH  4.16
     *      - Change W1LCNS to 15 Alphanumeric.
     *      - Left justify, remove leadind blanks for license
     *
417 A*    04/28/03  MLB  4.17
     *      - Revised ZZCHK1 to use *LEFTNOZ for call to ADJUST.
417bA*    06/25/03  RH   4.17b
     *      - Fix: Do not aloow entry of special characters in license
     *             entry field.
640aA*    07/18/12  LMC  6.40a
     *      - Converted to ILE
     *      - Enh:  Added incoming parms to create new LICINFO records.
     *      - Added logic to create license
     *      - Added logic to update LICINFO
     *      - Added input parms
650aA*    05/22/13  LMC  6.50a
     *      - Enh: RCVRTN transaction for MRC reporting.
650bA*    09/28/12  LMC  6.50b
     *      - Enh:  Added GS1/UCI Scanning                            .
650cA*    06/20/13  LMC  6.50c
     *      - Enh: Add call to CALCPTI
     *      NOTE: this enhancement needs to include Program CALCPTI
650dA*    10/31/13  LMC  6.50d
     *      - Enh: Add incoming parm for the entered pti#
720aA*    07/25/16  MR   7.20a
     *      - Enh: Populate parm values in DRIUICINFO
     *             for new UCIINFO file format.
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frn146fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(detail1:recno)
     F                                     sfile(msgrec:msgk)
     FLabel2    if   e           k disk
     F                                     rename(lbrec:record)
640aDF*License   uf a e           k disk
640aMFLicense   if   e           k disk
     F                                     rename(lirec:record2)
640aAFLicense1  uf a e           k disk
640aAF                                     rename(lirec:lirec1)
     Fwarehs    if   e           k disk
640aDF*piritem   if   e           k disk
640aDF*itemdsc   if   e           k disk
     Foptions   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
417bD*                   DESC    1   8 50
417bMD desc            s             50    dim(9) ctdata perrcd(1)
640aA*----------------------------------------------------------------
640aA*  DRI parameters
640aA*----------------------------------------------------------------
640aA /COPY *libl/qcopysrc,C#DRIPARMS

640aA /COPY *libl/qcopysrc,C#SLOT
640aA /COPY *libl/qcopysrc,C#LICINFO
640aA /COPY *libl/qcopysrc,C#LICENSE
640aA /COPY *libl/qcopysrc,C#ITEM
650bA /COPY *libl/qcopysrc,C#uciinfo
640aAD savever#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pitem                22     36
     D  $ppo                  37     45
     D  $prq1                 46     50  0
     D  $prq2                 51     55  0
     D  $prq3                 56     60  0
     D  $prpal                61     63  0
640aA*  Extra parameters not part of data structure.

640aAD $pindt          s              8  0
640aAD $pfifo          s              8  0
417bA*----------------------------------------------------------------
417bA*  Name constants
417bA*
     D valid           c                   const('0123456789 ABCDEFGHI-
     D                                     JKLMNOPQRSTUVWXYZabc-
     D                                     defghijklmnopqrstuvw-
     D                                     xyz')
     *----------------------------------------------------------------
     *  Called program parameters
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
     D  $lwhdp                22     26
     D  $lrack                22     26
     *
     D  $lbld                 19     20
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
650aAD @crtrcv         c                   const('CRTRCVTRN')
     *----------------------------------------------------------------
     *  Called program parameters
     *
720aDD*$cvtdt          ds
720aDD* $cvdop                 1      8
720aDD* $cvdd6                 9     14  0
720aDD* $cvdd8                15     22  0
720aAD $cvtdt          ds
720aAD  $cvcmd                 1      8
720aAD  $cvprg                 9     18
720aAD  $cvd6i                19     24
720aAD  $cvd8i                25     32
720aAD  $cvd6o                33     38  0
720aAD  $cvd8o                39     46  0
720aAD  $cvsto                47     64
720aAD  $cvrtn                65     72
720aAD  $cverm                73    132
720aAD  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  erfld1                 1     20
     D  erfld2                21     40
     D  erflvl                41     42p 0
     D  erclvl                43     44p 0
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
     * Data structure
     *
     D opdata          ds
     D  opstyp                 1      1
     D  opwhdp                 2      6
     D  opum1                  7      8
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1
     D  opwum                 58     72
     D  opxdsc                73     73
     D  optend               117    117
     *----------------------------------------------------------------
     *  Program info data structure
     *
640aA /COPY *libl/qcopysrc,C#PGMINFDS
640aDD*               sds
640aDD* #prog            *proc
640aDD* #job                 244    253
640aDD* #user                254    263
640aDD* #jobn                264    269
640aDD* #jobdt               276    281  0
640aDD* #jobtm               282    287  0
650cA*----------------------------------------------------------------
650cA*  Prototypes
650cA*----------------------------------------------------------------
650cAD calcpti         pr                  extpgm('CALCPTI')
650cA * Input
650cAD   pGTIN                             like($lgtin)
650cAD   pLOT                              like(pplot)
650cAD   pPackDate                         like($lbcProdD)
650cAD   pPTI                              like(pppti)
650cAD ucilic#         pr                  extpgm('UCILIC#')
650cA * Input
650cAD   unext                       13  0 const
650cAD   uwhse                        3  0 const
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
     *  Variables
     *
650cAD $lgtin          s             14
650cAD $lbcProdD       s              6  0
650cAD $lbclot         s             20
     D $msgf           s             10
650dAD $pw1pti         s              4  0
650aAD $rtnord         s              9
650cAD $unext          s             13  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
640aAD ck4err          s              1
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
640aDD*error           s              1
640aMD error           s               n
650bAD gs1seqqty       s              5  0
     D help            s              5  0
650bAD j               s              2  0
650cAd k               s                   like($lnrcvqty)
640aAD kytrn#          s                   like(lbtrn#)
     D msgk            s              4  0
     D nxtscr          s              3
     D ocode           s              8
     D posrec          s              4  0
650cAd pplot           s             20
650cAd pppti           s              4  0
     D reccnt          s              4  0
     D recno           s              4  0
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
720aAD today           s              8  0
650cAD unexta          s             13
     D uxflag          s              1
     D warn            s              1
640aAD zmflag          s               n
640aAD zmsflag         s               n
640aAD #rcvarea        s              6
640aAD #rcvitem        s                   like($ititem)
640aAD #rcvtype        s                   like($ittype)
640aAD #rcvdesc        s                   like($itdesc)
640aAD #rcvpdsc        s                   like($itpdsc)
640aAD #rcvwhdp        s                   like($itwhdp)
640aAD #rcvstyp        s                   like($itstyp)
640aAD #rcvdesg        s                   like($itdesg)
640aAD #rcvum1         s                   like($itum1)
640aAD #rcvflg1        s                   like($itflg1)
640aAD #rcvum2         s                   like($itum2)
640aAD #rcvumq2        s                   like($itumq2)
640aAD #rcvflg2        s                   like($itflg2)
640aAD #rcvum3         s                   like($itum3)
640aAD #rcvumq3        s                   like($itumq3)
640aAD #rcvdday        s                   like($imdday)
640aAD #rcvmday        s                   like($immday)
640aAD #rcvmflg        s                   like($immflg)
640aAD #rcvuday        s                   like($imuday)
640aAD #rcvnrpk        s                   like($imnrpk)
640aAD #rcvflgd        s                   like($itflgd)
640aAD #rcvcube        s                   like($itcube)
640aAD #rcvswgt        s                   like($itswgt)
640aAD #rcvupc         s                   like($itupc)

640aAD #slotitem       s                   like($ititem)
640aAD #slottype       s                   like($ittype)
640aAD #rcvcwgt        s                   like($itcwgt)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CHANGE  - Update licnese #.
     *              *VIEW    - View only
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Unchanged.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
223 D*                    PARM           $PUM1   5
223 D*                    PARM           $PUM2   5
223 D*                    PARM           $PUM3   5
     C                   parm                    $pord             7 0
640aAC                   parm                    $plbl#            7 0
640aAC                   parm                    $pcwgt            9 2
640aAC                   parm                    $pexpd            8 0
640aMC                   parm                    $pindt
640aAC                   parm                    $pfifo
640aAC                   parm                    $pdecvalue       15
640aAC                   parm                    $pmfexpd          8 0
640aAC                   parm                    $pmfgdt           8 0
650aAC                   parm                    $lsavetrn         7 0
650bAC                   parm                    $lcns            15
650bAC                   parm                    $plotc           30
650cAC                   parm                    $lgtin
650cAC                   parm                    $lbcProdD
650cAC                   parm                    $lbclot
650dAC                   parm                    $pw1pti
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   select
     *
     *R         NXTSCR    WHEQ '01 '
     *R                   EXFMTSCREEN1
     *
     *R         NXTSCR    WHEQ '02 '
     *R                   EXFMTSCREEN2
     *
     *R         NXTSCR    WHEQ '03 '
     C                   when      nxtscr = '01 '
     C                   exsr      sfldsp
650bAc                   if        $lcns = ' ' or
650bAc                             error = *on
     C                   read      head1                                  50
650bAc                   endif
     *
     C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
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
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   endif
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft3
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget3
     C                   exsr      zzfil3
     C                   endif
     C     end03i        endsr
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
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   if        $pcmd = '*ADD    '
     C                   eval      nxtscr = '01 '
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     redspl        cabeq     *on           endsc1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   if        $pcmd = '*ADD    '
     C                   eval      nxtscr = '01 '
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     redspl        cabeq     *on           endsc2
     C     error         cabeq     *on           endsc2
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr03i
     C                   endif
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   if        $pcmd = '*ADD    '
     C                   eval      nxtscr = '01 '
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     redspl        cabeq     *on           endsc3
     C     error         cabeq     *on           endsc3
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc3        endsr
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
     *  Initialize subfile values
     *
     *                    Z-ADD1         RECNO
     *                    WRITEDETAIL1                79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   add       1             reccnt
     C                   eval      recno = reccnt
     C                   write     detail1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      recno = 0
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     C                   write     head1
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     **                   WRITEOPTREC
     C                   write     cmdrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     **                   WRITEPOSTNREC
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   if        reccnt > 0
     C                   eval      *in81 = *on
     C                   endif
     C                   eval      recno = posrec
     C                   write     head1
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
     C                   write     clrscr
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
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
640aA*----------------------------------------------------------------
640aA*    DRI0001  Local system caused error
640aA*----------------------------------------------------------------
640aA
640aAC     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr

640aA*----------------------------------------------------------------
640aA*    DRI0001s Local system caused error (send to different program)
640aA*----------------------------------------------------------------
640aA
640aAC     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
640aA*----------------------------------------------------------------
640aA*      0105s
640aA*
640aAC     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20033  License # required.
     *
     C     zm033         begsr
     C                   eval      #msgid = 'PO20033'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO20034  License already exists.
     *
     C     zm034         begsr
     C                   eval      #msgid = 'PO20034'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7871  Error in writing a record.
     *
     C     zm7871        begsr
     C                   eval      #msgid = 'PIR7871'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7872  Error in updating a record.
     *
     C     zm7872        begsr
     C                   eval      #msgid = 'PIR7872'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
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
     *     PIR7973  Slot record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
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
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0113  Field 1 must be greater than or equal to field 2.
     *
     C     zm0113        begsr
     C                   eval      #msgid = 'PIR0113'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT11021  Invalid item type entered.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'IT11021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
650aAc                   exsr      zzrcvrtncheck
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     C                   endif
     *
     C                   eval      error = *off
     *
     *
     *   Verify changed subfile records.
     *
     C                   if        reccnt > 0
     C                   eval      posrec = 0
     C                   eval      *in79 = *off
     C                   dou       *in79
     C                   readc     detail1                                79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      *in13 = *off
     C                   eval      *in33 = *off
     *
     *  License # must be entered.
     *
416 D**         W1LCNS    IFEQ 0
416 MC                   if        w1lcns = *blanks
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm033
     C                   endif
     *
416 A*  Left justify license.
416 AC                   eval      $cstr = *blanks
416 AC                   move      w1lcns        $cstr
416 AC                   call      'ADJUST'
417 D*R                   PARM '*LEFT   '$CCMD   8
417 MC                   parm      '*LEFTNOZ'    $ccmd             8
416 AC                   parm                    $cstr            30
416 AC                   movel     $cstr         w1lcns
     *
417bAC                   eval      *in81 = *off
417bAC     valid         check     w1lcns                                 81
417bA*
417bA*  *IN81 = *ON - One of the positions did not have valid value
417bA*
417bAC                   if        *in81
417bAC                   eval      error = *on
417bAC                   eval      *in33 = *on
417bAC                   eval      *in13 = *on
417bAC                   eval      errmsg = desc(9)
417bAC                   exsr      zm1001
417bAC                   endif
     *
     *  License # must be unique.
     *
     C     lcnsky        setll     license                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   exsr      zm034
     C                   endif
     *
222 AC                   eval      *in85 = *on
     C                   update    detail1
     C                   if        posrec = 0
     C                   if        *in33
     C                   eval      posrec = recno
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   if        posrec = 0
     C                   eval      posrec = 1
     C                   endif
     *
     C                   endif
     *
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 1 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
650aAc                   exsr      zzrcvrtncheck
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
650aAc                   exsr      zzrcvrtncheck
     *
     C     endck3        endsr
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
     *
     *
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
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
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
     *
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 1.
     *
     C     zzcmd3        begsr
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
     *
     *     Build code.
     *
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm3
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   exsr      sflclr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT3   Get default values for add.
     *
     C     zzdft3        begsr
     *
     C                   exsr      sflclr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Move PO
     *
     C                   move      $ppo          w1ord
     *
     *   Move qtys
     *
     C                   eval      w1qrc1 = $prq1
     C                   eval      w1qrc2 = $prq2
     C                   eval      w1qrc3 = $prq3
223 D*R                   MOVE $PUM1     W1UM1
223 D*R                   MOVE $PUM2     W1UM2
223 D*R                   MOVE $PUM3     W1UM3
640aMC*                  move      #rcvum1       w1um1
640aMC*                  move      #rcvum2       w1um2
640aMC*                  move      #rcvum3       w1um3
     *
     C                   exsr      sflclr
     C     partk2        setll     label2
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     partk2        reade     label2                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   eval      w1qty = lbqalc
     C                   eval      w1tie = lbtie
     C                   eval      w1hi = lbhigh
     C                   eval      w1trn# = lbtrn#
411 AC                   eval      w1disp = lbdisp
416 D**                   Z-ADD0         W1LCNS
650bAC                   if        $lcns <> ' '
650bAc                   eval      w1lcns = $lcns
650bAc                   else
416 MC                   eval      w1lcns = *blanks
650bAc                   endif
     C                   exsr      sfladd
     C                   endif
     C                   enddo
     C                   eval      posrec = 1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get record(s) for screen 3.
     *
     C     zzget3        begsr
     C     endgt3        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for LICENSE file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1lcns
     *
     *  Define partial key for item LABEL file.
     *
     C     partk2        klist
     C                   kfld                    $pord
     C                   kfld                    $pwhse
640aD**
640aD** Define key for PIRITEM file.
640aD**
640aDC*    itkey         klist
640aDC*                  kfld                    $pwhse
640aDC*                  kfld                    $pitem
     *
     *  Define key for LICENSE file.
     *
     C     lcnsky        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1lcns
640aA*
640aA*  Define key for LICENSE1 file.
640aA*
640aAC     lcnsky1       klist
640aAC                   kfld                    $pwhse
640aAC                   kfld                    kytrn#
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ocode
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Set indicator for subfile change(SFLNXTCHG)
     C                   eval      *in85 = *on
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Move PO
     *
     C                   move      $ppo          w1ord
     *
     *   Get item description.
     *
     C                   exsr      zzxopt
     *
     C                   eval      woitem = *blanks
     C                   eval      wodsc1 = *blanks
     C                   eval      wodsc2 = *blanks
640aDC*    itkey         chain     piritem                            79
640aDC*                  if        *in79
640aDC*                  eval      itdesc = *blanks
640aDC*                  eval      itpdsc = *blanks
640aDC*                  goto      enditm
640aDC*                  endif
640aA
640aA*  Use DRI interface to get item.
640aA
640aAC                   exsr      clr$item
640aAC                   eval      $itwhse  = $pwhse
640aAC                   eval      $ititem  = $pitem
640aA
640aAC                   eval      $dricommand = '*ITEM'
640aAC                   eval      $drisubcmd  = '%GETALL'
640aAC                   eval      $drisys2upd = 'D'
640aAC                   eval      ck4err = *on
640aAC                   exsr      zzzdricop
640aAC                   if        error
640aAC                   clear                   #rcvitem
640aAC                   clear                   #rcvtype
640aAC                   clear                   #rcvdesc
640aAC                   clear                   #rcvpdsc
640aAC                   clear                   #rcvwhdp
640aAC                   clear                   #rcvstyp
640aAC                   clear                   #rcvdesg
640aAC                   clear                   #rcvum1
640aAC                   clear                   #rcvflg1
640aAC                   clear                   #rcvum2
640aAC                   clear                   #rcvumq2
640aAC                   clear                   #rcvflg2
640aAC                   clear                   #rcvum3
640aAC                   clear                   #rcvumq3
640aAC                   clear                   #rcvnrpk
640aAC                   clear                   #rcvmflg
640aAC                   clear                   #rcvdday
640aAC                   clear                   #rcvmday
640aAC                   clear                   #rcvuday
640aAC                   clear                   #rcvflgd
640aAC                   clear                   #rcvcube
640aAC                   clear                   #rcvswgt
640aAC                   clear                   #slotitem
640aAC                   clear                   #slottype
640aAC                   clear                   #rcvcwgt
640aAC                   goto      enditm
640aAC                   endif
640aA
640aAC                   eval      #rcvitem = $ititem
640aAC                   eval      #rcvtype = $ittype
640aAC                   eval      #rcvdesc = $itdesc
640aAC                   eval      #rcvpdsc = $itpdsc
640aAC                   eval      #rcvwhdp = $itwhdp
640aAC                   eval      #rcvstyp = $itstyp
640aAC                   eval      #rcvdesg = $itdesg
640aAC                   eval      #rcvum1  = $itum1
640aAC                   eval      #rcvflg1 = $itflg1
640aAC                   eval      #rcvum2  = $itum2
640aAC                   eval      #rcvumq2 = $itumq2
640aAC                   eval      #rcvflg2 = $itflg2
640aAC                   eval      #rcvum3  = $itum3
640aAC                   eval      #rcvumq3 = $itumq3
640aAC                   eval      #rcvnrpk = $imnrpk
640aAC                   eval      #rcvmflg = $immflg
640aAC                   eval      #rcvdday = $imdday
640aAC                   eval      #rcvmday = $immday
640aAC                   eval      #rcvuday = $imuday
640aAC                   eval      #rcvflgd = $itflgd
640aAC                   eval      #rcvcube = $itcube
640aAC                   eval      #rcvswgt = $itswgt
640aAC                   eval      #rcvcwgt = $itcwgt

     C                   if        uxflag = '0'
     C                   eval      $iitem = $pitem
640aDC*                  eval      $idesc = itdesc
640aDC*                  eval      $ipdsc = itpdsc
640aMC                   eval      $idesc = #rcvdesc
640aMC                   eval      $ipdsc = #rcvpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         woitem
     C                   else
     C                   movel     $pitem        woitem
640aDC*    itkey         chain     itemdsc                            79
640aDC*                  if        not *in79
640aDC*                  eval      wodsc1 = ixdsc1
640aDC*                  eval      wodsc2 = ixdsc2
640aMC                   eval      wodsc1 = $ixdsc1
640aMC                   eval      wodsc2 = $ixdsc2
640aDC*                  endif
     C                   endif
     *
     C     enditm        tag
640aA*
640aA*    Get User's employee number to be written to PORCV file
640aA*    if any records are flagged as touched.
640aA*
640aAC                   call      'GETUSER'
640aAC                   parm      #curruser     $code            10
640aAC                   parm      0             $whse             3 0
640aAC                   parm      0             $emp#             5 0
640aAC                   parm      *blanks       $fnam            15
640aAC                   parm      *blanks       $init             1
640aAC                   parm      *blanks       $lnam            20
640aAC                   parm      *blanks       $whdp             5
640aAC                   parm      *blanks       $styp             1
640aAC                   parm      *blanks       $shft             6
640aAC                   parm      *blanks       $crew             6
640aAC                   parm      0             $nhrs             3 1
640aAC                   parm      *blanks       $rtn              8
720aA*
720aA*  Convert today's date into century format.
720aA*
720aAC                   eval      $cvcmd = '*CURCMD '
720aAC                   call      @cvtdt
720aAC                   parm                    $cvtdt
720aAC                   eval      today = $cvd8o
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
640aA
640aA*----------------------------------------------------------------
640aA*  ZZLICINFO   Update licinfo
640aA*----------------------------------------------------------------
640aA
640aAC     zzlicinfo     begsr

     *  Write out standard license information.

     C                   exsr      clr$licinfo

     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr  = #jobnbr

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
     C                   eval      $lnlcns  = w1lcns

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*ITEM'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'A'
     C                   eval      $lnvalchr(1) = $pitem
     C                   eval      $lnvalnum(1) = 0


     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*RCVTRN#'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = W1trn#


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
     C                   if        error
     C                   endif

     *  Write out more standard and optional license information.

     C                   exsr      clr$licinfo

     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr  = #jobnbr

     C                   eval      $lnwhse  = $pwhse
     C                   eval      $lntype  = 'P'
     C                   eval      $lnlcns  = w1lcns

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*RCVLBL#'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'N'
     C                   eval      $lnvalchr(1) = ' '
     C                   eval      $lnvalnum(1) = lblbl#

     C                   if        $pexpd > 0
     C                   eval      $lncodeu(2) = *on
     C                   eval      $lncode(2) = '*EXPDTE'
     C                   eval      $lncseq(2) = 1
     C                   eval      $lnvaltyp(2) = 'N'
     C                   eval      $lnvalchr(2) = ' '
     C                   eval      $lnvalnum(2) = $pexpd
     C                   endif

     C                   if        $pindt > 0
     C                   eval      $lncodeu(3) = *on
     C                   eval      $lncode(3) = '*DATEIN '
     C                   eval      $lncseq(3) = 1
     C                   eval      $lnvaltyp(3) = 'N'
     C                   eval      $lnvalchr(3) = ' '
     c                   eval      $lnvalnum(3) = $pindt
     C                   endif

     C                   if        $pfifo > 0
     C                   eval      $lncodeu(4) = *on
     C                   eval      $lncode(4) = '*FIFODTE'
     C                   eval      $lncseq(4) = 1
     C                   eval      $lnvaltyp(4) = 'N'
     C                   eval      $lnvalchr(4) = ' '
     C                   eval      $lnvalnum(4) = $pfifo
     C                   endif

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
     C                   if        error
     C                   endif

640aA*  Write out Mfg standard and optional license information.

640aAC                   exsr      clr$licinfo
640aA
640aAC                   eval      $lnpgm  = #pgm
640aAC                   eval      $lnjob  = #job
640aAC                   eval      $lnjobnbr  = #jobnbr

640aAC                   eval      $lnwhse  = $pwhse
640aAC                   eval      $lntype  = 'P'
640aAC                   eval      $lnlcns  = w1lcns

640aAC                   if        $pdecvalue > ' '
640aAC                   eval      $lncodeu(1) = *on
640aAC                   eval      $lncode(1) = '*MFGDCOD'
640aAC                   eval      $lncseq(1) = 1
640aAC                   eval      $lnvaltyp(1) = 'A'
640aAC                   eval      $lnvalchr(1) = %trim($pdecvalue)
640aAC                   eval      $lnvalnum(1) = 0

640aAC                   if        $pmfexpd > 0
640aAC                   eval      $lncodeu(2) = *on
640aAC                   eval      $lncode(2) = '*MFGEXP'
640aAC                   eval      $lncseq(2) = 1
640aAC                   eval      $lnvaltyp(2) = 'N'
640aAC                   eval      $lnvalchr(2) = ' '
640aAC                   eval      $lnvalnum(2) = $pmfexpd
640aAC                   endif

640aAC                   eval      $lncodeu(3) = *on
640aAC                   eval      $lncode(3) = '*MFGDTE'
640aAC                   eval      $lncseq(3) = 1
640aAC                   eval      $lnvaltyp(3) = 'N'
640aAC                   eval      $lnvalchr(3) = ' '
640aAC                   eval      $lnvalnum(3) = $pmfgdt
     c                   else
640aAC                   if        $pmfexpd > 0
640aAC                   eval      $lncodeu(1) = *on
640aAC                   eval      $lncode(1) = '*MFGEXP'
640aAC                   eval      $lncseq(1) = 1
640aAC                   eval      $lnvaltyp(1) = 'N'
640aAC                   eval      $lnvalchr(1) = ' '
640aAC                   eval      $lnvalnum(1) = $pmfexpd
640aAC                   endif

640aAC                   eval      $lncodeu(2) = *on
640aAC                   eval      $lncode(2) = '*MFGDTE'
640aAC                   eval      $lncseq(2) = 1
640aAC                   eval      $lnvaltyp(2) = 'N'
640aAC                   eval      $lnvalchr(2) = ' '
640aAC                   eval      $lnvalnum(2) = $pmfgdt
640aAC                   endif

640aAC                   eval      $dricommand = '*LICINFO'
640aAC                   eval      $drisubcmd  = '%ADD'
640aAC                   eval      $drisys2upd = 'D'
640aAC                   eval      ck4err = *on
640aAC                   exsr      zzzdricop
640aAC                   if        error
640aAC                   endif
640aAC                   endsr
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZRCVRTNCHECK check for started RCVRTN Transaction
650aA*
650aAC     zzrcvrtncheck begsr
650aA*
650aA*  See if RCVRTN transaction is status 2 - start new if needed
650aA*
650aAc                   move      w1ord         $rtnord
650aAC                   call      @crtrcv
650aAC                   parm      '*RETURN'     $lcmdr           10
650aAC                   parm      '*CHECK '     $lsubcmd         10
650aAC                   parm      $itwhse       @lwhse            3 0
650aAC                   parm      0             $lpcs             5 0
650aAC                   parm      0             $lpallets         5 0
650aAC                   parm                    $lsavetrn         7 0
650aAC                   parm                    $rtnord           9
650aAC                   parm      $itstyp       $litstyp          1
650aAC                   parm      $itwhdp       $litwhdp          5
650aAC                   parm                    $lrtnr           10
650aAC                   endsr
650bA*----------------------------------------------------------------
650bA*  ZZLICINFONew Update New format of LICINFO
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA   begsr zzlicinfonew;

650bA     // first I need to deal with the Use label and NO stock
650bA     if $lcns <> ' ';
650bA       if $ppo = '*NOSTOCK';
650bA         exsr zznstemplcns;
650bA       else;
650bA         //exsr zzultemplcns;
650bA       endif;
650bA     endif;
650bA     // Write out standard license information
650bA     exsr clr$licinfo;
650bA     $lnwhse  = $pwhse;
650bA     $lnlcns  = w1lcns;
650bA     $lnseq = 1;

650bA     // $LCNS    SHOULD BE POPULATED IF CALL FROM THE UCI/GSI RECEIVING
650bA     // Need to get existing record so we don't overlay lnseqqty
650bA     select;
650bA       when $lcns <> ' ';
650bA         $dricommand = '*LICINFO';
650bA         $drisubcmd  = '%GET';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         exsr zzzdricop;
650bA         if error;
650bA           gs1seqqty = 0;
650bA         else;
650bA           gs1seqqty = $lnseqqty;
650bA         endif;
650bA         if $ifucicde = ' ' or $ifucicde = '1';
650bA           $lnseqqty = w1qty;
650bA         else;
650bA           $lnseqqty = gs1seqqty;
650bA         endif;
650bA         $lnrcvtrn# = w1trn#;
650bA         $lnrcvlbl# = lblbl#;
650bA         $lnrcvqty = w1qty;
650bA         $lnttllbs = $pcwgt;
650bA         $lnavglbs = $pcwgt / $lnrcvqty;
650bA       other;

650bA         exsr clr$licinfo;
650bA         $lnwhse  = $pwhse;
650bA         $lnlcns  = w1lcns;
650bA
650bA         $lnseq = 1;
650bA         $lnpo = ' ';
650bA         $lnposeq = 0;
650bA         if $ifucicde = ' ' or $ifucicde = '1';
650bA           $lnseqqty = w1qty;
650bA         else;
650bA           $lnseqqty = w1qty;
650bA         endif;
650bA         $lnitem = $pitem;
650bA         // LNRCVTYP notes
650bA         // 1 = Manual quantity (original method)
650bA         // 2 = Manual quantity with initial GS1 scan
650bA         // 3 = UCI using Mfg GS1 barcodes
650bA         // 4 = UCI using Internal GS1 barcodes (start with 99)
650bA         // 5 = ASN file

650bA         select;
650bA           //when $plpn <> ' ';
650bA             //$lnrcvtyp = '5';
650bA           when $ifucicde = ' ';
650bA             $lnrcvtyp = '1';
650bA           when $ifucicde = '1';
650bA             $lnrcvtyp = '1';
650bA           when $ifucicde = '2';
650bA             $lnrcvtyp = '3';
650bA           when $ifucicde = '3';
650bA             $lnrcvtyp = '4';
650bA           // don't know exactly what 2 will represent
650bA         endsl;
650bA         $lnrcvtrn# = w1trn#;
650bA         $lnrcvlbl# = lblbl#;
650bA         $lnrcvqty = w1qty;

650bA         if $pindt > 0;
650bA           $lnentdate = $pindt;
650bA         else;
650bA           $lnentdate = 0;
650bA         endif;

650bA         if $pfifo > 0;
650bA           $lnenttype = '*FIFODT';
650bA         else;
650bA           if #rcvflgd = 'Y';
650bA             select;
650bA               when #rcvuday > 0 or
650bA                    #rcvdday > 0;
650bA                 if #rcvmflg = 'Y';
650bA                   $lnenttype = '*MFGDTE';
650bA                 else;
650bA                   $lnenttype = '*USEDTE';
650bA                 endif;
650bA               other;
650bA                 $lnenttype = '*EXPDTE';
650bA             endsl;
650bA           else;
650bA             $lnenttype = '*ENTDTE';
650bA           endif;

650bA           $lndateflag = #rcvflgd;
650bA           $lnmfgflag = #rcvmflg;

650bA           $lnmfgdays = #rcvmday;
650bA           $lnusrdays = #rcvuday;
650bA           $lndstdays = #rcvdday;
650bA         endif;

650bA         $lnmfgdate = $pmfgdt;

650bA         if $pmfexpd > 0;
650bA           $lnmfgexp = $pmfexpd;
650bA         else;
650bA           $lnmfgexp = 0;
650bA         endif;

650bA         if $pfifo > 0;
650bA           $lnfifodate = $pfifo;
650bA         else;
650bA           $lnfifodate = 0;
650bA         endif;

650bA         if $pexpd > 0;
650bA           $lnexpdate = $pexpd;
650bA         else;
650bA           $lnexpdate = 0;
650bA         endif;

650bA         if $pdecvalue > ' ';
650bA           $lnmfgcode = $pdecvalue;
650bA         endif;

650bA         $lnttllbs = $pcwgt;
650bA         $lnavglbs = $pcwgt / $lnrcvqty;

650bA         if $plotc <> ' ';
650bA           $lnlot = $plotc;
650bA         endif;

650bA          // Clam and Shucked information.
650bA           //if $pcode = Clams
650bA              //or $pcode = Shucked;

650bA          //if $phdte > 0;
650bA         $lnhrvdate = 0;
650bA          //endif;

650bA          //if $phloc <> ' ';
650bA            //$lnhrvloc = $phloc;
650bA          //endif;

650bA          //if $pcert <> ' ';
650bA            //$lnhrvcert = $pcert;
650bA          //endif;
650bA        //endif;
650bA     endsl;

650cA       // calculate the PTI if adding.
650cA       if $lbclot <> ' ' and $lgtin <> ' ';
650cA         pplot  = %subst($lbclot: 1 : 20);
650dA         if $pw1pti = 0;
650cA           calcpti ($lgtin: pplot: $lbcProdD: pppti);
650dA         else;
650dA           pppti = $pw1pti;
650dA         endif;
650cA         if pppti > 0;
650cA           $lnlotPTI4 = %editc(pppti:'X');
650cA           $lnlotPTI2 = %Subst(%EditC(pppti:'X'):3:2);
650cA           // create detail pti records in UCIINFO for use at selection
650cA           // when item is not UCI receiving method
650cA           k = 0;
650dD           //if $ifrcvmth <> '2';
650dM           if $ifrcvmth <> '2' and $ppo <> '*NOSTOCK';
650cA             dou k = $lnrcvqty;
650cA               k = k + 1;
650cA               exsr clr$uciinfo;
650cA               $uiWhse = $pwhse;
650cA               $uiItem = $pitem;
650cA               $uiuci = %trim(%editc(pppti:'X'));
650cA               ucilic#($unext: $pwhse);
650cA               unexta = %editc($unext:'X');
650cA               $uiuciLcns = 'P:' + unexta;
650cA               $uiLcns = $lnlcns;
650cA               $uiseq = 1;
650cA               $uiSerial = ' ';
650cA               // weight is calculated as average
650cA               $uiwgtlbs = $lnavglbs;
650cA               $uiSelTrn# = 0;
650cA               $uiSelLbl# = 0;
650cA               $uiSelOrd = 0;
650cA               $uiSelSeq = 0;
650cA               $uiSelCSeq = 0;
650cA               $uiSelTrax = ' ';
650cA               $uiCrtBy = '2';
720aA               $uiaUTyp  = 'N';
720aA               $uiaSlUTyp = 'N';
720aA               if $lgtin = *blanks;
720aA                  $uiaGtin = 0;
720aA               else;
720aA                  $uiaGtin  = %DEC($lgtin:14:0);
720aA               endif;
720aA               $uiaLot   = $lbclot;
720aA               $uiaExpD  = $lnexpdate;
720aA               $uiaEntD  = today;

650cA               $dricommand = '*UCIINFO';
650cA               $drisubcmd  = '%ADD';
650cA               $drisys2upd = 'D';
650cA               ck4err = *on;
650cA               zmflag  = *off;
650cA               exsr zzzdricop;
650cA             enddo;
650cA           endif;
650cA         endif;
650cA       endif;

650bA     $dricommand = '*LICINFO';
650bA     // $PGSLCNS SHOULD BE POPULATED IF CALL FROM THE UCI/GSI RECEIVING
650bA     if $lcns = ' ';
650bA       $drisubcmd  = '%ADDS';
650bA     else;
650bA       $drisubcmd  = '%CHANGES';
650bA     endif;
650bA     $drisys2upd = 'D';
650bA     ck4err = *on;
650bA     exsr zzzdricop;
650bA     if error;
650bA     endif;

650bA   endsr;
650bA /end-free
     *----------------------------------------------------------------
     *
     *  ZZUSUB   Update using subfile records.
     *
     C     zzusub        begsr
     C                   eval      error = *off
     *
     *   Loop through changed subfile records and add/update file.
     *
     *
     C                   eval      *in77 = *off
     C                   dou       *in77
     C                   readc     detail1                                77
     C                   if        *in77
     C                   leave
     C                   endif
640aA*
640aA*     Ignore subfile records without a qty.
640aA*
640aAC                   if        w1qty <= 0
640aAC                   iter
640aAC                   endif
640aA
     ******** do I need this *******
640aAC                   call      'PIRLBL#'
640aAC                   parm                    newlbl#           7 0
640aA
640aA*  Create license
640aA *
640aAC*                  exsr      zzurcvSlot
640aA *
     *
     *     Get detail record.
     *
640aDC*    fileky        chain     record2                            7978
640aAC                   eval      kytrn# = w1trn#
640aMC     lcnsky1       chain     license1                           7978
     *
     *     Record locked. Tell user to try again.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
     C                   update    detail1
     C                   eval      errmsg = desc(4)
     C                   exsr      zm7872
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     *
     *     Initialize record fields before trying to add or update.
     *
     C                   eval      liwhse = $pwhse
416 D**                   Z-ADDW1LCNS    LILCNS
640aDC*****lynndelete    eval      lilcns = w1lcns
     C                   eval      litrn# = w1trn#
640aA
640aA*    Update licinfo.
640aA
650bDC*                  exsr      zzlicinfo
650bMC                   exsr      zzlicinfonew
640aA*
640aA*     Update license number
640aA*
640aAC                   exsr      clr$license
640aAC                   eval      $liToLcnsU = *on
640aAC                   eval      $liToLcns = w1lcns
640aAC                   eval      $liOLcnsU = *on
640aAC                   eval      $liOLcns = w1lcns
640aAC                   eval      $liFrmOldLcnsU = *on
640aAC                   eval      $liFrmOldLcns = lilcns
640aAC                   eval      $liActionU = *on
640aAC                   eval      $liAction = 'DPT'
640aAC                   eval      $liActionU = *on
640aAC                   eval      $liAction = 'DPT'
640aAC                   eval      $liLbl#U = *on
640aAC                   eval      $liLbl# = LBLBL#
640aAC                   eval      $liTrn#U = *on
640aAC                   eval      $liTrn# = w1trn#
640aAC                   eval      $liETrn#U = *on
640aAC                   eval      $liETrn# = 0

640aAC                   eval      $dricommand = '*LICENSE'
640aAC                   eval      $drisubcmd  = '%CHGDP'
640aAC                   eval      $drisys2upd = 'D'
640aAC                   eval      ck4err = *off
640aAC                   exsr      zzzdricop
640aAC                   if        error
640aAC                   endif
     *
     *     Record not found. Try adding record.
     *
     C                   if        *in79
640aDC*                  write     record2                              76
640aMC                   write     lirec1                               76
     C                   if        not *in76
     C                   iter
     C                   endif
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
     C                   update    detail1
     C                   eval      errmsg = desc(4)
     C                   exsr      zm7871
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     *
     *     Record found. Try updating record.
     *
640aDC*                  update    record2                              76
640aMC                   update    lirec1                               76
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
     C                   update    detail1
     C                   eval      errmsg = desc(4)
     C                   exsr      zm7872
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     *
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *
     *  Otherwise, update files and return.
     *
     *     Move screen fields to record fields.
     *
     *
     *  Update detail first.
     *
     C                   if        reccnt > 0
     C                   exsr      zzusub
     C     error         cabeq     *on           endup1
     C                   endif
     *
     *
     *      Move key values to parameters
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *      Move key values to parameters
     *
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     *
     *  If user is adding a detail record ...
     *    - add it to subfile and return to entry screen
     *    - do not update files
     *
     *R         W1ADDL    IFNE *BLANKS
     *R         W1ADDR    ORNE *BLANKS
     *R                   ADD  1         LSTSEQ
     *R                   Z-ADDLSTSEQ    W1SEQ
     *R                   MOVE W1ADDL    W1LEFT
     *R                   MOVE W1ADDR    W1RGHT
     *R                   MOVE *ON       *IN85
     *R                   EXSR SFLADD
     *R                   MOVE *BLANKS   W1ADDL
     *R                   MOVE *BLANKS   W1ADDR
     *R                   MOVE *ON       *IN17
     *R                   MOVE *ON       REDSPL
     *R                   GOTO ENDUP3
     *R                   ENDIF
     *
     *  Otherwise, update files and return.
     *
     *     Move screen fields to record fields.
     *
     *R                   CLEARRECORD
     *R                   Z-ADD$PWHSE    LHWHSE
     *R                   MOVE W1WHDP    LHWHDP
     *R                   CALL 'ADJUST'
     *R                   PARM '*RIGHT  '$TCMD
     *R                   PARM W1AISL    $TSTR
     *R                   MOVE $TSTR     LHAISL
     *R                   MOVE W1STYP    LHSTYP
     *R                   MOVE W1BLD     LHBLD
     *R                   Z-ADDW1SNUM    LHSNUM
     *R                   MOVE W1STRT    LHSTRT
     *
     *  Update detail first.
     *
     *R         RECCNT    IFGT 0
     *R                   EXSR ZZUSUB
     *R         ERROR     CABEQ*ON       ENDUP3
     *R                   ENDIF
     *
     *  Then header.
     *
     *      Add record
     *
     *R         $PCMD     IFEQ '*ADD    '
     *R                   WRITERECORD                 79
     *R         *IN79     IFEQ *ON
     *R                   MOVE *ON       ERROR
     *R                   EXSR ZM71
     *R                   GOTO ENDUP3
     *R                   END
     *R                   ELSE
     *
     *      -OR- Update record (it was read and locked in ZZGET2)
     *
     *R                   UPDATRECORD                 79
     *R         *IN79     IFEQ *ON
     *R                   MOVE *ON       ERROR
     *R                   EXSR ZM72
     *R                   GOTO ENDUP3
     *R                   END
     *R                   END
     *
     *      Move key values to parameters
     *
     C     endup3        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
     C                   eval      uxflag = *off
     C                   eval      ocode = '*ITEMMNT'
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   if        opxdsc = 'Y'
     C                   eval      uxflag = *on
     C                   endif
     C                   endif
     *
     C                   endsr
     *
650bA*----------------------------------------------------------------
650bA*  ZZNSTEMPLCNS Process NO stock temporary license
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA   begsr zznstemplcns;
650bA   // records that have a NS temporary license from gs1 scanning.
650bA   // These records are used to update the orginal uci that is returned
650bA   // Let's handle the uciinfo file first
650bA     dou $drireturn = '*DONE';
650bA       exsr clr$uciinfo;
650bA
650bA       $uiWhse = $pwhse;
650bA       $uilcns = $lcns;
650bA
650bA       $dricommand = '*UCIINFO';
650bA       $drisubcmd  = '%GET1UCI  ';
650bA       $drisys2upd = 'D';
650bA       ck4err = *on;
650bA       zmflag  = *off;
650bA       exsr zzzdricop;
650bA       if error;
650bA       endif;
650bA       if $drireturn <> '*DONE';

650bA         // Now get the original uci from selection to update with
650bA         // the return transaction number
650bA
650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%GET2RTN';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         else;

650bA         $uirtntrn#  = w1trn#;

650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%RETURN';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         endif;
650bA         endif;
650bA         // now delete the originals

650bA         $uilcns = $lcns;

650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%DELETE1';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         endif;
650bA       endif;
650bA     enddo;
650bA     // Now let's handle the replacement of the licinfo records

650bA     for j = 1 to 99;
650bA     exsr clr$licinfo;

650bA     // Get the temp license record
650bA     $lnwhse  = $pwhse;
650bA     $lnlcns  = $lcns;
650bA     $lnseq = j;

650bA     $dricommand = '*LICINFO';
650bA     $drisubcmd  = '%GET';
650bA     $drisys2upd = 'D';
650bA     ck4err = *on;
650bA     exsr zzzdricop;
650bA     if error;
650bA       leave;
650bA     endif;

650bA     //Replace with new license - this will actually write a new record
650bA     // With the data from the temporary record
650bA     $lnlcns  = $satolcns;

650bA     $dricommand = '*LICINFO';
650bA     $drisubcmd  = '%REPLACE';
650bA     $drisys2upd = 'D';
650bA     ck4err = *on;
650bA     exsr zzzdricop;
650bA     if error;
650bA     endif;

650bA   endfor;
650bA   // Now delete the temporary gs1/uci xdock
650bA   exsr clr$licinfo;
650bA   $lnwhse  = $pwhse;
650bA   $lnlcns  = $lcns;

650bA   $dricommand = '*LICINFO';
650bA   $drisubcmd  = '%DELETEALL';
650bA   $drisys2upd = 'D';
650bA   ck4err = *on;
650bA   exsr zzzdricop;
650bA   if error;
650bA   endif;

650bA   endsr;
650bA /end-free

650bA*----------------------------------------------------------------
650bA*----------------------------------------------------------------
650bA*  ZZULTEMPLCNS Replace licinfo & uciinfo temp lcns with *RT license
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA   begsr zzultemplcns;
650bA   // records that have a temporary license from gs1 scanning.
650bA   // will need to get the temp license record data, then replace the
650bA   // licinfo with the same data but real license.
650bA   // must loop to process all the licinfo seq#
650bA   // Let's handle the uciinfo file first
650bA      dou $drireturn = '*DONE';
650bA       exsr clr$uciinfo;
650bA
650bA       $uiWhse = $pwhse;
650bA       $uilcns = $lcns;
650bA
650bA       $dricommand = '*UCIINFO';
650bA       $drisubcmd  = '%GET1UCI  ';
650bA       $drisys2upd = 'D';
650bA       ck4err = *on;
650bA       zmflag  = *off;
650bA       exsr zzzdricop;
650bA       if error;
650bA       endif;
650bA       if $drireturn <> '*DONE';

650bA         // replace - which will add a new record
650bA         $uilcns = $satolcns;
720aA         $uialcns = $satolcns;

650bA         $dricommand = '*UCIINFO';
650bA         $drisubcmd  = '%REPLACE';
650bA         $drisys2upd = 'D';
650bA         ck4err = *on;
650bA         zmflag  = *off;
650bA         exsr zzzdricop;
650bA         if error;
650bA         endif;
650bA       // now delete the originals

650bA       $uilcns = $lcns;

650bA       $dricommand = '*UCIINFO';
650bA       $drisubcmd  = '%DELETE1';
650bA       $drisys2upd = 'D';
650bA       ck4err = *on;
650bA       zmflag  = *off;
650bA       exsr zzzdricop;
650bA       if error;
650bA       endif;
650bA       endif;
650bA     enddo;

650bA   // Now let's handle the replacement of the licinfo records

650bA   for j = 1 to 99;
650bA   exsr clr$licinfo;

650bA   // Get the temp license record
650bA   $lnwhse  = $pwhse;
650bA   $lnlcns  = $lcns;
650bA   $lnseq = j;

650bA   $dricommand = '*LICINFO';
650bA   $drisubcmd  = '%GET';
650bA   $drisys2upd = 'D';
650bA   ck4err = *on;
650bA   exsr zzzdricop;
650bA   if error;
650bA     leave;
650bA   endif;

650bA   // Replace with new license - this will actually write a new record
650bA   // With the data from the temporary record
650bA   $lnlcns  = $satolcns;

650bA   $dricommand = '*LICINFO';
650bA   $drisubcmd  = '%REPLACE';
650bA   $drisys2upd = 'D';
650bA   ck4err = *on;
650bA   exsr zzzdricop;
650bA   if error;
650bA   endif;

650bA   endfor;
650bA   // Now delete the temporary gs1/uci xdock
650bA   exsr clr$licinfo;
650bA   $lnwhse  = $pwhse;
650bA   $lnlcns  = $lcns;

650bA   $dricommand = '*LICINFO';
650bA   $drisubcmd  = '%DELETEALL';
650bA   $drisys2upd = 'D';
650bA   ck4err = *on;
650bA   exsr zzzdricop;
650bA   if error;
650bA   endif;

650bA   endsr;
650bA /end-free
640aA*----------------------------------------------------------------
640aA*----------------------------------------------------------------
640aA*                     DRI SUBROUTINES
640aA*----------------------------------------------------------------
640aA*----------------------------------------------------------------

640aA*----------------------------------------------------------------
640aA*  clr$item  Clear $item data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

640aA*----------------------------------------------------------------
640aA*  clr$license  Clear $license data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = $emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = $pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr

640aA*----------------------------------------------------------------
640aA*  clr$licinfo  Clear $licinfo data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
650cAC                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #curruser
     C                   eval      $lnemp# = $emp#
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

     C                   endsr

640aA*----------------------------------------------------------------
640aA*  clr$slot  Clear $slot data structure fields
640aA*----------------------------------------------------------------
640aA
640aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = $emp#
     C                   endsr
650bA*----------------------------------------------------------------
650bA*  clr$uciinfo  Clear $uciinfo data structure fields
650bA*----------------------------------------------------------------

650bAC     clr$uciinfo   begsr
650bAC                   eval      savever# = $uiver#
650bAC                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
650bAC                   eval      $uiver# = savever#
650bAC                   eval      $uiaddemp = $emp#
650bAC                   eval      $uiaddusr = #curruser
650bAC                   eval      $uiaddpgm  = #pgm
650bAC                   eval      $uiaddjob  = #job
650bAC                   eval      $uiaddnbr = #jobnbr
650bAC                   endsr


640aA*----------------------------------------------------------------
640aA*  zzzdricop  Call DRICOP
640aA*----------------------------------------------------------------
640aA
640aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
650bAC                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
650bAC                   when      $dricommand = '*UCIINFO'
650bAC                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
650bAC                             or $dricommand = '*LICINFO'
720aAC                             or $dricommand = '*UCIINFO'
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

     C                   when      %error and ck4err = *on
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm
     C                   select
     C                   when      zmsflag
     C                   exsr      zm0105s
     C                   when      zmflag
     C                   exsr      zm0105
     C                   endsl

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C                   exsr      zm0001s
     C                   when      zmflag
     C                   exsr      zm0001
     C*                  exsr      zzerrind
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
650bAC                   eval      $licinfo2 = $dridata2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
650bAC                   when      $dricommand = '*UCIINFO'
650bAC                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      ck4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Aisle
Start From
Starting Level
Detail record
Starting Number
Current Maximum Level
Future Maximum Level
Racks on One Side
license number
