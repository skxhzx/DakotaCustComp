     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OP130     PIR options - Receiving
     *  24 September 2001
     *  Dave Sommerville
     *
     *  Revisions
     *
416 A*    09/24/01  DAS  4.16
     *      - Created.
     *
416aA*    10/06/01  DAS  4.16a
     *      - Revised to allow cw entry type to be 1 or 2 if entry
     *        is First Only.
     *
417 A*    04/11/03  MLB  4.17
     *      - Enh: Add support to program for Retail UPC's. Add 3
     *        new fields: OPRUPC, OPRUPS and OPRUPF.
417aA*    02/01/04  MLB  4.17a
     *      - Enh: Add support to program for Allow single po to
     *        be attached to multiple Super P/O's.
700aA*    12/29/15  LMC  7.00a
     *      - Enh: Changed the edit check on receiving label print
     *        program - If the program starts with RFMT, we will edit
     *        for RFMT, and ignore the remaining 6 positions.
     *        The remaining six positions are used to send the label
     *        set name to the RFMT program.
     *      - Enh: Validate the label set name.
     *        label set name is the last 6 positions of the receiving
     *        label print program.
     *        This label set needs to exist in file LBLFMTD.
710aA*    05/02/17  LMC  7.10a
     *      - Enh: Added new option Allow Gui Multiple pallet
     *        Receiving option - default to 'Y' if the field is blank.
     *      - Enh: Renamed display file OP135FM to OP13501.
     *
710bA*    07/20/17  LMC  7.10b
     *      - Enh: Added new option Allow partial export.
     *        Receiving option - default to 'Y' if the field is blank.
     *      - Enh: Renamed display file OP13501 to OP13502.
     *
720 A*    02/20/18  MLB  7.20
     *      - Enh: Added 2 new options to plist for call to RFMT.

730aA*    09/23/19  LMC  7.30a
     *      - fix: Do not execute the edit check if the print program
     *        is RFMT. The original edit check was for program RLBL01.
     *        So the parms don't match rfmt. Skip this check.
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
710aDF*op135fm   cf   e             workstn
710bDF*op13501   cf   e             workstn
710bMFop13502   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Foptions   uf a e           k disk
     F                                     rename(oprec:record)
700aAFlblfmtd   if   e           k disk    usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
417 D*                   DESC    1   7 50
417aD*                   DESC    1  10 50
700aDD*desc            s             50    dim(11) ctdata perrcd(1)
710aDD*desc            s             50    dim(12) ctdata perrcd(1)
710bDD*desc            s             50    dim(13) ctdata perrcd(1)
710bMD desc            s             50    dim(14) ctdata perrcd(1)
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
     *----------------------------------------------------------------
     *  *RCVLBL  -  Receiving options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPLPGM  -  Receiving label program.
     *    OPUPCT  -  Ideal slot usage percentage.
     *    OPPDEF  -  PIR minimum number of slots priority.
     *    OPPBLD  -  PIR same build code priority.
     *    OPPACT  -  PIR same activity zone priority.
     *    OPFDEF  -  Fixed minimum number or slots priority.
     *    OPFASL  -  Fixed same aisle priority.
     *    OPFSID  -  Fixed same side priority.
     *    OPFLVL  -  Fixed highest level priority.
217 A*    OPPASL  -  PIR same aisle priority.
217 A*    OPPFRC  -  Force PIR same aisle priority.
221 A*    OPPLCN  -  Use generic license plates.
409 A*    OPPCHM  -  Check chimney (Y,N)
409 A*    OPPMIX  -  Allow mixed expiration dates in fixed home slot(Y,N)
412 A*    OPAPCK  -  Assign pick slots automatically for fixed items(Y,N)
414 A*    OPFRCM  -  Force marking of all P.O. detail lines (Y,N)
416 A*    OPEXCK  -  Expiration date check (1,2,3)
416 A*                What to do when exp date being rcvd comes
416 A*                earlier than existing overflow exp date ...
416 A*                  1 = Don't allow it.
416 A*                  2 = Warn user & log when overriden
416 A*                  3 = Let it go through.
416 A*    OPCWEN  -  Allow catch weight entry (1,2,3)
416 A*                  1 = Every receipt
416 A*                  2 = First receipt only
416 A*                  3 = Never
416 A*    OPCWTP  -  Catch weight value entered (1,2,3)
416 A*                  1 = User choice
416 A*                  2 = Average
416 A*                  3 = Total
416 A*    OPCWFR  -  Force catch weight entry (Y,N)
416gA*    OPIPCK  -  Ignore existing pick slots (Y,N)
417 A*    OPRUPC  -  Prompt user for Retail UPC during receiving? (Y,N)
417 A*    OPRUPS  -  Allow user to skip Retail UPC scan? (Y,N)
417 A*    OPRUPF  -  Require Retail UPC on file before receipt? (Y,N)
417hA*    OPMSPO  -  Allow single po attached to multiple Super P/Os? (Y/N)
710aA*    OPMPLT  -  Allow Gui Multiple Pallet Receiving (Y/N)        (Y/N)
710bA*    OPPEXP  -  Allow partial Export (Y/N)                       (Y/N)
     *
     * Data structure
     *
     D opdata          ds
     D  oplpgm                 1     10
     D  opupct                11     13  0
     D  oppdef                14     14  0
     D  oppbld                15     15  0
     D  oppact                16     16  0
     D  opfdef                17     17  0
     D  opfasl                18     18  0
     D  opfsid                19     19  0
     D  opflvl                20     20  0
     D  oppasl                21     21  0
     D  oppfrc                22     22
221 AD  opplcn                23     23
409 AD  oppchm                24     24
409 AD  oppmix                25     25
412 AD  opapck                26     26
414 AD  opfrcm                27     27
416 AD  opexck                28     28
416 AD  opcwen                29     29
416 AD  opcwtp                30     30
416 AD  opcwfr                31     31
416gAD  opipck                32     32
417 AD  oprupc                33     33
417 AD  oprups                34     34
417 AD  oprupf                35     35
417aAD  opmspo                36     36
710aAD  opmplt                37     37
710abD  oppexp                38     38
     D  optend               117    117
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
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erprty                 1      1p 0
     D  erprt2                 2      2p 0
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
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
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D tmpflg          s              1
     D warn            s              1
700aAD savew1lpgm      s                   like(w1lpgm)
700aAD w1lset          s              6
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new record.
     *              *EDIT    - Edit record.
     *              *PRINT   - Print record.
     *              *VIEW    - View record.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for everything but *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new unique key for *ADD.
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
700aA /free
700aA   if %open(lblfmtd);
700aA     close(e) lblfmtd;
700aA   endif;
700aA /end-free
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
     C                   exsr      zzupd
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
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     *R                   MOVE #MSGK     $PMSG
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     *R                   MOVE #MSGK     $PMSG
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
     *   OR13022  Error occured during call to program.
     *
     C     zm22          begsr
     C                   eval      #msgid = 'OP13022'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   movea     w1lpgm        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   OR13521  Value can't be 2=Total when entering on 1st receipt
     *
     C     zm21          begsr
     C                   eval      #msgid = 'OP13521'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify generic license plate option.
     *
     C                   if        w1plcn <> 'Y'  and
     C                             w1plcn <> 'N'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify label program.
     *
     *  Call program to make sure it is a valid receiving label pgm.
     *
     C                   if        w1lpgm <> *blanks  and
     C                             w1lpgm <> '*NONE'
700aA* save the label program name if it begins with RFMT, so it can
700aA* be replaced after the edit.
700aA /free
700aA   if %subst(w1lpgm:1:4) = 'RFMT';
700aA     savew1lpgm = w1lpgm;
700aA     w1lset = %subst(w1lpgm: 5 : 6);
700aA     w1lpgm = %subst(w1lpgm: 1 : 4);
700aA   endif;
700aA /end-free
730aAc                   if        w1lpgm <> 'RFMT'
     C                   call      w1lpgm                               50
     C                   parm      '*CLOSE  '    $rcmd             8
     C                   parm      0             $rtrn#            7 0
     C                   parm      0             $rwhse            3 0
     C                   parm                    $rwhdp            5
     C                   parm                    $rstyp            1
     C                   parm                    $rdisp           12
     C                   parm                    $rpslt           12
     C                   parm      0             $rqty             5 0
     C                   parm                    $rum              2
     C                   parm      0             $rtie             4 0
     C                   parm      0             $rhigh            2 0
     C                   parm                    $ritem           15
     C                   parm                    $rdesc           30
     C                   parm                    $rpdsc           15
     C                   parm                    $rupc            15
     C                   parm      0             $rven            11 0
     C                   parm                    $rvitm           15
     C                   parm                    $rpo              9
     C                   parm      0             $rrcvd            6 0
     C                   parm      0             $rexpd            6 0
     C                   parm                    $rdev            10
     C                   parm                    $rform           10
720 AC                   parm                    $rOSSlcns        15
720 AC                   parm                    $rmbrnd          10
     *
     C                   if        *in50
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   exsr      zm22
     C                   endif
730aAc                   endif
700aA*
700aA*  Verify label Set Name.
700aA*
700aA /free
700aA   if %subst(w1lpgm:1:4) = 'RFMT';
700aA     if not %open(lblfmtd);
700aA       open(e) lblfmtd;
700aA     endif;
700aA     chain(n) (w1lset) lblfmtd;
700aA     if not %found(lblfmtd);
700aA       error = *on;
700aA       *in22 = *on;
700aA       *in02 = *on;
700aA       errmsg = desc(12);
700aA       exsr zm1001;
700aA     endif;
700aA   endif;
700aA /end-free
700aA* Put the original w1lpgm values back.
700aA /free
700aA   if %subst(w1lpgm:1:4) = 'RFMT';
700aA     w1lpgm = savew1lpgm;
700aA   endif;
700aA /end-free
     C                   endif
     *
     *  Verify force marking of PO detail lines.
     *
     C                   if        w1frcm <> 'Y'  and
     C                             w1frcm <> 'N'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(3)
     C                   exsr      zm1005
     C                   endif
417aA*
417aA*  Verify Prompt for Retail UPC option.
417aA*
417aAC                   if        w1mspo <> 'Y'  and
417aAC                             w1mspo <> 'N'
417aAC                   eval      error = *on
417aAC                   eval      *in30 = *on
417aAC                   eval      *in10 = *on
417aAC                   eval      errmsg = *blanks
417aAC                   eval      errmsg = desc(11)
417aAC                   exsr      zm1005
417aAC                   endif
710aA*
710aA*  Verify Prompt for Allow Gui Multiple Pallet Receiving
710aA*
710aAC                   if        w1mplt <> 'Y'  and
710aAC                             w1mplt <> 'N'
710aAC                   eval      error = *on
710aAC                   eval      *in31 = *on
710aAC                   eval      *in11 = *on
710aAC                   eval      errmsg = *blanks
710aAC                   eval      errmsg = desc(13)
710aAC                   exsr      zm1005
710aAC                   endif
     *
     *  Verify expiration date option.
     *
     C                   if        w1exck <> '1'  and
     C                             w1exck <> '2'  and
     C                             w1exck <> '3'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(4)
     C                   exsr      zm1001
     C                   endif
710bA*
710bA*  Verify Prompt for Allow Partial Export
710bA*
710bAC                   if        w1pexp <> 'Y'  and
710bAC                             w1pexp <> 'N'
710bAC                   eval      error = *on
710bAC                   eval      *in32 = *on
710bAC                   eval      *in12 = *on
710bAC                   eval      errmsg = *blanks
710bAC                   eval      errmsg = desc(14)
710bAC                   exsr      zm1005
710bAC                   endif
     *
     *  Verify force catch weight entry option.
     *
     C                   if        w1cwfr <> 'Y'  and
     C                             w1cwfr <> 'N'
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(7)
     C                   exsr      zm1005
     C                   endif
     *
     *  Verify allow catch weight option.
     *
     C                   if        w1cwen <> '1'  and
     C                             w1cwen <> '2'  and
     C                             w1cwen <> '3'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(5)
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify catch weight value option.
     *
     C                   if        w1cwtp <> '1'  and
     C                             w1cwtp <> '2'  and
     C                             w1cwtp <> '3'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(6)
     C                   exsr      zm1001
     C                   endif
     *
416aM*  Catch weight value must be 1 or 2 when Allow CW is 2=First.
     *
     C                   if        w1cwen = '2'  and
     C                             w1cwtp <> '2'  and
416aAC                             w1cwtp <> '1'
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = *blanks
     C                   movel     w1cwtp        errmsg
     C                   exsr      zm21
     C                   endif
417 A*
417 A*  Verify Prompt for Retail UPC option.
417 A*
417 AC                   if        w1rupc <> 'Y'  and
417 AC                             w1rupc <> 'N'
417 AC                   eval      error = *on
417 AC                   eval      *in27 = *on
417 AC                   eval      *in07 = *on
417 AC                   eval      errmsg = *blanks
417 AC                   eval      errmsg = desc(8)
417 AC                   exsr      zm1005
417 AC                   endif
417 A*
417 A*  Verify Skip Retail UPC scan option.
417 A*
417 AC                   if        w1rups <> 'Y'  and
417 AC                             w1rups <> 'N'
417 AC                   eval      error = *on
417 AC                   eval      *in28 = *on
417 AC                   eval      *in08 = *on
417 AC                   eval      errmsg = *blanks
417 AC                   eval      errmsg = desc(9)
417 AC                   exsr      zm1005
417 AC                   endif
417 A*
417 A*  Verify Require Retail UPC on file option.
417 A*
417 AC                   if        w1rupf <> 'Y'  and
417 AC                             w1rupf <> 'N'
417 AC                   eval      error = *on
417 AC                   eval      *in29 = *on
417 AC                   eval      *in09 = *on
417 AC                   eval      errmsg = *blanks
417 AC                   eval      errmsg = desc(10)
417 AC                   exsr      zm1005
417 AC                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1plcn = 'N'
     C                   eval      w1lpgm = '*NONE'
     C                   eval      w1frcm = 'N'
     C                   eval      w1exck = *on
     C                   eval      w1cwfr = 'N'
     C                   eval      w1cwen = *on
     C                   eval      w1cwtp = *on
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1plcn = opplcn
     C                   if        oplpgm = 'RLBLXX'
     C                   eval      w1lpgm = '*NONE'
     C                   else
     C                   eval      w1lpgm = oplpgm
     C                   endif
     C                   eval      w1frcm = opfrcm
     C                   eval      w1exck = opexck
     C                   eval      w1cwfr = opcwfr
     C                   eval      w1cwen = opcwen
     C                   eval      w1cwtp = opcwtp
417 AC                   eval      w1rupc = oprupc
417 AC                   eval      w1rups = oprups
417 AC                   eval      w1rupf = oprupf
417aAC                   eval      w1mspo = opmspo
710aAc                   if        opmplt = ' '
710aAc                   eval      w1mplt = 'Y'
710aAc                   else
710aAC                   eval      w1mplt = opmplt
710aAc                   endif
710bAc                   if        oppexp = ' '
710bAc                   eval      w1pexp = 'Y'
710bAc                   else
710bAC                   eval      w1pexp = oppexp
710bAc                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*RCVLBL '
     *
     C                   eval      tmpflg = *off
     *
     C     beggt1        tag
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
     C                   if        tmpflg = *off
     C                   eval      tmpflg = *on
     C                   exsr      zzdft1
     C                   write     record
     C                   goto      beggt1
     C                   else
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif
     C                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get and verify warehouse description.
     *
     C                   eval      whcode = $pwhse
     C                   if        whcode = 0
     C                   eval      whdesc = *blanks
     C     'All ware'    cat       'houses':0    whdesc
     C                   else
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lprg = $pprg
     C                   eval      $lwhse = whcode
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '  or
     C                             $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      $prtn = $lrtn
     C                   eval      $perm = $lerm
     C                   goto      endin2
     C                   else
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
     *
     *   Select first screen to display.
     *
     C                   eval      $lprg = #prog
     C                   exsr      scr01i
     C     endin2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      opplcn = w1plcn
     C                   if        w1lpgm = '*NONE'
     C                   eval      oplpgm = 'RLBLXX'
     C                   else
     C                   eval      oplpgm = w1lpgm
     C                   endif
     C                   eval      opfrcm = w1frcm
     C                   eval      opexck = w1exck
     C                   eval      opcwfr = w1cwfr
     C                   eval      opcwen = w1cwen
     C                   eval      opcwtp = w1cwtp
417 AC                   eval      oprupc = w1rupc
417 AC                   eval      oprups = w1rups
417 AC                   eval      oprupf = w1rupf
417aAC                   eval      opmspo = w1mspo
710aAC                   eval      opmplt = w1mplt
710bAC                   eval      oppexp = w1pexp
     *
     *   Update record (it was read and locked in ZZGET1)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
     *
     C     endupd        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Use Generic License
Receiving Label Program
Force marking PO detail lines
Expiration date option
Allow catch weight entry
Catch weight value entered
Force catch weight entry
Prompt for Retail UPC
Allow skip Retail UPC
Require Retail UPC on file
Allow single po on multiple Super P/O's
Receiving Label Program/Label Name
Allow gui multiple pallet receiving
Allow partial export
