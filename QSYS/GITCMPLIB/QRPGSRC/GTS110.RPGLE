      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     F*----------------------------------------------------------------
     F*
     F*  GTS110    Global Tomcat server maintenance - display
     F*  22 February 2013
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
650  F*    02/22/13  DAS  6.50
     F*      - Created
     F*
700a F*    05/15/15  DAS  7.00
     F*      - Added 3=Copy
     F*
700b F*    08/28/15  DAS  7.00b
     F*      - Added cluster and debug.
     F*
700c F*    02/26/16  DAS  7.00c
     F*      - Revised to display a window for more parms for Cluster.
     F*      - Revised cluster to call different program.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  20        Position Cursor
     F*  21 - 29   Field Input Error (Reverse Display)
     F*  79        Chain Indicator
     F*  90        Protect Input Fields for Delete Display
     F*  97        Used by error message subfile
     F*  98        Error on screen (Sound Buzzer)
     F*  99        Universal Record Indicator (Very Temporary Usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     fgts110fm  cf   e             workstn
     f                                     infds(infds)
     f                                     sfile(dspsfl:recno)
     f                                     sfile(msgrec:msgk)
     fworkopt   uf a e           k disk
     fglotomsrv if   e           k disk
     f                                     rename(gtsrec:record)
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     d a2              s              1    dim(2)
     d a10             s              1    dim(10)
     d a75             s              1    dim(75)
     d fkey            s             50    dim(10)
     d ukey            s             50    dim(10)
     d optlst          s              2    dim(24)
     d cmdlst          s              2    dim(24)
     d zopt            s              2    dim(20) ctdata perrcd(20)
     d optln           s             75    dim(1) ctdata perrcd(1)
     d cmdln           s             79    dim(1) ctdata perrcd(1)
     D*----------------------------------------------------------------
     D*  Partial key redefinition
     D*
     d $prtky          ds
     d  $len50                 1     50
     D*----------------------------------------------------------------
     D*  Data structure for FKEY and UKEY
     D*
     d                 ds
     d  dskey                  1     50
     d  gtscode                1     10
700bAd  gtsclstr              11     11
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     d @cvtdt          c                   const('CVTDTE')
     d @chgpg          c                   const('GTS112')
     d @delpg          c                   const('GTS114')
     d @prtpg          c                   const('NONE')
     D*----------------------------------------------------------------
     D*  Variables
     D*
     d appLoc          s            100
     d pathLen         s              3  0
     D*
700bAD F3              C                   const(X'33')
700bAD F12             C                   const(X'3C')
700bAD Enter           C                   const(X'F1')
     D forever         s               n   inz(*ON)
     D*
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     d $postn          ds
     d  $pocmd                 1      8
     d  $poprg                 9     18
     d  $pofky                19     68
     d  $pouky                69    118
     d  $podsc               119    307
     d                                     dim(3)
     d  $popt1               308    322
     d  $popt2               323    335
     d  $portn               336    343
     d  $poerm               344    403
     d  $pomsg               336    339
     d $parms          ds
     d  $pcmd                  1      8
     d  $pprg                  9     18
     d  $puky                 19     68
     d  $prtn                 69     76
     d  $perm                 77    136
     d  $pmsg                 77     80
     d $cvtdt          ds
     d  $cvdop                 1      8
     d  $cvdd6                 9     14  0
     d  $cvdd8                15     22  0
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     d $mdt            ds
     d  errmsg                 1     50
     d  errcl1                 1     10
     d  errcl2                11     16
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
     D*  Workstation exception data structure
     D*
     d infds           ds
     d  status           *status
700bAD  cfkey                369    369
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

     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PRTKY  Partial key
     C*
     C*    Returned Parameters
     C*      $RTNCD  *EXIT    - CMD3 was entered
     C*              *CANCEL  - CMD12 was entered
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     c     *entry        plist
     c                   parm                    $prtky           50
     c                   parm                    $rtncd            8
     C*
     C*  Define keys
     C*
     C*     WORKOPT  (Unique key)
     C*
     c     wkounq        klist
     c                   kfld                    #user
     c                   kfld                    #prog
     c                   kfld                    wkokyf
     c                   kfld                    wkokyu
     C*
     C*     WORKOPT  (Partial key)
     C*
     c     wkoprt        klist
     c                   kfld                    #user
     c                   kfld                    #prog
     C*
     C*     WORKOPT  (Save key for top record on delete display)
     C*
     c     *like         define    wkokyf        $wkof
     c     *like         define    wkokyu        $wkou
     c     deltop        klist
     c                   kfld                    #user
     c                   kfld                    #prog
     c                   kfld                    $wkof
     c                   kfld                    $wkou
     C*----------------------------------------------------------------
     C*  Main line
     C*
      *
     c                   move      *on           *in97
     c                   move      *blanks       $rtncd
     c                   exsr      zzinz2
     c     nxtscr        downe     'EOJ'
     c                   exsr      dspscr
     c     nxtscr        caseq     '01 '         sc1
     c     nxtscr        caseq     '02 '         sc2
     c                   end
     c                   end
     C*
     C*   Do some clean up before leaving.
     C*
     c                   exsr      zsclr
     c                   exsr      clrsch
     c                   seton                                        lr
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     c     dspscr        begsr
     C*
     C*   Set ON alarm indicator if error occured
     C*
     c     error         ifeq      *on
     c                   move      *on           *in98
     c                   end
     C*
     C*   Set OFF command key indicators
     C*
     c                   setoff                                       kckekf
     c                   setoff                                       kl
     C*
     C*   Overlay screen with title
     C*
     c                   write     title
     C*
     C*   Overlay screen with error messages
     C*
     c                   exsr      zmdmsg
     C*
     C*   Overlay screen with subfile screen
     C*
     c     nxtscr        ifeq      '01 '
     c                   exsr      sfldsp
     c                   read      postnrec                               50
     c                   end
     c     nxtscr        ifeq      '02 '
     c                   exsr      deldsp
     c                   end
     C*
     C*   Initialize error indicators and fields
     C*
     c                   setoff                                       2021
     c                   setoff                                       98
     c                   move      *off          warn              1
     c                   move      *off          error             1
     c                   move      *off          cancel            1
     c                   z-add     0             e                 2 0
     C*
     C*   Initialize error subfile
     C*
     c                   exsr      zmcmsg
     C*
     c                   read      dspsfc                                 50
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
     c                   move      *loval        fkey
     c                   move      *loval        ukey
     c                   write     clr0306
     c                   move      '*REFRESH'    pagcmd
     c                   exsr      pag01
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  Screen 02 initialization
     C*
     c     scr02i        begsr
     c                   move      '02 '         nxtscr
     c                   move      *on           *in90
     c                   move      *loval        $wkof
     c                   move      *loval        $wkou
     c                   write     clr0306
     c                   write     delrec
     c                   move      '*REFRESH'    pagcmd
     c                   exsr      pag02
     c                   write     cmddel
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  Screen 02 wrap-up
     C*
     c     scr02e        begsr
     c                   move      '01 '         nxtscr
     c                   move      *off          *in90
     c                   write     clr0306
     C*
     C*   If delete was not canceled (no errors)
     C*     then reposition to record just before first deleted rec.
     C*
     c     cancel        ifeq      *off
     c                   move      '*POSTN2 '    $pocmd
     c                   move      frstky        $pofky
     c                   exsr      fgtway
     c                   move      '*GETPREV'    $pocmd
     c                   exsr      fgtway
     c     $portn        ifeq      '*NOMORE '
     c                   move      '*TOP    '    $pocmd
     c                   else
     C*
     C*   Otherwise, position to last record read.
     C*
     c                   move      '*POSTN2 '    $pocmd
     c                   end
     c                   exsr      fgtway
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   exsr      optns
     c                   else
     c                   move      '*POSTN2U'    $pocmd
     c                   move      $puky         $pouky
     c                   exsr      fgtway
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     c     sc1           begsr
     c     status        caseq     rollup        roll01
     c     status        caseq     rolldn        roll01
     c     status        caseq     comand        cmd01
     c                   cas                     ent01
     c                   end
     c     endsc1        endsr
     C*----------------------------------------------------------------
     C*
     C*  SC2  -  Screen 2
     C*
     c     sc2           begsr
     c     status        caseq     rollup        roll02
     c     status        caseq     rolldn        roll02
     c     status        caseq     comand        cmd02
     c                   cas                     ent02
     c                   end
     c     endsc2        endsr
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
     C*  Initialize special keys
     C*
700bDc**                 z-add     0             enter             5 0
     c                   z-add     2             comand            5 0
     c                   z-add     01122         rollup            5 0
     c                   z-add     01123         rolldn            5 0
     c                   z-add     01124         clear             5 0
     c                   z-add     01125         help              5 0
     C*
     C*  Initialize message handling
     C*
     c                   exsr      zmimsg
     C*
     C*  Initialize subfile (DSPSFL) record
     C*
     c                   z-add     1             recno
     c                   write     dspsfl                               79
     C*
     C*   Call user added initialization routine.
     C*
     c                   exsr      zzinz
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  CLRSCH   Clear everything out of work file
     C*
     c     clrsch        begsr
     c     wkoprt        setll     workopt
     c     wkoprt        reade     workopt                              7979
     c     *in79         doweq     *off
     c                   delete    wkorec
     c     wkoprt        reade     workopt                              7979
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  CMD01    Screen 1 command key routine
     C*
     c     cmd01         begsr
     C*
     C*  TEST FOR CMD3 - EXIT
     C*
     c     *inkc         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   move      '*EXIT   '    $rtncd
     c                   goto      cmd01e
     c                   end
     C*
     C*  TEST FOR CMD12 - PREVIOUS
     C*
     c     *inkl         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   move      '*CANCEL '    $rtncd
     c                   goto      cmd01e
     c                   end
     C*
     C*  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     C*
     C*     TEST FOR CMD5 - REFRESH
     C*
     c     *inke         ifeq      *on
     c                   exsr      clrsch
     c     1             do        10            x
     c     x             chain     dspsfl                             79
     c     *in79         ifeq      *off
     c                   move      '  '          option
     c                   update    dspsfl
     c                   end
     c                   end
     c                   move      '*REFRESH'    pagcmd
     c                   exsr      pag01
     c                   goto      cmd01e
     c                   end
     C*
     C*  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     C*
     c                   exsr      savopt
     c     error         cabeq     *on           cmd01e
     C*
     C*  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     C*
     C*  TEST FOR CMD6 - ADD RECORD
     C*
     c     *inkf         ifeq      *on
     c                   exsr      inzpar
     c                   move      '*ADD    '    $pcmd
     c                   call      @chgpg
     c                   parm                    $parms
     c     $prtn         ifeq      '*ERROR  '
     c                   move      *on           error
     c                   movel     $perm         errmsg
     c                   exsr      zm0105
     c                   else
     c     $prtn         ifeq      '*PGMQ   '
     c                   move      *on           error
     c                   move      $pmsg         #msgk
     c                   exsr      zmqmsg
     c                   else
     c     $prtn         ifne      '*CANCEL '
     c     $prtn         andne     '*EXIT   '
     c                   move      '*POSTN2U'    $pocmd
     c                   move      $puky         $pouky
     c                   exsr      fgtway
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   end
     c                   end
     c                   end
220 Ac                   move      '*REFRESH'    pagcmd
220 Ac                   exsr      pag01
     c                   goto      cmd01e
     c                   end
     C*
     C*  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     C*
     c     *inkj         ifeq      *on
     c                   z-add     0             row#
     c                   move      rowin         row
     c                   z-add     0             col#
     c                   move      colin         col
     C*
     C*     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     C*
     c                   sub       10            row#
     c     row#          iflt      1
     c     row#          orgt      dsplyd
     c                   move      *on           error
     c                   move      *blanks       errmsg
     c                   exsr      zm0106
     c                   goto      cmd01e
     c                   end
     C*
     C*     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     C*
     c                   move      '*POSTN2U'    $pocmd
     c                   move      ukey(row#)    $pouky
     c                   exsr      fgtway
     C*R         CLERR     CABEQ*ON       CMD01E
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   goto      cmd01e
     c                   end
     C*
     C*  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     C*
     c     *inkr         ifeq      *on
     c                   move      '*TOP    '    pagcmd
     c                   exsr      pag01
     c                   goto      cmd01e
     c                   end
     C*
     C*  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     C*
     c     *inks         ifeq      *on
     c                   move      '*BOTTOM '    pagcmd
     c                   exsr      pag01
     c                   goto      cmd01e
     c                   end
     C*
     C*   Process non-standard function keys.
     C*
     c                   exsr      zzcmd
     c     cmd01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  CMD02    Screen 2 command key routine
     C*
     c     cmd02         begsr
     C*
     C*  TEST FOR CMD12 - PREVIOUS
     C*
     c     *inkl         ifeq      *on
     c                   move      *on           cancel
     c                   exsr      scr02e
     c                   goto      cmd02e
     c                   end
     c     cmd02e        endsr
     C*----------------------------------------------------------------
     C*
     C*  DELADD   Add record to subfile for delete display
     C*
     c     deladd        begsr
     c     recno         iflt      11
     c                   add       1             recno
     c                   z-add     recno         y
     C*
     C*  GET RECORD INFO
     C*
     c                   move      '*GET    '    $pocmd
     c                   move      wkokyu        $pouky
     c                   exsr      fgtway
     C*R         CLERR     CABEQ*ON       DELADE
     C*
     C*  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     C*
     c     recno         ifeq      1
     c                   move      wkokyf        $wkof
     c                   move      wkokyu        $wkou
     c                   end
     C*
     C*  WRITE DISPLAY LINE TO SUBFILE
     C*
     c                   exsr      zzfill
     c                   move      wkoopt        option
     c                   write     dspsfl
     c                   end
     c     delade        endsr
     C*----------------------------------------------------------------
     C*
     C*  DELDSP   Display subfile of records marked for deletion
     C*
     c     deldsp        begsr
     C*
     C*  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     C*
     c                   write     morrec
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
     c                   move      *on           *in01
     c                   z-add     1             recno
     c                   write     dspsfc
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ENT01    Screen 1 enter key routine
     C*
     c     ent01         begsr
     C*
     C*  VERIFY AND SAVE OPTIONS
     C*
     c                   exsr      savopt
     c     error         cabeq     *on           ent01e
     C*
     C*  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     C*
     c                   move      *off          repos             1
     c                   exsr      zzpos
     c     repos         ifeq      *on
     c                   move      dskey         $pofky
     c                   move      '*POSTN2 '    $pocmd
     c                   exsr      fgtway
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   goto      ent01e
     c                   end
     C*
     C*  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     C*
     c                   exsr      optns
     C*
     C*  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     C*
     C*R         OTAKEN    IFEQ *OFF
     C*R                   MOVE 'EOJ'     NXTSCR
     C*R                   GOTO ENT01E
     C*R                   END
     c     ent01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  ENT02    Screen 2 enter key routine
     C*
     c     ent02         begsr
     C*
     C*  Save first delete key.
     C*
     c     *like         define    $puky         frstky
     c                   move      $puky         frstky
     C*
     C*  Delete the records that have been selected
     C*
     c     wkoprt        setll     workopt
     c                   move      *off          stop
     c     stop          doueq     *on
     c     wkoprt        reade     workopt                                79
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   else
     C*
     c     wkoopt        ifeq      ' 4'
     C*
     C*  Call delete program
     C*
     c                   exsr      inzpar
     c                   move      '*DELETE '    $pcmd
     c                   move      wkokyu        $puky
     c                   call      @delpg
     c                   parm                    $parms
     C*
     C*     Error occured - Error message sent back
     C*
     c     $prtn         ifeq      '*ERROR  '
     c                   move      *on           error
     c                   move      *on           cancel
     c                   move      *on           stop
     c                   movel     $perm         errmsg
     c                   exsr      zm0105
     c                   else
     C*
     C*     Error occured - Error message sent to program msgq
     C*
     c     $prtn         ifeq      '*PGMQ   '
     c                   move      *on           error
     c                   move      *on           cancel
     c                   move      *on           stop
     c                   move      $pmsg         #msgk
     c                   exsr      zmqmsg
     c                   else
     C*
     C*     Delete canceled
     C*
     c     $prtn         ifeq      '*CANCEL '
     c                   move      *on           cancel
     c                   move      *on           stop
     c                   else
     C*
     C*     Delete was successful.
     C*
     c     $prtn         ifeq      '*OK     '
     c                   move      $pmsg         #msgk
     c                   exsr      zmqmsg
     c                   end
     c                   end
     c                   end
     c                   end
     c     cancel        ifeq      *off
     c                   delete    wkorec
     c                   else
     c                   move      *on           wkoerr
     c                   update    wkorec
     c                   end
     c                   end
     C*
     c                   end
     c                   end
     c                   exsr      scr02e
     c     ent02e        endsr
     C*----------------------------------------------------------------
     C*
     C*  FGTWAY   Gateway to file handling routines
     C*
     C*    Input Parameters
     C*      $POCMD   *INIT    - Initialize and return
     C*               *GET     - Get record for $POUKY value
     C*               *GETNEXT - Get next record
     C*               *GETPREV - Get previous record
     C*               *WRITPOS - Write position record to display
     C*               *READPOS - Read position record
     C*               *POSTN2  - Position to $POFKY
     C*               *POSTN2U - Position to $POUKY
     C*               *TOP     - Position to top of file
     C*               *BOTTOM  - Position to bottom of file
     C*      $POFKY   Key for positioning within file
     C*      $POUKY   Unique key used for change/delete operations
     C*
     C*    Returned Parameters
     C*      $PORTN   *NOMORE  - Beginning/End of file was reached
     C*               *NOTFND  - Record not found on a GET
     C*               *FOUND   - Record found
     C*               *REPOS   - Repositioning took place
     C*               *ERROR   - Error occured
     C*      $POERM   Error message
     C*
     c     fgtway        begsr
     c                   move      *blanks       $portn
     c     $pocmd        caseq     '*GET    '    fget
     c     $pocmd        caseq     '*GETNEXT'    fgetn
     c     $pocmd        caseq     '*GETPREV'    fgetp
     c     $pocmd        caseq     '*POSTN2 '    fpos2
     c     $pocmd        caseq     '*POSTN2U'    fpos2u
     c     $pocmd        caseq     '*TOP'        zzpos2
     c     $pocmd        caseq     '*BOTTOM'     zzpos2
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FGET     Get record using file with unique key
     C*
     C*              In this case the lookup file and the unique key
     C*              file are the same.
     C*
     c     fget          begsr
     c                   move      $pouky        dskey
     c     fileky        chain     record                             79
     c     *in79         ifeq      *on
     c                   move      '*NOTFND '    $portn
     c                   move      *blanks       $pouky
     c                   else
     c                   move      '*FOUND  '    $portn
     c                   exsr      zzkeyf
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FGETN    Get next record
     C*
     c     fgetn         begsr
     c                   exsr      zzfgtn
     c     *in79         ifeq      *on
     c                   move      '*NOMORE '    $portn
     c                   move      *blanks       $pouky
     c                   else
     c                   move      '*FOUND  '    $portn
     c                   exsr      zzkeyf
     c                   exsr      zzkeyu
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FGETP    Get previous record
     C*
     c     fgetp         begsr
     c                   exsr      zzfgtp
     c     *in79         ifeq      *on
     c                   move      '*NOMORE '    $portn
     c                   move      *blanks       $pouky
     c                   else
     c                   move      '*FOUND  '    $portn
     c                   exsr      zzkeyf
     c                   exsr      zzkeyu
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FPOS2    Position to record
     C*
     c     fpos2         begsr
     c                   move      $pofky        dskey
     c     fileky        setll     record
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FPOS2U   Position to record using unique key
     C*
     c     fpos2u        begsr
     C*
     C*  GET RECORD FOR UNIQUE KEY
     C*
     c                   exsr      fget
     C*
     C*  POSITION TO RECORD IN LOOKUP FILE
     C*
     c                   exsr      fpos2
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  INZPAR   Initialize parameters for calling add/chg/del program
     C*
     c     inzpar        begsr
     c                   clear                   $parms
     c                   move      #prog         $pprg
     c                   move      $prtky        $puky
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  OPTNS    Perform options that user entered
     C*
     c     optns         begsr
     c                   move      *off          otaken            1
     C*
     C*     DO ALL DELETES FIRST (OPTION 4)
     C*
     c     wkoprt        setll     workopt
     c                   move      *off          stop
     c     wkoprt        reade     workopt                                79
     c     *in79         doweq     *off
     c     wkoopt        andne     ' 4'
     c     wkoprt        reade     workopt                                79
     c                   end
     c     *in79         ifeq      *off
     c     wkoopt        andeq     ' 4'
     c                   move      *on           otaken
     c                   move      wkokyu        $puky
     c                   exsr      scr02i
     c                   goto      optnse
     c                   end
     C*
     C*  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     C*     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     C*
     c     wkoprt        setll     workopt
     c                   move      *off          cancel            1
     c                   move      *off          stop              1
     c     stop          doueq     *on
     c     cancel        oreq      *on
     c     wkoprt        reade     workopt                                79
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   else
     c     wkoopt        ifne      '  '
     c                   move      *on           otaken
     c                   exsr      optns2
     c     wkounq        chain     workopt                            78
     c                   move      *on           refrsh
     c     error         ifeq      *off
     c                   delete    wkorec
     c                   end
     c     cancel        ifeq      *on
     c                   move      *on           stop
     c     error         ifeq      *on
     c                   move      *on           wkoerr
     c                   update    wkorec
     c                   end
     c                   move      '*POSTN2U'    $pocmd
     c                   move      $puky         $pouky
     c                   exsr      fgtway
     c                   move      '*REPOS  '    pagcmd
     c                   exsr      pag01
     c                   move      *off          refrsh
     c                   end
     c                   end
     c                   end
     c                   end
     c     refrsh        ifeq      *on
     c                   move      '*REFRESH'    pagcmd
     c                   exsr      pag01
     c                   move      *off          refrsh            1
     c                   end
     c     optnse        endsr
     C*----------------------------------------------------------------
     C*
     C*  OPTNS2   Execute individual options
     C*
     c     optns2        begsr
     c                   exsr      inzpar
     c                   move      wkokyu        $puky
     C*
     C*   Change
     C*
     c     wkoopt        ifeq      ' 2'
     c                   move      '*CHANGE '    $pcmd
     c                   call      @chgpg
     c                   parm                    $parms
     c                   else
     C*
     C*   View
     C*
     c     wkoopt        ifeq      ' 5'
     c                   move      '*VIEW   '    $pcmd
     c                   call      @chgpg
     c                   parm                    $parms
     c                   else
     C*
     C*   Print
     C*
     c     wkoopt        ifeq      ' 6'
     c                   move      '*PRINT  '    $pcmd
     c                   call      @prtpg
     c                   parm                    $parms
     c                   else
     c                   exsr      zzopt
     c                   end
     c                   end
     c                   end
     C*
     c     $prtn         ifeq      '*CANCEL '
     c                   move      *on           cancel
     c                   else
     c     $prtn         ifeq      '*ERROR  '
     c                   move      *on           cancel
     c                   move      *on           error
     c                   movel     $perm         errmsg
     c                   exsr      zm0105
     c                   else
     c     $prtn         ifeq      '*PGMQ   '
     c                   move      *on           cancel
     c                   move      *on           error
     c                   move      $pmsg         #msgk
     c                   exsr      zmqmsg
     c                   end
     c                   end
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG01    Screen 1 page routines
     C*
     c     pag01         begsr
     C*
     C*  NEXT PAGE
     C*
     c     pagcmd        ifeq      '*NEXT   '
     c                   exsr      pag1fw
     c                   else
     C*
     C*  PREVIOUS PAGE
     C*
     c     pagcmd        ifeq      '*PREV   '
     c                   exsr      pag1bk
     c                   else
     C*
     C*  TOP
     C*
     c     pagcmd        ifeq      '*TOP    '
     c                   move      '*TOP    '    $pocmd
     c                   exsr      fgtway
     C*R         CLERR     CABEQ*ON       PAG01E
     c                   move      *off          top
     c                   move      *off          bot
     c                   move      *off          forceb
     c                   exsr      pag1fw
     c                   else
     C*
     C*  BOTTOM
     C*
     c     pagcmd        ifeq      '*BOTTOM '
     c                   move      *on           bot
     c                   z-add     0             dsplyd
     c                   exsr      pag1bk
     c                   else
     C*
     C*  REFRESH SCREEN
     C*
     c     pagcmd        ifeq      '*REFRESH'
     c     fkey(1)       ifeq      *loval
     c                   move      '*TOP    '    $pocmd
     c                   else
     c                   move      '*POSTN2 '    $pocmd
     c                   move      fkey(1)       $pofky
     c                   end
     c                   exsr      fgtway
     C*R         CLERR     CABEQ*ON       PAG01E
     c                   move      *off          bot
     c                   exsr      pag1fw
     c                   else
     C*
     C*  REPOSITIONING
     C*
     c     pagcmd        ifeq      '*REPOS  '
     c                   move      *off          bot
     c                   move      *off          forceb
     c                   exsr      pag1fw
     c                   end
     c                   end
     c                   end
     c                   end
     c                   end
     c                   end
     c                   move      *blanks       pagcmd            8
     c     pag01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG02    Screen 2 page routines
     C*
     c     pag02         begsr
     C*
     C*  NEXT PAGE
     C*
     c     pagcmd        ifeq      '*NEXT   '
     c                   exsr      pag2fw
     c                   else
     C*
     C*  PREVIOUS PAGE
     C*
     c     pagcmd        ifeq      '*PREV   '
     c                   exsr      pag2bk
     c                   else
     C*
     C*  REFRESH SCREEN
     C*
     c     pagcmd        ifeq      '*REFRESH'
     c     deltop        setll     workopt
     c                   move      *off          bot
     c                   exsr      pag2fw
     c                   end
     c                   end
     c                   end
     c                   move      *blanks       pagcmd
     c     pag02e        endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG1FW   Let's see that next page of records
     C*
     c     pag1fw        begsr
     C*
     C*  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     C*
     c     bot           cabeq     *on           endf
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     c                   exsr      sflclr
     c                   move      *loval        fkey
     c                   move      *loval        ukey
     c                   move      *off          bot               1
     c                   move      *off          top               1
     c                   move      *off          stop              1
     c                   z-add     0             p                 2 0
     C*
     C*  GET 10 RECORDS TO DISPLAY
     C*
     c     stop          doueq     *on
     c                   move      '*GETNEXT'    $pocmd
     c                   exsr      fgtway
     C*
     C*  OUT OF RECORDS - INFORM USER AND SET FLAG
     C*
     c     $portn        ifeq      '*NOMORE '
     c                   move      *on           stop
     c                   move      *on           bot
     c                   move      'Bottom '     moreln
     c                   goto      endfrt
     c                   end
     C*
     C*  RECORD READ - STOP AFTER 10 GOOD RECORDS
     C*
     c                   add       1             p
     c                   exsr      sfladd
     c     p             ifge      10
     c                   move      *on           stop
     c     forceb        ifeq      *on
     c                   move      *on           bot
     c                   move      'Bottom '     moreln
     c                   else
     c                   move      'More...'     moreln
     c                   end
     c                   end
     c     endfrt        tag
     c                   end
     C*
     C*  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     C*
     c                   z-add     p             dsplyd            2 0
     c                   move      *off          forceb
     c     endf          endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG1BK   Let's see the previous page
     C*
     c     pag1bk        begsr
     C*
     C*  IF WE ARE AT THE TOP THEN DO NOTHING
     C*
     c     top           cabeq     *on           endb
     c                   move      *off          forceb            1
     C*
     C*  CALCULATE HOW MANY RECORDS TO GO BRTKWARDS
     C*
     c     dsplyd        add       10            gobrtk            2 0
     c     bot           ifeq      *on
     c     gobrtk        ifeq      10
     c                   move      *on           forceb
     c                   end
     c                   move      '*BOTTOM '    $pocmd
     c                   exsr      fgtway
     c                   add       1             gobrtk
     c                   end
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     c                   z-add     0             p
     c                   move      *off          top
     c                   move      *off          bot
     c                   move      *off          stop
     C*
     C*  READ SPECIFIED FLITCHES FILE
     C*
     c     stop          doueq     *on
     c                   move      '*GETPREV'    $pocmd
     c                   exsr      fgtway
     C*
     C*  HIT TOP OF FILE
     C*
     c     $portn        ifeq      '*NOMORE '
     c                   move      *on           stop
     c                   move      *on           top
     c                   goto      endbk
     c                   end
     C*
     C*  RECORD READ - STOP AFTER READING 'GOBRTK' NUMBER OF GOOD RECS
     C*
     c                   add       1             p
     c     p             ifge      gobrtk
     c                   move      *on           stop
     c                   end
     c     endbk         tag
     c                   end
     C*
     C* IF THE TOP WAS RERTHED THEN POSITION POINTER TO TOP OF FILE
     C*
     c     top           ifeq      *on
     c                   move      '*TOP    '    $pocmd
     c                   exsr      fgtway
     c                   end
     c                   exsr      pag1fw
     c     endb          endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG2FW   Let's see that next page of delete records
     C*
     c     pag2fw        begsr
     C*
     C*  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     C*
     c     bot           cabeq     *on           endf2
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     c                   exsr      sflclr
     c                   move      *loval        $wkof
     c                   move      *loval        $wkou
     c                   move      *off          bot               1
     c                   move      *off          top               1
     c                   move      *off          stop              1
     c                   z-add     0             p                 2 0
     C*
     C*  GET 10 RECORDS TO DISPLAY
     C*
     c     stop          doueq     *on
     c     wkoprt        reade     workopt                                79
     C*
     C*  OUT OF RECORDS - INFORM USER AND SET FLAG
     C*
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   move      *on           bot
     c                   move      'Bottom '     moreln
     c                   goto      endfw2
     c                   end
     C*
     C*  RECORD READ - STOP AFTER 10 GOOD RECORDS
     C*
     c     wkoopt        ifeq      ' 4'
     c                   add       1             p
     c                   exsr      deladd
     c     p             ifge      10
     c                   move      *on           stop
     c     forceb        ifeq      *on
     c                   move      *on           bot
     c                   move      'Bottom '     moreln
     c                   else
     c                   move      'More...'     moreln
     c                   end
     c                   end
     c                   end
     c     endfw2        tag
     c                   end
     C*
     C*  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     C*
     c                   z-add     p             dsplyd            2 0
     c                   move      *off          forceb
     c     endf2         endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG2BK   Let's see the previous page of delete records
     C*
     c     pag2bk        begsr
     C*
     C*  IF WE ARE AT THE TOP THEN DO NOTHING
     C*
     c     top           cabeq     *on           endb2
     c                   move      *off          forceb            1
     C*
     C*  CALCULATE HOW MANY RECORDS TO GO BRTKWARDS
     C*
     c     dsplyd        add       10            gobrtk            2 0
     c     bot           ifeq      *on
     c     wkoprt        setgt     workopt
     c                   add       1             gobrtk
     c                   end
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     c                   z-add     0             p
     c                   move      *off          top
     c                   move      *off          bot
     c                   move      *off          stop
     C*
     C*  READ SPECIFIED FLITCHES FILE
     C*
     c     stop          doueq     *on
     c     wkoprt        readpe    workopt                                79
     C*
     C*  HIT TOP OF FILE
     C*
     c     *in79         ifeq      *on
     c                   move      *on           stop
     c                   move      *on           top
     c                   goto      endbk2
     c                   end
     C*
     C*  RECORD READ - STOP AFTER READING 'GOBRTK' NUMBER OF GOOD RECS
     C*
     c     wkoopt        ifeq      ' 4'
     c                   add       1             p
     c     p             ifge      gobrtk
     c                   move      *on           stop
     c                   end
     c                   end
     c     endbk2        tag
     c                   end
     C*
     C* IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     C*
     c     top           ifeq      *on
     c     wkoprt        setll     workopt
     c                   end
     c                   exsr      pag2fw
     c     endb2         endsr
     C*----------------------------------------------------------------
     C*
     C*  ROLL01   Screen 1 roll up/down routine
     C*
     c     roll01        begsr
     C*
     C*  TEST FOR ROLLUP
     C*
     c     status        ifeq      rollup
     c                   exsr      savopt
     c     error         cabeq     *on           rol01e
     c                   move      '*NEXT   '    pagcmd
     c                   exsr      pag01
     c                   goto      rol01e
     c                   end
     C*
     C*  TEST FOR ROLLDOWN
     C*
     c     status        ifeq      rolldn
     c                   exsr      savopt
     c     error         cabeq     *on           rol01e
     c                   move      '*PREV   '    pagcmd
     c                   exsr      pag01
     c                   goto      rol01e
     c                   end
     c     rol01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  ROLL02   Screen 2 roll up/down routine
     C*
     c     roll02        begsr
     C*
     C*  TEST FOR ROLLUP
     C*
     c     status        ifeq      rollup
     c                   move      '*NEXT   '    pagcmd
     c                   exsr      pag02
     c                   goto      rol02e
     c                   end
     C*
     C*  TEST FOR ROLLDOWN
     C*
     c     status        ifeq      rolldn
     c                   move      '*PREV   '    pagcmd
     c                   exsr      pag02
     c                   goto      rol02e
     c                   end
     c     rol02e        endsr
     C*----------------------------------------------------------------
     C*
     C*  SAVOPT   Verify and save options that were entered
     C*
     c     savopt        begsr
     C*
     C*  READ ONLY THE CHANGED OPTIONS
     C*
     c                   move      *off          nomore            1
     c     nomore        doueq     *on
     c                   move      *off          *in21
     c                   readc     dspsfl                                 79
     c     *in79         ifeq      *on
     c                   move      *on           nomore
     c                   goto      enddo1
     c                   end
     C*
     C*  DISPLAY ERROR IF OPTION IS NOT VALID
     C*
     c     option        ifne      *blanks
     c                   movea     option        a2
     c     a2(2)         ifeq      ' '
     c                   move      a2(1)         a2(2)
     c                   move      ' '           a2(1)
     c                   movea     a2            option
     c                   end
     C*
     C*    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     C*
     c     option        lookup    zopt                                   50
     c     *in50         ifeq      *off
     c                   move      *on           error
     c                   move      *on           *in21
     c                   move      *blanks       errmsg
     c                   exsr      zm0108
     c                   end
     c                   end
     C*
     C*  SAVE OPTION
     C*
     c                   z-add     recno         y                 3 0
     c                   move      fkey(y)       wkokyf
     c                   move      ukey(y)       wkokyu
     c     wkounq        chain     workopt                            79
     c     *in79         ifeq      *off
     c     option        ifeq      *blanks
     c                   delete    wkorec
     c                   else
     c                   move      option        wkoopt
     c                   move      *in21         wkoerr
     c                   update    wkorec
     c                   end
     c                   else
     c     option        ifne      *blanks
     c                   move      #user         wkousr
     c                   move      #prog         wkopgm
     c                   move      fkey(y)       wkokyf
     c                   move      ukey(y)       wkokyu
     c                   move      option        wkoopt
     c                   move      *in21         wkoerr
     c                   write     wkorec
     c                   end
     c                   end
     c     enddo1        tag
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLADD   Add record to subfile
     C*
     c     sfladd        begsr
     c     recno         iflt      11
     c                   add       1             recno
     c                   z-add     recno         y
     C*
     C*  SAVE FILE AND UNIQUE KEYS
     C*
     c                   move      $pofky        fkey(y)
     c                   move      $pouky        ukey(y)
     C*
     C*  WRITE DISPLAY LINE TO SUBFILE
     C*
     c                   exsr      zzfill
     c                   write     dspsfl
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLCLR   Clear display subfile
     C*
     c     sflclr        begsr
     C*
     C*  CLEAR DISPLAY SUBFILE
     C*
     c                   move      *off          *in01
     c                   write     dspsfc
     c                   z-add     0             recno             4 0
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLDSP   Display subfile
     C*
     c     sfldsp        begsr
     C*
     C*  WRITE OPTION AND COMMAND LINES TO DISPLAY
     C*
     c                   write     optrec
     c                   write     cmdrec
     C*
     C*  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     C*
     c                   write     morrec
     C*
     C*  WRITE POSITION TO FIELD TO DISPLAY
     C*
     c                   write     postnrec
     C*
     C*  GET ANY EXISTING VALUES FOR THE OPTIONS
     C*
     c                   exsr      sflopt
     C*
     C*  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     C*
     c     error         ifne      *on
     c     1             chain     dspsfl                             79
     c     *in79         ifeq      *off
     c                   move      *on           *in20
     c                   update    dspsfl
     c                   end
     c                   end
     C*
     C*  WRITE SUBFILE TO DISPLAY
     C*
     c                   move      *on           *in01
     c                   z-add     1             recno
     c                   write     dspsfc
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SFLOPT   Initialize options for subfile
     C*
     c     sflopt        begsr
     c     1             do        10            x                 3 0
     c     x             chain     dspsfl                             79
     c     *in79         ifeq      *off
     c                   move      fkey(x)       wkokyf
     c                   move      ukey(x)       wkokyu
     c     wkounq        chain     workopt                            78
     c     *in78         ifeq      *off
     c                   move      wkoopt        option
     c                   move      wkoerr        *in21
     c                   move      wkoerr        *in20
     c                   else
     c                   move      *blanks       option
     c                   move      *off          *in21
     c                   move      *off          *in20
     c                   end
     c                   update    dspsfl
     c                   end
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMCMSG  Clear message record subfile
     C*
     c     zmcmsg        begsr
     c                   move      *off          *in97
     c                   write     msgctl
     c                   z-add     *zero         msgk              4 0
     c                   move      '*CLEAR '     #msgid            7
     c                   move      '*NULL  '     #msgtp            7
     c                   exsr      zmpmsg
     c                   endsr
     C*
     C*    ZMDMSG  Display message record subfile
     C*
     c     zmdmsg        begsr
     c                   write     msgclr
     c                   move      *on           *in97
     c     msgk          ifgt      0
     c                   write     msgctl
     c                   z-add     *zero         msgk
     c                   end
     c                   endsr
     C*
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     c     zmimsg        begsr
     c                   move      #prog         #pgmq            10
     c                   exsr      zmcmsg
     c                   endsr
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
     c                   parm      #prog         #pgmq
     c                   parm                    #msgk
     c     #msgid        ifne      '*CLEAR '
     c                   add       1             msgk
     c                   write     msgrec
     c                   end
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     C*
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     c     zmqmsg        begsr
     c                   add       1             msgk
     c                   write     msgrec
     c                   endsr
     C*
     C*    ZSCLR   Clear screen
     C*
     c     zsclr         begsr
     C*R                   WRITECLRSCR
     c                   move      *on           sclear            1
     c                   endsr
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     c     zmsmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm      '*PREV'       #pgmq
     c                   parm                    #msgk
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     C*
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*      0101  Program not found.
     C*
     c     zm0101        begsr
     c                   move      'PIR0101'     #msgid
     c                   move      '*DIAG  '     #msgtp
     C*R                   MOVE CLPRGM    ERRCL1
     C*R                   MOVE CLINFO    ERRCL2
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*      0102  Program not found.
     C*
     c     zm0102        begsr
     c                   move      'PIR0102'     #msgid
     c                   move      '*DIAG  '     #msgtp
     C*R                   MOVE CLPRGM    ERRCL1
     C*R                   MOVE CLINFO    ERRCL2
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*      0103  Program not found while exec. subroutine.
     C*
     c     zm0103        begsr
     c                   move      'PIR0103'     #msgid
     c                   move      '*DIAG  '     #msgtp
     C*R                   MOVE CLPRGM    ERRCL1
     C*R                   MOVE CLINFO    ERRCL2
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*      0104  Pressed an invalid key.
     C*
     c     zm0104        begsr
     c                   move      'PIR0104'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
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
     C*      0106  Invalid cursor position.
     C*
     c     zm0106        begsr
     c                   move      'PIR0106'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*      0107  Invalid value for "position To"
     C*
     c     zm0107        begsr
     c                   move      'PIR0107'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*      0108  Invalid Option.
     C*
     c     zm0108        begsr
     c                   move      'PIR0108'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movel     option        errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD    Process non-standard function keys
     C*
     c     zzcmd         begsr
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFGTN   Get next record
     C*
     c     zzfgtn        begsr
     c     try1          tag
     C*
     C*    Code to use when we are not using a partial key.
     C*
     c                   read      record                                 79
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     C*R         PARTKY    READERECORD                   79
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFGTP   Get previous record
     C*
     c     zzfgtp        begsr
     c     try2          tag
     C*
     C*    Code to use when we are not using a partial key.
     C*
     c                   readp     record                                 79
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     C*R         PARTKY    REDPERECORD                   79
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFILL   Fill display line with values that need
     C*           to be converted.
     C*
     c     zzfill        begsr
      /free

        w1desc = gtsdesc;

        pathLen  = %len(%trimr(gtstompath));
        select;
          when pathLen = 0 or gtsapploc = ' ';
            appLoc = gtstompath;
          when %subst(gtstompath: pathLen: 1) = '/';
            appLoc = %trimr(gtstompath) + gtsapploc;
         when %subst(gtstompath: pathLen: 1) <> '/';
            appLoc = %trimr(gtstompath) + '/' + gtsapploc;
        endsl;

        pathLen  = %len(%trimr(appLoc));
        if pathLen > 21;
          w1tompath = '..' + %subst(appLoc: pathLen-18: 19);
        else;
          w1tompath = appLoc;
        endif;

        pathLen  = %len(%trimr(gtsjdkpath));
        if pathLen > 10;
          w1jdkpath = '..' + %subst(gtsjdkpath: pathLen-7: 8);
        else;
          w1jdkpath = gtsjdkpath;
        endif;

      /end-free
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr
     C*
     C*  Define full key for main file.
     C*
     c     fileky        klist
     c                   kfld                    gtscode
     C*
     C*  Define partial key for main file (if needed).
     C*
     C*R         PARTKY    KLIST
     C*
     C*  Setup option and command display lines.
     C*
     c                   move      optln(1)      optln1
     c                   move      cmdln(1)      cmdln1
     C*
     c                   move      #prog         $pprg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Extra program initialization. Called from *INZSR.
     C*
     c     zzinz2        begsr
     c                   exsr      clrsch
     c                   exsr      scr01i
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYF   Create key for file being used
     C*
     c     zzkeyf        begsr
     c                   move      dskey         $pofky
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYU   Create unique key for file
     C*             (to be used in delete and change programs)
     C*
     c     zzkeyu        begsr
     c                   move      dskey         $pouky
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZOPT    Process non-standard options.
     C*              Note: Error handling is done in routine OPTNS2.
     C*
     c     zzopt         begsr

     C                   eval      dskey = $puky

     C                   select

700aA*   Copy
700aA
700aAC                   when      wkoopt = ' 3'
700aAC                   eval      $pcmd = '*COPY'
700aAC                   call      @chgpg
700aAC                   parm                    $parms

700bA*   Call different routine when dealing with a cluster
700bA
700baC                   when      gtsclstr = 'Y'
700baC                   exsr      zzoptcluster

     *   Start server

     C                   when      wkoopt = ' S'
     C                   call      'BFCTOMCAT2'
     C                   parm      '*START'      tCmd             10
     C                   parm                    gtscode

     *   Start server Interactively

     C                   when      wkoopt = 'SI'
     C                   call      'BFCTOMCATQ'
     C                   parm      '*START'      tCmd
     C                   parm                    gtscode

     *   Stop server

     C                   when      wkoopt = ' X'
     C                   call      'BFCTOMCAT2'
     C                   parm      '*END'        tCmd             10
     C                   parm                    gtscode

     *   Stop server Interactively

     C                   when      wkoopt = 'XI'
     C                   call      'BFCTOMCATQ'
     C                   parm      '*END'        tCmd
     C                   parm                    gtscode

     C                   endsl

     c                   endsr
700bAC*----------------------------------------------------------------
700bAC*
700bAC*  ZZOPTCLUSTER    Process non-standard options for cluster.
700bAC*
700bAc     zzoptcluster  begsr

     *   First get extra options

      /free

         *in21 = *off;
         *in22 = *off;
         *in23 = *off;
         w2start = 1;
         w2nbr = 1;
         w2apache = 'N';

         dow forever = forever;

           exfmt window1;

           *in21 = *off;
           *in22 = *off;
           *in23 = *off;

           if cfkey = F3 or cfkey = F12;
             leavesr;
           endif;

           if cfkey <> Enter;
             iter;
           endif;

           if w2start = 0 and w2apache <>'Y';
             *in21 = *on;
             *in23 = *on;
             iter;
           endif;

           if w2start < 0 or w2start > 20;
             *in21 = *on;
             iter;
           endif;

           if w2start > 0 and (w2nbr < 1 or w2nbr > 20);
             *in22 = *on;
             iter;
           endif;

           if w2apache <> 'Y' and w2apache <> 'N';
             *in23 = *on;
             iter;
           endif;

           leave;

         enddo;

      /end-free

     *   Then call appropriate program

     C                   select

     *   Start server

     C                   when      wkoopt = ' S'
     C                   call      'BFCCLUSTR2'
     C                   parm      '*START'      tCmd             10
     C                   parm                    gtscode
     C                   parm                    w2start
     C                   parm                    w2nbr
     C                   parm                    w2apache
     C                   parm      'Y'           tJobq             1

     *   Start server Interactively

     C                   when      wkoopt = 'SI'
     C                   call      'BFCCLUSTR2'
     C                   parm      '*START'      tCmd
     C                   parm                    gtscode
     C                   parm                    w2start
     C                   parm                    w2nbr
     C                   parm                    w2apache
     C                   parm      'N'           tJobq

     *   Stop server

     C                   when      wkoopt = ' X'
     C                   call      'BFCCLUSTR2'
     C                   parm      '*END'        tCmd             10
     C                   parm                    gtscode
     C                   parm                    w2start
     C                   parm                    w2nbr
     C                   parm                    w2apache
     C                   parm      'Y'           tJobq             1

     *   Stop server Interactively

     C                   when      wkoopt = 'XI'
     C                   call      'BFCCLUSTR2'
     C                   parm      '*END'        tCmd
     C                   parm                    gtscode
     C                   parm                    w2start
     C                   parm                    w2nbr
     C                   parm                    w2apache
     C                   parm      'N'           tJobq

     C                   endsl

     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS    Position to a different record.
     C*
     c     zzpos         begsr
     C*
     C*  See if user is trying to position to a certain spot
     C*
     c     gtsinp1       ifne      *blanks
     c                   move      gtsinp1       gtscode
     c                   move      *blanks       gtsinp1
     c                   move      *on           repos
     c                   end
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS2   Position to record
     C*
     c     zzpos2        begsr
     C*
     C*    Code to use when we are not using a partial key.
     C*
     c     $pocmd        ifeq      '*TOP'
     c     *loval        setll     record
     c                   else
     c     $pocmd        ifeq      '*BOTTOM'
     c     *hival        setll     record
     c                   end
     c                   end
     C*
     C*    Code to use when we do have a partial key to use.
     C*
     C*R         $POCMD    IFEQ '*TOP'
     C*R         PARTKY    SETLLRECORD
     C*R                   ELSE
     C*R         $POCMD    IFEQ '*BOTTOM'
     C*R         PARTKY    SETGTRECORD
     C*R                   END
     C*R                   END
     c                   endsr
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**  ZOPT - Valid options
 2 3 4 5 S XSIXI
**  OPTLN - Option display line
  2=Change  3=Copy  4=Delete  5=View  S=Start  X=Stop
**  CMDLN - Command display line
F3=Exit  F5=Refresh  F6=Create  F12=Cancel
