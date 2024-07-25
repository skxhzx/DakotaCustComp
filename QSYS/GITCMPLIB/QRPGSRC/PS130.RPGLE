     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *
     *  PS130     Truck build pallet detail (one whse) - Display
     *  17 June 1997
     *  Dave Sommerville
     *  Roxanne Harrison
     *  Created using IT110A
     *
     *  SK110 - 1.01
     *  Note:  This is not a normal 110 program, the reads were changed to read
     *         two records and display as one in the subfile.  The subfile
     *         fields are screen fields.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
402 A*    07/29/97  DAS  4.02
     *      - Change DSFKEY and $LUKY.
     *      - Made neccesary changes throught program for key change.
404 A*    08/25/97  RH   4.04
     *      - Remove w1new1 and w1new2 from display.
404 A*    08/27/97  RH   4.04
     *      - Call PS140 with $LCMD for view or change, passed into PS130 from
     *        RH130A or RH140A.
     *
413aA*    11/22/99  MLB  4.13a
     *      - Added support to call PS160 Display Stop Splits and PS170
     *        Display item splits.
     *
414 A*    09/29/00  DAS  4.14
     *      - Added options 31 & 32 to move an entire pallet.
     *      - Added fields to DSUKEY.
     *      - Added fields to $LPARM.
     *      - Added options 31 & 31 to ZZOPT routine.
     *
415 A*    02/26/01  DAS  4.15
     *      - Don't allow options 31/32 for *VIEW.
     *
416 A*    12/17/02  DAS  4.16
     *      - Revised W1COM1/2 to be a combination of compartment code
     *        and truck zone.
     *      - Added $LPARM fields UKZON1/2 to pass truck zone.
     *      - Revise ZZOPT to initialize UKZON1/2 fields.
     *
417 A*    07/30/03  HNK  4.17
     *      - Show 'S' for single pallet stop.
417aA*    08/12/03  MLB  4.17a
     *      - Fix: Rename fields in LABEL33 file that are referenced
     *        in PLTSUM file.
417bA*    08/12/03  MLB  4.17b
     *      - Fix: Add check to CMD01 to prevent F8=Split stops and
     *        F9=Split items from being called when in View mode.
417cA*    08/17/03  DAS  4.17c
     *      - Fix: Revised ZZCSP1 and ZZCSP2 to first check WORKLBL
     *        file and then the LABEL33 file. Re: This program is
     *        called for both Built and Printed routes. Built routes
     *        only have records in the WORKLBL file.
500 A*    05/02/06  JCJ  5.00
     *      - Enh: Display field WMODE in Reverse immage on screen
     *             when in *View mode.
510aA*    12/06/06  RH   5.10a
     *      - Enh: Remove BFCADR, no longer used.
510bA*    04/03/07  RBD  5.10b
     *      - Enh: Call PS134 to get total weight to display
     *        for each column.
510cA*    06/20/07  MLB  5.10c
     *      - Fix: Revised program to not clear W1BLK1, W1BLK2
     *        fields if they have been previously set to Y, indicating
     *        a bulk pick exists in that location.
510dA*    08/21/07  TJ   5.10d
     *      - Enh: Revise fields W1BLK1/2 to be 3 characters instead
     *        of 1.  Use the 1st char for the *SP flag and the 3rd
     *        char for the bulk flag.  Change the bulk flag from 'Y'
     *        to 'B'.  Allow a space in between.
510eA*    09/06/07  LMC  5.10e
     *      - Enh: Added F7 for route notes maintenance
     *        added additional command line
     *      - Enh: Added option 2 to maintain pallet detail - PS145
510fA*    11/15/07  JCJ  5.10f
     *      - Fix: changed program to not display the single pick flag
     *             when the ignore single pick flag is on.
520 A*    08/28/08  JCJ  5.20
     *      - Enh: Coverted to rpg4
520bA*    02/05/09  CWM/MLB 5.20b  1/22  1/28
     *      - Enh: Added support for new extended stop number
     *             Retrieve stop# in routine ZZFGTS and pgm GETSTOP
520cA*    02/12/09  MLB  5.20c
     *      - Enh: Disabled option# 2=Change
     *        Removed opt 2 from ZOPT array. Removed 2=Change from
     *        elements 1 and 3 of array OPTLN per Dave S. Feature
     *        not supported within GUI TruckBuilder with no plans to add.
520dA*    03/31/09  DAS  5.20d
     *      - Enh: Added client logic.
520eA*    08/28/09  RH   5.20e
     *      - Fix: Use extended stop if not 0.
530 A*    03/11/10  JCJ  5.30
     *      - Fix: Bulk flag was getting cleared.
530aA*    06/10/10  JCJ  5.30a
     *      - Fix: Use 5 digit extended stop if not 0.
640aA*    01/17/10  RH   6.40a
     *      - Enh: Add RTEHED to get route status.
640bA*    11/15/11  JCJ  6.40b
     *      - Enh: Add Truck Template logic
     *
CWD A*    04/26/16  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. WORKLBL5 had order id, descending
     *        added to key for tote processing.
     *
710aA*    11/15/17  JCJ  7.10a
     *      - Enh: Added new stop/drop field.
     *
720aA*    09/10/18  DAS  7.20a
     *      - For TruckBuilder Enhanced, force *VIEW Mode.
     *        Only GUI DD is allowed for moving pallets for Enhanced.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Cheney
     *
CBIaA*    09/30/03  HNK  CBIa
     *      - Add indicator to display different code for Single Palet
     *        customer depending on whether they are Jails, Cruise,
     *        Export or Street.
CBIbA*    03/24/16  MLB  CBIb
     *      - Revised CBIa mod. Changed to use %SUBST cmd instead of
     *        eval so that loading doesn't clear position 2,3 of W1BLK1
     *        W1BLK2 fields.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Springfield Grocer
     *
SGCaA*    01/17/11  RH   SGCa
     *      - Enh: add ZZDSG1 & ZZDSG2 to get item designation code.
     *        display '*' in postion 2 of *SP / BLK field for
     *        ICR desg, Ice cream item.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        POSITION CURSOR
     *  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
500 A*  30        REVERSE DISPLAY PROGRAM MODE (VIEW)
     *  79        CHAIN INDICATOR
     *  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fps130fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
     Fpltsum2   if   e           k disk
     F                                     rename(psrec:record)
     Fwarehs    if   e           k disk
417 AFLabel33   if   e           k disk
640aAFLabel13   if   e           k disk
640aAF                                     prefix(lb_)
417cAFworklbl5  if   e           k disk
417cAFordh      if   e           k disk
510fAFoptionz   if   e           k disk
640aAFPiritem   if   e           k disk
640aAF                                     prefix(it_)
640aAFRtehed    if   e           k disk
640bAFtruckh    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
415 D**                  OPTLN   1   2 75
415 MD optln           s             75    dim(4) ctdata perrcd(1)
510eD*                   CMDLN   1   1 79
510eAD cmdln           s             79    dim(2) ctdata perrcd(1)
520dA*----------------------------------------------------------------
520dA*  Dakota Client IDs
520dA*
CBIaA /COPY QCOPYSRC,ID#CHENEY
SGCaA /COPY QCOPYSRC,ID#SGC
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $krte                  4      8
     D  $krtid                 9     13
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
402 MD  pswhse                 1      3  0 inz(0)
402 MD  ukrte                  4      8
402 MD  psrtid                 9     13
402 MD  psgen                 14     14  0 inz(0)
402 MD  psrow                 15     16  0 inz(0)
402 MD  ukcom1                17     17
402 MD  ukusq1                18     19  0 inz(0)
402 AD  ukpli1                20     26  0 inz(0)
402 MD  ukcom2                27     27
402 MD  ukusq2                28     29  0 inz(0)
402 AD  ukpli2                30     36  0 inz(0)
414 AD  pstype                37     37
416 AD  ukzon1                38     43
416 AD  ukzon2                44     49
     *
402 D*I            0                         1   30UKWHSE
402 D*                                       4   8 UKRTID
402 D*                                       9   9 UKTYPE
402 D*I            0                        10  100UKGEN
402 D*I            0                        11  120UKROW
402 D*I            0                        13  130UKCOL
402 D*                                      14  14 UKCOMP
402 D*I            0                        15  160UKUSQ1
402 D*I            0                        17  180UKUSQ2
402 D*I            0                        19  250UKPLID
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
402 AD  $lrte                 22     26
402 MD  $lrtid                27     31
402 MD  $lrow                 32     33  0
402 MD  $lcol                 34     34  0
402 AD  $lcomp                35     35
402 AD  $luseq                36     37  0
402 AD  $lplid                38     44  0
414 AD  $ltype                45     45
414 AD  $lgen                 46     46  0
416 AD  $lzone                47     52
510eAD  $ltruk                53     62
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
510eD*             'TM132'               C         @CHGPG
     D @chgpg          c                   const('PS145')
     D @delpg          c                   const('TM134')
     D @prtpg          c                   const('NONE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     *
     D  $pwhse                19     21  0
     D  $prtid                22     26
     D  $pgen                 27     27  0
     D  $prow                 28     29  0
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
CBIaA*----------------------------------------------------------------
CBIaA*  Redefinition data struction for OHMISC field.
CBIaA*
CBIaAD                 ds
CBIaAD  dsmisc                 1     20
CBIaAD  dssdte                 1      8
CBIaAD  dsspcl                 9     11
CBIaAD  dsrpck                12     12
CBIaAD  dxdoor                13     14
CBIaAD  dsmeat                15     15
CBIaAD  dscode                16     16
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
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
500 A*----------------------------------------------------------------
500 A*  Constants
500 A*
     D #mode           c                   const(' VIEW ')
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
     *  Work fields
     *
     D $msgf           s             10
     D $pwgt1          s             15  5
     D $pwgt2          s             15  5
     D $whs15          s             15  5
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
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
     D error           s              1
     D forceb          s              1
640aAD forever         s               n
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
     D kygen           s                   like(psgen)
     D kytype          s                   like(pstype)
640aAD kyitem          s                   like(lbitem)
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
     D svrow           s              2  0
720aAd tbEnhanced      s               n
720aAd tbType          s              1
720aAd tbWhse          s              3  0
     D top             s              1
     D warn            s              1
     D w1col           s              1  0
     D w1new1          s              1
     D w1new2          s              1
     D x               s              3  0
     D y               s              3  0
510fAD kyzone          s              6
510fAD kycode          s              8
640bAD $ptmpl          s             10
510fA*----------------------------------------------------------------
510fA*  *PICK  -  Picking options
510fA*
510fA*----------------------------------------------------------------
510fA*
510fA* Fields
510fA*
510fA*    OPNXTP  -  Next pallet number.
510fA*    OPBPCK  -  Bulk pick definition.
510fA*    OPPCUB  -  Maximum cube for PIR.
510fA*    OPFPAL  -  Pallets on fixed fork lift.
510fA*    OPFCUB  -  Maximum cube per fixed pallet.
510fA*    OPFSTP  -  Maximum stops per fixed pallet.
510fA*    OPINCL  -  Include PIR in fixed cube.
510fA*    OPSRCH  -  Number of previous pallets to search for space.
510fA*    OPFBLD  -  Fixed pallet building method.
510fA*                1 = By piece without concern for splitting stop.
510fA*                2 = By stop without splitting stop between plts.
510fA*    OPPBRK  -  Aisle to start new pallet.
510fA*    OPPBLD  -  Pallet building method.
510fA*                1 = By stop then slot location.
510fA*                2 = By slot location then stop.
510fA*                3 = Descending by stop then location.
510fA*    OPSELM  -  Selection method.
510fA*                1 = Single pass (By location).
510fA*                2 = Multiple pass (By stop).
510fA*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
510fA*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
510fA*    OPNWPL  -  Start new pallet when aisle changes if build method
510fA*               is 2=Location.
510fA*    OPSTOP  -  Prevent *SP flag (Y=Yes, N=No).
510fA*
510fA* Data structure
510fA*
510fAD opzdta          ds
510fAD  opnxtp                 1      7  0 inz(0)
510fAD  oppcub                10     14  2 inz(0)
510fAD  opfpal                15     15  0 inz(0)
510fAD  opfcub                16     20  2 inz(0)
510fAD  opincl                22     22
510fAD  opsrch                23     24  0 inz(0)
510fAD  opfstp                25     26  0 inz(0)
510fAD  opfbld                27     27  0 inz(0)
510fAD  opbpck                28     30  0 inz(0)
510fAD  oppbrk                31     33
510fAD  oppbld                34     34
510fAD  opselm                35     35
510fAD  opsplt                36     36
510fAD  opbmrg                37     37
510fAD  opnwpl                38     38
510fAD  opstop                61     61
510fAD  opdend               117    117

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

720aAd/copy qcopysrc,p.gettbtyp

417aAILjrec33
417aAI              pscomp                      comp33
417aAI              pstzon                      tzon33
417aAI              pspzon                      pzon33
417aAI              pstruk                      truk33
417aAI              psrow                       row33
417aAI              pscol                       col33
417aAI              psmaxc                      maxc33
417aAI              pspal#                      pal#33
417aAI              psstp1                      stp133
417aAI              psstp2                      stp233
417aAI              pspcs                       pcs33
417aAI              pscube                      cube33
417aAI              psswgt                      swgt33
417aAI              pstype                      type33
417aAI              psbcnt                      bcnt33
417aAI              psflag                      flag33
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
     *  Let the show begin .....
     *
     C     *entry        plist
404 AC                   parm                    $pcmmd            8
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
510a *                    CALL 'BFCADR'
510a *                    PARM           $RTN    8
510a *          $RTN      IFEQ '*EXPIRED'
510a *                    MOVE 'EOJ'     NXTSCR
510a *                    MOVE '*EXIT   '$RTNCD
510a *                    ELSE
     C                   exsr      zzinz2
510aD*                    END
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     *
     C                   if        $rtncd = '*EXIT   '  or
     C                             $rtncd = '*CANCEL '
     C                   seton                                        lr
     C                   endif
     C                   return
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
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      deldsp
     C                   endif
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
     C                   eval      nxtscr = '01 '
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     clr0306
     C                   write     delrec
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   write     cmddel
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        begsr
     C                   eval      nxtscr = '01 '
     C                   eval      *in90 = *off
     C                   write     clr0306
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = frstky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
     C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
     C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
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
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
     C                   endcs
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
520dA*
520dA* Get client id.
520dA*
520dAC                   call      'GETCLIENT'
520dAC                   parm                    client           10
520dAC                   parm                    cliloc           10
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
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR CMD3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        10            x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl
     C                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
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
     C                   if        *inkf
     C                   exsr      inzpar
     C                   eval      $pcmd = '*ADD    '
     C                   exsr      zzlget
     C                   call      @chgpg
510eD*R                   PARM           $PARMS
510eAC                   parm                    $lparm
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     C                   if        $prtn <> '*CANCEL '  and
     C                             $prtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
402 D*                    MOVE $PWHSE    UKWHSE
402 D*                    MOVE $PRTID    UKRTID
402 D*                    Z-ADD$PGEN     UKGEN
402 D*                    Z-ADD$PROW     UKROW
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
510eA*
510eA*  TEST FOR CMD7  - Route Notes Maintenance
510eA*
510eAC                   if        *inkg
510eAC                   eval      $lcmd = '*CHANGE '
510eAC                   eval      $luky = $prtky
510eAC                   call      'RH132'
510eAC                   parm                    $lparm
510eAC                   eval      pagcmd = '*REFRESH'
510eAC                   exsr      pag01
510eAC                   endif
510eA*
413aA*  TEST FOR CMD8  - Check for stop splits
413aA*
413aAC                   if        *inkh
417bAC                   if        $pcmmd = '*VIEW   '
417bAC                   eval      $lcmd = $pcmmd
417bAC                   else
413aAC                   eval      $lcmd = '*CHANGE '
417bAC                   endif
413aAC                   eval      $luky = $prtky
413aAC                   call      'PS160'
413aAC                   parm                    $lparm
413aAC                   eval      pagcmd = '*REFRESH'
413aAC                   exsr      pag01
413aAC                   endif
413aA*
413aA*  TEST FOR CMD9  - Check for item splits
413aA*
413aAC                   if        *inki
417bAC                   if        $pcmmd = '*VIEW   '
417bAC                   eval      $lcmd = $pcmmd
417bAC                   else
413aAC                   eval      $lcmd = '*CHANGE '
417bAC                   endif
413aAC                   eval      $luky = $prtky
413aAC                   call      'PS170'
413aAC                   parm                    $lparm
413aAC                   eval      pagcmd = '*REFRESH'
413aAC                   exsr      pag01
413aAC                   endif
     *
     *  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
     C                   if        *inkj
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       10            row#
     C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       CMD01E
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
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
     C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      scr02e
     C                   goto      cmd02e
     C                   endif
     C     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
     C                   if        recno < 11
     C                   add       1             recno
     C                   z-add     recno         y
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
     C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
     C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
520bAC                   exsr      zzFgts
     C                   exsr      zzfill
     C                   eval      option = wkoopt
     C                   write     dspsfl
     C                   endif
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
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
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
     C                   eval      frstky = $puky
     *
     *  Delete the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   if        wkoopt = ' 4'
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
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     *
     *     Delete canceled
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   else
     *
     *     Delete was successful.
     *
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   if        cancel = '0'
     C                   delete    wkorec
     C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   endif
     *
     C                   endif
     C                   enddo
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
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
     C                   endcs
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
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   eval      $pofky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dsfkey = $pofky
221 AC     fileky        setll     record
221 D*R         TMKEY     SETLLRECORD
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
     C                   eval      otaken = *off
     *
     *     DO ALL DELETES FIRST (OPTION 4)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 4'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 4'
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
     C                   goto      optnse
     C                   endif
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = '0'
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = '1'
     C                   eval      stop = *on
     C                   if        error = '1'
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        refrsh = '1'
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     C                   select
     *
     *   Change
     *
     C                   when      wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
510eAC                   eval      $lcmd = '*CHANGE '
510eAC                   eval      dsukey = $puky
510eAC                   eval      $luky = $prtky
510eAC                   eval      $lrow = psrow
510eAC                   eval      $lcol = 1
510eAC                   eval      $lcomp = ukcom1
510eAC                   eval      $luseq = ukusq1
510eAC                   eval      $lplid = ukpli1
510eAC                   eval      $lzone = ukzon1
510eAC                   eval      $ltype = pstype
510eAC                   eval      $lgen = psgen
510eAC                   eval      $ltruk = pstruk
     C                   call      @chgpg
510eD*R                   PARM           $PARMS
510eAC                   parm                    $lparm
     *
     *   View
     *
     C                   when      wkoopt = ' 5'
510eD*R                   MOVE '*VIEW   '$PCMD
510eAC                   eval      $lcmd = '*VIEW   '
510eAC                   eval      dsukey = $puky
510eAC                   eval      $luky = $prtky
510eAC                   eval      $lrow = psrow
510eAC                   eval      $lcol = 1
510eAC                   eval      $lcomp = ukcom1
510eAC                   eval      $luseq = ukusq1
510eAC                   eval      $lplid = ukpli1
510eAC                   eval      $lzone = ukzon1
510eAC                   eval      $ltype = pstype
510eAC                   eval      $lgen = psgen
510eAC                   eval      $ltruk = pstruk
     C                   call      @chgpg
510eD*R                   PARM           $PARMS
510eAC                   parm                    $lparm
     *
     *   Print
     *
     C                   when      wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
     *
     C                   other
     C                   exsr      zzopt
     C                   endsl
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $prtn = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
     C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
510bAC                   eval      $whs15 = $kwhse
510bAC                   eval      $pwgt1 = 0
510bAC                   eval      $pwgt2 = 0
510bAC                   eval      $prtn = *blanks
510bAC                   eval      $pmsg = *blanks
510bAC                   call      'PS134'
510bAC                   parm                    $whs15
510bAC                   parm                    $krtid
510bAC                   parm                    $pwgt1
510bAC                   parm                    $pwgt2
510bAC                   parm                    $prtn
510bAC                   parm                    $pmsg
510bAC                   z-add     $pwgt1        w1wgt1
510bAC                   z-add     $pwgt2        w1wgt2
     *R         CLERR     CABEQ'1'       PAG01E
     C                   eval      bot = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
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
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   eval      bot = *off
     C                   exsr      pag2fw
     C                   endif
     C                   endif
     C                   endif
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
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfac        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
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
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C                   if        goback = 10
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
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
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw2
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C                   endif
     C     endfw2        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
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
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C     wkoprt        setgt     workopt
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ FILE
     *
     C                   dou       stop = '1'
     C     wkoprt        readpe    workopt                                79
     *
     *  HIT TOP OF FILE
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk2
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk2        tag
     C                   enddo
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C     wkoprt        setll     workopt
     C                   endif
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
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
     C                   readc     dspsfl                                 79
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     C                   endif
     *
     *  SAVE OPTION
     *
     C                   z-add     recno         y
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   if        recno < 11
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
520bAC                   exsr      zzFgts
     C                   exsr      zzfill
     C                   write     dspsfl
     C                   endif
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
     C                   if        error <> '1'
     C     1             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl
     C                   endif
     C                   endif
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
     C     1             do        10            x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
     C                   update    dspsfl
     C                   endif
     C                   enddo
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
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
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
     C                   parm      #prog         #pgmq
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
     *R                   WRITECLRSCR
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
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0001  Option under construction.
     *
     C     zm0001        begsr
     C                   eval      #msgid = 'PIR0001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   eval      #msgid = 'PIR0104'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
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
     *
417 A*  ZZCSP1   Check for single pallet stops.
     *
417 AC     zzcsp1        begsr
510cD*                    MOVE ' '       W1BLK1
510fAC                   eval      kyzone = *blanks
417cA*
417cA*   First, try and find order header using WORKLBL file.
417cA*
417cAC     keylw5        chain     worklbl5                           75
417cAC                   if        not *in75
417cAC     keyoh         chain     ordh                               75
417cAC                   if        not *in75
510fAC                   eval      kyzone = lwszon
417cAC                   goto      chksp1
417cAC                   endif
417cAC                   endif
417cA*
417cA*   If it couldn't be found, then try using LABEL33 file.
417cA*
     C     lbkey         chain     label33                            75
417cMC                   if        *in75
417cAC                   goto      endsp1
510fAC                   else
510fAC                   eval      kyzone = psszon
417cAC                   endif
417cA*
417cA*   Found header record. Now check for *SP.
417cA*
417cMC     chksp1        tag
     C     '*SP'         scan      ohmisc                                 50
     C                   if        *in50
CBIaAC                   if        client = cheney
CBIaAC                   eval      dsmisc = ohmisc
CBIbDC*                  eval      w1blk1 = dscode
CBIbMC                   eval      %subst(w1blk1:1:1) = dscode
CBIaAC                   else
530 D ***                eval      w1blk1 = 'S'
530 MC                   eval      %subst(w1blk1:1:1) = 'S'
CBIaAC                   endif
510dMC                   else
530 D ***                eval      w1blk1 = ' '
530 MC                   eval      %subst(w1blk1:1:1) = ' '
     C                   endif
640bA*
640bA*    Get truck information.
640bA*
640bAC     keyth         chain     truckh
640bAC                   if        %found(truckh)
640bAC                             and thtype = 'T'
640bAC                   eval      $ptmpl = thztmp
640bAC                   else
640bAC                   eval      $ptmpl = pstruk
640bAC                   endif
417cD*
417cD*   Clear *SP flag if the ignore flag is on.
417cD*
510fAC                   eval      kycode = '*PICK'
510fAC     keyopz        chain     optionz
510fAC                   if        %found(optionz)
510fAC                             and opstop = 'Y'
510fAC                   eval      %subst(w1blk1:1:1) = *blank
510fAC                   endif
510fA *
417 AC     endsp1        endsr
     *----------------------------------------------------------------
     *
417 A*  ZZCSP2   Check for single pallet stops.
     *
417 AC     zzcsp2        begsr
510cD*                    MOVE ' '       W1BLK2
510fAC                   eval      kyzone = *blanks
417cA*
417cA*   First, try and find order header using WORKLBL file.
417cA*
417cAC     keylw5        chain     worklbl5                           75
417cAC                   if        not *in75
417cAC     keyoh         chain     ordh                               75
417cAC                   if        not *in75
510fAC                   eval      kyzone = lwszon
417cAC                   goto      chksp2
417cAC                   endif
417cAC                   endif
417cA*
417cA*   If it couldn't be found, then try using LABEL33 file.
417cA*
     C     lbkey         chain     label33                            75
417cMC                   if        *in75
417cAC                   goto      endsp2
510fAC                   else
510fAC                   eval      kyzone = psszon
417cAC                   endif
417cA*
417cA*   Found header record. Now check for *SP.
417cA*
417cMC     chksp2        tag
     C     '*SP'         scan      ohmisc                                 50
     C                   if        *in50
CBIaAC                   if        client = cheney
CBIaAC                   eval      dsmisc = ohmisc
CBIbDC*                  eval      w1blk1 = dscode
CBIbMC                   eval      %subst(w1blk2:1:1) = dscode
CBIaAC                   else
530 D ***                eval      w1blk2 = 'S'
530 MC                   eval      %subst(w1blk2:1:1) = 'S'
CBIaAC                   endif
510dDC                   else
530 D ***                eval      w1blk2 = ' '
530 MC                   eval      %subst(w1blk2:1:1) = ' '
     C                   endif
417cD*
417cD*   Clear *SP flag if the ignore flag is on.
417cD*
510fAC                   eval      kycode = '*PICK'
510fAC     keyopz        chain     optionz
510fAC                   if        %found(optionz)
510fAC                             and opstop = 'Y'
510fAC                   eval      %subst(w1blk2:1:1) = *blank
510fAC                   endif
510fA *
417 AC     endsp2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
221 A*    Code to use to read two records and combine as one for subfile.
     C                   eval      w1col = 1
510dAC                   eval      w1blk1 = ' '
510dAC                   eval      w1blk2 = ' '
     C     filuky        chain     record                             79
     C                   if        not *in79
     C                   eval      w1row = psrow
416 D**                   MOVE PSCOMP    W1COM1
416 AC                   eval      w1com1 = *blanks
416 AC     pscomp        cat       '-':0         w1com1
416 AC     w1com1        cat       pstzon:0      w1com1
     C                   eval      w1pcs1 = pspcs
     C                   z-add     pscube        w1cub1
     C                   eval      w1seq1 = psunld
     C                   eval      w1st11 = psstp1
     C                   eval      w1st21 = psstp2
     C                   if        psbcnt > 0
510dD***                  MOVE 'Y'       W1BLK1
530 D ***                eval      w1blk1 = 'B'
530 MC                   eval      %subst(w1blk1:3:1) = 'B'
     C                   else
530 D ***                eval      w1blk1 = ' '
530 MC                   eval      %subst(w1blk1:3:1) = ' '
     C                   endif
417 AC                   if        psstp1 > 0  and
417 AC                             psstp2 > 0  and
417 AC                             psstp1 = psstp2  or
417aAC                             psstp1 > 0  and
417aAC                             psstp2 = 0
417 AC                   exsr      zzcsp1
417 AC                   endif
SGCaD*   Set Designation IceCream flag.
SGCaAC                   if        client = sgc
SGCaAC                   exsr      zzdsg1
SGCaAC                   endif
     C                   if        psflag = *on
     C                   eval      w1new1 = 'Y'
     C                   else
     C                   eval      w1new1 = ' '
     C                   endif
402 D*                    Z-ADDPSWHSE    UKWHSE
402 D*                    MOVE PSRTID    UKRTID
402 D*                    Z-ADDPSROW     UKROW
     C                   eval      ukusq1 = psunld
402 MC                   eval      ukcom1 = pscomp
402 AC                   eval      ukpli1 = psplid
416 AC                   eval      ukzon1 = pstzon
     *R
     C                   eval      w1col = 2
     C     filuky        chain     record                             76
     C                   if        not *in76
416 D**                   MOVE PSCOMP    W1COM2
416 AC                   eval      w1com2 = *blanks
416 AC     pscomp        cat       '-':0         w1com2
416 AC     w1com2        cat       pstzon:0      w1com2
     C                   eval      w1pcs2 = pspcs
     C                   z-add     pscube        w1cub2
     C                   eval      w1seq2 = psunld
     C                   eval      w1st12 = psstp1
     C                   eval      w1st22 = psstp2
     C                   if        psbcnt > 0
510dD***                  MOVE 'Y'       W1BLK2
530 D ***                eval      w1blk2 = 'B'
530 MC                   eval      %subst(w1blk2:3:1) = 'B'
     C                   else
530 D ***                eval      w1blk2 = ' '
530 MC                   eval      %subst(w1blk2:3:1) = ' '
     C                   endif
417 AC                   if        psstp1 > 0  and
417 AC                             psstp2 > 0  and
417 AC                             psstp1 = psstp2  or
417aAC                             psstp1 > 0  and
417aAC                             psstp2 = 0
417 AC                   exsr      zzcsp2
417 AC                   endif
SGCaD*   Set Designation IceCream flag.
SGCaAC                   if        client = sgc
SGCaAC                   exsr      zzdsg2
SGCaAC                   endif
     C                   if        psflag = *on
     C                   eval      w1new2 = 'Y'
     C                   else
     C                   eval      w1new2 = ' '
     C                   endif
402 AC                   eval      ukusq2 = psunld
402 AC                   eval      ukcom2 = pscomp
402 AC                   eval      ukpli2 = psplid
416 AC                   eval      ukzon2 = pstzon
     C                   else
     C                   eval      w1com2 = *blanks
     C                   eval      w1pcs2 = 0
     C                   eval      w1cub2 = 0
     C                   eval      w1seq2 = 0
     C                   eval      w1st12 = 0
     C                   eval      w1st22 = 0
     C                   eval      w1blk2 = ' '
     C                   eval      w1new2 = ' '
     C                   endif
     C                   else
     C                   eval      w1col = 2
     C     filuky        chain     record                             79
     C                   if        not *in79
     C                   eval      w1com1 = *blanks
     C                   eval      w1pcs1 = 0
     C                   eval      w1cub1 = 0
     C                   eval      w1seq1 = 0
     C                   eval      w1st11 = 0
     C                   eval      w1st21 = 0
     C                   eval      w1blk1 = ' '
     C                   eval      w1new1 = ' '
     C                   eval      w1row = psrow
416 A**                   MOVE PSCOMP    W1COM2
416 AC                   eval      w1com2 = *blanks
416 AC     pscomp        cat       '-':0         w1com2
416 AC     w1com2        cat       pstzon:0      w1com2
     C                   eval      w1pcs2 = pspcs
     C                   z-add     pscube        w1cub2
     C                   eval      w1seq2 = psunld
     C                   eval      w1st12 = psstp1
     C                   eval      w1st22 = psstp2
     C                   if        psbcnt > 0
510cD***                  MOVE 'Y'       W1BLK2
530 D ***                eval      w1blk2 = 'B'
530 MC                   eval      %subst(w1blk2:3:1) = 'B'
     C                   else
530 D ***                eval      w1blk2 = ' '
530 MC                   eval      %subst(w1blk2:3:1) = ' '
     C                   endif
417 AC                   if        psstp1 > 0  and
417 AC                             psstp2 > 0  and
417 AC                             psstp1 = psstp2  or
417aAC                             psstp1 > 0  and
417aAC                             psstp2 = 0
417 AC                   exsr      zzcsp2
417 AC                   endif
SGCaD*   Set Designation IceCream flag.
SGCaAC                   if        client = sgc
SGCaAC                   exsr      zzdsg2
SGCaAC                   endif
     C                   if        psflag = *on
     C                   eval      w1new2 = 'Y'
     C                   else
     C                   eval      w1new2 = ' '
     C                   endif
402 D*                    Z-ADDPSWHSE    UKWHSE
402 D*                    MOVE PSRTID    UKRTID
402 D*                    Z-ADDPSROW     UKROW
     C                   eval      ukusq2 = psunld
402 MC                   eval      ukcom2 = pscomp
402 AC                   eval      ukpli2 = psplid
416 AC                   eval      ukzon2 = pstzon
     C                   endif
     C                   endif
221 AC     fileky        setgt     record
221 D*R         TMKEY     SETGTRECORD
     *
     *    Code to use when file key and unique key are different.
     *
     *R         FILUKY    CHAINRECORDU              79
     *
     C                   endsr
SGCaA*----------------------------------------------------------------
     *
SGC A*  ZZDSG1   Check for Ice Cream Item designaiton code.
     *
SGC AC     zzdsg1        begsr
SGC AC                   select
SGC A*
SGCaA*   Process WORKLBL file for built routes.
SGCaAC                   when      rhstat = '3'
SGCaA*
SGCaAC     keylw5        setll     worklbl5
SGCaAC                   dow       forever = forever
SGCaAC     keylw5        reade     worklbl5
SGCaAC                   if        %eof(worklbl5)
SGCaAC                   leave
SGCaAC                   endif
SGCaAC                   eval      kyitem = lwitem
SGCaAC     keyit         chain     piritem
SGCaAC                   if        %found(piritem)
SGCaAC                   if        it_itdesg = 'ICR'
SGCaAC                   eval      %subst(w1blk1:2:1) = '*'
SGCaAC                   goto      endds1
SGCaAC                   endif
SGCaAC                   endif
SGCaAC                   iter
SGCaAC                   enddo
SGCaA*
SGCaA*   Route not at built status, try using LABEL13 file.
SGCaA*
SGCaAC                   other
SGCaAC     keylw5        setll     label13
SGCaAC                   dow       forever = forever
SGCa C     keylw5        reade     label13
SGCaAC                   if        %eof(label13)
SGCaAC                   leave
SGCaAC                   endif
SGCaAC                   eval      kyitem = lb_lbitem
SGCaAC     keyit         chain     piritem
SGCaAC                   if        %found(piritem)
SGCaAC                   if        it_itdesg = 'ICR'
SGCaAC                   eval      %subst(w1blk1:2:1) = '*'
SGCaAC                   goto      endds1
SGCaAC                   endif
SGCaAC                   endif
SGCaAC                   iter
SGCaAC                   enddo
SGCaA*
SGCaAC                   endsl
SGCaA*
SGCaAC     endds1        endsr
SGCaA*----------------------------------------------------------------
     *
SGCaA*  ZZDSG2   Check for Ice Cream Item designaiton code.
     *
SGCaAC     zzdsg2        begsr
SGCaA*
SGCaAC                   select
SGCaA*   Process WORKLBL file for built routes.
SGCaA*
SGCaAC                   when      rhstat = '3'
SGCaAC     keylw5        setll     worklbl5
SGCaAC                   dow       forever = forever
SGCa C     keylw5        reade     worklbl5
SGCaAC                   if        %eof(worklbl5)
SGCaAC                   leave
SGCaAC                   endif
SGCaAC                   eval      kyitem = lwitem
SGCaAC     keyit         chain     piritem
SGCaAC                   if        %found(piritem)
SGCaAC                   if        it_itdesg = 'ICR'
SGCaAC                   eval      %subst(w1blk2:2:1) = '*'
SGCaAC                   goto      endds2
SGCaAC                   endif
SGCaAC                   endif
SGCaAC                   iter
SGCaAC                   enddo
SGCaA*
SGCaA*   Route not at build status, try using LABEL13 file.
SGCaA*
SGCaAC                   other
SGCaAC     keylw5        setll     label13
SGCaAC                   dow       forever = forever
SGCa C     keylw5        reade     label13
SGCaAC                   if        %eof(label13)
SGCaAC                   leave
SGCaAC                   endif
SGCaAC                   eval      kyitem = lb_lbitem
SGCaAC     keyit         chain     piritem
SGCaAC                   if        %found(piritem)
SGCaAC                   if        it_itdesg = 'ICR'
SGCaAC                   eval      %subst(w1blk2:2:1) = '*'
SGCaAC                   goto      endds2
SGCaAC                   endif
SGCaAC                   endif
SGCaAC                   iter
SGCaAC                   enddo
SGCaA*
SGCaAC                   endsl
SGCaA *
SGCaAC     endds2        endsr
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
221 D*R         PARTKY    READERECORD                   79
     *
     *
221 A*    Code to use to read two records and combine as one for subfile.
510dAC                   eval      w1blk1 = ' '
510dAC                   eval      w1blk2 = ' '
     C     partky        reade     record                                 79
     C                   if        not *in79
     C                   if        pscol = 1
     C                   eval      svrow = psrow
     C                   eval      w1row = psrow
     C                   eval      w1col = pscol
416 D**                   MOVE PSCOMP    W1COM1
416 AC                   eval      w1com1 = *blanks
416 AC     pscomp        cat       '-':0         w1com1
416 AC     w1com1        cat       pstzon:0      w1com1
     C                   eval      w1pcs1 = pspcs
     C                   z-add     pscube        w1cub1
     C                   eval      w1seq1 = psunld
     C                   eval      w1st11 = psstp1
     C                   eval      w1st21 = psstp2
     C                   if        psbcnt > 0
510cD***                  MOVE 'Y'       W1BLK1
530 D ***                eval      w1blk1 = 'B'
530 MC                   eval      %subst(w1blk1:3:1) = 'B'
     C                   else
530 D ***                eval      w1blk1 = ' '
530 MC                   eval      %subst(w1blk1:3:1) = ' '
     C                   endif
417 AC                   if        psstp1 > 0  and
417 AC                             psstp2 > 0  and
417 AC                             psstp1 = psstp2  or
417aAC                             psstp1 > 0  and
417aAC                             psstp2 = 0
417 AC                   exsr      zzcsp1
417 AC                   endif
SGCaD*   Set Designation IceCream flag.
SGCaAC                   if        client = sgc
SGCaAC                   exsr      zzdsg1
SGCaAC                   endif
     C                   if        psflag = *on
     C                   eval      w1new1 = 'Y'
     C                   else
     C                   eval      w1new1 = ' '
     C                   endif
402 D*                    Z-ADDPSWHSE    UKWHSE
222 D*R                   MOVE PSTRUK    UKRTID
402 D*                    MOVE PSRTID    UKRTID
402 D*                    Z-ADDPSROW     UKROW
     C                   eval      ukusq1 = psunld
402 MC                   eval      ukcom1 = pscomp
402 AC                   eval      ukpli1 = psplid
416 AC                   eval      ukzon1 = pstzon
     C     partky        reade     record                                 76
     C                   if        not *in76  and
     C                             psrow = svrow
416 D**                   MOVE PSCOMP    W1COM2
416 AC                   eval      w1com2 = *blanks
416 AC     pscomp        cat       '-':0         w1com2
416 AC     w1com2        cat       pstzon:0      w1com2
     C                   eval      w1pcs2 = pspcs
     C                   z-add     pscube        w1cub2
     C                   eval      w1seq2 = psunld
     C                   eval      w1st12 = psstp1
     C                   eval      w1st22 = psstp2
     C                   if        psbcnt > 0
510cD***                  MOVE 'Y'       W1BLK2
530 D ***                eval      w1blk2 = 'B'
530 MC                   eval      %subst(w1blk2:3:1) = 'B'
     C                   else
530 D ***                eval      w1blk2 = ' '
530 MC                   eval      %subst(w1blk2:3:1) = ' '
     C                   endif
417 AC                   if        psstp1 > 0  and
417 AC                             psstp2 > 0  and
417 AC                             psstp1 = psstp2  or
417aAC                             psstp1 > 0  and
417aAC                             psstp2 = 0
417 AC                   exsr      zzcsp2
417 AC                   endif
SGCaD*   Set Designation IceCream flag.
SGCaAC                   if        client = sgc
SGCaAC                   exsr      zzdsg2
SGCaAC                   endif
     C                   if        psflag = *on
     C                   eval      w1new2 = 'Y'
     C                   else
     C                   eval      w1new2 = ' '
     C                   endif
402 AC                   eval      ukusq2 = psunld
402 AC                   eval      ukcom2 = pscomp
402 AC                   eval      ukpli2 = psplid
416 AC                   eval      ukzon2 = pstzon
     C                   else
     C                   eval      w1com2 = *blanks
     C                   eval      w1pcs2 = 0
     C                   eval      w1cub2 = 0
     C                   eval      w1seq2 = 0
     C                   eval      w1st12 = 0
     C                   eval      w1st22 = 0
     C                   eval      w1blk2 = ' '
     C                   eval      w1new2 = ' '
     C                   endif
222 AC                   eval      ukusq2 = w1seq2
     C                   else
     C                   eval      w1row = psrow
     C                   eval      w1com1 = *blanks
     C                   eval      w1pcs1 = 0
     C                   eval      w1cub1 = 0
     C                   eval      w1seq1 = 0
     C                   eval      w1blk1 = ' '
     C                   eval      w1new1 = ' '
416 A**                   MOVE PSCOMP    W1COM2
416 AC                   eval      w1com2 = *blanks
416 AC     pscomp        cat       '-':0         w1com2
416 AC     w1com2        cat       pstzon:0      w1com2
     C                   eval      w1pcs2 = pspcs
     C                   z-add     pscube        w1cub2
     C                   eval      w1seq2 = psunld
     C                   eval      w1st12 = psstp1
     C                   eval      w1st22 = psstp2
     C                   if        psbcnt > 0
510cD***                  MOVE 'Y'       W1BLK2
530 D ***                eval      w1blk2 = 'B'
530 MC                   eval      %subst(w1blk2:3:1) = 'B'
     C                   else
530 D ***                eval      w1blk2 = ' '
530 MC                   eval      %subst(w1blk2:3:1) = ' '
     C                   endif
417 AC                   if        psstp1 > 0  and
417 AC                             psstp2 > 0  and
417 AC                             psstp1 = psstp2  or
417aAC                             psstp1 > 0  and
417aAC                             psstp2 = 0
417 AC                   exsr      zzcsp2
417 AC                   endif
SGCaD*   Set Designation IceCream flag.
SGCaAC                   if        client = sgc
SGCaAC                   exsr      zzdsg2
SGCaAC                   endif
     C                   if        psflag = *on
     C                   eval      w1new2 = 'Y'
     C                   else
     C                   eval      w1new2 = ' '
     C                   endif
402 D*                    Z-ADDPSWHSE    UKWHSE
402 D*                    MOVE PSRTID    UKRTID
402 D*                    Z-ADDPSROW     UKROW
     C                   eval      ukusq2 = psunld
402 MC                   eval      ukcom2 = pscomp
402 AC                   eval      ukpli2 = psplid
416 AC                   eval      ukzon2 = pstzon
     C                   endif
     C                   endif
     *R
221 AC     fileky        setgt     record
221 D*R         TMKEY     SETGTRECORD
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
     C                   move      psrow         svrow
     C     doptag        tag
     C     partky        readpe    record                                 79
     C                   if        not *in79
     C     psrow         cabeq     svrow         doptag
402 D*                    Z-ADDPSROW     UKROW
221 AC     fileky        setll     record
221 D*R         TMKEY     SETLLRECORD
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGTFS   Get Host Stop Number
     *
520bAC     ZZFGTS        BEGSR
     *
520bAC                   Z-ADD     *zeros        $sord
     *
     *    Get Column 1 From Stop From RTESTp
     *
     C                   z-add     w1st11        $sdstp
520bAC                   CALL      'GETSTOP'
520bAC                   PARM      '*PLTSTP '    $scmd             8
520bMC                   PARM      pswhse        $swhse            3 0
520bAC                   PARM      $krtid        $srtid            5
520bAC                   PARM                    $sord             7 0
520bAC                   PARM                    $sdstp            2 0
520bAC                   PARM                    $sstop            5 0
710aAc                   parm                    $pDdrop           3
710aAc                   parm                    $pDextd          30
710aAc                   parm                    $pDsd             9
530aD *
530aD ***                if        $sdstp > 0
530aD ***                move      $sdstp        w1st11
530aD ***                else
530aD ***                move      $sstop        w1st11
530aD ***                endif
530aMC*
530aMC                   if        $sstop > 0
530aMC                   move      $sstop        w1st11
530aMC                   else
530aMC                   move      $sdstp        w1st11
530aMC                   endif
     *
     *    Get Column 1 TO Stop From RTESTp
     *
     C                   z-add     w1st21        $pdstp
520bAC                   CALL      'GETSTOP'
520bAC                   PARM      '*PLTSTP '    $PCMD             8
520bMC                   PARM      pswhse        $SWHSE            3 0
520bAC                   PARM      $krtid        $PRTID            5
520bAC                   PARM                    $PORD             7 0
520bAC                   PARM                    $PDSTP            2 0
520bAC                   PARM                    $PSTOP            5 0
710aAc                   parm                    $pDdrop
710aAc                   parm                    $pDextd
710aAc                   parm                    $pDsd
530aD ***
530aD ***                if        $pdstp > 0
530aD ***                move      $pdstp        w1st21
530aD ***                else
530aD ***                move      $pstop        w1st21
530aD ***                endif
530aD***
530aMC*
530aMC                   if        $pstop > 0
530aMC                   move      $pstop        w1st21
530aMC                   else
530aMC                   move      $pdstp        w1st21
530aMC                   endif
     *    Get Column 2 From Stop From RTESTp
520bA*
     C                   z-add     w1st12        $pdstp
520bAC                   CALL      'GETSTOP'
520bAC                   PARM      '*PLTSTP '    $PCMD             8
520bMC                   PARM      pswhse        $SWHSE            3 0
520bAC                   PARM      $krtid        $PRTID            5
520bAC                   PARM                    $PORD             7 0
520bAC                   PARM                    $PDSTP            2 0
520bAC                   PARM                    $PSTOP            5 0
710aAc                   parm                    $pDdrop
710aAc                   parm                    $pDextd
710aAc                   parm                    $pDsd
530aD ***
530aD ***                if        $pdstp > 0
530aD ***                move      $pdstp        w1st12
530aD ***                else
530aD ***                move      $pstop        w1st12
530aD ***                endif
530aMC*
530aMC                   if        $pstop > 0
530aMC                   move      $pstop        w1st12
530aMC                   else
530aMC                   move      $pdstp        w1st12
530aMC                   endif
520bA*
     *    Get Column 2 TO Stop From RTESTp
520bA*
520bAC                   z-add     w1st22        $pdstp
520bAC                   CALL      'GETSTOP'
520bAC                   PARM      '*PLTSTP '    $PCMD             8
520bMC                   PARM      pswhse        $SWHSE            3 0
520bAC                   PARM      $krtid        $PRTID            5
520bAC                   PARM                    $PORD             7 0
520bAC                   PARM                    $PDSTP            2 0
520bAC                   PARM                    $PSTOP            5 0
710aAc                   parm                    $pDdrop
710aAc                   parm                    $pDextd
710aAc                   parm                    $pDsd
530aM ***
530aM ***                if        $pdstp > 0
530aM ***                move      $pdstp        w1st22
530aM ***                else
530aM ***                move      $pstop        w1st22
530aM ***                endif
530aMC*
530aMC                   if        $pstop > 0
530aMC                   move      $pstop        w1st22
530aMC                   else
530aMC                   move      $pdstp        w1st22
530aMC                   endif
520bAC*
520bAC                   ENDSR
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $krtid
     C                   kfld                    kytype
     C                   kfld                    kygen
     C                   kfld                    psrow
     C                   kfld                    w1col
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $krtid
     C                   kfld                    kytype
     C                   kfld                    kygen
     C                   kfld                    psrow
221 D*R                   KFLD           UKCOL
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $krtid
     C                   kfld                    kytype
     C                   kfld                    kygen
     *
417 A*  Define key for LABEL33
417 A*
417 AC     lbkey         klist
417 AC                   kfld                    pswhse
417 AC                   kfld                    psrtid
417 AC                   kfld                    pstrn#
417 AC                   kfld                    psstp1
     *
417cA*  Define key for WORKLBL5
417cA*
417cAC     keylw5        klist
417cAC                   kfld                    pswhse
417cAC                   kfld                    psrtid
417cAC                   kfld                    psplid
     *
SGCaA*  Define key for PIRITEM
SGCaA*
SGCaAC     keyit         klist
SGCaAC                   kfld                    $kwhse
SGCaAC                   kfld                    kyitem
     *
417cA*  Define key for ORDH
417cA*
417cAC     keyoh         klist
417cAC                   kfld                    lwwhse
417cAC                   kfld                    lword
     *
     *  Define unique file key.
     *
402 D*          TMKEY     KLIST
402 D*                    KFLD           UKWHSE
402 D*                    KFLD           UKRTID
402 D*                    KFLD           UKTYPE
402 D*                    KFLD           UKGEN
402 D*                    KFLD           UKROW
510fA*
510fA*  Define partial key for options file.
510fA*
510fAC     keyopz        klist
510fAC                   kfld                    kycode
510fAC                   kfld                    $kwhse
640bD ***                kfld                    pstruk
640bMC                   kfld                    $ptmpl
510fAC                   kfld                    kyzone
640aA*
640aA*  Define key for RTEHED  file.
640aA*
640aAC     keyrth        klist
640aAC                   kfld                    $kwhse
640aAC                   kfld                    $krtid
640bA*
640bA*  Define key for truck file.
640bA*
640bAC     keyth         klist
640bAC                   kfld                    $kwhse
640bAC                   kfld                    pstruk
720aAc*
720aAc*  Force *VIEW mode if using TruckBUilder Enhanced
720aAc*  Only GUI DD can be used for Enhanced.
720aAc*
720aA /free
720aA      tbWhse = $kwhse;
720aA      GetTBType(tbWhse: $krtid: tbType);
720aA      if tbType = 'E';
720aA        tbEnhanced = *on;
             $pcmmd = '*VIEW';
720bA      else;
720bA        tbEnhanced = *off;
720ba      endif;
720bA /end-free
     *
     *  Setup option and command display lines.
     *
415 AC                   if        $pcmmd = '*VIEW'
415 AC                   eval      optln1 = optln(3)
415 AC                   eval      optln2 = optln(4)
500 AC                   eval      wmode = #mode
500 AC                   eval      *in30 = *on
415 AC                   else
     C                   eval      optln1 = optln(1)
     C                   eval      optln2 = optln(2)
500 AC                   eval      wmode = *blanks
500 AC                   eval      *in30 = *off
415 AC                   endif
     C                   eval      cmdln1 = cmdln(1)
510eAC                   eval      cmdln2 = cmdln(2)
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from main line.
     *
     C     zzinz2        begsr
     C                   eval      kytype = 'O'
     C                   eval      kygen = 1
     *
     C                   eval      wowhse = *blanks
     C     $kwhse        chain     warehs                             79
     C                   if        not *in79
     C                   eval      $cstr = *blanks
     C                   move      whcode        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         wowhse
     C     wowhse        cat       '-':1         wowhse
     C     wowhse        cat       whdesc:1      wowhse
     C                   endif
     C                   eval      worte = $krte
640aAC     keyrth        chain     rtehed
640aAC                   if        not %found(rtehed)
640aAC*                  eval      rhstat = '3'
640aAC                   endif
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
     *  ZZLGET   Find last row for truck.
     *
     *
     C     zzlget        begsr
     *
     C     partky        setgt     record
     C     partky        readpe    record                                 79
     C                   if        not *in79
     C                   eval      $prow = psrow
     C                   else
     C                   eval      $prow = 0
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     C                   select
     *
     *   Left pallet detail
     *
     C                   when      wkoopt = ' 8'
222 D*                    MOVE *ON       ERROR
222 D*                    MOVE *ON       CANCEL
222 D*                    MOVE *BLANKS   ERRMSG
222 D*                    EXSR ZM0001
222 M*                    MOVE W1COM1    $COM    1
222 M*                    Z-ADDW1SEQ1    $SEQ    20
222 M*                    MOVE $KRTE     $RTE    5
222 M*                    Z-ADD$KWHSE    $LWHSE
222 M*                    MOVE $KRTID    $LRTID
     *
402 D*                    MOVE $PUKY     DSUKEY
402 D*                    MOVE UKCOMP    $COM    1
402 D*                    Z-ADDUKUSQ1    $SEQ    20
402 D*                    MOVE $KRTE     $RTE    5
402 D*                    Z-ADDUKWHSE    $LWHSE
402 D*                    MOVE UKRTID    $LRTID
402 D*                    Z-ADDUKROW     $LROW
     *R                   MOVE $PUKY     $LUKY
     *
402 MC                   eval      $lcmd = $pcmmd
402 MC                   eval      dsukey = $puky
402 MC                   eval      $luky = $prtky
402 MC                   eval      $lrow = psrow
402 MC                   eval      $lcol = 1
402 MC                   eval      $lcomp = ukcom1
402 MC                   eval      $luseq = ukusq1
402 MC                   eval      $lplid = ukpli1
416 AC                   eval      $lzone = ukzon1
222 MC                   call      'PS140'
404 AC                   parm                    $lcmd
222 MC                   parm                    $luky
222 MC                   parm                    $lrtn
402 D*                    PARM           $COM
402 D*                    PARM           $SEQ
402 D*                    PARM           $RTE
     *
     *   Right pallet detail
     *
     C                   when      wkoopt = ' 9'
222 D*                    MOVE *ON       ERROR
222 D*                    MOVE *ON       CANCEL
222 D*                    MOVE *BLANKS   ERRMSG
222 D*                    EXSR ZM0001
222 M*                    MOVE W1COM2    $COM
222 M*                    Z-ADDW1SEQ2    $SEQ
222 M*                    MOVE $KRTE     $RTE
222 M*                    Z-ADD$KWHSE    $LWHSE
222 M*                    MOVE $KRTID    $LRTID
     *
402 D*                    MOVE $PUKY     DSUKEY
402 D*                    MOVE UKCOMP    $COM    1
402 D*                    Z-ADDUKUSQ2    $SEQ    20
402 D*                    MOVE $KRTE     $RTE    5
402 D*                    Z-ADDUKWHSE    $LWHSE
402 D*                    MOVE UKRTID    $LRTID
402 D*                    Z-ADDUKROW     $LROW
402 D*                    Z-ADD2         $LCOL
     *
404 MC                   eval      $lcmd = $pcmmd
402 MC                   eval      dsukey = $puky
402 MC                   eval      $luky = $prtky
402 MC                   eval      $lrow = psrow
402 MC                   eval      $lcol = 2
402 MC                   eval      $lcomp = ukcom2
402 MC                   eval      $luseq = ukusq2
402 MC                   eval      $lplid = ukpli2
416 AC                   eval      $lzone = ukzon2
222 MC                   call      'PS140'
404 AC                   parm                    $lcmd
222 MC                   parm                    $luky
222 MC                   parm                    $lrtn
402 D*                    PARM           $COM
402 D*                    PARM           $SEQ
402 D*                    PARM           $RTE
     *
414 A*
414 A*   Move left pallet to another pallet
414 A*
414 AC                   when      wkoopt = '31'  and
415 AC                             $pcmmd <> '*VIEW'
414 AC                   eval      $lcmd = '*CHANGE '
414 AC                   eval      dsukey = $puky
414 AC                   eval      $luky = $prtky
414 AC                   eval      $lrow = psrow
414 AC                   eval      $lcol = 1
414 AC                   eval      $lcomp = ukcom1
414 AC                   eval      $luseq = ukusq1
414 AC                   eval      $lplid = ukpli1
416 AC                   eval      $lzone = ukzon1
414 AC                   eval      $ltype = pstype
414 AC                   eval      $lgen = psgen
414 AC                   call      'PS132'
414 AC                   parm                    $lparm
414 A*
414 A*   Move right pallet to another pallet
414 A*
414 AC                   when      wkoopt = '32'  and
415 AC                             $pcmmd <> '*VIEW'
414 AC                   eval      $lcmd = '*CHANGE '
414 AC                   eval      dsukey = $puky
414 AC                   eval      $luky = $prtky
414 AC                   eval      $lrow = psrow
414 AC                   eval      $lcol = 2
414 AC                   eval      $lcomp = ukcom2
414 AC                   eval      $luseq = ukusq2
414 AC                   eval      $lplid = ukpli2
416 AC                   eval      $lzone = ukzon2
414 AC                   eval      $ltype = pstype
414 AC                   eval      $lgen = psgen
414 AC                   call      'PS132'
414 AC                   parm                    $lparm
     *
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *
     *  See if user is trying to position to code
     *
     C                   if        ptinp2 <> 0
402 D*                    Z-ADDPTINP2    UKROW
402 MC                   eval      psrow = ptinp2
     C                   eval      ptinp2 = 0
     C                   eval      repos = *on
     C                   endif
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
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
   8 93132
**  OPTLN - Option display line
            8=Column 1 pallet detail  31=Move column 1 pallet
            9=Column 2 pallet detail  32=Move column 2 pallet
            8=Column 1 pallet detail
            9=Column 2 pallet detail
**  CMDLN - Command display line
F3=Exit  F5=Refresh  F12=Cancel
F7=Notes  F8=Chk stop splits  F9=Chk item splits
