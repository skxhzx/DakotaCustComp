     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IV214   Inventory sheet maint Catch weight entry
     *  05 June, 2006
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions
500 A*    06/05/06  RH   5.00
     *      - Created using IV213
500dA*    06/17/06  MLB  5.00d
     *      - Fix: Revised program to remove check for catchweight
     *        greater than zero.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  90        View moSe (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fiv214fm   cf   e             workstn
     F                                     infds(infds)
500a Finvscw    uf a e           k disk
     Finvslot4  if   e           k disk
500bAFitemmsc   if   e           k disk
     Foptions   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
500c D $qty            s             13    dim(15)
412 AD a2              s              1    dim(2)
412 AD a2n             s              1    dim(2)
     D a10             s              1    dim(10)
     D desc            s             20    dim(6) ctdata perrcd(1)
500 A*----------------------------------------------------------------
500 A*  DRI parameters
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#DRIPARMS
500 A
500 A*----------------------------------------------------------------
500 A*  Data Formats
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#ITEM
500 AD saveVer#        s                   like($itver#)
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
     D  $pwhdp                22     26
500cAD  $pdsp                 27     38
500cAD  $pitem                39     53
     D $pqty           ds
     *                                       1  13 $QTY
     D  oqt1                   1      7  0
     D  oqt2                   8     10  2
     D  oqt3                  11     13  0
     *----------------------------------------------------------------
     *QTY        DS
     *I            0                         1   70OQT1
     *I            0                         8  102OQT2
     *I            0                        11  130OQT3
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
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
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *   Redefine key
     D  $lwhse                19     21  0
     D  $litem                22     36
     *
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  ertcwt                 1      5p 2
     D  erlrng                 6     10p 2
     D  erhrng                11     15p 2
     D  errg1c                16     17p 1
     D  errg2c                18     19p 1
     D  erexwt                20     24p 2
     *
     D  ertcw#                 1      3p 0
     D  erqpck                 4      6p 0
     *
     D  erwhse                 1      2p 0
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  eritm                  1     15
     D  erco#                 16     19p 0
     *
     D  erdisp                16     27
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
     *  Variables
     *
500 AD #toititem       s                   like($ititem)
500 AD #toittype       s                   like($ittype)
500 AD #toitdesc       s                   like($itdesc)
500 AD #toitpdsc       s                   like($itpdsc)
500 AD #toithead       s             70
500 AD #toitwhdp       s                   like($itwhdp)
500 AD #toitstyp       s                   like($itstyp)
500 AD #toitdesg       s                   like($itdesg)
500 AD #toitum1        s                   like($itum1)
500 AD #toitflg1       s                   like($itflg1)
500 AD #toitum2        s                   like($itum2)
500 AD #toitumq2       s                   like($itumq2)
500 AD #toitflg2       s                   like($itflg2)
500 AD #toitum3        s                   like($itum3)
500 AD #toitumq3       s                   like($itumq3)
500 AD #toitnrpk       s                   like($imnrpk)
500 AD #toitflgd       s                   like($itflgd)
500 AD #toitcube       s                   like($itcube)
500 AD #toitswgt       s                   like($itswgt)
500 AD #toitcwgt       s                   like($itcwgt)
500 AD #toitmitem      s                   like($itmitem)
500 AD #toitsdef       s                   like($idsdef)
500 AD #toittie        s                   like($idtie)
500 AD #toithigh       s                   like($idhigh)

500 AD #tossbititem    s                   like($ititem)
500 AD #tossbittype    s                   like($ittype)
500 AD #tossbitdesc    s                   like($itdesc)
500 AD #tossbitpdsc    s                   like($itpdsc)
500 AD #tossbitwhdp    s                   like($itwhdp)
500 AD #tossbitstyp    s                   like($itstyp)
500 AD #tossbitdesg    s                   like($itdesg)
500 AD #tossbitum1     s                   like($itum1)
500 AD #tossbitum2     s                   like($itum2)
500 AD #tossbitumq2    s                   like($itumq2)
500 AD #tossbitum3     s                   like($itum3)
500 AD #tossbitumq3    s                   like($itumq3)
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
500 AD chk4err         s               n
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
500b D exwgt           s              9  2
500b D exwg2           s              7  2
500 AD forever         s               n
     D help            s              5  0
500b D hirng           s              9  2
500b D hivar           s              9  2
500b D hvskp           s              1
500b D ihrng           s              9  2
500b D ihvar           s              9  2
500b D ilrng           s              9  2
500b D ilvar           s              9  2
500b D lvskp           s              1
500b D lwrng           s              9  2
500b D lwvar           s              9  2
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
500b D prg1c           s              4  3
500b D prg2c           s              4  3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
500 AD ssbflg          s               n
500b D swgt2           s              7  2
     D today           s              8  0
     D warn            s              1
500b D wkcode          s              8
500b D wkwhse          s                   like($pwhse)
     D woqt01          s              5  0
     D woqt02          s              3  0
     D woqt03          s              3  0
500b D wtchk           s              1
500 AD zmsflag         s               n
     *----------------------------------------------------------------
500b I*  *SYSTEM  -  System options.
     I*
     I* Fields
     I*
     I*    OPEPM   -  Using EPM module (Y,N).
     I*    OPRF    -  Using RF module (Y,N).
     I*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     I*    OPLETD  -  Print letdown labels (Y,N).
     I*    OPWRNC  -  Perform catch weight variance check (Y,N).
     I*    OPRG1C  -  Catch weight low variance percentage.
     I*    OPRG2C  -  Catch weight high variance percentage.
     I*    OPIMPI  -  Import item fields from host.(Y,N).
     I*    OPICW   -  Individual catch weight entry (Y,N).
     *
     * Data structure
     *
500b D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
500b D  optend               117    117
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
500cAD  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
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
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
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
     C                   parm                    $pqty
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
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
     C     nxtscr        caseq     '02 '         sc2
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
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     *
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       10
     C                   setoff                                       111213
     C                   setoff                                       14
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333440
     C                   setoff                                       414243
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcpmq
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
     C*                  eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzget2
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
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys
     *
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
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *R                   EXSR SCR02I
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
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
     C                   eval      nxtscr = '01 '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys
     *
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
     C     error         cabeq     *on           endsc2
     C                   endif
     C                   eval      nxtscr = 'EOJ'
     C     endsc2        endsr
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
     *  Initialize message handling
     *
     C                   exsr      zmimsg
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
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
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
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   write     msgctl
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
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
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
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
500 A*----------------------------------------------------------------
500 A*    DRI0001  Local system caused error
500 A*----------------------------------------------------------------
500 A
500 AC     zm0001        begsr
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

500 A*----------------------------------------------------------------
500 A*    DRI0001s Local system caused error (send to different program)
500 A*----------------------------------------------------------------
500 A
500 AC     zm0001s       begsr
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
     *    ZM0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
500 A*----------------------------------------------------------------
500 A*      0105s
500 A*
500 AC     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM04     Slot record does not exist.
     *
     C     zm04          begsr
     C                   eval      #msgid = 'IT13204'
     C                   eval      #msgtp = '*DIAG  '
TESTD**                   MOVE W1SLOT    ERDISP
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IV21201  Quantity entered without item number.
     *
     C     zm1201        begsr
     C                   eval      #msgid = 'IV21201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
500aA*----------------------------------------------------------------
500aA*     IV21203  Pallet position required.
500aA*
500aAC     zm1203        begsr
500aAC                   eval      #msgid = 'IV21203'
500aAC                   eval      #msgtp = '*DIAG  '
500aAC                   movea     errmsg        $md(1)
500aAC                   exsr      zmpmsg
500aAC                   endsr
     *----------------------------------------------------------------
     *     IV21301  Quantity entered without item number.
     *
     C     zm1301        begsr
     C                   eval      #msgid = 'IV21301'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
412 A*     IV21302  Not a physical slot
     *
     C     zm1302        begsr
     C                   eval      #msgid = 'IV21302'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
500bA*     PT13021  Warning: Entered catch wt not within +/- range.
500bA*
500b C     zm21          begsr
500b C                   eval      #msgid = 'PT13021'
500b C                   eval      #msgtp = '*DIAG  '
500b C                   movea     errmsg        $md(1)
500b C                   exsr      zmpmsg
500b C                   endsr
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
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     ****                 EXSR ZMSMSG
     ****                 MOVE #MSGK     $PMSG
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     ****                 EXSR ZMSMSG
     ****                 MOVE #MSGK     $PMSG
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
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  When adding ....
     *
     C*                  if        $pcmd = '*ADD    '
     C*                  endif
     *
500bA*    Weight can't be zero.
     *
     C                   if        w1cwgt = 0
500dDC*                  eval      error = *on
500dDC*                  eval      *in09 = *on
500dDC*                  eval      *in29 = *on
500dDC*                  eval      errmsg = *blanks
500dDC*                  movel     desc(6)       errmsg
500dDC*                  exsr      zm0110
500dDC*                  goto      endck1
     C                   endif
     *   Calculate catch weight values for check.
     C                   exsr      zzcwgt
500c C                   z-add     0             taddw             7 2
500c C                   eval      taddw = w1cwgt
     *
     *   WTCHK, Flags are used to force F8 for each test
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
     C                   eval      error = *off
     * Set flag
     C                   if        wtchk = '2' and
     C                             ovrrid = *on
     C                   eval      wtchk = '1'
     C                   endif
     *  Verify catch weight.
     C                   if        wtchk <> '1'
     C                   eval      wtchk = '1'
     *
     C*     Check individual CW if variance check = Y.
     C                   if        opwrnc = 'Y'
    DC**                           opicw  = 'Y'
     C**                 z-add     w1cwgt        cwgt              7 0
     C**   cwgt          div       100           taddw             7 2
500b C*                  z-add     0             taddw             7 2
500b C*                  eval      taddw = cwgt
     C                   if        lvskp = *off and
     C                             taddw < lwrng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     taddw         ertcwt
     C                   z-add     lwrng         erlrng
     *
     C                   if        hvskp  = *on
     C                   z-add     0             erhrng
     C                   else
     C                   z-add     hirng         erhrng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   z-add     exwgt         erexwt
     C*                  z-add     lbuwgt        erexwt
     C                   exsr      zm21
     C                   endif
     *
     C                   if        hvskp  = *off and
     C                             taddw  > hirng
     C                   eval      error = *on
     C                   eval      warn  = *on
     C                   eval      wtchk = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     taddw         ertcwt
     C                   if        lvskp = *on
     C                   z-add     0             erlrng
     C                   else
     C                   z-add     lwrng         erlrng
     C                   endif
     C                   z-add     hirng         erhrng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   z-add     exwgt         erexwt
     C                   exsr      zm21
     C                   endif
     *
     C                   endif
     C                   endif
     *
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     C                   if        $pcmd = '*CHANGE '  or
     C                             $pcmd = '*ADD    '
     *
     C                   endif
     C     enderr        tag
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F8 -  Catch Weight Override
     *
     C                   if        *inkh
     C                   move      *on           ovrrid
     C*                  eval      cmdtkn = *on
     C                   goto      endcm1
     C                   else
     C                   move      *off          ovrrid
     C                   endif
     *
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C     endcm2        endsr
500bA*----------------------------------------------------------------
500bA*
500bA*  ZZCWGT   Calculate catch weight variance values.
500bA*
500bAC     zzcwgt        begsr
     *
     *  If verify catch weight = yes
     *   Calculate total expected catch weight,
     *   Calculate low/high ranges.
     C                   if        opwrnc = 'Y'
     C                   z-add     0             lwvar
     C                   z-add     0             hivar
     C                   z-add     0             lwrng
     C                   z-add     0             hirng
     C                   z-add     0             exwgt
     C                   z-add     0             exwg2
     C                   z-add     0             ilvar
     C                   z-add     0             ihvar
     C                   z-add     0             ilrng
     C                   z-add     0             ihrng
     C                   z-add     0             swgt2
     *   Calc extended wt.
500b C**   $slvlopickqty mult      $slvlouwgt    exwgt
     C     woqt01        mult      #toitswgt     exwgt
     *   Calc extended wt for each item.
     C                   if        #toitumq2 <> 0
     C     #toitswgt     div       #toitumq2     swgt2
     C     woqt02        mult      swgt2         exwg2
     C                   add       exwg2         exwgt
     C                   endif
     *   Iniz flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     *   Use item variance % if it exists.
     C     imkey         chain     itemmsc                            79
     C                   if        *in79 = *off
     C                   if        imrg1c <> 0
     C     imrg1c        div       100           prg1c
     C                   if        imrg1c = 99
     C                   eval      lvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        imrg2c <> 0
     C     imrg2c        div       100           prg2c
     C                   if        imrg2c = 99
     C                   eval      hvskp = *on
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C                   if        prg1c = 0
     C     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
     C     oprg2c        div       100           prg2c
     C                   endif
     *
     C                   if        prg1c > 0
     C     exwgt         mult      prg1c         lwvar
     C*    $slvlouwgt    mult      prg1c         ilvar
     C     #toitswgt     mult      prg1c         ilvar
     C                   endif
     C     exwgt         sub       lwvar         lwrng
     C*    $slvlouwgt    sub       ilvar         ilrng
     C     #toitswgt     sub       ilvar         ilrng
     C                   if        prg2c > 0
     C     exwgt         mult      prg2c         hivar
     C*    $slvlouwgt    mult      prg2c         ihvar
     C     #toitswgt     mult      prg2c         ihvar
     C                   endif
     C     exwgt         add       hivar         hirng
     C*    $slvlouwgt    add       ihvar         ihrng
     C     #toitswgt     add       ihvar         ihrng
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1cwgt = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *R                   Z-ADD$PQTY     OQTY
     C                   z-add     oqt1          woqt01
     C                   z-add     oqt2          woqt02
     C                   z-add     oqt3          woqt03
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     C     ivskey        chain     invslot4                           77
     C                   if        *in77
     C                   eval      error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endgt1
500a C                   endif
     *
     C     cwkey         chain     invscw                             79
     C                   if        not *in79
500a C*    ivwwgt        mult      100           w1cwgt
500a C                   eval      w1cwgt = ivwwgt
500a C                   else
500a C                   eval      w1cwgt = 0
500a C                   endif
500bA*    Get options
     C                   exsr      zzoptn
     *
500bA*    Get item info
     C                   exsr      zzgeti
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGETI   Get item info
     *
     C     zzgeti        begsr
500 A
500 A*  Use DRI interface to get item.
500 A
500 AC                   exsr      clr$item
500 AC                   eval      $itwhse  = $pwhse
500 AC                   eval      $ititem  = $pitem
500 A
500 AC                   eval      $dricommand = '*ITEM'
500 AC                   eval      $drisubcmd  = '%GETMAIN'
500 AC                   eval      $drisys2upd = 'D'
500 AC                   eval      chk4err = *on
500 AC                   eval      zmsflag = *off
500 AC                   exsr      zzzdricop
500 AC                   if        error
500 AC                   eval      error = *off
500 AC                   eval      $itdesc = 'ITEM NOT FOUND'
500 AC                   endif
500 A
500 AC                   eval      #toititem = $ititem
500 AC                   eval      #toittype = $ittype
500 AC                   eval      #toitdesc = $itdesc
500 AC                   eval      #toitpdsc = $itpdsc
500 AC                   eval      #toitwhdp = $itwhdp
500 AC                   eval      #toitstyp = $itstyp
500 AC                   eval      #toitdesg = $itdesg
500 AC                   eval      #toitum1  = $itum1
500 AC                   eval      #toitflg1 = $itflg1
500 AC                   eval      #toitum2  = $itum2
500 AC                   eval      #toitumq2 = $itumq2
500 AC                   eval      #toitflg2 = $itflg2
500 AC                   eval      #toitum3  = $itum3
500 AC                   eval      #toitumq3 = $itumq3
500 AC                   eval      #toitnrpk = $imnrpk
500 AC                   eval      #toitflgd = $itflgd
500 AC                   eval      #toitcube = $itcube
500 AC                   eval      #toitswgt = $itswgt
500 AC                   eval      #toitcwgt = $itcwgt
500 AC                   eval      #toitmitem = $itmitem
500 A
500 A*  Use DRI interface to get corresponding SSB item, if any.
500 A
500 AC                   exsr      clr$item
500 AC                   eval      $itwhse  = $pwhse
500 AC                   eval      $ititem  = $pitem
500 A
500 AC                   eval      $dricommand = '*ITEM'
500 AC                   eval      $drisubcmd  = '%GETSSB'
500 AC                   eval      $drisys2upd = 'D'
500 AC                   eval      chk4err = *off
500 AC                   eval      zmsflag = *off
500 AC                   exsr      zzzdricop
500 AC                   if        $drireturn = 'SSBNOTFND'
500 AC                   eval      ssbflg  = *off
500 AC                   eval      #tossbititem = ' '
500 AC                   eval      #tossbittype = ' '
500 AC                   eval      #tossbitdesc = ' '
500 AC                   eval      #tossbitpdsc = ' '
500 AC                   eval      #tossbitwhdp = ' '
500 AC                   eval      #tossbitstyp = ' '
500 AC                   eval      #tossbitdesg = ' '
500 AC                   eval      #tossbitum1  = ' '
500 AC                   eval      #tossbitum2  = ' '
500 AC                   eval      #tossbitumq2 = 0
500 AC                   eval      #tossbitum3  = ' '
500 AC                   eval      #tossbitumq3 = 0
500 AC                   else
500 AC                   eval      ssbflg  = *on
500 AC                   eval      #tossbititem = $ititem
500 AC                   eval      #tossbittype = $ittype
500 AC                   eval      #tossbitdesc = $itdesc
500 AC                   eval      #tossbitpdsc = $itpdsc
500 AC                   eval      #tossbitwhdp = $itwhdp
500 AC                   eval      #tossbitstyp = $itstyp
500 AC                   eval      #tossbitdesg = $itdesg
500 AC                   eval      #tossbitum1  = $itum1
500 AC                   eval      #tossbitum2  = $itum2
500 AC                   eval      #tossbitumq2 = $itumq2
500 AC                   eval      #tossbitum3  = $itum3
500 AC                   eval      #tossbitumq3 = $itumq3
500 AC                   endif

     C     endgti        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     **         *LIKE     DEFN IVPPAG    SHEET
     *
     *  Define key for main file.
     *
     C     cwkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pdsp
     C                   kfld                    $pitem
     *
     *  Define partial key for main file.
     *
     C     partky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
500b *     ITEMMSC file -
     *
500b C     imkey         klist
500b C                   kfld                    $pwhse
500b C                   kfld                    $pitem
     *
     *
     *  Define key for INVSLOT4 file.
     *
     C     ivskey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pdsp
     *
500b *     OPTIONS file
500b C     opkeys        klist
500b C                   kfld                    wkwhse
500b C                   kfld                    wkcode
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      #pgmq = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     **                   MOVE '*ADD    '$PCMD
     C                   exsr      scr01i
     *
     C     endinz        endsr
500bA*----------------------------------------------------------------
     *
500bA*  ZZOPTN   Get options
     *
500b C     zzoptn        begsr
     *
500b *   Get catch wt options.
     C                   eval      wkcode = '*SYSTEM '
     C                   eval      wkwhse = 0
     *
     C     opkeys        chain     options                            79
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw  = 'N'
     C                   endif
     C*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     C     cwkey         chain     invscw                             79
     *
     C                   if        not *in79
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ivwedt = $cvd8o
     C                   time                    ivwctm
     C                   eval      ivwcby = #user
     C                   eval      ivwwgt = taddw
     C                   eval      ivwlrg = lwrng
     C                   eval      ivwhrg = hirng
     C                   eval      ivwwtx = ovrrid
     C                   update    ivwrec
     C                   else
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ivwedt = $cvd8o
     C                   time                    ivwetm
     C                   eval      ivweby = #user
     C                   eval      ivwwhs = ivswhs
     C                   eval      ivwdsp = ivsdsp
     C                   eval      ivwwhd = ivswhd
     C                   eval      ivwasl = ivsasl
     C                   eval      ivwloc = ivsloc
     C                   eval      ivwlvl = ivslvl
     C                   eval      ivwhnd = ivshnd
     C                   eval      ivwstp = ivsstp
     C                   eval      ivwitm = ivsitm
     C                   eval      ivwsid = ivssid
     C                   eval      ivwwgt = taddw
     C                   eval      ivwlrg = lwrng
     C                   eval      ivwhrg = hirng
     C                   eval      ivwwtx = ovrrid

     C                   write     ivwrec
     C                   endif
     C                   eval      ovrrid = *off
     C                   eval      wtchk = *off
     C                   eval      woqt01 = 0
     C                   eval      woqt02 = 0
     C                   eval      woqt03 = 0
     C                   if        %error
     C                   goto      endup1
     C                   endif

     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     **         $PWHSE    CHAININVNXTP              7978
     *
     *  Record locked.
     *
     **                   SELEC
     *R         *IN78     WHEQ *ON
     *R                   MOVE *ON       ERROR
     *
     *  Record found - Get next page number and update record.
     *
     *R                   OTHER
     *R                   Z-ADDIVXPAG    SHEET
     *R                   ADD  1         IVXPAG
     *R                   UPDATIVXREC
     *
     *R                   ENDSL
     *
     *
     C     endup2        endsr
     *
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------
500 A*                     DRI SUBROUTINES
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  clr$item  Clear $item data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

500 A*----------------------------------------------------------------
500 A*  zzzdricop  Call DRICOP
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C*                  when      $dricommand = '*SLOT'
     C*                  eval      $dridata = $slot
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
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

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        zmsflag
     C                   exsr      zm0105s
     C                   else
     C                   exsr      zm0105
     C                   endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C***                exsr      zzerrind
     C                   endif

     C                   endsl

     C                   select
     C*                  when      $dricommand = '*SLOT'
     C*                  eval      $slot = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Warehouse
Date
Team
Slot
Dept.
Weight
