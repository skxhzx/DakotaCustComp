     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     F*
     F*  UI312     Print UCI exceptions - Options
     F*  Randy Haselhorst
     F*  11 September, 2006
     F*
     F*  Revisions
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
     fui312fm   cf   e             workstn
     f                                     infds(infds)
MSG DF*                                       msgk  ksfile msgrec
     fpiritem1  if   e           k disk
     D*----------------------------------------------------------------
     d desc            s             60    dim(7) ctdata perrcd(1)
     D*  Table and array definitions
     D*
     d a10             s              1    dim(10)
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
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     d $mdt            ds
     d  errmsg                 1     50
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
     d $pavr           s              5
     d $whdp           s              5
     d $pwhse          s              3  0
     d $dept           s              5
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
     I*----------------------------------------------------------------
     C*  parameters
     C*
     C*    Input Parameters
     C*      None
     C*
     C*    Returned Parameters
     C*      $PWHSE  Warehouse
     C*      $PWHDP  Department
     C*      $PITEM  Item
     C*      $PRTN   *EXIT    - CMD3 was entered
     C*              *CANCEL  - CMD12 was entered
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     c     *entry        plist
     c                   parm                    $pwhse
     c                   parm                    $pwhdp            5
     c                   parm                    $pitem           15
     c                   parm                    $pjobq
     c                   parm                    $prtn
     c                   parm                    $pdev
     c                   parm                    $pform
     C*----------------------------------------------------------------
     C*  Main line
     C*
     c                   move      '1'           *in97
     c                   move      '0'           *in90
     c                   move      '0'           *in91
     c                   move      '0'           error
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
MSG DC*                    exsr zmcmsg
MSG Mc                   exsr      zmcpmq
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
     c                   kfld                    w1item
      *
     c                   movel     '*ALL'        w1dept
     c                   movel     '*ALL'        w1item
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
     c     w1dept        ifne      '*ALL'
     c     w1item        andne     '*ALL'
     c     key3          chain     piritem1                           80
     c     *in80         ifeq      *on
     c                   move      *on           error
     c                   movea     '11'          *in(22)
     c                   movea     '11'          *in(02)
     c                   move      'PIR9912'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endif
     c                   else
     c     w1dept        ifne      '*ALL'
     c     key2          chain     piritem1                           80
     c     *in80         ifeq      *on
     c                   move      *on           error
     c                   move      *on           *in22
     c                   move      *on           *in02
     c                   move      'PIR9911'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endif
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
     c                   eval      w1item = '*ALL '
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr
     C*
     c                   move      #prog         $lprg
     c                   move      #prog         #pgmq
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
     c                   move      w1item        $pitem
     c                   move      w1jobq        $pjobq
     c                   move      w1dev         $pdev
     c                   move      w1form        $pform
     c                   move      '*OK     '    $prtn
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
