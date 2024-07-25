     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     F*
     F*  SD301     Print Check Digit Exceptions Report - Options
     F*  Randy Haselhorst
     F*  22 November, 2006
     F*
     F*  Revisions
     F*
510aAF*    11/22/06  JCJ  5.10a
     F*      - Enh: Added date prompts.  Default from and to date to
     F*             current date.
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*    This program uses a revised method to display error messages.
     F*    Instead of the program writting each message to the subfile
     F*    using the message key the subfile has been revised to display
     F*    all messages from the program message queue automatically.
     F*
     F*    All changes have been marked with MSG in position 1.
     F*
     F*    This program has been modified to use field CSRFLD which
     F*    identifies the field the cursor is located on. The only
     F*    routine that was modified was ZZCMD.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  21 - 30   Field input error (Reverse Display)
     F*  90        View mode (Protect input fields)
     F*  91        Change mode (Protect key)
     F*  97        Always ON (Used for SFLEND Keyword)
     F*  98        Error on screen (Sound buzzer)
     F*  99        Universal record indicator (Very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     fsd301fm   cf   e             workstn
     f                                     infds(infds)
     fpiruser1  if   e           k disk
     D*----------------------------------------------------------------
     d desc            s             60    dim(8) ctdata perrcd(1)
     D*  Table and array definitions
     D*
     d a10             s              1    dim(10)
510aA *----------------------------------------------------------------
510aA *  Called programs
510aA *
510aAd @cvtdt          c                   const('CVTDTE')
510aAd $cvtdt          ds
510aAd  $cvcmd                 1      8
510aAd  $cvprg                 9     18
510aAd  $cvd6i                19     24
510aAd  $cvd8i                25     32
510aAd  $cvd6o                33     38  0
510aAd  $cvd8o                39     46  0
510aAd  $cvsto                47     64
510aAd  $cvrtn                65     72
510aAd  $cverm                73    132
510aAd  $cvmsg                73     76
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
     d $lparm          ds
     d  $lcmd                  1      8
     d  $lprg                  9     18
     d  $luky                 19     68
     d  $lrtn                 69     76
     d  $lerm                 77    136
     d  $lmsg                 77     80
     D*
     D*   redefine key
     D*
     d  $lwhse                19     21  0
     d  $lwhdp                22     26
     d  $lemp                 27     31  0
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     d $mdt            ds
     d  errmsg                 1     50
     d   erdate                1      4p 0
     d   erday                 5     14
     d                 ds
     d  $ec                    1      2p 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     d #msgf           c                   const('PIRMSGF   ')
     D*
     d                 ds
     d  #msgdt                 1    128
     d  $md                    1    128
     d                                     dim(128)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
     D*----------------------------------------------------------------
     D*  Workstation exception data structure
     D*
     d infds           ds
     d  status           *status
     d  rowin                370    370
     d  colin                371    371
     D*----------------------------------------------------------------
     D*  Workstation exception redefinition data structure
     D*
     d                 ds
     d  row#                   1      2b 0
     d  row                    2      2
     d  col#                   3      4b 0
     d  col                    4      4
      * variables
      *
     d $whse           s              3  0
     d #whse           s              3  0
     d $plen           s              3  0
     d e               s              2  0
     d $pstr           s             60
     d $desc           s             50
     d $dev            s             10
     d $form           s             10
     d $pdev           s             10
     d $pform          s             10
     d $lrpt           s             10
     d $prtn           s              8
     d $cmd            s              8
510aAd $pfmdt          s              8
510aAd $ptodt          s              8
     d $pavr           s              5
     d $whdp           s              5
     d $pwhse          s              3  0
     d $dept           s              5
     d $pwhdp          s              5
     d $pemp           s              5  0
     d $item           s             15
     d nxtscr          s              3
     d warn            s              1
     d error           s              1
     d cmdtkn          s              1
     d $pxcp           s              1
     d $psum           s              1
     d $pjobq          s              1
     d $styp           s              1
     d work1a          s              1
510aAD ISODate         s               d   datfmt(*iso)
510aAD ISOTime         s               z
510aAD FmTime          s             26
510aAD ToTime          s             26
510aAd FmDate          s             10
510aAd ToDate          s             10
510aAD workdate        s              8  0
510aAD maxtime         s              8    inz('24.00.00')
     I*----------------------------------------------------------------
     C*  parameters
     C*
     C*    Input Parameters
     C*      None
     C*
     C*    Returned Parameters
     C*      $PWHSE  Warehouse
     C*      $PWHDP  Department
     C*      $EMP    Employee Number
     C*      $PRTN   *EXIT    - CMD3 was entered
     C*              *CANCEL  - CMD12 was entered
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     c     *entry        plist
     c                   parm                    $pwhse
     c                   parm                    $pwhdp
     c                   parm                    $pemp
510aAc                   parm                    $pfmdt
510aAc                   parm                    $ptodt
510aAc                   parm                    FmTime
510aAc                   parm                    ToTime
     c                   parm                    $pjobq
     c                   parm                    $prtn
     c                   parm                    $pdev
     c                   parm                    $pform
     C*----------------------------------------------------------------
     C*  Main line
     C*
     c                   eval      *in97 = *on
     c                   eval      *in90 = *off
     c                   eval      *in91 = *off
     c                   eval      error = *off
     c                   exsr      zmcpmq
     c                   exsr      zzinz2
     c     error         ifeq      '1'
     c                   move      'EOJ'         nxtscr
     c                   end
     C*
     c     nxtscr        downe     'EOJ'
     c                   exsr      dspscr
     c     nxtscr        caseq     '01 '         sc1
     c                   end
     c                   end
     C*
     C*   Do some clean up before leaving.
     C*
     c                   exsr      zsclr
     c                   move      '1'           *inlr
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     c     dspscr        begsr
     C*
     C*   Set On alarm indicator if error occured
     C*
     c     error         ifeq      '1'
     c                   move      '1'           *in98
     c                   end
     C*
     C*   Overlay screen with error messages
     C*
     c                   exsr      zmdmsg
     C*
     C*  Overlay screen with screen to be processed.
     C*
     c     nxtscr        ifeq      '01 '
     c                   exfmt     screen1                              50
     c                   end
     C*
     C*   Initialize error indicators and fields
     C*
     c                   setoff                                       212223
     c                   setoff                                       242526
     c                   setoff                                       272829
     c                   setoff                                       30
     c                   setoff                                       98
     c                   eval      *in01 = *off
     c                   eval      *in02 = *off
     c                   eval      *in03 = *off
     c                   eval      *in04 = *off
     c                   eval      *in05 = *off
     c                   eval      *in06 = *off
     c                   eval      *in07 = *off
     c                   eval      *in08 = *off
     c                   eval      *in09 = *off
     c                   eval      *in10 = *off
     c                   move      '0'           warn              1
     c                   move      '0'           error             1
     c                   move      '0'           cmdtkn            1
     c                   z-add     0             e                 2 0
     C*
     C*   Initialize error subfile
     C*
     c                   exsr      zmcpmq
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  Screen 01 initialization
     C*
     c     scr01i        begsr
     c                   move      '01 '         nxtscr            3
     C*
     C*  get existing record.
     C*
     c                   exsr      zzfil1
     c     end01i        endsr
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     c     sc1           begsr
     C*
     C*  Test for F3 - Exit
     C*
     c     *inkc         ifeq      '1'
     c                   move      '*EXIT   '    $prtn
     c                   move      'EOJ'         nxtscr
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for F5 - Refresh
     C*
     c     *inke         ifeq      '1'
     c                   exsr      scr01i
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for F12 - Previous
     C*
     c     *inkl         ifeq      '1'
     c                   move      '*CANCEL '    $prtn
     c                   move      'EOJ'         nxtscr
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for other command keys
     C*
     c                   exsr      zzcmd1
     c     cmdtkn        cabeq     *on           endsc1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     c                   exsr      zzchk1
     c     error         cabeq     '1'           endsc1
     c                   exsr      zznxt1
     c     endsc1        endsr
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     c     *inzsr        begsr
     C*
     c     key1          klist
     c                   kfld                    w1whse
     C*
     c     key2          klist
     c                   kfld                    w1whse
     c                   kfld                    w1dept
      *
     c     key3          klist
     c                   kfld                    w1whse
     c                   kfld                    w1dept
     c                   kfld                    w1emp
      *
     c                   eval      w1dept = '*ALL '
     c                   eval      w1emp = *zero
     c                   eval      w1all = '*ALL'
      *
     C*
     C*  Initialize message handling
     C*   Call user added initialization routine.
     C*
     c                   exsr      zzinz
     c                   endsr
     C*---------------------------------------------------------------
     C*
     C*    ZMCPMQ  Clear program message queue.
     C*
     c     zmcpmq        begsr
     c                   move      '*CLEAR '     #msgid            7
     c                   move      '*NULL  '     #msgtp            7
     c                   exsr      zmpmsg
     c                   endsr
     C*---------------------------------------------------------------
     C*
     C*    ZMDMSG  Display message record subfile
     C*
     c     zmdmsg        begsr
     c                   move      '1'           *in97
     c                   write     msgctl
     c                   endsr
     C*---------------------------------------------------------------
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     c     zmpmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm                    #pgmq
     c                   parm                    #msgk
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*    ZSCLR   Clear screen
     C*
     c     zsclr         begsr
     C*                    writeclrscr
     c                   move      *on           sclear            1
     c                   endsr
510aA *----------------------------------------------------------------
510aA *    ZMnnnn  Build and send message nnnn to this program
510aA *----------------------------------------------------------------
510aA *
510aA *    PIR9901  From date greater than To date.
510aA *
510aAC     zm9901        begsr
510aAC                   eval      #msgid = 'PIR9901'
510aAC                   eval      #msgtp = '*DIAG  '
510aAc                   movea     errmsg        $md(1)
510aAC                   exsr      zmpmsg
510aAC                   endsr
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR9905  Cursor not in correct position for lookup.
     C*
     c     zm9905        begsr
     c                   move      'PIR9905'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*      0105
     C*
     c     zm0105        begsr
     c                   move      'PIR0105'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*    PIR1001  Invalid option entered.
     C*
     c     zm1001        begsr
     c                   move      'PIR1001'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*    PIR1006  Invalid jobq option for view report option.
     C*
     c     zm1006        begsr
     c                   move      'PIR1006'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     c     zzchk1        begsr
     c                   move      *off          error
510aA *
510aA *  Verify From Date.
510aA *
510aAC                   eval      $cvcmd = '*MDYEDT'
510aAC                   movel     w1fmdt        $cvd6i
510aAC                   call      @cvtdt
510aAC                   parm                    $cvtdt
510aAC                   if        $cvrtn = '*PGMQ    '
510aAC                   eval      error = *on
510aAC                   eval      *in24 = *on
510aAC                   eval      *in04 = *on
510aAC                   eval      #msgk = $cvmsg
510aAC                   else
510aAC                   movel     $cvd6o        w1fmdt
510aAC                   endif
510aA *
510aA *  Verify To Date.
510aA *
510aAC                   eval      $cvcmd = '*MDYEDT'
510aAC                   movel     w1todt        $cvd6i
510aAC                   call      @cvtdt
510aAC                   parm                    $cvtdt
510aAC                   if        $cvrtn = '*PGMQ    '
510aAC                   eval      error = *on
510aAC                   eval      *in28 = *on
510aAC                   eval      *in08 = *on
510aAC                   eval      #msgk = $cvmsg
510aAC                   else
510aAC                   movel     $cvd6o        w1todt
510aAC                   endif
510aA *
510aA *  Verify From date <= To date
510aA *
510aAC                   if        *in24 = *off and
510aAC                             *in28 = *off
510aA *
510aAC                   if        w1fmdt = *zeros
510aAC                   eval      $pfmdt = *blanks
510aAC                   else
510aAC                   eval      $cvcmd = '*MDYCMD'
510aAC                   movel     w1fmdt        $cvd6i
510aAC                   call      @cvtdt
510aAC                   parm                    $cvtdt
510aAC                   movel     $cvd8O        $pfmdt
510aAC                   endif
510aA *
510aAC                   if        w1todt = *zeros
510aAC                   eval      $ptodt = *blanks
510aAC                   else
510aAC                   eval      $cvcmd = '*MDYCMD'
510aAC                   movel     w1todt        $cvd6i
510aAC                   call      @cvtdt
510aAC                   parm                    $cvtdt
510aAC                   movel     $cvd8O        $ptodt
510aAC                   endif
510aA *
510aAC                   if        w1fmdt <> *zeros and
510aAC                             w1todt <> *zeros and
510aAC                             $pfmdt  > $ptodt
510aAC                   eval      error = *on
510aAC                   eval      *in24 = *on
510aAC                   eval      *in04 = *on
510aAC                   eval      errmsg = *blanks
510aAC                   exsr      zm9901
510aAC                   endif
510aAC
510aAC                   endif
     C*
     C*  Verify warehouse code.
     C*
     c                   move      '*VERIFY '    $lcmd
     c                   z-add     w1whse        $lwhse
     c                   call      'WH900'
     c                   parm                    $lparm
     c     $lrtn         ifeq      '*ERROR  '
     c                   move      *on           error
     c                   move      *on           *in21
     c                   move      *on           *in01
     c                   movel     $lerm         errmsg
     c                   exsr      zm0105
     c                   else
     c     $lrtn         ifeq      '*PGMQ   '
     c                   move      *on           error
     c                   move      *on           *in21
     c                   move      *on           *in01
     c                   move      $lmsg         #msgk
     c                   endif
     c                   endif
     C*
     c                   if        w1emp <> *zero and
     c                             w1all <> *blanks
     c                   eval      error = *on
     c                   eval      *in23 = *on
     c                   eval      *in03 = *on
     c                   eval      errmsg = desc(8)
     c                   exsr      zm1001
     c                   endif
     C*
     c                   if        w1all <> *blanks and
     c                             w1all <> '*ALL'
     c                   eval      error = *on
     c                   eval      *in23 = *on
     c                   eval      *in03 = *on
     c                   eval      errmsg = desc(8)
     c                   exsr      zm1001
     c                   endif
     C*
     c                   if        w1emp <> *zero
     c     w1emp         chain     piruser1
     c                   if        not %found
     c                   eval      error = *on
     c                   eval      *in23 = *on
     c                   eval      *in03 = *on
     c                   eval      errmsg = desc(8)
     c                   exsr      zm1001
     c                   endif
     c                   endif
     C*
     c                   if        w1jobq <> 'Y' and
     c                             w1jobq <> 'N'
     c                   eval      error = *on
     c                   eval      *in25 = *on
     c                   eval      *in05 = *on
     c                   eval      errmsg = desc(3)
     c                   exsr      zm1001
     c                   endif

      *  Verify default device

     c                   eval      work1a = w1dev
     c                   if        work1a =  '*'       and
     c                             w1dev  <> '*SYSVAL' and
     c                             w1dev  <> '*JOB'    or
     c                             w1dev  =   *blanks  or
     c                             work1a = *blank
     c                   eval      error = *on
     c                   eval      *in26 = *on
     c                   eval      *in06 = *on
     c                   eval      errmsg = desc(4)
     c                   exsr      zm1001
     c                   endif

      *  Verify default form type

     c                   eval      work1a = w1form
     c                   if        work1a =  '*'    and
     c                             w1form <> '*STD' or
     c                             w1form =   *blanks or
     c                             work1a = *blank
     c                   eval      error = *on
     c                   eval      *in27 = *on
     c                   eval      *in07 = *on
     c                   eval      errmsg = desc(5)
     c                   exsr      zm1001
     c                   endif
     C*
     c     endck1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     c     zzcmd1        begsr
     c                   move      '0'           cmdtkn
     C*
     C*  Test for F4 - Lookup
     C*
     c     *inkd         ifeq      *on
     c                   move      *on           cmdtkn
     c                   z-add     0             row#
     c                   move      rowin         row
     c                   z-add     0             col#
     c                   move      colin         col
     C*
     C*     Warehouse
     C*
     c                   select
     c     csrfld        wheneq    'W1WHSE'
     c                   move      '*LOOKUP '    $lcmd
     c                   move      #prog         $lprg
     c                   z-add     w1whse        $lwhse
     c                   call      'WH900'
     c                   parm                    $lparm
     c     $lrtn         ifeq      '*SELECT '
     c                   z-add     $lwhse        w1whse
     c                   goto      endcm1
     c                   endif
     c                   endsl
     C*
      *     Department.

     c                   select
     c     csrfld        wheneq    'W1DEPT'
     c                   move      '*LOOKUP '    $lcmd
     c                   z-add     w1whse        $lwhse
     c                   move      w1dept        $lwhdp
     c                   call      'WD900'
     c                   parm                    $lparm
     c     $lrtn         ifeq      '*SELECT '
     c                   move      $lwhdp        w1dept
     c                   goto      endcm1
     c                   end
     C*
     c                   endsl
     C*
     C*     Cursor not on a valid lookup field.
     C*
     c                   move      *on           error
     c                   exsr      zm9905
     c                   endif
     C*
     c     endcm1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     c     zzfil1        begsr
     C*
     C*      Get warehouse for user.
     C*
     c                   call      'GETWHSE'
     c                   parm                    #user
     c     w1whse        parm      0             #whse             3 0
     C*
      * Get device and form
     c                   call      'GETRPT'
     c                   parm      '*DEVFORM'    $cmd
     c                   parm      'IV161PR'     $lrpt
     c                   parm      0             $whse
     c                   parm      ' '           $styp
     c                   parm      ' '           $whdp
     c                   parm                    $desc
     c                   parm                    $dev
     c                   parm                    $form

     c                   eval      w1jobq = 'N'
     c                   eval      w1dev = $dev
     c                   eval      w1form = $form
     C*
     c                   eval      w1dept = '*ALL '
     c                   eval      w1emp = *zero
     c                   eval      w1all = '*ALL '
     *
     *    Retrieve current date.
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1fmdt = $cvd6o
     C                   eval      w1todt = $cvd6o
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr
     C*
     c                   move      #prog         #pgmq
510aAc                   eval      $cvprg = #prog
     c                   move      #prog         $lprg
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     c     zzinz2        begsr
     C*
     C*   Select first screen to display.
     C*
     c                   exsr      scr01i
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZNXT1   What to do next when screen 1 input is ok.
     C*
     c     zznxt1        begsr
     C*
     c                   move      w1whse        $pwhse
     c                   move      w1dept        $pwhdp
     c                   move      w1emp         $pemp
     c                   move      w1jobq        $pjobq
     c                   move      w1dev         $pdev
     c                   move      w1form        $pform
     c                   move      '*OK     '    $prtn

510aAc                   move      $pfmdt        workdate
510aAc     *ISO          move      workdate      ISOdate
510aAc                   move      ISOdate       FmDate

510aAc                   move      $ptodt        workdate
510aAc     *ISO          move      workdate      ISOdate
510aAc                   move      ISOdate       ToDate

510aAc                   move      ISOTime       FmTime
510aAc                   move      ISOTime       ToTime
510aAc                   eval      FmTime = %replace(FmDate:FmTime:1:10)
510aAc                   eval      ToTime = %replace(ToDate:ToTime:1:10)
510aAc                   eval      ToTime = %replace(MaxTime:ToTime:12:8)

     c                   move      'EOJ'         nxtscr
     C*
     c                   endsr
     O*----------------------------------------------------------------
     O*
     O*  COMPILE TIME TABLES
     O*
**
Section type
print variance only option
job queue option
printer device
form type
item
Minimum variance
Employee or *ALL
