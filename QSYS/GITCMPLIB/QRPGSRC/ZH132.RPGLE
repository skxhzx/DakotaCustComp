      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *                  WEBFACING REQUIREMENTS
     *
     * CHANGES TO THE DISPLAY FILE WILL REQUIRE THE F-SPEC TO BE
     * RENAMED TO THE NEXT SEQUENTIAL MEMBER NAME.
     *
     * I.E. ZH132FM WILL BE REPALCED WITH ZH13201
     *----------------------------------------------------------------
     *
     *  ZH132     Zone detail maintenance - Change
     *  11 June 1997
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *
     *  Revisions
412 A*    09/15/99  RH   4.12
     *      - FIX, change order of key ZDLOC1 & ZDLOC2 to match file.
413aA*    04/04/00  RH   4.13
     *      - FIX, get whse description, truck and zone for screen
520aA*    02/27/09  DAS  5.20a  P#00150
     *      - ENH, Added handstack range, designation, category,
     *        uom type and side.
     *      - Renamed ZH132FM to ZH13201
520bA*    03/13/09  JCJ  5.20b
     *      - Fix: Added supporting code for 520a change
530 A*    11/06/09  JCJ  5.30
     *      - Added Truck Template heading to Screen Title.
     *      - For a truck, display info for the corresponding
     *        template code.
     *      - For a truck, activated option 5=View
620aA*    12/08/10  DAS  6.20a
     *      - Revised to always allow 'PRE' aisle.
620bA*    12/16/10  DAS  6.20b
     *      - Revised to not allow 'PRE' aisle if an 'S' zone
     *        is defined.
640aA*    05/11/11  DAS  6.40a
     *      - Revised to prevent some fields from being entered when
     *        using TB Light.
700aA*    03/09/16  NLK  7.00a
     *      - Revised to always allow 'AMP' 'DOR' aisle.
720aA*    10/14/18  DAS  7.20a
     *      -  Recompiled because of new ZONED fields
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
520aMF**zh13201   cf   e             workstn
530 MFzh13202   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fzoned1    uf a e           k disk
     F                                     rename(zdrec:record)
     Fslot1     if   e           k disk
413AAFwarehs    if   e           k disk
530 AFtruckh    if   e           k disk
620bAFzoneh     if   e           k disk
620bAFoptionz   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
520aDD*desc            s             50    dim(6) ctdata perrcd(1)
520aMD desc            s             50    dim(12) ctdata perrcd(1)
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
     D  $ptruk                22     31
     D  $pzone                32     37
     D  $pwhdp                38     42
     D  $pstyp                43     43
     D  $paisl                44     46
     D  $prlvl                47     48  0
412 MD  $ploc2                49     51  0
412 MD  $ploc1                52     54  0
520bAD  $pdesg                55     59
520bAD  $phnd1                60     61
520bAD  $phnd2                62     63
520bAD  $putyp                64     64
520bAD  $pside                65     65
412 D*                                      49  510$PLOC1
412 D*                                      52  540$PLOC2
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
     D  $lsdef                22     23
     D  $lwhdp                22     26
413aA*
413aAD  $ltruk                22     31
413aAD  $lzone                22     37
     *
520aAD  $ldesg                19     23
     *
520aAD  $lcat                 19     28
620bA*----------------------------------------------------------------
620bA*  OPTIONZ data structure
620bA*
620bAD opzdta          ds
620bAD  opzend               117    117
620bA*----------------------------------------------------------------
620bA*  *PICK  -  Picking options
     *
     *     11/28/94  DAS
     *       - Changed OPFSTP to 2 digits from 1.
     *
     *     02/16/95  DAS   2.09
     *       - Moved option from OPTIONS to OPTIOND in order to have
     *         the options by department.
     *       - Added option OPFBLD for identifying the method to use
     *         for building a fixed pallet.
     *
213 A*     06/11/96  DAS   2.13
     *       - Redefined OPBPCK to 3.0 from 2.0.
     *       - Added option OPPBRK.
     *
214 A*     07/01/96  DAS
     *       - Redefined OPPBRK to 3 from 1 and to contain aisle
     *         instead of Y/N.
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - OPPBRK is not used with zones.
     *
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
214 D**** OPPBRK  -  Break pallets by aisle (Y,N).
214 M*    OPPBRK  -  Aisle to start new pallet.
400 A*    OPPBLD  -  Pallet building method.
400 A*                1 = By stop then slot location.
400 A*                2 = By slot location then stop.
416 A*                3 = By descening stop, then slot location.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
400 A*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
416aA*    OPNWPL  -  Start new pallet when aisle changes if build method
416aA*               is 2=Location.
500dA*    OPFORD  -  Maximun orders per pallet.
520dM*    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
500dA*    OPFTOT  -  Maximum totes per pallet.
500dA*    OPTECB  -  External tote cube.
500dA*    OPTICB  -  Internal tote cube.
500dA*    OPTSTP  -  Maximum stops per tote.
500dA*    OPTPCS  -  Maximum pieces per tote.
510dA*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
520dA*    OPGCDE  -  USF Group Code (0-9).
520cA*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520cA*    OPSPAL  -  Merge pallet should only contain
520cA*               items for single truck pallet (Y=Yes, N=No).
520dA*    OPPITM  -  Maximum items per pallet.
     *
     * Data structure
     *
     D opdta1          ds
     D  opnxtp                 1      7  0 inz(0)
213 D*I            0                         8   90OPBPCK
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     *I            0                        21  210OPFSTP
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
209 AD  opfbld                27     27  0 inz(0)
213 AD  opbpck                28     30  0 inz(0)
214 D*                                      31  31 OPPBRK
214 AD  oppbrk                31     33
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
500 D*                                      37  37 OPBMRG
500 D*                                      38  38 OPNWPL
500 MD  opbmrg                37     37
500 MD  opnwpl                38     38
500dAD  opford                39     40  0 inz(0)
500cMD  opptyp                41     41
500dAD  opftot                42     43  0 inz(0)
500dAD  optecb                44     48  2 inz(0)
500dAD  opticb                49     53  2 inz(0)
500dAD  optstp                54     55  0 inz(0)
500dAD  optord                56     57  0 inz(0)
500dAD  optpcs                58     60  0 inz(0)
510dAD  opstop                61     61
520dA** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
520dAD**opgcde                62     62
520cAD  oppkup                62     62
520cAD  opspal                63     63
520dAD  oppitm                64     67  0 inz(0)
     D  opend1               117    117
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     *
     D  eraisl                 1      3
     D  erwhdp                 4      8
     *
     D  ernam1                 1     20
     D  ernam2                21     40
     D  erval1                41     42p 0
     D  erval2                43     44p 0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
530  D #ztmp           c                   const('  TEMPLATE')
530  *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
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

520aA*----------------------------------------------------------------
520aA*  Verify Subprogram Variables.
520aA*----------------------------------------------------------------

     D $vcount         s              3p 0
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10
     D $vsdesc         s              5

     D $vcat           s                   like(zdcat)
     D $vdesg          s                   like(zddesg)

     *----------------------------------------------------------------
     *  Variables
     *
640aMD $gfCmd          s              1
640aMD $gfFeature      s              1
640aMD $gfLight        s              1
640aMD $gfWhse         s              3p 0
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
620bMD error           s               n
620bAD forever         s               n
     D help            s              5  0
     D kyaisl          s                   like(slaisl)
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
640aMD tbLight         s               n
     D warn            s              1
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
520bAC                   parm                    $pcat
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
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
520aMC                   setoff                                       303132
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
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
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
     C                   endif
     C                   eval      nxtscr = 'EOJ'
     C     endsc1        endsr
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
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
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
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
413aA*      0105
413aA*
413aAC     zm0105        begsr
413aAC                   eval      #msgid = 'PIR0105'
413aAC                   eval      #msgtp = '*DIAG  '
413aAC                   movea     errmsg        $md(1)
413aAC                   exsr      zmpmsg
413aAC                   endsr
     *----------------------------------------------------------------
     *   PIR0109  Number can not be less than zero.
     *
     C     zm0109        begsr
     C                   eval      #msgid = 'PIR0109'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0113  Number can not be less than zero.
     *
     C     zm0113        begsr
     C                   eval      #msgid = 'PIR0113'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
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
     *   ZH13221  Aisle does not exist in department.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'ZH13221'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT11021  Invalid section entered.
     *
     C     zm21b         begsr
     C                   eval      #msgid = 'IT11021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   ZH13222  Section must be entered if aisle, level or loc are entered.
     *
     C     zm22          begsr
     C                   eval      #msgid = 'ZH13222'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   ZH13223  Aisle must be entered if level or loc are entered.
     *
     C     zm23          begsr
     C                   eval      #msgid = 'ZH13223'
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
     C                   if        $pcmd = '*ADD    '
     *
     *    Make sure code was entered.
     *
     C                   if        w1whdp = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm01
     C                   endif
     *
     *    Verify warehouse department.
     *
     C                   if        w1whdp <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $pwhse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
620bA
620bA*  Do not allow aisle PRE if 'S' zone defined.
620bA
620bAC                   if        w1aisl = 'PRE'
620bAC                   exsr      zzIsPreOk
620bAC                   if        error
620bAC                   leavesr
620bAC                   endif
620bAC                   endif
     *
     *  Verify section type.
     *
     C                   if        w1styp <> *blank  and
     C                             w1styp <> 'F'  and
     C                             w1styp <> 'P'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   exsr      zm21b
     C                   endif
     *
     *  Section must be entered if Aisle, Level or Locations are entered.
     *
     C                   if        w1styp = *blanks
     C                   if        w1aisl <> *blanks  or
     C                             w1rlvl <> 0  or
     C                             w1loc1 <> 0  or
520aMC                             w1loc2 <> 0  or
520aAC                             w1hnd1 <> ' ' or
520aAC                             w1hnd2 <> ' '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm22
     C                   endif
     C                   endif
     *
     *  Verify aisle.
     *
     C                   if        w1aisl <> *blanks
620aAC                             and w1aisl <> 'PRE'
700aAC                             and w1aisl <> 'AMP'
700aAC                             and w1aisl <> 'DOR'
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm      w1aisl        $cstr            30
     C                   move      $cstr         kyaisl
     C     keysl1        setll     slot1                                  79
     C                   if        not *in79
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erwhdp = w1whdp
     C                   eval      eraisl = w1aisl
     C                   exsr      zm21
     C                   endif
     C                   endif
     *
     *  Aisle must be entered if Level or Locations are entered.
     *
     C                   if        w1aisl = *blanks
     C                   if        w1rlvl <> 0  or
     C                             w1loc1 <> 0  or
520aAC                             w1loc2 <> 0  or
520aAC                             w1hnd1 <> ' ' or
520aAC                             w1hnd2 <> ' '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm23
     C                   endif
     C                   endif
640aA
640aA*  For Truck Builder Light, some entries not allowed.
640aA
640aAC                   if        tbLight
640aAC                   if        w1rlvl <> 0
640aAC                             or w1loc1 <> 0
640aAC                             or w1loc2 <> 0
640aAC                             or w1hnd1 <> ' '
640aAC                             or w1hnd2 <> ' '
640aAC                             or w1desg <> ' '
640aAC                             or w1cat <> ' '
640aAC                             or w1utyp <> ' '
640aAC                             or w1side <> ' '
640aAC                   eval      error = *on
640aAC                   eval      errmsg = 'Only Dpt, Sect and Aisle '
640aAC                                    + 'allowed for Light version'
640aAC                   exsr      zm0105
640aAC                   leavesr
640aAC                   endif
640aAC                   endif
     *
     *  Verify level is within range.
     *
     C                   if        w1rlvl < 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       erfld
     C                   exsr      zm0109
     C                   endif
     *
     *  Verify from slot location is within range.
     *
     C                   if        w1loc1 < 0
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       erfld
     C                   exsr      zm0109
     C                   endif
     *
     *  Verify to slot location is within range.
     *
     C                   if        w1loc2 < 0
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       erfld
     C                   exsr      zm0109
     C                   endif
     *
     *  Verify to loc is greater than from loc.
     *
     C                   if        w1loc2 < w1loc1
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       ernam1
     C                   movel     desc(5)       ernam2
     C                   eval      erval1 = w1loc2
     C                   eval      erval2 = w1loc1
     C                   exsr      zm0113
     C                   endif
520aA*
520aA*  Verify To hand is greater than From hand.
520aA*
520aAC                   if        w1hnd2 < w1hnd1
520aAC                   eval      error = *on
520aAC                   eval      *in28 = *on
520aAC                   eval      *in08 = *on
520aAC                   eval      errmsg = 'To Handstack cannot be '
520aAC                                    + 'less than From Handstack'
520aAC                   exsr      zm0105
520aAC                   endif
520aA
520aA*  Verify designation code
520aA
520aAC                   if        w1desg <> ' '
520aAC                   call(e)   'VFYDESG'
520aAC                   parm      '*VERIFY'     $vcommand
520aAC                   parm      #prog         $vprg
520aAC                   parm      w1desg        $vdesg
520aAC                   parm      ' '           $vdesc
520aAC                   parm      ' '           $vreturn
520aAC                   parm      ' '           $vmessage
520aAC                   parm      ' '           $vmsgk
520aA
520aAC                   select
520aAC                   when      %error
520aAC                   eval      error = *on
520aAC                   eval      *in29 = *on
520aAC                   eval      *in09 = *on
520aAC                   eval      errmsg = 'Error occured on call to '
520aAC                                    + 'VFYDESG'
520aAC                                    + '/' + %trim($vcommand)
520aAC                                    + ' from ' + #prog
520aAC                   exsr      zm0105
520aA
520aAC                   when      $vreturn <> '*OK'
520aAC                   eval      error = *on
520aAC                   eval      *in29 = *on
520aAC                   eval      *in09 = *on
520aAC                   eval      errmsg = 'Invalid Designation code entered'
520aAC                   exsr      zm0105
520aA
520aAC                   endsl
520aA
520aAC                   endif
520aA
520aA*  Verify item category.
520aA
520aAC                   if        w1cat <> ' '
520aAC                   call(e)   'VFYICAT'
520aAC                   parm      '*VERIFY'     $vcommand
520aAC                   parm      #prog         $vprg
520aAC                   parm      w1cat         $vcat
520aAC                   parm      ' '           $vdesc
520aAC                   parm      ' '           $vreturn
520aAC                   parm      ' '           $vmessage
520aAC                   parm      ' '           $vmsgk
520aA
520aAC                   select
520aAC                   when      %error
520aAC                   eval      error = *on
520aAC                   eval      *in30 = *on
520aAC                   eval      *in10 = *on
520aAC                   eval      errmsg = 'Error occured on call to '
520aAC                                    + 'VFYICAT'
520aAC                                    + '/' + %trim($vcommand)
520aAC                                    + ' from ' + #prog
520aAC                   exsr      zm0105
520aA
520aAC                   when      $vreturn <> '*OK'
520aAC                   eval      error = *on
520aAC                   eval      *in30 = *on
520aAC                   eval      *in10 = *on
520aAC                   eval      errmsg = 'Invalid Category code entered'
520aAC                   exsr      zm0105
520aA
520aAC                   endsl
520aA
520aAC                   endif
520aA*
520aA*  Verify UOM Type
520aA*
520aAC                   if        w1utyp <> ' '
520aAC                             and w1utyp <> 'N'
520aAC                             and w1utyp <> '1'
520aAC                             and w1utyp <> '2'
520aAC                   eval      error = *on
520aAC                   eval      *in31 = *on
520aAC                   eval      *in11 = *on
520aAC                   eval      errmsg = 'Invalid value entered  '
520aAC                                    + 'for UOM Type'
520aAC                   exsr      zm0105
520aAC                   endif
520aA*
520aA*  Verify Side
520aA*
520aAC                   if        w1side <> ' '
520aAC                             and w1side <> 'O'
520aAC                             and w1side <> 'E'
520aAC                   eval      error = *on
520aAC                   eval      *in32 = *on
520aAC                   eval      *in12 = *on
520aAC                   eval      errmsg = 'Invalid value entered  '
520aAC                                    + 'for Side'
520aAC                   exsr      zm0105
520aAC                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
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
     *     Warehouse department.
     *
     C                   when      row# = 10
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
     C                   endif
520aA
520aA*     Designation code
520aA
520aAC                   when      row# = 16
520aAC                   eval      *in09 = *on
520aAC                   eval      $lcmd = '*LOOKUP '
520aAC                   eval      $ldesg = w1desg
520aAC                   call      'DS900'
520aAC                   parm                    $lparm
520aAC                   if        $lrtn = '*SELECT '
520aAC                   eval      w1desg = $ldesg
520aAC                   endif
520aA
520aA*     Category code.
520aA
520aAC                   when      row# = 17
520aAC                   eval      *in10 = *on
520aAC                   eval      $lcmd = '*LOOKUP '
520aAC                   eval      $lcat  = w1cat
520aAC                   call      'IC900'
520aAC                   parm                    $lparm
520aAC                   if        $lrtn = '*SELECT '
520aAC                   eval      w1cat  = $lcat
520aAC                   endif
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
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1whdp = *blanks
     C                   eval      w1styp = *blanks
     C                   eval      w1aisl = *blanks
     C                   eval      w1rlvl = 0
     C                   eval      w1loc1 = 0
     C                   eval      w1loc2 = 0
520aAC                   eval      w1hnd1 = ' '
520aAC                   eval      w1hnd2 = ' '
520aAC                   eval      w1desg = ' '
520aAC                   eval      w1cat  = ' '
520aAC                   eval      w1utyp = ' '
520aAC                   eval      w1side = ' '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1whdp = zdwhdp
     C                   eval      w1styp = zdstyp
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm      zdaisl        $cstr
     C                   movel     $cstr         w1aisl
     C                   eval      w1rlvl = zdrlvl
     C                   eval      w1loc1 = zdloc1
     C                   eval      w1loc2 = zdloc2
520aAC                   eval      w1hnd1 = %trim(zdhnd1)
520aAC                   eval      w1hnd2 = %trim(zdhnd2)
520aAC                   eval      w1desg = zddesg
520aAC                   eval      w1cat  = zdcat
520aAC                   eval      w1utyp = zdutyp
520aAC                   eval      w1side = zdside
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C     fileky        chain     record                             7978
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt2
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt2
     C                   endif
     *
     *   If viewing, release record.
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C     *loval        setll     record
     C                   endif
     C     endgt2        endsr

620bA*----------------------------------------------------------------
620bA*  zzIsPreOk   Check if PRE aisle is allowed.
620bA*----------------------------------------------------------------
620bA
620bAC     zzIsPREOk     begsr

      /free

         // Only one 'S' zone is allowed.

         setll ($pwhse: $ptruk) zoneh;

         dow forever = forever;

           reade    ($pwhse: $ptruk) zoneh;

           if %eof(zoneh);
             leave;
           endif;

           // If zone is 'S', return error.

           chain    ('*PICK': zhwhse: zhtruk: zhzone) optionz;
           if %found(optionz);
             opdta1 = opzdta;
             if opptyp = 'S';
               error = *on;
               *in23 = *on;
               *in03 = *on;
               errmsg = 'Cannot use aisle PRE because '
                      + 'an S zone is defined';
               exsr zm0105;
               leavesr;
             endif;
           endif;

         enddo;

      /end-free

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     C                   kfld                    $pzone
     C                   kfld                    $pwhdp
     C                   kfld                    $pstyp
     C                   kfld                    $paisl
     C                   kfld                    $prlvl
412 D*R                   KFLD           $PLOC1
     C                   kfld                    $ploc2
412 MC                   kfld                    $ploc1
520bAC                   kfld                    $pdesg
520bAC                   kfld                    $pcat            10
520bAC                   kfld                    $phnd1
520bAC                   kfld                    $phnd2
520bAC                   kfld                    $putyp
520bAC                   kfld                    $pside
     *
     *  Define key for SLOT1 file.
     *
     C     keysl1        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1whdp
     C                   kfld                    kyaisl
530 A*
530 A*  Define key for truck file.
530 A*
530 AC     trukky        klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
413aA*   Get warehouse description.
413aA*
413aAC     $pwhse        chain     warehs                             79
413aAC                   if        *in79
413aAC                   eval      whdesc = *blanks
413aAC                   eval      whcode = 0
413aAC                   endif
640aA
640aA*   Get feature info.
640aA
640aAC                   eval      $gfWhse = $pwhse
640aAC                   call      'GETFEAT'
640aAC                   parm      '*GET'        $gfCmd
640aAC                   parm                    $gfWhse
640aAC                   parm                    $gfFeature
640aAC                   parm                    $gfLight
640aAC                   if        $gfLight = 'Y'
640aAC                   eval      tbLight = *on
640aAC                   else
640aAC                   eval      tbLight = *off
640aAC                   endif
413aA*
413aA*   Get truck description.
413aA*
413aAC                   eval      wotruk = *blanks
413aAC                   movel     $ptruk        wotruk
413aAC                   eval      $lcmd = '*VERIFY '
413aAC                   eval      $lwhse = $pwhse
413aAC                   eval      $ltruk = $ptruk
413aAC                   call      'TM900'
413aAC                   parm                    $lparm
413aAC                   if        $lrtn = '*ERROR  '
413aAC                   eval      error = *on
413aAC                   eval      *in22 = *on
413aAC                   eval      *in02 = *on
413aAC                   movel     $lerm         errmsg
413aAC                   exsr      zm0105
413aAC                   else
413aAC                   if        $lrtn = '*PGMQ   '
413aAC                   eval      error = *on
413aAC                   eval      *in22 = *on
413aAC                   eval      *in02 = *on
413aAC                   eval      #msgk = $lmsg
413aAC                   exsr      zmqmsg
413aAC                   else
413aAC                   eval      wotruk = *blanks
413aAC                   eval      wotruk = %trimr($ptruk) + ' ' + '-'
413aAC                   eval      wotruk = %trimr(wotruk) + ' ' + $lerm
413aAC                   endif
413aAC                   endif
413aA*
413aA*   Get zone description.
413aA*
413aAC                   eval      wozone = *blanks
413aAC                   movel     $pzone        wozone
413aAC                   eval      $lcmd = '*VERIFY '
413aAC                   eval      $lwhse = $pwhse
413aAC                   eval      $ltruk = $ptruk
413aAC                   move      $pzone        $lzone
413aAC                   call      'ZH900'
413aAC                   parm                    $lparm
413aAC                   if        $lrtn = '*ERROR  '
413aAC                   eval      error = *on
413aAC                   eval      *in22 = *on
413aAC                   eval      *in02 = *on
413aAC                   movel     $lerm         errmsg
413aAC                   exsr      zm0105
413aAC                   else
413aAC                   if        $lrtn = '*PGMQ   '
413aAC                   eval      error = *on
413aAC                   eval      *in22 = *on
413aAC                   eval      *in02 = *on
413aAC                   eval      #msgk = $lmsg
413aAC                   exsr      zmqmsg
413aAC                   else
413aAC                   eval      wozone = *blanks
413aAC                   eval      wozone = %trimr($pzone) + ' ' + '-'
413aAC                   eval      wozone = %trimr(wozone) + ' ' + $lerm
413aAC                   endif
413aAC                   endif
     *
     *
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
     C                   eval      $pwhdp = *blanks
     C                   eval      $pstyp = *blanks
     C                   eval      $paisl = *blanks
     C                   eval      $prlvl = 0
     C                   eval      $ploc1 = 0
     C                   eval      $ploc2 = 0
     C                   endif
530 AC     trukky        chain     truckh
530 AC                   if        %found(truckh)
530 AC                   eval      w1ztmp = #ztmp
530 AC                   if        thztmp <> *blanks
530 AC                   eval      w1ztmp = thztmp
530 AC                   eval      $ptruk = thztmp
530 AC                   endif
530 AC                   endif
530 A*
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      zdwhdp = w1whdp
     C                   eval      zdstyp = w1styp
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd
     C                   parm      w1aisl        $cstr
     C                   move      $cstr         zdaisl
     C                   eval      zdrlvl = w1rlvl
     C                   eval      zdloc1 = w1loc1
     C                   eval      zdloc2 = w1loc2
520aAC                   evalr     zdhnd1 = %trim(w1hnd1)
520aAC                   evalr     zdhnd2 = %trim(w1hnd2)
520aAC                   eval      zddesg = w1desg
520aAC                   eval      zdcat  = w1cat
520aAC                   eval      zdutyp = w1utyp
520aAC                   eval      zdside = w1side
     *
     *   Add record
     *
     C                   if        $pcmd = '*ADD    '
     C                   eval      zdwhse = $pwhse
     C                   eval      zdtruk = $ptruk
     C                   eval      zdzone = $pzone
     C                   write     record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endupd
     C                   endif
     C                   else
     *
     *   -OR- Update record (it was read and locked in ZZGET2)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
     C                   endif
     *
     *   Move key values to parameters
     *
     C                   eval      $pwhdp = zdwhdp
     C                   eval      $pstyp = zdstyp
     C                   eval      $paisl = zdaisl
     C                   eval      $prlvl = zdrlvl
     C                   eval      $ploc1 = zdloc1
     C                   eval      $ploc2 = zdloc2
     C     endupd        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Department
Section
Aisle
Rack Level
From Location
To Location
From Handstack
To Handstack
Designation
Category
UOM Type
Side
