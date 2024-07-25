      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  LB371   Item Location label by Slot - options
     *  26 November 2014
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740bA*    07/03/20  MLB  7.40b  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (Reverse Display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Flb371fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiritem   if   e           k disk
     Fitemmsc   if   e           k disk
     Fslot1     if   e           k disk    rename(slrec:slrec1)
     Fslot2     if   e           k disk
     Flblfmtd   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(10) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

740bMD @prtpg          c                   const('BFCPRTLBL')
     D @plfmti         c                   const('ITEMLOC')

     *----------------------------------------------------------------
     *  Program parameters
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
     D  eritem#                1     15
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
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,id#cheneyo
      /COPY QCOPYSRC,id#cheneyr

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
     * Work Variables
     *----------------------------------------------------------------
     D msgk            s              4  0
     D $plen           s              3  0
     D wkwhse          s              3  0
     D w1whse          s              3  0
     D lblcount        s              3  0
     D w1tst           s              3  0
     D num             s              3  0
     D e               s              2  0
     D $pstr           s             60
     D $msgf           s             10
     D wkprtf          s             10
     D #pgmq           s             10
     D @plfmt          S              8
     D #msgid          s              7
     D #msgtp          s              7
     D @lblset         s              6
     D wkwhdp          s              5
     D nxtscr          s              3
     D wkaisl          s              3
     D cmdtkn          s              1
     D error           s              1
     D sclear          s              1
     D warn            s              1
     D wkstyp          s              1
     D work1a          s              1
     D forevr          s               n
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $prtn             8
     C                   parm                    $item            15
     C                   parm                    $qty              2 0
     C                   parm                    $brand           10
     C                   parm                    $dev             10
     C                   parm                    $form            10
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = '1'
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
     C                   eval      *inlr = *on
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
     C                   setoff                                       30
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
     *  Get existing record.
     *
     C                   exsr      zzfil1
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
     C                   eval      $prtn = '*EXIT   '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      $prtn = '*CANCEL '
     C                   eval      nxtscr = 'EOJ'
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
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zznxt1
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   move      *on           forevr
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
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
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
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0110 - Starting number
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1006  Invalid jobq option for view report option.
     *
     C     zm1006        begsr
     C                   eval      #msgid = 'PIR1006'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off

     *    Make sure valid department was enterd.

     C                   if        w1whdp <> '*ALL'

     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     *
     *  Verify slot/aisle
     *
     C                   if        w1whdp = '*ALL'
     C                   eval      w1slot = '*ALL'
     C                   endif

     C                   if        w1slot <> '*ALL'
     C     ' '           checkr(E) w1slot        num

     C                   select
     C                   when      %error
     C                   eval      wkaisl = *blanks
     C                   other

     C                   select
     C                   when      num = 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = desc(6)
     C                   exsr      zm1001

     C                   when      num = 1
     C                   eval      wkaisl = '  ' + %subst(w1slot:1:1)

     C                   when      num = 2
     C                   eval      wkaisl = ' ' + %subst(w1slot:1:2)

     C                   when      num = 3
     C                   eval      wkaisl = %subst(w1slot:1:3)

     C                   other
     *
     C     slotky        chain     slot2
     C                   if        not %found(slot2)
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = desc(6)
     C                   exsr      zm1001
     C                   endif

     C                   endsl

     C                   endsl

     C                   endif
     *
     *  Verify default device
     *
     C                   movel     w1dev         work1a
     C                   if        work1a = '*'  and
     C                             w1dev <> '*SYSVAL'  and
     C                             w1dev <> '*JOB'  or
     C                             w1dev = *blanks
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify default form type
     *
     C                   movel     w1form        work1a
     C                   if        work1a = '*'  and
     C                             w1form <> '*STD'  or
     C                             w1form = *blanks
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
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
     *     Prompt
     *
     C                   select
     *
     *     Warehouse code.
     *
     C                   when      row# = 8
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Initialize printer device/form
     *
     *      Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     C                   eval      wkwhse = w1whse
     *
     C                   eval      w1dev = '*JOB    '
     C                   eval      w1form = '*STD    '
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for EQUIP file.
     *
     C     itkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    slitem
     *
     C     slotky        klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    w1slot
     *
     C     slky1         klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    wkaisl
     *
     C     slky2         klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     *
     C     slky3         klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    wkaisl
     C                   kfld                    slloc
     C                   kfld                    slrlvl
     C                   kfld                    slhand
     *
     C     slky4         klist
     C                   kfld                    w1whse
     *
     C                   eval      $pstr  = 'Item Location label - options'
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm      40            $plen
     C                   eval      rptttl = $pstr
     *
     C     *loval        setll     lblfmtd
     C                   dou       %eof(lblfmtd)
     C                   read      lblfmtd
     C                   if        not %eof(lblfmtd)
     C                   if        lfdfmt = @plfmti
     C                   eval      @lblset = lfdset
     C                   leave
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
     * label type
     C                   eval      @plfmt = @plfmti
     *
     C                   eval      lblcount = *zeros
     C                   eval      $pcmd = '*LOCATE '
     *
     C                   select
     C                   when      w1whdp = '*ALL'
     C     slky4         setll     slot1
     C                   when      w1whdp <> *blanks
     C                             and wkaisl = *blanks
     C                             and w1slot <> *blanks
     C     slky3         setll     slot1
     C                   when      w1whdp <> *blanks
     C                             and wkaisl <> *blanks
     C                             and w1slot <> '*ALL'
     C     slky1         setll     slot1
     C                   when      w1whdp <> *blanks
     C                             and w1slot = '*ALL'
     C     slky2         setll     slot1
     C                   endsl

     C                   dou       %eof(slot1)

     C                   select
     C                   when      w1whdp = '*ALL'
     C     slky4         reade     slot1
     C                   when      w1whdp <> *blanks
     C                             and wkaisl = *blanks
     C                             and w1slot <> *blanks
     C     slky3         reade     slot1
     C                   when      w1whdp <> *blanks
     C                             and wkaisl <> *blanks
     C                             and w1slot <> '*ALL'
     C     slky1         reade     slot1
     C                   when      w1whdp <> *blanks
     C                             and w1slot = '*ALL'
     C     slky2         reade     slot1
     C                   endsl
     *
     C                   if        slstat <> 'A'
     C                   iter
     C                   endif

     *  Get item info

     C     itkey         chain     piritem
     C                   if        %found(piritem)
     C                   endif

     * get item brand

     C                   eval      $brand = *blanks
     C     itkey         chain     itemmsc
     C                   if        %found(itemmsc)
     C                   eval      $brand = imbrnd
     C                   endif

     C                   call      @prtpg
     C                   parm                    $pcmd             8
     C                   parm      @lblset       $plset            6
     C                   parm      @plfmti       $plfmt            8
     C                   parm      wkwhse        $pwhse            3 0
     C                   parm      *blanks       $pwhsd           30
     C                   parm      *blanks       $pwhdp            5
     C                   parm      sldisp        $pdisp           12
     C                   parm      *blanks       $pdispa           1
     C                   parm      *blanks       $pdispb          11
     C                   parm                    $pchkd1           3
     C                   parm      *blanks       $pchkd2           3
     C                   parm      *blanks       $pchkd3           3
     C                   parm      *blanks       $plcn#           15
     C                   parm      *blanks       $plcn2           15
     C                   parm      slitem        $pitm#           15
     C                   parm                    $brand
     C                   parm      itpdsc        $ppdsc           15
     C                   parm      itdesc        $pdesc           30
     C                   parm      *blanks       $ptxt1           30
     C                   parm      *blanks       $ptxt2           30
     C                   parm      *blanks       $ptxt3           30
     C                   parm      *blanks       $ptrail           8
     C                   parm      *blanks       $psize            3
     C                   parm      w1dev         $pdev            10
     C                   parm      w1form        $pform           10
     *
     C                   enddo
     *
     C                   call      @prtpg
     C                   parm      '*LOCEND '    $pcmd
     C                   parm      @lblset       $plset
     C                   parm      @plfmt        $plfmt
     C                   parm      w1whse        $pwhse
     C                   parm      *blanks       $pwhsd
     C                   parm      *blanks       $pwhdp
     C                   parm      *blanks       $pdisp
     C                   parm      *blanks       $pdispa
     C                   parm      *blanks       $pdispb
     C                   parm      *blanks       $pchkd1
     C                   parm      *blanks       $pchkd2
     C                   parm      *blanks       $pchkd3
     C                   parm      *blanks       $plcn#
     C                   parm      *blanks       $plcn2
     C                   parm      *blanks       $pitm#
     C                   parm      *blanks       $brand
     C                   parm      *blanks       $ppdsc
     C                   parm      *blanks       $pdesc
     C                   parm      *blanks       $ptxt1
     C                   parm      *blanks       $ptxt2
     C                   parm      *blanks       $ptxt3
     C                   parm      *blanks       $ptrail
     C                   parm      *blanks       $psize
     C                   parm      w1dev         $pdev
     C                   parm      w1form        $pform
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Aisle
Item not found
Quantity
Printer device
Form type
Slot
