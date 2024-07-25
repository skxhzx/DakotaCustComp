     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2003')
     Hoption(*srcstmt : *nodebugio)

     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  TA110     Truck Assignment 4.17
     *  31 July 2004
     *  Kenneth Elder
     *
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

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fta110fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(dspsfl:sflr)
212 AFpiruser1  if   e           k disk
     Frtehed    uf   e           k disk
     Frtehed2   uf   e           k disk
417g f                                     rename(rhrec:record)
     ftrkasign1 if   e           k disk
     f                                     prefix(t_)
     ftrkasign2 uf a e           k disk
417g f                                     rename(tarec:tarrec)
     floadtrn1  if   e           k disk
     fequip     if   e           k disk

     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     d fkey            s             50    dim(14)
     d ukey            s             50    dim(14)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D sclear          s              1
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D enter           s              5  0
     D eof             s              1
     D error           s               n
     D fillscreen      s              3
     D help            s              5  0
     D msgk            s              4  0
     D sflr            s              4  0
     D nxtscr          s              3
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sc2flg          s              1
     D warn            s              1
     D whse            s              3  0
     D #lline          s              2  0
     D zmsflag         s               n
     d*----------------------------------------------------------------
     d*  Data structure for FKEY and UKEY
     d*
     d dsfkey          ds
     d  wwhse#                 1      3  0
     d  wstat#                 4      4
     d  wtype#                 5      5
     d  wrte#                  6     10
     d  wrtid#                11     15
     d*
     d dsukey          ds
     d  wwhse                  1      3  0
     d  wstat                  4      4
     d  wtype                  5      5
     d  wrte                   6     10
     d  wrtid                 11     15

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     d $postn          ds
     d  $pocmd                 1      8
     d  $poprg                 9     18
     d  $pofky                19     68
     d  $pouky                69    118
     d  $podsc               119    307
     d  $popt1               308    322
     d  $popt2               323    335
     d  $portn               336    343
     d  $poerm               344    403
     d  $pomsg               336    339
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
411 AD  $pitpe               137    137
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
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
412 AD  erfld1                 1     20
412 AD  erfld2                21     40
412 AD  erval1                41     45
412 AD  erval2                46     50
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
     *----------------------------------------------------------------

     D curdef          s              3  0 inz(0)
     D forever         s              1    inz(*on)
     *----------------------------------------------------------------
     *  Main line
     *
     C                   exsr      init
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in95 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C*                  exsr      zzinz2
 1B  C                   if        error = *on
     C                   move      'EOJ'         nxtscr
 1E  C                   endif
     *
     c                   eval      pagcmd = '*REFRESH'
     c                   eval      nxtscr = '01'
 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
 2E  C                   endcs
 1E  C                   enddo
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
 1B  C                   if        error = *on
     C                   eval      *in98 = *on
 1E  C                   endif
     *
     *  Overl!y screen with screen to be processed.
     *
 1B  C                   if        nxtscr = '01 '
     C                   DOU       error=*off or *inkc=*on or *inkl=*on
      *
      *  write title of screen
     *
     c                   write     title
     C                   exsr      prcsf1
     c                   enddo
 1E  C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
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
     C                   move      '01 '         nxtscr
     c                   write     clr0306
     *
     c                   dou       error = *off and *inkc = *off and *inkl=*off
     C                   eval      *in91 = *on
     c                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     c                   enddo

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
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc1
 1E  C                   endif
      *
 1B  C                   if        *inkl
goto C                   goto      endsc1
 1E  C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so onto the next screen.
     *
     C     hldStatus     caseq     rollup        roll01
     C     hldStatus     caseq     rolldn        roll01
     C                   cas                     ent01
     c                   end

     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SCR02I - Display Screen 2
     *
     C     scr02i        begsr

     c                   eval      w2tkid = *blanks
     c     redo          tag
     C                   move      '02 '         nxtscr
     C                   exsr      zzfil2

     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg

     c                   exfmt     trkasgn
     c                   exsr      zmcmsg
     c                   if        *inkl = *off
     c                   exsr      sc2
     c                   endif
      *
      *  if errors exist display again for correction
      *
     c                   if        error = *on and *inkl = *off
     c                   goto      redo
     c                   endif

     c                   endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
     c                   eval      *inkl = *off
     C                   exsr      scr01i
goto C                   goto      endsc2
 1E  C                   endif
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Everything went fine so get out of program.
     *
     c                   eval      wwhse# = w2whse
     c                   eval      wrtid# = w2rtid
     c                   eval      wrte# = w2rte
     c                   eval      wstat# = rhstat
     c                   eval      wtype# = rhtype
     C                   exsr      scr01i
     C     endsc2        endsr
      *
      *  make necessary checks before allowing user to assign truck
      *
     c     zzchk2        begsr

      *
      *  Ensure valid Truck is selected
      *
     c                   eval      error = *off
     C     trkkey        chain     equip                              85
     C                   if        *in85 = *on
     c                   eval      error = *on
     c                   eval      errmsg = 'Invalid Truck selected.'
     c                   exsr      zm0105
     C                   goto      endck2
     C                   endif
      *
      *  Check for truck route combination...if so then display
      *    error...
      *
     c                   eval      error = *off
     C     trkrte        setll     trkasign1
     C     trkrte        reade     trkasign1                              85
     C                   if        *in85 = *off
     c                   eval      error = *on
     c                   eval      errmsg = 'Route already assigned to truck'
     c                   exsr      zm0105
     C                   goto      endck2
     C                   endif

      *
      *  if route is already assigned be sure no pallets have been loaded
      *
     c     trklod        setll     loadtrn1
     c     trklod        reade     loadtrn1                               85
     c                   if        *in85 = *off
     c                   eval      error = *on
     c                   eval      errmsg = 'Pallets already loaded. No Chg'
     c                   exsr      zm0105
     C                   goto      endck2
     c                   endif

      *
      *  if truck already assigned to different route show error
      *
     c     trkkey        setll     trkasign1
     c     trkkey        reade     trkasign1                              85
     c                   if        *in85 = *off and t_tatkid<>w2tkid
     c                   eval      error = *on
     c                   eval      errmsg = 'Truck already assigned'
     c                   exsr      zm0105
     C                   goto      endck2
     c                   endif

     c     endck2        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  INIT    Initialization subrotine
     *
     C     init          begsr
     *
     *  Initialize special keys
     *
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
     C*----------------------------------------------------------------
     C*
     C*  ROLL01   Screen 1 roll up/down routine
     C*
     CSR   roll01        begsr
     C*
     C*  TEST FOR ROLLUP
     C*
     C                   if        hldstatus = rollup
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT'
     C                   exsr      pag01
     C                   goto      rol01e
     C                   end
     C*
     C*  TEST FOR ROLLDOWN
     C*
     C                   if        hldstatus = rolldn
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV'
     C                   exsr      pag01
     c                   goto      rol01e
     C                   end
     C     rol01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG01    Screen 1 page routines
     C*
     C     pag01         begsr
     c*
     c*  Warehouse changed
     c*
     c                   if        w1whse <> wwhse#
     c                   eval      pagcmd = '*REFRESH'
     c                   eval      wwhse# = w1whse
     c                   eval      wstat# = ' '
     c                   eval      wtype# = ' '
     c                   eval      wrte# = ' '
     c                   eval      wrtid# = ' '
     c                   endif
     C*
     C*  NEXT PAGE
     C*
     C                   if        pagcmd = '*NEXT'
     C                   exsr      pag1fw
     C                   else
     C*
     C*  PREVIOUS PAGE
     C*
     C                   if        pagcmd = '*PREV'
     C                   exsr      pag1bk
     C                   else
     C*
     C*  TOP
     C*
     C                   if        pagcmd = '*TOP'
     C                   eval      $pocmd = '*TOP'
     C                   exsr      fgtway
     C                   eval      top = '0'
     C                   eval      bot = '0'
     C                   eval      forceb = '0'
     C                   exsr      pag1fw
     C                   else
     C*
     C*  BOTTOM
     C*
     C                   if        pagcmd = '*BOTTOM'
     C                   eval      bot = '1'
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     C*
     C*  REFRESH SCREEN
     C*
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval or fkey(1) = *blanks
     c                               or nxtscr = '01'
     c                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*TOP'
     C                   else
     C                   eval      $pocmd = '*POSTND'
     C                   eval      $pofky = fkey(1)
     C                   end
     C                   exsr      fgtway
     C                   eval      bot = '0'
     C                   exsr      pag1fw
     C                   else
     C*
     C*  REPOSITIONING
     C*
     C                   if        pagcmd = '*REPOS'
     C                   eval      bot = '0'
     C                   eval      forceb = '0'
     C                   exsr      pag1fw
     C                   end
     C                   end
     C                   end
     C                   end
     C                   end
     C                   end
     C                   move      *blanks       pagcmd            8
     C     pag01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG1FW   Let's see that next page of records
     C*
     C     pag1fw        begsr
     C*
     C*  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     C*
     C     bot           cabeq     '1'           endf
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     C                   eval      fkey = dsfkey
     C                   eval      ukey = *loval
     C                   move      '0'           bot               1
     C                   move      '0'           top               1
     C                   move      '0'           stop              1
     C                   z-add     0             p                 2 0
     C*
     C*  GET 3 RECORDS TO DISPLAY
     C*
     c                   exsr      zzclr1
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     C*
     C*  OUT OF RECORDS - INFORM USER AND SET FLAG
     C*
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = '1'
     C                   eval      bot = '1'
     C                   move      'Bottom '     MORELN            7
     C                   goto      endfwd
     C                   end
     C*
     C*  RECORD READ - STOP AFTER 3 GOOD RECORDS
     C*
     C                   eval      p = p+1
     C                   exsr      zzfil1
     C                   if        p = 3
     C                   eval      stop = '1'
     C                   if        forceb = '1'
     C                   eval      bot = '1'
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   end
     C                   end
     C     endfwd        tag
     C                   end
     C*
     C*  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     C*
     C                   z-add     p             dsplyd            2 0
     C                   eval      forceb = '0'
     C     endf          endsr
     C*----------------------------------------------------------------
     C*
     C*  PAG1BK   Let's see the previous page
     C*
     C     pag1bk        begsr
     C*
     C*  IF WE ARE AT THE TOP THEN DO NOTHING
     C*
     C     top           cabeq     '1'           endb
     C                   move      '0'           forceb            1
     C*
     C*  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     C*
     C                   select
     C                   when      #lline<>16
     C     dsplyd        add       3             goback            2 0
     C                   other
     C     dsplyd        add       14            goback
     C                   endsl
     C                   if        bot = '1'
     C                   if        goback = 3
     C                             and #lline<>16
     C                             or goback=14
     C                             and #lline<>16
     C                   eval      forceb = '1'
     C                   end
     C                   eval      $pocmd = '*BOTTOM'
     C                   exsr      fgtway
     C                   eval      goback = goback +1
     C                   end
     C*
     C*  INITIALIZE VARIABLES FOR LOOKUP
     C*
     C                   eval      p = 0
     C                   eval      top = '0'
     C                   eval      bot = '0'
     C                   eval      stop = '0'
     C*
     C*  READ SPECIFIED FLITCHES FILE
     C*
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C*
     C*  HIT TOP OF FILE
     C*
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = '1'
     C                   eval      top = '1'
     C                   goto      endbk
     C                   end
     C*
     C*  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     C*
     C                   eval      p = p+1
     C                   if        p>goback
     C                   eval      stop = '1'
     C                   end
     C     endbk         tag
     C                   end
     C*
     C* IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     C*
     C                   if        top = '1'
     C                   eval      $POCMD = '*TOP'
     C                   exsr      fgtway
     C                   end
     C                   exsr      pag1fw
     C     endb          endsr
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
     CSR   FGTWAY        begsr
     C                   eval      $portn = *blanks
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $POCMD        CASEQ     '*GETPREV'    fgetp
     C     $POCMD        CASEQ     '*POSTN1'     fpos1
     C     $POCMD        CASEQ     '*POSTN1U'    fpos1u
     C     $POCMD        CASEQ     '*TOP'        zzpos1
     C     $POCMD        CASEQ     '*BOTTOM'     zzpos1
     C                   end
     C                   endsr
     C*
     C*  FGET     Get record using file with unique key
     C*
     C*              In this case the lookup file and the unique key
     C*              file are DIFFERENT.
     C*
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79 = '1'
     C                   eval      $portn = '*NOTFND '
     C                   exsr      zzkeyi
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   end
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFGET   Get record with unique key.
     C*
     C     zzfget        begsr
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYF   Create key for file being used
     C*
     c     zzkeyf        begsr
     c                   eval      $pofky = dsfkey
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYI   Initialize keys for files being used.
     C*           Note: You must clear individual field when using
     C*                 partial keys or one of the fields is numeric.
     C*
     C     zzkeyi        begsr
     C*
     C*   Initialize unique key (DSUKEY)
     C*
     c                   eval      wwhse# = rhwhse
     c                   eval      wstat# = rhstat
     c                   eval      wtype# = rhtype
     c                   eval      wrte# = rhrte
     c                   eval      wrtid# = rhrtid
     c*
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZKEYU   Create unique key for file
     C*             (to be used in delete and change programs)
     C*
     C     zzkeyu        begsr
     c                   eval      wwhse# = rhwhse
     c                   eval      wstat# = rhstat
     c                   eval      wtype# = rhtype
     c                   eval      wrte# = rhrte
     c                   eval      wrtid# = rhrtid
     C                   eval      $pouky = DSfKEY
     c*
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZPOS1   Position to record
     C*
     C     zzpos1        begsr
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C                   if        $pocmd = '*TOP'
     C     fileky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     fileky        setll     record
     C                   end
     C                   end
     C                   endsr
      *
     c     zzpos         begsr
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FGETN    Get next record
     C*
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79 = '1' or rhstat<'1'
     c                               or rhstat>'4' or rhwhse <> w1whse
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   end
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FGETP    Get previous record
     C*
     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79 = '1' or rhstat<'1'
     c                               or rhstat>'4' or rhwhse <> w1whse
     C                   eval      $portn = '*NOMORE '
     C                   exsr      zzkeyi
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   end
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FPOS1    Position to record
     C*
     C     fpos1         begsr
     C                   eval      dsfkey = $POFKY
     C     fileky        setll     record
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  FPOS1U   Position to record using unique key
     C*
     C     fpos1u        begsr
     C*
     C*  GET RECORD FOR UNIQUE KEY
     C*
     C                   exsr      fget
     C*
     C*  POSITION TO RECORD IN LOOKUP FILE
     C*
     C                   exsr      fpos1
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
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
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
     C                   write     clr0306
     C                   move      *on           sclear
     C                   eval      $pitpe = 'X'
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
     C                   move      #msgf         $msgf
 1E  C                   endif
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
     *    PIR0105  Generic error (send to different program)
     *----------------------------------------------------------------

     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *   IT11201   Matching pattern not found
     *----------------------------------------------------------------

     C     zm1201        begsr
     C                   move      'IT11201'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C***                movea     desc          errmsg
     C***                movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   IT11212   Max var allowed is 75% with special var of 99%.
     *----------------------------------------------------------------

     C     zm1212        begsr
     C                   move      'IT11212'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
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
     *   IT11023  Warning: Entered cube not within +/- range.
     *----------------------------------------------------------------

     C     zm23          begsr
     C                   move      'IT11023'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
      *
      *  Check for invalid option entered....Only option 1 is allowed
      *    on this screen which assigns route to open truck...
      *
     C                   if        w1opt <> ' ' and %trim(w1opt) <> '1'
     C                   eval      error = *on
     C                   eval      *in32 = *on
     c                   eval      errmsg = 'F3=Exit      Invalid option. Retry'
     c                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *  Initialize interface fields.

     C                   eval      fillscreen = '01'

     C                   if        error
     C                   goto      endck1
     C                   endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZCMD2   User defined command keys for screen 2.
     *----------------------------------------------------------------

     C     zzcmd2        begsr
     C     endcm2        endsr

     *----------------------------------------------------------------
     *  ZZDFT1   Get default values for add.
     *----------------------------------------------------------------

     C     zzdft1        begsr
     C                   eval      w1opt=  *blanks
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCLR1   Clear Screen 1 subfile
     *----------------------------------------------------------------

     C     zzclr1        begsr
     c                   eval      *in01 = *off
     c                   write     dspsfc
     c                   eval      sflr = *zeros
     c                   endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

      *  load data read from rtehed2

     c                   eval      sflr = sflr + 1
     c                   eval      w1opt = *blanks
     c                   eval      w1rte = rhrte
     c                   eval      w1rtid = rhrtid
     c                   select
     c                   when      rhstat='1'
     c                   eval      w1sts='Open'
     c                   when      rhstat='2'
     c                   eval      w1sts='Allocated'
     c                   when      rhstat='3'
     c                   eval      w1sts='Built'
     c                   when      rhstat='4'
     c                   eval      w1sts='Printed'
     c                   endsl
     c                   eval      w1tkid = rhtruk
     c                   write     dspsfl

     c                   endsr

     *----------------------------------------------------------------
     *  PRCSF1   Process subfile from screen 1
     *----------------------------------------------------------------

     C     prcsf1        begsr

     *   Overlay screen with error messages
     *

     c                   exsr      pag01
     c                   write     cmdline
     c                   exsr      zmdmsg

      *  loop through processing any subfile records changed
     c                   eval      *in01 = *on
     c                   eval      wwhse# = w1whse
     c                   exfmt     dspsfc
     c                   movel     status        hldStatus         5 0
     c                   exsr      zmcmsg
      *
     c                   eval      *in01 = *off

     c                   z-add     1             sflr                     65
     C                   EVAL      error = *off
     c                   dow       sflr<4 and *inkc = *off and *inkl=*off
     c     sflr          chain     dspsfl                             65
     c                   z-add     sflr          hsflr             4 0
     c                   if        *in65 = *off and (w1opt='01' or
     c                              w1opt='1' or w1opt=' 1')
     c                   exsr      zzchk1
     c                   if        error<>*on
     c                   exsr      scr02i
     c     hsflr         chain     dspsfl                             65
     c                   if        *inkl<>*on
     c                   movel     rhtruk        w1tkid
     c                   endif
     c                   eval      w1opt = *blanks
     c  n65              update    dspsfl
     c                   endif
     c                   endif
     c                   eval      sflr=sflr+1

     c                   if        *inkl = *on
     c                   eval      nxtscr = '01 '
     c                   endif

     c                   enddo

     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ENT01    Screen 1 enter key routine
     C*
     C     ent01         begsr
     C*
     C*  VERIFY AND SAVE OPTIONS
     C*
     c                   if        not *inkc and not *inkl
     c     error         CABEQ     '1'           ent01e
     C*
     C*  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     C*
     C                   move      '0'           repos             1
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = DSFKEY
     C                   eval      $pocmd = '*POSTN1 '
     C                   exsr      FGTWAY
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   end
     C                   endif
     c*
     c*  display screen two if option 1 on one of the trucks
     c*
     c                   z-add     1             sub2              3 0
     c     sub2          chain     dspsfl                             79
     c                   dow       sub2<4
     c                   if        (w1opt='1 ' or w1opt=' 1'
     c                               or w1opt='01')
     c                   exsr      scr02i
     c                   eval      w1opt = *blanks
     c  n79              update    dspsfl
     c                   endif
     c                   eval      sub2 = sub2 + 1
     c     sub2          chain     dspsfl                             79
     c                   enddo
     c*
     C     ent01e        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFGTN   Get next record
     C*
     C     zzfgtn        begsr
     C     try1          tag
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C                   READ      record                                 79
     C*
     C     endgtn        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFGTP   Get previous record
     C*
     C     zzfgtp        begsr
     C     try2          tag
     C*
     C*    Code to use when we are not using a partial key.
     C*
     C                   readp     record                                 79
     C*
     C     endgtp        endsr

     *----------------------------------------------------------------
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil2        begsr

     c                   eval      w2rte = w1rte
     c                   eval      w2whse = w1whse
     c                   eval      w2rtid = w1rtid
     c                   eval      w2sts = w1sts

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr

      *
      *    key lists
      *

      *    route/truck key
     c     rtetrk        klist
     c                   kfld                    w2whse
     c                   kfld                    w2rtid

      *    route/truck key
     c     fileky        klist
     c                   kfld                    wwhse#
     c                   kfld                    wstat#
     c                   kfld                    wtype#
     c                   kfld                    wrte#
     c                   kfld                    wrtid#

      *    truck/route key
     c     trkrte        klist
     c                   kfld                    w2whse
     c                   kfld                    w2tkid
     c                   kfld                    w2rtid

      *    truck key
     c     trkkey        klist
     c                   kfld                    w2whse
     c                   kfld                    w2tkid

      *    truck key
     c     trklod        klist
     c                   kfld                    w2rtid

     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8

     c                   eval      w1whse = #whse
     c                   eval      wwhse# = #whse
     c                   eval      sflr = 1
     c                   write     dspsfl

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

     *  Get warehouse description.

     C                   exsr      scr01i

     C     endinz2       endsr

     *----------------------------------------------------------------
     *  ZZUPD1   Update for screen 1.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   move      *off          error
     C     endup1        endsr

     *----------------------------------------------------------------
     *  ZZUPD2   Update for screen 2.
     *----------------------------------------------------------------

     C     zzupd2        begsr

     C                   move      *off          error
     c     rtetrk        setll     trkasign2
     c     rtetrk        reade     trkasign2                              85
     c                   if        *in85 = *off
     c*  also update truck in route header
     c     rtetrk        chain     rtehed                             86
     c                   movel     w2tkid        rhtruk
     c  n86              update    rhrec
     c                   movel     w2tkid        tatkid
     c                   eval      taflag = 'A'
     c                   update    tarrec
     c                   else
     c                   eval      tawhse = w2whse
     c                   eval      tartid = w2rtid
     c                   eval      tarte = w2rte
     c                   eval      tatkid = w2tkid
     c                   eval      taflag= 'A'
     c                   write     tarrec
     c                   endif

     C     endup2        endsr
