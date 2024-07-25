417cA /copy *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TSTLICHIST   Test DRILICHIST interface
     *  25 July 2004
     *  Dave Sommerville
     *
     *  Revisions:
     *
417 A*    07/25/04  DAS  4.17
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftstlichistcf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#LICHIST
     D savever#        s                   like($lrver#)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D $prtn           s              8
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1
     D whse            s              3  0
     D w1subcmd        s                   like($drisubcmd)

     *----------------------------------------------------------------
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371

     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *----------------------------------------------------------------

     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
 1B  C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
 1E  C                   endif
     *
 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
 2E  C                   endcs
 1E  C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr

     *  Close interface

     C                   exsr      zzzclose

     C                   eval      *inlr = *on
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
 1B  C                   if        error = *on
     C                   eval      *in98 = *on
 1E  C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
 1B  C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
 1E  C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       13
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
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
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
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
 1B  C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   exsr      scr01i
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     **                   MOVE 'EOJ'     NXTSCR
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
 1B  C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
 1E  C                   endif
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
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
 1B  C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
 1E  C                   endif
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
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      *blanks       #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
     C                   if        $drisys2upd = 'D'
     C                   eval      #msgid = 'DRI0001'
     C                   else
     C                   eval      #msgid = 'DRI0002'
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *----------------------------------------------------------------

     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off

     *  If wanting to simulate call from a Dakota program,
     *    then change the first character of subcommand to a '%'.

416aMC**                 if        w1dkta = 'Y'
416aMC                   eval      %subst(w1subcmd:1:1) = '%'
416aMC**                 endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

     C                   eval      wswhse = 'N'
     C                   eval      wsltrn = 'N'
     C                   eval      wsacfl = 'N'
     C                   eval      wsnode = 'N'
     C                   eval      wstrn# = 'N'
     C                   eval      wslbl# = 'N'
     C                   eval      wslqy1 = 'N'
     C                   eval      wslqy2 = 'N'
     C                   eval      wslqy3 = 'N'
     C                   eval      wsaqy1 = 'N'
     C                   eval      wsaqy2 = 'N'
     C                   eval      wsaqy3 = 'N'
     C                   eval      wslcns = 'N'
     C                   eval      wstcod = 'N'
     C                   eval      wstara = 'N'
     C                   eval      wstwhd = 'N'
     C                   eval      wstasl = 'N'
     C                   eval      wstloc = 'N'
     C                   eval      wstlvl = 'N'
     C                   eval      wsthnd = 'N'
     C                   eval      wstslp = 'N'
     C                   eval      wstitm = 'N'
     C                   eval      wsflic = 'N'
     C                   eval      wsfcod = 'N'
     C                   eval      wsfara = 'N'
     C                   eval      wsfwhd = 'N'
     C                   eval      wsfasl = 'N'
     C                   eval      wsfloc = 'N'
     C                   eval      wsflvl = 'N'
     C                   eval      wsfhnd = 'N'
     C                   eval      wsfslp = 'N'
     C                   eval      wsfitm = 'N'

     C                   eval      w1whse = 0
     C                   eval      w1ltrn = 0
     C                   eval      w1acfl = ' '
     C                   eval      w1node = ' '
     C                   eval      w1trn# = 0
     C                   eval      w1lbl# = 0
     C                   eval      w1lqy1 = 0
     C                   eval      w1lqy2 = 0
     C                   eval      w1lqy3 = 0
     C                   eval      w1aqy1 = 0
     C                   eval      w1aqy2 = 0
     C                   eval      w1aqy3 = 0
     C                   eval      w1lcns = ' '
     C                   eval      w1tcod = ' '
     C                   eval      w1tara = ' '
     C                   eval      w1twhd = ' '
     C                   eval      w1tasl = ' '
     C                   eval      w1tloc = 0
     C                   eval      w1tlvl = 0
     C                   eval      w1thnd = ' '
     C                   eval      w1tslp = 0
     C                   eval      w1titm = ' '
     C                   eval      w1flic = ' '
     C                   eval      w1fcod = ' '
     C                   eval      w1fara = ' '
     C                   eval      w1fwhd = ' '
     C                   eval      w1fasl = ' '
     C                   eval      w1floc = 0
     C                   eval      w1flvl = 0
     C                   eval      w1fhnd = ' '
     C                   eval      w1fslp = 0
     C                   eval      w1fitm = ' '

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGET1   Get record(s) for screen 1.
     *----------------------------------------------------------------

     C     zzget1        begsr
     C     endgt1        endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

     *  Open interface

     C                   exsr      zzzopen
     C                   if        error
     C                   goto      endinz2
     C                   endif

     *   Select first screen to display.

     C                   exsr      scr01i
     C     endinz2       endsr

     *----------------------------------------------------------------
     *  ZZUPD    Update record.
     *----------------------------------------------------------------

     C     zzupd         begsr
     C                   eval      error = *off

     *  Initialize interface fields.

     C                   exsr      clr$lichist

     C                   eval      $lremp#  = w1emp#

     C                   if        wswhse = 'Y'
     C                   eval      $lrwhseu = *on
     C                   eval      $lrwhse = w1whse
     C                   endif

     C                   if        wsltrn = 'Y'
     C                   eval      $lrltrnu = *on
     C                   eval      $lrltrn = w1ltrn
     C                   endif

     C*                  if        wsacfl = 'Y'
     C*                  eval      $lracflu = *on
     C*                  eval      $lracfl = w1acfl
     C*                  endif

     C                   if        wsnode = 'Y'
     C                   eval      $lrnodeu = *on
     C                   eval      $lrnode = w1node
     C                   endif

     C                   if        wstrn# = 'Y'
     C                   eval      $lrtrn#u = *on
     C                   eval      $lrtrn# = w1trn#
     C                   endif

     C                   if        wslbl# = 'Y'
     C                   eval      $lrlbl#u = *on
     C                   eval      $lrlbl# = w1lbl#
     C                   endif

     C                   if        wslqy1 = 'Y'
     C                   eval      $lrlqy1u = *on
     C                   eval      $lrlqy1 = w1lqy1
     C                   endif

     C                   if        wslqy2 = 'Y'
     C                   eval      $lrlqy2u = *on
     C                   eval      $lrlqy2 = w1lqy2
     C                   endif

     C                   if        wslqy3 = 'Y'
     C                   eval      $lrlqy3u = *on
     C                   eval      $lrlqy3 = w1lqy3
     C                   endif

     C                   if        wsaqy1 = 'Y'
     C                   eval      $lraqy1u = *on
     C                   eval      $lraqy1 = w1aqy1
     C                   endif

     C                   if        wsaqy2 = 'Y'
     C                   eval      $lraqy2u = *on
     C                   eval      $lraqy2 = w1aqy2
     C                   endif

     C                   if        wsaqy3 = 'Y'
     C                   eval      $lraqy3u = *on
     C                   eval      $lraqy3 = w1aqy3
     C                   endif

     C                   if        wslcns = 'Y'
     C                   eval      $lrlcnsu = *on
     C                   eval      $lrlcns = w1lcns
     C                   endif

     C                   if        wstcod = 'Y'
     C                   eval      $lrtcodu = *on
     C                   eval      $lrtcod = w1tcod
     C                   endif

     C                   if        wstara = 'Y'
     C                   eval      $lrtarau = *on
     C                   eval      $lrtara = w1tara
     C                   endif

     C                   if        wstwhd = 'Y'
     C                   eval      $lrtwhdu = *on
     C                   eval      $lrtwhd = w1twhd
     C                   endif

     C                   if        wstasl = 'Y'
     C                   eval      $lrtaslu = *on
     C                   eval      $lrtasl = w1tasl
     C                   endif

     C                   if        wstloc = 'Y'
     C                   eval      $lrtlocu = *on
     C                   eval      $lrtloc = w1tloc
     C                   endif

     C                   if        wstlvl = 'Y'
     C                   eval      $lrtlvlu = *on
     C                   eval      $lrtlvl = w1tlvl
     C                   endif

     C                   if        wsthnd = 'Y'
     C                   eval      $lrthndu = *on
     C                   eval      $lrthnd = w1thnd
     C                   endif

     C                   if        wstslp = 'Y'
     C                   eval      $lrtslpu = *on
     C                   eval      $lrtslp = w1tslp
     C                   endif

     C                   if        wstitm = 'Y'
     C                   eval      $lrtitmu = *on
     C                   eval      $lrtitm = w1titm
     C                   endif

     C                   if        wsflic = 'Y'
     C                   eval      $lrflicu = *on
     C                   eval      $lrflic = w1flic
     C                   endif

     C                   if        wsfcod = 'Y'
     C                   eval      $lrfcodu = *on
     C                   eval      $lrfcod = w1fcod
     C                   endif

     C                   if        wsfara = 'Y'
     C                   eval      $lrfarau = *on
     C                   eval      $lrfara = w1fara
     C                   endif

     C                   if        wsfwhd = 'Y'
     C                   eval      $lrfwhdu = *on
     C                   eval      $lrfwhd = w1fwhd
     C                   endif

     C                   if        wsfasl = 'Y'
     C                   eval      $lrfaslu = *on
     C                   eval      $lrfasl = w1fasl
     C                   endif

     C                   if        wsfloc = 'Y'
     C                   eval      $lrflocu = *on
     C                   eval      $lrfloc = w1floc
     C                   endif

     C                   if        wsflvl = 'Y'
     C                   eval      $lrflvlu = *on
     C                   eval      $lrflvl = w1flvl
     C                   endif

     C                   if        wsfhnd = 'Y'
     C                   eval      $lrfhndu = *on
     C                   eval      $lrfhnd = w1fhnd
     C                   endif

     C                   if        wsfslp = 'Y'
     C                   eval      $lrfslpu = *on
     C                   eval      $lrfslp = w1fslp
     C                   endif

     C                   if        wsfitm = 'Y'
     C                   eval      $lrfitmu = *on
     C                   eval      $lrfitm = w1fitm
     C                   endif

     *  Set system we are calling from

     C                   eval      $drisys2upd = 'D'

     *  Update Host.

     C                   eval      $dricommand = '*LICHIST'
     C                   eval      $drisubcmd  = w1subcmd
     C                   exsr      zzzdricop

     *  Move return code to output field.

     C                   eval      w1rtn = $drireturn

     C     endupd        endsr

     *----------------------------------------------------------------
     *  clr$lichist  Initialize $lichist data structure.
     *----------------------------------------------------------------

     C     clr$lichist   begsr

     *  Initialize data structure

     C                   eval      savever# = $lrver#
     C                   clear                   $lichist
     C                   eval      $lrver# = savever#

     C                   eval      $lruser  = #user
     C                   eval      $lrpgm   = #prog
     C                   eval      $lrjob   = #job
     C                   eval      $lrjobn  = #jobn

     C                   endsr

     *----------------------------------------------------------------
     *  zzzclose     Close interface.
     *----------------------------------------------------------------

     C     zzzclose      begsr

     C                   eval      $dricommand = '*LICHIST'
     C                   eval      $drisubcmd  = '%CLOSE'

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*CLOSE'
     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $lichist      parm      $lichist      $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   exsr      zm0105

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   exsr      zm0001
     C                   exsr      zzzerrind

     C                   endsl

     C     enddricop     endsr

     *----------------------------------------------------------------
     *  zzzerrind    Set error indicators from DRI call.
     *----------------------------------------------------------------

     C     zzzerrind     begsr
     C                   endsr

     *----------------------------------------------------------------
     *  zzzopen      Open interface.
     *----------------------------------------------------------------

     C     zzzopen       begsr

     C                   eval      $dricommand = '*LICHIST'
     C                   eval      $drisubcmd  = '%OPEN'

     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C     endzzzopen    endsr
