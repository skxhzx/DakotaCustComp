     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')
     H Option(*NODEBUGIO)

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  IT262     RF Will Call Transfer
     *  08 May 2002
     *  Max Blacknik
     *
     *  Notes
     *       16 X 20 Screens for hand held scanners
     *
     *  Revisions
     *
416 A*    05/08/02  MLB  4.16
     *      - Created.
416aA*    07/19/02  MLB  4.16a
     *      - Fix: Changed size of AVAILQTY, CHECKQTY to 9,0 from 5,0.
416bA*    07/30/02  MLB  4.16b
     *      - ENH: Added support to screen 3 to allow F4=Prompt to be
     *        used to allow selection of new pick slot. SC3,ZZCMD3 chg'd.
     *      - Fix: Revised ZZTFWC, ZZUPD4 to update will call transfer
     *        slot with expiration date.
416cA*    07/17/02  DAS  4.16c
     *      - Revised ZZUPD4 routine to call zzadjqy before updating
     *        slot record.
416eA*    09/04/02  MLB  4.16e
     *      - Fix: Added code to ZZADJQY to make sure break down qty's
     *        are greater than or equal to zero.
416eA*    10/23/02  RH   4.16f
     *      - Fix: Added code to adjust ITEMQTY for inactive qty.
417aAF*    04/03/03  RH   4.17a
     F*      - Recompiled, ITEMMSC file changed.
417bAF*    08/11/04  RH   4.17b
     F*      - Fix: Revised to call GETSLOTITM, if the item was an
     F*        alias item for a SSB item, GETBASE would return the SSB
     F*        item which is not a slot item.
640aA*    06/07/12  LMC  6.40a
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  51        F12=Cancel available on screen 2.
     * N51        F10=Finish available on screen 2.
     *  52        Display breakdown qty 1 on screen 4.
     *  53        Display breakdown qty 2 on screen 4.
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fit262fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fitemdef   if   e           k disk
     Funmesr    if   e           k disk
     Fpiritem   if   e           k disk
     Fpirtran   uf a e           k disk
     Fpirtran1  if   e           k disk
     F                                     rename(ptrec:ptrec1)
     Fpirtran2  if   e           k disk
     F                                     rename(ptrec:ptrec2)
     Fpirtran3  if   e           k disk
     F                                     rename(ptrec:ptrec3)
     Foptions   if   e           k disk
     Fitemmsc   if   e           k disk
     Fslot1     uf a e           k disk
     F                                     rename(slrec:slrec1)
     Fslot2     uf   e           k disk
     F                                     rename(slrec:slrec2)
     Fslot4     uf   e           k disk
     F                                     rename(slrec:slrec4)
     Ftask      if   e           k disk
     Fvslot1    if   e           k disk
     Fitmexcp   o    e           k disk
     FLabel     o    e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D cmdln           s             19    dim(2) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Working variables
     *
     *
416aDD*availqty        s                   like(avail1)
416aMD availqty        s              9  0
     D brkdwn1         s              4    inz('*NO ')
     D brkdwn2         s              4    inz('*NO ')
416aDD*checkqty        s                   like(avail1)
416aMD checkqty        s              9  0
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D curent          s              1    inz(*off)
     D curtrn          s                   like(lbtrn#)
     D                                     inz(*zeros)
     D curtsk          s                   like(tkcode)
     D                                     inz(*blanks)
     D curtyp          s                   like(tktype)
     D                                     inz(*blanks)
     D dummy           s              5  0
     D e               s              3  0
     D enter           s              5  0
     D eof             s              1
     D errflg          s              1
     D error           s              1
     D excpflg         s              1    inz('0')
     D fintim          s                   like(PTSTIM)
     D fmdisp          s                   like(lbdisp)
     D fmitem          s                   like(lbitem)
     D forevr          s              1    inz('1')
     D found           s              1    inz('1')
     D help            s              5  0
     D kyaisl          s                   like(slaisl)
     D kycode          s                   like(opcode)
     D kydisp          s                   like(sldisp)
     D kystat          s                   like(ptstat)
     D kytrn#          s                   like(pttrn#)
     D $msgf           s             10
     D #msgid          s              7
     D msgk            s              4  0
     D #msgtp          s              7
     D newtrn          s              4    inz('*YES')
     D nxtscr          s              3
     D ocode           s              8
     D ovrrid          s              1
     D #pgmq           s             10
     D redspl          s              1    inz('0')
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D rtnto           s              3
     D sclear          s              1
     D slotfnd         s              4
     D ssbflg          s              1    inz('0')
     D stdate          s                   like(ptsdte)
     D strtim          s                   like(PTSTIM)
     D sttime          s                   like(ptstim)
     D stop            s              1
     D svavl1          s                   like(avail1)
     D                                     inz(0)
     D svavl2          s                   like(avail2)
     D                                     inz(0)
     D svavl3          s                   like(avail3)
     D                                     inz(0)
416bAD svexpd          s                   like(slexpd)
     D svtask          s                   like(pttask)
     D svtlen          s                   like(ptdmin)
     D svtrn#          s                   like(pttrn#)
     D timlen          s                   like(PTDMIN)
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D tmploc          s                   like(slloc)
     D today           s              8  0
     D todisp          s                   like(sldisp)
     D toitem          s                   like(lbitem)
     D totpcs          s              5  0 inz(0)
     D towhdp          s                   like(lbwhdp)
     D t#task          s                   like(tkcode)
     D updslot         s                   like(sldisp)
     D vrtslt          s              4
     D warn            s              1
     D wkgrp1          s                   like(ptgrp1)
     D                                     inz('L')
     D wkgrp2          s                   like(ptgrp2)
     D                                     inz(' ')
     D wkrtpo          s                   like(ptrtpo)
     D                                     inz('0')
     D wkwhse          s                   like(lbwhse)
     D wohome          s                   like(lbwhse)
     D worow           s              3  0
     D wocol           s              3  0
     D wotrn#          s                   like(pttrn#)
640aAD wrtpcmd         s             10
640aAD wrtpwait        s              2  0
640aAD wrtpwhse        s              3  0
640aAD wrtptran#       s                   like(pttrn#)
640aAD wrtpfrmdate     s              8  0
640aAD wrtptodate      s              8  0
640aAd wrtpemp#        s                   like(ptemp#)
     D zzedte          s                   like(ptedte)
     D zzetim          s                   like(ptetim)
     D zzsdte          s                   like(ptsdte)
     D zzstim          s                   like(ptstim)
     *----------------------------------------------------------------
     *  Error message(s)
     *
     Derr01            c                   'Invalid warehouse'
     *
     Derr02            c                   'Invalid item'
     *
     Derr03            c                   'Wrong slot scanned'
     *
     Derr04            c                   'Qty must be gt zero. '
     Derr040           c                   '                     '
     Derr041           c                   'Qty ('
     Derr042           c                   ') greater  '
     Derr043           c                   'than available qty   '
     Derr044           c                   '('
     Derr045           c                   ').'
     Derr046           c                   ' Change      transfer qty. '
     *
     Derr051           c                   'No pick slot found   '
     Derr052           c                   'for item             '
     Derr053           c                   '      Enter next item.     '
     Derr06            c                   'Qty must be entered. '
     *
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     *
     *----------------------------------------------------------------
     * Data structure
     *
     D opdata          ds
     D  optlen               117    117
     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *
     * Data structure
     *
     D sydata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  sysend               117    117
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *  Called programs
     *
     D @addtr          c                   const('ADDSTDTRN')
     D @adjtd          c                   const('ADJTSKDET')
     D @adjtr          c                   const('ADJTRAN  ')
     D @apics          c                   const('APICVTSLT ')
     D @cvtdt          c                   const('CVTDTE')
417b D @getsi          c                   const('GETSLOTITM')
     D @fmtit          c                   const('FRMTIT2')
     D @vewpg          c                   const('SL630')
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
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     *
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0
     *
     D  $litem                22     36
     *
     D  $lwhdp                22     26
     D  $ldsp1                27     38
     D  $litm1                39     53
     D  $lalwc                54     54
416bA*
416bAD  $lwhd2                37     41
416bAD  $ldsp2                42     53
     *
     *----------------------------------------------------------------
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
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
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
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
640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aA
640aAD wrttran1        pr                  extpgm('WRTTRAN1')
640aA * Input
640aAD   ppcmd                        8
640aAD   ppwait                       2  0
640aAD   ppwhse                       3  0
640aAD   pptran#                      7  0
640aAD   ppfromdate                   8  0
640aAD   pptodate                     8  0
640aAD   ppemp#                       5  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
415fD**     None
     *
     *    Returned Parameters
     *      None
     *
415fA*----------------------------------------------------------------
415fA*  Let the show begin .....
415fA*
415kD**         *ENTRY    PLIST
415kD**                   PARM           $PLINE  2
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
 1B  C                   if        error = *on
     C                   move      'EOJ'         nxtscr
 1E  C                   endif
     *
 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
     C     nxtscr        caseq     '09 '         sc9
     C     nxtscr        caseq     '99 '         sc99
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
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   select
 1B  C                   when      nxtscr = '01 '
     C                   exfmt     screen1                              50
 1E  *
 1B  C                   when      nxtscr = '02 '
     C                   exfmt     screen2                              50
 1E  *
 1B  C                   when      nxtscr = '03 '
     C                   exfmt     screen3                              50
 1E  *
 1B  C                   when      nxtscr = '04 '
     C                   exfmt     screen4                              50
 1E  *
 1B  C                   when      nxtscr = '09 '
     C                   exfmt     screen9                              50
 1E  *
 1B  C                   when      nxtscr = '99 '
     C                   exfmt     screen99                             50
 2E  C                   endsl
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
     C                   setoff                                       9298
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
     C                   exsr      zzfil1
     *
     *    Clear counter and last item selected fields on screen 2
     *    when starting new batch.
     C                   eval      w2nrpk = *zeros
     C                   eval      w2lsit = *blanks
     C                   eval      refrsh = *off
     C     end01i        endsr

     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr  = '02 '
     C                   eval      *in02   = *on
     C                   eval      excpflg = *off
     C                   exsr      zzfil2
     C     end02i        endsr

     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   if        refrsh = *on
     C                   exsr      zzget3
     C                   exsr      zzfil3
     C                   endif
     C                   eval      refrsh = *off
     C                   eval      w3scan = *blanks
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   eval      nxtscr = '04 '
     C                   if        refrsh = *on
     C                   exsr      zzfil4
     C                   endif
     C                   eval      refrsh = *off
     C                   eval      w4qty1 = 0
     C                   eval      w4qty2 = 0
     C                   eval      w4qty3 = 0
     C     end04i        endsr

     *----------------------------------------------------------------
     *
     *  Screen 09 initialization
     *
     C     scr09i        begsr
     C                   eval      nxtscr = '09 '
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil9
 1E  C                   endif
     C                   move      *off          refrsh
     C     end09i        endsr

     *----------------------------------------------------------------
     *
     *  Screen 99 initialization
     *
     C     scr99i        begsr
     C                   eval      nxtscr = '99 '
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil99
 1E  C                   endif
     C                   eval      refrsh = *off
     C     end99i        endsr
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
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
goto Csr                 goto      endsc1
 1E  C                   endif
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
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   if        newtrn = '*NO '
     C                   exsr      zzabrt
     C                   endif
     C                   exsr      scr01i
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   if        newtrn = '*NO '
     C                   exsr      zzabrt
     C                   endif
     C                   exsr      scr01i
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
goto C                   exsr      scr02i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
416bACsr                 eval      refrsh = *on
     C                   exsr      scr03i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   exsr      scr02i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for other command keys
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     C     redspl        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   eval      nxtscr = '03 '
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr04i
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr03i
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     C     endsc4        endsr
     *----------------------------------------------------------------
     *
     *  SC9  -  Screen 9
     *
     C     sc9           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   exsr      scr02i
goto Csr                 goto      endsc9
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr09i
goto Csr                 goto      endsc9
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr02i
goto Csr                 goto      endsc9
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd9
     C     cmdtkn        cabeq     *on           endsc9
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk9
     C     error         cabeq     *on           endsc9
     C*                  exsr      zzupd9
     C     error         cabeq     *on           endsc9
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd9
     C     cmdtkn        cabeq     *on           endsc9
     *
     C     endsc9        endsr

     *----------------------------------------------------------------
     *
     *  SC99  -  Screen 99 Display Error routine
     *
     C     sc99          begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
goto Csr                 goto      ends99
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr99i
goto Csr                 goto      ends99
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr99i
goto Csr                 goto      ends99
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd99
     C     cmdtkn        cabeq     *on           ends99
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk99
     C     error         cabeq     *on           ends99
     C                   exsr      zzupd99
     C     error         cabeq     *on           ends99
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd99
     C     cmdtkn        cabeq     *on           ends99
     *
     C     ends99        endsr

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
     *----------------------------------------------------------------
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   move      *on           sclear
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   move      'PIR7971'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   move      'PIR7972'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
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
     *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   move      'PIR0112'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1008  Date is required.
     *
     C     zm1008        begsr
     C                   move      'PIR1008'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PO13229  Item cannot be accepted.
     *
     C     zm3229        begsr
     C                   move      'PO13229'     #msgid
     C                   move      '*DIAG  '     #msgtp
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
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *    Verify warehouse.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
 1B  C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel(p)  err01         errmsg
     C                   exsr      zm0105
 1X  C                   else
 2B  C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel(p)  err01         errmsg
     C                   exsr      zm0105
 2E  C                   endif
 1E  C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     *    Verify item number.
     *
     C                   if        w2item > *blanks
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w2item
     C                   call      'IT900'
     C                   parm                    $lparm
 1B  C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel(p)  err02         errmsg
     C                   exsr      zm0105
 1X  C                   else
 2B  C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel(p)  err02         errmsg
     C                   exsr      zm0105
 2E  C                   endif
 1E  C                   endif
 1E  C                   endif
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   move      *off          error
     C                   move      *off          errflg
     *
     *  Call API for slot.
     *
     C                   call      @apics
     C                   parm                    w3scan
     C                   parm      10            worow
     C                   parm      03            wocol
     C                   parm                    @artn             8
 1B  C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
goto Csr                 goto      endck3
 1E  C                   endif
     *
     *    Verify display.(SCAN slot)
     *
 1B  C                   if        w3scan <> w3disp
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   movel(p)  err03         errmsg
     C                   exsr      zm0105
 2E  C                   endif
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   eval      error = *off
     *
     *
     *    Re-compute available qty as it may have changed.
     *
     C     sl2key        chain(n)  slot2                              79
 1B  C                   select
 1X  C                   when      %found
     *
     C                   exsr      zzavail
     *
     C                   eval      $pcmd  = '*QTY2STR'
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
     C                   eval      $pqstr = *blanks
     C                   exsr      zzcvst
     C                   eval      w4aval =  $pqstr
 2E  C                   endsl
     *
     C                   eval      availqty = avail1
     C                   eval      checkqty = w4qty1
     *
     *    Convert case qty to lowest common denominator.
     C                   if        brkdwn1  = '*YES'
     C                   eval      availqty = (availqty * itumq2) +
     C                             avail2
     C                   eval      checkqty = (checkqty * itumq2) +
     C                             w4qty2
     C                   endif
     *
     *    Convert break down qty 2 to lowest common denominator.
     C                   if        brkdwn2   = '*YES'
     C                   eval      availqty  = (availqty * itumq3) +
     C                             avail3
     C                   eval      checkqty  = (checkqty * itumq3) +
     C                             w4qty3
     C                   endif
     *
     C                   select
     *
     *    Transfer quantity not entered.
     C                   when      w4qty1 = 0 and w4qty2 = 0 and w4qty3 = 0
     *
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   if        brkdwn1 = '*YES'
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif
     C                   if        brkdwn1 = '*YES'
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif
     *
     C                   eval      errmsg = err06
     C                   exsr      zm0105
     *
     *    Transfer quantity must be greater than zero.
     C                   when      w4qty1 < 0 or w4qty2 < 0 or w4qty3 < 0
     *
     C                   if        w4qty1 < 0
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif
     C                   if        brkdwn1 = '*YES' and w4qty2 < 0
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif
     C                   if        brkdwn1 = '*YES' and w4qty3 < 0
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif
     *
     C                   eval      errmsg = err04
     C                   exsr      zm0105
     *
     *    Transfer quantity exceeds total available quantity in slot.
 1B  C                   when      checkqty > availqty
     *
     C                   move      *on           error
     *
     C                   if        w4qty1 > 0
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif
     C                   if        brkdwn1 = '*YES' and w4qty2 > 0
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif
     C                   if        brkdwn1 = '*YES' and w4qty3 > 0
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif
     C                   eval      errmsg = *blanks
     C                   eval      w9txt01 = err040 + err041 +
     C                                       %editc(checkqty:'Z') +
     C                                       err042 + err043 + err044 +
     C                                       %editc(availqty:'Z') + err045 +
     C                                       err046
     C                   eval      rtnto = '04 '
     C                   exsr      scr99i
     *
     C                   endsl
     *
     C     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK9   Screen 9 error checking.
     *
     C     zzchk9        begsr
     *
     C                   eval      error = *off
     *
     C     endck9        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK99  Screen 99 error checking.
     *
     C     zzchk99       begsr
     *
     C                   eval      error = *off
     *
     C     endck99       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
     *
 1E  C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
 1B  C                   if        cmdchk = '*AFTER  '
     *
 1E  C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F10 - Finish
     *
     C                   select
 2B  C                   when      *inkj and w2nrpk > 0
     C                   eval      cmdtkn = *on
     C                   exsr      scr09i
     *
 1E  C                   endsl
     *
 1E  C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
 1B  C                   if        cmdchk = '*AFTER  '
     *
 1E  C                   endif
     *
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     C                   move      *off          cmdtkn
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
416bA*
416bA*  Test for F4 - Display list of slots for item.
416bA*
416bAC                   if        *inkd
416bAC                   eval      cmdtkn  = *on
416bA
416bA*    Display list of slots for item.
416bA
416bAC                   eval      $lwhse = w1whse
416bAC                   eval      $litem = w3item
416bAC                   eval      $lwhd2 = w3whdp
416bAC                   eval      $ldsp2 = w3disp
416bAC                   call      'IT232'
416bAC                   parm                    $luky
416bAC                   parm      *blanks       $lrtn
416bA
416bA*    Get info on selected slot.
416bA
416bAC                   if        $lrtn  = '*SELECT '
416bAC                   eval      w3disp = $ldsp2
416bAC                   eval      $pslot = $ldsp2
416bAC     sl2aky        chain(n)  slot2
416bAC                   exsr      zzavail
416bAC                   eval      slotfnd = '*YES'
416bA*
416bA*    Retrieve base slot for virtual pick slot. Base slot will be
416bA*    used for display and validation.  All updates will be done
416bA*    to virtual slot.
416bAC                   eval      vrtslt  = '*NO '
416bAC                   if        slrsrv = 'V'
416bAC                   exsr      zzgtbs
416bAC                   eval      updslot = $pslot
416bAC                   eval      w3disp  = vspdis
416bAC                   else
416bAC                   eval      updslot = $pslot
416bAC                   eval      w3disp = $pslot
416bAC                   endif
416bA
416bACsr                 goto      endcm3
416bAC                   endif
416bA*
416bAC                   endif
     *
     *
     *  Test for F10 - Log Pick exception
     *    Note:  Pick exception can only be logged one time for each pick slot.
     *
 2B  C**                 if        *inkj and excpflg = *off
 2B  C                   if        *inkj
     C                   eval      cmdtkn  = *on
     C                   eval      excpflg = *on
     C                   eval      exerid  = 'WCTFRPK'
     C                   exsr      zzexcp
     *
     *    Look for first pick slot for item scanned.
     C                   eval      slotfnd = '*NO '
     C                   eval      $pcmd  = '*NEXT   '
     *
     C                   exsr      zzslot
     C                   select
     C                   when      slotfnd = '*NO '
     C                   eval      w9txt01 = err051 + err052 + w3item + err053
     C                   eval      rtnto = '02 '
     C                   exsr      scr99i
     *
     C                   endsl
goto Csr                 goto      endcm3
     *
 1E  C                   endif
     *
 1E  C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
 1B  C                   if        cmdchk = '*AFTER  '
     *
 1E  C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F9 - Slot info
     *
 2B  C                   if        *inki
     C                   eval      cmdtkn = *on
     C                   eval      $lcmd  = '*VIEW   '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w4whdp
     C                   eval      $ldsp1 = w4disp
     C                   eval      $litm1 = *blanks
     C                   eval      $lalwc = 'N'
     C                   call      @vewpg
     C                   parm                    $lparm
 1E  C                   endif
     *
 1E  C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
 1B  C                   if        cmdchk = '*AFTER  '
     *
 1E  C                   endif
     *
     C     endcm4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD9   User defined command keys for screen 9.
     *
     C     zzcmd9        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
     *
     C                   select
     *
     *    User selected F10=Finish.
     C                   when      *inkj
     C                   eval      cmdtkn = *on
     *
     *    Close current transfer will call transaction
     C                   exsr      zzupd9
     *
     *    Return to screen 1 to await starting new batch to pick.
     C                   exsr      scr01i
     *
     C                   endsl
     *
 1E  C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
 1B  C                   if        cmdchk = '*AFTER  '
     *
 1E  C                   endif
     *
     C     endcm9        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD99  User defined command keys for screen 99.
     *
     C     zzcmd99       begsr
     C                   eval      cmdtkn = *off
     *
     *  Command keys to check BEFORE verification and update.
     *
 1B  C                   if        cmdchk = '*BEFORE '
     *
 1E  C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm8        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   eval      w2item = *blanks
     *
     C                   select
     *
     *    No items have been scanned in. F12=Cancel available.
     C                   when      w2nrpk = 0
     C                   eval      w2cmdln = cmdln(2)
     C                   eval      *in51 = *on
     *
     *    One or more items scanned in. F10=Finish available.
     C                   when      w2nrpk > 0
     C                   eval      w2cmdln = cmdln(1)
     C                   eval      *in51 = *off
     *
     C                   endsl
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     C                   eval      w3item = w2item
     C                   move      *blanks       w3desc           30
     C                   eval      w3desc = itdesc
     C                   movel     w3desc        w3desa
     C                   move      w3desc        w3desb
     C                   eval      w3pdsc = itpdsc
     C                   eval      w3whdp = itwhdp
     *
     *    Look for first pick slot for item scanned.
     C                   eval      slotfnd = '*NO '
     C                   eval      $pcmd  = '*FRSTFRS'
     C                   eval      $pslot = *blanks
     *
     C                   exsr      zzslot
     C                   select
     C                   when      slotfnd = '*NO '
     C                   eval      w9txt01 = err051 + err052 +  w3item  + err053
     C                   eval      rtnto = '02 '
     C                   exsr      scr99i
     *
     C                   endsl
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZGET3   Fill files needed to fill screen 3.
     *
     C     zzget3        begsr
     *
     C     itkey         chain     piritem
     C                   select
     C                   when      not %found
     *
     C                   when      %found
     C                   select
     C                   when      ittype = 'A' or ittype = 'C' or ittype = 'S'
     C                   CALL      'GETBASE'
     C                   PARM      w1whse        $gwhse            3 0
     C                   PARM      w2item        $GITEM           15
     C                   PARM      ' '           #BITEM           15
     C                   PARM                    #BITYP            1
     C                   PARM                    #BDESC           30
     C                   PARM                    #BPDSC           15
     C                   PARM                    #BWHDP            5
     C                   PARM                    #BSTYP            1
     C                   PARM                    #BUM              2
     C                   PARM                    #BUM2             2
     C                   PARM                    #BUMQ2            3 0
     C                   PARM                    #BUM3             2
     C                   PARM                    #BUMQ3            3 0
     C                   PARM      ' '           #BCITM           15
     C                   PARM                    #BCTYP            1
     C                   PARM                    #BCDSC           30
     C                   PARM                    #BCPDS           15
     C                   PARM                    #BWHDP            5
     C                   PARM                    #BCSTP            1
     C                   PARM                    #BCUM             2
     C                   PARM                    #BCUM2            2
     C                   PARM                    #BCUQ2            3 0
     C                   PARM                    #BCUM3            2
     C                   PARM                    #BCUQ3            3 0
     C                   PARM                    #BRTN             8
     C                   eval      fmitem = #bitem
     C                   other
     C                   eval      fmitem = w2item
     C                   endsl
417bA*    Get slot item for all items.
417bAC                   call      @getsi
417bAC                   PARM      w1whse        $gwhse
417bAC                   PARM      w2item        $GITEM
417bAC                   PARM      ' '           #SITEM           15
417bAC                   PARM                    #SITYP            1
417bAC                   PARM                    #SDESC           30
417bAC                   PARM                    #SPDSC           15
417bAC                   PARM                    #SRTN            10
417bAC                   PARM                    #SMSG            60
417bAC                   eval      fmitem = #sitem
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     *
     C                   eval      w4item = w3item
     C                   eval      w4desc = w3desc
     C                   eval      w4pdsc = w3pdsc
     C                   eval      w4whdp = w3whdp
     C                   eval      w4disp = w3scan
     C                   eval      w4um1  = itum1
     C                   select
     C                   when      itflg1  = 'Y' and itumq2 > 0
     C                   eval      w4um2   = itum2
     C                   eval      *in52   = *on
     C                   eval      brkdwn1 = '*YES'
     *
     C                   other
     C                   eval      itum2   = *blanks
     C                   eval      *in52   = *off
     C                   eval      brkdwn1 = '*NO '
     *
     C                   endsl
     *
     C                   select
     C                   when      itflg2  = 'Y' and itumq3 > 0
     C                   eval      w4um3   = itum3
     C                   eval      *in53   = *on
     C                   eval      brkdwn2 = '*YES'
     *
     C                   other
     C                   eval      itum3   = *blanks
     C                   eval      *in53   = *off
     C                   eval      brkdwn2 = '*NO '
     C                   endsl
     *
     C                   eval      $pcmd  = '*QTY2STR'
     C                   eval      $pqty1 = avail1
     C                   eval      $pqty2 = avail2
     C                   eval      $pqty3 = avail3
     C                   eval      $pqstr = *blanks
     C                   exsr      zzcvst
     C                   eval      w4aval  =  $pqstr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL9   Fill screen 9 fields with info from file.
     *
     C     zzfil9        begsr
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL99  Fill screen 99 fields with info from file.
     *
     C     zzfil99       begsr
     *
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
     C                   eval      *in53  = *off
     C                   eval      $lprg  = #prog
     C                   eval      $cvprg = #prog
     *
     *    Define key for ITEMDEF file.
     *
     C     idkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w2item
     C                   kfld                    slsdef
     *
     *    Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w2item
     *
     *    Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    ocode
     *
     *    Define key for ITEMMSC file.
     *
     C     imkey         klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
     *
     *    Define key for PIRTRAN file.
     *
     C     ptkey         klist
     C                   kfld                    SVTRN#
     *
     *    Define key for PIRTRAN1 file.
     *
     C     PTKEY1        KLIST
     C                   KFLD                    #emp#
     C                   KFLD                    KYSTAT
     *
     *    Define partial key for PIRTRAN2 file.
     *
     C     ptkey2        KLIST
     C                   KFLD                    #EMP#
     C                   KFLD                    STDATE
     *
     C     ptke22        klist
     C                   kfld                    #EMP#
     C                   kfld                    STDATE
     C                   kfld                    STTIME
     *
     *    Define partial key for PIRTRAN3 file.
     *
     C     PTKEY3        KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    WKGRP1
     C                   KFLD                    WKGRP2
     *
     *    Define Full key for PIRTRAN3 file.
     *
     C     PTKY3A        KLIST
     C                   KFLD                    W1WHSE
     C                   KFLD                    WKGRP1
     C                   KFLD                    WKGRP2
     C                   KFLD                    WKRTPO
     C                   KFLD                    KYTRN#
405 A*
405 A*    Define key for SLOT1 file.
405 A*
405 AC     keysl1        klist
     C                   kfld                    w1whse
     C                   kfld                    itwhdp
     C                   kfld                    kyaisl
     *
     *    Define Full key for SLOT2 file.
     *
     C     sl2key        klist
     C                   kfld                    w1whse
     C                   kfld                    itwhdp
     C                   kfld                    updslot
     C     sl2aky        klist
     C                   kfld                    w1whse
     C                   kfld                    itwhdp
     C                   kfld                    $pslot
405 A*
     C     tokey         klist
     C                   kfld                    w1whse
     C                   kfld                    itwhdp
     C                   kfld                    kydisp
405 A*
405 A*    Define key for SLOT4 file.
405 A*
405 AC     keysl4        klist
405 AC                   kfld                    w1whse
405 AC                   kfld                    itwhdp
405 AC                   kfld                    w2item
405 AC                   kfld                    kydisp
     *
     *    Define key for TASK file.
     *
     C     tkkey         klist
     C                   kfld                    t#task
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     C                   setoff                                       kckl
     *
     *   Get default warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     *
     C                   eval      w1whse = #whse
     *
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
     *
     C                   move      *on           refrsh
     *
     C                   move      '*SYSTEM '    ocode
     C                   eval      wkwhse = 0
     C     opkey         chain     options                            79
     C                   eval      sydata = opdata
 1B  C                   if        not %found
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw = 'N'
 1E  C                   endif
     *
     *    Get User's employee number.
     *
     C                   call      'GETUSER'
     C                   parm      #user         #code            10
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm      *blanks       #fnam            15
     C                   parm      *blanks       #init             1
     C                   parm      *blanks       #lnam            20
     C                   parm      *blanks       #whdp             5
     C                   parm      *blanks       #styp             1
     C                   parm      *blanks       #shft             6
     C                   parm      *blanks       #crew             6
     C                   parm      0.0           #nhrs             3 1
     C                   parm      *blanks       #rtn              8
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      #pgmq = #prog
     *
     *    Initialize first screen for display.
     C                   exsr      scr01i
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZABRT   Abort a transaction
     *
     C     zzabrt        begsr
     *
     C                   move      *off          error
     C                   eval      @pcmd = '*ABORT  '
     *
     C                   call      @adjtr
     C                   parm                    @pcmd             8
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#            7 0
     C                   parm      pttask        @ptask            6
     C                   parm      w1whse        @pwhse            3 0
     C                   parm      itwhdp        @pwhdp            5
     C                   parm      itstyp        @pstyp            1
     C                   parm      0.000         @pcube            9 3
     C                   parm      0.00          @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'L'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
     *    Start an 'IDLE' task.
     *
     C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
 3B  C                   if        curent = *off
     C                   exsr      zzidle
 3E  C                   endif
     *
     C     endabr        endsr

     *----------------------------------------------------------------
     *
     *  ZZADJQY  Adjust breakdown quantities.
     *
     C     zzadjqy       begsr
     *
     *    Make sure breakdown qty's are not greater than
     *    quantity in the unit of measure.
     *
     C                   dow       slstk3 > itumq3 and itumq3 <> 0
     C                   eval      slstk3 = slstk3 - itumq3
     C                   eval      slstk2 = slstk2 + 1
     C                   enddo
     *
     C                   dow       slstk2 > itumq2 and itumq2 <> 0
     C                   eval      slstk2 = slstk2 - itumq2
     C                   eval      slstk1 = slstk1 + 1
     C                   enddo
416eA*
416eA*    Make sure breakdown qty's are not less than zero
416eA*    in the unit of measure.
416eA*
416eAC                   dow       slstk2 < 0 and itumq2 <> 0
416eAC                   eval      slstk2 = slstk2 + itumq2
416eAC                   eval      slstk1 = slstk1 - 1
416eAC                   enddo
416eA*
416eAC                   dow       slstk3 < 0 and itumq3 <> 0
416eAC                   eval      slstk3 = slstk3 + itumq3
416eAC                   eval      slstk2 = slstk2 - 1
416eAC                   enddo
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZAVAIL  Compute available qty in slot.
     *
     C     zzavail       begsr
     *
     C                   call      'SLOTQTY'
     C                   PARM                    slstk1
     C                   PARM                    slstk2
     C                   PARM                    slstk3
     C*
     C                   PARM                    slalc1
     C                   PARM                    slalc2
     C                   PARM                    slalc3
     C*
     C                   PARM                    sltfr1
     C                   PARM                    sltfr2
     C                   PARM                    sltfr3
     C*
     C                   parm                    slpck1
     C                   PARM                    slpck2
     C                   PARM                    slpck3
     C*
     C                   PARM                    slrcv1
     C                   PARM                    slrcv2
     C                   PARM                    slrcv3
     C*
     C                   PARM      0             stock1            5 0
     C                   PARM      0             stock2            3 0
     C                   PARM      0             stock3            3 0
     C*
     C                   PARM      0             avail1            5 0
     C                   PARM      0             avail2            3 0
     C                   PARM      0             avail3            3 0
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCKU2   Check for overlapping task and update the current
     *           task just ended, by adjusting the time.
     *
     C     zzcku2        begsr
     C                   eval      svtlen = 0
     C     ptkey2        setll     pirtran2
 1B  C                   dow       forevr = forevr
     C                   read      pirtran2
 2B  C                   if        %eof   or
     C                             ptsdte < zzsdte
 1L  C                   leave
 2E  C                   endif
     *    Skip the task that just ended.
 2B  C                   if        not %eof   and
     C                             pttrn# = svtrn#
 1I  C                   iter
 2E  C                   endif
     *    Accumulate overlapping minutes.(Same start and end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  10:00:23   11:30:35  1/25/96
     *Manual(PT) BREAK 1/25/96  10:30:00   10:45:00  1/25/96   (15)
     *
     *    Auto    CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *    Manual  BREAK 1/25/96  23:30:00    1:30:00  1/26/96   (120)
     *
 2B  C                   if        not %eof   and
     C                             ptsdte = zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptstim >= zzstim  and
     C                             ptetim <= zzetim
     C                   z-add     ptstim        strtim
     C                   z-add     ptetim        fintim
     C                   exsr      zztime
     C                   add       timlen        svtlen
 2E  C                   endif
     *    Accumulate overlapping minutes(Diff start date/same end date)
     *                                  (Past midnight)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/26/96   8:00:00    8:30:00  1/26/96   (30)
     *
 2B  C                   if        not %eof   and
     C                             ptsdte > zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptetim <= zzetim
     C                   z-add     ptstim        strtim
     C                   z-add     ptetim        fintim
     C                   exsr      zztime
     C                   add       timlen        svtlen
 2E  C                   endif
     *    Accumulate overlapping minutes.(Same start date/diff end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/25/96  16:00:00   16:30:00  1/25/96   (30)
     *
 2B  C                   if        not %eof   and
     C                             ptsdte = zzsdte  and
     C                             ptedte < zzedte  and
     C                             ptstim >= zzstim
     C                   z-add     ptstim        strtim
     C                   z-add     ptetim        fintim
     C                   exsr      zztime
     C                   add       timlen        svtlen
 2E  C                   endif
 1E  C                   enddo
     *
     *    Update the task that just ended.
     *
     C     svtrn#        chain     pirtran
 1B  C                   if        not %eof
 2B  C                   if        ptdmin > 0
     C                   eval      ptdmin = ptdmin - svtlen
 2X  C                   else
     C                   eval      ptimin = ptimin - svtlen
 2E  C                   endif
     *
     *    Update transaction time only if difference found.
     *    Otherwise, release lock on record.
 2B  C                   if        svtlen <> *zeros
     C                   update    ptrec
640aAc                   exsr      zzwrttrand
 2X  C                   else
     C                   unlock    pirtran
 2E  C                   endif
 1E  C                   endif
     C     endcu2        endsr

     *----------------------------------------------------------------
     *
     *  ZZCLSE   Close a transaction
     *
     C     zzclse        begsr
     *
     C                   eval      $lcmd = '*CLOSE  '
     C                   eval      $ltype = '*INTER  '
     C                   eval      $lwhse = lbwhse
     C                   eval      $lrte = *blanks
     C                   eval      $lpo = *blanks
     C                   eval      $ltrn# = pttrn#
     *
     C                   call      'PT132'
     C                   parm                    $lparm
     *
     *     Error occured - Error message sent back
     *
 1B  C                   select
 1X  C                   when      $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   movel     $lerm         errmsg
     C**                 exsr      zm0105
     *
     *     Error occured - Error message sent to program msgq
     *
 1X  C                   when      $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     *
     *     Error occured - User pressed F12=Cancel.
     *
 1X  C                   when      $lrtn = '*CANCEL '
     C                   move      *on           error
     *
     *    Close was successful.
     *
 1X  C                   when      $lrtn = '*OK     '
     *
     *    Calculate the time in minutes it took to complete this task.
     *    PTCTIM is used for end time instead of PTETIM, because close
     *    time and End time are the same in this case.
     *
     C     ptkey         chain     pirtran                            79
     C                   z-add     ptstim        strtim
     C                   z-add     ptctim        fintim
     C                   exsr      zztime
     C                   eval      ptdmin = timlen
     C                   update    ptrec
640aAc                   exsr      zzwrttrand
     *
     *        There is a posibility that a manual task might have
     *        been added before the current task was ended. Hence
     *        adjust the current task just ended, if there is
     *        any overlapping manual task.
     *
     C                   z-add     pttrn#        svtrn#
     *    Past overnight. (PTEDTE > PTSDTE)
 2B  C                   if        ptedte > ptsdte
     C                   z-add     ptedte        stdate
 2X  C                   else
     C                   z-add     ptsdte        stdate
 2E  C                   endif
     C                   z-add     ptsdte        zzsdte
     C                   z-add     ptedte        zzedte
     C                   z-add     ptstim        zzstim
     C                   z-add     ptetim        zzetim
     C                   exsr      zzcku2
     *
 1E  C                   endsl
     *
     C     endcls        endsr

     *----------------------------------------------------------------
     *
     *  ZZCVTDT  Convert date to selected format.
     *
     C     zzcvtdt       begsr
     *
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCVST   Convert quantities into string for display.
     *
     C     zzcvst        begsr
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd             8
     C                   parm                    $pprg             1 0
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn             8
     C                   parm                    $perm            60
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZEND  End current task.
     *
     C     zzend         begsr
     *    No current task to end.
     C     curtrn        cabeq     0             endend
     *    End current task
     C                   eval      wotrn# = curtrn
     C     wotrn#        chain     pirtran                            79
 1B  C                   if        not *in79
 2B  C                   if        curtyp = 'D'  and
     C                             curtsk <> 'IDLE  '
     C                   eval      ptstat = '3'
 2X  C                   else
     C                   eval      ptstat = '4'
 2E  C                   endif
     C                   eval      ptetyp = 'N'
 1E  C                   endif
     *
     C                   call      @adjtd
     C                   parm      '*END    '    @pcmd
     C                   parm      '*INTER  '    @ptype            8
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   update    ptrec                                79
 1B  C                   if        *in79
     C                   eval      error = *on
     C*                  exsr      zm72
goto Csr                 goto      endend
 1E  C                   endif
640aAc                   exsr      zzwrttrand
     *
 1B  C                   if        curtyp = 'D'
     *
     *        There is a posibility that a manual task might have
     *        been added before the current task was ended. Hence
     *        adjust the current task just ended, if there is
     *        any overlapping manual task.
     *
     C                   z-add     pttrn#        svtrn#
     *    Past overnight. (PTEDTE > PTSDTE)
 2B  C                   if        ptedte > ptsdte
     C                   z-add     ptedte        stdate
 2X  C                   else
     C                   z-add     ptsdte        stdate
 2E  C                   endif
     C                   z-add     ptsdte        zzsdte
     C                   z-add     ptedte        zzedte
     C                   z-add     ptstim        zzstim
     C                   z-add     ptetim        zzetim
     C                   exsr      zzcku2
 1E  C                   endif
     *
     C     endend        endsr

     *----------------------------------------------------------------
     *
     *  ZZEXCP Write item exception record to file.
     *
     C     zzexcp        begsr
     *
     *    Write an item exception record, and delete replenishment
     *    record.
     C                   eval      exwhse = w1whse
     C                   eval      exwhdp = itwhdp
     C                   eval      exstyp = itstyp
     C                   eval      exitem = w3item
     C                   eval      exfdis = w3disp
     C                   eval      extdis = *blanks
     C                   eval      exqty  = slstk1
     C                   eval      extask = curtsk
     *    Get todays date.
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvtdt
     C                   eval      exgdte = today
     C                   time                    exgtim
     C                   eval      exgby = #user
     C                   eval      exesta = '1 '
     C                   write     exrec
     *
     C     endexc        endsr

     *----------------------------------------------------------------
     *
     *  ZZGTBS   Retrieve base slot for virtual slot
     *
     C     zzgtbs        begsr
     *
     C     sl2aky        chain     vslot1                             79
 1B  C                   if        %found
     C                   eval      vrtslt = '*YES'
 1X  C                   else
     C                   eval      vrtslt = '*NO '
 2E  C                   endif
     *
     C     endgtb        endsr

     *----------------------------------------------------------------
     *
     *  ZZGTPSLT  Get pick slot for item.
     *
     C     zzgtpslt      begsr
     *
     C                   call      'GETPSLT'
     C                   parm                    $pcmd             8
     C                   parm      w1whse        $pwhse            3 0
     C                   parm      fmitem        $pitem           15
     C                   parm                    $pslot           12
     C                   parm      *blanks       $paisl            3
     C                   parm      *zeros        $ploc             3 0
     C                   parm      *zeros        $prlvl            2 0
     C                   parm      *blanks       $phand            2
     C                   parm      *blanks       $prtn             8
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZIDLE   Create and Start an Idle task.
     *
     C     zzidle        begsr
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#
     C                   eval      ptstat = '2'
     C                   eval      pttask = 'IDLE  '
     C                   eval      t#task = 'IDLE  '
     C     tkkey         chain     task                               77
     C                   eval      ptcat = tkcat
     C                   eval      ptsub = tksub
 1B  C                   select
 1X  C                   when      tktlvl = 'S'
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = itwhdp
     C                   eval      ptstyp = itstyp
     *
 1X  C                   when      tktlvl = 'D'
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = itwhdp
     C                   eval      ptstyp = *blanks
     *
 1X  C                   other
     C                   eval      ptwhse = w1whse
     C                   eval      ptwhdp = *blanks
     C                   eval      ptstyp = *blanks
 1E  C                   endsl
     C                   eval      ptshft = #shft
     C                   eval      ptcrew = #crew
     C                   eval      ptemp# = #emp#
     C                   eval      ptcube = 0
     C                   eval      ptswgt = 0
     C                   eval      ptpcs = 0
     C                   eval      ptaisl = 0
     C                   eval      ptqty1 = 0
     C                   eval      ptqty2 = 0
     C                   eval      ptqty3 = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvtdt
     C                   eval      ptgdte = $cvd8o
     C                   time                    ptgtim
     C                   eval      ptsdte = $cvd8o
     C                   time                    ptstim
     C                   eval      ptedte = 0
     C                   eval      ptetim = 0
     C                   eval      ptetyp = *blanks
     C                   eval      ptcdte = 0
     C                   eval      ptctim = 0
     C                   eval      ptrdte = $cvd8o
     C                   eval      ptdmin = 0
     C                   eval      ptimin = 0
     C                   eval      ptrtpo = *blanks
     C                   write     ptrec
 1B  C                   if        %error
     C                   eval      error = *on
     C**                 exsr      zm71
goto Csr                 goto      endidl
 1E  C                   endif
640aAc                   exsr      zzwrttrand
     *
     C     endidl        endsr

     *----------------------------------------------------------------
     *
     *  ZZSLOT   Routine to find available pick slot.
     *
     C     zzslot        begsr
     *
     C                   dou       slotfnd = '*YES'
     *
     C                   exsr      zzgtpslt
     *
     C                   select
     C                   when      $prtn = '*NONE   '
     C                   eval      slotfnd = '*NO '
     C                   leave
     *
     *    Pick slot found. Check for available quantity.
     C                   when      $prtn = '*OKPICK ' or $prtn = '*OKOVRF'
     C     sl2aky        chain(n)  slot2
     C                   exsr      zzavail
     C                   select
     C                   when      avail1 > 0 or avail2 > 0
     C                             or avail3 > 0
     C                   eval      slotfnd = '*YES'
     C                   eval      vrtslt  = '*NO '
     *
     *    Retrieve base slot for virtual pick slot. Base slot will be
     *    used for display and validation.  All updates will be done
     *    to virtual slot.
     C                   if        slrsrv = 'V'
     C                   exsr      zzgtbs
     C                   eval      updslot = $pslot
     C                   eval      w3disp  = vspdis
     C                   else
     C                   eval      updslot = $pslot
     C                   eval      w3disp = $pslot
     C                   endif
     C                   other
     C                   eval      $pcmd  = '*NEXT   '
     C                   endsl
     *
     C                   endsl
     C                   enddo
     *
     C     endslo        endsr

     *----------------------------------------------------------------
     *
     *  ZZTFEND  End Transfer Will Call task.
     *
     C     zztfend       begsr
     *
     *    End current task
     C     curtrn        chain     pirtran
 1B  C                   if        %found and pttask = 'TFRWIL'
     C                   eval      ptpcs  = ptpcs + totpcs
     C                   eval      ptstat = '4'
     C                   eval      svtask = pttask
     C                   eval      svtrn# = pttrn#
     C                   eval      ptetyp = 'N'
 1E  C                   endif
     *
     *    Update Task Detail with total pieces picked.
     C                   call      @adjtd
     C                   parm      '*INCACT '    @pcmd
     C                   parm      '*INTER  '    @ptype            8
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     *    Update Task Detail. Moving active qty's to closed qty's.
     C                   call      @adjtd
     C                   parm      '*END    '    @pcmd
     C                   parm      '*INTER  '    @ptype            8
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   update    ptrec
 1B  C                   if        %error
     C                   eval      error = *on
     C**                 exsr      zm72
goto Csr                 goto      endtfe
 1E  C                   endif
640aAc                   exsr      zzwrttrand
     *
 1B  C                   if        curtyp = 'D'
     *
     *        There is a posibility that a manual task might have
     *        been added before the current task was ended. Hence
     *        adjust the current task just ended, if there is
     *        any overlapping manual task.
     *
     C                   z-add     pttrn#        svtrn#
     *    Past overnight. (PTEDTE > PTSDTE)
 2B  C                   if        ptedte > ptsdte
     C                   z-add     ptedte        stdate
 2X  C                   else
     C                   z-add     ptsdte        stdate
 2E  C                   endif
     C                   z-add     ptsdte        zzsdte
     C                   z-add     ptedte        zzedte
     C                   z-add     ptstim        zzstim
     C                   z-add     ptetim        zzetim
     C                   exsr      zzcku2
 1E  C                   endif
     *
     C     endtfe        endsr

     *----------------------------------------------------------------
     *
     *  ZZTFWC  Attach transfer will call item to slot.
     *
     C     zztfwc        begsr
     *
     C                   eval      found = *off
     *
     *    If Transfer Will Call slot record exists, update
     C                   movel(p)  'WIL'         kydisp
     C     keysl4        setll     slot4
 2B  C                   dow       forevr = forevr
     C                   read      slot4
 3B  C                   if        not %eof   and
     *
     C                             slstat = 'WC'  and
     C                             slwhse = w1whse  and
     C                             slwhdp = itwhdp  and
     C                             slitem = fmitem  and
     C                             slaisl = 'WIL'
416bA*
416bA*    Update slot expiration date when product transferred in
416bA*    is older than current product in the slot.
416bAC                   if        svexpd > 0 and svexpd < slexpd
416bAC                   eval      slexpd = svexpd
416bAC                   endif
     *
     *    Update Transfer Will Call slot stock quantities.
     C                   add       w4qty1        slstk1
     *
 4B  C                   if        brkdwn1 = '*YES'
     C                   add       w4qty2        slstk2
 4E  C                   endif
     *
 4B  C                   if        brkdwn2 = '*YES'
     C                   add       w4qty3        slstk3
 4E  C                   endif
     *
     *    Adjust breakdown quantities be less than qty multiplier.
     C                   exsr      zzadjqy
     *
     C                   update    slrec4
     *
     C                   eval      todisp = sldisp
     C                   eval      kydisp = sldisp
     C                   eval      found  = *on
     C                   leave
     *
 3X  C                   else
     *
     C                   unlock    slot4
 2L  C                   leave
 3E  C                   endif
 2E  C                   enddo
     *
     *-----------------------------------------------------------------
     *
     *    Create Transfer will call slot record.
     C                   select
     C                   when      found = *off
     *
     C                   eval      tmploc = 1
     C                   move      'WIL'         kyaisl
     C     keysl1        setll     slot1
 2B  C                   dow       forevr = forevr
     C     keysl1        reade(n)  slot1
 3B  C                   if        %eof   or
     C                             slloc > tmploc
 2L  C                   leave
 3E  C                   endif
     C                   eval      tmploc = slloc + 1
 2E  C                   enddo
     *
     C                   clear                   slrec4
     C                   eval      slwhse = w1whse
     C                   eval      slwhdp = itwhdp
     C                   eval      slaisl = 'WIL'
     C                   eval      slloc = tmploc
     C                   eval      slrlvl = 1
     C                   eval      slhand = *blanks
     C                   eval      slstyp = 'X'
     C                   eval      slpseq = tmploc
     C                   eval      slitem = fmitem
     C                   eval      slstat = 'WC'
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvtdt
416bAC                   eval      slexpd = svexpd
     C                   eval      slentd = $cvd8o
     C                   eval      slsdte = $cvd8o
     C                   time                    slstim
     C                   eval      slpick = 'N'
     C                   eval      slrsrv = 'N'
     * Format display slot.
     C                   call      'FRMTSL'
     C                   parm                    slwhse
     C                   parm                    slwhdp
     C                   parm                    slaisl
     C                   parm                    slloc
     C                   parm                    slrlvl
     C                   parm                    slhand
     C                   parm                    slstyp
     C                   parm                    slpseq
     C                   parm                    sldisp
     *    Initialize Transfer Will Call stock quantities.
     C                   eval      slstk1  = w4qty1
 2B  C                   if        brkdwn1 = '*YES'
     C                   eval      slstk2  = w4qty2
 2E  C                   endif
 2B  C                   if        brkdwn2 = '*YES'
     C                   eval      slstk3  = w4qty3
 2E  C                   endif
     *
     *    Adjust breakdown quantities be less than qty multiplier.
     C                   exsr      zzadjqy
     *   Add record
     C     slloc         div       2             dummy
     C                   mvr                     slside
 2B  C                   if        slside < 0
     C                   eval      slside = -(slside)
 2E  C                   endif
     C                   write     slrec1
     C                   eval      found  = *on
     C                   eval      kydisp = sldisp
     *   Error if slot not created.
 2B  C                   if        %error
     C**                 eval      detmsg = desc(5)
 2E  C                   endif
     *
     C                   endsl
     *
     C     endtf         endsr

     *----------------------------------------------------------------
     *
     *  ZZTASK  Get current task.
     *
     C     zztask        begsr
     C                   eval      stdate = *hival
     C                   eval      sttime = *hival
     *
     C                   move      '2'           kystat
     C     ptkey1        setll     pirtran1
     C     ptkey1        reade     pirtran1
 1B  C                   if        %eof
     C                   move      *off          found
goto Csr                 goto      endtsk
 1E  C                   endif
     *
     C     ptke22        setll     pirtran2
 1B  C                   dow       forevr = forevr
     C                   read      pirtran2
 2B  C                   if        %eof   or
     C                             ptemp# <> #emp#
     C                   move      *off          found
 1L  C                   leave
 2E  C                   endif
 2B  C                   if        ptstat <> '2'
 1I  C                   iter
 2E  C                   endif
     *    Found an active transaction
     C                   move      *on           curent
     C                   eval      curtrn = pttrn#
     C                   move      pttask        t#task
     C     tkkey         chain     task
 2B  C                   if        %found
     C                   move      tkcode        curtsk
     C                   move      tktype        curtyp
 2E  C                   endif
 1L  C                   leave
 1E  C                   enddo
     C     endtsk        endsr
     *----------------------------------------------------------------
     *
     *  ZZTIME   Update for screen 1.
     *
     C     zztime        begsr
     *
     *    Calculate length of time in minutes for output.
     *
     C                   eval      dshms = strtim
     *    Round up minute, if the seconds is >= 30
 1B  C                   if        dsss >= 30
     C                   add       1             dsmm
 1E  C                   endif
     C     dshh          mult      60            tmpbeg
     C                   add       dsmm          tmpbeg
     *
     C                   eval      dshms = fintim
     *    Round up minute, if the seconds is >= 30
 1B  C                   if        dsss >= 30
     C                   add       1             dsmm
 1E  C                   endif
     *
     *    If the ending time is < starting time, than
     *    we have gone past the midnight.
     *
 1B  C                   if        fintim < strtim
     C                   add       24            dshh
 1E  C                   endif
     C     dshh          mult      60            tmpend
     C                   add       dsmm          tmpend
     *
     C                   eval      timlen = tmpend - tmpbeg
 1B  C                   if        timlen < 0
     C                   eval      timlen = 0
 1E  C                   endif
     *
     C     endtim        endsr

     *----------------------------------------------------------------
     *
     *  ZZUHLD  Update held quantities.
     *
     C     zzuhld        begsr
     *
     C                   eval      $acmd = '*HOLD   '
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*INTER  '
     C                   eval      $awhse  = slwhse
     C                   eval      $aitem  = slitem
     C                   eval      $aqty1  = w4qty1
     C                   eval      $aqty2  = w4qty2
     C                   eval      $aqty3  = w4qty3
     C                   call      'ADJQTY'
     C                   parm                    $acmd             8
     C                   parm                    $aprg            10
     C                   parm                    $atype            8
     C                   parm                    $awhse            3 0
     C                   parm                    $aitem           15
     C                   parm                    $aqty1            7 0
     C                   parm                    $aqty2            7 0
     C                   parm                    $aqty3            7 0
     C                   parm                    $artq1            7 0
     C                   parm                    $artq2            7 0
     C                   parm                    $artq3            7 0
     C                   parm                    $artn             8
     C                   parm                    $aerm
 1B  C                   if        $artn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $amsg
     C                   exsr      zmqmsg
 1E  C                   endif
     C     endhld        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     *
     C                   eval      error = *off
     *
     *    Start loop for user to begin item selection.
     *
     *    Note: Set flag so that after first item is scanned, we
     *          create a new transaction number for this batch items
     *          items to be picked and transferred to will call area.
     *
     C                   eval      newtrn = '*YES'
     C                   eval      totpcs = *zeros
     C                   eval      w2nrpk = *zeros
     C                   eval      w2lsit = *blanks
     C                   exsr      scr02i
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     C                   select
     *--------------------------------------------------------------------
     *
     *    New batch being started. Create new transaction.
     C                   when      newtrn = '*YES' and w2item > *blanks
     C                   eval      newtrn = '*NO '
     *
     *    Get current task.
     *
     C                   eval      curtrn = *zeros
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     *
     *    Now end current task.
 1B  C                   if        curent = *on
     C                   exsr      zzend
 1E  C                   endif
     *
     *    Create new transaction record for this batch.
     *
     C                   call      'PIRTRN#'
     C                   parm                    pttrn#            7 0
     *
     C                   eval      @ptask = 'TFRWIL'
     C                   eval      curtsk = 'TFRWIL'
     C                   eval      @pcube = *zeros
     C                   eval      @pswgt = *zeros
     C                   call      @addtr
     C                   parm      '*CRTSTRT'    @pcmd
     C                   parm                    #job
     C                   parm      pttrn#        @ptrn#
     C                   parm                    @ptask
     C                   parm      w1whse        @pwhse
     C                   parm      itwhdp        @pwhdp
     C                   parm      itstyp        @pstyp
     C                   parm                    @pcube
     C                   parm                    @pswgt
     C                   parm      0             @ppcs
     C                   parm      1             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      ' '           @prte
     C                   parm      *blanks       @ppo
     C                   parm      'L'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   endsl
     *
     *--------------------------------------------------------------------
     *
     C                   select
     *
     *    No item scanned in. Goto Finish screen 9.
     C                   when      w2nrpk > 0 and w2item = *blanks
     C                   exsr      scr09i
     *
     *    Item number scanned in. Display qty screen.
     C                   when      w2item > *blanks
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     *
     C                   endsl
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     *
     C                   eval      error = *off
     C                   eval      refrsh= *on
     C                   exsr      scr04i
     *
     C     endup3        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     C                   move      *off          error
     *
     *    Increment counter and update last item picked on screen 2.
     *
     C                   eval      w2nrpk = w2nrpk + 1
     C                   eval      w2lsit = w2item
     C                   eval      totpcs = totpcs + w4qty1 + w4qty2 + w4qty3
     *
     *    Reduce From Slot stock qty with Transfer Qty.
     *
     C     sl2key        chain     slot2
     C                   select
     C                   when      %found
     *
     *    Note: Stock quantity could go negative if a receiving
     *          transaction has not been closed yet so let it be.
     *
     C                   select
     C                   when      w4qty1 > 0
     C                   eval      slstk1 = slstk1 - w4qty1
     C                   endsl
     C                   select
     C                   when      w4qty2 > 0
     C                   eval      slstk2 = slstk2 - w4qty2
     C                   endsl
     C                   select
     C                   when      w4qty3 > 0
     C                   eval      slstk3 = slstk3 - w4qty3
     C                   endsl
     *
416bAC                   eval      svexpd = slexpd
416bA*
416cA*    Adjust breakdown quantities be less than qty multiplier.
416cAC                   exsr      zzadjqy
416cA*
     C                   update    slrec2
     C                   endsl
     *
     *    Create label records for case Will Call transfer.
     *
 1B  C                   select
 1X  C                   when      w4qty1 <> 0
     *
     C                   eval      lbwhse = itwhse
     C                   eval      lbwhdp = itwhdp
     C                   eval      lbseq  = w2nrpk
     C                   eval      lbitem = w2item
     C                   eval      toitem = w2item
     C                   eval      lbpbat = 0
     C                   eval      lbaisl = slaisl
     C                   eval      lbloc  = slloc
     C                   eval      lbrlvl = slrlvl
     C                   eval      lbhand = slhand
     C                   eval      lbpseq = slpseq
     C                   eval      lbstyp = slstyp
     C                   if        slstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
     C                   eval      lbdisp = sldisp
     C                   eval      fmdisp = sldisp
     C                   eval      lbqavl = svavl1
     *
     *    Retrieve tie/high for From slot.
     *      Note:  In a normal transfer, the tie/high of the To Slot would
     *             normally be used.  But since the To Slot is created by
     *             the program, we're using the From Slot tie/high.
     *
     C     idkey         chain     itemdef
     C                   select
     C                   when      not %found
     C                   eval      lbtie  = *zeros
     C                   eval      lbhigh = *zeros
     *
     C                   when      %found
     C                   eval      lbtie  = idtie
     C                   eval      lbhigh = idhigh
     *
     C                   endsl
     *
     *    Update or Create To Slot for Will Call Transfer.
     *
     C                   exsr      zztfwc
     *
     *    Update Label record with To Slot info.
     *
     C                   eval      lbwhs2 = slwhse
     C                   eval      lbwhd2 = slwhdp
     C                   eval      lbasl2 = slaisl
     C                   eval      lbloc2 = slloc
     C                   eval      lblvl2 = slrlvl
     C                   eval      lbhnd2 = slhand
     C                   eval      lbdsp2 = sldisp
     C                   eval      todisp = sldisp
     C                   eval      lbrte  = *blanks
     C                   eval      lbstop = *zeros
     C                   eval      lbord  = *zeros
     C                   eval      lbspcl = 'WC'
     C                   eval      lbpo   = *blanks
     C                   eval      lbutyp = 'N'
     C                   eval      lbucod = w4um1
     C                   eval      lbucub = itcube
     C                   eval      lbcube = itcube * w4qty1
     C                   eval      lbuwgt = itswgt
     C                   eval      lbswgt = itswgt * w4qty1
     C                   eval      lbqalc = w4qty1
     C                   eval      lbqrmn = *zeros
     C                   eval      lbqpck = w4qty1
 2B  C                   if        w2item = toitem
     C                   eval      lbgrp1 = '1'
 2X  C                   else
     C                   eval      lbgrp1 = '2'
 2E  C                   endif
     C                   eval      lbgrp2 = 'A'
     C                   eval      lbtype = 'T'
     *     - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbpal# = 0
     C                   eval      lbtrn# = pttrn#
     C                   eval      lbctr# = 0
     C                   eval      lbstat = 'C'
     C                   eval      lbprty = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvtdt
     C                   eval      lbsdte = $cvd8o
     C                   time                    lbstim
     C                   eval      lbrdte = $cvd8o
     C                   write     lbrec
     *
     *     - Create second label record
     *         - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbdisp = todisp
     C                   eval      lbdsp2 = fmdisp
     C                   eval      lbgrp2 = 'B'
     C                   write     lbrec
     *
 1E  C                   endsl
     *
     *    Create transfer record for breakdown 1 qty.
     *
 1B  C                   select
 1X  C                   when      w4qty2 <> 0
     *
     *    Retrieve From Slot record info for label record.
     C                   if        w4qty1 > 0
     C     sl2key        chain(n)  slot2
     C                   endif
     *
     C                   eval      lbwhse = itwhse
     C                   eval      lbwhdp = itwhdp
     C                   eval      lbseq  = w2nrpk
     C                   eval      lbitem = w2item
     C                   eval      toitem = w2item
     C                   eval      lbpbat = 0
     C                   eval      lbaisl = slaisl
     C                   eval      lbloc  = slloc
     C                   eval      lbrlvl = slrlvl
     C                   eval      lbhand = slhand
     C                   eval      lbpseq = slpseq
     C                   eval      lbstyp = slstyp
     C                   if        slstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
     C                   eval      lbdisp = sldisp
     C                   eval      fmdisp = sldisp
     C                   eval      lbqavl = svavl1
     *
     *    Retrieve tie/high for From slot.
     *      Note:  In a normal transfer, the tie/high of the To Slot would
     *             normally be used.  But since the To Slot is created by
     *             the program, we're using the From Slot tie/high.
     *
     C     idkey         chain     itemdef
     C                   select
     C                   when      not %found
     C                   eval      lbtie  = *zeros
     C                   eval      lbhigh = *zeros
     *
     C                   when      %found
     C                   eval      lbtie  = idtie
     C                   eval      lbhigh = idhigh
     *
     C                   endsl
     *
     C                   select
     *
     *    Update or Create To Slot for Will Call Transfer.
     C                   when      w4qty1 <= 0
     C                   exsr      zztfwc
     *
     *    Will Call Transfer Slot already updated/created. Retrieve slot info.
     C                   when      w4qty1 > 0
     C     tokey         chain(n)  slot2
     *
     C                   endsl
     *
     *    Update Label record with To Slot info.
     *
     C                   eval      lbwhs2 = slwhse
     C                   eval      lbwhd2 = slwhdp
     C                   eval      lbasl2 = slaisl
     C                   eval      lbloc2 = slloc
     C                   eval      lblvl2 = slrlvl
     C                   eval      lbhnd2 = slhand
     C                   eval      lbdsp2 = sldisp
     C                   eval      todisp = sldisp
     C                   eval      lbrte  = *blanks
     C                   eval      lbstop = *zeros
     C                   eval      lbord  = *zeros
     C                   eval      lbspcl = 'WC'
     C                   eval      lbpo   = *blanks
     C                   eval      lbutyp = '1'
     C                   eval      lbucod = w4um2
     C                   if        itumq2 > 0
     C                   eval      lbucub = itcube / itumq2
     C                   else
     C                   eval      lbucub = itcube
     C                   endif
     C                   eval      lbcube = lbucub * w4qty2
     C                   if        itumq2 > 0
     C                   eval      lbuwgt = itswgt / itumq2
     C                   else
     C                   eval      lbuwgt = itswgt
     C                   endif
     C                   eval      lbswgt = lbuwgt * w4qty2
     C                   eval      lbqalc = w4qty2
     C                   eval      lbqrmn = *zeros
     C                   eval      lbqpck = w4qty2
     C                   eval      lbgrp1 = '1'
     C                   eval      lbgrp2 = 'A'
     C                   eval      lbtype = 'T'
     *     - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbpal# = 0
     C                   eval      lbtrn# = pttrn#
     C                   eval      lbctr# = 0
     C                   eval      lbstat = 'C'
     C                   eval      lbprty = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvtdt
     C                   eval      lbsdte = $cvd8o
     C                   time                    lbstim
     C                   eval      lbrdte = $cvd8o
     C                   write     lbrec
     *
     *     - Create second label record
     *         - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbdisp = todisp
     C                   eval      lbdsp2 = fmdisp
     C                   eval      lbgrp2 = 'B'
     C                   write     lbrec
     *
 1E  C                   endsl
     *
     *    Create transfer record for breakdown 2 qty.
     *
 1B  C                   select
 1X  C                   when      w4qty3 <> 0
     *
     *    Retrieve From Slot record info for label record.
     C                   if        w4qty1 > 0 or W4qty2 > 0
     C     sl2key        chain(n)  slot2
     C                   endif
     *
     C                   eval      lbwhse = itwhse
     C                   eval      lbwhdp = itwhdp
     C                   eval      lbseq  = w2nrpk
     C                   eval      lbitem = w2item
     C                   eval      toitem = w2item
     C                   eval      lbpbat = 0
     C                   eval      lbaisl = slaisl
     C                   eval      lbloc  = slloc
     C                   eval      lbrlvl = slrlvl
     C                   eval      lbhand = slhand
     C                   eval      lbpseq = slpseq
     C                   eval      lbstyp = slstyp
     C                   if        slstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
     C                   eval      lbdisp = sldisp
     C                   eval      fmdisp = sldisp
     C                   eval      lbqavl = svavl1
     *
     *    Retrieve tie/high for From slot.
     *      Note:  In a normal transfer, the tie/high of the To Slot would
     *             normally be used.  But since the To Slot is created by
     *             the program, we're using the From Slot tie/high.
     *
     C     idkey         chain     itemdef
     C                   select
     C                   when      not %found
     C                   eval      lbtie  = *zeros
     C                   eval      lbhigh = *zeros
     *
     C                   when      %found
     C                   eval      lbtie  = idtie
     C                   eval      lbhigh = idhigh
     *
     C                   endsl
     *
     C                   select
     *
     *    Update or Create To Slot for Will Call Transfer.
     C                   when      w4qty1 <= 0 and w4qty2 <= 0
     C                   exsr      zztfwc
     *
     *    Will Call Transfer Slot already updated/created. Retrieve slot info.
     C                   when      w4qty1 > 0 or w4qty2 > 0
     C     tokey         chain(n)  slot2
     *
     C                   endsl
     *
     *    Update Label record with To Slot info.
     *
     C                   eval      lbwhs2 = slwhse
     C                   eval      lbwhd2 = slwhdp
     C                   eval      lbasl2 = slaisl
     C                   eval      lbloc2 = slloc
     C                   eval      lblvl2 = slrlvl
     C                   eval      lbhnd2 = slhand
     C                   eval      lbdsp2 = sldisp
     C                   eval      todisp = sldisp
     C                   eval      lbrte  = *blanks
     C                   eval      lbstop = *zeros
     C                   eval      lbord  = *zeros
     C                   eval      lbspcl = 'WC'
     C                   eval      lbpo   = *blanks
     C                   eval      lbutyp = '2'
     C                   eval      lbucod = w4um3
     C                   if        itumq3 > 0
     C                   eval      lbucub = itcube / itumq3
     C                   else
     C                   eval      lbucub = itcube
     C                   endif
     C                   eval      lbcube = lbucub * w4qty3
     C                   if        itumq3 > 0
     C                   eval      lbuwgt = itswgt / itumq3
     C                   else
     C                   eval      lbuwgt = itswgt
     C                   endif
     C                   eval      lbswgt = lbuwgt * w4qty3
     C                   eval      lbqalc = w4qty3
     C                   eval      lbqrmn = *zeros
     C                   eval      lbqpck = w4qty3
     C                   eval      lbgrp1 = '1'
     C                   eval      lbgrp2 = 'A'
     C                   eval      lbtype = 'T'
     *     - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbpal# = 0
     C                   eval      lbtrn# = pttrn#
     C                   eval      lbctr# = 0
     C                   eval      lbstat = 'C'
     C                   eval      lbprty = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvtdt
     C                   eval      lbsdte = $cvd8o
     C                   time                    lbstim
     C                   eval      lbrdte = $cvd8o
     C                   write     lbrec
     *
     *     - Create second label record
     *         - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbdisp = todisp
     C                   eval      lbdsp2 = fmdisp
     C                   eval      lbgrp2 = 'B'
     C                   write     lbrec
     *
 1E  C                   endsl
     *    Update ITEMQTY held quantities.
     C                   exsr      zzuhld
     *
     *    Return to screen 2 and wait for next item.
     *
     C                   exsr      scr02i
     *
     C     endup4        endsr

     *----------------------------------------------------------------
     *
     *  ZZUPD9   Update for screen 9.
     *
     C     zzupd9        begsr
     C                   move      *off          error
     *
     *    Retrieve current task / transaction.
     C                   eval      curtrn = 0
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   exsr      zztask
     *
     *    End current transaction and update total time.
     C                   if        curent = *on
     C                   exsr      zztfend
     C                   endif
     *
     *    Start Idle transaction while waiting for user to start new batch.
     C                   exsr      zzidle
     *
     C     endup9        endsr

     *----------------------------------------------------------------
     *
     *  ZZUPD99  Update for screen 99.
     *
     C     zzupd99       begsr
     C                   move      *off          error
     C                   select
     C                   when      rtnto = '01 '
     C                   exsr      scr01i
     *
     C                   when      rtnto = '02 '
     C                   exsr      scr02i
     *
     C                   when      rtnto = '03 '
     C                   exsr      scr03i
     *
     C                   when      rtnto = '04 '
     C                   exsr      scr04i
     *
     C                   when      rtnto = '09 '
     C                   exsr      scr09i
     *
     C                   endsl
     *
     C     endup99       endsr
640aA*----------------------------------------------------------------*********
640aA*
640aA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640aA*
640aA /free
640aA   begsr zzwrttrand;
640aA     wrtpcmd = '*ONETRAN';
640aA     wrtpwait = 0;
640aA     wrtpwhse = ptwhse;
640aA     wrtptran# = pttrn#;
640aA     wrtpfrmdate = 0;
640aA     wrtptodate = 0;
640aA     wrtpemp# = 0;
640aA
640aA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640aA               wrtpfrmdate: wrtptodate: wrtpemp#);
640aA   endsr;
640aA /end-free
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
F10=Finish
F12=Cancel
