     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
510 A*   UI318    UCI weight - print options
     *   Jeffrey  Jahnke
     *   25 February, 2007
     *
     *   Revisions
     *
     *    xx/xx/xx  xxx  x.xxa
     *
     *----------------------------------------------------------------
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
     fui318fm   cf   e             workstn
     f                                     infds(infds)
      *----------------------------------------------------------------
     d desc            s             60    dim(7) ctdata perrcd(1)
      *  Table and array definitions
      *
     d a10             s              1    dim(10)
      *----------------------------------------------------------------
      *  Program parameters
      *
     d $lparm          ds
     d  $lcmd                  1      8
     d  $lprg                  9     18
     d  $luky                 19     68
     d  $lrtn                 69     76
     d  $lerm                 77    136
     d  $lmsg                 77     80
      *
      *   redefine key
      *
     d  $lwhse                19     21  0
     d  $lwhdp                22     26
      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *
     d $mdt            ds
     d  errmsg                 1     50
     d                 ds
     d  $ec                    1      2p 0
      *----------------------------------------------------------------
      *  Message control
      *
     d #msgf           c                   const('PIRMSGF   ')
      *
     d                 ds
     d  #msgdt                 1    128
     d  $md                    1    128
     d                                     dim(128)
      *----------------------------------------------------------------
      *  Program info data structure
      *
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
      *----------------------------------------------------------------
      *  Workstation exception data structure
      *
     d infds           ds
     d  status           *status
     d  rowin                370    370
     d  colin                371    371
      *----------------------------------------------------------------
      *  Workstation exception redefinition data structure
      *
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
     d $ppo            s              9
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
     d nxtscr          s              3
     d warn            s              1
     d error           s              1
     d cmdtkn          s              1
     d $pxcp           s              1
     d $psum           s              1
     d $pjobq          s              1
     d $styp           s              1
     d work1a          s              1
      *----------------------------------------------------------------
      *  parameters
      *
      *    Input Parameters
      *      None
      *
      *    Returned Parameters
      *      $PWHSE  Warehouse
      *      $PWHDP  Department
      *      $PITEM  Item
      *      $PRTN   *EXIT    - CMD3 was entered
      *              *CANCEL  - CMD12 was entered
      *
      *----------------------------------------------------------------
      *  Let the show begin .....
      *
     c     *entry        plist
     c                   parm                    $pwhse
     c                   parm                    $ppo
     c                   parm                    $pjobq
     c                   parm                    $prtn
     c                   parm                    $pdev
     c                   parm                    $pform
      *----------------------------------------------------------------
      *  Main line
      *
     c                   move      '1'           *in97
     c                   move      '0'           *in90
     c                   move      '0'           *in91
     c                   move      '0'           error
     c                   exsr      zmcpmq
     c                   exsr      zzinz2
     c     error         ifeq      '1'
     c                   move      'EOJ'         nxtscr
     c                   end
      *
     c     nxtscr        downe     'EOJ'
     c                   exsr      dspscr
     c     nxtscr        caseq     '01 '         sc1
     c                   end
     c                   end
      *
      *   Do some clean up before leaving.
      *
     c                   exsr      zsclr
     c                   move      '1'           *inlr
      *----------------------------------------------------------------
      *  DSPSCR - Display screen
      *
     c     dspscr        begsr
      *
      *   Set On alarm indicator if error occured
      *
     c     error         ifeq      '1'
     c                   move      '1'           *in98
     c                   end
      *
      *   Overlay screen with error messages
      *
     c                   exsr      zmdmsg
      *
      *  Overlay screen with screen to be processed.
      *
     c     nxtscr        ifeq      '01 '
     c                   exfmt     screen1                              50
     c                   end
      *
      *   Initialize error indicators and fields
      *
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
      *
      *   Initialize error subfile
      *
MSG Mc                   exsr      zmcpmq
      *
     c                   endsr
      *----------------------------------------------------------------
      *
      *     Screen initialization and wrap-up routines
      *
      *----------------------------------------------------------------
      *
      *  Screen 01 initialization
      *
     c     scr01i        begsr
     c                   move      '01 '         nxtscr            3
      *
      *  get existing record.
      *
     c                   exsr      zzfil1
     c     end01i        endsr
      *----------------------------------------------------------------
      *
      *              Screen Processing Routines
      *
      *----------------------------------------------------------------
      *
      *  SC1  -  Screen 1
      *
     c     sc1           begsr
      *
      *  Test for F3 - Exit
      *
     c     *inkc         ifeq      '1'
     c                   move      '*EXIT   '    $prtn
     c                   move      'EOJ'         nxtscr
     c                   goto      endsc1
     c                   end
      *
      *  Test for F5 - Refresh
      *
     c     *inke         ifeq      '1'
     c                   exsr      scr01i
     c                   goto      endsc1
     c                   end
      *
      *  Test for F12 - Previous
      *
     c     *inkl         ifeq      '1'
     c                   move      '*CANCEL '    $prtn
     c                   move      'EOJ'         nxtscr
     c                   goto      endsc1
     c                   end
      *
      *  Test for other command keys
      *
     c                   exsr      zzcmd1
     c     cmdtkn        cabeq     *on           endsc1
      *
      *  Some other key pressed.
      *
      *     Check input and write/update record.
      *
     c                   exsr      zzchk1
     c     error         cabeq     '1'           endsc1
     c                   exsr      zznxt1
     c     endsc1        endsr
      *----------------------------------------------------------------
      *
      *          SUBROUTINES IN ALPHABETICAL ORDER
      *
      *----------------------------------------------------------------
      *
      *  *INZSR  Initialization subrotine
      *
     c     *inzsr        begsr
      *
     c     key1          klist
     c                   kfld                    w1whse
      *
      *  Initialize message handling
      *   Call user added initialization routine.
      *
     c                   exsr      zzinz
     c                   endsr
      *---------------------------------------------------------------
      *
      *    ZMCPMQ  Clear program message queue.
      *
     c     zmcpmq        begsr
     c                   move      '*CLEAR '     #msgid            7
     c                   move      '*NULL  '     #msgtp            7
     c                   exsr      zmpmsg
     c                   endsr
      *---------------------------------------------------------------
      *
      *    ZMDMSG  Display message record subfile
      *
     c     zmdmsg        begsr
     c                   move      '1'           *in97
     c                   write     msgctl
     c                   endsr
      *---------------------------------------------------------------
      *
      *    ZMPMSG  Add message record to subfile
      *
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
      *----------------------------------------------------------------
      *
      *    ZSCLR   Clear screen
      *
     c     zsclr         begsr
      *                    writeclrscr
     c                   move      *on           sclear            1
     c                   endsr
      *----------------------------------------------------------------
      *    ZMnnnn  Build and send message nnnn to this program
      *----------------------------------------------------------------
      *   PIR9905  Cursor not in correct position for lookup.
      *
     c     zm9905        begsr
     c                   move      'PIR9905'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
      *----------------------------------------------------------------
      *      0105
      *
     c     zm0105        begsr
     c                   move      'PIR0105'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
      *----------------------------------------------------------------
      *    PIR1001  Invalid option entered.
      *
     c     zm1001        begsr
     c                   move      'PIR1001'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md
     c                   exsr      zmpmsg
     c                   endsr
      *----------------------------------------------------------------
      *    PIR1006  Invalid jobq option for view report option.
      *
     c     zm1006        begsr
     c                   move      'PIR1006'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md
     c                   exsr      zmpmsg
     c                   endsr
      *----------------------------------------------------------------
      *
      *  ZZCHK1   Screen 1 error checking.
      *
     c     zzchk1        begsr
     c                   move      *off          error
      *
      *  Verify warehouse code.
      *
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
      *
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
      *
     c     endck1        endsr
      *----------------------------------------------------------------
      *
      *  ZZCMD1   User defined command keys for screen 1.
      *
     c     zzcmd1        begsr
     c                   move      '0'           cmdtkn
      *
      *  Test for F4 - Lookup
      *
     c     *inkd         ifeq      *on
     c                   move      *on           cmdtkn
     c                   z-add     0             row#
     c                   move      rowin         row
     c                   z-add     0             col#
     c                   move      colin         col
      *
      *     Warehouse
      *
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
      *
      *     Cursor not on a valid lookup field.
      *
     c                   move      *on           error
     c                   exsr      zm9905
     c                   endif
      *
     c     endcm1        endsr
      *----------------------------------------------------------------
      *
      *  ZZFIL1   Fill screen 1 fields with info from file.
      *
     c     zzfil1        begsr
      *
      *      Get warehouse for user.
      *
     c                   call      'GETWHSE'
     c                   parm                    #user
     c     w1whse        parm      0             #whse             3 0
      *
      * Get device and form
     c                   call      'GETRPT'
     c                   parm      '*DEVFORM'    $cmd
     c                   parm      'UI316PR'     $lrpt
     c                   parm      0             $whse
     c                   parm      ' '           $styp
     c                   parm      ' '           $whdp
     c                   parm                    $desc
     c                   parm                    $dev
     c                   parm                    $form

     c                   eval      w1jobq = 'N'
     c                   eval      w1dev = $dev
     c                   eval      w1form = $form
      *
     c                   endsr
      *----------------------------------------------------------------
      *
      *  ZZINZ    Extra program initialization. Called from *INZSR.
      *
     c     zzinz         begsr
      *
     c                   move      #prog         $lprg
     c                   move      #prog         #pgmq
     c                   eval      w1po = $ppo
      *
     c                   endsr
      *----------------------------------------------------------------
      *
      *  ZZINZ2   Program initialization. Called from main line.
      *
     c     zzinz2        begsr
      *
      *   Select first screen to display.
      *
     c                   exsr      scr01i
     c                   endsr
      *----------------------------------------------------------------
      *
      *  ZZNXT1   What to do next when screen 1 input is ok.
      *
     c     zznxt1        begsr
      *
     c                   move      w1whse        $pwhse
     c                   move      w1jobq        $pjobq
     c                   move      w1dev         $pdev
     c                   move      w1form        $pform
     c                   move      '*OK     '    $prtn
     c                   move      'EOJ'         nxtscr
      *
     c                   endsr
      *----------------------------------------------------------------
      *
      *  COMPILE TIME TABLES
      *
**


job queue option
printer device
form type


