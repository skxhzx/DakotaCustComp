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
     *  IT112     Item maintenance - Change
     *  09 July 1994
     *  Dave Sommerville
     *
     *  SK112 - 1.01
     *
     *  Revisions
     *
DRI A*    10/22/01  DAS  4.16
     *      - Total rewrite. Changed to use DRI interface programs.
     *
416aA*    01/17/02  DAS  4.16a
     *      - Revised calculation of decmal value in routine ZZTIE.
     *        ILE doesn't like it when you take a 5.2 number and try to
     *        put it into a 2.2 number. ILE gives a "Target for a numeric
     *        operation is too small to hold the result" error.
     *
416bA*    01/24/02  DAS  4.16b
     *      - Revised to only do one call to the DRI interface.
     *        The interface program will make the call to the host.
     *      - Revised to use '%' as the first character of the subcommand
     *        instead of '*'. This identifies that the call to the
     *        interface was initiated from Dakota and not the Host.
     *      - Revised the way the ZM0001 routines identify if the message
     *        was sent back from the host.
     *
416cA*    01/29/02  DAS  4.16c
     *      - Revised to combine screen 4 and screen 1.
     *
416dA*    06/11/03  DAS  4.16d
     *      - C#ITEM revised to have two data structures, $item and $item2.
     *      - Revised program to work with second data structure.
     *
417 A*    06/11/03  DAS  4.17
     *      - Added W1ODAY # of out days to screen.
     *      - Added fields W1LTRK and W2LOT.
     *
500 A*    11/13/04  DAS  5.00
     *      - Changed Tracking options from No, Low, High, to Low,
     *        Med, High.
500aA*    11/23/04  MLB  5.00a
     *      - Fix: Revise program when called w/ *WORKTIE to set W1RPKG
     *        flag based on $ITTYPE. Revise ZZUPD3 to set $ittype based
     *        on W1RPKG.
500bA*    01/19/05  MLB  5.00b
     *      - Fix: Revise fill$item when processing screen 2, 3 fields,
     *        to send $imnrpk field to be verified.
500cA*    05/24/05  RH   5.00c
     *      - ENH: Call IT820 to update LABEL/PIRTRAN for manual put-
     *        away if department changes.
     *
500dA*    11/03/05  DAS  5.00d
     *      - ENH: Added category field.
     *
500eA*    12/21/05  DAS  5.00e
     *      - ENH: Revised F4 row/col locations that were changed because
     *        of 500d.
     *      - ENH: Added Category lookup.
     *
510 A*    06/20/06  RMC  5.10
     *      - ENH: Update file ITEMEXT when IFCAT changes.
510aA*    07/24/06  MLB  5.10a
     *      - Fix: Changed rcdfmt to IKREC from IXTREC.
510bA*    08/27/06  MLB  5.10b
     *      - Enh: ITEMEXT file changed. Recompiled program.
510cA*    01/24/07  TLJ  5.10c
     *      - Enh: For new item type Repack, remove several fields
     *        from screen IT112.01 and .02.  Add 3 new fields and
     *        make Full Case Item mandatory.
510dA*    02/23/07  DAS  5.10d
     *      - Enh: For Repack item, revised to set indicators 92/93
     *        based on $itumq2/3 instead of $itflg1/2.
     *      - Revised to initialize Parent Repack qtys.
     *      - Revised to display Repack heading for Repack items.
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

     Fif112fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
212 AFpackage1  if   e           k disk
     Foptions   if   e           k disk
212 AFslotdef   if   e           k disk
212 AFworkopt   if   e           k disk
510  Fitemext1  uf a e           k disk
510  Fitemfld   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a10             s              1    dim(10)
511aDD**xtd            s             40    dim(2) ctdata perrcd(1)
511aMD extd            s             40    dim(3) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item
510  *----------------------------------------------------------------
510  *  Customer id
510  *----------------------------------------------------------------
510
510   /copy qcopysrc,id#packers

     D savever#        s                   like($itver#)
     D save$item       s                   like($item)
416dAD save$item2      s                   like($item2)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D actcub          s                   like($itcube)
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D cubdif          s              7  3
     D decmal          s              2  2
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
     D error           s               n
     D fillscreen      s              3
     D help            s              5  0
     D hldilm          s             15
     D kyulen          s                   like($itulen)
     D kyuwdt          s                   like($ituwdt)
     D kywhse          s                   like($pwhse)
     D maxdif          s              9  6
     D msgk            s              4  0
     D n               s              3  0
     D nxtscr          s              3
     D ovrhng          s              3  2
     D ovrrid          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sc2flg          s              1
     D sc3flg          s              1
     D sclear          s              1
     D t#tie           s             10
     D tmpflg          s              1
     D tnter           s              5  0
     D w3tie           s                   like(w3tie1)
     D warn            s              1
     D whse            s              3  0
     D zmsflag         s               n
500cAD svwhdp          s                   like($itwhdp)
510cAD #svitver#       s                   like($itver#)
510cAD #svitwhse       s                   like($itwhse)
510cAD #svititem       s                   like($ititem)
510cAD #svitmitem      s                   like($itmitem)
510cAD #svitcitem      s                   like($itcitem)
510cAD #svittype       s                   like($ittype)
510cAD #svitdesc       s                   like($itdesc)
510cAD #svitstyp       s                   like($itstyp)
510cAD #svitwhdp       s                   like($itwhdp)
510cAD #svitdesg       s                   like($itdesg)
510cAD #svitactv       s                   like($itactv)
510cAD #svitupc        s                   like($itupc)
510cAD #svitbld        s                   like($itbld)
510cAD #svitven#       s                   like($itven#)
510cAD #svitvit#       s                   like($itvit#)
510cAD #svitpdsc       s                   like($itpdsc)
510cAD #svitum1        s                   like($itum1)
510cAD #svitflg1       s                   like($itflg1)
510cAD #svitum2        s                   like($itum2)
510cAD #svitumq2       s                   like($itumq2)
510cAD #svitflg2       s                   like($itflg2)
510cAD #svitum3        s                   like($itum3)
510cAD #svitumq3       s                   like($itumq3)
510cAD #svitulen       s                   like($itulen)
510cAD #svituwdt       s                   like($ituwdt)
510cAD #svituhgt       s                   like($ituhgt)
510cAD #svitcube       s                   like($itcube)
510cAD #svitswgt       s                   like($itswgt)
510cAD #svitcwgt       s                   like($itcwgt)
510cAD #svitreor       s                   like($itreor)
510cAD #svitrepl       s                   like($itrepl)
510cAD #svitrcvd       s                   like($itrcvd)
510cAD #svitflgd       s                   like($itflgd)
510cAD #svitflgb       s                   like($itflgb)
510cAD #svitslif       s                   like($itslif)
510cAD #svitnday       s                   like($itnday)
510cAD #svitsdef       s              2    dim(5)
510cAD #svittie        s              4s 0 dim(5)
510cAD #svithigh       s              2s 0 dim(5)
510cAD #svitum         s              1    dim(5)
510cAD #svitpref       s              1    dim(5)
510cAD #svixdsc1       s                   like($ixdsc1)
510cAD #svixdsc2       s                   like($ixdsc2)
510cAD #svimtie        s                   like($imtie)
510cAD #svimhigh       s                   like($imhigh)
510cAD #svimmflg       s                   like($immflg)
510cAD #svimdday       s                   like($imdday)
510cAD #svimuday       s                   like($imuday)
510cAD #svimmday       s                   like($immday)
510cAD #svimwrnc       s                   like($imwrnc)
510cAD #svimrg1c       s                   like($imrg1c)
510cAD #svimrg2c       s                   like($imrg2c)
510cAD #svimapck       s                   like($imapck)
510cAD #svimnrpk       s                   like($imnrpk)
510cAD #svimnslt       s                   like($imnslt)
510cAD #svimxdck       s                   like($imxdck)
510cAD #svimbnbr       s                   like($imbnbr)
510cAD #svimbnam       s                   like($imbnam)
510cAD #svimvnam       s                   like($imvnam)
510cAD #svimbrnd       s                   like($imbrnd)
510cAD #svimlot        s                   like($imlot)
510cAD #svimltrk       s                   like($imltrk)
510cAD #svimoday       s                   like($imoday)
510cAD #svifcat        s                   like($ifcat)
510cAD #svkcqty1       s                   like($kcqty1)
510cAD #svkcqty2       s                   like($kcqty2)
510cAD #svkcqty3       s                   like($kcqty3)

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
411 AD  $pitpe               137    137
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pitem                22     36
219 AD  $pxflg                37     37

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
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lsdef                22     23
     D  $lwhdp                22     26
     D  $litem                22     36
     *
     D  $ldesg                19     23
     *
     D  $lactv                19     20
     *
500eAD  $lcat                 19     28
     *
     D  $lum                  19     20
     *
     D  $lbc                  19     20
212 A*
212 AD  $lwhs1                19     21  0
212 AD  $litm1                22     36
212 AD  $lwhd1                37     41
212 AD  $lsty1                42     42
212 AD  $lst1                 43     44
212 AD  $lpal1                45     50
212 AD  $lovr1                51     53  2
     *
212 AD  $lwhs2                19     21  0
212 AD  $lwhd2                22     26
212 AD  $litm2                27     41
212 AD  $lcnt                 42     44  0
212 AD  $lrepl                45     45
212 AD  $lulen                46     50  2
212 AD  $luwdt                51     55  2
212 AD  $lstyp                56     56
212 A*----------------------------------------------------------------
212 A*  Data structure for DSFKEY
212 A*
212 AD                 ds
212 AD  wkfkey                 1     50
212 AD  wksdef                 1      2
212 AD  wktie                  3      6  0 inz(0)
212 AD  wkhigh                 7      8  0 inz(0)
     *----------------------------------------------------------------
     *  *ITEMMNT  -  Item maintenance options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPSTYP  -  Default section type
     *    OPWHDP  -  Default warehouse department
     *    OPUM1   -  Default normal unit of measure
     *    OPDUM   -  Unit of measure for dimensions
     *    OPCUM   -  Unit of measure for cube
     *    OPCDIV  -  Divisor for cube
     *    OPCAUT  -  Automaticaly calculate cube when zero (Y/N)
     *    OPCWRN  -  Display cube warning (Y/N)
     *    OPCRNG  -  Display cube warning range percentage
     *    OPWUM   -  Unit of measure for weight
     *
     * Data structure
     *
     D opdata          ds
     D  opstyp                 1      1
     D  opwhdp                 2      6
     D  opum1                  7      8
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  3
     D  opwum                 58     72
     D  optend               117    117
213 A*----------------------------------------------------------------
213 A*  *PATTERN  -  Tie pattern options.
213 A*----------------------------------------------------------------
213 A*
213 A* Fields
213 A*
213 A*    OPHANG  -  Pallet overhang.
213 A*    OPDINC  -  Dimension increment.
213 A*
213 A* Data structure
213 A*
213 AD opdat1          ds
213 AD  ophang                 1      3  2
213 AD  opdinc                 4      6  2
213 AD  opten1               117    117
412 A*----------------------------------------------------------------
412 A*  *SYSTEM  -  System options.
412 A*----------------------------------------------------------------
412 A*
412 A* Fields
412 A*
412 A*    OPEPM   -  Using EPM module (Y,N).
412 A*    OPRF    -  Using RF module (Y,N).
412 A*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
412 A*    OPLETD  -  Print letdown labels (Y,N).
412 A*    OPWRNC  -  Perform catch weight variance check (Y,N).
412 A*    OPRG1C  -  Catch weight low variance percentage.
412 A*    OPRG2C  -  Catch weight high variance percentage.
412 A*    OPIMPI  -  Import item fields from host.(Y,N).
412 A*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
412 A*
412 A* Data structure
412 A*
412 AD opdat2          ds
412 AD  opepm                  1      1
412 AD  oprf                   2      2
412 AD  opcapc                 3      3
412 AD  opletd                 4      4
412 AD  opwrnc                 5      5
412 AD  oprg1c                 6      8  1
412 AD  oprg2c                 9     11  1
412 AD  opimpi                12     12
412 AD  opmpck                14     14
412 AD  opten2               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erulen                 1      3p 2
     D  eruwdt                 4      6p 2
     D  eruhgt                 7      9p 2
     D  ercalc                10     13p 3
     D  ercube                14     17p 3
     D  ercdiv                18     22p 2
     D  ercrng                23     24p 1
     D  ermax                 25     28p 4
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  eritem                 1     15
DRI AD  ercode                16     25
412 A*
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
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new record.
     *              *EDIT    - Edit record.
     *              *PRINT   - Print record.
     *              *VIEW    - View record.
     *              *WORKTIE - Work with tie/highs
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for everything but *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new unique key for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C                   exsr      init
510cAC                   eval      *in92 = *off
510cAC                   eval      *in93 = *off
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in95 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      sc2flg = *off
     C                   eval      sc3flg = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   MOVE      *ON           *IN59
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
     C     nxtscr        caseq     '04 '         sc1
 2E  C                   endcs
 1E  C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr

     *  Close interface

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop

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
 1B  C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
 1E  C                   endif
 1B  C                   if        nxtscr = '03 '
     C                   exfmt     screen3                              50
 1E  C                   endif
 1B  C                   if        nxtscr = '04 '
     C                   exfmt     screen4                              50
 1E  C                   endif
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
417 AC                   setoff                                       414243
500dAC                   setoff                                       44
     C                   setoff                                       616263
     C                   setoff                                       646566
     C                   setoff                                       676869
     C                   setoff                                       70
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
416cDC**                 if        $pxflg = '0'
     C                   move      '01 '         nxtscr
416cDC**                 else
416cDC**                 move      '04 '         nxtscr
416cDC**                 endif
     *
 1B  C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
 1E  C                   endif
     *
     *  Refresh screen fields if requested.
     *
 1B  C                   if        refrsh = *on
     *
     *     Get field defaults if this is an add.
     *
 2B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
 2X  C                   else
     *
     *     Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
 2E  C                   endif
 1E  C                   endif
     C                   eval      refrsh = *off
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     *
 1B  C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
416cDC**                 if        $pxflg = '0'
     C                   eval      woitem = %trim(w1item) + ' - ' + w1desc
416cDC**                 else
416cDC**                 eval      woitem = %trim(w1item) + ' - ' + w1dsc1
416cDC**                 endif
 1E  C                   endif
     *
     *  Refresh screen fields if requested.
     *
 1B  C                   if        refrsh = *on
     *
     *     Get field defaults if this is an add.
     *
 2B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
510cAC                   exsr      zzuompar
 2X  C                   else
     *
     *     Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
510cAC                   exsr      zzuompar
 2E  C                   endif
 1E  C                   endif
     C                   eval      refrsh = *off
     C                   eval      sc2flg = *on
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   move      '03 '         nxtscr
     *
     *     Get field defaults if this is an add.
     *
 1B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft3
 1X  C                   else
     *
     *     Otherwise get existing record(s).
     *
     C                   exsr      zzfil3
 1E  C                   endif
     *
     C                   eval      refrsh = *off
     C                   eval      sc3flg = *on
     C     end03i        endsr
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
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr01i
 2E  C                   endif
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *      F9 - View warehouse quantities.
     *
 1B  C                   if        *inki
     C                   eval      whse = $pwhse
     C                   call      'IT810'
     C                   parm                    whse
     C                   parm                    $pitem
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
416cDC**                 if        $pxflg = '0'
     C                   exsr      zzcmd1
416cDC**                 else
416cDC**                 exsr      zzcmd4
416cDC**                 endif
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
 1B  C                   if        $pcmd = '*ADD    '
     *R         $PCMD     OREQ '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     *R                   EXSR ZZGET1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
 1E  C                   endif
     *
 1B  C                   if        $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzget1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
 1E  C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
416cDC**                 if        $pxflg = '0'
     C                   exsr      zzcmd1
416cDC**                 else
416cDC**                 exsr      zzcmd4
416cDC**                 endif
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so onto the next screen.
     *
 1B  C                   if        sc2flg = *off
     C                   move      *on           refrsh
 1X  C                   else
     C                   move      *off          refrsh
 1E  C                   endif
     C                   exsr      scr02i
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
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr02i
 2E  C                   endif
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *      F9 - View warehouse quantities.
     *
 1B  C                   if        *inki
     C                   eval      whse = $pwhse
     C                   call      'IT810'
     C                   parm                    whse
     C                   parm                    $pitem
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
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
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
 1E  C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so get out of program.
     *
     C                   exsr      scr03i
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
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   exsr      scr03i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl  and
     C                             $pcmd <> '*WORKTIE'
     C                   exsr      scr02i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
 1B  C                   if        *inkl  and
     C                             $pcmd = '*WORKTIE'
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     *
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '  or
     C                             $pcmd = '*WORKTIE'
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
 1E  C                   endif
     *
     C                   move      'EOJ'         nxtscr
     C     endsc3        endsr
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
     C                   movel     $pitem        hldilm
     C                   eval      tnter = 0
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
     *  Setup heading based on type being entered
     *
 1B  C                   if        $pitpe = ' '
     C                   eval      hdtype = extd(1)
 1X  C                   else
511aAC                   if        $pitpe = 'R'
511aAC                   eval      hdtype = extd(3)
511aAC                   else
     C                   eval      *in96 = *off
     C                   eval      hdtype = extd(2)
511aAC                   endif
 1E  C                   endif
510cAC                   if        $pitpe = 'R'
510cAC                   eval      *in45 = *off
510cAC                   else
510cAC                   eval      *in45 = *on
510cAC                   endif
     C                   move      *off          tmpflg
510
510  * Get client id.
510
510  C                   call      'GETCLIENT'
510  C                   parm                    client           10
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
     C                   write     clrscr
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
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    DRI0001s Local system caused error (send to different program)
     *----------------------------------------------------------------

     C     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
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

     *  Verify Brokencase option.

     *    Note: This is check in this program because it is not a field
     *          that is stored in the file and thus is not sent to the
     *          interface program.

     C                   if        w1rpkg <> 'Y' and w1rpkg <> 'N'
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      $drireturn  = ' '
     C                   eval      $drimessage = 'Invalid broken case '
     C                                         + 'option '
     C                                         + '(' + w1rpkg + ')'
     C                   exsr      zm0001
     C                   goto      endck1
     C                   endif

     *  Initialize interface fields.

     C                   eval      fillscreen = '01'
     C                   exsr      fill$item

     *  Dakota verification.

     C                   eval      $dricommand = '*ITEM'
     C                   if        $pcmd = '*ADD'
     C                   eval      $drisubcmd  = '%VERIFYADD'
     C                   else
     C                   eval      $drisubcmd  = '%VERIFYCHG'
     C                   endif
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *  Host verification.

     C****               if        not error
     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop
     C****               endif

     C                   if        error
     C                   goto      endck1
     C                   endif

     *  If this was a PIR item AND now is beiing changed
     *  to a FIXED item - force SCREEN1 to be redisplayed.

 1X  C                   if        $pcmd = '*CHANGE '  and
     C                             $itstyp = 'P'  and
     C                             w1styp = 'F'  and
     C                             $ittype = ' '  and
     C                             tmpflg = *off
     C                   move      *on           error
     C                   eval      *in40 = *on
     C                   eval      *in41 = *off
     C                   eval      *in20 = *on
     C                   eval      tmpflg = *on
     C                   endif

510cA*  Verify only Section F allowed when Item Type is 'R'

510cAC                   if        w1styp <> 'F'
510cAC                             and $pitpe = 'R'
510cAC                             and error = *off
510cAC                   eval      error = *on
510cAC                   eval      *in03 = *on
510cAC                   eval      *in23 = *on
510cAC                   eval      $drireturn  = ' '
510cAC                   eval      $drimessage = 'Section must be F for Repack'
510cAC                   exsr      zm0001
510cAC                   goto      endck1
510cAC                   endif

510cA*  Verify Full Case Item mandatory entry when Item Type is 'R'

510cAC                   if        w1itm2 = *blanks
510cAC                             and $pitpe = 'R'
510cAC                             and error = *off
510cAC                   eval      error = *on
510cAC                   eval      *in35 = *on
510cAC                   eval      *in15 = *on
510cAC                   eval      $drireturn  = ' '
510cAC                   eval      $drimessage = 'Full Case Item '
510cAC                                         + 'Mandatory'
510cAC                   exsr      zm0001
510cAC                   goto      endck1
510cAC                   endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCHK2   Screen 2 error checking.
     *----------------------------------------------------------------

     C     zzchk2        begsr
     C                   move      *off          error

     *  Initialize interface fields.

     C                   eval      fillscreen = '02'
     C                   exsr      fill$item

     *  Dakota verification.

     C                   eval      $dricommand = '*ITEM'
     C                   if        $pcmd = '*ADD'
     C                   eval      $drisubcmd  = '%VERIFYADD'
     C                   else
     C                   eval      $drisubcmd  = '%VERIFYCHG'
     C                   endif
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *  Host verification.

     C****               if        not error
     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop
     C****               endif

     C                   if        error
     C                   goto      endck2
     C                   endif

     *  Calculate actual cube according to dimensions entered.

 1B  C                   if        opcdiv = 0
     C                   eval      actcub = 0
 1X  C                   else
     C                   eval(h)   actcub=(w2ulen * w2uwdt * w2uhgt)/opcdiv
 1E  C                   endif

     *   Warn user if ...
     *      Display warning option is 'Y'
     *      and Cube entered has changed
     *      and Cube entered is not within +/- range of
     *          calculated cube.

 1B  C                   if        opcwrn = 'Y' and w2cube > 0 and
     C                             ovrrid = *off
     C                   eval      maxdif = actcub * opcrng
     C                   eval      cubdif = actcub - w2cube
 2B  C                   if        cubdif < 0
     C                   eval      cubdif = -(cubdif)
 2E  C                   endif
 2B  C                   if        cubdif > maxdif
     C                   move      *on           error
     C                   move      *on           warn
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erulen = w2ulen
     C                   eval      eruwdt = w2uwdt
     C                   eval      eruhgt = w2uhgt
     C                   eval      ercalc = actcub
     C                   eval      ercube = w2cube
     C                   eval      ercdiv = opcdiv
     C     opcrng        mult      100           ercrng
     C                   eval      ermax = maxdif
     C                   exsr      zm23
 2E  C                   endif
 1E  C                   endif

     C     endck2        endsr

     *----------------------------------------------------------------
     *  ZZCHK3   Screen 3 error checking.
     *----------------------------------------------------------------

     C     zzchk3        begsr
     C                   move      *off          error

     *  Initialize interface fields.

     C                   eval      fillscreen = '03'
     C                   exsr      fill$item

     *  Dakota verification.

     C                   eval      $dricommand = '*ITEM'
     C                   select
     C*                  when      $pcmd = '*WORKTIE'
     C*                  eval      $drisubcmd  = '%VERIFYDEF'
     C                   when      $pcmd = '*ADD'
     C                   eval      $drisubcmd  = '%VERIFYADD'
     C                   other
     C                   eval      $drisubcmd  = '%VERIFYCHG'
     C                   endsl
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *  Host verification.

     C****               if        not error
     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop
     C****               endif

     C                   if        error
     C                   goto      endck3
     C                   endif

     C     endck3        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '

     *  Test for F4 - Lookup

 2B  C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
 3B  C                   select

     *     Warehouse department.

 3X  C                   when      row# = 11
500eAC                             and col#>=28 and col#<=32
     C                   eval      *in04 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
 4E  C                   endif

     *     Designation area.

500eDC**                 when      row# = 12
500eMC                   when      row# = 11
500eAC                             and col#>=75 and col#<=79
     C                   eval      *in05 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $ldesg = w1desg
     C                   call      'DS900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1desg = $ldesg
 4E  C                   endif
500eA
500eA*     Category code.
500eA
500eAC                   when      row# = 12
500eAC                             and col#>=28 and col#<=37
500eAC**                 eval      *in44 = *on
500eAC                   eval      $lcmd = '*LOOKUP '
500eAC                   eval      $lcat  = w1cat
500eAC                   call      'IC900'
500eAC                   parm                    $lparm
500eAC                   if        $lrtn = '*SELECT '
500eAC                   eval      w1cat  = $lcat
500eAC                   endif

     *     Activity zone.

500eDC**                 when      row# = 13
500eMC                   when      row# = 12
500eAC                             and col#>=75 and col#<=76
     C                   eval      *in06 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lactv = w1actv
     C                   call      'AC900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1actv = $lactv
 4E  C                   endif

     *  Full case item number.

 3X  C                   when      row# = 14  and
     C                             col# >= 65
     C                   eval      *in15 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = *blanks
     C                   call      'IT900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1itm2 = $litem
 4E  C                   endif

 3X  C                   other

     *     Cursor not on a valid lookup field.

     C                   move      *on           error
     C                   exsr      zm9905
 3E  C                   endsl
goto C                   goto      endcm1
 2E  C                   endif
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZCMD2   User defined command keys for screen 2.
     *----------------------------------------------------------------

     C     zzcmd2        begsr

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '

     *  Test for F4 - Lookup

 2B  C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin

     *     Normal unit of measure.

 3B  C                   if        row# = 10  and
     C                             col# >= 39  and
     C                             col# <= 40
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lum = w2um1
     C                   call      'UM900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w2um1 = $lum
 4E  C                   endif
 3X  C                   else

     *     Breakdown 1 unit of measure.

 4B  C                   if        row# = 11  and
     C                             col# >= 39  and
     C                             col# <= 40
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lum = w2um2
     C                   call      'UM900'
     C                   parm                    $lparm
 5B  C                   if        $lrtn = '*SELECT '
     C                   eval      w2um2 = $lum
 5E  C                   endif
 4X  C                   else

     *     Breakdown 2 unit of measure.

 5B  C                   if        row# = 12  and
     C                             col# >= 39  and
     C                             col# <= 40
     C                   eval      *in04 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lum = w2um3
     C                   call      'UM900'
     C                   parm                    $lparm
 6B  C                   if        $lrtn = '*SELECT '
     C                   eval      w2um3 = $lum
 6E  C                   endif
 5X  C                   else

     *     Build code.

 6B  C                   if        row# = 18
     C                   eval      *in09 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lbc = w2bld
     C                   call      'BC900'
     C                   parm                    $lparm
 7B  C                   if        $lrtn = '*SELECT '
     C                   eval      w2bld = $lbc
 7E  C                   endif
 6X  C                   else

     *     Cursor not on a valid lookup field.

     C                   move      *on           error
     C                   exsr      zm9905
 6E  C                   endif
 5E  C                   endif
 4E  C                   endif
 3E  C                   endif

goto C                   goto      endcm2
 2E  C                   endif

     *      F20 - Accept Warning.

 2B  C                   if        *inku
     C                   move      *on           ovrrid
 2E  C                   endif
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm2        endsr

     *----------------------------------------------------------------
     *  ZZCMD3   User defined command keys for screen 3.
     *----------------------------------------------------------------

     C     zzcmd3        begsr
     C                   move      *off          cmdtkn

     *  Test for F4 - Lookup

 1B  C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin

 2B  C                   select

     *     Slot type 1.

 2X  C                   when      row# = 13  and
     C                             col# >= 9  and
     C                             col# <= 10
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = whcode
     C                   eval      $lsdef = w3st1
     C                   call      'SD900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w3st1 = $lsdef
 3X  C                   else
 4B  C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
 4X  C                   else
 5B  C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
 5E  C                   endif
 4E  C                   endif
 3E  C                   endif

     *     Slot type 2.

 2X  C                   when      row# = 14  and
     C                             col# >= 9  and
     C                             col# <= 10
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = whcode
     C                   eval      $lsdef = w3st2
     C                   call      'SD900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w3st2 = $lsdef
 3X  C                   else
 4B  C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
 4X  C                   else
 5B  C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
 5E  C                   endif
 4E  C                   endif
 3E  C                   endif

     *     Slot type 3.

 2X  C                   when      row# = 15  and
     C                             col# >= 9  and
     C                             col# <= 10
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = whcode
     C                   eval      $lsdef = w3st3
     C                   call      'SD900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w3st3 = $lsdef
 3X  C                   else
 4B  C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in23 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
 4X  C                   else
 5B  C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in23 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
 5E  C                   endif
 4E  C                   endif
 3E  C                   endif

     *     Slot type 4.

 2X  C                   when      row# = 16  and
     C                             col# >= 9  and
     C                             col# <= 10
     C                   eval      *in04 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = whcode
     C                   eval      $lsdef = w3st4
     C                   call      'SD900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w3st4 = $lsdef
 3X  C                   else
 4B  C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
 4X  C                   else
 5B  C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
 5E  C                   endif
 4E  C                   endif
 3E  C                   endif

     *     Slot type 5.

 2X  C                   when      row# = 17  and
     C                             col# >= 9  and
     C                             col# <= 10
     C                   eval      *in05 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = whcode
     C                   eval      $lsdef = w3st5
     C                   call      'SD900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w3st5 = $lsdef
 3X  C                   else
 4B  C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in25 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
 4X  C                   else
 5B  C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in25 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
 5E  C                   endif
 4E  C                   endif
 3E  C                   endif

 2X  C                   other

     *     Cursor not on a valid lookup field.

     C                   move      *on           error
     C                   exsr      zm9905
 2E  C                   endsl
goto Csr                 goto      endcm3
 1E  C                   endif

     *  Test for F9 - Call pattern program

 1B  C                   if        *inki
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin

 2B  C                   select

     *     Slot type 1.

 2X  C                   when      row# = 13  and
     C                             col# >= 9  and
     C                             col# <= 10
     C                   eval      *in01 = *on
     C                   move      w3st1         sltdef
     C                   z-add     w3tie1        w3tie
     C                   exsr      zztie

 3B  C                   if        error = *off
     C                   eval      $item = save$item
416dAC                   eval      $item2 = save$item2
     C                   eval      $lcmd = '*VIEW   '
     C                   eval      $lwhs1 = $itwhse
     C                   eval      $lwhd1 = $itwhdp
     C                   eval      $lsty1 = $itstyp
     C                   eval      $litm1 = $ititem
     C                   eval      $lst1 = w3st1
     C                   eval      $lpal1 = sdpal
     C                   eval      $lovr1 = ovrhng
     C                   eval      $lprg = #prog
     C                   call      'PATRN'
     C                   parm                    $lparm
 3X  C                   else
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm1201
 3E  C                   endif

     *     Slot type 2.

 2X  C                   when      row# = 14  and
     C                             col# >= 9  and
     C                             col# <= 10
     C                   eval      *in02 = *on
     C                   move      w3st2         sltdef
     C                   z-add     w3tie2        w3tie
     C                   exsr      zztie

 3B  C                   if        error = *off
     C                   eval      $item = save$item
416dAC                   eval      $item2 = save$item2
     C                   eval      $lcmd = '*VIEW   '
     C                   eval      $lwhs1 = $itwhse
     C                   eval      $lwhd1 = $itwhdp
     C                   eval      $lsty1 = $itstyp
     C                   eval      $litm1 = $ititem
     C                   eval      $lst1 = w3st2
     C                   eval      $lpal1 = sdpal
     C                   eval      $lovr1 = ovrhng
     C                   eval      $lprg = #prog
     C                   call      'PATRN'
     C                   parm                    $lparm
 3X  C                   else
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   exsr      zm1201
 3E  C                   endif

     *     Slot type 3.

 2X  C                   when      row# = 15  and
     C                             col# >= 9  and
     C                             col# <= 10
     C                   eval      *in03 = *on
     C                   move      w3st3         sltdef
     C                   z-add     w3tie3        w3tie
     C                   exsr      zztie

 3B  C                   if        error = *off
     C                   eval      $item = save$item
416dAC                   eval      $item2 = save$item2
     C                   eval      $lcmd = '*VIEW   '
     C                   eval      $lwhs1 = $itwhse
     C                   eval      $lwhd1 = $itwhdp
     C                   eval      $lsty1 = $itstyp
     C                   eval      $litm1 = $ititem
     C                   eval      $lst1 = w3st3
     C                   eval      $lpal1 = sdpal
     C                   eval      $lovr1 = ovrhng
     C                   eval      $lprg = #prog
     C                   call      'PATRN'
     C                   parm                    $lparm
 3X  C                   else
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   exsr      zm1201
 3E  C                   endif

     *     Slot type 4.

 2X  C                   when      row# = 16  and
     C                             col# >= 9  and
     C                             col# <= 10
     C                   eval      *in04 = *on
     C                   move      w3st4         sltdef
     C                   z-add     w3tie4        w3tie
     C                   exsr      zztie

 3B  C                   if        error = *off
     C                   eval      $item = save$item
416dAC                   eval      $item2 = save$item2
     C                   eval      $lcmd = '*VIEW   '
     C                   eval      $lwhs1 = $itwhse
     C                   eval      $lwhd1 = $itwhdp
     C                   eval      $lsty1 = $itstyp
     C                   eval      $litm1 = $ititem
     C                   eval      $lst1 = w3st4
     C                   eval      $lpal1 = sdpal
     C                   eval      $lovr1 = ovrhng
     C                   eval      $lprg = #prog
     C                   call      'PATRN'
     C                   parm                    $lparm
 3X  C                   else
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm1201
 3E  C                   endif

     *     Slot type 5.

 2X  C                   when      row# = 17  and
     C                             col# >= 9  and
     C                             col# <= 10
     C                   eval      *in05 = *on
     C                   move      w3st5         sltdef
     C                   z-add     w3tie5        w3tie
     C                   exsr      zztie

 3B  C                   if        error = *off
     C                   eval      $item = save$item
416dAC                   eval      $item2 = save$item2
     C                   eval      $lcmd = '*VIEW   '
     C                   eval      $lwhs1 = $itwhse
     C                   eval      $lwhd1 = $itwhdp
     C                   eval      $lsty1 = $itstyp
     C                   eval      $litm1 = $ititem
     C                   eval      $lst1 = w3st5
     C                   eval      $lpal1 = sdpal
     C                   eval      $lovr1 = ovrhng
     C                   eval      $lprg = #prog
     C                   call      'PATRN'
     C                   parm                    $lparm
 3X  C                   else
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   exsr      zm1201
 3E  C                   endif

 2X  C                   other

     *     Cursor not on a valid lookup field.

     C                   eval      error = *on
     C                   exsr      zm9905

 2E  C                   endsl
goto Csr                 goto      endcm3
 1E  C                   endif

     *  Test for F11- Call

 1B  C                   if        *inkk
     C                   eval      $lcnt = 0
 2B  C                   if        w3st1 <> *blanks
     C                   add       1             $lcnt
 2E  C                   endif
 2B  C                   if        w3st2 <> *blanks
     C                   add       1             $lcnt
 2E  C                   endif
 2B  C                   if        w3st3 <> *blanks
     C                   add       1             $lcnt
 2E  C                   endif
 2B  C                   if        w3st4 <> *blanks
     C                   add       1             $lcnt
 2E  C                   endif
 2B  C                   if        w3st5 <> *blanks
     C                   add       1             $lcnt
 2E  C                   endif
     C                   move      *on           cmdtkn
     C                   eval      $lwhd2 = w1whdp
     C                   eval      $litm2 = w1item
     C                   eval      $lstyp = w1styp
     C                   eval      $lulen = w2ulen
     C                   eval      $luwdt = w2uwdt
     C                   eval      $lwhs2 = $pwhse
     C                   eval      $lrepl = *blanks
     C                   call      'IT210'
     C                   parm                    $lparm
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   exsr      zzrepl
 2E  C                   endif
 1E  C                   endif

     C     endcm3        endsr

     *----------------------------------------------------------------
     *  ZZCMD4   User defined command keys for screen 4.
     *----------------------------------------------------------------

     C     zzcmd4        begsr

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '

     *  Test for F4 - Lookup

 2B  C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
 3B  C                   select

     *     Warehouse department.

 3X  C                   when      row# = 12
     C                   eval      *in04 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
 4E  C                   endif

     *     Designation area.

 3X  C                   when      row# = 13
     C                   eval      *in05 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $ldesg = w1desg
     C                   call      'DS900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1desg = $ldesg
 4E  C                   endif

     *     Activity zone.

 3X  C                   when      row# = 14
     C                   eval      *in06 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lactv = w1actv
     C                   call      'AC900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1actv = $lactv
 4E  C                   endif

     *  Full case item number.

 3X  C                   when      row# = 15  and
     C                             col# >= 65
     C                   eval      *in15 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = *blanks
     C                   call      'IT900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1itm2 = $litem
 4E  C                   endif

 3X  C                   other

     *     Cursor not on a valid lookup field.

     C                   move      *on           error
     C                   exsr      zm9905
 3E  C                   endsl
goto Csr                 goto      endcm4
 2E  C                   endif
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm4        endsr

     *----------------------------------------------------------------
     *  ZZDFT1   Get default values for add.
     *----------------------------------------------------------------

     C     zzdft1        begsr
     C                   eval      w1item = *blanks
     C                   eval      w1desc = *blanks
416cDC**                 eval      w1dsc1 = *blanks
     C                   eval      w1dsc2 = *blanks
     C                   eval      w1styp = opstyp
     C                   eval      w1whdp = opwhdp
     C                   eval      w1desg = *blanks
     C                   eval      w1actv = *blanks
 1B  C                   if        $pitpe = ' '
     C                   eval      w1rpkg = 'N'
 1X  C                   else
     C                   eval      w1rpkg = 'Y'
 1E  C                   endif
     C                   eval      w1flgd = 'N'
 1B  C                   if        w1styp = 'P'
     C                   eval      w1flgb = 'Y'
 1X  C                   else
     C                   eval      w1flgb = 'N'
 1E  C                   endif
     C                   eval      w1itm2 = *blanks
     C                   eval      w1upc = *blanks
     C                   eval      w1ven# = 0
     C                   eval      w1vit# = *blanks
     C                   eval      w1repl = 0
     C                   eval      w1mflg = 'N'
417 AC                   eval      w1oday = 0
     C                   eval      w1mday = 0
     C                   eval      w1dday = 0
     C                   eval      w1uday = 0
     C                   eval      w1nrpk = 1
500 DC**                 eval      w1ltrk = 'N'
500 MC                   eval      w1ltrk = 'L'
     C                   eval      *in41 = *off
     C                   endsr

     *----------------------------------------------------------------
     *  ZZDFT2   Get default values for add.
     *----------------------------------------------------------------

     C     zzdft2        begsr
     C                   eval      w2pdsc = *blanks
     C                   eval      w2um1 = opum1
     C                   eval      w2um2 = *blanks
     C                   eval      w2umq2 = 0
     C                   eval      w2flg1 = 'N'
     C                   eval      w2um3 = *blanks
     C                   eval      w2umq3 = 0
     C                   eval      w2flg2 = 'N'
     C                   eval      w2ulen = 0
     C                   eval      w2uwdt = 0
     C                   eval      w2uhgt = 0
     C                   eval      w2cube = 0
     C                   eval      w2swgt = 0
     C                   eval      w2cwgt = 'N'
     C                   eval      w2rg1c = 0
     C                   eval      w2rg2c = 0
     C                   eval      w2bld = *blanks
     C                   eval      w2slif = 0
     C                   eval      w2nday = 0
417 AC                   eval      w2lot = 'N'
510dAC                   eval      w2rqty1 = 0
510dAC                   eval      w2rqty2 = 0
510dAC                   eval      w2rqty3 = 0
     C                   endsr

     *----------------------------------------------------------------
     *  ZZDFT3   Get default values for add.
     *----------------------------------------------------------------

     C     zzdft3        begsr
     C                   eval      w3st1 = *blanks
     C                   eval      w3st2 = *blanks
     C                   eval      w3st3 = *blanks
     C                   eval      w3st4 = *blanks
     C                   eval      w3st5 = *blanks
     C                   eval      w3tie1 = 0
     C                   eval      w3tie2 = 0
     C                   eval      w3tie3 = 0
     C                   eval      w3tie4 = 0
     C                   eval      w3tie5 = 0
     C                   eval      w3hi1 = 0
     C                   eval      w3hi2 = 0
     C                   eval      w3hi3 = 0
     C                   eval      w3hi4 = 0
     C                   eval      w3hi5 = 0
     C                   eval      w3prf1 = *blanks
     C                   eval      w3prf2 = *blanks
     C                   eval      w3prf3 = *blanks
     C                   eval      w3prf4 = *blanks
     C                   eval      w3prf5 = *blanks
     C                   eval      w3mtie = 0
     C                   eval      w3mhi = 0
     C                   endsr

     *----------------------------------------------------------------
     *  zzerrind    Set error indicators from DRI call.
     *----------------------------------------------------------------

     C     zzerrind      begsr

     *  Screen 1/4 error indicators.

     C                   if        fillscreen = '01'

     C                   if        $ititeme = '1'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   endif

     C                   if        $itdesce = '1' or
     C                             $ixdsc1e = '1' or
     C                             $ixdsc2e = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   if        $itstype = '1'
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif

     C                   if        $itwhdpe = '1'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif

     C                   if        $itdesge = '1'
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif

     C                   if        $itactve = '1'
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif

     C                   if        $itmiteme = '1'
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     C                   endif

     C                   if        $itflgde = '1'
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   endif

     C                   if        $immflge = '1'
     C                   eval      *in36 = *on
     C                   eval      *in16 = *on
     C                   endif

     C                   if        $itflgbe = '1'
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   endif

     C                   if        $immdaye = '1'
     C                   eval      *in37 = *on
     C                   eval      *in17 = *on
     C                   endif

     C                   if        $imddaye = '1'
     C                   eval      *in38 = *on
     C                   eval      *in18 = *on
     C                   endif

     C                   if        $itven#e = '1'
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   endif

     C                   if        $imudaye = '1'
     C                   eval      *in39 = *on
     C                   eval      *in19 = *on
     C                   endif

     C                   if        $itvit#e = '1'
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   endif

     C                   if        $imnrpke = '1'
     C                   eval      *in40 = *on
     C                   eval      *in20 = *on
     C                   endif

     C                   if        $itreple = '1'
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   endif

417 AC                   if        $imodaye = '1'
417 AC                   eval      *in42 = *on
417 AC                   endif

417 AC                   if        $imltrke = '1'
417 AC                   eval      *in43 = *on
417 AC                   endif

500dAC                   if        $ifcate = '1'
500dAC                   eval      *in44 = *on
500dAC                   endif

     C                   endif

     *  Screen 2 error indicators.

     C                   if        fillscreen = '02'

     C                   if        $itpdsce = '1'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   endif

     C                   if        $itum1e = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   if        $itum2e = '1'
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif

     C                   if        $itumq2e = '1'
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   endif

     C                   if        $itflg1e = '1'
     C                   eval      *in36 = *on
     C                   eval      *in16 = *on
     C                   endif

     C                   if        $itum3e = '1'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif

     C                   if        $itumq3e = '1'
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   endif

     C                   if        $itflg1e = '1'
     C                   eval      *in37 = *on
     C                   eval      *in17 = *on
     C                   endif

     C                   if        $itulene = '1'
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif

     C                   if        $ituwdte = '1'
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif

     C                   if        $ituhgte = '1'
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   endif

     C                   if        $itcubee = '1'
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   endif

     C                   if        $itswgte = '1'
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   endif

     C                   if        $itcwgte = '1'
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   endif

     C                   if        $imrg1ce = '1'
     C                   eval      *in38 = *on
     C                   eval      *in18 = *on
     C                   endif

     C                   if        $imrg2ce = '1'
     C                   eval      *in39 = *on
     C                   eval      *in19 = *on
     C                   endif

     C                   if        $itblde = '1'
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   endif

     C                   if        $itslife = '1'
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   endif

     C                   if        $itndaye = '1'
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     C                   endif

417 AC                   if        $imlote = '1'
417 AC                   eval      *in40 = *on
417 AC                   endif

     C                   endif

     *  Screen 3 error indicators.

     C                   if        fillscreen = '03'

     C                   if        $imtiee = '1'
     C                   eval      *in36 = *on
     C                   eval      *in16 = *on
     C                   endif

     C                   if        $imhighe = '1'
     C                   eval      *in37 = *on
     C                   eval      *in17 = *on
     C                   endif

     C                   if        $idsdefe(1) = '1'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   endif
     C                   if        $idtiee(1)  = '1'
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif
     C                   if        $idhighe(1) = '1'
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   endif
     C                   if        $idprefe(1) = '1'
     C                   eval      *in61 = *on
     C                   eval      *in66 = *on
     C                   endif

     C                   if        $idsdefe(2) = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif
     C                   if        $idtiee(2)  = '1'
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   endif
     C                   if        $idhighe(2) = '1'
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   endif
     C                   if        $idprefe(2) = '1'
     C                   eval      *in62 = *on
     C                   eval      *in67 = *on
     C                   endif

     C                   if        $idsdefe(3) = '1'
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif
     C                   if        $idtiee(3)  = '1'
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   endif
     C                   if        $idhighe(3) = '1'
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   endif
     C                   if        $idprefe(3) = '1'
     C                   eval      *in63 = *on
     C                   eval      *in68 = *on
     C                   endif

     C                   if        $idsdefe(4) = '1'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif
     C                   if        $idtiee(4)  = '1'
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   endif
     C                   if        $idhighe(4) = '1'
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   endif
     C                   if        $idprefe(4) = '1'
     C                   eval      *in64 = *on
     C                   eval      *in69 = *on
     C                   endif

     C                   if        $idsdefe(5) = '1'
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif
     C                   if        $idtiee(5)  = '1'
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   endif
     C                   if        $idhighe(5) = '1'
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     C                   endif
     C                   if        $idprefe(5) = '1'
     C                   eval      *in65 = *on
     C                   eval      *in70 = *on
     C                   endif

     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

     *  Restore record information.

     C                   eval      $item = save$item
416dAC                   eval      $item2 = save$item2

     *  Initialize screen fields and indicators.

     C                   eval      w1item = $ititem
     C                   eval      w1desc = $itdesc
 1B
 1B  C                   if        $pxflg = '1'
416cMC                   eval      w1dsc2 = $ixdsc1 + $ixdsc2
416cDC**                 eval      w1dsc1 = $ixdsc1
416cDC**                 eval      w1dsc2 = $ixdsc2
 1E  C                   endif
 1B
     C                   eval      w1styp = $itstyp
     C                   eval      w1whdp = $itwhdp
     C                   eval      w1desg = $itdesg
     C                   eval      w1actv = $itactv
 1B
 1B  C                   if        $ittype = 'B'
510cAC                             or $ittype = 'R'
     C                   eval      w1rpkg = 'Y'
 1X  C                   else
     C                   eval      w1rpkg = 'N'
 1E  C                   endif
     C                   eval      w1itm2 = $itmitem
 1B
     C                   eval      w1flgd = $itflgd
     C                   eval      w1flgb = $itflgb
     C                   eval      w1upc = $itupc
     C                   eval      w1ven# = $itven#
     C                   eval      w1vit# = $itvit#
     C                   eval      w1repl = $itrepl

510cAC                   if        $ittype = 'R'
510cAC                   eval      w1mflg = 'N'
510cAC                   else
     C                   eval      w1mflg = $immflg
510cAC                   endif
     C                   eval      w1mday = $immday
     C                   eval      w1dday = $imdday
     C                   eval      w1uday = $imuday
     C                   eval      w1nrpk = $imnrpk
417 AC                   eval      w1oday = $imoday
417 AC                   eval      w1ltrk = $imltrk
500dAC                   eval      w1cat  = $ifcat
     *
     *    If this is a PIR item or not a regular or breakdown item
     *    condition display not to show number of pick slots.
     *
 1B  C                   if        $itstyp = 'P'  or
     C                             $ittype <> ' '  and
     C                             $ittype <> 'B'
     C                   eval      *in41 = *on
 1X  C                   else
     C                   eval      *in41 = *off
 1E  C                   endif
500c *    Save department to allow LABEL/TRAN department update.
500c C                   eval      svwhdp = w1whdp

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil2        begsr

     *  Restore record information.

     C                   eval      $item = save$item
416dAC                   eval      $item2 = save$item2

     *  Initialize screen fields and indicators.

     C                   eval      w2pdsc = $itpdsc
     C                   eval      w2um1  = $itum1
     C                   eval      w2um2  = $itum2
     C                   eval      w2umq2 = $itumq2
     C                   eval      w2flg1 = $itflg1
     C                   eval      w2um3  = $itum3
     C                   eval      w2umq3 = $itumq3
     C                   eval      w2flg2 = $itflg2
     C                   eval      w2ulen = $itulen
     C                   eval      w2uwdt = $ituwdt
     C                   eval      w2uhgt = $ituhgt
     C                   eval      w2cube = $itcube
     C                   eval      w2swgt = $itswgt
     C                   eval      w2cwgt = $itcwgt
     C                   eval      w2bld  = $itbld
     C                   eval      w2rg1c = $imrg1c
     C                   eval      w2rg2c = $imrg2c
     C                   eval      w2slif = $itslif
     C                   eval      w2nday = $itnday
417 AC                   eval      w2lot  = $imlot

510dAC                   if        $pitpe = 'R'
510dAC                   eval      w2rqty1 = $kcqty1
510dAC                   eval      w2rqty2 = $kcqty2
510dAC                   eval      w2rqty3 = $kcqty3
510dAC                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil3        begsr

     *  Restore record information.

     C                   eval      $item = save$item
416dAC                   eval      $item2 = save$item2

     *  Initialize screen fields and indicators.

     C                   eval      w3st1  = $idsdef(1)
     C                   eval      w3tie1 = $idtie(1)
     C                   eval      w3hi1  = $idhigh(1)
     C                   eval      w3prf1 = $idpref(1)

     C                   eval      w3st2  = $idsdef(2)
     C                   eval      w3tie2 = $idtie(2)
     C                   eval      w3hi2  = $idhigh(2)
     C                   eval      w3prf2 = $idpref(2)

     C                   eval      w3st3  = $idsdef(3)
     C                   eval      w3tie3 = $idtie(3)
     C                   eval      w3hi3  = $idhigh(3)
     C                   eval      w3prf3 = $idpref(3)

     C                   eval      w3st4  = $idsdef(4)
     C                   eval      w3tie4 = $idtie(4)
     C                   eval      w3hi4  = $idhigh(4)
     C                   eval      w3prf4 = $idpref(4)

     C                   eval      w3st5  = $idsdef(5)
     C                   eval      w3tie5 = $idtie(5)
     C                   eval      w3hi5  = $idhigh(5)
     C                   eval      w3prf5 = $idpref(5)

     C                   eval      w3mtie = $imtie
     C                   eval      w3mhi  = $imhigh

     C******             exsr      zzchk3
     C                   endsr

     *----------------------------------------------------------------
     *  ZZGET1   Get record(s) for screen 1.
     *----------------------------------------------------------------

     C     zzget1        begsr

     *   Get item information.

     C                   eval      savever# = $itver#
     C                   clear                   $item
416dAC                   clear                   $item2
     C                   eval      $itver# = savever#

     C                   eval      $itwhse   = $pwhse
     C                   eval      $ititem   = $pitem

     C                   eval      zmsflag     = *on
     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *  Save record information.

     C                   eval      save$item = $item
416dAC                   eval      save$item2 = $item2


     C     endgt1        endsr

     *----------------------------------------------------------------
     *  ZZGET2   Get record(s) for screen 2.
     *----------------------------------------------------------------

     C     zzget2        begsr
     C     endgt2        endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr

     *  Define key for options file.

     C     optnky        klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode

     *  Define key for options file, System values.

     C     optsky        klist
     C                   kfld                    kywhse
     C                   kfld                    opcode
     *
     *  Define key for PACKAGE1 FILE.
     *
     C     pkkey         klist
     C                   kfld                    sdpal
     C                   kfld                    ovrhng
     C                   kfld                    kyulen
     C                   kfld                    kyuwdt
     *
     *  Define key for SLOTDEF FILE.
     *
212 AC     sdkey         klist
212 AC                   kfld                    $itwhse
212 AC                   kfld                    sltdef            2
     *
     *     WORKOPT  (Partial key)
     *
     C                   eval      t#tie = 'IT210   '
     C     wkoprt        klist
     C                   kfld                    #user
     C                   kfld                    t#tie
     *
     *  Define key for ITEMFLD FILE.
     *
510  C     ifkey         klist
510  C                   kfld                    $itwhse
510  C                   kfld                    $ititem

510cAC     parkey        klist
510cAC                   kfld                    whcode
510cAC                   kfld                    w1itm2

     C                   eval      $lprg = #prog
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

     *  Open interface

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%OPEN'
     C                   eval      $drisys2upd = 'D'

     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endinz2
     C                   endif

     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop
     C****               if        error
     C****               goto      endinz2
     C****               endif
416cA
416cA*   Initialize screen indicators.
416cA
416cAC                   if        $pxflg = '1'
416cAC                   eval      *in81 = *on
416cAC                   eval      *in82 = *off
416cAC                   else
416cAC                   eval      *in82 = *on
416cAC                   eval      *in81 = *off
416cAC                   endif

     *   Get tie pattern options.

     C                   eval      opcode = '*PATTERN'
     C     optnky        chain     options                            79
 1B  C                   if        *in79
     C                   eval      ophang = 1
 1X  C                   else
     C                   eval      opdat1 = opdata
 1E  C                   endif
     C                   eval      ovrhng = ophang

     *   Get system options.

     C                   eval      kywhse = *zeros
     C                   eval      opcode = '*SYSTEM '
     C     optsky        chain     options                            79
 1B  C                   if        *in79
     C                   eval      opmpck = 'N'
 1X  C                   else
     C                   eval      opdat2 = opdata
 1E  C                   endif

     *   Get item maintenance options.

     C                   eval      opcode = '*ITEMMNT'
     C     optnky        chain     options                            79
 1B  C                   if        *in79
     C                   clear                   opdata
 1E  C                   endif

     *  Get warehouse description.

     C                   eval      whcode = $pwhse
     C                   eval      whdesc = ' '

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $pwhse        $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   when      $vreturn <> '*OK'
     C                   other
     C                   eval      whdesc = $vdesc
     C                   endsl

     *   Select first screen to display.

 1B  C                   if        $pcmd = '*ADD    '
     C                   eval      $pitem = *blanks
 1E  C                   endif

 1B  C                   if        $pcmd = '*WORKTIE'
     C                   exsr      zzget1
     C                   eval      w1item = $ititem

500aA*   Current item is a Breakdown item. Save setup.
500aAC                   if        $ittype = 'B'
510cAC                             or $ittype = 'R'
500aAC                   eval      w1rpkg = 'Y'
500aAC                   else
500aAC                   eval      w1rpkg = 'N'
500aAC                   endif

     C                   eval      w1desc = $itdesc
     C                   eval      w1styp = $itstyp
     C                   eval      w1whdp = $itwhdp
     C                   eval      w2um1 = $itum1
     C                   eval      w2um2 = $itum2
     C                   eval      w2um3 = $itum3
     C                   eval      w2ulen = $itulen
     C                   eval      w2uwdt = $ituwdt
510cAC                   if        $ittype = 'R'
510cAC                   eval      w1mflg = 'N'
510cAC                   else
     C                   eval      w1mflg = $immflg
510cAC                   endif
     C                   eval      w1mday = $immday
     C                   eval      w1dday = $imdday
     C                   eval      w1uday = $imuday
     C                   eval      w1nrpk = $imnrpk
417 AC                   eval      w1oday = $imoday
417 AC                   eval      w1ltrk = $imltrk
500dAC                   eval      w1cat = $ifcat
     C                   eval      woitem = %trim(w1item) + ' - ' + w1desc
     C                   exsr      scr03i
 1X  C                   else
     C                   move      *on           refrsh
     C                   exsr      scr01i
 1E  C                   endif

     C     endinz2       endsr

510cA*----------------------------------------------------------------
510cA*  ZZUOMPAR For Repack Items, get Unit of Measure from parent
510cA*----------------------------------------------------------------
510cA
510cAC     zzuompar      begsr
510cA
510cAC                   eval      *in92 = *off
510cAC                   eval      *in93 = *off
510cA
510cA *   If Repack Item 'R', load Unit of Measure from Parent Item
510cAC                   if        $pitpe = 'R'
510cA
510cA*   Get Unit of Measures.
510cA*    *IN92=Protect & non-display breakdown1 unit of measure
510cA*    *IN93=Protect & non-display breakdown2 unit of measure
510cA
510cAC                   exsr      fill$item
510cAC                   exsr      zzsavflds
510cA
510cA * Override and send parent item # to get parent uom
510cAC                   eval      $ititem  = w1itm2
510cAC                   eval      $dricommand = '*ITEM'
510cAC                   eval      $drisubcmd  = '%GETMAIN'
510cAC                   eval      $drisys2upd = 'D'
510cAC                   exsr      zzzdricop
510cA
510cAC                   if        error
510cAC                   eval      *in92 = *on
510cAC                   eval      *in93 = *on
510cAC                   exsr      zzrestflds
510cAC                   goto      enduom
510cAC                   else
510cA
510dDC**                 if        $itflg1 = 'N'
510dAC                   if        $itumq2 <= 0
510cAC                   eval      *in92 = *on
510cAC                   endif
510cA
510dDC**                 if        $itflg2 = 'N'
510dAC                   if        $itumq3 <= 0
510cAC                   eval      *in93 = *on
510cAC                   endif
510cAC                   endif
510cA
510cAC                   eval      w2rum1 = $itum1
510cAC                   eval      w2rum2 = $itum2
510cAC                   eval      w2rum3 = $itum3
510cAC                   exsr      zzrestflds
510cAC                   endif
510cAC     enduom        endsr
510cA
     *----------------------------------------------------------------
     *  ZZREPL
     *----------------------------------------------------------------

     C     zzrepl        begsr
 1B  C                   if        $lrepl = 'Y'
     C                   eval      n = 0
     C                   exsr      zzdft3
 1X  C                   else
     C                   eval      n = $lcnt
 1E  C                   endif
     *
     C     wkoprt        setll     workopt                            79
     C                   move      *in79         eof
 1B  C                   dow       eof = *off
 2B  C                   if        n > 5
 1L  C                   leave
 2E  C                   endif
     C                   move      *in79         eof
     C     wkoprt        reade     workopt                                79
     C                   move      *in79         eof
 2B  C                   if        not *in79
     C                   eval      wkfkey = wkokyf
 3B  C                   if        wksdef = w3st1
 1I  C                   iter
 3E  C                   endif
 3B  C                   if        wksdef = w3st2
 1I  C                   iter
 3E  C                   endif
 3B  C                   if        wksdef = w3st3
 1I  C                   iter
 3E  C                   endif
 3B  C                   if        wksdef = w3st4
 1I  C                   iter
 3E  C                   endif
 3B  C                   if        wksdef = w3st5
 1I  C                   iter
 3E  C                   endif
     C                   add       1             n
 3B  C                   if        n = 1
     C                   eval      w3st1 = wksdef
     C                   eval      w3tie1 = wktie
     C                   eval      w3hi1 = wkhigh
     C                   eval      w3prf1 = ' '
 3E  C                   endif
     *
 3B  C                   if        n = 2
     C                   eval      w3st2 = wksdef
     C                   eval      w3tie2 = wktie
     C                   eval      w3hi2 = wkhigh
     C                   eval      w3prf2 = ' '
 3E  C                   endif
     *
 3B  C                   if        n = 3
     C                   eval      w3st3 = wksdef
     C                   eval      w3tie3 = wktie
     C                   eval      w3hi3 = wkhigh
     C                   eval      w3prf3 = ' '
 3E  C                   endif
     *
 3B  C                   if        n = 4
     C                   eval      w3st4 = wksdef
     C                   eval      w3tie4 = wktie
     C                   eval      w3hi4 = wkhigh
     C                   eval      w3prf4 = ' '
 3E  C                   endif
     *
 3B  C                   if        n = 5
     C                   eval      w3st5 = wksdef
     C                   eval      w3tie5 = wktie
     C                   eval      w3hi5 = wkhigh
     C                   eval      w3prf5 = ' '
 3E  C                   endif
     *
 2E  C                   endif
 1E  C                   enddo
     *R
     C     endrep        endsr

510cA*----------------------------------------------------------------
510cA*  ZZRESTFLDS   Restore saved data structure fields
510cA*----------------------------------------------------------------
510cA
510cAC     zzrestflds    begsr
510cAC                   eval      $itver#    = #svitver#
510cAC                   eval      $itwhse    = #svitwhse
510cAC                   eval      $ititem    = #svititem
510cAC                   eval      $itmitem   = #svitmitem
510cAC                   eval      $itcitem   = #svitcitem
510cAC                   eval      $ittype    = #svittype
510cAC                   eval      $itdesc    = #svitdesc
510cAC                   eval      $itstyp    = #svitstyp
510cAC                   eval      $itwhdp    = #svitwhdp
510cAC                   eval      $itdesg    = #svitdesg
510cAC                   eval      $itactv    = #svitactv
510cAC                   eval      $itupc     = #svitupc
510cAC                   eval      $itbld     = #svitbld
510cAC                   eval      $itven#    = #svitven#
510cAC                   eval      $itvit#    = #svitvit#
510cAC                   eval      $itpdsc    = #svitpdsc
510cAC                   eval      $itum1     = #svitum1
510cAC                   eval      $itflg1    = #svitflg1
510cAC                   eval      $itum2     = #svitum2
510cAC                   eval      $itumq2    = #svitumq2
510cAC                   eval      $itflg2    = #svitflg2
510cAC                   eval      $itum3     = #svitum3
510cAC                   eval      $itumq3    = #svitumq3
510cAC                   eval      $itulen    = #svitulen
510cAC                   eval      $ituwdt    = #svituwdt
510cAC                   eval      $ituhgt    = #svituhgt
510cAC                   eval      $itcube    = #svitcube
510cAC                   eval      $itswgt    = #svitswgt
510cAC                   eval      $itcwgt    = #svitcwgt
510cAC                   eval      $itreor    = #svitreor
510cAC                   eval      $itrepl    = #svitrepl
510cAC                   eval      $itrcvd    = #svitrcvd
510cAC                   eval      $itflgd    = #svitflgd
510cAC                   eval      $itflgb    = #svitflgb
510cAC                   eval      $itslif    = #svitslif
510cAC                   eval      $itnday    = #svitnday
510cAC                   move      #svitsdef     $idsdef
510cAC                   move      #svittie      $idtie
510cAC                   move      #svithigh     $idhigh
510cAC                   move      #svitum       $idum
510cAC                   move      #svitpref     $idpref
510cAC                   eval      $ixdsc1    = #svixdsc1
510cAC                   eval      $ixdsc2    = #svixdsc2
510cAC                   eval      $imtie     = #svimtie
510cAC                   eval      $imhigh    = #svimhigh
510cAC                   eval      $immflg    = #svimmflg
510cAC                   eval      $imdday    = #svimdday
510cAC                   eval      $imuday    = #svimuday
510cAC                   eval      $immday    = #svimmday
510cAC                   eval      $imwrnc    = #svimwrnc
510cAC                   eval      $imrg1c    = #svimrg1c
510cAC                   eval      $imrg2c    = #svimrg2c
510cAC                   eval      $imapck    = #svimapck
510cAC                   eval      $imnrpk    = #svimnrpk
510cAC                   eval      $imnslt    = #svimnslt
510cAC                   eval      $imxdck    = #svimxdck
510cAC                   eval      $imbnbr    = #svimbnbr
510cAC                   eval      $imbnam    = #svimbnam
510cAC                   eval      $imvnam    = #svimvnam
510cAC                   eval      $imbrnd    = #svimbrnd
510cAC                   eval      $imlot     = #svimlot
510cAC                   eval      $imltrk    = #svimltrk
510cAC                   eval      $imoday    = #svimoday
510cAC                   eval      $ifcat     = #svifcat
510cAC                   eval      $kcqty1    = #svkcqty1
510cAC                   eval      $kcqty2    = #svkcqty2
510cAC                   eval      $kcqty3    = #svkcqty3
510cAC     endrest       endsr

510cA*----------------------------------------------------------------
510cA*  ZZSAVFLDS   Save data structure fields
510cA*----------------------------------------------------------------
510cA
510cAC     zzsavflds     begsr
510cAC                   eval      #svitver#  = $itver#
510cAC                   eval      #svitwhse  = $itwhse
510cAC                   eval      #svititem  = $ititem
510cAC                   eval      #svitmitem = $itmitem
510cAC                   eval      #svitcitem = $itcitem
510cAC                   eval      #svittype  = $ittype
510cAC                   eval      #svitdesc  = $itdesc
510cAC                   eval      #svitstyp  = $itstyp
510cAC                   eval      #svitwhdp  = $itwhdp
510cAC                   eval      #svitdesg  = $itdesg
510cAC                   eval      #svitactv  = $itactv
510cAC                   eval      #svitupc   = $itupc
510cAC                   eval      #svitbld   = $itbld
510cAC                   eval      #svitven#  = $itven#
510cAC                   eval      #svitvit#  = $itvit#
510cAC                   eval      #svitpdsc  = $itpdsc
510cAC                   eval      #svitum1   = $itum1
510cAC                   eval      #svitflg1  = $itflg1
510cAC                   eval      #svitum2   = $itum2
510cAC                   eval      #svitumq2  = $itumq2
510cAC                   eval      #svitflg2  = $itflg2
510cAC                   eval      #svitum3   = $itum3
510cAC                   eval      #svitumq3  = $itumq3
510cAC                   eval      #svitulen  = $itulen
510cAC                   eval      #svituwdt  = $ituwdt
510cAC                   eval      #svituhgt  = $ituhgt
510cAC                   eval      #svitcube  = $itcube
510cAC                   eval      #svitswgt  = $itswgt
510cAC                   eval      #svitcwgt  = $itcwgt
510cAC                   eval      #svitreor  = $itreor
510cAC                   eval      #svitrepl  = $itrepl
510cAC                   eval      #svitrcvd  = $itrcvd
510cAC                   eval      #svitflgd  = $itflgd
510cAC                   eval      #svitflgb  = $itflgb
510cAC                   eval      #svitslif  = $itslif
510cAC                   eval      #svitnday  = $itnday
510cAC                   move      $idsdef       #svitsdef
510cAC                   move      $idtie        #svittie
510cAC                   move      $idhigh       #svithigh
510cAC                   move      $idum         #svitum
510cAC                   move      $idsdef       #svitsdef
510cAC                   eval      #svixdsc1  = $ixdsc1
510cAC                   eval      #svixdsc2  = $ixdsc2
510cAC                   eval      #svimtie   = $imtie
510cAC                   eval      #svimhigh  = $imhigh
510cAC                   eval      #svimmflg  = $immflg
510cAC                   eval      #svimdday  = $imdday
510cAC                   eval      #svimuday  = $imuday
510cAC                   eval      #svimmday  = $immday
510cAC                   eval      #svimwrnc  = $imwrnc
510cAC                   eval      #svimrg1c  = $imrg1c
510cAC                   eval      #svimrg2c  = $imrg2c
510cAC                   eval      #svimapck  = $imapck
510cAC                   eval      #svimnrpk  = $imnrpk
510cAC                   eval      #svimnslt  = $imnslt
510cAC                   eval      #svimxdck  = $imxdck
510cAC                   eval      #svimbnbr  = $imbnbr
510cAC                   eval      #svimbnam  = $imbnam
510cAC                   eval      #svimvnam  = $imvnam
510cAC                   eval      #svimbrnd  = $imbrnd
510cAC                   eval      #svimlot   = $imlot
510cAC                   eval      #svimltrk  = $imltrk
510cAC                   eval      #svimoday  = $imoday
510cAC                   eval      #svifcat   = $ifcat
510cAC                   eval      #svkcqty1  = $kcqty1
510cAC                   eval      #svkcqty2  = $kcqty2
510cAC                   eval      #svkcqty3  = $kcqty3
510cAC     endsav        endsr

     *----------------------------------------------------------------
     *  ZZTIE
     *----------------------------------------------------------------

     C     zztie         begsr
     C                   eval      error = *off
     *
     *   Round length and width.
     *
     C                   z-add     w2ulen        kyulen
416aMC                   eval      decmal = kyulen - %int(kyulen)
     C                   eval      kyulen = kyulen - decmal
 1B  C                   if        decmal >= .5
     C                   add       .5            kyulen
 1E  C                   endif
     *
     C                   z-add     w2uwdt        kyuwdt
416aMC                   eval      decmal = kyuwdt - %int(kyuwdt)
     C                   eval      kyuwdt = kyuwdt - decmal
 1B  C                   if        decmal >= .5
     C                   add       .5            kyuwdt
 1E  C                   endif
     *
212 AC     sdkey         chain     slotdef                            79
212 AC     *in79         ifeq      *on
212 AC                   move      *blanks       sdpal
212 AC                   endif
     *
     C     pkkey         chain     package1                           79
 1B  C                   if        not *in79  and
     C                             w3tie = pktie
goto Csr                 goto      endtie
 1X  C                   else
     C                   move      *on           error
 1E  C                   endif
     C     endtie        endsr

     *----------------------------------------------------------------
     *  ZZUPD1   Update for screen 1.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   move      *off          error

     *   Format item description for following screens

416cDC**                 if        $pxflg = '0'
     C                   eval      woitem = %trim(w1item) + ' - ' + w1desc
416cDC**                 else
416cDC**                 eval      woitem = %trim(w1item) + ' - ' + w1dsc1
416cDC**                 endif

     *   Move item into parameter field.

 1B  C                   eval      $pitem = w1item

     C     endup1        endsr

     *----------------------------------------------------------------
     *  ZZUPD2   Update for screen 2.
     *----------------------------------------------------------------

     C     zzupd2        begsr
     C                   move      *off          error
     C     endup2        endsr

     *----------------------------------------------------------------
     *  ZZUPD3   Update for screen 3.
     *----------------------------------------------------------------

     C     zzupd3        begsr
     C                   move      *off          error

     *  Initialize interface fields.

     C                   if        $pcmd <> '*WORKTIE'
     C                   eval      fillscreen = 'ALL'
     C                   exsr      fill$item
     C                   endif

     *  Update Host.

     C                   eval      $dricommand = '*ITEM'
     C                   if        $pcmd = '*WORKTIE'
     C                   eval      $drisubcmd  = '%CHANGE'

500aA*   Current item is a Breakdown item. Set item type.
500aAC                   if        w1rpkg = 'Y'
510cA *
510cAC                   if        $pitpe = 'B'
500aAC                   eval      $ittype  = 'B'
510cAC                   endif
510cAC                   if        $pitpe = 'R'
510cAC                   eval      $ittype  = 'R'
510cAC                   endif
510cA *
500aAC                   else
500aAC                   eval      $ittype  = ' '
500aAC                   endif

     C                   else
     C                   eval      $drisubcmd  = $pcmd
     C                   eval      %subst($drisubcmd:1:1) = '%'
     C                   endif
     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop

     *  Update Dakota.

     C                   if        not error
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   endif
500c *  Update LABEL/PIRTRAN if department changed
500cAC                   if        $itwhdp <> svwhdp
500c C                   eval      whse = $pwhse
500c C                   call      'IT820'
500c C*                  parm                    whse
500c C                   parm                    $itwhse
500c C                   parm                    $itwhdp
500c C                   parm                    $itstyp
500c C                   parm                    $ititem
500c C                   parm                    $lrtn
500cAC                   endif

     C     endup3        endsr

     *----------------------------------------------------------------
     *  fill$item  Fill $item data structure fields.
     *----------------------------------------------------------------

     C     fill$item     begsr

     *  Initialize data structure

     C                   eval      savever# = $itver#
     C                   clear                   $item
416dAC                   clear                   $item2
     C                   eval      $itver# = savever#

     *  Move fields from record to data structure.

     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = w1item

     C                   eval      $ittypeu  = *on
     C                   if        w1rpkg = 'Y'
510cA *
510cAC                   if        $pitpe = 'B'
     C                   eval      $ittype  = 'B'
510cAC                   endif
510cAC                   if        $pitpe = 'R'
510cAC                   eval      $ittype  = 'R'
510cAC                   endif
510cA *
     C                   else
     C                   eval      $ittype  = ' '
     C                   endif

     C                   eval      $itmitemu = *on
     C                   eval      $itmitem = w1itm2

     *    Screen 1 fields.

     C                   if        fillscreen = '01' or fillscreen = 'ALL'

     C                   eval      $itdescu  = *on
     C                   if        $pxflg = '0'
     C                   eval      $itdesc  = w1desc
     C                   else
     C                   eval      $itdesc  = %subst(w1dsc2:1:30)
     C                   endif

     C                   eval      $itwhdpu  = *on
     C                   eval      $itwhdp  = w1whdp

     C                   eval      $itstypu  = *on
     C                   eval      $itstyp  = w1styp

     C                   eval      $itdesgu  = *on
     C                   eval      $itdesg  = w1desg

     C                   eval      $itactvu  = *on
     C                   eval      $itactv  = w1actv

     C                   eval      $itflgdu  = *on
     C                   eval      $itflgd  = w1flgd

     C                   eval      $itflgbu  = *on
     C                   eval      $itflgb  = w1flgb

     C                   eval      $itven#u  = *on
     C                   eval      $itven#  = w1ven#

     C                   eval      $itvit#u  = *on
     C                   eval      $itvit#  = w1vit#

     C                   eval      $itreplu  = *on
     C                   eval      $itrepl  = w1repl

     C                   if        $pxflg = '1'
     C                   eval      $ixdsc1u  = *on
     C                   eval      $ixdsc1  = %subst(w1dsc2:1:40)

     C                   eval      $ixdsc2u  = *on
     C                   eval      $ixdsc2  = %subst(w1dsc2:41:40)
     C                   endif

     C                   eval      $immflgu  = *on
     C                   eval      $immflg  = w1mflg

     C                   eval      $imddayu  = *on
     C                   eval      $imdday  = w1dday

     C                   eval      $imudayu  = *on
     C                   eval      $imuday  = w1uday

     C                   eval      $immdayu  = *on
     C                   eval      $immday  = w1mday

     C                   eval      $imnrpku  = *on
     C                   eval      $imnrpk  = w1nrpk

417 AC                   eval      $imodayu  = *on
417 AC                   eval      $imoday  = w1oday

417 AC                   eval      $imltrku  = *on
417 AC                   eval      $imltrk  = w1ltrk

500dAC                   eval      $ifcatu  = *on
500dAC                   eval      $ifcat  = w1cat

     C                   endif

     *    Screen 2 fields.

     C                   if        fillscreen = '02' or fillscreen = 'ALL'

     C                   eval      $itpdscu  = *on
     C                   eval      $itpdsc  = w2pdsc

     C                   eval      $itum1u   = *on
     C                   eval      $itum1   = w2um1

510cAC                   if        $pitpe <> 'R'
     C                   eval      $itum2u   = *on
     C                   eval      $itum2   = w2um2

     C                   eval      $itumq2u  = *on
     C                   eval      $itumq2  = w2umq2

     C                   eval      $itflg1u  = *on
     C                   eval      $itflg1  = w2flg1

     C                   eval      $itum3u   = *on
     C                   eval      $itum3   = w2um3

     C                   eval      $itumq3u  = *on
     C                   eval      $itumq3  = w2umq3

     C                   eval      $itflg2u  = *on
     C                   eval      $itflg2  = w2flg2
510cAC                   endif

     C                   eval      $itulenu  = *on
     C                   eval      $itulen  = w2ulen

     C                   eval      $ituwdtu  = *on
     C                   eval      $ituwdt  = w2uwdt

     C                   eval      $ituhgtu  = *on
     C                   eval      $ituhgt  = w2uhgt

     C                   eval      $itcubeu  = *on
     C                   eval      $itcube  = w2cube

     C                   eval      $itswgtu  = *on
     C                   eval      $itswgt  = w2swgt

     C                   eval      $itcwgtu  = *on
     C                   eval      $itcwgt  = w2cwgt

     C                   eval      $imrg1cu  = *on
     C                   eval      $imrg1c  = w2rg1c

     C                   eval      $imrg2cu  = *on
     C                   eval      $imrg2c  = w2rg2c

     C                   eval      $itbldu   = *on
     C                   eval      $itbld   = w2bld

     C                   eval      $itslifu  = *on
     C                   eval      $itslif  = w2slif

     C                   eval      $itndayu  = *on
     C                   eval      $itnday  = w2nday

417 AC                   eval      $imlotu  = *on
417 AC                   eval      $imlot   = w2lot

500bAC                   eval      $imnrpku  = *on
500bAC                   eval      $imnrpk  = w1nrpk

510cAC                   if        $pitpe = 'R'
510cAC                   eval      $kcqty1u = *on
510cAC                   eval      $kcqty1  = w2rqty1
510cAC                   eval      $kcqty2u = *on
510cAC                   eval      $kcqty2  = w2rqty2
510cAC                   eval      $kcqty3u = *on
510cAC                   eval      $kcqty3  = w2rqty3
510cAC                   endif

     C                   endif

     *    Screen 3 fields.

     C                   if        fillscreen = '03' or fillscreen = 'ALL'

     C                   eval      $imtieu   = *on
     C                   eval      $imtie   = w3mtie

     C                   eval      $imhighu  = *on
     C                   eval      $imhigh  = w3mhi

500bAC                   eval      $imnrpku  = *on
500bAC                   eval      $imnrpk  = w1nrpk

     C                   eval      curdef = 0
     C                   eval      curdef = curdef + 1
     C                   eval      $idsdefu(curdef) = *on
     C                   eval      $idsdef(curdef)  = w3st1
     C                   eval      $idtie(curdef)   = w3tie1
     C                   eval      $idhigh(curdef)  = w3hi1
     C                   eval      $idum(curdef)    ='N'
     C                   eval      $idpref(curdef)  = w3prf1

     C                   eval      curdef = curdef + 1
     C                   eval      $idsdefu(curdef) = *on
     C                   eval      $idsdef(curdef)  = w3st2
     C                   eval      $idtie(curdef)   = w3tie2
     C                   eval      $idhigh(curdef)  = w3hi2
     C                   eval      $idum(curdef)    ='N'
     C                   eval      $idpref(curdef)  = w3prf2

     C                   eval      curdef = curdef + 1
     C                   eval      $idsdefu(curdef) = *on
     C                   eval      $idsdef(curdef)  = w3st3
     C                   eval      $idtie(curdef)   = w3tie3
     C                   eval      $idhigh(curdef)  = w3hi3
     C                   eval      $idum(curdef)    ='N'
     C                   eval      $idpref(curdef)  = w3prf3

     C                   eval      curdef = curdef + 1
     C                   eval      $idsdefu(curdef) = *on
     C                   eval      $idsdef(curdef)  = w3st4
     C                   eval      $idtie(curdef)   = w3tie4
     C                   eval      $idhigh(curdef)  = w3hi4
     C                   eval      $idum(curdef)    ='N'
     C                   eval      $idpref(curdef)  = w3prf4

     C                   eval      curdef = curdef + 1
     C                   eval      $idsdefu(curdef) = *on
     C                   eval      $idsdef(curdef)  = w3st5
     C                   eval      $idtie(curdef)   = w3tie5
     C                   eval      $idhigh(curdef)  = w3hi5
     C                   eval      $idum(curdef)    ='N'
     C                   eval      $idpref(curdef)  = w3prf5

 1E  C                   endif

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
     C     $item         parm      $item         $dridata
416dAC     $item2        parm      $item2        $dridata2

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        zmsflag
     C                   exsr      zm0105s
     C                   else
     C                   exsr      zm0105
     C                   endif

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C                   exsr      zzerrind
     C                   endif

     C                   endsl

510  C                   select

510  C                   when      client = packers
510  c                   if        $drisubcmd  = '*CHANGE'
510  C     ifkey         chain     itemfld                            79
510  C                   if        not *in79
510  C     ifkey         chain     itemext1                           79
510  C                   if        not *in79
510  C                   eval      ikgrp = ifcat
510  C                   update    ikrec
510  C                   else
510  C                   eval      ikwhse =   ifwhse
510  C                   eval      ikitem =   ifitem
510  C                   eval      ikgrp  =   ifcat
510  C                   eval      ikmsc1 =   ' '
510  C                   eval      ikmsc2 =   ' '
510  C                   eval      ikmsc3 =   ' '
510  C                   eval      ikmsc4 =   ' '
510  C                   eval      ikmsc5 =   ' '
510  c                   write     ikrec
510  C                   endif
510  C                   endif
510  C                   endif

510  C                   endsl

     C                   eval      zmsflag = *off
     C     enddricop     endsr

     *---------------------------------------------------------------------****
     *  COMPILE TIME TABLES
     *---------------------------------------------------------------------****
**
          Standard Detail Entry
         Breakdown Detail Entry
           Repack Detail Entry
