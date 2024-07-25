     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DK110B    Dock door maint by dept/door - Display
     *  05 November 2001
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    11/05/01  DAS  4.16
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        POSITION CURSOR
     *  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  79        CHAIN INDICATOR
     *  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fdk110bfm  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
     Fdocdoor1  if   e           k disk
     F                                     rename(ddrec:record)

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
     D cmdln           s             79    dim(1) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Partial key redefinition
     *----------------------------------------------------------------

     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0

     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *----------------------------------------------------------------

     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  ddwhse                 1      3  0 inz(0)
     D  ddwhdp                 4      8
     D  dddoor                 9     11  0 inz(0)

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80

     *   Redefine key

     D  $lwhse                19     21  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D $wkof           s                   like(WKOKYF)
     D $wkou           s                   like(WKOKYU)
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
     D error           s               n
     D forceb          s              1
     D frstky          s                   like($PUKY)
     D goback          s              2  0
     D help            s              5  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D top             s              1
     D warn            s              1
     D x               s              3  0
     D y               s              3  0

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('DK112')
     D @delpg          c                   const('DK114')
     D @prtpg          c                   const('@NONE')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

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
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

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

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

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
     *     USERCODE
     *
     C     uskey         klist
     C                   kfld                    #user
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     C                   exsr      zzinz2
 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
 2E  C                   endcs
 1E  C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     *
 1B  C                   if        $rtncd = '*EXIT   '  or
     C                             $rtncd = '*CANCEL '
     C                   seton                                        lr
 1E  C                   endif
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
 1B  C                   if        error = '1'
     C                   eval      *in98 = *on
 1E  C                   endif
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
 1B  C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
 1E  C                   endif
 1B  C                   if        nxtscr = '02 '
     C                   exsr      deldsp
 1E  C                   endif
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
     C                   read      dspsfc                                 50
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
     C                   move      '01 '         nxtscr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   move      '*REFRESH'    pagcmd
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     clr0306
     C                   write     delrec
     C                   move      '*REFRESH'    pagcmd
     C                   exsr      pag02
     C                   write     cmddel
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        begsr
     C                   move      '01 '         nxtscr
     C                   eval      *in90 = *off
     C                   write     clr0306
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
 1B  C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   move      frstky        $pofky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
 2B  C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
 2X  C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
 2E  C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
 1X  C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   move      '*REPOS  '    pagcmd
     C                   exsr      pag01
 1E  C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
 1B  C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
 1E  C                   endcs
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
 1B  C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
 1E  C                   endcs
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
 1B  C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
 1E  C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR CMD3 - EXIT
     *
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $rtncd = '*EXIT   '
goto Csr                 goto      cmd01e
 1E  C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $rtncd = '*CANCEL '
goto Csr                 goto      cmd01e
 1E  C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
 1B  C                   if        *inke
     C                   exsr      clrsch
 2B  C     1             do        10            x
     C     x             chain     dspsfl                             79
 3B  C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl
 3E  C                   endif
 2E  C                   enddo
     C                   move      '*REFRESH'    pagcmd
     C                   exsr      pag01
goto Csr                 goto      cmd01e
 1E  C                   endif
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
 1B  C                   if        *inkf
     C                   exsr      inzpar
     C                   eval      $pcmd = '*ADD    '
     C                   call      @chgpg
     C                   parm                    $parms
 2B  C                   if        $prtn = '*ERROR  '
     C                   move      '1'           error
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
 2X  C                   else
 3B  C                   if        $prtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
 3X  C                   else
 4B  C                   if        $prtn <> '*CANCEL '  and
     C                             $prtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   move      '*REPOS  '    pagcmd
     C                   exsr      pag01
 4E  C                   endif
 3E  C                   endif
 2E  C                   endif
     C                   move      '*REFRESH'    pagcmd
     C                   exsr      pag01
goto Csr                 goto      cmd01e
 1E  C                   endif
     *
     *  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
 1B  C                   if        *inkj
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       10            row#
 2B  C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   move      '1'           error
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
goto Csr                 goto      cmd01e
 2E  C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       CMD01E
     C                   move      '*REPOS  '    pagcmd
     C                   exsr      pag01
goto Csr                 goto      cmd01e
 1E  C                   endif
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
 1B  C                   if        *inkr
     C                   move      '*TOP    '    pagcmd
     C                   exsr      pag01
goto Csr                 goto      cmd01e
 1E  C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
 1B  C                   if        *inks
     C                   move      '*BOTTOM '    pagcmd
     C                   exsr      pag01
goto Csr                 goto      cmd01e
 1E  C                   endif
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
 1B  C                   if        *inkl
     C                   move      '1'           cancel
     C                   exsr      scr02e
goto Csr                 goto      cmd02e
 1E  C                   endif
     C     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
 1B  C                   if        recno < 11
     C                   add       1             recno
     C                   eval      y = recno
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
 2B  C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
 2E  C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   eval      option = wkoopt
     C                   write     dspsfl
 1E  C                   endif
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
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc
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
     C     error         cabeq     '1'           ent01e
 1B  C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
goto Csr                 goto      ent01e
 1E  C                   endif
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
     C                   move      $puky         frstky
     *
     *  Delete the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   move      '0'           stop
 1B  C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
 2B  C                   if        *in79
     C                   move      '1'           stop
 2X  C                   else
     *
 3B  C                   if        wkoopt = ' 4'
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
 4B  C                   if        $prtn = '*ERROR  '
     C                   move      '1'           error
     C                   move      '1'           cancel
     C                   move      '1'           stop
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
 4X  C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
 5B  C                   if        $prtn = '*PGMQ   '
     C                   move      '1'           error
     C                   move      '1'           cancel
     C                   move      '1'           stop
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
 5X  C                   else
     *
     *     Delete canceled
     *
 6B  C                   if        $prtn = '*CANCEL '
     C                   move      '1'           cancel
     C                   move      '1'           stop
 6X  C                   else
     *
     *     Delete was successful.
     *
 7B  C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
 7E  C                   endif
 6E  C                   endif
 5E  C                   endif
 4E  C                   endif
 4B  C                   if        cancel = '0'
     C                   delete    wkorec
 4X  C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
 4E  C                   endif
 3E  C                   endif
     *
 2E  C                   endif
 1E  C                   enddo
     C                   exsr      scr02e
     C     ent02e        endsr
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
 1B  C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
 1E  C                   endcs
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
 1B  C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
 1X  C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
 1E  C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
 1B  C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
 1X  C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
 1E  C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
 1B  C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
 1X  C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
 1E  C                   endif
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
     C                   move      '0'           otaken
     *
     *     DO ALL DELETES FIRST (OPTION 4)
     *
     C     wkoprt        setll     workopt
     C                   move      '0'           stop
     C     wkoprt        reade     workopt                                79
 1B  C                   dow       not *in79  and
     C                             wkoopt <> ' 4'
     C     wkoprt        reade     workopt                                79
 1E  C                   enddo
 1B  C                   if        not *in79  and
     C                             wkoopt = ' 4'
     C                   move      '1'           otaken
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
goto Csr                 goto      optnse
 1E  C                   endif
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     C     wkoprt        setll     workopt
     C                   move      '0'           cancel
     C                   move      '0'           stop
 1B  C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
 2B  C                   if        *in79
     C                   move      '1'           stop
 2X  C                   else
 3B  C                   if        wkoopt <> '  '
     C                   move      '1'           otaken
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   move      '1'           refrsh
 4B  C                   if        error = '0'
     C                   delete    wkorec
 4E  C                   endif
 4B  C                   if        cancel = '1'
     C                   move      '1'           stop
 5B  C                   if        error = '1'
     C                   eval      wkoerr = *on
     C                   update    wkorec
 5E  C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   move      '*REPOS  '    pagcmd
     C                   exsr      pag01
     C                   move      '0'           refrsh
 4E  C                   endif
 3E  C                   endif
 2E  C                   endif
 1E  C                   enddo
 1B  C                   if        refrsh = '1'
     C                   move      '*REFRESH'    pagcmd
     C                   exsr      pag01
     C                   move      '0'           refrsh
 1E  C                   endif
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
 1B  C                   if        wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
 1X  C                   else
     *
     *   View
     *
 2B  C                   if        wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @chgpg
     C                   parm                    $parms
 2X  C                   else
     *
     *   Print
     *
 3B  C                   if        wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
 3X  C                   else
     C                   exsr      zzopt
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
     *
 1B  C                   if        $prtn = '*CANCEL '
     C                   move      '1'           cancel
 1X  C                   else
 2B  C                   if        $prtn = '*ERROR  '
     C                   move      '1'           cancel
     C                   move      '1'           error
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
 2X  C                   else
 3B  C                   if        $prtn = '*PGMQ   '
     C                   move      '1'           cancel
     C                   move      '1'           error
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         begsr
     *
     *  NEXT PAGE
     *
 1B  C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
 1X  C                   else
     *
     *  PREVIOUS PAGE
     *
 2B  C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
 2X  C                   else
     *
     *  TOP
     *
 3B  C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   move      '0'           top
     C                   move      '0'           bot
     C                   move      '0'           forceb
     C                   exsr      pag1fw
 3X  C                   else
     *
     *  BOTTOM
     *
 4B  C                   if        pagcmd = '*BOTTOM '
     C                   move      '1'           bot
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
 4X  C                   else
     *
     *  REFRESH SCREEN
     *
 5B  C                   if        pagcmd = '*REFRESH'
 6B  C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
 6X  C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
 6E  C                   endif
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   move      '0'           bot
     C                   exsr      pag1fw
 5X  C                   else
     *
     *  REPOSITIONING
     *
 6B  C                   if        pagcmd = '*REPOS  '
     C                   move      '0'           bot
     C                   move      '0'           forceb
     C                   exsr      pag1fw
 6E  C                   endif
 5E  C                   endif
 4E  C                   endif
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
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
 1B  C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
 1X  C                   else
     *
     *  PREVIOUS PAGE
     *
 2B  C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
 2X  C                   else
     *
     *  REFRESH SCREEN
     *
 3B  C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   move      '0'           bot
     C                   exsr      pag2fw
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr
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
     C                   move      '0'           bot
     C                   move      '0'           top
     C                   move      '0'           stop
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
 1B  C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
 2B  C                   if        $portn = '*NOMORE '
     C                   move      '1'           stop
     C                   move      '1'           bot
     C                   eval      moreln = 'Bottom '
goto Csr                 goto      endfac
 2E  C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
 2B  C                   if        p >= 10
     C                   move      '1'           stop
 3B  C                   if        forceb = '1'
     C                   move      '1'           bot
     C                   eval      moreln = 'Bottom '
 3X  C                   else
     C                   eval      moreln = 'More...'
 3E  C                   endif
 2E  C                   endif
     C     endfac        tag
 1E  C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   move      '0'           forceb
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
     C                   move      '0'           forceb
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C                   eval      goback = dsplyd + 10
 1B  C                   if        bot = '1'
 2B  C                   if        goback = 10
     C                   move      '1'           forceb
 2E  C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
 1E  C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   move      '0'           top
     C                   move      '0'           bot
     C                   move      '0'           stop
     *
     *  READ SPECIFIED FLITCHES FILE
     *
 1B  C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
 2B  C                   if        $portn = '*NOMORE '
     C                   move      '1'           stop
     C                   move      '1'           top
goto Csr                 goto      endbk
 2E  C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
 2B  C                   if        p >= goback
     C                   move      '1'           stop
 2E  C                   endif
     C     endbk         tag
 1E  C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
 1B  C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
 1E  C                   endif
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
     C                   move      '0'           bot
     C                   move      '0'           top
     C                   move      '0'           stop
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
 1B  C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
 2B  C                   if        *in79
     C                   move      '1'           stop
     C                   move      '1'           bot
     C                   eval      moreln = 'Bottom '
goto Csr                 goto      endfw2
 2E  C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
 2B  C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
 3B  C                   if        p >= 10
     C                   move      '1'           stop
 4B  C                   if        forceb = '1'
     C                   move      '1'           bot
     C                   eval      moreln = 'Bottom '
 4X  C                   else
     C                   eval      moreln = 'More...'
 4E  C                   endif
 3E  C                   endif
 2E  C                   endif
     C     endfw2        tag
 1E  C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   move      '0'           forceb
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
     C                   move      '0'           forceb
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C                   eval      goback = dsplyd + 10
 1B  C                   if        bot = '1'
     C     wkoprt        setgt     workopt
     C                   add       1             goback
 1E  C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   move      '0'           top
     C                   move      '0'           bot
     C                   move      '0'           stop
     *
     *  READ FILE
     *
 1B  C                   dou       stop = '1'
     C     wkoprt        readpe    workopt                                79
     *
     *  HIT TOP OF FILE
     *
 2B  C                   if        *in79
     C                   move      '1'           stop
     C                   move      '1'           top
goto Csr                 goto      endbk2
 2E  C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
 2B  C                   if        wkoopt = ' 4'
     C                   add       1             p
 3B  C                   if        p >= goback
     C                   move      '1'           stop
 3E  C                   endif
 2E  C                   endif
     C     endbk2        tag
 1E  C                   enddo
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
 1B  C                   if        top = '1'
     C     wkoprt        setll     workopt
 1E  C                   endif
     C                   exsr      pag2fw
     C     endb2         endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
 1B  C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   move      '*NEXT   '    pagcmd
     C                   exsr      pag01
goto Csr                 goto      rol01e
 1E  C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
 1B  C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   move      '*PREV   '    pagcmd
     C                   exsr      pag01
goto Csr                 goto      rol01e
 1E  C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
 1B  C                   if        status = rollup
     C                   move      '*NEXT   '    pagcmd
     C                   exsr      pag02
goto Csr                 goto      rol02e
 1E  C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
 1B  C                   if        status = rolldn
     C                   move      '*PREV   '    pagcmd
     C                   exsr      pag02
goto Csr                 goto      rol02e
 1E  C                   endif
     C     rol02e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   move      '0'           nomore
 1B  C                   dou       nomore = '1'
     C                   eval      *in21 = *off
     C                   readc     dspsfl                                 79
 2B  C                   if        *in79
     C                   eval      nomore = *on
goto Csr                 goto      enddo1
 2E  C                   endif
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
 2B  C                   if        option <> *blanks
     C                   movea     option        a2
 3B  C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
 3E  C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     C     option        lookup    zopt                                   50
 3B  C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
 3E  C                   endif
 2E  C                   endif
     *
     *  SAVE OPTION
     *
     C                   eval      y = recno
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
 2B  C                   if        not *in79
 3B  C                   if        option = *blanks
     C                   delete    wkorec
 3X  C                   else
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   update    wkorec
 3E  C                   endif
 2X  C                   else
 3B  C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   write     wkorec
 3E  C                   endif
 2E  C                   endif
     C     enddo1        tag
 1E  C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
 1B  C                   if        recno < 11
     C                   add       1             recno
     C                   eval      y = recno
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
 1E  C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in01 = *off
     C                   write     dspsfc
     C                   eval      recno = 0
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
 1B  C                   if        error <> '1'
     C     1             chain     dspsfl                             79
 2B  C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl
 2E  C                   endif
 1E  C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
 1B  C     1             do        10            x
     C     x             chain     dspsfl                             79
 2B  C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
 3B  C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
 3X  C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
 3E  C                   endif
     C                   update    dspsfl
 2E  C                   endif
 1E  C                   enddo
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
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
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
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
 1B  C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
 1E  C                   endif
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
     C                   move      *on           sclear
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif
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
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   move      'PIR0101'     #msgid
     C                   move      '*DIAG  '     #msgtp
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   move      'PIR0102'     #msgid
     C                   move      '*DIAG  '     #msgtp
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   move      'PIR0103'     #msgid
     C                   move      '*DIAG  '     #msgtp
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   move      'PIR0104'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   move      'PIR0106'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   move      'PIR0107'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   move      'PIR0108'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
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
 1B  C                   if        *inkd
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Warehouse department.
     *
 2B  C                   if        row# = 4  and
     C                             col# >= 48
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      ptinp1 = $lwhse
 3E  C                   endif
 2X  C                   else
     *
     *     Cursor not on a valid lookup field.
     *
     C                   move      '1'           error
     C                   exsr      zm9905
 2E  C                   endif
goto Csr                 goto      endcm1
 1E  C                   endif
     *
     *  Test for F9 - Display by door/dept
     *
 1B  C                   if        *inki
     C                   move      'EOJ'         nxtscr
     C                   eval      $rtncd = '*F9     '
goto Csr                 goto      endcm1
 1E  C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     C     filuky        chain     record                             79
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
     *R                   READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        reade     record                                 79
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
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    ddwhse
     C                   kfld                    ddwhdp
     C                   kfld                    dddoor
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    ddwhse
     C                   kfld                    ddwhdp
     C                   kfld                    dddoor
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    ddwhse
     *
     *  Setup option and command display lines.
     *
     C                   eval      optln1 = optln(1)
     C                   eval      cmdln1 = cmdln(1)
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     ddwhse        parm      0             #whse             3 0
     *
     *   Verify warehouse and get description.
     *
     C                   eval      whcode = ddwhse
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ddwhse
     C                   call      'WH900'
     C                   parm                    $lparm
 1B  C                   if        $lrtn = '*ERROR  '
     C                   move      '1'           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
 1X  C                   else
 2B  C                   if        $lrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
 2X  C                   else
     C                   eval      $kwhse = ddwhse
     C                   eval      whcode = ddwhse
     C                   movel     $lerm         whdesc
 2E  C                   endif
 1E  C                   endif
     *
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   endsr
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
 1B  C                   if        ptinp1 <> 0
     *
     *      Verify warehouse entry.
     *
     C                   eval      whcode = ptinp1
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
 2B  C                   if        $lrtn = '*ERROR  '
     C                   move      '1'           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
goto Csr                 goto      endzps
 2X  C                   else
 3B  C                   if        $lrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
goto Csr                 goto      endzps
 3X  C                   else
     C                   eval      ddwhse = ptinp1
     C                   eval      $kwhse = ddwhse
     C                   eval      ddwhdp = *blanks
     C                   eval      dddoor = 0
     C                   eval      whcode = ptinp1
     C                   movel     $lerm         whdesc
     C                   eval      ptinp1 = 0
     C                   move      *on           repos
 3E  C                   endif
 2E  C                   endif
 1E  C                   endif
     *
     *  See if user is trying to position to department.
     *
 1B  C                   if        ptinp2 <> ' '
     C                   eval      ddwhdp = ptinp2
     C                   eval      dddoor = 0
     C                   eval      ptinp2 = ' '
     C                   move      *on           repos
 3E  C                   endif
     *
     *  See if user is trying to position to code
     *
 1B  C                   if        ptinp3 <> 0
     C                   eval      dddoor = ptinp3
     C                   eval      ptinp3 = 0
     C                   move      *on           repos
 1E  C                   endif
     *
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
 1B  C                   if        $pocmd = '*TOP'
     C     partky        setll     record
 1X  C                   else
 2B  C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
 2E  C                   endif
 1E  C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 2 4 5
**  OPTLN - Option display line
  2=Change  4=Delete  5=View
**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F6=Create  F9=By door  F12=Cancel
